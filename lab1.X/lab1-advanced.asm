List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00


	initial:
	    MOVLW b'00000000'
	    MOVWF 0x00
	    
	    MOVLW d'8'
	    MOVWF 0x02
	    
	    CLRF 0x01
	    
	start:
	    BTFSS 0x00,7
		GOTO CLZ
	    GOTO STOP
	    
	    
	CLZ:
	    INCF 0x01
	    RLNCF 0x00
	    
	    DECFSZ 0x02
		GOTO start
	    
	STOP:
	end

