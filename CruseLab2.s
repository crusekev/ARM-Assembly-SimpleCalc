@ Kevin Cruse
@ 2/18/22
@ kc0145@uah.edu
@ CS413-01 Spring 2022

@ Use these commands to assemble, link, run and debug this program:
@ as CruseLab2.s -o CruseLab2.o
@ gcc CruseLab2.o -o CruseLab2 || gcc -g CruseLab2.s -o CruseLab2 for debugging
@ ./CruseLab2
@ gdb --args ./CruseLab2

.text
.global main

main:
    PUSH    {r1, r2, r7}            @ Push r1, r2, r3 onto the stack
    LDR     r4, =intInput           @ Put the address of first input into r4
    LDR     r5, =intInput2          @ Put the address of second input into r5
    LDR     r6, =intInput3          @ Put the address of third input into r6
	LDR     r0, =strInputPrompt     @ Put the address of string into r0
	BL      printf
    LDR     r0, =numInputPattern    @ Put the address of string pattern into r0
    MOV     r1, r4                  @ r1 <- r4
    MOV     r2, r5                  @ r2 <- r5
    MOV     r3, r6                  @ r3 <- r6
	BL      scanf                   @ Scan for input
    MOV     r1, r4
    LDR     r1, [r1]                @ Put the value of r1 into r1
    CMP     r1, #0
    BLT     main                    @ If < 0, reprompt for input
    MOV     r2, r5
    LDR     r2, [r2]                @ Put the value of r2 into r2
    CMP     r2, #0
    BLT     main                    @ If < 0, reprompt for input
    MOV     r7, r6                  @ r7 <- r6
    LDR     r7, [r7]                @ Put the value of r7 into r7
    CMP     r7, #1
    BLEQ    addition                @ If user chose 1, branch to addition
    CMP     r7, #2
    BLEQ    subtraction             @ If user chose 2, branch to subtraction
    CMP     r7, #3
    BLEQ    multiplication          @ If user chose 3, branch to multiplication
    CMP     r7, #4
    BLEQ    division                @ If user chose 4, branch to division
    LDR     r0, =strOutput          @ Put the address of string into r0
    BL      printf
    POP     {r1, r2, r7}            @ Pop r1, r2, r3 from the stack

addition:
    PUSH    {r1, r2, r7}
    MOV     r1, r4
    LDR     r1, [r1]
    MOV     r2, r5
    LDR     r2, [r2]
    ADDS    r3, r2, r1
    MRS     r8, CPSR                @ Save the CPSR flags in r8
    MOV     r1, r3
    LDR     r0, =strOutputAdd
    BL      printf
    LDR     r0, =str_Vt             @ Overflow = True
    MSR     CPSR, r8                @ Restore the CPSR
    BLVS    printf                  @ Print if set
    LDR     r0, =str_Vf             @ Overflow = False
    MSR     CPSR, r8                @ Restore the CPSR
    BLVC    printf                  @ Print if clear
    B       exit
    POP     {r1, r2, r7}

subtraction:
    PUSH    {r1, r2, r7}
    MOV     r1, r4
    LDR     r1, [r1]
    MOV     r2, r5
    LDR     r2, [r2]
    SUBS    r3, r1, r2
    MRS     r8, CPSR                @ Save the CPSR flags in r8
    MOV     r1, r3
    LDR     r0, =strOutputSub
    BL      printf
    LDR     r0, =str_Vt             @ Overflow = True
    MSR     CPSR, r8                @ Restore the CPSR
    BLVS    printf                  @ Print if set
    LDR     r0, =str_Vf             @ Overflow = False
    MSR     CPSR, r8                @ Restore the CPSR
    BLVC    printf                  @ Print if clear
    B       exit
    POP     {r1, r2, r7}

multiplication:
    PUSH    {r1, r2, r7}
    MOV     r1, r4
    LDR     r1, [r1]
    MOV     r2, r5
    LDR     r2, [r2]
    MUL     r3, r1, r2
    @ Couldn't figure out detection of overflow for multiplication.
    @ UMULLS  r4, r8, r1, r2
    @ MRS     r9, CPSR                @ Save the CPSR flags in r8
    MOV     r1, r3
    LDR     r0, =strOutputMul
    BL      printf
    @ LDR     r0, =str_Vt             @ Overflow = True
    @ MSR     CPSR, r9                @ Restore the CPSR
    @ BLVS    printf                  @ Print if set
    @ LDR     r0, =str_Vf             @ Overflow = False
    @ MSR     CPSR, r9                @ Restore the CPSR
    @ BLVC    printf                  @ Print if clear
    B       exit
    POP     {r1, r2, r7}

division:
    PUSH    {r1, r2, r7}
    MOV     r0, r4
    LDR     r0, [r0]                @ r0 <- numerator
    MOV     r1, r5
    LDR     r1, [r1]                @ r1 <- denominator
    CMP     r1, #0
    BEQ     error                   @ Throw an error is user divides by zero
    BL      __aeabi_idiv            @ Call div library
    MOV     r1, r0                  @ Store quotient into r1 for printf
    MOV     r2, r3                  @ Store remainder into r2 for printf
    LDR     r0, =strOutputDiv       
    BL      printf
    B       exit
    POP     {r1, r2, r7}

error:
    LDR     r0, =strOutputDivError  @ Put the address of string into r0
    BL      printf
    B       exit
    

exit:
    MOV     R7, #0X01               @ Exit program
    SVC     0

.data

.balign 4
strInputPrompt: .asciz "Hello! Please enter three natural numbers, with a space separating each number.\nThe first two numbers will be the numbers you want to calculate and the third number will be which operation you would like to perform.\nFor addition, type 1\nFor subtraction type 2\nFor multiplication type 3\nFor division type 4\nExamples:\nTo do 123 + 678, type 123 678 1\nTo do 907 - 45, type 907 45 2\nTo do 98 * 45, type 98 45 3\nTo do 17 / 25, type 17 25 4\n: "
.balign 4
strOutput: .asciz "The number values are: %d %d %d\n"
.balign
strOutputAdd: .asciz "The sum is: %d\n"
.balign
strOutputSub: .asciz "The difference is: %d\n"
.balign
strOutputMul: .asciz "The product is: %d\n"
.balign
strOutputDiv: .asciz "The quotient is: %d and the remainder is %d\n"
.balign
strOutputDivError: .asciz "You can't divide by zero! Try again\n"
.balign 4
str_Vt: .asciz "Overflow flag = 1\n" 
.balign 4
str_Vf: .asciz "Overflow flag = 0\n"
.balign 4
numInputPattern: .asciz "%d %d %d"
.balign 4
intInput: .word 0
.balign 4
intInput2: .word 0
.balign 4
intInput3: .word 0



.global printf
.global scanf
