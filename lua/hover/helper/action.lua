---
--- action config helper
---

local M = {}

function M.win_goto_top_right(w)
	vim.api.nvim_win_set_config(w.winnr, {
		relative = "win",
		row = 1,
		col = vim.api.nvim_win_get_width(0),
	})
end

function M.win_update_footer(w, s)
	require("hover.helper.window").win_update_footer(w, s)
end

function M.win_goto_cursor(w)
	vim.api.nvim_win_set_config(w.winnr, {
		relative = "cursor",
		row = 1,
		col = 0
	})
end

return M
