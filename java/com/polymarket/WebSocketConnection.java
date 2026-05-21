package com.polymarket;

import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Arrays;
import java.util.Base64;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import javax.net.ssl.SSLSocketFactory;

public final class WebSocketConnection implements Runnable {
    private static final String MAGIC = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

    private final LinkedBlockingQueue<String> messages = new LinkedBlockingQueue<String>();
    private final SecureRandom random = new SecureRandom();
    private final AtomicBoolean open = new AtomicBoolean(false);

    private Socket socket;
    private InputStream input;
    private OutputStream output;
    private Thread reader;

    private WebSocketConnection() {
    }

    public static WebSocketConnection connect(String uriText) throws Exception {
        WebSocketConnection connection = new WebSocketConnection();
        connection.open(uriText);
        return connection;
    }

    public void send(String message) throws IOException {
        sendFrame(0x1, message.getBytes(StandardCharsets.UTF_8));
    }

    public String receive(int timeoutMillis) throws InterruptedException {
        if (timeoutMillis <= 0) {
            return messages.poll();
        }
        return messages.poll(timeoutMillis, TimeUnit.MILLISECONDS);
    }

    public void close() throws IOException {
        if (open.getAndSet(false)) {
            sendFrame(0x8, new byte[0]);
        }
        if (socket != null) {
            socket.close();
        }
    }

    @Override
    public void run() {
        ByteArrayOutputStream continuation = new ByteArrayOutputStream();
        try {
            while (open.get()) {
                Frame frame = readFrame();
                if (frame.opcode == 0x1) {
                    if (frame.fin) {
                        messages.offer(new String(frame.payload, StandardCharsets.UTF_8));
                    } else {
                        continuation.write(frame.payload);
                    }
                } else if (frame.opcode == 0x0) {
                    continuation.write(frame.payload);
                    if (frame.fin) {
                        messages.offer(new String(continuation.toByteArray(), StandardCharsets.UTF_8));
                        continuation.reset();
                    }
                } else if (frame.opcode == 0x8) {
                    open.set(false);
                    break;
                } else if (frame.opcode == 0x9) {
                    sendFrame(0xA, frame.payload);
                }
            }
        } catch (Exception error) {
            if (open.get()) {
                messages.offer("{\"event_type\":\"error\",\"message\":\"" + escape(error.getMessage()) + "\"}");
            }
        } finally {
            open.set(false);
        }
    }

    private void open(String uriText) throws Exception {
        URI uri = new URI(uriText);
        String scheme = uri.getScheme();
        boolean secure = "wss".equalsIgnoreCase(scheme);
        int port = uri.getPort();
        if (port < 0) {
            port = secure ? 443 : 80;
        }

        if (secure) {
            socket = SSLSocketFactory.getDefault().createSocket(uri.getHost(), port);
        } else {
            socket = new Socket(uri.getHost(), port);
        }
        input = socket.getInputStream();
        output = socket.getOutputStream();
        handshake(uri, port, secure);

        open.set(true);
        reader = new Thread(this, "polymarket-websocket-reader");
        reader.setDaemon(true);
        reader.start();
    }

    private void handshake(URI uri, int port, boolean secure) throws Exception {
        byte[] nonce = new byte[16];
        random.nextBytes(nonce);
        String key = Base64.getEncoder().encodeToString(nonce);
        String path = uri.getRawPath();
        if (path == null || path.length() == 0) {
            path = "/";
        }
        if (uri.getRawQuery() != null) {
            path = path + "?" + uri.getRawQuery();
        }

        String host = uri.getHost();
        if ((!secure && port != 80) || (secure && port != 443)) {
            host = host + ":" + port;
        }

        String request = "GET " + path + " HTTP/1.1\r\n" +
            "Host: " + host + "\r\n" +
            "Upgrade: websocket\r\n" +
            "Connection: Upgrade\r\n" +
            "Sec-WebSocket-Key: " + key + "\r\n" +
            "Sec-WebSocket-Version: 13\r\n" +
            "User-Agent: matlab-polymarket/0.1.0\r\n\r\n";
        output.write(request.getBytes(StandardCharsets.US_ASCII));
        output.flush();

        String response = readHttpHeader();
        if (!response.startsWith("HTTP/1.1 101") && !response.startsWith("HTTP/1.0 101")) {
            throw new IOException("WebSocket upgrade failed: " + firstLine(response));
        }
        String expected = Base64.getEncoder().encodeToString(
            MessageDigest.getInstance("SHA-1").digest((key + MAGIC).getBytes(StandardCharsets.US_ASCII)));
        if (!response.toLowerCase().contains("sec-websocket-accept: " + expected.toLowerCase())) {
            throw new IOException("WebSocket upgrade response had an invalid accept key");
        }
    }

