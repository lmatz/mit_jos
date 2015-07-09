
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 20 80 00       	mov    0x802000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 69 00 00 00       	call   8000b8 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  800066:	e8 32 03 00 00       	call   80039d <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b1:	e8 1b 03 00 00       	call   8003d1 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	89 1c 24             	mov    %ebx,(%esp)
  8000c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d4:	89 c3                	mov    %eax,%ebx
  8000d6:	89 c7                	mov    %eax,%edi
  8000d8:	89 c6                	mov    %eax,%esi
  8000da:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dc:	8b 1c 24             	mov    (%esp),%ebx
  8000df:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000e3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000e7:	89 ec                	mov    %ebp,%esp
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 38             	sub    $0x38,%esp
  8000f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  8000fa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000fe:	75 0c                	jne    80010c <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800100:	c7 04 24 98 11 80 00 	movl   $0x801198,(%esp)
  800107:	e8 11 04 00 00       	call   80051d <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800111:	b8 09 00 00 00       	mov    $0x9,%eax
  800116:	8b 55 08             	mov    0x8(%ebp),%edx
  800119:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80011c:	89 df                	mov    %ebx,%edi
  80011e:	89 de                	mov    %ebx,%esi
  800120:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800122:	85 c0                	test   %eax,%eax
  800124:	7e 28                	jle    80014e <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800126:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800131:	00 
  800132:	c7 44 24 08 c4 11 80 	movl   $0x8011c4,0x8(%esp)
  800139:	00 
  80013a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800141:	00 
  800142:	c7 04 24 e1 11 80 00 	movl   $0x8011e1,(%esp)
  800149:	e8 16 03 00 00       	call   800464 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80014e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800151:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800154:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800157:	89 ec                	mov    %ebp,%esp
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 38             	sub    $0x38,%esp
  800161:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800164:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800167:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80016f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	89 cb                	mov    %ecx,%ebx
  800179:	89 cf                	mov    %ecx,%edi
  80017b:	89 ce                	mov    %ecx,%esi
  80017d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017f:	85 c0                	test   %eax,%eax
  800181:	7e 28                	jle    8001ab <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800183:	89 44 24 10          	mov    %eax,0x10(%esp)
  800187:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80018e:	00 
  80018f:	c7 44 24 08 c4 11 80 	movl   $0x8011c4,0x8(%esp)
  800196:	00 
  800197:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80019e:	00 
  80019f:	c7 04 24 e1 11 80 00 	movl   $0x8011e1,(%esp)
  8001a6:	e8 b9 02 00 00       	call   800464 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8001ab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001ae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001b1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001b4:	89 ec                	mov    %ebp,%esp
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	89 1c 24             	mov    %ebx,(%esp)
  8001c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c9:	be 00 00 00 00       	mov    $0x0,%esi
  8001ce:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8001e1:	8b 1c 24             	mov    (%esp),%ebx
  8001e4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001e8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001ec:	89 ec                	mov    %ebp,%esp
  8001ee:	5d                   	pop    %ebp
  8001ef:	c3                   	ret    

008001f0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 38             	sub    $0x38,%esp
  8001f6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001f9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001fc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800204:	b8 08 00 00 00       	mov    $0x8,%eax
  800209:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020c:	8b 55 08             	mov    0x8(%ebp),%edx
  80020f:	89 df                	mov    %ebx,%edi
  800211:	89 de                	mov    %ebx,%esi
  800213:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800215:	85 c0                	test   %eax,%eax
  800217:	7e 28                	jle    800241 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800219:	89 44 24 10          	mov    %eax,0x10(%esp)
  80021d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800224:	00 
  800225:	c7 44 24 08 c4 11 80 	movl   $0x8011c4,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 e1 11 80 00 	movl   $0x8011e1,(%esp)
  80023c:	e8 23 02 00 00       	call   800464 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800241:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800244:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800247:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80024a:	89 ec                	mov    %ebp,%esp
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	83 ec 38             	sub    $0x38,%esp
  800254:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800257:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80025a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80025d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800262:	b8 06 00 00 00       	mov    $0x6,%eax
  800267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026a:	8b 55 08             	mov    0x8(%ebp),%edx
  80026d:	89 df                	mov    %ebx,%edi
  80026f:	89 de                	mov    %ebx,%esi
  800271:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800273:	85 c0                	test   %eax,%eax
  800275:	7e 28                	jle    80029f <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800277:	89 44 24 10          	mov    %eax,0x10(%esp)
  80027b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800282:	00 
  800283:	c7 44 24 08 c4 11 80 	movl   $0x8011c4,0x8(%esp)
  80028a:	00 
  80028b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800292:	00 
  800293:	c7 04 24 e1 11 80 00 	movl   $0x8011e1,(%esp)
  80029a:	e8 c5 01 00 00       	call   800464 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80029f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002a2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002a5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002a8:	89 ec                	mov    %ebp,%esp
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 38             	sub    $0x38,%esp
  8002b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8002c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8002c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d1:	85 c0                	test   %eax,%eax
  8002d3:	7e 28                	jle    8002fd <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8002e0:	00 
  8002e1:	c7 44 24 08 c4 11 80 	movl   $0x8011c4,0x8(%esp)
  8002e8:	00 
  8002e9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002f0:	00 
  8002f1:	c7 04 24 e1 11 80 00 	movl   $0x8011e1,(%esp)
  8002f8:	e8 67 01 00 00       	call   800464 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002fd:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800300:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800303:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800306:	89 ec                	mov    %ebp,%esp
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	83 ec 38             	sub    $0x38,%esp
  800310:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800313:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800316:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800319:	be 00 00 00 00       	mov    $0x0,%esi
  80031e:	b8 04 00 00 00       	mov    $0x4,%eax
  800323:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800326:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 f7                	mov    %esi,%edi
  80032e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800330:	85 c0                	test   %eax,%eax
  800332:	7e 28                	jle    80035c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800334:	89 44 24 10          	mov    %eax,0x10(%esp)
  800338:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80033f:	00 
  800340:	c7 44 24 08 c4 11 80 	movl   $0x8011c4,0x8(%esp)
  800347:	00 
  800348:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80034f:	00 
  800350:	c7 04 24 e1 11 80 00 	movl   $0x8011e1,(%esp)
  800357:	e8 08 01 00 00       	call   800464 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80035c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80035f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800362:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800365:	89 ec                	mov    %ebp,%esp
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	83 ec 0c             	sub    $0xc,%esp
  80036f:	89 1c 24             	mov    %ebx,(%esp)
  800372:	89 74 24 04          	mov    %esi,0x4(%esp)
  800376:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
  80037f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800384:	89 d1                	mov    %edx,%ecx
  800386:	89 d3                	mov    %edx,%ebx
  800388:	89 d7                	mov    %edx,%edi
  80038a:	89 d6                	mov    %edx,%esi
  80038c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80038e:	8b 1c 24             	mov    (%esp),%ebx
  800391:	8b 74 24 04          	mov    0x4(%esp),%esi
  800395:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800399:	89 ec                	mov    %ebp,%esp
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	83 ec 0c             	sub    $0xc,%esp
  8003a3:	89 1c 24             	mov    %ebx,(%esp)
  8003a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003aa:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8003b8:	89 d1                	mov    %edx,%ecx
  8003ba:	89 d3                	mov    %edx,%ebx
  8003bc:	89 d7                	mov    %edx,%edi
  8003be:	89 d6                	mov    %edx,%esi
  8003c0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8003c2:	8b 1c 24             	mov    (%esp),%ebx
  8003c5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003c9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003cd:	89 ec                	mov    %ebp,%esp
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 38             	sub    $0x38,%esp
  8003d7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003da:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003dd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8003ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ed:	89 cb                	mov    %ecx,%ebx
  8003ef:	89 cf                	mov    %ecx,%edi
  8003f1:	89 ce                	mov    %ecx,%esi
  8003f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003f5:	85 c0                	test   %eax,%eax
  8003f7:	7e 28                	jle    800421 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003fd:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800404:	00 
  800405:	c7 44 24 08 c4 11 80 	movl   $0x8011c4,0x8(%esp)
  80040c:	00 
  80040d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800414:	00 
  800415:	c7 04 24 e1 11 80 00 	movl   $0x8011e1,(%esp)
  80041c:	e8 43 00 00 00       	call   800464 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800421:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800424:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800427:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80042a:	89 ec                	mov    %ebp,%esp
  80042c:	5d                   	pop    %ebp
  80042d:	c3                   	ret    

