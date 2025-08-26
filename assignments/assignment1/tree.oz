declare
%% inorderPreorder2BT
%% Input: Two lists representing the inorder and preorder
%% Output: A binary tree built from the traversals

fun {InorderPreorder2BT In Pre}
  case In
  of nil then nil
  [] InList then
    case Pre
    of nil then nil
    [] Root|PreRest then

      % Find the index of the root in the inorder list
      Mid = {List.length {List.takeWhile InList fun {$ X} X \= Root end}}
      % Use the index to split the lists
      LeftIn = {List.take InList Mid}
      RightIn = {List.drop InList Mid+1}

      LeftPre = {List.take PreRest Mid}
      RightPre = {List.drop PreRest Mid}

      in
        tree(value:Root left:{InorderPreorder2BT LeftIn LeftPre} right:{InorderPreorder2BT RightIn RightPre})
      end
    end
  end

%% inorderPostorder2BT
%% Input: Two lists representing the inorder and postorder traversals of a binary tree
%% Output: A binary tree built from the traversals

fun {InorderPostorder2BT In Post}
  case In
  of nil then nil
  [] InList then
    case Post
    of nil then nil
    [] _|_ then

      % Get the root (last element of Postorder)
      Root = {List.last Post}

      % Get the list without the root
      PostInit = {List.take Post {List.length Post}-1}

      % Find the index of the root in the inorder list
      Mid = {List.length {List.takeWhile InList fun {$ X} X \= Root end}}
      LeftIn = {List.take InList Mid}
      RightIn = {List.drop InList Mid+1}
      LeftPost = {List.take PostInit Mid}
      RightPost = {List.drop PostInit Mid}
      in
        tree(value:Root left:{InorderPostorder2BT LeftIn LeftPost} right:{InorderPostorder2BT RightIn RightPost})
      end
    end
  end


% Test cases
Inorder1 = [4 2 5 1 3]
Preorder1 = [1 2 4 5 3]
Postorder1 = [4 5 2 3 1]

Inorder2 = ['A' 'B' 'C' 'D']
Preorder2 = ['A' 'B' 'C' 'D']
Postorder2 = ['D' 'C' 'B' 'A']

Inorder3 = nil
Preorder3 = nil
Postorder3 = nil

Tree1a = {InorderPreorder2BT Inorder1 Preorder1}
Tree1b = {InorderPostorder2BT Inorder1 Postorder1}
Tree2a = {InorderPreorder2BT Inorder2 Preorder2}
Tree2b = {InorderPostorder2BT Inorder2 Postorder2}
Tree3a = {InorderPreorder2BT Inorder4 Preorder4}
Tree3b = {InorderPostorder2BT Inorder4 Postorder4}


{Browse Tree1a}
{Browse Tree1b}
{Browse Tree2a}
{Browse Tree2b}
{Browse Tree3a}
{Browse Tree3b}