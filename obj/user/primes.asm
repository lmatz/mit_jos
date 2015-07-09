
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 bf 13 00 00       	call   801417 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 c0 17 80 00 	movl   $0x8017c0,(%esp)
  800071:	e8 f7 01 00 00       	call   80026d <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 e3 10 00 00       	call   80115e <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 cc 17 80 	movl   $0x8017cc,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 d5 17 80 00 	movl   $0x8017d5,(%esp)
  80009c:	e8 13 01 00 00       	call   8001b4 <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 57 13 00 00       	call   801417 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 bd 12 00 00       	call   8013a6 <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 66 10 00 00       	call   80115e <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 cc 17 80 	movl   $0x8017cc,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 d5 17 80 00 	movl   $0x8017d5,(%esp)
  800119:	e8 96 00 00 00       	call   8001b4 <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 5e 12 00 00       	call   8013a6 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 75 08             	mov    0x8(%ebp),%esi
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  800162:	e8 de 0d 00 00       	call   800f45 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800188:	89 34 24             	mov    %esi,(%esp)
  80018b:	e8 5b ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ad:	e8 c7 0d 00 00       	call   800f79 <sys_env_destroy>
}
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001bc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001bf:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001c5:	e8 7b 0d 00 00       	call   800f45 <sys_getenvid>
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e0:	c7 04 24 f0 17 80 00 	movl   $0x8017f0,(%esp)
  8001e7:	e8 81 00 00 00       	call   80026d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	e8 11 00 00 00       	call   80020c <vcprintf>
	cprintf("\n");
  8001fb:	c7 04 24 fc 1a 80 00 	movl   $0x801afc,(%esp)
  800202:	e8 66 00 00 00       	call   80026d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800207:	cc                   	int3   
  800208:	eb fd                	jmp    800207 <_panic+0x53>
	...

0080020c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800215:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021c:	00 00 00 
	b.cnt = 0;
  80021f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800226:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800229:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800230:	8b 45 08             	mov    0x8(%ebp),%eax
  800233:	89 44 24 08          	mov    %eax,0x8(%esp)
  800237:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	c7 04 24 87 02 80 00 	movl   $0x800287,(%esp)
  800248:	e8 c2 01 00 00       	call   80040f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80024d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800253:	89 44 24 04          	mov    %eax,0x4(%esp)
  800257:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	e8 fb 09 00 00       	call   800c60 <sys_cputs>

	return b.cnt;
}
  800265:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800273:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800276:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	89 04 24             	mov    %eax,(%esp)
  800280:	e8 87 ff ff ff       	call   80020c <vcprintf>
	va_end(ap);

	return cnt;
}
  800285:	c9                   	leave  
  800286:	c3                   	ret    

00800287 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	53                   	push   %ebx
  80028b:	83 ec 14             	sub    $0x14,%esp
  80028e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800291:	8b 03                	mov    (%ebx),%eax
  800293:	8b 55 08             	mov    0x8(%ebp),%edx
  800296:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029a:	83 c0 01             	add    $0x1,%eax
  80029d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80029f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a4:	75 19                	jne    8002bf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002a6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002ad:	00 
  8002ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 a7 09 00 00       	call   800c60 <sys_cputs>
		b->idx = 0;
  8002b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c3:	83 c4 14             	add    $0x14,%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    
  8002c9:	00 00                	add    %al,(%eax)
  8002cb:	00 00                	add    %al,(%eax)
  8002cd:	00 00                	add    %al,(%eax)
	...

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 4c             	sub    $0x4c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d6                	mov    %edx,%esi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fb:	39 d1                	cmp    %edx,%ecx
  8002fd:	72 07                	jb     800306 <printnum+0x36>
  8002ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800302:	39 d0                	cmp    %edx,%eax
  800304:	77 69                	ja     80036f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800306:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80030a:	83 eb 01             	sub    $0x1,%ebx
  80030d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800311:	89 44 24 08          	mov    %eax,0x8(%esp)
  800315:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800319:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80031d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800320:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800323:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800326:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800331:	00 
  800332:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800335:	89 04 24             	mov    %eax,(%esp)
  800338:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80033b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033f:	e8 fc 11 00 00       	call   801540 <__udivdi3>
  800344:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800347:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80034a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80034e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800352:	89 04 24             	mov    %eax,(%esp)
  800355:	89 54 24 04          	mov    %edx,0x4(%esp)
  800359:	89 f2                	mov    %esi,%edx
  80035b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035e:	e8 6d ff ff ff       	call   8002d0 <printnum>
  800363:	eb 11                	jmp    800376 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800365:	89 74 24 04          	mov    %esi,0x4(%esp)
  800369:	89 3c 24             	mov    %edi,(%esp)
  80036c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036f:	83 eb 01             	sub    $0x1,%ebx
  800372:	85 db                	test   %ebx,%ebx
  800374:	7f ef                	jg     800365 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800376:	89 74 24 04          	mov    %esi,0x4(%esp)
  80037a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80037e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800381:	89 44 24 08          	mov    %eax,0x8(%esp)
  800385:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038c:	00 
  80038d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800390:	89 14 24             	mov    %edx,(%esp)
  800393:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800396:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80039a:	e8 d1 12 00 00       	call   801670 <__umoddi3>
  80039f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a3:	0f be 80 13 18 80 00 	movsbl 0x801813(%eax),%eax
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003b0:	83 c4 4c             	add    $0x4c,%esp
  8003b3:	5b                   	pop    %ebx
  8003b4:	5e                   	pop    %esi
  8003b5:	5f                   	pop    %edi
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003bb:	83 fa 01             	cmp    $0x1,%edx
  8003be:	7e 0e                	jle    8003ce <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	8b 52 04             	mov    0x4(%edx),%edx
  8003cc:	eb 22                	jmp    8003f0 <getuint+0x38>
	else if (lflag)
  8003ce:	85 d2                	test   %edx,%edx
  8003d0:	74 10                	je     8003e2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d2:	8b 10                	mov    (%eax),%edx
  8003d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d7:	89 08                	mov    %ecx,(%eax)
  8003d9:	8b 02                	mov    (%edx),%eax
  8003db:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e0:	eb 0e                	jmp    8003f0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e2:	8b 10                	mov    (%eax),%edx
  8003e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e7:	89 08                	mov    %ecx,(%eax)
  8003e9:	8b 02                	mov    (%edx),%eax
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003f0:	5d                   	pop    %ebp
  8003f1:	c3                   	ret    

