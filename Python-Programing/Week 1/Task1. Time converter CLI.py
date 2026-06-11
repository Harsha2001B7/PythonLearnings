"""
1. Time converter CLI
A program that takes seconds from the user and prints it as hours, minutes, seconds — like a clock.

Input:  Enter seconds: 3725
Output: 1 hour(s), 2 minute(s), 5 second(s)
"""

def time_converter(seconds):
    hours = seconds // 3600
    minutes = (seconds % 3600) // 60
    remaining_seconds = seconds % 60
    return f"{hours} hours(s), {minutes} minute(s), {remaining_seconds} second(s)"
    

print(time_converter(3725))


def time_converter(seconds):
    hours, rem = divmod(seconds, 3600)
    minutes, secs = divmod(rem, 60)
    return f"{hours} hours(s), {minutes} minute(s), {secs} second(s)"

print(time_converter(3725))