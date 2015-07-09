
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80004d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800050:	8b 75 08             	mov    0x8(%ebp),%esi
  800053:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  800056:	e8 32 03 00 00       	call   80038d <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x34>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007c:	89 34 24             	mov    %esi,(%esp)
  80007f:	e8 b0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800084:	e8 0b 00 00 00       	call   800094 <exit>
}
  800089:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80008c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008f:	89 ec                	mov    %ebp,%esp
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a1:	e8 1b 03 00 00       	call   8003c1 <sys_env_destroy>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	89 1c 24             	mov    %ebx,(%esp)
  8000b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8000be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c4:	89 c3                	mov    %eax,%ebx
  8000c6:	89 c7                	mov    %eax,%edi
  8000c8:	89 c6                	mov    %eax,%esi
  8000ca:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cc:	8b 1c 24             	mov    (%esp),%ebx
  8000cf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000d3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000d7:	89 ec                	mov    %ebp,%esp
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	83 ec 38             	sub    $0x38,%esp
  8000e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  8000ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000ee:	75 0c                	jne    8000fc <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  8000f0:	c7 04 24 8c 11 80 00 	movl   $0x80118c,(%esp)
  8000f7:	e8 11 04 00 00       	call   80050d <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800101:	b8 09 00 00 00       	mov    $0x9,%eax
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80010c:	89 df                	mov    %ebx,%edi
  80010e:	89 de                	mov    %ebx,%esi
  800110:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7e 28                	jle    80013e <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800116:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011a:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800121:	00 
  800122:	c7 44 24 08 b8 11 80 	movl   $0x8011b8,0x8(%esp)
  800129:	00 
  80012a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800131:	00 
  800132:	c7 04 24 d5 11 80 00 	movl   $0x8011d5,(%esp)
  800139:	e8 16 03 00 00       	call   800454 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80013e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800141:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800144:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800147:	89 ec                	mov    %ebp,%esp
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 38             	sub    $0x38,%esp
  800151:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800154:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800157:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800164:	8b 55 08             	mov    0x8(%ebp),%edx
  800167:	89 cb                	mov    %ecx,%ebx
  800169:	89 cf                	mov    %ecx,%edi
  80016b:	89 ce                	mov    %ecx,%esi
  80016d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016f:	85 c0                	test   %eax,%eax
  800171:	7e 28                	jle    80019b <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800173:	89 44 24 10          	mov    %eax,0x10(%esp)
  800177:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80017e:	00 
  80017f:	c7 44 24 08 b8 11 80 	movl   $0x8011b8,0x8(%esp)
  800186:	00 
  800187:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80018e:	00 
  80018f:	c7 04 24 d5 11 80 00 	movl   $0x8011d5,(%esp)
  800196:	e8 b9 02 00 00       	call   800454 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80019b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80019e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001a1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a4:	89 ec                	mov    %ebp,%esp
  8001a6:	5d                   	pop    %ebp
  8001a7:	c3                   	ret    

008001a8 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	89 1c 24             	mov    %ebx,(%esp)
  8001b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b5:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b9:	be 00 00 00 00       	mov    $0x0,%esi
  8001be:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8001d1:	8b 1c 24             	mov    (%esp),%ebx
  8001d4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001d8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001dc:	89 ec                	mov    %ebp,%esp
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	83 ec 38             	sub    $0x38,%esp
  8001e6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001ec:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f4:	b8 08 00 00 00       	mov    $0x8,%eax
  8001f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ff:	89 df                	mov    %ebx,%edi
  800201:	89 de                	mov    %ebx,%esi
  800203:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800205:	85 c0                	test   %eax,%eax
  800207:	7e 28                	jle    800231 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800209:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800214:	00 
  800215:	c7 44 24 08 b8 11 80 	movl   $0x8011b8,0x8(%esp)
  80021c:	00 
  80021d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800224:	00 
  800225:	c7 04 24 d5 11 80 00 	movl   $0x8011d5,(%esp)
  80022c:	e8 23 02 00 00       	call   800454 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800231:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800234:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800237:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80023a:	89 ec                	mov    %ebp,%esp
  80023c:	5d                   	pop    %ebp
  80023d:	c3                   	ret    

0080023e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	83 ec 38             	sub    $0x38,%esp
  800244:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800247:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80024a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800252:	b8 06 00 00 00       	mov    $0x6,%eax
  800257:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025a:	8b 55 08             	mov    0x8(%ebp),%edx
  80025d:	89 df                	mov    %ebx,%edi
  80025f:	89 de                	mov    %ebx,%esi
  800261:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800263:	85 c0                	test   %eax,%eax
  800265:	7e 28                	jle    80028f <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800267:	89 44 24 10          	mov    %eax,0x10(%esp)
  80026b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800272:	00 
  800273:	c7 44 24 08 b8 11 80 	movl   $0x8011b8,0x8(%esp)
  80027a:	00 
  80027b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800282:	00 
  800283:	c7 04 24 d5 11 80 00 	movl   $0x8011d5,(%esp)
  80028a:	e8 c5 01 00 00       	call   800454 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80028f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800292:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800295:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800298:	89 ec                	mov    %ebp,%esp
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    

0080029c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 38             	sub    $0x38,%esp
  8002a2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002a5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8002b0:	8b 75 18             	mov    0x18(%ebp),%esi
  8002b3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c1:	85 c0                	test   %eax,%eax
  8002c3:	7e 28                	jle    8002ed <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c9:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8002d0:	00 
  8002d1:	c7 44 24 08 b8 11 80 	movl   $0x8011b8,0x8(%esp)
  8002d8:	00 
  8002d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002e0:	00 
  8002e1:	c7 04 24 d5 11 80 00 	movl   $0x8011d5,(%esp)
  8002e8:	e8 67 01 00 00       	call   800454 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8002ed:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002f0:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002f3:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f6:	89 ec                	mov    %ebp,%esp
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    