008003f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800401:	73 0a                	jae    80040d <sprintputch+0x1b>
		*b->buf++ = ch;
  800403:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800406:	88 0a                	mov    %cl,(%edx)
  800408:	83 c2 01             	add    $0x1,%edx
  80040b:	89 10                	mov    %edx,(%eax)
}
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	57                   	push   %edi
  800413:	56                   	push   %esi
  800414:	53                   	push   %ebx
  800415:	83 ec 4c             	sub    $0x4c,%esp
  800418:	8b 7d 08             	mov    0x8(%ebp),%edi
  80041b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80041e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800421:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800428:	eb 11                	jmp    80043b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80042a:	85 c0                	test   %eax,%eax
  80042c:	0f 84 b0 03 00 00    	je     8007e2 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800432:	89 74 24 04          	mov    %esi,0x4(%esp)
  800436:	89 04 24             	mov    %eax,(%esp)
  800439:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80043b:	0f b6 03             	movzbl (%ebx),%eax
  80043e:	83 c3 01             	add    $0x1,%ebx
  800441:	83 f8 25             	cmp    $0x25,%eax
  800444:	75 e4                	jne    80042a <vprintfmt+0x1b>
  800446:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80044d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800452:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800456:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80045d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800464:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800467:	eb 06                	jmp    80046f <vprintfmt+0x60>
  800469:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80046d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	0f b6 0b             	movzbl (%ebx),%ecx
  800472:	0f b6 c1             	movzbl %cl,%eax
  800475:	8d 53 01             	lea    0x1(%ebx),%edx
  800478:	83 e9 23             	sub    $0x23,%ecx
  80047b:	80 f9 55             	cmp    $0x55,%cl
  80047e:	0f 87 41 03 00 00    	ja     8007c5 <vprintfmt+0x3b6>
  800484:	0f b6 c9             	movzbl %cl,%ecx
  800487:	ff 24 8d e0 18 80 00 	jmp    *0x8018e0(,%ecx,4)
  80048e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800492:	eb d9                	jmp    80046d <vprintfmt+0x5e>
  800494:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80049b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004a3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004a7:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  8004aa:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ad:	83 fb 09             	cmp    $0x9,%ebx
  8004b0:	77 2b                	ja     8004dd <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b2:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b5:	eb e9                	jmp    8004a0 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ba:	8d 48 04             	lea    0x4(%eax),%ecx
  8004bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004c0:	8b 00                	mov    (%eax),%eax
  8004c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  8004c5:	eb 19                	jmp    8004e0 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  8004c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ca:	c1 f8 1f             	sar    $0x1f,%eax
  8004cd:	f7 d0                	not    %eax
  8004cf:	21 45 e4             	and    %eax,-0x1c(%ebp)
  8004d2:	eb 99                	jmp    80046d <vprintfmt+0x5e>
  8004d4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004db:	eb 90                	jmp    80046d <vprintfmt+0x5e>
  8004dd:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  8004e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004e4:	79 87                	jns    80046d <vprintfmt+0x5e>
  8004e6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ec:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004f2:	e9 76 ff ff ff       	jmp    80046d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004fb:	e9 6d ff ff ff       	jmp    80046d <vprintfmt+0x5e>
  800500:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 50 04             	lea    0x4(%eax),%edx
  800509:	89 55 14             	mov    %edx,0x14(%ebp)
  80050c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800510:	8b 00                	mov    (%eax),%eax
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	ff d7                	call   *%edi
  800517:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80051a:	e9 1c ff ff ff       	jmp    80043b <vprintfmt+0x2c>
  80051f:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 50 04             	lea    0x4(%eax),%edx
  800528:	89 55 14             	mov    %edx,0x14(%ebp)
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 c2                	mov    %eax,%edx
  80052f:	c1 fa 1f             	sar    $0x1f,%edx
  800532:	31 d0                	xor    %edx,%eax
  800534:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800536:	83 f8 09             	cmp    $0x9,%eax
  800539:	7f 0b                	jg     800546 <vprintfmt+0x137>
  80053b:	8b 14 85 40 1a 80 00 	mov    0x801a40(,%eax,4),%edx
  800542:	85 d2                	test   %edx,%edx
  800544:	75 20                	jne    800566 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800546:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80054a:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800551:	00 
  800552:	89 74 24 04          	mov    %esi,0x4(%esp)
  800556:	89 3c 24             	mov    %edi,(%esp)
  800559:	e8 0c 03 00 00       	call   80086a <printfmt>
  80055e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800561:	e9 d5 fe ff ff       	jmp    80043b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800566:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80056a:	c7 44 24 08 2d 18 80 	movl   $0x80182d,0x8(%esp)
  800571:	00 
  800572:	89 74 24 04          	mov    %esi,0x4(%esp)
  800576:	89 3c 24             	mov    %edi,(%esp)
  800579:	e8 ec 02 00 00       	call   80086a <printfmt>
  80057e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800581:	e9 b5 fe ff ff       	jmp    80043b <vprintfmt+0x2c>
  800586:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80058f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 04             	lea    0x4(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 18                	mov    (%eax),%ebx
  80059d:	85 db                	test   %ebx,%ebx
  80059f:	75 05                	jne    8005a6 <vprintfmt+0x197>
  8005a1:	bb 30 18 80 00       	mov    $0x801830,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8005a6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005aa:	7e 76                	jle    800622 <vprintfmt+0x213>
  8005ac:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005b0:	74 7a                	je     80062c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b6:	89 1c 24             	mov    %ebx,(%esp)
  8005b9:	e8 fa 02 00 00       	call   8008b8 <strnlen>
  8005be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005c1:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  8005c3:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ca:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005cd:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cf:	eb 0f                	jmp    8005e0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8005d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d8:	89 04 24             	mov    %eax,(%esp)
  8005db:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dd:	83 eb 01             	sub    $0x1,%ebx
  8005e0:	85 db                	test   %ebx,%ebx
  8005e2:	7f ed                	jg     8005d1 <vprintfmt+0x1c2>
  8005e4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8005e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005ea:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005ed:	89 f7                	mov    %esi,%edi
  8005ef:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005f2:	eb 40                	jmp    800634 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f8:	74 18                	je     800612 <vprintfmt+0x203>
  8005fa:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005fd:	83 fa 5e             	cmp    $0x5e,%edx
  800600:	76 10                	jbe    800612 <vprintfmt+0x203>
					putch('?', putdat);
  800602:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800606:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80060d:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800610:	eb 0a                	jmp    80061c <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800620:	eb 12                	jmp    800634 <vprintfmt+0x225>
  800622:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800625:	89 f7                	mov    %esi,%edi
  800627:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80062a:	eb 08                	jmp    800634 <vprintfmt+0x225>
  80062c:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80062f:	89 f7                	mov    %esi,%edi
  800631:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800634:	0f be 03             	movsbl (%ebx),%eax
  800637:	83 c3 01             	add    $0x1,%ebx
  80063a:	85 c0                	test   %eax,%eax
  80063c:	74 25                	je     800663 <vprintfmt+0x254>
  80063e:	85 f6                	test   %esi,%esi
  800640:	78 b2                	js     8005f4 <vprintfmt+0x1e5>
  800642:	83 ee 01             	sub    $0x1,%esi
  800645:	79 ad                	jns    8005f4 <vprintfmt+0x1e5>
  800647:	89 fe                	mov    %edi,%esi
  800649:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80064c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80064f:	eb 1a                	jmp    80066b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800651:	89 74 24 04          	mov    %esi,0x4(%esp)
  800655:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80065c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065e:	83 eb 01             	sub    $0x1,%ebx
  800661:	eb 08                	jmp    80066b <vprintfmt+0x25c>
  800663:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800666:	89 fe                	mov    %edi,%esi
  800668:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80066b:	85 db                	test   %ebx,%ebx
  80066d:	7f e2                	jg     800651 <vprintfmt+0x242>
  80066f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800672:	e9 c4 fd ff ff       	jmp    80043b <vprintfmt+0x2c>
  800677:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80067a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80067d:	83 f9 01             	cmp    $0x1,%ecx
  800680:	7e 16                	jle    800698 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 50 08             	lea    0x8(%eax),%edx
  800688:	89 55 14             	mov    %edx,0x14(%ebp)
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	8b 48 04             	mov    0x4(%eax),%ecx
  800690:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800693:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800696:	eb 32                	jmp    8006ca <vprintfmt+0x2bb>
	else if (lflag)
  800698:	85 c9                	test   %ecx,%ecx
  80069a:	74 18                	je     8006b4 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80069c:	8b 45 14             	mov    0x14(%ebp),%eax
  80069f:	8d 50 04             	lea    0x4(%eax),%edx
  8006a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a5:	8b 00                	mov    (%eax),%eax
  8006a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006aa:	89 c1                	mov    %eax,%ecx
  8006ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8006af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b2:	eb 16                	jmp    8006ca <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c2:	89 c2                	mov    %eax,%edx
  8006c4:	c1 fa 1f             	sar    $0x1f,%edx
  8006c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ca:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006cd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006d0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006d9:	0f 89 a7 00 00 00    	jns    800786 <vprintfmt+0x377>
				putch('-', putdat);
  8006df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006ea:	ff d7                	call   *%edi
				num = -(long long) num;
  8006ec:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006ef:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006f2:	f7 d9                	neg    %ecx
  8006f4:	83 d3 00             	adc    $0x0,%ebx
  8006f7:	f7 db                	neg    %ebx
  8006f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fe:	e9 83 00 00 00       	jmp    800786 <vprintfmt+0x377>
  800703:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800706:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800709:	89 ca                	mov    %ecx,%edx
  80070b:	8d 45 14             	lea    0x14(%ebp),%eax
  80070e:	e8 a5 fc ff ff       	call   8003b8 <getuint>
  800713:	89 c1                	mov    %eax,%ecx
  800715:	89 d3                	mov    %edx,%ebx
  800717:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80071c:	eb 68                	jmp    800786 <vprintfmt+0x377>
  80071e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800721:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800724:	89 ca                	mov    %ecx,%edx
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
  800729:	e8 8a fc ff ff       	call   8003b8 <getuint>
  80072e:	89 c1                	mov    %eax,%ecx
  800730:	89 d3                	mov    %edx,%ebx
  800732:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800737:	eb 4d                	jmp    800786 <vprintfmt+0x377>
  800739:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80073c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800740:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800747:	ff d7                	call   *%edi
			putch('x', putdat);
  800749:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800754:	ff d7                	call   *%edi
			num = (unsigned long long)
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8d 50 04             	lea    0x4(%eax),%edx
  80075c:	89 55 14             	mov    %edx,0x14(%ebp)
  80075f:	8b 08                	mov    (%eax),%ecx
  800761:	bb 00 00 00 00       	mov    $0x0,%ebx
  800766:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80076b:	eb 19                	jmp    800786 <vprintfmt+0x377>
  80076d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800770:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800773:	89 ca                	mov    %ecx,%edx
  800775:	8d 45 14             	lea    0x14(%ebp),%eax
  800778:	e8 3b fc ff ff       	call   8003b8 <getuint>
  80077d:	89 c1                	mov    %eax,%ecx
  80077f:	89 d3                	mov    %edx,%ebx
  800781:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800786:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80078a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80078e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800791:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800795:	89 44 24 08          	mov    %eax,0x8(%esp)
  800799:	89 0c 24             	mov    %ecx,(%esp)
  80079c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a0:	89 f2                	mov    %esi,%edx
  8007a2:	89 f8                	mov    %edi,%eax
  8007a4:	e8 27 fb ff ff       	call   8002d0 <printnum>
  8007a9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007ac:	e9 8a fc ff ff       	jmp    80043b <vprintfmt+0x2c>
  8007b1:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b8:	89 04 24             	mov    %eax,(%esp)
  8007bb:	ff d7                	call   *%edi
  8007bd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007c0:	e9 76 fc ff ff       	jmp    80043b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007d5:	80 38 25             	cmpb   $0x25,(%eax)
  8007d8:	0f 84 5d fc ff ff    	je     80043b <vprintfmt+0x2c>
  8007de:	89 c3                	mov    %eax,%ebx
  8007e0:	eb f0                	jmp    8007d2 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  8007e2:	83 c4 4c             	add    $0x4c,%esp
  8007e5:	5b                   	pop    %ebx
  8007e6:	5e                   	pop    %esi
  8007e7:	5f                   	pop    %edi
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	83 ec 28             	sub    $0x28,%esp
  8007f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	74 04                	je     8007fe <vsnprintf+0x14>
  8007fa:	85 d2                	test   %edx,%edx
  8007fc:	7f 07                	jg     800805 <vsnprintf+0x1b>
  8007fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800803:	eb 3b                	jmp    800840 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800805:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800808:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80080c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80080f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80081d:	8b 45 10             	mov    0x10(%ebp),%eax
  800820:	89 44 24 08          	mov    %eax,0x8(%esp)
  800824:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	c7 04 24 f2 03 80 00 	movl   $0x8003f2,(%esp)
  800832:	e8 d8 fb ff ff       	call   80040f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800837:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80083d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800840:	c9                   	leave  
  800841:	c3                   	ret    

00800842 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800848:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80084b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084f:	8b 45 10             	mov    0x10(%ebp),%eax
  800852:	89 44 24 08          	mov    %eax,0x8(%esp)
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
  800859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	e8 82 ff ff ff       	call   8007ea <vsnprintf>
	va_end(ap);

	return rc;
}
  800868:	c9                   	leave  
  800869:	c3                   	ret    

