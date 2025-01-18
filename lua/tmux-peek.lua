local M = {}

local state = {
	floating = {
		buf = -1,
		win = -1
	}
}

---@class tmux_peek_config
---@field session_prefix? string
---@field win_config?  vim.api.keyset.win_config

---@type tmux_peek_config
local config = {
	session_prefix = "peek-",

	win_config = {
		width = 0.5,
		height = 0.3,
		col = 0.5,
		row = 0.9,
		relative = "editor",
		border = "rounded",
		style = "minimal",
		title = "Tmux Peek",
		title_pos = "center"
	}
}

local function get_pos_and_size(opts)
	local out = {}

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
		out.col = math.floor(vim.o.columns * opts.col)
		out.row = math.floor(vim.o.lines * opts.row)
	else
		out.col = opts.col
		out.row = opts.row
	end

	return out
end

local function create_floating_window(buf, win_config)
	local dimensions = get_pos_and_size(win_config)
	if dimensions == nil then
		return
	end

	for key, value in pairs(dimensions) do
		win_config[key] = value
	end

	if not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win = vim.api.nvim_open_win(buf, true, win_config)
	return { buf = buf, win = win }
end

local function attach_to_tmux(prefix, session)
	if not session then
		local tmux_var = vim.env.TMUX
		if not tmux_var then
			vim.api.nvim_err_writeln("TMUX env var not found")
			vim.api.nvim_win_hide(state.floating.win)
			return
		end

		session = vim.split(tmux_var, ",")[3]
	end

	local tmux_cmd = "tmux new-session -A -t " ..
		session ..
		" -s " ..
		prefix .. session

	vim.cmd.terminal(tmux_cmd)
end


--- Set plugin config options
---@param opts tmux_peek_config
M.setup = function(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
end

--- Toggles the peek window
---@param opts tmux_peek_config Options for setting up the window
M.toggle_peek = function(opts, tmux_session)
	opts = vim.tbl_deep_extend("keep", opts or {}, config)

	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window(state.floating.buf, opts.win_config)

		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			attach_to_tmux(opts.session_prefix, tmux_session)
		end
		vim.cmd.startinsert()
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

return M
