-- Clear messages at the bottom of the screen after a timeout.
local msg_timeout_clear_ms = 3000 -- milliseconds to wait before clearing
local general_settings_group =
  vim.api.nvim_create_augroup('General settings', { clear = true })
local timer = nil

vim.api.nvim_create_autocmd({'CursorHold', 'ModeChanged'}, {
  callback = function()
    if (timer ~= nil) then
      timer:stop()
    end
    timer = vim.uv.new_timer()
    timer:start(msg_timeout_clear_ms, 0, vim.schedule_wrap(function()
      print("\n")
    end))
  end,
  group = general_settings_group,
})
return {}