008002fa <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	83 ec 38             	sub    $0x38,%esp
  800300:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800303:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800306:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800309:	be 00 00 00 00       	mov    $0x0,%esi
  80030e:	b8 04 00 00 00       	mov    $0x4,%eax
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 f7                	mov    %esi,%edi
  80031e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800320:	85 c0                	test   %eax,%eax
  800322:	7e 28                	jle    80034c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800324:	89 44 24 10          	mov    %eax,0x10(%esp)
  800328:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80032f:	00 
  800330:	c7 44 24 08 b8 11 80 	movl   $0x8011b8,0x8(%esp)
  800337:	00 
  800338:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033f:	00 
  800340:	c7 04 24 d5 11 80 00 	movl   $0x8011d5,(%esp)
  800347:	e8 08 01 00 00       	call   800454 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80034c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80034f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800352:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800355:	89 ec                	mov    %ebp,%esp
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	83 ec 0c             	sub    $0xc,%esp
  80035f:	89 1c 24             	mov    %ebx,(%esp)
  800362:	89 74 24 04          	mov    %esi,0x4(%esp)
  800366:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800374:	89 d1                	mov    %edx,%ecx
  800376:	89 d3                	mov    %edx,%ebx
  800378:	89 d7                	mov    %edx,%edi
  80037a:	89 d6                	mov    %edx,%esi
  80037c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80037e:	8b 1c 24             	mov    (%esp),%ebx
  800381:	8b 74 24 04          	mov    0x4(%esp),%esi
  800385:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800389:	89 ec                	mov    %ebp,%esp
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	83 ec 0c             	sub    $0xc,%esp
  800393:	89 1c 24             	mov    %ebx,(%esp)
  800396:	89 74 24 04          	mov    %esi,0x4(%esp)
  80039a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039e:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8003a8:	89 d1                	mov    %edx,%ecx
  8003aa:	89 d3                	mov    %edx,%ebx
  8003ac:	89 d7                	mov    %edx,%edi
  8003ae:	89 d6                	mov    %edx,%esi
  8003b0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8003b2:	8b 1c 24             	mov    (%esp),%ebx
  8003b5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003b9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003bd:	89 ec                	mov    %ebp,%esp
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	83 ec 38             	sub    $0x38,%esp
  8003c7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003ca:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003cd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d5:	b8 03 00 00 00       	mov    $0x3,%eax
  8003da:	8b 55 08             	mov    0x8(%ebp),%edx
  8003dd:	89 cb                	mov    %ecx,%ebx
  8003df:	89 cf                	mov    %ecx,%edi
  8003e1:	89 ce                	mov    %ecx,%esi
  8003e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	7e 28                	jle    800411 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003ed:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8003f4:	00 
  8003f5:	c7 44 24 08 b8 11 80 	movl   $0x8011b8,0x8(%esp)
  8003fc:	00 
  8003fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800404:	00 
  800405:	c7 04 24 d5 11 80 00 	movl   $0x8011d5,(%esp)
  80040c:	e8 43 00 00 00       	call   800454 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800411:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800414:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800417:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80041a:	89 ec                	mov    %ebp,%esp
  80041c:	5d                   	pop    %ebp
  80041d:	c3                   	ret    

0080041e <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	83 ec 0c             	sub    $0xc,%esp
  800424:	89 1c 24             	mov    %ebx,(%esp)
  800427:	89 74 24 04          	mov    %esi,0x4(%esp)
  80042b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80042f:	ba 00 00 00 00       	mov    $0x0,%edx
  800434:	b8 01 00 00 00       	mov    $0x1,%eax
  800439:	89 d1                	mov    %edx,%ecx
  80043b:	89 d3                	mov    %edx,%ebx
  80043d:	89 d7                	mov    %edx,%edi
  80043f:	89 d6                	mov    %edx,%esi
  800441:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800443:	8b 1c 24             	mov    (%esp),%ebx
  800446:	8b 74 24 04          	mov    0x4(%esp),%esi
  80044a:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80044e:	89 ec                	mov    %ebp,%esp
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    
	...

00800454 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	56                   	push   %esi
  800458:	53                   	push   %ebx
  800459:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80045c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800465:	e8 23 ff ff ff       	call   80038d <sys_getenvid>
  80046a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800471:	8b 55 08             	mov    0x8(%ebp),%edx
  800474:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800478:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80047c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800480:	c7 04 24 e4 11 80 00 	movl   $0x8011e4,(%esp)
  800487:	e8 81 00 00 00       	call   80050d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80048c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800490:	8b 45 10             	mov    0x10(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 11 00 00 00       	call   8004ac <vcprintf>
	cprintf("\n");
  80049b:	c7 04 24 08 12 80 00 	movl   $0x801208,(%esp)
  8004a2:	e8 66 00 00 00       	call   80050d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a7:	cc                   	int3   
  8004a8:	eb fd                	jmp    8004a7 <_panic+0x53>
	...

008004ac <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004bc:	00 00 00 
	b.cnt = 0;
  8004bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e1:	c7 04 24 27 05 80 00 	movl   $0x800527,(%esp)
  8004e8:	e8 c2 01 00 00       	call   8006af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004ed:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004fd:	89 04 24             	mov    %eax,(%esp)
  800500:	e8 a3 fb ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  800505:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80050b:	c9                   	leave  
  80050c:	c3                   	ret    

0080050d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800513:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051a:	8b 45 08             	mov    0x8(%ebp),%eax
  80051d:	89 04 24             	mov    %eax,(%esp)
  800520:	e8 87 ff ff ff       	call   8004ac <vcprintf>
	va_end(ap);

	return cnt;
}
  800525:	c9                   	leave  
  800526:	c3                   	ret    

00800527 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	53                   	push   %ebx
  80052b:	83 ec 14             	sub    $0x14,%esp
  80052e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800531:	8b 03                	mov    (%ebx),%eax
  800533:	8b 55 08             	mov    0x8(%ebp),%edx
  800536:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80053a:	83 c0 01             	add    $0x1,%eax
  80053d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80053f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800544:	75 19                	jne    80055f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800546:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80054d:	00 
  80054e:	8d 43 08             	lea    0x8(%ebx),%eax
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	e8 4f fb ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  800559:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80055f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800563:	83 c4 14             	add    $0x14,%esp
  800566:	5b                   	pop    %ebx
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    
  800569:	00 00                	add    %al,(%eax)
  80056b:	00 00                	add    %al,(%eax)
  80056d:	00 00                	add    %al,(%eax)
	...

00800570 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	57                   	push   %edi
  800574:	56                   	push   %esi
  800575:	53                   	push   %ebx
  800576:	83 ec 4c             	sub    $0x4c,%esp
  800579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057c:	89 d6                	mov    %edx,%esi
  80057e:	8b 45 08             	mov    0x8(%ebp),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	8b 55 0c             	mov    0xc(%ebp),%edx
  800587:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058a:	8b 45 10             	mov    0x10(%ebp),%eax
  80058d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800590:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800593:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059b:	39 d1                	cmp    %edx,%ecx
  80059d:	72 07                	jb     8005a6 <printnum+0x36>
  80059f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a2:	39 d0                	cmp    %edx,%eax
  8005a4:	77 69                	ja     80060f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005a6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005aa:	83 eb 01             	sub    $0x1,%ebx
  8005ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8005b9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8005bd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005c0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005c3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005d1:	00 
  8005d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d5:	89 04 24             	mov    %eax,(%esp)
  8005d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005df:	e8 1c 09 00 00       	call   800f00 <__udivdi3>
  8005e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005f2:	89 04 24             	mov    %eax,(%esp)
  8005f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f9:	89 f2                	mov    %esi,%edx
  8005fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005fe:	e8 6d ff ff ff       	call   800570 <printnum>
  800603:	eb 11                	jmp    800616 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800605:	89 74 24 04          	mov    %esi,0x4(%esp)
  800609:	89 3c 24             	mov    %edi,(%esp)
  80060c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80060f:	83 eb 01             	sub    $0x1,%ebx
  800612:	85 db                	test   %ebx,%ebx
  800614:	7f ef                	jg     800605 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800616:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80061e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800621:	89 44 24 08          	mov    %eax,0x8(%esp)
  800625:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80062c:	00 
  80062d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800630:	89 14 24             	mov    %edx,(%esp)
  800633:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800636:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80063a:	e8 f1 09 00 00       	call   801030 <__umoddi3>
  80063f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800643:	0f be 80 0a 12 80 00 	movsbl 0x80120a(%eax),%eax
  80064a:	89 04 24             	mov    %eax,(%esp)
  80064d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800650:	83 c4 4c             	add    $0x4c,%esp
  800653:	5b                   	pop    %ebx
  800654:	5e                   	pop    %esi
  800655:	5f                   	pop    %edi
  800656:	5d                   	pop    %ebp
  800657:	c3                   	ret    

