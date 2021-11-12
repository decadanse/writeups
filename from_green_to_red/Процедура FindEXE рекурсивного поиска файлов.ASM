;#################################################################
;Процедура FindEXE рекурсивного поиска файлов 
;Вход: Dir - адрес ASCIIZ-строки с именем директории где производить поиск
;       Mask2 -адрес ASCIIZ-строки "*.*",0 
;#################################################################
FindEXE proc Dir:DWORD, Mask2:DWORD
LOCAL Find:WIN32_FIND_DATA
LOCAL hFile:DWORD
LOCAL Path[1000]:BYTE
pushad
;#############################Обработка переданного пути##############################
invoke lstrlen,Dir;вычисляем длину переданного пути

mov esi,Dir
lea edi,Path
mov ecx,eax
rep movsb;получаем в Path - путь для поиска

lea edi,Path
add edi,eax
mov esi,Mask2
mov ecx,5
rep movsb;Path=Path+Mask+\0
;#############################Обработка переданного пути##############################

lea ebx,Find
lea edi,Path
invoke FindFirstFile,edi,ebx;начало поиска
.IF eax!=INVALID_HANDLE_VALUE;если начало поиска удачно
        mov hFile,eax
invoke FindNextFile,hFile,ADDR Find;продолжение поиска
.WHILE eax!=0;если продолжение поиска удачно
        mov ebx,Find.dwFileAttributes
        and ebx,FILE_ATTRIBUTE_DIRECTORY
        lea ecx,Find.cFileName
        .IF (ebx==FILE_ATTRIBUTE_DIRECTORY) && (byte ptr [ecx]!='.')
                lea ebx,Path
;####################Удаляем '\*.*'#########################################
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
                rep stosb;удаляем маску
;####################END Удаляем '\*.*'#########################################
;#######################Добавляем имя директории к строке######################
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
;#######################END Добавляем имя директории к строке##################
                lea ebx,Path
                push Mask2
                push ebx
                call FindEXE;рекурсивный вызов
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
;###############################Не EXE ли это#########################################
                lea ebx,Find.cFileName;не exe ли это?
                push ebx
                push ebx
                call lstrlen
                pop ebx
                add ebx,eax
                sub ebx,4
                .IF (dword ptr [ebx]=='exe.')||(dword ptr [ebx]=='EXE.')
                        ;EXE ФАЙЛ НАЙДЕН!!!     
                .ENDIF
;###############################Не EXE ли это#########################################
        .ENDIF
        invoke FindNextFile,hFile,ADDR Find;продолжение поиска
.ENDW           
.ENDIF
popad
ret     
FindEXE endp
;#################################################################
;Конец Процедуры FindEXE рекурсивного поиска файлов 
;#################################################################