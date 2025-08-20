%% AddPolynomials
%% Input: Two lists of integers representing polynomials
%% Output: A list of integers representing the sum of the polynomials
%% Examples
%% {AddPolynomials [1 ~2] [4 3 2 1]} = [4 3 3 ~1]
%% {AddPolynomials [3 0 0 4 1 ~5] [0 2 ~1 1 4 10]} = [3 2 ~1 5 5 5]


%% PadWithZeros
%% Input: A list of integers and a number N
%% Output: A list of integers with N zeros appended to the left
declare
fun {PadWithZeros L N}
    if N == 0 then L
    else 0 | {PadWithZeros L (N-1)}
    end
end

fun {AddList L1 L2}
    case L1 of H1|T1 then
        case L2 of H2|T2 then
            H1+H2|{AddList T1 T2}
        end
    else nil end
end

fun {AddPolynomials P1 P2}
    % 1. If P1 is longer than P2, pad P2 with zeros and use AddList
    % 2. If P2 is longer than P1, pad P1 with zeros and use AddList
    % 3. If they are the same length, just use AddList
    local L1 L2 in
        if {Length P1} < {Length P2} then
            L1 = {PadWithZeros P1 {Length P2} - {Length P1}}
            L2 = P2
        elseif {Length P1} > {Length P2} then
            L2 = {PadWithZeros P2 {Length P1} - {Length P2}}
            L1 = P1
        else
            L1 = P1
            L2 = P2
        end
            {AddList L1 L2}
    end
end


local
%test case of the current function
    P1 = [~2 2 0]
    P2 = [2 1 0 0 0]
in
    {Browse {AddPolynomials P1 P2}}
end