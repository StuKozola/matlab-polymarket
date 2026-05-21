classdef GammaClient < polymarket.Client
    %GAMMACLIENT Client for the Polymarket Gamma API.

    methods
        function obj = GammaClient(options)
            arguments
                options.BaseUrl string = "https://gamma-api.polymarket.com"
                options.Auth = []
                options.Timeout double = 30
                options.MaxRetries double = 2
                options.ReturnTables logical = false
            end
            obj@polymarket.Client(options.BaseUrl, "Auth", options.Auth, ...
                "Timeout", options.Timeout, "MaxRetries", options.MaxRetries, ...
                "ReturnTables", options.ReturnTables);
        end

        function data = status(obj)
            data = obj.get("/status");
        end

        function data = listTeams(obj, varargin)
            data = obj.get("/teams", varargin{:});
        end

        function data = getTeam(obj, id, varargin)
            data = obj.get("/teams/" + polymarket.internal.urlEncode(id), varargin{:});
        end

        function data = listTags(obj, varargin)
            data = obj.get("/tags", varargin{:});
        end

        function data = getTag(obj, id, varargin)
            data = obj.get("/tags/" + polymarket.internal.urlEncode(id), varargin{:});
        end

        function data = getTagBySlug(obj, slug, varargin)
            data = obj.get("/tags/slug/" + polymarket.internal.urlEncode(slug), varargin{:});
        end

        function data = getRelatedTagsById(obj, id, varargin)
            data = obj.get("/tags/" + polymarket.internal.urlEncode(id) + "/related-tags", varargin{:});
        end

        function data = getRelatedTagsBySlug(obj, slug, varargin)
            data = obj.get("/tags/slug/" + polymarket.internal.urlEncode(slug) + "/related-tags", varargin{:});
        end

        function data = getTagsRelatedToATagById(obj, id, varargin)
            data = obj.get("/tags/" + polymarket.internal.urlEncode(id) + "/related-tags/tags", varargin{:});
        end

        function data = getTagsRelatedToATagBySlug(obj, slug, varargin)
            data = obj.get("/tags/slug/" + polymarket.internal.urlEncode(slug) + "/related-tags/tags", varargin{:});
        end

        function data = listEvents(obj, varargin)
            data = obj.get("/events", varargin{:});
        end

        function data = listEventsPagination(obj, varargin)
            data = obj.get("/events/pagination", varargin{:});
        end

        function data = listEventsKeyset(obj, varargin)
            data = obj.get("/events/keyset", varargin{:});
        end

        function data = listSportEventsResults(obj, varargin)
            data = obj.get("/events/results", varargin{:});
        end

        function data = getEvent(obj, id, varargin)
            data = obj.get("/events/" + polymarket.internal.urlEncode(id), varargin{:});
        end

        function data = getEventBySlug(obj, slug, varargin)
            data = obj.get("/events/slug/" + polymarket.internal.urlEncode(slug), varargin{:});
        end

        function data = getEventTweetCount(obj, id, varargin)
            data = obj.get("/events/" + polymarket.internal.urlEncode(id) + "/tweet-count", varargin{:});
        end

        function data = getEventCommentsCount(obj, id, varargin)
            data = obj.get("/events/" + polymarket.internal.urlEncode(id) + "/comments/count", varargin{:});
        end

        function data = getEventTags(obj, id, varargin)
            data = obj.get("/events/" + polymarket.internal.urlEncode(id) + "/tags", varargin{:});
        end

        function data = listEventCreators(obj, varargin)
            data = obj.get("/events/creators", varargin{:});
        end

        function data = getEventCreator(obj, id, varargin)
            data = obj.get("/events/creators/" + polymarket.internal.urlEncode(id), varargin{:});
        end

        function data = listMarkets(obj, varargin)
            data = obj.get("/markets", varargin{:});
        end

        function data = listMarketsKeyset(obj, varargin)
            data = obj.get("/markets/keyset", varargin{:});
        end

        function data = getMarket(obj, id, varargin)
            data = obj.get("/markets/" + polymarket.internal.urlEncode(id), varargin{:});
        end

        function data = getMarketBySlug(obj, slug, varargin)
            data = obj.get("/markets/slug/" + polymarket.internal.urlEncode(slug), varargin{:});
        end

        function data = getMarketDescription(obj, id, varargin)
            data = obj.get("/markets/" + polymarket.internal.urlEncode(id) + "/description", varargin{:});
        end

        function data = getMarketTags(obj, id, varargin)
            data = obj.get("/markets/" + polymarket.internal.urlEncode(id) + "/tags", varargin{:});
        end

        function data = getMarketsInformation(obj, body, varargin)
            data = obj.post("/markets/information", body, varargin{:});
        end

        function data = getAbridgedMarkets(obj, body, varargin)
            data = obj.post("/markets/abridged", body, varargin{:});
        end

        function data = listSeries(obj, varargin)
            data = obj.get("/series", varargin{:});
        end

        function data = getSeries(obj, id, varargin)
            data = obj.get("/series/" + polymarket.internal.urlEncode(id), varargin{:});
        end

        function data = getSeriesCommentsCount(obj, id, varargin)
            data = obj.get("/series/" + polymarket.internal.urlEncode(id) + "/comments/count", varargin{:});
        end

        function data = getSeriesSummaryById(obj, id, varargin)
            data = obj.get("/series-summary/" + polymarket.internal.urlEncode(id), varargin{:});
        end

        function data = getSeriesSummaryBySlug(obj, slug, varargin)
            data = obj.get("/series-summary/slug/" + polymarket.internal.urlEncode(slug), varargin{:});
        end

        function data = listComments(obj, varargin)
            data = obj.get("/comments", varargin{:});
        end

        function data = getCommentsById(obj, id, varargin)
            data = obj.get("/comments/" + polymarket.internal.urlEncode(id), varargin{:});
        end

        function data = getCommentsByUserAddress(obj, userAddress, varargin)
            data = obj.get("/comments/user_address/" + polymarket.internal.urlEncode(userAddress), varargin{:});
        end

        function data = getPublicProfile(obj, varargin)
            data = obj.get("/public-profile", varargin{:});
        end

        function data = getPublicProfileByUserAddress(obj, userAddress, varargin)
            data = obj.get("/profiles/user_address/" + polymarket.internal.urlEncode(userAddress), varargin{:});
        end

        function data = getSportsMetadata(obj, varargin)
            data = obj.get("/sports", varargin{:});
        end

        function data = getSportsMarketTypes(obj, varargin)
            data = obj.get("/sports/market-types", varargin{:});
        end

        function data = publicSearch(obj, varargin)
            data = obj.get("/public-search", varargin{:});
        end
    end
end

