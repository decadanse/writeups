;#########################################################################
;Процедура GetAPIs
;Получение адресов всех требуемых API-функций
;Вход: В edi указатель на массив ASCIIZ строк имен функций
;       В ebx - смещение массива двойных слов которые заполняет функция
;       В esi - база kernel32.dll
;       В ecx - адрес функции GetProcAddress
;       В стек кладется количество функций
;Выход:заполняются соответствующие поля
;#########################################################################
GetAPIs proc Number:DWORD
        Pushad
        mov eax,ecx
        mov ecx,Number
NextFunc:
        push eax
        push esi
        push edi
        push ebx
        push ecx

        push edi;имя функции
        push esi;база kernel32
        call eax;вызов GetProcAddress
        
        pop ecx
        pop ebx
        pop edi
        pop esi

        mov dword ptr [ebx],eax;помещаем адрес функции в переменную
        pop eax
        add ebx,4;следующая переменная
        push ecx;сохраняем счетчик
        mov ecx,30;для цепочечной команды
        push eax
        mov al,0;ищем 0
        repne scasb  ;Найти байт равный AL в блоке из (E)CX байт по адресу ES:(E)DI
        pop eax
        pop ecx
        loop NextFunc
        popad
        ret
GetAPIs endp
;#########################################################################
;Конец процедуры GetAPIs
;#########################################################################