package com.polymarket;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.WebSocket;
import java.time.Duration;
import java.util.concurrent.CompletionStage;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

public final class WebSocketConnection implements WebSocket.Listener {
    private final LinkedBlockingQueue<String> messages = new LinkedBlockingQueue<>();
    private final StringBuilder partial = new StringBuilder();
    private WebSocket webSocket;

    public static WebSocketConnection connect(String uri) {
        WebSocketConnection connection = new WebSocketConnection();
        HttpClient client = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(30))
            .build();
        connection.webSocket = client.newWebSocketBuilder()
            .buildAsync(URI.create(uri), connection)
            .join();
        return connection;
    }

    public void send(String message) {
        webSocket.sendText(message, true).join();
    }

    public String receive(int timeoutMillis) throws InterruptedException {
        if (timeoutMillis <= 0) {
            return messages.poll();
        }
        return messages.poll(timeoutMillis, TimeUnit.MILLISECONDS);
    }

    public void close() {
        if (webSocket != null) {
            webSocket.sendClose(WebSocket.NORMAL_CLOSURE, "closed").join();
        }
    }

    @Override
    public CompletionStage<?> onText(WebSocket socket, CharSequence data, boolean last) {
        partial.append(data);
        if (last) {
            messages.offer(partial.toString());
            partial.setLength(0);
        }
        socket.request(1);
        return null;
    }

    @Override
    public void onOpen(WebSocket socket) {
        socket.request(1);
    }

    @Override
    public CompletionStage<?> onPing(WebSocket socket, java.nio.ByteBuffer message) {
        socket.sendPong(message);
        socket.request(1);
        return null;
    }

    @Override
    public void onError(WebSocket socket, Throwable error) {
        messages.offer("{\"event_type\":\"error\",\"message\":\"" + escape(error.getMessage()) + "\"}");
    }

    private static String escape(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}

