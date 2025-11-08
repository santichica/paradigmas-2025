declare

% Tipos de nodos en el grafo
% leaf(value: X) - nodo hoja (constante o variable)
% app(left: Node right: Node) - nodo de aplicación (@)
% funDef(params: [Atom] body: Node) - definición de función

% Built-in primitives
Primitives = primitives(
   '+': fun {$ X Y} X + Y end
   '-': fun {$ X Y} X - Y end
   '*': fun {$ X Y} X * Y end
   '/': fun {$ X Y} X div Y end
)

% Environment para almacenar definiciones de funciones
fun {NewEnv}
   {Dictionary.new}
end

proc {AddFun Env Name Params Body}
   {Dictionary.put Env Name funDef(params:Params body:Body)}
end

fun {GetFun Env Name}
   {Dictionary.get Env Name}
end

fun {HasFun Env Name}
   {Dictionary.member Env Name}
end

% Convierte una cadena en una lista de tokens
fun {Str2Lst Data}
   {String.tokens Data & }
end

% Genera el grafo desde un programa
fun {GraphGeneration Program}
   local Tokens Env in
      Tokens = {Str2Lst Program}
      Env = {NewEnv}
      {ParseProgram Tokens Env}
   end
end

% Parsea el programa completo (puede tener múltiples definiciones)
fun {ParseProgram Tokens Env}
   case Tokens
   of nil then
      result(env: Env mainExpr: nil)
   [] "fun"|Rest then
      local FunName RestTokens1 Params Body RestTokens2 MainExpr FunAtom in
         FunName|RestTokens1 = Rest
         FunAtom = {String.toAtom FunName}
         {ParseFunction RestTokens1 FunAtom Env Params Body RestTokens2}
         {AddFun Env FunAtom Params Body}
         MainExpr = {ParseProgram RestTokens2 Env}
         MainExpr
      end
   else
      % No hay más definiciones, el resto es la expresión principal
      local MainExpr RestTokens in
         MainExpr = {ParseExpression Tokens Env RestTokens}
         result(env: Env mainExpr: MainExpr)
      end
   end
end

% Parsea una definición de función
proc {ParseFunction Tokens FunName Env ?Params ?Body ?RestTokens}
   local RestTokens1 RestTokens2 in
      {ParseParams Tokens Params "=" RestTokens1}
      Body = {ParseBodyLimited RestTokens1 Env RestTokens2}
      RestTokens = RestTokens2
   end
end

% Parsea los parámetros de una función hasta encontrar "="
proc {ParseParams Tokens ?Params Sep ?RestTokens}
   case Tokens
   of H|T then
      if H == Sep then
         Params = nil
         RestTokens = T
      else
         local RestParams RestTokens1 in
            {ParseParams T RestParams Sep RestTokens1}
            Params = H|RestParams
            RestTokens = RestTokens1
         end
      end
   else
      Params = nil
      RestTokens = nil
   end
end

% Parsea el cuerpo de una función limitado (se detiene en "fun" o fin de tokens)
fun {ParseBodyLimited Tokens Env ?RestTokens}
   case Tokens
   of nil then
      RestTokens = nil
      leaf(value:nil)
   [] "var"|VarName|"="|Rest then
      % Expresión con variable local
      local VarExpr RestTokens1 in
         VarExpr = {ParseExpressionLimited Rest Env RestTokens1}
         case RestTokens1 
         of "in"|RestTokens2 then
            local BodyExpr RestTokens3 in
               BodyExpr = {ParseBodyLimited RestTokens2 Env RestTokens3}
               RestTokens = RestTokens3
               app(left: app(left: leaf(value:'var') 
                             right: leaf(value:{String.toAtom VarName}))
                   right: app(left: VarExpr right: BodyExpr))
            end
         else
            RestTokens = RestTokens1
            VarExpr
         end
      end
   [] "fun"|_ then
      RestTokens = Tokens
      leaf(value:nil)
   else
      {ParseExpressionLimited Tokens Env RestTokens}
   end
end

