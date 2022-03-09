TITLE Project6    (Proj6_Bartanee.asm)

; Author: Eric Bartanen
; Last Modified: 3/5/22
; OSU email address: bartanee@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                 Due Date: 3/12/22
; Description: 

INCLUDE Irvine32.inc

MAX_STRING = 12


mGetString MACRO prompt, num, count, max

	;display prompt by reference
	;get users keyboard entry, save to memory location

	PUSH	EAX
	PUSH	ECX
	PUSH	EDX

	MOV		EDX, prompt
	CALL	WriteString 

	MOV		EDX, num
	MOV		ECX, max
	CALL	ReadString
	MOV		count, EAX

	POP		EDX
	POP		ECX
	POP		EAX

ENDM

mDisplayString MACRO user_string

	PUSH	EDX

	MOV		EDX, user_string
	CALL	WriteString

	POP		EDX


ENDM

.data

prog_title		BYTE	"Assignment 6: Low-level I/O procedures",13,10, "Programmed by Eric Bartanen",13,10,0
instructions	BYTE	"Please enter 10 signed decimal integers.", 13,10, "Each integer must fit in a 32 bit register. Once you've entered the numbers I'll show you the list of integers, their sum, and their average.",13,10,0

user_prompt		BYTE	"Please enter a signed integer: ",0

error_msg		BYTE	"ERROR: Something's wrong with your integer. Please review the instructions and try again.",13,10,0

list_title		BYTE	"Here are your 10 integers:",13,10,0
sum_title		BYTE	"The sum is: ",0
avg_title		BYTE	"The average is: ",0

farewell		BYTE	"Let's do this again sometime, bye!",0

user_num		BYTE	MAX_STRING DUP(?), 0
user_count		DWORD	?

num_int			SDWORD	?

user_array		SDWORD	10 DUP (?)

user_string		BYTE	MAX_STRING DUP(?), 0



.code
main PROC
	;ReadVal loop to get 10 valid integers
	;store numeric values in array
	;display integers, sum, truncated average


	MOV		ECX, 3	;LENGTHOF user_array	
	MOV		EDI, OFFSET user_array	; User array into EDI
_userLoop:
	PUSH	num_int
	PUSH	OFFSET error_msg
	PUSH	SIZEOF user_num
	PUSH	user_count 
	PUSH	OFFSET user_num
	PUSH	OFFSET user_prompt
	CALL	ReadVal
	MOV		[EDI], EAX
	ADD		EDI, 4
	LOOP	_userLoop


	MOV		ECX, 3	;LENGTHOF user_array	
	MOV		ESI, OFFSET user_array	; User array into ESI
_writeLoop:
	PUSH	[ESI]
	PUSH	OFFSET user_string
	CALL	WriteVal
	ADD		ESI, 4
	LOOP	_writeLoop

	Invoke ExitProcess,0	; exit to operating system
main ENDP


ReadVal PROC
	LOCAL	byte_sign:SDWORD
	PUSH	ECX

_entryLoop:
	mGetString [EBP+8], [EBP+12], [EBP+16], [EBP+20]
	
	MOV	ESI, [EBP+12]
	MOV	ECX, [EBP+16]
	MOV	byte_sign, 1
	MOV	EAX, 0
	MOV [EBP+28], EAX		; clear number conversion tracker 
	MOV	EBX, 0
	MOV	EDX, 0
	CLD

_validateLoop:
	LODSB

	CMP		AL, 57	; Check for ASCII too high
	JG		_error

	CMP		AL, 45	; If negative sign found, set local variable "sign" then load next byte
	JE		_negative

	CMP		AL, 43	; If positive sign found, load next byte
	JE		_positive

	CMP		AL, 48	; Check for ASCII too low
	JL		_error

_convert:
	MOVZX	EAX, AL
	SUB		EAX, 48
	MOV		EBX, EAX
	MOV		EAX, [EBP+28]
	MOV		EDX, 10
	IMUL	EDX
	JO		_error
	ADD		EAX, EBX 
	JO		_error
	MOV		[EBP+28], EAX
	JMP		_loop

	;checks that negative sign is only at the beginning of the byte string 
_negative:
	CMP		ECX, [EBP+16]
	;JZ		_error	;checks that more digits than negative sign are present
	JNE		_error
	MOV		byte_sign, -1
	JMP		_loop

	;checks that positive sign is only at the beginning of the byte string
_positive:
	CMP		ECX, [EBP+16]
	;JZ		_error	;checks that more digits than positive sign are present
	JNE		_error

_loop:
	LOOP	_validateLoop
	JMP		_end

_error:
	MOV		EDX, [EBP+24]
	CALL	WriteString
	JMP		_entryLoop

_end:
	CMP		byte_sign, -1
	JNE		_return
	NEG		EAX

_return:
	POP		ECX
	RET		24

ReadVal ENDP


WriteVal PROC

	; convert numeric SDWORD (INPUT, VALUE) to a string of ascii digits
	; invoke mDisplayString to print the ascii representation of the SDWORD to output

	;mDisplayString 
	;LOCAL 

	PUSH	EBP
	MOV		EBP, ESP

	PUSH	ECX
	PUSH	ESI
	
	XOR		EAX, EAX
	MOV		EAX, [EBP+12]	;SDWORD from user_array into EAX

	; Check for negative

	MOV		ECX, MAX_STRING-1 
	MOV		EDI, [EBP+8]	;user_string to EDI
	ADD		EDI, MAX_STRING-1
	
	MOV		EBX, 10
	MOV		EDX, 0
	DIV		EBX
	ADD		DL, 48
	DEC		EDI
	MOV		[EDI], DL

	; Continue dividing and adding remainder to EDI
	
	mDisplayString EDI

	POP		ESI
	POP		ECX
	POP		EBP

	RET		8

WriteVal ENDP




END main
