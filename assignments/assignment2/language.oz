declare
class Expression
  meth print
    {System.showInfo "Base method does nothing"}
  end
  meth eval(R)
    {System.showInfo "Base method does nothing"}
  end
  meth toString(R)
    {System.showInfo "Base method does nothing"}
  end
end

class Num from Expression
  attr n : 0
  meth init(Val)
    n := Val
  end
  meth print
    {System.showInfo @n}
  end
  meth eval(R)
    R = @n
  end
  meth toStringLess100(N ?PrintStatement)
    % Helper method to convert numbers less than 100 to words
    local Units Tens Unique in
      Units = number_dict(0:"zero" 1:"one" 2:"two" 3:"three" 4:"four" 5:"five" 6:"six" 7:"seven" 8:"eight" 9:"nine")
      Tens = number_dict(10:"ten" 20:"twenty" 30:"thirty" 40:"forty" 50:"fifty" 60:"sixty" 70:"seventy" 80:"eighty" 90:"ninety")
      Unique = number_dict(11:"eleven" 12:"twelve" 13:"thirteen" 14:"fourteen" 15:"fifteen" 16:"sixteen" 17:"seventeen" 18:"eighteen" 19:"nineteen")
      if N < 10 then
        {CondSelect Units N "number out of range" PrintStatement}
      elseif N < 20 then
        if N == 10 then
          {CondSelect Tens N "number out of range" PrintStatement}
        else
          {CondSelect Unique N "number out of range" PrintStatement}
        end
      elseif N < 100 then
        local TensPart UnitsPart in
          TensPart = (N div 10) * 10
          UnitsPart = N mod 10
          if UnitsPart == 0 then
            {CondSelect Tens TensPart "number out of range" PrintStatement}
          else
            local TensString UnitsString in
              {CondSelect Tens TensPart "number out of range" TensString}
              {CondSelect Units UnitsPart "number out of range" UnitsString}
              PrintStatement = TensString # "-" # UnitsString
            end
          end
        end
      else
        PrintStatement = "number out of range"
      end
    end
  end
  meth toString
    local Units Tens Unique PrintStatement in
      Units = number_dict(0:"zero" 1:"one" 2:"two" 3:"three" 4:"four" 5:"five" 6:"six" 7:"seven" 8:"eight" 9:"nine")
      Tens = number_dict(10:"ten" 20:"twenty" 30:"thirty" 40:"forty" 50:"fifty" 60:"sixty" 70:"seventy" 80:"eighty" 90:"ninety")
      Unique = number_dict(11:"eleven" 12:"twelve" 13:"thirteen" 14:"fourteen" 15:"fifteen" 16:"sixteen" 17:"seventeen" 18:"eighteen" 19:"nineteen")
      if @n < 100 then
        {self toStringLess100(@n PrintStatement)}
      elseif @n < 1000 then
        local HundredsPart RemainderPart in
          HundredsPart = @n div 100
          RemainderPart = @n mod 100
          if RemainderPart == 0 then
            local HundredsString in
              {CondSelect Units HundredsPart "number out of range" HundredsString}
              PrintStatement = HundredsString # " hundred"
            end
          else
            local HundredsString RemainderString in
              {CondSelect Units HundredsPart "number out of range" HundredsString}
              {self toStringLess100(RemainderPart RemainderString)}
              PrintStatement = HundredsString # " hundred and " # RemainderString
            end
          end
        end
      else
      PrintStatement = "number out of range"
      end
      {System.showInfo PrintStatement}
    end
  end
end

class Sum from Expression
  attr left right
  meth init(L R)
    left := L
    right := R
  end
  meth print
    {@left print}
    {System.showInfo "+"}
    {@right print}
  end
  meth eval(R)
    local LR RR in
      {@left eval(LR)}
      {@right eval(RR)}
      R = LR + RR
    end
  end
  meth toString
    {@left toString}
    {System.showInfo "plus"}
    {@right toString}
  end
end

class Difference from Expression
  attr left right
  meth init(L R)
    left := L
    right := R
  end
  meth print
    {@left print}
    {System.showInfo "-"}
    {@right print}
  end
  meth eval(R)
    local LR RR in
        {@left eval(LR)}
        {@right eval(RR)}
        R = LR - RR
    end
  end
  meth toString
    {@left toString}
    {System.showInfo "minus"}
    {@right toString}
  end
