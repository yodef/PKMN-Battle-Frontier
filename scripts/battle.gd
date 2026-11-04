extends Control

# --- CONFIGURACIÓN DE REGLAS ---
const WEAKNESS_BONUS: int = 2        # Daño extra si atacas a la debilidad del rival
const RESISTANCE_REDUCTION: int = 2  # Daño reducido si el rival resiste tu tipo
const MIN_DAMAGE_AFTER_RESIST: int = 1 # Daño mínimo si la resistencia reduce

# --- MODELOS DE DATOS ---
var player_team: Array = []
var enemy_team: Array = []
var active_player_idx: int = 0
var active_enemy_idx: int = 0

var is_player_turn: bool = true
var is_busy: bool = false
var can_player_act: bool = false
var is_enemy_fainting: bool = false
var is_player_fainting: bool = false

# --- SISTEMA DE RONDAS E INICIATIVA (SPEED) ---
var round_number: int = 0
var round_order: Array[String] = [] # ["PLAYER", "ENEMY"] o ["ENEMY", "PLAYER"]
var round_step: int = 0             # 0 = 1er turno de la ronda, 1 = 2do turno de la ronda
var combat_history: Array[String] = []
var is_battle_over: bool = false
var sandstorm_turns: int = 0
var grassy_terrain_turns: int = 0
var pending_opponent_actions: Array[Dictionary] = []
var is_waiting_for_online_opponent: bool = false
var is_processing_opponent_action: bool = false

# --- RECOMPENSAS DINÁMICAS Y SEGUIMIENTO DE RIVALES DERROTADOS ---
var defeated_enemy_indices: Array[int] = []
var combat_earned_gold: int = 0
var combat_earned_diamonds: int = 0
var defeated_rewards_summary: Array[Dictionary] = []

# --- REFERENCIAS A NODOS ---
@onready var btn_back_menu: Button = $MainContainer/TopBar/BtnBackMenu
@onready var btn_speed: Button = $MainContainer/TopBar/BtnSpeed
@onready var battle_title_lbl: Label = $MainContainer/TopBar/BattleTitle
@onready var floating_numbers_layer: Control = $FloatingNumbersLayer
var bgm_player: AudioStreamPlayer = null
var player_status_overlay: StatusFXOverlay = null
var enemy_status_overlay: StatusFXOverlay = null

const SPEED_LEVELS: Array[float] = [1.0, 1.5, 2.0, 3.0]
const SPEED_LABELS: Array[String] = ["⏩ 1x", "⏩ 1.5x", "⏩ 2x", "⏩ 3x"]

@onready var enemy_card_img: Control = $MainContainer/EnemySection/HBox/EnemyCard
@onready var enemy_type_icon: TextureRect = $MainContainer/EnemySection/HBox/Info/EnemyNameRow/EnemyTypeIcon
@onready var enemy_name_lbl: Label = $MainContainer/EnemySection/HBox/Info/EnemyNameRow/EnemyName
@onready var enemy_type_lbl: Label = $MainContainer/EnemySection/HBox/Info/EnemyType

@onready var enemy_bench_lbl: Label = $MainContainer/EnemySection/HBox/Info/EnemyBenchRow/EnemyBenchLbl
@onready var enemy_bench_cards: HBoxContainer = $MainContainer/EnemySection/HBox/Info/EnemyBenchRow/EnemyBenchCards
@onready var enemy_bench_1: PanelContainer = $MainContainer/EnemySection/HBox/Info/EnemyBenchRow/EnemyBenchCards/EnemyBench1
@onready var enemy_bench_2: PanelContainer = $MainContainer/EnemySection/HBox/Info/EnemyBenchRow/EnemyBenchCards/EnemyBench2

@onready var enemy_hp_bar: ProgressBar = $MainContainer/EnemySection/HBox/Info/HPBox/HPBarRow/EnemyHPBar
@onready var enemy_hp_lbl: Label = $MainContainer/EnemySection/HBox/Info/HPBox/HPBarRow/EnemyHPLbl
@onready var enemy_energy_lbl: Label = $MainContainer/EnemySection/HBox/Info/EnemyEnergyLbl
@onready var enemy_status_lbl: Label = $MainContainer/EnemySection/HBox/Info/HPBox/HPTopRow/EnemyStatusLbl

@onready var log_label: RichTextLabel = $MainContainer/CenterLog/Margin/VBox/LogLabel
@onready var turn_badge: Label = $MainContainer/CenterLog/Margin/VBox/TurnBadge

@onready var player_card_img: Control = $MainContainer/PlayerSection/HBox/PlayerCard
@onready var player_type_icon: TextureRect = $MainContainer/PlayerSection/HBox/Info/PlayerNameRow/PlayerTypeIcon
@onready var player_name_lbl: Label = $MainContainer/PlayerSection/HBox/Info/PlayerNameRow/PlayerName
@onready var player_type_lbl: Label = $MainContainer/PlayerSection/HBox/Info/PlayerType

@onready var player_bench_lbl: Label = $MainContainer/PlayerSection/HBox/Info/BenchRow/PlayerBenchLbl
@onready var btn_switch_1: Button = $MainContainer/PlayerSection/HBox/Info/BenchRow/SwitchButtons/BtnSwitch1
@onready var btn_switch_2: Button = $MainContainer/PlayerSection/HBox/Info/BenchRow/SwitchButtons/BtnSwitch2

@onready var player_hp_bar: ProgressBar = $MainContainer/PlayerSection/HBox/Info/HPBox/HPBarRow/PlayerHPBar
@onready var player_hp_lbl: Label = $MainContainer/PlayerSection/HBox/Info/HPBox/HPBarRow/PlayerHPLbl
@onready var player_energy_lbl: Label = $MainContainer/PlayerSection/HBox/Info/PlayerEnergyLbl
@onready var player_exp_box: VBoxContainer = $MainContainer/PlayerSection/HBox/Info/PlayerExpBox
@onready var player_exp_bar: ProgressBar = $MainContainer/PlayerSection/HBox/Info/PlayerExpBox/PlayerExpBar
@onready var player_exp_lbl: Label = $MainContainer/PlayerSection/HBox/Info/PlayerExpBox/PlayerExpLbl
@onready var player_status_lbl: Label = $MainContainer/PlayerSection/HBox/Info/HPBox/HPTopRow/PlayerStatusLbl

@onready var move1_slots: HBoxContainer = $MainContainer/ActionsSection/MoveButtons/Move1Col/Move1Slots
@onready var btn_move1: Button = $MainContainer/ActionsSection/MoveButtons/Move1Col/BtnMove1
@onready var move2_slots: HBoxContainer = $MainContainer/ActionsSection/MoveButtons/Move2Col/Move2Slots
@onready var btn_move2: Button = $MainContainer/ActionsSection/MoveButtons/Move2Col/BtnMove2

var selected_energy_move1: int = -1
var selected_energy_move2: int = -1
@onready var chk_boost: CheckBox = $MainContainer/ActionsSection/Options/ChkBoost
@onready var btn_passive: Button = $MainContainer/ActionsSection/Options/BtnPassive
@onready var btn_recover: Button = $MainContainer/ActionsSection/Options/BtnRecover

@onready var game_over_panel: Control = $GameOverOverlay
@onready var game_over_card: PanelContainer = $GameOverOverlay/CenterBox/CardPanel
@onready var game_over_title: Label = $GameOverOverlay/CenterBox/CardPanel/Margin/VBox/Title
@onready var game_over_subtitle: Label = $GameOverOverlay/CenterBox/CardPanel/Margin/VBox/Subtitle
@onready var btn_restart: Button = $GameOverOverlay/CenterBox/CardPanel/Margin/VBox/ButtonsRow/BtnRestart
@onready var btn_game_over_menu: Button = $GameOverOverlay/CenterBox/CardPanel/Margin/VBox/ButtonsRow/BtnGameOverMenu

@onready var energy_modal: Control = $EnergyModal
@onready var energy_modal_panel: PanelContainer = $EnergyModal/CenterBox/Panel
@onready var energy_modal_icon: TextureRect = $EnergyModal/CenterBox/Panel/Margin/VBox/TitleRow/MoveIcon
@onready var energy_modal_title: Label = $EnergyModal/CenterBox/Panel/Margin/VBox/TitleRow/MoveTitle
@onready var energy_modal_target: Label = $EnergyModal/CenterBox/Panel/Margin/VBox/TargetLbl
@onready var energy_modal_prompt: Label = $EnergyModal/CenterBox/Panel/Margin/VBox/PromptLbl
@onready var energy_modal_options: VBoxContainer = $EnergyModal/CenterBox/Panel/Margin/VBox/OptionsList
@onready var btn_cancel_energy: Button = $EnergyModal/CenterBox/Panel/Margin/VBox/BtnCancelEnergy

@onready var btn_bag: Button = $MainContainer/ActionsSection/Options/BtnBag
@onready var bag_modal: Control = $BagModal
@onready var bag_panel: PanelContainer = $BagModal/CenterBox/Panel
@onready var bag_items_list: VBoxContainer = $BagModal/CenterBox/Panel/Margin/VBox/ItemsList
@onready var bag_targets_section: VBoxContainer = $BagModal/CenterBox/Panel/Margin/VBox/TargetsSection
@onready var bag_target_prompt: Label = $BagModal/CenterBox/Panel/Margin/VBox/TargetsSection/TargetPromptLbl
@onready var bag_targets_container: VBoxContainer = $BagModal/CenterBox/Panel/Margin/VBox/TargetsSection/TargetsContainer
@onready var btn_cancel_bag: Button = $BagModal/CenterBox/Panel/Margin/VBox/BtnCancelBag
var selected_bag_item: String = ""

# --- TABLA DE EFECTIVIDADES POR TIPO ---
@onready var btn_type_chart: Button = $MainContainer/TopBar/BtnTypeChart
@onready var type_chart_modal: Control = $TypeChartModal
@onready var type_chart_panel: PanelContainer = $TypeChartModal/CenterBox/Panel
@onready var btn_close_type_chart_x: Button = $TypeChartModal/CenterBox/Panel/Margin/VBox/TitleRow/BtnCloseTypeChartX
@onready var btn_close_type_chart_bottom: Button = $TypeChartModal/CenterBox/Panel/Margin/VBox/BtnCloseTypeChartBottom
@onready var type_chart_matchup_body: RichTextLabel = $TypeChartModal/CenterBox/Panel/Margin/VBox/MatchupPanel/MatchupMargin/MatchupVBox/MatchupBody
@onready var type_chart_matrix_grid: GridContainer = $TypeChartModal/CenterBox/Panel/Margin/VBox/GridPanel/GridMargin/MatrixGrid
@onready var type_chart_detail_lbl: RichTextLabel = $TypeChartModal/CenterBox/Panel/Margin/VBox/DetailPanel/DetailMargin/DetailLbl
@onready var type_chart_matchup_panel: PanelContainer = $TypeChartModal/CenterBox/Panel/Margin/VBox/MatchupPanel
@onready var type_chart_grid_panel: PanelContainer = $TypeChartModal/CenterBox/Panel/Margin/VBox/GridPanel
@onready var type_chart_detail_panel: PanelContainer = $TypeChartModal/CenterBox/Panel/Margin/VBox/DetailPanel
@onready var type_chart_inc_panel: PanelContainer = $TypeChartModal/CenterBox/Panel/Margin/VBox/IncPanel

# --- ANIMACIÓN DE EVOLUCIÓN EN COMBATE ---
@onready var evolution_modal: Control = $EvolutionModal
@onready var evo_card_panel: PanelContainer = $EvolutionModal/CenterBox/CardPanel
@onready var evo_title: Label = $EvolutionModal/CenterBox/CardPanel/Margin/VBox/Title
@onready var evo_status_text: Label = $EvolutionModal/CenterBox/CardPanel/Margin/VBox/StatusText
@onready var evo_sprite: TextureRect = $EvolutionModal/CenterBox/CardPanel/Margin/VBox/SpriteBox/PkmnSprite
@onready var evo_heal_row: HBoxContainer = $EvolutionModal/CenterBox/CardPanel/Margin/VBox/HealBadgeRow
@onready var evo_heal_label: Label = $EvolutionModal/CenterBox/CardPanel/Margin/VBox/HealBadgeRow/HealLabel
@onready var evo_hp_bar: ProgressBar = $EvolutionModal/CenterBox/CardPanel/Margin/VBox/HpBar
@onready var evo_hp_text: Label = $EvolutionModal/CenterBox/CardPanel/Margin/VBox/HpText
@onready var evo_btn_continue: Button = $EvolutionModal/CenterBox/CardPanel/Margin/VBox/BtnContinueEvo
var current_evo_tween: Tween = null
var current_evo_finish_cb: Callable = Callable()
var completed_evolutions_this_battle: Array[Dictionary] = []

# --- TUTORIAL DE COMBATE ---
var tutorial_callout_modal: Control = null
var tutorial_callout_badge_lbl: Label = null
var tutorial_callout_title_lbl: Label = null
var tutorial_callout_text_lbl: RichTextLabel = null
var btn_tutorial_callout_next: Button = null
var tutorial_callout_callback: Callable = Callable()
var tutorial_steps_shown: Dictionary = {}

var type_chart_cell_buttons: Dictionary = {}

const TYPE_CHART_ORDER = [
	"GRASS", "FIRE", "WATER", "ELECTRIC", "GROUND",
	"FIGHTING", "PSYCHIC", "DARK", "NORMAL"
]

const TYPE_NAMES_EN = {
	"GRASS": "GRASS",
	"FIRE": "FIRE",
	"WATER": "WATER",
	"ELECTRIC": "ELECTRIC",
	"THUNDER": "ELECTRIC",
	"GROUND": "GROUND",
	"FIGHTING": "FIGHTING",
	"PSYCHIC": "PSYCHIC",
	"DARK": "DARK",
	"NORMAL": "NORMAL"
}

func _ready() -> void:
	btn_back_menu.pressed.connect(_on_back_menu_pressed)
	btn_game_over_menu.pressed.connect(_on_return_to_menu)
	btn_move1.pressed.connect(_on_move1_pressed)
	btn_move2.pressed.connect(_on_move2_pressed)
	chk_boost.visible = false
	chk_boost.toggled.connect(_on_boost_toggled)
	btn_passive.pressed.connect(_on_passive_pressed)
	btn_recover.pressed.connect(_on_recover_pressed)
	btn_switch_1.pressed.connect(func(): _on_switch_pressed(0))
	btn_switch_2.pressed.connect(func(): _on_switch_pressed(1))
	btn_restart.pressed.connect(start_new_game)
	btn_cancel_energy.pressed.connect(func(): energy_modal.visible = false)
	energy_modal.visible = false
	
	btn_bag.pressed.connect(_on_bag_pressed)
	btn_cancel_bag.pressed.connect(func(): bag_modal.visible = false)
	bag_modal.visible = false
	
	if btn_type_chart:
		btn_type_chart.pressed.connect(_on_type_chart_pressed)
	if btn_close_type_chart_x:
		btn_close_type_chart_x.pressed.connect(func(): type_chart_modal.visible = false)
	if btn_close_type_chart_bottom:
		btn_close_type_chart_bottom.pressed.connect(func(): type_chart_modal.visible = false)
	if type_chart_modal:
		type_chart_modal.visible = false
	_build_type_chart_matrix()
	
	# Asegurar z_index elevado en todos los modales para que ningún gráfico de cartas (lupa 🔍, status FX o foils) se sobreponga
	if floating_numbers_layer: floating_numbers_layer.z_index = 10
	if energy_modal: energy_modal.z_index = 40
	if bag_modal: bag_modal.z_index = 40
	if type_chart_modal: type_chart_modal.z_index = 45
	if evolution_modal: evolution_modal.z_index = 60
	if game_over_panel: game_over_panel.z_index = 75
	
	if battle_title_lbl:
		battle_title_lbl.clip_text = true
		battle_title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	if enemy_type_lbl:
		enemy_type_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if player_type_lbl:
		player_type_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var em_sb = StyleBoxFlat.new()
	em_sb.bg_color = Color("#121722")
	em_sb.border_color = Color("#384860")
	em_sb.set_border_width_all(2)
	em_sb.set_corner_radius_all(10)
	energy_modal_panel.add_theme_stylebox_override("panel", em_sb)
	
	var bm_sb = StyleBoxFlat.new()
	bm_sb.bg_color = Color("#121722")
	bm_sb.border_color = Color("#4caf50")
	bm_sb.set_border_width_all(2)
	bm_sb.set_corner_radius_all(10)
	bag_panel.add_theme_stylebox_override("panel", bm_sb)
	
	# Estilo para EvolutionModal
	if evolution_modal:
		evolution_modal.visible = false
		var evo_sb = StyleBoxFlat.new()
		evo_sb.bg_color = Color("#101726")
		evo_sb.border_color = Color("#f59e0b")
		evo_sb.set_border_width_all(3)
		evo_sb.set_corner_radius_all(12)
		evo_sb.shadow_size = 18
		evo_sb.shadow_offset = Vector2(0, 6)
		evo_sb.shadow_color = Color(0, 0, 0, 0.85)
		if evo_card_panel:
			evo_card_panel.add_theme_stylebox_override("panel", evo_sb)
			
		var hp_bg = StyleBoxFlat.new()
		hp_bg.bg_color = Color("#1e293b")
		hp_bg.set_corner_radius_all(4)
		
		var hp_fill = StyleBoxFlat.new()
		hp_fill.bg_color = Color("#22c55e")
		hp_fill.set_corner_radius_all(4)
		
		if evo_hp_bar:
			evo_hp_bar.add_theme_stylebox_override("background", hp_bg)
			evo_hp_bar.add_theme_stylebox_override("fill", hp_fill)
			
		if evo_btn_continue:
			var btn_sb = StyleBoxFlat.new()
			btn_sb.bg_color = Color("#1e293b")
			btn_sb.border_color = Color("#60a5fa")
			btn_sb.set_border_width_all(2)
			btn_sb.set_corner_radius_all(8)
			btn_sb.content_margin_left = 14
			btn_sb.content_margin_right = 14
			btn_sb.content_margin_top = 6
			btn_sb.content_margin_bottom = 6
			evo_btn_continue.add_theme_stylebox_override("normal", btn_sb)
			evo_btn_continue.add_theme_stylebox_override("hover", btn_sb)
			evo_btn_continue.add_theme_stylebox_override("pressed", btn_sb)
			evo_btn_continue.pressed.connect(_on_evo_continue_pressed)
	
	_setup_battle_hud_theme()
	
	# BGM de combate
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BattleBGMPlayer"
	add_child(bgm_player)
	var bgm_stream = load("res://assets/bgm/1-11. Battle! (Trainer).mp3")
	if bgm_stream:
		if bgm_stream is AudioStreamMP3:
			bgm_stream.loop = true
		bgm_player.stream = bgm_stream
		bgm_player.volume_db = GameData.get_music_db()
		bgm_player.play()
		
	if btn_speed:
		btn_speed.pressed.connect(_on_speed_toggle_pressed)
		if GameData.is_online_pvp:
			btn_speed.disabled = true
			btn_speed.text = "🔒 1x"
			btn_speed.tooltip_text = "Speed locked to 1x in online PvP"
			Engine.time_scale = 1.0
		else:
			var s_idx = clampi(GameData.battle_speed_index, 0, SPEED_LEVELS.size() - 1)
			Engine.time_scale = SPEED_LEVELS[s_idx]
			btn_speed.text = SPEED_LABELS[s_idx]
			
	if GameData.is_online_pvp:
		OnlineManager.start_polling(1.0)
		if not OnlineManager.opponent_action_received.is_connected(_on_online_opponent_action):
			OnlineManager.opponent_action_received.connect(_on_online_opponent_action)
		if not OnlineManager.opponent_left_or_surrendered.is_connected(_on_online_opponent_surrender):
			OnlineManager.opponent_left_or_surrendered.connect(_on_online_opponent_surrender)
	
	if enemy_card_img and not enemy_card_img.has_meta("original_pos"):
		enemy_card_img.set_meta("original_pos", enemy_card_img.position)
	if player_card_img and not player_card_img.has_meta("original_pos"):
		player_card_img.set_meta("original_pos", player_card_img.position)
	
	_setup_status_overlays()
	_setup_details_inspector_modal()
	start_new_game()

func _setup_status_overlays() -> void:
	if player_card_img and not player_status_overlay:
		player_status_overlay = StatusFXOverlay.new()
		player_status_overlay.size = player_card_img.size
		player_status_overlay.z_as_relative = true
		player_status_overlay.z_index = 2
		player_card_img.add_child(player_status_overlay)
	if enemy_card_img and not enemy_status_overlay:
		enemy_status_overlay = StatusFXOverlay.new()
		enemy_status_overlay.size = enemy_card_img.size
		enemy_status_overlay.z_as_relative = true
		enemy_status_overlay.z_index = 2
		enemy_card_img.add_child(enemy_status_overlay)

# --- MODAL DE DETALLES DE POKÉMON Y MOVIMIENTOS EN COMBATE ---
var details_modal: Control
var details_tab_player_btn: Button
var details_tab_enemy_btn: Button
var details_scroll: ScrollContainer
var details_content_box: VBoxContainer
var details_is_enemy_selected: bool = false

func _setup_details_inspector_modal() -> void:
	if details_modal:
		return
		
	# 1. Botón Info en TopBar
	var top_bar = get_node_or_null("MainContainer/TopBar")
	if top_bar and not top_bar.get_node_or_null("BtnDetailsInfo"):
		var btn_info = Button.new()
		btn_info.name = "BtnDetailsInfo"
		btn_info.text = "📜 Info"
		btn_info.custom_minimum_size = Vector2(64, 30)
		btn_info.add_theme_font_size_override("font_size", 11)
		btn_info.pressed.connect(func():
			show_pokemon_details(get_active_player(), false)
		)
		top_bar.add_child(btn_info)
		top_bar.move_child(btn_info, 3)
		
	# 2. Hacer las cartas interactivas para abrir inspector al hacer clic o pulsar la lupa
	if player_card_img:
		player_card_img.mouse_filter = Control.MOUSE_FILTER_STOP
		player_card_img.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if not player_card_img.gui_input.is_connected(_on_player_card_clicked):
			player_card_img.gui_input.connect(_on_player_card_clicked)
		if player_card_img.has_signal("inspect_requested"):
			if not player_card_img.inspect_requested.is_connected(_on_player_inspect_pressed):
				player_card_img.inspect_requested.connect(_on_player_inspect_pressed)
			
	if enemy_card_img:
		enemy_card_img.mouse_filter = Control.MOUSE_FILTER_STOP
		enemy_card_img.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if not enemy_card_img.gui_input.is_connected(_on_enemy_card_clicked):
			enemy_card_img.gui_input.connect(_on_enemy_card_clicked)
		if enemy_card_img.has_signal("inspect_requested"):
			if not enemy_card_img.inspect_requested.is_connected(_on_enemy_inspect_pressed):
				enemy_card_img.inspect_requested.connect(_on_enemy_inspect_pressed)

	# 3. Construcción del modal
	details_modal = Control.new()
	details_modal.name = "CombatDetailsModal"
	details_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	details_modal.visible = false
	details_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	details_modal.z_index = 50
	add_child(details_modal)
	
	# Backdrop oscuro
	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.02, 0.04, 0.08, 0.82)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			details_modal.visible = false
	)
	details_modal.add_child(backdrop)
	
	# CenterContainer
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	details_modal.add_child(center)
	
	# PanelContainer
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(430, 560)
	var p_sb = StyleBoxFlat.new()
	p_sb.bg_color = Color(0.08, 0.11, 0.17, 0.98)
	p_sb.border_color = Color(0.24, 0.44, 0.72, 0.9)
	p_sb.set_border_width_all(2)
	p_sb.set_corner_radius_all(10)
	p_sb.shadow_color = Color(0, 0, 0, 0.75)
	p_sb.shadow_size = 14
	panel.add_theme_stylebox_override("panel", p_sb)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(main_vbox)
	
	# Header Row
	var header_row = HBoxContainer.new()
	main_vbox.add_child(header_row)
	
	var title_lbl = Label.new()
	title_lbl.text = "📜 POKÉMON & MOVES DETAILS"
	title_lbl.add_theme_font_size_override("font_size", 14)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(title_lbl)
	
	var close_btn = Button.new()
	close_btn.text = "✖"
	close_btn.custom_minimum_size = Vector2(30, 28)
	close_btn.pressed.connect(func(): details_modal.visible = false)
	header_row.add_child(close_btn)
	
	# Tabs Row (Tu Pokémon vs Rival)
	var tabs_row = HBoxContainer.new()
	tabs_row.add_theme_constant_override("separation", 8)
	main_vbox.add_child(tabs_row)
	
	details_tab_player_btn = Button.new()
	details_tab_player_btn.text = "🟢 Your Pokémon"
	details_tab_player_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_tab_player_btn.custom_minimum_size = Vector2(0, 32)
	details_tab_player_btn.pressed.connect(func():
		show_pokemon_details(get_active_player(), false)
	)
	tabs_row.add_child(details_tab_player_btn)
	
	details_tab_enemy_btn = Button.new()
	details_tab_enemy_btn.text = "🔴 Rival's Pokémon"
	details_tab_enemy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_tab_enemy_btn.custom_minimum_size = Vector2(0, 32)
	details_tab_enemy_btn.pressed.connect(func():
		show_pokemon_details(get_active_enemy(), true)
	)
	tabs_row.add_child(details_tab_enemy_btn)
	
	# ScrollContainer para contenido
	details_scroll = ScrollContainer.new()
	details_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details_scroll.custom_minimum_size = Vector2(0, 420)
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(details_scroll)
	
	details_content_box = VBoxContainer.new()
	details_content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_content_box.add_theme_constant_override("separation", 10)
	details_scroll.add_child(details_content_box)
	
	# Botón inferior para cerrar
	var bot_close = Button.new()
	bot_close.text = "Close / Return to Battle"
	bot_close.custom_minimum_size = Vector2(0, 32)
	bot_close.pressed.connect(func(): details_modal.visible = false)
	main_vbox.add_child(bot_close)

func _on_player_card_clicked(event: InputEvent) -> void:
	if (game_over_panel and game_over_panel.visible) or (evolution_modal and evolution_modal.visible):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_pokemon_details(get_active_player(), false)

func _on_enemy_card_clicked(event: InputEvent) -> void:
	if (game_over_panel and game_over_panel.visible) or (evolution_modal and evolution_modal.visible):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		show_pokemon_details(get_active_enemy(), true)

func _on_player_inspect_pressed() -> void:
	if (game_over_panel and game_over_panel.visible) or (evolution_modal and evolution_modal.visible):
		return
	show_pokemon_details(get_active_player(), false)

func _on_enemy_inspect_pressed() -> void:
	if (game_over_panel and game_over_panel.visible) or (evolution_modal and evolution_modal.visible):
		return
	show_pokemon_details(get_active_enemy(), true)

func show_pokemon_details(pkmn, is_enemy: bool = false) -> void:
	if (game_over_panel and game_over_panel.visible) or (evolution_modal and evolution_modal.visible):
		return
	if not details_modal:
		_setup_details_inspector_modal()
	if not pkmn:
		return
		
	details_is_enemy_selected = is_enemy
	details_tab_player_btn.modulate = Color(1.0, 1.0, 1.0, 1.0) if not is_enemy else Color(0.65, 0.65, 0.7, 0.7)
	details_tab_enemy_btn.modulate = Color(1.0, 1.0, 1.0, 1.0) if is_enemy else Color(0.65, 0.65, 0.7, 0.7)
	
	# Limpiar contenido anterior
	for c in details_content_box.get_children():
		c.queue_free()
		
	var active_p = get_active_player()
	var active_e = get_active_enemy()
	var opponent = active_p if is_enemy else active_e
	
	# 1. Header Card (Overview)
	var header_panel = PanelContainer.new()
	var hp_sb = StyleBoxFlat.new()
	hp_sb.bg_color = Color(0.12, 0.16, 0.24, 0.9)
	hp_sb.border_color = Color(0.25, 0.45, 0.7, 0.6)
	hp_sb.set_border_width_all(1)
	hp_sb.set_corner_radius_all(8)
	header_panel.add_theme_stylebox_override("panel", hp_sb)
	details_content_box.add_child(header_panel)
	
	var hp_margin = MarginContainer.new()
	hp_margin.add_theme_constant_override("margin_left", 8)
	hp_margin.add_theme_constant_override("margin_right", 8)
	hp_margin.add_theme_constant_override("margin_top", 8)
	hp_margin.add_theme_constant_override("margin_bottom", 8)
	header_panel.add_child(hp_margin)
	
	var hp_hbox = HBoxContainer.new()
	hp_hbox.add_theme_constant_override("separation", 10)
	hp_margin.add_child(hp_hbox)
	
	# Miniatura del Pokémon
	var card_rect = TextureRect.new()
	card_rect.custom_minimum_size = Vector2(72, 100)
	card_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex = GameData.get_pokemon_texture(pkmn.texture_path)
	if tex: card_rect.texture = tex
	hp_hbox.add_child(card_rect)
	
	# Datos del Pokémon
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 3)
	hp_hbox.add_child(info_vbox)
	
	# Fila Nombre + Tipo
	var name_row = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 6)
	info_vbox.add_child(name_row)
	
	var type_ico = TextureRect.new()
	type_ico.custom_minimum_size = Vector2(18, 18)
	type_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	type_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	type_ico.texture = GameData.get_type_icon_texture(pkmn.type)
	name_row.add_child(type_ico)
	
	var name_lbl = Label.new()
	name_lbl.text = pkmn.name
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_row.add_child(name_lbl)
	
	var stage_lbl = Label.new()
	stage_lbl.text = "• %s" % pkmn.stage
	stage_lbl.add_theme_font_size_override("font_size", 11)
	stage_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	name_row.add_child(stage_lbl)
	
	# HP & Energy
	var stats_lbl = Label.new()
	stats_lbl.text = "❤️ HP: %d / %d   ⚡ Energy: %d / %d   👟 SPD: %d" % [
		pkmn.current_hp, pkmn.max_hp, pkmn.current_energy, pkmn.max_energy,
		get_pokemon_effective_speed(pkmn, opponent)
	]
	stats_lbl.add_theme_font_size_override("font_size", 11)
	stats_lbl.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	info_vbox.add_child(stats_lbl)
	
	# Weakness & Resistances
	var eff_resists = GameData.get_effective_resistances(pkmn.type, pkmn.resistant)
	var res_text = ", ".join(eff_resists) if not eff_resists.is_empty() else "NONE"
	var weak_lbl = RichTextLabel.new()
	weak_lbl.bbcode_enabled = true
	weak_lbl.fit_content = true
	weak_lbl.text = "[color=#FF8A80]Weakness (+2 DMG):[/color] %s  |  [color=#81D4FA]Resist (-2 DMG):[/color] %s" % [pkmn.weakness, res_text]
	weak_lbl.add_theme_font_size_override("normal_font_size", 10)
	info_vbox.add_child(weak_lbl)
	
	# Estados Negativos Activos
	var status_list = _format_status_list(pkmn)
	if not status_list.is_empty():
		var st_lbl = Label.new()
		st_lbl.text = "⚠️ Status: " + " | ".join(status_list)
		st_lbl.add_theme_font_size_override("font_size", 10)
		st_lbl.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2))
		info_vbox.add_child(st_lbl)

	# 2. MOVES SECTION
	var moves_title = Label.new()
	moves_title.text = "⚔️ POKÉMON MOVES"
	moves_title.add_theme_font_size_override("font_size", 12)
	moves_title.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	details_content_box.add_child(moves_title)
	
	for m_idx in range(min(2, pkmn.moves.size())):
		var m = pkmn.moves[m_idx]
		var move_card = PanelContainer.new()
		var m_sb = StyleBoxFlat.new()
		m_sb.bg_color = Color(0.10, 0.13, 0.19, 0.95)
		m_sb.border_color = Color(0.2, 0.35, 0.55, 0.5)
		m_sb.set_border_width_all(1)
		m_sb.set_corner_radius_all(6)
		move_card.add_theme_stylebox_override("panel", m_sb)
		details_content_box.add_child(move_card)
		
		var m_margin = MarginContainer.new()
		m_margin.add_theme_constant_override("margin_left", 10)
		m_margin.add_theme_constant_override("margin_right", 10)
		m_margin.add_theme_constant_override("margin_top", 8)
		m_margin.add_theme_constant_override("margin_bottom", 8)
		move_card.add_child(m_margin)
		
		var m_vbox = VBoxContainer.new()
		m_vbox.add_theme_constant_override("separation", 4)
		m_margin.add_child(m_vbox)
		
		# Move Header: Name + Type Badge
		var m_head = HBoxContainer.new()
		m_head.add_theme_constant_override("separation", 6)
		m_vbox.add_child(m_head)
		
		var m_ico = TextureRect.new()
		m_ico.custom_minimum_size = Vector2(16, 16)
		m_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		m_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		m_ico.texture = GameData.get_type_icon_texture(m.type)
		m_head.add_child(m_ico)
		
		var m_name_lbl = Label.new()
		m_name_lbl.text = "Move %d: %s [%s]" % [m_idx + 1, m.name, m.type]
		m_name_lbl.add_theme_font_size_override("font_size", 12)
		m_name_lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		m_head.add_child(m_name_lbl)
		
		# Move Stats Line
		var m_stats = Label.new()
		var dmg_str = "%d DMG" % m.base_damage if m.effect_type != "MULTI_ATTACK" else "2-5 DMG / hit (25% Crit)"
		m_stats.text = "💥 Base: %s  |  ⚡ Cost: %d⚡  |  ⚡ Req: %d⚡" % [dmg_str, m.cost, m.min_energy_req]
		m_stats.add_theme_font_size_override("font_size", 10)
		m_stats.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		m_vbox.add_child(m_stats)
		
		# Move Description
		var m_desc = RichTextLabel.new()
		m_desc.bbcode_enabled = true
		m_desc.fit_content = true
		m_desc.add_theme_font_size_override("normal_font_size", 11)
		var desc_text = m.description if m.description != "" else "Standard attack."
		m_desc.text = "[color=#CFD8DC]%s[/color]" % desc_text
		m_vbox.add_child(m_desc)
		
		# Boost Info
		if m.can_boost:
			var boost_lbl = RichTextLabel.new()
			boost_lbl.bbcode_enabled = true
			boost_lbl.fit_content = true
			boost_lbl.add_theme_font_size_override("normal_font_size", 10)
			boost_lbl.text = "[color=#FFB74D]🔥 Boost Effect (+%d⚡):[/color] [color=#FFE0B2]+%d Extra Damage%s[/color]" % [
				m.boost_cost, m.boost_damage,
				" & applies Burn" if m.boost_applies_burn else ""
			]
			m_vbox.add_child(boost_lbl)

	# 3. PASSIVE ABILITY SECTION
	if pkmn.has_passive and pkmn.passive_name != "":
		var pas_title = Label.new()
		pas_title.text = "✨ PASSIVE ABILITY"
		pas_title.add_theme_font_size_override("font_size", 12)
		pas_title.add_theme_color_override("font_color", Color(0.8, 0.6, 1.0))
		details_content_box.add_child(pas_title)
		
		var pas_card = PanelContainer.new()
		var pas_sb = StyleBoxFlat.new()
		pas_sb.bg_color = Color(0.13, 0.11, 0.20, 0.95)
		pas_sb.border_color = Color(0.45, 0.3, 0.65, 0.6)
		pas_sb.set_border_width_all(1)
		pas_sb.set_corner_radius_all(6)
		pas_card.add_theme_stylebox_override("panel", pas_sb)
		details_content_box.add_child(pas_card)
		
		var pas_margin = MarginContainer.new()
		pas_margin.add_theme_constant_override("margin_left", 10)
		pas_margin.add_theme_constant_override("margin_right", 10)
		pas_margin.add_theme_constant_override("margin_top", 8)
		pas_margin.add_theme_constant_override("margin_bottom", 8)
		pas_card.add_child(pas_margin)
		
		var pas_vbox = VBoxContainer.new()
		pas_vbox.add_theme_constant_override("separation", 3)
		pas_margin.add_child(pas_vbox)
		
		var p_name = Label.new()
		p_name.text = "✨ %s" % pkmn.passive_name
		p_name.add_theme_font_size_override("font_size", 12)
		p_name.add_theme_color_override("font_color", Color(0.9, 0.75, 1.0))
		pas_vbox.add_child(p_name)
		
		var p_desc = RichTextLabel.new()
		p_desc.bbcode_enabled = true
		p_desc.fit_content = true
		p_desc.add_theme_font_size_override("normal_font_size", 11)
		p_desc.text = "[color=#E1BEE7]%s[/color]" % pkmn.passive_desc
		pas_vbox.add_child(p_desc)

	details_modal.visible = true

