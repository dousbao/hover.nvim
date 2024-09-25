---
--- contains core operation's definition
---

local M = {}

local session = require("hover.session")
local config = require("hover.config")
local window = require("hover.window")
local util = require("hover.util")

local ss = session:monk()
local win = window:monk()

---
--- active hover.
--- will try to start a session and 
--- restart once previous session terminated
---
function M.start()
	vim.api.nvim_create_autocmd(config.get().popup_event, {
		pattern = "*",
		group = "dousbao/hover.nvim",
		once = true,
		callback = function(env)
			if not ss:is_alive() then
				ss = session:new(env)

				ss:start(function(...) win:display(...) end)	-- display recieved content
				win:display(ss:get_current_active_content(), ss:pack())		-- display placeholder while waiting

				-- terminate session on close_event and register autocmds 
				-- which wait for popup_event and then start another session
				vim.api.nvim_create_autocmd(config.get().close_event, {
					pattern = "*",
					group = "dousbao/hover.nvim",
					once = true,
					callback = function()
						if ss:is_alive() then
							ss:terminate()
							win:close()
							M.start()
						end
					end
				})

				util.invoke_funcs(config.get().action.on_start, win:pack(), ss:pack())
			end
		end
	})
end

---
--- stop hover.
---
--- terminate any alive session
--- close any valid window/buffer
--- delete any registered autocmds
---
function M.stop()
	if ss:is_alive() then
		util.invoke_funcs(config.get().action.on_stop, win:pack(), ss:pack())

		ss:terminate()
		win:close()

		local aucmds = vim.api.nvim_get_autocmds({
			group = "dousbao/hover.nvim",
		})

		if not vim.tbl_isempty(aucmds) then
			for _, aucmd in ipairs(aucmds) do
				vim.api.nvim_del_autocmd(aucmd.id)
			end
		end
	end
end

---
--- toggle hover.
---
function M.toggle()
	if ss:is_alive() then
		M.stop()
	else
		M.start()
	end
end

---
--- display next valid content
---
function M.next()
	if win:is_valid() then		-- if window is valid, then session must be alive
		ss:goto_next_active()
		win:display(ss:get_current_active_content(), ss:pack())
		util.invoke_funcs(config.get().action.on_next, win:pack(), ss:pack())
	end
end

--- 
--- display previous valid content
---
function M.prev()
	if win:is_valid() then		-- if window is valid, then session must be alive
		ss:goto_prev_active()
		win:display(ss:get_current_active_content(), ss:pack())
		util.invoke_funcs(config.get().action.on_prev, win:pack(), ss:pack())
	end
end

---
--- pause hover if session is alive and there exist something to display
---
--- will holds all registered autocmds, hijack their callbacks, and invoke them
--- once User event is triggered with 'unpin' pattern
---
function M.pin()
	if win:is_valid() then		-- if window is valid, then session must be alive
		util.hold_events_until(config.get().close_event, "unpin")
		util.invoke_funcs(config.get().action.on_pin, win:pack(), ss:pack())
	end
end

---
--- continue if hover is paused. otherwise has no effect
---
function M.unpin()
	if ss:is_alive() then
		vim.api.nvim_exec_autocmds("User", {
			group = "dousbao/hover.nvim",
			pattern = "unpin"
		})

		util.invoke_funcs(config.get().action.on_unpin, win:pack(), ss:pack())
	end
end

---
--- hide (close) window for current session
---
--- useful when want to close window without terminate session
---
function M.hide()
	if win:is_valid() then
		util.invoke_funcs(config.get().action.on_hide, win:pack(), ss:pack())
		win:close()
	end
end

--- 
--- scroll up
---
function M.scroll_up()
	if win:is_valid() then
		win:scroll(-config.get().window.scrolloff)
		util.invoke_funcs(config.get().action.on_scroll, win:pack(), ss:pack())
	end
end

--- 
--- scroll down
---
function M.scroll_down()
	if win:is_valid() then
		win:scroll(config.get().window.scrolloff)
		util.invoke_funcs(config.get().action.on_scroll, win:pack(), ss:pack())
	end
end

return M
