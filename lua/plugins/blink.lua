return {
  "Saghen/blink.cmp",
  version = "*",
  event = { "InsertEnter", "CmdlineEnter" },
  opts = {
    keymap = { preset = "default" },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
  },
}
