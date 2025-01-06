vim.api.nvim_create_user_command("TmuxPeek", function ()
	require("tmux-peek").toggle_peek()
end, {})
