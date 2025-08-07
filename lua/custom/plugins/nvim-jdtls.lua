-- JDTLS (Java language server) setup.  See also ftplugin/java.lua.
-- Config roughly based on nvim-jdtls sample configurations:
-- https://github.com/mfussenegger/nvim-jdtls/wiki/Sample-Configurations
--
-- Also influenced by:
-- https://github.com/unknownkoder/Java-FullStack-NeoVim-Configuration

local function get_mason_package_install_path(pkgname)
  -- Get the Mason Registry to gain access to downloaded binaries.  Find
  -- the given package in the Mason Regsitry, then find the full path to
  -- the directory where Mason has downloaded the package's binaries.
  -- NOTE: used to be as follows:
  --   local mason_registry = require("mason-registry")
  --   local pkg = mason_registry.get_package(pkgname)
  --   return pkg:get_install_path()
  --
  -- See this discussion explaining how it was deprecated, and how we
  -- should use "$MASON/packages" now instead:
  -- https://github.com/mason-org/mason.nvim/discussions/33
  return vim.fn.expand("$MASON/packages/" .. pkgname)
end

local function get_jdtls()
  local jdtls_path = get_mason_package_install_path("jdtls")
  -- Obtain the path to the jar which runs the language server
  local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  -- Declare which operating system we are using.
  local osname = "linux"
  if vim.fn.has('win32') ~= 0 then
    osname = "win"
  elseif vim.fn.has('mac') ~= 0 then
    osname = "mac"
  end
  -- Obtain the path to configuration files for your specific operating system
  local config = jdtls_path .. "/config_" .. osname
  -- Obtain the path to the Lomboc jar
  local lombok = jdtls_path .. "/lombok.jar"
  return launcher, config, lombok
end

local function get_bundles()
  -- -- Get the Mason Registry to gain access to downloaded binaries
  -- local mason_registry = require("mason-registry")
  -- -- Find the Java Debug Adapter package in the Mason Registry
  -- local java_debug = mason_registry.get_package("java-debug-adapter")
  -- -- Obtain the full path to the directory where Mason has downloaded the Java Debug Adapter binaries
  -- local java_debug_path = java_debug:get_install_path()
  local java_debug_path = get_mason_package_install_path("java-debug-adapter")

  local bundles = {
    vim.fn.glob(
      java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
      false, true, false)[1]
  }

  bundles = {
    vim.fn.glob(
      java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
      1)
  }

  -- Find the Java Test package in the Mason Registry
  -- local java_test = mason_registry.get_package("java-test")
  -- Obtain the full path to the directory where Mason has downloaded the Java Test binaries
  -- local java_test_path = java_test:get_install_path()
  local java_test_path = get_mason_package_install_path('java-test')
  -- Add all of the Jars for running tests in debug mode to the bundles list
  vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar", 1), "\n"))

  return bundles
end

-- Table maps project directories to their cached workspace names.
local workspace_cache = {}

local function get_workspace(root_dir)
  local proj_dir = vim.fn.fnamemodify(root_dir, ":p")
  if workspace_cache[proj_dir] == nil then
    -- Generate a short but unique folder for this project based on its
    -- absolute path.
    local home = os.getenv('USERPROFILE') or os.getenv('HOME')
    workspace_cache[proj_dir] = home .. "/.local/cache/jdtls-workspace/" ..
        vim.fn.fnamemodify(root_dir, ":p:h:t") .. '-' ..
        require('lib.md5.md5').sumhexa(proj_dir)
  end
  return workspace_cache[proj_dir]
end

