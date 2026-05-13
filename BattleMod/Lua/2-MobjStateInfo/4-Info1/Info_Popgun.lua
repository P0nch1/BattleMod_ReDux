mobjinfo[MT_CORK].speed = 46*FRACUNIT

freeslot(
    "spr_fair",
    "spr_bgun",
	"s_fang_airshot",
	"s_fang_airshot1",
	"s_fang_airshot2",
	"s_fang_airshot3",
	"s_fang_bceshot",
	"s_fang_bceshot1"
)
states[S_FANG_AIRSHOT] = {
	sprite = SPR_FAIR,
	frame = A,
	nextstate = S_FANG_AIRSHOT1
}
states[S_FANG_AIRSHOT1] = {
	sprite = SPR_FAIR,
	frame = B,
	nextstate = S_FANG_AIRSHOT2
}
states[S_FANG_AIRSHOT2] = {
	sprite = SPR_FAIR,
	frame = C,
	nextstate = S_FANG_AIRSHOT3
}
states[S_FANG_AIRSHOT3] = {
	sprite = SPR_FAIR,
	frame = D,
	nextstate = S_FANG_AIRSHOT3
}
states[S_FANG_BCESHOT] = {
        sprite = SPR_BGUN,
        frame = A,
		nextstate = S_FANG_BCESHOT1,
}
states[S_FANG_BCESHOT1] = {
        sprite = SPR_BGUN,
        frame = B,
		nextstate = S_FANG_BCESHOT,
}