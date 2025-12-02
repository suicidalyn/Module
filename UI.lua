-- UI.lua
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local BASE = "https://raw.githubusercontent.com/suicidalyn/Module/refs/heads/main/"

local function httpGet(url)
	local ok, res = pcall(function() return game:HttpGet(url) end)
	if ok then return res end
	return nil
end

local Library = nil
local ok, lib = pcall(function() return loadstring(game:HttpGet(repo .. "Library.lua"))() end)
if ok and lib then Library = lib end
if not Library then error("failed to load Obsidian Library") end

local SaveManager = nil
local ok2, sm = pcall(function() return loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))() end)
if ok2 and sm then SaveManager = sm end

local ESP = _G.__ESP
if not ESP then
	local esp_src = httpGet(BASE .. "ESP.lua")
	if esp_src then
		local fn, err = loadstring(esp_src)
		if fn then
			local ok3, mod = pcall(fn)
			if ok3 and type(mod) == "table" then
				ESP = mod
				_G.__ESP = mod
			end
		end
	end
end
if not ESP then error("failed to obtain ESP module") end

if SaveManager and type(SaveManager.SetLibrary) == "function" then
	pcall(function() SaveManager:SetLibrary(Library) end)
	pcall(function() SaveManager:IgnoreThemeSettings() end)
	pcall(function() SaveManager:SetFolder("MyScriptHub/ESP") end)
end

local Window = Library:CreateWindow({ Title = "ESP", Footer = "ESP UI", Icon = 0, NotifySide = "Right", ShowCustomCursor = true })
local Tabs = { Main = Window:AddTab("Visuals", "user"), Settings = Window:AddTab("Settings", "settings") }
local LeftGroup = Tabs.Main:AddLeftGroupbox("ESP")

local Config = ESP.Config or {}

LeftGroup:AddToggle("ESPEnabled", { Text = "ESP Enabled", Default = Config.Enabled == nil and true or Config.Enabled, Callback = function(Value) Config.Enabled = Value end })
LeftGroup:AddToggle("Boxes", { Text = "Boxes", Default = Config.Box == nil and true or Config.Box, Callback = function(Value) Config.Box = Value end }):AddColorPicker("BoxColor", { Default = (Config.Colors and Config.Colors.Box) or Color3.fromRGB(255,255,255), Title = "Box Color", Transparency = 0 })
LeftGroup:AddToggle("Names", { Text = "Names", Default = Config.Name == nil and true or Config.Name, Callback = function(Value) Config.Name = Value end }):AddColorPicker("NameColor", { Default = (Config.Colors and Config.Colors.Name) or Color3.fromRGB(255,255,255), Title = "Name Color", Transparency = 0 })
LeftGroup:AddToggle("Tracers", { Text = "Tracers", Default = Config.Tracer == nil and true or Config.Tracer, Callback = function(Value) Config.Tracer = Value end }):AddColorPicker("TracerColor", { Default = (Config.Colors and Config.Colors.Tracer) or Color3.fromRGB(200,200,200), Title = "Tracer Color", Transparency = 0 })
LeftGroup:AddToggle("Healthbar", { Text = "Healthbar", Default = Config.Healthbar == nil and true or Config.Healthbar, Callback = function(Value) Config.Healthbar = Value end }):AddColorPicker("HealthColor", { Default = (Config.Colors and Config.Colors.Health) or Color3.fromRGB(0,200,50), Title = "Health Color", Transparency = 0 })
LeftGroup:AddToggle("Skeleton", { Text = "Skeleton", Default = Config.Skeleton == nil and true or Config.Skeleton, Callback = function(Value) Config.Skeleton = Value end }):AddColorPicker("SkeletonColor", { Default = (Config.Colors and Config.Colors.Skeleton) or Color3.fromRGB(255,255,255), Title = "Skeleton Color", Transparency = 0 })
LeftGroup:AddToggle("Chams", { Text = "Chams", Default = Config.Chams == nil and false or Config.Chams, Callback = function(Value) Config.Chams = Value end }):AddColorPicker("ChamsColor", { Default = (Config.Colors and Config.Colors.Chams) or Color3.fromRGB(255,100,100), Title = "Chams Color", Transparency = 0 })
LeftGroup:AddToggle("ToolESP", { Text = "Tool ESP", Default = Config.ToolESP == nil and true or Config.ToolESP, Callback = function(Value) Config.ToolESP = Value end }):AddColorPicker("ToolColor", { Default = (Config.Colors and Config.Colors.Tool) or Color3.fromRGB(255,255,255), Title = "Tool Color", Transparency = 0 })
LeftGroup:AddToggle("HeadDot", { Text = "Head Dot", Default = Config.HeadDot == nil and true or Config.HeadDot, Callback = function(Value) Config.HeadDot = Value end }):AddColorPicker("HeadDotColor", { Default = (Config.Colors and Config.Colors.HeadDot) or Color3.fromRGB(255,255,255), Title = "HeadDot Color", Transparency = 0 })

