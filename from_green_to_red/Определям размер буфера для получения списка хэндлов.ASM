;NtQuerySystemInformation
;На самом деле, если размер буфера меньше нужного, то параметр ReturnLength не заполняется.
;Так как размер буфера не перманентен, то нам приходиться инкрементно перебирать размеры.
;Если функция возвращает STATUS_INFO_LENGTH_MISMATCH, то размер буфера недостаточен.
;Вот код который находит нужный размер буфера:


;===============================================================================;
;               Определям размер буфера для получения списка хэндлов            
;===============================================================================;
        push offset SizeBuffer
        push 0
        push 0
        push 16;SystemHandleInformation
        call _NtQuerySystemInformation
        .if eax!=STATUS_INFO_LENGTH_MISMATCH
                jmp end_calc_size
        .endif
next_calc_size:
        add SizeBuffer,01000h;Увеличиваем размер буфера на страницу
        .if pSystemHandleInfo!=0
                invoke VirtualFree,pSystemHandleInfo, 0, MEM_RELEASE
        .endif
        invoke VirtualAlloc,NULL, SizeBuffer, MEM_COMMIT, PAGE_READWRITE
        mov pSystemHandleInfo,eax
        push offset uBuff
        push SizeBuffer
        push pSystemHandleInfo
        push 16
        call _NtQuerySystemInformation
        .if eax==STATUS_INFO_LENGTH_MISMATCH
                jmp next_calc_size
        .endif
end_calc_size:
;===============================================================================;