;#########################################################################
;��������� GetAPIs
;��������� ������� ���� ��������� API-�������
;����: � edi ��������� �� ������ ASCIIZ ����� ���� �������
;       � ebx - �������� ������� ������� ���� ������� ��������� �������
;       � esi - ���� kernel32.dll
;       � ecx - ����� ������� GetProcAddress
;       � ���� �������� ���������� �������
;�����:����������� ��������������� ����
;#########################################################################
GetAPIs proc Number:DWORD
        Pushad
        mov eax,ecx
        mov ecx,Number
NextFunc:
        push eax
        push esi
        push edi
        push ebx
        push ecx

        push edi;��� �������
        push esi;���� kernel32
        call eax;����� GetProcAddress
        
        pop ecx
        pop ebx
        pop edi
        pop esi

        mov dword ptr [ebx],eax;�������� ����� ������� � ����������
        pop eax
        add ebx,4;��������� ����������
        push ecx;��������� �������
        mov ecx,30;��� ���������� �������
        push eax
        mov al,0;���� 0
        repne scasb  ;����� ���� ������ AL � ����� �� (E)CX ���� �� ������ ES:(E)DI
        pop eax
        pop ecx
        loop NextFunc
        popad
        ret
GetAPIs endp
;#########################################################################
;����� ��������� GetAPIs
;#########################################################################