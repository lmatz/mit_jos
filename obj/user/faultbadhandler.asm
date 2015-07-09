
obj/user/faultbadhandler:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 d8 02 00 00       	call   80032e <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 a5 00 00 00       	call   80010f <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  80008a:	e8 32 03 00 00       	call   8003c1 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000d5:	e8 1b 03 00 00       	call   8003f5 <sys_env_destroy>
}
  8000da:	c9                   	leave  
  8000db:	c3                   	ret    

008000dc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	89 1c 24             	mov    %ebx,(%esp)
  8000e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000e9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	89 c3                	mov    %eax,%ebx
  8000fa:	89 c7                	mov    %eax,%edi
  8000fc:	89 c6                	mov    %eax,%esi
  8000fe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800100:	8b 1c 24             	mov    (%esp),%ebx
  800103:	8b 74 24 04          	mov    0x4(%esp),%esi
  800107:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    

0080010f <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 38             	sub    $0x38,%esp
  800115:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800118:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  80011e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800122:	75 0c                	jne    800130 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800124:	c7 04 24 ac 11 80 00 	movl   $0x8011ac,(%esp)
  80012b:	e8 11 04 00 00       	call   800541 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	bb 00 00 00 00       	mov    $0x0,%ebx
  800135:	b8 09 00 00 00       	mov    $0x9,%eax
  80013a:	8b 55 08             	mov    0x8(%ebp),%edx
  80013d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800140:	89 df                	mov    %ebx,%edi
  800142:	89 de                	mov    %ebx,%esi
  800144:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800146:	85 c0                	test   %eax,%eax
  800148:	7e 28                	jle    800172 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80014a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014e:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800155:	00 
  800156:	c7 44 24 08 d8 11 80 	movl   $0x8011d8,0x8(%esp)
  80015d:	00 
  80015e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800165:	00 
  800166:	c7 04 24 f5 11 80 00 	movl   $0x8011f5,(%esp)
  80016d:	e8 16 03 00 00       	call   800488 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800172:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800175:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800178:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80017b:	89 ec                	mov    %ebp,%esp
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	83 ec 38             	sub    $0x38,%esp
  800185:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800188:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80018b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800193:	b8 0c 00 00 00       	mov    $0xc,%eax
  800198:	8b 55 08             	mov    0x8(%ebp),%edx
  80019b:	89 cb                	mov    %ecx,%ebx
  80019d:	89 cf                	mov    %ecx,%edi
  80019f:	89 ce                	mov    %ecx,%esi
  8001a1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	7e 28                	jle    8001cf <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ab:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  8001b2:	00 
  8001b3:	c7 44 24 08 d8 11 80 	movl   $0x8011d8,0x8(%esp)
  8001ba:	00 
  8001bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c2:	00 
  8001c3:	c7 04 24 f5 11 80 00 	movl   $0x8011f5,(%esp)
  8001ca:	e8 b9 02 00 00       	call   800488 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8001cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001d8:	89 ec                	mov    %ebp,%esp
  8001da:	5d                   	pop    %ebp
  8001db:	c3                   	ret    

008001dc <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	89 1c 24             	mov    %ebx,(%esp)
  8001e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001e9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ed:	be 00 00 00 00       	mov    $0x0,%esi
  8001f2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001f7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800200:	8b 55 08             	mov    0x8(%ebp),%edx
  800203:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800205:	8b 1c 24             	mov    (%esp),%ebx
  800208:	8b 74 24 04          	mov    0x4(%esp),%esi
  80020c:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800210:	89 ec                	mov    %ebp,%esp
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 38             	sub    $0x38,%esp
  80021a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80021d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800220:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800223:	bb 00 00 00 00       	mov    $0x0,%ebx
  800228:	b8 08 00 00 00       	mov    $0x8,%eax
  80022d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800230:	8b 55 08             	mov    0x8(%ebp),%edx
  800233:	89 df                	mov    %ebx,%edi
  800235:	89 de                	mov    %ebx,%esi
  800237:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800239:	85 c0                	test   %eax,%eax
  80023b:	7e 28                	jle    800265 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800241:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800248:	00 
  800249:	c7 44 24 08 d8 11 80 	movl   $0x8011d8,0x8(%esp)
  800250:	00 
  800251:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800258:	00 
  800259:	c7 04 24 f5 11 80 00 	movl   $0x8011f5,(%esp)
  800260:	e8 23 02 00 00       	call   800488 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800265:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800268:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80026b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80026e:	89 ec                	mov    %ebp,%esp
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    

00800272 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800272:	55                   	push   %ebp
  800273:	89 e5                	mov    %esp,%ebp
  800275:	83 ec 38             	sub    $0x38,%esp
  800278:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80027b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80027e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800281:	bb 00 00 00 00       	mov    $0x0,%ebx
  800286:	b8 06 00 00 00       	mov    $0x6,%eax
  80028b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028e:	8b 55 08             	mov    0x8(%ebp),%edx
  800291:	89 df                	mov    %ebx,%edi
  800293:	89 de                	mov    %ebx,%esi
  800295:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800297:	85 c0                	test   %eax,%eax
  800299:	7e 28                	jle    8002c3 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002a6:	00 
  8002a7:	c7 44 24 08 d8 11 80 	movl   $0x8011d8,0x8(%esp)
  8002ae:	00 
  8002af:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b6:	00 
  8002b7:	c7 04 24 f5 11 80 00 	movl   $0x8011f5,(%esp)
  8002be:	e8 c5 01 00 00       	call   800488 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002c3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002c6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002c9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002cc:	89 ec                	mov    %ebp,%esp
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 38             	sub    $0x38,%esp
  8002d6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002d9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002dc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	b8 05 00 00 00       	mov    $0x5,%eax
  8002e4:	8b 75 18             	mov    0x18(%ebp),%esi
  8002e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	7e 28                	jle    800321 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fd:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800304:	00 
  800305:	c7 44 24 08 d8 11 80 	movl   $0x8011d8,0x8(%esp)
  80030c:	00 
  80030d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800314:	00 
  800315:	c7 04 24 f5 11 80 00 	movl   $0x8011f5,(%esp)
  80031c:	e8 67 01 00 00       	call   800488 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800321:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800324:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800327:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80032a:	89 ec                	mov    %ebp,%esp
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	83 ec 38             	sub    $0x38,%esp
  800334:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800337:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80033a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033d:	be 00 00 00 00       	mov    $0x0,%esi
  800342:	b8 04 00 00 00       	mov    $0x4,%eax
  800347:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034d:	8b 55 08             	mov    0x8(%ebp),%edx
  800350:	89 f7                	mov    %esi,%edi
  800352:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800354:	85 c0                	test   %eax,%eax
  800356:	7e 28                	jle    800380 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800358:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800363:	00 
  800364:	c7 44 24 08 d8 11 80 	movl   $0x8011d8,0x8(%esp)
  80036b:	00 
  80036c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800373:	00 
  800374:	c7 04 24 f5 11 80 00 	movl   $0x8011f5,(%esp)
  80037b:	e8 08 01 00 00       	call   800488 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800380:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800383:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800386:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800389:	89 ec                	mov    %ebp,%esp
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
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
  8003a3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003a8:	89 d1                	mov    %edx,%ecx
  8003aa:	89 d3                	mov    %edx,%ebx
  8003ac:	89 d7                	mov    %edx,%edi
  8003ae:	89 d6                	mov    %edx,%esi
  8003b0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8003b2:	8b 1c 24             	mov    (%esp),%ebx
  8003b5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003b9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003bd:	89 ec                	mov    %ebp,%esp
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	83 ec 0c             	sub    $0xc,%esp
  8003c7:	89 1c 24             	mov    %ebx,(%esp)
  8003ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	b8 02 00 00 00       	mov    $0x2,%eax
  8003dc:	89 d1                	mov    %edx,%ecx
  8003de:	89 d3                	mov    %edx,%ebx
  8003e0:	89 d7                	mov    %edx,%edi
  8003e2:	89 d6                	mov    %edx,%esi
  8003e4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8003e6:	8b 1c 24             	mov    (%esp),%ebx
  8003e9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003ed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003f1:	89 ec                	mov    %ebp,%esp
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	83 ec 38             	sub    $0x38,%esp
  8003fb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003fe:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800401:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800404:	b9 00 00 00 00       	mov    $0x0,%ecx
  800409:	b8 03 00 00 00       	mov    $0x3,%eax
  80040e:	8b 55 08             	mov    0x8(%ebp),%edx
  800411:	89 cb                	mov    %ecx,%ebx
  800413:	89 cf                	mov    %ecx,%edi
  800415:	89 ce                	mov    %ecx,%esi
  800417:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800419:	85 c0                	test   %eax,%eax
  80041b:	7e 28                	jle    800445 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80041d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800421:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800428:	00 
  800429:	c7 44 24 08 d8 11 80 	movl   $0x8011d8,0x8(%esp)
  800430:	00 
  800431:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800438:	00 
  800439:	c7 04 24 f5 11 80 00 	movl   $0x8011f5,(%esp)
  800440:	e8 43 00 00 00       	call   800488 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800445:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800448:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80044b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80044e:	89 ec                	mov    %ebp,%esp
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    

