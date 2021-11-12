;Приостановка всех потоков, кроме вызывающего
SuspendThreads proc
        invoke GetModuleHandle,offset kern
        invoke GetProcAddress,eax,offset OpenThreadStr
        mov _OpenThread,eax
        invoke GetCurrentThreadId
        mov CurrThread,eax
        invoke GetCurrentProcessId
        mov CurrProcess,eax

        invoke CreateToolhelp32Snapshot,TH32CS_SNAPTHREAD,0
        .if eax==-1
                xor eax,eax
                ret
        .endif
        mov hSnap,eax
        mov Thread.dwSize,sizeof THREADENTRY32
        invoke Thread32First,hSnap,offset Thread
        .if eax==0
                xor eax,eax
                ret
        .endif
NextThread:
        mov eax,CurrThread
        mov edx,CurrProcess
        .if (Thread.th32ThreadID!=eax)&&(Thread.th32OwnerProcessID==edx)
                push Thread.th32ThreadID
                push NULL
                push THREAD_SUSPEND_RESUME
                call _OpenThread
                mov ThreadHandle,eax
                .if ThreadHandle>0
                        invoke SuspendThread,ThreadHandle
                        invoke CloseHandle,ThreadHandle
                .endif
        .endif
        invoke Thread32Next,hSnap,offset Thread
        .if eax!=0
                jmp NextThread
        .endif 
        invoke CloseHandle,hSnap
        ret
SuspendThreads endp