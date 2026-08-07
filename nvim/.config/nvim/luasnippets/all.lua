---@diagnostic disable: unused-local
require("luasnip.session.snippet_collection").clear_snippets("all")

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- Helper to get comment string for the current filetype
local function get_comment()
    local cs = vim.bo.commentstring
    if cs == "" then
        return "//"
    end
    return cs:gsub("%%s", ""):match("^%s*(.-)%s*$") or "//"
end

local function get_uuid()
    local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    return string.gsub(template, "[xy]", function(c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
    end)
end

ls.add_snippets("all", {
    s(
        "mrgsheader",
        fmt(
            [=[
{comment} @signature:  {uuid}
{comment} @filename:   {filename}
{comment} @date:       {date}
{comment} @author:     Marrangas
{comment}
{comment} @overview:   {overview}
{comment} @component:  {component}
{comment} @package:    {package}
{comment} @type:       {type}
{comment}
{comment} -------------------------------------------------------------------------------
{comment} @relations:
{comment} - IMPORTS: {imports}
{comment} - USED_BY: {used_by}
{comment} - CONSUMES_STATE: {consumes_state}
{comment} - EMITS_EVENTS: {emits_events}
{comment}
{comment} @contract:
{comment} - INPUTS: {inputs}
{comment} - OUTPUTS: {outputs}
{comment} - INVARIANTS: {invariants}
{comment}
{comment} @ai-context:
{comment} {ai_context}
]=],
            {
                comment = f(function()
                    return get_comment()
                end),
                uuid = f(function()
                    return get_uuid()
                end),
                filename = f(function()
                    return vim.fn.expand("%:t")
                end),
                date = f(function()
                    return os.date("%Y-%m-%d")
                end),
                overview = i(1, "[Describe the primary responsibility]"),
                component = i(2, "[Component name or file identifier]"),
                package = i(3, "[Module or Directory Path]"),
                type = i(4, "[UI:Atom | UI:Molecule | UI:Organism | Service | Hook | Utility | State:Store]"),
                imports = i(5, "[Comma-separated list of child/dep modules directly imported]"),
                used_by = i(6, "[Known parent components or services consuming this]"),
                consumes_state = i(7, "[Contexts, Redux/Zustand stores, or global state objects read]"),
                emits_events = i(8, "[Custom DOM events, callbacks, or message queue events fired]"),
                inputs = i(9, "{ [Key Props/Params]: [Types/Typescript interfaces] }"),
                outputs = i(10, "[Return types or JSX structure]"),
                invariants = i(11, "[Critical rules: e.g., 'Must be rendered within ThemeProvider']"),
                ai_context = i(
                    12,
                    "[Direct instructions for LLM codegen: performance considerations, re-render traps, usage guidelines]"
                ),
            }
        )
    ),
})
