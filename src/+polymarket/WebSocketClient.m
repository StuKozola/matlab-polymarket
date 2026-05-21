classdef WebSocketClient < handle
    %WEBSOCKETCLIENT Polymarket WebSocket client wrapper.
    %   Requires the helper JAR built by tools/buildJavaHelper.m.

    properties
        Url string
        Channel string
        Auth = []
        Connection = []
        PollTimer = []
        Callback = []
    end

    methods
        function obj = WebSocketClient(url, channel, options)
            arguments
                url string
                channel string
                options.Auth = []
            end
            obj.Url = url;
            obj.Channel = channel;
            obj.Auth = options.Auth;
        end

        function connect(obj)
            %CONNECT Open the WebSocket connection.
            obj.ensureJavaHelper();
            obj.Connection = com.polymarket.WebSocketConnection.connect(char(obj.Url));
        end

        function subscription = subscribe(obj, ids, callback, options)
            %SUBSCRIBE Subscribe and optionally start a MATLAB callback timer.
            arguments
                obj
                ids = strings(1, 0)
                callback = []
                options.SendInitialBook logical = true
                options.Hash string = ""
            end

            if isempty(obj.Connection)
                obj.connect();
            end
            obj.Callback = callback;

            switch lower(obj.Channel)
                case "market"
                    payload = struct( ...
                        "assets_ids", string(ids), ...
                        "type", "market", ...
                        "initial_dump", options.SendInitialBook);
                    if strlength(options.Hash) > 0
                        payload.hash = options.Hash;
                    end
                    obj.send(payload);
                case "user"
                    if isempty(obj.Auth)
                        error("polymarket:MissingAuth", ...
                            "AuthConfig is required for the user WebSocket channel.");
                    end
                    payload = struct( ...
                        "auth", obj.Auth.websocketAuth(), ...
                        "type", "user");
                    if ~isempty(ids)
                        payload.markets = string(ids);
                    end
                    obj.send(payload);
                case "sports"
                    % Sports sends updates immediately after connect.
                otherwise
                    error("polymarket:InvalidChannel", "Unsupported channel: %s", obj.Channel);
            end

            if ~isempty(callback)
                obj.startPolling();
            end
            subscription = obj;
        end

        function updateSubscription(obj, operation, ids, options)
            %UPDATESUBSCRIPTION Subscribe or unsubscribe without reconnecting.
            arguments
                obj
                operation string {mustBeMember(operation, ["subscribe", "unsubscribe"])}
                ids
                options.Hash string = ""
            end

            switch lower(obj.Channel)
                case "market"
                    payload = struct("operation", operation, "assets_ids", string(ids));
                    if strlength(options.Hash) > 0
                        payload.hash = options.Hash;
                    end
                case "user"
                    payload = struct("operation", operation, "markets", string(ids));
                otherwise
                    error("polymarket:InvalidChannel", ...
                        "Dynamic subscription updates are not supported for %s.", obj.Channel);
            end
            obj.send(payload);
        end

        function send(obj, payload)
            %SEND Send a raw JSON-serializable payload.
            if isempty(obj.Connection)
                obj.connect();
            end
            if ischar(payload) || (isstring(payload) && isscalar(payload))
                text = string(payload);
            else
                text = string(jsonencode(payload));
            end
            obj.Connection.send(char(text));
        end

        function message = receive(obj, timeout)
            %RECEIVE Receive one message, or [] after timeout seconds.
            if nargin < 2
                timeout = 0;
            end
            if isempty(obj.Connection)
                obj.connect();
            end
            raw = obj.Connection.receive(int32(round(timeout * 1000)));
            if isempty(raw)
                message = [];
                return
            end
            message = polymarket.WebSocketClient.decodeMessage(string(raw));
        end

        function close(obj)
            %CLOSE Close the WebSocket and callback timer.
            if ~isempty(obj.PollTimer) && isvalid(obj.PollTimer)
                stop(obj.PollTimer);
                delete(obj.PollTimer);
            end
            obj.PollTimer = [];
            if ~isempty(obj.Connection)
                obj.Connection.close();
            end
            obj.Connection = [];
        end

        function delete(obj)
            obj.close();
        end
    end

    methods (Access = private)
        function ensureJavaHelper(~)
            if exist("com.polymarket.WebSocketConnection", "class") ~= 8
                jarFile = fullfile(fileparts(fileparts(fileparts(mfilename("fullpath")))), ...
                    "lib", "polymarket-java-helper.jar");
                if isfile(jarFile)
                    javaaddpath(jarFile);
                end
            end
            if exist("com.polymarket.WebSocketConnection", "class") ~= 8
                error("polymarket:MissingJavaHelper", ...
                    "Build the WebSocket helper with tools/buildJavaHelper.m before using WebSocketClient.");
            end
        end

        function startPolling(obj)
            if ~isempty(obj.PollTimer) && isvalid(obj.PollTimer)
                start(obj.PollTimer);
                return
            end
            obj.PollTimer = timer( ...
                "ExecutionMode", "fixedSpacing", ...
                "Period", 0.1, ...
                "TimerFcn", @(~, ~) obj.drainMessages());
            start(obj.PollTimer);
        end

        function drainMessages(obj)
            if isempty(obj.Callback) || isempty(obj.Connection)
                return
            end
            while true
                message = obj.receive(0);
                if isempty(message)
                    break
                end
                obj.Callback(message);
            end
        end
    end

    methods (Static)
        function obj = market(options)
            arguments
                options.Auth = []
            end
            obj = polymarket.WebSocketClient( ...
                "wss://ws-subscriptions-clob.polymarket.com/ws/market", ...
                "market", "Auth", options.Auth);
        end

        function obj = user(options)
            arguments
                options.Auth = []
            end
            obj = polymarket.WebSocketClient( ...
                "wss://ws-subscriptions-clob.polymarket.com/ws/user", ...
                "user", "Auth", options.Auth);
        end

        function obj = sports()
            obj = polymarket.WebSocketClient( ...
                "wss://sports-api.polymarket.com/ws", "sports");
        end

        function message = decodeMessage(raw)
            raw = strtrim(string(raw));
            if strlength(raw) == 0
                message = [];
            elseif startsWith(raw, "{") || startsWith(raw, "[")
                message = jsondecode(char(raw));
            else
                message = raw;
            end
        end
    end
end

