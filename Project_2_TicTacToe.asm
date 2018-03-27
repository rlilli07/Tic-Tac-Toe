TITLE Simple Calculator

; Adds, Subtracts, Multiplies, and Divides user input numbers
; DIVISION FUNCTION DOES NOT WORK

INCLUDE Irvine32.inc

.data

gameBoard			BYTE "1 | 2 | 3", 0Dh, 0Ah, "--+---+--", 0Dh, 0Ah, "4 | 5 | 6", 0Dh, 0AH, "--+---+--", 0Dh, 0ah, "7 | 8 | 9", 0

str_Welcome			BYTE "Welcome to tic-tac-toe!", 0
str_PromptPlayer	BYTE "Enter 1 to play person, 2 to play AI, or 0 to quit", 0
str_BadMove			BYTE "Bad Move", 0
str_ChoseAI			BYTE "You chose to play the AI", 0
str_ChosePerson		BYTE "You chose to play a person", 0
str_AskNextMove		BYTE "Please enter a number 1-9 for your next move", 0
str_WinnerPlayer1	BYTE "Player 1 wins!", 0
str_WinnerPlayer2	BYTE "Player 2 Wins!", 0
str_TieGame			BYTE "Tie Game!", 0
newLine				BYTE 0Dh, 0Ah, 0

movesLeft			BYTE 9
playerTurn			BYTE 1


.code

main PROC

mainPrompt:
	CALL startingPrompt							; Welcomes and prompts user for input. Gets user input and returns back into EAX
	CALL displayPlayingPersonOrAI				; Takes from EAX a player number of 1 or 2 then displays proper output for player number
	
	CMP EAX, 0
	JE done

	CMP EAX, 1									; If equal to 1 then playing person, if not 1 then playing AI
	JE playPerson								; Play person if 1 was entered
	JNE playAI									; Play AI if 2 or any other number was entered

playPerson:										; Versus a person
	CALL displayBoard							; Clears anything currently on the screen and displays the current board

	CALL getNextMove							; Requests next move, validates move, updates board.
	DEC movesLeft								; Starts with 9 moves, when a valid move is made and the board is updated the movesLeft is decremented.
	CALL checkGame								; Check if game is over or not (First to 3 x's or 3 O's)
	CALL switchPlayerTurn						; Changes which player's turn it is. If on first player then switches to second player. If Second player then switches to first.

	CMP EAX, 0									; 0 in EAX means no win, 1 means game game over
	JE playPerson								; Loops back up to play person if game is not over
	JNE endOfGameScreen							; Jumps to label that you can see final gameBoard and then prompts for the player to play ai, person, or quit.

playAI:											; Versus "AI"
	CALL displayBoard							; Clears anything currently on the screen and displays the current board
	
	CMP playerTurn, 1							; playerTurn equal to 1 is a live person, 2 is for AI
	JE livePersonsTurn							; Jumps to steps that the live player must make.
	JNE AI_Turn									; Jumps to steps that the AI must make.

livePersonsTurn:
	CALL getNextMove							; Requests next move, validates move, updates board.
	DEC movesLeft								; Starts with 9 moves, when a valid move is made and the board is updated the movesLeft is decremented.
	CALL checkGame								; Check if game is over or not (First to 3 x's or 3 O's)
	CALL switchPlayerTurn						; Changes which player's turn it is. If on first player then switches to second player. If Second player then switches to first.

	CMP EAX, 0									; 0 in EAX means no win
	JE playAI									; Loops back up to play AI if game is not over
	JNE endOfGameScreen							; Jumps to label that you can see final gameBoard and then prompts for the player to play ai, person, or quit.

AI_Turn:										
	CALL getNextAIMove							; AI selects a random number 1-9 for it's next move, validates the move, and updates board.
	DEC movesLeft								; Starts with 9 moves, when a valid move is made and the board is updated the movesLeft is decremented.
	CALL checkGame								; Check if game is over or not (First to 3 x's or 3 O's)
	CALL switchPlayerTurn						; Changes which player's turn it is. If on first player then switches to second player. If Second player then switches to first.

	CMP EAX, 0									; 0 in EAX means no win
	JE playAI									; Loops back up to play AI if game is not over
	JNE endOfGameScreen							; Jumps to label that you can see final gameBoard and then prompts for the player to play ai, person, or quit.

endOfGameScreen:
	CALL waitMsg								; Allows for final board to be displayed until users hits 'ENTER'
	CALL clrscr									; Clears the screen after user hits enter.
	CALL resetGame								; Resets the gameboard, playerTurn, and movesLeft if player decides to play a new game.
	JMP mainPrompt								; Goes back to prompt for play live player, play ai, or quit.
	
