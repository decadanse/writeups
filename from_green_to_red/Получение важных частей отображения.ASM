.data?
        pPE dd ?
        pSectionTable dd ?
        pDataDirectory dd ?
        pFileHeader dd ?
        pOptionalHeader dd ?
���
;#####################��������� ������ PE-���������###############################
assume edi:ptr IMAGE_DOS_HEADER
mov edi,hMap
add edi,[edi].e_lfanew
mov pPE,edi
;#####################END ��������� ������ PE-���������###########################
;#####################��������� ������ ��������� ���������########################
add edi,4
mov pFileHeader,edi
;#####################END ��������� ������ ��������� ���������####################
;#####################��������� ������ ������������� ���������####################
add edi,sizeof IMAGE_FILE_HEADER
mov pOptionalHeader,edi
;#####################END ��������� ������ ������������� ���������################
;#######################��������� ������ ������� ����������#######################
assume edi:ptr IMAGE_OPTIONAL_HEADER
lea edi,[edi].DataDirectory
mov pDataDirectory,edi
;#######################END ��������� ������ ������� ����������###################
;############################��������� ������ ������ ������#######################
mov edi,pOptionalHeader
mov eax,[edi].NumberOfRvaAndSizes
mov edi,pDataDirectory
mov edx,sizeof IMAGE_DATA_DIRECTORY
mul edx
add edi,eax
mov pSectionTable,edi
;########################END ��������� ������ ������� ������######################