---
--- displayer
---

local Window = {}
Window.__index = Window

local config = require("hover.config")
local util = require("hover.util")

---
--- create a dummy window
---
function Window:monk()
	local window = setmetatable({}, self)

	window.winnr = -1
	window.bufnr = -1

	return window
end

---
--- ensure winnr and bufnr are valid. and they are bind together.
---
--- used by display() only currently. keep public for future usage
---
--- @param win_size table window's size. used by make_floating_popup_options
--- @param ... any extra arguments for on_create
---
function Window:open(win_size, ...)
	-- create buffer if not exist
	if not vim.api.nvim_buf_is_valid(self.bufnr) then
		self.bufnr = vim.api.nvim_create_buf(false, {})
	end

	-- create window if not exist
	if not vim.api.nvim_win_is_valid(self.winnr) then
		self.winnr = vim.api.nvim_open_win(
			self.bufnr, false,
			vim.lsp.util.make_floating_popup_options(
				win_size.width, win_size.height, config.get().window
			)
		);

		-- signal window create
		util.invoke_funcs(config.get().window.on_create, self:pack(), ...)
	end

	-- ensure correct window/buffer binding
	if vim.api.nvim_win_get_buf(self.winnr) ~= self.bufnr then
		vim.api.nvim_win_set_buf(self.winnr, self.bufnr)
	end
end

---
--- close bufnr/winnr
---
function Window:close()
	if vim.api.nvim_win_is_valid(self.winnr) then
		vim.api.nvim_win_close(self.winnr, true)
		self.winnr = -1
	end

	if vim.api.nvim_buf_is_valid(self.bufnr) then
		vim.api.nvim_buf_delete(self.bufnr, { force = true })
		self.bufnr = -1
	end
end

---
--- scroll window
---
function Window:scroll(scroll_by)
	vim.validate({
		text = { scroll_by, "number" }
	})

	local row, col = unpack(vim.api.nvim_win_get_cursor(self.winnr))
	local max_row = vim.api.nvim_buf_line_count(self.bufnr)

	vim.api.nvim_win_set_cursor(self.winnr, {
		math.max(1, math.min(row + scroll_by, max_row)), col
	})
end

---
--- determine whether window is valid
---
--- @return boolean
---
function Window:is_valid()
	return vim.api.nvim_win_is_valid(self.winnr) and
		vim.api.nvim_buf_is_valid(self.bufnr)
end

---
--- pack useful data of window
---
function Window:pack()
	return {
		winnr = self.winnr,
		bufnr = self.bufnr
	}
end

---
--- display a highlight-group-inlined text.
---
--- no need to call open() before. since will automatically try
--- to open() anyway.
---
--- when input empty/nil text, window will be closed.
---
--- @param text string|nil highlight-group-inlined text
--- @param ... any data that on_update might be insterested in
---
function Window:display(text, ...)
	vim.validate({
		text = { text, { "string", "nil" } }
	})

	-- close window on empty input
	if text == nil or text == "" then
		self:close()
		return
	end

	local lines, highlights, win_size = util.parse_highlight_inlined_text(text)

	self:open(win_size, ...)

	vim.api.nvim_win_set_width(self.winnr, win_size.width)
	vim.api.nvim_win_set_height(self.winnr, win_size.height)
	vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
	for _, v in ipairs(highlights) do
		vim.api.nvim_buf_add_highlight(self.bufnr, -1, v[1], v[2], v[3], v[4])
	end

	-- signal window update
	util.invoke_funcs(config.get().window.on_update, self:pack(), ...)
end

return Window
