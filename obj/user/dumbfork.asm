
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 0b 02 00 00       	call   80023c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	DUMBFORKDEBUG("enter the duppage\n");
	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 4c 0f 00 00       	call   800fa2 <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 80 13 80 	movl   $0x801380,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 93 13 80 00 	movl   $0x801393,(%esp)
  800075:	e8 26 02 00 00       	call   8002a0 <_panic>
	
	DUMBFORKDEBUG("duppage:after sys_page_alloc\n");

	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 a6 0e 00 00       	call   800f44 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 a3 13 80 	movl   $0x8013a3,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 93 13 80 00 	movl   $0x801393,(%esp)
  8000bd:	e8 de 01 00 00       	call   8002a0 <_panic>


	DUMBFORKDEBUG("duppage:after sys_page_map \n");

	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 96 0a 00 00       	call   800b70 <memmove>


	DUMBFORKDEBUG("duppage:after memmove\n");

	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 f8 0d 00 00       	call   800ee6 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 b4 13 80 	movl   $0x8013b4,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 93 13 80 00 	movl   $0x801393,(%esp)
  80010d:	e8 8e 01 00 00       	call   8002a0 <_panic>

	DUMBFORKDEBUG("duppage:after sys_page_unmap\n");
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	53                   	push   %ebx
  80011d:	83 ec 24             	sub    $0x24,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800120:	bb 07 00 00 00       	mov    $0x7,%ebx
  800125:	89 d8                	mov    %ebx,%eax
  800127:	cd 30                	int    $0x30
  800129:	89 c3                	mov    %eax,%ebx
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	DUMBFORKDEBUG("dumbfork: after sys_exofork\n");

	if (envid < 0)
  80012b:	85 c0                	test   %eax,%eax
  80012d:	79 20                	jns    80014f <dumbfork+0x36>
		panic("sys_exofork: %e", envid);
  80012f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800133:	c7 44 24 08 c7 13 80 	movl   $0x8013c7,0x8(%esp)
  80013a:	00 
  80013b:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  800142:	00 
  800143:	c7 04 24 93 13 80 00 	movl   $0x801393,(%esp)
  80014a:	e8 51 01 00 00       	call   8002a0 <_panic>
	if (envid == 0) {
  80014f:	85 c0                	test   %eax,%eax
  800151:	75 19                	jne    80016c <dumbfork+0x53>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		DUMBFORKDEBUG("Child envid: %d\n",sys_getenvid());
		thisenv = &envs[ENVX(sys_getenvid())];
  800153:	e8 dd 0e 00 00       	call   801035 <sys_getenvid>
  800158:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800160:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800165:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80016a:	eb 6e                	jmp    8001da <dumbfork+0xc1>
	DUMBFORKDEBUG("Parent envid: %d\n",sys_getenvid());

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80016c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800173:	eb 13                	jmp    800188 <dumbfork+0x6f>
		duppage(envid, addr);
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	89 1c 24             	mov    %ebx,(%esp)
  80017c:	e8 b3 fe ff ff       	call   800034 <duppage>
	DUMBFORKDEBUG("Parent envid: %d\n",sys_getenvid());

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800181:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80018b:	3d 08 20 80 00       	cmp    $0x802008,%eax
  800190:	72 e3                	jb     800175 <dumbfork+0x5c>
		duppage(envid, addr);


	DUMBFORKDEBUG("Parent after duppage the entire address space\n");
	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800192:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800195:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80019a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019e:	89 1c 24             	mov    %ebx,(%esp)
  8001a1:	e8 8e fe ff ff       	call   800034 <duppage>

	DUMBFORKDEBUG("Parent after duppage the stack we are currently on\n");

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001a6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001ad:	00 
  8001ae:	89 1c 24             	mov    %ebx,(%esp)
  8001b1:	e8 d2 0c 00 00       	call   800e88 <sys_env_set_status>
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	79 20                	jns    8001da <dumbfork+0xc1>
		panic("sys_env_set_status: %e", r);
  8001ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001be:	c7 44 24 08 d7 13 80 	movl   $0x8013d7,0x8(%esp)
  8001c5:	00 
  8001c6:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  8001cd:	00 
  8001ce:	c7 04 24 93 13 80 00 	movl   $0x801393,(%esp)
  8001d5:	e8 c6 00 00 00       	call   8002a0 <_panic>

	DUMBFORKDEBUG("Parent start the child environment running\n");

	return envid;
}
  8001da:	89 d8                	mov    %ebx,%eax
  8001dc:	83 c4 24             	add    $0x24,%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    

008001e2 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	57                   	push   %edi
  8001e6:	56                   	push   %esi
  8001e7:	53                   	push   %ebx
  8001e8:	83 ec 1c             	sub    $0x1c,%esp


	DUMBFORKDEBUG("ready to fork a child process\n");
	DUMBFORKDEBUG("parent's envid: %d\n",sys_getenvid());
	// fork a child process
	who = dumbfork();
  8001eb:	e8 29 ff ff ff       	call   800119 <dumbfork>
  8001f0:	89 c6                	mov    %eax,%esi
  8001f2:	bb 00 00 00 00       	mov    $0x0,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001f7:	bf f4 13 80 00       	mov    $0x8013f4,%edi
	DUMBFORKDEBUG("parent's envid: %d\n",sys_getenvid());
	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001fc:	eb 27                	jmp    800225 <umain+0x43>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001fe:	89 f8                	mov    %edi,%eax
  800200:	85 f6                	test   %esi,%esi
  800202:	75 05                	jne    800209 <umain+0x27>
  800204:	b8 ee 13 80 00       	mov    $0x8013ee,%eax
  800209:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800211:	c7 04 24 fb 13 80 00 	movl   $0x8013fb,(%esp)
  800218:	e8 3c 01 00 00       	call   800359 <cprintf>
		sys_yield();
  80021d:	e8 df 0d 00 00       	call   801001 <sys_yield>
	DUMBFORKDEBUG("parent's envid: %d\n",sys_getenvid());
	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800222:	83 c3 01             	add    $0x1,%ebx
  800225:	83 fe 01             	cmp    $0x1,%esi
  800228:	19 c0                	sbb    %eax,%eax
  80022a:	83 e0 0a             	and    $0xa,%eax
  80022d:	83 c0 0a             	add    $0xa,%eax
  800230:	39 c3                	cmp    %eax,%ebx
  800232:	7c ca                	jl     8001fe <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800234:	83 c4 1c             	add    $0x1c,%esp
  800237:	5b                   	pop    %ebx
  800238:	5e                   	pop    %esi
  800239:	5f                   	pop    %edi
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 18             	sub    $0x18,%esp
  800242:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800245:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800248:	8b 75 08             	mov    0x8(%ebp),%esi
  80024b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  80024e:	e8 e2 0d 00 00       	call   801035 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  800253:	25 ff 03 00 00       	and    $0x3ff,%eax
  800258:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80025b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800260:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800265:	85 f6                	test   %esi,%esi
  800267:	7e 07                	jle    800270 <libmain+0x34>
		binaryname = argv[0];
  800269:	8b 03                	mov    (%ebx),%eax
  80026b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800270:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800274:	89 34 24             	mov    %esi,(%esp)
  800277:	e8 66 ff ff ff       	call   8001e2 <umain>

	// exit gracefully
	exit();
  80027c:	e8 0b 00 00 00       	call   80028c <exit>
}
  800281:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800284:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800287:	89 ec                	mov    %ebp,%esp
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    
	...

