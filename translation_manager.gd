extends Node

## Translation Manager - EDITOR-SAFE VERSION
## NO JavaScriptBridge calls = NO errors in Godot Editor!

# Signals
signal language_changed(new_language: String)
signal translations_loaded()

# Current language
var current_language: String = "en":
	set(value):
		if value != current_language:
			current_language = value
			save_language_preference()
			language_changed.emit(current_language)

# Available languages with their native names
const LANGUAGES := {
	"en": "English",
	"ms": "Bahasa Melayu",
	"zh": "中文 (简体)",
	"ta": "தமிழ்",
	"ar": "العربية"
}

# Translation cache
var translations: Dictionary = {}
var is_loaded: bool = false

func _ready() -> void:
	# Always load fallback translations
	load_fallback_translations()
	
	# Load saved language preference
	load_language_preference()
	
	print("✅ TranslationManager ready with %d translation keys" % translations.size())

# ============================================
# CORE TRANSLATION FUNCTIONS
# ============================================

func get_text(key: String, replacements: Dictionary = {}) -> String:
	"""Get translated text for a key in the current language"""
	var text := _get_translation(key, current_language)
	
	# Apply replacements
	for placeholder in replacements:
		text = text.replace(placeholder, str(replacements[placeholder]))
	
	return text

func _get_translation(key: String, lang: String) -> String:
	"""Internal function to get translation with fallback logic"""
	
	# Try current language
	if key in translations and lang in translations[key]:
		return translations[key][lang]
	
	# Fallback to English
	if key in translations and "en" in translations[key]:
		return translations[key]["en"]
	
	# Return key if no translation found
	return key

# ============================================
# TRANSLATION DATA
# ============================================

