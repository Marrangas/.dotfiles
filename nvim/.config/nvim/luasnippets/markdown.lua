---@diagnostic disable: unused-local
require('luasnip.session.snippet_collection').clear_snippets 'markdown'

local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require 'luasnip.util.events'
local ai = require 'luasnip.nodes.absolute_indexer'
local extras = require 'luasnip.extras'
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local conds = require 'luasnip.extras.expand_conditions'
local postfix = require('luasnip.extras.postfix').postfix
local types = require 'luasnip.util.types'
local parse = require('luasnip.util.parser').parse_snippet
local ms = ls.multi_snippet
local k = require('luasnip.nodes.key_indexer').new_key

-- Function to get formatted string: YYYY-wWW (e.g., 2026-w32)
local function get_year_week() return os.date '%Y-w%W' end

-- Helper to define a choice option with selection highlight and custom label
local function opt(value, label)
    local node = t(value, {
        node_ext_opts = {
            active = {
                virt_text = { { label, 'Comment' } },
            },
        },
    })
    node.label = label
    return node
end

-- local wiki_utils = require 'util.wiki'
local function get_wiki_affections()
    local choices = {
        opt('afectos incluidos', 'emociones y sentimientos'),
        opt('otros', 'factores no clasificados'),
    }

    -- local ok_notes, notes = pcall(wiki_utils.get_notes_by_tag, 'afectos')
    -- if ok_notes and notes then
    --     for _, note in ipairs(notes) do
    --         table.insert(choices, opt(note, 'Nota etiquetada con afectos'))
    --     end
    -- end

    -- 2. Query for all subtags of "afectos"
    -- local ok_subtags, subtags = pcall(wiki_completions.get_subtags, 'afectos')
    -- if ok_subtags and subtags then
    --     for _, subtag in ipairs(subtags) do
    --         table.insert(choices, opt(subtag, 'Subetiqueta de afectos'))
    --     end
    -- end

    return choices
end

-- TODO: salud make the list of things you want to insert in your routine
-- TODO: personal
-- TODO: profesional
-- TODO: social
ls.add_snippets('markdown', {
    s(
        'pkm-table',
        fmt(
            [=[
| [[{week}]] | salud            | personal             | profesional      | social                         |
| ------------ | ---------------- | -------------------- | ---------------- | ------------------------------ |
| cuerpo       | {c1} | {c2} | {c3} | {c4} |
| mente        | {c5} | {c6} | {c7} | {c8} |
| espiritu     | {c9} | {c10} | {c11} | {c12} |
]=],
            {
                week = f(get_year_week, {}),
                c1 = i(1, '[*deporte/reto*]'),
                c2 = i(2, '[*proyecto*]'),
                c3 = i(3, '[*empresa*]'),
                c4 = i(4, '[*cuidar y estar ahí*]'),
                c5 = i(5, '[*sentir*]'),
                c6 = i(6, '[*cultivar cultura*]'),
                c7 = i(7, '[*aprender*]'),
                c8 = i(8, '[*crecer y conectar*]'),
                c9 = i(9, '[*más allá*]'),
                c10 = i(10, '[*sin confort*]'),
                c11 = i(11, '[*una obsesión*]'),
                c12 = i(12, '[*yo y el mundo, y biceversa*]'),
            }
        )
    ),

    s('wiki-week', {
        f(function()
            local current_date = os.date '*t'
            current_date.hour = 12
            current_date.min = 0
            current_date.sec = 0
            local noon_today = os.time(current_date)

            local current_wday = os.date('*t', noon_today).wday
            local days_from_monday = (current_wday + 5) % 7
            local monday_noon = noon_today - (days_from_monday * 86400)

            local week_str = os.date('%Y-w%W', noon_today)

            local day_prefixes = { 'L', 'M', 'X', 'J', 'V', 'S', 'D' }
            local lines = {}
            table.insert(lines, '- [[' .. week_str .. ']]')
            for idx = 0, 6 do
                local day_time = monday_noon + (idx * 86400)
                local formatted_date = os.date('%Y-%m-%d', day_time)
                table.insert(lines, '- ' .. day_prefixes[idx + 1] .. ' [[' .. formatted_date .. ']]')
            end
            return lines
        end, {}),
    }),

    s(
        'wiki-arg',
        -- TODO: how to filter the results so it is possible to aggregate this themes into
        -- something to convert it into a loop that is useful (in vim obsidian or whatever the fuck)
        fmt(
            [=[
- razon:: {c1}
- autoridad:: {c2}
- pragmatismo:: {c3}
- axiologia:: {c4}
- experiencias:: {c5}
- emociones:: {c6}
]=],
            {
                c1 = c(1, {
                    opt('induccion', 'generalizar de lo particular'),
                    opt('deduccion', 'derivar por logica formal'),
                    opt('abduccion', 'hipotesis de la mejor explicacion'),
                }),
                c2 = c(2, {
                    opt('referentes', 'expertos, citas o bibliografia'),
                    opt('antireferentes', 'puntos a refutar o evitar'),
                }),
                c3 = c(3, {
                    opt('consecuencias', 'analisis pragmático de resultados'),
                    opt('utilidad', 'valor practico o aplicabilidad'),
                }),
                c4 = c(4, {
                    opt('valores', 'principios rectores'),
                    opt('moral', 'normas sociales o compartidas'),
                    opt('etica', 'filosofia de la accion justa'),
                }),
                c5 = c(5, {
                    opt('la vida propia', 'experiencias vividas'),
                    opt('agena', 'testimonios, biografias u otros'),
                }),
                c6 = d(
                    6,
                    function()
                        return sn(nil, {
                            c(1, get_wiki_affections()),
                        })
                    end,
                    {}
                ),
            }
        )
    ),

    s('wiki-stat', {
        c(1, {
            opt('status/queue', 'Pending review / Next in line'),
            opt('status/efforts', 'Pending review / Next in line'),
            opt('status/active', 'Currently active / In progress'),
            opt('status/archive', 'Completed task / Archived'),
            opt('type/concept', 'Atomic conceptual note'),
            opt('type/project', 'High-level active project log'),
            opt('type/person', 'Contact or referent directory'),
        }),
    }),
})

-- local fmt = require("luasnip.extras.fmt").fmt
--
-- return {
--
--   ls.snippet({trig="l", descr="Insert a link"},
--     fmt(
--       [[
--       [{}]({})
--       ]],
--       { i(1, "text"), i(2, "url"), }
--     )
--   ),
--
--   ls.snippet({trig="img", descr="Insert an image"},
--     fmt(
--       [[
--       ![{}]({})
--       ]],
--       { i(1, "alt text"), i(2, "src")}
--     )
--   ),
--
-- }