% Parsea una expresión limitada (se detiene en "fun")
fun {ParseExpressionLimited Tokens Env ?RestTokens}
   case Tokens
   of nil then 
      RestTokens = nil
      leaf(value:nil)
   [] "fun"|_ then
      RestTokens = Tokens
      leaf(value:nil)
   [] Op|Rest then
      if {IsPrimitive Op} then
         local Left Right Rest2 in
            Left = {ParseSingleExprLimitedAux Rest Env Rest2}
            Right = {ParseSingleExprLimitedAux Rest2 Env RestTokens}
            app(left: app(left: leaf(value:{String.toAtom Op})
                          right: Left)
                right: Right)
         end
      elseif {HasFun Env {String.toAtom Op}} then
         local Args in
            Args = {ParseFunctionArgsLimited Rest Env RestTokens}
            {BuildAppChain {String.toAtom Op} Args}
         end
      else
         RestTokens = Rest
         leaf(value:{String.toAtom Op})
      end
   end
end

% Convierte un string a número o átomo
fun {StringToValue Str}
   try
      {String.toInt Str}
   catch _ then
      {String.toAtom Str}
   end
end

% Parsea una expresión auxiliar limitada
fun {ParseSingleExprLimitedAux Tokens Env ?RestTokens}
   case Tokens
   of nil then
      RestTokens = nil
      leaf(value:nil)
   [] "fun"|_ then
      RestTokens = Tokens
      leaf(value:nil)
   [] H|T then
      case H
      of "(" then
         % Expresión entre paréntesis
         local Expr Rest2 in
            Expr = {ParseExpressionLimited T Env Rest2}
            case Rest2 of ")"|Rest3 then
               RestTokens = Rest3
               Expr
            else
               RestTokens = Rest2
               Expr
            end
         end
      else
         RestTokens = T
         % Intentar convertir a número, si falla usar átomo
         leaf(value:{StringToValue H})
      end
   end
end

% Parsea argumentos de función limitados
fun {ParseFunctionArgsLimited Tokens Env ?RestTokens}
   case Tokens
   of nil then 
      RestTokens = nil
      nil
   [] "fun"|_ then
      RestTokens = Tokens
      nil
   [] H|T then
      if H == ")" orelse H == "in" then
         RestTokens = Tokens
         nil
      else
         local Arg Rest2 RestArgs in
            Arg = {ParseSingleExprLimitedAux Tokens Env Rest2}
            RestArgs = {ParseFunctionArgsLimited Rest2 Env RestTokens}
            Arg|RestArgs
         end
      end
   end
end

% Parsea una expresión hasta encontrar un separador opcional
proc {ParseSingleExpr Tokens Env ?Expr ?Sep}
   Expr = {ParseSingleExprAux Tokens Env _}
   Sep = nil
end

% Parsea una expresión hasta encontrar un separador opcional
fun {ParseSingleExprAux Tokens Env ?RestTokens}
   case Tokens
   of nil then
      RestTokens = nil
      leaf(value:nil)
   [] H|T then
      case H
      of "(" then
         % Expresión entre paréntesis
         local Expr Rest2 in
            Expr = {ParseExpression T Env Rest2}
            case Rest2 of ")"|Rest3 then
               RestTokens = Rest3
               Expr
            else
               RestTokens = Rest2
               Expr
            end
         end
      else
         RestTokens = T
         % Intentar convertir a número, si falla usar átomo
         leaf(value:{StringToValue H})
      end
   end
end

% Parsea una expresión completa (con operadores)
fun {ParseExpression Tokens Env ?RestTokens}
   case Tokens
   of nil then 
      RestTokens = nil
      leaf(value:nil)
   [] Op|Rest then
      if {IsPrimitive Op} then
         local Left Right Rest2 in
            Left = {ParseSingleExprAux Rest Env Rest2}
            Right = {ParseSingleExprAux Rest2 Env RestTokens}
            app(left: app(left: leaf(value:{String.toAtom Op})
                          right: Left)
                right: Right)
         end
      elseif {HasFun Env {String.toAtom Op}} then
         local Args in
            Args = {ParseFunctionArgs Rest Env RestTokens}
            {BuildAppChain {String.toAtom Op} Args}
         end
      else
         RestTokens = Rest
         leaf(value:{String.toAtom Op})
      end
   end
end

% Verifica si es una primitiva
fun {IsPrimitive Op}
   {List.member Op ["+" "-" "*" "/"]}
