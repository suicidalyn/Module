local Utils = __ESP_REQUIRE("Utils.lua")

local M = {}

function M.Create(cfg)
	local bar = Utils.NewDrawing("Square")
	if bar then
		bar.Filled = true
		bar.Transparency = 1
		bar.Thickness = 1
		bar.Color = cfg.Colors.Health
		bar.Size = Vector2.new(4,0)
		bar.Visible = false
	end
	return { Bar = bar }
end

function M.Update(s, player, cx, cy, w, h)
	if not s or not s.Bar then return end
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.MaxHealth <= 0 then pcall(function() s.Bar.Visible = false end) return end
	local hp = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
	local bx = cx - w/2 - 8
	local by = cy - h/2
	pcall(function()
		s.Bar.Position = Vector2.new(bx, by + (1 - hp) * h)
		s.Bar.Size = Vector2.new(4, h * hp)
		local g = math.clamp(hp,0,1)
		s.Bar.Color = Color3.new(1-g, g, 0)
		s.Bar.Visible = true
	end)
end

function M.Hide(s)
	if s and s.Bar then pcall(function() s.Bar.Visible = false end) end
end

function M.Destroy(s)
	if s and s.Bar and s.Bar.Destroy then pcall(function() s.Bar:Destroy() end) end
end

return M
