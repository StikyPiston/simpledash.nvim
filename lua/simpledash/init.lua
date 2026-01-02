local M = {}

-- Block letters (5x5)
local letters = {
  H = {
    "█   █",
    "█   █",
    "█████",
    "█   █",
    "█   █",
  },
  E = {
    "█████",
    "█    ",
    "████ ",
    "█    ",
    "█████",
  },
  L = {
    "█    ",
    "█    ",
    "█    ",
    "█    ",
    "█████",
  },
  O = {
    "█████",
    "█   █",
    "█   █",
    "█   █",
    "█████",
  },
  ["."] = {
    "     ",
    "     ",
    "     ",
    "     ",
    "  █  ",
  },
}

local word = { "H", "E", "L", "L", "O", "." }

local function build_lines()
  local lines = {}
  for row = 1, 5 do
    local parts = {}
    for _, c in ipairs(word) do
      table.insert(parts, letters[c][row])
      table.insert(parts, " ")
    end
    table.insert(lines, table.concat(parts))
  end
  return lines
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

local function center_screen(lines)
  local win = vim.api.nvim_get_current_win()
  local win_h = vim.api.nvim_win_get_height(win)
  local win_w = vim.api.nvim_win_get_width(win)

  local result = {}

  -- Vertical centering
  local top_pad = math.max(0, math.floor((win_h - #lines) / 2))
  for _ = 1, top_pad do
    table.insert(result, "")
  end

  -- Horizontal centering
  for _, line in ipairs(lines) do
    local pad = math.max(0, math.floor((win_w - vim.fn.strdisplaywidth(line)) / 2))
    table.insert(result, string.rep(" ", pad) .. line)
  end

  return result
end

local function show()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false

  vim.api.nvim_set_current_buf(buf)

  local hl = pick_random_highlight()
  local lines = center_screen(build_lines())

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  for i = 0, #lines - 1 do
    vim.api.nvim_buf_add_highlight(buf, -1, hl, i, 0, -1)
  end

  -- Recenter on resize
  vim.api.nvim_create_autocmd("WinResized", {
    buffer = buf,
    callback = function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      local new_lines = center_screen(build_lines())
      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)
      vim.bo[buf].modifiable = false
    end,
  })
end

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      if vim.fn.argc() > 0 then return end
      if vim.bo.filetype ~= "" then return end
      show()
    end,
  })
end

return M
