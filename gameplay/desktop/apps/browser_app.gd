extends Control

# Browser App for Desktop OS
# Simulates web browsing with phishing website detection

@onready var url_bar = $VBoxContainer/NavigationBar/URLBar
@onready var security_indicator = $VBoxContainer/NavigationBar/SecurityIndicator
@onready var page_content = $VBoxContainer/Content/MarginContainer/PageContent

var legitimate_sites := {
	"www.maybank2u.com.my": {
		"title": "Maybank2u Online Banking",
		"content": """[b]Welcome to Maybank2u[/b]

Official Maybank online banking portal.

✓ Secure HTTPS connection
✓ Verified SSL certificate
✓ Official domain: maybank2u.com.my"""
	},
	"www.pos.com.my": {
		"title": "Pos Malaysia",
		"content": """[b]Pos Malaysia Official Website[/b]

Track parcels, send mail, and more.

✓ Secure connection
✓ Official postal service
✓ Domain: pos.com.my"""
	}
}

var phishing_sites := {
	"maybank-secure.net": {
		"title": "Maybank Account Verification",
		"content": """[color=red][b]⚠️ WARNING: This is a phishing website![/b][/color]

Red flags:
• Suspicious domain (not maybank2u.com.my)
• Requests sensitive information
• Mimics legitimate Maybank website

[b]Never enter your credentials here![/b]"""
	},
	"poslaju-my.com": {
		"title": "Parcel Tracking",
		"content": """[color=red][b]⚠️ WARNING: This is a phishing website![/b][/color]

Red flags:
• Wrong domain (official is pos.com.my)
• Requests payment for delivery
• Suspicious tracking system

[b]Do not proceed![/b]"""
	}
}

func _ready():
	print("🌐 Browser App: Initializing...")

func _on_url_submitted(url: String):
	print("🔗 Browser App: Navigating to -", url)
	_load_url(url)

func _load_url(url: String):
	# Remove http:// or https:// if present
	url = url.replace("https://", "").replace("http://", "")
	url_bar.text = url
	
	# Check if it's a legitimate site
	if legitimate_sites.has(url):
		_display_legitimate_site(url)
	# Check if it's a known phishing site
	elif phishing_sites.has(url):
		_display_phishing_site(url)
	else:
		_display_404()

func _display_legitimate_site(url: String):
	var site = legitimate_sites[url]
	security_indicator.text = "🔒"
	security_indicator.modulate = Color.GREEN
	
	page_content.text = "[center]" + site.content + "[/center]"

func _display_phishing_site(url: String):
	var site = phishing_sites[url]
	security_indicator.text = "⚠️"
	security_indicator.modulate = Color.RED
	
	page_content.text = "[center]" + site.content + "[/center]"

func _display_404():
	security_indicator.text = "❓"
	security_indicator.modulate = Color.GRAY
	
	page_content.text = """[center][b]Page Not Found[/b]

The website you're looking for could not be found.

Try visiting:
• www.maybank2u.com.my
• www.pos.com.my[/center]"""
