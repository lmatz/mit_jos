
obj/user/faultnostack:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 6c 04 80 	movl   $0x80046c,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 a5 00 00 00       	call   8000f3 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  80006e:	e8 32 03 00 00       	call   8003a5 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 f6                	test   %esi,%esi
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 03                	mov    (%ebx),%eax
  80008b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800094:	89 34 24             	mov    %esi,(%esp)
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a7:	89 ec                	mov    %ebp,%esp
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b9:	e8 1b 03 00 00       	call   8003d9 <sys_env_destroy>
}
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 0c             	sub    $0xc,%esp
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000cd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dc:	89 c3                	mov    %eax,%ebx
  8000de:	89 c7                	mov    %eax,%edi
  8000e0:	89 c6                	mov    %eax,%esi
  8000e2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e4:	8b 1c 24             	mov    (%esp),%ebx
  8000e7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000eb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000ef:	89 ec                	mov    %ebp,%esp
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 38             	sub    $0x38,%esp
  8000f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800102:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800106:	75 0c                	jne    800114 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800108:	c7 04 24 4c 12 80 00 	movl   $0x80124c,(%esp)
  80010f:	e8 39 04 00 00       	call   80054d <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800114:	bb 00 00 00 00       	mov    $0x0,%ebx
  800119:	b8 09 00 00 00       	mov    $0x9,%eax
  80011e:	8b 55 08             	mov    0x8(%ebp),%edx
  800121:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800124:	89 df                	mov    %ebx,%edi
  800126:	89 de                	mov    %ebx,%esi
  800128:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7e 28                	jle    800156 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800132:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800139:	00 
  80013a:	c7 44 24 08 78 12 80 	movl   $0x801278,0x8(%esp)
  800141:	00 
  800142:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800149:	00 
  80014a:	c7 04 24 95 12 80 00 	movl   $0x801295,(%esp)
  800151:	e8 3e 03 00 00       	call   800494 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800156:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800159:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80015c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80015f:	89 ec                	mov    %ebp,%esp
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	83 ec 38             	sub    $0x38,%esp
  800169:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80016c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80016f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800172:	b9 00 00 00 00       	mov    $0x0,%ecx
  800177:	b8 0c 00 00 00       	mov    $0xc,%eax
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	89 cb                	mov    %ecx,%ebx
  800181:	89 cf                	mov    %ecx,%edi
  800183:	89 ce                	mov    %ecx,%esi
  800185:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800187:	85 c0                	test   %eax,%eax
  800189:	7e 28                	jle    8001b3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80018f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800196:	00 
  800197:	c7 44 24 08 78 12 80 	movl   $0x801278,0x8(%esp)
  80019e:	00 
  80019f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 95 12 80 00 	movl   $0x801295,(%esp)
  8001ae:	e8 e1 02 00 00       	call   800494 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8001b3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001b6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001bc:	89 ec                	mov    %ebp,%esp
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    

008001c0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	83 ec 0c             	sub    $0xc,%esp
  8001c6:	89 1c 24             	mov    %ebx,(%esp)
  8001c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001cd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d1:	be 00 00 00 00       	mov    $0x0,%esi
  8001d6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8001e9:	8b 1c 24             	mov    (%esp),%ebx
  8001ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001f0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001f4:	89 ec                	mov    %ebp,%esp
  8001f6:	5d                   	pop    %ebp
  8001f7:	c3                   	ret    

008001f8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 38             	sub    $0x38,%esp
  8001fe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800201:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800204:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	b8 08 00 00 00       	mov    $0x8,%eax
  800211:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7e 28                	jle    800249 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800221:	89 44 24 10          	mov    %eax,0x10(%esp)
  800225:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80022c:	00 
  80022d:	c7 44 24 08 78 12 80 	movl   $0x801278,0x8(%esp)
  800234:	00 
  800235:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80023c:	00 
  80023d:	c7 04 24 95 12 80 00 	movl   $0x801295,(%esp)
  800244:	e8 4b 02 00 00       	call   800494 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800249:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80024c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80024f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800252:	89 ec                	mov    %ebp,%esp
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	83 ec 38             	sub    $0x38,%esp
  80025c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80025f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800262:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026a:	b8 06 00 00 00       	mov    $0x6,%eax
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	8b 55 08             	mov    0x8(%ebp),%edx
  800275:	89 df                	mov    %ebx,%edi
  800277:	89 de                	mov    %ebx,%esi
  800279:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027b:	85 c0                	test   %eax,%eax
  80027d:	7e 28                	jle    8002a7 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800283:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80028a:	00 
  80028b:	c7 44 24 08 78 12 80 	movl   $0x801278,0x8(%esp)
  800292:	00 
  800293:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029a:	00 
  80029b:	c7 04 24 95 12 80 00 	movl   $0x801295,(%esp)
  8002a2:	e8 ed 01 00 00       	call   800494 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002a7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002aa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002ad:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002b0:	89 ec                	mov    %ebp,%esp
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 38             	sub    $0x38,%esp
  8002ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c3:	b8 05 00 00 00       	mov    $0x5,%eax
  8002c8:	8b 75 18             	mov    0x18(%ebp),%esi
  8002cb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7e 28                	jle    800305 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002e1:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8002e8:	00 
  8002e9:	c7 44 24 08 78 12 80 	movl   $0x801278,0x8(%esp)
  8002f0:	00 
  8002f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f8:	00 
  8002f9:	c7 04 24 95 12 80 00 	movl   $0x801295,(%esp)
  800300:	e8 8f 01 00 00       	call   800494 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800305:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800308:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80030b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80030e:	89 ec                	mov    %ebp,%esp
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	83 ec 38             	sub    $0x38,%esp
  800318:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80031b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80031e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800321:	be 00 00 00 00       	mov    $0x0,%esi
  800326:	b8 04 00 00 00       	mov    $0x4,%eax
  80032b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800331:	8b 55 08             	mov    0x8(%ebp),%edx
  800334:	89 f7                	mov    %esi,%edi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 28                	jle    800364 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800340:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800347:	00 
  800348:	c7 44 24 08 78 12 80 	movl   $0x801278,0x8(%esp)
  80034f:	00 
  800350:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800357:	00 
  800358:	c7 04 24 95 12 80 00 	movl   $0x801295,(%esp)
  80035f:	e8 30 01 00 00       	call   800494 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800364:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800367:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80036a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80036d:	89 ec                	mov    %ebp,%esp
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 0c             	sub    $0xc,%esp
  800377:	89 1c 24             	mov    %ebx,(%esp)
  80037a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80037e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800382:	ba 00 00 00 00       	mov    $0x0,%edx
  800387:	b8 0a 00 00 00       	mov    $0xa,%eax
  80038c:	89 d1                	mov    %edx,%ecx
  80038e:	89 d3                	mov    %edx,%ebx
  800390:	89 d7                	mov    %edx,%edi
  800392:	89 d6                	mov    %edx,%esi
  800394:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800396:	8b 1c 24             	mov    (%esp),%ebx
  800399:	8b 74 24 04          	mov    0x4(%esp),%esi
  80039d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003a1:	89 ec                	mov    %ebp,%esp
  8003a3:	5d                   	pop    %ebp
  8003a4:	c3                   	ret    

