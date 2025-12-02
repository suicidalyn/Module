-- SaveManager.lua (wrapper - returns the Obsidian SaveManager addon for UI to use)
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
return SaveManager
