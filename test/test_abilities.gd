extends GutTest


func test_assassin_inflicts_up_to_two_wounds_and_passes_dagger():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_ASSASSIN)
	var target := Character.new(Game.RED_ELDER)
	var context := AbilityContext.new()
	context.target = target
	actor.activate_ability(game, context)
	# Assassin should attempt up to two wounds; ensure at least one wound recorded and dagger moved
	assert_eq(target.unassigned_wounds.size(), 2)
	assert_eq(game.knife_holder, target)

func test_mentalist_inflicts_rank_and_passes_dagger():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_MENTALIST)
	var target := Character.new(Game.RED_ELDER)
	var ctx := AbilityContext.new()
	ctx.target = target
	actor.activate_ability(game, ctx)
	# Mentalist prefers RANK
	assert_true(target.wound_count() >= 1)
	assert_eq(game.knife_holder, target)

func test_mentalist_inflicts_unassigned_if_rank_not_available():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_MENTALIST)
	var target := Character.new(Game.RED_ELDER)
	var initial_wound := WoundContext.new(actor)
	initial_wound.wound_type = CharacterStats.Wound.RANK
	game.suffer_wound(target, initial_wound)
	var ctx := AbilityContext.new()
	ctx.target = target
	actor.activate_ability(game, ctx)
	assert_eq(target.unassigned_wounds.size(), 1)
	assert_eq(game.knife_holder, target)

func test_berserker_wounds_attacker():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_BERSERKER)
	var attacker := Character.new(Game.RED_ELDER)
	var wound := WoundContext.new(attacker)
	wound.wound_type = CharacterStats.Wound.RANK
	game.suffer_wound(actor, wound)
	actor.activate_ability(game)
	assert_eq(attacker.unassigned_wounds.size(), 1)

func test_guardian_gives_shield_and_actor_gets_sword():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_GUARDIAN)
	var target := Character.new(Game.RED_ELDER)
	var ctx := AbilityContext.new()
	ctx.target = target
	actor.activate_ability(game, ctx)
	var sword := actor.get_sword()
	var shield := target.get_shield()
	assert_not_null(sword)
	assert_not_null(shield)
	assert_eq(sword.color, shield.color)

func test_guardian_gives_matching_shield_if_already_has_sword():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_GUARDIAN)
	var target := Character.new(Game.RED_ELDER)
	actor.ability_cards.append(AbilityCard.Sword.new(Color.PURPLE))
	var ctx := AbilityContext.new()
	ctx.target = target
	actor.activate_ability(game, ctx)
	var shield := target.get_shield()
	assert_not_null(shield)
	assert_eq(shield.color, Color.PURPLE)

func test_guardian_gives_unique_shield_if_default_color_exists():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_GUARDIAN)
	var target := Character.new(Game.RED_ELDER)
	game.characters.front().ability_cards.append(AbilityCard.Shield.new(Color.GREEN))
	var ctx := AbilityContext.new()
	ctx.target = target
	actor.activate_ability(game, ctx)
	var sword := actor.get_sword()
	var shield := target.get_shield()
	assert_not_null(sword)
	assert_not_null(shield)
	assert_eq(sword.color, shield.color)
	assert_not_same(shield.color, Color.GREEN)

func test_shielded_target_invalid():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_GUARDIAN)
	var target: Character = game.characters.front()
	game.characters.append(actor) # game now has 7 chars
	game.set_knife_holder(actor)
	var ctx := AbilityContext.new()
	ctx.target = target
	actor.activate_ability(game, ctx)
	# 2 characters are not valid: shielded and knife holder
	assert_eq( game.get_valid_stab_targets().size(), game.characters.size() - 2)

func test_shielded_target_valid_when_guardian_wounded():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_GUARDIAN)
	var target: Character = game.characters.front()
	game.characters.append(actor) # game now has 7 chars
	game.set_knife_holder(actor)
	var ctx := AbilityContext.new()
	ctx.target = target
	actor.activate_ability(game, ctx)
	var wound := WoundContext.new(target)
	wound.wound_type = CharacterStats.Wound.RANK
	game.suffer_wound(actor, wound)
	wound.wound_type = CharacterStats.Wound.BLUE
	game.suffer_wound(actor, wound)
	game.suffer_wound(actor, wound)
	# 1 character not valid: knife holder
	assert_eq( game.get_valid_stab_targets().size(), game.characters.size() - 1)

func test_mage_gives_staffs():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_MAGE)
	var target := Character.new(Game.RED_ELDER)
	var ctx := AbilityContext.new()
	ctx.target = target
	actor.activate_ability(game, ctx)
	# both actor and target should be in the Staff owners
	assert_true(actor.has_staff())
	assert_true(target.has_staff())