0080028c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800292:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800299:	e8 cb 0d 00 00       	call   801069 <sys_env_destroy>
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8002a8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ab:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002b1:	e8 7f 0d 00 00       	call   801035 <sys_getenvid>
  8002b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cc:	c7 04 24 18 14 80 00 	movl   $0x801418,(%esp)
  8002d3:	e8 81 00 00 00       	call   800359 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	89 04 24             	mov    %eax,(%esp)
  8002e2:	e8 11 00 00 00       	call   8002f8 <vcprintf>
	cprintf("\n");
  8002e7:	c7 04 24 0b 14 80 00 	movl   $0x80140b,(%esp)
  8002ee:	e8 66 00 00 00       	call   800359 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002f3:	cc                   	int3   
  8002f4:	eb fd                	jmp    8002f3 <_panic+0x53>
	...

008002f8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800301:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800308:	00 00 00 
	b.cnt = 0;
  80030b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800312:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
  800318:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80031c:	8b 45 08             	mov    0x8(%ebp),%eax
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800329:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032d:	c7 04 24 73 03 80 00 	movl   $0x800373,(%esp)
  800334:	e8 c6 01 00 00       	call   8004ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800339:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80033f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800343:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800349:	89 04 24             	mov    %eax,(%esp)
  80034c:	e8 ff 09 00 00       	call   800d50 <sys_cputs>

	return b.cnt;
}
  800351:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800357:	c9                   	leave  
  800358:	c3                   	ret    

00800359 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80035f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800362:	89 44 24 04          	mov    %eax,0x4(%esp)
  800366:	8b 45 08             	mov    0x8(%ebp),%eax
  800369:	89 04 24             	mov    %eax,(%esp)
  80036c:	e8 87 ff ff ff       	call   8002f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800371:	c9                   	leave  
  800372:	c3                   	ret    

00800373 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	53                   	push   %ebx
  800377:	83 ec 14             	sub    $0x14,%esp
  80037a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80037d:	8b 03                	mov    (%ebx),%eax
  80037f:	8b 55 08             	mov    0x8(%ebp),%edx
  800382:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800386:	83 c0 01             	add    $0x1,%eax
  800389:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80038b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800390:	75 19                	jne    8003ab <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800392:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800399:	00 
  80039a:	8d 43 08             	lea    0x8(%ebx),%eax
  80039d:	89 04 24             	mov    %eax,(%esp)
  8003a0:	e8 ab 09 00 00       	call   800d50 <sys_cputs>
		b->idx = 0;
  8003a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003af:	83 c4 14             	add    $0x14,%esp
  8003b2:	5b                   	pop    %ebx
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    
	...

008003c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	57                   	push   %edi
  8003c4:	56                   	push   %esi
  8003c5:	53                   	push   %ebx
  8003c6:	83 ec 4c             	sub    $0x4c,%esp
  8003c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003cc:	89 d6                	mov    %edx,%esi
  8003ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003da:	8b 45 10             	mov    0x10(%ebp),%eax
  8003dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003eb:	39 d1                	cmp    %edx,%ecx
  8003ed:	72 07                	jb     8003f6 <printnum+0x36>
  8003ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003f2:	39 d0                	cmp    %edx,%eax
  8003f4:	77 69                	ja     80045f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8003fa:	83 eb 01             	sub    $0x1,%ebx
  8003fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800401:	89 44 24 08          	mov    %eax,0x8(%esp)
  800405:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800409:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80040d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800410:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800413:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800416:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80041a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800421:	00 
  800422:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800425:	89 04 24             	mov    %eax,(%esp)
  800428:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80042b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80042f:	e8 cc 0c 00 00       	call   801100 <__udivdi3>
  800434:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800437:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80043a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80043e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800442:	89 04 24             	mov    %eax,(%esp)
  800445:	89 54 24 04          	mov    %edx,0x4(%esp)
  800449:	89 f2                	mov    %esi,%edx
  80044b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80044e:	e8 6d ff ff ff       	call   8003c0 <printnum>
  800453:	eb 11                	jmp    800466 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800455:	89 74 24 04          	mov    %esi,0x4(%esp)
  800459:	89 3c 24             	mov    %edi,(%esp)
  80045c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80045f:	83 eb 01             	sub    $0x1,%ebx
  800462:	85 db                	test   %ebx,%ebx
  800464:	7f ef                	jg     800455 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800466:	89 74 24 04          	mov    %esi,0x4(%esp)
  80046a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80046e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800471:	89 44 24 08          	mov    %eax,0x8(%esp)
  800475:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80047c:	00 
  80047d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800480:	89 14 24             	mov    %edx,(%esp)
  800483:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800486:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80048a:	e8 a1 0d 00 00       	call   801230 <__umoddi3>
  80048f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800493:	0f be 80 3b 14 80 00 	movsbl 0x80143b(%eax),%eax
  80049a:	89 04 24             	mov    %eax,(%esp)
  80049d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004a0:	83 c4 4c             	add    $0x4c,%esp
  8004a3:	5b                   	pop    %ebx
  8004a4:	5e                   	pop    %esi
  8004a5:	5f                   	pop    %edi
  8004a6:	5d                   	pop    %ebp
  8004a7:	c3                   	ret    

008004a8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004ab:	83 fa 01             	cmp    $0x1,%edx
  8004ae:	7e 0e                	jle    8004be <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b0:	8b 10                	mov    (%eax),%edx
  8004b2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004b5:	89 08                	mov    %ecx,(%eax)
  8004b7:	8b 02                	mov    (%edx),%eax
  8004b9:	8b 52 04             	mov    0x4(%edx),%edx
  8004bc:	eb 22                	jmp    8004e0 <getuint+0x38>
	else if (lflag)
  8004be:	85 d2                	test   %edx,%edx
  8004c0:	74 10                	je     8004d2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d0:	eb 0e                	jmp    8004e0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d2:	8b 10                	mov    (%eax),%edx
  8004d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d7:	89 08                	mov    %ecx,(%eax)
  8004d9:	8b 02                	mov    (%edx),%eax
  8004db:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e0:	5d                   	pop    %ebp
  8004e1:	c3                   	ret    

