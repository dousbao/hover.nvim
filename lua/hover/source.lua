local M = {}
local sources = {}

function M.add(source)
	vim.validate({
		name = { source.name, "string" },
		priority = { source.priority, "number" },
		enabled = { source.enabled, { "boolean", "number" } },
		fetch = { source.fetch, "function" }
	})

	-- existence check + ordered insert
	local pos = -1
	for i, s in ipairs(sources) do
		if source.name == s.name then
			error("duplicate source name: " .. source.name)
		elseif pos == -1 and source.priority < s.priority then
			pos = i
		end
	end

	if pos ~= -1 then
		table.insert(sources, pos, source)
	else
		table.insert(sources, source)
	end
end

function M.snapshot(filter)
	vim.validate({
		filter = { filter, "function" }
	})

	local snap = {}
	for _, s in ipairs(sources) do
		if filter(s) then
			table.insert(snap, vim.deepcopy(s))
		end
	end

	return snap
end

return M
