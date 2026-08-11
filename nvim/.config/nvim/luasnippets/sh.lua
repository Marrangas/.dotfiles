---@diagnostic disable: unused-local
require('luasnip.session.snippet_collection').clear_snippets 'sh'

local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets('sh', {
    s('echo', fmt('echo "{msg}"', { msg = i(1, 'message') })),
    s('read', fmt('read -r {var}', { var = i(1, 'VAR') })),

    s(
        'if',
        fmt(
            [=[
if [[ {cond} ]]; then
	{body}
fi
]=],
            {
                cond = i(1, 'condition'),
                body = i(2, ''),
            }
        )
    ),

    s(
        'elseif',
        fmt(
            [=[
elif [[ {cond} ]]; then
	{body}
]=],
            {
                cond = i(1, 'condition'),
                body = i(2, ''),
            }
        )
    ),

    s(
        'else',
        fmt(
            [=[
else
	{body}
]=],
            {
                body = i(1, 'command'),
            }
        )
    ),

    s(
        'for_in',
        fmt(
            [=[
for {var} in {list}
do
	echo "${var_echo}"
done
]=],
            {
                var = i(1, 'VAR'),
                list = i(2, 'LIST'),
                var_echo = require('luasnip.extras').rep(1),
            }
        )
    ),

    s(
        'for_i',
        fmt(
            [=[
for (({index} = 0; {index_rep} < {max}; {index_rep2}++)); do
	echo "${index_rep3}"
done
]=],
            {
                index = i(1, 'i'),
                max = i(2, '10'),
                index_rep = require('luasnip.extras').rep(1),
                index_rep2 = require('luasnip.extras').rep(1),
                index_rep3 = require('luasnip.extras').rep(1),
            }
        )
    ),

    s(
        'while',
        fmt(
            [=[
while [[ {cond} ]]; do
	{body}
done
]=],
            {
                cond = i(1, 'condition'),
                body = i(2, ''),
            }
        )
    ),
    s(
        'until',
        fmt(
            [=[
until [[ {cond} ]]; do
	{body}
done
]=],
            {
                cond = i(1, 'condition'),
                body = i(2, ''),
            }
        )
    ),

    s(
        'function',
        fmt(
            [=[
{name} () {{
	{body}
}}
]=],
            {
                name = i(1, 'name'),
                body = i(2, ''),
            }
        )
    ),

    s(
        'case',
        fmt(
            [=[
case "${var}" in
	{opt1}) echo 1
	;;
	{opt2}) echo 2 or 3
	;;
	*) echo default
	;;
esac
]=],
            {
                var = i(1, 'VAR'),
                opt1 = i(2, '1'),
                opt2 = i(3, '2|3'),
            }
        )
    ),

    s('break', fmt('break {val}', { val = i(1, '') })),

    s('expr', fmt('expr {val}', { val = i(1, '1 + 1') })),
})
