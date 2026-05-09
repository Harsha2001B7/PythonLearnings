"""
2. Bytecode explorer
Write three different expressions, disassemble each with dis, and note how many bytecode instructions each one uses.
pipeline
Try:  x = 1 + 2
      x = [1, 2, 3]
      x = "hello" * 3
Count the LOAD/STORE instructions in each.
"""
import dis

dis.dis("x = 1 + 2")
# dis.dis("x = [1, 2, 3]")    
# dis.dis("x = 'hello' * 3")