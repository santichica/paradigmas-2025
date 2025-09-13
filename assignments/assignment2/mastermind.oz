%% ============================================================================
%% MastermindGame Class
%% Main game controller that manages the overall game flow
%% ============================================================================
%% Color enumeration - valid colors in the game
%% Type: Color :: red | blue | green | yellow | orange | purple
%% ============================================================================
declare MastermindGame CodeBreaker CodeMaker

class MastermindGame
   attr codemaker codebreaker currentRound maxRounds gameStatus
   
   meth init(CodemakerObj CodebreakerObj)
      %% Initialize a new Mastermind game
      %% Input: CodemakerObj :: CodeMaker - Object implementing codemaker behavior
      %%        CodebreakerObj :: CodeBreaker - Object implementing codebreaker behavior
      %% Side effects: Initializes game state, sets maxRounds to 12
      %% Postcondition: Game ready to start, gameStatus = 'ready'
      codemaker := CodemakerObj
      codebreaker := CodebreakerObj
      currentRound := 0
      maxRounds := 12
      gameStatus := ready
   end
   
   meth startGame(?Result)
      %% Starts a new game session
      %% Input: None
      %% Output: Result :: Bool - true if game started successfully, false otherwise
      %% Side effects: Resets game state, generates new secret code
      %% Precondition: Game must be in 'ready' or 'finished' state
      %% Postcondition: Game in 'playing' state, currentRound = 1
      if @gameStatus == ready orelse @gameStatus == finished then
         local CodeGenerated in
            {@codemaker generateSecretCode(CodeGenerated)}
            if CodeGenerated then
               currentRound := 1
               gameStatus := playing
               {@codebreaker resetHistory}
               Result = true
            else
               Result = false
            end
         end
      else
         Result = false
      end
   end
   
   meth playRound(?Result)
      %% Executes one round of the game (guess + feedback)
      %% Input: None  
      %% Output: Result :: GameRoundResult - Record containing round results
      %%         GameRoundResult = result(
      %%            guess: [Color]           % The guess made this round
      %%            feedback: [FeedbackClue] % Black and white Clues received  
      %%            roundNumber: Int         % Current round number
      %%            gameWon: Bool            % Whether game was won this round
      %%            gameOver: Bool           % Whether game is over
      %%         )
      %% Precondition: Game must be in 'playing' state
      %% Side effects: Increments currentRound, may change gameStatus
      if @gameStatus == playing then
         local Guess BoolGuess Feedback IsCorrect GameWon GameOver Strategy in
            {@codebreaker getStrategy(Strategy)}
            if Strategy == human then
               {@codebreaker generateHumanGuess(Guess)}
            else
               {@codebreaker generateRandomGuess(Guess)}
            end
            {@codebreaker makeGuess(Guess BoolGuess)}
            {@codemaker evaluateGuess(Guess Feedback)}
            {@codebreaker receiveFeedback(Guess Feedback)}
            IsCorrect = Feedback.isCorrect
            if IsCorrect then
               gameStatus := won
               GameWon = true
               GameOver = true
            elseif @currentRound >= @maxRounds then
               gameStatus := lost
               GameWon = false
               GameOver = true
            else
               
               GameWon = false
               GameOver = false
            end
            Result = result(guess: Guess feedback: Feedback.clueList 
                                 roundNumber: @currentRound gameWon: GameWon gameOver: GameOver)
            currentRound := @currentRound + 1
         end
      else
         Result = result(guess: nil feedback: nil roundNumber: @currentRound gameWon: false gameOver: false)
      end
   end
   
   meth getGameStatus(?Result)
      %% Returns current game status
      %% Input: None
      %% Output: Result :: GameStatus - Current status of the game
      %%         GameStatus :: 'ready' | 'playing' | 'won' | 'lost' | 'finished'
      Result = @gameStatus
   end
   
   meth getCurrentRound(?Result)
      %% Returns current round number
      %% Input: None
      %% Output: Result :: Int - Current round number (1-12)
      Result = @currentRound
   end
   
   meth getRemainingRounds(?Result)
      %% Returns number of rounds left
      %% Input: None
      %% Output: Result :: Int - Number of rounds remaining (0-11)
      Result = @maxRounds - @currentRound
   end
   
end

