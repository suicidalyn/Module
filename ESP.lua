local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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
local conn = nil
local lastTick = tick()

local function safeNewDrawing(kind)
	local ok, obj = pcall(function() return Drawing.new(kind) end)
	if ok and obj then return obj end
	return nil
end

local function createDrawSet()
	local set = {}

	set.box = safeNewDrawing("Square")
	if set.box then
		set.box.Filled = false
		set.box.Thickness = 1
		set.box.Transparency = 1
		set.box.Color = module.Config.Colors.Box
		set.box.Size = Vector2.new(0,0)
		set.box.Position = Vector2.new(0,0)
		set.box.Visible = false
	end

	set.boxOutline = safeNewDrawing("Square")
	if set.boxOutline then
		set.boxOutline.Filled = false
		set.boxOutline.Thickness = 3
		set.boxOutline.Transparency = 1
		set.boxOutline.Color = Color3.new(0,0,0)
		set.boxOutline.Visible = false
	end

	set.name = safeNewDrawing("Text")
	if set.name then
		set.name.Size = 14
		set.name.Center = true
		set.name.Outline = true
		set.name.OutlineColor = Color3.new(0,0,0)
		set.name.Font = module.Config.Font
		set.name.Color = module.Config.Colors.Name
		set.name.Position = Vector2.new(0,0)
		set.name.Visible = false
	end

	set.tracer = safeNewDrawing("Line")
	if set.tracer then
		set.tracer.Thickness = 1
		set.tracer.Transparency = 1
		set.tracer.Color = module.Config.Colors.Tracer
		set.tracer.Visible = false
	end

	set.health = safeNewDrawing("Square")
	if set.health then
		set.health.Filled = true
		set.health.Transparency = 1
		set.health.Thickness = 1
		set.health.Color = module.Config.Colors.Health
		set.health.Size = Vector2.new(4,0)
		set.health.Position = Vector2.new(0,0)
		set.health.Visible = false
	end

	set.skeleton = {}
	for i = 1, 24 do
		local l = safeNewDrawing("Line")
		if l then
			l.Thickness = 1
			l.Transparency = 1
			l.Color = module.Config.Colors.Skeleton
			l.Visible = false
			table.insert(set.skeleton, l)
		end
	end

	set.headDot = safeNewDrawing("Circle")
	if set.headDot then
		set.headDot.Radius = 4
		set.headDot.Filled = true
		set.headDot.Transparency = 1
		set.headDot.Color = module.Config.Colors.HeadDot
		set.headDot.Visible = false
	end

	set.toolLabel = safeNewDrawing("Text")
	if set.toolLabel then
		set.toolLabel.Size = 14
		set.toolLabel.Center = true
		set.toolLabel.Outline = true
		set.toolLabel.OutlineColor = Color3.new(0,0,0)
		set.toolLabel.Font = module.Config.Font
		set.toolLabel.Color = module.Config.Colors.Tool
		set.toolLabel.Position = Vector2.new(0,0)
		set.toolLabel.Visible = false
	end

	return set
end

local bonePairs = {
	{"Head","UpperTorso"},
	{"UpperTorso","LowerTorso"},
	{"LowerTorso","LeftUpperLeg"},
	{"LeftUpperLeg","LeftLowerLeg"},
	{"LowerTorso","RightUpperLeg"},
	{"RightUpperLeg","RightLowerLeg"},
	{"UpperTorso","LeftUpperArm"},
	{"LeftUpperArm","LeftLowerArm"},
	{"UpperTorso","RightUpperArm"},
	{"RightUpperArm","RightLowerArm"},
	{"Head","Neck"},
	{"LeftLowerArm","LeftHand"},
	{"RightLowerArm","RightHand"},
	{"LeftLowerLeg","LeftFoot"},
	{"RightLowerLeg","RightFoot"},
	{"UpperTorso","LeftHand"},
	{"UpperTorso","RightHand"},
	{"LowerTorso","HumanoidRootPart"}
}

local function getCharacterParts(character)
	local parts = {}
	for _,v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			table.insert(parts, v)
		end
	end
	return parts
end

local function setLinePoints(line, pa, pb)
	-- support both APIs: From/To and PointA/PointB
	pcall(function()
		if line then
			line.From = pa
		end
	end)
	pcall(function()
		if line then
			line.To = pb
		end
	end)
	pcall(function()
		if line and line.PointA ~= nil then line.PointA = pa end
	end)
	pcall(function()
		if line and line.PointB ~= nil then line.PointB = pb end
	end)
