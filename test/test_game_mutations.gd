extends GutTest

const RANK := CharacterStats.Wound.RANK
const RED := CharacterStats.Wound.RED
const BLUE := CharacterStats.Wound.BLUE
const UNKNOWN := CharacterStats.Wound.UNKNOWN
const ANY := CharacterStats.Wound.ANY


func test_game_initializes_without_ui() -> void:
	var game := Game.new(6)
	assert_false(game.is_inside_tree())
	assert_null(game.get_node_or_null("DevPanel"))
	assert_eq(game.characters.size(), 6)
	assert_not_null(game.knife_holder)
	assert_true(game.knife_holder.has_knife)

	var added_game := Game.new(6)
	add_child_autofree(added_game)
	assert_null(added_game.get_node_or_null("DevPanel"))


func test_game_scene_rebuilds_panel_for_new_game() -> void:
	var game := load("res://game.tscn").instantiate() as Game
	add_child_autofree(game)
	await get_tree().process_frame

	var panel := game.dev_panel
	var player_list := panel.get_node("%PlayerList") as VBoxContainer
	var first_panel_id := panel.get_instance_id()
	assert_eq(_dev_panel_count(game), 1)
	assert_eq(player_list.get_child_count(), 7)

	game.start_new_game(8)
	panel = game.dev_panel
	assert_ne(panel.get_instance_id(), first_panel_id)
	assert_eq(_dev_panel_count(game), 1)
	assert_eq(panel.get_node("%PlayerList").get_child_count(), 8)
	assert_eq(panel.get_children().filter(func(child: Node): return child is PlayerView).size(), 8)

	await get_tree().process_frame
	var second_panel_id := panel.get_instance_id()
	game.start_new_game(6)
	panel = game.dev_panel
	assert_ne(panel.get_instance_id(), second_panel_id)
	assert_eq(_dev_panel_count(game), 1)
	assert_eq(panel.get_node("%PlayerList").get_child_count(), 6)
	assert_eq(panel.get_children().filter(func(child: Node): return child is PlayerView).size(), 6)


func _dev_panel_count(game: Game) -> int:
	return game.get_children().filter(func(child: Node): return child is DevPanel).size()


func _wound(type: CharacterStats.Wound) -> WoundContext:
	var wound := WoundContext.new(null)
	wound.wound_type = type
	return wound


func test_set_knife_holder_moves_freely():
	var game := Game.new(6)
	for c: Character in game.characters:
		game.set_knife_holder(c)
		assert_eq(game.knife_holder, c)


func test_suffer_valid_wound_is_taken():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER) # valid: RANK, RED, RED
	game.suffer_wound(c, _wound(RED))
	assert_eq(c.wound_count(), 1)
	assert_true(RED in c.wounds, "Red wound should have been recorded")


func test_inquisitor_can_take_any_wound():
	var game := Game.new(6)
	var c := Character.new(Game.INQUISITOR) # valid: RANK, ANY, ANY
	game.suffer_wound(c, _wound(RED))
	game.suffer_wound(c, _wound(BLUE))
	assert_eq(c.wound_count(), 2)
	assert_true(RED in c.wounds, "Red wound should have been recorded")
	assert_true(BLUE in c.wounds, "Blue wound should have been recorded")


func test_inquisitor_can_take_duplicate_wounds():
	var game := Game.new(6)
	var c := Character.new(Game.INQUISITOR) # valid: RANK, ANY, ANY
	game.suffer_wound(c, _wound(UNKNOWN))
	game.suffer_wound(c, _wound(UNKNOWN))
	assert_eq(c.wound_count(), 2)
	assert_eq(c.wounds.filter(func(w): return w == UNKNOWN).size(), 2, "Inquisitor should be able to take duplicate wounds")


func test_inquisitor_cannot_take_literal_any_wound():
	var game := Game.new(6)
	var c := Character.new(Game.INQUISITOR) # valid: RANK, ANY, ANY
	game.suffer_wound(c, _wound(ANY))
	var errors := get_errors()
	assert_eq(c.wound_count(), 0, "Inquisitor should not be able to take literal ANY wound")
	assert_eq(errors.size(), 1, "Rejecting an invalid wound must push an error")
	handle_errors(errors)


func test_suffer_invalid_wound_is_rejected():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER) # cannot take BLUE
	game.suffer_wound(c, _wound(BLUE))
	var errors := get_errors()
	assert_eq(c.wound_count(), 0, "Invalid wound must not be recorded")
	assert_eq(errors.size(), 1, "Rejecting an invalid wound must push an error")
	handle_errors(errors)


func test_fourth_wound_invalid():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER) # RANK, RED, RED
	game.suffer_wound(c, _wound(RANK))
	game.suffer_wound(c, _wound(RED))
	game.suffer_wound(c, _wound(RED))
	assert_eq(c.wound_count(), 3)
	assert_false(c.is_captured, "Three wounds should not capture")
	game.suffer_wound(c, _wound(RANK)) # slots full -> 4th wound captures
	assert_eq(c.wound_count(), 3, "Capture must not add a fourth token")
	var errors := get_errors()
	assert_eq(errors.size(), 1, "Should be an error if trying to wound a fully-wounded character")
	handle_errors(errors)


func test_remove_wound_leaves_the_rest():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER)
	game.suffer_wound(c, _wound(RANK))
	game.suffer_wound(c, _wound(RED))
	game.remove_wound(c, RANK)
	assert_eq(c.wound_count(), 1)
	assert_true(RED in c.wounds, "Removing RANK should leave RED")


func test_clear_wounds_empties():
	var game := Game.new(6)
	var c := Character.new(Game.RED_ELDER)
	game.suffer_wound(c, _wound(RANK))
	game.suffer_wound(c, _wound(RED))
	game.clear_wounds(c)
	assert_eq(c.wound_count(), 0)
	assert_false(c.is_captured)


func handle_errors(errors: Array) -> void:
	errors.map(func(error: GutTrackedError): error.handled = true)