func _on_speed_toggle_pressed() -> void:
	if GameData.is_online_pvp:
		return
	GameData.battle_speed_index = (GameData.battle_speed_index + 1) % SPEED_LEVELS.size()
	var new_scale = SPEED_LEVELS[GameData.battle_speed_index]
	Engine.time_scale = new_scale
	if btn_speed:
		btn_speed.text = SPEED_LABELS[GameData.battle_speed_index]
		var tw = create_tween()
		tw.tween_property(btn_speed, "scale", Vector2(1.15, 1.15), 0.06)
		tw.tween_property(btn_speed, "scale", Vector2.ONE, 0.08)

var forfeit_modal: Control = null
var forfeit_title_lbl: Label = null
var forfeit_body_lbl: Label = null
var btn_confirm_forfeit: Button = null
var btn_cancel_forfeit: Button = null

func _setup_forfeit_confirmation_modal() -> void:
	if forfeit_modal:
		return
	
	forfeit_modal = Control.new()
	forfeit_modal.name = "ForfeitConfirmationModal"
	forfeit_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	forfeit_modal.visible = false
	forfeit_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	forfeit_modal.z_index = 65
	add_child(forfeit_modal)
	
	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.02, 0.04, 0.08, 0.85)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	forfeit_modal.add_child(backdrop)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	forfeit_modal.add_child(center)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(360, 200)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color("#FF5252")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.shadow_color = Color(0, 0, 0, 0.7)
	sb.shadow_size = 14
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)
	
	forfeit_title_lbl = Label.new()
	forfeit_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	forfeit_title_lbl.add_theme_font_size_override("font_size", 16)
	forfeit_title_lbl.add_theme_color_override("font_color", Color("#FF5252"))
	vbox.add_child(forfeit_title_lbl)
	
	forfeit_body_lbl = Label.new()
	forfeit_body_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	forfeit_body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	forfeit_body_lbl.custom_minimum_size = Vector2(310, 0)
	forfeit_body_lbl.add_theme_font_size_override("font_size", 12)
	forfeit_body_lbl.add_theme_color_override("font_color", Color("#CFD8DC"))
	vbox.add_child(forfeit_body_lbl)
	
	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn_row)
	
	btn_cancel_forfeit = Button.new()
	btn_cancel_forfeit.text = "⚔️ Keep Battling"
	btn_cancel_forfeit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_cancel_forfeit.custom_minimum_size = Vector2(0, 38)
	var sb_cancel = StyleBoxFlat.new()
	sb_cancel.bg_color = Color(0.12, 0.28, 0.18, 0.95)
	sb_cancel.border_color = Color("#4CAF50")
	sb_cancel.set_border_width_all(1)
	sb_cancel.set_corner_radius_all(6)
	btn_cancel_forfeit.add_theme_stylebox_override("normal", sb_cancel)
	btn_cancel_forfeit.add_theme_stylebox_override("hover", sb_cancel)
	btn_cancel_forfeit.add_theme_color_override("font_color", Color("#81C784"))
	btn_cancel_forfeit.pressed.connect(func():
		forfeit_modal.visible = false
	)
	btn_row.add_child(btn_cancel_forfeit)
	
	btn_confirm_forfeit = Button.new()
	btn_confirm_forfeit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_confirm_forfeit.custom_minimum_size = Vector2(0, 38)
	var sb_confirm = StyleBoxFlat.new()
	sb_confirm.bg_color = Color(0.35, 0.1, 0.1, 0.95)
	sb_confirm.border_color = Color("#FF5252")
	sb_confirm.set_border_width_all(1)
	sb_confirm.set_corner_radius_all(6)
	btn_confirm_forfeit.add_theme_stylebox_override("normal", sb_confirm)
	btn_confirm_forfeit.add_theme_stylebox_override("hover", sb_confirm)
	btn_confirm_forfeit.add_theme_color_override("font_color", Color("#FF8A80"))
	btn_confirm_forfeit.pressed.connect(_on_confirm_forfeit_pressed)
	btn_row.add_child(btn_confirm_forfeit)

func _setup_tutorial_callout_modal() -> void:
	if tutorial_callout_modal:
		return
		
	tutorial_callout_modal = Control.new()
	tutorial_callout_modal.name = "TutorialCalloutModal"
	tutorial_callout_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_callout_modal.visible = false
	tutorial_callout_modal.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_callout_modal.z_index = 70
	add_child(tutorial_callout_modal)
	
	var backdrop = ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.02, 0.04, 0.08, 0.85)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	tutorial_callout_modal.add_child(backdrop)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_callout_modal.add_child(center)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(380, 0)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color("#FFD700")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.shadow_color = Color(0, 0, 0, 0.8)
	sb.shadow_size = 16
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	
	tutorial_callout_badge_lbl = Label.new()
	tutorial_callout_badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_callout_badge_lbl.add_theme_font_size_override("font_size", 11)
	tutorial_callout_badge_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	vbox.add_child(tutorial_callout_badge_lbl)
	
	tutorial_callout_title_lbl = Label.new()
	tutorial_callout_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_callout_title_lbl.add_theme_font_size_override("font_size", 16)
	tutorial_callout_title_lbl.add_theme_color_override("font_color", Color("#FFFFFF"))
	vbox.add_child(tutorial_callout_title_lbl)
	
	tutorial_callout_text_lbl = RichTextLabel.new()
	tutorial_callout_text_lbl.bbcode_enabled = true
	tutorial_callout_text_lbl.fit_content = true
	tutorial_callout_text_lbl.scroll_active = false
	tutorial_callout_text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_callout_text_lbl.custom_minimum_size = Vector2(340, 0)
	tutorial_callout_text_lbl.add_theme_font_size_override("normal_font_size", 12)
	tutorial_callout_text_lbl.add_theme_color_override("default_color", Color("#CFD8DC"))
	vbox.add_child(tutorial_callout_text_lbl)
	
	btn_tutorial_callout_next = Button.new()
	btn_tutorial_callout_next.text = "Understood! ➡️"
	btn_tutorial_callout_next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tutorial_callout_next.custom_minimum_size = Vector2(0, 38)
	var sb_btn = StyleBoxFlat.new()
	sb_btn.bg_color = Color(0.15, 0.45, 0.25, 0.95)
	sb_btn.border_color = Color("#4CAF50")
	sb_btn.set_border_width_all(2)
	sb_btn.set_corner_radius_all(6)
	btn_tutorial_callout_next.add_theme_stylebox_override("normal", sb_btn)
	btn_tutorial_callout_next.add_theme_stylebox_override("hover", sb_btn)
	btn_tutorial_callout_next.add_theme_color_override("font_color", Color("#E8F5E9"))
	btn_tutorial_callout_next.pressed.connect(_on_tutorial_callout_next_pressed)
	vbox.add_child(btn_tutorial_callout_next)

func _show_tutorial_callout(step_key: String, badge: String, title: String, text_bbcode: String, btn_text: String = "Understood! ➡️", callback: Callable = Callable()) -> void:
	_setup_tutorial_callout_modal()
	tutorial_callout_badge_lbl.text = badge.to_upper()
	tutorial_callout_title_lbl.text = title
	tutorial_callout_text_lbl.text = text_bbcode
	btn_tutorial_callout_next.text = btn_text
	tutorial_callout_callback = callback
	tutorial_steps_shown[step_key] = true
	tutorial_callout_modal.visible = true

func _on_tutorial_callout_next_pressed() -> void:
	if tutorial_callout_modal:
		tutorial_callout_modal.visible = false
	var cb = tutorial_callout_callback
	tutorial_callout_callback = Callable()
	if cb.is_valid():
		cb.call()

func _on_back_menu_pressed() -> void:
	if is_battle_over:
		_on_return_to_menu()
	else:
		_show_forfeit_confirmation_modal()

func _show_forfeit_confirmation_modal() -> void:
	_setup_forfeit_confirmation_modal()
	
	if GameData.is_tutorial_mode:
		forfeit_title_lbl.text = "🎓 EXIT TUTORIAL?"
		forfeit_body_lbl.text = "Are you sure you want to exit the Tutorial?\nYou can restart it anytime to learn mechanics and claim your 💎 5 Diamonds."
		btn_confirm_forfeit.text = "🚪 Exit Tutorial"
	elif GameData.is_online_pvp:
		var r_name = GameData.online_rival_name if not GameData.online_rival_name.is_empty() else "your opponent"
		forfeit_title_lbl.text = "🏳️ FORFEIT MATCH?"
		forfeit_body_lbl.text = "Are you sure you want to surrender?\nYou will forfeit the match to %s." % r_name
		btn_confirm_forfeit.text = "🏳️ Forfeit & Surrender"
	elif GameData.is_campaign_mode:
		if GameData.campaign_submode == "ADVENTURE":
			forfeit_title_lbl.text = "⚠️ RETREAT FROM ADVENTURE?"
			forfeit_body_lbl.text = "Are you sure you want to retreat?\nCurrent episode progress will be reset.\n(Your earned Gold and Diamonds are safe)."
		else:
			forfeit_title_lbl.text = "⚠️ FORFEIT TOURNAMENT?"
			forfeit_body_lbl.text = "Are you sure you want to retreat?\nYour current tournament run will be abandoned.\n(Your Gold and Diamonds are safe)."
		btn_confirm_forfeit.text = "🏳️ Retreat"
	else:
		forfeit_title_lbl.text = "🚪 EXIT BATTLE?"
		forfeit_body_lbl.text = "Are you sure you want to exit to the Main Menu?\nCurrent battle progress will be lost."
		btn_confirm_forfeit.text = "🚪 Exit Battle"
		
	forfeit_modal.visible = true

func _on_confirm_forfeit_pressed() -> void:
	if forfeit_modal:
		forfeit_modal.visible = false
	if GameData.is_online_pvp:
		OnlineManager.send_battle_action({ "type": "SURRENDER" })
	_on_return_to_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if forfeit_modal and forfeit_modal.visible:
			forfeit_modal.visible = false
			get_viewport().set_input_as_handled()
		elif details_modal and details_modal.visible:
			details_modal.visible = false
			get_viewport().set_input_as_handled()
		elif bag_modal and bag_modal.visible:
			bag_modal.visible = false
			get_viewport().set_input_as_handled()
		elif not is_battle_over:
			_show_forfeit_confirmation_modal()
			get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if forfeit_modal and forfeit_modal.visible:
			forfeit_modal.visible = false
		elif details_modal and details_modal.visible:
			details_modal.visible = false
		elif bag_modal and bag_modal.visible:
			bag_modal.visible = false
		elif not is_battle_over:
			_show_forfeit_confirmation_modal()
		else:
			_on_return_to_menu()

func _on_return_to_menu() -> void:
	Engine.time_scale = 1.0
	if GameData.is_tutorial_mode:
		GameData.is_tutorial_mode = false
	if GameData.is_online_pvp:
		OnlineManager.leave_or_delete_room()
		GameData.is_online_pvp = false
	if not is_battle_over and GameData.is_campaign_mode and GameData.campaign_submode == "ADVENTURE":
		# Solo si se abandona a mitad de combate (forfeit):
		# Si sales antes de terminar el combate, se reinicia el progreso del episodio conservando los recursos G y Diamonds
		GameData.reset_adventure_episode(GameData.adventure_current_episode)
		GameData.is_campaign_mode = false
		GameData.save_profile()
	if bgm_player and bgm_player.playing:
		bgm_player.stop()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _exit_tree() -> void:
	Engine.time_scale = 1.0
	if GameData.is_tutorial_mode:
		GameData.is_tutorial_mode = false
	if GameData.is_online_pvp:
		OnlineManager.leave_or_delete_room()
		GameData.is_online_pvp = false

func get_active_player():
	if player_team.is_empty():
		return null
	if active_player_idx < 0 or active_player_idx >= player_team.size():
		return player_team[0]
	return player_team[active_player_idx]

func get_active_enemy():
	if enemy_team.is_empty():
		return null
	if active_enemy_idx < 0 or active_enemy_idx >= enemy_team.size():
		return enemy_team[0]
	return enemy_team[active_enemy_idx]

# Calcula la velocidad efectiva considerando pasivas de campo (como String Shot de Weedle)
func get_pokemon_effective_speed(pkmn, opponent) -> int:
	if pkmn == null:
		return 1
	var spd = pkmn.get_effective_speed()
	if opponent and opponent.has_passive and opponent.passive_name == "String Shot":
		spd = max(1, spd - 1)
	return spd

func get_benched_player_indices() -> Array[int]:
	var indices: Array[int] = []
	for i in range(player_team.size()):
		if i != active_player_idx:
			indices.append(i)
	return indices

func get_benched_enemy_indices() -> Array[int]:
	var indices: Array[int] = []
	for i in range(enemy_team.size()):
		if i != active_enemy_idx:
			indices.append(i)
	return indices

func start_new_game() -> void:
	game_over_panel.visible = false
	is_battle_over = false
	is_busy = false
	can_player_act = false
	is_player_turn = false
	is_enemy_fainting = false
	is_player_fainting = false
	active_player_idx = 0
	active_enemy_idx = 0
	combat_history.clear()
	reset_selected_energy()
	
	if enemy_card_img:
		enemy_card_img.modulate = Color.WHITE
		if enemy_card_img.has_meta("original_pos"):
			enemy_card_img.position = enemy_card_img.get_meta("original_pos")
	if player_card_img:
		player_card_img.modulate = Color.WHITE
		if player_card_img.has_meta("original_pos"):
			player_card_img.position = player_card_img.get_meta("original_pos")
	
	if player_status_overlay:
		player_status_overlay.clear_all()
	if enemy_status_overlay:
		enemy_status_overlay.clear_all()
	
	defeated_enemy_indices.clear()
	combat_earned_gold = 0
	combat_earned_diamonds = 0
	defeated_rewards_summary.clear()
	sandstorm_turns = 0
	grassy_terrain_turns = 0
	pending_opponent_actions.clear()
	is_waiting_for_online_opponent = false
	is_processing_opponent_action = false
	
	if GameData.is_tutorial_mode:
		tutorial_steps_shown.clear()
		player_team = [GameData.create_pokemon_instance(1)]
		enemy_team = [GameData.create_pokemon_instance(0)]
		battle_title_lbl.text = "🎓 Battle Tutorial (Charmander vs Bulbasaur)"
	elif GameData.is_campaign_mode:
		var team_state = GameData.get_active_campaign_team_state()
		if team_state.is_empty():
			if GameData.campaign_submode == "ADVENTURE":
				GameData.init_adventure_team(GameData.adventure_current_episode, [0, 1, 2])
			else:
				GameData.init_campaign_team([0, 1, 2])
			team_state = GameData.get_active_campaign_team_state()
			
		player_team = []
		for p_state in team_state:
			var inst = GameData.create_pokemon_instance(int(p_state["id"]))
			if inst:
				inst.current_hp = p_state["current_hp"]
				var req = inst.get_required_exp()
				var loaded_exp = int(p_state.get("current_exp", 0))
				inst.current_exp = min(req, loaded_exp) if req > 0 else 0
				inst.max_exp = req
				inst.burn_turns = int(p_state.get("burn_turns", 0))
				inst.is_poisoned = bool(p_state.get("is_poisoned", false))
				inst.is_flinched = bool(p_state.get("is_flinched", false))
				player_team.append(inst)
			
		var rival_ids: Array[int] = []
		if GameData.campaign_submode == "ADVENTURE":
			rival_ids = GameData.get_adventure_rival_team(GameData.adventure_current_episode, GameData.adventure_current_stage)
			var total_stages = GameData.get_adventure_total_stages(GameData.adventure_current_episode)
			var stage_info = GameData.get_adventure_stage_info(GameData.adventure_current_episode, GameData.adventure_current_stage)
			var trainer_name = stage_info.get("trainer_name", "Trainer")
			battle_title_lbl.text = "🗺️ Ep. %d: %s (%d/%d)" % [GameData.adventure_current_episode, trainer_name, GameData.adventure_current_stage, total_stages]
		else:
			rival_ids = GameData.get_campaign_rival_team(GameData.campaign_match_number)
			var match_info = GameData.get_tournament_match_info(GameData.campaign_match_number)
			battle_title_lbl.text = "🏆 %s - Battle %d / %d" % [match_info["phase_name"], GameData.campaign_match_number, GameData.TOURNAMENT_TOTAL_MATCHES]
			
		enemy_team = []
		for eid in rival_ids:
			var inst = GameData.create_pokemon_instance(eid)
			if inst:
				enemy_team.append(inst)
	else:
		var p_ids = GameData.player_team_ids
		if p_ids.is_empty():
			p_ids = [0]
		var e_ids = GameData.enemy_team_ids
		if e_ids.is_empty():
			e_ids = [4]
			
		player_team = []
		for pid in p_ids:
			player_team.append(GameData.create_pokemon_instance(pid))
		enemy_team = []
		for eid in e_ids:
			enemy_team.append(GameData.create_pokemon_instance(eid))
			
		if GameData.is_online_pvp:
			battle_title_lbl.text = "🌐 Online vs %s (%d vs %d)" % [GameData.online_rival_name, player_team.size(), enemy_team.size()]
		else:
			battle_title_lbl.text = "Quick Battle (%d vs %d)" % [player_team.size(), enemy_team.size()]
		
	# Seleccionar el primer Pokémon vivo del jugador
	active_player_idx = 0
	for i in range(player_team.size()):
		if player_team[i].current_hp > 0:
			active_player_idx = i
			break
	active_enemy_idx = 0
	
	chk_boost.button_pressed = false
	can_player_act = false
	is_player_turn = false
	update_ui()
	set_controls_enabled(false)
	
	var active_p = get_active_player()
	var active_e = get_active_enemy()
	
	round_number = 0
	round_step = 0
	
	var mode_str = "QUICK BATTLE"
	if GameData.is_tutorial_mode:
		mode_str = "COMBAT TUTORIAL"
	elif GameData.is_online_pvp:
		mode_str = "ONLINE BATTLE"
	elif GameData.is_campaign_mode:
		if GameData.campaign_submode == "ADVENTURE":
			var total_stages = GameData.get_adventure_total_stages(GameData.adventure_current_episode)
			var stage_info = GameData.get_adventure_stage_info(GameData.adventure_current_episode, GameData.adventure_current_stage)
			var trainer_name = stage_info.get("trainer_name", "Trainer")
			mode_str = "ADVENTURE EP. %d: %s (%d/%d)" % [GameData.adventure_current_episode, trainer_name.to_upper(), GameData.adventure_current_stage, total_stages]
		else:
			var match_info_start = GameData.get_tournament_match_info(GameData.campaign_match_number)
			mode_str = "%s (Battle %d/%d)" % [match_info_start.get("phase_name", "Tournament").to_upper(), GameData.campaign_match_number, GameData.TOURNAMENT_TOTAL_MATCHES]
	log_action("[b]%s![/b]\nYour Leader: [b]%s[/b] enters the field.\nRival sends out: [b]%s[/b]." % [mode_str, active_p.name, active_e.name])
	if GameData.is_campaign_mode and GameData.campaign_submode == "ADVENTURE":
		var stage_info = GameData.get_adventure_stage_info(GameData.adventure_current_episode, GameData.adventure_current_stage)
		var intro_dialogue = stage_info.get("intro", "")
		var trainer_name = stage_info.get("trainer_name", "Opponent")
		if intro_dialogue != "":
			log_action("💬 [b]%s[/b]: \"%s\"" % [trainer_name, intro_dialogue])
	if active_e.has_passive and active_e.passive_name == "String Shot":
		log_action("✨ Weedle's [color=cyan]String Shot[/color] passively reduces foe's Speed by 1.")
	
	turn_badge.text = "STARTING BATTLE..."
	turn_badge.modulate = Color(1.0, 0.85, 0.2)
	
	var timer = get_tree().create_timer(2.2)
	timer.timeout.connect(start_new_round)

# --- REGLA DE DAÑO FRACCIONADO ---
func calculate_move_damage(move, energy_spent: int) -> int:
	if move.effect_type == "MULTI_ATTACK":
		return 0
	if move.cost <= 1:
		return move.base_damage
	var fraction = float(energy_spent) / float(move.cost)
	return int(round(move.base_damage * fraction))

# --- CICLO DE RONDAS Y TURNOS BASADO EN SPEED ---
func start_new_round() -> void:
	if is_battle_over or check_team_defeat():
		return
	if is_enemy_fainting or is_player_fainting:
		var t = get_tree().create_timer(0.4)
		t.timeout.connect(start_new_round)
		return
		
	is_busy = false
	can_player_act = false
	is_player_turn = false
	is_waiting_for_online_opponent = false
	is_processing_opponent_action = false
	set_controls_enabled(false)
		
	round_number += 1
	round_step = 0
	
	var p = get_active_player()
	var e = get_active_enemy()
	var p_spd = get_pokemon_effective_speed(p, e)
	var e_spd = get_pokemon_effective_speed(e, p)
	
	var initiative_msg = ""
	if p_spd > e_spd:
		round_order = ["PLAYER", "ENEMY"]
		initiative_msg = "[b]━━━ ROUND %d ━━━[/b]\n[b]%s[/b] is faster (SPD %d vs %d) and [color=green]takes the first turn[/color]." % [round_number, p.name, p_spd, e_spd]
	elif e_spd > p_spd:
		round_order = ["ENEMY", "PLAYER"]
		initiative_msg = "[b]━━━ ROUND %d ━━━[/b]\nRival [b]%s[/b] is faster (SPD %d vs %d) and [color=red]takes the first turn[/color]." % [round_number, e.name, e_spd, p_spd]
	else:
		var coin = randf() < 0.5
		if GameData.is_online_pvp:
			var host_wins = (round_number % 2 == 1)
			coin = host_wins if OnlineManager.is_host else (not host_wins)
		elif GameData.is_tutorial_mode:
			coin = true
		if coin:
			round_order = ["PLAYER", "ENEMY"]
			initiative_msg = "[b]━━━ ROUND %d ━━━[/b]\nSpeed Tie (SPD %d vs %d)! 🪙 [color=yellow]Coin Toss:[/color] [b]%s[/b] wins the tiebreaker and takes the first turn." % [round_number, p_spd, e_spd, p.name]
		else:
			round_order = ["ENEMY", "PLAYER"]
			initiative_msg = "[b]━━━ ROUND %d ━━━[/b]\nSpeed Tie (SPD %d vs %d)! 🪙 [color=yellow]Coin Toss:[/color] Rival [b]%s[/b] wins the tiebreaker and takes the first turn." % [round_number, p_spd, e_spd, e.name]
			
	log_action(initiative_msg)
	update_ui()
	set_controls_enabled(false)
	
	var starter_name = p.name if round_order[0] == "PLAYER" else e.name
	turn_badge.text = "ROUND %d (%s starts)" % [round_number, starter_name]
	turn_badge.modulate = Color(1.0, 0.85, 0.2)
	
	if GameData.is_tutorial_mode and round_number == 1 and not tutorial_steps_shown.get("step1", false):
		_show_tutorial_callout(
			"step1",
			"TUTORIAL • STEP 1 OF 5",
			"🎓 Welcome to Pokémon Combat!",
			"This is a tactical card battle arena.\n\n• [b]Active Pokémon[/b]: Your [color=coral]Charmander[/color] is at the bottom; rival [color=lightgreen]Bulbasaur[/color] is at the top.\n• [b]HP Bar (Hit Points)[/b]: Displays remaining life. When a Pokémon's HP reaches 0, it is knocked out (KO)!\n• [b]⚡ Energy Bar[/b]: Required to power attacks and special moves.",
			"Next ➡️",
			func():
				_show_tutorial_callout(
					"step2",
					"TUTORIAL • STEP 2 OF 5",
					"⏩ Speed & Initiative Priority",
					"Every round starts with an initiative check based on each Pokémon's [b]Speed (SPD)[/b].\n\n• The faster Pokémon acts first!\n• In a tie (SPD 1 vs SPD 1), a 🪙 [b]Coin Toss[/b] decides who gets the first turn.\n\nCharmander won the coin toss and will attack first this round!",
					"Got It! ➡️",
					func():
						var t_next = get_tree().create_timer(0.6)
						t_next.timeout.connect(execute_round_turn)
				)
		)
		return
	
	var timer = get_tree().create_timer(1.2)
	timer.timeout.connect(execute_round_turn)

func execute_round_turn() -> void:
	if is_battle_over or check_team_defeat():
		return
	if is_enemy_fainting or is_player_fainting:
		var t = get_tree().create_timer(0.4)
		t.timeout.connect(execute_round_turn)
		return
		
	if round_step < 0 or round_step >= round_order.size():
		_finish_round()
		return
		
	if round_order[round_step] == "PLAYER":
		start_player_turn()
	else:
		start_enemy_turn()

func _is_turn_action_allowed() -> bool:
	if is_busy or is_battle_over or is_enemy_fainting or is_player_fainting or not can_player_act:
		return false
	if is_player_turn:
		return true
	if not is_player_turn and GameData.is_pvp_mode:
		return true
	return false

func _process_turn_start_status(actor, opponent, actor_img: Node, opponent_img: Node, is_player: bool) -> bool:
	if not actor or not opponent:
		return false
		
	# 1. Leech Seed (Seeded)
	if actor.is_seeded_turns > 0:
		actor.is_seeded_turns -= 1
		var s_dmg = 2
		actor.current_hp = max(0, actor.current_hp - s_dmg)
		opponent.current_hp = min(opponent.max_hp, opponent.current_hp + s_dmg)
		log_action("🌱 [color=green]Leech Seed saps %d HP from %s to %s![/color]" % [s_dmg, actor.name, opponent.name])
		play_damage_hit(actor_img, "GRASS", s_dmg)
		spawn_floating_combat_number(actor_img, -s_dmg, false)
		spawn_floating_combat_number(opponent_img, s_dmg, true)
		if check_active_faint():
			update_ui()
			if check_team_defeat():
				return true
			var timer = get_tree().create_timer(2.0)
			timer.timeout.connect(func():
				if is_player: end_player_turn() else: end_enemy_turn()
			)
			return true
				
	# 2. Burn
	if actor.burn_turns > 0:
		var bdmg = actor.burn_dmg
		actor.current_hp = max(0, actor.current_hp - bdmg)
		actor.burn_turns -= 1
		log_action("🔥 [color=orange]%s takes %d Burn damage![/color] (%d turns remaining)" % [actor.name, bdmg, actor.burn_turns])
		var target_overlay = player_status_overlay if actor == get_active_player() else enemy_status_overlay
		if target_overlay:
			target_overlay.trigger_burn_effect()
		play_damage_hit(actor_img, "FIRE", bdmg)
		spawn_floating_combat_number(actor_img, -bdmg, false)
		if check_active_faint():
			update_ui()
			if check_team_defeat():
				return true
			var timer = get_tree().create_timer(2.0)
			timer.timeout.connect(func():
				if is_player: end_player_turn() else: end_enemy_turn()
			)
			return true
				
	# 3. Sleep
	if actor.is_asleep_turns > 0:
		actor.is_asleep_turns -= 1
		if actor.is_asleep_turns > 0:
			log_action("💤 [b]%s[/b] [color=lightblue]is fast asleep and cannot move! (%d rounds remaining)[/color]" % [actor.name, actor.is_asleep_turns])
			update_ui()
			var timer = get_tree().create_timer(2.0)
			timer.timeout.connect(func():
				if is_player: end_player_turn() else: end_enemy_turn()
			)
			return true
		else:
			actor.immune_sleep_rounds = 1
			log_action("✨ [b]%s[/b] [color=green]woke up from sleep and gained 1 round Sleep immunity![/color]" % actor.name)
			
	# 4. Freeze
	if actor.is_frozen:
		actor.frozen_turns += 1
		if actor.frozen_turns >= 2 or randf() < 0.25:
			actor.is_frozen = false
			actor.frozen_turns = 0
			log_action("🔥 [b]%s[/b] [color=orange]thawed out and can move![/color]" % actor.name)
		else:
			log_action("❄️ [b]%s[/b] [color=cyan]is frozen solid and cannot move! (%d/2)[/color]" % [actor.name, actor.frozen_turns])
			update_ui()
			var timer = get_tree().create_timer(2.0)
			timer.timeout.connect(func():
				if is_player: end_player_turn() else: end_enemy_turn()
			)
			return true
			
	# 5. Paralyze (25% chance unable to act, recharges energy instead, retains status)
	if actor.is_paralyzed:
		if randf() < 0.25:
			var rec = min(actor.recover_amount, actor.max_energy - actor.current_energy)
			actor.current_energy += rec
			log_action("⚡ [b]%s[/b] [color=yellow]is paralyzed! Unable to attack, recharged +%d Energy (⚡ %d/%d). (%d rounds left)[/color]" % [actor.name, rec, actor.current_energy, actor.max_energy, actor.paralyze_turns])
			var target_overlay = player_status_overlay if actor == get_active_player() else enemy_status_overlay
			if target_overlay:
				target_overlay.trigger_paralyze_effect(1.4)
			update_ui()
			var timer = get_tree().create_timer(2.0)
			timer.timeout.connect(func():
				if is_player: end_player_turn() else: end_enemy_turn()
			)
			return true
		else:
			log_action("⚡ [b]%s[/b] [color=yellow]is paralyzed but pushed through the paralysis![/color]" % actor.name)
			
	# 6. Must Rest (Hyper Beam / Giga Impact / Mind Bending)
	if actor.rest_next_turn:
		actor.rest_next_turn = false
		var rec = min(actor.recover_amount, actor.max_energy - actor.current_energy)
		actor.current_energy += rec
		log_action("😴 [b]%s[/b] [color=cyan]must rest this round and recharged +%d Energy (⚡ %d/%d).[/color]" % [actor.name, rec, actor.current_energy, actor.max_energy])
		update_ui()
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(func():
			if is_player: end_player_turn() else: end_enemy_turn()
		)
		return true
		
	# 7. Confusion (35% snap out or max 3 turns, else self-inflicts 2 DMG and skips turn)
	if actor.is_confused:
		actor.confused_turns += 1
		if actor.confused_turns >= 3 or randf() < 0.35:
			actor.is_confused = false
			actor.confused_turns = 0
			log_action("✨ [b]%s[/b] [color=green]snapped out of confusion![/color]" % actor.name)
		else:
			var self_dmg = 2
			actor.current_hp = max(0, actor.current_hp - self_dmg)
			log_action("🌀 [b]%s[/b] [color=magenta]is confused! It hurt itself in its confusion for %d DMG! (%d/3)[/color]" % [actor.name, self_dmg, actor.confused_turns])
			play_damage_hit(actor_img, "NORMAL", self_dmg)
			spawn_floating_combat_number(actor_img, -self_dmg, false)
			update_ui()
			if check_active_faint():
				if check_team_defeat():
					return true
			var timer = get_tree().create_timer(2.0)
			timer.timeout.connect(func():
				if is_player: end_player_turn() else: end_enemy_turn()
			)
			return true

	# 8. Flinch
	if actor.is_flinched:
		actor.is_flinched = false
		log_action("💫 [b]%s[/b] [color=yellow]flinched and cannot act this round![/color]" % actor.name)
		update_ui()
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(func():
			if is_player: end_player_turn() else: end_enemy_turn()
		)
		return true
		
	return false

