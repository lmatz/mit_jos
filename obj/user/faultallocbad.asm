
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80003a:	c7 04 24 5c 00 80 00 	movl   $0x80005c,(%esp)
  800041:	e8 56 0f 00 00       	call   800f9c <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  800046:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80004d:	00 
  80004e:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  800055:	e8 96 0b 00 00       	call   800bf0 <sys_cputs>
}
  80005a:	c9                   	leave  
  80005b:	c3                   	ret    

0080005c <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	53                   	push   %ebx
  800060:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800063:	8b 45 08             	mov    0x8(%ebp),%eax
  800066:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800068:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80006c:	c7 04 24 c0 12 80 00 	movl   $0x8012c0,(%esp)
  800073:	e8 89 01 00 00       	call   800201 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800078:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80007f:	00 
  800080:	89 d8                	mov    %ebx,%eax
  800082:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800092:	e8 ab 0d 00 00       	call   800e42 <sys_page_alloc>
  800097:	85 c0                	test   %eax,%eax
  800099:	79 24                	jns    8000bf <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80009b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a3:	c7 44 24 08 e0 12 80 	movl   $0x8012e0,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 ca 12 80 00 	movl   $0x8012ca,(%esp)
  8000ba:	e8 89 00 00 00       	call   800148 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000c3:	c7 44 24 08 0c 13 80 	movl   $0x80130c,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000d2:	00 
  8000d3:	89 1c 24             	mov    %ebx,(%esp)
  8000d6:	e8 f7 06 00 00       	call   8007d2 <snprintf>
}
  8000db:	83 c4 24             	add    $0x24,%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  8000f6:	e8 da 0d 00 00       	call   800ed5 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 f6                	test   %esi,%esi
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 03                	mov    (%ebx),%eax
  800113:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800118:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80011c:	89 34 24             	mov    %esi,(%esp)
  80011f:	e8 10 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 c3 0d 00 00       	call   800f09 <sys_env_destroy>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
  80014d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800150:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800159:	e8 77 0d 00 00       	call   800ed5 <sys_getenvid>
  80015e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800161:	89 54 24 10          	mov    %edx,0x10(%esp)
  800165:	8b 55 08             	mov    0x8(%ebp),%edx
  800168:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80016c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800170:	89 44 24 04          	mov    %eax,0x4(%esp)
  800174:	c7 04 24 38 13 80 00 	movl   $0x801338,(%esp)
  80017b:	e8 81 00 00 00       	call   800201 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	89 74 24 04          	mov    %esi,0x4(%esp)
  800184:	8b 45 10             	mov    0x10(%ebp),%eax
  800187:	89 04 24             	mov    %eax,(%esp)
  80018a:	e8 11 00 00 00       	call   8001a0 <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 c8 12 80 00 	movl   $0x8012c8,(%esp)
  800196:	e8 66 00 00 00       	call   800201 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x53>
	...

008001a0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001cb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d5:	c7 04 24 1b 02 80 00 	movl   $0x80021b,(%esp)
  8001dc:	e8 be 01 00 00       	call   80039f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001eb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f1:	89 04 24             	mov    %eax,(%esp)
  8001f4:	e8 f7 09 00 00       	call   800bf0 <sys_cputs>

	return b.cnt;
}
  8001f9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    

00800201 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800207:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80020a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 04 24             	mov    %eax,(%esp)
  800214:	e8 87 ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	53                   	push   %ebx
  80021f:	83 ec 14             	sub    $0x14,%esp
  800222:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800225:	8b 03                	mov    (%ebx),%eax
  800227:	8b 55 08             	mov    0x8(%ebp),%edx
  80022a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80022e:	83 c0 01             	add    $0x1,%eax
  800231:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800233:	3d ff 00 00 00       	cmp    $0xff,%eax
  800238:	75 19                	jne    800253 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80023a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800241:	00 
  800242:	8d 43 08             	lea    0x8(%ebx),%eax
  800245:	89 04 24             	mov    %eax,(%esp)
  800248:	e8 a3 09 00 00       	call   800bf0 <sys_cputs>
		b->idx = 0;
  80024d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800253:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800257:	83 c4 14             	add    $0x14,%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    
  80025d:	00 00                	add    %al,(%eax)
	...

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 4c             	sub    $0x4c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d6                	mov    %edx,%esi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800274:	8b 55 0c             	mov    0xc(%ebp),%edx
  800277:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80027a:	8b 45 10             	mov    0x10(%ebp),%eax
  80027d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800280:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800283:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800286:	b9 00 00 00 00       	mov    $0x0,%ecx
  80028b:	39 d1                	cmp    %edx,%ecx
  80028d:	72 07                	jb     800296 <printnum+0x36>
  80028f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800292:	39 d0                	cmp    %edx,%eax
  800294:	77 69                	ja     8002ff <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800296:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002a9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002ad:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002b0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002b3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c1:	00 
  8002c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002cb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cf:	e8 6c 0d 00 00       	call   801040 <__udivdi3>
  8002d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002de:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e2:	89 04 24             	mov    %eax,(%esp)
  8002e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e9:	89 f2                	mov    %esi,%edx
  8002eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ee:	e8 6d ff ff ff       	call   800260 <printnum>
  8002f3:	eb 11                	jmp    800306 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f9:	89 3c 24             	mov    %edi,(%esp)
  8002fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ff:	83 eb 01             	sub    $0x1,%ebx
  800302:	85 db                	test   %ebx,%ebx
  800304:	7f ef                	jg     8002f5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800306:	89 74 24 04          	mov    %esi,0x4(%esp)
  80030a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80030e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800311:	89 44 24 08          	mov    %eax,0x8(%esp)
  800315:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031c:	00 
  80031d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800320:	89 14 24             	mov    %edx,(%esp)
  800323:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800326:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80032a:	e8 41 0e 00 00       	call   801170 <__umoddi3>
  80032f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800333:	0f be 80 5b 13 80 00 	movsbl 0x80135b(%eax),%eax
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800340:	83 c4 4c             	add    $0x4c,%esp
  800343:	5b                   	pop    %ebx
  800344:	5e                   	pop    %esi
  800345:	5f                   	pop    %edi
  800346:	5d                   	pop    %ebp
  800347:	c3                   	ret    

