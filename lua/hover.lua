local M = {}

function M.setup(user_config)
	require("hover.config").set(user_config)

	vim.api.nvim_create_augroup("dousbao/hover.nvim", { clear = true })
	vim.api.nvim_create_user_command("DSHoverStart", "lua require('hover.action').start()", {})
	vim.api.nvim_create_user_command("DSHoverStop", "lua require('hover.action').stop()", {})
	vim.api.nvim_create_user_command("DSHoverToggle", "lua require('hover.action').toggle()", {})
	vim.api.nvim_create_user_command("DSHoverNext", "lua require('hover.action').next()", {})
	vim.api.nvim_create_user_command("DSHoverPrev", "lua require('hover.action').prev()", {})
	vim.api.nvim_create_user_command("DSHoverPin", "lua require('hover.action').pin()", {})
	vim.api.nvim_create_user_command("DSHoverUnpin", "lua require('hover.action').unpin()", {})
	vim.api.nvim_create_user_command("DSHoverHide", "lua require('hover.action').hide()", {})
	vim.api.nvim_create_user_command("DSHoverScrollUp", "lua require('hover.action').scroll_up()", {})
	vim.api.nvim_create_user_command("DSHoverScrollDown", "lua require('hover.action').scroll_down()", {})
end

return M
