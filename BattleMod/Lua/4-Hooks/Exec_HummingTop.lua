
local state_startup = 1
local state_spinning = 2

addHook("PlayerCanDamage", function(player, mo)
	if (player.mo and player.mo.valid and player.mo.hummingtop_state == state_spinning) and not(mo.player) then
        return true
	end
end)