00800658 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800658:	55                   	push   %ebp
  800659:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80065b:	83 fa 01             	cmp    $0x1,%edx
  80065e:	7e 0e                	jle    80066e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800660:	8b 10                	mov    (%eax),%edx
  800662:	8d 4a 08             	lea    0x8(%edx),%ecx
  800665:	89 08                	mov    %ecx,(%eax)
  800667:	8b 02                	mov    (%edx),%eax
  800669:	8b 52 04             	mov    0x4(%edx),%edx
  80066c:	eb 22                	jmp    800690 <getuint+0x38>
	else if (lflag)
  80066e:	85 d2                	test   %edx,%edx
  800670:	74 10                	je     800682 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8d 4a 04             	lea    0x4(%edx),%ecx
  800677:	89 08                	mov    %ecx,(%eax)
  800679:	8b 02                	mov    (%edx),%eax
  80067b:	ba 00 00 00 00       	mov    $0x0,%edx
  800680:	eb 0e                	jmp    800690 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800682:	8b 10                	mov    (%eax),%edx
  800684:	8d 4a 04             	lea    0x4(%edx),%ecx
  800687:	89 08                	mov    %ecx,(%eax)
  800689:	8b 02                	mov    (%edx),%eax
  80068b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800690:	5d                   	pop    %ebp
  800691:	c3                   	ret    

00800692 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800698:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	3b 50 04             	cmp    0x4(%eax),%edx
  8006a1:	73 0a                	jae    8006ad <sprintputch+0x1b>
		*b->buf++ = ch;
  8006a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a6:	88 0a                	mov    %cl,(%edx)
  8006a8:	83 c2 01             	add    $0x1,%edx
  8006ab:	89 10                	mov    %edx,(%eax)
}
  8006ad:	5d                   	pop    %ebp
  8006ae:	c3                   	ret    