end

class Multiplication from Expression
  attr left right
  meth init(L R)
    left := L
    right := R
  end
  meth print
    {@left print}
    {System.showInfo "*"}
    {@right print}
  end
  meth eval(R)
    local LR RR in
      {@left eval(LR)}
      {@right eval(RR)}
      R = LR * RR
    end
  end
  meth toString
    {@left toString}
    {System.showInfo "times"}
    {@right toString}
  end
end

class Modulo from Expression
  attr left right
  meth init(L R)
    left := L
    right := R
  end
  meth print
    {@left print}
    {System.showInfo "mod"}
    {@right print}
  end
  meth eval(R)
    local LR RR in
      {@left eval(LR)}
      {@right eval(RR)}
      R = LR mod RR
    end
  end
  meth toString
    {@left toString}
    {System.showInfo "modulo"}
    {@right toString}
  end
end


% Example usage each class:

local N1 N2 N17 N49 N100 N289 N343 N440 N999 N1000 Sum1 EvalSum1 Diff1 EvalDiff1 Mult1 EvalMult1 Mod1 EvalMod1 in
  % Num
  {System.showInfo "Test Num print"}
  N1 = {New Num init(10)}
  N2 = {New Num init(7)}

  N17 = {New Num init(17)}
  N49 = {New Num init(49)}
  N100 = {New Num init(100)}
  N289 = {New Num init(289)}
  N343 = {New Num init(343)}
  N440 = {New Num init(440)}
  N999 = {New Num init(999)}
  N1000 = {New Num init(1000)}
  {N1 print} % prints 10
  {N2 print} % prints 7

  {System.showInfo "\nTest Num toString"}
  {N1 toString} % prints ten
  {N2 toString} % prints seven
  {N17 toString} % prints seventeen - unique case
  {N49 toString} % prints forty-nine - tens with units
  {N100 toString} % prints one hundred - exact hundred
  {N289 toString} % prints two hundred and eighty-nine - hundreds with tens and units
  {N343 toString} % prints three hundred and forty-three - hundreds with tens and units
  {N440 toString} % prints four hundred and forty - hundreds with tens
  {N999 toString} % prints nine hundred and ninety-nine - hundreds with tens and units
  {N1000 toString} % prints number out of range - out of range case

  % Sum
  {System.showInfo "\nTest Sum print"}
  Sum1 = {New Sum init(N1 N2)}
  {Sum1 print} % prints 10+7

  {System.showInfo "\nTest Sum toString"}
  {Sum1 toString} % prints "ten plus seven"

  {System.showInfo "\nTest Sum eval"}
  {Sum1 eval(EvalSum1)}
  {System.showInfo EvalSum1} % prints 17

  % Difference
  {System.showInfo "\nTest Difference print"}
  Diff1 = {New Difference init(N1 N2)}
  {Diff1 print} % prints 10-7

  {System.showInfo "\nTest Difference toString"}
  {Diff1 toString} % prints "ten minus seven"

  {System.showInfo "\nTest Difference eval"}
  {Diff1 eval(EvalDiff1)}
  {System.showInfo EvalDiff1} % prints 3

  
  % Multiplication
  {System.showInfo "\nTest Multiplication print"}
  Mult1 = {New Multiplication init(N1 {New Num init(15)})}
  {Mult1 print} % prints 10*15

  {System.showInfo "\nTest Multiplication toString"}
  {Mult1 toString} % prints "ten times fifteen"

  {System.showInfo "\nTest Multiplication eval"}
  {Mult1 eval(EvalMult1)}
  {System.showInfo EvalMult1} % prints 150

  % Modulo
  {System.showInfo "\nTest Modulo print"}
  Mod1 = {New Modulo init({New Num init(4)} {New Num init(2)})}
  {Mod1 print} % prints 4 mod 2

  {System.showInfo "\nTest Modulo toString"}
  {Mod1 toString} % prints "four modulo two"

  {System.showInfo "\nTest Modulo eval"}
  {Mod1 eval(EvalMod1)}
  {System.showInfo EvalMod1} % prints 0

end