end

% Parsea argumentos de función
fun {ParseFunctionArgs Tokens Env ?RestTokens}
   case Tokens
   of nil then 
      RestTokens = nil
      nil
   [] H|T then
      if H == ")" orelse H == "in" then
         RestTokens = Tokens
         nil
      else
         local Arg Rest2 RestArgs in
            Arg = {ParseSingleExprAux Tokens Env Rest2}
            RestArgs = {ParseFunctionArgs Rest2 Env RestTokens}
            Arg|RestArgs
         end
      end
   end
end

% Construye una cadena de aplicaciones para función con múltiples argumentos
fun {BuildAppChain FunName Args}
   case Args
   of nil then leaf(value:FunName)
   [] [Arg] then
      app(left: leaf(value:FunName) right: Arg)
   [] Arg|Rest then
      app(left: {BuildAppChain FunName [Arg]} right: {List.last Args})
   end
end

% Pruebas
%{Browse "=== Prueba 1: Expresión simple ==="} 
%{Browse {GraphGeneration "* 3 4"}}

%{Browse "=== Prueba 2: Función y aplicación ==="} 
%{Browse {GraphGeneration "fun square x = * x x square 3"}}

%{Browse "=== Prueba 3: Expresión del profesor - twice ==="} 
%{Browse {GraphGeneration "fun twice x = + x x twice 5"}}

%{Browse "=== Prueba 4: Expresión del profesor - fourtimes ==="} 
%{Browse {GraphGeneration "fun fourtimes x = var y = * x x in + y y fourtimes 2"}}

%% ============================================
%% TASK 2: NextReduction
%% ============================================

% Encuentra la próxima expresión a reducir o instanciar
% Retorna: redex(node: Node path: [left|right]) 
%          instantiate(node: Node path: [left|right])
%          o none
fun {NextReduction Graph Env}
   % Primero buscar instanciaciones (tienen prioridad)
   local InstResult in
      InstResult = {FindInstantiation Graph.mainExpr Env nil}
      case InstResult
      of none then
         % Si no hay instanciaciones, buscar redex
         {FindRedex Graph.mainExpr Env nil}
      else
         InstResult
      end
   end
end

% Busca un nodo que necesite instanciación (función definida con argumentos completos)
fun {FindInstantiation Node Env Path}
   case Node
   of leaf(value:_) then
      none
   [] app(left:Left right:Right) then
      % Verificar si este nodo necesita instanciación
      if {NeedsInstantiation Node Env} then
         instantiate(node:Node path:{Reverse Path nil})
      else
         % Buscar en el hijo izquierdo primero
         local LeftResult in
            LeftResult = {FindInstantiation Left Env left|Path}
            case LeftResult
            of none then
               % Si no hay en la izquierda, buscar a la derecha
               {FindInstantiation Right Env right|Path}
            else
               LeftResult
            end
         end
      end
   else
      none
   end
end

% Verifica si un nodo necesita instanciación
fun {NeedsInstantiation Node Env}
   case Node
   of app(left:Left right:Right) then
      local Op Args in
         Op = {GetOperator Node}
         Args = {GetArgs Node nil}
         
         case Op
         of leaf(value:OpName) then
            % Verificar si es una función definida con suficientes argumentos
            if {HasFun Env OpName} then
               local FunDef in
                  FunDef = {GetFun Env OpName}
                  {Length Args} == {Length FunDef.params}
               end
            else
               false
            end
         else
            false
         end
      end
   else
      false
   end
end

% Busca un redex (expresión reducible) en el grafo
% Path mantiene el camino desde la raíz (lista de 'left' o 'right')
fun {FindRedex Node Env Path}
   case Node
   of leaf(value:_) then
      none  % Una hoja no es reducible
   [] app(left:Left right:Right) then
      % Verificar si este nodo de aplicación es un redex
      if {IsRedex Node Env} then
         redex(node:Node path:{Reverse Path nil})
      else
         % Buscar en el hijo izquierdo primero (order matters!)
         local LeftResult in
            LeftResult = {FindRedex Left Env left|Path}
            case LeftResult
            of none then
               % Si no hay redex a la izquierda, buscar a la derecha
               {FindRedex Right Env right|Path}
            else
               LeftResult
            end
         end
      end
   else
      none
   end