0080042e <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 0c             	sub    $0xc,%esp
  800434:	89 1c 24             	mov    %ebx,(%esp)
  800437:	89 74 24 04          	mov    %esi,0x4(%esp)
  80043b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80043f:	ba 00 00 00 00       	mov    $0x0,%edx
  800444:	b8 01 00 00 00       	mov    $0x1,%eax
  800449:	89 d1                	mov    %edx,%ecx
  80044b:	89 d3                	mov    %edx,%ebx
  80044d:	89 d7                	mov    %edx,%edi
  80044f:	89 d6                	mov    %edx,%esi
  800451:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800453:	8b 1c 24             	mov    (%esp),%ebx
  800456:	8b 74 24 04          	mov    0x4(%esp),%esi
  80045a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80045e:	89 ec                	mov    %ebp,%esp
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    
	...

00800464 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	56                   	push   %esi
  800468:	53                   	push   %ebx
  800469:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80046c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80046f:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800475:	e8 23 ff ff ff       	call   80039d <sys_getenvid>
  80047a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800481:	8b 55 08             	mov    0x8(%ebp),%edx
  800484:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800488:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80048c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800490:	c7 04 24 f0 11 80 00 	movl   $0x8011f0,(%esp)
  800497:	e8 81 00 00 00       	call   80051d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a3:	89 04 24             	mov    %eax,(%esp)
  8004a6:	e8 11 00 00 00       	call   8004bc <vcprintf>
	cprintf("\n");
  8004ab:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  8004b2:	e8 66 00 00 00       	call   80051d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004b7:	cc                   	int3   
  8004b8:	eb fd                	jmp    8004b7 <_panic+0x53>
	...

008004bc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004cc:	00 00 00 
	b.cnt = 0;
  8004cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f1:	c7 04 24 37 05 80 00 	movl   $0x800537,(%esp)
  8004f8:	e8 c2 01 00 00       	call   8006bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004fd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800503:	89 44 24 04          	mov    %eax,0x4(%esp)
  800507:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80050d:	89 04 24             	mov    %eax,(%esp)
  800510:	e8 a3 fb ff ff       	call   8000b8 <sys_cputs>

	return b.cnt;
}
  800515:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80051b:	c9                   	leave  
  80051c:	c3                   	ret    

0080051d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800523:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052a:	8b 45 08             	mov    0x8(%ebp),%eax
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	e8 87 ff ff ff       	call   8004bc <vcprintf>
	va_end(ap);

	return cnt;
}
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	53                   	push   %ebx
  80053b:	83 ec 14             	sub    $0x14,%esp
  80053e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800541:	8b 03                	mov    (%ebx),%eax
  800543:	8b 55 08             	mov    0x8(%ebp),%edx
  800546:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80054a:	83 c0 01             	add    $0x1,%eax
  80054d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80054f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800554:	75 19                	jne    80056f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800556:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80055d:	00 
  80055e:	8d 43 08             	lea    0x8(%ebx),%eax
  800561:	89 04 24             	mov    %eax,(%esp)
  800564:	e8 4f fb ff ff       	call   8000b8 <sys_cputs>
		b->idx = 0;
  800569:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80056f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800573:	83 c4 14             	add    $0x14,%esp
  800576:	5b                   	pop    %ebx
  800577:	5d                   	pop    %ebp
  800578:	c3                   	ret    
  800579:	00 00                	add    %al,(%eax)
  80057b:	00 00                	add    %al,(%eax)
  80057d:	00 00                	add    %al,(%eax)
	...

00800580 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 4c             	sub    $0x4c,%esp
  800589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058c:	89 d6                	mov    %edx,%esi
  80058e:	8b 45 08             	mov    0x8(%ebp),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	8b 55 0c             	mov    0xc(%ebp),%edx
  800597:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80059a:	8b 45 10             	mov    0x10(%ebp),%eax
  80059d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ab:	39 d1                	cmp    %edx,%ecx
  8005ad:	72 07                	jb     8005b6 <printnum+0x36>
  8005af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b2:	39 d0                	cmp    %edx,%eax
  8005b4:	77 69                	ja     80061f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005b6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005ba:	83 eb 01             	sub    $0x1,%ebx
  8005bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8005c9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8005cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005d0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005e1:	00 
  8005e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e5:	89 04 24             	mov    %eax,(%esp)
  8005e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ef:	e8 1c 09 00 00       	call   800f10 <__udivdi3>
  8005f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800602:	89 04 24             	mov    %eax,(%esp)
  800605:	89 54 24 04          	mov    %edx,0x4(%esp)
  800609:	89 f2                	mov    %esi,%edx
  80060b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060e:	e8 6d ff ff ff       	call   800580 <printnum>
  800613:	eb 11                	jmp    800626 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800615:	89 74 24 04          	mov    %esi,0x4(%esp)
  800619:	89 3c 24             	mov    %edi,(%esp)
  80061c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80061f:	83 eb 01             	sub    $0x1,%ebx
  800622:	85 db                	test   %ebx,%ebx
  800624:	7f ef                	jg     800615 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800626:	89 74 24 04          	mov    %esi,0x4(%esp)
  80062a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80062e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800631:	89 44 24 08          	mov    %eax,0x8(%esp)
  800635:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80063c:	00 
  80063d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800640:	89 14 24             	mov    %edx,(%esp)
  800643:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800646:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80064a:	e8 f1 09 00 00       	call   801040 <__umoddi3>
  80064f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800653:	0f be 80 14 12 80 00 	movsbl 0x801214(%eax),%eax
  80065a:	89 04 24             	mov    %eax,(%esp)
  80065d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800660:	83 c4 4c             	add    $0x4c,%esp
  800663:	5b                   	pop    %ebx
  800664:	5e                   	pop    %esi
  800665:	5f                   	pop    %edi
  800666:	5d                   	pop    %ebp
  800667:	c3                   	ret    

