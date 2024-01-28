local M = {}
local cfg = require("hover.config").get()

local function iter_lines(str)
    local lines = {}
    for line in str:gmatch("([^\n]+)") do
        table.insert(lines, line)
    end
    return lines
end

function M.parse_highlight_inlined_text(text)
	vim.validate({
		text = { text, "string" }
	})

	local lines = {}
	local highlights = {}
	local window = {
		width = 0,
		height = 0
	}

	for i, line in ipairs(iter_lines(text)) do
		-- parse in-text XML-like color tags
		local match
		repeat
			line, match = line:gsub("(.-)<([a-zA-Z@.]+)>(.-)</>(.*)", function(before, highlight, inner, after)
				table.insert(highlights, {
					highlight,				-- highlight group name
					i - 1,					-- line number in buffer (0-indexed)
					#before,				-- start position of highlight
					#before + #inner		-- end position of highlight
				})
				return before .. inner .. after
			end)
		until match == 0

		-- store line without tag
		table.insert(lines, line)

		-- track expected window's height
		local length = #line;
		if length > cfg.window.max_width then
			window.height = window.height + math.ceil(length / cfg.window.max_width)
		else
			window.height = window.height + 1
		end

		-- track expected window's width
		if length > window.width then
			window.width = length
		end
	end

	window.width = math.min(window.width, cfg.window.max_width)

	return lines, highlights, window
end

function M.severity_to_string(severity)
	if severity == vim.diagnostic.severity.ERROR then
		return "Error"
	elseif severity == vim.diagnostic.severity.WARN then
		return "Warn"
	elseif severity == vim.diagnostic.severity.INFO then
		return "Info"
	elseif severity == vim.diagnostic.severity.HINT then
		return "Hint"
	else
		return "N/A"
	end
end

return M
