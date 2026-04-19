freeslot("S_FANG_SLIDE")

states[S_FANG_SLIDE] = {
	sprite = SPR_PLAY,
	frame = SPR2_FLY_,
	tics = -1,
	nextstate = S_PLAY_STND,
	action = function(mo) mo.player.panim = PA_ROLL end
}