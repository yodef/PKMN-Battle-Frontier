extends Control

const AssembledCardScript = preload("res://scripts/assembled_card.gd")

# --- REFERENCIAS DE BOTONES DEL MENÚ ---
@onready var trainer_status_badge: Label = $ContentContainer/HeaderContainer/TrainerStatusBadge
@onready var btn_campaign: Button = $ContentContainer/MenuButtons/BtnCampaign
@onready var btn_quick_battle: Button = $ContentContainer/MenuButtons/BtnQuickBattle
@onready var btn_online_multiplayer: Button = $ContentContainer/MenuButtons/BtnOnlineMultiplayer
@onready var btn_collection: Button = $ContentContainer/MenuButtons/BtnCollection
@onready var btn_shop: Button = $ContentContainer/MenuButtons/BtnShop
@onready var btn_profile: Button = $ContentContainer/MenuButtons/AuxButtonsRow/BtnProfile
@onready var btn_settings: Button = $ContentContainer/MenuButtons/AuxButtonsRow/BtnSettings
@onready var btn_exit: Button = $ContentContainer/MenuButtons/BtnExit

# --- MODAL SELECCIÓN DE EQUIPO (COMBATE LIBRE Y CAMPAÑA) ---
@onready var team_select_modal: Control = $TeamSelectModal
@onready var team_select_title: Label = $TeamSelectModal/Box/Title
@onready var team_select_subtitle: Label = $TeamSelectModal/Box/Subtitle
@onready var team_select_tabs: HBoxContainer = $TeamSelectModal/Box/TabsContainer
@onready var btn_tab_player: Button = $TeamSelectModal/Box/TabsContainer/BtnTabPlayer
@onready var btn_tab_enemy: Button = $TeamSelectModal/Box/TabsContainer/BtnTabEnemy
@onready var btn_random_enemy: Button = $TeamSelectModal/Box/TabsContainer/BtnRandomEnemy
@onready var slot1_lbl: Label = $TeamSelectModal/Box/SlotsContainer/Slot1/Label
@onready var slot2_lbl: Label = $TeamSelectModal/Box/SlotsContainer/Slot2/Label
@onready var slot3_lbl: Label = $TeamSelectModal/Box/SlotsContainer/Slot3/Label
@onready var btn_team_sort_id: Button = $TeamSelectModal/Box/SortBar/BtnSortId
@onready var btn_team_sort_dex: Button = $TeamSelectModal/Box/SortBar/BtnSortDex
@onready var btn_team_sort_alpha: Button = $TeamSelectModal/Box/SortBar/BtnSortAlpha
@onready var btn_team_sort_rarity: Button = $TeamSelectModal/Box/SortBar/BtnSortRarity
@onready var btn_team_sort_evo: Button = $TeamSelectModal/Box/SortBar/BtnSortEvo
@onready var team_grid_cards: Container = $TeamSelectModal/Box/ScrollContainer/GridMargin/GridCards
@onready var btn_start_battle: Button = $TeamSelectModal/Box/Actions/BtnStartBattle
@onready var btn_clear_team: Button = $TeamSelectModal/Box/Actions/TeamActionsRow/BtnClearTeam
@onready var btn_close_team_select: Button = $TeamSelectModal/Box/Actions/TeamActionsRow/BtnCloseTeamSelect

# --- MODAL CAMPAIGN HUB (TUTORIAL, AVENTURA & POKÉMON STADIUM) ---
@onready var campaign_hub_modal: Control = $CampaignHubModal
@onready var tutorial_status_lbl: Label = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardTutorial/Margin/TutorialVBox/TutorialStatus
@onready var btn_hub_tutorial: Button = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardTutorial/Margin/TutorialVBox/BtnHubTutorial
@onready var adv_status_lbl: Label = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventure/Margin/AdvVBox/AdvStatus
@onready var btn_hub_adventure: Button = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventure/Margin/AdvVBox/BtnHubAdventure
@onready var tourn_status_lbl: Label = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardTournament/Margin/TournVBox/TournStatus
@onready var btn_hub_tournament: Button = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardTournament/Margin/TournVBox/BtnHubTournament
@onready var btn_stadium_guide: Button = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardTournament/Margin/TournVBox/BtnStadiumGuide
@onready var btn_close_campaign_hub: Button = $CampaignHubModal/Box/BtnCloseCampaignHub

# --- MODAL ADVENTURE EPISODES ---
@onready var adventure_episodes_modal: Control = $AdventureEpisodesModal
@onready var ep1_status_lbl: Label = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp1/Margin/Ep1VBox/Ep1Status
@onready var btn_hub_adventure_ep1: Button = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp1/Margin/Ep1VBox/BtnHubAdventureEp1
@onready var ep2_status_lbl: Label = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp2/Margin/Ep2VBox/Ep2Status
@onready var btn_hub_adventure_ep2: Button = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp2/Margin/Ep2VBox/BtnHubAdventureEp2
@onready var ep3_status_lbl: Label = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp3/Margin/Ep3VBox/Ep3Status
@onready var btn_hub_adventure_ep3: Button = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp3/Margin/Ep3VBox/BtnHubAdventureEp3
@onready var ep4_status_lbl: Label = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp4/Margin/Ep4VBox/Ep4Status
@onready var btn_hub_adventure_ep4: Button = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp4/Margin/Ep4VBox/BtnHubAdventureEp4
@onready var ep5_status_lbl: Label = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp5/Margin/Ep5VBox/Ep5Status
@onready var btn_hub_adventure_ep5: Button = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp5/Margin/Ep5VBox/BtnHubAdventureEp5
@onready var ep6_status_lbl: Label = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp6/Margin/Ep6VBox/Ep6Status
@onready var btn_hub_adventure_ep6: Button = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp6/Margin/Ep6VBox/BtnHubAdventureEp6
@onready var ep7_status_lbl: Label = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp7/Margin/Ep7VBox/Ep7Status
@onready var btn_hub_adventure_ep7: Button = $AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp7/Margin/Ep7VBox/BtnHubAdventureEp7
@onready var btn_close_adventure_episodes: Button = $AdventureEpisodesModal/Box/BtnCloseAdventureEpisodes

var adventure_ep5_routes_modal: Control = null
var ep5_route_cards: Dictionary = {}

var adventure_ep6_routes_modal: Control = null
var ep6_route_cards: Dictionary = {}

var adventure_ep7_routes_modal: Control = null
var ep7_route_cards: Dictionary = {}

var tutorial_confirm_modal: Control = null
var tutorial_confirm_title_lbl: Label = null
var tutorial_confirm_msg_lbl: Control = null
var btn_confirm_tutorial: Button = null
var btn_cancel_tutorial: Button = null

# --- MODAL CAMPAÑA (TORNEO POKÉMON & CAMPAMENTO) ---
const CampaignTrackDiagram = preload("res://scripts/campaign_track_diagram.gd")
var campaign_track_diagram: CampaignTrackDiagram = null

@onready var campaign_modal: Control = $CampaignModal
@onready var campaign_match_lbl: Label = $CampaignModal/Box/StatusCard/StatusRow/MatchLbl
@onready var campaign_gold_lbl: Label = $CampaignModal/Box/StatusCard/StatusRow/GoldLbl
@onready var campaign_team_list: VBoxContainer = $CampaignModal/Box/TeamScroll/TeamList
@onready var campaign_item_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox/PotionRow/ItemIcon
@onready var campaign_item_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox/PotionRow/ShopInfo/ItemCountLbl
@onready var btn_buy_potion: Button = $CampaignModal/Box/ShopSection/ShopVBox/PotionRow/BtnBuyPotion

@onready var campaign_super_potion_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox/SuperPotionRow/SuperPotionIcon
@onready var campaign_super_potion_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox/SuperPotionRow/SuperPotionInfo/SuperPotionCountLbl
@onready var btn_buy_super_potion: Button = $CampaignModal/Box/ShopSection/ShopVBox/SuperPotionRow/BtnBuySuperPotion

@onready var campaign_hyper_potion_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox/HyperPotionRow/HyperPotionIcon
@onready var campaign_hyper_potion_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox/HyperPotionRow/HyperPotionInfo/HyperPotionCountLbl
@onready var btn_buy_hyper_potion: Button = $CampaignModal/Box/ShopSection/ShopVBox/HyperPotionRow/BtnBuyHyperPotion

@onready var campaign_remedy_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox/RemedyRow/RemedyIcon
@onready var campaign_remedy_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox/RemedyRow/RemedyInfo/RemedyCountLbl
@onready var btn_buy_remedy: Button = $CampaignModal/Box/ShopSection/ShopVBox/RemedyRow/BtnBuyRemedy

@onready var campaign_poke_flute_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox.get_node_or_null("PokeFluteRow/PokeFluteIcon") as TextureRect
@onready var campaign_poke_flute_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox.get_node_or_null("PokeFluteRow/PokeFluteInfo/PokeFluteCountLbl") as Label
@onready var btn_buy_poke_flute: Button = $CampaignModal/Box/ShopSection/ShopVBox.get_node_or_null("PokeFluteRow/BtnBuyPokeFlute") as Button

@onready var campaign_ether_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox/EtherRow/EtherIcon
@onready var campaign_ether_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox/EtherRow/EtherInfo/EtherCountLbl
@onready var btn_buy_ether: Button = $CampaignModal/Box/ShopSection/ShopVBox/EtherRow/BtnBuyEther

@onready var campaign_revive_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox/ReviveRow/ReviveIcon
@onready var campaign_revive_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox/ReviveRow/ReviveInfo/ReviveCountLbl
@onready var btn_buy_revive: Button = $CampaignModal/Box/ShopSection/ShopVBox/ReviveRow/BtnBuyRevive
@onready var btn_start_campaign_battle: Button = $CampaignModal/Box/ActionsBox/BtnStartCampaignBattle
@onready var btn_change_campaign_team: Button = $CampaignModal/Box/ActionsBox/NavRow/BtnChangeCampaignTeam
@onready var btn_reset_campaign: Button = $CampaignModal/Box/ActionsBox/BtnResetCampaign
@onready var btn_close_campaign: Button = $CampaignModal/Box/ActionsBox/NavRow/BtnCloseCampaign
@onready var btn_camp_stadium_guide: Button = $CampaignModal/Box/ActionsBox/BtnCampStadiumGuide

# --- MODAL STADIUM GUIDE ---
@onready var stadium_guide_modal: Control = $StadiumGuideModal
@onready var btn_close_stadium_guide: Button = $StadiumGuideModal/Box/BtnCloseStadiumGuide
var _stadium_guide_return_modal: Control = null

# --- CAMP TOOLBAR & MODALS (SHOP, MOCHILA, INSPECTOR) ---
var camp_toolbar: HBoxContainer = null
var btn_camp_shop: Button = null
var btn_camp_bag: Button = null
var camp_shop_modal: Control = null
var camp_shop_gold_lbl: Label = null
var camp_shop_stones_list: VBoxContainer = null
var camp_bag_modal: Control = null
var camp_bag_items_view: VBoxContainer = null
var camp_bag_targets_view: VBoxContainer = null
var camp_bag_targets_container: VBoxContainer = null
var camp_bag_prompt_lbl: Label = null
var camp_bag_selected_item: String = ""
var camp_pokemon_inspector_modal: Control = null
var camp_evo_selector_modal: Control = null
var camp_evo_modal: Control = null
var camp_evo_title_lbl: Label = null
var camp_evo_sub_lbl: Label = null
var camp_evo_sprite: TextureRect = null
var camp_evo_stats_lbl: Label = null
var btn_camp_evo_continue: Button = null
var current_camp_evo_tween: Tween = null
var _camp_evo_queue: Array[Dictionary] = []
var _is_camp_evo_active: bool = false

# --- MODAL COLECCIÓN (CUADRÍCULA Y DETALLE) ---
@onready var collection_modal: Control = $CollectionModal
@onready var collection_grid_view: VBoxContainer = $CollectionModal/GridView
@onready var collection_detail_view: VBoxContainer = $CollectionModal/DetailView
@onready var collection_stats_lbl: Label = $CollectionModal/GridView/StatsLbl
@onready var btn_col_sort_id: Button = $CollectionModal/GridView/SortBar/BtnSortId
@onready var btn_col_sort_dex: Button = $CollectionModal/GridView/SortBar/BtnSortDex
@onready var btn_col_sort_alpha: Button = $CollectionModal/GridView/SortBar/BtnSortAlpha
@onready var btn_col_sort_rarity: Button = $CollectionModal/GridView/SortBar/BtnSortRarity
@onready var btn_col_sort_owned: Button = $CollectionModal/GridView/SortBar/BtnSortOwned
@onready var grid_cards: GridContainer = $CollectionModal/GridView/GridScroll/GridMargin/GridCards
@onready var col_grid_scroll: ScrollContainer = $CollectionModal/GridView/GridScroll
@onready var btn_close_collection: Button = $CollectionModal/GridView/BtnCloseCollection
@onready var btn_back_to_grid: Button = $CollectionModal/DetailView/TopNav/BtnBackToGrid

@onready var assembled_card: Control = $CollectionModal/DetailView/CardCenter/AssembledCard
@onready var locked_notice_panel: PanelContainer = $CollectionModal/DetailView/DetailsScroll/DetailsBox/LockedNoticePanel
@onready var detail_type_icon: TextureRect = $CollectionModal/DetailView/DetailsScroll/DetailsBox/HeaderPanel/HeaderMargin/HeaderVBox/NameRow/DetailTypeIcon
@onready var detail_name: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/HeaderPanel/HeaderMargin/HeaderVBox/NameRow/DetailName
@onready var detail_sub: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/HeaderPanel/HeaderMargin/HeaderVBox/DetailSub

@onready var stats_panel: PanelContainer = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel
@onready var stats_hp: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/StatsHp
@onready var stats_spd: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/StatsSpd
@onready var stats_energy: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/StatsEnergy
@onready var deb_row: HBoxContainer = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/DebRow
@onready var deb_icon: TextureRect = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/DebRow/DebIcon
@onready var deb_val: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/DebRow/DebVal
@onready var res_row: HBoxContainer = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/ResRow
@onready var res_icon: TextureRect = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/ResRow/ResIcon
@onready var res_val: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/StatsPanel/StatsMargin/StatsVBox/ResRow/ResVal

@onready var passive_panel: PanelContainer = $CollectionModal/DetailView/DetailsScroll/DetailsBox/PassivePanel
@onready var passive_title: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/PassivePanel/PassiveMargin/PassiveVBox/PassiveTitle
@onready var passive_desc: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/PassivePanel/PassiveMargin/PassiveVBox/PassiveDesc

@onready var move1_panel: PanelContainer = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move1Panel
@onready var m1_type_icon: TextureRect = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move1Panel/M1Margin/M1VBox/M1TitleRow/M1TypeIcon
@onready var m1_title: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move1Panel/M1Margin/M1VBox/M1TitleRow/M1Title
@onready var m1_sub: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move1Panel/M1Margin/M1VBox/M1Sub
@onready var m1_desc: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move1Panel/M1Margin/M1VBox/M1Desc

@onready var move2_panel: PanelContainer = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move2Panel
@onready var m2_type_icon: TextureRect = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move2Panel/M2Margin/M2VBox/M2TitleRow/M2TypeIcon
@onready var m2_title: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move2Panel/M2Margin/M2VBox/M2TitleRow/M2Title
@onready var m2_sub: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move2Panel/M2Margin/M2VBox/M2Sub
@onready var m2_boost: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move2Panel/M2Margin/M2VBox/M2Boost
@onready var m2_desc: Label = $CollectionModal/DetailView/DetailsScroll/DetailsBox/Move2Panel/M2Margin/M2VBox/M2Desc

@onready var btn_prev_card: Button = $CollectionModal/DetailView/CardNav/BtnPrev
@onready var btn_next_card: Button = $CollectionModal/DetailView/CardNav/BtnNext
@onready var collection_page_lbl: Label = $CollectionModal/DetailView/CardNav/PageLbl

# --- MODAL TIENDA ---
@onready var shop_modal: Control = $ShopModal
@onready var shop_box: VBoxContainer = $ShopModal/Box
@onready var shop_diamonds_lbl: Label = $ShopModal/Box/ShopDiamondsLbl
@onready var btn_open_pack: Button = $ShopModal/Box/BtnOpenPack
@onready var shop_feedback_lbl: Label = $ShopModal/Box/ShopFeedbackLbl
@onready var btn_close_shop: Button = $ShopModal/Box/BtnCloseShop
@onready var pack_art_texture: TextureRect = $ShopModal/Box/PackPanel/VBox/PackHeaderRow/PackArtTexture
@onready var rates_grid: GridContainer = $ShopModal/Box/PackPanel/VBox/RatesPanel/RatesVBox/RatesGrid
@onready var showcase_row: HBoxContainer = $ShopModal/Box/PackPanel/VBox/ShowcaseVBox/ShowcaseRow
@onready var showcase_header: Label = $ShopModal/Box/PackPanel/VBox/ShowcaseVBox/ShowcaseHeader

var pack_reveal_box: VBoxContainer = null
var reveal_cards_row: HBoxContainer = null
var btn_reveal_another: Button = null
const BOOSTER_PACK_COST: int = 5
const SHOWCASE_POKEMON_NAMES: Array[String] = ["Zapdos", "Articuno", "Moltres"]

# --- SHOP SHOWCASE ROTATION (EPIC & LEGENDARY FOILS ONLY) ---
const SHOWCASE_ROTATION_INTERVAL: float = 6.0
var showcase_timer: Timer = null
var showcase_legendary_queue: Array[int] = []
var showcase_epic_queue: Array[int] = []
var showcase_cycle_count: int = 0
var showcase_is_animating: bool = false

# --- SHOP EXPANSION: TABS, RECYCLE, HIDDEN SHOP ---
const GameLocalizationScript = preload("res://scripts/localization.gd")
var shop_active_tab: String = "PACKS" # "PACKS", "RECYCLE", "HIDDEN"
var hidden_shop_filter: String = "ALL"
var hidden_shop_region: String = "KANTO" # "KANTO", "JOHTO", "HOENN", "SINNOH", "ALL"
var hidden_shop_page: int = 0
const HIDDEN_SHOP_PER_PAGE: int = 50
var hidden_shop_scroll: ScrollContainer = null
var hidden_shop_pagination_bar: PanelContainer = null
var shop_tabs_row: HBoxContainer = null
var btn_shop_tab_packs: Button = null
var btn_shop_tab_recycle: Button = null
var btn_shop_tab_hidden: Button = null
var packs_container: VBoxContainer = null
var packs_catalog_view: VBoxContainer = null
var selected_booster_pack_id: String = "kanto"
var btn_small_cost_pack: Button = null
var pack_detail_art_container: MarginContainer = null
var pack_detail_region_lbl: Label = null
var btn_back_from_detail: Button = null
var recycle_container: VBoxContainer = null
var hidden_shop_container: VBoxContainer = null
var btn_bulk_recycle: Button = null
var recycle_scroll_list: VBoxContainer = null
var recycle_empty_lbl: Label = null
var hidden_shop_grid: GridContainer = null
var hidden_filter_buttons: Dictionary = {}
var hidden_region_buttons: Dictionary = {}
var stat_candies_lbl: Label = null

# --- ONBOARDING TUTORIAL & STARTER SELECTION ---
var starter_select_modal: Control = null
var starter_region_active: String = "Kanto"
var starter_cards_row: VBoxContainer = null
var starter_tab_buttons: Dictionary = {}
var tutorial_prompt_callback: Callable = Callable()
var _pending_tutorial_after_settings: bool = false

# --- MODAL LOGIN (PANTALLA DE ACCESO PREVIA AL LOBBY) ---
@onready var login_modal: Control = $LoginModal
@onready var profile_detected_lbl: Label = $LoginModal/LoginBox/LoginHeader/ProfileDetectedLbl
@onready var btn_login_play: Button = $LoginModal/LoginBox/LoginButtons/BtnLoginPlay
@onready var btn_login_cloud: Button = $LoginModal/LoginBox/LoginButtons/BtnLoginCloud
@onready var btn_sign_up_google: Button = $LoginModal/LoginBox/LoginButtons/BtnSignUpGoogle
@onready var login_feedback_lbl: Label = $LoginModal/LoginBox/LoginFeedbackLbl

# --- MODAL PERFIL DEL ENTRENADOR ---
@onready var profile_modal: Control = $ProfileModal
@onready var trainer_name_input: LineEdit = $ProfileModal/ProfileBox/TrainerInfoCard/TrainerInfoVBox/TrainerNameRow/TrainerNameInput
@onready var trainer_email_row: HBoxContainer = $ProfileModal/ProfileBox/TrainerInfoCard/TrainerInfoVBox/TrainerEmailRow
@onready var trainer_email_prompt: Label = $ProfileModal/ProfileBox/TrainerInfoCard/TrainerInfoVBox/TrainerEmailRow/TrainerEmailPrompt
@onready var trainer_email_value: Label = $ProfileModal/ProfileBox/TrainerInfoCard/TrainerInfoVBox/TrainerEmailRow/TrainerEmailValue
@onready var account_status_lbl: Label = $ProfileModal/ProfileBox/TrainerInfoCard/TrainerInfoVBox/AccountStatusLbl
@onready var btn_link_google: Button = $ProfileModal/ProfileBox/TrainerInfoCard/TrainerInfoVBox/BtnLinkGoogle
@onready var stat_diamonds_lbl: Label = $ProfileModal/ProfileBox/StatsCard/StatsVBox/StatsGrid/StatDiamondsLbl
@onready var stat_tournaments_lbl: Label = $ProfileModal/ProfileBox/StatsCard/StatsVBox/StatsGrid/StatTournamentsLbl
@onready var stat_battles_lbl: Label = $ProfileModal/ProfileBox/StatsCard/StatsVBox/StatsGrid/StatBattlesLbl
@onready var stat_collection_lbl: Label = $ProfileModal/ProfileBox/StatsCard/StatsVBox/StatsGrid/StatCollectionLbl
@onready var stat_packs_lbl: Label = $ProfileModal/ProfileBox/StatsCard/StatsVBox/StatsGrid/StatPacksLbl
@onready var stat_gold_lbl: Label = $ProfileModal/ProfileBox/StatsCard/StatsVBox/StatsGrid/StatGoldLbl
@onready var profile_feedback_lbl: Label = $ProfileModal/ProfileBox/ProfileFeedbackLbl
@onready var btn_save_progress: Button = $ProfileModal/ProfileBox/BtnSaveProgress
@onready var btn_logout: Button = $ProfileModal/ProfileBox/BtnLogout
@onready var btn_erase_profile: Button = $ProfileModal/ProfileBox/BtnEraseProfile
@onready var btn_close_profile: Button = $ProfileModal/ProfileBox/BtnCloseProfile

# --- MODAL AJUSTES / CONFIGURACIÓN ---
@onready var settings_modal: Control = $SettingsModal
@onready var language_option: OptionButton = $SettingsModal/SettingsBox/LanguagePanel/LanguageVBox/LanguageRow/LanguageOption
@onready var music_vol_value_lbl: Label = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/MusicVolHeaderRow/MusicVolValueLbl
@onready var music_slider: HSlider = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/MusicSlider
@onready var mute_music_check: CheckBox = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/MuteMusicCheck
@onready var sfx_vol_value_lbl: Label = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/SfxVolHeaderRow/SfxVolValueLbl
@onready var sfx_slider: HSlider = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/SfxSlider
@onready var mute_sfx_check: CheckBox = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/MuteSfxCheck
@onready var info_version_lbl: Label = $SettingsModal/SettingsBox/InfoPanel/InfoVBox/InfoVersionLbl
@onready var btn_check_update: Button = $SettingsModal/SettingsBox/InfoPanel/InfoVBox/BtnCheckUpdate
@onready var update_status_lbl: Label = $SettingsModal/SettingsBox/InfoPanel/InfoVBox/UpdateStatusLbl
@onready var btn_close_settings: Button = $SettingsModal/SettingsBox/BtnCloseSettings

# --- MODAL ACTUALIZACIÓN (UPDATER LEVEL 1) ---
@onready var update_modal: Control = $UpdateModal
@onready var update_title: Label = $UpdateModal/UpdateCard/UpdateVBox/UpdateTitle
@onready var update_subtitle: Label = $UpdateModal/UpdateCard/UpdateVBox/UpdateSubtitle
@onready var update_notes: Label = $UpdateModal/UpdateCard/UpdateVBox/UpdateNotesScroll/UpdateNotes
@onready var btn_update_download: Button = $UpdateModal/UpdateCard/UpdateVBox/BtnUpdateDownload
@onready var btn_update_github: Button = $UpdateModal/UpdateCard/UpdateVBox/UpdateActionsRow/BtnUpdateGitHub
@onready var btn_update_close: Button = $UpdateModal/UpdateCard/UpdateVBox/UpdateActionsRow/BtnUpdateClose
var _latest_release_info: Dictionary = {}
var _target_download_url: String = ""

# --- MODAL CONFIRMACIÓN DE BORRADO DE PERFIL ---
@onready var erase_confirm_modal: Control = $EraseConfirmModal
@onready var btn_cancel_erase: Button = $EraseConfirmModal/EraseCard/EraseVBox/EraseActions/BtnCancelErase
@onready var btn_confirm_erase: Button = $EraseConfirmModal/EraseCard/EraseVBox/EraseActions/BtnConfirmErase

# --- MODAL AVISO AUTENTICACIÓN GOOGLE / NUBE ---
@onready var cloud_notice_modal: Control = $CloudNoticeModal
@onready var cloud_title: Label = $CloudNoticeModal/CloudCard/CloudVBox/CloudTitle
@onready var cloud_desc: Label = $CloudNoticeModal/CloudCard/CloudVBox/CloudDesc
@onready var cloud_email_row: HBoxContainer = $CloudNoticeModal/CloudCard/CloudVBox/CloudEmailRow
@onready var cloud_email_input: LineEdit = $CloudNoticeModal/CloudCard/CloudVBox/CloudEmailRow/CloudEmailInput
@onready var cloud_trainer_row: HBoxContainer = $CloudNoticeModal/CloudCard/CloudVBox/CloudTrainerRow
@onready var cloud_trainer_prompt: Label = $CloudNoticeModal/CloudCard/CloudVBox/CloudTrainerRow/CloudTrainerPrompt
@onready var cloud_trainer_input: LineEdit = $CloudNoticeModal/CloudCard/CloudVBox/CloudTrainerRow/CloudTrainerInput
@onready var cloud_password_row: HBoxContainer = $CloudNoticeModal/CloudCard/CloudVBox/CloudPasswordRow
@onready var cloud_password_prompt: Label = $CloudNoticeModal/CloudCard/CloudVBox/CloudPasswordRow/CloudPasswordPrompt
@onready var cloud_password_input: LineEdit = $CloudNoticeModal/CloudCard/CloudVBox/CloudPasswordRow/CloudPasswordInput
@onready var cloud_feedback_lbl: Label = $CloudNoticeModal/CloudCard/CloudVBox/CloudFeedbackLbl
@onready var btn_cloud_confirm: Button = $CloudNoticeModal/CloudCard/CloudVBox/BtnCloudConfirm
@onready var btn_resend_verification: Button = $CloudNoticeModal/CloudCard/CloudVBox/BtnResendVerification
@onready var btn_launch_browser_auth: Button = $CloudNoticeModal/CloudCard/CloudVBox/BtnLaunchBrowserAuth
@onready var btn_toggle_manual_auth: Button = $CloudNoticeModal/CloudCard/CloudVBox/BtnToggleManualAuth
@onready var btn_close_cloud_notice: Button = $CloudNoticeModal/CloudCard/CloudVBox/BtnCloseCloudNotice
var cloud_action_mode: String = "SIGNUP_GOOGLE"
var is_manual_cloud_mode: bool = false
var _pending_verify_id_token: String = ""
var _pending_verify_email: String = ""
var _pending_verify_alias: String = ""
var _pending_verify_password: String = ""

# --- MODAL BIENVENIDA (REGALO 15 GEMAS) ---
@onready var welcome_modal: Control = $WelcomeModal
@onready var welcome_card: PanelContainer = $WelcomeModal/WelcomeBox/WelcomeCard
@onready var welcome_gift_panel: PanelContainer = $WelcomeModal/WelcomeBox/WelcomeCard/WelcomeMargin/WelcomeVBox/WelcomeGiftPanel
@onready var welcome_title: Label = $WelcomeModal/WelcomeBox/WelcomeCard/WelcomeMargin/WelcomeVBox/WelcomeTitle
@onready var btn_welcome_go_shop: Button = $WelcomeModal/WelcomeBox/WelcomeCard/WelcomeMargin/WelcomeVBox/WelcomeActions/BtnWelcomeGoShop
@onready var btn_welcome_enter_lobby: Button = $WelcomeModal/WelcomeBox/WelcomeCard/WelcomeMargin/WelcomeVBox/WelcomeActions/BtnWelcomeEnterLobby

# --- MODAL SALA ONLINE (COMBATE MULTIJUGADOR EN LÍNEA) ---
@onready var online_lobby_modal: Control = $OnlineLobbyModal
@onready var online_card: PanelContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard
@onready var btn_tab_create_room: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/OnlineModeSelector/BtnTabCreateRoom
@onready var btn_tab_join_room: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/OnlineModeSelector/BtnTabJoinRoom

# Host Panel
@onready var host_panel: VBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel
@onready var room_code_box: PanelContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/RoomCodeBox
@onready var room_code_lbl: Label = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/RoomCodeBox/RoomCodeLbl
@onready var host_team_container: HBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/HostTeamSection/HostTeamContainer
@onready var btn_host_change_team: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/HostTeamSection/HostTeamHeader/BtnHostChangeTeam
@onready var host_rival_info_lbl: Label = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/HostRivalSection/HostRivalInfoLbl
@onready var host_rival_team_container: HBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/HostRivalSection/HostRivalTeamContainer
@onready var host_rival_ready_badge: Label = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/HostRivalSection/HostRivalReadyBadge
@onready var btn_host_start_battle: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/BtnHostStartBattle
@onready var host_status_lbl: Label = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/HostStatusLbl

# Join Panel
@onready var join_panel: VBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel
@onready var join_input_section: VBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/JoinInputSection
@onready var join_code_input: LineEdit = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/JoinInputSection/JoinCodeInput
@onready var btn_confirm_join: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/JoinInputSection/BtnConfirmJoin
@onready var guest_lobby_section: VBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/GuestLobbySection
@onready var guest_room_info_lbl: Label = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/GuestLobbySection/GuestRoomInfoLbl
@onready var guest_rival_info_lbl: Label = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/GuestLobbySection/GuestRivalSection/GuestRivalInfoLbl
@onready var guest_rival_team_container: HBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/GuestLobbySection/GuestRivalSection/GuestRivalTeamContainer
@onready var btn_guest_change_team: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/GuestLobbySection/GuestTeamHeader/BtnGuestChangeTeam
@onready var guest_team_container: HBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/GuestLobbySection/GuestTeamContainer
@onready var btn_guest_ready_toggle: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/GuestLobbySection/BtnGuestReadyToggle
@onready var join_status_lbl: Label = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/JoinStatusLbl

@onready var btn_close_online_lobby: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/BtnCloseOnlineLobby

# --- MODAL MISIONES Y RECOMPENSAS DIARIAS ---
@onready var btn_daily_missions: Button = $ContentContainer/MenuButtons/BtnDailyMissions
@onready var daily_modal: Control = $DailyModal
@onready var daily_streak_badge: Label = $DailyModal/DailyBox/DailyHeaderRow/DailyStreakBadge
@onready var calendar_grid: HBoxContainer = $DailyModal/DailyBox/DailyCalendarPanel/DailyCalendarMargin/DailyCalendarVBox/CalendarGrid
@onready var btn_claim_login_reward: Button = $DailyModal/DailyBox/DailyCalendarPanel/DailyCalendarMargin/DailyCalendarVBox/BtnClaimLoginReward
@onready var calendar_status_lbl: Label = $DailyModal/DailyBox/DailyCalendarPanel/DailyCalendarMargin/DailyCalendarVBox/CalendarTitleRow/CalendarStatus
@onready var missions_list_vbox: VBoxContainer = $DailyModal/DailyBox/DailyMissionsPanel/DailyMissionsMargin/DailyMissionsVBox/MissionsListVBox
@onready var btn_claim_chest: Button = $DailyModal/DailyBox/ChestPanel/ChestMargin/ChestHBox/BtnClaimChest
@onready var chest_desc_lbl: Label = $DailyModal/DailyBox/ChestPanel/ChestMargin/ChestHBox/ChestTextVBox/ChestDesc
@onready var btn_close_daily: Button = $DailyModal/DailyBox/BtnCloseDaily

# --- BOTÓN Y MODAL DE AMIGOS (FRIENDS SYSTEM) ---
@onready var btn_friends: Button = $ContentContainer/MenuButtons/AuxButtonsRow/BtnFriends
@onready var btn_online_friends: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/BtnOnlineFriends
@onready var friends_modal: Control = $FriendsModal
@onready var friends_count_badge: Label = $FriendsModal/FriendsBox/FriendsHeaderRow/FriendsCountBadge
@onready var challenge_banner: PanelContainer = $FriendsModal/FriendsBox/ChallengeBanner
@onready var challenge_title: Label = $FriendsModal/FriendsBox/ChallengeBanner/ChallengeMargin/ChallengeHBox/ChallengeTextVBox/ChallengeTitle
@onready var challenge_desc: Label = $FriendsModal/FriendsBox/ChallengeBanner/ChallengeMargin/ChallengeHBox/ChallengeTextVBox/ChallengeDesc
@onready var btn_accept_challenge: Button = $FriendsModal/FriendsBox/ChallengeBanner/ChallengeMargin/ChallengeHBox/BtnAcceptChallenge
@onready var btn_decline_challenge: Button = $FriendsModal/FriendsBox/ChallengeBanner/ChallengeMargin/ChallengeHBox/BtnDeclineChallenge
@onready var friend_search_input: LineEdit = $FriendsModal/FriendsBox/SearchCard/SearchMargin/SearchHBox/FriendSearchInput
@onready var btn_search_friend: Button = $FriendsModal/FriendsBox/SearchCard/SearchMargin/SearchHBox/BtnSearchFriend
@onready var btn_clear_search: Button = $FriendsModal/FriendsBox/SearchCard/SearchMargin/SearchHBox/BtnClearSearch
@onready var btn_tab_my_friends: Button = $FriendsModal/FriendsBox/FriendsTabsRow/BtnTabMyFriends
@onready var btn_tab_search_results: Button = $FriendsModal/FriendsBox/FriendsTabsRow/BtnTabSearchResults
@onready var btn_refresh_friends: Button = $FriendsModal/FriendsBox/FriendsTabsRow/BtnRefreshFriends
@onready var friends_content_scroll: ScrollContainer = $FriendsModal/FriendsBox/FriendsContentScroll
@onready var friends_list_vbox: VBoxContainer = $FriendsModal/FriendsBox/FriendsContentScroll/FriendsListVBox
@onready var search_results_scroll: ScrollContainer = $FriendsModal/FriendsBox/SearchResultsScroll
@onready var search_results_vbox: VBoxContainer = $FriendsModal/FriendsBox/SearchResultsScroll/SearchResultsVBox
@onready var friends_feedback_lbl: Label = $FriendsModal/FriendsBox/FriendsFeedbackLbl
@onready var btn_close_friends: Button = $FriendsModal/FriendsBox/BtnCloseFriends

var friends_active_tab: String = "MY_FRIENDS"
var last_search_results: Array = []
var active_direct_challenge: Dictionary = {}
var active_friend_rooms_map: Dictionary = {} # host_email -> room_info

var qb_selected_mode: String = "AI" # "AI", "PVP"

# --- AUDIO DE FONDO (BGM) ---
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

# Datos de cartas (se cargan dinámicamente desde el CSV)
var cards_data: Array = [] # Cartas desbloqueadas del jugador
var all_catalog_cards: Array = [] # Todo el catálogo (para Mi Colección y Rival IA)
var current_collection_index: int = 0
var collection_sort_mode: String = "ID" # "ID", "DEX", "NAME"
var current_sorted_collection: Array = []

# Filtros de Colección (Region, Owned, Types, Stages, Rarity, Tier)
var col_filter_region: String = "KANTO" # "KANTO", "JOHTO", "HOENN", "SINNOH", "ALL"
var col_filter_owned: String = "ALL" # "ALL", "OWNED", "MISSING"
var col_filter_type: String = "ALL" # "ALL", "NORMAL", "GRASS", "FIRE", "WATER", "ELECTRIC", "DARK", "PSYCHIC", "FIGHTING", "GROUND"
var col_filter_stage: String = "ALL" # "ALL", "BASIC", "STAGE 1", "STAGE 2"
var col_filter_rarity: String = "ALL" # "ALL", "COMMON", "RARE", "EPIC", "LEGENDARY"
var col_filter_tier: String = "ALL" # "ALL", "S+", "S", "A", "B", "C", "D"
var col_current_page: int = 0
const COL_CARDS_PER_PAGE: int = 50
var col_pagination_bar: PanelContainer = null

var col_region_tabs_row: Container = null
var col_region_buttons: Dictionary = {}
var collection_filter_panel: PanelContainer = null
var opt_col_owned: OptionButton = null
var opt_col_type: OptionButton = null
var opt_col_stage: OptionButton = null
var opt_col_rarity: OptionButton = null
var opt_col_tier: OptionButton = null
var btn_col_reset_filters: Button = null
var btn_col_fav_toggle: Button = null

# Showcase de Favoritos y Perfil de Amigos
var profile_showcase_card: PanelContainer = null
var showcase_picker_modal: Control = null
var temp_showcase_selection: Array[int] = []
var friend_profile_modal: Control = null

# Selección de equipos
var team_select_mode: String = "QUICK_BATTLE" # "QUICK_BATTLE" o "CAMPAIGN"
var current_team_tab: String = "PLAYER" # "PLAYER" o "ENEMY"
var team_sort_mode: String = "ID" # "ID", "DEX", "NAME"
var selected_player_ids: Array[int] = []
var selected_enemy_ids: Array[int] = []
var qb_mode_row: HBoxContainer = null
var btn_qb_mode_ai: Button = null
var btn_qb_mode_pvp: Button = null
var current_sorted_team_pool: Array = []
var card_buttons_map: Dictionary = {} # id -> Button (compatibilidad)
var team_card_views_map: Dictionary = {} # id -> Dictionary de vistas del grid

func _ready() -> void:
	refresh_cards_data_from_catalog()
	
	# Botones del menú principal
	btn_campaign.pressed.connect(_on_campaign_pressed)
	btn_quick_battle.pressed.connect(_on_quick_battle_pressed)
	if btn_online_multiplayer:
		btn_online_multiplayer.pressed.connect(_open_online_lobby)
	btn_collection.pressed.connect(_on_collection_pressed)
	btn_shop.pressed.connect(_on_shop_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	# Modal Selección de Equipo
	btn_tab_player.pressed.connect(_on_tab_player_pressed)
	btn_tab_enemy.pressed.connect(_on_tab_enemy_pressed)
	btn_random_enemy.pressed.connect(_randomize_enemy_team)
	btn_start_battle.pressed.connect(_on_start_battle_pressed)
	if btn_clear_team:
		btn_clear_team.pressed.connect(_on_clear_team_pressed)
	btn_close_team_select.pressed.connect(_on_close_team_select_pressed)
	btn_team_sort_id.pressed.connect(func(): _on_team_sort_pressed("ID"))
	btn_team_sort_dex.pressed.connect(func(): _on_team_sort_pressed("DEX"))
	btn_team_sort_alpha.pressed.connect(func(): _on_team_sort_pressed("NAME"))
	btn_team_sort_rarity.pressed.connect(func(): _on_team_sort_pressed("RARITY"))
	btn_team_sort_evo.pressed.connect(func(): _on_team_sort_pressed("EVO"))
	update_team_sort_buttons_ui()
	
	# Modal Campaign Hub
	btn_hub_tutorial.pressed.connect(_on_hub_tutorial_pressed)
	btn_hub_adventure.pressed.connect(_on_hub_adventure_pressed)
	btn_hub_tournament.pressed.connect(_on_select_tournament_pressed)
	btn_close_campaign_hub.pressed.connect(func():
		campaign_hub_modal.visible = false
		_update_lobby_header_badge()
	)
	
	# Modal Adventure Episodes
	btn_hub_adventure_ep1.pressed.connect(_on_select_adventure_ep1_pressed)
	btn_hub_adventure_ep2.pressed.connect(_on_select_adventure_ep2_pressed)
	btn_hub_adventure_ep3.pressed.connect(_on_select_adventure_ep3_pressed)
	btn_hub_adventure_ep4.pressed.connect(_on_select_adventure_ep4_pressed)
	btn_hub_adventure_ep5.pressed.connect(_on_select_adventure_ep5_pressed)
	btn_hub_adventure_ep6.pressed.connect(_on_select_adventure_ep6_pressed)
	btn_hub_adventure_ep7.pressed.connect(_on_select_adventure_ep7_pressed)
	btn_close_adventure_episodes.pressed.connect(func():
		adventure_episodes_modal.visible = false
		update_campaign_hub_ui()
		campaign_hub_modal.visible = true
	)

	# Modal Stadium Encounters Guide
	btn_stadium_guide.pressed.connect(func():
		_stadium_guide_return_modal = campaign_hub_modal
		campaign_hub_modal.visible = false
		stadium_guide_modal.visible = true
	)
	btn_camp_stadium_guide.pressed.connect(func():
		_stadium_guide_return_modal = campaign_modal
		campaign_modal.visible = false
		stadium_guide_modal.visible = true
	)
	btn_close_stadium_guide.pressed.connect(func():
		stadium_guide_modal.visible = false
		if _stadium_guide_return_modal:
			_stadium_guide_return_modal.visible = true
			_stadium_guide_return_modal = null
	)

	for card_path in [
		"CampaignHubModal/Box/ModesScroll/ModesVBox/CardTutorial",
		"CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventure",
		"CampaignHubModal/Box/ModesScroll/ModesVBox/CardTournament",
		"CampaignHubModal/Box/ModesScroll/ModesVBox/CardLootRates",
		"AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp1",
		"AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp2",
		"AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp3",
		"AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp4",
		"StadiumGuideModal/Box/GuideScroll/GuideVBox/Phase1Card",
		"StadiumGuideModal/Box/GuideScroll/GuideVBox/Phase2Card",
		"StadiumGuideModal/Box/GuideScroll/GuideVBox/Phase3Card",
		"StadiumGuideModal/Box/GuideScroll/GuideVBox/RulesCard"
	]:
		var card_node = get_node_or_null(card_path)
		if card_node:
			var csb = StyleBoxFlat.new()
			csb.bg_color = Color(0.08, 0.12, 0.18, 0.95)
			csb.border_color = Color(0.24, 0.35, 0.48, 0.75)
			csb.set_border_width_all(1)
			csb.set_corner_radius_all(8)
			card_node.add_theme_stylebox_override("panel", csb)

	# Modal Campaña / Torneo
	btn_buy_potion.pressed.connect(_on_buy_potion_pressed)
	btn_buy_super_potion.pressed.connect(_on_buy_super_potion_pressed)
	btn_buy_hyper_potion.pressed.connect(_on_buy_hyper_potion_pressed)
	btn_buy_remedy.pressed.connect(_on_buy_remedy_pressed)
	if btn_buy_poke_flute:
		btn_buy_poke_flute.pressed.connect(_on_buy_poke_flute_pressed)
	btn_buy_ether.pressed.connect(_on_buy_ether_pressed)
	btn_buy_revive.pressed.connect(_on_buy_revive_pressed)
	btn_start_campaign_battle.pressed.connect(_on_start_campaign_battle_pressed)
	btn_change_campaign_team.pressed.connect(open_team_select_for_campaign)
	btn_reset_campaign.pressed.connect(_on_reset_campaign_pressed)
	btn_close_campaign.pressed.connect(func():
		if GameData.campaign_submode == "ADVENTURE":
			# Los episodios de campaña no se pueden abandonar manteniendo progreso:
			# Si sales, se reinicia el progreso del episodio conservando los recursos G y Diamonds
			GameData.reset_adventure_episode(GameData.adventure_current_episode)
			GameData.is_campaign_mode = false
			GameData.save_profile()
		campaign_modal.visible = false
		if camp_shop_modal: camp_shop_modal.visible = false
		if camp_bag_modal: camp_bag_modal.visible = false
		if camp_pokemon_inspector_modal: camp_pokemon_inspector_modal.visible = false
		if camp_evo_modal: camp_evo_modal.visible = false
		if GameData.campaign_submode == "ADVENTURE":
			update_adventure_episodes_ui()
			adventure_episodes_modal.visible = true
		else:
			update_campaign_hub_ui()
			campaign_hub_modal.visible = true
		_update_lobby_header_badge()
	)
	
	campaign_item_icon.texture = GameData.get_item_texture("potion")
	campaign_super_potion_icon.texture = GameData.get_item_texture("super_potion")
	campaign_hyper_potion_icon.texture = GameData.get_item_texture("hyper_potion")
	campaign_remedy_icon.texture = GameData.get_item_texture("remedy")
	if campaign_poke_flute_icon:
		campaign_poke_flute_icon.texture = GameData.get_item_texture("poke_flute")
	campaign_ether_icon.texture = GameData.get_item_texture("ether")
	campaign_revive_icon.texture = GameData.get_item_texture("revive")
	
	# Modal Colección
	btn_close_collection.pressed.connect(func():
		collection_modal.visible = false
		_update_lobby_header_badge()
	)
	btn_back_to_grid.pressed.connect(_on_back_to_grid_pressed)
	btn_prev_card.pressed.connect(_on_prev_card_pressed)
	btn_next_card.pressed.connect(_on_next_card_pressed)
	btn_col_sort_id.pressed.connect(func(): _on_col_sort_pressed("ID"))
	btn_col_sort_dex.pressed.connect(func(): _on_col_sort_pressed("DEX"))
	btn_col_sort_alpha.pressed.connect(func(): _on_col_sort_pressed("NAME"))
	btn_col_sort_rarity.pressed.connect(func(): _on_col_sort_pressed("RARITY"))
	btn_col_sort_owned.pressed.connect(func(): _on_col_sort_pressed("OWNED"))
	update_collection_sort_buttons_ui()
	_setup_collection_filters()
	
	# Modal Tienda (Sobre de Prueba)
	_setup_showcase_timer()
	btn_close_shop.pressed.connect(func():
		if not GameData.tutorial_completed and (GameData.tutorial_step == 1 or GameData.tutorial_step == 2):
			if shop_feedback_lbl:
				shop_feedback_lbl.text = "⚠️ ¡Debes abrir tu primer sobre para continuar el tutorial!"
				shop_feedback_lbl.visible = true
			return
		_stop_showcase_timer()
		shop_modal.visible = false
		_update_lobby_header_badge()
	)
	btn_open_pack.disabled = false
	btn_open_pack.pressed.connect(_on_open_pack_pressed)
	
	# Botones de Perfil y Ajustes en Lobby
	btn_profile.pressed.connect(_on_profile_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_daily_missions.pressed.connect(_on_daily_missions_pressed)
	
	# Modal Misiones Diarias
	btn_close_daily.pressed.connect(func(): daily_modal.visible = false)
	btn_claim_login_reward.pressed.connect(_on_claim_login_reward_pressed)
	btn_claim_chest.pressed.connect(_on_claim_chest_pressed)
	GameData.daily_rewards_changed.connect(_update_daily_ui)
	
	# Modal Perfil
	btn_save_progress.pressed.connect(_on_save_progress_pressed)
	btn_logout.pressed.connect(_on_logout_pressed)
	if btn_erase_profile:
		btn_erase_profile.pressed.connect(_on_erase_profile_prompt_pressed)
		_apply_retro_button_style(btn_erase_profile, Color(0.40, 0.12, 0.12), Color(0.85, 0.25, 0.25), false)
	btn_close_profile.pressed.connect(func(): profile_modal.visible = false)
	trainer_name_input.text_submitted.connect(func(_t): _on_save_progress_pressed())
	if btn_link_google:
		btn_link_google.pressed.connect(func():
			profile_modal.visible = false
			_on_sign_up_google_pressed()
		)
	
	# Modal Ajustes
	btn_close_settings.pressed.connect(_on_close_settings_pressed)
	if language_option:
		language_option.item_selected.connect(_on_language_option_selected)
	if not GameData.language_changed.is_connected(_on_language_changed):
		GameData.language_changed.connect(_on_language_changed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	mute_music_check.toggled.connect(_on_mute_music_toggled)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	mute_sfx_check.toggled.connect(_on_mute_sfx_toggled)
	if btn_check_update:
		btn_check_update.pressed.connect(_on_check_update_pressed)
	if btn_update_download:
		btn_update_download.pressed.connect(_on_update_download_pressed)
	if btn_update_github:
		btn_update_github.pressed.connect(_on_update_github_pressed)
	if btn_update_close:
		btn_update_close.pressed.connect(_on_update_close_pressed)
	
	# Modal Confirmar Borrado de Perfil
	btn_cancel_erase.pressed.connect(func(): erase_confirm_modal.visible = false)
	btn_confirm_erase.pressed.connect(_on_confirm_erase_pressed)
	
	# Modal Login & Google Sign-Up
	btn_login_play.pressed.connect(_on_login_play_pressed)
	btn_login_cloud.pressed.connect(_on_login_cloud_pressed)
	btn_sign_up_google.pressed.connect(_on_sign_up_google_pressed)
	btn_cloud_confirm.pressed.connect(_on_cloud_confirm_pressed)
	if btn_resend_verification:
		btn_resend_verification.pressed.connect(_on_resend_verification_pressed)
	if btn_launch_browser_auth:
		btn_launch_browser_auth.pressed.connect(_launch_google_browser_oauth)
	if btn_toggle_manual_auth:
		btn_toggle_manual_auth.pressed.connect(_toggle_manual_cloud_mode)
	btn_close_cloud_notice.pressed.connect(func():
		CloudSync.stop_google_oauth_server()
		cloud_notice_modal.visible = false
	)
	cloud_trainer_input.text_submitted.connect(func(_t): _on_cloud_confirm_pressed())
	if cloud_password_input:
		cloud_password_input.text_submitted.connect(func(_t): _on_cloud_confirm_pressed())
	if cloud_email_input:
		cloud_email_input.text_submitted.connect(func(_t): _on_cloud_confirm_pressed())
		cloud_email_input.gui_input.connect(func(event: InputEvent):
			if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
				if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
					var is_mobile_web = bool(JavaScriptBridge.eval("/Mobi|Android|iPhone|iPad/i.test(navigator.userAgent)"))
					if is_mobile_web:
						_prompt_web_input_if_needed(cloud_email_input, "Enter your Google email or alias:")
		)
	if cloud_trainer_input:
		cloud_trainer_input.gui_input.connect(func(event: InputEvent):
			if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
				if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
					var is_mobile_web = bool(JavaScriptBridge.eval("/Mobi|Android|iPhone|iPad/i.test(navigator.userAgent)"))
					if is_mobile_web:
						_prompt_web_input_if_needed(cloud_trainer_input, "Enter your Trainer Alias:")
		)
	
	# Botón ✏️ de ayuda para escribir en móvil
	if cloud_email_row and not cloud_email_row.has_node("BtnPromptEmail"):
		var b_pe = Button.new()
		b_pe.name = "BtnPromptEmail"
		b_pe.text = "✏️"
		b_pe.tooltip_text = "Type email or alias"
		b_pe.custom_minimum_size = Vector2(34, 0)
		b_pe.pressed.connect(func():
			_prompt_web_input_if_needed(cloud_email_input, "Enter your Google email or alias:")
		)
		cloud_email_row.add_child(b_pe)
		
	if cloud_trainer_row and not cloud_trainer_row.has_node("BtnPromptTrainer"):
		var b_pt = Button.new()
		b_pt.name = "BtnPromptTrainer"
		b_pt.text = "✏️"
		b_pt.tooltip_text = "Type alias"
		b_pt.custom_minimum_size = Vector2(34, 0)
		b_pt.pressed.connect(func():
			_prompt_web_input_if_needed(cloud_trainer_input, "Enter your Trainer Alias:")
		)
		cloud_trainer_row.add_child(b_pt)

	if not CloudSync.google_oauth_completed.is_connected(_on_google_oauth_completed):
		CloudSync.google_oauth_completed.connect(_on_google_oauth_completed)
	
	# Modal Bienvenida (Regalo de Bienvenida)
	btn_welcome_go_shop.pressed.connect(_on_welcome_go_shop_pressed)
	btn_welcome_enter_lobby.pressed.connect(func():
		GameData.claim_welcome_gift()
		welcome_modal.visible = false
	)
	if welcome_card:
		var wc_sb = StyleBoxFlat.new()
		wc_sb.bg_color = Color("#111722")
		wc_sb.border_color = Color("#FFD700")
		wc_sb.set_border_width_all(2)
		wc_sb.set_corner_radius_all(12)
		welcome_card.add_theme_stylebox_override("panel", wc_sb)
	if welcome_gift_panel:
		var gp_sb = StyleBoxFlat.new()
		gp_sb.bg_color = Color("#182338")
		gp_sb.border_color = Color("#29B6F6")
		gp_sb.set_border_width_all(1)
		gp_sb.set_corner_radius_all(8)
		welcome_gift_panel.add_theme_stylebox_override("panel", gp_sb)
	welcome_modal.visible = false
	
	# Modal Sala Online
	btn_tab_create_room.pressed.connect(_show_online_host_tab)
	btn_tab_join_room.pressed.connect(_show_online_join_tab)
	btn_confirm_join.pressed.connect(_on_confirm_join_pressed)
	btn_close_online_lobby.pressed.connect(_on_close_online_lobby_pressed)
	if btn_host_change_team:
		btn_host_change_team.pressed.connect(_on_lobby_change_team_pressed)
	if btn_guest_change_team:
		btn_guest_change_team.pressed.connect(_on_lobby_change_team_pressed)
	if btn_guest_ready_toggle:
		btn_guest_ready_toggle.pressed.connect(_on_guest_ready_toggle_pressed)
	if btn_host_start_battle:
		btn_host_start_battle.pressed.connect(_on_host_start_battle_pressed)
		
	if not OnlineManager.guest_connected.is_connected(_on_online_guest_connected):
		OnlineManager.guest_connected.connect(_on_online_guest_connected)
	if not OnlineManager.guest_ready_changed.is_connected(_on_online_guest_ready_changed):
		OnlineManager.guest_ready_changed.connect(_on_online_guest_ready_changed)
	if not OnlineManager.opponent_team_updated.is_connected(_on_online_opponent_team_updated):
		OnlineManager.opponent_team_updated.connect(_on_online_opponent_team_updated)
	if not OnlineManager.match_ready_to_start.is_connected(_on_online_match_ready):
		OnlineManager.match_ready_to_start.connect(_on_online_match_ready)
	join_code_input.text_submitted.connect(func(_t): _on_confirm_join_pressed())
	join_code_input.gui_input.connect(func(event: InputEvent):
		if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
			if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
				var is_mobile_web = bool(JavaScriptBridge.eval("/Mobi|Android|iPhone|iPad/i.test(navigator.userAgent)"))
				if is_mobile_web:
					_prompt_web_input_if_needed(join_code_input, "Enter the 4-character room code:")
	)
	var j_parent = join_code_input.get_parent()
	if j_parent and not j_parent.has_node("BtnPromptJoinCode"):
		var b_pjc = Button.new()
		b_pjc.name = "BtnPromptJoinCode"
		b_pjc.text = "✏️ Type Room Code"
		b_pjc.custom_minimum_size = Vector2(0, 32)
		b_pjc.add_theme_font_size_override("font_size", 11)
		_apply_retro_button_style(b_pjc, Color(0.2, 0.45, 0.65), Color(0.3, 0.6, 0.85), false)
		b_pjc.pressed.connect(func():
			_prompt_web_input_if_needed(join_code_input, "Enter the 4-character room code:")
		)
		j_parent.add_child(b_pjc)
		j_parent.move_child(b_pjc, join_code_input.get_index() + 1)
	if not OnlineManager.match_ready_to_start.is_connected(_on_online_match_ready):
		OnlineManager.match_ready_to_start.connect(_on_online_match_ready)
	online_lobby_modal.visible = false
	
	# Modal Amigos (Friends System)
	btn_friends.pressed.connect(_open_friends_modal)
	if btn_online_friends:
		btn_online_friends.pressed.connect(_open_friends_modal)
	btn_close_friends.pressed.connect(func(): friends_modal.visible = false)
	btn_search_friend.pressed.connect(_on_search_friend_pressed)
	btn_clear_search.pressed.connect(_on_clear_search_pressed)
	friend_search_input.text_submitted.connect(func(_t): _on_search_friend_pressed())
	friend_search_input.gui_input.connect(func(event: InputEvent):
		if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
			if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
				var is_mobile_web = bool(JavaScriptBridge.eval("/Mobi|Android|iPhone|iPad/i.test(navigator.userAgent)"))
				if is_mobile_web:
					_prompt_web_input_if_needed(friend_search_input, "Search trainer by Email or Alias:")
	)
	var s_parent = friend_search_input.get_parent()
	if s_parent and not s_parent.has_node("BtnPromptSearch"):
		var b_ps = Button.new()
		b_ps.name = "BtnPromptSearch"
		b_ps.text = "✏️"
		b_ps.tooltip_text = "Type search"
		b_ps.custom_minimum_size = Vector2(34, 0)
		b_ps.pressed.connect(func():
			_prompt_web_input_if_needed(friend_search_input, "Search trainer by Email or Alias:")
		)
		s_parent.add_child(b_ps)
		s_parent.move_child(b_ps, friend_search_input.get_index() + 1)
	btn_tab_my_friends.pressed.connect(_show_my_friends_tab)
	btn_tab_search_results.pressed.connect(_show_search_results_tab)
	btn_refresh_friends.pressed.connect(_refresh_friends_and_rooms)
	btn_accept_challenge.pressed.connect(_on_accept_direct_challenge_pressed)
	btn_decline_challenge.pressed.connect(_on_decline_direct_challenge_pressed)
	GameData.friends_updated.connect(_update_friends_ui)
	friends_modal.visible = false
	
	# En modo Web, deshabilitar opciones online para jugar exclusivamente local
	if OS.has_feature("web"):
		if btn_online_multiplayer:
			btn_online_multiplayer.visible = false
		if btn_friends:
			btn_friends.visible = false
	
	# Ocultar modales al inicio
	campaign_hub_modal.visible = false
	adventure_episodes_modal.visible = false
	if stadium_guide_modal:
		stadium_guide_modal.visible = false
	team_select_modal.visible = false
	campaign_modal.visible = false
	collection_modal.visible = false
	shop_modal.visible = false
	profile_modal.visible = false
	settings_modal.visible = false
	erase_confirm_modal.visible = false
	cloud_notice_modal.visible = false
	if update_modal:
		update_modal.visible = false
	
	# Aplicar audio y encabezado del lobby
	_apply_audio_settings()
	_update_lobby_header_badge()
	
	# Aplicar tema visual retro Pokémon GBA
	_apply_pokemon_ui_theme()
	
	# Configurar secciones ampliadas de la Tienda (Sobres, Reciclaje, Hidden Shop)
	_setup_shop_sections()
	
	# Configurar Toolbar, Tienda y Mochila del Campamento
	_setup_camp_modals()
	
	# Reactividad en tiempo real de Diamantes / Gemas y Caramelos Raros
	if not GameData.diamonds_changed.is_connected(_on_diamonds_changed):
		GameData.diamonds_changed.connect(_on_diamonds_changed)
	if not GameData.rare_candies_changed.is_connected(_on_rare_candies_changed):
		GameData.rare_candies_changed.connect(_on_rare_candies_changed)
	if not GameData.card_stocks_changed.is_connected(_on_card_stocks_changed):
		GameData.card_stocks_changed.connect(_on_card_stocks_changed)
	
	# Reproducir música de fondo en loop
	if bgm_player:
		if bgm_player.stream is AudioStreamMP3:
			bgm_player.stream.loop = true
		if not bgm_player.playing:
			bgm_player.play()
			
	# Mostrar pantalla de Login al primer acceso de la sesión
	if not GameData.session_entered_lobby:
		if OS.has_feature("web"):
			var is_brand_new = not GameData.has_saved_profile()
			if is_brand_new:
				GameData.create_new_profile("Trainer", "Guest")
			GameData.session_entered_lobby = true
			login_modal.visible = false
			_update_lobby_header_badge()
			if not GameData.tutorial_completed and GameData.tutorial_step == 1:
				_start_tutorial_flow_or_settings()
		else:
			_show_login_screen()
	else:
		login_modal.visible = false
		
	# Si regresamos de completar el tutorial, un combate de campaña o de conquistar un episodio
	if GameData.just_completed_tutorial_combat1 or (not GameData.tutorial_completed and (GameData.tutorial_step == 4 or GameData.tutorial_step == 5)):
		GameData.just_completed_tutorial_combat1 = false
		GameData.campaign_submode = "ADVENTURE"
		update_campaign_ui()
		campaign_modal.visible = true
		if GameData.tutorial_step == 5:
			_show_camp_combat2_prompt()
		else:
			_show_camp_evolution_tutorial_guidance()
	elif GameData.just_completed_tutorial:
		GameData.just_completed_tutorial = false
		update_campaign_hub_ui()
		campaign_hub_modal.visible = true
	elif not GameData.tutorial_completed and GameData.tutorial_step == 1 and GameData.session_entered_lobby:
		_start_tutorial_flow_or_settings()
	elif GameData.last_adventure_episode_conquered:
		GameData.last_adventure_episode_conquered = false
		update_adventure_episodes_ui()
		adventure_episodes_modal.visible = true
	elif GameData.is_campaign_mode:
		var active_state = GameData.get_active_campaign_team_state()
		if active_state.size() > 0:
			update_campaign_ui()
			campaign_modal.visible = true
			_check_and_run_camp_evolutions()

func refresh_cards_data_from_catalog() -> void:
	cards_data.clear()
	all_catalog_cards.clear()
	for id in GameData.all_pokemon_ids:
		if not GameData.pokemon_catalog.has(id):
			continue
		var d = GameData.pokemon_catalog[id]
		var entry = d.duplicate()
		entry["id"] = d["id"]
		entry["pokedex_num"] = str(d.get("pokedex_num", "1"))
		entry["name"] = "%s (No. %s)" % [d["name"], entry["pokedex_num"]]
		entry["short_name"] = d["name"]
		entry["stage"] = d.get("stage", "Basic")
		entry["rarity"] = d.get("rarity", "Common")
		entry["region"] = str(d.get("region", "Kanto"))
		entry["type"] = d["type"]
		entry["hp"] = d["hp"]
		entry["spd"] = d["speed"]
		entry["speed"] = d["speed"]
		entry["texture"] = d["texture_path"]
		
		var passive_str = ""
		if str(d.get("passive_name", "")).strip_edges() != "":
			passive_str = "✨ Passive: %s\n" % d["passive_name"]
			
		var r_info = GameData.get_rarity_display_info(entry["rarity"])
		var eff_resists = GameData.get_effective_resistances(d["type"], d["resistant"])
		var res_str = ", ".join(eff_resists) if not eff_resists.is_empty() else "NONE"
		entry["info"] = "HP: %d | SPD: %d | Type: %s | %s\nStage: %s | Weak: %s | Res: %s\n%s• %s (%d DMG) [%s]\n• %s (%d DMG) [%s]" % [
			d["hp"], d["speed"], d["type"], r_info.get("name", "Common"),
			d.get("stage", "Basic"), d["weakness"], res_str,
			passive_str,
			d["m1_name"], d["m1_dmg"], d["m1_type"],
			d["m2_name"], d["m2_dmg"], d["m2_type"]
		]
		all_catalog_cards.append(entry)
		if GameData.is_pokemon_unlocked(id):
			cards_data.append(entry)
	current_sorted_collection = get_sorted_cards(all_catalog_cards, collection_sort_mode)

# --- SISTEMA DE ORDENAMIENTO (ID, DEX, ALFABÉTICO) ---
func get_sorted_cards(cards: Array, mode: String) -> Array:
	var result = cards.duplicate()
	match mode:
		"DEX":
			result.sort_custom(func(a, b):
				var num_a = int(a.get("pokedex_num", 0))
				var num_b = int(b.get("pokedex_num", 0))
				if num_a != num_b:
					return num_a < num_b
				return int(a.get("id", 0)) < int(b.get("id", 0))
			)
		"NAME":
			result.sort_custom(func(a, b):
				var name_a = str(a.get("short_name", a.get("name", ""))).to_lower()
				var name_b = str(b.get("short_name", b.get("name", ""))).to_lower()
				if name_a != name_b:
					return name_a < name_b
				return int(a.get("id", 0)) < int(b.get("id", 0))
			)
		"EVO":
			result.sort_custom(func(a, b):
				var status_a = GameData.get_pokemon_evolution_chain_status(int(a.get("id", 0)))
				var status_b = GameData.get_pokemon_evolution_chain_status(int(b.get("id", 0)))
				var rank_a = int(status_a.get("sort_rank", 4))
				var rank_b = int(status_b.get("sort_rank", 4))
				if rank_a != rank_b:
					return rank_a < rank_b
				var num_a = int(a.get("pokedex_num", 0))
				var num_b = int(b.get("pokedex_num", 0))
				if num_a != num_b:
					return num_a < num_b
				return int(a.get("id", 0)) < int(b.get("id", 0))
			)
		"OWNED":
			result.sort_custom(func(a, b):
				var owned_a = GameData.is_pokemon_unlocked(int(a.get("id", 0)))
				var owned_b = GameData.is_pokemon_unlocked(int(b.get("id", 0)))
				if owned_a != owned_b:
					return owned_a and not owned_b
				var num_a = int(a.get("pokedex_num", 0))
				var num_b = int(b.get("pokedex_num", 0))
				if num_a != num_b:
					return num_a < num_b
				return int(a.get("id", 0)) < int(b.get("id", 0))
			)
		"RARITY":
			result.sort_custom(func(a, b):
				var rarity_a = str(a.get("rarity", ""))
				if rarity_a == "":
					var cat_a = GameData.pokemon_catalog.get(int(a.get("id", 0)), {})
					rarity_a = str(cat_a.get("rarity", "Common"))
				var rarity_b = str(b.get("rarity", ""))
				if rarity_b == "":
					var cat_b = GameData.pokemon_catalog.get(int(b.get("id", 0)), {})
					rarity_b = str(cat_b.get("rarity", "Common"))
				var r_a = GameData.get_rarity_sort_rank(rarity_a)
				var r_b = GameData.get_rarity_sort_rank(rarity_b)
				if r_a != r_b:
					return r_a < r_b
				var num_a = int(a.get("pokedex_num", 0))
				var num_b = int(b.get("pokedex_num", 0))
				if num_a != num_b:
					return num_a < num_b
				return int(a.get("id", 0)) < int(b.get("id", 0))
			)
		"TIER":
			result.sort_custom(func(a, b):
				var tier_rank_map = {"S+": 0, "S": 1, "A": 2, "B": 3, "C": 4, "D": 5}
				var t_a = tier_rank_map.get(str(a.get("tier", "C")).strip_edges().to_upper(), 4)
				var t_b = tier_rank_map.get(str(b.get("tier", "C")).strip_edges().to_upper(), 4)
				if t_a != t_b:
					return t_a < t_b
				var num_a = int(a.get("pokedex_num", 0))
				var num_b = int(b.get("pokedex_num", 0))
				if num_a != num_b:
					return num_a < num_b
				return int(a.get("id", 0)) < int(b.get("id", 0))
			)
		"ID", _:
			result.sort_custom(func(a, b):
				return int(a.get("id", 0)) < int(b.get("id", 0))
			)
	return result

func update_collection_sort_buttons_ui() -> void:
	if not btn_col_sort_id or not btn_col_sort_dex or not btn_col_sort_alpha:
		return
	btn_col_sort_id.button_pressed = (collection_sort_mode == "ID")
	btn_col_sort_dex.button_pressed = (collection_sort_mode == "DEX")
	btn_col_sort_alpha.button_pressed = (collection_sort_mode == "NAME")
	if btn_col_sort_rarity:
		btn_col_sort_rarity.button_pressed = (collection_sort_mode == "RARITY")
		btn_col_sort_rarity.modulate = Color(1.2, 1.2, 0.4) if collection_sort_mode == "RARITY" else Color(0.8, 0.8, 0.8)
	if btn_col_sort_owned:
		btn_col_sort_owned.button_pressed = (collection_sort_mode == "OWNED")
		btn_col_sort_owned.modulate = Color(1.2, 1.2, 0.4) if collection_sort_mode == "OWNED" else Color(0.8, 0.8, 0.8)
	btn_col_sort_id.modulate = Color(1.2, 1.2, 0.4) if collection_sort_mode == "ID" else Color(0.8, 0.8, 0.8)
	btn_col_sort_dex.modulate = Color(1.2, 1.2, 0.4) if collection_sort_mode == "DEX" else Color(0.8, 0.8, 0.8)
	btn_col_sort_alpha.modulate = Color(1.2, 1.2, 0.4) if collection_sort_mode == "NAME" else Color(0.8, 0.8, 0.8)

func _on_col_sort_pressed(mode: String) -> void:
	collection_sort_mode = mode
	update_collection_sort_buttons_ui()
	populate_collection_grid()

func update_team_sort_buttons_ui() -> void:
	if not btn_team_sort_id or not btn_team_sort_dex or not btn_team_sort_alpha:
		return
	btn_team_sort_id.button_pressed = (team_sort_mode == "ID")
	btn_team_sort_dex.button_pressed = (team_sort_mode == "DEX")
	btn_team_sort_alpha.button_pressed = (team_sort_mode == "NAME")
	if btn_team_sort_rarity:
		btn_team_sort_rarity.button_pressed = (team_sort_mode == "RARITY")
		btn_team_sort_rarity.modulate = Color(1.2, 1.2, 0.4) if team_sort_mode == "RARITY" else Color(0.8, 0.8, 0.8)
	btn_team_sort_id.modulate = Color(1.2, 1.2, 0.4) if team_sort_mode == "ID" else Color(0.8, 0.8, 0.8)
	btn_team_sort_dex.modulate = Color(1.2, 1.2, 0.4) if team_sort_mode == "DEX" else Color(0.8, 0.8, 0.8)
	btn_team_sort_alpha.modulate = Color(1.2, 1.2, 0.4) if team_sort_mode == "NAME" else Color(0.8, 0.8, 0.8)
	
	if btn_team_sort_evo:
		btn_team_sort_evo.visible = (team_select_mode == "CAMPAIGN")
		btn_team_sort_evo.button_pressed = (team_sort_mode == "EVO")
		btn_team_sort_evo.modulate = Color(1.2, 1.2, 0.4) if team_sort_mode == "EVO" else Color(0.8, 0.8, 0.8)

func _on_team_sort_pressed(mode: String) -> void:
	team_sort_mode = mode
	update_team_sort_buttons_ui()
	build_team_select_cards_grid()
	update_team_select_ui()

# --- NAVEGACIÓN ---
func _on_campaign_pressed() -> void:
	if not GameData.tutorial_completed and GameData.tutorial_step == 1:
		_start_tutorial_flow_or_settings()
		return
	refresh_cards_data_from_catalog()
	update_campaign_hub_ui()
	campaign_hub_modal.visible = true

func update_campaign_hub_ui() -> void:
	var hub_badge = campaign_hub_modal.get_node_or_null("Box/HubWalletBadge")
	if hub_badge:
		hub_badge.text = "💰 Campaign Gold: %d G  |  💎 %d Diamonds" % [
			GameData.campaign_gold,
			GameData.player_diamonds
		]
	var hub_desc = campaign_hub_modal.get_node_or_null("Box/Desc")
	if hub_desc:
		hub_desc.text = "Choose your path: learn battle tactics, explore Adventure episodes, or challenge Pokémon Stadium!"
		
	# 1. Estado del Tutorial
	if GameData.is_tutorial_completed():
		tutorial_status_lbl.text = "Status: ✅ Completed (💎 5 Diamonds Claimed) • Replayable"
		tutorial_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_hub_tutorial.text = "🔄 Replay Tutorial (Practice)"
	else:
		tutorial_status_lbl.text = "Status: ⏳ Not completed • First Clear: 💎 5 Diamonds & Unlocks Adventure"
		tutorial_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
		btn_hub_tutorial.text = "🎓 Start Tutorial"

	# 2. Estado de Adventure Mode
	if not GameData.is_tutorial_completed():
		adv_status_lbl.text = "Status: 🔒 Locked (Complete Battle Tutorial to unlock!)"
		adv_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
		btn_hub_adventure.text = "🔒 Locked (Complete Tutorial)"
	else:
		var ep1_done = GameData.is_adventure_episode_completed(1)
		var ep2_done = GameData.is_adventure_episode_completed(2)
		if not GameData.adventure_player_team_state.is_empty():
			var cur_ep_roman = {1: "I", 2: "II", 3: "III", 4: "IV", 5: "V", 6: "VI", 7: "VII"}.get(GameData.adventure_current_episode, str(GameData.adventure_current_episode))
			adv_status_lbl.text = "Status: In Progress • Episode %s (Stage %d/%d)" % [
				cur_ep_roman,
				GameData.adventure_current_stage,
				GameData.get_adventure_total_stages(GameData.adventure_current_episode)
			]
			adv_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
			btn_hub_adventure.text = "🗺️ Continue Adventure (Episodes) ➜"
		elif ep2_done:
			adv_status_lbl.text = "Status: 🔓 Unlocked • Ep. I & II Conquered (Cascade Badge Won!)"
			adv_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			btn_hub_adventure.text = "🗺️ Enter Adventure Mode (Episodes) ➜"
		elif ep1_done:
			adv_status_lbl.text = "Status: 🔓 Unlocked • Episode I Conquered (Boulder Badge Won!)"
			adv_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			btn_hub_adventure.text = "🗺️ Enter Adventure Mode (Episodes) ➜"
		else:
			adv_status_lbl.text = "Status: 🔓 Unlocked • Ready to embark!"
			adv_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
			btn_hub_adventure.text = "🗺️ Enter Adventure Mode (Episodes) ➜"

	# 3. Estado de Pokémon Stadium (Arcade Tournament)
	if GameData.campaign_player_team_state.is_empty():
		tourn_status_lbl.text = "Status: No active run • Ready to challenge"
		tourn_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_tournament.text = "⚔️ Enter Pokémon Stadium"
	else:
		if GameData.campaign_match_number > GameData.TOURNAMENT_TOTAL_MATCHES:
			tourn_status_lbl.text = "Status: 🏆 Stadium Champion! Ready for new run"
			tourn_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			btn_hub_tournament.text = "🏆 Review / Restart Pokémon Stadium"
		else:
			tourn_status_lbl.text = "Status: In Progress (Battle %d/%d)" % [
				GameData.campaign_match_number,
				GameData.TOURNAMENT_TOTAL_MATCHES
			]
			tourn_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
			btn_hub_tournament.text = "⛺ Continue Stadium Run (Camp)"

func update_adventure_episodes_ui() -> void:
	var ep_badge = adventure_episodes_modal.get_node_or_null("Box/EpisodesWalletBadge")
	if ep_badge:
		ep_badge.text = "💰 Campaign Gold: %d G  |  💎 %d Diamonds" % [
			GameData.campaign_gold,
			GameData.player_diamonds
		]
		
	# Estado del Episodio I
	var ep1_completed = GameData.is_adventure_episode_completed(1)
	if not GameData.is_tutorial_completed():
		ep1_status_lbl.text = "Status: 🔒 Locked (Complete Tutorial First!)"
		ep1_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
		btn_hub_adventure_ep1.text = "🔒 Locked (Complete Tutorial)"
		btn_hub_adventure_ep1.disabled = false
	elif GameData.adventure_current_episode == 1 and not GameData.adventure_player_team_state.is_empty():
		var total_stages1 = GameData.get_adventure_total_stages(1)
		ep1_status_lbl.text = "Status: In Progress (Stage %d/%d)" % [
			GameData.adventure_current_stage,
			total_stages1
		]
		ep1_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		btn_hub_adventure_ep1.text = "⛺ Continue Episode I (Camp)"
		btn_hub_adventure_ep1.disabled = false
	elif ep1_completed:
		ep1_status_lbl.text = "Status: 🏅 COMPLETED (Boulder Badge Won!) • Replayable"
		ep1_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_hub_adventure_ep1.text = "🗺️ Replay Episode I"
		btn_hub_adventure_ep1.disabled = false
	else:
		ep1_status_lbl.text = "Status: Ready to embark"
		ep1_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_adventure_ep1.text = "🗺️ Embark on Episode I"
		btn_hub_adventure_ep1.disabled = false
		
	# Estado del Episodio II
	var ep2_unlocked = GameData.is_adventure_episode_unlocked(2)
	var ep2_completed = GameData.is_adventure_episode_completed(2)
	if not ep2_unlocked:
		ep2_status_lbl.text = "Status: 🔒 Locked (Complete Episode I first)"
		ep2_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
		btn_hub_adventure_ep2.text = "🔒 Locked (Clear Episode I)"
		btn_hub_adventure_ep2.disabled = true
	elif GameData.adventure_current_episode == 2 and not GameData.adventure_player_team_state.is_empty():
		var total_stages2 = GameData.get_adventure_total_stages(2)
		ep2_status_lbl.text = "Status: In Progress (Stage %d/%d)" % [
			GameData.adventure_current_stage,
			total_stages2
		]
		ep2_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		btn_hub_adventure_ep2.text = "⛺ Continue Episode II (Camp)"
		btn_hub_adventure_ep2.disabled = false
	elif ep2_completed:
		ep2_status_lbl.text = "Status: 🏅 COMPLETED (Cascade Badge Won!) • Replayable"
		ep2_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_hub_adventure_ep2.text = "🗺️ Replay Episode II"
		btn_hub_adventure_ep2.disabled = false
	else:
		ep2_status_lbl.text = "Status: Ready to embark"
		ep2_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_adventure_ep2.text = "🗺️ Embark on Episode II"
		btn_hub_adventure_ep2.disabled = false

	# Estado del Episodio III
	var ep3_unlocked = GameData.is_adventure_episode_unlocked(3)
	var ep3_completed = GameData.is_adventure_episode_completed(3)
	if not ep3_unlocked:
		ep3_status_lbl.text = "Status: 🔒 Locked (Complete Episode II first)"
		ep3_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
		btn_hub_adventure_ep3.text = "🔒 Locked (Clear Episode II)"
		btn_hub_adventure_ep3.disabled = true
	elif GameData.adventure_current_episode == 3 and not GameData.adventure_player_team_state.is_empty():
		var total_stages3 = GameData.get_adventure_total_stages(3)
		ep3_status_lbl.text = "Status: In Progress (Stage %d/%d)" % [
			GameData.adventure_current_stage,
			total_stages3
		]
		ep3_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		btn_hub_adventure_ep3.text = "⛺ Continue Episode III (Camp)"
		btn_hub_adventure_ep3.disabled = false
	elif ep3_completed:
		ep3_status_lbl.text = "Status: 🏅 COMPLETED (Thunder Badge Won!) • Replayable"
		ep3_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_hub_adventure_ep3.text = "🗺️ Replay Episode III"
		btn_hub_adventure_ep3.disabled = false
	else:
		ep3_status_lbl.text = "Status: Ready to embark"
		ep3_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_adventure_ep3.text = "🗺️ Embark on Episode III"
		btn_hub_adventure_ep3.disabled = false

	# Estado del Episodio IV
	var ep4_unlocked = GameData.is_adventure_episode_unlocked(4)
	var ep4_completed = GameData.is_adventure_episode_completed(4)
	var card_ep4 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp4")
	if card_ep4:
		card_ep4.modulate = Color(1, 1, 1, 1) if ep4_unlocked else Color(0.7, 0.7, 0.75, 0.8)
	var ep4_title_lbl = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp4/Margin/Ep4VBox/Ep4Title") as Label
	if ep4_title_lbl:
		ep4_title_lbl.text = "Episode IV: Celadon City Gym" if ep4_unlocked else "🔒 Episode IV: Celadon City Gym"
		ep4_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if ep4_completed else (Color(1, 1, 1) if ep4_unlocked else Color(0.5, 0.6, 0.7)))
	var ep4_rewards_lbl = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp4/Margin/Ep4VBox/Ep4Rewards") as Label
	if ep4_rewards_lbl:
		ep4_rewards_lbl.text = "Battles: 8  |  First Clear: 💎 35 Diamonds & Rainbow Badge"
		ep4_rewards_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65) if ep4_unlocked else Color(0.5, 0.6, 0.7))

	if not ep4_unlocked:
		ep4_status_lbl.text = "Status: 🔒 Locked (Complete Episode III first)"
		ep4_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
		btn_hub_adventure_ep4.text = "🔒 Locked (Clear Episode III)"
		btn_hub_adventure_ep4.disabled = true
		_apply_retro_button_style(btn_hub_adventure_ep4, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
	elif GameData.adventure_current_episode == 4 and not GameData.adventure_player_team_state.is_empty():
		var total_stages4 = GameData.get_adventure_total_stages(4)
		ep4_status_lbl.text = "Status: In Progress (Stage %d/%d)" % [
			GameData.adventure_current_stage,
			total_stages4
		]
		ep4_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		btn_hub_adventure_ep4.text = "⛺ Continue Episode IV (Camp)"
		btn_hub_adventure_ep4.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep4, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	elif ep4_completed:
		ep4_status_lbl.text = "Status: 🏅 COMPLETED (Rainbow Badge Won!) • Replayable"
		ep4_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_hub_adventure_ep4.text = "🗺️ Replay Episode IV"
		btn_hub_adventure_ep4.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep4, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	else:
		ep4_status_lbl.text = "Status: Ready to embark"
		ep4_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_adventure_ep4.text = "🗺️ Embark on Episode IV"
		btn_hub_adventure_ep4.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep4, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)

	# Estado del Episodio V
	var ep5_unlocked = GameData.is_adventure_episode_unlocked(5)
	var ep5_completed = GameData.is_adventure_episode_completed(5)
	var card_ep5 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp5")
	if card_ep5:
		card_ep5.modulate = Color(1, 1, 1, 1) if ep5_unlocked else Color(0.7, 0.7, 0.75, 0.8)
	var ep5_title_lbl = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp5/Margin/Ep5VBox/Ep5Title") as Label
	if ep5_title_lbl:
		ep5_title_lbl.text = "Episode V: Team Rocket, Pokémon Tower & Fuchsia Gym" if ep5_unlocked else "🔒 Episode V: Team Rocket, Pokémon Tower & Fuchsia Gym"
		ep5_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if ep5_completed else (Color(1, 1, 1) if ep5_unlocked else Color(0.5, 0.6, 0.7)))
	var ep5_rewards_lbl = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp5/Margin/Ep5VBox/Ep5Rewards") as Label
	if ep5_rewards_lbl:
		ep5_rewards_lbl.text = "3 Infiltration Routes  |  Rewards: 💎 50 Diamonds, 🎶 Poké Flute & Soul Badge"
		ep5_rewards_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65) if ep5_unlocked else Color(0.5, 0.6, 0.7))

	if not ep5_unlocked:
		ep5_status_lbl.text = "Status: 🔒 Locked (Complete Episode IV first)"
		ep5_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
		btn_hub_adventure_ep5.text = "🔒 Locked (Clear Episode IV)"
		btn_hub_adventure_ep5.disabled = true
		_apply_retro_button_style(btn_hub_adventure_ep5, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
	elif GameData.adventure_current_episode == 5 and not GameData.adventure_player_team_state.is_empty():
		var cur_r = GameData.adventure_ep5_selected_route
		var r_info = GameData.get_adventure_route_info(5, cur_r)
		var total_stages5 = GameData.get_adventure_total_stages(5)
		ep5_status_lbl.text = "Status: In Progress (%s • Stage %d/%d)" % [
			str(r_info.get("name_es", "Route")),
			GameData.adventure_current_stage,
			total_stages5
		]
		ep5_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		btn_hub_adventure_ep5.text = "⛺ Continue Episode V (Camp)"
		btn_hub_adventure_ep5.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep5, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	elif ep5_completed:
		ep5_status_lbl.text = "Status: 🏅 COMPLETED (Soul Badge Won!) • 3 Routes Available"
		ep5_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_hub_adventure_ep5.text = "🗺️ Enter Episode V Routes"
		btn_hub_adventure_ep5.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep5, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	else:
		var cleared_cnt = GameData.adventure_ep5_cleared_routes.size()
		ep5_status_lbl.text = "Status: Ready to embark (%d/3 Routes Cleared)" % cleared_cnt
		ep5_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_adventure_ep5.text = "🗺️ Embark on Episode V"
		btn_hub_adventure_ep5.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep5, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)

	# Estado del Episodio VI
	var ep6_unlocked = GameData.is_adventure_episode_unlocked(6)
	var ep6_completed = GameData.is_adventure_episode_completed(6)
	var card_ep6 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp6")
	if card_ep6:
		card_ep6.modulate = Color(1, 1, 1, 1) if ep6_unlocked else Color(0.7, 0.7, 0.75, 0.8)
	var ep6_title_lbl = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp6/Margin/Ep6VBox/Ep6Title") as Label
	if ep6_title_lbl:
		ep6_title_lbl.text = "Episode VI: Silph Co. & Saffron City Gym" if ep6_unlocked else "🔒 Episode VI: Silph Co. & Saffron City Gym"
		ep6_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if ep6_completed else (Color(1, 1, 1) if ep6_unlocked else Color(0.5, 0.6, 0.7)))
	var ep6_rewards_lbl = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp6/Margin/Ep6VBox/Ep6Rewards") as Label
	if ep6_rewards_lbl:
		ep6_rewards_lbl.text = "3 Operations  |  Rewards: 💎 60 Diamonds, Hitmonlee, Hitmonchan & Marsh Badge"
		ep6_rewards_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65) if ep6_unlocked else Color(0.5, 0.6, 0.7))

	if not ep6_unlocked:
		ep6_status_lbl.text = "Status: 🔒 Locked (Complete Episode V first)"
		ep6_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
		btn_hub_adventure_ep6.text = "🔒 Locked (Clear Episode V)"
		btn_hub_adventure_ep6.disabled = true
		_apply_retro_button_style(btn_hub_adventure_ep6, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
	elif GameData.adventure_current_episode == 6 and not GameData.adventure_player_team_state.is_empty():
		var cur_r = GameData.adventure_ep6_selected_route
		var r_info = GameData.get_adventure_route_info(6, cur_r)
		var total_stages6 = GameData.get_adventure_total_stages(6)
		ep6_status_lbl.text = "Status: In Progress (%s • Stage %d/%d)" % [
			str(r_info.get("name_es", "Route")),
			GameData.adventure_current_stage,
			total_stages6
		]
		ep6_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		btn_hub_adventure_ep6.text = "⛺ Continue Episode VI (Camp)"
		btn_hub_adventure_ep6.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep6, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	elif ep6_completed:
		ep6_status_lbl.text = "Status: 🏅 COMPLETED (Marsh Badge Won!) • 3 Routes Available"
		ep6_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_hub_adventure_ep6.text = "🗺️ Enter Episode VI Routes"
		btn_hub_adventure_ep6.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep6, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	else:
		var cleared_cnt = GameData.adventure_ep6_cleared_routes.size()
		ep6_status_lbl.text = "Status: Ready to embark (%d/3 Routes Cleared)" % cleared_cnt
		ep6_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_adventure_ep6.text = "🗺️ Embark on Episode VI"
		btn_hub_adventure_ep6.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep6, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)

	var ep7_unlocked = GameData.is_adventure_episode_unlocked(7)
	var ep7_completed = GameData.is_adventure_episode_completed(7)
	var card_ep7 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp7")
	if card_ep7:
		card_ep7.modulate = Color(1, 1, 1, 1) if ep7_unlocked else Color(0.7, 0.7, 0.75, 0.8)
	var ep7_title_lbl = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp7/Margin/Ep7VBox/Ep7Title") as Label
	if ep7_title_lbl:
		ep7_title_lbl.text = "Episode VII: Pokémon Mansion & Cinnabar Gym" if ep7_unlocked else "🔒 Episode VII: Pokémon Mansion & Cinnabar Gym"
		ep7_title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if ep7_completed else (Color(1, 1, 1) if ep7_unlocked else Color(0.5, 0.6, 0.7)))
	var ep7_rewards_lbl = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp7/Margin/Ep7VBox/Ep7Rewards") as Label
	if ep7_rewards_lbl:
		ep7_rewards_lbl.text = "2 Operations  |  Rewards: 💎 70 Diamonds & Volcano Badge"
		ep7_rewards_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65) if ep7_unlocked else Color(0.5, 0.6, 0.7))

	if not ep7_unlocked:
		ep7_status_lbl.text = "Status: 🔒 Locked (Complete Episode VI first)"
		ep7_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
		btn_hub_adventure_ep7.text = "🔒 Locked (Clear Episode VI)"
		btn_hub_adventure_ep7.disabled = true
		_apply_retro_button_style(btn_hub_adventure_ep7, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
	elif GameData.adventure_current_episode == 7 and not GameData.adventure_player_team_state.is_empty():
		var cur_r = GameData.adventure_ep7_selected_route
		var r_info = GameData.get_adventure_route_info(7, cur_r)
		var total_stages7 = GameData.get_adventure_total_stages(7)
		ep7_status_lbl.text = "Status: In Progress (%s • Stage %d/%d)" % [
			str(r_info.get("name_es", "Route")),
			GameData.adventure_current_stage,
			total_stages7
		]
		ep7_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		btn_hub_adventure_ep7.text = "⛺ Continue Episode VII (Camp)"
		btn_hub_adventure_ep7.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep7, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	elif ep7_completed:
		ep7_status_lbl.text = "Status: 🏅 COMPLETED (Volcano Badge Won!) • 2 Routes Available"
		ep7_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_hub_adventure_ep7.text = "🗺️ Enter Episode VII Routes"
		btn_hub_adventure_ep7.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep7, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	else:
		var cleared_cnt = GameData.adventure_ep7_cleared_routes.size()
		ep7_status_lbl.text = "Status: Ready to embark (%d/2 Routes Cleared)" % cleared_cnt
		ep7_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_adventure_ep7.text = "🗺️ Embark on Episode VII"
		btn_hub_adventure_ep7.disabled = false
		_apply_retro_button_style(btn_hub_adventure_ep7, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)

func _on_hub_adventure_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	if not GameData.is_tutorial_completed():
		_show_tutorial_prompt_for_locked_episode()
		return
	campaign_hub_modal.visible = false
	update_adventure_episodes_ui()
	adventure_episodes_modal.visible = true

func _on_select_tournament_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	campaign_hub_modal.visible = false
	GameData.campaign_submode = "TOURNAMENT"
	if GameData.campaign_player_team_state.is_empty():
		open_team_select_for_campaign()
	else:
		update_campaign_ui()
		campaign_modal.visible = true
		_check_and_run_camp_evolutions()

func _on_select_adventure_episode_pressed(episode_id: int) -> void:
	if GameData.is_drag_scrolling():
		return
	if not GameData.is_tutorial_completed():
		_show_tutorial_prompt_for_locked_episode()
		return
	if not GameData.is_adventure_episode_unlocked(episode_id):
		return
	adventure_episodes_modal.visible = false
	GameData.campaign_submode = "ADVENTURE"
	if GameData.adventure_current_episode != episode_id:
		GameData.reset_adventure_episode(episode_id)
	GameData.adventure_current_episode = episode_id
	if GameData.adventure_player_team_state.is_empty():
		open_team_select_for_campaign()
	else:
		update_campaign_ui()
		campaign_modal.visible = true
		_check_and_run_camp_evolutions()

func _on_select_adventure_ep1_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	_on_select_adventure_episode_pressed(1)

func _on_select_adventure_ep2_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	_on_select_adventure_episode_pressed(2)

func _on_select_adventure_ep3_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	_on_select_adventure_episode_pressed(3)

func _on_select_adventure_ep4_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	_on_select_adventure_episode_pressed(4)

func _on_select_adventure_ep5_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	if not GameData.is_tutorial_completed():
		_show_tutorial_prompt_for_locked_episode()
		return
	if not GameData.is_adventure_episode_unlocked(5):
		return
	adventure_episodes_modal.visible = false
	_open_adventure_ep5_routes_modal()

func _open_adventure_ep5_routes_modal() -> void:
	_setup_adventure_ep5_routes_modal()
	_refresh_adventure_ep5_routes_ui()
	adventure_ep5_routes_modal.visible = true

func _setup_adventure_ep5_routes_modal() -> void:
	if adventure_ep5_routes_modal != null:
		return
	adventure_ep5_routes_modal = Control.new()
	adventure_ep5_routes_modal.name = "AdventureEp5RoutesModal"
	adventure_ep5_routes_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	adventure_ep5_routes_modal.visible = false
	adventure_ep5_routes_modal.z_index = 45
	add_child(adventure_ep5_routes_modal)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.04, 0.08, 0.88)
	adventure_ep5_routes_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	adventure_ep5_routes_modal.add_child(center)
	
	var panel = PanelContainer.new()
	var ep5_target_w: float = minf(460.0, get_viewport_rect().size.x - 24.0)
	panel.custom_minimum_size = Vector2(ep5_target_w, 0)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color(0.3, 0.75, 0.85, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	var title_lbl = Label.new()
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.text = "🗺️ EPISODE V: REGIONAL OBJECTIVES"
	title_lbl.add_theme_font_size_override("font_size", 17)
	title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	vbox.add_child(title_lbl)
	
	var subtitle_lbl = Label.new()
	subtitle_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_lbl.text = "Select your target operation across Kanto:"
	subtitle_lbl.add_theme_font_size_override("font_size", 12)
	subtitle_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	vbox.add_child(subtitle_lbl)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var routes_vbox = VBoxContainer.new()
	routes_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes_vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(routes_vbox)
	
	var routes_def = [
		{
			"id": "rocket_hideout",
			"name": "Base Secreta del Team Rocket",
			"desc": "Infiltrate Team Rocket's underground base in Celadon and defeat Boss Giovanni!",
			"rewards": "5 Combates  |  Reward: 💎 20 Diamonds • Unlocks Tower & Gym"
		},
		{
			"id": "pokemon_tower",
			"name": "Torre Pokémon (Lavender Town)",
			"desc": "Climb the haunted tower, calm the restless ghosts and free the possessed trainer!",
			"rewards": "4 Combates  |  Reward: 💎 15 Diamonds & 🎶 Poké Flute (Permanent Item)"
		},
		{
			"id": "fuchsia_gym",
			"name": "Gimnasio de Koga (Fuchsia City)",
			"desc": "Challenge Ninja Master Koga and his toxic masters to win the Soul Badge!",
			"rewards": "3 Combates  |  Reward: 💎 15 Diamonds & 🏅 Soul Badge • Unlocks Ep. VI"
		}
	]
	
	for r in routes_def:
		var r_id = r["id"]
		var c_panel = PanelContainer.new()
		c_panel.name = "RouteCard_" + r_id
		var c_sb = StyleBoxFlat.new()
		c_sb.bg_color = Color(0.12, 0.17, 0.24, 0.95)
		c_sb.border_color = Color(0.25, 0.45, 0.60, 0.8)
		c_sb.set_border_width_all(1)
		c_sb.set_corner_radius_all(6)
		c_sb.content_margin_left = 12
		c_sb.content_margin_right = 12
		c_sb.content_margin_top = 10
		c_sb.content_margin_bottom = 10
		c_panel.add_theme_stylebox_override("panel", c_sb)
		routes_vbox.add_child(c_panel)
		
		var cvbox = VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 4)
		c_panel.add_child(cvbox)
		
		var r_title = Label.new()
		r_title.name = "Title"
		r_title.text = r["name"]
		r_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_title.add_theme_font_size_override("font_size", 14)
		r_title.add_theme_color_override("font_color", Color(1, 1, 1))
		cvbox.add_child(r_title)
		
		var r_desc = Label.new()
		r_desc.name = "Desc"
		r_desc.text = r["desc"]
		r_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_desc.add_theme_font_size_override("font_size", 11)
		r_desc.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
		cvbox.add_child(r_desc)
		
		var r_rew = Label.new()
		r_rew.name = "Rewards"
		r_rew.text = r["rewards"]
		r_rew.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_rew.add_theme_font_size_override("font_size", 11)
		r_rew.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		cvbox.add_child(r_rew)
		
		var r_status = Label.new()
		r_status.name = "Status"
		r_status.text = "Status: Ready"
		r_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_status.add_theme_font_size_override("font_size", 11)
		r_status.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		cvbox.add_child(r_status)
		
		var r_btn = Button.new()
		r_btn.name = "Btn"
		r_btn.custom_minimum_size = Vector2(0, 36)
		r_btn.add_theme_font_size_override("font_size", 12)
		r_btn.text = "Select Route"
		_apply_retro_button_style(r_btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
		r_btn.pressed.connect(func():
			if GameData.is_drag_scrolling():
				return
			_on_select_adventure_ep5_route_pressed(r_id)
		)
		cvbox.add_child(r_btn)
		
		ep5_route_cards[r_id] = {
			"panel": c_panel,
			"title": r_title,
			"status": r_status,
			"rewards": r_rew,
			"btn": r_btn
		}
		
	var btn_close_routes = Button.new()
	btn_close_routes.name = "BtnCloseEp5Routes"
	btn_close_routes.custom_minimum_size = Vector2(0, 38)
	btn_close_routes.add_theme_font_size_override("font_size", 13)
	btn_close_routes.text = "⬅ Back to Episode Select"
	_apply_retro_button_style(btn_close_routes, Color(0.25, 0.52, 0.60), Color(0.40, 0.85, 0.95), false)
	btn_close_routes.pressed.connect(func():
		if GameData.is_drag_scrolling():
			return
		adventure_ep5_routes_modal.visible = false
		update_adventure_episodes_ui()
		adventure_episodes_modal.visible = true
	)
	vbox.add_child(btn_close_routes)

func _refresh_adventure_ep5_routes_ui() -> void:
	for r_id in ep5_route_cards.keys():
		var card = ep5_route_cards[r_id]
		var c_panel: PanelContainer = card["panel"]
		var lbl_title: Label = card["title"]
		var lbl_status: Label = card["status"]
		var btn: Button = card["btn"]
		var is_unlocked = GameData.is_adventure_ep5_route_unlocked(r_id)
		var is_cleared = GameData.is_adventure_ep5_route_completed(r_id)
		var is_in_progress = (GameData.adventure_current_episode == 5 and GameData.adventure_ep5_selected_route == r_id and not GameData.adventure_player_team_state.is_empty())
		
		c_panel.modulate = Color(1, 1, 1, 1) if is_unlocked else Color(0.7, 0.7, 0.75, 0.8)
		
		if not is_unlocked:
			lbl_title.text = "🔒 " + card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7))
			lbl_status.text = "Status: 🔒 Locked (Defeat Giovanni at Rocket Hideout first)"
			lbl_status.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
			btn.text = "🔒 Locked"
			btn.disabled = true
			_apply_retro_button_style(btn, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
		elif is_in_progress:
			var total_st = GameData.get_adventure_total_stages(5)
			lbl_title.text = card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
			lbl_status.text = "Status: In Progress (Stage %d/%d)" % [GameData.adventure_current_stage, total_st]
			lbl_status.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
			btn.text = "⛺ Continue Operation (Camp)"
			btn.disabled = false
			_apply_retro_button_style(btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
		elif is_cleared:
			lbl_title.text = card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			lbl_status.text = "Status: 🏅 COMPLETED • Replayable"
			lbl_status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			btn.text = "🗺️ Replay Operation"
			btn.disabled = false
			_apply_retro_button_style(btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
		else:
			lbl_title.text = card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(1, 1, 1))
			lbl_status.text = "Status: Ready to deploy"
			lbl_status.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
			btn.text = "🗺️ Embark on Route"
			btn.disabled = false
			_apply_retro_button_style(btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)

func _on_select_adventure_ep5_route_pressed(route_id: String) -> void:
	if not GameData.is_adventure_ep5_route_unlocked(route_id):
		return
	if adventure_ep5_routes_modal:
		adventure_ep5_routes_modal.visible = false
	adventure_episodes_modal.visible = false
	GameData.campaign_submode = "ADVENTURE"
	
	if GameData.adventure_current_episode == 5 and GameData.adventure_ep5_selected_route == route_id and not GameData.adventure_player_team_state.is_empty():
		update_campaign_ui()
		campaign_modal.visible = true
		_check_and_run_camp_evolutions()
	else:
		GameData.adventure_ep5_selected_route = route_id
		GameData.reset_adventure_episode(5)
		GameData.adventure_current_episode = 5
		open_team_select_for_campaign()

func _on_select_adventure_ep6_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	if not GameData.is_tutorial_completed():
		_show_tutorial_prompt_for_locked_episode()
		return
	if not GameData.is_adventure_episode_unlocked(6):
		return
	adventure_episodes_modal.visible = false
	_open_adventure_ep6_routes_modal()

func _open_adventure_ep6_routes_modal() -> void:
	_setup_adventure_ep6_routes_modal()
	_refresh_adventure_ep6_routes_ui()
	adventure_ep6_routes_modal.visible = true

func _setup_adventure_ep6_routes_modal() -> void:
	if adventure_ep6_routes_modal != null:
		return
	adventure_ep6_routes_modal = Control.new()
	adventure_ep6_routes_modal.name = "AdventureEp6RoutesModal"
	adventure_ep6_routes_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	adventure_ep6_routes_modal.visible = false
	adventure_ep6_routes_modal.z_index = 45
	add_child(adventure_ep6_routes_modal)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.04, 0.08, 0.88)
	adventure_ep6_routes_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	adventure_ep6_routes_modal.add_child(center)
	
	var panel = PanelContainer.new()
	var ep5_target_w: float = minf(460.0, get_viewport_rect().size.x - 24.0)
	panel.custom_minimum_size = Vector2(ep5_target_w, 0)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color(0.3, 0.75, 0.85, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	var title_lbl = Label.new()
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.text = "🗺️ EPISODE VI: REGIONAL OPERATIONS"
	title_lbl.add_theme_font_size_override("font_size", 17)
	title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	vbox.add_child(title_lbl)
	
	var subtitle_lbl = Label.new()
	subtitle_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_lbl.text = "Liberate Silph Co. skyscraper and confront Gym Leader Sabrina:"
	subtitle_lbl.add_theme_font_size_override("font_size", 12)
	subtitle_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	vbox.add_child(subtitle_lbl)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var routes_vbox = VBoxContainer.new()
	routes_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes_vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(routes_vbox)
	
	var routes_def = [
		{
			"id": "silph_co",
			"name": "Torre Silph S. A. (6 Combates)",
			"desc": "Infiltrate the 11-floor Silph Co. corporate skyscraper taken hostage by Team Rocket and defeat Boss Giovanni!",
			"rewards": "6 Combates  |  Reward: 💎 20 Diamonds • Unlocks Saffron Gym & PokéDojo"
		},
		{
			"id": "fighting_dojo",
			"name": "PokéDojo de Ciudad Azafrán (4 Combates)",
			"desc": "Challenge the black-belt masters of the Fighting Dojo and defeat Champion Koichi!",
			"rewards": "4 Combates  |  Reward: 💎 20 Diamonds & 🥋 Cartas Hitmonlee + Hitmonchan"
		},
		{
			"id": "saffron_gym",
			"name": "Gimnasio de Sabrina (4 Combates)",
			"desc": "Step into the teleporter maze of Saffron Gym and challenge Psychic Master Sabrina!",
			"rewards": "4 Combates  |  Reward: 💎 20 Diamonds & 🏅 Marsh Badge • Unlocks Ep. VII"
		}
	]
	
	for r in routes_def:
		var r_id = r["id"]
		var c_panel = PanelContainer.new()
		c_panel.name = "RouteCard_" + r_id
		var c_sb = StyleBoxFlat.new()
		c_sb.bg_color = Color(0.12, 0.17, 0.24, 0.95)
		c_sb.border_color = Color(0.25, 0.45, 0.60, 0.8)
		c_sb.set_border_width_all(1)
		c_sb.set_corner_radius_all(6)
		c_sb.content_margin_left = 12
		c_sb.content_margin_right = 12
		c_sb.content_margin_top = 10
		c_sb.content_margin_bottom = 10
		c_panel.add_theme_stylebox_override("panel", c_sb)
		routes_vbox.add_child(c_panel)
		
		var cvbox = VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 4)
		c_panel.add_child(cvbox)
		
		var r_title = Label.new()
		r_title.name = "Title"
		r_title.text = r["name"]
		r_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_title.add_theme_font_size_override("font_size", 14)
		r_title.add_theme_color_override("font_color", Color(1, 1, 1))
		cvbox.add_child(r_title)
		
		var r_desc = Label.new()
		r_desc.name = "Desc"
		r_desc.text = r["desc"]
		r_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_desc.add_theme_font_size_override("font_size", 11)
		r_desc.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
		cvbox.add_child(r_desc)
		
		var r_rew = Label.new()
		r_rew.name = "Rewards"
		r_rew.text = r["rewards"]
		r_rew.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_rew.add_theme_font_size_override("font_size", 11)
		r_rew.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		cvbox.add_child(r_rew)
		
		var r_status = Label.new()
		r_status.name = "Status"
		r_status.text = "Status: Ready"
		r_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_status.add_theme_font_size_override("font_size", 11)
		r_status.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		cvbox.add_child(r_status)
		
		var r_btn = Button.new()
		r_btn.name = "Btn"
		r_btn.custom_minimum_size = Vector2(0, 36)
		r_btn.add_theme_font_size_override("font_size", 12)
		r_btn.text = "Select Route"
		_apply_retro_button_style(r_btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
		r_btn.pressed.connect(func():
			if GameData.is_drag_scrolling():
				return
			_on_select_adventure_ep6_route_pressed(r_id)
		)
		cvbox.add_child(r_btn)
		
		ep6_route_cards[r_id] = {
			"panel": c_panel,
			"title": r_title,
			"status": r_status,
			"rewards": r_rew,
			"btn": r_btn
		}
		
	var btn_close_routes = Button.new()
	btn_close_routes.name = "BtnCloseEp6Routes"
	btn_close_routes.custom_minimum_size = Vector2(0, 38)
	btn_close_routes.add_theme_font_size_override("font_size", 13)
	btn_close_routes.text = "⬅ Back to Episode Select"
	_apply_retro_button_style(btn_close_routes, Color(0.25, 0.52, 0.60), Color(0.40, 0.85, 0.95), false)
	btn_close_routes.pressed.connect(func():
		if GameData.is_drag_scrolling():
			return
		adventure_ep6_routes_modal.visible = false
		update_adventure_episodes_ui()
		adventure_episodes_modal.visible = true
	)
	vbox.add_child(btn_close_routes)

func _refresh_adventure_ep6_routes_ui() -> void:
	for r_id in ep6_route_cards.keys():
		var card = ep6_route_cards[r_id]
		var c_panel: PanelContainer = card["panel"]
		var lbl_title: Label = card["title"]
		var lbl_status: Label = card["status"]
		var btn: Button = card["btn"]
		var is_unlocked = GameData.is_adventure_ep6_route_unlocked(r_id)
		var is_cleared = GameData.is_adventure_ep6_route_completed(r_id)
		var is_in_progress = (GameData.adventure_current_episode == 6 and GameData.adventure_ep6_selected_route == r_id and not GameData.adventure_player_team_state.is_empty())
		
		c_panel.modulate = Color(1, 1, 1, 1) if is_unlocked else Color(0.7, 0.7, 0.75, 0.8)
		
		if not is_unlocked:
			lbl_title.text = "🔒 " + card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7))
			lbl_status.text = "Status: 🔒 Locked (Defeat Giovanni at Silph Co. first)"
			lbl_status.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
			btn.text = "🔒 Locked"
			btn.disabled = true
			_apply_retro_button_style(btn, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
		elif is_in_progress:
			var total_st = GameData.get_adventure_total_stages(6)
			lbl_title.text = card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
			lbl_status.text = "Status: In Progress (Stage %d/%d)" % [GameData.adventure_current_stage, total_st]
			lbl_status.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
			btn.text = "⛺ Continue Operation (Camp)"
			btn.disabled = false
			_apply_retro_button_style(btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
		elif is_cleared:
			lbl_title.text = card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			lbl_status.text = "Status: 🏅 COMPLETED • Replayable"
			lbl_status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			btn.text = "🗺️ Replay Operation"
			btn.disabled = false
			_apply_retro_button_style(btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
		else:
			lbl_title.text = card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(1, 1, 1))
			lbl_status.text = "Status: Ready to deploy"
			lbl_status.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
			btn.text = "🗺️ Embark on Route"
			btn.disabled = false
			_apply_retro_button_style(btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)

func _on_select_adventure_ep6_route_pressed(route_id: String) -> void:
	if not GameData.is_adventure_ep6_route_unlocked(route_id):
		return
	if adventure_ep6_routes_modal:
		adventure_ep6_routes_modal.visible = false
	adventure_episodes_modal.visible = false
	GameData.campaign_submode = "ADVENTURE"
	
	if GameData.adventure_current_episode == 6 and GameData.adventure_ep6_selected_route == route_id and not GameData.adventure_player_team_state.is_empty():
		update_campaign_ui()
		campaign_modal.visible = true
		_check_and_run_camp_evolutions()
	else:
		GameData.adventure_ep6_selected_route = route_id
		GameData.reset_adventure_episode(6)
		GameData.adventure_current_episode = 6
		open_team_select_for_campaign()

func _on_select_adventure_ep7_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	if not GameData.is_tutorial_completed():
		_show_tutorial_prompt_for_locked_episode()
		return
	if not GameData.is_adventure_episode_unlocked(7):
		return
	adventure_episodes_modal.visible = false
	_open_adventure_ep7_routes_modal()

func _open_adventure_ep7_routes_modal() -> void:
	_setup_adventure_ep7_routes_modal()
	_refresh_adventure_ep7_routes_ui()
	adventure_ep7_routes_modal.visible = true

func _setup_adventure_ep7_routes_modal() -> void:
	if adventure_ep7_routes_modal != null:
		return
	adventure_ep7_routes_modal = Control.new()
	adventure_ep7_routes_modal.name = "AdventureEp7RoutesModal"
	adventure_ep7_routes_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	adventure_ep7_routes_modal.visible = false
	adventure_ep7_routes_modal.z_index = 45
	add_child(adventure_ep7_routes_modal)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.04, 0.08, 0.88)
	adventure_ep7_routes_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	adventure_ep7_routes_modal.add_child(center)
	
	var panel = PanelContainer.new()
	var ep5_target_w: float = minf(460.0, get_viewport_rect().size.x - 24.0)
	panel.custom_minimum_size = Vector2(ep5_target_w, 0)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color(0.9, 0.45, 0.2, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	var title_lbl = Label.new()
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.text = "🌋 EPISODE VII: CINNABAR OPERATIONS"
	title_lbl.add_theme_font_size_override("font_size", 17)
	title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	vbox.add_child(title_lbl)
	
	var subtitle_lbl = Label.new()
	subtitle_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_lbl.text = "Explore Pokémon Mansion and challenge Gym Leader Blaine in Cinnabar Gym:"
	subtitle_lbl.add_theme_font_size_override("font_size", 12)
	subtitle_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	vbox.add_child(subtitle_lbl)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 320)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var routes_vbox = VBoxContainer.new()
	routes_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	routes_vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(routes_vbox)
	
	var routes_def = [
		{
			"id": "pokemon_mansion",
			"name": "Mansión Pokémon (6 Combates)",
			"desc": "Explore the scorched ruined mansion on Cinnabar Island and battle researchers, Team Rocket and your Rival!",
			"rewards": "6 Combates  |  Reward: 💎 35 Diamonds • Unlocks Cinnabar Gym"
		},
		{
			"id": "blaine_gym",
			"name": "Gimnasio de Blaine (5 Combates)",
			"desc": "Answer the quiz questions and battle fiery champions to conquer the Volcano Badge!",
			"rewards": "5 Combates  |  Reward: 💎 35 Diamonds & 🏅 Volcano Badge (Final Clear!)"
		}
	]
	
	for r in routes_def:
		var r_id = r["id"]
		var c_panel = PanelContainer.new()
		c_panel.name = "RouteCard_" + r_id
		var c_sb = StyleBoxFlat.new()
		c_sb.bg_color = Color(0.12, 0.17, 0.24, 0.95)
		c_sb.border_color = Color(0.35, 0.40, 0.55, 0.8)
		c_sb.set_border_width_all(1)
		c_sb.set_corner_radius_all(6)
		c_sb.content_margin_left = 12
		c_sb.content_margin_right = 12
		c_sb.content_margin_top = 10
		c_sb.content_margin_bottom = 10
		c_panel.add_theme_stylebox_override("panel", c_sb)
		routes_vbox.add_child(c_panel)
		
		var cvbox = VBoxContainer.new()
		cvbox.add_theme_constant_override("separation", 4)
		c_panel.add_child(cvbox)
		
		var r_title = Label.new()
		r_title.name = "Title"
		r_title.text = r["name"]
		r_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_title.add_theme_font_size_override("font_size", 14)
		r_title.add_theme_color_override("font_color", Color(1, 1, 1))
		cvbox.add_child(r_title)
		
		var r_desc = Label.new()
		r_desc.name = "Desc"
		r_desc.text = r["desc"]
		r_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_desc.add_theme_font_size_override("font_size", 11)
		r_desc.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
		cvbox.add_child(r_desc)
		
		var r_rew = Label.new()
		r_rew.name = "Rewards"
		r_rew.text = r["rewards"]
		r_rew.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_rew.add_theme_font_size_override("font_size", 11)
		r_rew.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		cvbox.add_child(r_rew)
		
		var r_status = Label.new()
		r_status.name = "Status"
		r_status.text = "Status: Ready"
		r_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r_status.add_theme_font_size_override("font_size", 11)
		r_status.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		cvbox.add_child(r_status)
		
		var r_btn = Button.new()
		r_btn.name = "Btn"
		r_btn.custom_minimum_size = Vector2(0, 36)
		r_btn.add_theme_font_size_override("font_size", 12)
		r_btn.text = "Select Route"
		_apply_retro_button_style(r_btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
		r_btn.pressed.connect(func():
			if GameData.is_drag_scrolling():
				return
			_on_select_adventure_ep7_route_pressed(r_id)
		)
		cvbox.add_child(r_btn)
		
		ep7_route_cards[r_id] = {
			"panel": c_panel,
			"title": r_title,
			"status": r_status,
			"rewards": r_rew,
			"btn": r_btn
		}
		
	var btn_close_routes = Button.new()
	btn_close_routes.name = "BtnCloseEp7Routes"
	btn_close_routes.custom_minimum_size = Vector2(0, 36)
	btn_close_routes.text = "⬅ Return to Episodes"
	btn_close_routes.add_theme_font_size_override("font_size", 12)
	_apply_retro_button_style(btn_close_routes, Color(0.25, 0.52, 0.60), Color(0.40, 0.85, 0.95), false)
	btn_close_routes.pressed.connect(func():
		if GameData.is_drag_scrolling():
			return
		adventure_ep7_routes_modal.visible = false
		adventure_episodes_modal.visible = true
	)
	vbox.add_child(btn_close_routes)

func _refresh_adventure_ep7_routes_ui() -> void:
	for r_id in ep7_route_cards.keys():
		var card = ep7_route_cards[r_id]
		var lbl_title = card["title"] as Label
		var lbl_status = card["status"] as Label
		var btn = card["btn"] as Button
		
		var is_unlocked = GameData.is_adventure_ep7_route_unlocked(r_id)
		var is_cleared = GameData.is_adventure_ep7_route_completed(r_id)
		var is_in_progress = (GameData.adventure_current_episode == 7 and GameData.adventure_ep7_selected_route == r_id and not GameData.adventure_player_team_state.is_empty())
		
		if not is_unlocked:
			lbl_title.text = "🔒 " + card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(0.55, 0.60, 0.70))
			lbl_status.text = "Status: 🔒 Locked (Explore Pokémon Mansion first)"
			lbl_status.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
			btn.text = "🔒 Locked"
			btn.disabled = true
			_apply_retro_button_style(btn, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
		elif is_in_progress:
			lbl_title.text = card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
			var total_st = GameData.get_adventure_total_stages(7)
			lbl_status.text = "Status: In Progress • Stage %d/%d" % [GameData.adventure_current_stage, total_st]
			lbl_status.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
			btn.text = "⛺ Continue Camp"
			btn.disabled = false
			_apply_retro_button_style(btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
		elif is_cleared:
			lbl_title.text = card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			lbl_status.text = "Status: 🏅 Completed!"
			lbl_status.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			btn.text = "🔄 Replay Route"
			btn.disabled = false
			_apply_retro_button_style(btn, Color(0.25, 0.50, 0.75), Color(0.35, 0.75, 1.00), true)
		else:
			lbl_title.text = card["title"].text.replace("🔒 ", "")
			lbl_title.add_theme_color_override("font_color", Color(1, 1, 1))
			lbl_status.text = "Status: Ready to deploy"
			lbl_status.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
			btn.text = "🗺️ Embark on Route"
			btn.disabled = false
			_apply_retro_button_style(btn, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)

func _on_select_adventure_ep7_route_pressed(route_id: String) -> void:
	if not GameData.is_adventure_ep7_route_unlocked(route_id):
		return
	if adventure_ep7_routes_modal:
		adventure_ep7_routes_modal.visible = false
	adventure_episodes_modal.visible = false
	GameData.campaign_submode = "ADVENTURE"
	
	if GameData.adventure_current_episode == 7 and GameData.adventure_ep7_selected_route == route_id and not GameData.adventure_player_team_state.is_empty():
		update_campaign_ui()
		campaign_modal.visible = true
		_check_and_run_camp_evolutions()
	else:
		GameData.adventure_ep7_selected_route = route_id
		GameData.reset_adventure_episode(7)
		GameData.adventure_current_episode = 7
		open_team_select_for_campaign()

func _on_hub_tutorial_pressed() -> void:
	if GameData.is_drag_scrolling():
		return
	_show_tutorial_confirmation_modal()

func _setup_tutorial_confirmation_modal() -> void:
	if tutorial_confirm_modal != null:
		return
	tutorial_confirm_modal = Control.new()
	tutorial_confirm_modal.name = "TutorialConfirmModal"
	tutorial_confirm_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_confirm_modal.visible = false
	tutorial_confirm_modal.z_index = 85
	add_child(tutorial_confirm_modal)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.04, 0.08, 0.88)
	tutorial_confirm_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_confirm_modal.add_child(center)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 0)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color(0.3, 0.75, 0.85, 0.9)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	
	tutorial_confirm_title_lbl = Label.new()
	tutorial_confirm_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_confirm_title_lbl.text = "🎓 Start Combat Tutorial?"
	tutorial_confirm_title_lbl.add_theme_font_size_override("font_size", 17)
	tutorial_confirm_title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	vbox.add_child(tutorial_confirm_title_lbl)
	
	var rich_lbl = RichTextLabel.new()
	rich_lbl.bbcode_enabled = true
	rich_lbl.fit_content = true
	rich_lbl.scroll_active = false
	rich_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rich_lbl.custom_minimum_size = Vector2(380, 0)
	rich_lbl.add_theme_font_size_override("normal_font_size", 12)
	rich_lbl.add_theme_color_override("default_color", Color("#CFD8DC"))
	vbox.add_child(rich_lbl)
	tutorial_confirm_msg_lbl = rich_lbl
	
	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 10)
	vbox.add_child(btn_row)
	
	btn_cancel_tutorial = Button.new()
	btn_cancel_tutorial.text = "Cancel"
	btn_cancel_tutorial.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_cancel_tutorial.custom_minimum_size = Vector2(0, 36)
	_apply_retro_button_style(btn_cancel_tutorial, Color(0.35, 0.35, 0.40), Color(0.50, 0.50, 0.55), false)
	btn_cancel_tutorial.pressed.connect(func(): tutorial_confirm_modal.visible = false)
	btn_row.add_child(btn_cancel_tutorial)
	
	btn_confirm_tutorial = Button.new()
	btn_confirm_tutorial.text = "⚔️ Start Tutorial"
	btn_confirm_tutorial.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_confirm_tutorial.custom_minimum_size = Vector2(0, 36)
	_apply_retro_button_style(btn_confirm_tutorial, Color(0.20, 0.65, 0.35), Color(0.35, 0.85, 0.50), false)
	btn_confirm_tutorial.pressed.connect(_on_confirm_start_tutorial_pressed)
	btn_row.add_child(btn_confirm_tutorial)

func _show_tutorial_prompt_modal(title: String, msg_bbcode: String, btn_text: String, callback: Callable = Callable()) -> void:
	_setup_tutorial_confirmation_modal()
	tutorial_confirm_title_lbl.text = title
	if tutorial_confirm_msg_lbl is RichTextLabel:
		tutorial_confirm_msg_lbl.text = msg_bbcode
	else:
		tutorial_confirm_msg_lbl.text = msg_bbcode.replace("[b]", "").replace("[/b]", "")
	btn_confirm_tutorial.text = btn_text
	btn_cancel_tutorial.visible = false
	tutorial_prompt_callback = callback
	tutorial_confirm_modal.visible = true

func _show_tutorial_confirmation_modal() -> void:
	_setup_tutorial_confirmation_modal()
	if GameData.tutorial_completed:
		tutorial_confirm_title_lbl.text = "🎓 Replay Combat Tutorial?"
		tutorial_confirm_msg_lbl.text = "You will enter a practice battle to review the fundamentals of Pokémon combat.\n\nDo you want to start now?"
		btn_confirm_tutorial.text = "⚔️ Start Practice"
	else:
		tutorial_confirm_title_lbl.text = "🎓 Start Combat Tutorial?"
		tutorial_confirm_msg_lbl.text = "You will enter a guided battle to learn the fundamentals of Pokémon combat.\n\nFirst completion reward: 💎 5 Diamonds & unlocks Episode I!\n\nDo you want to start now?"
		btn_confirm_tutorial.text = "⚔️ Start Tutorial"
	btn_cancel_tutorial.visible = true
	tutorial_prompt_callback = Callable()
	tutorial_confirm_modal.visible = true

func _show_tutorial_prompt_for_locked_episode() -> void:
	_setup_tutorial_confirmation_modal()
	tutorial_confirm_title_lbl.text = "🔒 Adventure Mode is Locked!"
	tutorial_confirm_msg_lbl.text = "You must complete the Battle Tutorial first before entering Adventure Mode!\n\nWould you like to start the Tutorial now?"
	btn_confirm_tutorial.text = "🎓 Start Tutorial"
	btn_cancel_tutorial.visible = true
	tutorial_prompt_callback = Callable()
	tutorial_confirm_modal.visible = true

func _on_confirm_start_tutorial_pressed() -> void:
	if tutorial_confirm_modal:
		tutorial_confirm_modal.visible = false
	if tutorial_prompt_callback.is_valid():
		var cb = tutorial_prompt_callback
		tutorial_prompt_callback = Callable()
		cb.call()
		return
	campaign_hub_modal.visible = false
	adventure_episodes_modal.visible = false
	GameData.is_tutorial_mode = true
	GameData.is_campaign_mode = false
	GameData.is_pvp_mode = false
	GameData.is_online_pvp = false
	if GameData.tutorial_completed:
		GameData.tutorial_combat_phase = 1
	if GameData.tutorial_starter_id < 0:
		GameData.set_tutorial_starter(1)
	if bgm_player:
		bgm_player.stop()
	get_tree().call_deferred("change_scene_to_file", "res://scenes/battle.tscn")

func _start_tutorial_flow_or_settings() -> void:
	if not GameData.initial_settings_shown and not GameData.tutorial_completed and GameData.tutorial_step == 1:
		_show_initial_settings_popup()
	else:
		_show_tutorial_step1_intro_guidance()

func _show_initial_settings_popup() -> void:
	_pending_tutorial_after_settings = true
	_on_settings_pressed()
	if btn_close_settings:
		btn_close_settings.text = "🌟 Continuar al Tutorial ➡️" if GameData.is_spanish() else "🌟 Continue to Tutorial ➡️"

func _on_close_settings_pressed() -> void:
	settings_modal.visible = false
	if btn_close_settings:
		btn_close_settings.text = "⬅ Back to Lobby"
	if _pending_tutorial_after_settings:
		_pending_tutorial_after_settings = false
		GameData.initial_settings_shown = true
		GameData.save_profile()
		_show_tutorial_step1_intro_guidance()

func _show_tutorial_step1_intro_guidance() -> void:
	if GameData.player_diamonds < 25:
		GameData.player_diamonds = 25
		GameData.diamonds_changed.emit(GameData.player_diamonds)
		GameData.save_profile()
	_show_tutorial_prompt_modal(
		"🎓 ¡Bienvenido a Pokémon Battle Frontier!",
		"¡Hola, Entrenador! Para comenzar tus batallas necesitarás cartas de Pokémon. Las cartas se consiguen en la Tienda abriendo Sobres de Expansión con Diamantes 💎.\n\n🎁 ¡Has recibido [color=gold][b]💎 25 Diamantes[/b][/color] de bienvenida para comprar tu primer sobre!\n\nToca el botón a continuación para ir a la Tienda a abrir tu sobre.",
		"🛒 Ir a la Tienda ➡️",
		func():
			_on_shop_pressed()
	)

func _show_card_anatomy_and_starter_modal() -> void:
	_show_tutorial_prompt_modal(
		"🃏 Anatomía de una Carta Pokémon",
		"¡Felicidades por abrir tu primer Sobre de Expansión!\n\n" +
		"Cada carta de Pokémon cuenta con estadísticas clave para el combate:\n" +
		"• [b]❤️ HP (Puntos de Salud):[/b] La vida del Pokémon. Si llega a 0, queda fuera de combate (KO).\n" +
		"• [b]⚔️ ATK & 🛡️ DEF:[/b] Poder ofensivo y resistencia al daño recibido.\n" +
		"• [b]⏩ SPD (Velocidad):[/b] Define el orden de iniciativa en cada ronda.\n" +
		"• [b]🌿🔥💧 Tipos y Debilidades:[/b] Golpear con ventaja elemental otorga daño crítico adicional (+2 DMG).\n" +
		"• [b]⚡ Energía y Movimientos:[/b] Los movimientos consumen Energía. Si necesitas más, puedes usar 'Recargar Energía' (+2⚡).\n\n" +
		"¡Ahora selecciona a tu [color=gold][b]Pokémon Inicial[/b][/color] de entre las 4 regiones para liderar tu aventura!",
		"🌟 Elegir Pokémon Inicial ➡️",
		func():
			_open_starter_selection_modal()
	)

func _open_starter_selection_modal() -> void:
	if tutorial_confirm_modal:
		tutorial_confirm_modal.visible = false
	if shop_modal:
		shop_modal.visible = false
	if pack_reveal_box:
		pack_reveal_box.visible = false
	_setup_starter_selection_modal()
	starter_select_modal.z_index = 100
	starter_region_active = "Kanto"
	_update_starter_region_tabs()
	_refresh_starter_cards_display()
	starter_select_modal.visible = true

func _setup_starter_selection_modal() -> void:
	if starter_select_modal != null:
		return
	starter_select_modal = Control.new()
	starter_select_modal.name = "StarterSelectModal"
	starter_select_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	starter_select_modal.visible = false
	starter_select_modal.z_index = 100
	add_child(starter_select_modal)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.04, 0.08, 0.94)
	starter_select_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	starter_select_modal.add_child(center)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(490, 580)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.10, 0.16, 0.98)
	sb.border_color = Color(0.3, 0.75, 0.85, 0.95)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "🌟 ELIGE TU POKÉMON INICIAL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("#FFD700"))
	vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Selecciona una región y elige al compañero que te acompañará en tu aventura:"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", Color("#B0BEC5"))
	vbox.add_child(subtitle)
	
	# Tabs Row
	var tabs_row = HBoxContainer.new()
	tabs_row.add_theme_constant_override("separation", 6)
	tabs_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(tabs_row)
	
	var regions = ["Kanto", "Johto", "Hoenn", "Sinnoh"]
	var reg_icons = { "Kanto": "🔴", "Johto": "🟡", "Hoenn": "🟢", "Sinnoh": "🔵" }
	for reg in regions:
		var tab_btn = Button.new()
		tab_btn.text = "%s %s" % [reg_icons.get(reg, ""), reg]
		tab_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab_btn.custom_minimum_size = Vector2(0, 32)
		tab_btn.add_theme_font_size_override("font_size", 11)
		var target_reg = reg
		tab_btn.pressed.connect(func():
			starter_region_active = target_reg
			_update_starter_region_tabs()
			_refresh_starter_cards_display()
		)
		tabs_row.add_child(tab_btn)
		starter_tab_buttons[reg] = tab_btn
		
	# Cards Scroll / Container
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(450, 360)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var cards_vbox = VBoxContainer.new()
	cards_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(cards_vbox)
	starter_cards_row = cards_vbox

func _update_starter_region_tabs() -> void:
	for reg in starter_tab_buttons.keys():
		var btn = starter_tab_buttons[reg] as Button
		if not btn: continue
		var is_act = (reg == starter_region_active)
		if is_act:
			_apply_retro_button_style(btn, Color(0.20, 0.55, 0.75), Color(0.35, 0.85, 1.0), true)
			btn.add_theme_color_override("font_color", Color("#FFF59D"))
		else:
			_apply_retro_button_style(btn, Color(0.12, 0.16, 0.22), Color(0.25, 0.35, 0.45), false)
			btn.add_theme_color_override("font_color", Color("#90A4AE"))

func _refresh_starter_cards_display() -> void:
	if not starter_cards_row:
		return
	for c in starter_cards_row.get_children():
		starter_cards_row.remove_child(c)
		c.queue_free()
		
	if starter_cards_row.get_parent() is ScrollContainer:
		(starter_cards_row.get_parent() as ScrollContainer).scroll_vertical = 0
		
	var starters_by_reg = {
		"Kanto": [0, 1, 2],
		"Johto": [167, 170, 173],
		"Hoenn": [257, 260, 263],
		"Sinnoh": [392, 395, 398]
	}
	var ids: Array = starters_by_reg.get(starter_region_active, [0, 1, 2])
	
	for pid in ids:
		var d = GameData.pokemon_catalog.get(pid, {})
		if d.is_empty(): continue
		
		var card_panel = PanelContainer.new()
		card_panel.custom_minimum_size = Vector2(430, 80)
		card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var card_sb = StyleBoxFlat.new()
		var type_color = GameData.get_type_primary_color(str(d.get("type", "NORMAL")))
		card_sb.bg_color = Color(0.09, 0.13, 0.20, 0.96)
		card_sb.border_color = type_color
		card_sb.set_border_width_all(2)
		card_sb.set_corner_radius_all(8)
		card_sb.content_margin_left = 10
		card_sb.content_margin_right = 10
		card_sb.content_margin_top = 8
		card_sb.content_margin_bottom = 8
		card_panel.add_theme_stylebox_override("panel", card_sb)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		card_panel.add_child(hbox)
		
		var tex_rect = TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(56, 56)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var p_tex = GameData.get_pokemon_texture(str(d.get("texture_path", "")))
		if p_tex: tex_rect.texture = p_tex
		hbox.add_child(tex_rect)
		
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", 2)
		hbox.add_child(info_vbox)
		
		var name_row = HBoxContainer.new()
		name_row.add_theme_constant_override("separation", 6)
		info_vbox.add_child(name_row)
		
		var type_ico = TextureRect.new()
		type_ico.custom_minimum_size = Vector2(16, 16)
		type_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		type_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		type_ico.texture = GameData.get_type_icon_texture(str(d.get("type", "NORMAL")))
		name_row.add_child(type_ico)
		
		var name_lbl = Label.new()
		name_lbl.text = "%s (No. %s)" % [d.get("name", ""), d.get("pokedex_num", "")]
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		name_row.add_child(name_lbl)
		
		var stats_lbl = Label.new()
		stats_lbl.text = "❤️ HP: %d  |  ⏩ SPD: %d  |  Tipo: %s" % [int(d.get("hp", 10)), int(d.get("speed", 1)), str(d.get("type", ""))]
		stats_lbl.add_theme_font_size_override("font_size", 10)
		stats_lbl.add_theme_color_override("font_color", Color("#B0BEC5"))
		info_vbox.add_child(stats_lbl)
		
		var m1 = str(d.get("move1_name", "Tackle"))
		var m2 = str(d.get("move2_name", "Attack"))
		var moves_lbl = Label.new()
		moves_lbl.text = "⚔️ Movimientos: %s, %s" % [m1, m2]
		moves_lbl.add_theme_font_size_override("font_size", 10)
		moves_lbl.add_theme_color_override("font_color", Color("#81D4FA"))
		info_vbox.add_child(moves_lbl)
		
		var select_btn = Button.new()
		select_btn.custom_minimum_size = Vector2(110, 36)
		select_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		select_btn.text = "⭐ Elegir ⭐"
		select_btn.add_theme_font_size_override("font_size", 11)
		_apply_retro_button_style(select_btn, type_color.darkened(0.4), type_color, false)
		var chosen_id = pid
		select_btn.pressed.connect(func(): _on_starter_selected(chosen_id))
		hbox.add_child(select_btn)
		
		starter_cards_row.add_child(card_panel)

func _on_starter_selected(starter_id: int) -> void:
	GameData.play_combat_sfx("click")
	GameData.set_tutorial_starter(starter_id)
	GameData.tutorial_step = 3
	GameData.tutorial_combat_phase = 1
	GameData.is_tutorial_mode = true
	GameData.save_profile()
	
	if starter_select_modal:
		starter_select_modal.visible = false
	if shop_modal:
		shop_modal.visible = false
	if pack_reveal_box:
		pack_reveal_box.visible = false
		
	if bgm_player and bgm_player.playing:
		bgm_player.stop()
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

func _show_camp_evolution_tutorial_guidance() -> void:
	var st_id = GameData.tutorial_starter_id if GameData.tutorial_starter_id >= 0 else 1
	var st_info = GameData.get_tutorial_starter_info(st_id)
	var st_name = str(st_info.get("name", "Starter"))
	var stone_type = str(st_info.get("stone_type", "Fire"))
	var stone_name = GameData.get_stone_display_name(stone_type)
	var owned_stones = GameData.get_campaign_stone_count(stone_type)
	
	var team = GameData.get_active_campaign_team_state()
	var cur_id = int(team[0]["id"]) if not team.is_empty() else st_id
	var already_evolved = (cur_id == int(st_info.get("stage1_id", -1)))
	
	if already_evolved:
		GameData.tutorial_step = 5
		GameData.save_profile()
		_show_camp_combat2_prompt()
		return
		
	if owned_stones <= 0:
		_show_tutorial_prompt_modal(
			"⛺ Campamento y Evolución",
			"¡Bienvenido al Campamento de Aventura!\n\nAquí tus Pokémon ganan experiencia y evolucionan. Tu [b]%s[/b] ya tiene su experiencia al máximo (EXP: MAX), pero necesita una Piedra Evolutiva para evolucionar.\n\n🛒 Abre la Tienda de Suministros del Campamento para comprar 1x [b]%s[/b] por 10 G." % [st_name, stone_name],
			"🛒 Abrir Tienda del Campamento ➡️",
			func(): _on_camp_shop_pressed()
		)
	else:
		_show_tutorial_prompt_modal(
			"✨ ¡Listo para Evolucionar!",
			"¡Ya tienes la [b]%s[/b] en tu mochila!\n\nAhora pulsa el botón [b]'✨ Evolve!'[/b] en la tarjeta de tu [b]%s[/b] en el Campamento para iniciar su evolución." % [stone_name, st_name],
			"Entendido ➡️",
			func(): pass
		)

func _show_camp_combat2_prompt() -> void:
	var st_id = GameData.tutorial_starter_id if GameData.tutorial_starter_id >= 0 else 1
	var st_info = GameData.get_tutorial_starter_info(st_id)
	var s1_id = int(st_info.get("stage1_id", 6))
	var s1_name = "Stage 1"
	if GameData.pokemon_catalog.has(s1_id):
		s1_name = str(GameData.pokemon_catalog[s1_id].get("name", "Stage 1"))
		
	_show_tutorial_prompt_modal(
		"🌟 ¡Evolución Completada!",
		"¡Tu inicial ha evolucionado exitosamente a [b]%s[/b]!\n\nHa aumentado notablemente sus Puntos de Salud, su Velocidad y ha aprendido ataques más poderosos.\n\n⚔️ ¡Es momento de poner a prueba su poder en el Combate Avanzado contra otro Pokémon de Fase 1 y su banca rival!" % s1_name,
		"⚔️ Iniciar Combate Avanzado ➡️",
		func():
			GameData.tutorial_combat_phase = 2
			GameData.is_tutorial_mode = true
			GameData.save_profile()
			if bgm_player and bgm_player.playing:
				bgm_player.stop()
			get_tree().change_scene_to_file("res://scenes/battle.tscn")
	)

func open_team_select_for_campaign() -> void:
	refresh_cards_data_from_catalog()
	team_select_mode = "CAMPAIGN"
	GameData.is_pvp_mode = false
	if qb_mode_row:
		qb_mode_row.visible = false
	current_team_tab = "PLAYER"
	team_sort_mode = "EVO"
	
	if GameData.campaign_submode == "ADVENTURE":
		team_select_title.text = "🗺️ ADVENTURE TEAM"
		var ep_roman = {1: "I", 2: "II", 3: "III", 4: "IV", 5: "V", 6: "VI", 7: "VII"}.get(GameData.adventure_current_episode, str(GameData.adventure_current_episode))
		team_select_subtitle.text = "Choose 1 to 3 BASIC Pokémon for Episode %s (Legendaries banned).\n⏫ icons show evolutions ready in your collection!" % ep_roman
	else:
		team_select_title.text = "🏟️ POKÉMON STADIUM TEAM"
		team_select_subtitle.text = "Choose 1 to 3 BASIC Pokémon for Pokémon Stadium (Legendaries banned).\n⏫ icons show evolutions ready in your collection!"
	team_select_tabs.visible = false
	
	# Cargar selección del equipo de la campaña activa
	var active_team = GameData.get_active_campaign_team_state()
	if active_team.size() > 0:
		selected_player_ids.clear()
		for p in active_team:
			var cat_entry = GameData.pokemon_catalog.get(int(p["id"]))
			var r = str(cat_entry.get("rarity", "Common")).strip_edges().to_lower() if cat_entry else ""
			var is_legendary = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (cat_entry and str(cat_entry.get("stage", "Basic")).strip_edges().to_lower() == "legendary")
			if cat_entry and str(cat_entry.get("stage", "Basic")).strip_edges().to_lower() == "basic" and not is_legendary:
				selected_player_ids.append(int(p["id"]))
	# If starting a fresh run, leave selected_player_ids empty so the player can choose freely
			
	update_team_sort_buttons_ui()
	build_team_select_cards_grid()
	update_team_select_ui()
	campaign_modal.visible = false
	campaign_hub_modal.visible = false
	team_select_modal.visible = true

func update_campaign_ui() -> void:
	var cur_gold = GameData.get_active_campaign_gold()
	var cur_inv = GameData.get_active_campaign_inventory()
	var cur_team = GameData.get_active_campaign_team_state()
	
	campaign_gold_lbl.text = "💰 %d G  |  💎 %d" % [cur_gold, GameData.player_diamonds]
	if camp_shop_gold_lbl:
		camp_shop_gold_lbl.text = "💰 %d G  |  💎 %d" % [cur_gold, GameData.player_diamonds]
	var potions = cur_inv.get("potion", 0)
	var super_potions = cur_inv.get("super_potion", 0)
	var hyper_potions = cur_inv.get("hyper_potion", 0)
	var revives = cur_inv.get("revive", 0)
	var remedies = cur_inv.get("remedy", 0)
	var ethers = cur_inv.get("ether", 0)
	var poke_flutes = cur_inv.get("poke_flute", 0)
	if btn_camp_bag:
		var total_items = potions + super_potions + hyper_potions + revives + remedies + ethers + poke_flutes
		for st_name in GameData.EVOLUTION_STONE_TYPES:
			total_items += GameData.get_campaign_stone_count(st_name)
		btn_camp_bag.text = "🎒 Bag (%d Item%s)" % [total_items, "s" if total_items != 1 else ""]
	if camp_shop_stones_list and camp_shop_modal and camp_shop_modal.visible:
		_refresh_camp_shop_stones_ui()
	campaign_item_count_lbl.text = "Inventory: %d Potions" % potions
	if campaign_super_potion_count_lbl:
		campaign_super_potion_count_lbl.text = "Inventory: %d Super Potions" % super_potions
	if campaign_hyper_potion_count_lbl:
		campaign_hyper_potion_count_lbl.text = "Inventory: %d Hyper Potions" % hyper_potions
	campaign_remedy_count_lbl.text = "Inventory: %d Remedies" % remedies
	if campaign_poke_flute_count_lbl:
		campaign_poke_flute_count_lbl.text = "Owned: 1 Poké Flute" if poke_flutes > 0 else "Not Owned (Permanent item)"
	campaign_ether_count_lbl.text = "Inventory: %d Ethers" % ethers
	campaign_revive_count_lbl.text = "Inventory: %d Revives" % revives
	
	btn_buy_potion.disabled = (cur_gold < GameData.ITEM_COST_POTION)
	btn_buy_potion.text = "Buy (%d G)" % GameData.ITEM_COST_POTION
	if btn_buy_super_potion:
		btn_buy_super_potion.disabled = (cur_gold < GameData.ITEM_COST_SUPER_POTION)
		btn_buy_super_potion.text = "Buy (%d G)" % GameData.ITEM_COST_SUPER_POTION
	if btn_buy_hyper_potion:
		btn_buy_hyper_potion.disabled = (cur_gold < GameData.ITEM_COST_HYPER_POTION)
		btn_buy_hyper_potion.text = "Buy (%d G)" % GameData.ITEM_COST_HYPER_POTION
	btn_buy_remedy.disabled = (cur_gold < GameData.ITEM_COST_REMEDY)
	btn_buy_remedy.text = "Buy (%d G)" % GameData.ITEM_COST_REMEDY
	if btn_buy_poke_flute:
		if poke_flutes > 0:
			btn_buy_poke_flute.disabled = true
			btn_buy_poke_flute.text = "Owned"
		else:
			btn_buy_poke_flute.disabled = (cur_gold < GameData.ITEM_COST_POKE_FLUTE)
			btn_buy_poke_flute.text = "Buy (%d G)" % GameData.ITEM_COST_POKE_FLUTE
	btn_buy_ether.disabled = (cur_gold < GameData.ITEM_COST_ETHER)
	btn_buy_ether.text = "Buy (%d G)" % GameData.ITEM_COST_ETHER
	btn_buy_revive.disabled = (cur_gold < GameData.ITEM_COST_REVIVE)
	btn_buy_revive.text = "Buy (%d G)" % GameData.ITEM_COST_REVIVE
	
	var camp_title = campaign_modal.get_node_or_null("Box/Title")
	var camp_desc = campaign_modal.get_node_or_null("Box/Desc")
	var camp_team_header = campaign_modal.get_node_or_null("Box/TeamHeader")
	if btn_camp_stadium_guide:
		btn_camp_stadium_guide.visible = (GameData.campaign_submode != "ADVENTURE")
	if GameData.campaign_submode == "ADVENTURE":
		btn_close_campaign.text = "⬅ Abandon Episode (Resets Run)"
		var ep_id = GameData.adventure_current_episode
		var ep_info = GameData.get_adventure_episode_info(ep_id)
		var total_stages = GameData.get_adventure_total_stages(ep_id)
		var cur_stage = GameData.adventure_current_stage
		btn_change_campaign_team.visible = (cur_stage == 1)
		btn_reset_campaign.text = "🔄 Restart Episode (Resets Stage Progress)"
		
		if ep_id == 5:
			var r_info = GameData.get_adventure_route_info(5, GameData.adventure_ep5_selected_route)
			if camp_title:
				camp_title.text = "🗺️ EPISODE V: %s" % str(r_info.get("name_es", r_info.get("name", "ROUTE"))).to_upper()
			if camp_desc:
				camp_desc.text = str(r_info.get("desc", ep_info.get("subtitle", "Story adventure")))
		elif ep_id == 6:
			var r_info = GameData.get_adventure_route_info(6, GameData.adventure_ep6_selected_route)
			if camp_title:
				camp_title.text = "🗺️ EPISODE VI: %s" % str(r_info.get("name_es", r_info.get("name", "ROUTE"))).to_upper()
			if camp_desc:
				camp_desc.text = str(r_info.get("desc", ep_info.get("subtitle", "Story adventure")))
		elif ep_id == 7:
			var r_info = GameData.get_adventure_route_info(7, GameData.adventure_ep7_selected_route)
			if camp_title:
				camp_title.text = "🗺️ EPISODE VII: %s" % str(r_info.get("name_es", r_info.get("name", "ROUTE"))).to_upper()
			if camp_desc:
				camp_desc.text = str(r_info.get("desc", ep_info.get("subtitle", "Story adventure")))
		else:
			if camp_title:
				camp_title.text = "🗺️ " + ep_info.get("title", "ADVENTURE: EPISODE I").to_upper()
			if camp_desc:
				camp_desc.text = ep_info.get("subtitle", "Story adventure")
		if camp_team_header:
			camp_team_header.text = "👥 YOUR ADVENTURE TEAM:"
			
		if cur_stage > total_stages:
			var badge_name = "Badge"
			if ep_id in [5, 6, 7]:
				var cur_route = GameData.get_adventure_selected_route(ep_id)
				var r_info = GameData.get_adventure_route_info(ep_id, cur_route)
				badge_name = str(r_info.get("badge_name", "Operation Complete!"))
			else:
				var stages = ep_info.get("stages", [])
				if stages.size() > 0:
					badge_name = stages[stages.size() - 1].get("badge_name", "Badge")
			campaign_match_lbl.text = "🎉 EPISODE CONQUERED! %s Won!" % badge_name
			btn_start_campaign_battle.text = "🏆 Replay Episode"
			btn_start_campaign_battle.disabled = false
			if campaign_track_diagram:
				campaign_track_diagram.set_campaign_progress(total_stages, total_stages, true, true)
		else:
			var stage_info = GameData.get_adventure_stage_info(ep_id, cur_stage)
			var trainer_name = stage_info.get("trainer_name", "Trainer")
			campaign_match_lbl.text = "🗺️ %s • %s" % [
				stage_info.get("trainer_title", "Stage %d" % cur_stage),
				trainer_name
			]
			btn_start_campaign_battle.text = "⚔️ BATTLE %s (%d/%d)" % [
				stage_info.get("trainer_title", trainer_name).to_upper(),
				cur_stage,
				total_stages
			]
			var any_alive = false
			for p in cur_team:
				if p["current_hp"] > 0:
					any_alive = true
					break
			btn_start_campaign_battle.disabled = not any_alive
			if campaign_track_diagram:
				campaign_track_diagram.set_campaign_progress(total_stages, cur_stage, false, true)
	else:
		# Modo Pokémon Stadium
		btn_close_campaign.text = "⬅ Exit Stadium Camp"
		btn_change_campaign_team.visible = (GameData.campaign_match_number == 1)
		btn_reset_campaign.text = "🔄 Restart Stadium Run (Resets Match Progress)"
		
		if camp_title:
			camp_title.text = "🏟️ POKÉMON STADIUM"
		if camp_desc:
			camp_desc.text = "Arcade adventure: manage your team and purchase battle items between rounds!"
		if camp_team_header:
			camp_team_header.text = "👥 YOUR STADIUM TEAM:"
			
		if GameData.campaign_match_number > GameData.TOURNAMENT_TOTAL_MATCHES:
			campaign_match_lbl.text = "🎉 STADIUM CHAMPION!"
			btn_start_campaign_battle.text = "🏆 Start New Stadium Run!"
			btn_start_campaign_battle.disabled = false
			if campaign_track_diagram:
				campaign_track_diagram.set_campaign_progress(GameData.TOURNAMENT_TOTAL_MATCHES, GameData.TOURNAMENT_TOTAL_MATCHES, true, false)
		else:
			var match_info = GameData.get_tournament_match_info(GameData.campaign_match_number)
			var milestone_d = int(match_info.get("reward_diamonds", 0))
			var bonus_str = " (+💎%d)" % milestone_d if milestone_d > 0 else ""
			campaign_match_lbl.text = "🏆 %s%s" % [
				match_info["phase_name"],
				bonus_str
			]
			btn_start_campaign_battle.text = "⚔️ START BATTLE (%d/%d)" % [
				GameData.campaign_match_number,
				GameData.TOURNAMENT_TOTAL_MATCHES
			]
			var any_alive = false
			for p in cur_team:
				if p["current_hp"] > 0:
					any_alive = true
					break
			btn_start_campaign_battle.disabled = not any_alive
			if campaign_track_diagram:
				campaign_track_diagram.set_campaign_progress(GameData.TOURNAMENT_TOTAL_MATCHES, GameData.campaign_match_number, false, false)

	# Reconstruir lista de equipo del campamento
	for child in campaign_team_list.get_children():
		child.queue_free()
		
	for i in range(cur_team.size()):
		var p = cur_team[i]
		var is_leader = (i == 0)
		var item_panel = PanelContainer.new()
		var card_sb = StyleBoxFlat.new()
		if is_leader:
			card_sb.bg_color = Color(0.09, 0.13, 0.20, 0.98)
			card_sb.border_color = Color(1.0, 0.82, 0.28, 0.95)
			card_sb.set_border_width_all(2)
		else:
			card_sb.bg_color = Color(0.07, 0.11, 0.17, 0.95)
			card_sb.border_color = Color(0.25, 0.52, 0.60, 0.85)
			card_sb.set_border_width_all(1)
		card_sb.set_corner_radius_all(6)
		card_sb.content_margin_left = 8
		card_sb.content_margin_top = 6
		card_sb.content_margin_right = 8
		card_sb.content_margin_bottom = 6
		item_panel.add_theme_stylebox_override("panel", card_sb)
		
		var card_hbox = HBoxContainer.new()
		card_hbox.add_theme_constant_override("separation", 8)
		item_panel.add_child(card_hbox)
		
		# 1. Sprite thumbnail
		var thumb_rect = TextureRect.new()
		thumb_rect.custom_minimum_size = Vector2(52, 52)
		thumb_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var p_tex = GameData.get_pokemon_texture(p.get("texture_path", ""))
		if p_tex: thumb_rect.texture = p_tex
		if p["current_hp"] <= 0:
			thumb_rect.modulate = Color(0.45, 0.45, 0.45, 0.70)
		card_hbox.add_child(thumb_rect)
		
		# 2. Pokémon Info
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_theme_constant_override("separation", 3)
		card_hbox.add_child(vbox)
		
		# Top row: Role, Tier Badge, Type, Name, Stage
		var top_row = HBoxContainer.new()
		top_row.add_theme_constant_override("separation", 5)
		vbox.add_child(top_row)
		
		var role_badge = Label.new()
		role_badge.add_theme_font_size_override("font_size", 10)
		if is_leader:
			role_badge.text = "👑 LEADER"
			role_badge.add_theme_color_override("font_color", Color("#FFD700"))
		else:
			role_badge.text = "🔄 BENCH %d" % i
			role_badge.add_theme_color_override("font_color", Color("#80DEEA"))
		top_row.add_child(role_badge)
		
		var p_cat_entry = GameData.pokemon_catalog.get(int(p["id"]), {})
		var p_tier = str(p.get("tier", p_cat_entry.get("tier", "C"))).strip_edges().to_upper()
		if p_tier == "": p_tier = "C"
		var tier_badge = Label.new()
		tier_badge.text = "[%s]" % p_tier
		tier_badge.add_theme_font_size_override("font_size", 10)
		tier_badge.add_theme_color_override("font_color", GameData.get_tier_color(p_tier))
		top_row.add_child(tier_badge)
		
		var type_ico = TextureRect.new()
		type_ico.custom_minimum_size = Vector2(16, 16)
		type_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		type_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		type_ico.texture = GameData.get_type_icon_texture(p["type"])
		top_row.add_child(type_ico)
		
		var top_lbl = Label.new()
		top_lbl.text = p["name"]
		top_lbl.add_theme_font_size_override("font_size", 12)
		top_lbl.add_theme_color_override("font_color", Color("#E2E8F0"))
		top_row.add_child(top_lbl)
		
		var stage_lbl = Label.new()
		stage_lbl.text = "• %s" % p["stage"]
		stage_lbl.add_theme_font_size_override("font_size", 10)
		stage_lbl.add_theme_color_override("font_color", Color("#90A4AE"))
		top_row.add_child(stage_lbl)
		
		# Mid row: HP Bar & Text
		var hp_row = HBoxContainer.new()
		hp_row.add_theme_constant_override("separation", 6)
		
		var hp_bar = ProgressBar.new()
		hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hp_bar.custom_minimum_size = Vector2(0, 8)
		hp_bar.max_value = max(1, p["max_hp"])
		hp_bar.value = p["current_hp"]
		hp_bar.show_percentage = false
		
		var hp_bg = StyleBoxFlat.new()
		hp_bg.bg_color = Color("#181c22")
		hp_bg.border_color = Color("#3e4656")
		hp_bg.set_border_width_all(1)
		hp_bg.set_corner_radius_all(3)
		hp_bar.add_theme_stylebox_override("background", hp_bg)
		
		var ratio = float(p["current_hp"]) / float(max(1, p["max_hp"]))
		var fill_color = Color("#58d858")
		var highlight = Color("#88f888")
		if ratio <= 0.2:
			fill_color = Color("#e83030")
			highlight = Color("#f87070")
		elif ratio <= 0.5:
			fill_color = Color("#f8b030")
			highlight = Color("#f8e070")
		var hp_fill = StyleBoxFlat.new()
		hp_fill.bg_color = fill_color
		hp_fill.border_color = highlight
		hp_fill.set_border_width_all(1)
		hp_fill.set_corner_radius_all(3)
		hp_bar.add_theme_stylebox_override("fill", hp_fill)
		hp_row.add_child(hp_bar)
		
		var hp_lbl = Label.new()
		hp_lbl.text = "%d / %d HP" % [p["current_hp"], p["max_hp"]]
		hp_lbl.add_theme_font_size_override("font_size", 10)
		hp_lbl.add_theme_color_override("font_color", Color("#E2E8F0"))
		hp_row.add_child(hp_lbl)
		vbox.add_child(hp_row)
		
		# EXP Row
		var exp_row = HBoxContainer.new()
		exp_row.add_theme_constant_override("separation", 6)
		var exp_bar = ProgressBar.new()
		exp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		exp_bar.custom_minimum_size = Vector2(0, 6)
		exp_bar.show_percentage = false
		
		var cur_exp = int(p.get("current_exp", 0))
		var req_exp = GameData.get_pokemon_required_exp(int(p.get("id", -1)))
		
		var exp_lbl = Label.new()
		exp_lbl.add_theme_font_size_override("font_size", 10)
		
		var exp_bg = StyleBoxFlat.new()
		exp_bg.bg_color = Color("#181c22")
		exp_bg.border_color = Color("#3e4656")
		exp_bg.set_border_width_all(1)
		exp_bg.set_corner_radius_all(3)
		exp_bar.add_theme_stylebox_override("background", exp_bg)
		
		var exp_fill = StyleBoxFlat.new()
		exp_fill.bg_color = Color("#42a5f5") if cur_exp < req_exp else Color("#ffd700")
		exp_fill.border_color = Color("#90caf9") if cur_exp < req_exp else Color("#fff59d")
		exp_fill.set_border_width_all(1)
		exp_fill.set_corner_radius_all(3)
		exp_bar.add_theme_stylebox_override("fill", exp_fill)
		
		var evo_opts = GameData.get_evolution_options(int(p["id"]), true)
		var stone_req_tag = ""
		if evo_opts.size() == 1:
			stone_req_tag = "%dx %s" % [int(evo_opts[0].get("stone_count", 1)), str(evo_opts[0].get("stone_name", "Stone"))]
		elif evo_opts.size() > 1:
			stone_req_tag = "%dx Stone (%d Branches)" % [int(evo_opts[0].get("stone_count", 1)), evo_opts.size()]

		if req_exp <= 0 or evo_opts.is_empty():
			exp_bar.max_value = 1
			exp_bar.value = 1
			exp_lbl.text = "EXP: MAX"
			exp_lbl.add_theme_color_override("font_color", Color("#81D4FA"))
		else:
			exp_bar.max_value = req_exp
			exp_bar.value = min(req_exp, cur_exp)
			var any_unlocked = false
			for opt in evo_opts:
				if bool(opt.get("is_unlocked", false)):
					any_unlocked = true
					break
			if cur_exp >= req_exp:
				if int(p.get("current_hp", 0)) <= 0:
					exp_lbl.text = "EXP: %d/%d (💀 KO - Revive to Evolve!)" % [cur_exp, req_exp]
					exp_lbl.add_theme_color_override("font_color", Color("#FF8A80"))
				elif any_unlocked:
					exp_lbl.text = "EXP: %d/%d • Ready! (%s)" % [cur_exp, req_exp, stone_req_tag]
					exp_lbl.add_theme_color_override("font_color", Color("#FFD700"))
				else:
					var first_target_name = str(evo_opts[0].get("to_name", "evolution"))
					exp_lbl.text = "EXP: %d/%d 🔒 (Need %s)" % [cur_exp, req_exp, first_target_name]
					exp_lbl.add_theme_color_override("font_color", Color("#FF8A80"))
			else:
				exp_lbl.text = "EXP: %d/%d (%s)" % [cur_exp, req_exp, stone_req_tag]
				exp_lbl.add_theme_color_override("font_color", Color("#64B5F6"))
				
		exp_row.add_child(exp_bar)
		exp_row.add_child(exp_lbl)
		vbox.add_child(exp_row)
		
		# Status Row
		var status_row = HBoxContainer.new()
		status_row.add_theme_constant_override("separation", 6)
		var stat_lbl = Label.new()
		stat_lbl.add_theme_font_size_override("font_size", 10)
		if p["current_hp"] <= 0:
			top_lbl.modulate = Color(0.6, 0.6, 0.6)
			stat_lbl.text = "💀 Fainted (Needs Revive)"
			stat_lbl.add_theme_color_override("font_color", Color("#EF5350"))
		elif int(p.get("burn_turns", 0)) > 0 or bool(p.get("is_poisoned", false)):
			var s_list = []
			if int(p.get("burn_turns", 0)) > 0: s_list.append("🔥 Burned (%d)" % int(p.get("burn_turns", 0)))
			if bool(p.get("is_poisoned", false)): s_list.append("🟣 Poisoned")
			stat_lbl.text = ", ".join(s_list)
			stat_lbl.add_theme_color_override("font_color", Color("#FFA726"))
		else:
			stat_lbl.text = "💚 Healthy"
			stat_lbl.add_theme_color_override("font_color", Color("#81C784"))
		status_row.add_child(stat_lbl)
		vbox.add_child(status_row)
		
		# 3. Actions (Evolve, Inspect & Order)
		var card_btns_vbox = VBoxContainer.new()
		card_btns_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card_btns_vbox.add_theme_constant_override("separation", 4)
		card_btns_vbox.custom_minimum_size = Vector2(104, 0)
		card_hbox.add_child(card_btns_vbox)
		
		# 3.0 Evolve Button (Interactive Camp Evolution with Stones)
		if req_exp > 0 and not evo_opts.is_empty() and cur_exp >= req_exp and int(p.get("current_hp", 0)) > 0:
			var btn_evo = Button.new()
			btn_evo.custom_minimum_size = Vector2(104, 24)
			btn_evo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_evo.add_theme_font_size_override("font_size", 10)
			var evo_check = GameData.can_evolve_campaign_pokemon_with_option(i)
			var ready_now = bool(evo_check.get("can_evolve", false))
			btn_evo.text = "✨ Evolve!" if ready_now else "✨ Evolve"
			if ready_now:
				_apply_compact_order_button_style(btn_evo, Color(0.20, 0.72, 0.38), Color(0.35, 0.95, 0.55), false)
				btn_evo.add_theme_color_override("font_color", Color("#FFF59D"))
			else:
				_apply_compact_order_button_style(btn_evo, Color(0.65, 0.48, 0.14), Color(0.95, 0.75, 0.25), false)
				btn_evo.add_theme_color_override("font_color", Color("#FFE082"))
			var evo_team_idx = i
			btn_evo.pressed.connect(func(): _open_camp_evolution_selector(evo_team_idx))
			card_btns_vbox.add_child(btn_evo)
		
		# 3.1 Inspect Button
		var btn_status = Button.new()
		btn_status.custom_minimum_size = Vector2(104, 24)
		btn_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_status.add_theme_font_size_override("font_size", 10)
		btn_status.text = "🔍 Inspect"
		_apply_compact_order_button_style(btn_status, Color(0.20, 0.50, 0.70), Color(0.35, 0.75, 0.95), false)
		var target_p = p
		btn_status.pressed.connect(func(): _open_camp_pokemon_inspector(target_p))
		card_btns_vbox.add_child(btn_status)
		
		# 3.2 Order Controls (Leader / Bench)
		if cur_team.size() > 1:
			var order_hbox = HBoxContainer.new()
			order_hbox.add_theme_constant_override("separation", 4)
			order_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var cur_idx = i
			var is_fainted = (p["current_hp"] <= 0)
			
			if is_leader:
				var btn_demote = Button.new()
				btn_demote.text = "▼ To Bench"
				btn_demote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				btn_demote.custom_minimum_size = Vector2(104, 22)
				btn_demote.add_theme_font_size_override("font_size", 10)
				_apply_compact_order_button_style(btn_demote, Color(0.28, 0.35, 0.45), Color(0.45, 0.55, 0.70), false)
				btn_demote.pressed.connect(func():
					if GameData.swap_campaign_team_members(0, 1):
						GameData.play_combat_sfx("click")
						update_campaign_ui()
				)
				order_hbox.add_child(btn_demote)
			else:
				var has_down = (cur_idx < cur_team.size() - 1)
				var btn_lead = Button.new()
				btn_lead.text = "👑 Leader"
				btn_lead.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				btn_lead.custom_minimum_size = Vector2(48 if has_down else 74, 22)
				btn_lead.add_theme_font_size_override("font_size", 10)
				if is_fainted:
					btn_lead.disabled = true
					_apply_compact_order_button_style(btn_lead, Color(0.20, 0.20, 0.20), Color(0.35, 0.35, 0.35), true)
				else:
					_apply_compact_order_button_style(btn_lead, Color(0.60, 0.45, 0.10), Color(0.95, 0.75, 0.20), false)
					btn_lead.pressed.connect(func():
						if GameData.set_campaign_team_leader(cur_idx):
							GameData.play_combat_sfx("click")
							update_campaign_ui()
					)
				order_hbox.add_child(btn_lead)
				
				var btn_up = Button.new()
				btn_up.text = "▲"
				btn_up.custom_minimum_size = Vector2(25, 22)
				btn_up.add_theme_font_size_override("font_size", 10)
				if cur_idx == 1 and is_fainted:
					btn_up.disabled = true
					_apply_compact_order_button_style(btn_up, Color(0.20, 0.20, 0.20), Color(0.35, 0.35, 0.35), true)
				else:
					_apply_compact_order_button_style(btn_up, Color(0.22, 0.38, 0.50), Color(0.35, 0.60, 0.80), false)
					btn_up.pressed.connect(func():
						if GameData.swap_campaign_team_members(cur_idx, cur_idx - 1):
							GameData.play_combat_sfx("click")
							update_campaign_ui()
					)
				order_hbox.add_child(btn_up)
				
				if has_down:
					var btn_down = Button.new()
					btn_down.text = "▼"
					btn_down.custom_minimum_size = Vector2(25, 22)
					btn_down.add_theme_font_size_override("font_size", 10)
					_apply_compact_order_button_style(btn_down, Color(0.22, 0.38, 0.50), Color(0.35, 0.60, 0.80), false)
					btn_down.pressed.connect(func():
						if GameData.swap_campaign_team_members(cur_idx, cur_idx + 1):
							GameData.play_combat_sfx("click")
							update_campaign_ui()
					)
					order_hbox.add_child(btn_down)
					
			card_btns_vbox.add_child(order_hbox)
		
		campaign_team_list.add_child(item_panel)

func _apply_compact_order_button_style(btn: Button, border_col: Color, hover_col: Color, is_disabled: bool = false) -> void:
	if not btn:
		return
	var normal_sb = StyleBoxFlat.new()
	normal_sb.bg_color = Color(0.06, 0.08, 0.12, 0.85) if is_disabled else Color(0.09, 0.14, 0.20, 0.95)
	normal_sb.border_color = Color(0.18, 0.24, 0.30, 0.5) if is_disabled else border_col
	normal_sb.set_border_width_all(1)
	normal_sb.set_corner_radius_all(4)
	normal_sb.content_margin_left = 4
	normal_sb.content_margin_right = 4
	normal_sb.content_margin_top = 2
	normal_sb.content_margin_bottom = 2
	
	var hover_sb = normal_sb.duplicate()
	hover_sb.bg_color = Color(0.13, 0.22, 0.32, 1.0)
	hover_sb.border_color = hover_col
	
	btn.add_theme_stylebox_override("normal", normal_sb)
	btn.add_theme_stylebox_override("hover", hover_sb)
	btn.add_theme_stylebox_override("pressed", hover_sb)
	btn.add_theme_stylebox_override("disabled", normal_sb)
	btn.add_theme_color_override("font_disabled_color", Color(0.4, 0.45, 0.5))

func _on_buy_potion_pressed() -> void:
	if GameData.buy_campaign_potion():
		GameData.add_daily_mission_progress("buy_camp_shop", 1)
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_buy_super_potion_pressed() -> void:
	if GameData.buy_campaign_super_potion():
		GameData.add_daily_mission_progress("buy_camp_shop", 1)
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_buy_hyper_potion_pressed() -> void:
	if GameData.buy_campaign_hyper_potion():
		GameData.add_daily_mission_progress("buy_camp_shop", 1)
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_buy_poke_flute_pressed() -> void:
	if GameData.buy_campaign_poke_flute():
		GameData.add_daily_mission_progress("buy_camp_shop", 1)
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_buy_revive_pressed() -> void:
	if GameData.buy_campaign_revive():
		GameData.add_daily_mission_progress("buy_camp_shop", 1)
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_buy_remedy_pressed() -> void:
	if GameData.buy_campaign_remedy():
		GameData.add_daily_mission_progress("buy_camp_shop", 1)
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_buy_ether_pressed() -> void:
	if GameData.buy_campaign_ether():
		GameData.add_daily_mission_progress("buy_camp_shop", 1)
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_camp_shop_pressed() -> void:
	if camp_shop_modal:
		camp_shop_modal.visible = true
		update_campaign_ui()

func _on_camp_bag_pressed() -> void:
	if camp_bag_modal:
		camp_bag_modal.visible = true
		camp_bag_targets_view.visible = false
		camp_bag_items_view.visible = true
		_refresh_camp_bag_items_ui()

func _setup_camp_modals() -> void:
	if camp_toolbar != null:
		return
		
	var camp_box = campaign_modal.get_node_or_null("Box")
	if not camp_box:
		return
		
	var status_card = camp_box.get_node_or_null("StatusCard")
	var shop_section = camp_box.get_node_or_null("ShopSection")
	
	# 0. Setup Campaign Track Diagram inside StatusCard
	if status_card and campaign_track_diagram == null:
		var status_row = status_card.get_node_or_null("StatusRow")
		var status_vbox = status_card.get_node_or_null("StatusVBox")
		if not status_vbox:
			status_vbox = VBoxContainer.new()
			status_vbox.name = "StatusVBox"
			status_vbox.add_theme_constant_override("separation", 2)
			if status_row:
				status_card.remove_child(status_row)
				status_vbox.add_child(status_row)
			status_card.add_child(status_vbox)
		
		campaign_track_diagram = CampaignTrackDiagram.new()
		campaign_track_diagram.name = "CampaignTrackDiagram"
		status_vbox.add_child(campaign_track_diagram)
	
	# 1. Crear Camp Toolbar entre StatusCard y TeamHeader
	camp_toolbar = HBoxContainer.new()
	camp_toolbar.name = "CampToolbar"
	camp_toolbar.custom_minimum_size = Vector2(0, 42)
	camp_toolbar.add_theme_constant_override("separation", 10)
	
	btn_camp_shop = Button.new()
	btn_camp_shop.text = "🏪 Camp Shop"
	btn_camp_shop.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_camp_shop.custom_minimum_size = Vector2(0, 40)
	btn_camp_shop.add_theme_font_size_override("font_size", 12)
	_apply_retro_button_style(btn_camp_shop, Color(0.18, 0.55, 0.65), Color(0.35, 0.80, 0.95), true)
	btn_camp_shop.pressed.connect(_on_camp_shop_pressed)
	camp_toolbar.add_child(btn_camp_shop)
	
	btn_camp_bag = Button.new()
	btn_camp_bag.text = "🎒 Bag"
	btn_camp_bag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_camp_bag.custom_minimum_size = Vector2(0, 40)
	btn_camp_bag.add_theme_font_size_override("font_size", 12)
	_apply_retro_button_style(btn_camp_bag, Color(0.65, 0.45, 0.18), Color(0.95, 0.75, 0.35), true)
	btn_camp_bag.pressed.connect(_on_camp_bag_pressed)
	camp_toolbar.add_child(btn_camp_bag)
	
	camp_box.add_child(camp_toolbar)
	if status_card:
		var sc_idx = status_card.get_index()
		camp_box.move_child(camp_toolbar, sc_idx + 1)
		
	# Disable horizontal/vertical scrollbars on TeamScroll permanently
	var team_scroll = camp_box.get_node_or_null("TeamScroll")
	if team_scroll is ScrollContainer:
		team_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		team_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		var hbar = team_scroll.get_h_scroll_bar()
		if hbar:
			hbar.visible = false
			hbar.custom_minimum_size = Vector2.ZERO
		var vbar = team_scroll.get_v_scroll_bar()
		if vbar:
			vbar.visible = false
			vbar.custom_minimum_size = Vector2.ZERO
		
	# 2. Configurar CampShopModal
	camp_shop_modal = Control.new()
	camp_shop_modal.name = "CampShopModal"
	camp_shop_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_shop_modal.visible = false
	camp_shop_modal.z_index = 30
	add_child(camp_shop_modal)
	
	var shop_bg = ColorRect.new()
	shop_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_bg.color = Color(0, 0, 0, 0.75)
	camp_shop_modal.add_child(shop_bg)
	
	var shop_center = CenterContainer.new()
	shop_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_shop_modal.add_child(shop_center)
	
	var shop_panel = PanelContainer.new()
	var shop_w: float = minf(490.0, get_viewport_rect().size.x - 24.0)
	shop_panel.custom_minimum_size = Vector2(shop_w, 0)
	var shop_sb = StyleBoxFlat.new()
	shop_sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	shop_sb.border_color = Color(0.25, 0.60, 0.70, 0.90)
	shop_sb.set_border_width_all(2)
	shop_sb.set_corner_radius_all(8)
	shop_sb.content_margin_left = 16
	shop_sb.content_margin_right = 16
	shop_sb.content_margin_top = 14
	shop_sb.content_margin_bottom = 14
	shop_panel.add_theme_stylebox_override("panel", shop_sb)
	shop_center.add_child(shop_panel)
	
	var shop_vbox = VBoxContainer.new()
	shop_vbox.add_theme_constant_override("separation", 10)
	shop_panel.add_child(shop_vbox)
	
	# Header Tienda
	var shop_head_row = HBoxContainer.new()
	var shop_title_lbl = Label.new()
	shop_title_lbl.text = "🏪 CAMP SUPPLY SHOP"
	shop_title_lbl.add_theme_font_size_override("font_size", 16)
	shop_title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	shop_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_head_row.add_child(shop_title_lbl)
	
	var btn_close_shop_x = Button.new()
	btn_close_shop_x.text = "✕"
	btn_close_shop_x.custom_minimum_size = Vector2(30, 30)
	btn_close_shop_x.pressed.connect(func(): camp_shop_modal.visible = false)
	shop_head_row.add_child(btn_close_shop_x)
	shop_vbox.add_child(shop_head_row)
	
	camp_shop_gold_lbl = Label.new()
	camp_shop_gold_lbl.text = "💰 Gold: 0 G  |  💎 0 Diamonds"
	camp_shop_gold_lbl.add_theme_font_size_override("font_size", 12)
	camp_shop_gold_lbl.add_theme_color_override("font_color", Color("#4DD0E1"))
	shop_vbox.add_child(camp_shop_gold_lbl)
	
	var shop_sep = HSeparator.new()
	shop_vbox.add_child(shop_sep)
	
	# Re-parentar ShopSection dentro de CampShopModal
	if shop_section:
		shop_section.reparent(shop_vbox)
		var old_header = shop_section.get_node_or_null("ShopVBox/ShopHeader")
		if old_header: old_header.visible = false
		var old_hsep = shop_section.get_node_or_null("ShopVBox/ShopHSep")
		if old_hsep: old_hsep.visible = false
		var empty_sb = StyleBoxEmpty.new()
		shop_section.add_theme_stylebox_override("panel", empty_sb)
		
	var stones_sep = HSeparator.new()
	shop_vbox.add_child(stones_sep)
	
	var stones_hdr = Label.new()
	stones_hdr.text = "💎 EVOLUTION STONES (%d G each • 1x S1 / 2x S2)" % GameData.ITEM_COST_STONE
	stones_hdr.add_theme_font_size_override("font_size", 12)
	stones_hdr.add_theme_color_override("font_color", Color("#FFE082"))
	shop_vbox.add_child(stones_hdr)
	
	var stones_scroll = ScrollContainer.new()
	stones_scroll.custom_minimum_size = Vector2(0, 175)
	stones_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	shop_vbox.add_child(stones_scroll)
	
	camp_shop_stones_list = VBoxContainer.new()
	camp_shop_stones_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	camp_shop_stones_list.add_theme_constant_override("separation", 5)
	stones_scroll.add_child(camp_shop_stones_list)
	_refresh_camp_shop_stones_ui()
		
	var shop_bot_sep = HSeparator.new()
	shop_vbox.add_child(shop_bot_sep)
	
	var btn_close_camp_shop = Button.new()
	btn_close_camp_shop.text = "⬅ Back to Camp"
	btn_close_camp_shop.custom_minimum_size = Vector2(0, 36)
	btn_close_camp_shop.add_theme_font_size_override("font_size", 12)
	_apply_retro_button_style(btn_close_camp_shop, Color(0.25, 0.45, 0.55), Color(0.35, 0.65, 0.80), false)
	btn_close_camp_shop.pressed.connect(func():
		camp_shop_modal.visible = false
		update_campaign_ui()
	)
	shop_vbox.add_child(btn_close_camp_shop)
	
	# 3. Configurar CampBagModal (Mochila / Inventario)
	camp_bag_modal = Control.new()
	camp_bag_modal.name = "CampBagModal"
	camp_bag_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_bag_modal.visible = false
	camp_bag_modal.z_index = 30
	add_child(camp_bag_modal)
	
	var bag_bg = ColorRect.new()
	bag_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bag_bg.color = Color(0, 0, 0, 0.75)
	camp_bag_modal.add_child(bag_bg)
	
	var bag_center = CenterContainer.new()
	bag_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_bag_modal.add_child(bag_center)
	
	var bag_panel = PanelContainer.new()
	var bag_w: float = minf(510.0, get_viewport_rect().size.x - 24.0)
	bag_panel.custom_minimum_size = Vector2(bag_w, 0)
	var bag_sb = StyleBoxFlat.new()
	bag_sb.bg_color = Color(0.10, 0.12, 0.16, 0.98)
	bag_sb.border_color = Color(0.75, 0.55, 0.20, 0.90)
	bag_sb.set_border_width_all(2)
	bag_sb.set_corner_radius_all(8)
	bag_sb.content_margin_left = 16
	bag_sb.content_margin_right = 16
	bag_sb.content_margin_top = 14
	bag_sb.content_margin_bottom = 14
	bag_panel.add_theme_stylebox_override("panel", bag_sb)
	bag_center.add_child(bag_panel)
	
	var bag_vbox = VBoxContainer.new()
	bag_vbox.add_theme_constant_override("separation", 10)
	bag_panel.add_child(bag_vbox)
	
	# Header Mochila
	var bag_head_row = HBoxContainer.new()
	var bag_title_lbl = Label.new()
	bag_title_lbl.text = "🎒 INVENTORY & BAG"
	bag_title_lbl.add_theme_font_size_override("font_size", 16)
	bag_title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	bag_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bag_head_row.add_child(bag_title_lbl)
	
	var btn_close_bag_x = Button.new()
	btn_close_bag_x.text = "✕"
	btn_close_bag_x.custom_minimum_size = Vector2(30, 30)
	btn_close_bag_x.pressed.connect(func(): camp_bag_modal.visible = false)
	bag_head_row.add_child(btn_close_bag_x)
	bag_vbox.add_child(bag_head_row)
	
	var bag_sub_lbl = Label.new()
	bag_sub_lbl.text = "Manage and use your campaign items on your Pokémon team."
	bag_sub_lbl.add_theme_font_size_override("font_size", 11)
	bag_sub_lbl.add_theme_color_override("font_color", Color("#B0BEC5"))
	bag_vbox.add_child(bag_sub_lbl)
	
	var bag_sep = HSeparator.new()
	bag_vbox.add_child(bag_sep)
	
	# Contenedor de Items (Vista 1)
	camp_bag_items_view = VBoxContainer.new()
	camp_bag_items_view.add_theme_constant_override("separation", 8)
	bag_vbox.add_child(camp_bag_items_view)
	
	# Contenedor de Selección de Pokémon Objetivo (Vista 2)
	camp_bag_targets_view = VBoxContainer.new()
	camp_bag_targets_view.add_theme_constant_override("separation", 8)
	camp_bag_targets_view.visible = false
	bag_vbox.add_child(camp_bag_targets_view)
	
	camp_bag_prompt_lbl = Label.new()
	camp_bag_prompt_lbl.text = "Select a Pokémon to use item on:"
	camp_bag_prompt_lbl.add_theme_font_size_override("font_size", 13)
	camp_bag_prompt_lbl.add_theme_color_override("font_color", Color("#80DEEA"))
	camp_bag_targets_view.add_child(camp_bag_prompt_lbl)
	
	camp_bag_targets_container = VBoxContainer.new()
	camp_bag_targets_container.add_theme_constant_override("separation", 6)
	camp_bag_targets_view.add_child(camp_bag_targets_container)
	
	var btn_back_to_items = Button.new()
	btn_back_to_items.text = "⬅ Back to Items"
	btn_back_to_items.custom_minimum_size = Vector2(0, 32)
	btn_back_to_items.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_back_to_items, Color(0.3, 0.4, 0.5), Color(0.4, 0.6, 0.7), false)
	btn_back_to_items.pressed.connect(func():
		camp_bag_targets_view.visible = false
		camp_bag_items_view.visible = true
		_refresh_camp_bag_items_ui()
	)
	camp_bag_targets_view.add_child(btn_back_to_items)
	
	var bag_bot_sep = HSeparator.new()
	bag_vbox.add_child(bag_bot_sep)
	
	var btn_close_camp_bag = Button.new()
	btn_close_camp_bag.text = "⬅ Back to Camp"
	btn_close_camp_bag.custom_minimum_size = Vector2(0, 36)
	btn_close_camp_bag.add_theme_font_size_override("font_size", 12)
	_apply_retro_button_style(btn_close_camp_bag, Color(0.45, 0.35, 0.20), Color(0.70, 0.55, 0.30), false)
	btn_close_camp_bag.pressed.connect(func():
		camp_bag_modal.visible = false
		update_campaign_ui()
	)
	bag_vbox.add_child(btn_close_camp_bag)
	
	# 4. Configurar CampPokemonInspectorModal
	_setup_camp_pokemon_inspector_modal()
	
	# 5. Configurar CampEvolutionModal & CampEvolutionSelectorModal
	_setup_camp_evolution_modal()
	_setup_camp_evolution_selector_modal()

func _refresh_camp_shop_stones_ui() -> void:
	if not camp_shop_stones_list:
		return
	for child in camp_shop_stones_list.get_children():
		child.queue_free()
		
	var cur_gold = GameData.get_active_campaign_gold()
	var needed_stones = GameData.get_team_needed_stones()
	var ordered_stones: Array[String] = []
	for st in needed_stones:
		if st in GameData.EVOLUTION_STONE_TYPES and not (st in ordered_stones):
			ordered_stones.append(st)
	for st in GameData.EVOLUTION_STONE_TYPES:
		if not (st in ordered_stones):
			ordered_stones.append(st)
			
	for st_type in ordered_stones:
		var is_needed = (st_type in needed_stones)
		var owned = GameData.get_campaign_stone_count(st_type)
		
		var row = PanelContainer.new()
		var r_sb = StyleBoxFlat.new()
		r_sb.bg_color = Color(0.09, 0.14, 0.22, 0.94) if is_needed else Color(0.06, 0.09, 0.14, 0.90)
		r_sb.border_color = Color(1.0, 0.82, 0.25, 0.88) if is_needed else Color(0.20, 0.35, 0.45, 0.75)
		r_sb.set_border_width_all(1)
		r_sb.set_corner_radius_all(6)
		r_sb.content_margin_left = 8
		r_sb.content_margin_right = 8
		r_sb.content_margin_top = 4
		r_sb.content_margin_bottom = 4
		row.add_theme_stylebox_override("panel", r_sb)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		row.add_child(hbox)
		
		var ico = TextureRect.new()
		ico.custom_minimum_size = Vector2(28, 28)
		ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ico.texture = GameData.get_item_texture(st_type)
		hbox.add_child(ico)
		
		var info_v = VBoxContainer.new()
		info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_v.add_theme_constant_override("separation", 1)
		hbox.add_child(info_v)
		
		var top_r = HBoxContainer.new()
		top_r.add_theme_constant_override("separation", 6)
		info_v.add_child(top_r)
		
		var n_lbl = Label.new()
		n_lbl.text = GameData.get_stone_display_name(st_type)
		n_lbl.add_theme_font_size_override("font_size", 11)
		n_lbl.add_theme_color_override("font_color", Color("#FFF59D") if is_needed else Color.WHITE)
		top_r.add_child(n_lbl)
		
		if is_needed:
			var badge_lbl = Label.new()
			badge_lbl.text = "★ Team"
			badge_lbl.add_theme_font_size_override("font_size", 10)
			badge_lbl.add_theme_color_override("font_color", Color("#69F0AE"))
			top_r.add_child(badge_lbl)
			
		var own_lbl = Label.new()
		own_lbl.text = "[Owned: %d]" % owned
		own_lbl.add_theme_font_size_override("font_size", 10)
		own_lbl.add_theme_color_override("font_color", Color("#FFD54F") if owned > 0 else Color("#78909C"))
		top_r.add_child(own_lbl)
		
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(88, 28)
		buy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		buy_btn.add_theme_font_size_override("font_size", 10)
		buy_btn.text = "Buy (%d G)" % GameData.ITEM_COST_STONE
		
		var is_tutorial_stage4 = (not GameData.tutorial_completed and GameData.tutorial_step == 4)
		var st_req_type = ""
		if is_tutorial_stage4:
			var starter_inf = GameData.get_tutorial_starter_info(GameData.tutorial_starter_id)
			st_req_type = str(starter_inf.get("stone_type", "Fire"))
			
		if is_tutorial_stage4:
			if st_type == st_req_type:
				buy_btn.disabled = (cur_gold < GameData.ITEM_COST_STONE)
				buy_btn.text = "Buy (10 G) 👈"
			else:
				buy_btn.disabled = true
		else:
			buy_btn.disabled = (cur_gold < GameData.ITEM_COST_STONE)
			
		if not buy_btn.disabled:
			_apply_retro_button_style(buy_btn, Color(0.20, 0.58, 0.38), Color(0.35, 0.85, 0.58), false)
		else:
			_apply_retro_button_style(buy_btn, Color(0.25, 0.30, 0.35), Color(0.35, 0.40, 0.45), false)
		var target_stone = st_type
		buy_btn.pressed.connect(func():
			if GameData.is_drag_scrolling():
				return
			if GameData.buy_campaign_stone(target_stone):
				GameData.add_daily_mission_progress("buy_camp_shop", 1)
				GameData.play_combat_sfx("purchase")
				update_campaign_ui()
				if is_tutorial_stage4 and target_stone == st_req_type:
					var st_name = str(GameData.get_tutorial_starter_info(GameData.tutorial_starter_id).get("name", "Starter"))
					_show_tutorial_prompt_modal(
						"💎 ¡Piedra Comprada!",
						"¡Has adquirido la Piedra requerida!\n\nAhora cierra la Tienda de Suministros y pulsa [b]'✨ Evolve!'[/b] en tu [b]%s[/b] para realizar la evolución." % st_name,
						"¡A Evolucionar! ✨",
						func():
							camp_shop_modal.visible = false
					)
		)
		hbox.add_child(buy_btn)
		camp_shop_stones_list.add_child(row)

func _refresh_camp_bag_items_ui() -> void:
	if not camp_bag_items_view:
		return
	for child in camp_bag_items_view.get_children():
		child.queue_free()
		
	var inv = GameData.get_active_campaign_inventory()
	
	var item_defs = [
		{
			"id": "potion",
			"name": "Potion",
			"desc": "Restores up to 10 HP to a damaged Pokémon.",
			"stock": inv.get("potion", 0)
		},
		{
			"id": "super_potion",
			"name": "Super Potion",
			"desc": "Restores up to 25 HP to a damaged Pokémon.",
			"stock": inv.get("super_potion", 0)
		},
		{
			"id": "hyper_potion",
			"name": "Hyper Potion",
			"desc": "Restores 100% HP (Full Max HP) to a damaged Pokémon.",
			"stock": inv.get("hyper_potion", 0)
		},
		{
			"id": "revive",
			"name": "Revive",
			"desc": "Revives a fainted Pokémon with 50% max HP.",
			"stock": inv.get("revive", 0)
		},
		{
			"id": "remedy",
			"name": "Remedy",
			"desc": "Cures all negative status conditions (Burn, Poison, Flinch, etc).",
			"stock": inv.get("remedy", 0)
		},
		{
			"id": "poke_flute",
			"name": "Poké Flute",
			"desc": "Plays a melody that awakens any sleeping Pokémon. Permanent item (not consumed).",
			"stock": inv.get("poke_flute", 0)
		},
		{
			"id": "ether",
			"name": "Ether",
			"desc": "Restores 100% Energy (⚡). Used during combat.",
			"stock": inv.get("ether", 0)
		}
	]
	
	for it in item_defs:
		var item_id = it["id"]
		var stock = it["stock"]
		
		var row = PanelContainer.new()
		var row_sb = StyleBoxFlat.new()
		row_sb.bg_color = Color(0.06, 0.09, 0.14, 0.90)
		row_sb.border_color = Color(0.20, 0.35, 0.45, 0.8)
		row_sb.set_border_width_all(1)
		row_sb.set_corner_radius_all(6)
		row_sb.content_margin_left = 10
		row_sb.content_margin_right = 10
		row_sb.content_margin_top = 8
		row_sb.content_margin_bottom = 8
		row.add_theme_stylebox_override("panel", row_sb)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		row.add_child(hbox)
		
		var icon_rect = TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(40, 40)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = GameData.get_item_texture(item_id)
		hbox.add_child(icon_rect)
		
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", 2)
		hbox.add_child(info_vbox)
		
		var title_row = HBoxContainer.new()
		title_row.add_theme_constant_override("separation", 8)
		info_vbox.add_child(title_row)
		
		var name_lbl = Label.new()
		name_lbl.text = it["name"]
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		title_row.add_child(name_lbl)
		
		var stock_lbl = Label.new()
		if item_id == "poke_flute":
			stock_lbl.text = "[Owned]" if stock > 0 else "[Not Owned]"
		else:
			stock_lbl.text = "[Owned: %d]" % stock
		stock_lbl.add_theme_font_size_override("font_size", 11)
		stock_lbl.add_theme_color_override("font_color", Color("#FFD54F") if stock > 0 else Color("#78909C"))
		title_row.add_child(stock_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = it["desc"]
		desc_lbl.add_theme_font_size_override("font_size", 11)
		desc_lbl.add_theme_color_override("font_color", Color("#B0BEC5"))
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_vbox.add_child(desc_lbl)
		
		var use_btn = Button.new()
		use_btn.custom_minimum_size = Vector2(90, 36)
		use_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		use_btn.add_theme_font_size_override("font_size", 11)
		
		if item_id == "ether":
			use_btn.text = "In Battle Only"
			use_btn.disabled = true
			_apply_retro_button_style(use_btn, Color(0.3, 0.3, 0.35), Color(0.4, 0.4, 0.45), false)
		else:
			use_btn.text = "Use / Usar"
			use_btn.disabled = (stock <= 0)
			if stock > 0:
				_apply_retro_button_style(use_btn, Color(0.22, 0.63, 0.41), Color(0.40, 0.85, 0.60), false)
			else:
				_apply_retro_button_style(use_btn, Color(0.25, 0.30, 0.35), Color(0.35, 0.40, 0.45), false)
			var cur_id = item_id
			use_btn.pressed.connect(func(): _show_camp_bag_targets(cur_id))
			
		hbox.add_child(use_btn)
		camp_bag_items_view.add_child(row)
		
	# Mostrar Piedras Evolutivas en posesión dentro de la Mochila
	for st_type in GameData.EVOLUTION_STONE_TYPES:
		var st_owned = GameData.get_campaign_stone_count(st_type)
		if st_owned <= 0:
			continue
		var s_row = PanelContainer.new()
		var s_sb = StyleBoxFlat.new()
		s_sb.bg_color = Color(0.08, 0.11, 0.18, 0.92)
		s_sb.border_color = Color(0.65, 0.52, 0.18, 0.85)
		s_sb.set_border_width_all(1)
		s_sb.set_corner_radius_all(6)
		s_sb.content_margin_left = 10
		s_sb.content_margin_right = 10
		s_sb.content_margin_top = 6
		s_sb.content_margin_bottom = 6
		s_row.add_theme_stylebox_override("panel", s_sb)
		
		var s_hbox = HBoxContainer.new()
		s_hbox.add_theme_constant_override("separation", 10)
		s_row.add_child(s_hbox)
		
		var s_ico = TextureRect.new()
		s_ico.custom_minimum_size = Vector2(36, 36)
		s_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		s_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		s_ico.texture = GameData.get_item_texture(st_type)
		s_hbox.add_child(s_ico)
		
		var s_info = VBoxContainer.new()
		s_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s_info.add_theme_constant_override("separation", 2)
		s_hbox.add_child(s_info)
		
		var s_title = Label.new()
		s_title.text = "%s  [Owned: %d]" % [GameData.get_stone_display_name(st_type), st_owned]
		s_title.add_theme_font_size_override("font_size", 12)
		s_title.add_theme_color_override("font_color", Color("#FFF59D"))
		s_info.add_child(s_title)
		
		var s_desc = Label.new()
		s_desc.text = "Evolution Stone (1x for Stage 1 • 2x for Stage 2)."
		s_desc.add_theme_font_size_override("font_size", 10)
		s_desc.add_theme_color_override("font_color", Color("#B0BEC5"))
		s_info.add_child(s_desc)
		
		var s_btn = Button.new()
		s_btn.custom_minimum_size = Vector2(90, 32)
		s_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		s_btn.add_theme_font_size_override("font_size", 11)
		s_btn.text = "✨ Evolve"
		var match_team_idx = -1
		var team = GameData.get_active_campaign_team_state()
		for tidx in range(team.size()):
			var tp = team[tidx]
			var topts = GameData.get_evolution_options(int(tp.get("id", -1)), true)
			for topt in topts:
				if str(topt.get("stone_type", "")) == st_type:
					match_team_idx = tidx
					break
			if match_team_idx != -1:
				break
		s_btn.disabled = (match_team_idx == -1)
		if match_team_idx != -1:
			_apply_retro_button_style(s_btn, Color(0.22, 0.63, 0.41), Color(0.40, 0.85, 0.60), false)
			var target_tidx = match_team_idx
			s_btn.pressed.connect(func():
				camp_bag_modal.visible = false
				_open_camp_evolution_selector(target_tidx)
			)
		else:
			_apply_retro_button_style(s_btn, Color(0.25, 0.30, 0.35), Color(0.35, 0.40, 0.45), false)
		s_hbox.add_child(s_btn)
		camp_bag_items_view.add_child(s_row)

func _show_camp_bag_targets(item_id: String) -> void:
	camp_bag_selected_item = item_id
	camp_bag_items_view.visible = false
	camp_bag_targets_view.visible = true
	
	for child in camp_bag_targets_container.get_children():
		child.queue_free()
		
	var item_display_name = item_id.capitalize()
	camp_bag_prompt_lbl.text = "Select a Pokémon to use %s on:" % item_display_name
	
	var team = GameData.get_active_campaign_team_state()
	var inv = GameData.get_active_campaign_inventory()
	var stock = inv.get(item_id, 0)
	
	for i in range(team.size()):
		var p = team[i]
		var pkmn_idx = i
		
		var panel = PanelContainer.new()
		var p_sb = StyleBoxFlat.new()
		p_sb.bg_color = Color(0.07, 0.10, 0.16, 0.95)
		p_sb.border_color = Color(0.25, 0.45, 0.55, 0.8)
		p_sb.set_border_width_all(1)
		p_sb.set_corner_radius_all(6)
		p_sb.content_margin_left = 10
		p_sb.content_margin_right = 10
		p_sb.content_margin_top = 6
		p_sb.content_margin_bottom = 6
		panel.add_theme_stylebox_override("panel", p_sb)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		panel.add_child(hbox)
		
		# Miniatura del Pokémon
		var thumb = TextureRect.new()
		thumb.custom_minimum_size = Vector2(44, 44)
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var tex = GameData.get_pokemon_texture(p.get("texture_path", ""))
		if tex: thumb.texture = tex
		if p["current_hp"] <= 0:
			thumb.modulate = Color(0.5, 0.5, 0.5, 0.7)
		hbox.add_child(thumb)
		
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", 3)
		hbox.add_child(info_vbox)
		
		# Fila nombre + fase
		var head_row = HBoxContainer.new()
		head_row.add_theme_constant_override("separation", 6)
		info_vbox.add_child(head_row)
		
		var type_ico = TextureRect.new()
		type_ico.custom_minimum_size = Vector2(16, 16)
		type_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		type_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		type_ico.texture = GameData.get_type_icon_texture(p["type"])
		head_row.add_child(type_ico)
		
		var name_lbl = Label.new()
		name_lbl.text = "%dº %s [%s]" % [i + 1, p["name"], p["stage"]]
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		head_row.add_child(name_lbl)
		
		# HP row
		var hp_row = HBoxContainer.new()
		hp_row.add_theme_constant_override("separation", 6)
		info_vbox.add_child(hp_row)
		
		var hp_bar = ProgressBar.new()
		hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hp_bar.custom_minimum_size = Vector2(0, 10)
		hp_bar.max_value = max(1, p["max_hp"])
		hp_bar.value = p["current_hp"]
		hp_bar.show_percentage = false
		hp_row.add_child(hp_bar)
		
		var hp_lbl = Label.new()
		hp_lbl.text = "%d / %d HP" % [p["current_hp"], p["max_hp"]]
		hp_lbl.add_theme_font_size_override("font_size", 11)
		hp_lbl.add_theme_color_override("font_color", Color("#E0E0E0"))
		hp_row.add_child(hp_lbl)
		
		# Status indicator
		var stat_lbl = Label.new()
		stat_lbl.add_theme_font_size_override("font_size", 10)
		if p["current_hp"] <= 0:
			stat_lbl.text = "💀 Fainted"
			stat_lbl.add_theme_color_override("font_color", Color("#EF5350"))
		elif int(p.get("burn_turns", 0)) > 0 or bool(p.get("is_poisoned", false)) or int(p.get("is_asleep_turns", 0)) > 0:
			var s_arr = []
			if int(p.get("burn_turns", 0)) > 0: s_arr.append("🔥 Burned (%d)" % int(p.get("burn_turns", 0)))
			if bool(p.get("is_poisoned", false)): s_arr.append("🟣 Poisoned")
			if int(p.get("is_asleep_turns", 0)) > 0: s_arr.append("💤 Asleep (%d)" % int(p.get("is_asleep_turns", 0)))
			stat_lbl.text = ", ".join(s_arr)
			stat_lbl.add_theme_color_override("font_color", Color("#FFA726"))
		else:
			stat_lbl.text = "💚 Healthy"
			stat_lbl.add_theme_color_override("font_color", Color("#81C784"))
		info_vbox.add_child(stat_lbl)
		
		# Botón Aplicar
		var apply_btn = Button.new()
		apply_btn.custom_minimum_size = Vector2(100, 34)
		apply_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		apply_btn.add_theme_font_size_override("font_size", 11)
		
		var can_apply = false
		var btn_text = "Apply"
		
		if stock <= 0:
			can_apply = false
			btn_text = "No Stock"
		elif item_id == "potion":
			if p["current_hp"] <= 0:
				can_apply = false
				btn_text = "Fainted"
			elif p["current_hp"] >= p["max_hp"]:
				can_apply = false
				btn_text = "Full HP"
			else:
				can_apply = true
				btn_text = "Use (+10 HP)"
		elif item_id == "super_potion":
			if p["current_hp"] <= 0:
				can_apply = false
				btn_text = "Fainted"
			elif p["current_hp"] >= p["max_hp"]:
				can_apply = false
				btn_text = "Full HP"
			else:
				can_apply = true
				btn_text = "Use (+25 HP)"
		elif item_id == "hyper_potion":
			if p["current_hp"] <= 0:
				can_apply = false
				btn_text = "Fainted"
			elif p["current_hp"] >= p["max_hp"]:
				can_apply = false
				btn_text = "Full HP"
			else:
				can_apply = true
				btn_text = "Use (Full HP)"
		elif item_id == "poke_flute":
			if p["current_hp"] <= 0:
				can_apply = false
				btn_text = "Fainted"
			elif int(p.get("is_asleep_turns", 0)) <= 0:
				can_apply = false
				btn_text = "Not Asleep"
			else:
				can_apply = true
				btn_text = "Awaken 🎶"
		elif item_id == "revive":
			if p["current_hp"] > 0:
				can_apply = false
				btn_text = "Not Fainted"
			else:
				can_apply = true
				btn_text = "Revive (50%)"
		elif item_id == "remedy":
			var has_stat = (int(p.get("burn_turns", 0)) > 0) or bool(p.get("is_poisoned", false)) or bool(p.get("is_flinched", false)) or (int(p.get("is_asleep_turns", 0)) > 0)
			if not has_stat:
				can_apply = false
				btn_text = "No Status"
			elif p["current_hp"] <= 0:
				can_apply = false
				btn_text = "Fainted"
			else:
				can_apply = true
				btn_text = "Cure Status"
				
		apply_btn.text = btn_text
		apply_btn.disabled = not can_apply
		if can_apply:
			_apply_retro_button_style(apply_btn, Color(0.20, 0.60, 0.40), Color(0.35, 0.85, 0.60), false)
			var cur_it = item_id
			apply_btn.pressed.connect(func():
				var success = false
				if cur_it == "potion":
					success = GameData.use_potion_on_campaign_pkmn(pkmn_idx)
				elif cur_it == "super_potion":
					success = GameData.use_super_potion_on_campaign_pkmn(pkmn_idx)
				elif cur_it == "hyper_potion":
					success = GameData.use_hyper_potion_on_campaign_pkmn(pkmn_idx)
				elif cur_it == "poke_flute":
					success = GameData.use_poke_flute_on_campaign_pkmn(pkmn_idx)
				elif cur_it == "revive":
					success = GameData.use_revive_on_campaign_pkmn(pkmn_idx)
				elif cur_it == "remedy":
					success = GameData.use_remedy_on_campaign_pkmn(pkmn_idx)
				if success:
					GameData.play_combat_sfx("use")
					GameData.add_daily_mission_progress("use_camp_items", 1)
					if cur_it in ["potion", "super_potion", "hyper_potion"]:
						GameData.add_daily_mission_progress("heal_hp", 1)
					update_campaign_ui()
					if cur_it == "revive":
						var pending = GameData.get_pending_campaign_evolutions()
						if not pending.is_empty():
							camp_bag_modal.visible = false
							_check_and_run_camp_evolutions()
							return
					_show_camp_bag_targets(cur_it)
			)
		else:
			_apply_retro_button_style(apply_btn, Color(0.25, 0.30, 0.35), Color(0.35, 0.40, 0.45), false)
			
		hbox.add_child(apply_btn)
		camp_bag_targets_container.add_child(panel)

func _setup_camp_pokemon_inspector_modal() -> void:
	if camp_pokemon_inspector_modal != null:
		return
	camp_pokemon_inspector_modal = Control.new()
	camp_pokemon_inspector_modal.name = "CampPokemonInspectorModal"
	camp_pokemon_inspector_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_pokemon_inspector_modal.visible = false
	camp_pokemon_inspector_modal.z_index = 50
	add_child(camp_pokemon_inspector_modal)
	
	var insp_bg = ColorRect.new()
	insp_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	insp_bg.color = Color(0, 0, 0, 0.80)
	camp_pokemon_inspector_modal.add_child(insp_bg)
	
	var insp_center = CenterContainer.new()
	insp_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_pokemon_inspector_modal.add_child(insp_center)
	
	var insp_panel = PanelContainer.new()
	insp_panel.custom_minimum_size = Vector2(490, 0)
	var insp_sb = StyleBoxFlat.new()
	insp_sb.bg_color = Color(0.08, 0.11, 0.17, 0.98)
	insp_sb.border_color = Color(0.25, 0.55, 0.65, 0.90)
	insp_sb.set_border_width_all(2)
	insp_sb.set_corner_radius_all(8)
	insp_sb.content_margin_left = 16
	insp_sb.content_margin_right = 16
	insp_sb.content_margin_top = 14
	insp_sb.content_margin_bottom = 14
	insp_panel.add_theme_stylebox_override("panel", insp_sb)
	insp_center.add_child(insp_panel)
	
	var insp_scroll = ScrollContainer.new()
	insp_scroll.custom_minimum_size = Vector2(460, 480)
	insp_panel.add_child(insp_scroll)
	
	var insp_vbox = VBoxContainer.new()
	insp_vbox.name = "InspVBox"
	insp_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	insp_vbox.add_theme_constant_override("separation", 10)
	insp_scroll.add_child(insp_vbox)

func _open_camp_pokemon_inspector(p: Dictionary) -> void:
	if not camp_pokemon_inspector_modal:
		return
	camp_pokemon_inspector_modal.visible = true
	var vbox = camp_pokemon_inspector_modal.find_child("InspVBox", true, false)
	if not vbox:
		return
		
	for child in vbox.get_children():
		child.queue_free()
		
	var cid = int(p.get("id", 1))
	var full_inst = GameData.create_pokemon_instance(cid)
	if not full_inst:
		return
		
	# Header: Name, Stage, Close button
	var head_row = HBoxContainer.new()
	head_row.add_theme_constant_override("separation", 8)
	
	var type_ico = TextureRect.new()
	type_ico.custom_minimum_size = Vector2(22, 22)
	type_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	type_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	type_ico.texture = GameData.get_type_icon_texture(p["type"])
	head_row.add_child(type_ico)
	
	var p_tier = str(p.get("tier", full_inst.tier if full_inst else "C")).strip_edges().to_upper()
	if p_tier == "": p_tier = "C"
	var title_lbl = Label.new()
	title_lbl.text = "%s • %s • [Tier %s]" % [p["name"], p["stage"], p_tier]
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_row.add_child(title_lbl)
	
	var btn_close = Button.new()
	btn_close.text = "✕"
	btn_close.custom_minimum_size = Vector2(30, 30)
	btn_close.pressed.connect(func(): camp_pokemon_inspector_modal.visible = false)
	head_row.add_child(btn_close)
	vbox.add_child(head_row)
	
	var sep1 = HSeparator.new()
	vbox.add_child(sep1)
	
	# Main Stats Row: Sprite + Stats
	var main_row = HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 12)
	
	var art_rect = TextureRect.new()
	art_rect.custom_minimum_size = Vector2(80, 100)
	art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex = GameData.get_pokemon_texture(p.get("texture_path", ""))
	if tex: art_rect.texture = tex
	if p["current_hp"] <= 0:
		art_rect.modulate = Color(0.5, 0.5, 0.5, 0.7)
	main_row.add_child(art_rect)
	
	var stats_box = VBoxContainer.new()
	stats_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_box.add_theme_constant_override("separation", 4)
	main_row.add_child(stats_box)
	
	var hp_lbl = Label.new()
	hp_lbl.text = "❤️ HP: %d / %d" % [p["current_hp"], p["max_hp"]]
	hp_lbl.add_theme_font_size_override("font_size", 12)
	hp_lbl.add_theme_color_override("font_color", Color("#81C784"))
	stats_box.add_child(hp_lbl)
	
	var nrg_lbl = Label.new()
	nrg_lbl.text = "⚡ Max Energy: %d ⚡  |  👟 Speed: %d  |  🏆 Tier %s" % [full_inst.max_energy, full_inst.speed, p_tier]
	nrg_lbl.add_theme_font_size_override("font_size", 11)
	nrg_lbl.add_theme_color_override("font_color", Color("#FFF176"))
	stats_box.add_child(nrg_lbl)
	
	var cur_exp = int(p.get("current_exp", 0))
	var req_exp = full_inst.get_required_exp()
	var exp_str = "MAX (Final Stage)" if req_exp <= 0 else "%d / %d" % [cur_exp, req_exp]
	var exp_lbl = Label.new()
	exp_lbl.text = "🌟 EXP: %s" % exp_str
	exp_lbl.add_theme_font_size_override("font_size", 11)
	exp_lbl.add_theme_color_override("font_color", Color("#64B5F6"))
	stats_box.add_child(exp_lbl)
	
	# Status condition
	var cond_lbl = Label.new()
	cond_lbl.add_theme_font_size_override("font_size", 11)
	if p["current_hp"] <= 0:
		cond_lbl.text = "Status: 💀 Fainted (Requires Revive)"
		cond_lbl.add_theme_color_override("font_color", Color("#EF5350"))
	elif int(p.get("burn_turns", 0)) > 0 or bool(p.get("is_poisoned", false)):
		var s_list = []
		if int(p.get("burn_turns", 0)) > 0: s_list.append("🔥 Burned (%d)" % int(p.get("burn_turns", 0)))
		if bool(p.get("is_poisoned", false)): s_list.append("🟣 Poisoned")
		cond_lbl.text = "Status: " + ", ".join(s_list)
		cond_lbl.add_theme_color_override("font_color", Color("#FFA726"))
	else:
		cond_lbl.text = "Status: 💚 Healthy"
		cond_lbl.add_theme_color_override("font_color", Color("#81C784"))
	stats_box.add_child(cond_lbl)
	
	# Weakness / Resistance
	var weak = full_inst.weakness if full_inst.weakness != "" else GameData.get_default_weakness_for_type(p["type"])
	var res = GameData.get_effective_resistances(p["type"], full_inst.resistant)
	var wr_lbl = Label.new()
	wr_lbl.text = "Weak (+2): %s  |  Resist (-2): %s" % [weak if weak != "" else "None", ", ".join(res) if res.size() > 0 else "None"]
	wr_lbl.add_theme_font_size_override("font_size", 10)
	wr_lbl.add_theme_color_override("font_color", Color("#B0BEC5"))
	stats_box.add_child(wr_lbl)
	
	vbox.add_child(main_row)
	
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)
	
	# Moves Section
	var moves_hdr = Label.new()
	moves_hdr.text = "⚔️ POKÉMON MOVES"
	moves_hdr.add_theme_font_size_override("font_size", 12)
	moves_hdr.add_theme_color_override("font_color", Color("#80DEEA"))
	vbox.add_child(moves_hdr)
	
	for m_idx in range(full_inst.moves.size()):
		var m = full_inst.moves[m_idx]
		var m_panel = PanelContainer.new()
		var m_sb = StyleBoxFlat.new()
		m_sb.bg_color = Color(0.06, 0.08, 0.12, 0.9)
		m_sb.border_color = Color(0.20, 0.35, 0.45, 0.7)
		m_sb.set_border_width_all(1)
		m_sb.set_corner_radius_all(6)
		m_sb.content_margin_left = 8
		m_sb.content_margin_right = 8
		m_sb.content_margin_top = 6
		m_sb.content_margin_bottom = 6
		m_panel.add_theme_stylebox_override("panel", m_sb)
		
		var m_box = VBoxContainer.new()
		m_box.add_theme_constant_override("separation", 3)
		m_panel.add_child(m_box)
		
		var m_title = Label.new()
		var dmg_str = "%d DMG" % m.base_damage if m.effect_type != "MULTI_ATTACK" else "1-3 DMG/hit"
		m_title.text = "Move %d: %s [%s] • %s (Cost: %d⚡ | Req: %d⚡)" % [
			m_idx + 1, m.name, m.type, dmg_str, m.cost, m.min_energy_req
		]
		m_title.add_theme_font_size_override("font_size", 11)
		m_title.add_theme_color_override("font_color", Color("#FFE082"))
		m_box.add_child(m_title)
		
		var m_desc = Label.new()
		m_desc.text = m.description if m.description != "" else "Standard attack."
		m_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		m_desc.add_theme_font_size_override("font_size", 10)
		m_desc.add_theme_color_override("font_color", Color("#CFD8DC"))
		m_box.add_child(m_desc)
		
		if m.can_boost:
			var b_lbl = Label.new()
			b_lbl.text = "🔥 Boost (+%d⚡): %s" % [
				m.boost_cost,
				GameData.format_move_boost_summary(m.boost_cost, m.boost_damage, m.effect_type, m.description)
			]
			b_lbl.add_theme_font_size_override("font_size", 10)
			b_lbl.add_theme_color_override("font_color", Color("#FFAB40"))
			m_box.add_child(b_lbl)
			
		vbox.add_child(m_panel)
		
	# Passive Ability
	if full_inst.has_passive and full_inst.passive_name != "":
		var pas_panel = PanelContainer.new()
		var p_sb = StyleBoxFlat.new()
		p_sb.bg_color = Color(0.12, 0.08, 0.16, 0.9)
		p_sb.border_color = Color(0.45, 0.25, 0.55, 0.7)
		p_sb.set_border_width_all(1)
		p_sb.set_corner_radius_all(6)
		p_sb.content_margin_left = 8
		p_sb.content_margin_right = 8
		p_sb.content_margin_top = 6
		p_sb.content_margin_bottom = 6
		pas_panel.add_theme_stylebox_override("panel", p_sb)
		
		var p_box = VBoxContainer.new()
		p_box.add_theme_constant_override("separation", 2)
		pas_panel.add_child(p_box)
		
		var p_title = Label.new()
		p_title.text = "✨ Passive: %s" % full_inst.passive_name
		p_title.add_theme_font_size_override("font_size", 11)
		p_title.add_theme_color_override("font_color", Color("#CE93D8"))
		p_box.add_child(p_title)
		
		var p_desc = Label.new()
		p_desc.text = full_inst.passive_description
		p_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		p_desc.add_theme_font_size_override("font_size", 10)
		p_desc.add_theme_color_override("font_color", Color("#E1BEE7"))
		p_box.add_child(p_desc)
		vbox.add_child(pas_panel)
		
	var sep3 = HSeparator.new()
	vbox.add_child(sep3)
	
	var btn_done = Button.new()
	btn_done.text = "⬅ Back to Camp"
	btn_done.custom_minimum_size = Vector2(0, 34)
	btn_done.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_done, Color(0.25, 0.45, 0.55), Color(0.35, 0.65, 0.80), false)
	btn_done.pressed.connect(func(): camp_pokemon_inspector_modal.visible = false)
	vbox.add_child(btn_done)

# --- CAMP EVOLUTION SYSTEM ---
func _setup_camp_evolution_modal() -> void:
	if camp_evo_modal != null:
		return
	camp_evo_modal = Control.new()
	camp_evo_modal.name = "CampEvolutionModal"
	camp_evo_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_evo_modal.visible = false
	camp_evo_modal.z_index = 25
	add_child(camp_evo_modal)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.04, 0.08, 0.88)
	camp_evo_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_evo_modal.add_child(center)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 460)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.11, 0.17, 0.98)
	sb.border_color = Color(1.0, 0.84, 0.0, 0.95)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 18
	sb.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	camp_evo_title_lbl = Label.new()
	camp_evo_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	camp_evo_title_lbl.text = "🌟 POKÉMON EVOLUTION! 🌟"
	camp_evo_title_lbl.add_theme_font_size_override("font_size", 18)
	camp_evo_title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	vbox.add_child(camp_evo_title_lbl)
	
	camp_evo_sub_lbl = Label.new()
	camp_evo_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	camp_evo_sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	camp_evo_sub_lbl.text = "Your Pokémon is evolving at Camp!"
	camp_evo_sub_lbl.add_theme_font_size_override("font_size", 13)
	camp_evo_sub_lbl.add_theme_color_override("font_color", Color("#B0BEC5"))
	vbox.add_child(camp_evo_sub_lbl)
	
	var sprite_box = CenterContainer.new()
	sprite_box.custom_minimum_size = Vector2(0, 180)
	vbox.add_child(sprite_box)
	
	camp_evo_sprite = TextureRect.new()
	camp_evo_sprite.custom_minimum_size = Vector2(160, 160)
	camp_evo_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	camp_evo_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite_box.add_child(camp_evo_sprite)
	
	var stats_panel = PanelContainer.new()
	var s_sb = StyleBoxFlat.new()
	s_sb.bg_color = Color(0.12, 0.16, 0.24, 0.9)
	s_sb.border_color = Color(0.3, 0.45, 0.6, 0.7)
	s_sb.set_border_width_all(1)
	s_sb.set_corner_radius_all(8)
	s_sb.content_margin_left = 12
	s_sb.content_margin_right = 12
	s_sb.content_margin_top = 8
	s_sb.content_margin_bottom = 8
	stats_panel.add_theme_stylebox_override("panel", s_sb)
	vbox.add_child(stats_panel)
	
	camp_evo_stats_lbl = Label.new()
	camp_evo_stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	camp_evo_stats_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	camp_evo_stats_lbl.add_theme_font_size_override("font_size", 12)
	camp_evo_stats_lbl.add_theme_color_override("font_color", Color("#ECEFF1"))
	stats_panel.add_child(camp_evo_stats_lbl)
	
	btn_camp_evo_continue = Button.new()
	btn_camp_evo_continue.text = "Continue ➔"
	btn_camp_evo_continue.custom_minimum_size = Vector2(0, 38)
	btn_camp_evo_continue.add_theme_font_size_override("font_size", 13)
	_apply_retro_button_style(btn_camp_evo_continue, Color(0.20, 0.65, 0.35), Color(0.35, 0.85, 0.50), false)
	btn_camp_evo_continue.pressed.connect(_on_camp_evo_continue_pressed)
	vbox.add_child(btn_camp_evo_continue)

func _setup_camp_evolution_selector_modal() -> void:
	if camp_evo_selector_modal != null:
		return
	camp_evo_selector_modal = Control.new()
	camp_evo_selector_modal.name = "CampEvolutionSelectorModal"
	camp_evo_selector_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_evo_selector_modal.visible = false
	camp_evo_selector_modal.z_index = 45
	add_child(camp_evo_selector_modal)
	
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.04, 0.08, 0.84)
	camp_evo_selector_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_evo_selector_modal.add_child(center)
	
	var panel = PanelContainer.new()
	var ep5_target_w: float = minf(460.0, get_viewport_rect().size.x - 24.0)
	panel.custom_minimum_size = Vector2(ep5_target_w, 0)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.11, 0.17, 0.98)
	sb.border_color = Color(1.0, 0.82, 0.25, 0.92)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(436, 460)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	
	var vbox = VBoxContainer.new()
	vbox.name = "EvoSelectVBox"
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(vbox)

func _open_camp_evolution_selector(team_idx: int) -> void:
	if not camp_evo_selector_modal:
		_setup_camp_evolution_selector_modal()
	var team = GameData.get_active_campaign_team_state()
	if team_idx < 0 or team_idx >= team.size():
		return
	var p = team[team_idx]
	var cid = int(p.get("id", -1))
	var opts = GameData.get_evolution_options(cid, true)
	if opts.is_empty():
		return
		
	camp_evo_selector_modal.visible = true
	var vbox = camp_evo_selector_modal.find_child("EvoSelectVBox", true, false)
	if not vbox:
		return
	for child in vbox.get_children():
		child.queue_free()
		
	var head_row = HBoxContainer.new()
	head_row.add_theme_constant_override("separation", 8)
	var title_lbl = Label.new()
	title_lbl.text = "✨ EVOLVE %s (%s)" % [str(p.get("name", "Pokémon")).to_upper(), str(p.get("stage", "Basic"))]
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_row.add_child(title_lbl)
	
	var btn_close_x = Button.new()
	btn_close_x.text = "✕"
	btn_close_x.custom_minimum_size = Vector2(30, 30)
	btn_close_x.pressed.connect(func(): camp_evo_selector_modal.visible = false)
	head_row.add_child(btn_close_x)
	vbox.add_child(head_row)
	
	var cur_gold = GameData.get_active_campaign_gold()
	var cur_exp = int(p.get("current_exp", 0))
	var req_exp = GameData.get_pokemon_required_exp(cid)
	var sub_lbl = Label.new()
	sub_lbl.text = "💰 Gold: %d G  |  🌟 EXP: %d / %d  |  Choose evolution branch & use required Stone(s):" % [cur_gold, cur_exp, req_exp]
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color("#80DEEA"))
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(sub_lbl)
	
	var sep1 = HSeparator.new()
	vbox.add_child(sep1)
	
	for opt in opts:
		var to_id = int(opt.get("to_id", -1))
		var to_name = str(opt.get("to_name", "Evolution"))
		var to_stage = str(opt.get("to_stage", "Stage 1"))
		var stone_type = str(opt.get("stone_type", "Heart"))
		var stone_name = str(opt.get("stone_name", "Heart Stone"))
		var stone_req = int(opt.get("stone_count", 1))
		var stone_owned = GameData.get_campaign_stone_count(stone_type)
		var is_unlocked = bool(opt.get("is_unlocked", false))
		var target_inst = GameData.create_pokemon_instance(to_id)
		if not target_inst:
			continue
			
		var can_evo = (int(p.get("current_hp", 0)) > 0 and cur_exp >= req_exp and is_unlocked and stone_owned >= stone_req)
		
		var b_panel = PanelContainer.new()
		var b_sb = StyleBoxFlat.new()
		b_sb.bg_color = Color(0.09, 0.14, 0.22, 0.96) if can_evo else Color(0.06, 0.09, 0.14, 0.92)
		b_sb.border_color = Color(0.35, 0.90, 0.55, 0.92) if can_evo else Color(0.28, 0.42, 0.55, 0.80)
		b_sb.set_border_width_all(2 if can_evo else 1)
		b_sb.set_corner_radius_all(8)
		b_sb.content_margin_left = 10
		b_sb.content_margin_right = 10
		b_sb.content_margin_top = 8
		b_sb.content_margin_bottom = 8
		b_panel.add_theme_stylebox_override("panel", b_sb)
		
		var b_vbox = VBoxContainer.new()
		b_vbox.add_theme_constant_override("separation", 6)
		b_panel.add_child(b_vbox)
		
		var main_r = HBoxContainer.new()
		main_r.add_theme_constant_override("separation", 10)
		b_vbox.add_child(main_r)
		
		var sp_rect = TextureRect.new()
		sp_rect.custom_minimum_size = Vector2(64, 80)
		sp_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sp_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sp_rect.texture = GameData.get_pokemon_texture(target_inst.texture_path)
		if not is_unlocked:
			sp_rect.modulate = Color(0.45, 0.45, 0.45, 0.8)
		main_r.add_child(sp_rect)
		
		var mid_v = VBoxContainer.new()
		mid_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		mid_v.add_theme_constant_override("separation", 3)
		main_r.add_child(mid_v)
		
		var name_r = HBoxContainer.new()
		name_r.add_theme_constant_override("separation", 6)
		mid_v.add_child(name_r)
		
		var t_ico = TextureRect.new()
		t_ico.custom_minimum_size = Vector2(18, 18)
		t_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t_ico.texture = GameData.get_type_icon_texture(target_inst.type)
		name_r.add_child(t_ico)
		
		var n_lbl = Label.new()
		n_lbl.text = "%s • %s [Tier %s]" % [to_name, to_stage, target_inst.tier]
		n_lbl.add_theme_font_size_override("font_size", 13)
		n_lbl.add_theme_color_override("font_color", Color("#FFF59D") if can_evo else Color.WHITE)
		name_r.add_child(n_lbl)
		
		var st_lbl = Label.new()
		st_lbl.text = "❤️ %d HP  |  👟 %d SPD  |  ⚡ %d Max NRG" % [target_inst.max_hp, target_inst.speed, target_inst.max_energy]
		st_lbl.add_theme_font_size_override("font_size", 11)
		st_lbl.add_theme_color_override("font_color", Color("#81C784"))
		mid_v.add_child(st_lbl)
		
		if target_inst.moves.size() >= 2:
			var mv_lbl = Label.new()
			mv_lbl.text = "⚔️ Moves: %s & %s" % [target_inst.moves[0].name, target_inst.moves[1].name]
			mv_lbl.add_theme_font_size_override("font_size", 10)
			mv_lbl.add_theme_color_override("font_color", Color("#CFD8DC"))
			mid_v.add_child(mv_lbl)
			
		# Requirement Row (Icon + Text with autowrap)
		var req_r = HBoxContainer.new()
		req_r.add_theme_constant_override("separation", 6)
		req_r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b_vbox.add_child(req_r)
		
		var st_ico = TextureRect.new()
		st_ico.custom_minimum_size = Vector2(20, 20)
		st_ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		st_ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		st_ico.texture = GameData.get_item_texture(stone_type)
		req_r.add_child(st_ico)
		
		var req_lbl = Label.new()
		req_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		req_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		req_lbl.add_theme_font_size_override("font_size", 10)
		var unlock_txt = "✓ Card Unlocked" if is_unlocked else "🔒 Card Locked"
		req_lbl.text = "Requires: %dx %s (Owned: %d)  •  %s" % [stone_req, stone_name, stone_owned, unlock_txt]
		if is_unlocked and stone_owned >= stone_req:
			req_lbl.add_theme_color_override("font_color", Color("#69F0AE"))
		else:
			req_lbl.add_theme_color_override("font_color", Color("#FFB74D"))
		req_r.add_child(req_lbl)
		
		# Actions Footer Row (Right-aligned, never pushes horizontal width)
		var act_r = HBoxContainer.new()
		act_r.alignment = BoxContainer.ALIGNMENT_END
		act_r.add_theme_constant_override("separation", 8)
		act_r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b_vbox.add_child(act_r)
		
		if stone_owned < stone_req:
			var btn_buy_st = Button.new()
			btn_buy_st.custom_minimum_size = Vector2(104, 28)
			btn_buy_st.add_theme_font_size_override("font_size", 10)
			btn_buy_st.text = "🛒 Buy (%d G)" % GameData.ITEM_COST_STONE
			btn_buy_st.disabled = (cur_gold < GameData.ITEM_COST_STONE)
			if cur_gold >= GameData.ITEM_COST_STONE:
				_apply_retro_button_style(btn_buy_st, Color(0.18, 0.52, 0.65), Color(0.32, 0.78, 0.95), false)
			else:
				_apply_retro_button_style(btn_buy_st, Color(0.25, 0.30, 0.35), Color(0.35, 0.40, 0.45), false)
			var buy_st_type = stone_type
			var reopen_idx = team_idx
			btn_buy_st.pressed.connect(func():
				if GameData.is_drag_scrolling():
					return
				if GameData.buy_campaign_stone(buy_st_type):
					GameData.add_daily_mission_progress("buy_camp_shop", 1)
					GameData.play_combat_sfx("purchase")
					update_campaign_ui()
					_open_camp_evolution_selector(reopen_idx)
			)
			act_r.add_child(btn_buy_st)
		
		var btn_do_evo = Button.new()
		btn_do_evo.custom_minimum_size = Vector2(104, 28)
		btn_do_evo.add_theme_font_size_override("font_size", 11)
		btn_do_evo.text = "✨ Evolve!"
		btn_do_evo.disabled = not can_evo
		if can_evo:
			_apply_retro_button_style(btn_do_evo, Color(0.20, 0.68, 0.36), Color(0.35, 0.92, 0.55), false)
			var chosen_t_id = to_id
			var chosen_idx = team_idx
			btn_do_evo.pressed.connect(func():
				if GameData.is_drag_scrolling():
					return
				var evo_info = GameData.prepare_campaign_pokemon_evolution_with_option(chosen_idx, chosen_t_id)
				if bool(evo_info.get("success", false)):
					camp_evo_selector_modal.visible = false
					_play_camp_evolution_sequence(evo_info)
			)
		else:
			_apply_retro_button_style(btn_do_evo, Color(0.25, 0.30, 0.35), Color(0.35, 0.40, 0.45), false)
		req_r.add_child(btn_do_evo)
		
		vbox.add_child(b_panel)
		
	var sep_bot = HSeparator.new()
	vbox.add_child(sep_bot)
	
	var btn_back = Button.new()
	btn_back.text = "⬅ Back to Camp"
	btn_back.custom_minimum_size = Vector2(0, 34)
	btn_back.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_back, Color(0.30, 0.40, 0.50), Color(0.42, 0.58, 0.72), false)
	btn_back.pressed.connect(func():
		camp_evo_selector_modal.visible = false
		update_campaign_ui()
	)
	vbox.add_child(btn_back)

func _check_and_run_camp_evolutions() -> void:
	if _is_camp_evo_active:
		return
	if not _camp_evo_queue.is_empty():
		_run_camp_evolution_queue()
	else:
		update_campaign_ui()

func _run_camp_evolution_queue() -> void:
	if _camp_evo_queue.is_empty():
		_is_camp_evo_active = false
		if camp_evo_modal:
			camp_evo_modal.visible = false
		update_campaign_ui()
		return
		
	_is_camp_evo_active = true
	var evo = _camp_evo_queue.pop_front()
	_play_camp_evolution_sequence(evo)

func _play_camp_evolution_sequence(evo: Dictionary) -> void:
	if not camp_evo_modal:
		_setup_camp_evolution_modal()
	camp_evo_modal.visible = true
	
	btn_camp_evo_continue.disabled = true
	btn_camp_evo_continue.visible = false
	
	var from_name = str(evo.get("from_name", "Pokémon"))
	var to_name = str(evo.get("to_name", "Evolution"))
	var from_tex_path = str(evo.get("from_texture", ""))
	var to_tex_path = str(evo.get("to_texture", ""))
	var new_stage = str(evo.get("new_stage", "Stage 1"))
	var new_max_hp = int(evo.get("new_max_hp", 20))
	
	camp_evo_title_lbl.text = "🌟 POKÉMON EVOLUTION! 🌟"
	camp_evo_sub_lbl.text = "What? %s is evolving in the Camp!" % from_name
	camp_evo_sub_lbl.add_theme_color_override("font_color", Color("#B0BEC5"))
	camp_evo_sprite.texture = GameData.get_pokemon_texture(from_tex_path)
	camp_evo_sprite.scale = Vector2.ONE
	camp_evo_sprite.modulate = Color.WHITE
	camp_evo_stats_lbl.text = "Evolving into %s (%s)...\nRestoring full HP (%d HP) & cleansing conditions!" % [to_name, new_stage, new_max_hp]
	
	GameData.play_combat_sfx("use")
	
	if current_camp_evo_tween and current_camp_evo_tween.is_valid():
		current_camp_evo_tween.kill()
		
	var tw = create_tween()
	current_camp_evo_tween = tw
	
	tw.tween_property(camp_evo_sprite, "scale", Vector2(1.15, 1.15), 0.35)
	tw.tween_property(camp_evo_sprite, "scale", Vector2(0.9, 0.9), 0.3)
	tw.parallel().tween_property(camp_evo_sprite, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.3)
	
	tw.tween_callback(func():
		GameData.apply_single_campaign_evolution(evo)
		GameData.add_daily_mission_progress("camp_evolution", 1)
		camp_evo_sprite.texture = GameData.get_pokemon_texture(to_tex_path)
		GameData.play_combat_sfx("heal")
		camp_evo_sub_lbl.text = "🎉 Congratulations! Your %s evolved into %s!" % [from_name, to_name]
		camp_evo_sub_lbl.add_theme_color_override("font_color", Color("#81C784"))
		camp_evo_stats_lbl.text = "✨ Stage: %s\n💚 HP: %d/%d (Fully Restored!)\n⚡ Status conditions cleared!" % [new_stage, new_max_hp, new_max_hp]
	)
	
	tw.tween_property(camp_evo_sprite, "scale", Vector2(1.2, 1.2), 0.25)
	tw.parallel().tween_property(camp_evo_sprite, "modulate", Color.WHITE, 0.25)
	tw.tween_property(camp_evo_sprite, "scale", Vector2.ONE, 0.2)
	
	tw.tween_callback(func():
		btn_camp_evo_continue.visible = true
		btn_camp_evo_continue.disabled = false
		btn_camp_evo_continue.grab_focus()
	)

func _on_camp_evo_continue_pressed() -> void:
	if not _camp_evo_queue.is_empty():
		_run_camp_evolution_queue()
	else:
		_is_camp_evo_active = false
		if camp_evo_modal:
			camp_evo_modal.visible = false
		update_campaign_ui()
		if GameData.tutorial_step == 4:
			GameData.tutorial_step = 5
			GameData.save_profile()
			_show_camp_combat2_prompt()

func _on_reset_campaign_pressed() -> void:
	if GameData.campaign_submode == "ADVENTURE":
		GameData.reset_adventure_episode(GameData.adventure_current_episode)
	else:
		GameData.reset_campaign()
	open_team_select_for_campaign()

func _on_start_campaign_battle_pressed() -> void:
	if GameData.campaign_submode == "ADVENTURE":
		var total_stages = GameData.get_adventure_total_stages(GameData.adventure_current_episode)
		if GameData.adventure_current_stage > total_stages or GameData.adventure_player_team_state.is_empty():
			GameData.reset_adventure_episode(GameData.adventure_current_episode)
			open_team_select_for_campaign()
			return
		GameData.is_campaign_mode = true
		GameData.player_team_ids.clear()
		for p in GameData.adventure_player_team_state:
			GameData.player_team_ids.append(int(p["id"]))
		GameData.enemy_team_ids = GameData.get_adventure_rival_team(GameData.adventure_current_episode, GameData.adventure_current_stage)
	else:
		if GameData.campaign_match_number > GameData.TOURNAMENT_TOTAL_MATCHES:
			GameData.reset_campaign()
			open_team_select_for_campaign()
			return
		GameData.is_campaign_mode = true
		GameData.player_team_ids.clear()
		for p in GameData.campaign_player_team_state:
			GameData.player_team_ids.append(int(p["id"]))
		GameData.enemy_team_ids = GameData.get_campaign_rival_team(GameData.campaign_match_number)
		
	if bgm_player and bgm_player.playing:
		bgm_player.stop()
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

# --- COMBATE LIBRE (1 A 3 POKÉMON) ---
func _setup_team_select_pvp_controls() -> void:
	if qb_mode_row != null:
		return
	var box = team_select_modal.get_node_or_null("Box")
	if not box:
		return
	qb_mode_row = HBoxContainer.new()
	qb_mode_row.name = "QuickBattleModeRow"
	qb_mode_row.custom_minimum_size = Vector2(0, 36)
	qb_mode_row.add_theme_constant_override("separation", 6)
	qb_mode_row.alignment = BoxContainer.ALIGNMENT_CENTER
	
	btn_qb_mode_ai = Button.new()
	btn_qb_mode_ai.text = "🤖 VS AI"
	btn_qb_mode_ai.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_qb_mode_ai.custom_minimum_size = Vector2(0, 34)
	btn_qb_mode_ai.toggle_mode = true
	btn_qb_mode_ai.pressed.connect(func(): _set_quick_battle_mode("AI"))
	
	btn_qb_mode_pvp = Button.new()
	btn_qb_mode_pvp.text = "👥 Pass & Play"
	btn_qb_mode_pvp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_qb_mode_pvp.custom_minimum_size = Vector2(0, 34)
	btn_qb_mode_pvp.toggle_mode = true
	btn_qb_mode_pvp.pressed.connect(func(): _set_quick_battle_mode("PVP"))
	
	qb_mode_row.add_child(btn_qb_mode_ai)
	qb_mode_row.add_child(btn_qb_mode_pvp)
	
	var tab_idx = team_select_tabs.get_index()
	box.add_child(qb_mode_row)
	box.move_child(qb_mode_row, tab_idx)
	_update_qb_mode_buttons_style()

func _set_quick_battle_mode(mode: String) -> void:
	if mode != "PVP":
		mode = "AI"
	qb_selected_mode = mode
	GameData.is_pvp_mode = (mode == "PVP")
	GameData.is_online_pvp = false
	_update_qb_mode_buttons_style()
	update_team_select_ui()

func _update_qb_mode_buttons_style() -> void:
	if not btn_qb_mode_ai or not btn_qb_mode_pvp:
		return
	btn_qb_mode_ai.button_pressed = (qb_selected_mode == "AI")
	btn_qb_mode_pvp.button_pressed = (qb_selected_mode == "PVP")
	
	_style_toggle_btn(btn_qb_mode_ai, qb_selected_mode == "AI", Color("#4CAF50"))
	_style_toggle_btn(btn_qb_mode_pvp, qb_selected_mode == "PVP", Color("#2196F3"))

func _style_toggle_btn(btn: Button, is_active: bool, accent_color: Color) -> void:
	var sb = StyleBoxFlat.new()
	sb.set_corner_radius_all(6)
	if is_active:
		sb.bg_color = accent_color.darkened(0.65)
		sb.border_color = accent_color
		sb.set_border_width_all(2)
		btn.add_theme_color_override("font_color", Color.WHITE)
	else:
		sb.bg_color = Color(0.08, 0.12, 0.18, 0.9)
		sb.border_color = Color(0.25, 0.35, 0.45, 0.7)
		sb.set_border_width_all(1)
		btn.add_theme_color_override("font_color", Color("#90A4AE"))
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)

func _on_quick_battle_pressed() -> void:
	if not GameData.tutorial_completed and GameData.tutorial_step == 1:
		_start_tutorial_flow_or_settings()
		return
	refresh_cards_data_from_catalog()
	team_select_mode = "QUICK_BATTLE"
	GameData.is_online_pvp = false
	if qb_selected_mode != "PVP":
		qb_selected_mode = "AI"
	GameData.is_pvp_mode = (qb_selected_mode == "PVP")
	_setup_team_select_pvp_controls()
	if qb_mode_row:
		qb_mode_row.visible = true
		_update_qb_mode_buttons_style()
	
	team_select_title.text = "⚔️ TEAM SELECTION"
	team_select_tabs.visible = true
	
	# Preseleccionar para la IA si no hay selección o si contiene cartas no desbloqueadas
	var valid_enemy_ids: Array[int] = []
	for id in selected_enemy_ids:
		if GameData.is_pokemon_unlocked(id):
			valid_enemy_ids.append(id)
	selected_enemy_ids = valid_enemy_ids
	if selected_enemy_ids.is_empty():
		_randomize_enemy_team()
		
	current_team_tab = "PLAYER"
	btn_tab_player.button_pressed = true
	btn_tab_enemy.button_pressed = false
	
	update_team_sort_buttons_ui()
	build_team_select_cards_grid()
	update_team_select_ui()
	team_select_modal.visible = true

func _on_close_team_select_pressed() -> void:
	team_select_modal.visible = false
	if team_select_mode == "ONLINE_LOBBY":
		online_lobby_modal.visible = true
	elif team_select_mode == "CAMPAIGN":
		var state = GameData.get_active_campaign_team_state()
		if state.size() > 0:
			update_campaign_ui()
			campaign_modal.visible = true
		elif GameData.campaign_submode == "ADVENTURE":
			update_adventure_episodes_ui()
			adventure_episodes_modal.visible = true
		else:
			update_campaign_hub_ui()
			campaign_hub_modal.visible = true

func _on_clear_team_pressed() -> void:
	if current_team_tab == "ENEMY":
		selected_enemy_ids.clear()
	else:
		selected_player_ids.clear()
	build_team_select_cards_grid()
	update_team_select_ui()

func _on_tab_player_pressed() -> void:
	current_team_tab = "PLAYER"
	btn_tab_player.button_pressed = true
	btn_tab_enemy.button_pressed = false
	update_team_sort_buttons_ui()
	build_team_select_cards_grid()
	update_team_select_ui()

func _on_tab_enemy_pressed() -> void:
	current_team_tab = "ENEMY"
	btn_tab_player.button_pressed = false
	btn_tab_enemy.button_pressed = true
	update_team_sort_buttons_ui()
	build_team_select_cards_grid()
	update_team_select_ui()

func _randomize_enemy_team() -> void:
	selected_enemy_ids.clear()
	var pool: Array = []
	for c in cards_data:
		pool.append(c["id"])
	pool.shuffle()
	var max_pick = min(3, pool.size())
	if max_pick > 0:
		var target_count = randi_range(1, max_pick)
		for i in range(min(target_count, pool.size())):
			selected_enemy_ids.append(pool[i])
	update_team_select_ui()

func build_team_select_cards_grid() -> void:
	if not team_grid_cards:
		return
	for child in team_grid_cards.get_children():
		child.queue_free()
	card_buttons_map.clear()
	team_card_views_map.clear()
	
	var is_player = (team_select_mode == "CAMPAIGN" or current_team_tab == "PLAYER")
	# Tanto jugador como rival/jugador 2 solo usan cartas desbloqueadas en el perfil
	var pool = cards_data
	if team_select_mode == "CAMPAIGN":
		var basic_pool = []
		for c in pool:
			var st = str(c.get("stage", "Basic")).strip_edges().to_lower()
			var r = str(c.get("rarity", "Common")).strip_edges().to_lower()
			var is_legendary = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (st == "legendary")
			if st == "basic" and not is_legendary:
				basic_pool.append(c)
		pool = basic_pool
	current_sorted_team_pool = get_sorted_cards(pool, team_sort_mode)
	
	const CARDS_PER_ROW = 4
	var row_hbox: HBoxContainer = null
	
	for i in range(current_sorted_team_pool.size()):
		if i % CARDS_PER_ROW == 0:
			row_hbox = HBoxContainer.new()
			row_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			row_hbox.add_theme_constant_override("separation", 10)
			row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			team_grid_cards.add_child(row_hbox)
			
		var card = current_sorted_team_pool[i]
		var cid = int(card["id"])
		var p_num = str(card.get("pokedex_num", "1")).pad_zeros(3)
		var type_key = str(card.get("type", "NORMAL")).to_upper()
		var theme = AssembledCardScript.TYPE_THEMES.get(type_key, AssembledCardScript.TYPE_THEMES["NORMAL"])
		
		var cell_vbox = VBoxContainer.new()
		cell_vbox.custom_minimum_size = Vector2(106, 185)
		cell_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		cell_vbox.add_theme_constant_override("separation", 2)
		cell_vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		
		# 1. Miniatura idéntica a Colección con marco temático y sprite
		var thumb_btn = Button.new()
		thumb_btn.custom_minimum_size = Vector2(106, 136)
		thumb_btn.focus_mode = Control.FOCUS_NONE
		thumb_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var tex_file = str(card.get("texture_path", card.get("texture_file", "")))
		var pkmn_tex = GameData.get_pokemon_texture(tex_file)
		thumb_btn.icon = pkmn_tex
		thumb_btn.expand_icon = true
		thumb_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		thumb_btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		
		# Badge flotante para indicar rol en el equipo (✓ 1º LÍDER, etc.)
		var badge_panel = PanelContainer.new()
		badge_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
		badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		badge_panel.visible = false
		
		var badge_lbl = Label.new()
		badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge_lbl.add_theme_font_size_override("font_size", 10)
		badge_panel.add_child(badge_lbl)
		thumb_btn.add_child(badge_panel)
		
		thumb_btn.pressed.connect(func():
			if GameData.is_drag_scrolling():
				return
			toggle_pokemon_selection(cid)
		)
		cell_vbox.add_child(thumb_btn)
		
		# 2. Nombre y Nº Pokédex
		var name_lbl = Label.new()
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 10)
		name_lbl.text = "#%s %s" % [p_num, card.get("short_name", "PKMN")]
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cell_vbox.add_child(name_lbl)
		
		# 3. Estadísticas base (HP / SPD) y Tier
		var stats_lbl = Label.new()
		stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_lbl.add_theme_font_size_override("font_size", 9)
		var t_val = str(card.get("tier", "C")).strip_edges().to_upper()
		if t_val == "": t_val = "C"
		stats_lbl.text = "❤️%d HP  👟%d SPD  ⭐%s" % [int(card.get("hp", 10)), int(card.get("speed", 1)), t_val]
		stats_lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95))
		cell_vbox.add_child(stats_lbl)
		
		# 4. Indicador de Evolución para Torneo según cartas disponibles en tu colección
		if team_select_mode == "CAMPAIGN":
			cell_vbox.custom_minimum_size = Vector2(106, 208)
			var evo_info = GameData.get_pokemon_evolution_chain_status(cid)
			var evo_color = Color(evo_info.get("color_hex", "#78909C"))
			
			# Mini-badge en la esquina inferior de la tarjeta
			var thumb_evo_badge = PanelContainer.new()
			thumb_evo_badge.mouse_filter = Control.MOUSE_FILTER_PASS
			thumb_evo_badge.tooltip_text = evo_info.get("tooltip", "")
			thumb_evo_badge.position = Vector2(76, 110)
			thumb_evo_badge.custom_minimum_size = Vector2(24, 20)
			
			var thumb_sb = StyleBoxFlat.new()
			thumb_sb.set_corner_radius_all(4)
			thumb_sb.bg_color = Color(0, 0, 0, 0.82)
			thumb_sb.border_color = evo_color
			thumb_sb.set_border_width_all(1)
			thumb_evo_badge.add_theme_stylebox_override("panel", thumb_sb)
			
			var thumb_icon_lbl = Label.new()
			thumb_icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			thumb_icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			thumb_icon_lbl.add_theme_font_size_override("font_size", 10)
			thumb_icon_lbl.add_theme_color_override("font_color", evo_color)
			thumb_icon_lbl.text = evo_info.get("icon", "—")
			thumb_evo_badge.add_child(thumb_icon_lbl)
			thumb_btn.add_child(thumb_evo_badge)
			
			# Panel de texto descriptivo bajo las estadísticas
			var evo_panel = PanelContainer.new()
			evo_panel.mouse_filter = Control.MOUSE_FILTER_PASS
			evo_panel.tooltip_text = evo_info.get("tooltip", "")
			
			var evo_sb = StyleBoxFlat.new()
			evo_sb.set_corner_radius_all(3)
			evo_sb.bg_color = evo_color.darkened(0.85)
			evo_sb.border_color = evo_color.darkened(0.4)
			evo_sb.set_border_width_all(1)
			evo_sb.content_margin_top = 1
			evo_sb.content_margin_bottom = 1
			evo_panel.add_theme_stylebox_override("panel", evo_sb)
			
			var evo_lbl = Label.new()
			evo_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			evo_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			evo_lbl.add_theme_font_size_override("font_size", 9)
			evo_lbl.add_theme_color_override("font_color", evo_color)
			evo_lbl.text = evo_info.get("text_badge", "")
			evo_panel.add_child(evo_lbl)
			
			cell_vbox.add_child(evo_panel)
		
		row_hbox.add_child(cell_vbox)
		
		card_buttons_map[cid] = thumb_btn
		team_card_views_map[cid] = {
			"card": card,
			"btn": thumb_btn,
			"theme": theme,
			"badge_panel": badge_panel,
			"badge_lbl": badge_lbl,
			"name_lbl": name_lbl,
			"stats_lbl": stats_lbl
		}

# --- LÓGICA DE SELECCIÓN DE EQUIPO (MÍNIMO 1, MÁXIMO 3 POKÉMON) ---
func toggle_pokemon_selection(pkmn_id: int) -> void:
	if team_select_mode == "CAMPAIGN":
		var cat_entry = GameData.pokemon_catalog.get(pkmn_id)
		if cat_entry:
			var st = str(cat_entry.get("stage", "Basic")).strip_edges().to_lower()
			if st != "basic":
				return
	var is_player = (team_select_mode == "CAMPAIGN" or current_team_tab == "PLAYER")
	var team = selected_player_ids if is_player else selected_enemy_ids
	var idx = team.find(pkmn_id)
	if idx != -1:
		team.remove_at(idx)
	else:
		if team.size() < 3:
			team.append(pkmn_id)
			
	update_team_select_ui()

func get_card_short_name(id: int) -> String:
	if GameData.pokemon_catalog.has(id):
		return GameData.pokemon_catalog[id].get("name", "PKMN")
	return "PKMN"

func update_team_select_ui() -> void:
	var is_player = (team_select_mode == "CAMPAIGN" or current_team_tab == "PLAYER")
	var active_team = selected_player_ids if is_player else selected_enemy_ids
	
	if team_select_mode == "ONLINE_LOBBY":
		if qb_mode_row:
			qb_mode_row.visible = false
		team_select_title.text = "🌐 ONLINE TEAM SELECTION"
		team_select_subtitle.text = "Select 1 to 3 Pokémon from your collection for Online Battle"
		btn_tab_player.text = "🌐 Your Team (%d/3)" % selected_player_ids.size()
		btn_tab_enemy.visible = false
		btn_random_enemy.visible = false
	elif team_select_mode == "CAMPAIGN":
		if qb_mode_row:
			qb_mode_row.visible = false
		if GameData.campaign_submode == "ADVENTURE":
			team_select_title.text = "🗺️ ADVENTURE TEAM"
			var ep_roman = {1: "I", 2: "II", 3: "III", 4: "IV", 5: "V", 6: "VI", 7: "VII"}.get(GameData.adventure_current_episode, str(GameData.adventure_current_episode))
			team_select_subtitle.text = "Choose 1 to 3 BASIC Pokémon for Episode %s (Legendaries banned).\n⏫ icons show evolutions ready in your collection!" % ep_roman
		else:
			team_select_title.text = "🏟️ POKÉMON STADIUM TEAM"
			team_select_subtitle.text = "Choose 1 to 3 BASIC Pokémon for Pokémon Stadium (Legendaries banned).\n⏫ icons show evolutions ready in your collection!"
		btn_tab_player.text = "👤 Your Team (%d/3)" % selected_player_ids.size()
		btn_tab_enemy.text = "🤖 Rival AI (%d/3)" % selected_enemy_ids.size()
	else:
		if qb_mode_row:
			qb_mode_row.visible = true
			_update_qb_mode_buttons_style()
		team_select_title.text = "⚔️ TEAM SELECTION"
		if GameData.is_pvp_mode:
			btn_tab_enemy.visible = true
			btn_random_enemy.visible = true
			team_select_subtitle.text = "👥 Pass & Play: Choose from your unlocked Pokémon for Player 1 and Player 2"
			btn_tab_player.text = "🔴 Player 1 (%d/3)" % selected_player_ids.size()
			btn_tab_enemy.text = "🔵 Player 2 (%d/3)" % selected_enemy_ids.size()
			btn_start_battle.text = "⚔️ START BATTLE"
		else:
			btn_tab_enemy.visible = true
			btn_random_enemy.visible = true
			team_select_subtitle.text = "Configure your team and Rival AI from your unlocked Pokémon (1 to 3 each)"
			btn_tab_player.text = "👤 Your Team (%d/3)" % selected_player_ids.size()
			btn_tab_enemy.text = "🤖 Rival AI (%d/3)" % selected_enemy_ids.size()
			btn_start_battle.text = "⚔️ START BATTLE"
	
	btn_tab_player.modulate = Color(0.4, 1.0, 0.5) if selected_player_ids.size() >= 1 else Color(1.0, 1.0, 1.0)
	btn_tab_enemy.modulate = Color(0.3, 0.8, 1.0) if (GameData.is_pvp_mode and selected_enemy_ids.size() >= 1) else (Color(1.0, 0.65, 0.3) if selected_enemy_ids.size() >= 1 else Color(1.0, 1.0, 1.0))
	
	# Slots
	var slot_color = Color(0.3, 1.0, 0.4) if is_player else (Color(0.3, 0.8, 1.0) if GameData.is_pvp_mode else Color(1.0, 0.6, 0.2))
	var s1_title = "1st LEADER"
	var s2_title = "2nd BENCH"
	var s3_title = "3rd BENCH"
	if team_select_mode != "CAMPAIGN":
		var tag = ("P1" if is_player else "P2") if GameData.is_pvp_mode else ("YOU" if is_player else "AI")
		s1_title = "LEADER (%s)" % tag
		s2_title = "BENCH 1 (%s)" % tag
		s3_title = "BENCH 2 (%s)" % tag
		
	if active_team.size() > 0:
		slot1_lbl.text = "%s:\n%s" % [s1_title, get_card_short_name(active_team[0])]
		slot1_lbl.modulate = slot_color
	else:
		slot1_lbl.text = "%s:\n[Empty]" % s1_title
		slot1_lbl.modulate = Color(0.7, 0.7, 0.7)
		
	if active_team.size() > 1:
		slot2_lbl.text = "%s:\n%s" % [s2_title, get_card_short_name(active_team[1])]
		slot2_lbl.modulate = slot_color
	else:
		slot2_lbl.text = "%s:\n[Empty]" % s2_title
		slot2_lbl.modulate = Color(0.7, 0.7, 0.7)
		
	if active_team.size() > 2:
		slot3_lbl.text = "%s:\n%s" % [s3_title, get_card_short_name(active_team[2])]
		slot3_lbl.modulate = slot_color
	else:
		slot3_lbl.text = "%s:\n[Empty]" % s3_title
		slot3_lbl.modulate = Color(0.7, 0.7, 0.7)
		
	# Actualizar tarjetas de la cuadrícula
	for cid in team_card_views_map.keys():
		var view = team_card_views_map[cid]
		var btn: Button = view["btn"]
		var theme = view["theme"]
		var badge_panel: PanelContainer = view["badge_panel"]
		var badge_lbl: Label = view["badge_lbl"]
		var name_lbl: Label = view["name_lbl"]
		
		var idx = active_team.find(cid)
		if idx != -1:
			var role_name = "1st LEADER" if idx == 0 else ("%d%s BENCH" % [idx + 1, "nd" if idx == 1 else "rd"])
			badge_panel.visible = true
			badge_lbl.text = "✓ %s" % role_name
			
			var badge_sb = StyleBoxFlat.new()
			badge_sb.set_corner_radius_all(4)
			if is_player:
				badge_sb.bg_color = Color(0.12, 0.65, 0.32, 0.95)
			elif GameData.is_pvp_mode:
				badge_sb.bg_color = Color(0.12, 0.45, 0.85, 0.95)
			else:
				badge_sb.bg_color = Color(0.85, 0.45, 0.1, 0.95)
			badge_panel.add_theme_stylebox_override("panel", badge_sb)
			
			# Resaltado del botón con borde brillante
			var sb_selected = StyleBoxFlat.new()
			sb_selected.bg_color = theme["bg"]
			var border_c = Color(0.2, 1.0, 0.4) if is_player else (Color(0.3, 0.8, 1.0) if GameData.is_pvp_mode else Color(1.0, 0.7, 0.2))
			sb_selected.border_color = border_c
			sb_selected.set_border_width_all(4)
			sb_selected.set_corner_radius_all(6)
			btn.add_theme_stylebox_override("normal", sb_selected)
			btn.add_theme_stylebox_override("hover", sb_selected)
			btn.add_theme_stylebox_override("pressed", sb_selected)
			
			name_lbl.add_theme_color_override("font_color", border_c)
		else:
			badge_panel.visible = false
			
			var sb_normal = StyleBoxFlat.new()
			sb_normal.bg_color = theme["bg"]
			sb_normal.border_color = theme["border"]
			sb_normal.set_border_width_all(2)
			sb_normal.set_corner_radius_all(6)
			
			var sb_hover = StyleBoxFlat.new()
			sb_hover.bg_color = theme["bg"].lightened(0.18)
			sb_hover.border_color = theme["border"].lightened(0.25)
			sb_hover.set_border_width_all(3)
			sb_hover.set_corner_radius_all(6)
			
			btn.add_theme_stylebox_override("normal", sb_normal)
			btn.add_theme_stylebox_override("hover", sb_hover)
			btn.add_theme_stylebox_override("pressed", sb_hover)
			
			name_lbl.add_theme_color_override("font_color", Color("#e2e8f0"))
			
	if team_select_mode == "ONLINE_LOBBY":
		var p_count = selected_player_ids.size()
		var ready = (p_count >= 1 and p_count <= 3)
		btn_start_battle.disabled = not ready
		if ready:
			btn_start_battle.text = "✅ CONFIRM TEAM IN LOBBY (%d PKMN)" % p_count
		else:
			btn_start_battle.text = "Choose 1 to 3 Basic Pokémon"
	elif team_select_mode == "CAMPAIGN":
		var p_count = selected_player_ids.size()
		btn_start_battle.disabled = (p_count < 1)
		var mode_label = "ADVENTURE" if GameData.campaign_submode == "ADVENTURE" else "TOURNAMENT"
		if p_count >= 1:
			btn_start_battle.text = "✅ CONFIRM %s TEAM (%d PKMN)" % [mode_label, p_count]
		else:
			btn_start_battle.text = "Choose 1 to 3 BASIC Pokémon for %s" % mode_label.capitalize()
	else:
		var p_count = selected_player_ids.size()
		var e_count = selected_enemy_ids.size()
		var ready = (p_count >= 1 and p_count <= 3 and e_count >= 1 and e_count <= 3)
		btn_start_battle.disabled = not ready
		if ready:
			if GameData.is_pvp_mode:
				btn_start_battle.text = "⚔️ START 2-PLAYER BATTLE (%d vs %d)!" % [p_count, e_count]
			else:
				btn_start_battle.text = "⚔️ START BATTLE vs AI (%d vs %d)!" % [p_count, e_count]
		elif p_count < 1:
			btn_start_battle.text = "Choose at least 1 for %s" % ("Player 1" if GameData.is_pvp_mode else "Your Team")
		else:
			btn_start_battle.text = "Choose at least 1 for %s" % ("Player 2" if GameData.is_pvp_mode else "Rival AI")

func _on_start_battle_pressed() -> void:
	if team_select_mode == "ONLINE_LOBBY":
		if selected_player_ids.size() < 1:
			return
		team_select_modal.visible = false
		online_lobby_modal.visible = true
		_update_lobby_teams_ui()
		OnlineManager.update_my_team(selected_player_ids)
		if not OnlineManager.is_host and OnlineManager.is_guest_ready:
			OnlineManager.set_guest_ready(false)
			if btn_guest_ready_toggle:
				btn_guest_ready_toggle.text = "✅ READY FOR BATTLE"
				_apply_retro_button_style(btn_guest_ready_toggle, Color(0.2, 0.7, 0.3), Color(0.3, 0.9, 0.4))
		return
		
	if team_select_mode == "CAMPAIGN":
		if selected_player_ids.is_empty():
			return
		if GameData.campaign_submode == "ADVENTURE":
			GameData.change_adventure_team(selected_player_ids)
		else:
			GameData.change_campaign_team(selected_player_ids)
		team_select_modal.visible = false
		update_campaign_ui()
		campaign_modal.visible = true
		return
		
	if selected_player_ids.size() < 1:
		return
		
	if selected_enemy_ids.size() < 1:
		return
		
	GameData.is_campaign_mode = false
	GameData.player_team_ids = selected_player_ids.duplicate()
	GameData.enemy_team_ids = selected_enemy_ids.duplicate()
	if bgm_player and bgm_player.playing:
		bgm_player.stop()
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

# --- SALA DE COMBATE EN LÍNEA (ONLINE LOBBY) ---
var _is_online_match_launching: bool = false

func _open_online_lobby() -> void:
	if not GameData.tutorial_completed and GameData.tutorial_step == 1:
		_start_tutorial_flow_or_settings()
		return
	_is_online_match_launching = false
	_ensure_default_online_team()
	online_lobby_modal.visible = true
	_show_online_host_tab()

func _ensure_default_online_team() -> void:
	if selected_player_ids.is_empty():
		for id in GameData.player_unlocked_ids:
			if selected_player_ids.size() < 3:
				selected_player_ids.append(id)
	if selected_player_ids.is_empty():
		selected_player_ids = [0]

func _render_pokemon_team_badges(container: HBoxContainer, team_ids: Array) -> void:
	if not container:
		return
	for c in container.get_children():
		c.queue_free()
		
	if team_ids.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "⏳ (Waiting for selection...)"
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
		container.add_child(empty_lbl)
		return
		
	for pid in team_ids:
		var cat_entry = GameData.pokemon_catalog.get(int(pid), {})
		var pkmn_name = str(cat_entry.get("name", "PKMN"))
		var type_key = str(cat_entry.get("type", "NORMAL")).to_upper()
		var theme = AssembledCardScript.TYPE_THEMES.get(type_key, AssembledCardScript.TYPE_THEMES["NORMAL"])
		var border_col = theme.get("border", Color("#81D4FA"))
		
		var badge_panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.12, 0.18, 0.95)
		sb.border_color = border_col
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(6)
		badge_panel.add_theme_stylebox_override("panel", sb)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 6)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_top", 4)
		margin.add_theme_constant_override("margin_bottom", 4)
		badge_panel.add_child(margin)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 6)
		margin.add_child(hbox)
		
		var tex_file = str(cat_entry.get("texture_path", cat_entry.get("texture_file", "")))
		var pkmn_tex = GameData.get_pokemon_texture(tex_file)
		if pkmn_tex:
			var trect = TextureRect.new()
			trect.texture = pkmn_tex
			trect.custom_minimum_size = Vector2(26, 26)
			trect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			trect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			hbox.add_child(trect)
			
		var n_lbl = Label.new()
		n_lbl.text = pkmn_name
		n_lbl.add_theme_font_size_override("font_size", 11)
		n_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		hbox.add_child(n_lbl)
		
		container.add_child(badge_panel)

func _update_lobby_teams_ui() -> void:
	if host_team_container:
		_render_pokemon_team_badges(host_team_container, selected_player_ids)
	if guest_team_container:
		_render_pokemon_team_badges(guest_team_container, selected_player_ids)
	if host_rival_team_container:
		_render_pokemon_team_badges(host_rival_team_container, OnlineManager.opponent_team_ids)
	if guest_rival_team_container:
		_render_pokemon_team_badges(guest_rival_team_container, OnlineManager.opponent_team_ids)

func _show_online_host_tab() -> void:
	_ensure_default_online_team()
	_is_online_match_launching = false
	btn_tab_create_room.button_pressed = true
	btn_tab_join_room.button_pressed = false
	_style_toggle_btn(btn_tab_create_room, true, Color("#4CAF50"))
	_style_toggle_btn(btn_tab_join_room, false, Color("#2196F3"))
	host_panel.visible = true
	join_panel.visible = false
	
	if host_rival_info_lbl:
		host_rival_info_lbl.text = "👤 Rival: Waiting for opponent..."
	if host_rival_ready_badge:
		host_rival_ready_badge.text = "🔴 Rival: Not connected"
		host_rival_ready_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	if btn_host_start_battle:
		btn_host_start_battle.disabled = true
		btn_host_start_battle.text = "⚔️ Waiting for rival to be READY..."
		_apply_retro_button_style(btn_host_start_battle, Color(0.3, 0.4, 0.5), Color(0.3, 0.4, 0.5))
		
	_update_lobby_teams_ui()
	
	# If already hosting with valid room code, reuse it
	if OnlineManager.is_host and not OnlineManager.room_code.is_empty():
		room_code_lbl.text = OnlineManager.room_code
		host_status_lbl.text = "⏳ Share room code %s with your rival to battle." % OnlineManager.room_code
		return
		
	room_code_lbl.text = "----"
	host_status_lbl.text = "⏳ Creating room in Google Cloud..."
	
	OnlineManager.create_room(GameData.profile_name, selected_player_ids, func(success: bool, code: String):
		if success:
			room_code_lbl.text = code
			host_status_lbl.text = "⏳ Share room code %s with your rival to battle." % code
		else:
			room_code_lbl.text = "ERR"
			host_status_lbl.text = "❌ Error creating room. Please try again."
	)

func _show_online_join_tab() -> void:
	_ensure_default_online_team()
	_is_online_match_launching = false
	btn_tab_create_room.button_pressed = false
	btn_tab_join_room.button_pressed = true
	_style_toggle_btn(btn_tab_create_room, false, Color("#4CAF50"))
	_style_toggle_btn(btn_tab_join_room, true, Color("#2196F3"))
	host_panel.visible = false
	join_panel.visible = true
	
	if join_input_section:
		join_input_section.visible = true
	if guest_lobby_section:
		guest_lobby_section.visible = false
		
	join_code_input.text = ""
	join_status_lbl.text = ""
	OnlineManager.leave_or_delete_room()

func _on_confirm_join_pressed() -> void:
	_ensure_default_online_team()
	_is_online_match_launching = false
	var raw_code = join_code_input.text.strip_edges().to_upper()
	var regex = RegEx.new()
	if regex.compile("[^A-Z0-9]") == OK:
		raw_code = regex.sub(raw_code, "", true)
	if raw_code.length() != 4:
		join_status_lbl.text = "⚠️ Please enter the 4-character room code."
		join_status_lbl.add_theme_color_override("font_color", Color("#FF5252"))
		return
	join_status_lbl.text = "🔄 Connecting to room %s..." % raw_code
	join_status_lbl.add_theme_color_override("font_color", Color("#81D4FA"))
	btn_confirm_join.disabled = true
	
	OnlineManager.join_room(raw_code, GameData.profile_name, selected_player_ids, func(success: bool, msg: String):
		btn_confirm_join.disabled = false
		if success:
			if join_input_section:
				join_input_section.visible = false
			if guest_lobby_section:
				guest_lobby_section.visible = true
			if guest_room_info_lbl:
				guest_room_info_lbl.text = "🏠 Connected to room %s" % raw_code
			if guest_rival_info_lbl:
				var h_name = OnlineManager.opponent_name if not OnlineManager.opponent_name.is_empty() else "Host"
				guest_rival_info_lbl.text = "👤 Host Rival: %s" % h_name
			if guest_rival_team_container:
				_render_pokemon_team_badges(guest_rival_team_container, OnlineManager.opponent_team_ids)
			if btn_guest_ready_toggle:
				btn_guest_ready_toggle.text = "✅ READY FOR BATTLE"
				_apply_retro_button_style(btn_guest_ready_toggle, Color(0.2, 0.7, 0.3), Color(0.3, 0.9, 0.4))
			join_status_lbl.text = "💡 Edit your team if desired, then click READY FOR BATTLE."
			join_status_lbl.add_theme_color_override("font_color", Color("#69F0AE"))
			_update_lobby_teams_ui()
		else:
			join_status_lbl.text = "❌ %s" % msg
			join_status_lbl.add_theme_color_override("font_color", Color("#FF5252"))
	)

func _on_guest_ready_toggle_pressed() -> void:
	var new_ready = not OnlineManager.is_guest_ready
	btn_guest_ready_toggle.disabled = true
	OnlineManager.set_guest_ready(new_ready, func(_success: bool):
		btn_guest_ready_toggle.disabled = false
		if new_ready:
			btn_guest_ready_toggle.text = "↩️ Cancel Ready (Edit Team)"
			_apply_retro_button_style(btn_guest_ready_toggle, Color(0.85, 0.5, 0.15), Color(1.0, 0.65, 0.2))
			join_status_lbl.text = "🟢 You are Ready! Waiting for host to start battle..."
			join_status_lbl.add_theme_color_override("font_color", Color("#69F0AE"))
		else:
			btn_guest_ready_toggle.text = "✅ READY FOR BATTLE"
			_apply_retro_button_style(btn_guest_ready_toggle, Color(0.2, 0.7, 0.3), Color(0.3, 0.9, 0.4))
			join_status_lbl.text = "🟡 Not ready. Edit your team or click READY FOR BATTLE."
			join_status_lbl.add_theme_color_override("font_color", Color("#FFD54F"))
	)

func _on_lobby_change_team_pressed() -> void:
	team_select_mode = "ONLINE_LOBBY"
	_open_team_select_for_online()

func _open_team_select_for_online() -> void:
	qb_selected_mode = "ONLINE"
	team_select_title.text = "🌐 MODIFY BATTLE TEAM"
	team_select_subtitle.text = "Select 1 to 3 Basic Pokémon for multiplayer battles"
	btn_tab_player.text = "🌐 Your Team (%d/3)" % selected_player_ids.size()
	btn_tab_enemy.visible = false
	btn_random_enemy.visible = false
	if qb_mode_row:
		qb_mode_row.visible = false
	current_team_tab = "PLAYER"
	build_team_select_cards_grid()
	update_team_select_ui()
	online_lobby_modal.visible = false
	team_select_modal.visible = true

func _on_online_guest_connected(guest_name: String, guest_team: Array) -> void:
	if host_rival_info_lbl:
		host_rival_info_lbl.text = "👤 Connected Rival: %s" % guest_name
	if host_rival_team_container:
		_render_pokemon_team_badges(host_rival_team_container, guest_team)
	host_status_lbl.text = "👥 %s has connected. Waiting for rival to be ready..." % guest_name
	host_status_lbl.add_theme_color_override("font_color", Color("#81D4FA"))

func _on_online_guest_ready_changed(is_ready: bool) -> void:
	if is_ready:
		if host_rival_ready_badge:
			host_rival_ready_badge.text = "🟢 Rival: READY FOR BATTLE!"
			host_rival_ready_badge.add_theme_color_override("font_color", Color(0.3, 1.0, 0.45))
		if btn_host_start_battle:
			btn_host_start_battle.disabled = false
			var rival_str = OnlineManager.opponent_name if not OnlineManager.opponent_name.is_empty() else "Rival"
			btn_host_start_battle.text = "⚔️ START BATTLE VS %s!" % rival_str.to_upper()
			_apply_retro_button_style(btn_host_start_battle, Color(0.15, 0.75, 0.3), Color(0.25, 0.95, 0.4))
		host_status_lbl.text = "✨ Both trainers are ready! Click Start Battle."
		host_status_lbl.add_theme_color_override("font_color", Color("#69F0AE"))
	else:
		if host_rival_ready_badge:
			host_rival_ready_badge.text = "🔴 Rival: Preparing team (NOT READY)"
			host_rival_ready_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
		if btn_host_start_battle:
			btn_host_start_battle.disabled = true
			btn_host_start_battle.text = "⚔️ Waiting for rival to be READY..."
			_apply_retro_button_style(btn_host_start_battle, Color(0.3, 0.4, 0.5), Color(0.3, 0.4, 0.5))
		host_status_lbl.text = "⏳ Rival is modifying or preparing their team..."
		host_status_lbl.add_theme_color_override("font_color", Color("#FFD54F"))

func _on_online_opponent_team_updated(new_team: Array) -> void:
	if host_rival_team_container:
		_render_pokemon_team_badges(host_rival_team_container, new_team)
	if guest_rival_team_container:
		_render_pokemon_team_badges(guest_rival_team_container, new_team)
	if guest_rival_info_lbl and not OnlineManager.opponent_name.is_empty():
		guest_rival_info_lbl.text = "👤 Host Rival: %s" % OnlineManager.opponent_name

func _on_host_start_battle_pressed() -> void:
	btn_host_start_battle.disabled = true
	btn_host_start_battle.text = "🚀 Loading Stadium..."
	OnlineManager.start_online_match()

func _on_close_online_lobby_pressed() -> void:
	OnlineManager.leave_or_delete_room()
	online_lobby_modal.visible = false

func _on_online_match_ready() -> void:
	print("[Main] 🚀 _on_online_match_ready invoked! Role=%s, is_host=%s, _is_online_match_launching=%s" % [OnlineManager.my_role, str(OnlineManager.is_host), str(_is_online_match_launching)])
	if _is_online_match_launching:
		return
	_is_online_match_launching = true
	OnlineManager.stop_polling()
	
	var r_name = OnlineManager.opponent_name if not OnlineManager.opponent_name.is_empty() else "Rival"
	host_status_lbl.text = "🚀 Starting battle! Trainer: %s" % r_name
	join_status_lbl.text = "🚀 Starting battle! Trainer: %s" % r_name
	
	GameData.is_campaign_mode = false
	GameData.is_pvp_mode = false
	GameData.is_online_pvp = true
	GameData.online_rival_name = r_name
	
	_ensure_default_online_team()
	var safe_enemy_ids: Array[int] = []
	for eid in OnlineManager.opponent_team_ids:
		safe_enemy_ids.append(int(eid))
	if safe_enemy_ids.is_empty():
		safe_enemy_ids.append(4)
	GameData.enemy_team_ids = safe_enemy_ids

	var safe_player_ids: Array[int] = []
	for pid in selected_player_ids:
		safe_player_ids.append(int(pid))
	if safe_player_ids.is_empty():
		safe_player_ids.append(0)
	GameData.player_team_ids = safe_player_ids
	
	online_lobby_modal.visible = false
	team_select_modal.visible = false
	if bgm_player and bgm_player.playing:
		bgm_player.stop()
		
	var err = get_tree().change_scene_to_file("res://scenes/battle.tscn")
	if err != OK:
		print("[Main] Error cambiando escena a battle.tscn: ", err)
		_is_online_match_launching = false

func _on_collection_pressed() -> void:
	if not GameData.tutorial_completed and GameData.tutorial_step == 1:
		_start_tutorial_flow_or_settings()
		return
	refresh_cards_data_from_catalog()
	update_collection_sort_buttons_ui()
	populate_collection_grid()
	collection_grid_view.visible = true
	collection_detail_view.visible = false
	collection_modal.visible = true

# --- RETRO POKÉMON GBA THEME SYSTEM ---
func _apply_pokemon_ui_theme() -> void:
	var tex_pokeball = preload("res://assets/ui/menu_pokeball.png")
	var tex_pokeball_active = preload("res://assets/ui/menu_pokeball_active.png")
	
	# Apply pokeball bullet icons and styling to Lobby & Login buttons
	var lobby_btns = [
		btn_campaign,
		btn_quick_battle,
		btn_online_multiplayer,
		btn_collection,
		btn_shop,
		btn_daily_missions,
		btn_profile,
		btn_settings,
		btn_exit,
		btn_login_play,
		btn_login_cloud,
		btn_sign_up_google
	]
	for btn in lobby_btns:
		if not btn:
			continue
		btn.icon = tex_pokeball
		btn.expand_icon = false
		btn.mouse_entered.connect(func():
			if btn and btn.icon:
				btn.icon = tex_pokeball_active
				btn.pivot_offset = Vector2(24, btn.size.y / 2.0 if btn.size.y > 0 else 24.0)
				var tw = btn.create_tween()
				tw.tween_property(btn, "scale", Vector2(1.025, 1.025), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		)
		btn.mouse_exited.connect(func():
			if btn and btn.icon:
				btn.icon = tex_pokeball
				btn.pivot_offset = Vector2(24, btn.size.y / 2.0 if btn.size.y > 0 else 24.0)
				var tw = btn.create_tween()
				tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		)
		
		var normal_sb = StyleBoxFlat.new()
		normal_sb.bg_color = Color(0.09, 0.14, 0.20, 0.95)
		normal_sb.border_color = Color(0.25, 0.52, 0.60)
		normal_sb.set_border_width_all(2)
		normal_sb.set_corner_radius_all(6)
		normal_sb.content_margin_left = 14
		normal_sb.content_margin_right = 14
		
		var hover_sb = StyleBoxFlat.new()
		hover_sb.bg_color = Color(0.13, 0.22, 0.32, 1.0)
		hover_sb.border_color = Color(0.40, 0.85, 0.95)
		hover_sb.set_border_width_all(2)
		hover_sb.set_corner_radius_all(6)
		hover_sb.content_margin_left = 14
		hover_sb.content_margin_right = 14
		
		btn.add_theme_stylebox_override("normal", normal_sb)
		btn.add_theme_stylebox_override("hover", hover_sb)
		btn.add_theme_stylebox_override("pressed", hover_sb)

	# Trainer Status Badge with GBA border
	var badge_sb = StyleBoxFlat.new()
	badge_sb.bg_color = Color(0.07, 0.12, 0.18, 0.92)
	badge_sb.border_color = Color(0.28, 0.60, 0.70, 0.85)
	badge_sb.set_border_width_all(1)
	badge_sb.set_corner_radius_all(6)
	badge_sb.content_margin_left = 12
	badge_sb.content_margin_right = 12
	badge_sb.content_margin_top = 4
	badge_sb.content_margin_bottom = 4
	if trainer_status_badge:
		trainer_status_badge.add_theme_stylebox_override("normal", badge_sb)
	if profile_detected_lbl:
		profile_detected_lbl.add_theme_stylebox_override("normal", badge_sb.duplicate())

	# Subtle scanline tile on main background and login background
	var scan_tex = preload("res://assets/ui/scanline_tile.png")
	var bg_node = get_node_or_null("Background")
	if bg_node and not bg_node.get_node_or_null("Scanlines"):
		var scan_rect = TextureRect.new()
		scan_rect.name = "Scanlines"
		scan_rect.texture = scan_tex
		scan_rect.stretch_mode = TextureRect.STRETCH_TILE
		scan_rect.anchors_preset = Control.PRESET_FULL_RECT
		scan_rect.anchor_right = 1.0
		scan_rect.anchor_bottom = 1.0
		scan_rect.modulate = Color(1, 1, 1, 0.12)
		scan_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg_node.add_child(scan_rect)
		
	var login_bg_node = get_node_or_null("LoginModal/LoginBg")
	if login_bg_node and not login_bg_node.get_node_or_null("Scanlines"):
		var scan_rect_login = TextureRect.new()
		scan_rect_login.name = "Scanlines"
		scan_rect_login.texture = scan_tex
		scan_rect_login.stretch_mode = TextureRect.STRETCH_TILE
		scan_rect_login.anchors_preset = Control.PRESET_FULL_RECT
		scan_rect_login.anchor_right = 1.0
		scan_rect_login.anchor_bottom = 1.0
		scan_rect_login.modulate = Color(1, 1, 1, 0.12)
		scan_rect_login.mouse_filter = Control.MOUSE_FILTER_IGNORE
		login_bg_node.add_child(scan_rect_login)
		
	# Apply teal 9-slice panel stylebox to modal cards
	var teal_sb = _create_pokemon_panel_stylebox()
	
	# Profile modal cards
	var profile_info_card = get_node_or_null("ProfileModal/ProfileBox/TrainerInfoCard")
	if profile_info_card is PanelContainer:
		profile_info_card.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var profile_stats_card = get_node_or_null("ProfileModal/ProfileBox/StatsCard")
	if profile_stats_card is PanelContainer:
		profile_stats_card.add_theme_stylebox_override("panel", teal_sb.duplicate())
		
	# Settings modal cards
	var audio_panel = get_node_or_null("SettingsModal/SettingsBox/AudioPanel")
	if audio_panel is PanelContainer:
		audio_panel.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var info_panel = get_node_or_null("SettingsModal/SettingsBox/InfoPanel")
	if info_panel is PanelContainer:
		info_panel.add_theme_stylebox_override("panel", teal_sb.duplicate())
		
	# Other modal cards
	if welcome_card:
		welcome_card.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var cloud_card = get_node_or_null("CloudNoticeModal/CloudCard")
	if cloud_card is PanelContainer:
		cloud_card.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var erase_card = get_node_or_null("EraseConfirmModal/EraseCard")
	if erase_card is PanelContainer:
		erase_card.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var update_card = get_node_or_null("UpdateModal/UpdateCard")
	if update_card is PanelContainer:
		update_card.add_theme_stylebox_override("panel", teal_sb.duplicate())
		
	# Shop PackPanel
	var pack_panel = get_node_or_null("ShopModal/Box/PackPanel")
	if pack_panel is PanelContainer:
		pack_panel.add_theme_stylebox_override("panel", teal_sb.duplicate())

	# Online Lobby Card
	if online_card is PanelContainer:
		online_card.add_theme_stylebox_override("panel", teal_sb.duplicate())
	if room_code_box is PanelContainer:
		var r_sb = StyleBoxFlat.new()
		r_sb.bg_color = Color(0.04, 0.08, 0.12, 0.95)
		r_sb.border_color = Color(1.0, 0.85, 0.2, 0.85)
		r_sb.set_border_width_all(2)
		r_sb.set_corner_radius_all(8)
		room_code_box.add_theme_stylebox_override("panel", r_sb)
		
	# Daily Modal Panels
	var daily_cal_panel = get_node_or_null("DailyModal/DailyBox/DailyCalendarPanel")
	if daily_cal_panel is PanelContainer:
		daily_cal_panel.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var daily_mis_panel = get_node_or_null("DailyModal/DailyBox/DailyMissionsPanel")
	if daily_mis_panel is PanelContainer:
		daily_mis_panel.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var daily_chest_panel = get_node_or_null("DailyModal/DailyBox/ChestPanel")
	if daily_chest_panel is PanelContainer:
		daily_chest_panel.add_theme_stylebox_override("panel", teal_sb.duplicate())
		
	var online_bg_node = get_node_or_null("OnlineLobbyModal/OnlineBg")
	if online_bg_node and not online_bg_node.get_node_or_null("Scanlines"):
		var scan_rect_online = TextureRect.new()
		scan_rect_online.name = "Scanlines"
		scan_rect_online.texture = scan_tex
		scan_rect_online.stretch_mode = TextureRect.STRETCH_TILE
		scan_rect_online.anchors_preset = Control.PRESET_FULL_RECT
		scan_rect_online.anchor_right = 1.0
		scan_rect_online.anchor_bottom = 1.0
		scan_rect_online.modulate = Color(1, 1, 1, 0.12)
		scan_rect_online.mouse_filter = Control.MOUSE_FILTER_IGNORE
		online_bg_node.add_child(scan_rect_online)

	# Subtle scanline tile on Campaign Hub & Campaign Camp backgrounds
	var hub_bg_node = get_node_or_null("CampaignHubModal/CampaignHubBg")
	if hub_bg_node and not hub_bg_node.get_node_or_null("Scanlines"):
		var scan_rect_hub = TextureRect.new()
		scan_rect_hub.name = "Scanlines"
		scan_rect_hub.texture = scan_tex
		scan_rect_hub.stretch_mode = TextureRect.STRETCH_TILE
		scan_rect_hub.anchors_preset = Control.PRESET_FULL_RECT
		scan_rect_hub.anchor_right = 1.0
		scan_rect_hub.anchor_bottom = 1.0
		scan_rect_hub.modulate = Color(1, 1, 1, 0.12)
		scan_rect_hub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hub_bg_node.add_child(scan_rect_hub)

	var camp_bg_node = get_node_or_null("CampaignModal/CampaignBg")
	if camp_bg_node and not camp_bg_node.get_node_or_null("Scanlines"):
		var scan_rect_camp = TextureRect.new()
		scan_rect_camp.name = "Scanlines"
		scan_rect_camp.texture = scan_tex
		scan_rect_camp.stretch_mode = TextureRect.STRETCH_TILE
		scan_rect_camp.anchors_preset = Control.PRESET_FULL_RECT
		scan_rect_camp.anchor_right = 1.0
		scan_rect_camp.anchor_bottom = 1.0
		scan_rect_camp.modulate = Color(1, 1, 1, 0.12)
		scan_rect_camp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		camp_bg_node.add_child(scan_rect_camp)

	var adv_ep_bg_node = get_node_or_null("AdventureEpisodesModal/AdventureEpisodesBg")
	if adv_ep_bg_node and not adv_ep_bg_node.get_node_or_null("Scanlines"):
		var scan_rect_adv_ep = TextureRect.new()
		scan_rect_adv_ep.name = "Scanlines"
		scan_rect_adv_ep.texture = scan_tex
		scan_rect_adv_ep.stretch_mode = TextureRect.STRETCH_TILE
		scan_rect_adv_ep.anchors_preset = Control.PRESET_FULL_RECT
		scan_rect_adv_ep.anchor_right = 1.0
		scan_rect_adv_ep.anchor_bottom = 1.0
		scan_rect_adv_ep.modulate = Color(1, 1, 1, 0.12)
		scan_rect_adv_ep.mouse_filter = Control.MOUSE_FILTER_IGNORE
		adv_ep_bg_node.add_child(scan_rect_adv_ep)

	var stadium_guide_bg_node = get_node_or_null("StadiumGuideModal/StadiumGuideBg")
	if stadium_guide_bg_node and not stadium_guide_bg_node.get_node_or_null("Scanlines"):
		var scan_rect_stadium = TextureRect.new()
		scan_rect_stadium.name = "Scanlines"
		scan_rect_stadium.texture = scan_tex
		scan_rect_stadium.stretch_mode = TextureRect.STRETCH_TILE
		scan_rect_stadium.anchors_preset = Control.PRESET_FULL_RECT
		scan_rect_stadium.anchor_right = 1.0
		scan_rect_stadium.anchor_bottom = 1.0
		scan_rect_stadium.modulate = Color(1, 1, 1, 0.12)
		scan_rect_stadium.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stadium_guide_bg_node.add_child(scan_rect_stadium)

	# Badges for Campaign
	var hub_badge_node = get_node_or_null("CampaignHubModal/Box/HubWalletBadge")
	if hub_badge_node is Label:
		hub_badge_node.add_theme_stylebox_override("normal", badge_sb.duplicate())

	var ep_badge_node = get_node_or_null("AdventureEpisodesModal/Box/EpisodesWalletBadge")
	if ep_badge_node is Label:
		ep_badge_node.add_theme_stylebox_override("normal", badge_sb.duplicate())

	var camp_status_card = get_node_or_null("CampaignModal/Box/StatusCard")
	if camp_status_card is PanelContainer:
		camp_status_card.add_theme_stylebox_override("panel", badge_sb.duplicate())

	# Mode Cards in Campaign Hub & Adventure Episodes
	var card_adv = get_node_or_null("CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventure")
	if card_adv is PanelContainer:
		card_adv.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_tourn = get_node_or_null("CampaignHubModal/Box/ModesScroll/ModesVBox/CardTournament")
	if card_tourn is PanelContainer:
		card_tourn.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_ep1 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp1")
	if card_ep1 is PanelContainer:
		card_ep1.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_ep2 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp2")
	if card_ep2 is PanelContainer:
		card_ep2.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_ep3 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp3")
	if card_ep3 is PanelContainer:
		card_ep3.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_ep4 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp4")
	if card_ep4 is PanelContainer:
		card_ep4.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_ep5 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp5")
	if card_ep5 is PanelContainer:
		card_ep5.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_ep6 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp6")
	if card_ep6 is PanelContainer:
		card_ep6.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_ep7 = get_node_or_null("AdventureEpisodesModal/Box/EpisodesScroll/EpisodesVBox/CardAdventureEp7")
	if card_ep7 is PanelContainer:
		card_ep7.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_loot = get_node_or_null("CampaignHubModal/Box/ModesScroll/ModesVBox/CardLootRates")
	if card_loot is PanelContainer:
		card_loot.add_theme_stylebox_override("panel", teal_sb.duplicate())

	# Camp Supply Shop Panel
	var camp_shop_panel = find_child("ShopSection", true, false)
	if camp_shop_panel is PanelContainer:
		camp_shop_panel.add_theme_stylebox_override("panel", teal_sb.duplicate())

	# Retro stylebox overrides for Campaign Hub & Camp buttons
	_apply_retro_button_style(btn_hub_tutorial, Color(0.20, 0.65, 0.35), Color(0.35, 0.85, 0.50), true)
	_apply_retro_button_style(btn_hub_adventure, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	_apply_retro_button_style(btn_hub_tournament, Color(0.22, 0.63, 0.41), Color(0.40, 0.85, 0.60), true)
	_apply_retro_button_style(btn_stadium_guide, Color(0.25, 0.60, 0.85), Color(0.40, 0.85, 1.00), true)
	_apply_retro_button_style(btn_close_campaign_hub, Color(0.25, 0.52, 0.60), Color(0.40, 0.85, 0.95), false)

	_apply_retro_button_style(btn_hub_adventure_ep1, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	_apply_retro_button_style(btn_hub_adventure_ep2, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	_apply_retro_button_style(btn_hub_adventure_ep3, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	_apply_retro_button_style(btn_hub_adventure_ep4, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
	_apply_retro_button_style(btn_hub_adventure_ep5, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
	_apply_retro_button_style(btn_hub_adventure_ep6, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
	_apply_retro_button_style(btn_hub_adventure_ep7, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
	_apply_retro_button_style(btn_close_adventure_episodes, Color(0.25, 0.52, 0.60), Color(0.40, 0.85, 0.95), false)

	_apply_retro_button_style(btn_buy_potion, Color(0.20, 0.50, 0.80), Color(0.35, 0.75, 1.00), false)
	_apply_retro_button_style(btn_buy_super_potion, Color(0.18, 0.55, 0.85), Color(0.30, 0.80, 1.00), false)
	_apply_retro_button_style(btn_buy_hyper_potion, Color(0.75, 0.25, 0.55), Color(0.95, 0.40, 0.75), false)
	_apply_retro_button_style(btn_buy_remedy, Color(0.22, 0.63, 0.41), Color(0.40, 0.85, 0.60), false)
	if btn_buy_poke_flute:
		_apply_retro_button_style(btn_buy_poke_flute, Color(0.75, 0.60, 0.15), Color(1.00, 0.85, 0.30), false)
	_apply_retro_button_style(btn_buy_ether, Color(0.50, 0.35, 0.85), Color(0.70, 0.55, 1.00), false)
	_apply_retro_button_style(btn_buy_revive, Color(0.84, 0.62, 0.18), Color(1.00, 0.85, 0.35), false)

	_apply_retro_button_style(btn_camp_stadium_guide, Color(0.25, 0.60, 0.85), Color(0.40, 0.85, 1.00), true)
	_apply_retro_button_style(btn_close_stadium_guide, Color(0.25, 0.52, 0.60), Color(0.40, 0.85, 0.95), false)

	_apply_retro_button_style(btn_start_campaign_battle, Color(0.28, 0.73, 0.47), Color(0.45, 0.95, 0.65), true)
	_apply_retro_button_style(btn_change_campaign_team, Color(0.22, 0.70, 0.67), Color(0.35, 0.90, 0.85), true)
	_apply_retro_button_style(btn_reset_campaign, Color(0.85, 0.28, 0.28), Color(1.00, 0.50, 0.50), false)
	_apply_retro_button_style(btn_close_campaign, Color(0.25, 0.52, 0.60), Color(0.40, 0.85, 0.95), false)

func _apply_retro_button_style(btn: Button, border_col: Color = Color(0.25, 0.52, 0.60), hover_col: Color = Color(0.40, 0.85, 0.95), with_icon: bool = false) -> void:
	if not btn:
		return
	var normal_sb = StyleBoxFlat.new()
	normal_sb.bg_color = Color(0.09, 0.14, 0.20, 0.95)
	normal_sb.border_color = border_col
	normal_sb.set_border_width_all(2)
	normal_sb.set_corner_radius_all(6)
	normal_sb.content_margin_left = 12
	normal_sb.content_margin_right = 12
	normal_sb.content_margin_top = 4
	normal_sb.content_margin_bottom = 4
	
	var hover_sb = StyleBoxFlat.new()
	hover_sb.bg_color = Color(0.13, 0.22, 0.32, 1.0)
	hover_sb.border_color = hover_col
	hover_sb.set_border_width_all(2)
	hover_sb.set_corner_radius_all(6)
	hover_sb.content_margin_left = 12
	hover_sb.content_margin_right = 12
	hover_sb.content_margin_top = 4
	hover_sb.content_margin_bottom = 4
	
	var disabled_sb = StyleBoxFlat.new()
	disabled_sb.bg_color = Color(0.06, 0.08, 0.12, 0.75)
	disabled_sb.border_color = Color(0.18, 0.24, 0.30, 0.5)
	disabled_sb.set_border_width_all(1)
	disabled_sb.set_corner_radius_all(6)
	disabled_sb.content_margin_left = 12
	disabled_sb.content_margin_right = 12
	disabled_sb.content_margin_top = 4
	disabled_sb.content_margin_bottom = 4
	
	btn.add_theme_stylebox_override("normal", normal_sb)
	btn.add_theme_stylebox_override("hover", hover_sb)
	btn.add_theme_stylebox_override("pressed", hover_sb)
	btn.add_theme_stylebox_override("disabled", disabled_sb)
	
	if with_icon:
		var tex_pokeball = preload("res://assets/ui/menu_pokeball.png")
		var tex_pokeball_active = preload("res://assets/ui/menu_pokeball_active.png")
		btn.icon = tex_pokeball
		btn.expand_icon = false
		btn.mouse_entered.connect(func():
			if is_instance_valid(btn) and not btn.disabled:
				btn.icon = tex_pokeball_active
				btn.pivot_offset = Vector2(24, btn.size.y / 2.0 if btn.size.y > 0 else 20.0)
				var tw = btn.create_tween()
				tw.tween_property(btn, "scale", Vector2(1.02, 1.02), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		)
		btn.mouse_exited.connect(func():
			if is_instance_valid(btn):
				btn.icon = tex_pokeball
				btn.pivot_offset = Vector2(24, btn.size.y / 2.0 if btn.size.y > 0 else 20.0)
				var tw = btn.create_tween()
				tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		)
	else:
		btn.mouse_entered.connect(func():
			if is_instance_valid(btn) and not btn.disabled:
				btn.pivot_offset = Vector2(btn.size.x / 2.0, btn.size.y / 2.0)
				var tw = btn.create_tween()
				tw.tween_property(btn, "scale", Vector2(1.02, 1.02), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		)
		btn.mouse_exited.connect(func():
			if is_instance_valid(btn):
				btn.pivot_offset = Vector2(btn.size.x / 2.0, btn.size.y / 2.0)
				var tw = btn.create_tween()
				tw.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		)

func _create_pokemon_panel_stylebox() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.95)
	sb.border_color = Color(0.25, 0.52, 0.60)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 14
	sb.content_margin_top = 12
	sb.content_margin_right = 14
	sb.content_margin_bottom = 12
	return sb

func _create_pokemon_textbox_stylebox() -> StyleBoxTexture:
	var sb = StyleBoxTexture.new()
	sb.texture = preload("res://assets/ui/menu_textbox.png")
	sb.texture_margin_left = 12
	sb.texture_margin_top = 8
	sb.texture_margin_right = 12
	sb.texture_margin_bottom = 8
	sb.content_margin_left = 10
	sb.content_margin_top = 6
	sb.content_margin_right = 10
	sb.content_margin_bottom = 6
	return sb

# --- SHOP EXPANSION: TABS, RECYCLING & HIDDEN SHOP ---
func _setup_shop_sections() -> void:
	if not shop_box or shop_tabs_row != null:
		return
		
	# 1. Update Title and Diamonds/Candies Header
	var title_node = shop_box.get_node_or_null("Title")
	if title_node is Label:
		title_node.text = "🏪 POKÉMON SHOP & EXCHANGE"
		title_node.add_theme_color_override("font_color", Color("#FFD700"))
		
	_update_shop_currencies()
	
	# 2. Insert Shop Navigation Tabs Row directly under shop_diamonds_lbl
	shop_tabs_row = HBoxContainer.new()
	shop_tabs_row.custom_minimum_size = Vector2(0, 42)
	shop_tabs_row.add_theme_constant_override("separation", 8)
	shop_tabs_row.alignment = BoxContainer.ALIGNMENT_CENTER
	
	btn_shop_tab_packs = Button.new()
	btn_shop_tab_packs.text = "📦 Booster Packs"
	btn_shop_tab_packs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_shop_tab_packs.custom_minimum_size = Vector2(0, 38)
	btn_shop_tab_packs.add_theme_font_size_override("font_size", 13)
	btn_shop_tab_packs.pressed.connect(func(): _switch_shop_tab("PACKS"))
	shop_tabs_row.add_child(btn_shop_tab_packs)
	
	btn_shop_tab_recycle = Button.new()
	btn_shop_tab_recycle.text = "♻️ Recycle Duplicates"
	btn_shop_tab_recycle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_shop_tab_recycle.custom_minimum_size = Vector2(0, 38)
	btn_shop_tab_recycle.add_theme_font_size_override("font_size", 13)
	btn_shop_tab_recycle.pressed.connect(func(): _switch_shop_tab("RECYCLE"))
	shop_tabs_row.add_child(btn_shop_tab_recycle)
	
	btn_shop_tab_hidden = Button.new()
	btn_shop_tab_hidden.text = "🔮 Hidden Shop"
	btn_shop_tab_hidden.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_shop_tab_hidden.custom_minimum_size = Vector2(0, 38)
	btn_shop_tab_hidden.add_theme_font_size_override("font_size", 13)
	btn_shop_tab_hidden.pressed.connect(func(): _switch_shop_tab("HIDDEN"))
	shop_tabs_row.add_child(btn_shop_tab_hidden)
	
	shop_box.add_child(shop_tabs_row)
	var dia_idx = shop_diamonds_lbl.get_index()
	shop_box.move_child(shop_tabs_row, dia_idx + 1)
	
	# 3. Create Packs Container, Regional Catalog & Detail Views
	packs_container = VBoxContainer.new()
	packs_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	packs_container.add_theme_constant_override("separation", 10)
	
	var pack_panel = shop_box.get_node_or_null("PackPanel")
	if pack_panel:
		shop_box.remove_child(pack_panel)
	if btn_open_pack:
		shop_box.remove_child(btn_open_pack)
		btn_open_pack.visible = false
		
	shop_box.add_child(packs_container)
	var tabs_idx = shop_tabs_row.get_index()
	shop_box.move_child(packs_container, tabs_idx + 1)
	
	_setup_packs_catalog_view()
	if pack_panel:
		_setup_pack_detail_panel(pack_panel)
		packs_container.add_child(pack_panel)
		pack_panel.visible = false
	
	# 4. Create Recycle Container
	recycle_container = VBoxContainer.new()
	recycle_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	recycle_container.add_theme_constant_override("separation", 8)
	recycle_container.visible = false
	
	# Header Card for Recycle
	var rec_header_card = PanelContainer.new()
	rec_header_card.add_theme_stylebox_override("panel", _create_pokemon_panel_stylebox())
	var rh_vbox = VBoxContainer.new()
	rh_vbox.add_theme_constant_override("separation", 4)
	
	var rh_title = Label.new()
	rh_title.text = "♻️ DUPLICATE RECYCLE CENTER"
	rh_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rh_title.add_theme_font_size_override("font_size", 14)
	rh_title.add_theme_color_override("font_color", Color("#FFD700"))
	rh_vbox.add_child(rh_title)
	
	var rh_desc = Label.new()
	rh_desc.text = "Recycle extra copies (stock > 1) to earn 🍬 Rare Candies!\nUse Candies to purchase missing cards in the 🔮 Hidden Shop."
	rh_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rh_desc.add_theme_font_size_override("font_size", 11)
	rh_desc.add_theme_color_override("font_color", Color("#E2E8F0"))
	rh_vbox.add_child(rh_desc)
	
	var rh_rates = Label.new()
	rh_rates.text = "Yield: Common (+1 🍬) • Rare (+5 🍬) • Epic (+15 🍬) • Legendary (+40 🍬)"
	rh_rates.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rh_rates.add_theme_font_size_override("font_size", 10)
	rh_rates.add_theme_color_override("font_color", Color("#81D4FA"))
	rh_vbox.add_child(rh_rates)
	rec_header_card.add_child(rh_vbox)
	recycle_container.add_child(rec_header_card)
	
	# Action bar with bulk recycle button
	var rec_action_bar = HBoxContainer.new()
	rec_action_bar.add_theme_constant_override("separation", 8)
	rec_action_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	
	btn_bulk_recycle = Button.new()
	btn_bulk_recycle.custom_minimum_size = Vector2(0, 44)
	btn_bulk_recycle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_bulk_recycle.text = "♻️ RECYCLE ALL DUPLICATES (+0 🍬)"
	btn_bulk_recycle.add_theme_font_size_override("font_size", 13)
	btn_bulk_recycle.add_theme_color_override("font_color", Color("#33FF77"))
	
	var sb_bulk_n = StyleBoxFlat.new()
	sb_bulk_n.bg_color = Color(0.08, 0.20, 0.14, 0.95)
	sb_bulk_n.border_color = Color("#2ecc71")
	sb_bulk_n.set_border_width_all(2)
	sb_bulk_n.set_corner_radius_all(6)
	sb_bulk_n.set_content_margin_all(8)
	btn_bulk_recycle.add_theme_stylebox_override("normal", sb_bulk_n)
	
	var sb_bulk_h = StyleBoxFlat.new()
	sb_bulk_h.bg_color = Color(0.12, 0.28, 0.20, 0.95)
	sb_bulk_h.border_color = Color("#58e89d")
	sb_bulk_h.set_border_width_all(2)
	sb_bulk_h.set_corner_radius_all(6)
	sb_bulk_h.set_content_margin_all(8)
	btn_bulk_recycle.add_theme_stylebox_override("hover", sb_bulk_h)
	
	btn_bulk_recycle.pressed.connect(_on_bulk_recycle_pressed)
	rec_action_bar.add_child(btn_bulk_recycle)
	recycle_container.add_child(rec_action_bar)
	
	# Scroll area for duplicate cards
	var rec_scroll = ScrollContainer.new()
	rec_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rec_scroll.custom_minimum_size = Vector2(0, 320)
	rec_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	recycle_scroll_list = VBoxContainer.new()
	recycle_scroll_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recycle_scroll_list.add_theme_constant_override("separation", 6)
	rec_scroll.add_child(recycle_scroll_list)
	recycle_container.add_child(rec_scroll)
	
	# Empty duplicates message
	recycle_empty_lbl = Label.new()
	recycle_empty_lbl.text = "📦 No duplicate cards in your collection!\n\nAll your Pokémon cards currently have 1 copy (Stock x1).\nOpen Booster Packs to get duplicates and convert them into Rare Candies!"
	recycle_empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	recycle_empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	recycle_empty_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	recycle_empty_lbl.add_theme_font_size_override("font_size", 13)
	recycle_empty_lbl.add_theme_color_override("font_color", Color("#94A3B8"))
	recycle_container.add_child(recycle_empty_lbl)
	
	shop_box.add_child(recycle_container)
	shop_box.move_child(recycle_container, tabs_idx + 2)
	
	# 5. Create Hidden Shop Container
	hidden_shop_container = VBoxContainer.new()
	hidden_shop_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hidden_shop_container.add_theme_constant_override("separation", 8)
	hidden_shop_container.visible = false
	
	# Header Card for Hidden Shop
	var hid_header_card = PanelContainer.new()
	hid_header_card.add_theme_stylebox_override("panel", _create_pokemon_panel_stylebox())
	var hh_vbox = VBoxContainer.new()
	hh_vbox.add_theme_constant_override("separation", 4)
	
	var hh_title = Label.new()
	hh_title.text = "🔮 SECRET RARE CANDY EXCHANGE"
	hh_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hh_title.add_theme_font_size_override("font_size", 14)
	hh_title.add_theme_color_override("font_color", Color("#FFD700"))
	hh_vbox.add_child(hh_title)
	
	var hh_desc = Label.new()
	hh_desc.text = "Craft & unlock any Pokémon card using 🍬 Rare Candies!"
	hh_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hh_desc.add_theme_font_size_override("font_size", 11)
	hh_desc.add_theme_color_override("font_color", Color("#E2E8F0"))
	hh_vbox.add_child(hh_desc)
	
	var hh_rates = Label.new()
	hh_rates.text = "Prices: Common (10 🍬) • Rare (50 🍬) • Epic (150 🍬) • Legendary (400 🍬)"
	hh_rates.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hh_rates.add_theme_font_size_override("font_size", 10)
	hh_rates.add_theme_color_override("font_color", Color("#81D4FA"))
	hh_vbox.add_child(hh_rates)
	hid_header_card.add_child(hh_vbox)
	hidden_shop_container.add_child(hid_header_card)
	
	# Region buttons row for Hidden Shop
	var hid_region_row = HBoxContainer.new()
	hid_region_row.name = "HiddenRegionRow"
	hid_region_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hid_region_row.add_theme_constant_override("separation", 6)
	var hid_regions = [
		{"id": "KANTO", "label": "Kanto"},
		{"id": "JOHTO", "label": "Johto"},
		{"id": "HOENN", "label": "Hoenn"},
		{"id": "SINNOH", "label": "Sinnoh"},
		{"id": "ALL", "label": "All"}
	]
	hidden_region_buttons.clear()
	for reg in hid_regions:
		var btn_r = Button.new()
		btn_r.text = reg["label"]
		btn_r.custom_minimum_size = Vector2(96, 32)
		btn_r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_r.add_theme_font_size_override("font_size", 11)
		var rid = reg["id"]
		btn_r.pressed.connect(func(): _on_hidden_region_pressed(rid))
		hid_region_row.add_child(btn_r)
		hidden_region_buttons[rid] = btn_r
	hidden_shop_container.add_child(hid_region_row)
	
	# Filter buttons row
	var filter_scroll = ScrollContainer.new()
	filter_scroll.custom_minimum_size = Vector2(0, 36)
	filter_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	var filter_row = HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 6)
	filter_scroll.add_child(filter_row)
	
	var filters = [
		{"id": "ALL", "label": "All"},
		{"id": "MISSING", "label": "🔒 Missing"},
		{"id": "COMMON", "label": "Common"},
		{"id": "UNCOMMON", "label": "Uncommon"},
		{"id": "RARE", "label": "Rare"},
		{"id": "EPIC", "label": "Epic"},
		{"id": "LEGENDARY", "label": "Legendary"}
	]
	hidden_filter_buttons.clear()
	for f in filters:
		var btn_f = Button.new()
		btn_f.text = f["label"]
		btn_f.custom_minimum_size = Vector2(68, 30)
		btn_f.add_theme_font_size_override("font_size", 11)
		var fid = f["id"]
		btn_f.pressed.connect(func(): _on_hidden_filter_pressed(fid))
		filter_row.add_child(btn_f)
		hidden_filter_buttons[fid] = btn_f
		
	hidden_shop_container.add_child(filter_scroll)
	
	# Pagination Bar for Hidden Shop
	hidden_shop_pagination_bar = PanelContainer.new()
	hidden_shop_pagination_bar.name = "HiddenShopPaginationBar"
	var sb_hp = StyleBoxFlat.new()
	sb_hp.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	sb_hp.border_color = Color(0.20, 0.30, 0.42, 0.8)
	sb_hp.set_border_width_all(1)
	sb_hp.set_corner_radius_all(6)
	sb_hp.content_margin_left = 6
	sb_hp.content_margin_right = 6
	sb_hp.content_margin_top = 4
	sb_hp.content_margin_bottom = 4
	hidden_shop_pagination_bar.add_theme_stylebox_override("panel", sb_hp)
	hidden_shop_pagination_bar.visible = false
	hidden_shop_container.add_child(hidden_shop_pagination_bar)
	
	# Scroll Area for Hidden Shop Catalog Grid
	var hid_scroll = ScrollContainer.new()
	hid_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hid_scroll.custom_minimum_size = Vector2(0, 320)
	hid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hidden_shop_scroll = hid_scroll
	
	var grid_margin = MarginContainer.new()
	grid_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_margin.add_theme_constant_override("margin_left", 12)
	grid_margin.add_theme_constant_override("margin_right", 12)
	grid_margin.add_theme_constant_override("margin_top", 10)
	grid_margin.add_theme_constant_override("margin_bottom", 16)
	
	hidden_shop_grid = GridContainer.new()
	hidden_shop_grid.columns = 3
	hidden_shop_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hidden_shop_grid.add_theme_constant_override("h_separation", 14)
	hidden_shop_grid.add_theme_constant_override("v_separation", 16)
	grid_margin.add_child(hidden_shop_grid)
	hid_scroll.add_child(grid_margin)
	hidden_shop_container.add_child(hid_scroll)
	
	shop_box.add_child(hidden_shop_container)
	shop_box.move_child(hidden_shop_container, tabs_idx + 3)
	
	# Ensure ShopFeedbackLbl and BtnCloseShop remain at the very bottom
	if shop_feedback_lbl:
		shop_box.move_child(shop_feedback_lbl, -1)
	if btn_close_shop:
		shop_box.move_child(btn_close_shop, -1)
		
	_switch_shop_tab("PACKS")

func _switch_shop_tab(tab_name: String) -> void:
	if not GameData.tutorial_completed and GameData.tutorial_step == 1 and tab_name != "PACKS":
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "⚠️ ¡Debes comprar tu primer sobre en la sección de Sobres!"
			shop_feedback_lbl.visible = true
		return
	shop_active_tab = tab_name
	if packs_container:
		packs_container.visible = (tab_name == "PACKS")
	if recycle_container:
		recycle_container.visible = (tab_name == "RECYCLE")
	if hidden_shop_container:
		hidden_shop_container.visible = (tab_name == "HIDDEN")
		
	var active_color = Color(1.3, 1.2, 0.4)
	var inactive_color = Color(0.8, 0.85, 0.9)
	if btn_shop_tab_packs:
		btn_shop_tab_packs.modulate = active_color if tab_name == "PACKS" else inactive_color
	if btn_shop_tab_recycle:
		btn_shop_tab_recycle.modulate = active_color if tab_name == "RECYCLE" else inactive_color
	if btn_shop_tab_hidden:
		btn_shop_tab_hidden.modulate = active_color if tab_name == "HIDDEN" else inactive_color
		
	_update_shop_currencies()
	if tab_name == "PACKS":
		var pack_panel = packs_container.get_node_or_null("PackPanel") if packs_container else null
		if pack_panel and pack_panel.visible:
			_update_shop_showcase_and_rates()
		else:
			if packs_catalog_view:
				packs_catalog_view.visible = true
			if pack_panel:
				pack_panel.visible = false
			_stop_showcase_timer()
			if packs_catalog_view and is_inside_tree():
				GameLocalizationScript.translate_node_tree(packs_catalog_view, GameData.get_current_language())
	elif tab_name == "RECYCLE":
		_stop_showcase_timer()
		_populate_recycle_view()
	elif tab_name == "HIDDEN":
		_stop_showcase_timer()
		_populate_hidden_shop_view()

func _populate_recycle_view() -> void:
	if not recycle_scroll_list or not recycle_empty_lbl:
		return
		
	for child in recycle_scroll_list.get_children():
		child.queue_free()
		
	var dupes = GameData.get_duplicate_cards()
	if dupes.is_empty():
		recycle_empty_lbl.visible = true
		if btn_bulk_recycle:
			btn_bulk_recycle.disabled = true
			btn_bulk_recycle.text = "♻️ RECYCLE ALL (0 Duplicates)"
		return
		
	recycle_empty_lbl.visible = false
	var total_extra = 0
	var total_candies = 0
	for d in dupes:
		total_extra += int(d.get("dupes_count", 0))
		total_candies += int(d.get("dupes_count", 0)) * int(d.get("candy_value", 1))
		
	if btn_bulk_recycle:
		btn_bulk_recycle.disabled = false
		btn_bulk_recycle.text = "♻️ RECYCLE ALL DUPLICATES (%d extra cards ➔ +%d 🍬)" % [total_extra, total_candies]
	
	for d in dupes:
		var cid = int(d.get("id", 0))
		var c_name = str(d.get("name", "PKMN"))
		var p_num = str(d.get("pokedex_num", "1")).pad_zeros(3)
		var r_str = str(d.get("rarity", "Common"))
		var r_info = GameData.get_rarity_display_info(r_str)
		var stock = int(d.get("stock", 1))
		var extras = int(d.get("dupes_count", stock - 1))
		var candy_val = int(d.get("candy_value", GameData.get_recycle_candy_value(r_str)))
		var type_str = str(d.get("type", "NORMAL")).to_upper()
		
		var row_panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.11, 0.16, 0.95)
		sb.border_color = r_info.get("border", Color("#81D4FA"))
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(6)
		sb.set_content_margin_all(6)
		row_panel.add_theme_stylebox_override("panel", sb)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		row_panel.add_child(hbox)
		
		# Thumbnail
		var tex_rect = TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(48, 48)
		tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.texture = GameData.get_pokemon_texture(str(d.get("texture_path", "")))
		hbox.add_child(tex_rect)
		
		# Info VBox
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", 2)
		hbox.add_child(info_vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = "#%s %s" % [p_num, c_name]
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		info_vbox.add_child(name_lbl)
		
		var sub_lbl = Label.new()
		sub_lbl.text = "%s • %s" % [type_str, r_info.get("name", "Common")]
		sub_lbl.add_theme_font_size_override("font_size", 10)
		sub_lbl.add_theme_color_override("font_color", r_info.get("color", Color("#81D4FA")))
		info_vbox.add_child(sub_lbl)
		
		var stock_lbl = Label.new()
		stock_lbl.text = "Stock: x%d (1 preserved, %d extra)" % [stock, extras]
		stock_lbl.add_theme_font_size_override("font_size", 10)
		stock_lbl.add_theme_color_override("font_color", Color("#FFD700"))
		info_vbox.add_child(stock_lbl)
		
		# Action VBox
		var act_vbox = VBoxContainer.new()
		act_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		act_vbox.add_theme_constant_override("separation", 3)
		hbox.add_child(act_vbox)
		
		var yield_lbl = Label.new()
		yield_lbl.text = "+%d 🍬 each" % candy_val
		yield_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		yield_lbl.add_theme_font_size_override("font_size", 10)
		yield_lbl.add_theme_color_override("font_color", Color("#33FF77"))
		act_vbox.add_child(yield_lbl)
		
		var btn_row = HBoxContainer.new()
		btn_row.add_theme_constant_override("separation", 4)
		btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
		act_vbox.add_child(btn_row)
		
		var btn_rec_one = Button.new()
		btn_rec_one.custom_minimum_size = Vector2(75, 28)
		btn_rec_one.text = "Recycle 1"
		btn_rec_one.tooltip_text = "Recycle 1 duplicate copy (+%d 🍬)" % candy_val
		btn_rec_one.add_theme_font_size_override("font_size", 11)
		btn_rec_one.pressed.connect(func():
			if GameData.is_drag_scrolling():
				return
			_on_recycle_one_pressed(cid, c_name))
		btn_row.add_child(btn_rec_one)
		
		var btn_rec_all = Button.new()
		btn_rec_all.custom_minimum_size = Vector2(95, 28)
		if extras > 1:
			btn_rec_all.text = "Recycle All (%d)" % extras
			btn_rec_all.tooltip_text = "Recycle all %d duplicate copies (+%d 🍬)" % [extras, extras * candy_val]
		else:
			btn_rec_all.text = "Recycle All"
			btn_rec_all.tooltip_text = "Recycle 1 duplicate copy (+%d 🍬)" % candy_val
		btn_rec_all.add_theme_font_size_override("font_size", 11)
		btn_rec_all.add_theme_color_override("font_color", Color("#48e88b"))
		btn_rec_all.pressed.connect(func():
			if GameData.is_drag_scrolling():
				return
			_on_recycle_all_card_pressed(cid, c_name))
		btn_row.add_child(btn_rec_all)
		
		recycle_scroll_list.add_child(row_panel)

func _on_bulk_recycle_pressed() -> void:
	var res = GameData.recycle_all_duplicates()
	var count = int(res.get("recycled_count", 0))
	var earned = int(res.get("candies_earned", 0))
	if count > 0:
		GameData.play_combat_sfx("purchase")
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "♻️ Successfully recycled all %d duplicate cards! Earned +%d 🍬 Rare Candies!" % [count, earned]
			shop_feedback_lbl.modulate = Color(0.3, 1.0, 0.4)
			shop_feedback_lbl.visible = true
	else:
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "No duplicate cards to recycle."
			shop_feedback_lbl.modulate = Color(0.8, 0.8, 0.8)
			shop_feedback_lbl.visible = true
			
	_populate_recycle_view()
	_update_shop_currencies()
	_update_lobby_header_badge()

func _on_recycle_one_pressed(cid: int, card_name: String) -> void:
	var earned = GameData.recycle_card_copy(cid)
	if earned > 0:
		GameData.play_combat_sfx("purchase")
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "♻️ Recycled 1 duplicate copy of %s! Earned +%d 🍬 Rare Candies!" % [card_name, earned]
			shop_feedback_lbl.modulate = Color(0.3, 1.0, 0.4)
			shop_feedback_lbl.visible = true
	_populate_recycle_view()
	_update_shop_currencies()
	_update_lobby_header_badge()

func _on_recycle_all_card_pressed(cid: int, card_name: String) -> void:
	var res = GameData.recycle_all_copies_of_card(cid)
	var count = int(res.get("recycled_count", 0))
	var earned = int(res.get("candies_earned", 0))
	if count > 0:
		GameData.play_combat_sfx("purchase")
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "♻️ Recycled all %d duplicate copies of %s! Earned +%d 🍬 Rare Candies!" % [count, card_name, earned]
			shop_feedback_lbl.modulate = Color(0.3, 1.0, 0.4)
			shop_feedback_lbl.visible = true
	_populate_recycle_view()
	_update_shop_currencies()
	_update_lobby_header_badge()

func _on_hidden_region_pressed(rid: String) -> void:
	hidden_shop_region = rid
	hidden_shop_page = 0
	_populate_hidden_shop_view()

func _on_hidden_filter_pressed(fid: String) -> void:
	hidden_shop_filter = fid
	hidden_shop_page = 0
	for k in hidden_filter_buttons:
		var btn = hidden_filter_buttons[k]
		if k == fid:
			btn.modulate = Color(1.3, 1.2, 0.4)
		else:
			btn.modulate = Color(0.85, 0.85, 0.85)
	_populate_hidden_shop_view()

func _populate_hidden_shop_view() -> void:
	if not hidden_shop_grid:
		return
		
	for child in hidden_shop_grid.get_children():
		hidden_shop_grid.remove_child(child)
		child.queue_free()
		
	# Count cards per region for button labels (Only 4 official regions + ALL)
	var reg_counts = {"KANTO": 0, "JOHTO": 0, "HOENN": 0, "SINNOH": 0, "ALL": all_catalog_cards.size()}
	for c in all_catalog_cards:
		var cr = str(c.get("region", "Kanto")).strip_edges().to_upper()
		if cr == "":
			cr = "KANTO"
		if reg_counts.has(cr):
			reg_counts[cr] += 1
	var reg_labels = {"KANTO": "Kanto", "JOHTO": "Johto", "HOENN": "Hoenn", "SINNOH": "Sinnoh", "ALL": "All"}
	for rk in hidden_region_buttons:
		var rbtn: Button = hidden_region_buttons[rk]
		rbtn.text = "%s (%d)" % [reg_labels.get(rk, rk), reg_counts.get(rk, 0)]
		rbtn.modulate = Color(1.3, 1.2, 0.4) if rk == hidden_shop_region else Color(0.85, 0.85, 0.85)

	for k in hidden_filter_buttons:
		var btn = hidden_filter_buttons[k]
		btn.modulate = Color(1.3, 1.2, 0.4) if k == hidden_shop_filter else Color(0.85, 0.85, 0.85)

	var sorted_list = get_sorted_cards(all_catalog_cards, "DEX")
	var matching_cards: Array = []
	for card in sorted_list:
		if hidden_shop_region != "ALL":
			var card_reg = str(card.get("region", "Kanto")).strip_edges().to_upper()
			if card_reg == "":
				card_reg = "KANTO"
			if card_reg != hidden_shop_region:
				continue
		var cid = int(card.get("id", 0))
		var is_owned = GameData.is_pokemon_unlocked(cid)
		var r_str = str(card.get("rarity", "Common"))
		var r_low = r_str.strip_edges().to_lower()
		
		match hidden_shop_filter:
			"MISSING":
				if is_owned:
					continue
			"COMMON":
				if r_low != "common":
					continue
			"UNCOMMON":
				if not (r_low in ["uncommon", "poco común", "poco comun"]):
					continue
			"RARE":
				if r_low != "rare":
					continue
			"EPIC":
				if r_low != "epic":
					continue
			"LEGENDARY":
				if not (r_low in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]):
					continue
			"ALL", _:
				pass
		matching_cards.append(card)

	var total_cards = matching_cards.size()
	var total_pages = int(ceil(float(total_cards) / float(HIDDEN_SHOP_PER_PAGE)))
	if total_pages < 1:
		total_pages = 1
	hidden_shop_page = clampi(hidden_shop_page, 0, total_pages - 1)

	var start_idx = hidden_shop_page * HIDDEN_SHOP_PER_PAGE
	var end_idx = min(start_idx + HIDDEN_SHOP_PER_PAGE, total_cards)
	var page_cards = matching_cards.slice(start_idx, end_idx)

	_render_hidden_shop_pagination(total_cards, start_idx, end_idx, total_pages)

	for card in page_cards:
		var cid = int(card.get("id", 0))
		var is_owned = GameData.is_pokemon_unlocked(cid)
		var r_str = str(card.get("rarity", "Common"))
		var cost = GameData.get_hidden_shop_candy_cost(r_str)
		var stock = GameData.get_card_stock(cid)
		var r_info = GameData.get_rarity_display_info(r_str)
		var p_num = str(card.get("pokedex_num", "1")).pad_zeros(3)
		var c_name = str(card.get("short_name", card.get("name", "PKMN")))
		var type_str = str(card.get("type", "NORMAL")).to_upper()
		
		var card_panel = PanelContainer.new()
		card_panel.custom_minimum_size = Vector2(144, 205)
		card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.07, 0.09, 0.14, 0.95)
		sb.border_color = r_info.get("border", Color("#81D4FA"))
		sb.set_border_width_all(2 if is_owned else 1)
		sb.set_corner_radius_all(6)
		sb.set_content_margin_all(5)
		card_panel.add_theme_stylebox_override("panel", sb)
		
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.mouse_filter = Control.MOUSE_FILTER_PASS
		card_panel.add_child(vbox)
		
		# Name and Dex #
		var name_lbl = Label.new()
		name_lbl.text = "#%s %s" % [p_num, c_name]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 10)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(name_lbl)
		
		# Thumbnail
		var tex_rect = TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(68, 68)
		tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.texture = GameData.get_pokemon_texture(str(card.get("texture_path", "")))
		tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not is_owned:
			tex_rect.modulate = Color(0.85, 0.85, 0.85, 0.85)
		vbox.add_child(tex_rect)
		
		# Type and Rarity
		var type_lbl = Label.new()
		type_lbl.text = "%s • %s" % [type_str, r_info.get("name", "Common")]
		type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		type_lbl.add_theme_font_size_override("font_size", 8)
		type_lbl.add_theme_color_override("font_color", r_info.get("color", Color.WHITE))
		type_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(type_lbl)
		
		# Stock indicator
		var stock_lbl = Label.new()
		stock_lbl.text = "Stock: x%d" % stock if is_owned else "Status: Locked 🔒"
		stock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stock_lbl.add_theme_font_size_override("font_size", 9)
		stock_lbl.add_theme_color_override("font_color", Color("#81C784") if is_owned else Color("#FFB74D"))
		stock_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(stock_lbl)
		
		# Buy button
		var btn_buy = Button.new()
		btn_buy.custom_minimum_size = Vector2(0, 28)
		btn_buy.add_theme_font_size_override("font_size", 10)
		btn_buy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_buy.mouse_filter = Control.MOUSE_FILTER_STOP
		
		if GameData.player_rare_candies < cost:
			btn_buy.disabled = true
			btn_buy.text = "🍬 %d Candies" % cost
			btn_buy.modulate = Color(0.7, 0.7, 0.7)
		else:
			btn_buy.disabled = false
			if is_owned:
				btn_buy.text = "📦 Copy (🍬 %d)" % cost
				btn_buy.modulate = Color(0.4, 0.9, 1.0)
			else:
				btn_buy.text = "✨ Unlock (🍬 %d)" % cost
				btn_buy.modulate = Color(0.3, 1.0, 0.5)
			btn_buy.pressed.connect(func():
				if GameData.is_drag_scrolling():
					return
				_on_buy_hidden_card_pressed(cid, c_name, cost)
			)
		vbox.add_child(btn_buy)
		
		hidden_shop_grid.add_child(card_panel)

func _render_hidden_shop_pagination(total_cards: int, start_idx: int, end_idx: int, total_pages: int) -> void:
	if not hidden_shop_pagination_bar:
		return
		
	if total_pages <= 1:
		hidden_shop_pagination_bar.visible = false
		return
	hidden_shop_pagination_bar.visible = true
		
	for c in hidden_shop_pagination_bar.get_children():
		c.queue_free()
		
	var bar_vbox = VBoxContainer.new()
	bar_vbox.add_theme_constant_override("separation", 3)
	bar_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hidden_shop_pagination_bar.add_child(bar_vbox)
		
	var nav_hbox = HBoxContainer.new()
	nav_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	nav_hbox.add_theme_constant_override("separation", 6)
	nav_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_vbox.add_child(nav_hbox)
		
	var btn_prev = Button.new()
	btn_prev.text = "◀ Ant"
	btn_prev.custom_minimum_size = Vector2(56, 26)
	btn_prev.add_theme_font_size_override("font_size", 10)
	btn_prev.disabled = (hidden_shop_page <= 0)
	_apply_retro_button_style(btn_prev, Color(0.18, 0.24, 0.34), Color(0.28, 0.38, 0.52), btn_prev.disabled)
	btn_prev.pressed.connect(func():
		if hidden_shop_page > 0:
			hidden_shop_page -= 1
			_populate_hidden_shop_view()
			if hidden_shop_scroll:
				hidden_shop_scroll.scroll_vertical = 0
	)
	nav_hbox.add_child(btn_prev)
		
	var scroll_tabs = ScrollContainer.new()
	scroll_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_tabs.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_tabs.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_tabs.custom_minimum_size = Vector2(0, 30)
		
	var tabs_hbox = HBoxContainer.new()
	tabs_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_hbox.add_theme_constant_override("separation", 4)
	tabs_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_tabs.add_child(tabs_hbox)
	nav_hbox.add_child(scroll_tabs)
		
	for p in range(total_pages):
		var btn_p = Button.new()
		btn_p.text = "Pág %d" % (p + 1)
		btn_p.custom_minimum_size = Vector2(48, 24)
		btn_p.add_theme_font_size_override("font_size", 10)
		var is_active = (p == hidden_shop_page)
		if is_active:
			_apply_retro_button_style(btn_p, Color(0.65, 0.48, 0.12), Color(0.95, 0.78, 0.22), false)
			btn_p.modulate = Color(1.3, 1.25, 0.45)
		else:
			_apply_retro_button_style(btn_p, Color(0.16, 0.22, 0.30), Color(0.28, 0.38, 0.50), false)
			btn_p.modulate = Color(0.85, 0.85, 0.85)
		var page_num = p
		btn_p.pressed.connect(func():
			hidden_shop_page = page_num
			_populate_hidden_shop_view()
			if hidden_shop_scroll:
				hidden_shop_scroll.scroll_vertical = 0
		)
		tabs_hbox.add_child(btn_p)
		
	var btn_next = Button.new()
	btn_next.text = "Sig ▶"
	btn_next.custom_minimum_size = Vector2(56, 26)
	btn_next.add_theme_font_size_override("font_size", 10)
	btn_next.disabled = (hidden_shop_page >= total_pages - 1)
	_apply_retro_button_style(btn_next, Color(0.18, 0.24, 0.34), Color(0.28, 0.38, 0.52), btn_next.disabled)
	btn_next.pressed.connect(func():
		if hidden_shop_page < total_pages - 1:
			hidden_shop_page += 1
			_populate_hidden_shop_view()
			if hidden_shop_scroll:
				hidden_shop_scroll.scroll_vertical = 0
	)
	nav_hbox.add_child(btn_next)
		
	var info_lbl = Label.new()
	info_lbl.text = "Página %d de %d  (Mostrando %d - %d de %d cartas)" % [hidden_shop_page + 1, total_pages, start_idx + 1, end_idx, total_cards]
	info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_lbl.add_theme_font_size_override("font_size", 9)
	info_lbl.add_theme_color_override("font_color", Color("#90A4AE"))
	bar_vbox.add_child(info_lbl)

func _on_buy_hidden_card_pressed(cid: int, card_name: String, cost: int) -> void:
	var res = GameData.buy_card_from_hidden_shop(cid)
	if res.get("success", false):
		GameData.play_combat_sfx("purchase")
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "🎉 Successfully purchased %s for 🍬 %d Rare Candies! (Stock: x%d)" % [card_name, cost, res.get("stock", 1)]
			shop_feedback_lbl.modulate = Color(0.3, 1.0, 0.4)
			shop_feedback_lbl.visible = true
		refresh_cards_data_from_catalog()
		_populate_hidden_shop_view()
		_update_shop_currencies()
		_update_lobby_header_badge()
	else:
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "❌ %s" % res.get("message", "Could not complete purchase.")
			shop_feedback_lbl.modulate = Color(1.0, 0.4, 0.4)
			shop_feedback_lbl.visible = true

func _setup_packs_catalog_view() -> void:
	if packs_catalog_view != null:
		return
	packs_catalog_view = VBoxContainer.new()
	packs_catalog_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	packs_catalog_view.add_theme_constant_override("separation", 10)
	
	var cat_header = PanelContainer.new()
	cat_header.add_theme_stylebox_override("panel", _create_pokemon_panel_stylebox())
	var ch_vbox = VBoxContainer.new()
	ch_vbox.add_theme_constant_override("separation", 3)
	
	var ch_title = Label.new()
	ch_title.text = "📦 REGIONAL BOOSTER PACKS"
	ch_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ch_title.add_theme_font_size_override("font_size", 14)
	ch_title.add_theme_color_override("font_color", Color("#FFD700"))
	ch_vbox.add_child(ch_title)
	
	var ch_desc = Label.new()
	ch_desc.text = "Choose a Booster Pack to view cards, drop rates & showcases!"
	ch_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ch_desc.add_theme_font_size_override("font_size", 11)
	ch_desc.add_theme_color_override("font_color", Color("#E2E8F0"))
	ch_vbox.add_child(ch_desc)
	cat_header.add_child(ch_vbox)
	packs_catalog_view.add_child(cat_header)
	
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	
	var list_vbox = VBoxContainer.new()
	list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_vbox.add_theme_constant_override("separation", 10)
	
	for pid in ["kanto", "johto", "hoenn", "sinnoh"]:
		var p_info = GameData.BOOSTER_PACKS[pid]
		var pack_entry = _create_catalog_pack_card(pid, p_info)
		list_vbox.add_child(pack_entry)
		
	scroll.add_child(list_vbox)
	packs_catalog_view.add_child(scroll)
	packs_container.add_child(packs_catalog_view)

func _setup_pack_detail_panel(pack_panel: Control) -> void:
	var p_vbox = pack_panel.get_node_or_null("VBox")
	if not p_vbox:
		return
		
	var top_bar = HBoxContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 32)
	top_bar.alignment = BoxContainer.ALIGNMENT_BEGIN
	
	btn_back_from_detail = Button.new()
	btn_back_from_detail.text = "⬅ Back to Packs"
	btn_back_from_detail.custom_minimum_size = Vector2(135, 30)
	btn_back_from_detail.add_theme_font_size_override("font_size", 12)
	btn_back_from_detail.add_theme_color_override("font_color", Color("#81D4FA"))
	
	var sb_back = StyleBoxFlat.new()
	sb_back.bg_color = Color(0.08, 0.12, 0.20, 0.95)
	sb_back.border_color = Color("#29B6F6")
	sb_back.set_border_width_all(1)
	sb_back.set_corner_radius_all(6)
	sb_back.set_content_margin_all(5)
	btn_back_from_detail.add_theme_stylebox_override("normal", sb_back)
	
	var sb_back_h = StyleBoxFlat.new()
	sb_back_h.bg_color = Color(0.12, 0.18, 0.28, 0.98)
	sb_back_h.border_color = Color("#81D4FA")
	sb_back_h.set_border_width_all(2)
	sb_back_h.set_corner_radius_all(6)
	sb_back_h.set_content_margin_all(5)
	btn_back_from_detail.add_theme_stylebox_override("hover", sb_back_h)
	
	btn_back_from_detail.pressed.connect(_back_to_packs_catalog)
	top_bar.add_child(btn_back_from_detail)
	
	p_vbox.add_child(top_bar)
	p_vbox.move_child(top_bar, 0)
	
	var header_row = p_vbox.get_node_or_null("PackHeaderRow")
	if header_row:
		if pack_art_texture:
			pack_art_texture.visible = false
			
		pack_detail_art_container = MarginContainer.new()
		pack_detail_art_container.custom_minimum_size = Vector2(124, 174)
		header_row.add_child(pack_detail_art_container)
		header_row.move_child(pack_detail_art_container, 0)
		
		var header_info = header_row.get_node_or_null("PackHeaderInfo")
		if header_info:
			var pack_price = header_info.get_node_or_null("PackPrice")
			if pack_price:
				pack_price.visible = false
				
			pack_detail_region_lbl = Label.new()
			pack_detail_region_lbl.add_theme_font_size_override("font_size", 11)
			pack_detail_region_lbl.add_theme_color_override("font_color", Color("#81D4FA"))
			header_info.add_child(pack_detail_region_lbl)
			header_info.move_child(pack_detail_region_lbl, 1)
			
			btn_small_cost_pack = Button.new()
			btn_small_cost_pack.text = "Cost: 5 💎"
			btn_small_cost_pack.custom_minimum_size = Vector2(130, 36)
			btn_small_cost_pack.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			btn_small_cost_pack.add_theme_font_size_override("font_size", 13)
			btn_small_cost_pack.add_theme_color_override("font_color", Color("#33FF77"))
			
			var sb_c_n = StyleBoxFlat.new()
			sb_c_n.bg_color = Color(0.08, 0.22, 0.14, 0.95)
			sb_c_n.border_color = Color("#2ecc71")
			sb_c_n.set_border_width_all(2)
			sb_c_n.set_corner_radius_all(6)
			sb_c_n.set_content_margin_all(6)
			btn_small_cost_pack.add_theme_stylebox_override("normal", sb_c_n)
			
			var sb_c_h = StyleBoxFlat.new()
			sb_c_h.bg_color = Color(0.12, 0.30, 0.20, 0.98)
			sb_c_h.border_color = Color("#58e89d")
			sb_c_h.set_border_width_all(2)
			sb_c_h.set_corner_radius_all(6)
			sb_c_h.set_content_margin_all(6)
			btn_small_cost_pack.add_theme_stylebox_override("hover", sb_c_h)
			
			btn_small_cost_pack.pressed.connect(_on_open_selected_pack_pressed)
			header_info.add_child(btn_small_cost_pack)

func _create_crimp_band(region_name: String, accent: Color, _is_top: bool, width: float, height: float, is_large: bool) -> Control:
	var band = PanelContainer.new()
	band.custom_minimum_size = Vector2(width, height)
	band.clip_contents = true
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = accent.lerp(Color.WHITE, 0.35)
	sb.border_color = Color("#111827")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(2)
	sb.content_margin_left = 2
	sb.content_margin_right = 2
	sb.content_margin_top = 0
	sb.content_margin_bottom = 0
	band.add_theme_stylebox_override("panel", sb)
	
	# Background crimp texture (subtle serrated ribs)
	var border_tex = GameData.get_booster_pack_border_texture()
	if border_tex:
		var bg_tex = TextureRect.new()
		bg_tex.texture = border_tex
		bg_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_tex.stretch_mode = TextureRect.STRETCH_TILE
		bg_tex.modulate = Color(1.0, 1.0, 1.0, 0.25)
		band.add_child(bg_tex)
		
	# Region text replacing "Ruby/Sapphire/Emerald"
	var lbl = Label.new()
	lbl.text = region_name.to_upper()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.add_theme_font_size_override("font_size", 8 if not is_large else 10)
	lbl.add_theme_color_override("font_color", Color("#111827"))
	lbl.add_theme_constant_override("outline_size", 1)
	lbl.add_theme_color_override("font_outline_color", accent.lerp(Color.WHITE, 0.7))
	band.add_child(lbl)
	
	return band

func _create_booster_pack_visual_widget(pack_id: String, is_large: bool = false) -> Control:
	var pack_info = GameData.BOOSTER_PACKS.get(pack_id, {})
	var accent: Color = pack_info.get("accent_color", Color("#FFD700"))
	var reg_name = str(pack_info.get("region", "Kanto"))
	var pack_tex = GameData.get_booster_pack_texture(pack_id)
	
	var w = 96 if not is_large else 124
	var h = 138 if not is_large else 174
	var crimp_h = 14 if not is_large else 16
	
	var pack_card = PanelContainer.new()
	pack_card.custom_minimum_size = Vector2(w, h)
	pack_card.clip_contents = true
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.05, 0.08, 0.98)
	sb.border_color = accent
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 2
	sb.content_margin_right = 2
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	pack_card.add_theme_stylebox_override("panel", sb)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pack_card.add_child(vbox)
	
	# Top crimped seal with region name (replaces "Ruby/Sapphire/Emerald")
	var top_crimp = _create_crimp_band(reg_name, accent, true, w - 4, crimp_h, is_large)
	vbox.add_child(top_crimp)
	
	# Artwork with dedicated booster pack packaging foil sheen
	var art_container = PanelContainer.new()
	art_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art_container.clip_contents = true
	
	var art_rect = TextureRect.new()
	art_rect.texture = pack_tex
	art_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art_container.add_child(art_rect)
	
	# Dedicated booster pack foil shader (distinct from card foil)
	GameData.apply_booster_pack_foil_overlay(art_container, accent)
	vbox.add_child(art_container)
	
	# Bottom crimped seal with region name (replaces "Ruby/Sapphire/Emerald")
	var bot_crimp = _create_crimp_band(reg_name, accent, false, w - 4, crimp_h, is_large)
	vbox.add_child(bot_crimp)
	
	return pack_card

func _create_catalog_pack_card(pid: String, p_info: Dictionary) -> Control:
	var accent: Color = p_info.get("accent_color", Color("#FFD700"))
	var reg_name = p_info.get("region", "")
	var count = _get_region_card_count(reg_name)
	
	var card_panel = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(0, 146)
	card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.08, 0.13, 0.95)
	sb.border_color = accent.lerp(Color.WHITE, 0.25)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	card_panel.add_theme_stylebox_override("panel", sb)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)
	hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	card_panel.add_child(hbox)
	
	# LEFT: Booster pack visual
	var pack_visual = _create_booster_pack_visual_widget(pid, false)
	pack_visual.custom_minimum_size = Vector2(96, 138)
	hbox.add_child(pack_visual)
	
	# RIGHT: Pack Data & Actions
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	info_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(info_vbox)
	
	var title_lbl = Label.new()
	title_lbl.text = p_info.get("name", "")
	title_lbl.add_theme_font_size_override("font_size", 15)
	title_lbl.add_theme_color_override("font_color", accent)
	info_vbox.add_child(title_lbl)
	
	var reg_lbl = Label.new()
	reg_lbl.text = "📍 %s • %d Cards" % [reg_name, count]
	reg_lbl.add_theme_font_size_override("font_size", 11)
	reg_lbl.add_theme_color_override("font_color", Color("#90A4AE"))
	info_vbox.add_child(reg_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = p_info.get("desc", "")
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.max_lines_visible = 3
	desc_lbl.add_theme_font_size_override("font_size", 10)
	desc_lbl.add_theme_color_override("font_color", Color("#CFD8DC"))
	info_vbox.add_child(desc_lbl)
	
	var act_row = HBoxContainer.new()
	act_row.add_theme_constant_override("separation", 10)
	act_row.alignment = BoxContainer.ALIGNMENT_BEGIN
	info_vbox.add_child(act_row)
	
	var cost_lbl = Label.new()
	cost_lbl.text = "Cost: %d 💎" % p_info.get("cost", 5)
	cost_lbl.add_theme_font_size_override("font_size", 11)
	cost_lbl.add_theme_color_override("font_color", Color("#33FF77"))
	act_row.add_child(cost_lbl)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	act_row.add_child(spacer)
	
	var btn_inspect = Button.new()
	btn_inspect.text = "Inspect Pack ➡"
	btn_inspect.custom_minimum_size = Vector2(115, 30)
	btn_inspect.add_theme_font_size_override("font_size", 11)
	btn_inspect.add_theme_color_override("font_color", accent)
	
	var sb_n = StyleBoxFlat.new()
	sb_n.bg_color = Color(0.08, 0.12, 0.18, 0.95)
	sb_n.border_color = accent
	sb_n.set_border_width_all(1)
	sb_n.set_corner_radius_all(6)
	btn_inspect.add_theme_stylebox_override("normal", sb_n)
	
	var sb_h = StyleBoxFlat.new()
	sb_h.bg_color = Color(0.12, 0.18, 0.28, 0.98)
	sb_h.border_color = accent.lerp(Color.WHITE, 0.3)
	sb_h.set_border_width_all(2)
	sb_h.set_corner_radius_all(6)
	btn_inspect.add_theme_stylebox_override("hover", sb_h)
	
	btn_inspect.pressed.connect(func():
		if GameData.is_drag_scrolling():
			return
		_open_booster_pack_detail(pid)
	)
	act_row.add_child(btn_inspect)
	
	card_panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if GameData.is_drag_scrolling():
				return
			_open_booster_pack_detail(pid)
	)
	
	return card_panel

func _open_booster_pack_detail(pid: String) -> void:
	selected_booster_pack_id = pid
	if packs_catalog_view:
		packs_catalog_view.visible = false
	var pack_panel = packs_container.get_node_or_null("PackPanel") if packs_container else null
	if pack_panel:
		pack_panel.visible = true
	if btn_open_pack:
		btn_open_pack.visible = false
		
	_update_selected_pack_detail_ui()
	_update_shop_showcase_and_rates()
	if is_inside_tree() and pack_panel:
		GameLocalizationScript.translate_node_tree(pack_panel, GameData.get_current_language())

func _back_to_packs_catalog() -> void:
	if not GameData.tutorial_completed and GameData.tutorial_step == 1:
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "⚠️ ¡Debes abrir el sobre de Kanto para continuar con el tutorial!"
			shop_feedback_lbl.visible = true
		return
	var pack_panel = packs_container.get_node_or_null("PackPanel") if packs_container else null
	if pack_panel:
		pack_panel.visible = false
	if btn_open_pack:
		btn_open_pack.visible = false
	if packs_catalog_view:
		packs_catalog_view.visible = true
	_stop_showcase_timer()
	if is_inside_tree() and packs_catalog_view:
		GameLocalizationScript.translate_node_tree(packs_catalog_view, GameData.get_current_language())

func _update_selected_pack_detail_ui() -> void:
	var p_info = GameData.BOOSTER_PACKS.get(selected_booster_pack_id, {})
	var reg_name = str(p_info.get("region", "Kanto"))
	var accent: Color = p_info.get("accent_color", Color("#FFD700"))
	var count = _get_region_card_count(reg_name)
	
	var pack_panel = packs_container.get_node_or_null("PackPanel") if packs_container else null
	if not pack_panel:
		return
		
	var pack_title = pack_panel.find_child("PackTitle", true, false) as Label
	if pack_title:
		pack_title.text = p_info.get("name", "Booster Pack")
		pack_title.add_theme_color_override("font_color", accent)
		
	if pack_detail_region_lbl:
		pack_detail_region_lbl.text = "📍 Region: %s • %d Pokémon Available" % [reg_name, count]
		pack_detail_region_lbl.add_theme_color_override("font_color", accent.lerp(Color.WHITE, 0.4))
		
	var pack_desc = pack_panel.find_child("PackDesc", true, false) as Label
	if pack_desc:
		pack_desc.text = p_info.get("desc", "")
		
	if btn_small_cost_pack:
		var cost = int(p_info.get("cost", 5))
		btn_small_cost_pack.text = "Cost: %d 💎" % cost
		btn_small_cost_pack.disabled = (GameData.player_diamonds < cost)
		
	if pack_detail_art_container:
		for c in pack_detail_art_container.get_children():
			pack_detail_art_container.remove_child(c)
			c.queue_free()
		var visual = _create_booster_pack_visual_widget(selected_booster_pack_id, true)
		pack_detail_art_container.add_child(visual)

func _get_region_card_count(region_name: String) -> int:
	var count = 0
	var reg_lower = region_name.strip_edges().to_lower()
	for pid in GameData.all_pokemon_ids:
		var d = GameData.pokemon_catalog.get(pid, {})
		if str(d.get("region", "")).strip_edges().to_lower() == reg_lower:
			count += 1
	return count

func _on_open_selected_pack_pressed() -> void:
	var p_info = GameData.BOOSTER_PACKS.get(selected_booster_pack_id, {})
	var cost = int(p_info.get("cost", BOOSTER_PACK_COST))
	if GameData.player_diamonds < cost:
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "❌ Not enough Diamonds! Requires 💎 %d Diamonds. Complete Tournament phases to earn Diamonds." % cost
			shop_feedback_lbl.visible = true
		return
		
	var opened = GameData.open_booster_pack(selected_booster_pack_id, cost)
	if opened.is_empty():
		return
	if not GameData.tutorial_completed and GameData.tutorial_step == 1:
		GameData.tutorial_step = 2
		GameData.save_profile()
	refresh_cards_data_from_catalog()
	_update_lobby_header_badge()
	_update_shop_currencies()
	_show_pack_reveal_ui(opened)

func _on_shop_pressed() -> void:
	if shop_feedback_lbl:
		shop_feedback_lbl.text = ""
	_update_shop_currencies()
	if btn_open_pack:
		btn_open_pack.text = "✨ OPEN BOOSTER PACK (💎 %d Diamonds)" % BOOSTER_PACK_COST
		btn_open_pack.disabled = (GameData.player_diamonds < BOOSTER_PACK_COST)
	
	if pack_reveal_box:
		pack_reveal_box.visible = false
	shop_box.visible = true
	shop_modal.visible = true
	if not GameData.tutorial_completed and GameData.tutorial_step == 1:
		_switch_shop_tab("PACKS")
		_open_booster_pack_detail("kanto")
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "🎁 ¡Toca 'Cost: 5 💎' abajo para abrir tu primer sobre con tus 25 Diamantes!"
			shop_feedback_lbl.visible = true
	else:
		_switch_shop_tab(shop_active_tab)

func _update_shop_showcase_and_rates() -> void:
	var p_info = GameData.BOOSTER_PACKS.get(selected_booster_pack_id, {})
	var reg_name = str(p_info.get("region", "Kanto"))

	# 1. Booster Pack Visual
	if pack_detail_art_container and pack_detail_art_container.get_child_count() == 0:
		var visual = _create_booster_pack_visual_widget(selected_booster_pack_id, true)
		pack_detail_art_container.add_child(visual)

	# 2. Rarity Drop Rates Grid
	if rates_grid:
		for child in rates_grid.get_children():
			child.queue_free()
		var rates = GameData.get_booster_rarity_rates(reg_name)
		for r in rates:
			var item_box = HBoxContainer.new()
			item_box.add_theme_constant_override("separation", 6)
			
			var stars_lbl = Label.new()
			stars_lbl.text = str(r["stars"])
			stars_lbl.add_theme_font_size_override("font_size", 11)
			stars_lbl.add_theme_color_override("font_color", r["color"])
			item_box.add_child(stars_lbl)
			
			var rate_lbl = Label.new()
			rate_lbl.text = "%s: %.1f%%" % [r["name"], r["percent"]]
			rate_lbl.add_theme_font_size_override("font_size", 11)
			rate_lbl.add_theme_color_override("font_color", r["color"])
			item_box.add_child(rate_lbl)
			
			rates_grid.add_child(item_box)

	# 3. Featured Showcase Cards (Rotating Epic & Legendary Foils for this region)
	if showcase_header:
		showcase_header.text = "✨ FEATURED FOIL CARDS (EPIC & LEGENDARY - %s):" % reg_name.to_upper()
	showcase_legendary_queue.clear()
	showcase_epic_queue.clear()
	showcase_cycle_count = 0
	_rotate_showcase_cards(false)
	_start_showcase_timer()

func _setup_showcase_timer() -> void:
	if not showcase_timer:
		showcase_timer = Timer.new()
		showcase_timer.name = "ShowcaseRotationTimer"
		showcase_timer.wait_time = SHOWCASE_ROTATION_INTERVAL
		showcase_timer.one_shot = false
		showcase_timer.autostart = false
		showcase_timer.timeout.connect(_on_showcase_timer_timeout)
		add_child(showcase_timer)

func _start_showcase_timer() -> void:
	if showcase_timer and shop_modal and shop_modal.visible and shop_active_tab == "PACKS":
		if showcase_timer.is_stopped():
			showcase_timer.start(SHOWCASE_ROTATION_INTERVAL)

func _stop_showcase_timer() -> void:
	if showcase_timer and not showcase_timer.is_stopped():
		showcase_timer.stop()

func _on_showcase_timer_timeout() -> void:
	if not shop_modal or not shop_modal.visible or shop_active_tab != "PACKS" or (pack_reveal_box and pack_reveal_box.visible):
		_stop_showcase_timer()
		return
	if showcase_is_animating:
		return
	_rotate_showcase_cards(true)

func _rotate_showcase_cards(animated: bool = true) -> void:
	if not showcase_row:
		return
	if animated and is_inside_tree() and showcase_row.is_visible_in_tree():
		showcase_is_animating = true
		var tween = create_tween()
		tween.tween_property(showcase_row, "modulate:a", 0.0, 0.25)
		tween.tween_callback(func():
			_populate_showcase_cards()
		)
		tween.tween_property(showcase_row, "modulate:a", 1.0, 0.25)
		tween.tween_callback(func():
			showcase_is_animating = false
		)
	else:
		showcase_row.modulate.a = 1.0
		_populate_showcase_cards()

func _populate_showcase_cards() -> void:
	if not showcase_row:
		return
	for child in showcase_row.get_children():
		showcase_row.remove_child(child)
		child.queue_free()
		
	var trio = _get_next_showcase_trio()
	for pid in trio:
		var d = GameData.pokemon_catalog.get(pid, {})
		if d.is_empty():
			continue
		var showcase_card = _create_showcase_card_node(d)
		showcase_row.add_child(showcase_card)

func _refill_showcase_queues_if_needed() -> void:
	var p_info = GameData.BOOSTER_PACKS.get(selected_booster_pack_id, {})
	var reg_name = str(p_info.get("region", "Kanto")).strip_edges().to_lower()
	
	if showcase_legendary_queue.size() < 3:
		var l_ids: Array[int] = []
		for pid in GameData.all_pokemon_ids:
			var d = GameData.pokemon_catalog.get(pid, {})
			if str(d.get("region", "")).strip_edges().to_lower() == reg_name:
				var r = str(d.get("rarity", "")).strip_edges().to_lower()
				if r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]:
					l_ids.append(pid)
		if l_ids.is_empty():
			for pid in GameData.all_pokemon_ids:
				var d = GameData.pokemon_catalog.get(pid, {})
				var r = str(d.get("rarity", "")).strip_edges().to_lower()
				if r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]:
					l_ids.append(pid)
		l_ids.shuffle()
		showcase_legendary_queue.append_array(l_ids)
		
	if showcase_epic_queue.size() < 3:
		var e_ids: Array[int] = []
		for pid in GameData.all_pokemon_ids:
			var d = GameData.pokemon_catalog.get(pid, {})
			if str(d.get("region", "")).strip_edges().to_lower() == reg_name:
				var r = str(d.get("rarity", "")).strip_edges().to_lower()
				if r in ["epic", "epica", "epico", "sr", "super rare"]:
					e_ids.append(pid)
		if e_ids.is_empty():
			for pid in GameData.all_pokemon_ids:
				var d = GameData.pokemon_catalog.get(pid, {})
				var r = str(d.get("rarity", "")).strip_edges().to_lower()
				if r in ["epic", "epica", "epico", "sr", "super rare"]:
					e_ids.append(pid)
		e_ids.shuffle()
		showcase_epic_queue.append_array(e_ids)

func _get_next_showcase_trio() -> Array[int]:
	_refill_showcase_queues_if_needed()
	showcase_cycle_count += 1
	var trio: Array[int] = []
	
	# Rotación garantizada de solo épicas y legendarias:
	# - Ciclo 1 y cada 5: Trío Legendario (3 Legendarios)
	# - Cada 5 con offset 3: Trío Épico (3 Épicos)
	# - Resto de ciclos: 1 Legendario + 2 Épicos
	if showcase_cycle_count % 5 == 1 and showcase_legendary_queue.size() >= 3:
		for i in range(3):
			if not showcase_legendary_queue.is_empty():
				trio.append(showcase_legendary_queue.pop_front())
	elif showcase_cycle_count % 5 == 3 and showcase_epic_queue.size() >= 3:
		for i in range(3):
			if not showcase_epic_queue.is_empty():
				trio.append(showcase_epic_queue.pop_front())
	else:
		if not showcase_legendary_queue.is_empty():
			trio.append(showcase_legendary_queue.pop_front())
		while trio.size() < 3 and not showcase_epic_queue.is_empty():
			trio.append(showcase_epic_queue.pop_front())
			
	trio.shuffle()
	return trio

func _create_showcase_card_node(d: Dictionary) -> Control:
	var cid = int(d.get("id", 0))
	var p_num = str(d.get("pokedex_num", "1")).pad_zeros(3)
	var r_info = GameData.get_rarity_display_info(str(d.get("rarity", "Legendary")))
	var type_key = str(d.get("type", "NORMAL")).to_upper()
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(104, 142)
	panel.clip_contents = true
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.08, 0.13, 0.95)
	sb.border_color = r_info.get("border", Color("#FFE066"))
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 4
	sb.content_margin_right = 4
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", sb)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	# Stars
	var stars_lbl = Label.new()
	stars_lbl.text = str(r_info.get("stars", "⭐⭐⭐⭐"))
	stars_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars_lbl.add_theme_font_size_override("font_size", 9)
	stars_lbl.add_theme_color_override("font_color", r_info.get("color", Color("#FFD700")))
	vbox.add_child(stars_lbl)
	
	# Artwork
	var tex_rect = TextureRect.new()
	tex_rect.custom_minimum_size = Vector2(80, 80)
	tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex = GameData.get_pokemon_texture(str(d.get("texture_path", "")))
	tex_rect.texture = tex
	vbox.add_child(tex_rect)
	
	# Name & Dex #
	var name_lbl = Label.new()
	name_lbl.text = "#%s %s" % [p_num, d.get("name", "")]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_lbl)
	
	# Type & Rarity
	var sub_lbl = Label.new()
	sub_lbl.text = "%s • %s" % [type_key, r_info.get("name", "Legendary")]
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 8)
	sub_lbl.add_theme_color_override("font_color", r_info.get("color", Color("#FFD700")))
	vbox.add_child(sub_lbl)
	
	# Efecto Foil Holográfico según rareza (Epic o Legendary)
	GameData.apply_foil_overlay(panel, str(d.get("rarity", "Legendary")))
	
	return panel

func _on_open_pack_pressed() -> void:
	_on_open_selected_pack_pressed()

func _show_pack_reveal_ui(cards: Array) -> void:
	_stop_showcase_timer()
	if not pack_reveal_box:
		_create_pack_reveal_container()
		
	shop_box.visible = false
	pack_reveal_box.visible = true
	
	var rem_lbl = pack_reveal_box.find_child("RemainingDiamondsLbl", true, false) as Label
	if rem_lbl:
		rem_lbl.text = "💎 Remaining Diamonds: %d" % GameData.player_diamonds
	
	if btn_reveal_another:
		var p_info = GameData.BOOSTER_PACKS.get(selected_booster_pack_id, {})
		var cost = int(p_info.get("cost", BOOSTER_PACK_COST))
		btn_reveal_another.text = "✨ OPEN ANOTHER PACK (💎 %d Diamonds)" % cost
		btn_reveal_another.disabled = (GameData.player_diamonds < cost)
	
	for child in reveal_cards_row.get_children():
		reveal_cards_row.remove_child(child)
		child.queue_free()
		
	for c in cards:
		var card_panel = _create_reveal_card_item(c)
		reveal_cards_row.add_child(card_panel)
		
	if is_inside_tree():
		GameLocalizationScript.translate_node_tree(pack_reveal_box, GameData.get_current_language())

	if not GameData.tutorial_completed and GameData.tutorial_step == 2:
		if btn_reveal_another:
			btn_reveal_another.visible = false
		var btn_col = pack_reveal_box.find_child("BtnCol", true, false) as Button
		if btn_col:
			btn_col.visible = false
		var btn_back_shop = pack_reveal_box.find_child("BtnBackShop", true, false) as Button
		if btn_back_shop:
			btn_back_shop.visible = false
			
		var actions_box = pack_reveal_box.get_child(pack_reveal_box.get_child_count() - 1)
		var btn_tutorial_starter = pack_reveal_box.find_child("BtnTutorialStarter", true, false) as Button
		if not btn_tutorial_starter:
			btn_tutorial_starter = Button.new()
			btn_tutorial_starter.name = "BtnTutorialStarter"
			btn_tutorial_starter.custom_minimum_size = Vector2(0, 48)
			btn_tutorial_starter.text = "🌟 Aprender Estadísticas y Elegir Inicial ➡️"
			btn_tutorial_starter.add_theme_font_size_override("font_size", 14)
			_apply_retro_button_style(btn_tutorial_starter, Color(0.20, 0.65, 0.35), Color(0.35, 0.85, 0.50), false)
			btn_tutorial_starter.pressed.connect(_show_card_anatomy_and_starter_modal)
			if actions_box:
				actions_box.add_child(btn_tutorial_starter)
		btn_tutorial_starter.visible = true
		var t_modal = get_tree().create_timer(0.4)
		t_modal.timeout.connect(_show_card_anatomy_and_starter_modal)

func _create_pack_reveal_container() -> void:
	pack_reveal_box = VBoxContainer.new()
	pack_reveal_box.layout_mode = 1
	pack_reveal_box.anchors_preset = Control.PRESET_FULL_RECT
	pack_reveal_box.offset_left = 16
	pack_reveal_box.offset_top = 28
	pack_reveal_box.offset_right = -16
	pack_reveal_box.offset_bottom = -20
	pack_reveal_box.add_theme_constant_override("separation", 14)
	pack_reveal_box.alignment = BoxContainer.ALIGNMENT_CENTER
	shop_modal.add_child(pack_reveal_box)
	
	# Cabecera
	var title_lbl = Label.new()
	title_lbl.text = "🎉 BOOSTER PACK OPENED!"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color("#FFD700"))
	pack_reveal_box.add_child(title_lbl)
	
	var remaining_dia_lbl = Label.new()
	remaining_dia_lbl.name = "RemainingDiamondsLbl"
	remaining_dia_lbl.text = "💎 Remaining Diamonds: %d" % GameData.player_diamonds
	remaining_dia_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	remaining_dia_lbl.add_theme_font_size_override("font_size", 14)
	remaining_dia_lbl.add_theme_color_override("font_color", Color("#40C4FF"))
	pack_reveal_box.add_child(remaining_dia_lbl)
	
	var sub_lbl = Label.new()
	sub_lbl.text = "You obtained 3 cards based on Rarity probability:"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 12)
	sub_lbl.add_theme_color_override("font_color", Color("#B0BEC5"))
	pack_reveal_box.add_child(sub_lbl)
	
	# Fila de 3 cartas
	reveal_cards_row = HBoxContainer.new()
	reveal_cards_row.layout_mode = 2
	reveal_cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reveal_cards_row.add_theme_constant_override("separation", 8)
	reveal_cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pack_reveal_box.add_child(reveal_cards_row)
	
	# Acciones inferiores
	var actions_box = VBoxContainer.new()
	actions_box.add_theme_constant_override("separation", 8)
	pack_reveal_box.add_child(actions_box)
	
	btn_reveal_another = Button.new()
	btn_reveal_another.custom_minimum_size = Vector2(0, 48)
	btn_reveal_another.text = "✨ OPEN ANOTHER PACK (💎 %d Diamonds)" % BOOSTER_PACK_COST
	btn_reveal_another.add_theme_font_size_override("font_size", 14)
	btn_reveal_another.add_theme_color_override("font_color", Color("#33FF77"))
	btn_reveal_another.pressed.connect(_on_open_pack_pressed)
	actions_box.add_child(btn_reveal_another)
	
	var btn_col = Button.new()
	btn_col.name = "BtnCol"
	btn_col.custom_minimum_size = Vector2(0, 40)
	btn_col.text = "📖 View in My Collection"
	btn_col.add_theme_font_size_override("font_size", 13)
	btn_col.add_theme_color_override("font_color", Color("#40C4FF"))
	btn_col.pressed.connect(func():
		_stop_showcase_timer()
		pack_reveal_box.visible = false
		shop_modal.visible = false
		_update_lobby_header_badge()
		_on_collection_pressed()
	)
	actions_box.add_child(btn_col)
	
	var btn_back_shop = Button.new()
	btn_back_shop.name = "BtnBackShop"
	btn_back_shop.custom_minimum_size = Vector2(0, 36)
	btn_back_shop.text = "🛒 Back to Shop"
	btn_back_shop.add_theme_font_size_override("font_size", 13)
	btn_back_shop.pressed.connect(func():
		pack_reveal_box.visible = false
		shop_box.visible = true
		_update_lobby_header_badge()
		if shop_active_tab == "PACKS":
			var pack_panel = packs_container.get_node_or_null("PackPanel") if packs_container else null
			if pack_panel and pack_panel.visible:
				_start_showcase_timer()
	)
	actions_box.add_child(btn_back_shop)

func _create_reveal_card_item(card_dict: Dictionary) -> PanelContainer:
	var is_new = card_dict.get("is_new", false)
	var r_info = GameData.get_rarity_display_info(str(card_dict.get("rarity", "Common")))
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(154, 245)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#121722")
	if is_new:
		# Borde dorado brillante para carta recién conseguida
		sb.border_color = Color("#FFD700")
		sb.set_border_width_all(2)
	else:
		# Borde temático de la rareza sin resalte
		sb.border_color = r_info.get("border", Color("#81D4FA"))
		sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(6)
	panel.add_theme_stylebox_override("panel", sb)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	# Indicador superior: Estrella sobre la carta si la acabas de conseguir.
	# Si ya la tenías, queda totalmente limpio sin símbolos sobre la carta.
	var top_indicator = Label.new()
	top_indicator.custom_minimum_size = Vector2(0, 20)
	top_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_indicator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var stock = card_dict.get("stock", GameData.get_card_stock(int(card_dict.get("id", 0))))
	if is_new:
		top_indicator.text = "⭐ NEW! (x%d)" % stock
		top_indicator.add_theme_font_size_override("font_size", 11)
		top_indicator.add_theme_color_override("font_color", Color("#FFD700"))
	else:
		top_indicator.text = "📦 Copy (x%d)" % stock
		top_indicator.add_theme_font_size_override("font_size", 10)
		top_indicator.add_theme_color_override("font_color", Color("#81D4FA"))
	vbox.add_child(top_indicator)
	
	# Arte de la Carta con proporción adecuada
	var thumb = TextureRect.new()
	thumb.custom_minimum_size = Vector2(140, 130)
	thumb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumb.texture = GameData.get_pokemon_texture(str(card_dict.get("texture_path", "")))
	vbox.add_child(thumb)
	
	# Nombre y Número Pokédex
	var p_num = str(card_dict.get("pokedex_num", "1")).pad_zeros(3)
	var name_lbl = Label.new()
	name_lbl.text = "#%s %s" % [p_num, card_dict.get("name", "PKMN")]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_lbl)
	
	# Tipo y Fase
	var type_str = str(card_dict.get("type", "NORMAL"))
	var type_lbl = Label.new()
	type_lbl.text = "%s • %s" % [type_str, card_dict.get("stage", "Basic")]
	type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_lbl.add_theme_font_size_override("font_size", 10)
	type_lbl.add_theme_color_override("font_color", GameData.get_type_primary_color(type_str))
	vbox.add_child(type_lbl)
	
	# Rareza (texto limpio, sin estrellas ni símbolos sobre la carta)
	var rarity_lbl = Label.new()
	rarity_lbl.text = str(r_info.get("name", "Common"))
	rarity_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_lbl.add_theme_font_size_override("font_size", 10)
	rarity_lbl.add_theme_color_override("font_color", r_info.get("color", Color.WHITE))
	vbox.add_child(rarity_lbl)
	
	# Efecto Foil Holográfico en cartas reveladas según su rareza
	GameData.apply_foil_overlay(panel, str(card_dict.get("rarity", "Common")))
	
	return panel

func _on_exit_pressed() -> void:
	get_tree().quit()

# --- LÓGICA DE COLECCIÓN (CUADRÍCULA, DETALLE Y FILTROS) ---
func _setup_collection_filters() -> void:
	if collection_filter_panel != null:
		return
	if not collection_grid_view:
		return
		
	# 0. Barra de Pestañas por Región en cuadrícula 3 columnas x 2 filas
	var col_reg_grid = GridContainer.new()
	col_reg_grid.name = "ColRegionTabsRow"
	col_reg_grid.columns = 5
	col_reg_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_reg_grid.add_theme_constant_override("h_separation", 4)
	col_reg_grid.add_theme_constant_override("v_separation", 4)
	col_region_tabs_row = col_reg_grid
	var col_regions = [
		{"id": "KANTO", "label": "Kanto"},
		{"id": "JOHTO", "label": "Johto"},
		{"id": "HOENN", "label": "Hoenn"},
		{"id": "SINNOH", "label": "Sinnoh"},
		{"id": "ALL", "label": "All"}
	]
	col_region_buttons.clear()
	for reg in col_regions:
		var btn_r = Button.new()
		btn_r.name = "BtnColRegion_" + reg["id"]
		btn_r.text = reg["label"]
		btn_r.custom_minimum_size = Vector2(0, 30)
		btn_r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_r.add_theme_font_size_override("font_size", 11)
		var rid = reg["id"]
		btn_r.pressed.connect(func(): _on_col_region_pressed(rid))
		col_region_tabs_row.add_child(btn_r)
		col_region_buttons[rid] = btn_r
	collection_grid_view.add_child(col_region_tabs_row)
	var stats_node = collection_grid_view.get_node_or_null("StatsLbl")
	if stats_node:
		collection_grid_view.move_child(col_region_tabs_row, stats_node.get_index() + 1)
		
	collection_filter_panel = PanelContainer.new()
	collection_filter_panel.name = "CollectionFilterPanel"
	var sb_panel = StyleBoxFlat.new()
	sb_panel.bg_color = Color(0.08, 0.11, 0.16, 0.95)
	sb_panel.border_color = Color(0.20, 0.32, 0.44, 0.85)
	sb_panel.set_border_width_all(1)
	sb_panel.set_corner_radius_all(6)
	sb_panel.content_margin_left = 6
	sb_panel.content_margin_right = 6
	sb_panel.content_margin_top = 6
	sb_panel.content_margin_bottom = 6
	collection_filter_panel.add_theme_stylebox_override("panel", sb_panel)
	
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collection_filter_panel.add_child(grid)
	
	# 1. Filtro Owned (Estado de posesión y Favoritos)
	opt_col_owned = OptionButton.new()
	opt_col_owned.name = "OptColOwned"
	opt_col_owned.add_item("📦 Status: All", 0)
	opt_col_owned.add_item("📦 Owned Only", 1)
	opt_col_owned.add_item("📦 Missing Only", 2)
	opt_col_owned.add_item("⭐ Favorites Only", 3)
	_style_filter_option(opt_col_owned)
	opt_col_owned.item_selected.connect(func(idx: int):
		match idx:
			1: col_filter_owned = "OWNED"
			2: col_filter_owned = "MISSING"
			3: col_filter_owned = "FAVORITES"
			_: col_filter_owned = "ALL"
		col_current_page = 0
		_update_filter_button_visuals()
		populate_collection_grid()
	)
	grid.add_child(opt_col_owned)
	
	# 2. Filtro Types (Tipos elementales)
	opt_col_type = OptionButton.new()
	opt_col_type.name = "OptColType"
	opt_col_type.add_item("⚡ Type: All", 0)
	opt_col_type.add_item("⚪ Normal", 1)
	opt_col_type.add_item("🌿 Grass", 2)
	opt_col_type.add_item("🔥 Fire", 3)
	opt_col_type.add_item("💧 Water", 4)
	opt_col_type.add_item("⚡ Electric", 5)
	opt_col_type.add_item("🌑 Dark", 6)
	opt_col_type.add_item("🔮 Psychic", 7)
	opt_col_type.add_item("🥊 Fighting", 8)
	opt_col_type.add_item("🏜️ Ground", 9)
	_style_filter_option(opt_col_type)
	var type_map = [
		"ALL", "NORMAL", "GRASS", "FIRE", "WATER",
		"ELECTRIC", "DARK", "PSYCHIC", "FIGHTING", "GROUND"
	]
	opt_col_type.item_selected.connect(func(idx: int):
		if idx >= 0 and idx < type_map.size():
			col_filter_type = type_map[idx]
		else:
			col_filter_type = "ALL"
		col_current_page = 0
		_update_filter_button_visuals()
		populate_collection_grid()
	)
	grid.add_child(opt_col_type)
	
	# 3. Filtro Stages (Fase evolutiva)
	opt_col_stage = OptionButton.new()
	opt_col_stage.name = "OptColStage"
	opt_col_stage.add_item("🧬 Stage: All", 0)
	opt_col_stage.add_item("🌱 Basic", 1)
	opt_col_stage.add_item("⚔️ Stage 1", 2)
	opt_col_stage.add_item("👑 Stage 2", 3)
	opt_col_stage.add_item("⭐ Legendary", 4)
	_style_filter_option(opt_col_stage)
	var stage_map = ["ALL", "BASIC", "STAGE 1", "STAGE 2", "LEGENDARY"]
	opt_col_stage.item_selected.connect(func(idx: int):
		if idx >= 0 and idx < stage_map.size():
			col_filter_stage = stage_map[idx]
		else:
			col_filter_stage = "ALL"
		col_current_page = 0
		_update_filter_button_visuals()
		populate_collection_grid()
	)
	grid.add_child(opt_col_stage)
	
	# 4. Filtro Rarity (Rareza)
	opt_col_rarity = OptionButton.new()
	opt_col_rarity.name = "OptColRarity"
	opt_col_rarity.add_item("✨ Rarity: All", 0)
	opt_col_rarity.add_item("⚪ Common", 1)
	opt_col_rarity.add_item("🔷 Rare", 2)
	opt_col_rarity.add_item("💜 Epic", 3)
	opt_col_rarity.add_item("👑 Legendary", 4)
	_style_filter_option(opt_col_rarity)
	var rarity_map = ["ALL", "COMMON", "RARE", "EPIC", "LEGENDARY"]
	opt_col_rarity.item_selected.connect(func(idx: int):
		if idx >= 0 and idx < rarity_map.size():
			col_filter_rarity = rarity_map[idx]
		else:
			col_filter_rarity = "ALL"
		col_current_page = 0
		_update_filter_button_visuals()
		populate_collection_grid()
	)
	grid.add_child(opt_col_rarity)
	
	# 5. Filtro Tier (Tier List competitiva)
	opt_col_tier = OptionButton.new()
	opt_col_tier.name = "OptColTier"
	opt_col_tier.add_item("🏆 Tier: All", 0)
	opt_col_tier.add_item("🔴 Tier S+", 1)
	opt_col_tier.add_item("🟠 Tier S", 2)
	opt_col_tier.add_item("🟣 Tier A", 3)
	opt_col_tier.add_item("🔵 Tier B", 4)
	opt_col_tier.add_item("🟢 Tier C", 5)
	opt_col_tier.add_item("⚪ Tier D", 6)
	_style_filter_option(opt_col_tier)
	var tier_map = ["ALL", "S+", "S", "A", "B", "C", "D"]
	opt_col_tier.item_selected.connect(func(idx: int):
		if idx >= 0 and idx < tier_map.size():
			col_filter_tier = tier_map[idx]
		else:
			col_filter_tier = "ALL"
		col_current_page = 0
		_update_filter_button_visuals()
		populate_collection_grid()
	)
	grid.add_child(opt_col_tier)
	
	# 6. Botón Clear Filters
	btn_col_reset_filters = Button.new()
	btn_col_reset_filters.name = "BtnColResetFilters"
	btn_col_reset_filters.text = "✕ Clear Filters"
	btn_col_reset_filters.custom_minimum_size = Vector2(0, 28)
	btn_col_reset_filters.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_col_reset_filters.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_col_reset_filters, Color(0.38, 0.20, 0.25), Color(0.65, 0.30, 0.38), false)
	btn_col_reset_filters.pressed.connect(_on_reset_collection_filters_pressed)
	grid.add_child(btn_col_reset_filters)
	
	# Insertar panel de filtros justo debajo de SortBar
	collection_grid_view.add_child(collection_filter_panel)
	var sort_node = collection_grid_view.get_node_or_null("SortBar")
	if sort_node:
		collection_grid_view.move_child(collection_filter_panel, sort_node.get_index() + 1)

func _style_filter_option(opt: OptionButton) -> void:
	opt.custom_minimum_size = Vector2(0, 28)
	opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opt.add_theme_font_size_override("font_size", 11)
	opt.focus_mode = Control.FOCUS_NONE
	
	var sb_normal = StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.10, 0.14, 0.20, 0.95)
	sb_normal.border_color = Color(0.24, 0.36, 0.48, 0.85)
	sb_normal.set_border_width_all(1)
	sb_normal.set_corner_radius_all(4)
	sb_normal.content_margin_left = 6
	sb_normal.content_margin_right = 6
	
	var sb_hover = StyleBoxFlat.new()
	sb_hover.bg_color = Color(0.15, 0.22, 0.32, 0.98)
	sb_hover.border_color = Color(0.40, 0.65, 0.88, 1.0)
	sb_hover.set_border_width_all(1)
	sb_hover.set_corner_radius_all(4)
	sb_hover.content_margin_left = 6
	sb_hover.content_margin_right = 6
	
	opt.add_theme_stylebox_override("normal", sb_normal)
	opt.add_theme_stylebox_override("hover", sb_hover)
	opt.add_theme_stylebox_override("pressed", sb_hover)
	opt.add_theme_stylebox_override("focus", sb_hover)

func _on_col_region_pressed(reg_id: String) -> void:
	col_filter_region = reg_id
	col_current_page = 0
	_update_col_region_buttons_ui()
	populate_collection_grid()

func _update_col_region_buttons_ui() -> void:
	if col_region_buttons.is_empty():
		return
	var totals = {"KANTO": 0, "JOHTO": 0, "HOENN": 0, "SINNOH": 0, "ALL": all_catalog_cards.size()}
	var owned = {"KANTO": 0, "JOHTO": 0, "HOENN": 0, "SINNOH": 0, "ALL": 0}
	for c in all_catalog_cards:
		var cid = int(c.get("id", 0))
		var is_unl = GameData.is_pokemon_unlocked(cid)
		if is_unl:
			owned["ALL"] += 1
		var cr = str(c.get("region", "Kanto")).strip_edges().to_upper()
		if cr == "":
			cr = "KANTO"
		if totals.has(cr):
			totals[cr] += 1
			if is_unl:
				owned[cr] += 1
	var reg_labels = {"KANTO": "Kanto", "JOHTO": "Johto", "HOENN": "Hoenn", "SINNOH": "Sinnoh", "ALL": "All"}
	for rk in col_region_buttons:
		var rbtn: Button = col_region_buttons[rk]
		rbtn.text = "%s (%d/%d)" % [reg_labels.get(rk, rk), owned.get(rk, 0), totals.get(rk, 0)]
		rbtn.modulate = Color(1.3, 1.25, 0.45) if rk == col_filter_region else Color(0.85, 0.85, 0.85)

func _update_filter_button_visuals() -> void:
	_update_col_region_buttons_ui()
	if opt_col_owned:
		opt_col_owned.modulate = Color(1.3, 1.25, 0.45) if col_filter_owned != "ALL" else Color.WHITE
	if opt_col_type:
		opt_col_type.modulate = Color(1.3, 1.25, 0.45) if col_filter_type != "ALL" else Color.WHITE
	if opt_col_stage:
		opt_col_stage.modulate = Color(1.3, 1.25, 0.45) if col_filter_stage != "ALL" else Color.WHITE
	if opt_col_rarity:
		opt_col_rarity.modulate = Color(1.3, 1.25, 0.45) if col_filter_rarity != "ALL" else Color.WHITE
	if opt_col_tier:
		opt_col_tier.modulate = Color(1.3, 1.25, 0.45) if col_filter_tier != "ALL" else Color.WHITE
	if btn_col_reset_filters:
		var any_active = (col_filter_owned != "ALL" or col_filter_type != "ALL" or col_filter_stage != "ALL" or col_filter_rarity != "ALL" or col_filter_tier != "ALL")
		btn_col_reset_filters.modulate = Color(1.3, 1.0, 1.0) if any_active else Color(0.75, 0.75, 0.75)

func _on_reset_collection_filters_pressed() -> void:
	col_current_page = 0
	col_filter_owned = "ALL"
	col_filter_type = "ALL"
	col_filter_stage = "ALL"
	col_filter_rarity = "ALL"
	col_filter_tier = "ALL"
	if opt_col_owned: opt_col_owned.select(0)
	if opt_col_type: opt_col_type.select(0)
	if opt_col_stage: opt_col_stage.select(0)
	if opt_col_rarity: opt_col_rarity.select(0)
	if opt_col_tier: opt_col_tier.select(0)
	_update_filter_button_visuals()
	populate_collection_grid()

func get_filtered_collection_cards() -> Array:
	var filtered: Array = []
	for card in all_catalog_cards:
		var cid = int(card["id"])
		var is_unlocked = GameData.is_pokemon_unlocked(cid)
		
		# 0. Filtro Region (Región Pokémon: Kanto, Johto, Hoenn, Sinnoh)
		if col_filter_region != "ALL":
			var c_region = str(card.get("region", "Kanto")).strip_edges().to_upper()
			if c_region == "":
				c_region = "KANTO"
			if c_region != col_filter_region:
				continue
				
		# 1. Filtro Owned (Estado de posesión y Favoritos)
		if col_filter_owned == "OWNED" and not is_unlocked:
			continue
		elif col_filter_owned == "MISSING" and is_unlocked:
			continue
		elif col_filter_owned == "FAVORITES" and not GameData.is_pokemon_favorite(cid):
			continue
			
		# 2. Filtro Types (Tipo elemental)
		if col_filter_type != "ALL":
			var c_type = str(card.get("type", "")).strip_edges().to_upper()
			if c_type != col_filter_type:
				continue
				
		# 3. Filtro Stages (Fase evolutiva)
		if col_filter_stage != "ALL":
			var c_stage = str(card.get("stage", "")).strip_edges().to_lower()
			var c_rarity_chk = str(card.get("rarity", "")).strip_edges().to_lower()
			if col_filter_stage == "LEGENDARY":
				if not (c_stage in ["legendary", "legendaria"] or c_rarity_chk in ["legendary", "legendaria", "ur"]):
					continue
			elif c_stage != col_filter_stage.to_lower():
				continue
				
		# 4. Filtro Rarity (Rareza)
		if col_filter_rarity != "ALL":
			var c_rarity = str(card.get("rarity", "")).strip_edges().to_lower()
			match col_filter_rarity:
				"COMMON":
					if not (c_rarity in ["common", "comun", "común", "initial"]):
						continue
				"RARE":
					if not (c_rarity in ["rare", "rara", "raro", "uncommon"]):
						continue
				"EPIC":
					if not (c_rarity in ["epic", "epica", "epico"]):
						continue
				"LEGENDARY":
					if not (c_rarity in ["legendary", "legendaria", "legendario", "ur"]):
						continue
						
		# 5. Filtro Tier (Tier list competitiva)
		if col_filter_tier != "ALL":
			var c_tier = str(card.get("tier", "C")).strip_edges().to_upper()
			if c_tier == "":
				c_tier = "C"
			if c_tier != col_filter_tier:
				continue
				
		filtered.append(card)
	return filtered

func populate_collection_grid() -> void:
	if not grid_cards:
		return
	for c in grid_cards.get_children():
		c.queue_free()
		
	var unlocked_count = 0
	for card in all_catalog_cards:
		var cid = int(card["id"])
		if GameData.is_pokemon_unlocked(cid):
			unlocked_count += 1
			
	var filtered_cards = get_filtered_collection_cards()
	current_sorted_collection = get_sorted_cards(filtered_cards, collection_sort_mode)
	_update_col_region_buttons_ui()

	var is_filtered = (col_filter_region != "ALL" or col_filter_owned != "ALL" or col_filter_type != "ALL" or col_filter_stage != "ALL" or col_filter_rarity != "ALL" or col_filter_tier != "ALL")
	if collection_stats_lbl:
		if is_filtered:
			collection_stats_lbl.text = "Showing: %d / %d cards  |  Collected: %d / %d" % [
				current_sorted_collection.size(),
				all_catalog_cards.size(),
				unlocked_count,
				all_catalog_cards.size()
			]
		else:
			collection_stats_lbl.text = "Cards Collected: %d / %d" % [unlocked_count, all_catalog_cards.size()]

	var total_cards = current_sorted_collection.size()
	var total_pages = int(ceil(float(total_cards) / float(COL_CARDS_PER_PAGE)))
	if total_pages < 1:
		total_pages = 1
	col_current_page = clampi(col_current_page, 0, total_pages - 1)

	if current_sorted_collection.is_empty():
		_render_collection_pagination(0, 0, 0, 1)
		var empty_box = CenterContainer.new()
		empty_box.custom_minimum_size = Vector2(480, 220)
		empty_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var empty_lbl = Label.new()
		empty_lbl.text = "🔍 No Pokémon match the selected filters.\nTry resetting or changing your filter criteria."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 13)
		empty_lbl.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85))
		empty_box.add_child(empty_lbl)
		grid_cards.add_child(empty_box)
		return

	var start_idx = col_current_page * COL_CARDS_PER_PAGE
	var end_idx = min(start_idx + COL_CARDS_PER_PAGE, total_cards)
	_render_collection_pagination(total_cards, start_idx, end_idx, total_pages)

	for i in range(start_idx, end_idx):
		var card = current_sorted_collection[i]
		var cid = int(card["id"])
		var is_unlocked = GameData.is_pokemon_unlocked(cid)
		var p_num = str(card.get("pokedex_num", "1")).pad_zeros(3)

		var cell_vbox = VBoxContainer.new()
		cell_vbox.custom_minimum_size = Vector2(110, 185)
		cell_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell_vbox.add_theme_constant_override("separation", 4)
		cell_vbox.alignment = BoxContainer.ALIGNMENT_BEGIN

		# 1. Miniatura de la carta
		var thumb_btn = Button.new()
		thumb_btn.custom_minimum_size = Vector2(110, 150)
		thumb_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		thumb_btn.focus_mode = Control.FOCUS_NONE
		thumb_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		if is_unlocked:
			# Si la tienes: fondo temático elemental con el sprite limpio del Pokémon
			var type_key = str(card.get("type", "NORMAL")).to_upper()
			var theme = AssembledCardScript.TYPE_THEMES.get(type_key, AssembledCardScript.TYPE_THEMES["NORMAL"])

			var sb_normal = StyleBoxFlat.new()
			sb_normal.bg_color = theme["bg"]
			sb_normal.border_color = theme["border"]
			sb_normal.set_border_width_all(2)
			sb_normal.set_corner_radius_all(6)

			var sb_hover = StyleBoxFlat.new()
			sb_hover.bg_color = theme["bg"].lightened(0.18)
			sb_hover.border_color = theme["border"].lightened(0.25)
			sb_hover.set_border_width_all(3)
			sb_hover.set_corner_radius_all(6)

			thumb_btn.add_theme_stylebox_override("normal", sb_normal)
			thumb_btn.add_theme_stylebox_override("hover", sb_hover)
			thumb_btn.add_theme_stylebox_override("pressed", sb_hover)
			thumb_btn.text = ""

			# Cargar el sprite limpio del Pokémon centrado en la miniatura
			var tex_file = str(card.get("texture_path", card.get("texture_file", "")))
			var pkmn_tex = GameData.get_pokemon_texture(tex_file)
			thumb_btn.icon = pkmn_tex
			thumb_btn.expand_icon = true
			thumb_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			thumb_btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER

			# Badge de Stock / Cantidad de copias (x1, x2, x3...)
			var stock = GameData.get_card_stock(cid)
			var stock_badge = PanelContainer.new()
			stock_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			stock_badge.position = Vector2(72, 5)
			stock_badge.custom_minimum_size = Vector2(32, 20)

			var sb_badge = StyleBoxFlat.new()
			sb_badge.set_corner_radius_all(4)
			sb_badge.bg_color = Color(0, 0, 0, 0.82)
			sb_badge.border_color = Color("#FFD700") if stock > 1 else Color(1, 1, 1, 0.45)
			sb_badge.set_border_width_all(1)
			stock_badge.add_theme_stylebox_override("panel", sb_badge)

			var stock_lbl = Label.new()
			stock_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			stock_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			stock_lbl.add_theme_font_size_override("font_size", 10)
			stock_lbl.add_theme_color_override("font_color", Color("#FFE066") if stock > 1 else Color("#E2E8F0"))
			stock_lbl.text = "x%d" % stock
			stock_badge.add_child(stock_lbl)
			thumb_btn.add_child(stock_badge)

			# Badge flotante de Tier en la esquina superior izquierda
			var tier_val = str(card.get("tier", "C")).strip_edges().to_upper()
			if tier_val == "":
				tier_val = "C"
			var t_color = GameData.get_tier_color(tier_val)
			var tier_thumb_badge = PanelContainer.new()
			tier_thumb_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tier_thumb_badge.position = Vector2(5, 5)
			tier_thumb_badge.custom_minimum_size = Vector2(26, 20)

			var sb_tb = StyleBoxFlat.new()
			sb_tb.set_corner_radius_all(4)
			sb_tb.bg_color = Color(0, 0, 0, 0.85)
			sb_tb.border_color = t_color
			sb_tb.set_border_width_all(1)
			tier_thumb_badge.add_theme_stylebox_override("panel", sb_tb)

			var tb_lbl = Label.new()
			tb_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tb_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			tb_lbl.add_theme_font_size_override("font_size", 9)
			tb_lbl.add_theme_color_override("font_color", t_color)
			tb_lbl.text = tier_val
			tier_thumb_badge.add_child(tb_lbl)
			thumb_btn.add_child(tier_thumb_badge)

			# Marcador de Favoritos (⭐) interactivo en la miniatura
			var is_fav = GameData.is_pokemon_favorite(cid)
			var fav_btn = Button.new()
			fav_btn.custom_minimum_size = Vector2(24, 20)
			fav_btn.position = Vector2(36, 5)
			fav_btn.focus_mode = Control.FOCUS_NONE
			fav_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			fav_btn.text = "⭐" if is_fav else "☆"
			fav_btn.tooltip_text = "Favorite"
			fav_btn.add_theme_font_size_override("font_size", 10)

			var sb_fav = StyleBoxFlat.new()
			sb_fav.set_corner_radius_all(4)
			sb_fav.bg_color = Color(0, 0, 0, 0.85) if is_fav else Color(0, 0, 0, 0.45)
			sb_fav.border_color = Color("#FFD700") if is_fav else Color(1, 1, 1, 0.3)
			sb_fav.set_border_width_all(1)
			fav_btn.add_theme_stylebox_override("normal", sb_fav)
			fav_btn.add_theme_stylebox_override("hover", sb_fav)
			fav_btn.add_theme_stylebox_override("pressed", sb_fav)

			fav_btn.pressed.connect(func():
				if GameData.is_drag_scrolling():
					return
				var new_state = GameData.toggle_pokemon_favorite(cid)
				GameData.save_profile()
				fav_btn.text = "⭐" if new_state else "☆"
				sb_fav.bg_color = Color(0, 0, 0, 0.85) if new_state else Color(0, 0, 0, 0.45)
				sb_fav.border_color = Color("#FFD700") if new_state else Color(1, 1, 1, 0.3)
				if col_filter_owned == "FAVORITES":
					populate_collection_grid()
			)
			thumb_btn.add_child(fav_btn)

			# Efecto Foil Holográfico en la miniatura de cartas Raras/Épicas/Legendarias
			GameData.apply_foil_overlay(thumb_btn, str(card.get("rarity", "Common")))
		else:
			# Si no la tienes: miniatura oscura de misterio con '?'
			var sb_locked = StyleBoxFlat.new()
			sb_locked.bg_color = Color("#141820")
			sb_locked.border_color = Color("#2d3748")
			sb_locked.set_border_width_all(2)
			sb_locked.set_corner_radius_all(6)

			var sb_locked_hover = StyleBoxFlat.new()
			sb_locked_hover.bg_color = Color("#1c222e")
			sb_locked_hover.border_color = Color("#4a5568")
			sb_locked_hover.set_border_width_all(2)
			sb_locked_hover.set_corner_radius_all(6)

			thumb_btn.add_theme_stylebox_override("normal", sb_locked)
			thumb_btn.add_theme_stylebox_override("hover", sb_locked_hover)
			thumb_btn.add_theme_stylebox_override("pressed", sb_locked_hover)
			thumb_btn.text = "?"
			thumb_btn.add_theme_font_size_override("font_size", 22)
			thumb_btn.add_theme_color_override("font_color", Color("#4a5568"))

		var card_idx = i
		thumb_btn.pressed.connect(func():
			if GameData.is_drag_scrolling():
				return
			open_collection_detail(card_idx)
		)
		cell_vbox.add_child(thumb_btn)

		# 2. Etiqueta inferior con número Pokédex y nombre (o ??? si está bloqueada)
		var lbl = Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		if is_unlocked:
			var s_name = str(card.get("short_name", card.get("name", "PKMN")))
			lbl.text = "#%s\n%s" % [p_num, s_name]
			lbl.add_theme_color_override("font_color", Color("#e2e8f0"))
		else:
			lbl.text = "#%s\n???" % p_num
			lbl.add_theme_color_override("font_color", Color("#718096"))

		cell_vbox.add_child(lbl)
		grid_cards.add_child(cell_vbox)

func _render_collection_pagination(total_cards: int, start_idx: int, end_idx: int, total_pages: int) -> void:
	if not col_pagination_bar:
		col_pagination_bar = PanelContainer.new()
		col_pagination_bar.name = "ColPaginationBar"
		var sb_p = StyleBoxFlat.new()
		sb_p.bg_color = Color(0.06, 0.09, 0.14, 0.95)
		sb_p.border_color = Color(0.20, 0.32, 0.44, 0.8)
		sb_p.set_border_width_all(1)
		sb_p.set_corner_radius_all(6)
		sb_p.content_margin_left = 6
		sb_p.content_margin_right = 6
		sb_p.content_margin_top = 4
		sb_p.content_margin_bottom = 4
		col_pagination_bar.add_theme_stylebox_override("panel", sb_p)
		collection_grid_view.add_child(col_pagination_bar)
		var scroll_node = collection_grid_view.get_node_or_null("GridScroll")
		if scroll_node:
			collection_grid_view.move_child(col_pagination_bar, scroll_node.get_index())
		
	if total_pages <= 1:
		col_pagination_bar.visible = false
		return
	col_pagination_bar.visible = true
		
	for c in col_pagination_bar.get_children():
		c.queue_free()
		
	var bar_vbox = VBoxContainer.new()
	bar_vbox.add_theme_constant_override("separation", 3)
	bar_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col_pagination_bar.add_child(bar_vbox)
		
	var nav_hbox = HBoxContainer.new()
	nav_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	nav_hbox.add_theme_constant_override("separation", 6)
	nav_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar_vbox.add_child(nav_hbox)
		
	var btn_prev = Button.new()
	btn_prev.text = "◀ Ant"
	btn_prev.custom_minimum_size = Vector2(56, 26)
	btn_prev.add_theme_font_size_override("font_size", 10)
	btn_prev.disabled = (col_current_page <= 0)
	_apply_retro_button_style(btn_prev, Color(0.18, 0.24, 0.34), Color(0.28, 0.38, 0.52), btn_prev.disabled)
	btn_prev.pressed.connect(func():
		if col_current_page > 0:
			col_current_page -= 1
			populate_collection_grid()
			if col_grid_scroll:
				col_grid_scroll.scroll_vertical = 0
	)
	nav_hbox.add_child(btn_prev)
		
	var scroll_tabs = ScrollContainer.new()
	scroll_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_tabs.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_tabs.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll_tabs.custom_minimum_size = Vector2(0, 30)
		
	var tabs_hbox = HBoxContainer.new()
	tabs_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_hbox.add_theme_constant_override("separation", 4)
	tabs_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_tabs.add_child(tabs_hbox)
	nav_hbox.add_child(scroll_tabs)
		
	for p in range(total_pages):
		var btn_p = Button.new()
		btn_p.text = "Pág %d" % (p + 1)
		btn_p.custom_minimum_size = Vector2(48, 24)
		btn_p.add_theme_font_size_override("font_size", 10)
		var is_active = (p == col_current_page)
		if is_active:
			_apply_retro_button_style(btn_p, Color(0.65, 0.48, 0.12), Color(0.95, 0.78, 0.22), false)
			btn_p.modulate = Color(1.3, 1.25, 0.45)
		else:
			_apply_retro_button_style(btn_p, Color(0.16, 0.22, 0.30), Color(0.28, 0.38, 0.50), false)
			btn_p.modulate = Color(0.85, 0.85, 0.85)
		var page_num = p
		btn_p.pressed.connect(func():
			col_current_page = page_num
			populate_collection_grid()
			if col_grid_scroll:
				col_grid_scroll.scroll_vertical = 0
		)
		tabs_hbox.add_child(btn_p)
		
	var btn_next = Button.new()
	btn_next.text = "Sig ▶"
	btn_next.custom_minimum_size = Vector2(56, 26)
	btn_next.add_theme_font_size_override("font_size", 10)
	btn_next.disabled = (col_current_page >= total_pages - 1)
	_apply_retro_button_style(btn_next, Color(0.18, 0.24, 0.34), Color(0.28, 0.38, 0.52), btn_next.disabled)
	btn_next.pressed.connect(func():
		if col_current_page < total_pages - 1:
			col_current_page += 1
			populate_collection_grid()
			if col_grid_scroll:
				col_grid_scroll.scroll_vertical = 0
	)
	nav_hbox.add_child(btn_next)
		
	var info_lbl = Label.new()
	info_lbl.text = "Página %d de %d  (Mostrando %d-%d de %d cartas)" % [col_current_page + 1, total_pages, start_idx + 1, end_idx, total_cards]
	info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_lbl.add_theme_font_size_override("font_size", 9)
	info_lbl.add_theme_color_override("font_color", Color("#90A4AE"))
	bar_vbox.add_child(info_lbl)

func open_collection_detail(index: int) -> void:
	current_collection_index = index
	collection_grid_view.visible = false
	collection_detail_view.visible = true
	show_collection_card(current_collection_index)

func _on_back_to_grid_pressed() -> void:
	collection_detail_view.visible = false
	collection_grid_view.visible = true
	var target_page = int(current_collection_index / COL_CARDS_PER_PAGE)
	if target_page != col_current_page:
		col_current_page = target_page
		populate_collection_grid()

func show_collection_card(index: int) -> void:
	if current_sorted_collection.is_empty():
		current_sorted_collection = get_sorted_cards(all_catalog_cards, collection_sort_mode)
	if current_sorted_collection.is_empty():
		return
	if index < 0 or index >= current_sorted_collection.size():
		return
	var card = current_sorted_collection[index]
	var cid = int(card["id"])
	var is_unlocked = GameData.is_pokemon_unlocked(cid)
	var p_num = str(card.get("pokedex_num", "1")).pad_zeros(3)
	
	# 1. Ensamble dinámico de la carta (desbloqueada o misterio)
	if assembled_card:
		assembled_card.setup(card, is_unlocked)
		
	# Botón interactivo de Favorito en TopNav
	if btn_col_fav_toggle == null:
		var top_nav = get_node_or_null("CollectionModal/DetailView/TopNav")
		if top_nav:
			btn_col_fav_toggle = Button.new()
			btn_col_fav_toggle.name = "BtnDetailFavToggle"
			btn_col_fav_toggle.custom_minimum_size = Vector2(150, 36)
			btn_col_fav_toggle.add_theme_font_size_override("font_size", 12)
			top_nav.add_child(btn_col_fav_toggle)
			top_nav.move_child(btn_col_fav_toggle, 1)
			
	if btn_col_fav_toggle:
		if is_unlocked:
			btn_col_fav_toggle.visible = true
			var is_fav = GameData.is_pokemon_favorite(cid)
			_update_detail_fav_button_visuals(is_fav)
			for conn in btn_col_fav_toggle.pressed.get_connections():
				btn_col_fav_toggle.pressed.disconnect(conn["callable"])
			btn_col_fav_toggle.pressed.connect(func():
				var new_state = GameData.toggle_pokemon_favorite(cid)
				GameData.save_profile()
				_update_detail_fav_button_visuals(new_state)
				if col_filter_owned == "FAVORITES":
					populate_collection_grid()
			)
		else:
			btn_col_fav_toggle.visible = false
		
	# 2. Panel lateral con desglose
	if is_unlocked:
		var type_key = str(card.get("type", "NORMAL")).to_upper()
		var theme = AssembledCardScript.TYPE_THEMES.get(type_key, AssembledCardScript.TYPE_THEMES["NORMAL"])
		var stage_raw = str(card.get("stage", "Basic"))
		
		if locked_notice_panel:
			locked_notice_panel.visible = false
			
		detail_type_icon.visible = true
		detail_type_icon.texture = GameData.get_type_icon_texture(type_key)
		detail_name.text = str(card.get("short_name", "PKMN"))
		var r_info = GameData.get_rarity_display_info(str(card.get("rarity", "Common")))
		var stock = GameData.get_card_stock(cid)
		var tier_str = str(card.get("tier", "C")).strip_edges().to_upper()
		if tier_str == "":
			tier_str = "C"
		detail_sub.text = "No. %s • Stage: %s • %s Type • %s %s • [Tier %s] • Copies: x%d" % [p_num, stage_raw, theme["name"], r_info.get("stars", "⭐"), r_info.get("name", "Common"), tier_str, stock]
		
		stats_panel.visible = true
		var evo_target = str(card.get("evolves_to", "")).strip_edges()
		var req_exp_val = GameData.get_pokemon_required_exp(int(card.get("id", -1)))
		var evo_suffix = ("  |  ⏫ Evolves to %s (%d EXP)" % [evo_target, req_exp_val]) if (evo_target != "" and req_exp_val > 0) else ""
		stats_hp.text = "❤️ Max HP: %d HP%s" % [int(card.get("hp", 10)), evo_suffix]
		stats_spd.text = "👟 Speed: %d SPD (Determines turn order)" % int(card.get("speed", 1))
		stats_energy.text = "🔋 Recovery: +%d EN / turn (Max: %d)  |  🏆 Rank: Tier %s" % [int(card.get("recover", 1)), int(card.get("energy", 3)), tier_str]
		
		var weak_key = str(card.get("weakness", "NONE")).to_upper()
		if weak_key != "NONE" and GameData.TYPE_ICON_FILES.has(weak_key):
			deb_row.visible = true
			deb_icon.visible = true
			deb_icon.texture = GameData.get_type_icon_texture(weak_key)
			deb_val.text = "%s (+2 damage taken)" % weak_key
		else:
			deb_row.visible = true
			deb_icon.visible = false
			deb_val.text = "None"
			
		var card_type = GameData.normalize_type_key(str(card.get("type", "NORMAL")))
		var eff_resists = GameData.get_effective_resistances(card_type, str(card.get("resistant", "NONE")))
		if not eff_resists.is_empty():
			res_row.visible = true
			res_icon.visible = true
			res_icon.texture = GameData.get_type_icon_texture(eff_resists[0])
			var res_desc_list = []
			for r in eff_resists:
				if r == card_type:
					res_desc_list.append("%s (Natural)" % r)
				else:
					res_desc_list.append(r)
			res_val.text = "%s (-2 damage taken)" % ", ".join(res_desc_list)
		else:
			res_row.visible = true
			res_icon.visible = false
			res_val.text = "None"
			
		# Pasiva
		var pas_name = str(card.get("passive_name", "")).strip_edges()
		var pas_desc = str(card.get("passive_desc", "")).strip_edges()
		if pas_name != "":
			passive_panel.visible = true
			passive_title.text = "✨ Passive: %s" % pas_name
			passive_desc.text = pas_desc
		else:
			passive_panel.visible = false
			
		# Movimiento 1 con Icono Oficial
		move1_panel.visible = true
		var m1_name_val = str(card.get("m1_name", "Attack 1"))
		var m1_dmg_val = int(card.get("m1_dmg", 0))
		var m1_type_val = str(card.get("m1_type", "NORMAL")).to_upper()
		var m1_cost_val = int(card.get("m1_cost", 1))
		var m1_req_val = int(card.get("m1_req", 0))
		var m1_desc_val = str(card.get("m1_effect", "")).strip_edges()
		
		m1_type_icon.visible = true
		m1_type_icon.texture = GameData.get_type_icon_texture(m1_type_val)
		m1_title.text = "%s (%d DMG)" % [m1_name_val, m1_dmg_val]
		var req_text1 = (" | Req: %d EN" % m1_req_val) if m1_req_val > m1_cost_val else ""
		m1_sub.text = "Type: %s | Cost: ⚡ %d%s" % [m1_type_val, m1_cost_val, req_text1]
		m1_desc.text = m1_desc_val if m1_desc_val != "" else "Basic attack with no secondary effect."
		
		# Movimiento 2 con Icono Oficial
		move2_panel.visible = true
		var m2_name_val = str(card.get("m2_name", "Attack 2"))
		var m2_dmg_val = int(card.get("m2_dmg", 0))
		var m2_type_val = str(card.get("m2_type", "NORMAL")).to_upper()
		var m2_cost_val = int(card.get("m2_cost", 1))
		var m2_req_val = int(card.get("m2_req", 0))
		var m2_bcost = int(card.get("m2_boost_cost", 0))
		var m2_bdmg = int(card.get("m2_boost_dmg", 0))
		var m2_desc_val = str(card.get("m2_effect", "")).strip_edges()
		
		m2_type_icon.visible = true
		m2_type_icon.texture = GameData.get_type_icon_texture(m2_type_val)
		m2_title.text = "%s (%d DMG)" % [m2_name_val, m2_dmg_val]
		var req_text2 = (" | Req: %d EN" % m2_req_val) if m2_req_val > m2_cost_val else ""
		m2_sub.text = "Type: %s | Cost: ⚡ %d%s" % [m2_type_val, m2_cost_val, req_text2]
		if m2_bcost > 0:
			m2_boost.visible = true
			var boost_txt = GameData.format_move_boost_summary(m2_bcost, m2_bdmg, str(card.get("m2_effect_type", "")), m2_desc_val)
			m2_boost.text = "🔥 Boost (+%d⚡): %s" % [m2_bcost, boost_txt]
		else:
			m2_boost.visible = false
		m2_desc.text = m2_desc_val if m2_desc_val != "" else "Secondary attack."
	else:
		# Si NO la tienes: solo número en Pokédex y ??? en los datos
		if locked_notice_panel:
			locked_notice_panel.visible = true
			
		detail_type_icon.visible = false
		detail_type_icon.texture = null
		detail_name.text = "???"
		detail_sub.text = "No. %s • Stage: ??? • Type: ???" % p_num
		
		stats_panel.visible = true
		stats_hp.text = "❤️ Max HP: ??? HP"
		stats_spd.text = "👟 Speed: ??? SPD"
		stats_energy.text = "🔋 Recovery: ??? EN / turn"
		
		deb_row.visible = true
		deb_icon.visible = false
		deb_val.text = "???"
		
		res_row.visible = true
		res_icon.visible = false
		res_val.text = "???"
		
		passive_panel.visible = true
		passive_title.text = "✨ Passive Ability"
		passive_desc.text = "???"
		
		move1_panel.visible = true
		m1_type_icon.visible = false
		m1_type_icon.texture = null
		m1_title.text = "??? (?? DMG)"
		m1_sub.text = "Type: ??? | Cost: ⚡ ?"
		m1_desc.text = "Move data not discovered."
		
		move2_panel.visible = true
		m2_type_icon.visible = false
		m2_type_icon.texture = null
		m2_title.text = "??? (?? DMG)"
		m2_sub.text = "Type: ??? | Cost: ⚡ ?"
		m2_boost.visible = false
		m2_desc.text = "Move data not discovered."
		
	# 3. Actualizar página y botones
	collection_page_lbl.text = "%d / %d" % [index + 1, current_sorted_collection.size()]

func _update_detail_fav_button_visuals(is_fav: bool) -> void:
	if not btn_col_fav_toggle:
		return
	if is_fav:
		btn_col_fav_toggle.text = "⭐ Favorited"
		_apply_retro_button_style(btn_col_fav_toggle, Color(0.85, 0.70, 0.15), Color(1.0, 0.85, 0.25))
	else:
		btn_col_fav_toggle.text = "☆ Add to Favorites"
		_apply_retro_button_style(btn_col_fav_toggle, Color(0.25, 0.40, 0.55), Color(0.35, 0.55, 0.75))

func _on_prev_card_pressed() -> void:
	if current_sorted_collection.is_empty():
		return
	current_collection_index = (current_collection_index - 1 + current_sorted_collection.size()) % current_sorted_collection.size()
	show_collection_card(current_collection_index)

func _on_next_card_pressed() -> void:
	if current_sorted_collection.is_empty():
		return
	current_collection_index = (current_collection_index + 1) % current_sorted_collection.size()
	show_collection_card(current_collection_index)

# --- AJUSTES Y AUDIO ---
var _last_sfx_preview_time: int = 0

func _apply_audio_settings() -> void:
	if language_option:
		var target_idx = 1 if GameData.settings_language == "es" else 0
		if language_option.selected != target_idx:
			language_option.select(target_idx)
	if bgm_player:
		bgm_player.volume_db = GameData.get_music_db()
	if music_slider:
		music_slider.set_value_no_signal(GameData.settings_music_volume)
	if music_vol_value_lbl:
		music_vol_value_lbl.text = "%d%%" % int(GameData.settings_music_volume * 100.0)
	if mute_music_check:
		mute_music_check.set_pressed_no_signal(GameData.settings_music_muted)
		
	if sfx_slider:
		sfx_slider.set_value_no_signal(GameData.settings_sfx_volume)
	if sfx_vol_value_lbl:
		sfx_vol_value_lbl.text = "%d%%" % int(GameData.settings_sfx_volume * 100.0)
	if mute_sfx_check:
		mute_sfx_check.set_pressed_no_signal(GameData.settings_sfx_muted)

func _on_language_option_selected(index: int) -> void:
	var new_lang = "es" if index == 1 else "en"
	GameData.set_language(new_lang)
	GameData.play_combat_sfx("hit_normal")

func _on_language_changed(_new_lang: String) -> void:
	if language_option:
		var target_idx = 1 if GameData.settings_language == "es" else 0
		if language_option.selected != target_idx:
			language_option.select(target_idx)
	if _pending_tutorial_after_settings and btn_close_settings:
		btn_close_settings.text = "🌟 Continuar al Tutorial ➡️" if GameData.is_spanish() else "🌟 Continue to Tutorial ➡️"
	_update_lobby_header_badge()
	if info_version_lbl:
		info_version_lbl.text = "Version: %s • Pokémon Battle Frontier" % GameData.GAME_VERSION
	GameData.apply_language_to_scene_tree()

func _on_music_slider_changed(value: float) -> void:
	GameData.settings_music_volume = value
	if music_vol_value_lbl:
		music_vol_value_lbl.text = "%d%%" % int(value * 100.0)
	_apply_audio_settings()
	GameData.save_profile()

func _on_mute_music_toggled(pressed: bool) -> void:
	GameData.settings_music_muted = pressed
	_apply_audio_settings()
	GameData.save_profile()

func _on_sfx_slider_changed(value: float) -> void:
	GameData.settings_sfx_volume = value
	if sfx_vol_value_lbl:
		sfx_vol_value_lbl.text = "%d%%" % int(value * 100.0)
	_apply_audio_settings()
	GameData.save_profile()
	
	var now = Time.get_ticks_msec()
	if now - _last_sfx_preview_time > 180 and not GameData.settings_sfx_muted and value > 0.01:
		_last_sfx_preview_time = now
		GameData.play_combat_sfx("hit_normal")

func _on_mute_sfx_toggled(pressed: bool) -> void:
	GameData.settings_sfx_muted = pressed
	_apply_audio_settings()
	GameData.save_profile()
	if not pressed and GameData.settings_sfx_volume > 0.01:
		GameData.play_combat_sfx("hit_normal")

func _on_settings_pressed() -> void:
	_apply_audio_settings()
	if info_version_lbl:
		info_version_lbl.text = "Version: %s • Pokémon Battle Frontier" % GameData.GAME_VERSION
	settings_modal.visible = true

# ==============================================================================
# --- SISTEMA DE ACTUALIZACIONES (UPDATER LEVEL 1 - GITHUB RELEASES) ---
# ==============================================================================

func _compare_versions(v1_str: String, v2_str: String) -> int:
	var v1_clean = v1_str.strip_edges().trim_prefix("v").trim_prefix("V")
	var v2_clean = v2_str.strip_edges().trim_prefix("v").trim_prefix("V")
	
	var v1_base = v1_clean.split("-")[0].split("+")[0]
	var v2_base = v2_clean.split("-")[0].split("+")[0]
	
	var parts1 = v1_base.split(".")
	var parts2 = v2_base.split(".")
	
	var max_len = max(parts1.size(), parts2.size())
	for i in range(max_len):
		var num1 = int(parts1[i]) if i < parts1.size() else 0
		var num2 = int(parts2[i]) if i < parts2.size() else 0
		if num1 > num2:
			return 1
		elif num1 < num2:
			return -1
	return 0

func _format_file_size(bytes: int) -> String:
	if bytes <= 0:
		return ""
	if bytes < 1024 * 1024:
		return "%.1f KB" % (float(bytes) / 1024.0)
	return "%.1f MB" % (float(bytes) / (1024.0 * 1024.0))

func _on_check_update_pressed() -> void:
	if btn_check_update:
		btn_check_update.disabled = true
	if update_status_lbl:
		update_status_lbl.visible = true
		update_status_lbl.text = "⏳ Checking GitHub for updates..."
		update_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 1))
	
	var http = HTTPRequest.new()
	http.name = "UpdateCheckerHTTP"
	add_child(http)
	http.request_completed.connect(_on_update_http_completed.bind(http))
	
	var url = "https://api.github.com/repos/yodef/PKMN-Battle-Frontier/releases/latest"
	var headers = [
		"User-Agent: PKMN-Battle-Frontier-App",
		"Accept: application/vnd.github.v3+json"
	]
	var err = http.request(url, headers)
	if err != OK:
		if btn_check_update:
			btn_check_update.disabled = false
		if update_status_lbl:
			update_status_lbl.text = "⚠️ Could not start update request (Error %d)." % err
			update_status_lbl.add_theme_color_override("font_color", Color(1, 0.45, 0.45, 1))
		http.queue_free()

func _on_update_http_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http_node: HTTPRequest) -> void:
	if is_instance_valid(http_node):
		http_node.queue_free()
	if btn_check_update:
		btn_check_update.disabled = false
		
	if result != HTTPRequest.RESULT_SUCCESS:
		if update_status_lbl:
			update_status_lbl.visible = true
			if GameData.update_direct_fallback_url != "":
				update_status_lbl.text = "⚠️ Network error. Fallback URL available."
			else:
				update_status_lbl.text = "⚠️ Network error while checking for updates."
			update_status_lbl.add_theme_color_override("font_color", Color(1, 0.45, 0.45, 1))
		return
		
	if response_code == 404:
		if update_status_lbl:
			update_status_lbl.visible = true
			update_status_lbl.text = "✅ Your game is up to date! (%s)\n(No newer releases found online)" % GameData.GAME_VERSION
			update_status_lbl.add_theme_color_override("font_color", Color(0.3, 1, 0.45, 1))
		return
		
	if response_code != 200:
		if update_status_lbl:
			update_status_lbl.visible = true
			update_status_lbl.text = "⚠️ Server responded with HTTP code %d." % response_code
			update_status_lbl.add_theme_color_override("font_color", Color(1, 0.7, 0.3, 1))
		return
		
	var body_text = body.get_string_from_utf8()
	var json = JSON.new()
	var parse_err = json.parse(body_text)
	if parse_err != OK or not (json.data is Dictionary):
		if update_status_lbl:
			update_status_lbl.visible = true
			update_status_lbl.text = "⚠️ Could not parse release information."
			update_status_lbl.add_theme_color_override("font_color", Color(1, 0.45, 0.45, 1))
		return
		
	var release_data: Dictionary = json.data
	var tag_name: String = str(release_data.get("tag_name", "")).strip_edges()
	
	if tag_name.is_empty():
		if update_status_lbl:
			update_status_lbl.visible = true
			update_status_lbl.text = "✅ Your game is up to date! (%s)" % GameData.GAME_VERSION
			update_status_lbl.add_theme_color_override("font_color", Color(0.3, 1, 0.45, 1))
		return
		
	var comp = _compare_versions(tag_name, GameData.GAME_VERSION)
	if comp > 0:
		if update_status_lbl:
			update_status_lbl.visible = true
			update_status_lbl.text = "🎉 New update available: %s!" % tag_name
			update_status_lbl.add_theme_color_override("font_color", Color(0.35, 0.85, 1, 1))
		_show_update_modal(release_data)
	else:
		if update_status_lbl:
			update_status_lbl.visible = true
			update_status_lbl.text = "✅ Your game is up to date! (%s)" % GameData.GAME_VERSION
			update_status_lbl.add_theme_color_override("font_color", Color(0.3, 1, 0.45, 1))

func _show_update_modal(release_data: Dictionary) -> void:
	_latest_release_info = release_data
	var tag_name: String = str(release_data.get("tag_name", ""))
	var rel_name: String = str(release_data.get("name", ""))
	var body_txt: String = str(release_data.get("body", ""))
	
	if update_title:
		update_title.text = "🚀 NEW UPDATE AVAILABLE!"
	if update_subtitle:
		var display_title = rel_name if not rel_name.is_empty() else tag_name
		update_subtitle.text = "%s (Installed: %s)" % [display_title, GameData.GAME_VERSION]
	if update_notes:
		update_notes.text = body_txt if not body_txt.strip_edges().is_empty() else "No detailed changelog provided."
		
	# Select best asset or fallback
	_target_download_url = ""
	var assets: Array = release_data.get("assets", [])
	var os_name: String = OS.get_name().to_lower()
	var selected_asset_name: String = ""
	var selected_asset_size: int = 0
	
	if os_name == "android":
		for a in assets:
			if a is Dictionary:
				var aname: String = str(a.get("name", "")).to_lower()
				if aname.ends_with(".apk"):
					_target_download_url = str(a.get("browser_download_url", ""))
					selected_asset_name = str(a.get("name", ""))
					selected_asset_size = int(a.get("size", 0))
					break
	elif os_name == "windows":
		for a in assets:
			if a is Dictionary:
				var aname: String = str(a.get("name", "")).to_lower()
				if aname.ends_with(".zip") or aname.ends_with(".exe") or "windows" in aname or "win" in aname:
					_target_download_url = str(a.get("browser_download_url", ""))
					selected_asset_name = str(a.get("name", ""))
					selected_asset_size = int(a.get("size", 0))
					break
					
	if _target_download_url.is_empty() and GameData.update_direct_fallback_url != "":
		_target_download_url = GameData.update_direct_fallback_url
		selected_asset_name = "Direct Link"
		
	if _target_download_url.is_empty():
		_target_download_url = str(release_data.get("html_url", "https://github.com/yodef/PKMN-Battle-Frontier/releases"))
		selected_asset_name = "GitHub Release"
		
	if btn_update_download:
		if os_name == "web":
			btn_update_download.text = "🔄 Reload Game to Update"
		elif not selected_asset_name.is_empty():
			var size_txt = (" (" + _format_file_size(selected_asset_size) + ")") if selected_asset_size > 0 else ""
			btn_update_download.text = "📥 Download %s%s" % [selected_asset_name, size_txt]
		else:
			btn_update_download.text = "📥 Download Update"
			
	if update_modal:
		update_modal.visible = true

func _on_update_download_pressed() -> void:
	if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
		JavaScriptBridge.eval("window.location.reload(true);")
		return
	if not _target_download_url.is_empty():
		OS.shell_open(_target_download_url)

func _on_update_github_pressed() -> void:
	var gh_url: String = str(_latest_release_info.get("html_url", "https://github.com/yodef/PKMN-Battle-Frontier/releases"))
	OS.shell_open(gh_url)

func _on_update_close_pressed() -> void:
	if update_modal:
		update_modal.visible = false

# --- PANTALLA DE ACCESO / LOGIN ---
func _show_login_screen() -> void:
	if OS.has_feature("web"):
		login_modal.visible = false
		GameData.session_entered_lobby = true
		return
	login_modal.visible = true
	var has_saved = GameData.has_saved_profile()
	if has_saved:
		var email_tag = ("  |  📧 " + GameData.profile_email) if not GameData.profile_email.is_empty() else " (Guest)"
		profile_detected_lbl.text = "👤 %s%s  |  💎 %d  |  🍬 %d" % [
			GameData.profile_name,
			email_tag,
			GameData.player_diamonds,
			GameData.player_rare_candies
		]
		btn_login_play.text = "▶  CONTINUE AS %s\n(Enter Battle Frontier)" % GameData.profile_name.to_upper()
	else:
		# En Web: Si no hay perfil local en IndexedDB, verificar si localStorage recuerda la cuenta de Google
		if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
			var remembered_str = JavaScriptBridge.eval("window.getRememberedCloudUser ? window.getRememberedCloudUser() : ''")
			if remembered_str != null and typeof(remembered_str) == TYPE_STRING and not str(remembered_str).is_empty():
				var remembered_dict = JSON.parse_string(str(remembered_str))
				if typeof(remembered_dict) == TYPE_DICTIONARY:
					var rem_email = str(remembered_dict.get("email", "")).strip_edges()
					if not rem_email.is_empty():
						profile_detected_lbl.text = "☁️ Google Account: %s\n⏳ Restoring game save from cloud..." % rem_email
						btn_login_play.disabled = true
						CloudSync.load_profile_from_cloud(rem_email, func(ok: bool, data: Dictionary, _msg: String):
							btn_login_play.disabled = false
							if ok:
								var prof = data.get("profile", {})
								var cloud_alias = str(prof.get("trainer_alias", prof.get("name", ""))).strip_edges()
								if (cloud_alias.is_empty() or cloud_alias == "Trainer") and not GameData.profile_name.is_empty() and GameData.profile_name != "Trainer":
									data["profile"]["trainer_alias"] = GameData.profile_name
									data["profile"]["name"] = GameData.profile_name
								GameData.apply_save_dict(data)
								GameData.profile_email = rem_email
								GameData.profile_cloud_key = rem_email
								GameData.profile_auth_provider = "Google Cloud"
								GameData.save_profile()
								GameData.session_entered_lobby = true
								login_modal.visible = false
								_update_lobby_header_badge()
								refresh_cards_data_from_catalog()
								print("[Main] Auto-restored cloud profile on Web for %s (%s)!" % [GameData.profile_name, rem_email])
							else:
								profile_detected_lbl.text = "👤 Welcome to Pokémon Battle Frontier!"
								btn_login_play.text = "▶  PLAY AS GUEST\n(Direct to Lobby)"
						)
						return
		profile_detected_lbl.text = "👤 Welcome to Pokémon Battle Frontier!"
		btn_login_play.text = "▶  PLAY AS GUEST\n(Direct to Lobby)"
	btn_login_cloud.text = "🔑  LOG IN WITH CLOUD ACCOUNT\n(Restore Saved Progress)"
	btn_sign_up_google.text = "🌐  REGISTER NEW PROFILE\n(Email Verification & Cloud Sync)"

func _on_login_play_pressed() -> void:
	var is_brand_new = not GameData.has_saved_profile()
	if is_brand_new:
		GameData.create_new_profile("Trainer", "Guest")
	GameData.session_entered_lobby = true
	login_modal.visible = false
	_update_lobby_header_badge()
	GameData.save_profile()
	if not GameData.tutorial_completed and GameData.tutorial_step == 1:
		_start_tutorial_flow_or_settings()
	elif GameData.can_claim_welcome_gift():
		_show_welcome_notification()

func _launch_google_browser_oauth() -> void:
	if cloud_feedback_lbl:
		if OS.has_feature("web"):
			cloud_feedback_lbl.text = "⏳ Opening Google account selector..."
		else:
			cloud_feedback_lbl.text = "⏳ Opening Google browser login..."
		cloud_feedback_lbl.visible = true
	var ok = CloudSync.start_google_oauth_flow()
	if not ok:
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "⚠️ Could not open Google browser login. Please enter manually."
			cloud_feedback_lbl.visible = true
		_set_manual_cloud_mode(true)

func _toggle_manual_cloud_mode() -> void:
	_set_manual_cloud_mode(not is_manual_cloud_mode)

func _set_manual_cloud_mode(manual: bool) -> void:
	is_manual_cloud_mode = manual
	if cloud_action_mode == "VERIFY_EMAIL":
		if cloud_email_row:
			cloud_email_row.visible = false
		if cloud_trainer_row:
			cloud_trainer_row.visible = false
		if cloud_password_row:
			cloud_password_row.visible = false
		if btn_launch_browser_auth:
			btn_launch_browser_auth.visible = false
		if btn_toggle_manual_auth:
			btn_toggle_manual_auth.visible = false
		if btn_resend_verification:
			btn_resend_verification.visible = true
		if btn_cloud_confirm:
			btn_cloud_confirm.visible = true
		return

	if cloud_email_row:
		cloud_email_row.visible = manual
	if cloud_password_row:
		cloud_password_row.visible = manual
	if cloud_trainer_row:
		cloud_trainer_row.visible = (manual and cloud_action_mode == "SIGNUP_GOOGLE")
	if btn_resend_verification:
		btn_resend_verification.visible = false
	if btn_cloud_confirm:
		btn_cloud_confirm.visible = manual
	if btn_launch_browser_auth:
		btn_launch_browser_auth.visible = not manual
		if OS.has_feature("web"):
			btn_launch_browser_auth.text = "🔑 Sign In with Google"
		else:
			btn_launch_browser_auth.text = "🌐 Open Google Browser Sign-In"
	if btn_toggle_manual_auth:
		btn_toggle_manual_auth.visible = true
		btn_toggle_manual_auth.text = "🌐 Switch to Google Browser Sign-In" if manual else "✏️ Or enter credentials manually..."
	if manual:
		if cloud_email_input and cloud_email_input.text.is_empty():
			cloud_email_input.grab_focus()
		elif cloud_trainer_input and cloud_action_mode == "SIGNUP_GOOGLE" and cloud_trainer_input.text.is_empty():
			cloud_trainer_input.grab_focus()
		elif cloud_password_input and cloud_password_input.text.is_empty():
			cloud_password_input.grab_focus()

func _on_google_oauth_completed(success: bool, email: String, display_name: String, error_msg: String) -> void:
	if not success:
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "❌ %s" % error_msg
			cloud_feedback_lbl.visible = true
		return
		
	if cloud_feedback_lbl:
		cloud_feedback_lbl.text = "✅ Account selected: %s\nSyncing with Google Cloud..." % email
		cloud_feedback_lbl.visible = true
		
	CloudSync.check_account_exists(email, func(exists: bool, cloud_data: Dictionary, err: String):
		if not err.is_empty():
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "❌ Error connecting to Google Cloud:\n%s" % err
				cloud_feedback_lbl.visible = true
			return
			
		if exists:
			# Existing account in Google Cloud -> Load and enter
			var prof = cloud_data.get("profile", {})
			var cloud_alias = str(prof.get("trainer_alias", prof.get("name", ""))).strip_edges()
			if (cloud_alias.is_empty() or cloud_alias == "Trainer") and not GameData.profile_name.is_empty() and GameData.profile_name != "Trainer":
				cloud_data["profile"]["trainer_alias"] = GameData.profile_name
				cloud_data["profile"]["name"] = GameData.profile_name
			elif (cloud_alias.is_empty() or cloud_alias == "Trainer") and not display_name.is_empty() and display_name != "Trainer":
				cloud_data["profile"]["trainer_alias"] = display_name
				cloud_data["profile"]["name"] = display_name
				
			GameData.apply_save_dict(cloud_data)
			GameData.profile_email = email
			GameData.profile_cloud_key = email
			GameData.profile_auth_provider = "Google Cloud"
			GameData.save_profile()
			if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
				JavaScriptBridge.eval("if (window.saveRememberedCloudUser) { window.saveRememberedCloudUser('%s', '%s'); }" % [email.c_escape(), GameData.profile_name.c_escape()])
			GameData.session_entered_lobby = true
			cloud_notice_modal.visible = false
			login_modal.visible = false
			_update_lobby_header_badge()
			refresh_cards_data_from_catalog()
			print("[Main] Google OAuth: Profile loaded from Cloud for %s (%s)!" % [GameData.profile_name, email])
			if GameData.can_claim_welcome_gift():
				_show_welcome_notification()
		else:
			# New account in Google Cloud
			var chosen_alias = display_name if not display_name.is_empty() else email.split("@")[0].capitalize()
			if not GameData.profile_name.is_empty() and GameData.profile_name != "Trainer":
				chosen_alias = GameData.profile_name
			if chosen_alias.is_empty() or chosen_alias == "Trainer":
				chosen_alias = email.split("@")[0].capitalize()
			if GameData.player_unlocked_ids.is_empty():
				GameData.create_new_profile(chosen_alias, "Google Cloud", email, false)
			else:
				GameData.create_or_update_profile(chosen_alias, "Google Cloud", email, false)
			GameData.profile_email = email
			GameData.profile_cloud_key = email
			GameData.profile_name = chosen_alias
			GameData.profile_auth_provider = "Google Cloud"
			GameData.save_profile(false)
			if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
				JavaScriptBridge.eval("if (window.saveRememberedCloudUser) { window.saveRememberedCloudUser('%s', '%s'); }" % [email.c_escape(), chosen_alias.c_escape()])
			
			CloudSync.save_profile_to_cloud(email, GameData.get_save_dict(), func(save_ok: bool, save_msg: String):
				if save_ok:
					GameData.session_entered_lobby = true
					cloud_notice_modal.visible = false
					login_modal.visible = false
					_update_lobby_header_badge()
					refresh_cards_data_from_catalog()
					if GameData.can_claim_welcome_gift():
						_show_welcome_notification()
					print("[Main] Google OAuth: Profile created and synced for %s (%s)!" % [chosen_alias, email])
				else:
					if cloud_feedback_lbl:
						cloud_feedback_lbl.text = "⚠️ Profile saved locally, but failed to sync to cloud:\n%s" % save_msg
						cloud_feedback_lbl.visible = true
			)
	)

func _on_login_cloud_pressed() -> void:
	cloud_action_mode = "LOGIN_CLOUD"
	cloud_title.text = "🔑 LOG IN WITH CLOUD ACCOUNT"
	cloud_desc.text = "Enter your registered email and password to restore your progress and collection:"
	_set_manual_cloud_mode(true)
	if cloud_email_input:
		var remembered_email = GameData.profile_email
		if remembered_email.is_empty() and GameData.profile_cloud_key.contains("@"):
			remembered_email = GameData.profile_cloud_key
		if remembered_email.is_empty() and OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
			var rem_str = JavaScriptBridge.eval("window.getRememberedCloudUser ? window.getRememberedCloudUser() : ''")
			if rem_str != null and typeof(rem_str) == TYPE_STRING and not str(rem_str).is_empty():
				var rem_dict = JSON.parse_string(str(rem_str))
				if typeof(rem_dict) == TYPE_DICTIONARY:
					remembered_email = str(rem_dict.get("email", "")).strip_edges()
		cloud_email_input.text = remembered_email
		cloud_email_input.placeholder_text = "e.g. ash@gmail.com"
	if cloud_password_input:
		cloud_password_input.text = ""
		cloud_password_input.placeholder_text = "Your password"
	if cloud_feedback_lbl:
		cloud_feedback_lbl.visible = false
		cloud_feedback_lbl.text = ""
	if btn_resend_verification:
		btn_resend_verification.visible = false
	btn_cloud_confirm.text = "☁️ Log In & Restore Save"
	btn_cloud_confirm.disabled = false
	cloud_notice_modal.visible = true

func _on_sign_up_google_pressed() -> void:
	cloud_action_mode = "SIGNUP_GOOGLE"
	cloud_title.text = "🌐 REGISTER NEW PROFILE"
	cloud_desc.text = "Enter your email, alias and password. An email verification is required to activate your profile:"
	_set_manual_cloud_mode(true)
	if cloud_trainer_prompt:
		cloud_trainer_prompt.text = "Trainer Alias:"
	if cloud_email_input:
		cloud_email_input.text = GameData.profile_email
		cloud_email_input.placeholder_text = "e.g. ash@gmail.com"
	if cloud_trainer_input:
		var current_alias = GameData.profile_name
		if current_alias.is_empty() or current_alias == "Trainer":
			var sys_user = OS.get_environment("USERNAME")
			current_alias = sys_user.capitalize() if not sys_user.is_empty() else "Red"
		cloud_trainer_input.text = current_alias
		cloud_trainer_input.placeholder_text = "e.g. Ash, Red, Nestor..."
	if cloud_password_input:
		cloud_password_input.text = ""
		cloud_password_input.placeholder_text = "Min 6 characters"
	if cloud_feedback_lbl:
		cloud_feedback_lbl.visible = false
		cloud_feedback_lbl.text = ""
	if btn_resend_verification:
		btn_resend_verification.visible = false
	btn_cloud_confirm.text = "✉️ Send Verification & Register"
	btn_cloud_confirm.disabled = false
	cloud_notice_modal.visible = true

func _prompt_web_input_if_needed(target_input: LineEdit, title_prompt: String) -> void:
	if not target_input:
		return
	if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
		var cur_val = target_input.text.c_escape()
		var p_title = title_prompt.c_escape()
		var js = "window.prompt('%s', '%s')" % [p_title, cur_val]
		var res = JavaScriptBridge.eval(js)
		if res != null and typeof(res) == TYPE_STRING:
			target_input.text = str(res).strip_edges()
	else:
		DisplayServer.virtual_keyboard_show(target_input.text)

func _on_cloud_confirm_pressed() -> void:
	if cloud_action_mode == "VERIFY_EMAIL":
		_check_email_verification_status()
		return

	var entered_email = cloud_email_input.text.strip_edges() if cloud_email_input else ""
	var entered_alias = cloud_trainer_input.text.strip_edges() if cloud_trainer_input else ""
	var entered_pass = cloud_password_input.text.strip_edges() if cloud_password_input else ""
	
	if cloud_action_mode == "LOGIN_CLOUD":
		if entered_email.is_empty():
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⚠️ Please enter your registered email address."
				cloud_feedback_lbl.visible = true
			return
				
		btn_cloud_confirm.disabled = true
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "⏳ Authenticating..."
			cloud_feedback_lbl.visible = true
			
		if not entered_pass.is_empty():
			CloudSync.firebase_auth_sign_in(entered_email, entered_pass, func(sign_ok: bool, id_token: String, sign_err: String):
				if not sign_ok:
					btn_cloud_confirm.disabled = false
					if cloud_feedback_lbl:
						cloud_feedback_lbl.text = "❌ %s" % sign_err
						cloud_feedback_lbl.visible = true
					return
					
				# Check if verified
				CloudSync.firebase_auth_check_verified(id_token, func(check_ok: bool, is_verified: bool, _chk_err: String):
					if check_ok and not is_verified:
						_pending_verify_id_token = id_token
						_pending_verify_email = entered_email
						_pending_verify_alias = entered_alias if not entered_alias.is_empty() else entered_email.split("@")[0].capitalize()
						_pending_verify_password = entered_pass
						btn_cloud_confirm.disabled = false
						_switch_to_verification_view(entered_email)
						return
						
					_load_cloud_profile_and_enter(entered_email, true, entered_alias)
				)
			)
		else:
			_load_cloud_profile_and_enter(entered_email, false, entered_alias)
		
	elif cloud_action_mode == "SIGNUP_GOOGLE":
		if entered_email.is_empty():
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⚠️ Please enter your email address."
				cloud_feedback_lbl.visible = true
			return
			
		var email_regex = RegEx.new()
		email_regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
		if not email_regex.search(entered_email):
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⚠️ Please enter a valid email address (e.g. trainer@gmail.com)."
				cloud_feedback_lbl.visible = true
			return
			
		if entered_pass.length() < 6:
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⚠️ Password must be at least 6 characters long."
				cloud_feedback_lbl.visible = true
			return
			
		if entered_alias.is_empty():
			entered_alias = entered_email.split("@")[0].capitalize()
			if cloud_trainer_input:
				cloud_trainer_input.text = entered_alias
				
		btn_cloud_confirm.disabled = true
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "⏳ Checking account availability..."
			cloud_feedback_lbl.visible = true
			
		CloudSync.check_account_exists(entered_email, func(exists: bool, _data: Dictionary, err: String):
			if not err.is_empty():
				btn_cloud_confirm.disabled = false
				if cloud_feedback_lbl:
					cloud_feedback_lbl.text = "❌ Cloud connection error:\n%s" % err
					cloud_feedback_lbl.visible = true
				return
				
			if exists:
				btn_cloud_confirm.disabled = false
				if cloud_feedback_lbl:
					cloud_feedback_lbl.text = "ℹ️ An account with '%s' already exists. Switching to Log In..." % entered_email
					cloud_feedback_lbl.visible = true
				_on_login_cloud_pressed()
				return
				
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⏳ Creating account in Firebase..."
				
			CloudSync.firebase_auth_sign_up(entered_email, entered_pass, func(sign_ok: bool, id_token: String, sign_err: String):
				if not sign_ok:
					btn_cloud_confirm.disabled = false
					if sign_err.to_lower().contains("already exists") or sign_err.contains("EMAIL_EXISTS"):
						if cloud_feedback_lbl:
							cloud_feedback_lbl.text = "ℹ️ Account already exists. Signing in..."
							cloud_feedback_lbl.visible = true
						CloudSync.firebase_auth_sign_in(entered_email, entered_pass, func(s_ok: bool, s_token: String, _s_err: String):
							if not s_ok:
								btn_cloud_confirm.disabled = false
								if cloud_feedback_lbl:
									cloud_feedback_lbl.text = "ℹ️ An account with this email already exists.\nPlease enter your registered password in Log In."
									cloud_feedback_lbl.visible = true
								_on_login_cloud_pressed()
								return
								
							CloudSync.firebase_auth_check_verified(s_token, func(chk_ok: bool, is_ver: bool, _chk_e: String):
								if chk_ok and not is_ver:
									_pending_verify_id_token = s_token
									_pending_verify_email = entered_email
									_pending_verify_alias = entered_alias
									_pending_verify_password = entered_pass
									btn_cloud_confirm.disabled = false
									_switch_to_verification_view(entered_email)
									return
									
								_load_cloud_profile_and_enter(entered_email, true, entered_alias)
							)
						)
						return
					else:
						if cloud_feedback_lbl:
							cloud_feedback_lbl.text = "❌ Registration failed: %s" % sign_err
							cloud_feedback_lbl.visible = true
					return
					
				if cloud_feedback_lbl:
					cloud_feedback_lbl.text = "⏳ Sending verification email to %s..." % entered_email
					
				CloudSync.firebase_auth_send_verification_email(id_token, func(ver_ok: bool, ver_err: String):
					btn_cloud_confirm.disabled = false
					if not ver_ok:
						if cloud_feedback_lbl:
							cloud_feedback_lbl.text = "❌ Failed to send verification email: %s" % ver_err
							cloud_feedback_lbl.visible = true
						return
						
					_pending_verify_id_token = id_token
					_pending_verify_email = entered_email
					_pending_verify_alias = entered_alias
					_pending_verify_password = entered_pass
					_switch_to_verification_view(entered_email)
				)
			)
		)

func _switch_to_verification_view(email: String) -> void:
	cloud_action_mode = "VERIFY_EMAIL"
	cloud_title.text = "✉️ VERIFY YOUR EMAIL"
	cloud_desc.text = "A verification email has been sent to:\n%s\n\n1. Check your inbox (and Spam folder).\n2. Click the verification link from Firebase.\n3. Click '✅ I Have Verified My Email' below." % email
	_set_manual_cloud_mode(true)
	if cloud_feedback_lbl:
		cloud_feedback_lbl.text = "✉️ Verification link sent! Please check your email inbox."
		cloud_feedback_lbl.visible = true
	btn_cloud_confirm.text = "✅ I Have Verified My Email"
	btn_cloud_confirm.disabled = false

func _check_email_verification_status() -> void:
	btn_cloud_confirm.disabled = true
	if cloud_feedback_lbl:
		cloud_feedback_lbl.text = "⏳ Checking email verification with Firebase..."
		cloud_feedback_lbl.visible = true
		
	# Reautenticar siempre si conocemos la contraseña para obtener un token fresco con el estado emailVerified actualizado
	if not _pending_verify_email.is_empty() and not _pending_verify_password.is_empty():
		CloudSync.firebase_auth_sign_in(_pending_verify_email, _pending_verify_password, func(s_ok: bool, new_token: String, _s_err: String):
			if s_ok:
				_pending_verify_id_token = new_token
				_finalize_verification_check(new_token)
			elif not _pending_verify_id_token.is_empty():
				_finalize_verification_check(_pending_verify_id_token)
			else:
				btn_cloud_confirm.disabled = false
				if cloud_feedback_lbl:
					cloud_feedback_lbl.text = "⚠️ Session expired. Please log in or register again."
					cloud_feedback_lbl.visible = true
				_on_login_cloud_pressed()
		)
	elif not _pending_verify_id_token.is_empty():
		_finalize_verification_check(_pending_verify_id_token)
	else:
		btn_cloud_confirm.disabled = false
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "⚠️ Session token missing. Please register again."
			cloud_feedback_lbl.visible = true
		_on_login_cloud_pressed()

func _finalize_verification_check(token_to_check: String) -> void:
	CloudSync.firebase_auth_check_verified(token_to_check, func(success: bool, is_verified: bool, err_msg: String):
		btn_cloud_confirm.disabled = false
		if not success:
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "❌ Verification check failed: %s" % err_msg
				cloud_feedback_lbl.visible = true
			return
			
		if not is_verified:
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⚠️ Email not verified yet!\nPlease click the verification link sent to %s, then try again." % _pending_verify_email
				cloud_feedback_lbl.visible = true
			return
			
		# Verification successful!
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "🎉 Email verified! Creating your profile..."
			cloud_feedback_lbl.visible = true
			
		if GameData.player_unlocked_ids.is_empty():
			GameData.create_new_profile(_pending_verify_alias, "Google Cloud", _pending_verify_email, false)
		else:
			GameData.create_or_update_profile(_pending_verify_alias, "Google Cloud", _pending_verify_email, false)
		GameData.profile_email = _pending_verify_email
		GameData.profile_cloud_key = _pending_verify_email
		GameData.profile_name = _pending_verify_alias
		GameData.profile_auth_provider = "Google Cloud"
		GameData.save_profile(false)
		
		CloudSync.save_profile_to_cloud(_pending_verify_email, GameData.get_save_dict(), func(save_ok: bool, save_msg: String):
			btn_cloud_confirm.disabled = false
			if save_ok:
				GameData.session_entered_lobby = true
				cloud_notice_modal.visible = false
				login_modal.visible = false
				_update_lobby_header_badge()
				refresh_cards_data_from_catalog()
				if profile_modal and profile_modal.visible:
					_on_profile_pressed()
				if not GameData.tutorial_completed and GameData.tutorial_step == 1:
					_show_tutorial_step1_intro_guidance()
				elif GameData.can_claim_welcome_gift():
					_show_welcome_notification()
				print("[Main] New verified profile created and synced for %s (%s)!" % [_pending_verify_alias, _pending_verify_email])
			else:
				if cloud_feedback_lbl:
					cloud_feedback_lbl.text = "⚠️ Profile saved locally, but failed to sync to cloud:\n%s" % save_msg
					cloud_feedback_lbl.visible = true
		)
	)

func _on_resend_verification_pressed() -> void:
	if _pending_verify_id_token.is_empty():
		if not _pending_verify_email.is_empty() and not _pending_verify_password.is_empty():
			if btn_resend_verification:
				btn_resend_verification.disabled = true
			CloudSync.firebase_auth_sign_in(_pending_verify_email, _pending_verify_password, func(s_ok: bool, new_token: String, _s_err: String):
				if s_ok:
					_pending_verify_id_token = new_token
					_on_resend_verification_pressed()
				else:
					if btn_resend_verification:
						btn_resend_verification.disabled = false
					if cloud_feedback_lbl:
						cloud_feedback_lbl.text = "⚠️ Session expired. Please log in or register again."
						cloud_feedback_lbl.visible = true
			)
			return
		else:
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⚠️ Session token missing. Please register again."
				cloud_feedback_lbl.visible = true
			return
			
	if btn_resend_verification:
		btn_resend_verification.disabled = true
	if cloud_feedback_lbl:
		cloud_feedback_lbl.text = "⏳ Resending verification email..."
		cloud_feedback_lbl.visible = true
		
	CloudSync.firebase_auth_send_verification_email(_pending_verify_id_token, func(ok: bool, msg: String):
		if btn_resend_verification:
			btn_resend_verification.disabled = false
		if ok:
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "✅ Verification email resent! Check your inbox (and Spam folder)."
				cloud_feedback_lbl.visible = true
		else:
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "❌ Failed to resend email: %s" % msg
				cloud_feedback_lbl.visible = true
	)

func _load_cloud_profile_and_enter(email: String, is_authenticated: bool = false, preferred_alias: String = "") -> void:
	if cloud_feedback_lbl:
		cloud_feedback_lbl.text = "⏳ Loading profile from Cloud..."
		cloud_feedback_lbl.visible = true
		
	CloudSync.load_profile_from_cloud(email, func(success: bool, data: Dictionary, msg: String):
		btn_cloud_confirm.disabled = false
		if success:
			var prof = data.get("profile", {})
			var cloud_alias = str(prof.get("trainer_alias", prof.get("name", ""))).strip_edges()
			if (cloud_alias.is_empty() or cloud_alias == "Trainer") and not GameData.profile_name.is_empty() and GameData.profile_name != "Trainer":
				data["profile"]["trainer_alias"] = GameData.profile_name
				data["profile"]["name"] = GameData.profile_name
			elif (cloud_alias.is_empty() or cloud_alias == "Trainer") and not preferred_alias.is_empty() and preferred_alias != "Trainer":
				data["profile"]["trainer_alias"] = preferred_alias
				data["profile"]["name"] = preferred_alias
			GameData.apply_save_dict(data)
			GameData.profile_email = email
			GameData.profile_cloud_key = email
			GameData.profile_auth_provider = "Google Cloud"
			GameData.save_profile()
			if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
				JavaScriptBridge.eval("if (window.saveRememberedCloudUser) { window.saveRememberedCloudUser('%s', '%s'); }" % [email.c_escape(), GameData.profile_name.c_escape()])
			GameData.session_entered_lobby = true
			cloud_notice_modal.visible = false
			login_modal.visible = false
			_update_lobby_header_badge()
			refresh_cards_data_from_catalog()
			print("[Main] Profile loaded from Google Cloud for %s (%s)!" % [GameData.profile_name, email])
			if GameData.can_claim_welcome_gift():
				_show_welcome_notification()
		else:
			# Si el usuario ya fue autenticado (por contraseña o Firebase Auth) pero aún no tenía documento en Firestore
			# (por ejemplo, verificó su correo externamente en el navegador o móvil y acaba de iniciar sesión por primera vez):
			if is_authenticated:
				print("[Main] Authenticated user without Firestore doc. Provisioning new profile for: %s" % email)
				var chosen_alias = preferred_alias
				if chosen_alias.is_empty() and cloud_trainer_input and not cloud_trainer_input.text.strip_edges().is_empty():
					chosen_alias = cloud_trainer_input.text.strip_edges()
				if chosen_alias.is_empty() and not _pending_verify_alias.is_empty():
					chosen_alias = _pending_verify_alias
				if chosen_alias.is_empty() and not GameData.profile_name.is_empty() and GameData.profile_name != "Trainer":
					chosen_alias = GameData.profile_name
				if chosen_alias.is_empty() or chosen_alias == "Trainer":
					chosen_alias = email.split("@")[0].capitalize()
					
				if GameData.player_unlocked_ids.is_empty():
					GameData.create_new_profile(chosen_alias, "Google Cloud", email, false)
				else:
					GameData.create_or_update_profile(chosen_alias, "Google Cloud", email, false)
				GameData.profile_email = email
				GameData.profile_cloud_key = email
				GameData.profile_name = chosen_alias
				GameData.profile_auth_provider = "Google Cloud"
				GameData.save_profile(false)
				
				if cloud_feedback_lbl:
					cloud_feedback_lbl.text = "🎉 Welcome %s! Creating your cloud profile..." % chosen_alias
					cloud_feedback_lbl.visible = true
					
				CloudSync.save_profile_to_cloud(email, GameData.get_save_dict(), func(save_ok: bool, save_msg: String):
					btn_cloud_confirm.disabled = false
					GameData.session_entered_lobby = true
					cloud_notice_modal.visible = false
					login_modal.visible = false
					_update_lobby_header_badge()
					refresh_cards_data_from_catalog()
					if profile_modal and profile_modal.visible:
						_on_profile_pressed()
					if GameData.can_claim_welcome_gift():
						_show_welcome_notification()
					print("[Main] Initial cloud profile created and entered lobby for %s (%s)!" % [chosen_alias, email])
				)
				return
				
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "ℹ️ No saved game found for '%s'.\nWould you like to register this email as a new profile?" % email
				cloud_feedback_lbl.visible = true
			btn_cloud_confirm.text = "✉️ Send Verification & Register"
			cloud_action_mode = "SIGNUP_GOOGLE"
			_set_manual_cloud_mode(true)
			if cloud_trainer_input and cloud_trainer_input.text.is_empty():
				cloud_trainer_input.text = email.split("@")[0].capitalize()
	)

func _show_welcome_notification() -> void:
	if not welcome_modal:
		return
	if not GameData.can_claim_welcome_gift():
		welcome_modal.visible = false
		return
	welcome_title.text = "WELCOME, %s!" % GameData.profile_name.to_upper()
	welcome_modal.visible = true

func _on_welcome_go_shop_pressed() -> void:
	GameData.claim_welcome_gift()
	welcome_modal.visible = false
	_on_shop_pressed()

func _on_diamonds_changed(_new_amount: int = 0) -> void:
	_update_lobby_header_badge()
	_update_shop_currencies()
	if campaign_gold_lbl:
		campaign_gold_lbl.text = "💰 %d G  |  💎 %d" % [GameData.campaign_gold, GameData.player_diamonds]
	if stat_diamonds_lbl:
		stat_diamonds_lbl.text = "💎 Diamonds: %d" % GameData.player_diamonds
	var current_cost = BOOSTER_PACK_COST
	if GameData.BOOSTER_PACKS.has(selected_booster_pack_id):
		current_cost = int(GameData.BOOSTER_PACKS[selected_booster_pack_id].get("cost", BOOSTER_PACK_COST))
	if btn_small_cost_pack:
		btn_small_cost_pack.disabled = (GameData.player_diamonds < current_cost)
	if btn_open_pack:
		btn_open_pack.disabled = (GameData.player_diamonds < current_cost)
	if btn_reveal_another:
		btn_reveal_another.disabled = (GameData.player_diamonds < current_cost)

func _on_rare_candies_changed(_new_amount: int = 0) -> void:
	_update_lobby_header_badge()
	_update_shop_currencies()
	if stat_candies_lbl:
		stat_candies_lbl.text = "🍬 Rare Candies: %d" % GameData.player_rare_candies
	if shop_active_tab == "HIDDEN":
		_populate_hidden_shop_view()

func _on_card_stocks_changed() -> void:
	if collection_modal and collection_modal.visible:
		populate_collection_grid()
		if collection_detail_view and collection_detail_view.visible:
			show_collection_card(current_collection_index)
	if shop_modal and shop_modal.visible:
		if shop_active_tab == "RECYCLE":
			_populate_recycle_view()
		elif shop_active_tab == "HIDDEN":
			_populate_hidden_shop_view()

func _update_shop_currencies() -> void:
	if shop_diamonds_lbl:
		shop_diamonds_lbl.text = "💎 Diamonds: %d  |  🍬 Rare Candies: %d" % [GameData.player_diamonds, GameData.player_rare_candies]

func _update_lobby_header_badge() -> void:
	if trainer_status_badge:
		var alias = GameData.profile_name
		if alias.is_empty():
			alias = "Trainer"
		trainer_status_badge.text = "👤 %s  |  💎 %d  |  🍬 %d" % [alias, GameData.player_diamonds, GameData.player_rare_candies]
		if OS.has_feature("web"):
			trainer_status_badge.tooltip_text = "Local Web Trainer\nTrainer ID: %s" % GameData.profile_id
		elif not GameData.profile_email.is_empty():
			trainer_status_badge.tooltip_text = "Google Account: %s\nTrainer ID: %s" % [GameData.profile_email, GameData.profile_id]
		else:
			trainer_status_badge.tooltip_text = "Local / Guest Account\nTrainer ID: %s" % GameData.profile_id
	if btn_daily_missions:
		if GameData.has_any_daily_reward_ready():
			btn_daily_missions.text = "🎁  DAILY MISSIONS & REWARDS  🔔"
		else:
			btn_daily_missions.text = "🎁  DAILY MISSIONS & REWARDS"

func _create_activity_status_button(is_active: bool, tooltip_info: String = "") -> Button:
	var btn = Button.new()
	btn.mouse_filter = Control.MOUSE_FILTER_PASS
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(85, 26)
	btn.add_theme_font_size_override("font_size", 10)
	
	var sb = StyleBoxFlat.new()
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(13)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	
	if is_active:
		btn.text = "🟢 Activo" if GameData.is_spanish() else "🟢 Active"
		sb.bg_color = Color(0.12, 0.35, 0.18, 0.95)
		sb.border_color = Color(0.3, 0.9, 0.45, 0.9)
		btn.add_theme_color_override("font_color", Color(0.6, 1.0, 0.7))
	else:
		btn.text = "⚪ Inactivo" if GameData.is_spanish() else "⚪ Inactive"
		sb.bg_color = Color(0.18, 0.22, 0.26, 0.95)
		sb.border_color = Color(0.45, 0.52, 0.60, 0.8)
		btn.add_theme_color_override("font_color", Color(0.75, 0.82, 0.88))
		
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_stylebox_override("disabled", sb)
	if not tooltip_info.is_empty():
		btn.tooltip_text = tooltip_info
	return btn

# --- PERFIL Y REGISTROS DEL ENTRENADOR ---
func _on_profile_pressed() -> void:
	refresh_cards_data_from_catalog()
	if trainer_name_input:
		trainer_name_input.text = GameData.profile_name
	if trainer_email_prompt:
		trainer_email_prompt.text = "🕒 Última Actividad:" if GameData.is_spanish() else "🕒 Last Activity:"
	if trainer_email_value:
		trainer_email_value.text = "Hace un momento" if GameData.is_spanish() else "Just now"
	if trainer_email_row and not trainer_email_row.has_node("BtnTrainerStatus"):
		var status_btn = _create_activity_status_button(true)
		status_btn.name = "BtnTrainerStatus"
		trainer_email_row.add_child(status_btn)
	elif trainer_email_row and trainer_email_row.has_node("BtnTrainerStatus"):
		var status_btn = trainer_email_row.get_node("BtnTrainerStatus") as Button
		status_btn.text = "🟢 Activo" if GameData.is_spanish() else "🟢 Active"
		
	if btn_link_google:
		if GameData.profile_auth_provider.begins_with("Google"):
			btn_link_google.text = "🔄 Switch / Re-sync Google Account"
		else:
			btn_link_google.text = "🌐 Connect with Google Account"
	if account_status_lbl:
		if OS.has_feature("web"):
			account_status_lbl.text = "Status: 🌐 Local Web Play (Browser IndexedDB Storage)"
			account_status_lbl.modulate = Color(0.4, 0.85, 1.0)
		elif GameData.profile_auth_provider.begins_with("Google"):
			account_status_lbl.text = "Status: 🟢 Google Cloud Connected (Firebase)"
			account_status_lbl.modulate = Color(0.35, 1.0, 0.5)
		else:
			account_status_lbl.text = "Status: ⚪ Local Storage Active (%s)" % GameData.profile_auth_provider
			account_status_lbl.modulate = Color(0.7, 0.85, 0.95)
	
	if OS.has_feature("web"):
		if trainer_email_row:
			trainer_email_row.visible = false
		if btn_link_google:
			btn_link_google.visible = false
		if btn_logout:
			btn_logout.visible = false
	else:
		if trainer_email_row:
			trainer_email_row.visible = true
		if btn_link_google:
			btn_link_google.visible = true
		if btn_logout:
			btn_logout.visible = true
	if stat_diamonds_lbl:
		stat_diamonds_lbl.text = "💎 Diamonds: %d" % GameData.player_diamonds
	
	if not stat_candies_lbl:
		var grid = $ProfileModal/ProfileBox/StatsCard/StatsVBox/StatsGrid
		if grid:
			stat_candies_lbl = Label.new()
			stat_candies_lbl.name = "StatCandiesLbl"
			stat_candies_lbl.add_theme_font_size_override("font_size", 12)
			grid.add_child(stat_candies_lbl)
	if stat_candies_lbl:
		stat_candies_lbl.text = "🍬 Rare Candies: %d" % GameData.player_rare_candies
		
	if stat_tournaments_lbl:
		stat_tournaments_lbl.text = "🏆 Tournament Wins: %d" % GameData.stats_tournaments_won
	if stat_battles_lbl:
		var win_rate = 0.0
		if GameData.stats_battles_total > 0:
			win_rate = (float(GameData.stats_battles_won) / float(GameData.stats_battles_total)) * 100.0
		stat_battles_lbl.text = "⚔️ Battles: %d / %d (%.0f%%)" % [GameData.stats_battles_won, GameData.stats_battles_total, win_rate]
	if stat_collection_lbl:
		var pct = (float(GameData.player_unlocked_ids.size()) / max(1.0, float(GameData.pokemon_catalog.size()))) * 100.0
		stat_collection_lbl.text = "🎴 Cards: %d / %d (%.0f%%)" % [GameData.player_unlocked_ids.size(), GameData.pokemon_catalog.size(), pct]
	if stat_packs_lbl:
		stat_packs_lbl.text = "📦 Packs Opened: %d" % GameData.stats_packs_opened
	if stat_gold_lbl:
		stat_gold_lbl.text = "💰 Campaign Gold: %d G" % GameData.campaign_gold
	if profile_feedback_lbl:
		profile_feedback_lbl.visible = false
	_update_profile_showcase_ui()
	profile_modal.visible = true

func _on_save_progress_pressed() -> void:
	if trainer_name_input:
		var new_name = trainer_name_input.text.strip_edges()
		if new_name != "":
			GameData.profile_name = new_name
	var success = GameData.save_profile()
	_update_lobby_header_badge()
	if profile_feedback_lbl:
		if success:
			if GameData.profile_auth_provider.begins_with("Google"):
				profile_feedback_lbl.text = "✅ Progress saved locally & syncing to Google Cloud!"
			else:
				profile_feedback_lbl.text = "✅ Progress saved successfully to local storage!"
		else:
			profile_feedback_lbl.text = "❌ Error saving file."
		profile_feedback_lbl.visible = true

func _on_logout_pressed() -> void:
	if OS.has_feature("web"):
		return
	profile_modal.visible = false
	GameData.session_entered_lobby = false
	_show_login_screen()

func _on_erase_profile_prompt_pressed() -> void:
	erase_confirm_modal.visible = true

func _on_confirm_erase_pressed() -> void:
	erase_confirm_modal.visible = false
	profile_modal.visible = false
	if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
		JavaScriptBridge.eval("if (window.clearRememberedCloudUser) { window.clearRememberedCloudUser(); }")
	GameData.erase_profile()
	refresh_cards_data_from_catalog()
	_apply_audio_settings()
	_update_lobby_header_badge()
	if OS.has_feature("web"):
		GameData.create_new_profile("Trainer", "Guest")
		GameData.session_entered_lobby = true
		_update_lobby_header_badge()
	else:
		_show_login_screen()

# --- SHOWCASE DE POKÉMON FAVORITOS Y PERFIL DE AMIGOS ---

func _update_profile_showcase_ui() -> void:
	var p_box = get_node_or_null("ProfileModal/ProfileBox")
	if not p_box:
		return
		
	if profile_showcase_card == null:
		profile_showcase_card = PanelContainer.new()
		profile_showcase_card.name = "FavoriteShowcaseCard"
		var sb_panel = StyleBoxFlat.new()
		sb_panel.bg_color = Color(0.08, 0.12, 0.18, 0.95)
		sb_panel.border_color = Color(0.25, 0.52, 0.60)
		sb_panel.set_border_width_all(2)
		sb_panel.set_corner_radius_all(8)
		profile_showcase_card.add_theme_stylebox_override("panel", sb_panel)
		
		var stats_card = p_box.get_node_or_null("StatsCard")
		if stats_card:
			p_box.add_child(profile_showcase_card)
			p_box.move_child(profile_showcase_card, stats_card.get_index() + 1)
		else:
			p_box.add_child(profile_showcase_card)
			
	for c in profile_showcase_card.get_children():
		c.queue_free()
		
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	profile_showcase_card.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)
	
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(header_hbox)
	
	var title_lbl = Label.new()
	title_lbl.text = "⭐ TOP 3 FAVORITE POKÉMON"
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_lbl)
	
	var btn_edit_showcase = Button.new()
	btn_edit_showcase.text = "✏️ Edit Showcase"
	btn_edit_showcase.custom_minimum_size = Vector2(130, 28)
	btn_edit_showcase.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_edit_showcase, Color(0.2, 0.6, 0.7), Color(0.3, 0.8, 0.9))
	btn_edit_showcase.pressed.connect(func(): _open_showcase_picker_modal())
	header_hbox.add_child(btn_edit_showcase)
	
	var slots_hbox = HBoxContainer.new()
	slots_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	slots_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(slots_hbox)
	
	var current_showcase = GameData.get_profile_showcase()
	for i in range(3):
		var pid = current_showcase[i] if i < current_showcase.size() else -1
		var card_node = _build_showcase_card_node(pid, i, true, func(_slot_idx: int):
			_open_showcase_picker_modal()
		)
		slots_hbox.add_child(card_node)

func _build_showcase_card_node(pokemon_id: int, slot_idx: int, is_editable: bool = false, on_clicked: Callable = Callable()) -> Control:
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(106, 150)
	container.mouse_filter = Control.MOUSE_FILTER_STOP if is_editable else Control.MOUSE_FILTER_IGNORE
	if is_editable:
		container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if on_clicked.is_valid():
			container.gui_input.connect(func(event: InputEvent):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					on_clicked.call(slot_idx)
			)
			
	if pokemon_id < 0 or not GameData.pokemon_catalog.has(pokemon_id):
		var sb_empty = StyleBoxFlat.new()
		sb_empty.bg_color = Color(0.06, 0.09, 0.14, 0.85)
		sb_empty.border_color = Color(0.25, 0.35, 0.50, 0.7)
		sb_empty.set_border_width_all(2)
		sb_empty.set_corner_radius_all(6)
		container.add_theme_stylebox_override("panel", sb_empty)
		
		var empty_center = CenterContainer.new()
		empty_center.set_anchors_preset(Control.PRESET_FULL_RECT)
		container.add_child(empty_center)
		
		var empty_vbox = VBoxContainer.new()
		empty_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		empty_vbox.add_theme_constant_override("separation", 4)
		empty_center.add_child(empty_vbox)
		
		var plus_lbl = Label.new()
		plus_lbl.text = "➕"
		plus_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		plus_lbl.add_theme_font_size_override("font_size", 22)
		empty_vbox.add_child(plus_lbl)
		
		var slot_lbl = Label.new()
		slot_lbl.text = "Slot %d\n(Empty)" % (slot_idx + 1)
		slot_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_lbl.add_theme_font_size_override("font_size", 10)
		slot_lbl.add_theme_color_override("font_color", Color(0.5, 0.65, 0.8))
		empty_vbox.add_child(slot_lbl)
		
		return container

	var card = GameData.pokemon_catalog[pokemon_id]
	var type_key = str(card.get("type", "NORMAL")).to_upper()
	var theme = AssembledCardScript.TYPE_THEMES.get(type_key, AssembledCardScript.TYPE_THEMES["NORMAL"])
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = theme["bg"]
	sb.border_color = theme["border"]
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	container.add_theme_stylebox_override("panel", sb)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 4)
	margin.add_theme_constant_override("margin_bottom", 4)
	margin.mouse_filter = Control.MOUSE_FILTER_PASS
	container.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.mouse_filter = Control.MOUSE_FILTER_PASS
	margin.add_child(vbox)
	
	# Fila 1: Icono Tipo + Nombre + Estrella
	var top_hbox = HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 3)
	top_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(top_hbox)
	
	var type_icon = TextureRect.new()
	type_icon.custom_minimum_size = Vector2(14, 14)
	type_icon.texture = GameData.get_type_icon_texture(type_key)
	type_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	type_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	top_hbox.add_child(type_icon)
	
	var name_lbl = Label.new()
	name_lbl.text = str(card.get("short_name", "PKMN"))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	top_hbox.add_child(name_lbl)
	
	var star_lbl = Label.new()
	star_lbl.text = "⭐"
	star_lbl.add_theme_font_size_override("font_size", 9)
	top_hbox.add_child(star_lbl)
	
	# Fila 2: Sprite centrado
	var sprite_box = CenterContainer.new()
	sprite_box.custom_minimum_size = Vector2(0, 94)
	sprite_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sprite_box.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(sprite_box)
	
	var sprite = TextureRect.new()
	var tex_file = str(card.get("texture_path", card.get("texture_file", "")))
	sprite.texture = GameData.get_pokemon_texture(tex_file)
	sprite.custom_minimum_size = Vector2(84, 84)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite_box.add_child(sprite)
	
	# Fila 3: Tier Badge + Rarity Stars
	var bot_hbox = HBoxContainer.new()
	bot_hbox.add_theme_constant_override("separation", 3)
	bot_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(bot_hbox)
	
	var tier_val = str(card.get("tier", "C")).strip_edges().to_upper()
	if tier_val == "":
		tier_val = "C"
	var t_col = GameData.get_tier_color(tier_val)
	var tier_lbl = Label.new()
	tier_lbl.text = "Tier " + tier_val
	tier_lbl.add_theme_font_size_override("font_size", 9)
	tier_lbl.add_theme_color_override("font_color", t_col)
	tier_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bot_hbox.add_child(tier_lbl)
	
	var r_info = GameData.get_rarity_display_info(str(card.get("rarity", "Common")))
	var stars_lbl = Label.new()
	stars_lbl.text = str(r_info.get("stars", "⭐"))
	stars_lbl.add_theme_font_size_override("font_size", 9)
	stars_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	bot_hbox.add_child(stars_lbl)
	
	# Efecto Foil Holográfico continuo
	var rarity_str = str(card.get("rarity", "Common"))
	var foil_rect = GameData.apply_foil_overlay(container, rarity_str, true)
	if foil_rect:
		container.move_child(foil_rect, container.get_child_count() - 1)
		
	return container

func _open_showcase_picker_modal() -> void:
	temp_showcase_selection = GameData.get_profile_showcase().duplicate()
	_build_or_update_showcase_picker_ui()
	if showcase_picker_modal:
		showcase_picker_modal.visible = true

func _build_or_update_showcase_picker_ui() -> void:
	if showcase_picker_modal == null:
		showcase_picker_modal = Control.new()
		showcase_picker_modal.name = "ShowcasePickerModal"
		showcase_picker_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
		showcase_picker_modal.z_index = 95
		add_child(showcase_picker_modal)
		
	for c in showcase_picker_modal.get_children():
		c.queue_free()
		
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.06, 0.10, 0.95)
	showcase_picker_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	showcase_picker_modal.add_child(center)
	
	var card_panel = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(450, 620)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color(0.25, 0.52, 0.60)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	card_panel.add_theme_stylebox_override("panel", sb)
	center.add_child(card_panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	card_panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "⭐ CHOOSE SHOWCASE POKÉMON"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title)
	
	var sub_lbl = Label.new()
	sub_lbl.text = "Select up to 3 Pokémon from your collection (%d/3 selected)" % temp_showcase_selection.size()
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.45, 0.75, 0.95))
	vbox.add_child(sub_lbl)
	
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)
	
	# Población de Pokémon desbloqueados
	for cid in GameData.player_unlocked_ids:
		if not GameData.pokemon_catalog.has(cid):
			continue
		var card = GameData.pokemon_catalog[cid]
		var is_selected = cid in temp_showcase_selection
		var sel_idx = temp_showcase_selection.find(cid)
		
		var p_btn = Button.new()
		p_btn.custom_minimum_size = Vector2(98, 126)
		p_btn.focus_mode = Control.FOCUS_NONE
		p_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var type_key = str(card.get("type", "NORMAL")).to_upper()
		var theme = AssembledCardScript.TYPE_THEMES.get(type_key, AssembledCardScript.TYPE_THEMES["NORMAL"])
		
		var btn_sb = StyleBoxFlat.new()
		btn_sb.bg_color = theme["bg"]
		btn_sb.border_color = Color("#FFD700") if is_selected else theme["border"]
		btn_sb.set_border_width_all(3 if is_selected else 1)
		btn_sb.set_corner_radius_all(6)
		p_btn.add_theme_stylebox_override("normal", btn_sb)
		p_btn.add_theme_stylebox_override("hover", btn_sb)
		p_btn.add_theme_stylebox_override("pressed", btn_sb)
		
		var tex_file = str(card.get("texture_path", card.get("texture_file", "")))
		p_btn.icon = GameData.get_pokemon_texture(tex_file)
		p_btn.expand_icon = true
		p_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		p_btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		
		if is_selected:
			var sel_badge = PanelContainer.new()
			sel_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			sel_badge.position = Vector2(4, 4)
			var sb_badge = StyleBoxFlat.new()
			sb_badge.bg_color = Color(0, 0, 0, 0.85)
			sb_badge.border_color = Color("#FFD700")
			sb_badge.set_border_width_all(1)
			sb_badge.set_corner_radius_all(4)
			sel_badge.add_theme_stylebox_override("panel", sb_badge)
			var sel_lbl = Label.new()
			sel_lbl.text = "⭐ #%d" % (sel_idx + 1)
			sel_lbl.add_theme_font_size_override("font_size", 9)
			sel_lbl.add_theme_color_override("font_color", Color("#FFD700"))
			sel_badge.add_child(sel_lbl)
			p_btn.add_child(sel_badge)
			
		var c_id_cap = cid
		p_btn.pressed.connect(func():
			if GameData.is_drag_scrolling():
				return
			if c_id_cap in temp_showcase_selection:
				temp_showcase_selection.erase(c_id_cap)
			elif temp_showcase_selection.size() < 3:
				temp_showcase_selection.append(c_id_cap)
			_build_or_update_showcase_picker_ui()
		)
		grid.add_child(p_btn)
		
	# Barra de botones inferiores
	var bot_hbox = HBoxContainer.new()
	bot_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(bot_hbox)
	
	var btn_use_favs = Button.new()
	btn_use_favs.text = "⭐ Use Favorites"
	btn_use_favs.custom_minimum_size = Vector2(0, 36)
	btn_use_favs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_use_favs.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_use_favs, Color(0.85, 0.7, 0.2), Color(1.0, 0.85, 0.3))
	btn_use_favs.pressed.connect(func():
		temp_showcase_selection.clear()
		for fid in GameData.player_favorites:
			if temp_showcase_selection.size() < 3 and fid not in temp_showcase_selection:
				temp_showcase_selection.append(fid)
		if temp_showcase_selection.is_empty():
			for uid in GameData.player_unlocked_ids:
				if temp_showcase_selection.size() < 3 and uid not in temp_showcase_selection:
					temp_showcase_selection.append(uid)
		_build_or_update_showcase_picker_ui()
	)
	bot_hbox.add_child(btn_use_favs)
	
	var btn_clear = Button.new()
	btn_clear.text = "🗑️ Clear"
	btn_clear.custom_minimum_size = Vector2(65, 36)
	btn_clear.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_clear, Color(0.6, 0.3, 0.3), Color(0.8, 0.4, 0.4))
	btn_clear.pressed.connect(func():
		temp_showcase_selection.clear()
		_build_or_update_showcase_picker_ui()
	)
	bot_hbox.add_child(btn_clear)
	
	var btn_save = Button.new()
	btn_save.text = "💾 Save"
	btn_save.custom_minimum_size = Vector2(75, 36)
	btn_save.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_save, Color(0.2, 0.7, 0.3), Color(0.3, 0.9, 0.4))
	btn_save.pressed.connect(func():
		GameData.set_profile_showcase(temp_showcase_selection)
		GameData.save_profile(true)
		showcase_picker_modal.visible = false
		_update_profile_showcase_ui()
	)
	bot_hbox.add_child(btn_save)
	
	var btn_cancel = Button.new()
	btn_cancel.text = "Cancel"
	btn_cancel.custom_minimum_size = Vector2(65, 36)
	btn_cancel.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_cancel, Color(0.4, 0.4, 0.4), Color(0.6, 0.6, 0.6))
	btn_cancel.pressed.connect(func():
		showcase_picker_modal.visible = false
	)
	bot_hbox.add_child(btn_cancel)

# --- VISOR DEL PERFIL DE AMIGOS ---

func _open_friend_profile_modal(f_data: Dictionary) -> void:
	var f_alias = str(f_data.get("alias", "Trainer"))
	var f_email = str(f_data.get("email", ""))
	var f_id = str(f_data.get("id", ""))
	var query_key = f_email if not f_email.is_empty() else (f_id if not f_id.is_empty() else f_alias)
	
	_show_friend_profile_modal_loading(f_alias, f_email, f_id)
	
	CloudSync.fetch_public_trainer_profile(query_key, func(success: bool, save_data: Dictionary, err: String):
		if not is_instance_valid(self):
			return
		if success and not save_data.is_empty():
			_render_friend_profile_data(save_data, f_data)
		else:
			_show_friend_profile_modal_error(f_alias, err)
	)

func _show_friend_profile_modal_loading(f_alias: String, _f_email: String, _f_id: String) -> void:
	if friend_profile_modal == null:
		friend_profile_modal = Control.new()
		friend_profile_modal.name = "FriendProfileModal"
		friend_profile_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
		friend_profile_modal.z_index = 92
		add_child(friend_profile_modal)
		
	for c in friend_profile_modal.get_children():
		c.queue_free()
		
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.06, 0.10, 0.95)
	friend_profile_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	friend_profile_modal.add_child(center)
	
	var card_panel = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(440, 300)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color(0.25, 0.52, 0.60)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	card_panel.add_theme_stylebox_override("panel", sb)
	center.add_child(card_panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	card_panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "👤 TRAINER PROFILE: %s" % f_alias
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title)
	
	var spinner_lbl = Label.new()
	spinner_lbl.text = "⏳ Loading Trainer profile and cards from Google Cloud..."
	spinner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spinner_lbl.add_theme_font_size_override("font_size", 12)
	spinner_lbl.add_theme_color_override("font_color", Color(0.45, 0.75, 0.95))
	vbox.add_child(spinner_lbl)
	
	var btn_close = Button.new()
	btn_close.text = "Cancel"
	btn_close.custom_minimum_size = Vector2(100, 32)
	btn_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_apply_retro_button_style(btn_close, Color(0.4, 0.4, 0.4), Color(0.6, 0.6, 0.6))
	btn_close.pressed.connect(func(): friend_profile_modal.visible = false)
	vbox.add_child(btn_close)
	
	friend_profile_modal.visible = true

func _show_friend_profile_modal_error(f_alias: String, err_msg: String) -> void:
	if not friend_profile_modal:
		return
	for c in friend_profile_modal.get_children():
		c.queue_free()
		
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.06, 0.10, 0.95)
	friend_profile_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	friend_profile_modal.add_child(center)
	
	var card_panel = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(400, 240)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color(0.8, 0.3, 0.3)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	card_panel.add_theme_stylebox_override("panel", sb)
	center.add_child(card_panel)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	card_panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "👤 TRAINER PROFILE: %s" % f_alias
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title)
	
	var err_lbl = Label.new()
	err_lbl.text = "⚠️ Could not load profile from Google Cloud.\n%s" % err_msg
	err_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	err_lbl.add_theme_font_size_override("font_size", 12)
	err_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	vbox.add_child(err_lbl)
	
	var btn_close = Button.new()
	btn_close.text = "⬅ Back to Friends"
	btn_close.custom_minimum_size = Vector2(140, 36)
	btn_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_apply_retro_button_style(btn_close, Color(0.4, 0.4, 0.4), Color(0.6, 0.6, 0.6))
	btn_close.pressed.connect(func(): friend_profile_modal.visible = false)
	vbox.add_child(btn_close)

func _render_friend_profile_data(save_data: Dictionary, f_data: Dictionary) -> void:
	if not friend_profile_modal:
		return
	for c in friend_profile_modal.get_children():
		c.queue_free()
		
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.06, 0.10, 0.95)
	friend_profile_modal.add_child(bg)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	friend_profile_modal.add_child(center)
	
	var card_panel = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(440, 600)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.98)
	sb.border_color = Color(0.25, 0.52, 0.60)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	card_panel.add_theme_stylebox_override("panel", sb)
	center.add_child(card_panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card_panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	
	# Header
	var prof = save_data.get("profile", {})
	var alias = str(prof.get("trainer_alias", prof.get("name", f_data.get("alias", "Trainer")))).strip_edges()
	var email = str(prof.get("email", f_data.get("email", ""))).strip_edges()
	var p_id = str(prof.get("id", f_data.get("id", ""))).strip_edges()
	var act_val = prof.get("last_activity_at", f_data.get("last_activity_at", prof.get("updated_at", "")))
	
	var title = Label.new()
	title.text = "👤 TRAINER PROFILE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title)
	
	# Trainer info card
	var info_panel = PanelContainer.new()
	var sb_info = StyleBoxFlat.new()
	sb_info.bg_color = Color(0.06, 0.09, 0.14, 0.9)
	sb_info.border_color = Color(0.2, 0.4, 0.55)
	sb_info.set_border_width_all(1)
	sb_info.set_corner_radius_all(6)
	info_panel.add_theme_stylebox_override("panel", sb_info)
	vbox.add_child(info_panel)
	
	var info_margin = MarginContainer.new()
	info_margin.add_theme_constant_override("margin_left", 10)
	info_margin.add_theme_constant_override("margin_top", 8)
	info_margin.add_theme_constant_override("margin_right", 10)
	info_margin.add_theme_constant_override("margin_bottom", 8)
	info_panel.add_child(info_margin)
	
	var info_vbox = VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 3)
	info_margin.add_child(info_vbox)
	
	var name_lbl = Label.new()
	name_lbl.text = "Trainer: %s" % alias
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	info_vbox.add_child(name_lbl)
	
	var rel_act = GameData.format_relative_activity_time(act_val)
	var sub_lbl = Label.new()
	var sub_text = ("ID: " + p_id) if not p_id.is_empty() else "ID: ---"
	sub_text += "  •  🕒 " + rel_act
	sub_lbl.text = sub_text
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.45, 0.75, 0.95))
	info_vbox.add_child(sub_lbl)
	
	var f_email_clean = email.strip_edges().to_lower()
	var has_room = active_friend_rooms_map.has(f_email_clean)
	var is_active = (has_room or GameData.is_trainer_active(act_val))
	
	var act_row = HBoxContainer.new()
	act_row.add_theme_constant_override("separation", 8)
	var status_btn = _create_activity_status_button(is_active)
	act_row.add_child(status_btn)
	
	var cloud_status = Label.new()
	cloud_status.text = "Google Cloud Verified Trainer"
	cloud_status.add_theme_font_size_override("font_size", 11)
	cloud_status.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	act_row.add_child(cloud_status)
	info_vbox.add_child(act_row)
	
	# Stats card
	var stats = save_data.get("stats", {})
	var econ = save_data.get("economy", {})
	var col = save_data.get("collection", {})
	var unl_ids = col.get("unlocked_ids", [])
	
	var stats_panel_node = PanelContainer.new()
	var sb_stats = StyleBoxFlat.new()
	sb_stats.bg_color = Color(0.06, 0.09, 0.14, 0.9)
	sb_stats.border_color = Color(0.2, 0.4, 0.55)
	sb_stats.set_border_width_all(1)
	sb_stats.set_corner_radius_all(6)
	stats_panel_node.add_theme_stylebox_override("panel", sb_stats)
	vbox.add_child(stats_panel_node)
	
	var stats_margin = MarginContainer.new()
	stats_margin.add_theme_constant_override("margin_left", 10)
	stats_margin.add_theme_constant_override("margin_top", 8)
	stats_margin.add_theme_constant_override("margin_right", 10)
	stats_margin.add_theme_constant_override("margin_bottom", 8)
	stats_panel_node.add_child(stats_margin)
	
	var stats_grid = GridContainer.new()
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 16)
	stats_grid.add_theme_constant_override("v_separation", 4)
	stats_margin.add_child(stats_grid)
	
	var diamonds = int(econ.get("diamonds", 0))
	var candies = int(econ.get("rare_candies", 0))
	var tourneys = int(stats.get("tournaments_won", 0))
	var b_won = int(stats.get("battles_won", 0))
	var b_tot = int(stats.get("battles_total", 0))
	var win_rate = (float(b_won) / float(b_tot) * 100.0) if b_tot > 0 else 0.0
	var packs = int(stats.get("packs_opened", 0))
	var total_cards = max(1, GameData.pokemon_catalog.size())
	var col_pct = (float(unl_ids.size()) / float(total_cards)) * 100.0
	
	var stat_items = [
		"💎 Diamonds: %d" % diamonds,
		"🍬 Rare Candies: %d" % candies,
		"🏆 Tournaments Won: %d" % tourneys,
		"⚔️ Battles: %d/%d (%.0f%%)" % [b_won, b_tot, win_rate],
		"🎴 Cards: %d/%d (%.0f%%)" % [unl_ids.size(), total_cards, col_pct],
		"📦 Packs Opened: %d" % packs
	]
	for s_text in stat_items:
		var s_lbl = Label.new()
		s_lbl.text = s_text
		s_lbl.add_theme_font_size_override("font_size", 11)
		stats_grid.add_child(s_lbl)
		
	# Showcase Section con Foils
	var showcase_box = VBoxContainer.new()
	showcase_box.add_theme_constant_override("separation", 6)
	vbox.add_child(showcase_box)
	
	var sc_title = Label.new()
	sc_title.text = "⭐ TOP 3 FAVORITE POKÉMON"
	sc_title.add_theme_font_size_override("font_size", 13)
	sc_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	showcase_box.add_child(sc_title)
	
	var sc_slots_row = HBoxContainer.new()
	sc_slots_row.alignment = BoxContainer.ALIGNMENT_CENTER
	sc_slots_row.add_theme_constant_override("separation", 10)
	showcase_box.add_child(sc_slots_row)
	
	var f_showcase = save_data.get("favorite_showcase", prof.get("favorite_showcase", []))
	if typeof(f_showcase) != TYPE_ARRAY or f_showcase.is_empty():
		f_showcase = save_data.get("favorites", unl_ids)
		
	for i in range(3):
		var pid = int(f_showcase[i]) if (typeof(f_showcase) == TYPE_ARRAY and i < f_showcase.size()) else -1
		var c_node = _build_showcase_card_node(pid, i, false)
		sc_slots_row.add_child(c_node)
		
	# Botones de Acción
	var act_hbox = HBoxContainer.new()
	act_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(act_hbox)
	
	var btn_chal = Button.new()
	btn_chal.text = "⚔️ Challenge to Battle"
	btn_chal.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_chal.custom_minimum_size = Vector2(0, 38)
	btn_chal.add_theme_font_size_override("font_size", 12)
	_apply_retro_button_style(btn_chal, Color(0.85, 0.65, 0.15), Color(1.0, 0.8, 0.25))
	btn_chal.pressed.connect(func():
		friend_profile_modal.visible = false
		_challenge_friend(f_data)
	)
	act_hbox.add_child(btn_chal)
	
	var btn_close = Button.new()
	btn_close.text = "⬅ Back to Friends"
	btn_close.custom_minimum_size = Vector2(130, 38)
	btn_close.add_theme_font_size_override("font_size", 12)
	_apply_retro_button_style(btn_close, Color(0.4, 0.4, 0.4), Color(0.6, 0.6, 0.6))
	btn_close.pressed.connect(func():
		friend_profile_modal.visible = false
	)
	act_hbox.add_child(btn_close)

# --- MODAL MISIONES Y RECOMPENSAS DIARIAS ---
func _on_daily_missions_pressed() -> void:
	if not GameData.tutorial_completed and GameData.tutorial_step == 1:
		_start_tutorial_flow_or_settings()
		return
	GameData.check_and_update_daily_system()
	_update_daily_ui()
	daily_modal.visible = true

func _update_daily_ui() -> void:
	if not daily_modal:
		return
	GameData.check_and_update_daily_system()
	
	# 1. Streak badge
	if daily_streak_badge:
		daily_streak_badge.text = "🔥 Streak: Day %d/7" % GameData.daily_login_streak
		
	# 2. Calendario de 7 Días
	if calendar_grid:
		for c in calendar_grid.get_children():
			c.queue_free()
			
		var cur_day = GameData.daily_login_streak
		var claimed_today = GameData.daily_login_claimed_today
		
		for entry in GameData.DAILY_LOGIN_CALENDAR:
			var d_num = int(entry.get("day", 1))
			var d_lbl = str(entry.get("label", ""))
			
			var card = PanelContainer.new()
			card.custom_minimum_size = Vector2(66, 74)
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var card_sb = StyleBoxFlat.new()
			card_sb.set_corner_radius_all(6)
			
			var status_text = ""
			var status_color = Color.WHITE
			
			if d_num < cur_day:
				# Días pasados ya cobrados
				card_sb.bg_color = Color(0.08, 0.16, 0.12, 0.95)
				card_sb.border_color = Color(0.2, 0.7, 0.4, 0.8)
				card_sb.set_border_width_all(1)
				status_text = "✅ Done"
				status_color = Color(0.3, 1.0, 0.5)
			elif d_num == cur_day:
				# Día actual
				if claimed_today:
					card_sb.bg_color = Color(0.08, 0.16, 0.12, 0.95)
					card_sb.border_color = Color(0.2, 0.7, 0.4, 0.9)
					card_sb.set_border_width_all(2)
					status_text = "✅ Claimed"
					status_color = Color(0.3, 1.0, 0.5)
				else:
					card_sb.bg_color = Color(0.20, 0.18, 0.08, 0.98)
					card_sb.border_color = Color(1.0, 0.85, 0.2, 1.0)
					card_sb.set_border_width_all(2)
					status_text = "🎁 READY!"
					status_color = Color(1.0, 0.9, 0.3)
			else:
				# Días futuros bloqueados
				card_sb.bg_color = Color(0.06, 0.08, 0.12, 0.9)
				card_sb.border_color = Color(0.2, 0.28, 0.38, 0.6)
				card_sb.set_border_width_all(1)
				status_text = "🔒 Day %d" % d_num
				status_color = Color(0.5, 0.6, 0.7)
				
			card.add_theme_stylebox_override("panel", card_sb)
			
			var m = MarginContainer.new()
			m.add_theme_constant_override("margin_left", 4)
			m.add_theme_constant_override("margin_top", 4)
			m.add_theme_constant_override("margin_right", 4)
			m.add_theme_constant_override("margin_bottom", 4)
			card.add_child(m)
			
			var vb = VBoxContainer.new()
			vb.alignment = BoxContainer.ALIGNMENT_CENTER
			vb.add_theme_constant_override("separation", 2)
			m.add_child(vb)
			
			var day_title = Label.new()
			day_title.text = "DAY %d%s" % [d_num, " ⭐" if d_num == 7 else ""]
			day_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			day_title.add_theme_font_size_override("font_size", 10)
			day_title.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0) if d_num != 7 else Color(1.0, 0.85, 0.3))
			vb.add_child(day_title)
			
			var rew_lbl = Label.new()
			rew_lbl.text = d_lbl
			rew_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			rew_lbl.add_theme_font_size_override("font_size", 10)
			rew_lbl.add_theme_color_override("font_color", Color.WHITE)
			vb.add_child(rew_lbl)
			
			var st_lbl = Label.new()
			st_lbl.text = status_text
			st_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			st_lbl.add_theme_font_size_override("font_size", 9)
			st_lbl.add_theme_color_override("font_color", status_color)
			vb.add_child(st_lbl)
			
			calendar_grid.add_child(card)
			
	# Botón reclamar login reward
	if btn_claim_login_reward:
		if GameData.daily_login_claimed_today:
			btn_claim_login_reward.disabled = true
			btn_claim_login_reward.text = "✅ Today's Login Reward Claimed"
			btn_claim_login_reward.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
			if calendar_status_lbl:
				calendar_status_lbl.text = "Next reward available tomorrow!"
				calendar_status_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9))
		else:
			btn_claim_login_reward.disabled = false
			var idx = clampi(GameData.daily_login_streak - 1, 0, GameData.DAILY_LOGIN_CALENDAR.size() - 1)
			var r = GameData.DAILY_LOGIN_CALENDAR[idx]
			btn_claim_login_reward.text = "🎁 Claim Day %d Reward (%s)" % [GameData.daily_login_streak, r.get("label", "")]
			btn_claim_login_reward.add_theme_color_override("font_color", Color(0.2, 1.0, 0.5))
			if calendar_status_lbl:
				calendar_status_lbl.text = "🎁 Ready to claim now!"
				calendar_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
				
	# 3. Lista de 3 Misiones Diarias
	var reset_hint = daily_modal.find_child("MissionsResetHint", true, false)
	if reset_hint:
		reset_hint.text = "🗺️ Campaign Mode Only • ⏳ Resets daily"
	if missions_list_vbox:
		for c in missions_list_vbox.get_children():
			c.queue_free()
			
		for i in range(GameData.daily_missions.size()):
			var m = GameData.daily_missions[i]
			var card = _create_mission_row_card(i, m)
			missions_list_vbox.add_child(card)
			
	# 4. Cofre de Bonus Diario (+10 💎)
	var all_claimed = GameData.are_all_daily_missions_claimed()
	if chest_desc_lbl:
		var claimed_count = 0
		for m in GameData.daily_missions:
			if m.get("claimed", false):
				claimed_count += 1
		chest_desc_lbl.text = "Complete all 3 missions (%d/3 completed)" % claimed_count
		
	if btn_claim_chest:
		if GameData.daily_bonus_chest_claimed:
			btn_claim_chest.disabled = true
			btn_claim_chest.text = "✅ Claimed"
			btn_claim_chest.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7))
		elif all_claimed:
			btn_claim_chest.disabled = false
			btn_claim_chest.text = "🏆 Claim +10 💎"
			btn_claim_chest.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		else:
			btn_claim_chest.disabled = true
			btn_claim_chest.text = "🔒 Locked (+10 💎)"
			btn_claim_chest.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65))
			
	_update_lobby_header_badge()

func _create_mission_row_card(index: int, m: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	var card_sb = StyleBoxFlat.new()
	card_sb.bg_color = Color(0.08, 0.12, 0.18, 0.95)
	card_sb.border_color = Color(0.22, 0.38, 0.48, 0.8)
	card_sb.set_border_width_all(1)
	card_sb.set_corner_radius_all(8)
	card.add_theme_stylebox_override("panel", card_sb)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	margin.add_child(main_vbox)
	
	# Fila 1: Icono + Título + Recompensa Badge
	var top_row = HBoxContainer.new()
	main_vbox.add_child(top_row)
	
	var title_lbl = Label.new()
	title_lbl.text = "%s %s" % [m.get("icon", "🎯"), m.get("title", "Daily Mission")]
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	top_row.add_child(title_lbl)
	
	var rew_badge = Label.new()
	rew_badge.text = "+%d 💎" % int(m.get("reward_diamonds", 5))
	rew_badge.add_theme_font_size_override("font_size", 12)
	rew_badge.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0))
	top_row.add_child(rew_badge)
	
	# Fila 2: Descripción del objetivo
	var desc_lbl = Label.new()
	desc_lbl.text = m.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.75, 0.85, 0.95))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(desc_lbl)
	
	# Fila 3: Barra de Progreso + Botón Swap / Claim
	var bottom_row = HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 8)
	main_vbox.add_child(bottom_row)
	
	var cur = int(m.get("current", 0))
	var target = max(1, int(m.get("target", 1)))
	var is_claimed = bool(m.get("claimed", false))
	var is_ready = (cur >= target and not is_claimed)
	
	var prog_vbox = VBoxContainer.new()
	prog_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prog_vbox.add_theme_constant_override("separation", 2)
	bottom_row.add_child(prog_vbox)
	
	var prog_bar = ProgressBar.new()
	prog_bar.custom_minimum_size = Vector2(0, 10)
	prog_bar.max_value = target
	prog_bar.value = cur
	prog_bar.show_percentage = false
	prog_vbox.add_child(prog_bar)
	
	var prog_lbl = Label.new()
	prog_lbl.text = "Progress: %d / %d" % [cur, target]
	prog_lbl.add_theme_font_size_override("font_size", 10)
	prog_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5) if is_ready or is_claimed else Color(0.6, 0.7, 0.8))
	prog_vbox.add_child(prog_lbl)
	
	if is_claimed:
		var done_btn = Button.new()
		done_btn.text = "✅ Claimed"
		done_btn.disabled = true
		done_btn.custom_minimum_size = Vector2(96, 28)
		done_btn.add_theme_font_size_override("font_size", 11)
		bottom_row.add_child(done_btn)
	elif is_ready:
		var claim_btn = Button.new()
		claim_btn.text = "✨ Claim 💎"
		claim_btn.custom_minimum_size = Vector2(96, 28)
		claim_btn.add_theme_font_size_override("font_size", 11)
		claim_btn.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
		claim_btn.pressed.connect(func():
			GameData.claim_daily_mission_reward(index)
			_update_daily_ui()
		)
		bottom_row.add_child(claim_btn)
	else:
		# Botón de Swap (💎 1)
		var swap_btn = Button.new()
		swap_btn.text = "🔄 Swap (1 💎)"
		swap_btn.custom_minimum_size = Vector2(96, 28)
		swap_btn.add_theme_font_size_override("font_size", 11)
		swap_btn.add_theme_color_override("font_color", Color(1.0, 0.75, 0.3))
		swap_btn.pressed.connect(func():
			var res = GameData.swap_daily_mission(index)
			if res.get("success", false):
				_update_daily_ui()
			else:
				var tw = swap_btn.create_tween()
				swap_btn.modulate = Color(1.0, 0.3, 0.3)
				tw.tween_property(swap_btn, "modulate", Color.WHITE, 0.3)
		)
		bottom_row.add_child(swap_btn)
		
	return card

func _on_claim_login_reward_pressed() -> void:
	var res = GameData.claim_daily_login_reward()
	if res.get("success", false):
		_update_daily_ui()

func _on_claim_chest_pressed() -> void:
	var res = GameData.claim_daily_bonus_chest()
	if res.get("success", false):
		_update_daily_ui()

# ==============================================================================
# --- SISTEMA DE AMIGOS (FRIENDS SYSTEM & MATCHMAKING DIRECTO) ---
# ==============================================================================

func _open_friends_modal() -> void:
	friends_modal.visible = true
	_show_my_friends_tab()
	_refresh_friends_and_rooms()

func _show_my_friends_tab() -> void:
	friends_active_tab = "MY_FRIENDS"
	friends_content_scroll.visible = true
	search_results_scroll.visible = false
	_style_toggle_btn(btn_tab_my_friends, true, Color("#4CAF50"))
	_style_toggle_btn(btn_tab_search_results, false, Color("#2196F3"))
	_update_friends_ui()

func _show_search_results_tab() -> void:
	friends_active_tab = "SEARCH"
	friends_content_scroll.visible = false
	search_results_scroll.visible = true
	_style_toggle_btn(btn_tab_my_friends, false, Color("#4CAF50"))
	_style_toggle_btn(btn_tab_search_results, true, Color("#2196F3"))
	_populate_search_results_ui()

func _refresh_friends_and_rooms() -> void:
	friends_feedback_lbl.text = "⏳ Syncing friends and live matches with Google Cloud..."
	
	# Consultar salas de amigos activas o retos directos
	var my_email = GameData.profile_email if GameData else ""
	CloudSync.fetch_friend_rooms(GameData.player_friends, my_email, func(success: bool, data: Dictionary, _msg: String):
		if success:
			active_friend_rooms_map.clear()
			var d_invites = data.get("direct_invites", [])
			var f_rooms = data.get("friend_rooms", [])
			
			# Mapear salas por email del anfitrión
			for r in f_rooms:
				var he = str(r.get("host_email", "")).strip_edges().to_lower()
				if not he.is_empty():
					active_friend_rooms_map[he] = r
					
			# Revisar retos directos dirigidos a mí
			if d_invites.size() > 0:
				active_direct_challenge = d_invites[0]
				challenge_banner.visible = true
				challenge_desc.text = "Host: %s  •  Room: %s  •  Click ACCEPT to battle!" % [
					active_direct_challenge.get("host_name", "Friend"),
					active_direct_challenge.get("room_code", "")
				]
				friends_feedback_lbl.text = "🔔 Challenge received from %s! Room: %s" % [
					active_direct_challenge.get("host_name", "Friend"),
					active_direct_challenge.get("room_code", "")
				]
			else:
				challenge_banner.visible = false
				active_direct_challenge.clear()
				friends_feedback_lbl.text = "💡 Tip: Click '⚔️ Challenge' on any friend to start an instant online battle!"
		else:
			friends_feedback_lbl.text = "⚠️ Could not connect to Google Cloud to refresh live rooms."
			
		_update_friends_ui()
	)

func _update_friends_ui() -> void:
	var friends = GameData.player_friends
	friends_count_badge.text = "Friends: %d" % friends.size()
	btn_tab_my_friends.text = "👥 My Friends (%d)" % friends.size()
	
	for child in friends_list_vbox.get_children():
		child.queue_free()
		
	if friends.is_empty():
		var empty_panel = PanelContainer.new()
		var ep_sb = StyleBoxFlat.new()
		ep_sb.bg_color = Color(0.08, 0.11, 0.16, 0.9)
		ep_sb.set_border_width_all(1)
		ep_sb.border_color = Color(0.2, 0.3, 0.45)
		ep_sb.set_corner_radius_all(10)
		empty_panel.add_theme_stylebox_override("panel", ep_sb)
		
		var ep_margin = MarginContainer.new()
		ep_margin.add_theme_constant_override("margin_left", 20)
		ep_margin.add_theme_constant_override("margin_top", 24)
		ep_margin.add_theme_constant_override("margin_right", 20)
		ep_margin.add_theme_constant_override("margin_bottom", 24)
		empty_panel.add_child(ep_margin)
		
		var ep_vbox = VBoxContainer.new()
		ep_vbox.add_theme_constant_override("separation", 8)
		ep_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		ep_margin.add_child(ep_vbox)
		
		var ep_icon = Label.new()
		ep_icon.text = "👥"
		ep_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ep_icon.add_theme_font_size_override("font_size", 28)
		ep_vbox.add_child(ep_icon)
		
		var ep_title = Label.new()
		ep_title.text = "No Friends Added Yet"
		ep_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ep_title.add_theme_font_size_override("font_size", 15)
		ep_title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		ep_vbox.add_child(ep_title)
		
		var ep_desc = Label.new()
		ep_desc.text = "Search for other players above by their Google Email or Trainer Alias and add them to challenge them to battles easily!"
		ep_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ep_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ep_desc.add_theme_font_size_override("font_size", 12)
		ep_desc.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
		ep_vbox.add_child(ep_desc)
		
		friends_list_vbox.add_child(empty_panel)
		return
		
	for f in friends:
		var card = _create_friend_card(f)
		friends_list_vbox.add_child(card)

func _create_friend_card(f_data: Dictionary) -> Control:
	var card = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.18, 0.95)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.2, 0.4, 0.6)
	sb.set_corner_radius_all(8)
	card.add_theme_stylebox_override("panel", sb)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)
	
	# Icono Avatar
	var avatar_lbl = Label.new()
	avatar_lbl.text = "👤"
	avatar_lbl.add_theme_font_size_override("font_size", 22)
	avatar_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(avatar_lbl)
	
	# Información del amigo
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)
	
	var alias = str(f_data.get("alias", "Trainer"))
	var email = str(f_data.get("email", ""))
	var p_id = str(f_data.get("id", ""))
	var act_val = f_data.get("last_activity_at", f_data.get("updated_at", ""))
	
	var name_lbl = Label.new()
	name_lbl.text = alias
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1, 0.88, 0.35))
	info_vbox.add_child(name_lbl)
	
	var rel_act = GameData.format_relative_activity_time(act_val)
	var sub_lbl = Label.new()
	var sub_text = ("ID: " + p_id) if not p_id.is_empty() else "ID: ---"
	sub_text += "  •  🕒 " + rel_act
	sub_lbl.text = sub_text
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.45, 0.75, 0.95))
	info_vbox.add_child(sub_lbl)
	
	# ¿Tiene este amigo una sala esperando?
	var f_email_clean = email.strip_edges().to_lower()
	var has_room = active_friend_rooms_map.has(f_email_clean)
	var active_room = active_friend_rooms_map.get(f_email_clean, {}) if has_room else {}
	
	if has_room:
		var status_lbl = Label.new()
		status_lbl.text = "🟢 Waiting in Room: %s" % active_room.get("room_code", "")
		status_lbl.add_theme_font_size_override("font_size", 11)
		status_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.45))
		info_vbox.add_child(status_lbl)
		
	# Acciones a la derecha
	var actions_hbox = HBoxContainer.new()
	actions_hbox.add_theme_constant_override("separation", 6)
	hbox.add_child(actions_hbox)
	
	# Botón de Estado Activo/Inactivo
	var is_active = (has_room or GameData.is_trainer_active(act_val))
	var status_btn = _create_activity_status_button(is_active)
	actions_hbox.add_child(status_btn)
	
	# Botón Ver Perfil
	var profile_btn = Button.new()
	profile_btn.text = "👁️ Profile"
	profile_btn.custom_minimum_size = Vector2(75, 34)
	profile_btn.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(profile_btn, Color(0.2, 0.6, 0.8), Color(0.3, 0.8, 1.0))
	profile_btn.pressed.connect(func():
		_open_friend_profile_modal(f_data)
	)
	actions_hbox.add_child(profile_btn)
	
	if has_room:
		# Botón para unirse a la sala activa de este amigo
		var join_btn = Button.new()
		join_btn.text = "⚡ Join (%s)" % active_room.get("room_code", "")
		join_btn.custom_minimum_size = Vector2(100, 34)
		join_btn.add_theme_font_size_override("font_size", 11)
		join_btn.add_theme_color_override("font_color", Color(0.3, 1.0, 0.45))
		join_btn.pressed.connect(func():
			_join_friend_room(str(active_room.get("room_code", "")))
		)
		actions_hbox.add_child(join_btn)
	else:
		# Botón Desafiar / Crear sala invitando a este amigo
		var challenge_btn = Button.new()
		challenge_btn.text = "⚔️ Challenge"
		challenge_btn.custom_minimum_size = Vector2(95, 34)
		challenge_btn.add_theme_font_size_override("font_size", 11)
		challenge_btn.add_theme_color_override("font_color", Color(1.0, 0.8, 0.25))
		challenge_btn.pressed.connect(func():
			_challenge_friend(f_data)
		)
		actions_hbox.add_child(challenge_btn)
		
	# Botón Eliminar amigo
	var remove_btn = Button.new()
	remove_btn.text = "🗑️"
	remove_btn.tooltip_text = "Remove from Friends"
	remove_btn.custom_minimum_size = Vector2(36, 34)
	remove_btn.add_theme_font_size_override("font_size", 12)
	remove_btn.pressed.connect(func():
		var rem_id = email if not email.is_empty() else alias
		GameData.remove_friend(rem_id)
		_update_friends_ui()
	)
	actions_hbox.add_child(remove_btn)
	
	return card

func _on_search_friend_pressed() -> void:
	var query = friend_search_input.text.strip_edges()
	friends_feedback_lbl.text = "⏳ Searching trainers in Google Cloud (Firebase)..."
	btn_search_friend.disabled = true
	
	CloudSync.search_trainers(query, func(success: bool, results: Array, msg: String):
		btn_search_friend.disabled = false
		if success:
			last_search_results = results
			btn_tab_search_results.text = "🔍 Results (%d)" % results.size()
			_show_search_results_tab()
			if results.is_empty():
				if query.is_empty():
					friends_feedback_lbl.text = "⚠️ No other trainers registered in Google Cloud yet."
				else:
					friends_feedback_lbl.text = "⚠️ No trainers found matching '%s'." % query
			else:
				if query.is_empty():
					friends_feedback_lbl.text = "✅ Showing all registered trainers (%d total)" % results.size()
				else:
					friends_feedback_lbl.text = "✅ Found %d trainer(s)!" % results.size()
		else:
			friends_feedback_lbl.text = "❌ Search error: %s" % msg
	)

func _on_clear_search_pressed() -> void:
	friend_search_input.text = ""
	last_search_results.clear()
	btn_tab_search_results.text = "🔍 Search Results"
	_show_my_friends_tab()

func _populate_search_results_ui() -> void:
	for child in search_results_vbox.get_children():
		child.queue_free()
		
	if last_search_results.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "No search results to display.\nType a trainer's Google Email or Alias above and click 'Search'!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_lbl.add_theme_font_size_override("font_size", 13)
		empty_lbl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
		search_results_vbox.add_child(empty_lbl)
		return
		
	for res in last_search_results:
		var card = _create_search_result_card(res)
		search_results_vbox.add_child(card)

func _create_search_result_card(res_data: Dictionary) -> Control:
	var card = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.13, 0.2, 0.95)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.25, 0.45, 0.65)
	sb.set_corner_radius_all(8)
	card.add_theme_stylebox_override("panel", sb)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	card.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	margin.add_child(hbox)
	
	var avatar_lbl = Label.new()
	avatar_lbl.text = "🎮"
	avatar_lbl.add_theme_font_size_override("font_size", 20)
	avatar_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(avatar_lbl)
	
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)
	
	var alias = str(res_data.get("alias", "Trainer"))
	var email = str(res_data.get("email", ""))
	var p_id = str(res_data.get("id", ""))
	var act_val = res_data.get("last_activity_at", "")
	
	var name_lbl = Label.new()
	name_lbl.text = alias
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1))
	info_vbox.add_child(name_lbl)
	
	var rel_act = GameData.format_relative_activity_time(act_val)
	var sub_lbl = Label.new()
	var sub_text = ("ID: " + p_id) if not p_id.is_empty() else "ID: ---"
	if not rel_act.is_empty() and rel_act != "Desconocido" and rel_act != "Unknown":
		sub_text += "  •  🕒 " + rel_act
	sub_lbl.text = sub_text
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	info_vbox.add_child(sub_lbl)
	
	# Acciones
	var is_self = bool(res_data.get("is_self", false))
	var is_already = GameData.is_friend(email) or GameData.is_friend(p_id) or GameData.is_friend(alias)
	var is_active = is_self or GameData.is_trainer_active(act_val)
	
	var status_btn = _create_activity_status_button(is_active)
	hbox.add_child(status_btn)
	
	if not is_self:
		var profile_btn = Button.new()
		profile_btn.text = "👁️ Profile"
		profile_btn.custom_minimum_size = Vector2(75, 34)
		profile_btn.add_theme_font_size_override("font_size", 11)
		_apply_retro_button_style(profile_btn, Color(0.2, 0.6, 0.8), Color(0.3, 0.8, 1.0))
		profile_btn.pressed.connect(func():
			_open_friend_profile_modal(res_data)
		)
		hbox.add_child(profile_btn)
		
	var add_btn = Button.new()
	add_btn.custom_minimum_size = Vector2(110, 34)
	add_btn.add_theme_font_size_override("font_size", 11)
	
	if is_self:
		name_lbl.text = "%s  👤 (Your Profile)" % alias
		name_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		add_btn.text = "👤 (Your Profile)"
		add_btn.disabled = true
		add_btn.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85))
	elif is_already:
		add_btn.text = "✓ Friends"
		add_btn.disabled = true
		add_btn.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
	else:
		add_btn.text = "➕ Add Friend"
		add_btn.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		add_btn.pressed.connect(func():
			GameData.add_friend(alias, email, p_id)
			add_btn.text = "✓ Added!"
			add_btn.disabled = true
			add_btn.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
			friends_feedback_lbl.text = "✨ '%s' added to your friends list!" % alias
			_update_friends_ui()
		)
	hbox.add_child(add_btn)
	
	return card

func _challenge_friend(f_data: Dictionary) -> void:
	# Asegurar que el jugador tenga al menos 1 Pokémon seleccionado
	if selected_player_ids.is_empty():
		for id in GameData.player_unlocked_ids:
			if selected_player_ids.size() < 3:
				selected_player_ids.append(id)
				
	team_select_mode = "ONLINE"
	friends_modal.visible = false
	online_lobby_modal.visible = true
	
	_is_online_match_launching = false
	btn_tab_create_room.button_pressed = true
	btn_tab_join_room.button_pressed = false
	_style_toggle_btn(btn_tab_create_room, true, Color("#4CAF50"))
	_style_toggle_btn(btn_tab_join_room, false, Color("#2196F3"))
	host_panel.visible = true
	join_panel.visible = false
	
	room_code_lbl.text = "...."
	host_status_lbl.text = "⚔️ Challenging %s...\nCreating room in Google Cloud..." % f_data.get("alias", "Friend")
	
	if host_rival_info_lbl:
		host_rival_info_lbl.text = "👤 Rival: %s (Direct Challenge)" % f_data.get("alias", "Friend")
	if host_rival_ready_badge:
		host_rival_ready_badge.text = "🔴 Rival: Waiting to join..."
		host_rival_ready_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
	if btn_host_start_battle:
		btn_host_start_battle.disabled = true
		btn_host_start_battle.text = "⚔️ Waiting for rival to be READY..."
		_apply_retro_button_style(btn_host_start_battle, Color(0.3, 0.4, 0.5), Color(0.3, 0.4, 0.5))
		
	_update_lobby_teams_ui()
	
	OnlineManager.create_room(GameData.profile_name, selected_player_ids, func(success: bool, code: String):
		if success:
			room_code_lbl.text = code
			host_status_lbl.text = "⚔️ Challenged %s!\nRoom Code: %s\nWaiting for %s to join..." % [
				f_data.get("alias", "Friend"),
				code,
				f_data.get("alias", "Friend")
			]
			print("[Friends] Room %s created targeting friend %s" % [code, f_data.get("alias")])
		else:
			room_code_lbl.text = "ERR"
			host_status_lbl.text = "❌ Error creating online room."
	, f_data)

func _join_friend_room(r_code: String) -> void:
	if r_code.is_empty():
		return
	if selected_player_ids.is_empty():
		for id in GameData.player_unlocked_ids:
			if selected_player_ids.size() < 3:
				selected_player_ids.append(id)
				
	team_select_mode = "ONLINE"
	friends_modal.visible = false
	online_lobby_modal.visible = true
	_show_online_join_tab()
	join_code_input.text = r_code
	_on_confirm_join_pressed()

func _on_accept_direct_challenge_pressed() -> void:
	var r_code = str(active_direct_challenge.get("room_code", ""))
	if r_code.is_empty():
		return
	challenge_banner.visible = false
	_join_friend_room(r_code)

func _on_decline_direct_challenge_pressed() -> void:
	challenge_banner.visible = false
	active_direct_challenge.clear()
	friends_feedback_lbl.text = "Challenge dismissed."