008003a5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003a5:	55                   	push   %ebp
  8003a6:	89 e5                	mov    %esp,%ebp
  8003a8:	83 ec 0c             	sub    $0xc,%esp
  8003ab:	89 1c 24             	mov    %ebx,(%esp)
  8003ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8003c0:	89 d1                	mov    %edx,%ecx
  8003c2:	89 d3                	mov    %edx,%ebx
  8003c4:	89 d7                	mov    %edx,%edi
  8003c6:	89 d6                	mov    %edx,%esi
  8003c8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8003ca:	8b 1c 24             	mov    (%esp),%ebx
  8003cd:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003d1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003d5:	89 ec                	mov    %ebp,%esp
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    

008003d9 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
  8003dc:	83 ec 38             	sub    $0x38,%esp
  8003df:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003e2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003e5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8003f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f5:	89 cb                	mov    %ecx,%ebx
  8003f7:	89 cf                	mov    %ecx,%edi
  8003f9:	89 ce                	mov    %ecx,%esi
  8003fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003fd:	85 c0                	test   %eax,%eax
  8003ff:	7e 28                	jle    800429 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800401:	89 44 24 10          	mov    %eax,0x10(%esp)
  800405:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80040c:	00 
  80040d:	c7 44 24 08 78 12 80 	movl   $0x801278,0x8(%esp)
  800414:	00 
  800415:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80041c:	00 
  80041d:	c7 04 24 95 12 80 00 	movl   $0x801295,(%esp)
  800424:	e8 6b 00 00 00       	call   800494 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800429:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80042c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80042f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800432:	89 ec                	mov    %ebp,%esp
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	83 ec 0c             	sub    $0xc,%esp
  80043c:	89 1c 24             	mov    %ebx,(%esp)
  80043f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800443:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800447:	ba 00 00 00 00       	mov    $0x0,%edx
  80044c:	b8 01 00 00 00       	mov    $0x1,%eax
  800451:	89 d1                	mov    %edx,%ecx
  800453:	89 d3                	mov    %edx,%ebx
  800455:	89 d7                	mov    %edx,%edi
  800457:	89 d6                	mov    %edx,%esi
  800459:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80045b:	8b 1c 24             	mov    (%esp),%ebx
  80045e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800462:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800466:	89 ec                	mov    %ebp,%esp
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    
	...

0080046c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80046c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80046d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800472:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800474:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl  %esp , %ebx
  800477:	89 e3                	mov    %esp,%ebx
	movl  40(%esp) , %eax
  800479:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl  48(%esp) , %esp
  80047d:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl  %eax 
  800481:	50                   	push   %eax


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl  %ebx , %esp
  800482:	89 dc                	mov    %ebx,%esp
	subl  $4 , 48(%esp)
  800484:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl  %eax
  800489:	58                   	pop    %eax
	popl  %eax
  80048a:	58                   	pop    %eax
	popal
  80048b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4 , %esp
  80048c:	83 c4 04             	add    $0x4,%esp
	popfl
  80048f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800490:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800491:	c3                   	ret    
	...

00800494 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800494:	55                   	push   %ebp
  800495:	89 e5                	mov    %esp,%ebp
  800497:	56                   	push   %esi
  800498:	53                   	push   %ebx
  800499:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80049c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80049f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8004a5:	e8 fb fe ff ff       	call   8003a5 <sys_getenvid>
  8004aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c0:	c7 04 24 a4 12 80 00 	movl   $0x8012a4,(%esp)
  8004c7:	e8 81 00 00 00       	call   80054d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d3:	89 04 24             	mov    %eax,(%esp)
  8004d6:	e8 11 00 00 00       	call   8004ec <vcprintf>
	cprintf("\n");
  8004db:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  8004e2:	e8 66 00 00 00       	call   80054d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004e7:	cc                   	int3   
  8004e8:	eb fd                	jmp    8004e7 <_panic+0x53>
	...

008004ec <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fc:	00 00 00 
	b.cnt = 0;
  8004ff:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800506:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800509:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800510:	8b 45 08             	mov    0x8(%ebp),%eax
  800513:	89 44 24 08          	mov    %eax,0x8(%esp)
  800517:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800521:	c7 04 24 67 05 80 00 	movl   $0x800567,(%esp)
  800528:	e8 c2 01 00 00       	call   8006ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800533:	89 44 24 04          	mov    %eax,0x4(%esp)
  800537:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80053d:	89 04 24             	mov    %eax,(%esp)
  800540:	e8 7b fb ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800545:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80054b:	c9                   	leave  
  80054c:	c3                   	ret    

0080054d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
  800550:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800553:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800556:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055a:	8b 45 08             	mov    0x8(%ebp),%eax
  80055d:	89 04 24             	mov    %eax,(%esp)
  800560:	e8 87 ff ff ff       	call   8004ec <vcprintf>
	va_end(ap);

	return cnt;
}
  800565:	c9                   	leave  
  800566:	c3                   	ret    

00800567 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800567:	55                   	push   %ebp
  800568:	89 e5                	mov    %esp,%ebp
  80056a:	53                   	push   %ebx
  80056b:	83 ec 14             	sub    $0x14,%esp
  80056e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800571:	8b 03                	mov    (%ebx),%eax
  800573:	8b 55 08             	mov    0x8(%ebp),%edx
  800576:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80057a:	83 c0 01             	add    $0x1,%eax
  80057d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80057f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800584:	75 19                	jne    80059f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800586:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80058d:	00 
  80058e:	8d 43 08             	lea    0x8(%ebx),%eax
  800591:	89 04 24             	mov    %eax,(%esp)
  800594:	e8 27 fb ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  800599:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80059f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8005a3:	83 c4 14             	add    $0x14,%esp
  8005a6:	5b                   	pop    %ebx
  8005a7:	5d                   	pop    %ebp
  8005a8:	c3                   	ret    
  8005a9:	00 00                	add    %al,(%eax)
  8005ab:	00 00                	add    %al,(%eax)
  8005ad:	00 00                	add    %al,(%eax)
	...

