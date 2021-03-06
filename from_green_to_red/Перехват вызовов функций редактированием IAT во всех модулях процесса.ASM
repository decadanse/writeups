; ��������� EditIATGlobal ������ IAT ���� ������� ��������, � ������� ��� ����������.
;�� �������� �� � ��������� DllMain DLL, ������� �� ����� �������� � �������� ������������
;��������-������. ��� ������ ����������� ��� ������ � �������� ������������ ��������
;�������� � ������� ToolHelp-�������, � ����� ��������������� �������� ��� �������
;������ ��������� EditIATLocal

;===============================================================================;
;��������� EditIATGlobal                                                        
;��������:
;�������� ������� ������� ��������������� IAT �� ���� ������� ��������
;����: Address ����� ������ ����� � ������
;       ModName - ��������� �� ��� ������, IAT �������� �� ����� �������. 
;   ������� �� �����.
;       Orig - ����� �������, ������� �������������
;       New - ����� ������ �����������
;�����: ���
;===============================================================================;
EditIATGlobal proc ModName:DWORD, Orig:DWORD, New:DWORD
LOCAL Current:DWORD
LOCAL hSnap:DWORD
        push offset NextMod
        call GetBase
        mov Current,eax;�������� ����� ������ ������
        mov ecx,eax
        invoke CreateToolhelp32Snapshot,TH32CS_SNAPMODULE,NULL
        mov hSnap,eax
        mov ModEntry.dwSize,sizeof MODULEENTRY32
        invoke Module32First,hSnap,offset ModEntry
NextMod:
        mov eax,Current
        .IF eax!=ModEntry.hModule;� ����� ������ �� ����� �������������!
                push ModEntry.hModule
                push New
                push Orig
                push ModName
                call EditIATLocal;������������� � ���� ������
        .ENDIF
        invoke Module32Next,hSnap,offset ModEntry;��������� ������
        .IF eax!=0 
                jmp NextMod
        .ENDIF
        invoke CloseHandle,hSnap
        mov eax,1
        ret
EditIATGlobal endp
;===============================================================================;