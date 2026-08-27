extends GutTest


func test_attack():
	var game := Game.new(6)
	var attacker := game.knife_holder
	var target: Character = game.get_other_characters(attacker).front()
	var attack := Attack.new(game, attacker, target)
	attack.apply_attack()
	assert_eq(target.unassigned_wounds.size(), 1)
