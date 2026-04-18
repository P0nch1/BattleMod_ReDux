local B = CBW_Battle

-- old and stinky
local y_rest = 200
local y_offscreen = 0
local bouncetics = 50
local waittics = 20
local width = 256
local height = 128
local scrolldelay = TICRATE*2
local scrolltics = TICRATE
local scrolldist = 100
local animtime = TICRATE*4

-- new and fancy
local slideStartTic = 20
	-- the tic where the logo starts sliding
local hitTic = 35
	-- the tic for when the srb2 battle logo hits the srb2 logo out of the way
local logoHitOffset = 90 * FU
	-- the offset for the logo once it collides with the srb2 logo
local logoDamagedSlideTics = 12
	-- the duration for how long the SRB2 logo slides for once hit
	-- this will need to be incredibly fine tuned
local slideTics = 24
	-- how long does sliding last for?
local slideHitOffset = 50 * FU
	-- the offset for the logo while it slides
local scrollRaiseDuration = 35
	-- the duration for how long the scroll takes, rising starts on hitTic
local hitStop = 10
	-- heh....... ring racers...
	-- just kidding i really hate that game - saxa

local function drawScrollingPatch(v, x, y, patch)
	local screenWidth = v.width() * FU / v.dupx()

	-- draw texture based on width
	for x = 
		((x % (patch.width * FU)) - (patch.width * FU)),
		screenWidth,
		patch.width * FU
	do
		v.drawScaled(x, y, FU, patch, V_SNAPTOLEFT|V_SNAPTOTOP)
	end
end

local function drawPaletteRect(v, x, y, width, height, palette, flags)
	local patch = v.cachePatch(string.format("~%03d",palette))

	v.drawStretched(
		x, y,
		FixedDiv(width, patch.width*FU),
		FixedDiv(height, patch.height*FU),
		patch,
		flags or 0
	)
end

-- local drawscroll = function(v,player,cam,x,y,patch,scroll,scrollspeed,bottom)
-- 	local scrolltime = FixedSqrt(min(scrolldelay,leveltime)*FRACUNIT/scrolldelay)
-- 	scrollspeed = FixedMul(scrolltime,$*FRACUNIT)
-- 	local uncovertime = max(leveltime-scrolldelay,0)
-- 	local uncoveramt = FRACUNIT*max(scrolltics-uncovertime,0)/scrolltics
-- 	if bottom == true then
-- 		y = B.FixedLerp($,100,uncoveramt)
-- 	else
-- 		y = B.FixedLerp($,-28,uncoveramt)
-- 	end
	
-- 	patch = v.cachePatch($ or "CHECKER1")
-- 	if scroll == "right" then
-- 		for n = 1, (320/width)+3 do
-- 			local x = x+(((leveltime*scrollspeed/FRACUNIT)%width)+width*(n-3))
-- 			v.draw(x,y,patch,0)
-- 		end
-- 	elseif scroll == "left" then
-- 		for n = 1, (320/width)+3 do
-- 			local x = x-(((leveltime*scrollspeed/FRACUNIT)%width)+width*(n-3))
-- 			v.draw(x,y,patch,0)
-- 		end
-- 	end
-- end

B.TitleTicker = function(v,player,cam)
	if not titlemapinaction then return end

	if leveltime == hitTic then
		S_ChangeMusic("BLTTIL", true)
		S_StartSound(nil, sfx_s243a)
		S_StartSound(nil, sfx_hit00)
	end
end

B.TitleMusicChange = function(old, new)
	if not titlemapinaction then return end
	if not leveltime then return end

	if new == "_title" then
		return old, 0, true, S_GetMusicPosition(), 0, 0
	end
end

