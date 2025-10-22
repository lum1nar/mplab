    List p=18f4520
	#include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00
	  
	MOVLF macro literal, address
	    MOVLW literal
	    MOVWF address
	endm
	
	; This is a multiplier for 16 bit `signed` integer
	; Put mult1 in 0x80, 0x81
	; put mult2 in 0x82, 0x83
	; product   in 0x90, 0x91, 0x92, 0x93
	; All input test cases have to fall between -32768 and 32767
    ; change d'16' to 16 of the following line for cx8
    ; MOVLF d'16', 0x8B; iteration

	MOVLF 0x75, 0x80 ;mult1_high
	MOVLF 0x23, 0x81 ;mult1_low
	MOVLF 0x25, 0x82 ;mult2_high
	MOVLF 0x23, 0x83 ;mult2_low
	

	BTFSC 0x80, 7 ; check negative bit
	GOTO neg1 ; skip if mult1 is positive
	GOTO next

	neg1: 
	 ;;2s complement
	    CLRF WREG
	    COMF 0x80, F
	    COMF 0x81, F
	    INCF 0x81, F
	    ADDWFC 0x80, F

	    BTG 0x8A,0;SIGNED

	next:
	    BTFSC 0x82, 7 ; skip if mult2 is positive
	    GOTO neg2
	    GOTO mulinit

	neg2:
	;;2s complement
	    CLRF WREG
	    COMF 0x82, F
	    COMF 0x83, F
	    INCF 0x83, F
	    ADDWFC 0x82, F

	    BTG 0x8A,0;SIGNED

	mulinit:
	    CLRF 0x85  ; clear mul1_1
	    CLRF 0x86  ; clear mul1_2
	    MOVFF 0x80, 0x87 ;mul1_3
	    MOVFF 0x81, 0x88 ;mul1_4
	    
	    CLRF 0x95  ; clear mul2_1
	    CLRF 0x96  ; clear mul2_2
	    MOVFF 0x82, 0x97 ;mul2_3
	    MOVFF 0x83, 0x98 ;mul2_4

	    MOVLF d'16', 0x8B; iteration
	    BCF STATUS, 0
	    RLCF 0x88 ; mul1 rotate left with carry
	    RLCF 0x87 ; mul1 rotate left with carry
	    RLCF 0x86 ; mul1 rotate left with carry
	    RLCF 0x85 ; mul1 rotate left with carry

	mul:	    
	    CLRF WREG
	    BCF STATUS, 0
	    RRCF 0x85 ; mul1 rotate right
	    RRCF 0x86 ; mul1 rotate right
	    RRCF 0x87 ; mul1 rotate right
	    RRCF 0x88 ; mul1 rotate right 
	    BTFSC 0x88, 0 ;check first bit
	    GOTO add

	    ;;maybe I can do it with shifting?? Nahhhh I'm lazy
	    MOVF 0x98 ,W ; mul2_4 *= 2
	    ADDWF 0x98, F ; mul2_4 *= 2

	    MOVF 0x97, W  ; mul2_3 * 2 + carry
	    ADDWFC 0x97, F ; mul2_3 * 2 + carry

	    MOVF 0x96, W  ; mul2_2 * 2 + carry
	    ADDWFC 0x96, F ; mul2_2 * 2 + carry

	    MOVF 0x95, W  ; mul2_1 * 2 + carry
	    ADDWFC 0x95, F ; mul2_1 * 2 + carry

	    DECFSZ 0x8B
	    GOTO mul
	    GOTO sign

	add:

	    MOVF 0x98, W ;mul2_4 -> WREG
	    ADDWF 0x93, F ;mul2_4 + ans_4

	    MOVF 0x97, W ;mul2_3-> WREG
	    ADDWFC 0x92, F ;mul2_3 + ans_3 + carry

	    MOVF 0x96, W ;mul2_2-> WREG
	    ADDWFC 0x91, F ;mul2_2 + ans_2 + carry

	    MOVF 0x95, W ;mul2_1-> WREG
	    ADDWFC 0x90, F ;mul2_1 + ans_1 + carry

	    CLRF WREG

	    MOVF 0x98 ,W ; mul2_4 *= 2
	    ADDWF 0x98, F ; mul2_4 *= 2

	    MOVF 0x97, W  ; mul2_3 * 2 + carry
	    ADDWFC 0x97, F ; mul2_3 * 2 + carry

	    MOVF 0x96, W  ; mul2_2 * 2 + carry
	    ADDWFC 0x96, F ; mul2_2 * 2 + carry

	    MOVF 0x95, W  ; mul2_1 * 2 + carry
	    ADDWFC 0x95, F ; mul2_1 * 2 + carry

	    DECFSZ 0x8B
	    GOTO mul
	    GOTO sign

	sign:
	    BTFSC 0x8A, 0
	    GOTO comp
	    GOTO stop

	comp:
	    CLRF WREG
	    COMF 0x93, F
	    COMF 0x92, F
	    COMF 0x91, F
	    COMF 0x90, F
	    INCF 0x93, F
	    ADDWFC 0x92, F
	    ADDWFC 0x91, F
	    ADDWFC 0x90, F

	stop:
	    ; Done!, Clean Up!
	    CLRF 0x80
	    CLRF 0x81
	    CLRF 0x82
	    CLRF 0x83
	    CLRF 0x95
	    CLRF 0x96
	    CLRF 0x97
	    CLRF 0x98
	    CLRF 0x8A
	    NOP 
	    end