00800452 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	83 ec 0c             	sub    $0xc,%esp
  800458:	89 1c 24             	mov    %ebx,(%esp)
  80045b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80045f:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800463:	ba 00 00 00 00       	mov    $0x0,%edx
  800468:	b8 01 00 00 00       	mov    $0x1,%eax
  80046d:	89 d1                	mov    %edx,%ecx
  80046f:	89 d3                	mov    %edx,%ebx
  800471:	89 d7                	mov    %edx,%edi
  800473:	89 d6                	mov    %edx,%esi
  800475:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800477:	8b 1c 24             	mov    (%esp),%ebx
  80047a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80047e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800482:	89 ec                	mov    %ebp,%esp
  800484:	5d                   	pop    %ebp
  800485:	c3                   	ret    
	...

00800488 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	56                   	push   %esi
  80048c:	53                   	push   %ebx
  80048d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800490:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800493:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800499:	e8 23 ff ff ff       	call   8003c1 <sys_getenvid>
  80049e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8004a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b4:	c7 04 24 04 12 80 00 	movl   $0x801204,(%esp)
  8004bb:	e8 81 00 00 00       	call   800541 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004c7:	89 04 24             	mov    %eax,(%esp)
  8004ca:	e8 11 00 00 00       	call   8004e0 <vcprintf>
	cprintf("\n");
  8004cf:	c7 04 24 28 12 80 00 	movl   $0x801228,(%esp)
  8004d6:	e8 66 00 00 00       	call   800541 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004db:	cc                   	int3   
  8004dc:	eb fd                	jmp    8004db <_panic+0x53>
	...

008004e0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004f0:	00 00 00 
	b.cnt = 0;
  8004f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800500:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800504:	8b 45 08             	mov    0x8(%ebp),%eax
  800507:	89 44 24 08          	mov    %eax,0x8(%esp)
  80050b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800511:	89 44 24 04          	mov    %eax,0x4(%esp)
  800515:	c7 04 24 5b 05 80 00 	movl   $0x80055b,(%esp)
  80051c:	e8 be 01 00 00       	call   8006df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800521:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800531:	89 04 24             	mov    %eax,(%esp)
  800534:	e8 a3 fb ff ff       	call   8000dc <sys_cputs>

	return b.cnt;
}
  800539:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80053f:	c9                   	leave  
  800540:	c3                   	ret    

00800541 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800541:	55                   	push   %ebp
  800542:	89 e5                	mov    %esp,%ebp
  800544:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800547:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80054a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	89 04 24             	mov    %eax,(%esp)
  800554:	e8 87 ff ff ff       	call   8004e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800559:	c9                   	leave  
  80055a:	c3                   	ret    

0080055b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	53                   	push   %ebx
  80055f:	83 ec 14             	sub    $0x14,%esp
  800562:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800565:	8b 03                	mov    (%ebx),%eax
  800567:	8b 55 08             	mov    0x8(%ebp),%edx
  80056a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80056e:	83 c0 01             	add    $0x1,%eax
  800571:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800573:	3d ff 00 00 00       	cmp    $0xff,%eax
  800578:	75 19                	jne    800593 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80057a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800581:	00 
  800582:	8d 43 08             	lea    0x8(%ebx),%eax
  800585:	89 04 24             	mov    %eax,(%esp)
  800588:	e8 4f fb ff ff       	call   8000dc <sys_cputs>
		b->idx = 0;
  80058d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800593:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800597:	83 c4 14             	add    $0x14,%esp
  80059a:	5b                   	pop    %ebx
  80059b:	5d                   	pop    %ebp
  80059c:	c3                   	ret    
  80059d:	00 00                	add    %al,(%eax)
	...

