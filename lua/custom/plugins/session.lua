-- Automatic session saver.  Integrated with Tmux's tmux-resurrect plugin.

-- Don't bother if we're not runing inside tmux.
if os.getenv('TMUX') == nil or os.getenv('TMUX') == '' then
  return {}
end

-- Run a system command given as an array of strings, where the first item
-- is the command, and remaining items are arguments.  Return (STDOUT,
-- STDERR), where STDOUT and STDERR are the command's output to stdout and
-- stderr, respectively.
local runcmd = function(argv)
  local status = vim.system(argv, { text = true }):wait()
  if status.code ~= 0 or status.signal ~= 0 then
    error('unsuccessful runcmd("' .. argv[1] .. '"):\n' ..
      'status: ' .. status.code .. ', signal: ' .. status.signal)
  end
  local stdout = status.stdout == nil and '' or status.stdout
  local stderr = status.stderr == nil and '' or status.stderr
  return stdout, stderr
end

-- Return a filename unique to this nvim+tmux session.  Return nil if
-- unavailable (e.g., if we're not running under tmux, etc).  Loosely based
-- on [pbower's comment on tmux-resurrect issue
-- 421](https://github.com/tmux-plugins/tmux-resurrect/issues/421#issuecomment-2001890213),
-- but translated to Lua.
--
-- TODO: actually use this to make nvim "Just Work" with tmux-resurrect.
local nvim_session_filename = function()
  local ok, res = pcall(function()
    local session_id_raw = runcmd({'tmux', 'display-message', '-p', '#{session_id}'})
    session_id_raw = vim.fn.substitute(session_id_raw, '\n', '', '')
    local session_id = vim.fn.substitute(session_id_raw, '^\\$', '', '')
    local window_index = runcmd({'tmux', 'display-message', '-p', '#{window_index}'})
    window_index = vim.fn.substitute(window_index, '\n', '', '')
    local pane_index = runcmd({'tmux', 'display-message', '-p', '#{pane_index}'})
    pane_index = vim.fn.substitute(pane_index, '\n', '', '')

    -- FIXME: use a hash of vim.fn.getcwd() instead of using it directly.
    -- Using a hash will prevent errors from the path name being too long.
    local session_dir = vim.fn.stdpath('state') .. '/session/' .. vim.fn.getcwd() .. 's-'
    --local session_dir = vim.fn.getcwd() .. '/.TmuxNvimSession-'
    return session_dir .. session_id .. '-' .. window_index .. '-' .. pane_index .. '.vim'
  end)
  if ok then return res else return nil end
end

-- This just loads tpope's vim-obsession plugin, but with tweaks to work
-- with nvim.  Tweaks based on gelocraft's comment on tmux-resurrect [pull
-- request 534](https://github.com/tmux-plugins/tmux-resurrect/pull/534).
--
-- NOTE: the above pull request was intended to integrate tmux-resurrect
-- with folke's persistence.nvim plugin, but as of 2026-02-08, the PR has
-- not been merged.  After the PR gets merged, consider updating this
-- config by replacing vim-obsession with persistence.nvim.
return {
  'tpope/vim-obsession',
  enabled = true,
  --event = 'VimEnter',  -- must be loaded early to prevent errors
  init = function()
    local events
    -- Try to match vim-obsession's behavior w.r.t. g:obsession_no_bufenter
    -- per its official docs.  See :help :Obsession for details.
    if vim.g.obession_no_bufenter and vim.g.obsession_no_bufenter ~= 0 then
      events = { 'VimLeavePre', }
    else
      events = { 'VimLeavePre', 'BufEnter' }
    end
    vim.api.nvim_create_autocmd(events, {
      pattern = '*',
      group = vim.api.nvim_create_augroup('Obsession', { clear = true }),
      callback = function()
        vim.cmd 'silent Obsession! | silent Obsession'
      end,
    })
  end,
}
