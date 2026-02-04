local B = CBW_Battle
local R = B.Ruby
local CP = B.ControlPoint
local D = B.Diamond
local F = B.CTF
local C = B.Bank

addHook("MobjThinker", B.BattleShieldThinker, MT_BATTLESHIELD)
addHook("MobjThinker", B.NegaShieldThinker, MT_NEGASHIELD)
addHook("MobjThinker", B.InstaFlip, MT_INSTASHIELD)
addHook("MobjThinker", B.StunBreakVFXThinker, MT_STUNBREAK)
addHook("MobjThinker",function(mo) B.EnergyGather(mo,mo.target,mo.extravalue1,mo.extravalue2) end,MT_ENERGYGATHER)
addHook("MobjThinker", B.TargetDummyThinker, MT_TARGETDUMMY)

//Shields (yeah, this is pretty messy...)
local colorsh = function(mo, redcol, bluecol)
	B.OverlayHide(mo,mo.target)
	
	if mo.colorized return end
	local target = mo.target
	if target and target.valid and not target.player and target.target and target.target.player
		target = target.target
	end
	
	if not (G_GametypeHasTeams() and target and target.valid and target.player and target.player.valid and target.player.ctfteam)
		return
	end
	
	if (target.player.ctfteam == 1) and redcol
		mo.color = redcol
		mo.colorized = true
		return
		
	elseif (target.player.ctfteam == 2) and bluecol
		mo.color = bluecol
		mo.colorized = true
		return
	end
end

local colorsh2 = function(mo)
	if mo.state >= S_ARMA1 and mo.state <= S_ARMB32
		colorsh(mo,nil,SKINCOLOR_PURPLE)
		return
	end
	if mo.state >= S_ZAPS1 and mo.state <= S_ZAPSB11
		colorsh(mo,SKINCOLOR_SUPERRED3,SKINCOLOR_SUPERSKY2)
		return
	end
	if mo.state >= S_FIRS1 and mo.state <= S_FIRSB10
		colorsh(mo,nil,SKINCOLOR_CYAN)
		return
	end
	if mo.state >= S_BUBS1 and mo.state <= S_BUBSB6
		colorsh(mo,SKINCOLOR_SUPERGOLD1,nil)
		return
	end
	if mo.state >= S_ELEMF1 and mo.state <= S_ELEMF10
		colorsh(mo,nil,SKINCOLOR_SAPPHIRE)
		return
	end
	B.OverlayHide(mo,mo.target)
end

B.RestoreTailsFollowMobj = function(p, mobj) -- cry
	if not (p and p.mo and p.mo.skin == "tails") then return end
	if (mobj == nil) then mobj = p.followmobj end
	if not (mobj) then return end

	if p.mo.state == S_PLAY_LEDGE_GRAB 
	or p.mo.state == S_PLAY_LEDGE_RELEASE
        mobj.state = S_TAILSOVERLAY_PLUS60DEGREES
		P_MoveOrigin(mobj,
		p.mo.x-P_ReturnThrustX(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustX(mobj, mobj.angle, mobj.scale),
		p.mo.y-P_ReturnThrustY(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustY(mobj, mobj.angle, mobj.scale),
		p.mo.z+FixedMul(4*p.mo.scale, mobj.scale)
		)
		mobj.angle = p.drawangle
		return true
    end

	if mobj.state == S_INVISIBLE
		mobj.state = S_TAILSOVERLAY_PLUS30DEGREES
	end

	if (p.skidtime or mobj.restorebuffer)
	and P_IsValidSprite2(mobj, SPR2_WALK)
		mobj.state = S_TAILSOVERLAY_PLUS30DEGREES
		mobj.frame = 512 + min(7,1+p.speed/(p.mo.scale*2))
		P_MoveOrigin(mobj,
		p.mo.x-P_ReturnThrustX(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustX(mobj, mobj.angle, mobj.scale),
		p.mo.y-P_ReturnThrustY(mobj, p.drawangle, 2*p.mo.scale)+P_ReturnThrustY(mobj, mobj.angle, mobj.scale),
		p.mo.z+FixedMul(2*p.mo.scale, mobj.scale)
		)
		mobj.angle = p.drawangle
		mobj.restorebuffer = p.skidtime --+1 frame
		return true
	end
end
addHook("FollowMobj", B.RestoreTailsFollowMobj, MT_TAILSOVERLAY)

addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_CRIMSON,nil) end,MT_ELEMENTAL_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_ORANGE,SKINCOLOR_VAPOR) end,MT_ATTRACT_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_FLAME,SKINCOLOR_SKY) end,MT_WHIRLWIND_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_RED,SKINCOLOR_MIDNIGHT) end,MT_FORCE_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,nil,SKINCOLOR_BLUE) end,MT_ARMAGEDDON_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,nil,SKINCOLOR_DUSK) end,MT_FLAMEAURA_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_RED,nil) end,MT_BUBBLEWRAP_ORB)
addHook("MobjThinker", function(mo) colorsh(mo,SKINCOLOR_RED,SKINCOLOR_SAPPHIRE) end,MT_THUNDERCOIN_ORB)
addHook("MobjThinker", colorsh2,MT_OVERLAY)