008006af <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006af:	55                   	push   %ebp
  8006b0:	89 e5                	mov    %esp,%ebp
  8006b2:	57                   	push   %edi
  8006b3:	56                   	push   %esi
  8006b4:	53                   	push   %ebx
  8006b5:	83 ec 4c             	sub    $0x4c,%esp
  8006b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006be:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006c1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8006c8:	eb 11                	jmp    8006db <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	0f 84 b0 03 00 00    	je     800a82 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  8006d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d6:	89 04 24             	mov    %eax,(%esp)
  8006d9:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006db:	0f b6 03             	movzbl (%ebx),%eax
  8006de:	83 c3 01             	add    $0x1,%ebx
  8006e1:	83 f8 25             	cmp    $0x25,%eax
  8006e4:	75 e4                	jne    8006ca <vprintfmt+0x1b>
  8006e6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8006f6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8006fd:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800704:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800707:	eb 06                	jmp    80070f <vprintfmt+0x60>
  800709:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80070d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070f:	0f b6 0b             	movzbl (%ebx),%ecx
  800712:	0f b6 c1             	movzbl %cl,%eax
  800715:	8d 53 01             	lea    0x1(%ebx),%edx
  800718:	83 e9 23             	sub    $0x23,%ecx
  80071b:	80 f9 55             	cmp    $0x55,%cl
  80071e:	0f 87 41 03 00 00    	ja     800a65 <vprintfmt+0x3b6>
  800724:	0f b6 c9             	movzbl %cl,%ecx
  800727:	ff 24 8d e0 12 80 00 	jmp    *0x8012e0(,%ecx,4)
  80072e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800732:	eb d9                	jmp    80070d <vprintfmt+0x5e>
  800734:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80073b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800740:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800743:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800747:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80074a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80074d:	83 fb 09             	cmp    $0x9,%ebx
  800750:	77 2b                	ja     80077d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800752:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800755:	eb e9                	jmp    800740 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 48 04             	lea    0x4(%eax),%ecx
  80075d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800760:	8b 00                	mov    (%eax),%eax
  800762:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800765:	eb 19                	jmp    800780 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80076a:	c1 f8 1f             	sar    $0x1f,%eax
  80076d:	f7 d0                	not    %eax
  80076f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800772:	eb 99                	jmp    80070d <vprintfmt+0x5e>
  800774:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80077b:	eb 90                	jmp    80070d <vprintfmt+0x5e>
  80077d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800780:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800784:	79 87                	jns    80070d <vprintfmt+0x5e>
  800786:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800789:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80078c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80078f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800792:	e9 76 ff ff ff       	jmp    80070d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800797:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80079b:	e9 6d ff ff ff       	jmp    80070d <vprintfmt+0x5e>
  8007a0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 50 04             	lea    0x4(%eax),%edx
  8007a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b0:	8b 00                	mov    (%eax),%eax
  8007b2:	89 04 24             	mov    %eax,(%esp)
  8007b5:	ff d7                	call   *%edi
  8007b7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007ba:	e9 1c ff ff ff       	jmp    8006db <vprintfmt+0x2c>
  8007bf:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c5:	8d 50 04             	lea    0x4(%eax),%edx
  8007c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	c1 fa 1f             	sar    $0x1f,%edx
  8007d2:	31 d0                	xor    %edx,%eax
  8007d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007d6:	83 f8 09             	cmp    $0x9,%eax
  8007d9:	7f 0b                	jg     8007e6 <vprintfmt+0x137>
  8007db:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  8007e2:	85 d2                	test   %edx,%edx
  8007e4:	75 20                	jne    800806 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  8007e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ea:	c7 44 24 08 1b 12 80 	movl   $0x80121b,0x8(%esp)
  8007f1:	00 
  8007f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f6:	89 3c 24             	mov    %edi,(%esp)
  8007f9:	e8 0c 03 00 00       	call   800b0a <printfmt>
  8007fe:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800801:	e9 d5 fe ff ff       	jmp    8006db <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800806:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80080a:	c7 44 24 08 24 12 80 	movl   $0x801224,0x8(%esp)
  800811:	00 
  800812:	89 74 24 04          	mov    %esi,0x4(%esp)
  800816:	89 3c 24             	mov    %edi,(%esp)
  800819:	e8 ec 02 00 00       	call   800b0a <printfmt>
  80081e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800821:	e9 b5 fe ff ff       	jmp    8006db <vprintfmt+0x2c>
  800826:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800829:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80082c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80082f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8d 50 04             	lea    0x4(%eax),%edx
  800838:	89 55 14             	mov    %edx,0x14(%ebp)
  80083b:	8b 18                	mov    (%eax),%ebx
  80083d:	85 db                	test   %ebx,%ebx
  80083f:	75 05                	jne    800846 <vprintfmt+0x197>
  800841:	bb 27 12 80 00       	mov    $0x801227,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800846:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80084a:	7e 76                	jle    8008c2 <vprintfmt+0x213>
  80084c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800850:	74 7a                	je     8008cc <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800852:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800856:	89 1c 24             	mov    %ebx,(%esp)
  800859:	e8 fa 02 00 00       	call   800b58 <strnlen>
  80085e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800861:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800863:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800867:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80086a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80086d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80086f:	eb 0f                	jmp    800880 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800871:	89 74 24 04          	mov    %esi,0x4(%esp)
  800875:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80087d:	83 eb 01             	sub    $0x1,%ebx
  800880:	85 db                	test   %ebx,%ebx
  800882:	7f ed                	jg     800871 <vprintfmt+0x1c2>
  800884:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800887:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80088a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80088d:	89 f7                	mov    %esi,%edi
  80088f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800892:	eb 40                	jmp    8008d4 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800894:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800898:	74 18                	je     8008b2 <vprintfmt+0x203>
  80089a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80089d:	83 fa 5e             	cmp    $0x5e,%edx
  8008a0:	76 10                	jbe    8008b2 <vprintfmt+0x203>
					putch('?', putdat);
  8008a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008a6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008ad:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008b0:	eb 0a                	jmp    8008bc <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8008b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008bc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008c0:	eb 12                	jmp    8008d4 <vprintfmt+0x225>
  8008c2:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008c5:	89 f7                	mov    %esi,%edi
  8008c7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008ca:	eb 08                	jmp    8008d4 <vprintfmt+0x225>
  8008cc:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008cf:	89 f7                	mov    %esi,%edi
  8008d1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008d4:	0f be 03             	movsbl (%ebx),%eax
  8008d7:	83 c3 01             	add    $0x1,%ebx
  8008da:	85 c0                	test   %eax,%eax
  8008dc:	74 25                	je     800903 <vprintfmt+0x254>
  8008de:	85 f6                	test   %esi,%esi
  8008e0:	78 b2                	js     800894 <vprintfmt+0x1e5>
  8008e2:	83 ee 01             	sub    $0x1,%esi
  8008e5:	79 ad                	jns    800894 <vprintfmt+0x1e5>
  8008e7:	89 fe                	mov    %edi,%esi
  8008e9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8008ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8008ef:	eb 1a                	jmp    80090b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008fc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008fe:	83 eb 01             	sub    $0x1,%ebx
  800901:	eb 08                	jmp    80090b <vprintfmt+0x25c>
  800903:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800906:	89 fe                	mov    %edi,%esi
  800908:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80090b:	85 db                	test   %ebx,%ebx
  80090d:	7f e2                	jg     8008f1 <vprintfmt+0x242>
  80090f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800912:	e9 c4 fd ff ff       	jmp    8006db <vprintfmt+0x2c>
  800917:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80091a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80091d:	83 f9 01             	cmp    $0x1,%ecx
  800920:	7e 16                	jle    800938 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8d 50 08             	lea    0x8(%eax),%edx
  800928:	89 55 14             	mov    %edx,0x14(%ebp)
  80092b:	8b 10                	mov    (%eax),%edx
  80092d:	8b 48 04             	mov    0x4(%eax),%ecx
  800930:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800933:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800936:	eb 32                	jmp    80096a <vprintfmt+0x2bb>
	else if (lflag)
  800938:	85 c9                	test   %ecx,%ecx
  80093a:	74 18                	je     800954 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80093c:	8b 45 14             	mov    0x14(%ebp),%eax
  80093f:	8d 50 04             	lea    0x4(%eax),%edx
  800942:	89 55 14             	mov    %edx,0x14(%ebp)
  800945:	8b 00                	mov    (%eax),%eax
  800947:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80094a:	89 c1                	mov    %eax,%ecx
  80094c:	c1 f9 1f             	sar    $0x1f,%ecx
  80094f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800952:	eb 16                	jmp    80096a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800954:	8b 45 14             	mov    0x14(%ebp),%eax
  800957:	8d 50 04             	lea    0x4(%eax),%edx
  80095a:	89 55 14             	mov    %edx,0x14(%ebp)
  80095d:	8b 00                	mov    (%eax),%eax
  80095f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800962:	89 c2                	mov    %eax,%edx
  800964:	c1 fa 1f             	sar    $0x1f,%edx
  800967:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80096a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80096d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800970:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800975:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800979:	0f 89 a7 00 00 00    	jns    800a26 <vprintfmt+0x377>
				putch('-', putdat);
  80097f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800983:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80098a:	ff d7                	call   *%edi
				num = -(long long) num;
  80098c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80098f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800992:	f7 d9                	neg    %ecx
  800994:	83 d3 00             	adc    $0x0,%ebx
  800997:	f7 db                	neg    %ebx
  800999:	b8 0a 00 00 00       	mov    $0xa,%eax
  80099e:	e9 83 00 00 00       	jmp    800a26 <vprintfmt+0x377>
  8009a3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009a6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a9:	89 ca                	mov    %ecx,%edx
  8009ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ae:	e8 a5 fc ff ff       	call   800658 <getuint>
  8009b3:	89 c1                	mov    %eax,%ecx
  8009b5:	89 d3                	mov    %edx,%ebx
  8009b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8009bc:	eb 68                	jmp    800a26 <vprintfmt+0x377>
  8009be:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009c1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009c4:	89 ca                	mov    %ecx,%edx
  8009c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c9:	e8 8a fc ff ff       	call   800658 <getuint>
  8009ce:	89 c1                	mov    %eax,%ecx
  8009d0:	89 d3                	mov    %edx,%ebx
  8009d2:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8009d7:	eb 4d                	jmp    800a26 <vprintfmt+0x377>
  8009d9:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8009dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009e7:	ff d7                	call   *%edi
			putch('x', putdat);
  8009e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ed:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009f4:	ff d7                	call   *%edi
			num = (unsigned long long)
  8009f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f9:	8d 50 04             	lea    0x4(%eax),%edx
  8009fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ff:	8b 08                	mov    (%eax),%ecx
  800a01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a06:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a0b:	eb 19                	jmp    800a26 <vprintfmt+0x377>
  800a0d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800a10:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a13:	89 ca                	mov    %ecx,%edx
  800a15:	8d 45 14             	lea    0x14(%ebp),%eax
  800a18:	e8 3b fc ff ff       	call   800658 <getuint>
  800a1d:	89 c1                	mov    %eax,%ecx
  800a1f:	89 d3                	mov    %edx,%ebx
  800a21:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a26:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  800a2a:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a31:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a39:	89 0c 24             	mov    %ecx,(%esp)
  800a3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a40:	89 f2                	mov    %esi,%edx
  800a42:	89 f8                	mov    %edi,%eax
  800a44:	e8 27 fb ff ff       	call   800570 <printnum>
  800a49:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a4c:	e9 8a fc ff ff       	jmp    8006db <vprintfmt+0x2c>
  800a51:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a58:	89 04 24             	mov    %eax,(%esp)
  800a5b:	ff d7                	call   *%edi
  800a5d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a60:	e9 76 fc ff ff       	jmp    8006db <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a65:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a69:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800a70:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a72:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800a75:	80 38 25             	cmpb   $0x25,(%eax)
  800a78:	0f 84 5d fc ff ff    	je     8006db <vprintfmt+0x2c>
  800a7e:	89 c3                	mov    %eax,%ebx
  800a80:	eb f0                	jmp    800a72 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800a82:	83 c4 4c             	add    $0x4c,%esp
  800a85:	5b                   	pop    %ebx
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	83 ec 28             	sub    $0x28,%esp
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a96:	85 c0                	test   %eax,%eax
  800a98:	74 04                	je     800a9e <vsnprintf+0x14>
  800a9a:	85 d2                	test   %edx,%edx
  800a9c:	7f 07                	jg     800aa5 <vsnprintf+0x1b>
  800a9e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800aa3:	eb 3b                	jmp    800ae0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800aa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800aa8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800aac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aaf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ab6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800abd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acb:	c7 04 24 92 06 80 00 	movl   $0x800692,(%esp)
  800ad2:	e8 d8 fb ff ff       	call   8006af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ad7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ada:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800add:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800ae8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800aeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aef:	8b 45 10             	mov    0x10(%ebp),%eax
  800af2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	89 04 24             	mov    %eax,(%esp)
  800b03:	e8 82 ff ff ff       	call   800a8a <vsnprintf>
	va_end(ap);

	return rc;
}
  800b08:	c9                   	leave  
  800b09:	c3                   	ret    

