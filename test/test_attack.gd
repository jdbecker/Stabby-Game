extends GutTest


func test_attack():
	var game := Game.new(6)
	var attacker := game.knife_holder
	var target: Character = game.get_other_characters(attacker).front()
	var attack := Attack.new(attacker, target)
	attack.wound_requested.connect(game.suffer_wound)
	attack.knife_holder_requested.connect(game.set_knife_holder)
	attack.apply_attack()
	assert_eq(target.unassigned_wounds.size(), 1)
