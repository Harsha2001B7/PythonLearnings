class Vehicle:
    def __init__(self, name):
        self.name = name

    def start(self):
        print(f"{self.name} is starting")


class Car(Vehicle):
    def drive(self):
        print(f"{self.name} is driving on the road")


class Helicopter(Vehicle):
    def fly(self):
        print(f"{self.name} is flying in the sky")


car1 = Car("BMW")
heli1 = Helicopter("Apache")

car1.start()
car1.drive()

heli1.start()
heli1.fly()

#testinf pull222222222222222
