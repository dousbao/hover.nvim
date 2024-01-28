local M = {}

function M.setup(user_config)
	local config = require("hover.config")
	local source = require("hover.source")

	config.set(user_config)
	for k, _ in pairs(config.get().source) do
		source.add(require("hover.source." .. k))
	end

	vim.api.nvim_create_user_command("HoverStart", "lua require('hover.action').start()", {})
	vim.api.nvim_create_user_command("HoverStop", "lua require('hover.action').stop()", {})
	vim.api.nvim_create_user_command("HoverToggle", "lua require('hover.action').toggle()", {})
	vim.api.nvim_create_user_command("HoverNext", "lua require('hover.action').next()", {})
	vim.api.nvim_create_user_command("HoverPrev", "lua require('hover.action').prev()", {})
end

return M