%% ============================================================================
%% CodeMaker Class  
%% Handles secret code generation and feedback calculation
%% ============================================================================
declare
class CodeMaker
   attr secretCode availableColors
   
   meth init() 
      %% Initialize codemaker with available colors
      %% Input: None
      %% Side effects: Sets availableColors to [red blue green yellow orange purple]
      %% Postcondition: Ready to generate secret codes
      availableColors := [red blue green yellow orange purple]
      secretCode := nil
   end
   
   meth generateSecretCode(?Result)
      %% Generates a new random secret code
      %% Input: None
      %% Output: Result :: Bool - true if code generated successfully
      %% Side effects: Sets new secretCode (4 colors, repetitions allowed)
      %% Postcondition: secretCode contains exactly 4 valid colors
      %% Note: Uses random selection, colors may repeat
      local N C in
         {NewCell ~1 N}
         {NewCell ~1 C}
         for I in 1..4 do
            N := (({OS.rand} mod {List.length @availableColors}) + 1)
            C := {List.nth @availableColors @N}
            if I == 1 then
               secretCode := [@C]
            else
               secretCode := {List.flatten @secretCode | [@C]}
            end
         end
      end
      Result = true
   end
   
   meth setSecretCode(Code ?Result)
      %% Sets a specific secret code
      %% Input: Code :: [Color] - List of exactly 4 valid colors
      %% Output: Result :: Bool - true if code was set successfully
      %% Validation: Code must have exactly 4 elements, all valid colors
      local Valid in
         {self isValidCode(Code Valid)}
         if Valid then
            secretCode := Code
            Result = true
         else
            Result = false
         end
      end
   end
   
   meth evaluateGuess(Guess ?Result)
      %% Evaluates a guess against the secret code
      %% Input: Guess :: [Color] - List of exactly 4 colors representing the guess
      %% Output: Result :: FeedbackResult - Detailed feedback for the guess
      %%         FeedbackResult = feedback(
      %%            blackClues: Int            % Number of correct color & position
      %%            whiteClues: Int            % Number of correct color, wrong position  
      %%            totalCorrect: Int          % blackClues + whiteClues
      %%            isCorrect: Bool            % true if guess matches secret code exactly
      %%            ClueList: [FeedbackClue]   % List of individual Clue results
      %%         )
      %%         FeedbackClue :: black | white | none
      local BCounter WCounter SizeCode ClueList IsCorrect
      in
         {NewCell 0 BCounter}
         {NewCell 0 WCounter}
         ClueList = {NewCell nil}
         if @secretCode == nil then
            Result = feedback(blackClues:0 whiteClues:0 totalCorrect:0 isCorrect:false clueList:nil)
         else
            SizeCode = {List.length @secretCode}

            for I in 1..SizeCode do
               if {List.nth @secretCode I}=={List.nth Guess I} then
                  ClueList := {List.append @ClueList [black]}
                  BCounter := @BCounter + 1
               elseif {List.member {List.nth Guess I} @secretCode} then
                  ClueList := {List.append @ClueList [white]}
                  WCounter := @WCounter + 1
               else
                  ClueList := {List.append @ClueList [none]}
               end
            end
            IsCorrect = (@secretCode == Guess)
            Result = feedback(blackClues:@BCounter whiteClues:@WCounter 
                                    totalCorrect:(@BCounter+@WCounter) isCorrect:IsCorrect
                                    clueList:@ClueList)
         end
      end
   end
   
   meth getSecretCode(?Result)
      %% Returns the current secret code (for testing/debugging)
      %% Input: None
      %% Output: Result :: [Color] | nil - Secret code or nil if not set
      %% Note: Should only be used for testing, breaks game in normal play
      Result = @secretCode
   end
   
   meth getAvailableColors(?Result)
      %% Returns list of colors that can be used in codes
      %% Input: None
      %% Output: Result :: [Color] - List of available colors for the game
      Result = @availableColors
   end
   
   meth isValidCode(Code ?Result)
      %% Validates if a code follows game rules
      %% Input: Code :: [Color] - Code to validate
      %% Output: Result :: Bool - true if code is valid for this game
      %% Validation: Exactly 4 colors, all from available color set
      if {And ({List.length Code} == 4) {List.forAll Code fun {$ C} {List.member C @availableColors} end}} then
         Result = true
      else
         Result = false
      end
   end
end



