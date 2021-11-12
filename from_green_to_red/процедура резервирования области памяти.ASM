proc    Allock_Region pRegion,Size
        pusha
        mov     edi,[pRegion]
        mov     esi,[Size]
        add     esi,edi
        ;esi - указатель на конец выделяемой области
        ;edi - указатель на начало
     @@:
        xinvoke UnmapViewOfFile,edi
        xinvoke VirtualFree,edi,0,MEM_RELEASE
        ;освободить память
        xinvoke VirtualAlloc,edi,10000h,MEM_RESERVE+MEM_COMMIT,PAGE_EXECUTE_READWRITE
        ;зарезервировать
        test    eax,eax
        jz      @f
        ;без этой проверки функция работает если параметры в "разумных" пределах
        add     edi,10000h
        ;память резервируется по 10000h за шаг
        cmp     edi,esi
        jl      @b
     @@:
        popa
        ret
endp