-module(dummy_worker).

-export([initial_state/0, metrics/0, check_iterator/3,
         print/3, test_method/3, test_pre_hook/1, test_proplist/3, doubled_print_counter/0]).

-type state() :: string().

-spec initial_state() -> state().
initial_state() -> -1.

metrics() ->
    [{"print", counter, #{visibility => false, rps_visibility => true}},
     {"dummy", histogram, #{visibility => true}},
     {"derived", derived, #{resolver => doubled_print_counter, visibility => false}}].

doubled_print_counter() ->
    2 * mzb_metrics:get_value("print").

print(State, _Meta, Text) ->
    Start = os:timestamp(),
    _ = mzb_metrics:notify("print", 1),
    lager:info("Dummy print: ~p", [Text]),
    Finish = os:timestamp(),
    _ = mzb_metrics:notify({"dummy", histogram}, timer:now_diff(Finish, Start)),
    {nil, State}.

check_iterator(State, _Meta, Iterator) ->
    if Iterator /= State + 1 -> lager:info("Iterator problem, should be ~p instead of ~p", [State + 1, Iterator]);
        true -> ok end,
    {nil, Iterator}.

test_method(State, _Meta, Text) ->
    {nil, Text ++ State}.

test_pre_hook(Env) ->
    {ok, [{"foo", "bar"} | Env]}.

test_proplist(State, _Meta, Proplist) ->
    true = proplists:get_value(test, Proplist),
    {ok, State}.
