---
--- document config helper
---

local M = {}

local buf_request_async = require("plenary.async").wrap(function(bufnr, method, params, callback)
	vim.lsp.buf_request_all(bufnr, method, params, callback)
end, 4)

function M.enable(env)
	return #vim.lsp.get_clients({ method = "textDocument/hover" }) ~= 0
end

function M.fetch(env)
	local responses = buf_request_async(
		env.buf, "textDocument/hover",
		vim.lsp.util.make_position_params()
	)

	local result = {}

	for _, response in ipairs(responses) do
		if not vim.tbl_isempty(response) then
			local lines = vim.lsp.util.convert_input_to_markdown_lines(
				response.result.contents.value
			)

			table.insert(result, table.concat(lines, '\n'))
		end
	end

	return result
end

return M