008005b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	57                   	push   %edi
  8005b4:	56                   	push   %esi
  8005b5:	53                   	push   %ebx
  8005b6:	83 ec 4c             	sub    $0x4c,%esp
  8005b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005bc:	89 d6                	mov    %edx,%esi
  8005be:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8005cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005db:	39 d1                	cmp    %edx,%ecx
  8005dd:	72 07                	jb     8005e6 <printnum+0x36>
  8005df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e2:	39 d0                	cmp    %edx,%eax
  8005e4:	77 69                	ja     80064f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005e6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005ea:	83 eb 01             	sub    $0x1,%ebx
  8005ed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8005f9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8005fd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800600:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800603:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800606:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80060a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800611:	00 
  800612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800615:	89 04 24             	mov    %eax,(%esp)
  800618:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80061b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80061f:	e8 9c 09 00 00       	call   800fc0 <__udivdi3>
  800624:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800627:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80062a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80062e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800632:	89 04 24             	mov    %eax,(%esp)
  800635:	89 54 24 04          	mov    %edx,0x4(%esp)
  800639:	89 f2                	mov    %esi,%edx
  80063b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80063e:	e8 6d ff ff ff       	call   8005b0 <printnum>
  800643:	eb 11                	jmp    800656 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800645:	89 74 24 04          	mov    %esi,0x4(%esp)
  800649:	89 3c 24             	mov    %edi,(%esp)
  80064c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80064f:	83 eb 01             	sub    $0x1,%ebx
  800652:	85 db                	test   %ebx,%ebx
  800654:	7f ef                	jg     800645 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80065e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800661:	89 44 24 08          	mov    %eax,0x8(%esp)
  800665:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80066c:	00 
  80066d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800670:	89 14 24             	mov    %edx,(%esp)
  800673:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800676:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80067a:	e8 71 0a 00 00       	call   8010f0 <__umoddi3>
  80067f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800683:	0f be 80 c9 12 80 00 	movsbl 0x8012c9(%eax),%eax
  80068a:	89 04 24             	mov    %eax,(%esp)
  80068d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800690:	83 c4 4c             	add    $0x4c,%esp
  800693:	5b                   	pop    %ebx
  800694:	5e                   	pop    %esi
  800695:	5f                   	pop    %edi
  800696:	5d                   	pop    %ebp
  800697:	c3                   	ret    

00800698 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80069b:	83 fa 01             	cmp    $0x1,%edx
  80069e:	7e 0e                	jle    8006ae <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006a5:	89 08                	mov    %ecx,(%eax)
  8006a7:	8b 02                	mov    (%edx),%eax
  8006a9:	8b 52 04             	mov    0x4(%edx),%edx
  8006ac:	eb 22                	jmp    8006d0 <getuint+0x38>
	else if (lflag)
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	74 10                	je     8006c2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b7:	89 08                	mov    %ecx,(%eax)
  8006b9:	8b 02                	mov    (%edx),%eax
  8006bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c0:	eb 0e                	jmp    8006d0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006c2:	8b 10                	mov    (%eax),%edx
  8006c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006c7:	89 08                	mov    %ecx,(%eax)
  8006c9:	8b 02                	mov    (%edx),%eax
  8006cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	3b 50 04             	cmp    0x4(%eax),%edx
  8006e1:	73 0a                	jae    8006ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8006e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e6:	88 0a                	mov    %cl,(%edx)
  8006e8:	83 c2 01             	add    $0x1,%edx
  8006eb:	89 10                	mov    %edx,(%eax)
}
  8006ed:	5d                   	pop    %ebp
  8006ee:	c3                   	ret    

