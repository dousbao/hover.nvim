local cfg = require("hover.config").get()
local M = {}

M.name = "diagnostic"
M.priority = cfg.source.diagnostic.priority
M.enabled = cfg.source.diagnostic.enabled or function()
	return not vim.diagnostic.is_disabled()
end
M.fetch = function(env)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line_diags = vim.diagnostic.get(env.buf, { lnum = cursor[1] - 1 })

	local cursor_diags = {}
	for _, d in ipairs(line_diags) do
		if d.col <= cursor[2] and cursor[2] < d.end_col then
			if cfg.source.diagnostic.filter(d) then
				table.insert(cursor_diags, d)
			end
		end
	end

	local result = ""
	for i, d in ipairs(cursor_diags) do
		result = result .. cfg.source.diagnostic.format(i, d)
	end

	return result
end

return M