00800348 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800348:	55                   	push   %ebp
  800349:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80034b:	83 fa 01             	cmp    $0x1,%edx
  80034e:	7e 0e                	jle    80035e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 08             	lea    0x8(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	8b 52 04             	mov    0x4(%edx),%edx
  80035c:	eb 22                	jmp    800380 <getuint+0x38>
	else if (lflag)
  80035e:	85 d2                	test   %edx,%edx
  800360:	74 10                	je     800372 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800362:	8b 10                	mov    (%eax),%edx
  800364:	8d 4a 04             	lea    0x4(%edx),%ecx
  800367:	89 08                	mov    %ecx,(%eax)
  800369:	8b 02                	mov    (%edx),%eax
  80036b:	ba 00 00 00 00       	mov    $0x0,%edx
  800370:	eb 0e                	jmp    800380 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800372:	8b 10                	mov    (%eax),%edx
  800374:	8d 4a 04             	lea    0x4(%edx),%ecx
  800377:	89 08                	mov    %ecx,(%eax)
  800379:	8b 02                	mov    (%edx),%eax
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800388:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038c:	8b 10                	mov    (%eax),%edx
  80038e:	3b 50 04             	cmp    0x4(%eax),%edx
  800391:	73 0a                	jae    80039d <sprintputch+0x1b>
		*b->buf++ = ch;
  800393:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800396:	88 0a                	mov    %cl,(%edx)
  800398:	83 c2 01             	add    $0x1,%edx
  80039b:	89 10                	mov    %edx,(%eax)
}
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 4c             	sub    $0x4c,%esp
  8003a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003b1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003b8:	eb 11                	jmp    8003cb <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ba:	85 c0                	test   %eax,%eax
  8003bc:	0f 84 b0 03 00 00    	je     800772 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  8003c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c6:	89 04 24             	mov    %eax,(%esp)
  8003c9:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003cb:	0f b6 03             	movzbl (%ebx),%eax
  8003ce:	83 c3 01             	add    $0x1,%ebx
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e4                	jne    8003ba <vprintfmt+0x1b>
  8003d6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e2:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8003e6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ed:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003f4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003f7:	eb 06                	jmp    8003ff <vprintfmt+0x60>
  8003f9:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8003fd:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	0f b6 0b             	movzbl (%ebx),%ecx
  800402:	0f b6 c1             	movzbl %cl,%eax
  800405:	8d 53 01             	lea    0x1(%ebx),%edx
  800408:	83 e9 23             	sub    $0x23,%ecx
  80040b:	80 f9 55             	cmp    $0x55,%cl
  80040e:	0f 87 41 03 00 00    	ja     800755 <vprintfmt+0x3b6>
  800414:	0f b6 c9             	movzbl %cl,%ecx
  800417:	ff 24 8d 20 14 80 00 	jmp    *0x801420(,%ecx,4)
  80041e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800422:	eb d9                	jmp    8003fd <vprintfmt+0x5e>
  800424:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80042b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800430:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800433:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800437:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80043a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80043d:	83 fb 09             	cmp    $0x9,%ebx
  800440:	77 2b                	ja     80046d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800442:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800445:	eb e9                	jmp    800430 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	8d 48 04             	lea    0x4(%eax),%ecx
  80044d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800450:	8b 00                	mov    (%eax),%eax
  800452:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800455:	eb 19                	jmp    800470 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80045a:	c1 f8 1f             	sar    $0x1f,%eax
  80045d:	f7 d0                	not    %eax
  80045f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800462:	eb 99                	jmp    8003fd <vprintfmt+0x5e>
  800464:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80046b:	eb 90                	jmp    8003fd <vprintfmt+0x5e>
  80046d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800474:	79 87                	jns    8003fd <vprintfmt+0x5e>
  800476:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800479:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80047f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800482:	e9 76 ff ff ff       	jmp    8003fd <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800487:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80048b:	e9 6d ff ff ff       	jmp    8003fd <vprintfmt+0x5e>
  800490:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8d 50 04             	lea    0x4(%eax),%edx
  800499:	89 55 14             	mov    %edx,0x14(%ebp)
  80049c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a0:	8b 00                	mov    (%eax),%eax
  8004a2:	89 04 24             	mov    %eax,(%esp)
  8004a5:	ff d7                	call   *%edi
  8004a7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8004aa:	e9 1c ff ff ff       	jmp    8003cb <vprintfmt+0x2c>
  8004af:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 00                	mov    (%eax),%eax
  8004bd:	89 c2                	mov    %eax,%edx
  8004bf:	c1 fa 1f             	sar    $0x1f,%edx
  8004c2:	31 d0                	xor    %edx,%eax
  8004c4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c6:	83 f8 09             	cmp    $0x9,%eax
  8004c9:	7f 0b                	jg     8004d6 <vprintfmt+0x137>
  8004cb:	8b 14 85 80 15 80 00 	mov    0x801580(,%eax,4),%edx
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	75 20                	jne    8004f6 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  8004d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004da:	c7 44 24 08 6c 13 80 	movl   $0x80136c,0x8(%esp)
  8004e1:	00 
  8004e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e6:	89 3c 24             	mov    %edi,(%esp)
  8004e9:	e8 0c 03 00 00       	call   8007fa <printfmt>
  8004ee:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f1:	e9 d5 fe ff ff       	jmp    8003cb <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004f6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004fa:	c7 44 24 08 75 13 80 	movl   $0x801375,0x8(%esp)
  800501:	00 
  800502:	89 74 24 04          	mov    %esi,0x4(%esp)
  800506:	89 3c 24             	mov    %edi,(%esp)
  800509:	e8 ec 02 00 00       	call   8007fa <printfmt>
  80050e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800511:	e9 b5 fe ff ff       	jmp    8003cb <vprintfmt+0x2c>
  800516:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800519:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80051f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	8b 18                	mov    (%eax),%ebx
  80052d:	85 db                	test   %ebx,%ebx
  80052f:	75 05                	jne    800536 <vprintfmt+0x197>
  800531:	bb 78 13 80 00       	mov    $0x801378,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800536:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053a:	7e 76                	jle    8005b2 <vprintfmt+0x213>
  80053c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800540:	74 7a                	je     8005bc <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800546:	89 1c 24             	mov    %ebx,(%esp)
  800549:	e8 fa 02 00 00       	call   800848 <strnlen>
  80054e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800551:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800553:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800557:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80055a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80055d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	eb 0f                	jmp    800570 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800561:	89 74 24 04          	mov    %esi,0x4(%esp)
  800565:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056d:	83 eb 01             	sub    $0x1,%ebx
  800570:	85 db                	test   %ebx,%ebx
  800572:	7f ed                	jg     800561 <vprintfmt+0x1c2>
  800574:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800577:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80057a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80057d:	89 f7                	mov    %esi,%edi
  80057f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800582:	eb 40                	jmp    8005c4 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800584:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800588:	74 18                	je     8005a2 <vprintfmt+0x203>
  80058a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80058d:	83 fa 5e             	cmp    $0x5e,%edx
  800590:	76 10                	jbe    8005a2 <vprintfmt+0x203>
					putch('?', putdat);
  800592:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800596:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80059d:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a0:	eb 0a                	jmp    8005ac <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a6:	89 04 24             	mov    %eax,(%esp)
  8005a9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ac:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005b0:	eb 12                	jmp    8005c4 <vprintfmt+0x225>
  8005b2:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005b5:	89 f7                	mov    %esi,%edi
  8005b7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005ba:	eb 08                	jmp    8005c4 <vprintfmt+0x225>
  8005bc:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005bf:	89 f7                	mov    %esi,%edi
  8005c1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005c4:	0f be 03             	movsbl (%ebx),%eax
  8005c7:	83 c3 01             	add    $0x1,%ebx
  8005ca:	85 c0                	test   %eax,%eax
  8005cc:	74 25                	je     8005f3 <vprintfmt+0x254>
  8005ce:	85 f6                	test   %esi,%esi
  8005d0:	78 b2                	js     800584 <vprintfmt+0x1e5>
  8005d2:	83 ee 01             	sub    $0x1,%esi
  8005d5:	79 ad                	jns    800584 <vprintfmt+0x1e5>
  8005d7:	89 fe                	mov    %edi,%esi
  8005d9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005dc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005df:	eb 1a                	jmp    8005fb <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ec:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ee:	83 eb 01             	sub    $0x1,%ebx
  8005f1:	eb 08                	jmp    8005fb <vprintfmt+0x25c>
  8005f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f6:	89 fe                	mov    %edi,%esi
  8005f8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005fb:	85 db                	test   %ebx,%ebx
  8005fd:	7f e2                	jg     8005e1 <vprintfmt+0x242>
  8005ff:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800602:	e9 c4 fd ff ff       	jmp    8003cb <vprintfmt+0x2c>
  800607:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80060a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060d:	83 f9 01             	cmp    $0x1,%ecx
  800610:	7e 16                	jle    800628 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 08             	lea    0x8(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	8b 48 04             	mov    0x4(%eax),%ecx
  800620:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800623:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800626:	eb 32                	jmp    80065a <vprintfmt+0x2bb>
	else if (lflag)
  800628:	85 c9                	test   %ecx,%ecx
  80062a:	74 18                	je     800644 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 00                	mov    (%eax),%eax
  800637:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063a:	89 c1                	mov    %eax,%ecx
  80063c:	c1 f9 1f             	sar    $0x1f,%ecx
  80063f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800642:	eb 16                	jmp    80065a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 50 04             	lea    0x4(%eax),%edx
  80064a:	89 55 14             	mov    %edx,0x14(%ebp)
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800652:	89 c2                	mov    %eax,%edx
  800654:	c1 fa 1f             	sar    $0x1f,%edx
  800657:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80065a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80065d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800660:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800665:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800669:	0f 89 a7 00 00 00    	jns    800716 <vprintfmt+0x377>
				putch('-', putdat);
  80066f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800673:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80067a:	ff d7                	call   *%edi
				num = -(long long) num;
  80067c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80067f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800682:	f7 d9                	neg    %ecx
  800684:	83 d3 00             	adc    $0x0,%ebx
  800687:	f7 db                	neg    %ebx
  800689:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068e:	e9 83 00 00 00       	jmp    800716 <vprintfmt+0x377>
  800693:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800696:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 a5 fc ff ff       	call   800348 <getuint>
  8006a3:	89 c1                	mov    %eax,%ecx
  8006a5:	89 d3                	mov    %edx,%ebx
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006ac:	eb 68                	jmp    800716 <vprintfmt+0x377>
  8006ae:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006b1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006b4:	89 ca                	mov    %ecx,%edx
  8006b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b9:	e8 8a fc ff ff       	call   800348 <getuint>
  8006be:	89 c1                	mov    %eax,%ecx
  8006c0:	89 d3                	mov    %edx,%ebx
  8006c2:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8006c7:	eb 4d                	jmp    800716 <vprintfmt+0x377>
  8006c9:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d7:	ff d7                	call   *%edi
			putch('x', putdat);
  8006d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006dd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e4:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ef:	8b 08                	mov    (%eax),%ecx
  8006f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f6:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006fb:	eb 19                	jmp    800716 <vprintfmt+0x377>
  8006fd:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800700:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800703:	89 ca                	mov    %ecx,%edx
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
  800708:	e8 3b fc ff ff       	call   800348 <getuint>
  80070d:	89 c1                	mov    %eax,%ecx
  80070f:	89 d3                	mov    %edx,%ebx
  800711:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800716:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80071a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80071e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800721:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800725:	89 44 24 08          	mov    %eax,0x8(%esp)
  800729:	89 0c 24             	mov    %ecx,(%esp)
  80072c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800730:	89 f2                	mov    %esi,%edx
  800732:	89 f8                	mov    %edi,%eax
  800734:	e8 27 fb ff ff       	call   800260 <printnum>
  800739:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80073c:	e9 8a fc ff ff       	jmp    8003cb <vprintfmt+0x2c>
  800741:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800744:	89 74 24 04          	mov    %esi,0x4(%esp)
  800748:	89 04 24             	mov    %eax,(%esp)
  80074b:	ff d7                	call   *%edi
  80074d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800750:	e9 76 fc ff ff       	jmp    8003cb <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800755:	89 74 24 04          	mov    %esi,0x4(%esp)
  800759:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800760:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800762:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800765:	80 38 25             	cmpb   $0x25,(%eax)
  800768:	0f 84 5d fc ff ff    	je     8003cb <vprintfmt+0x2c>
  80076e:	89 c3                	mov    %eax,%ebx
  800770:	eb f0                	jmp    800762 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800772:	83 c4 4c             	add    $0x4c,%esp
  800775:	5b                   	pop    %ebx
  800776:	5e                   	pop    %esi
  800777:	5f                   	pop    %edi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	83 ec 28             	sub    $0x28,%esp
  800780:	8b 45 08             	mov    0x8(%ebp),%eax
  800783:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800786:	85 c0                	test   %eax,%eax
  800788:	74 04                	je     80078e <vsnprintf+0x14>
  80078a:	85 d2                	test   %edx,%edx
  80078c:	7f 07                	jg     800795 <vsnprintf+0x1b>
  80078e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800793:	eb 3b                	jmp    8007d0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800795:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800798:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80079c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80079f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bb:	c7 04 24 82 03 80 00 	movl   $0x800382,(%esp)
  8007c2:	e8 d8 fb ff ff       	call   80039f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007d8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007df:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f0:	89 04 24             	mov    %eax,(%esp)
  8007f3:	e8 82 ff ff ff       	call   80077a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800800:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800807:	8b 45 10             	mov    0x10(%ebp),%eax
  80080a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800811:	89 44 24 04          	mov    %eax,0x4(%esp)
  800815:	8b 45 08             	mov    0x8(%ebp),%eax
  800818:	89 04 24             	mov    %eax,(%esp)
  80081b:	e8 7f fb ff ff       	call   80039f <vprintfmt>
	va_end(ap);
}
  800820:	c9                   	leave  
  800821:	c3                   	ret    
	...

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  80083b:	eb 03                	jmp    800840 <strlen+0x10>
		n++;
  80083d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800840:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800844:	75 f7                	jne    80083d <strlen+0xd>
		n++;
	return n;
}
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80084f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800857:	eb 03                	jmp    80085c <strnlen+0x14>
		n++;
  800859:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80085c:	39 c1                	cmp    %eax,%ecx
  80085e:	74 06                	je     800866 <strnlen+0x1e>
  800860:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800864:	75 f3                	jne    800859 <strnlen+0x11>
		n++;
	return n;
}
  800866:	5b                   	pop    %ebx
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    

