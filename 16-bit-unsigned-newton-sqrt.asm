List p=18f4520
    #include<p18f4520.inc>
	CONFIG OSC = INTIO67
	CONFIG WDT = OFF
    org 0x00
    
    MOVLF macro literal, address
    MOVLW literal
    MOVWF address
    endm
    
    ; This is a Sqrare Root Finder for 16 bit unsigned integer
    ; Put N in 0x050, 0x051
    ; Sqrt(N) in 0x052 0x053

    ; WARNING: IF N IS NOT A PERFECT SQUARE, USE ANOTHER SQUARE ROOT FINDER!!!! 
    ; WARNING: THIS ONE WILL GET STUCK AND IT'S NORMAL!!!

    ; Hi I'm Sasa

    
    MOVLF 0x00, 0x050 ;N_high
    MOVLF 0x40, 0x051 ;N_low
    MOVLF 0x00, 0x052 ;x0_high
    MOVLF 0x50, 0x053 ;x0_low
    RCALL newtonSqrt

    GOTO finish
    
    ; put dividend in 0x60 0x61
    ; put divisor  in 0x62 0x63
    ; quotient	   in 0x70 0x71
    ; remainder	   in 0x72 0x73
newtonSqrt:
    MOVLF d'16', 0x07A ;iteration count
    CLRF 0x070  ; quotient_high = 0
    CLRF 0x071  ; quotient_low = 0
    CLRF 0x072  ; remainder_high = 0
    CLRF 0x073  ; remainder_low = 0
    MOVFF 0x050, 0x60 ;dividend_high
    MOVFF 0x051, 0x61 ;dividend_low
    MOVFF 0x052, 0x62 ;divisor_high
    MOVFF 0x053, 0x63 ;divisor_low
    RCALL division
    
    MOVF 0x071, W      ; quotient_low -> W
    ADDWF 0x053, W     ; quotient_low + x0_low ? W
    MOVWF 0x053        ; ? x1_low
    MOVF 0x070, W      ; quotient_high -> W
    ADDWFC 0x052, W    ; quotient_high + x0_high + carry ? W
    MOVWF 0x052        ; ? x1_high
    
    BCF STATUS, 0 ;;!!!!!! clear the carry flag before rotate the high bits
    RRCF 0x052 ; / 2
    RRCF 0x053 ; / 2
    MOVF 0x052, W
    
    CPFSEQ  0x5E ;skip if squareroot_high == last_squareroot_high
    GOTO save
    MOVF 0x053, W
    CPFSEQ 0x5F ;skip if squareroot_low == last_squareroot_low
    GOTO save
    RETURN
    
save:
    MOVFF 0x052, 0x5E ;last_squareroot_high
    MOVFF 0x053, 0x5F ;last_squareroot_low
    GOTO newtonSqrt
    
division:
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

