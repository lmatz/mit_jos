
obj/user/faultread:     file format elf32-i386


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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003a:	a1 00 00 00 00       	mov    0x0,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 a0 11 80 00 	movl   $0x8011a0,(%esp)
  80004a:	e8 ca 00 00 00       	call   800119 <cprintf>
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
  800066:	e8 8a 0d 00 00       	call   800df5 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 20 80 00       	mov    %eax,0x802000

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
  8000b1:	e8 73 0d 00 00       	call   800e29 <sys_env_destroy>
}
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000c8:	00 00 00 
	b.cnt = 0;
  8000cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8000df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ed:	c7 04 24 33 01 80 00 	movl   $0x800133,(%esp)
  8000f4:	e8 c6 01 00 00       	call   8002bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000f9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8000ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800103:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800109:	89 04 24             	mov    %eax,(%esp)
  80010c:	e8 ff 09 00 00       	call   800b10 <sys_cputs>

	return b.cnt;
}
  800111:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80011f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800122:	89 44 24 04          	mov    %eax,0x4(%esp)
  800126:	8b 45 08             	mov    0x8(%ebp),%eax
  800129:	89 04 24             	mov    %eax,(%esp)
  80012c:	e8 87 ff ff ff       	call   8000b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800131:	c9                   	leave  
  800132:	c3                   	ret    

00800133 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	53                   	push   %ebx
  800137:	83 ec 14             	sub    $0x14,%esp
  80013a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013d:	8b 03                	mov    (%ebx),%eax
  80013f:	8b 55 08             	mov    0x8(%ebp),%edx
  800142:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800146:	83 c0 01             	add    $0x1,%eax
  800149:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80014b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800150:	75 19                	jne    80016b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800152:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800159:	00 
  80015a:	8d 43 08             	lea    0x8(%ebx),%eax
  80015d:	89 04 24             	mov    %eax,(%esp)
  800160:	e8 ab 09 00 00       	call   800b10 <sys_cputs>
		b->idx = 0;
  800165:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80016b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80016f:	83 c4 14             	add    $0x14,%esp
  800172:	5b                   	pop    %ebx
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 4c             	sub    $0x4c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800194:	8b 55 0c             	mov    0xc(%ebp),%edx
  800197:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
  80019d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ab:	39 d1                	cmp    %edx,%ecx
  8001ad:	72 07                	jb     8001b6 <printnum+0x36>
  8001af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001b2:	39 d0                	cmp    %edx,%eax
  8001b4:	77 69                	ja     80021f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001ba:	83 eb 01             	sub    $0x1,%ebx
  8001bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001c9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001d0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e1:	00 
  8001e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ef:	e8 2c 0d 00 00       	call   800f20 <__udivdi3>
  8001f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8001f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8001fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8001fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800202:	89 04 24             	mov    %eax,(%esp)
  800205:	89 54 24 04          	mov    %edx,0x4(%esp)
  800209:	89 f2                	mov    %esi,%edx
  80020b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020e:	e8 6d ff ff ff       	call   800180 <printnum>
  800213:	eb 11                	jmp    800226 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800215:	89 74 24 04          	mov    %esi,0x4(%esp)
  800219:	89 3c 24             	mov    %edi,(%esp)
  80021c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021f:	83 eb 01             	sub    $0x1,%ebx
  800222:	85 db                	test   %ebx,%ebx
  800224:	7f ef                	jg     800215 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80022a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80022e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023c:	00 
  80023d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800240:	89 14 24             	mov    %edx,(%esp)
  800243:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800246:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80024a:	e8 01 0e 00 00       	call   801050 <__umoddi3>
  80024f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800253:	0f be 80 c8 11 80 00 	movsbl 0x8011c8(%eax),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800260:	83 c4 4c             	add    $0x4c,%esp
  800263:	5b                   	pop    %ebx
  800264:	5e                   	pop    %esi
  800265:	5f                   	pop    %edi
  800266:	5d                   	pop    %ebp
  800267:	c3                   	ret    

00800268 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80026b:	83 fa 01             	cmp    $0x1,%edx
  80026e:	7e 0e                	jle    80027e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800270:	8b 10                	mov    (%eax),%edx
  800272:	8d 4a 08             	lea    0x8(%edx),%ecx
  800275:	89 08                	mov    %ecx,(%eax)
  800277:	8b 02                	mov    (%edx),%eax
  800279:	8b 52 04             	mov    0x4(%edx),%edx
  80027c:	eb 22                	jmp    8002a0 <getuint+0x38>
	else if (lflag)
  80027e:	85 d2                	test   %edx,%edx
  800280:	74 10                	je     800292 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800282:	8b 10                	mov    (%eax),%edx
  800284:	8d 4a 04             	lea    0x4(%edx),%ecx
  800287:	89 08                	mov    %ecx,(%eax)
  800289:	8b 02                	mov    (%edx),%eax
  80028b:	ba 00 00 00 00       	mov    $0x0,%edx
  800290:	eb 0e                	jmp    8002a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 04             	lea    0x4(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002a0:	5d                   	pop    %ebp
  8002a1:	c3                   	ret    

008002a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a2:	55                   	push   %ebp
  8002a3:	89 e5                	mov    %esp,%ebp
  8002a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ac:	8b 10                	mov    (%eax),%edx
  8002ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b1:	73 0a                	jae    8002bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b6:	88 0a                	mov    %cl,(%edx)
  8002b8:	83 c2 01             	add    $0x1,%edx
  8002bb:	89 10                	mov    %edx,(%eax)
}
  8002bd:	5d                   	pop    %ebp
  8002be:	c3                   	ret    

