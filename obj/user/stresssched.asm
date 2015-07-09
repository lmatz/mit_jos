
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 f3 00 00 00       	call   800124 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 c8 0e 00 00       	call   800f15 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
  800054:	e8 d5 10 00 00       	call   80112e <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 05                	jmp    80006c <umain+0x2c>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	75 16                	jne    800082 <umain+0x42>
		sys_yield();
  80006c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800070:	e8 6c 0e 00 00       	call   800ee1 <sys_yield>
		return;
  800075:	e9 a1 00 00 00       	jmp    80011b <umain+0xdb>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  80007a:	f3 90                	pause  
  80007c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800080:	eb 11                	jmp    800093 <umain+0x53>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800082:	89 f2                	mov    %esi,%edx
  800084:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
  80008a:	6b d2 7c             	imul   $0x7c,%edx,%edx
  80008d:	81 c2 54 00 c0 ee    	add    $0xeec00054,%edx
  800093:	8b 02                	mov    (%edx),%eax
  800095:	85 c0                	test   %eax,%eax
  800097:	75 e1                	jne    80007a <umain+0x3a>
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80009e:	be 00 00 00 00       	mov    $0x0,%esi
  8000a3:	e8 39 0e 00 00       	call   800ee1 <sys_yield>
  8000a8:	89 f0                	mov    %esi,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000aa:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000b0:	83 c2 01             	add    $0x1,%edx
  8000b3:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000b9:	83 c0 01             	add    $0x1,%eax
  8000bc:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000c1:	75 e7                	jne    8000aa <umain+0x6a>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000c3:	83 c3 01             	add    $0x1,%ebx
  8000c6:	83 fb 0a             	cmp    $0xa,%ebx
  8000c9:	75 d8                	jne    8000a3 <umain+0x63>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000cb:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d0:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000d5:	74 25                	je     8000fc <umain+0xbc>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d7:	a1 04 20 80 00       	mov    0x802004,%eax
  8000dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e0:	c7 44 24 08 40 16 80 	movl   $0x801640,0x8(%esp)
  8000e7:	00 
  8000e8:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000ef:	00 
  8000f0:	c7 04 24 68 16 80 00 	movl   $0x801668,(%esp)
  8000f7:	e8 8c 00 00 00       	call   800188 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000fc:	a1 08 20 80 00       	mov    0x802008,%eax
  800101:	8b 50 5c             	mov    0x5c(%eax),%edx
  800104:	8b 40 48             	mov    0x48(%eax),%eax
  800107:	89 54 24 08          	mov    %edx,0x8(%esp)
  80010b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010f:	c7 04 24 7b 16 80 00 	movl   $0x80167b,(%esp)
  800116:	e8 26 01 00 00       	call   800241 <cprintf>

}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    
	...

00800124 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 18             	sub    $0x18,%esp
  80012a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80012d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800130:	8b 75 08             	mov    0x8(%ebp),%esi
  800133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  800136:	e8 da 0d 00 00       	call   800f15 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  80013b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800140:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800143:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800148:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014d:	85 f6                	test   %esi,%esi
  80014f:	7e 07                	jle    800158 <libmain+0x34>
		binaryname = argv[0];
  800151:	8b 03                	mov    (%ebx),%eax
  800153:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800158:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80015c:	89 34 24             	mov    %esi,(%esp)
  80015f:	e8 dc fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800164:	e8 0b 00 00 00       	call   800174 <exit>
}
  800169:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80016c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80016f:	89 ec                	mov    %ebp,%esp
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    
	...

00800174 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80017a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800181:	e8 c3 0d 00 00       	call   800f49 <sys_env_destroy>
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800190:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800193:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800199:	e8 77 0d 00 00       	call   800f15 <sys_getenvid>
  80019e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 a4 16 80 00 	movl   $0x8016a4,(%esp)
  8001bb:	e8 81 00 00 00       	call   800241 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 11 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  8001cf:	c7 04 24 97 16 80 00 	movl   $0x801697,(%esp)
  8001d6:	e8 66 00 00 00       	call   800241 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001db:	cc                   	int3   
  8001dc:	eb fd                	jmp    8001db <_panic+0x53>
	...

008001e0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800200:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800204:	8b 45 08             	mov    0x8(%ebp),%eax
  800207:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800211:	89 44 24 04          	mov    %eax,0x4(%esp)
  800215:	c7 04 24 5b 02 80 00 	movl   $0x80025b,(%esp)
  80021c:	e8 be 01 00 00       	call   8003df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800221:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800231:	89 04 24             	mov    %eax,(%esp)
  800234:	e8 f7 09 00 00       	call   800c30 <sys_cputs>

	return b.cnt;
}
  800239:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023f:	c9                   	leave  
  800240:	c3                   	ret    