00800869 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	8b 45 08             	mov    0x8(%ebp),%eax
  800870:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800873:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800878:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80087c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80087f:	83 c2 01             	add    $0x1,%edx
  800882:	84 c9                	test   %cl,%cl
  800884:	75 f2                	jne    800878 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800886:	5b                   	pop    %ebx
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800893:	89 1c 24             	mov    %ebx,(%esp)
  800896:	e8 95 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008a5:	89 04 24             	mov    %eax,(%esp)
  8008a8:	e8 bc ff ff ff       	call   800869 <strcpy>
	return dst;
}
  8008ad:	89 d8                	mov    %ebx,%eax
  8008af:	83 c4 08             	add    $0x8,%esp
  8008b2:	5b                   	pop    %ebx
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c0:	8b 75 10             	mov    0x10(%ebp),%esi
  8008c3:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c8:	eb 0f                	jmp    8008d9 <strncpy+0x24>
		*dst++ = *src;
  8008ca:	0f b6 19             	movzbl (%ecx),%ebx
  8008cd:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008d3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d6:	83 c2 01             	add    $0x1,%edx
  8008d9:	39 f2                	cmp    %esi,%edx
  8008db:	72 ed                	jb     8008ca <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5e                   	pop    %esi
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	56                   	push   %esi
  8008e5:	53                   	push   %ebx
  8008e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ec:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ef:	89 f0                	mov    %esi,%eax
  8008f1:	85 d2                	test   %edx,%edx
  8008f3:	75 0a                	jne    8008ff <strlcpy+0x1e>
  8008f5:	eb 17                	jmp    80090e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008f7:	88 18                	mov    %bl,(%eax)
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ff:	83 ea 01             	sub    $0x1,%edx
  800902:	74 07                	je     80090b <strlcpy+0x2a>
  800904:	0f b6 19             	movzbl (%ecx),%ebx
  800907:	84 db                	test   %bl,%bl
  800909:	75 ec                	jne    8008f7 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80090b:	c6 00 00             	movb   $0x0,(%eax)
  80090e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091d:	eb 06                	jmp    800925 <strcmp+0x11>
		p++, q++;
  80091f:	83 c1 01             	add    $0x1,%ecx
  800922:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800925:	0f b6 01             	movzbl (%ecx),%eax
  800928:	84 c0                	test   %al,%al
  80092a:	74 04                	je     800930 <strcmp+0x1c>
  80092c:	3a 02                	cmp    (%edx),%al
  80092e:	74 ef                	je     80091f <strcmp+0xb>
  800930:	0f b6 c0             	movzbl %al,%eax
  800933:	0f b6 12             	movzbl (%edx),%edx
  800936:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800944:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800947:	eb 09                	jmp    800952 <strncmp+0x18>
		n--, p++, q++;
  800949:	83 ea 01             	sub    $0x1,%edx
  80094c:	83 c0 01             	add    $0x1,%eax
  80094f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800952:	85 d2                	test   %edx,%edx
  800954:	75 07                	jne    80095d <strncmp+0x23>
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	eb 13                	jmp    800970 <strncmp+0x36>
  80095d:	0f b6 18             	movzbl (%eax),%ebx
  800960:	84 db                	test   %bl,%bl
  800962:	74 04                	je     800968 <strncmp+0x2e>
  800964:	3a 19                	cmp    (%ecx),%bl
  800966:	74 e1                	je     800949 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 00             	movzbl (%eax),%eax
  80096b:	0f b6 11             	movzbl (%ecx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5b                   	pop    %ebx
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097d:	eb 07                	jmp    800986 <strchr+0x13>
		if (*s == c)
  80097f:	38 ca                	cmp    %cl,%dl
  800981:	74 0f                	je     800992 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	0f b6 10             	movzbl (%eax),%edx
  800989:	84 d2                	test   %dl,%dl
  80098b:	75 f2                	jne    80097f <strchr+0xc>
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099e:	eb 07                	jmp    8009a7 <strfind+0x13>
		if (*s == c)
  8009a0:	38 ca                	cmp    %cl,%dl
  8009a2:	74 0a                	je     8009ae <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009a4:	83 c0 01             	add    $0x1,%eax
  8009a7:	0f b6 10             	movzbl (%eax),%edx
  8009aa:	84 d2                	test   %dl,%dl
  8009ac:	75 f2                	jne    8009a0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ae:	5d                   	pop    %ebp
  8009af:	90                   	nop
  8009b0:	c3                   	ret    

008009b1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	83 ec 0c             	sub    $0xc,%esp
  8009b7:	89 1c 24             	mov    %ebx,(%esp)
  8009ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009be:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009cb:	85 c9                	test   %ecx,%ecx
  8009cd:	74 30                	je     8009ff <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d5:	75 25                	jne    8009fc <memset+0x4b>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 20                	jne    8009fc <memset+0x4b>
		c &= 0xFF;
  8009dc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009df:	89 d3                	mov    %edx,%ebx
  8009e1:	c1 e3 08             	shl    $0x8,%ebx
  8009e4:	89 d6                	mov    %edx,%esi
  8009e6:	c1 e6 18             	shl    $0x18,%esi
  8009e9:	89 d0                	mov    %edx,%eax
  8009eb:	c1 e0 10             	shl    $0x10,%eax
  8009ee:	09 f0                	or     %esi,%eax
  8009f0:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009f2:	09 d8                	or     %ebx,%eax
  8009f4:	c1 e9 02             	shr    $0x2,%ecx
  8009f7:	fc                   	cld    
  8009f8:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009fa:	eb 03                	jmp    8009ff <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009fc:	fc                   	cld    
  8009fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ff:	89 f8                	mov    %edi,%eax
  800a01:	8b 1c 24             	mov    (%esp),%ebx
  800a04:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a08:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a0c:	89 ec                	mov    %ebp,%esp
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	89 34 24             	mov    %esi,(%esp)
  800a19:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a23:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a26:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a28:	39 c6                	cmp    %eax,%esi
  800a2a:	73 35                	jae    800a61 <memmove+0x51>
  800a2c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2f:	39 d0                	cmp    %edx,%eax
  800a31:	73 2e                	jae    800a61 <memmove+0x51>
		s += n;
		d += n;
  800a33:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a35:	f6 c2 03             	test   $0x3,%dl
  800a38:	75 1b                	jne    800a55 <memmove+0x45>
  800a3a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a40:	75 13                	jne    800a55 <memmove+0x45>
  800a42:	f6 c1 03             	test   $0x3,%cl
  800a45:	75 0e                	jne    800a55 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a47:	83 ef 04             	sub    $0x4,%edi
  800a4a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a4d:	c1 e9 02             	shr    $0x2,%ecx
  800a50:	fd                   	std    
  800a51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a53:	eb 09                	jmp    800a5e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a55:	83 ef 01             	sub    $0x1,%edi
  800a58:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a5b:	fd                   	std    
  800a5c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a5e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a5f:	eb 20                	jmp    800a81 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a61:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a67:	75 15                	jne    800a7e <memmove+0x6e>
  800a69:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6f:	75 0d                	jne    800a7e <memmove+0x6e>
  800a71:	f6 c1 03             	test   $0x3,%cl
  800a74:	75 08                	jne    800a7e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a76:	c1 e9 02             	shr    $0x2,%ecx
  800a79:	fc                   	cld    
  800a7a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7c:	eb 03                	jmp    800a81 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a7e:	fc                   	cld    
  800a7f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a81:	8b 34 24             	mov    (%esp),%esi
  800a84:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a88:	89 ec                	mov    %ebp,%esp
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a92:	8b 45 10             	mov    0x10(%ebp),%eax
  800a95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 65 ff ff ff       	call   800a10 <memmove>
}
  800aab:	c9                   	leave  
  800aac:	c3                   	ret    

