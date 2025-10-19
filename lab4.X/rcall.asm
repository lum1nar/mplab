List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	MOVLW d'3'
	MOVWF 0x00
	MOVLW d'5'
	RCALL label
	NOP
	NOP
	
    label:
	ADDWF 0x01, F
	DECFSZ 0x00
	GOTO label
	RETURN
	
	
	
	
	end





