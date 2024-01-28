local M = {}
local current = nil
local default = {
	window = {
		offset_x = 0,
		offset_y = 0,
		border = "none",
		focusable = false,
		zindex = 50,
		anchor_bias = "auto",
		max_width = 30,
		addition = {
			wrap = true,
			winblend = 20,
			winhighlight = "",
		}
	},

	popup_event = { "CursorHold" },
	close_event = { "CursorMoved", "CursorMovedI" },

	source = {
		diagnostic = {
			enabled = true,
			priority = 50,
			filter = function(diag)
				return diag.severity <= vim.diagnostic.severity.HINT
			end,
			format = function(index, diag)
				local severity = require("hover.utils").severity_to_string(diag.severity)
				return string.format("%d: <%s>%s</> [%s]\n",
					index, "DiagnosticFloating" .. severity, diag.message, severity)
			end
		}
	}
}

function M.get()
	if current == nil then
		M.set(default)
	end

	return current
end

function M.set(user_cfg)
	current = vim.tbl_deep_extend("force", default, user_cfg)
end

return M
