-- Cursor smearing animations to make large cursor movements easier to see.

local function has_env(varname)
  local val = os.getenv(varname)
  return val ~= nil and val ~= ''
end

return {
  "sphamba/smear-cursor.nvim",
  event = 'VeryLazy',

  -- Disable this plugin if using Neovide (Neovide has it built in), or if
  -- running over SSH (this plugin can be very laggy over slow SSH).
  cond = (vim.fn.exists('g:neovide') == 0 and
          not has_env('SSH_CLIENT') and
          not has_env('SSH_CONNECTION') and
          not has_env('SSH_TTY')),
  opts = {
    -- Stop animating when the smear's tail is within this distance (in
    -- characters) from the target.  Default = 0.1.
    distance_stop_animating = 1.5,
  },
}
