;���, ������� ��������� ��������� ������������ �������, �.�. �������� ������ ��������:

TrueMessageBoxA proc x:dword,x1:dword,x2:dword,x3:dword
        call SuspendThreads
        ;��������������� ������ �����
        invoke WriteProcessMemory,-1,RealAddr1,offset Old_Code1,size_code1,0
        push x3
        push x2
        push x1
        push x
        call MessageBoxA;�������� ������������ ������� MessageBoxA
        push eax
        invoke WriteProcessMemory,-1,RealAddr1,offset code1,size_code1,0;��������������� ��������
        call ResumeThreads
        pop eax
        ret
TrueMessageBoxA endp