00800b0a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b10:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b13:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b17:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	89 04 24             	mov    %eax,(%esp)
  800b2b:	e8 7f fb ff ff       	call   8006af <vprintfmt>
	va_end(ap);
}
  800b30:	c9                   	leave  
  800b31:	c3                   	ret    
	...

00800b40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  800b4b:	eb 03                	jmp    800b50 <strlen+0x10>
		n++;
  800b4d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b50:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b54:	75 f7                	jne    800b4d <strlen+0xd>
		n++;
	return n;
}
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	53                   	push   %ebx
  800b5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b67:	eb 03                	jmp    800b6c <strnlen+0x14>
		n++;
  800b69:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b6c:	39 c1                	cmp    %eax,%ecx
  800b6e:	74 06                	je     800b76 <strnlen+0x1e>
  800b70:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800b74:	75 f3                	jne    800b69 <strnlen+0x11>
		n++;
	return n;
}
  800b76:	5b                   	pop    %ebx
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	53                   	push   %ebx
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b88:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b8c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b8f:	83 c2 01             	add    $0x1,%edx
  800b92:	84 c9                	test   %cl,%cl
  800b94:	75 f2                	jne    800b88 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b96:	5b                   	pop    %ebx
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	53                   	push   %ebx
  800b9d:	83 ec 08             	sub    $0x8,%esp
  800ba0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ba3:	89 1c 24             	mov    %ebx,(%esp)
  800ba6:	e8 95 ff ff ff       	call   800b40 <strlen>
	strcpy(dst + len, src);
  800bab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bae:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bb2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bb5:	89 04 24             	mov    %eax,(%esp)
  800bb8:	e8 bc ff ff ff       	call   800b79 <strcpy>
	return dst;
}
  800bbd:	89 d8                	mov    %ebx,%eax
  800bbf:	83 c4 08             	add    $0x8,%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd0:	8b 75 10             	mov    0x10(%ebp),%esi
  800bd3:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd8:	eb 0f                	jmp    800be9 <strncpy+0x24>
		*dst++ = *src;
  800bda:	0f b6 19             	movzbl (%ecx),%ebx
  800bdd:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800be0:	80 39 01             	cmpb   $0x1,(%ecx)
  800be3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800be6:	83 c2 01             	add    $0x1,%edx
  800be9:	39 f2                	cmp    %esi,%edx
  800beb:	72 ed                	jb     800bda <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	56                   	push   %esi
  800bf5:	53                   	push   %ebx
  800bf6:	8b 75 08             	mov    0x8(%ebp),%esi
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfc:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800bff:	89 f0                	mov    %esi,%eax
  800c01:	85 d2                	test   %edx,%edx
  800c03:	75 0a                	jne    800c0f <strlcpy+0x1e>
  800c05:	eb 17                	jmp    800c1e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c07:	88 18                	mov    %bl,(%eax)
  800c09:	83 c0 01             	add    $0x1,%eax
  800c0c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c0f:	83 ea 01             	sub    $0x1,%edx
  800c12:	74 07                	je     800c1b <strlcpy+0x2a>
  800c14:	0f b6 19             	movzbl (%ecx),%ebx
  800c17:	84 db                	test   %bl,%bl
  800c19:	75 ec                	jne    800c07 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  800c1b:	c6 00 00             	movb   $0x0,(%eax)
  800c1e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c2d:	eb 06                	jmp    800c35 <strcmp+0x11>
		p++, q++;
  800c2f:	83 c1 01             	add    $0x1,%ecx
  800c32:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c35:	0f b6 01             	movzbl (%ecx),%eax
  800c38:	84 c0                	test   %al,%al
  800c3a:	74 04                	je     800c40 <strcmp+0x1c>
  800c3c:	3a 02                	cmp    (%edx),%al
  800c3e:	74 ef                	je     800c2f <strcmp+0xb>
  800c40:	0f b6 c0             	movzbl %al,%eax
  800c43:	0f b6 12             	movzbl (%edx),%edx
  800c46:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	53                   	push   %ebx
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c57:	eb 09                	jmp    800c62 <strncmp+0x18>
		n--, p++, q++;
  800c59:	83 ea 01             	sub    $0x1,%edx
  800c5c:	83 c0 01             	add    $0x1,%eax
  800c5f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c62:	85 d2                	test   %edx,%edx
  800c64:	75 07                	jne    800c6d <strncmp+0x23>
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6b:	eb 13                	jmp    800c80 <strncmp+0x36>
  800c6d:	0f b6 18             	movzbl (%eax),%ebx
  800c70:	84 db                	test   %bl,%bl
  800c72:	74 04                	je     800c78 <strncmp+0x2e>
  800c74:	3a 19                	cmp    (%ecx),%bl
  800c76:	74 e1                	je     800c59 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c78:	0f b6 00             	movzbl (%eax),%eax
  800c7b:	0f b6 11             	movzbl (%ecx),%edx
  800c7e:	29 d0                	sub    %edx,%eax
}
  800c80:	5b                   	pop    %ebx
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	8b 45 08             	mov    0x8(%ebp),%eax
  800c89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c8d:	eb 07                	jmp    800c96 <strchr+0x13>
		if (*s == c)
  800c8f:	38 ca                	cmp    %cl,%dl
  800c91:	74 0f                	je     800ca2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c93:	83 c0 01             	add    $0x1,%eax
  800c96:	0f b6 10             	movzbl (%eax),%edx
  800c99:	84 d2                	test   %dl,%dl
  800c9b:	75 f2                	jne    800c8f <strchr+0xc>
  800c9d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  800caa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cae:	eb 07                	jmp    800cb7 <strfind+0x13>
		if (*s == c)
  800cb0:	38 ca                	cmp    %cl,%dl
  800cb2:	74 0a                	je     800cbe <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cb4:	83 c0 01             	add    $0x1,%eax
  800cb7:	0f b6 10             	movzbl (%eax),%edx
  800cba:	84 d2                	test   %dl,%dl
  800cbc:	75 f2                	jne    800cb0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800cbe:	5d                   	pop    %ebp
  800cbf:	90                   	nop
  800cc0:	c3                   	ret    

