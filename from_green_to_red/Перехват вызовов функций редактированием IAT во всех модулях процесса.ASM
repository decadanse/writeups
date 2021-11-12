; процедура EditIATGlobal правит IAT всех модулей процесса, в котором она вызывается.
;Мы вызываем ее в процедуре DllMain DLL, которую мы будет внедрять в адресное пространство
;процесса-жертвы. Она просто перечисляет все модули в адресном пространстве текущего
;процесса с помощью ToolHelp-функций, а потом последовательно вызывает для каждого
;модуля процедуру EditIATLocal

;===============================================================================;
;Процедура EditIATGlobal                                                        
;Описание:
;Перехват вызовов функций редактированием IAT во всех модулях процесса
;Вход: Address адрес внутри файла в памяти
;       ModName - указатель на имя модуля, IAT которого мы будем править. 
;   Регистр не важен.
;       Orig - адрес функции, которую перехватываем
;       New - адрес нашего обработчика
;Выход: нет
;===============================================================================;
EditIATGlobal proc ModName:DWORD, Orig:DWORD, New:DWORD
LOCAL Current:DWORD
LOCAL hSnap:DWORD
        push offset NextMod
        call GetBase
        mov Current,eax;Получили хэндл своего модуля
        mov ecx,eax
        invoke CreateToolhelp32Snapshot,TH32CS_SNAPMODULE,NULL
        mov hSnap,eax
        mov ModEntry.dwSize,sizeof MODULEENTRY32
        invoke Module32First,hSnap,offset ModEntry
NextMod:
        mov eax,Current
        .IF eax!=ModEntry.hModule;В своем модуле не будем перехватывать!
                push ModEntry.hModule
                push New
                push Orig
                push ModName
                call EditIATLocal;Перехватываем в этом модуле
        .ENDIF
        invoke Module32Next,hSnap,offset ModEntry;Следующий модуль
        .IF eax!=0 
                jmp NextMod
        .ENDIF
        invoke CloseHandle,hSnap
        mov eax,1
        ret
EditIATGlobal endp
;===============================================================================;