008005a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	57                   	push   %edi
  8005a4:	56                   	push   %esi
  8005a5:	53                   	push   %ebx
  8005a6:	83 ec 4c             	sub    $0x4c,%esp
  8005a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ac:	89 d6                	mov    %edx,%esi
  8005ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8005bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cb:	39 d1                	cmp    %edx,%ecx
  8005cd:	72 07                	jb     8005d6 <printnum+0x36>
  8005cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d2:	39 d0                	cmp    %edx,%eax
  8005d4:	77 69                	ja     80063f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005d6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005da:	83 eb 01             	sub    $0x1,%ebx
  8005dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8005e9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8005ed:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005f0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005f3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800601:	00 
  800602:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800605:	89 04 24             	mov    %eax,(%esp)
  800608:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80060b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060f:	e8 1c 09 00 00       	call   800f30 <__udivdi3>
  800614:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800617:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80061a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80061e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	89 54 24 04          	mov    %edx,0x4(%esp)
  800629:	89 f2                	mov    %esi,%edx
  80062b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062e:	e8 6d ff ff ff       	call   8005a0 <printnum>
  800633:	eb 11                	jmp    800646 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800635:	89 74 24 04          	mov    %esi,0x4(%esp)
  800639:	89 3c 24             	mov    %edi,(%esp)
  80063c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80063f:	83 eb 01             	sub    $0x1,%ebx
  800642:	85 db                	test   %ebx,%ebx
  800644:	7f ef                	jg     800635 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80064e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800651:	89 44 24 08          	mov    %eax,0x8(%esp)
  800655:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80065c:	00 
  80065d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800660:	89 14 24             	mov    %edx,(%esp)
  800663:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800666:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80066a:	e8 f1 09 00 00       	call   801060 <__umoddi3>
  80066f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800673:	0f be 80 2a 12 80 00 	movsbl 0x80122a(%eax),%eax
  80067a:	89 04 24             	mov    %eax,(%esp)
  80067d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800680:	83 c4 4c             	add    $0x4c,%esp
  800683:	5b                   	pop    %ebx
  800684:	5e                   	pop    %esi
  800685:	5f                   	pop    %edi
  800686:	5d                   	pop    %ebp
  800687:	c3                   	ret    

00800688 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80068b:	83 fa 01             	cmp    $0x1,%edx
  80068e:	7e 0e                	jle    80069e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800690:	8b 10                	mov    (%eax),%edx
  800692:	8d 4a 08             	lea    0x8(%edx),%ecx
  800695:	89 08                	mov    %ecx,(%eax)
  800697:	8b 02                	mov    (%edx),%eax
  800699:	8b 52 04             	mov    0x4(%edx),%edx
  80069c:	eb 22                	jmp    8006c0 <getuint+0x38>
	else if (lflag)
  80069e:	85 d2                	test   %edx,%edx
  8006a0:	74 10                	je     8006b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a7:	89 08                	mov    %ecx,(%eax)
  8006a9:	8b 02                	mov    (%edx),%eax
  8006ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b0:	eb 0e                	jmp    8006c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b7:	89 08                	mov    %ecx,(%eax)
  8006b9:	8b 02                	mov    (%edx),%eax
  8006bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006c0:	5d                   	pop    %ebp
  8006c1:	c3                   	ret    