008004e2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ec:	8b 10                	mov    (%eax),%edx
  8004ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f1:	73 0a                	jae    8004fd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004f6:	88 0a                	mov    %cl,(%edx)
  8004f8:	83 c2 01             	add    $0x1,%edx
  8004fb:	89 10                	mov    %edx,(%eax)
}
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	57                   	push   %edi
  800503:	56                   	push   %esi
  800504:	53                   	push   %ebx
  800505:	83 ec 4c             	sub    $0x4c,%esp
  800508:	8b 7d 08             	mov    0x8(%ebp),%edi
  80050b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80050e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800511:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800518:	eb 11                	jmp    80052b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80051a:	85 c0                	test   %eax,%eax
  80051c:	0f 84 b0 03 00 00    	je     8008d2 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800522:	89 74 24 04          	mov    %esi,0x4(%esp)
  800526:	89 04 24             	mov    %eax,(%esp)
  800529:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052b:	0f b6 03             	movzbl (%ebx),%eax
  80052e:	83 c3 01             	add    $0x1,%ebx
  800531:	83 f8 25             	cmp    $0x25,%eax
  800534:	75 e4                	jne    80051a <vprintfmt+0x1b>
  800536:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80053d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800542:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800546:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80054d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800554:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800557:	eb 06                	jmp    80055f <vprintfmt+0x60>
  800559:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80055d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	0f b6 0b             	movzbl (%ebx),%ecx
  800562:	0f b6 c1             	movzbl %cl,%eax
  800565:	8d 53 01             	lea    0x1(%ebx),%edx
  800568:	83 e9 23             	sub    $0x23,%ecx
  80056b:	80 f9 55             	cmp    $0x55,%cl
  80056e:	0f 87 41 03 00 00    	ja     8008b5 <vprintfmt+0x3b6>
  800574:	0f b6 c9             	movzbl %cl,%ecx
  800577:	ff 24 8d 00 15 80 00 	jmp    *0x801500(,%ecx,4)
  80057e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800582:	eb d9                	jmp    80055d <vprintfmt+0x5e>
  800584:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80058b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800590:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800593:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800597:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80059a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80059d:	83 fb 09             	cmp    $0x9,%ebx
  8005a0:	77 2b                	ja     8005cd <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005a2:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005a5:	eb e9                	jmp    800590 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 48 04             	lea    0x4(%eax),%ecx
  8005ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005b0:	8b 00                	mov    (%eax),%eax
  8005b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  8005b5:	eb 19                	jmp    8005d0 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  8005b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005ba:	c1 f8 1f             	sar    $0x1f,%eax
  8005bd:	f7 d0                	not    %eax
  8005bf:	21 45 e4             	and    %eax,-0x1c(%ebp)
  8005c2:	eb 99                	jmp    80055d <vprintfmt+0x5e>
  8005c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8005cb:	eb 90                	jmp    80055d <vprintfmt+0x5e>
  8005cd:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  8005d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d4:	79 87                	jns    80055d <vprintfmt+0x5e>
  8005d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005dc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005df:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005e2:	e9 76 ff ff ff       	jmp    80055d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005eb:	e9 6d ff ff ff       	jmp    80055d <vprintfmt+0x5e>
  8005f0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 04 24             	mov    %eax,(%esp)
  800605:	ff d7                	call   *%edi
  800607:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80060a:	e9 1c ff ff ff       	jmp    80052b <vprintfmt+0x2c>
  80060f:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	89 c2                	mov    %eax,%edx
  80061f:	c1 fa 1f             	sar    $0x1f,%edx
  800622:	31 d0                	xor    %edx,%eax
  800624:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800626:	83 f8 09             	cmp    $0x9,%eax
  800629:	7f 0b                	jg     800636 <vprintfmt+0x137>
  80062b:	8b 14 85 60 16 80 00 	mov    0x801660(,%eax,4),%edx
  800632:	85 d2                	test   %edx,%edx
  800634:	75 20                	jne    800656 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800636:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80063a:	c7 44 24 08 4c 14 80 	movl   $0x80144c,0x8(%esp)
  800641:	00 
  800642:	89 74 24 04          	mov    %esi,0x4(%esp)
  800646:	89 3c 24             	mov    %edi,(%esp)
  800649:	e8 0c 03 00 00       	call   80095a <printfmt>
  80064e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800651:	e9 d5 fe ff ff       	jmp    80052b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800656:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80065a:	c7 44 24 08 55 14 80 	movl   $0x801455,0x8(%esp)
  800661:	00 
  800662:	89 74 24 04          	mov    %esi,0x4(%esp)
  800666:	89 3c 24             	mov    %edi,(%esp)
  800669:	e8 ec 02 00 00       	call   80095a <printfmt>
  80066e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800671:	e9 b5 fe ff ff       	jmp    80052b <vprintfmt+0x2c>
  800676:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800679:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80067c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80067f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 04             	lea    0x4(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 18                	mov    (%eax),%ebx
  80068d:	85 db                	test   %ebx,%ebx
  80068f:	75 05                	jne    800696 <vprintfmt+0x197>
  800691:	bb 58 14 80 00       	mov    $0x801458,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800696:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80069a:	7e 76                	jle    800712 <vprintfmt+0x213>
  80069c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8006a0:	74 7a                	je     80071c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006a6:	89 1c 24             	mov    %ebx,(%esp)
  8006a9:	e8 fa 02 00 00       	call   8009a8 <strnlen>
  8006ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b1:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  8006b3:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8006b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006ba:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8006bd:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bf:	eb 0f                	jmp    8006d0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006c8:	89 04 24             	mov    %eax,(%esp)
  8006cb:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cd:	83 eb 01             	sub    $0x1,%ebx
  8006d0:	85 db                	test   %ebx,%ebx
  8006d2:	7f ed                	jg     8006c1 <vprintfmt+0x1c2>
  8006d4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8006d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006da:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8006dd:	89 f7                	mov    %esi,%edi
  8006df:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006e2:	eb 40                	jmp    800724 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e8:	74 18                	je     800702 <vprintfmt+0x203>
  8006ea:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006ed:	83 fa 5e             	cmp    $0x5e,%edx
  8006f0:	76 10                	jbe    800702 <vprintfmt+0x203>
					putch('?', putdat);
  8006f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006fd:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800700:	eb 0a                	jmp    80070c <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800702:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800706:	89 04 24             	mov    %eax,(%esp)
  800709:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800710:	eb 12                	jmp    800724 <vprintfmt+0x225>
  800712:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800715:	89 f7                	mov    %esi,%edi
  800717:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80071a:	eb 08                	jmp    800724 <vprintfmt+0x225>
  80071c:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80071f:	89 f7                	mov    %esi,%edi
  800721:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800724:	0f be 03             	movsbl (%ebx),%eax
  800727:	83 c3 01             	add    $0x1,%ebx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	74 25                	je     800753 <vprintfmt+0x254>
  80072e:	85 f6                	test   %esi,%esi
  800730:	78 b2                	js     8006e4 <vprintfmt+0x1e5>
  800732:	83 ee 01             	sub    $0x1,%esi
  800735:	79 ad                	jns    8006e4 <vprintfmt+0x1e5>
  800737:	89 fe                	mov    %edi,%esi
  800739:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80073c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80073f:	eb 1a                	jmp    80075b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800741:	89 74 24 04          	mov    %esi,0x4(%esp)
  800745:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80074c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074e:	83 eb 01             	sub    $0x1,%ebx
  800751:	eb 08                	jmp    80075b <vprintfmt+0x25c>
  800753:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800756:	89 fe                	mov    %edi,%esi
  800758:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80075b:	85 db                	test   %ebx,%ebx
  80075d:	7f e2                	jg     800741 <vprintfmt+0x242>
  80075f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800762:	e9 c4 fd ff ff       	jmp    80052b <vprintfmt+0x2c>
  800767:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80076a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80076d:	83 f9 01             	cmp    $0x1,%ecx
  800770:	7e 16                	jle    800788 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 08             	lea    0x8(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	8b 48 04             	mov    0x4(%eax),%ecx
  800780:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800783:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800786:	eb 32                	jmp    8007ba <vprintfmt+0x2bb>
	else if (lflag)
  800788:	85 c9                	test   %ecx,%ecx
  80078a:	74 18                	je     8007a4 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	8d 50 04             	lea    0x4(%eax),%edx
  800792:	89 55 14             	mov    %edx,0x14(%ebp)
  800795:	8b 00                	mov    (%eax),%eax
  800797:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079a:	89 c1                	mov    %eax,%ecx
  80079c:	c1 f9 1f             	sar    $0x1f,%ecx
  80079f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a2:	eb 16                	jmp    8007ba <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8d 50 04             	lea    0x4(%eax),%edx
  8007aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ad:	8b 00                	mov    (%eax),%eax
  8007af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b2:	89 c2                	mov    %eax,%edx
  8007b4:	c1 fa 1f             	sar    $0x1f,%edx
  8007b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ba:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8007bd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007c0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007c5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007c9:	0f 89 a7 00 00 00    	jns    800876 <vprintfmt+0x377>
				putch('-', putdat);
  8007cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007da:	ff d7                	call   *%edi
				num = -(long long) num;
  8007dc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8007df:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8007e2:	f7 d9                	neg    %ecx
  8007e4:	83 d3 00             	adc    $0x0,%ebx
  8007e7:	f7 db                	neg    %ebx
  8007e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ee:	e9 83 00 00 00       	jmp    800876 <vprintfmt+0x377>
  8007f3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8007f6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f9:	89 ca                	mov    %ecx,%edx
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fe:	e8 a5 fc ff ff       	call   8004a8 <getuint>
  800803:	89 c1                	mov    %eax,%ecx
  800805:	89 d3                	mov    %edx,%ebx
  800807:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80080c:	eb 68                	jmp    800876 <vprintfmt+0x377>
  80080e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800811:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800814:	89 ca                	mov    %ecx,%edx
  800816:	8d 45 14             	lea    0x14(%ebp),%eax
  800819:	e8 8a fc ff ff       	call   8004a8 <getuint>
  80081e:	89 c1                	mov    %eax,%ecx
  800820:	89 d3                	mov    %edx,%ebx
  800822:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800827:	eb 4d                	jmp    800876 <vprintfmt+0x377>
  800829:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80082c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800830:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800837:	ff d7                	call   *%edi
			putch('x', putdat);
  800839:	89 74 24 04          	mov    %esi,0x4(%esp)
  80083d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800844:	ff d7                	call   *%edi
			num = (unsigned long long)
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8d 50 04             	lea    0x4(%eax),%edx
  80084c:	89 55 14             	mov    %edx,0x14(%ebp)
  80084f:	8b 08                	mov    (%eax),%ecx
  800851:	bb 00 00 00 00       	mov    $0x0,%ebx
  800856:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80085b:	eb 19                	jmp    800876 <vprintfmt+0x377>
  80085d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800860:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800863:	89 ca                	mov    %ecx,%edx
  800865:	8d 45 14             	lea    0x14(%ebp),%eax
  800868:	e8 3b fc ff ff       	call   8004a8 <getuint>
  80086d:	89 c1                	mov    %eax,%ecx
  80086f:	89 d3                	mov    %edx,%ebx
  800871:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800876:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80087a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80087e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800881:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800885:	89 44 24 08          	mov    %eax,0x8(%esp)
  800889:	89 0c 24             	mov    %ecx,(%esp)
  80088c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800890:	89 f2                	mov    %esi,%edx
  800892:	89 f8                	mov    %edi,%eax
  800894:	e8 27 fb ff ff       	call   8003c0 <printnum>
  800899:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80089c:	e9 8a fc ff ff       	jmp    80052b <vprintfmt+0x2c>
  8008a1:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a8:	89 04 24             	mov    %eax,(%esp)
  8008ab:	ff d7                	call   *%edi
  8008ad:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8008b0:	e9 76 fc ff ff       	jmp    80052b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008c0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8008c5:	80 38 25             	cmpb   $0x25,(%eax)
  8008c8:	0f 84 5d fc ff ff    	je     80052b <vprintfmt+0x2c>
  8008ce:	89 c3                	mov    %eax,%ebx
  8008d0:	eb f0                	jmp    8008c2 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  8008d2:	83 c4 4c             	add    $0x4c,%esp
  8008d5:	5b                   	pop    %ebx
  8008d6:	5e                   	pop    %esi
  8008d7:	5f                   	pop    %edi
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	83 ec 28             	sub    $0x28,%esp
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	74 04                	je     8008ee <vsnprintf+0x14>
  8008ea:	85 d2                	test   %edx,%edx
  8008ec:	7f 07                	jg     8008f5 <vsnprintf+0x1b>
  8008ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f3:	eb 3b                	jmp    800930 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090d:	8b 45 10             	mov    0x10(%ebp),%eax
  800910:	89 44 24 08          	mov    %eax,0x8(%esp)
  800914:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091b:	c7 04 24 e2 04 80 00 	movl   $0x8004e2,(%esp)
  800922:	e8 d8 fb ff ff       	call   8004ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800927:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800938:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80093b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093f:	8b 45 10             	mov    0x10(%ebp),%eax
  800942:	89 44 24 08          	mov    %eax,0x8(%esp)
  800946:	8b 45 0c             	mov    0xc(%ebp),%eax
  800949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	89 04 24             	mov    %eax,(%esp)
  800953:	e8 82 ff ff ff       	call   8008da <vsnprintf>
	va_end(ap);

	return rc;
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800960:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800963:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800967:	8b 45 10             	mov    0x10(%ebp),%eax
  80096a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	89 44 24 04          	mov    %eax,0x4(%esp)
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	89 04 24             	mov    %eax,(%esp)
  80097b:	e8 7f fb ff ff       	call   8004ff <vprintfmt>
	va_end(ap);
}
  800980:	c9                   	leave  
  800981:	c3                   	ret    
	...

00800990 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	8b 55 08             	mov    0x8(%ebp),%edx
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  80099b:	eb 03                	jmp    8009a0 <strlen+0x10>
		n++;
  80099d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009a4:	75 f7                	jne    80099d <strlen+0xd>
		n++;
	return n;
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	53                   	push   %ebx
  8009ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b7:	eb 03                	jmp    8009bc <strnlen+0x14>
		n++;
  8009b9:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009bc:	39 c1                	cmp    %eax,%ecx
  8009be:	74 06                	je     8009c6 <strnlen+0x1e>
  8009c0:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8009c4:	75 f3                	jne    8009b9 <strnlen+0x11>
		n++;
	return n;
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	53                   	push   %ebx
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009d3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009d8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009dc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009df:	83 c2 01             	add    $0x1,%edx
  8009e2:	84 c9                	test   %cl,%cl
  8009e4:	75 f2                	jne    8009d8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009e6:	5b                   	pop    %ebx
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	83 ec 08             	sub    $0x8,%esp
  8009f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f3:	89 1c 24             	mov    %ebx,(%esp)
  8009f6:	e8 95 ff ff ff       	call   800990 <strlen>
	strcpy(dst + len, src);
  8009fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a02:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 bc ff ff ff       	call   8009c9 <strcpy>
	return dst;
}
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	83 c4 08             	add    $0x8,%esp
  800a12:	5b                   	pop    %ebx
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a20:	8b 75 10             	mov    0x10(%ebp),%esi
  800a23:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a28:	eb 0f                	jmp    800a39 <strncpy+0x24>
		*dst++ = *src;
  800a2a:	0f b6 19             	movzbl (%ecx),%ebx
  800a2d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a30:	80 39 01             	cmpb   $0x1,(%ecx)
  800a33:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a36:	83 c2 01             	add    $0x1,%edx
  800a39:	39 f2                	cmp    %esi,%edx
  800a3b:	72 ed                	jb     800a2a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 75 08             	mov    0x8(%ebp),%esi
  800a49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a4f:	89 f0                	mov    %esi,%eax
  800a51:	85 d2                	test   %edx,%edx
  800a53:	75 0a                	jne    800a5f <strlcpy+0x1e>
  800a55:	eb 17                	jmp    800a6e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a57:	88 18                	mov    %bl,(%eax)
  800a59:	83 c0 01             	add    $0x1,%eax
  800a5c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a5f:	83 ea 01             	sub    $0x1,%edx
  800a62:	74 07                	je     800a6b <strlcpy+0x2a>
  800a64:	0f b6 19             	movzbl (%ecx),%ebx
  800a67:	84 db                	test   %bl,%bl
  800a69:	75 ec                	jne    800a57 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  800a6b:	c6 00 00             	movb   $0x0,(%eax)
  800a6e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7d:	eb 06                	jmp    800a85 <strcmp+0x11>
		p++, q++;
  800a7f:	83 c1 01             	add    $0x1,%ecx
  800a82:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a85:	0f b6 01             	movzbl (%ecx),%eax
  800a88:	84 c0                	test   %al,%al
  800a8a:	74 04                	je     800a90 <strcmp+0x1c>
  800a8c:	3a 02                	cmp    (%edx),%al
  800a8e:	74 ef                	je     800a7f <strcmp+0xb>
  800a90:	0f b6 c0             	movzbl %al,%eax
  800a93:	0f b6 12             	movzbl (%edx),%edx
  800a96:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	53                   	push   %ebx
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa4:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800aa7:	eb 09                	jmp    800ab2 <strncmp+0x18>
		n--, p++, q++;
  800aa9:	83 ea 01             	sub    $0x1,%edx
  800aac:	83 c0 01             	add    $0x1,%eax
  800aaf:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ab2:	85 d2                	test   %edx,%edx
  800ab4:	75 07                	jne    800abd <strncmp+0x23>
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	eb 13                	jmp    800ad0 <strncmp+0x36>
  800abd:	0f b6 18             	movzbl (%eax),%ebx
  800ac0:	84 db                	test   %bl,%bl
  800ac2:	74 04                	je     800ac8 <strncmp+0x2e>
  800ac4:	3a 19                	cmp    (%ecx),%bl
  800ac6:	74 e1                	je     800aa9 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac8:	0f b6 00             	movzbl (%eax),%eax
  800acb:	0f b6 11             	movzbl (%ecx),%edx
  800ace:	29 d0                	sub    %edx,%eax
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800add:	eb 07                	jmp    800ae6 <strchr+0x13>
		if (*s == c)
  800adf:	38 ca                	cmp    %cl,%dl
  800ae1:	74 0f                	je     800af2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ae3:	83 c0 01             	add    $0x1,%eax
  800ae6:	0f b6 10             	movzbl (%eax),%edx
  800ae9:	84 d2                	test   %dl,%dl
  800aeb:	75 f2                	jne    800adf <strchr+0xc>
  800aed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	8b 45 08             	mov    0x8(%ebp),%eax
  800afa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800afe:	eb 07                	jmp    800b07 <strfind+0x13>
		if (*s == c)
  800b00:	38 ca                	cmp    %cl,%dl
  800b02:	74 0a                	je     800b0e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b04:	83 c0 01             	add    $0x1,%eax
  800b07:	0f b6 10             	movzbl (%eax),%edx
  800b0a:	84 d2                	test   %dl,%dl
  800b0c:	75 f2                	jne    800b00 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800b0e:	5d                   	pop    %ebp
  800b0f:	90                   	nop
  800b10:	c3                   	ret    

