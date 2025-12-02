-- UI.lua
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManagerAddon = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local ESP = loadfile("ESP_Module/ESP.lua")()
local SaveManager = SaveManagerAddon

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("MyScriptHub/ESP")

local Window = Library:CreateWindow({ Title = "ESP", Footer = "ESP UI", Icon = 0, NotifySide = "Right", ShowCustomCursor = true })
local Tabs = { Main = Window:AddTab("Visuals", "user"), Settings = Window:AddTab("Settings", "settings") }
local LeftGroup = Tabs.Main:AddLeftGroupbox("ESP")

local Config = ESP.Config

local function applyColorPickers()
	if Options.BoxColor then Options.BoxColor:SetValueRGB(Config.Colors.Box) end
	if Options.NameColor then Options.NameColor:SetValueRGB(Config.Colors.Name) end
	if Options.TracerColor then Options.TracerColor:SetValueRGB(Config.Colors.Tracer) end
	if Options.SkeletonColor then Options.SkeletonColor:SetValueRGB(Config.Colors.Skeleton) end
	if Options.HealthColor then Options.HealthColor:SetValueRGB(Config.Colors.Health) end
	if Options.ChamsColor then Options.ChamsColor:SetValueRGB(Config.Colors.Chams) end
	if Options.HeadDotColor then Options.HeadDotColor:SetValueRGB(Config.Colors.HeadDot) end
	if Options.ToolColor then Options.ToolColor:SetValueRGB(Config.Colors.Tool) end
end

LeftGroup:AddToggle("ESPEnabled", { Text = "ESP Enabled", Default = Config.Enabled, Callback = function(Value) Config.Enabled = Value end })
LeftGroup:AddToggle("Boxes", { Text = "Boxes", Default = Config.Box, Callback = function(Value) Config.Box = Value end }):AddColorPicker("BoxColor", { Default = Config.Colors.Box, Title = "Box Color", Transparency = 0 })
LeftGroup:AddToggle("Names", { Text = "Names", Default = Config.Name, Callback = function(Value) Config.Name = Value end }):AddColorPicker("NameColor", { Default = Config.Colors.Name, Title = "Name Color", Transparency = 0 })
LeftGroup:AddToggle("Tracers", { Text = "Tracers", Default = Config.Tracer, Callback = function(Value) Config.Tracer = Value end }):AddColorPicker("TracerColor", { Default = Config.Colors.Tracer, Title = "Tracer Color", Transparency = 0 })
LeftGroup:AddToggle("Healthbar", { Text = "Healthbar", Default = Config.Healthbar, Callback = function(Value) Config.Healthbar = Value end }):AddColorPicker("HealthColor", { Default = Config.Colors.Health, Title = "Health Color", Transparency = 0 })
LeftGroup:AddToggle("Skeleton", { Text = "Skeleton", Default = Config.Skeleton, Callback = function(Value) Config.Skeleton = Value end }):AddColorPicker("SkeletonColor", { Default = Config.Colors.Skeleton, Title = "Skeleton Color", Transparency = 0 })
LeftGroup:AddToggle("Chams", { Text = "Chams", Default = Config.Chams, Callback = function(Value) Config.Chams = Value end }):AddColorPicker("ChamsColor", { Default = Config.Colors.Chams, Title = "Chams Color", Transparency = 0 })
LeftGroup:AddToggle("ToolESP", { Text = "Tool ESP", Default = Config.ToolESP, Callback = function(Value) Config.ToolESP = Value end }):AddColorPicker("ToolColor", { Default = Config.Colors.Tool, Title = "Tool Color", Transparency = 0 })
LeftGroup:AddToggle("HeadDot", { Text = "Head Dot", Default = Config.HeadDot, Callback = function(Value) Config.HeadDot = Value end }):AddColorPicker("HeadDotColor", { Default = Config.Colors.HeadDot, Title = "HeadDot Color", Transparency = 0 })

local Options = Library.Options
local Toggles = Library.Toggles

if Options.BoxColor then
	Options.BoxColor:OnChanged(function() Config.Colors.Box = Options.BoxColor.Value end)
end
if Options.NameColor then
	Options.NameColor:OnChanged(function() Config.Colors.Name = Options.NameColor.Value end)
end
if Options.TracerColor then
	Options.TracerColor:OnChanged(function() Config.Colors.Tracer = Options.TracerColor.Value end)
end
if Options.SkeletonColor then
	Options.SkeletonColor:OnChanged(function() Config.Colors.Skeleton = Options.SkeletonColor.Value end)
end
if Options.HealthColor then
	Options.HealthColor:OnChanged(function() Config.Colors.Health = Options.HealthColor.Value end)
end
if Options.ChamsColor then
	Options.ChamsColor:OnChanged(function() Config.Colors.Chams = Options.ChamsColor.Value end)
end
if Options.HeadDotColor then
	Options.HeadDotColor:OnChanged(function() Config.Colors.HeadDot = Options.HeadDotColor.Value end)
end
if Options.ToolColor then
	Options.ToolColor:OnChanged(function() Config.Colors.Tool = Options.ToolColor.Value end)
end

if Toggles.ESPEnabled then Toggles.ESPEnabled:OnChanged(function() Config.Enabled = Toggles.ESPEnabled.Value end) end
if Toggles.Boxes then Toggles.Boxes:OnChanged(function() Config.Box = Toggles.Boxes.Value end) end
if Toggles.Names then Toggles.Names:OnChanged(function() Config.Name = Toggles.Names.Value end) end
if Toggles.Tracers then Toggles.Tracers:OnChanged(function() Config.Tracer = Toggles.Tracers.Value end) end
if Toggles.Healthbar then Toggles.Healthbar:OnChanged(function() Config.Healthbar = Toggles.Healthbar.Value end) end
if Toggles.Skeleton then Toggles.Skeleton:OnChanged(function() Config.Skeleton = Toggles.Skeleton.Value end) end
if Toggles.Chams then Toggles.Chams:OnChanged(function() Config.Chams = Toggles.Chams.Value end) end
if Toggles.ToolESP then Toggles.ToolESP:OnChanged(function() Config.ToolESP = Toggles.ToolESP.Value end) end
if Toggles.HeadDot then Toggles.HeadDot:OnChanged(function() Config.HeadDot = Toggles.HeadDot.Value end) end

SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
ESP.Start()