008006c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006c2:	55                   	push   %ebp
  8006c3:	89 e5                	mov    %esp,%ebp
  8006c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8006d1:	73 0a                	jae    8006dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8006d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d6:	88 0a                	mov    %cl,(%edx)
  8006d8:	83 c2 01             	add    $0x1,%edx
  8006db:	89 10                	mov    %edx,(%eax)
}
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 4c             	sub    $0x4c,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006f1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8006f8:	eb 11                	jmp    80070b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006fa:	85 c0                	test   %eax,%eax
  8006fc:	0f 84 b0 03 00 00    	je     800ab2 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800702:	89 74 24 04          	mov    %esi,0x4(%esp)
  800706:	89 04 24             	mov    %eax,(%esp)
  800709:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80070b:	0f b6 03             	movzbl (%ebx),%eax
  80070e:	83 c3 01             	add    $0x1,%ebx
  800711:	83 f8 25             	cmp    $0x25,%eax
  800714:	75 e4                	jne    8006fa <vprintfmt+0x1b>
  800716:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80071d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800722:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800726:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80072d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800734:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800737:	eb 06                	jmp    80073f <vprintfmt+0x60>
  800739:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80073d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	0f b6 0b             	movzbl (%ebx),%ecx
  800742:	0f b6 c1             	movzbl %cl,%eax
  800745:	8d 53 01             	lea    0x1(%ebx),%edx
  800748:	83 e9 23             	sub    $0x23,%ecx
  80074b:	80 f9 55             	cmp    $0x55,%cl
  80074e:	0f 87 41 03 00 00    	ja     800a95 <vprintfmt+0x3b6>
  800754:	0f b6 c9             	movzbl %cl,%ecx
  800757:	ff 24 8d 00 13 80 00 	jmp    *0x801300(,%ecx,4)
  80075e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800762:	eb d9                	jmp    80073d <vprintfmt+0x5e>
  800764:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80076b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800770:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800773:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800777:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80077a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80077d:	83 fb 09             	cmp    $0x9,%ebx
  800780:	77 2b                	ja     8007ad <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800782:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800785:	eb e9                	jmp    800770 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8d 48 04             	lea    0x4(%eax),%ecx
  80078d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800790:	8b 00                	mov    (%eax),%eax
  800792:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800795:	eb 19                	jmp    8007b0 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80079a:	c1 f8 1f             	sar    $0x1f,%eax
  80079d:	f7 d0                	not    %eax
  80079f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  8007a2:	eb 99                	jmp    80073d <vprintfmt+0x5e>
  8007a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8007ab:	eb 90                	jmp    80073d <vprintfmt+0x5e>
  8007ad:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  8007b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b4:	79 87                	jns    80073d <vprintfmt+0x5e>
  8007b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007bc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8007bf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007c2:	e9 76 ff ff ff       	jmp    80073d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007c7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8007cb:	e9 6d ff ff ff       	jmp    80073d <vprintfmt+0x5e>
  8007d0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8d 50 04             	lea    0x4(%eax),%edx
  8007d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	89 04 24             	mov    %eax,(%esp)
  8007e5:	ff d7                	call   *%edi
  8007e7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007ea:	e9 1c ff ff ff       	jmp    80070b <vprintfmt+0x2c>
  8007ef:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8d 50 04             	lea    0x4(%eax),%edx
  8007f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	89 c2                	mov    %eax,%edx
  8007ff:	c1 fa 1f             	sar    $0x1f,%edx
  800802:	31 d0                	xor    %edx,%eax
  800804:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800806:	83 f8 09             	cmp    $0x9,%eax
  800809:	7f 0b                	jg     800816 <vprintfmt+0x137>
  80080b:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800812:	85 d2                	test   %edx,%edx
  800814:	75 20                	jne    800836 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800816:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081a:	c7 44 24 08 3b 12 80 	movl   $0x80123b,0x8(%esp)
  800821:	00 
  800822:	89 74 24 04          	mov    %esi,0x4(%esp)
  800826:	89 3c 24             	mov    %edi,(%esp)
  800829:	e8 0c 03 00 00       	call   800b3a <printfmt>
  80082e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800831:	e9 d5 fe ff ff       	jmp    80070b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800836:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80083a:	c7 44 24 08 44 12 80 	movl   $0x801244,0x8(%esp)
  800841:	00 
  800842:	89 74 24 04          	mov    %esi,0x4(%esp)
  800846:	89 3c 24             	mov    %edi,(%esp)
  800849:	e8 ec 02 00 00       	call   800b3a <printfmt>
  80084e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800851:	e9 b5 fe ff ff       	jmp    80070b <vprintfmt+0x2c>
  800856:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800859:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80085c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80085f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800862:	8b 45 14             	mov    0x14(%ebp),%eax
  800865:	8d 50 04             	lea    0x4(%eax),%edx
  800868:	89 55 14             	mov    %edx,0x14(%ebp)
  80086b:	8b 18                	mov    (%eax),%ebx
  80086d:	85 db                	test   %ebx,%ebx
  80086f:	75 05                	jne    800876 <vprintfmt+0x197>
  800871:	bb 47 12 80 00       	mov    $0x801247,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800876:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80087a:	7e 76                	jle    8008f2 <vprintfmt+0x213>
  80087c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800880:	74 7a                	je     8008fc <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800882:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800886:	89 1c 24             	mov    %ebx,(%esp)
  800889:	e8 fa 02 00 00       	call   800b88 <strnlen>
  80088e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800891:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800893:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800897:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80089a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80089d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089f:	eb 0f                	jmp    8008b0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8008a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a8:	89 04 24             	mov    %eax,(%esp)
  8008ab:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ad:	83 eb 01             	sub    $0x1,%ebx
  8008b0:	85 db                	test   %ebx,%ebx
  8008b2:	7f ed                	jg     8008a1 <vprintfmt+0x1c2>
  8008b4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8008b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8008ba:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008bd:	89 f7                	mov    %esi,%edi
  8008bf:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008c2:	eb 40                	jmp    800904 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008c8:	74 18                	je     8008e2 <vprintfmt+0x203>
  8008ca:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008cd:	83 fa 5e             	cmp    $0x5e,%edx
  8008d0:	76 10                	jbe    8008e2 <vprintfmt+0x203>
					putch('?', putdat);
  8008d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008d6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008dd:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e0:	eb 0a                	jmp    8008ec <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8008e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008ec:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008f0:	eb 12                	jmp    800904 <vprintfmt+0x225>
  8008f2:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008f5:	89 f7                	mov    %esi,%edi
  8008f7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008fa:	eb 08                	jmp    800904 <vprintfmt+0x225>
  8008fc:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8008ff:	89 f7                	mov    %esi,%edi
  800901:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800904:	0f be 03             	movsbl (%ebx),%eax
  800907:	83 c3 01             	add    $0x1,%ebx
  80090a:	85 c0                	test   %eax,%eax
  80090c:	74 25                	je     800933 <vprintfmt+0x254>
  80090e:	85 f6                	test   %esi,%esi
  800910:	78 b2                	js     8008c4 <vprintfmt+0x1e5>
  800912:	83 ee 01             	sub    $0x1,%esi
  800915:	79 ad                	jns    8008c4 <vprintfmt+0x1e5>
  800917:	89 fe                	mov    %edi,%esi
  800919:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80091c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80091f:	eb 1a                	jmp    80093b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800921:	89 74 24 04          	mov    %esi,0x4(%esp)
  800925:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80092c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092e:	83 eb 01             	sub    $0x1,%ebx
  800931:	eb 08                	jmp    80093b <vprintfmt+0x25c>
  800933:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800936:	89 fe                	mov    %edi,%esi
  800938:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80093b:	85 db                	test   %ebx,%ebx
  80093d:	7f e2                	jg     800921 <vprintfmt+0x242>
  80093f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800942:	e9 c4 fd ff ff       	jmp    80070b <vprintfmt+0x2c>
  800947:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80094a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80094d:	83 f9 01             	cmp    $0x1,%ecx
  800950:	7e 16                	jle    800968 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800952:	8b 45 14             	mov    0x14(%ebp),%eax
  800955:	8d 50 08             	lea    0x8(%eax),%edx
  800958:	89 55 14             	mov    %edx,0x14(%ebp)
  80095b:	8b 10                	mov    (%eax),%edx
  80095d:	8b 48 04             	mov    0x4(%eax),%ecx
  800960:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800963:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800966:	eb 32                	jmp    80099a <vprintfmt+0x2bb>
	else if (lflag)
  800968:	85 c9                	test   %ecx,%ecx
  80096a:	74 18                	je     800984 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80096c:	8b 45 14             	mov    0x14(%ebp),%eax
  80096f:	8d 50 04             	lea    0x4(%eax),%edx
  800972:	89 55 14             	mov    %edx,0x14(%ebp)
  800975:	8b 00                	mov    (%eax),%eax
  800977:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80097a:	89 c1                	mov    %eax,%ecx
  80097c:	c1 f9 1f             	sar    $0x1f,%ecx
  80097f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800982:	eb 16                	jmp    80099a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800984:	8b 45 14             	mov    0x14(%ebp),%eax
  800987:	8d 50 04             	lea    0x4(%eax),%edx
  80098a:	89 55 14             	mov    %edx,0x14(%ebp)
  80098d:	8b 00                	mov    (%eax),%eax
  80098f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800992:	89 c2                	mov    %eax,%edx
  800994:	c1 fa 1f             	sar    $0x1f,%edx
  800997:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80099a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80099d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8009a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8009a9:	0f 89 a7 00 00 00    	jns    800a56 <vprintfmt+0x377>
				putch('-', putdat);
  8009af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ba:	ff d7                	call   *%edi
				num = -(long long) num;
  8009bc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8009bf:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8009c2:	f7 d9                	neg    %ecx
  8009c4:	83 d3 00             	adc    $0x0,%ebx
  8009c7:	f7 db                	neg    %ebx
  8009c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009ce:	e9 83 00 00 00       	jmp    800a56 <vprintfmt+0x377>
  8009d3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009d6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d9:	89 ca                	mov    %ecx,%edx
  8009db:	8d 45 14             	lea    0x14(%ebp),%eax
  8009de:	e8 a5 fc ff ff       	call   800688 <getuint>
  8009e3:	89 c1                	mov    %eax,%ecx
  8009e5:	89 d3                	mov    %edx,%ebx
  8009e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8009ec:	eb 68                	jmp    800a56 <vprintfmt+0x377>
  8009ee:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009f1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8009f4:	89 ca                	mov    %ecx,%edx
  8009f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009f9:	e8 8a fc ff ff       	call   800688 <getuint>
  8009fe:	89 c1                	mov    %eax,%ecx
  800a00:	89 d3                	mov    %edx,%ebx
  800a02:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800a07:	eb 4d                	jmp    800a56 <vprintfmt+0x377>
  800a09:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800a0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a10:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a17:	ff d7                	call   *%edi
			putch('x', putdat);
  800a19:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a1d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a24:	ff d7                	call   *%edi
			num = (unsigned long long)
  800a26:	8b 45 14             	mov    0x14(%ebp),%eax
  800a29:	8d 50 04             	lea    0x4(%eax),%edx
  800a2c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a2f:	8b 08                	mov    (%eax),%ecx
  800a31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a36:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a3b:	eb 19                	jmp    800a56 <vprintfmt+0x377>
  800a3d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800a40:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a43:	89 ca                	mov    %ecx,%edx
  800a45:	8d 45 14             	lea    0x14(%ebp),%eax
  800a48:	e8 3b fc ff ff       	call   800688 <getuint>
  800a4d:	89 c1                	mov    %eax,%ecx
  800a4f:	89 d3                	mov    %edx,%ebx
  800a51:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a56:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  800a5a:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a5e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a61:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a69:	89 0c 24             	mov    %ecx,(%esp)
  800a6c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a70:	89 f2                	mov    %esi,%edx
  800a72:	89 f8                	mov    %edi,%eax
  800a74:	e8 27 fb ff ff       	call   8005a0 <printnum>
  800a79:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a7c:	e9 8a fc ff ff       	jmp    80070b <vprintfmt+0x2c>
  800a81:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a84:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a88:	89 04 24             	mov    %eax,(%esp)
  800a8b:	ff d7                	call   *%edi
  800a8d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a90:	e9 76 fc ff ff       	jmp    80070b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a95:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a99:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aa0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800aa5:	80 38 25             	cmpb   $0x25,(%eax)
  800aa8:	0f 84 5d fc ff ff    	je     80070b <vprintfmt+0x2c>
  800aae:	89 c3                	mov    %eax,%ebx
  800ab0:	eb f0                	jmp    800aa2 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800ab2:	83 c4 4c             	add    $0x4c,%esp
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	83 ec 28             	sub    $0x28,%esp
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	74 04                	je     800ace <vsnprintf+0x14>
  800aca:	85 d2                	test   %edx,%edx
  800acc:	7f 07                	jg     800ad5 <vsnprintf+0x1b>
  800ace:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ad3:	eb 3b                	jmp    800b10 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ad5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ad8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800adc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800adf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aed:	8b 45 10             	mov    0x10(%ebp),%eax
  800af0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800af4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afb:	c7 04 24 c2 06 80 00 	movl   $0x8006c2,(%esp)
  800b02:	e8 d8 fb ff ff       	call   8006df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b0a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b10:	c9                   	leave  
  800b11:	c3                   	ret    

