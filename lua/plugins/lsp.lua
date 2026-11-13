return {
    "neovim/nvim-lspconfig",
    config = function()
        -- New 0.11 API
        vim.lsp.config("*", {
            capabilities = vim.lsp.protocol.make_client_capabilities(),
        })
        vim.lsp.enable("gopls")    -- auto-detected if gopls is on PATH

        -- Python
        vim.lsp.config.pyright = {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_markers = { "pyproject.toml", "setup.py", "requirements.txt" },
        }
        vim.lsp.enable("pyright")

        -- Bash
        vim.lsp.config.bash = {
            cmd = { "bash-language-server", "start" },
            filetypes = { "sh", "bash", "zsh" },
            root_markers = { ".git" },
        }
        vim.lsp.enable("bash")

        -- Java
        vim.lsp.config.jdtls = {
            cmd = { "jdtls" },
            filetypes = { "java" },
            root_markers = { "pom.xml", "build.gradle", ".project" },
        }
        vim.lsp.enable("jdtls")

        -- TypeScript / JavaScript
        vim.lsp.config.ts_ls = {
            cmd = { "typescript-language-server", "--stdio" },
            filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
            root_markers = { "tsconfig.json", "package.json" },
        }
        vim.lsp.enable("ts_ls")
        -- HTML
        vim.lsp.config.html = {
            cmd = { "vscode-html-language-server", "--stdio" },
            filetypes = { "html" },
            root_markers = { ".git" },
        }
        vim.lsp.enable("html")
        -- CSS
        vim.lsp.config.css = {
            cmd = { "vscode-css-language-server", "--stdio" },
            filetypes = { "css", "scss", "less" },
            root_markers = { ".git" },
        }
        vim.lsp.enable("css")
        
        -- Elixir: 由 elixir-tools.nvim 管理并自动启动 ElixirLS
        -- (在 lua/plugins/elixir-tools.lua 中配置)

        -- Keymaps on LSP attach
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("user_lsp", {}),
            callback = function(ev)
                local opts = { buffer = ev.buf }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            end,
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "go",
            callback = function()
                vim.bo.tabstop = 4
                vim.bo.shiftwidth = 4
                vim.bo.expandtab = false
            end,
        })

        -- gl: 显示光标处诊断浮窗(nvim 没有默认的 gl 键, 显式声明)
        vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "诊断浮窗" })
    end,
}
