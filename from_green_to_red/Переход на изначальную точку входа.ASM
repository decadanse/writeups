;#############################Переход на старую точку входа#######################
        mov esi,pOptionalHeader
        assume esi:ptr IMAGE_OPTIONAL_HEADER
        mov eax,[esi].AddressOfEntryPoint;В EAX - старая точка входа
        add eax,[esi].ImageBase
        mov byte ptr [edi],0BFh;BF - опкод команды mov edi,XXXXXXX
        inc edi
        push eax
        pop dword ptr [edi];Джампим к старой точке входа
        add edi,4
        mov word ptr [edi],0E7FFh;FFE7 - опкод команды jmp edi
;#########################END Переход на старую точку входа#######################