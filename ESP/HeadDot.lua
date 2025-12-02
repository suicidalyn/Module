local Utils = __ESP_REQUIRE("Utils.lua")

local M = {}

function M.Create(cfg)
	local c = Utils.NewDrawing("Circle")
	if c then
		c.Radius = 4
		c.Filled = true
		c.Transparency = 1
		c.Color = cfg.Colors.HeadDot
		c.Visible = false
	end
	return { Dot = c }
end

function M.Update(s, player, teamColor)
	if not s or not s.Dot then return end
	local head = player.Character and (player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("head"))
	if not head then pcall(function() s.Dot.Visible = false end) return end
	local p, vis = Utils.WorldToScreen(head.Position + Vector3.new(0,0.2,0))
	if vis then
		pcall(function() s.Dot.Position = p; s.Dot.Color = teamColor or s.Dot.Color; s.Dot.Visible = true end)
	else
		pcall(function() s.Dot.Visible = false end)
	end
end

function M.Hide(s)
	if s and s.Dot then pcall(function() s.Dot.Visible = false end) end
end

function M.Destroy(s)
	if s and s.Dot and s.Dot.Destroy then pcall(function() s.Dot:Destroy() end) end
end

return M
