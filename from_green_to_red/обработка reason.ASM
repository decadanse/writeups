;� ������� DLLMain DLL, ������� �� ������������ ����� �������� �� ��� ��������
;�� ������ ������������ reason ��������� �������:

DllEntry proc hInstance:HINSTANCE, reason:DWORD, reserved1:DWORD
        push esi
        push edi
        push ebx
        push ebp
        .if reason==DLL_PROCESS_ATTACH
            ;�������� ��������� ������, ��� ���-�� ��������������� �������
                invoke GetModuleHandle,offset nt
                invoke GetProcAddress,eax,offset Exitstr;ExitStr - ��� ��������������� �������
                push offset start
                push eax
                push offset nt
                ;������������� �������� ������� Exitstr �� ������ nt.
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