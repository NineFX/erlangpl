%%%-------------------------------------------------------------------
%%% @doc
%%% Websocket handler returning supervision trees data to web client
%%% @end
%%%-------------------------------------------------------------------

-module(epl_st_EPL).

-behaviour(cowboy_websocket_handler).

%% EPL plugin callbacks
-export([start_link/1,
         init/1]).

%% cowboy_websocket_handler callbacks
-export([init/3,
         websocket_init/3,
         websocket_handle/3,
         websocket_info/3,
         websocket_terminate/3]).

%%%===================================================================
%%% EPL plugin callbacks
%%%===================================================================
start_link(_Options) ->
    {ok, spawn(fun() -> receive _ -> ok end end)}.

init(_Options) ->
    MenuItem = <<"<li class=\"glyphicons share_alt\">",
                   "<a href=\"/epl_st/index.html\"><i></i>",
                   "<span>Supervision trees</span></a>",
                 "</li>">>,
    Author = <<"Erlang Lab">>,
    {ok, [{menu_item, MenuItem}, {author, Author}]}.

%%%===================================================================
%%% cowboy_websocket_handler callbacks
%%%===================================================================
init({tcp, http}, _Req, _Opts) ->
    epl_st:subscribe(),
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
    {ok, Req, undefined_state}.

websocket_handle({text, Id}, Req, State) ->
    Data = epl_st:node_info(Id),
    {reply, {text, Data}, Req, State};
websocket_handle(Data, _Req, _State) ->
    exit({not_implemented, Data}).

websocket_info({data, Data}, Req, State) ->
    {reply, {text, Data}, Req, State};
websocket_info(Info, _Req, _State) ->
    exit({not_implemented, Info}).

websocket_terminate(_Reason, _Req, _State) ->
    epl_st:unsubscribe(),
    ok.