00800b11 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	89 1c 24             	mov    %ebx,(%esp)
  800b1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b22:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b2b:	85 c9                	test   %ecx,%ecx
  800b2d:	74 30                	je     800b5f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b35:	75 25                	jne    800b5c <memset+0x4b>
  800b37:	f6 c1 03             	test   $0x3,%cl
  800b3a:	75 20                	jne    800b5c <memset+0x4b>
		c &= 0xFF;
  800b3c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b3f:	89 d3                	mov    %edx,%ebx
  800b41:	c1 e3 08             	shl    $0x8,%ebx
  800b44:	89 d6                	mov    %edx,%esi
  800b46:	c1 e6 18             	shl    $0x18,%esi
  800b49:	89 d0                	mov    %edx,%eax
  800b4b:	c1 e0 10             	shl    $0x10,%eax
  800b4e:	09 f0                	or     %esi,%eax
  800b50:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b52:	09 d8                	or     %ebx,%eax
  800b54:	c1 e9 02             	shr    $0x2,%ecx
  800b57:	fc                   	cld    
  800b58:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b5a:	eb 03                	jmp    800b5f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b5c:	fc                   	cld    
  800b5d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5f:	89 f8                	mov    %edi,%eax
  800b61:	8b 1c 24             	mov    (%esp),%ebx
  800b64:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b68:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b6c:	89 ec                	mov    %ebp,%esp
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 08             	sub    $0x8,%esp
  800b76:	89 34 24             	mov    %esi,(%esp)
  800b79:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800b83:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b86:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b88:	39 c6                	cmp    %eax,%esi
  800b8a:	73 35                	jae    800bc1 <memmove+0x51>
  800b8c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b8f:	39 d0                	cmp    %edx,%eax
  800b91:	73 2e                	jae    800bc1 <memmove+0x51>
		s += n;
		d += n;
  800b93:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b95:	f6 c2 03             	test   $0x3,%dl
  800b98:	75 1b                	jne    800bb5 <memmove+0x45>
  800b9a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba0:	75 13                	jne    800bb5 <memmove+0x45>
  800ba2:	f6 c1 03             	test   $0x3,%cl
  800ba5:	75 0e                	jne    800bb5 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800ba7:	83 ef 04             	sub    $0x4,%edi
  800baa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bad:	c1 e9 02             	shr    $0x2,%ecx
  800bb0:	fd                   	std    
  800bb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb3:	eb 09                	jmp    800bbe <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bb5:	83 ef 01             	sub    $0x1,%edi
  800bb8:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bbb:	fd                   	std    
  800bbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bbe:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bbf:	eb 20                	jmp    800be1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bc7:	75 15                	jne    800bde <memmove+0x6e>
  800bc9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bcf:	75 0d                	jne    800bde <memmove+0x6e>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 08                	jne    800bde <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800bd6:	c1 e9 02             	shr    $0x2,%ecx
  800bd9:	fc                   	cld    
  800bda:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdc:	eb 03                	jmp    800be1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bde:	fc                   	cld    
  800bdf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be1:	8b 34 24             	mov    (%esp),%esi
  800be4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800be8:	89 ec                	mov    %ebp,%esp
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	89 04 24             	mov    %eax,(%esp)
  800c06:	e8 65 ff ff ff       	call   800b70 <memmove>
}
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	57                   	push   %edi
  800c11:	56                   	push   %esi
  800c12:	53                   	push   %ebx
  800c13:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c19:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800c1c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c21:	eb 1c                	jmp    800c3f <memcmp+0x32>
		if (*s1 != *s2)
  800c23:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800c27:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800c2b:	83 c2 01             	add    $0x1,%edx
  800c2e:	83 e9 01             	sub    $0x1,%ecx
  800c31:	38 d8                	cmp    %bl,%al
  800c33:	74 0a                	je     800c3f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800c35:	0f b6 c0             	movzbl %al,%eax
  800c38:	0f b6 db             	movzbl %bl,%ebx
  800c3b:	29 d8                	sub    %ebx,%eax
  800c3d:	eb 09                	jmp    800c48 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3f:	85 c9                	test   %ecx,%ecx
  800c41:	75 e0                	jne    800c23 <memcmp+0x16>
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c56:	89 c2                	mov    %eax,%edx
  800c58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c5b:	eb 07                	jmp    800c64 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c5d:	38 08                	cmp    %cl,(%eax)
  800c5f:	74 07                	je     800c68 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c61:	83 c0 01             	add    $0x1,%eax
  800c64:	39 d0                	cmp    %edx,%eax
  800c66:	72 f5                	jb     800c5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 04             	sub    $0x4,%esp
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c79:	eb 03                	jmp    800c7e <strtol+0x14>
		s++;
  800c7b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7e:	0f b6 02             	movzbl (%edx),%eax
  800c81:	3c 20                	cmp    $0x20,%al
  800c83:	74 f6                	je     800c7b <strtol+0x11>
  800c85:	3c 09                	cmp    $0x9,%al
  800c87:	74 f2                	je     800c7b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c89:	3c 2b                	cmp    $0x2b,%al
  800c8b:	75 0c                	jne    800c99 <strtol+0x2f>
		s++;
  800c8d:	8d 52 01             	lea    0x1(%edx),%edx
  800c90:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c97:	eb 15                	jmp    800cae <strtol+0x44>
	else if (*s == '-')
  800c99:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ca0:	3c 2d                	cmp    $0x2d,%al
  800ca2:	75 0a                	jne    800cae <strtol+0x44>
		s++, neg = 1;
  800ca4:	8d 52 01             	lea    0x1(%edx),%edx
  800ca7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cae:	85 db                	test   %ebx,%ebx
  800cb0:	0f 94 c0             	sete   %al
  800cb3:	74 05                	je     800cba <strtol+0x50>
  800cb5:	83 fb 10             	cmp    $0x10,%ebx
  800cb8:	75 18                	jne    800cd2 <strtol+0x68>
  800cba:	80 3a 30             	cmpb   $0x30,(%edx)
  800cbd:	75 13                	jne    800cd2 <strtol+0x68>
  800cbf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cc3:	75 0d                	jne    800cd2 <strtol+0x68>
		s += 2, base = 16;
  800cc5:	83 c2 02             	add    $0x2,%edx
  800cc8:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ccd:	8d 76 00             	lea    0x0(%esi),%esi
  800cd0:	eb 13                	jmp    800ce5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd2:	84 c0                	test   %al,%al
  800cd4:	74 0f                	je     800ce5 <strtol+0x7b>
  800cd6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cdb:	80 3a 30             	cmpb   $0x30,(%edx)
  800cde:	75 05                	jne    800ce5 <strtol+0x7b>
		s++, base = 8;
  800ce0:	83 c2 01             	add    $0x1,%edx
  800ce3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cea:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cec:	0f b6 0a             	movzbl (%edx),%ecx
  800cef:	89 cf                	mov    %ecx,%edi
  800cf1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf4:	80 fb 09             	cmp    $0x9,%bl
  800cf7:	77 08                	ja     800d01 <strtol+0x97>
			dig = *s - '0';
  800cf9:	0f be c9             	movsbl %cl,%ecx
  800cfc:	83 e9 30             	sub    $0x30,%ecx
  800cff:	eb 1e                	jmp    800d1f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800d01:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d04:	80 fb 19             	cmp    $0x19,%bl
  800d07:	77 08                	ja     800d11 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800d09:	0f be c9             	movsbl %cl,%ecx
  800d0c:	83 e9 57             	sub    $0x57,%ecx
  800d0f:	eb 0e                	jmp    800d1f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800d11:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d14:	80 fb 19             	cmp    $0x19,%bl
  800d17:	77 15                	ja     800d2e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800d19:	0f be c9             	movsbl %cl,%ecx
  800d1c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d1f:	39 f1                	cmp    %esi,%ecx
  800d21:	7d 0b                	jge    800d2e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800d23:	83 c2 01             	add    $0x1,%edx
  800d26:	0f af c6             	imul   %esi,%eax
  800d29:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d2c:	eb be                	jmp    800cec <strtol+0x82>
  800d2e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d34:	74 05                	je     800d3b <strtol+0xd1>
		*endptr = (char *) s;
  800d36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d39:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d3f:	74 04                	je     800d45 <strtol+0xdb>
  800d41:	89 c8                	mov    %ecx,%eax
  800d43:	f7 d8                	neg    %eax
}
  800d45:	83 c4 04             	add    $0x4,%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    
  800d4d:	00 00                	add    %al,(%eax)
	...

