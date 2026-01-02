local digits = require("simpledash.digits")

local M = {}

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
      table.insert(line, "  ")
    end
    table.insert(output, table.concat(line))
  end

  return output
end

local function pick_random_highlight()
  -- Common color groups most schemes define
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

function M.show()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.bo[buf].swapfile = false

  vim.api.nvim_set_current_buf(buf)

  local lines = build_lines(get_time_string())

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  local hl = pick_random_highlight()
  vim.api.nvim_buf_add_highlight(buf, -1, hl, 0, 0, -1)
end

return M
