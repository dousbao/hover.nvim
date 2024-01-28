local M = {}
local current = nil
local default = {
	window = {
		max_width = 15,
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
