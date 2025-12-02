local Utils = __ESP_REQUIRE("Utils.lua")

local M = {}

function M.Create(cfg)
	local ln = Utils.NewDrawing("Line")
	if ln then
		ln.Thickness = 1
		ln.Transparency = 1
		ln.Color = cfg.Colors.Tracer
		ln.Visible = false
	end
	return { Line = ln }
end

function M.Update(s, player, screenCenter, teamColor)
	if not s or not s.Line then return end
	local hrp = player and player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso"))
	if not hrp then pcall(function() s.Line.Visible = false end) return end
	local sp, vis = Utils.WorldToScreen(hrp.Position)
	if vis then
		Utils.SetLinePoints(s.Line, screenCenter, sp)
		pcall(function() s.Line.Color = teamColor or s.Line.Color; s.Line.Visible = true end)
	else
		local edge, _ = Utils.ClampToEdge(hrp.Position)
		Utils.SetLinePoints(s.Line, screenCenter, edge)
		pcall(function() s.Line.Color = teamColor or s.Line.Color; s.Line.Visible = true end)
	end
end

function M.Hide(s)
	if s and s.Line then pcall(function() s.Line.Visible = false end) end
end

function M.Destroy(s)
	if s and s.Line and s.Line.Destroy then pcall(function() s.Line:Destroy() end) end
end

return M
