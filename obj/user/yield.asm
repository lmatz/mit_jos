
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 20 80 00       	mov    0x802004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 e0 11 80 00 	movl   $0x8011e0,(%esp)
  80004e:	e8 12 01 00 00       	call   800165 <cprintf>
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 5; i++) {
		sys_yield();
  800058:	e8 b4 0d 00 00       	call   800e11 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 00 12 80 00 	movl   $0x801200,(%esp)
  800074:	e8 ec 00 00 00       	call   800165 <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800081:	a1 04 20 80 00       	mov    0x802004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 2c 12 80 00 	movl   $0x80122c,(%esp)
  800094:	e8 cc 00 00 00       	call   800165 <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  8000b2:	e8 8e 0d 00 00       	call   800e45 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 f6                	test   %esi,%esi
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 03                	mov    (%ebx),%eax
  8000cf:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d8:	89 34 24             	mov    %esi,(%esp)
  8000db:	e8 54 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 77 0d 00 00       	call   800e79 <sys_env_destroy>
}
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80010d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800114:	00 00 00 
	b.cnt = 0;
  800117:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800121:	8b 45 0c             	mov    0xc(%ebp),%eax
  800124:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800128:	8b 45 08             	mov    0x8(%ebp),%eax
  80012b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800135:	89 44 24 04          	mov    %eax,0x4(%esp)
  800139:	c7 04 24 7f 01 80 00 	movl   $0x80017f,(%esp)
  800140:	e8 ca 01 00 00       	call   80030f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800145:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800155:	89 04 24             	mov    %eax,(%esp)
  800158:	e8 03 0a 00 00       	call   800b60 <sys_cputs>

	return b.cnt;
}
  80015d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80016b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80016e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	89 04 24             	mov    %eax,(%esp)
  800178:	e8 87 ff ff ff       	call   800104 <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	53                   	push   %ebx
  800183:	83 ec 14             	sub    $0x14,%esp
  800186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800189:	8b 03                	mov    (%ebx),%eax
  80018b:	8b 55 08             	mov    0x8(%ebp),%edx
  80018e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800192:	83 c0 01             	add    $0x1,%eax
  800195:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800197:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019c:	75 19                	jne    8001b7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80019e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a5:	00 
  8001a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a9:	89 04 24             	mov    %eax,(%esp)
  8001ac:	e8 af 09 00 00       	call   800b60 <sys_cputs>
		b->idx = 0;
  8001b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001bb:	83 c4 14             	add    $0x14,%esp
  8001be:	5b                   	pop    %ebx
  8001bf:	5d                   	pop    %ebp
  8001c0:	c3                   	ret    
	...

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 4c             	sub    $0x4c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001fb:	39 d1                	cmp    %edx,%ecx
  8001fd:	72 07                	jb     800206 <printnum+0x36>
  8001ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800202:	39 d0                	cmp    %edx,%eax
  800204:	77 69                	ja     80026f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800206:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80020a:	83 eb 01             	sub    $0x1,%ebx
  80020d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800219:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80021d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800220:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800223:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800226:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80022a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800231:	00 
  800232:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80023b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023f:	e8 2c 0d 00 00       	call   800f70 <__udivdi3>
  800244:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800247:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80024a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800252:	89 04 24             	mov    %eax,(%esp)
  800255:	89 54 24 04          	mov    %edx,0x4(%esp)
  800259:	89 f2                	mov    %esi,%edx
  80025b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025e:	e8 6d ff ff ff       	call   8001d0 <printnum>
  800263:	eb 11                	jmp    800276 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800265:	89 74 24 04          	mov    %esi,0x4(%esp)
  800269:	89 3c 24             	mov    %edi,(%esp)
  80026c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026f:	83 eb 01             	sub    $0x1,%ebx
  800272:	85 db                	test   %ebx,%ebx
  800274:	7f ef                	jg     800265 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80027a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80027e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800281:	89 44 24 08          	mov    %eax,0x8(%esp)
  800285:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028c:	00 
  80028d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800290:	89 14 24             	mov    %edx,(%esp)
  800293:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800296:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80029a:	e8 01 0e 00 00       	call   8010a0 <__umoddi3>
  80029f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a3:	0f be 80 55 12 80 00 	movsbl 0x801255(%eax),%eax
  8002aa:	89 04 24             	mov    %eax,(%esp)
  8002ad:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002b0:	83 c4 4c             	add    $0x4c,%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002bb:	83 fa 01             	cmp    $0x1,%edx
  8002be:	7e 0e                	jle    8002ce <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	8b 52 04             	mov    0x4(%edx),%edx
  8002cc:	eb 22                	jmp    8002f0 <getuint+0x38>
	else if (lflag)
  8002ce:	85 d2                	test   %edx,%edx
  8002d0:	74 10                	je     8002e2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e0:	eb 0e                	jmp    8002f0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e2:	8b 10                	mov    (%eax),%edx
  8002e4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e7:	89 08                	mov    %ecx,(%eax)
  8002e9:	8b 02                	mov    (%edx),%eax
  8002eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800301:	73 0a                	jae    80030d <sprintputch+0x1b>
		*b->buf++ = ch;
  800303:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800306:	88 0a                	mov    %cl,(%edx)
  800308:	83 c2 01             	add    $0x1,%edx
  80030b:	89 10                	mov    %edx,(%eax)
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	57                   	push   %edi
  800313:	56                   	push   %esi
  800314:	53                   	push   %ebx
  800315:	83 ec 4c             	sub    $0x4c,%esp
  800318:	8b 7d 08             	mov    0x8(%ebp),%edi
  80031b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800321:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800328:	eb 11                	jmp    80033b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80032a:	85 c0                	test   %eax,%eax
  80032c:	0f 84 b0 03 00 00    	je     8006e2 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800332:	89 74 24 04          	mov    %esi,0x4(%esp)
  800336:	89 04 24             	mov    %eax,(%esp)
  800339:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033b:	0f b6 03             	movzbl (%ebx),%eax
  80033e:	83 c3 01             	add    $0x1,%ebx
  800341:	83 f8 25             	cmp    $0x25,%eax
  800344:	75 e4                	jne    80032a <vprintfmt+0x1b>
  800346:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80034d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800352:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800356:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80035d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800364:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800367:	eb 06                	jmp    80036f <vprintfmt+0x60>
  800369:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80036d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036f:	0f b6 0b             	movzbl (%ebx),%ecx
  800372:	0f b6 c1             	movzbl %cl,%eax
  800375:	8d 53 01             	lea    0x1(%ebx),%edx
  800378:	83 e9 23             	sub    $0x23,%ecx
  80037b:	80 f9 55             	cmp    $0x55,%cl
  80037e:	0f 87 41 03 00 00    	ja     8006c5 <vprintfmt+0x3b6>
  800384:	0f b6 c9             	movzbl %cl,%ecx
  800387:	ff 24 8d 20 13 80 00 	jmp    *0x801320(,%ecx,4)
  80038e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800392:	eb d9                	jmp    80036d <vprintfmt+0x5e>
  800394:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80039b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003a3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003a7:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  8003aa:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003ad:	83 fb 09             	cmp    $0x9,%ebx
  8003b0:	77 2b                	ja     8003dd <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b2:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b5:	eb e9                	jmp    8003a0 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	8d 48 04             	lea    0x4(%eax),%ecx
  8003bd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003c0:	8b 00                	mov    (%eax),%eax
  8003c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  8003c5:	eb 19                	jmp    8003e0 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  8003c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ca:	c1 f8 1f             	sar    $0x1f,%eax
  8003cd:	f7 d0                	not    %eax
  8003cf:	21 45 e4             	and    %eax,-0x1c(%ebp)
  8003d2:	eb 99                	jmp    80036d <vprintfmt+0x5e>
  8003d4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003db:	eb 90                	jmp    80036d <vprintfmt+0x5e>
  8003dd:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  8003e0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003e4:	79 87                	jns    80036d <vprintfmt+0x5e>
  8003e6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ec:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003ef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003f2:	e9 76 ff ff ff       	jmp    80036d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003fb:	e9 6d ff ff ff       	jmp    80036d <vprintfmt+0x5e>
  800400:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800403:	8b 45 14             	mov    0x14(%ebp),%eax
  800406:	8d 50 04             	lea    0x4(%eax),%edx
  800409:	89 55 14             	mov    %edx,0x14(%ebp)
  80040c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	89 04 24             	mov    %eax,(%esp)
  800415:	ff d7                	call   *%edi
  800417:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80041a:	e9 1c ff ff ff       	jmp    80033b <vprintfmt+0x2c>
  80041f:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 50 04             	lea    0x4(%eax),%edx
  800428:	89 55 14             	mov    %edx,0x14(%ebp)
  80042b:	8b 00                	mov    (%eax),%eax
  80042d:	89 c2                	mov    %eax,%edx
  80042f:	c1 fa 1f             	sar    $0x1f,%edx
  800432:	31 d0                	xor    %edx,%eax
  800434:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800436:	83 f8 09             	cmp    $0x9,%eax
  800439:	7f 0b                	jg     800446 <vprintfmt+0x137>
  80043b:	8b 14 85 80 14 80 00 	mov    0x801480(,%eax,4),%edx
  800442:	85 d2                	test   %edx,%edx
  800444:	75 20                	jne    800466 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800446:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80044a:	c7 44 24 08 66 12 80 	movl   $0x801266,0x8(%esp)
  800451:	00 
  800452:	89 74 24 04          	mov    %esi,0x4(%esp)
  800456:	89 3c 24             	mov    %edi,(%esp)
  800459:	e8 0c 03 00 00       	call   80076a <printfmt>
  80045e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800461:	e9 d5 fe ff ff       	jmp    80033b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800466:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80046a:	c7 44 24 08 6f 12 80 	movl   $0x80126f,0x8(%esp)
  800471:	00 
  800472:	89 74 24 04          	mov    %esi,0x4(%esp)
  800476:	89 3c 24             	mov    %edi,(%esp)
  800479:	e8 ec 02 00 00       	call   80076a <printfmt>
  80047e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800481:	e9 b5 fe ff ff       	jmp    80033b <vprintfmt+0x2c>
  800486:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800489:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80048c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80048f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 18                	mov    (%eax),%ebx
  80049d:	85 db                	test   %ebx,%ebx
  80049f:	75 05                	jne    8004a6 <vprintfmt+0x197>
  8004a1:	bb 72 12 80 00       	mov    $0x801272,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8004a6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004aa:	7e 76                	jle    800522 <vprintfmt+0x213>
  8004ac:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8004b0:	74 7a                	je     80052c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b6:	89 1c 24             	mov    %ebx,(%esp)
  8004b9:	e8 fa 02 00 00       	call   8007b8 <strnlen>
  8004be:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004c1:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  8004c3:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8004c7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004ca:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004cd:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	eb 0f                	jmp    8004e0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004d1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d8:	89 04 24             	mov    %eax,(%esp)
  8004db:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004dd:	83 eb 01             	sub    $0x1,%ebx
  8004e0:	85 db                	test   %ebx,%ebx
  8004e2:	7f ed                	jg     8004d1 <vprintfmt+0x1c2>
  8004e4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004e7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004ea:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004ed:	89 f7                	mov    %esi,%edi
  8004ef:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004f2:	eb 40                	jmp    800534 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f8:	74 18                	je     800512 <vprintfmt+0x203>
  8004fa:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004fd:	83 fa 5e             	cmp    $0x5e,%edx
  800500:	76 10                	jbe    800512 <vprintfmt+0x203>
					putch('?', putdat);
  800502:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800506:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80050d:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800510:	eb 0a                	jmp    80051c <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800512:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800516:	89 04 24             	mov    %eax,(%esp)
  800519:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800520:	eb 12                	jmp    800534 <vprintfmt+0x225>
  800522:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800525:	89 f7                	mov    %esi,%edi
  800527:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80052a:	eb 08                	jmp    800534 <vprintfmt+0x225>
  80052c:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80052f:	89 f7                	mov    %esi,%edi
  800531:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800534:	0f be 03             	movsbl (%ebx),%eax
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	85 c0                	test   %eax,%eax
  80053c:	74 25                	je     800563 <vprintfmt+0x254>
  80053e:	85 f6                	test   %esi,%esi
  800540:	78 b2                	js     8004f4 <vprintfmt+0x1e5>
  800542:	83 ee 01             	sub    $0x1,%esi
  800545:	79 ad                	jns    8004f4 <vprintfmt+0x1e5>
  800547:	89 fe                	mov    %edi,%esi
  800549:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80054c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80054f:	eb 1a                	jmp    80056b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800551:	89 74 24 04          	mov    %esi,0x4(%esp)
  800555:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80055c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055e:	83 eb 01             	sub    $0x1,%ebx
  800561:	eb 08                	jmp    80056b <vprintfmt+0x25c>
  800563:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800566:	89 fe                	mov    %edi,%esi
  800568:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80056b:	85 db                	test   %ebx,%ebx
  80056d:	7f e2                	jg     800551 <vprintfmt+0x242>
  80056f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800572:	e9 c4 fd ff ff       	jmp    80033b <vprintfmt+0x2c>
  800577:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80057a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80057d:	83 f9 01             	cmp    $0x1,%ecx
  800580:	7e 16                	jle    800598 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 50 08             	lea    0x8(%eax),%edx
  800588:	89 55 14             	mov    %edx,0x14(%ebp)
  80058b:	8b 10                	mov    (%eax),%edx
  80058d:	8b 48 04             	mov    0x4(%eax),%ecx
  800590:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800593:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800596:	eb 32                	jmp    8005ca <vprintfmt+0x2bb>
	else if (lflag)
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	74 18                	je     8005b4 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 00                	mov    (%eax),%eax
  8005a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005aa:	89 c1                	mov    %eax,%ecx
  8005ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8005af:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b2:	eb 16                	jmp    8005ca <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	89 c2                	mov    %eax,%edx
  8005c4:	c1 fa 1f             	sar    $0x1f,%edx
  8005c7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ca:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005cd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005d0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005d5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005d9:	0f 89 a7 00 00 00    	jns    800686 <vprintfmt+0x377>
				putch('-', putdat);
  8005df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005ea:	ff d7                	call   *%edi
				num = -(long long) num;
  8005ec:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005ef:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005f2:	f7 d9                	neg    %ecx
  8005f4:	83 d3 00             	adc    $0x0,%ebx
  8005f7:	f7 db                	neg    %ebx
  8005f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fe:	e9 83 00 00 00       	jmp    800686 <vprintfmt+0x377>
  800603:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800606:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800609:	89 ca                	mov    %ecx,%edx
  80060b:	8d 45 14             	lea    0x14(%ebp),%eax
  80060e:	e8 a5 fc ff ff       	call   8002b8 <getuint>
  800613:	89 c1                	mov    %eax,%ecx
  800615:	89 d3                	mov    %edx,%ebx
  800617:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80061c:	eb 68                	jmp    800686 <vprintfmt+0x377>
  80061e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800621:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800624:	89 ca                	mov    %ecx,%edx
  800626:	8d 45 14             	lea    0x14(%ebp),%eax
  800629:	e8 8a fc ff ff       	call   8002b8 <getuint>
  80062e:	89 c1                	mov    %eax,%ecx
  800630:	89 d3                	mov    %edx,%ebx
  800632:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800637:	eb 4d                	jmp    800686 <vprintfmt+0x377>
  800639:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80063c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800640:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800647:	ff d7                	call   *%edi
			putch('x', putdat);
  800649:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800654:	ff d7                	call   *%edi
			num = (unsigned long long)
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 50 04             	lea    0x4(%eax),%edx
  80065c:	89 55 14             	mov    %edx,0x14(%ebp)
  80065f:	8b 08                	mov    (%eax),%ecx
  800661:	bb 00 00 00 00       	mov    $0x0,%ebx
  800666:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80066b:	eb 19                	jmp    800686 <vprintfmt+0x377>
  80066d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800670:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800673:	89 ca                	mov    %ecx,%edx
  800675:	8d 45 14             	lea    0x14(%ebp),%eax
  800678:	e8 3b fc ff ff       	call   8002b8 <getuint>
  80067d:	89 c1                	mov    %eax,%ecx
  80067f:	89 d3                	mov    %edx,%ebx
  800681:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800686:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80068a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80068e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800691:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800695:	89 44 24 08          	mov    %eax,0x8(%esp)
  800699:	89 0c 24             	mov    %ecx,(%esp)
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	89 f2                	mov    %esi,%edx
  8006a2:	89 f8                	mov    %edi,%eax
  8006a4:	e8 27 fb ff ff       	call   8001d0 <printnum>
  8006a9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006ac:	e9 8a fc ff ff       	jmp    80033b <vprintfmt+0x2c>
  8006b1:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b8:	89 04 24             	mov    %eax,(%esp)
  8006bb:	ff d7                	call   *%edi
  8006bd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006c0:	e9 76 fc ff ff       	jmp    80033b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006d0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006d5:	80 38 25             	cmpb   $0x25,(%eax)
  8006d8:	0f 84 5d fc ff ff    	je     80033b <vprintfmt+0x2c>
  8006de:	89 c3                	mov    %eax,%ebx
  8006e0:	eb f0                	jmp    8006d2 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  8006e2:	83 c4 4c             	add    $0x4c,%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5e                   	pop    %esi
  8006e7:	5f                   	pop    %edi
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	83 ec 28             	sub    $0x28,%esp
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006f6:	85 c0                	test   %eax,%eax
  8006f8:	74 04                	je     8006fe <vsnprintf+0x14>
  8006fa:	85 d2                	test   %edx,%edx
  8006fc:	7f 07                	jg     800705 <vsnprintf+0x1b>
  8006fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800703:	eb 3b                	jmp    800740 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800705:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800708:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80070c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80070f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071d:	8b 45 10             	mov    0x10(%ebp),%eax
  800720:	89 44 24 08          	mov    %eax,0x8(%esp)
  800724:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800727:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072b:	c7 04 24 f2 02 80 00 	movl   $0x8002f2,(%esp)
  800732:	e8 d8 fb ff ff       	call   80030f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800737:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800740:	c9                   	leave  
  800741:	c3                   	ret    

