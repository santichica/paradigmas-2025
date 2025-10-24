%% ============================================================================
%% Main game controller that manages the overall game flow
%% ============================================================================
%% Color enumeration - valid colors in the game
%% Type: Color :: red | blue | green | yellow | orange | purple
%% ============================================================================

declare

%% ============================================================================
%% Game State Representation
%% ============================================================================
%% Codemaker is represented as a record:
%% codemaker(secretCode: [Color] currentRound: Int maxRounds: Int)

fun {StartGame Code}
   %% Starts a new game session with a codemaker with a defined secret code
   %% Input: Code :: [Color] - The secret code (4 colors)
   %% Output: Codemaker record with the code and initial state
   codemaker(secretCode: Code currentRound: 1 maxRounds: 12)
end

fun {PlayRound Codemaker Guess}
   %% Executes one round of the game (guess + feedback)
   %% Input: Codemaker - current game state
   %%        Guess :: [Color] - the guess from the codebreaker
   %% Output: result(feedback: Feedback newCodemaker: UpdatedCodemaker)
   local Feedback NewCodemaker in
      Feedback = {EvaluateGuess Codemaker Guess}
      NewCodemaker = codemaker(secretCode: Codemaker.secretCode currentRound: (Codemaker.currentRound + 1) maxRounds: Codemaker.maxRounds)
      result(feedback: Feedback newCodemaker: NewCodemaker)
   end
end

fun {GetGameStatus Feedback Rounds}
   %% Returns current game status
   %% Input: Feedback - feedback from last guess
   %%        Rounds :: Int - The number of rounds played so far
   %% Output: GameStatus :: 'playing' | 'won' | 'lost'
   if Feedback.blackClues == 4 then
      won
   elseif Rounds > 12 then
      lost
   else
      playing
   end
end

fun {GetCurrentRound Codemaker}
   %% Returns current round number
   %% Input: Codemaker - current game state
   %% Output: Int - Current round number (1-12)
   Codemaker.currentRound
end

fun {GetRemainingRounds Codemaker}
   %% Returns number of rounds left
   %% Input: Codemaker - current game state
   %% Output: Int - Number of rounds remaining (0-11)
   Codemaker.maxRounds - Codemaker.currentRound + 1
end

fun {EvaluateGuess Codemaker Guess}
   %% Evaluates a guess against the secret code
   %% Input: Codemaker - contains the secret code
   %%        Guess :: [Color] - List of exactly 4 colors
   %% Output: feedback(blackClues: Int whiteClues: Int clueList: [Clue])
   
   local 
      SecretCode
      CountBlackClues
      RemoveMatched
      CountWhiteClues
      GenerateClueList
   in
      SecretCode = Codemaker.secretCode
      
      %% Helper function to count black clues (correct position)
      fun {CountBlackClues Secret Guess}
         case Secret#Guess
         of nil#nil then 0
         [] (SH|ST)#(GH|GT) then
            if SH == GH then
               1 + {CountBlackClues ST GT}
            else
               {CountBlackClues ST GT}
            end
         end
      end
      
      %% Helper function to remove matched elements
      fun {RemoveMatched Secret Guess}
         case Secret#Guess
         of nil#nil then nil#nil
         [] (SH|ST)#(GH|GT) then
            if SH == GH then
               {RemoveMatched ST GT}
            else
               local RestResult in
                  RestResult = {RemoveMatched ST GT}
                  (SH|RestResult.1)#(GH|RestResult.2)
               end
            end
         end
      end
      
      %% Helper function to count white clues (correct color, wrong position)
      fun {CountWhiteClues RemainingSecret RemainingGuess}
         case RemainingGuess
         of nil then 0
         [] GH|GT then
            if {List.member GH RemainingSecret} then
               local NewSecret in
                  NewSecret = {List.subtract RemainingSecret GH}
                  1 + {CountWhiteClues NewSecret GT}
               end
            else
               {CountWhiteClues RemainingSecret GT}
            end
         end
      end
      
      %% Generate clue list
      fun {GenerateClueList Secret Guess}
         case Secret#Guess
         of nil#nil then nil
         [] (SH|ST)#(GH|GT) then
            if SH == GH then
               black | {GenerateClueList ST GT}
            elseif {List.member GH Secret} then
               white | {GenerateClueList ST GT}
            else
               none | {GenerateClueList ST GT}
            end
         end
      end
      
      local BlackCount Remaining WhiteCount ClueList in
         BlackCount = {CountBlackClues SecretCode Guess}
         Remaining = {RemoveMatched SecretCode Guess}
         WhiteCount = {CountWhiteClues Remaining.1 Remaining.2}
         ClueList = {GenerateClueList SecretCode Guess}
         
         feedback(
            blackClues: BlackCount
            whiteClues: WhiteCount
            totalCorrect: BlackCount + WhiteCount
            isCorrect: (BlackCount == 4)
            clueList: ClueList
         )
      end
   end