B.PityThinker = function(mo) 
	B.OverlayHide(mo,mo.target)
	if gametyperules&GTR_PITYSHIELD or G_GametypeHasTeams()
		local owner = mo.target
		if not(owner and owner.valid and owner.player and owner.player.valid) then return nil end
		mo.color = owner.player.skincolor
		mo.colorized = true
	else
		mo.color = SKINCOLOR_CERULEAN
	end
end
addHook("MobjThinker", B.PityThinker,MT_PITY_ORB)

B.SpinDustThinker = function(mo)
	if mo.changed then
		return
	end
	if (mo.state == S_SPINDUST_FIRE1)
	and (mo.target and mo.target.valid and mo.target.player)
	then
		mo.color = mo.target.player.skincolor
		mo.state = S_TEAMFIRE1
		mo.frame = $|FF_ANIMATE|FF_TRANSMASK
		mo.fuse = TICRATE/2
		mo.destscale = 0
		mo.scalespeed = $/2
		mo.changed = true
	end
end
addHook("MobjThinker", B.SpinDustThinker, MT_SPINDUST)

//visual indicator for tagger
B.BattleTagITtag = function(mo)
	if gametype != GT_BATTLETAG
	or mo.tracerplayer == nil
	or not mo.tracerplayer.valid
	or not mo.tracerplayer.battletagIT
		P_RemoveMobj(mo)
		return
	end
	
	local tracer = mo.tracerplayer.mo
	if tracer != nil and tracer.valid
		mo.flags2 = $ & ~MF2_DONTDRAW
		mo.scale = tracer.scale
		mo.eflags = tracer.eflags
		local zheight
		if tracer.eflags & MFE_VERTICALFLIP
			zheight = tracer.height / 2 * -1
		else
			zheight = tracer.height + tracer.height / 3
		end
		P_MoveOrigin(mo, tracer.x, tracer.y, tracer.z + zheight)
	else
		mo.flags2 = $ | MF2_DONTDRAW
	end
end
addHook("MobjThinker", B.BattleTagITtag, MT_BATTLETAG_IT)

