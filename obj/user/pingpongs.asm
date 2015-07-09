
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 6a 0f 00 00       	call   800fac <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80004f:	e8 91 0e 00 00       	call   800ee5 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 a0 17 80 00 	movl   $0x8017a0,(%esp)
  800063:	e8 a9 01 00 00       	call   800211 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 75 0e 00 00       	call   800ee5 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 ba 17 80 00 	movl   $0x8017ba,(%esp)
  80007f:	e8 8d 01 00 00       	call   800211 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 9f 12 00 00       	call   801346 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 f5 12 00 00       	call   8013b7 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 09 0e 00 00       	call   800ee5 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 d0 17 80 00 	movl   $0x8017d0,(%esp)
  8000fa:	e8 12 01 00 00       	call   800211 <cprintf>
		if (val == 10)
  8000ff:	a1 04 20 80 00       	mov    0x802004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 12 12 00 00       	call   801346 <ipc_send>
		if (val == 10)
  800134:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  80013b:	0f 85 66 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  80015e:	e8 82 0d 00 00       	call   800ee5 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800170:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 f6                	test   %esi,%esi
  800177:	7e 07                	jle    800180 <libmain+0x34>
		binaryname = argv[0];
  800179:	8b 03                	mov    (%ebx),%eax
  80017b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 a8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018c:	e8 0b 00 00 00       	call   80019c <exit>
}
  800191:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800194:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800197:	89 ec                	mov    %ebp,%esp
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001a9:	e8 6b 0d 00 00       	call   800f19 <sys_env_destroy>
}
  8001ae:	c9                   	leave  
  8001af:	c3                   	ret    

