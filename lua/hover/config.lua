---
--- global configuration handler
---

local M = {}

local helper = {
	window = require("hover.helper.window"),
	action = require("hover.helper.action"),
	diagnostic = require("hover.helper.diagnostic"),
	document = require("hover.helper.document"),
}

local current = nil
local default = {
	window = {
		offset_x = 0,
		offset_y = 0,
		border = "single",
		focusable = false,
		zindex = 50,
		relative = "cursor",
		anchor_bias = "auto",

		max_width = 40,
		max_height = 5,
		min_width = 10,
		scrolloff = 2,

		on_create = { helper.window.win_set_additional_opts },
		on_update = {
			helper.window.win_update_header,
			helper.window.win_update_footer
		},
	},

	action = {
		on_start = {},
		on_stop = {},
		on_next = {},
		on_prev = {},
		on_pin = { helper.action.win_goto_top_right },
		on_unpin = { helper.action.win_goto_cursor },
		on_hide = {},
		on_scroll = { helper.action.win_update_footer }
	},

	popup_event = { "CursorHold" },
	close_event = { "CursorMoved", "CursorMovedI", "InsertEnter" },

	source = {
		diagnostic = {
			name = "diagnostic",
			enable = helper.diagnostic.enable,
			priority = 50,
			placeholder = "[loading...]",
			fetch = helper.diagnostic.fetch,
			filter = helper.diagnostic.filter,
			format = helper.diagnostic.format,
		},
		document = {
			name = "document",
			enable = helper.document.enable,
			priority = 60,
			placeholder = "[loading...]",
			fetch = helper.document.fetch
		}
	}
}

---
--- get configs
---
function M.get()
	if current == nil then
		M.set(default)
	end

	return current
end

---
--- set configs by using user-specific config to overwrite default config
---
function M.set(user_config)
	current = vim.tbl_deep_extend("force", default, user_config)
end

return M