00800742 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800748:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80074b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074f:	8b 45 10             	mov    0x10(%ebp),%eax
  800752:	89 44 24 08          	mov    %eax,0x8(%esp)
  800756:	8b 45 0c             	mov    0xc(%ebp),%eax
  800759:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	89 04 24             	mov    %eax,(%esp)
  800763:	e8 82 ff ff ff       	call   8006ea <vsnprintf>
	va_end(ap);

	return rc;
}
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800770:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800773:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800777:	8b 45 10             	mov    0x10(%ebp),%eax
  80077a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800781:	89 44 24 04          	mov    %eax,0x4(%esp)
  800785:	8b 45 08             	mov    0x8(%ebp),%eax
  800788:	89 04 24             	mov    %eax,(%esp)
  80078b:	e8 7f fb ff ff       	call   80030f <vprintfmt>
	va_end(ap);
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    
	...

008007a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a6:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ab:	eb 03                	jmp    8007b0 <strlen+0x10>
		n++;
  8007ad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b4:	75 f7                	jne    8007ad <strlen+0xd>
		n++;
	return n;
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c7:	eb 03                	jmp    8007cc <strnlen+0x14>
		n++;
  8007c9:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cc:	39 c1                	cmp    %eax,%ecx
  8007ce:	74 06                	je     8007d6 <strnlen+0x1e>
  8007d0:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8007d4:	75 f3                	jne    8007c9 <strnlen+0x11>
		n++;
	return n;
}
  8007d6:	5b                   	pop    %ebx
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007ec:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007ef:	83 c2 01             	add    $0x1,%edx
  8007f2:	84 c9                	test   %cl,%cl
  8007f4:	75 f2                	jne    8007e8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f6:	5b                   	pop    %ebx
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800803:	89 1c 24             	mov    %ebx,(%esp)
  800806:	e8 95 ff ff ff       	call   8007a0 <strlen>
	strcpy(dst + len, src);
  80080b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800812:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800815:	89 04 24             	mov    %eax,(%esp)
  800818:	e8 bc ff ff ff       	call   8007d9 <strcpy>
	return dst;
}
  80081d:	89 d8                	mov    %ebx,%eax
  80081f:	83 c4 08             	add    $0x8,%esp
  800822:	5b                   	pop    %ebx
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	56                   	push   %esi
  800829:	53                   	push   %ebx
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800830:	8b 75 10             	mov    0x10(%ebp),%esi
  800833:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800838:	eb 0f                	jmp    800849 <strncpy+0x24>
		*dst++ = *src;
  80083a:	0f b6 19             	movzbl (%ecx),%ebx
  80083d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800840:	80 39 01             	cmpb   $0x1,(%ecx)
  800843:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	39 f2                	cmp    %esi,%edx
  80084b:	72 ed                	jb     80083a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	56                   	push   %esi
  800855:	53                   	push   %ebx
  800856:	8b 75 08             	mov    0x8(%ebp),%esi
  800859:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085f:	89 f0                	mov    %esi,%eax
  800861:	85 d2                	test   %edx,%edx
  800863:	75 0a                	jne    80086f <strlcpy+0x1e>
  800865:	eb 17                	jmp    80087e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800867:	88 18                	mov    %bl,(%eax)
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086f:	83 ea 01             	sub    $0x1,%edx
  800872:	74 07                	je     80087b <strlcpy+0x2a>
  800874:	0f b6 19             	movzbl (%ecx),%ebx
  800877:	84 db                	test   %bl,%bl
  800879:	75 ec                	jne    800867 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80087b:	c6 00 00             	movb   $0x0,(%eax)
  80087e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088d:	eb 06                	jmp    800895 <strcmp+0x11>
		p++, q++;
  80088f:	83 c1 01             	add    $0x1,%ecx
  800892:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800895:	0f b6 01             	movzbl (%ecx),%eax
  800898:	84 c0                	test   %al,%al
  80089a:	74 04                	je     8008a0 <strcmp+0x1c>
  80089c:	3a 02                	cmp    (%edx),%al
  80089e:	74 ef                	je     80088f <strcmp+0xb>
  8008a0:	0f b6 c0             	movzbl %al,%eax
  8008a3:	0f b6 12             	movzbl (%edx),%edx
  8008a6:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b4:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008b7:	eb 09                	jmp    8008c2 <strncmp+0x18>
		n--, p++, q++;
  8008b9:	83 ea 01             	sub    $0x1,%edx
  8008bc:	83 c0 01             	add    $0x1,%eax
  8008bf:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c2:	85 d2                	test   %edx,%edx
  8008c4:	75 07                	jne    8008cd <strncmp+0x23>
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb 13                	jmp    8008e0 <strncmp+0x36>
  8008cd:	0f b6 18             	movzbl (%eax),%ebx
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	74 04                	je     8008d8 <strncmp+0x2e>
  8008d4:	3a 19                	cmp    (%ecx),%bl
  8008d6:	74 e1                	je     8008b9 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d8:	0f b6 00             	movzbl (%eax),%eax
  8008db:	0f b6 11             	movzbl (%ecx),%edx
  8008de:	29 d0                	sub    %edx,%eax
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ed:	eb 07                	jmp    8008f6 <strchr+0x13>
		if (*s == c)
  8008ef:	38 ca                	cmp    %cl,%dl
  8008f1:	74 0f                	je     800902 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	0f b6 10             	movzbl (%eax),%edx
  8008f9:	84 d2                	test   %dl,%dl
  8008fb:	75 f2                	jne    8008ef <strchr+0xc>
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090e:	eb 07                	jmp    800917 <strfind+0x13>
		if (*s == c)
  800910:	38 ca                	cmp    %cl,%dl
  800912:	74 0a                	je     80091e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800914:	83 c0 01             	add    $0x1,%eax
  800917:	0f b6 10             	movzbl (%eax),%edx
  80091a:	84 d2                	test   %dl,%dl
  80091c:	75 f2                	jne    800910 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  80091e:	5d                   	pop    %ebp
  80091f:	90                   	nop
  800920:	c3                   	ret    