008001b0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c0:	00 00 00 
	b.cnt = 0;
  8001c3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ca:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	c7 04 24 2b 02 80 00 	movl   $0x80022b,(%esp)
  8001ec:	e8 be 01 00 00       	call   8003af <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800201:	89 04 24             	mov    %eax,(%esp)
  800204:	e8 f7 09 00 00       	call   800c00 <sys_cputs>

	return b.cnt;
}
  800209:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800217:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80021a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	89 04 24             	mov    %eax,(%esp)
  800224:	e8 87 ff ff ff       	call   8001b0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 14             	sub    $0x14,%esp
  800232:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800235:	8b 03                	mov    (%ebx),%eax
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80023e:	83 c0 01             	add    $0x1,%eax
  800241:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800243:	3d ff 00 00 00       	cmp    $0xff,%eax
  800248:	75 19                	jne    800263 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80024a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800251:	00 
  800252:	8d 43 08             	lea    0x8(%ebx),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	e8 a3 09 00 00       	call   800c00 <sys_cputs>
		b->idx = 0;
  80025d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800263:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800267:	83 c4 14             	add    $0x14,%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    
  80026d:	00 00                	add    %al,(%eax)
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 4c             	sub    $0x4c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d6                	mov    %edx,%esi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800284:	8b 55 0c             	mov    0xc(%ebp),%edx
  800287:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80028a:	8b 45 10             	mov    0x10(%ebp),%eax
  80028d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800290:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800293:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800296:	b9 00 00 00 00       	mov    $0x0,%ecx
  80029b:	39 d1                	cmp    %edx,%ecx
  80029d:	72 07                	jb     8002a6 <printnum+0x36>
  80029f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a2:	39 d0                	cmp    %edx,%eax
  8002a4:	77 69                	ja     80030f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002aa:	83 eb 01             	sub    $0x1,%ebx
  8002ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002b9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002bd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002c0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002c3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d1:	00 
  8002d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d5:	89 04 24             	mov    %eax,(%esp)
  8002d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002db:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002df:	e8 4c 12 00 00       	call   801530 <__udivdi3>
  8002e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002ea:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ee:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fe:	e8 6d ff ff ff       	call   800270 <printnum>
  800303:	eb 11                	jmp    800316 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800305:	89 74 24 04          	mov    %esi,0x4(%esp)
  800309:	89 3c 24             	mov    %edi,(%esp)
  80030c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030f:	83 eb 01             	sub    $0x1,%ebx
  800312:	85 db                	test   %ebx,%ebx
  800314:	7f ef                	jg     800305 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800316:	89 74 24 04          	mov    %esi,0x4(%esp)
  80031a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80031e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800321:	89 44 24 08          	mov    %eax,0x8(%esp)
  800325:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032c:	00 
  80032d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800330:	89 14 24             	mov    %edx,(%esp)
  800333:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800336:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80033a:	e8 21 13 00 00       	call   801660 <__umoddi3>
  80033f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800343:	0f be 80 00 18 80 00 	movsbl 0x801800(%eax),%eax
  80034a:	89 04 24             	mov    %eax,(%esp)
  80034d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800350:	83 c4 4c             	add    $0x4c,%esp
  800353:	5b                   	pop    %ebx
  800354:	5e                   	pop    %esi
  800355:	5f                   	pop    %edi
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80035b:	83 fa 01             	cmp    $0x1,%edx
  80035e:	7e 0e                	jle    80036e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 08             	lea    0x8(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	8b 52 04             	mov    0x4(%edx),%edx
  80036c:	eb 22                	jmp    800390 <getuint+0x38>
	else if (lflag)
  80036e:	85 d2                	test   %edx,%edx
  800370:	74 10                	je     800382 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800372:	8b 10                	mov    (%eax),%edx
  800374:	8d 4a 04             	lea    0x4(%edx),%ecx
  800377:	89 08                	mov    %ecx,(%eax)
  800379:	8b 02                	mov    (%edx),%eax
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
  800380:	eb 0e                	jmp    800390 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 4a 04             	lea    0x4(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800390:	5d                   	pop    %ebp
  800391:	c3                   	ret    

00800392 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800398:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80039c:	8b 10                	mov    (%eax),%edx
  80039e:	3b 50 04             	cmp    0x4(%eax),%edx
  8003a1:	73 0a                	jae    8003ad <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a6:	88 0a                	mov    %cl,(%edx)
  8003a8:	83 c2 01             	add    $0x1,%edx
  8003ab:	89 10                	mov    %edx,(%eax)
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	57                   	push   %edi
  8003b3:	56                   	push   %esi
  8003b4:	53                   	push   %ebx
  8003b5:	83 ec 4c             	sub    $0x4c,%esp
  8003b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003be:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003c1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003c8:	eb 11                	jmp    8003db <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ca:	85 c0                	test   %eax,%eax
  8003cc:	0f 84 b0 03 00 00    	je     800782 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  8003d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d6:	89 04 24             	mov    %eax,(%esp)
  8003d9:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003db:	0f b6 03             	movzbl (%ebx),%eax
  8003de:	83 c3 01             	add    $0x1,%ebx
  8003e1:	83 f8 25             	cmp    $0x25,%eax
  8003e4:	75 e4                	jne    8003ca <vprintfmt+0x1b>
  8003e6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f2:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8003f6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003fd:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800404:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800407:	eb 06                	jmp    80040f <vprintfmt+0x60>
  800409:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80040d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	0f b6 0b             	movzbl (%ebx),%ecx
  800412:	0f b6 c1             	movzbl %cl,%eax
  800415:	8d 53 01             	lea    0x1(%ebx),%edx
  800418:	83 e9 23             	sub    $0x23,%ecx
  80041b:	80 f9 55             	cmp    $0x55,%cl
  80041e:	0f 87 41 03 00 00    	ja     800765 <vprintfmt+0x3b6>
  800424:	0f b6 c9             	movzbl %cl,%ecx
  800427:	ff 24 8d c0 18 80 00 	jmp    *0x8018c0(,%ecx,4)
  80042e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800432:	eb d9                	jmp    80040d <vprintfmt+0x5e>
  800434:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80043b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800440:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800443:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800447:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80044a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80044d:	83 fb 09             	cmp    $0x9,%ebx
  800450:	77 2b                	ja     80047d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800452:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800455:	eb e9                	jmp    800440 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800457:	8b 45 14             	mov    0x14(%ebp),%eax
  80045a:	8d 48 04             	lea    0x4(%eax),%ecx
  80045d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800460:	8b 00                	mov    (%eax),%eax
  800462:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800465:	eb 19                	jmp    800480 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800467:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046a:	c1 f8 1f             	sar    $0x1f,%eax
  80046d:	f7 d0                	not    %eax
  80046f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800472:	eb 99                	jmp    80040d <vprintfmt+0x5e>
  800474:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80047b:	eb 90                	jmp    80040d <vprintfmt+0x5e>
  80047d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800480:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800484:	79 87                	jns    80040d <vprintfmt+0x5e>
  800486:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800489:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80048c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80048f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800492:	e9 76 ff ff ff       	jmp    80040d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800497:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80049b:	e9 6d ff ff ff       	jmp    80040d <vprintfmt+0x5e>
  8004a0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 50 04             	lea    0x4(%eax),%edx
  8004a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b0:	8b 00                	mov    (%eax),%eax
  8004b2:	89 04 24             	mov    %eax,(%esp)
  8004b5:	ff d7                	call   *%edi
  8004b7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8004ba:	e9 1c ff ff ff       	jmp    8003db <vprintfmt+0x2c>
  8004bf:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 50 04             	lea    0x4(%eax),%edx
  8004c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cb:	8b 00                	mov    (%eax),%eax
  8004cd:	89 c2                	mov    %eax,%edx
  8004cf:	c1 fa 1f             	sar    $0x1f,%edx
  8004d2:	31 d0                	xor    %edx,%eax
  8004d4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	83 f8 09             	cmp    $0x9,%eax
  8004d9:	7f 0b                	jg     8004e6 <vprintfmt+0x137>
  8004db:	8b 14 85 20 1a 80 00 	mov    0x801a20(,%eax,4),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	75 20                	jne    800506 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  8004e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ea:	c7 44 24 08 11 18 80 	movl   $0x801811,0x8(%esp)
  8004f1:	00 
  8004f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f6:	89 3c 24             	mov    %edi,(%esp)
  8004f9:	e8 0c 03 00 00       	call   80080a <printfmt>
  8004fe:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800501:	e9 d5 fe ff ff       	jmp    8003db <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800506:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80050a:	c7 44 24 08 1a 18 80 	movl   $0x80181a,0x8(%esp)
  800511:	00 
  800512:	89 74 24 04          	mov    %esi,0x4(%esp)
  800516:	89 3c 24             	mov    %edi,(%esp)
  800519:	e8 ec 02 00 00       	call   80080a <printfmt>
  80051e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800521:	e9 b5 fe ff ff       	jmp    8003db <vprintfmt+0x2c>
  800526:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800529:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80052f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 50 04             	lea    0x4(%eax),%edx
  800538:	89 55 14             	mov    %edx,0x14(%ebp)
  80053b:	8b 18                	mov    (%eax),%ebx
  80053d:	85 db                	test   %ebx,%ebx
  80053f:	75 05                	jne    800546 <vprintfmt+0x197>
  800541:	bb 1d 18 80 00       	mov    $0x80181d,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800546:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054a:	7e 76                	jle    8005c2 <vprintfmt+0x213>
  80054c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800550:	74 7a                	je     8005cc <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800552:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800556:	89 1c 24             	mov    %ebx,(%esp)
  800559:	e8 fa 02 00 00       	call   800858 <strnlen>
  80055e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800561:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800563:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800567:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80056a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80056d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	eb 0f                	jmp    800580 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800571:	89 74 24 04          	mov    %esi,0x4(%esp)
  800575:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800578:	89 04 24             	mov    %eax,(%esp)
  80057b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057d:	83 eb 01             	sub    $0x1,%ebx
  800580:	85 db                	test   %ebx,%ebx
  800582:	7f ed                	jg     800571 <vprintfmt+0x1c2>
  800584:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800587:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80058a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80058d:	89 f7                	mov    %esi,%edi
  80058f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800592:	eb 40                	jmp    8005d4 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800594:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800598:	74 18                	je     8005b2 <vprintfmt+0x203>
  80059a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80059d:	83 fa 5e             	cmp    $0x5e,%edx
  8005a0:	76 10                	jbe    8005b2 <vprintfmt+0x203>
					putch('?', putdat);
  8005a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005a6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ad:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005b0:	eb 0a                	jmp    8005bc <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b6:	89 04 24             	mov    %eax,(%esp)
  8005b9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005bc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005c0:	eb 12                	jmp    8005d4 <vprintfmt+0x225>
  8005c2:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005c5:	89 f7                	mov    %esi,%edi
  8005c7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005ca:	eb 08                	jmp    8005d4 <vprintfmt+0x225>
  8005cc:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005cf:	89 f7                	mov    %esi,%edi
  8005d1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005d4:	0f be 03             	movsbl (%ebx),%eax
  8005d7:	83 c3 01             	add    $0x1,%ebx
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	74 25                	je     800603 <vprintfmt+0x254>
  8005de:	85 f6                	test   %esi,%esi
  8005e0:	78 b2                	js     800594 <vprintfmt+0x1e5>
  8005e2:	83 ee 01             	sub    $0x1,%esi
  8005e5:	79 ad                	jns    800594 <vprintfmt+0x1e5>
  8005e7:	89 fe                	mov    %edi,%esi
  8005e9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005ec:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ef:	eb 1a                	jmp    80060b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005fc:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fe:	83 eb 01             	sub    $0x1,%ebx
  800601:	eb 08                	jmp    80060b <vprintfmt+0x25c>
  800603:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800606:	89 fe                	mov    %edi,%esi
  800608:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80060b:	85 db                	test   %ebx,%ebx
  80060d:	7f e2                	jg     8005f1 <vprintfmt+0x242>
  80060f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800612:	e9 c4 fd ff ff       	jmp    8003db <vprintfmt+0x2c>
  800617:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80061a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061d:	83 f9 01             	cmp    $0x1,%ecx
  800620:	7e 16                	jle    800638 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8d 50 08             	lea    0x8(%eax),%edx
  800628:	89 55 14             	mov    %edx,0x14(%ebp)
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	8b 48 04             	mov    0x4(%eax),%ecx
  800630:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800633:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800636:	eb 32                	jmp    80066a <vprintfmt+0x2bb>
	else if (lflag)
  800638:	85 c9                	test   %ecx,%ecx
  80063a:	74 18                	je     800654 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	8b 00                	mov    (%eax),%eax
  800647:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80064a:	89 c1                	mov    %eax,%ecx
  80064c:	c1 f9 1f             	sar    $0x1f,%ecx
  80064f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800652:	eb 16                	jmp    80066a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 50 04             	lea    0x4(%eax),%edx
  80065a:	89 55 14             	mov    %edx,0x14(%ebp)
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800662:	89 c2                	mov    %eax,%edx
  800664:	c1 fa 1f             	sar    $0x1f,%edx
  800667:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80066a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800670:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800675:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800679:	0f 89 a7 00 00 00    	jns    800726 <vprintfmt+0x377>
				putch('-', putdat);
  80067f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800683:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80068a:	ff d7                	call   *%edi
				num = -(long long) num;
  80068c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80068f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800692:	f7 d9                	neg    %ecx
  800694:	83 d3 00             	adc    $0x0,%ebx
  800697:	f7 db                	neg    %ebx
  800699:	b8 0a 00 00 00       	mov    $0xa,%eax
  80069e:	e9 83 00 00 00       	jmp    800726 <vprintfmt+0x377>
  8006a3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006a6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006a9:	89 ca                	mov    %ecx,%edx
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 a5 fc ff ff       	call   800358 <getuint>
  8006b3:	89 c1                	mov    %eax,%ecx
  8006b5:	89 d3                	mov    %edx,%ebx
  8006b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006bc:	eb 68                	jmp    800726 <vprintfmt+0x377>
  8006be:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006c1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006c4:	89 ca                	mov    %ecx,%edx
  8006c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c9:	e8 8a fc ff ff       	call   800358 <getuint>
  8006ce:	89 c1                	mov    %eax,%ecx
  8006d0:	89 d3                	mov    %edx,%ebx
  8006d2:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8006d7:	eb 4d                	jmp    800726 <vprintfmt+0x377>
  8006d9:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006e7:	ff d7                	call   *%edi
			putch('x', putdat);
  8006e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ed:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006f4:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 50 04             	lea    0x4(%eax),%edx
  8006fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ff:	8b 08                	mov    (%eax),%ecx
  800701:	bb 00 00 00 00       	mov    $0x0,%ebx
  800706:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80070b:	eb 19                	jmp    800726 <vprintfmt+0x377>
  80070d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800710:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800713:	89 ca                	mov    %ecx,%edx
  800715:	8d 45 14             	lea    0x14(%ebp),%eax
  800718:	e8 3b fc ff ff       	call   800358 <getuint>
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	89 d3                	mov    %edx,%ebx
  800721:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800726:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80072a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80072e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800731:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800735:	89 44 24 08          	mov    %eax,0x8(%esp)
  800739:	89 0c 24             	mov    %ecx,(%esp)
  80073c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800740:	89 f2                	mov    %esi,%edx
  800742:	89 f8                	mov    %edi,%eax
  800744:	e8 27 fb ff ff       	call   800270 <printnum>
  800749:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80074c:	e9 8a fc ff ff       	jmp    8003db <vprintfmt+0x2c>
  800751:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800754:	89 74 24 04          	mov    %esi,0x4(%esp)
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	ff d7                	call   *%edi
  80075d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800760:	e9 76 fc ff ff       	jmp    8003db <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800765:	89 74 24 04          	mov    %esi,0x4(%esp)
  800769:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800770:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800772:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800775:	80 38 25             	cmpb   $0x25,(%eax)
  800778:	0f 84 5d fc ff ff    	je     8003db <vprintfmt+0x2c>
  80077e:	89 c3                	mov    %eax,%ebx
  800780:	eb f0                	jmp    800772 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800782:	83 c4 4c             	add    $0x4c,%esp
  800785:	5b                   	pop    %ebx
  800786:	5e                   	pop    %esi
  800787:	5f                   	pop    %edi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	83 ec 28             	sub    $0x28,%esp
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800796:	85 c0                	test   %eax,%eax
  800798:	74 04                	je     80079e <vsnprintf+0x14>
  80079a:	85 d2                	test   %edx,%edx
  80079c:	7f 07                	jg     8007a5 <vsnprintf+0x1b>
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a3:	eb 3b                	jmp    8007e0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cb:	c7 04 24 92 03 80 00 	movl   $0x800392,(%esp)
  8007d2:	e8 d8 fb ff ff       	call   8003af <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007da:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007e8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800800:	89 04 24             	mov    %eax,(%esp)
  800803:	e8 82 ff ff ff       	call   80078a <vsnprintf>
	va_end(ap);

	return rc;
}
  800808:	c9                   	leave  
  800809:	c3                   	ret    

0080080a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	e8 7f fb ff ff       	call   8003af <vprintfmt>
	va_end(ap);
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    
	...

00800840 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 55 08             	mov    0x8(%ebp),%edx
  800846:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  80084b:	eb 03                	jmp    800850 <strlen+0x10>
		n++;
  80084d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800850:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800854:	75 f7                	jne    80084d <strlen+0xd>
		n++;
	return n;
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80085f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800867:	eb 03                	jmp    80086c <strnlen+0x14>
		n++;
  800869:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086c:	39 c1                	cmp    %eax,%ecx
  80086e:	74 06                	je     800876 <strnlen+0x1e>
  800870:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800874:	75 f3                	jne    800869 <strnlen+0x11>
		n++;
	return n;
}
  800876:	5b                   	pop    %ebx
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800883:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800888:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80088c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80088f:	83 c2 01             	add    $0x1,%edx
  800892:	84 c9                	test   %cl,%cl
  800894:	75 f2                	jne    800888 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800896:	5b                   	pop    %ebx
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	53                   	push   %ebx
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a3:	89 1c 24             	mov    %ebx,(%esp)
  8008a6:	e8 95 ff ff ff       	call   800840 <strlen>
	strcpy(dst + len, src);
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008b5:	89 04 24             	mov    %eax,(%esp)
  8008b8:	e8 bc ff ff ff       	call   800879 <strcpy>
	return dst;
}
  8008bd:	89 d8                	mov    %ebx,%eax
  8008bf:	83 c4 08             	add    $0x8,%esp
  8008c2:	5b                   	pop    %ebx
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
  8008ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d0:	8b 75 10             	mov    0x10(%ebp),%esi
  8008d3:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d8:	eb 0f                	jmp    8008e9 <strncpy+0x24>
		*dst++ = *src;
  8008da:	0f b6 19             	movzbl (%ecx),%ebx
  8008dd:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	39 f2                	cmp    %esi,%edx
  8008eb:	72 ed                	jb     8008da <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ed:	5b                   	pop    %ebx
  8008ee:	5e                   	pop    %esi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
  8008f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fc:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ff:	89 f0                	mov    %esi,%eax
  800901:	85 d2                	test   %edx,%edx
  800903:	75 0a                	jne    80090f <strlcpy+0x1e>
  800905:	eb 17                	jmp    80091e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800907:	88 18                	mov    %bl,(%eax)
  800909:	83 c0 01             	add    $0x1,%eax
  80090c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80090f:	83 ea 01             	sub    $0x1,%edx
  800912:	74 07                	je     80091b <strlcpy+0x2a>
  800914:	0f b6 19             	movzbl (%ecx),%ebx
  800917:	84 db                	test   %bl,%bl
  800919:	75 ec                	jne    800907 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80091b:	c6 00 00             	movb   $0x0,(%eax)
  80091e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092d:	eb 06                	jmp    800935 <strcmp+0x11>
		p++, q++;
  80092f:	83 c1 01             	add    $0x1,%ecx
  800932:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800935:	0f b6 01             	movzbl (%ecx),%eax
  800938:	84 c0                	test   %al,%al
  80093a:	74 04                	je     800940 <strcmp+0x1c>
  80093c:	3a 02                	cmp    (%edx),%al
  80093e:	74 ef                	je     80092f <strcmp+0xb>
  800940:	0f b6 c0             	movzbl %al,%eax
  800943:	0f b6 12             	movzbl (%edx),%edx
  800946:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800954:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800957:	eb 09                	jmp    800962 <strncmp+0x18>
		n--, p++, q++;
  800959:	83 ea 01             	sub    $0x1,%edx
  80095c:	83 c0 01             	add    $0x1,%eax
  80095f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800962:	85 d2                	test   %edx,%edx
  800964:	75 07                	jne    80096d <strncmp+0x23>
  800966:	b8 00 00 00 00       	mov    $0x0,%eax
  80096b:	eb 13                	jmp    800980 <strncmp+0x36>
  80096d:	0f b6 18             	movzbl (%eax),%ebx
  800970:	84 db                	test   %bl,%bl
  800972:	74 04                	je     800978 <strncmp+0x2e>
  800974:	3a 19                	cmp    (%ecx),%bl
  800976:	74 e1                	je     800959 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800978:	0f b6 00             	movzbl (%eax),%eax
  80097b:	0f b6 11             	movzbl (%ecx),%edx
  80097e:	29 d0                	sub    %edx,%eax
}
  800980:	5b                   	pop    %ebx
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098d:	eb 07                	jmp    800996 <strchr+0x13>
		if (*s == c)
  80098f:	38 ca                	cmp    %cl,%dl
  800991:	74 0f                	je     8009a2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	0f b6 10             	movzbl (%eax),%edx
  800999:	84 d2                	test   %dl,%dl
  80099b:	75 f2                	jne    80098f <strchr+0xc>
  80099d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ae:	eb 07                	jmp    8009b7 <strfind+0x13>
		if (*s == c)
  8009b0:	38 ca                	cmp    %cl,%dl
  8009b2:	74 0a                	je     8009be <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009b4:	83 c0 01             	add    $0x1,%eax
  8009b7:	0f b6 10             	movzbl (%eax),%edx
  8009ba:	84 d2                	test   %dl,%dl
  8009bc:	75 f2                	jne    8009b0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009be:	5d                   	pop    %ebp
  8009bf:	90                   	nop
  8009c0:	c3                   	ret    