00800aad <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	57                   	push   %edi
  800ab1:	56                   	push   %esi
  800ab2:	53                   	push   %ebx
  800ab3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800abc:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac1:	eb 1c                	jmp    800adf <memcmp+0x32>
		if (*s1 != *s2)
  800ac3:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800ac7:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800acb:	83 c2 01             	add    $0x1,%edx
  800ace:	83 e9 01             	sub    $0x1,%ecx
  800ad1:	38 d8                	cmp    %bl,%al
  800ad3:	74 0a                	je     800adf <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800ad5:	0f b6 c0             	movzbl %al,%eax
  800ad8:	0f b6 db             	movzbl %bl,%ebx
  800adb:	29 d8                	sub    %ebx,%eax
  800add:	eb 09                	jmp    800ae8 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adf:	85 c9                	test   %ecx,%ecx
  800ae1:	75 e0                	jne    800ac3 <memcmp+0x16>
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5f                   	pop    %edi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800af6:	89 c2                	mov    %eax,%edx
  800af8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800afb:	eb 07                	jmp    800b04 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afd:	38 08                	cmp    %cl,(%eax)
  800aff:	74 07                	je     800b08 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	39 d0                	cmp    %edx,%eax
  800b06:	72 f5                	jb     800afd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	83 ec 04             	sub    $0x4,%esp
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b19:	eb 03                	jmp    800b1e <strtol+0x14>
		s++;
  800b1b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1e:	0f b6 02             	movzbl (%edx),%eax
  800b21:	3c 20                	cmp    $0x20,%al
  800b23:	74 f6                	je     800b1b <strtol+0x11>
  800b25:	3c 09                	cmp    $0x9,%al
  800b27:	74 f2                	je     800b1b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b29:	3c 2b                	cmp    $0x2b,%al
  800b2b:	75 0c                	jne    800b39 <strtol+0x2f>
		s++;
  800b2d:	8d 52 01             	lea    0x1(%edx),%edx
  800b30:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b37:	eb 15                	jmp    800b4e <strtol+0x44>
	else if (*s == '-')
  800b39:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b40:	3c 2d                	cmp    $0x2d,%al
  800b42:	75 0a                	jne    800b4e <strtol+0x44>
		s++, neg = 1;
  800b44:	8d 52 01             	lea    0x1(%edx),%edx
  800b47:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4e:	85 db                	test   %ebx,%ebx
  800b50:	0f 94 c0             	sete   %al
  800b53:	74 05                	je     800b5a <strtol+0x50>
  800b55:	83 fb 10             	cmp    $0x10,%ebx
  800b58:	75 18                	jne    800b72 <strtol+0x68>
  800b5a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b5d:	75 13                	jne    800b72 <strtol+0x68>
  800b5f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b63:	75 0d                	jne    800b72 <strtol+0x68>
		s += 2, base = 16;
  800b65:	83 c2 02             	add    $0x2,%edx
  800b68:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6d:	8d 76 00             	lea    0x0(%esi),%esi
  800b70:	eb 13                	jmp    800b85 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b72:	84 c0                	test   %al,%al
  800b74:	74 0f                	je     800b85 <strtol+0x7b>
  800b76:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b7b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7e:	75 05                	jne    800b85 <strtol+0x7b>
		s++, base = 8;
  800b80:	83 c2 01             	add    $0x1,%edx
  800b83:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b85:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b8c:	0f b6 0a             	movzbl (%edx),%ecx
  800b8f:	89 cf                	mov    %ecx,%edi
  800b91:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b94:	80 fb 09             	cmp    $0x9,%bl
  800b97:	77 08                	ja     800ba1 <strtol+0x97>
			dig = *s - '0';
  800b99:	0f be c9             	movsbl %cl,%ecx
  800b9c:	83 e9 30             	sub    $0x30,%ecx
  800b9f:	eb 1e                	jmp    800bbf <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800ba1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ba4:	80 fb 19             	cmp    $0x19,%bl
  800ba7:	77 08                	ja     800bb1 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800ba9:	0f be c9             	movsbl %cl,%ecx
  800bac:	83 e9 57             	sub    $0x57,%ecx
  800baf:	eb 0e                	jmp    800bbf <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800bb1:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bb4:	80 fb 19             	cmp    $0x19,%bl
  800bb7:	77 15                	ja     800bce <strtol+0xc4>
			dig = *s - 'A' + 10;
  800bb9:	0f be c9             	movsbl %cl,%ecx
  800bbc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bbf:	39 f1                	cmp    %esi,%ecx
  800bc1:	7d 0b                	jge    800bce <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800bc3:	83 c2 01             	add    $0x1,%edx
  800bc6:	0f af c6             	imul   %esi,%eax
  800bc9:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bcc:	eb be                	jmp    800b8c <strtol+0x82>
  800bce:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bd0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bd4:	74 05                	je     800bdb <strtol+0xd1>
		*endptr = (char *) s;
  800bd6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bd9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bdb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bdf:	74 04                	je     800be5 <strtol+0xdb>
  800be1:	89 c8                	mov    %ecx,%eax
  800be3:	f7 d8                	neg    %eax
}
  800be5:	83 c4 04             	add    $0x4,%esp
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    
  800bed:	00 00                	add    %al,(%eax)
	...

