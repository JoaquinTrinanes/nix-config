local U = require("config.util")

---@type LazyPluginSpec[]
return {
  {
    "stevearc/oil.nvim",
    enabled = false,
    event = "VeryLazy",
    cmd = { "Oil" },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = false,
      columns = {
        -- "permissions",
        "icon",
        "size",
        -- "mtime",
      },
      view_options = { show_hidden = true },
      keymaps = {
        -- ["w-"] = "actions.select-split",
        -- ["w|"] = "actions.select-vsplit",
        ["C-r"] = "actions.refresh",
        ["<S-h>"] = "actions.toggle_hidden",

        -- ["g?"] = "actions.show_help",
        -- ["<CR>"] = "actions.select",
        ["<C-s>"] = false, -- "actions.select_vsplit"
        ["<C-h>"] = false, -- "actions.select_split"
        -- ["<C-t>"] = "actions.select_tab",
        -- ["<C-p>"] = "actions.preview",
        ["<C-c>"] = false, -- "actions.close",
        ["<C-l>"] = false, -- "actions.refresh",
        -- ["-"] = "actions.parent",
        -- ["_"] = "actions.open_cwd",
        -- ["`"] = "actions.cd",
        -- ["~"] = "actions.tcd",
        -- ["gs"] = "actions.change_sort",
        -- ["gx"] = "actions.open_external",
        -- ["g."] = "actions.toggle_hidden",
        -- ["g\\"] = "actions.toggle_trash",
        ["q"] = { "actions.close", mode = "n" },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
    optional = true,
    cmd = { "Neotree" },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
      },
      follow_current_file = { enabled = true },
      buffers = {
        follow_current_file = { enabled = true },
      },
    },
  },
  {
    "folke/snacks.nvim",
    optional = true,
    keys = { { "<leader>e", false }, { "<leader>E", false } },
  },
  {
    "echasnovski/mini.files",
    lazy = false,
    opts = {
      windows = {
        preview = true,
        width_focus = 50,
        width_preview = 30,
      },
      options = { use_as_default_explorer = true },
    },
    keys = {
      {
        "<leader>e",
        function()
          local MiniFiles = require("mini.files")
          if not MiniFiles.close() then
            local open_path = nil ---@type string?
            local current_path = vim.api.nvim_buf_get_name(0)
            if vim.fn.isdirectory(current_path) == 1 or vim.fn.filereadable(current_path) == 1 then
              open_path = current_path
            else
              open_path = vim.fs.root(current_path, function(_, dir_path)
                return vim.fn.isdirectory(dir_path) == 1
              end)
            end

            MiniFiles.open(open_path, true)
          end
        end,
        desc = "Explorer mini.files (Root Dir)",
        remap = true,
      },
      {
        "<leader>E",
        function()
          if not require("mini.files").close() then
            require("mini.files").open(vim.fn.getcwd(), true)
          end
        end,
        desc = "Explorer mini.files (cwd)",
        remap = true,
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      local show_dotfiles = true
      local filter_show = function(fs_entry)
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, ".")
      end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require("mini.files").refresh({ content = { filter = new_filter } })
      end

      local map_split = function(buf_id, lhs, direction, close_on_file)
        local rhs = function()
          local new_target_window
          local cur_target_window = require("mini.files").get_explorer_state().target_window
          if cur_target_window ~= nil then
            vim.api.nvim_win_call(cur_target_window, function()
              vim.cmd("belowright " .. direction .. " split")
              new_target_window = vim.api.nvim_get_current_win()
            end)

            require("mini.files").set_target_window(new_target_window)
            require("mini.files").go_in({ close_on_file = close_on_file })
          end
        end

        local desc = "Open in " .. direction .. " split"
        if close_on_file then
          desc = desc .. " and close"
        end
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
      end

      local files_set_cwd = function()
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        if cur_directory ~= nil then
          vim.fn.chdir(cur_directory)
        end
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id

          vim.keymap.set(
            "n",
            opts.mappings and opts.mappings.toggle_hidden or "g.",
            toggle_dotfiles,
            { buffer = buf_id, desc = "Toggle hidden files" }
          )

          vim.keymap.set(
            "n",
            opts.mappings and opts.mappings.change_cwd or "gc",
            files_set_cwd,
            { buffer = args.data.buf_id, desc = "Set cwd" }
          )

          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal or "<C-w>s", "horizontal", false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical or "<C-w>v", "vertical", false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal_plus or "<C-w>S", "horizontal", true)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical_plus or "<C-w>V", "vertical", true)
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end,
  },
  {
    -- add git highligts
    "echasnovski/mini.files",
    optional = true,
    opts = function()
      -- adapted from https://gist.github.com/bassamsdata/eec0a3065152226581f8d4244cce9051
      local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
      local autocmd = vim.api.nvim_create_autocmd
      local MiniFiles = require("mini.files")

      -- Cache for git status
      local gitStatusCache = {}
      local cacheTimeout = 2000 -- Cache timeout in milliseconds

      local function isSymlink(path)
        local stat = vim.uv.fs_lstat(path)
        return stat ~= nil and stat.type == "link"
      end

      ---@type table<string, {symbol: string, hlGroup: string}>
      ---@param status string
      ---@param is_symlink boolean
      ---@return string symbol, string hlGroup
      local function mapSymbols(status, is_symlink)
        local statusMap = {
          [" M"] = { symbol = "○", hlGroup = "Changed" }, -- Modified in the working directory
          ["M "] = { symbol = "○", hlGroup = "Changed" }, -- modified in index
          ["MM"] = { symbol = "≠", hlGroup = "Changed" }, -- modified in both working tree and index
          ["A "] = { symbol = "", hlGroup = "Added" }, -- Added to the staging area, new file
          ["AA"] = { symbol = "", hlGroup = "Added" }, -- file is added in both working tree and index
          ["D "] = { symbol = "", hlGroup = "Removed" }, -- Deleted from the staging area
          ["AM"] = { symbol = "⊕", hlGroup = "Changed" }, -- added in working tree, modified in index
          ["AD"] = { symbol = "-•", hlGroup = "Changed" }, -- Added in the index and deleted in the working directory
          ["R "] = { symbol = "→", hlGroup = "Changed" }, -- Renamed in the index
          ["U "] = { symbol = "‖", hlGroup = "Changed" }, -- Unmerged path
          ["UU"] = { symbol = " ", hlGroup = "Added" }, -- file is unmerged
          ["UA"] = { symbol = "○", hlGroup = "Added" }, -- file is unmerged and added in working tree
          ["??"] = { symbol = "?", hlGroup = "Added" }, -- Untracked files
          ["!!"] = { symbol = "", hlGroup = "NonText" }, -- Ignored files
        }

        local result = statusMap[status] or { symbol = "?", hlGroup = "NonText" }
        local gitSymbol = result.symbol
        local gitHlGroup = result.hlGroup

        local symlinkSymbol = is_symlink and "↩" or ""

        local combinedSymbol = vim.trim(symlinkSymbol .. gitSymbol)

        return combinedSymbol, gitHlGroup
      end

      ---@param cwd string
      ---@param callback function
      ---@return nil
      local function fetchGitStatus(cwd, callback)
        local clean_cwd = cwd:gsub("^minifiles://%d+/", "")
        ---@param content table
        local function on_exit(content)
          if content.code == 0 then
            callback(content.stdout)
          end
        end
        vim.system(
          { "git", "status", "--untracked-files=normal", "--ignored", "--porcelain" },
          { text = true, cwd = clean_cwd },
          on_exit
        )
      end

      ---@param buf_id integer
      ---@param gitStatusMap table
      ---@return nil
      local function updateMiniWithGit(buf_id, gitStatusMap)
        vim.schedule(function()
          local nlines = vim.api.nvim_buf_line_count(buf_id)
          local cwd = vim.fs.root(buf_id, ".git")
          local escapedcwd = cwd and vim.pesc(cwd)
          escapedcwd = escapedcwd and vim.fs.normalize(escapedcwd)

          for i = 1, nlines do
            local entry = MiniFiles.get_fs_entry(buf_id, i)
            if not entry then
              break
            end
            local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
            local status = gitStatusMap[relativePath]

            if status then
              local is_symlink = isSymlink(entry.path)
              local symbol, hlGroup = mapSymbols(status, is_symlink)

              vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
                virt_text = { { symbol, hlGroup } },
                virt_text_pos = "right_align",
                line_hl_group = hlGroup,
                sign_hl_group = hlGroup,
              })
            else
            end
          end
        end)
      end

      -- Thanks for the idea of gettings https://github.com/refractalize/oil-git-status.nvim signs for dirs
      ---@param content string
      ---@return table
      local function parseGitStatus(content)
        local gitStatusMap = {}
        -- lua match is faster than vim.split (in my experience)
        for line in content:gmatch("[^\r\n]+") do
          local status, filePath = string.match(line, "^(..)%s+(.*)")
          -- Split the file path into parts
          local parts = {}
          for part in filePath:gmatch("[^/]+") do
            table.insert(parts, part)
          end
          -- Start with the root directory
          local currentKey = ""
          for i, part in ipairs(parts) do
            if i > 1 then
              -- Concatenate parts with a separator to create a unique key
              currentKey = currentKey .. "/" .. part
            else
              currentKey = part
            end
            -- If it's the last part, it's a file, so add it with its status
            if i == #parts then
              gitStatusMap[currentKey] = status
            else
              -- If it's not the last part, it's a directory. Check if it exists, if not, add it.
              if not gitStatusMap[currentKey] then
                gitStatusMap[currentKey] = status
              end
            end
          end
        end
        return gitStatusMap
      end

      ---@param buf_id integer
      ---@return nil
      local function updateGitStatus(buf_id)
        local cwd = vim.fs.root(buf_id, ".git")
        if not cwd then
          return
        end

        local currentTime = os.time()
        if gitStatusCache[cwd] and currentTime - gitStatusCache[cwd].time < cacheTimeout then
          updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
        else
          fetchGitStatus(cwd, function(content)
            local gitStatusMap = parseGitStatus(content)
            gitStatusCache[cwd] = {
              time = currentTime,
              statusMap = gitStatusMap,
            }
            updateMiniWithGit(buf_id, gitStatusMap)
          end)
        end
      end

      ---@return nil
      local function clearCache()
        gitStatusCache = {}
      end

      autocmd("User", {
        group = U.augroup("MiniFiles_start"),
        pattern = "MiniFilesExplorerOpen",
        callback = function(args)
          -- local bufnr = vim.api.nvim_get_current_buf()
          local bufnr = args.buf
          updateGitStatus(bufnr)
        end,
      })

      autocmd("User", {
        group = U.augroup("MiniFiles_close"),
        pattern = "MiniFilesExplorerClose",
        callback = function()
          clearCache()
        end,
      })

      autocmd("User", {
        group = U.augroup("MiniFiles_update"),
        pattern = "MiniFilesBufferUpdate",
        callback = function(args)
          local bufnr = args.data.buf_id

          local cwd = vim.fs.root(bufnr, ".git")

          if gitStatusCache[cwd] then
            updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
          end
        end,
      })
    end,
  },
}
