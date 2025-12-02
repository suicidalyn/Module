local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Utils = __ESP_REQUIRE("Utils.lua")
local Boxes = __ESP_REQUIRE("Boxes.lua")
local Tracers = __ESP_REQUIRE("Tracers.lua")
local Skeleton = __ESP_REQUIRE("Skeleton.lua")
local HeadDot = __ESP_REQUIRE("HeadDot.lua")
local ToolESP = __ESP_REQUIRE("ToolESP.lua")
local Health = __ESP_REQUIRE("Health.lua")
local Names = __ESP_REQUIRE("Names.lua")

local module = {}
module.Config = {
	Enabled = true,
	TeamCheck = true,
	TeamColored = true,
	MaxDistance = 1000,
	Box = true,
	Name = true,
	Distance = true,
	Healthbar = true,
	Tracer = true,
	Skeleton = true,
	FillBoxes = false,
	Outline = true,
	Font = Drawing.Fonts.Plex,
	Chams = false,
	ToolESP = true,
	HeadDot = true,
	Colors = {
		Box = Color3.fromRGB(255,255,255),
		Name = Color3.fromRGB(255,255,255),
		Tracer = Color3.fromRGB(200,200,200),
		Skeleton = Color3.fromRGB(255,255,255),
		Health = Color3.fromRGB(0,200,50),
		Chams = Color3.fromRGB(255,100,100),
		HeadDot = Color3.fromRGB(255,255,255),
		Tool = Color3.fromRGB(255,255,255)
	}
}

local espStore = {}
local running = false
local renderConn
local playerAddedConn
local playerRemovingConn

local function createEntryForPlayer(p)
	if espStore[p] then return espStore[p] end
	local entry = {}
	entry.draw = {}
	entry.humanoid = nil
	entry.hrp = nil
	entry.highlight = nil
	entry.conns = {}
	if module.Config.Box then entry.draw.boxset = Boxes.Create(module.Config) end
	if module.Config.Tracer then entry.draw.tracer = Tracers.Create(module.Config) end
	if module.Config.Skeleton then entry.draw.skel = Skeleton.Create(module.Config) end
	if module.Config.HeadDot then entry.draw.headdot = HeadDot.Create(module.Config) end
	if module.Config.ToolESP then entry.draw.tool = ToolESP.Create(module.Config) end
	if module.Config.Healthbar then entry.draw.health = Health.Create(module.Config) end
	if module.Config.Name then entry.draw.name = Names.Create(module.Config) end
	espStore[p] = entry
	return entry
end

local function destroyEntry(p)
	local s = espStore[p]
	if not s then return end
	for k,v in pairs(s.draw) do
		if v and type(v.Destroy) == "function" then
			pcall(function() v:Destroy() end)
		elseif type(v) == "table" then
			pcall(function()
				if type(v.Destroy) == "function" then v:Destroy() end
			end)
		end
	end
	if s.highlight and s.highlight.Parent then pcall(function() s.highlight:Destroy() end) end
	for _,c in pairs(s.conns) do pcall(function() c:Disconnect() end) end
	espStore[p] = nil
end

local function onCharacterAdded(p, char)
	local s = createEntryForPlayer(p)
	if not s then return end
	s.humanoid = char:FindFirstChildOfClass("Humanoid")
	s.hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	if module.Config.Chams then
		if s.highlight and s.highlight.Parent then pcall(function() s.highlight:Destroy() end) end
		local ok,h = pcall(function() return Instance.new("Highlight") end)
		if ok and h then
			h.Parent = workspace
			h.Adornee = char
			h.FillColor = module.Config.Colors.Chams
			h.OutlineColor = Color3.new(0,0,0)
			h.FillTransparency = 0.6
			h.OutlineTransparency = 0
			h.Enabled = true
			s.highlight = h
		end
	end
end

local function onPlayerAdded(p)
	if p == LocalPlayer then return end
	createEntryForPlayer(p)
	if p.Character then onCharacterAdded(p, p.Character) end
	local con = p.CharacterAdded:Connect(function(c) onCharacterAdded(p, c) end)
	table.insert(espStore[p].conns, con)
end

local function onPlayerRemoving(p)
	destroyEntry(p)
end

local function ensureExistingPlayers()
	for _,pl in pairs(Players:GetPlayers()) do
		if pl ~= LocalPlayer and not espStore[pl] then
			onPlayerAdded(pl)
		end
	end
end

local function shouldDrawFor(player, s)
	if not s or not s.hrp then return false end
	if not module.Config.Enabled then return false end
	if module.Config.TeamCheck and LocalPlayer.Team and player.Team then
		if module.Config.TeamColored then
		end
	end
	return true
