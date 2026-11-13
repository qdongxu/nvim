return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = { { "<C-\\>", desc = "终端: 开关浮动终端" } },
  config = function()
    require("toggleterm").setup({
      open_mapping = [[<c-\>]],
      direction = "float",
      float_opts = { border = "curved" },
    })
  end,
}
