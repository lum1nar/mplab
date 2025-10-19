#include "xc.inc"
BCF WDTCON, 0
GLOBAL _count_primes
PSECT mytext, local, class=CODE, reloc=2

MOVLF macro literal, address
    MOVLW literal
    MOVWF address
endm

_count_primes:
    MOVLF 0xFF, 0x1F ;; not a prime
    MOVLF 0x01, 0x1E ;; prime
    
    MOVLW 1
    ADDWF 0x03, F
    MOVLW 0
    ADDWFC 0x04, F
    RCALL find_prime
    MOVFF 0x0A0, 0x01
    MOVFF 0x0A1, 0x02
    RETURN
 

find_prime:

      
    
    find_loop:
    RCALL is_prime
    
    MOVF 0x00, W
    
    CPFSEQ 0x1F ;skip if 0x00 is not a prime 
    GOTO ansplus1
    GOTO nplus1
    
ansplus1:
    MOVLW 1
    ADDWF 0x0A0, F
    MOVLW 0
    ADDWFC 0x0A1, F
    ;0x00 is not a prime 
    
nplus1:
    ;n += 1
    MOVLW 1
    ADDWF 0x01, F
    MOVLW 0
    ADDWFC 0x02, F
    
    ; next prime
    MOVF 0x01, W
    CPFSEQ 0x03 ;skip if n_low = m_low
    goto find_prime
    MOVF 0x02, W ; n_low = m_low
    CPFSEQ 0x04 ;skip if n_high = m_high
    goto find_prime
    RETURN ;n_high = m_high
    

is_prime:
    
    MOVFF 0x01, 0x051; N_low -> 0x051 for sqrt
    MOVFF 0x02, 0x050; N_high -> 0x050 for sqrt
    
    MOVFF 0x01, 0x008; N_low -> 0x008 for dividend
    MOVFF 0x02, 0x007; N_high -> 0x007 for dividend

    MOVLF 0x01, 0x00 ; Suppose it is a prime until we find its divisor
    
    ;check if N_HIGH != 0 && N_low == 1 or 2
    MOVLF 0x01, 0x0E 
    MOVLF 0x02, 0x0F 
    ;MOVF 0x050
    MOVF 0x050, W ;N_high -> WREG
    CPFSEQ 0x0D; if N_high == 0 skip next line
    GOTO not1or2 ;N_high != 0
    ;N_high == 0
    MOVF 0x051, W ;N_low -> WREG 
    CPFSEQ 0x0E ; if 0x51 == 0x0E -> WREG = 0x01 skip next line
    GOTO not1
    GOTO notprime;WREG==1
    
not1:
    CPFSEQ 0x0F ; if 0x51 == 0x0F -> WREG = 0x02 skip next line
    GOTO not1or2
    RETURN ;WREG==2
    
not1or2:  
    CLRF 0x0E
    CLRF 0x0F

    MOVLF 0x00, 0x052 ;x0_high 
    MOVLF 0x50, 0x053 ;x0_low ;; Don't change it 50 work fine with N == 3

    ; This is a Sqruare Finder for 16bit unsigned integer
    ; Put N in 0x050, 0x051
    ; Sqrt(N) in 0x052 0x053
    MOVLF 0x05, 0x17 ;0x17- > squareroot counter : doing 5 times is enough
    RCALL newtonSqrt
    
     ; sqrtn += 1
    MOVLW 1
    ADDWF 0x53, F ;divisor_low
    MOVLW 0
    ADDWFC 0x52, F ;divisor_high
    
    MOVLF 0, 0x10 ;divisor_high
    MOVLF 2, 0x11 ;divisor_low
    
    MOVFF 0x052, 0x022 ;; 0x022 -> sqrtn_high -> max -> i don;t reaaly need this, I can just use 0x52 but just in case
    MOVFF 0x053, 0x023 ;; 0x023 -> sqrtn_low -> max
    
    RCALL checkprime
    

    RETURN


checkprime:

    MOVLF 16, 0x07A ;iteration count

    CLRF 0x070  ; quotient_high = 0
    CLRF 0x071  ; quotient_low = 0
    CLRF 0x072  ; remainder_high = 0
    CLRF 0x073  ; remainder_low = 0
    MOVFF 0x011, 0x063 ; cur_divisor_low -> divisor_low
    MOVFF 0x010, 0x062 ; cur_divisor_high -> divisor_high
    MOVFF 0x007, 0x60 ; N_HIGH -> dividend_low
    MOVFF 0x008, 0x61 ; N_LOW -> dividend_low
    RCALL division
    
    ;check whether remainder == 0 if not, 
    MOVF 0x72, W
    CPFSEQ 0x10 ;skip if remainder_low == 0; do next line if remainder_low > 0 -> still a prime 0x10 is just 0
    GOTO adddivisor
    
    MOVF 0x73, W
    CPFSEQ 0x10 ;!!!!!!!!! maybe clrf 0x10 first?
    GOTO adddivisor

    ;; only get here if we found a divisor
notprime:
    MOVLF 0xFF, 0x00
    RETURN

    

adddivisor:  
    ; divisor += 1
    MOVLW 1
    ADDWF 0x11, F ;divisor_low
    MOVLW 0
    ADDWFC 0x10, F ;divisor_high

    ; check if divisor == sqrt -> not found
    MOVF 0x11, W
    CPFSEQ 0x23 ;skip if divisor_low == sqrt__low
    goto checkprime
    MOVF 0x10, W
    CPFSEQ 0x22 ;skip if divisor_high == divisor_high
    goto checkprime
    RETURN
    
    ; Put N in 0x050, 0x051
    ; Sqrt(N) in 0x052 0x053
    ; put dividend in 0x60 0x61
    ; put divisor  in 0x62 0x63
    ; quotient	   in 0x70 0x71
    ; remainder	   in 0x72 0x73
newtonSqrt:
    ;; !!!!!!!!!!!!!!!!!!! Clear quotient and remainder before use because it has different number everytime
    MOVLF 16, 0x07A ;iteration count
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
    
    DECFSZ 0x17 ;skip next line if iteration count == 0
    GOTO newtonSqrt
    RETURN

    
    
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
    

