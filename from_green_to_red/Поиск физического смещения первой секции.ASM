;########################����� ����������� �������� ������ ������#################
mov edi,pFileHeader
assume edi:ptr IMAGE_FILE_HEADER
xor ecx,ecx
mov cx,[edi].NumberOfSections
dec cx
mov edi,pSectionTable
assume edi:ptr IMAGE_SECTION_HEADER
xor eax,eax
mov eax,[edi].PointerToRawData;� eax - ���������� �������� 1 ������ � ������� ������
add edi,sizeof IMAGE_SECTION_HEADER
NextSection:
.IF eax>[edi].PointerToRawData
        mov eax,[edi].PointerToRawData
.ENDIF
add edi,sizeof IMAGE_SECTION_HEADER
loop NextSection
;#####################END ����� ����������� �������� ������ ������################