00800bf0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	89 1c 24             	mov    %ebx,(%esp)
  800bf9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bfd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0c:	89 c3                	mov    %eax,%ebx
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	89 c6                	mov    %eax,%esi
  800c12:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c14:	8b 1c 24             	mov    (%esp),%ebx
  800c17:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c1b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c1f:	89 ec                	mov    %ebp,%esp
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 38             	sub    $0x38,%esp
  800c29:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c2c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c2f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800c32:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c36:	75 0c                	jne    800c44 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800c38:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  800c3f:	e8 bd f5 ff ff       	call   800201 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c49:	b8 09 00 00 00       	mov    $0x9,%eax
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c54:	89 df                	mov    %ebx,%edi
  800c56:	89 de                	mov    %ebx,%esi
  800c58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 28                	jle    800c86 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c62:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c69:	00 
  800c6a:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800c71:	00 
  800c72:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c79:	00 
  800c7a:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800c81:	e8 c2 f4 ff ff       	call   800148 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c86:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c89:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c8c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c8f:	89 ec                	mov    %ebp,%esp
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 38             	sub    $0x38,%esp
  800c99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cac:	8b 55 08             	mov    0x8(%ebp),%edx
  800caf:	89 cb                	mov    %ecx,%ebx
  800cb1:	89 cf                	mov    %ecx,%edi
  800cb3:	89 ce                	mov    %ecx,%esi
  800cb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 28                	jle    800ce3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cbf:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800cc6:	00 
  800cc7:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800cce:	00 
  800ccf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cd6:	00 
  800cd7:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800cde:	e8 65 f4 ff ff       	call   800148 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ce6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ce9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cec:	89 ec                	mov    %ebp,%esp
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	89 1c 24             	mov    %ebx,(%esp)
  800cf9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cfd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	be 00 00 00 00       	mov    $0x0,%esi
  800d06:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d19:	8b 1c 24             	mov    (%esp),%ebx
  800d1c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d20:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d24:	89 ec                	mov    %ebp,%esp
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 38             	sub    $0x38,%esp
  800d2e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d31:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d34:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 df                	mov    %ebx,%edi
  800d49:	89 de                	mov    %ebx,%esi
  800d4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	7e 28                	jle    800d79 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d55:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d5c:	00 
  800d5d:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800d64:	00 
  800d65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d6c:	00 
  800d6d:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800d74:	e8 cf f3 ff ff       	call   800148 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d79:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d7c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d7f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d82:	89 ec                	mov    %ebp,%esp
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	83 ec 38             	sub    $0x38,%esp
  800d8c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d8f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d92:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	89 df                	mov    %ebx,%edi
  800da7:	89 de                	mov    %ebx,%esi
  800da9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 28                	jle    800dd7 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dba:	00 
  800dbb:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dca:	00 
  800dcb:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800dd2:	e8 71 f3 ff ff       	call   800148 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dda:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ddd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800de0:	89 ec                	mov    %ebp,%esp
  800de2:	5d                   	pop    %ebp
  800de3:	c3                   	ret    

