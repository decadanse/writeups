;########################Поиск физического смещения первой секции#################
mov edi,pFileHeader
assume edi:ptr IMAGE_FILE_HEADER
xor ecx,ecx
mov cx,[edi].NumberOfSections
dec cx
mov edi,pSectionTable
assume edi:ptr IMAGE_SECTION_HEADER
xor eax,eax
mov eax,[edi].PointerToRawData;в eax - физическое смещение 1 секции в таблице секций
add edi,sizeof IMAGE_SECTION_HEADER
NextSection:
.IF eax>[edi].PointerToRawData
        mov eax,[edi].PointerToRawData
.ENDIF
add edi,sizeof IMAGE_SECTION_HEADER
loop NextSection
;#####################END Поиск физического смещения первой секции################