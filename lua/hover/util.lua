---
--- some robust util functions
---

local M = {}

local config = require("hover.config")

---
--- seperate a highlight-inlined text line by line
--- extract any highlight notation (<Highlight></>)
--- compute appropriate window size to display contents
---
--- @param text string highlight-inlined text
--- @return table lines, table highlights, table win_size
---
function M.parse_highlight_inlined_text(text)

	--- seperate a str line by line
	local function iter_lines(str)
		local lines = {}
		for line in str:gmatch("([^\n]+)") do
			table.insert(lines, line)
		end
		return lines
	end

	vim.validate({
		text = { text, "string" }
	})

	local lines = {}
	local highlights = {}
	local win_size = {
		width = 0,
		height = 0
	}

	local stack = {}

	for i, line in ipairs(iter_lines(text)) do
		local tmp = #highlights

		-- parse in-text XML-like color tags
		local match
		repeat
			line, match = line:gsub("(.-)<([a-zA-Z@.]+)>(.-)</>(.*)", function(before, highlight, inner, after)
				if #stack ~= 0 then
					error("tag '" .. highlight .. "' overlapped with tag '" .. stack[#stack] .. "'")
				end

				table.insert(highlights, {
					highlight,				-- highlight group name
					i - 1,					-- line number in buffer (0-indexed)
					#before,				-- start position of highlight
					#before + #inner		-- end position of highlight
				})
				return before .. inner .. after
			end)
		until match == 0

		repeat
			line, match = line:gsub("(.-)<([a-zA-Z@.]+)>(.*)", function(before, highlight, after)
				if #stack ~= 0 then
					error("tag '" .. highlight "' overlapped with tag '" .. stack[#stack] "'")
				end
				
				table.insert(stack, highlight)
				table.insert(highlights, {
					highlight,
					i - 1,
					#before,
					-1
				})
				return before .. after
			end)
		until match == 0

		repeat
			line, match = line:gsub("(.-)</>(.*)", function(before, after)
				local highlight = table.remove(stack)
				if highlight == nil then
					error("unmatched closing tag '</>' at line " .. i .. ", position " .. #before)
				end

				table.insert(highlights, {
					highlight,
					i - 1,
					0,
					#before,
				})

				return before .. after
			end)
		until match == 0

		if #highlights == tmp and #stack ~= 0 then
			table.insert(highlights, {
				stack[#stack],
				i - 1,
				0,
				-1
			})
		end

		-- store line without tag
		table.insert(lines, line)

		-- track expected window's height
		local length = #line;
		if length > config.get().window.max_width then
			win_size.height = win_size.height + math.ceil(length / config.get().window.max_width)
		else
			win_size.height = win_size.height + 1
		end

		-- track expected window's width
		if length > win_size.width then
			win_size.width = length
		end
	end

	if #stack ~= 0 then
		error("unclosed highligh group: " .. stack[#stack])
	end

	win_size.width = math.max(config.get().window.min_width, math.min(win_size.width, config.get().window.max_width))
	win_size.height = math.min(win_size.height, config.get().window.max_height)

	return lines, highlights, win_size
end

--- 
--- hijack autocmds belongs to events
---  
--- when User with resume_pattern is triggered,
--- restore hijacked autocmds
---
--- @param events string|table events
--- @param resume_pattern string User event's pattern
---
function M.hold_events_until(events, resume_pattern)
	local aucmds = vim.api.nvim_get_autocmds({
		group = "dousbao/hover.nvim",
		event = events,
	})

	if not vim.tbl_isempty(aucmds) then
		for _, aucmd in ipairs(aucmds) do
			vim.api.nvim_del_autocmd(aucmd.id)
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = resume_pattern,
			group = "dousbao/hover.nvim",
			once = true,
			callback = function()
				for _, aucmd in ipairs(aucmds) do
					vim.api.nvim_create_autocmd(aucmd.event, {
						pattern = aucmd.pattern,
						group = aucmd.group,
						once = aucmd.once,
						callback = aucmd.callback
					})
				end
			end
		})
	end

end

--- 
--- invoke a list of functions (callback)
---
--- @param funcs table list of functions
--- @param ... any common paramaters for funcs
---
function M.invoke_funcs(funcs, ...)
	vim.validate({
		callbacks = { funcs, "table" }
	})

	for _, func in ipairs(funcs) do
		func(...)
	end
end

return M
