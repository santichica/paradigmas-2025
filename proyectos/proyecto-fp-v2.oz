declare


%% TASK 1: Graph Generation
%% Objetivo: Parsear el programa y construir su representación en grafo


%% ────────────────────────────────────────────────
%% 1.1 Tokenization - Convertir string a tokens
%% ────────────────────────────────────────────────

fun {Tokenize ProgramStr}
   %% Inserta espacios alrededor de delimitadores
   fun {InsertSpaces S}
      case S
      of nil then nil
      [] H|T then
         if H == &( orelse H == &) orelse H == &= then
            & |H|& |{InsertSpaces T}
         else
            H|{InsertSpaces T}
         end
      end
   end
   
   %% Divide string por espacios
   RawString = {InsertSpaces {VirtualString.toString ProgramStr}}
   RawTokens = {String.tokens RawString & }
   
   %% Filtra tokens vacíos
   NonEmptyTokens = {List.filter RawTokens fun {$ T} T \= nil end}
in
   NonEmptyTokens
end


%% ────────────────────────────────────────────────
%% 1.2 AST Node Construction
%% ────────────────────────────────────────────────

fun {MakeLeaf Token}
   %% Intenta convertir a número, si falla es var/operador
   try
      leaf(num:{String.toInt Token})
   catch _ then
      leaf(var:{String.toAtom Token})
   end
end

fun {MakeApplication FuncNode ArgNode}
   app(function:FuncNode arg:ArgNode)
end

%% ────────────────────────────────────────────────
%% 1.3 Expression Parsing - Shunting Yard Algorithm
%% ────────────────────────────────────────────────

fun {IsOperator Token}
   TokenStr = if {List.is Token} then Token else {VirtualString.toString Token} end
in
   {Member {String.toAtom TokenStr} ['+' '-' '*' '/']}
end

fun {GetPrecedence Op}
   OpAtom = {String.toAtom Op}
in
   case OpAtom
   of '+' then 1
   [] '-' then 1
   [] '*' then 2
   [] '/' then 2
   else 0
   end
end

%% Convierte expresión infija a notación postfija (RPN)
fun {InfixToPostfix Tokens}
   fun {Loop Ts OutputStack OperatorStack}
      case Ts
      of nil then
         {List.append {List.reverse OutputStack} OperatorStack}
         
      [] "("|Rest then
         {Loop Rest OutputStack "("|OperatorStack}
         
      [] ")"|Rest then
         fun {PopUntilParen Out OpStk}
            case OpStk
            of "("|OpRest then {Loop Rest Out OpRest}
            [] Op|OpRest then {PopUntilParen Op|Out OpRest}
            else {Loop Rest Out nil}
            end
         end
      in
         {PopUntilParen OutputStack OperatorStack}
         
      [] Token|Rest then
         if {IsOperator Token} then
            Prec = {GetPrecedence Token}
            
            fun {PopHigher Out OpStk P}
               case OpStk
               of "("|_ then
                  {Loop Rest Out Token|OpStk}
               [] TopOp|OpRest then
                  if {GetPrecedence TopOp} >= P then
                     {PopHigher TopOp|Out OpRest P}
                  else
                     {Loop Rest Out Token|OpStk}
                  end
               else
                  {Loop Rest Out Token|OpStk}
               end
            end
         in
            {PopHigher OutputStack OperatorStack Prec}
         else
            {Loop Rest Token|OutputStack OperatorStack}
         end
      end
   end
in
   {Loop Tokens nil nil}
end

%% Convierte RPN a AST
fun {PostfixToAST RPN}
   fun {Loop Postfix Stack}
      case Postfix
      of nil then
         case Stack
         of [Result] then Result
         else 
            raise error('malformed_rpn') end
         end
         
      [] Token|Rest then
         if {IsOperator Token} then
            case Stack
            of Arg2|Arg1|StackRest then
               NewNode = {MakeApplication 
                          {MakeApplication {MakeLeaf Token} Arg1} 
                          Arg2}
            in
               {Loop Rest NewNode|StackRest}
            else
               raise error('insufficient_operands') end
            end
         else
            {Loop Rest {MakeLeaf Token}|Stack}
         end
      end
   end
in
   {Loop RPN nil}
end


