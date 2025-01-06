# `tmux-peek.nvim`

Quickly access a tmux window without changing windows. Inspired by tj's `floaterminal` in [advent-of-nvim](https://github.com/tjdevries/advent-of-nvim)

## Usage

`:TmuxPeek` opens a floating window with the leftmost tmux window opened.

## Installation

For `lazy.nvim`

```lua
{
    "gassayping/tmux-peek.nvim",
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
    },
    position = {
        x_pos_pct = 0.5,
        y_pos_pct = 0.9
    }
})
```