local function java_keymaps()
  -- Allow yourself to run JdtCompile as a Vim command
  vim.cmd("command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)")
  -- Allow yourself/register to run JdtUpdateConfig as a Vim command
  vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
  -- Allow yourself/register to run JdtBytecode as a Vim command
  vim.cmd("command! -buffer JdtBytecode lua require('jdtls').javap()")
  -- Allow yourself/register to run JdtShell as a Vim command
  vim.cmd("command! -buffer JdtJshell lua require('jdtls').jshell()")

  -- Set a Vim motion to <Space> + <Shift>J + o to organize imports in normal mode
  vim.keymap.set('n', '<leader>Jo', "<Cmd> lua require('jdtls').organize_imports()<CR>", { desc = "[J]ava [O]rganize Imports" })
  -- Set a Vim motion to <Space> + <Shift>J + v to extract the code under the cursor to a variable
  vim.keymap.set('n', '<leader>Jv', "<Cmd> lua require('jdtls').extract_variable()<CR>", { desc = "[J]ava Extract [V]ariable" })
  -- Set a Vim motion to <Space> + <Shift>J + v to extract the code selected in visual mode to a variable
  vim.keymap.set('v', '<leader>Jv', "<Esc><Cmd> lua require('jdtls').extract_variable(true)<CR>", { desc = "[J]ava Extract [V]ariable" })
  -- Set a Vim motion to <Space> + <Shift>J + <Shift>C to extract the code under the cursor to a static variable
  vim.keymap.set('n', '<leader>JC', "<Cmd> lua require('jdtls').extract_constant()<CR>", { desc = "[J]ava Extract [C]onstant" })
  -- Set a Vim motion to <Space> + <Shift>J + <Shift>C to extract the code selected in visual mode to a static variable
  vim.keymap.set('v', '<leader>JC', "<Esc><Cmd> lua require('jdtls').extract_constant(true)<CR>", { desc = "[J]ava Extract [C]onstant" })
  -- Set a Vim motion to <Space> + <Shift>J + t to run the test method currently under the cursor
  vim.keymap.set('n', '<leader>Jt', "<Cmd> lua require('jdtls').test_nearest_method()<CR>", { desc = "[J]ava [T]est Method" })
  -- Set a Vim motion to <Space> + <Shift>J + t to run the test method that is currently selected in visual mode
  vim.keymap.set('v', '<leader>Jt', "<Esc><Cmd> lua require('jdtls').test_nearest_method(true)<CR>", { desc = "[J]ava [T]est Method" })
  -- Set a Vim motion to <Space> + <Shift>J + <Shift>T to run an entire test suite (class)
  vim.keymap.set('n', '<leader>JT', "<Cmd> lua require('jdtls').test_class()<CR>", { desc = "[J]ava [T]est Class" })
  -- Set a Vim motion to <Space> + <Shift>J + u to update the project configuration
  vim.keymap.set('n', '<leader>Ju', "<Cmd> JdtUpdateConfig<CR>", { desc = "[J]ava [U]pdate Config" })
end

