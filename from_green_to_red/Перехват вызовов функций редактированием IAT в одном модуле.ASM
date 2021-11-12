;Например, мы перехватываем функцию, адрес которой X.
;Тогда процедура EditIATLocal  анализирует таблицу импорта указанного модуля и если
;она встречает там адрес X, то функция меняет X на адрес нашего обработчика, который
;также передается как параметр функции.

;===============================================================================;
;Процедура EditIATLocal                                                 
;Описание:
;Перехват вызовов функций редактированием IAT в одном модуле
;Вход: Address адрес внутри файла в памяти
;       ModName - указатель на имя модуля, IAT которого мы будем править. Регистр 
;   не важен.
;       Orig - адрес функции, которую перехватываем
;       New - адрес нашего обработчика
;       ModHandle - описатель модуля, где находиться функция для перехвата. 
;   Например, описатель KERNEL32.DLL
;Выход: 1 - перехватили, 0 - не перехватили
;===============================================================================;
EditIATLocal proc ModName:DWORD, Orig:DWORD, New:DWORD, ModHandle:DWORD
LOCAL OldProtect:DWORD
;Получаем адрес таблицы директорий
        mov eax,ModHandle
        assume eax:ptr IMAGE_DOS_HEADER
        add eax,[eax].e_lfanew
        add eax,4
        add eax,sizeof IMAGE_FILE_HEADER        
        mov edi,eax
        assume edi:ptr IMAGE_OPTIONAL_HEADER
        lea edi,[edi].DataDirectory
        mov eax,edi
;Получаем адрес таблицы импорта
        assume eax:ptr IMAGE_DATA_DIRECTORY
        lea eax,[eax+(sizeof IMAGE_DATA_DIRECTORY)*IMAGE_DIRECTORY_ENTRY_IMPORT]
        .IF dword ptr [eax]==0 
                move ax,FALSE
                ret;Нет таблицы импорта
        .ENDIF
        mov esi,ModHandle
        add esi,dword ptr [eax];В esi - адрес таблицы импорта
        assume esi:PTR IMAGE_IMPORT_DESCRIPTOR
NextDLL:;очередная запись в таблице импорта
        .IF [esi].Name1==NULL;Конец таблицы импорта?
                mov eax,FALSE
                ret
        .ENDIF 
        mov ecx,[esi].Name1
        add ecx,ModHandle
        invoke lstrcmpi,ModName,ecx;тот ли это модуль?
        .IF EAX!=0
                add esi,sizeof IMAGE_IMPORT_DESCRIPTOR
                jmp NextDLL
        .ENDIF
;Если дошли до сюда, то нашли имя модуля
        mov edi,ModHandle
        add edi,[esi].FirstThunk;В EDI - IAT
        assume edi:PTR IMAGE_THUNK_DATA
NextFunction:;перебираем все импортируемые функции
        .IF [edi].u1.Function==0;IAT закончилась
                add esi,sizeof IMAGE_IMPORT_DESCRIPTOR
                jmp NextDLL
        .ENDIF
        mov eax,[edi].u1.Function
        .IF Orig==eax;Нашли!!!
        ;Разрешим запись на нужную страницу
                invoke VirtualProtect,edi,4,PAGE_EXECUTE_READWRITE,ADDR OldProtect
                call GetCurrentProcess
                mov ecx,eax
                lea eax,New
                ;Сменим адрес функции на адрес обработчика
                invoke WriteProcessMemory,ecx,edi,eax,4,NULL
                ;Воостановим прежние аттрибуты
                invoke VirtualProtect,edi,4,OldProtect,ADDR OldProtect
                mov eax,TRUE
                ret
        .ENDIF  
        add edi,sizeof IMAGE_THUNK_DATA
        jmp NextFunction
EditIATLocal endp
;===============================================================================;