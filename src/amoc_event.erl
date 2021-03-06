-module(amoc_event).

-export([start_link/0,
         add_handler/2,
         notify/1]).

%% ------------------------------------------------------------------
%% API Function Definitions
%% ------------------------------------------------------------------
-spec start_link() -> {ok, pid()} | {error, {already_started, pid()}}.
start_link() ->
    gen_event:start_link({local, ?MODULE}).

-spec add_handler(module(), term()) ->  ok | {'EXIT', term()} | term().
add_handler(Handler, Args) ->
    gen_event:add_handler(?MODULE, Handler, Args).

-spec notify(term()) -> ok.
notify(Event) ->
    gen_event:notify(?MODULE, Event).