func start_player_turn() -> void:
	if is_battle_over or check_team_defeat():
		return
	if is_enemy_fainting or is_player_fainting:
		var t = get_tree().create_timer(0.4)
		t.timeout.connect(start_player_turn)
		return
		
	is_busy = false
	is_player_turn = true
	can_player_act = false
	is_waiting_for_online_opponent = false
	is_processing_opponent_action = false
	set_controls_enabled(false)
	reset_selected_energy()
	var p = get_active_player()
	var e = get_active_enemy()
	
	if GameData.is_online_pvp:
		turn_badge.text = "ROUND %d • 🟢 YOUR TURN (%s)" % [round_number, p.name]
		turn_badge.modulate = Color(0.2, 0.9, 0.3)
	elif GameData.is_pvp_mode:
		turn_badge.text = "ROUND %d • 🔴 PLAYER 1'S TURN (%s)" % [round_number, p.name]
		turn_badge.modulate = Color(0.2, 0.9, 0.3)
	else:
		turn_badge.text = "ROUND %d • YOUR TURN (%s)" % [round_number, p.name]
		turn_badge.modulate = Color(0.2, 0.9, 0.3)
	
	if _process_turn_start_status(p, e, player_card_img, enemy_card_img, true):
		return
			
	if GameData.is_tutorial_mode and round_number == 1 and not tutorial_steps_shown.get("step3", false):
		_show_tutorial_callout(
			"step3",
			"TUTORIAL • STEP 3 OF 5",
			"🔥 Attacking & Type Advantage",
			"It is your turn! Inspect your available moves below:\n\n• [b]Scratch[/b]: Normal-type move. Deals 3 DMG. (Cost: 0 ⚡)\n• [b]Ember[/b]: Fire-type move. Deals 4 DMG. (Cost: 1 ⚡)\n\n⭐ [color=yellow][b]Type Weakness (+2 DMG):[/b][/color] Bulbasaur is GRASS type, which is weak to FIRE! Using [b]Ember[/b] triggers the Weakness bonus to deal [b]6 DAMAGE[/b] (4 + 2)!\n\n💡 [i]Recharge:[/i] If low on energy, tap [b]⚡ Recharge (+2 ⚡)[/b] instead of attacking.\n\nTap [b]Ember[/b] below to strike Bulbasaur!",
			"Let's Battle! ⚔️",
			func():
				can_player_act = true
				update_ui()
				set_controls_enabled(true)
		)
		return
	elif GameData.is_tutorial_mode and not tutorial_steps_shown.get("step5", false):
		if e and e.current_hp <= 6:
			_show_tutorial_callout(
				"step5",
				"TUTORIAL • STEP 5 OF 5",
				"💥 Delivering the Knockout!",
				"Bulbasaur is critically weakened from your previous Fire attack!\n\nDepleting its remaining HP to 0 will knock it out and secure victory.\n\nWin this battle to claim your [color=gold]💎 5 Diamonds[/color] and unlock [b]Episode I of Adventure Mode[/b]!",
				"Finish It! 🏆",
				func():
					can_player_act = true
					update_ui()
					set_controls_enabled(true)
			)
			return

	can_player_act = true
	update_ui()
	set_controls_enabled(true)

func end_player_turn() -> void:
	if is_enemy_fainting or is_player_fainting:
		var t = get_tree().create_timer(0.4)
		t.timeout.connect(end_player_turn)
		return
		
	is_busy = false
	can_player_act = false
	is_player_turn = false
	is_waiting_for_online_opponent = false
	is_processing_opponent_action = false
	set_controls_enabled(false)
	var active_p = get_active_player()
	if active_p:
		active_p.took_damage_last_turn = false
		
	if is_battle_over or check_team_defeat():
		return
		
	if round_step == 0:
		round_step = 1
		var timer = get_tree().create_timer(1.2)
		timer.timeout.connect(execute_round_turn)
	else:
		_finish_round()

func start_enemy_turn() -> void:
	if is_battle_over or check_team_defeat():
		return
	if is_enemy_fainting or is_player_fainting:
		var t = get_tree().create_timer(0.4)
		t.timeout.connect(start_enemy_turn)
		return
		
	is_busy = false
	is_player_turn = false
	can_player_act = false
	is_waiting_for_online_opponent = false
	is_processing_opponent_action = false
	set_controls_enabled(false)
	var e = get_active_enemy()
	var p = get_active_player()
	
	if GameData.is_online_pvp:
		turn_badge.text = "ROUND %d • ⏳ WAITING FOR %s..." % [round_number, GameData.online_rival_name.to_upper()]
		turn_badge.modulate = Color(0.9, 0.7, 0.2)
	elif GameData.is_pvp_mode:
		turn_badge.text = "ROUND %d • 🔵 PLAYER 2'S TURN (%s)" % [round_number, e.name]
		turn_badge.modulate = Color(0.3, 0.8, 1.0)
	else:
		turn_badge.text = "ROUND %d • RIVAL'S TURN (%s)" % [round_number, e.name]
		turn_badge.modulate = Color(0.95, 0.3, 0.2)
	
	if _process_turn_start_status(e, p, enemy_card_img, player_card_img, false):
		return
			
	if GameData.is_online_pvp:
		is_waiting_for_online_opponent = true
		can_player_act = false
		update_ui()
		set_controls_enabled(false)
		_try_process_next_opponent_action()
	elif GameData.is_pvp_mode:
		can_player_act = true
		reset_selected_energy()
		update_ui()
		set_controls_enabled(true)
	else:
		can_player_act = false
		update_ui()
		set_controls_enabled(false)
		if GameData.is_tutorial_mode and round_number == 1 and not tutorial_steps_shown.get("step4", false):
			_show_tutorial_callout(
				"step4",
				"TUTORIAL • STEP 4 OF 5",
				"🛡️ Rival Turn & Combat Log",
				"Now it's Bulbasaur's turn to counterattack!\n\nKeep an eye on the [b]Combat Log[/b] in the center of the arena. It tracks every move, damage calculations, type effectiveness, and coin tosses in real time.",
				"Watch Rival Turn ➡️",
				func():
					var t_ai = get_tree().create_timer(1.0)
					t_ai.timeout.connect(execute_enemy_ai)
			)
			return
		var timer = get_tree().create_timer(1.6)
		timer.timeout.connect(execute_enemy_ai)

func end_enemy_turn() -> void:
	if is_enemy_fainting or is_player_fainting:
		var t = get_tree().create_timer(0.4)
		t.timeout.connect(end_enemy_turn)
		return
		
	is_busy = false
	can_player_act = false
	is_player_turn = false
	is_waiting_for_online_opponent = false
	is_processing_opponent_action = false
	set_controls_enabled(false)
	var active_e = get_active_enemy()
	if active_e:
		active_e.took_damage_last_turn = false
		
	if is_battle_over or check_team_defeat():
		return
		
	if round_step == 0:
		round_step = 1
		var timer = get_tree().create_timer(1.2)
		timer.timeout.connect(execute_round_turn)
	else:
		_finish_round()

func _finish_round() -> void:
	is_busy = false
	can_player_act = false
	is_player_turn = false
	is_waiting_for_online_opponent = false
	is_processing_opponent_action = false
	set_controls_enabled(false)
	if is_battle_over or check_team_defeat():
		return
		
	round_step = 0
	var active_p = get_active_player()
	var active_e = get_active_enemy()
	
	# Sandstorm check: 2 DMG to non-GROUND active Pokemon
	if sandstorm_turns > 0:
		sandstorm_turns -= 1
		log_action("🌪️ [color=yellow]Sandstorm rages! (%d rounds remaining)[/color]" % sandstorm_turns)
		if active_p and active_p.type != "GROUND":
			active_p.current_hp = max(0, active_p.current_hp - 2)
			spawn_floating_combat_number(player_card_img, -2, false)
			play_damage_hit(player_card_img, "GROUND", 2)
		if active_e and active_e.type != "GROUND":
			active_e.current_hp = max(0, active_e.current_hp - 2)
			spawn_floating_combat_number(enemy_card_img, -2, false)
			play_damage_hit(enemy_card_img, "GROUND", 2)
		if check_active_faint() and check_team_defeat():
			return

	# Grassy Terrain countdown
	if grassy_terrain_turns > 0:
		grassy_terrain_turns -= 1
		if grassy_terrain_turns == 0:
			log_action("🌿 [color=green]The Grassy Terrain faded away.[/color]")

	# Constrict (Sand Tomb 2 DMG, Wrap 1 DMG - capped at constricted_turns)
	for pkmn in [active_p, active_e]:
		if pkmn and pkmn.is_constricted_dmg > 0:
			var c_dmg = pkmn.is_constricted_dmg
			pkmn.current_hp = max(0, pkmn.current_hp - c_dmg)
			var node_vis = player_card_img if pkmn == active_p else enemy_card_img
			pkmn.constricted_turns -= 1
			log_action("🪢 [color=orange]%s is constricted and takes %d DMG! (%d rounds left)[/color]" % [pkmn.name, c_dmg, max(0, pkmn.constricted_turns)])
			spawn_floating_combat_number(node_vis, -c_dmg, false)
			play_damage_hit(node_vis, "NORMAL", c_dmg)
			if pkmn.constricted_turns <= 0:
				pkmn.is_constricted_dmg = 0
				pkmn.constricted_turns = 0
				log_action("✨ [b]%s[/b] [color=green]broke free from constriction![/color]" % pkmn.name)
	if check_active_faint() and check_team_defeat():
		return

	# Toxic extra round-end damage (1 DMG if poisoned & toxic envenomed)
	for pkmn in [active_p, active_e]:
		if pkmn and pkmn.is_poisoned and pkmn.toxic_envenomed:
			pkmn.current_hp = max(0, pkmn.current_hp - 1)
			var node_vis = player_card_img if pkmn == active_p else enemy_card_img
			log_action("☠️ [color=purple]%s takes 1 extra DMG from Toxic![/color]" % pkmn.name)
			var overlay = player_status_overlay if pkmn == active_p else enemy_status_overlay
			if overlay:
				overlay.trigger_poison_effect()
			spawn_floating_combat_number(node_vis, -1, false)
			play_damage_hit(node_vis, "POISON", 1)
	if check_active_faint() and check_team_defeat():
		return

	# Expirar modificadores temporales de velocidad (+2 Turtle Shell, -1 Bubble) y bufos
	for pkmn in [active_p, active_e]:
		if pkmn:
			if pkmn.speed_mod_expires_round > 0 and round_number >= pkmn.speed_mod_expires_round:
				pkmn.temp_speed_mod = 0
				pkmn.speed_mod_expires_round = 0
			if pkmn.shield_turns > 0:
				pkmn.shield_turns -= 1
				if pkmn.shield_turns == 0:
					pkmn.shield_reduction = 0
			if pkmn.ground_boost_turns > 0:
				pkmn.ground_boost_turns -= 1
			if pkmn.damage_buff_turns > 0:
				pkmn.damage_buff_turns -= 1
				if pkmn.damage_buff_turns == 0:
					pkmn.damage_buff = 0
			if pkmn.foe_damage_debuff_turns > 0:
				pkmn.foe_damage_debuff_turns -= 1
				if pkmn.foe_damage_debuff_turns == 0:
					pkmn.foe_damage_debuff = 0
			if pkmn.is_paralyzed:
				pkmn.paralyze_turns -= 1
				if pkmn.paralyze_turns <= 0:
					pkmn.is_paralyzed = false
					pkmn.paralyze_turns = 0
					log_action("✨ [b]%s[/b] [color=green]recovered from paralysis![/color]" % pkmn.name)
			if pkmn.immune_sleep_rounds > 0:
				pkmn.immune_sleep_rounds -= 1
			pkmn.is_digging = false
		
	# Actualizar historial de Flinch para la siguiente ronda
	for team in [player_team, enemy_team]:
		for pkmn in team:
			pkmn.is_flinched = false
			pkmn.was_flinched_last_round = pkmn.flinched_this_round
			pkmn.flinched_this_round = false
		
	update_ui()
	
	var timer = get_tree().create_timer(1.2)
	timer.timeout.connect(start_new_round)

func _is_status_move_redundant(move_data, target) -> bool:
	if not move_data or not target:
		return false
	if move_data.effect_type == "SLEEP":
		return (target.is_asleep_turns > 0 or target.immune_sleep_rounds > 0)
	if move_data.effect_type == "PARALYZE":
		return (target.is_paralyzed or target.paralyze_turns > 0)
	if move_data.effect_type == "BURN" or move_data.boost_applies_burn:
		return (target.burn_turns > 0)
	if move_data.effect_type == "POISON" or move_data.causes_poison:
		return target.is_poisoned
	if move_data.effect_type == "CONFUSION":
		return (target.is_confused or target.confused_turns > 0)
	if move_data.effect_type == "FREEZE":
		return (target.is_frozen or target.frozen_turns > 0)
	if move_data.effect_type == "CONSTRICT":
		return (target.constricted_turns > 0)
	if move_data.effect_type == "SEEDED":
		return (target.is_seeded_turns > 0)
	if move_data.effect_type == "ENVENOM":
		return (target.toxic_envenomed or not target.is_poisoned)
	return false

func execute_enemy_ai() -> void:
	if is_battle_over or check_team_defeat():
		return
		
	var e = get_active_enemy()
	var p = get_active_player()
	
	# Si tiene pasiva Turtle Shell y recibió daño, contraataca
	if e.has_passive and e.passive_name == "Turtle Shell" and e.took_damage_last_turn and e.current_energy >= 1:
		e.current_energy -= 1
		e.temp_speed_mod = 2
		e.speed_mod_expires_round = round_number + 1
		var dmg = 3
		if GameData.is_attack_resisted(p.type, p.resistant, "NORMAL"):
			dmg = max(1, dmg - RESISTANCE_REDUCTION)
		p.current_hp = max(0, p.current_hp - dmg)
		log_action("Rival [b]%s[/b] triggered passive [color=cyan]Turtle Shell[/color] dealing [b]%d[/b] damage and gaining [b]+2 Speed[/b] for next round!" % [e.name, dmg])
		lunge_card(enemy_card_img, false)
		play_damage_hit(player_card_img, "NORMAL", dmg)
		spawn_floating_combat_number(player_card_img, -dmg, false)
		update_ui()
		check_active_faint()
		var next_timer = get_tree().create_timer(2.4)
		next_timer.timeout.connect(func():
			if is_battle_over:
				return
			end_enemy_turn()
		)
		return
	
	if e.current_energy <= 0:
		enemy_do_recover()
		return
		
	var move1 = e.moves[0]
	var move2 = e.moves[1]
	
	# Detectar si alguno de los movimientos es puramente de estado (0 DMG) y redundante contra el rival
	var m2_redundant = (move2.base_damage == 0 and _is_status_move_redundant(move2, p))
	var m1_redundant = (move1.base_damage == 0 and _is_status_move_redundant(move1, p))
	
	# 1. Pichu Thunder Shock
	if move2.is_pichu_shock and e.current_energy >= move2.cost:
		perform_attack(e, p, move2, false, move2.cost, enemy_card_img, player_card_img)
	# 2. Bite con Flinch potenciado (Rattata)
	elif move2.effect_type == "FLINCH" and e.current_energy >= (move2.cost + move2.boost_cost) and not p.was_flinched_last_round and not p.is_flinched:
		perform_attack(e, p, move2, true, move2.cost + move2.boost_cost, enemy_card_img, player_card_img)
	# 3. Ember con Burn potenciado (Charmander)
	elif move2.boost_applies_burn and e.current_energy >= (move2.cost + move2.boost_cost) and p.burn_turns == 0:
		perform_attack(e, p, move2, true, move2.cost + move2.boost_cost, enemy_card_img, player_card_img)
	# 4. Poison Sting con veneno si es más veloz (Weedle)
	elif move2.causes_poison and not p.is_poisoned and get_pokemon_effective_speed(e, p) > get_pokemon_effective_speed(p, e) and e.current_energy >= move2.cost:
		perform_attack(e, p, move2, false, move2.cost, enemy_card_img, player_card_img)
	# 5. Ataque múltiple Fury Attack (Spearow)
	elif move2.effect_type == "MULTI_ATTACK" and e.current_energy >= 1:
		var spent = min(e.current_energy, move2.cost)
		perform_attack(e, p, move2, false, spent, enemy_card_img, player_card_img)
	# 6. Bono de daño por tipo (Gust / Peck)
	elif move2.effect_type == "BOOST_DMG_TYPE" and e.current_energy >= move2.cost:
		var bonus = false
		if move2.name == "Gust" and (p.type == "GRASS" or p.type == "FIGHTING"):
			bonus = true
		elif move2.name == "Peck" and (p.type == "GRASS" or p.type == "NORMAL"):
			bonus = true
		if bonus or randf() < 0.7:
			perform_attack(e, p, move2, false, move2.cost, enemy_card_img, player_card_img)
		elif e.current_energy >= move1.min_energy_req and not m1_redundant:
			perform_attack(e, p, move1, false, move1.cost, enemy_card_img, player_card_img)
		else:
			enemy_do_recover()
			return
	# 7. Comportamiento general
	elif not m2_redundant and e.current_energy >= move2.cost:
		var rng = randf()
		if (rng < 0.65 or m1_redundant):
			perform_attack(e, p, move2, false, move2.cost, enemy_card_img, player_card_img)
		elif rng < 0.85 and e.current_energy >= move1.min_energy_req and not m1_redundant:
			perform_attack(e, p, move1, false, move1.cost, enemy_card_img, player_card_img)
		elif m1_redundant:
			perform_attack(e, p, move2, false, move2.cost, enemy_card_img, player_card_img)
		else:
			enemy_do_recover()
			return
	elif not m2_redundant and e.current_energy >= move2.min_energy_req and move2.cost > 1 and (randf() < 0.4 or m1_redundant):
		var spent = min(e.current_energy, move2.cost)
		perform_attack(e, p, move2, false, spent, enemy_card_img, player_card_img)
	elif not m1_redundant and e.current_energy >= move1.min_energy_req:
		perform_attack(e, p, move1, false, move1.cost, enemy_card_img, player_card_img)
	elif not m2_redundant and e.current_energy >= move2.min_energy_req:
		var spent = min(e.current_energy, move2.cost)
		perform_attack(e, p, move2, false, spent, enemy_card_img, player_card_img)
	else:
		enemy_do_recover()
		return
		
	var next_timer = get_tree().create_timer(2.4)
	next_timer.timeout.connect(func():
		if is_battle_over:
			return
		end_enemy_turn()
	)

func enemy_do_recover() -> void:
	var e = get_active_enemy()
	var rec = min(e.recover_amount, e.max_energy - e.current_energy)
	e.current_energy += rec
	log_action("[b]%s[/b] used [color=cyan]Recharge[/color] and restored [b]+%d[/b] Energy (⚡ %d/%d)." % [e.name, rec, e.current_energy, e.max_energy])
	update_ui()
	
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		end_enemy_turn()
	)