00800de4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	83 ec 38             	sub    $0x38,%esp
  800dea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ded:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df3:	b8 05 00 00 00       	mov    $0x5,%eax
  800df8:	8b 75 18             	mov    0x18(%ebp),%esi
  800dfb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	7e 28                	jle    800e35 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e11:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e18:	00 
  800e19:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800e20:	00 
  800e21:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e28:	00 
  800e29:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800e30:	e8 13 f3 ff ff       	call   800148 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e35:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e38:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e3b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e3e:	89 ec                	mov    %ebp,%esp
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	83 ec 38             	sub    $0x38,%esp
  800e48:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e4b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e4e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e51:	be 00 00 00 00       	mov    $0x0,%esi
  800e56:	b8 04 00 00 00       	mov    $0x4,%eax
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	89 f7                	mov    %esi,%edi
  800e66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	7e 28                	jle    800e94 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e70:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e77:	00 
  800e78:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800e7f:	00 
  800e80:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e87:	00 
  800e88:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800e8f:	e8 b4 f2 ff ff       	call   800148 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e94:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e97:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e9a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e9d:	89 ec                	mov    %ebp,%esp
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	89 1c 24             	mov    %ebx,(%esp)
  800eaa:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eae:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ebc:	89 d1                	mov    %edx,%ecx
  800ebe:	89 d3                	mov    %edx,%ebx
  800ec0:	89 d7                	mov    %edx,%edi
  800ec2:	89 d6                	mov    %edx,%esi
  800ec4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ec6:	8b 1c 24             	mov    (%esp),%ebx
  800ec9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ecd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ed1:	89 ec                	mov    %ebp,%esp
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	89 1c 24             	mov    %ebx,(%esp)
  800ede:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee6:	ba 00 00 00 00       	mov    $0x0,%edx
  800eeb:	b8 02 00 00 00       	mov    $0x2,%eax
  800ef0:	89 d1                	mov    %edx,%ecx
  800ef2:	89 d3                	mov    %edx,%ebx
  800ef4:	89 d7                	mov    %edx,%edi
  800ef6:	89 d6                	mov    %edx,%esi
  800ef8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800efa:	8b 1c 24             	mov    (%esp),%ebx
  800efd:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f01:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f05:	89 ec                	mov    %ebp,%esp
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    

