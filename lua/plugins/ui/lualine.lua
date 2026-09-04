local dotnet = require("easy-dotnet")

return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "base16",
    },
    sections = {
      lualine_x = {
        dotnet.lualine.jobs,
        {
          dotnet.lualine.run_status,
          color    = dotnet.lualine.run_status_color,
          on_click = dotnet.lualine.run_status_click,
        },
      },
    },
  },
}
