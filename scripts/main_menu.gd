extends Control

const AssembledCardScript = preload("res://scripts/assembled_card.gd")

# --- REFERENCIAS DE BOTONES DEL MENÚ ---
@onready var trainer_status_badge: Label = $ContentContainer/HeaderContainer/TrainerStatusBadge
@onready var btn_campaign: Button = $ContentContainer/MenuButtons/BtnCampaign
@onready var btn_quick_battle: Button = $ContentContainer/MenuButtons/BtnQuickBattle
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
@onready var btn_close_team_select: Button = $TeamSelectModal/Box/Actions/BtnCloseTeamSelect

# --- MODAL CAMPAIGN HUB (TORNEO & AVENTURA) ---
@onready var campaign_hub_modal: Control = $CampaignHubModal
@onready var tourn_status_lbl: Label = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardTournament/Margin/TournVBox/TournStatus
@onready var btn_hub_tournament: Button = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardTournament/Margin/TournVBox/BtnHubTournament
@onready var ep1_status_lbl: Label = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventureEp1/Margin/Ep1VBox/Ep1Status
@onready var btn_hub_adventure_ep1: Button = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventureEp1/Margin/Ep1VBox/BtnHubAdventureEp1
@onready var ep2_status_lbl: Label = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventureEp2/Margin/Ep2VBox/Ep2Status
@onready var btn_hub_adventure_ep2: Button = $CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventureEp2/Margin/Ep2VBox/BtnHubAdventureEp2
@onready var btn_close_campaign_hub: Button = $CampaignHubModal/Box/BtnCloseCampaignHub

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
@onready var campaign_revive_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox/ReviveRow/ReviveIcon
@onready var campaign_revive_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox/ReviveRow/ReviveInfo/ReviveCountLbl
@onready var btn_buy_revive: Button = $CampaignModal/Box/ShopSection/ShopVBox/ReviveRow/BtnBuyRevive
@onready var campaign_remedy_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox/RemedyRow/RemedyIcon
@onready var campaign_remedy_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox/RemedyRow/RemedyInfo/RemedyCountLbl
@onready var btn_buy_remedy: Button = $CampaignModal/Box/ShopSection/ShopVBox/RemedyRow/BtnBuyRemedy
@onready var campaign_ether_icon: TextureRect = $CampaignModal/Box/ShopSection/ShopVBox/EtherRow/EtherIcon
@onready var campaign_ether_count_lbl: Label = $CampaignModal/Box/ShopSection/ShopVBox/EtherRow/EtherInfo/EtherCountLbl
@onready var btn_buy_ether: Button = $CampaignModal/Box/ShopSection/ShopVBox/EtherRow/BtnBuyEther
@onready var btn_start_campaign_battle: Button = $CampaignModal/Box/ActionsBox/BtnStartCampaignBattle
@onready var btn_change_campaign_team: Button = $CampaignModal/Box/ActionsBox/NavRow/BtnChangeCampaignTeam
@onready var btn_reset_campaign: Button = $CampaignModal/Box/ActionsBox/BtnResetCampaign
@onready var btn_close_campaign: Button = $CampaignModal/Box/ActionsBox/NavRow/BtnCloseCampaign

# --- CAMP TOOLBAR & MODALS (SHOP, MOCHILA, INSPECTOR) ---
var camp_toolbar: HBoxContainer = null
var btn_camp_shop: Button = null
var btn_camp_bag: Button = null
var camp_shop_modal: Control = null
var camp_shop_gold_lbl: Label = null
var camp_bag_modal: Control = null
var camp_bag_items_view: VBoxContainer = null
var camp_bag_targets_view: VBoxContainer = null
var camp_bag_targets_container: VBoxContainer = null
var camp_bag_prompt_lbl: Label = null
var camp_bag_selected_item: String = ""
var camp_pokemon_inspector_modal: Control = null

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
var shop_active_tab: String = "PACKS" # "PACKS", "RECYCLE", "HIDDEN"
var hidden_shop_filter: String = "ALL"
var shop_tabs_row: HBoxContainer = null
var btn_shop_tab_packs: Button = null
var btn_shop_tab_recycle: Button = null
var btn_shop_tab_hidden: Button = null
var packs_container: VBoxContainer = null
var recycle_container: VBoxContainer = null
var hidden_shop_container: VBoxContainer = null
var btn_bulk_recycle: Button = null
var recycle_scroll_list: VBoxContainer = null
var recycle_empty_lbl: Label = null
var hidden_shop_grid: GridContainer = null
var hidden_filter_buttons: Dictionary = {}
var stat_candies_lbl: Label = null

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
@onready var btn_close_profile: Button = $ProfileModal/ProfileBox/BtnCloseProfile

# --- MODAL AJUSTES / CONFIGURACIÓN ---
@onready var settings_modal: Control = $SettingsModal
@onready var music_vol_value_lbl: Label = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/MusicVolHeaderRow/MusicVolValueLbl
@onready var music_slider: HSlider = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/MusicSlider
@onready var mute_music_check: CheckBox = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/MuteMusicCheck
@onready var sfx_vol_value_lbl: Label = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/SfxVolHeaderRow/SfxVolValueLbl
@onready var sfx_slider: HSlider = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/SfxSlider
@onready var mute_sfx_check: CheckBox = $SettingsModal/SettingsBox/AudioPanel/AudioVBox/MuteSfxCheck
@onready var btn_close_settings: Button = $SettingsModal/SettingsBox/BtnCloseSettings

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
@onready var cloud_feedback_lbl: Label = $CloudNoticeModal/CloudCard/CloudVBox/CloudFeedbackLbl
@onready var btn_cloud_confirm: Button = $CloudNoticeModal/CloudCard/CloudVBox/BtnCloudConfirm
@onready var btn_launch_browser_auth: Button = $CloudNoticeModal/CloudCard/CloudVBox/BtnLaunchBrowserAuth
@onready var btn_toggle_manual_auth: Button = $CloudNoticeModal/CloudCard/CloudVBox/BtnToggleManualAuth
@onready var btn_close_cloud_notice: Button = $CloudNoticeModal/CloudCard/CloudVBox/BtnCloseCloudNotice
var cloud_action_mode: String = "SIGNUP_GOOGLE"
var is_manual_cloud_mode: bool = false

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
@onready var host_panel: VBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel
@onready var room_code_box: PanelContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/RoomCodeBox
@onready var room_code_lbl: Label = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/RoomCodeBox/RoomCodeLbl
@onready var host_status_lbl: Label = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/HostPanel/HostStatusLbl
@onready var join_panel: VBoxContainer = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel
@onready var join_code_input: LineEdit = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/JoinCodeInput
@onready var btn_confirm_join: Button = $OnlineLobbyModal/OnlineCenter/OnlineCard/OnlineMargin/OnlineVBox/JoinPanel/BtnConfirmJoin
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

var btn_qb_mode_online: Button = null
var qb_selected_mode: String = "AI" # "AI", "PVP", "ONLINE"

# --- AUDIO DE FONDO (BGM) ---
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer

# Datos de cartas (se cargan dinámicamente desde el CSV)
var cards_data: Array = [] # Cartas desbloqueadas del jugador
var all_catalog_cards: Array = [] # Todo el catálogo (para Mi Colección y Rival IA)
var current_collection_index: int = 0
var collection_sort_mode: String = "ID" # "ID", "DEX", "NAME"
var current_sorted_collection: Array = []

# Filtros de Colección (Owned, Types, Stages, Rarity, Tier)
var col_filter_owned: String = "ALL" # "ALL", "OWNED", "MISSING"
var col_filter_type: String = "ALL" # "ALL", "NORMAL", "GRASS", "FIRE", "WATER", "ELECTRIC", "DARK", "PSYCHIC", "FIGHTING", "GROUND"
var col_filter_stage: String = "ALL" # "ALL", "BASIC", "STAGE 1", "STAGE 2"
var col_filter_rarity: String = "ALL" # "ALL", "COMMON", "RARE", "EPIC", "LEGENDARY"
var col_filter_tier: String = "ALL" # "ALL", "S+", "S", "A", "B", "C", "D"