00800d50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 0c             	sub    $0xc,%esp
  800d56:	89 1c 24             	mov    %ebx,(%esp)
  800d59:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d5d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d61:	b8 00 00 00 00       	mov    $0x0,%eax
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6c:	89 c3                	mov    %eax,%ebx
  800d6e:	89 c7                	mov    %eax,%edi
  800d70:	89 c6                	mov    %eax,%esi
  800d72:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d74:	8b 1c 24             	mov    (%esp),%ebx
  800d77:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d7b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d7f:	89 ec                	mov    %ebp,%esp
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	83 ec 38             	sub    $0x38,%esp
  800d89:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800d92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d96:	75 0c                	jne    800da4 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800d98:	c7 04 24 88 16 80 00 	movl   $0x801688,(%esp)
  800d9f:	e8 b5 f5 ff ff       	call   800359 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	b8 09 00 00 00       	mov    $0x9,%eax
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7e 28                	jle    800de6 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dc9:	00 
  800dca:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd9:	00 
  800dda:	c7 04 24 d1 16 80 00 	movl   $0x8016d1,(%esp)
  800de1:	e8 ba f4 ff ff       	call   8002a0 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800de6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800def:	89 ec                	mov    %ebp,%esp
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    

00800df3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800df3:	55                   	push   %ebp
  800df4:	89 e5                	mov    %esp,%ebp
  800df6:	83 ec 38             	sub    $0x38,%esp
  800df9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dfc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e07:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	89 cb                	mov    %ecx,%ebx
  800e11:	89 cf                	mov    %ecx,%edi
  800e13:	89 ce                	mov    %ecx,%esi
  800e15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 28                	jle    800e43 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e26:	00 
  800e27:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e36:	00 
  800e37:	c7 04 24 d1 16 80 00 	movl   $0x8016d1,(%esp)
  800e3e:	e8 5d f4 ff ff       	call   8002a0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e46:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e49:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4c:	89 ec                	mov    %ebp,%esp
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	89 1c 24             	mov    %ebx,(%esp)
  800e59:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e61:	be 00 00 00 00       	mov    $0x0,%esi
  800e66:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e79:	8b 1c 24             	mov    (%esp),%ebx
  800e7c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e80:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e84:	89 ec                	mov    %ebp,%esp
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 38             	sub    $0x38,%esp
  800e8e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e91:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e94:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7e 28                	jle    800ed9 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  800ec4:	00 
  800ec5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ecc:	00 
  800ecd:	c7 04 24 d1 16 80 00 	movl   $0x8016d1,(%esp)
  800ed4:	e8 c7 f3 ff ff       	call   8002a0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800edc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800edf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ee2:	89 ec                	mov    %ebp,%esp
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 38             	sub    $0x38,%esp
  800eec:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eef:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efa:	b8 06 00 00 00       	mov    $0x6,%eax
  800eff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f02:	8b 55 08             	mov    0x8(%ebp),%edx
  800f05:	89 df                	mov    %ebx,%edi
  800f07:	89 de                	mov    %ebx,%esi
  800f09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	7e 28                	jle    800f37 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f13:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f1a:	00 
  800f1b:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  800f22:	00 
  800f23:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2a:	00 
  800f2b:	c7 04 24 d1 16 80 00 	movl   $0x8016d1,(%esp)
  800f32:	e8 69 f3 ff ff       	call   8002a0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f37:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f3a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f40:	89 ec                	mov    %ebp,%esp
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 38             	sub    $0x38,%esp
  800f4a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f4d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f50:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f53:	b8 05 00 00 00       	mov    $0x5,%eax
  800f58:	8b 75 18             	mov    0x18(%ebp),%esi
  800f5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f64:	8b 55 08             	mov    0x8(%ebp),%edx
  800f67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 28                	jle    800f95 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f71:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f78:	00 
  800f79:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 d1 16 80 00 	movl   $0x8016d1,(%esp)
  800f90:	e8 0b f3 ff ff       	call   8002a0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f95:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f98:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f9b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9e:	89 ec                	mov    %ebp,%esp
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 38             	sub    $0x38,%esp
  800fa8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fab:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fae:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb1:	be 00 00 00 00       	mov    $0x0,%esi
  800fb6:	b8 04 00 00 00       	mov    $0x4,%eax
  800fbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc4:	89 f7                	mov    %esi,%edi
  800fc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	7e 28                	jle    800ff4 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  800fdf:	00 
  800fe0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe7:	00 
  800fe8:	c7 04 24 d1 16 80 00 	movl   $0x8016d1,(%esp)
  800fef:	e8 ac f2 ff ff       	call   8002a0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ff4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ffd:	89 ec                	mov    %ebp,%esp
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	89 1c 24             	mov    %ebx,(%esp)
  80100a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801012:	ba 00 00 00 00       	mov    $0x0,%edx
  801017:	b8 0a 00 00 00       	mov    $0xa,%eax
  80101c:	89 d1                	mov    %edx,%ecx
  80101e:	89 d3                	mov    %edx,%ebx
  801020:	89 d7                	mov    %edx,%edi
  801022:	89 d6                	mov    %edx,%esi
  801024:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801026:	8b 1c 24             	mov    (%esp),%ebx
  801029:	8b 74 24 04          	mov    0x4(%esp),%esi
  80102d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801031:	89 ec                	mov    %ebp,%esp
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 0c             	sub    $0xc,%esp
  80103b:	89 1c 24             	mov    %ebx,(%esp)
  80103e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801042:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801046:	ba 00 00 00 00       	mov    $0x0,%edx
  80104b:	b8 02 00 00 00       	mov    $0x2,%eax
  801050:	89 d1                	mov    %edx,%ecx
  801052:	89 d3                	mov    %edx,%ebx
  801054:	89 d7                	mov    %edx,%edi
  801056:	89 d6                	mov    %edx,%esi
  801058:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80105a:	8b 1c 24             	mov    (%esp),%ebx
  80105d:	8b 74 24 04          	mov    0x4(%esp),%esi
  801061:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801065:	89 ec                	mov    %ebp,%esp
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    

