extends Node

func _ready() -> void:
	print("--- TESTING CAMP ART BACKGROUND ON CAMPAIGN SCENES ---")
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	
	# 1. CampaignModal CampArtBackdrop
	var camp_modal = menu.get_node_or_null("CampaignModal")
	assert(camp_modal != null, "CampaignModal must exist")
	var camp_art = camp_modal.find_child("CampArtBackdrop", true, false)
	assert(camp_art != null and camp_art is TextureRect, "CampArtBackdrop must exist in CampaignModal")
	assert(camp_art.texture != null and camp_art.texture.resource_path.ends_with("camp_bg.png"), "CampArtBackdrop texture must be camp_bg.png")
	print("Test 1 Passed: CampaignModal has CAMP art background.")
	
	# 2. CampaignHubModal CampHubArtBackdrop
	var hub_modal = menu.get_node_or_null("CampaignHubModal")
	assert(hub_modal != null, "CampaignHubModal must exist")
	var hub_art = hub_modal.find_child("CampHubArtBackdrop", true, false)
	assert(hub_art != null and hub_art is TextureRect, "CampHubArtBackdrop must exist in CampaignHubModal")
	assert(hub_art.texture != null and hub_art.texture.resource_path.ends_with("camp_bg.png"), "CampHubArtBackdrop texture must be camp_bg.png")
	print("Test 2 Passed: CampaignHubModal has CAMP art background.")
	
	# 3. StadiumGuideModal StadiumGuideArtBackdrop
	var guide_modal = menu.get_node_or_null("StadiumGuideModal")
	assert(guide_modal != null, "StadiumGuideModal must exist")
	var guide_art = guide_modal.find_child("StadiumGuideArtBackdrop", true, false)
	assert(guide_art != null and guide_art is TextureRect, "StadiumGuideArtBackdrop must exist in StadiumGuideModal")
	assert(guide_art.texture != null and guide_art.texture.resource_path.ends_with("camp_bg.png"), "StadiumGuideArtBackdrop texture must be camp_bg.png")
	print("Test 3 Passed: StadiumGuideModal has CAMP art background.")
	
	print("=== ALL CAMP ART TESTS PASSED SUCCESSFULLY! ===")
	get_tree().quit(0)