var collection_filter_panel: PanelContainer = null
var opt_col_owned: OptionButton = null
var opt_col_type: OptionButton = null
var opt_col_stage: OptionButton = null
var opt_col_rarity: OptionButton = null
var opt_col_tier: OptionButton = null
var btn_col_reset_filters: Button = null

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
	btn_collection.pressed.connect(_on_collection_pressed)
	btn_shop.pressed.connect(_on_shop_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	# Modal Selección de Equipo
	btn_tab_player.pressed.connect(_on_tab_player_pressed)
	btn_tab_enemy.pressed.connect(_on_tab_enemy_pressed)
	btn_random_enemy.pressed.connect(_randomize_enemy_team)
	btn_start_battle.pressed.connect(_on_start_battle_pressed)
	btn_close_team_select.pressed.connect(_on_close_team_select_pressed)
	btn_team_sort_id.pressed.connect(func(): _on_team_sort_pressed("ID"))
	btn_team_sort_dex.pressed.connect(func(): _on_team_sort_pressed("DEX"))
	btn_team_sort_alpha.pressed.connect(func(): _on_team_sort_pressed("NAME"))
	btn_team_sort_rarity.pressed.connect(func(): _on_team_sort_pressed("RARITY"))
	btn_team_sort_evo.pressed.connect(func(): _on_team_sort_pressed("EVO"))
	update_team_sort_buttons_ui()
	
	# Modal Campaign Hub
	btn_hub_tournament.pressed.connect(_on_select_tournament_pressed)
	btn_hub_adventure_ep1.pressed.connect(_on_select_adventure_ep1_pressed)
	btn_close_campaign_hub.pressed.connect(func():
		campaign_hub_modal.visible = false
		_update_lobby_header_badge()
	)
	for card_path in [
		"CampaignHubModal/Box/ModesScroll/ModesVBox/CardTournament",
		"CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventureEp1",
		"CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventureEp2"
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
	btn_buy_remedy.pressed.connect(_on_buy_remedy_pressed)
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
		update_campaign_hub_ui()
		campaign_hub_modal.visible = true
		_update_lobby_header_badge()
	)
	
	campaign_item_icon.texture = GameData.get_item_texture("potion")
	campaign_remedy_icon.texture = GameData.get_item_texture("remedy")
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
	btn_close_profile.pressed.connect(func(): profile_modal.visible = false)
	trainer_name_input.text_submitted.connect(func(_t): _on_save_progress_pressed())
	if btn_link_google:
		btn_link_google.pressed.connect(func():
			profile_modal.visible = false
			_on_sign_up_google_pressed()
		)
	
	# Modal Ajustes
	btn_close_settings.pressed.connect(func(): settings_modal.visible = false)
	music_slider.value_changed.connect(_on_music_slider_changed)
	mute_music_check.toggled.connect(_on_mute_music_toggled)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	mute_sfx_check.toggled.connect(_on_mute_sfx_toggled)
	
	# Modal Confirmar Borrado de Perfil
	btn_cancel_erase.pressed.connect(func(): erase_confirm_modal.visible = false)
	btn_confirm_erase.pressed.connect(_on_confirm_erase_pressed)
	
	# Modal Login & Google Sign-Up
	btn_login_play.pressed.connect(_on_login_play_pressed)
	btn_login_cloud.pressed.connect(_on_login_cloud_pressed)
	btn_sign_up_google.pressed.connect(_on_sign_up_google_pressed)
	btn_cloud_confirm.pressed.connect(_on_cloud_confirm_pressed)
	if btn_launch_browser_auth:
		btn_launch_browser_auth.pressed.connect(_launch_google_browser_oauth)
	if btn_toggle_manual_auth:
		btn_toggle_manual_auth.pressed.connect(_toggle_manual_cloud_mode)
	btn_close_cloud_notice.pressed.connect(func():
		CloudSync.stop_google_oauth_server()
		cloud_notice_modal.visible = false
	)
	cloud_trainer_input.text_submitted.connect(func(_t): _on_cloud_confirm_pressed())
	if cloud_email_input:
		cloud_email_input.text_submitted.connect(func(_t): _on_cloud_confirm_pressed())
	if not CloudSync.google_oauth_completed.is_connected(_on_google_oauth_completed):
		CloudSync.google_oauth_completed.connect(_on_google_oauth_completed)
	
	# Modal Bienvenida (Regalo 15 Gemas)
	btn_welcome_go_shop.pressed.connect(_on_welcome_go_shop_pressed)
	btn_welcome_enter_lobby.pressed.connect(func(): welcome_modal.visible = false)
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
	join_code_input.text_submitted.connect(func(_t): _on_confirm_join_pressed())
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
	btn_tab_my_friends.pressed.connect(_show_my_friends_tab)
	btn_tab_search_results.pressed.connect(_show_search_results_tab)
	btn_refresh_friends.pressed.connect(_refresh_friends_and_rooms)
	btn_accept_challenge.pressed.connect(_on_accept_direct_challenge_pressed)
	btn_decline_challenge.pressed.connect(_on_decline_direct_challenge_pressed)
	GameData.friends_updated.connect(_update_friends_ui)
	friends_modal.visible = false
	
	# Ocultar modales al inicio
	campaign_hub_modal.visible = false
	team_select_modal.visible = false
	campaign_modal.visible = false
	collection_modal.visible = false
	shop_modal.visible = false
	profile_modal.visible = false
	settings_modal.visible = false
	erase_confirm_modal.visible = false
	cloud_notice_modal.visible = false
	
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
		_show_login_screen()
	else:
		login_modal.visible = false
		
	# Si regresamos de un combate de campaña o de conquistar un episodio
	if GameData.last_adventure_episode_conquered:
		GameData.last_adventure_episode_conquered = false
		update_campaign_hub_ui()
		campaign_hub_modal.visible = true
	elif GameData.is_campaign_mode:
		var active_state = GameData.get_active_campaign_team_state()
		if active_state.size() > 0:
			update_campaign_ui()
			campaign_modal.visible = true

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
		hub_desc.text = "Choose your path: compete in the Tournament or embark on Story Adventure!"
		
	# Estado del Torneo
	if GameData.campaign_player_team_state.is_empty():
		tourn_status_lbl.text = "Status: No active run • Ready to start"
		tourn_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_tournament.text = "⚔️ Start Tournament"
	else:
		if GameData.campaign_match_number > GameData.TOURNAMENT_TOTAL_MATCHES:
			tourn_status_lbl.text = "Status: 🏆 Tournament Champion! Ready for new run"
			tourn_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			btn_hub_tournament.text = "🏆 Review / Restart Tournament"
		else:
			tourn_status_lbl.text = "Status: In Progress (Battle %d/%d)" % [
				GameData.campaign_match_number,
				GameData.TOURNAMENT_TOTAL_MATCHES
			]
			tourn_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
			btn_hub_tournament.text = "⛺ Continue Tournament (Camp)"
			
	# Estado del Episodio I
	var ep1_completed = GameData.is_adventure_episode_completed(1)
	if ep1_completed:
		ep1_status_lbl.text = "Status: 🏅 COMPLETED (Boulder Badge Won!) • Replayable"
		ep1_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		btn_hub_adventure_ep1.text = "🗺️ Replay Episode I"
	elif GameData.adventure_player_team_state.is_empty():
		ep1_status_lbl.text = "Status: Not started • Ready to embark"
		ep1_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		btn_hub_adventure_ep1.text = "🗺️ Embark on Episode I"
	else:
		var total_stages = GameData.get_adventure_total_stages(1)
		ep1_status_lbl.text = "Status: In Progress (Stage %d/%d)" % [
			GameData.adventure_current_stage,
			total_stages
		]
		ep1_status_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
		btn_hub_adventure_ep1.text = "⛺ Continue Episode I (Camp)"
		
	# Estado del Episodio II (inhabilitado temporalmente)
	var ep2_unlocked = GameData.is_adventure_episode_unlocked(2)
	if ep2_unlocked:
		ep2_status_lbl.text = "Status: 🔓 Unlocked! (Disabled for Episode I testing)"
		ep2_status_lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
		btn_hub_adventure_ep2.text = "🚧 Coming Soon (Testing Ep. I)"
		btn_hub_adventure_ep2.disabled = true
	else:
		ep2_status_lbl.text = "Status: 🔒 Locked (Clear Episode I first)"
		ep2_status_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4))
		btn_hub_adventure_ep2.text = "🔒 Locked"
		btn_hub_adventure_ep2.disabled = true

func _on_select_tournament_pressed() -> void:
	campaign_hub_modal.visible = false
	GameData.campaign_submode = "TOURNAMENT"
	if GameData.campaign_player_team_state.is_empty():
		open_team_select_for_campaign()
	else:
		update_campaign_ui()
		campaign_modal.visible = true