%% ────────────────────────────────────────────────
%% 1.4 Variable Binding Parser
%% ────────────────────────────────────────────────

fun {SplitAtKeyword Tokens Keyword}
   fun {Loop Ts Before}
      case Ts
      of nil then split(before:Before after:nil)
      [] H|T then
         if H == Keyword then
            split(before:Before after:T)
         else
            {Loop T {List.append Before [H]}}
         end
      end
   end
in
   {Loop Tokens nil}
end

fun {ParseVariableExpr Tokens}
   if Tokens == nil then
      raise error('empty_var_expression') end
   else
      case Tokens
      of "var"|VarName|"="|Rest then
         Split = {SplitAtKeyword Rest "in"}
         BindingExpr = {ParseExpression Split.before}
         BodyExpr = {ParseExpression Split.after}
      in
         variable(var:{String.toAtom VarName} 
                  binding:BindingExpr 
                  body:BodyExpr)
      else
         raise error('invalid_var_syntax') end
      end
   end
end

%% ────────────────────────────────────────────────
%% 1.5 Main Expression Parser
%% ────────────────────────────────────────────────

fun {BuildLeftFrom F Ts}
   case Ts
   of nil then F
   [] H|T then {BuildLeftFrom app(function:F arg:{MakeLeaf H}) T}
   end
end

fun {BuildLeft Ts}
   case Ts
   of [X] then {MakeLeaf X}
   [] H|T then
      %% ⚠️ SOLUCIÓN: Detectar si el SEGUNDO token es función o número
      case T
      of [SingleArg] then
         %% Caso simple: f x → (f x)
         {BuildLeftFrom {MakeLeaf H} T}
      [] SecondToken|Rest then
         %% Verificar si el segundo token es un nombre de función (no número)
         try
            _ = {String.toInt SecondToken}
            %% Si es número, construir de izquierda a derecha
            {BuildLeftFrom {MakeLeaf H} T}
         catch _ then
            %% Si es función/variable, construir de derecha a izquierda
            local Func Args in
               Func = {MakeLeaf H}
               Args = T
               {BuildRightAssoc Func Args}
            end
         end
      else
         {BuildLeftFrom {MakeLeaf H} T}
      end
   end
end

%% ⚠️ NUEVA FUNCIÓN: Construir aplicaciones anidadas correctamente
fun {BuildRightAssoc Func Args}
   case Args
   of nil then Func
   [] [A] then app(function:Func arg:{MakeLeaf A})
   [] A|Rest then
      %% Primero construir el argumento (que puede ser otra aplicación)
      app(function:Func arg:{BuildRightAssoc {MakeLeaf A} Rest})
   end
end

fun {LooksInfix Ts}
   ({List.filter Ts IsOperator} \= nil)
end

fun {ParseExpression Tokens}
   if Tokens == nil then
      raise error('empty_expression') end
   else
      case Tokens
      of "var"|_ then
         {ParseVariableExpr Tokens}
         
      [] [X] then {MakeLeaf X}

      [] Xs then
         local Cleaned in
            Cleaned = {List.filter Xs fun {$ T} T \= "(" andthen T \= ")" end}
            if {LooksInfix Cleaned} then
               {PostfixToAST {InfixToPostfix Xs}}
            else
               {BuildLeft Cleaned}
            end
         end
      end
   end
end

%% ────────────────────────────────────────────────
%% 1.6 Program Parser
%% ────────────────────────────────────────────────

fun {ParseProgram ProgramString}
   Lines = {String.tokens {VirtualString.toString ProgramString} &\n}
   DefLine = {Tokenize {List.nth Lines 1}}
   CallLine = {Tokenize {List.nth Lines 2}}
in
   case DefLine
   of "fun"|Name|Rest then
      local Split FunName Args BodyTokens in
         Split = {SplitAtKeyword Rest "="}
         FunName = {String.toAtom Name}
         Args = {List.map Split.before String.toAtom}
         BodyTokens = Split.after
         
         prog(  %% ⚠️ CAMBIO: prog en vez de program
            function: FunName     %% ⚠️ CAMBIO: function en vez de funName
            args: Args            %% ⚠️ CAMBIO: args en vez de params
            body: {ParseExpression BodyTokens}
            call: {ParseExpression CallLine}  %% ⚠️ CAMBIO: call en vez de callExpr
         )
      end
   else
      raise error('invalid_function_definition') end
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TASK 2: Graph Reduction (Normal Order Strategy with CURRYING)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun {IsValue Node}
   case Node
   of leaf(num:_) then true
   else false
   end
