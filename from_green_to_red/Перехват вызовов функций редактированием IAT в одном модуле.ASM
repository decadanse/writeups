;��������, �� ������������� �������, ����� ������� X.
;����� ��������� EditIATLocal  ����������� ������� ������� ���������� ������ � ����
;��� ��������� ��� ����� X, �� ������� ������ X �� ����� ������ �����������, �������
;����� ���������� ��� �������� �������.

;===============================================================================;
;��������� EditIATLocal                                                 
;��������:
;�������� ������� ������� ��������������� IAT � ����� ������
;����: Address ����� ������ ����� � ������
;       ModName - ��������� �� ��� ������, IAT �������� �� ����� �������. ������� 
;   �� �����.
;       Orig - ����� �������, ������� �������������
;       New - ����� ������ �����������
;       ModHandle - ��������� ������, ��� ���������� ������� ��� ���������. 
;   ��������, ��������� KERNEL32.DLL
;�����: 1 - �����������, 0 - �� �����������
;===============================================================================;
EditIATLocal proc ModName:DWORD, Orig:DWORD, New:DWORD, ModHandle:DWORD
LOCAL OldProtect:DWORD
;�������� ����� ������� ����������
        mov eax,ModHandle
        assume eax:ptr IMAGE_DOS_HEADER
        add eax,[eax].e_lfanew
        add eax,4
        add eax,sizeof IMAGE_FILE_HEADER        
        mov edi,eax
        assume edi:ptr IMAGE_OPTIONAL_HEADER
        lea edi,[edi].DataDirectory
        mov eax,edi
;�������� ����� ������� �������
        assume eax:ptr IMAGE_DATA_DIRECTORY
        lea eax,[eax+(sizeof IMAGE_DATA_DIRECTORY)*IMAGE_DIRECTORY_ENTRY_IMPORT]
        .IF dword ptr [eax]==0 
                move ax,FALSE
                ret;��� ������� �������
        .ENDIF
        mov esi,ModHandle
        add esi,dword ptr [eax];� esi - ����� ������� �������
        assume esi:PTR IMAGE_IMPORT_DESCRIPTOR
NextDLL:;��������� ������ � ������� �������
        .IF [esi].Name1==NULL;����� ������� �������?
                mov eax,FALSE
                ret
        .ENDIF 
        mov ecx,[esi].Name1
        add ecx,ModHandle
        invoke lstrcmpi,ModName,ecx;��� �� ��� ������?
        .IF EAX!=0
                add esi,sizeof IMAGE_IMPORT_DESCRIPTOR
                jmp NextDLL
        .ENDIF
;���� ����� �� ����, �� ����� ��� ������
        mov edi,ModHandle
        add edi,[esi].FirstThunk;� EDI - IAT
        assume edi:PTR IMAGE_THUNK_DATA
NextFunction:;���������� ��� ������������� �������
        .IF [edi].u1.Function==0;IAT �����������
                add esi,sizeof IMAGE_IMPORT_DESCRIPTOR
                jmp NextDLL
        .ENDIF
        mov eax,[edi].u1.Function
        .IF Orig==eax;�����!!!
        ;�������� ������ �� ������ ��������
                invoke VirtualProtect,edi,4,PAGE_EXECUTE_READWRITE,ADDR OldProtect
                call GetCurrentProcess
                mov ecx,eax
                lea eax,New
                ;������ ����� ������� �� ����� �����������
                invoke WriteProcessMemory,ecx,edi,eax,4,NULL
                ;����������� ������� ���������
                invoke VirtualProtect,edi,4,OldProtect,ADDR OldProtect
                mov eax,TRUE
                ret
        .ENDIF  
        add edi,sizeof IMAGE_THUNK_DATA
        jmp NextFunction
EditIATLocal endp
;===============================================================================;