done:											;

exit											;

main ENDP										;



switchPlayerTurn PROC							; Flips the player turn from player 1 to player 2
	CMP playerTurn, 1							; 
	je player1ToPlayer2							;
	JNE player2ToPlayer1						;

player1ToPlayer2:								;
	MOV playerTurn, 2							;
	JMP return									;
	
player2ToPlayer1:								;
	MOV playerTurn, 1							;
	JMP return									;

return:											;
	ret											;

switchPlayerTurn ENDP							;


startingPrompt PROC								; Displays the welcome screen, instructs the player, reads the player input.

	MOV EDX, OFFSET str_Welcome					;
	CALL writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;

	MOV EDX, OFFSET str_PromptPlayer			;
	call writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;


	CALL ReadInt								;

	RET
startingPrompt ENDP								;


displayPlayingPersonOrAI PROC					; Writes the string based on character that user wants to play. Keeps value in EAX for comparison.
	CMP EAX, 0									; If EAX is 0 then user wants to exit program. Returns 0 back into EAX for program exit
	JE return

	CMP EAX, 1									; If 1 then playing person. If 2 then playing AI
	JE playingPerson							;
	JNE playingAI								;

playingPerson:									;
	MOV EDX, OFFSET str_ChosePerson				;
	JMP writeToScreen							;

playingAI:										;
	MOV EDX, OFFSET str_ChoseAI					;
	JMP writeToScreen							;

writeToScreen:									;
	CALL writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;

	CALL waitMsg								; Makes user press enter to play the game and have the board displayed.
	
	JMP return									;

return:											;
	RET											;

displayPlayingPersonOrAI ENDP


displayBoard PROC								; Displays the gameboard string in a 3x3 grid
	CALL Clrscr									;

	MOV EDX, OFFSET gameBoard					;
	CALL writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;

	RET											;
displayBoard ENDP								;


getNextMove PROC								; Request next move, validate move, update board.

playerMovePrompt:								;
	CALL promptNextMove							; Displays string to user for next move.
	
	CALL ReadChar								; Copies user input move character (1-9) into AL
	
	CALL validateMove							; Validates that the move can be made. Returns -1 to EAX if bad move, then reprompts.

	CMP EAX, -1									; If -1 then bad move, repeat prompt.
	JE playerMovePrompt							;
	JNE updateValidMove							; If moved is valid then move to update board to reflect player X or 0. Depends on player turn.

updateValidMove:								;
	CALL updateBoard							; Places an X or an O depending on player turn in the spot that the player chose if spot is available and correct.
	CALL return									;

return:											;
	RET											;

getNextMove ENDP								;


getNextAIMove PROC								; Logic running the AI. AI spot is chosen by random number. The spot is validated to make sure it is an ok move, if not then selects another random number.

playerMovePrompt:								;

	CALL aiChooseSpot							; Returns a character value 1-9 to the al register.
	
	CALL validateMove							; Validates that the randomly chosen move can be made

	CMP EAX, -1									; If -1 then move is a bad move and another random spot will be chosen.
	JE playerMovePrompt							; If bad random number is chosen then reprompts for new random number.
	JNE updateValidMove							; If random number has not been selected yet and no X or 0 in the spot then the board is updated to reflect AI move as 'O'

updateValidMove:								;
	CALL updateBoard							; Updates the board with the AI char of 'O'
	CALL return									;

return:											;
	RET											;

getNextAIMove ENDP


aiChooseSpot PROC								; Put character 1-9 into AL register via randomly chosen number

	MOV EAX, 9
	CALL RandomRange

	CMP EAX, 0
	JE spot1

	CMP EAX, 1
	JE spot2

	CMP EAX, 2
	JE spot3

	CMP EAX, 3
	JE spot4

	CMP EAX, 4
	JE spot5

	CMP EAX, 5
	JE spot6

	CMP EAX, 6
	JE spot7

	CMP EAX, 7
	JE spot8

	CMP EAX, 8
	JE spot9

spot1:
	MOV al, '1'
	JMP return

spot2:
	MOV al, '2'
	JMP return

spot3:
	MOV al, '3'
	JMP return

spot4:
	MOV al, '4'
	JMP return

spot5:
	MOV al, '5'
	JMP return

spot6:
	MOV al, '6'
	JMP return

spot7:
	MOV al, '7'
	JMP return

spot8:
	MOV al, '8'
	JMP return

spot9:
	MOV al, '9'
	JMP return

return:
	ret

aiChooseSpot ENDP


promptNextMove PROC								; Displays prompt for player's next move.

	MOV EDX, OFFSET str_AskNextMove				;
	CALL writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;

	RET
