local Camera = workspace.CurrentCamera

local Utils = {}

function Utils.NewDrawing(kind)
	local ok,obj = pcall(function() return Drawing.new(kind) end)
	if ok and obj then return obj end
	return nil
end

function Utils.WorldToScreen(pos)
	local ok, v, vis = pcall(function() return Camera:WorldToViewportPoint(pos) end)
	if not ok or not v then return Vector2.new(0,0), false end
	return Vector2.new(v.X, v.Y), vis
end

function Utils.SetLinePoints(line, pa, pb)
	pcall(function()
		if line.From ~= nil then line.From = pa end
		if line.To ~= nil then line.To = pb end
		if line.PointA ~= nil then line.PointA = pa end
		if line.PointB ~= nil then line.PointB = pb end
	end)
end

function Utils.ClampToEdge(worldPos)
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	local p, vis = Utils.WorldToScreen(worldPos)
	if vis then return p, true end
	local cam = Camera
	local ok, screenPoint, onScreen = pcall(function() return Camera:WorldToViewportPoint(worldPos) end)
	local sx = screenPoint and screenPoint.X or center.X
	local sy = screenPoint and screenPoint.Y or center.Y
	local dx = sx - center.X
	local dy = sy - center.Y
	if dx == 0 and dy == 0 then return center, false end
	local w = Camera.ViewportSize.X/2
	local h = Camera.ViewportSize.Y/2
	local nx = dx / math.abs(dx)
	local ny = dy / math.abs(dy)
	local tx = (dx > 0) and (w / math.abs(dx)) or (w / math.abs(dx))
	local ty = (dy > 0) and (h / math.abs(dy)) or (h / math.abs(dy))
	local t = math.min(math.abs(w/dx), math.abs(h/dy))
	if t == math.huge or t ~= t then t = 1 end
	local ex = center.X + dx * (t * 0.98)
	local ey = center.Y + dy * (t * 0.98)
	ex = math.clamp(ex, 10, Camera.ViewportSize.X - 10)
	ey = math.clamp(ey, 10, Camera.ViewportSize.Y - 10)
	return Vector2.new(ex, ey), false
end

function Utils.ColorToTable(c)
	return { r = math.floor(c.R*255 + 0.5), g = math.floor(c.G*255 + 0.5), b = math.floor(c.B*255 + 0.5) }
end

function Utils.TableToColor(t)
	if type(t) ~= "table" then return Color3.fromRGB(255,255,255) end
	return Color3.fromRGB(t.r or 255, t.g or 255, t.b or 255)
end

return Utils
