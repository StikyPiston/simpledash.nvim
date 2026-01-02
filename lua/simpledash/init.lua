local dashboard = require("simpledash.dashboard")

local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- If files were passed as args, do nothing
      if vim.fn.argc() > 0 then
        return
      end

      -- If already in a real buffer, do nothing
      if vim.bo.filetype ~= "" then
        return
      end

      dashboard.show()
    end,
  })
end

return M