00801069 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801069:	55                   	push   %ebp
  80106a:	89 e5                	mov    %esp,%ebp
  80106c:	83 ec 38             	sub    $0x38,%esp
  80106f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801072:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801075:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801078:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107d:	b8 03 00 00 00       	mov    $0x3,%eax
  801082:	8b 55 08             	mov    0x8(%ebp),%edx
  801085:	89 cb                	mov    %ecx,%ebx
  801087:	89 cf                	mov    %ecx,%edi
  801089:	89 ce                	mov    %ecx,%esi
  80108b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80108d:	85 c0                	test   %eax,%eax
  80108f:	7e 28                	jle    8010b9 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801091:	89 44 24 10          	mov    %eax,0x10(%esp)
  801095:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80109c:	00 
  80109d:	c7 44 24 08 b4 16 80 	movl   $0x8016b4,0x8(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ac:	00 
  8010ad:	c7 04 24 d1 16 80 00 	movl   $0x8016d1,(%esp)
  8010b4:	e8 e7 f1 ff ff       	call   8002a0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010b9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010bc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010bf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010c2:	89 ec                	mov    %ebp,%esp
  8010c4:	5d                   	pop    %ebp
  8010c5:	c3                   	ret    

008010c6 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	89 1c 24             	mov    %ebx,(%esp)
  8010cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010d3:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e1:	89 d1                	mov    %edx,%ecx
  8010e3:	89 d3                	mov    %edx,%ebx
  8010e5:	89 d7                	mov    %edx,%edi
  8010e7:	89 d6                	mov    %edx,%esi
  8010e9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010eb:	8b 1c 24             	mov    (%esp),%ebx
  8010ee:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010f2:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010f6:	89 ec                	mov    %ebp,%esp
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    
  8010fa:	00 00                	add    %al,(%eax)
  8010fc:	00 00                	add    %al,(%eax)
	...

00801100 <__udivdi3>:
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	57                   	push   %edi
  801104:	56                   	push   %esi
  801105:	83 ec 10             	sub    $0x10,%esp
  801108:	8b 45 14             	mov    0x14(%ebp),%eax
  80110b:	8b 55 08             	mov    0x8(%ebp),%edx
  80110e:	8b 75 10             	mov    0x10(%ebp),%esi
  801111:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801114:	85 c0                	test   %eax,%eax
  801116:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801119:	75 35                	jne    801150 <__udivdi3+0x50>
  80111b:	39 fe                	cmp    %edi,%esi
  80111d:	77 61                	ja     801180 <__udivdi3+0x80>
  80111f:	85 f6                	test   %esi,%esi
  801121:	75 0b                	jne    80112e <__udivdi3+0x2e>
  801123:	b8 01 00 00 00       	mov    $0x1,%eax
  801128:	31 d2                	xor    %edx,%edx
  80112a:	f7 f6                	div    %esi
  80112c:	89 c6                	mov    %eax,%esi
  80112e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801131:	31 d2                	xor    %edx,%edx
  801133:	89 f8                	mov    %edi,%eax
  801135:	f7 f6                	div    %esi
  801137:	89 c7                	mov    %eax,%edi
  801139:	89 c8                	mov    %ecx,%eax
  80113b:	f7 f6                	div    %esi
  80113d:	89 c1                	mov    %eax,%ecx
  80113f:	89 fa                	mov    %edi,%edx
  801141:	89 c8                	mov    %ecx,%eax
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	5e                   	pop    %esi
  801147:	5f                   	pop    %edi
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    
  80114a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801150:	39 f8                	cmp    %edi,%eax
  801152:	77 1c                	ja     801170 <__udivdi3+0x70>
  801154:	0f bd d0             	bsr    %eax,%edx
  801157:	83 f2 1f             	xor    $0x1f,%edx
  80115a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80115d:	75 39                	jne    801198 <__udivdi3+0x98>
  80115f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801162:	0f 86 a0 00 00 00    	jbe    801208 <__udivdi3+0x108>
  801168:	39 f8                	cmp    %edi,%eax
  80116a:	0f 82 98 00 00 00    	jb     801208 <__udivdi3+0x108>
  801170:	31 ff                	xor    %edi,%edi
  801172:	31 c9                	xor    %ecx,%ecx
  801174:	89 c8                	mov    %ecx,%eax
  801176:	89 fa                	mov    %edi,%edx
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    
  80117f:	90                   	nop
  801180:	89 d1                	mov    %edx,%ecx
  801182:	89 fa                	mov    %edi,%edx
  801184:	89 c8                	mov    %ecx,%eax
  801186:	31 ff                	xor    %edi,%edi
  801188:	f7 f6                	div    %esi
  80118a:	89 c1                	mov    %eax,%ecx
  80118c:	89 fa                	mov    %edi,%edx
  80118e:	89 c8                	mov    %ecx,%eax
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    
  801197:	90                   	nop
  801198:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80119c:	89 f2                	mov    %esi,%edx
  80119e:	d3 e0                	shl    %cl,%eax
  8011a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8011a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8011ab:	89 c1                	mov    %eax,%ecx
  8011ad:	d3 ea                	shr    %cl,%edx
  8011af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8011b6:	d3 e6                	shl    %cl,%esi
  8011b8:	89 c1                	mov    %eax,%ecx
  8011ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8011bd:	89 fe                	mov    %edi,%esi
  8011bf:	d3 ee                	shr    %cl,%esi
  8011c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011cb:	d3 e7                	shl    %cl,%edi
  8011cd:	89 c1                	mov    %eax,%ecx
  8011cf:	d3 ea                	shr    %cl,%edx
  8011d1:	09 d7                	or     %edx,%edi
  8011d3:	89 f2                	mov    %esi,%edx
  8011d5:	89 f8                	mov    %edi,%eax
  8011d7:	f7 75 ec             	divl   -0x14(%ebp)
  8011da:	89 d6                	mov    %edx,%esi
  8011dc:	89 c7                	mov    %eax,%edi
  8011de:	f7 65 e8             	mull   -0x18(%ebp)
  8011e1:	39 d6                	cmp    %edx,%esi
  8011e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011e6:	72 30                	jb     801218 <__udivdi3+0x118>
  8011e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011ef:	d3 e2                	shl    %cl,%edx
  8011f1:	39 c2                	cmp    %eax,%edx
  8011f3:	73 05                	jae    8011fa <__udivdi3+0xfa>
  8011f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8011f8:	74 1e                	je     801218 <__udivdi3+0x118>
  8011fa:	89 f9                	mov    %edi,%ecx
  8011fc:	31 ff                	xor    %edi,%edi
  8011fe:	e9 71 ff ff ff       	jmp    801174 <__udivdi3+0x74>
  801203:	90                   	nop
  801204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801208:	31 ff                	xor    %edi,%edi
  80120a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80120f:	e9 60 ff ff ff       	jmp    801174 <__udivdi3+0x74>
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80121b:	31 ff                	xor    %edi,%edi
  80121d:	89 c8                	mov    %ecx,%eax
  80121f:	89 fa                	mov    %edi,%edx
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
	...

00801230 <__umoddi3>:
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	83 ec 20             	sub    $0x20,%esp
  801238:	8b 55 14             	mov    0x14(%ebp),%edx
  80123b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80123e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801241:	8b 75 0c             	mov    0xc(%ebp),%esi
  801244:	85 d2                	test   %edx,%edx
  801246:	89 c8                	mov    %ecx,%eax
  801248:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80124b:	75 13                	jne    801260 <__umoddi3+0x30>
  80124d:	39 f7                	cmp    %esi,%edi
  80124f:	76 3f                	jbe    801290 <__umoddi3+0x60>
  801251:	89 f2                	mov    %esi,%edx
  801253:	f7 f7                	div    %edi
  801255:	89 d0                	mov    %edx,%eax
  801257:	31 d2                	xor    %edx,%edx
  801259:	83 c4 20             	add    $0x20,%esp
  80125c:	5e                   	pop    %esi
  80125d:	5f                   	pop    %edi
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    
  801260:	39 f2                	cmp    %esi,%edx
  801262:	77 4c                	ja     8012b0 <__umoddi3+0x80>
  801264:	0f bd ca             	bsr    %edx,%ecx
  801267:	83 f1 1f             	xor    $0x1f,%ecx
  80126a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80126d:	75 51                	jne    8012c0 <__umoddi3+0x90>
  80126f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801272:	0f 87 e0 00 00 00    	ja     801358 <__umoddi3+0x128>
  801278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80127b:	29 f8                	sub    %edi,%eax
  80127d:	19 d6                	sbb    %edx,%esi
  80127f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801285:	89 f2                	mov    %esi,%edx
  801287:	83 c4 20             	add    $0x20,%esp
  80128a:	5e                   	pop    %esi
  80128b:	5f                   	pop    %edi
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    
  80128e:	66 90                	xchg   %ax,%ax
  801290:	85 ff                	test   %edi,%edi
  801292:	75 0b                	jne    80129f <__umoddi3+0x6f>
  801294:	b8 01 00 00 00       	mov    $0x1,%eax
  801299:	31 d2                	xor    %edx,%edx
  80129b:	f7 f7                	div    %edi
  80129d:	89 c7                	mov    %eax,%edi
  80129f:	89 f0                	mov    %esi,%eax
  8012a1:	31 d2                	xor    %edx,%edx
  8012a3:	f7 f7                	div    %edi
  8012a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a8:	f7 f7                	div    %edi
  8012aa:	eb a9                	jmp    801255 <__umoddi3+0x25>
  8012ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b0:	89 c8                	mov    %ecx,%eax
  8012b2:	89 f2                	mov    %esi,%edx
  8012b4:	83 c4 20             	add    $0x20,%esp
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    
  8012bb:	90                   	nop
  8012bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012c4:	d3 e2                	shl    %cl,%edx
  8012c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8012ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8012d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012d8:	89 fa                	mov    %edi,%edx
  8012da:	d3 ea                	shr    %cl,%edx
  8012dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8012e3:	d3 e7                	shl    %cl,%edi
  8012e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012ec:	89 f2                	mov    %esi,%edx
  8012ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8012f1:	89 c7                	mov    %eax,%edi
  8012f3:	d3 ea                	shr    %cl,%edx
  8012f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8012fc:	89 c2                	mov    %eax,%edx
  8012fe:	d3 e6                	shl    %cl,%esi
  801300:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801304:	d3 ea                	shr    %cl,%edx
  801306:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80130a:	09 d6                	or     %edx,%esi
  80130c:	89 f0                	mov    %esi,%eax
  80130e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801311:	d3 e7                	shl    %cl,%edi
  801313:	89 f2                	mov    %esi,%edx
  801315:	f7 75 f4             	divl   -0xc(%ebp)
  801318:	89 d6                	mov    %edx,%esi
  80131a:	f7 65 e8             	mull   -0x18(%ebp)
  80131d:	39 d6                	cmp    %edx,%esi
  80131f:	72 2b                	jb     80134c <__umoddi3+0x11c>
  801321:	39 c7                	cmp    %eax,%edi
  801323:	72 23                	jb     801348 <__umoddi3+0x118>
  801325:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801329:	29 c7                	sub    %eax,%edi
  80132b:	19 d6                	sbb    %edx,%esi
  80132d:	89 f0                	mov    %esi,%eax
  80132f:	89 f2                	mov    %esi,%edx
  801331:	d3 ef                	shr    %cl,%edi
  801333:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801337:	d3 e0                	shl    %cl,%eax
  801339:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80133d:	09 f8                	or     %edi,%eax
  80133f:	d3 ea                	shr    %cl,%edx
  801341:	83 c4 20             	add    $0x20,%esp
  801344:	5e                   	pop    %esi
  801345:	5f                   	pop    %edi
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    
  801348:	39 d6                	cmp    %edx,%esi
  80134a:	75 d9                	jne    801325 <__umoddi3+0xf5>
  80134c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80134f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801352:	eb d1                	jmp    801325 <__umoddi3+0xf5>
  801354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801358:	39 f2                	cmp    %esi,%edx
  80135a:	0f 82 18 ff ff ff    	jb     801278 <__umoddi3+0x48>
  801360:	e9 1d ff ff ff       	jmp    801282 <__umoddi3+0x52>