008006ef <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ef:	55                   	push   %ebp
  8006f0:	89 e5                	mov    %esp,%ebp
  8006f2:	57                   	push   %edi
  8006f3:	56                   	push   %esi
  8006f4:	53                   	push   %ebx
  8006f5:	83 ec 4c             	sub    $0x4c,%esp
  8006f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006fe:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800701:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800708:	eb 11                	jmp    80071b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80070a:	85 c0                	test   %eax,%eax
  80070c:	0f 84 b0 03 00 00    	je     800ac2 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800712:	89 74 24 04          	mov    %esi,0x4(%esp)
  800716:	89 04 24             	mov    %eax,(%esp)
  800719:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80071b:	0f b6 03             	movzbl (%ebx),%eax
  80071e:	83 c3 01             	add    $0x1,%ebx
  800721:	83 f8 25             	cmp    $0x25,%eax
  800724:	75 e4                	jne    80070a <vprintfmt+0x1b>
  800726:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800736:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80073d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800744:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800747:	eb 06                	jmp    80074f <vprintfmt+0x60>
  800749:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80074d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074f:	0f b6 0b             	movzbl (%ebx),%ecx
  800752:	0f b6 c1             	movzbl %cl,%eax
  800755:	8d 53 01             	lea    0x1(%ebx),%edx
  800758:	83 e9 23             	sub    $0x23,%ecx
  80075b:	80 f9 55             	cmp    $0x55,%cl
  80075e:	0f 87 41 03 00 00    	ja     800aa5 <vprintfmt+0x3b6>
  800764:	0f b6 c9             	movzbl %cl,%ecx
  800767:	ff 24 8d 80 13 80 00 	jmp    *0x801380(,%ecx,4)
  80076e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800772:	eb d9                	jmp    80074d <vprintfmt+0x5e>
  800774:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80077b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800780:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800783:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800787:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80078a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80078d:	83 fb 09             	cmp    $0x9,%ebx
  800790:	77 2b                	ja     8007bd <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800792:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800795:	eb e9                	jmp    800780 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 48 04             	lea    0x4(%eax),%ecx
  80079d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  8007a5:	eb 19                	jmp    8007c0 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  8007a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007aa:	c1 f8 1f             	sar    $0x1f,%eax
  8007ad:	f7 d0                	not    %eax
  8007af:	21 45 e4             	and    %eax,-0x1c(%ebp)
  8007b2:	eb 99                	jmp    80074d <vprintfmt+0x5e>
  8007b4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8007bb:	eb 90                	jmp    80074d <vprintfmt+0x5e>
  8007bd:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  8007c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c4:	79 87                	jns    80074d <vprintfmt+0x5e>
  8007c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007cc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8007cf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007d2:	e9 76 ff ff ff       	jmp    80074d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007d7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007db:	e9 6d ff ff ff       	jmp    80074d <vprintfmt+0x5e>
  8007e0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 50 04             	lea    0x4(%eax),%edx
  8007e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f0:	8b 00                	mov    (%eax),%eax
  8007f2:	89 04 24             	mov    %eax,(%esp)
  8007f5:	ff d7                	call   *%edi
  8007f7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007fa:	e9 1c ff ff ff       	jmp    80071b <vprintfmt+0x2c>
  8007ff:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	8d 50 04             	lea    0x4(%eax),%edx
  800808:	89 55 14             	mov    %edx,0x14(%ebp)
  80080b:	8b 00                	mov    (%eax),%eax
  80080d:	89 c2                	mov    %eax,%edx
  80080f:	c1 fa 1f             	sar    $0x1f,%edx
  800812:	31 d0                	xor    %edx,%eax
  800814:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800816:	83 f8 09             	cmp    $0x9,%eax
  800819:	7f 0b                	jg     800826 <vprintfmt+0x137>
  80081b:	8b 14 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%edx
  800822:	85 d2                	test   %edx,%edx
  800824:	75 20                	jne    800846 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800826:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082a:	c7 44 24 08 da 12 80 	movl   $0x8012da,0x8(%esp)
  800831:	00 
  800832:	89 74 24 04          	mov    %esi,0x4(%esp)
  800836:	89 3c 24             	mov    %edi,(%esp)
  800839:	e8 0c 03 00 00       	call   800b4a <printfmt>
  80083e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800841:	e9 d5 fe ff ff       	jmp    80071b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800846:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80084a:	c7 44 24 08 e3 12 80 	movl   $0x8012e3,0x8(%esp)
  800851:	00 
  800852:	89 74 24 04          	mov    %esi,0x4(%esp)
  800856:	89 3c 24             	mov    %edi,(%esp)
  800859:	e8 ec 02 00 00       	call   800b4a <printfmt>
  80085e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800861:	e9 b5 fe ff ff       	jmp    80071b <vprintfmt+0x2c>
  800866:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800869:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80086c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80086f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8d 50 04             	lea    0x4(%eax),%edx
  800878:	89 55 14             	mov    %edx,0x14(%ebp)
  80087b:	8b 18                	mov    (%eax),%ebx
  80087d:	85 db                	test   %ebx,%ebx
  80087f:	75 05                	jne    800886 <vprintfmt+0x197>
  800881:	bb e6 12 80 00       	mov    $0x8012e6,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800886:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80088a:	7e 76                	jle    800902 <vprintfmt+0x213>
  80088c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800890:	74 7a                	je     80090c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800892:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800896:	89 1c 24             	mov    %ebx,(%esp)
  800899:	e8 fa 02 00 00       	call   800b98 <strnlen>
  80089e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8008a1:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  8008a3:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8008a7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8008aa:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8008ad:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008af:	eb 0f                	jmp    8008c0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8008b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b8:	89 04 24             	mov    %eax,(%esp)
  8008bb:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bd:	83 eb 01             	sub    $0x1,%ebx
  8008c0:	85 db                	test   %ebx,%ebx
  8008c2:	7f ed                	jg     8008b1 <vprintfmt+0x1c2>
  8008c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008c7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8008ca:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008cd:	89 f7                	mov    %esi,%edi
  8008cf:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008d2:	eb 40                	jmp    800914 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008d4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008d8:	74 18                	je     8008f2 <vprintfmt+0x203>
  8008da:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008dd:	83 fa 5e             	cmp    $0x5e,%edx
  8008e0:	76 10                	jbe    8008f2 <vprintfmt+0x203>
					putch('?', putdat);
  8008e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008e6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008ed:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008f0:	eb 0a                	jmp    8008fc <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8008f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800900:	eb 12                	jmp    800914 <vprintfmt+0x225>
  800902:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800905:	89 f7                	mov    %esi,%edi
  800907:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80090a:	eb 08                	jmp    800914 <vprintfmt+0x225>
  80090c:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80090f:	89 f7                	mov    %esi,%edi
  800911:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800914:	0f be 03             	movsbl (%ebx),%eax
  800917:	83 c3 01             	add    $0x1,%ebx
  80091a:	85 c0                	test   %eax,%eax
  80091c:	74 25                	je     800943 <vprintfmt+0x254>
  80091e:	85 f6                	test   %esi,%esi
  800920:	78 b2                	js     8008d4 <vprintfmt+0x1e5>
  800922:	83 ee 01             	sub    $0x1,%esi
  800925:	79 ad                	jns    8008d4 <vprintfmt+0x1e5>
  800927:	89 fe                	mov    %edi,%esi
  800929:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80092c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80092f:	eb 1a                	jmp    80094b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800931:	89 74 24 04          	mov    %esi,0x4(%esp)
  800935:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80093c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80093e:	83 eb 01             	sub    $0x1,%ebx
  800941:	eb 08                	jmp    80094b <vprintfmt+0x25c>
  800943:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800946:	89 fe                	mov    %edi,%esi
  800948:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80094b:	85 db                	test   %ebx,%ebx
  80094d:	7f e2                	jg     800931 <vprintfmt+0x242>
  80094f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800952:	e9 c4 fd ff ff       	jmp    80071b <vprintfmt+0x2c>
  800957:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80095a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80095d:	83 f9 01             	cmp    $0x1,%ecx
  800960:	7e 16                	jle    800978 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800962:	8b 45 14             	mov    0x14(%ebp),%eax
  800965:	8d 50 08             	lea    0x8(%eax),%edx
  800968:	89 55 14             	mov    %edx,0x14(%ebp)
  80096b:	8b 10                	mov    (%eax),%edx
  80096d:	8b 48 04             	mov    0x4(%eax),%ecx
  800970:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800973:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800976:	eb 32                	jmp    8009aa <vprintfmt+0x2bb>
	else if (lflag)
  800978:	85 c9                	test   %ecx,%ecx
  80097a:	74 18                	je     800994 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80097c:	8b 45 14             	mov    0x14(%ebp),%eax
  80097f:	8d 50 04             	lea    0x4(%eax),%edx
  800982:	89 55 14             	mov    %edx,0x14(%ebp)
  800985:	8b 00                	mov    (%eax),%eax
  800987:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80098a:	89 c1                	mov    %eax,%ecx
  80098c:	c1 f9 1f             	sar    $0x1f,%ecx
  80098f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800992:	eb 16                	jmp    8009aa <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800994:	8b 45 14             	mov    0x14(%ebp),%eax
  800997:	8d 50 04             	lea    0x4(%eax),%edx
  80099a:	89 55 14             	mov    %edx,0x14(%ebp)
  80099d:	8b 00                	mov    (%eax),%eax
  80099f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009a2:	89 c2                	mov    %eax,%edx
  8009a4:	c1 fa 1f             	sar    $0x1f,%edx
  8009a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009aa:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8009ad:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009b0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8009b5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009b9:	0f 89 a7 00 00 00    	jns    800a66 <vprintfmt+0x377>
				putch('-', putdat);
  8009bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009c3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ca:	ff d7                	call   *%edi
				num = -(long long) num;
  8009cc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8009cf:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009d2:	f7 d9                	neg    %ecx
  8009d4:	83 d3 00             	adc    $0x0,%ebx
  8009d7:	f7 db                	neg    %ebx
  8009d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009de:	e9 83 00 00 00       	jmp    800a66 <vprintfmt+0x377>
  8009e3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009e6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009e9:	89 ca                	mov    %ecx,%edx
  8009eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ee:	e8 a5 fc ff ff       	call   800698 <getuint>
  8009f3:	89 c1                	mov    %eax,%ecx
  8009f5:	89 d3                	mov    %edx,%ebx
  8009f7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8009fc:	eb 68                	jmp    800a66 <vprintfmt+0x377>
  8009fe:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800a01:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800a04:	89 ca                	mov    %ecx,%edx
  800a06:	8d 45 14             	lea    0x14(%ebp),%eax
  800a09:	e8 8a fc ff ff       	call   800698 <getuint>
  800a0e:	89 c1                	mov    %eax,%ecx
  800a10:	89 d3                	mov    %edx,%ebx
  800a12:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800a17:	eb 4d                	jmp    800a66 <vprintfmt+0x377>
  800a19:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800a1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a20:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a27:	ff d7                	call   *%edi
			putch('x', putdat);
  800a29:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a34:	ff d7                	call   *%edi
			num = (unsigned long long)
  800a36:	8b 45 14             	mov    0x14(%ebp),%eax
  800a39:	8d 50 04             	lea    0x4(%eax),%edx
  800a3c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a3f:	8b 08                	mov    (%eax),%ecx
  800a41:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a46:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a4b:	eb 19                	jmp    800a66 <vprintfmt+0x377>
  800a4d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800a50:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a53:	89 ca                	mov    %ecx,%edx
  800a55:	8d 45 14             	lea    0x14(%ebp),%eax
  800a58:	e8 3b fc ff ff       	call   800698 <getuint>
  800a5d:	89 c1                	mov    %eax,%ecx
  800a5f:	89 d3                	mov    %edx,%ebx
  800a61:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a66:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  800a6a:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a71:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a79:	89 0c 24             	mov    %ecx,(%esp)
  800a7c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a80:	89 f2                	mov    %esi,%edx
  800a82:	89 f8                	mov    %edi,%eax
  800a84:	e8 27 fb ff ff       	call   8005b0 <printnum>
  800a89:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a8c:	e9 8a fc ff ff       	jmp    80071b <vprintfmt+0x2c>
  800a91:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a94:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a98:	89 04 24             	mov    %eax,(%esp)
  800a9b:	ff d7                	call   *%edi
  800a9d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800aa0:	e9 76 fc ff ff       	jmp    80071b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aa5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aa9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ab0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ab2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ab5:	80 38 25             	cmpb   $0x25,(%eax)
  800ab8:	0f 84 5d fc ff ff    	je     80071b <vprintfmt+0x2c>
  800abe:	89 c3                	mov    %eax,%ebx
  800ac0:	eb f0                	jmp    800ab2 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800ac2:	83 c4 4c             	add    $0x4c,%esp
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5f                   	pop    %edi
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	83 ec 28             	sub    $0x28,%esp
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	74 04                	je     800ade <vsnprintf+0x14>
  800ada:	85 d2                	test   %edx,%edx
  800adc:	7f 07                	jg     800ae5 <vsnprintf+0x1b>
  800ade:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ae3:	eb 3b                	jmp    800b20 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ae5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ae8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800aec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800af6:	8b 45 14             	mov    0x14(%ebp),%eax
  800af9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800afd:	8b 45 10             	mov    0x10(%ebp),%eax
  800b00:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b04:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0b:	c7 04 24 d2 06 80 00 	movl   $0x8006d2,(%esp)
  800b12:	e8 d8 fb ff ff       	call   8006ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b17:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b1a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b20:	c9                   	leave  
  800b21:	c3                   	ret    

