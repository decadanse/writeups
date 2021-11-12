.data?
        pPE dd ?
        pSectionTable dd ?
        pDataDirectory dd ?
        pFileHeader dd ?
        pOptionalHeader dd ?
………
;#####################Получение адреса PE-заголовка###############################
assume edi:ptr IMAGE_DOS_HEADER
mov edi,hMap
add edi,[edi].e_lfanew
mov pPE,edi
;#####################END Получение адреса PE-заголовка###########################
;#####################Получение адреса файлового заголовка########################
add edi,4
mov pFileHeader,edi
;#####################END Получение адреса файлового заголовка####################
;#####################Получение адреса опционального заголовка####################
add edi,sizeof IMAGE_FILE_HEADER
mov pOptionalHeader,edi
;#####################END Получение адреса опционального заголовка################
;#######################Получение адреса таблицы директорий#######################
assume edi:ptr IMAGE_OPTIONAL_HEADER
lea edi,[edi].DataDirectory
mov pDataDirectory,edi
;#######################END Получение адреса таблицы директорий###################
;############################Получение адреса талицы секций#######################
mov edi,pOptionalHeader
mov eax,[edi].NumberOfRvaAndSizes
mov edi,pDataDirectory
mov edx,sizeof IMAGE_DATA_DIRECTORY
mul edx
add edi,eax
mov pSectionTable,edi
;########################END Получение адреса таблицы секций######################