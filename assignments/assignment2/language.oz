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
  % num_to_string can be extended as needed. It was built from 0 to 9 for explanatory purposes.
  meth init(Val)
    n := Val
  end
  meth print
    {System.showInfo @n}
  end
  meth eval(R)
    R = @n
  end
  meth toString
    local Map PrintStatement in
        Map = number_dict(0:"zero" 1:"one" 2:"two" 3:"three" 4:"four" 5:"five" 6:"six" 7:"seven" 8:"eight" 9:"nine")
        {CondSelect Map @n "number out of range" PrintStatement}
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

local N1 N2 Sum1 EvalSum1 Diff1 EvalDiff1 Mult1 EvalMult1 Mod1 EvalMod1 in
  % Num
  {System.showInfo "Test Num print"}
  N1 = {New Num init(5)}
  N2 = {New Num init(3)}
  {N1 print} % prints 5
  {N2 print} % prints 3

  {System.showInfo "\nTest Num toString"}
  {N1 toString} % prints five
  {N2 toString} % prints three
  N_out_of_range = {New Num init(29)}
  {N_out_of_range toString} % prints "number out of range"

  % Sum
  {System.showInfo "\nTest Sum print"}
  Sum1 = {New Sum init(N1 N2)}
  {Sum1 print} % prints 5+3

  {System.showInfo "\nTest Sum toString"}
  {Sum1 toString} % prints "five plus three"

  {System.showInfo "\nTest Sum eval"}
  {Sum1 eval(EvalSum1)}
  {System.showInfo EvalSum1} % prints 8

  % Difference
  {System.showInfo "\nTest Difference print"}
  Diff1 = {New Difference init(N1 N2)}
  {Diff1 print} % prints 5-3

  {System.showInfo "\nTest Difference toString"}
  {Diff1 toString} % prints "five minus three"

  {System.showInfo "\nTest Difference eval"}
  {Diff1 eval(EvalDiff1)}
  {System.showInfo EvalDiff1} % prints 2

  
  % Multiplication
  {System.showInfo "\nTest Multiplication print"}
  Mult1 = {New Multiplication init(N1 {New Num init(2)})}
  {Mult1 print} % prints 5*2

  {System.showInfo "\nTest Multiplication toString"}
  {Mult1 toString} % prints "five times two"

  {System.showInfo "\nTest Multiplication eval"}
  {Mult1 eval(EvalMult1)}
  {System.showInfo EvalMult1} % prints 10

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