promptNextMove ENDP								;


validateMove PROC								; Checks the spots where 1-9 are located. Compares for number in the spot and checks user input char to see if they match. If they match the move can be made.
												; Returns spot value to the EAX register. (1-9)		58h = 'X' 4Fh = 'O'

	CMP BYTE PTR [gameBoard], al				; 1
	JE spot1									;

	CMP BYTE PTR [gameBoard+4], al				; 2
	JE spot2									;

	CMP BYTE PTR [gameBoard+8], al				; 3
	JE spot3									;

	CMP BYTE PTR [gameBoard+22], al				; 4
	JE spot4									;

	CMP BYTE PTR [gameBoard+26], al				; 5
	JE spot5									;

	CMP BYTE PTR [gameBoard+30], al				; 6
	JE spot6									;

	CMP BYTE PTR [gameBoard+44], al				; 7
	JE spot7									;

	CMP BYTE PTR [gameBoard+48], al				; 8
	JE spot8									;

	CMP BYTE PTR [gameBoard+52], al				; 9
	JE spot9									;

	JMP notFound								;

spot1:											;
	MOV EAX, 0									;
	JMP return									;

spot2:											;
	MOV EAX, 4									;
	JMP return									;

spot3:											;
	MOV EAX, 8									;
	JMP return									;

spot4:											;
	MOV EAX, 22									;
	JMP return									;

spot5:											;
	MOV EAX, 26									;
	JMP return									;

spot6:											;
	MOV EAX, 30									;
	JMP return									;

spot7:											;
	MOV EAX, 44									;
	JMP return									;

spot8:											;
	MOV EAX, 48									;
	JMP return									;

spot9:											;
	MOV EAX, 52									;
	JMP return									;

notFound:										;
	CALL displayBoard							;
	CALL displayBadMove							;
	MOV EAX, -1									;
	JMP return									;

return:											;
	ret											;

validateMove ENDP								;


displayBadMove PROC								; Displays that the move was invalid to the user.

	MOV EDX, OFFSET str_BadMove					;
	CALL writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;

	ret											;
displayBadMove ENDP


updateBoard PROC								; Takes an argument from EAX returned from validateMove
	CMP playerTurn, 1							; 1 for player1, 2 for player2
	JE markBoardAsPlayer1						; Marks an X on the playerboard
	JNE markBoardAsPlayer2						; Marks an O on the playerboard
	
markBoardAsPlayer1:								;
	MOV BYTE PTR [gameBoard+EAX], 'X'			; 'X'
	JMP return									;

markBoardAsPlayer2:								;
	MOV BYTE PTR [gameBoard+EAX], 'O'			; 'O'
	JMP return									;

return:											;
	ret											;
updateBoard ENDP								;


checkGame PROC									; Check if game is over or not (3 x's or 3 o's )	Passes a 1 back in EAX if game is a tie and is over
												; 8 Total Scenarios, check all 3 rows, check all 3 columns, check left to right corner, check right to left corner
topRow_LR:										; (Top row, left to right), Spots: 0,4,8
	MOV EAX, 0									;
	MOV EBX, 4									;
	MOV ECX, 8									;
	CALL checkThreeInRow						; This function passes a 1 into EAX for player having 3 in a row. Or a 0 into EAX if the player does not have 3 in a row.

	CMP EAX, 1									; If not 3 in a row, check next possible row for 3 in a row.
	JE gameWon									;
	
midRow_LR:										; (Mid row, Left to right), Spots: 22,26,30
	MOV EAX, 22									;
	MOV EBX, 26									;
	MOV ECX, 30									;
	CALL checkThreeInRow						;

	CMP EAX, 1									;
	JE gameWon									;

btmRow_LR:										; (Bottom row, Left to right), Spots: 44,48,52
	MOV EAX, 44									;
	MOV EBX, 48									;
	MOV ECX, 52									;
	CALL checkThreeInRow						;

	CMP EAX, 1									;
	JE gameWon									;

leftCol_TB:										; (left Column, Top to Bottom), Spots: 0,22,44
	MOV EAX, 0									;
	MOV EBX, 22									;
	MOV ECX, 44									;
	CALL checkThreeInRow						;

	CMP EAX, 1									;
	JE gameWon									;

midCol_TB:										; (Mid Column, Top to Bottom), Spots: 4,26,48
	MOV EAX, 4									;
	MOV EBX, 26									;
	MOV ECX, 48									;
	CALL checkThreeInRow						;

	CMP EAX, 1									;
	JE gameWon									;

rightCol_TB:									; (Right Column, Top to Bottom), Spots: 8,30,52
	MOV EAX, 8									;
	MOV EBX, 30									;
	MOV ECX, 52									;
	CALL checkThreeInRow						;

	CMP EAX, 1									;
	JE gameWon									;

