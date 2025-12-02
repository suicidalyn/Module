-- main.lua
local BASE = "https://raw.githubusercontent.com/suicidalyn/Module/refs/heads/main/"

local loaded = {}

local function safeSetClipboard(t)
	pcall(function()
		if type(setclipboard) == "function" or type(setclipboard) == "userdata" then
			setclipboard(tostring(t))
		end
	end)
end

local function httpGet(url)
	local ok, res = pcall(function() return game:HttpGet(url) end)
	if not ok then
		safeSetClipboard("HttpGet error: "..tostring(res))
		return nil
	end
	return res
end

local function runString(src, name)
	local fn, loadErr = loadstring(src)
	if not fn then
		safeSetClipboard(("loadstring %s error: %s"):format(tostring(name), tostring(loadErr)))
		return nil
	end
	local ok, res = pcall(fn)
	if not ok then
		safeSetClipboard(("runtime %s error: %s"):format(tostring(name), tostring(res)))
		return nil
	end
	return res
end

local function replaceLoadfileESPinUI(src)
	src = src:gsub('loadfile%(%s*["\'][^"\']*ESP[^"\']*["\']%s*%)%s*%(%s*%)', "_G.__ESP")
	src = src:gsub('loadfile%(%s*["\'][^"\']*ESP[^"\']*["\']%s*%)', "_G.__ESP")
	return src
end

local esp_files = {
	"init.lua",      
	"Boxes.lua",
	"Tracers.lua",
	"Skeleton.lua",
	"HeadDot.lua",
	"ToolESP.lua",
	"Health.lua",
	"Names.lua",
	"Utils.lua"
}

local function fetchSaveManager()
	local src = httpGet(BASE .. "SaveManager.lua")
	if not src then return end
	local sm = runString(src, "SaveManager.lua")
	if sm then loaded["SaveManager.lua"] = sm end
end

local function fetchESPParts()
	local parts = {}
	for _,fname in ipairs(esp_files) do
		local path = "ESP/" .. fname
		local src = httpGet(BASE .. path)
		if src then
			parts[fname] = src
		end
	end
	return parts
end

local function makeRequireFromParts(parts)
	local cache = {}
	local function requireESP(name)
		if not name then return nil end
		name = tostring(name)
		if not name:match("%.lua$") then name = name .. ".lua" end
		name = name:gsub("^.*/","") -- strip directories, yoo thats sussy boiiii
		if cache[name] then return cache[name] end
		local src = parts[name]
		if not src then return nil end
		local mod = runString(src, "ESP/"..name)
		cache[name] = mod
		return mod
	end
	return requireESP
end

local function fetchAndLoadESP()
	local parts = fetchESPParts()
	if not parts or not parts["init.lua"] then
		safeSetClipboard("ESP init.lua not found in repo/ESP/")
		return nil
	end
	_G.__ESP_REQUIRE = makeRequireFromParts(parts)
	local mod = runString(parts["init.lua"], "ESP/init.lua")
	if mod and type(mod) == "table" then
		_G.__ESP = mod
		loaded["ESP"] = mod
		return mod
	end
	return nil
end

local function fetchAndRunUI()
	local src = httpGet(BASE .. "UI.lua")
	if not src then return nil end
	local processed = replaceLoadfileESPinUI(src)
	local ui = runString(processed, "UI.lua")
	if ui then loaded["UI.lua"] = ui end
	return ui
end

local function loadAll()
	loaded = {}
	fetchSaveManager()
	fetchAndLoadESP()
	fetchAndRunUI()
	return loaded
end

local function reloadAll()
	pcall(function() _G.__ESP = nil; _G.__ESP_REQUIRE = nil end)
	for k in pairs(loaded) do loaded[k] = nil end
	return loadAll()
end

local result = loadAll()

return {
	loaded = loaded,
	reload = reloadAll,
	base = BASE
}
