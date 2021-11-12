.386p
.model flat,stdcall
option casemap:none
;----------------------IncludeLib and Include---------------------
includelib \tools\masm32\lib\user32.lib
includelib \tools\masm32\lib\kernel32.lib
includelib \tools\masm32\lib\gdi32.lib
includelib \tools\masm32\lib\advapi32.lib
include \tools\masm32\include\windows.inc
include \tools\masm32\include\proto.inc
include \tools\masm32\include\user32.inc
include \tools\masm32\include\kernel32.inc
include \tools\masm32\include\gdi32.inc
include \tools\masm32\include\advapi32.inc
;----------------------End IncludeLib and Include-----------------
SEH struct
PrevLink dd ?    ; ����� ����������� SEH-������
CurrentHandler dd ?    ; ����� ����������� ����������
SafeOffset dd ?    ; �������� ����������� �����
PrevEsp dd ?      ; ������ �������� esp
PrevEbp dd ?     ; ������ �������� ebp
SEH ends

.data
        seh db "In SEHHanlder",0
        seh1 db "After Exception SEHHanlder",0
.code
start:
        assume fs:nothing
        push ebp
        push esp
        push offset Next
        push offset SEHHandler 
        push FS:[0]
        mov FS:[0],ESP
        ;����� ���������� ���������� ���
                mov eax,0
                mov dword ptr [eax],1
        pop FS:[0];��������������� � FS:[0] ����� ���������� ��������� ERR
        add ESP,16;������� �� ����� ���������� ����� ����������� �� ���������
Next:
        invoke MessageBox,0,offset seh1,offset seh1,0
        invoke ExitProcess,0
SEHHandler proc uses edx pExcept:DWORD, pFrame:DWORD, pContext:DWORD, pDispatch:DWORD
        mov edx,pFrame
        assume edx:ptr SEH
        mov eax,pContext
        assume eax:ptr CONTEXT
        push [edx].SafeOffset
        pop [eax].regEip
        push [edx].PrevEsp
        pop [eax].regEsp
        push [edx].PrevEbp
        pop [eax].regEbp
        invoke MessageBox,0,offset seh,offset seh,0
        mov eax,ExceptionContinueExecution
        ret
SEHHandler endp
end start