008002bf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002bf:	55                   	push   %ebp
  8002c0:	89 e5                	mov    %esp,%ebp
  8002c2:	57                   	push   %edi
  8002c3:	56                   	push   %esi
  8002c4:	53                   	push   %ebx
  8002c5:	83 ec 4c             	sub    $0x4c,%esp
  8002c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002d1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002d8:	eb 11                	jmp    8002eb <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	0f 84 b0 03 00 00    	je     800692 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  8002e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e6:	89 04 24             	mov    %eax,(%esp)
  8002e9:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002eb:	0f b6 03             	movzbl (%ebx),%eax
  8002ee:	83 c3 01             	add    $0x1,%ebx
  8002f1:	83 f8 25             	cmp    $0x25,%eax
  8002f4:	75 e4                	jne    8002da <vprintfmt+0x1b>
  8002f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8002fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800302:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800306:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800314:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800317:	eb 06                	jmp    80031f <vprintfmt+0x60>
  800319:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80031d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	0f b6 0b             	movzbl (%ebx),%ecx
  800322:	0f b6 c1             	movzbl %cl,%eax
  800325:	8d 53 01             	lea    0x1(%ebx),%edx
  800328:	83 e9 23             	sub    $0x23,%ecx
  80032b:	80 f9 55             	cmp    $0x55,%cl
  80032e:	0f 87 41 03 00 00    	ja     800675 <vprintfmt+0x3b6>
  800334:	0f b6 c9             	movzbl %cl,%ecx
  800337:	ff 24 8d 80 12 80 00 	jmp    *0x801280(,%ecx,4)
  80033e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800342:	eb d9                	jmp    80031d <vprintfmt+0x5e>
  800344:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80034b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800350:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800353:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800357:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80035a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80035d:	83 fb 09             	cmp    $0x9,%ebx
  800360:	77 2b                	ja     80038d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800362:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800365:	eb e9                	jmp    800350 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 48 04             	lea    0x4(%eax),%ecx
  80036d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800370:	8b 00                	mov    (%eax),%eax
  800372:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800375:	eb 19                	jmp    800390 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800377:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037a:	c1 f8 1f             	sar    $0x1f,%eax
  80037d:	f7 d0                	not    %eax
  80037f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800382:	eb 99                	jmp    80031d <vprintfmt+0x5e>
  800384:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80038b:	eb 90                	jmp    80031d <vprintfmt+0x5e>
  80038d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800390:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800394:	79 87                	jns    80031d <vprintfmt+0x5e>
  800396:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800399:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80039c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80039f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003a2:	e9 76 ff ff ff       	jmp    80031d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003ab:	e9 6d ff ff ff       	jmp    80031d <vprintfmt+0x5e>
  8003b0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 50 04             	lea    0x4(%eax),%edx
  8003b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	89 04 24             	mov    %eax,(%esp)
  8003c5:	ff d7                	call   *%edi
  8003c7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8003ca:	e9 1c ff ff ff       	jmp    8002eb <vprintfmt+0x2c>
  8003cf:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 50 04             	lea    0x4(%eax),%edx
  8003d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003db:	8b 00                	mov    (%eax),%eax
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 fa 1f             	sar    $0x1f,%edx
  8003e2:	31 d0                	xor    %edx,%eax
  8003e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 09             	cmp    $0x9,%eax
  8003e9:	7f 0b                	jg     8003f6 <vprintfmt+0x137>
  8003eb:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	75 20                	jne    800416 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003fa:	c7 44 24 08 d9 11 80 	movl   $0x8011d9,0x8(%esp)
  800401:	00 
  800402:	89 74 24 04          	mov    %esi,0x4(%esp)
  800406:	89 3c 24             	mov    %edi,(%esp)
  800409:	e8 0c 03 00 00       	call   80071a <printfmt>
  80040e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800411:	e9 d5 fe ff ff       	jmp    8002eb <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800416:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80041a:	c7 44 24 08 e2 11 80 	movl   $0x8011e2,0x8(%esp)
  800421:	00 
  800422:	89 74 24 04          	mov    %esi,0x4(%esp)
  800426:	89 3c 24             	mov    %edi,(%esp)
  800429:	e8 ec 02 00 00       	call   80071a <printfmt>
  80042e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800431:	e9 b5 fe ff ff       	jmp    8002eb <vprintfmt+0x2c>
  800436:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800439:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80043c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80043f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 18                	mov    (%eax),%ebx
  80044d:	85 db                	test   %ebx,%ebx
  80044f:	75 05                	jne    800456 <vprintfmt+0x197>
  800451:	bb e5 11 80 00       	mov    $0x8011e5,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800456:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80045a:	7e 76                	jle    8004d2 <vprintfmt+0x213>
  80045c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800460:	74 7a                	je     8004dc <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800462:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800466:	89 1c 24             	mov    %ebx,(%esp)
  800469:	e8 fa 02 00 00       	call   800768 <strnlen>
  80046e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800471:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800473:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800477:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80047a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80047d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047f:	eb 0f                	jmp    800490 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800481:	89 74 24 04          	mov    %esi,0x4(%esp)
  800485:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800488:	89 04 24             	mov    %eax,(%esp)
  80048b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	83 eb 01             	sub    $0x1,%ebx
  800490:	85 db                	test   %ebx,%ebx
  800492:	7f ed                	jg     800481 <vprintfmt+0x1c2>
  800494:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800497:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80049a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80049d:	89 f7                	mov    %esi,%edi
  80049f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004a2:	eb 40                	jmp    8004e4 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a8:	74 18                	je     8004c2 <vprintfmt+0x203>
  8004aa:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ad:	83 fa 5e             	cmp    $0x5e,%edx
  8004b0:	76 10                	jbe    8004c2 <vprintfmt+0x203>
					putch('?', putdat);
  8004b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004b6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004bd:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004c0:	eb 0a                	jmp    8004cc <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c6:	89 04 24             	mov    %eax,(%esp)
  8004c9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004cc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8004d0:	eb 12                	jmp    8004e4 <vprintfmt+0x225>
  8004d2:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004d5:	89 f7                	mov    %esi,%edi
  8004d7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004da:	eb 08                	jmp    8004e4 <vprintfmt+0x225>
  8004dc:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004df:	89 f7                	mov    %esi,%edi
  8004e1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004e4:	0f be 03             	movsbl (%ebx),%eax
  8004e7:	83 c3 01             	add    $0x1,%ebx
  8004ea:	85 c0                	test   %eax,%eax
  8004ec:	74 25                	je     800513 <vprintfmt+0x254>
  8004ee:	85 f6                	test   %esi,%esi
  8004f0:	78 b2                	js     8004a4 <vprintfmt+0x1e5>
  8004f2:	83 ee 01             	sub    $0x1,%esi
  8004f5:	79 ad                	jns    8004a4 <vprintfmt+0x1e5>
  8004f7:	89 fe                	mov    %edi,%esi
  8004f9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8004fc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8004ff:	eb 1a                	jmp    80051b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800501:	89 74 24 04          	mov    %esi,0x4(%esp)
  800505:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80050c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80050e:	83 eb 01             	sub    $0x1,%ebx
  800511:	eb 08                	jmp    80051b <vprintfmt+0x25c>
  800513:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800516:	89 fe                	mov    %edi,%esi
  800518:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80051b:	85 db                	test   %ebx,%ebx
  80051d:	7f e2                	jg     800501 <vprintfmt+0x242>
  80051f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800522:	e9 c4 fd ff ff       	jmp    8002eb <vprintfmt+0x2c>
  800527:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80052a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80052d:	83 f9 01             	cmp    $0x1,%ecx
  800530:	7e 16                	jle    800548 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8d 50 08             	lea    0x8(%eax),%edx
  800538:	89 55 14             	mov    %edx,0x14(%ebp)
  80053b:	8b 10                	mov    (%eax),%edx
  80053d:	8b 48 04             	mov    0x4(%eax),%ecx
  800540:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800543:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800546:	eb 32                	jmp    80057a <vprintfmt+0x2bb>
	else if (lflag)
  800548:	85 c9                	test   %ecx,%ecx
  80054a:	74 18                	je     800564 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	8b 00                	mov    (%eax),%eax
  800557:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055a:	89 c1                	mov    %eax,%ecx
  80055c:	c1 f9 1f             	sar    $0x1f,%ecx
  80055f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800562:	eb 16                	jmp    80057a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 50 04             	lea    0x4(%eax),%edx
  80056a:	89 55 14             	mov    %edx,0x14(%ebp)
  80056d:	8b 00                	mov    (%eax),%eax
  80056f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800572:	89 c2                	mov    %eax,%edx
  800574:	c1 fa 1f             	sar    $0x1f,%edx
  800577:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80057d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800580:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800585:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800589:	0f 89 a7 00 00 00    	jns    800636 <vprintfmt+0x377>
				putch('-', putdat);
  80058f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800593:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80059a:	ff d7                	call   *%edi
				num = -(long long) num;
  80059c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80059f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005a2:	f7 d9                	neg    %ecx
  8005a4:	83 d3 00             	adc    $0x0,%ebx
  8005a7:	f7 db                	neg    %ebx
  8005a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ae:	e9 83 00 00 00       	jmp    800636 <vprintfmt+0x377>
  8005b3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005b6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b9:	89 ca                	mov    %ecx,%edx
  8005bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005be:	e8 a5 fc ff ff       	call   800268 <getuint>
  8005c3:	89 c1                	mov    %eax,%ecx
  8005c5:	89 d3                	mov    %edx,%ebx
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8005cc:	eb 68                	jmp    800636 <vprintfmt+0x377>
  8005ce:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005d1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005d4:	89 ca                	mov    %ecx,%edx
  8005d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d9:	e8 8a fc ff ff       	call   800268 <getuint>
  8005de:	89 c1                	mov    %eax,%ecx
  8005e0:	89 d3                	mov    %edx,%ebx
  8005e2:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8005e7:	eb 4d                	jmp    800636 <vprintfmt+0x377>
  8005e9:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8005ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8005f7:	ff d7                	call   *%edi
			putch('x', putdat);
  8005f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800604:	ff d7                	call   *%edi
			num = (unsigned long long)
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 50 04             	lea    0x4(%eax),%edx
  80060c:	89 55 14             	mov    %edx,0x14(%ebp)
  80060f:	8b 08                	mov    (%eax),%ecx
  800611:	bb 00 00 00 00       	mov    $0x0,%ebx
  800616:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061b:	eb 19                	jmp    800636 <vprintfmt+0x377>
  80061d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800620:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800623:	89 ca                	mov    %ecx,%edx
  800625:	8d 45 14             	lea    0x14(%ebp),%eax
  800628:	e8 3b fc ff ff       	call   800268 <getuint>
  80062d:	89 c1                	mov    %eax,%ecx
  80062f:	89 d3                	mov    %edx,%ebx
  800631:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800636:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80063a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80063e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800641:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800645:	89 44 24 08          	mov    %eax,0x8(%esp)
  800649:	89 0c 24             	mov    %ecx,(%esp)
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	89 f2                	mov    %esi,%edx
  800652:	89 f8                	mov    %edi,%eax
  800654:	e8 27 fb ff ff       	call   800180 <printnum>
  800659:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80065c:	e9 8a fc ff ff       	jmp    8002eb <vprintfmt+0x2c>
  800661:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800664:	89 74 24 04          	mov    %esi,0x4(%esp)
  800668:	89 04 24             	mov    %eax,(%esp)
  80066b:	ff d7                	call   *%edi
  80066d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800670:	e9 76 fc ff ff       	jmp    8002eb <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800675:	89 74 24 04          	mov    %esi,0x4(%esp)
  800679:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800680:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800682:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800685:	80 38 25             	cmpb   $0x25,(%eax)
  800688:	0f 84 5d fc ff ff    	je     8002eb <vprintfmt+0x2c>
  80068e:	89 c3                	mov    %eax,%ebx
  800690:	eb f0                	jmp    800682 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800692:	83 c4 4c             	add    $0x4c,%esp
  800695:	5b                   	pop    %ebx
  800696:	5e                   	pop    %esi
  800697:	5f                   	pop    %edi
  800698:	5d                   	pop    %ebp
  800699:	c3                   	ret    