00800b12 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b18:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b22:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	89 04 24             	mov    %eax,(%esp)
  800b33:	e8 82 ff ff ff       	call   800aba <vsnprintf>
	va_end(ap);

	return rc;
}
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b40:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b43:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b47:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	e8 7f fb ff ff       	call   8006df <vprintfmt>
	va_end(ap);
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    
	...

00800b70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  800b7b:	eb 03                	jmp    800b80 <strlen+0x10>
		n++;
  800b7d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b80:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b84:	75 f7                	jne    800b7d <strlen+0xd>
		n++;
	return n;
}
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	53                   	push   %ebx
  800b8c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b92:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b97:	eb 03                	jmp    800b9c <strnlen+0x14>
		n++;
  800b99:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b9c:	39 c1                	cmp    %eax,%ecx
  800b9e:	74 06                	je     800ba6 <strnlen+0x1e>
  800ba0:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800ba4:	75 f3                	jne    800b99 <strnlen+0x11>
		n++;
	return n;
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	53                   	push   %ebx
  800bad:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bb8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bbc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bbf:	83 c2 01             	add    $0x1,%edx
  800bc2:	84 c9                	test   %cl,%cl
  800bc4:	75 f2                	jne    800bb8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bc6:	5b                   	pop    %ebx
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 08             	sub    $0x8,%esp
  800bd0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bd3:	89 1c 24             	mov    %ebx,(%esp)
  800bd6:	e8 95 ff ff ff       	call   800b70 <strlen>
	strcpy(dst + len, src);
  800bdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bde:	89 54 24 04          	mov    %edx,0x4(%esp)
  800be2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800be5:	89 04 24             	mov    %eax,(%esp)
  800be8:	e8 bc ff ff ff       	call   800ba9 <strcpy>
	return dst;
}
  800bed:	89 d8                	mov    %ebx,%eax
  800bef:	83 c4 08             	add    $0x8,%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 75 10             	mov    0x10(%ebp),%esi
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c08:	eb 0f                	jmp    800c19 <strncpy+0x24>
		*dst++ = *src;
  800c0a:	0f b6 19             	movzbl (%ecx),%ebx
  800c0d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c10:	80 39 01             	cmpb   $0x1,(%ecx)
  800c13:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c16:	83 c2 01             	add    $0x1,%edx
  800c19:	39 f2                	cmp    %esi,%edx
  800c1b:	72 ed                	jb     800c0a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	8b 75 08             	mov    0x8(%ebp),%esi
  800c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c2f:	89 f0                	mov    %esi,%eax
  800c31:	85 d2                	test   %edx,%edx
  800c33:	75 0a                	jne    800c3f <strlcpy+0x1e>
  800c35:	eb 17                	jmp    800c4e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c37:	88 18                	mov    %bl,(%eax)
  800c39:	83 c0 01             	add    $0x1,%eax
  800c3c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c3f:	83 ea 01             	sub    $0x1,%edx
  800c42:	74 07                	je     800c4b <strlcpy+0x2a>
  800c44:	0f b6 19             	movzbl (%ecx),%ebx
  800c47:	84 db                	test   %bl,%bl
  800c49:	75 ec                	jne    800c37 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  800c4b:	c6 00 00             	movb   $0x0,(%eax)
  800c4e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c5d:	eb 06                	jmp    800c65 <strcmp+0x11>
		p++, q++;
  800c5f:	83 c1 01             	add    $0x1,%ecx
  800c62:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c65:	0f b6 01             	movzbl (%ecx),%eax
  800c68:	84 c0                	test   %al,%al
  800c6a:	74 04                	je     800c70 <strcmp+0x1c>
  800c6c:	3a 02                	cmp    (%edx),%al
  800c6e:	74 ef                	je     800c5f <strcmp+0xb>
  800c70:	0f b6 c0             	movzbl %al,%eax
  800c73:	0f b6 12             	movzbl (%edx),%edx
  800c76:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	53                   	push   %ebx
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800c87:	eb 09                	jmp    800c92 <strncmp+0x18>
		n--, p++, q++;
  800c89:	83 ea 01             	sub    $0x1,%edx
  800c8c:	83 c0 01             	add    $0x1,%eax
  800c8f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c92:	85 d2                	test   %edx,%edx
  800c94:	75 07                	jne    800c9d <strncmp+0x23>
  800c96:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9b:	eb 13                	jmp    800cb0 <strncmp+0x36>
  800c9d:	0f b6 18             	movzbl (%eax),%ebx
  800ca0:	84 db                	test   %bl,%bl
  800ca2:	74 04                	je     800ca8 <strncmp+0x2e>
  800ca4:	3a 19                	cmp    (%ecx),%bl
  800ca6:	74 e1                	je     800c89 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca8:	0f b6 00             	movzbl (%eax),%eax
  800cab:	0f b6 11             	movzbl (%ecx),%edx
  800cae:	29 d0                	sub    %edx,%eax
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cbd:	eb 07                	jmp    800cc6 <strchr+0x13>
		if (*s == c)
  800cbf:	38 ca                	cmp    %cl,%dl
  800cc1:	74 0f                	je     800cd2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cc3:	83 c0 01             	add    $0x1,%eax
  800cc6:	0f b6 10             	movzbl (%eax),%edx
  800cc9:	84 d2                	test   %dl,%dl
  800ccb:	75 f2                	jne    800cbf <strchr+0xc>
  800ccd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cde:	eb 07                	jmp    800ce7 <strfind+0x13>
		if (*s == c)
  800ce0:	38 ca                	cmp    %cl,%dl
  800ce2:	74 0a                	je     800cee <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ce4:	83 c0 01             	add    $0x1,%eax
  800ce7:	0f b6 10             	movzbl (%eax),%edx
  800cea:	84 d2                	test   %dl,%dl
  800cec:	75 f2                	jne    800ce0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800cee:	5d                   	pop    %ebp
  800cef:	90                   	nop
  800cf0:	c3                   	ret    

