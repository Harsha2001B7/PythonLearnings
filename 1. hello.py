print("Hello, World!")


import dis
dis.dis('print("Hello, world!")')

"""
  0           RESUME                   0

  1           LOAD_NAME                0 (print)
              PUSH_NULL
              LOAD_CONST               0 ('Hello, world!')
              CALL                     1
              RETURN_VALUE

"""