0080069a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	83 ec 28             	sub    $0x28,%esp
  8006a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	74 04                	je     8006ae <vsnprintf+0x14>
  8006aa:	85 d2                	test   %edx,%edx
  8006ac:	7f 07                	jg     8006b5 <vsnprintf+0x1b>
  8006ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b3:	eb 3b                	jmp    8006f0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8006bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006db:	c7 04 24 a2 02 80 00 	movl   $0x8002a2,(%esp)
  8006e2:	e8 d8 fb ff ff       	call   8002bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8006fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800702:	89 44 24 08          	mov    %eax,0x8(%esp)
  800706:	8b 45 0c             	mov    0xc(%ebp),%eax
  800709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	89 04 24             	mov    %eax,(%esp)
  800713:	e8 82 ff ff ff       	call   80069a <vsnprintf>
	va_end(ap);

	return rc;
}
  800718:	c9                   	leave  
  800719:	c3                   	ret    

0080071a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800720:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800723:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800727:	8b 45 10             	mov    0x10(%ebp),%eax
  80072a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800731:	89 44 24 04          	mov    %eax,0x4(%esp)
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	89 04 24             	mov    %eax,(%esp)
  80073b:	e8 7f fb ff ff       	call   8002bf <vprintfmt>
	va_end(ap);
}
  800740:	c9                   	leave  
  800741:	c3                   	ret    
	...