local ARROW_TAGSCALE = 0
local ARROW_CONSTANTSCALE = 1
local ARROW_INVERTSCALE = 2
//thinker for pointer
B.BattleTagPointers = function(mo)
	local delete = false
	local arrowscale = ARROW_TAGSCALE
	local target = mo.target

	if not(B.IsValidPlayer(mo.tracer)) then
		delete = true
	elseif (gametype == GT_BATTLECTF) then
		arrowscale = (mo.allydrop and ARROW_CONSTANTSCALE) or ARROW_INVERTSCALE
		if mo.tracer.player.gotflag then
			target = ({F.RedFlagPos, F.BlueFlagPos})[mo.tracer.player.ctfteam]
		end
		if not(mo.target and mo.target.valid) or ((mo.tracer.player.ctfteam == 1) and not(F.RedFlag and F.RedFlag.valid)) or ((mo.tracer.player.ctfteam == 2) and not(F.BlueFlag and F.BlueFlag.valid))then
			delete = true
		end
	elseif B.TagGametype() then
		arrowscale = ARROW_TAGSCALE
		if ((not(mo.tracer.player.battletagIT) or mo.target.player.battletagIT) or not(B.IsValidPlayer(mo.target))) then
			delete = true
		end
	elseif B.RubyGametype() then
		arrowscale = ARROW_CONSTANTSCALE
		if mo.tracer.player.gotcrystal then
			target = ({R.BlueGoal, R.RedGoal})[mo.tracer.player.ctfteam]
		else
			if R.ID and R.ID.valid then
				if R.ID.target and R.ID.target.valid and R.ID.target.player and R.ID.target.player.gotcrystal then
					target = R.ID.target
				end
			end
		end
		if not(R.ID and R.ID.valid) then
			delete = true
		end
	elseif B.DiamondGametype() then
		arrowscale = ARROW_CONSTANTSCALE
		if mo.tracer.player.gotcrystal then
			target = D.ActivePoint
			if not(target and target.valid) then
				delete = true
			end
		else
			if D.Diamond and D.Diamond.valid then
				if D.Diamond.target and D.Diamond.target.valid and D.Diamond.target.player and D.Diamond.target.player.gotcrystal then
					target = D.Diamond.target
				end
			end
		end
		if not(D.Diamond and D.Diamond.valid) then
			delete = true
		end
	elseif B.CPGametype() then
		arrowscale = ARROW_CONSTANTSCALE
		if CP.ID and CP.Num and CP.ID[CP.Num] and CP.ID[CP.Num].valid and ((CP.Timer <= TICRATE*10) or (CP.Active == true)) then
			target = CP.ID[CP.Num]
		else
			delete = true
		end
	elseif B.SuddenDeath then
		arrowscale = ARROW_CONSTANTSCALE
		if B.ZoneObject and B.ZoneObject.valid then
			target = B.ZoneObject
		else
			delete = true
		end
	end

	if not(target) and not(mo.target and mo.target.valid) then
		delete = true
	end

	if delete then
		if mo.tracer and mo.tracer.valid then
			if mo == mo.tracer.btagpointer then
				mo.tracer.btagpointer = nil
			end

			if mo == mo.tracer.btagpointer2 then
				mo.tracer.btagpointer2 = nil
			end
			mo.tracer.btagpointers = nil
		end
		P_RemoveMobj(mo)
		return
	end
	
	//change the appearance based on perspective
	local cam
	if displayplayer == mo.tracer.player
		cam = camera
	elseif secondarydisplayplayer == mo.tracer.player
		cam = camera2
	end
	if cam != nil
		if cam.chase
			mo.frame = $ | FF_PAPERSPRITE & ~FF_FLOORSPRITE
			mo.renderflags = $ & ~RF_NOSPLATBILLBOARD
			mo.spriteroll = ANGLE_270
		else
			mo.frame = $ | FF_FLOORSPRITE & ~FF_PAPERSPRITE
			mo.renderflags = $ | RF_NOSPLATBILLBOARD
			mo.spriteroll = 0
		end
	end
	mo.drawonlyforplayer = mo.tracer.player
	mo.color = ((gametype == GT_BATTLECTF) and ((mo.allydrop and {skincolor_blueteam, skincolor_redteam}) or {skincolor_redteam, skincolor_blueteam})[mo.tracer.player.ctfteam]) or
			   (B.TagGametype() and mo.target.player.skincolor) or
			   (B.RubyGametype() and (
						(mo.tracer.player.gotcrystal and ({skincolor_blueteam, skincolor_redteam})[mo.tracer.player.ctfteam]) or
						((R.ID and R.ID.valid and R.ID.target and R.ID.target.valid and R.ID.target.player) and ({skincolor_redteam, skincolor_blueteam})[R.ID.target.player.ctfteam]) or
						SKINCOLOR_MAGENTA
					) 
			   ) or
			   (B.DiamondGametype() and (
						D.Diamond and D.Diamond.valid and 
						(D.Diamond.target and D.Diamond.target.valid and 
						D.Diamond.target.player and D.Diamond.target.player.skincolor) or D.Diamond.color
					)
			   ) or
			   (B.CPGametype() and (
						(G_GametypeHasTeams() and (
							((CP.TeamCapAmt[1] > CP.TeamCapAmt[2]) and skincolor_redteam) or
							((CP.TeamCapAmt[2] > CP.TeamCapAmt[1]) and skincolor_blueteam) or
							SKINCOLOR_YELLOW
						)) or
						(CP.LeadCapPlr and CP.LeadCapPlr.skincolor) or 
						mo.tracer.player.skincolor
					)
			   ) or
			   (B.BankGametype() and (
			   			mo.tracer.player.skincolor
					)
			   ) or
			   (B.SuddenDeath and (
			   			mo.tracer.player.skincolor
					)
			   ) or
			   SKINCOLOR_PITCHBLACK --If it's pitch black, something's probably wrong
	local x = mo.tracer.x
	local y = mo.tracer.y
	local z = mo.tracer.z
	if not(target) then
		target = mo.target
	end
	local rx = target.x
	local ry = target.y
	local rz = target.z
	//keep track of how close the targeted runner is
	local h_dist = R_PointToDist2(x, y, rx, ry)
	mo.closedist = R_PointToDist2(0, z, h_dist, rz)
	//point towards the targeted runner
	mo.angle = R_PointToAngle2(x, y, rx, ry)
	local hight = mo.tracer.height / 2
	if mo.tracer.eflags & MFE_VERTICALFLIP
		hight = 0
	end
	P_MoveOrigin(mo, x + P_ReturnThrustX(mo, mo.angle, 75 * mo.tracer.scale), 
			y + P_ReturnThrustY(mo, mo.angle, 75 * mo.tracer.scale), z + hight)
	//change the appearance based on distance of targeted runner
	mo.frame = $ & ~FF_TRANSMASK
	local blink
	mo.closedist = $ / (FRACUNIT * 60)
	if mo.closedist <= 2
		blink = 1
	elseif mo.closedist <= 20

		if arrowscale == ARROW_TAGSCALE then
			mo.scale = mo.tracer.scale
		elseif arrowscale == ARROW_INVERTSCALE then
			mo.scale = mo.tracer.scale / 4
		elseif arrowscale == ARROW_CONSTANTSCALE then
			mo.scale = mo.tracer.scale
		end

		blink = 3
		mo.frame = $ & ~FF_TRANSMASK
	elseif mo.closedist <= 60

		if arrowscale == ARROW_TAGSCALE then
			mo.scale = mo.tracer.scale - (mo.tracer.scale / 4)
		elseif arrowscale == ARROW_INVERTSCALE then
			mo.scale = mo.tracer.scale / 2
		end

		blink = 6
		mo.frame = $ | FF_TRANS10
	elseif mo.closedist <= 180

		if arrowscale == ARROW_TAGSCALE then
			mo.scale = mo.tracer.scale / 2
		elseif arrowscale == ARROW_INVERTSCALE then
			mo.scale = mo.tracer.scale - (mo.tracer.scale / 4)
		end

		blink = 12
		mo.frame = $ | FF_TRANS30
	else

		if arrowscale == ARROW_TAGSCALE then
			mo.scale = mo.tracer.scale / 4
		elseif arrowscale == ARROW_INVERTSCALE then
			mo.scale = mo.tracer.scale
		end

		blink = 24
		mo.frame = $ | FF_TRANS50
	end
	if leveltime % blink == 0
		if blink == 1
			mo.flags2 = $ | MF2_DONTDRAW
		else
			mo.flags2 = $ & ~MF2_DONTDRAW
			if mo.frame & FF_ADD
				mo.frame = $ & ~FF_ADD
			else
				mo.frame = $ | FF_ADD
			end
		end
	end
	if mo.interpolation_fix then
		mo.flags = $ & ~MF_NOSECTOR
	end
	mo.interpolation_fix = true
end
addHook("MobjThinker", B.BattleTagPointers, MT_BTAG_POINTER)