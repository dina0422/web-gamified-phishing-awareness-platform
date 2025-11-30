extends Node

## Translation Uploader - Admin tool to populate Firestore with translations
## Run this scene once to upload all translations to Firestore

# Translation data structure
const TRANSLATIONS = {
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

func _ready() -> void:
	print("\n" + "="*50)
	print("TRANSLATION UPLOADER - ADMIN TOOL")
	print("="*50 + "\n")
	
	# Wait for Firebase to be ready
	if not Firebase.is_initialized():
		print("⏳ Waiting for Firebase initialization...")
		await Firebase.initialization_complete
	
	print("🔥 Firebase ready!")
	print("📤 Starting translation upload...")
	
	await upload_all_translations()
	
	print("\n✅ Translation upload complete!")
	print("You can now close this scene.\n")

func upload_all_translations() -> void:
	"""Upload all translations to Firestore"""
	var total = TRANSLATIONS.size()
	var uploaded = 0
	
	for key in TRANSLATIONS:
		print("📝 Uploading: %s" % key)
		await upload_translation(key, TRANSLATIONS[key])
		uploaded += 1
		print("   Progress: %d/%d" % [uploaded, total])
	
	print("\n🎉 Uploaded %d translation keys!" % total)

func upload_translation(key: String, translations: Dictionary) -> void:
	"""Upload a single translation document to Firestore"""
	
	# Prepare the data
	var data = {}
	for lang in translations:
		data[lang] = translations[lang]
	
	# JavaScript code to upload to Firestore
	var js_code = """
	(async () => {
		try {
			const db = window.db;
			const doc = window.doc;
			const setDoc = window.setDoc;
			
			const docRef = doc(db, 'translations', '%s');
			await setDoc(docRef, %s);
			
			return { success: true };
		} catch (error) {
			console.error('Error uploading translation:', error);
			return { success: false, error: error.message };
		}
	})();
	""" % [key.replace("'", "\\'"), JSON.stringify(data)]
	
	var result = await JavaScriptBridge.eval_async(js_code)
	
	if not result or not result.success:
		push_error("❌ Failed to upload %s: %s" % [key, result.get("error", "Unknown error")])
