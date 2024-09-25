---
--- window config helper
---

local M = {}

function M.win_set_additional_opts(w)
	local opts = {
		wrap = true,
		winblend = 20,
	}

	for k, v in pairs(opts) do
		vim.api.nvim_win_set_option(w.winnr, k, v)
	end
end

function M.win_update_header(w, s)
	vim.api.nvim_win_set_config(w.winnr, {
		title = " " .. s.name .. " ",
		title_pos = "left"
	})
end

function M.win_update_footer(w, s)
	local footer = " [" .. s.index .. "/" .. s.size .. "] "
	vim.api.nvim_win_set_config(w.winnr, {
		footer = footer,
		footer_pos = "right"
	})
end


return M