00800750 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  80075b:	eb 03                	jmp    800760 <strlen+0x10>
		n++;
  80075d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800760:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800764:	75 f7                	jne    80075d <strlen+0xd>
		n++;
	return n;
}
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	53                   	push   %ebx
  80076c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80076f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800772:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800777:	eb 03                	jmp    80077c <strnlen+0x14>
		n++;
  800779:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077c:	39 c1                	cmp    %eax,%ecx
  80077e:	74 06                	je     800786 <strnlen+0x1e>
  800780:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800784:	75 f3                	jne    800779 <strnlen+0x11>
		n++;
	return n;
}
  800786:	5b                   	pop    %ebx
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	53                   	push   %ebx
  80078d:	8b 45 08             	mov    0x8(%ebp),%eax
  800790:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800793:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800798:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80079c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80079f:	83 c2 01             	add    $0x1,%edx
  8007a2:	84 c9                	test   %cl,%cl
  8007a4:	75 f2                	jne    800798 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007a6:	5b                   	pop    %ebx
  8007a7:	5d                   	pop    %ebp
  8007a8:	c3                   	ret    

008007a9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	53                   	push   %ebx
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b3:	89 1c 24             	mov    %ebx,(%esp)
  8007b6:	e8 95 ff ff ff       	call   800750 <strlen>
	strcpy(dst + len, src);
  8007bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007c5:	89 04 24             	mov    %eax,(%esp)
  8007c8:	e8 bc ff ff ff       	call   800789 <strcpy>
	return dst;
}
  8007cd:	89 d8                	mov    %ebx,%eax
  8007cf:	83 c4 08             	add    $0x8,%esp
  8007d2:	5b                   	pop    %ebx
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	56                   	push   %esi
  8007d9:	53                   	push   %ebx
  8007da:	8b 45 08             	mov    0x8(%ebp),%eax
  8007dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e0:	8b 75 10             	mov    0x10(%ebp),%esi
  8007e3:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e8:	eb 0f                	jmp    8007f9 <strncpy+0x24>
		*dst++ = *src;
  8007ea:	0f b6 19             	movzbl (%ecx),%ebx
  8007ed:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f0:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	39 f2                	cmp    %esi,%edx
  8007fb:	72 ed                	jb     8007ea <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	56                   	push   %esi
  800805:	53                   	push   %ebx
  800806:	8b 75 08             	mov    0x8(%ebp),%esi
  800809:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080f:	89 f0                	mov    %esi,%eax
  800811:	85 d2                	test   %edx,%edx
  800813:	75 0a                	jne    80081f <strlcpy+0x1e>
  800815:	eb 17                	jmp    80082e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800817:	88 18                	mov    %bl,(%eax)
  800819:	83 c0 01             	add    $0x1,%eax
  80081c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80081f:	83 ea 01             	sub    $0x1,%edx
  800822:	74 07                	je     80082b <strlcpy+0x2a>
  800824:	0f b6 19             	movzbl (%ecx),%ebx
  800827:	84 db                	test   %bl,%bl
  800829:	75 ec                	jne    800817 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80082b:	c6 00 00             	movb   $0x0,(%eax)
  80082e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800830:	5b                   	pop    %ebx
  800831:	5e                   	pop    %esi
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083d:	eb 06                	jmp    800845 <strcmp+0x11>
		p++, q++;
  80083f:	83 c1 01             	add    $0x1,%ecx
  800842:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800845:	0f b6 01             	movzbl (%ecx),%eax
  800848:	84 c0                	test   %al,%al
  80084a:	74 04                	je     800850 <strcmp+0x1c>
  80084c:	3a 02                	cmp    (%edx),%al
  80084e:	74 ef                	je     80083f <strcmp+0xb>
  800850:	0f b6 c0             	movzbl %al,%eax
  800853:	0f b6 12             	movzbl (%edx),%edx
  800856:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800864:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800867:	eb 09                	jmp    800872 <strncmp+0x18>
		n--, p++, q++;
  800869:	83 ea 01             	sub    $0x1,%edx
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800872:	85 d2                	test   %edx,%edx
  800874:	75 07                	jne    80087d <strncmp+0x23>
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	eb 13                	jmp    800890 <strncmp+0x36>
  80087d:	0f b6 18             	movzbl (%eax),%ebx
  800880:	84 db                	test   %bl,%bl
  800882:	74 04                	je     800888 <strncmp+0x2e>
  800884:	3a 19                	cmp    (%ecx),%bl
  800886:	74 e1                	je     800869 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800888:	0f b6 00             	movzbl (%eax),%eax
  80088b:	0f b6 11             	movzbl (%ecx),%edx
  80088e:	29 d0                	sub    %edx,%eax
}
  800890:	5b                   	pop    %ebx
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089d:	eb 07                	jmp    8008a6 <strchr+0x13>
		if (*s == c)
  80089f:	38 ca                	cmp    %cl,%dl
  8008a1:	74 0f                	je     8008b2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a3:	83 c0 01             	add    $0x1,%eax
  8008a6:	0f b6 10             	movzbl (%eax),%edx
  8008a9:	84 d2                	test   %dl,%dl
  8008ab:	75 f2                	jne    80089f <strchr+0xc>
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008be:	eb 07                	jmp    8008c7 <strfind+0x13>
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 0a                	je     8008ce <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008c4:	83 c0 01             	add    $0x1,%eax
  8008c7:	0f b6 10             	movzbl (%eax),%edx
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	75 f2                	jne    8008c0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008ce:	5d                   	pop    %ebp
  8008cf:	90                   	nop
  8008d0:	c3                   	ret    

