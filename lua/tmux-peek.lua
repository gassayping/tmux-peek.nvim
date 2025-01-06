local M = {}

local state = {
	floating = {
		buf = -1,
		win = -1
	}
}

local config = {
	session_prefix = "peek-",

	dimensions = {
		width = 0.5,
		height = 0.3,
		col = 0.5,
		row = 0.9
	}
}

local function get_pos_and_size(opts)
	local out = {}
	opts = vim.tbl_extend('force', config.dimensions, opts)
	print(vim.inspect(opts))

	if opts.width < 1 or opts.height < 1 then
		if not (opts.width < 1 and opts.height < 1) then
			vim.api.nvim_err_writeln("Width and height must both be percentages or exact")
			return nil
		end
		out.width = math.floor(vim.o.columns * opts.width)
		out.height = math.floor(vim.o.lines * opts.height)
	else
		out.width = opts.width
		out.height = opts.height
	end

	if opts.row < 1 or opts.col < 1 then
		if not (opts.row < 1 and opts.col < 1) then
			vim.api.nvim_err_writeln("Row and col must both be percentages or exact")
			return nil
		end
		out.col = math.floor((vim.o.columns - out.width) * opts.col)
		out.row = math.floor((vim.o.lines - out.height) * opts.row)
	else
		out.col = opts.col
		out.row = opts.row
	end

	return out
end

local function create_floating_window(buf)
	local dimensions = get_pos_and_size({})
	if dimensions == nil then
		return
	end

	if not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(false, true)
	end

	--- @type vim.api.keyset.win_config
	local win_conf = {
		relative = "editor",
		col = dimensions.col,
		row = dimensions.row,
		width = dimensions.width,
		height = dimensions.height,
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
		vim.cmd.startinsert()
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

return M
