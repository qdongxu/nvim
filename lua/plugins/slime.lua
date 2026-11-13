return {
  -- 原 jalvesaq/nvim-slime 已从 GitHub 删除，改用维护中的原版
  "jpalardy/vim-slime",
  init = function()
    vim.g.slime_target = "neovim"     -- 发送到 Neovim 内置终端(含 toggleterm 的隐藏终端)
    vim.g.slime_menu_config = 1       -- 首次发送时弹编号菜单选终端
    vim.g.slime_bracketed_paste = 1   -- 多行代码整块发送，iex 友好
    vim.g.slime_no_mappings = 1
  end,
  keys = {
    { "<leader>sl", "<Plug>SlimeLineSend", desc = "Slime: 发送当前行", mode = "n" },
    { "<leader>ss", "<Plug>SlimeRegionSend", desc = "Slime: 发送选区", mode = "x" },
    { "<C-c><C-c>", "<Plug>SlimeParagraphSend", desc = "Slime: 发送段落", mode = "n" },
    { "<C-c><C-c>", "<Plug>SlimeRegionSend", desc = "Slime: 发送选区", mode = "x" },
  },
}