0080086a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800870:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800873:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800877:	8b 45 10             	mov    0x10(%ebp),%eax
  80087a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800881:	89 44 24 04          	mov    %eax,0x4(%esp)
  800885:	8b 45 08             	mov    0x8(%ebp),%eax
  800888:	89 04 24             	mov    %eax,(%esp)
  80088b:	e8 7f fb ff ff       	call   80040f <vprintfmt>
	va_end(ap);
}
  800890:	c9                   	leave  
  800891:	c3                   	ret    
	...

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ab:	eb 03                	jmp    8008b0 <strlen+0x10>
		n++;
  8008ad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b4:	75 f7                	jne    8008ad <strlen+0xd>
		n++;
	return n;
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c7:	eb 03                	jmp    8008cc <strnlen+0x14>
		n++;
  8008c9:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cc:	39 c1                	cmp    %eax,%ecx
  8008ce:	74 06                	je     8008d6 <strnlen+0x1e>
  8008d0:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008d4:	75 f3                	jne    8008c9 <strnlen+0x11>
		n++;
	return n;
}
  8008d6:	5b                   	pop    %ebx
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	53                   	push   %ebx
  8008dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ec:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008ef:	83 c2 01             	add    $0x1,%edx
  8008f2:	84 c9                	test   %cl,%cl
  8008f4:	75 f2                	jne    8008e8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008f6:	5b                   	pop    %ebx
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	53                   	push   %ebx
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800903:	89 1c 24             	mov    %ebx,(%esp)
  800906:	e8 95 ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800912:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800915:	89 04 24             	mov    %eax,(%esp)
  800918:	e8 bc ff ff ff       	call   8008d9 <strcpy>
	return dst;
}
  80091d:	89 d8                	mov    %ebx,%eax
  80091f:	83 c4 08             	add    $0x8,%esp
  800922:	5b                   	pop    %ebx
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	56                   	push   %esi
  800929:	53                   	push   %ebx
  80092a:	8b 45 08             	mov    0x8(%ebp),%eax
  80092d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800930:	8b 75 10             	mov    0x10(%ebp),%esi
  800933:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800938:	eb 0f                	jmp    800949 <strncpy+0x24>
		*dst++ = *src;
  80093a:	0f b6 19             	movzbl (%ecx),%ebx
  80093d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800940:	80 39 01             	cmpb   $0x1,(%ecx)
  800943:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800946:	83 c2 01             	add    $0x1,%edx
  800949:	39 f2                	cmp    %esi,%edx
  80094b:	72 ed                	jb     80093a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 75 08             	mov    0x8(%ebp),%esi
  800959:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095f:	89 f0                	mov    %esi,%eax
  800961:	85 d2                	test   %edx,%edx
  800963:	75 0a                	jne    80096f <strlcpy+0x1e>
  800965:	eb 17                	jmp    80097e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800967:	88 18                	mov    %bl,(%eax)
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80096f:	83 ea 01             	sub    $0x1,%edx
  800972:	74 07                	je     80097b <strlcpy+0x2a>
  800974:	0f b6 19             	movzbl (%ecx),%ebx
  800977:	84 db                	test   %bl,%bl
  800979:	75 ec                	jne    800967 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80097b:	c6 00 00             	movb   $0x0,(%eax)
  80097e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80098d:	eb 06                	jmp    800995 <strcmp+0x11>
		p++, q++;
  80098f:	83 c1 01             	add    $0x1,%ecx
  800992:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800995:	0f b6 01             	movzbl (%ecx),%eax
  800998:	84 c0                	test   %al,%al
  80099a:	74 04                	je     8009a0 <strcmp+0x1c>
  80099c:	3a 02                	cmp    (%edx),%al
  80099e:	74 ef                	je     80098f <strcmp+0xb>
  8009a0:	0f b6 c0             	movzbl %al,%eax
  8009a3:	0f b6 12             	movzbl (%edx),%edx
  8009a6:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	53                   	push   %ebx
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b4:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009b7:	eb 09                	jmp    8009c2 <strncmp+0x18>
		n--, p++, q++;
  8009b9:	83 ea 01             	sub    $0x1,%edx
  8009bc:	83 c0 01             	add    $0x1,%eax
  8009bf:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009c2:	85 d2                	test   %edx,%edx
  8009c4:	75 07                	jne    8009cd <strncmp+0x23>
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	eb 13                	jmp    8009e0 <strncmp+0x36>
  8009cd:	0f b6 18             	movzbl (%eax),%ebx
  8009d0:	84 db                	test   %bl,%bl
  8009d2:	74 04                	je     8009d8 <strncmp+0x2e>
  8009d4:	3a 19                	cmp    (%ecx),%bl
  8009d6:	74 e1                	je     8009b9 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d8:	0f b6 00             	movzbl (%eax),%eax
  8009db:	0f b6 11             	movzbl (%ecx),%edx
  8009de:	29 d0                	sub    %edx,%eax
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ed:	eb 07                	jmp    8009f6 <strchr+0x13>
		if (*s == c)
  8009ef:	38 ca                	cmp    %cl,%dl
  8009f1:	74 0f                	je     800a02 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	0f b6 10             	movzbl (%eax),%edx
  8009f9:	84 d2                	test   %dl,%dl
  8009fb:	75 f2                	jne    8009ef <strchr+0xc>
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0e:	eb 07                	jmp    800a17 <strfind+0x13>
		if (*s == c)
  800a10:	38 ca                	cmp    %cl,%dl
  800a12:	74 0a                	je     800a1e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	0f b6 10             	movzbl (%eax),%edx
  800a1a:	84 d2                	test   %dl,%dl
  800a1c:	75 f2                	jne    800a10 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a1e:	5d                   	pop    %ebp
  800a1f:	90                   	nop
  800a20:	c3                   	ret    

00800a21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	83 ec 0c             	sub    $0xc,%esp
  800a27:	89 1c 24             	mov    %ebx,(%esp)
  800a2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a32:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3b:	85 c9                	test   %ecx,%ecx
  800a3d:	74 30                	je     800a6f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a45:	75 25                	jne    800a6c <memset+0x4b>
  800a47:	f6 c1 03             	test   $0x3,%cl
  800a4a:	75 20                	jne    800a6c <memset+0x4b>
		c &= 0xFF;
  800a4c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4f:	89 d3                	mov    %edx,%ebx
  800a51:	c1 e3 08             	shl    $0x8,%ebx
  800a54:	89 d6                	mov    %edx,%esi
  800a56:	c1 e6 18             	shl    $0x18,%esi
  800a59:	89 d0                	mov    %edx,%eax
  800a5b:	c1 e0 10             	shl    $0x10,%eax
  800a5e:	09 f0                	or     %esi,%eax
  800a60:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a62:	09 d8                	or     %ebx,%eax
  800a64:	c1 e9 02             	shr    $0x2,%ecx
  800a67:	fc                   	cld    
  800a68:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6a:	eb 03                	jmp    800a6f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6c:	fc                   	cld    
  800a6d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6f:	89 f8                	mov    %edi,%eax
  800a71:	8b 1c 24             	mov    (%esp),%ebx
  800a74:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a78:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a7c:	89 ec                	mov    %ebp,%esp
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	83 ec 08             	sub    $0x8,%esp
  800a86:	89 34 24             	mov    %esi,(%esp)
  800a89:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a93:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a96:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a98:	39 c6                	cmp    %eax,%esi
  800a9a:	73 35                	jae    800ad1 <memmove+0x51>
  800a9c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9f:	39 d0                	cmp    %edx,%eax
  800aa1:	73 2e                	jae    800ad1 <memmove+0x51>
		s += n;
		d += n;
  800aa3:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa5:	f6 c2 03             	test   $0x3,%dl
  800aa8:	75 1b                	jne    800ac5 <memmove+0x45>
  800aaa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab0:	75 13                	jne    800ac5 <memmove+0x45>
  800ab2:	f6 c1 03             	test   $0x3,%cl
  800ab5:	75 0e                	jne    800ac5 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800ab7:	83 ef 04             	sub    $0x4,%edi
  800aba:	8d 72 fc             	lea    -0x4(%edx),%esi
  800abd:	c1 e9 02             	shr    $0x2,%ecx
  800ac0:	fd                   	std    
  800ac1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac3:	eb 09                	jmp    800ace <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac5:	83 ef 01             	sub    $0x1,%edi
  800ac8:	8d 72 ff             	lea    -0x1(%edx),%esi
  800acb:	fd                   	std    
  800acc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ace:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800acf:	eb 20                	jmp    800af1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad7:	75 15                	jne    800aee <memmove+0x6e>
  800ad9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800adf:	75 0d                	jne    800aee <memmove+0x6e>
  800ae1:	f6 c1 03             	test   $0x3,%cl
  800ae4:	75 08                	jne    800aee <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800ae6:	c1 e9 02             	shr    $0x2,%ecx
  800ae9:	fc                   	cld    
  800aea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aec:	eb 03                	jmp    800af1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aee:	fc                   	cld    
  800aef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af1:	8b 34 24             	mov    (%esp),%esi
  800af4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800af8:	89 ec                	mov    %ebp,%esp
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b02:	8b 45 10             	mov    0x10(%ebp),%eax
  800b05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	89 04 24             	mov    %eax,(%esp)
  800b16:	e8 65 ff ff ff       	call   800a80 <memmove>
}
  800b1b:	c9                   	leave  
  800b1c:	c3                   	ret    

