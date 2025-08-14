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
  -- Get the path to the jar which runs the language server.
  local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  -- Declare which operating system we are using.
  local osname = "linux"
  if vim.fn.has('win32') ~= 0 then
    osname = "win"
  elseif vim.fn.has('mac') ~= 0 then
    osname = "mac"
  end
  -- Get os-specific config path.
  local config = jdtls_path .. "/config_" .. osname
  -- Get path to the Lombok jar.
  local lombok = jdtls_path .. "/lombok.jar"
  return launcher, config, lombok
end

local function get_bundles()
  -- Get full path to the Java Debug Adapter binaries downloaded by Mason.
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

  -- Find the Java Test package in the Mason Registry.
  local java_test_path = get_mason_package_install_path('java-test')
  -- Add all jars for running tests in debug mode to the bundles list.
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
  -- Get access to the jdtls plugin and all of its functionality.
  local jdtls = require "jdtls"

  -- Get the paths to jdtls jar, os-specific config dir, and lombok jar.
  local launcher, os_config, lombok = get_jdtls()

  -- Get bundles list with jars to the debug adapter and testing adapters.
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

  -- Get the path you specified to hold project information.
  local workspace_dir = get_workspace(root_dir)

  -- Tell JDTLS which language features it is capable of.
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

  -- Modify extended client capabilities of JDTLS.
  local extendedClientCapabilities = jdtls.extendedClientCapabilities
  extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

  -- Set the command that starts JDTLS.
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

  -- Run an external process with the given argv array.
  local runproc = function(argv)
    local ok, sysobj = pcall(vim.system, argv, { text = true })
    local res = ok and sysobj:wait()
    local stdout = (ok and res and vim.fn.trim(res.stdout, '\n', 2)) or ''
    local stderr = (ok and res and vim.fn.trim(res.stderr, '\n', 2)) or ''
    local err = -1
    if ok and res and res.signal == 0 then
      err = res.code
    end
    return err, stdout, stderr
  end

  -- Run given java executable with '-version' and return the major version
  -- number parsed from executable's output, or nil if parsing failed.
  local java_version_from_cmd = function(executable)
    local _, stdout, stderr = runproc({executable, '-version'})
    stdout = stdout and vim.fn.trim(stdout) or ''
    stderr = stderr and vim.fn.trim(stderr) or ''
    stdout = stdout == '' and stderr or stdout
    stdout = stdout:gsub('^javac', ''):gsub('^.exe', ''):gsub('^%s*', '')
    local version = stdout:gsub('^1%.', ''):match('^%d+')
    return version and tonumber(version) or nil
  end

  -- Return given java executable's version number deduced from the
  -- executable's path name, or nil if indeterminate.
  local java_version_from_path = function(executable)
    local basedir = vim.fn.fnamemodify(executable, ":p:h:h")
    basedir = vim.fn.fnamemodify(basedir, ":p:h:t"):gsub('[ _-]', '')
    basedir = basedir:gsub('^open', '')
    basedir = basedir:gsub('^jdk', ''):gsub('^java', ''):gsub('^1%.', '')
    local version = basedir:match('^%d+')
    version = version ~= nil and tonumber(version)
    return version
  end

  -- Split a string by the given seperator.  Return list of strings.
  local splitstr = function(inputstr, sep)
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end

  local jdk_path
  if vim.fn.has('win32') ~= 0 then
    jdk_path = function(major_version)
      local progfiles = os.getenv('PROGRAMFILES')
      if not progfiles or progfiles == '' then
        progfiles = os.getenv('SystemDrive') .. '/Program Files'
      end
      local search_dirs = { progfiles .. '/Java' }

      -- Search in standard install dirs.
      for _, dir in ipairs(vim.fn.glob(progfiles .. '/Java/*', true, true)) do
        if vim.fn.executable(dir .. "/bin/javac") ~= 0 then
          local ver = java_version_from_path(dir .. "/bin/javac")
          print('java version from path = "' .. tostring(ver) .. '" (' .. dir .. ')')
          --if ver == major_version then return dir end
        end
      end

      -- Not found in standard install dirs, so check everything in PATH.
      local path = os.getenv('PATH') or ''
      for _, dir in ipairs(splitstr(path, ';')) do
        local ver = java_version_from_cmd(dir .. '/' .. 'javac')
        if ver then
          print('javac = "' .. ver .. '" (' .. dir .. ')')
        end
        if ver == major_version then return vim.fn.fnamemodify(dir, ":h") end
      end

      return nil
    end
  elseif vim.fn.has('mac') ~= 0 then
    ---@diagnostic disable-next-line: unused-local
    jdk_path = function(major_version)
      -- TODO: finish implementing this.
      return "/usr/lib/jvm/java-8-openjdk"
    end
  else
    jdk_path = function(major_version)
      local path
      --path = "/usr/lib/jvm/java-8-openjdk/"
      path = "/usr/lib/jvm/java-8-openjdk-amd64/"
      -- TODO: finish implementing this.
      return path
    end
  end

   -- Configure settings in the JDTLS server.
  local settings = {
    java = {
      -- Enable code formatting.
      format = {
        enabled = true,
        -- Use the Google Style guide for code formatting.
        settings = {
          url = vim.fn.stdpath("config") .. "/lang_servers/intellij-java-google-style.xml",
          profile = "GoogleStyle"
        }
      },
      -- Enable downloading archives from eclipse automatically.
      eclipse = {
        downloadSources = true
      },
      -- Enable downloading archives from maven automatically.
      maven = {
        downloadSources = true
      },
      -- Enable method signature help.
      signatureHelp = {
        enabled = true
      },
      -- Use the fernflower decompiler when using the javap command to
      -- decompile JVM byte code back to Java source code.
      contentProvider = {
        preferred = "fernflower"
      },
      -- Setup automatical package import oranization on file save.
      saveActions = {
        organizeImports = false
      },
      -- Customize completion options
      completion = {
        -- How JDTLS should rank import suggestions for static methods.
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*",
        },
        -- Try not to suggest imports from these packages in code actions.
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
        -- Order in which the language server should organize imports.
        importOrder = {
          "java",
          "jakarta",
          "javax",
          "com",
          "org",
        }
      },
      sources = {
        -- How many classes from a specific package should be imported
        -- before automatic imports combine them all into a single import.
        organizeImports = {
          starThreshold = 9999,
          staticThreshold = 9999
        }
      },
      -- How should different pieces of code be generated?
      codeGeneration = {
        -- Make generated toString() use json format.
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        -- Make generated hashCode()/equals() use Java 7 objects method.
        hashCodeEquals = {
          useJava7Objects = true
        },
        -- Make generated code use code blocks.
        useBlocks = true
      },
      -- Enable code lens.
      implementationsCodeLens = {
        enabled = true,
      },
      referencesCodeLens = {
        enabled = true
      },
      -- Enable inlay hints for parameter names.
      inlayHints = {
        parameterNames = {
          enabled = "all"
        }
      },
      -- If changes to the project will require the developer to update the
      -- project config, advise the developer before accepting the change.
      configuration = {
        updateBuildConfiguration = "interactive",

        -- XXX: `path` items in the `runtimes` map are system-specific!
        -- !!! They specify directories where each JDK is installed !!!
        -- This will, of course, vary based on your local dev setup.
        --
        -- This necessarily involves dirty hacks where we set up each
        -- `path` item on a case-by-case basis.  TODO: come up with
        -- said dirty hacks for the systems I use.
        runtimes = {
          -- XXX: `name` fields are _not_ arbitrary.  Must match one of the
          -- execution environments here:
          -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
          --
          -- JDTLS will choose what runtime to use based on config found in
          -- your project's pom.xml or build.gradle file.  E.g., for maven:
          --   <properties>
          --     <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
          --     <maven.compiler.source>11</maven.compiler.source>
          --     <maven.compiler.target>11</maven.compiler.target>
          --   </properties>
          --[[
          {
            name = "J2SE-1.5",
            path = "TODO",
          },
          {
            name = "JavaSE-1.6",
            path = "TODO",
          },
          {
            name = "JavaSE-1.7",
            path = "TODO",
          },
          --]]
          {
            name = "JavaSE-1.8",
            path = jdk_path(8),
          },
          --[[
          {
            name = "JavaSE-9",
            path = "TODO",
          },
          {
            name = "JavaSE-10",
            path = "TODO",
          },
          {
            name = "JavaSE-11",
            path = "/usr/lib/jvm/java-11-openjdk/",
          },
          {
            name = "JavaSE-12",
            path = "TODO",
          },
          {
            name = "JavaSE-13",
            path = "TODO",
          },
          {
            name = "JavaSE-14",
            path = "TODO",
          },
          {
            name = "JavaSE-15",
            path = "TODO",
          },
          {
            name = "JavaSE-16",
            path = home .. "/.local/jdks/jdk-16.0.1+9/",
          },
          {
            name = "JavaSE-17",
            path = home .. "/.local/jdks/jdk-17.0.2+8/",
          },
          {
            name = "JavaSE-18",
            path = "TODO",
          },
          {
            name = "JavaSE-19",
            path = "TODO",
          },
          {
            name = "JavaSE-20",
            path = "TODO",
          },
          {
            name = "JavaSE-21",
            path = "TODO",
          },
          {
            name = "JavaSE-22",
            path = "TODO",
          },
          --]]
        },
      },
    },
  }

  -- Create table init_options with debug and testing jar bundles, plus
  -- extended client capablies to pass to JDTLS function start_or_attach().
  local init_options = {
    bundles = bundles,
    extendedClientCapabilities = extendedClientCapabilities
  }

  -- Function that will be ran once the language server is attached.
  local on_attach = function(_, bufnr)
    -- Map the Java-specific key mappings once the server is attached.
    java_keymaps()

    -- Setup the Java debug adapter of the JDTLS server.
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

    -- Refresh the codelens.  Code lens enables features such as code
    -- reference counts, implemenation counts, and more.
    vim.lsp.codelens.refresh()

    -- Setup a function that automatically runs every time a Java file is
    -- saved to refresh the code lens.
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = { "*.java" },
      callback = function()
        local _, _ = pcall(vim.lsp.codelens.refresh)
      end
    })
  end

  -- Create the configuration table for the start_or_attach() function.
  local config = {
    cmd = cmd,
    root_dir = root_dir,
    settings = settings,
    capabilities = capabilities,
    init_options = init_options,
    on_attach = on_attach
  }

  -- Start JDTLS or attach to an existing one based on root_dir.
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
    -- Ensure the Java debug adapter is installed.
    ---@diagnostic disable-next-line: missing-fields
    require("mason-nvim-dap").setup({
      ensure_installed = { "javadbg", "javatest" }
    })
    setup_jdtls()
  end,
}
