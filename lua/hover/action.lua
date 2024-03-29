local cfg = require("hover.config").get()
local global = require("hover.global")
local window = require("hover.window")
local M = {}

local sources = nil
local active_index = 0
local recover_au_id = 0

local function enabled_only(src)
	if type(src.enabled) == "boolean" then
		return src.enabled
	else
		return src.enabled()
	end
end

local function on_popup(env)
	if not vim.tbl_isempty(sources) then
		local fetched_sources = {}

		for i, src in ipairs(sources) do
			local ok, texts = pcall(src.fetch, env)
			if ok and texts ~= "" then
				window.overwrite_buf(src.name, texts)
				table.insert(fetched_sources, src)
			end
		end

		sources = fetched_sources

		if not vim.tbl_isempty(sources) then
			active_index = 1
			window.display_buf(sources[active_index].name)
		else
			active_index = 0
		end
	end

	recover_au_id = vim.api.nvim_create_autocmd(cfg.close_event, {
		pattern = "*",
		group = global.get_augroup(),
		once = true,
		callback = function()
			if sources ~= nil then
				sources = nil
				M.start()
			end
		end
	})
end

function M.start()
	vim.api.nvim_create_autocmd(cfg.popup_event, {
		pattern = "*",
		group = global.get_augroup(),
		once = true,
		callback = function(env)
			if sources == nil then
				sources = require("hover.source").snapshot(enabled_only)
				on_popup(env)
			end
		end
	})
end

function M.next()
	if sources == nil then
		return
	end

	active_index = sources[active_index + 1] == nil
		and 1 or active_index + 1

	window.display_buf(sources[active_index].name)
end

function M.prev()
	if sources == nil then
		return
	end

	active_index = active_index == 1
		and #sources or active_index - 1

	window.display_buf(sources[active_index].name)
end

function M.stop()
	if sources ~= nil then
		vim.api.nvim_del_autocmd(recover_au_id)
		sources = nil
	end
end

function M.toggle()
	if sources == nil then
		M.start()
	else
		M.stop()
	end
end

return M
