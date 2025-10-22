#include <xc.h>
#pragma config WDT = OFF
extern long mul_extended(int n, int m);

void main(void){
    
    volatile long ans = mul_extended(1, 20); // the arg is passed to WREG since char is 4 bit
        while(1);
    return;
    
    
    
}
