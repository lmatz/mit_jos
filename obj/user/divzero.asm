
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	ba 01 00 00 00       	mov    $0x1,%edx
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 d0                	mov    %edx,%eax
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 a0 11 80 00 	movl   $0x8011a0,(%esp)
  800060:	e8 c8 00 00 00       	call   80012d <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800071:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800074:	8b 75 08             	mov    0x8(%ebp),%esi
  800077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  80007a:	e8 86 0d 00 00       	call   800e05 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 f6                	test   %esi,%esi
  800093:	7e 07                	jle    80009c <libmain+0x34>
		binaryname = argv[0];
  800095:	8b 03                	mov    (%ebx),%eax
  800097:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80009c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a0:	89 34 24             	mov    %esi,(%esp)
  8000a3:	e8 8c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b3:	89 ec                	mov    %ebp,%esp
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c5:	e8 6f 0d 00 00       	call   800e39 <sys_env_destroy>
}
  8000ca:	c9                   	leave  
  8000cb:	c3                   	ret    

008000cc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000dc:	00 00 00 
	b.cnt = 0;
  8000df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 47 01 80 00 	movl   $0x800147,(%esp)
  800108:	e8 c2 01 00 00       	call   8002cf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800113:	89 44 24 04          	mov    %eax,0x4(%esp)
  800117:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 fb 09 00 00       	call   800b20 <sys_cputs>

	return b.cnt;
}
  800125:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800133:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013a:	8b 45 08             	mov    0x8(%ebp),%eax
  80013d:	89 04 24             	mov    %eax,(%esp)
  800140:	e8 87 ff ff ff       	call   8000cc <vcprintf>
	va_end(ap);

	return cnt;
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	53                   	push   %ebx
  80014b:	83 ec 14             	sub    $0x14,%esp
  80014e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800151:	8b 03                	mov    (%ebx),%eax
  800153:	8b 55 08             	mov    0x8(%ebp),%edx
  800156:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80015a:	83 c0 01             	add    $0x1,%eax
  80015d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80015f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800164:	75 19                	jne    80017f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800166:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80016d:	00 
  80016e:	8d 43 08             	lea    0x8(%ebx),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 a7 09 00 00       	call   800b20 <sys_cputs>
		b->idx = 0;
  800179:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80017f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800183:	83 c4 14             	add    $0x14,%esp
  800186:	5b                   	pop    %ebx
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
  80018b:	00 00                	add    %al,(%eax)
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 07                	jb     8001c6 <printnum+0x36>
  8001bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c2:	39 d0                	cmp    %edx,%eax
  8001c4:	77 69                	ja     80022f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001ca:	83 eb 01             	sub    $0x1,%ebx
  8001cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001d9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001dd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001e0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001e3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f1:	00 
  8001f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001f5:	89 04 24             	mov    %eax,(%esp)
  8001f8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001fb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001ff:	e8 2c 0d 00 00       	call   800f30 <__udivdi3>
  800204:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800207:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80020a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800212:	89 04 24             	mov    %eax,(%esp)
  800215:	89 54 24 04          	mov    %edx,0x4(%esp)
  800219:	89 f2                	mov    %esi,%edx
  80021b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021e:	e8 6d ff ff ff       	call   800190 <printnum>
  800223:	eb 11                	jmp    800236 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800225:	89 74 24 04          	mov    %esi,0x4(%esp)
  800229:	89 3c 24             	mov    %edi,(%esp)
  80022c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ef                	jg     800225 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80023a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80023e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800241:	89 44 24 08          	mov    %eax,0x8(%esp)
  800245:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024c:	00 
  80024d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800250:	89 14 24             	mov    %edx,(%esp)
  800253:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800256:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80025a:	e8 01 0e 00 00       	call   801060 <__umoddi3>
  80025f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800263:	0f be 80 b8 11 80 00 	movsbl 0x8011b8(%eax),%eax
  80026a:	89 04 24             	mov    %eax,(%esp)
  80026d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800270:	83 c4 4c             	add    $0x4c,%esp
  800273:	5b                   	pop    %ebx
  800274:	5e                   	pop    %esi
  800275:	5f                   	pop    %edi
  800276:	5d                   	pop    %ebp
  800277:	c3                   	ret    

00800278 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80027b:	83 fa 01             	cmp    $0x1,%edx
  80027e:	7e 0e                	jle    80028e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800280:	8b 10                	mov    (%eax),%edx
  800282:	8d 4a 08             	lea    0x8(%edx),%ecx
  800285:	89 08                	mov    %ecx,(%eax)
  800287:	8b 02                	mov    (%edx),%eax
  800289:	8b 52 04             	mov    0x4(%edx),%edx
  80028c:	eb 22                	jmp    8002b0 <getuint+0x38>
	else if (lflag)
  80028e:	85 d2                	test   %edx,%edx
  800290:	74 10                	je     8002a2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800292:	8b 10                	mov    (%eax),%edx
  800294:	8d 4a 04             	lea    0x4(%edx),%ecx
  800297:	89 08                	mov    %ecx,(%eax)
  800299:	8b 02                	mov    (%edx),%eax
  80029b:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a0:	eb 0e                	jmp    8002b0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a7:	89 08                	mov    %ecx,(%eax)
  8002a9:	8b 02                	mov    (%edx),%eax
  8002ab:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bc:	8b 10                	mov    (%eax),%edx
  8002be:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c1:	73 0a                	jae    8002cd <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c6:	88 0a                	mov    %cl,(%edx)
  8002c8:	83 c2 01             	add    $0x1,%edx
  8002cb:	89 10                	mov    %edx,(%eax)
}
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    