# --- EJECUCIÓN DE ATAQUES Y HABILIDADES ---
func perform_attack(attacker, defender, move, boosted: bool, energy_to_spend: int, attacker_visual: Node, defender_visual: Node) -> void:
	attacker.current_energy -= energy_to_spend
	if attacker == get_active_player() and GameData.is_campaign_mode:
		GameData.add_daily_mission_progress("play_moves", 1)
	
	var is_full_energy: bool = (energy_to_spend >= move.cost or move.cost == 0)
	var raw_damage: int = 0
	var note_text: String = ""
	var effect_annulled: bool = false
	var att_spd = get_pokemon_effective_speed(attacker, defender)
	var def_spd = get_pokemon_effective_speed(defender, attacker)

	# 1. Chequeo de Amnesia del rival
	if defender.amnesia_active:
		defender.amnesia_active = false
		effect_annulled = true
		note_text += " [color=pink](Amnesia annulled move effect!)[/color]"

	# 2. Chansey Pasiva: Pacifist (no puede atacar)
	if attacker.has_passive and attacker.passive_name == "Pacifist":
		log_action("[b]%s[/b] is a [color=pink]Pacifist[/color] and cannot attack!" % attacker.name)
		update_ui()
		return

	# 3. Evasión / Mirage / Reflect
	if defender.is_evasive:
		defender.is_evasive = false
		var ref = defender.evasive_reflects_dmg
		defender.evasive_reflects_dmg = 0
		if ref > 0:
			attacker.current_hp = max(0, attacker.current_hp - ref)
			note_text += " [color=cyan]Reflect evaded attack and dealt %d counter DMG![/color]" % ref
			spawn_floating_combat_number(attacker_visual, -ref, false)
			play_damage_hit(attacker_visual, "NORMAL", ref)
		else:
			note_text += " [color=cyan]The attack was completely evaded![/color]"
		log_action("[b]%s[/b] used [color=cyan]%s[/color], but %s%s" % [attacker.name, move.name, defender.name, note_text])
		shake_node(defender_visual)
		update_ui()
		check_active_faint()
		return

	# 4. Dig (subterráneo: inmune a ataques no tipo GROUND)
	if defender.is_digging and move.type != "GROUND":
		log_action("[b]%s[/b] used [color=cyan]%s[/color], but [b]%s[/b] is underground via Dig and avoided the hit!" % [attacker.name, move.name, defender.name])
		shake_node(defender_visual)
		update_ui()
		return

	# 5. Spite (bloqueo de movimiento)
	if defender.lock_foe_move != "" and move.name == defender.lock_foe_move:
		log_action("[color=purple]Spite prevents %s from using %s again this round![/color]" % [attacker.name, move.name])
		update_ui()
		return

	# 6. Movimientos con probabilidad de fallo (MISS e.g. Guillotine)
	if move.effect_type == "MISS" and randf() < 0.33:
		attacker.current_energy = min(attacker.max_energy, attacker.current_energy + 1)
		log_action("[b]%s[/b] used [color=cyan]%s[/color], but it [color=red]missed completely![/color] (Refunded 1 Energy⚡)" % [attacker.name, move.name])
		shake_node(defender_visual)
		update_ui()
		return

	# 7. Cálculo del daño base
	if move.effect_type == "MULTI_ATTACK":
		var num_hits = max(1, energy_to_spend)
		var hit_dmgs: Array[String] = []
		var total_multi_dmg: int = 0
		var crits_landed = 0
		for i in range(num_hits):
			var base_roll: int = 0
			if move.name in ["Bone Rush", "Fury Swipes"]:
				base_roll = 4 if randf() < 0.5 else 3
			elif move.name == "Icicle Spear":
				base_roll = 5 if randf() < 0.5 else 4
			else: # Bullet Seed, Fury Attack
				base_roll = 3 if randf() < 0.5 else 2
				
			var is_crit = (randf() < 0.25)
			if is_crit:
				var crit_bonus = 3 if move.name in ["Bone Rush", "Icicle Spear"] else 2
				base_roll += crit_bonus
				crits_landed += 1
				hit_dmgs.append("%d💥" % base_roll)
			else:
				hit_dmgs.append(str(base_roll))
			total_multi_dmg += base_roll
			
		raw_damage = total_multi_dmg
		var rolls_text = "+".join(hit_dmgs)
		var crit_tag = " [color=orange](%d Critical Hit%s!)[/color]" % [crits_landed, "s" if crits_landed > 1 else ""] if crits_landed > 0 else ""
		note_text += " [color=yellow](%d hits: %s = %d DMG)%s[/color]" % [num_hits, rolls_text, raw_damage, crit_tag]
	elif move.effect_type == "ANTI_TANK":
		raw_damage = max(1, int(round(defender.current_hp * 0.5)))
		note_text += " [color=yellow](Anti-Tank: 50%% foe's HP = %d DMG)[/color]" % raw_damage
	else:
		raw_damage = calculate_move_damage(move, energy_to_spend)
		if boosted:
			raw_damage += move.boost_damage
		elif not is_full_energy and move.cost > 1:
			note_text += " [color=yellow](Partial Energy %d/%d⚡: scaled damage)[/color]" % [energy_to_spend, move.cost]
		
		# Close Combat (MINIMIZE): penalización por energía faltante
		if move.effect_type == "MINIMIZE" and energy_to_spend < move.cost:
			var missing = move.cost - energy_to_spend
			raw_damage = max(1, raw_damage - (missing * 6))
			note_text += " [color=yellow](Close Combat: -%d DMG for partial energy)[/color]" % (missing * 6)
			
		# Aurora Beam (BOOST_DMG): daño extra si boosted
		if move.effect_type == "BOOST_DMG" and boosted:
			raw_damage += 4

	# 8. Modificadores de daño del atacante
	# Focus Energy (Rattata)
	if attacker.has_passive and attacker.passive_name == "Focus Energy" and att_spd > def_spd:
		raw_damage += 1
		note_text += " [color=cyan]Focus Energy (+1 DMG for higher SPD)![/color]"
		
	# Flash Cannon bono cargado
	if attacker.shield_breaker_bonus > 0 and move.effect_type != "SHIELD_BREAKER":
		raw_damage += attacker.shield_breaker_bonus
		note_text += " [color=yellow]Flash Cannon (+%d DMG)![/color]" % attacker.shield_breaker_bonus
		attacker.shield_breaker_bonus = 0

	# Bufos de daño acumulados (Growth, Calm Mind, Belly Drum)
	if attacker.damage_buff != 0:
		raw_damage = max(1, raw_damage + attacker.damage_buff)
		note_text += " [color=cyan]Stat Buff (%+d DMG)![/color]" % attacker.damage_buff

	# Terreno y efectos de campo
	if grassy_terrain_turns > 0 and move.type == "GRASS":
		raw_damage += 4
		note_text += " [color=green]Grassy Terrain (+4 DMG)![/color]"
	if attacker.ground_boost_turns > 0 and move.type == "GROUND":
		raw_damage += 4
		note_text += " [color=orange]Rock Polish (+4 Ground DMG)![/color]"

	# Snowball / Rolling (uso consecutivo del mismo movimiento)
	if attacker.last_move_used == move.name:
		if move.effect_type == "ROLLING":
			raw_damage *= 2
			note_text += " [color=cyan]Rolling Momentum (x2 DMG)![/color]"
		elif move.effect_type == "SNOWBALL":
			raw_damage += 4
			note_text += " [color=cyan]Snowball Boost (+4 DMG)![/color]"

	# Revenge y Rage (daño recibido el turno anterior)
	if move.effect_type == "REVENGE" and attacker.took_damage_last_turn:
		raw_damage += 3
		note_text += " [color=orange]Revenge (+3 DMG)![/color]"
	elif move.effect_type == "RAGE" and attacker.took_damage_last_turn:
		raw_damage += 4
		attacker.temp_speed_mod += 1
		note_text += " [color=orange]Outrage (+4 DMG & +1 Speed)![/color]"

	# Aerial Ace y similares (BOOST_IF_FASTER)
	if move.effect_type == "BOOST_IF_FASTER" and is_full_energy and att_spd > def_spd:
		raw_damage += 3
		note_text += " [color=cyan]Speed Advantage (+3 DMG)![/color]"

	# Sinergias con estados negativos del rival
	if move.effect_type == "BLAZE" and defender.burn_turns > 0:
		raw_damage += 3
		note_text += " [color=orange]Blaze vs Burn (+3 DMG)![/color]"
	if move.effect_type == "BOOST_IF_PARALYZED" and defender.is_paralyzed:
		raw_damage += 4
		note_text += " [color=yellow]Bonus vs Paralyzed (+4 DMG)![/color]"
	if move.effect_type == "OVERCHARGE" and defender.is_paralyzed:
		raw_damage += 6
		defender.is_paralyzed = false
		defender.paralyze_turns = 0
		note_text += " [color=yellow]Overcharge (+6 DMG & cured Paralyze)![/color]"
	if defender.is_poisoned:
		if move.effect_type in ["DOUBLE_DMG", "SHOCK"]:
			raw_damage *= 2
			note_text += " [color=purple]Poison Synergy (x2 DMG)![/color]"
		elif move.effect_type == "DROWN":
			raw_damage += 4
			note_text += " [color=purple]Drown vs Poison (+4 DMG)![/color]"
	if move.effect_type == "BOOST_CONFUSED" and defender.is_confused:
		raw_damage += 3
		note_text += " [color=magenta]Bonus vs Confused (+3 DMG)![/color]"
	if defender.is_asleep_turns > 0 and move.name == "Dream Eater":
		raw_damage += 5
		note_text += " [color=purple]Dream Eater vs Asleep (+5 DMG)![/color]"

	# Bono de daño por tipo objetivo (BOOST_DMG_TYPE)
	if move.effect_type == "BOOST_DMG_TYPE" and is_full_energy:
		var desc_u = move.description.to_upper()
		if "FIGHTING" in desc_u and defender.type == "FIGHTING":
			var b = 3 if "+3" in desc_u else 2
			raw_damage += b
			note_text += " [color=orange]Bonus vs Fighting (+%d DMG)![/color]" % b
		elif "GRASS" in desc_u and defender.type == "GRASS":
			raw_damage += 2
			note_text += " [color=orange]Bonus vs Grass (+2 DMG)![/color]"
		elif "NORMAL" in desc_u and defender.type == "NORMAL":
			raw_damage += 2
			note_text += " [color=orange]Bonus vs Normal (+2 DMG)![/color]"

	# Golpe Crítico (CRITICAL)
	if move.effect_type == "CRITICAL" and randf() < 0.25:
		raw_damage += 3
		note_text += " [color=yellow]Critical Hit! (+3 DMG)[/color]"

	# Tirada de dado de Pichu Shock
	if move.is_pichu_shock:
		if is_full_energy:
			var dice_roll = randi_range(1, 6)
			note_text += " [color=yellow](🎲 Die: %d)[/color]" % dice_roll
			if dice_roll <= 3:
				attacker.current_hp = max(0, attacker.current_hp - 2)
				attacker.current_energy = min(attacker.max_energy, attacker.current_energy + 1)
				note_text += " [color=red]Pichu recoils 2 HP and recharges 1⚡![/color]"
				play_damage_hit(attacker_visual, "ELECTRIC", 2)
				spawn_floating_combat_number(attacker_visual, -2, false)
		else:
			note_text += " [color=gray](Partial Energy: no recoil/recharge)[/color]"

	# 9. Debilidades y Resistencias
	var final_damage: int = 0
	if raw_damage > 0:
		final_damage = raw_damage
		
		# Movimientos Adaptativos / Punto Débil (WEAK_SPOT / ADAPT)
		if move.effect_type in ["WEAK_SPOT", "ADAPT"]:
			final_damage += WEAKNESS_BONUS
			note_text += " [color=yellow]Adapted to weakness! (+%d DMG)[/color]" % WEAKNESS_BONUS
		# Movimientos de doble o triple tipo
		elif move.effect_type in ["DOUBLE_TYPE", "TRIPLE_TYPE"]:
			var combo_types = ["WATER", "FIRE", "ELECTRIC"] if move.effect_type == "TRIPLE_TYPE" else (["FIGHTING", "PSYCHIC"] if move.name == "Aura Sphere" else ["ICE", "FIGHTING"])
			var hit_weak = false
			var all_res = true
			for ct in combo_types:
				if GameData.types_match(defender.weakness, ct):
					hit_weak = true
				if not GameData.is_attack_resisted(defender.type, defender.resistant, ct):
					all_res = false
			if hit_weak:
				final_damage += WEAKNESS_BONUS
				note_text += " [color=yellow]Super effective elemental combo! (+%d DMG)[/color]" % WEAKNESS_BONUS
			elif all_res:
				final_damage = max(MIN_DAMAGE_AFTER_RESIST, final_damage - RESISTANCE_REDUCTION)
				note_text += " [color=gray]Resisted elemental combo (-%d DMG)[/color]" % RESISTANCE_REDUCTION
		# Tipo estándar
		elif GameData.types_match(defender.weakness, move.type):
			final_damage += WEAKNESS_BONUS
			note_text += " [color=yellow]It's super effective! (+%d DMG)[/color]" % WEAKNESS_BONUS
			if defender.has_passive and defender.passive_name == "Protect":
				defender.weakness = "NONE"
				note_text += " [color=cyan]%s's Protect removes its weakness for the rest of battle![/color]" % defender.name
		elif GameData.is_attack_resisted(defender.type, defender.resistant, move.type):
			final_damage = max(MIN_DAMAGE_AFTER_RESIST, final_damage - RESISTANCE_REDUCTION)
			var is_same_type_resist = (GameData.normalize_type_key(move.type) == GameData.normalize_type_key(defender.type)) and not GameData.types_match(defender.resistant, move.type)
			if is_same_type_resist:
				note_text += " [color=gray]It's not very effective... Same-type resistance (-%d DMG)[/color]" % RESISTANCE_REDUCTION
			else:
				note_text += " [color=gray]It's not very effective... (-%d DMG)[/color]" % RESISTANCE_REDUCTION

		# 10. Reducciones y Pasivas defensivas
		# Charm (Pichu)
		if defender.has_passive and defender.passive_name == "Charm" and move.type == "NORMAL":
			final_damage = max(1, final_damage - 1)
			note_text += " [color=pink]Charm reduces 1 Normal DMG![/color]"
			
		# Envenenamiento del atacante
		if attacker.is_poisoned:
			final_damage = max(1, final_damage - 1)
			note_text += " [color=purple](Poison: -1 DMG)[/color]"
			
		# Debilitamiento por Smokescreen/Sand Attack
		if attacker.foe_damage_debuff > 0:
			final_damage = max(1, final_damage - attacker.foe_damage_debuff)
			note_text += " [color=gray](Debuff: -%d DMG)[/color]" % attacker.foe_damage_debuff
			
		# Escudo / Velo / Bloqueo
		if defender.shield_reduction > 0:
			final_damage = max(0, final_damage - defender.shield_reduction)
			note_text += " [color=blue](Shield absorbed %d DMG)[/color]" % defender.shield_reduction
			
		# Slimy (Ditto)
		if defender.has_passive and defender.passive_name == "Slimy":
			final_damage = max(1, int(ceil(final_damage * 0.5)))
			note_text += " [color=pink]Slimy takes 50% DMG![/color]"
			
		# Light Screen (Wall)
		if defender.wall_hp > 0:
			if final_damage <= defender.wall_hp:
				defender.wall_hp -= final_damage
				note_text += " [color=cyan]Light Screen absorbed %d DMG (%d HP left)![/color]" % [final_damage, defender.wall_hp]
				final_damage = 0
			else:
				final_damage -= defender.wall_hp
				defender.wall_hp = 0
				attacker.current_hp = max(0, attacker.current_hp - 4)
				note_text += " [color=cyan]Light Screen shattered and dealt 4 counter DMG![/color]"
				spawn_floating_combat_number(attacker_visual, -4, false)
				play_damage_hit(attacker_visual, "PSYCHIC", 4)

	# 11. Aplicar daño y secuelas
	defender.current_hp = max(0, defender.current_hp - final_damage)
	defender.took_damage_last_turn = (final_damage > 0)
	
	# Descongelación por daño de Fuego
	if defender.is_frozen and (move.type == "FIRE" or move.effect_type == "BURN" or (boosted and move.boost_applies_burn)):
		defender.is_frozen = false
		defender.frozen_turns = 0
		note_text += " [color=orange]Fire thawed %s out of freeze![/color]" % defender.name
	
	# Conversion (Porygon)
	if defender.has_passive and defender.passive_name == "Conversion" and final_damage > 0:
		defender.type = move.type
		defender.weakness = GameData.get_default_weakness_for_type(defender.type)
		defender.resistant = GameData.get_default_resistance_for_type(defender.type)
		note_text += " [color=cyan]Conversion: %s adapted type to %s![/color]" % [defender.name, defender.type]

	# Drenaje de Vida (LIFE_DRAIN)
	if move.effect_type == "LIFE_DRAIN" and is_full_energy and final_damage > 0:
		var drain_ratio = 1.0 if (boosted or defender.is_asleep_turns > 0) else 0.5
		var heal_amount = max(1, int(round(final_damage * drain_ratio)))
		attacker.current_hp = min(attacker.max_hp, attacker.current_hp + heal_amount)
		note_text += " [color=green]Drained health and recovered +%d HP![/color]" % heal_amount
		spawn_floating_combat_number(attacker_visual, heal_amount, true)
		GameData.play_combat_sfx("heal")
		if attacker == get_active_player() and GameData.is_campaign_mode:
			GameData.add_daily_mission_progress("heal_hp", 1)

	# Recoil (Double-Edge, Take Down)
	if move.effect_type == "RECOIL" and not boosted and final_damage > 0:
		var rec_dmg = max(1, int(round(final_damage * 0.25)))
		attacker.current_hp = max(0, attacker.current_hp - rec_dmg)
		note_text += " [color=red]Recoil: takes %d DMG![/color]" % rec_dmg
		spawn_floating_combat_number(attacker_visual, -rec_dmg, false)

	# Doble Golpe (DOUBLE_HIT / EXTRA_HIT)
	if move.effect_type in ["DOUBLE_HIT", "EXTRA_HIT"] and is_full_energy and not effect_annulled and final_damage > 0:
		var hit_chance = 0.35 if move.effect_type == "EXTRA_HIT" else 0.50
		if randf() < hit_chance:
			defender.current_hp = max(0, defender.current_hp - final_damage)
			note_text += " [color=yellow]Double Hit struck a 2nd time for %d DMG![/color]" % final_damage
			spawn_floating_combat_number(defender_visual, -final_damage, false)

	# Pay Day (EARNINGS)
	if move.effect_type == "EARNINGS" and GameData.is_campaign_mode and not attacker.payday_used:
		attacker.payday_used = true
		GameData.add_active_campaign_gold(3)
		note_text += " [color=gold]Pay Day earned +3 G![/color]"

	# Flash Cannon (SHIELD_BREAKER)
	if move.effect_type == "SHIELD_BREAKER" and final_damage > 0 and is_full_energy:
		attacker.shield_breaker_bonus = 4
		note_text += " [color=yellow]Flash Cannon charged +4 DMG for next attack![/color]"

	# 12. Aplicación de Estados y Efectos Secundarios (si no fue anulado por Amnesia y con energía completa)
	if not effect_annulled and is_full_energy:
		# Quemadura
		if (boosted and move.name == "Inferno") or (boosted and (move.boost_applies_burn or move.effect_type == "BURN")) or (move.effect_type == "BURN"):
			if defender.burn_turns > 0:
				note_text += " [color=gray](%s is already burned - move had no effect!)[/color]" % defender.name
				spawn_floating_combat_text(defender_visual, "Already Burned!", Color("#f97316"))
			else:
				defender.burn_turns = 2
				defender.burn_dmg = 3 if ("3 DMG" in move.description or move.name == "Inferno") else (2 if ("2 DMG" in move.description or move.name in ["Burn Up", "Fire Fang", "Fire Blast"]) else 1)
				note_text += " [color=orange]Inflicted BURN (%d DMG x 2 turns)![/color]" % defender.burn_dmg
				var def_overlay = player_status_overlay if defender == get_active_player() else enemy_status_overlay
				if def_overlay:
					def_overlay.trigger_burn_effect()
			
		# Envenenamiento
		if move.effect_type == "POISON":
			if defender.is_poisoned:
				note_text += " [color=gray](%s is already poisoned - move had no effect!)[/color]" % defender.name
				spawn_floating_combat_text(defender_visual, "Already Poisoned!", Color("#a855f7"))
			else:
				defender.is_poisoned = true
				note_text += " [color=purple]Inflicted POISON (-1 permanent DMG)![/color]"
				var def_overlay = player_status_overlay if defender == get_active_player() else enemy_status_overlay
				if def_overlay:
					def_overlay.trigger_poison_effect()
		elif move.causes_poison or move.effect_type == "POISON_IF_FASTER":
			if att_spd > def_spd:
				if defender.is_poisoned:
					note_text += " [color=gray](%s is already poisoned - move had no effect!)[/color]" % defender.name
					spawn_floating_combat_text(defender_visual, "Already Poisoned!", Color("#a855f7"))
				else:
					defender.is_poisoned = true
					note_text += " [color=purple]Inflicted POISON (-1 permanent DMG)![/color]"
					var def_overlay = player_status_overlay if defender == get_active_player() else enemy_status_overlay
					if def_overlay:
						def_overlay.trigger_poison_effect()
			else:
				note_text += " [color=gray](No poison: foe is not slower, SPD %d vs %d)[/color]" % [def_spd, att_spd]
				
		# Toxic (ENVENOM)
		if move.effect_type == "ENVENOM":
			if defender.toxic_envenomed:
				note_text += " [color=gray](%s is already envenomed with Toxic - move had no effect!)[/color]" % defender.name
				spawn_floating_combat_text(defender_visual, "Already Envenomed!", Color("#9333ea"))
			elif defender.is_poisoned:
				defender.toxic_envenomed = true
				note_text += " [color=purple]Envenomed with Toxic (1 extra DMG at round end)![/color]"
			else:
				note_text += " [color=gray](Toxic requires foe to be poisoned first)[/color]"
				
		# Congelación (FREEZE)
		if move.effect_type == "FREEZE":
			if defender.is_frozen or defender.frozen_turns > 0:
				note_text += " [color=gray](%s is already frozen - move had no effect!)[/color]" % defender.name
				spawn_floating_combat_text(defender_visual, "Already Frozen!", Color("#38bdf8"))
			else:
				defender.is_frozen = true
				defender.frozen_turns = 0
				note_text += " [color=cyan]Inflicted FREEZE (foe cannot move, max 2 rounds or thaw on Fire)![/color]"
			
		# Sueño (SLEEP)
		if move.effect_type == "SLEEP":
			if defender.immune_sleep_rounds > 0:
				note_text += " [color=gray](Immune to Sleep: recently woke up - move had no effect!)[/color]"
				spawn_floating_combat_text(defender_visual, "Sleep Immune!", Color("#94a3b8"))
			elif defender.is_asleep_turns > 0:
				note_text += " [color=gray](%s is already asleep - move had no effect!)[/color]" % defender.name
				spawn_floating_combat_text(defender_visual, "Already Asleep!", Color("#818cf8"))
			else:
				defender.is_asleep_turns = 2
				note_text += " [color=lightblue]Put foe to SLEEP (2 rounds)![/color]"
			
		# Parálisis (PARALYZE)
		if move.effect_type == "PARALYZE":
			if defender.is_paralyzed or defender.paralyze_turns > 0:
				note_text += " [color=gray](%s is already paralyzed - move had no effect!)[/color]" % defender.name
				spawn_floating_combat_text(defender_visual, "Already Paralyzed!", Color("#facc15"))
			else:
				defender.is_paralyzed = true
				defender.paralyze_turns = 2
				note_text += " [color=yellow]Inflicted PARALYZE (25% chance cannot act, 2 rounds)![/color]"
			
		# Confusión (CONFUSION)
		if move.effect_type == "CONFUSION":
			if defender.is_confused or defender.confused_turns > 0:
				note_text += " [color=gray](%s is already confused - move had no effect!)[/color]" % defender.name
				spawn_floating_combat_text(defender_visual, "Already Confused!", Color("#e879f9"))
			else:
				defender.is_confused = true
				defender.confused_turns = 0
				note_text += " [color=magenta]Inflicted CONFUSION (35% snap out, max 3 rounds, 2 self-DMG)![/color]"
			
		# Constricción (CONSTRICT e.g. Sand Tomb / Wrap)
		if move.effect_type == "CONSTRICT":
			if defender.constricted_turns > 0:
				note_text += " [color=gray](%s is already trapped - move had no effect!)[/color]" % defender.name
				spawn_floating_combat_text(defender_visual, "Already Trapped!", Color("#fb923c"))
			else:
				defender.is_constricted_dmg = 2 if move.name == "Sand Tomb" else 1
				defender.constricted_turns = 2
				note_text += " [color=orange]Trapped foe! Cannot switch and takes %d DMG/round for 2 rounds.[/color]" % defender.is_constricted_dmg
			
		# Drenadoras (SEEDED e.g. Leech Seed)
		if move.effect_type == "SEEDED":
			if defender.is_seeded_turns > 0:
				note_text += " [color=gray](%s is already seeded - move had no effect!)[/color]" % defender.name
				spawn_floating_combat_text(defender_visual, "Already Seeded!", Color("#4ade80"))
			else:
				defender.is_seeded_turns = 3
				note_text += " [color=green]Planted Leech Seed on foe (saps 2 HP x 3 rounds)![/color]"
			
		# Flinch
		var flinch_rate = 1.0 if boosted else (0.30 if "30%" in move.description else (0.20 if "20%" in move.description else (0.15 if "15%" in move.description else 0.0)))
		if flinch_rate > 0 and randf() < flinch_rate:
			if not defender.was_flinched_last_round:
				defender.is_flinched = true
				defender.flinched_this_round = true
				note_text += " [color=yellow]Inflicted FLINCH (loses turn this round)![/color]"
			else:
				note_text += " [color=gray](Immune to Flinch: already flinched last round)[/color]"

		# Reducción de Velocidad al rival (SLOW_FOE / BLIND)
		if move.reduces_foe_speed or move.effect_type in ["SLOW_FOE", "BLIND"]:
			defender.temp_speed_mod = -1
			defender.speed_mod_expires_round = round_number + 1
			note_text += " [color=lightblue]Reduced foe's Speed by 1 next round![/color]"

		# Debilitamiento al rival (WEAKEN)
		if move.effect_type == "WEAKEN":
			defender.foe_damage_debuff = 2
			defender.foe_damage_debuff_turns = 2
			note_text += " [color=purple]Weakened foe: -2 DMG on next 2 rounds![/color]"

		# Descanso forzado tras hiperataque (REST e.g. Hyper Beam / Giga Impact / Mind Bending)
		if move.effect_type == "REST":
			attacker.rest_next_turn = true
			note_text += " [color=cyan]%s must rest next round to recharge![/color]" % attacker.name

		# Excavación (DIG)
		if move.effect_type == "DIG":
			attacker.is_digging = true
			note_text += " [color=orange]%s dug underground! Cannot be attacked by non-ground moves.[/color]" % attacker.name

		# Pantalla de Luz (WALL / Light Screen)
		if move.effect_type == "WALL":
			attacker.wall_hp = 4
			note_text += " [color=cyan]Light Screen Wall active (absorbs 4 DMG & counters)![/color]"

		# Evasión / Reflejo (EVASIVE / MIRAGE e.g. Reflect / Teleport / Primal Coat)
		if move.effect_type in ["EVASIVE", "MIRAGE"]:
			attacker.is_evasive = true
			attacker.evasive_reflects_dmg = 3 if move.effect_type == "EVASIVE" else 0
			note_text += " [color=cyan]Active Evasion: next move against %s will fail![/color]" % attacker.name

		# Escudo defensivo (SHIELD / BLOCK / VEIL)
		if move.effect_type in ["SHIELD", "BLOCK", "VEIL"]:
			attacker.shield_reduction = 2 if "-2 DMG" in move.description else 1
			attacker.shield_turns = 3 if "3 rounds" in move.description else 2
			note_text += " [color=blue]Activated Shield: -%d DMG for %d rounds![/color]" % [attacker.shield_reduction, attacker.shield_turns]

		# Aumento de ataque propio (DMG_BOOST / RELAXED / GROWING e.g. Belly Drum / Calm Mind / Growth)
		if move.effect_type in ["DMG_BOOST", "RELAXED", "GROWING"]:
			attacker.damage_buff = 8 if "+8 DMG" in move.description else (5 if "+5" in move.description else 2)
			attacker.damage_buff_turns = 2 if "2 Moves" in move.description else 1
			note_text += " [color=yellow]Boosted attack power: +%d DMG! [/color]" % attacker.damage_buff

		# Aumento de velocidad propio (RUSH / SPEED_UP e.g. Agility / Bullet Punch)
		if move.effect_type in ["RUSH", "SPEED_UP"]:
			attacker.temp_speed_mod += 2
			attacker.speed_mod_expires_round = round_number + 2
			note_text += " [color=cyan]+2 Speed for next rounds![/color]"

		# Ralentización propia (SLOW_USER e.g. Hammer Arm)
		if move.effect_type == "SLOW_USER":
			attacker.temp_speed_mod -= 2
			attacker.speed_mod_expires_round = round_number + 1
			note_text += " [color=red]-2 Speed next round![/color]"

		# Campo de Hierba (TERRAIN_SET)
		if move.effect_type == "TERRAIN_SET":
			grassy_terrain_turns = 2
			note_text += " [color=green]Grassy Terrain active (+4 GRASS DMG x 2 rounds)![/color]"

		# Tormenta de Arena (SANDSTORM)
		if move.effect_type == "SANDSTORM":
			sandstorm_turns = 3
			note_text += " [color=yellow]Sandstorm active (2 DMG/round to non-ground x 3 rounds)![/color]"

		# Pulimento de Roca (BOOST_GROUND_TYPE)
		if move.effect_type == "BOOST_GROUND_TYPE":
			attacker.ground_boost_turns = 2
			note_text += " [color=orange]+4 DMG to GROUND moves for 2 rounds![/color]"

		# Rencor (LOCK e.g. Spite)
		if move.effect_type == "LOCK":
			attacker.lock_foe_move = defender.last_move_used
			note_text += " [color=purple]Spite locked foe from using %s again![/color]" % attacker.lock_foe_move

		# Amnesia (MEMORY_FADE)
		if move.effect_type == "MEMORY_FADE":
			attacker.amnesia_active = true
			note_text += " [color=pink]Amnesia active: will annul next foe's move effect![/color]"

		# Curación de estados alterados (SUPPORT_BOOST / COVER e.g. Rapid Spin / Mist)
		if move.effect_type in ["SUPPORT_BOOST", "COVER"]:
			attacker.burn_turns = 0
			attacker.is_poisoned = false
			attacker.toxic_envenomed = false
			attacker.is_flinched = false
			attacker.is_paralyzed = false
			attacker.paralyze_turns = 0
			attacker.is_asleep_turns = 0
			attacker.is_frozen = false
			attacker.frozen_turns = 0
			attacker.is_confused = false
			attacker.confused_turns = 0
			attacker.is_seeded_turns = 0
			attacker.is_constricted_dmg = 0
			attacker.constricted_turns = 0
			attacker.foe_damage_debuff = 0
			attacker.foe_damage_debuff_turns = 0
			if move.effect_type == "COVER":
				attacker.damage_buff = 2
				attacker.damage_buff_turns = 1
			note_text += " [color=green]Rapid Spin/Mist cleansed all negative status conditions![/color]"

		# Reciclaje (RECYCLE)
		if move.effect_type == "RECYCLE" and GameData.is_campaign_mode:
			GameData.add_campaign_item("potion", 1)
			note_text += " [color=green]Recycled and recovered 1 Potion in bag![/color]"

		# Transformación (METAMORPHOSIS e.g. Transform)
		if move.effect_type == "METAMORPHOSIS":
			attacker.type = defender.type
			attacker.weakness = defender.weakness
			attacker.resistant = defender.resistant
			attacker.moves = defender.moves.duplicate(true)
			attacker.damage_buff = -2
			attacker.damage_buff_turns = 99
			note_text += " [color=pink]Transformed into %s (-2 DMG penalty)![/color]" % defender.name

	# Registrar último movimiento usado
	attacker.last_move_used = move.name
	
	# Otorgar EXP al Pokémon atacante del jugador conforme provoca daño
	var exp_log_str = ""
	if (attacker in player_team) and final_damage > 0:
		var req = attacker.get_required_exp()
		if req > 0:
			if attacker.current_exp >= req:
				exp_log_str = " [color=#FFD700](EXP MAX: %d/%d)[/color]" % [attacker.current_exp, req]
			else:
				var exp_gained = min(final_damage, req - attacker.current_exp)
				attacker.current_exp += exp_gained
				var is_now_max = (attacker.current_exp >= req)
				exp_log_str = " [color=#64B5F6](+%d EXP ➔ %d/%d%s)[/color]" % [
					exp_gained, 
					attacker.current_exp, 
					req, 
					" ⭐ READY TO EVOLVE!" if is_now_max else ""
				]
		else:
			exp_log_str = ""
			
		if GameData.is_campaign_mode:
			var p_idx = player_team.find(attacker)
			var active_team = GameData.get_active_campaign_team_state()
			if p_idx != -1 and p_idx < active_team.size():
				active_team[p_idx]["current_exp"] = attacker.current_exp
	
	var boost_str = " (BOOSTED)" if boosted else ""
	log_action("[b]%s[/b] used [color=cyan]%s[/color] [%s]%s dealing [b]%d[/b] damage.%s%s" % [
		attacker.name, move.name, move.type, boost_str, final_damage, note_text, exp_log_str
	])
	
	lunge_card(attacker_visual, attacker == get_active_player())
	GameData.play_move_sfx(move.name)
	if final_damage > 0:
		var is_weakness = GameData.types_match(defender.weakness, move.type)
		var is_resist = GameData.is_attack_resisted(defender.type, defender.resistant, move.type)
		play_damage_hit(defender_visual, move.type, final_damage)
		spawn_floating_combat_number(defender_visual, -final_damage, false, is_weakness)
		if is_weakness:
			GameData.play_combat_sfx("hit_super")
			if attacker == get_active_player() and GameData.is_campaign_mode:
				GameData.add_daily_mission_progress("super_effective", 1)
		elif is_resist:
			GameData.play_combat_sfx("hit_weak")
		else:
			GameData.play_combat_sfx("hit_normal")
	else:
		shake_node(defender_visual)
	update_ui()
	
	check_active_faint()

# Procesa recompensas dinámicas por Pokémon enemigos derrotados en el torneo
func process_defeated_enemies() -> void:
	if not GameData.is_campaign_mode:
		return
		
	for i in range(enemy_team.size()):
		var e = enemy_team[i]
		if e.current_hp <= 0 and not (i in defeated_enemy_indices):
			defeated_enemy_indices.append(i)
			GameData.add_daily_mission_progress("defeat_pokemon", 1)
			var drop = GameData.calculate_pkmn_defeat_reward(e.rarity, e.stage)
			var g_drop = int(drop.get("gold", 0))
			var d_drop = int(drop.get("diamonds", 0))
			if g_drop > 0:
				GameData.add_daily_mission_progress("earn_gold", g_drop)
			combat_earned_gold += g_drop
			combat_earned_diamonds += d_drop
			defeated_rewards_summary.append({
				"name": e.name,
				"rarity": e.rarity,
				"stage": e.stage,
				"gold": g_drop,
				"diamonds": d_drop
			})
			
			var drop_str = "+%d G" % g_drop
			if d_drop > 0:
				drop_str += " & 💎 +%d Diamond%s" % [d_drop, "s" if d_drop > 1 else ""]
			log_action("💥 [b]%s[/b] KO'd! [color=#FFD54F]Foe dropped: %s[/color]" % [e.name, drop_str])