00800cf1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	89 1c 24             	mov    %ebx,(%esp)
  800cfa:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cfe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d0b:	85 c9                	test   %ecx,%ecx
  800d0d:	74 30                	je     800d3f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d15:	75 25                	jne    800d3c <memset+0x4b>
  800d17:	f6 c1 03             	test   $0x3,%cl
  800d1a:	75 20                	jne    800d3c <memset+0x4b>
		c &= 0xFF;
  800d1c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d1f:	89 d3                	mov    %edx,%ebx
  800d21:	c1 e3 08             	shl    $0x8,%ebx
  800d24:	89 d6                	mov    %edx,%esi
  800d26:	c1 e6 18             	shl    $0x18,%esi
  800d29:	89 d0                	mov    %edx,%eax
  800d2b:	c1 e0 10             	shl    $0x10,%eax
  800d2e:	09 f0                	or     %esi,%eax
  800d30:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d32:	09 d8                	or     %ebx,%eax
  800d34:	c1 e9 02             	shr    $0x2,%ecx
  800d37:	fc                   	cld    
  800d38:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d3a:	eb 03                	jmp    800d3f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d3c:	fc                   	cld    
  800d3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d3f:	89 f8                	mov    %edi,%eax
  800d41:	8b 1c 24             	mov    (%esp),%ebx
  800d44:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d48:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d4c:	89 ec                	mov    %ebp,%esp
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    

00800d50 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 08             	sub    $0x8,%esp
  800d56:	89 34 24             	mov    %esi,(%esp)
  800d59:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800d63:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800d66:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800d68:	39 c6                	cmp    %eax,%esi
  800d6a:	73 35                	jae    800da1 <memmove+0x51>
  800d6c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d6f:	39 d0                	cmp    %edx,%eax
  800d71:	73 2e                	jae    800da1 <memmove+0x51>
		s += n;
		d += n;
  800d73:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d75:	f6 c2 03             	test   $0x3,%dl
  800d78:	75 1b                	jne    800d95 <memmove+0x45>
  800d7a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d80:	75 13                	jne    800d95 <memmove+0x45>
  800d82:	f6 c1 03             	test   $0x3,%cl
  800d85:	75 0e                	jne    800d95 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d87:	83 ef 04             	sub    $0x4,%edi
  800d8a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d8d:	c1 e9 02             	shr    $0x2,%ecx
  800d90:	fd                   	std    
  800d91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d93:	eb 09                	jmp    800d9e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d95:	83 ef 01             	sub    $0x1,%edi
  800d98:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d9b:	fd                   	std    
  800d9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d9e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d9f:	eb 20                	jmp    800dc1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800da1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800da7:	75 15                	jne    800dbe <memmove+0x6e>
  800da9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daf:	75 0d                	jne    800dbe <memmove+0x6e>
  800db1:	f6 c1 03             	test   $0x3,%cl
  800db4:	75 08                	jne    800dbe <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800db6:	c1 e9 02             	shr    $0x2,%ecx
  800db9:	fc                   	cld    
  800dba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dbc:	eb 03                	jmp    800dc1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dbe:	fc                   	cld    
  800dbf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dc1:	8b 34 24             	mov    (%esp),%esi
  800dc4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800dc8:	89 ec                	mov    %ebp,%esp
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800dd5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	89 04 24             	mov    %eax,(%esp)
  800de6:	e8 65 ff ff ff       	call   800d50 <memmove>
}
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    