008009c1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	83 ec 0c             	sub    $0xc,%esp
  8009c7:	89 1c 24             	mov    %ebx,(%esp)
  8009ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ce:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009db:	85 c9                	test   %ecx,%ecx
  8009dd:	74 30                	je     800a0f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009df:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009e5:	75 25                	jne    800a0c <memset+0x4b>
  8009e7:	f6 c1 03             	test   $0x3,%cl
  8009ea:	75 20                	jne    800a0c <memset+0x4b>
		c &= 0xFF;
  8009ec:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ef:	89 d3                	mov    %edx,%ebx
  8009f1:	c1 e3 08             	shl    $0x8,%ebx
  8009f4:	89 d6                	mov    %edx,%esi
  8009f6:	c1 e6 18             	shl    $0x18,%esi
  8009f9:	89 d0                	mov    %edx,%eax
  8009fb:	c1 e0 10             	shl    $0x10,%eax
  8009fe:	09 f0                	or     %esi,%eax
  800a00:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a02:	09 d8                	or     %ebx,%eax
  800a04:	c1 e9 02             	shr    $0x2,%ecx
  800a07:	fc                   	cld    
  800a08:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0a:	eb 03                	jmp    800a0f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a0c:	fc                   	cld    
  800a0d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0f:	89 f8                	mov    %edi,%eax
  800a11:	8b 1c 24             	mov    (%esp),%ebx
  800a14:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a18:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a1c:	89 ec                	mov    %ebp,%esp
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	83 ec 08             	sub    $0x8,%esp
  800a26:	89 34 24             	mov    %esi,(%esp)
  800a29:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a36:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a38:	39 c6                	cmp    %eax,%esi
  800a3a:	73 35                	jae    800a71 <memmove+0x51>
  800a3c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3f:	39 d0                	cmp    %edx,%eax
  800a41:	73 2e                	jae    800a71 <memmove+0x51>
		s += n;
		d += n;
  800a43:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a45:	f6 c2 03             	test   $0x3,%dl
  800a48:	75 1b                	jne    800a65 <memmove+0x45>
  800a4a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a50:	75 13                	jne    800a65 <memmove+0x45>
  800a52:	f6 c1 03             	test   $0x3,%cl
  800a55:	75 0e                	jne    800a65 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a57:	83 ef 04             	sub    $0x4,%edi
  800a5a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a5d:	c1 e9 02             	shr    $0x2,%ecx
  800a60:	fd                   	std    
  800a61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a63:	eb 09                	jmp    800a6e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a65:	83 ef 01             	sub    $0x1,%edi
  800a68:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a6b:	fd                   	std    
  800a6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6f:	eb 20                	jmp    800a91 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a71:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a77:	75 15                	jne    800a8e <memmove+0x6e>
  800a79:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7f:	75 0d                	jne    800a8e <memmove+0x6e>
  800a81:	f6 c1 03             	test   $0x3,%cl
  800a84:	75 08                	jne    800a8e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a86:	c1 e9 02             	shr    $0x2,%ecx
  800a89:	fc                   	cld    
  800a8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8c:	eb 03                	jmp    800a91 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8e:	fc                   	cld    
  800a8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a91:	8b 34 24             	mov    (%esp),%esi
  800a94:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a98:	89 ec                	mov    %ebp,%esp
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa2:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	89 04 24             	mov    %eax,(%esp)
  800ab6:	e8 65 ff ff ff       	call   800a20 <memmove>
}
  800abb:	c9                   	leave  
  800abc:	c3                   	ret    

