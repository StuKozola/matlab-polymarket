classdef Client < handle
    %CLIENT Base HTTP client for Polymarket REST APIs.

    properties
        BaseUrl string
        Auth = []
        Timeout double = 30
        MaxRetries double = 2
        UserAgent string = "matlab-polymarket/0.1.1"
        ReturnTables logical = false
    end

    methods
        function obj = Client(baseUrl, options)
            arguments
                baseUrl string
                options.Auth = []
                options.Timeout double = 30
                options.MaxRetries double = 2
                options.UserAgent string = "matlab-polymarket/0.1.1"
                options.ReturnTables logical = false
            end

            obj.BaseUrl = erase(string(baseUrl), regexpPattern("/$"));
            obj.Auth = options.Auth;
            obj.Timeout = options.Timeout;
            obj.MaxRetries = options.MaxRetries;
            obj.UserAgent = options.UserAgent;
            obj.ReturnTables = options.ReturnTables;
        end

        function data = get(obj, path, varargin)
            %GET Send a GET request. Name-value arguments become query params.
            [query, auth, headers, raw] = polymarket.internal.splitRequestOptions(varargin{:});
            data = obj.request("GET", path, "Query", query, "Auth", auth, ...
                "Headers", headers, "Raw", raw);
        end

        function data = post(obj, path, body, varargin)
            %POST Send a POST request with a JSON body.
            if nargin < 3
                body = struct();
            end
            [query, auth, headers, raw] = polymarket.internal.splitRequestOptions(varargin{:});
            data = obj.request("POST", path, "Query", query, "Body", body, ...
                "Auth", auth, "Headers", headers, "Raw", raw);
        end

        function data = put(obj, path, body, varargin)
            %PUT Send a PUT request with a JSON body.
            if nargin < 3
                body = struct();
            end
            [query, auth, headers, raw] = polymarket.internal.splitRequestOptions(varargin{:});
            data = obj.request("PUT", path, "Query", query, "Body", body, ...
                "Auth", auth, "Headers", headers, "Raw", raw);
        end

        function data = delete(obj, path, body, varargin)
            %DELETE Send a DELETE request with an optional JSON body.
            if nargin < 3
                body = [];
            end
            [query, auth, headers, raw] = polymarket.internal.splitRequestOptions(varargin{:});
            data = obj.request("DELETE", path, "Query", query, "Body", body, ...
                "Auth", auth, "Headers", headers, "Raw", raw);
        end

        function data = request(obj, method, path, options)
            %REQUEST Low-level HTTP request.
            arguments
                obj
                method string
                path string
                options.Query = struct()
                options.Body = []
                options.Auth = false
                options.Headers = struct()
                options.Raw logical = false
            end

            queryText = polymarket.internal.encodeQuery(options.Query);
            requestPath = obj.pathWithQuery(path, queryText);
            bodyText = obj.bodyText(options.Body);
            headers = obj.httpHeaders(options.Headers, options.Auth, method, requestPath, bodyText);
            uri = matlab.net.URI(obj.urlWithQuery(path, queryText));
            requestMethod = matlab.net.http.RequestMethod.(char(upper(method)));
            messageBody = [];
            if strlength(bodyText) > 0
                messageBody = matlab.net.http.MessageBody(char(bodyText));
            end
            requestMessage = matlab.net.http.RequestMessage(requestMethod, headers, messageBody);
            httpOptions = matlab.net.http.HTTPOptions("ConnectTimeout", obj.Timeout);

            response = [];
            for attempt = 0:obj.MaxRetries
                try
                    response = send(requestMessage, uri, httpOptions);
                catch err
                    if attempt >= obj.MaxRetries
                        rethrow(err)
                    end
                    pause(obj.retryDelay(attempt));
                    continue
                end

                status = double(response.StatusCode);
                if status ~= 429 && status < 500
                    break
                end
                if attempt >= obj.MaxRetries
                    break
                end
                pause(obj.retryDelay(attempt));
            end

            status = double(response.StatusCode);
            if status < 200 || status >= 300
                obj.throwHttpError(response);
            end
            data = obj.parseResponse(response, options.Raw);
        end
    end

    methods (Access = private)
        function headers = httpHeaders(obj, extraHeaders, authMode, method, requestPath, bodyText)
            headers = matlab.net.http.HeaderField.empty(1, 0);
            headers(end + 1) = matlab.net.http.HeaderField("User-Agent", char(obj.UserAgent));
            headers(end + 1) = matlab.net.http.HeaderField("Accept", "application/json");
            if strlength(bodyText) > 0
                headers(end + 1) = matlab.net.http.HeaderField("Content-Type", "application/json");
            end

            if polymarket.internal.isTruthy(authMode)
                if isempty(obj.Auth)
                    error("polymarket:MissingAuth", ...
                        "This endpoint requires an AuthConfig object.");
                end
                authText = upper(string(authMode));
                if authText == "TRUE" || authText == "L2"
                    authHeaders = obj.Auth.l2Headers(method, requestPath, bodyText);
                elseif authText == "L1"
                    authHeaders = obj.Auth.l1Headers(method, requestPath, bodyText, 0);
                else
                    error("polymarket:InvalidAuthMode", ...
                        "Unsupported authentication mode: %s", string(authMode));
                end
                headers = obj.appendHeaders(headers, authHeaders);
            end
            headers = obj.appendHeaders(headers, extraHeaders);
        end

        function headers = appendHeaders(~, headers, extraHeaders)
            if isempty(extraHeaders)
                return
            end
            if isa(extraHeaders, "containers.Map")
                names = string(extraHeaders.keys);
                for i = 1:numel(names)
                    headers(end + 1) = matlab.net.http.HeaderField(char(names(i)), char(string(extraHeaders(char(names(i)))))); %#ok<AGROW>
                end
                return
            end
            names = fieldnames(extraHeaders);
            for i = 1:numel(names)
                name = names{i};
                headers(end + 1) = matlab.net.http.HeaderField(name, char(string(extraHeaders.(name)))); %#ok<AGROW>
            end
        end

        function text = bodyText(~, body)
            if isempty(body)
                text = "";
            elseif ischar(body) || (isstring(body) && isscalar(body))
                text = string(body);
            else
                text = string(jsonencode(body));
            end
        end

        function url = urlWithQuery(obj, path, queryText)
            url = obj.BaseUrl + obj.normalizePath(path);
            if strlength(queryText) > 0
                url = url + "?" + queryText;
            end
        end

        function path = pathWithQuery(obj, path, queryText)
            path = obj.normalizePath(path);
            if strlength(queryText) > 0
                path = path + "?" + queryText;
            end
        end

        function path = normalizePath(~, path)
            path = string(path);
            if ~startsWith(path, "/")
                path = "/" + path;
            end
        end

        function delay = retryDelay(~, attempt)
            delay = min(0.25 * 2^attempt, 2.0);
        end

        function data = parseResponse(obj, response, raw)
            bodyData = response.Body.Data;
            if raw
                data = bodyData;
                return
            end
            if isempty(bodyData)
                data = [];
                return
            end
            if isstruct(bodyData) || iscell(bodyData)
                data = bodyData;
            elseif isnumeric(bodyData) || islogical(bodyData)
                text = string(char(bodyData(:).'));
                data = obj.decodeText(text);
            else
                data = obj.decodeText(string(bodyData));
            end
            if obj.ReturnTables
                data = polymarket.internal.maybeTable(data);
            end
        end

        function data = decodeText(~, text)
            text = strtrim(text);
            if strlength(text) == 0
                data = [];
                return
            end
            first = extractBetween(text, 1, 1);
            if first == "{" || first == "["
                data = jsondecode(char(text));
            else
                data = text;
            end
        end

        function throwHttpError(obj, response)
            body = obj.parseResponse(response, false);
            if isstruct(body) && isfield(body, "error")
                detail = string(body.error);
            elseif isstruct(body) && isfield(body, "message")
                detail = string(body.message);
            else
                detail = string(jsonencode(body));
            end
            error("polymarket:HttpError", "Polymarket HTTP %d: %s", ...
                double(response.StatusCode), detail);
        end
    end
end
