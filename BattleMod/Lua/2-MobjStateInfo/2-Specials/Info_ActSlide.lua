freeslot(
	'spr_flob',
	's_fangchar_lob1',
	's_fangchar_lob2',
	's_fangchar_lob3',
	's_fang_slide',
	'spr_cbom',
	's_colorbomb1',
	's_colorbomb2'
)

states[S_FANG_SLIDE] = {
	sprite = SPR_PLAY,
	frame = SPR2_FLY_,
	tics = -1,
	nextstate = S_PLAY_STND,
	action = function(mo) mo.player.panim = PA_ROLL end
}

//Fang lob animation
states[S_FANGCHAR_LOB1] = {
	sprite = SPR_FLOB,
	frame = A
}

states[S_FANGCHAR_LOB2] = {
	sprite = SPR_FLOB,
	frame = B
}

states[S_FANGCHAR_LOB3] = {
	sprite = SPR_FLOB,
	frame = C
}

//overwritting some bomb states to prevent it from using A_GhostMe
states[S_FBOMB1] = {
	sprite = SPR_FBOM,
	frame = A,
	tics = 1,
	nextstate = S_FBOMB2
}

states[S_FBOMB2] = {
	sprite = SPR_FBOM,
	frame = B,
	tics = 1,
	nextstate = S_FBOMB1
}

//Fang's team-colored bomb

states[S_COLORBOMB1] = {
	sprite = SPR_CBOM,
	frame = A,
	tics = 1,
	nextstate = S_COLORBOMB2
}

states[S_COLORBOMB2] = {
	sprite = SPR_CBOM,
	frame = B,
	tics = 1,
	nextstate = S_COLORBOMB1
}

states[S_FBOMB_EXPL2] = {
	sprite = SPR_BARX,
	frame = 1|FF_FULLBRIGHT,
	tics = 2,
	nextstate = S_FBOMB_EXPL3
}