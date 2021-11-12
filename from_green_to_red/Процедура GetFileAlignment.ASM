;####################################################
;Процедура GetFileAlignment
;Получение выровненного-вверх значения
;Вход:  esi - указатель на строку с именем файла
;Выход: eax - значение FileAlignment
;!!!!!!!Процедура не сохраняет регистры!!!!!!!!!!!!!!
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
;##################Проверка правильности PE-файла и ошибок при проекции###########
        .IF eax==0;ошибки при проецировании
                invoke CloseHandle,hFile1
                invoke CloseHandle,hMapping1
                mov eax,0
                ret
        .ENDIF
        mov esi,eax
        call ValidPE
        .IF eax==0;EXE-файл не корректный
                push esi
                call UnmapViewOfFile
                invoke CloseHandle,hFile1
                invoke CloseHandle,hMapping1
                mov eax,0
                ret
        .ENDIF
;##############END Проверка правильности PE-файла и ошибок при проекции###########
;#####################Получение адреса PE-заголовка###############################
assume edi:ptr IMAGE_DOS_HEADER
mov edi,esi
add edi,[edi].e_lfanew
;#####################END Получение адреса PE-заголовка###########################
;#####################Получение адреса файлового заголовка########################
add edi,4
;#####################END Получение адреса файлового заголовка####################
;#####################Получение адреса опционального заголовка####################
add edi,sizeof IMAGE_FILE_HEADER
assume edi:ptr IMAGE_OPTIONAL_HEADER
invoke CloseHandle,hFile1
invoke CloseHandle,hMapping1
mov eax,[edi].FileAlignment
;#####################END Получение адреса опционального заголовка################      
ret
GetFileAlignment endp
;####################################################
;Конец Процедуры GetFileAlignment
;####################################################