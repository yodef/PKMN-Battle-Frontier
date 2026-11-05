class_name GameLocalization
extends RefCounted

# Diccionario de traducciones exactas (Inglés -> Español)
const EXACT_EN_TO_ES: Dictionary = {
	# --- Menú Principal (Lobby) ---
	"TCG Mobile Edition • Fan Game": "Edición Móvil TCG • Fan Game",
	"TCG Mobile Edition • Cloud Sync": "Edición Móvil TCG • Sincronización en la Nube",
	"Non-profit fan project • v0.4": "Proyecto fan sin fines de lucro • v0.4",
	"🏆  CAMPAIGN\n(Pokémon Tournament)": "🏆  CAMPAÑA\n(Torneo Pokémon)",
	"🏟️  CAMPAIGN\nTournament & Story Adventure": "🏟️  CAMPAÑA\nTorneo y Modo Aventura",
	"⚔️  QUICK BATTLE\n(1 to 3 PKMN Battle)": "⚔️  COMBATE RÁPIDO\n(Combate de 1 a 3 PKMN)",
	"⚔️  QUICK BATTLE\nFree 3 vs 3 Match": "⚔️  COMBATE RÁPIDO\nPartida Libre 3 vs 3",
	"🌐  ONLINE BATTLE\n(Cloud Rooms & Challenges)": "🌐  COMBATE EN LÍNEA\n(Salas y Retos Cloud)",
	"🌐  ONLINE BATTLE\nMultiplayer 3 vs 3 PvP": "🌐  COMBATE EN LÍNEA\nMultijugador 3 vs 3 PvP",
	"🌐  COMBATE EN LÍNEA\n(Salas y Retos Cloud)": "🌐  COMBATE EN LÍNEA\n(Salas y Retos Cloud)",
	"🌐  COMBATE EN LÍNEA\nMultijugador 3 vs 3 PvP": "🌐  COMBATE EN LÍNEA\nMultijugador 3 vs 3 PvP",
	"🎴  MY COLLECTION\n(View Cards & Stages)": "🎴  MI COLECCIÓN\n(Ver Cartas y Fases)",
	"🃏  MY COLLECTION\nInspect & Evolve Cards": "🃏  MI COLECCIÓN\nInspeccionar y Evolucionar Cartas",
	"🛒  SHOP\n(Gen 1 Kanto Booster)": "🛒  TIENDA\n(Sobres Kanto Gen 1)",
	"🛒  SHOP\nBooster Packs & Cards": "🛒  TIENDA\nSobres y Cartas",
	"🎁  DAILY MISSIONS & REWARDS": "🎁  MISIONES DIARIAS Y RECOMPENSAS",
	"🎁  DAILY MISSIONS & REWARDS  🔔": "🎁  MISIONES DIARIAS Y RECOMPENSAS  🔔",
	"📅  DAILY MISSIONS & REWARDS": "📅  MISIONES DIARIAS Y RECOMPENSAS",
	"👤  PROFILE": "👤  PERFIL",
	"👥  FRIENDS": "👥  AMIGOS",
	"⚙️  SETTINGS": "⚙️  AJUSTES",
	"🚪  EXIT GAME": "🚪  SALIR DEL JUEGO",

	# --- Ajustes (SettingsModal) ---
	"⚙️ SETTINGS": "⚙️ AJUSTES",
	"🌐 LANGUAGE": "🌐 IDIOMA",
	"Language:": "Idioma:",
	"🎵 AUDIO & MUSIC": "🎵 AUDIO Y MÚSICA",
	"Music Level:": "Volumen de Música:",
	"🔇 Mute Music": "🔇 Silenciar Música",
	"SFX Level:": "Volumen de Efectos (SFX):",
	"🔇 Mute SFX": "🔇 Silenciar Efectos (SFX)",
	"ℹ️ GAME SYSTEM": "ℹ️ SISTEMA DEL JUEGO",
	"Save Path: user://profile_save.json": "Ruta de Guardado: user://profile_save.json",
	"🔄 Check for Updates": "🔄 Buscar Actualizaciones",
	"⏳ Checking GitHub...": "⏳ Consultando GitHub...",
	"⬅ Back to Lobby": "⬅ Volver al Lobby",
	"⬅ Back to Menu": "⬅ Volver al Menú",
	"⬅ Back to Main Menu": "⬅ Volver al Menú Principal",
	"Back to Menu": "Volver al Menú",
	"Main Menu": "Menú Principal",
	"⬅ Main Menu": "⬅ Menú Principal",

	# --- Selección de Equipo (TeamSelectModal) ---
	"⚔️ TEAM SELECTION": "⚔️ SELECCIÓN DE EQUIPO",
	"Configure your team and the rival team (1st Leader, 2nd & 3rd Bench).": "Configura tu equipo y el equipo rival (1º Líder, 2º y 3º en Banca).",
	"🎲 Random": "🎲 Aleatorio",
	"Sort by:": "Ordenar por:",
	"🔢 ID": "🔢 ID",
	"📖 Dex": "📖 Dex",
	"🔤 A - Z": "🔤 A - Z",
	"⭐ Rarity": "⭐ Rareza",
	"✨ Evo": "✨ Evo",
	"✅ Owned": "✅ Obtenidas",
	"🔥 START BATTLE (3 vs 3)!": "🔥 ¡INICIAR COMBATE (3 vs 3)!",
	"🗑️  Clear Team": "🗑️  Limpiar Equipo",

	# --- Modos de Campaña (CampaignHubModal) ---
	"🏟️ CAMPAIGN MODES": "🏟️ MODOS DE CAMPAÑA",
	"Choose your path: compete in the Tournament or embark on Story Adventure!": "Elige tu camino: ¡compite en el Torneo o embárcate en la Aventura!",
	"🎓 Battle Tutorial": "🎓 Tutorial de Combate",
	"Master combat fundamentals: HP, Energy costs, Speed priority, Type advantages, and Recharging in a guided 1v1 battle (Charmander vs Bulbasaur).": "Domina los fundamentos del combate: HP, costos de Energía, prioridad de Velocidad, ventajas de Tipo y Recarga en una batalla guiada 1v1 (Charmander vs Bulbasaur).",
	"Status: Not started • First Clear: 💎 5 Diamonds": "Estado: No iniciado • Primera Victoria: 💎 5 Diamantes",
	"🎓 Start Tutorial": "🎓 Iniciar Tutorial",
	"🗺️ Adventure Mode": "🗺️ Modo Aventura",
	"Embark on an episodic Pokémon journey across regions! Battle gym leaders, level up your party, and conquer regional badges.": "¡Embárcate en un viaje Pokémon por episodios! Enfréntate a líderes de gimnasio, sube de nivel a tu equipo y conquista medallas regionales.",
	"Status: 🔒 Locked (Complete Battle Tutorial to unlock!)": "Estado: 🔒 Bloqueado (¡Completa el Tutorial de Combate para desbloquear!)",
	"🗺️ Enter Adventure Mode ➡": "🗺️ Entrar al Modo Aventura ➡",
	"🏟️ Pokémon Stadium": "🏟️ Pokémon Stadium",
	"Arcade adventure tournament: battle through challenging trainer rounds, manage your camp inventory, and claim victory!": "Torneo arcade: ¡supera rondas de entrenadores desafiantes, administra tu inventario en el campamento y reclama la victoria!",
	"Status: Ready to start": "Estado: Listo para comenzar",
	"⚔️ Enter Pokémon Stadium": "⚔️ Entrar a Pokémon Stadium",
	"📋 View Encounters Guide (All 9 Rounds)": "📋 Ver Guía de Encuentros (Las 9 Rondas)",
	"📋 Stadium Encounters Guide (All 9 Rounds)": "📋 Guía de Encuentros del Estadio (9 Rondas)",
	"💰 Combat Loot Rates (Per Pokémon Defeated)": "💰 Botín de Combate (Por Pokémon Derrotado)",
	"In Campaign battles (Adventure & Stadium), defeating rival Pokémon drops dynamic Gold (G) and Diamonds (💎) according to their Tier / Rarity & Stage:": "En batallas de Campaña (Aventura y Estadio), derrotar Pokémon rivales otorga Oro (G) y Diamantes (💎) según su Tier / Rareza y Fase:",
	"⚪ Common (Basic):": "⚪ Común (Básico):",
	"🟢 Uncommon:": "🟢 Poco Común:",
	"🔵 Rare / Stage 1:": "🔵 Raro / Fase 1:",
	"🟣 Epic / Stage 2:": "🟣 Épico / Fase 2:",
	"🟡 Legendary (Boss):": "🟡 Legendario (Jefe):",
	"💡 Gold is preserved for Camp Shop supplies. Diamonds are permanently added to your trainer wallet!": "💡 El Oro se conserva para suministros en la Tienda del Campamento. ¡Los Diamantes se añaden permanentemente a tu billetera!",

	# --- Episodios de Aventura (AdventureEpisodesModal) ---
	"🗺️ ADVENTURE EPISODES": "🗺️ EPISODIOS DE AVENTURA",
	"Select an episode to embark with your party and conquer gym badges:": "Selecciona un episodio para embarcarte con tu equipo y conquistar medallas de gimnasio:",
	"⛰️ Episode I: Pewter City Gym": "⛰️ Episodio I: Gimnasio de Ciudad Plateada",
	"Pewter City Gym: Journey from Route 2 through Viridian Forest to defeat Gym Leader Brock!": "Gimnasio de Ciudad Plateada: ¡Viaja desde la Ruta 2 a través del Bosque Verde para derrotar al Líder Brock!",
	"Battles: 4  |  First Clear: 💎 20 Diamonds & Ep. II Unlock": "Combates: 4  |  Primera Victoria: 💎 20 Diamantes y Desbloqueo Ep. II",
	"Status: Ready to embark": "Estado: Listo para partir",
	"🗺️ Embark on Episode I": "🗺️ Embarcarse en Episodio I",
	"💧 Episode II: Cerulean City Gym": "💧 Episodio II: Gimnasio de Ciudad Celeste",
	"Cerulean City Gym: Traverse Mt. Moon & Route 4 to challenge Gym Leader Misty!": "Gimnasio de Ciudad Celeste: ¡Cruza el Mt. Moon y la Ruta 4 para desafiar a la Líder Misty!",
	"Battles: 5  |  First Clear: 💎 30 Diamonds & Ep. III Unlock": "Combates: 5  |  Primera Victoria: 💎 30 Diamantes y Desbloqueo Ep. III",
	"Status: 🔒 Locked (Clear Episode I to unlock)": "Estado: 🔒 Bloqueado (Completa el Episodio I para desbloquear)",
	"🗺️ Embark on Episode II": "🗺️ Embarcarse en Episodio II",
	"⚡ Episode III: Vermilion City Gym": "⚡ Episodio III: Gimnasio de Ciudad Carmín",
	"Vermilion City Gym: Board the S.S. Anne and battle through Vermilion to challenge Gym Leader Lt. Surge!": "Gimnasio de Ciudad Carmín: ¡Aborda el S.S. Anne y lucha en Ciudad Carmín para desafiar al Teniente Surge!",
	"Battles: 7  |  First Clear: 💎 60 Diamonds & Ep. IV Unlock": "Combates: 7  |  Primera Victoria: 💎 60 Diamantes y Desbloqueo Ep. IV",
	"🗺️ Embark on Episode III": "🗺️ Embarcarse en Episodio III",
	"🌿 Episode IV: Celadon City Gym": "🌿 Episodio IV: Gimnasio de Ciudad Azulona",
	"Celadon City Gym: Cross Route 9 and the Rock Tunnel to challenge Gym Leader Erika!": "Gimnasio de Ciudad Azulona: ¡Cruza la Ruta 9 y el Túnel Roca para desafiar a la Líder Erika!",
	"Battles: 6  |  First Clear: 💎 80 Diamonds & Ep. V Unlock": "Combates: 6  |  Primera Victoria: 💎 80 Diamantes y Desbloqueo Ep. V",
	"Status: 🔒 Locked (Clear Episode III first)": "Estado: 🔒 Bloqueado (Completa primero el Episodio III)",
	"🔒 Locked (In Development)": "🔒 Bloqueado (En Desarrollo)",
	"⬅ Back to Campaign Modes": "⬅ Volver a Modos de Campaña",

	# --- Guía del Estadio (StadiumGuideModal) ---
	"🏟️ POKÉMON STADIUM: ENCOUNTERS": "🏟️ POKÉMON STADIUM: ENCUENTROS",
	"Roadmap of all 9 rounds across 3 phases, rival team compositions, allowed tiers, and rewards:": "Mapa de las 9 rondas en 3 fases, composición de equipos rivales, tiers permitidos y recompensas:",
	"🥉 PHASE 1: CLASSIFICATION (Rounds 1 - 3)": "🥉 FASE 1: CLASIFICACIÓN (Rondas 1 - 3)",
	"🥈 PHASE 2: ELIMINATION (Rounds 4 - 6)": "🥈 FASE 2: ELIMINACIÓN (Rondas 4 - 6)",
	"🏆 PHASE 3: GRAND FINALE (Rounds 7 - 9)": "🏆 FASE 3: GRAN FINAL (Rondas 7 - 9)",
	"⚖️ STADIUM RULES & GENERATION CRITERIA": "⚖️ REGLAS DEL ESTADIO Y CRITERIOS",
	"⬅ Close Guide": "⬅ Cerrar Guía",

	# --- Campamento de Torneo / Aventura (CampaignModal) ---
	"🏆 POKÉMON TOURNAMENT": "🏆 TORNEO POKÉMON",
	"Compete across 3 phases (9 battles total) to become the Tournament Champion!\n Pokémon HP is NOT restored automatically between matches. Spend Gold on Potions!": "¡Compite en 3 fases (9 combates en total) para convertirte en el Campeón del Torneo!\nEl HP de tus Pokémon NO se restaura automáticamente entre partidas. ¡Usa Oro en Pociones!",
	"🛡️ YOUR TOURNAMENT TEAM:": "🛡️ TU EQUIPO DE TORNEO:",
	"🛡️ YOUR ADVENTURE PARTY:": "🛡️ TU EQUIPO DE AVENTURA:",
	"🛒 CAMP SUPPLY SHOP": "🛒 TIENDA DE SUMINISTROS DEL CAMPAMENTO",
	"Potion (+10 HP to an active PKMN)": "Poción (+10 HP a un PKMN activo)",
	"Remedy (Cure Burn, Poison & Statuses)": "Remedio (Cura Quemadura, Veneno y Estados)",
	"Ether (+5 Energy to a PKMN in battle)": "Éter (+5 de Energía a un PKMN en combate)",
	"Revive (Revive a PKMN at 50% HP)": "Revivir (Revive a un PKMN con 50% HP)",
	"🔄 Change Team": "🔄 Cambiar Equipo",
	"🗑️ Restart Tournament (Forfeits Gold & Progress)": "🗑️ Reiniciar Torneo (Pierde Oro y Progreso)",
	"🗑️ Restart Episode (Forfeits Stage Progress)": "🗑️ Reiniciar Episodio (Pierde Progreso de Etapa)",

	# --- Mi Colección (CollectionModal) ---
	"🃏 MY COLLECTION": "🃏 MI COLECCIÓN",
	"⬅ Back to Grid": "⬅ Volver a la Cuadrícula",
	"CARD DETAILS": "DETALLES DE LA CARTA",
	"🔒 CARD NOT UNLOCKED\nOpen Booster Packs in the Shop to obtain this Pokémon!": "🔒 CARTA NO DESBLOQUEADA\n¡Abre Sobres en la Tienda para obtener este Pokémon!",
	"📊 BASE STATS": "📊 ESTADÍSTICAS BASE",
	"🔥 Weakness:": "🔥 Debilidad:",
	"(+2 damage taken)": "(+2 de daño recibido)",
	"🛡️ Resistance:": "🛡️ Resistencia:",
	"(-2 damage taken)": "(-2 de daño recibido)",
	"✨ PASSIVE ABILITY": "✨ HABILIDAD PASIVA",
	"Passive ability description...": "Descripción de habilidad pasiva...",
	"Basic attack with no secondary effect.": "Ataque básico sin efecto secundario.",
	"⬅ Previous": "⬅ Anterior",
	"Next ➡": "Siguiente ➡",

	# --- Tienda (ShopModal) ---
	"🛒 BOOSTER PACK SHOP": "🛒 TIENDA DE SOBRES",
	"Booster Pack (Kanto)": "Sobre de Expansión (Kanto)",
	"Price: 💎 5 Diamonds": "Precio: 💎 5 Diamantes",
	"Contains 3 random cards based on Rarity. Expand your collection and unlock powerful Pokémon!": "Contiene 3 cartas aleatorias según su Rareza. ¡Expande tu colección y desbloquea Pokémon poderosos!",
	"💡 Earn Diamonds in Tournament Mode!": "💡 ¡Gana Diamantes en el Modo Torneo!",
	"📊 RARITY DROP RATES (PER CARD):": "📊 PROBABILIDADES POR RAREZA (POR CARTA):",
	"✨ FEATURED FOIL CARDS (EPIC & LEGENDARY):": "✨ CARTAS FOIL DESTACADAS (ÉPICAS Y LEGENDARIAS):",
	"✨ OPEN BOOSTER PACK (💎 5 Diamonds)": "✨ ABRIR SOBRE (💎 5 Diamantes)",
	"🎉 All cards unlocked for testing!": "🎉 ¡Todas las cartas desbloqueadas para pruebas!",

	# --- Login y Bienvenida (LoginModal / WelcomeModal) ---
	"👋 Welcome to Battle Frontier!": "👋 ¡Bienvenido a Battle Frontier!",
	"▶️  PLAY AS GUEST\nStart or continue on this device": "▶️  JUGAR COMO INVITADO\nIniciar o continuar en este dispositivo",
	"☁️  LOG IN WITH GOOGLE\nRestore your cloud profile & cards": "☁️  INICIAR SESIÓN CON GOOGLE\nRestaura tu perfil y cartas de la nube",
	"📝  REGISTER GOOGLE ACCOUNT\nCreate new cloud-synced profile": "📝  REGISTRAR CUENTA DE GOOGLE\nCrear nuevo perfil sincronizado en la nube",
	"WELCOME, TRAINER!": "¡BIENVENIDO, ENTRENADOR!",
	"💎 +25 GEMS & 🍬 50 RARE CANDIES!": "💎 +25 GEMAS Y 🍬 50 CARAMELOS RAROS!",
	"Welcome to Pokémon Battle Frontier!\nAs a special welcome gift, we have granted 25 Gems and 50 Rare Candies so you can open packs and evolve your first Pokémon!": "¡Bienvenido a Pokémon Battle Frontier!\nComo regalo especial de bienvenida, ¡te hemos otorgado 25 Gemas y 50 Caramelos Raros para que abras sobres y evoluciones a tu primer Pokémon!",
	"🛒 Go to Shop & Open Booster Packs (25 💎)": "🛒 Ir a la Tienda y Abrir Sobres (25 💎)",
	"▶️ Enter Lobby": "▶️ Entrar al Lobby",

	# --- Perfil del Entrenador (ProfileModal / EraseConfirmModal / CloudNoticeModal) ---
	"👤 TRAINER PROFILE": "👤 PERFIL DEL ENTRENADOR",
	"Trainer Alias:": "Alias de Entrenador:",
	"Enter Trainer Alias...": "Ingresa tu Alias de Entrenador...",
	"Google Email:": "Correo de Google:",
	"Not connected": "No conectado",
	"Status: 📱 Local Storage Active": "Estado: 📱 Almacenamiento Local Activo",
	"🔗 Connect with Google Account": "🔗 Conectar con Cuenta de Google",
	"🏆 PERSONAL RECORDS & STATS": "🏆 RÉCORDS Y ESTADÍSTICAS PERSONALES",
	"✅ Progress saved successfully!": "✅ ¡Progreso guardado con éxito!",
	"💾  SAVE PROGRESS (Local Storage)": "💾  GUARDAR PROGRESO (Almacenamiento Local)",
	"🚪  LOG OUT": "🚪  CERRAR SESIÓN",
	"⚠️ ERASE TRAINER PROFILE?": "⚠️ ¿BORRAR PERFIL DE ENTRENADOR?",
	"❌ Cancel": "❌ Cancelar",
	"Cancel": "Cancelar",
	"🗑️ Yes, Erase Profile": "🗑️ Sí, Borrar Perfil",
	"☁️ CLOUD AUTHENTICATION": "☁️ AUTENTICACIÓN EN LA NUBE",
	"🌐 Sign In with Google (Browser)": "🌐 Iniciar Sesión con Google (Navegador)",
	"⌨️ Or enter email manually...": "⌨️ O ingresa tu correo manualmente...",
	"Email Address:": "Correo Electrónico:",
	"e.g. ash@gmail.com": "ej. ash@gmail.com",
	"e.g. Ash, Red, Nestor...": "ej. Ash, Red, Nestor...",
	"Password:": "Contraseña:",
	"Min 6 characters": "Mín. 6 caracteres",
	"✅ Set Name & Enter Lobby": "✅ Guardar Nombre y Entrar al Lobby",
	"📨  Resend Verification Email": "📨  Reenviar Correo de Verificación",

	# --- Sala Online (OnlineLobbyModal) ---
	"🌐 ONLINE POKÉMON BATTLE": "🌐 COMBATE POKÉMON EN LÍNEA",
	"Connect with another trainer via Google Cloud": "Conéctate con otro entrenador vía Google Cloud",
	"🏠 Create Room": "🏠 Crear Sala",
	"🔑 Join Room": "🔑 Unirse a Sala",
	"Share this room code with your friend to battle:": "Comparte este código de sala con tu amigo para combatir:",
	"🛡️ Your Team:": "🛡️ Tu Equipo:",
	"✏️ Edit Team": "✏️ Editar Equipo",
	"👤 Rival: Waiting for opponent...": "👤 Rival: Esperando oponente...",
	"👤 Rival: Not connected": "👤 Rival: No conectado",
	"⏳ Waiting for rival to be READY...": "⏳ Esperando a que el rival esté LISTO...",
	"⏳ Waiting for rival to enter room code...": "⏳ Esperando a que el rival ingrese el código...",
	"Enter the 4-character room code:": "Ingresa el código de sala de 4 caracteres:",
	"e.g. UJK3": "ej. UJK3",
	"🔗 Connect to Room": "🔗 Conectar a la Sala",
	"🏠 Connected to room": "🏠 Conectado a la sala",
	"✅ READY FOR BATTLE": "✅ LISTO PARA COMBATIR",
	"👥  Friends List & Direct Challenges": "👥  Lista de Amigos y Retos Directos",
	"⬅ Cancel & Return": "⬅ Cancelar y Volver",

	# --- Misiones Diarias (DailyModal) ---
	"📅 DAILY MISSIONS & REWARDS": "📅 MISIONES DIARIAS Y RECOMPENSAS",
	"🎁 7-Day Login Streak Rewards": "🎁 Recompensas por Racha de 7 Días",
	"Available!": "¡Disponible!",
	"🎁 Claim Today's Reward": "🎁 Reclamar Recompensa de Hoy",
	"✅ Claimed Today": "✅ Reclamado Hoy",
	"⚔️ Today's Missions": "⚔️ Misiones de Hoy",
	"⏰ Resets daily at 00:00": "⏰ Se reinicia a las 00:00",
	"Daily Completion Bonus (+10 💎)": "Bono por Completar Misiones (+10 💎)",
	"Complete all 3 daily missions to claim!": "¡Completa las 3 misiones diarias para reclamar!",
	"Claim +10 💎": "Reclamar +10 💎",

	# --- Amigos (FriendsModal) ---
	"👥 TRAINER FRIENDS & MATCHES": "👥 AMIGOS Y RETOS DE ENTRENADOR",
	"⚔️ DIRECT BATTLE CHALLENGE RECEIVED!": "⚔️ ¡RETO DE COMBATE DIRECTO RECIBIDO!",
	"⚔️ ACCEPT": "⚔️ ACEPTAR",
	"✖ Dismiss": "✖ Descartar",
	"Search trainers by Google Email, Alias (e.g. Ash) or ID (PKMN-)...": "Buscar entrenadores por Correo, Alias (ej. Ash) o ID (PKMN-)...",
	"Search trainers by Google Email, Alias (e.g. Ash) or ID (PKMN-...)...": "Buscar entrenadores por Correo, Alias (ej. Ash) o ID (PKMN-...)...",
	"🔍 Search": "🔍 Buscar",
	"🔎 Search Results": "🔎 Resultados de Búsqueda",
	"🔄 Refresh": "🔄 Actualizar",
	"💡 Tip: Click '⚔️ Challenge' on any friend to start an instant online battle!": "💡 Consejo: ¡Pulsa '⚔️ Retar' en cualquier amigo para iniciar un combate en línea al instante!",

	# --- Actualizaciones (UpdateModal) ---
	"🚀 NEW UPDATE AVAILABLE!": "🚀 ¡NUEVA ACTUALIZACIÓN DISPONIBLE!",
	"Changelog details...": "Detalles de la versión...",
	"⬇️ Download Update": "⬇️ Descargar Actualización",
	"🌐 View on GitHub": "🌐 Ver en GitHub",
	"Later": "Más tarde",

	# --- Combate (battle.tscn / battle.gd) ---
	"⬅ Menu": "⬅ Menú",
	"📊 Types": "📊 Tipos",
	"Quick Battle (3 vs 3)": "Combate Rápido (3 vs 3)",
	"  RIVAL BENCH:": "  BANCA RIVAL:",
	"  BANCA RIVAL:": "  BANCA RIVAL:",
	"  YOUR BENCH (SWITCH POKÉMON):": "  TU BANCA (CAMBIAR POKÉMON):",
	"YOUR TURN": "TU TURNO",
	"RIVAL'S TURN": "TURNO DEL RIVAL",
	"[center]Battle Ready![/center]": "[center]¡Listos para el Combate![/center]",
	"Player": "Jugador",
	"Rival": "Rival",
	"⚡ Boost (+1⚡)": "⚡ Boost (+1⚡)",
	"🛡️ Passive": "🛡️ Pasiva",
	"🔋 Recharge (+1⚡)": "🔋 Recargar (+1⚡)",
	"🎒 Bag": "🎒 Mochila",
	"Attack 1": "Ataque 1",
	"Attack 2": "Ataque 2",
	"VICTORY!": "¡VICTORIA!",
	"DEFEAT...": "DERROTA...",
	"You won the battle!": "¡Ganaste el combate!",
	"Play Again": "Jugar de Nuevo",
	"ENERGY USAGE": "USO DE ENERGÍA",
	"Choose how much energy to spend for this attack:": "Elige cuánta energía gastar para este ataque:",
	"✖ Cancel (Choose another action)": "✖ Cancelar (Elegir otra acción)",
	"🎒 TRAINER'S BAG": "🎒 MOCHILA DEL ENTRENADOR",
	"⚠️ Using an item will consume your turn.": "⚠️ Usar un objeto consumirá tu turno.",
	"Select a target Pokémon:": "Selecciona un Pokémon objetivo:",
	"✖ Close Bag (Don't spend turn)": "✖ Cerrar Mochila (No gastar turno)",
	"📊 TYPE EFFECTIVENESS CHART": "📊 TABLA DE EFECTIVIDAD DE TIPOS",
	"⚔️ ACTIVE BATTLE MATCHUP": "⚔️ DUELO ACTIVO EN COMBATE",
	"Loading combat matchup data...": "Cargando datos de emparejamiento...",
	"🗡️ Rows: ATTACK TYPE": "🗡️ Filas: TIPO DE ATAQUE",
	"🛡️ Columns: DEFENDER": "🛡️ Columnas: DEFENSOR",
	"💡 [color=#ffd700]Tap any cell or type icon[/color] to view exact damage modifier.": "💡 [color=#ffd700]Toca cualquier celda o icono de tipo[/color] para ver el modificador exacto de daño.",
	"🟩 +2 Super Effective": "🟩 +2 Súper Efectivo",
	"🟥 -2 Resisted (Table / Same Type)": "🟥 -2 Resistido (Tabla / Mismo Tipo)",
	"⬜ — Neutral Damage": "⬜ — Daño Neutro",
	"⬅ Return to Battle": "⬅ Volver al Combate",
	"✨ EVOLUTION! ✨": "✨ ¡EVOLUCIÓN! ✨",
	"💖 Restored +10 HP!": "💖 ¡Restauró +10 HP!",
	"Continue ➡": "Continuar ➡",
	"BASIC": "BÁSICO",
	"STAGE 1": "FASE 1",
	"STAGE 2": "FASE 2",
	"LEGENDARY": "LEGENDARIO",
	"Weak:": "Débil:",
	"Res:": "Res:"
}

