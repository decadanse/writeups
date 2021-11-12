.data
        AddAtom1 db "AddAtomA",0
start:
        call GetKernelImport
        mov esi,eax
        call GetBase
        mov esi,eax
        push offset NameGetProcAddress
        call GetGetProcAddress
        push offset AddAtom1;указатель на строку
        push esi;передаем базу kernel32.dll
        call eax