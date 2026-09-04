 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#232136',
    base01 = '#393552',
    base02 = '#423d5e',
    base03 = '#6c6a85',
    base04 = '#908caa',
    base05 = '#e0def4',
    base06 = '#e0def4',
    base07 = '#e0def4',
    base08 = '#eb6f92',
    base09 = '#9ccfd8',
    base0A = '#f6c177',
    base0B = '#c4a7e7',
    base0C = '#96dce9',
    base0D = '#bb96e9',
    base0E = '#f7c887',
    base0F = '#fadeb7',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e0def4',          bg = '#232136' })
  hi('TelescopeBorder',         { fg = '#6c6a85',             bg = '#232136' })
  hi('TelescopePromptNormal',   { fg = '#e0def4',          bg = '#232136' })
  hi('TelescopePromptBorder',   { fg = '#6c6a85',             bg = '#232136' })
  hi('TelescopePromptPrefix',   { fg = '#c4a7e7',             bg = '#232136' })
  hi('TelescopePromptCounter',  { fg = '#908caa',  bg = '#232136' })
  hi('TelescopePromptTitle',    { fg = '#232136',             bg = '#c4a7e7' })
  hi('TelescopePreviewTitle',   { fg = '#232136',             bg = '#f6c177' })
  hi('TelescopeResultsTitle',   { fg = '#232136',             bg = '#9ccfd8' })
  hi('TelescopeSelection',      { fg = '#e0def4',          bg = '#423d5e' })
  hi('TelescopeSelectionCaret', { fg = '#c4a7e7',             bg = '#423d5e' })
  hi('TelescopeMatching',       { fg = '#c4a7e7',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
