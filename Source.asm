; Conway's Game of Life
; by frank paschen :)

INCLUDE Irvine32.inc
.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
	genMsg BYTE "GENERATION #", 0
	genCount SWORD 0

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
	; board modified each generation, and copied into the game GameBoard
	GameBoardBackup BYTE 20 DUP(0)
	Rowsize2 = ($ - GameBoardBackup)
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
liveCount2 BYTE 0
.code
CalculateGeneration PROC USES ecx 
	call CopyMainToBackup

	mov ecx, 20
	L1:
		mov count4, ecx
		mov ecx, 20
		L2:
			; get live neighbor count
			mov eax, xCoord4
			mov edx, yCoord4
			call CalcLivingNeighbors
			mov liveCount2, bl

			; get cellstate
			mov eax, xCoord4
			mov edx, yCoord4
			call GetValueAtCoords
			mov cellState, al
			inc xCoord4

			
			; apply GoL rules & change backup board
			.IF (cellstate == 0) && (liveCount2 == 3)
				call InvertValueAtCoords2
			.ELSEIF (cellState == 1) && (liveCount2 <= 1)
				call InvertValueAtCoords2
			.ELSEIF (cellState == 1) && (liveCount2 >= 4)
				call InvertValueAtCoords2
			.ELSEIF (cellState == 1) && (liveCount2 == 2 || liveCount2 == 3)
				
			.ENDIF

		dec cx
		jne L2
			mov ecx, count4
	dec cx
	jne L1

	call CopyBackupToMain
	ret
CalculateGeneration ENDP
;-----------------------------------------------------
; CopyMainToBackup
;
; Copies every cell from the main GameBoard to the GameBoardBackup
; Receives: N/A
;
; Returns: N/A
;-----------------------------------------------------
.data
	yCoord6 DWORD 0
	xCoord6 DWORD 0
	count6 DWORD 0
	backupVal2 DWORD 0
.code
CopyMainToBackup PROC
	mov ecx, 20

	L1:
		mov count6, ecx
		mov ecx, 20
		L2:
			
			; xy in backup
			mov eax, xCoord6
			mov edx, yCoord6

			call GetValueAtCoords	; value in backup
			mov backupVal2, eax

			mov edx, yCoord7
			mov eax, xCoord7
			mov ebx, backupVal2
			call SetBackupCell

			inc xCoord6
		dec cx
		jne L2
			mov ecx, count6
	dec cx
	jne L1
	ret
CopyMainToBackup ENDP
;-----------------------------------------------------
; CopyBackupToMain
;
; Copies every cell from the GameBoardBackup to the main GameBoard
; Receives: N/A
;
; Returns: N/A
;-----------------------------------------------------
.data
	yCoord7 DWORD 0
	xCoord7 DWORD 0
	count7 DWORD 0
	backupVal BYTE 0
.code
CopyBackupToMain PROC
	mov ecx, 20

	L1:
		mov count7, ecx
		mov ecx, 20
		L2:
			
			; xy in backup
			mov eax, xCoord7
			mov edx, yCoord7

			call GetValueAtCoords2	; value in backup
			mov backupVal, al

			mov edx, yCoord7
			mov eax, xCoord7
			mov bl, backupVal
			call SetMainCell

			inc xCoord7
		dec cx
		jne L2
			mov ecx, count7
	dec cx
	jne L1
	ret
CopyBackupToMain ENDP

;-----------------------------------------------------
; SetMainCell
;
; Returns number of "living" neighbors for any given cell. Between 0 and 8
; Receives: edx = y coordinate
;			eax = x coordinate
;			bl = value
;
; Returns: ebx = # of living neighbors
;-----------------------------------------------------
.data
newValue BYTE ?
yIndex3 DWORD ?
xIndex3 DWORD ?
.code
SetMainCell PROC 
	mov newValue, bl
	mov xIndex3, eax
	mov yIndex3, edx

	mov ebx, OFFSET GameBoard 
	mov eax, RowSize
	mul yIndex3
	add ebx, eax 
	mov esi, xIndex3
	mov al, newValue
	mov [ebx + esi], al

SetMainCell ENDP

.data
newValue2 DWORD ?
yIndex4 DWORD ?
xIndex4 DWORD ?
.code
SetBackupCell PROC 
	mov newValue2, ebx
	mov xIndex4, eax
	mov yIndex4, edx

	mov ebx, OFFSET GameBoardBackup
	mov eax, RowSize2
	mul yIndex4	
	add ebx, eax
	mov esi, xIndex4
	mov eax, 0 ; problem here
	mov [ebx + esi], eax

SetBackupCell ENDP