# Reemplazos de frases ordenados para cadenas dinámicas (con números, nombres, etc.)
const PHRASE_REPLACEMENTS: Array = [
	# --- Lobby & Perfil & Tienda ---
	["👤 Trainer: ", "👤 Entrenador: "],
	["Diamonds:", "Diamantes:"],
	["Diamonds", "Diamantes"],
	["Diamond", "Diamante"],
	["Rare Candies:", "Caramelos Raros:"],
	["Rare Candies", "Caramelos Raros"],
	["Rare Candy", "Caramelo Raro"],
	["Campaign Gold:", "Oro de Campaña:"],
	["Gold:", "Oro:"],
	["Tournaments Won:", "Torneos Ganados:"],
	["Packs Opened:", "Sobres Abiertos:"],
	["Cards Collected:", "Cartas Obtenidas:"],
	["Cards:", "Cartas:"],
	["Battles:", "Combates:"],
	["First Clear:", "Primera Victoria:"],
	["Status: Ready to start", "Estado: Listo para comenzar"],
	["Status: Ready to embark", "Estado: Listo para partir"],
	["Status: Not started", "Estado: No iniciado"],
	["Status: ✅ Completed", "Estado: ✅ Completado"],
	["Status: 🔒 Locked", "Estado: 🔒 Bloqueado"],
	["Complete Battle Tutorial to unlock!", "¡Completa el Tutorial de Combate para desbloquear!"],
	["Clear Episode I to unlock", "Completa el Episodio I para desbloquear"],
	["Clear Episode II to unlock", "Completa el Episodio II para desbloquear"],
	["Clear Episode III first", "Completa primero el Episodio III"],
	["In Progress (Battle ", "En Curso (Combate "],
	["In Progress (Stage ", "En Curso (Etapa "],
	["Continue Battle ", "Continuar Combate "],
	["Continue Stage ", "Continuar Etapa "],
	["Your Team (", "Tu Equipo ("],
	["Rival AI (", "IA Rival ("],
	["1st LEADER:\n", "1º LÍDER:\n"],
	["2nd Bench:\n", "2º Banca:\n"],
	["3rd Bench:\n", "3º Banca:\n"],
	["1st LEADER: ", "1º LÍDER: "],
	["2nd Bench: ", "2º Banca: "],
	["3rd Bench: ", "3º Banca: "],
	["(Empty)", "(Vacío)"],
	["Empty", "Vacío"],
	["Inventory: ", "Inventario: "],
	["Potions", "Pociones"],
	["Potion", "Poción"],
	["Remedies", "Remedios"],
	["Remedy", "Remedio"],
	["Ethers", "Éteres"],
	["Ether", "Éter"],
	["Revives", "Revivir"],
	["Buy (", "Comprar ("],
	["START BATTLE (", "INICIAR COMBATE ("],
	["Battle ", "Combate "],
	[" of ", " de "],
	["Stage: Basic", "Fase: Básico"],
	["Stage: Stage 1", "Fase: Fase 1"],
	["Stage: Stage 2", "Fase: Fase 2"],
	["Stage: Legendary", "Fase: Legendario"],
	["Max HP:", "HP Máx:"],
	["Speed:", "Velocidad:"],
	["(Turn order)", "(Orden de turno)"],
	["Recovery:", "Recarga:"],
	["Energy / turn", "Energía / turno"],
	["Passive:", "Pasiva:"],
	["Cost:", "Costo:"],
	["Req:", "Req:"],
	["Boost Effect:", "Efecto Boost:"],
	["Boost:", "Boost:"],
	["extra ⚡ ->", "⚡ extra ->"],
	["Version: ", "Versión: "],
	["Save Path: ", "Ruta de Guardado: "],
	["✅ Up to date (", "✅ Actualizado ("],
	["⚠️ Could not check updates", "⚠️ No se pudo buscar actualizaciones"],
	["is available (Current:", "está disponible (Actual:"],
	["Friends: ", "Amigos: "],
	["My Friends (", "Mis Amigos ("],
	["Day ", "Día "],
	["PACKS", "SOBRES"],
	["RECYCLE", "RECICLAR"],
	["HIDDEN SHOP", "TIENDA OCULTA"],
	["ALL", "TODOS"],
	["OTHER", "OTROS"],

	# --- Cartas y Tipos ---
	["GRASS Type", "Tipo PLANTA"],
	["FIRE Type", "Tipo FUEGO"],
	["WATER Type", "Tipo AGUA"],
	["ELECTRIC Type", "Tipo ELÉCTRICO"],
	["THUNDER Type", "Tipo ELÉCTRICO"],
	["NORMAL Type", "Tipo NORMAL"],
	["PSYCHIC Type", "Tipo PSÍQUICO"],
	["FIGHTING Type", "Tipo LUCHA"],
	["ROCK Type", "Tipo ROCA"],
	["GROUND Type", "Tipo TIERRA"],
	["POISON Type", "Tipo VENENO"],
	["BUG Type", "Tipo BICHO"],
	["FLYING Type", "Tipo VOLADOR"],
	["GHOST Type", "Tipo FANTASMA"],
	["ICE Type", "Tipo HIELO"],
	["DRAGON Type", "Tipo DRAGÓN"],
	["STEEL Type", "Tipo ACERO"],
	["DARK Type", "Tipo SINIESTRO"],
	["FAIRY Type", "Tipo HADA"],

	# --- Combate & Botones de Movimiento ---
	["YOUR TURN", "TU TURNO"],
	["RIVAL'S TURN", "TURNO DEL RIVAL"],
	["RIVAL'S BENCH: (No reserves)", "BANCA RIVAL: (Sin reservas)"],
	["RIVAL'S BENCH:", "BANCA RIVAL:"],
	["YOUR BENCH (SWITCH POKÉMON):", "TU BANCA (CAMBIAR POKÉMON):"],
	["YOUR BENCH: (No reserves)", "TU BANCA: (Sin reservas)"],
	["Type: ", "Tipo: "],
	["Weak: ", "Débil: "],
	["Energy: ", "Energía: "],
	["EXP: MAX (Final Stage)", "EXP: MÁX (Fase Final)"],
	["Ready for ", "¡Listo para "],
	["Missing ", "Falta carta "],
	["Burn (", "Quemado ("],
	["Toxic (-1 DMG & tick)", "Tóxico (-1 DMG y pulso)"],
	["Poison (-1 DMG)", "Veneno (-1 DMG)"],
	["Flinch", "Retroceso"],
	["Frozen", "Congelado"],
	["Asleep (", "Dormido ("],
	["Paralyzed", "Paralizado"],
	["Confused", "Confundido"],
	["Trapped (", "Atrapado ("],
	["Seeded (", "Drenadoras ("],
	["Shield -", "Escudo -"],
	["Wall (", "Muro ("],
	["Evasive", "Evasivo"],
	["Underground", "Bajo Tierra"],
	["Wait 1 turn (Resting)", "Espera 1 turno (Descanso)"],
	["Locked by Disable!", "¡Bloqueado por Anulación!"],
	["WAIT...", "ESPERA..."],
	["ROUND ", "RONDA "],
	["takes the first turn", "toma el primer turno"],
	["faster Speed:", "mayor Velocidad:"],
	["Speed tie", "Empate de Velocidad"],
	["coin flip", "lanzamiento de moneda"],
	["Bench Recharge:", "Recarga en Banca:"],
	["recovered +1⚡", "recuperó +1⚡"],
	["Recharge (+", "Recargar (+" ],
	["Boost ON", "Boost ACTIVO"],
	["Boost (+", "Boost (+" ],
	["No Boost", "Sin Boost"],
	["Target: ", "Objetivo: "],
	["Base Attack (", "Ataque Base ("],
	["Boosted Attack (", "Ataque con Boost ("],
	["Need ", "Faltan "],
	["Locked", "Bloqueado"],
	["Fainted", "Debilitado"],
	["Active", "Activo"],
	["Bench 1", "Banca 1"],
	["Bench 2", "Banca 2"],
	["Super Effective!", "¡Súper Efectivo!"],
	["Super Effective", "Súper Efectivo"],
	["Resisted", "Resistido"],
	["Critical Hit!", "¡Golpe Crítico!"],
	["What? ", "¿Qué? ¡"],
	[" is evolving!", " está evolucionando!"],
	[" evolved into ", " evolucionó a "],
	["Restored +", "¡Restauró +"],
	["You won the battle!", "¡Ganaste el combate!"],
	["All your Pokémon fainted...", "Todos tus Pokémon se debilitaron..."],

	# --- Descripciones de Movimientos y Pasivas ---
	["Use 1 extra energy to ", "Usa 1 energía extra para "],
	["Use 2 extra energy to ", "Usa 2 energías extra para "],
	["Use 1 extra energy for ", "Usa 1 energía extra para "],
	["Use 2 extra energy for ", "Usa 2 energías extra para "],
	["deal +", "causar +"],
	["deals +", "causa +"],
	["extra damage", "de daño extra"],
	["additional damage", "de daño adicional"],
	["and cause Flinch", "y causar Retroceso (Flinch)"],
	["and inflict Burn", "y causar Quemadura"],
	["and inflict Poison", "y causar Veneno"],
	["and inflict Paralyze", "y causar Parálisis"],
	["and inflict Freeze", "y causar Congelación"],
	["and inflict Confusion", "y causar Confusión"],
	["and avoid recoil damage", "y evitar el daño de retroceso"],
	["Avoids Recoil DMG", "Evita Daño de Retroceso"],
	["Inflicts Flinch", "Causa Retroceso"],
	["Inflicts Burn", "Causa Quemadura"],
	["Inflicts Confusion", "Causa Confusión"],
	["Inflicts Freeze", "Causa Congelación"],
	["Inflicts Paralyze", "Causa Parálisis"],
	["Deals X2 DMG", "Causa Daño X2"],
	["100% HP Drain", "Drena 100% HP"],
	["-1 Foe Speed", "-1 Velocidad Rival"],
	["Boosted Effect", "Efecto Mejorado"],
	["Extra DMG", "DMG Extra"],
	["Heals ", "Cura "],
	["Recovers ", "Recupera "],
	["Reduces incoming damage by ", "Reduce el daño recibido en "],
	["Reduces foe Speed by ", "Reduce la Velocidad del rival en "],
	["Flip a coin", "Lanza una moneda"],
	["Multi-hit attack", "Ataque multigolpe"],
	["Always hits first", "Siempre ataca primero"],
	["Ignores shields and resistances", "Ignora escudos y resistencias"]
]