# --- REVISIÓN DE CAÍDAS Y DERROTAS ---
func _animate_faint_and_replacement(is_player: bool, fainted_pkmn, next_idx: int) -> void:
	var card_node = player_card_img if is_player else enemy_card_img
	if is_player:
		is_player_fainting = true
	else:
		is_enemy_fainting = true
	is_busy = true
	can_player_act = false
	set_controls_enabled(false)
	
	if is_player and player_status_overlay:
		player_status_overlay.clear_all()
	elif not is_player and enemy_status_overlay:
		enemy_status_overlay.clear_all()
	
	GameData.play_combat_sfx("faint")
	if not is_player:
		process_defeated_enemies()
		
	var orig_pos = card_node.position
	if card_node.has_meta("original_pos"):
		orig_pos = card_node.get_meta("original_pos")
	else:
		card_node.set_meta("original_pos", orig_pos)
		
	# 1. Animación clásica y dramática de caída / desmayo (faint):
	# Destello sutil rojizo de derrota, hundimiento hacia abajo (sliding down) y desvanecimiento a opacidad 0
	var faint_tween = create_tween()
	faint_tween.tween_property(card_node, "modulate", Color(1.0, 0.25, 0.25, 1.0), 0.1)
	faint_tween.set_parallel(true)
	faint_tween.tween_property(card_node, "position:y", orig_pos.y + 75.0, 0.52).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	faint_tween.tween_property(card_node, "modulate", Color(0.15, 0.05, 0.05, 0.0), 0.52).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	faint_tween.chain().finished.connect(func():
		if not is_instance_valid(card_node):
			if is_player: is_player_fainting = false else: is_enemy_fainting = false
			return
			
		if next_idx != -1:
			# Hay un sustituto en la banca
			if is_player:
				active_player_idx = next_idx
				reset_selected_energy()
				var new_p = get_active_player()
				log_action("[b]%s[/b] enters the field!" % new_p.name)
				if new_p.has_passive and new_p.passive_name == "String Shot":
					log_action("✨ Weedle's [color=cyan]String Shot[/color] passively reduces foe's Speed by 1.")
			else:
				active_enemy_idx = next_idx
				var new_e = get_active_enemy()
				log_action("Rival sends out [b]%s[/b]!" % new_e.name)
				if new_e.has_passive and new_e.passive_name == "String Shot":
					log_action("✨ Weedle's [color=cyan]String Shot[/color] passively reduces foe's Speed by 1.")
			
			# Actualiza la UI con los nuevos datos, textura y stats del Pokémon entrante
			update_ui()
			
			# Preparar animación de entrada (cae desde arriba con ligero rebote y fade in)
			card_node.position = orig_pos + Vector2(0, -40.0)
			card_node.modulate = Color(1.0, 1.0, 1.0, 0.0)
			GameData.play_combat_sfx("switch")
			
			var enter_tween = create_tween()
			enter_tween.set_parallel(true)
			enter_tween.tween_property(card_node, "position:y", orig_pos.y, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			enter_tween.tween_property(card_node, "modulate:a", 1.0, 0.32)
			enter_tween.chain().finished.connect(func():
				if is_instance_valid(card_node):
					card_node.position = orig_pos
					card_node.modulate = Color.WHITE
				if is_player:
					is_player_fainting = false
				else:
					is_enemy_fainting = false
				is_busy = false
			)
		else:
			# No quedan Pokémon en el equipo -> Derrota total del equipo
			card_node.modulate = Color(1.0, 1.0, 1.0, 0.0)
			if is_player:
				is_player_fainting = false
			else:
				is_enemy_fainting = false
			check_team_defeat()
	)

func check_active_faint() -> bool:
	var active_p = get_active_player()
	var active_e = get_active_enemy()
	var triggered = false
	
	if active_e and active_e.current_hp <= 0 and not is_enemy_fainting:
		var next_e_idx = find_next_alive_enemy()
		log_action("[b]Rival's %s fainted![/b]" % active_e.name)
		_animate_faint_and_replacement(false, active_e, next_e_idx)
		triggered = true
		if next_e_idx == -1:
			check_team_defeat()
			return true
			
	if active_p and active_p.current_hp <= 0 and not is_player_fainting:
		var next_p_idx = find_next_alive_player()
		log_action("[b]Your %s fainted in battle![/b]" % active_p.name)
		_animate_faint_and_replacement(true, active_p, next_p_idx)
		triggered = true
		if next_p_idx == -1:
			check_team_defeat()
			return true
			
	if triggered:
		update_ui()
	return triggered or is_enemy_fainting or is_player_fainting

func find_next_alive_player() -> int:
	for i in range(player_team.size()):
		if i != active_player_idx and player_team[i].current_hp > 0:
			return i
	return -1

func find_next_alive_enemy() -> int:
	for i in range(enemy_team.size()):
		if i != active_enemy_idx and enemy_team[i].current_hp > 0:
			return i
	return -1

func check_team_defeat() -> bool:
	if is_battle_over:
		return true
		
	# Procesar caídas pendientes de rivales para asegurar drops
	process_defeated_enemies()
		
	var enemy_all_dead = true
	for p in enemy_team:
		if p.current_hp > 0:
			enemy_all_dead = false
			break
			
	var player_all_dead = true
	for p in player_team:
		if p.current_hp > 0:
			player_all_dead = false
			break
			
	if enemy_all_dead:
		is_battle_over = true
		if GameData.is_campaign_mode:
			var active_team = GameData.get_active_campaign_team_state()
			for i in range(min(player_team.size(), active_team.size())):
				active_team[i]["current_hp"] = player_team[i].current_hp
				active_team[i]["current_exp"] = player_team[i].current_exp
				active_team[i]["burn_turns"] = player_team[i].burn_turns
				active_team[i]["is_poisoned"] = player_team[i].is_poisoned
				active_team[i]["is_flinched"] = player_team[i].is_flinched
				
		_resolve_battle_victory()
		return true
	elif player_all_dead:
		is_battle_over = true
		if GameData.is_campaign_mode:
			var active_team = GameData.get_active_campaign_team_state()
			for i in range(min(player_team.size(), active_team.size())):
				active_team[i]["current_hp"] = player_team[i].current_hp
				active_team[i]["current_exp"] = player_team[i].current_exp
				active_team[i]["burn_turns"] = player_team[i].burn_turns
				active_team[i]["is_poisoned"] = player_team[i].is_poisoned
				active_team[i]["is_flinched"] = player_team[i].is_flinched
				
		_resolve_battle_defeat()
		return true
	return false

func _resolve_battle_victory() -> void:
	GameData.stats_battles_total += 1
	GameData.stats_battles_won += 1
	if GameData.is_tutorial_mode:
		GameData.tutorial_completed = true
		GameData.just_completed_tutorial = true
		var reward_text = ""
		if not GameData.tutorial_reward_claimed:
			GameData.player_diamonds += 5
			GameData.tutorial_reward_claimed = true
			reward_text = "\n\n🎁 First Clear Reward: 💎 5 Diamonds!\n🔓 Adventure Mode Episode I is now UNLOCKED!"
		else:
			reward_text = "\n\n(Tutorial completed - practice cleared!)"
		GameData.save_profile()
		show_game_over(
			"🎓 TUTORIAL COMPLETE!",
			"Congratulations! You defeated Bulbasaur and mastered the fundamentals of battle!%s\n\nHead to the Campaign Hub to begin Episode I of your Adventure!" % reward_text
		)
		return
	if GameData.is_campaign_mode:
		GameData.add_daily_mission_progress("win_battles", 1)
		GameData.add_daily_mission_progress("defeat_gym", 1)
		# Guardar la salud, experiencia y estados restantes de los Pokémon en la campaña activa
		var active_team = GameData.get_active_campaign_team_state()
		for i in range(min(player_team.size(), active_team.size())):
			active_team[i]["current_hp"] = player_team[i].current_hp
			active_team[i]["current_exp"] = player_team[i].current_exp
			active_team[i]["burn_turns"] = player_team[i].burn_turns
			active_team[i]["is_poisoned"] = player_team[i].is_poisoned
			active_team[i]["is_flinched"] = player_team[i].is_flinched
			
		# Las evoluciones ocurren ahora en el Campamento!
		var pending_evos = GameData.get_pending_campaign_evolutions()
		var evo_msg = ""
		if not pending_evos.is_empty():
			evo_msg = "\n\n⛺ CAMP EVOLUTION READY!\n"
			for pe in pending_evos:
				evo_msg += "• %s is ready to evolve in Camp! 🎉\n" % pe["from_name"]
		else:
			for p in active_team:
				var st = str(p.get("stage", "Basic")).strip_edges().to_lower()
				var req_exp = 10 if st == "basic" else (25 if st == "stage 1" else 0)
				var cur_exp = int(p.get("current_exp", 0))
				var cur_hp = int(p.get("current_hp", 0))
				if req_exp > 0 and cur_exp >= req_exp and cur_hp <= 0:
					evo_msg = "\n\n💀 %s is KO! Use a Revive in Camp to allow evolution.\n" % p["name"]
					break
			
		if GameData.campaign_submode == "ADVENTURE":
			GameData.add_daily_mission_progress("clear_stage", 1)
			var ep_id = GameData.adventure_current_episode
			var cur_stage = GameData.adventure_current_stage
			var total_stages = GameData.get_adventure_total_stages(ep_id)
			var stage_info = GameData.get_adventure_stage_info(ep_id, cur_stage)
			var trainer_name = stage_info.get("trainer_name", "Trainer")
			var outro_text = stage_info.get("outro", "")
			
			var total_gold_won = combat_earned_gold
			var total_diamonds_won = combat_earned_diamonds
			GameData.add_active_campaign_gold(total_gold_won)
			if total_diamonds_won > 0:
				GameData.player_diamonds += total_diamonds_won
				
			var loot_details = "\n💰 Combat Loot: +%d G" % combat_earned_gold
			if combat_earned_diamonds > 0:
				loot_details += " & 💎 +%d Diamonds" % combat_earned_diamonds
				
			var outro_msg = "\n💬 %s: \"%s\"" % [trainer_name, outro_text] if outro_text != "" else ""
			
			if cur_stage >= total_stages:
				# Final boss cleared! (Brock in Ep I, Misty in Ep II, etc.)
				var bonus_diamonds = GameData.complete_adventure_episode(ep_id)
				var badge_str = stage_info.get("badge_name", "Boulder Badge")
				var ep_info = GameData.get_adventure_episode_info(ep_id)
				var next_ep_id = ep_id + 1
				var first_clear_text = ""
				if bonus_diamonds > 0:
					first_clear_text = "\n🎁 FIRST CLEAR BONUS: +💎 %d Diamonds!\n🔓 Episode %d Unlocked!" % [bonus_diamonds, next_ep_id]
				else:
					first_clear_text = "\n(Episode already cleared - replay completed!)"
					
				# Reiniciar progreso del run del episodio al terminar para evitar farmear al jefe
				GameData.reset_adventure_episode(ep_id)
				GameData.is_campaign_mode = false
				GameData.last_adventure_episode_conquered = true
				GameData.save_profile()
				show_game_over(
					"🎉 EPISODE CONQUERED! %s WON!" % badge_str.to_upper(),
					"You defeated %s and conquered %s!%s%s%s\nFinal Gold: %d G | Total Diamonds: 💎 %d%s\nCongratulations on your grand victory!" % [
						trainer_name,
						ep_info.get("title", "Episode %d" % ep_id),
						outro_msg,
						first_clear_text,
						loot_details,
						GameData.get_active_campaign_gold(),
						GameData.player_diamonds,
						evo_msg
					]
				)
			else:
				# Stages 1, 2, 3
				GameData.adventure_current_stage += 1
				GameData.save_profile()
				show_game_over(
					"⚔️ VICTORY OVER %s!" % trainer_name.to_upper(),
					"Victory in Stage %d / %d!%s%s\nCurrent Gold: %d G | Total Diamonds: 💎 %d\n⚠️ Your Pokémon do NOT heal automatically.%s\nVisit the camp shop to prepare for the next battle." % [
						cur_stage,
						total_stages,
						outro_msg,
						loot_details,
						GameData.get_active_campaign_gold(),
						GameData.player_diamonds,
						evo_msg
					]
				)
		else:
			# Modo Torneo
			var current_match = GameData.campaign_match_number
			var match_info = GameData.get_tournament_match_info(current_match)
			var base_gold = int(match_info.get("reward_gold", 0))
			var milestone_diamonds = int(match_info.get("reward_diamonds", 0))
			var total_gold_won = combat_earned_gold + base_gold
			var total_diamonds_won = combat_earned_diamonds + milestone_diamonds
				
			GameData.campaign_gold += total_gold_won
			if total_diamonds_won > 0:
				GameData.player_diamonds += total_diamonds_won
				
			var loot_details = "\n💰 Combat Loot: +%d G" % combat_earned_gold
			if combat_earned_diamonds > 0:
				loot_details += " & 💎 +%d Diamonds" % combat_earned_diamonds
			if milestone_diamonds > 0:
				loot_details += " (+💎 %d Phase Bonus!)" % milestone_diamonds
				
			GameData.campaign_match_number += 1
			
			if GameData.campaign_match_number > GameData.TOURNAMENT_TOTAL_MATCHES:
				GameData.stats_tournaments_won += 1
				GameData.save_profile()
				show_game_over(
					"🎉 POKÉMON TOURNAMENT CHAMPION!",
					"You conquered all 9 battles and won the Tournament Grand Finale!%s\nFinal Gold: %d G | Total Diamonds: 💎 %d%s\nHonor and glory to your champion team!" % [
						loot_details,
						GameData.campaign_gold,
						GameData.player_diamonds,
						evo_msg
					]
				)
			elif milestone_diamonds > 0:
				GameData.save_profile()
				show_game_over(
					"🌟 %s PHASE COMPLETE!" % match_info["phase_name"].to_upper(),
					"Victory in Battle %d / %d!%s\nCurrent Gold: %d G | Total Diamonds: 💎 %d\n⚠️ Your Pokémon do NOT heal automatically.%s\nPrepare for Phase %d at the Camp!" % [
						current_match,
						GameData.TOURNAMENT_TOTAL_MATCHES,
						loot_details,
						GameData.campaign_gold,
						GameData.player_diamonds,
						evo_msg,
						int(match_info.get("phase_num", 1)) + 1
					]
				)
			else:
				GameData.save_profile()
				show_game_over(
					"⚔️ VICTORY IN BATTLE %d / %d!" % [current_match, GameData.TOURNAMENT_TOTAL_MATCHES],
					"Victory!%s\nCurrent Gold: %d G | Total Diamonds: 💎 %d\n⚠️ Your Pokémon do NOT heal automatically.%s\nVisit the shop and prepare at the camp." % [
						loot_details,
						GameData.campaign_gold,
						GameData.player_diamonds,
						evo_msg
					]
				)
	else:
		GameData.save_profile()
		if GameData.is_online_pvp:
			show_game_over("🏆 ONLINE VICTORY!", "You defeated %s's entire team!" % GameData.online_rival_name)
		elif GameData.is_pvp_mode:
			show_game_over("🏆 PLAYER 1 WINS!", "Player 1 has defeated all of Player 2's Pokémon!")
		else:
			show_game_over("VICTORY!", "You defeated the rival team!")
func _resolve_battle_defeat() -> void:
	GameData.stats_battles_total += 1
	if GameData.is_tutorial_mode:
		show_game_over(
			"💀 TUTORIAL DEFEATED",
			"Charmander fainted! Don't worry, you can try the tutorial again anytime to claim your 💎 5 Diamonds reward."
		)
		return
	if GameData.is_campaign_mode:
		# Conservar Oro y Diamantes obtenidos de los rivales derrotados en este combate
		if combat_earned_diamonds > 0:
			GameData.player_diamonds += combat_earned_diamonds
		if combat_earned_gold > 0:
			GameData.add_active_campaign_gold(combat_earned_gold)
		var kept_diamonds = GameData.player_diamonds
		var kept_gold = GameData.get_active_campaign_gold()
		var foes_ko_count = defeated_enemy_indices.size()
		
		var preserved_msg = ""
		if combat_earned_diamonds > 0 or combat_earned_gold > 0:
			preserved_msg = "\n💰 PRESERVED LOOT: +%d G | 💎 +%d Diamonds (from %d defeated foe%s)!\nTotal Gold: %d G | Total Diamonds: 💎 %d" % [
				combat_earned_gold,
				combat_earned_diamonds,
				foes_ko_count,
				"s" if foes_ko_count > 1 else "",
				kept_gold,
				kept_diamonds
			]
		else:
			preserved_msg = "\n(Total Gold: %d G | Total Diamonds: 💎 %d)" % [kept_gold, kept_diamonds]
			
		if GameData.campaign_submode == "ADVENTURE":
			var ep_id = GameData.adventure_current_episode
			GameData.reset_adventure_episode(ep_id)
			GameData.is_campaign_mode = false
			GameData.save_profile()
			show_game_over(
				"💀 DEFEATED IN ADVENTURE!",
				"All your Pokémon have fainted in battle.\nEpisode progress was reset, but your Gold (G) and Diamonds are safe!%s\nYou can embark again from the Campaign Hub!" % preserved_msg
			)
		else:
			GameData.reset_campaign()
			GameData.save_profile()
			show_game_over(
				"💀 ELIMINATED FROM THE TOURNAMENT!",
				"All your Pokémon have fainted in battle.\nThe Tournament run was reset, but your Gold (G) and Diamonds are safe!%s\nYou can use your Gold at the Camp to buy supplies for your next run!" % preserved_msg
			)
	else:
		GameData.save_profile()
		if GameData.is_online_pvp:
			show_game_over("💀 ONLINE DEFEAT", "%s defeated all your Pokémon." % GameData.online_rival_name)
		elif GameData.is_pvp_mode:
			show_game_over("🏆 PLAYER 2 WINS!", "Player 2 has defeated all of Player 1's Pokémon!")
		else:
			show_game_over("DEFEAT!", "Your Pokémon have been defeated!")

# --- GESTIÓN DE EVOLUCIONES CON ANIMACIÓN Y CURACIÓN ---
func _get_pending_player_evolutions() -> Array[Dictionary]:
	var pending: Array[Dictionary] = []
	for i in range(player_team.size()):
		var p = player_team[i]
		if not p:
			continue
		var req_exp = p.get_required_exp()
		var cur_exp = p.current_exp
		if GameData.is_campaign_mode:
			var active_team = GameData.get_active_campaign_team_state()
			if i < active_team.size():
				cur_exp = max(cur_exp, int(active_team[i].get("current_exp", 0)))
				
		if req_exp > 0 and cur_exp >= req_exp:
			var target_id = GameData.get_evolution_target_id(p.id)
			if target_id != -1 and GameData.is_pokemon_unlocked(target_id):
				var target_inst = GameData.create_pokemon_instance(target_id)
				if target_inst:
					var old_hp = p.current_hp
					var new_max_hp = target_inst.max_hp
					var hp_healed = new_max_hp - max(0, old_hp)
					pending.append({
						"team_index": i,
						"pokemon": p,
						"from_name": p.name,
						"to_name": target_inst.name,
						"from_id": p.id,
						"to_id": target_id,
						"from_texture": p.texture_path,
						"to_texture": target_inst.texture_path,
						"old_hp": old_hp,
						"old_max_hp": p.max_hp,
						"new_max_hp": new_max_hp,
						"hp_healed": max(1, hp_healed),
						"target_inst": target_inst,
						"new_stage": target_inst.stage
					})
	return pending

func _check_and_run_end_of_combat_evolutions(on_complete: Callable) -> void:
	var pending = _get_pending_player_evolutions()
	if pending.is_empty():
		if on_complete:
			on_complete.call()
		return
		
	set_controls_enabled(false)
	_run_evolution_queue(pending, on_complete)

func _run_evolution_queue(queue: Array, on_complete: Callable) -> void:
	if queue.is_empty():
		if evolution_modal:
			evolution_modal.visible = false
		if on_complete:
			on_complete.call()
		return
		
	var evo = queue.pop_front()
	_play_evolution_sequence(evo, func():
		_apply_pokemon_evolution(evo)
		_run_evolution_queue(queue, on_complete)
	)

func _play_evolution_sequence(evo: Dictionary, on_finished: Callable) -> void:
	if not evolution_modal:
		_apply_pokemon_evolution(evo)
		if on_finished:
			on_finished.call()
		return
		
	evolution_modal.visible = true
	if evo_btn_continue:
		evo_btn_continue.visible = false
		
	var from_name = str(evo.get("from_name", ""))
	var to_name = str(evo.get("to_name", ""))
	var from_tex_path = str(evo.get("from_texture", ""))
	var to_tex_path = str(evo.get("to_texture", ""))
	var old_hp = int(evo.get("old_hp", 0))
	var new_max_hp = int(evo.get("new_max_hp", 20))
	var hp_healed = int(evo.get("hp_healed", 10))
	
	if evo_title:
		evo_title.text = "🌟 EVOLUTION! 🌟"
	if evo_status_text:
		evo_status_text.text = "What? %s is evolving!" % from_name
	if evo_sprite:
		var from_tex = load(from_tex_path)
		if from_tex:
			evo_sprite.texture = from_tex
		evo_sprite.modulate = Color.WHITE
		evo_sprite.scale = Vector2.ONE
		
	if evo_heal_row:
		evo_heal_row.visible = false
	if evo_hp_bar:
		evo_hp_bar.visible = false
	if evo_hp_text:
		evo_hp_text.visible = false
		
	GameData.play_move_sfx("Transform")
	
	current_evo_finish_cb = on_finished
	if current_evo_tween and is_instance_valid(current_evo_tween) and current_evo_tween.is_valid():
		current_evo_tween.kill()
		
	var tw = create_tween()
	current_evo_tween = tw
	
	# Fase 1: Palpitar y preparar silueta blanca radiante (0.5s)
	tw.tween_property(evo_sprite, "scale", Vector2(1.15, 1.15), 0.22).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(evo_sprite, "modulate", Color(1.8, 1.8, 2.2), 0.22)
	tw.tween_property(evo_sprite, "scale", Vector2(0.92, 0.92), 0.18)
	
	tw.tween_property(evo_sprite, "scale", Vector2(1.25, 1.25), 0.28).set_trans(Tween.TRANS_BACK)
	tw.parallel().tween_property(evo_sprite, "modulate", Color(4.0, 4.0, 4.0, 1.0), 0.28)
	
	# Fase 2: Metamorfosis y cambio al sprite evolucionado (0.4s)
	tw.tween_callback(func():
		var to_tex = load(to_tex_path)
		if to_tex and evo_sprite:
			evo_sprite.texture = to_tex
		if evo_status_text:
			evo_status_text.text = "🎉 %s evolved into %s!" % [from_name, to_name]
		GameData.play_combat_sfx("hit_super")
	)
	
	tw.tween_property(evo_sprite, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BOUNCE)
	tw.parallel().tween_property(evo_sprite, "modulate", Color.WHITE, 0.35)
	
	tw.tween_interval(0.3)
	
	# Fase 3: Animación de Curación y barra de vida (0.8s)
	tw.tween_callback(func():
		GameData.play_combat_sfx("heal")
		if evo_heal_row:
			evo_heal_row.visible = true
		if evo_heal_label:
			evo_heal_label.text = "💖 Restored +%d HP! (Fully Healed)" % hp_healed
		if evo_hp_bar:
			evo_hp_bar.visible = true
			evo_hp_bar.max_value = float(new_max_hp)
			evo_hp_bar.value = float(max(0, old_hp))
		if evo_hp_text:
			evo_hp_text.visible = true
			evo_hp_text.text = "HP: %d / %d" % [max(0, old_hp), new_max_hp]
		if evo_btn_continue:
			evo_btn_continue.visible = true
			
		# Destello verde de curación en el sprite
		if evo_sprite:
			var heal_tw = create_tween()
			heal_tw.tween_property(evo_sprite, "modulate", Color(0.5, 2.2, 0.7), 0.18)
			heal_tw.tween_property(evo_sprite, "modulate", Color.WHITE, 0.32)
			spawn_floating_combat_number(evo_sprite, hp_healed, true)
	)
	
	if evo_hp_bar:
		tw.tween_property(evo_hp_bar, "value", float(new_max_hp), 0.6).set_trans(Tween.TRANS_CUBIC)
	if evo_hp_text:
		tw.parallel().tween_method(func(val: float):
			if evo_hp_text:
				evo_hp_text.text = "HP: %d / %d" % [int(val), new_max_hp]
		, float(max(0, old_hp)), float(new_max_hp), 0.6)
		
	# Fase 4: Pausa de celebración y desenlace
	tw.tween_interval(1.2)
	tw.tween_callback(func():
		if current_evo_finish_cb and current_evo_finish_cb.is_valid():
			var cb = current_evo_finish_cb
			current_evo_finish_cb = Callable()
			cb.call()
	)

func _apply_pokemon_evolution(evo: Dictionary) -> void:
	var idx = int(evo.get("team_index", 0))
	var p = evo.get("pokemon")
	var target_inst = evo.get("target_inst")
	var target_id = int(evo.get("to_id", -1))
	if not p or not target_inst:
		return
		
	var new_max = target_inst.max_hp
	p.id = target_id
	p.name = target_inst.name
	p.stage = target_inst.stage
	p.type = target_inst.type
	p.speed = target_inst.speed
	p.moves = target_inst.moves
	p.texture_path = target_inst.texture_path
	p.max_hp = new_max
	p.current_hp = new_max # Curado completamente por evolucionar
	p.current_exp = 0
	p.max_exp = target_inst.get_required_exp()
	p.recover_amount = target_inst.recover_amount
	p.evolves_to = target_inst.evolves_to
	p.burn_turns = 0
	p.is_poisoned = false
	p.toxic_envenomed = false
	p.is_paralyzed = false
	p.paralyze_turns = 0
	p.is_asleep_turns = 0
	p.is_frozen = false
	p.is_confused = false
	
	completed_evolutions_this_battle.append({
		"from_name": evo.get("from_name", ""),
		"to_name": target_inst.name,
		"new_stage": target_inst.stage
	})
	
	if GameData.is_campaign_mode:
		var active_team = GameData.get_active_campaign_team_state()
		if idx < active_team.size():
			active_team[idx]["id"] = target_id
			active_team[idx]["name"] = target_inst.name
			active_team[idx]["stage"] = target_inst.stage
			active_team[idx]["type"] = target_inst.type
			active_team[idx]["speed"] = target_inst.speed
			active_team[idx]["texture_path"] = target_inst.texture_path
			active_team[idx]["max_hp"] = new_max
			active_team[idx]["current_hp"] = new_max
			active_team[idx]["current_exp"] = 0
			active_team[idx]["max_exp"] = target_inst.get_required_exp()
			active_team[idx]["burn_turns"] = 0
			active_team[idx]["is_poisoned"] = false
			active_team[idx]["is_flinched"] = false
			
	update_ui()

func _on_evo_continue_pressed() -> void:
	if current_evo_tween and is_instance_valid(current_evo_tween) and current_evo_tween.is_valid():
		current_evo_tween.kill()
		current_evo_tween = null
	if current_evo_finish_cb and current_evo_finish_cb.is_valid():
		var cb = current_evo_finish_cb
		current_evo_finish_cb = Callable()
		cb.call()

# --- ACCIONES DEL JUGADOR ---
func execute_player_move(move, boosted: bool, energy_to_spend: int) -> void:
	if not _is_turn_action_allowed():
		return
	can_player_act = false
	is_busy = true
	set_controls_enabled(false)
	var is_p2 = (not is_player_turn and GameData.is_pvp_mode)
	var actor = get_active_enemy() if is_p2 else get_active_player()
	var defender = get_active_player() if is_p2 else get_active_enemy()
	var actor_img = enemy_card_img if is_p2 else player_card_img
	var defender_img = player_card_img if is_p2 else enemy_card_img
	
	perform_attack(actor, defender, move, boosted, energy_to_spend, actor_img, defender_img)
	chk_boost.button_pressed = false
	
	if GameData.is_online_pvp:
		var action_payload = {
			"type": "MOVE",
			"move_name": move.name,
			"energy_spent": energy_to_spend,
			"boosted": boosted
		}
		OnlineManager.send_battle_action(action_payload)
	
	var timer = get_tree().create_timer(2.4)
	timer.timeout.connect(func():
		if is_battle_over:
			return
		if is_enemy_fainting or is_player_fainting:
			var wait_t = get_tree().create_timer(0.4)
			wait_t.timeout.connect(func():
				is_busy = false
				if is_p2: end_enemy_turn() else: end_player_turn()
			)
			return
		is_busy = false
		if is_p2:
			end_enemy_turn()
		else:
			end_player_turn()
	)

func calculate_predicted_damage(attacker, defender, move, energy_spent: int, boosted: bool) -> int:
	if not attacker or not defender or not move:
		return 0
	if attacker.has_passive and attacker.passive_name == "Pacifist":
		return 0
	var is_full_energy: bool = (energy_spent >= move.cost or move.cost == 0)
	var dmg: int = 0
	var att_spd = get_pokemon_effective_speed(attacker, defender)
	var def_spd = get_pokemon_effective_speed(defender, attacker)

	if move.effect_type == "ANTI_TANK":
		dmg = max(1, int(round(defender.current_hp * 0.5)))
	elif move.effect_type == "MULTI_ATTACK":
		var avg_hit = 5 if move.name == "Icicle Spear" else (4 if move.name in ["Bone Rush", "Fury Swipes"] else 3)
		dmg = max(1, energy_spent) * avg_hit
	else:
		dmg = calculate_move_damage(move, energy_spent)
		if boosted:
			dmg += move.boost_damage
		if move.effect_type == "MINIMIZE" and energy_spent < move.cost:
			dmg = max(1, dmg - ((move.cost - energy_spent) * 6))
		if move.effect_type == "BOOST_DMG" and boosted:
			dmg += 4

	# Bonos del atacante
	if attacker.has_passive and attacker.passive_name == "Focus Energy" and att_spd > def_spd:
		dmg += 1
	if attacker.shield_breaker_bonus > 0 and move.effect_type != "SHIELD_BREAKER":
		dmg += attacker.shield_breaker_bonus
	if attacker.damage_buff != 0:
		dmg = max(1, dmg + attacker.damage_buff)
	if grassy_terrain_turns > 0 and move.type == "GRASS":
		dmg += 4
	if attacker.ground_boost_turns > 0 and move.type == "GROUND":
		dmg += 4

	# Momentum / Consecutivos
	if attacker.last_move_used == move.name:
		if move.effect_type == "ROLLING":
			dmg *= 2
		elif move.effect_type == "SNOWBALL":
			dmg += 4

	# Venganza / Furia
	if move.effect_type == "REVENGE" and attacker.took_damage_last_turn:
		dmg += 3
	elif move.effect_type == "RAGE" and attacker.took_damage_last_turn:
		dmg += 4

	# Velocidad superior
	if move.effect_type == "BOOST_IF_FASTER" and is_full_energy and att_spd > def_spd:
		dmg += 3

	# Sinergias de estado
	if move.effect_type == "BLAZE" and defender.burn_turns > 0:
		dmg += 3
	if move.effect_type == "BOOST_IF_PARALYZED" and defender.is_paralyzed:
		dmg += 4
	if move.effect_type == "OVERCHARGE" and defender.is_paralyzed:
		dmg += 6
	if defender.is_poisoned:
		if move.effect_type in ["DOUBLE_DMG", "SHOCK"]:
			dmg *= 2
		elif move.effect_type == "DROWN":
			dmg += 4
	if move.effect_type == "BOOST_CONFUSED" and defender.is_confused:
		dmg += 3
	if defender.is_asleep_turns > 0 and move.name == "Dream Eater":
		dmg += 5

	# Bono de daño por tipo objetivo
	if move.effect_type == "BOOST_DMG_TYPE" and is_full_energy:
		var desc_u = move.description.to_upper()
		if "FIGHTING" in desc_u and defender.type == "FIGHTING":
			dmg += 3 if "+3" in desc_u else 2
		elif "GRASS" in desc_u and defender.type == "GRASS":
			dmg += 2
		elif "NORMAL" in desc_u and defender.type == "NORMAL":
			dmg += 2

	# Debilidad / Resistencia
	if move.effect_type in ["WEAK_SPOT", "ADAPT"]:
		dmg += WEAKNESS_BONUS
	elif move.effect_type in ["DOUBLE_TYPE", "TRIPLE_TYPE"]:
		var combo_types = ["WATER", "FIRE", "ELECTRIC"] if move.effect_type == "TRIPLE_TYPE" else (["FIGHTING", "PSYCHIC"] if move.name == "Aura Sphere" else ["ICE", "FIGHTING"])
		var hit_weak = false
		var all_res = true
		for ct in combo_types:
			if GameData.types_match(defender.weakness, ct):
				hit_weak = true
			if not GameData.is_attack_resisted(defender.type, defender.resistant, ct):
				all_res = false
		if hit_weak:
			dmg += WEAKNESS_BONUS
		elif all_res:
			dmg = max(MIN_DAMAGE_AFTER_RESIST, dmg - RESISTANCE_REDUCTION)
	elif GameData.types_match(defender.weakness, move.type):
		dmg += WEAKNESS_BONUS
	elif GameData.is_attack_resisted(defender.type, defender.resistant, move.type):
		dmg = max(MIN_DAMAGE_AFTER_RESIST, dmg - RESISTANCE_REDUCTION)

	# Reducciones defensivas
	if defender.has_passive and defender.passive_name == "Charm" and move.type == "NORMAL":
		dmg = max(1, dmg - 1)
	if attacker.is_poisoned:
		dmg = max(1, dmg - 1)
	if attacker.foe_damage_debuff > 0:
		dmg = max(1, dmg - attacker.foe_damage_debuff)
	if defender.shield_reduction > 0:
		dmg = max(0, dmg - defender.shield_reduction)
	if defender.has_passive and defender.passive_name == "Slimy":
		dmg = max(1, int(ceil(dmg * 0.5)))

	return max(0, dmg)

func open_energy_select_modal(move, initial_boosted: bool, max_spend: int) -> void:
	var p = get_active_player()
	var e = get_active_enemy()
	if not p or not e:
		return
		
	# Limpiar opciones previas
	for child in energy_modal_options.get_children():
		child.queue_free()
		
	energy_modal_icon.texture = GameData.get_type_icon_texture(move.type)
	energy_modal_title.text = "%s [Base Cost: %d⚡]" % [move.name, move.cost]
	energy_modal_target.text = "🎯 Rival: %s (❤️ %d / %d HP)" % [e.name, e.current_hp, e.max_hp]
	energy_modal_prompt.text = "Choose how much energy to spend for this attack:"
	
	# Indicador de afinidad de tipo frente al rival
	var type_mod_str = ""
	if GameData.types_match(e.weakness, move.type):
		type_mod_str = " (Effective +%d!)" % WEAKNESS_BONUS
	elif GameData.is_attack_resisted(e.type, e.resistant, move.type):
		type_mod_str = " (Resisted -%d)" % RESISTANCE_REDUCTION
	
	# Caso 1: Ataque Múltiple (Fury Attack)
	if move.effect_type == "MULTI_ATTACK":
		var limit = clamp(p.current_energy, 1, move.cost)
		for amt in range(1, limit + 1):
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(0, 48)
			btn.add_theme_font_size_override("font_size", 12)
			
			var lightning = ""
			for l in range(amt):
				lightning += "⚡"
				
			var remate_note = ""
			if amt * 2 >= e.current_hp:
				remate_note = "  ✨ [Ideal finisher!]"
				btn.modulate = Color(0.3, 1.0, 0.4)
				
			var hit_desc = "4-8 DMG/hit (25% Crit)" if move.name == "Icicle Spear" else ("3-7 DMG/hit (25% Crit)" if move.name in ["Bone Rush", "Fury Swipes"] else "2-5 DMG/hit (25% Crit)")
			btn.text = "%s %d Hit%s [Uses %d⚡]%s\n(%s • Save %d⚡)" % [
				lightning, amt, "s" if amt > 1 else "", amt, remate_note, hit_desc, p.current_energy - amt
			]
			var spend_amt = amt
			btn.pressed.connect(func():
				energy_modal.visible = false
				execute_player_move(move, false, spend_amt)
			)
			energy_modal_options.add_child(btn)
			
		energy_modal.visible = true
		return

	# Caso 2: Movimiento normal con costo > 1
	var normal_cost = move.cost
	var can_boost_this = move.can_boost and (p.current_energy >= (normal_cost + move.boost_cost))
	var upper_limit = min(p.current_energy, normal_cost)
	
	# Opciones parciales y completa normal (1 hasta upper_limit)
	for amt in range(1, upper_limit + 1):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 12)
		
		var lightning = ""
		for l in range(amt):
			lightning += "⚡"
			
		var dmg = calculate_predicted_damage(p, e, move, amt, false)
		
		if amt < normal_cost:
			# Opción parcial
			var remate_note = ""
			if dmg >= e.current_hp:
				remate_note = "  ✨ Sufficient to defeat! (Knockout)"
				btn.modulate = Color(0.3, 1.0, 0.4)
			else:
				btn.modulate = Color(1.0, 1.0, 1.0)
				
			btn.text = "%s Pay %d/%d⚡ ➔ %d DMG%s [Partial]%s\n(No secondary effect • Save %d⚡)" % [
				lightning, amt, normal_cost, dmg, type_mod_str, remate_note, p.current_energy - amt
			]
		else:
			# Opción completa normal (amt == normal_cost)
			var eff_desc = "Active effect"
			if move.effect_type == "SLOW_FOE":
				eff_desc = "Reduces foe's SPD by 1"
			elif move.effect_type == "BURN":
				eff_desc = "Inflicts Burn"
			elif move.effect_type == "POISON" or move.effect_type == "POISON_IF_FASTER":
				eff_desc = "Inflicts Poison (-1 DMG)"
			elif move.effect_type == "LIFE_DRAIN":
				eff_desc = "Drains 50% of dealt HP"
			elif move.effect_type == "SHIELD_BREAKER":
				eff_desc = "Charges +4 DMG to next move"
			elif move.effect_type == "SUPPORT_BOOST":
				eff_desc = "Cures status conditions"
				
			var remate_note = ""
			if dmg >= e.current_hp:
				remate_note = "  ✨ Knockout!"
				
			btn.text = "%s Pay %d/%d⚡ ➔ %d DMG%s [Full]%s\n(Triggers effect: %s)" % [
				lightning, amt, normal_cost, dmg, type_mod_str, remate_note, eff_desc
			]
			btn.modulate = Color(0.85, 0.95, 1.0)
			
		var spend_amt = amt
		btn.pressed.connect(func():
			energy_modal.visible = false
			execute_player_move(move, false, spend_amt)
		)
		energy_modal_options.add_child(btn)
		
	# Opción Potenciada (Boost) si el Pokémon tiene la energía suficiente para el boost
	if can_boost_this:
		var boost_btn = Button.new()
		boost_btn.custom_minimum_size = Vector2(0, 52)
		boost_btn.add_theme_font_size_override("font_size", 12)
		
		var b_cost = normal_cost + move.boost_cost
		var b_dmg = calculate_predicted_damage(p, e, move, b_cost, true)
		var lightning = ""
		for l in range(b_cost):
			lightning += "⚡"
			
		var b_extra = "(+%d DMG & boosted effect)" % move.boost_damage
		if move.effect_type == "FLINCH":
			b_extra = "(+%d DMG & inflicts Flinch)" % move.boost_damage
		elif move.effect_type == "LIFE_DRAIN":
			b_extra = "(+%d DMG & heals 100%% dealt HP)" % move.boost_damage
		elif move.effect_type == "BURN":
			b_extra = "(Inflicts Burn for 2 turns)"
			
		var b_remate = ""
		if b_dmg >= e.current_hp:
			b_remate = "  ✨ Knockout!"
			
		boost_btn.text = "%s Pay %d⚡ ➔ %d DMG%s [BOOSTED 🔥]%s\n%s" % [
			lightning, b_cost, b_dmg, type_mod_str, b_remate, b_extra
		]
		boost_btn.modulate = Color(1.0, 0.75, 0.2)
		boost_btn.pressed.connect(func():
			energy_modal.visible = false
			execute_player_move(move, true, b_cost)
		)
		energy_modal_options.add_child(boost_btn)
		
	energy_modal.visible = true

func _on_move_button_pressed(move_idx: int) -> void:
	if not _is_turn_action_allowed():
		return
	var is_p2 = (not is_player_turn and GameData.is_pvp_mode)
	var actor = get_active_enemy() if is_p2 else get_active_player()
	var defender = get_active_player() if is_p2 else get_active_enemy()
	if not actor or move_idx >= actor.moves.size():
		return
	var move = actor.moves[move_idx]
	
	if actor.current_energy < move.min_energy_req:
		log_action("[color=red]Not enough energy to use %s! Requires at least %d⚡, you have %d⚡.[/color]" % [move.name, move.min_energy_req, actor.current_energy])
		return
		
	var selected_spend = selected_energy_move1 if move_idx == 0 else selected_energy_move2
	var can_afford_boost = move.can_boost and (actor.current_energy >= (move.cost + move.boost_cost))
	var max_cost = move.cost + (move.boost_cost if can_afford_boost else 0)
	
	if move.cost == 0:
		selected_spend = 0
	else:
		if selected_spend < move.min_energy_req or selected_spend > max_cost:
			selected_spend = clamp(actor.current_energy, move.min_energy_req, move.cost)
		elif selected_spend > actor.current_energy:
			log_action("[color=red]Not enough energy to spend %d⚡ (you have %d⚡)![/color]" % [selected_spend, actor.current_energy])
			return
			
	var is_boost_spend = (selected_spend > move.cost)
	execute_player_move(move, is_boost_spend, selected_spend)

func _on_move1_pressed() -> void:
	_on_move_button_pressed(0)

func _on_move2_pressed() -> void:
	_on_move_button_pressed(1)

func _on_passive_pressed() -> void:
	if not _is_turn_action_allowed():
		return
	var is_p2 = (not is_player_turn and GameData.is_pvp_mode)
	var actor = get_active_enemy() if is_p2 else get_active_player()
	var defender = get_active_player() if is_p2 else get_active_enemy()
	var actor_img = enemy_card_img if is_p2 else player_card_img
	var defender_img = player_card_img if is_p2 else enemy_card_img
	
	if actor.has_passive and actor.passive_name == "Turtle Shell":
		if not actor.took_damage_last_turn:
			log_action("[color=yellow]Turtle Shell requires taking damage on the previous turn![/color]")
			return
		if actor.current_energy < 1:
			log_action("[color=red]You need at least 1⚡ to activate Turtle Shell![/color]")
			return
			
		can_player_act = false
		is_busy = true
		set_controls_enabled(false)
		actor.current_energy -= 1
		actor.temp_speed_mod = 2
		actor.speed_mod_expires_round = round_number + 1
		
		var dmg = 3
		if GameData.is_attack_resisted(defender.type, defender.resistant, "NORMAL"):
			dmg = max(1, dmg - RESISTANCE_REDUCTION)
		defender.current_hp = max(0, defender.current_hp - dmg)
		
		var prefix = "🔵 Player 2's " if is_p2 else ""
		log_action("%s[b]%s[/b] activated passive [color=cyan]Turtle Shell[/color] dealing [b]%d[/b] damage and gaining [b]+2 Speed[/b]!" % [prefix, actor.name, dmg])
		lunge_card(actor_img, not is_p2)
		play_damage_hit(defender_img, "NORMAL", dmg)
		spawn_floating_combat_number(defender_img, -dmg, false)
		update_ui()
		check_active_faint()
		
		var timer = get_tree().create_timer(2.2)
		timer.timeout.connect(func():
			if is_enemy_fainting or is_player_fainting:
				var wait_t = get_tree().create_timer(0.4)
				wait_t.timeout.connect(func():
					if is_p2: end_enemy_turn() else: end_player_turn()
				)
				return
			is_busy = false
			if is_p2:
				end_enemy_turn()
			else:
				end_player_turn()
		)