end

% Verifica si un nodo de aplicación es un redex (reducible)
fun {IsRedex Node Env}
   case Node
   of app(left:Left right:Right) then
      % Obtener el operador/función en la cabeza
      local Op Args in
         Op = {GetOperator Node}
         Args = {GetArgs Node nil}
         
         case Op
         of leaf(value:OpName) then
            % Verificar si es un átomo (primitiva) o un número
            if {IsAtom OpName} then
               % Verificar si es una primitiva o 'var'
               if {IsPrimitive {Atom.toString OpName}} then
                  % Primitiva: necesita 2 argumentos que sean valores numéricos
                  {Length Args} == 2 andthen {AllValues Args}
               elseif OpName == 'var' then
                  % 'var' siempre se puede reducir si tiene 2 argumentos
                  {Length Args} == 2
               else
                  false
               end
            else
               % No es un átomo (es un número o nil), no es reducible
               false
            end
         else
            false
         end
      end
   else
      false
   end
end

% Obtiene el operador (función/primitiva) en la cabeza de aplicaciones anidadas
fun {GetOperator Node}
   case Node
   of app(left:Left right:_) then
      {GetOperator Left}
   [] leaf(value:_) then
      Node
   else
      Node
   end
end

% Obtiene la lista de argumentos de aplicaciones anidadas
fun {GetArgs Node Acc}
   case Node
   of app(left:Left right:Right) then
      {GetArgs Left Right|Acc}
   [] leaf(value:_) then
      Acc
   else
      Acc
   end
end

% Verifica si todos los nodos en la lista son valores (hojas con números)
fun {AllValues Nodes}
   case Nodes
   of nil then true
   [] H|T then
      case H
      of leaf(value:V) then
         {IsNumber V} andthen {AllValues T}
      else
         false
      end
   end
end

% Invierte una lista
fun {Reverse L Acc}
   case L
   of nil then Acc
   [] H|T then {Reverse T H|Acc}
   end
end

% Pruebas de NextReduction
%{Browse "=== TASK 2: NextReduction ==="}
%local Result1 in
%   Result1 = {GraphGeneration "* 3 4"}
%   {Browse "Siguiente reducción en * 3 4:"}
%   {Browse {NextReduction Result1 Result1.env}}
%end

%local Result2 in
%   Result2 = {GraphGeneration "fun square x = * x x square 3"}
%   {Browse "Siguiente reducción en square 3:"}
%   {Browse {NextReduction Result2 Result2.env}}
%end

%local Result3 in
%   Result3 = {GraphGeneration "fun twice x = + x x twice 5"}
%   {Browse "Siguiente reducción en twice 5:"}
%   {Browse {NextReduction Result3 Result3.env}}
%end

%% ============================================
%% TASK 3: Reduce
%% ============================================

% Aplica una única reducción al grafo
% Retorna: reduced(graph: Graph) si se pudo reducir
%          unreducible si no hay más reducciones
fun {Reduce Graph}
   local Next in
      Next = {NextReduction Graph Graph.env}
      case Next
      of none then
         unreducible
      [] redex(node:Node path:Path) then
         % Aplicar reducción de primitiva
         local NewExpr in
            NewExpr = {ReduceRedex Node}
            reduced(graph: result(env: Graph.env 
                                   mainExpr: {ReplaceNode Graph.mainExpr Path NewExpr}))
         end
      [] instantiate(node:Node path:Path) then
         % Aplicar instanciación de función
         local NewExpr in
            NewExpr = {InstantiateFunction Node Graph.env}
            reduced(graph: result(env: Graph.env 
                                   mainExpr: {ReplaceNode Graph.mainExpr Path NewExpr}))
         end
      end
   end
end

