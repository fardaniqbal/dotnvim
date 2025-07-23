-- JDTLS (Java language server) setup.  See also ftplugin/java.lua.
-- Config roughly based on nvim-jdtls sample configurations:
-- https://github.com/mfussenegger/nvim-jdtls/wiki/Sample-Configurations

return {
  'mfussenegger/nvim-jdtls',
  lazy = true,
  ft = { 'java', 'jsp' },

  config = function()

    local ospath = function(path) return path end

    -- Adjust behavior on Windows.  XXX: %USERPROFILE% may not be
    -- set depending on how MSYS2 is configured.
    if vim.loop.os_uname().sysname:find('^Windows') ~= nil then
      ospath = function(path) return path.gsub('/', '\\') end
    end

    -- The below setup is (roughly) based on this guide:
    -- https://sookocheff.com/post/vim/neovim-java-ide/
    local home = ospath(os.getenv('USERPROFILE') or os.getenv('HOME'))

    -- File types that signify a Java project's root directory.  This
    -- will be used by jdtls to determine what constitutes a workspace.
    local root_markers = {'gradlew', 'mvnw', 'build.xml', 'ant', '.git'}
    local root_dir = require('jdtls.setup').find_root(root_markers)

    -- eclipse.jdt.ls stores project specific data within a folder.
    -- If you are working with multiple different projects, each
    -- project must use a dedicated data directory. This variable
    -- is used to configure eclipse to use the directory name of
    -- the current project found using the "root_marker" as the
    -- folder for project specific data.
    local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

    local config = {
      cmd = {
        --'java',
        (os.getenv('USERPROFILE') or os.getenv('HOME')) .. '/local/jdtls/bin/jdtls',
        '-data', workspace_folder,
      },

      -- TODO: need better logic for this.  Some of our projects have their
      -- build.xml files under an `ant` directory.
      root_dir = vim.fs.dirname(vim.fs.find(
          { 'gradlew', 'pom.xml', 'build.xml', '.git', 'mvnw' },
          { upward = true }
      )[1]),

      -- Here you can configure eclipse.jdt.ls specific settings
      -- For list of options see
      -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      settings = {
        java = {
          signatureHelp = { enabled = true };
          contentProvider = { preferred = 'fernflower' };

          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*"
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "jdk.*",
              "sun.*",
            },
          };

          sources = {
            organizeImports = {
              starThreshold = 9999;
              staticStarThreshold = 9999;
            };
          };

          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
            },
            hashCodeEquals = {
              useJava7Objects = true,
            },
            useBlocks = true,
          };

          configuration = {
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
            }
          };
        }
      },
    }

    -- This starts a new client & server,
    -- or attaches to an existing client & server depending on the `root_dir`.
    require("jdtls").start_or_attach(config)
  end
}
