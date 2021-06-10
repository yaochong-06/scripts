import sys

def max_slice(p_list):
    """get the max start_sofarice from the given list
    """
    maxsofar = -sys.maxsize
    prev_maxendinghere = maxendinghere = 0
    
    start_sofar = end_sofar = start_endinghere = end_endinghere = 0

    for i in range(len(p_list)):
        print(maxsofar,maxendinghere)
        maxendinghere += p_list[i]
        prev_maxendinghere = maxendinghere
        if maxendinghere < 0:
            prev_maxendinghere = maxendinghere
            maxendinghere = 0
            start_endinghere = end_endinghere = i+1
        else:
            end_endinghere += 1

        if maxsofar < prev_maxendinghere:
            maxsofar = prev_maxendinghere
            start_sofar = start_endinghere
            end_sofar = end_endinghere

    # special handle if start_sofar euqal to end_sofar
    if start_sofar == end_sofar:
        start_sofar = start_sofar - 1

    return maxsofar,start_sofar,end_sofar


p_list = [2,1,-1,5,-3]
print("input list is : %s"%p_list)
max, i_start, i_end = max_slice(p_list)
print("max value is : %s"%max)
print("max list is : %s"%p_list[i_start:i_end])

p_list = [1, 3, -20, 10, 8 , -11]
print("input list is : %s"%p_list)
max, i_start, i_end = max_slice(p_list)
print("max value is : %s"%max)
print("max list is : %s"%p_list[i_start:i_end])

p_list = [-31, -3, -20, -10, -8 , -11]
max, i_start, i_end = max_slice(p_list)
print(max, i_start, i_end)
print("max value is : %s"%max)
print("max list is : %s"%p_list[i_start:i_end])

p_list = [-31, -3, 10, -1, -8 , -11]
max, i_start, i_end = max_slice(p_list)
print(max, i_start, i_end)
print("max value is : %s"%max)
print("max list is : %s"%p_list[i_start:i_end])

p_list = [-31, -3, 0, -1, -8 , -11]
max, i_start, i_end = max_slice(p_list)
print(max, i_start, i_end)
print("max value is : %s"%max)
print("max list is : %s"%p_list[i_start:i_end])