008008d1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 0c             	sub    $0xc,%esp
  8008d7:	89 1c 24             	mov    %ebx,(%esp)
  8008da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	74 30                	je     80091f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f5:	75 25                	jne    80091c <memset+0x4b>
  8008f7:	f6 c1 03             	test   $0x3,%cl
  8008fa:	75 20                	jne    80091c <memset+0x4b>
		c &= 0xFF;
  8008fc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ff:	89 d3                	mov    %edx,%ebx
  800901:	c1 e3 08             	shl    $0x8,%ebx
  800904:	89 d6                	mov    %edx,%esi
  800906:	c1 e6 18             	shl    $0x18,%esi
  800909:	89 d0                	mov    %edx,%eax
  80090b:	c1 e0 10             	shl    $0x10,%eax
  80090e:	09 f0                	or     %esi,%eax
  800910:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800912:	09 d8                	or     %ebx,%eax
  800914:	c1 e9 02             	shr    $0x2,%ecx
  800917:	fc                   	cld    
  800918:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091a:	eb 03                	jmp    80091f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091c:	fc                   	cld    
  80091d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091f:	89 f8                	mov    %edi,%eax
  800921:	8b 1c 24             	mov    (%esp),%ebx
  800924:	8b 74 24 04          	mov    0x4(%esp),%esi
  800928:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80092c:	89 ec                	mov    %ebp,%esp
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	83 ec 08             	sub    $0x8,%esp
  800936:	89 34 24             	mov    %esi,(%esp)
  800939:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800943:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800946:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800948:	39 c6                	cmp    %eax,%esi
  80094a:	73 35                	jae    800981 <memmove+0x51>
  80094c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094f:	39 d0                	cmp    %edx,%eax
  800951:	73 2e                	jae    800981 <memmove+0x51>
		s += n;
		d += n;
  800953:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800955:	f6 c2 03             	test   $0x3,%dl
  800958:	75 1b                	jne    800975 <memmove+0x45>
  80095a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800960:	75 13                	jne    800975 <memmove+0x45>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 0e                	jne    800975 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800967:	83 ef 04             	sub    $0x4,%edi
  80096a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80096d:	c1 e9 02             	shr    $0x2,%ecx
  800970:	fd                   	std    
  800971:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	eb 09                	jmp    80097e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800975:	83 ef 01             	sub    $0x1,%edi
  800978:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097b:	fd                   	std    
  80097c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80097e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097f:	eb 20                	jmp    8009a1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800981:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800987:	75 15                	jne    80099e <memmove+0x6e>
  800989:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80098f:	75 0d                	jne    80099e <memmove+0x6e>
  800991:	f6 c1 03             	test   $0x3,%cl
  800994:	75 08                	jne    80099e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800996:	c1 e9 02             	shr    $0x2,%ecx
  800999:	fc                   	cld    
  80099a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	eb 03                	jmp    8009a1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099e:	fc                   	cld    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a1:	8b 34 24             	mov    (%esp),%esi
  8009a4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009a8:	89 ec                	mov    %ebp,%esp
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	89 04 24             	mov    %eax,(%esp)
  8009c6:	e8 65 ff ff ff       	call   800930 <memmove>
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	57                   	push   %edi
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009dc:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e1:	eb 1c                	jmp    8009ff <memcmp+0x32>
		if (*s1 != *s2)
  8009e3:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  8009e7:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  8009eb:	83 c2 01             	add    $0x1,%edx
  8009ee:	83 e9 01             	sub    $0x1,%ecx
  8009f1:	38 d8                	cmp    %bl,%al
  8009f3:	74 0a                	je     8009ff <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  8009f5:	0f b6 c0             	movzbl %al,%eax
  8009f8:	0f b6 db             	movzbl %bl,%ebx
  8009fb:	29 d8                	sub    %ebx,%eax
  8009fd:	eb 09                	jmp    800a08 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ff:	85 c9                	test   %ecx,%ecx
  800a01:	75 e0                	jne    8009e3 <memcmp+0x16>
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a08:	5b                   	pop    %ebx
  800a09:	5e                   	pop    %esi
  800a0a:	5f                   	pop    %edi
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a16:	89 c2                	mov    %eax,%edx
  800a18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a1b:	eb 07                	jmp    800a24 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1d:	38 08                	cmp    %cl,(%eax)
  800a1f:	74 07                	je     800a28 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	72 f5                	jb     800a1d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	83 ec 04             	sub    $0x4,%esp
  800a33:	8b 55 08             	mov    0x8(%ebp),%edx
  800a36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a39:	eb 03                	jmp    800a3e <strtol+0x14>
		s++;
  800a3b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a3e:	0f b6 02             	movzbl (%edx),%eax
  800a41:	3c 20                	cmp    $0x20,%al
  800a43:	74 f6                	je     800a3b <strtol+0x11>
  800a45:	3c 09                	cmp    $0x9,%al
  800a47:	74 f2                	je     800a3b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a49:	3c 2b                	cmp    $0x2b,%al
  800a4b:	75 0c                	jne    800a59 <strtol+0x2f>
		s++;
  800a4d:	8d 52 01             	lea    0x1(%edx),%edx
  800a50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a57:	eb 15                	jmp    800a6e <strtol+0x44>
	else if (*s == '-')
  800a59:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a60:	3c 2d                	cmp    $0x2d,%al
  800a62:	75 0a                	jne    800a6e <strtol+0x44>
		s++, neg = 1;
  800a64:	8d 52 01             	lea    0x1(%edx),%edx
  800a67:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6e:	85 db                	test   %ebx,%ebx
  800a70:	0f 94 c0             	sete   %al
  800a73:	74 05                	je     800a7a <strtol+0x50>
  800a75:	83 fb 10             	cmp    $0x10,%ebx
  800a78:	75 18                	jne    800a92 <strtol+0x68>
  800a7a:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7d:	75 13                	jne    800a92 <strtol+0x68>
  800a7f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a83:	75 0d                	jne    800a92 <strtol+0x68>
		s += 2, base = 16;
  800a85:	83 c2 02             	add    $0x2,%edx
  800a88:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8d:	8d 76 00             	lea    0x0(%esi),%esi
  800a90:	eb 13                	jmp    800aa5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a92:	84 c0                	test   %al,%al
  800a94:	74 0f                	je     800aa5 <strtol+0x7b>
  800a96:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a9b:	80 3a 30             	cmpb   $0x30,(%edx)
  800a9e:	75 05                	jne    800aa5 <strtol+0x7b>
		s++, base = 8;
  800aa0:	83 c2 01             	add    $0x1,%edx
  800aa3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aac:	0f b6 0a             	movzbl (%edx),%ecx
  800aaf:	89 cf                	mov    %ecx,%edi
  800ab1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ab4:	80 fb 09             	cmp    $0x9,%bl
  800ab7:	77 08                	ja     800ac1 <strtol+0x97>
			dig = *s - '0';
  800ab9:	0f be c9             	movsbl %cl,%ecx
  800abc:	83 e9 30             	sub    $0x30,%ecx
  800abf:	eb 1e                	jmp    800adf <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800ac1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ac4:	80 fb 19             	cmp    $0x19,%bl
  800ac7:	77 08                	ja     800ad1 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800ac9:	0f be c9             	movsbl %cl,%ecx
  800acc:	83 e9 57             	sub    $0x57,%ecx
  800acf:	eb 0e                	jmp    800adf <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ad1:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ad4:	80 fb 19             	cmp    $0x19,%bl
  800ad7:	77 15                	ja     800aee <strtol+0xc4>
			dig = *s - 'A' + 10;
  800ad9:	0f be c9             	movsbl %cl,%ecx
  800adc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800adf:	39 f1                	cmp    %esi,%ecx
  800ae1:	7d 0b                	jge    800aee <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800ae3:	83 c2 01             	add    $0x1,%edx
  800ae6:	0f af c6             	imul   %esi,%eax
  800ae9:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800aec:	eb be                	jmp    800aac <strtol+0x82>
  800aee:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800af0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af4:	74 05                	je     800afb <strtol+0xd1>
		*endptr = (char *) s;
  800af6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800afb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800aff:	74 04                	je     800b05 <strtol+0xdb>
  800b01:	89 c8                	mov    %ecx,%eax
  800b03:	f7 d8                	neg    %eax
}
  800b05:	83 c4 04             	add    $0x4,%esp
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    
  800b0d:	00 00                	add    %al,(%eax)
	...

