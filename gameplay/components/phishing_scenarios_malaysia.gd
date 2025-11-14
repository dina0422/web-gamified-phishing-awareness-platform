# Additional Phishing Scenarios for Malaysian Context
# These can be used for other NPCs in the beginner level

## Scenario 2: Fake Bank SMS (Maybank)
var maybank_scenario = {
	"npc_name": "Sarah",
	"dialogue": [
		"Oh no! I just got this SMS from Maybank...",
		"It says there's suspicious activity on my account.",
		"They want me to update my TAC code by clicking this link.",
		"Should I do it? I'm really worried about my savings!"
	],
	"platform": "SMS",
	"message": """Maybank Alert: 
	
Suspicious transaction detected on your account.
Amount: RM 3,450.00

Verify your identity NOW:
https://maybank-secure.tk

Enter your TAC code to prevent account suspension.

-Maybank Security Team""",
	"question": "What should Sarah do?",
	"options": {
		"A": "Click the link and enter TAC code to secure account",
		"B": "Call Maybank's official hotline (1-300-88-6688) to verify",
		"C": "Reply to the SMS asking for more information",
		"D": "Share the message in family WhatsApp group for advice"
	},
	"correct_answer": "B",
	"scores": {"A": 0, "B": 100, "C": 25, "D": 0},
	"phishing_indicators": [
		"Suspicious URL (.tk domain, not maybank.com.my)",
		"Requests TAC code (banks NEVER ask for this)",
		"Creates urgency and fear",
		"Generic sender name",
		"Threatens account suspension"
	],
	"feedback": {
		"A": "❌ CRITICAL ERROR!\n\nNEVER share your TAC code! This is a major red flag.\n\nReal banks:\n✗ Never ask for TAC via SMS/call\n✗ Never use suspicious URLs\n✗ Never threaten immediate suspension\n\nYou would have lost access to your account and money!",
		"B": "✓✓ PERFECT!\n\nYou made the right choice!\n\n✓ Didn't click suspicious link\n✓ Recognized phishing attempt\n✓ Chose official verification method\n✓ Protected TAC code\n\nMaybank's real number: 1-300-88-6688\nAlways verify through official channels!",
		"C": "⚠ POOR CHOICE!\n\nNever engage with suspicious messages.\n\nWhy this is wrong:\n• Confirms your number is active\n• Scammer knows you're interested\n• Might lead to more scam attempts\n\nCorrect action: Call the bank directly using their official number!",
		"D": "❌ VERY DANGEROUS!\n\nThis spreads the scam and puts family at risk!\n\nWhy it's harmful:\n• Family members might click the link\n• Scammers reach more victims\n• Could compromise multiple accounts\n\nInstead: Warn them it's a scam WITHOUT forwarding the actual message!"
	}
}

## Scenario 3: Fake Delivery Notification (PosLaju)
var poslaju_scenario = {
	"npc_name": "Uncle Kumar",
	"dialogue": [
		"Hello there! I need your help with something.",
		"I'm expecting a package, and I got this notification from PosLaju.",
		"But they're asking me to pay RM 8.50 for customs clearance...",
		"Is this normal? The link takes me to a payment page."
	],
	"platform": "SMS",
	"message": """PosLaju Notification:

Your parcel (Track: MY4532167) is held at customs.

Pay clearance fee: RM 8.50

Complete payment here:
http://poslaju-delivery.net/pay

Parcel will be returned if not paid within 48 hours.

-PosLaju""",
	"question": "What should Uncle Kumar do?",
	"options": {
		"A": "Pay RM 8.50 - it's a small amount and worth it",
		"B": "Visit the official PosLaju website to track the package",
		"C": "Ignore it - probably just spam",
		"D": "Call the number shown in the SMS"
	},
	"correct_answer": "B",
	"scores": {"A": 0, "B": 100, "C": 50, "D": 25},
	"phishing_indicators": [
		"Fake URL (poslaju-delivery.net instead of pos.com.my)",
		"Unsolicited payment request",
		"Small amount to avoid suspicion",
		"Urgent 48-hour deadline",
		"Generic tracking number",
		"No official branding"
	],
	"feedback": {
		"A": "❌ SCAM PAYMENT!\n\nSmall amounts are tactics to avoid suspicion!\n\nWhat happens next:\n• Credit card details stolen\n• Possible unauthorized charges\n• Identity theft risk\n• No actual package delivery\n\nReal customs fees are paid at pickup, not via SMS links!",
		"B": "✓✓ EXCELLENT DECISION!\n\nYou showed great security awareness!\n\n✓ Recognized fake URL\n✓ Chose official verification\n✓ Protected payment information\n✓ Avoided potential fraud\n\nAlways use official websites:\nPosLaju: www.pos.com.my\nTrack packages only through official channels!",
		"C": "⚠ PARTIAL CREDIT\n\nIgnoring is better than clicking, but not the best approach.\n\nWhy?\n• You miss legitimate notifications\n• Don't learn to identify scams\n• Can't report the fraud\n\nBetter: Verify through official channels and report suspicious messages!",
		"D": "⚠ RISKY MOVE!\n\nThe number in the SMS is likely fake too!\n\nProblems:\n• Scammer's hotline\n• Might pressure you to pay\n• Could steal more information\n• Premium rate number charges\n\nAlways use official contact numbers from the company's website!"
	}
}

