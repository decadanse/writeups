;����� ������� ��������� ������� � ������ ������������, ���������� �������
;KERNEL32.DLL!OpenProcess ������ ����� ���������� SeDebugPrivilegies.
;���� ������������ ��������� �� ���������� ��������� ������ ����������:

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


;����� Priv � ��� ������ ������������ ���:
;Priv db "SeDebugPrivilege",0

;����� ������ ������ ������� ���������� �� ������� ����� ��������� ��������� ��������.


        ;call EnableDebugPrivilege
        ;push ProcID;ID ���������� ��������
        ;push 0
        ;push PROCESS_CREATE_THREAD or PROCESS_VM_WRITE or PROCESS_VM_OPERATION
        ;call OpenProcess

;GetLastError ������ ERROR_SUCCESS. ���� ������� ��������� ������� ��� ������
;������� EnableDebugPrivilege, �� OpenProcess ������ ����, � GetLastError
;������ ERROR_ACCESSDENIED.