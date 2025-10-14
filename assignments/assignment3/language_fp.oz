%% Preguntas
% 1. Se puede pasar exp en ExpPrint?
% 2. Se puede usar dict con numeros para number to string?
%% ============================================================================
%% ExpPrint : Expression -> String
%% Prints an expression in mathematical notation
%% ============================================================================
declare ExpPrint

proc {ExpPrint Exp}
   case Exp
   of num(I) then
      {System.showInfo I}
   [] sum(Left Right) then
      {ExpPrint Left}
      {System.showInfo "+"}
      {ExpPrint Right}
   [] difference(Left Right) then
      {ExpPrint Left}
      {System.showInfo "-"}
      {ExpPrint Right}
   [] multiplication(Left Right) then
      {ExpPrint Left}
      {System.showInfo "*"}
      {ExpPrint Right}
   [] modulo(Left Right) then
      {ExpPrint Left}
      {System.showInfo "mod"}
      {ExpPrint Right}
   end
end

%% ============================================================================
%% Eval : Expression -> Int
%% ============================================================================
declare Eval

fun {Eval Exp}
   case Exp
   of num(I) then
      I
   [] sum(Left Right) then
      {Eval Left} + {Eval Right}
   [] difference(Left Right) then
      {Eval Left} - {Eval Right}
   [] multiplication(Left Right) then
      {Eval Left} * {Eval Right}
   [] modulo(Left Right) then
      {Eval Left} mod {Eval Right}
   end
end

%% ============================================================================
%% Helper functions for number-to-string conversion
%% ============================================================================
declare NumberToStringLess100

fun {NumberToStringLess100 N}
   local Units Tens Unique in
      Units = unit(0:"zero" 1:"one" 2:"two" 3:"three" 4:"four" 5:"five" 
                   6:"six" 7:"seven" 8:"eight" 9:"nine")
      Tens = unit(10:"ten" 20:"twenty" 30:"thirty" 40:"forty" 50:"fifty" 
                  60:"sixty" 70:"seventy" 80:"eighty" 90:"ninety")
      Unique = unit(11:"eleven" 12:"twelve" 13:"thirteen" 14:"fourteen" 
                    15:"fifteen" 16:"sixteen" 17:"seventeen" 18:"eighteen" 19:"nineteen")
      
      if N < 10 then
         Units.N
      elseif N == 10 then
         Tens.10
      elseif N < 20 then
         Unique.N
      elseif N < 100 then
         local TensPart UnitsPart in
            TensPart = (N div 10) * 10
            UnitsPart = N mod 10
            if UnitsPart == 0 then
               Tens.TensPart
            else
               Tens.TensPart # "-" # Units.UnitsPart
            end
         end
      else
         "number out of range"
      end
   end
end

declare NumberToString

fun {NumberToString N}
   local Units in
      Units = unit(0:"zero" 1:"one" 2:"two" 3:"three" 4:"four" 5:"five" 
                   6:"six" 7:"seven" 8:"eight" 9:"nine")
      
      if N < 100 then
         {NumberToStringLess100 N}
      elseif N < 1000 then
         local HundredsPart RemainderPart HundredsString in
            HundredsPart = N div 100
            RemainderPart = N mod 100
            HundredsString = Units.HundredsPart
            
            if RemainderPart == 0 then
               HundredsString # " hundred"
            else
               HundredsString # " hundred and " # {NumberToStringLess100 RemainderPart}
            end
         end
      else
         "number out of range"
      end
   end
end

%% ============================================================================
%% ToString : Expression -> String
%% Converts an expression to its string representation
%% ============================================================================
declare ToString

fun {ToString Exp}
   case Exp
   of num(I) then
      {NumberToString I}
   [] sum(Left Right) then
      {ToString Left} # " plus " # {ToString Right}
   [] difference(Left Right) then
      {ToString Left} # " minus " # {ToString Right}
   [] multiplication(Left Right) then
      {ToString Left} # " times " # {ToString Right}
   [] modulo(Left Right) then
      {ToString Left} # " modulo " # {ToString Right}
   end
end

%% ============================================================================
%% Test Cases
%% ============================================================================

{System.showInfo "\n=== TEST: ExpPrint ==="}
local E1 E2 E3 E4 E5 in
   E1 = num(10)
   E2 = num(7)
   E3 = sum(E1 E2)
   E4 = difference(E1 E2)
   E5 = multiplication(E1 num(15))
   E6 = modulo(E1 num(3))
   
   {System.showInfo "Print num(10):"}
   {ExpPrint E1}
   
   {System.showInfo "\nPrint sum(10, 7):"}
   {ExpPrint E3}
   
   {System.showInfo "\nPrint difference(10, 7):"}
   {ExpPrint E4}
   
   {System.showInfo "\nPrint multiplication(10, 15):"}
   {ExpPrint E5}
   {System.showInfo "\nPrint modulo(10, 3):"}
   {ExpPrint E6}
end

{System.showInfo "\n=== TEST: Eval ==="}
local E1 E2 E3 E4 E5 in
   E1 = sum(num(10) num(7))
   E2 = difference(num(10) num(7))
   E3 = multiplication(num(10) num(15))
   E4 = modulo(num(10) num(3))
   E5 = sum(num(5) multiplication(num(3) num(4)))
   
   {System.showInfo "Eval sum(10, 7): " # {Eval E1}}           % 17
   {System.showInfo "Eval difference(10, 7): " # {Eval E2}}     % 3
   {System.showInfo "Eval multiplication(10, 15): " # {Eval E3}} % 150
   {System.showInfo "Eval modulo(10, 3): " # {Eval E4}}         % 1
   {System.showInfo "Eval 5 + (3 * 4): " # {Eval E5}}           % 17
end

{System.showInfo "\n=== TEST: ToString ==="}
local E1 E2 E3 E4 E5 E6 E7 E8 E9 E10 in
   E1 = num(0)
   E2 = num(10)
   E3 = num(17)
   E4 = num(49)
   E5 = num(100)
   E6 = num(289)
   E7 = num(999)
   E8 = sum(num(10) num(7))
   E9 = difference(num(10) num(7))
   E10 = multiplication(num(10) num(15))
   
   {System.showInfo "ToString num(0): " # {ToString E1}}
   {System.showInfo "ToString num(10): " # {ToString E2}}
   {System.showInfo "ToString num(17): " # {ToString E3}}
   {System.showInfo "ToString num(49): " # {ToString E4}}
   {System.showInfo "ToString num(100): " # {ToString E5}}
   {System.showInfo "ToString num(289): " # {ToString E6}}
   {System.showInfo "ToString num(999): " # {ToString E7}}
   {System.showInfo "ToString sum(10, 7): " # {ToString E8}}
   {System.showInfo "ToString difference(10, 7): " # {ToString E9}}
   {System.showInfo "ToString multiplication(10, 15): " # {ToString E10}}
end