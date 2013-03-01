	ORG 00H
	JMP MAIN

	ORG 23H
	JMP UART

UART:
	JB TI,L1
	CLR RI
	;increase digit number
	INC R2
	;display what you have typed
	MOV A,SBUF
	MOV SBUF,A
	;store what you have typed in R3
	MOV R3,A
	;determine if input is a delete.if yes, R2-1 and finish. if no, continue.
	CJNE A,#08H,begin_determine_R2
	CJNE R2,#1,DEC_R2
	DEC R2
	JMP L1
DEC_R2:
	DEC R2
	DEC R2
	MOV P1,R2
	JMP L1
begin_determine_R2:
	CJNE R2,#5,determine_number  ;if R2 is not equal to 5, the user should type a number
	;if R2=5,clear R2 first
	MOV R2,#0
	;if R2=5, the user should type an operator.
	;+:2BH  -:2DH  *:2AH  /:2FH
determine_R3_equal_2BH:
	CJNE R3,#2BH,determine_R3_equal_2DH
	CALL display_summation_result
	JMP L1
determine_R3_equal_2DH:
	CJNE R3,#2DH,determine_R3_equal_2AH
	CALL display_subtraction_result
	JMP L1
determine_R3_equal_2AH:
	CJNE R3,#2AH,determine_R3_equal_2FH
	CALL display_multiple_result
	JMP L1
determine_R3_equal_2FH:
	CJNE R3,#2FH,Call_operator_warning
	CALL display_division_result
	JMP L1
determine_number:
	;determine if the character that the user has typed is a number.
	;first determine if the high 4 bits	are 3H. if not, warning.
	;if yes, determine if the character is smaller than 3AH. 
	;if yes, saving number.
	;if no, warning.
	MOV A,R3
	RR A
	RR A
	RR A
	RR A
	ANL A,#00001111B
	CJNE A,#3,Call_number_warning
	CLR C
	MOV A,R3
	MOV R4,#3AH
	SUBB A,R4
	JNC Call_number_warning
	;saving number
determine_R2_equal_1:
	CJNE R2,#1,determine_R2_equal_2
	MOV A,R3
	ANL A,#00001111B
	MOV 1FH,A
	JMP L1
determine_R2_equal_2:
	CJNE R2,#2,determine_R2_equal_3
	MOV A,R3
	ANL A,#00001111B
	MOV 1EH,A
	JMP L1
determine_R2_equal_3:
	CJNE R2,#3,determine_R2_equal_4
	MOV A,R3
	ANL A,#00001111B
	MOV 1DH,A
	JMP L1
determine_R2_equal_4:
	MOV A,R3
	ANL A,#00001111B
	MOV 1CH,A
	JMP L1
Call_number_warning:
	CALL display_number_warning
	MOV R2,#0
	MOV R3,#0
	JMP L1
Call_operator_warning:
	CALL display_operator_warning
	MOV R3,#0
	JMP L1
L1:
	CLR TI
	RETI

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;display number warning function
;This function is used to display a warning string -- "Type wrong. Please type a number."
display_number_warning:
	;make sure that all transimissions have been finished
	JNB TI,$
	CLR TI
	;display an enter
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	;prepare to diaplay the string
	MOV DPTR,#Warning_number
	MOV R1,#0
	;begin to display the string
number_warning_loop:
	MOV A,R1
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	CJNE A,#0DH,number_warning_continue
	RET
number_warning_continue:
	INC R1
	JMP number_warning_loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;display operator warning function
;This function is used to display a warning string -- "Type wrong. Please type an operator."
display_operator_warning:
	;make sure that all transimissions have been finished
	JNB TI,$
	CLR TI
	;display an enter
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	;prepare to diaplay the string
	MOV DPTR,#Warning_operator
	MOV R1,#0
	;begin to display the string
operator_warning_loop:
	MOV A,R1
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	CJNE A,#0DH,number_warning_continue
	RET
operator_warning_continue:
	INC R1
	JMP number_warning_loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;display summation result