end

fun {GetSecretCode Codemaker}
   %% Returns the current secret code (for testing/debugging)
   %% Input: Codemaker - current game state
   %% Output: [Color] - Secret code
   %% Note: Should only be used for testing
   Codemaker.secretCode
end

%% ============================================================================
%% Helper Functions
%% ============================================================================

fun {IsValidGuess Guess}
   %% Validates if a guess is valid (4 colors)
   local ValidColors in
      ValidColors = [red blue green yellow orange purple]
      {List.length Guess} == 4 andthen
      {List.all Guess fun {$ C} {List.member C ValidColors} end}
   end
end

proc {DisplayFeedback Feedback}
   %% Displays feedback in a readable format
   {System.showInfo "Black clues (correct position): " # Feedback.blackClues}
   {System.showInfo "White clues (correct color): " # Feedback.whiteClues}
   {System.showInfo "Clue list: "}
   {System.show Feedback.clueList}
end

%% ============================================================================
%% Test Cases
%% ============================================================================

{System.showInfo "\n=== TEST: Mastermind Game - Functional Programming ==="}

local CM1 SecretCode Guess1 RoundResult1 Feedback1 Status1 in
   %% Start game
   SecretCode = [red blue green yellow]
   CM1 = {StartGame SecretCode}
   {System.showInfo "Game started with secret code:"}
   {System.show {GetSecretCode CM1}}
   {System.showInfo "Current round: " # {GetCurrentRound CM1}}
   {System.showInfo "Remaining rounds: " # {GetRemainingRounds CM1}}
   
   %% Round 1
   {System.showInfo "\n--- Round 1 ---"}
   Guess1 = [blue red yellow orange]
   {System.showInfo "Guess: "}
   {System.show Guess1}
   RoundResult1 = {PlayRound CM1 Guess1}
   Feedback1 = RoundResult1.feedback
   {DisplayFeedback Feedback1}
   Status1 = {GetGameStatus Feedback1 {GetCurrentRound RoundResult1.newCodemaker}}
   {System.showInfo "Status: " # Status1}
   {System.showInfo "Current round: " # {GetCurrentRound RoundResult1.newCodemaker}}
   {System.showInfo "Remaining rounds: " # {GetRemainingRounds RoundResult1.newCodemaker}}
   
   %% Round 2
   {System.showInfo "\n--- Round 2 ---"}
   local Guess2 RoundResult2 Feedback2 Status2 in
      Guess2 = [red blue green yellow]
      {System.showInfo "Guess: "}
      {System.show Guess2}
      RoundResult2 = {PlayRound RoundResult1.newCodemaker Guess2}
      Feedback2 = RoundResult2.feedback
      {DisplayFeedback Feedback2}
      Status2 = {GetGameStatus Feedback2 {GetCurrentRound RoundResult2.newCodemaker}}
      {System.showInfo "Status: " # Status2}
      
      if Status2 == won then
         {System.showInfo "\n*** YOU WON! ***"}
      elseif Status2 == lost then
         {System.showInfo "\n*** YOU LOST! ***"}
         {System.showInfo "Secret code was:"}
         {System.show SecretCode}
      end
   end
end

%% Test validation
{System.showInfo "\n=== TEST: Validation ==="}
local ValidGuess InvalidGuess1 InvalidGuess2 in
   ValidGuess = [red blue green yellow]
   InvalidGuess1 = [red blue green]  % Too short
   InvalidGuess2 = [red blue green yellow orange]  % Too long
   
   {System.showInfo "Valid guess: "}
   {System.show ValidGuess}
   if {IsValidGuess ValidGuess} then
      {System.showInfo "Is valid: true"}
   else
      {System.showInfo "Is valid: false"}
   end
   
   {System.showInfo "Invalid guess (too short): "}
   {System.show InvalidGuess1}
   if {IsValidGuess InvalidGuess1} then
      {System.showInfo "Is valid: true"}
   else
      {System.showInfo "Is valid: false"}
   end
   
   {System.showInfo "Invalid guess (too long): "}
   {System.show InvalidGuess2}
   if {IsValidGuess InvalidGuess2} then
      {System.showInfo "Is valid: true"}
   else
      {System.showInfo "Is valid: false"}
   end
end