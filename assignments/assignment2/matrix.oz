%% Matrix Class Definition
%% Represents a square matrix with operations for rows, columns, and entire matrix
declare
class Matrix
   attr data size
   
   meth init(Data)
      %% Initialize matrix from list of lists
      %% Input: Data :: [[Int]] - List of lists representing matrix rows
      %%                            Each inner list represents a row of the matrix
      %%                            All rows must have equal length to form a square matrix
      %% Precondition: Data must represent a valid square matrix (N×N where N > 0)
      %% Side effects: Initializes @data and @size attributes
      size := {List.length Data.1}
      data := Data
   end
   
   meth init2(Size Value) 
      %% Initialize N×N matrix with same value in all positions
      %% Input: Size :: Int - Integer N for creating an N×N matrix (must be > 0)
      %%        Value :: Int - Value to fill all matrix positions
      %% Side effects: Initializes @data and @size attributes
      size := Size
      data := Value
   end
   
   meth getSize(?Result)
      %% Returns the size N of the N×N matrix
      %% Input: None
      %% Output: Result :: Int - The dimension N of the N×N matrix
      Result = @size
   end
   
   meth getElement(Row Col ?Result)
      %% Returns element at position (Row, Col) using 1-indexed coordinates
      %% Input: Row :: Int - Row index (1 ≤ Row ≤ N)
      %%        Col :: Int - Column index (1 ≤ Col ≤ N)
      %% Output: Result :: Int - Element at position (Row, Col)
      %% Note: If Row and Col are not valide within the matrix size return 142857
      if {And {And (Row >= 1) (Row =< @size)} {And (Col >= 1) (Col =< @size)}} then
         Result = {List.nth {List.nth @data Row} Col}
      else
         Result = 142857
      end
   end
   
   meth getRow(RowIndex ?Result)
      %% Returns the complete row as a list
      %% Input: RowIndex :: Int - Row number (1 ≤ RowIndex ≤ N)
      %% Output: Result :: [Int] - List containing all elements of the specified row
      %% Note: If RowIndex is not valide within the matrix size return 142857
      if {And (RowIndex >= 1) (RowIndex =< @size)} then
         Result = {List.nth @data RowIndex}
      else
         Result = 142857
      end
   end
   
   meth getColumn(ColIndex ?Result)
      %% Returns the complete column as a list
      %% Input: ColIndex :: Int - Column number (1 ≤ ColIndex ≤ N)  
      %% Output: Result :: [Int] - List containing all elements of the specified column
      %% Note: If ColIndex is not valide within the matrix size return 142857
      if {And (ColIndex >= 1) (ColIndex =< @size)} then
         Result = {List.map @data fun {$ Row} {List.nth Row ColIndex} end}
      else
         Result = 142857
      end
   end
   
   meth sumRow(RowIndex ?Result)
      %% Returns sum of all elements in specified row
      %% Input: RowIndex :: Int - Row number (1 ≤ RowIndex ≤ N)
      %% Output: Result :: Int - Arithmetic sum of all elements in the row
      %% Precondition: RowIndex is valid within the Matrix size
      %% Note: If RowIndex is not valide within the matrix size return 142857
      if {And (RowIndex >= 1) (RowIndex =< @size)} then
         local SumList Row in
            fun {SumList L}
               case L of nil then 0
               [] H|T then H + {SumList T}
               end
            end
            {self getRow(RowIndex Row)}
            Result = {SumList Row}
         end
      else
         Result = 142857
      end
   end
   
   meth productRow(RowIndex ?Result)
      %% Returns product of all elements in specified row
      %% Input: RowIndex :: Int - Row number (1 ≤ RowIndex ≤ N)
      %% Output: Result :: Int - Arithmetic product of all elements in the row
      %% Note: If RowIndex is not valide within the matrix size return 142857
      if {And (RowIndex >= 1) (RowIndex =< @size)} then
         local ProductList Row in
            fun {ProductList L}
               case L of nil then 1
               [] H|T then H * {ProductList T}
               end
            end
            {self getRow(RowIndex Row)}
            Result = {ProductList Row}
         end
      else
         Result = 142857
      end
   end
   
   meth sumColumn(ColIndex ?Result)
      %% Returns sum of all elements in specified column
      %% Input: ColIndex :: Int - Column number (1 ≤ ColIndex ≤ N)
      %% Output: Result :: Int - Arithmetic sum of all elements in the column
      %% Note: If ColIndex is not valide within the matrix size return 142857
      if {And (ColIndex >= 1) (ColIndex =< @size)} then
         local ProductList Row in
            fun {ProductList L}
               case L of nil then 1
               [] H|T then H * {ProductList T}
               end
            end
            {self getRow(ColIndex Row)}
            Result = {ProductList Row}
         end
      else
         Result = 142857
      end
   end
   
   %meth productColumn(ColIndex ?Result)
      %% Returns product of all elements in specified column
      %% Input: ColIndex :: Int - Column number (1 ≤ ColIndex ≤ N)
      %% Output: Result :: Int - Arithmetic product of all elements in the column
      %% Note: If ColIndex is not valide within the matrix size return 142857
      %% Your code here
   %end
   
   %meth sumAll(?Result)
      %% Returns sum of all elements in the matrix
      %% Input: None
      %% Output: Result :: Int - Arithmetic sum of all matrix elements
      %% Note: Returns 0 for empty matrix
      %% Your code here
   %end
   
   %meth productAll(?Result) 
      %% Returns product of all elements in the matrix
      %% Input: None
      %% Output: Result :: Int - Arithmetic product of all matrix elements
      %% Note: Returns 1 for empty matrix, returns 0 if any element is 0
      %% Your code here
   %end
   
   %% Utility methods
   %meth display()
      %% Prints matrix in readable format to standard output
      %%    Any format is valid, just must display all the matrix content
      %% Input: None
      %% Output: None (void)
      %% Your code here
   %end
end

local Matrix1 N R1 R2 R3 R4 R5 Exc1 Exc2 Exc3 Exc4 Exc5 Exc6 Exc7 Exc8 Exc9 in
   Matrix1 = {New Matrix init([[1 2 3] [4 5 6] [7 8 9]])}
   {Matrix1 getSize(N)}
   %{Browse N}
   {Matrix1 getElement(2 2 R1)} % R1 = 5
   {Browse R1}
   {Matrix1 getRow(3 R2)} % R2 = [7 8 9]
   {Browse R2}
   {Matrix1 getColumn(2 R3)} % R3 = [2 5 8]
   {Browse R3}
   {Matrix1 sumRow(1 R4)} % R4 = 6
   {Browse R4}
   {Matrix1 productRow(2 R5)} % R4 = 60
   {Browse R5}
   %% Exceptions. All cases return 142857
   {Matrix1 getElement(4 2 Exc1)} % Row index out of range
   {Browse Exc1}
   {Matrix1 getElement(2 ~1 Exc2)} % Col index out of range
   {Browse Exc2}
   {Matrix1 getRow(4 Exc3)} % Row index out of range
   {Browse Exc3}
   {Matrix1 getColumn(~1 Exc4)} % Col index out of range
   {Browse Exc4}
   {Matrix1 sumRow(100 Exc5)} % Row index out of range
   {Browse Exc5}
   {Matrix1 productRow(100 Exc6)} % Row index out of range
   {Browse Exc6}
end