00800668 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80066b:	83 fa 01             	cmp    $0x1,%edx
  80066e:	7e 0e                	jle    80067e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800670:	8b 10                	mov    (%eax),%edx
  800672:	8d 4a 08             	lea    0x8(%edx),%ecx
  800675:	89 08                	mov    %ecx,(%eax)
  800677:	8b 02                	mov    (%edx),%eax
  800679:	8b 52 04             	mov    0x4(%edx),%edx
  80067c:	eb 22                	jmp    8006a0 <getuint+0x38>
	else if (lflag)
  80067e:	85 d2                	test   %edx,%edx
  800680:	74 10                	je     800692 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800682:	8b 10                	mov    (%eax),%edx
  800684:	8d 4a 04             	lea    0x4(%edx),%ecx
  800687:	89 08                	mov    %ecx,(%eax)
  800689:	8b 02                	mov    (%edx),%eax
  80068b:	ba 00 00 00 00       	mov    $0x0,%edx
  800690:	eb 0e                	jmp    8006a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800692:	8b 10                	mov    (%eax),%edx
  800694:	8d 4a 04             	lea    0x4(%edx),%ecx
  800697:	89 08                	mov    %ecx,(%eax)
  800699:	8b 02                	mov    (%edx),%eax
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
  8006a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8006b1:	73 0a                	jae    8006bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8006b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b6:	88 0a                	mov    %cl,(%edx)
  8006b8:	83 c2 01             	add    $0x1,%edx
  8006bb:	89 10                	mov    %edx,(%eax)
}
  8006bd:	5d                   	pop    %ebp
  8006be:	c3                   	ret    

