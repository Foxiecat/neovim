return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "rose-pine",
    },
    sections = {
      lualine_a = { "mode", require("easy-dotnet.ui-modules.jobs").lualine },
    },
  },
}
