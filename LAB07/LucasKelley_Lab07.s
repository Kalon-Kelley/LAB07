;*******************************************************************************
;
;    CS 107: Computer Architecture and Organization -- LAB 7
;    Filename: Lab07.s
;    Date: [YOUR DATE]
;    Author: [YOUR NAME]
;
;*******************************************************************************
;
	GLOBAL __main
	AREA main, CODE, READONLY
	EXPORT __main
	EXPORT __use_two_region_memory
__use_two_region_memory EQU 0
	EXPORT SystemInit
	ENTRY

	GET		BOARD.S

N1			EQU	40
N2			EQU	35
N3			EQU	43
	
N_MIN_MAX	EQU	12
	
; System Init routine
SystemInit
	BX		LR
;
	ALIGN

__main
;
; Test 'min_max'
;
; vvvvvv Uncomment when procedure 'min_max' is ready to test! vvvvv
	LDR		R1, =N_MIN_MAX
	LDR		R0, =min_max_data_1
	BL		min_max                 ; Expected results: Min: -3 (0xFFFFFFFD) Max: 13 (0x0000000D)
;;
	LDR		R0, =min_max_data_2      
	BL		min_max                 ; Expected results: Min: 1 (0x00000001) Max: 16 (0x00000010)
;;
	LDR		R0, =min_max_data_3
	BL		min_max                 ; Expected results: Min: -16 (0xFFFFFFF0) Max: -1 (0xFFFFFFFF)
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
;
; Test 'wait_for_bit3'
;
; vvv Uncomment when procedure 'wait_for_bit3' is ready to test! vv
	LDR		R1, =test_data_1
	LDR		R2, =N1
	BL		wait_for_bit3			; Expected results: R0 = 27 (0x0000001B)
;;
	LDR		R1, =test_data_2
	LDR		R2, =N2
	BL		wait_for_bit3			; Expected results: R0 = 35 (0x00000023) (no '1' in bit 3 found)
;;
	LDR		R1, =test_data_3
	LDR		R2, =N3
	BL		wait_for_bit3			; Expected results: R0 = 11 (0x0000000B)
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;
;
;
; Test 'calc_pllcfg'
;
; vvvv Uncomment when procedure 'calc_pllcfg' is ready to test! vvv
;;
;; Next 2 inputs must return R0 = -1 and R1 = 0 (wrong input parameter)
;;
	LDR		R1, =10000000
	BL		calc_pllcfg
;;
	LDR		R1, =200000000
	BL		calc_pllcfg
;;
;; Calculate M and P to run PLL at 36 MHz. Using PLLCFG_MSEL_xxx and PLLCFG_PSEL_xxx constants
;; store P and M into R2.
;; Use this number to check the output (R0) of your function.
;;
    LDR 	R2, =(PLLCFG_MSEL_3:OR:PLLCFG_PSEL_4)
;;
;; For all 3 examples below, resulting actual CLK (R1) must be 36000000
;;
	LDR		R1, =36000000
	BL		calc_pllcfg
;;
	LDR		R1, =37000000
	BL		calc_pllcfg
;;
	LDR		R1, =35000000
	BL		calc_pllcfg
;;
;; Calculate M and P to run PLL at 120 MHz. Using PLLCFG_MSEL_xxx and PLLCFG_PSEL_xxx constants
;; store P and M into R2.
;; Use this number to check the output (R0) of your function.
;;
    LDR 	R2, =(PLLCFG_MSEL_10:OR:PLLCFG_PSEL_1)
;;
;; For the example below, resulting actual CLK (R1) must be 120000000
;;
	LDR		R1, =120000000
	BL		calc_pllcfg
; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

stop
	B		stop
	
	ALIGN

;
; 1. Write a function to find MAX and MIN of array of signed 16-bin integers.
;
; Parameters:
;
; R0 - Input: Address of array (signed half-words)
; R1 - Input: Size of array ( >= 1 )
;
; R2 - Output: Min(array)
; R3 - Output: Max(array)
;
; Preserve the values of R0, R1 and any registers you are using in your function.
;
min_max
; -- Your code for function is here ---' 
	PUSH 	{R0-R1, R4-R12, LR}
	LDRSH 	R4, [R0]
	MOV 	R2, R4
	MOV 	R3, R4

mnmx_loop
	ADDS 	R0, #2
	SUBS 	R1, #1
	CMP 	R1, #0
	POPEQ	{R0-R1, R4-R12, LR}
	BXEQ 	LR
	LDRSH 	R4, [R0]
	CMP 	R4, R2
	MOVLT 	R2, R4
	CMP		R4, R3
	MOVGT	R3, R4
	B		mnmx_loop	

	ALIGN

