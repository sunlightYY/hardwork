-- tools/gen_sprites.lua
-- 生成角色贴图：主角 / 同事 / 主管。
-- 每张 96x160：4 方向 x 3 帧（idle, walk1, walk2）+ 第 5 行坐姿。
-- 运行：aseprite -b --script tools/gen_sprites.lua

local ART = "assets/art/"
local TILE = 48
local S = 1.5

local function C(r, g, b, a)
	return Color { r = r, g = g, b = b, a = a or 255 }
end

local LINE = C(14, 15, 19)

local PALETTES = {
	{
		file = "player.png",
		hair = C(30, 32, 38),
		hair_hi = C(52, 56, 66),
		skin = C(242, 203, 168),
		skin_d = C(212, 166, 128),
		shirt = C(249, 251, 254),
		shirt_d = C(208, 218, 232),
		pants = C(38, 41, 49),
		pants_d = C(26, 28, 34),
		shoe = C(15, 16, 21),
		suit = false,
	},
	{
		file = "coworker.png",
		hair = C(60, 48, 40),
		hair_hi = C(84, 68, 57),
		skin = C(238, 198, 164),
		skin_d = C(208, 160, 124),
		shirt = C(226, 234, 245),
		shirt_d = C(194, 206, 222),
		pants = C(45, 49, 58),
		pants_d = C(32, 35, 42),
		shoe = C(20, 22, 28),
		suit = false,
	},
	{
		file = "supervisor.png",
		hair = C(22, 23, 28),
		hair_hi = C(40, 42, 50),
		skin = C(236, 196, 162),
		skin_d = C(204, 158, 122),
		shirt = C(240, 243, 248),
		shirt_d = C(206, 212, 223),
		pants = C(24, 26, 32),
		pants_d = C(16, 17, 21),
		shoe = C(11, 12, 16),
		suit = true,
		jacket = C(28, 30, 37),
		jacket_d = C(18, 19, 24),
		tie = C(150, 38, 46),
	},
}

local function rect(img, x, y, w, h, c)
	local x0 = math.floor(x * S + 0.5)
	local y0 = math.floor(y * S + 0.5)
	local x1 = math.floor((x + w) * S + 0.5)
	local y1 = math.floor((y + h) * S + 0.5)
	for j = y0, y1 - 1 do
		for i = x0, x1 - 1 do
			img:drawPixel(i, j, c)
		end
	end
end

local function span(img, y, x1, x2, c)
	rect(img, x1, y, x2 - x1 + 1, 1, c)
end

local function outline(img)
	local w, h = img.width, img.height
	local copy = Image(w, h)
	copy:drawImage(img, Point(0, 0))
	for y = 0, h - 1 do
		for x = 0, w - 1 do
			if app.pixelColor.rgbaA(copy:getPixel(x, y)) == 0 then
				local touch = false
				if x > 0 and app.pixelColor.rgbaA(copy:getPixel(x - 1, y)) > 0 then touch = true end
				if x < w - 1 and app.pixelColor.rgbaA(copy:getPixel(x + 1, y)) > 0 then touch = true end
				if y > 0 and app.pixelColor.rgbaA(copy:getPixel(x, y - 1)) > 0 then touch = true end
				if y < h - 1 and app.pixelColor.rgbaA(copy:getPixel(x, y + 1)) > 0 then touch = true end
				if touch then img:drawPixel(x, y, LINE) end
			end
		end
	end
end

local function torso_down(img, p)
	if p.suit then
		rect(img, 10, 16, 12, 6, p.jacket)
		rect(img, 14, 16, 4, 5, p.shirt)
		rect(img, 15, 17, 2, 4, p.tie)
		rect(img, 10, 22, 12, 1, p.jacket_d)
	else
		rect(img, 10, 16, 12, 6, p.shirt)
		rect(img, 10, 22, 12, 1, p.shirt_d)
	end
end

local function torso_up(img, p)
	if p.suit then
		rect(img, 10, 16, 12, 6, p.jacket)
		rect(img, 15, 17, 1, 5, p.jacket_d)
	else
		rect(img, 10, 16, 12, 6, p.shirt)
		rect(img, 15, 17, 1, 5, p.shirt_d)
	end
	rect(img, 10, 22, 12, 1, p.shirt_d)
end

local function arms_down(img, p)
	local sleeve = p.shirt
	if p.suit then sleeve = p.jacket end
	rect(img, 8, 17, 2, 6, sleeve)
	rect(img, 22, 17, 2, 6, sleeve)
	rect(img, 8, 22, 2, 2, p.skin)
	rect(img, 22, 22, 2, 2, p.skin)
end

local function legs_down(img, p, step)
	rect(img, 11, 23, 10, 4, p.pants)
	rect(img, 15, 25, 2, 3, p.pants_d)
	if step == 1 then
		rect(img, 10, 26, 5, 2, p.shoe)
		rect(img, 17, 28, 5, 2, p.shoe)
	elseif step == 2 then
		rect(img, 11, 28, 5, 2, p.shoe)
		rect(img, 17, 26, 5, 2, p.shoe)
	else
		rect(img, 11, 27, 5, 2, p.shoe)
		rect(img, 17, 27, 5, 2, p.shoe)
	end
end