00800b1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
  800b23:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b29:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b2c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b31:	eb 1c                	jmp    800b4f <memcmp+0x32>
		if (*s1 != *s2)
  800b33:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800b37:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800b3b:	83 c2 01             	add    $0x1,%edx
  800b3e:	83 e9 01             	sub    $0x1,%ecx
  800b41:	38 d8                	cmp    %bl,%al
  800b43:	74 0a                	je     800b4f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800b45:	0f b6 c0             	movzbl %al,%eax
  800b48:	0f b6 db             	movzbl %bl,%ebx
  800b4b:	29 d8                	sub    %ebx,%eax
  800b4d:	eb 09                	jmp    800b58 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4f:	85 c9                	test   %ecx,%ecx
  800b51:	75 e0                	jne    800b33 <memcmp+0x16>
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b66:	89 c2                	mov    %eax,%edx
  800b68:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b6b:	eb 07                	jmp    800b74 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6d:	38 08                	cmp    %cl,(%eax)
  800b6f:	74 07                	je     800b78 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b71:	83 c0 01             	add    $0x1,%eax
  800b74:	39 d0                	cmp    %edx,%eax
  800b76:	72 f5                	jb     800b6d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 04             	sub    $0x4,%esp
  800b83:	8b 55 08             	mov    0x8(%ebp),%edx
  800b86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b89:	eb 03                	jmp    800b8e <strtol+0x14>
		s++;
  800b8b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8e:	0f b6 02             	movzbl (%edx),%eax
  800b91:	3c 20                	cmp    $0x20,%al
  800b93:	74 f6                	je     800b8b <strtol+0x11>
  800b95:	3c 09                	cmp    $0x9,%al
  800b97:	74 f2                	je     800b8b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b99:	3c 2b                	cmp    $0x2b,%al
  800b9b:	75 0c                	jne    800ba9 <strtol+0x2f>
		s++;
  800b9d:	8d 52 01             	lea    0x1(%edx),%edx
  800ba0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ba7:	eb 15                	jmp    800bbe <strtol+0x44>
	else if (*s == '-')
  800ba9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bb0:	3c 2d                	cmp    $0x2d,%al
  800bb2:	75 0a                	jne    800bbe <strtol+0x44>
		s++, neg = 1;
  800bb4:	8d 52 01             	lea    0x1(%edx),%edx
  800bb7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbe:	85 db                	test   %ebx,%ebx
  800bc0:	0f 94 c0             	sete   %al
  800bc3:	74 05                	je     800bca <strtol+0x50>
  800bc5:	83 fb 10             	cmp    $0x10,%ebx
  800bc8:	75 18                	jne    800be2 <strtol+0x68>
  800bca:	80 3a 30             	cmpb   $0x30,(%edx)
  800bcd:	75 13                	jne    800be2 <strtol+0x68>
  800bcf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd3:	75 0d                	jne    800be2 <strtol+0x68>
		s += 2, base = 16;
  800bd5:	83 c2 02             	add    $0x2,%edx
  800bd8:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bdd:	8d 76 00             	lea    0x0(%esi),%esi
  800be0:	eb 13                	jmp    800bf5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be2:	84 c0                	test   %al,%al
  800be4:	74 0f                	je     800bf5 <strtol+0x7b>
  800be6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800beb:	80 3a 30             	cmpb   $0x30,(%edx)
  800bee:	75 05                	jne    800bf5 <strtol+0x7b>
		s++, base = 8;
  800bf0:	83 c2 01             	add    $0x1,%edx
  800bf3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bfa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bfc:	0f b6 0a             	movzbl (%edx),%ecx
  800bff:	89 cf                	mov    %ecx,%edi
  800c01:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c04:	80 fb 09             	cmp    $0x9,%bl
  800c07:	77 08                	ja     800c11 <strtol+0x97>
			dig = *s - '0';
  800c09:	0f be c9             	movsbl %cl,%ecx
  800c0c:	83 e9 30             	sub    $0x30,%ecx
  800c0f:	eb 1e                	jmp    800c2f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c11:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c14:	80 fb 19             	cmp    $0x19,%bl
  800c17:	77 08                	ja     800c21 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800c19:	0f be c9             	movsbl %cl,%ecx
  800c1c:	83 e9 57             	sub    $0x57,%ecx
  800c1f:	eb 0e                	jmp    800c2f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c21:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c24:	80 fb 19             	cmp    $0x19,%bl
  800c27:	77 15                	ja     800c3e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800c29:	0f be c9             	movsbl %cl,%ecx
  800c2c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c2f:	39 f1                	cmp    %esi,%ecx
  800c31:	7d 0b                	jge    800c3e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800c33:	83 c2 01             	add    $0x1,%edx
  800c36:	0f af c6             	imul   %esi,%eax
  800c39:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c3c:	eb be                	jmp    800bfc <strtol+0x82>
  800c3e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c44:	74 05                	je     800c4b <strtol+0xd1>
		*endptr = (char *) s;
  800c46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c49:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c4f:	74 04                	je     800c55 <strtol+0xdb>
  800c51:	89 c8                	mov    %ecx,%eax
  800c53:	f7 d8                	neg    %eax
}
  800c55:	83 c4 04             	add    $0x4,%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    
  800c5d:	00 00                	add    %al,(%eax)
	...

