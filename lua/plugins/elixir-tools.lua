return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    -- nvim 0.12+: elixir-tools 内部调用的旧 codelens API 每次光标停留都刷弃用警告，
    -- 上游尚未修复。此处转发到新 API，0.13 移除旧包装后依然有效。
    vim.lsp.codelens.refresh = function(opts)
      vim.lsp.codelens.enable(true, { bufnr = opts and opts.bufnr })
    end

    local elixir = require("elixir")
    local elixirls = require("elixir.elixirls")

    elixir.setup({
      nextls = { enable = false },
      elixirls = {
        cmd = { "elixir-ls" }, -- 复用 homebrew 安装，跳过内置下载器(60s 超时易失败)
        settings = elixirls.settings({ dialyzerEnabled = false }),
      },
      projectionist = { enable = true },
    })

    vim.keymap.set("n", "<leader>fp", ":ElixirFromPipe<cr>", { desc = "Elixir: 管道转嵌套" })
    vim.keymap.set("n", "<leader>tp", ":ElixirToPipe<cr>", { desc = "Elixir: 嵌套转管道" })
    vim.keymap.set("v", "<leader>em", ":ElixirExpandMacro<cr>", { desc = "Elixir: 展开宏" })
  end,
}
