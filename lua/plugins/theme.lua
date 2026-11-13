return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- Load this plugin before everything else
    config = function()
      -- Set theme variant: mocha, macchiato, frappe, latte
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  }
}

