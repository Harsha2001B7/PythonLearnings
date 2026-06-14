from passlib.context import CryptContext

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)

# print(pwd_context.hash("teacher123"))  # $2b$12$Ks.T5Pm29dS.zDohwxBLae2U7dLvXaPTMG6JWeEnewlKz/e6OhUg.
# print(pwd_context.hash("principal123"))  # $2b$12$10QP.mgfoH94NdaauVFwyumZajJFxw008g0MbjMGK.y1SObu9M.b6




# print(pwd_context.hash("teacher456")) # $2b$12$.x/Fou0s2Lfs6a6wfETUN.XwMsDzovwJIwwSSq0w1PMotBLb.58DS