008006bf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	57                   	push   %edi
  8006c3:	56                   	push   %esi
  8006c4:	53                   	push   %ebx
  8006c5:	83 ec 4c             	sub    $0x4c,%esp
  8006c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006d1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8006d8:	eb 11                	jmp    8006eb <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	0f 84 b0 03 00 00    	je     800a92 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  8006e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e6:	89 04 24             	mov    %eax,(%esp)
  8006e9:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006eb:	0f b6 03             	movzbl (%ebx),%eax
  8006ee:	83 c3 01             	add    $0x1,%ebx
  8006f1:	83 f8 25             	cmp    $0x25,%eax
  8006f4:	75 e4                	jne    8006da <vprintfmt+0x1b>
  8006f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800702:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800706:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80070d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800714:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800717:	eb 06                	jmp    80071f <vprintfmt+0x60>
  800719:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80071d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	0f b6 0b             	movzbl (%ebx),%ecx
  800722:	0f b6 c1             	movzbl %cl,%eax
  800725:	8d 53 01             	lea    0x1(%ebx),%edx
  800728:	83 e9 23             	sub    $0x23,%ecx
  80072b:	80 f9 55             	cmp    $0x55,%cl
  80072e:	0f 87 41 03 00 00    	ja     800a75 <vprintfmt+0x3b6>
  800734:	0f b6 c9             	movzbl %cl,%ecx
  800737:	ff 24 8d e0 12 80 00 	jmp    *0x8012e0(,%ecx,4)
  80073e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800742:	eb d9                	jmp    80071d <vprintfmt+0x5e>
  800744:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80074b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800750:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800753:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800757:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80075a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80075d:	83 fb 09             	cmp    $0x9,%ebx
  800760:	77 2b                	ja     80078d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800762:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800765:	eb e9                	jmp    800750 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800767:	8b 45 14             	mov    0x14(%ebp),%eax
  80076a:	8d 48 04             	lea    0x4(%eax),%ecx
  80076d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800770:	8b 00                	mov    (%eax),%eax
  800772:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800775:	eb 19                	jmp    800790 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80077a:	c1 f8 1f             	sar    $0x1f,%eax
  80077d:	f7 d0                	not    %eax
  80077f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800782:	eb 99                	jmp    80071d <vprintfmt+0x5e>
  800784:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80078b:	eb 90                	jmp    80071d <vprintfmt+0x5e>
  80078d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800790:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800794:	79 87                	jns    80071d <vprintfmt+0x5e>
  800796:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800799:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80079c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80079f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007a2:	e9 76 ff ff ff       	jmp    80071d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007a7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007ab:	e9 6d ff ff ff       	jmp    80071d <vprintfmt+0x5e>
  8007b0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8d 50 04             	lea    0x4(%eax),%edx
  8007b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c0:	8b 00                	mov    (%eax),%eax
  8007c2:	89 04 24             	mov    %eax,(%esp)
  8007c5:	ff d7                	call   *%edi
  8007c7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007ca:	e9 1c ff ff ff       	jmp    8006eb <vprintfmt+0x2c>
  8007cf:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8d 50 04             	lea    0x4(%eax),%edx
  8007d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007db:	8b 00                	mov    (%eax),%eax
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	c1 fa 1f             	sar    $0x1f,%edx
  8007e2:	31 d0                	xor    %edx,%eax
  8007e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007e6:	83 f8 09             	cmp    $0x9,%eax
  8007e9:	7f 0b                	jg     8007f6 <vprintfmt+0x137>
  8007eb:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  8007f2:	85 d2                	test   %edx,%edx
  8007f4:	75 20                	jne    800816 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  8007f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fa:	c7 44 24 08 25 12 80 	movl   $0x801225,0x8(%esp)
  800801:	00 
  800802:	89 74 24 04          	mov    %esi,0x4(%esp)
  800806:	89 3c 24             	mov    %edi,(%esp)
  800809:	e8 0c 03 00 00       	call   800b1a <printfmt>
  80080e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800811:	e9 d5 fe ff ff       	jmp    8006eb <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800816:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80081a:	c7 44 24 08 2e 12 80 	movl   $0x80122e,0x8(%esp)
  800821:	00 
  800822:	89 74 24 04          	mov    %esi,0x4(%esp)
  800826:	89 3c 24             	mov    %edi,(%esp)
  800829:	e8 ec 02 00 00       	call   800b1a <printfmt>
  80082e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800831:	e9 b5 fe ff ff       	jmp    8006eb <vprintfmt+0x2c>
  800836:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800839:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80083c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80083f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8d 50 04             	lea    0x4(%eax),%edx
  800848:	89 55 14             	mov    %edx,0x14(%ebp)
  80084b:	8b 18                	mov    (%eax),%ebx
  80084d:	85 db                	test   %ebx,%ebx
  80084f:	75 05                	jne    800856 <vprintfmt+0x197>
  800851:	bb 31 12 80 00       	mov    $0x801231,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800856:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80085a:	7e 76                	jle    8008d2 <vprintfmt+0x213>
  80085c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800860:	74 7a                	je     8008dc <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800862:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800866:	89 1c 24             	mov    %ebx,(%esp)
  800869:	e8 fa 02 00 00       	call   800b68 <strnlen>
  80086e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800871:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800873:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800877:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80087a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80087d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80087f:	eb 0f                	jmp    800890 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800881:	89 74 24 04          	mov    %esi,0x4(%esp)
  800885:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800888:	89 04 24             	mov    %eax,(%esp)
  80088b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80088d:	83 eb 01             	sub    $0x1,%ebx
  800890:	85 db                	test   %ebx,%ebx
  800892:	7f ed                	jg     800881 <vprintfmt+0x1c2>
  800894:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800897:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80089a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80089d:	89 f7                	mov    %esi,%edi
  80089f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008a2:	eb 40                	jmp    8008e4 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008a8:	74 18                	je     8008c2 <vprintfmt+0x203>
  8008aa:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008ad:	83 fa 5e             	cmp    $0x5e,%edx
  8008b0:	76 10                	jbe    8008c2 <vprintfmt+0x203>
					putch('?', putdat);
  8008b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008bd:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008c0:	eb 0a                	jmp    8008cc <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8008c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008c6:	89 04 24             	mov    %eax,(%esp)
  8008c9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008cc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008d0:	eb 12                	jmp    8008e4 <vprintfmt+0x225>
  8008d2:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008d5:	89 f7                	mov    %esi,%edi
  8008d7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008da:	eb 08                	jmp    8008e4 <vprintfmt+0x225>
  8008dc:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008df:	89 f7                	mov    %esi,%edi
  8008e1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008e4:	0f be 03             	movsbl (%ebx),%eax
  8008e7:	83 c3 01             	add    $0x1,%ebx
  8008ea:	85 c0                	test   %eax,%eax
  8008ec:	74 25                	je     800913 <vprintfmt+0x254>
  8008ee:	85 f6                	test   %esi,%esi
  8008f0:	78 b2                	js     8008a4 <vprintfmt+0x1e5>
  8008f2:	83 ee 01             	sub    $0x1,%esi
  8008f5:	79 ad                	jns    8008a4 <vprintfmt+0x1e5>
  8008f7:	89 fe                	mov    %edi,%esi
  8008f9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8008fc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008ff:	eb 1a                	jmp    80091b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800901:	89 74 24 04          	mov    %esi,0x4(%esp)
  800905:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80090c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80090e:	83 eb 01             	sub    $0x1,%ebx
  800911:	eb 08                	jmp    80091b <vprintfmt+0x25c>
  800913:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800916:	89 fe                	mov    %edi,%esi
  800918:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80091b:	85 db                	test   %ebx,%ebx
  80091d:	7f e2                	jg     800901 <vprintfmt+0x242>
  80091f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800922:	e9 c4 fd ff ff       	jmp    8006eb <vprintfmt+0x2c>
  800927:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80092a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80092d:	83 f9 01             	cmp    $0x1,%ecx
  800930:	7e 16                	jle    800948 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	8d 50 08             	lea    0x8(%eax),%edx
  800938:	89 55 14             	mov    %edx,0x14(%ebp)
  80093b:	8b 10                	mov    (%eax),%edx
  80093d:	8b 48 04             	mov    0x4(%eax),%ecx
  800940:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800943:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800946:	eb 32                	jmp    80097a <vprintfmt+0x2bb>
	else if (lflag)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	74 18                	je     800964 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80094c:	8b 45 14             	mov    0x14(%ebp),%eax
  80094f:	8d 50 04             	lea    0x4(%eax),%edx
  800952:	89 55 14             	mov    %edx,0x14(%ebp)
  800955:	8b 00                	mov    (%eax),%eax
  800957:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80095a:	89 c1                	mov    %eax,%ecx
  80095c:	c1 f9 1f             	sar    $0x1f,%ecx
  80095f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800962:	eb 16                	jmp    80097a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800964:	8b 45 14             	mov    0x14(%ebp),%eax
  800967:	8d 50 04             	lea    0x4(%eax),%edx
  80096a:	89 55 14             	mov    %edx,0x14(%ebp)
  80096d:	8b 00                	mov    (%eax),%eax
  80096f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800972:	89 c2                	mov    %eax,%edx
  800974:	c1 fa 1f             	sar    $0x1f,%edx
  800977:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80097a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80097d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800980:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800985:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800989:	0f 89 a7 00 00 00    	jns    800a36 <vprintfmt+0x377>
				putch('-', putdat);
  80098f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800993:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80099a:	ff d7                	call   *%edi
				num = -(long long) num;
  80099c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80099f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009a2:	f7 d9                	neg    %ecx
  8009a4:	83 d3 00             	adc    $0x0,%ebx
  8009a7:	f7 db                	neg    %ebx
  8009a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009ae:	e9 83 00 00 00       	jmp    800a36 <vprintfmt+0x377>
  8009b3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009b6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009b9:	89 ca                	mov    %ecx,%edx
  8009bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009be:	e8 a5 fc ff ff       	call   800668 <getuint>
  8009c3:	89 c1                	mov    %eax,%ecx
  8009c5:	89 d3                	mov    %edx,%ebx
  8009c7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8009cc:	eb 68                	jmp    800a36 <vprintfmt+0x377>
  8009ce:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009d1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009d4:	89 ca                	mov    %ecx,%edx
  8009d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d9:	e8 8a fc ff ff       	call   800668 <getuint>
  8009de:	89 c1                	mov    %eax,%ecx
  8009e0:	89 d3                	mov    %edx,%ebx
  8009e2:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8009e7:	eb 4d                	jmp    800a36 <vprintfmt+0x377>
  8009e9:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8009ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009f7:	ff d7                	call   *%edi
			putch('x', putdat);
  8009f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a04:	ff d7                	call   *%edi
			num = (unsigned long long)
  800a06:	8b 45 14             	mov    0x14(%ebp),%eax
  800a09:	8d 50 04             	lea    0x4(%eax),%edx
  800a0c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a0f:	8b 08                	mov    (%eax),%ecx
  800a11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a16:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a1b:	eb 19                	jmp    800a36 <vprintfmt+0x377>
  800a1d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800a20:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a23:	89 ca                	mov    %ecx,%edx
  800a25:	8d 45 14             	lea    0x14(%ebp),%eax
  800a28:	e8 3b fc ff ff       	call   800668 <getuint>
  800a2d:	89 c1                	mov    %eax,%ecx
  800a2f:	89 d3                	mov    %edx,%ebx
  800a31:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a36:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  800a3a:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a3e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a41:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a49:	89 0c 24             	mov    %ecx,(%esp)
  800a4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a50:	89 f2                	mov    %esi,%edx
  800a52:	89 f8                	mov    %edi,%eax
  800a54:	e8 27 fb ff ff       	call   800580 <printnum>
  800a59:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a5c:	e9 8a fc ff ff       	jmp    8006eb <vprintfmt+0x2c>
  800a61:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a68:	89 04 24             	mov    %eax,(%esp)
  800a6b:	ff d7                	call   *%edi
  800a6d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a70:	e9 76 fc ff ff       	jmp    8006eb <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a75:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a79:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a80:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a82:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800a85:	80 38 25             	cmpb   $0x25,(%eax)
  800a88:	0f 84 5d fc ff ff    	je     8006eb <vprintfmt+0x2c>
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	eb f0                	jmp    800a82 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800a92:	83 c4 4c             	add    $0x4c,%esp
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5f                   	pop    %edi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	83 ec 28             	sub    $0x28,%esp
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800aa6:	85 c0                	test   %eax,%eax
  800aa8:	74 04                	je     800aae <vsnprintf+0x14>
  800aaa:	85 d2                	test   %edx,%edx
  800aac:	7f 07                	jg     800ab5 <vsnprintf+0x1b>
  800aae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ab3:	eb 3b                	jmp    800af0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ab5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ab8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800abc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800abf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ac6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800acd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800adb:	c7 04 24 a2 06 80 00 	movl   $0x8006a2,(%esp)
  800ae2:	e8 d8 fb ff ff       	call   8006bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ae7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800aea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800af8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800afb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aff:	8b 45 10             	mov    0x10(%ebp),%eax
  800b02:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b06:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	89 04 24             	mov    %eax,(%esp)
  800b13:	e8 82 ff ff ff       	call   800a9a <vsnprintf>
	va_end(ap);

	return rc;
}
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b20:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b27:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	89 04 24             	mov    %eax,(%esp)
  800b3b:	e8 7f fb ff ff       	call   8006bf <vprintfmt>
	va_end(ap);
}
  800b40:	c9                   	leave  
  800b41:	c3                   	ret    
	...

