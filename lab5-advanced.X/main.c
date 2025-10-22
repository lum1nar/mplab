
#include <xc.h>
#pragma config WDT = OFF
extern unsigned int count_primes(unsigned int n, unsigned int m);

void main(void){
    
    volatile unsigned int ans = count_primes(1,20); // the arg is passed to WREG since char is 4 bit
    while(1);
    return;
    
    
    
}
