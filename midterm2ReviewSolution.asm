TITLE midterm 2 review 

COMMENT !
The midterm is open book / notes
It covers modules 5 (branching), 6 (bit-wise instruction / indirect addressing), 7 (procedures / macros)
Bring a pen / pencil and a picture ID
!


INCLUDE Irvine32.inc

printError MACRO myStr         ;;;; we discussed in class that myStr could also be a string address
	push eax			; save registers
	push edx
	mov al, '*'			; print *
	call writeChar
	mov edx, OFFSET myStr	; print string
	call writeString
	call writeChar		; print *
	call crlf			; print newline
	pop edx				; restore registers
	pop eax
ENDM


.stack

.data
errorStr BYTE "invalid result",0

var1 BYTE 9
var2 BYTE 10
var3 BYTE 11
arr DWORD 1,2,3,4,5,6,7
;arr DWORD 5


.code
main PROC
; The first 3 sample questions are to write code

; 1. write a macro that prints the errorStr (defined above)
; on a separate line of text, with a * character at the beginning and end of the string

;;;; solution macro is at top of file


; 2. write code that implements:
;   var1 * var2 - var3
; the result can be in any register
;
; if any operation ends up with an invalid result, invoke the
; macro of question 1 
; var1, var2, var3 can contain any data value. You shouldn't rely 
; on the given data values when writing code to catch invalid result

; this problem works with BYTEs so we only work with 8-bit registers and data

; 1. multiply: var1 * var2
mov al, var1
mul var2		; result is in ax, but if it doesn't fit in al, then we have a problem
				; so we need to check if ah is 0
				; One way:
				; cmp ah, 0
				; jne errorhandling

				; however, there is a shorter way:
jc errorhandling	; CF is set for unsigned multiply if the result goes into
					; the upper half of product (class notes module 4)

sub al, var3	; fall through logic: if ah is 0, result is a BYTE, we can continue
				; Then, after subtraction, the result can also be invalid
				; so we need to check CF

; we first did:
; jc errorHandling
; jmp question3
 
; but the code flows better with fall through logic if we coded:
jnc question3

errorhandling:
printError  errorStr	; invoke macro

question3:

; 3. write a procedure that accepts 2 input arguments: an array 
; of DWORDs and the number of elements. The procedure zeroes out all 
; the elements at an even index
;
; the procedure call is given here:
push OFFSET arr
push LENGTHOF arr 
call proc1

exit
main ENDP

; Answer to question 4:
; stack frame:

; old ecx
; old esi
; ebp
; return addr       ebp + 4
; num of elems		ebp + 8
; arr address		ebp + 12

COMMENT !   
Our first attempt at proc1
proc1 PROC
	; set ebp
	push ebp
	mov ebp, esp

	; save registers that we use
	push esi
	push ecx

	; fetch data from stack
	mov esi, [ebp+12]	; esi -> arr or arr[0]
	mov ecx, [ebp+8]	; ecx = num of elems

	; divide ecx by 2 because we'll skip every other element to zero out data:
	;;; this is not how to divide ecx by 2:
	;mov eax, ecx
	;mov ebx, 2
	;div ebx
	;mov ecx, eax
	;;; this is how to divide ecx by 2:
	shr ecx, 1

	; check that array size is not 1, otherwise ecx will be 0 at the start of the loop,
	; and the loop will go on for a long time

	jz smallArray		; if ecx is 0, we can jump to the special case of array of
						; size 1 below

	zeroLoop:
		mov DWORD PTR [esi], 0			; zero out current element
		; or:  and  DWORD PTR [esi], 0
		add esi, 8						; skip every other element
		loop zeroLoop
	jmp ending			; jump over the small array case

	smallArray:
		mov DWORD PTR [esi], 0

	ending:
	pop ecx				; restore registers
	pop esi
	pop ebp
	ret 8				; clear out 2 input params
proc1 ENDP

Question in class: proc1 doesn't catch the last element to be zeroed out if
the array has an odd-numbered size like 3, 5, 7...
!

;;; our final solution:
proc1 PROC
	; 1. set ebp
	push ebp
	mov ebp, esp

	; 2. save registers
	push esi
	push ecx

	; 3. do work
	mov esi, [ebp+12]	; esi -> arr or arr[0]
	mov ecx, [ebp+8]	; ecx = num of elems
	shr ecx, 1			; CF has the LSB that is shifted out

	jnc zeroOutLoop		; CF is 0, it's an even size and our ecx is okay
	inc ecx				; else increment ecx
						; this takes care of the odd numbered size,
						; which includes the size of 1

	zeroOutLoop:
		mov DWORD PTR [esi], 0			; zero out current element
		add esi, 8						; skip every other element
		loop zeroOutLoop

	; 4. clean up
	pop ecx
	pop esi
	pop ebp
	ret 8		; return and clear out 2 input params
proc1 ENDP


END main


COMMENT !

These sample questions are to read code

4. With the procedure call to proc1 of question 3, show a diagram
of the stack frame of proc1 at the point right after all the even indexed
elements have been zeroed out. 
For each value in the stack frame, you can either put the register 
name that holds the value (such as: eax), or describe what the value 
is (such as: return addr in main)
Make sure to list the values in the order that they appear in the stack,
and show where the stack top is

;;;;; answer shown above proc1


5. Show the value of all registers that are changed after each
instruction

xor al, al			; al: 0000 0000
or al, 82h			; al: 1000 0010
shl al, 1			; al: 0000 0100    CF: 1
jc L1				; jump since CF is 1
and bl, 0
jz L2
L1: not al			; al: 1111 1011
L2:


6. Using the same arr defined in main above, show the values in the array
after this code segment:

; arr DWORD 1,2,3,4,5,6,7,8

mov edx, OFFSET arr				; edx: addr of arr[0]
add edx, LENGTHOF arr			; edx: addr of arr[2]
add DWORD PTR [edx], 2			; [edx]: 5
sub edx, 4						; edx: addr of arr[1]
add DWORD PTR [edx], 4			; [edx]: 6

final arr:   1,6,5,4,5,6,7,8

!