## Scenario 4: Fake Job Offer (LinkedIn/Email)
var job_offer_scenario = {
	"npc_name": "Melissa",
	"dialogue": [
		"Hey! Check this out!",
		"I just got a job offer via email - RM 6,000 per month!",
		"They want me to be a 'money transfer agent' - work from home!",
		"But they're asking for my bank account details first. Is this legit?"
	],
	"platform": "Email",
	"message": """Subject: Congratulations! Job Offer - Money Transfer Agent

Dear Candidate,

You have been selected for a WORK FROM HOME position!

Position: Money Transfer Agent
Salary: RM 6,000/month
Requirements: Bank account for fund transfers

NO EXPERIENCE NEEDED! EASY WORK!

To confirm your position:
1. Reply with your full bank details
2. IC number and address
3. Start immediately!

This is a LIMITED TIME offer!

Best regards,
HR Department - Tech Solutions Sdn Bhd""",
	"question": "What should Melissa do?",
	"options": {
		"A": "Reply with bank details - it's a great opportunity!",
		"B": "Research the company and verify through official channels",
		"C": "Ask for more details about the job first",
		"D": "Accept but use a separate bank account"
	},
	"correct_answer": "B",
	"scores": {"A": 0, "B": 100, "C": 60, "D": 10},
	"phishing_indicators": [
		"Too good to be true salary",
		"No interview or proper application process",
		"Requests bank details upfront",
		"Suspicious job title (money mule scheme)",
		"High pressure tactics",
		"Generic sender",
		"No company website mentioned"
	],
	"feedback": {
		"A": "❌ CRITICAL DANGER!\n\nThis is a MONEY MULE SCAM!\n\nConsequences:\n• Used for money laundering\n• Your account used for criminal activity\n• Bank account frozen\n• Legal prosecution possible\n• Lost IC data for identity theft\n\nLegitimate jobs NEVER ask for bank details before interview!",
		"B": "✓✓ OUTSTANDING!\n\nYou avoided a dangerous scam!\n\n✓ Recognized unrealistic offer\n✓ Suspicious of upfront bank detail request\n✓ Understood verification importance\n✓ Protected personal information\n\nRed flags spotted:\n• No interview process\n• Requests sensitive information\n• Money mule scheme indicators\n\nAlways research companies on SSM, check reviews, and interview properly!",
		"C": "⚠ BETTER, BUT RISKY\n\nEngaging with scammers is dangerous.\n\nRisks:\n• They might be very convincing\n• Pressure tactics could work\n• Waste of time\n• Marks you as a potential target\n\nBetter approach: Research first, then only engage if it checks out as legitimate!",
		"D": "❌ STILL A SCAM!\n\nUsing a different account doesn't help!\n\nWhy it's still bad:\n• Still participating in money laundering\n• Still legally liable\n• Account will be frozen\n• Criminal record possible\n• IC information compromised\n\nNO legitimate employer asks for bank details before interview!"
	}
}

## Scenario 5: Fake EPF Withdrawal (Government Impersonation)
var epf_scenario = {
	"npc_name": "Pak Hassan",
	"dialogue": [
		"Assalamualaikum, young one. Can you help me?",
		"I received this message about EPF special withdrawal...",
		"It says I'm eligible for RM 10,000 under a new government program.",
		"They need me to fill in my details. Should I proceed?"
	],
	"platform": "WhatsApp",
	"message": """KWSP (EPF) OFFICIAL ANNOUNCEMENT

Special Withdrawal Program 2024
Available for ALL members!

Eligibility:
✓ Malaysian citizen
✓ EPF account holder
✓ Withdrawal up to RM 10,000

APPLY NOW (Last 3 days):
https://epf-withdrawal2024.com/apply

Required information:
- Full name and IC number
- EPF account number  
- Bank account details
- Password confirmation

Process time: 24 hours only!

-KWSP Malaysia""",
	"question": "What should Pak Hassan do?",
	"options": {
		"A": "Fill in the form immediately to secure the withdrawal",
		"B": "Visit the official EPF website or branch office to verify",
		"C": "Share the message with others so they don't miss out",
		"D": "Call the number in the message to confirm"
	},
	"correct_answer": "B",
	"scores": {"A": 0, "B": 100, "C": 0, "D": 30},
	"phishing_indicators": [
		"Fake URL (not kwsp.gov.my)",
		"Unsolicited government benefit",
		"Requests sensitive personal information",
		"Asks for password/EPF number",
		"Urgent deadline pressure",
		"Too good to be true offer",
		"No official letterhead or reference number"
	],
	"feedback": {
		"A": "❌ IDENTITY THEFT DANGER!\n\nThis is a government impersonation scam!\n\nWhat you'd lose:\n• IC number (identity theft)\n• EPF account details\n• Bank information  \n• Online banking password\n• Potential EPF account hijacking\n\nReal EPF withdrawals:\n✓ Announced on official website\n✓ Never ask for passwords\n✓ Require in-person or official app submission",
		"B": "✓✓ WISE DECISION!\n\nYou protected Pak Hassan's retirement savings!\n\n✓ Recognized fake URL\n✓ Suspicious of unsolicited offer\n✓ Chose official verification\n✓ Protected sensitive information\n\nOfficial EPF info:\nWebsite: www.kwsp.gov.my\nCall: 03-8922 6000\nVisit: EPF branch\n\nGovernment agencies NEVER ask for passwords via messages!",
		"C": "❌ SPREADING THE SCAM!\n\nThis multiplies the damage!\n\nHarm caused:\n• More victims lose information\n• Elder community especially vulnerable\n• Retirement savings at risk\n• Trust in government eroded\n\nInstead: Warn others it's a scam and report to KWSP and cybersecurity Malaysia!",
		"D": "⚠ RISKY APPROACH\n\nThe number is likely part of the scam!\n\nProblems:\n• Scammer's hotline\n• Will pressure you to proceed\n• Might extract more information\n• Possible premium rate charges\n\nAlways use official EPF contact numbers from www.kwsp.gov.my!"
	}
}
