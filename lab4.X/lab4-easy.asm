List p=18f4520
    #include<p18f4520.inc>
	CONFIG OSC = INTIO67
	CONFIG WDT = OFF
	org 0x00
    
    MOVLF macro literal, address
	MOVLW literal
	MOVWF address
    endm
	
    And_Mul macro xh, xl, yh, yl
	MOVLF xh, 0x02
	MOVLF xl, 0x03
	MOVLF yh, 0x04
	MOVLF yl, 0x05
	
	MOVF 0x02, W
	ANDWF 0x04, W
	MOVWF 0x00
	
	MOVF 0x03, W
	ANDWF 0x05, W
	MOVWF 0x01
	
	MOVF 0x00, W
	MULWF 0x01, W
	
	MOVFF PRODH, 0x010
	MOVFF PRODL, 0x011
		
    endm
    
   

    And_Mul 0x50, 0x6F, 0x3A, 0xBC
    NOP

    end











