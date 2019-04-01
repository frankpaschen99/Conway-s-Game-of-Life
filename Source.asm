; by frank paschen :)

INCLUDE Irvine32.inc
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
	GenMsg BYTE "GENERATION #", 0
	GenCount WORD 0
.code
;-------------
;  CalculateGeneration
;  Returns nothing
;  Called each gamestep
;-------------
CalculateGeneration PROC

	; copy the gameboard to the backup board

	; LOOP
		; 1. Iterate through the board and calculate the # of living neighbors for each cell
		; 2. Implement GoL rules and update the backup board based on the # of living neighbors
	; Copy the backup board into the gameboard
CalculateGeneration ENDP

;-------------
;  GenRandomBoard
;  Returns nothing
;  Sets random cells in the gameboard to living or dead.
;  Called before first generation
;-------------
GenRandomBoard PROC
	; LOOP
		; 1. Iterate through the game board
		; 2. Generate a number between 0 and 1 (inclusive)
		; 3. Set current cell to random number
GenRandomBoard ENDP

;-------------
;  DrawGameBoard
;  Returns nothing
;  Uses cursor to print the gameboard to the console.
;  Called immediately after CalculateGeneration
;-------------
DrawGameBoard PROC
	; LOOP
		; 1. Iterate through the first row of the game board
		; 2. Move cursor to top left of board
		; 3. Draw character based on value of gameboard at that index
		; 4. Move cursor to the left one

		; this might not be right lol
		; we're using ROW-MAJOR ORDER I THINK
		; possibly do each row at a time, increment Y coordinate for Gotoxy each loop
		

DrawGameBoard ENDP


;-------------
;  IncrementGeneration
;  Returns nothing
;  Prints and increments the generation count
;  Called immediately after CalculateGeneration
;-------------
IncrementGeneration PROC
	; increment gen count
	inc GenCount
	; move cursor to top left
	mov dh, 0	; Y
	mov dl, 0	; X
	call Gotoxy
	; print Generation #:
	mov edx, OFFSET GenMsg
	call WriteString      
	; print actual gen count
	mov eax, DWORD PTR GenCount
	call WriteInt
	ret
IncrementGeneration ENDP

;-------------
; MAIN PROCEDURE
;-------------
main PROC


;	call IncrementGeneration

;	call DumpRegs

	; main procedure will handle timing and procedure calls

	invoke ExitProcess,0
main endp
end main