008002cf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 4c             	sub    $0x4c,%esp
  8002d8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002de:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002e1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002e8:	eb 11                	jmp    8002fb <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	0f 84 b0 03 00 00    	je     8006a2 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  8002f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f6:	89 04 24             	mov    %eax,(%esp)
  8002f9:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002fb:	0f b6 03             	movzbl (%ebx),%eax
  8002fe:	83 c3 01             	add    $0x1,%ebx
  800301:	83 f8 25             	cmp    $0x25,%eax
  800304:	75 e4                	jne    8002ea <vprintfmt+0x1b>
  800306:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80030d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800312:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800316:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80031d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800324:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800327:	eb 06                	jmp    80032f <vprintfmt+0x60>
  800329:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80032d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	0f b6 0b             	movzbl (%ebx),%ecx
  800332:	0f b6 c1             	movzbl %cl,%eax
  800335:	8d 53 01             	lea    0x1(%ebx),%edx
  800338:	83 e9 23             	sub    $0x23,%ecx
  80033b:	80 f9 55             	cmp    $0x55,%cl
  80033e:	0f 87 41 03 00 00    	ja     800685 <vprintfmt+0x3b6>
  800344:	0f b6 c9             	movzbl %cl,%ecx
  800347:	ff 24 8d 80 12 80 00 	jmp    *0x801280(,%ecx,4)
  80034e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800352:	eb d9                	jmp    80032d <vprintfmt+0x5e>
  800354:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80035b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800360:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800363:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800367:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80036a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80036d:	83 fb 09             	cmp    $0x9,%ebx
  800370:	77 2b                	ja     80039d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800372:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800375:	eb e9                	jmp    800360 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8d 48 04             	lea    0x4(%eax),%ecx
  80037d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800380:	8b 00                	mov    (%eax),%eax
  800382:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800385:	eb 19                	jmp    8003a0 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800387:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80038a:	c1 f8 1f             	sar    $0x1f,%eax
  80038d:	f7 d0                	not    %eax
  80038f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800392:	eb 99                	jmp    80032d <vprintfmt+0x5e>
  800394:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80039b:	eb 90                	jmp    80032d <vprintfmt+0x5e>
  80039d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  8003a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003a4:	79 87                	jns    80032d <vprintfmt+0x5e>
  8003a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ac:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003af:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003b2:	e9 76 ff ff ff       	jmp    80032d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003bb:	e9 6d ff ff ff       	jmp    80032d <vprintfmt+0x5e>
  8003c0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c6:	8d 50 04             	lea    0x4(%eax),%edx
  8003c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d0:	8b 00                	mov    (%eax),%eax
  8003d2:	89 04 24             	mov    %eax,(%esp)
  8003d5:	ff d7                	call   *%edi
  8003d7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8003da:	e9 1c ff ff ff       	jmp    8002fb <vprintfmt+0x2c>
  8003df:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e5:	8d 50 04             	lea    0x4(%eax),%edx
  8003e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	89 c2                	mov    %eax,%edx
  8003ef:	c1 fa 1f             	sar    $0x1f,%edx
  8003f2:	31 d0                	xor    %edx,%eax
  8003f4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f6:	83 f8 09             	cmp    $0x9,%eax
  8003f9:	7f 0b                	jg     800406 <vprintfmt+0x137>
  8003fb:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  800402:	85 d2                	test   %edx,%edx
  800404:	75 20                	jne    800426 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800406:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80040a:	c7 44 24 08 c9 11 80 	movl   $0x8011c9,0x8(%esp)
  800411:	00 
  800412:	89 74 24 04          	mov    %esi,0x4(%esp)
  800416:	89 3c 24             	mov    %edi,(%esp)
  800419:	e8 0c 03 00 00       	call   80072a <printfmt>
  80041e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800421:	e9 d5 fe ff ff       	jmp    8002fb <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800426:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80042a:	c7 44 24 08 d2 11 80 	movl   $0x8011d2,0x8(%esp)
  800431:	00 
  800432:	89 74 24 04          	mov    %esi,0x4(%esp)
  800436:	89 3c 24             	mov    %edi,(%esp)
  800439:	e8 ec 02 00 00       	call   80072a <printfmt>
  80043e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800441:	e9 b5 fe ff ff       	jmp    8002fb <vprintfmt+0x2c>
  800446:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800449:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80044c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80044f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800452:	8b 45 14             	mov    0x14(%ebp),%eax
  800455:	8d 50 04             	lea    0x4(%eax),%edx
  800458:	89 55 14             	mov    %edx,0x14(%ebp)
  80045b:	8b 18                	mov    (%eax),%ebx
  80045d:	85 db                	test   %ebx,%ebx
  80045f:	75 05                	jne    800466 <vprintfmt+0x197>
  800461:	bb d5 11 80 00       	mov    $0x8011d5,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800466:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046a:	7e 76                	jle    8004e2 <vprintfmt+0x213>
  80046c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800470:	74 7a                	je     8004ec <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800472:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800476:	89 1c 24             	mov    %ebx,(%esp)
  800479:	e8 fa 02 00 00       	call   800778 <strnlen>
  80047e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800481:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800483:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800487:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80048a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80048d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80048f:	eb 0f                	jmp    8004a0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800491:	89 74 24 04          	mov    %esi,0x4(%esp)
  800495:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800498:	89 04 24             	mov    %eax,(%esp)
  80049b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049d:	83 eb 01             	sub    $0x1,%ebx
  8004a0:	85 db                	test   %ebx,%ebx
  8004a2:	7f ed                	jg     800491 <vprintfmt+0x1c2>
  8004a4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004a7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004aa:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004ad:	89 f7                	mov    %esi,%edi
  8004af:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004b2:	eb 40                	jmp    8004f4 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b8:	74 18                	je     8004d2 <vprintfmt+0x203>
  8004ba:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004bd:	83 fa 5e             	cmp    $0x5e,%edx
  8004c0:	76 10                	jbe    8004d2 <vprintfmt+0x203>
					putch('?', putdat);
  8004c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004c6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004cd:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004d0:	eb 0a                	jmp    8004dc <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8004d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004d6:	89 04 24             	mov    %eax,(%esp)
  8004d9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8004e0:	eb 12                	jmp    8004f4 <vprintfmt+0x225>
  8004e2:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004e5:	89 f7                	mov    %esi,%edi
  8004e7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004ea:	eb 08                	jmp    8004f4 <vprintfmt+0x225>
  8004ec:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004ef:	89 f7                	mov    %esi,%edi
  8004f1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004f4:	0f be 03             	movsbl (%ebx),%eax
  8004f7:	83 c3 01             	add    $0x1,%ebx
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	74 25                	je     800523 <vprintfmt+0x254>
  8004fe:	85 f6                	test   %esi,%esi
  800500:	78 b2                	js     8004b4 <vprintfmt+0x1e5>
  800502:	83 ee 01             	sub    $0x1,%esi
  800505:	79 ad                	jns    8004b4 <vprintfmt+0x1e5>
  800507:	89 fe                	mov    %edi,%esi
  800509:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80050c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80050f:	eb 1a                	jmp    80052b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800511:	89 74 24 04          	mov    %esi,0x4(%esp)
  800515:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80051c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80051e:	83 eb 01             	sub    $0x1,%ebx
  800521:	eb 08                	jmp    80052b <vprintfmt+0x25c>
  800523:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800526:	89 fe                	mov    %edi,%esi
  800528:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80052b:	85 db                	test   %ebx,%ebx
  80052d:	7f e2                	jg     800511 <vprintfmt+0x242>
  80052f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800532:	e9 c4 fd ff ff       	jmp    8002fb <vprintfmt+0x2c>
  800537:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80053a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053d:	83 f9 01             	cmp    $0x1,%ecx
  800540:	7e 16                	jle    800558 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 08             	lea    0x8(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 10                	mov    (%eax),%edx
  80054d:	8b 48 04             	mov    0x4(%eax),%ecx
  800550:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800553:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800556:	eb 32                	jmp    80058a <vprintfmt+0x2bb>
	else if (lflag)
  800558:	85 c9                	test   %ecx,%ecx
  80055a:	74 18                	je     800574 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8d 50 04             	lea    0x4(%eax),%edx
  800562:	89 55 14             	mov    %edx,0x14(%ebp)
  800565:	8b 00                	mov    (%eax),%eax
  800567:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056a:	89 c1                	mov    %eax,%ecx
  80056c:	c1 f9 1f             	sar    $0x1f,%ecx
  80056f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800572:	eb 16                	jmp    80058a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 50 04             	lea    0x4(%eax),%edx
  80057a:	89 55 14             	mov    %edx,0x14(%ebp)
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800582:	89 c2                	mov    %eax,%edx
  800584:	c1 fa 1f             	sar    $0x1f,%edx
  800587:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80058a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80058d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800590:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800595:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800599:	0f 89 a7 00 00 00    	jns    800646 <vprintfmt+0x377>
				putch('-', putdat);
  80059f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005aa:	ff d7                	call   *%edi
				num = -(long long) num;
  8005ac:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005af:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005b2:	f7 d9                	neg    %ecx
  8005b4:	83 d3 00             	adc    $0x0,%ebx
  8005b7:	f7 db                	neg    %ebx
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	e9 83 00 00 00       	jmp    800646 <vprintfmt+0x377>
  8005c3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005c9:	89 ca                	mov    %ecx,%edx
  8005cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ce:	e8 a5 fc ff ff       	call   800278 <getuint>
  8005d3:	89 c1                	mov    %eax,%ecx
  8005d5:	89 d3                	mov    %edx,%ebx
  8005d7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8005dc:	eb 68                	jmp    800646 <vprintfmt+0x377>
  8005de:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005e1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8005e4:	89 ca                	mov    %ecx,%edx
  8005e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e9:	e8 8a fc ff ff       	call   800278 <getuint>
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	89 d3                	mov    %edx,%ebx
  8005f2:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8005f7:	eb 4d                	jmp    800646 <vprintfmt+0x377>
  8005f9:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8005fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800600:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800607:	ff d7                	call   *%edi
			putch('x', putdat);
  800609:	89 74 24 04          	mov    %esi,0x4(%esp)
  80060d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800614:	ff d7                	call   *%edi
			num = (unsigned long long)
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
  80061f:	8b 08                	mov    (%eax),%ecx
  800621:	bb 00 00 00 00       	mov    $0x0,%ebx
  800626:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80062b:	eb 19                	jmp    800646 <vprintfmt+0x377>
  80062d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800630:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800633:	89 ca                	mov    %ecx,%edx
  800635:	8d 45 14             	lea    0x14(%ebp),%eax
  800638:	e8 3b fc ff ff       	call   800278 <getuint>
  80063d:	89 c1                	mov    %eax,%ecx
  80063f:	89 d3                	mov    %edx,%ebx
  800641:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800646:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80064a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80064e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800651:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800655:	89 44 24 08          	mov    %eax,0x8(%esp)
  800659:	89 0c 24             	mov    %ecx,(%esp)
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	89 f2                	mov    %esi,%edx
  800662:	89 f8                	mov    %edi,%eax
  800664:	e8 27 fb ff ff       	call   800190 <printnum>
  800669:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80066c:	e9 8a fc ff ff       	jmp    8002fb <vprintfmt+0x2c>
  800671:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800674:	89 74 24 04          	mov    %esi,0x4(%esp)
  800678:	89 04 24             	mov    %eax,(%esp)
  80067b:	ff d7                	call   *%edi
  80067d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800680:	e9 76 fc ff ff       	jmp    8002fb <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800685:	89 74 24 04          	mov    %esi,0x4(%esp)
  800689:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800690:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800692:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800695:	80 38 25             	cmpb   $0x25,(%eax)
  800698:	0f 84 5d fc ff ff    	je     8002fb <vprintfmt+0x2c>
  80069e:	89 c3                	mov    %eax,%ebx
  8006a0:	eb f0                	jmp    800692 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  8006a2:	83 c4 4c             	add    $0x4c,%esp
  8006a5:	5b                   	pop    %ebx
  8006a6:	5e                   	pop    %esi
  8006a7:	5f                   	pop    %edi
  8006a8:	5d                   	pop    %ebp
  8006a9:	c3                   	ret    

008006aa <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	83 ec 28             	sub    $0x28,%esp
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006b6:	85 c0                	test   %eax,%eax
  8006b8:	74 04                	je     8006be <vsnprintf+0x14>
  8006ba:	85 d2                	test   %edx,%edx
  8006bc:	7f 07                	jg     8006c5 <vsnprintf+0x1b>
  8006be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006c3:	eb 3b                	jmp    800700 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8006cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006eb:	c7 04 24 b2 02 80 00 	movl   $0x8002b2,(%esp)
  8006f2:	e8 d8 fb ff ff       	call   8002cf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800708:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80070b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070f:	8b 45 10             	mov    0x10(%ebp),%eax
  800712:	89 44 24 08          	mov    %eax,0x8(%esp)
  800716:	8b 45 0c             	mov    0xc(%ebp),%eax
  800719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	89 04 24             	mov    %eax,(%esp)
  800723:	e8 82 ff ff ff       	call   8006aa <vsnprintf>
	va_end(ap);

	return rc;
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    

0080072a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800730:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800733:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800737:	8b 45 10             	mov    0x10(%ebp),%eax
  80073a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80073e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800741:	89 44 24 04          	mov    %eax,0x4(%esp)
  800745:	8b 45 08             	mov    0x8(%ebp),%eax
  800748:	89 04 24             	mov    %eax,(%esp)
  80074b:	e8 7f fb ff ff       	call   8002cf <vprintfmt>
	va_end(ap);
}
  800750:	c9                   	leave  
  800751:	c3                   	ret    
	...

