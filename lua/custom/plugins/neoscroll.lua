--[[
Smooth scrolling - the available plugins are not quite ready yet for my
use cases, so consider this file as mostly documentation for what I intend
to do once one of them are mature enough to do what I need them to do.

Here is a non-exhaustive list of smooth-scrolling plugins:
* https://github.com/karb94/neoscroll.nvim
* https://github.com/echasnovski/mini.animate
* https://github.com/declancm/cinnamon.nvim
--]]

--[[
The neoscroll plugin has much potential in terms of making things
visually easier to keep track of during large jumps, especially while
screen-sharing.  However, it still has a long way to go, so let's keep it
commented out until it matures enough to:

- Properly handle ctrl+u/ctrl+d in Telescope (#1 use case)
- Can handle smooth scrolling for `n` and `N` (tied for #1 use case)
- Has options to mitigate slow connections (minimum framerate, debounce
  handling, etc.)
- Work well with smear_cursor plugin without hacky workarounds
- Handle probably a million other things I haven't thought of

Other similar plugins to look into are cinnamon and mini.animation.  Main
reason I'm favoring neoscroll over the others is that it offers hooks to
disable smear_cursor while the scroll animation plays, which actually makes
it practical performance-wise to use both at the same time.  This may
change in the future.
--]]

--[[
-- Here's the neoscroll-based smooth scrolling.
return {
  "karb94/neoscroll.nvim",
  event = 'UIEnter',
  config = function()
    local neoscroll = require('neoscroll')
    -- See https://github.com/karb94/neoscroll.nvim, under 'pre_hook'.
    -- local keymap = {
    --   -- Useful for passing custon 'info' arg to pre_hook/post_hook.
    --   ["<C-u>"] = function() neoscroll.ctrl_u({
    --     info = 'cursorline',
    --   }) end;
    --   ["<C-d>"] = function() neoscroll.ctrl_d({
    --     info = 'cursorline',
    --   }) end;
    -- }
    -- local modes = { 'n', 'v', 'x' }
    -- for key, func in pairs(keymap) do
    --   vim.keymap.set(modes, key, func)
    -- end
    neoscroll.setup({
      mappings = { -- keys to map to their corresponding scrolling animation
        '<C-u>', '<C-d>',
        '<C-b>', '<C-f>',
        --'<C-y>', '<C-e>',
        'zt', 'zz', 'zb',
      },
      cursor_scrolls_alone = false, -- don't move cursor if window can't scroll further
      duration_multiplier = 0.70,   -- global duration multiplier
      performance_mode = true,      -- enable to use lighter hilighting while scrolling
      easing = 'sine',

      -- Disable smear-cursor during scrolling animations.
      ---@diagnostic disable-next-line: unused-local
      pre_hook = function(info)
        require('smear_cursor').enabled = false
      end,
      ---@diagnostic disable-next-line: unused-local
      post_hook = function(info)
        require('smear_cursor').enabled = true
      end
    })
  end
}
--]]

--[[
-- Here's the cinnamon-based smooth scrolling.
return {
  {
    "declancm/cinnamon.nvim",
    version = "*", -- use latest release
    opts = {
      -- change default options here
      keymaps = { basic = true },
      mode = 'window',
      --delay = 50, -- millisecond delay between steps
      max_delta = { time = 200 },
      --step_size = { vertical = 3, horizontal = 3 },
    },
  }
}
--]]

--[[
-- Here's the mini.animate-based smooth scrolling.
return {
  'echasnovski/mini.animate',
  version = '*',
  config = function()
    local anim = require('mini.animate')
    anim.setup({
      cursor = { enable = false },
      scroll = {
        -- Animate for 200 milliseconds with linear easing
        timing = anim.gen_timing.linear({ duration = 200, unit = 'total' }),

        -- Animate equally but with at most 120 steps instead of default 60
        subscroll = anim.gen_subscroll.equal({ max_output_steps = 120 }),
      }
    })
  end
}
--]]

return {}
