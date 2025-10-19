#include <xc.h>
#pragma config WDT = OFF
extern unsigned int is_prime(unsigned char n);

void main(void){
    
    volatile unsigned char ans = is_prime(253); // the arg is passed to WREG since char is 4 bit
    while(1);
    return;
    
    
    
}