00800b10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	83 ec 0c             	sub    $0xc,%esp
  800b16:	89 1c 24             	mov    %ebx,(%esp)
  800b19:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b1d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	89 c7                	mov    %eax,%edi
  800b30:	89 c6                	mov    %eax,%esi
  800b32:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b34:	8b 1c 24             	mov    (%esp),%ebx
  800b37:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b3b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b3f:	89 ec                	mov    %ebp,%esp
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 38             	sub    $0x38,%esp
  800b49:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b4c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b4f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800b52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b56:	75 0c                	jne    800b64 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800b58:	c7 04 24 08 14 80 00 	movl   $0x801408,(%esp)
  800b5f:	e8 b5 f5 ff ff       	call   800119 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b69:	b8 09 00 00 00       	mov    $0x9,%eax
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b74:	89 df                	mov    %ebx,%edi
  800b76:	89 de                	mov    %ebx,%esi
  800b78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 28                	jle    800ba6 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b82:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800b89:	00 
  800b8a:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800b91:	00 
  800b92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b99:	00 
  800b9a:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800ba1:	e8 16 03 00 00       	call   800ebc <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ba6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ba9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800baf:	89 ec                	mov    %ebp,%esp
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 38             	sub    $0x38,%esp
  800bb9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bbc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bbf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	89 cb                	mov    %ecx,%ebx
  800bd1:	89 cf                	mov    %ecx,%edi
  800bd3:	89 ce                	mov    %ecx,%esi
  800bd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 28                	jle    800c03 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bdf:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800be6:	00 
  800be7:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800bee:	00 
  800bef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf6:	00 
  800bf7:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800bfe:	e8 b9 02 00 00       	call   800ebc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c03:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c06:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c0c:	89 ec                	mov    %ebp,%esp
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	89 1c 24             	mov    %ebx,(%esp)
  800c19:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c1d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	be 00 00 00 00       	mov    $0x0,%esi
  800c26:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c39:	8b 1c 24             	mov    (%esp),%ebx
  800c3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c40:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c44:	89 ec                	mov    %ebp,%esp
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    

00800c48 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 38             	sub    $0x38,%esp
  800c4e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c51:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c54:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	89 df                	mov    %ebx,%edi
  800c69:	89 de                	mov    %ebx,%esi
  800c6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	7e 28                	jle    800c99 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c75:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800c84:	00 
  800c85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c8c:	00 
  800c8d:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800c94:	e8 23 02 00 00       	call   800ebc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c99:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c9c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c9f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ca2:	89 ec                	mov    %ebp,%esp
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    

00800ca6 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 38             	sub    $0x38,%esp
  800cac:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800caf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cb2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	b8 06 00 00 00       	mov    $0x6,%eax
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	89 df                	mov    %ebx,%edi
  800cc7:	89 de                	mov    %ebx,%esi
  800cc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 28                	jle    800cf7 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cda:	00 
  800cdb:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800ce2:	00 
  800ce3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cea:	00 
  800ceb:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800cf2:	e8 c5 01 00 00       	call   800ebc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cfa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cfd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d00:	89 ec                	mov    %ebp,%esp
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 38             	sub    $0x38,%esp
  800d0a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d0d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d10:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	b8 05 00 00 00       	mov    $0x5,%eax
  800d18:	8b 75 18             	mov    0x18(%ebp),%esi
  800d1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 28                	jle    800d55 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d31:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d38:	00 
  800d39:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800d40:	00 
  800d41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d48:	00 
  800d49:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800d50:	e8 67 01 00 00       	call   800ebc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d55:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d58:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d5b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d5e:	89 ec                	mov    %ebp,%esp
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    

00800d62 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	83 ec 38             	sub    $0x38,%esp
  800d68:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d6b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	be 00 00 00 00       	mov    $0x0,%esi
  800d76:	b8 04 00 00 00       	mov    $0x4,%eax
  800d7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	89 f7                	mov    %esi,%edi
  800d86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	7e 28                	jle    800db4 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d90:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d97:	00 
  800d98:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800d9f:	00 
  800da0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da7:	00 
  800da8:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800daf:	e8 08 01 00 00       	call   800ebc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbd:	89 ec                	mov    %ebp,%esp
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	89 1c 24             	mov    %ebx,(%esp)
  800dca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dce:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ddc:	89 d1                	mov    %edx,%ecx
  800dde:	89 d3                	mov    %edx,%ebx
  800de0:	89 d7                	mov    %edx,%edi
  800de2:	89 d6                	mov    %edx,%esi
  800de4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800de6:	8b 1c 24             	mov    (%esp),%ebx
  800de9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ded:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800df1:	89 ec                	mov    %ebp,%esp
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	89 1c 24             	mov    %ebx,(%esp)
  800dfe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e02:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e10:	89 d1                	mov    %edx,%ecx
  800e12:	89 d3                	mov    %edx,%ebx
  800e14:	89 d7                	mov    %edx,%edi
  800e16:	89 d6                	mov    %edx,%esi
  800e18:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e1a:	8b 1c 24             	mov    (%esp),%ebx
  800e1d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e21:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e25:	89 ec                	mov    %ebp,%esp
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 38             	sub    $0x38,%esp
  800e2f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e32:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e35:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	89 cb                	mov    %ecx,%ebx
  800e47:	89 cf                	mov    %ecx,%edi
  800e49:	89 ce                	mov    %ecx,%esi
  800e4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7e 28                	jle    800e79 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e55:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800e64:	00 
  800e65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6c:	00 
  800e6d:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800e74:	e8 43 00 00 00       	call   800ebc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e79:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e82:	89 ec                	mov    %ebp,%esp
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	89 1c 24             	mov    %ebx,(%esp)
  800e8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e93:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e97:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea1:	89 d1                	mov    %edx,%ecx
  800ea3:	89 d3                	mov    %edx,%ebx
  800ea5:	89 d7                	mov    %edx,%edi
  800ea7:	89 d6                	mov    %edx,%esi
  800ea9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eab:	8b 1c 24             	mov    (%esp),%ebx
  800eae:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eb2:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800eb6:	89 ec                	mov    %ebp,%esp
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    
	...

