local Utils = __ESP_REQUIRE("Utils.lua")

local M = {}

function M.Create(cfg)
	local box = Utils.NewDrawing("Square")
	if box then
		box.Filled = false
		box.Thickness = 1
		box.Transparency = 1
		box.Color = cfg.Colors.Box
		box.Visible = false
	end
	local outline = Utils.NewDrawing("Square")
	if outline then
		outline.Filled = false
		outline.Thickness = 3
		outline.Transparency = 1
		outline.Color = Color3.new(0,0,0)
		outline.Visible = false
	end
	return { Box = box, Outline = outline }
end

function M.Update(s, cx, cy, w, h, teamColor)
	if not s or not s.Box then return end
	local clr = teamColor or s.Box.Color or Color3.fromRGB(255,255,255)
	pcall(function()
		s.Box.Size = Vector2.new(w, h)
		s.Box.Position = Vector2.new(cx - w/2, cy - h/2)
		s.Box.Color = clr
		s.Box.Visible = true
	end)
	if s.Outline then
		pcall(function()
			s.Outline.Size = Vector2.new(w+4, h+4)
			s.Outline.Position = Vector2.new(cx - (w+4)/2, cy - (h+4)/2)
			s.Outline.Visible = true
		end)
	end
end

function M.Hide(s)
	if not s then return end
	if s.Box then pcall(function() s.Box.Visible = false end) end
	if s.Outline then pcall(function() s.Outline.Visible = false end) end
end

function M.Destroy(s)
	if not s then return end
	if s.Box and s.Box.Destroy then pcall(function() s.Box:Destroy() end) end
	if s.Outline and s.Outline.Destroy then pcall(function() s.Outline:Destroy() end) end
end

return M
