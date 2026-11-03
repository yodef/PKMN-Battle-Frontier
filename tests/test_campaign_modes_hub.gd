extends Node

func _ready() -> void:
	print("--- BEGIN CAMPAIGN MODES HUB TEST ---")
	
	# Load MainMenu scene
	var menu_scene = load("res://scenes/main_menu.tscn")
	assert(menu_scene != null, "scenes/main_menu.tscn should load successfully")
	var menu = menu_scene.instantiate()
	add_child(menu)
	await get_tree().process_frame
	
	# 1. Structure Check: CampaignHubModal must contain exactly 3 mode cards
	var modes_vbox = menu.get_node("CampaignHubModal/Box/ModesScroll/ModesVBox")
	assert(modes_vbox != null, "ModesVBox must exist in CampaignHubModal")
	var card_tutorial = modes_vbox.get_node_or_null("CardTutorial")
	var card_adventure = modes_vbox.get_node_or_null("CardAdventure")
	var card_tournament = modes_vbox.get_node_or_null("CardTournament")
	
	assert(card_tutorial != null, "CardTutorial must exist in CampaignHubModal")
	assert(card_adventure != null, "CardAdventure must exist in CampaignHubModal")
	assert(card_tournament != null, "CardTournament must exist in CampaignHubModal")
	
	assert(modes_vbox.get_node_or_null("CardAdventureEp1") == null, "CardAdventureEp1 must not be in ModesVBox")
	assert(modes_vbox.get_node_or_null("CardAdventureEp2") == null, "CardAdventureEp2 must not be in ModesVBox")
	
	var mode_cards = []
	for child in modes_vbox.get_children():
		if child is PanelContainer:
			mode_cards.append(str(child.name))
	print("Mode cards found in Campaign Hub: ", mode_cards)
	assert(mode_cards.size() == 3, "There must be exactly 3 mode cards in Campaign Hub")
	assert(mode_cards == ["CardTutorial", "CardAdventure", "CardTournament"], "Cards order must be Tutorial, Adventure, Stadium")
	print("Test 1 Passed: Campaign Hub has exactly 3 mode cards.")
	
	# 2. AdventureEpisodesModal structure check
	var adv_modal = menu.get_node("AdventureEpisodesModal")
	assert(adv_modal != null, "AdventureEpisodesModal must exist in main menu")
	var ep1_card = adv_modal.get_node_or_null("Box/EpisodesScroll/EpisodesVBox/CardAdventureEp1")
	var ep2_card = adv_modal.get_node_or_null("Box/EpisodesScroll/EpisodesVBox/CardAdventureEp2")
	var btn_close_episodes = adv_modal.get_node_or_null("Box/BtnCloseAdventureEpisodes")
	assert(ep1_card != null, "CardAdventureEp1 must exist in AdventureEpisodesModal")
	assert(ep2_card != null, "CardAdventureEp2 must exist in AdventureEpisodesModal")
	assert(btn_close_episodes != null, "BtnCloseAdventureEpisodes must exist")
	print("Test 2 Passed: AdventureEpisodesModal structure verified.")
	
	# 3. Text and naming check: Pokemon Stadium
	var tourn_title = card_tournament.get_node("Margin/TournVBox/TournTitle")
	assert(tourn_title.text.contains("Pokémon Stadium"), "Tournament card title must mention Pokémon Stadium")
	print("Test 3 Passed: Pokémon Stadium name verified.")
	
	# 4. Locking test: fresh profile without tutorial completed
	GameData.create_new_profile("TesterHub", "Guest", "tester_hub@frontier.local")
	GameData.tutorial_completed = false
	GameData.tutorial_reward_claimed = false
	menu.update_campaign_hub_ui()
	
	assert(menu.adv_status_lbl.text.contains("Locked"), "Adventure status must be Locked when tutorial not done")
	assert(menu.btn_hub_adventure.text.contains("Locked"), "Adventure button must state Locked")
	
	# Pressing Adventure when locked should show tutorial prompt
	menu._on_hub_adventure_pressed()
	assert(menu.tutorial_confirm_modal != null and menu.tutorial_confirm_modal.visible, "Tutorial prompt modal should open when clicking locked Adventure")
	menu.tutorial_confirm_modal.visible = false
	print("Test 4 Passed: Locked Adventure mode prompts tutorial.")
	
	# 5. Unlocking test: complete tutorial
	GameData.tutorial_completed = true
	GameData.tutorial_reward_claimed = true
	menu.update_campaign_hub_ui()
	
	assert(menu.tutorial_status_lbl.text.contains("Completed"), "Tutorial status must show completed")
	assert(menu.adv_status_lbl.text.contains("Unlocked") or menu.adv_status_lbl.text.contains("available"), "Adventure status must show unlocked")
	
	# Pressing Adventure when unlocked should open AdventureEpisodesModal
	menu.campaign_hub_modal.visible = true
	menu._on_hub_adventure_pressed()
	assert(menu.campaign_hub_modal.visible == false, "CampaignHubModal must hide when opening episodes")
	assert(menu.adventure_episodes_modal.visible == true, "AdventureEpisodesModal must become visible")
	
	# Pressing Back to Campaign Modes should return to CampaignHubModal
	menu.btn_close_adventure_episodes.emit_signal("pressed")
	assert(menu.adventure_episodes_modal.visible == false, "AdventureEpisodesModal must hide")
	assert(menu.campaign_hub_modal.visible == true, "CampaignHubModal must reopen")
	print("Test 5 Passed: Unlocked Adventure navigates to episodes modal and back.")
	
	# 6. Team select labels for Pokemon Stadium vs Adventure
	GameData.campaign_submode = "TOURNAMENT"
	menu.open_team_select_for_campaign()
	assert(menu.team_select_title.text.contains("STADIUM"), "Team select title for Tournament must say STADIUM")
	menu._on_close_team_select_pressed()
	assert(menu.campaign_hub_modal.visible == true, "Closing Stadium team select should reopen CampaignHubModal")
	
	GameData.campaign_submode = "ADVENTURE"
	menu.open_team_select_for_campaign()
	assert(menu.team_select_title.text.contains("ADVENTURE"), "Team select title for Adventure must say ADVENTURE")
	menu._on_close_team_select_pressed()
	assert(menu.adventure_episodes_modal.visible == true, "Closing Adventure team select should reopen AdventureEpisodesModal")
	print("Test 6 Passed: Team select titles and back navigation verified for both modes.")
	
	print("=== ALL CAMPAIGN MODES HUB TESTS PASSED! ===")
	get_tree().quit(0)