    private String readHttpHeader() throws IOException {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        int previous3 = -1;
        int previous2 = -1;
        int previous1 = -1;
        while (true) {
            int current = input.read();
            if (current < 0) {
                throw new EOFException("Unexpected EOF during WebSocket handshake");
            }
            buffer.write(current);
            if (previous3 == '\r' && previous2 == '\n' && previous1 == '\r' && current == '\n') {
                return new String(buffer.toByteArray(), StandardCharsets.US_ASCII);
            }
            previous3 = previous2;
            previous2 = previous1;
            previous1 = current;
        }
    }

    private Frame readFrame() throws IOException {
        int b1 = readByte();
        int b2 = readByte();
        boolean fin = (b1 & 0x80) != 0;
        int opcode = b1 & 0x0F;
        boolean masked = (b2 & 0x80) != 0;
        long length = b2 & 0x7F;
        if (length == 126) {
            length = ((long) readByte() << 8) | readByte();
        } else if (length == 127) {
            length = 0;
            for (int i = 0; i < 8; i++) {
                length = (length << 8) | readByte();
            }
        }
        if (length > Integer.MAX_VALUE) {
            throw new IOException("WebSocket frame too large");
        }

        byte[] mask = new byte[4];
        if (masked) {
            readFully(mask);
        }
        byte[] payload = new byte[(int) length];
        readFully(payload);
        if (masked) {
            for (int i = 0; i < payload.length; i++) {
                payload[i] = (byte) (payload[i] ^ mask[i % 4]);
            }
        }
        return new Frame(fin, opcode, payload);
    }

    private void sendFrame(int opcode, byte[] payload) throws IOException {
        ByteArrayOutputStream frame = new ByteArrayOutputStream();
        frame.write(0x80 | opcode);
        int length = payload.length;
        if (length <= 125) {
            frame.write(0x80 | length);
        } else if (length <= 65535) {
            frame.write(0x80 | 126);
            frame.write((length >>> 8) & 0xFF);
            frame.write(length & 0xFF);
        } else {
            frame.write(0x80 | 127);
            for (int i = 7; i >= 0; i--) {
                frame.write((length >>> (8 * i)) & 0xFF);
            }
        }

        byte[] mask = new byte[4];
        random.nextBytes(mask);
        frame.write(mask);
        byte[] maskedPayload = Arrays.copyOf(payload, payload.length);
        for (int i = 0; i < maskedPayload.length; i++) {
            maskedPayload[i] = (byte) (maskedPayload[i] ^ mask[i % 4]);
        }
        frame.write(maskedPayload);

        synchronized (this) {
            output.write(frame.toByteArray());
            output.flush();
        }
    }

    private int readByte() throws IOException {
        int value = input.read();
        if (value < 0) {
            throw new EOFException("Unexpected EOF while reading WebSocket frame");
        }
        return value;
    }

    private void readFully(byte[] bytes) throws IOException {
        int offset = 0;
        while (offset < bytes.length) {
            int count = input.read(bytes, offset, bytes.length - offset);
            if (count < 0) {
                throw new EOFException("Unexpected EOF while reading WebSocket payload");
            }
            offset += count;
        }
    }

    private static String firstLine(String text) {
        int index = text.indexOf("\r\n");
        if (index < 0) {
            return text;
        }
        return text.substring(0, index);
    }

    private static String escape(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static final class Frame {
        final boolean fin;
        final int opcode;
        final byte[] payload;

        Frame(boolean fin, int opcode, byte[] payload) {
            this.fin = fin;
            this.opcode = opcode;
            this.payload = payload;
        }
    }
}