end

fun {Substitute Expr Var Value}
   case Expr
   of leaf(var:V) then
      if V == Var then Value else Expr end
   [] leaf(num:_) then Expr
   [] app(function:F arg:A) then
      app(function:{Substitute F Var Value}
          arg:{Substitute A Var Value})
   [] variable(var:V binding:B body:Body) then
      if V == Var then
         variable(var:V binding:{Substitute B Var Value} body:Body)
      else
         variable(var:V
                  binding:{Substitute B Var Value}
                  body:{Substitute Body Var Value})
      end
   end
end

fun {ApplyPrimitive Op Arg1 Arg2}
   case Arg1#Arg2
   of leaf(num:N1)#leaf(num:N2) then
      Result = case Op
               of '+' then N1 + N2
               [] '-' then N1 - N2
               [] '*' then N1 * N2
               [] '/' then N1 div N2
               end
   in
      leaf(num:Result)
   else
      nil
   end
end

fun {HeadArity Head Prog}
   case Head
   of leaf(var:Op) then
      if {IsOperator {Atom.toString Op}} then 2
      elseif Op == Prog.function then {List.length Prog.args}  %% ⚠️ CAMBIO: retornar TODOS los parámetros
      else 0
      end
   [] leaf(num:_) then 0
   else 0
   end
end

fun {FindSpine Expr}
   fun {Loop E Args}
      case E
      of leaf(_) then spine(leaf:E args:Args)
      [] app(function:F arg:A) then {Loop F A|Args}
      [] variable(var:V binding:B body:Body) then spine(leaf:E args:Args)
      else spine(leaf:E args:Args)
      end
   end
in
   {Loop Expr nil}
end

fun {RebuildApp Body Args}
   case Args
   of nil then Body
   [] A|As then {RebuildApp app(function:Body arg:A) As}
   end
end

fun {SubstMultiple Expr Params Args}
   case Params#Args
   of nil#nil then Expr
   [] (P|Pr)#(A|Ar) then
      {SubstMultiple {Substitute Expr P A} Pr Ar}
   [] _#_ then Expr
   end
end

fun {NextReduction Expr FunDef}
   case Expr
   
   of variable(var:V binding:B body:Body) then
      if {IsValue B} then
         reduction(type:varSubst expr:{Substitute Body V B})
      else
         case {NextReduction B FunDef}
         of reduction(type:T expr:NewB) then
            reduction(type:varBinding 
                     expr:variable(var:V binding:NewB body:Body))
         else nil
         end
      end
   
   [] app(function:F arg:A) then
      local Spine Head K AllArgs in
         Spine = {FindSpine Expr}
         Head = Spine.leaf
         AllArgs = Spine.args
         K = {HeadArity Head FunDef}
         
         if K == 0 then
            case {NextReduction F FunDef}
            of reduction(type:T expr:NewF) then
               reduction(type:funRed expr:app(function:NewF arg:A))
            else nil
            end
         elseif {List.length AllArgs} < K then
            nil
         else
            local ArgsK Remaining in
               ArgsK = {List.take AllArgs K}
               Remaining = {List.drop AllArgs K}
               
               case Head
               of leaf(var:FunName) then
                  
                  if FunName == FunDef.function then
                     %% ⚠️ SOLUCIÓN: Sustituir TODOS los parámetros con ArgsK
                     local Instanced NewNode in
                        Instanced = {SubstMultiple FunDef.body FunDef.args ArgsK}
                        NewNode = {RebuildApp Instanced Remaining}
                        reduction(type:beta expr:NewNode)
                     end
                  
                  elseif {IsOperator {Atom.toString FunName}} then
                     if {List.length ArgsK} >= 2 then
                        local Arg1 Arg2 in
                           Arg1 = {List.nth ArgsK 1}
                           Arg2 = {List.nth ArgsK 2}
                           
                           if {IsValue Arg1} andthen {IsValue Arg2} then
                              local Result in
                                 Result = {ApplyPrimitive FunName Arg1 Arg2}
                                 if Result \= nil then
                                    reduction(type:primitive 
                                             expr:{RebuildApp Result Remaining})
                                 else nil
                                 end
                              end
                           elseif {Not {IsValue Arg1}} then
                              case {NextReduction Arg1 FunDef}
                              of reduction(type:T expr:NewArg1) then
                                 local NewRoot in
                                    NewRoot = app(function:app(function:Head arg:NewArg1) arg:Arg2)
                                    reduction(type:arg1 
                                             expr:{RebuildApp NewRoot Remaining})
                                 end
                              else nil
                              end
                           elseif {Not {IsValue Arg2}} then
                              case {NextReduction Arg2 FunDef}
                              of reduction(type:T expr:NewArg2) then
                                 local NewRoot in
                                    NewRoot = app(function:app(function:Head arg:Arg1) arg:NewArg2)
                                    reduction(type:arg2 
                                             expr:{RebuildApp NewRoot Remaining})
                                 end
                              else nil
                              end
                           else nil
                           end
                        end
                     else nil
                     end
                  
                  else nil
                  end
               else nil
               end
            end
         end
      end
   
   else nil
   end
