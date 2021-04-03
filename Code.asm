ORG 0h
LJMP Main
ORG 3h; Jumping address of the 0 interrupt on Port 3.2
LJMP Save_value
LJMP Show

;----------------------------
; init the interrupt and counter
;----------------------------

Counter_Init:; With P3.4 the counter will be increased
	MOV TMOD, #5h; set timer mode 00000101b = 5
	MOV TL0, #0d; start value
	SETB TR0; start counter 0
RET

EX0_INIT:; init 0 interrupt on Port 3.2
	SETB IT0
	SETB EX0
	SETB EA
RET

;----------------------------

Check:; Check the Pin
	CJNE R4, #3d, Fail
	CJNE R5, #1d, Fail
	CJNE R6, #7d, Fail
	CJNE R7, #4d, Fail
	SETB P0.7
RETI

;----------------------------
; Save the input in register
;----------------------------

Reset:
	MOV TL0, #0d
	INC A
RETI

Save_value:
	JMP W1s
RETI

W1s:
	CJNE A, #0d, W2s
	MOV R4, P2
	SETB P0.0
	JMP Reset
RETI

W2s:
	CJNE A, #1d, W3s
	MOV R5, P2
	SETB P0.1
	JMP Reset
RETI

W3s:
	CJNE A, #2d, W4s
	MOV R6, P2
	SETB P0.2
	JMP Reset
RETI

W4s:
	CJNE A, #3d, Finish
	MOV R7, P2
	SETB P0.3
	JMP Check
	JMP Reset
RETI

;----------------------------

Main:
	MOV P0, #0d
	MOV A, #0d
	CALL EX0_INIT
	CALL Counter_Init

Show:
	MOV P2, TL0
	SJMP Show

Finish:
	MOV P2, #0d
	SJMP Finish

Fail:
MOV P2, #0d
NextFail:
CALL Spin
CALL Delay
SJMP NextFail

Spin:
	CPL P2.0
	CPL P2.1
	CPL P2.2
	CPL P2.3
	CPL P2.4
	CPL P2.5
	CPL P2.6
	CPL P2.7
RET

Delay:
	MOV R0, #220d
	j1: MOV R1, #255d
	j2: MOV R2, #255d
	j3: DJNZ R2, j3
	DJNZ R1, j2
	DJNZ R0, j1
RET

END