00800cc1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 0c             	sub    $0xc,%esp
  800cc7:	89 1c 24             	mov    %ebx,(%esp)
  800cca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800cd2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cdb:	85 c9                	test   %ecx,%ecx
  800cdd:	74 30                	je     800d0f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cdf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ce5:	75 25                	jne    800d0c <memset+0x4b>
  800ce7:	f6 c1 03             	test   $0x3,%cl
  800cea:	75 20                	jne    800d0c <memset+0x4b>
		c &= 0xFF;
  800cec:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cef:	89 d3                	mov    %edx,%ebx
  800cf1:	c1 e3 08             	shl    $0x8,%ebx
  800cf4:	89 d6                	mov    %edx,%esi
  800cf6:	c1 e6 18             	shl    $0x18,%esi
  800cf9:	89 d0                	mov    %edx,%eax
  800cfb:	c1 e0 10             	shl    $0x10,%eax
  800cfe:	09 f0                	or     %esi,%eax
  800d00:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d02:	09 d8                	or     %ebx,%eax
  800d04:	c1 e9 02             	shr    $0x2,%ecx
  800d07:	fc                   	cld    
  800d08:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d0a:	eb 03                	jmp    800d0f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d0c:	fc                   	cld    
  800d0d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d0f:	89 f8                	mov    %edi,%eax
  800d11:	8b 1c 24             	mov    (%esp),%ebx
  800d14:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d18:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d1c:	89 ec                	mov    %ebp,%esp
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	83 ec 08             	sub    $0x8,%esp
  800d26:	89 34 24             	mov    %esi,(%esp)
  800d29:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800d33:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d36:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d38:	39 c6                	cmp    %eax,%esi
  800d3a:	73 35                	jae    800d71 <memmove+0x51>
  800d3c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d3f:	39 d0                	cmp    %edx,%eax
  800d41:	73 2e                	jae    800d71 <memmove+0x51>
		s += n;
		d += n;
  800d43:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d45:	f6 c2 03             	test   $0x3,%dl
  800d48:	75 1b                	jne    800d65 <memmove+0x45>
  800d4a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d50:	75 13                	jne    800d65 <memmove+0x45>
  800d52:	f6 c1 03             	test   $0x3,%cl
  800d55:	75 0e                	jne    800d65 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d57:	83 ef 04             	sub    $0x4,%edi
  800d5a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d5d:	c1 e9 02             	shr    $0x2,%ecx
  800d60:	fd                   	std    
  800d61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d63:	eb 09                	jmp    800d6e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d65:	83 ef 01             	sub    $0x1,%edi
  800d68:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d6b:	fd                   	std    
  800d6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d6e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d6f:	eb 20                	jmp    800d91 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d71:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d77:	75 15                	jne    800d8e <memmove+0x6e>
  800d79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d7f:	75 0d                	jne    800d8e <memmove+0x6e>
  800d81:	f6 c1 03             	test   $0x3,%cl
  800d84:	75 08                	jne    800d8e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d86:	c1 e9 02             	shr    $0x2,%ecx
  800d89:	fc                   	cld    
  800d8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d8c:	eb 03                	jmp    800d91 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d8e:	fc                   	cld    
  800d8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d91:	8b 34 24             	mov    (%esp),%esi
  800d94:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d98:	89 ec                	mov    %ebp,%esp
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800da2:	8b 45 10             	mov    0x10(%ebp),%eax
  800da5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db0:	8b 45 08             	mov    0x8(%ebp),%eax
  800db3:	89 04 24             	mov    %eax,(%esp)
  800db6:	e8 65 ff ff ff       	call   800d20 <memmove>
}
  800dbb:	c9                   	leave  
  800dbc:	c3                   	ret    

