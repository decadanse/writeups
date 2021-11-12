;А вот функция, которая как раз делает то, к чему мы стремились – осуществляет перехват:


SetHook proc NameFunc:dword,NameModul:dword 
        invoke GetModuleHandle,NameModul
        invoke GetProcAddress,eax,NameFunc
        mov RealAddr1,eax;сохраняем адрес перехватываемой функции
        invoke ReadProcessMemory,-1,RealAddr1,offset Old_Code1,size_code1,0
        mov Hooker1,offset Hooker
        invoke WriteProcessMemory,-1,RealAddr1,offset code1,size_code1,0
        ret
SetHook endp