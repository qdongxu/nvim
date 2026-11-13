return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>go", "<cmd>DiffviewOpen<cr>", desc = "Git: 打开 Diffview（审阅全部改动）" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Git: 关闭 Diffview" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git: 当前文件历史" },
  },
  config = function()
    require("diffview").setup({
      view = {
        merge_tool = { layout = "diff3_plain" },
      },
    })
  end,
}
