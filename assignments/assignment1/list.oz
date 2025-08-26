%% OddSumEvenProduct
%% Input: A list of integers
%% Output: A tuple where
%% - the first element is the product of elements at even positions ,
%% - the second element is the sum of elements at odd positions
%%% Edge cases: %%%
%% - If the list is empty, return nil
%% - If there are no even-positioned elements, the product should be 1
%% - If there are no odd-positioned elements, the sum should be 0
declare

fun {IsEven N}
    (N mod 2) == 0
end

fun {SumList L}
    case L of nil then 0
    [] H|T then H + {SumList T}
    end
end

fun {ProductList L}
    case L of nil then 1
    [] H|T then H * {ProductList T}
    end
end

fun {OddSumEvenProduct L}
    local List_isEven List_isOdd in
        case L of nil then nil
        else
        {List.partition L IsEven List_isEven List_isOdd}
        result(product:{ProductList List_isEven} sum:{SumList List_isOdd})
        end
    end     
end


% Test cases
local
    L1 = [7 8 9 10 11 12]
    L2 = [1 3 5]
    L3 = [2 4 6]
    L4 = nil
in
    {Browse {OddSumEvenProduct L1}}
    {Browse {OddSumEvenProduct L2}}
    {Browse {OddSumEvenProduct L3}}
    {Browse {OddSumEvenProduct L4}}
    
end
