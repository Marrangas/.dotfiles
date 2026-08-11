-- nvim/lua/util/wiki_completions.lua
local M = {}

local cache_file = vim.fn.stdpath 'cache' .. '/wiki_metadata_cache.json'

local cache = {
    cwd = '',
    files = {}, -- map of file -> { keys = { "status" }, values = { status = { "draft" } } }
    last_scan = 0,
    keys = {}, -- aggregated list
    values = {}, -- aggregated map
}

-- Re-aggregates keys and values from cache.files into cache.keys and cache.values
local function aggregate_cache()
    local keys_set = {}
    local values_set = {}

    for _, file_data in pairs(cache.files) do
        if file_data.keys then
            for _, k in ipairs(file_data.keys) do
                keys_set[k] = true
            end
        end
        if file_data.values then
            for k, vals in pairs(file_data.values) do
                values_set[k] = values_set[k] or {}
                for _, v in ipairs(vals) do
                    values_set[k][v] = true
                end
            end
        end
    end

    cache.keys = {}
    for k, _ in pairs(keys_set) do
        table.insert(cache.keys, k)
    end
    table.sort(cache.keys)

    cache.values = {}
    for k, v_set in pairs(values_set) do
        cache.values[k] = {}
        for v, _ in pairs(v_set) do
            table.insert(cache.values[k], v)
        end
        table.sort(cache.values[k])
    end
end

-- Saves cache to disk
local function save_cache()
    local f = io.open(cache_file, 'w')
    if f then
        f:write(vim.json.encode {
            cwd = cache.cwd,
            files = cache.files,
            last_scan = cache.last_scan,
        })
        f:close()
    end
end

-- Loads cache from disk
local function load_cache()
    local f = io.open(cache_file, 'r')
    if f then
        local content = f:read '*a'
        f:close()
        local ok, data = pcall(vim.json.decode, content)
        if ok and data then
            -- Verify if the cached CWD matches the current working directory
            if data.cwd == vim.fn.getcwd() then
                cache.cwd = data.cwd or ''
                cache.files = data.files or {}
                cache.last_scan = data.last_scan or 0
                aggregate_cache()
                return true
            end
        end
    end
    return false
end

-- Parses a single file and extracts its keys and values
function M.parse_file(file)
    local keys_set = {}
    local values_set = {}
    local f = io.open(file, 'r')
    if not f then return nil end

    local in_frontmatter = false
    local lines_read = 0
    local current_key = nil

    for line in f:lines() do
        lines_read = lines_read + 1
        if lines_read > 50 then break end

        if line == '---' then
            if not in_frontmatter then
                in_frontmatter = true
            else
                break
            end
        elseif in_frontmatter then
            local key, val = line:match '^([%w_-]+)%s*:%s*(.*)$'
            if key then
                key = key:lower()
                keys_set[key] = true
                current_key = key

                val = val:gsub('^"%s*', ''):gsub('%s*"$', ''):gsub("^'%s*", ''):gsub("%s*'$", '')
                if val ~= '' then
                    if val:match '^%s*%[(.*)%]%s*$' then
                        local list_content = val:match '^%s*%[(.*)%]%s*$'
                        for item in list_content:gmatch '[^,%s]+' do
                            item = item:gsub('^"%s*', '')
                                :gsub('%s*"$', '')
                                :gsub("^'%s*", '')
                                :gsub("%s*'$", '')
                            if item ~= '' then
                                values_set[key] = values_set[key] or {}
                                values_set[key][item] = true
                            end
                        end
                    else
                        values_set[key] = values_set[key] or {}
                        values_set[key][val] = true
                    end
                end
            else
                local list_item = line:match '^%s*-%s*(.*)$'
                if list_item and current_key then
                    list_item = list_item
                        :gsub('^"%s*', '')
                        :gsub('%s*"$', '')
                        :gsub("^'%s*", '')
                        :gsub("%s*'$", '')
                    if list_item ~= '' then
                        values_set[current_key] = values_set[current_key] or {}
                        values_set[current_key][list_item] = true
                    end
                end
            end
        end
    end
    f:close()

    -- Format to lists
    local file_keys = {}
    for k, _ in pairs(keys_set) do
        table.insert(file_keys, k)
    end
    local file_values = {}
    for k, v_set in pairs(values_set) do
        file_values[k] = {}
        for v, _ in pairs(v_set) do
            table.insert(file_values[k], v)
        end
    end

    return { keys = file_keys, values = file_values }
end

-- Incremental update for a single file (called on BufWritePost)
function M.update_file_in_cache(file)
    local abs_path = vim.fn.fnamemodify(file, ':p')
    local data = M.parse_file(abs_path)
    if data then
        cache.files[abs_path] = data
        aggregate_cache()
        save_cache()
    end
end