00800abd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	57                   	push   %edi
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800acc:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad1:	eb 1c                	jmp    800aef <memcmp+0x32>
		if (*s1 != *s2)
  800ad3:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800ad7:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800adb:	83 c2 01             	add    $0x1,%edx
  800ade:	83 e9 01             	sub    $0x1,%ecx
  800ae1:	38 d8                	cmp    %bl,%al
  800ae3:	74 0a                	je     800aef <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800ae5:	0f b6 c0             	movzbl %al,%eax
  800ae8:	0f b6 db             	movzbl %bl,%ebx
  800aeb:	29 d8                	sub    %ebx,%eax
  800aed:	eb 09                	jmp    800af8 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aef:	85 c9                	test   %ecx,%ecx
  800af1:	75 e0                	jne    800ad3 <memcmp+0x16>
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b06:	89 c2                	mov    %eax,%edx
  800b08:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b0b:	eb 07                	jmp    800b14 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0d:	38 08                	cmp    %cl,(%eax)
  800b0f:	74 07                	je     800b18 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b11:	83 c0 01             	add    $0x1,%eax
  800b14:	39 d0                	cmp    %edx,%eax
  800b16:	72 f5                	jb     800b0d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
  800b20:	83 ec 04             	sub    $0x4,%esp
  800b23:	8b 55 08             	mov    0x8(%ebp),%edx
  800b26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b29:	eb 03                	jmp    800b2e <strtol+0x14>
		s++;
  800b2b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2e:	0f b6 02             	movzbl (%edx),%eax
  800b31:	3c 20                	cmp    $0x20,%al
  800b33:	74 f6                	je     800b2b <strtol+0x11>
  800b35:	3c 09                	cmp    $0x9,%al
  800b37:	74 f2                	je     800b2b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b39:	3c 2b                	cmp    $0x2b,%al
  800b3b:	75 0c                	jne    800b49 <strtol+0x2f>
		s++;
  800b3d:	8d 52 01             	lea    0x1(%edx),%edx
  800b40:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b47:	eb 15                	jmp    800b5e <strtol+0x44>
	else if (*s == '-')
  800b49:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b50:	3c 2d                	cmp    $0x2d,%al
  800b52:	75 0a                	jne    800b5e <strtol+0x44>
		s++, neg = 1;
  800b54:	8d 52 01             	lea    0x1(%edx),%edx
  800b57:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5e:	85 db                	test   %ebx,%ebx
  800b60:	0f 94 c0             	sete   %al
  800b63:	74 05                	je     800b6a <strtol+0x50>
  800b65:	83 fb 10             	cmp    $0x10,%ebx
  800b68:	75 18                	jne    800b82 <strtol+0x68>
  800b6a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b6d:	75 13                	jne    800b82 <strtol+0x68>
  800b6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b73:	75 0d                	jne    800b82 <strtol+0x68>
		s += 2, base = 16;
  800b75:	83 c2 02             	add    $0x2,%edx
  800b78:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7d:	8d 76 00             	lea    0x0(%esi),%esi
  800b80:	eb 13                	jmp    800b95 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b82:	84 c0                	test   %al,%al
  800b84:	74 0f                	je     800b95 <strtol+0x7b>
  800b86:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b8b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8e:	75 05                	jne    800b95 <strtol+0x7b>
		s++, base = 8;
  800b90:	83 c2 01             	add    $0x1,%edx
  800b93:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b9c:	0f b6 0a             	movzbl (%edx),%ecx
  800b9f:	89 cf                	mov    %ecx,%edi
  800ba1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba4:	80 fb 09             	cmp    $0x9,%bl
  800ba7:	77 08                	ja     800bb1 <strtol+0x97>
			dig = *s - '0';
  800ba9:	0f be c9             	movsbl %cl,%ecx
  800bac:	83 e9 30             	sub    $0x30,%ecx
  800baf:	eb 1e                	jmp    800bcf <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800bb1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bb4:	80 fb 19             	cmp    $0x19,%bl
  800bb7:	77 08                	ja     800bc1 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800bb9:	0f be c9             	movsbl %cl,%ecx
  800bbc:	83 e9 57             	sub    $0x57,%ecx
  800bbf:	eb 0e                	jmp    800bcf <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800bc1:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bc4:	80 fb 19             	cmp    $0x19,%bl
  800bc7:	77 15                	ja     800bde <strtol+0xc4>
			dig = *s - 'A' + 10;
  800bc9:	0f be c9             	movsbl %cl,%ecx
  800bcc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcf:	39 f1                	cmp    %esi,%ecx
  800bd1:	7d 0b                	jge    800bde <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800bd3:	83 c2 01             	add    $0x1,%edx
  800bd6:	0f af c6             	imul   %esi,%eax
  800bd9:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bdc:	eb be                	jmp    800b9c <strtol+0x82>
  800bde:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800be0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be4:	74 05                	je     800beb <strtol+0xd1>
		*endptr = (char *) s;
  800be6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800beb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bef:	74 04                	je     800bf5 <strtol+0xdb>
  800bf1:	89 c8                	mov    %ecx,%eax
  800bf3:	f7 d8                	neg    %eax
}
  800bf5:	83 c4 04             	add    $0x4,%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    
  800bfd:	00 00                	add    %al,(%eax)
	...

00800c00 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	89 1c 24             	mov    %ebx,(%esp)
  800c09:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c0d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c11:	b8 00 00 00 00       	mov    $0x0,%eax
  800c16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c19:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1c:	89 c3                	mov    %eax,%ebx
  800c1e:	89 c7                	mov    %eax,%edi
  800c20:	89 c6                	mov    %eax,%esi
  800c22:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c24:	8b 1c 24             	mov    (%esp),%ebx
  800c27:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c2b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c2f:	89 ec                	mov    %ebp,%esp
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 38             	sub    $0x38,%esp
  800c39:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c3c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c3f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800c42:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c46:	75 0c                	jne    800c54 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800c48:	c7 04 24 48 1a 80 00 	movl   $0x801a48,(%esp)
  800c4f:	e8 bd f5 ff ff       	call   800211 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c54:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c59:	b8 09 00 00 00       	mov    $0x9,%eax
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	89 df                	mov    %ebx,%edi
  800c66:	89 de                	mov    %ebx,%esi
  800c68:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	7e 28                	jle    800c96 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c72:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c79:	00 
  800c7a:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  800c81:	00 
  800c82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c89:	00 
  800c8a:	c7 04 24 91 1a 80 00 	movl   $0x801a91,(%esp)
  800c91:	e8 a2 07 00 00       	call   801438 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c96:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c99:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c9c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c9f:	89 ec                	mov    %ebp,%esp
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	83 ec 38             	sub    $0x38,%esp
  800ca9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800caf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	89 cb                	mov    %ecx,%ebx
  800cc1:	89 cf                	mov    %ecx,%edi
  800cc3:	89 ce                	mov    %ecx,%esi
  800cc5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7e 28                	jle    800cf3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccf:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800cd6:	00 
  800cd7:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 91 1a 80 00 	movl   $0x801a91,(%esp)
  800cee:	e8 45 07 00 00       	call   801438 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfc:	89 ec                	mov    %ebp,%esp
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	89 1c 24             	mov    %ebx,(%esp)
  800d09:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d0d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	be 00 00 00 00       	mov    $0x0,%esi
  800d16:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d29:	8b 1c 24             	mov    (%esp),%ebx
  800d2c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d30:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d34:	89 ec                	mov    %ebp,%esp
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 38             	sub    $0x38,%esp
  800d3e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d41:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d44:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	89 df                	mov    %ebx,%edi
  800d59:	89 de                	mov    %ebx,%esi
  800d5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	7e 28                	jle    800d89 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d61:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d65:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d6c:	00 
  800d6d:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  800d74:	00 
  800d75:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7c:	00 
  800d7d:	c7 04 24 91 1a 80 00 	movl   $0x801a91,(%esp)
  800d84:	e8 af 06 00 00       	call   801438 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d89:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d8c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d92:	89 ec                	mov    %ebp,%esp
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 38             	sub    $0x38,%esp
  800d9c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daa:	b8 06 00 00 00       	mov    $0x6,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 df                	mov    %ebx,%edi
  800db7:	89 de                	mov    %ebx,%esi
  800db9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 28                	jle    800de7 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dca:	00 
  800dcb:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  800dd2:	00 
  800dd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dda:	00 
  800ddb:	c7 04 24 91 1a 80 00 	movl   $0x801a91,(%esp)
  800de2:	e8 51 06 00 00       	call   801438 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800de7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dea:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ded:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800df0:	89 ec                	mov    %ebp,%esp
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 38             	sub    $0x38,%esp
  800dfa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dfd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e00:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e03:	b8 05 00 00 00       	mov    $0x5,%eax
  800e08:	8b 75 18             	mov    0x18(%ebp),%esi
  800e0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 28                	jle    800e45 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e21:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e28:	00 
  800e29:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  800e30:	00 
  800e31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e38:	00 
  800e39:	c7 04 24 91 1a 80 00 	movl   $0x801a91,(%esp)
  800e40:	e8 f3 05 00 00       	call   801438 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e45:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e48:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e4b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4e:	89 ec                	mov    %ebp,%esp
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	83 ec 38             	sub    $0x38,%esp
  800e58:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e5b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e61:	be 00 00 00 00       	mov    $0x0,%esi
  800e66:	b8 04 00 00 00       	mov    $0x4,%eax
  800e6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	89 f7                	mov    %esi,%edi
  800e76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	7e 28                	jle    800ea4 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e80:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e87:	00 
  800e88:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  800e8f:	00 
  800e90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e97:	00 
  800e98:	c7 04 24 91 1a 80 00 	movl   $0x801a91,(%esp)
  800e9f:	e8 94 05 00 00       	call   801438 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ea4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eaa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ead:	89 ec                	mov    %ebp,%esp
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 0c             	sub    $0xc,%esp
  800eb7:	89 1c 24             	mov    %ebx,(%esp)
  800eba:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ebe:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ecc:	89 d1                	mov    %edx,%ecx
  800ece:	89 d3                	mov    %edx,%ebx
  800ed0:	89 d7                	mov    %edx,%edi
  800ed2:	89 d6                	mov    %edx,%esi
  800ed4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ed6:	8b 1c 24             	mov    (%esp),%ebx
  800ed9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800edd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ee1:	89 ec                	mov    %ebp,%esp
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	89 1c 24             	mov    %ebx,(%esp)
  800eee:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	ba 00 00 00 00       	mov    $0x0,%edx
  800efb:	b8 02 00 00 00       	mov    $0x2,%eax
  800f00:	89 d1                	mov    %edx,%ecx
  800f02:	89 d3                	mov    %edx,%ebx
  800f04:	89 d7                	mov    %edx,%edi
  800f06:	89 d6                	mov    %edx,%esi
  800f08:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f0a:	8b 1c 24             	mov    (%esp),%ebx
  800f0d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f11:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f15:	89 ec                	mov    %ebp,%esp
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	83 ec 38             	sub    $0x38,%esp
  800f1f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f22:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f25:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	89 cb                	mov    %ecx,%ebx
  800f37:	89 cf                	mov    %ecx,%edi
  800f39:	89 ce                	mov    %ecx,%esi
  800f3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	7e 28                	jle    800f69 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f41:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f45:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 08 74 1a 80 	movl   $0x801a74,0x8(%esp)
  800f54:	00 
  800f55:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f5c:	00 
  800f5d:	c7 04 24 91 1a 80 00 	movl   $0x801a91,(%esp)
  800f64:	e8 cf 04 00 00       	call   801438 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f69:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f6c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f6f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f72:	89 ec                	mov    %ebp,%esp
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 0c             	sub    $0xc,%esp
  800f7c:	89 1c 24             	mov    %ebx,(%esp)
  800f7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f83:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f87:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f91:	89 d1                	mov    %edx,%ecx
  800f93:	89 d3                	mov    %edx,%ebx
  800f95:	89 d7                	mov    %edx,%edi
  800f97:	89 d6                	mov    %edx,%esi
  800f99:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f9b:	8b 1c 24             	mov    (%esp),%ebx
  800f9e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fa2:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fa6:	89 ec                	mov    %ebp,%esp
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    
	...