00800760 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	8b 55 08             	mov    0x8(%ebp),%edx
  800766:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  80076b:	eb 03                	jmp    800770 <strlen+0x10>
		n++;
  80076d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800770:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800774:	75 f7                	jne    80076d <strlen+0xd>
		n++;
	return n;
}
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80077f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800787:	eb 03                	jmp    80078c <strnlen+0x14>
		n++;
  800789:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078c:	39 c1                	cmp    %eax,%ecx
  80078e:	74 06                	je     800796 <strnlen+0x1e>
  800790:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800794:	75 f3                	jne    800789 <strnlen+0x11>
		n++;
	return n;
}
  800796:	5b                   	pop    %ebx
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	53                   	push   %ebx
  80079d:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007ac:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007af:	83 c2 01             	add    $0x1,%edx
  8007b2:	84 c9                	test   %cl,%cl
  8007b4:	75 f2                	jne    8007a8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b6:	5b                   	pop    %ebx
  8007b7:	5d                   	pop    %ebp
  8007b8:	c3                   	ret    

008007b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	83 ec 08             	sub    $0x8,%esp
  8007c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c3:	89 1c 24             	mov    %ebx,(%esp)
  8007c6:	e8 95 ff ff ff       	call   800760 <strlen>
	strcpy(dst + len, src);
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8007d5:	89 04 24             	mov    %eax,(%esp)
  8007d8:	e8 bc ff ff ff       	call   800799 <strcpy>
	return dst;
}
  8007dd:	89 d8                	mov    %ebx,%eax
  8007df:	83 c4 08             	add    $0x8,%esp
  8007e2:	5b                   	pop    %ebx
  8007e3:	5d                   	pop    %ebp
  8007e4:	c3                   	ret    

