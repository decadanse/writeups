call delta
delta:
        pop ebp
    sub ebp,offset delta


;еще один способ
d:      jmp c1
        x dw 0
c1:     lea ebp,x
        sub ebp,offset d
        sub ebp,2;в EBP - дельта смещение


;еще один способ2
d:      jmp c1
        x db "Hello!!! I'm Crazy Virus",0
c1:     lea ebp,x
        sub ebp,offset d
        sub ebp,2;в EBP - дельта смещение;


;еще один способ3
mov ebx,old_size_of_infected_file;используем размер файла, до инфецирования
jmp ebx

;еще один способ4
m:      lea ebx,m
        sub ebx,offset m;в EBX - дельта смещение