func _on_recover_pressed() -> void:
	if not _is_turn_action_allowed():
		return
	var is_p2 = (not is_player_turn and GameData.is_pvp_mode)
	var actor = get_active_enemy() if is_p2 else get_active_player()
	if actor.current_energy >= actor.max_energy:
		log_action("[color=yellow]%s's energy is already full (%d/%d)![/color]" % [actor.name, actor.current_energy, actor.max_energy])
		return
		
	can_player_act = false
	is_busy = true
	set_controls_enabled(false)
	var rec = min(actor.recover_amount, actor.max_energy - actor.current_energy)
	actor.current_energy += rec
	if not is_p2 and GameData.is_campaign_mode:
		GameData.add_daily_mission_progress("recharge_energy", 1)
	var prefix = "🔵 Player 2's " if is_p2 else ""
	log_action("%s[b]%s[/b] used [color=cyan]Recharge[/color] and restored [b]+%d[/b] Energy (⚡ %d/%d)." % [prefix, actor.name, rec, actor.current_energy, actor.max_energy])
	update_ui()
	set_controls_enabled(false)
	
	if GameData.is_online_pvp:
		OnlineManager.send_battle_action({ "type": "RECHARGE" })
	
	var timer = get_tree().create_timer(1.4)
	timer.timeout.connect(func():
		if is_battle_over:
			return
		is_busy = false
		if is_p2:
			end_enemy_turn()
		else:
			end_player_turn()
	)

func _on_switch_pressed(benched_slot_idx: int) -> void:
	if not _is_turn_action_allowed():
		return
	var is_p2 = (not is_player_turn and GameData.is_pvp_mode)
	var current = get_active_enemy() if is_p2 else get_active_player()
	if current and current.is_constricted_dmg > 0:
		log_action("[color=red]%s is trapped by Constrict/Sand Tomb and cannot switch![/color]" % current.name)
		return

	var benched_indices = get_benched_enemy_indices() if is_p2 else get_benched_player_indices()
	if benched_slot_idx >= benched_indices.size():
		return
	var target_idx = benched_indices[benched_slot_idx]
	var current_team = enemy_team if is_p2 else player_team
	var target_pkmn = current_team[target_idx]
	
	if target_pkmn.current_hp <= 0:
		log_action("[color=red]%s has fainted and cannot enter battle![/color]" % target_pkmn.name)
		return
		
	can_player_act = false
	is_busy = true
	set_controls_enabled(false)
	GameData.play_combat_sfx("switch")
	if not is_p2 and GameData.is_campaign_mode:
		GameData.add_daily_mission_progress("switch_pkmn", 1)

	# Clear volatile battle states on outgoing Pokemon (major statuses Burn/Poison/Sleep/Freeze/Paralyze persist)
	if current:
		current.is_confused = false
		current.confused_turns = 0
		current.is_seeded_turns = 0
		current.is_constricted_dmg = 0
		current.constricted_turns = 0
		current.shield_reduction = 0
		current.shield_turns = 0
		current.wall_hp = 0
		current.is_evasive = false
		current.evasive_reflects_dmg = 0
		current.is_digging = false
		current.damage_buff = 0
		current.damage_buff_turns = 0
		current.foe_damage_debuff = 0
		current.foe_damage_debuff_turns = 0
		current.temp_speed_mod = 0
	if is_p2:
		current = get_active_enemy()
		active_enemy_idx = target_idx
		reset_selected_energy()
		log_action("🔵 Player 2 called back [b]%s[/b] and sent out [b]%s[/b]!" % [current.name, target_pkmn.name])
		
		var orig_e_pos = enemy_card_img.position
		if enemy_card_img.has_meta("original_pos"): orig_e_pos = enemy_card_img.get_meta("original_pos")
		else: enemy_card_img.set_meta("original_pos", orig_e_pos)
		
		update_ui()
		set_controls_enabled(false)
		enemy_card_img.position = orig_e_pos + Vector2(0, -35.0)
		enemy_card_img.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var sw_tween = create_tween()
		sw_tween.set_parallel(true)
		sw_tween.tween_property(enemy_card_img, "position:y", orig_e_pos.y, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		sw_tween.tween_property(enemy_card_img, "modulate:a", 1.0, 0.3)
		sw_tween.chain().finished.connect(func():
			if is_instance_valid(enemy_card_img):
				enemy_card_img.position = orig_e_pos
				enemy_card_img.modulate = Color.WHITE
		)
		
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(func():
			if is_battle_over:
				return
			is_busy = false
			end_enemy_turn()
		)
	else:
		current = get_active_player()
		active_player_idx = target_idx
		reset_selected_energy()
		log_action("[b]Tactical switch![/b] %s withdraws, [b]%s[/b] enters!" % [current.name, target_pkmn.name])
		
		var orig_p_pos = player_card_img.position
		if player_card_img.has_meta("original_pos"): orig_p_pos = player_card_img.get_meta("original_pos")
		else: player_card_img.set_meta("original_pos", orig_p_pos)
		
		update_ui()
		set_controls_enabled(false)
		player_card_img.position = orig_p_pos + Vector2(0, -35.0)
		player_card_img.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var sw_p_tween = create_tween()
		sw_p_tween.set_parallel(true)
		sw_p_tween.tween_property(player_card_img, "position:y", orig_p_pos.y, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		sw_p_tween.tween_property(player_card_img, "modulate:a", 1.0, 0.3)
		sw_p_tween.chain().finished.connect(func():
			if is_instance_valid(player_card_img):
				player_card_img.position = orig_p_pos
				player_card_img.modulate = Color.WHITE
		)
		
		if GameData.is_online_pvp:
			OnlineManager.send_battle_action({
				"type": "SWAP",
				"benched_slot_idx": benched_slot_idx,
				"target_name": target_pkmn.name
			})
		
		var timer = get_tree().create_timer(1.6)
		timer.timeout.connect(func():
			if is_battle_over:
				return
			is_busy = false
			end_player_turn()
		)

func _on_boost_toggled(_pressed: bool) -> void:
	update_move_button_labels()

# --- EVENTOS MULTIJUGADOR EN LÍNEA ---
func _on_online_opponent_action(action: Dictionary) -> void:
	if is_battle_over:
		return
	print("[OnlineBattle] 📥 Enqueueing opponent action (type=%s, seq=%s)" % [str(action.get("type", "")), str(action.get("seq", ""))])
	pending_opponent_actions.append(action)
	_try_process_next_opponent_action()

func _try_process_next_opponent_action() -> void:
	if not GameData.is_online_pvp:
		return
	if is_battle_over:
		return
	if pending_opponent_actions.is_empty():
		return
	if is_processing_opponent_action:
		print("[OnlineBattle] ⏳ Already processing an opponent action, waiting...")
		var t_proc = get_tree().create_timer(0.2)
		t_proc.timeout.connect(_try_process_next_opponent_action)
		return
	if is_enemy_fainting or is_player_fainting:
		print("[OnlineBattle] ⏳ Waiting for faint animation to complete...")
		var t = get_tree().create_timer(0.3)
		t.timeout.connect(_try_process_next_opponent_action)
		return
		
	# SURRENDER can be executed immediately regardless of whose turn it is
	if pending_opponent_actions[0].get("type", "") == "SURRENDER":
		var surr_action = pending_opponent_actions.pop_front()
		_execute_opponent_action(surr_action)
		return
		
	# Game actions must strictly wait until start_enemy_turn() is active
	if not is_waiting_for_online_opponent:
		print("[OnlineBattle] ⏳ Action waiting in queue (current state: round %d, step %d, player_turn=%s)" % [round_number, round_step, str(is_player_turn)])
		var t_wait = get_tree().create_timer(0.25)
		t_wait.timeout.connect(_try_process_next_opponent_action)
		return
		
	var next_action = pending_opponent_actions.pop_front()
	_execute_opponent_action(next_action)

func _execute_opponent_action(action: Dictionary) -> void:
	if is_battle_over:
		return
	is_processing_opponent_action = true
	is_busy = true
	can_player_act = false
	set_controls_enabled(false)
	
	var action_type = str(action.get("type", ""))
	if action_type == "MOVE":
		var move_name = str(action.get("move_name", ""))
		var energy_spent = int(action.get("energy_spent", 0))
		var boosted = bool(action.get("boosted", false))
		
		var actor = get_active_enemy()
		var defender = get_active_player()
		
		if not actor or not defender:
			print("[OnlineBattle] ⚠️ Missing actor or defender for opponent action!")
			is_processing_opponent_action = false
			is_busy = false
			end_enemy_turn()
			return
		
		var move = null
		if actor.moves:
			for m in actor.moves:
				if m and m.name == move_name:
					move = m
					break
			if not move and actor.moves.size() > 0:
				move = actor.moves[0]
				
		if not move:
			print("[OnlineBattle] ⚠️ Opponent move '%s' not found on active enemy!" % move_name)
			is_processing_opponent_action = false
			is_busy = false
			end_enemy_turn()
			return
			
		perform_attack(actor, defender, move, boosted, energy_spent, enemy_card_img, player_card_img)
		
		var timer = get_tree().create_timer(2.4)
		timer.timeout.connect(func():
			if is_battle_over:
				is_processing_opponent_action = false
				is_busy = false
				return
			if is_enemy_fainting or is_player_fainting:
				var wait_t = get_tree().create_timer(0.4)
				wait_t.timeout.connect(func():
					if is_battle_over:
						is_processing_opponent_action = false
						is_busy = false
						return
					end_enemy_turn()
				)
				return
			end_enemy_turn()
		)
	elif action_type == "SWAP":
		var target_name = str(action.get("target_name", ""))
		var target_idx = -1
		if not target_name.is_empty():
			for i in range(enemy_team.size()):
				if i != active_enemy_idx and enemy_team[i].name == target_name and enemy_team[i].current_hp > 0:
					target_idx = i
					break
		if target_idx == -1:
			var benched_slot_idx = int(action.get("benched_slot_idx", 0))
			var benched_indices = get_benched_enemy_indices()
			if benched_slot_idx < benched_indices.size():
				target_idx = benched_indices[benched_slot_idx]
				
		if target_idx != -1 and target_idx < enemy_team.size():
			var current = get_active_enemy()
			active_enemy_idx = target_idx
			var target_pkmn = enemy_team[target_idx]
			log_action("🌐 %s withdraws [b]%s[/b] and sends out [b]%s[/b]!" % [GameData.online_rival_name, current.name, target_pkmn.name])
			
			var orig_e_pos = enemy_card_img.position
			if enemy_card_img.has_meta("original_pos"): orig_e_pos = enemy_card_img.get_meta("original_pos")
			else: enemy_card_img.set_meta("original_pos", orig_e_pos)
			
			update_ui()
			set_controls_enabled(false)
			enemy_card_img.position = orig_e_pos + Vector2(0, -35.0)
			enemy_card_img.modulate = Color(1.0, 1.0, 1.0, 0.0)
			GameData.play_combat_sfx("switch")
			var sw_tween = create_tween()
			sw_tween.set_parallel(true)
			sw_tween.tween_property(enemy_card_img, "position:y", orig_e_pos.y, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			sw_tween.tween_property(enemy_card_img, "modulate:a", 1.0, 0.3)
			sw_tween.chain().finished.connect(func():
				if is_instance_valid(enemy_card_img):
					enemy_card_img.position = orig_e_pos
					enemy_card_img.modulate = Color.WHITE
			)
			
		var timer = get_tree().create_timer(1.8)
		timer.timeout.connect(func():
			if is_battle_over:
				is_processing_opponent_action = false
				is_busy = false
				return
			end_enemy_turn()
		)
	elif action_type == "RECHARGE":
		var actor = get_active_enemy()
		var rec = min(actor.recover_amount, actor.max_energy - actor.current_energy)
		actor.current_energy += rec
		log_action("🌐 %s charged energy (+%d ⚡)." % [GameData.online_rival_name, rec])
		update_ui()
		set_controls_enabled(false)
		var timer = get_tree().create_timer(1.6)
		timer.timeout.connect(func():
			if is_battle_over:
				is_processing_opponent_action = false
				is_busy = false
				return
			end_enemy_turn()
		)
	elif action_type == "SURRENDER":
		is_processing_opponent_action = false
		is_busy = false
		_on_online_opponent_surrender()

func _on_online_opponent_surrender() -> void:
	if is_battle_over:
		return
	is_battle_over = true
	show_game_over("🏆 VICTORY BY FORFEIT!", "Opponent %s has forfeited or left the battle." % GameData.online_rival_name)

func _setup_battle_hud_theme() -> void:
	var slate_box = StyleBoxTexture.new()
	slate_box.texture = load("res://assets/ui/frlg_frame_dark_slate.png")
	slate_box.texture_margin_left = 7
	slate_box.texture_margin_top = 7
	slate_box.texture_margin_right = 7
	slate_box.texture_margin_bottom = 7
	slate_box.content_margin_left = 12
	slate_box.content_margin_top = 10
	slate_box.content_margin_right = 12
	slate_box.content_margin_bottom = 10
	
	if has_node("MainContainer/EnemySection"):
		$MainContainer/EnemySection.add_theme_stylebox_override("panel", slate_box)
	if has_node("MainContainer/PlayerSection"):
		$MainContainer/PlayerSection.add_theme_stylebox_override("panel", slate_box)
		
	var diag_box = StyleBoxTexture.new()
	diag_box.texture = load("res://assets/ui/frlg_frame_dark_dialogue.png")
	diag_box.texture_margin_left = 7
	diag_box.texture_margin_top = 7
	diag_box.texture_margin_right = 7
	diag_box.texture_margin_bottom = 7
	diag_box.content_margin_left = 12
	diag_box.content_margin_top = 8
	diag_box.content_margin_right = 12
	diag_box.content_margin_bottom = 8
	
	if has_node("MainContainer/CenterLog"):
		$MainContainer/CenterLog.add_theme_stylebox_override("panel", diag_box)
		
	var enemy_card_style = StyleBoxFlat.new()
	enemy_card_style.bg_color = Color("#101822")
	enemy_card_style.border_color = Color("#2a6888")
	enemy_card_style.set_border_width_all(2)
	enemy_card_style.set_corner_radius_all(4)
	enemy_card_style.content_margin_left = 6
	enemy_card_style.content_margin_top = 4
	enemy_card_style.content_margin_right = 6
	enemy_card_style.content_margin_bottom = 4
	
	if enemy_bench_1:
		enemy_bench_1.add_theme_stylebox_override("panel", enemy_card_style)
	if enemy_bench_2:
		enemy_bench_2.add_theme_stylebox_override("panel", enemy_card_style)
		
	# Estilo GBA para botones de ataque Move 1 y Move 2
	var move_btn_style = StyleBoxFlat.new()
	move_btn_style.bg_color = Color("#121c28")
	move_btn_style.border_color = Color("#2a6888")
	move_btn_style.set_border_width_all(2)
	move_btn_style.set_corner_radius_all(6)
	move_btn_style.content_margin_left = 8
	move_btn_style.content_margin_right = 8
	move_btn_style.content_margin_top = 6
	move_btn_style.content_margin_bottom = 6
	
	var move_btn_hover = move_btn_style.duplicate()
	move_btn_hover.border_color = Color("#ff9800")
	move_btn_hover.bg_color = Color("#18283a")
	
	if btn_move1:
		btn_move1.add_theme_stylebox_override("normal", move_btn_style)
		btn_move1.add_theme_stylebox_override("hover", move_btn_hover)
	if btn_move2:
		btn_move2.add_theme_stylebox_override("normal", move_btn_style)
		btn_move2.add_theme_stylebox_override("hover", move_btn_hover)
		
	# Estilo GBA para botón Back del TopBar
	var back_btn_style = StyleBoxFlat.new()
	back_btn_style.bg_color = Color("#121b26")
	back_btn_style.border_color = Color("#386888")
	back_btn_style.set_border_width_all(2)
	back_btn_style.set_corner_radius_all(5)
	if btn_back_menu:
		btn_back_menu.add_theme_stylebox_override("normal", back_btn_style)
		var back_hover = back_btn_style.duplicate()
		back_hover.border_color = Color("#ff9800")
		btn_back_menu.add_theme_stylebox_override("hover", back_hover)
		
	# Estilo GBA para botón Tabla Tipos del TopBar
	var tc_btn_style = StyleBoxFlat.new()
	tc_btn_style.bg_color = Color("#142232")
	tc_btn_style.border_color = Color("#4a8bb8")
	tc_btn_style.set_border_width_all(2)
	tc_btn_style.set_corner_radius_all(5)
	if btn_type_chart:
		btn_type_chart.add_theme_stylebox_override("normal", tc_btn_style)
		var tc_hover = tc_btn_style.duplicate()
		tc_hover.border_color = Color("#ffd700")
		tc_hover.bg_color = Color("#1c324a")
		btn_type_chart.add_theme_stylebox_override("hover", tc_hover)
		
	# Estilo GBA para botón Speed del TopBar
	var spd_btn_style = StyleBoxFlat.new()
	spd_btn_style.bg_color = Color("#142232")
	spd_btn_style.border_color = Color("#3880a8")
	spd_btn_style.set_border_width_all(2)
	spd_btn_style.set_corner_radius_all(5)
	if btn_speed:
		btn_speed.add_theme_stylebox_override("normal", spd_btn_style)
		var spd_hover = spd_btn_style.duplicate()
		spd_hover.border_color = Color("#40c4ff")
		spd_hover.bg_color = Color("#1a3048")
		btn_speed.add_theme_stylebox_override("hover", spd_hover)
		
	var btn_info_node = $MainContainer/TopBar.get_node_or_null("BtnDetailsInfo") if has_node("MainContainer/TopBar") else null
	if btn_info_node:
		btn_info_node.add_theme_stylebox_override("normal", spd_btn_style.duplicate())
		var info_hover = spd_btn_style.duplicate()
		info_hover.border_color = Color("#81c784")
		info_hover.bg_color = Color("#1a3528")
		btn_info_node.add_theme_stylebox_override("hover", info_hover)
		
	# Estilo para el modal de la Tabla de Tipos
	var tc_diag_box = StyleBoxTexture.new()
	tc_diag_box.texture = load("res://assets/ui/frlg_frame_dark_dialogue.png")
	tc_diag_box.texture_margin_left = 8
	tc_diag_box.texture_margin_top = 8
	tc_diag_box.texture_margin_right = 8
	tc_diag_box.texture_margin_bottom = 8
	if type_chart_panel:
		type_chart_panel.add_theme_stylebox_override("panel", tc_diag_box)
		
	var tc_sub_sb = StyleBoxFlat.new()
	tc_sub_sb.bg_color = Color(0.08, 0.12, 0.18, 0.95)
	tc_sub_sb.border_color = Color(0.25, 0.45, 0.65, 0.8)
	tc_sub_sb.set_border_width_all(1)
	tc_sub_sb.set_corner_radius_all(4)
	if type_chart_matchup_panel:
		type_chart_matchup_panel.add_theme_stylebox_override("panel", tc_sub_sb)

	var tc_grid_sb = StyleBoxFlat.new()
	tc_grid_sb.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	tc_grid_sb.border_color = Color(0.2, 0.3, 0.4, 0.8)
	tc_grid_sb.set_border_width_all(1)
	tc_grid_sb.set_corner_radius_all(4)
	if type_chart_grid_panel:
		type_chart_grid_panel.add_theme_stylebox_override("panel", tc_grid_sb)

	var tc_detail_sb = StyleBoxFlat.new()
	tc_detail_sb.bg_color = Color(0.07, 0.10, 0.15, 0.9)
	tc_detail_sb.border_color = Color(0.2, 0.35, 0.5, 0.6)
	tc_detail_sb.set_border_width_all(1)
	tc_detail_sb.set_corner_radius_all(4)
	if type_chart_detail_panel:
		type_chart_detail_panel.add_theme_stylebox_override("panel", tc_detail_sb)

	var tc_inc_sb = StyleBoxFlat.new()
	tc_inc_sb.bg_color = Color(0.06, 0.08, 0.12, 0.8)
	tc_inc_sb.border_color = Color(0.2, 0.28, 0.38, 0.5)
	tc_inc_sb.set_border_width_all(1)
	tc_inc_sb.set_corner_radius_all(4)
	if type_chart_inc_panel:
		type_chart_inc_panel.add_theme_stylebox_override("panel", tc_inc_sb)
		
	# Estilo GBA para botones de opciones (Recharge, Bag)
	var opt_btn_style = StyleBoxFlat.new()
	opt_btn_style.bg_color = Color("#121b26")
	opt_btn_style.border_color = Color("#2a6080")
	opt_btn_style.set_border_width_all(2)
	opt_btn_style.set_corner_radius_all(6)
	opt_btn_style.content_margin_left = 10
	opt_btn_style.content_margin_right = 10
	opt_btn_style.content_margin_top = 4
	opt_btn_style.content_margin_bottom = 4
	
	var opt_hover = opt_btn_style.duplicate()
	opt_hover.border_color = Color("#ff9800")
	opt_hover.bg_color = Color("#18283a")
	
	if btn_recover:
		btn_recover.add_theme_stylebox_override("normal", opt_btn_style)
		btn_recover.add_theme_stylebox_override("hover", opt_hover)
	if btn_bag:
		btn_bag.add_theme_stylebox_override("normal", opt_btn_style)
		btn_bag.add_theme_stylebox_override("hover", opt_hover)
		
	# Estilo de píldora para TurnBadge
	var tb_style = StyleBoxFlat.new()
	tb_style.bg_color = Color("#0e1622")
	tb_style.border_color = Color("#285878")
	tb_style.set_border_width_all(1)
	tb_style.set_corner_radius_all(4)
	tb_style.content_margin_left = 10
	tb_style.content_margin_right = 10
	tb_style.content_margin_top = 3
	tb_style.content_margin_bottom = 3
	if turn_badge:
		turn_badge.add_theme_stylebox_override("normal", tb_style)

func _apply_hp_bar_styles(bar: ProgressBar, cur_hp: int, max_hp: int) -> void:
	if not bar:
		return
	bar.max_value = max(1, max_hp)
	bar.value = max(0, cur_hp)
	
	# Background style: Dark empty slot (canal de drenaje visible)
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color("#181c22")
	bg.border_color = Color("#3e4656")
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", bg)
	
	# Fill style: Verde (> 50%) / Amarillo (<= 50%) / Rojo (<= 20%)
	var ratio = float(cur_hp) / float(max(1, max_hp))
	var fill_color = Color("#58d858")
	var highlight = Color("#88f888")
	if ratio <= 0.2:
		fill_color = Color("#e83030") # Rojo crítico
		highlight = Color("#f87070")
	elif ratio <= 0.5:
		fill_color = Color("#f8b030") # Amarillo precaución
		highlight = Color("#f8e070")
		
	var fill = StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.border_color = highlight
	fill.border_width_top = 1
	fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", fill)

func _update_bench_button(btn: Button, team: Array, benched_indices: Array, slot_idx: int) -> void:
	if not btn:
		return
	if slot_idx >= benched_indices.size():
		btn.visible = false
		return
		
	btn.visible = true
	var pkmn = team[benched_indices[slot_idx]]
	var is_alive = (pkmn.current_hp > 0)
	var allowed = _is_turn_action_allowed() and is_alive
	btn.disabled = not allowed
	btn.text = ""
	
	var pb = btn.get_node_or_null("CardContent/Pokeball")
	if pb:
		pb.texture = load("res://assets/ui/pokeball_faint.png") if not is_alive else (load("res://assets/ui/pokeball_active.png") if allowed else load("res://assets/ui/pokeball_normal.png"))
		
	var ico = btn.get_node_or_null("CardContent/Details/Header/TypeIcon")
	if ico:
		ico.texture = GameData.get_type_icon_texture(pkmn.type)
		
	var n_lbl = btn.get_node_or_null("CardContent/Details/Header/Name")
	if n_lbl:
		n_lbl.text = pkmn.name
		n_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		n_lbl.clip_text = true
		n_lbl.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0) if is_alive else Color(0.6, 0.6, 0.6))
		
	var active_opp = get_active_enemy() if team == player_team else get_active_player()
	var spd_val = get_pokemon_effective_speed(pkmn, active_opp)
	var spd_lbl = btn.get_node_or_null("CardContent/Details/Header/SpdText")
	if not spd_lbl:
		var header = btn.get_node_or_null("CardContent/Details/Header")
		if header:
			spd_lbl = Label.new()
			spd_lbl.name = "SpdText"
			spd_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			spd_lbl.add_theme_font_size_override("font_size", 10)
			spd_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			header.add_child(spd_lbl)
	if spd_lbl:
		spd_lbl.text = "SPD: %d" % spd_val
		spd_lbl.add_theme_color_override("font_color", Color(0.45, 0.85, 1.0) if is_alive else Color(0.5, 0.5, 0.5))
		
	var hp_bar = btn.get_node_or_null("CardContent/Details/HPSection/MiniHPBar")
	if hp_bar:
		_apply_hp_bar_styles(hp_bar, pkmn.current_hp, pkmn.max_hp)
		
	var hp_lbl = btn.get_node_or_null("CardContent/Details/HPSection/HPText")
	if hp_lbl:
		if not is_alive:
			hp_lbl.text = "💀 KO"
			hp_lbl.add_theme_color_override("font_color", Color("#e84040"))
		else:
			hp_lbl.text = "%d/%d" % [pkmn.current_hp, pkmn.max_hp]
			hp_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
			
	_update_bench_card_style(btn, allowed, is_alive)

func _update_enemy_bench_card(card: PanelContainer, team: Array, benched_indices: Array, slot_idx: int) -> void:
	if not card:
		return
	if slot_idx >= benched_indices.size():
		card.visible = false
		return
		
	card.visible = true
	var pkmn = team[benched_indices[slot_idx]]
	var is_alive = (pkmn.current_hp > 0)
	
	var pb = card.get_node_or_null("CardContent/Pokeball")
	if pb:
		pb.texture = load("res://assets/ui/pokeball_faint.png") if not is_alive else load("res://assets/ui/pokeball_normal.png")
		
	var ico = card.get_node_or_null("CardContent/Details/Header/TypeIcon")
	if ico:
		ico.texture = GameData.get_type_icon_texture(pkmn.type)
		
	var n_lbl = card.get_node_or_null("CardContent/Details/Header/Name")
	if n_lbl:
		n_lbl.text = pkmn.name
		n_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		n_lbl.clip_text = true
		n_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 0.95) if is_alive else Color(0.55, 0.55, 0.55))
		
	var active_opp = get_active_player()
	var spd_val = get_pokemon_effective_speed(pkmn, active_opp)
	var spd_lbl = card.get_node_or_null("CardContent/Details/Header/SpdText")
	if not spd_lbl:
		var header = card.get_node_or_null("CardContent/Details/Header")
		if header:
			spd_lbl = Label.new()
			spd_lbl.name = "SpdText"
			spd_lbl.add_theme_font_size_override("font_size", 10)
			spd_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			header.add_child(spd_lbl)
	if spd_lbl:
		spd_lbl.text = "SPD: %d" % spd_val
		spd_lbl.add_theme_color_override("font_color", Color(0.45, 0.85, 1.0) if is_alive else Color(0.5, 0.5, 0.5))
		
	var hp_bar = card.get_node_or_null("CardContent/Details/HPSection/MiniHPBar")
	if hp_bar:
		_apply_hp_bar_styles(hp_bar, pkmn.current_hp, pkmn.max_hp)
		
	var hp_lbl = card.get_node_or_null("CardContent/Details/HPSection/HPText")
	if hp_lbl:
		if not is_alive:
			hp_lbl.text = "💀 KO"
			hp_lbl.add_theme_color_override("font_color", Color("#e84040"))
		else:
			hp_lbl.text = "%d/%d" % [pkmn.current_hp, pkmn.max_hp]
			hp_lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95))

func _update_bench_card_style(btn: Button, allowed: bool, is_alive: bool) -> void:
	var sb_norm = StyleBoxFlat.new()
	sb_norm.bg_color = Color("#121e2a") if is_alive else Color("#0e1318")
	sb_norm.border_color = Color("#ff9800") if allowed else (Color("#2a6888") if is_alive else Color("#262c36"))
	sb_norm.set_border_width_all(2)
	sb_norm.set_corner_radius_all(4)
	sb_norm.content_margin_left = 6
	sb_norm.content_margin_top = 4
	sb_norm.content_margin_right = 6
	sb_norm.content_margin_bottom = 4
	btn.add_theme_stylebox_override("normal", sb_norm)
	
	var sb_hover = sb_norm.duplicate()
	sb_hover.border_color = Color("#ff9800")
	sb_hover.bg_color = Color("#1c2e40")
	btn.add_theme_stylebox_override("hover", sb_hover)
	
	var sb_pressed = sb_norm.duplicate()
	sb_pressed.border_color = Color("#00e5ff")
	sb_pressed.bg_color = Color("#0c1620")
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	
	var sb_dis = sb_norm.duplicate()
	sb_dis.bg_color = Color("#0e1216")
	sb_dis.border_color = Color("#222830")
	btn.add_theme_stylebox_override("disabled", sb_dis)

func _format_status_list(pkmn) -> Array:
	var list = []
	if not pkmn:
		return list
	if pkmn.burn_turns > 0:
		list.append("🔥 Burn (%d)" % pkmn.burn_turns)
	if pkmn.is_poisoned:
		if pkmn.toxic_envenomed:
			list.append("☠️ Toxic (-1 DMG & tick)")
		else:
			list.append("🟣 Poison (-1 DMG)")
	if pkmn.is_flinched:
		list.append("💫 Flinch")
	if pkmn.is_frozen:
		list.append("❄️ Frozen (%d/2)" % pkmn.frozen_turns if pkmn.frozen_turns > 0 else "❄️ Frozen")
	if pkmn.is_asleep_turns > 0:
		list.append("💤 Asleep (%d)" % pkmn.is_asleep_turns)
	if pkmn.is_paralyzed:
		list.append("⚡ Paralyzed (%d)" % pkmn.paralyze_turns if pkmn.paralyze_turns > 0 else "⚡ Paralyzed")
	if pkmn.is_confused:
		list.append("🌀 Confused (%d/3)" % pkmn.confused_turns if pkmn.confused_turns > 0 else "🌀 Confused")
	if pkmn.is_constricted_dmg > 0:
		list.append("🪢 Trapped (%d DMG, %d)" % [pkmn.is_constricted_dmg, pkmn.constricted_turns])
	if pkmn.is_seeded_turns > 0:
		list.append("🌱 Seeded (%d)" % pkmn.is_seeded_turns)
	if pkmn.shield_reduction > 0:
		list.append("🛡️ Shield -%d (%d)" % [pkmn.shield_reduction, pkmn.shield_turns])
	if pkmn.wall_hp > 0:
		list.append("🧱 Wall (%d HP)" % pkmn.wall_hp)
	if pkmn.is_evasive:
		list.append("💨 Evasive")
	if pkmn.is_digging:
		list.append("⛏️ Underground")
	if pkmn.damage_buff > 0:
		list.append("⚔️ Buff +%d" % pkmn.damage_buff)
	return list

