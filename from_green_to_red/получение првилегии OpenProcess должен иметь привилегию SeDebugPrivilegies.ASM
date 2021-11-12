;Чтобы открыть системный процесс с такими привилегиями, вызывающий функцию
;KERNEL32.DLL!OpenProcess должен иметь привилегию SeDebugPrivilegies.
;Ниже представлена процедура на ассемблере получения данной привилегии:

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
        mov eax,1
        ret
EnableDebugPrivilege endp


;Здесь Priv — это строка определенная так:
;Priv db "SeDebugPrivilege",0

;После вызова данной функции вызывающий ее процесс может открывать системные процессы.


        ;call EnableDebugPrivilege
        ;push ProcID;ID системного процесса
        ;push 0
        ;push PROCESS_CREATE_THREAD or PROCESS_VM_WRITE or PROCESS_VM_OPERATION
        ;call OpenProcess

;GetLastError вернет ERROR_SUCCESS. Если открыть системный процесс без вызова
;функции EnableDebugPrivilege, то OpenProcess вернет ноль, а GetLastError
;вернет ERROR_ACCESSDENIED.