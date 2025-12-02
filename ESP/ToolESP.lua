local Utils = __ESP_REQUIRE("Utils.lua")

local M = {}

function M.Create(cfg)
	local t = Utils.NewDrawing("Text")
	if t then
		t.Size = 14
		t.Center = true
		t.Outline = true
		t.OutlineColor = Color3.new(0,0,0)
		t.Font = cfg.Font or Drawing.Fonts.Plex
		t.Color = cfg.Colors.Tool
		t.Visible = false
	end
	return { Label = t }
end

function M.Update(s, player, cx, cy, h, teamColor)
	if not s or not s.Label then return end
	local tool = nil
	if player.Character then
		for _,v in pairs(player.Character:GetChildren()) do
			if v:IsA("Tool") then tool = v.Name break end
		end
	end
	if tool then
		pcall(function() s.Label.Text = tool; s.Label.Position = Vector2.new(cx, cy + h/2 + 8); s.Label.Color = teamColor or s.Label.Color; s.Label.Visible = true end)
	else
		pcall(function() s.Label.Visible = false end)
	end
end

function M.Hide(s)
	if s and s.Label then pcall(function() s.Label.Visible = false end) end
end

function M.Destroy(s)
	if s and s.Label and s.Label.Destroy then pcall(function() s.Label:Destroy() end) end
end

return M
