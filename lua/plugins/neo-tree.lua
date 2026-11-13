return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false, -- 与原 nvim-tree 一致:启动即加载,保证 <Leader>f 随时可用
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- 图标
    "MunifTanjim/nui.nvim",        -- neo-tree 独有依赖
  },
  config = function()
    require("neo-tree").setup({
      filesystem = {
        follow_current_file = {
          enabled = true, -- 切换缓冲区时树自动跟随/高亮当前文件
        },
        use_libuv_file_watcher = true, -- 文件系统变化实时刷新
      },
      window = {
        width = 30,
      },
    })
    -- 接管原 nvim-tree 的键位语义：reveal = 打开树并定位当前文件
    vim.keymap.set('n', '<Leader>f', '<cmd>Neotree reveal left<cr>',
      { silent = true, desc = 'NeoTree: reveal current file' })
    vim.keymap.set('n', '<Leader>e', '<cmd>Neotree toggle left<cr>',
      { silent = true, desc = 'NeoTree: toggle' })
  end,
}