B.TitleHUD = function(v,player,cam)
	local screenWidth = v.width() * FU / v.dupx()
	local screenHeight = v.height() * FU / v.dupy()

	-- srb2 logo parameters, taken from f_finale.c
	local logoX = screenWidth / 2 - 160 * FU + 40 * FU
	local logoY = screenHeight / 2 - 100 * FU + 20 * FU
	local logoScale = FU / max(1, min(6, v.dupx()))

	local emblemPatch = v.cachePatch("T"..max(1, min(6, v.dupx())).."EMBL")
	local emblemX = 0 * FU
	local emblemY = 0 * FU

	local ribbonPatch = v.cachePatch("T"..max(1, min(6, v.dupx())).."RIBB01")
	local ribbonX = -FU
	local ribbonY = 68 * FU

	-- the battle logo parameters
	local battleLogoPatch = v.cachePatch("LOGO280A") -- TODO: animate what patch it uses :P
	local battleLogoX = (screenWidth / 2)
	local battleLogoY = (screenHeight / 2) + 100 * FU -- to whoever made the logos offset in the lump instead of in code, i dont like you
	local battleLogoFloatSpeed = FU * 3
	local battleLogoFloatPosition = 6

	-- tween X based on parameters for sliding and all
	if leveltime < hitTic then
		local progress = FixedDiv(max(0, leveltime - slideStartTic), hitTic - slideStartTic)
		battleLogoX = ease.linear(progress, -battleLogoPatch.width * FU, $ - logoHitOffset) -- will have to offset so it appears correctly once hit
	elseif leveltime - hitTic - hitStop < slideTics then
		local progress = FixedDiv(max(0, leveltime - hitTic - hitStop), slideTics)

		if progress < FU / 2 then
			battleLogoX = ease.outquad(progress * 2, $ - logoHitOffset, $ + slideHitOffset)
		else
			battleLogoX = ease.inquad((progress * 2) - FU, $ + slideHitOffset, $)
		end

		local position = battleLogoFloatPosition * cos(FixedAngle(leveltime * battleLogoFloatSpeed))

		position = FixedMul($, progress)
		battleLogoY = $ + position
	else
		local position = battleLogoFloatPosition * cos(FixedAngle(leveltime * battleLogoFloatSpeed))
		battleLogoY = $ + position
	end

	if leveltime >= hitTic and leveltime < hitTic + hitStop then
		-- shake
		battleLogoX = $ + v.RandomRange(-2 * FU, 2 * FU)
		battleLogoY = $ + v.RandomRange(-2 * FU, 2 * FU)
	end

	-- scrolling parameters
	local scrollDuration = 65
		-- the general duration for the scrolling
	local scrollOffsetDuration = 40
		-- for each parallax "layer", if you wanna call it that, this is the offset
		-- so 50 turns to 60 on the second layer drawn and whatnot
	local scrollLayers = 3
		-- speaking of layers, this is how much layers get drawn on both sides of the screen
	local scrollY = 40*FU
		-- the Y for the scroll, p.s. its applied in reverse for the other side
	local scrollOffsetY = -10*FU
		-- the offset for each layer
		-- follows the same rule as scrollOffsetDuration
	local scrollPatches = {
		{"CHECKER7", "CHECKER3", "CHECKER8"},
		{"CHECKER1", "CHECKER4", "CHECKERA"}
	}
		-- covers both sides

	if leveltime < hitTic + scrollRaiseDuration then
		local progress = FixedDiv(max(0, leveltime - hitTic), scrollRaiseDuration)

		scrollY = ease.outquad(progress, 0, $)
		scrollOffsetY = ease.outquad(progress, 0, $)
	end

	-- draw scroll

	for layer = 1, scrollLayers do
		local duration = scrollDuration + scrollOffsetDuration * (layer - 1)
		local tics = leveltime % duration
		local progress = FixedDiv(tics, duration) -- 0-FU scale :money_mouth:

		for side = 1, 2 do
			local reversed = side == 2 -- if we should make it draw from below

			local patch = v.cachePatch(scrollPatches[side][layer])
			local x = patch.width * progress
			local y = scrollY + scrollOffsetY * (layer - 1)

			if reversed then
				y = screenHeight - $
				x = -$
			else
				y = $ - patch.height * FU -- kinda important
			end

			drawScrollingPatch(v, x, y, patch)
		end
	end

	-- draw background stuff? i guess? is this considered a background if it just fades
	if leveltime < hitTic then
		drawPaletteRect(v, 0, 0, screenWidth, screenHeight, 31, V_SNAPTOLEFT|V_SNAPTOTOP)
	elseif leveltime - hitTic < 10 then
		drawPaletteRect(v, 0, 0, screenWidth, screenHeight, 0, V_SNAPTOLEFT|V_SNAPTOTOP|(V_10TRANS * (leveltime - hitTic)))
	end

	-- draw logo :P
	if leveltime < hitTic + logoDamagedSlideTics + hitStop then
		local progress = FixedDiv(max(0, leveltime - hitTic - hitStop), logoDamagedSlideTics)
		local x = ease.linear(progress, logoX, logoX + screenWidth)
		local y = logoY

		if leveltime >= hitTic and leveltime < hitTic + hitStop then
			-- shake
			x = $ + v.RandomRange(-2 * FU, 2 * FU)
			y = $ + v.RandomRange(-2 * FU, 2 * FU)
		end

		v.drawScaled(x + emblemX, y + emblemY, logoScale, emblemPatch, V_SNAPTOLEFT|V_SNAPTOTOP)
		v.drawScaled(x + ribbonX, y + ribbonY, logoScale, ribbonPatch, V_SNAPTOLEFT|V_SNAPTOTOP)
	end
	v.drawScaled(battleLogoX, battleLogoY, FU, battleLogoPatch, V_SNAPTOLEFT|V_SNAPTOTOP)

	//Debug
-- 	v.drawString(0,0,leveltime,0,"left")
-- 	v.drawString(0,0,tostring(B.BattleCampaign()),0,"left")
end