00800ded <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
  800df0:	57                   	push   %edi
  800df1:	56                   	push   %esi
  800df2:	53                   	push   %ebx
  800df3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800df6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800df9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800dfc:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e01:	eb 1c                	jmp    800e1f <memcmp+0x32>
		if (*s1 != *s2)
  800e03:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800e07:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800e0b:	83 c2 01             	add    $0x1,%edx
  800e0e:	83 e9 01             	sub    $0x1,%ecx
  800e11:	38 d8                	cmp    %bl,%al
  800e13:	74 0a                	je     800e1f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800e15:	0f b6 c0             	movzbl %al,%eax
  800e18:	0f b6 db             	movzbl %bl,%ebx
  800e1b:	29 d8                	sub    %ebx,%eax
  800e1d:	eb 09                	jmp    800e28 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e1f:	85 c9                	test   %ecx,%ecx
  800e21:	75 e0                	jne    800e03 <memcmp+0x16>
  800e23:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	8b 45 08             	mov    0x8(%ebp),%eax
  800e33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e36:	89 c2                	mov    %eax,%edx
  800e38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e3b:	eb 07                	jmp    800e44 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e3d:	38 08                	cmp    %cl,(%eax)
  800e3f:	74 07                	je     800e48 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e41:	83 c0 01             	add    $0x1,%eax
  800e44:	39 d0                	cmp    %edx,%eax
  800e46:	72 f5                	jb     800e3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 04             	sub    $0x4,%esp
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
  800e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e59:	eb 03                	jmp    800e5e <strtol+0x14>
		s++;
  800e5b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e5e:	0f b6 02             	movzbl (%edx),%eax
  800e61:	3c 20                	cmp    $0x20,%al
  800e63:	74 f6                	je     800e5b <strtol+0x11>
  800e65:	3c 09                	cmp    $0x9,%al
  800e67:	74 f2                	je     800e5b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e69:	3c 2b                	cmp    $0x2b,%al
  800e6b:	75 0c                	jne    800e79 <strtol+0x2f>
		s++;
  800e6d:	8d 52 01             	lea    0x1(%edx),%edx
  800e70:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e77:	eb 15                	jmp    800e8e <strtol+0x44>
	else if (*s == '-')
  800e79:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e80:	3c 2d                	cmp    $0x2d,%al
  800e82:	75 0a                	jne    800e8e <strtol+0x44>
		s++, neg = 1;
  800e84:	8d 52 01             	lea    0x1(%edx),%edx
  800e87:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e8e:	85 db                	test   %ebx,%ebx
  800e90:	0f 94 c0             	sete   %al
  800e93:	74 05                	je     800e9a <strtol+0x50>
  800e95:	83 fb 10             	cmp    $0x10,%ebx
  800e98:	75 18                	jne    800eb2 <strtol+0x68>
  800e9a:	80 3a 30             	cmpb   $0x30,(%edx)
  800e9d:	75 13                	jne    800eb2 <strtol+0x68>
  800e9f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ea3:	75 0d                	jne    800eb2 <strtol+0x68>
		s += 2, base = 16;
  800ea5:	83 c2 02             	add    $0x2,%edx
  800ea8:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ead:	8d 76 00             	lea    0x0(%esi),%esi
  800eb0:	eb 13                	jmp    800ec5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800eb2:	84 c0                	test   %al,%al
  800eb4:	74 0f                	je     800ec5 <strtol+0x7b>
  800eb6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ebb:	80 3a 30             	cmpb   $0x30,(%edx)
  800ebe:	75 05                	jne    800ec5 <strtol+0x7b>
		s++, base = 8;
  800ec0:	83 c2 01             	add    $0x1,%edx
  800ec3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ecc:	0f b6 0a             	movzbl (%edx),%ecx
  800ecf:	89 cf                	mov    %ecx,%edi
  800ed1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ed4:	80 fb 09             	cmp    $0x9,%bl
  800ed7:	77 08                	ja     800ee1 <strtol+0x97>
			dig = *s - '0';
  800ed9:	0f be c9             	movsbl %cl,%ecx
  800edc:	83 e9 30             	sub    $0x30,%ecx
  800edf:	eb 1e                	jmp    800eff <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800ee1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ee4:	80 fb 19             	cmp    $0x19,%bl
  800ee7:	77 08                	ja     800ef1 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800ee9:	0f be c9             	movsbl %cl,%ecx
  800eec:	83 e9 57             	sub    $0x57,%ecx
  800eef:	eb 0e                	jmp    800eff <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ef1:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ef4:	80 fb 19             	cmp    $0x19,%bl
  800ef7:	77 15                	ja     800f0e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800ef9:	0f be c9             	movsbl %cl,%ecx
  800efc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800eff:	39 f1                	cmp    %esi,%ecx
  800f01:	7d 0b                	jge    800f0e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800f03:	83 c2 01             	add    $0x1,%edx
  800f06:	0f af c6             	imul   %esi,%eax
  800f09:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f0c:	eb be                	jmp    800ecc <strtol+0x82>
  800f0e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f14:	74 05                	je     800f1b <strtol+0xd1>
		*endptr = (char *) s;
  800f16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f19:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f1f:	74 04                	je     800f25 <strtol+0xdb>
  800f21:	89 c8                	mov    %ecx,%eax
  800f23:	f7 d8                	neg    %eax
}
  800f25:	83 c4 04             	add    $0x4,%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    
  800f2d:	00 00                	add    %al,(%eax)
	...

00800f30 <__udivdi3>:
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	83 ec 10             	sub    $0x10,%esp
  800f38:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	8b 75 10             	mov    0x10(%ebp),%esi
  800f41:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f44:	85 c0                	test   %eax,%eax
  800f46:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f49:	75 35                	jne    800f80 <__udivdi3+0x50>
  800f4b:	39 fe                	cmp    %edi,%esi
  800f4d:	77 61                	ja     800fb0 <__udivdi3+0x80>
  800f4f:	85 f6                	test   %esi,%esi
  800f51:	75 0b                	jne    800f5e <__udivdi3+0x2e>
  800f53:	b8 01 00 00 00       	mov    $0x1,%eax
  800f58:	31 d2                	xor    %edx,%edx
  800f5a:	f7 f6                	div    %esi
  800f5c:	89 c6                	mov    %eax,%esi
  800f5e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800f61:	31 d2                	xor    %edx,%edx
  800f63:	89 f8                	mov    %edi,%eax
  800f65:	f7 f6                	div    %esi
  800f67:	89 c7                	mov    %eax,%edi
  800f69:	89 c8                	mov    %ecx,%eax
  800f6b:	f7 f6                	div    %esi
  800f6d:	89 c1                	mov    %eax,%ecx
  800f6f:	89 fa                	mov    %edi,%edx
  800f71:	89 c8                	mov    %ecx,%eax
  800f73:	83 c4 10             	add    $0x10,%esp
  800f76:	5e                   	pop    %esi
  800f77:	5f                   	pop    %edi
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    
  800f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f80:	39 f8                	cmp    %edi,%eax
  800f82:	77 1c                	ja     800fa0 <__udivdi3+0x70>
  800f84:	0f bd d0             	bsr    %eax,%edx
  800f87:	83 f2 1f             	xor    $0x1f,%edx
  800f8a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800f8d:	75 39                	jne    800fc8 <__udivdi3+0x98>
  800f8f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800f92:	0f 86 a0 00 00 00    	jbe    801038 <__udivdi3+0x108>
  800f98:	39 f8                	cmp    %edi,%eax
  800f9a:	0f 82 98 00 00 00    	jb     801038 <__udivdi3+0x108>
  800fa0:	31 ff                	xor    %edi,%edi
  800fa2:	31 c9                	xor    %ecx,%ecx
  800fa4:	89 c8                	mov    %ecx,%eax
  800fa6:	89 fa                	mov    %edi,%edx
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	5e                   	pop    %esi
  800fac:	5f                   	pop    %edi
  800fad:	5d                   	pop    %ebp
  800fae:	c3                   	ret    
  800faf:	90                   	nop
  800fb0:	89 d1                	mov    %edx,%ecx
  800fb2:	89 fa                	mov    %edi,%edx
  800fb4:	89 c8                	mov    %ecx,%eax
  800fb6:	31 ff                	xor    %edi,%edi
  800fb8:	f7 f6                	div    %esi
  800fba:	89 c1                	mov    %eax,%ecx
  800fbc:	89 fa                	mov    %edi,%edx
  800fbe:	89 c8                	mov    %ecx,%eax
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	5e                   	pop    %esi
  800fc4:	5f                   	pop    %edi
  800fc5:	5d                   	pop    %ebp
  800fc6:	c3                   	ret    
  800fc7:	90                   	nop
  800fc8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fcc:	89 f2                	mov    %esi,%edx
  800fce:	d3 e0                	shl    %cl,%eax
  800fd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fd3:	b8 20 00 00 00       	mov    $0x20,%eax
  800fd8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fdb:	89 c1                	mov    %eax,%ecx
  800fdd:	d3 ea                	shr    %cl,%edx
  800fdf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fe3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800fe6:	d3 e6                	shl    %cl,%esi
  800fe8:	89 c1                	mov    %eax,%ecx
  800fea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800fed:	89 fe                	mov    %edi,%esi
  800fef:	d3 ee                	shr    %cl,%esi
  800ff1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800ff5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800ff8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ffb:	d3 e7                	shl    %cl,%edi
  800ffd:	89 c1                	mov    %eax,%ecx
  800fff:	d3 ea                	shr    %cl,%edx
  801001:	09 d7                	or     %edx,%edi
  801003:	89 f2                	mov    %esi,%edx
  801005:	89 f8                	mov    %edi,%eax
  801007:	f7 75 ec             	divl   -0x14(%ebp)
  80100a:	89 d6                	mov    %edx,%esi
  80100c:	89 c7                	mov    %eax,%edi
  80100e:	f7 65 e8             	mull   -0x18(%ebp)
  801011:	39 d6                	cmp    %edx,%esi
  801013:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801016:	72 30                	jb     801048 <__udivdi3+0x118>
  801018:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80101b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80101f:	d3 e2                	shl    %cl,%edx
  801021:	39 c2                	cmp    %eax,%edx
  801023:	73 05                	jae    80102a <__udivdi3+0xfa>
  801025:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801028:	74 1e                	je     801048 <__udivdi3+0x118>
  80102a:	89 f9                	mov    %edi,%ecx
  80102c:	31 ff                	xor    %edi,%edi
  80102e:	e9 71 ff ff ff       	jmp    800fa4 <__udivdi3+0x74>
  801033:	90                   	nop
  801034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801038:	31 ff                	xor    %edi,%edi
  80103a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80103f:	e9 60 ff ff ff       	jmp    800fa4 <__udivdi3+0x74>
  801044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801048:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80104b:	31 ff                	xor    %edi,%edi
  80104d:	89 c8                	mov    %ecx,%eax
  80104f:	89 fa                	mov    %edi,%edx
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    
	...