;input:1BH and 1AH
;output: result -> 19H and diplay
display_summation_result:
    ;display an enter
	JNB TI,$
	CLR TI
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	;calculate summation
	MOV B,#10
	MOV A,1FH
	MUL AB
	ADD A,1EH
	MOV 1BH,A
	MOV B,#10
	MOV A,1DH
	MUL AB
	ADD A,1CH
	MOV 1AH,A
	MOV A,1BH
	ADD A,1AH
	MOV 19H,A
	;display result
	MOV SBUF,#30H
	JNB TI,$
	CLR TI
	MOV B,#100
	DIV AB
	MOV DPTR,#display_number
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,B
	MOV B,#10
	DIV AB
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,B
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	;display an enter
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;display the subtraction result
;input: 1BH and 1AH
;output: if negative, display "-" and absolute result in 19H
;        if positive, display result in 19H
display_subtraction_result:
	;display an enter
	JNB TI,$
	CLR TI
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	;calculate difference
	MOV B,#10
	MOV A,1FH
	MUL AB
	ADD A,1EH
	MOV 1BH,A
	MOV B,#10
	MOV A,1DH
	MUL AB
	ADD A,1CH
	MOV 1AH,A
	CLR C
	MOV A,1BH
	SUBB A,1AH
	;if C=1,difference is negative -> display "-" and absolute result in 19H
	;if C=0,difference is positive -> display result in 19H
	JC negative_difference
	MOV SBUF,#30H
	JNB TI,$
	CLR TI
	MOV SBUF,#30H
	JNB TI,$
	CLR TI
	MOV 19H,A
	MOV B,#10
	DIV AB
	MOV DPTR,#display_number
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,B
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	;display an enter
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	RET
negative_difference:
	MOV SBUF,#2DH
	JNB TI,$
	CLR TI
	MOV SBUF,#30H
	JNB TI,$
	CLR TI
	MOV SBUF,#30H
	JNB TI,$
	CLR TI
	CLR C
	MOV A,1AH
	SUBB A,1BH
	MOV 19H,A
	MOV B,#10
	DIV AB
	MOV DPTR,#display_number
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,B
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	;display an enter
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;display multiple result
;input: 1BH and 1AH
;output: 19H and 16H and display
display_multiple_result:
	;display an enter
	JNB TI,$
	CLR TI
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	;calculate multiplication
	MOV B,#10
	MOV A,1FH
	MUL AB
	ADD A,1EH
	MOV 1BH,A
	MOV B,#10
	MOV A,1DH
	MUL AB
	ADD A,1CH
	MOV 1AH,A
	MOV A,1BH
	MOV B,1AH
	MUL AB
	MOV 19H,B
	MOV 16H,A
	MOV 64H,B
	MOV 65H,A
	MOV 66H,#100
	CLR C
	CALL division
	MOV A,68H
	MOV B,#10
	DIV AB
	MOV DPTR,#display_number
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,B
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,69H
	MOV B,#10
	DIV AB
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,B
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;display the division result
;input: 1BH and 1AH
;output: quotient -> 19H and display
;        remainder -> 16H and display
display_division_result:
	;display an enter
	JNB TI,$
	CLR TI
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	;calculate division
	MOV B,#10
	MOV A,1FH
	MUL AB
	ADD A,1EH
	MOV 1BH,A
	MOV B,#10
	MOV A,1DH
	MUL AB
	ADD A,1CH
	MOV 1AH,A
	JNZ begin_calculate_division
	MOV DPTR,#display_infinity
	MOV R1,#0
	;begin to display the string "Infinity"
number_infinity_loop:
	MOV A,R1
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	CJNE A,#0DH,number_infinity_continue
	RET
number_infinity_continue:
	INC R1
	JMP number_infinity_loop