end

local function updateAll(dt)
	local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	for player,s in pairs(espStore) do
		if player and player.Character and s and s.humanoid and s.hrp and s.hrp.Parent then
			if s.humanoid.Health <= 0 then
				Boxes.Hide(s)
				Tracers.Hide(s)
				Skeleton.Hide(s)
				HeadDot.Hide(s)
				ToolESP.Hide(s)
				Health.Hide(s)
				Names.Hide(s)
				if s.highlight and s.highlight.Parent then pcall(function() s.highlight.Enabled = false end) end
			else
				local parts = {}
				for _,v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then table.insert(parts, v) end end
				local minX,minY = math.huge, math.huge
				local maxX,maxY = -math.huge, -math.huge
				local onScreen = false
				for _,part in pairs(parts) do
					local p2, vis = Utils.WorldToScreen(part.Position)
					if vis then
						onScreen = true
						if p2.X < minX then minX = p2.X end
						if p2.Y < minY then minY = p2.Y end
						if p2.X > maxX then maxX = p2.X end
						if p2.Y > maxY then maxY = p2.Y end
					end
				end
				if not onScreen then
					Boxes.Hide(s)
					Skeleton.Hide(s)
					HeadDot.Hide(s)
					Names.Hide(s)
				else
					if minX==math.huge then minX,maxX = 0,0 end
					if minY==math.huge then minY,maxY = 0,0 end
					local w = math.max(20, maxX - minX)
					local h = math.max(20, maxY - minY)
					local cx = (minX + maxX)/2
					local cy = (minY + maxY)/2
					local dist = 0
					local lpRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso"))
					if lpRoot and s.hrp then dist = math.floor((s.hrp.Position - lpRoot.Position).Magnitude) end
					if module.Config.MaxDistance and dist > module.Config.MaxDistance then
						Boxes.Hide(s)
						Tracers.Hide(s)
						Skeleton.Hide(s)
						HeadDot.Hide(s)
						ToolESP.Hide(s)
						Health.Hide(s)
						Names.Hide(s)
					else
						local teamColor = nil
						if module.Config.TeamColored and module.Config.TeamCheck and LocalPlayer.Team and player.Team then
							if player.Team == LocalPlayer.Team then teamColor = Color3.fromRGB(50,230,50) else teamColor = Color3.fromRGB(230,50,50) end
						end
						Boxes.Update(s, cx, cy, w, h, teamColor)
						Tracers.Update(s, player, screenCenter, teamColor)
						Skeleton.Update(s, player, teamColor)
						HeadDot.Update(s, player, teamColor)
						ToolESP.Update(s, player, cx, cy, h, teamColor)
						Health.Update(s, player, cx, cy, w, h)
						Names.Update(s, player, cx, cy, dist, teamColor)
						if s.highlight and s.highlight.Parent then
							pcall(function() s.highlight.FillColor = teamColor or module.Config.Colors.Chams; s.highlight.Enabled = module.Config.Chams end)
						end
					end
				end
			end
		else
			if s then
				Boxes.Hide(s)
				Tracers.Hide(s)
				Skeleton.Hide(s)
				HeadDot.Hide(s)
				ToolESP.Hide(s)
				Health.Hide(s)
				Names.Hide(s)
				if s.highlight and s.highlight.Parent then pcall(function() s.highlight.Enabled = false end) end
			end
		end
	end
end

function module.Start()
	if running then return end
	running = true
	ensureExistingPlayers()
	playerAddedConn = Players.PlayerAdded:Connect(function(p) onPlayerAdded(p) end)
	playerRemovingConn = Players.PlayerRemoving:Connect(function(p) onPlayerRemoving(p) end)
	renderConn = RunService.RenderStepped:Connect(function(dt) pcall(function() updateAll(dt) end) end)
end

function module.Stop()
	if not running then return end
	running = false
	if renderConn then renderConn:Disconnect(); renderConn = nil end
	if playerAddedConn then playerAddedConn:Disconnect(); playerAddedConn = nil end
	if playerRemovingConn then playerRemovingConn:Disconnect(); playerRemovingConn = nil end
	for p,_ in pairs(espStore) do destroyEntry(p) end
	espStore = {}
end

function module.SetConfig(tbl)
	if type(tbl) ~= "table" then return end
	for k,v in pairs(tbl) do
		if k == "Colors" and type(v) == "table" then
			for name,c in pairs(v) do
				if type(c) == "table" and c.r then module.Config.Colors[name] = Color3.fromRGB(c.r,c.g,c.b) end
			end
		else
			module.Config[k] = v
		end
	end
end

return module