00800c60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	89 1c 24             	mov    %ebx,(%esp)
  800c69:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c6d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	89 c3                	mov    %eax,%ebx
  800c7e:	89 c7                	mov    %eax,%edi
  800c80:	89 c6                	mov    %eax,%esi
  800c82:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c84:	8b 1c 24             	mov    (%esp),%ebx
  800c87:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c8b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c8f:	89 ec                	mov    %ebp,%esp
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	83 ec 38             	sub    $0x38,%esp
  800c99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800ca2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca6:	75 0c                	jne    800cb4 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800ca8:	c7 04 24 68 1a 80 00 	movl   $0x801a68,(%esp)
  800caf:	e8 b9 f5 ff ff       	call   80026d <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb9:	b8 09 00 00 00       	mov    $0x9,%eax
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	89 df                	mov    %ebx,%edi
  800cc6:	89 de                	mov    %ebx,%esi
  800cc8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	7e 28                	jle    800cf6 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cce:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800cd9:	00 
  800cda:	c7 44 24 08 94 1a 80 	movl   $0x801a94,0x8(%esp)
  800ce1:	00 
  800ce2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce9:	00 
  800cea:	c7 04 24 b1 1a 80 00 	movl   $0x801ab1,(%esp)
  800cf1:	e8 be f4 ff ff       	call   8001b4 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cfc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cff:	89 ec                	mov    %ebp,%esp
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	83 ec 38             	sub    $0x38,%esp
  800d09:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d0c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d0f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d17:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 cb                	mov    %ecx,%ebx
  800d21:	89 cf                	mov    %ecx,%edi
  800d23:	89 ce                	mov    %ecx,%esi
  800d25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d27:	85 c0                	test   %eax,%eax
  800d29:	7e 28                	jle    800d53 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d36:	00 
  800d37:	c7 44 24 08 94 1a 80 	movl   $0x801a94,0x8(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d46:	00 
  800d47:	c7 04 24 b1 1a 80 00 	movl   $0x801ab1,(%esp)
  800d4e:	e8 61 f4 ff ff       	call   8001b4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d53:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d56:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5c:	89 ec                	mov    %ebp,%esp
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	89 1c 24             	mov    %ebx,(%esp)
  800d69:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d6d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	be 00 00 00 00       	mov    $0x0,%esi
  800d76:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d89:	8b 1c 24             	mov    (%esp),%ebx
  800d8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d90:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d94:	89 ec                	mov    %ebp,%esp
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 38             	sub    $0x38,%esp
  800d9e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800da1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dac:	b8 08 00 00 00       	mov    $0x8,%eax
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	89 df                	mov    %ebx,%edi
  800db9:	89 de                	mov    %ebx,%esi
  800dbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbd:	85 c0                	test   %eax,%eax
  800dbf:	7e 28                	jle    800de9 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dcc:	00 
  800dcd:	c7 44 24 08 94 1a 80 	movl   $0x801a94,0x8(%esp)
  800dd4:	00 
  800dd5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddc:	00 
  800ddd:	c7 04 24 b1 1a 80 00 	movl   $0x801ab1,(%esp)
  800de4:	e8 cb f3 ff ff       	call   8001b4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800def:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df2:	89 ec                	mov    %ebp,%esp
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	83 ec 38             	sub    $0x38,%esp
  800dfc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dff:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e02:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 df                	mov    %ebx,%edi
  800e17:	89 de                	mov    %ebx,%esi
  800e19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	7e 28                	jle    800e47 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 08 94 1a 80 	movl   $0x801a94,0x8(%esp)
  800e32:	00 
  800e33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3a:	00 
  800e3b:	c7 04 24 b1 1a 80 00 	movl   $0x801ab1,(%esp)
  800e42:	e8 6d f3 ff ff       	call   8001b4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e47:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e4a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e4d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e50:	89 ec                	mov    %ebp,%esp
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 38             	sub    $0x38,%esp
  800e5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e60:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	b8 05 00 00 00       	mov    $0x5,%eax
  800e68:	8b 75 18             	mov    0x18(%ebp),%esi
  800e6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
  800e77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 28                	jle    800ea5 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e81:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e88:	00 
  800e89:	c7 44 24 08 94 1a 80 	movl   $0x801a94,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 b1 1a 80 00 	movl   $0x801ab1,(%esp)
  800ea0:	e8 0f f3 ff ff       	call   8001b4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ea5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eae:	89 ec                	mov    %ebp,%esp
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	83 ec 38             	sub    $0x38,%esp
  800eb8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ebb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebe:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec1:	be 00 00 00 00       	mov    $0x0,%esi
  800ec6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ece:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed4:	89 f7                	mov    %esi,%edi
  800ed6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 28                	jle    800f04 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ee7:	00 
  800ee8:	c7 44 24 08 94 1a 80 	movl   $0x801a94,0x8(%esp)
  800eef:	00 
  800ef0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef7:	00 
  800ef8:	c7 04 24 b1 1a 80 00 	movl   $0x801ab1,(%esp)
  800eff:	e8 b0 f2 ff ff       	call   8001b4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f04:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f07:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f0a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0d:	89 ec                	mov    %ebp,%esp
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	83 ec 0c             	sub    $0xc,%esp
  800f17:	89 1c 24             	mov    %ebx,(%esp)
  800f1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f22:	ba 00 00 00 00       	mov    $0x0,%edx
  800f27:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f2c:	89 d1                	mov    %edx,%ecx
  800f2e:	89 d3                	mov    %edx,%ebx
  800f30:	89 d7                	mov    %edx,%edi
  800f32:	89 d6                	mov    %edx,%esi
  800f34:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f36:	8b 1c 24             	mov    (%esp),%ebx
  800f39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f41:	89 ec                	mov    %ebp,%esp
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 0c             	sub    $0xc,%esp
  800f4b:	89 1c 24             	mov    %ebx,(%esp)
  800f4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f52:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f56:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800f60:	89 d1                	mov    %edx,%ecx
  800f62:	89 d3                	mov    %edx,%ebx
  800f64:	89 d7                	mov    %edx,%edi
  800f66:	89 d6                	mov    %edx,%esi
  800f68:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f6a:	8b 1c 24             	mov    (%esp),%ebx
  800f6d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f71:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f75:	89 ec                	mov    %ebp,%esp
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	83 ec 38             	sub    $0x38,%esp
  800f7f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f85:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	89 cb                	mov    %ecx,%ebx
  800f97:	89 cf                	mov    %ecx,%edi
  800f99:	89 ce                	mov    %ecx,%esi
  800f9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	7e 28                	jle    800fc9 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa5:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fac:	00 
  800fad:	c7 44 24 08 94 1a 80 	movl   $0x801a94,0x8(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fbc:	00 
  800fbd:	c7 04 24 b1 1a 80 00 	movl   $0x801ab1,(%esp)
  800fc4:	e8 eb f1 ff ff       	call   8001b4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fc9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fcc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fcf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fd2:	89 ec                	mov    %ebp,%esp
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    

00800fd6 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 0c             	sub    $0xc,%esp
  800fdc:	89 1c 24             	mov    %ebx,(%esp)
  800fdf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe3:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fec:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff1:	89 d1                	mov    %edx,%ecx
  800ff3:	89 d3                	mov    %edx,%ebx
  800ff5:	89 d7                	mov    %edx,%edi
  800ff7:	89 d6                	mov    %edx,%esi
  800ff9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ffb:	8b 1c 24             	mov    (%esp),%ebx
  800ffe:	8b 74 24 04          	mov    0x4(%esp),%esi
  801002:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801006:	89 ec                	mov    %ebp,%esp
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    
	...

0080100c <sfork>:
}

// Challenge!
int
sfork(void)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801012:	c7 44 24 08 bf 1a 80 	movl   $0x801abf,0x8(%esp)
  801019:	00 
  80101a:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  801021:	00 
  801022:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  801029:	e8 86 f1 ff ff       	call   8001b4 <_panic>

0080102e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
  801033:	83 ec 20             	sub    $0x20,%esp
  801036:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801039:	8b 30                	mov    (%eax),%esi
	uint32_t err = utf->utf_err;
  80103b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80103f:	75 1c                	jne    80105d <pgfault+0x2f>

	// LAB 4: Your code here.
	FORKDEBUG("lib pgfault: fault address 0x%08x\n",(int)addr);

	if ( (err&FEC_WR) == 0 ) {
		panic("lib pgfault: The page fault is not caused by write\n");
  801041:	c7 44 24 08 00 1b 80 	movl   $0x801b00,0x8(%esp)
  801048:	00 
  801049:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801050:	00 
  801051:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  801058:	e8 57 f1 ff ff       	call   8001b4 <_panic>
	} 
	
	if ( (uvpt[PGNUM(addr)]&PTE_COW) == 0 ) {
  80105d:	89 f0                	mov    %esi,%eax
  80105f:	c1 e8 0c             	shr    $0xc,%eax
  801062:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801069:	f6 c4 08             	test   $0x8,%ah
  80106c:	75 1c                	jne    80108a <pgfault+0x5c>
		panic("lib pgfault: The page fault's page is not COW\n");
  80106e:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  801075:	00 
  801076:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  80107d:	00 
  80107e:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  801085:	e8 2a f1 ff ff       	call   8001b4 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
		
	envid_t envid=sys_getenvid();
  80108a:	e8 b6 fe ff ff       	call   800f45 <sys_getenvid>
  80108f:	89 c3                	mov    %eax,%ebx
	int res;
	
	res=sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W);
  801091:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801098:	00 
  801099:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010a0:	00 
  8010a1:	89 04 24             	mov    %eax,(%esp)
  8010a4:	e8 09 fe ff ff       	call   800eb2 <sys_page_alloc>
	if (res<0) {
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	79 1c                	jns    8010c9 <pgfault+0x9b>
		panic("lib pgfault: cannot allocate temp page\n");
  8010ad:	c7 44 24 08 64 1b 80 	movl   $0x801b64,0x8(%esp)
  8010b4:	00 
  8010b5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8010bc:	00 
  8010bd:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  8010c4:	e8 eb f0 ff ff       	call   8001b4 <_panic>
	}

	memmove(PFTEMP, (void*)ROUNDDOWN(addr,PGSIZE),PGSIZE);
  8010c9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  8010cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010d6:	00 
  8010d7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010db:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8010e2:	e8 99 f9 ff ff       	call   800a80 <memmove>
	
	res=sys_page_map(envid,PFTEMP,envid,(void*)ROUNDDOWN(addr,PGSIZE), PTE_U | PTE_P | PTE_W);
  8010e7:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8010ee:	00 
  8010ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010f7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010fe:	00 
  8010ff:	89 1c 24             	mov    %ebx,(%esp)
  801102:	e8 4d fd ff ff       	call   800e54 <sys_page_map>
	if (res<0) {
  801107:	85 c0                	test   %eax,%eax
  801109:	79 1c                	jns    801127 <pgfault+0xf9>
		panic("lib pgfault: cannot map page\n");
  80110b:	c7 44 24 08 e0 1a 80 	movl   $0x801ae0,0x8(%esp)
  801112:	00 
  801113:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80111a:	00 
  80111b:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  801122:	e8 8d f0 ff ff       	call   8001b4 <_panic>
	}

	res=sys_page_unmap(envid,PFTEMP);
  801127:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80112e:	00 
  80112f:	89 1c 24             	mov    %ebx,(%esp)
  801132:	e8 bf fc ff ff       	call   800df6 <sys_page_unmap>
	if (res<0) {
  801137:	85 c0                	test   %eax,%eax
  801139:	79 1c                	jns    801157 <pgfault+0x129>
		panic("lib pgfault: cannot unmap page\n");
  80113b:	c7 44 24 08 8c 1b 80 	movl   $0x801b8c,0x8(%esp)
  801142:	00 
  801143:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  80114a:	00 
  80114b:	c7 04 24 d5 1a 80 00 	movl   $0x801ad5,(%esp)
  801152:	e8 5d f0 ff ff       	call   8001b4 <_panic>
	}
	return;
	//panic("pgfault not implemented");
}
  801157:	83 c4 20             	add    $0x20,%esp
  80115a:	5b                   	pop    %ebx
  80115b:	5e                   	pop    %esi
  80115c:	5d                   	pop    %ebp
  80115d:	c3                   	ret    

