                ;=======================================================
                ;               П Р О Г Р А М М А                            
                ; Внедрение DLL в адресное пространство чужого процесса              
                ; Дата: 01.07.2005                                                   
                ; Автор: Bill Prisoner / TPOC                                        
                ;=======================================================

;===============================================================================
;                       Options and Includes                                           
;===============================================================================
.386
option casemap:none
.model flat,stdcall
include \tools\masm32\include\windows.inc
includelib \tools\masm32\lib\kernel32.lib
include \tools\masm32\include\kernel32.inc
include \tools\masm32\include\user32.inc
includelib \tools\masm32\lib\user32.lib
include \tools\masm32\include\advapi32.inc
includelib \tools\masm32\lib\advapi32.lib
;===============================================================================

;===============================================================================
;                       Initialized Data Section
;===============================================================================
.data                                                                                           
        lib db "c:\\dll.dll",0;имя DLL, которую внедряем в чужой процесс                                
        dwSize equ $-lib;Размер строки с именем DLL 
        kernelName db "kernel32.dll",0;Имя Kernel32.dll
        loadlibraryName db "LoadLibraryA",0;Имя функции LoadLibraryA
        _LoadLibrary dd 0;Адрес функции LoadLibrary                             
        ParameterForLoadLibrary dd 0;Адрес строки с именем DLL в чужом процессе 
        ThreadId dd 0;Идентификатор треда                                       
        PID dd 1700;Идентификатор целевого процесса                             
;===============================================================================

;===============================================================================
;                       Uninitialized Data Section                                             
;===============================================================================
.data?                                                                          
        hProcess dd ?                                                           
;===============================================================================

;===============================================================================
;                               Code Section                                    
;===============================================================================
.code
start:
    ;Открываем процесс куда будем внедрять DLL
        invoke OpenProcess,PROCESS_CREATE_THREAD or PROCESS_VM_WRITE or \
        PROCESS_VM_OPERATION,0,PID 
        mov hProcess,eax
        ;Получаем описатель модуля Kernel32.dll
        invoke GetModuleHandle,offset kernelName
        ;Получаем адрес функции LoadLibrary
        invoke GetProcAddress,eax,offset loadlibraryName
        mov _LoadLibrary,eax
        ;Выделяем память в удаленном процессе
        invoke VirtualAllocEx,hProcess,NULL,dwSize,MEM_RESERVE or MEM_COMMIT, \
               PAGE_READWRITE
        mov ParameterForLoadLibrary,eax
        ;Запись строки с именем DLL в АП чужого процесса
        invoke WriteProcessMemory,hProcess,eax,offset lib,dwSize,NULL
    ;Создаем удаленный поток, который вызывает LoadLibrary, 
        ;тем самым внедряем DLL в адресное пространство чужого процесса.  
        invoke CreateRemoteThread,hProcess,NULL,NULL,_LoadLibrary, \
               ParameterForLoadLibrary,NULL,offset ThreadId
        invoke ExitProcess,0
end start
;===============================================================================
;                               End Program
;===============================================================================


;После внедрения DLL вызывается DllMain с параметром DLL_PROCESS_ATTACH.
;Именно при обработке этого параметра мы устанавливаем перехватчик.