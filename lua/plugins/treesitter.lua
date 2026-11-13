return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    -- 新版（main 分支）API：install() 装解析器（已装的会跳过）
    require("nvim-treesitter").install({
      "lua", "query", "vimdoc", "markdown", "markdown_inline",
      "java", "bash", "javascript", "typescript", "go", "python", "html", "css",
      "elixir", "heex",
    })

    -- 新版没有 highlight.enable：Neovim 0.10+ 需要手动 vim.treesitter.start()
    -- pcall 兜底：没有解析器的文件类型不报错
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}

