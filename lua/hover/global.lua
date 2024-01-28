local M = {}

local namespace = vim.api.nvim_create_namespace("dousbao/hover.nvim")
local augroup = vim.api.nvim_create_augroup("dousbao/hover.nvim", { clear = true })

function M.get_namespace()
	return namespace
end

function M.get_augroup()
	return augroup
end

return M