008007e5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f0:	8b 75 10             	mov    0x10(%ebp),%esi
  8007f3:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f8:	eb 0f                	jmp    800809 <strncpy+0x24>
		*dst++ = *src;
  8007fa:	0f b6 19             	movzbl (%ecx),%ebx
  8007fd:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800800:	80 39 01             	cmpb   $0x1,(%ecx)
  800803:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800806:	83 c2 01             	add    $0x1,%edx
  800809:	39 f2                	cmp    %esi,%edx
  80080b:	72 ed                	jb     8007fa <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80080d:	5b                   	pop    %ebx
  80080e:	5e                   	pop    %esi
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	56                   	push   %esi
  800815:	53                   	push   %ebx
  800816:	8b 75 08             	mov    0x8(%ebp),%esi
  800819:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80081f:	89 f0                	mov    %esi,%eax
  800821:	85 d2                	test   %edx,%edx
  800823:	75 0a                	jne    80082f <strlcpy+0x1e>
  800825:	eb 17                	jmp    80083e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800827:	88 18                	mov    %bl,(%eax)
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082f:	83 ea 01             	sub    $0x1,%edx
  800832:	74 07                	je     80083b <strlcpy+0x2a>
  800834:	0f b6 19             	movzbl (%ecx),%ebx
  800837:	84 db                	test   %bl,%bl
  800839:	75 ec                	jne    800827 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80083b:	c6 00 00             	movb   $0x0,(%eax)
  80083e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800840:	5b                   	pop    %ebx
  800841:	5e                   	pop    %esi
  800842:	5d                   	pop    %ebp
  800843:	c3                   	ret    

