%% Preguntas
% 1. Se puede dejar suelto _ en línea 29?
% 2. En 40 y 55, asignar la variable a la función respeta FP?
% 3. En display se puede usar skip? puede ser proc en vez de fun?
%% Matrix Definition
declare

   %% Helper functions
   fun {SumList L}
      case L
      of nil then 0
      [] H|T then H + {SumList T}
      end
   end

   fun {ProductList L}
      case L
      of nil then 1
      [] H|T then H * {ProductList T}
      end
   end

   fun {GetSize Matrix }
      %% Returns the size N of the N×N matrix given as parameter
      %% Input: None
      %% Output: Result :: Int - The dimension N of the N×N matrix
      case Matrix
      of nil then 0
      [] Row|_ then {List.length Row}
      end
   end
   
   fun {GetElement Matrix Row Col }
      %% Returns element at position  Matrix Row, Col) using 1-indexed coordinates
      %% Input: Row :: Int - Row index  Matrix 1 ≤ Row ≤ N)
      %%        Col :: Int - Column index  Matrix 1 ≤ Col ≤ N)
      %% Output: Result :: Int - Element at position  Matrix Row, Col)
      %% Note: If Row and Col are not valide within the matrix size return 142857
      local Size in
         Size = {GetSize Matrix}
         if {And {And Row >= 1 Row =< Size} {And Col >= 1 Col =< Size}} then
            {List.nth {List.nth Matrix Row} Col}
         else
            142857
         end
      end
   end
   
   fun {GetRow Matrix RowIndex }
      %% Returns the complete row as a list
      %% Input: RowIndex :: Int - Row number  Matrix 1 ≤ RowIndex ≤ N)
      %% Output: Result :: [Int] - List containing all elements of the specified row
      %% Note: If RowIndex is not valide within the matrix size return 142857
      local Size in
         Size = {GetSize Matrix}
         if {And RowIndex >= 1 RowIndex =< Size} then
            {List.nth Matrix RowIndex}
         else
            142857
         end
      end
   end

   fun {GetColumn Matrix ColIndex }
      %% Returns the complete column as a list
      %% Input: ColIndex :: Int - Column number  Matrix 1 ≤ ColIndex ≤ N)
      %% Output: Result :: [Int] - List containing all elements of the specified column
      %% Note: If ColIndex is not valide within the matrix size return 142857
      local Size in
         Size = {GetSize Matrix}
         if {And ColIndex >= 1 ColIndex =< Size} then
            {List.map Matrix fun {$ Row} {List.nth Row ColIndex} end}
         else
            142857
         end
      end
   end
   
   fun {SumRow Matrix RowIndex }
      %% Returns sum of all elements in specified row
      %% Input: RowIndex :: Int - Row number  Matrix 1 ≤ RowIndex ≤ N)
      %% Output: Result :: Int - Arithmetic sum of all elements in the row
      %% Precondition: RowIndex is valid within the Matrix size
      %% Note: If RowIndex is not valide within the matrix size return 142857
      local Row in
         Row = {GetRow Matrix RowIndex}
         if Row == 142857 then
            142857
         else
            {SumList Row}
         end
      end
   end
   
   fun {ProductRow Matrix RowIndex }
      %% Returns product of all elements in specified row
      %% Input: RowIndex :: Int - Row number  ( 1 ≤ RowIndex ≤ N)
      %% Output: Result :: Int - Arithmetic product of all elements in the row
      %% Note: If RowIndex is not valide within the matrix size return 142857
      %% Your code here
      local Row in
         Row = {GetRow Matrix RowIndex}
         if Row == 142857 then
            142857
         else
            {ProductList Row}
         end
      end
   end
   
   fun {SumColumn Matrix ColIndex }
      %% Returns sum of all elements in specified column
      %% Input: ColIndex :: Int - Column number  Matrix 1 ≤ ColIndex ≤ N)
      %% Output: Result :: Int - Arithmetic sum of all elements in the column
      %% Note: If ColIndex is not valide within the matrix size return 142857
      %% Your code here
      local Col in
         Col = {GetColumn Matrix ColIndex}
         if Col == 142857 then
            142857
         else
            {SumList Col}
         end
      end
   end
   
   fun {ProductColumn Matrix ColIndex }
      %% Returns product of all elements in specified column
      %% Input: ColIndex :: Int - Column number  Matrix 1 ≤ ColIndex ≤ N)
      %% Output: Result :: Int - Arithmetic product of all elements in the column
      %% Note: If ColIndex is not valide within the matrix size return 142857
      %% Your code here
      local Col in
         Col = {GetColumn Matrix ColIndex}
         if Col == 142857 then
            142857
         else
            {ProductList Col}
         end
      end 
   end
   
   fun {SumAll Matrix }
      %% Returns sum of all elements in the matrix
      %% Input: None
      %% Output: Result :: Int - Arithmetic sum of all matrix elements
      %% Note: Returns 0 for empty matrix
      %% Your code here
      case Matrix
      of nil then 0
      else
         {SumList {List.flatten Matrix}}
      end
   end
   
   fun {ProductAll Matrix }
      %% Returns product of all elements in the matrix
      %% Input: None
      %% Output: Result :: Int - Arithmetic product of all matrix elements
      %% Note: Returns 1 for empty matrix, returns 0 if any element is 0
      %% Your code here
      case Matrix
      of nil then 1
      else
         {ProductList {List.flatten Matrix}}
      end
   end
   
   %% Utility funods
   proc {Display Matrix}
      %% Prints matrix in readable format to standard output
      %% Input: Matrix :: [[Int]]
      %% Output: None (void)
      proc {DisplayRows Rows}
         case Rows
         of nil then skip
         [] Row|Rest then
            {System.show Row}
            {DisplayRows Rest}
         end
      end
   in
      case Matrix
      of nil then {System.showInfo "Empty matrix"}
      else {DisplayRows Matrix}
      end
   end

