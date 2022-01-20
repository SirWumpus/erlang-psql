%%#!/usr/bin/env escript

-module(epsql).
-export([main/1]).

-include_lib("epgsql/include/epgsql.hrl").

-type io_input() :: standard_io | file:io_device().
-type io_data()  :: {ok, string()} | {error, any()} | eof.

-spec usage() -> no_return().
usage() ->
	io:format("usage: epsql [-v][-h host][-p port][-t ms][-P pass][-U user] [database]~n~n"),
	io:format("-h host\t\thost to connect to; default \"127.0.0.1\"~n"),
	io:format("-p port\t\tport number to connect to; default \"5432\"~n"),
	io:format("-t ms\t\tconnection timeout in milliseconds; default \"5000\"~n"),
	io:format("-P pass\t\tuser password~n"),
	io:format("-U user\t\tuser to connect as; default \"~s\"~n", [os:getenv("USER", "")]),
	io:format("-v\t\tverbose output~n"),
	halt(2).

-spec main([string()]) -> ok.
main(Args) ->
	case opts:to_map(Args, [
		{ $h, param, hostname },
		{ $p, param, port     },
		{ $t, param, timeout  },
		{ $P, param, password },
		{ $U, param, username },
		{ $v, flag,  verbose  }
	]) of
	{error, Reason, Opt} ->
		io:format("~s -~c~n", [Reason, Opt]),
		usage();
	{ok, _Options, ArgsN} ->
		process(ArgsN)
	end.

-spec process(egetopt:args() | [undefined]) -> ok.
process([]) ->
	process([undefined]);
process([Database | _Args]) ->
	PgOpts0 = #{
		host => opts:get(hostname, "127.0.0.1"),
		port => list_to_integer(opts:get(portnum, "5432")),
		username => opts:get(username, os:getenv("USER")),
		timeout => list_to_integer(opts:get(timeout, "5000"))
	},
	PgOpts1 = map_set(PgOpts0, password, opts:get(password)),
	PgOpts2 = map_set(PgOpts1, database, Database),
	case epgsql:connect(PgOpts2) of
	{error, Reason} ->
		io:format(standard_error, "epsql: ~p~n", [Reason]);
	{ok, C} ->
		psql(C, standard_io),
		epgsql:close(C)
	end.

-spec map_set(map(), atom(), egetopt:optarg()) -> map().
map_set(Map0, _Key, undefined) ->
	Map0;
map_set(Map0, Key, Value) ->
	maps:put(Key, Value, Map0).

-spec psql(epgsql:connection(), io_input()) -> ok.
psql(C, Fp) ->
	% Read an SQL statement.
	case read_sql(Fp) of
	{ok, Sql} ->
		case epgsql:equery(C, Sql) of
		{error, Reason} ->
			io:format(standard_error, "epsql: ~s~n", [Reason#error.message]);
		Result ->
			result(Result, opts:get(verbose, false)),
			psql(C, Fp)
		end;
	{error, Reason} ->
		io:format(standard_error, "epsql: ~p~n", [Reason]);
	eof ->
		ok
	end.

-spec read_sql(io_input()) -> io_data().
read_sql(Fp) ->
	case file:read(Fp, 1) of
	{ok, "\\"} ->
		cmd_to_sql(read_delim(Fp, $\n, "\\"));
	{ok, Ch} ->
		read_delim(Fp, $;, Ch);
	eof ->
		eof;
	Other ->
		Other
	end.

-spec read_delim(io_input(), char(), string()) -> io_data().
read_delim(Fp, Delim, Acc) ->
	case file:read(Fp, 1) of
	{ok, [Delim]} ->
		{ok, lists:reverse(Acc)};
	{ok, [Ch]} ->
		read_delim(Fp, Delim, [Ch | Acc]);
	eof ->
		case lists:reverse(Acc) of
		[] ->
			eof;
		String ->
			{ok, String}
		end;
	Other ->
		Other
	end.

-spec result(tuple(), boolean()) -> ok.
result({ok, _Count}, false) ->
	% INSERT / UPDATE / DELETE
	ok;
result({ok, Count}, true) ->
	% INSERT / UPDATE / DELETE
	io:format("rows ~p~n", [Count]);
result({ok, _Cols, Rows}, _) when length(Rows) == 0 ->
	% SELECT
	ok;
result({ok, Cols, Rows}, _) ->
	% SELECT
	headings(Cols),
	ruler(Cols),
	rows(Rows),
	io:format("(~B rows)~n~n", [length(Rows)]);
result({ok, _Count, Cols, Rows}, _) ->
	% INSERT...RETURNING...
	headings(Cols),
	ruler(Cols),
	rows(Rows),
	io:format("(~B rows)~n~n", [length(Rows)]).

-spec rows([tuple()]) -> ok.
rows([]) ->
	ok;
rows([Row | Rows]) ->
	cols(tuple_to_list(Row)),
	rows(Rows).

-spec comma_nl(non_neg_integer()) -> ok.
comma_nl(0) ->
	io:format("~n");
comma_nl(_) ->
	io:format(", ").

-spec cols([any()]) -> ok.
cols([]) ->
	ok;
cols([Col | Cols]) ->
	case Col of
	Bin when is_binary(Bin) ->
		io:format("\"~s\"", [Bin]);
	_ ->
		io:format("~p", [Col])
	end,
	comma_nl(length(Cols)),
	cols(Cols).

-spec headings([map()]) -> ok.
headings([]) ->
	ok;
headings([Col | Cols]) ->
	io:format("\"~s\"", [Col#column.name]),
	comma_nl(length(Cols)),
	headings(Cols).

-spec ruler([map()]) -> ok.
ruler([]) ->
	ok;
ruler([Col | Cols]) ->
	io:format("\"~*..-s\"", [byte_size(Col#column.name), ""]),
	comma_nl(length(Cols)),
	ruler(Cols).

-spec cmd_to_sql(Cmd :: string()) -> string().
cmd_to_sql({ok, Cmd}) ->
	cmd_to_sql(string:tokens(Cmd, " "));
cmd_to_sql(["\\q"]) ->
	eof;
cmd_to_sql(["\\l"]) ->
	{ok, "SELECT datname FROM pg_database;"};
cmd_to_sql(["\\dt"]) ->
	{ok, "SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';"};
cmd_to_sql(["\\d", Table]) ->
	{ok, "SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = '"++ Table ++"';"};
cmd_to_sql(Other) ->
	Other.