00800fac <sfork>:
}

// Challenge!
int
sfork(void)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800fb2:	c7 44 24 08 9f 1a 80 	movl   $0x801a9f,0x8(%esp)
  800fb9:	00 
  800fba:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  800fc1:	00 
  800fc2:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  800fc9:	e8 6a 04 00 00       	call   801438 <_panic>

00800fce <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 20             	sub    $0x20,%esp
  800fd6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fd9:	8b 30                	mov    (%eax),%esi
	uint32_t err = utf->utf_err;
  800fdb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fdf:	75 1c                	jne    800ffd <pgfault+0x2f>

	// LAB 4: Your code here.
	FORKDEBUG("lib pgfault: fault address 0x%08x\n",(int)addr);

	if ( (err&FEC_WR) == 0 ) {
		panic("lib pgfault: The page fault is not caused by write\n");
  800fe1:	c7 44 24 08 e0 1a 80 	movl   $0x801ae0,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  800ff8:	e8 3b 04 00 00       	call   801438 <_panic>
	} 
	
	if ( (uvpt[PGNUM(addr)]&PTE_COW) == 0 ) {
  800ffd:	89 f0                	mov    %esi,%eax
  800fff:	c1 e8 0c             	shr    $0xc,%eax
  801002:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801009:	f6 c4 08             	test   $0x8,%ah
  80100c:	75 1c                	jne    80102a <pgfault+0x5c>
		panic("lib pgfault: The page fault's page is not COW\n");
  80100e:	c7 44 24 08 14 1b 80 	movl   $0x801b14,0x8(%esp)
  801015:	00 
  801016:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  80101d:	00 
  80101e:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  801025:	e8 0e 04 00 00       	call   801438 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
		
	envid_t envid=sys_getenvid();
  80102a:	e8 b6 fe ff ff       	call   800ee5 <sys_getenvid>
  80102f:	89 c3                	mov    %eax,%ebx
	int res;
	
	res=sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W);
  801031:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801038:	00 
  801039:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801040:	00 
  801041:	89 04 24             	mov    %eax,(%esp)
  801044:	e8 09 fe ff ff       	call   800e52 <sys_page_alloc>
	if (res<0) {
  801049:	85 c0                	test   %eax,%eax
  80104b:	79 1c                	jns    801069 <pgfault+0x9b>
		panic("lib pgfault: cannot allocate temp page\n");
  80104d:	c7 44 24 08 44 1b 80 	movl   $0x801b44,0x8(%esp)
  801054:	00 
  801055:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80105c:	00 
  80105d:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  801064:	e8 cf 03 00 00       	call   801438 <_panic>
	}

	memmove(PFTEMP, (void*)ROUNDDOWN(addr,PGSIZE),PGSIZE);
  801069:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  80106f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801076:	00 
  801077:	89 74 24 04          	mov    %esi,0x4(%esp)
  80107b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801082:	e8 99 f9 ff ff       	call   800a20 <memmove>
	
	res=sys_page_map(envid,PFTEMP,envid,(void*)ROUNDDOWN(addr,PGSIZE), PTE_U | PTE_P | PTE_W);
  801087:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80108e:	00 
  80108f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801093:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801097:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80109e:	00 
  80109f:	89 1c 24             	mov    %ebx,(%esp)
  8010a2:	e8 4d fd ff ff       	call   800df4 <sys_page_map>
	if (res<0) {
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	79 1c                	jns    8010c7 <pgfault+0xf9>
		panic("lib pgfault: cannot map page\n");
  8010ab:	c7 44 24 08 c0 1a 80 	movl   $0x801ac0,0x8(%esp)
  8010b2:	00 
  8010b3:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8010ba:	00 
  8010bb:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  8010c2:	e8 71 03 00 00       	call   801438 <_panic>
	}

	res=sys_page_unmap(envid,PFTEMP);
  8010c7:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010ce:	00 
  8010cf:	89 1c 24             	mov    %ebx,(%esp)
  8010d2:	e8 bf fc ff ff       	call   800d96 <sys_page_unmap>
	if (res<0) {
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	79 1c                	jns    8010f7 <pgfault+0x129>
		panic("lib pgfault: cannot unmap page\n");
  8010db:	c7 44 24 08 6c 1b 80 	movl   $0x801b6c,0x8(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  8010ea:	00 
  8010eb:	c7 04 24 b5 1a 80 00 	movl   $0x801ab5,(%esp)
  8010f2:	e8 41 03 00 00       	call   801438 <_panic>
	}
	return;
	//panic("pgfault not implemented");
}
  8010f7:	83 c4 20             	add    $0x20,%esp
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 4: Your code here.
	int i,j,pn=0;
	envid_t curenvid=sys_getenvid();
  801107:	e8 d9 fd ff ff       	call   800ee5 <sys_getenvid>
  80110c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	envid_t envid;
	int r;
	

	FORKDEBUG("fork: start to fork\n");
	set_pgfault_handler(pgfault);
  80110f:	c7 04 24 ce 0f 80 00 	movl   $0x800fce,(%esp)
  801116:	e8 75 03 00 00       	call   801490 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80111b:	ba 07 00 00 00       	mov    $0x7,%edx
  801120:	89 d0                	mov    %edx,%eax
  801122:	cd 30                	int    $0x30
  801124:	89 45 d8             	mov    %eax,-0x28(%ebp)
	FORKDEBUG("fork: already set pgfault handler\n");


	if ( (envid = sys_exofork()) < 0) {
  801127:	85 c0                	test   %eax,%eax
  801129:	0f 88 c2 01 00 00    	js     8012f1 <fork+0x1f3>
		return -1;
	}	

	FORKDEBUG("fork: already sys_exofork\n");
	
	if ( envid==0 ) {
  80112f:	85 c0                	test   %eax,%eax
  801131:	75 39                	jne    80116c <fork+0x6e>

		FORKDEBUG("fork: I am the child\n");
		sys_page_alloc(sys_getenvid(),(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P);
  801133:	e8 ad fd ff ff       	call   800ee5 <sys_getenvid>
  801138:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80113f:	00 
  801140:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801147:	ee 
  801148:	89 04 24             	mov    %eax,(%esp)
  80114b:	e8 02 fd ff ff       	call   800e52 <sys_page_alloc>

		thisenv=&envs[ENVX(sys_getenvid())];
  801150:	e8 90 fd ff ff       	call   800ee5 <sys_getenvid>
  801155:	25 ff 03 00 00       	and    $0x3ff,%eax
  80115a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80115d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801162:	a3 08 20 80 00       	mov    %eax,0x802008
		return envid;
  801167:	e9 8c 01 00 00       	jmp    8012f8 <fork+0x1fa>
  80116c:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
  801173:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801176:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  80117d:	a8 01                	test   $0x1,%al
  80117f:	0f 84 a9 00 00 00    	je     80122e <fork+0x130>
			for ( j=0;j<NPTENTRIES;j++) {
		//		cprintf("i: %d, j:%d\n",i,j);
				pn=PGNUM(PGADDR(i,j,0));
  801185:	c1 e2 16             	shl    $0x16,%edx
  801188:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80118b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801190:	89 de                	mov    %ebx,%esi
  801192:	c1 e6 0c             	shl    $0xc,%esi
  801195:	0b 75 e4             	or     -0x1c(%ebp),%esi
  801198:	c1 ee 0c             	shr    $0xc,%esi
				if ( pn== PGNUM(UXSTACKTOP-PGSIZE) ) {
  80119b:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  8011a1:	0f 84 87 00 00 00    	je     80122e <fork+0x130>
					break;
				}
				if ( uvpt[pn] & PTE_P ) {
  8011a7:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011ae:	a8 01                	test   $0x1,%al
  8011b0:	74 6d                	je     80121f <fork+0x121>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid();
  8011b2:	e8 2e fd ff ff       	call   800ee5 <sys_getenvid>
  8011b7:	89 45 e0             	mov    %eax,-0x20(%ebp)

	pte_t pte = uvpt[pn];
  8011ba:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm;

	perm = PTE_U | PTE_P;
	if ( pte & PTE_W || pte & PTE_COW ) {
  8011c1:	25 02 08 00 00       	and    $0x802,%eax
  8011c6:	83 f8 01             	cmp    $0x1,%eax
  8011c9:	19 ff                	sbb    %edi,%edi
  8011cb:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  8011d1:	81 c7 05 08 00 00    	add    $0x805,%edi
		perm |= PTE_COW;
	}

	r=sys_page_map(curenvid, (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE),perm);
  8011d7:	c1 e6 0c             	shl    $0xc,%esi
  8011da:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8011de:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011ed:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8011f0:	89 14 24             	mov    %edx,(%esp)
  8011f3:	e8 fc fb ff ff       	call   800df4 <sys_page_map>
	if (r<0) {
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 23                	js     80121f <fork+0x121>
		FORKDEBUG("lib duppage: sys_page_map curenvid fail\n");
		return r;
	}
	
	if ( perm & PTE_COW ) {
  8011fc:	f7 c7 00 08 00 00    	test   $0x800,%edi
  801202:	74 1b                	je     80121f <fork+0x121>
		r=sys_page_map(curenvid, (void*)(pn*PGSIZE), curenvid, (void*)(pn*PGSIZE), perm);
  801204:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801208:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80120c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80120f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801213:	89 74 24 04          	mov    %esi,0x4(%esp)
  801217:	89 04 24             	mov    %eax,(%esp)
  80121a:	e8 d5 fb ff ff       	call   800df4 <sys_page_map>
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
			for ( j=0;j<NPTENTRIES;j++) {
  80121f:	83 c3 01             	add    $0x1,%ebx
  801222:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801228:	0f 85 62 ff ff ff    	jne    801190 <fork+0x92>
//			duppage(envid,pn);
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
  80122e:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  801232:	81 7d dc bb 03 00 00 	cmpl   $0x3bb,-0x24(%ebp)
  801239:	0f 85 34 ff ff ff    	jne    801173 <fork+0x75>
			}
		}
	}
	FORKDEBUG("lib fork: after duppage\n");
	
	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_U | PTE_P | PTE_W)<0 ) {
  80123f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801246:	00 
  801247:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80124e:	ee 
  80124f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801252:	89 14 24             	mov    %edx,(%esp)
  801255:	e8 f8 fb ff ff       	call   800e52 <sys_page_alloc>
  80125a:	85 c0                	test   %eax,%eax
  80125c:	0f 88 8f 00 00 00    	js     8012f1 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_alloc fail\n");
		return -1;
	}

	if (sys_page_map(envid,(void*)(UXSTACKTOP-PGSIZE),curenvid,PFTEMP, PTE_U | PTE_P | PTE_W)<0) {
  801262:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801269:	00 
  80126a:	c7 44 24 0c 00 f0 7f 	movl   $0x7ff000,0xc(%esp)
  801271:	00 
  801272:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801275:	89 44 24 08          	mov    %eax,0x8(%esp)
  801279:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801280:	ee 
  801281:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801284:	89 14 24             	mov    %edx,(%esp)
  801287:	e8 68 fb ff ff       	call   800df4 <sys_page_map>
  80128c:	85 c0                	test   %eax,%eax
  80128e:	78 61                	js     8012f1 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_map envid fail\n");
		return -1;
	}

	memmove((void*)(UXSTACKTOP-PGSIZE) , PFTEMP ,PGSIZE);
  801290:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801297:	00 
  801298:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80129f:	00 
  8012a0:	c7 04 24 00 f0 bf ee 	movl   $0xeebff000,(%esp)
  8012a7:	e8 74 f7 ff ff       	call   800a20 <memmove>
	
	if (sys_page_unmap(curenvid,PFTEMP)<0) {
  8012ac:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8012b3:	00 
  8012b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012b7:	89 04 24             	mov    %eax,(%esp)
  8012ba:	e8 d7 fa ff ff       	call   800d96 <sys_page_unmap>
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 2e                	js     8012f1 <fork+0x1f3>
		return -1;
	}

	extern void _pgfault_upcall(void);

	if (sys_env_set_pgfault_upcall(envid,_pgfault_upcall)<0) {
  8012c3:	c7 44 24 04 04 15 80 	movl   $0x801504,0x4(%esp)
  8012ca:	00 
  8012cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012ce:	89 14 24             	mov    %edx,(%esp)
  8012d1:	e8 5d f9 ff ff       	call   800c33 <sys_env_set_pgfault_upcall>
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 17                	js     8012f1 <fork+0x1f3>
//	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P)<0) {
//		FORKDEBUG("lib fork: sys_page_alloc fail\n");
//		return -1;
//	}		

	if (sys_env_set_status(envid, ENV_RUNNABLE)<0) {
  8012da:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012e1:	00 
  8012e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012e5:	89 04 24             	mov    %eax,(%esp)
  8012e8:	e8 4b fa ff ff       	call   800d38 <sys_env_set_status>
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	79 07                	jns    8012f8 <fork+0x1fa>
  8012f1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)

	FORKDEBUG("lib fork: finish fork\n");

	return envid;
//	panic("fork not implemented");
}
  8012f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012fb:	83 c4 4c             	add    $0x4c,%esp
  8012fe:	5b                   	pop    %ebx
  8012ff:	5e                   	pop    %esi
  801300:	5f                   	pop    %edi
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    
	...

00801310 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801310:	55                   	push   %ebp
  801311:	89 e5                	mov    %esp,%ebp
  801313:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801316:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80131b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80131e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801324:	8b 12                	mov    (%edx),%edx
  801326:	39 ca                	cmp    %ecx,%edx
  801328:	75 0c                	jne    801336 <ipc_find_env+0x26>
			return envs[i].env_id;
  80132a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80132d:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801332:	8b 00                	mov    (%eax),%eax
  801334:	eb 0e                	jmp    801344 <ipc_find_env+0x34>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801336:	83 c0 01             	add    $0x1,%eax
  801339:	3d 00 04 00 00       	cmp    $0x400,%eax
  80133e:	75 db                	jne    80131b <ipc_find_env+0xb>
  801340:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	57                   	push   %edi
  80134a:	56                   	push   %esi
  80134b:	53                   	push   %ebx
  80134c:	83 ec 2c             	sub    $0x2c,%esp
  80134f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801352:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int res;
	do {
		res=sys_ipc_try_send(to_env,val,pg?pg:(void*)UTOP,perm);
  801355:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801358:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80135d:	85 f6                	test   %esi,%esi
  80135f:	74 03                	je     801364 <ipc_send+0x1e>
  801361:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801364:	8b 55 14             	mov    0x14(%ebp),%edx
  801367:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80136b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80136f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801372:	89 44 24 04          	mov    %eax,0x4(%esp)
  801376:	89 3c 24             	mov    %edi,(%esp)
  801379:	e8 82 f9 ff ff       	call   800d00 <sys_ipc_try_send>
		
		if( res!=0 && res!= -E_IPC_NOT_RECV) {
  80137e:	85 c0                	test   %eax,%eax
  801380:	0f 95 c3             	setne  %bl
  801383:	74 21                	je     8013a6 <ipc_send+0x60>
  801385:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801388:	74 1c                	je     8013a6 <ipc_send+0x60>
			panic("ipc_send: error\n");
  80138a:	c7 44 24 08 8c 1b 80 	movl   $0x801b8c,0x8(%esp)
  801391:	00 
  801392:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801399:	00 
  80139a:	c7 04 24 9d 1b 80 00 	movl   $0x801b9d,(%esp)
  8013a1:	e8 92 00 00 00       	call   801438 <_panic>
		}
		else {
			sys_yield();	
  8013a6:	e8 06 fb ff ff       	call   800eb1 <sys_yield>
		}
	} while(res!=0);
  8013ab:	84 db                	test   %bl,%bl
  8013ad:	75 a9                	jne    801358 <ipc_send+0x12>
	
	
//	panic("ipc_send not implemented");
}
  8013af:	83 c4 2c             	add    $0x2c,%esp
  8013b2:	5b                   	pop    %ebx
  8013b3:	5e                   	pop    %esi
  8013b4:	5f                   	pop    %edi
  8013b5:	5d                   	pop    %ebp
  8013b6:	c3                   	ret    

