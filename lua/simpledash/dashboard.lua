local digits = require("simpledash.digits")

local M = {}
local timer = nil

local function get_time_string()
  return os.date("%H:%M")
end

local function build_lines(time)
  local output = {}
  local height = #digits.digits["0"]

  for i = 1, height do
    local line = {}
    for c in time:gmatch(".") do
      table.insert(line, digits.digits[c][i])
      table.insert(line, " ")
    end
    table.insert(output, table.concat(line))
  end

  return output
end

local function center_lines(lines)
  local win = vim.api.nvim_get_current_win()
  local width = vim.api.nvim_win_get_width(win)

  local centered = {}

  for _, line in ipairs(lines) do
    local padding = math.max(0, math.floor((width - vim.fn.strdisplaywidth(line)) / 2))
    table.insert(centered, string.rep(" ", padding) .. line)
  end

  return centered
end

local function pick_random_highlight()
  local groups = {
    "String",
    "Function",
    "Keyword",
    "Type",
    "Constant",
    "Identifier",
    "Number",
    "Statement",
  }

  math.randomseed(os.time())
  return groups[math.random(#groups)]
end

local function render(buf, hl)
  local lines = build_lines(get_time_string())
  lines = center_lines(lines)

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  -- Apply highlight to ALL lines
  for i = 0, #lines - 1 do
    vim.api.nvim_buf_add_highlight(buf, -1, hl, i, 0, -1)
  end
end

function M.show()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.bo[buf].swapfile = false

  vim.api.nvim_set_current_buf(buf)

  local hl = pick_random_highlight()
  render(buf, hl)

  -- Update every minute
  timer = vim.loop.new_timer()
  timer:start(
    60000,
    60000,
    vim.schedule_wrap(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        timer:stop()
        timer:close()
        return
      end
      render(buf, hl)
    end)
  )
end

return M