00800dbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dbd:	55                   	push   %ebp
  800dbe:	89 e5                	mov    %esp,%ebp
  800dc0:	57                   	push   %edi
  800dc1:	56                   	push   %esi
  800dc2:	53                   	push   %ebx
  800dc3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dc6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dc9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800dcc:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd1:	eb 1c                	jmp    800def <memcmp+0x32>
		if (*s1 != *s2)
  800dd3:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800dd7:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800ddb:	83 c2 01             	add    $0x1,%edx
  800dde:	83 e9 01             	sub    $0x1,%ecx
  800de1:	38 d8                	cmp    %bl,%al
  800de3:	74 0a                	je     800def <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800de5:	0f b6 c0             	movzbl %al,%eax
  800de8:	0f b6 db             	movzbl %bl,%ebx
  800deb:	29 d8                	sub    %ebx,%eax
  800ded:	eb 09                	jmp    800df8 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800def:	85 c9                	test   %ecx,%ecx
  800df1:	75 e0                	jne    800dd3 <memcmp+0x16>
  800df3:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e06:	89 c2                	mov    %eax,%edx
  800e08:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e0b:	eb 07                	jmp    800e14 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e0d:	38 08                	cmp    %cl,(%eax)
  800e0f:	74 07                	je     800e18 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e11:	83 c0 01             	add    $0x1,%eax
  800e14:	39 d0                	cmp    %edx,%eax
  800e16:	72 f5                	jb     800e0d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	57                   	push   %edi
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	83 ec 04             	sub    $0x4,%esp
  800e23:	8b 55 08             	mov    0x8(%ebp),%edx
  800e26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e29:	eb 03                	jmp    800e2e <strtol+0x14>
		s++;
  800e2b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e2e:	0f b6 02             	movzbl (%edx),%eax
  800e31:	3c 20                	cmp    $0x20,%al
  800e33:	74 f6                	je     800e2b <strtol+0x11>
  800e35:	3c 09                	cmp    $0x9,%al
  800e37:	74 f2                	je     800e2b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e39:	3c 2b                	cmp    $0x2b,%al
  800e3b:	75 0c                	jne    800e49 <strtol+0x2f>
		s++;
  800e3d:	8d 52 01             	lea    0x1(%edx),%edx
  800e40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e47:	eb 15                	jmp    800e5e <strtol+0x44>
	else if (*s == '-')
  800e49:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e50:	3c 2d                	cmp    $0x2d,%al
  800e52:	75 0a                	jne    800e5e <strtol+0x44>
		s++, neg = 1;
  800e54:	8d 52 01             	lea    0x1(%edx),%edx
  800e57:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e5e:	85 db                	test   %ebx,%ebx
  800e60:	0f 94 c0             	sete   %al
  800e63:	74 05                	je     800e6a <strtol+0x50>
  800e65:	83 fb 10             	cmp    $0x10,%ebx
  800e68:	75 18                	jne    800e82 <strtol+0x68>
  800e6a:	80 3a 30             	cmpb   $0x30,(%edx)
  800e6d:	75 13                	jne    800e82 <strtol+0x68>
  800e6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e73:	75 0d                	jne    800e82 <strtol+0x68>
		s += 2, base = 16;
  800e75:	83 c2 02             	add    $0x2,%edx
  800e78:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e7d:	8d 76 00             	lea    0x0(%esi),%esi
  800e80:	eb 13                	jmp    800e95 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e82:	84 c0                	test   %al,%al
  800e84:	74 0f                	je     800e95 <strtol+0x7b>
  800e86:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e8b:	80 3a 30             	cmpb   $0x30,(%edx)
  800e8e:	75 05                	jne    800e95 <strtol+0x7b>
		s++, base = 8;
  800e90:	83 c2 01             	add    $0x1,%edx
  800e93:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e9c:	0f b6 0a             	movzbl (%edx),%ecx
  800e9f:	89 cf                	mov    %ecx,%edi
  800ea1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ea4:	80 fb 09             	cmp    $0x9,%bl
  800ea7:	77 08                	ja     800eb1 <strtol+0x97>
			dig = *s - '0';
  800ea9:	0f be c9             	movsbl %cl,%ecx
  800eac:	83 e9 30             	sub    $0x30,%ecx
  800eaf:	eb 1e                	jmp    800ecf <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800eb1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800eb4:	80 fb 19             	cmp    $0x19,%bl
  800eb7:	77 08                	ja     800ec1 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800eb9:	0f be c9             	movsbl %cl,%ecx
  800ebc:	83 e9 57             	sub    $0x57,%ecx
  800ebf:	eb 0e                	jmp    800ecf <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ec1:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ec4:	80 fb 19             	cmp    $0x19,%bl
  800ec7:	77 15                	ja     800ede <strtol+0xc4>
			dig = *s - 'A' + 10;
  800ec9:	0f be c9             	movsbl %cl,%ecx
  800ecc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ecf:	39 f1                	cmp    %esi,%ecx
  800ed1:	7d 0b                	jge    800ede <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800ed3:	83 c2 01             	add    $0x1,%edx
  800ed6:	0f af c6             	imul   %esi,%eax
  800ed9:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800edc:	eb be                	jmp    800e9c <strtol+0x82>
  800ede:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ee0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee4:	74 05                	je     800eeb <strtol+0xd1>
		*endptr = (char *) s;
  800ee6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800eeb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800eef:	74 04                	je     800ef5 <strtol+0xdb>
  800ef1:	89 c8                	mov    %ecx,%eax
  800ef3:	f7 d8                	neg    %eax
}
  800ef5:	83 c4 04             	add    $0x4,%esp
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    
  800efd:	00 00                	add    %al,(%eax)
	...

00800f00 <__udivdi3>:
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	83 ec 10             	sub    $0x10,%esp
  800f08:	8b 45 14             	mov    0x14(%ebp),%eax
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	8b 75 10             	mov    0x10(%ebp),%esi
  800f11:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f14:	85 c0                	test   %eax,%eax
  800f16:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f19:	75 35                	jne    800f50 <__udivdi3+0x50>
  800f1b:	39 fe                	cmp    %edi,%esi
  800f1d:	77 61                	ja     800f80 <__udivdi3+0x80>
  800f1f:	85 f6                	test   %esi,%esi
  800f21:	75 0b                	jne    800f2e <__udivdi3+0x2e>
  800f23:	b8 01 00 00 00       	mov    $0x1,%eax
  800f28:	31 d2                	xor    %edx,%edx
  800f2a:	f7 f6                	div    %esi
  800f2c:	89 c6                	mov    %eax,%esi
  800f2e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800f31:	31 d2                	xor    %edx,%edx
  800f33:	89 f8                	mov    %edi,%eax
  800f35:	f7 f6                	div    %esi
  800f37:	89 c7                	mov    %eax,%edi
  800f39:	89 c8                	mov    %ecx,%eax
  800f3b:	f7 f6                	div    %esi
  800f3d:	89 c1                	mov    %eax,%ecx
  800f3f:	89 fa                	mov    %edi,%edx
  800f41:	89 c8                	mov    %ecx,%eax
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	5e                   	pop    %esi
  800f47:	5f                   	pop    %edi
  800f48:	5d                   	pop    %ebp
  800f49:	c3                   	ret    
  800f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f50:	39 f8                	cmp    %edi,%eax
  800f52:	77 1c                	ja     800f70 <__udivdi3+0x70>
  800f54:	0f bd d0             	bsr    %eax,%edx
  800f57:	83 f2 1f             	xor    $0x1f,%edx
  800f5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800f5d:	75 39                	jne    800f98 <__udivdi3+0x98>
  800f5f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800f62:	0f 86 a0 00 00 00    	jbe    801008 <__udivdi3+0x108>
  800f68:	39 f8                	cmp    %edi,%eax
  800f6a:	0f 82 98 00 00 00    	jb     801008 <__udivdi3+0x108>
  800f70:	31 ff                	xor    %edi,%edi
  800f72:	31 c9                	xor    %ecx,%ecx
  800f74:	89 c8                	mov    %ecx,%eax
  800f76:	89 fa                	mov    %edi,%edx
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    
  800f7f:	90                   	nop
  800f80:	89 d1                	mov    %edx,%ecx
  800f82:	89 fa                	mov    %edi,%edx
  800f84:	89 c8                	mov    %ecx,%eax
  800f86:	31 ff                	xor    %edi,%edi
  800f88:	f7 f6                	div    %esi
  800f8a:	89 c1                	mov    %eax,%ecx
  800f8c:	89 fa                	mov    %edi,%edx
  800f8e:	89 c8                	mov    %ecx,%eax
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    
  800f97:	90                   	nop
  800f98:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800f9c:	89 f2                	mov    %esi,%edx
  800f9e:	d3 e0                	shl    %cl,%eax
  800fa0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fa3:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fab:	89 c1                	mov    %eax,%ecx
  800fad:	d3 ea                	shr    %cl,%edx
  800faf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fb3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800fb6:	d3 e6                	shl    %cl,%esi
  800fb8:	89 c1                	mov    %eax,%ecx
  800fba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800fbd:	89 fe                	mov    %edi,%esi
  800fbf:	d3 ee                	shr    %cl,%esi
  800fc1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fc5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fcb:	d3 e7                	shl    %cl,%edi
  800fcd:	89 c1                	mov    %eax,%ecx
  800fcf:	d3 ea                	shr    %cl,%edx
  800fd1:	09 d7                	or     %edx,%edi
  800fd3:	89 f2                	mov    %esi,%edx
  800fd5:	89 f8                	mov    %edi,%eax
  800fd7:	f7 75 ec             	divl   -0x14(%ebp)
  800fda:	89 d6                	mov    %edx,%esi
  800fdc:	89 c7                	mov    %eax,%edi
  800fde:	f7 65 e8             	mull   -0x18(%ebp)
  800fe1:	39 d6                	cmp    %edx,%esi
  800fe3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fe6:	72 30                	jb     801018 <__udivdi3+0x118>
  800fe8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800feb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fef:	d3 e2                	shl    %cl,%edx
  800ff1:	39 c2                	cmp    %eax,%edx
  800ff3:	73 05                	jae    800ffa <__udivdi3+0xfa>
  800ff5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  800ff8:	74 1e                	je     801018 <__udivdi3+0x118>
  800ffa:	89 f9                	mov    %edi,%ecx
  800ffc:	31 ff                	xor    %edi,%edi
  800ffe:	e9 71 ff ff ff       	jmp    800f74 <__udivdi3+0x74>
  801003:	90                   	nop
  801004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801008:	31 ff                	xor    %edi,%edi
  80100a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80100f:	e9 60 ff ff ff       	jmp    800f74 <__udivdi3+0x74>
  801014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801018:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80101b:	31 ff                	xor    %edi,%edi
  80101d:	89 c8                	mov    %ecx,%eax
  80101f:	89 fa                	mov    %edi,%edx
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	5e                   	pop    %esi
  801025:	5f                   	pop    %edi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    
	...