00800241 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800247:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 04 24             	mov    %eax,(%esp)
  800254:	e8 87 ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	53                   	push   %ebx
  80025f:	83 ec 14             	sub    $0x14,%esp
  800262:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800265:	8b 03                	mov    (%ebx),%eax
  800267:	8b 55 08             	mov    0x8(%ebp),%edx
  80026a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80026e:	83 c0 01             	add    $0x1,%eax
  800271:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800273:	3d ff 00 00 00       	cmp    $0xff,%eax
  800278:	75 19                	jne    800293 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80027a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800281:	00 
  800282:	8d 43 08             	lea    0x8(%ebx),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	e8 a3 09 00 00       	call   800c30 <sys_cputs>
		b->idx = 0;
  80028d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800293:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800297:	83 c4 14             	add    $0x14,%esp
  80029a:	5b                   	pop    %ebx
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 4c             	sub    $0x4c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d6                	mov    %edx,%esi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002cb:	39 d1                	cmp    %edx,%ecx
  8002cd:	72 07                	jb     8002d6 <printnum+0x36>
  8002cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d2:	39 d0                	cmp    %edx,%eax
  8002d4:	77 69                	ja     80033f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002da:	83 eb 01             	sub    $0x1,%ebx
  8002dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002e9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002ed:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002f0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002f3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800301:	00 
  800302:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80030b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80030f:	e8 bc 10 00 00       	call   8013d0 <__udivdi3>
  800314:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800317:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80031a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80031e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	89 54 24 04          	mov    %edx,0x4(%esp)
  800329:	89 f2                	mov    %esi,%edx
  80032b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80032e:	e8 6d ff ff ff       	call   8002a0 <printnum>
  800333:	eb 11                	jmp    800346 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800335:	89 74 24 04          	mov    %esi,0x4(%esp)
  800339:	89 3c 24             	mov    %edi,(%esp)
  80033c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033f:	83 eb 01             	sub    $0x1,%ebx
  800342:	85 db                	test   %ebx,%ebx
  800344:	7f ef                	jg     800335 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800346:	89 74 24 04          	mov    %esi,0x4(%esp)
  80034a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80034e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800351:	89 44 24 08          	mov    %eax,0x8(%esp)
  800355:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035c:	00 
  80035d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800360:	89 14 24             	mov    %edx,(%esp)
  800363:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800366:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80036a:	e8 91 11 00 00       	call   801500 <__umoddi3>
  80036f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800373:	0f be 80 c7 16 80 00 	movsbl 0x8016c7(%eax),%eax
  80037a:	89 04 24             	mov    %eax,(%esp)
  80037d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800380:	83 c4 4c             	add    $0x4c,%esp
  800383:	5b                   	pop    %ebx
  800384:	5e                   	pop    %esi
  800385:	5f                   	pop    %edi
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80038b:	83 fa 01             	cmp    $0x1,%edx
  80038e:	7e 0e                	jle    80039e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 08             	lea    0x8(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	8b 52 04             	mov    0x4(%edx),%edx
  80039c:	eb 22                	jmp    8003c0 <getuint+0x38>
	else if (lflag)
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	74 10                	je     8003b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003a2:	8b 10                	mov    (%eax),%edx
  8003a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a7:	89 08                	mov    %ecx,(%eax)
  8003a9:	8b 02                	mov    (%edx),%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	eb 0e                	jmp    8003c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003b2:	8b 10                	mov    (%eax),%edx
  8003b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b7:	89 08                	mov    %ecx,(%eax)
  8003b9:	8b 02                	mov    (%edx),%eax
  8003bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cc:	8b 10                	mov    (%eax),%edx
  8003ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d1:	73 0a                	jae    8003dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d6:	88 0a                	mov    %cl,(%edx)
  8003d8:	83 c2 01             	add    $0x1,%edx
  8003db:	89 10                	mov    %edx,(%eax)
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	57                   	push   %edi
  8003e3:	56                   	push   %esi
  8003e4:	53                   	push   %ebx
  8003e5:	83 ec 4c             	sub    $0x4c,%esp
  8003e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003f1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003f8:	eb 11                	jmp    80040b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003fa:	85 c0                	test   %eax,%eax
  8003fc:	0f 84 b0 03 00 00    	je     8007b2 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800402:	89 74 24 04          	mov    %esi,0x4(%esp)
  800406:	89 04 24             	mov    %eax,(%esp)
  800409:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80040b:	0f b6 03             	movzbl (%ebx),%eax
  80040e:	83 c3 01             	add    $0x1,%ebx
  800411:	83 f8 25             	cmp    $0x25,%eax
  800414:	75 e4                	jne    8003fa <vprintfmt+0x1b>
  800416:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80041d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800422:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800426:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800434:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800437:	eb 06                	jmp    80043f <vprintfmt+0x60>
  800439:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80043d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	0f b6 0b             	movzbl (%ebx),%ecx
  800442:	0f b6 c1             	movzbl %cl,%eax
  800445:	8d 53 01             	lea    0x1(%ebx),%edx
  800448:	83 e9 23             	sub    $0x23,%ecx
  80044b:	80 f9 55             	cmp    $0x55,%cl
  80044e:	0f 87 41 03 00 00    	ja     800795 <vprintfmt+0x3b6>
  800454:	0f b6 c9             	movzbl %cl,%ecx
  800457:	ff 24 8d 80 17 80 00 	jmp    *0x801780(,%ecx,4)
  80045e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800462:	eb d9                	jmp    80043d <vprintfmt+0x5e>
  800464:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80046b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800470:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800473:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800477:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80047a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80047d:	83 fb 09             	cmp    $0x9,%ebx
  800480:	77 2b                	ja     8004ad <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800482:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800485:	eb e9                	jmp    800470 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8d 48 04             	lea    0x4(%eax),%ecx
  80048d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800490:	8b 00                	mov    (%eax),%eax
  800492:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800495:	eb 19                	jmp    8004b0 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800497:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049a:	c1 f8 1f             	sar    $0x1f,%eax
  80049d:	f7 d0                	not    %eax
  80049f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  8004a2:	eb 99                	jmp    80043d <vprintfmt+0x5e>
  8004a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004ab:	eb 90                	jmp    80043d <vprintfmt+0x5e>
  8004ad:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  8004b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b4:	79 87                	jns    80043d <vprintfmt+0x5e>
  8004b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004bf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004c2:	e9 76 ff ff ff       	jmp    80043d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004cb:	e9 6d ff ff ff       	jmp    80043d <vprintfmt+0x5e>
  8004d0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 50 04             	lea    0x4(%eax),%edx
  8004d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e0:	8b 00                	mov    (%eax),%eax
  8004e2:	89 04 24             	mov    %eax,(%esp)
  8004e5:	ff d7                	call   *%edi
  8004e7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8004ea:	e9 1c ff ff ff       	jmp    80040b <vprintfmt+0x2c>
  8004ef:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f5:	8d 50 04             	lea    0x4(%eax),%edx
  8004f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fb:	8b 00                	mov    (%eax),%eax
  8004fd:	89 c2                	mov    %eax,%edx
  8004ff:	c1 fa 1f             	sar    $0x1f,%edx
  800502:	31 d0                	xor    %edx,%eax
  800504:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800506:	83 f8 09             	cmp    $0x9,%eax
  800509:	7f 0b                	jg     800516 <vprintfmt+0x137>
  80050b:	8b 14 85 e0 18 80 00 	mov    0x8018e0(,%eax,4),%edx
  800512:	85 d2                	test   %edx,%edx
  800514:	75 20                	jne    800536 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800516:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051a:	c7 44 24 08 d8 16 80 	movl   $0x8016d8,0x8(%esp)
  800521:	00 
  800522:	89 74 24 04          	mov    %esi,0x4(%esp)
  800526:	89 3c 24             	mov    %edi,(%esp)
  800529:	e8 0c 03 00 00       	call   80083a <printfmt>
  80052e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800531:	e9 d5 fe ff ff       	jmp    80040b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800536:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80053a:	c7 44 24 08 e1 16 80 	movl   $0x8016e1,0x8(%esp)
  800541:	00 
  800542:	89 74 24 04          	mov    %esi,0x4(%esp)
  800546:	89 3c 24             	mov    %edi,(%esp)
  800549:	e8 ec 02 00 00       	call   80083a <printfmt>
  80054e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800551:	e9 b5 fe ff ff       	jmp    80040b <vprintfmt+0x2c>
  800556:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800559:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80055c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80055f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 04             	lea    0x4(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	8b 18                	mov    (%eax),%ebx
  80056d:	85 db                	test   %ebx,%ebx
  80056f:	75 05                	jne    800576 <vprintfmt+0x197>
  800571:	bb e4 16 80 00       	mov    $0x8016e4,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800576:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80057a:	7e 76                	jle    8005f2 <vprintfmt+0x213>
  80057c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800580:	74 7a                	je     8005fc <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800582:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800586:	89 1c 24             	mov    %ebx,(%esp)
  800589:	e8 fa 02 00 00       	call   800888 <strnlen>
  80058e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800591:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800593:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800597:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80059a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80059d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	eb 0f                	jmp    8005b0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8005a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a8:	89 04 24             	mov    %eax,(%esp)
  8005ab:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ad:	83 eb 01             	sub    $0x1,%ebx
  8005b0:	85 db                	test   %ebx,%ebx
  8005b2:	7f ed                	jg     8005a1 <vprintfmt+0x1c2>
  8005b4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005b7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005ba:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005bd:	89 f7                	mov    %esi,%edi
  8005bf:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005c2:	eb 40                	jmp    800604 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c8:	74 18                	je     8005e2 <vprintfmt+0x203>
  8005ca:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005cd:	83 fa 5e             	cmp    $0x5e,%edx
  8005d0:	76 10                	jbe    8005e2 <vprintfmt+0x203>
					putch('?', putdat);
  8005d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005d6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005dd:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e0:	eb 0a                	jmp    8005ec <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e6:	89 04 24             	mov    %eax,(%esp)
  8005e9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ec:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005f0:	eb 12                	jmp    800604 <vprintfmt+0x225>
  8005f2:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005f5:	89 f7                	mov    %esi,%edi
  8005f7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005fa:	eb 08                	jmp    800604 <vprintfmt+0x225>
  8005fc:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005ff:	89 f7                	mov    %esi,%edi
  800601:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800604:	0f be 03             	movsbl (%ebx),%eax
  800607:	83 c3 01             	add    $0x1,%ebx
  80060a:	85 c0                	test   %eax,%eax
  80060c:	74 25                	je     800633 <vprintfmt+0x254>
  80060e:	85 f6                	test   %esi,%esi
  800610:	78 b2                	js     8005c4 <vprintfmt+0x1e5>
  800612:	83 ee 01             	sub    $0x1,%esi
  800615:	79 ad                	jns    8005c4 <vprintfmt+0x1e5>
  800617:	89 fe                	mov    %edi,%esi
  800619:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80061c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80061f:	eb 1a                	jmp    80063b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800621:	89 74 24 04          	mov    %esi,0x4(%esp)
  800625:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80062c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062e:	83 eb 01             	sub    $0x1,%ebx
  800631:	eb 08                	jmp    80063b <vprintfmt+0x25c>
  800633:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800636:	89 fe                	mov    %edi,%esi
  800638:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80063b:	85 db                	test   %ebx,%ebx
  80063d:	7f e2                	jg     800621 <vprintfmt+0x242>
  80063f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800642:	e9 c4 fd ff ff       	jmp    80040b <vprintfmt+0x2c>
  800647:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80064a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064d:	83 f9 01             	cmp    $0x1,%ecx
  800650:	7e 16                	jle    800668 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 08             	lea    0x8(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	8b 48 04             	mov    0x4(%eax),%ecx
  800660:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800663:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800666:	eb 32                	jmp    80069a <vprintfmt+0x2bb>
	else if (lflag)
  800668:	85 c9                	test   %ecx,%ecx
  80066a:	74 18                	je     800684 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 50 04             	lea    0x4(%eax),%edx
  800672:	89 55 14             	mov    %edx,0x14(%ebp)
  800675:	8b 00                	mov    (%eax),%eax
  800677:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067a:	89 c1                	mov    %eax,%ecx
  80067c:	c1 f9 1f             	sar    $0x1f,%ecx
  80067f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800682:	eb 16                	jmp    80069a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 50 04             	lea    0x4(%eax),%edx
  80068a:	89 55 14             	mov    %edx,0x14(%ebp)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800692:	89 c2                	mov    %eax,%edx
  800694:	c1 fa 1f             	sar    $0x1f,%edx
  800697:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80069d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a9:	0f 89 a7 00 00 00    	jns    800756 <vprintfmt+0x377>
				putch('-', putdat);
  8006af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ba:	ff d7                	call   *%edi
				num = -(long long) num;
  8006bc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006bf:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006c2:	f7 d9                	neg    %ecx
  8006c4:	83 d3 00             	adc    $0x0,%ebx
  8006c7:	f7 db                	neg    %ebx
  8006c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ce:	e9 83 00 00 00       	jmp    800756 <vprintfmt+0x377>
  8006d3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006d6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006d9:	89 ca                	mov    %ecx,%edx
  8006db:	8d 45 14             	lea    0x14(%ebp),%eax
  8006de:	e8 a5 fc ff ff       	call   800388 <getuint>
  8006e3:	89 c1                	mov    %eax,%ecx
  8006e5:	89 d3                	mov    %edx,%ebx
  8006e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006ec:	eb 68                	jmp    800756 <vprintfmt+0x377>
  8006ee:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006f1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006f4:	89 ca                	mov    %ecx,%edx
  8006f6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f9:	e8 8a fc ff ff       	call   800388 <getuint>
  8006fe:	89 c1                	mov    %eax,%ecx
  800700:	89 d3                	mov    %edx,%ebx
  800702:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800707:	eb 4d                	jmp    800756 <vprintfmt+0x377>
  800709:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80070c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800710:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800717:	ff d7                	call   *%edi
			putch('x', putdat);
  800719:	89 74 24 04          	mov    %esi,0x4(%esp)
  80071d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800724:	ff d7                	call   *%edi
			num = (unsigned long long)
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 08                	mov    (%eax),%ecx
  800731:	bb 00 00 00 00       	mov    $0x0,%ebx
  800736:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073b:	eb 19                	jmp    800756 <vprintfmt+0x377>
  80073d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800740:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800743:	89 ca                	mov    %ecx,%edx
  800745:	8d 45 14             	lea    0x14(%ebp),%eax
  800748:	e8 3b fc ff ff       	call   800388 <getuint>
  80074d:	89 c1                	mov    %eax,%ecx
  80074f:	89 d3                	mov    %edx,%ebx
  800751:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800756:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80075a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80075e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800761:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800765:	89 44 24 08          	mov    %eax,0x8(%esp)
  800769:	89 0c 24             	mov    %ecx,(%esp)
  80076c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800770:	89 f2                	mov    %esi,%edx
  800772:	89 f8                	mov    %edi,%eax
  800774:	e8 27 fb ff ff       	call   8002a0 <printnum>
  800779:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80077c:	e9 8a fc ff ff       	jmp    80040b <vprintfmt+0x2c>
  800781:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800784:	89 74 24 04          	mov    %esi,0x4(%esp)
  800788:	89 04 24             	mov    %eax,(%esp)
  80078b:	ff d7                	call   *%edi
  80078d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800790:	e9 76 fc ff ff       	jmp    80040b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800795:	89 74 24 04          	mov    %esi,0x4(%esp)
  800799:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007a5:	80 38 25             	cmpb   $0x25,(%eax)
  8007a8:	0f 84 5d fc ff ff    	je     80040b <vprintfmt+0x2c>
  8007ae:	89 c3                	mov    %eax,%ebx
  8007b0:	eb f0                	jmp    8007a2 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  8007b2:	83 c4 4c             	add    $0x4c,%esp
  8007b5:	5b                   	pop    %ebx
  8007b6:	5e                   	pop    %esi
  8007b7:	5f                   	pop    %edi
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 28             	sub    $0x28,%esp
  8007c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	74 04                	je     8007ce <vsnprintf+0x14>
  8007ca:	85 d2                	test   %edx,%edx
  8007cc:	7f 07                	jg     8007d5 <vsnprintf+0x1b>
  8007ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d3:	eb 3b                	jmp    800810 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007d8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fb:	c7 04 24 c2 03 80 00 	movl   $0x8003c2,(%esp)
  800802:	e8 d8 fb ff ff       	call   8003df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800807:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80080d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800818:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80081b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081f:	8b 45 10             	mov    0x10(%ebp),%eax
  800822:	89 44 24 08          	mov    %eax,0x8(%esp)
  800826:	8b 45 0c             	mov    0xc(%ebp),%eax
  800829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	89 04 24             	mov    %eax,(%esp)
  800833:	e8 82 ff ff ff       	call   8007ba <vsnprintf>
	va_end(ap);

	return rc;
}
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800840:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800843:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800847:	8b 45 10             	mov    0x10(%ebp),%eax
  80084a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800851:	89 44 24 04          	mov    %eax,0x4(%esp)
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	89 04 24             	mov    %eax,(%esp)
  80085b:	e8 7f fb ff ff       	call   8003df <vprintfmt>
	va_end(ap);
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    
	...

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  80087b:	eb 03                	jmp    800880 <strlen+0x10>
		n++;
  80087d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800880:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800884:	75 f7                	jne    80087d <strlen+0xd>
		n++;
	return n;
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80088f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800897:	eb 03                	jmp    80089c <strnlen+0x14>
		n++;
  800899:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089c:	39 c1                	cmp    %eax,%ecx
  80089e:	74 06                	je     8008a6 <strnlen+0x1e>
  8008a0:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008a4:	75 f3                	jne    800899 <strnlen+0x11>
		n++;
	return n;
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008bc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008bf:	83 c2 01             	add    $0x1,%edx
  8008c2:	84 c9                	test   %cl,%cl
  8008c4:	75 f2                	jne    8008b8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c6:	5b                   	pop    %ebx
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	53                   	push   %ebx
  8008cd:	83 ec 08             	sub    $0x8,%esp
  8008d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d3:	89 1c 24             	mov    %ebx,(%esp)
  8008d6:	e8 95 ff ff ff       	call   800870 <strlen>
	strcpy(dst + len, src);
  8008db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008e5:	89 04 24             	mov    %eax,(%esp)
  8008e8:	e8 bc ff ff ff       	call   8008a9 <strcpy>
	return dst;
}
  8008ed:	89 d8                	mov    %ebx,%eax
  8008ef:	83 c4 08             	add    $0x8,%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800900:	8b 75 10             	mov    0x10(%ebp),%esi
  800903:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800908:	eb 0f                	jmp    800919 <strncpy+0x24>
		*dst++ = *src;
  80090a:	0f b6 19             	movzbl (%ecx),%ebx
  80090d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800910:	80 39 01             	cmpb   $0x1,(%ecx)
  800913:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800916:	83 c2 01             	add    $0x1,%edx
  800919:	39 f2                	cmp    %esi,%edx
  80091b:	72 ed                	jb     80090a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	8b 75 08             	mov    0x8(%ebp),%esi
  800929:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80092f:	89 f0                	mov    %esi,%eax
  800931:	85 d2                	test   %edx,%edx
  800933:	75 0a                	jne    80093f <strlcpy+0x1e>
  800935:	eb 17                	jmp    80094e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800937:	88 18                	mov    %bl,(%eax)
  800939:	83 c0 01             	add    $0x1,%eax
  80093c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80093f:	83 ea 01             	sub    $0x1,%edx
  800942:	74 07                	je     80094b <strlcpy+0x2a>
  800944:	0f b6 19             	movzbl (%ecx),%ebx
  800947:	84 db                	test   %bl,%bl
  800949:	75 ec                	jne    800937 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80094b:	c6 00 00             	movb   $0x0,(%eax)
  80094e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095d:	eb 06                	jmp    800965 <strcmp+0x11>
		p++, q++;
  80095f:	83 c1 01             	add    $0x1,%ecx
  800962:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800965:	0f b6 01             	movzbl (%ecx),%eax
  800968:	84 c0                	test   %al,%al
  80096a:	74 04                	je     800970 <strcmp+0x1c>
  80096c:	3a 02                	cmp    (%edx),%al
  80096e:	74 ef                	je     80095f <strcmp+0xb>
  800970:	0f b6 c0             	movzbl %al,%eax
  800973:	0f b6 12             	movzbl (%edx),%edx
  800976:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800984:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800987:	eb 09                	jmp    800992 <strncmp+0x18>
		n--, p++, q++;
  800989:	83 ea 01             	sub    $0x1,%edx
  80098c:	83 c0 01             	add    $0x1,%eax
  80098f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800992:	85 d2                	test   %edx,%edx
  800994:	75 07                	jne    80099d <strncmp+0x23>
  800996:	b8 00 00 00 00       	mov    $0x0,%eax
  80099b:	eb 13                	jmp    8009b0 <strncmp+0x36>
  80099d:	0f b6 18             	movzbl (%eax),%ebx
  8009a0:	84 db                	test   %bl,%bl
  8009a2:	74 04                	je     8009a8 <strncmp+0x2e>
  8009a4:	3a 19                	cmp    (%ecx),%bl
  8009a6:	74 e1                	je     800989 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	0f b6 00             	movzbl (%eax),%eax
  8009ab:	0f b6 11             	movzbl (%ecx),%edx
  8009ae:	29 d0                	sub    %edx,%eax
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009bd:	eb 07                	jmp    8009c6 <strchr+0x13>
		if (*s == c)
  8009bf:	38 ca                	cmp    %cl,%dl
  8009c1:	74 0f                	je     8009d2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c3:	83 c0 01             	add    $0x1,%eax
  8009c6:	0f b6 10             	movzbl (%eax),%edx
  8009c9:	84 d2                	test   %dl,%dl
  8009cb:	75 f2                	jne    8009bf <strchr+0xc>
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009de:	eb 07                	jmp    8009e7 <strfind+0x13>
		if (*s == c)
  8009e0:	38 ca                	cmp    %cl,%dl
  8009e2:	74 0a                	je     8009ee <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	0f b6 10             	movzbl (%eax),%edx
  8009ea:	84 d2                	test   %dl,%dl
  8009ec:	75 f2                	jne    8009e0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ee:	5d                   	pop    %ebp
  8009ef:	90                   	nop
  8009f0:	c3                   	ret    

008009f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	83 ec 0c             	sub    $0xc,%esp
  8009f7:	89 1c 24             	mov    %ebx,(%esp)
  8009fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009fe:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a02:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a0b:	85 c9                	test   %ecx,%ecx
  800a0d:	74 30                	je     800a3f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a15:	75 25                	jne    800a3c <memset+0x4b>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 20                	jne    800a3c <memset+0x4b>
		c &= 0xFF;
  800a1c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1f:	89 d3                	mov    %edx,%ebx
  800a21:	c1 e3 08             	shl    $0x8,%ebx
  800a24:	89 d6                	mov    %edx,%esi
  800a26:	c1 e6 18             	shl    $0x18,%esi
  800a29:	89 d0                	mov    %edx,%eax
  800a2b:	c1 e0 10             	shl    $0x10,%eax
  800a2e:	09 f0                	or     %esi,%eax
  800a30:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a32:	09 d8                	or     %ebx,%eax
  800a34:	c1 e9 02             	shr    $0x2,%ecx
  800a37:	fc                   	cld    
  800a38:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3a:	eb 03                	jmp    800a3f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3c:	fc                   	cld    
  800a3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a3f:	89 f8                	mov    %edi,%eax
  800a41:	8b 1c 24             	mov    (%esp),%ebx
  800a44:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a48:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a4c:	89 ec                	mov    %ebp,%esp
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	83 ec 08             	sub    $0x8,%esp
  800a56:	89 34 24             	mov    %esi,(%esp)
  800a59:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a63:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a66:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a68:	39 c6                	cmp    %eax,%esi
  800a6a:	73 35                	jae    800aa1 <memmove+0x51>
  800a6c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a6f:	39 d0                	cmp    %edx,%eax
  800a71:	73 2e                	jae    800aa1 <memmove+0x51>
		s += n;
		d += n;
  800a73:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a75:	f6 c2 03             	test   $0x3,%dl
  800a78:	75 1b                	jne    800a95 <memmove+0x45>
  800a7a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a80:	75 13                	jne    800a95 <memmove+0x45>
  800a82:	f6 c1 03             	test   $0x3,%cl
  800a85:	75 0e                	jne    800a95 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a87:	83 ef 04             	sub    $0x4,%edi
  800a8a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a8d:	c1 e9 02             	shr    $0x2,%ecx
  800a90:	fd                   	std    
  800a91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a93:	eb 09                	jmp    800a9e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a95:	83 ef 01             	sub    $0x1,%edi
  800a98:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a9b:	fd                   	std    
  800a9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a9f:	eb 20                	jmp    800ac1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa7:	75 15                	jne    800abe <memmove+0x6e>
  800aa9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aaf:	75 0d                	jne    800abe <memmove+0x6e>
  800ab1:	f6 c1 03             	test   $0x3,%cl
  800ab4:	75 08                	jne    800abe <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
  800ab9:	fc                   	cld    
  800aba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abc:	eb 03                	jmp    800ac1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800abe:	fc                   	cld    
  800abf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac1:	8b 34 24             	mov    (%esp),%esi
  800ac4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800ac8:	89 ec                	mov    %ebp,%esp
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	89 04 24             	mov    %eax,(%esp)
  800ae6:	e8 65 ff ff ff       	call   800a50 <memmove>
}
  800aeb:	c9                   	leave  
  800aec:	c3                   	ret    