008013b7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	83 ec 28             	sub    $0x28,%esp
  8013bd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013c0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013c3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013cc:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int res;

	res=sys_ipc_recv( pg?pg:(void*)UTOP);
  8013cf:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013d4:	85 db                	test   %ebx,%ebx
  8013d6:	74 02                	je     8013da <ipc_recv+0x23>
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	89 04 24             	mov    %eax,(%esp)
  8013dd:	e8 c1 f8 ff ff       	call   800ca3 <sys_ipc_recv>

	if( from_env_store) {
  8013e2:	85 f6                	test   %esi,%esi
  8013e4:	74 14                	je     8013fa <ipc_recv+0x43>
		*from_env_store = (res==0)? thisenv->env_ipc_from:0;
  8013e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	75 09                	jne    8013f8 <ipc_recv+0x41>
  8013ef:	8b 15 08 20 80 00    	mov    0x802008,%edx
  8013f5:	8b 52 74             	mov    0x74(%edx),%edx
  8013f8:	89 16                	mov    %edx,(%esi)
	}

	if( perm_store) {
  8013fa:	85 ff                	test   %edi,%edi
  8013fc:	74 1f                	je     80141d <ipc_recv+0x66>
		*perm_store = (res==0 && (uint32_t)pg < UTOP)? thisenv->env_ipc_perm:0;
  8013fe:	85 c0                	test   %eax,%eax
  801400:	75 08                	jne    80140a <ipc_recv+0x53>
  801402:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801408:	76 08                	jbe    801412 <ipc_recv+0x5b>
  80140a:	ba 00 00 00 00       	mov    $0x0,%edx
  80140f:	90                   	nop
  801410:	eb 09                	jmp    80141b <ipc_recv+0x64>
  801412:	8b 15 08 20 80 00    	mov    0x802008,%edx
  801418:	8b 52 78             	mov    0x78(%edx),%edx
  80141b:	89 17                	mov    %edx,(%edi)
	}
	
	if( res) {
  80141d:	85 c0                	test   %eax,%eax
  80141f:	75 08                	jne    801429 <ipc_recv+0x72>
		return res;
	}
	
