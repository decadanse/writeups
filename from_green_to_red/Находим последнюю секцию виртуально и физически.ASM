;###################������� ��������� ������ ���������� � ���������###############
mov edi,pFileHeader
assume edi:ptr IMAGE_FILE_HEADER
xor ecx,ecx
mov cx,word ptr [edi].NumberOfSections
mov edi,pSectionTable
assume edi:ptr IMAGE_SECTION_HEADER
mov eax,[edi].PointerToRawData
mov ebx,[edi].VirtualAddress
add edi,sizeof IMAGE_SECTION_HEADER
dec ecx
NextSection:
.IF (eax<[edi].PointerToRawData)&&(ebx<[edi].VirtualAddress)
        mov eax,[edi].PointerToRawData
        mov ebx,[edi].VirtualAddress
        mov pLastSection,edi;��������� �� ������ � ��������� ������
.ENDIF
add edi,sizeof IMAGE_SECTION_HEADER
loop NextSection
;###############END ������� ��������� ������ ���������� � ���������###############