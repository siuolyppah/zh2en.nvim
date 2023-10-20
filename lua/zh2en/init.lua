local M = {}

local function tbl_length(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

local function selection_area_pos()
  -- this will exit visual mode
  -- use 'gv' to reselect the text
  local _, csrow, cscol, cerow, cecol
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "" then
    -- if we are in visual mode use the live position
    _, csrow, cscol, _ = unpack(vim.fn.getpos("."))
    _, cerow, cecol, _ = unpack(vim.fn.getpos("v"))
    if mode == "V" then
      -- visual line doesn't provide columns
      cscol, cecol = 0, 999
    end
    -- exit visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  else
    -- otherwise, use the last known visual position
    _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
    _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
  end
  -- swap vars if needed
  if cerow < csrow then
    csrow, cerow = cerow, csrow
  end
  if cecol < cscol then
    cscol, cecol = cecol, cscol
  end

  return csrow, cscol, cerow, cecol
end

local function get_visual_selection()
  local csrow, cscol, cerow, cecol = selection_area_pos()

  local lines = vim.fn.getline(csrow, cerow)
  -- local n = cerow-csrow+1
  local n = tbl_length(lines)
  if n <= 0 then
    return ""
  end
  lines[n] = string.sub(lines[n], 1, cecol)
  lines[1] = string.sub(lines[1], cscol)
  return table.concat(lines, "\n")
end

--- replace current selection. must be one line.
--- @param to_replace string
local function replace_selection(to_replace)
  local csrow, cscol, cerow, cecol = selection_area_pos()

  if csrow ~= cerow then
    require("zh2en.notify").error("the selection must be only one line")
    return
  end
  local origin_line_begin = string.sub(vim.fn.getline(csrow), 1, cscol - 1)
  local origin_line_end = string.sub(vim.fn.getline(cerow), cecol + 1)

  local line_new_content = origin_line_begin .. to_replace .. origin_line_end
  vim.fn.setline(csrow, line_new_content)

  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_col = string.len(origin_line_begin .. to_replace) - 1

  vim.api.nvim_win_set_cursor(0, { cursor_row, cursor_col })
end

local function translate(input)
  return require("zh2en.rpc").rpc_translate(input)
end

local function translate_current_selection()
  local selection = get_visual_selection()
  local translate_output = translate(selection)
  replace_selection(translate_output)
end

M.translate_current_selection = translate_current_selection

return M