0080115e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 4: Your code here.
	int i,j,pn=0;
	envid_t curenvid=sys_getenvid();
  801167:	e8 d9 fd ff ff       	call   800f45 <sys_getenvid>
  80116c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	envid_t envid;
	int r;
	

	FORKDEBUG("fork: start to fork\n");
	set_pgfault_handler(pgfault);
  80116f:	c7 04 24 2e 10 80 00 	movl   $0x80102e,(%esp)
  801176:	e8 1d 03 00 00       	call   801498 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80117b:	ba 07 00 00 00       	mov    $0x7,%edx
  801180:	89 d0                	mov    %edx,%eax
  801182:	cd 30                	int    $0x30
  801184:	89 45 d8             	mov    %eax,-0x28(%ebp)
	FORKDEBUG("fork: already set pgfault handler\n");


	if ( (envid = sys_exofork()) < 0) {
  801187:	85 c0                	test   %eax,%eax
  801189:	0f 88 c2 01 00 00    	js     801351 <fork+0x1f3>
		return -1;
	}	

	FORKDEBUG("fork: already sys_exofork\n");
	
	if ( envid==0 ) {
  80118f:	85 c0                	test   %eax,%eax
  801191:	75 39                	jne    8011cc <fork+0x6e>

		FORKDEBUG("fork: I am the child\n");
		sys_page_alloc(sys_getenvid(),(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P);
  801193:	e8 ad fd ff ff       	call   800f45 <sys_getenvid>
  801198:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80119f:	00 
  8011a0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011a7:	ee 
  8011a8:	89 04 24             	mov    %eax,(%esp)
  8011ab:	e8 02 fd ff ff       	call   800eb2 <sys_page_alloc>

		thisenv=&envs[ENVX(sys_getenvid())];
  8011b0:	e8 90 fd ff ff       	call   800f45 <sys_getenvid>
  8011b5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011ba:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c2:	a3 04 20 80 00       	mov    %eax,0x802004
		return envid;
  8011c7:	e9 8c 01 00 00       	jmp    801358 <fork+0x1fa>
  8011cc:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
  8011d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8011d6:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  8011dd:	a8 01                	test   $0x1,%al
  8011df:	0f 84 a9 00 00 00    	je     80128e <fork+0x130>
			for ( j=0;j<NPTENTRIES;j++) {
		//		cprintf("i: %d, j:%d\n",i,j);
				pn=PGNUM(PGADDR(i,j,0));
  8011e5:	c1 e2 16             	shl    $0x16,%edx
  8011e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011eb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011f0:	89 de                	mov    %ebx,%esi
  8011f2:	c1 e6 0c             	shl    $0xc,%esi
  8011f5:	0b 75 e4             	or     -0x1c(%ebp),%esi
  8011f8:	c1 ee 0c             	shr    $0xc,%esi
				if ( pn== PGNUM(UXSTACKTOP-PGSIZE) ) {
  8011fb:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801201:	0f 84 87 00 00 00    	je     80128e <fork+0x130>
					break;
				}
				if ( uvpt[pn] & PTE_P ) {
  801207:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80120e:	a8 01                	test   $0x1,%al
  801210:	74 6d                	je     80127f <fork+0x121>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid();
  801212:	e8 2e fd ff ff       	call   800f45 <sys_getenvid>
  801217:	89 45 e0             	mov    %eax,-0x20(%ebp)

	pte_t pte = uvpt[pn];
  80121a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm;

	perm = PTE_U | PTE_P;
	if ( pte & PTE_W || pte & PTE_COW ) {
  801221:	25 02 08 00 00       	and    $0x802,%eax
  801226:	83 f8 01             	cmp    $0x1,%eax
  801229:	19 ff                	sbb    %edi,%edi
  80122b:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801231:	81 c7 05 08 00 00    	add    $0x805,%edi
		perm |= PTE_COW;
	}

	r=sys_page_map(curenvid, (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE),perm);
  801237:	c1 e6 0c             	shl    $0xc,%esi
  80123a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80123e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801242:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801245:	89 44 24 08          	mov    %eax,0x8(%esp)
  801249:	89 74 24 04          	mov    %esi,0x4(%esp)
  80124d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801250:	89 14 24             	mov    %edx,(%esp)
  801253:	e8 fc fb ff ff       	call   800e54 <sys_page_map>
	if (r<0) {
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 23                	js     80127f <fork+0x121>
		FORKDEBUG("lib duppage: sys_page_map curenvid fail\n");
		return r;
	}
	
	if ( perm & PTE_COW ) {
  80125c:	f7 c7 00 08 00 00    	test   $0x800,%edi
  801262:	74 1b                	je     80127f <fork+0x121>
		r=sys_page_map(curenvid, (void*)(pn*PGSIZE), curenvid, (void*)(pn*PGSIZE), perm);
  801264:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801268:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80126c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80126f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801273:	89 74 24 04          	mov    %esi,0x4(%esp)
  801277:	89 04 24             	mov    %eax,(%esp)
  80127a:	e8 d5 fb ff ff       	call   800e54 <sys_page_map>
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
			for ( j=0;j<NPTENTRIES;j++) {
  80127f:	83 c3 01             	add    $0x1,%ebx
  801282:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801288:	0f 85 62 ff ff ff    	jne    8011f0 <fork+0x92>
//			duppage(envid,pn);
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
  80128e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  801292:	81 7d dc bb 03 00 00 	cmpl   $0x3bb,-0x24(%ebp)
  801299:	0f 85 34 ff ff ff    	jne    8011d3 <fork+0x75>
			}
		}
	}
	FORKDEBUG("lib fork: after duppage\n");
	
	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_U | PTE_P | PTE_W)<0 ) {
  80129f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012a6:	00 
  8012a7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012ae:	ee 
  8012af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012b2:	89 14 24             	mov    %edx,(%esp)
  8012b5:	e8 f8 fb ff ff       	call   800eb2 <sys_page_alloc>
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	0f 88 8f 00 00 00    	js     801351 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_alloc fail\n");
		return -1;
	}

	if (sys_page_map(envid,(void*)(UXSTACKTOP-PGSIZE),curenvid,PFTEMP, PTE_U | PTE_P | PTE_W)<0) {
  8012c2:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8012c9:	00 
  8012ca:	c7 44 24 0c 00 f0 7f 	movl   $0x7ff000,0xc(%esp)
  8012d1:	00 
  8012d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012e0:	ee 
  8012e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012e4:	89 14 24             	mov    %edx,(%esp)
  8012e7:	e8 68 fb ff ff       	call   800e54 <sys_page_map>
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 61                	js     801351 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_map envid fail\n");
		return -1;
	}

	memmove((void*)(UXSTACKTOP-PGSIZE) , PFTEMP ,PGSIZE);
  8012f0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8012f7:	00 
  8012f8:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012ff:	00 
  801300:	c7 04 24 00 f0 bf ee 	movl   $0xeebff000,(%esp)
  801307:	e8 74 f7 ff ff       	call   800a80 <memmove>
	
	if (sys_page_unmap(curenvid,PFTEMP)<0) {
  80130c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801313:	00 
  801314:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801317:	89 04 24             	mov    %eax,(%esp)
  80131a:	e8 d7 fa ff ff       	call   800df6 <sys_page_unmap>
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 2e                	js     801351 <fork+0x1f3>
		return -1;
	}

	extern void _pgfault_upcall(void);

	if (sys_env_set_pgfault_upcall(envid,_pgfault_upcall)<0) {
  801323:	c7 44 24 04 0c 15 80 	movl   $0x80150c,0x4(%esp)
  80132a:	00 
  80132b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80132e:	89 14 24             	mov    %edx,(%esp)
  801331:	e8 5d f9 ff ff       	call   800c93 <sys_env_set_pgfault_upcall>
  801336:	85 c0                	test   %eax,%eax
  801338:	78 17                	js     801351 <fork+0x1f3>
//	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P)<0) {
//		FORKDEBUG("lib fork: sys_page_alloc fail\n");
//		return -1;
//	}		

	if (sys_env_set_status(envid, ENV_RUNNABLE)<0) {
  80133a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801341:	00 
  801342:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801345:	89 04 24             	mov    %eax,(%esp)
  801348:	e8 4b fa ff ff       	call   800d98 <sys_env_set_status>
  80134d:	85 c0                	test   %eax,%eax
  80134f:	79 07                	jns    801358 <fork+0x1fa>
  801351:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)

	FORKDEBUG("lib fork: finish fork\n");

	return envid;
//	panic("fork not implemented");
}
  801358:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80135b:	83 c4 4c             	add    $0x4c,%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5f                   	pop    %edi
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    
	...

00801370 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801376:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80137b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80137e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801384:	8b 12                	mov    (%edx),%edx
  801386:	39 ca                	cmp    %ecx,%edx
  801388:	75 0c                	jne    801396 <ipc_find_env+0x26>
			return envs[i].env_id;
  80138a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80138d:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801392:	8b 00                	mov    (%eax),%eax
  801394:	eb 0e                	jmp    8013a4 <ipc_find_env+0x34>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801396:	83 c0 01             	add    $0x1,%eax
  801399:	3d 00 04 00 00       	cmp    $0x400,%eax
  80139e:	75 db                	jne    80137b <ipc_find_env+0xb>
  8013a0:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	57                   	push   %edi
  8013aa:	56                   	push   %esi
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 2c             	sub    $0x2c,%esp
  8013af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013b2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int res;
	do {
		res=sys_ipc_try_send(to_env,val,pg?pg:(void*)UTOP,perm);
  8013b5:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8013b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013bd:	85 f6                	test   %esi,%esi
  8013bf:	74 03                	je     8013c4 <ipc_send+0x1e>
  8013c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013c4:	8b 55 14             	mov    0x14(%ebp),%edx
  8013c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d6:	89 3c 24             	mov    %edi,(%esp)
  8013d9:	e8 82 f9 ff ff       	call   800d60 <sys_ipc_try_send>
		
		if( res!=0 && res!= -E_IPC_NOT_RECV) {
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	0f 95 c3             	setne  %bl
  8013e3:	74 21                	je     801406 <ipc_send+0x60>
  8013e5:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8013e8:	74 1c                	je     801406 <ipc_send+0x60>
			panic("ipc_send: error\n");
  8013ea:	c7 44 24 08 ac 1b 80 	movl   $0x801bac,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 bd 1b 80 00 	movl   $0x801bbd,(%esp)
  801401:	e8 ae ed ff ff       	call   8001b4 <_panic>
		}
		else {
			sys_yield();	
  801406:	e8 06 fb ff ff       	call   800f11 <sys_yield>
		}
	} while(res!=0);
  80140b:	84 db                	test   %bl,%bl
  80140d:	75 a9                	jne    8013b8 <ipc_send+0x12>
	
	
//	panic("ipc_send not implemented");
}
  80140f:	83 c4 2c             	add    $0x2c,%esp
  801412:	5b                   	pop    %ebx
  801413:	5e                   	pop    %esi
  801414:	5f                   	pop    %edi
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    

