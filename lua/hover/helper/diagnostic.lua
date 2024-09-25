---
--- diagnostic config helper
---

local M = {}

function M.enable()
	return not vim.diagnostic.is_disabled()
end

function M.filter(diag)
	return diag.severity <= vim.diagnostic.severity.HINT
end

function M.format(diag)
	local severity = {
		[vim.diagnostic.severity.HINT] = "Hint",
		[vim.diagnostic.severity.INFO] = "Info",
		[vim.diagnostic.severity.WARN] = "Warn",
		[vim.diagnostic.severity.ERROR] = "Error",
	}

	return string.format("<%s>%s</>\n",
		"DiagnosticFloating" .. severity[diag.severity], diag.message, severity[diag.severity])
end

function M.fetch(env)
	local config = require("hover.config")
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line_diags = vim.diagnostic.get(env.buf, { lnum = cursor[1] - 1 })

	local cursor_diags = {}
	for _, d in ipairs(line_diags) do
		if d.col <= cursor[2] and cursor[2] < d.end_col then
			if config.get().source.diagnostic.filter(d) then
				table.insert(cursor_diags, d)
			end
		end
	end

	local result = {}
	for _, d in ipairs(cursor_diags) do
		table.insert(result, config.get().source.diagnostic.format(d))
	end

	return result
end

return M