00800aed <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	57                   	push   %edi
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800afc:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b01:	eb 1c                	jmp    800b1f <memcmp+0x32>
		if (*s1 != *s2)
  800b03:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800b07:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800b0b:	83 c2 01             	add    $0x1,%edx
  800b0e:	83 e9 01             	sub    $0x1,%ecx
  800b11:	38 d8                	cmp    %bl,%al
  800b13:	74 0a                	je     800b1f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800b15:	0f b6 c0             	movzbl %al,%eax
  800b18:	0f b6 db             	movzbl %bl,%ebx
  800b1b:	29 d8                	sub    %ebx,%eax
  800b1d:	eb 09                	jmp    800b28 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1f:	85 c9                	test   %ecx,%ecx
  800b21:	75 e0                	jne    800b03 <memcmp+0x16>
  800b23:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b28:	5b                   	pop    %ebx
  800b29:	5e                   	pop    %esi
  800b2a:	5f                   	pop    %edi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3b:	eb 07                	jmp    800b44 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3d:	38 08                	cmp    %cl,(%eax)
  800b3f:	74 07                	je     800b48 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b41:	83 c0 01             	add    $0x1,%eax
  800b44:	39 d0                	cmp    %edx,%eax
  800b46:	72 f5                	jb     800b3d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	83 ec 04             	sub    $0x4,%esp
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b59:	eb 03                	jmp    800b5e <strtol+0x14>
		s++;
  800b5b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5e:	0f b6 02             	movzbl (%edx),%eax
  800b61:	3c 20                	cmp    $0x20,%al
  800b63:	74 f6                	je     800b5b <strtol+0x11>
  800b65:	3c 09                	cmp    $0x9,%al
  800b67:	74 f2                	je     800b5b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b69:	3c 2b                	cmp    $0x2b,%al
  800b6b:	75 0c                	jne    800b79 <strtol+0x2f>
		s++;
  800b6d:	8d 52 01             	lea    0x1(%edx),%edx
  800b70:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b77:	eb 15                	jmp    800b8e <strtol+0x44>
	else if (*s == '-')
  800b79:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b80:	3c 2d                	cmp    $0x2d,%al
  800b82:	75 0a                	jne    800b8e <strtol+0x44>
		s++, neg = 1;
  800b84:	8d 52 01             	lea    0x1(%edx),%edx
  800b87:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8e:	85 db                	test   %ebx,%ebx
  800b90:	0f 94 c0             	sete   %al
  800b93:	74 05                	je     800b9a <strtol+0x50>
  800b95:	83 fb 10             	cmp    $0x10,%ebx
  800b98:	75 18                	jne    800bb2 <strtol+0x68>
  800b9a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9d:	75 13                	jne    800bb2 <strtol+0x68>
  800b9f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba3:	75 0d                	jne    800bb2 <strtol+0x68>
		s += 2, base = 16;
  800ba5:	83 c2 02             	add    $0x2,%edx
  800ba8:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bad:	8d 76 00             	lea    0x0(%esi),%esi
  800bb0:	eb 13                	jmp    800bc5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb2:	84 c0                	test   %al,%al
  800bb4:	74 0f                	je     800bc5 <strtol+0x7b>
  800bb6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bbb:	80 3a 30             	cmpb   $0x30,(%edx)
  800bbe:	75 05                	jne    800bc5 <strtol+0x7b>
		s++, base = 8;
  800bc0:	83 c2 01             	add    $0x1,%edx
  800bc3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bcc:	0f b6 0a             	movzbl (%edx),%ecx
  800bcf:	89 cf                	mov    %ecx,%edi
  800bd1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bd4:	80 fb 09             	cmp    $0x9,%bl
  800bd7:	77 08                	ja     800be1 <strtol+0x97>
			dig = *s - '0';
  800bd9:	0f be c9             	movsbl %cl,%ecx
  800bdc:	83 e9 30             	sub    $0x30,%ecx
  800bdf:	eb 1e                	jmp    800bff <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800be1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800be4:	80 fb 19             	cmp    $0x19,%bl
  800be7:	77 08                	ja     800bf1 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800be9:	0f be c9             	movsbl %cl,%ecx
  800bec:	83 e9 57             	sub    $0x57,%ecx
  800bef:	eb 0e                	jmp    800bff <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800bf1:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bf4:	80 fb 19             	cmp    $0x19,%bl
  800bf7:	77 15                	ja     800c0e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800bf9:	0f be c9             	movsbl %cl,%ecx
  800bfc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bff:	39 f1                	cmp    %esi,%ecx
  800c01:	7d 0b                	jge    800c0e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800c03:	83 c2 01             	add    $0x1,%edx
  800c06:	0f af c6             	imul   %esi,%eax
  800c09:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c0c:	eb be                	jmp    800bcc <strtol+0x82>
  800c0e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c14:	74 05                	je     800c1b <strtol+0xd1>
		*endptr = (char *) s;
  800c16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c19:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c1f:	74 04                	je     800c25 <strtol+0xdb>
  800c21:	89 c8                	mov    %ecx,%eax
  800c23:	f7 d8                	neg    %eax
}
  800c25:	83 c4 04             	add    $0x4,%esp
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    
  800c2d:	00 00                	add    %al,(%eax)
	...