//	panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801421:	a1 08 20 80 00       	mov    0x802008,%eax
  801426:	8b 40 70             	mov    0x70(%eax),%eax
}
  801429:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80142c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80142f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801432:	89 ec                	mov    %ebp,%esp
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    
	...

00801438 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	56                   	push   %esi
  80143c:	53                   	push   %ebx
  80143d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801440:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801443:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801449:	e8 97 fa ff ff       	call   800ee5 <sys_getenvid>
  80144e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801451:	89 54 24 10          	mov    %edx,0x10(%esp)
  801455:	8b 55 08             	mov    0x8(%ebp),%edx
  801458:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80145c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801460:	89 44 24 04          	mov    %eax,0x4(%esp)
  801464:	c7 04 24 a8 1b 80 00 	movl   $0x801ba8,(%esp)
  80146b:	e8 a1 ed ff ff       	call   800211 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801470:	89 74 24 04          	mov    %esi,0x4(%esp)
  801474:	8b 45 10             	mov    0x10(%ebp),%eax
  801477:	89 04 24             	mov    %eax,(%esp)
  80147a:	e8 31 ed ff ff       	call   8001b0 <vcprintf>
	cprintf("\n");
  80147f:	c7 04 24 dc 1a 80 00 	movl   $0x801adc,(%esp)
  801486:	e8 86 ed ff ff       	call   800211 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80148b:	cc                   	int3   
  80148c:	eb fd                	jmp    80148b <_panic+0x53>
	...

00801490 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801496:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  80149d:	75 58                	jne    8014f7 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  80149f:	a1 08 20 80 00       	mov    0x802008,%eax
  8014a4:	8b 40 48             	mov    0x48(%eax),%eax
  8014a7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014ae:	00 
  8014af:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8014b6:	ee 
  8014b7:	89 04 24             	mov    %eax,(%esp)
  8014ba:	e8 93 f9 ff ff       	call   800e52 <sys_page_alloc>
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	74 1c                	je     8014df <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  8014c3:	c7 44 24 08 cc 1b 80 	movl   $0x801bcc,0x8(%esp)
  8014ca:	00 
  8014cb:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014d2:	00 
  8014d3:	c7 04 24 f8 1b 80 00 	movl   $0x801bf8,(%esp)
  8014da:	e8 59 ff ff ff       	call   801438 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  8014df:	a1 08 20 80 00       	mov    0x802008,%eax
  8014e4:	8b 40 48             	mov    0x48(%eax),%eax
  8014e7:	c7 44 24 04 04 15 80 	movl   $0x801504,0x4(%esp)
  8014ee:	00 
  8014ef:	89 04 24             	mov    %eax,(%esp)
  8014f2:	e8 3c f7 ff ff       	call   800c33 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fa:	a3 0c 20 80 00       	mov    %eax,0x80200c
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  8014ff:	c9                   	leave  
  801500:	c3                   	ret    
  801501:	00 00                	add    %al,(%eax)
	...

00801504 <_pgfault_upcall>:
  801504:	54                   	push   %esp
  801505:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80150a:	ff d0                	call   *%eax
  80150c:	83 c4 04             	add    $0x4,%esp
  80150f:	89 e3                	mov    %esp,%ebx
  801511:	8b 44 24 28          	mov    0x28(%esp),%eax
  801515:	8b 64 24 30          	mov    0x30(%esp),%esp
  801519:	50                   	push   %eax
  80151a:	89 dc                	mov    %ebx,%esp
  80151c:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  801521:	58                   	pop    %eax
  801522:	58                   	pop    %eax
  801523:	61                   	popa   
  801524:	83 c4 04             	add    $0x4,%esp
  801527:	9d                   	popf   
  801528:	5c                   	pop    %esp
  801529:	c3                   	ret    
  80152a:	00 00                	add    %al,(%eax)
  80152c:	00 00                	add    %al,(%eax)
	...