00800921 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	83 ec 0c             	sub    $0xc,%esp
  800927:	89 1c 24             	mov    %ebx,(%esp)
  80092a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80092e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800932:	8b 7d 08             	mov    0x8(%ebp),%edi
  800935:	8b 45 0c             	mov    0xc(%ebp),%eax
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	74 30                	je     80096f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800945:	75 25                	jne    80096c <memset+0x4b>
  800947:	f6 c1 03             	test   $0x3,%cl
  80094a:	75 20                	jne    80096c <memset+0x4b>
		c &= 0xFF;
  80094c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094f:	89 d3                	mov    %edx,%ebx
  800951:	c1 e3 08             	shl    $0x8,%ebx
  800954:	89 d6                	mov    %edx,%esi
  800956:	c1 e6 18             	shl    $0x18,%esi
  800959:	89 d0                	mov    %edx,%eax
  80095b:	c1 e0 10             	shl    $0x10,%eax
  80095e:	09 f0                	or     %esi,%eax
  800960:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800962:	09 d8                	or     %ebx,%eax
  800964:	c1 e9 02             	shr    $0x2,%ecx
  800967:	fc                   	cld    
  800968:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096a:	eb 03                	jmp    80096f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096c:	fc                   	cld    
  80096d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096f:	89 f8                	mov    %edi,%eax
  800971:	8b 1c 24             	mov    (%esp),%ebx
  800974:	8b 74 24 04          	mov    0x4(%esp),%esi
  800978:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80097c:	89 ec                	mov    %ebp,%esp
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 08             	sub    $0x8,%esp
  800986:	89 34 24             	mov    %esi,(%esp)
  800989:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800993:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800996:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800998:	39 c6                	cmp    %eax,%esi
  80099a:	73 35                	jae    8009d1 <memmove+0x51>
  80099c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099f:	39 d0                	cmp    %edx,%eax
  8009a1:	73 2e                	jae    8009d1 <memmove+0x51>
		s += n;
		d += n;
  8009a3:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a5:	f6 c2 03             	test   $0x3,%dl
  8009a8:	75 1b                	jne    8009c5 <memmove+0x45>
  8009aa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b0:	75 13                	jne    8009c5 <memmove+0x45>
  8009b2:	f6 c1 03             	test   $0x3,%cl
  8009b5:	75 0e                	jne    8009c5 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8009b7:	83 ef 04             	sub    $0x4,%edi
  8009ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bd:	c1 e9 02             	shr    $0x2,%ecx
  8009c0:	fd                   	std    
  8009c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c3:	eb 09                	jmp    8009ce <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c5:	83 ef 01             	sub    $0x1,%edi
  8009c8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009cb:	fd                   	std    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ce:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009cf:	eb 20                	jmp    8009f1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d7:	75 15                	jne    8009ee <memmove+0x6e>
  8009d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009df:	75 0d                	jne    8009ee <memmove+0x6e>
  8009e1:	f6 c1 03             	test   $0x3,%cl
  8009e4:	75 08                	jne    8009ee <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  8009e6:	c1 e9 02             	shr    $0x2,%ecx
  8009e9:	fc                   	cld    
  8009ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ec:	eb 03                	jmp    8009f1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ee:	fc                   	cld    
  8009ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f1:	8b 34 24             	mov    (%esp),%esi
  8009f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009f8:	89 ec                	mov    %ebp,%esp
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a02:	8b 45 10             	mov    0x10(%ebp),%eax
  800a05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	89 04 24             	mov    %eax,(%esp)
  800a16:	e8 65 ff ff ff       	call   800980 <memmove>
}
  800a1b:	c9                   	leave  
  800a1c:	c3                   	ret    

