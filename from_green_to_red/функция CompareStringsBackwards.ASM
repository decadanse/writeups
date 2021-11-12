;Сравниваем мы с конца, идя в начало.

;===============================================================================;
;                       Сравнить строки назад
;===============================================================================;
CompareStringBackwards proc pStr1:dword,pStr2:dword
LOCAL Len1:DWORD
LOCAL Len2:DWORD
        push esi
        push edi
        invoke lstrlenW,pStr1
        mov Len1,eax
        invoke lstrlenW,pStr2
        mov Len2,eax
        mov eax,Len1
        .if eax>Len2
                mov eax,0
                ret
        .endif
        mov edx,Len1
        add edx,Len1
        mov edi,pStr1
        add edi,edx

        mov edx,Len2
        add edx,Len2
        mov esi,pStr2
        add esi,edx

        mov ecx,Len1
        inc ecx
        std
        repe cmpsw
        add esi,2
        add edi,2
        xor eax,eax
        xor edx,edx
        mov ax,word ptr [esi]
        mov dx,word ptr [edi]
        .if (ecx==0)&&(eax==edx)
                mov eax,1
                pop edi
                pop esi
                ret
        .else
                mov eax,0
                pop edi
                pop esi
                ret
        .endif
CompareStringBackwards endp
;===============================================================================;