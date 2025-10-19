List p=18f4520
    #include<p18f4520.inc>
	CONFIG OSC = INTIO67
	CONFIG WDT = OFF
	org 0x00
	
    MOVLF macro literal, register
	MOVLW literal
	MOVWF register
    endm
    
   

    MOVLW d'5'
    MOVLF d'5', 0x00
    NOP
    NOP
    NOP


    end








