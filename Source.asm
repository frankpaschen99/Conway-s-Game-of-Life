; by frank paschen :)

INCLUDE Irvine32.inc
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
	GenMsg BYTE "GENERATION #", 0
	GenCount SWORD 0

	; Main game board array that will be drawn to the console
	GameBoard BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	Rowsize = ($ - GameBoard)
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			  BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		
.code
;-----------------------------------------------------
; CalculateGeneration
;
; Calculates next game board based on game's rules
; Called each gamestep
; Receives: N/A
;
; Returns: N/A
;-----------------------------------------------------
CalculateGeneration PROC

	; copy the gameboard to the backup board

	; LOOP
		; 1. Iterate through the board and calculate the # of living neighbors for each cell
		; 2. Implement GoL rules and update the backup board based on the # of living neighbors
	; Copy the backup board into the gameboard
	ret
CalculateGeneration ENDP
;-----------------------------------------------------
; GenRandomBoard
;
; Sets random cells in the gameboard to living or dead.
; Called before first generation
; Receives: N/A
;
; Returns: N/A
;-----------------------------------------------------
GenRandomBoard PROC
	; LOOP
		; 1. Iterate through the game board
		; 2. Generate a number between 0 and 1 (inclusive)
		; 3. Set current cell to random number
		ret
GenRandomBoard ENDP
;-----------------------------------------------------
; DrawGameBoard
;
; Uses cursor to print the gameboard to the console.
; Called immediately after CalculateGeneration
; Receives: N/A
;
; Returns: N/A
;-----------------------------------------------------
DrawGameBoard PROC
	; LOOP
		; 1. Iterate through the first row of the game board
		; 2. Move cursor to top left of board
		; 3. Draw character based on value of gameboard at that index
		; 4. Move cursor to the left one

		; this might not be right lol
		; we're using ROW-MAJOR ORDER I THINK
		; possibly do each row at a time, increment Y coordinate for Gotoxy each loop

		; possibly call GetValueAtCoords using dh and dl

	mov dh, 0
	mov dl, 0
	mov ecx, 20
	L1:
		call GetValueAtCoords	; al = result

		call WriteInt	; will draw ascii characters with colors instead of ints
		inc dl
	loop L1

	ret
DrawGameBoard ENDP
;-----------------------------------------------------
; IncrementGeneration
;
; Prints and increments the generation count.
; Called immediately after CalculateGeneration
; Receives: N/A
;
; Returns: N/A
;-----------------------------------------------------
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
;-----------------------------------------------------
; GetValueAtCoords
;
; Returns value found at index in gameboard.
; Receives: dh = y coordinate
;			dl = x coordinate
; 
; Returns: al = value at coordinates in array (zero indexed)
;-----------------------------------------------------
GetValueAtCoords PROC USES esi ebx edx
	mov eax, 0
	; store array offset in memory
	mov ebx, OFFSET GameBoard ; table offset

	; multiply RowSize and y coordinate
	mov al, RowSize
	mul dh	; result of AL * DH stored in AX

	add ebx, eax ; row offset

	; add offset and x coordinate to get [X,Y] in array
	movzx esi, dl
	mov al, [ebx + esi] ; al = result

	ret
GetValueAtCoords ENDP
;-----------------------------------------------------
; main
;
; manages timing and procedure calls 
;-----------------------------------------------------
main PROC
	call DrawGameBoard	; will be called on a delay

	invoke ExitProcess,0
main endp
end main