func load_fallback_translations() -> void:
	"""Load hardcoded translations (works everywhere!)"""
	
	translations = {
		# Main Menu
		"main_menu.welcome": {
			"en": "Welcome to PhishProof - Let's see if you'd get scammed! 🎃",
			"ms": "Selamat Datang ke PhishProof - Mari lihat jika anda tertipu! 🎃",
			"zh": "欢迎来到 PhishProof - 让我们看看你会不会上当！🎃",
			"ta": "PhishProof க்கு வரவேற்கிறோம் - நீங்கள் ஏமாற்றப்படுவீர்களா என்று பார்ப்போம்! 🎃",
			"ar": "مرحبًا بك في PhishProof - دعنا نرى إذا كنت ستخدع! 🎃"
		},
		"main_menu.start": {
			"en": "Get Started",
			"ms": "Mula",
			"zh": "开始",
			"ta": "தொடங்குங்கள்",
			"ar": "ابدأ"
		},
		"main_menu.exit": {
			"en": "Exit",
			"ms": "Keluar",
			"zh": "退出",
			"ta": "வெளியேறு",
			"ar": "خروج"
		},
		
		# Name Input
		"name_input.title": {
			"en": "Your Name",
			"ms": "Nama Anda",
			"zh": "您的名字",
			"ta": "உங்கள் பெயர்",
			"ar": "اسمك"
		},
		"name_input.placeholder": {
			"en": "Enter your name",
			"ms": "Masukkan nama anda",
			"zh": "输入您的名字",
			"ta": "உங்கள் பெயரை உள்ளிடவும்",
			"ar": "أدخل اسمك"
		},
		
		# Role Selection
		"role.civilian": {
			"en": "Civilian 👨‍💼",
			"ms": "Awam 👨‍💼",
			"zh": "平民 👨‍💼",
			"ta": "சாதாரண மக்கள் 👨‍💼",
			"ar": "مدني 👨‍💼"
		},
		"role.office_staff": {
			"en": "Office Staff 💼",
			"ms": "Kakitangan Pejabat 💼",
			"zh": "办公室职员 💼",
			"ta": "அலுவலக ஊழியர்கள் 💼",
			"ar": "موظف مكتب 💼"
		},
		"role.cybersecurity": {
			"en": "Cybersecurity Pro 🛡️",
			"ms": "Pakar Keselamatan Siber 🛡️",
			"zh": "网络安全专家 🛡️",
			"ta": "இணைய பாதுகாப்பு நிபுணர் 🛡️",
			"ar": "محترف الأمن السيبراني 🛡️"
		},
		
		# Game UI
		"game.score": {
			"en": "Score",
			"ms": "Skor",
			"zh": "分数",
			"ta": "மதிப்பெண்",
			"ar": "النتيجة"
		},
		"game.level": {
			"en": "Level",
			"ms": "Tahap",
			"zh": "级别",
			"ta": "நிலை",
			"ar": "المستوى"
		},
		"game.player": {
			"en": "Player",
			"ms": "Pemain",
			"zh": "玩家",
			"ta": "வீரர்",
			"ar": "لاعب"
		},
		
		# Settings Menu
		"settings.title": {
			"en": "Settings",
			"ms": "Tetapan",
			"zh": "设置",
			"ta": "அமைப்புகள்",
			"ar": "إعدادات"
		},
		"settings.language": {
			"en": "Language",
			"ms": "Bahasa",
			"zh": "语言",
			"ta": "மொழி",
			"ar": "اللغة"
		},
		"settings.save_game": {
			"en": "Save Game",
			"ms": "Simpan Permainan",
			"zh": "保存游戏",
			"ta": "விளையாட்டை சேமிக்கவும்",
			"ar": "حفظ اللعبة"
		},
		"settings.sound": {
			"en": "Sound Settings",
			"ms": "Tetapan Bunyi",
			"zh": "声音设置",
			"ta": "ஒலி அமைப்புகள்",
			"ar": "إعدادات الصوت"
		},
		"settings.return_menu": {
			"en": "Return to Main Menu",
			"ms": "Kembali ke Menu Utama",
			"zh": "返回主菜单",
			"ta": "பிரதான பட்டியலுக்குத் திரும்பு",
			"ar": "العودة إلى القائمة الرئيسية"
		},
		"settings.exit_game": {
			"en": "Exit Game",
			"ms": "Keluar Permainan",
			"zh": "退出游戏",
			"ta": "விளையாட்டிலிருந்து வெளியேறு",
			"ar": "الخروج من اللعبة"
		},
		"settings.game_saved": {
			"en": "Game saved successfully!",
			"ms": "Permainan berjaya disimpan!",
			"zh": "游戏保存成功！",
			"ta": "விளையாட்டு வெற்றிகரமாக சேமிக்கப்பட்டது!",
			"ar": "تم حفظ اللعبة بنجاح!"
		},
		"settings.sound_coming_soon": {
			"en": "Sound settings coming soon!",
			"ms": "Tetapan bunyi akan datang tidak lama lagi!",
			"zh": "声音设置即将推出！",
			"ta": "ஒலி அமைப்புகள் விரைவில் வரும்!",
			"ar": "إعدادات الصوت قريبًا!"
		},
		"settings.confirm_return_menu": {
			"en": "Save progress and return to main menu?",
			"ms": "Simpan kemajuan dan kembali ke menu utama?",
			"zh": "保存进度并返回主菜单？",
			"ta": "முன்னேற்றத்தை சேமித்து பிரதான பட்டியலுக்குத் திரும்பவா?",
			"ar": "حفظ التقدم والعودة إلى القائمة الرئيسية؟"
		},
		"settings.confirm_exit": {
			"en": "Save progress and quit the game?",
			"ms": "Simpan kemajuan dan keluar dari permainan?",
			"zh": "保存进度并退出游戏？",
			"ta": "முன்னேற்றத்தை சேமித்து விளையாட்டிலிருந்து வெளியேறவா?",
			"ar": "حفظ التقدم والخروج من اللعبة؟"
		},
		
		# Common Actions
		"common.confirm": {
			"en": "Confirm",
			"ms": "Sahkan",
			"zh": "确认",
			"ta": "உறுதிப்படுத்து",
			"ar": "تأكيد"
		},
		"common.cancel": {
			"en": "Cancel",
			"ms": "Batal",
			"zh": "取消",
			"ta": "ரத்துசெய்",
			"ar": "إلغاء"
		},
		"common.save": {
			"en": "Save",
			"ms": "Simpan",
			"zh": "保存",
			"ta": "சேமி",
			"ar": "حفظ"
		},
		"common.loading": {
			"en": "Loading...",
			"ms": "Memuatkan...",
			"zh": "加载中...",
			"ta": "ஏற்றுகிறது...",
			"ar": "جاري التحميل..."
		},
		"common.confirm_reset": {
			"en": "Clear all data and start fresh?",
			"ms": "Padam semua data dan mula semula?",
			"zh": "清除所有数据并重新开始？",
			"ta": "எல்லா தரவையும் அழித்து புதிதாக தொடங்கவா?",
			"ar": "مسح جميع البيانات والبدء من جديد؟"
		}
	}
	
	is_loaded = true
	translations_loaded.emit()

# ============================================
# LANGUAGE PREFERENCES
# ============================================

func save_language_preference() -> void:
	"""Save current language to local config file"""
	var config = ConfigFile.new()
	config.set_value("preferences", "language", current_language)
	config.save("user://preferences.cfg")

func load_language_preference() -> void:
	"""Load saved language preference"""
	var config = ConfigFile.new()
	var err = config.load("user://preferences.cfg")
	
	if err == OK:
		current_language = config.get_value("preferences", "language", "en")
	else:
		# Auto-detect system language
		var system_locale = OS.get_locale()
		if system_locale.begins_with("ms"):
			current_language = "ms"
		elif system_locale.begins_with("zh"):
			current_language = "zh"
		elif system_locale.begins_with("ta"):
			current_language = "ta"
		elif system_locale.begins_with("ar"):
			current_language = "ar"
		else:
			current_language = "en"

# ============================================
# UTILITY FUNCTIONS
# ============================================

func get_available_languages() -> Dictionary:
	"""Get dictionary of available languages"""
	return LANGUAGES.duplicate()

func cycle_language() -> void:
	"""Cycle to the next available language"""
	var lang_keys = LANGUAGES.keys()
	var current_index = lang_keys.find(current_language)
	var next_index = (current_index + 1) % lang_keys.size()
	current_language = lang_keys[next_index]

func get_language_name(lang_code: String) -> String:
	"""Get the native name of a language"""
	return LANGUAGES.get(lang_code, lang_code)