% Reduce un redex (aplica operación primitiva)
fun {ReduceRedex Node}
   local Op Args Arg1 Arg2 in
      Op = {GetOperator Node}
      Args = {GetArgs Node nil}
      Arg1|Arg2|nil = Args
      
      case Op
      of leaf(value:OpName) then
         case OpName
         of 'var' then
            % var VarName VarValue -> crea sustitución local
            % Arg1 es el nombre de la variable (como leaf(value:y))
            % Arg2 es el cuerpo donde se usa la variable
            % VarValue es el primer argumento que se debe sustituir
            case Arg1
            of leaf(value:VarName) then
               % Obtener el valor de la variable (Arg2 es app(left:VarExpr right:BodyExpr))
               case Arg2
               of app(left:VarValue right:BodyExpr) then
                  % Sustituir VarName por VarValue en BodyExpr
                  local SubstDict in
                     SubstDict = {Dictionary.new}
                     {Dictionary.put SubstDict VarName VarValue}
                     {SubstituteInNode BodyExpr SubstDict}
                  end
               else
                  Arg2
               end
            else
               Arg2
            end
         else
            % Primitiva normal
            case Arg1#Arg2
            of leaf(value:V1)#leaf(value:V2) then
               case OpName
               of '+' then leaf(value: V1 + V2)
               [] '-' then leaf(value: V1 - V2)
               [] '*' then leaf(value: V1 * V2)
               [] '/' then leaf(value: V1 div V2)
               else leaf(value:error)
               end
            else
               leaf(value:error)
            end
         end
      else
         leaf(value:error)
      end
   end
end

% Instancia una función (copia su cuerpo sustituyendo parámetros)
fun {InstantiateFunction Node Env}
   local Op Args FunDef in
      Op = {GetOperator Node}
      Args = {GetArgs Node nil}
      
      case Op
      of leaf(value:FunName) then
         FunDef = {GetFun Env FunName}
         % Crear un diccionario de sustituciones parámetro -> argumento
         local SubstDict in
            SubstDict = {Dictionary.new}
            {CreateSubstitutions FunDef.params Args SubstDict}
            % Sustituir en el cuerpo de la función
            {SubstituteInNode FunDef.body SubstDict}
         end
      else
         leaf(value:error)
      end
   end
end

% Crea un diccionario de sustituciones
proc {CreateSubstitutions Params Args SubstDict}
   case Params#Args
   of (P|Ps)#(A|As) then
      {Dictionary.put SubstDict {String.toAtom P} A}
      {CreateSubstitutions Ps As SubstDict}
   [] nil#nil then
      skip
   else
      skip
   end
end

% Sustituye variables en un nodo según el diccionario
fun {SubstituteInNode Node SubstDict}
   case Node
   of leaf(value:V) then
      % Si es un átomo y está en el diccionario, sustituir
      if {IsAtom V} andthen {Dictionary.member SubstDict V} then
         {Dictionary.get SubstDict V}
      else
         Node
      end
   [] app(left:Left right:Right) then
      app(left:{SubstituteInNode Left SubstDict}
          right:{SubstituteInNode Right SubstDict})
   else
      Node
   end
end

% Reemplaza un nodo en el árbol siguiendo un path
fun {ReplaceNode Root Path NewNode}
   case Path
   of nil then NewNode
   [] left|RestPath then
      case Root
      of app(left:L right:R) then
         app(left:{ReplaceNode L RestPath NewNode} right:R)
      else
         Root
      end
   [] right|RestPath then
      case Root
      of app(left:L right:R) then
         app(left:L right:{ReplaceNode R RestPath NewNode})
      else
         Root
      end
   end
end

% Extrae solo el valor de un leaf
fun {ExtractValue Node}
   case Node
   of leaf(value:V) then V
   else Node
   end
end

%% ============================================
%% TASK 4: Evaluate
%% ============================================

% Evalúa una expresión hasta que no haya más reducciones posibles
% Usa Reduce repetidamente
fun {Evaluate Graph}
   local ReductionResult in
      ReductionResult = {Reduce Graph}
      case ReductionResult
      of unreducible then
         % No hay más reducciones, retornar el resultado
         Graph.mainExpr
      [] reduced(graph:NewGraph) then
         % Aplicar Reduce nuevamente recursivamente
         {Evaluate NewGraph}
      end
   end
end

%% ============================================
%% TESTS
%% ============================================

{System.showInfo "===================================="}
{System.showInfo "PRUEBAS DEL PROYECTO"}
{System.showInfo "===================================="}
{System.showInfo ""}

