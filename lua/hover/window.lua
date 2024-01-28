local cfg = require("hover.config").get()
local global = require("hover.global")
local M = {}

local buffers = {}
local winnr = 0

function M.make_buf(name)
	vim.validate({
		name = { name, "string" }
	})

	buffers[name] = {
		bufnr = vim.api.nvim_create_buf(false, {}),
		window = { width = 0, height = 0 }
	}
end

function M.overwrite_buf(name, text)
    vim.validate({
        name = { name, "string" },
        text = { text, "string" }
    })

	local buf = buffers[name]
	if buf == nil then
		error("overwrite nonexistent buffer: " .. name)
	end

	-- erase exist content
	if buf.window.width ~= 0 and buf.window.height ~= 0 then
		vim.api.nvim_buf_set_lines(buf.bufnr, 0, -1, false, {})
	end

	-- decode and rewrite
	local lines, highlights, window = require("hover.utils").parse_highlight_inlined_text(text)

	buf.window = window
	vim.api.nvim_buf_set_lines(buf.bufnr, 0, #lines, false, lines)
	for _, v in ipairs(highlights) do
		vim.api.nvim_buf_add_highlight(buf.bufnr, global.get_namespace(), v[1], v[2], v[3], v[4])
	end
end

function M.display_buf(name)
	vim.validate({
		name = { name, "string" }
	})

	local buf = buffers[name]
	if buf == nil then
		error("display nonexistent buffer: " .. name)
	end

	-- create window if noexistent
	if winnr == 0 then
		winnr = vim.api.nvim_open_win(0, false,
			vim.lsp.util.make_floating_popup_options(buf.window.width, buf.window.height, cfg.window))

		for k, v in pairs(cfg.window.addition) do
			vim.api.nvim_win_set_option(winnr, k, v)
		end

		vim.api.nvim_create_autocmd(cfg.close_event, {
			pattern = "*",
			group = global.get_augroup(),
			once = true,
			callback = function()
				if winnr ~= 0 then
					vim.api.nvim_win_hide(winnr)
					winnr = 0
				end
			end
		})
	end

	if not vim.api.nvim_win_is_valid(winnr) then
		error("unknown error, " .. winnr .. " closed by external codes")
	end

	vim.api.nvim_win_set_buf(winnr, buf.bufnr)
	vim.api.nvim_win_set_width(winnr, buf.window.width)
	vim.api.nvim_win_set_height(winnr, buf.window.height)
end

return M