00800c30 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 0c             	sub    $0xc,%esp
  800c36:	89 1c 24             	mov    %ebx,(%esp)
  800c39:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c3d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	b8 00 00 00 00       	mov    $0x0,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	89 c3                	mov    %eax,%ebx
  800c4e:	89 c7                	mov    %eax,%edi
  800c50:	89 c6                	mov    %eax,%esi
  800c52:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c54:	8b 1c 24             	mov    (%esp),%ebx
  800c57:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c5b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c5f:	89 ec                	mov    %ebp,%esp
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 38             	sub    $0x38,%esp
  800c69:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c6c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c6f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800c72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c76:	75 0c                	jne    800c84 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800c78:	c7 04 24 08 19 80 00 	movl   $0x801908,(%esp)
  800c7f:	e8 bd f5 ff ff       	call   800241 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 28                	jle    800cc6 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ca9:	00 
  800caa:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  800cb1:	00 
  800cb2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb9:	00 
  800cba:	c7 04 24 51 19 80 00 	movl   $0x801951,(%esp)
  800cc1:	e8 c2 f4 ff ff       	call   800188 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cc6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ccc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ccf:	89 ec                	mov    %ebp,%esp
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 38             	sub    $0x38,%esp
  800cd9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cdc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	89 cb                	mov    %ecx,%ebx
  800cf1:	89 cf                	mov    %ecx,%edi
  800cf3:	89 ce                	mov    %ecx,%esi
  800cf5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7e 28                	jle    800d23 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cff:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d06:	00 
  800d07:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  800d0e:	00 
  800d0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d16:	00 
  800d17:	c7 04 24 51 19 80 00 	movl   $0x801951,(%esp)
  800d1e:	e8 65 f4 ff ff       	call   800188 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d23:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d26:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d29:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2c:	89 ec                	mov    %ebp,%esp
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	83 ec 0c             	sub    $0xc,%esp
  800d36:	89 1c 24             	mov    %ebx,(%esp)
  800d39:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d3d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d41:	be 00 00 00 00       	mov    $0x0,%esi
  800d46:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	8b 1c 24             	mov    (%esp),%ebx
  800d5c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d60:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d64:	89 ec                	mov    %ebp,%esp
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 38             	sub    $0x38,%esp
  800d6e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d71:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d74:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	89 df                	mov    %ebx,%edi
  800d89:	89 de                	mov    %ebx,%esi
  800d8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	7e 28                	jle    800db9 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d95:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d9c:	00 
  800d9d:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  800da4:	00 
  800da5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dac:	00 
  800dad:	c7 04 24 51 19 80 00 	movl   $0x801951,(%esp)
  800db4:	e8 cf f3 ff ff       	call   800188 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dbc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc2:	89 ec                	mov    %ebp,%esp
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	83 ec 38             	sub    $0x38,%esp
  800dcc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dcf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dda:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 df                	mov    %ebx,%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 28                	jle    800e17 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  800e02:	00 
  800e03:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0a:	00 
  800e0b:	c7 04 24 51 19 80 00 	movl   $0x801951,(%esp)
  800e12:	e8 71 f3 ff ff       	call   800188 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e17:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e1a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e1d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e20:	89 ec                	mov    %ebp,%esp
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 38             	sub    $0x38,%esp
  800e2a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e2d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e30:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e33:	b8 05 00 00 00       	mov    $0x5,%eax
  800e38:	8b 75 18             	mov    0x18(%ebp),%esi
  800e3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	7e 28                	jle    800e75 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e51:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e58:	00 
  800e59:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  800e60:	00 
  800e61:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e68:	00 
  800e69:	c7 04 24 51 19 80 00 	movl   $0x801951,(%esp)
  800e70:	e8 13 f3 ff ff       	call   800188 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e75:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e78:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7e:	89 ec                	mov    %ebp,%esp
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 38             	sub    $0x38,%esp
  800e88:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e8b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e91:	be 00 00 00 00       	mov    $0x0,%esi
  800e96:	b8 04 00 00 00       	mov    $0x4,%eax
  800e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	89 f7                	mov    %esi,%edi
  800ea6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea8:	85 c0                	test   %eax,%eax
  800eaa:	7e 28                	jle    800ed4 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eac:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  800ebf:	00 
  800ec0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec7:	00 
  800ec8:	c7 04 24 51 19 80 00 	movl   $0x801951,(%esp)
  800ecf:	e8 b4 f2 ff ff       	call   800188 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ed4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eda:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800edd:	89 ec                	mov    %ebp,%esp
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	83 ec 0c             	sub    $0xc,%esp
  800ee7:	89 1c 24             	mov    %ebx,(%esp)
  800eea:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eee:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efc:	89 d1                	mov    %edx,%ecx
  800efe:	89 d3                	mov    %edx,%ebx
  800f00:	89 d7                	mov    %edx,%edi
  800f02:	89 d6                	mov    %edx,%esi
  800f04:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f06:	8b 1c 24             	mov    (%esp),%ebx
  800f09:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f0d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f11:	89 ec                	mov    %ebp,%esp
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 0c             	sub    $0xc,%esp
  800f1b:	89 1c 24             	mov    %ebx,(%esp)
  800f1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f22:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f26:	ba 00 00 00 00       	mov    $0x0,%edx
  800f2b:	b8 02 00 00 00       	mov    $0x2,%eax
  800f30:	89 d1                	mov    %edx,%ecx
  800f32:	89 d3                	mov    %edx,%ebx
  800f34:	89 d7                	mov    %edx,%edi
  800f36:	89 d6                	mov    %edx,%esi
  800f38:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f3a:	8b 1c 24             	mov    (%esp),%ebx
  800f3d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f41:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f45:	89 ec                	mov    %ebp,%esp
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 38             	sub    $0x38,%esp
  800f4f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f52:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f55:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	89 cb                	mov    %ecx,%ebx
  800f67:	89 cf                	mov    %ecx,%edi
  800f69:	89 ce                	mov    %ecx,%esi
  800f6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6d:	85 c0                	test   %eax,%eax
  800f6f:	7e 28                	jle    800f99 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f75:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 08 34 19 80 	movl   $0x801934,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 51 19 80 00 	movl   $0x801951,(%esp)
  800f94:	e8 ef f1 ff ff       	call   800188 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f99:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f9c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f9f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa2:	89 ec                	mov    %ebp,%esp
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	89 1c 24             	mov    %ebx,(%esp)
  800faf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fb3:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbc:	b8 01 00 00 00       	mov    $0x1,%eax
  800fc1:	89 d1                	mov    %edx,%ecx
  800fc3:	89 d3                	mov    %edx,%ebx
  800fc5:	89 d7                	mov    %edx,%edi
  800fc7:	89 d6                	mov    %edx,%esi
  800fc9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fcb:	8b 1c 24             	mov    (%esp),%ebx
  800fce:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fd2:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fd6:	89 ec                	mov    %ebp,%esp
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    
	...