00801417 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	83 ec 28             	sub    $0x28,%esp
  80141d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801420:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801423:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801426:	8b 75 08             	mov    0x8(%ebp),%esi
  801429:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80142c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int res;

	res=sys_ipc_recv( pg?pg:(void*)UTOP);
  80142f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801434:	85 db                	test   %ebx,%ebx
  801436:	74 02                	je     80143a <ipc_recv+0x23>
  801438:	89 d8                	mov    %ebx,%eax
  80143a:	89 04 24             	mov    %eax,(%esp)
  80143d:	e8 c1 f8 ff ff       	call   800d03 <sys_ipc_recv>

	if( from_env_store) {
  801442:	85 f6                	test   %esi,%esi
  801444:	74 14                	je     80145a <ipc_recv+0x43>
		*from_env_store = (res==0)? thisenv->env_ipc_from:0;
  801446:	ba 00 00 00 00       	mov    $0x0,%edx
  80144b:	85 c0                	test   %eax,%eax
  80144d:	75 09                	jne    801458 <ipc_recv+0x41>
  80144f:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801455:	8b 52 74             	mov    0x74(%edx),%edx
  801458:	89 16                	mov    %edx,(%esi)
	}

	if( perm_store) {
  80145a:	85 ff                	test   %edi,%edi
  80145c:	74 1f                	je     80147d <ipc_recv+0x66>
		*perm_store = (res==0 && (uint32_t)pg < UTOP)? thisenv->env_ipc_perm:0;
  80145e:	85 c0                	test   %eax,%eax
  801460:	75 08                	jne    80146a <ipc_recv+0x53>
  801462:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801468:	76 08                	jbe    801472 <ipc_recv+0x5b>
  80146a:	ba 00 00 00 00       	mov    $0x0,%edx
  80146f:	90                   	nop
  801470:	eb 09                	jmp    80147b <ipc_recv+0x64>
  801472:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801478:	8b 52 78             	mov    0x78(%edx),%edx
  80147b:	89 17                	mov    %edx,(%edi)
	}
	
	if( res) {
  80147d:	85 c0                	test   %eax,%eax
  80147f:	75 08                	jne    801489 <ipc_recv+0x72>
		return res;
	}
	
//	panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801481:	a1 04 20 80 00       	mov    0x802004,%eax
  801486:	8b 40 70             	mov    0x70(%eax),%eax
}
  801489:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80148c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80148f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801492:	89 ec                	mov    %ebp,%esp
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    
	...

00801498 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80149e:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  8014a5:	75 58                	jne    8014ff <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  8014a7:	a1 04 20 80 00       	mov    0x802004,%eax
  8014ac:	8b 40 48             	mov    0x48(%eax),%eax
  8014af:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014b6:	00 
  8014b7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014be:	ee 
  8014bf:	89 04 24             	mov    %eax,(%esp)
  8014c2:	e8 eb f9 ff ff       	call   800eb2 <sys_page_alloc>
  8014c7:	85 c0                	test   %eax,%eax
  8014c9:	74 1c                	je     8014e7 <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  8014cb:	c7 44 24 08 c8 1b 80 	movl   $0x801bc8,0x8(%esp)
  8014d2:	00 
  8014d3:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014da:	00 
  8014db:	c7 04 24 f4 1b 80 00 	movl   $0x801bf4,(%esp)
  8014e2:	e8 cd ec ff ff       	call   8001b4 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  8014e7:	a1 04 20 80 00       	mov    0x802004,%eax
  8014ec:	8b 40 48             	mov    0x48(%eax),%eax
  8014ef:	c7 44 24 04 0c 15 80 	movl   $0x80150c,0x4(%esp)
  8014f6:	00 
  8014f7:	89 04 24             	mov    %eax,(%esp)
  8014fa:	e8 94 f7 ff ff       	call   800c93 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801502:	a3 08 20 80 00       	mov    %eax,0x802008
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  801507:	c9                   	leave  
  801508:	c3                   	ret    
  801509:	00 00                	add    %al,(%eax)
	...

0080150c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80150c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80150d:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801512:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801514:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl  %esp , %ebx
  801517:	89 e3                	mov    %esp,%ebx
	movl  40(%esp) , %eax
  801519:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl  48(%esp) , %esp
  80151d:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl  %eax 
  801521:	50                   	push   %eax


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl  %ebx , %esp
  801522:	89 dc                	mov    %ebx,%esp
	subl  $4 , 48(%esp)
  801524:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl  %eax
  801529:	58                   	pop    %eax
	popl  %eax
  80152a:	58                   	pop    %eax
	popal
  80152b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4 , %esp
  80152c:	83 c4 04             	add    $0x4,%esp
	popfl
  80152f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801530:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801531:	c3                   	ret    
	...

