%% -*- tab-width: 4;erlang-indent-level: 4;indent-tabs-mode: nil -*-
%% ex: ts=4 sw=4 et
%% ----------------------------------------------------------------------------
%%
%% Copyright (c) 2000 - 2012 Tim Watson.
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
%% IN THE SOFTWARE.
%% ----------------------------------------------------------------------------
%% @doc Default backend that simply calls into error logger.
%% ----------------------------------------------------------------------------
-module(sasl_logging_backend).

-behaviour(logging_backend).

-export([levels/0]).
-export([init/1]).
-export([log/4]).

levels() ->
    [debug, info, notice, warning, error].

init(_) -> ignore.

log(notice, Meta, Fmt, Data) ->
    log(info_msg, format(Meta, "[NOTICE] " ++ Fmt, Data));
log(Level, Meta, Fmt, Data) when Level =:= debug orelse
                                 Level =:= info ->
    log(info_msg, format(Meta, Fmt, Data));
log(warning, Meta, Fmt, Data) ->
    log(warning_msg, format(Meta, Fmt, Data));
log(_Level, Meta, Fmt, Data) ->
    log(error_msg, format(Meta, Fmt, Data)).

format([], Fmt, Data) ->
    {Fmt, Data};
format(Meta, Fmt, Data) ->
    {Fmt2, Extra} = lists:foldl(fun meta_format/2, {Fmt, []}, Meta),
    {Fmt2, lists:reverse(Extra) ++ Data}.

meta_format(pid, {Fmt, Data}) ->
    {"[~p] " ++ Fmt, [self()|Data]};
meta_format(node, {Fmt, Data}) ->
    {"[~p] " ++ Fmt, [node()|Data]};
meta_format({Tag, Value}, {Fmt, Data}) when is_atom(Tag) ->
    {"[~s: ~p] " ++ Fmt, [Value, Tag|Data]};
meta_format(Meta, {Fmt, Data}) ->
    {"[~p] " ++ Fmt, [Meta|Data]}.

log(LogFun, {Fmt, Args}) ->
    apply(error_logger, LogFun, [Fmt, Args]).