{System.showInfo "\n=== TEST: Matrix Operations ==="}
local Matrix1 N R1 R2 R3 R4 R5 R6 R7 R8 R9 Exc1 Exc2 Exc3 Exc4 Exc5 Exc6 in
   Matrix1 = [[1 2 3] [4 5 6] [7 8 9]]
   
   N = {GetSize Matrix1}
   {System.showInfo "GetSize: " # N} % Expected: 3
   
   R1 = {GetElement Matrix1 2 2}
   {System.showInfo "GetElement(2,2): " # R1} % Expected: 5
   
   R2 = {GetRow Matrix1 3}
   {System.showInfo "GetRow(3): "}
   {System.show R2} % Expected: [7 8 9]
   
   R3 = {GetColumn Matrix1 2}
   {System.showInfo "GetColumn(2): "}
   {System.show R3} % Expected: [2 5 8]
   
   R4 = {SumRow Matrix1 1}
   {System.showInfo "SumRow(1): " # R4} % Expected: 6
   
   R5 = {ProductRow Matrix1 2}
   {System.showInfo "ProductRow(2): " # R5} % Expected: 120
   
   R6 = {SumColumn Matrix1 2}
   {System.showInfo "SumColumn(2): " # R6} % Expected: 15
   
   R7 = {ProductColumn Matrix1 2}
   {System.showInfo "ProductColumn(2): " # R7} % Expected: 80
   
   R8 = {SumAll Matrix1}
   {System.showInfo "SumAll: " # R8} % Expected: 45
   
   R9 = {ProductAll Matrix1}
   {System.showInfo "ProductAll: " # R9} % Expected: 362880 (9!)
   
   {System.showInfo "\n=== TEST: Exception Cases ==="}
   
   Exc1 = {GetElement Matrix1 4 2}
   {System.showInfo "GetElement(4,2) - out of range: " # Exc1} % Expected: 142857
   
   Exc2 = {GetElement Matrix1 2 ~1}
   {System.showInfo "GetElement(2,-1) - out of range: " # Exc2} % Expected: 142857
   
   Exc3 = {GetRow Matrix1 4}
   {System.showInfo "GetRow(4) - out of range: " # Exc3} % Expected: 142857
   
   Exc4 = {GetColumn Matrix1 ~1}
   {System.showInfo "GetColumn(-1) - out of range: " # Exc4} % Expected: 142857
   
   Exc5 = {SumRow Matrix1 100}
   {System.showInfo "SumRow(100) - out of range: " # Exc5} % Expected: 142857
   
   Exc6 = {ProductColumn Matrix1 100}
   {System.showInfo "ProductColumn(100) - out of range: " # Exc6} % Expected: 142857
   
   {System.showInfo "\n=== Display Matrix ==="}
   {Display Matrix1}
end