extends GutTest

const RANK := CharacterStats.Wound.RANK
const RED := CharacterStats.Wound.RED
const BLUE := CharacterStats.Wound.BLUE
const UNKNOWN := CharacterStats.Wound.UNKNOWN
const ANY := CharacterStats.Wound.ANY


func test_set_knife_holder_moves_freely():
	var game := Game.new(6)
	for c: Character in game.characters:
		game.set_knife_holder(c)
		assert_eq(game.knife_holder, c)


func test_suffer_valid_wound_is_taken():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER) # valid: RANK, RED, RED
	game.suffer_wound(c, RED)
	assert_eq(c.wound_count(), 1)
	assert_true(RED in c.wounds, "Red wound should have been recorded")


func test_inquisitor_can_take_any_wound():
	var game := Game.new(6)
	var c := Character.new(Game.INQUISITOR) # valid: RANK, ANY, ANY
	game.suffer_wound(c, RED)
	game.suffer_wound(c, BLUE)
	assert_eq(c.wound_count(), 2)
	assert_true(RED in c.wounds, "Red wound should have been recorded")
	assert_true(BLUE in c.wounds, "Blue wound should have been recorded")


func test_inquisitor_can_take_duplicate_wounds():
	var game := Game.new(6)
	var c := Character.new(Game.INQUISITOR) # valid: RANK, ANY, ANY
	game.suffer_wound(c, UNKNOWN)
	game.suffer_wound(c, UNKNOWN)
	assert_eq(c.wound_count(), 2)
	assert_eq(c.wounds.filter(func(w): return w == UNKNOWN).size(), 2, "Inquisitor should be able to take duplicate wounds")


func test_inquisitor_cannot_take_literal_any_wound():
	var game := Game.new(6)
	var c := Character.new(Game.INQUISITOR) # valid: RANK, ANY, ANY
	game.suffer_wound(c, ANY)
	assert_eq(c.wound_count(), 0, "Inquisitor should not be able to take literal ANY wound")
	assert_eq(get_errors().size(), 0, "Rejecting an invalid wound must not push an error")


func test_suffer_invalid_wound_is_rejected():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER) # cannot take BLUE
	game.suffer_wound(c, BLUE)
	assert_eq(c.wound_count(), 0, "Invalid wound must not be recorded")
	assert_eq(get_errors().size(), 0, "Rejecting an invalid wound must not push an error")


func test_fourth_wound_captures_without_extra_token():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER) # RANK, RED, RED
	game.suffer_wound(c, RANK)
	game.suffer_wound(c, RED)
	game.suffer_wound(c, RED)
	assert_eq(c.wound_count(), 3)
	assert_false(c.is_captured(), "Three wounds should not capture")
	game.suffer_wound(c, RANK) # slots full -> 4th wound captures
	assert_true(c.is_captured(), "Fourth wound should capture")
	assert_eq(c.wound_count(), 3, "Capture must not add a fourth token")


func test_remove_wound_leaves_the_rest():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER)
	game.suffer_wound(c, RANK)
	game.suffer_wound(c, RED)
	game.remove_wound(c, RANK)
	assert_eq(c.wound_count(), 1)
	assert_true(RED in c.wounds, "Removing RANK should leave RED")


func test_remove_wound_uncaptures():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER)
	game.suffer_wound(c, RANK)
	game.suffer_wound(c, RED)
	game.suffer_wound(c, RED)
	game.suffer_wound(c, RANK) # capture
	assert_true(c.is_captured())
	game.remove_wound(c, RED)
	assert_false(c.is_captured(), "Freeing a slot should undo capture in sandbox")
	assert_eq(c.wound_count(), 2)


func test_clear_wounds_empties():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER)
	game.suffer_wound(c, RANK)
	game.suffer_wound(c, RED)
	game.clear_wounds(c)
	assert_eq(c.wound_count(), 0)
	assert_false(c.is_captured())


func test_state_changed_emitted_on_mutation():
	var game := Game.new(6)
	watch_signals(game)
	game.set_knife_holder(game.characters[0])
	assert_signal_emitted(game, "state_changed", "set_knife_holder should emit state_changed")
	var c := Character.new(Game.RED_ELDER)
	game.suffer_wound(c, RED)
	assert_signal_emit_count(game, "state_changed", 2)
