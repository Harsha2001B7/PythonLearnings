"""
9. Mini password validator
Ask for a password and check: length ≥ 8, has uppercase, has digit, has no spaces. Print a pass/fail for each rule and an overall result.
strings
Input:  Password: Hello1
Output:
✓ Length: FAIL (6 chars, need 8)
✓ Uppercase: PASS
✓ Has digit: PASS
✓ No spaces: PASS
Result: WEAK — fix 1 rule
"""

pwd = "Harsha123"

rules = {
    "Length ≥ 8": len(pwd) >= 8,
    "Has uppercase": any(c.isupper() for c in pwd),
    "Has digit": any(c.isdigit() for c in pwd),
    "No spaces": " " not in pwd,
}

fails = 0
for rule, passed in rules.items():
    status = "PASS" if passed else "FAIL"
    print(f"  {rule}: {status}")
    if not passed:
        fails += 1

if fails == 0:
    print("Result: STRONG")
elif fails == 1:
    print(f"Result: WEAK — fix 1 rule")
else:
    print(f"Result: WEAK — fix {fails} rules")