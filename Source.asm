; Conway's Game of Life
; by frank paschen :)

INCLUDE Irvine32.inc
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
	genMsg BYTE "GENERATION #", 0
	genCount SBYTE 0

	; Main game board array that will be drawn to the console
	GameBoard BYTE 20 DUP(0)
	Rowsize = ($ - GameBoard)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)
			  BYTE 20 DUP(0)

;-----------------------------------------------------
; CalculateGeneration
;
; Calculates next game board based on game's rules
; Called each gamestep
; Receives: N/A
;
; Returns: N/A
;-----------------------------------------------------
cellState BYTE 0	; 1 or 0, living or dead
yCoord4 DWORD 0
xCoord4 DWORD 0
count4 DWORD 0
liveCount2 DWORD 0
.code
CalculateGeneration PROC

	; copy the gameboard to the backup board

	; LOOP
		; 1. Iterate through the board and calculate the # of living neighbors for each cell
		; 2. Implement GoL rules and update the backup board based on the # of living neighbors
	; Copy the backup board into the gameboard
	mov ecx, 20

	L1:
		mov count4, ecx
		mov ecx, 20
		L2:

			mov edx, yCoord4 ; y
			mov eax, xCoord4 ; x
			;call GetValueAtCoords ; result stored in al
			;mov cellState, al	; used for implementing rules

			call CalcLivingNeighbors
			call DumpRegs
			;mov liveCount2, ebx


			inc xCoord4
		loop L2
			mov ecx, count4
	loop L1
	
	mov yCoord4, 0
	mov xCoord4, 0

	ret
CalculateGeneration ENDP

; eax = x, edx = y
.data
liveCount BYTE 0	; stores # of living neighbors for each cell
originalX DWORD 0
originalY DWORD 0
.code
CalcLivingNeighbors PROC
	mov ebx, 0
	mov originalX, eax
	mov originalY, edx

	
	mov eax, originalX
	mov edx, originalY
	call GetBottomLeft
	.IF (al == 0) || (al == 1)
		add liveCount, al
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetBottomCenter
	.IF (al == 0) || (al == 1)
		add liveCount, al
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetBottomRight
	.IF (al == 0) || (al == 1)
		add liveCount, al
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetRight
	.IF (al == 0) || (al == 1)
		add liveCount, al
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetLeft
	.IF (al == 0) || (al == 1)
		add liveCount, al
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetTopLeft
	.IF (al == 0) || (al == 1)
		add liveCount, al
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetTopCenter
	.IF (al == 0) || (al == 1)
		add liveCount, al
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetTopRight
	.IF (al == 0) || (al == 1)
		add liveCount, al
	.ENDIF


	mov ebx, DWORD PTR liveCount

	ret
CalcLivingNeighbors ENDP

; receives edx=y eax=x 
; returns al
.code
GetBottomLeft PROC
	dec eax
	js L1
	inc edx
	call GetValueAtCoords

	L1:
	ret
GetBottomLeft ENDP

GetBottomCenter PROC
	inc edx
	call GetValueAtCoords
	ret
GetBottomCenter ENDP

GetBottomRight PROC
	inc eax
	inc edx
	call GetValueAtCoords
	ret
GetBottomRight ENDP

GetLeft PROC
	dec eax
	js L1	; return if eax is negative (moving off the gameboard)
	call GetValueAtCoords
	L1:
	ret
GetLeft ENDP

GetRight PROC
	inc eax
	call GetValueAtCoords
	ret
GetRight ENDP

GetTopLeft PROC
	dec eax
	js L1
	dec edx
	js L1
	call GetValueAtCoords
	
	L1:
	ret
GetTopLeft ENDP

GetTopCenter PROC
	dec edx
	js L1
	call GetValueAtCoords
	L1:
	ret
GetTopCenter ENDP

GetTopRight PROC
	inc eax
	dec edx
	js L1
	call GetValueAtCoords

	L1:
	ret
GetTopRight ENDP

;-----------------------------------------------------
; GenRandomBoard
;
; Sets random cells in the gameboard to living or dead.
; Called before first generation
; Receives: N/A
;
; Returns: N/A
;-----------------------------------------------------
.data
	yCoord3 DWORD 0
	xCoord3 DWORD 0
	count3 DWORD 0
	randVal DWORD 0
