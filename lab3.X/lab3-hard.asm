    List p=18f4520
	#include<p18f4520.inc>
	    CONFIG OSC = INTIO67
	    CONFIG WDT = OFF
	    org 0x00
	    MOVLW 0xFE ;arg1
	    MOVWF 0x01

	    MOVLW 0xFC ;arg2 
	    MOVWF 0x02
 
	    CLRF 0x05 ;SIGNED
	    CLRF 0x04 ;[0x001 << n]
	    
	    BTFSC 0x01, 7
	    GOTO neg1
	    GOTO next
	
	neg1: 
	    COMF 0x01
	    INCF 0x01
	    BTG 0x005,0
    
	next:
	    BTFSC 0x02, 7
	    GOTO neg2
	    GOTO mulinit
	    	
	neg2:
	    COMF 0x02
	    INCF 0x02
	    BTG 0x005,0
	
	mulinit:
	    MOVFF 0x01, 0x04 ; [0x001 << n]
	    MOVLW 8; iteration
	    MOVWF 0x06 ; iteration
	    RLNCF 0x02 ; 0x02 rotate left
	    
	mul:	    
	    CLRF WREG
	    
	    RRNCF 0x02
	    BTFSC 0x02, 0
	    GOTO add
	    CLRF WREG ; i *= 2
	    ADDWF 0x04, W ; i *= 2
	    ADDWF 0x04, W ; i *= 2
	    MOVWF 0x04 ; i *= 2
	    DECFSZ 0x06
	    GOTO mul
	    GOTO sign
	
	add:
	    CLRF WREG
	    ADDWF 0x04, W
	    ADDWF 0x03, W
	    MOVWF 0x03
	    CLRF WREG ; i *= 2
	    ADDWF 0x04, W ; i *= 2
	    ADDWF 0x04, W ; i *= 2
	    MOVWF 0x04 ; i *= 2
	    DECFSZ 0x06
	    GOTO mul
	    GOTO sign
	    
	sign:
	    BTFSC 0x05, 0
	    GOTO comp
	    GOTO stop
	    
	comp:
	    COMF 0x03
	    INCF 0x03
	stop:
	    end


