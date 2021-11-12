;Процедура GetGetProcAddress
;Поиск адреса внутри kernel32.dll
;Вход: в стек кладется смещение имени "GetProcAddress"
;       ebx - база kernel32.dll
;Выход:В eax - адрес функции GetProcAddress
;#########################################################################
GetGetProcAddress proc NameFunc:DWORD
        pushad;сохраняем регистры
        mov esi,ebx
        assume esi:ptr IMAGE_DOS_HEADER
        add esi,[esi].e_lfanew;в esi - заголовок PE

        assume esi:ptr IMAGE_NT_HEADERS
        lea esi,[esi].OptionalHeader;в esi - адрес опционального заголовка

        assume esi:ptr IMAGE_OPTIONAL_HEADER
        lea esi,[esi].DataDirectory;в esi - адрес DataDirectory
        mov esi,dword ptr [esi]
        add esi,ebx;в esi - структура IMAGE_EXPORT_DIRECTORY
        push esi
        assume esi:ptr IMAGE_EXPORT_DIRECTORY
        mov esi,[esi].AddressOfNames
        add esi,ebx;в esi - массив имен функций
        xor edx,edx;в edx - храним индекс

        mov eax,esi
        mov esi,dword ptr [esi]
NextName:;поиск следующего имени функции
        add esi,ebx
        mov edi,NameFunc
        mov ecx,14;количество байт в "GetProcAddress"
        cld     ;Командой cld очищается флаг направления (DF)
                ;Инструкция, выполняющая обратное действие, называется std.
        repe cmpsb
        ;инструкция cmpsb. Она сравнивает байты (%esi) и (edi)
        ;и выставляет флаги в соответствии с результатом сравнения
        ;Префикс rep, repe повторяет инструкцию заданное в регистре ecx количество раз
        .IF ecx==0;нашли имя
                jmp GetAddr
        .ENDIF
        inc edx
        add eax,4
        mov esi,dword ptr [eax]
        jmp NextName
GetAddr:;если нашли "GetProcAddress"
        pop esi
        mov edi,esi
        mov esi,[esi].AddressOfNameOrdinals
        add esi,ebx;в esi - массив слов с индесками
        mov dx,word ptr [esi][edx*2]
        assume edi:ptr IMAGE_EXPORT_DIRECTORY
        sub edx,[edi].nBase;вычитаем начальный ординал
        inc edx;т.к. начальный ординал начинается с 1
        mov esi,[edi].AddressOfFunctions
        add esi,ebx;в esi - массив адресов функций
        mov eax,dword ptr [esi][edx*4]
        add eax,ebx;в eax - адрес функции GetProcAddress
        mov NameFunc,eax
        popad;восстанавливаем регистры
        mov eax,NameFunc
        ret
GetGetProcAddress endp  
;#########################################################################
;Конец процедуры GetGetProcAddress
;#########################################################################