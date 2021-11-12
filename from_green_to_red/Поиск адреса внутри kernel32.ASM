;#########################################################################
;Процедура GetKernelImport
;Поиск адреса внутри kernel32.dll
;Вход: ничего
;Выход:В eax - адрес внутри kernel32.dll
;#########################################################################
GetKernelImport proc
        push esi
        push ebx
        push edi

        call x
x:
        mov esi,dword ptr [esp];в esi - смещение данной команды
        add esp,4;выравниваем стек
        and esi,0FFFF0000h;используем гранулярность
y:
        call ValidPE;начало EXE-файла?
        .IF eax==0;если нет, то ищем дальше 
                sub esi,010000h
                jmp y
        .ENDIF

        mov ebx,esi;в ebx теперь будем хранить базу
        assume esi:ptr IMAGE_DOS_HEADER
        add esi,[esi].e_lfanew;в esi - заголовок PE

        assume esi:ptr IMAGE_NT_HEADERS
        lea esi,[esi].OptionalHeader;в esi - адрес опционального заголовка

        assume esi:ptr IMAGE_OPTIONAL_HEADER
        lea esi,[esi].DataDirectory;в esi - адрес DataDirectory

        add esi,8;в esi - элемент 1 в DataDirectory
        mov eax,ebx
        add eax,dword ptr [esi];в eax - смещение таблицы импорта
        mov esi,eax
        assume esi:ptr IMAGE_IMPORT_DESCRIPTOR
NextDLL:
        mov edi,[esi].Name1
        add edi,ebx
        .IF DWORD PTR [edi]=="NREK";черт, мы могли бы написать так: 
        ; .IF TBYTE PTR [edi]=="LLD.LENREK", но нас сдерживает формат машинной
                  ; команды Intel в которой константа может быть не более 4 байт
                ;нашли запись о kernel32!!!
                mov edi,[esi].FirstThunk
                add edi,ebx;в edi - VA массива IMAGE_THUNK_DATA         
                mov eax,dword ptr [edi];в eax адрес какой-то из функций kernel32.dll
                pop edi
                pop ebx
                pop esi
                ret
        .ENDIF
        add esi,sizeof IMAGE_IMPORT_DESCRIPTOR
        jmp NextDLL
GetKernelImport endp
;#########################################################################
;Конец процедуры GetKernelImport
;#########################################################################