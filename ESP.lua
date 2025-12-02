-- ESP.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local module = {}
local Config = {
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
module.Config = Config

local espStore = {}
local running = false
local conn

local function newDrawing(k)
	local ok, obj = pcall(function() return Drawing.new(k) end)
	if ok then return obj end
	return nil
end

local function createDrawSet()
	local set = {}
	set.box = newDrawing("Square")
	if set.box then
		set.box.Filled = false
		set.box.Thickness = 1
		set.box.Transparency = 1
		set.box.Color = Config.Colors.Box
		set.box.Size = Vector2.new(0,0)
		set.box.Position = Vector2.new(0,0)
		set.box.Visible = false
	end
	set.boxOutline = newDrawing("Square")
	if set.boxOutline then
		set.boxOutline.Filled = false
		set.boxOutline.Thickness = 3
		set.boxOutline.Transparency = 1
		set.boxOutline.Color = Color3.new(0,0,0)
		set.boxOutline.Visible = false
	end
	set.name = newDrawing("Text")
	if set.name then
		set.name.Size = 14
		set.name.Center = true
		set.name.Outline = true
		set.name.OutlineColor = Color3.new(0,0,0)
		set.name.Font = Config.Font
		set.name.Color = Config.Colors.Name
		set.name.Position = Vector2.new(0,0)
		set.name.Visible = false
	end
	set.tracer = newDrawing("Line")
	if set.tracer then
		set.tracer.Thickness = 1
		set.tracer.Transparency = 1
		set.tracer.Color = Config.Colors.Tracer
		set.tracer.Visible = false
	end
	set.health = newDrawing("Square")
	if set.health then
		set.health.Filled = true
		set.health.Transparency = 1
		set.health.Thickness = 1
		set.health.Color = Config.Colors.Health
		set.health.Size = Vector2.new(4,0)
		set.health.Position = Vector2.new(0,0)
		set.health.Visible = false
	end
	set.skeleton = {}
	for i=1,24 do
		local l = newDrawing("Line")
		if l then
			l.Thickness = 1
			l.Transparency = 1
			l.Color = Config.Colors.Skeleton
			l.Visible = false
			table.insert(set.skeleton, l)
		end
	end
	set.headDot = newDrawing("Circle")
	if set.headDot then
		set.headDot.Radius = 4
		set.headDot.Filled = true
		set.headDot.Transparency = 1
		set.headDot.Color = Config.Colors.HeadDot
		set.headDot.Visible = false
	end
	set.toolLabel = newDrawing("Text")
	if set.toolLabel then
		set.toolLabel.Size = 14
		set.toolLabel.Center = true
		set.toolLabel.Outline = true
		set.toolLabel.OutlineColor = Color3.new(0,0,0)
		set.toolLabel.Font = Config.Font
		set.toolLabel.Color = Config.Colors.Tool
		set.toolLabel.Position = Vector2.new(0,0)
		set.toolLabel.Visible = false
	end
	return set
end

local bonePairs = {
	{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"LowerTorso","LeftUpperLeg"},
	{"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
	{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"UpperTorso","RightUpperArm"},
	{"RightUpperArm","RightLowerArm"},{"Head","Neck"},{"LeftLowerArm","LeftHand"},
	{"RightLowerArm","RightHand"},{"LeftLowerLeg","LeftFoot"},{"RightLowerLeg","RightFoot"},
	{"UpperTorso","LeftHand"},{"UpperTorso","RightHand"},{"LowerTorso","HumanoidRootPart"}
}

local function getCharacterParts(character)
	local parts = {}
	for _,v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") then table.insert(parts, v) end
	end
	return parts
end

local function onPlayerAdded(p)
	espStore[p] = { draw = createDrawSet(), humanoid = nil, hrp = nil, highlight = nil }
	local function setupChar(c)
		espStore[p].humanoid = c:FindFirstChildOfClass("Humanoid")
		espStore[p].hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
		if Config.Chams and espStore[p].highlight == nil then
			local ok, h = pcall(function() return Instance.new("Highlight") end)
			if ok and h then
				h.Parent = workspace
				h.Adornee = c
				h.FillColor = Config.Colors.Chams
				h.Enabled = true
				espStore[p].highlight = h
			end
		end
	end
	if p.Character then setupChar(p.Character) end
	p.CharacterAdded:Connect(setupChar)
	p.AncestryChanged:Connect(function()
		if not p.Parent then
			local s = espStore[p]
			if s then
				if s.highlight and s.highlight.Parent then pcall(function() s.highlight:Destroy() end) end
				if s.draw then
					for _,v in pairs(s.draw) do
						if type(v) == "table" then
							for _,d in pairs(v) do if d and d.Destroy then pcall(function() d:Destroy() end) end end
						else
							if v and v.Destroy then pcall(function() v:Destroy() end) end
						end
					end
				end
			end
			espStore[p] = nil
		end
	end)
end

for _,pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer then onPlayerAdded(pl) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then onPlayerAdded(p) end end)
Players.PlayerRemoving:Connect(function(p) if espStore[p] then if espStore[p].highlight and espStore[p].highlight.Parent then pcall(function() espStore[p].highlight:Destroy() end) end end espStore[p] = nil end)

local function worldToScreen(pos)
	local p, vis = Camera:WorldToViewportPoint(pos)
	return Vector2.new(p.X, p.Y), vis
end

local function teamColorOrElement(p, elementColor)
	if Config.TeamColored and Config.TeamCheck and LocalPlayer.Team and p.Team then
		if p.Team == LocalPlayer.Team then return Color3.fromRGB(50,230,50) else return Color3.fromRGB(230,50,50) end
	else return elementColor end
end

local function getToolName(character)
	for _,v in pairs(character:GetChildren()) do if v:IsA("Tool") then return v.Name end end
	return nil
end

local lastTick = tick()
local function render(dt)
	if not Config.Enabled then
		for p,s in pairs(espStore) do
			for _,v in pairs(s.draw) do
				if type(v) == "table" then for _,d in pairs(v) do if d then d.Visible = false end end else if v then v.Visible = false end end
			end
			if s.highlight and s.highlight.Parent then s.highlight.Enabled = false end
		end
		return
	end
	local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	for p,s in pairs(espStore) do
		if p and p.Character and s and s.humanoid and s.hrp and s.hrp.Parent then
			local alive = s.humanoid.Health > 0
			if not alive then
				for _,v in pairs(s.draw) do if type(v) == "table" then for _,d in pairs(v) do if d then d.Visible = false end end else if v then v.Visible = false end end end
				if s.highlight and s.highlight.Parent then s.highlight.Enabled = false end
			else
				local parts = getCharacterParts(p.Character)
				local minX, minY = math.huge, math.huge
				local maxX, maxY = -math.huge, -math.huge
				local onScreen = false
				for _,part in pairs(parts) do
					local pos, vis = worldToScreen(part.Position)
					if vis then
						onScreen = true
						if pos.X < minX then minX = pos.X end
						if pos.Y < minY then minY = pos.Y end
						if pos.X > maxX then maxX = pos.X end
						if pos.Y > maxY then maxY = pos.Y end
					end
				end
				if not onScreen then
					for _,v in pairs(s.draw) do if type(v) == "table" then for _,d in pairs(v) do if d then d.Visible = false end end else if v then v.Visible = false end end end
					if s.highlight and s.highlight.Parent then s.highlight.Enabled = false end
				else
					if minX==math.huge then minX,maxX = 0,0 end
					if minY==math.huge then minY,maxY = 0,0 end
					local w = math.max(20, maxX - minX)
					local h = math.max(20, maxY - minY)
					local cx = (minX + maxX)/2
					local cy = (minY + maxY)/2
					local dist = 0
					if LocalPlayer.Character then
						local lpRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
						if lpRoot and s.hrp then dist = math.floor((s.hrp.Position - lpRoot.Position).Magnitude) end
					end
					if Config.MaxDistance and dist > Config.MaxDistance then
						for _,v in pairs(s.draw) do if type(v) == "table" then for _,d in pairs(v) do if d then d.Visible = false end end else if v then v.Visible = false end end end
						if s.highlight and s.highlight.Parent then s.highlight.Enabled = false end
					else
						local baseBoxColor = Config.Colors.Box
						local baseNameColor = Config.Colors.Name
						local baseTracerColor = Config.Colors.Tracer
						local baseSkeletonColor = Config.Colors.Skeleton
						local baseHealthColor = Config.Colors.Health
						local baseChamsColor = Config.Colors.Chams
						if Config.Chams then
							if not s.highlight or not s.highlight.Parent then
								local ok, h = pcall(function() return Instance.new("Highlight") end)
								if ok and h and p.Character then
									h.Parent = workspace
									h.Adornee = p.Character
									h.FillColor = teamColorOrElement(p, baseChamsColor)
									h.OutlineColor = Color3.new(0,0,0)
									h.FillTransparency = 0.6
									h.OutlineTransparency = 0
									h.Enabled = true
									s.highlight = h
								end
							else
								s.highlight.FillColor = teamColorOrElement(p, baseChamsColor)
								s.highlight.Enabled = true
							end
						else
							if s.highlight and s.highlight.Parent then s.highlight.Enabled = false end
						end
						if Config.Box and s.draw.box then
							s.draw.box.Size = Vector2.new(w, h)
							s.draw.box.Position = Vector2.new(cx - w/2, cy - h/2)
							s.draw.box.Color = teamColorOrElement(p, baseBoxColor)
							s.draw.box.Filled = Config.FillBoxes
							s.draw.box.Visible = true
							if Config.Outline and s.draw.boxOutline then
								s.draw.boxOutline.Size = Vector2.new(w+4, h+4)
								s.draw.boxOutline.Position = Vector2.new(cx - (w+4)/2, cy - (h+4)/2)
								s.draw.boxOutline.Color = Color3.new(0,0,0)
								s.draw.boxOutline.Visible = true
							else
								if s.draw.boxOutline then s.draw.boxOutline.Visible = false end
							end
						else
							if s.draw.box then s.draw.box.Visible = false end
							if s.draw.boxOutline then s.draw.boxOutline.Visible = false end
						end
						if Config.Name and s.draw.name then
							local txt = p.Name
							if Config.Distance then txt = txt .. " ["..tostring(dist).."m]" end
							s.draw.name.Text = txt
							s.draw.name.Position = Vector2.new(cx, cy - h/2 - 12)
							s.draw.name.Color = teamColorOrElement(p, baseNameColor)
							s.draw.name.Visible = true
						else if s.draw.name then s.draw.name.Visible = false end end
						if Config.Tracer and s.draw.tracer then
							s.draw.tracer.From = screenCenter
							s.draw.tracer.To = Vector2.new(cx, cy)
							s.draw.tracer.Color = teamColorOrElement(p, baseTracerColor)
							s.draw.tracer.Visible = true
						else if s.draw.tracer then s.draw.tracer.Visible = false end end
						if Config.Healthbar and s.humanoid and s.humanoid.MaxHealth > 0 and s.draw.health then
							local hp = math.clamp(s.humanoid.Health / s.humanoid.MaxHealth, 0, 1)
							local barH = h
							local bx = cx - w/2 - 8
							local by = cy - barH/2
							s.draw.health.Position = Vector2.new(bx, by + (1 - hp) * barH)
							s.draw.health.Size = Vector2.new(4, barH * hp)
							local g = math.clamp(hp,0,1)
							local healthColor = Color3.new(1-g, g, 0)
							s.draw.health.Color = healthColor
							s.draw.health.Visible = true
						else if s.draw.health then s.draw.health.Visible = false end end
						if Config.Skeleton then
							local used = 0
							for i,pair in ipairs(bonePairs) do
								local aName, bName = pair[1], pair[2]
								local a = p.Character:FindFirstChild(aName) or p.Character:FindFirstChild(aName.."Part")
								local b = p.Character:FindFirstChild(bName) or p.Character:FindFirstChild(bName.."Part")
								if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
									local pa, va = worldToScreen(a.Position)
									local pb, vb = worldToScreen(b.Position)
									if va and vb then
										used = used + 1
										local line = s.draw.skeleton[used]
										if line then
											line.From = pa
											line.To = pb
											line.Color = teamColorOrElement(p, baseSkeletonColor)
											line.Visible = true
										end
									end
								end
							end
							for i=used+1,#s.draw.skeleton do if s.draw.skeleton[i] then s.draw.skeleton[i].Visible = false end end
						else for _,l in pairs(s.draw.skeleton) do if l then l.Visible = false end end end
						if Config.HeadDot and s.draw.headDot then
							local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("head")
							if head and head:IsA("BasePart") then
								local pos, vis = worldToScreen(head.Position + Vector3.new(0,0.2,0))
								if vis then s.draw.headDot.Position = pos s.draw.headDot.Color = teamColorOrElement(p, Config.Colors.HeadDot) s.draw.headDot.Visible = true else s.draw.headDot.Visible = false end
							else s.draw.headDot.Visible = false end
						else if s.draw.headDot then s.draw.headDot.Visible = false end end
						if Config.ToolESP and s.draw.toolLabel then
							local tool = getToolName(p.Character)
							if tool then
								s.draw.toolLabel.Text = tool
								s.draw.toolLabel.Position = Vector2.new(cx, cy + h/2 + 8)
								s.draw.toolLabel.Color = teamColorOrElement(p, Config.Colors.Tool)
								s.draw.toolLabel.Visible = true
							else s.draw.toolLabel.Visible = false end
						else if s.draw.toolLabel then s.draw.toolLabel.Visible = false end end
					end
				end
			end
		else
			if s then
				for _,v in pairs(s.draw) do if type(v) == "table" then for _,d in pairs(v) do if d then d.Visible = false end end else if v then v.Visible = false end end end
				if s.highlight and s.highlight.Parent then s.highlight.Enabled = false end
			end
		end
	end
end

function module.Start()
	if running then return end
	running = true
	lastTick = tick()
	conn = RunService.RenderStepped:Connect(function()
		local now = tick()
		local dt = now - lastTick
		lastTick = now
		pcall(function() render(dt) end)
	end)
end

function module.Stop()
	if not running then return end
	running = false
	if conn then conn:Disconnect() conn = nil end
	for p,s in pairs(espStore) do
		for _,v in pairs(s.draw) do
			if type(v) == "table" then for _,d in pairs(v) do if d and d.Destroy then pcall(function() d:Destroy() end) end end
			else if v and v.Destroy then pcall(function() v:Destroy() end) end end
		end
		if s.highlight and s.highlight.Parent then pcall(function() s.highlight:Destroy() end) end
	end
	espStore = {}
	for _,pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer then onPlayerAdded(pl) end end
end

function module.SetConfig(tbl)
	if type(tbl) ~= "table" then return end
	for k,v in pairs(tbl) do
		if k == "Colors" and type(v) == "table" then for name,clr in pairs(v) do if type(clr) == "string" then -- allow hex or json
				local ok, t = pcall(function() return HttpService:JSONDecode(clr) end)
				if ok and type(t) == "table" then module.Config.Colors[name] = Color3.fromRGB(t.r or 255, t.g or 255, t.b or 255) end
			elseif type(clr) == "table" then module.Config.Colors[name] = Color3.fromRGB(clr.r or 255, clr.g or 255, clr.b or 255) end
		elseif k ~= "Font" then module.Config[k] = v end
	end
end

return module
