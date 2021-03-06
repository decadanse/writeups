;#########################################################################
;��������� GetKernelImport
;����� ������ ������ kernel32.dll
;����: ������
;�����:� eax - ����� ������ kernel32.dll
;#########################################################################
GetKernelImport proc
        push esi
        push ebx
        push edi

        call x
x:
        mov esi,dword ptr [esp];� esi - �������� ������ �������
        add esp,4;����������� ����
        and esi,0FFFF0000h;���������� �������������
y:
        call ValidPE;������ EXE-�����?
        .IF eax==0;���� ���, �� ���� ������ 
                sub esi,010000h
                jmp y
        .ENDIF

        mov ebx,esi;� ebx ������ ����� ������� ����
        assume esi:ptr IMAGE_DOS_HEADER
        add esi,[esi].e_lfanew;� esi - ��������� PE

        assume esi:ptr IMAGE_NT_HEADERS
        lea esi,[esi].OptionalHeader;� esi - ����� ������������� ���������

        assume esi:ptr IMAGE_OPTIONAL_HEADER
        lea esi,[esi].DataDirectory;� esi - ����� DataDirectory

        add esi,8;� esi - ������� 1 � DataDirectory
        mov eax,ebx
        add eax,dword ptr [esi];� eax - �������� ������� �������
        mov esi,eax
        assume esi:ptr IMAGE_IMPORT_DESCRIPTOR
NextDLL:
        mov edi,[esi].Name1
        add edi,ebx
        .IF DWORD PTR [edi]=="NREK";����, �� ����� �� �������� ���: 
        ; .IF TBYTE PTR [edi]=="LLD.LENREK", �� ��� ���������� ������ ��������
                  ; ������� Intel � ������� ��������� ����� ���� �� ����� 4 ����
                ;����� ������ � kernel32!!!
                mov edi,[esi].FirstThunk
                add edi,ebx;� edi - VA ������� IMAGE_THUNK_DATA         
                mov eax,dword ptr [edi];� eax ����� �����-�� �� ������� kernel32.dll
                pop edi
                pop ebx
                pop esi
                ret
        .ENDIF
        add esi,sizeof IMAGE_IMPORT_DESCRIPTOR
        jmp NextDLL
GetKernelImport endp
;#########################################################################
;����� ��������� GetKernelImport
;#########################################################################