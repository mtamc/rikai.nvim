local M = {}
local dict = require('rikai.dict')

local config = {
  max_entries = 7,
  select_match = true,
  float_opts = {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = 60,
    height = 20,
    style = 'minimal',
    border = 'rounded',
  },
}

local function ensure_initialized()
  if not dict then
    error("Dictionary module failed to load")
  end

  -- Initialize dictionary if needed
  local ok, err = dict.init()
  if not ok then
    vim.notify("Failed to initialize Rikai dictionary: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  return true
end

local function get_text_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- Lua is 1-indexed
  return line:sub(col)
end

local function select_text(text)
  if not text or text == "" then
    return
  end

  local char_count = vim.fn.strchars(text)
  if char_count > 0 then
    vim.cmd('normal! v' .. (char_count - 1) .. 'l')
  end
end

local function format_results(results)
  if not results or #results == 0 then
    return {"No results found"}
  end

  local lines = {}
  for i, entry in ipairs(results) do
    if entry.reading and entry.reading ~= "" then
      table.insert(lines, string.format("%d. %s [%s]", i, entry.word, entry.reading))
    else
      table.insert(lines, string.format("%d. %s", i, entry.word))
    end

    local defs = entry.definitions
    local max_width = config.float_opts.width - 3
    while #defs > 0 do
      if #defs <= max_width then
        table.insert(lines, "   " .. defs)
        break
      else
        local break_pos = max_width
        for j = max_width, 1, -1 do
          if defs:sub(j, j) == ' ' or defs:sub(j, j) == ';' then
            break_pos = j
            break
          end
        end
        table.insert(lines, "   " .. defs:sub(1, break_pos))
        defs = defs:sub(break_pos + 1)
      end
    end

    table.insert(lines, "")
  end

  return lines
end

local function show_floating_window(lines, defer_autocmds)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  local height = math.min(#lines, config.float_opts.height)
  local opts = vim.tbl_extend('force', config.float_opts, {height = height})

  local win = vim.api.nvim_open_win(buf, false, opts)

  vim.api.nvim_win_set_option(win, 'wrap', true)
  vim.api.nvim_win_set_option(win, 'cursorline', false)

  local function close_window()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function setup_autocmds()
    -- Set up autocommands to close window
    -- Don't close immediately if we're in visual mode (for select_match feature)
    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
      buffer = vim.api.nvim_get_current_buf(),
      callback = function()
        -- Check if we're in visual mode
        local mode = vim.api.nvim_get_mode().mode
        if mode:match('^[vV\x16]') then
          return false
        end
        close_window()
        return true
      end
    })

    vim.api.nvim_create_autocmd({'BufLeave', 'InsertEnter'}, {
      buffer = vim.api.nvim_get_current_buf(),
      once = true,
      callback = close_window
    })

    -- Also close on any key in the floating window
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
      callback = close_window,
      noremap = true,
      silent = true
    })
  end

  if defer_autocmds then
    vim.schedule(setup_autocmds)
  else
    setup_autocmds()
  end
end

function M.lookup()
  if not ensure_initialized() then
    return
  end

  local text = get_text_at_cursor()
  if not text or text == "" then
    vim.notify("No text at cursor", vim.log.levels.WARN)
    return
  end

  local results = dict.lookup(text, config.max_entries)

  if not results or #results == 0 then
    vim.notify("No dictionary entries found", vim.log.levels.INFO)
    return
  end

  local lines = format_results(results)

  local defer = config.select_match and results[1] ~= nil
  show_floating_window(lines, defer)

  if config.select_match and results[1] then
    vim.schedule(function()
      select_text(results[1].word)
    end)
  end
end

function M.setup(opts)
  opts = opts or {}

  if opts.max_entries then
    config.max_entries = opts.max_entries
  end
  if opts.select_match ~= nil then
    config.select_match = opts.select_match
  end
  if opts.float_opts then
    config.float_opts = vim.tbl_extend('force', config.float_opts, opts.float_opts)
  end

  vim.api.nvim_create_user_command('Rikai', function()
    M.lookup()
  end, {
    desc = 'Look up Japanese word at cursor'
  })

  -- Create default keymapping
  vim.keymap.set('n', '<leader>rk', M.lookup, {
    desc = 'Rikai: Look up Japanese word',
    noremap = true,
    silent = true
  })
end

return M