%% ============================================================================
%% CodeBreaker Class
%% Handles guess generation and strategy for breaking codes
%% ============================================================================  
declare class CodeBreaker
   attr guessHistory feedbackHistory strategy availableColors nextHumanGuess
   
   meth init(Strategy)
      %% Initialize codebreaker with a specific strategy
      %% Input: Strategy :: GuessingStrategy - Strategy for making guesses
      %%        GuessingStrategy :: 'random' | 'systematic' | 'smart' | 'human'
      %% Side effects: Initializes strategy and available colors
      %% Postcondition: Ready to make guesses
      %% Your code here
      availableColors := [red blue green yellow orange purple]
      strategy := Strategy
      guessHistory := nil
      feedbackHistory := nil
      nextHumanGuess := nil
   end
      
   meth makeGuess(SuggestedGuess ?Result)  
      %% Makes a specific guess (overrides strategy)
      %% Input: SuggestedGuess :: [Color] - Specific guess to make
      %% Output: Result :: Bool - true if guess was accepted and recorded
      %% Note: If SuggestedGuess is invalid, return false
      %% Side effects: Records guess in history
      local Valid in
         {self isValidCode(SuggestedGuess Valid)}
         if Valid then
            guessHistory := {List.append @guessHistory [SuggestedGuess]}
            Result = true
         else
            Result = false
         end
      end
   end

   meth generateRandomGuess(?Guess)
      local Colors N G in
      N = {NewCell ~1}
      Colors = @availableColors
      G = {NewCell nil}
         for I in 1..4 do
            N := (({OS.rand} mod {List.length Colors}) + 1)
            G := @G | [{List.nth Colors @N}]
         end
         Guess = {List.flatten @G}
      end
   end

   meth setNextHumanGuess(Guess)
      %% Sets the next guess for human strategy
      %% Input: Guess :: [Color] - The guess to be used next
      %% Side effects: Updates internal state to use this guess next
      %% Note: Only applicable if strategy is 'human'
      nextHumanGuess := Guess
   end

   meth generateHumanGuess(?Guess)
      %% Generates the next guess for human strategy
      %% Input: None
      %% Output: Guess :: [Color] - The guess to be made
      %% Note: Uses the guess set by setNextHumanGuess, or defaults if none set
      local Valid in
         {self isValidCode(@nextHumanGuess Valid)}
         if Valid then
            Guess = @nextHumanGuess
            nextHumanGuess := nil
         else
            Guess = [red red red red] % Default guess if none set or invalid
         end
      end
   end
   
   meth receiveFeedback(Guess Feedback)
      %% Receives and processes feedback for a guess
      %% Input: Guess :: [Color] - The guess that was evaluated
      %%        Feedback :: FeedbackResult - Feedback received from codemaker
      %% Side effects: Updates internal state, refines strategy if applicable
      %% Note: Smart strategies use this to eliminate future possibilities
      %% Your code here
      feedbackHistory := record(guess: Guess feedback: Feedback roundNumber: {Length @feedbackHistory} + 1) | @feedbackHistory 
   end
   
   meth getGuessHistory(?Result)
      %% Returns all guesses made so far
      %% Input: None  
      %% Output: Result :: [GuessRecord] - History of all guesses
      %%         GuessRecord = record(
      %%            guess: [Color]
      %%            feedback: FeedbackResult  
      %%            roundNumber: Int
      %%         )
      %% Your code here
      Result = @guessHistory
   end
   
   meth setStrategy(NewStrategy ?Result)
      %% Changes the guessing strategy
      %% Input: NewStrategy :: GuessingStrategy - New strategy to use
      %% Output: Result :: Bool - true if strategy was changed successfully
      %% Side effects: Updates strategy, may reset internal state
      %% Your code here
      local Strategies Valid in
         Strategies = [random systematic smart human]
         Valid = {List.member NewStrategy Strategies}
         if Valid then
            strategy := NewStrategy
            Result = true
         else
            Result = false
         end
      end
   end
   
   meth getStrategy(?Result)
      %% Returns current guessing strategy
      %% Input: None
      %% Output: Result :: GuessingStrategy - Current strategy being used
      Result = @strategy
   end
   
   meth resetHistory()
      %% Clears guess and feedback history (for new game)
      %% Input: None
      %% Output: None (void)
      %% Side effects: Clears guessHistory and feedbackHistory
      guessHistory := nil
      feedbackHistory := nil
   end
   
   meth getRemainingPossibilities(?Result)
      %% Returns estimated number of remaining possible codes (smart strategy only)
      %% Input: None
      %% Output: Result :: Int | nil - Number of possibilities or nil if not applicable
      %% Note: Only meaningful for 'smart' strategy, returns nil for others
      local Possibilities in
         if @strategy == smart then
            %% Por defecto, todas las combinaciones posibles (6 colores, 4 posiciones, repeticiones permitidas)
            Possibilities = {Pow {Length @availableColors} 4}
            %% Si tienes un historial y lógica de descarte, aquí puedes reducir Possibilities
            Result = Possibilities
         else
            Result = nil
         end
      end
   end

   
   meth isValidCode(Code ?Result)
      local Colors ValidLength ValidColors in
         Colors = @availableColors
         ValidLength = ({List.length Code} == 4)
         ValidColors = true
         for I in 1..{List.length Code} do
            if ({List.member {List.nth Code I} Colors}) == false then
               ValidColors = false
            end
         end
         Result = ValidLength andthen ValidColors
      end
   end
end


