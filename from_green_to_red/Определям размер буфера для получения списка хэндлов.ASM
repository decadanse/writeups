;NtQuerySystemInformation
;�� ����� ����, ���� ������ ������ ������ �������, �� �������� ReturnLength �� �����������.
;��� ��� ������ ������ �� �����������, �� ��� ����������� ����������� ���������� �������.
;���� ������� ���������� STATUS_INFO_LENGTH_MISMATCH, �� ������ ������ ������������.
;��� ��� ������� ������� ������ ������ ������:


;===============================================================================;
;               ��������� ������ ������ ��� ��������� ������ �������            
;===============================================================================;
        push offset SizeBuffer
        push 0
        push 0
        push 16;SystemHandleInformation
        call _NtQuerySystemInformation
        .if eax!=STATUS_INFO_LENGTH_MISMATCH
                jmp end_calc_size
        .endif
next_calc_size:
        add SizeBuffer,01000h;����������� ������ ������ �� ��������
        .if pSystemHandleInfo!=0
                invoke VirtualFree,pSystemHandleInfo, 0, MEM_RELEASE
        .endif
        invoke VirtualAlloc,NULL, SizeBuffer, MEM_COMMIT, PAGE_READWRITE
        mov pSystemHandleInfo,eax
        push offset uBuff
        push SizeBuffer
        push pSystemHandleInfo
        push 16
        call _NtQuerySystemInformation
        .if eax==STATUS_INFO_LENGTH_MISMATCH
                jmp next_calc_size
        .endif
end_calc_size:
;===============================================================================;