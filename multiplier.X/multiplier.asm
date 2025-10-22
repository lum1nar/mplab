    List p=18f4520
	#include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00
	    MOVLW 0x9A ;hex1h
	    MOVWF 0x00

	    MOVLW 0xBC ;hex1l
	    MOVWF 0x01
 
	    MOVLW 0x12 ;hex2h
	    MOVWF 0x02 

	    MOVLW 0x34 ;hex2l
	    MOVWF 0x03

	    ;USE COMF TO GET 2's COMPLEMENT INSTEAD OF BTG
	    
	    ;BTG 0x02, 0 ;This is terrible
	    ;BTG 0x02, 1
	    ;BTG 0x02, 2
	    ;BTG 0x02, 3
	    ;BTG 0x02, 4
	    ;BTG 0x02, 5
	    ;BTG 0x02, 6
	    ;BTG 0x02, 7
	    ;INCF 0x02

	    ;BTG 0x03, 0
	   ; BTG 0x03, 1
	    ;BTG 0x03, 2
	    ;BTG 0x03, 3
	    ;BTG 0x03, 4
	    ;BTG 0x03, 5
	    ;BTG 0x03, 6
	    ;BTG 0x03, 7
	    ;INCF 0x03
	    
	    COMF 0x02
	    INCF 0x02
	    
	    COMF 0x03
	    INCF 0x03
	    
	    
	Add:
	    CLRF WREG
	    ADDWF 0x01, W
	    ADDWF 0x03, W
	    
	    TSTFSZ 0x03
	    GOTO Check
	    GOTO Zero
	    
	Zero:
	    BSF STATUS, C
	    
	Check:
	    BC Carry
	    GOTO NoCarry

	Carry:
	    MOVWF 0x021
	    CLRF WREG
	    ADDWF 0x02, W
	    ADDWF 0x00, W
	    MOVWF 0x020
    	    GOTO STOP

	NoCarry:
	    MOVWF 0x021
    	    DECF 0x00
	    CLRF WREG
	    ADDWF 0x02, W
	    ADDWF 0x00, W

	    MOVWF 0x020
	    GOTO STOP   



	STOP:

	    end