func _on_select_adventure_ep1_pressed() -> void:
	campaign_hub_modal.visible = false
	GameData.campaign_submode = "ADVENTURE"
	GameData.adventure_current_episode = 1
	if GameData.adventure_player_team_state.is_empty():
		open_team_select_for_campaign()
	else:
		update_campaign_ui()
		campaign_modal.visible = true

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
		team_select_subtitle.text = "Choose 1 to 3 BASIC Pokémon for Episode I (Legendaries banned).\n⏫ icons show evolutions ready in your collection!"
	else:
		team_select_title.text = "🏆 TOURNAMENT TEAM"
		team_select_subtitle.text = "Choose 1 to 3 BASIC Pokémon (Legendaries banned).\n⏫ icons show evolutions ready in your collection!"
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
	elif selected_player_ids.is_empty():
		for card in cards_data:
			var st = str(card.get("stage", "Basic")).strip_edges().to_lower()
			var r = str(card.get("rarity", "Common")).strip_edges().to_lower()
			var is_legendary = (r in ["legendary", "legendaria", "legendario", "ur", "ultra rare"]) or (st == "legendary")
			if st == "basic" and not is_legendary:
				selected_player_ids.append(int(card["id"]))
				if selected_player_ids.size() >= 3:
					break
			
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
	var revives = cur_inv.get("revive", 0)
	var remedies = cur_inv.get("remedy", 0)
	var ethers = cur_inv.get("ether", 0)
	if btn_camp_bag:
		var total_items = potions + revives + remedies + ethers
		btn_camp_bag.text = "🎒 Bag (%d Item%s)" % [total_items, "s" if total_items != 1 else ""]
	campaign_item_count_lbl.text = "Inventory: %d Potions" % potions
	campaign_remedy_count_lbl.text = "Inventory: %d Remedies" % remedies
	campaign_ether_count_lbl.text = "Inventory: %d Ethers" % ethers
	campaign_revive_count_lbl.text = "Inventory: %d Revives" % revives
	
	btn_buy_potion.disabled = (cur_gold < 3)
	btn_buy_potion.text = "Buy (3 G)"
	btn_buy_remedy.disabled = (cur_gold < 2)
	btn_buy_remedy.text = "Buy (2 G)"
	btn_buy_ether.disabled = (cur_gold < 3)
	btn_buy_ether.text = "Buy (3 G)"
	btn_buy_revive.disabled = (cur_gold < 6)
	btn_buy_revive.text = "Buy (6 G)"
	
	var camp_title = campaign_modal.get_node_or_null("Box/Title")
	var camp_desc = campaign_modal.get_node_or_null("Box/Desc")
	var camp_team_header = campaign_modal.get_node_or_null("Box/TeamHeader")
	if GameData.campaign_submode == "ADVENTURE":
		btn_close_campaign.text = "⬅ Abandon Episode (Resets Run)"
		var ep_id = GameData.adventure_current_episode
		var ep_info = GameData.get_adventure_episode_info(ep_id)
		var total_stages = GameData.get_adventure_total_stages(ep_id)
		var cur_stage = GameData.adventure_current_stage
		btn_change_campaign_team.visible = (cur_stage == 1)
		btn_reset_campaign.text = "🔄 Restart Episode (Resets Stage Progress)"
		
		if camp_title:
			camp_title.text = "🗺️ " + ep_info.get("title", "ADVENTURE: EPISODE I").to_upper()
		if camp_desc:
			camp_desc.text = ep_info.get("subtitle", "Story adventure")
		if camp_team_header:
			camp_team_header.text = "👥 YOUR ADVENTURE TEAM:"
			
		if cur_stage > total_stages:
			campaign_match_lbl.text = "🎉 EPISODE CONQUERED! Boulder Badge Won!"
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
		# Modo Torneo
		btn_change_campaign_team.visible = (GameData.campaign_match_number == 1)
		btn_reset_campaign.text = "🔄 Restart Tournament (Resets Match Progress)"
		
		if camp_title:
			camp_title.text = "🏆 POKÉMON TOURNAMENT"
		if camp_desc:
			camp_desc.text = "Manage your team and purchase battle items between matches!"
		if camp_team_header:
			camp_team_header.text = "👥 YOUR TOURNAMENT TEAM:"
			
		if GameData.campaign_match_number > GameData.TOURNAMENT_TOTAL_MATCHES:
			campaign_match_lbl.text = "🎉 TOURNAMENT CHAMPION!"
			btn_start_campaign_battle.text = "🏆 Start New Tournament!"
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
		
		var p_stage_low = str(p.get("stage", "Basic")).strip_edges().to_lower()
		var cur_exp = int(p.get("current_exp", 0))
		var req_exp = 10 if p_stage_low == "basic" else (25 if p_stage_low == "stage 1" else 0)
		
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
		
		if req_exp <= 0:
			exp_bar.max_value = 1
			exp_bar.value = 1
			exp_lbl.text = "EXP: MAX"
			exp_lbl.add_theme_color_override("font_color", Color("#81D4FA"))
		else:
			exp_bar.max_value = req_exp
			exp_bar.value = min(req_exp, cur_exp)
			var target_id = GameData.get_evolution_target_id(int(p["id"]))
			if cur_exp >= req_exp:
				if target_id != -1 and GameData.is_pokemon_unlocked(target_id):
					var target_name = GameData.pokemon_catalog.get(target_id, {}).get("name", "evolution")
					exp_lbl.text = "EXP: %d/%d (Ready to Evolve!)" % [cur_exp, req_exp]
					exp_lbl.add_theme_color_override("font_color", Color("#FFD700"))
				elif target_id != -1:
					var target_name = GameData.pokemon_catalog.get(target_id, {}).get("name", "evolution")
					exp_lbl.text = "EXP: %d/%d 🔒 (Need %s)" % [cur_exp, req_exp, target_name]
					exp_lbl.add_theme_color_override("font_color", Color("#FF8A80"))
				else:
					exp_lbl.text = "EXP: %d/%d (Ready!)" % [cur_exp, req_exp]
					exp_lbl.add_theme_color_override("font_color", Color("#FFD700"))
			else:
				exp_lbl.text = "EXP: %d/%d" % [cur_exp, req_exp]
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
		
		# 3. Actions (Inspect & Order)
		var card_btns_vbox = VBoxContainer.new()
		card_btns_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		card_btns_vbox.add_theme_constant_override("separation", 4)
		card_btns_vbox.custom_minimum_size = Vector2(104, 0)
		card_hbox.add_child(card_btns_vbox)
		
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
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_buy_revive_pressed() -> void:
	if GameData.buy_campaign_revive():
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_buy_remedy_pressed() -> void:
	if GameData.buy_campaign_remedy():
		GameData.play_combat_sfx("purchase")
		update_campaign_ui()

