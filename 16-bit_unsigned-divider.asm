List p=18f4520
    #include<p18f4520.inc>
	CONFIG OSC = INTIO67
	CONFIG WDT = OFF
    org 0x00
    
    MOVLF macro literal, address
    MOVLW literal
    MOVWF address
    endm

    ; put dividend in 0x60 0x61
    ; put divisor  in 0x62 0x63
    ; quotient	   in 0x70 0x71
    ; remainder	   in 0x72 0x73
    ; change the next to 16 for cx8
    
    MOVLF d'16', 0x07A ;iteration count
    MOVLF 0xFA, 0x60 ;dividend_high
    MOVLF 0x9F, 0x61 ;dividend_low
    MOVLF 0x03, 0x62 ;divisor_high
    MOVLF 0x45, 0x63 ;divisor_low
    RCALL division
    GOTO finish
    
    
division:
    BCF STATUS, 0 ;;!!!!!! clear the carry flag before rotate the high bits
    RLCF 0x61 ;dividend_low rotate left and store carry
    RLCF 0x60 ;dividend_high rotate left with carry of dividend_low
    RLCF 0x73 ; remainder_low rotate left with carry of dividend_high
    RLCF 0x72 ; remainder_high rotate left with carry of remainder_low
    
    MOVF 0x63, W ;divisor_low -> wreg
    SUBWF 0x073, F ;remainder_low - divisor_low
    MOVF 0x62, W ;divisor_high -> wreg
    SUBWFB 0x072, F ;remainder_high - divisor_high - borrow
    
    
    
    ;if no carry -> neg
    ;rotate quotient left and set the LSB to 0
    ;restore remainder_low !beware of the carry
    BNC neg ;!!!!!!!!!!!!!!!!!!!!!!!!!!! use BNC instead of BN e.g. 0x01 - 0xFF will be positive due to overflow
    
    ;if carry -> pos
    ;rotate quotient left and set the LSB to 1
    GOTO pos
neg:
    RLCF 0x071 ;rotate quotient_low left with carry
    RLCF 0x070 ;rotate quotient_high left with carry
    BCF 0x071, 0 ;set the LSB to 0
    
    MOVF 0x63, W ;divisor_low -> wreg
    ADDWF 0x073, F ;remainder_low + divisor_low
    MOVF 0x62, W ;divisor_high -> wreg
    ADDWFC 0x072, F ;remainder_high + divisor_high + carry
    GOTO next_div
    
pos:
    RLCF 0x071 ;rotate quotient_low left with carry
    RLCF 0x070 ;rotate quotient_high left with carry
    BSF 0x071, 0 ;set the LSB to 1
    GOTO next_div

next_div:
    DECFSZ 0x07A ;skip next line if iteration count == 0
    GOTO division
    RETURN
    
finish:
    end