00800844 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80084a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084d:	eb 06                	jmp    800855 <strcmp+0x11>
		p++, q++;
  80084f:	83 c1 01             	add    $0x1,%ecx
  800852:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800855:	0f b6 01             	movzbl (%ecx),%eax
  800858:	84 c0                	test   %al,%al
  80085a:	74 04                	je     800860 <strcmp+0x1c>
  80085c:	3a 02                	cmp    (%edx),%al
  80085e:	74 ef                	je     80084f <strcmp+0xb>
  800860:	0f b6 c0             	movzbl %al,%eax
  800863:	0f b6 12             	movzbl (%edx),%edx
  800866:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800874:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800877:	eb 09                	jmp    800882 <strncmp+0x18>
		n--, p++, q++;
  800879:	83 ea 01             	sub    $0x1,%edx
  80087c:	83 c0 01             	add    $0x1,%eax
  80087f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800882:	85 d2                	test   %edx,%edx
  800884:	75 07                	jne    80088d <strncmp+0x23>
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	eb 13                	jmp    8008a0 <strncmp+0x36>
  80088d:	0f b6 18             	movzbl (%eax),%ebx
  800890:	84 db                	test   %bl,%bl
  800892:	74 04                	je     800898 <strncmp+0x2e>
  800894:	3a 19                	cmp    (%ecx),%bl
  800896:	74 e1                	je     800879 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 00             	movzbl (%eax),%eax
  80089b:	0f b6 11             	movzbl (%ecx),%edx
  80089e:	29 d0                	sub    %edx,%eax
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ad:	eb 07                	jmp    8008b6 <strchr+0x13>
		if (*s == c)
  8008af:	38 ca                	cmp    %cl,%dl
  8008b1:	74 0f                	je     8008c2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b3:	83 c0 01             	add    $0x1,%eax
  8008b6:	0f b6 10             	movzbl (%eax),%edx
  8008b9:	84 d2                	test   %dl,%dl
  8008bb:	75 f2                	jne    8008af <strchr+0xc>
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ce:	eb 07                	jmp    8008d7 <strfind+0x13>
		if (*s == c)
  8008d0:	38 ca                	cmp    %cl,%dl
  8008d2:	74 0a                	je     8008de <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008d4:	83 c0 01             	add    $0x1,%eax
  8008d7:	0f b6 10             	movzbl (%eax),%edx
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	75 f2                	jne    8008d0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8008de:	5d                   	pop    %ebp
  8008df:	90                   	nop
  8008e0:	c3                   	ret    