.code
GenRandomBoard PROC
	mov ecx, 20

	L1:	; outer loop
		mov count3, ecx
		mov ecx, 20
		L2: ; inner loop

			mov edx, yCoord3	; y
			mov eax, xCoord3 ; x

			; preserve eax to use RandomRange
			push eax
			mov eax, 2

			call RandomRange
			mov randVal, eax
			pop eax

			.IF randVal > 0
				call InvertValueAtCoords
			.ENDIF

			call GetValueAtCoords

			inc xCoord3
		loop L2
			mov ecx, count3
	loop L1
	
	mov yCoord3, 0
	mov xCoord3, 0

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

.data
	yCoord DWORD 0
	xCoord DWORD 0
	count DWORD 0
	temp BYTE ?
.code
DrawGameBoard PROC
	call Clrscr
	call Crlf
	mov ecx, 20

	L1:	; outer loop
		mov count, ecx
		mov ecx, 20
		L2: ; inner loop

			mov edx, yCoord	; y
			mov eax, xCoord	; x

			call GetValueAtCoords
			
			; TODO: Color these, possible find better ASCII characters
			mov temp, al
			.IF temp == 0
				mov al, 178
			.ELSEIF temp == 1
				mov al, 176
			.ENDIF

			call WriteChar

			inc xCoord

		loop L2
			mov ecx, count
			call Crlf
	loop L1

	mov yCoord, 0
	mov xCoord, 0
	
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
IncrementGeneration PROC USES eax edx
	mov eax, 0
	; increment gen count
	inc genCount
	; move cursor to top left
	mov dh, 0	; Y
	mov dl, 0	; X
	call Gotoxy
	; print Generation #:
	mov edx, OFFSET genMsg
	call WriteString      
	; print actual gen count
	mov al, genCount
	mov ah, 0

	call WriteDec

	ret
IncrementGeneration ENDP
;-----------------------------------------------------
; GetValueAtCoords
;
; Returns value found at index in gameboard.
; Receives: edx = y coordinate
;			eax = x coordinate
; 
; Returns: al = value at coordinates in array (zero indexed)
;-----------------------------------------------------
.data
	yIndex DWORD ?
	xIndex DWORD ?
.code
GetValueAtCoords PROC USES esi ebx
	mov yIndex, edx
	mov xIndex, eax

	; store array offset in memory
	mov ebx, OFFSET GameBoard ; table offset
	; multiply RowSize and y coordinate
	mov eax, RowSize
	mul yIndex	; result of AL * DH stored in EAX
	add ebx, eax ; row offset
	; add offset and x coordinate to get [X,Y] in array
	mov esi, xIndex
	mov ah, 0	; clear top half of reg NOTE: ONLY NECESSARY FOR WRITEINT PROC. We can just test al for other purposes
	mov al, [ebx + esi] ; al = result

	ret
GetValueAtCoords ENDP

;-----------------------------------------------------
; GetValueAtCoords
;
; Inverts value found at index in gameboard.
; Receives: edx = y coordinate
;			eax = x coordinate
; 
; Returns: N/A
;-----------------------------------------------------
.data
	yIndex2 DWORD ?
	xIndex2 DWORD ?
.code
InvertValueAtCoords PROC USES edx eax ebx
	mov yIndex2, edx
	mov xIndex2, eax

	; same exact thing as GetValueAtCoords
	mov ebx, OFFSET GameBoard
	mov eax, RowSize
	mul yIndex2
	add ebx, eax
	mov esi, xIndex2
	mov ah, 0
	mov al, [ebx + esi]

	; invert last bit in AL
	; couldnt figure out a better way to do this
	.IF al == 0001h
		mov al, 0000
	.ELSEIF al == 0000h
		mov al, 0001h
	.ENDIF
	
	; move the new value to the array
	mov [ebx+esi], al
	ret
InvertValueAtCoords ENDP
;-----------------------------------------------------
; main
;
; manages timing and procedure calls 
;-----------------------------------------------------

.code
main PROC
	; randomize seed and generate a starting board
	call Randomize
	call GenRandomBoard

	;mov ecx, 1000	; game will run for 1000 generations
	;L1:
		
		;call CalculateGeneration
		call IncrementGeneration

		call DrawGameBoard
		mov eax, 0
		mov edx, 2
		call CalcLivingNeighbors
		call DumpRegs


		;mov eax, 2000	; 200 ms delay between generations
		;call Delay		
	;loop L1

	invoke ExitProcess,0
main endp
end main