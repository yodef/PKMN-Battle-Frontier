extends Node

func _ready() -> void:
	print("--- Running Alias and Friends Search Test ---")
	
	# Test 1: parse_trainer_doc_to_save_data preserves custom alias in save_json
	var doc_fields = {
		"email": { "stringValue": "rafagc092@gmail.com" },
		"trainer_alias": { "stringValue": "Trainer" },
		"save_json": { "stringValue": JSON.stringify({
			"profile": { "name": "Rafiki", "trainer_alias": "Rafiki" }
		}) }
	}
	var res1 = CloudSync.parse_trainer_doc_to_save_data(doc_fields)
	assert(res1["profile"]["name"] == "Rafiki", "Should preserve 'Rafiki' even if root field has 'Trainer'")
	assert(res1["profile"]["trainer_alias"] == "Rafiki", "Should preserve 'Rafiki' in trainer_alias")
	print("✅ Test 1 Passed: Custom alias in save_json preserved over root 'Trainer' default.")
	
	# Test 2: Root custom alias used when save_json alias is generic or empty
	var doc_fields2 = {
		"email": { "stringValue": "rafagc092@gmail.com" },
		"trainer_name": { "stringValue": "Rafiki" },
		"save_json": { "stringValue": JSON.stringify({
			"profile": { "name": "Trainer", "trainer_alias": "Trainer" }
		}) }
	}
	var res2 = CloudSync.parse_trainer_doc_to_save_data(doc_fields2)
	assert(res2["profile"]["name"] == "Rafiki", "Should take root 'Rafiki' when save_json is generic")
	print("✅ Test 2 Passed: Root custom alias overrides generic 'Trainer' in save_json.")
	
	# Test 3: apply_save_dict does not clobber existing custom profile_name if incoming is generic
	GameData.profile_name = "Rafiki"
	var incoming_generic = {
		"profile": { "name": "Trainer", "trainer_alias": "Trainer", "email": "test@gmail.com" }
	}
	GameData.apply_save_dict(incoming_generic)
	assert(GameData.profile_name == "Rafiki", "GameData.profile_name must remain 'Rafiki'")
	print("✅ Test 3 Passed: GameData.profile_name preserved against incoming generic 'Trainer'.")
	
	# Test 4: apply_save_dict updates profile_name when incoming is a real new alias
	var incoming_new = {
		"profile": { "name": "AmikoRed", "trainer_alias": "AmikoRed", "email": "jetstratocaster@gmail.com" }
	}
	GameData.apply_save_dict(incoming_new)
	assert(GameData.profile_name == "AmikoRed", "GameData.profile_name should update to new custom alias")
	print("✅ Test 4 Passed: GameData.profile_name correctly updates to incoming custom alias.")
	
	print("🎉 ALL TESTS PASSED SUCCESSFULLY!")
	get_tree().quit()
