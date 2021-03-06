;��������� GetGetProcAddress
;����� ������ ������ kernel32.dll
;����: � ���� �������� �������� ����� "GetProcAddress"
;       ebx - ���� kernel32.dll
;�����:� eax - ����� ������� GetProcAddress
;#########################################################################
GetGetProcAddress proc NameFunc:DWORD
        pushad;��������� ��������
        mov esi,ebx
        assume esi:ptr IMAGE_DOS_HEADER
        add esi,[esi].e_lfanew;� esi - ��������� PE

        assume esi:ptr IMAGE_NT_HEADERS
        lea esi,[esi].OptionalHeader;� esi - ����� ������������� ���������

        assume esi:ptr IMAGE_OPTIONAL_HEADER
        lea esi,[esi].DataDirectory;� esi - ����� DataDirectory
        mov esi,dword ptr [esi]
        add esi,ebx;� esi - ��������� IMAGE_EXPORT_DIRECTORY
        push esi
        assume esi:ptr IMAGE_EXPORT_DIRECTORY
        mov esi,[esi].AddressOfNames
        add esi,ebx;� esi - ������ ���� �������
        xor edx,edx;� edx - ������ ������

        mov eax,esi
        mov esi,dword ptr [esi]
NextName:;����� ���������� ����� �������
        add esi,ebx
        mov edi,NameFunc
        mov ecx,14;���������� ���� � "GetProcAddress"
        cld     ;�������� cld ��������� ���� ����������� (DF)
                ;����������, ����������� �������� ��������, ���������� std.
        repe cmpsb
        ;���������� cmpsb. ��� ���������� ����� (%esi) � (edi)
        ;� ���������� ����� � ������������ � ����������� ���������
        ;������� rep, repe ��������� ���������� �������� � �������� ecx ���������� ���
        .IF ecx==0;����� ���
                jmp GetAddr
        .ENDIF
        inc edx
        add eax,4
        mov esi,dword ptr [eax]
        jmp NextName
GetAddr:;���� ����� "GetProcAddress"
        pop esi
        mov edi,esi
        mov esi,[esi].AddressOfNameOrdinals
        add esi,ebx;� esi - ������ ���� � ���������
        mov dx,word ptr [esi][edx*2]
        assume edi:ptr IMAGE_EXPORT_DIRECTORY
        sub edx,[edi].nBase;�������� ��������� �������
        inc edx;�.�. ��������� ������� ���������� � 1
        mov esi,[edi].AddressOfFunctions
        add esi,ebx;� esi - ������ ������� �������
        mov eax,dword ptr [esi][edx*4]
        add eax,ebx;� eax - ����� ������� GetProcAddress
        mov NameFunc,eax
        popad;��������������� ��������
        mov eax,NameFunc
        ret
GetGetProcAddress endp  
;#########################################################################
;����� ��������� GetGetProcAddress
;#########################################################################