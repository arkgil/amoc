-module(dialyzer_SUITE).
-include_lib("common_test/include/ct.hrl").

-compile(export_all).

suite() -> [].

groups() -> [].

all() ->
    [run_dialyzer].

init_per_suite(Config) ->
    ok = filelib:ensure_dir(filename:join(dialyzer_dir(), ".file")),
    Config.

end_per_suite(_Config) ->
    ok.

init_per_group(_group, Config) ->
    Config.

end_per_group(_group, Config) ->
    Config.

init_per_testcase(_TestCase, Config) ->
    Config.

end_per_testcase(_TestCase, Config) ->
    Config.

run_dialyzer(_Config) ->
    build_or_check_plts(),
    dialyze().

dialyze() ->
    ct:pal("Running analysis"),
    run([{analysis_type, succ_typings},
         {plts, [file("erlang.plt"), file("deps.plt"), file("amoc.plt")]},
         {files_rec, [ebin_dir()]},
         {check_plt, false},
         {get_warnings, true},
         {output_file, file("error.log")}]).

build_or_check_plts() ->
    build_or_check_plt(file("erlang.plt"),
                       [{apps, [kernel, stdlib, erts, crypto, compiler]},
                        {output_file, file("erlang.log")}]),
    build_or_check_plt(file("deps.plt"),
                       [{files_rec, deps_dirs()},
                        {output_file, file("deps.log")}]),
    build_or_check_plt(file("amoc.plt"),
                       [{files_rec, [ebin_dir()]},
                        {output_file, file("amoc.log")}]),
    ok.

build_or_check_plt(File, Opts) ->
    case filelib:is_file(File) of
        false ->
            ct:pal("Building plt ~p", [File]),
            run([{output_plt, File}, {analysis_type, plt_build} | Opts]);
        true ->
            ct:pal("Checking plt ~p", [File]),
            run([{plts, [File]}, {analysis_type, plt_check} | Opts])
    end.

run(Opts) ->
    case dialyzer:run(Opts) of
        [] ->
            ok;
        Result ->
            ct:pal("Dialyzer step finished with errors:~n~p", [Result]),
            ct:fail({dialyzer_returned_errors, Result})
    end.

file(Filename) ->
    filename:join(dialyzer_dir(), Filename).

deps_dirs() ->
    filelib:wildcard(filename:join([amoc_dir(), "deps", "*", "ebin"])).

dialyzer_dir() ->
    filename:join([amoc_dir(), "dialyzer"]).

ebin_dir() ->
    filename:join([amoc_dir(), "ebin"]).

amoc_dir() ->
    code:lib_dir(amoc).
