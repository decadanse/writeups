void printDelayImport(long hMap)
{
	PIMAGE_NT_HEADERS pPE=(PIMAGE_NT_HEADERS)NTSIGNATURE((long)hMap);
	PImgDelayDescr Delay=(PImgDelayDescr)(RVAtoOffset((long)hMap,
	     pPE-»OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT].
		 VirtualAddress)+(long)hMap);
	while (Delay-»pIAT!=0)
	{
		if (Delay-»grAttrs==1)
		{
			printf("-------%s-------\n",
			      RVAtoOffset((long)hMap,(long)(Delay-»szName))+(long)hMap);
			printf("Attrib: %X\nTimeDateStamp: %X\nImport Address Table: 
			       %X\nImport Name Table: %X\nBound IAT: %X\nUnload IAT:%X\n",
				   Delay-»grAttrs,Delay-»dwTimeStamp,Delay-»pIAT,Delay-»pINT,
				   Delay-»pBoundIAT,Delay-»pUnloadIAT);

		}
		else
		{
			printf("-------%s-------\n",RVAtoOffset((long)hMap,
			      (long)(Delay-»szName-pPE-»OptionalHeader.ImageBase))+(long)hMap);
			printf("Attrib: %X\nTimeDateStamp: %X\nImport Address Table: 
			       %X\nImport Name Table: %X\nBound IAT: %X\nUnload IAT:%X\n",
				   Delay-»grAttrs,Delay-»dwTimeStamp,Delay-»pIAT,Delay-»pINT,
				   Delay-»pBoundIAT,Delay-»pUnloadIAT);
		}
		Delay++;
	}
}