LT_BR:											; (Left top corner to bottom right), Spots:  0,26,52
	MOV EAX, 0									;
	MOV EBX, 26									;
	MOV ECX, 52									;
	CALL checkThreeInRow						;

	CMP EAX, 1									;
	JE gameWon									;

TR_BL:											; (Right top corner to bottom left), Spots: 8,26,44
	MOV EAX, 8									;
	MOV EBX, 26									;
	MOV ECX, 44									;
	CALL checkThreeInRow						;

	CMP EAX, 1									;
	JE gameWon									;
	JNE checkTie								; If all the previous checks don't cause a game win then a tie is checked to see if any other possible moves are available.

gameWon:										;
	CALL displayGameWon							; Displays player number who won to the user.
	JMP return									;

checkTie:										;
	CMP movesLeft, 0							; If no 3 in a row is found and game is not won and movesLeft is 0 then the game is a tie game as no more moves can be made.
	JE gameTie									;
	JNE gameNotOver								; If moves left is greater than 0 then there are still moves on the board that can be made.

gameTie:										;
	CALL displayTieGame							; Displays that the game is a tie to the user.
	MOV EAX, 1									; 1 is win or tie (game over)
	JMP return									;

gameNotOver:									;
	JMP return									;

return:											;
	ret											;

checkGame ENDP									;


displayTieGame PROC								; Displays that the game is a tie to the user.

	CALL displayBoard							;

	MOV EDX, OFFSET str_TieGame					;
	CALL writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;
	JMP return									;

return:											;
	ret											;

displayTieGame ENDP								;


displayGameWon PROC								; Checks who's turn the play was that won the game. Displays that player as the winner and displays the winning gameboard.

	CMP playerTurn, 1							;
	JE player1Win								;
	JNE player2Win								;

player1Win:										;

	CALL displayBoard							;

	MOV EDX, OFFSET str_WinnerPlayer1			;
	CALL writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;
	JMP return									;

player2Win:										;
	CALL displayBoard							;

	MOV EDX, OFFSET str_WinnerPlayer2			;
	CALL writeString							;

	MOV EDX, OFFSET newline						;
	CALL writeString							;
	JMP return									;

return:											;
	ret											;

displayGameWon ENDP								;


checkThreeInRow PROC							; Pass into EAX first spot, EBX second spot, ECX third spot returns 1 to EAX if the player has 3 in a row. 0 if no 3 in a row.

	CMP playerTurn, 1							;
	JE player1_Spot1							;
	JNE player2_Spot1							;

player1_Spot1:									;
	CMP BYTE PTR [gameBoard+EAX], 'X'			;
	JNE noThreeInRow							;
	JE player1_Spot2							;

player1_Spot2:									;
	CMP BYTE PTR [gameBoard+EBX], 'X'			;
	JNE noThreeInRow							;
	JE player1_Spot3							;

player1_Spot3:									;
	CMP BYTE PTR [gameBoard+ECX], 'X'			;
	JNE noThreeInRow							;
	JE threeInRow								;


player2_Spot1:									;
	CMP BYTE PTR [gameBoard+EAX], 'O'			;
	JNE noThreeInRow							;
	JE player2_Spot2							;

player2_Spot2:									;
	CMP BYTE PTR [gameBoard+EBX], 'O'			;
	JNE noThreeInRow							;
	JE player2_Spot3							;

player2_Spot3:									;
	CMP BYTE PTR [gameBoard+ECX], 'O'			;
	JNE noThreeInRow							;
	JE threeInRow								;


noThreeInRow:									;
	MOV EAX, 0									;
	JMP return									;
	
threeInRow:										;
	MOV EAX, 1									;
	JMP return									;

return:											;
	ret											;

checkThreeInRow ENDP							;

resetGame PROC									; Resets the gameboard string to it's original value along with the player turn and moves left so that another fresh game can be played.

	MOV BYTE PTR [gameBoard], '1'				; 

	MOV BYTE PTR [gameBoard+4], '2'				;

	MOV BYTE PTR [gameBoard+8], '3'				;

	MOV BYTE PTR [gameBoard+22], '4'			;

	MOV BYTE PTR [gameBoard+26], '5'			;

	MOV BYTE PTR [gameBoard+30], '6'			;

	MOV BYTE PTR [gameBoard+44], '7'			;

	MOV BYTE PTR [gameBoard+48], '8'			;

	MOV BYTE PTR [gameBoard+52], '9'			;

	MOV playerTurn, 1
	MOV movesLeft, 9

return:
	ret
resetGame ENDP

END main										;