00800b22 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b28:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b32:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	89 04 24             	mov    %eax,(%esp)
  800b43:	e8 82 ff ff ff       	call   800aca <vsnprintf>
	va_end(ap);

	return rc;
}
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    

00800b4a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b50:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b53:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b57:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	89 04 24             	mov    %eax,(%esp)
  800b6b:	e8 7f fb ff ff       	call   8006ef <vprintfmt>
	va_end(ap);
}
  800b70:	c9                   	leave  
  800b71:	c3                   	ret    
	...

00800b80 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  800b8b:	eb 03                	jmp    800b90 <strlen+0x10>
		n++;
  800b8d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b90:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b94:	75 f7                	jne    800b8d <strlen+0xd>
		n++;
	return n;
}
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	53                   	push   %ebx
  800b9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba7:	eb 03                	jmp    800bac <strnlen+0x14>
		n++;
  800ba9:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bac:	39 c1                	cmp    %eax,%ecx
  800bae:	74 06                	je     800bb6 <strnlen+0x1e>
  800bb0:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bb4:	75 f3                	jne    800ba9 <strnlen+0x11>
		n++;
	return n;
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	53                   	push   %ebx
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bcc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bcf:	83 c2 01             	add    $0x1,%edx
  800bd2:	84 c9                	test   %cl,%cl
  800bd4:	75 f2                	jne    800bc8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 08             	sub    $0x8,%esp
  800be0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be3:	89 1c 24             	mov    %ebx,(%esp)
  800be6:	e8 95 ff ff ff       	call   800b80 <strlen>
	strcpy(dst + len, src);
  800beb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bee:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bf2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bf5:	89 04 24             	mov    %eax,(%esp)
  800bf8:	e8 bc ff ff ff       	call   800bb9 <strcpy>
	return dst;
}
  800bfd:	89 d8                	mov    %ebx,%eax
  800bff:	83 c4 08             	add    $0x8,%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c10:	8b 75 10             	mov    0x10(%ebp),%esi
  800c13:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c18:	eb 0f                	jmp    800c29 <strncpy+0x24>
		*dst++ = *src;
  800c1a:	0f b6 19             	movzbl (%ecx),%ebx
  800c1d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c20:	80 39 01             	cmpb   $0x1,(%ecx)
  800c23:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c26:	83 c2 01             	add    $0x1,%edx
  800c29:	39 f2                	cmp    %esi,%edx
  800c2b:	72 ed                	jb     800c1a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	8b 75 08             	mov    0x8(%ebp),%esi
  800c39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c3f:	89 f0                	mov    %esi,%eax
  800c41:	85 d2                	test   %edx,%edx
  800c43:	75 0a                	jne    800c4f <strlcpy+0x1e>
  800c45:	eb 17                	jmp    800c5e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c47:	88 18                	mov    %bl,(%eax)
  800c49:	83 c0 01             	add    $0x1,%eax
  800c4c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c4f:	83 ea 01             	sub    $0x1,%edx
  800c52:	74 07                	je     800c5b <strlcpy+0x2a>
  800c54:	0f b6 19             	movzbl (%ecx),%ebx
  800c57:	84 db                	test   %bl,%bl
  800c59:	75 ec                	jne    800c47 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  800c5b:	c6 00 00             	movb   $0x0,(%eax)
  800c5e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c6d:	eb 06                	jmp    800c75 <strcmp+0x11>
		p++, q++;
  800c6f:	83 c1 01             	add    $0x1,%ecx
  800c72:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c75:	0f b6 01             	movzbl (%ecx),%eax
  800c78:	84 c0                	test   %al,%al
  800c7a:	74 04                	je     800c80 <strcmp+0x1c>
  800c7c:	3a 02                	cmp    (%edx),%al
  800c7e:	74 ef                	je     800c6f <strcmp+0xb>
  800c80:	0f b6 c0             	movzbl %al,%eax
  800c83:	0f b6 12             	movzbl (%edx),%edx
  800c86:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	53                   	push   %ebx
  800c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c97:	eb 09                	jmp    800ca2 <strncmp+0x18>
		n--, p++, q++;
  800c99:	83 ea 01             	sub    $0x1,%edx
  800c9c:	83 c0 01             	add    $0x1,%eax
  800c9f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ca2:	85 d2                	test   %edx,%edx
  800ca4:	75 07                	jne    800cad <strncmp+0x23>
  800ca6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cab:	eb 13                	jmp    800cc0 <strncmp+0x36>
  800cad:	0f b6 18             	movzbl (%eax),%ebx
  800cb0:	84 db                	test   %bl,%bl
  800cb2:	74 04                	je     800cb8 <strncmp+0x2e>
  800cb4:	3a 19                	cmp    (%ecx),%bl
  800cb6:	74 e1                	je     800c99 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb8:	0f b6 00             	movzbl (%eax),%eax
  800cbb:	0f b6 11             	movzbl (%ecx),%edx
  800cbe:	29 d0                	sub    %edx,%eax
}
  800cc0:	5b                   	pop    %ebx
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ccd:	eb 07                	jmp    800cd6 <strchr+0x13>
		if (*s == c)
  800ccf:	38 ca                	cmp    %cl,%dl
  800cd1:	74 0f                	je     800ce2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cd3:	83 c0 01             	add    $0x1,%eax
  800cd6:	0f b6 10             	movzbl (%eax),%edx
  800cd9:	84 d2                	test   %dl,%dl
  800cdb:	75 f2                	jne    800ccf <strchr+0xc>
  800cdd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cea:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cee:	eb 07                	jmp    800cf7 <strfind+0x13>
		if (*s == c)
  800cf0:	38 ca                	cmp    %cl,%dl
  800cf2:	74 0a                	je     800cfe <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cf4:	83 c0 01             	add    $0x1,%eax
  800cf7:	0f b6 10             	movzbl (%eax),%edx
  800cfa:	84 d2                	test   %dl,%dl
  800cfc:	75 f2                	jne    800cf0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800cfe:	5d                   	pop    %ebp
  800cff:	90                   	nop
  800d00:	c3                   	ret    