00800b50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  800b5b:	eb 03                	jmp    800b60 <strlen+0x10>
		n++;
  800b5d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b60:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b64:	75 f7                	jne    800b5d <strlen+0xd>
		n++;
	return n;
}
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    

00800b68 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b68:	55                   	push   %ebp
  800b69:	89 e5                	mov    %esp,%ebp
  800b6b:	53                   	push   %ebx
  800b6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b77:	eb 03                	jmp    800b7c <strnlen+0x14>
		n++;
  800b79:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b7c:	39 c1                	cmp    %eax,%ecx
  800b7e:	74 06                	je     800b86 <strnlen+0x1e>
  800b80:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b84:	75 f3                	jne    800b79 <strnlen+0x11>
		n++;
	return n;
}
  800b86:	5b                   	pop    %ebx
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	53                   	push   %ebx
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b98:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b9c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b9f:	83 c2 01             	add    $0x1,%edx
  800ba2:	84 c9                	test   %cl,%cl
  800ba4:	75 f2                	jne    800b98 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	53                   	push   %ebx
  800bad:	83 ec 08             	sub    $0x8,%esp
  800bb0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bb3:	89 1c 24             	mov    %ebx,(%esp)
  800bb6:	e8 95 ff ff ff       	call   800b50 <strlen>
	strcpy(dst + len, src);
  800bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bc5:	89 04 24             	mov    %eax,(%esp)
  800bc8:	e8 bc ff ff ff       	call   800b89 <strcpy>
	return dst;
}
  800bcd:	89 d8                	mov    %ebx,%eax
  800bcf:	83 c4 08             	add    $0x8,%esp
  800bd2:	5b                   	pop    %ebx
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be0:	8b 75 10             	mov    0x10(%ebp),%esi
  800be3:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be8:	eb 0f                	jmp    800bf9 <strncpy+0x24>
		*dst++ = *src;
  800bea:	0f b6 19             	movzbl (%ecx),%ebx
  800bed:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800bf0:	80 39 01             	cmpb   $0x1,(%ecx)
  800bf3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bf6:	83 c2 01             	add    $0x1,%edx
  800bf9:	39 f2                	cmp    %esi,%edx
  800bfb:	72 ed                	jb     800bea <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	8b 75 08             	mov    0x8(%ebp),%esi
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c0f:	89 f0                	mov    %esi,%eax
  800c11:	85 d2                	test   %edx,%edx
  800c13:	75 0a                	jne    800c1f <strlcpy+0x1e>
  800c15:	eb 17                	jmp    800c2e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c17:	88 18                	mov    %bl,(%eax)
  800c19:	83 c0 01             	add    $0x1,%eax
  800c1c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c1f:	83 ea 01             	sub    $0x1,%edx
  800c22:	74 07                	je     800c2b <strlcpy+0x2a>
  800c24:	0f b6 19             	movzbl (%ecx),%ebx
  800c27:	84 db                	test   %bl,%bl
  800c29:	75 ec                	jne    800c17 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  800c2b:	c6 00 00             	movb   $0x0,(%eax)
  800c2e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c3d:	eb 06                	jmp    800c45 <strcmp+0x11>
		p++, q++;
  800c3f:	83 c1 01             	add    $0x1,%ecx
  800c42:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c45:	0f b6 01             	movzbl (%ecx),%eax
  800c48:	84 c0                	test   %al,%al
  800c4a:	74 04                	je     800c50 <strcmp+0x1c>
  800c4c:	3a 02                	cmp    (%edx),%al
  800c4e:	74 ef                	je     800c3f <strcmp+0xb>
  800c50:	0f b6 c0             	movzbl %al,%eax
  800c53:	0f b6 12             	movzbl (%edx),%edx
  800c56:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	53                   	push   %ebx
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c67:	eb 09                	jmp    800c72 <strncmp+0x18>
		n--, p++, q++;
  800c69:	83 ea 01             	sub    $0x1,%edx
  800c6c:	83 c0 01             	add    $0x1,%eax
  800c6f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c72:	85 d2                	test   %edx,%edx
  800c74:	75 07                	jne    800c7d <strncmp+0x23>
  800c76:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7b:	eb 13                	jmp    800c90 <strncmp+0x36>
  800c7d:	0f b6 18             	movzbl (%eax),%ebx
  800c80:	84 db                	test   %bl,%bl
  800c82:	74 04                	je     800c88 <strncmp+0x2e>
  800c84:	3a 19                	cmp    (%ecx),%bl
  800c86:	74 e1                	je     800c69 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c88:	0f b6 00             	movzbl (%eax),%eax
  800c8b:	0f b6 11             	movzbl (%ecx),%edx
  800c8e:	29 d0                	sub    %edx,%eax
}
  800c90:	5b                   	pop    %ebx
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	8b 45 08             	mov    0x8(%ebp),%eax
  800c99:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c9d:	eb 07                	jmp    800ca6 <strchr+0x13>
		if (*s == c)
  800c9f:	38 ca                	cmp    %cl,%dl
  800ca1:	74 0f                	je     800cb2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ca3:	83 c0 01             	add    $0x1,%eax
  800ca6:	0f b6 10             	movzbl (%eax),%edx
  800ca9:	84 d2                	test   %dl,%dl
  800cab:	75 f2                	jne    800c9f <strchr+0xc>
  800cad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cbe:	eb 07                	jmp    800cc7 <strfind+0x13>
		if (*s == c)
  800cc0:	38 ca                	cmp    %cl,%dl
  800cc2:	74 0a                	je     800cce <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cc4:	83 c0 01             	add    $0x1,%eax
  800cc7:	0f b6 10             	movzbl (%eax),%edx
  800cca:	84 d2                	test   %dl,%dl
  800ccc:	75 f2                	jne    800cc0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800cce:	5d                   	pop    %ebp
  800ccf:	90                   	nop
  800cd0:	c3                   	ret    