00800f09 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 38             	sub    $0x38,%esp
  800f0f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f12:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f15:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f18:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f22:	8b 55 08             	mov    0x8(%ebp),%edx
  800f25:	89 cb                	mov    %ecx,%ebx
  800f27:	89 cf                	mov    %ecx,%edi
  800f29:	89 ce                	mov    %ecx,%esi
  800f2b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	7e 28                	jle    800f59 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f31:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f35:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800f44:	00 
  800f45:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4c:	00 
  800f4d:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800f54:	e8 ef f1 ff ff       	call   800148 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f59:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f5c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f5f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f62:	89 ec                	mov    %ebp,%esp
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	89 1c 24             	mov    %ebx,(%esp)
  800f6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f73:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f77:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f81:	89 d1                	mov    %edx,%ecx
  800f83:	89 d3                	mov    %edx,%ebx
  800f85:	89 d7                	mov    %edx,%edi
  800f87:	89 d6                	mov    %edx,%esi
  800f89:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f8b:	8b 1c 24             	mov    (%esp),%ebx
  800f8e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f92:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f96:	89 ec                	mov    %ebp,%esp
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
	...

00800f9c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fa2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fa9:	75 58                	jne    801003 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  800fab:	a1 04 20 80 00       	mov    0x802004,%eax
  800fb0:	8b 40 48             	mov    0x48(%eax),%eax
  800fb3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fba:	00 
  800fbb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800fc2:	ee 
  800fc3:	89 04 24             	mov    %eax,(%esp)
  800fc6:	e8 77 fe ff ff       	call   800e42 <sys_page_alloc>
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	74 1c                	je     800feb <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  800fcf:	c7 44 24 08 00 16 80 	movl   $0x801600,0x8(%esp)
  800fd6:	00 
  800fd7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800fde:	00 
  800fdf:	c7 04 24 2c 16 80 00 	movl   $0x80162c,(%esp)
  800fe6:	e8 5d f1 ff ff       	call   800148 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  800feb:	a1 04 20 80 00       	mov    0x802004,%eax
  800ff0:	8b 40 48             	mov    0x48(%eax),%eax
  800ff3:	c7 44 24 04 10 10 80 	movl   $0x801010,0x4(%esp)
  800ffa:	00 
  800ffb:	89 04 24             	mov    %eax,(%esp)
  800ffe:	e8 20 fc ff ff       	call   800c23 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801003:	8b 45 08             	mov    0x8(%ebp),%eax
  801006:	a3 08 20 80 00       	mov    %eax,0x802008
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  80100b:	c9                   	leave  
  80100c:	c3                   	ret    
  80100d:	00 00                	add    %al,(%eax)
	...

00801010 <_pgfault_upcall>:
  801010:	54                   	push   %esp
  801011:	a1 08 20 80 00       	mov    0x802008,%eax
  801016:	ff d0                	call   *%eax
  801018:	83 c4 04             	add    $0x4,%esp
  80101b:	89 e3                	mov    %esp,%ebx
  80101d:	8b 44 24 28          	mov    0x28(%esp),%eax
  801021:	8b 64 24 30          	mov    0x30(%esp),%esp
  801025:	50                   	push   %eax
  801026:	89 dc                	mov    %ebx,%esp
  801028:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  80102d:	58                   	pop    %eax
  80102e:	58                   	pop    %eax
  80102f:	61                   	popa   
  801030:	83 c4 04             	add    $0x4,%esp
  801033:	9d                   	popf   
  801034:	5c                   	pop    %esp
  801035:	c3                   	ret    
	...

00801040 <__udivdi3>:
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	83 ec 10             	sub    $0x10,%esp
  801048:	8b 45 14             	mov    0x14(%ebp),%eax
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
  80104e:	8b 75 10             	mov    0x10(%ebp),%esi
  801051:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801054:	85 c0                	test   %eax,%eax
  801056:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801059:	75 35                	jne    801090 <__udivdi3+0x50>
  80105b:	39 fe                	cmp    %edi,%esi
  80105d:	77 61                	ja     8010c0 <__udivdi3+0x80>
  80105f:	85 f6                	test   %esi,%esi
  801061:	75 0b                	jne    80106e <__udivdi3+0x2e>
  801063:	b8 01 00 00 00       	mov    $0x1,%eax
  801068:	31 d2                	xor    %edx,%edx
  80106a:	f7 f6                	div    %esi
  80106c:	89 c6                	mov    %eax,%esi
  80106e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801071:	31 d2                	xor    %edx,%edx
  801073:	89 f8                	mov    %edi,%eax
  801075:	f7 f6                	div    %esi
  801077:	89 c7                	mov    %eax,%edi
  801079:	89 c8                	mov    %ecx,%eax
  80107b:	f7 f6                	div    %esi
  80107d:	89 c1                	mov    %eax,%ecx
  80107f:	89 fa                	mov    %edi,%edx
  801081:	89 c8                	mov    %ecx,%eax
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    
  80108a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801090:	39 f8                	cmp    %edi,%eax
  801092:	77 1c                	ja     8010b0 <__udivdi3+0x70>
  801094:	0f bd d0             	bsr    %eax,%edx
  801097:	83 f2 1f             	xor    $0x1f,%edx
  80109a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80109d:	75 39                	jne    8010d8 <__udivdi3+0x98>
  80109f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8010a2:	0f 86 a0 00 00 00    	jbe    801148 <__udivdi3+0x108>
  8010a8:	39 f8                	cmp    %edi,%eax
  8010aa:	0f 82 98 00 00 00    	jb     801148 <__udivdi3+0x108>
  8010b0:	31 ff                	xor    %edi,%edi
  8010b2:	31 c9                	xor    %ecx,%ecx
  8010b4:	89 c8                	mov    %ecx,%eax
  8010b6:	89 fa                	mov    %edi,%edx
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    
  8010bf:	90                   	nop
  8010c0:	89 d1                	mov    %edx,%ecx
  8010c2:	89 fa                	mov    %edi,%edx
  8010c4:	89 c8                	mov    %ecx,%eax
  8010c6:	31 ff                	xor    %edi,%edi
  8010c8:	f7 f6                	div    %esi
  8010ca:	89 c1                	mov    %eax,%ecx
  8010cc:	89 fa                	mov    %edi,%edx
  8010ce:	89 c8                	mov    %ecx,%eax
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    
  8010d7:	90                   	nop
  8010d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010dc:	89 f2                	mov    %esi,%edx
  8010de:	d3 e0                	shl    %cl,%eax
  8010e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8010e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8010eb:	89 c1                	mov    %eax,%ecx
  8010ed:	d3 ea                	shr    %cl,%edx
  8010ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010f6:	d3 e6                	shl    %cl,%esi
  8010f8:	89 c1                	mov    %eax,%ecx
  8010fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010fd:	89 fe                	mov    %edi,%esi
  8010ff:	d3 ee                	shr    %cl,%esi
  801101:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801105:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801108:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80110b:	d3 e7                	shl    %cl,%edi
  80110d:	89 c1                	mov    %eax,%ecx
  80110f:	d3 ea                	shr    %cl,%edx
  801111:	09 d7                	or     %edx,%edi
  801113:	89 f2                	mov    %esi,%edx
  801115:	89 f8                	mov    %edi,%eax
  801117:	f7 75 ec             	divl   -0x14(%ebp)
  80111a:	89 d6                	mov    %edx,%esi
  80111c:	89 c7                	mov    %eax,%edi
  80111e:	f7 65 e8             	mull   -0x18(%ebp)
  801121:	39 d6                	cmp    %edx,%esi
  801123:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801126:	72 30                	jb     801158 <__udivdi3+0x118>
  801128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80112b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80112f:	d3 e2                	shl    %cl,%edx
  801131:	39 c2                	cmp    %eax,%edx
  801133:	73 05                	jae    80113a <__udivdi3+0xfa>
  801135:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801138:	74 1e                	je     801158 <__udivdi3+0x118>
  80113a:	89 f9                	mov    %edi,%ecx
  80113c:	31 ff                	xor    %edi,%edi
  80113e:	e9 71 ff ff ff       	jmp    8010b4 <__udivdi3+0x74>
  801143:	90                   	nop
  801144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801148:	31 ff                	xor    %edi,%edi
  80114a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80114f:	e9 60 ff ff ff       	jmp    8010b4 <__udivdi3+0x74>
  801154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801158:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80115b:	31 ff                	xor    %edi,%edi
  80115d:	89 c8                	mov    %ecx,%eax
  80115f:	89 fa                	mov    %edi,%edx
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    
	...

