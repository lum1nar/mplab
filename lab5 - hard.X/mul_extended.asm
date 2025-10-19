#include "xc.inc"
BCF WDTCON, 0
GLOBAL _mul_extended
PSECT mytext, local, class=CODE, reloc=2

MOVLF macro literal, address
    MOVLW literal
    MOVWF address
endm

;; For midtrem: This can be rewritten to a 16 bit Multiplier

_mul_extended:

	
    BTFSC 0x02, 7
    GOTO neg1
    GOTO next

    neg1: 
     ;;2s complement
	CLRF WREG
	COMF 0x02, F
	COMF 0x01, F
	INCF 0x01, F
	ADDWFC 0x02, F

	BTG 0x025,0;SIGNED

    next:
	BTFSC 0x04, 7
	GOTO neg2
	GOTO mulinit

    neg2:
    ;;2s complement
	CLRF WREG
	COMF 0x04, F
	COMF 0x03, F
	INCF 0x03, F
	ADDWFC 0x02, F

	BTG 0x025,0;SIGNED

    mulinit:
	
	MOVFF 0x02, 0x07 ;mul1_3
	MOVFF 0x01, 0x08 ;mul1_4
	MOVFF 0x04, 0x17 ;mul2_3
	MOVFF 0x03, 0x18 ;mul2_4

	MOVLW 16; iteration
	MOVWF 0x26 ; iteration_addr
	BCF STATUS, 0
	RLCF 0x08 ; 0x07 rotate right with carry
	RLCF 0x07 ; 0x08 rotate right with carry
	RLCF 0x06 ; 0x08 rotate right with carry
	RLCF 0x05 ; 0x08 rotate right with carry

    mul:	    
	CLRF WREG
	BCF STATUS, 0
	RRCF 0x05 ;rotate right
	RRCF 0x06 ;rotate right
	RRCF 0x07 ;rotate right
	RRCF 0x08 ;rotate right 
	BTFSC 0x08, 0 ;check first bit
	GOTO add
	
	;;maybe I can do it with shifting?? 
	MOVF 0x18 ,W ; mul2_4 *= 2
	ADDWF 0x18, F ; mul2_4 *= 2
	
	MOVF 0x17, W  ; mul2_3 * 2 + carry
	ADDWFC 0x17, F ; mul2_3 * 2 + carry
	
	MOVF 0x16, W  ; mul2_2 * 2 + carry
	ADDWFC 0x16, F ; mul2_2 * 2 + carry
	
	MOVF 0x15, W  ; mul2_1 * 2 + carry
	ADDWFC 0x15, F ; mul2_1 * 2 + carry
	
	DECFSZ 0x26
	GOTO mul
	GOTO sign

    add:

	MOVF 0x18, W ;mul2_4 -> WREG
	ADDWF 0x14, F ;mul2_4 + ans_4
	
	MOVF 0x017, W ;mul2_3-> WREG
	ADDWFC 0x13, F ;mul2_3 + ans_3 + carry
	
	MOVF 0x016, W ;mul2_2-> WREG
	ADDWFC 0x12, F ;mul2_2 + ans_2 + carry
	
	MOVF 0x015, W ;mul2_1-> WREG
	ADDWFC 0x11, F ;mul2_1 + ans_1 + carry
	
	CLRF WREG
	
	MOVF 0x18 ,W ; mul2_4 *= 2
	ADDWF 0x18, F ; mul2_4 *= 2
	
	MOVF 0x17, W  ; mul2_3 * 2 + carry
	ADDWFC 0x17, F ; mul2_3 * 2 + carry
	
	MOVF 0x16, W  ; mul2_2 * 2 + carry
	ADDWFC 0x16, F ; mul2_2 * 2 + carry
	
	MOVF 0x15, W  ; mul2_1 * 2 + carry
	ADDWFC 0x15, F ; mul2_1 * 2 + carry
	
	DECFSZ 0x26
	GOTO mul
	GOTO sign

    sign:
	BTFSC 0x25, 0
	GOTO comp
	GOTO stop

    comp:
	CLRF WREG
	COMF 0x014, F
	COMF 0x013, F
	COMF 0x012, F
	COMF 0x011, F
	INCF 0x014, F
	ADDWFC 0x013, F
	ADDWFC 0x012, F
	ADDWFC 0x011, F

    stop:
	MOVFF 0x11, 0x04
	MOVFF 0x12, 0x03
	MOVFF 0x13, 0x02
	MOVFF 0x14, 0x01
	
	RETURN


	


