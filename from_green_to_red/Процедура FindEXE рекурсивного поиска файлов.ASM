;#################################################################
;��������� FindEXE ������������ ������ ������ 
;����: Dir - ����� ASCIIZ-������ � ������ ���������� ��� ����������� �����
;       Mask2 -����� ASCIIZ-������ "*.*",0 
;#################################################################
FindEXE proc Dir:DWORD, Mask2:DWORD
LOCAL Find:WIN32_FIND_DATA
LOCAL hFile:DWORD
LOCAL Path[1000]:BYTE
pushad
;#############################��������� ����������� ����##############################
invoke lstrlen,Dir;��������� ����� ����������� ����

mov esi,Dir
lea edi,Path
mov ecx,eax
rep movsb;�������� � Path - ���� ��� ������

lea edi,Path
add edi,eax
mov esi,Mask2
mov ecx,5
rep movsb;Path=Path+Mask+\0
;#############################��������� ����������� ����##############################

lea ebx,Find
lea edi,Path
invoke FindFirstFile,edi,ebx;������ ������
.IF eax!=INVALID_HANDLE_VALUE;���� ������ ������ ������
        mov hFile,eax
invoke FindNextFile,hFile,ADDR Find;����������� ������
.WHILE eax!=0;���� ����������� ������ ������
        mov ebx,Find.dwFileAttributes
        and ebx,FILE_ATTRIBUTE_DIRECTORY
        lea ecx,Find.cFileName
        .IF (ebx==FILE_ATTRIBUTE_DIRECTORY) && (byte ptr [ecx]!='.')
                lea ebx,Path
;####################������� '\*.*'#########################################
                push ebx
                push ebx
                call lstrlen
                pop ebx
                add ebx,eax
                sub ebx,3
                mov edi,ebx
                mov eax,0
                mov ecx,3
                cld
                rep stosb;������� �����
;####################END ������� '\*.*'#########################################
;#######################��������� ��� ���������� � ������######################
                lea ebx,Path
                push ebx
                call lstrlen
                add ebx,eax
                mov edi,ebx
                
                push edi
                lea edx,Find.cFileName
                push edx
                call lstrlen    
                mov ecx,eax
                inc ecx
                pop edi

                lea edx,Find.cFileName
                mov esi,edx
                cld
                rep movsb
                mov byte ptr [edi],0
;#######################END ��������� ��� ���������� � ������##################
                lea ebx,Path
                push Mask2
                push ebx
                call FindEXE;����������� �����
                std
                
                lea ebx,Path
                push ebx
                call lstrlen
                add ebx,eax
                mov edi,ebx

                mov ecx,10000
                mov al,'\'
                repne scasb
                add edi,2
                mov ecx,3
                mov eax,0f3h
                cld
                rep stosb
                mov byte ptr [edi],0
        .ELSE
;###############################�� EXE �� ���#########################################
                lea ebx,Find.cFileName;�� exe �� ���?
                push ebx
                push ebx
                call lstrlen
                pop ebx
                add ebx,eax
                sub ebx,4
                .IF (dword ptr [ebx]=='exe.')||(dword ptr [ebx]=='EXE.')
                        ;EXE ���� ������!!!     
                .ENDIF
;###############################�� EXE �� ���#########################################
        .ENDIF
        invoke FindNextFile,hFile,ADDR Find;����������� ������
.ENDW           
.ENDIF
popad
ret     
FindEXE endp
;#################################################################
;����� ��������� FindEXE ������������ ������ ������ 
;#################################################################