func test_staff_sets_valid_wounds_unknown():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_MAGE)
	var red_elder := Character.new(Game.RED_ELDER)
	assert_eq(red_elder.valid_new_wounds(), [CharacterStats.Wound.RANK, CharacterStats.Wound.RED, CharacterStats.Wound.RED])
	var ctx := AbilityContext.new()
	ctx.target = red_elder
	actor.activate_ability(game, ctx)
	assert_eq(red_elder.valid_new_wounds(), [CharacterStats.Wound.RANK, CharacterStats.Wound.UNKNOWN, CharacterStats.Wound.UNKNOWN])

func test_staff_already_having_color_wound_doesnt_break():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_MAGE)
	var red_elder := Character.new(Game.RED_ELDER)
	var wound := WoundContext.new(actor)
	wound.wound_type = CharacterStats.Wound.RED
	game.suffer_wound(red_elder, wound)
	assert_eq(red_elder.valid_new_wounds(), [CharacterStats.Wound.RANK, CharacterStats.Wound.RED])
	var ctx := AbilityContext.new()
	ctx.target = red_elder
	actor.activate_ability(game, ctx)
	assert_eq(red_elder.valid_new_wounds(), [CharacterStats.Wound.RANK, CharacterStats.Wound.UNKNOWN])

func test_courtesan_gives_fan():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_COURTESAN)
	var target := Character.new(Game.RED_ELDER)
	var ctx := AbilityContext.new()
	ctx.target = target
	actor.activate_ability(game, ctx)
	assert_true(target.has_fan())

func test_no_quill_low_number_leader():
	var game := Game.new(6)
	var red_leader := Character.new(Game.RED_ELDER)
	var red_follower_1 := Character.new(Game.RED_ASSASSIN)
	var red_follower_2 := Character.new(Game.RED_HARLEQUIN)
	var blue_leader := Character.new(Game.BLUE_BERSERKER)
	var blue_follower_1 := Character.new(Game.BLUE_MAGE)
	var blue_follower_2 := Character.new(Game.BLUE_COURTESAN)
	game.characters = [red_leader, red_follower_1, red_follower_2, blue_leader, blue_follower_1, blue_follower_2]
	assert_eq(game.clan_leader(CharacterStats.Clan.RED), red_leader)
	assert_eq(game.clan_leader(CharacterStats.Clan.BLUE), blue_leader)

func test_elder_makes_last_rank_leader():
	var game := Game.new(6)
	var red_leader := Character.new(Game.RED_ELDER)
	var red_follower_1 := Character.new(Game.RED_ASSASSIN)
	var red_follower_2 := Character.new(Game.RED_HARLEQUIN)
	var blue_leader := Character.new(Game.BLUE_ELDER)
	var blue_follower_1 := Character.new(Game.BLUE_MAGE)
	var blue_follower_2 := Character.new(Game.BLUE_COURTESAN)
	game.characters = [red_leader, red_follower_1, red_follower_2, blue_leader, blue_follower_1, blue_follower_2]
	red_leader.activate_ability(game)
	blue_leader.activate_ability(game)
	assert_eq(game.clan_leader(CharacterStats.Clan.RED), red_follower_2)
	assert_eq(game.clan_leader(CharacterStats.Clan.BLUE), blue_follower_2)

func test_alchemist_intervention_heal():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_ALCHEMIST)
	var target := Character.new(Game.RED_ELDER)
	var wound := WoundContext.new(game.characters[0])
	wound.intervened_for = target
	wound.wound_type = CharacterStats.Wound.RANK
	actor.take_wound(wound)
	var ctx := AbilityContext.new()
	ctx.intervention = true
	ctx.heal = true
	actor.activate_ability(game, ctx)
	assert_eq(target.unassigned_heals, 1)

func test_alchemist_intervention_wound():
	var game := Game.new(6)
	var actor := Character.new(Game.BLUE_ALCHEMIST)
	var target := Character.new(Game.RED_ELDER)
	var wound := WoundContext.new(game.characters[0])
	wound.intervened_for = target
	wound.wound_type = CharacterStats.Wound.RANK
	actor.take_wound(wound)
	var ctx := AbilityContext.new()
	ctx.intervention = true
	ctx.target = target
	ctx.heal = false
	actor.activate_ability(game, ctx)
	assert_eq(target.unassigned_wounds.size(), 1)

func test_inquisitor_gives_curses():
	var game := Game.new(6)
	var actor := Character.new(Game.INQUISITOR)
	var true_target := Character.new(Game.RED_ELDER)
	var false_target_1 := Character.new(Game.RED_ASSASSIN)
	var false_target_2 := Character.new(Game.RED_HARLEQUIN)
	var false_target_3 := Character.new(Game.RED_ALCHEMIST)
	var ctx := AbilityContext.new()
	ctx.targets = [true_target, false_target_1, false_target_2, false_target_3]
	actor.activate_ability(game, ctx)
	assert_true(true_target.has_true_curse())
	assert_true(false_target_1.has_false_curse())
	assert_true(false_target_2.has_false_curse())
	assert_true(false_target_3.has_false_curse())
