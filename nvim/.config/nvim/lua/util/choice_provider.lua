local luasnip = require('luasnip')

local source = {}

function source.new(opts)
  return setmetatable({ opts = opts }, { __index = source })
end

function source:enabled()
  return luasnip.choice_active()
end

function source:get_trigger_characters()
  return {}
end

function source:get_completions(context, callback)
  if not luasnip.choice_active() then
    callback()
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local active_choice_node = luasnip.session.active_choice_nodes[bufnr]
  if not active_choice_node then
    -- Fallback: traverse up from current node
    local node = luasnip.session.current_nodes[bufnr]
    while node do
      if node.type == 'choiceNode' then
        active_choice_node = node
        break
      end
      node = node.parent
    end
  end

  if not active_choice_node then
    callback()
    return
  end

  -- Determine the current word under the cursor to replace it correctly
  local col = context.cursor[2]
  local line = context.line
  local word = line:sub(1, col):match("[%w_/-]*$") or ""

  local items = {}
  for i, choice in ipairs(active_choice_node.choices) do
    -- Get the raw docstring representation of the choice node
    local docstring = choice:get_docstring()
    local raw_value = table.concat(docstring, ' ')

    -- Clean any LSP/luasnip tabstop template wrappers (e.g. ${1:status/queue}) down to plain text
    local clean_value = raw_value
    clean_value = clean_value:gsub("%$%{%d+:", "")
    clean_value = clean_value:gsub("%$[%d+]", "")
    clean_value = clean_value:gsub("%${", "")
    clean_value = clean_value:gsub("}", "")
    clean_value = clean_value:gsub("%$", "")

    if clean_value == '' then
      clean_value = 'Choice ' .. i
    end

    -- Get the rich description directly from the custom .label property attached to the choice node
    local desc = choice.label or ""

    table.insert(items, {
      label = clean_value, -- Displays the clean value natively
      detail = desc,       -- Displays the full description next to the option like LSP keywords
      labelDetails = {
        detail = desc ~= "" and ('  (' .. desc .. ')') or "", -- Appends directly after the label (displayed by default in blink.cmp!)
        description = desc,             -- Natively maps to blink.cmp's label_description column on the right
      },
      kind = require('blink.cmp.types').CompletionItemKind.Value,
      -- Set insertText to empty to let LuaSnip handle replacement cleanly in execute() without conflicts!
      insertText = "",
      textEdit = {
        newText = "",
        range = {
          start = { line = context.cursor[1] - 1, character = context.cursor[2] },
          ['end'] = { line = context.cursor[1] - 1, character = context.cursor[2] },
        },
      },
      data = {
        index = i,
      },
    })
  end

  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items,
  })
end

function source:execute(context, item, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local active_choice_node = luasnip.session.active_choice_nodes[bufnr]
  if not active_choice_node then
    local node = luasnip.session.current_nodes[bufnr]
    while node do
      if node.type == 'choiceNode' then
        active_choice_node = node
        break
      end
      node = node.parent
    end
  end

  local current_node = luasnip.session.current_nodes[bufnr]

  if active_choice_node and current_node then
    -- Find the chosen index either from custom data or by matching the label
    local selected_idx = nil
    if item.data and item.data.index then
      selected_idx = item.data.index
    else
      for idx, choice in ipairs(active_choice_node.choices) do
        local docstring = choice:get_docstring()
        local raw_val = table.concat(docstring, ' ')
        local clean_val = raw_val:gsub("%$%{%d+:", ""):gsub("%$[%d+]", ""):gsub("%${", ""):gsub("}", ""):gsub("%$", "")
        if clean_val == item.label then
          selected_idx = idx
          break
        end
      end
    end

    if selected_idx then
      local chosen_choice = active_choice_node.choices[selected_idx]
      -- set_choice returns the newly focused insertNode! We MUST assign it back to luasnip's session
      -- so the global cursor tracking remains completely healthy and Tab jumping works flawlessly!
      local new_active_node = active_choice_node:set_choice(chosen_choice, current_node)
      if new_active_node then
        luasnip.session.current_nodes[bufnr] = new_active_node
      end
      luasnip.active_update_dependents()
    end
  end
  callback()
end

return source
