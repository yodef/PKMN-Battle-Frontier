extends Node

func _ready() -> void:
	print("--- TEST: UPDATER LEVEL 1 (GITHUB RELEASES) ---")
	
	# 1. Instantiate MainMenu scene
	var main_menu_scene = load("res://scenes/main_menu.tscn")
	assert(main_menu_scene != null, "scenes/main_menu.tscn should load successfully")
	var menu = main_menu_scene.instantiate()
	add_child(menu)
	
	# 2. Check GameData constants
	assert(GameData.GAME_VERSION != "", "GameData.GAME_VERSION should be set")
	print("GameData.GAME_VERSION = %s" % GameData.GAME_VERSION)
	assert(GameData.GAME_VERSION == "v0.5.0", "GameData.GAME_VERSION should be v0.5.0")
	
	# 3. Test version comparison function
	print("Testing _compare_versions...")
	assert(menu._compare_versions("v0.5.0", "v0.5.0") == 0, "Equal versions should return 0")
	assert(menu._compare_versions("v0.5.1", "v0.5.0") == 1, "v0.5.1 > v0.5.0 should return 1")
	assert(menu._compare_versions("v0.4.9", "v0.5.0") == -1, "v0.4.9 < v0.5.0 should return -1")
	assert(menu._compare_versions("v1.0.0", "v0.9.9") == 1, "v1.0.0 > v0.9.9 should return 1")
	assert(menu._compare_versions("v0.5.10", "v0.5.2") == 1, "v0.5.10 > v0.5.2 should return 1 (semantic numerical comparison)")
	assert(menu._compare_versions("0.6.0", "v0.5.0") == 1, "0.6.0 > v0.5.0 should return 1 without leading v")
	assert(menu._compare_versions("v0.5.0-beta.1", "v0.5.0") == 0, "Pre-release tag should match base version")
	print("✅ Version comparison passed!")
	
	# 4. Check UI elements in SettingsModal
	print("Testing SettingsModal UI nodes...")
	assert(menu.btn_check_update != null, "btn_check_update should exist")
	assert(menu.btn_check_update.text.contains("Check for Updates"), "btn_check_update text should contain Check for Updates")
	assert(menu.update_status_lbl != null, "update_status_lbl should exist")
	assert(menu.info_version_lbl != null, "info_version_lbl should exist")
	print("✅ SettingsModal updater UI nodes verified!")
	
	# 5. Check UpdateModal elements
	print("Testing UpdateModal UI nodes...")
	assert(menu.update_modal != null, "update_modal should exist")
	assert(menu.update_modal.visible == false, "update_modal should be hidden by default")
	assert(menu.update_title != null, "update_title should exist")
	assert(menu.update_subtitle != null, "update_subtitle should exist")
	assert(menu.update_notes != null, "update_notes should exist")
	assert(menu.btn_update_download != null, "btn_update_download should exist")
	assert(menu.btn_update_github != null, "btn_update_github should exist")
	assert(menu.btn_update_close != null, "btn_update_close should exist")
	print("✅ UpdateModal UI nodes verified!")
	
	# 6. Test file size formatting
	print("Testing _format_file_size...")
	assert(menu._format_file_size(0) == "", "0 bytes should format to empty string")
	assert(menu._format_file_size(2048) == "2.0 KB", "2048 bytes should format to 2.0 KB")
	assert(menu._format_file_size(52428800) == "50.0 MB", "52428800 bytes should format to 50.0 MB")
	print("✅ File size formatting passed!")
	
	# 7. Test _show_update_modal with mock release data
	print("Testing _show_update_modal with mock data...")
	var mock_release = {
		"tag_name": "v0.6.0",
		"name": "Battle Frontier v0.6.0 Release",
		"body": "- Added In-App Updater\n- Rebalanced evolution requirements\n- Added thematic move boosts",
		"html_url": "https://github.com/yodef/PKMN-Battle-Frontier/releases/tag/v0.6.0",
		"assets": [
			{
				"name": "pkmn-battle-frontier-windows.zip",
				"browser_download_url": "https://github.com/yodef/PKMN-Battle-Frontier/releases/download/v0.6.0/pkmn-battle-frontier-windows.zip",
				"size": 52428800
			},
			{
				"name": "pkmn-battle-frontier.apk",
				"browser_download_url": "https://github.com/yodef/PKMN-Battle-Frontier/releases/download/v0.6.0/pkmn-battle-frontier.apk",
				"size": 48234496
			}
		]
	}
	
	menu._show_update_modal(mock_release)
	assert(menu.update_modal.visible == true, "update_modal should be visible after _show_update_modal")
	assert(menu.update_subtitle.text.contains("v0.6.0"), "Subtitle should contain new version")
	assert(menu.update_notes.text.contains("Rebalanced evolution"), "Notes should contain body text")
	assert(menu._target_download_url != "", "Target download url should be selected")
	print("Target download url: %s" % menu._target_download_url)
	print("Download button text: %s" % menu.btn_update_download.text)
	
	# Close modal
	menu._on_update_close_pressed()
	assert(menu.update_modal.visible == false, "update_modal should be hidden after close pressed")
	print("✅ UpdateModal display and dismissal passed!")
	
	# 8. Test 404 response handling (e.g. no release published yet on repo)
	print("Testing 404 response handling...")
	menu._on_update_http_completed(HTTPRequest.RESULT_SUCCESS, 404, PackedStringArray(), PackedByteArray(), null)
	assert(menu.update_status_lbl.visible == true, "Status label should be visible")
	assert(menu.update_status_lbl.text.contains("up to date"), "Status label should state game is up to date on 404")
	print("Status label on 404: %s" % menu.update_status_lbl.text)
	print("✅ 404 handling passed!")
	
	# 9. Test equal version response handling
	print("Testing equal version response handling...")
	var up_to_date_release = {
		"tag_name": "v0.5.0",
		"name": "v0.5.0",
		"body": "Current version",
		"html_url": "https://github.com/yodef/PKMN-Battle-Frontier/releases/tag/v0.5.0",
		"assets": []
	}
	var json_bytes = JSON.stringify(up_to_date_release).to_utf8_buffer()
	menu._on_update_http_completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), json_bytes, null)
	assert(menu.update_status_lbl.visible == true, "Status label should be visible")
	assert(menu.update_status_lbl.text.contains("up to date"), "Status label should state game is up to date for same version")
	assert(menu.update_modal.visible == false, "Update modal should not open for same version")
	print("Status label on v0.5.0: %s" % menu.update_status_lbl.text)
	print("✅ Same version handling passed!")
	
	print("🎉 ALL UPDATER TESTS PASSED SUCCESSFULLY!")
	get_tree().quit(0)