00801170 <__umoddi3>:
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	83 ec 20             	sub    $0x20,%esp
  801178:	8b 55 14             	mov    0x14(%ebp),%edx
  80117b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801181:	8b 75 0c             	mov    0xc(%ebp),%esi
  801184:	85 d2                	test   %edx,%edx
  801186:	89 c8                	mov    %ecx,%eax
  801188:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80118b:	75 13                	jne    8011a0 <__umoddi3+0x30>
  80118d:	39 f7                	cmp    %esi,%edi
  80118f:	76 3f                	jbe    8011d0 <__umoddi3+0x60>
  801191:	89 f2                	mov    %esi,%edx
  801193:	f7 f7                	div    %edi
  801195:	89 d0                	mov    %edx,%eax
  801197:	31 d2                	xor    %edx,%edx
  801199:	83 c4 20             	add    $0x20,%esp
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    
  8011a0:	39 f2                	cmp    %esi,%edx
  8011a2:	77 4c                	ja     8011f0 <__umoddi3+0x80>
  8011a4:	0f bd ca             	bsr    %edx,%ecx
  8011a7:	83 f1 1f             	xor    $0x1f,%ecx
  8011aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8011ad:	75 51                	jne    801200 <__umoddi3+0x90>
  8011af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8011b2:	0f 87 e0 00 00 00    	ja     801298 <__umoddi3+0x128>
  8011b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bb:	29 f8                	sub    %edi,%eax
  8011bd:	19 d6                	sbb    %edx,%esi
  8011bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c5:	89 f2                	mov    %esi,%edx
  8011c7:	83 c4 20             	add    $0x20,%esp
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    
  8011ce:	66 90                	xchg   %ax,%ax
  8011d0:	85 ff                	test   %edi,%edi
  8011d2:	75 0b                	jne    8011df <__umoddi3+0x6f>
  8011d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d9:	31 d2                	xor    %edx,%edx
  8011db:	f7 f7                	div    %edi
  8011dd:	89 c7                	mov    %eax,%edi
  8011df:	89 f0                	mov    %esi,%eax
  8011e1:	31 d2                	xor    %edx,%edx
  8011e3:	f7 f7                	div    %edi
  8011e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e8:	f7 f7                	div    %edi
  8011ea:	eb a9                	jmp    801195 <__umoddi3+0x25>
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	89 c8                	mov    %ecx,%eax
  8011f2:	89 f2                	mov    %esi,%edx
  8011f4:	83 c4 20             	add    $0x20,%esp
  8011f7:	5e                   	pop    %esi
  8011f8:	5f                   	pop    %edi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    
  8011fb:	90                   	nop
  8011fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801200:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801204:	d3 e2                	shl    %cl,%edx
  801206:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801209:	ba 20 00 00 00       	mov    $0x20,%edx
  80120e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801211:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801214:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801218:	89 fa                	mov    %edi,%edx
  80121a:	d3 ea                	shr    %cl,%edx
  80121c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801220:	0b 55 f4             	or     -0xc(%ebp),%edx
  801223:	d3 e7                	shl    %cl,%edi
  801225:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801229:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80122c:	89 f2                	mov    %esi,%edx
  80122e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801231:	89 c7                	mov    %eax,%edi
  801233:	d3 ea                	shr    %cl,%edx
  801235:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801239:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	d3 e6                	shl    %cl,%esi
  801240:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801244:	d3 ea                	shr    %cl,%edx
  801246:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80124a:	09 d6                	or     %edx,%esi
  80124c:	89 f0                	mov    %esi,%eax
  80124e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801251:	d3 e7                	shl    %cl,%edi
  801253:	89 f2                	mov    %esi,%edx
  801255:	f7 75 f4             	divl   -0xc(%ebp)
  801258:	89 d6                	mov    %edx,%esi
  80125a:	f7 65 e8             	mull   -0x18(%ebp)
  80125d:	39 d6                	cmp    %edx,%esi
  80125f:	72 2b                	jb     80128c <__umoddi3+0x11c>
  801261:	39 c7                	cmp    %eax,%edi
  801263:	72 23                	jb     801288 <__umoddi3+0x118>
  801265:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801269:	29 c7                	sub    %eax,%edi
  80126b:	19 d6                	sbb    %edx,%esi
  80126d:	89 f0                	mov    %esi,%eax
  80126f:	89 f2                	mov    %esi,%edx
  801271:	d3 ef                	shr    %cl,%edi
  801273:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801277:	d3 e0                	shl    %cl,%eax
  801279:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80127d:	09 f8                	or     %edi,%eax
  80127f:	d3 ea                	shr    %cl,%edx
  801281:	83 c4 20             	add    $0x20,%esp
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    
  801288:	39 d6                	cmp    %edx,%esi
  80128a:	75 d9                	jne    801265 <__umoddi3+0xf5>
  80128c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80128f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801292:	eb d1                	jmp    801265 <__umoddi3+0xf5>
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	39 f2                	cmp    %esi,%edx
  80129a:	0f 82 18 ff ff ff    	jb     8011b8 <__umoddi3+0x48>
  8012a0:	e9 1d ff ff ff       	jmp    8011c2 <__umoddi3+0x52>