00800ebc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800ec4:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ec7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ecd:	e8 23 ff ff ff       	call   800df5 <sys_getenvid>
  800ed2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ee0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ee4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee8:	c7 04 24 60 14 80 00 	movl   $0x801460,(%esp)
  800eef:	e8 25 f2 ff ff       	call   800119 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ef4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef8:	8b 45 10             	mov    0x10(%ebp),%eax
  800efb:	89 04 24             	mov    %eax,(%esp)
  800efe:	e8 b5 f1 ff ff       	call   8000b8 <vcprintf>
	cprintf("\n");
  800f03:	c7 04 24 bc 11 80 00 	movl   $0x8011bc,(%esp)
  800f0a:	e8 0a f2 ff ff       	call   800119 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f0f:	cc                   	int3   
  800f10:	eb fd                	jmp    800f0f <_panic+0x53>
	...

00800f20 <__udivdi3>:
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	83 ec 10             	sub    $0x10,%esp
  800f28:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2e:	8b 75 10             	mov    0x10(%ebp),%esi
  800f31:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f34:	85 c0                	test   %eax,%eax
  800f36:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f39:	75 35                	jne    800f70 <__udivdi3+0x50>
  800f3b:	39 fe                	cmp    %edi,%esi
  800f3d:	77 61                	ja     800fa0 <__udivdi3+0x80>
  800f3f:	85 f6                	test   %esi,%esi
  800f41:	75 0b                	jne    800f4e <__udivdi3+0x2e>
  800f43:	b8 01 00 00 00       	mov    $0x1,%eax
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	f7 f6                	div    %esi
  800f4c:	89 c6                	mov    %eax,%esi
  800f4e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800f51:	31 d2                	xor    %edx,%edx
  800f53:	89 f8                	mov    %edi,%eax
  800f55:	f7 f6                	div    %esi
  800f57:	89 c7                	mov    %eax,%edi
  800f59:	89 c8                	mov    %ecx,%eax
  800f5b:	f7 f6                	div    %esi
  800f5d:	89 c1                	mov    %eax,%ecx
  800f5f:	89 fa                	mov    %edi,%edx
  800f61:	89 c8                	mov    %ecx,%eax
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	5e                   	pop    %esi
  800f67:	5f                   	pop    %edi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    
  800f6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f70:	39 f8                	cmp    %edi,%eax
  800f72:	77 1c                	ja     800f90 <__udivdi3+0x70>
  800f74:	0f bd d0             	bsr    %eax,%edx
  800f77:	83 f2 1f             	xor    $0x1f,%edx
  800f7a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800f7d:	75 39                	jne    800fb8 <__udivdi3+0x98>
  800f7f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800f82:	0f 86 a0 00 00 00    	jbe    801028 <__udivdi3+0x108>
  800f88:	39 f8                	cmp    %edi,%eax
  800f8a:	0f 82 98 00 00 00    	jb     801028 <__udivdi3+0x108>
  800f90:	31 ff                	xor    %edi,%edi
  800f92:	31 c9                	xor    %ecx,%ecx
  800f94:	89 c8                	mov    %ecx,%eax
  800f96:	89 fa                	mov    %edi,%edx
  800f98:	83 c4 10             	add    $0x10,%esp
  800f9b:	5e                   	pop    %esi
  800f9c:	5f                   	pop    %edi
  800f9d:	5d                   	pop    %ebp
  800f9e:	c3                   	ret    
  800f9f:	90                   	nop
  800fa0:	89 d1                	mov    %edx,%ecx
  800fa2:	89 fa                	mov    %edi,%edx
  800fa4:	89 c8                	mov    %ecx,%eax
  800fa6:	31 ff                	xor    %edi,%edi
  800fa8:	f7 f6                	div    %esi
  800faa:	89 c1                	mov    %eax,%ecx
  800fac:	89 fa                	mov    %edi,%edx
  800fae:	89 c8                	mov    %ecx,%eax
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	5e                   	pop    %esi
  800fb4:	5f                   	pop    %edi
  800fb5:	5d                   	pop    %ebp
  800fb6:	c3                   	ret    
  800fb7:	90                   	nop
  800fb8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fbc:	89 f2                	mov    %esi,%edx
  800fbe:	d3 e0                	shl    %cl,%eax
  800fc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fc3:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  800fcb:	89 c1                	mov    %eax,%ecx
  800fcd:	d3 ea                	shr    %cl,%edx
  800fcf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fd3:	0b 55 ec             	or     -0x14(%ebp),%edx
  800fd6:	d3 e6                	shl    %cl,%esi
  800fd8:	89 c1                	mov    %eax,%ecx
  800fda:	89 75 e8             	mov    %esi,-0x18(%ebp)
  800fdd:	89 fe                	mov    %edi,%esi
  800fdf:	d3 ee                	shr    %cl,%esi
  800fe1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  800fe5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  800fe8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800feb:	d3 e7                	shl    %cl,%edi
  800fed:	89 c1                	mov    %eax,%ecx
  800fef:	d3 ea                	shr    %cl,%edx
  800ff1:	09 d7                	or     %edx,%edi
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	89 f8                	mov    %edi,%eax
  800ff7:	f7 75 ec             	divl   -0x14(%ebp)
  800ffa:	89 d6                	mov    %edx,%esi
  800ffc:	89 c7                	mov    %eax,%edi
  800ffe:	f7 65 e8             	mull   -0x18(%ebp)
  801001:	39 d6                	cmp    %edx,%esi
  801003:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801006:	72 30                	jb     801038 <__udivdi3+0x118>
  801008:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80100b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80100f:	d3 e2                	shl    %cl,%edx
  801011:	39 c2                	cmp    %eax,%edx
  801013:	73 05                	jae    80101a <__udivdi3+0xfa>
  801015:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801018:	74 1e                	je     801038 <__udivdi3+0x118>
  80101a:	89 f9                	mov    %edi,%ecx
  80101c:	31 ff                	xor    %edi,%edi
  80101e:	e9 71 ff ff ff       	jmp    800f94 <__udivdi3+0x74>
  801023:	90                   	nop
  801024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801028:	31 ff                	xor    %edi,%edi
  80102a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80102f:	e9 60 ff ff ff       	jmp    800f94 <__udivdi3+0x74>
  801034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801038:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80103b:	31 ff                	xor    %edi,%edi
  80103d:	89 c8                	mov    %ecx,%eax
  80103f:	89 fa                	mov    %edi,%edx
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    
	...

