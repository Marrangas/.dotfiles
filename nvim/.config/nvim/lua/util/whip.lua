local wiki_base_dir = vim.fn.expand '~/Documents/wiki/atlas/'
local cache_base_dir = vim.fn.stdpath 'cache' .. '/whip/'

local function get_customer_context()
    local docs_base = vim.fn.expand '~/Documents'
    local path = vim.api.nvim_buf_get_name(0)

    -- Gracefully handle special buffers (NvimTree, terminal, etc.) or empty path
    if path == '' or vim.bo.buftype ~= '' then path = vim.fn.getcwd() end

    if path:find(docs_base, 1, true) ~= 1 then return 'mrgs' end

    -- Ensure we didn't just match a directory that starts with the same prefix (e.g., Documents_backup)
    if #path > #docs_base and path:sub(#docs_base + 1, #docs_base + 1) ~= '/' then return 'mrgs' end

    local rel_path = path:sub(#docs_base + 2)
    local first_folder = rel_path:match '^([^/]+)'

    if first_folder and first_folder ~= 'wiki' and first_folder ~= '' then return first_folder end

    return 'mrgs'
end

local function get_git_branch()
    if vim.fn.executable 'git' == 0 then return nil end
    local branch = vim.fn.system 'git rev-parse --abbrev-ref HEAD 2>/dev/null'
    if vim.v.shell_error ~= 0 or not branch or branch == '' then return nil end
    return vim.trim(branch)
end

local function parse_context()
    local branch = get_git_branch()
    if not branch then return nil end

    -- Robust JIRA ticket matching: scan for the last valid alphanumeric JIRA key pattern
    -- where the project key has at least 2 characters.
    local proj, num
    for p, n in branch:gmatch '([%a%d]+)%-(%d+)' do
        if #p >= 2 then
            proj, num = p, n
        end
    end

    if not proj or not num then return nil end

    local customer = get_customer_context()
    local ticket_key = (proj .. '-' .. num):lower()

    local target_dir = wiki_base_dir .. customer .. '/'
    local glob_pattern = string.format('%sz-task-*-%s-%s.md', target_dir, proj:lower(), num)
    local matches = vim.fn.glob(glob_pattern, false, true)

    if #matches == 0 then
        local fallback_glob = string.format('%sz-task-*-%s-%s.md', wiki_base_dir .. '**/', proj:lower(), num)
        matches = vim.fn.glob(fallback_glob, false, true)
    end

    return {
        customer = customer,
        ticket_key = ticket_key,
        wiki_path = #matches > 0 and matches[1] or nil,
    }
end

local M = {}

function M.open_wiki_note()
    local ctx = parse_context()
    if not ctx then
        vim.notify('[Whip] Could not resolve Git branch / Jira context.', vim.log.levels.WARN)
        return
    end

    if ctx.wiki_path and vim.fn.filereadable(ctx.wiki_path) == 1 then
        vim.cmd('edit ' .. vim.fn.fnameescape(ctx.wiki_path))
    else
        vim.notify('[Whip] No Wiki note found for ticket ' .. ctx.ticket_key .. ' in [' .. ctx.customer .. ']', vim.log.levels.WARN)
    end
end

--- Save Quickfix list under customer-specific cache
function M.save_quickfix()
    local ctx = parse_context()
    if not ctx then
        vim.notify('[Whip] Could not resolve Git branch / Jira context.', vim.log.levels.WARN)
        return
    end

    local qf = vim.fn.getqflist { items = 0 }
    local qf_items = qf.items
    if #qf_items == 0 then
        vim.notify('[Whip] Quickfix list is empty.', vim.log.levels.WARN)
        return
    end

    local persistent_items = {}
    for _, item in ipairs(qf_items) do
        local new_item = vim.deepcopy(item)
        if new_item.bufnr and new_item.bufnr > 0 then
            new_item.filename = vim.api.nvim_buf_get_name(new_item.bufnr)
            new_item.bufnr = nil
        end
        table.insert(persistent_items, new_item)
    end

    local cache_dir = string.format('%s%s/%s/', cache_base_dir, ctx.customer, ctx.ticket_key)
    if vim.fn.isdirectory(cache_dir) == 0 then
        local ok, err = pcall(vim.fn.mkdir, cache_dir, 'p')
        if not ok then
            vim.notify('[Whip] Failed to create cache directory: ' .. tostring(err), vim.log.levels.ERROR)
            return
        end
    end

    local qf_file = cache_dir .. 'quickfix.json'

    local function perform_save()
        local file, err = io.open(qf_file, 'w')
        if file then
            local ok, write_err = pcall(function()
                file:write(vim.json.encode(persistent_items))
                file:close()
            end)
            if ok then
                vim.notify(string.format('[Whip] Saved Quickfix [%s / %s]', ctx.customer, ctx.ticket_key), vim.log.levels.INFO)
            else
                vim.notify('[Whip] Failed to write cache file: ' .. tostring(write_err), vim.log.levels.ERROR)
            end
        else
            vim.notify('[Whip] Failed to open cache file: ' .. tostring(err), vim.log.levels.ERROR)
        end
    end

    if vim.fn.filereadable(qf_file) == 1 then
        vim.ui.select({ 'Yes', 'No' }, {
            prompt = string.format('Cache file for %s exists. Overwrite?', ctx.ticket_key),
        }, function(choice)
            if choice == 'Yes' then
                perform_save()
            else
                vim.notify('[Whip] Save aborted.', vim.log.levels.INFO)
            end
        end)
    else
        perform_save()
    end
end

function M.load_quickfix()
    local ctx = parse_context()
    if not ctx then
        vim.notify('[Whip] Could not resolve Git branch / Jira context.', vim.log.levels.WARN)
        return
    end

    local qf_file = string.format('%s%s/%s/quickfix.json', cache_base_dir, ctx.customer, ctx.ticket_key)
    local file = io.open(qf_file, 'r')

    if not file then
        qf_file = string.format('%s%s/quickfix.json', cache_base_dir, ctx.ticket_key)
        file = io.open(qf_file, 'r')
    end

    if not file then
        vim.notify('[Whip] No quickfix cache found for ticket ' .. ctx.ticket_key, vim.log.levels.WARN)
        return
    end

    local content, read_err = file:read '*a'
    file:close()

    if not content or content == '' then
        vim.notify('[Whip] Quickfix cache file is empty. (' .. tostring(read_err) .. ')', vim.log.levels.WARN)
        return
    end

    local status, items = pcall(vim.json.decode, content)
    if not status or type(items) ~= 'table' then
        vim.notify('[Whip] Failed to decode quickfix JSON: ' .. tostring(items), vim.log.levels.ERROR)
        return
    end

    vim.fn.setqflist({}, 'r', {
        title = string.format('Jira QF [%s]: %s', ctx.customer, ctx.ticket_key),
        items = items,
    })
    vim.cmd 'copen'
    vim.notify(string.format('[Whip] Loaded Quickfix [%s / %s]', ctx.customer, ctx.ticket_key), vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>wo', M.open_wiki_note, { desc = '[Whip] [O]pen note' })
vim.keymap.set('n', '<leader>ww', M.save_quickfix, { desc = '[Whip] [w]rite quickfix' })
vim.keymap.set('n', '<leader>wl', M.load_quickfix, { desc = '[Whip] [L]oad quickfix' })

vim.api.nvim_create_user_command('Whip', function(opts)
    local subcmd = opts.args
    if subcmd == 'open' then
        M.open_wiki_note()
    elseif subcmd == 'save' then
        M.save_quickfix()
    elseif subcmd == 'load' then
        M.load_quickfix()
    else
        vim.notify("[Whip] Unknown subcommand: '" .. subcmd .. "'. Valid options: open, save, load", vim.log.levels.ERROR)
    end
end, {
    nargs = 1,
    complete = function(ArgLead)
        local subcmds = { 'open', 'save', 'load' }
        return vim.tbl_filter(function(cmd) return cmd:find(ArgLead, 1, true) == 1 end, subcmds)
    end,
    desc = 'Whip integration commands (open, save, load)',
})

return M