-- Runs a full scan of the directory and writes cache to disk
function M.scan_vault()
    -- 1. Try to load from disk cache first if we haven't loaded it yet in this session
    if cache.last_scan == 0 then
        if load_cache() then
            -- If last scan is fresh (within 1 hour), we don't need to re-scan
            if os.time() - cache.last_scan < 3600 then return end
        end
    end

    -- 2. If already loaded and within 1 hour, skip
    local now = os.time()
    if cache.cwd == vim.fn.getcwd() and now - cache.last_scan < 3600 then return end

    -- 3. Perform a full scan
    cache.cwd = vim.fn.getcwd()
    cache.files = {}
    cache.last_scan = now

    local files = vim.fn.globpath(vim.fn.getcwd(), '**/*.md', true, true)
    local max_files = 500
    local scanned = 0

    for _, file in ipairs(files) do
        if scanned >= max_files then break end
        local abs_path = vim.fn.fnamemodify(file, ':p')
        local data = M.parse_file(abs_path)
        if data then
            cache.files[abs_path] = data
            scanned = scanned + 1
        end
    end

    aggregate_cache()
    save_cache()
end

-- Extracts all note wikilinks with a specific tag or subtag
function M.get_notes_by_tag(target_tag)
    if cache.last_scan == 0 then load_cache() end

    local notes = {}
    local seen = {}
    for abs_path, file_data in pairs(cache.files) do
        local note_name = vim.fn.fnamemodify(abs_path, ':t:r')
        if file_data.values then
            for _, tag_key in ipairs { 'tags', 'tag' } do
                local vals = file_data.values[tag_key]
                if vals then
                    for _, val in ipairs(vals) do
                        if val == target_tag or val:match('^' .. target_tag .. '/') then
                            local wikilink = '[[' .. note_name .. ']]'
                            if not seen[wikilink] then
                                seen[wikilink] = true
                                table.insert(notes, wikilink)
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(notes)
    return notes
end

-- Extracts all subtags belonging to a parent tag
function M.get_subtags(parent_tag)
    if cache.last_scan == 0 then load_cache() end

    local subtags = {}
    local seen = {}
    for _, file_data in pairs(cache.files) do
        if file_data.values then
            for _, tag_key in ipairs { 'tags', 'tag' } do
                local vals = file_data.values[tag_key]
                if vals then
                    for _, val in ipairs(vals) do
                        if val:match('^' .. parent_tag .. '/') then
                            if not seen[val] then
                                seen[val] = true
                                table.insert(subtags, val)
                            end
                        end
                    end
                end
            end
        end
    end
    table.sort(subtags)
    return subtags
end

-- Checks if the cursor is currently inside a YAML frontmatter block
local function is_in_frontmatter()
    local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_row, false)
    local dash_count = 0
    for _, line in ipairs(lines) do
        if line == '---' then dash_count = dash_count + 1 end
    end
    return dash_count == 1
end

-- Inspects the current line context to check if completing a key or a value
local function get_completion_context()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local before_cursor = line:sub(1, col)

    -- Case A: Colons exist before cursor -> Typing a value
    local colon_idx = before_cursor:find ':'
    if colon_idx then
        local key = before_cursor:sub(1, colon_idx - 1):match '^%s*([%w_-]+)'
        if key then return 'value', key:lower() end
    end

    -- Case B: Bullet point -> Scan upwards to find the parent key
    if before_cursor:match '^%s*-%s*' then
        local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
        for r = cursor_row - 1, 1, -1 do
            local l = vim.api.nvim_buf_get_lines(0, r - 1, r, false)[1]
            if l then
                local key = l:match '^([%w_-]+)%s*:'
                if key then return 'value', key:lower() end
                if l == '---' or (not l:match '^%s' and not l:match '^%s*-') then break end
            end
        end
    end

    -- Case C: On a new line -> Completing a key
    return 'key', nil
end

-- Register Autocommands for file saves
local wiki_group = vim.api.nvim_create_augroup('WikiMetadataAutocmds', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
    group = wiki_group,
    pattern = '*.md',
    callback = function(ev) M.update_file_in_cache(ev.match) end,
})

-- Warm the cache asynchronously 2 seconds after opening a markdown file
vim.api.nvim_create_autocmd('FileType', {
    group = wiki_group,
    pattern = 'markdown',
    callback = function() vim.defer_fn(M.scan_vault, 2000) end,
})

-- Nvim-Cmp Provider Interface
local source = {}

function source.new(opts)
    local self = setmetatable({}, { __index = source })
    return self
end

function source:complete(params, callback)
    if vim.bo.filetype ~= 'markdown' then
        callback { items = {} }
        return
    end

    if not is_in_frontmatter() then
        callback { items = {} }
        return
    end

    -- Ensure cache is loaded from disk if not yet loaded (takes < 2ms, zero typing lag)
    if cache.last_scan == 0 then load_cache() end

    local completion_items = {}
    local mode, key = get_completion_context()

    -- Requires nvim-cmp installed
    local cmp_ok, cmp = pcall(require, 'cmp')
    local kinds = cmp_ok and cmp.lsp.CompletionItemKind or {}

    if mode == 'key' then
        for _, k in ipairs(cache.keys) do
            table.insert(completion_items, {
                label = k .. ':',
                kind = kinds.Field,
                insertText = k .. ': ',
                detail = 'Frontmatter Key',
            })
        end
    elseif mode == 'value' and key and cache.values[key] then
        for _, val in ipairs(cache.values[key]) do
            table.insert(completion_items, {
                label = val,
                kind = kinds.Value,
                insertText = val,
                detail = 'Historical Value (for ' .. key .. ')',
            })
        end
    end

    callback {
        items = completion_items,
        isIncomplete = false,
    }
end

source.get_notes_by_tag = M.get_notes_by_tag
source.get_subtags = M.get_subtags

return source
