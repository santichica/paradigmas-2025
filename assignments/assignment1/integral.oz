%% integral
%% Input: A function F, real numbers A and B with A < B, and an even integer N > 0. The N should be an integer in float format (e.g., 10.0).
%% Output: A real number approximating the definite integral of F over [A, B] using Simpson ’s rule

%% Main function
declare
fun {Integral F A B N}
    local
        N_float = {Int.toFloat N}
        H = (B-A)/N_float
        
        C = {NewCell 0.0}
        for I in 0..N do

            if {Bool.'or' I==0 I==N} then
                C:= @C + {F (A+H*{Int.toFloat I})}
            elseif (I mod 2) \= 0 then
                C:= @C + 4.0*{F (A+H*{Int.toFloat I})}
            else
                C:= @C + 2.0*{F (A+H*{Int.toFloat I})}
            end
            
        end
        C:= @C*(H/3.0)
    in
        @C
    end
end

% Test case
% Function that will be injected as parameter to the Integral function
declare
fun {Sqr A}
    local R = A*A
    in
        R
    end
end

local A B N
in
    A = 1.0
    B = 12.0
    N = 30
    {Browse {Integral Sqr A B N}}
end
