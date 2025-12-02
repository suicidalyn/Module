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
		t.Color = cfg.Colors.Name
		t.Visible = false
	end
	return { Text = t }
end

function M.Update(s, player, cx, cy, dist, teamColor)
	if not s or not s.Text then return end
	local txt = player.Name
	if type(dist) == "number" then txt = txt .. " ["..tostring(dist).."m]" end
	pcall(function()
		s.Text.Text = txt
		s.Text.Position = Vector2.new(cx, cy - 30)
		s.Text.Color = teamColor or s.Text.Color
		s.Text.Visible = true
	end)
end

function M.Hide(s)
	if s and s.Text then pcall(function() s.Text.Visible = false end) end
end

function M.Destroy(s)
	if s and s.Text and s.Text.Destroy then pcall(function() s.Text:Destroy() end) end
end

return M