008008e1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	83 ec 0c             	sub    $0xc,%esp
  8008e7:	89 1c 24             	mov    %ebx,(%esp)
  8008ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ee:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8008f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fb:	85 c9                	test   %ecx,%ecx
  8008fd:	74 30                	je     80092f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800905:	75 25                	jne    80092c <memset+0x4b>
  800907:	f6 c1 03             	test   $0x3,%cl
  80090a:	75 20                	jne    80092c <memset+0x4b>
		c &= 0xFF;
  80090c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80090f:	89 d3                	mov    %edx,%ebx
  800911:	c1 e3 08             	shl    $0x8,%ebx
  800914:	89 d6                	mov    %edx,%esi
  800916:	c1 e6 18             	shl    $0x18,%esi
  800919:	89 d0                	mov    %edx,%eax
  80091b:	c1 e0 10             	shl    $0x10,%eax
  80091e:	09 f0                	or     %esi,%eax
  800920:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800922:	09 d8                	or     %ebx,%eax
  800924:	c1 e9 02             	shr    $0x2,%ecx
  800927:	fc                   	cld    
  800928:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092a:	eb 03                	jmp    80092f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80092c:	fc                   	cld    
  80092d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80092f:	89 f8                	mov    %edi,%eax
  800931:	8b 1c 24             	mov    (%esp),%ebx
  800934:	8b 74 24 04          	mov    0x4(%esp),%esi
  800938:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80093c:	89 ec                	mov    %ebp,%esp
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
  800946:	89 34 24             	mov    %esi,(%esp)
  800949:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800956:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800958:	39 c6                	cmp    %eax,%esi
  80095a:	73 35                	jae    800991 <memmove+0x51>
  80095c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095f:	39 d0                	cmp    %edx,%eax
  800961:	73 2e                	jae    800991 <memmove+0x51>
		s += n;
		d += n;
  800963:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800965:	f6 c2 03             	test   $0x3,%dl
  800968:	75 1b                	jne    800985 <memmove+0x45>
  80096a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800970:	75 13                	jne    800985 <memmove+0x45>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0e                	jne    800985 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800977:	83 ef 04             	sub    $0x4,%edi
  80097a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	fd                   	std    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800983:	eb 09                	jmp    80098e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800985:	83 ef 01             	sub    $0x1,%edi
  800988:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098b:	fd                   	std    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098f:	eb 20                	jmp    8009b1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800997:	75 15                	jne    8009ae <memmove+0x6e>
  800999:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80099f:	75 0d                	jne    8009ae <memmove+0x6e>
  8009a1:	f6 c1 03             	test   $0x3,%cl
  8009a4:	75 08                	jne    8009ae <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  8009a6:	c1 e9 02             	shr    $0x2,%ecx
  8009a9:	fc                   	cld    
  8009aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	eb 03                	jmp    8009b1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ae:	fc                   	cld    
  8009af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009b1:	8b 34 24             	mov    (%esp),%esi
  8009b4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009b8:	89 ec                	mov    %ebp,%esp
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	89 04 24             	mov    %eax,(%esp)
  8009d6:	e8 65 ff ff ff       	call   800940 <memmove>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	57                   	push   %edi
  8009e1:	56                   	push   %esi
  8009e2:	53                   	push   %ebx
  8009e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8009ec:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f1:	eb 1c                	jmp    800a0f <memcmp+0x32>
		if (*s1 != *s2)
  8009f3:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  8009f7:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 e9 01             	sub    $0x1,%ecx
  800a01:	38 d8                	cmp    %bl,%al
  800a03:	74 0a                	je     800a0f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800a05:	0f b6 c0             	movzbl %al,%eax
  800a08:	0f b6 db             	movzbl %bl,%ebx
  800a0b:	29 d8                	sub    %ebx,%eax
  800a0d:	eb 09                	jmp    800a18 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	85 c9                	test   %ecx,%ecx
  800a11:	75 e0                	jne    8009f3 <memcmp+0x16>
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2b:	eb 07                	jmp    800a34 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2d:	38 08                	cmp    %cl,(%eax)
  800a2f:	74 07                	je     800a38 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a31:	83 c0 01             	add    $0x1,%eax
  800a34:	39 d0                	cmp    %edx,%eax
  800a36:	72 f5                	jb     800a2d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	83 ec 04             	sub    $0x4,%esp
  800a43:	8b 55 08             	mov    0x8(%ebp),%edx
  800a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a49:	eb 03                	jmp    800a4e <strtol+0x14>
		s++;
  800a4b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4e:	0f b6 02             	movzbl (%edx),%eax
  800a51:	3c 20                	cmp    $0x20,%al
  800a53:	74 f6                	je     800a4b <strtol+0x11>
  800a55:	3c 09                	cmp    $0x9,%al
  800a57:	74 f2                	je     800a4b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a59:	3c 2b                	cmp    $0x2b,%al
  800a5b:	75 0c                	jne    800a69 <strtol+0x2f>
		s++;
  800a5d:	8d 52 01             	lea    0x1(%edx),%edx
  800a60:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a67:	eb 15                	jmp    800a7e <strtol+0x44>
	else if (*s == '-')
  800a69:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a70:	3c 2d                	cmp    $0x2d,%al
  800a72:	75 0a                	jne    800a7e <strtol+0x44>
		s++, neg = 1;
  800a74:	8d 52 01             	lea    0x1(%edx),%edx
  800a77:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7e:	85 db                	test   %ebx,%ebx
  800a80:	0f 94 c0             	sete   %al
  800a83:	74 05                	je     800a8a <strtol+0x50>
  800a85:	83 fb 10             	cmp    $0x10,%ebx
  800a88:	75 18                	jne    800aa2 <strtol+0x68>
  800a8a:	80 3a 30             	cmpb   $0x30,(%edx)
  800a8d:	75 13                	jne    800aa2 <strtol+0x68>
  800a8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a93:	75 0d                	jne    800aa2 <strtol+0x68>
		s += 2, base = 16;
  800a95:	83 c2 02             	add    $0x2,%edx
  800a98:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9d:	8d 76 00             	lea    0x0(%esi),%esi
  800aa0:	eb 13                	jmp    800ab5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa2:	84 c0                	test   %al,%al
  800aa4:	74 0f                	je     800ab5 <strtol+0x7b>
  800aa6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aab:	80 3a 30             	cmpb   $0x30,(%edx)
  800aae:	75 05                	jne    800ab5 <strtol+0x7b>
		s++, base = 8;
  800ab0:	83 c2 01             	add    $0x1,%edx
  800ab3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aba:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abc:	0f b6 0a             	movzbl (%edx),%ecx
  800abf:	89 cf                	mov    %ecx,%edi
  800ac1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac4:	80 fb 09             	cmp    $0x9,%bl
  800ac7:	77 08                	ja     800ad1 <strtol+0x97>
			dig = *s - '0';
  800ac9:	0f be c9             	movsbl %cl,%ecx
  800acc:	83 e9 30             	sub    $0x30,%ecx
  800acf:	eb 1e                	jmp    800aef <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800ad1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ad4:	80 fb 19             	cmp    $0x19,%bl
  800ad7:	77 08                	ja     800ae1 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800ad9:	0f be c9             	movsbl %cl,%ecx
  800adc:	83 e9 57             	sub    $0x57,%ecx
  800adf:	eb 0e                	jmp    800aef <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800ae1:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ae4:	80 fb 19             	cmp    $0x19,%bl
  800ae7:	77 15                	ja     800afe <strtol+0xc4>
			dig = *s - 'A' + 10;
  800ae9:	0f be c9             	movsbl %cl,%ecx
  800aec:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aef:	39 f1                	cmp    %esi,%ecx
  800af1:	7d 0b                	jge    800afe <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800af3:	83 c2 01             	add    $0x1,%edx
  800af6:	0f af c6             	imul   %esi,%eax
  800af9:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800afc:	eb be                	jmp    800abc <strtol+0x82>
  800afe:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b04:	74 05                	je     800b0b <strtol+0xd1>
		*endptr = (char *) s;
  800b06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b09:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b0f:	74 04                	je     800b15 <strtol+0xdb>
  800b11:	89 c8                	mov    %ecx,%eax
  800b13:	f7 d8                	neg    %eax
}
  800b15:	83 c4 04             	add    $0x4,%esp
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    
  800b1d:	00 00                	add    %al,(%eax)
	...