00800a1d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a29:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a2c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a31:	eb 1c                	jmp    800a4f <memcmp+0x32>
		if (*s1 != *s2)
  800a33:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800a37:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800a3b:	83 c2 01             	add    $0x1,%edx
  800a3e:	83 e9 01             	sub    $0x1,%ecx
  800a41:	38 d8                	cmp    %bl,%al
  800a43:	74 0a                	je     800a4f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800a45:	0f b6 c0             	movzbl %al,%eax
  800a48:	0f b6 db             	movzbl %bl,%ebx
  800a4b:	29 d8                	sub    %ebx,%eax
  800a4d:	eb 09                	jmp    800a58 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a4f:	85 c9                	test   %ecx,%ecx
  800a51:	75 e0                	jne    800a33 <memcmp+0x16>
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a58:	5b                   	pop    %ebx
  800a59:	5e                   	pop    %esi
  800a5a:	5f                   	pop    %edi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a66:	89 c2                	mov    %eax,%edx
  800a68:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a6b:	eb 07                	jmp    800a74 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a6d:	38 08                	cmp    %cl,(%eax)
  800a6f:	74 07                	je     800a78 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a71:	83 c0 01             	add    $0x1,%eax
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	72 f5                	jb     800a6d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	57                   	push   %edi
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	83 ec 04             	sub    $0x4,%esp
  800a83:	8b 55 08             	mov    0x8(%ebp),%edx
  800a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a89:	eb 03                	jmp    800a8e <strtol+0x14>
		s++;
  800a8b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a8e:	0f b6 02             	movzbl (%edx),%eax
  800a91:	3c 20                	cmp    $0x20,%al
  800a93:	74 f6                	je     800a8b <strtol+0x11>
  800a95:	3c 09                	cmp    $0x9,%al
  800a97:	74 f2                	je     800a8b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a99:	3c 2b                	cmp    $0x2b,%al
  800a9b:	75 0c                	jne    800aa9 <strtol+0x2f>
		s++;
  800a9d:	8d 52 01             	lea    0x1(%edx),%edx
  800aa0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800aa7:	eb 15                	jmp    800abe <strtol+0x44>
	else if (*s == '-')
  800aa9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ab0:	3c 2d                	cmp    $0x2d,%al
  800ab2:	75 0a                	jne    800abe <strtol+0x44>
		s++, neg = 1;
  800ab4:	8d 52 01             	lea    0x1(%edx),%edx
  800ab7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800abe:	85 db                	test   %ebx,%ebx
  800ac0:	0f 94 c0             	sete   %al
  800ac3:	74 05                	je     800aca <strtol+0x50>
  800ac5:	83 fb 10             	cmp    $0x10,%ebx
  800ac8:	75 18                	jne    800ae2 <strtol+0x68>
  800aca:	80 3a 30             	cmpb   $0x30,(%edx)
  800acd:	75 13                	jne    800ae2 <strtol+0x68>
  800acf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ad3:	75 0d                	jne    800ae2 <strtol+0x68>
		s += 2, base = 16;
  800ad5:	83 c2 02             	add    $0x2,%edx
  800ad8:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800add:	8d 76 00             	lea    0x0(%esi),%esi
  800ae0:	eb 13                	jmp    800af5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae2:	84 c0                	test   %al,%al
  800ae4:	74 0f                	je     800af5 <strtol+0x7b>
  800ae6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aeb:	80 3a 30             	cmpb   $0x30,(%edx)
  800aee:	75 05                	jne    800af5 <strtol+0x7b>
		s++, base = 8;
  800af0:	83 c2 01             	add    $0x1,%edx
  800af3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af5:	b8 00 00 00 00       	mov    $0x0,%eax
  800afa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800afc:	0f b6 0a             	movzbl (%edx),%ecx
  800aff:	89 cf                	mov    %ecx,%edi
  800b01:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b04:	80 fb 09             	cmp    $0x9,%bl
  800b07:	77 08                	ja     800b11 <strtol+0x97>
			dig = *s - '0';
  800b09:	0f be c9             	movsbl %cl,%ecx
  800b0c:	83 e9 30             	sub    $0x30,%ecx
  800b0f:	eb 1e                	jmp    800b2f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b11:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b14:	80 fb 19             	cmp    $0x19,%bl
  800b17:	77 08                	ja     800b21 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800b19:	0f be c9             	movsbl %cl,%ecx
  800b1c:	83 e9 57             	sub    $0x57,%ecx
  800b1f:	eb 0e                	jmp    800b2f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b21:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b24:	80 fb 19             	cmp    $0x19,%bl
  800b27:	77 15                	ja     800b3e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800b29:	0f be c9             	movsbl %cl,%ecx
  800b2c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b2f:	39 f1                	cmp    %esi,%ecx
  800b31:	7d 0b                	jge    800b3e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800b33:	83 c2 01             	add    $0x1,%edx
  800b36:	0f af c6             	imul   %esi,%eax
  800b39:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b3c:	eb be                	jmp    800afc <strtol+0x82>
  800b3e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b44:	74 05                	je     800b4b <strtol+0xd1>
		*endptr = (char *) s;
  800b46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b49:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b4f:	74 04                	je     800b55 <strtol+0xdb>
  800b51:	89 c8                	mov    %ecx,%eax
  800b53:	f7 d8                	neg    %eax
}
  800b55:	83 c4 04             	add    $0x4,%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    
  800b5d:	00 00                	add    %al,(%eax)
	...

