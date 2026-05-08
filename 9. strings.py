# Three ways to write strings
s1 = 'single quotes'
s2 = "double quotes"
s3 = """triple quotes
can span multiple lines"""
 
# Concatenation and repetition
"py" + "thon"     # 'python'
"ab" * 3          # 'ababab'
 
# Indexing and slicing (zero-based)
s = "python"
s[0]      # 'p'
s[-1]     # 'n'    (negative = from end)
s[0:2]    # 'py'   (start inclusive, end exclusive)
s[:3]     # 'pyt'
s[3:]     # 'hon'
s[::-1]   # 'nohtyp'  (reversed)
len(s)    # 6

###############################################

name = "  Alice  "
name.strip()           # 'Alice'
name.lower()           # '  alice  '
name.upper()           # '  ALICE  '
name.replace("A","E")  # '  Elice  '
 
"a,b,c".split(",")     # ['a', 'b', 'c']
",".join(["a","b"])    # 'a,b'
 
"py" in "python"       # True
"python".startswith("py")  # True
"  ".isspace()         # True

###############################################

name = "Alice"; age = 30
f"{name} is {age}"               # 'Alice is 30'
f"{name.upper():>10}"            # '     ALICE'  (right-align, width 10)
f"{3.14159:.2f}"                 # '3.14'
f"{1000000:,}"                   # '1,000,000'
f"{age=}"                        # 'age=30'  (debug shorthand)
