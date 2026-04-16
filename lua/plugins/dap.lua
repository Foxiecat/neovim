return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    dap.defaults.fallback.external_terminal = {
      command = "/usr/bin/wezterm",
      args = { "start" },
    }
  end,
}