00800d01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	89 1c 24             	mov    %ebx,(%esp)
  800d0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d12:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d1b:	85 c9                	test   %ecx,%ecx
  800d1d:	74 30                	je     800d4f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d25:	75 25                	jne    800d4c <memset+0x4b>
  800d27:	f6 c1 03             	test   $0x3,%cl
  800d2a:	75 20                	jne    800d4c <memset+0x4b>
		c &= 0xFF;
  800d2c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d2f:	89 d3                	mov    %edx,%ebx
  800d31:	c1 e3 08             	shl    $0x8,%ebx
  800d34:	89 d6                	mov    %edx,%esi
  800d36:	c1 e6 18             	shl    $0x18,%esi
  800d39:	89 d0                	mov    %edx,%eax
  800d3b:	c1 e0 10             	shl    $0x10,%eax
  800d3e:	09 f0                	or     %esi,%eax
  800d40:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d42:	09 d8                	or     %ebx,%eax
  800d44:	c1 e9 02             	shr    $0x2,%ecx
  800d47:	fc                   	cld    
  800d48:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d4a:	eb 03                	jmp    800d4f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d4c:	fc                   	cld    
  800d4d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d4f:	89 f8                	mov    %edi,%eax
  800d51:	8b 1c 24             	mov    (%esp),%ebx
  800d54:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d58:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d5c:	89 ec                	mov    %ebp,%esp
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 08             	sub    $0x8,%esp
  800d66:	89 34 24             	mov    %esi,(%esp)
  800d69:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800d73:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d76:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d78:	39 c6                	cmp    %eax,%esi
  800d7a:	73 35                	jae    800db1 <memmove+0x51>
  800d7c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d7f:	39 d0                	cmp    %edx,%eax
  800d81:	73 2e                	jae    800db1 <memmove+0x51>
		s += n;
		d += n;
  800d83:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d85:	f6 c2 03             	test   $0x3,%dl
  800d88:	75 1b                	jne    800da5 <memmove+0x45>
  800d8a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d90:	75 13                	jne    800da5 <memmove+0x45>
  800d92:	f6 c1 03             	test   $0x3,%cl
  800d95:	75 0e                	jne    800da5 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d97:	83 ef 04             	sub    $0x4,%edi
  800d9a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d9d:	c1 e9 02             	shr    $0x2,%ecx
  800da0:	fd                   	std    
  800da1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da3:	eb 09                	jmp    800dae <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800da5:	83 ef 01             	sub    $0x1,%edi
  800da8:	8d 72 ff             	lea    -0x1(%edx),%esi
  800dab:	fd                   	std    
  800dac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dae:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800daf:	eb 20                	jmp    800dd1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800db1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800db7:	75 15                	jne    800dce <memmove+0x6e>
  800db9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dbf:	75 0d                	jne    800dce <memmove+0x6e>
  800dc1:	f6 c1 03             	test   $0x3,%cl
  800dc4:	75 08                	jne    800dce <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800dc6:	c1 e9 02             	shr    $0x2,%ecx
  800dc9:	fc                   	cld    
  800dca:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dcc:	eb 03                	jmp    800dd1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dce:	fc                   	cld    
  800dcf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dd1:	8b 34 24             	mov    (%esp),%esi
  800dd4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dd8:	89 ec                	mov    %ebp,%esp
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800de2:	8b 45 10             	mov    0x10(%ebp),%eax
  800de5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dec:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	89 04 24             	mov    %eax,(%esp)
  800df6:	e8 65 ff ff ff       	call   800d60 <memmove>
}
  800dfb:	c9                   	leave  
  800dfc:	c3                   	ret    

00800dfd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e09:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e0c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e11:	eb 1c                	jmp    800e2f <memcmp+0x32>
		if (*s1 != *s2)
  800e13:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800e17:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800e1b:	83 c2 01             	add    $0x1,%edx
  800e1e:	83 e9 01             	sub    $0x1,%ecx
  800e21:	38 d8                	cmp    %bl,%al
  800e23:	74 0a                	je     800e2f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800e25:	0f b6 c0             	movzbl %al,%eax
  800e28:	0f b6 db             	movzbl %bl,%ebx
  800e2b:	29 d8                	sub    %ebx,%eax
  800e2d:	eb 09                	jmp    800e38 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e2f:	85 c9                	test   %ecx,%ecx
  800e31:	75 e0                	jne    800e13 <memcmp+0x16>
  800e33:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e46:	89 c2                	mov    %eax,%edx
  800e48:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e4b:	eb 07                	jmp    800e54 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e4d:	38 08                	cmp    %cl,(%eax)
  800e4f:	74 07                	je     800e58 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e51:	83 c0 01             	add    $0x1,%eax
  800e54:	39 d0                	cmp    %edx,%eax
  800e56:	72 f5                	jb     800e4d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    

