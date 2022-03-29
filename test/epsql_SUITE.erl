-module(epsql_SUITE).

-include_lib("common_test/include/ct.hrl").

-compile(export_all).

-define(PROG, "epsql").
-define(TIMEOUT, 1000).

-define(DUMP, ?MIN_IMPORTANCE).
-define(DEBUG, ?LOW_IMPORTANCE).
-define(INFO, ?STD_IMPORTANCE).
-define(WARN, ?HI_IMPORTANCE).
-define(ERROR, ?MAX_IMPORTANCE).

all() ->
	[
	test_usage
	].

exec(Args) ->
	Out = str:trim(list_to_binary(os:cmd(["../../bin/" ?PROG " ", Args]))),
	ct:pal(?DEBUG, "out ~s args: ~p", [Out, Args]),
	str:trim(Out).

test_usage(_Config) ->
	Out = exec("-?"),
	0 = str:str(Out, <<"unknown option -?">>),
	-1 /= str:str(Out, <<"usage: ", ?PROG>>).