00801060 <__umoddi3>:
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	83 ec 20             	sub    $0x20,%esp
  801068:	8b 55 14             	mov    0x14(%ebp),%edx
  80106b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801071:	8b 75 0c             	mov    0xc(%ebp),%esi
  801074:	85 d2                	test   %edx,%edx
  801076:	89 c8                	mov    %ecx,%eax
  801078:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80107b:	75 13                	jne    801090 <__umoddi3+0x30>
  80107d:	39 f7                	cmp    %esi,%edi
  80107f:	76 3f                	jbe    8010c0 <__umoddi3+0x60>
  801081:	89 f2                	mov    %esi,%edx
  801083:	f7 f7                	div    %edi
  801085:	89 d0                	mov    %edx,%eax
  801087:	31 d2                	xor    %edx,%edx
  801089:	83 c4 20             	add    $0x20,%esp
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    
  801090:	39 f2                	cmp    %esi,%edx
  801092:	77 4c                	ja     8010e0 <__umoddi3+0x80>
  801094:	0f bd ca             	bsr    %edx,%ecx
  801097:	83 f1 1f             	xor    $0x1f,%ecx
  80109a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80109d:	75 51                	jne    8010f0 <__umoddi3+0x90>
  80109f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8010a2:	0f 87 e0 00 00 00    	ja     801188 <__umoddi3+0x128>
  8010a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ab:	29 f8                	sub    %edi,%eax
  8010ad:	19 d6                	sbb    %edx,%esi
  8010af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b5:	89 f2                	mov    %esi,%edx
  8010b7:	83 c4 20             	add    $0x20,%esp
  8010ba:	5e                   	pop    %esi
  8010bb:	5f                   	pop    %edi
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    
  8010be:	66 90                	xchg   %ax,%ax
  8010c0:	85 ff                	test   %edi,%edi
  8010c2:	75 0b                	jne    8010cf <__umoddi3+0x6f>
  8010c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c9:	31 d2                	xor    %edx,%edx
  8010cb:	f7 f7                	div    %edi
  8010cd:	89 c7                	mov    %eax,%edi
  8010cf:	89 f0                	mov    %esi,%eax
  8010d1:	31 d2                	xor    %edx,%edx
  8010d3:	f7 f7                	div    %edi
  8010d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010d8:	f7 f7                	div    %edi
  8010da:	eb a9                	jmp    801085 <__umoddi3+0x25>
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	89 c8                	mov    %ecx,%eax
  8010e2:	89 f2                	mov    %esi,%edx
  8010e4:	83 c4 20             	add    $0x20,%esp
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    
  8010eb:	90                   	nop
  8010ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010f4:	d3 e2                	shl    %cl,%edx
  8010f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010f9:	ba 20 00 00 00       	mov    $0x20,%edx
  8010fe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801101:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801104:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801108:	89 fa                	mov    %edi,%edx
  80110a:	d3 ea                	shr    %cl,%edx
  80110c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801110:	0b 55 f4             	or     -0xc(%ebp),%edx
  801113:	d3 e7                	shl    %cl,%edi
  801115:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801119:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80111c:	89 f2                	mov    %esi,%edx
  80111e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801121:	89 c7                	mov    %eax,%edi
  801123:	d3 ea                	shr    %cl,%edx
  801125:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801129:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	d3 e6                	shl    %cl,%esi
  801130:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801134:	d3 ea                	shr    %cl,%edx
  801136:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80113a:	09 d6                	or     %edx,%esi
  80113c:	89 f0                	mov    %esi,%eax
  80113e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801141:	d3 e7                	shl    %cl,%edi
  801143:	89 f2                	mov    %esi,%edx
  801145:	f7 75 f4             	divl   -0xc(%ebp)
  801148:	89 d6                	mov    %edx,%esi
  80114a:	f7 65 e8             	mull   -0x18(%ebp)
  80114d:	39 d6                	cmp    %edx,%esi
  80114f:	72 2b                	jb     80117c <__umoddi3+0x11c>
  801151:	39 c7                	cmp    %eax,%edi
  801153:	72 23                	jb     801178 <__umoddi3+0x118>
  801155:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801159:	29 c7                	sub    %eax,%edi
  80115b:	19 d6                	sbb    %edx,%esi
  80115d:	89 f0                	mov    %esi,%eax
  80115f:	89 f2                	mov    %esi,%edx
  801161:	d3 ef                	shr    %cl,%edi
  801163:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801167:	d3 e0                	shl    %cl,%eax
  801169:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80116d:	09 f8                	or     %edi,%eax
  80116f:	d3 ea                	shr    %cl,%edx
  801171:	83 c4 20             	add    $0x20,%esp
  801174:	5e                   	pop    %esi
  801175:	5f                   	pop    %edi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    
  801178:	39 d6                	cmp    %edx,%esi
  80117a:	75 d9                	jne    801155 <__umoddi3+0xf5>
  80117c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80117f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801182:	eb d1                	jmp    801155 <__umoddi3+0xf5>
  801184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801188:	39 f2                	cmp    %esi,%edx
  80118a:	0f 82 18 ff ff ff    	jb     8010a8 <__umoddi3+0x48>
  801190:	e9 1d ff ff ff       	jmp    8010b2 <__umoddi3+0x52>