00800cd1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	83 ec 0c             	sub    $0xc,%esp
  800cd7:	89 1c 24             	mov    %ebx,(%esp)
  800cda:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cde:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ce2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ceb:	85 c9                	test   %ecx,%ecx
  800ced:	74 30                	je     800d1f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cf5:	75 25                	jne    800d1c <memset+0x4b>
  800cf7:	f6 c1 03             	test   $0x3,%cl
  800cfa:	75 20                	jne    800d1c <memset+0x4b>
		c &= 0xFF;
  800cfc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cff:	89 d3                	mov    %edx,%ebx
  800d01:	c1 e3 08             	shl    $0x8,%ebx
  800d04:	89 d6                	mov    %edx,%esi
  800d06:	c1 e6 18             	shl    $0x18,%esi
  800d09:	89 d0                	mov    %edx,%eax
  800d0b:	c1 e0 10             	shl    $0x10,%eax
  800d0e:	09 f0                	or     %esi,%eax
  800d10:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d12:	09 d8                	or     %ebx,%eax
  800d14:	c1 e9 02             	shr    $0x2,%ecx
  800d17:	fc                   	cld    
  800d18:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d1a:	eb 03                	jmp    800d1f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d1c:	fc                   	cld    
  800d1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d1f:	89 f8                	mov    %edi,%eax
  800d21:	8b 1c 24             	mov    (%esp),%ebx
  800d24:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d28:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d2c:	89 ec                	mov    %ebp,%esp
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 08             	sub    $0x8,%esp
  800d36:	89 34 24             	mov    %esi,(%esp)
  800d39:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800d43:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d46:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d48:	39 c6                	cmp    %eax,%esi
  800d4a:	73 35                	jae    800d81 <memmove+0x51>
  800d4c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d4f:	39 d0                	cmp    %edx,%eax
  800d51:	73 2e                	jae    800d81 <memmove+0x51>
		s += n;
		d += n;
  800d53:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d55:	f6 c2 03             	test   $0x3,%dl
  800d58:	75 1b                	jne    800d75 <memmove+0x45>
  800d5a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d60:	75 13                	jne    800d75 <memmove+0x45>
  800d62:	f6 c1 03             	test   $0x3,%cl
  800d65:	75 0e                	jne    800d75 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d67:	83 ef 04             	sub    $0x4,%edi
  800d6a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d6d:	c1 e9 02             	shr    $0x2,%ecx
  800d70:	fd                   	std    
  800d71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d73:	eb 09                	jmp    800d7e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d75:	83 ef 01             	sub    $0x1,%edi
  800d78:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d7b:	fd                   	std    
  800d7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d7e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d7f:	eb 20                	jmp    800da1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d81:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d87:	75 15                	jne    800d9e <memmove+0x6e>
  800d89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d8f:	75 0d                	jne    800d9e <memmove+0x6e>
  800d91:	f6 c1 03             	test   $0x3,%cl
  800d94:	75 08                	jne    800d9e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d96:	c1 e9 02             	shr    $0x2,%ecx
  800d99:	fc                   	cld    
  800d9a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d9c:	eb 03                	jmp    800da1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d9e:	fc                   	cld    
  800d9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800da1:	8b 34 24             	mov    (%esp),%esi
  800da4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800da8:	89 ec                	mov    %ebp,%esp
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800db2:	8b 45 10             	mov    0x10(%ebp),%eax
  800db5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc3:	89 04 24             	mov    %eax,(%esp)
  800dc6:	e8 65 ff ff ff       	call   800d30 <memmove>
}
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    

