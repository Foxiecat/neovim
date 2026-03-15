-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  pattern = "*",
  callback = function()
    local clients = vim.lsp.get_clients({ name = "roslyn" })
    if not clients or #clients == 0 then
      return
    end

    local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
    local buffers = vim.lsp.get_buffers_by_client_id(ctx.client_id)
    for _, buf in ipairs(buffers) do
      local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
      client:request("textDocument/diagnostic", params, nil, buf)
    end
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    if client and (client.name == "roslyn" or client.name == "roslyn_ls") then
      vim.api.nvim_create_autocmd("InsertCharPre", {
        desc = "Roslyn: Trigger an auto insert on '/'.",
        buffer = bufnr,
        callback = function()
          local char = vim.v.char

          if char ~= "/" then
            return
          end

          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          row, col = row - 1, col + 1
          local uri = vim.uri_from_bufnr(bufnr)

          local params = {
            _vs_textDocument = { uri = uri },
            _vs_position = { line = row, character = col },
            _vs_ch = char,
            _vs_options = {
              tabSize = vim.bo[bufnr].tabstop,
              insertSpaces = vim.bo[bufnr].expandtab,
            },
          }

          -- NOTE: We should send textDocument/_vs_onAutoInsert request only after
          -- buffer has changed.
          vim.defer_fn(function()
            client:request(
              ---@diagnostic disable-next-line: param-type-mismatch
              "textDocument/_vs_onAutoInsert",
              params,
              function(err, result, _)
                if err or not result then
                  return
                end

                vim.snippet.expand(result._vs_textEdit.newText)
              end,
              bufnr
            )
          end, 1)
        end,
      })
    end
  end,
})