00800fdc <sfork>:
}

// Challenge!
int
sfork(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800fe2:	c7 44 24 08 5f 19 80 	movl   $0x80195f,0x8(%esp)
  800fe9:	00 
  800fea:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  800ff1:	00 
  800ff2:	c7 04 24 75 19 80 00 	movl   $0x801975,(%esp)
  800ff9:	e8 8a f1 ff ff       	call   800188 <_panic>

00800ffe <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	56                   	push   %esi
  801002:	53                   	push   %ebx
  801003:	83 ec 20             	sub    $0x20,%esp
  801006:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801009:	8b 30                	mov    (%eax),%esi
	uint32_t err = utf->utf_err;
  80100b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80100f:	75 1c                	jne    80102d <pgfault+0x2f>

	// LAB 4: Your code here.
	FORKDEBUG("lib pgfault: fault address 0x%08x\n",(int)addr);

	if ( (err&FEC_WR) == 0 ) {
		panic("lib pgfault: The page fault is not caused by write\n");
  801011:	c7 44 24 08 a0 19 80 	movl   $0x8019a0,0x8(%esp)
  801018:	00 
  801019:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801020:	00 
  801021:	c7 04 24 75 19 80 00 	movl   $0x801975,(%esp)
  801028:	e8 5b f1 ff ff       	call   800188 <_panic>
	} 
	
	if ( (uvpt[PGNUM(addr)]&PTE_COW) == 0 ) {
  80102d:	89 f0                	mov    %esi,%eax
  80102f:	c1 e8 0c             	shr    $0xc,%eax
  801032:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801039:	f6 c4 08             	test   $0x8,%ah
  80103c:	75 1c                	jne    80105a <pgfault+0x5c>
		panic("lib pgfault: The page fault's page is not COW\n");
  80103e:	c7 44 24 08 d4 19 80 	movl   $0x8019d4,0x8(%esp)
  801045:	00 
  801046:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  80104d:	00 
  80104e:	c7 04 24 75 19 80 00 	movl   $0x801975,(%esp)
  801055:	e8 2e f1 ff ff       	call   800188 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
		
	envid_t envid=sys_getenvid();
  80105a:	e8 b6 fe ff ff       	call   800f15 <sys_getenvid>
  80105f:	89 c3                	mov    %eax,%ebx
	int res;
	
	res=sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W);
  801061:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801070:	00 
  801071:	89 04 24             	mov    %eax,(%esp)
  801074:	e8 09 fe ff ff       	call   800e82 <sys_page_alloc>
	if (res<0) {
  801079:	85 c0                	test   %eax,%eax
  80107b:	79 1c                	jns    801099 <pgfault+0x9b>
		panic("lib pgfault: cannot allocate temp page\n");
  80107d:	c7 44 24 08 04 1a 80 	movl   $0x801a04,0x8(%esp)
  801084:	00 
  801085:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80108c:	00 
  80108d:	c7 04 24 75 19 80 00 	movl   $0x801975,(%esp)
  801094:	e8 ef f0 ff ff       	call   800188 <_panic>
	}

	memmove(PFTEMP, (void*)ROUNDDOWN(addr,PGSIZE),PGSIZE);
  801099:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  80109f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010a6:	00 
  8010a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010ab:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010b2:	e8 99 f9 ff ff       	call   800a50 <memmove>
	
	res=sys_page_map(envid,PFTEMP,envid,(void*)ROUNDDOWN(addr,PGSIZE), PTE_U | PTE_P | PTE_W);
  8010b7:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010be:	00 
  8010bf:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010c7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010ce:	00 
  8010cf:	89 1c 24             	mov    %ebx,(%esp)
  8010d2:	e8 4d fd ff ff       	call   800e24 <sys_page_map>
	if (res<0) {
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	79 1c                	jns    8010f7 <pgfault+0xf9>
		panic("lib pgfault: cannot map page\n");
  8010db:	c7 44 24 08 80 19 80 	movl   $0x801980,0x8(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8010ea:	00 
  8010eb:	c7 04 24 75 19 80 00 	movl   $0x801975,(%esp)
  8010f2:	e8 91 f0 ff ff       	call   800188 <_panic>
	}

	res=sys_page_unmap(envid,PFTEMP);
  8010f7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010fe:	00 
  8010ff:	89 1c 24             	mov    %ebx,(%esp)
  801102:	e8 bf fc ff ff       	call   800dc6 <sys_page_unmap>
	if (res<0) {
  801107:	85 c0                	test   %eax,%eax
  801109:	79 1c                	jns    801127 <pgfault+0x129>
		panic("lib pgfault: cannot unmap page\n");
  80110b:	c7 44 24 08 2c 1a 80 	movl   $0x801a2c,0x8(%esp)
  801112:	00 
  801113:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  80111a:	00 
  80111b:	c7 04 24 75 19 80 00 	movl   $0x801975,(%esp)
  801122:	e8 61 f0 ff ff       	call   800188 <_panic>
	}
	return;
	//panic("pgfault not implemented");
}
  801127:	83 c4 20             	add    $0x20,%esp
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 4: Your code here.
	int i,j,pn=0;
	envid_t curenvid=sys_getenvid();
  801137:	e8 d9 fd ff ff       	call   800f15 <sys_getenvid>
  80113c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	envid_t envid;
	int r;
	

	FORKDEBUG("fork: start to fork\n");
	set_pgfault_handler(pgfault);
  80113f:	c7 04 24 fe 0f 80 00 	movl   $0x800ffe,(%esp)
  801146:	e8 e9 01 00 00       	call   801334 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80114b:	ba 07 00 00 00       	mov    $0x7,%edx
  801150:	89 d0                	mov    %edx,%eax
  801152:	cd 30                	int    $0x30
  801154:	89 45 d8             	mov    %eax,-0x28(%ebp)
	FORKDEBUG("fork: already set pgfault handler\n");


	if ( (envid = sys_exofork()) < 0) {
  801157:	85 c0                	test   %eax,%eax
  801159:	0f 88 c2 01 00 00    	js     801321 <fork+0x1f3>
		return -1;
	}	

	FORKDEBUG("fork: already sys_exofork\n");
	
	if ( envid==0 ) {
  80115f:	85 c0                	test   %eax,%eax
  801161:	75 39                	jne    80119c <fork+0x6e>

		FORKDEBUG("fork: I am the child\n");
		sys_page_alloc(sys_getenvid(),(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P);
  801163:	e8 ad fd ff ff       	call   800f15 <sys_getenvid>
  801168:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80116f:	00 
  801170:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801177:	ee 
  801178:	89 04 24             	mov    %eax,(%esp)
  80117b:	e8 02 fd ff ff       	call   800e82 <sys_page_alloc>

		thisenv=&envs[ENVX(sys_getenvid())];
  801180:	e8 90 fd ff ff       	call   800f15 <sys_getenvid>
  801185:	25 ff 03 00 00       	and    $0x3ff,%eax
  80118a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80118d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801192:	a3 08 20 80 00       	mov    %eax,0x802008
		return envid;
  801197:	e9 8c 01 00 00       	jmp    801328 <fork+0x1fa>
  80119c:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
  8011a3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011a6:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  8011ad:	a8 01                	test   $0x1,%al
  8011af:	0f 84 a9 00 00 00    	je     80125e <fork+0x130>
			for ( j=0;j<NPTENTRIES;j++) {
		//		cprintf("i: %d, j:%d\n",i,j);
				pn=PGNUM(PGADDR(i,j,0));
  8011b5:	c1 e2 16             	shl    $0x16,%edx
  8011b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c0:	89 de                	mov    %ebx,%esi
  8011c2:	c1 e6 0c             	shl    $0xc,%esi
  8011c5:	0b 75 e4             	or     -0x1c(%ebp),%esi
  8011c8:	c1 ee 0c             	shr    $0xc,%esi
				if ( pn== PGNUM(UXSTACKTOP-PGSIZE) ) {
  8011cb:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8011d1:	0f 84 87 00 00 00    	je     80125e <fork+0x130>
					break;
				}
				if ( uvpt[pn] & PTE_P ) {
  8011d7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011de:	a8 01                	test   $0x1,%al
  8011e0:	74 6d                	je     80124f <fork+0x121>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid();
  8011e2:	e8 2e fd ff ff       	call   800f15 <sys_getenvid>
  8011e7:	89 45 e0             	mov    %eax,-0x20(%ebp)

	pte_t pte = uvpt[pn];
  8011ea:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm;

	perm = PTE_U | PTE_P;
	if ( pte & PTE_W || pte & PTE_COW ) {
  8011f1:	25 02 08 00 00       	and    $0x802,%eax
  8011f6:	83 f8 01             	cmp    $0x1,%eax
  8011f9:	19 ff                	sbb    %edi,%edi
  8011fb:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801201:	81 c7 05 08 00 00    	add    $0x805,%edi
		perm |= PTE_COW;
	}

	r=sys_page_map(curenvid, (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE),perm);
  801207:	c1 e6 0c             	shl    $0xc,%esi
  80120a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80120e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801212:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801215:	89 44 24 08          	mov    %eax,0x8(%esp)
  801219:	89 74 24 04          	mov    %esi,0x4(%esp)
  80121d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801220:	89 14 24             	mov    %edx,(%esp)
  801223:	e8 fc fb ff ff       	call   800e24 <sys_page_map>
	if (r<0) {
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 23                	js     80124f <fork+0x121>
		FORKDEBUG("lib duppage: sys_page_map curenvid fail\n");
		return r;
	}
	
	if ( perm & PTE_COW ) {
  80122c:	f7 c7 00 08 00 00    	test   $0x800,%edi
  801232:	74 1b                	je     80124f <fork+0x121>
		r=sys_page_map(curenvid, (void*)(pn*PGSIZE), curenvid, (void*)(pn*PGSIZE), perm);
  801234:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801238:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80123c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80123f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801243:	89 74 24 04          	mov    %esi,0x4(%esp)
  801247:	89 04 24             	mov    %eax,(%esp)
  80124a:	e8 d5 fb ff ff       	call   800e24 <sys_page_map>
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
			for ( j=0;j<NPTENTRIES;j++) {
  80124f:	83 c3 01             	add    $0x1,%ebx
  801252:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801258:	0f 85 62 ff ff ff    	jne    8011c0 <fork+0x92>
//			duppage(envid,pn);
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
  80125e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  801262:	81 7d dc bb 03 00 00 	cmpl   $0x3bb,-0x24(%ebp)
  801269:	0f 85 34 ff ff ff    	jne    8011a3 <fork+0x75>
			}
		}
	}
	FORKDEBUG("lib fork: after duppage\n");
	
	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_U | PTE_P | PTE_W)<0 ) {
  80126f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801276:	00 
  801277:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80127e:	ee 
  80127f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801282:	89 14 24             	mov    %edx,(%esp)
  801285:	e8 f8 fb ff ff       	call   800e82 <sys_page_alloc>
  80128a:	85 c0                	test   %eax,%eax
  80128c:	0f 88 8f 00 00 00    	js     801321 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_alloc fail\n");
		return -1;
	}

	if (sys_page_map(envid,(void*)(UXSTACKTOP-PGSIZE),curenvid,PFTEMP, PTE_U | PTE_P | PTE_W)<0) {
  801292:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801299:	00 
  80129a:	c7 44 24 0c 00 f0 7f 	movl   $0x7ff000,0xc(%esp)
  8012a1:	00 
  8012a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012b0:	ee 
  8012b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012b4:	89 14 24             	mov    %edx,(%esp)
  8012b7:	e8 68 fb ff ff       	call   800e24 <sys_page_map>
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 61                	js     801321 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_map envid fail\n");
		return -1;
	}

	memmove((void*)(UXSTACKTOP-PGSIZE) , PFTEMP ,PGSIZE);
  8012c0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012c7:	00 
  8012c8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012cf:	00 
  8012d0:	c7 04 24 00 f0 bf ee 	movl   $0xeebff000,(%esp)
  8012d7:	e8 74 f7 ff ff       	call   800a50 <memmove>
	
	if (sys_page_unmap(curenvid,PFTEMP)<0) {
  8012dc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012e3:	00 
  8012e4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012e7:	89 04 24             	mov    %eax,(%esp)
  8012ea:	e8 d7 fa ff ff       	call   800dc6 <sys_page_unmap>
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 2e                	js     801321 <fork+0x1f3>
		return -1;
	}

	extern void _pgfault_upcall(void);

	if (sys_env_set_pgfault_upcall(envid,_pgfault_upcall)<0) {
  8012f3:	c7 44 24 04 a8 13 80 	movl   $0x8013a8,0x4(%esp)
  8012fa:	00 
  8012fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012fe:	89 14 24             	mov    %edx,(%esp)
  801301:	e8 5d f9 ff ff       	call   800c63 <sys_env_set_pgfault_upcall>
  801306:	85 c0                	test   %eax,%eax
  801308:	78 17                	js     801321 <fork+0x1f3>
//	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P)<0) {
//		FORKDEBUG("lib fork: sys_page_alloc fail\n");
//		return -1;
//	}		

	if (sys_env_set_status(envid, ENV_RUNNABLE)<0) {
  80130a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801311:	00 
  801312:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801315:	89 04 24             	mov    %eax,(%esp)
  801318:	e8 4b fa ff ff       	call   800d68 <sys_env_set_status>
  80131d:	85 c0                	test   %eax,%eax
  80131f:	79 07                	jns    801328 <fork+0x1fa>
  801321:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)

	FORKDEBUG("lib fork: finish fork\n");

	return envid;
//	panic("fork not implemented");
}
  801328:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80132b:	83 c4 4c             	add    $0x4c,%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
	...

00801334 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80133a:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  801341:	75 58                	jne    80139b <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  801343:	a1 08 20 80 00       	mov    0x802008,%eax
  801348:	8b 40 48             	mov    0x48(%eax),%eax
  80134b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801352:	00 
  801353:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80135a:	ee 
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	e8 1f fb ff ff       	call   800e82 <sys_page_alloc>
  801363:	85 c0                	test   %eax,%eax
  801365:	74 1c                	je     801383 <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  801367:	c7 44 24 08 4c 1a 80 	movl   $0x801a4c,0x8(%esp)
  80136e:	00 
  80136f:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801376:	00 
  801377:	c7 04 24 78 1a 80 00 	movl   $0x801a78,(%esp)
  80137e:	e8 05 ee ff ff       	call   800188 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  801383:	a1 08 20 80 00       	mov    0x802008,%eax
  801388:	8b 40 48             	mov    0x48(%eax),%eax
  80138b:	c7 44 24 04 a8 13 80 	movl   $0x8013a8,0x4(%esp)
  801392:	00 
  801393:	89 04 24             	mov    %eax,(%esp)
  801396:	e8 c8 f8 ff ff       	call   800c63 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80139b:	8b 45 08             	mov    0x8(%ebp),%eax
  80139e:	a3 0c 20 80 00       	mov    %eax,0x80200c
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    
  8013a5:	00 00                	add    %al,(%eax)
	...

008013a8 <_pgfault_upcall>:
  8013a8:	54                   	push   %esp
  8013a9:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8013ae:	ff d0                	call   *%eax
  8013b0:	83 c4 04             	add    $0x4,%esp
  8013b3:	89 e3                	mov    %esp,%ebx
  8013b5:	8b 44 24 28          	mov    0x28(%esp),%eax
  8013b9:	8b 64 24 30          	mov    0x30(%esp),%esp
  8013bd:	50                   	push   %eax
  8013be:	89 dc                	mov    %ebx,%esp
  8013c0:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  8013c5:	58                   	pop    %eax
  8013c6:	58                   	pop    %eax
  8013c7:	61                   	popa   
  8013c8:	83 c4 04             	add    $0x4,%esp
  8013cb:	9d                   	popf   
  8013cc:	5c                   	pop    %esp
  8013cd:	c3                   	ret    
	...

008013d0 <__udivdi3>:
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	57                   	push   %edi
  8013d4:	56                   	push   %esi
  8013d5:	83 ec 10             	sub    $0x10,%esp
  8013d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013db:	8b 55 08             	mov    0x8(%ebp),%edx
  8013de:	8b 75 10             	mov    0x10(%ebp),%esi
  8013e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8013e4:	85 c0                	test   %eax,%eax
  8013e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8013e9:	75 35                	jne    801420 <__udivdi3+0x50>
  8013eb:	39 fe                	cmp    %edi,%esi
  8013ed:	77 61                	ja     801450 <__udivdi3+0x80>
  8013ef:	85 f6                	test   %esi,%esi
  8013f1:	75 0b                	jne    8013fe <__udivdi3+0x2e>
  8013f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8013f8:	31 d2                	xor    %edx,%edx
  8013fa:	f7 f6                	div    %esi
  8013fc:	89 c6                	mov    %eax,%esi
  8013fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801401:	31 d2                	xor    %edx,%edx
  801403:	89 f8                	mov    %edi,%eax
  801405:	f7 f6                	div    %esi
  801407:	89 c7                	mov    %eax,%edi
  801409:	89 c8                	mov    %ecx,%eax
  80140b:	f7 f6                	div    %esi
  80140d:	89 c1                	mov    %eax,%ecx
  80140f:	89 fa                	mov    %edi,%edx
  801411:	89 c8                	mov    %ecx,%eax
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	5e                   	pop    %esi
  801417:	5f                   	pop    %edi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    
  80141a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801420:	39 f8                	cmp    %edi,%eax
  801422:	77 1c                	ja     801440 <__udivdi3+0x70>
  801424:	0f bd d0             	bsr    %eax,%edx
  801427:	83 f2 1f             	xor    $0x1f,%edx
  80142a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80142d:	75 39                	jne    801468 <__udivdi3+0x98>
  80142f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801432:	0f 86 a0 00 00 00    	jbe    8014d8 <__udivdi3+0x108>
  801438:	39 f8                	cmp    %edi,%eax
  80143a:	0f 82 98 00 00 00    	jb     8014d8 <__udivdi3+0x108>
  801440:	31 ff                	xor    %edi,%edi
  801442:	31 c9                	xor    %ecx,%ecx
  801444:	89 c8                	mov    %ecx,%eax
  801446:	89 fa                	mov    %edi,%edx
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    
  80144f:	90                   	nop
  801450:	89 d1                	mov    %edx,%ecx
  801452:	89 fa                	mov    %edi,%edx
  801454:	89 c8                	mov    %ecx,%eax
  801456:	31 ff                	xor    %edi,%edi
  801458:	f7 f6                	div    %esi
  80145a:	89 c1                	mov    %eax,%ecx
  80145c:	89 fa                	mov    %edi,%edx
  80145e:	89 c8                	mov    %ecx,%eax
  801460:	83 c4 10             	add    $0x10,%esp
  801463:	5e                   	pop    %esi
  801464:	5f                   	pop    %edi
  801465:	5d                   	pop    %ebp
  801466:	c3                   	ret    
  801467:	90                   	nop
  801468:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80146c:	89 f2                	mov    %esi,%edx
  80146e:	d3 e0                	shl    %cl,%eax
  801470:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801473:	b8 20 00 00 00       	mov    $0x20,%eax
  801478:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80147b:	89 c1                	mov    %eax,%ecx
  80147d:	d3 ea                	shr    %cl,%edx
  80147f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801483:	0b 55 ec             	or     -0x14(%ebp),%edx
  801486:	d3 e6                	shl    %cl,%esi
  801488:	89 c1                	mov    %eax,%ecx
  80148a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80148d:	89 fe                	mov    %edi,%esi
  80148f:	d3 ee                	shr    %cl,%esi
  801491:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801495:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801498:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80149b:	d3 e7                	shl    %cl,%edi
  80149d:	89 c1                	mov    %eax,%ecx
  80149f:	d3 ea                	shr    %cl,%edx
  8014a1:	09 d7                	or     %edx,%edi
  8014a3:	89 f2                	mov    %esi,%edx
  8014a5:	89 f8                	mov    %edi,%eax
  8014a7:	f7 75 ec             	divl   -0x14(%ebp)
  8014aa:	89 d6                	mov    %edx,%esi
  8014ac:	89 c7                	mov    %eax,%edi
  8014ae:	f7 65 e8             	mull   -0x18(%ebp)
  8014b1:	39 d6                	cmp    %edx,%esi
  8014b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8014b6:	72 30                	jb     8014e8 <__udivdi3+0x118>
  8014b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8014bf:	d3 e2                	shl    %cl,%edx
  8014c1:	39 c2                	cmp    %eax,%edx
  8014c3:	73 05                	jae    8014ca <__udivdi3+0xfa>
  8014c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8014c8:	74 1e                	je     8014e8 <__udivdi3+0x118>
  8014ca:	89 f9                	mov    %edi,%ecx
  8014cc:	31 ff                	xor    %edi,%edi
  8014ce:	e9 71 ff ff ff       	jmp    801444 <__udivdi3+0x74>
  8014d3:	90                   	nop
  8014d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014d8:	31 ff                	xor    %edi,%edi
  8014da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8014df:	e9 60 ff ff ff       	jmp    801444 <__udivdi3+0x74>
  8014e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8014eb:	31 ff                	xor    %edi,%edi
  8014ed:	89 c8                	mov    %ecx,%eax
  8014ef:	89 fa                	mov    %edi,%edx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	5e                   	pop    %esi
  8014f5:	5f                   	pop    %edi
  8014f6:	5d                   	pop    %ebp
  8014f7:	c3                   	ret    
	...

00801500 <__umoddi3>:
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	57                   	push   %edi
  801504:	56                   	push   %esi
  801505:	83 ec 20             	sub    $0x20,%esp
  801508:	8b 55 14             	mov    0x14(%ebp),%edx
  80150b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801511:	8b 75 0c             	mov    0xc(%ebp),%esi
  801514:	85 d2                	test   %edx,%edx
  801516:	89 c8                	mov    %ecx,%eax
  801518:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80151b:	75 13                	jne    801530 <__umoddi3+0x30>
  80151d:	39 f7                	cmp    %esi,%edi
  80151f:	76 3f                	jbe    801560 <__umoddi3+0x60>
  801521:	89 f2                	mov    %esi,%edx
  801523:	f7 f7                	div    %edi
  801525:	89 d0                	mov    %edx,%eax
  801527:	31 d2                	xor    %edx,%edx
  801529:	83 c4 20             	add    $0x20,%esp
  80152c:	5e                   	pop    %esi
  80152d:	5f                   	pop    %edi
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    
  801530:	39 f2                	cmp    %esi,%edx
  801532:	77 4c                	ja     801580 <__umoddi3+0x80>
  801534:	0f bd ca             	bsr    %edx,%ecx
  801537:	83 f1 1f             	xor    $0x1f,%ecx
  80153a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80153d:	75 51                	jne    801590 <__umoddi3+0x90>
  80153f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801542:	0f 87 e0 00 00 00    	ja     801628 <__umoddi3+0x128>
  801548:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154b:	29 f8                	sub    %edi,%eax
  80154d:	19 d6                	sbb    %edx,%esi
  80154f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801555:	89 f2                	mov    %esi,%edx
  801557:	83 c4 20             	add    $0x20,%esp
  80155a:	5e                   	pop    %esi
  80155b:	5f                   	pop    %edi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    
  80155e:	66 90                	xchg   %ax,%ax
  801560:	85 ff                	test   %edi,%edi
  801562:	75 0b                	jne    80156f <__umoddi3+0x6f>
  801564:	b8 01 00 00 00       	mov    $0x1,%eax
  801569:	31 d2                	xor    %edx,%edx
  80156b:	f7 f7                	div    %edi
  80156d:	89 c7                	mov    %eax,%edi
  80156f:	89 f0                	mov    %esi,%eax
  801571:	31 d2                	xor    %edx,%edx
  801573:	f7 f7                	div    %edi
  801575:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801578:	f7 f7                	div    %edi
  80157a:	eb a9                	jmp    801525 <__umoddi3+0x25>
  80157c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801580:	89 c8                	mov    %ecx,%eax
  801582:	89 f2                	mov    %esi,%edx
  801584:	83 c4 20             	add    $0x20,%esp
  801587:	5e                   	pop    %esi
  801588:	5f                   	pop    %edi
  801589:	5d                   	pop    %ebp
  80158a:	c3                   	ret    
  80158b:	90                   	nop
  80158c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801590:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801594:	d3 e2                	shl    %cl,%edx
  801596:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801599:	ba 20 00 00 00       	mov    $0x20,%edx
  80159e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8015a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015a8:	89 fa                	mov    %edi,%edx
  8015aa:	d3 ea                	shr    %cl,%edx
  8015ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8015b3:	d3 e7                	shl    %cl,%edi
  8015b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015bc:	89 f2                	mov    %esi,%edx
  8015be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	d3 ea                	shr    %cl,%edx
  8015c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	d3 e6                	shl    %cl,%esi
  8015d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8015d4:	d3 ea                	shr    %cl,%edx
  8015d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015da:	09 d6                	or     %edx,%esi
  8015dc:	89 f0                	mov    %esi,%eax
  8015de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015e1:	d3 e7                	shl    %cl,%edi
  8015e3:	89 f2                	mov    %esi,%edx
  8015e5:	f7 75 f4             	divl   -0xc(%ebp)
  8015e8:	89 d6                	mov    %edx,%esi
  8015ea:	f7 65 e8             	mull   -0x18(%ebp)
  8015ed:	39 d6                	cmp    %edx,%esi
  8015ef:	72 2b                	jb     80161c <__umoddi3+0x11c>
  8015f1:	39 c7                	cmp    %eax,%edi
  8015f3:	72 23                	jb     801618 <__umoddi3+0x118>
  8015f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8015f9:	29 c7                	sub    %eax,%edi
  8015fb:	19 d6                	sbb    %edx,%esi
  8015fd:	89 f0                	mov    %esi,%eax
  8015ff:	89 f2                	mov    %esi,%edx
  801601:	d3 ef                	shr    %cl,%edi
  801603:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801607:	d3 e0                	shl    %cl,%eax
  801609:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80160d:	09 f8                	or     %edi,%eax
  80160f:	d3 ea                	shr    %cl,%edx
  801611:	83 c4 20             	add    $0x20,%esp
  801614:	5e                   	pop    %esi
  801615:	5f                   	pop    %edi
  801616:	5d                   	pop    %ebp
  801617:	c3                   	ret    
  801618:	39 d6                	cmp    %edx,%esi
  80161a:	75 d9                	jne    8015f5 <__umoddi3+0xf5>
  80161c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80161f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801622:	eb d1                	jmp    8015f5 <__umoddi3+0xf5>
  801624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801628:	39 f2                	cmp    %esi,%edx
  80162a:	0f 82 18 ff ff ff    	jb     801548 <__umoddi3+0x48>
  801630:	e9 1d ff ff ff       	jmp    801552 <__umoddi3+0x52>
