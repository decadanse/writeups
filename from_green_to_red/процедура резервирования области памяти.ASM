proc    Allock_Region pRegion,Size
        pusha
        mov     edi,[pRegion]
        mov     esi,[Size]
        add     esi,edi
        ;esi - ��������� �� ����� ���������� �������
        ;edi - ��������� �� ������
     @@:
        xinvoke UnmapViewOfFile,edi
        xinvoke VirtualFree,edi,0,MEM_RELEASE
        ;���������� ������
        xinvoke VirtualAlloc,edi,10000h,MEM_RESERVE+MEM_COMMIT,PAGE_EXECUTE_READWRITE
        ;���������������
        test    eax,eax
        jz      @f
        ;��� ���� �������� ������� �������� ���� ��������� � "��������" ��������
        add     edi,10000h
        ;������ ������������� �� 10000h �� ���
        cmp     edi,esi
        jl      @b
     @@:
        popa
        ret
endp