00800b60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 0c             	sub    $0xc,%esp
  800b66:	89 1c 24             	mov    %ebx,(%esp)
  800b69:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b6d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b79:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7c:	89 c3                	mov    %eax,%ebx
  800b7e:	89 c7                	mov    %eax,%edi
  800b80:	89 c6                	mov    %eax,%esi
  800b82:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b84:	8b 1c 24             	mov    (%esp),%ebx
  800b87:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b8b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b8f:	89 ec                	mov    %ebp,%esp
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 38             	sub    $0x38,%esp
  800b99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800ba2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ba6:	75 0c                	jne    800bb4 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800ba8:	c7 04 24 a8 14 80 00 	movl   $0x8014a8,(%esp)
  800baf:	e8 b1 f5 ff ff       	call   800165 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb9:	b8 09 00 00 00       	mov    $0x9,%eax
  800bbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc4:	89 df                	mov    %ebx,%edi
  800bc6:	89 de                	mov    %ebx,%esi
  800bc8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	7e 28                	jle    800bf6 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bce:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bd2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800bd9:	00 
  800bda:	c7 44 24 08 d4 14 80 	movl   $0x8014d4,0x8(%esp)
  800be1:	00 
  800be2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800be9:	00 
  800bea:	c7 04 24 f1 14 80 00 	movl   $0x8014f1,(%esp)
  800bf1:	e8 16 03 00 00       	call   800f0c <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800bf6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bf9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bfc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bff:	89 ec                	mov    %ebp,%esp
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	83 ec 38             	sub    $0x38,%esp
  800c09:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c0c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c0f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c12:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c17:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	89 cb                	mov    %ecx,%ebx
  800c21:	89 cf                	mov    %ecx,%edi
  800c23:	89 ce                	mov    %ecx,%esi
  800c25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c27:	85 c0                	test   %eax,%eax
  800c29:	7e 28                	jle    800c53 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c2f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800c36:	00 
  800c37:	c7 44 24 08 d4 14 80 	movl   $0x8014d4,0x8(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c46:	00 
  800c47:	c7 04 24 f1 14 80 00 	movl   $0x8014f1,(%esp)
  800c4e:	e8 b9 02 00 00       	call   800f0c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c53:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c56:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c5c:	89 ec                	mov    %ebp,%esp
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
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
  800c71:	be 00 00 00 00       	mov    $0x0,%esi
  800c76:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c7b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c89:	8b 1c 24             	mov    (%esp),%ebx
  800c8c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c90:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c94:	89 ec                	mov    %ebp,%esp
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	83 ec 38             	sub    $0x38,%esp
  800c9e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ca4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cac:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	89 df                	mov    %ebx,%edi
  800cb9:	89 de                	mov    %ebx,%esi
  800cbb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7e 28                	jle    800ce9 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cc5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ccc:	00 
  800ccd:	c7 44 24 08 d4 14 80 	movl   $0x8014d4,0x8(%esp)
  800cd4:	00 
  800cd5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cdc:	00 
  800cdd:	c7 04 24 f1 14 80 00 	movl   $0x8014f1,(%esp)
  800ce4:	e8 23 02 00 00       	call   800f0c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cf2:	89 ec                	mov    %ebp,%esp
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	83 ec 38             	sub    $0x38,%esp
  800cfc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cff:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d02:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	89 df                	mov    %ebx,%edi
  800d17:	89 de                	mov    %ebx,%esi
  800d19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	7e 28                	jle    800d47 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 08 d4 14 80 	movl   $0x8014d4,0x8(%esp)
  800d32:	00 
  800d33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3a:	00 
  800d3b:	c7 04 24 f1 14 80 00 	movl   $0x8014f1,(%esp)
  800d42:	e8 c5 01 00 00       	call   800f0c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d47:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d4a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d4d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d50:	89 ec                	mov    %ebp,%esp
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 38             	sub    $0x38,%esp
  800d5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d60:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	b8 05 00 00 00       	mov    $0x5,%eax
  800d68:	8b 75 18             	mov    0x18(%ebp),%esi
  800d6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 d4 14 80 	movl   $0x8014d4,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 f1 14 80 00 	movl   $0x8014f1,(%esp)
  800da0:	e8 67 01 00 00       	call   800f0c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800da5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dae:	89 ec                	mov    %ebp,%esp
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	83 ec 38             	sub    $0x38,%esp
  800db8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dbb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbe:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc1:	be 00 00 00 00       	mov    $0x0,%esi
  800dc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	89 f7                	mov    %esi,%edi
  800dd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	7e 28                	jle    800e04 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800de7:	00 
  800de8:	c7 44 24 08 d4 14 80 	movl   $0x8014d4,0x8(%esp)
  800def:	00 
  800df0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df7:	00 
  800df8:	c7 04 24 f1 14 80 00 	movl   $0x8014f1,(%esp)
  800dff:	e8 08 01 00 00       	call   800f0c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e04:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e07:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e0a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e0d:	89 ec                	mov    %ebp,%esp
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	89 1c 24             	mov    %ebx,(%esp)
  800e1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e22:	ba 00 00 00 00       	mov    $0x0,%edx
  800e27:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e2c:	89 d1                	mov    %edx,%ecx
  800e2e:	89 d3                	mov    %edx,%ebx
  800e30:	89 d7                	mov    %edx,%edi
  800e32:	89 d6                	mov    %edx,%esi
  800e34:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e36:	8b 1c 24             	mov    (%esp),%ebx
  800e39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e41:	89 ec                	mov    %ebp,%esp
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	83 ec 0c             	sub    $0xc,%esp
  800e4b:	89 1c 24             	mov    %ebx,(%esp)
  800e4e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e52:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e60:	89 d1                	mov    %edx,%ecx
  800e62:	89 d3                	mov    %edx,%ebx
  800e64:	89 d7                	mov    %edx,%edi
  800e66:	89 d6                	mov    %edx,%esi
  800e68:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e6a:	8b 1c 24             	mov    (%esp),%ebx
  800e6d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e71:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e75:	89 ec                	mov    %ebp,%esp
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    

00800e79 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 38             	sub    $0x38,%esp
  800e7f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e82:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e85:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8d:	b8 03 00 00 00       	mov    $0x3,%eax
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	89 cb                	mov    %ecx,%ebx
  800e97:	89 cf                	mov    %ecx,%edi
  800e99:	89 ce                	mov    %ecx,%esi
  800e9b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	7e 28                	jle    800ec9 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea5:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800eac:	00 
  800ead:	c7 44 24 08 d4 14 80 	movl   $0x8014d4,0x8(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebc:	00 
  800ebd:	c7 04 24 f1 14 80 00 	movl   $0x8014f1,(%esp)
  800ec4:	e8 43 00 00 00       	call   800f0c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ec9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ecc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ecf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed2:	89 ec                	mov    %ebp,%esp
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    

00800ed6 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 0c             	sub    $0xc,%esp
  800edc:	89 1c 24             	mov    %ebx,(%esp)
  800edf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ee3:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee7:	ba 00 00 00 00       	mov    $0x0,%edx
  800eec:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef1:	89 d1                	mov    %edx,%ecx
  800ef3:	89 d3                	mov    %edx,%ebx
  800ef5:	89 d7                	mov    %edx,%edi
  800ef7:	89 d6                	mov    %edx,%esi
  800ef9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800efb:	8b 1c 24             	mov    (%esp),%ebx
  800efe:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f02:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f06:	89 ec                	mov    %ebp,%esp
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    
	...

00800f0c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f14:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f17:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800f1d:	e8 23 ff ff ff       	call   800e45 <sys_getenvid>
  800f22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f25:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f29:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f30:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f38:	c7 04 24 00 15 80 00 	movl   $0x801500,(%esp)
  800f3f:	e8 21 f2 ff ff       	call   800165 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4b:	89 04 24             	mov    %eax,(%esp)
  800f4e:	e8 b1 f1 ff ff       	call   800104 <vcprintf>
	cprintf("\n");
  800f53:	c7 04 24 24 15 80 00 	movl   $0x801524,(%esp)
  800f5a:	e8 06 f2 ff ff       	call   800165 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f5f:	cc                   	int3   
  800f60:	eb fd                	jmp    800f5f <_panic+0x53>
	...

00800f70 <__udivdi3>:
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	83 ec 10             	sub    $0x10,%esp
  800f78:	8b 45 14             	mov    0x14(%ebp),%eax
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	8b 75 10             	mov    0x10(%ebp),%esi
  800f81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f84:	85 c0                	test   %eax,%eax
  800f86:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800f89:	75 35                	jne    800fc0 <__udivdi3+0x50>
  800f8b:	39 fe                	cmp    %edi,%esi
  800f8d:	77 61                	ja     800ff0 <__udivdi3+0x80>
  800f8f:	85 f6                	test   %esi,%esi
  800f91:	75 0b                	jne    800f9e <__udivdi3+0x2e>
  800f93:	b8 01 00 00 00       	mov    $0x1,%eax
  800f98:	31 d2                	xor    %edx,%edx
  800f9a:	f7 f6                	div    %esi
  800f9c:	89 c6                	mov    %eax,%esi
  800f9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  800fa1:	31 d2                	xor    %edx,%edx
  800fa3:	89 f8                	mov    %edi,%eax
  800fa5:	f7 f6                	div    %esi
  800fa7:	89 c7                	mov    %eax,%edi
  800fa9:	89 c8                	mov    %ecx,%eax
  800fab:	f7 f6                	div    %esi
  800fad:	89 c1                	mov    %eax,%ecx
  800faf:	89 fa                	mov    %edi,%edx
  800fb1:	89 c8                	mov    %ecx,%eax
  800fb3:	83 c4 10             	add    $0x10,%esp
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    
  800fba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fc0:	39 f8                	cmp    %edi,%eax
  800fc2:	77 1c                	ja     800fe0 <__udivdi3+0x70>
  800fc4:	0f bd d0             	bsr    %eax,%edx
  800fc7:	83 f2 1f             	xor    $0x1f,%edx
  800fca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800fcd:	75 39                	jne    801008 <__udivdi3+0x98>
  800fcf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  800fd2:	0f 86 a0 00 00 00    	jbe    801078 <__udivdi3+0x108>
  800fd8:	39 f8                	cmp    %edi,%eax
  800fda:	0f 82 98 00 00 00    	jb     801078 <__udivdi3+0x108>
  800fe0:	31 ff                	xor    %edi,%edi
  800fe2:	31 c9                	xor    %ecx,%ecx
  800fe4:	89 c8                	mov    %ecx,%eax
  800fe6:	89 fa                	mov    %edi,%edx
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	5e                   	pop    %esi
  800fec:	5f                   	pop    %edi
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    
  800fef:	90                   	nop
  800ff0:	89 d1                	mov    %edx,%ecx
  800ff2:	89 fa                	mov    %edi,%edx
  800ff4:	89 c8                	mov    %ecx,%eax
  800ff6:	31 ff                	xor    %edi,%edi
  800ff8:	f7 f6                	div    %esi
  800ffa:	89 c1                	mov    %eax,%ecx
  800ffc:	89 fa                	mov    %edi,%edx
  800ffe:	89 c8                	mov    %ecx,%eax
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	5e                   	pop    %esi
  801004:	5f                   	pop    %edi
  801005:	5d                   	pop    %ebp
  801006:	c3                   	ret    
  801007:	90                   	nop
  801008:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80100c:	89 f2                	mov    %esi,%edx
  80100e:	d3 e0                	shl    %cl,%eax
  801010:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801013:	b8 20 00 00 00       	mov    $0x20,%eax
  801018:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80101b:	89 c1                	mov    %eax,%ecx
  80101d:	d3 ea                	shr    %cl,%edx
  80101f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801023:	0b 55 ec             	or     -0x14(%ebp),%edx
  801026:	d3 e6                	shl    %cl,%esi
  801028:	89 c1                	mov    %eax,%ecx
  80102a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80102d:	89 fe                	mov    %edi,%esi
  80102f:	d3 ee                	shr    %cl,%esi
  801031:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801035:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801038:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80103b:	d3 e7                	shl    %cl,%edi
  80103d:	89 c1                	mov    %eax,%ecx
  80103f:	d3 ea                	shr    %cl,%edx
  801041:	09 d7                	or     %edx,%edi
  801043:	89 f2                	mov    %esi,%edx
  801045:	89 f8                	mov    %edi,%eax
  801047:	f7 75 ec             	divl   -0x14(%ebp)
  80104a:	89 d6                	mov    %edx,%esi
  80104c:	89 c7                	mov    %eax,%edi
  80104e:	f7 65 e8             	mull   -0x18(%ebp)
  801051:	39 d6                	cmp    %edx,%esi
  801053:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801056:	72 30                	jb     801088 <__udivdi3+0x118>
  801058:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80105b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80105f:	d3 e2                	shl    %cl,%edx
  801061:	39 c2                	cmp    %eax,%edx
  801063:	73 05                	jae    80106a <__udivdi3+0xfa>
  801065:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801068:	74 1e                	je     801088 <__udivdi3+0x118>
  80106a:	89 f9                	mov    %edi,%ecx
  80106c:	31 ff                	xor    %edi,%edi
  80106e:	e9 71 ff ff ff       	jmp    800fe4 <__udivdi3+0x74>
  801073:	90                   	nop
  801074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801078:	31 ff                	xor    %edi,%edi
  80107a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80107f:	e9 60 ff ff ff       	jmp    800fe4 <__udivdi3+0x74>
  801084:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801088:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80108b:	31 ff                	xor    %edi,%edi
  80108d:	89 c8                	mov    %ecx,%eax
  80108f:	89 fa                	mov    %edi,%edx
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	5e                   	pop    %esi
  801095:	5f                   	pop    %edi
  801096:	5d                   	pop    %ebp
  801097:	c3                   	ret    
	...

008010a0 <__umoddi3>:
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	83 ec 20             	sub    $0x20,%esp
  8010a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8010ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8010b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b4:	85 d2                	test   %edx,%edx
  8010b6:	89 c8                	mov    %ecx,%eax
  8010b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8010bb:	75 13                	jne    8010d0 <__umoddi3+0x30>
  8010bd:	39 f7                	cmp    %esi,%edi
  8010bf:	76 3f                	jbe    801100 <__umoddi3+0x60>
  8010c1:	89 f2                	mov    %esi,%edx
  8010c3:	f7 f7                	div    %edi
  8010c5:	89 d0                	mov    %edx,%eax
  8010c7:	31 d2                	xor    %edx,%edx
  8010c9:	83 c4 20             	add    $0x20,%esp
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    
  8010d0:	39 f2                	cmp    %esi,%edx
  8010d2:	77 4c                	ja     801120 <__umoddi3+0x80>
  8010d4:	0f bd ca             	bsr    %edx,%ecx
  8010d7:	83 f1 1f             	xor    $0x1f,%ecx
  8010da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8010dd:	75 51                	jne    801130 <__umoddi3+0x90>
  8010df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8010e2:	0f 87 e0 00 00 00    	ja     8011c8 <__umoddi3+0x128>
  8010e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010eb:	29 f8                	sub    %edi,%eax
  8010ed:	19 d6                	sbb    %edx,%esi
  8010ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010f5:	89 f2                	mov    %esi,%edx
  8010f7:	83 c4 20             	add    $0x20,%esp
  8010fa:	5e                   	pop    %esi
  8010fb:	5f                   	pop    %edi
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    
  8010fe:	66 90                	xchg   %ax,%ax
  801100:	85 ff                	test   %edi,%edi
  801102:	75 0b                	jne    80110f <__umoddi3+0x6f>
  801104:	b8 01 00 00 00       	mov    $0x1,%eax
  801109:	31 d2                	xor    %edx,%edx
  80110b:	f7 f7                	div    %edi
  80110d:	89 c7                	mov    %eax,%edi
  80110f:	89 f0                	mov    %esi,%eax
  801111:	31 d2                	xor    %edx,%edx
  801113:	f7 f7                	div    %edi
  801115:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801118:	f7 f7                	div    %edi
  80111a:	eb a9                	jmp    8010c5 <__umoddi3+0x25>
  80111c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801120:	89 c8                	mov    %ecx,%eax
  801122:	89 f2                	mov    %esi,%edx
  801124:	83 c4 20             	add    $0x20,%esp
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    
  80112b:	90                   	nop
  80112c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801130:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801134:	d3 e2                	shl    %cl,%edx
  801136:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801139:	ba 20 00 00 00       	mov    $0x20,%edx
  80113e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801141:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801144:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801148:	89 fa                	mov    %edi,%edx
  80114a:	d3 ea                	shr    %cl,%edx
  80114c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801150:	0b 55 f4             	or     -0xc(%ebp),%edx
  801153:	d3 e7                	shl    %cl,%edi
  801155:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801159:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80115c:	89 f2                	mov    %esi,%edx
  80115e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801161:	89 c7                	mov    %eax,%edi
  801163:	d3 ea                	shr    %cl,%edx
  801165:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801169:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	d3 e6                	shl    %cl,%esi
  801170:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801174:	d3 ea                	shr    %cl,%edx
  801176:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80117a:	09 d6                	or     %edx,%esi
  80117c:	89 f0                	mov    %esi,%eax
  80117e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801181:	d3 e7                	shl    %cl,%edi
  801183:	89 f2                	mov    %esi,%edx
  801185:	f7 75 f4             	divl   -0xc(%ebp)
  801188:	89 d6                	mov    %edx,%esi
  80118a:	f7 65 e8             	mull   -0x18(%ebp)
  80118d:	39 d6                	cmp    %edx,%esi
  80118f:	72 2b                	jb     8011bc <__umoddi3+0x11c>
  801191:	39 c7                	cmp    %eax,%edi
  801193:	72 23                	jb     8011b8 <__umoddi3+0x118>
  801195:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801199:	29 c7                	sub    %eax,%edi
  80119b:	19 d6                	sbb    %edx,%esi
  80119d:	89 f0                	mov    %esi,%eax
  80119f:	89 f2                	mov    %esi,%edx
  8011a1:	d3 ef                	shr    %cl,%edi
  8011a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011a7:	d3 e0                	shl    %cl,%eax
  8011a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ad:	09 f8                	or     %edi,%eax
  8011af:	d3 ea                	shr    %cl,%edx
  8011b1:	83 c4 20             	add    $0x20,%esp
  8011b4:	5e                   	pop    %esi
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    
  8011b8:	39 d6                	cmp    %edx,%esi
  8011ba:	75 d9                	jne    801195 <__umoddi3+0xf5>
  8011bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8011bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8011c2:	eb d1                	jmp    801195 <__umoddi3+0xf5>
  8011c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	39 f2                	cmp    %esi,%edx
  8011ca:	0f 82 18 ff ff ff    	jb     8010e8 <__umoddi3+0x48>
  8011d0:	e9 1d ff ff ff       	jmp    8010f2 <__umoddi3+0x52>
