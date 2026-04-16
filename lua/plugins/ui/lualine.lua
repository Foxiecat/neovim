return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "base16",
    },
    sections = {
      lualine_a = { "mode", require("easy-dotnet.ui-modules.jobs").lualine },
    },
  },
}