# --- ACTUALIZACIÓN DE INTERFAZ ---
func update_ui() -> void:
	if player_team.is_empty() or enemy_team.is_empty():
		return
		
	var active_e = get_active_enemy()
	var enemy_benched_idx = get_benched_enemy_indices()
	
	if enemy_card_img and enemy_card_img.has_method("setup"):
		enemy_card_img.setup(active_e, true)
	else:
		var e_tex = GameData.get_pokemon_texture(active_e.texture_path)
		if e_tex and enemy_card_img.texture != e_tex:
			enemy_card_img.texture = e_tex
			
	var active_p_peek = get_active_player()
	var e_pas = " | ✨ %s" % active_e.passive_name if active_e.has_passive else ""
	enemy_type_icon.texture = GameData.get_type_icon_texture(active_e.type)
	enemy_name_lbl.text = "%s (SPD: %d)" % [active_e.name, get_pokemon_effective_speed(active_e, active_p_peek)]
	var e_resists = GameData.get_effective_resistances(active_e.type, active_e.resistant)
	var e_res_str = ", ".join(e_resists) if not e_resists.is_empty() else "NONE"
	enemy_type_lbl.text = "Type: %s | Weak: %s | Res: %s%s" % [active_e.type, active_e.weakness, e_res_str, e_pas]
	
	enemy_bench_lbl.text = "👥 RIVAL'S BENCH:" if not enemy_benched_idx.is_empty() else "👥 RIVAL'S BENCH: (No reserves)"
	_update_enemy_bench_card(enemy_bench_1, enemy_team, enemy_benched_idx, 0)
	_update_enemy_bench_card(enemy_bench_2, enemy_team, enemy_benched_idx, 1)
	
	enemy_hp_bar.max_value = active_e.max_hp
	enemy_hp_bar.value = active_e.current_hp
	_apply_hp_bar_styles(enemy_hp_bar, active_e.current_hp, active_e.max_hp)
	enemy_hp_lbl.text = "%d / %d" % [active_e.current_hp, active_e.max_hp]
	enemy_energy_lbl.text = "Energy: " + get_energy_icons(active_e.current_energy, active_e.max_energy)
	enemy_status_lbl.text = " | ".join(_format_status_list(active_e))
	
	# Jugador
	var active_p = get_active_player()
	var player_benched_idx = get_benched_player_indices()
	
	if player_card_img and player_card_img.has_method("setup"):
		player_card_img.setup(active_p, false)
	else:
		var p_tex = GameData.get_pokemon_texture(active_p.texture_path)
		if p_tex and player_card_img.texture != p_tex:
			player_card_img.texture = p_tex
			
	var p_pas = " | ✨ %s" % active_p.passive_name if active_p.has_passive else ""
	player_type_icon.texture = GameData.get_type_icon_texture(active_p.type)
	player_name_lbl.text = "%s (SPD: %d)" % [active_p.name, get_pokemon_effective_speed(active_p, active_e)]
	var p_resists = GameData.get_effective_resistances(active_p.type, active_p.resistant)
	var p_res_str = ", ".join(p_resists) if not p_resists.is_empty() else "NONE"
	player_type_lbl.text = "Type: %s | Weak: %s | Res: %s%s" % [active_p.type, active_p.weakness, p_res_str, p_pas]
	
	var is_p2 = (not is_player_turn and GameData.is_pvp_mode)
	var active_benched_idx = enemy_benched_idx if is_p2 else player_benched_idx
	var active_bench_team = enemy_team if is_p2 else player_team
	
	player_bench_lbl.text = "👥 YOUR BENCH (SWITCH POKÉMON):" if not active_benched_idx.is_empty() else "👥 YOUR BENCH: (No reserves)"
	
	_update_bench_button(btn_switch_1, active_bench_team, active_benched_idx, 0)
	_update_bench_button(btn_switch_2, active_bench_team, active_benched_idx, 1)
		
	player_hp_bar.max_value = active_p.max_hp
	player_hp_bar.value = active_p.current_hp
	_apply_hp_bar_styles(player_hp_bar, active_p.current_hp, active_p.max_hp)
	player_hp_lbl.text = "%d / %d" % [active_p.current_hp, active_p.max_hp]
	player_energy_lbl.text = "Energy: " + get_energy_icons(active_p.current_energy, active_p.max_energy)
	
	# Barra de EXP en Campaña (oculta en Juego Libre)
	if GameData.is_campaign_mode and player_exp_box:
		player_exp_box.visible = true
		var req_exp = active_p.get_required_exp()
		if req_exp <= 0:
			player_exp_bar.max_value = 1
			player_exp_bar.value = 1
			player_exp_lbl.text = "⭐ EXP: MAX (Final Stage)"
			player_exp_lbl.add_theme_color_override("font_color", Color("#81D4FA"))
		else:
			player_exp_bar.max_value = req_exp
			player_exp_bar.value = min(req_exp, active_p.current_exp)
			var target_id = GameData.get_evolution_target_id(active_p.id)
			if active_p.current_exp >= req_exp:
				if target_id != -1 and GameData.is_pokemon_unlocked(target_id):
					var target_name = GameData.pokemon_catalog.get(target_id, {}).get("name", "evolution")
					player_exp_lbl.text = "⭐ EXP: %d / %d (Ready for %s!)" % [active_p.current_exp, req_exp, target_name]
					player_exp_lbl.add_theme_color_override("font_color", Color("#FFD700"))
				elif target_id != -1:
					var target_name = GameData.pokemon_catalog.get(target_id, {}).get("name", "evolution")
					player_exp_lbl.text = "🔒 EXP: %d / %d (Missing %s card)" % [active_p.current_exp, req_exp, target_name]
					player_exp_lbl.add_theme_color_override("font_color", Color("#FF8A80"))
				else:
					player_exp_lbl.text = "⭐ EXP: %d / %d (Ready)" % [active_p.current_exp, req_exp]
					player_exp_lbl.add_theme_color_override("font_color", Color("#FFD700"))
			else:
				player_exp_lbl.text = "⭐ EXP: %d / %d" % [active_p.current_exp, req_exp]
				player_exp_lbl.add_theme_color_override("font_color", Color("#64B5F6"))
	elif player_exp_box:
		player_exp_box.visible = false
	player_status_lbl.text = " | ".join(_format_status_list(active_p))
	
	if player_status_overlay and active_p:
		player_status_overlay.update_statuses(active_p)
	if enemy_status_overlay and active_e:
		enemy_status_overlay.update_statuses(active_e)
	
	update_move_button_labels()

func reset_selected_energy() -> void:
	selected_energy_move1 = -1
	selected_energy_move2 = -1

func get_move_effect_summary(move, boosted: bool) -> String:
	if not move:
		return ""
	var eff = move.effect_type
	var desc = move.description
	if eff == "BURN":
		if boosted and move.name == "Inferno":
			return "Severe Burn (3 DMG)"
		elif boosted or move.boost_applies_burn:
			return "Inflicts Burn (2 DMG)" if move.name in ["Burn Up", "Fire Fang", "Fire Blast"] else "Inflicts Burn (1 DMG)"
		return "Inflicts Burn"
	elif eff == "POISON":
		return "Inflicts Poison (-1 DMG)"
	elif eff == "POISON_IF_FASTER":
		return "Poison if faster"
	elif eff == "ENVENOM":
		return "Envenom (+1 round DMG)"
	elif eff == "FREEZE":
		return "Freezes foe"
	elif eff == "SLEEP":
		return "Puts foe to Sleep"
	elif eff == "PARALYZE":
		return "25% chance Paralyze"
	elif eff == "CONFUSION":
		return "Confuses foe"
	elif eff == "FLINCH":
		return "Inflicts Flinch" if boosted else "Chance to Flinch"
	elif eff == "CONSTRICT":
		return "Trap foe (%d DMG/rd)" % (2 if move.name == "Sand Tomb" else 1)
	elif eff == "SEEDED":
		return "Leech Seed (saps 2 HP)"
	elif eff == "LIFE_DRAIN":
		return "Drains 100% HP" if boosted else "Drains 50% HP"
	elif eff == "ANTI_TANK":
		return "Deals 50% foe's HP"
	elif eff == "WEAK_SPOT" or eff == "ADAPT":
		return "Hits foe's Weakness"
	elif eff == "DOUBLE_TYPE" or eff == "TRIPLE_TYPE":
		return "Multi-element attack"
	elif eff == "CRITICAL":
		return "25% Critical (+3 DMG)"
	elif eff == "MULTI_ATTACK":
		return "Hits = ⚡ spent (25% Crit)"
	elif eff in ["DOUBLE_HIT", "EXTRA_HIT"]:
		return "Chance to hit twice"
	elif eff == "RECOIL":
		return "No Recoil" if boosted else "25% Recoil DMG"
	elif eff == "SNOWBALL":
		return "+4 DMG consecutive"
	elif eff == "ROLLING":
		return "x2 DMG consecutive"
	elif eff in ["REVENGE", "RAGE"]:
		return "Bonus DMG if took hit"
	elif eff == "BOOST_IF_FASTER":
		return "+3 DMG if faster"
	elif eff == "BLAZE":
		return "+3 DMG vs Burn"
	elif eff == "BOOST_IF_PARALYZED":
		return "+4 DMG vs Paralyzed"
	elif eff == "OVERCHARGE":
		return "+6 DMG vs Paralyzed"
	elif eff in ["DOUBLE_DMG", "SHOCK"]:
		return "x2 DMG vs Poison"
	elif eff == "DROWN":
		return "+4 DMG vs Poison"
	elif eff == "BOOST_CONFUSED":
		return "+3 DMG vs Confused"
	elif eff == "BOOST_DMG_TYPE":
		if "FIGHTING" in desc.to_upper(): return "+3 vs Fighting"
		elif "GRASS" in desc.to_upper(): return "+2 vs Grass"
		elif "NORMAL" in desc.to_upper(): return "+2 vs Normal"
		return "Bonus vs Type"
	elif eff == "MISS":
		return "33% chance to miss"
	elif eff == "SHIELD_BREAKER":
		return "Charges +4 DMG next turn"
	elif eff in ["SHIELD", "BLOCK", "VEIL"]:
		return "Reduces incoming DMG"
	elif eff == "WALL":
		return "Absorbs 4 DMG & counters"
	elif eff in ["EVASIVE", "MIRAGE"]:
		return "Evades next attack"
	elif eff == "DIG":
		return "Digs underground"
	elif eff == "REST":
		return "Must rest next round"
	elif eff in ["DMG_BOOST", "RELAXED", "GROWING"]:
		return "Buffs attack DMG"
	elif eff in ["RUSH", "SPEED_UP"]:
		return "+2 Speed"
	elif eff in ["SLOW_FOE", "BLIND"]:
		return "Reduces foe's Speed"
	elif eff == "WEAKEN":
		return "Reduces foe's DMG"
	elif eff == "SLOW_USER":
		return "-2 Speed next round"
	elif eff in ["SUPPORT_BOOST", "COVER"]:
		return "Cures all status effects"
	elif eff == "TERRAIN_SET":
		return "+4 Grass DMG (2 rds)"
	elif eff == "SANDSTORM":
		return "2 DMG/rd to non-ground"
	elif eff == "BOOST_GROUND_TYPE":
		return "+4 Ground DMG (2 rds)"
	elif eff == "EARNINGS":
		return "+3 G in Campaign"
	elif eff == "RECYCLE":
		return "Restores bag item"
	elif eff == "METAMORPHOSIS":
		return "Transforms into foe"
	elif eff == "LOCK":
		return "Locks foe's last move"
	elif eff == "MEMORY_FADE":
		return "Annuls foe's next effect"
	elif eff == "PICHU_SHOCK":
		return "50% Recoil/Recharge"
	elif eff == "BOOST_DMG":
		return "+%d extra DMG" % move.boost_damage
	elif desc != "":
		return desc.substr(0, 28)
	return ""

func _create_slot_button(slot_val: int, current_selected: int, move_idx: int, is_affordable: bool, is_boost_slot: bool, label_text: String) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(28, 28)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 10)
	btn.text = label_text
	btn.focus_mode = Control.FOCUS_NONE
	
	var is_selected = (slot_val == current_selected)
	
	var sb = StyleBoxFlat.new()
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 0
	sb.content_margin_right = 0
	sb.content_margin_top = 0
	sb.content_margin_bottom = 0
	
	if not is_affordable:
		sb.bg_color = Color("#0f172a")
		if is_selected:
			sb.border_color = Color("#b45309")
			sb.set_border_width_all(1.5)
			btn.add_theme_color_override("font_color", Color("#d97706"))
			btn.add_theme_color_override("font_disabled_color", Color("#d97706"))
		else:
			sb.border_color = Color("#1e293b")
			sb.set_border_width_all(1)
			btn.add_theme_color_override("font_color", Color("#475569"))
			btn.add_theme_color_override("font_disabled_color", Color("#475569"))
	elif is_selected:
		if is_boost_slot:
			sb.bg_color = Color("#ea580c")
			sb.border_color = Color("#fde047")
			sb.set_border_width_all(2)
			btn.add_theme_color_override("font_color", Color("#ffffff"))
			btn.add_theme_color_override("font_hover_color", Color("#ffffff"))
			btn.add_theme_color_override("font_pressed_color", Color("#ffffff"))
		else:
			sb.bg_color = Color("#f59e0b")
			sb.border_color = Color("#ffffff")
			sb.set_border_width_all(2)
			btn.add_theme_color_override("font_color", Color("#0f172a"))
			btn.add_theme_color_override("font_hover_color", Color("#000000"))
			btn.add_theme_color_override("font_pressed_color", Color("#000000"))
	else:
		sb.bg_color = Color("#1e293b")
		sb.border_color = Color("#ea580c" if is_boost_slot else "#475569")
		sb.set_border_width_all(1)
		btn.add_theme_color_override("font_color", Color("#fb923c" if is_boost_slot else "#cbd5e1"))
		btn.add_theme_color_override("font_hover_color", Color("#ffffff"))
		
	var sb_hover = sb.duplicate()
	if is_selected:
		sb_hover.bg_color = sb.bg_color.lightened(0.12)
	elif is_affordable:
		sb_hover.bg_color = Color("#431407" if is_boost_slot else "#334155")
		sb_hover.border_color = Color("#f97316" if is_boost_slot else "#94a3b8")
		
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_stylebox_override("disabled", sb)
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	btn.disabled = not _is_turn_action_allowed() or not is_affordable
	
	btn.pressed.connect(func():
		if move_idx == 0:
			selected_energy_move1 = slot_val
		else:
			selected_energy_move2 = slot_val
		update_move_button_labels()
	)
	return btn

func update_single_move_ui(move_idx: int, move, slots_container: HBoxContainer, btn: Button, p, active_e, _is_boosted_unused: bool = false) -> void:
	if not move or not btn:
		return
		
	btn.icon = GameData.get_type_icon_texture(move.type)
	btn.expand_icon = true
	
	var base_cost = move.cost
	var min_cost = move.min_energy_req
	var has_boost = move.can_boost and move.boost_cost > 0
	var max_cost = base_cost + (move.boost_cost if has_boost else 0)
	var can_fraction = (base_cost > 0 and (min_cost < base_cost or has_boost))
	
	var current_selected = selected_energy_move1 if move_idx == 0 else selected_energy_move2
	
	if base_cost == 0:
		current_selected = 0
		if move_idx == 0: selected_energy_move1 = 0
		else: selected_energy_move2 = 0
	elif not can_fraction:
		current_selected = base_cost
		if move_idx == 0: selected_energy_move1 = base_cost
		else: selected_energy_move2 = base_cost
	else:
		if current_selected < min_cost or current_selected > max_cost:
			if p.current_energy >= base_cost:
				current_selected = base_cost
			elif p.current_energy >= min_cost:
				current_selected = min(p.current_energy, base_cost)
			else:
				current_selected = min_cost
		elif current_selected > p.current_energy and p.current_energy >= min_cost:
			current_selected = min(p.current_energy, base_cost)
			
		if move_idx == 0:
			selected_energy_move1 = current_selected
		else:
			selected_energy_move2 = current_selected

	if slots_container:
		for child in slots_container.get_children():
			slots_container.remove_child(child)
			child.queue_free()
			
		var req_cost_val = base_cost if base_cost > 0 else min_cost
		var cost_lbl = Label.new()
		cost_lbl.text = "Req: %d⚡" % req_cost_val
		cost_lbl.add_theme_font_size_override("font_size", 11)
		cost_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var is_enough = (p.current_energy >= min_cost)
		cost_lbl.add_theme_color_override("font_color", Color("#cbd5e1") if is_enough else Color("#f87171"))
		slots_container.add_child(cost_lbl)
		
		if base_cost == 0:
			var is_affordable = (p.current_energy >= min_cost)
			var slot_btn = _create_slot_button(0, current_selected, move_idx, is_affordable, false, "0⚡")
			slots_container.add_child(slot_btn)
		elif can_fraction:
			for slot_val in range(min_cost, max_cost + 1):
				var is_boost_slot = (slot_val > base_cost)
				var is_affordable = (p.current_energy >= slot_val)
				var label_text = ("🔥%d" if is_boost_slot else "%d⚡") % slot_val
				var slot_btn = _create_slot_button(slot_val, current_selected, move_idx, is_affordable, is_boost_slot, label_text)
				slots_container.add_child(slot_btn)
		else:
			var is_affordable = (p.current_energy >= base_cost)
			var slot_btn = _create_slot_button(base_cost, current_selected, move_idx, is_affordable, false, "%d⚡" % base_cost)
			slots_container.add_child(slot_btn)

	if p.current_energy < min_cost:
		btn.disabled = true
		if base_cost == 0:
			btn.text = "%s (%d DMG)\n[Cost: 0⚡ | Req: %d⚡]" % [move.name, move.base_damage, min_cost]
		elif can_fraction:
			btn.text = "%s (%d DMG)\n[Cost: %d⚡ | Min: %d⚡]" % [move.name, move.base_damage, base_cost, min_cost]
		else:
			btn.text = "%s (%d DMG)\n[Cost: %d⚡]" % [move.name, move.base_damage, base_cost]
		return
		
	btn.disabled = not _is_turn_action_allowed()
	
	var is_boosted = (current_selected > base_cost)
	
	if move.effect_type == "MULTI_ATTACK":
		var hits = max(1, current_selected)
		var per_hit_min = 4 if move.name == "Icicle Spear" else (3 if move.name in ["Bone Rush", "Fury Swipes"] else 2)
		var per_hit_max = 8 if move.name == "Icicle Spear" else (7 if move.name == "Bone Rush" else (6 if move.name == "Fury Swipes" else 5))
		var est_min = hits * per_hit_min
		var est_max = hits * per_hit_max
		var ko_tag = " ✨ Knockout!" if (active_e and est_min >= active_e.current_hp and active_e.current_hp > 0) else ""
		btn.text = "%s (%d Hit%s)%s\n[Uses: %d/%d⚡ • %d-%d DMG]" % [
			move.name, hits, "s" if hits > 1 else "", ko_tag, current_selected, base_cost, est_min, est_max
		]
	elif base_cost == 0:
		var dmg = calculate_predicted_damage(p, active_e, move, 0, false)
		var ko_tag = " ✨ Knockout!" if (active_e and dmg >= active_e.current_hp and active_e.current_hp > 0) else ""
		var type_tag = ""
		if active_e:
			if GameData.types_match(active_e.weakness, move.type):
				type_tag = " (+%d)" % WEAKNESS_BONUS
			elif GameData.is_attack_resisted(active_e.type, active_e.resistant, move.type):
				type_tag = " (-%d)" % RESISTANCE_REDUCTION
		btn.text = "%s (%d DMG)%s%s\n[Cost: 0⚡ | Req: %d⚡]" % [move.name, dmg, type_tag, ko_tag, min_cost]
	elif current_selected < base_cost:
		var dmg = calculate_predicted_damage(p, active_e, move, current_selected, false)
		var ko_tag = " ✨ Knockout!" if (active_e and dmg >= active_e.current_hp and active_e.current_hp > 0) else ""
		btn.text = "%s (%d DMG) [Partial]%s\n[Uses: %d/%d⚡]" % [
			move.name, dmg, ko_tag, current_selected, base_cost
		]
	elif is_boosted:
		var dmg = calculate_predicted_damage(p, active_e, move, current_selected, true)
		var ko_tag = " ✨ Knockout!" if (active_e and dmg >= active_e.current_hp and active_e.current_hp > 0) else ""
		btn.text = "%s (%d DMG) [BOOSTED 🔥]%s\n[Uses: %d⚡]" % [
			move.name, dmg, ko_tag, current_selected
		]
	else:
		var dmg = calculate_predicted_damage(p, active_e, move, current_selected, false)
		var ko_tag = " ✨ Knockout!" if (active_e and dmg >= active_e.current_hp and active_e.current_hp > 0) else ""
		var type_tag = ""
		if active_e:
			if GameData.types_match(active_e.weakness, move.type):
				type_tag = " (+%d)" % WEAKNESS_BONUS
			elif GameData.is_attack_resisted(active_e.type, active_e.resistant, move.type):
				type_tag = " (-%d)" % RESISTANCE_REDUCTION
		if can_fraction:
			btn.text = "%s (%d DMG)%s%s\n[Uses: %d/%d⚡]" % [
				move.name, dmg, type_tag, ko_tag, current_selected, base_cost
			]
		else:
			btn.text = "%s (%d DMG)%s%s\n[Cost: %d⚡]" % [
				move.name, dmg, type_tag, ko_tag, base_cost
			]

func update_move_button_labels() -> void:
	var is_p2 = (not is_player_turn and GameData.is_pvp_mode)
	var actor = get_active_enemy() if is_p2 else get_active_player()
	var defender = get_active_player() if is_p2 else get_active_enemy()
	if actor == null or actor.moves.is_empty():
		return
	var m1 = actor.moves[0]
	var m2 = actor.moves[1]
	
	update_single_move_ui(0, m1, move1_slots, btn_move1, actor, defender)
	update_single_move_ui(1, m2, move2_slots, btn_move2, actor, defender)
	
	move1_slots.visible = true
	move2_slots.visible = true
	
	# Botón Pasiva
	if actor.has_passive:
		btn_passive.visible = true
		if actor.passive_name == "Turtle Shell":
			if actor.took_damage_last_turn:
				btn_passive.text = "🛡️ Shell (1⚡)\n[Counter]"
				btn_passive.disabled = (actor.current_energy < 1) or not _is_turn_action_allowed()
			else:
				btn_passive.text = "🛡️ Shell\n[No damage taken]"
				btn_passive.disabled = true
		elif actor.passive_name == "Focus Energy":
			var att_spd = get_pokemon_effective_speed(actor, defender)
			var def_spd = get_pokemon_effective_speed(defender, actor)
			if att_spd > def_spd:
				btn_passive.text = "✨ Focus Energy\n[ACTIVE: +1 DMG]"
			else:
				btn_passive.text = "✨ Focus Energy\n[INACTIVE: SPD ≤ rival]"
			btn_passive.disabled = true
		elif actor.passive_name == "String Shot":
			btn_passive.text = "✨ String Shot\n[Passive: -1 SPD rival]"
			btn_passive.disabled = true
		elif actor.passive_name == "Charm":
			btn_passive.text = "✨ Charm\n[Passive: -1 DMG Normal]"
			btn_passive.disabled = true
		else:
			btn_passive.text = "✨ %s\n[Passive]" % actor.passive_name
			btn_passive.disabled = true
	else:
		btn_passive.visible = false
	
	chk_boost.visible = false
	btn_recover.text = "🔋 Recharge (+%d⚡)" % actor.recover_amount
	btn_recover.disabled = not _is_turn_action_allowed() or (actor.current_energy >= actor.max_energy)
	
	if btn_bag:
		btn_bag.visible = GameData.is_campaign_mode
		btn_bag.disabled = not _is_turn_action_allowed()
		if team_has_negative_status():
			btn_bag.text = "🎒 Bag ⚠️"
			btn_bag.modulate = Color(1.2, 0.95, 0.3)
		else:
			btn_bag.text = "🎒 Bag"
			btn_bag.modulate = Color.WHITE

func get_energy_icons(current: int, maximum: int) -> String:
	var s = ""
	for i in range(current):
		s += "⚡"
	for i in range(maximum - current):
		s += "⚪"
	return "%s (%d/%d)" % [s, current, maximum]

func set_controls_enabled(enabled: bool) -> void:
	var allow = enabled and _is_turn_action_allowed()
	btn_move1.disabled = not allow
	btn_move2.disabled = not allow
	chk_boost.disabled = not allow
	btn_recover.disabled = not allow
	btn_switch_1.disabled = not allow
	btn_switch_2.disabled = not allow
	if btn_bag:
		btn_bag.disabled = not allow
	if btn_passive:
		btn_passive.disabled = not allow
	if not allow and energy_modal:
		energy_modal.visible = false
	if not allow and bag_modal:
		bag_modal.visible = false
	if move1_slots:
		for child in move1_slots.get_children():
			if child is Button:
				child.disabled = not allow
	if move2_slots:
		for child in move2_slots.get_children():
			if child is Button:
				child.disabled = not allow
	if allow:
		update_move_button_labels()

func log_action(text: String) -> void:
	combat_history.append(text)
	if combat_history.size() > 2:
		combat_history.pop_front()
	if combat_history.size() == 1:
		log_label.text = "[center]" + combat_history[0] + "[/center]"
	else:
		log_label.text = "[center][color=#788a9c][font_size=11]%s[/font_size][/color]\n[font_size=13]%s[/font_size][/center]" % [combat_history[0], combat_history[1]]

func show_game_over(title: String, subtitle: String) -> void:
	if is_enemy_fainting or is_player_fainting:
		var t = get_tree().create_timer(0.65)
		t.timeout.connect(func():
			_show_game_over_internal(title, subtitle)
		)
		return
	_show_game_over_internal(title, subtitle)

func _show_game_over_internal(title: String, subtitle: String) -> void:
	set_controls_enabled(false)
	if details_modal and is_instance_valid(details_modal):
		details_modal.visible = false
	if energy_modal and is_instance_valid(energy_modal):
		energy_modal.visible = false
	if bag_modal and is_instance_valid(bag_modal):
		bag_modal.visible = false
	if type_chart_modal and is_instance_valid(type_chart_modal):
		type_chart_modal.visible = false
	if forfeit_modal and is_instance_valid(forfeit_modal):
		forfeit_modal.visible = false
	if tutorial_callout_modal and is_instance_valid(tutorial_callout_modal):
		tutorial_callout_modal.visible = false
	if game_over_panel:
		game_over_panel.z_index = 75
	game_over_title.text = title
	game_over_subtitle.text = subtitle
	game_over_panel.visible = true
	
	_apply_game_over_banner_styling(title)
	
	if GameData.is_tutorial_mode:
		btn_restart.visible = false
		btn_game_over_menu.text = "🏛️ Return to Campaign Hub"
	elif GameData.is_online_pvp:
		btn_restart.visible = false
		btn_game_over_menu.text = "⬅ Main Menu"
	elif GameData.last_adventure_episode_conquered:
		btn_restart.visible = false
		btn_game_over_menu.text = "🏆 Return to Campaign Hub"
	elif GameData.is_campaign_mode:
		btn_restart.visible = false
		if GameData.campaign_submode == "ADVENTURE":
			btn_game_over_menu.text = "⛺ Camp / Shop"
		else:
			if GameData.campaign_match_number > GameData.TOURNAMENT_TOTAL_MATCHES:
				btn_game_over_menu.text = "🏆 Complete Tournament"
			else:
				btn_game_over_menu.text = "⛺ Camp / Shop"
	elif GameData.campaign_submode == "ADVENTURE":
		btn_restart.visible = false
		btn_game_over_menu.text = "⬅ Return to Campaign Hub"
	else:
		btn_restart.visible = true
		btn_restart.text = "🔄 Rematch"
		btn_game_over_menu.text = "⬅ Main Menu"

func _apply_game_over_banner_styling(title: String) -> void:
	var title_upper = title.to_upper()
	var is_victory = (
		"VICTOR" in title_upper or 
		"WIN" in title_upper or 
		"CHAMPION" in title_upper or 
		"CONQUERED" in title_upper or 
		"COMPLETE" in title_upper or
		"🏆" in title or "🎉" in title or "🌟" in title
	)
	var is_defeat = (
		"DEFEAT" in title_upper or 
		"DERROTA" in title_upper or 
		"ELIMINAT" in title_upper or 
		"💀" in title
	)

	var card_sb = StyleBoxFlat.new()
	card_sb.set_corner_radius_all(12)
	card_sb.shadow_size = 16
	card_sb.shadow_offset = Vector2(0, 6)
	card_sb.shadow_color = Color(0, 0, 0, 0.75)

	if is_defeat and not is_victory:
		card_sb.bg_color = Color("#171118")
		card_sb.border_color = Color("#ef4444")
		card_sb.set_border_width_all(3)
		game_over_title.add_theme_color_override("font_color", Color("#fca5a5"))
		game_over_title.add_theme_color_override("font_shadow_color", Color(0.3, 0.05, 0.05, 0.9))
	else:
		card_sb.bg_color = Color("#101726")
		card_sb.border_color = Color("#f59e0b")
		card_sb.set_border_width_all(3)
		game_over_title.add_theme_color_override("font_color", Color("#fbbf24"))
		game_over_title.add_theme_color_override("font_shadow_color", Color(0.2, 0.15, 0.02, 0.9))

	game_over_title.add_theme_constant_override("shadow_offset_y", 2)
	game_over_title.add_theme_constant_override("shadow_offset_x", 0)

	game_over_subtitle.add_theme_color_override("font_color", Color("#f1f5f9"))
	game_over_subtitle.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	game_over_subtitle.add_theme_constant_override("shadow_offset_y", 1)
	game_over_subtitle.add_theme_constant_override("line_spacing", 4)

	if game_over_card:
		game_over_card.add_theme_stylebox_override("panel", card_sb)

	_style_game_over_buttons(is_victory)

func _style_game_over_buttons(is_victory: bool) -> void:
	if btn_restart:
		var r_normal = StyleBoxFlat.new()
		r_normal.bg_color = Color("#0d9488")
		r_normal.border_color = Color("#2dd4bf")
		r_normal.set_border_width_all(2)
		r_normal.set_corner_radius_all(8)
		r_normal.content_margin_left = 12
		r_normal.content_margin_right = 12
		r_normal.content_margin_top = 8
		r_normal.content_margin_bottom = 8
		
		var r_hover = StyleBoxFlat.new()
		r_hover.bg_color = Color("#14b8a6")
		r_hover.border_color = Color("#99f6e4")
		r_hover.set_border_width_all(2)
		r_hover.set_corner_radius_all(8)
		r_hover.content_margin_left = 12
		r_hover.content_margin_right = 12
		r_hover.content_margin_top = 8
		r_hover.content_margin_bottom = 8

		var r_pressed = StyleBoxFlat.new()
		r_pressed.bg_color = Color("#0f766e")
		r_pressed.border_color = Color("#2dd4bf")
		r_pressed.set_border_width_all(2)
		r_pressed.set_corner_radius_all(8)
		r_pressed.content_margin_left = 12
		r_pressed.content_margin_right = 12
		r_pressed.content_margin_top = 8
		r_pressed.content_margin_bottom = 8

		btn_restart.add_theme_stylebox_override("normal", r_normal)
		btn_restart.add_theme_stylebox_override("hover", r_hover)
		btn_restart.add_theme_stylebox_override("pressed", r_pressed)
		btn_restart.add_theme_color_override("font_color", Color.WHITE)
		btn_restart.add_theme_color_override("font_hover_color", Color.WHITE)

	if btn_game_over_menu:
		var m_normal = StyleBoxFlat.new()
		m_normal.bg_color = Color("#1e293b")
		m_normal.border_color = Color("#60a5fa") if is_victory else Color("#94a3b8")
		m_normal.set_border_width_all(2)
		m_normal.set_corner_radius_all(8)
		m_normal.content_margin_left = 12
		m_normal.content_margin_right = 12
		m_normal.content_margin_top = 8
		m_normal.content_margin_bottom = 8

		var m_hover = StyleBoxFlat.new()
		m_hover.bg_color = Color("#334155")
		m_hover.border_color = Color("#93c5fd") if is_victory else Color("#cbd5e1")
		m_hover.set_border_width_all(2)
		m_hover.set_corner_radius_all(8)
		m_hover.content_margin_left = 12
		m_hover.content_margin_right = 12
		m_hover.content_margin_top = 8
		m_hover.content_margin_bottom = 8

		var m_pressed = StyleBoxFlat.new()
		m_pressed.bg_color = Color("#0f172a")
		m_pressed.border_color = Color("#3b82f6") if is_victory else Color("#64748b")
		m_pressed.set_border_width_all(2)
		m_pressed.set_corner_radius_all(8)
		m_pressed.content_margin_left = 12
		m_pressed.content_margin_right = 12
		m_pressed.content_margin_top = 8
		m_pressed.content_margin_bottom = 8

		btn_game_over_menu.add_theme_stylebox_override("normal", m_normal)
		btn_game_over_menu.add_theme_stylebox_override("hover", m_hover)
		btn_game_over_menu.add_theme_stylebox_override("pressed", m_pressed)
		btn_game_over_menu.add_theme_color_override("font_color", Color.WHITE)
		btn_game_over_menu.add_theme_color_override("font_hover_color", Color.WHITE)

