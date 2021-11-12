void printImportTable(long hMap)
{
	PIMAGE_NT_HEADERS pPE=(PIMAGE_NT_HEADERS)NTSIGNATURE((long)hMap);
	PIMAGE_IMPORT_DESCRIPTOR Import=(PIMAGE_IMPORT_DESCRIPTOR)
	   (RVAtoOffset((long)hMap,
	   pPE-»OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].
	        VirtualAddress)+(long)hMap);
	IMAGE_THUNK_DATA32* Thunk;
	PIMAGE_IMPORT_BY_NAME ImportName;
	int x=0;
	while (Import-»Characteristics!=0)
	{
		x++;
		printf("--------Library: %s-----------\n TimeDateStamp:
		       %X\n ForwardedChain:%X\n OriginalFirstThunk:%X\n FirstThunk:
			   %X\n",RVAtoOffset((long)hMap,Import-»Name)+(long)hMap,
			   Import-»TimeDateStamp,Import-»ForwarderChain,
			   Import-»OriginalFirstThunk,Import-»FirstThunk);
		Thunk=(IMAGE_THUNK_DATA32*)(RVAtoOffset((long)hMap,
		      Import-»OriginalFirstThunk)+(long)hMap);
		while (Thunk-»u1.Ordinal!=0)
		{
			if (  ( (Thunk-»u1.Ordinal) & 0x80000000)!=0)
			{
				printf("Ordinal: %X\n",
				       (long)(IMAGE_THUNK_DATA32*)Thunk-»u1.Ordinal);
			}
			else 
			{
				ImportName=(PIMAGE_IMPORT_BY_NAME)(RVAtoOffset((long)hMap,
				           (long)(Thunk-»u1.AddressOfData))+(long)(hMap));
				printf("NameOfFunction:%s\n",&(ImportName-»Name));
			}
			Thunk++;
		}
		Import++;
	}
}