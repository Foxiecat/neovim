return {
  -- lazy.nvim
  {
    "GustavEikaas/easy-dotnet.nvim",
    lazy = true,
    -- 'nvim-telescope/telescope.nvim' or 'ibhagwan/fzf-lua' or 'folke/snacks.nvim'
    -- are highly recommended for a better experience
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap", "folke/snacks.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")
      -- Options are not required
      dotnet.setup({
        -- Optional configuration for external terminals (matches nvim-dap structure)
        external_terminal = nil,
        lsp = {
          enabled = true, -- Enable builtin roslyn lsp
          preload_roslyn = true, -- Start loading roslyn before any buffer is opened
          roslynator_enabled = true, -- Automatically enable roslynator analyzer
          easy_dotnet_analyzer_enabled = true, -- Enable roslyn analyzer from easy-dotnet-server
          auto_refresh_codelens = true,
          analyzer_assemblies = { -- Any additional roslyn analyzers you might use like SonarAnalyzer.CSharp
            "/home/foxiecat/GlobalNuGetPackages/SonarAnalyzer.CSharp.10.20.0.135146/analyzers/SonarAnalyzer.CSharp.dll",
          },
          config = {},
        },
        debugger = {
          -- Path to custom coreclr DAP adapter
          -- easy-dotnet-server falls back to its own netcoredbg binary if bin_path is nil
          bin_path = nil,
          console = "integratedTerminal", -- Controls where the target app runs: "integratedTerminal" (Neovim buffer) or "externalTerminal" (OS window)
          apply_value_converters = true,
          auto_register_dap = true,
          mappings = {
            open_variable_viewer = { lhs = "T", desc = "open variable viewer" },
          },
        },
        ---@type TestRunnerOptions
        test_runner = {
          ---@type "split" | "vsplit" | "float" | "buf"
          viewmode = "float",
          ---@type number|nil
          vsplit_width = nil,
          ---@type string|nil "topleft" | "topright"
          vsplit_pos = nil,
          enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
          noBuild = false,
          icons = {
            passed = "",
            skipped = "",
            failed = "",
            success = "",
            reload = "",
            test = "",
            sln = "󰘐",
            project = "󰘐",
            dir = "",
            package = "",
          },
          mappings = {
            run_test_from_buffer = { lhs = "<leader>r", desc = "run test from buffer" },
            run_all_tests_from_buffer = { lhs = "<leader>t", desc = "run all tests from buffer" },
            peek_stack_trace_from_buffer = { lhs = "<leader>p", desc = "peek stack trace from buffer" },
            filter_failed_tests = { lhs = "<leader>fe", desc = "filter failed tests" },
            debug_test = { lhs = "<leader>d", desc = "debug test" },
            go_to_file = { lhs = "g", desc = "go to file" },
            run_all = { lhs = "<leader>R", desc = "run all tests" },
            run = { lhs = "<leader>r", desc = "run test" },
            peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
            expand = { lhs = "o", desc = "expand" },
            expand_node = { lhs = "E", desc = "expand node" },
            expand_all = { lhs = "-", desc = "expand all" },
            collapse_all = { lhs = "W", desc = "collapse all" },
            close = { lhs = "q", desc = "close testrunner" },
            refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" },
          },
          --- Optional table of extra args e.g "--blame crash"
          additional_args = {},
        },
        new = {
          project = {
            prefix = "sln", -- "sln" | "none"
          },
        },
        ---@param action "test" | "restore" | "build" | "run"
        terminal = function(path, action, args)
          args = args or ""
          local commands = {
            run = function()
              return string.format("dotnet run --project %s %s", path, args)
            end,
            test = function()
              return string.format("dotnet test %s %s", path, args)
            end,
            restore = function()
              return string.format("dotnet restore %s %s", path, args)
            end,
            build = function()
              return string.format("dotnet build %s %s", path, args)
            end,
            watch = function()
              return string.format("dotnet watch --project %s %s", path, args)
            end,
          }
          local command = commands[action]()
          if require("easy-dotnet.extensions").isWindows() == true then
            command = command .. "\r"
          end
          vim.cmd("vsplit")
          vim.cmd("term " .. command)
        end,
        csproj_mappings = true,
        fsproj_mappings = true,
        auto_bootstrap_namespace = {
          --block_scoped, file_scoped
          type = "file_scoped",
          enabled = true,
          use_clipboard_json = {
            behavior = "prompt", --'auto' | 'prompt' | 'never',
            register = "+", -- which register to check
          },
        },
        server = {
          ---@type nil | "Off" | "Critical" | "Error" | "Warning" | "Information" | "Verbose" | "All"
          log_level = nil,
        },
        -- choose which picker to use with the plugin
        -- possible values are "telescope" | "fzf" | "snacks" | "basic"
        -- if no picker is specified, the plugin will determine
        -- the available one automatically with this priority:
        -- telescope -> fzf -> snacks ->  basic
        picker = "snacks",
        background_scanning = true,
        notifications = {
          --Set this to false if you have configured lualine to avoid double logging
          handler = function(start_event)
            local spinner = require("easy-dotnet.ui-modules.spinner").new()
            spinner:start_spinner(start_event.job.name)
            ---@param finished_event JobEvent
            return function(finished_event)
              spinner:stop_spinner(finished_event.result.msg, finished_event.result.level)
            end
          end,
        },
        diagnostics = {
          default_severity = "warning",
          setqflist = false,
        },
      })

      -- Example command
      vim.api.nvim_create_user_command("Secrets", function()
        dotnet.secrets()
      end, {})

      -- Example keybinding
      vim.keymap.set("n", "<C-p>", function()
        dotnet.run_project()
      end)
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local job_indicator = { require("easy-dotnet.ui-modules.jobs").lualine }
      opts.sections = {
        lualine_a = { "mode", job_indicator },
      }
      return opts
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "csharpier", "netcoredbg" } },
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.csharpier)
      table.insert(opts.sources, nls.builtins.formatting.fantomas)
    end,
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.config
    opts = {
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["A"] = "explorer_add_dotnet",
                },
              },
            },
            actions = {
              explorer_add_dotnet = function(picker)
                local dir = picker:dir()
                local easydotnet = require("easy-dotnet")

                easydotnet.create_new_item(dir, function(item_path)
                  local tree = require("snacks.explorer.tree")
                  local actions = require("snacks.explorer.actions")
                  tree:open(dir)
                  tree:refresh(dir)
                  actions.update(picker, { target = item_path })
                  picker:focus()
                end)
              end,
            },
          },
        },
      },
    },
  },
}
