;####################################################
;��������� GetFileAlignment
;��������� ������������-����� ��������
;����:  esi - ��������� �� ������ � ������ �����
;�����: eax - �������� FileAlignment
;!!!!!!!��������� �� ��������� ��������!!!!!!!!!!!!!!
;####################################################
GetFileAlignment proc
LOCAL hFile1:DWORD
LOCAL hMapping1:DWORD
;#########################Create File Mapping instructions########################
invoke CreateFile,esi,GENERIC_WRITE or  GENERIC_READ,FILE_SHARE_WRITE,NULL,
       OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
mov hFile1,eax
invoke CreateFileMapping,eax,NULL,PAGE_READWRITE,0,0,NULL
mov hMapping1,eax
invoke MapViewOfFile,eax,FILE_MAP_ALL_ACCESS,0,0,0
;#########################END Create File Mapping instructions####################
;##################�������� ������������ PE-����� � ������ ��� ��������###########
        .IF eax==0;������ ��� �������������
                invoke CloseHandle,hFile1
                invoke CloseHandle,hMapping1
                mov eax,0
                ret
        .ENDIF
        mov esi,eax
        call ValidPE
        .IF eax==0;EXE-���� �� ����������
                push esi
                call UnmapViewOfFile
                invoke CloseHandle,hFile1
                invoke CloseHandle,hMapping1
                mov eax,0
                ret
        .ENDIF
;##############END �������� ������������ PE-����� � ������ ��� ��������###########
;#####################��������� ������ PE-���������###############################
assume edi:ptr IMAGE_DOS_HEADER
mov edi,esi
add edi,[edi].e_lfanew
;#####################END ��������� ������ PE-���������###########################
;#####################��������� ������ ��������� ���������########################
add edi,4
;#####################END ��������� ������ ��������� ���������####################
;#####################��������� ������ ������������� ���������####################
add edi,sizeof IMAGE_FILE_HEADER
assume edi:ptr IMAGE_OPTIONAL_HEADER
invoke CloseHandle,hFile1
invoke CloseHandle,hMapping1
mov eax,[edi].FileAlignment
;#####################END ��������� ������ ������������� ���������################      
ret
GetFileAlignment endp
;####################################################
;����� ��������� GetFileAlignment
;####################################################