local Options = Library.Options or {}
local Toggles = Library.Toggles or {}

if Options.BoxColor and type(Options.BoxColor.OnChanged) == "function" then
	Options.BoxColor:OnChanged(function() Config.Colors.Box = Options.BoxColor.Value end)
	Options.BoxColor:SetValueRGB(Config.Colors and Config.Colors.Box or Color3.fromRGB(255,255,255))
end
if Options.NameColor and type(Options.NameColor.OnChanged) == "function" then
	Options.NameColor:OnChanged(function() Config.Colors.Name = Options.NameColor.Value end)
	Options.NameColor:SetValueRGB(Config.Colors and Config.Colors.Name or Color3.fromRGB(255,255,255))
end
if Options.TracerColor and type(Options.TracerColor.OnChanged) == "function" then
	Options.TracerColor:OnChanged(function() Config.Colors.Tracer = Options.TracerColor.Value end)
	Options.TracerColor:SetValueRGB(Config.Colors and Config.Colors.Tracer or Color3.fromRGB(200,200,200))
end
if Options.SkeletonColor and type(Options.SkeletonColor.OnChanged) == "function" then
	Options.SkeletonColor:OnChanged(function() Config.Colors.Skeleton = Options.SkeletonColor.Value end)
	Options.SkeletonColor:SetValueRGB(Config.Colors and Config.Colors.Skeleton or Color3.fromRGB(255,255,255))
end
if Options.HealthColor and type(Options.HealthColor.OnChanged) == "function" then
	Options.HealthColor:OnChanged(function() Config.Colors.Health = Options.HealthColor.Value end)
	Options.HealthColor:SetValueRGB(Config.Colors and Config.Colors.Health or Color3.fromRGB(0,200,50))
end
if Options.ChamsColor and type(Options.ChamsColor.OnChanged) == "function" then
	Options.ChamsColor:OnChanged(function() Config.Colors.Chams = Options.ChamsColor.Value end)
	Options.ChamsColor:SetValueRGB(Config.Colors and Config.Colors.Chams or Color3.fromRGB(255,100,100))
end
if Options.HeadDotColor and type(Options.HeadDotColor.OnChanged) == "function" then
	Options.HeadDotColor:OnChanged(function() Config.Colors.HeadDot = Options.HeadDotColor.Value end)
	Options.HeadDotColor:SetValueRGB(Config.Colors and Config.Colors.HeadDot or Color3.fromRGB(255,255,255))
end
if Options.ToolColor and type(Options.ToolColor.OnChanged) == "function" then
	Options.ToolColor:OnChanged(function() Config.Colors.Tool = Options.ToolColor.Value end)
	Options.ToolColor:SetValueRGB(Config.Colors and Config.Colors.Tool or Color3.fromRGB(255,255,255))
end

if Toggles.ESPEnabled and type(Toggles.ESPEnabled.OnChanged) == "function" then Toggles.ESPEnabled:OnChanged(function() Config.Enabled = Toggles.ESPEnabled.Value end) end
if Toggles.Boxes and type(Toggles.Boxes.OnChanged) == "function" then Toggles.Boxes:OnChanged(function() Config.Box = Toggles.Boxes.Value end) end
if Toggles.Names and type(Toggles.Names.OnChanged) == "function" then Toggles.Names:OnChanged(function() Config.Name = Toggles.Names.Value end) end
if Toggles.Tracers and type(Toggles.Tracers.OnChanged) == "function" then Toggles.Tracers:OnChanged(function() Config.Tracer = Toggles.Tracers.Value end) end
if Toggles.Healthbar and type(Toggles.Healthbar.OnChanged) == "function" then Toggles.Healthbar:OnChanged(function() Config.Healthbar = Toggles.Healthbar.Value end) end
if Toggles.Skeleton and type(Toggles.Skeleton.OnChanged) == "function" then Toggles.Skeleton:OnChanged(function() Config.Skeleton = Toggles.Skeleton.Value end) end
if Toggles.Chams and type(Toggles.Chams.OnChanged) == "function" then Toggles.Chams:OnChanged(function() Config.Chams = Toggles.Chams.Value end) end
if Toggles.ToolESP and type(Toggles.ToolESP.OnChanged) == "function" then Toggles.ToolESP:OnChanged(function() Config.ToolESP = Toggles.ToolESP.Value end) end
if Toggles.HeadDot and type(Toggles.HeadDot.OnChanged) == "function" then Toggles.HeadDot:OnChanged(function() Config.HeadDot = Toggles.HeadDot.Value end) end

if SaveManager and type(SaveManager.BuildConfigSection) == "function" then
	pcall(function() SaveManager:BuildConfigSection(Tabs.Settings) end)
	pcall(function() SaveManager:LoadAutoloadConfig() end)
end

if type(ESP.Start) == "function" then
	pcall(function() ESP.Start() end)
end