00800e5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	83 ec 04             	sub    $0x4,%esp
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e69:	eb 03                	jmp    800e6e <strtol+0x14>
		s++;
  800e6b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e6e:	0f b6 02             	movzbl (%edx),%eax
  800e71:	3c 20                	cmp    $0x20,%al
  800e73:	74 f6                	je     800e6b <strtol+0x11>
  800e75:	3c 09                	cmp    $0x9,%al
  800e77:	74 f2                	je     800e6b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e79:	3c 2b                	cmp    $0x2b,%al
  800e7b:	75 0c                	jne    800e89 <strtol+0x2f>
		s++;
  800e7d:	8d 52 01             	lea    0x1(%edx),%edx
  800e80:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e87:	eb 15                	jmp    800e9e <strtol+0x44>
	else if (*s == '-')
  800e89:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e90:	3c 2d                	cmp    $0x2d,%al
  800e92:	75 0a                	jne    800e9e <strtol+0x44>
		s++, neg = 1;
  800e94:	8d 52 01             	lea    0x1(%edx),%edx
  800e97:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e9e:	85 db                	test   %ebx,%ebx
  800ea0:	0f 94 c0             	sete   %al
  800ea3:	74 05                	je     800eaa <strtol+0x50>
  800ea5:	83 fb 10             	cmp    $0x10,%ebx
  800ea8:	75 18                	jne    800ec2 <strtol+0x68>
  800eaa:	80 3a 30             	cmpb   $0x30,(%edx)
  800ead:	75 13                	jne    800ec2 <strtol+0x68>
  800eaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800eb3:	75 0d                	jne    800ec2 <strtol+0x68>
		s += 2, base = 16;
  800eb5:	83 c2 02             	add    $0x2,%edx
  800eb8:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ebd:	8d 76 00             	lea    0x0(%esi),%esi
  800ec0:	eb 13                	jmp    800ed5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ec2:	84 c0                	test   %al,%al
  800ec4:	74 0f                	je     800ed5 <strtol+0x7b>
  800ec6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ecb:	80 3a 30             	cmpb   $0x30,(%edx)
  800ece:	75 05                	jne    800ed5 <strtol+0x7b>
		s++, base = 8;
  800ed0:	83 c2 01             	add    $0x1,%edx
  800ed3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800edc:	0f b6 0a             	movzbl (%edx),%ecx
  800edf:	89 cf                	mov    %ecx,%edi
  800ee1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ee4:	80 fb 09             	cmp    $0x9,%bl
  800ee7:	77 08                	ja     800ef1 <strtol+0x97>
			dig = *s - '0';
  800ee9:	0f be c9             	movsbl %cl,%ecx
  800eec:	83 e9 30             	sub    $0x30,%ecx
  800eef:	eb 1e                	jmp    800f0f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800ef1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ef4:	80 fb 19             	cmp    $0x19,%bl
  800ef7:	77 08                	ja     800f01 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800ef9:	0f be c9             	movsbl %cl,%ecx
  800efc:	83 e9 57             	sub    $0x57,%ecx
  800eff:	eb 0e                	jmp    800f0f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800f01:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f04:	80 fb 19             	cmp    $0x19,%bl
  800f07:	77 15                	ja     800f1e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800f09:	0f be c9             	movsbl %cl,%ecx
  800f0c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f0f:	39 f1                	cmp    %esi,%ecx
  800f11:	7d 0b                	jge    800f1e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800f13:	83 c2 01             	add    $0x1,%edx
  800f16:	0f af c6             	imul   %esi,%eax
  800f19:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f1c:	eb be                	jmp    800edc <strtol+0x82>
  800f1e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f24:	74 05                	je     800f2b <strtol+0xd1>
		*endptr = (char *) s;
  800f26:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f29:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f2b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f2f:	74 04                	je     800f35 <strtol+0xdb>
  800f31:	89 c8                	mov    %ecx,%eax
  800f33:	f7 d8                	neg    %eax
}
  800f35:	83 c4 04             	add    $0x4,%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    
  800f3d:	00 00                	add    %al,(%eax)
	...

