;#############################������� �� ������ ����� �����#######################
        mov esi,pOptionalHeader
        assume esi:ptr IMAGE_OPTIONAL_HEADER
        mov eax,[esi].AddressOfEntryPoint;� EAX - ������ ����� �����
        add eax,[esi].ImageBase
        mov byte ptr [edi],0BFh;BF - ����� ������� mov edi,XXXXXXX
        inc edi
        push eax
        pop dword ptr [edi];������� � ������ ����� �����
        add edi,4
        mov word ptr [edi],0E7FFh;FFE7 - ����� ������� jmp edi
;#########################END ������� �� ������ ����� �����#######################