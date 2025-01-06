local M = {}

local state = {
	floating = {
		buf = -1,
		win = -1
	}
}

-- TODO: Allow whole numbers as well as percentages
local config = {
	session_prefix = "peek-",

	dimensions = {
		width_pct = 0.5,
		height_pct = 0.3,
	},

	position = {
		x_pos_pct = 0.5,
		y_pos_pct = 0.9
	}
}

local function create_floating_window(buf)
	local width = math.floor(vim.o.columns * config.dimensions.width_pct)
	local height = math.floor(vim.o.lines * config.dimensions.height_pct)

	local col = math.floor((vim.o.columns - width) * config.position.x_pos_pct)
	local row = math.floor((vim.o.lines - height) * config.position.y_pos_pct)

	if not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(false, true)
	end

	--- @type vim.api.keyset.win_config
	local win_conf = {
		relative = "editor",
		col = col,
		row = row,
		width = width,
		height = height,
		border = "rounded",
		style = "minimal",
		title = "Tmux Peek",
		title_pos = "center"
	}

	local win = vim.api.nvim_open_win(buf, true, win_conf)
	return { buf = buf, win = win }
end

local function attach_to_tmux()
	local tmux_var = vim.env.TMUX

	if not tmux_var then
		vim.api.nvim_err_writeln("TMUX env var not found")
		vim.api.nvim_win_hide(state.floating.win)
		return
	end

	local session = vim.split(tmux_var, ",")[3]

	local tmux_cmd = "tmux new-session -A -t " ..
		session ..
		" -s " ..
		config.session_prefix .. session

	vim.cmd.terminal(tmux_cmd)
	vim.cmd.startinsert()
end


M.setup = function(opts)
	config = vim.tbl_extend("force", config, opts)
end

M.toggle_peek = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window(state.floating.buf)
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			attach_to_tmux()
		end
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

return M
