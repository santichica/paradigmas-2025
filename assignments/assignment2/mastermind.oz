%% ============================================================================
%% MastermindGame Class
%% Main game controller that manages the overall game flow
%% ============================================================================
%% Color enumeration - valid colors in the game
%% Type: Color :: red | blue | green | yellow | orange | purple
%% ============================================================================
class MastermindGame
   attr codemaker codebreaker currentRound maxRounds gameStatus
   
   meth init(CodemakerObj CodebreakerObj)
      %% Initialize a new Mastermind game
      %% Input: CodemakerObj :: CodeMaker - Object implementing codemaker behavior
      %%        CodebreakerObj :: CodeBreaker - Object implementing codebreaker behavior
      %% Side effects: Initializes game state, sets maxRounds to 12
      %% Postcondition: Game ready to start, gameStatus = 'ready'
      %% Your code here
   end
   
   meth startGame(?Result)
      %% Starts a new game session
      %% Input: None
      %% Output: Result :: Bool - true if game started successfully, false otherwise
      %% Side effects: Resets game state, generates new secret code
      %% Precondition: Game must be in 'ready' or 'finished' state
      %% Postcondition: Game in 'playing' state, currentRound = 1
      %% Your code here
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
      %% Your code here
   end
   
   meth getGameStatus(?Result)
      %% Returns current game status
      %% Input: None
      %% Output: Result :: GameStatus - Current status of the game
      %%         GameStatus :: 'ready' | 'playing' | 'won' | 'lost' | 'finished'
      %% Your code here
   end
   
   meth getCurrentRound(?Result)
      %% Returns current round number
      %% Input: None
      %% Output: Result :: Int - Current round number (1-12)
      %% Your code here
   end
   
   meth getRemainingRounds(?Result)
      %% Returns number of rounds left
      %% Input: None
      %% Output: Result :: Int - Number of rounds remaining (0-11)
      %% Your code here
   end
   
end

%% ============================================================================
%% CodeMaker Class  
%% Handles secret code generation and feedback calculation
%% ============================================================================
class CodeMaker
   attr secretCode availableColors
   
   meth init()
      %% Initialize codemaker with available colors
      %% Input: None
      %% Side effects: Sets availableColors to [red blue green yellow orange purple]
      %% Postcondition: Ready to generate secret codes
      %% Your code here
   end
   
   meth init(CustomColors)
      %% Initialize codemaker with custom color set
      %% Input: CustomColors :: [Color] - List of available colors (must have > 3 colors)
      %% Side effects: Sets availableColors to CustomColors
      %% Your code here
   end
   
   meth generateSecretCode(?Result)
      %% Generates a new random secret code
      %% Input: None
      %% Output: Result :: Bool - true if code generated successfully
      %% Side effects: Sets new secretCode (4 colors, repetitions allowed)
      %% Postcondition: secretCode contains exactly 4 valid colors
      %% Note: Uses random selection, colors may repeat
      %% Your code here
   end
   
   meth setSecretCode(Code ?Result)
      %% Sets a specific secret code
      %% Input: Code :: [Color] - List of exactly 4 valid colors
      %% Output: Result :: Bool - true if code was set successfully
      %% Validation: Code must have exactly 4 elements, all valid colors
      %% Your code here
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
      %% Your code here
   end
   
   meth getSecretCode(?Result)
      %% Returns the current secret code (for testing/debugging)
      %% Input: None
      %% Output: Result :: [Color] | nil - Secret code or nil if not set
      %% Note: Should only be used for testing, breaks game in normal play
      %% Your code here
   end
   
   meth getAvailableColors(?Result)
      %% Returns list of colors that can be used in codes
      %% Input: None
      %% Output: Result :: [Color] - List of available colors for the game
      %% Your code here
   end
   
   meth isValidCode(Code ?Result)
      %% Validates if a code follows game rules
      %% Input: Code :: [Color] - Code to validate
      %% Output: Result :: Bool - true if code is valid for this game
      %% Validation: Exactly 4 colors, all from available color set
      %% Your code here
   end
end

%% ============================================================================
%% CodeBreaker Class
%% Handles guess generation and strategy for breaking codes
%% ============================================================================  
class CodeBreaker
   attr guessHistory feedbackHistory strategy availableColors
   
   meth init(Strategy)
      %% Initialize codebreaker with a specific strategy
      %% Input: Strategy :: GuessingStrategy - Strategy for making guesses
      %%        GuessingStrategy :: 'random' | 'systematic' | 'smart' | 'human'
      %% Side effects: Initializes strategy and available colors
      %% Postcondition: Ready to make guesses
      %% Your code here
   end
   
   meth init()
      %% Initialize codebreaker with default random strategy
      %% Input: None
      %% Side effects: Sets strategy to 'random', loads default colors
      %% Your code here
   end
   
   meth makeGuess(?Result)
      %% Generates next guess based on current strategy and history
      %% Input: None
      %% Output: Result :: [Color] - List of 4 colors representing the guess
      %% Side effects: Updates internal guess tracking
      %% Strategy behavior:
      %%   - 'random': Random valid combination
      %%   - 'systematic': Tries all combinations systematically  
      %%   - 'smart': Uses feedback to eliminate possibilities
      %%   - 'human': Prompts user for input
      %% Your code here
   end
   
   meth makeGuess(SuggestedGuess ?Result)
      %% Makes a specific guess (overrides strategy)
      %% Input: SuggestedGuess :: [Color] - Specific guess to make
      %% Output: Result :: Bool - true if guess was accepted and recorded
      %% Note: If SuggestedGuess is invalid, return false
      %% Side effects: Records guess in history
      %% Your code here
   end
   
   meth receiveFeedback(Guess Feedback)
      %% Receives and processes feedback for a guess
      %% Input: Guess :: [Color] - The guess that was evaluated
      %%        Feedback :: FeedbackResult - Feedback received from codemaker
      %% Side effects: Updates internal state, refines strategy if applicable
      %% Note: Smart strategies use this to eliminate future possibilities
      %% Your code here
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
   end
   
   meth setStrategy(NewStrategy ?Result)
      %% Changes the guessing strategy
      %% Input: NewStrategy :: GuessingStrategy - New strategy to use
      %% Output: Result :: Bool - true if strategy was changed successfully
      %% Side effects: Updates strategy, may reset internal state
      %% Your code here
   end
   
   meth getStrategy(?Result)
      %% Returns current guessing strategy
      %% Input: None
      %% Output: Result :: GuessingStrategy - Current strategy being used
      %% Your code here
   end
   
   meth resetHistory()
      %% Clears guess and feedback history (for new game)
      %% Input: None
      %% Output: None (void)
      %% Side effects: Clears guessHistory and feedbackHistory
      %% Your code here
   end
   
   meth getRemainingPossibilities(?Result)
      %% Returns estimated number of remaining possible codes (smart strategy only)
      %% Input: None
      %% Output: Result :: Int | nil - Number of possibilities or nil if not applicable
      %% Note: Only meaningful for 'smart' strategy, returns nil for others
      %% Your code here
   end
end

end