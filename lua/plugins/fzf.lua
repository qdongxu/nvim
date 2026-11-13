return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({})
    vim.keymap.set("n", "<C-p>", function() require("fzf-lua").files() end)
    vim.keymap.set("n", "<leader>fg", function() require("fzf-lua").live_grep() end)
    vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end)
    vim.keymap.set("n", "<leader>fs", function() require("fzf-lua").lsp_live_workspace_symbols() end)
  end,
}