% Test 1: GraphGeneration
{System.showInfo "TEST 1: GraphGeneration"}
{System.showInfo "Program: * 3 4"}
local G1 in
   G1 = {GraphGeneration "* 3 4"}
   {System.showInfo "✓ Grafo generado exitosamente"}
end
{System.showInfo ""}

% Test 2: NextReduction
{System.showInfo "TEST 2: NextReduction"}
{System.showInfo "Program: * 3 4"}
local G2 Next2 in
   G2 = {GraphGeneration "* 3 4"}
   Next2 = {NextReduction G2 G2.env}
   case Next2
   of redex(node:_ path:_) then
      {System.showInfo "✓ Redex encontrado: primitiva * con argumentos 3 y 4"}
   else
      {System.showInfo "✗ Error: no se encontró redex"}
   end
end
{System.showInfo ""}

% Test 3: Reduce (una sola reducción)
{System.showInfo "TEST 3: Reduce (una reducción)"}
{System.showInfo "Program: * 3 4"}
local G3 R3 in
   G3 = {GraphGeneration "* 3 4"}
   R3 = {Reduce G3}
   case R3
   of reduced(graph:NewG) then
      case NewG.mainExpr
      of leaf(value:V) then
         {System.showInfo "✓ Reducción aplicada: resultado = "#{Int.toString V}}
      else
         {System.showInfo "✗ Error en reducción"}
      end
   else
      {System.showInfo "✗ No se pudo reducir"}
   end
end
{System.showInfo ""}

% Test 4: Evaluate (evaluación completa usando Reduce)
{System.showInfo "TEST 4: Evaluate (evaluación completa)"}
{System.showInfo ""}

{System.showInfo "Test 4.1: * 3 4"}
local R4_1 in
   R4_1 = {Evaluate {GraphGeneration "* 3 4"}}
   case R4_1
   of leaf(value:V) then
      if V == 12 then
         {System.showInfo "✓ Resultado correcto: "#{Int.toString V}}
      else
         {System.showInfo "✗ Resultado incorrecto. Esperado: 12, Obtenido: "#{Int.toString V}}
      end
   else
      {System.showInfo "✗ Error en evaluación"}
   end
end

{System.showInfo ""}
{System.showInfo "Test 4.2: square 3 (fun square x = * x x)"}
local R4_2 in
   R4_2 = {Evaluate {GraphGeneration "fun square x = * x x square 3"}}
   case R4_2
   of leaf(value:V) then
      if V == 9 then
         {System.showInfo "✓ Resultado correcto: "#{Int.toString V}}
      else
         {System.showInfo "✗ Resultado incorrecto. Esperado: 9, Obtenido: "#{Int.toString V}}
      end
   else
      {System.showInfo "✗ Error en evaluación"}
   end
end

{System.showInfo ""}
{System.showInfo "Test 4.3: twice 5 (fun twice x = + x x)"}
local R4_3 in
   R4_3 = {Evaluate {GraphGeneration "fun twice x = + x x twice 5"}}
   case R4_3
   of leaf(value:V) then
      if V == 10 then
         {System.showInfo "✓ Resultado correcto: "#{Int.toString V}}
      else
         {System.showInfo "✗ Resultado incorrecto. Esperado: 10, Obtenido: "#{Int.toString V}}
      end
   else
      {System.showInfo "✗ Error en evaluación"}
   end
end

{System.showInfo ""}
{System.showInfo "Test 4.4: fourtimes 2 (fun fourtimes x = var y = * x x in + y y)"}
local R4_4 in
   R4_4 = {Evaluate {GraphGeneration "fun fourtimes x = var y = * x x in + y y fourtimes 2"}}
   case R4_4
   of leaf(value:V) then
      if V == 8 then
         {System.showInfo "✓ Resultado correcto: "#{Int.toString V}}
      else
         {System.showInfo "✗ Resultado incorrecto. Esperado: 8, Obtenido: "#{Int.toString V}}
      end
   else
      {System.showInfo "✗ Error en evaluación"}
   end
end

{System.showInfo ""}
{System.showInfo "===================================="}
{System.showInfo "PRUEBAS COMPLETADAS"}
{System.showInfo "===================================="}