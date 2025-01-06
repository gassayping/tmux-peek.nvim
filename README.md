# `tmux-peek.nvim`

Get a view into a tmux window without leaving neovim. Useful for referencing your code as you read errors. Inspired by tj's `floaterminal` in [advent-of-nvim](https://github.com/tjdevries/advent-of-nvim)

## Usage

`:TmuxPeek` opens a floating window with the leftmost tmux window opened.

`tmux-peek.nvim` uses terminal mode. When in terminal mode, use `<C-\><C-N>` to exit insert mode. *Use `:h terminal` for more information on terminal mode.*

⚠️ Using `tmux-peek.nvim` to open the same tmux window that neovim is open in will cause resizing issues

## Installation

For `lazy.nvim`

```lua
{
    "gassayping/tmux-peek.nvim",
    opts = {}
}
```

`:TmuxPeek` will automatically be made available

## Configuration

These are the default configuration options

```lua
require("tmux-peek").setup({
    session_prefix = "peek-",
    dimensions = {
        width_pct = 0.5,
        height_pct = 0.3,
        col = 0.5,
        row = 0.9
    }
})
```

It is recommended to add a keymap to easily toggle the floating tmux window

```lua
vim.keymap.set({ "n", "t" }, "<leader>tp", "<cmd>TmuxPeek<CR>", { desc = "Toggle floating tmux window" })
```