00800b20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	89 1c 24             	mov    %ebx,(%esp)
  800b29:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b2d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b31:	b8 00 00 00 00       	mov    $0x0,%eax
  800b36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b39:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3c:	89 c3                	mov    %eax,%ebx
  800b3e:	89 c7                	mov    %eax,%edi
  800b40:	89 c6                	mov    %eax,%esi
  800b42:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b44:	8b 1c 24             	mov    (%esp),%ebx
  800b47:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b4b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b4f:	89 ec                	mov    %ebp,%esp
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 38             	sub    $0x38,%esp
  800b59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800b62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b66:	75 0c                	jne    800b74 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800b68:	c7 04 24 08 14 80 00 	movl   $0x801408,(%esp)
  800b6f:	e8 b9 f5 ff ff       	call   80012d <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b79:	b8 09 00 00 00       	mov    $0x9,%eax
  800b7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b84:	89 df                	mov    %ebx,%edi
  800b86:	89 de                	mov    %ebx,%esi
  800b88:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b8a:	85 c0                	test   %eax,%eax
  800b8c:	7e 28                	jle    800bb6 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b92:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800b99:	00 
  800b9a:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800ba1:	00 
  800ba2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ba9:	00 
  800baa:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800bb1:	e8 16 03 00 00       	call   800ecc <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bb6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bb9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bbc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bbf:	89 ec                	mov    %ebp,%esp
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 38             	sub    $0x38,%esp
  800bc9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bcc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bcf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	89 cb                	mov    %ecx,%ebx
  800be1:	89 cf                	mov    %ecx,%edi
  800be3:	89 ce                	mov    %ecx,%esi
  800be5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7e 28                	jle    800c13 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800beb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bef:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800bf6:	00 
  800bf7:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800bfe:	00 
  800bff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c06:	00 
  800c07:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800c0e:	e8 b9 02 00 00       	call   800ecc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c13:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c16:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c19:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c1c:	89 ec                	mov    %ebp,%esp
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	89 1c 24             	mov    %ebx,(%esp)
  800c29:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c2d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c31:	be 00 00 00 00       	mov    $0x0,%esi
  800c36:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c49:	8b 1c 24             	mov    (%esp),%ebx
  800c4c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c50:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c54:	89 ec                	mov    %ebp,%esp
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 38             	sub    $0x38,%esp
  800c5e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c61:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c64:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	89 df                	mov    %ebx,%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7d:	85 c0                	test   %eax,%eax
  800c7f:	7e 28                	jle    800ca9 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c85:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800c8c:	00 
  800c8d:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800c94:	00 
  800c95:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9c:	00 
  800c9d:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800ca4:	e8 23 02 00 00       	call   800ecc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cac:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800caf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cb2:	89 ec                	mov    %ebp,%esp
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	83 ec 38             	sub    $0x38,%esp
  800cbc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cbf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 06 00 00 00       	mov    $0x6,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 28                	jle    800d07 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800cea:	00 
  800ceb:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfa:	00 
  800cfb:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800d02:	e8 c5 01 00 00       	call   800ecc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d07:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d0d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d10:	89 ec                	mov    %ebp,%esp
  800d12:	5d                   	pop    %ebp
  800d13:	c3                   	ret    