local function setup_jdtls()
  -- Get access to the jdtls plugin and all of its functionality
  local jdtls = require "jdtls"

  -- Get the paths to the jdtls jar, operating specific configuration directory, and lombok jar
  local launcher, os_config, lombok = get_jdtls()

  -- Get the bundles list with the jars to the debug adapter, and testing adapters
  local bundles = get_bundles()

  -- Determine the root directory of the project by looking for these
  -- specific markers. This will be used by jdtls to determine what
  -- constitutes a workspace. TODO: need better logic for this.  Some of
  -- our projects have their build.xml files under an `ant` directory.
  --[[
  root_dir = vim.fs.dirname(vim.fs.find(
      { 'gradlew', 'pom.xml', 'build.xml', '.git', 'mvnw' },
      { upward = true }
  )[1]),
  --]]
  local root_markers = { 'mvnw', 'gradlew', 'pom.xml', 'build.gradle', '.git', 'build.xml' }
  local root_dir = jdtls.setup.find_root(root_markers);

  -- Get the path you specified to hold project information
  local workspace_dir = get_workspace(root_dir)

  -- Tell JDTLS which language features it is capable of
  local capabilities = {
    workspace = {
      configuration = true
    },
    textDocument = {
      completion = {
        snippetSupport = false
      }
    }
  }

  local lsp_capabilities = require("blink.cmp").get_lsp_capabilities()

  for k,v in pairs(lsp_capabilities) do capabilities[k] = v end

  -- Get the default extended client capablities of the JDTLS language server
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  -- Modify one property called resolveAdditionalTextEditsSupport and set it to true
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  -- Set the command that starts the JDTLS language server jar
  local cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. lombok,
    '-jar',
    launcher,
    '-configuration',
    os_config,
    '-data',
    workspace_dir
  }

   -- Configure settings in the JDTLS server
  local settings = {
    java = {
      -- Enable code formatting
      format = {
        enabled = true,
        -- Use the Google Style guide for code formattingh
        settings = {
          url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
          profile = "GoogleStyle"
        }
      },
      -- Enable downloading archives from eclipse automatically
      eclipse = {
        downloadSource = true
      },
      -- Enable downloading archives from maven automatically
      maven = {
        downloadSources = true
      },
      -- Enable method signature help
      signatureHelp = {
        enabled = true
      },
      -- Use the fernflower decompiler when using the javap command to decompile byte code back to java code
      contentProvider = {
        preferred = "fernflower"
      },
      -- Setup automatical package import oranization on file save
      saveActions = {
        organizeImports = false
      },
      -- Customize completion options
      completion = {
        -- When using an unimported static method, how should the LSP rank possible places to import the static method from
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
        },
        -- Try not to suggest imports from these packages in the code action window
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
        -- Set the order in which the language server should organize imports
        importOrder = {
          "java",
          "jakarta",
          "javax",
          "com",
          "org",
        }
      },
      sources = {
        -- How many classes from a specific package should be imported before automatic imports combine them all into a single import
        organizeImports = {
          starThreshold = 9999,
          staticThreshold = 9999
        }
      },
      -- How should different pieces of code be generated?
      codeGeneration = {
        -- When generating toString use a json format
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        -- When generating hashCode and equals methods use the java 7 objects method
        hashCodeEquals = {
          useJava7Objects = true
        },
        -- When generating code use code blocks
        useBlocks = true
      },
      -- enable code lens in the lsp
      referencesCodeLens = {
        enabled = true
      },
      -- enable inlay hints for parameter names,
      inlayHints = {
        parameterNames = {
          enabled = "all"
        }
      },
      -- If changes to the project will require the developer to update the projects configuration advise the developer before accepting the change
      configuration = {
        updateBuildConfiguration = "interactive",

        -- XXX: `name` items in the `runtimes` map _are not arbitrary_.
        -- Their names are semantically significant to JDTLS.
        --
        -- XXX: `path` items in the `runtimes` map are system-specific!
        -- !!! They specify directories where each JDK is installed !!!
        -- This will, of course, vary based on your local dev setup.
        --
        -- This necessarily involves dirty hacks where we set up each
        -- `path` item on a case-by-case basis.  TODO: come up with
        -- said dirty hacks for the systems I use.
        runtimes = {
          {
            name = "JavaSE-1.8",
            --path = "/usr/lib/jvm/java-8-openjdk/",
            path = "/usr/lib/jvm/java-8-openjdk-amd64/",
          },
          --[[
          {
            name = "JavaSE-11",
            path = "/usr/lib/jvm/java-11-openjdk/",
          },
          {
            name = "JavaSE-16",
            path = home .. "/.local/jdks/jdk-16.0.1+9/",
          },
          {
            name = "JavaSE-17",
            path = home .. "/.local/jdks/jdk-17.0.2+8/",
          },
          --]]
        },
      },
    },
  }

  -- Create a table called init_options to pass the bundles with debug and testing jar, along with the extended client capablies to the start or attach function of JDTLS
  local init_options = {
    bundles = bundles,
    extendedClientCapabilities = extendedClientCapabilities
  }

  -- Function that will be ran once the language server is attached
  local on_attach = function(_, bufnr)
    -- Map the Java specific key mappings once the server is attached
    java_keymaps()

    -- Setup the java debug adapter of the JDTLS server
    require('jdtls.dap').setup_dap()

    -- Find the main method(s) of the application so the debug adapter can
    -- successfully start up the application. Sometimes this will randomly
    -- fail if language server takes to long to startup for the project, if
    -- a ClassDefNotFoundException occurs when running. the debug tool,
    -- attempt to run the debug tool while in the main class of the
    -- application, or restart the neovim instance. Unfortunately I have
    -- not found an elegant way to ensure this works 100%.
    require('jdtls.dap').setup_dap_main_class_configs()
    -- Enable jdtls commands to be used in Neovim
    --require 'jdtls.setup'.add_commands() -- deprecated (start() auto-adds commands)
    -- Refresh the codelens
    -- Code lens enables features such as code reference counts, implemenation counts, and more.
    vim.lsp.codelens.refresh()

    -- Setup a function that automatically runs every time a java file is
    -- saved to refresh the code lens
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.java" },
      callback = function()
        local _, _ = pcall(vim.lsp.codelens.refresh)
      end
    })
  end

  -- Create the configuration table for the start or attach function
  local config = {
    cmd = cmd,
    root_dir = root_dir,
    settings = settings,
    capabilities = capabilities,
    init_options = init_options,
    on_attach = on_attach
  }

  -- Start the JDTLS server
  require('jdtls').start_or_attach(config)
end

return {
    'mfussenegger/nvim-jdtls',
    lazy = true,
    ft = { 'java' },
    dependencies = {
      "jay-babu/mason-nvim-dap.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      -- ensure the java debug adapter is installed
      require("mason-nvim-dap").setup({
        ensure_installed = { "javadbg", "javatest" }
      })
      setup_jdtls()
    end,
}
