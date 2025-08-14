%% OddSumEvenProduct
%% Input: A list of integers
%% Output: A tuple where
%% - the first element is the product of elements at even positions ,
%% - the second element is the sum of elements at odd positions
declare

fun {IsEven N}
    if (N mod 2) == 0 then N else 1 end
end

fun {IsOdd N}
    if (N mod 2) \= 0 then N else 0 end
end


fun {OddSumEvenProduct L}
    local List_isEven List_isOdd product sum R in
        List_isEven = {List.map L IsEven}
        List_isOdd = {List.map L IsOdd}
        product = {List.product List_isEven}
        sum = {List.sum List_isOdd}
        R = result(product1: sum1:{List.sum List_isOdd})
    end     
end
local
    L = [1 2 3 4 5 6]
    L2 = {OddSumEvenProduct L}
in
    {Browse L2}
end

local L L1 in
    L = [1 2 3 4 5 6]
    L1 = {List.sum L}
    {Browse L1}
end