00800d14 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 38             	sub    $0x38,%esp
  800d1a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d1d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d20:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d23:	b8 05 00 00 00       	mov    $0x5,%eax
  800d28:	8b 75 18             	mov    0x18(%ebp),%esi
  800d2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	7e 28                	jle    800d65 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d41:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d48:	00 
  800d49:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800d50:	00 
  800d51:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d58:	00 
  800d59:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800d60:	e8 67 01 00 00       	call   800ecc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d65:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d68:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d6b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d6e:	89 ec                	mov    %ebp,%esp
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	83 ec 38             	sub    $0x38,%esp
  800d78:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d7b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d7e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	be 00 00 00 00       	mov    $0x0,%esi
  800d86:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	89 f7                	mov    %esi,%edi
  800d96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 28                	jle    800dc4 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800da7:	00 
  800da8:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800daf:	00 
  800db0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db7:	00 
  800db8:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800dbf:	e8 08 01 00 00       	call   800ecc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dcd:	89 ec                	mov    %ebp,%esp
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	89 1c 24             	mov    %ebx,(%esp)
  800dda:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dde:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de2:	ba 00 00 00 00       	mov    $0x0,%edx
  800de7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dec:	89 d1                	mov    %edx,%ecx
  800dee:	89 d3                	mov    %edx,%ebx
  800df0:	89 d7                	mov    %edx,%edi
  800df2:	89 d6                	mov    %edx,%esi
  800df4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800df6:	8b 1c 24             	mov    (%esp),%ebx
  800df9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dfd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e01:	89 ec                	mov    %ebp,%esp
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	89 1c 24             	mov    %ebx,(%esp)
  800e0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e12:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e16:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e20:	89 d1                	mov    %edx,%ecx
  800e22:	89 d3                	mov    %edx,%ebx
  800e24:	89 d7                	mov    %edx,%edi
  800e26:	89 d6                	mov    %edx,%esi
  800e28:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e2a:	8b 1c 24             	mov    (%esp),%ebx
  800e2d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e31:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e35:	89 ec                	mov    %ebp,%esp
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    

00800e39 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	83 ec 38             	sub    $0x38,%esp
  800e3f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e42:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e45:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4d:	b8 03 00 00 00       	mov    $0x3,%eax
  800e52:	8b 55 08             	mov    0x8(%ebp),%edx
  800e55:	89 cb                	mov    %ecx,%ebx
  800e57:	89 cf                	mov    %ecx,%edi
  800e59:	89 ce                	mov    %ecx,%esi
  800e5b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	7e 28                	jle    800e89 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e61:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e65:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e6c:	00 
  800e6d:	c7 44 24 08 34 14 80 	movl   $0x801434,0x8(%esp)
  800e74:	00 
  800e75:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7c:	00 
  800e7d:	c7 04 24 51 14 80 00 	movl   $0x801451,(%esp)
  800e84:	e8 43 00 00 00       	call   800ecc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e89:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e8c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e8f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e92:	89 ec                	mov    %ebp,%esp
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 0c             	sub    $0xc,%esp
  800e9c:	89 1c 24             	mov    %ebx,(%esp)
  800e9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea3:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eac:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb1:	89 d1                	mov    %edx,%ecx
  800eb3:	89 d3                	mov    %edx,%ebx
  800eb5:	89 d7                	mov    %edx,%edi
  800eb7:	89 d6                	mov    %edx,%esi
  800eb9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ebb:	8b 1c 24             	mov    (%esp),%ebx
  800ebe:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ec2:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ec6:	89 ec                	mov    %ebp,%esp
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    
	...

00800ecc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800ed4:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ed7:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800edd:	e8 23 ff ff ff       	call   800e05 <sys_getenvid>
  800ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee5:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ee9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eec:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ef0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef8:	c7 04 24 60 14 80 00 	movl   $0x801460,(%esp)
  800eff:	e8 29 f2 ff ff       	call   80012d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f04:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f08:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0b:	89 04 24             	mov    %eax,(%esp)
  800f0e:	e8 b9 f1 ff ff       	call   8000cc <vcprintf>
	cprintf("\n");
  800f13:	c7 04 24 ac 11 80 00 	movl   $0x8011ac,(%esp)
  800f1a:	e8 0e f2 ff ff       	call   80012d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f1f:	cc                   	int3   
  800f20:	eb fd                	jmp    800f1f <_panic+0x53>
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
