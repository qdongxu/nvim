return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local gitsigns = require("gitsigns")
    gitsigns.setup({
      -- 行号列实时显示增删改标记；当前行用 virt_text 提示
      current_line_blame = false,
      signcolumn = true,
    })

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { desc = "Git: " .. desc })
    end

    map("]h", function() gitsigns.nav_hunk("next") end, "下一个改动块")
    map("[h", function() gitsigns.nav_hunk("prev") end, "上一个改动块")
    map("<leader>hp", gitsigns.preview_hunk, "预览当前改动块")
    map("<leader>hb", gitsigns.blame_line, "当前行 blame")
    map("<leader>tb", gitsigns.toggle_current_line_blame, "开关虚拟行 blame")
    map("<leader>hs", gitsigns.stage_hunk, "暂存当前改动块")
    map("<leader>hr", gitsigns.reset_hunk, "还原当前改动块")
  end,
}