00800f40 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f46:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f4d:	75 58                	jne    800fa7 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  800f4f:	a1 04 20 80 00       	mov    0x802004,%eax
  800f54:	8b 40 48             	mov    0x48(%eax),%eax
  800f57:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f5e:	00 
  800f5f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f66:	ee 
  800f67:	89 04 24             	mov    %eax,(%esp)
  800f6a:	e8 a3 f3 ff ff       	call   800312 <sys_page_alloc>
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	74 1c                	je     800f8f <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  800f73:	c7 44 24 08 08 15 80 	movl   $0x801508,0x8(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f82:	00 
  800f83:	c7 04 24 34 15 80 00 	movl   $0x801534,(%esp)
  800f8a:	e8 05 f5 ff ff       	call   800494 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  800f8f:	a1 04 20 80 00       	mov    0x802004,%eax
  800f94:	8b 40 48             	mov    0x48(%eax),%eax
  800f97:	c7 44 24 04 6c 04 80 	movl   $0x80046c,0x4(%esp)
  800f9e:	00 
  800f9f:	89 04 24             	mov    %eax,(%esp)
  800fa2:	e8 4c f1 ff ff       	call   8000f3 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800fa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800faa:	a3 08 20 80 00       	mov    %eax,0x802008
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    
	...

00800fc0 <__udivdi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	83 ec 10             	sub    $0x10,%esp
  800fc8:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fce:	8b 75 10             	mov    0x10(%ebp),%esi
  800fd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800fd9:	75 35                	jne    801010 <__udivdi3+0x50>
  800fdb:	39 fe                	cmp    %edi,%esi
  800fdd:	77 61                	ja     801040 <__udivdi3+0x80>
  800fdf:	85 f6                	test   %esi,%esi
  800fe1:	75 0b                	jne    800fee <__udivdi3+0x2e>
  800fe3:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe8:	31 d2                	xor    %edx,%edx
  800fea:	f7 f6                	div    %esi
  800fec:	89 c6                	mov    %eax,%esi
  800fee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800ff1:	31 d2                	xor    %edx,%edx
  800ff3:	89 f8                	mov    %edi,%eax
  800ff5:	f7 f6                	div    %esi
  800ff7:	89 c7                	mov    %eax,%edi
  800ff9:	89 c8                	mov    %ecx,%eax
  800ffb:	f7 f6                	div    %esi
  800ffd:	89 c1                	mov    %eax,%ecx
  800fff:	89 fa                	mov    %edi,%edx
  801001:	89 c8                	mov    %ecx,%eax
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    
  80100a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801010:	39 f8                	cmp    %edi,%eax
  801012:	77 1c                	ja     801030 <__udivdi3+0x70>
  801014:	0f bd d0             	bsr    %eax,%edx
  801017:	83 f2 1f             	xor    $0x1f,%edx
  80101a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80101d:	75 39                	jne    801058 <__udivdi3+0x98>
  80101f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801022:	0f 86 a0 00 00 00    	jbe    8010c8 <__udivdi3+0x108>
  801028:	39 f8                	cmp    %edi,%eax
  80102a:	0f 82 98 00 00 00    	jb     8010c8 <__udivdi3+0x108>
  801030:	31 ff                	xor    %edi,%edi
  801032:	31 c9                	xor    %ecx,%ecx
  801034:	89 c8                	mov    %ecx,%eax
  801036:	89 fa                	mov    %edi,%edx
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    
  80103f:	90                   	nop
  801040:	89 d1                	mov    %edx,%ecx
  801042:	89 fa                	mov    %edi,%edx
  801044:	89 c8                	mov    %ecx,%eax
  801046:	31 ff                	xor    %edi,%edi
  801048:	f7 f6                	div    %esi
  80104a:	89 c1                	mov    %eax,%ecx
  80104c:	89 fa                	mov    %edi,%edx
  80104e:	89 c8                	mov    %ecx,%eax
  801050:	83 c4 10             	add    $0x10,%esp
  801053:	5e                   	pop    %esi
  801054:	5f                   	pop    %edi
  801055:	5d                   	pop    %ebp
  801056:	c3                   	ret    
  801057:	90                   	nop
  801058:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80105c:	89 f2                	mov    %esi,%edx
  80105e:	d3 e0                	shl    %cl,%eax
  801060:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801063:	b8 20 00 00 00       	mov    $0x20,%eax
  801068:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80106b:	89 c1                	mov    %eax,%ecx
  80106d:	d3 ea                	shr    %cl,%edx
  80106f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801073:	0b 55 ec             	or     -0x14(%ebp),%edx
  801076:	d3 e6                	shl    %cl,%esi
  801078:	89 c1                	mov    %eax,%ecx
  80107a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80107d:	89 fe                	mov    %edi,%esi
  80107f:	d3 ee                	shr    %cl,%esi
  801081:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801085:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801088:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108b:	d3 e7                	shl    %cl,%edi
  80108d:	89 c1                	mov    %eax,%ecx
  80108f:	d3 ea                	shr    %cl,%edx
  801091:	09 d7                	or     %edx,%edi
  801093:	89 f2                	mov    %esi,%edx
  801095:	89 f8                	mov    %edi,%eax
  801097:	f7 75 ec             	divl   -0x14(%ebp)
  80109a:	89 d6                	mov    %edx,%esi
  80109c:	89 c7                	mov    %eax,%edi
  80109e:	f7 65 e8             	mull   -0x18(%ebp)
  8010a1:	39 d6                	cmp    %edx,%esi
  8010a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010a6:	72 30                	jb     8010d8 <__udivdi3+0x118>
  8010a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010af:	d3 e2                	shl    %cl,%edx
  8010b1:	39 c2                	cmp    %eax,%edx
  8010b3:	73 05                	jae    8010ba <__udivdi3+0xfa>
  8010b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010b8:	74 1e                	je     8010d8 <__udivdi3+0x118>
  8010ba:	89 f9                	mov    %edi,%ecx
  8010bc:	31 ff                	xor    %edi,%edi
  8010be:	e9 71 ff ff ff       	jmp    801034 <__udivdi3+0x74>
  8010c3:	90                   	nop
  8010c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	31 ff                	xor    %edi,%edi
  8010ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010cf:	e9 60 ff ff ff       	jmp    801034 <__udivdi3+0x74>
  8010d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010db:	31 ff                	xor    %edi,%edi
  8010dd:	89 c8                	mov    %ecx,%eax
  8010df:	89 fa                	mov    %edi,%edx
  8010e1:	83 c4 10             	add    $0x10,%esp
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    
	...

008010f0 <__umoddi3>:
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	83 ec 20             	sub    $0x20,%esp
  8010f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8010fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801101:	8b 75 0c             	mov    0xc(%ebp),%esi
  801104:	85 d2                	test   %edx,%edx
  801106:	89 c8                	mov    %ecx,%eax
  801108:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80110b:	75 13                	jne    801120 <__umoddi3+0x30>
  80110d:	39 f7                	cmp    %esi,%edi
  80110f:	76 3f                	jbe    801150 <__umoddi3+0x60>
  801111:	89 f2                	mov    %esi,%edx
  801113:	f7 f7                	div    %edi
  801115:	89 d0                	mov    %edx,%eax
  801117:	31 d2                	xor    %edx,%edx
  801119:	83 c4 20             	add    $0x20,%esp
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    
  801120:	39 f2                	cmp    %esi,%edx
  801122:	77 4c                	ja     801170 <__umoddi3+0x80>
  801124:	0f bd ca             	bsr    %edx,%ecx
  801127:	83 f1 1f             	xor    $0x1f,%ecx
  80112a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80112d:	75 51                	jne    801180 <__umoddi3+0x90>
  80112f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801132:	0f 87 e0 00 00 00    	ja     801218 <__umoddi3+0x128>
  801138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113b:	29 f8                	sub    %edi,%eax
  80113d:	19 d6                	sbb    %edx,%esi
  80113f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801145:	89 f2                	mov    %esi,%edx
  801147:	83 c4 20             	add    $0x20,%esp
  80114a:	5e                   	pop    %esi
  80114b:	5f                   	pop    %edi
  80114c:	5d                   	pop    %ebp
  80114d:	c3                   	ret    
  80114e:	66 90                	xchg   %ax,%ax
  801150:	85 ff                	test   %edi,%edi
  801152:	75 0b                	jne    80115f <__umoddi3+0x6f>
  801154:	b8 01 00 00 00       	mov    $0x1,%eax
  801159:	31 d2                	xor    %edx,%edx
  80115b:	f7 f7                	div    %edi
  80115d:	89 c7                	mov    %eax,%edi
  80115f:	89 f0                	mov    %esi,%eax
  801161:	31 d2                	xor    %edx,%edx
  801163:	f7 f7                	div    %edi
  801165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801168:	f7 f7                	div    %edi
  80116a:	eb a9                	jmp    801115 <__umoddi3+0x25>
  80116c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801170:	89 c8                	mov    %ecx,%eax
  801172:	89 f2                	mov    %esi,%edx
  801174:	83 c4 20             	add    $0x20,%esp
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    
  80117b:	90                   	nop
  80117c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801180:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801184:	d3 e2                	shl    %cl,%edx
  801186:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801189:	ba 20 00 00 00       	mov    $0x20,%edx
  80118e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801191:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801194:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801198:	89 fa                	mov    %edi,%edx
  80119a:	d3 ea                	shr    %cl,%edx
  80119c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011a3:	d3 e7                	shl    %cl,%edi
  8011a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011ac:	89 f2                	mov    %esi,%edx
  8011ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011b1:	89 c7                	mov    %eax,%edi
  8011b3:	d3 ea                	shr    %cl,%edx
  8011b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	d3 e6                	shl    %cl,%esi
  8011c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c4:	d3 ea                	shr    %cl,%edx
  8011c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ca:	09 d6                	or     %edx,%esi
  8011cc:	89 f0                	mov    %esi,%eax
  8011ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011d1:	d3 e7                	shl    %cl,%edi
  8011d3:	89 f2                	mov    %esi,%edx
  8011d5:	f7 75 f4             	divl   -0xc(%ebp)
  8011d8:	89 d6                	mov    %edx,%esi
  8011da:	f7 65 e8             	mull   -0x18(%ebp)
  8011dd:	39 d6                	cmp    %edx,%esi
  8011df:	72 2b                	jb     80120c <__umoddi3+0x11c>
  8011e1:	39 c7                	cmp    %eax,%edi
  8011e3:	72 23                	jb     801208 <__umoddi3+0x118>
  8011e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011e9:	29 c7                	sub    %eax,%edi
  8011eb:	19 d6                	sbb    %edx,%esi
  8011ed:	89 f0                	mov    %esi,%eax
  8011ef:	89 f2                	mov    %esi,%edx
  8011f1:	d3 ef                	shr    %cl,%edi
  8011f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011f7:	d3 e0                	shl    %cl,%eax
  8011f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011fd:	09 f8                	or     %edi,%eax
  8011ff:	d3 ea                	shr    %cl,%edx
  801201:	83 c4 20             	add    $0x20,%esp
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    
  801208:	39 d6                	cmp    %edx,%esi
  80120a:	75 d9                	jne    8011e5 <__umoddi3+0xf5>
  80120c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80120f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801212:	eb d1                	jmp    8011e5 <__umoddi3+0xf5>
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	39 f2                	cmp    %esi,%edx
  80121a:	0f 82 18 ff ff ff    	jb     801138 <__umoddi3+0x48>
  801220:	e9 1d ff ff ff       	jmp    801142 <__umoddi3+0x52>
