local B = CBW_Battle
local cooldown = TICRATE * 2
local cooldown2 = TICRATE * 5
local duration = 3 * TICRATE
local xythrust = 38
local zthrust = 9
local dropspeed = 20
local nojumpwindow = 10

B.Action.Slide_PlayerThink = function(mo)
	local player = mo.player

	local grounded = P_IsObjectOnGround(mo) or mo.eflags & MFE_JUSTHITFLOOR
	local bouncing = player.pflags&PF_BOUNCING
	local activate = player.actiontime == 0 and doaction == 1
	local slide_trigger = activate and not(bouncing)
	local springdrop_trigger = activate and bouncing
	local drop_state = player.actionstate == 1 and bouncing
		and P_MobjFlip(mo)*mo.momz < 0
	local sliding = player.actionstate == 2
		and player.pflags & PF_SPINNING

end

B.Action.Slide = function(mo,doaction)
	local player = mo.player

	//Conditions
	local grounded = P_IsObjectOnGround(mo) or mo.eflags & MFE_JUSTHITFLOOR
	local bouncing = player.pflags&PF_BOUNCING
	local activate = player.actiontime == 0 and doaction == 1
	local slide_trigger = activate and not(bouncing)
	local springdrop_trigger = activate and bouncing
	local drop_state = player.actionstate == 1 and bouncing
		and P_MobjFlip(mo)*mo.momz < 0
	local sliding = player.actionstate == 2
		and player.actiontime

	//Properties
	player.actiontext = "Slide"
	player.actionrings = 5
	if player.pflags&PF_BOUNCING
		player.actiontext = "Spring Drop"
		player.actionrings = 10
	end
	
	//Perform Thrust
	if slide_trigger
		-- thrust player forward
		local speed = max(xythrust * mo.scale, FixedHypot(mo.momx - player.cmomx, mo.momy - player.cmomy) * 3 / 2)

		B.PayRings(player)
		B.ApplyCooldown(player, cooldown2)

		P_InstaThrust(mo, mo.angle, speed)
		player.pflags = ($|PF_SPINNING) & ~(PF_THOKKED|PF_JUMPED|PF_BOUNCING)
		player.actionstate = 2
		player.actiontime = duration
		player.lockjumpframe = nojumpwindow
		mo.state = S_FANG_SLIDE
	end
	
 	//Perform spring drop
	if springdrop_trigger
		//Apply cost, cooldown, state
		B.PayRings(player)
		player.actionstate = 1
		player.actiontime = 1
		//Apply momentum
		mo.momx = $/2
		mo.momy = $/2
		B.ZLaunch(mo,-dropspeed*FRACUNIT,false)
		//Effects
		S_StartSound(mo,sfx_zoom)
		P_SpawnParaloop(mo.x,mo.y,mo.z,mo.scale*128,16,MT_DUST,ANGLE_90,nil,true)
		return
	end
	
	//Drop bombs
	if player.actionstate == 1
	and bouncing
	and (mo.eflags & MFE_JUSTHITFLOOR)
		B.ApplyCooldown(player,cooldown2)
		player.nobombjump = true
		for n = 0, 4
			local bomb = B.throwbomb(mo)
			if bomb and bomb.valid then
				P_InstaThrust(bomb,ANGLE_45+mo.angle+(ANGLE_90*n),mo.scale*4)
				P_SetObjectMomZ(bomb, mo.scale*8*P_MobjFlip(mo))
				bomb.flags = $ &~ (MF_GRENADEBOUNCE)
				bomb.bombtype = 0
			end
		end
		player.actiontime = 0
		player.actionstate = 0
	elseif player.actionstate == 1
	and not bouncing
	or mo.eflags & MFE_SPRUNG then
		player.actiontime = 0
		player.actionstate = 0
	end

	if sliding then
		if grounded then
			player.actiontime = $-1
		end
		if leveltime%8 then
			print("ghost")
			P_SpawnGhostMobj(mo)
		end

		if player.pflags & PF_JUMPED then
			player.actionstate = 0
			player.actiontime = 0
			return
		end

		player.pflags = ($|PF_SPINNING) & ~(PF_THOKKED|PF_JUMPED|PF_BOUNCING)

		if mo.eflags & MFE_JUSTHITFLOOR or mo.eflags & MFE_SPRUNG then
			print("hit floor or sprung")
			mo.state = S_FANG_SLIDE
		end

		if player.actiontime == 0 then
			mo.state = S_PLAY_STND
			mo.momx = $/2
			mo.momy = $/2
			player.actionstate = 0
		end
	end
end

local function fanghop(player)
	local mo = player.mo
	B.ZLaunch(mo, 7 * mo.scale, false)
	mo.state = S_PLAY_JUMP
	mo.momx = $ * -2/3
	mo.momy = $ * -2/3
	player.actionstate = 0
	player.actiontime = 0
	player.pflags = ($ | (PF_JUMPED | PF_STARTJUMP | PF_NOJUMPDAMAGE)) & ~PF_THOKKED
	player.powers[pw_nocontrol] = 16
end

local function iscombatroll(player)
	if not (player and player.valid and player.playerstate == PST_LIVE)
		or not player.mo
		or not (player.actiontime and player.mo.state == S_PLAY_ROLL)
		or not player.mo.health
		return false
	end
	return true
end

B.Fang_PreCollide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
	if iscombatroll(plr[n1])
		plr[n1].fangmarker = true
	end
end

B.Fang_PostCollide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
	if plr[n1] and plr[n1].fangmarker
		plr[n1].fangmarker = nil
	end
end

B.Fang_Collide = function(n1,n2,plr,mo,atk,def,weight,hurt,pain,ground,angle,thrust,thrust2,collisiontype)
	if not (plr[n1] and plr[n1].fangmarker)
		return false
	end
	if (hurt != 1 and n1 == 1) or (hurt != -1 and n1 == 2)
		if not (plr[n2] and plr[n2].fangmarker)
			fanghop(plr[n1])
		end
		if plr[n2]
			B.DoPlayerTumble(plr[n2], 24, angle[n1], mo[n1].scale*3, true, true)
		end
		P_InstaThrust(mo[n2], angle[n2], mo[n1].scale * 5)
		B.ZLaunch(mo[n2], 7 * mo[n2].scale, false)
		return true
	end
end

B.Action.CombatRoll_Priority = function(player)
	local mo = player.mo
	if not (mo and mo.valid) return end
	
	local bouncing = player.pflags&PF_BOUNCING
	local drop_state = player.actionstate == 1 and bouncing
		and P_MobjFlip(mo)*mo.momz < 0
	local thrust_state = player.actiontime and mo.state == S_PLAY_ROLL
		and not(P_IsObjectOnGround(mo)) and player.actiontime < 20
	
	if player.actionstate == 1
		B.SetPriority(player,0,1,"fang_springdrop",2,3,"spring drop")
	elseif player.actionstate == 2
		B.SetPriority(player,1,1,nil,1,1,"combat roll")
	end
end