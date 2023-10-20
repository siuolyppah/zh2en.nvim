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
  local csrow, _, cerow, _ = selection_area_pos()

  if csrow ~= cerow then
    require("zh2en.notify").error("the selection must be only one line")
    return
  end

  vim.cmd('normal! "ay')
  return csrow, vim.fn.getreg("a")
end

local function split_string(longger, str)
  local startIdx, endIdx = string.find(longger, str, nil, true)
  local part1 = string.sub(longger, 1, startIdx - 1)
  local part2 = string.sub(longger, endIdx + 1)
  return part1, part2
end

local function translate_and_replace(line_no, input)
  local output = require("zh2en.rpc").rpc_translate(input)
  local current_line = vim.fn.getline(line_no)

  local left, right = split_string(current_line, input)
  local newline = left .. output .. right

  vim.fn.setline(line_no, newline)
end

local function translate_current_selection()
  local line_no, selection = get_visual_selection()
  translate_and_replace(line_no, selection)
end

M.translate_current_selection = translate_current_selection

return M
