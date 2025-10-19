# xc8 語法差異

1. 將十進位傳入 WREG
```asm
MOVLW d'16' -> X
MOVLW 16    -> O
```


2. 清空 Carry Flag
```asm
CLRF STATUS, C   -> X
CLRF STATUS, 0   -> O

```