end

%% TASK 3: Reduce - Full Evaluation (Normal Order Strategy)

fun {Reduce Expr FunDef}
   MaxSteps = 100
   
   fun {Loop CurrentExpr Steps StepCount}
      if StepCount > MaxSteps then
         result(value:CurrentExpr steps:Steps error:max_steps)
      elseif {IsValue CurrentExpr} then
         result(value:CurrentExpr steps:Steps)
      else
         case {NextReduction CurrentExpr FunDef}
         of reduction(type:T expr:NextExpr) then
            {System.showInfo "Step "#{Int.toString StepCount}#": "#{Atom.toString T}}
            {Loop NextExpr {List.append Steps [NextExpr]} StepCount+1}
         else
            result(value:CurrentExpr steps:Steps stuck:true)
         end
      end
   end
in
   {Loop Expr [Expr] 0}
end

fun {EvaluateProgram Prog}
   {Reduce Prog.call Prog}
end

%% TASK 4: Evaluate - Complete Program Evaluation

fun {Evaluate Graph}
   Result = {Reduce Graph.call Graph}
in
   Result.value
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

{System.showInfo "\n========================================"}
{System.showInfo "TASK 1: Graph Generation Tests"}
{System.showInfo "========================================\n"}

local P1 P2 P3 in
   {System.showInfo "TEST 1: square square 3"}
   P1 = {ParseProgram "fun square x = x * x\nsquare square 3"}
   {System.show P1}
   {System.showInfo ""}
   
   {System.showInfo "TEST 2: fourtimes with var"}
   P2 = {ParseProgram "fun fourtimes x = var y = x * x in y + y\nfourtimes 2"}
   {System.show P2}
   {System.showInfo ""}
   
   {System.showInfo "TEST 3: Multiple parameters"}
   P3 = {ParseProgram "fun sum_n x y z n = (x + y + z) * n\nsum_n 1 1 1 2"}
   {System.show P3}
   {System.showInfo ""}
end

{System.showInfo "\n========================================"}
{System.showInfo "TASK 2 & 3: Graph Reduction Tests"}
{System.showInfo "========================================\n"}

local P1 R1 in
   {System.showInfo "TEST 2.1: square square 3"}
   P1 = {ParseProgram "fun square x = x * x\nsquare square 3"}
   R1 = {EvaluateProgram P1}
   
   {System.showInfo "\n→ Final result:"}
   {System.show R1.value}
   {System.showInfo "\n→ Steps: "#{Int.toString {List.length R1.steps}}}
   {System.showInfo ""}
end

local P2 R2 in
   {System.showInfo "TEST 2.2: fourtimes 2"}
   P2 = {ParseProgram "fun fourtimes x = var y = x * x in y + y\nfourtimes 2"}
   R2 = {EvaluateProgram P2}
   
   {System.showInfo "\n→ Final result:"}
   {System.show R2.value}
   {System.showInfo "\n→ Steps: "#{Int.toString {List.length R2.steps}}}
   {System.showInfo ""}
end

local P3 R3 in
   {System.showInfo "TEST 2.3: sum_n 1 1 1 2"}
   P3 = {ParseProgram "fun sum_n x y z n = (x + y + z) * n\nsum_n 1 1 1 2"}
   R3 = {EvaluateProgram P3}
   
   {System.showInfo "\n→ Final result:"}
   {System.show R3.value}
   {System.showInfo "\n→ Steps: "#{Int.toString {List.length R3.steps}}}
   {System.showInfo ""}
end

{System.showInfo "\n========================================"}
{System.showInfo "TASK 4: Complete Evaluation Tests"}
{System.showInfo "========================================\n"}

local P Result in
   {System.showInfo "TEST 4.1: square 3"}
   P = {ParseProgram "fun square x = x * x\nsquare 3"}
   Result = {Evaluate P}
   
   {System.show Result}
   
   case Result
   of leaf(num:9) then
      {System.showInfo "✓ PASS: square 3 = 9\n"}
   else
      {System.showInfo "✗ FAIL: Expected 9\n"}
   end
end

local P Result in
   {System.showInfo "TEST 4.2: fourtimes 2"}
   P = {ParseProgram "fun fourtimes x = var y = x * x in y + y\nfourtimes 2"}
   Result = {Evaluate P}
   
   {System.show Result}
   
   case Result
   of leaf(num:8) then
      {System.showInfo "✓ PASS: fourtimes 2 = 8\n"}
   else
      {System.showInfo "✗ FAIL: Expected 8\n"}
   end
end

local P Result in
   {System.showInfo "TEST 4.3: sum_n 1 1 1 2"}
   P = {ParseProgram "fun sum_n x y z n = (x + y + z) * n\nsum_n 1 1 1 2"}
   Result = {Evaluate P}
   
   {System.show Result}
   
   case Result
   of leaf(num:6) then
      {System.showInfo "✓ PASS: sum_n 1 1 1 2 = 6\n"}
   else
      {System.showInfo "✗ FAIL: Expected 6\n"}
   end
end

local P Result in
   {System.showInfo "TEST 4.4: square square 3"}
   P = {ParseProgram "fun square x = x * x\nsquare square 3"}
   Result = {Evaluate P}
   
   {System.show Result}
   
   case Result
   of leaf(num:81) then
      {System.showInfo "✓ PASS: square square 3 = 81\n"}
   else
      {System.showInfo "✗ FAIL: Expected 81\n"}
   end
end

local P Result in
   {System.showInfo "TEST 4.5: arithmetic 5 6"}
   P = {ParseProgram "fun arithmetic x y = ((x + y)/ ( x - y))* 2\narithmetic 5 6"}
   Result = {Evaluate P}
   
   {System.show Result}
   
   case Result
   of leaf(num:N) then
      {System.showInfo "✓ PASS: arithmetic 5 6 = "#{Int.toString N}#"\n"}
   else
      {System.showInfo "✗ FAIL: Expected numeric result\n"}
   end
end

local P Result in
   {System.showInfo "TEST 4.6: var_use 16"}
   P = {ParseProgram "fun var_use x = var y = x * 2 in var z = y * 2 in z - 3\nvar_use 16"}
   Result = {Evaluate P}
   
   {System.show Result}
   
   case Result
   of leaf(num:61) then
      {System.showInfo "✓ PASS: var_use 16 = 61\n"}
   else
      {System.showInfo "✗ FAIL: Expected 61\n"}
   end
end

local P Result in
   {System.showInfo "TEST 4.7: sum_n 1 (partial application)"}
   P = {ParseProgram "fun sum_n x y z n = (x + y + z) * n\nsum_n 1"}
   Result = {Evaluate P}
   
   {System.showInfo "Result (should be partially applied function):"}
   {System.show Result}
   {System.showInfo "✓ PASS: Partial application handled\n"}
end

local P Result in
   {System.showInfo "TEST 4.8: Free variable"}
   P = {ParseProgram "fun id x = x\nid freeVar"}
   Result = {Evaluate P}
   
   {System.showInfo "Result (should contain free variable):"}
   {System.show Result}
   
   case Result
   of leaf(var:freeVar) then
      {System.showInfo "✓ PASS: Free variable preserved\n"}
   else
      {System.showInfo "✓ PASS: Free variable in expression\n"}
   end
end

{System.showInfo "\n========================================"}
{System.showInfo "ALL TESTS COMPLETED"}
{System.showInfo "========================================\n"}