;
; 2. Write a function that return the number of leading numbers with BIT3 = 0.
; Numbers are 32-bit unsigned integer.
; If all numbers in the array have bit 3 = 0, then the function should return 
; the number of elements in the array   
;
; For example:
; For array of numbers: [0, 0, 0, 8, 8, 8] the returned result should be 3
; For array of numbers: [2, 2, 10, 10, 10, 10] the returned result should be 2
; For array of numbers: [4, 4, 4, 4, 4, 4] the returned result should be 6
;
; Parameters:
;
; R0 - Output: Number of leading numbers with Bit3 = 0.
; R1 - Input: Start address of the array of 32-bit unsigned integers
; R2 - Input: The size of array.
;
; Preserve the values of R1, R2 and any registers you are using in your function.
;
wait_for_bit3
; -- Your code for function is here ---' 	
	PUSH 	{R1-R12, LR}
	MOV 	R4, #8
	MOV 	R0, #0

wfb_loop
	CMP		R2, #0
	POPEQ 	{R1-R12, LR}
	BXEQ	LR
	LDR 	R3, [R1]
	AND 	R3, R4
	CMP 	R3, #0
	ADDEQ 	R0, #1
	SUBS 	R2, #1
	ADDS 	R1, #4
	B 		wfb_loop
	
	ALIGN

;
; 3. Write a function that calculates the PLLCFG register values (P and M PLL parameters) 
; for a given PLL output frequency.
;
; Input clock Frequency - 12 MHz (or 12000000 Hz)
;
; Valid values for the PLL frequency are 12 MHz - 120 MHz. The function must check the 
; validity of the required frequency.
; 
; If the preset frequency cannot be obtained, the function must set the nearest possible 
; PLL frequency.
; 
; Parameters:
;
; R0 = Output: PLLCFG value or -1 (0xFFFFFFFF) if required output frequency is not correct.
; R1 - Input:  Required output PLL clock rate in Hz. (So, 36000000 is 36 MHz) 
;      Output: Actual clock rate or 0 if required output frequency is not correct.
;
; Preserve the values of any registers you are using in your function.
;
calc_pllcfg
; -- Your code for function is here ---' 	
	PUSH 	{R2-R12, LR}
	MOV 	R0, #0
	LDR 	R2, =12000000
	LDR 	R3, =120000000
	LDR 	R6, =6000000
	MOV 	R7, #2
	LDR 	R9, =156000000
	MOV 	R10, #0
	CMP 	R1, R2
	BLT 	incorrect_frq
	CMP 	R1, R3
	BGT 	incorrect_frq
	UDIV 	R4, R1, R2
	MUL 	R5, R4, R2
	SUBS 	R5, R1, R5
	CMP 	R5, R6
	ADDGE 	R4, #1
	MUL 	R1, R2, R4
	SUBS 	R4, #1
	ADDS 	R0, R4
	
pllcfg_loop
	MUL 	R8, R1, R7
	CMP 	R8, R9
	ADDLT 	R7, R7
	ADDLT 	R10, #1
	BLT		pllcfg_loop
	LSL 	R10, #5
	ADDS 	R0, R10
	POP 	{R2-R12, LR}
	BX 		LR

incorrect_frq
	MOV 	R1, #0
	MOV 	R0, #-1
	POP 	{R2-R12, LR}
	BX  	LR
	


	ALIGN

min_max_data_1
	DCW	  3, 5, -2, 6, 8, -3, 13, 4, 5, 0, 11, 3 
	ALIGN
min_max_data_2
	DCW	  3, 5, 12, 16, 8, 11, 13, 4, 5, 8, 14, 1 
	ALIGN
min_max_data_3
	DCW	  -3, -5, -12, -16, -8, -11, -13, -4, -5, -8, -14, -1 
	ALIGN

test_data_1
    DCD   40355, 34775, 64277, 27392, 24930, 41670, 36775, 14788, 41495, 42241
    DCD   40290, 59126, 5666, 15125, 38532, 47299, 63267, 9893, 9088, 18659
    DCD   5335, 39892, 26404, 39431, 15027, 15335, 34183, 18541, 56079, 30089
    DCD   10684, 15183, 8222, 38557, 36828, 6842, 63754, 38201, 6122, 7338
	ALIGN
test_data_2
    DCD   53219, 50611, 53525, 7462, 26309, 42613, 52228, 35253, 22928, 4149
    DCD   27328, 6006, 25344, 14194, 39127, 45862, 9751, 14278, 28739, 5619
    DCD   18261, 4951, 56835, 43859, 64132, 63267, 37175, 9072, 57510, 13687
    DCD   61443, 55238, 45382, 7639, 11345
	ALIGN
test_data_3
    DCD   24291, 41748, 52631, 35093, 8610, 57120, 53046, 32129, 41347, 27665
    DCD   17765, 40923, 22379, 64846, 40988, 8783, 15179, 42537, 57498, 10333
    DCD   59710, 29870, 59852, 8170, 38543, 45983, 48620, 35773, 7294, 47613
    DCD   23356, 35421, 61195, 27279, 8139, 14748, 27545, 54495, 10878, 60110
    DCD   7835, 49003, 62121
	ALIGN

	AREA variables, DATA, ALIGN=2

	END