static func translate_en_to_es(text: String) -> String:
	if text.is_empty():
		return text
	if EXACT_EN_TO_ES.has(text):
		return EXACT_EN_TO_ES[text]
	var stripped = text.strip_edges()
	if EXACT_EN_TO_ES.has(stripped):
		var prefix_len = text.find(stripped)
		var prefix = text.substr(0, prefix_len) if prefix_len > 0 else ""
		var suffix = text.substr(prefix_len + stripped.length())
		return prefix + EXACT_EN_TO_ES[stripped] + suffix

	var result = text
	for pair in PHRASE_REPLACEMENTS:
		if result.contains(pair[0]):
			result = result.replace(pair[0], pair[1])
	return result

static func _should_skip_node(node: Node) -> bool:
	if node == null:
		return true
	if node.name == "LanguageOption":
		return true
	if node.has_meta("_skip_localization"):
		return true
	return false

static func _is_numeric_or_symbol_only(s: String) -> bool:
	var clean = s.strip_edges()
	if clean.is_empty():
		return true
	# Floating numbers like "-5", "-5!", "+4", "10 / 10", "80%"
	var has_letter = false
	for i in range(clean.length()):
		var code = clean.unicode_at(i)
		if (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or (code >= 192 and code <= 687):
			has_letter = true
			break
	return not has_letter

static func translate_node_single(node: Node, lang: String) -> void:
	if _should_skip_node(node):
		return

	# Tooltip translation on any Control
	if node is Control:
		var ctrl := node as Control
		if ctrl.tooltip_text != "":
			if lang == "es":
				var last_es_tip = str(ctrl.get_meta("_last_es_tooltip", ""))
				if ctrl.tooltip_text != last_es_tip:
					ctrl.set_meta("_orig_en_tooltip", ctrl.tooltip_text)
					var es_tip = translate_en_to_es(ctrl.tooltip_text)
					ctrl.set_meta("_last_es_tooltip", es_tip)
					if es_tip != ctrl.tooltip_text:
						ctrl.tooltip_text = es_tip
			else:
				if ctrl.has_meta("_last_es_tooltip"):
					if ctrl.tooltip_text == str(ctrl.get_meta("_last_es_tooltip")) and ctrl.has_meta("_orig_en_tooltip"):
						ctrl.tooltip_text = str(ctrl.get_meta("_orig_en_tooltip"))
					ctrl.remove_meta("_last_es_tooltip")

	if node is LineEdit:
		var le := node as LineEdit
		if le.placeholder_text != "":
			if lang == "es":
				var last_es_ph = str(le.get_meta("_last_es_placeholder", ""))
				if le.placeholder_text != last_es_ph:
					le.set_meta("_orig_en_placeholder", le.placeholder_text)
					var es_ph = translate_en_to_es(le.placeholder_text)
					le.set_meta("_last_es_placeholder", es_ph)
					if es_ph != le.placeholder_text:
						le.placeholder_text = es_ph
			else:
				if le.has_meta("_last_es_placeholder"):
					if le.placeholder_text == str(le.get_meta("_last_es_placeholder")) and le.has_meta("_orig_en_placeholder"):
						le.placeholder_text = str(le.get_meta("_orig_en_placeholder"))
					le.remove_meta("_last_es_placeholder")
		return

	if node is OptionButton:
		var ob := node as OptionButton
		for i in range(ob.item_count):
			var item_txt = ob.get_item_text(i)
			var meta_orig_key = "_orig_en_item_%d" % i
			var meta_es_key = "_last_es_item_%d" % i
			if lang == "es":
				var last_es_item = str(ob.get_meta(meta_es_key, ""))
				if item_txt != last_es_item:
					ob.set_meta(meta_orig_key, item_txt)
					var es_item = translate_en_to_es(item_txt)
					ob.set_meta(meta_es_key, es_item)
					if es_item != item_txt:
						ob.set_item_text(i, es_item)
			else:
				if ob.has_meta(meta_es_key):
					if item_txt == str(ob.get_meta(meta_es_key)) and ob.has_meta(meta_orig_key):
						ob.set_item_text(i, str(ob.get_meta(meta_orig_key)))
					ob.remove_meta(meta_es_key)
		return

	if node is Label or node is Button or node is RichTextLabel:
		var cur_txt: String = str(node.get("text"))
		if cur_txt.is_empty() or _is_numeric_or_symbol_only(cur_txt):
			return
		if lang == "es":
			var last_es = str(node.get_meta("_last_es_text", ""))
			if cur_txt != last_es:
				node.set_meta("_orig_en_text", cur_txt)
				var es_txt = translate_en_to_es(cur_txt)
				node.set_meta("_last_es_text", es_txt)
				if es_txt != cur_txt:
					node.set("text", es_txt)
		else:
			if node.has_meta("_last_es_text"):
				if cur_txt == str(node.get_meta("_last_es_text")) and node.has_meta("_orig_en_text"):
					node.set("text", str(node.get_meta("_orig_en_text")))
				node.remove_meta("_last_es_text")

static func translate_node_tree(root: Node, lang: String) -> void:
	if root == null:
		return
	translate_node_single(root, lang)
	for child in root.get_children():
		translate_node_tree(child, lang)