end

local function onPlayerAdded(p)
	espStore[p] = {
		draw = createDrawSet(),
		humanoid = nil,
		hrp = nil,
		highlight = nil
	}
	local function setupChar(c)
		if not espStore[p] then return end
		espStore[p].humanoid = c:FindFirstChildOfClass("Humanoid")
		espStore[p].hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
		if module.Config.Chams then
			if espStore[p].highlight and espStore[p].highlight.Parent then
				pcall(function() espStore[p].highlight:Destroy() end)
			end
			local ok, h = pcall(function() return Instance.new("Highlight") end)
			if ok and h then
				h.Parent = workspace
				h.Adornee = c
				h.FillColor = module.Config.Colors.Chams
				h.OutlineColor = Color3.new(0,0,0)
				h.FillTransparency = 0.6
				h.OutlineTransparency = 0
				h.Enabled = true
				espStore[p].highlight = h
			end
		end
	end

	if p.Character then setupChar(p.Character) end
	p.CharacterAdded:Connect(function(c) setupChar(c) end)
	p.AncestryChanged:Connect(function()
		if not p.Parent then
			local s = espStore[p]
			if s then
				if s.highlight and s.highlight.Parent then pcall(function() s.highlight:Destroy() end) end
				for _,v in pairs(s.draw) do
					if type(v) == "table" then
						for _,d in pairs(v) do
							if d and d.Destroy then pcall(function() d:Destroy() end) end
						end
					else
						if v and v.Destroy then pcall(function() v:Destroy() end) end
					end
				end
			end
			espStore[p] = nil
		end
	end)
end

for _,pl in pairs(Players:GetPlayers()) do
	if pl ~= LocalPlayer then onPlayerAdded(pl) end
end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then onPlayerAdded(p) end end)
Players.PlayerRemoving:Connect(function(p)
	local s = espStore[p]
	if s then
		if s.highlight and s.highlight.Parent then pcall(function() s.highlight:Destroy() end) end
		for _,v in pairs(s.draw) do
			if type(v) == "table" then
				for _,d in pairs(v) do
					if d and d.Destroy then pcall(function() d:Destroy() end) end
				end
			else
				if v and v.Destroy then pcall(function() v:Destroy() end) end
			end
		end
	end
	espStore[p] = nil
end)

local function worldToScreen(pos)
	local ok, p, vis = pcall(function() return Camera:WorldToViewportPoint(pos) end)
	if not ok or not p then return Vector2.new(0,0), false end
	return Vector2.new(p.X, p.Y), vis
end

local function teamColorOrElement(player, fallback)
	if module.Config.TeamColored and module.Config.TeamCheck and LocalPlayer.Team and player.Team then
		if player.Team == LocalPlayer.Team then
			return Color3.fromRGB(50,230,50)
		else
			return Color3.fromRGB(230,50,50)
		end
	end
	return fallback
end

local function getToolName(character)
	for _,v in pairs(character:GetChildren()) do
		if v:IsA("Tool") then return v.Name end
	end
	return nil
end

local function hideAllDrawsFor(s)
	for _,v in pairs(s.draw) do
		if type(v) == "table" then
			for _,d in pairs(v) do if d then pcall(function() d.Visible = false end) end end
		else
			if v then pcall(function() v.Visible = false end) end
		end
	end
	if s.highlight and s.highlight.Parent then pcall(function() s.highlight.Enabled = false end) end
end