00801540 <__udivdi3>:
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	57                   	push   %edi
  801544:	56                   	push   %esi
  801545:	83 ec 10             	sub    $0x10,%esp
  801548:	8b 45 14             	mov    0x14(%ebp),%eax
  80154b:	8b 55 08             	mov    0x8(%ebp),%edx
  80154e:	8b 75 10             	mov    0x10(%ebp),%esi
  801551:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801554:	85 c0                	test   %eax,%eax
  801556:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801559:	75 35                	jne    801590 <__udivdi3+0x50>
  80155b:	39 fe                	cmp    %edi,%esi
  80155d:	77 61                	ja     8015c0 <__udivdi3+0x80>
  80155f:	85 f6                	test   %esi,%esi
  801561:	75 0b                	jne    80156e <__udivdi3+0x2e>
  801563:	b8 01 00 00 00       	mov    $0x1,%eax
  801568:	31 d2                	xor    %edx,%edx
  80156a:	f7 f6                	div    %esi
  80156c:	89 c6                	mov    %eax,%esi
  80156e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801571:	31 d2                	xor    %edx,%edx
  801573:	89 f8                	mov    %edi,%eax
  801575:	f7 f6                	div    %esi
  801577:	89 c7                	mov    %eax,%edi
  801579:	89 c8                	mov    %ecx,%eax
  80157b:	f7 f6                	div    %esi
  80157d:	89 c1                	mov    %eax,%ecx
  80157f:	89 fa                	mov    %edi,%edx
  801581:	89 c8                	mov    %ecx,%eax
  801583:	83 c4 10             	add    $0x10,%esp
  801586:	5e                   	pop    %esi
  801587:	5f                   	pop    %edi
  801588:	5d                   	pop    %ebp
  801589:	c3                   	ret    
  80158a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801590:	39 f8                	cmp    %edi,%eax
  801592:	77 1c                	ja     8015b0 <__udivdi3+0x70>
  801594:	0f bd d0             	bsr    %eax,%edx
  801597:	83 f2 1f             	xor    $0x1f,%edx
  80159a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80159d:	75 39                	jne    8015d8 <__udivdi3+0x98>
  80159f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8015a2:	0f 86 a0 00 00 00    	jbe    801648 <__udivdi3+0x108>
  8015a8:	39 f8                	cmp    %edi,%eax
  8015aa:	0f 82 98 00 00 00    	jb     801648 <__udivdi3+0x108>
  8015b0:	31 ff                	xor    %edi,%edi
  8015b2:	31 c9                	xor    %ecx,%ecx
  8015b4:	89 c8                	mov    %ecx,%eax
  8015b6:	89 fa                	mov    %edi,%edx
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	5e                   	pop    %esi
  8015bc:	5f                   	pop    %edi
  8015bd:	5d                   	pop    %ebp
  8015be:	c3                   	ret    
  8015bf:	90                   	nop
  8015c0:	89 d1                	mov    %edx,%ecx
  8015c2:	89 fa                	mov    %edi,%edx
  8015c4:	89 c8                	mov    %ecx,%eax
  8015c6:	31 ff                	xor    %edi,%edi
  8015c8:	f7 f6                	div    %esi
  8015ca:	89 c1                	mov    %eax,%ecx
  8015cc:	89 fa                	mov    %edi,%edx
  8015ce:	89 c8                	mov    %ecx,%eax
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	5e                   	pop    %esi
  8015d4:	5f                   	pop    %edi
  8015d5:	5d                   	pop    %ebp
  8015d6:	c3                   	ret    
  8015d7:	90                   	nop
  8015d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015dc:	89 f2                	mov    %esi,%edx
  8015de:	d3 e0                	shl    %cl,%eax
  8015e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8015e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8015eb:	89 c1                	mov    %eax,%ecx
  8015ed:	d3 ea                	shr    %cl,%edx
  8015ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8015f6:	d3 e6                	shl    %cl,%esi
  8015f8:	89 c1                	mov    %eax,%ecx
  8015fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8015fd:	89 fe                	mov    %edi,%esi
  8015ff:	d3 ee                	shr    %cl,%esi
  801601:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801605:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801608:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80160b:	d3 e7                	shl    %cl,%edi
  80160d:	89 c1                	mov    %eax,%ecx
  80160f:	d3 ea                	shr    %cl,%edx
  801611:	09 d7                	or     %edx,%edi
  801613:	89 f2                	mov    %esi,%edx
  801615:	89 f8                	mov    %edi,%eax
  801617:	f7 75 ec             	divl   -0x14(%ebp)
  80161a:	89 d6                	mov    %edx,%esi
  80161c:	89 c7                	mov    %eax,%edi
  80161e:	f7 65 e8             	mull   -0x18(%ebp)
  801621:	39 d6                	cmp    %edx,%esi
  801623:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801626:	72 30                	jb     801658 <__udivdi3+0x118>
  801628:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80162b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80162f:	d3 e2                	shl    %cl,%edx
  801631:	39 c2                	cmp    %eax,%edx
  801633:	73 05                	jae    80163a <__udivdi3+0xfa>
  801635:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801638:	74 1e                	je     801658 <__udivdi3+0x118>
  80163a:	89 f9                	mov    %edi,%ecx
  80163c:	31 ff                	xor    %edi,%edi
  80163e:	e9 71 ff ff ff       	jmp    8015b4 <__udivdi3+0x74>
  801643:	90                   	nop
  801644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801648:	31 ff                	xor    %edi,%edi
  80164a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80164f:	e9 60 ff ff ff       	jmp    8015b4 <__udivdi3+0x74>
  801654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801658:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80165b:	31 ff                	xor    %edi,%edi
  80165d:	89 c8                	mov    %ecx,%eax
  80165f:	89 fa                	mov    %edi,%edx
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	5e                   	pop    %esi
  801665:	5f                   	pop    %edi
  801666:	5d                   	pop    %ebp
  801667:	c3                   	ret    
	...

00801670 <__umoddi3>:
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	57                   	push   %edi
  801674:	56                   	push   %esi
  801675:	83 ec 20             	sub    $0x20,%esp
  801678:	8b 55 14             	mov    0x14(%ebp),%edx
  80167b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801681:	8b 75 0c             	mov    0xc(%ebp),%esi
  801684:	85 d2                	test   %edx,%edx
  801686:	89 c8                	mov    %ecx,%eax
  801688:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80168b:	75 13                	jne    8016a0 <__umoddi3+0x30>
  80168d:	39 f7                	cmp    %esi,%edi
  80168f:	76 3f                	jbe    8016d0 <__umoddi3+0x60>
  801691:	89 f2                	mov    %esi,%edx
  801693:	f7 f7                	div    %edi
  801695:	89 d0                	mov    %edx,%eax
  801697:	31 d2                	xor    %edx,%edx
  801699:	83 c4 20             	add    $0x20,%esp
  80169c:	5e                   	pop    %esi
  80169d:	5f                   	pop    %edi
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    
  8016a0:	39 f2                	cmp    %esi,%edx
  8016a2:	77 4c                	ja     8016f0 <__umoddi3+0x80>
  8016a4:	0f bd ca             	bsr    %edx,%ecx
  8016a7:	83 f1 1f             	xor    $0x1f,%ecx
  8016aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016ad:	75 51                	jne    801700 <__umoddi3+0x90>
  8016af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8016b2:	0f 87 e0 00 00 00    	ja     801798 <__umoddi3+0x128>
  8016b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bb:	29 f8                	sub    %edi,%eax
  8016bd:	19 d6                	sbb    %edx,%esi
  8016bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8016c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c5:	89 f2                	mov    %esi,%edx
  8016c7:	83 c4 20             	add    $0x20,%esp
  8016ca:	5e                   	pop    %esi
  8016cb:	5f                   	pop    %edi
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    
  8016ce:	66 90                	xchg   %ax,%ax
  8016d0:	85 ff                	test   %edi,%edi
  8016d2:	75 0b                	jne    8016df <__umoddi3+0x6f>
  8016d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016d9:	31 d2                	xor    %edx,%edx
  8016db:	f7 f7                	div    %edi
  8016dd:	89 c7                	mov    %eax,%edi
  8016df:	89 f0                	mov    %esi,%eax
  8016e1:	31 d2                	xor    %edx,%edx
  8016e3:	f7 f7                	div    %edi
  8016e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e8:	f7 f7                	div    %edi
  8016ea:	eb a9                	jmp    801695 <__umoddi3+0x25>
  8016ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016f0:	89 c8                	mov    %ecx,%eax
  8016f2:	89 f2                	mov    %esi,%edx
  8016f4:	83 c4 20             	add    $0x20,%esp
  8016f7:	5e                   	pop    %esi
  8016f8:	5f                   	pop    %edi
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    
  8016fb:	90                   	nop
  8016fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801700:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801704:	d3 e2                	shl    %cl,%edx
  801706:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801709:	ba 20 00 00 00       	mov    $0x20,%edx
  80170e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801711:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801714:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801718:	89 fa                	mov    %edi,%edx
  80171a:	d3 ea                	shr    %cl,%edx
  80171c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801720:	0b 55 f4             	or     -0xc(%ebp),%edx
  801723:	d3 e7                	shl    %cl,%edi
  801725:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801729:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80172c:	89 f2                	mov    %esi,%edx
  80172e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801731:	89 c7                	mov    %eax,%edi
  801733:	d3 ea                	shr    %cl,%edx
  801735:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801739:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	d3 e6                	shl    %cl,%esi
  801740:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801744:	d3 ea                	shr    %cl,%edx
  801746:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80174a:	09 d6                	or     %edx,%esi
  80174c:	89 f0                	mov    %esi,%eax
  80174e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801751:	d3 e7                	shl    %cl,%edi
  801753:	89 f2                	mov    %esi,%edx
  801755:	f7 75 f4             	divl   -0xc(%ebp)
  801758:	89 d6                	mov    %edx,%esi
  80175a:	f7 65 e8             	mull   -0x18(%ebp)
  80175d:	39 d6                	cmp    %edx,%esi
  80175f:	72 2b                	jb     80178c <__umoddi3+0x11c>
  801761:	39 c7                	cmp    %eax,%edi
  801763:	72 23                	jb     801788 <__umoddi3+0x118>
  801765:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801769:	29 c7                	sub    %eax,%edi
  80176b:	19 d6                	sbb    %edx,%esi
  80176d:	89 f0                	mov    %esi,%eax
  80176f:	89 f2                	mov    %esi,%edx
  801771:	d3 ef                	shr    %cl,%edi
  801773:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801777:	d3 e0                	shl    %cl,%eax
  801779:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80177d:	09 f8                	or     %edi,%eax
  80177f:	d3 ea                	shr    %cl,%edx
  801781:	83 c4 20             	add    $0x20,%esp
  801784:	5e                   	pop    %esi
  801785:	5f                   	pop    %edi
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    
  801788:	39 d6                	cmp    %edx,%esi
  80178a:	75 d9                	jne    801765 <__umoddi3+0xf5>
  80178c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80178f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801792:	eb d1                	jmp    801765 <__umoddi3+0xf5>
  801794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801798:	39 f2                	cmp    %esi,%edx
  80179a:	0f 82 18 ff ff ff    	jb     8016b8 <__umoddi3+0x48>
  8017a0:	e9 1d ff ff ff       	jmp    8016c2 <__umoddi3+0x52>