00801050 <__umoddi3>:
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	83 ec 20             	sub    $0x20,%esp
  801058:	8b 55 14             	mov    0x14(%ebp),%edx
  80105b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801061:	8b 75 0c             	mov    0xc(%ebp),%esi
  801064:	85 d2                	test   %edx,%edx
  801066:	89 c8                	mov    %ecx,%eax
  801068:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80106b:	75 13                	jne    801080 <__umoddi3+0x30>
  80106d:	39 f7                	cmp    %esi,%edi
  80106f:	76 3f                	jbe    8010b0 <__umoddi3+0x60>
  801071:	89 f2                	mov    %esi,%edx
  801073:	f7 f7                	div    %edi
  801075:	89 d0                	mov    %edx,%eax
  801077:	31 d2                	xor    %edx,%edx
  801079:	83 c4 20             	add    $0x20,%esp
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    
  801080:	39 f2                	cmp    %esi,%edx
  801082:	77 4c                	ja     8010d0 <__umoddi3+0x80>
  801084:	0f bd ca             	bsr    %edx,%ecx
  801087:	83 f1 1f             	xor    $0x1f,%ecx
  80108a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80108d:	75 51                	jne    8010e0 <__umoddi3+0x90>
  80108f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801092:	0f 87 e0 00 00 00    	ja     801178 <__umoddi3+0x128>
  801098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109b:	29 f8                	sub    %edi,%eax
  80109d:	19 d6                	sbb    %edx,%esi
  80109f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a5:	89 f2                	mov    %esi,%edx
  8010a7:	83 c4 20             	add    $0x20,%esp
  8010aa:	5e                   	pop    %esi
  8010ab:	5f                   	pop    %edi
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    
  8010ae:	66 90                	xchg   %ax,%ax
  8010b0:	85 ff                	test   %edi,%edi
  8010b2:	75 0b                	jne    8010bf <__umoddi3+0x6f>
  8010b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8010b9:	31 d2                	xor    %edx,%edx
  8010bb:	f7 f7                	div    %edi
  8010bd:	89 c7                	mov    %eax,%edi
  8010bf:	89 f0                	mov    %esi,%eax
  8010c1:	31 d2                	xor    %edx,%edx
  8010c3:	f7 f7                	div    %edi
  8010c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010c8:	f7 f7                	div    %edi
  8010ca:	eb a9                	jmp    801075 <__umoddi3+0x25>
  8010cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010d0:	89 c8                	mov    %ecx,%eax
  8010d2:	89 f2                	mov    %esi,%edx
  8010d4:	83 c4 20             	add    $0x20,%esp
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    
  8010db:	90                   	nop
  8010dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8010e4:	d3 e2                	shl    %cl,%edx
  8010e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8010ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8010f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8010f8:	89 fa                	mov    %edi,%edx
  8010fa:	d3 ea                	shr    %cl,%edx
  8010fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801100:	0b 55 f4             	or     -0xc(%ebp),%edx
  801103:	d3 e7                	shl    %cl,%edi
  801105:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801109:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80110c:	89 f2                	mov    %esi,%edx
  80110e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801111:	89 c7                	mov    %eax,%edi
  801113:	d3 ea                	shr    %cl,%edx
  801115:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801119:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80111c:	89 c2                	mov    %eax,%edx
  80111e:	d3 e6                	shl    %cl,%esi
  801120:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801124:	d3 ea                	shr    %cl,%edx
  801126:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80112a:	09 d6                	or     %edx,%esi
  80112c:	89 f0                	mov    %esi,%eax
  80112e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801131:	d3 e7                	shl    %cl,%edi
  801133:	89 f2                	mov    %esi,%edx
  801135:	f7 75 f4             	divl   -0xc(%ebp)
  801138:	89 d6                	mov    %edx,%esi
  80113a:	f7 65 e8             	mull   -0x18(%ebp)
  80113d:	39 d6                	cmp    %edx,%esi
  80113f:	72 2b                	jb     80116c <__umoddi3+0x11c>
  801141:	39 c7                	cmp    %eax,%edi
  801143:	72 23                	jb     801168 <__umoddi3+0x118>
  801145:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801149:	29 c7                	sub    %eax,%edi
  80114b:	19 d6                	sbb    %edx,%esi
  80114d:	89 f0                	mov    %esi,%eax
  80114f:	89 f2                	mov    %esi,%edx
  801151:	d3 ef                	shr    %cl,%edi
  801153:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801157:	d3 e0                	shl    %cl,%eax
  801159:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80115d:	09 f8                	or     %edi,%eax
  80115f:	d3 ea                	shr    %cl,%edx
  801161:	83 c4 20             	add    $0x20,%esp
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    
  801168:	39 d6                	cmp    %edx,%esi
  80116a:	75 d9                	jne    801145 <__umoddi3+0xf5>
  80116c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80116f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801172:	eb d1                	jmp    801145 <__umoddi3+0xf5>
  801174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801178:	39 f2                	cmp    %esi,%edx
  80117a:	0f 82 18 ff ff ff    	jb     801098 <__umoddi3+0x48>
  801180:	e9 1d ff ff ff       	jmp    8010a2 <__umoddi3+0x52>
