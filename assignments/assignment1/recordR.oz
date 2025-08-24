%% recordRelation
%% Input: Two records R1 and R2
%% Output: One of the atoms ’equal ’, ’equivalent ’, ’subsimilar ’, or ’different ’,
%% describing the relationship between the two records.

% **equal**: if their names, cardinality, and items all correspond to each other
% **equivalent**: if their names and cardinality correspond, but at least one of their items have different values -> Items = Arguments (?)
% **subsimilar**: if one of the records is contained in the other
% **different**: in any other case

declare 
fun {RecordRelation R1 R2}
    local Arity1 Arity2 Label1 Label2
        Arity1 = {Arity R1}
        Arity2 = {Arity R2}
        Label1 = {Label R1}
        Label2 = {Label R2}

    in 
        if R1 == R2 then
            equal
        elseif {Bool.'and' (Label1 == Label2) (Arity1 == Arity2)} then
            equivalent
        elseif {All Arity1 fun {$ Feature} {HasFeature R2 Feature} andthen R1.Feature == R2.Feature end} then
            subsimilar
        elseif {All Arity2 fun {$ Feature} {HasFeature R1 Feature} andthen R1.Feature == R2.Feature end} then
            subsimilar
        else
            different
        end
    end
end


% Test case
R1 = record1(a:1)
R2 = record1(a:1 2:0)
{Browse {RecordRelation R1 R2}}
