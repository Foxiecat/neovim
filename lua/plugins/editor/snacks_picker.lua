return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      files = {
        hidden = false,
      },
    },
    picker = {
      sources = {
        explorer = {
          layout = { preset = "sidebar", preview = true },
        },
      },
    },
  },
}
