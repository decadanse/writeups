;В функции DLLMain DLL, которую мы впоследствии будем внедрять во все процессы
;мы должны обрабатывать reason следующим образом:

DllEntry proc hInstance:HINSTANCE, reason:DWORD, reserved1:DWORD
        push esi
        push edi
        push ebx
        push ebp
        .if reason==DLL_PROCESS_ATTACH
            ;Получаем описатель модуля, где нах-ся перехватываемая функция
                invoke GetModuleHandle,offset nt
                invoke GetProcAddress,eax,offset Exitstr;ExitStr - имя перехватываемой функции
                push offset start
                push eax
                push offset nt
                ;Устанавливаем перехват функции Exitstr из модуля nt.
                call EditIATGlobal
        .elseif reason==DLL_PROCESS_DETACH

        .elseif reason==DLL_THREAD_ATTACH

        .else        ; DLL_THREAD_DETACH

        .endif
        pop ebp
        pop ebx
        pop edi
        pop esi
        mov  eax,TRUE
        ret
DllEntry Endp