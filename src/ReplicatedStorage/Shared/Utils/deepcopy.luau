local function deepCopy(table: {})
	local copy = {}
	for key, value in pairs(table) do
		if type(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end
	return copy
end

return deepCopy