00800dcd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dd6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dd9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ddc:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800de1:	eb 1c                	jmp    800dff <memcmp+0x32>
		if (*s1 != *s2)
  800de3:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800de7:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800deb:	83 c2 01             	add    $0x1,%edx
  800dee:	83 e9 01             	sub    $0x1,%ecx
  800df1:	38 d8                	cmp    %bl,%al
  800df3:	74 0a                	je     800dff <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800df5:	0f b6 c0             	movzbl %al,%eax
  800df8:	0f b6 db             	movzbl %bl,%ebx
  800dfb:	29 d8                	sub    %ebx,%eax
  800dfd:	eb 09                	jmp    800e08 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dff:	85 c9                	test   %ecx,%ecx
  800e01:	75 e0                	jne    800de3 <memcmp+0x16>
  800e03:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e16:	89 c2                	mov    %eax,%edx
  800e18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e1b:	eb 07                	jmp    800e24 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e1d:	38 08                	cmp    %cl,(%eax)
  800e1f:	74 07                	je     800e28 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e21:	83 c0 01             	add    $0x1,%eax
  800e24:	39 d0                	cmp    %edx,%eax
  800e26:	72 f5                	jb     800e1d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
  800e2e:	56                   	push   %esi
  800e2f:	53                   	push   %ebx
  800e30:	83 ec 04             	sub    $0x4,%esp
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e39:	eb 03                	jmp    800e3e <strtol+0x14>
		s++;
  800e3b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e3e:	0f b6 02             	movzbl (%edx),%eax
  800e41:	3c 20                	cmp    $0x20,%al
  800e43:	74 f6                	je     800e3b <strtol+0x11>
  800e45:	3c 09                	cmp    $0x9,%al
  800e47:	74 f2                	je     800e3b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e49:	3c 2b                	cmp    $0x2b,%al
  800e4b:	75 0c                	jne    800e59 <strtol+0x2f>
		s++;
  800e4d:	8d 52 01             	lea    0x1(%edx),%edx
  800e50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e57:	eb 15                	jmp    800e6e <strtol+0x44>
	else if (*s == '-')
  800e59:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e60:	3c 2d                	cmp    $0x2d,%al
  800e62:	75 0a                	jne    800e6e <strtol+0x44>
		s++, neg = 1;
  800e64:	8d 52 01             	lea    0x1(%edx),%edx
  800e67:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e6e:	85 db                	test   %ebx,%ebx
  800e70:	0f 94 c0             	sete   %al
  800e73:	74 05                	je     800e7a <strtol+0x50>
  800e75:	83 fb 10             	cmp    $0x10,%ebx
  800e78:	75 18                	jne    800e92 <strtol+0x68>
  800e7a:	80 3a 30             	cmpb   $0x30,(%edx)
  800e7d:	75 13                	jne    800e92 <strtol+0x68>
  800e7f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e83:	75 0d                	jne    800e92 <strtol+0x68>
		s += 2, base = 16;
  800e85:	83 c2 02             	add    $0x2,%edx
  800e88:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e8d:	8d 76 00             	lea    0x0(%esi),%esi
  800e90:	eb 13                	jmp    800ea5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e92:	84 c0                	test   %al,%al
  800e94:	74 0f                	je     800ea5 <strtol+0x7b>
  800e96:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e9b:	80 3a 30             	cmpb   $0x30,(%edx)
  800e9e:	75 05                	jne    800ea5 <strtol+0x7b>
		s++, base = 8;
  800ea0:	83 c2 01             	add    $0x1,%edx
  800ea3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eaa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800eac:	0f b6 0a             	movzbl (%edx),%ecx
  800eaf:	89 cf                	mov    %ecx,%edi
  800eb1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800eb4:	80 fb 09             	cmp    $0x9,%bl
  800eb7:	77 08                	ja     800ec1 <strtol+0x97>
			dig = *s - '0';
  800eb9:	0f be c9             	movsbl %cl,%ecx
  800ebc:	83 e9 30             	sub    $0x30,%ecx
  800ebf:	eb 1e                	jmp    800edf <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800ec1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ec4:	80 fb 19             	cmp    $0x19,%bl
  800ec7:	77 08                	ja     800ed1 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800ec9:	0f be c9             	movsbl %cl,%ecx
  800ecc:	83 e9 57             	sub    $0x57,%ecx
  800ecf:	eb 0e                	jmp    800edf <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ed1:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ed4:	80 fb 19             	cmp    $0x19,%bl
  800ed7:	77 15                	ja     800eee <strtol+0xc4>
			dig = *s - 'A' + 10;
  800ed9:	0f be c9             	movsbl %cl,%ecx
  800edc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800edf:	39 f1                	cmp    %esi,%ecx
  800ee1:	7d 0b                	jge    800eee <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800ee3:	83 c2 01             	add    $0x1,%edx
  800ee6:	0f af c6             	imul   %esi,%eax
  800ee9:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800eec:	eb be                	jmp    800eac <strtol+0x82>
  800eee:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ef0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ef4:	74 05                	je     800efb <strtol+0xd1>
		*endptr = (char *) s;
  800ef6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ef9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800efb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800eff:	74 04                	je     800f05 <strtol+0xdb>
  800f01:	89 c8                	mov    %ecx,%eax
  800f03:	f7 d8                	neg    %eax
}
  800f05:	83 c4 04             	add    $0x4,%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    
  800f0d:	00 00                	add    %al,(%eax)
	...

00800f10 <__udivdi3>:
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	83 ec 10             	sub    $0x10,%esp
  800f18:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1e:	8b 75 10             	mov    0x10(%ebp),%esi
  800f21:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f24:	85 c0                	test   %eax,%eax
  800f26:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f29:	75 35                	jne    800f60 <__udivdi3+0x50>
  800f2b:	39 fe                	cmp    %edi,%esi
  800f2d:	77 61                	ja     800f90 <__udivdi3+0x80>
  800f2f:	85 f6                	test   %esi,%esi
  800f31:	75 0b                	jne    800f3e <__udivdi3+0x2e>
  800f33:	b8 01 00 00 00       	mov    $0x1,%eax
  800f38:	31 d2                	xor    %edx,%edx
  800f3a:	f7 f6                	div    %esi
  800f3c:	89 c6                	mov    %eax,%esi
  800f3e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800f41:	31 d2                	xor    %edx,%edx
  800f43:	89 f8                	mov    %edi,%eax
  800f45:	f7 f6                	div    %esi
  800f47:	89 c7                	mov    %eax,%edi
  800f49:	89 c8                	mov    %ecx,%eax
  800f4b:	f7 f6                	div    %esi
  800f4d:	89 c1                	mov    %eax,%ecx
  800f4f:	89 fa                	mov    %edi,%edx
  800f51:	89 c8                	mov    %ecx,%eax
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
  800f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f60:	39 f8                	cmp    %edi,%eax
  800f62:	77 1c                	ja     800f80 <__udivdi3+0x70>
  800f64:	0f bd d0             	bsr    %eax,%edx
  800f67:	83 f2 1f             	xor    $0x1f,%edx
  800f6a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800f6d:	75 39                	jne    800fa8 <__udivdi3+0x98>
  800f6f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800f72:	0f 86 a0 00 00 00    	jbe    801018 <__udivdi3+0x108>
  800f78:	39 f8                	cmp    %edi,%eax
  800f7a:	0f 82 98 00 00 00    	jb     801018 <__udivdi3+0x108>
  800f80:	31 ff                	xor    %edi,%edi
  800f82:	31 c9                	xor    %ecx,%ecx
  800f84:	89 c8                	mov    %ecx,%eax
  800f86:	89 fa                	mov    %edi,%edx
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	5e                   	pop    %esi
  800f8c:	5f                   	pop    %edi
  800f8d:	5d                   	pop    %ebp
  800f8e:	c3                   	ret    
  800f8f:	90                   	nop
  800f90:	89 d1                	mov    %edx,%ecx
  800f92:	89 fa                	mov    %edi,%edx
  800f94:	89 c8                	mov    %ecx,%eax
  800f96:	31 ff                	xor    %edi,%edi
  800f98:	f7 f6                	div    %esi
  800f9a:	89 c1                	mov    %eax,%ecx
  800f9c:	89 fa                	mov    %edi,%edx
  800f9e:	89 c8                	mov    %ecx,%eax
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	5e                   	pop    %esi
  800fa4:	5f                   	pop    %edi
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    
  800fa7:	90                   	nop
  800fa8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fac:	89 f2                	mov    %esi,%edx
  800fae:	d3 e0                	shl    %cl,%eax
  800fb0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fb3:	b8 20 00 00 00       	mov    $0x20,%eax
  800fb8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fbb:	89 c1                	mov    %eax,%ecx
  800fbd:	d3 ea                	shr    %cl,%edx
  800fbf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fc3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800fc6:	d3 e6                	shl    %cl,%esi
  800fc8:	89 c1                	mov    %eax,%ecx
  800fca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800fcd:	89 fe                	mov    %edi,%esi
  800fcf:	d3 ee                	shr    %cl,%esi
  800fd1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fd5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fd8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fdb:	d3 e7                	shl    %cl,%edi
  800fdd:	89 c1                	mov    %eax,%ecx
  800fdf:	d3 ea                	shr    %cl,%edx
  800fe1:	09 d7                	or     %edx,%edi
  800fe3:	89 f2                	mov    %esi,%edx
  800fe5:	89 f8                	mov    %edi,%eax
  800fe7:	f7 75 ec             	divl   -0x14(%ebp)
  800fea:	89 d6                	mov    %edx,%esi
  800fec:	89 c7                	mov    %eax,%edi
  800fee:	f7 65 e8             	mull   -0x18(%ebp)
  800ff1:	39 d6                	cmp    %edx,%esi
  800ff3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ff6:	72 30                	jb     801028 <__udivdi3+0x118>
  800ff8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ffb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fff:	d3 e2                	shl    %cl,%edx
  801001:	39 c2                	cmp    %eax,%edx
  801003:	73 05                	jae    80100a <__udivdi3+0xfa>
  801005:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801008:	74 1e                	je     801028 <__udivdi3+0x118>
  80100a:	89 f9                	mov    %edi,%ecx
  80100c:	31 ff                	xor    %edi,%edi
  80100e:	e9 71 ff ff ff       	jmp    800f84 <__udivdi3+0x74>
  801013:	90                   	nop
  801014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801018:	31 ff                	xor    %edi,%edi
  80101a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80101f:	e9 60 ff ff ff       	jmp    800f84 <__udivdi3+0x74>
  801024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801028:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80102b:	31 ff                	xor    %edi,%edi
  80102d:	89 c8                	mov    %ecx,%eax
  80102f:	89 fa                	mov    %edi,%edx
  801031:	83 c4 10             	add    $0x10,%esp
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    
	...

