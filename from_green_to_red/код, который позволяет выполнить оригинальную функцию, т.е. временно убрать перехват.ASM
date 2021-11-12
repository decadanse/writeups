;код, который позволяет выполнить оригинальную функцию, т.е. временно убрать перехват:

TrueMessageBoxA proc x:dword,x1:dword,x2:dword,x3:dword
        call SuspendThreads
        ;восстанавливаем старые байты
        invoke WriteProcessMemory,-1,RealAddr1,offset Old_Code1,size_code1,0
        push x3
        push x2
        push x1
        push x
        call MessageBoxA;вызываем оригинальную функцию MessageBoxA
        push eax
        invoke WriteProcessMemory,-1,RealAddr1,offset code1,size_code1,0;восстанавливаем перехват
        call ResumeThreads
        pop eax
        ret
TrueMessageBoxA endp