# --- ANIMACIONES VISUALES ---
func play_damage_hit(node: Control, attack_type: String, damage: int = 2) -> void:
	if not node:
		return
		
	# Detener animación previa si aún estaba activa en este nodo
	if node.has_meta("active_hit_tween"):
		var old_tw = node.get_meta("active_hit_tween")
		if is_instance_valid(old_tw) and old_tw.is_valid():
			old_tw.kill()
		node.modulate = Color.WHITE
		
	if node.has_meta("active_color_tween"):
		var old_col_tw = node.get_meta("active_color_tween")
		if is_instance_valid(old_col_tw) and old_col_tw.is_valid():
			old_col_tw.kill()
		node.modulate = Color.WHITE

	var original_pos = node.position
	if node.has_meta("original_pos"):
		original_pos = node.get_meta("original_pos")
	else:
		node.set_meta("original_pos", original_pos)

	var orig_scale = Vector2.ONE
	if node.has_meta("original_scale"):
		orig_scale = node.get_meta("original_scale")
	else:
		orig_scale = node.scale
		node.set_meta("original_scale", orig_scale)
	node.pivot_offset = node.size * 0.5

	var effective_dmg = max(1, damage)
	var hit_color = GameData.get_type_hit_color(attack_type)

	# 1. Escala dinámica del impacto físico (Shake + Squash/Stretch según el daño)
	# Daño bajo (1-3): 7-11px, oscilaciones suaves
	# Daño medio (4-7): 13-18px, sacudida firme
	# Daño alto (8-14): 20-29px, vibración intensa
	# Daño masivo (15+): 30-36px, impacto devastador con deformación squash/stretch
	var shake_px: float = clampf(6.5 + float(effective_dmg) * 1.65, 7.0, 36.0)

	var shake_tween = create_tween()
	node.set_meta("active_hit_tween", shake_tween)

	if effective_dmg >= 8:
		# Squash and stretch punch on heavy impacts
		var squash_x = clampf(1.0 + float(effective_dmg) * 0.007, 1.05, 1.15)
		var squash_y = clampf(1.0 - float(effective_dmg) * 0.006, 0.88, 0.95)
		shake_tween.tween_property(node, "scale", orig_scale * Vector2(squash_x, squash_y), 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		shake_tween.tween_property(node, "scale", orig_scale * Vector2(0.97, 1.03), 0.06)
		shake_tween.tween_property(node, "scale", orig_scale, 0.08)

	shake_tween.set_parallel(false)
	shake_tween.tween_property(node, "position", original_pos + Vector2(shake_px, 0), 0.038)
	shake_tween.tween_property(node, "position", original_pos - Vector2(shake_px * 0.85, 0), 0.038)
	shake_tween.tween_property(node, "position", original_pos + Vector2(shake_px * 0.65, 0), 0.035)
	shake_tween.tween_property(node, "position", original_pos - Vector2(shake_px * 0.45, 0), 0.035)
	shake_tween.tween_property(node, "position", original_pos + Vector2(shake_px * 0.25, 0), 0.032)
	shake_tween.tween_property(node, "position", original_pos - Vector2(shake_px * 0.12, 0), 0.03)
	shake_tween.tween_property(node, "position", original_pos, 0.03)
	shake_tween.finished.connect(func():
		if is_instance_valid(node):
			node.position = original_pos
			node.scale = orig_scale
	)

	# 2. Intensidad y frecuencia del destello de color elemental según el daño
	var color_tween = create_tween()
	node.set_meta("active_color_tween", color_tween)

	if effective_dmg <= 3:
		# Daño leve: destello suave lerpeado con blanco
		var soft_color = hit_color.lerp(Color.WHITE, 0.45)
		color_tween.tween_property(node, "modulate", soft_color, 0.05)
		color_tween.tween_property(node, "modulate", Color.WHITE, 0.08)
		color_tween.tween_property(node, "modulate", soft_color, 0.05)
		color_tween.tween_property(node, "modulate", Color.WHITE, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	elif effective_dmg < 8:
		# Daño moderado: destello elemental clásico
		color_tween.tween_property(node, "modulate", hit_color, 0.04)
		color_tween.tween_property(node, "modulate", hit_color.lerp(Color.WHITE, 0.35), 0.04)
		color_tween.tween_property(node, "modulate", hit_color, 0.04)
		color_tween.tween_property(node, "modulate", Color.WHITE, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		# Daño alto / crítico: flash blanco cegador inicial y saturación elemental vibrante
		var intense_color = Color(minf(1.0, hit_color.r * 1.5 + 0.15), minf(1.0, hit_color.g * 1.5 + 0.15), minf(1.0, hit_color.b * 1.5 + 0.15), 1.0)
		color_tween.tween_property(node, "modulate", Color(1.8, 1.8, 1.8, 1.0), 0.03)
		color_tween.tween_property(node, "modulate", intense_color, 0.04)
		color_tween.tween_property(node, "modulate", Color.WHITE, 0.03)
		color_tween.tween_property(node, "modulate", intense_color, 0.04)
		color_tween.tween_property(node, "modulate", hit_color, 0.05)
		color_tween.tween_property(node, "modulate", Color.WHITE, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	color_tween.finished.connect(func():
		if is_instance_valid(node):
			node.modulate = Color.WHITE
	)

func shake_node(node: Control, attack_type: String = "", damage: int = 0) -> void:
	if not node:
		return
	if attack_type != "":
		play_damage_hit(node, attack_type, damage)
		return
		
	var original_pos = node.position
	if node.has_meta("original_pos"):
		original_pos = node.get_meta("original_pos")
	else:
		node.set_meta("original_pos", original_pos)
		
	var shake_px = clampf(6.0 + float(damage) * 1.5, 6.0, 24.0) if damage > 0 else 7.0
	var tween = create_tween()
	tween.tween_property(node, "position", original_pos + Vector2(shake_px, 0), 0.04)
	tween.tween_property(node, "position", original_pos - Vector2(shake_px * 0.8, 0), 0.04)
	tween.tween_property(node, "position", original_pos + Vector2(shake_px * 0.5, 0), 0.035)
	tween.tween_property(node, "position", original_pos - Vector2(shake_px * 0.25, 0), 0.03)
	tween.tween_property(node, "position", original_pos, 0.03)
	tween.finished.connect(func():
		if is_instance_valid(node):
			node.position = original_pos
	)

func lunge_card(node: Control, is_upward: bool) -> void:
	var original_pos = node.position
	var offset = Vector2(0, -25 if is_upward else 25)
	var tween = create_tween()
	tween.tween_property(node, "position", original_pos + offset, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "position", original_pos, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

# Genera números saltarines flotantes de daño (rojo/dorado), curación (verde) o energía (ámbar)
func spawn_floating_combat_number(target_node: Control, amount: int, is_heal: bool, is_crit_or_weakness: bool = false, is_energy: bool = false) -> void:
	if amount == 0:
		return
	if not target_node or not is_instance_valid(target_node):
		return
	var container: Control = floating_numbers_layer if (floating_numbers_layer and is_instance_valid(floating_numbers_layer)) else self
	
	var label = Label.new()
	var val_abs = abs(amount)
	
	if is_energy:
		label.text = "+%d ⚡" % val_abs
		label.add_theme_color_override("font_color", Color("#FFD54F")) # Ámbar eléctrico energía
		label.add_theme_font_size_override("font_size", 26)
	elif is_heal:
		label.text = "+%d" % val_abs
		label.add_theme_color_override("font_color", Color("#00E676")) # Verde esmeralda curación
		label.add_theme_font_size_override("font_size", 26)
	elif is_crit_or_weakness:
		label.text = "-%d 💥" % val_abs
		label.add_theme_color_override("font_color", Color("#FFD700")) # Dorado brillante debilidad / crítico
		label.add_theme_font_size_override("font_size", 28)
	else:
		label.text = "-%d" % val_abs
		label.add_theme_color_override("font_color", Color("#FF3B30")) # Rojo vivo daño recibido
		label.add_theme_font_size_override("font_size", 24)
		
	# Borde grueso oscuro para máxima legibilidad sobre cualquier fondo
	label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.08, 0.95))
	label.add_theme_constant_override("outline_size", 8)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Coordenadas globales sobre el sprite objetivo
	var rect = target_node.get_global_rect()
	var center = rect.get_center()
	var jitter_x = randf_range(-16.0, 16.0)
	var jitter_y = randf_range(-10.0, 6.0)
	var start_pos = center + Vector2(-24.0 + jitter_x, -36.0 + jitter_y)
	
	label.global_position = start_pos
	label.pivot_offset = Vector2(24, 14)
	label.scale = Vector2(0.4, 0.4)
	label.modulate.a = 0.0
	
	container.add_child(label)
	
	var tw = create_tween()
	tw.set_parallel(true)
	# Entrada rápida, permanencia y desvanecimiento suave
	tw.tween_property(label, "modulate:a", 1.0, 0.08)
	tw.tween_property(label, "modulate:a", 0.0, 0.35).set_delay(0.45)
	
	# Impacto de escala elástica
	tw.tween_property(label, "scale", Vector2(1.35, 1.35), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15).set_delay(0.12)
	
	# Salto ascendente parabólico con leve deriva lateral
	var drift_x = randf_range(-20.0, 20.0)
	var end_y = start_pos.y - 48.0
	tw.tween_property(label, "global_position:y", end_y, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "global_position:x", start_pos.x + drift_x, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tw.chain().tween_callback(label.queue_free)

# Genera texto flotante con efectos visuales para avisos de combate (ej. "Already Asleep!", "No Effect!")
func spawn_floating_combat_text(target_node: Control, msg: String, color: Color = Color("#cbd5e1")) -> void:
	if msg.is_empty():
		return
	if not target_node or not is_instance_valid(target_node):
		return
	var container: Control = floating_numbers_layer if (floating_numbers_layer and is_instance_valid(floating_numbers_layer)) else self
	
	var label = Label.new()
	label.text = msg
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.08, 0.95))
	label.add_theme_constant_override("outline_size", 6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var rect = target_node.get_global_rect()
	var center = rect.get_center()
	var start_pos = center + Vector2(-36.0, -32.0)
	
	label.global_position = start_pos
	label.pivot_offset = Vector2(36, 12)
	label.scale = Vector2(0.5, 0.5)
	label.modulate.a = 0.0
	
	container.add_child(label)
	
	var tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(label, "modulate:a", 1.0, 0.1)
	tw.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.65)
	tw.tween_property(label, "scale", Vector2(1.15, 1.15), 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "scale", Vector2(1.0, 1.0), 0.15).set_delay(0.14)
	tw.tween_property(label, "global_position:y", start_pos.y - 42.0, 0.9).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.chain().tween_callback(label.queue_free)

# --- SISTEMA DE MOCHILA / ITEMS EN COMBATE ---
func team_has_negative_status() -> bool:
	for p in player_team:
		if p.current_hp > 0 and (p.burn_turns > 0 or p.is_poisoned or p.is_flinched):
			return true
	return false

func _on_bag_pressed() -> void:
	if not _is_turn_action_allowed():
		return
	selected_bag_item = ""
	bag_targets_section.visible = false
	bag_items_list.visible = true
	refresh_bag_items_ui()
	bag_modal.visible = true

func refresh_bag_items_ui() -> void:
	for child in bag_items_list.get_children():
		child.queue_free()
		
	var item_defs = [
		{
			"id": "potion",
			"name": "Potion",
			"desc": "Restores up to 10 HP to an active or benched Pokémon.",
			"icon": "potion"
		},
		{
			"id": "ether",
			"name": "Ether",
			"desc": "Restores up to 5 Energy (⚡) to an active or benched Pokémon.",
			"icon": "ether"
		},
		{
			"id": "remedy",
			"name": "Remedy",
			"desc": "Cures all negative status conditions (Burn, Poison, Flinch).",
			"icon": "remedy"
		},
		{
			"id": "revive",
			"name": "Revive",
			"desc": "Revives a fainted Pokémon with 50% max HP.",
			"icon": "revive"
		}
	]
	
	for item in item_defs:
		var item_id = item["id"]
		var stock = GameData.get_active_campaign_inventory().get(item_id, 0)
		
		var row = PanelContainer.new()
		var row_sb = StyleBoxFlat.new()
		row_sb.bg_color = Color("#182030")
		row_sb.border_color = Color("#2a3b50")
		row_sb.set_border_width_all(1)
		row_sb.set_corner_radius_all(6)
		row.add_theme_stylebox_override("panel", row_sb)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_bottom", 6)
		row.add_child(margin)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		margin.add_child(hbox)
		
		var icon_rect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(40, 40)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = GameData.get_item_texture(item["icon"])
		hbox.add_child(icon_rect)
		
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = "%s  (Stock: %d)" % [item["name"], stock]
		name_lbl.add_theme_font_size_override("font_size", 14)
		if stock > 0:
			if item_id == "remedy":
				name_lbl.add_theme_color_override("font_color", Color("#81C784"))
			elif item_id == "potion":
				name_lbl.add_theme_color_override("font_color", Color("#4DD0E1"))
			elif item_id == "ether":
				name_lbl.add_theme_color_override("font_color", Color("#CE93D8"))
			elif item_id == "revive":
				name_lbl.add_theme_color_override("font_color", Color("#FFE082"))
			else:
				name_lbl.add_theme_color_override("font_color", Color("#FFFFFF"))
		else:
			name_lbl.add_theme_color_override("font_color", Color("#8899AA"))
		info_vbox.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = item["desc"]
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 11)
		desc_lbl.add_theme_color_override("font_color", Color("#B0BEC5"))
		info_vbox.add_child(desc_lbl)
		
		var use_btn = Button.new()
		use_btn.custom_minimum_size = Vector2(85, 36)
		use_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		use_btn.text = "Use" if stock > 0 else "Empty"
		use_btn.disabled = (stock <= 0)
		use_btn.pressed.connect(func(): show_bag_targets(item_id))
		hbox.add_child(use_btn)
		
		bag_items_list.add_child(row)

func show_bag_targets(item_id: String) -> void:
	selected_bag_item = item_id
	bag_items_list.visible = false
	bag_targets_section.visible = true
	
	for child in bag_targets_container.get_children():
		child.queue_free()
		
	var item_display_name = item_id.capitalize()
	bag_target_prompt.text = "Select a Pokémon to use %s on:" % item_display_name
	
	for i in range(player_team.size()):
		var pkmn = player_team[i]
		var is_active = (i == active_player_idx)
		var role_tag = " [ACTIVE]" if is_active else " [BENCH]"
		
		var target_btn = Button.new()
		target_btn.custom_minimum_size = Vector2(0, 44)
		target_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		# Determinar status y aplicabilidad
		var status_str = ""
		var status_list = []
		if pkmn.burn_turns > 0:
			status_list.append("🔥 Burned")
		if pkmn.is_poisoned:
			status_list.append("🟣 Poisoned")
		if pkmn.is_paralyzed:
			status_list.append("⚡ Paralyzed")
		if pkmn.is_asleep_turns > 0:
			status_list.append("💤 Asleep")
		if pkmn.is_frozen:
			status_list.append("❄️ Frozen")
		if pkmn.is_confused:
			status_list.append("🌀 Confused")
		if pkmn.is_constricted_dmg > 0:
			status_list.append("🪢 Trapped")
		if pkmn.is_seeded_turns > 0:
			status_list.append("🌱 Seeded")
		if pkmn.is_flinched:
			status_list.append("💫 Flinched")
		if status_list.size() > 0:
			status_str = " | " + ", ".join(status_list)
			
		var can_apply = false
		var reason = ""
		
		if item_id == "remedy":
			if pkmn.current_hp <= 0:
				reason = " (Fainted)"
			elif status_list.is_empty():
				reason = " (No status)"
			else:
				can_apply = true
		elif item_id == "potion":
			if pkmn.current_hp <= 0:
				reason = " (Fainted)"
			elif pkmn.current_hp >= pkmn.max_hp:
				reason = " (Full HP)"
			else:
				can_apply = true
		elif item_id == "ether":
			if pkmn.current_hp <= 0:
				reason = " (Fainted)"
			elif pkmn.current_energy >= pkmn.max_energy:
				reason = " (Full Energy)"
			else:
				can_apply = true
		elif item_id == "revive":
			if pkmn.current_hp > 0:
				reason = " (Not fainted)"
			else:
				can_apply = true
				
		target_btn.text = " %s%s - HP: %d/%d | ⚡ %d/%d%s%s" % [pkmn.name, role_tag, pkmn.current_hp, pkmn.max_hp, pkmn.current_energy, pkmn.max_energy, status_str, reason]
		target_btn.disabled = not can_apply
		if can_apply:
			target_btn.add_theme_color_override("font_color", Color("#A5D6A7"))
			target_btn.pressed.connect(func(): apply_item_in_battle(item_id, i))
		else:
			target_btn.add_theme_color_override("font_color", Color("#78909C"))
			
		bag_targets_container.add_child(target_btn)
		
	# Botón para regresar a la lista de items
	var back_btn = Button.new()
	back_btn.custom_minimum_size = Vector2(0, 34)
	back_btn.text = "⬅ Back to Items"
	back_btn.pressed.connect(func():
		bag_targets_section.visible = false
		bag_items_list.visible = true
	)
	bag_targets_container.add_child(back_btn)

func apply_item_in_battle(item_id: String, target_idx: int) -> void:
	if not is_player_turn or is_busy:
		return
	if target_idx < 0 or target_idx >= player_team.size():
		return
		
	var inv = GameData.get_active_campaign_inventory()
	var stock = inv.get(item_id, 0)
	if stock <= 0:
		return
		
	inv[item_id] -= 1
	var target_pkmn = player_team[target_idx]
	bag_modal.visible = false
	
	var healed: int = 0
	var energy_recovered: int = 0
	if item_id == "remedy":
		target_pkmn.burn_turns = 0
		target_pkmn.is_poisoned = false
		target_pkmn.toxic_envenomed = false
		target_pkmn.is_paralyzed = false
		target_pkmn.paralyze_turns = 0
		target_pkmn.is_asleep_turns = 0
		target_pkmn.is_frozen = false
		target_pkmn.frozen_turns = 0
		target_pkmn.is_confused = false
		target_pkmn.confused_turns = 0
		target_pkmn.is_constricted_dmg = 0
		target_pkmn.constricted_turns = 0
		target_pkmn.is_seeded_turns = 0
		target_pkmn.foe_damage_debuff = 0
		target_pkmn.foe_damage_debuff_turns = 0
		target_pkmn.is_flinched = false
		log_action("[b]Trainer[/b] used [color=lightgreen]Remedy[/color] on [b]%s[/b]! All negative status conditions were cleansed! 🌿" % target_pkmn.name)
	elif item_id == "potion":
		healed = min(10, target_pkmn.max_hp - target_pkmn.current_hp)
		target_pkmn.current_hp += healed
		log_action("[b]Trainer[/b] used [color=cyan]Potion[/color] on [b]%s[/b], restoring [color=green]+%d HP[/color]! 🧪 (%d/%d)" % [target_pkmn.name, healed, target_pkmn.current_hp, target_pkmn.max_hp])
	elif item_id == "ether":
		energy_recovered = min(5, target_pkmn.max_energy - target_pkmn.current_energy)
		target_pkmn.current_energy += energy_recovered
		log_action("[b]Trainer[/b] used [color=#B388FF]Ether[/color] on [b]%s[/b], restoring [color=yellow]+%d Energy[/color]! ⚡ (%d/%d)" % [target_pkmn.name, energy_recovered, target_pkmn.current_energy, target_pkmn.max_energy])
	elif item_id == "revive":
		target_pkmn.current_hp = max(1, int(target_pkmn.max_hp * 0.5))
		healed = target_pkmn.current_hp
		log_action("[b]Trainer[/b] used [color=yellow]Revive[/color] on [b]%s[/b]! Revived with [color=green]%d HP[/color]! 💖" % [target_pkmn.name, target_pkmn.current_hp])
		
	# Sincronizar estado en campaña activa
	var active_team = GameData.get_active_campaign_team_state()
	if target_idx < active_team.size():
		active_team[target_idx]["current_hp"] = target_pkmn.current_hp
		active_team[target_idx]["burn_turns"] = target_pkmn.burn_turns
		active_team[target_idx]["is_poisoned"] = target_pkmn.is_poisoned
		active_team[target_idx]["is_flinched"] = target_pkmn.is_flinched
		
	play_heal_flash(target_idx)
	GameData.play_combat_sfx("use")
	if GameData.is_campaign_mode:
		GameData.add_daily_mission_progress("use_camp_items", 1)
	var heal_node: Control = player_card_img if target_idx == active_player_idx else (btn_switch_1 if target_idx == 1 else btn_switch_2)
	if healed > 0:
		spawn_floating_combat_number(heal_node, healed, true)
		if GameData.is_campaign_mode:
			GameData.add_daily_mission_progress("heal_hp", 1)
	elif energy_recovered > 0:
		spawn_floating_combat_number(heal_node, energy_recovered, false, false, true)
	update_ui()
	
	# Ceder el turno al usar el objeto
	can_player_act = false
	is_busy = true
	set_controls_enabled(false)
	var timer = get_tree().create_timer(1.8)
	timer.timeout.connect(func():
		if is_battle_over:
			return
		is_busy = false
		end_player_turn()
	)

func play_heal_flash(target_idx: int) -> void:
	var target_node: Control = null
	if target_idx == active_player_idx:
		target_node = player_card_img
	elif target_idx == 1:
		target_node = btn_switch_1
	elif target_idx == 2:
		target_node = btn_switch_2
	if not target_node:
		target_node = player_card_img
	if target_node:
		var tw = create_tween()
		tw.tween_property(target_node, "modulate", Color(0.4, 1.8, 0.6), 0.15)
		tw.tween_property(target_node, "modulate", Color.WHITE, 0.35)

# --- LÓGICA DE TABLA DE EFECTIVIDADES POR TIPO ---

func _on_type_chart_pressed() -> void:
	_update_type_chart_matchup()
	type_chart_modal.visible = true

func _build_type_chart_matrix() -> void:
	if not type_chart_matrix_grid:
		return
	for c in type_chart_matrix_grid.get_children():
		c.queue_free()
	type_chart_cell_buttons.clear()
	
	# Celda (0, 0): Esquina con etiqueta ejes
	var corner_btn = Button.new()
	corner_btn.custom_minimum_size = Vector2(46, 26)
	corner_btn.text = "⚔\\🛡"
	corner_btn.add_theme_font_size_override("font_size", 9)
	corner_btn.flat = true
	corner_btn.pressed.connect(func():
		type_chart_detail_lbl.text = "⚔️ [b]Rows:[/b] Attack Type | 🛡️ [b]Columns:[/b] Defender Type"
	)
	type_chart_matrix_grid.add_child(corner_btn)
	
	# Fila 0, Columnas 1..9: Encabezados de tipos defensores
	for def_type in TYPE_CHART_ORDER:
		var hdr_btn = Button.new()
		hdr_btn.custom_minimum_size = Vector2(46, 26)
		hdr_btn.flat = true
		var icon_tex = GameData.get_type_icon_texture(def_type)
		if icon_tex:
			hdr_btn.icon = icon_tex
			hdr_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hdr_btn.expand_icon = true
		else:
			hdr_btn.text = def_type.substr(0, 3)
			hdr_btn.add_theme_font_size_override("font_size", 9)
			
		var dt = def_type
		hdr_btn.pressed.connect(func():
			var w = GameData.get_default_weakness_for_type(dt)
			var r = GameData.get_default_resistance_for_type(dt)
			var w_str = TYPE_NAMES_EN.get(w, w) if (w != "" and w != "VARIABLE" and w != "NONE") else "None / Variable"
			var r_list = []
			if r != "" and r != "VARIABLE" and r != "NONE":
				r_list.append(TYPE_NAMES_EN.get(r, r))
			if dt != "NORMAL" and not r_list.has(TYPE_NAMES_EN.get(dt, dt)):
				r_list.append("%s (Natural)" % TYPE_NAMES_EN.get(dt, dt))
			var r_str = ", ".join(r_list) if not r_list.is_empty() else "None / Variable"
			type_chart_detail_lbl.text = "🛡️ [b]%s (Defender):[/b] Weak to [color=#69f0ae]%s (+2)[/color] | Resists [color=#ff8a80]%s (-2)[/color]" % [TYPE_NAMES_EN.get(dt, dt), w_str, r_str]
		)
		type_chart_matrix_grid.add_child(hdr_btn)
		
	# Filas 1..9: Tipos atacantes y celdas de intersección
	for atk_type in TYPE_CHART_ORDER:
		# Columna 0: Encabezado atacante
		var atk_btn = Button.new()
		atk_btn.custom_minimum_size = Vector2(46, 25)
		atk_btn.flat = true
		var atk_icon = GameData.get_type_icon_texture(atk_type)
		if atk_icon:
			atk_btn.icon = atk_icon
			atk_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			atk_btn.expand_icon = true
		else:
			atk_btn.text = atk_type.substr(0, 3)
			atk_btn.add_theme_font_size_override("font_size", 9)
			
		var at = atk_type
		atk_btn.pressed.connect(func():
			type_chart_detail_lbl.text = "⚔️ [b]%s (Attack):[/b] Check row cells horizontally to see damage against each type." % TYPE_NAMES_EN.get(at, at)
		)
		type_chart_matrix_grid.add_child(atk_btn)
		
		# Columnas 1..9: Celdas de intersección
		for def_type in TYPE_CHART_ORDER:
			var cell_btn = Button.new()
			cell_btn.custom_minimum_size = Vector2(46, 25)
			
			var def_weakness = GameData.get_default_weakness_for_type(def_type)
			var def_resistance = GameData.get_default_resistance_for_type(def_type)
			
			var is_weak = GameData.types_match(def_weakness, atk_type)
			var is_resist = GameData.is_attack_resisted(def_type, def_resistance, atk_type)
			var is_same_type_resist = is_resist and not GameData.types_match(def_resistance, atk_type)
			
			var cell_sb = StyleBoxFlat.new()
			cell_sb.set_corner_radius_all(3)
			
			var dt = def_type
			var at_copy = atk_type
			
			if is_weak:
				cell_btn.text = "+2"
				cell_btn.add_theme_color_override("font_color", Color("#a7f3d0"))
				cell_btn.add_theme_font_size_override("font_size", 11)
				cell_sb.bg_color = Color(0.08, 0.35, 0.18, 0.95)
				cell_sb.border_color = Color(0.2, 0.7, 0.4, 0.9)
				cell_sb.set_border_width_all(1)
				cell_btn.pressed.connect(func():
					type_chart_detail_lbl.text = "⚔️ [color=#ffab91]%s[/color] vs 🛡️ [color=#80deea]%s[/color]: [color=#69f0ae][b]SUPER EFFECTIVE! (+2 DMG)[/b][/color]" % [TYPE_NAMES_EN.get(at_copy, at_copy), TYPE_NAMES_EN.get(dt, dt)]
				)
			elif is_resist:
				cell_btn.text = "-2"
				cell_btn.add_theme_color_override("font_color", Color("#fca5a5"))
				cell_btn.add_theme_font_size_override("font_size", 11)
				cell_sb.bg_color = Color(0.38, 0.12, 0.12, 0.95)
				cell_sb.border_color = Color(0.75, 0.25, 0.25, 0.9)
				cell_sb.set_border_width_all(1)
				cell_btn.pressed.connect(func():
					if is_same_type_resist:
						type_chart_detail_lbl.text = "⚔️ [color=#ffab91]%s[/color] vs 🛡️ [color=#80deea]%s[/color]: [color=#ff8a80][b]RESISTED! (-2 DMG)[/b][/color] (Natural same-type resistance)" % [TYPE_NAMES_EN.get(at_copy, at_copy), TYPE_NAMES_EN.get(dt, dt)]
					else:
						type_chart_detail_lbl.text = "⚔️ [color=#ffab91]%s[/color] vs 🛡️ [color=#80deea]%s[/color]: [color=#ff8a80][b]RESISTED! (-2 DMG)[/b][/color]" % [TYPE_NAMES_EN.get(at_copy, at_copy), TYPE_NAMES_EN.get(dt, dt)]
				)
			else:
				cell_btn.text = "·"
				cell_btn.add_theme_color_override("font_color", Color(0.4, 0.48, 0.58, 0.8))
				cell_btn.add_theme_font_size_override("font_size", 12)
				cell_sb.bg_color = Color(0.10, 0.13, 0.18, 0.7)
				cell_sb.border_color = Color(0.16, 0.22, 0.28, 0.4)
				cell_sb.set_border_width_all(1)
				cell_btn.pressed.connect(func():
					if at_copy == "NORMAL" and dt == "NORMAL":
						type_chart_detail_lbl.text = "⚔️ [color=#ffab91]NORMAL[/color] vs 🛡️ [color=#80deea]NORMAL[/color]: Standard neutral damage (Normal types do not resist Normal attacks)."
					else:
						type_chart_detail_lbl.text = "⚔️ [color=#ffab91]%s[/color] vs 🛡️ [color=#80deea]%s[/color]: Standard neutral damage (no bonus/reduction)." % [TYPE_NAMES_EN.get(at_copy, at_copy), TYPE_NAMES_EN.get(dt, dt)]
				)
				
			cell_btn.add_theme_stylebox_override("normal", cell_sb)
			cell_btn.add_theme_stylebox_override("hover", cell_sb)
			cell_btn.add_theme_stylebox_override("pressed", cell_sb)
			
			var cell_key = "%s_%s" % [GameData.normalize_type_key(atk_type), GameData.normalize_type_key(def_type)]
			type_chart_cell_buttons[cell_key] = {
				"btn": cell_btn,
				"base_sb": cell_sb,
				"is_weak": is_weak,
				"is_resist": is_resist,
				"is_same_type_resist": is_same_type_resist,
				"atk": atk_type,
				"def": def_type
			}
			type_chart_matrix_grid.add_child(cell_btn)

func _update_type_chart_matchup() -> void:
	if not type_chart_matchup_body:
		return
	var active_p = get_active_player()
	var active_e = get_active_enemy()
	if not active_p or not active_e:
		type_chart_matchup_body.text = "Start the battle to view active matchup."
		return
		
	var p_type = GameData.normalize_type_key(str(active_p.type))
	var e_type = GameData.normalize_type_key(str(active_e.type))
	
	var p_weak = str(active_p.weakness)
	var p_res = str(active_p.resistant)
	var e_weak = str(active_e.weakness)
	var e_res = str(active_e.resistant)
	
	var p_weak_str = TYPE_NAMES_EN.get(p_weak, p_weak) if (p_weak != "NONE" and p_weak != "VARIABLE" and p_weak != "") else "None"
	var e_weak_str = TYPE_NAMES_EN.get(e_weak, e_weak) if (e_weak != "NONE" and e_weak != "VARIABLE" and e_weak != "") else "None"
	
	var p_res_list = []
	if p_res != "NONE" and p_res != "VARIABLE" and p_res != "":
		p_res_list.append(TYPE_NAMES_EN.get(p_res, p_res))
	if p_type != "NORMAL" and not p_res_list.has(TYPE_NAMES_EN.get(p_type, p_type)):
		p_res_list.append("%s (Natural)" % TYPE_NAMES_EN.get(p_type, p_type))
	var p_res_str = ", ".join(p_res_list) if not p_res_list.is_empty() else "None"

	var e_res_list = []
	if e_res != "NONE" and e_res != "VARIABLE" and e_res != "":
		e_res_list.append(TYPE_NAMES_EN.get(e_res, e_res))
	if e_type != "NORMAL" and not e_res_list.has(TYPE_NAMES_EN.get(e_type, e_type)):
		e_res_list.append("%s (Natural)" % TYPE_NAMES_EN.get(e_type, e_type))
	var e_res_str = ", ".join(e_res_list) if not e_res_list.is_empty() else "None"
	
	type_chart_matchup_body.text = "[b]Your Pokémon:[/b] [color=#66bb6a]%s (%s)[/color] ➔ Weak to: [color=#ff7043]%s (+2)[/color] | Resists: [color=#d7ccc8]%s (-2)[/color]\n[b]Rival:[/b] [color=#ff7043]%s (%s)[/color] ➔ Weak to: [color=#4fc3f7]%s (+2)[/color] | Resists: [color=#66bb6a]%s (-2)[/color]" % [
		active_p.name, TYPE_NAMES_EN.get(p_type, p_type), p_weak_str, p_res_str,
		active_e.name, TYPE_NAMES_EN.get(e_type, e_type), e_weak_str, e_res_str
	]
	
	# Restaurar estilos base de todas las celdas
	for key in type_chart_cell_buttons:
		var c_data = type_chart_cell_buttons[key]
		var btn: Button = c_data["btn"]
		var base_sb: StyleBoxFlat = c_data["base_sb"]
		btn.add_theme_stylebox_override("normal", base_sb)
		
	# Resaltar la celda donde el jugador ataca al rival (P -> E)
	var pe_key = "%s_%s" % [p_type, e_type]
	if type_chart_cell_buttons.has(pe_key):
		var pe_data = type_chart_cell_buttons[pe_key]
		var pe_btn: Button = pe_data["btn"]
		var pe_sb: StyleBoxFlat = pe_data["base_sb"].duplicate()
		pe_sb.border_color = Color("#ffd700") # Bright gold
		pe_sb.set_border_width_all(2)
		pe_btn.add_theme_stylebox_override("normal", pe_sb)
		
		var eff_text = "SUPER EFFECTIVE! (+2 DMG)" if pe_data["is_weak"] else ("RESISTED! (-2 DMG)" if pe_data["is_resist"] else "Standard Neutral Damage")
		if pe_data.get("is_same_type_resist", false):
			eff_text += " (Natural same-type)"
		type_chart_detail_lbl.text = "🎯 [b]%s[/b] (%s) attacking [b]%s[/b] (%s): [color=#ffd700]%s[/color]" % [
			active_p.name, TYPE_NAMES_EN.get(p_type, p_type), active_e.name, TYPE_NAMES_EN.get(e_type, e_type), eff_text
		]
		
	# Resaltar la celda donde el rival ataca al jugador (E -> P)
	var ep_key = "%s_%s" % [e_type, p_type]
	if type_chart_cell_buttons.has(ep_key) and ep_key != pe_key:
		var ep_data = type_chart_cell_buttons[ep_key]
		var ep_btn: Button = ep_data["btn"]
		var ep_sb: StyleBoxFlat = ep_data["base_sb"].duplicate()
		ep_sb.border_color = Color("#00e5ff") # Electric cyan
		ep_sb.set_border_width_all(2)
		ep_btn.add_theme_stylebox_override("normal", ep_sb)
