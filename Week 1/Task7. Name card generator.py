"""
7. Name card generator
Ask the user for their full name and print a formatted card showing initials, name length, uppercase, and a personalised greeting.
strings
Input:  Enter your full name: harsha vardhan

Output:
━━━━━━━━━━━━━━━━━━
  HV  |  Harsha Vardhan
  15 letters  |  2 words
  "Hello, Harsha!"
━━━━━━━━━━━━━━━━━━
"""

name = "harsha vardhan"

def name_card(username):
    line = "━"*30
    words = username.split()
    initials = words[0][0].upper() + words[1][0].upper()
    
    print(line)
    print(f"   {initials}   |  {username.title()}")
    print(f"   {len(username)} letters   |   {len(words)} words")
    print(f"   \"Hello, {words[0].title()}!\"")
    print(line)

name_card(name)