%% ============================================================================
{System.showInfo "Strategy: random"}
{System.showInfo "Mastermind Game test cases with random codebreaker"}
local MastermindGame1 CodeMaker1 CodeBreaker1 StartGame1 GameStatus1 RoundResult1 RemainingRounds1 FinishGame in
   CodeMaker1 = {New CodeMaker init()}
   CodeBreaker1 = {New CodeBreaker init(random)}
   MastermindGame1 = {New MastermindGame init(CodeMaker1 CodeBreaker1)}
   %% Start a new game
   {MastermindGame1 startGame(StartGame1)}
   {MastermindGame1 getGameStatus(GameStatus1)}
   {System.showInfo "----- Juego iniciado -----"} % should be true
   {System.showInfo "Status: " # GameStatus1} % should be 'playing'
   local CurrentRound in
      {MastermindGame1 getCurrentRound(CurrentRound)}
      {System.showInfo "Inicia en ronda: " # CurrentRound} % should be 1
   end


   %% Play a round
   {MastermindGame1 playRound(RoundResult1)}
   {System.show RoundResult1} % should show guess and feedback

   %% Get current round
   local CurrentRound in
      {MastermindGame1 getCurrentRound(CurrentRound)}
      {System.showInfo "Ronda actual: " # CurrentRound} % should be 2
   end

   %% Get remaining rounds
   {MastermindGame1 getRemainingRounds(RemainingRounds1)}
   {System.showInfo "Rondas restantes: " # RemainingRounds1} % should be 10

   %% Repeat playing rounds until game ends
   FinishGame = {NewCell false}
   for I in 1..10 do
      if @FinishGame == false then
         local RoundResultForLoop CurrentRoundForLoop RemainingRoundsForLoop in
            {MastermindGame1 playRound(RoundResultForLoop)}
            {System.showInfo "Resultado de la ronda: "}
            {System.show RoundResultForLoop}
            {MastermindGame1 getGameStatus(GameStatus1)}
            {System.showInfo "Status: " # GameStatus1}
            if GameStatus1 == won orelse GameStatus1 == lost then
               {System.showInfo "----- Juego terminado -----"}
               FinishGame := true
            end
            {MastermindGame1 getCurrentRound(CurrentRoundForLoop)}
            {System.showInfo "Ronda actual: " # CurrentRoundForLoop}
            {MastermindGame1 getRemainingRounds(RemainingRoundsForLoop)}
            {System.showInfo "Rondas restantes: " # RemainingRoundsForLoop}
         end
      else
         {System.showInfo "----- Juego terminado -----"}
      end
   end
   {System.showInfo "----- Juego terminado -----"}
end

%% ============================================================================
{System.showInfo "Strategy: human"}
{System.showInfo "Mastermind Game test cases with human codebreaker"}
%% Run from here to initiate a new game session
declare
CodeMaker2 CodeBreaker2 MastermindGame2 StartGame2 GameStatus2 FinishGame
CodeMaker2 = {New CodeMaker init()}
CodeBreaker2 = {New CodeBreaker init(human)}
MastermindGame2 = {New MastermindGame init(CodeMaker2 CodeBreaker2)}
{MastermindGame2 startGame(StartGame2)}
{MastermindGame2 getGameStatus(GameStatus2)}
{System.showInfo "----- Juego iniciado -----"}
{System.showInfo "Status: " # GameStatus2}
FinishGame = {NewCell false}

%% Round Iterator: Play rounds by replacing INPUT with desired guesses check the System info for more info
% Always run the local scope below (from line 499 to line 523), after replacing INPUT with your guesses
local INPUT RoundResult1 Feedback1 GameStatus1 CurrentRound1 RemainingRounds1 in
   if @FinishGame == false then
      INPUT = [green green orange yellow] % Replace this with your guess
      {System.showInfo "Iniciando ronda con entrada: "}
      {System.show INPUT}
      {CodeBreaker2 setNextHumanGuess(INPUT)}
      {MastermindGame2 playRound(RoundResult1)}
      {System.showInfo "Resultado de la ronda :"}
      {System.show RoundResult1}
      Feedback1 = RoundResult1.feedback
      {System.showInfo "Feedback ronda : " }
      {System.show Feedback1}
      {MastermindGame2 getGameStatus(GameStatus1)}
      if GameStatus1 == won orelse GameStatus1 == lost then
         {System.showInfo "Status: " # GameStatus1}
         {System.showInfo "----- Juego terminado -----"}
         FinishGame := true
      end
      if GameStatus1 == playing then
         {System.showInfo "Status: " # GameStatus1}
         {MastermindGame2 getCurrentRound(CurrentRound1)}
         {MastermindGame2 getRemainingRounds(RemainingRounds1)}
         {System.showInfo "Ronda actual: " # CurrentRound1}
         {System.showInfo "Rondas restantes: " # RemainingRounds1}
      end
   else
      {System.showInfo "----- Juego terminado -----"}
   end

   
   if GameStatus1 == won orelse GameStatus1 == lost then FinishGame := true end
end