00801530 <__udivdi3>:
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	57                   	push   %edi
  801534:	56                   	push   %esi
  801535:	83 ec 10             	sub    $0x10,%esp
  801538:	8b 45 14             	mov    0x14(%ebp),%eax
  80153b:	8b 55 08             	mov    0x8(%ebp),%edx
  80153e:	8b 75 10             	mov    0x10(%ebp),%esi
  801541:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801544:	85 c0                	test   %eax,%eax
  801546:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801549:	75 35                	jne    801580 <__udivdi3+0x50>
  80154b:	39 fe                	cmp    %edi,%esi
  80154d:	77 61                	ja     8015b0 <__udivdi3+0x80>
  80154f:	85 f6                	test   %esi,%esi
  801551:	75 0b                	jne    80155e <__udivdi3+0x2e>
  801553:	b8 01 00 00 00       	mov    $0x1,%eax
  801558:	31 d2                	xor    %edx,%edx
  80155a:	f7 f6                	div    %esi
  80155c:	89 c6                	mov    %eax,%esi
  80155e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801561:	31 d2                	xor    %edx,%edx
  801563:	89 f8                	mov    %edi,%eax
  801565:	f7 f6                	div    %esi
  801567:	89 c7                	mov    %eax,%edi
  801569:	89 c8                	mov    %ecx,%eax
  80156b:	f7 f6                	div    %esi
  80156d:	89 c1                	mov    %eax,%ecx
  80156f:	89 fa                	mov    %edi,%edx
  801571:	89 c8                	mov    %ecx,%eax
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	5e                   	pop    %esi
  801577:	5f                   	pop    %edi
  801578:	5d                   	pop    %ebp
  801579:	c3                   	ret    
  80157a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801580:	39 f8                	cmp    %edi,%eax
  801582:	77 1c                	ja     8015a0 <__udivdi3+0x70>
  801584:	0f bd d0             	bsr    %eax,%edx
  801587:	83 f2 1f             	xor    $0x1f,%edx
  80158a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80158d:	75 39                	jne    8015c8 <__udivdi3+0x98>
  80158f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801592:	0f 86 a0 00 00 00    	jbe    801638 <__udivdi3+0x108>
  801598:	39 f8                	cmp    %edi,%eax
  80159a:	0f 82 98 00 00 00    	jb     801638 <__udivdi3+0x108>
  8015a0:	31 ff                	xor    %edi,%edi
  8015a2:	31 c9                	xor    %ecx,%ecx
  8015a4:	89 c8                	mov    %ecx,%eax
  8015a6:	89 fa                	mov    %edi,%edx
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	5e                   	pop    %esi
  8015ac:	5f                   	pop    %edi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    
  8015af:	90                   	nop
  8015b0:	89 d1                	mov    %edx,%ecx
  8015b2:	89 fa                	mov    %edi,%edx
  8015b4:	89 c8                	mov    %ecx,%eax
  8015b6:	31 ff                	xor    %edi,%edi
  8015b8:	f7 f6                	div    %esi
  8015ba:	89 c1                	mov    %eax,%ecx
  8015bc:	89 fa                	mov    %edi,%edx
  8015be:	89 c8                	mov    %ecx,%eax
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	5e                   	pop    %esi
  8015c4:	5f                   	pop    %edi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    
  8015c7:	90                   	nop
  8015c8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015cc:	89 f2                	mov    %esi,%edx
  8015ce:	d3 e0                	shl    %cl,%eax
  8015d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015d3:	b8 20 00 00 00       	mov    $0x20,%eax
  8015d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8015db:	89 c1                	mov    %eax,%ecx
  8015dd:	d3 ea                	shr    %cl,%edx
  8015df:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015e3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8015e6:	d3 e6                	shl    %cl,%esi
  8015e8:	89 c1                	mov    %eax,%ecx
  8015ea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8015ed:	89 fe                	mov    %edi,%esi
  8015ef:	d3 ee                	shr    %cl,%esi
  8015f1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015fb:	d3 e7                	shl    %cl,%edi
  8015fd:	89 c1                	mov    %eax,%ecx
  8015ff:	d3 ea                	shr    %cl,%edx
  801601:	09 d7                	or     %edx,%edi
  801603:	89 f2                	mov    %esi,%edx
  801605:	89 f8                	mov    %edi,%eax
  801607:	f7 75 ec             	divl   -0x14(%ebp)
  80160a:	89 d6                	mov    %edx,%esi
  80160c:	89 c7                	mov    %eax,%edi
  80160e:	f7 65 e8             	mull   -0x18(%ebp)
  801611:	39 d6                	cmp    %edx,%esi
  801613:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801616:	72 30                	jb     801648 <__udivdi3+0x118>
  801618:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80161b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80161f:	d3 e2                	shl    %cl,%edx
  801621:	39 c2                	cmp    %eax,%edx
  801623:	73 05                	jae    80162a <__udivdi3+0xfa>
  801625:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801628:	74 1e                	je     801648 <__udivdi3+0x118>
  80162a:	89 f9                	mov    %edi,%ecx
  80162c:	31 ff                	xor    %edi,%edi
  80162e:	e9 71 ff ff ff       	jmp    8015a4 <__udivdi3+0x74>
  801633:	90                   	nop
  801634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801638:	31 ff                	xor    %edi,%edi
  80163a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80163f:	e9 60 ff ff ff       	jmp    8015a4 <__udivdi3+0x74>
  801644:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801648:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80164b:	31 ff                	xor    %edi,%edi
  80164d:	89 c8                	mov    %ecx,%eax
  80164f:	89 fa                	mov    %edi,%edx
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	5e                   	pop    %esi
  801655:	5f                   	pop    %edi
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    
	...

00801660 <__umoddi3>:
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	57                   	push   %edi
  801664:	56                   	push   %esi
  801665:	83 ec 20             	sub    $0x20,%esp
  801668:	8b 55 14             	mov    0x14(%ebp),%edx
  80166b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80166e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801671:	8b 75 0c             	mov    0xc(%ebp),%esi
  801674:	85 d2                	test   %edx,%edx
  801676:	89 c8                	mov    %ecx,%eax
  801678:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80167b:	75 13                	jne    801690 <__umoddi3+0x30>
  80167d:	39 f7                	cmp    %esi,%edi
  80167f:	76 3f                	jbe    8016c0 <__umoddi3+0x60>
  801681:	89 f2                	mov    %esi,%edx
  801683:	f7 f7                	div    %edi
  801685:	89 d0                	mov    %edx,%eax
  801687:	31 d2                	xor    %edx,%edx
  801689:	83 c4 20             	add    $0x20,%esp
  80168c:	5e                   	pop    %esi
  80168d:	5f                   	pop    %edi
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    
  801690:	39 f2                	cmp    %esi,%edx
  801692:	77 4c                	ja     8016e0 <__umoddi3+0x80>
  801694:	0f bd ca             	bsr    %edx,%ecx
  801697:	83 f1 1f             	xor    $0x1f,%ecx
  80169a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80169d:	75 51                	jne    8016f0 <__umoddi3+0x90>
  80169f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8016a2:	0f 87 e0 00 00 00    	ja     801788 <__umoddi3+0x128>
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	29 f8                	sub    %edi,%eax
  8016ad:	19 d6                	sbb    %edx,%esi
  8016af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8016b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b5:	89 f2                	mov    %esi,%edx
  8016b7:	83 c4 20             	add    $0x20,%esp
  8016ba:	5e                   	pop    %esi
  8016bb:	5f                   	pop    %edi
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    
  8016be:	66 90                	xchg   %ax,%ax
  8016c0:	85 ff                	test   %edi,%edi
  8016c2:	75 0b                	jne    8016cf <__umoddi3+0x6f>
  8016c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c9:	31 d2                	xor    %edx,%edx
  8016cb:	f7 f7                	div    %edi
  8016cd:	89 c7                	mov    %eax,%edi
  8016cf:	89 f0                	mov    %esi,%eax
  8016d1:	31 d2                	xor    %edx,%edx
  8016d3:	f7 f7                	div    %edi
  8016d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d8:	f7 f7                	div    %edi
  8016da:	eb a9                	jmp    801685 <__umoddi3+0x25>
  8016dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016e0:	89 c8                	mov    %ecx,%eax
  8016e2:	89 f2                	mov    %esi,%edx
  8016e4:	83 c4 20             	add    $0x20,%esp
  8016e7:	5e                   	pop    %esi
  8016e8:	5f                   	pop    %edi
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    
  8016eb:	90                   	nop
  8016ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016f4:	d3 e2                	shl    %cl,%edx
  8016f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8016f9:	ba 20 00 00 00       	mov    $0x20,%edx
  8016fe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801701:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801704:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801708:	89 fa                	mov    %edi,%edx
  80170a:	d3 ea                	shr    %cl,%edx
  80170c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801710:	0b 55 f4             	or     -0xc(%ebp),%edx
  801713:	d3 e7                	shl    %cl,%edi
  801715:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801719:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80171c:	89 f2                	mov    %esi,%edx
  80171e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801721:	89 c7                	mov    %eax,%edi
  801723:	d3 ea                	shr    %cl,%edx
  801725:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801729:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	d3 e6                	shl    %cl,%esi
  801730:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801734:	d3 ea                	shr    %cl,%edx
  801736:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80173a:	09 d6                	or     %edx,%esi
  80173c:	89 f0                	mov    %esi,%eax
  80173e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801741:	d3 e7                	shl    %cl,%edi
  801743:	89 f2                	mov    %esi,%edx
  801745:	f7 75 f4             	divl   -0xc(%ebp)
  801748:	89 d6                	mov    %edx,%esi
  80174a:	f7 65 e8             	mull   -0x18(%ebp)
  80174d:	39 d6                	cmp    %edx,%esi
  80174f:	72 2b                	jb     80177c <__umoddi3+0x11c>
  801751:	39 c7                	cmp    %eax,%edi
  801753:	72 23                	jb     801778 <__umoddi3+0x118>
  801755:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801759:	29 c7                	sub    %eax,%edi
  80175b:	19 d6                	sbb    %edx,%esi
  80175d:	89 f0                	mov    %esi,%eax
  80175f:	89 f2                	mov    %esi,%edx
  801761:	d3 ef                	shr    %cl,%edi
  801763:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801767:	d3 e0                	shl    %cl,%eax
  801769:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80176d:	09 f8                	or     %edi,%eax
  80176f:	d3 ea                	shr    %cl,%edx
  801771:	83 c4 20             	add    $0x20,%esp
  801774:	5e                   	pop    %esi
  801775:	5f                   	pop    %edi
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    
  801778:	39 d6                	cmp    %edx,%esi
  80177a:	75 d9                	jne    801755 <__umoddi3+0xf5>
  80177c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80177f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801782:	eb d1                	jmp    801755 <__umoddi3+0xf5>
  801784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801788:	39 f2                	cmp    %esi,%edx
  80178a:	0f 82 18 ff ff ff    	jb     8016a8 <__umoddi3+0x48>
  801790:	e9 1d ff ff ff       	jmp    8016b2 <__umoddi3+0x52>
