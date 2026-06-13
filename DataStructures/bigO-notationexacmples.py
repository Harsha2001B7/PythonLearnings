#---------------------------------------------------------#
def example0(num):
    return num%2 == 0
#O(1) - big O constant because no matter the (n) there is contant number of operations here always just chekking wheather num is odd or even
#---------------------------------------------------------#
def example1(nums):
    total = 0

    for number in nums:
        total+=number

    return total

#O(n) - big O of (n) because as n gets larger the constanst doesnt matter the total and total+= number and return dont matter so herfe its [n + 3] = O(n)
#---------------------------------------------------------#
def example2(nums):
    results =  [1 for _ in range(len(nums))]

    for i , num1 in enumerate(nums):
        for num2 in nums:
            if num1 == num2:
                continue
            results[i] *= num2
    return results        

#O(n^2) becasue inner for loop run every time outer loop run 
#---------------------------------------------------------#
def example3(nums1, nums2):
    results = []
    for num in nums1:
        results.append(num)
    for i, num in enumerate(nums2):
        if i >= len(results):
            results.append(1)
        results[i] *= num
    return results

#O(n+m) as we have two distinct input variables 
#---------------------------------------------------------#
def example4(nested_list):
    total = 0 

    for inner_list in nested_list:
        for num in inner_list:
            total += num
        for num in inner_list:
            total += num
        for num in inner_list:
            total += num
    return total

#O(nm) 
#---------------------------------------------------------#
def example5(n):
    if n == 1:
        return 1
    if n == 2:
        return 2
    last = example5(n-1)
    second_last = example5(n-2)
    return last + second_last

fib = example5(10)
print(fib)

#O(2^n) in recursive find the number of times the fucntions run and then multiply by number of operations like a tree refer fibanaci series
#---------------------------------------------------------#
def example6(lst,search_lst):
    max_value = max(lst)
    
    for value in search_lst:
        if max_value == value:
            return True
        
    return False
#O(n+m) max is a built in funtion whic will loop through the list so it wont be constant
#---------------------------------------------------------# 
def example7(n):
    if n == 0:
        return
    print(n)
    example7(round(n/2))
#O(log2(n))       here n is constantly getting reduced by half exponectially 
#---------------------------------------------------------#
def example8(strings):
    for i, string in enumerate(strings):
        digits = 0 
        
        for char in string:
            if char in [str[i] for i in range(0,10)]:
                digit+=1
        
        if digits >= len(string)/2:
            strings[i] = sorted(strings[i])
    return strings

# Let:
# n = number of strings
# m = average length of each string
#
# Outer loop:
# for string in strings
# Runs n times
# => O(n)
#
# Inner loop:
# for char in string
# Runs m times for each string
# => O(n * m)
#
# Digit check:
# [str(i) for i in range(10)]
# Creates only 10 elements
# => O(10) = O(1) (constant)
#
# Sorting:
# sorted(string)
# Sorts m characters
# => O(m log m)
#
# Worst case:
# Every string gets sorted
# => n * O(m log m)
# => O(nm log m)
#
# Total:
# O(nm + nm log m)
# Remove smaller term
# => O(nm log m)
#
# Space Complexity:
# O(m) for sorted string creation
#---------------------------------------------------------#
def example9(dict1:dict, dict2:dict):
    keys1 = sorted(dict1.keys())
    keys2 = sorted(dict2.keys())

    process = keys1 + keys2
    results = set()

    while len(process)>0:
        element = process.pop(0)
        results.add(element)

        if len(element)==1:
            continue

        process.append(element[:-1])
    
    return results

#---------------------------------------------------------#
 