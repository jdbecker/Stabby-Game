extends GutTest


func test_count_chars():
	assert_eq(Game.ALL_CHARACTERS.size(), 19)


func test_count_clans():
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.clan == CharacterStats.Clan.RED).size(), 9)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.clan == CharacterStats.Clan.BLUE).size(), 9)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.clan == CharacterStats.Clan.PURPLE).size(), 1)
	assert_eq(Game.BLUE_CHARACTERS.size(), 9)
	assert_eq(Game.RED_CHARACTERS.size(), 9)


func test_count_ranks():
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.INQUISITOR).size(), 1)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.ELDER).size(), 2)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.ASSASSIN).size(), 2)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.HARLEQUIN).size(), 2)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.ALCHEMIST).size(), 2)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.MENTALIST).size(), 2)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.GUARDIAN).size(), 2)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.BERSERKER).size(), 2)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.MAGE).size(), 2)
	assert_eq(Game.ALL_CHARACTERS.filter(func(c: CharacterStats): return c.rank == CharacterStats.Rank.COURTESAN).size(), 2)


func test_new_game():
	var game := Game.new(7)
	var red_chars := game.characters.filter(func(c:Character): return c._stats.clan == CharacterStats.Clan.RED)
	var blue_chars := game.characters.filter(func(c:Character): return c._stats.clan == CharacterStats.Clan.BLUE)
	var inquisitor := game.characters.filter(func(c:Character): return c._stats.clan == CharacterStats.Clan.PURPLE)
	assert_eq(red_chars.size(), 3)
	assert_eq(blue_chars.size(), 3)
	assert_eq(inquisitor.size(), 1)


func test_rand_knife():
	var knives: Array[int] = []
	for _i in range(100):
		var game := Game.new(6)
		knives.append(game.characters.find(game.knife_holder))
	assert_gt(knives.filter(func(i): return i == 0).size(), 0, "Player 0 never got the knife!")
	assert_gt(knives.filter(func(i): return i == 1).size(), 0, "Player 1 never got the knife!")
	assert_gt(knives.filter(func(i): return i == 2).size(), 0, "Player 2 never got the knife!")
	assert_gt(knives.filter(func(i): return i == 3).size(), 0, "Player 3 never got the knife!")
	assert_gt(knives.filter(func(i): return i == 4).size(), 0, "Player 4 never got the knife!")
	assert_gt(knives.filter(func(i): return i == 5).size(), 0, "Player 5 never got the knife!")
	assert_eq(knives.filter(func(i): return i == 6).size(), 0, "Player 6 doesn't exist but received the knife!")


func test_too_few_players():
	Game.new(6)
	Game.new(5)
	var errors := get_errors()
	assert_eq(errors.size(), 1, "Game should error when created with too few players!")
	handle_errors(errors)


func test_too_many_players():
	Game.new(12)
	Game.new(13)
	var errors := get_errors()
	assert_eq(errors.size(), 1, "Game should error when created with too many players!")
	handle_errors(errors)


func test_errant_wound():
	var character := Character.new(Game.BLUE_ALCHEMIST)
	character.wounds.append(CharacterStats.Wound.RED)
	character.valid_new_wounds()
	var errors := get_errors()
	assert_eq(errors.size(), 1, "Blue Alchemist should not be able to have a Red wound, but no error was thrown!")
	handle_errors(errors)


func test_available_wounds():
	var character := Character.new(Game.RED_ELDER)
	character.wounds.append(CharacterStats.Wound.RED)
	var valid_wounds := character.valid_new_wounds()
	assert_eq(valid_wounds.size(), 2, "Expected two remaining wounds, but got %s!" % character.wounds_to_string(valid_wounds))
	assert_true(CharacterStats.Wound.RED in valid_wounds, "Red Elder should have one more Red wound left, but only has %s" % character.wounds_to_string(valid_wounds))
	assert_true(CharacterStats.Wound.RANK in valid_wounds, "Red Elder should have one Rank wound left, but only has %s" % character.wounds_to_string(valid_wounds))


func test_add_invalid_wound():
	var character := Character.new(Game.BLUE_HARLEQUIN)
	var wound_context := WoundContext.new(character)
	wound_context.wound_type = CharacterStats.Wound.BLUE
	character.take_wound(wound_context)
	var errors := get_errors()
	assert_eq(errors.size(), 1, "Blue Harlequin can't take Blue wounds, but no error was thrown!")
	handle_errors(errors)


func handle_errors(errors: Array) -> void:
	errors.map(func(error: GutTrackedError): error.handled = true)
