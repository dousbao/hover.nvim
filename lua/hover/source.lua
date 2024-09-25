---
--- maintain an priority-based ordered sequence of sources,
--- and provide method to extract currently enabled sources
---

local M = {}
local sources = {}

for _, src in pairs(require("hover.config").get().source) do
	vim.validate({
		name = { src.name, "string" },
		priority = { src.priority, "number" },
		enable = { src.enable, { "boolean", "function" } },
		placeholder = { src.placeholder, "string" },
		fetch = { src.fetch, "function" }
	})

	-- ordered insert
	local pos = -1
	for i, s in ipairs(sources) do
		if src.name == s.name then
			error("duplicate source name: " .. src.name)
		elseif pos == -1 and src.priority < s.priority then
			pos = i
		end
	end

	if pos ~= -1 then
		table.insert(sources, pos, src)
	else
		table.insert(sources, src)
	end
end

---
--- get enabled sources in priority-based order
---
--- @param ... any data that enable() might be insterested in
--- @return table
---
function M.get(...)
	local result = {}

	for _, src in ipairs(sources) do
		if (type(src.enable) == "boolean" and src.enable or src.enable(...)) then
			table.insert(result, src)
		end
	end

	return result
end

return M
