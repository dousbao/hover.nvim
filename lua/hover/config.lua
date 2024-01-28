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
		max_width = 15,
		addition = {
			wrap = true,
			winblend = 20,
			winhighlight = "",
		}
	},

	popup_event = { "CursorHold" },
	close_event = { "CursorMoved", "CursorMovedI" },
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
