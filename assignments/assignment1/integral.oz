%% integral
%% Input: A function F, real numbers A and B with A < B, and an even integer N > 0
%% Output: A real number approximating the definite integral of F over [A, B] using Simpson ’s rule

declare
fun {Sqr A}
    local R = A*A
    in
        R
    end
end


fun {Sqr2 F A}
    local R = {F A} + A
    in
        R
    end
end

local C
in
    C = 5
    {Browse {Sqr2 Sqr C}}
end

declare
fun {Integral F A B N}
    local
        H = (B-A)/N
        
        C = {NewCell 0.0}
        C:= @C + {F H}
        C:= @C + 1.0
        R = @C
    in
        R
    end
end

local A B N
in
    A = 1.0
    B = 9.0
    N = 2.0
    {Browse {Integral Sqr A B N}}
end