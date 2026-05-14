mobjinfo[MT_CORK].speed = 46*FRACUNIT

freeslot(
    "spr_fair",
    "spr_bgun",
	"s_fang_airshot",
	"s_fang_bceshot"
)
states[S_FANG_AIRSHOT] = {
	sprite = SPR_FAIR,
	frame = A,
	tics = 2,
	nextstate = S_FANG_AIRSHOT,
	action = function(mo)
		local frame = mo.frame & FF_FRAMEMASK
		local frames = skins[mo.skin].sprites[mo.sprite2 & FF_FRAMEMASK].numframes
	
		print("active")
		print(frame)
		if frame == frames - 1 then
			-- we hit the limit, don't loop the animation
			mo.tics = mo.player.weapondelay or 0
			print("limit")
		end
	end
}
states[S_FANG_BCESHOT] = {
        sprite = SPR_BGUN,
        frame = A,
		nextstate = S_FANG_BCESHOT,
}