;-----------------------------------------------------
; CalcLivingNeighbors
;
; Returns number of "living" neighbors for any given cell. Between 0 and 8
; Receives: edx = y coordinate
;			eax = x coordinate
; 
; Returns: ebx = # of living neighbors
;-----------------------------------------------------
.data
liveCount DWORD 0	; stores # of living neighbors for each cell
originalX DWORD 0
originalY DWORD 0
.code
CalcLivingNeighbors PROC 

	mov originalX, eax
	mov originalY, edx
	mov liveCount, 0
	; check all 8 adjacent cells and add any living (1) cells to the total

	mov eax, originalX
	mov edx, originalY
	call GetBottomLeft
	.IF (al == 0) || (al == 1)
		add liveCount, eax
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetBottomCenter
	.IF (al == 0) || (al == 1)
		add liveCount, eax
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetBottomRight
	.IF (al == 0) || (al == 1)
		add liveCount, eax
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetRight
	.IF (al == 0) || (al == 1)
		add liveCount, eax
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetLeft
	.IF (al == 0) || (al == 1)
		add liveCount, eax
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetTopLeft
	.IF (al == 0) || (al == 1)
		add liveCount, eax
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetTopCenter
	.IF (al == 0) || (al == 1)
		add liveCount, eax
	.ENDIF

	mov eax, originalX
	mov edx, originalY
	call GetTopRight
	.IF (al == 0) || (al == 1)
		add liveCount, eax
	.ENDIF

	; return count in ebx for CalculateGeneration
	mov ebx, liveCount

	ret
CalcLivingNeighbors ENDP

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
DrawGameBoard PROC USES ecx
	call Clrscr
	call Crlf
	mov ecx, 20
	mov yCoord, 0
	mov xCoord, 0

	L1:	; outer loop
		mov count, ecx
		mov ecx, 20
		L2: ; inner loop
			mov eax, xCoord	; x

			call GetValueAtCoords
			
			; TODO: Color these, possible find better ASCII characters
			mov temp, al
			.IF temp == 0	; 0 = dead cell
				mov al, 178
			.ELSEIF temp == 1	; 1 = living cell
				mov al, 176
			.ENDIF

			call WriteChar

			inc xCoord
		loop L2
			mov ecx, count
			call Crlf
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
	mov ax, genCount

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
; GetValueAtCoords2
;
; Returns value found at index in GameBoardBackup.
; Receives: edx = y coordinate
;			eax = x coordinate
; 
; Returns: al = value at coordinates in array (zero indexed)
;-----------------------------------------------------
GetValueAtCoords2 PROC USES esi ebx
	mov yIndex, edx
	mov xIndex, eax

	mov ebx, OFFSET GameBoardBackup

	mov eax, RowSize2
	mul yIndex	
	add ebx, eax 

	mov esi, xIndex
	mov ah, 0
	mov al, [ebx + esi]

	ret
GetValueAtCoords2 ENDP

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
.data
	yIndex9 DWORD ?
	xIndex9 DWORD ?
.code
InvertValueAtCoords2 PROC USES edx eax ebx
	mov yIndex9, edx
	mov xIndex9, eax

	; same exact thing as GetValueAtCoords
	mov ebx, OFFSET GameBoardBackup
	mov eax, RowSize2
	mul yIndex9
	add ebx, eax
	mov esi, xIndex9
	mov ah, 0
	mov al, [ebx + esi]

	.IF al == 0001h
		mov al, 0000
	.ELSEIF al == 0000h
		mov al, 0001h
	.ENDIF
	
	; move the new value to the array
	mov [ebx+esi], al

	ret
InvertValueAtCoords2 ENDP

;-----------------------------------------------------
; Helper procedures for calculating # of living cells
; All procedures check if cell is on a border and behave accordingly
; (do not want to return values outside of the array)
; Receives: edx = y coordinate
;			eax = x coordinate
; 
; Returns: al = value at coordinates in array (zero indexed)
;-----------------------------------------------------
.code
GetBottomLeft PROC
	.IF eax == 0 || edx == 19
		jmp L1
	.ENDIF
	dec eax
	inc edx
	call GetValueAtCoords
	L1:
	ret
GetBottomLeft ENDP

GetBottomCenter PROC
	.IF edx == 19
		jmp L1
	.ENDIF
	inc edx
	call GetValueAtCoords
	L1:
	ret
GetBottomCenter ENDP

GetBottomRight PROC
	.IF edx == 19 || eax == 19
		jmp L1
	.ENDIF
	inc eax
	inc edx
	call GetValueAtCoords
	L1:
	ret
GetBottomRight ENDP

GetLeft PROC
	.IF eax == 0
		jmp L1
	.ENDIF
	dec eax

	call GetValueAtCoords
	L1:
	ret
GetLeft ENDP

GetRight PROC
	.IF eax == 19
		jmp L1
	.ENDIF
	inc eax
	call GetValueAtCoords
	L1:
	ret
GetRight ENDP

GetTopLeft PROC
	.IF edx == 0 || eax == 0
		jmp L1
	.ENDIF
	dec eax
	dec edx
	call GetValueAtCoords
	L1:
	ret
GetTopLeft ENDP

GetTopCenter PROC
	.IF edx == 0
		jmp L1
	.ENDIF
	dec edx
	call GetValueAtCoords
	L1:
	ret
GetTopCenter ENDP

GetTopRight PROC
	.IF edx == 0 || eax == 19
		jmp L1
	.ENDIF
	inc eax
	dec edx
	call GetValueAtCoords
	L1:
	ret
GetTopRight ENDP

;-----------------------------------------------------
; main
;
; Contains game loop which manages timing and procedure calls 
;-----------------------------------------------------

.data
y DWORD 0
x DWORD 0
.code
main PROC
	; randomize seed and generate a starting board
	call Randomize
	call GenRandomBoard

	mov ecx, 1000	; game will run for 1000 generations
	L1:
		
		call DrawGameBoard
		call IncrementGeneration

		;call CalculateGeneration

		mov eax, 200	; 200 ms delay between generations
		call Delay		
	loop L1

	invoke ExitProcess,0
main endp
end main