local function render(dt)
	if not module.Config.Enabled then
		for p,s in pairs(espStore) do hideAllDrawsFor(s) end
		return
	end

	local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	for player, s in pairs(espStore) do
		if player and player.Character and s and s.humanoid and s.hrp and s.hrp.Parent then
			local alive = s.humanoid.Health > 0
			if not alive then
				hideAllDrawsFor(s)
			else
				local parts = getCharacterParts(player.Character)
				local minX, minY = math.huge, math.huge
				local maxX, maxY = -math.huge, -math.huge
				local onScreen = false
				for _,part in pairs(parts) do
					local p2, vis = worldToScreen(part.Position)
					if vis then
						onScreen = true
						if p2.X < minX then minX = p2.X end
						if p2.Y < minY then minY = p2.Y end
						if p2.X > maxX then maxX = p2.X end
						if p2.Y > maxY then maxY = p2.Y end
					end
				end

				if not onScreen then
					hideAllDrawsFor(s)
				else
					if minX == math.huge then minX,maxX = 0,0 end
					if minY == math.huge then minY,maxY = 0,0 end

					local w = math.max(20, maxX - minX)
					local h = math.max(20, maxY - minY)
					local cx = (minX + maxX)/2
					local cy = (minY + maxY)/2

					local dist = 0
					if LocalPlayer.Character then
						local lpRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso")
						if lpRoot and s.hrp then dist = math.floor((s.hrp.Position - lpRoot.Position).Magnitude) end
					end

					if module.Config.MaxDistance and dist > module.Config.MaxDistance then
						hideAllDrawsFor(s)
					else
						local baseBoxColor = module.Config.Colors.Box
						local baseNameColor = module.Config.Colors.Name
						local baseTracerColor = module.Config.Colors.Tracer
						local baseSkeletonColor = module.Config.Colors.Skeleton
						local baseHealthColor = module.Config.Colors.Health
						local baseChamsColor = module.Config.Colors.Chams

						-- chams
						if module.Config.Chams then
							if not s.highlight or not s.highlight.Parent then
								local ok, h = pcall(function() return Instance.new("Highlight") end)
								if ok and h and player.Character then
									h.Parent = workspace
									h.Adornee = player.Character
									h.FillColor = teamColorOrElement(player, baseChamsColor)
									h.OutlineColor = Color3.new(0,0,0)
									h.FillTransparency = 0.6
									h.OutlineTransparency = 0
									h.Enabled = true
									s.highlight = h
								end
							else
								pcall(function() s.highlight.FillColor = teamColorOrElement(player, baseChamsColor) end)
								pcall(function() s.highlight.Enabled = true end)
							end
						else
							if s.highlight and s.highlight.Parent then pcall(function() s.highlight.Enabled = false end) end
						end

						-- box
						if module.Config.Box and s.draw.box then
							pcall(function()
								s.draw.box.Size = Vector2.new(w, h)
								s.draw.box.Position = Vector2.new(cx - w/2, cy - h/2)
								s.draw.box.Color = teamColorOrElement(player, baseBoxColor)
								s.draw.box.Filled = module.Config.FillBoxes
								s.draw.box.Visible = true
							end)
							if module.Config.Outline and s.draw.boxOutline then
								pcall(function()
									s.draw.boxOutline.Size = Vector2.new(w+4, h+4)
									s.draw.boxOutline.Position = Vector2.new(cx - (w+4)/2, cy - (h+4)/2)
									s.draw.boxOutline.Color = Color3.new(0,0,0)
									s.draw.boxOutline.Visible = true
								end)
							else
								if s.draw.boxOutline then pcall(function() s.draw.boxOutline.Visible = false end) end
							end
						else
							if s.draw.box then pcall(function() s.draw.box.Visible = false end) end
							if s.draw.boxOutline then pcall(function() s.draw.boxOutline.Visible = false end) end
						end

						-- name
						if module.Config.Name and s.draw.name then
							local txt = player.Name
							if module.Config.Distance then txt = txt .. " ["..tostring(dist).."m]" end
							pcall(function()
								s.draw.name.Text = txt
								s.draw.name.Position = Vector2.new(cx, cy - h/2 - 12)
								s.draw.name.Color = teamColorOrElement(player, baseNameColor)
								s.draw.name.Visible = true
							end)
						else
							if s.draw.name then pcall(function() s.draw.name.Visible = false end) end
						end

						-- tracer
						if module.Config.Tracer and s.draw.tracer then
							pcall(function()
								setLinePoints(s.draw.tracer, screenCenter, Vector2.new(cx, cy))
								s.draw.tracer.Color = teamColorOrElement(player, baseTracerColor)
								s.draw.tracer.Visible = true
							end)
						else
							if s.draw.tracer then pcall(function() s.draw.tracer.Visible = false end) end
						end

						-- health
						if module.Config.Healthbar and s.humanoid and s.humanoid.MaxHealth > 0 and s.draw.health then
							local hp = math.clamp(s.humanoid.Health / s.humanoid.MaxHealth, 0, 1)
							local barH = h
							local bx = cx - w/2 - 8
							local by = cy - barH/2
							pcall(function()
								s.draw.health.Position = Vector2.new(bx, by + (1 - hp) * barH)
								s.draw.health.Size = Vector2.new(4, barH * hp)
								local g = math.clamp(hp,0,1)
								s.draw.health.Color = Color3.new(1-g, g, 0)
								s.draw.health.Visible = true
							end)
						else
							if s.draw.health then pcall(function() s.draw.health.Visible = false end) end
						end

						-- skeleton
						if module.Config.Skeleton then
							local used = 0
							for _,pair in ipairs(bonePairs) do
								local aName, bName = pair[1], pair[2]
								local a = player.Character:FindFirstChild(aName) or player.Character:FindFirstChild(aName.."Part")
								local b = player.Character:FindFirstChild(bName) or player.Character:FindFirstChild(bName.."Part")
								if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
									local pa, va = worldToScreen(a.Position)
									local pb, vb = worldToScreen(b.Position)
									if va and vb then
										used = used + 1
										local line = s.draw.skeleton[used]
										if line then
											setLinePoints(line, pa, pb)
											line.Color = teamColorOrElement(player, baseSkeletonColor)
											line.Visible = true
										end
									end
								end
							end
							for i = used + 1, #s.draw.skeleton do
								local ln = s.draw.skeleton[i]
								if ln then pcall(function() ln.Visible = false end) end
							end
						else
							for _,ln in pairs(s.draw.skeleton) do if ln then pcall(function() ln.Visible = false end) end end
						end

						-- head dot
						if module.Config.HeadDot and s.draw.headDot then
							local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("head")
							if head and head:IsA("BasePart") then
								local pos, vis = worldToScreen(head.Position + Vector3.new(0,0.2,0))
								if vis then
									pcall(function()
										s.draw.headDot.Position = pos
										s.draw.headDot.Color = teamColorOrElement(player, module.Config.Colors.HeadDot)
										s.draw.headDot.Visible = true
									end)
								else
									pcall(function() s.draw.headDot.Visible = false end)
								end
							else
								pcall(function() s.draw.headDot.Visible = false end)
							end
						else
							if s.draw.headDot then pcall(function() s.draw.headDot.Visible = false end) end
						end

						-- tool label
						if module.Config.ToolESP and s.draw.toolLabel then
							local tool = getToolName(player.Character)
							if tool then
								pcall(function()
									s.draw.toolLabel.Text = tool
									s.draw.toolLabel.Position = Vector2.new(cx, cy + h/2 + 8)
									s.draw.toolLabel.Color = teamColorOrElement(player, module.Config.Colors.Tool)
									s.draw.toolLabel.Visible = true
								end)
							else
								pcall(function() s.draw.toolLabel.Visible = false end)
							end
						else
							if s.draw.toolLabel then pcall(function() s.draw.toolLabel.Visible = false end) end
						end
					end
				end
			end
		else
			if s then hideAllDrawsFor(s) end
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
		if s.draw then
			for _,v in pairs(s.draw) do
				if type(v) == "table" then
					for _,d in pairs(v) do if d and d.Destroy then pcall(function() d:Destroy() end) end end
				else
					if v and v.Destroy then pcall(function() v:Destroy() end) end
				end
			end
		end
		if s.highlight and s.highlight.Parent then pcall(function() s.highlight:Destroy() end) end
	end
	espStore = {}
	for _,pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer then onPlayerAdded(pl) end end
end

function module.SetConfig(tbl)
	if type(tbl) ~= "table" then return end
	for k,v in pairs(tbl) do
		if k == "Colors" and type(v) == "table" then
			for name,clr in pairs(v) do
				if type(clr) == "table" and clr.r and clr.g and clr.b then
					module.Config.Colors[name] = Color3.fromRGB(clr.r, clr.g, clr.b)
				elseif type(clr) == "string" then
					-- try JSON decode if passed as string table
					pcall(function()
						local HttpService = game:GetService("HttpService")
						local ok, dec = pcall(function() return HttpService:JSONDecode(clr) end)
						if ok and type(dec) == "table" and dec.r then
							module.Config.Colors[name] = Color3.fromRGB(dec.r, dec.g, dec.b)
						end
					end)
				end
			end
		elseif k ~= "Font" then
			module.Config[k] = v
		end
	end
end

return module