00801040 <__umoddi3>:
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	83 ec 20             	sub    $0x20,%esp
  801048:	8b 55 14             	mov    0x14(%ebp),%edx
  80104b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801051:	8b 75 0c             	mov    0xc(%ebp),%esi
  801054:	85 d2                	test   %edx,%edx
  801056:	89 c8                	mov    %ecx,%eax
  801058:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80105b:	75 13                	jne    801070 <__umoddi3+0x30>
  80105d:	39 f7                	cmp    %esi,%edi
  80105f:	76 3f                	jbe    8010a0 <__umoddi3+0x60>
  801061:	89 f2                	mov    %esi,%edx
  801063:	f7 f7                	div    %edi
  801065:	89 d0                	mov    %edx,%eax
  801067:	31 d2                	xor    %edx,%edx
  801069:	83 c4 20             	add    $0x20,%esp
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    
  801070:	39 f2                	cmp    %esi,%edx
  801072:	77 4c                	ja     8010c0 <__umoddi3+0x80>
  801074:	0f bd ca             	bsr    %edx,%ecx
  801077:	83 f1 1f             	xor    $0x1f,%ecx
  80107a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80107d:	75 51                	jne    8010d0 <__umoddi3+0x90>
  80107f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801082:	0f 87 e0 00 00 00    	ja     801168 <__umoddi3+0x128>
  801088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108b:	29 f8                	sub    %edi,%eax
  80108d:	19 d6                	sbb    %edx,%esi
  80108f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801092:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801095:	89 f2                	mov    %esi,%edx
  801097:	83 c4 20             	add    $0x20,%esp
  80109a:	5e                   	pop    %esi
  80109b:	5f                   	pop    %edi
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    
  80109e:	66 90                	xchg   %ax,%ax
  8010a0:	85 ff                	test   %edi,%edi
  8010a2:	75 0b                	jne    8010af <__umoddi3+0x6f>
  8010a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a9:	31 d2                	xor    %edx,%edx
  8010ab:	f7 f7                	div    %edi
  8010ad:	89 c7                	mov    %eax,%edi
  8010af:	89 f0                	mov    %esi,%eax
  8010b1:	31 d2                	xor    %edx,%edx
  8010b3:	f7 f7                	div    %edi
  8010b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b8:	f7 f7                	div    %edi
  8010ba:	eb a9                	jmp    801065 <__umoddi3+0x25>
  8010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	89 c8                	mov    %ecx,%eax
  8010c2:	89 f2                	mov    %esi,%edx
  8010c4:	83 c4 20             	add    $0x20,%esp
  8010c7:	5e                   	pop    %esi
  8010c8:	5f                   	pop    %edi
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    
  8010cb:	90                   	nop
  8010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010d4:	d3 e2                	shl    %cl,%edx
  8010d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8010de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8010e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010e8:	89 fa                	mov    %edi,%edx
  8010ea:	d3 ea                	shr    %cl,%edx
  8010ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8010f3:	d3 e7                	shl    %cl,%edi
  8010f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010fc:	89 f2                	mov    %esi,%edx
  8010fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801101:	89 c7                	mov    %eax,%edi
  801103:	d3 ea                	shr    %cl,%edx
  801105:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801109:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80110c:	89 c2                	mov    %eax,%edx
  80110e:	d3 e6                	shl    %cl,%esi
  801110:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801114:	d3 ea                	shr    %cl,%edx
  801116:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80111a:	09 d6                	or     %edx,%esi
  80111c:	89 f0                	mov    %esi,%eax
  80111e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801121:	d3 e7                	shl    %cl,%edi
  801123:	89 f2                	mov    %esi,%edx
  801125:	f7 75 f4             	divl   -0xc(%ebp)
  801128:	89 d6                	mov    %edx,%esi
  80112a:	f7 65 e8             	mull   -0x18(%ebp)
  80112d:	39 d6                	cmp    %edx,%esi
  80112f:	72 2b                	jb     80115c <__umoddi3+0x11c>
  801131:	39 c7                	cmp    %eax,%edi
  801133:	72 23                	jb     801158 <__umoddi3+0x118>
  801135:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801139:	29 c7                	sub    %eax,%edi
  80113b:	19 d6                	sbb    %edx,%esi
  80113d:	89 f0                	mov    %esi,%eax
  80113f:	89 f2                	mov    %esi,%edx
  801141:	d3 ef                	shr    %cl,%edi
  801143:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801147:	d3 e0                	shl    %cl,%eax
  801149:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80114d:	09 f8                	or     %edi,%eax
  80114f:	d3 ea                	shr    %cl,%edx
  801151:	83 c4 20             	add    $0x20,%esp
  801154:	5e                   	pop    %esi
  801155:	5f                   	pop    %edi
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    
  801158:	39 d6                	cmp    %edx,%esi
  80115a:	75 d9                	jne    801135 <__umoddi3+0xf5>
  80115c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80115f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801162:	eb d1                	jmp    801135 <__umoddi3+0xf5>
  801164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801168:	39 f2                	cmp    %esi,%edx
  80116a:	0f 82 18 ff ff ff    	jb     801088 <__umoddi3+0x48>
  801170:	e9 1d ff ff ff       	jmp    801092 <__umoddi3+0x52>