func _on_buy_ether_pressed() -> void:
	if GameData.buy_campaign_ether():
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
	add_child(camp_shop_modal)
	
	var shop_bg = ColorRect.new()
	shop_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	shop_bg.color = Color(0, 0, 0, 0.75)
	camp_shop_modal.add_child(shop_bg)
	
	var shop_center = CenterContainer.new()
	shop_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_shop_modal.add_child(shop_center)
	
	var shop_panel = PanelContainer.new()
	shop_panel.custom_minimum_size = Vector2(490, 0)
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
	add_child(camp_bag_modal)
	
	var bag_bg = ColorRect.new()
	bag_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bag_bg.color = Color(0, 0, 0, 0.75)
	camp_bag_modal.add_child(bag_bg)
	
	var bag_center = CenterContainer.new()
	bag_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	camp_bag_modal.add_child(bag_center)
	
	var bag_panel = PanelContainer.new()
	bag_panel.custom_minimum_size = Vector2(510, 0)
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
	btn_close_camp_bag.text = "⬅ Back to Camp / Volver"
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
			"id": "revive",
			"name": "Revive",
			"desc": "Revives a fainted Pokémon with 50% max HP.",
			"stock": inv.get("revive", 0)
		},
		{
			"id": "remedy",
			"name": "Remedy",
			"desc": "Cures all negative status conditions (Burn, Poison, Flinch).",
			"stock": inv.get("remedy", 0)
		},
		{
			"id": "ether",
			"name": "Ether",
			"desc": "Restores up to 5 Energy (⚡). Used during combat.",
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
		elif int(p.get("burn_turns", 0)) > 0 or bool(p.get("is_poisoned", false)):
			var s_arr = []
			if int(p.get("burn_turns", 0)) > 0: s_arr.append("🔥 Burned (%d)" % int(p.get("burn_turns", 0)))
			if bool(p.get("is_poisoned", false)): s_arr.append("🟣 Poisoned")
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
		elif item_id == "revive":
			if p["current_hp"] > 0:
				can_apply = false
				btn_text = "Not Fainted"
			else:
				can_apply = true
				btn_text = "Revive (50%)"
		elif item_id == "remedy":
			var has_stat = (int(p.get("burn_turns", 0)) > 0) or bool(p.get("is_poisoned", false)) or bool(p.get("is_flinched", false))
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
				elif cur_it == "revive":
					success = GameData.use_revive_on_campaign_pkmn(pkmn_idx)
				elif cur_it == "remedy":
					success = GameData.use_remedy_on_campaign_pkmn(pkmn_idx)
				if success:
					GameData.play_combat_sfx("use")
					update_campaign_ui()
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
	
	var p_stage_low = str(p.get("stage", "Basic")).strip_edges().to_lower()
	var cur_exp = int(p.get("current_exp", 0))
	var req_exp = 10 if p_stage_low == "basic" else (25 if p_stage_low == "stage 1" else 0)
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
			b_lbl.text = "🔥 Boost (+%d⚡): +%d Extra DMG%s" % [
				m.boost_cost, m.boost_damage,
				" & applies Burn" if m.boost_applies_burn else ""
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
	btn_done.text = "⬅ Back to Camp / Volver"
	btn_done.custom_minimum_size = Vector2(0, 34)
	btn_done.add_theme_font_size_override("font_size", 11)
	_apply_retro_button_style(btn_done, Color(0.25, 0.45, 0.55), Color(0.35, 0.65, 0.80), false)
	btn_done.pressed.connect(func(): camp_pokemon_inspector_modal.visible = false)
	vbox.add_child(btn_done)

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
	btn_qb_mode_ai.text = "🤖 VS IA"
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
	
	btn_qb_mode_online = Button.new()
	btn_qb_mode_online.text = "🌐 En Línea"
	btn_qb_mode_online.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_qb_mode_online.custom_minimum_size = Vector2(0, 34)
	btn_qb_mode_online.toggle_mode = true
	btn_qb_mode_online.pressed.connect(func(): _set_quick_battle_mode("ONLINE"))
	
	qb_mode_row.add_child(btn_qb_mode_ai)
	qb_mode_row.add_child(btn_qb_mode_pvp)
	qb_mode_row.add_child(btn_qb_mode_online)
	
	var tab_idx = team_select_tabs.get_index()
	box.add_child(qb_mode_row)
	box.move_child(qb_mode_row, tab_idx)
	_update_qb_mode_buttons_style()

func _set_quick_battle_mode(mode: String) -> void:
	qb_selected_mode = mode
	GameData.is_pvp_mode = (mode == "PVP")
	GameData.is_online_pvp = (mode == "ONLINE")
	if mode == "ONLINE":
		current_team_tab = "PLAYER"
	_update_qb_mode_buttons_style()
	update_team_select_ui()

func _update_qb_mode_buttons_style() -> void:
	if not btn_qb_mode_ai or not btn_qb_mode_pvp or not btn_qb_mode_online:
		return
	btn_qb_mode_ai.button_pressed = (qb_selected_mode == "AI")
	btn_qb_mode_pvp.button_pressed = (qb_selected_mode == "PVP")
	btn_qb_mode_online.button_pressed = (qb_selected_mode == "ONLINE")
	
	_style_toggle_btn(btn_qb_mode_ai, qb_selected_mode == "AI", Color("#4CAF50"))
	_style_toggle_btn(btn_qb_mode_pvp, qb_selected_mode == "PVP", Color("#2196F3"))
	_style_toggle_btn(btn_qb_mode_online, qb_selected_mode == "ONLINE", Color("#9C27B0"))

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
	refresh_cards_data_from_catalog()
	team_select_mode = "QUICK_BATTLE"
	_setup_team_select_pvp_controls()
	if qb_mode_row:
		qb_mode_row.visible = true
		_update_qb_mode_buttons_style()
	
	team_select_title.text = "⚔️ TEAM SELECTION"
	team_select_tabs.visible = true
	
	# Preseleccionar para jugador si no hay selección
	if selected_player_ids.is_empty():
		for i in range(min(3, cards_data.size())):
			selected_player_ids.append(cards_data[i]["id"])
			
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
	if team_select_mode == "CAMPAIGN":
		var state = GameData.get_active_campaign_team_state()
		if state.size() > 0:
			update_campaign_ui()
			campaign_modal.visible = true
		else:
			update_campaign_hub_ui()
			campaign_hub_modal.visible = true

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
		
		thumb_btn.pressed.connect(func(): toggle_pokemon_selection(cid))
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
	
	if team_select_mode == "CAMPAIGN":
		if qb_mode_row:
			qb_mode_row.visible = false
		team_select_title.text = "🏆 TOURNAMENT TEAM"
		team_select_subtitle.text = "Choose 1 to 3 BASIC Pokémon (Legendaries banned).\n⏫ icons show evolutions ready in your collection!"
		btn_tab_player.text = "👤 Your Team (%d/3)" % selected_player_ids.size()
		btn_tab_enemy.text = "🤖 Rival AI (%d/3)" % selected_enemy_ids.size()
	else:
		if qb_mode_row:
			qb_mode_row.visible = true
			_update_qb_mode_buttons_style()
		team_select_title.text = "⚔️ TEAM SELECTION"
		if qb_selected_mode == "ONLINE":
			team_select_title.text = "🌐 ONLINE TEAM SELECTION"
			team_select_subtitle.text = "Choose 1 to 3 Pokémon from your collection, then Proceed to Online Lobby"
			btn_tab_player.text = "🌐 Your Team (%d/3)" % selected_player_ids.size()
			btn_tab_enemy.visible = false
			btn_random_enemy.visible = false
			btn_start_battle.text = "🌐  PROCEED TO ONLINE LOBBY"
		elif GameData.is_pvp_mode:
			btn_tab_enemy.visible = true
			btn_random_enemy.visible = true
			team_select_subtitle.text = "👥 Pass & Play: Choose from your unlocked Pokémon for Player 1 and Player 2"
			btn_tab_player.text = "🔴 Player 1 (%d/3)" % selected_player_ids.size()
			btn_tab_enemy.text = "🔵 Player 2 (%d/3)" % selected_enemy_ids.size()
			btn_start_battle.text = "⚔️  START BATTLE"
		else:
			btn_tab_enemy.visible = true
			btn_random_enemy.visible = true
			team_select_subtitle.text = "Configure your team and Rival AI from your unlocked Pokémon (1 to 3 each)"
			btn_tab_player.text = "👤 Your Team (%d/3)" % selected_player_ids.size()
			btn_tab_enemy.text = "🤖 Rival AI (%d/3)" % selected_enemy_ids.size()
			btn_start_battle.text = "⚔️  START BATTLE"
	
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
			
	if team_select_mode == "CAMPAIGN":
		var p_count = selected_player_ids.size()
		btn_start_battle.disabled = (p_count < 1)
		if p_count >= 1:
			btn_start_battle.text = "✅ CONFIRM TOURNAMENT TEAM (%d PKMN)" % p_count
		else:
			btn_start_battle.text = "Choose 1 to 3 BASIC Pokémon for Tournament"
	else:
		var p_count = selected_player_ids.size()
		var e_count = selected_enemy_ids.size()
		if qb_selected_mode == "ONLINE":
			var ready = (p_count >= 1 and p_count <= 3)
			btn_start_battle.disabled = not ready
			if ready:
				btn_start_battle.text = "🌐 PROCEED TO ONLINE LOBBY (%d PKMN)" % p_count
			else:
				btn_start_battle.text = "Choose 1 to 3 Pokémon for Online Battle"
		else:
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
		
	if qb_selected_mode == "ONLINE":
		_open_online_lobby()
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
func _open_online_lobby() -> void:
	online_lobby_modal.visible = true
	_show_online_host_tab()

func _show_online_host_tab() -> void:
	btn_tab_create_room.button_pressed = true
	btn_tab_join_room.button_pressed = false
	_style_toggle_btn(btn_tab_create_room, true, Color("#4CAF50"))
	_style_toggle_btn(btn_tab_join_room, false, Color("#2196F3"))
	host_panel.visible = true
	join_panel.visible = false
	room_code_lbl.text = "----"
	host_status_lbl.text = "⏳ Creando sala en Google Cloud..."
	
	OnlineManager.create_room(GameData.profile_name, selected_player_ids, func(success: bool, code: String):
		if success:
			room_code_lbl.text = code
			host_status_lbl.text = "⏳ Esperando a que tu rival ingrese el código %s..." % code
		else:
			room_code_lbl.text = "ERR"
			host_status_lbl.text = "❌ Error al crear sala. Intenta nuevamente."
	)

func _show_online_join_tab() -> void:
	btn_tab_create_room.button_pressed = false
	btn_tab_join_room.button_pressed = true
	_style_toggle_btn(btn_tab_create_room, false, Color("#4CAF50"))
	_style_toggle_btn(btn_tab_join_room, true, Color("#2196F3"))
	host_panel.visible = false
	join_panel.visible = true
	join_code_input.text = ""
	join_status_lbl.text = ""
	# Si éramos host de una sala previa sin usar, cancelarla
	OnlineManager.leave_or_delete_room()

func _on_confirm_join_pressed() -> void:
	var code = join_code_input.text.strip_edges().to_upper()
	if code.length() < 3:
		join_status_lbl.text = "⚠️ Ingresa el código de 4 caracteres de la sala."
		join_status_lbl.add_theme_color_override("font_color", Color("#FF5252"))
		return
	join_status_lbl.text = "🔄 Conectando a la sala %s..." % code
	join_status_lbl.add_theme_color_override("font_color", Color("#81D4FA"))
	btn_confirm_join.disabled = true
	OnlineManager.join_room(code, GameData.profile_name, selected_player_ids, func(success: bool, msg: String):
		btn_confirm_join.disabled = false
		if success:
			join_status_lbl.text = "✅ ¡Conectado! Esperando inicio de batalla..."
			join_status_lbl.add_theme_color_override("font_color", Color("#69F0AE"))
		else:
			join_status_lbl.text = "❌ %s" % msg
			join_status_lbl.add_theme_color_override("font_color", Color("#FF5252"))
	)

func _on_close_online_lobby_pressed() -> void:
	OnlineManager.leave_or_delete_room()
	online_lobby_modal.visible = false

func _on_online_match_ready() -> void:
	host_status_lbl.text = "🎉 ¡Rival conectado! Entrenador: %s" % OnlineManager.opponent_name
	join_status_lbl.text = "🎉 ¡Conectado con %s! Iniciando combate..." % OnlineManager.opponent_name
	
	GameData.is_campaign_mode = false
	GameData.is_pvp_mode = false
	GameData.is_online_pvp = true
	GameData.online_rival_name = OnlineManager.opponent_name
	GameData.player_team_ids = selected_player_ids.duplicate()
	GameData.enemy_team_ids = OnlineManager.opponent_team_ids.duplicate()
	
	var timer = get_tree().create_timer(1.2)
	timer.timeout.connect(func():
		online_lobby_modal.visible = false
		team_select_modal.visible = false
		if bgm_player and bgm_player.playing:
			bgm_player.stop()
		get_tree().change_scene_to_file("res://scenes/battle.tscn")
	)

func _on_collection_pressed() -> void:
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

	# Badges for Campaign
	var hub_badge_node = get_node_or_null("CampaignHubModal/Box/HubWalletBadge")
	if hub_badge_node is Label:
		hub_badge_node.add_theme_stylebox_override("normal", badge_sb.duplicate())

	var camp_status_card = get_node_or_null("CampaignModal/Box/StatusCard")
	if camp_status_card is PanelContainer:
		camp_status_card.add_theme_stylebox_override("panel", badge_sb.duplicate())

	# Mode Cards in Campaign Hub
	var card_tourn = get_node_or_null("CampaignHubModal/Box/ModesScroll/ModesVBox/CardTournament")
	if card_tourn is PanelContainer:
		card_tourn.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_ep1 = get_node_or_null("CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventureEp1")
	if card_ep1 is PanelContainer:
		card_ep1.add_theme_stylebox_override("panel", teal_sb.duplicate())
	var card_ep2 = get_node_or_null("CampaignHubModal/Box/ModesScroll/ModesVBox/CardAdventureEp2")
	if card_ep2 is PanelContainer:
		card_ep2.add_theme_stylebox_override("panel", teal_sb.duplicate())

	# Camp Supply Shop Panel
	var camp_shop_panel = find_child("ShopSection", true, false)
	if camp_shop_panel is PanelContainer:
		camp_shop_panel.add_theme_stylebox_override("panel", teal_sb.duplicate())

	# Retro stylebox overrides for Campaign Hub & Camp buttons
	_apply_retro_button_style(btn_hub_tournament, Color(0.22, 0.63, 0.41), Color(0.40, 0.85, 0.60), true)
	_apply_retro_button_style(btn_hub_adventure_ep1, Color(0.19, 0.59, 0.58), Color(0.30, 0.85, 0.80), true)
	_apply_retro_button_style(btn_hub_adventure_ep2, Color(0.25, 0.35, 0.45), Color(0.35, 0.45, 0.55), false)
	_apply_retro_button_style(btn_close_campaign_hub, Color(0.25, 0.52, 0.60), Color(0.40, 0.85, 0.95), false)

	_apply_retro_button_style(btn_buy_potion, Color(0.20, 0.50, 0.80), Color(0.35, 0.75, 1.00), false)
	_apply_retro_button_style(btn_buy_remedy, Color(0.22, 0.63, 0.41), Color(0.40, 0.85, 0.60), false)
	_apply_retro_button_style(btn_buy_ether, Color(0.50, 0.35, 0.85), Color(0.70, 0.55, 1.00), false)
	_apply_retro_button_style(btn_buy_revive, Color(0.84, 0.62, 0.18), Color(1.00, 0.85, 0.35), false)

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
	
	# 3. Create Packs Container and re-parent PackPanel, BtnOpenPack, BtnUnlockAllDev
	packs_container = VBoxContainer.new()
	packs_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	packs_container.add_theme_constant_override("separation", 10)
	
	var pack_panel = shop_box.get_node_or_null("PackPanel")
	if pack_panel:
		shop_box.remove_child(pack_panel)
		packs_container.add_child(pack_panel)
	if btn_open_pack:
		shop_box.remove_child(btn_open_pack)
		packs_container.add_child(btn_open_pack)
		
	shop_box.add_child(packs_container)
	var tabs_idx = shop_tabs_row.get_index()
	shop_box.move_child(packs_container, tabs_idx + 1)
	
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
	btn_bulk_recycle.custom_minimum_size = Vector2(0, 42)
	btn_bulk_recycle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_bulk_recycle.text = "♻️ Bulk Recycle All Duplicates (+0 🍬)"
	btn_bulk_recycle.add_theme_font_size_override("font_size", 13)
	btn_bulk_recycle.add_theme_color_override("font_color", Color("#33FF77"))
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
	
	# Scroll Area for Hidden Shop Catalog Grid
	var hid_scroll = ScrollContainer.new()
	hid_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hid_scroll.custom_minimum_size = Vector2(0, 320)
	hid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	
	var grid_margin = MarginContainer.new()
	grid_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_margin.add_theme_constant_override("margin_left", 4)
	grid_margin.add_theme_constant_override("margin_right", 4)
	
	hidden_shop_grid = GridContainer.new()
	hidden_shop_grid.columns = 3
	hidden_shop_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hidden_shop_grid.add_theme_constant_override("h_separation", 8)
	hidden_shop_grid.add_theme_constant_override("v_separation", 8)
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
		_update_shop_showcase_and_rates()
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
			btn_bulk_recycle.text = "♻️ Bulk Recycle All Duplicates (0 Duplicates)"
		return
		
	recycle_empty_lbl.visible = false
	var total_extra = 0
	var total_candies = 0
	for d in dupes:
		total_extra += int(d.get("dupes_count", 0))
		total_candies += int(d.get("dupes_count", 0)) * int(d.get("candy_value", 1))
		
	if btn_bulk_recycle:
		btn_bulk_recycle.disabled = false
		btn_bulk_recycle.text = "♻️ Bulk Recycle All Duplicates (%d extra cards -> +%d 🍬)" % [total_extra, total_candies]
	
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
		yield_lbl.text = "+%d 🍬" % candy_val
		yield_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		yield_lbl.add_theme_font_size_override("font_size", 11)
		yield_lbl.add_theme_color_override("font_color", Color("#33FF77"))
		act_vbox.add_child(yield_lbl)
		
		var btn_rec_one = Button.new()
		btn_rec_one.custom_minimum_size = Vector2(90, 28)
		btn_rec_one.text = "Recycle 1"
		btn_rec_one.add_theme_font_size_override("font_size", 11)
		btn_rec_one.pressed.connect(func(): _on_recycle_one_pressed(cid, c_name))
		act_vbox.add_child(btn_rec_one)
		
		recycle_scroll_list.add_child(row_panel)

func _on_bulk_recycle_pressed() -> void:
	var res = GameData.recycle_all_duplicates()
	var count = int(res.get("recycled_count", 0))
	var earned = int(res.get("candies_earned", 0))
	if count > 0:
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "♻️ Successfully recycled %d duplicate cards! Earned +%d 🍬 Rare Candies!" % [count, earned]
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
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "♻️ Recycled 1 duplicate copy of %s! Earned +%d 🍬 Rare Candies!" % [card_name, earned]
			shop_feedback_lbl.modulate = Color(0.3, 1.0, 0.4)
			shop_feedback_lbl.visible = true
	_populate_recycle_view()
	_update_shop_currencies()
	_update_lobby_header_badge()

func _on_hidden_filter_pressed(fid: String) -> void:
	hidden_shop_filter = fid
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
		child.queue_free()
		
	for k in hidden_filter_buttons:
		var btn = hidden_filter_buttons[k]
		btn.modulate = Color(1.3, 1.2, 0.4) if k == hidden_shop_filter else Color(0.85, 0.85, 0.85)
		
	var sorted_list = get_sorted_cards(all_catalog_cards, "DEX")
	for card in sorted_list:
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
				
		var cost = GameData.get_hidden_shop_candy_cost(r_str)
		var stock = GameData.get_card_stock(cid)
		var r_info = GameData.get_rarity_display_info(r_str)
		var p_num = str(card.get("pokedex_num", "1")).pad_zeros(3)
		var c_name = str(card.get("short_name", card.get("name", "PKMN")))
		var type_str = str(card.get("type", "NORMAL")).to_upper()
		
		var card_panel = PanelContainer.new()
		card_panel.custom_minimum_size = Vector2(144, 205)
		card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
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
		card_panel.add_child(vbox)
		
		# Name and Dex #
		var name_lbl = Label.new()
		name_lbl.text = "#%s %s" % [p_num, c_name]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 10)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(name_lbl)
		
		# Thumbnail
		var tex_rect = TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(68, 68)
		tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.texture = GameData.get_pokemon_texture(str(card.get("texture_path", "")))
		if not is_owned:
			tex_rect.modulate = Color(0.85, 0.85, 0.85, 0.85)
		vbox.add_child(tex_rect)
		
		# Type and Rarity
		var type_lbl = Label.new()
		type_lbl.text = "%s • %s" % [type_str, r_info.get("name", "Common")]
		type_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		type_lbl.add_theme_font_size_override("font_size", 8)
		type_lbl.add_theme_color_override("font_color", r_info.get("color", Color("#81D4FA")))
		vbox.add_child(type_lbl)
		
		# Ownership status
		var status_lbl = Label.new()
		status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_lbl.add_theme_font_size_override("font_size", 9)
		if is_owned:
			status_lbl.text = "Owned: x%d" % stock
			status_lbl.add_theme_color_override("font_color", Color("#4ade80") if stock == 1 else Color("#facc15"))
		else:
			status_lbl.text = "🔒 NOT OWNED"
			status_lbl.add_theme_color_override("font_color", Color("#fb7185"))
		vbox.add_child(status_lbl)
		
		# Cost & Buy Button
		var btn_buy = Button.new()
		btn_buy.custom_minimum_size = Vector2(0, 30)
		btn_buy.add_theme_font_size_override("font_size", 10)
		var can_afford = (GameData.player_rare_candies >= cost)
		
		if not can_afford:
			btn_buy.text = "Need 🍬 %d" % cost
			btn_buy.disabled = true
			btn_buy.modulate = Color(0.7, 0.7, 0.7)
		else:
			if is_owned:
				btn_buy.text = "📦 Copy (🍬 %d)" % cost
				btn_buy.modulate = Color(0.4, 0.9, 1.0)
			else:
				btn_buy.text = "✨ Unlock (🍬 %d)" % cost
				btn_buy.modulate = Color(0.3, 1.0, 0.5)
			btn_buy.pressed.connect(func(): _on_buy_hidden_card_pressed(cid, c_name, cost))
		vbox.add_child(btn_buy)
		
		hidden_shop_grid.add_child(card_panel)

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
	_switch_shop_tab(shop_active_tab)

func _update_shop_showcase_and_rates() -> void:
	# 1. Booster Pack Foil Art
	if pack_art_texture:
		var pack_tex = GameData.get_booster_pack_texture()
		if pack_tex:
			pack_art_texture.texture = pack_tex

	# 2. Rarity Drop Rates Grid
	if rates_grid:
		for child in rates_grid.get_children():
			child.queue_free()
		var rates = GameData.get_booster_rarity_rates()
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

	# 3. Featured Showcase Cards (Rotating Epic & Legendary Foils)
	if showcase_header:
		showcase_header.text = "✨ FEATURED FOIL CARDS (EPIC & LEGENDARY):"
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
	if showcase_legendary_queue.size() < 3:
		var l_ids: Array[int] = []
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
	if GameData.player_diamonds < BOOSTER_PACK_COST:
		if shop_feedback_lbl:
			shop_feedback_lbl.text = "❌ Not enough Diamonds! Requires 💎 %d Diamonds. Complete Tournament phases to earn Diamonds." % BOOSTER_PACK_COST
		return
		
	var opened = GameData.open_booster_pack("kanto_booster", BOOSTER_PACK_COST)
	if opened.is_empty():
		return
	refresh_cards_data_from_catalog()
	_update_lobby_header_badge()
	_update_shop_currencies()
	_show_pack_reveal_ui(opened)

func _show_pack_reveal_ui(cards: Array) -> void:
	_stop_showcase_timer()
	if not pack_reveal_box:
		_create_pack_reveal_container()
		
	shop_box.visible = false
	pack_reveal_box.visible = true
	
	if btn_reveal_another:
		btn_reveal_another.text = "✨ OPEN ANOTHER PACK (💎 %d Diamonds)" % BOOSTER_PACK_COST
		btn_reveal_another.disabled = (GameData.player_diamonds < BOOSTER_PACK_COST)
	
	for child in reveal_cards_row.get_children():
		reveal_cards_row.remove_child(child)
		child.queue_free()
		
	for c in cards:
		var card_panel = _create_reveal_card_item(c)
		reveal_cards_row.add_child(card_panel)

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
	btn_back_shop.custom_minimum_size = Vector2(0, 36)
	btn_back_shop.text = "🛒 Back to Shop"
	btn_back_shop.add_theme_font_size_override("font_size", 13)
	btn_back_shop.pressed.connect(func():
		pack_reveal_box.visible = false
		shop_box.visible = true
		_update_lobby_header_badge()
		if shop_active_tab == "PACKS":
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
	
	# 1. Filtro Owned (Estado de posesión)
	opt_col_owned = OptionButton.new()
	opt_col_owned.name = "OptColOwned"
	opt_col_owned.add_item("📦 Status: All", 0)
	opt_col_owned.add_item("📦 Owned Only", 1)
	opt_col_owned.add_item("📦 Missing Only", 2)
	_style_filter_option(opt_col_owned)
	opt_col_owned.item_selected.connect(func(idx: int):
		match idx:
			1: col_filter_owned = "OWNED"
			2: col_filter_owned = "MISSING"
			_: col_filter_owned = "ALL"
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

func _update_filter_button_visuals() -> void:
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
		
		# 1. Filtro Owned (Estado de posesión)
		if col_filter_owned == "OWNED" and not is_unlocked:
			continue
		elif col_filter_owned == "MISSING" and is_unlocked:
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
	
	var is_filtered = (col_filter_owned != "ALL" or col_filter_type != "ALL" or col_filter_stage != "ALL" or col_filter_rarity != "ALL" or col_filter_tier != "ALL")
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

	if current_sorted_collection.is_empty():
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
	
	for i in range(current_sorted_collection.size()):
		var card = current_sorted_collection[i]
		var cid = int(card["id"])
		var is_unlocked = GameData.is_pokemon_unlocked(cid)
		var p_num = str(card.get("pokedex_num", "1")).pad_zeros(3)
		
		var cell_vbox = VBoxContainer.new()
		cell_vbox.custom_minimum_size = Vector2(106, 175)
		cell_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell_vbox.add_theme_constant_override("separation", 4)
		cell_vbox.alignment = BoxContainer.ALIGNMENT_BEGIN
		
		# 1. Miniatura de la carta
		var thumb_btn = Button.new()
		thumb_btn.custom_minimum_size = Vector2(106, 140)
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
			stock_badge.position = Vector2(66, 6)
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
			tier_thumb_badge.position = Vector2(6, 6)
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

func open_collection_detail(index: int) -> void:
	current_collection_index = index
	collection_grid_view.visible = false
	collection_detail_view.visible = true
	show_collection_card(current_collection_index)

func _on_back_to_grid_pressed() -> void:
	collection_detail_view.visible = false
	collection_grid_view.visible = true

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
		stats_hp.text = "❤️ Max HP: %d HP" % int(card.get("hp", 10))
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
			var boost_txt = "+%d extra DMG" % m2_bdmg if m2_bdmg > 0 else ""
			if card.get("m2_effect_type", "") == "BURN":
				boost_txt += " and inflicts Burn (1 DMG x 2 turns)" if boost_txt != "" else "Inflicts Burn (1 DMG x 2 turns)"
			m2_boost.text = "🔥 Boost: +%d extra ⚡ -> %s" % [m2_bcost, boost_txt]
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
	settings_modal.visible = true

# --- PANTALLA DE ACCESO / LOGIN ---
func _show_login_screen() -> void:
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
		profile_detected_lbl.text = "👤 Welcome to Pokémon Battle Frontier!"
		btn_login_play.text = "▶  PLAY AS GUEST\n(Direct to Lobby)"
	btn_login_cloud.text = "🔑  LOG IN WITH GOOGLE\n(Restore Cloud Progress)"
	btn_sign_up_google.text = "🌐  REGISTER GOOGLE ACCOUNT\n(Personalize Alias & Cloud Sync)"

func _on_login_play_pressed() -> void:
	var is_brand_new = not GameData.has_saved_profile()
	if is_brand_new:
		GameData.create_new_profile("Trainer", "Guest")
	elif not GameData.profile_welcome_claimed and GameData.stats_battles_total == 0 and GameData.stats_tournaments_won == 0:
		if GameData.player_diamonds < GameData.WELCOME_GIFT_DIAMONDS:
			GameData.player_diamonds = GameData.WELCOME_GIFT_DIAMONDS
		if GameData.player_rare_candies < GameData.WELCOME_GIFT_RARE_CANDIES:
			GameData.player_rare_candies = GameData.WELCOME_GIFT_RARE_CANDIES
		GameData.profile_welcome_claimed = true
		is_brand_new = true
	GameData.session_entered_lobby = true
	login_modal.visible = false
	_update_lobby_header_badge()
	GameData.save_profile()
	if is_brand_new:
		_show_welcome_notification()

func _launch_google_browser_oauth() -> void:
	if cloud_feedback_lbl:
		cloud_feedback_lbl.text = "⏳ Abriendo ventana de selección en tu navegador..."
		cloud_feedback_lbl.visible = true
	var ok = CloudSync.start_google_oauth_flow()
	if not ok:
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "⚠️ No se pudo iniciar el servidor local para el navegador. Usa el ingreso manual."
			cloud_feedback_lbl.visible = true
		_set_manual_cloud_mode(true)

func _toggle_manual_cloud_mode() -> void:
	_set_manual_cloud_mode(not is_manual_cloud_mode)

func _set_manual_cloud_mode(manual: bool) -> void:
	if OS.has_feature("mobile"):
		manual = true
	is_manual_cloud_mode = manual
	if cloud_email_row:
		cloud_email_row.visible = manual
	if cloud_trainer_row:
		cloud_trainer_row.visible = (manual and cloud_action_mode == "SIGNUP_GOOGLE")
	if btn_cloud_confirm:
		btn_cloud_confirm.visible = manual
	if btn_launch_browser_auth:
		btn_launch_browser_auth.visible = (not manual and not OS.has_feature("mobile"))
	if btn_toggle_manual_auth:
		btn_toggle_manual_auth.visible = not OS.has_feature("mobile")
		btn_toggle_manual_auth.text = "🌐 Volver a selección con Google (Navegador)" if manual else "✏️ O ingresar correo manualmente..."
	if manual:
		if cloud_email_input and cloud_email_input.text.is_empty():
			cloud_email_input.grab_focus()
		elif cloud_trainer_input:
			cloud_trainer_input.grab_focus()

func _on_google_oauth_completed(success: bool, email: String, display_name: String, error_msg: String) -> void:
	if not success:
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "❌ %s" % error_msg
			cloud_feedback_lbl.visible = true
		return
		
	if cloud_feedback_lbl:
		cloud_feedback_lbl.text = "✅ ¡Cuenta seleccionada: %s!\nSincronizando con Google Cloud..." % email
		cloud_feedback_lbl.visible = true
		
	CloudSync.check_account_exists(email, func(exists: bool, cloud_data: Dictionary, err: String):
		if not err.is_empty():
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "❌ Error al conectar con Google Cloud:\n%s" % err
				cloud_feedback_lbl.visible = true
			return
			
		if exists:
			# Cuenta ya existente en Google Cloud -> Cargar y entrar
			var raw_prof = cloud_data.get("profile", {})
			var welcome_already_claimed = bool(raw_prof.get("welcome_gift_claimed", false))
			var battles = int(cloud_data.get("stats", {}).get("battles_total", 0))
			var tournaments = int(cloud_data.get("stats", {}).get("tournaments_won", 0))
			var show_welcome_on_login = (not welcome_already_claimed and battles == 0 and tournaments == 0)
			
			GameData.apply_save_dict(cloud_data)
			GameData.profile_email = email
			GameData.profile_cloud_key = email
			GameData.profile_auth_provider = "Google Cloud"
			GameData.save_profile()
			GameData.session_entered_lobby = true
			cloud_notice_modal.visible = false
			login_modal.visible = false
			_update_lobby_header_badge()
			refresh_cards_data_from_catalog()
			print("[Main] Google OAuth: Profile loaded from Cloud for %s (%s)!" % [GameData.profile_name, email])
			if show_welcome_on_login:
				_show_welcome_notification()
		else:
			# Cuenta nueva en Google Cloud -> Crear perfil con regalo de bienvenida y sincronizar
			var chosen_alias = display_name if not display_name.is_empty() else email.split("@")[0].capitalize()
			GameData.create_new_profile(chosen_alias, "Google Cloud", email, false)
			GameData.profile_welcome_claimed = true
			GameData.profile_email = email
			GameData.profile_cloud_key = email
			GameData.profile_name = chosen_alias
			GameData.profile_auth_provider = "Google Cloud"
			GameData.save_profile(false)
			
			CloudSync.save_profile_to_cloud(email, GameData.get_save_dict(), func(save_ok: bool, save_msg: String):
				if save_ok:
					GameData.session_entered_lobby = true
					cloud_notice_modal.visible = false
					login_modal.visible = false
					_update_lobby_header_badge()
					refresh_cards_data_from_catalog()
					_show_welcome_notification()
					print("[Main] Google OAuth: Brand new profile created and synced for %s (%s)!" % [chosen_alias, email])
				else:
					if cloud_feedback_lbl:
						cloud_feedback_lbl.text = "❌ Error al guardar perfil en la nube: %s" % save_msg
						cloud_feedback_lbl.visible = true
			)
	)

func _on_login_cloud_pressed() -> void:
	cloud_action_mode = "LOGIN_CLOUD"
	cloud_title.text = "🔑 LOG IN WITH GOOGLE"
	if OS.has_feature("mobile"):
		cloud_desc.text = "Ingresa tu correo de Google (Gmail) para restaurar tu progreso y colección desde la nube:"
		_set_manual_cloud_mode(true)
	else:
		cloud_desc.text = "Elige tu cuenta de Google en la ventana del navegador para sincronizar tu progreso y colección en tiempo real:"
		_set_manual_cloud_mode(false)
	if cloud_email_input:
		var remembered_email = GameData.profile_email
		if remembered_email.is_empty() and GameData.profile_cloud_key.contains("@"):
			remembered_email = GameData.profile_cloud_key
		cloud_email_input.text = remembered_email
		cloud_email_input.placeholder_text = "e.g. your_email@gmail.com"
	if cloud_feedback_lbl:
		cloud_feedback_lbl.visible = false
		cloud_feedback_lbl.text = ""
	btn_cloud_confirm.text = "☁️ Log In & Restore Save"
	btn_cloud_confirm.disabled = false
	cloud_notice_modal.visible = true
	if not OS.has_feature("mobile"):
		_launch_google_browser_oauth()

func _on_sign_up_google_pressed() -> void:
	cloud_action_mode = "SIGNUP_GOOGLE"
	cloud_title.text = "🌐 REGISTER GOOGLE ACCOUNT"
	if OS.has_feature("mobile"):
		cloud_desc.text = "Ingresa tu correo de Google y tu Alias para vincular tu partida con la nube:"
		_set_manual_cloud_mode(true)
	else:
		cloud_desc.text = "Conecta con tu cuenta de Google activa para sincronizar tu progreso y recibir tu regalo de bienvenida (25 💎 + 50 🍬):"
		_set_manual_cloud_mode(false)
	if cloud_trainer_prompt:
		cloud_trainer_prompt.text = "Trainer Alias:"
	if cloud_email_input:
		cloud_email_input.text = GameData.profile_email
		cloud_email_input.placeholder_text = "e.g. ash.ketchum@gmail.com"
	if cloud_trainer_input:
		var current_alias = GameData.profile_name
		if current_alias.is_empty() or current_alias == "Trainer":
			var sys_user = OS.get_environment("USERNAME")
			current_alias = sys_user.capitalize() if not sys_user.is_empty() else "Red"
		cloud_trainer_input.text = current_alias
		cloud_trainer_input.placeholder_text = "e.g. Ash, Red, Nestor..."
	if cloud_feedback_lbl:
		cloud_feedback_lbl.visible = false
		cloud_feedback_lbl.text = ""
	btn_cloud_confirm.text = "✨ Register & Sync Profile"
	btn_cloud_confirm.disabled = false
	cloud_notice_modal.visible = true
	if not OS.has_feature("mobile"):
		_launch_google_browser_oauth()

func _on_cloud_confirm_pressed() -> void:
	var entered_email = cloud_email_input.text.strip_edges() if cloud_email_input else ""
	var entered_alias = cloud_trainer_input.text.strip_edges() if cloud_trainer_input else ""
	
	if cloud_action_mode == "LOGIN_CLOUD":
		if entered_email.is_empty():
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⚠️ Please enter your Google Email."
				cloud_feedback_lbl.visible = true
			return
		if not entered_email.contains("@"):
			entered_email += "@gmail.com"
			if cloud_email_input:
				cloud_email_input.text = entered_email
				
		btn_cloud_confirm.disabled = true
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "⏳ Contacting Google Cloud (Firebase)..."
			cloud_feedback_lbl.visible = true
			
		CloudSync.load_profile_from_cloud(entered_email, func(success: bool, data: Dictionary, msg: String):
			btn_cloud_confirm.disabled = false
			if success:
				var raw_prof = data.get("profile", {})
				var welcome_already_claimed = bool(raw_prof.get("welcome_gift_claimed", false))
				var battles = int(data.get("stats", {}).get("battles_total", 0))
				var tournaments = int(data.get("stats", {}).get("tournaments_won", 0))
				var show_welcome_on_login = (not welcome_already_claimed and battles == 0 and tournaments == 0)
				
				GameData.apply_save_dict(data)
				GameData.profile_email = entered_email
				GameData.profile_cloud_key = entered_email
				GameData.profile_auth_provider = "Google Cloud"
				GameData.save_profile()
				GameData.session_entered_lobby = true
				cloud_notice_modal.visible = false
				login_modal.visible = false
				_update_lobby_header_badge()
				refresh_cards_data_from_catalog()
				print("[Main] Profile loaded from Google Cloud for %s (%s)!" % [GameData.profile_name, entered_email])
				if show_welcome_on_login:
					_show_welcome_notification()
			else:
				if cloud_feedback_lbl:
					cloud_feedback_lbl.text = "❌ %s\nPlease check spelling or register a new Google account." % msg
					cloud_feedback_lbl.visible = true
		)
		
	elif cloud_action_mode == "SIGNUP_GOOGLE":
		if btn_cloud_confirm.text.begins_with("🔑"):
			_on_login_cloud_pressed()
			return

		if entered_email.is_empty():
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⚠️ Please enter a valid Google Email."
				cloud_feedback_lbl.visible = true
			return
		if not entered_email.contains("@"):
			entered_email += "@gmail.com"
			if cloud_email_input:
				cloud_email_input.text = entered_email
				
		if entered_alias.is_empty():
			entered_alias = entered_email.split("@")[0].capitalize()
			if cloud_trainer_input:
				cloud_trainer_input.text = entered_alias
				
		btn_cloud_confirm.disabled = true
		if cloud_feedback_lbl:
			cloud_feedback_lbl.text = "⏳ Checking Google Account availability..."
			cloud_feedback_lbl.visible = true
			
		CloudSync.check_account_exists(entered_email, func(exists: bool, _data: Dictionary, err: String):
			if not err.is_empty():
				btn_cloud_confirm.disabled = false
				if cloud_feedback_lbl:
					cloud_feedback_lbl.text = "❌ Could not connect to Google Cloud:\n%s\nPlease check your internet connection." % err
					cloud_feedback_lbl.visible = true
				return
				
			if exists:
				btn_cloud_confirm.disabled = false
				if cloud_feedback_lbl:
					cloud_feedback_lbl.text = "⚠️ An account for '%s' already exists in Google Cloud!\n\nClick 'Switch to Log In' below to restore your save, or change the email." % entered_email
					cloud_feedback_lbl.visible = true
				btn_cloud_confirm.text = "🔑 Switch to Log In"
				return
				
			# Brand new cloud account registration!
			if cloud_feedback_lbl:
				cloud_feedback_lbl.text = "⏳ Creating new profile in Google Cloud..."
				
			GameData.create_new_profile(entered_alias, "Google Cloud", entered_email, false)
			GameData.profile_welcome_claimed = true
			GameData.profile_email = entered_email
			GameData.profile_cloud_key = entered_email
			GameData.profile_name = entered_alias
			GameData.profile_auth_provider = "Google Cloud"
			GameData.save_profile(false)
			
			CloudSync.save_profile_to_cloud(entered_email, GameData.get_save_dict(), func(success: bool, msg: String):
				btn_cloud_confirm.disabled = false
				if success:
					GameData.session_entered_lobby = true
					cloud_notice_modal.visible = false
					login_modal.visible = false
					_update_lobby_header_badge()
					refresh_cards_data_from_catalog()
					if profile_modal and profile_modal.visible:
						_on_profile_pressed()
					_show_welcome_notification()
					print("[Main] New Google Account created and synced for %s (%s)!" % [entered_alias, entered_email])
				else:
					if cloud_feedback_lbl:
						cloud_feedback_lbl.text = "❌ Error registering in Google Cloud: %s\nPlease check your internet connection." % msg
						cloud_feedback_lbl.visible = true
			)
		)

func _show_welcome_notification() -> void:
	if not welcome_modal:
		return
	welcome_title.text = "WELCOME, %s!" % GameData.profile_name.to_upper()
	welcome_modal.visible = true

func _on_welcome_go_shop_pressed() -> void:
	welcome_modal.visible = false
	_on_shop_pressed()

func _on_diamonds_changed(_new_amount: int = 0) -> void:
	_update_lobby_header_badge()
	_update_shop_currencies()
	if campaign_gold_lbl:
		campaign_gold_lbl.text = "💰 %d G  |  💎 %d" % [GameData.campaign_gold, GameData.player_diamonds]
	if stat_diamonds_lbl:
		stat_diamonds_lbl.text = "💎 Diamonds: %d" % GameData.player_diamonds
	if btn_open_pack:
		btn_open_pack.disabled = (GameData.player_diamonds < BOOSTER_PACK_COST)
	if btn_reveal_another:
		btn_reveal_another.disabled = (GameData.player_diamonds < BOOSTER_PACK_COST)

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
		if not GameData.profile_email.is_empty():
			trainer_status_badge.tooltip_text = "Google Account: %s\nTrainer ID: %s" % [GameData.profile_email, GameData.profile_id]
		else:
			trainer_status_badge.tooltip_text = "Local / Guest Account\nTrainer ID: %s" % GameData.profile_id
	if btn_daily_missions:
		if GameData.has_any_daily_reward_ready():
			btn_daily_missions.text = "🎁  DAILY MISSIONS & REWARDS  🔔"
		else:
			btn_daily_missions.text = "🎁  DAILY MISSIONS & REWARDS"

# --- PERFIL Y REGISTROS DEL ENTRENADOR ---
func _on_profile_pressed() -> void:
	refresh_cards_data_from_catalog()
	if trainer_name_input:
		trainer_name_input.text = GameData.profile_name
	if trainer_email_value:
		if not GameData.profile_email.is_empty():
			trainer_email_value.text = GameData.profile_email
		else:
			trainer_email_value.text = "(Not linked - Local Guest)"
	if btn_link_google:
		if GameData.profile_auth_provider.begins_with("Google"):
			btn_link_google.text = "🔄 Switch / Re-sync Google Account"
		else:
			btn_link_google.text = "🌐 Connect with Google Account"
	if account_status_lbl:
		if GameData.profile_auth_provider.begins_with("Google"):
			account_status_lbl.text = "Status: 🟢 Google Cloud Connected (Firebase)\n☁️ Email: %s" % GameData.profile_email
			account_status_lbl.modulate = Color(0.35, 1.0, 0.5)
		else:
			account_status_lbl.text = "Status: ⚪ Local Storage Active (%s)" % GameData.profile_auth_provider
			account_status_lbl.modulate = Color(0.7, 0.85, 0.95)
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
	profile_modal.visible = false
	GameData.session_entered_lobby = false
	_show_login_screen()

func _on_erase_profile_prompt_pressed() -> void:
	erase_confirm_modal.visible = true

func _on_confirm_erase_pressed() -> void:
	erase_confirm_modal.visible = false
	profile_modal.visible = false
	GameData.erase_profile()
	refresh_cards_data_from_catalog()
	_apply_audio_settings()
	_update_lobby_header_badge()
	_show_login_screen()

# --- MODAL MISIONES Y RECOMPENSAS DIARIAS ---
func _on_daily_missions_pressed() -> void:
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
	
	var name_lbl = Label.new()
	name_lbl.text = alias
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1, 0.88, 0.35))
	info_vbox.add_child(name_lbl)
	
	var sub_lbl = Label.new()
	var sub_text = email if not email.is_empty() else ("ID: " + p_id)
	if not email.is_empty() and not p_id.is_empty():
		sub_text += "  •  " + p_id
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
	if query.is_empty():
		friends_feedback_lbl.text = "⚠️ Please enter an Email, Alias or ID to search."
		return
		
	friends_feedback_lbl.text = "⏳ Searching trainers in Google Cloud (Firebase)..."
	btn_search_friend.disabled = true
	
	CloudSync.search_trainers(query, func(success: bool, results: Array, msg: String):
		btn_search_friend.disabled = false
		if success:
			last_search_results = results
			btn_tab_search_results.text = "🔍 Results (%d)" % results.size()
			_show_search_results_tab()
			if results.is_empty():
				friends_feedback_lbl.text = "⚠️ No trainers found matching '%s'." % query
			else:
				friends_feedback_lbl.text = "✅ Found %d trainer(s)!" % results.size()
		else:
			friends_feedback_lbl.text = "❌ Error searching: %s" % msg
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
	
	var name_lbl = Label.new()
	name_lbl.text = alias
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 1))
	info_vbox.add_child(name_lbl)
	
	var sub_lbl = Label.new()
	var sub_text = email if not email.is_empty() else ("ID: " + p_id)
	if not email.is_empty() and not p_id.is_empty():
		sub_text += "  •  " + p_id
	sub_lbl.text = sub_text
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	info_vbox.add_child(sub_lbl)
	
	# Acciones
	var is_already = GameData.is_friend(email) or GameData.is_friend(p_id) or GameData.is_friend(alias)
	var add_btn = Button.new()
	add_btn.custom_minimum_size = Vector2(110, 34)
	add_btn.add_theme_font_size_override("font_size", 11)
	
	if is_already:
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
			friends_feedback_lbl.text = "✨ '%s' added to your Friends List!" % alias
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
	
	# Mostrar pestaña de Anfitrión (Host)
	_show_online_host_tab()
	room_code_lbl.text = "...."
	host_status_lbl.text = "⚔️ Challenging %s...\nCreating room..." % f_data.get("alias", "Friend")
	
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
