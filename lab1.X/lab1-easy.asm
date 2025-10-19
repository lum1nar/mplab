List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00


	
	MOVLW 0xC2 ;x1
	MOVWF 0x00
	
	MOVLW 0x1E ;x2
	MOVWF 0x01
	
	MOVLW 0xF7 ;y1 
	MOVWF 0x02
	
	MOVLW 0xBF ;y2
	MOVWF 0x03
	
	
	MOVF 0x00, W
	ADDWF 0x01, W
	
	MOVWF 0x10
	
	MOVF 0x03, W
	SUBWF 0x02, W
	
	MOVWF 0x11
	
	CPFSGT 0x10 
	    GOTO WRITEONE
	    
	GOTO WRITEFF
	
	WRITEFF:
	    MOVLW 0xFF
	    MOVWF 0x20
	    GOTO STOP
    
	WRITEONE:
	    MOVLW 0x01
	    MOVWF 0x20
	    GOTO STOP
	    
	STOP:
	end




