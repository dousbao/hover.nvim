---
--- session info manager
---
--- period between popup_event and close_event is a session
---

local Session = {}
local next_session_id = 0
Session.__index = Session

---
---	create a dead dummy session
---
function Session:monk()
	local session = setmetatable({}, self)
	session.alive = false
	return session
end

---
--- create a usable session, which keeps
--- dead until self:start is called
---
--- @param env table autocmd triggered environment table
--- @return table session
---
function Session:new(env)
	local session = setmetatable({}, self)

	session.env = env										-- used by sources' fetch()
    session.sources = require("hover.source").get(env)		-- enabled sources. env is passed to sources' enable()
    session.contents = {}									-- will be filled by start()
    session.active_index = 1								-- index which contents[index] is always non-empty 
															-- as long as there exist non-empty slot
    session.id = next_session_id							-- avoid ABA. see start()
    session.alive = false

	next_session_id = next_session_id == math.maxinteger
		and 0 or next_session_id + 1

	return session
end

---
--- start a session.
--- to be more specific, start asynchronous fetching content 
--- from sources, and store them into contents.
---
--- @param on_new_content function callback on new content(s) recieved.
---
function Session:start(on_new_content)
	self.alive = true

	for i, src in ipairs(self.sources) do
		self.contents[i] = {
			value = src.placeholder,
			src_index = i
		}

		require("plenary.async").run(function()
			local old_session_id = self.id
			local ok, result = pcall(src.fetch, self.env)
			if not ok then
				vim.notify("error fetching content: " .. tostring(result), vim.log.levels.ERROR)
				result = {}
			end

			vim.schedule(function()
				-- do nothing when result out-dated
				if self.alive == false or self.id ~= old_session_id then
					return
				end

				-- compute start index
				local start_index = 1
				for j, content in ipairs(self.contents) do
					if content.src_index == i then
						start_index = j
						break
					end
				end

				-- update contents and invoke callback
				if vim.tbl_isempty(result) then
					self.contents[start_index].value = ""

					if self.active_index == start_index then
						self:goto_next_active()
					end

					on_new_content(self:get_current_active_content(), self:pack())
				else
					self.contents[start_index].value = result[1]
					for j = 2, #result do
						table.insert(self.contents, start_index + j - 1, {
							value = result[j],
							src_index = i
						})
					end

					if self.active_index > start_index then
						self.active_index = self.active_index + #result - 1
					elseif self.active_index == start_index then
						if self.contents[start_index].value == "" then
							self:goto_next_active()
						end

						on_new_content(self:get_current_active_content(), self:pack())
					end
				end
			end)
		end)
	end
end

---
--- terminate session
---
function Session:terminate()
    self.env = nil
    self.sources = {}
    self.contents = {}
    self.active_index = 0
    self.id = -1
    self.alive = false
end

---
--- determine whether session is alive
---
--- @return boolean
---
function Session:is_alive()
    return self.alive
end

---
--- get current active content
--- always return non-empty string as long as there exist any
---
--- @return string|nil
---
function Session:get_current_active_content()
	if self.active_index == 0 then
		return nil
	else
		return self.contents[self.active_index].value
	end
end

---
--- modify active_index. goto next non-empty slot
---
function Session:goto_next_active()
    local index = self.active_index
    local start_index = index

    while true do
        index = self.contents[index + 1] == nil and 1 or index + 1

        if self.contents[index].value ~= "" then
            self.active_index = index
            break
        elseif index == start_index then
            self.active_index = 0
            break
        end
    end
end

---
--- modify active_index. goto previous non-empty slot
---
function Session:goto_prev_active()
	local index = self.active_index
	local start_index = index

	while true do
		index = index == 1
			and #self.contents or index - 1

		if self.contents[index].value ~= "" then
			self.active_index = index
			break
		elseif index == start_index then
			self.active_index = 0
			break
		end
	end
end

---
--- pack useful information on session
---
--- @return table
---
function Session:pack()
	if self.active_index == 0 then
		return {}
	end

	local src_index = self.contents[self.active_index].src_index

    return {
        name = self.sources[src_index].name,
        priority = self.sources[src_index].priority,
        index = self.active_index,
        size = #self.contents,
        env = self.env,
    }
end

return Session