begin_calculate_division:
	MOV A,1BH
	MOV B,1AH
	DIV AB
	MOV 19H,A
	MOV 16H,B
	MOV DPTR,#display_number
	MOV A,#0
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,#0
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,19H
	MOV B,#10
	DIV AB
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,B
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,16H
	JZ display_division_finish
	;display string "......"
	MOV SBUF,#2EH
	JNB TI,$
	CLR TI
	MOV SBUF,#2EH
	JNB TI,$
	CLR TI
	MOV SBUF,#2EH
	JNB TI,$
	CLR TI
	MOV SBUF,#2EH
	JNB TI,$
	CLR TI
	MOV SBUF,#2EH
	JNB TI,$
	CLR TI
	MOV SBUF,#2EH
	JNB TI,$
	CLR TI
	MOV B,#10
	DIV AB
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
	MOV A,B
	MOVC A,@A+DPTR
	MOV SBUF,A
	JNB TI,$
	CLR TI
display_division_finish:
	MOV SBUF,#0DH
	JNB TI,$
	CLR TI
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;;;;;;;;;;;;;;;;;;;;;;;;;
;Division for unsigned integer
;input: 16 bits: 64H 65H
;        8 bits: 66H
;output: quotient: 67H 68H
;        remainder: 69H
;Reg: A(has been protected), B(has been protected), C, 6AH
division:
	PUSH Acc;protect Acc
	PUSH B;protect B
	CLR C;clear C
	;clear result
	MOV 67H,#0
	MOV 68H,#0
	MOV 69H,#0
	MOV 70H,#0
	MOV 6BH,#0
	;division for high 8 bits
	MOV A,66H
	MOV B,A
	MOV A,64H
	DIV AB
	;quotient go to high quotient of final result
	MOV 67H,A
	;remiander go to remainder of final result
	MOV A,B
	MOV 69H,A
	;begin 8 times of loop
	MOV 6AH,#8
division_loop:
	;rotate 65H left with C
	MOV A,65H
	RLC A
	MOV 65H,A
	;rotate 69H left with C
	MOV A,69H
	RLC A
	MOV 69H,A;result -> rotate 69H and 65H left together with C
	;69H - 66H
	CLR C
	MOV A,69H
	SUBB A,66H;if negative C=1, otherwise C=0. Result in A
	;
	JC division_quotient_set_0;if C=1, go to division_quotient_set_0
division_quotient_set_1:;if C=0, go down
	MOV 69H,A;sub result go to 69H
	;most right bit of 68H set 1
	SETB C
	MOV A,68H
	RLC A
	MOV 68H,A
	;go to dicision
	JMP division_loop_dicision
division_quotient_set_0:;if C=1, go down
	;most right bit of 68H set 0
	CLR C
	MOV A,68H
	RLC A
	MOV 68H,A
division_loop_dicision:
	DEC 6AH
	MOV A,6AH
	CJNE A,#0,division_loop
	;
	POP B;get back B
	POP Acc;get back Acc
	RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

	

MAIN:
	;set serial port
	CLR SM0
	SETB SM1
	CLR SM2
	SETB REN
	ANL PCON,#01111111B
	;set bound rate
	MOV TMOD,#00100000B
	MOV TH1,#0F4H
	SETB TR1
	;set interrupt
	SETB ES
	SETB EA
	;initial input digit number
	MOV R2,#0
	;
	JMP $

Warning_number:
	DB 54H, 79H, 70H, 65H, 20H, 77H, 72H, 6FH
	DB 6EH, 67H, 2EH, 20H, 50H, 6CH, 65H, 61H
	DB 73H, 65H, 20H, 74H, 79H, 70H, 65H, 20H
	DB 61H, 20H, 6EH, 75H, 6DH, 62H, 65H, 72H
	DB 2EH, 0DH

Warning_operator:
	DB 54H, 79H, 70H, 65H, 20H, 77H, 72H, 6FH
	DB 6EH, 67H, 2EH, 20H, 50H, 6CH, 65H, 61H
	DB 73H, 65H, 20H, 74H, 79H, 70H, 65H, 20H
	DB 61H, 6EH, 20H, 6FH, 70H, 65H, 72H, 61H 
	DB 74H, 6FH, 72H, 2EH, 0DH

display_number:
	DB 30H,31H,32H,33H,34H,35H,36H,37H,38H,39H

display_infinity:
	DB 49H,6EH,66H,69H,6EH,69H,74H,79H,0DH

	END