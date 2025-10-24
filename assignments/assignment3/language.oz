declare

% Helper function to convert numbers to strings
fun {NumberToString N}
   local 
      Units = unit(0:"zero" 1:"one" 2:"two" 3:"three" 4:"four" 5:"five" 6:"six" 7:"seven" 8:"eight" 9:"nine")
      Tens = unit(10:"ten" 20:"twenty" 30:"thirty" 40:"forty" 50:"fifty" 60:"sixty" 70:"seventy" 80:"eighty" 90:"ninety")
      Unique = unit(11:"eleven" 12:"twelve" 13:"thirteen" 14:"fourteen" 15:"fifteen" 16:"sixteen" 17:"seventeen" 18:"eighteen" 19:"nineteen")
      
      fun {ToStringLess100 Num}
         if Num < 10 then
            Units.Num
         elseif Num == 10 then
            Tens.10
         elseif Num < 20 then
            Unique.Num
         elseif Num < 100 then
            local TensPart UnitsPart in
               TensPart = (Num div 10) * 10
               UnitsPart = Num mod 10
               if UnitsPart == 0 then
                  Tens.TensPart
               else
                  Tens.TensPart # " " # Units.UnitsPart
               end
            end
         else
            "number out of range"
         end
      end
   in
      if N < 100 then
         {ToStringLess100 N}
      elseif N < 1000 then
         local HundredsPart RemainderPart in
            HundredsPart = N div 100
            RemainderPart = N mod 100
            if RemainderPart == 0 then
               Units.HundredsPart # " hundred"
            else
               Units.HundredsPart # " hundred " # {ToStringLess100 RemainderPart}
            end
         end
      else
         "number out of range"
      end
   end
end

%----------- Generic Expression functions -----------

% ExpPrint: dispatches based on expression type
proc {ExpPrint Exp}
   case Exp
   of sum(Left Right) then
      {System.showInfo {Eval Left}#" + "#{Eval Right}}
   [] dif(Left Right) then
      {System.showInfo {Eval Left}#" - "#{Eval Right}}
   [] multi(Left Right) then
      {System.showInfo {Eval Left}#" * "#{Eval Right}}
   [] modulo(Left Right) then
      {System.showInfo {Eval Left}#" mod "#{Eval Right}}
   else
      {Show Exp}
   end
end

% Eval: evaluates expressions recursively
fun {Eval Exp}
   case Exp
   of sum(Left Right) then
      {Eval Left} + {Eval Right}
   [] dif(Left Right) then
      {Eval Left} - {Eval Right}
   [] multi(Left Right) then
      {Eval Left} * {Eval Right}
   [] modulo(Left Right) then
      {Eval Left} mod {Eval Right}
   else
      Exp
   end
end

% ToString: converts expressions to string representation
fun {ToString Exp}
   case Exp
   of sum(Left Right) then
      {ToString Left} # " plus " # {ToString Right}
   [] dif(Left Right) then
      {ToString Left} # " minus " # {ToString Right}
   [] multi(Left Right) then
      {ToString Left} # " times " # {ToString Right}
   [] modulo(Left Right) then
      {ToString Left} # " modulo " # {ToString Right}
   else
      {NumberToString Exp}  % base case: it's a number
   end
end

%---------------------------------------
% Tests
{System.showInfo "----------NUM TESTS-----"}
{System.show {Eval 5}}
{ExpPrint 5}
{System.showInfo {ToString 5}}
{System.showInfo {ToString 152}}
{System.showInfo {ToString 999}}

{System.showInfo "----------SUM TESTS-----"}
{System.show {Eval sum(5 8)}}
{ExpPrint sum(5 8)}
{System.showInfo {ToString sum(5 8)}}

{System.showInfo "----------DIFFERENCE TESTS-----"}
{System.show {Eval dif(8 2)}}
{ExpPrint dif(8 2)}
{System.showInfo {ToString dif(8 2)}}

{System.showInfo "----------MULTIPLICATION TESTS-----"}
{System.show {Eval multi(14 3)}}
{ExpPrint multi(14 3)}
{System.showInfo {ToString multi(14 3)}}

{System.showInfo "----------MODULO TESTS-----"}
{System.show {Eval modulo(10 3)}}
{ExpPrint modulo(10 3)}
{System.showInfo {ToString modulo(10 3)}}

{System.showInfo "----------COMPLEX EXPRESSION TESTS-----"}
{System.show {Eval sum(152 221)}}
{System.showInfo {ToString sum(152 221)}}

{System.show {Eval dif(934 883)}}
{System.showInfo {ToString dif(934 883)}}

{System.show {Eval multi(5 4)}}
{System.showInfo {ToString multi(5 4)}}

{System.show {Eval modulo(10 2)}}
{System.showInfo {ToString modulo(10 2)}}

{System.showInfo "----------NESTED EXPRESSION TESTS-----"}
{System.show {Eval sum(multi(2 3) dif(10 5))}}  % (2*3) + (10-5) = 11
{System.showInfo {ToString sum(multi(2 3) dif(10 5))}}

{System.show {Eval modulo(sum(7 8) multi(2 3))}}  % (7+8) mod (2*3) = 15 mod 6 = 3
{System.showInfo {ToString modulo(sum(7 8) multi(2 3))}}