00801030 <__umoddi3>:
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	83 ec 20             	sub    $0x20,%esp
  801038:	8b 55 14             	mov    0x14(%ebp),%edx
  80103b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801041:	8b 75 0c             	mov    0xc(%ebp),%esi
  801044:	85 d2                	test   %edx,%edx
  801046:	89 c8                	mov    %ecx,%eax
  801048:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80104b:	75 13                	jne    801060 <__umoddi3+0x30>
  80104d:	39 f7                	cmp    %esi,%edi
  80104f:	76 3f                	jbe    801090 <__umoddi3+0x60>
  801051:	89 f2                	mov    %esi,%edx
  801053:	f7 f7                	div    %edi
  801055:	89 d0                	mov    %edx,%eax
  801057:	31 d2                	xor    %edx,%edx
  801059:	83 c4 20             	add    $0x20,%esp
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    
  801060:	39 f2                	cmp    %esi,%edx
  801062:	77 4c                	ja     8010b0 <__umoddi3+0x80>
  801064:	0f bd ca             	bsr    %edx,%ecx
  801067:	83 f1 1f             	xor    $0x1f,%ecx
  80106a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80106d:	75 51                	jne    8010c0 <__umoddi3+0x90>
  80106f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801072:	0f 87 e0 00 00 00    	ja     801158 <__umoddi3+0x128>
  801078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107b:	29 f8                	sub    %edi,%eax
  80107d:	19 d6                	sbb    %edx,%esi
  80107f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801085:	89 f2                	mov    %esi,%edx
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	5e                   	pop    %esi
  80108b:	5f                   	pop    %edi
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    
  80108e:	66 90                	xchg   %ax,%ax
  801090:	85 ff                	test   %edi,%edi
  801092:	75 0b                	jne    80109f <__umoddi3+0x6f>
  801094:	b8 01 00 00 00       	mov    $0x1,%eax
  801099:	31 d2                	xor    %edx,%edx
  80109b:	f7 f7                	div    %edi
  80109d:	89 c7                	mov    %eax,%edi
  80109f:	89 f0                	mov    %esi,%eax
  8010a1:	31 d2                	xor    %edx,%edx
  8010a3:	f7 f7                	div    %edi
  8010a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a8:	f7 f7                	div    %edi
  8010aa:	eb a9                	jmp    801055 <__umoddi3+0x25>
  8010ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010b0:	89 c8                	mov    %ecx,%eax
  8010b2:	89 f2                	mov    %esi,%edx
  8010b4:	83 c4 20             	add    $0x20,%esp
  8010b7:	5e                   	pop    %esi
  8010b8:	5f                   	pop    %edi
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    
  8010bb:	90                   	nop
  8010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010c4:	d3 e2                	shl    %cl,%edx
  8010c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8010ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8010d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010d8:	89 fa                	mov    %edi,%edx
  8010da:	d3 ea                	shr    %cl,%edx
  8010dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8010e3:	d3 e7                	shl    %cl,%edi
  8010e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010ec:	89 f2                	mov    %esi,%edx
  8010ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8010f1:	89 c7                	mov    %eax,%edi
  8010f3:	d3 ea                	shr    %cl,%edx
  8010f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8010fc:	89 c2                	mov    %eax,%edx
  8010fe:	d3 e6                	shl    %cl,%esi
  801100:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801104:	d3 ea                	shr    %cl,%edx
  801106:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80110a:	09 d6                	or     %edx,%esi
  80110c:	89 f0                	mov    %esi,%eax
  80110e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801111:	d3 e7                	shl    %cl,%edi
  801113:	89 f2                	mov    %esi,%edx
  801115:	f7 75 f4             	divl   -0xc(%ebp)
  801118:	89 d6                	mov    %edx,%esi
  80111a:	f7 65 e8             	mull   -0x18(%ebp)
  80111d:	39 d6                	cmp    %edx,%esi
  80111f:	72 2b                	jb     80114c <__umoddi3+0x11c>
  801121:	39 c7                	cmp    %eax,%edi
  801123:	72 23                	jb     801148 <__umoddi3+0x118>
  801125:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801129:	29 c7                	sub    %eax,%edi
  80112b:	19 d6                	sbb    %edx,%esi
  80112d:	89 f0                	mov    %esi,%eax
  80112f:	89 f2                	mov    %esi,%edx
  801131:	d3 ef                	shr    %cl,%edi
  801133:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801137:	d3 e0                	shl    %cl,%eax
  801139:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80113d:	09 f8                	or     %edi,%eax
  80113f:	d3 ea                	shr    %cl,%edx
  801141:	83 c4 20             	add    $0x20,%esp
  801144:	5e                   	pop    %esi
  801145:	5f                   	pop    %edi
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    
  801148:	39 d6                	cmp    %edx,%esi
  80114a:	75 d9                	jne    801125 <__umoddi3+0xf5>
  80114c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80114f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801152:	eb d1                	jmp    801125 <__umoddi3+0xf5>
  801154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801158:	39 f2                	cmp    %esi,%edx
  80115a:	0f 82 18 ff ff ff    	jb     801078 <__umoddi3+0x48>
  801160:	e9 1d ff ff ff       	jmp    801082 <__umoddi3+0x52>
