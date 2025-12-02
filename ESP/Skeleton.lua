local Utils = __ESP_REQUIRE("Utils.lua")

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

local M = {}

function M.Create(cfg)
	local lines = {}
	for i=1, #bonePairs do
		local l = Utils.NewDrawing("Line")
		if l then
			l.Thickness = 1
			l.Transparency = 1
			l.Color = cfg.Colors.Skeleton
			l.Visible = false
		end
		table.insert(lines, l)
	end
	return { Lines = lines }
end

function M.Update(s, player, teamColor)
	if not s then return end
	local used = 0
	for i,pair in ipairs(bonePairs) do
		local aName,bName = pair[1], pair[2]
		local a = player.Character:FindFirstChild(aName) or player.Character:FindFirstChild(aName.."Part")
		local b = player.Character:FindFirstChild(bName) or player.Character:FindFirstChild(bName.."Part")
		if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
			local pa, va = Utils.WorldToScreen(a.Position)
			local pb, vb = Utils.WorldToScreen(b.Position)
			if va and vb then
				used = used + 1
				local line = s.Lines[used]
				if line then
					Utils.SetLinePoints(line, pa, pb)
					pcall(function() line.Color = teamColor or line.Color; line.Visible = true end)
				end
			end
		end
	end
	for i = used+1, #s.Lines do
		local ln = s.Lines[i]
		if ln then pcall(function() ln.Visible = false end) end
	end
end

function M.Hide(s)
	if not s then return end
	for _,ln in ipairs(s.Lines) do if ln then pcall(function() ln.Visible = false end) end end
end

function M.Destroy(s)
	if not s then return end
	for _,ln in ipairs(s.Lines) do if ln and ln.Destroy then pcall(function() ln:Destroy() end) end end
end

return M
