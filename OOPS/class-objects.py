# Create a class
class Person:

    # Constructor
    def __init__(self, name, age):
        # Instance variables
        self.personname = name
        self.personage = age

    # Instance method
    def greet(self):
        print(f"Hello, my name is {self.personname}")
        print(f"My age is {self.personage}")


# Create an object
p1 = Person("John", 36)

# Call method
p1.greet()