local function down(img, step, p)
	span(img, 5, 12, 19, p.hair)
	span(img, 6, 11, 20, p.hair)
	span(img, 7, 10, 21, p.hair)
	span(img, 8, 10, 21, p.hair)
	span(img, 8, 13, 18, p.hair_hi)
	span(img, 9, 10, 21, p.hair)
	span(img, 10, 10, 11, p.hair)
	span(img, 10, 20, 21, p.hair)
	span(img, 11, 10, 11, p.hair)
	span(img, 11, 20, 21, p.hair)
	rect(img, 12, 9, 8, 6, p.skin)
	rect(img, 13, 11, 2, 2, p.hair)
	rect(img, 17, 11, 2, 2, p.hair)
	rect(img, 15, 13, 2, 1, p.skin_d)
	rect(img, 14, 15, 4, 1, p.skin)
	torso_down(img, p)
	arms_down(img, p)
	legs_down(img, p, step)
end

local function up(img, step, p)
	span(img, 5, 12, 19, p.hair)
	span(img, 6, 11, 20, p.hair)
	span(img, 7, 10, 21, p.hair)
	span(img, 8, 10, 21, p.hair)
	span(img, 8, 13, 18, p.hair_hi)
	rect(img, 10, 9, 12, 7, p.hair)
	rect(img, 15, 15, 2, 1, p.skin_d)
	torso_up(img, p)
	arms_down(img, p)
	legs_down(img, p, step == 2 and 2 or 0)
end

local function side(img, step, p)
	span(img, 5, 12, 20, p.hair)
	span(img, 6, 11, 21, p.hair)
	span(img, 7, 11, 21, p.hair)
	span(img, 8, 11, 21, p.hair)
	rect(img, 17, 9, 5, 5, p.skin)
	rect(img, 20, 11, 2, 2, p.hair)
	rect(img, 19, 14, 3, 1, p.skin_d)
	rect(img, 16, 15, 3, 1, p.skin_d)
	if p.suit then
		rect(img, 12, 16, 9, 6, p.jacket)
		rect(img, 17, 16, 3, 5, p.shirt)
		rect(img, 18, 17, 2, 4, p.tie)
	else
		rect(img, 12, 16, 9, 6, p.shirt)
		rect(img, 12, 21, 9, 1, p.shirt_d)
	end
	rect(img, 15, 17, 3, 5, p.shirt)
	rect(img, 15, 22, 3, 2, p.skin)
	rect(img, 13, 23, 8, 4, p.pants)
	rect(img, 13, 23, 8, 1, p.pants_d)
	if step == 1 then
		rect(img, 11, 26, 6, 2, p.shoe)
		rect(img, 16, 28, 6, 2, p.shoe)
	elseif step == 2 then
		rect(img, 12, 28, 6, 2, p.shoe)
		rect(img, 15, 26, 6, 2, p.shoe)
	else
		rect(img, 13, 27, 7, 2, p.shoe)
	end
end

local function sit(img, _step, p)
	span(img, 5, 13, 18, p.hair)
	span(img, 6, 12, 19, p.hair)
	span(img, 7, 11, 20, p.hair)
	span(img, 8, 11, 20, p.hair)
	span(img, 9, 11, 20, p.hair)
	span(img, 10, 11, 20, p.hair)
	span(img, 11, 12, 19, p.hair)
	span(img, 8, 14, 17, p.hair_hi)
	rect(img, 13, 12, 6, 1, p.skin_d)
	if p.suit then
		rect(img, 9, 13, 14, 7, p.jacket)
		rect(img, 15, 14, 2, 5, p.tie)
		rect(img, 9, 19, 14, 1, p.jacket_d)
	else
		rect(img, 9, 13, 14, 7, p.shirt)
		rect(img, 9, 19, 14, 1, p.shirt_d)
	end
	rect(img, 8, 14, 2, 6, p.suit and p.jacket or p.shirt)
	rect(img, 22, 14, 2, 6, p.suit and p.jacket or p.shirt)
	rect(img, 8, 20, 2, 2, p.skin)
	rect(img, 22, 20, 2, 2, p.skin)
	rect(img, 11, 21, 10, 4, p.pants)
	rect(img, 15, 22, 2, 3, p.pants_d)
end

local plan = {
	{ 0, down, false },
	{ 1, up, false },
	{ 2, side, true },
	{ 3, side, false },
	{ 4, sit, false },
}

for _, p in ipairs(PALETTES) do
	local sheet = Image(144, 240)
	sheet:clear(Color { r = 0, g = 0, b = 0, a = 0 })

	for _, entry in ipairs(plan) do
		local row = entry[1]
		local draw = entry[2]
		local mirror = entry[3]
		for step = 0, 2 do
			local cell = Image(TILE, TILE)
			cell:clear(Color { r = 0, g = 0, b = 0, a = 0 })
			draw(cell, step, p)
			if mirror then
				local flipped = Image(TILE, TILE)
				flipped:clear(Color { r = 0, g = 0, b = 0, a = 0 })
				for y = 0, TILE - 1 do
					for x = 0, TILE - 1 do
						flipped:drawPixel(TILE - 1 - x, y, cell:getPixel(x, y))
					end
				end
				cell = flipped
			end
			outline(cell)
			sheet:drawImage(cell, Point(step * TILE, row * TILE))
		end
	end

	local spr = Sprite(144, 240, ColorMode.RGB)
	spr:newCel(spr:newLayer(), 1, sheet, Point(0, 0))
	spr:saveCopyAs(ART .. p.file)
end
