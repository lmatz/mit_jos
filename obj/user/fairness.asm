
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 97 00 00 00       	call   8000c8 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 24 0e 00 00       	call   800e65 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 6d 0f 00 00       	call   800fd7 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  80007c:	e8 0c 01 00 00       	call   80018d <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 31 13 80 00 	movl   $0x801331,(%esp)
  800097:	e8 f1 00 00 00       	call   80018d <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	bb c4 00 c0 ee       	mov    $0xeec000c4,%ebx
  8000a1:	8b 03                	mov    (%ebx),%eax
  8000a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b2:	00 
  8000b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ba:	00 
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 a3 0e 00 00       	call   800f66 <ipc_send>
  8000c3:	eb dc                	jmp    8000a1 <umain+0x6d>
  8000c5:	00 00                	add    %al,(%eax)
	...

008000c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
  8000ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000d1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  8000da:	e8 86 0d 00 00       	call   800e65 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  8000df:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ec:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f1:	85 f6                	test   %esi,%esi
  8000f3:	7e 07                	jle    8000fc <libmain+0x34>
		binaryname = argv[0];
  8000f5:	8b 03                	mov    (%ebx),%eax
  8000f7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800100:	89 34 24             	mov    %esi,(%esp)
  800103:	e8 2c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800108:	e8 0b 00 00 00       	call   800118 <exit>
}
  80010d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800110:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800113:	89 ec                	mov    %ebp,%esp
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    
	...

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800125:	e8 6f 0d 00 00       	call   800e99 <sys_env_destroy>
}
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800135:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013c:	00 00 00 
	b.cnt = 0;
  80013f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800146:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800149:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800150:	8b 45 08             	mov    0x8(%ebp),%eax
  800153:	89 44 24 08          	mov    %eax,0x8(%esp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	c7 04 24 a7 01 80 00 	movl   $0x8001a7,(%esp)
  800168:	e8 c2 01 00 00       	call   80032f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800173:	89 44 24 04          	mov    %eax,0x4(%esp)
  800177:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017d:	89 04 24             	mov    %eax,(%esp)
  800180:	e8 fb 09 00 00       	call   800b80 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 87 ff ff ff       	call   80012c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 14             	sub    $0x14,%esp
  8001ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b1:	8b 03                	mov    (%ebx),%eax
  8001b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ba:	83 c0 01             	add    $0x1,%eax
  8001bd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c4:	75 19                	jne    8001df <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cd:	00 
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 a7 09 00 00       	call   800b80 <sys_cputs>
		b->idx = 0;
  8001d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e3:	83 c4 14             	add    $0x14,%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
  8001e9:	00 00                	add    %al,(%eax)
  8001eb:	00 00                	add    %al,(%eax)
  8001ed:	00 00                	add    %al,(%eax)
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 4c             	sub    $0x4c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d6                	mov    %edx,%esi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	8b 55 0c             	mov    0xc(%ebp),%edx
  800207:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800210:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800216:	b9 00 00 00 00       	mov    $0x0,%ecx
  80021b:	39 d1                	cmp    %edx,%ecx
  80021d:	72 07                	jb     800226 <printnum+0x36>
  80021f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800222:	39 d0                	cmp    %edx,%eax
  800224:	77 69                	ja     80028f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800226:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80022a:	83 eb 01             	sub    $0x1,%ebx
  80022d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800231:	89 44 24 08          	mov    %eax,0x8(%esp)
  800235:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800239:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80023d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800240:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800243:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800246:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800251:	00 
  800252:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800255:	89 04 24             	mov    %eax,(%esp)
  800258:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80025b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80025f:	e8 4c 0e 00 00       	call   8010b0 <__udivdi3>
  800264:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800267:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80026a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80026e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800272:	89 04 24             	mov    %eax,(%esp)
  800275:	89 54 24 04          	mov    %edx,0x4(%esp)
  800279:	89 f2                	mov    %esi,%edx
  80027b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80027e:	e8 6d ff ff ff       	call   8001f0 <printnum>
  800283:	eb 11                	jmp    800296 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	89 74 24 04          	mov    %esi,0x4(%esp)
  800289:	89 3c 24             	mov    %edi,(%esp)
  80028c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f ef                	jg     800285 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	89 74 24 04          	mov    %esi,0x4(%esp)
  80029a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80029e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ac:	00 
  8002ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b0:	89 14 24             	mov    %edx,(%esp)
  8002b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002ba:	e8 21 0f 00 00       	call   8011e0 <__umoddi3>
  8002bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002c3:	0f be 80 52 13 80 00 	movsbl 0x801352(%eax),%eax
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002d0:	83 c4 4c             	add    $0x4c,%esp
  8002d3:	5b                   	pop    %ebx
  8002d4:	5e                   	pop    %esi
  8002d5:	5f                   	pop    %edi
  8002d6:	5d                   	pop    %ebp
  8002d7:	c3                   	ret    

008002d8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d8:	55                   	push   %ebp
  8002d9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002db:	83 fa 01             	cmp    $0x1,%edx
  8002de:	7e 0e                	jle    8002ee <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	8b 52 04             	mov    0x4(%edx),%edx
  8002ec:	eb 22                	jmp    800310 <getuint+0x38>
	else if (lflag)
  8002ee:	85 d2                	test   %edx,%edx
  8002f0:	74 10                	je     800302 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002f2:	8b 10                	mov    (%eax),%edx
  8002f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f7:	89 08                	mov    %ecx,(%eax)
  8002f9:	8b 02                	mov    (%edx),%eax
  8002fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800300:	eb 0e                	jmp    800310 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800302:	8b 10                	mov    (%eax),%edx
  800304:	8d 4a 04             	lea    0x4(%edx),%ecx
  800307:	89 08                	mov    %ecx,(%eax)
  800309:	8b 02                	mov    (%edx),%eax
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800310:	5d                   	pop    %ebp
  800311:	c3                   	ret    

00800312 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800318:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80031c:	8b 10                	mov    (%eax),%edx
  80031e:	3b 50 04             	cmp    0x4(%eax),%edx
  800321:	73 0a                	jae    80032d <sprintputch+0x1b>
		*b->buf++ = ch;
  800323:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800326:	88 0a                	mov    %cl,(%edx)
  800328:	83 c2 01             	add    $0x1,%edx
  80032b:	89 10                	mov    %edx,(%eax)
}
  80032d:	5d                   	pop    %ebp
  80032e:	c3                   	ret    

0080032f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	57                   	push   %edi
  800333:	56                   	push   %esi
  800334:	53                   	push   %ebx
  800335:	83 ec 4c             	sub    $0x4c,%esp
  800338:	8b 7d 08             	mov    0x8(%ebp),%edi
  80033b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80033e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800341:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800348:	eb 11                	jmp    80035b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80034a:	85 c0                	test   %eax,%eax
  80034c:	0f 84 b0 03 00 00    	je     800702 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800352:	89 74 24 04          	mov    %esi,0x4(%esp)
  800356:	89 04 24             	mov    %eax,(%esp)
  800359:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80035b:	0f b6 03             	movzbl (%ebx),%eax
  80035e:	83 c3 01             	add    $0x1,%ebx
  800361:	83 f8 25             	cmp    $0x25,%eax
  800364:	75 e4                	jne    80034a <vprintfmt+0x1b>
  800366:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80036d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800372:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800376:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80037d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800384:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800387:	eb 06                	jmp    80038f <vprintfmt+0x60>
  800389:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80038d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	0f b6 0b             	movzbl (%ebx),%ecx
  800392:	0f b6 c1             	movzbl %cl,%eax
  800395:	8d 53 01             	lea    0x1(%ebx),%edx
  800398:	83 e9 23             	sub    $0x23,%ecx
  80039b:	80 f9 55             	cmp    $0x55,%cl
  80039e:	0f 87 41 03 00 00    	ja     8006e5 <vprintfmt+0x3b6>
  8003a4:	0f b6 c9             	movzbl %cl,%ecx
  8003a7:	ff 24 8d 20 14 80 00 	jmp    *0x801420(,%ecx,4)
  8003ae:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8003b2:	eb d9                	jmp    80038d <vprintfmt+0x5e>
  8003b4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003bb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003c3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003c7:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  8003ca:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003cd:	83 fb 09             	cmp    $0x9,%ebx
  8003d0:	77 2b                	ja     8003fd <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d2:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d5:	eb e9                	jmp    8003c0 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	8d 48 04             	lea    0x4(%eax),%ecx
  8003dd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003e0:	8b 00                	mov    (%eax),%eax
  8003e2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  8003e5:	eb 19                	jmp    800400 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  8003e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ea:	c1 f8 1f             	sar    $0x1f,%eax
  8003ed:	f7 d0                	not    %eax
  8003ef:	21 45 e4             	and    %eax,-0x1c(%ebp)
  8003f2:	eb 99                	jmp    80038d <vprintfmt+0x5e>
  8003f4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003fb:	eb 90                	jmp    80038d <vprintfmt+0x5e>
  8003fd:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800400:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800404:	79 87                	jns    80038d <vprintfmt+0x5e>
  800406:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800409:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80040f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800412:	e9 76 ff ff ff       	jmp    80038d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800417:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80041b:	e9 6d ff ff ff       	jmp    80038d <vprintfmt+0x5e>
  800420:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8d 50 04             	lea    0x4(%eax),%edx
  800429:	89 55 14             	mov    %edx,0x14(%ebp)
  80042c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800430:	8b 00                	mov    (%eax),%eax
  800432:	89 04 24             	mov    %eax,(%esp)
  800435:	ff d7                	call   *%edi
  800437:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80043a:	e9 1c ff ff ff       	jmp    80035b <vprintfmt+0x2c>
  80043f:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 50 04             	lea    0x4(%eax),%edx
  800448:	89 55 14             	mov    %edx,0x14(%ebp)
  80044b:	8b 00                	mov    (%eax),%eax
  80044d:	89 c2                	mov    %eax,%edx
  80044f:	c1 fa 1f             	sar    $0x1f,%edx
  800452:	31 d0                	xor    %edx,%eax
  800454:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800456:	83 f8 09             	cmp    $0x9,%eax
  800459:	7f 0b                	jg     800466 <vprintfmt+0x137>
  80045b:	8b 14 85 80 15 80 00 	mov    0x801580(,%eax,4),%edx
  800462:	85 d2                	test   %edx,%edx
  800464:	75 20                	jne    800486 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800466:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80046a:	c7 44 24 08 63 13 80 	movl   $0x801363,0x8(%esp)
  800471:	00 
  800472:	89 74 24 04          	mov    %esi,0x4(%esp)
  800476:	89 3c 24             	mov    %edi,(%esp)
  800479:	e8 0c 03 00 00       	call   80078a <printfmt>
  80047e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800481:	e9 d5 fe ff ff       	jmp    80035b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800486:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048a:	c7 44 24 08 6c 13 80 	movl   $0x80136c,0x8(%esp)
  800491:	00 
  800492:	89 74 24 04          	mov    %esi,0x4(%esp)
  800496:	89 3c 24             	mov    %edi,(%esp)
  800499:	e8 ec 02 00 00       	call   80078a <printfmt>
  80049e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004a1:	e9 b5 fe ff ff       	jmp    80035b <vprintfmt+0x2c>
  8004a6:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004af:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 50 04             	lea    0x4(%eax),%edx
  8004b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bb:	8b 18                	mov    (%eax),%ebx
  8004bd:	85 db                	test   %ebx,%ebx
  8004bf:	75 05                	jne    8004c6 <vprintfmt+0x197>
  8004c1:	bb 6f 13 80 00       	mov    $0x80136f,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8004c6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ca:	7e 76                	jle    800542 <vprintfmt+0x213>
  8004cc:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8004d0:	74 7a                	je     80054c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d6:	89 1c 24             	mov    %ebx,(%esp)
  8004d9:	e8 fa 02 00 00       	call   8007d8 <strnlen>
  8004de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004e1:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  8004e3:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8004e7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004ea:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004ed:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	eb 0f                	jmp    800500 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	83 eb 01             	sub    $0x1,%ebx
  800500:	85 db                	test   %ebx,%ebx
  800502:	7f ed                	jg     8004f1 <vprintfmt+0x1c2>
  800504:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800507:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80050a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80050d:	89 f7                	mov    %esi,%edi
  80050f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800512:	eb 40                	jmp    800554 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800514:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800518:	74 18                	je     800532 <vprintfmt+0x203>
  80051a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80051d:	83 fa 5e             	cmp    $0x5e,%edx
  800520:	76 10                	jbe    800532 <vprintfmt+0x203>
					putch('?', putdat);
  800522:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800526:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80052d:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800530:	eb 0a                	jmp    80053c <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800532:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800536:	89 04 24             	mov    %eax,(%esp)
  800539:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800540:	eb 12                	jmp    800554 <vprintfmt+0x225>
  800542:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800545:	89 f7                	mov    %esi,%edi
  800547:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80054a:	eb 08                	jmp    800554 <vprintfmt+0x225>
  80054c:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80054f:	89 f7                	mov    %esi,%edi
  800551:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800554:	0f be 03             	movsbl (%ebx),%eax
  800557:	83 c3 01             	add    $0x1,%ebx
  80055a:	85 c0                	test   %eax,%eax
  80055c:	74 25                	je     800583 <vprintfmt+0x254>
  80055e:	85 f6                	test   %esi,%esi
  800560:	78 b2                	js     800514 <vprintfmt+0x1e5>
  800562:	83 ee 01             	sub    $0x1,%esi
  800565:	79 ad                	jns    800514 <vprintfmt+0x1e5>
  800567:	89 fe                	mov    %edi,%esi
  800569:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80056c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80056f:	eb 1a                	jmp    80058b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800571:	89 74 24 04          	mov    %esi,0x4(%esp)
  800575:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80057c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057e:	83 eb 01             	sub    $0x1,%ebx
  800581:	eb 08                	jmp    80058b <vprintfmt+0x25c>
  800583:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800586:	89 fe                	mov    %edi,%esi
  800588:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80058b:	85 db                	test   %ebx,%ebx
  80058d:	7f e2                	jg     800571 <vprintfmt+0x242>
  80058f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800592:	e9 c4 fd ff ff       	jmp    80035b <vprintfmt+0x2c>
  800597:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80059a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059d:	83 f9 01             	cmp    $0x1,%ecx
  8005a0:	7e 16                	jle    8005b8 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 08             	lea    0x8(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 10                	mov    (%eax),%edx
  8005ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b0:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b6:	eb 32                	jmp    8005ea <vprintfmt+0x2bb>
	else if (lflag)
  8005b8:	85 c9                	test   %ecx,%ecx
  8005ba:	74 18                	je     8005d4 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ca:	89 c1                	mov    %eax,%ecx
  8005cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d2:	eb 16                	jmp    8005ea <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e2:	89 c2                	mov    %eax,%edx
  8005e4:	c1 fa 1f             	sar    $0x1f,%edx
  8005e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ea:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005ed:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005f5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f9:	0f 89 a7 00 00 00    	jns    8006a6 <vprintfmt+0x377>
				putch('-', putdat);
  8005ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800603:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060a:	ff d7                	call   *%edi
				num = -(long long) num;
  80060c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80060f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800612:	f7 d9                	neg    %ecx
  800614:	83 d3 00             	adc    $0x0,%ebx
  800617:	f7 db                	neg    %ebx
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 83 00 00 00       	jmp    8006a6 <vprintfmt+0x377>
  800623:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800626:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800629:	89 ca                	mov    %ecx,%edx
  80062b:	8d 45 14             	lea    0x14(%ebp),%eax
  80062e:	e8 a5 fc ff ff       	call   8002d8 <getuint>
  800633:	89 c1                	mov    %eax,%ecx
  800635:	89 d3                	mov    %edx,%ebx
  800637:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80063c:	eb 68                	jmp    8006a6 <vprintfmt+0x377>
  80063e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800641:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800644:	89 ca                	mov    %ecx,%edx
  800646:	8d 45 14             	lea    0x14(%ebp),%eax
  800649:	e8 8a fc ff ff       	call   8002d8 <getuint>
  80064e:	89 c1                	mov    %eax,%ecx
  800650:	89 d3                	mov    %edx,%ebx
  800652:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800657:	eb 4d                	jmp    8006a6 <vprintfmt+0x377>
  800659:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80065c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800660:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800667:	ff d7                	call   *%edi
			putch('x', putdat);
  800669:	89 74 24 04          	mov    %esi,0x4(%esp)
  80066d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800674:	ff d7                	call   *%edi
			num = (unsigned long long)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 50 04             	lea    0x4(%eax),%edx
  80067c:	89 55 14             	mov    %edx,0x14(%ebp)
  80067f:	8b 08                	mov    (%eax),%ecx
  800681:	bb 00 00 00 00       	mov    $0x0,%ebx
  800686:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068b:	eb 19                	jmp    8006a6 <vprintfmt+0x377>
  80068d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800690:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800693:	89 ca                	mov    %ecx,%edx
  800695:	8d 45 14             	lea    0x14(%ebp),%eax
  800698:	e8 3b fc ff ff       	call   8002d8 <getuint>
  80069d:	89 c1                	mov    %eax,%ecx
  80069f:	89 d3                	mov    %edx,%ebx
  8006a1:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a6:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  8006aa:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006b9:	89 0c 24             	mov    %ecx,(%esp)
  8006bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c0:	89 f2                	mov    %esi,%edx
  8006c2:	89 f8                	mov    %edi,%eax
  8006c4:	e8 27 fb ff ff       	call   8001f0 <printnum>
  8006c9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006cc:	e9 8a fc ff ff       	jmp    80035b <vprintfmt+0x2c>
  8006d1:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d8:	89 04 24             	mov    %eax,(%esp)
  8006db:	ff d7                	call   *%edi
  8006dd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006e0:	e9 76 fc ff ff       	jmp    80035b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006f5:	80 38 25             	cmpb   $0x25,(%eax)
  8006f8:	0f 84 5d fc ff ff    	je     80035b <vprintfmt+0x2c>
  8006fe:	89 c3                	mov    %eax,%ebx
  800700:	eb f0                	jmp    8006f2 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800702:	83 c4 4c             	add    $0x4c,%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	83 ec 28             	sub    $0x28,%esp
  800710:	8b 45 08             	mov    0x8(%ebp),%eax
  800713:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800716:	85 c0                	test   %eax,%eax
  800718:	74 04                	je     80071e <vsnprintf+0x14>
  80071a:	85 d2                	test   %edx,%edx
  80071c:	7f 07                	jg     800725 <vsnprintf+0x1b>
  80071e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800723:	eb 3b                	jmp    800760 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800725:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800728:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80072c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80072f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073d:	8b 45 10             	mov    0x10(%ebp),%eax
  800740:	89 44 24 08          	mov    %eax,0x8(%esp)
  800744:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074b:	c7 04 24 12 03 80 00 	movl   $0x800312,(%esp)
  800752:	e8 d8 fb ff ff       	call   80032f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800757:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80076b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076f:	8b 45 10             	mov    0x10(%ebp),%eax
  800772:	89 44 24 08          	mov    %eax,0x8(%esp)
  800776:	8b 45 0c             	mov    0xc(%ebp),%eax
  800779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	e8 82 ff ff ff       	call   80070a <vsnprintf>
	va_end(ap);

	return rc;
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800790:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800793:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800797:	8b 45 10             	mov    0x10(%ebp),%eax
  80079a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	e8 7f fb ff ff       	call   80032f <vprintfmt>
	va_end(ap);
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    
	...

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cb:	eb 03                	jmp    8007d0 <strlen+0x10>
		n++;
  8007cd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d4:	75 f7                	jne    8007cd <strlen+0xd>
		n++;
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e2:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	eb 03                	jmp    8007ec <strnlen+0x14>
		n++;
  8007e9:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ec:	39 c1                	cmp    %eax,%ecx
  8007ee:	74 06                	je     8007f6 <strnlen+0x1e>
  8007f0:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8007f4:	75 f3                	jne    8007e9 <strnlen+0x11>
		n++;
	return n;
}
  8007f6:	5b                   	pop    %ebx
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800803:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800808:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80080c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80080f:	83 c2 01             	add    $0x1,%edx
  800812:	84 c9                	test   %cl,%cl
  800814:	75 f2                	jne    800808 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800816:	5b                   	pop    %ebx
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	83 ec 08             	sub    $0x8,%esp
  800820:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800823:	89 1c 24             	mov    %ebx,(%esp)
  800826:	e8 95 ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800832:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800835:	89 04 24             	mov    %eax,(%esp)
  800838:	e8 bc ff ff ff       	call   8007f9 <strcpy>
	return dst;
}
  80083d:	89 d8                	mov    %ebx,%eax
  80083f:	83 c4 08             	add    $0x8,%esp
  800842:	5b                   	pop    %ebx
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	8b 45 08             	mov    0x8(%ebp),%eax
  80084d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800850:	8b 75 10             	mov    0x10(%ebp),%esi
  800853:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	eb 0f                	jmp    800869 <strncpy+0x24>
		*dst++ = *src;
  80085a:	0f b6 19             	movzbl (%ecx),%ebx
  80085d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800860:	80 39 01             	cmpb   $0x1,(%ecx)
  800863:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800866:	83 c2 01             	add    $0x1,%edx
  800869:	39 f2                	cmp    %esi,%edx
  80086b:	72 ed                	jb     80085a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5d                   	pop    %ebp
  800870:	c3                   	ret    

00800871 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800871:	55                   	push   %ebp
  800872:	89 e5                	mov    %esp,%ebp
  800874:	56                   	push   %esi
  800875:	53                   	push   %ebx
  800876:	8b 75 08             	mov    0x8(%ebp),%esi
  800879:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087f:	89 f0                	mov    %esi,%eax
  800881:	85 d2                	test   %edx,%edx
  800883:	75 0a                	jne    80088f <strlcpy+0x1e>
  800885:	eb 17                	jmp    80089e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800887:	88 18                	mov    %bl,(%eax)
  800889:	83 c0 01             	add    $0x1,%eax
  80088c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80088f:	83 ea 01             	sub    $0x1,%edx
  800892:	74 07                	je     80089b <strlcpy+0x2a>
  800894:	0f b6 19             	movzbl (%ecx),%ebx
  800897:	84 db                	test   %bl,%bl
  800899:	75 ec                	jne    800887 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80089b:	c6 00 00             	movb   $0x0,(%eax)
  80089e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ad:	eb 06                	jmp    8008b5 <strcmp+0x11>
		p++, q++;
  8008af:	83 c1 01             	add    $0x1,%ecx
  8008b2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b5:	0f b6 01             	movzbl (%ecx),%eax
  8008b8:	84 c0                	test   %al,%al
  8008ba:	74 04                	je     8008c0 <strcmp+0x1c>
  8008bc:	3a 02                	cmp    (%edx),%al
  8008be:	74 ef                	je     8008af <strcmp+0xb>
  8008c0:	0f b6 c0             	movzbl %al,%eax
  8008c3:	0f b6 12             	movzbl (%edx),%edx
  8008c6:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	53                   	push   %ebx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d4:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008d7:	eb 09                	jmp    8008e2 <strncmp+0x18>
		n--, p++, q++;
  8008d9:	83 ea 01             	sub    $0x1,%edx
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e2:	85 d2                	test   %edx,%edx
  8008e4:	75 07                	jne    8008ed <strncmp+0x23>
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	eb 13                	jmp    800900 <strncmp+0x36>
  8008ed:	0f b6 18             	movzbl (%eax),%ebx
  8008f0:	84 db                	test   %bl,%bl
  8008f2:	74 04                	je     8008f8 <strncmp+0x2e>
  8008f4:	3a 19                	cmp    (%ecx),%bl
  8008f6:	74 e1                	je     8008d9 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f8:	0f b6 00             	movzbl (%eax),%eax
  8008fb:	0f b6 11             	movzbl (%ecx),%edx
  8008fe:	29 d0                	sub    %edx,%eax
}
  800900:	5b                   	pop    %ebx
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090d:	eb 07                	jmp    800916 <strchr+0x13>
		if (*s == c)
  80090f:	38 ca                	cmp    %cl,%dl
  800911:	74 0f                	je     800922 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	0f b6 10             	movzbl (%eax),%edx
  800919:	84 d2                	test   %dl,%dl
  80091b:	75 f2                	jne    80090f <strchr+0xc>
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092e:	eb 07                	jmp    800937 <strfind+0x13>
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 0a                	je     80093e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	0f b6 10             	movzbl (%eax),%edx
  80093a:	84 d2                	test   %dl,%dl
  80093c:	75 f2                	jne    800930 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  80093e:	5d                   	pop    %ebp
  80093f:	90                   	nop
  800940:	c3                   	ret    

00800941 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 0c             	sub    $0xc,%esp
  800947:	89 1c 24             	mov    %ebx,(%esp)
  80094a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80094e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800952:	8b 7d 08             	mov    0x8(%ebp),%edi
  800955:	8b 45 0c             	mov    0xc(%ebp),%eax
  800958:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80095b:	85 c9                	test   %ecx,%ecx
  80095d:	74 30                	je     80098f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800965:	75 25                	jne    80098c <memset+0x4b>
  800967:	f6 c1 03             	test   $0x3,%cl
  80096a:	75 20                	jne    80098c <memset+0x4b>
		c &= 0xFF;
  80096c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096f:	89 d3                	mov    %edx,%ebx
  800971:	c1 e3 08             	shl    $0x8,%ebx
  800974:	89 d6                	mov    %edx,%esi
  800976:	c1 e6 18             	shl    $0x18,%esi
  800979:	89 d0                	mov    %edx,%eax
  80097b:	c1 e0 10             	shl    $0x10,%eax
  80097e:	09 f0                	or     %esi,%eax
  800980:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800982:	09 d8                	or     %ebx,%eax
  800984:	c1 e9 02             	shr    $0x2,%ecx
  800987:	fc                   	cld    
  800988:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098a:	eb 03                	jmp    80098f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098c:	fc                   	cld    
  80098d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098f:	89 f8                	mov    %edi,%eax
  800991:	8b 1c 24             	mov    (%esp),%ebx
  800994:	8b 74 24 04          	mov    0x4(%esp),%esi
  800998:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80099c:	89 ec                	mov    %ebp,%esp
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	83 ec 08             	sub    $0x8,%esp
  8009a6:	89 34 24             	mov    %esi,(%esp)
  8009a9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8009b3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009b6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009b8:	39 c6                	cmp    %eax,%esi
  8009ba:	73 35                	jae    8009f1 <memmove+0x51>
  8009bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bf:	39 d0                	cmp    %edx,%eax
  8009c1:	73 2e                	jae    8009f1 <memmove+0x51>
		s += n;
		d += n;
  8009c3:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c5:	f6 c2 03             	test   $0x3,%dl
  8009c8:	75 1b                	jne    8009e5 <memmove+0x45>
  8009ca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009d0:	75 13                	jne    8009e5 <memmove+0x45>
  8009d2:	f6 c1 03             	test   $0x3,%cl
  8009d5:	75 0e                	jne    8009e5 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8009d7:	83 ef 04             	sub    $0x4,%edi
  8009da:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009dd:	c1 e9 02             	shr    $0x2,%ecx
  8009e0:	fd                   	std    
  8009e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	eb 09                	jmp    8009ee <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009e5:	83 ef 01             	sub    $0x1,%edi
  8009e8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009eb:	fd                   	std    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ee:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ef:	eb 20                	jmp    800a11 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f7:	75 15                	jne    800a0e <memmove+0x6e>
  8009f9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ff:	75 0d                	jne    800a0e <memmove+0x6e>
  800a01:	f6 c1 03             	test   $0x3,%cl
  800a04:	75 08                	jne    800a0e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a06:	c1 e9 02             	shr    $0x2,%ecx
  800a09:	fc                   	cld    
  800a0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0c:	eb 03                	jmp    800a11 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0e:	fc                   	cld    
  800a0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a11:	8b 34 24             	mov    (%esp),%esi
  800a14:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a18:	89 ec                	mov    %ebp,%esp
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a22:	8b 45 10             	mov    0x10(%ebp),%eax
  800a25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	89 04 24             	mov    %eax,(%esp)
  800a36:	e8 65 ff ff ff       	call   8009a0 <memmove>
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	57                   	push   %edi
  800a41:	56                   	push   %esi
  800a42:	53                   	push   %ebx
  800a43:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a49:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a51:	eb 1c                	jmp    800a6f <memcmp+0x32>
		if (*s1 != *s2)
  800a53:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800a57:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800a5b:	83 c2 01             	add    $0x1,%edx
  800a5e:	83 e9 01             	sub    $0x1,%ecx
  800a61:	38 d8                	cmp    %bl,%al
  800a63:	74 0a                	je     800a6f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800a65:	0f b6 c0             	movzbl %al,%eax
  800a68:	0f b6 db             	movzbl %bl,%ebx
  800a6b:	29 d8                	sub    %ebx,%eax
  800a6d:	eb 09                	jmp    800a78 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6f:	85 c9                	test   %ecx,%ecx
  800a71:	75 e0                	jne    800a53 <memcmp+0x16>
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a86:	89 c2                	mov    %eax,%edx
  800a88:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8b:	eb 07                	jmp    800a94 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8d:	38 08                	cmp    %cl,(%eax)
  800a8f:	74 07                	je     800a98 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a91:	83 c0 01             	add    $0x1,%eax
  800a94:	39 d0                	cmp    %edx,%eax
  800a96:	72 f5                	jb     800a8d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	57                   	push   %edi
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	83 ec 04             	sub    $0x4,%esp
  800aa3:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa9:	eb 03                	jmp    800aae <strtol+0x14>
		s++;
  800aab:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aae:	0f b6 02             	movzbl (%edx),%eax
  800ab1:	3c 20                	cmp    $0x20,%al
  800ab3:	74 f6                	je     800aab <strtol+0x11>
  800ab5:	3c 09                	cmp    $0x9,%al
  800ab7:	74 f2                	je     800aab <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ab9:	3c 2b                	cmp    $0x2b,%al
  800abb:	75 0c                	jne    800ac9 <strtol+0x2f>
		s++;
  800abd:	8d 52 01             	lea    0x1(%edx),%edx
  800ac0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ac7:	eb 15                	jmp    800ade <strtol+0x44>
	else if (*s == '-')
  800ac9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ad0:	3c 2d                	cmp    $0x2d,%al
  800ad2:	75 0a                	jne    800ade <strtol+0x44>
		s++, neg = 1;
  800ad4:	8d 52 01             	lea    0x1(%edx),%edx
  800ad7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ade:	85 db                	test   %ebx,%ebx
  800ae0:	0f 94 c0             	sete   %al
  800ae3:	74 05                	je     800aea <strtol+0x50>
  800ae5:	83 fb 10             	cmp    $0x10,%ebx
  800ae8:	75 18                	jne    800b02 <strtol+0x68>
  800aea:	80 3a 30             	cmpb   $0x30,(%edx)
  800aed:	75 13                	jne    800b02 <strtol+0x68>
  800aef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800af3:	75 0d                	jne    800b02 <strtol+0x68>
		s += 2, base = 16;
  800af5:	83 c2 02             	add    $0x2,%edx
  800af8:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afd:	8d 76 00             	lea    0x0(%esi),%esi
  800b00:	eb 13                	jmp    800b15 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b02:	84 c0                	test   %al,%al
  800b04:	74 0f                	je     800b15 <strtol+0x7b>
  800b06:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b0b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b0e:	75 05                	jne    800b15 <strtol+0x7b>
		s++, base = 8;
  800b10:	83 c2 01             	add    $0x1,%edx
  800b13:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b1c:	0f b6 0a             	movzbl (%edx),%ecx
  800b1f:	89 cf                	mov    %ecx,%edi
  800b21:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b24:	80 fb 09             	cmp    $0x9,%bl
  800b27:	77 08                	ja     800b31 <strtol+0x97>
			dig = *s - '0';
  800b29:	0f be c9             	movsbl %cl,%ecx
  800b2c:	83 e9 30             	sub    $0x30,%ecx
  800b2f:	eb 1e                	jmp    800b4f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b31:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b34:	80 fb 19             	cmp    $0x19,%bl
  800b37:	77 08                	ja     800b41 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800b39:	0f be c9             	movsbl %cl,%ecx
  800b3c:	83 e9 57             	sub    $0x57,%ecx
  800b3f:	eb 0e                	jmp    800b4f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b41:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b44:	80 fb 19             	cmp    $0x19,%bl
  800b47:	77 15                	ja     800b5e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800b49:	0f be c9             	movsbl %cl,%ecx
  800b4c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b4f:	39 f1                	cmp    %esi,%ecx
  800b51:	7d 0b                	jge    800b5e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	0f af c6             	imul   %esi,%eax
  800b59:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b5c:	eb be                	jmp    800b1c <strtol+0x82>
  800b5e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b64:	74 05                	je     800b6b <strtol+0xd1>
		*endptr = (char *) s;
  800b66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b69:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b6f:	74 04                	je     800b75 <strtol+0xdb>
  800b71:	89 c8                	mov    %ecx,%eax
  800b73:	f7 d8                	neg    %eax
}
  800b75:	83 c4 04             	add    $0x4,%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    
  800b7d:	00 00                	add    %al,(%eax)
	...

00800b80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	83 ec 0c             	sub    $0xc,%esp
  800b86:	89 1c 24             	mov    %ebx,(%esp)
  800b89:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b8d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9c:	89 c3                	mov    %eax,%ebx
  800b9e:	89 c7                	mov    %eax,%edi
  800ba0:	89 c6                	mov    %eax,%esi
  800ba2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba4:	8b 1c 24             	mov    (%esp),%ebx
  800ba7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bab:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800baf:	89 ec                	mov    %ebp,%esp
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 38             	sub    $0x38,%esp
  800bb9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bbc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bbf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800bc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc6:	75 0c                	jne    800bd4 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800bc8:	c7 04 24 a8 15 80 00 	movl   $0x8015a8,(%esp)
  800bcf:	e8 b9 f5 ff ff       	call   80018d <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bd9:	b8 09 00 00 00       	mov    $0x9,%eax
  800bde:	8b 55 08             	mov    0x8(%ebp),%edx
  800be1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be4:	89 df                	mov    %ebx,%edi
  800be6:	89 de                	mov    %ebx,%esi
  800be8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7e 28                	jle    800c16 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bee:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bf2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800bf9:	00 
  800bfa:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800c01:	00 
  800c02:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c09:	00 
  800c0a:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800c11:	e8 42 04 00 00       	call   801058 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c16:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c19:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c1c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c1f:	89 ec                	mov    %ebp,%esp
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	83 ec 38             	sub    $0x38,%esp
  800c29:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c2c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c2f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3f:	89 cb                	mov    %ecx,%ebx
  800c41:	89 cf                	mov    %ecx,%edi
  800c43:	89 ce                	mov    %ecx,%esi
  800c45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7e 28                	jle    800c73 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c4f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800c56:	00 
  800c57:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800c5e:	00 
  800c5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c66:	00 
  800c67:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800c6e:	e8 e5 03 00 00       	call   801058 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c73:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c76:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c79:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c7c:	89 ec                	mov    %ebp,%esp
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	89 1c 24             	mov    %ebx,(%esp)
  800c89:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c8d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c91:	be 00 00 00 00       	mov    $0x0,%esi
  800c96:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ca9:	8b 1c 24             	mov    (%esp),%ebx
  800cac:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cb0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cb4:	89 ec                	mov    %ebp,%esp
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	83 ec 38             	sub    $0x38,%esp
  800cbe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccc:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	89 df                	mov    %ebx,%edi
  800cd9:	89 de                	mov    %ebx,%esi
  800cdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdd:	85 c0                	test   %eax,%eax
  800cdf:	7e 28                	jle    800d09 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cec:	00 
  800ced:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800cf4:	00 
  800cf5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfc:	00 
  800cfd:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800d04:	e8 4f 03 00 00       	call   801058 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d09:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d0c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d0f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d12:	89 ec                	mov    %ebp,%esp
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	83 ec 38             	sub    $0x38,%esp
  800d1c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d1f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d22:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 28                	jle    800d67 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d43:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800d52:	00 
  800d53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d5a:	00 
  800d5b:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800d62:	e8 f1 02 00 00       	call   801058 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d67:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d6a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d6d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d70:	89 ec                	mov    %ebp,%esp
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 38             	sub    $0x38,%esp
  800d7a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d7d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d80:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d83:	b8 05 00 00 00       	mov    $0x5,%eax
  800d88:	8b 75 18             	mov    0x18(%ebp),%esi
  800d8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7e 28                	jle    800dc5 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800da1:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800da8:	00 
  800da9:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800db0:	00 
  800db1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800db8:	00 
  800db9:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800dc0:	e8 93 02 00 00       	call   801058 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dc8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dcb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dce:	89 ec                	mov    %ebp,%esp
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	83 ec 38             	sub    $0x38,%esp
  800dd8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ddb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dde:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de1:	be 00 00 00 00       	mov    $0x0,%esi
  800de6:	b8 04 00 00 00       	mov    $0x4,%eax
  800deb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	89 f7                	mov    %esi,%edi
  800df6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	7e 28                	jle    800e24 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e00:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e07:	00 
  800e08:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800e0f:	00 
  800e10:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e17:	00 
  800e18:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800e1f:	e8 34 02 00 00       	call   801058 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e24:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e27:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e2a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e2d:	89 ec                	mov    %ebp,%esp
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	89 1c 24             	mov    %ebx,(%esp)
  800e3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e42:	ba 00 00 00 00       	mov    $0x0,%edx
  800e47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4c:	89 d1                	mov    %edx,%ecx
  800e4e:	89 d3                	mov    %edx,%ebx
  800e50:	89 d7                	mov    %edx,%edi
  800e52:	89 d6                	mov    %edx,%esi
  800e54:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e56:	8b 1c 24             	mov    (%esp),%ebx
  800e59:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e61:	89 ec                	mov    %ebp,%esp
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    

00800e65 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	83 ec 0c             	sub    $0xc,%esp
  800e6b:	89 1c 24             	mov    %ebx,(%esp)
  800e6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e72:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e76:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e80:	89 d1                	mov    %edx,%ecx
  800e82:	89 d3                	mov    %edx,%ebx
  800e84:	89 d7                	mov    %edx,%edi
  800e86:	89 d6                	mov    %edx,%esi
  800e88:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e8a:	8b 1c 24             	mov    (%esp),%ebx
  800e8d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e91:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e95:	89 ec                	mov    %ebp,%esp
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    

00800e99 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 38             	sub    $0x38,%esp
  800e9f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ead:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb2:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb5:	89 cb                	mov    %ecx,%ebx
  800eb7:	89 cf                	mov    %ecx,%edi
  800eb9:	89 ce                	mov    %ecx,%esi
  800ebb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	7e 28                	jle    800ee9 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec5:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800ecc:	00 
  800ecd:	c7 44 24 08 d4 15 80 	movl   $0x8015d4,0x8(%esp)
  800ed4:	00 
  800ed5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800edc:	00 
  800edd:	c7 04 24 f1 15 80 00 	movl   $0x8015f1,(%esp)
  800ee4:	e8 6f 01 00 00       	call   801058 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ee9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eec:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eef:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ef2:	89 ec                	mov    %ebp,%esp
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 0c             	sub    $0xc,%esp
  800efc:	89 1c 24             	mov    %ebx,(%esp)
  800eff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f03:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f07:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f11:	89 d1                	mov    %edx,%ecx
  800f13:	89 d3                	mov    %edx,%ebx
  800f15:	89 d7                	mov    %edx,%edi
  800f17:	89 d6                	mov    %edx,%esi
  800f19:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f1b:	8b 1c 24             	mov    (%esp),%ebx
  800f1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f22:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f26:	89 ec                	mov    %ebp,%esp
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
  800f2a:	00 00                	add    %al,(%eax)
  800f2c:	00 00                	add    %al,(%eax)
	...

00800f30 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f36:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  800f3b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800f3e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  800f44:	8b 12                	mov    (%edx),%edx
  800f46:	39 ca                	cmp    %ecx,%edx
  800f48:	75 0c                	jne    800f56 <ipc_find_env+0x26>
			return envs[i].env_id;
  800f4a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f4d:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  800f52:	8b 00                	mov    (%eax),%eax
  800f54:	eb 0e                	jmp    800f64 <ipc_find_env+0x34>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800f56:	83 c0 01             	add    $0x1,%eax
  800f59:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f5e:	75 db                	jne    800f3b <ipc_find_env+0xb>
  800f60:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  800f64:	5d                   	pop    %ebp
  800f65:	c3                   	ret    

00800f66 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	57                   	push   %edi
  800f6a:	56                   	push   %esi
  800f6b:	53                   	push   %ebx
  800f6c:	83 ec 2c             	sub    $0x2c,%esp
  800f6f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f72:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int res;
	do {
		res=sys_ipc_try_send(to_env,val,pg?pg:(void*)UTOP,perm);
  800f75:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  800f78:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800f7d:	85 f6                	test   %esi,%esi
  800f7f:	74 03                	je     800f84 <ipc_send+0x1e>
  800f81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f84:	8b 55 14             	mov    0x14(%ebp),%edx
  800f87:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f96:	89 3c 24             	mov    %edi,(%esp)
  800f99:	e8 e2 fc ff ff       	call   800c80 <sys_ipc_try_send>
		
		if( res!=0 && res!= -E_IPC_NOT_RECV) {
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	0f 95 c3             	setne  %bl
  800fa3:	74 21                	je     800fc6 <ipc_send+0x60>
  800fa5:	83 f8 f8             	cmp    $0xfffffff8,%eax
  800fa8:	74 1c                	je     800fc6 <ipc_send+0x60>
			panic("ipc_send: error\n");
  800faa:	c7 44 24 08 ff 15 80 	movl   $0x8015ff,0x8(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  800fb9:	00 
  800fba:	c7 04 24 10 16 80 00 	movl   $0x801610,(%esp)
  800fc1:	e8 92 00 00 00       	call   801058 <_panic>
		}
		else {
			sys_yield();	
  800fc6:	e8 66 fe ff ff       	call   800e31 <sys_yield>
		}
	} while(res!=0);
  800fcb:	84 db                	test   %bl,%bl
  800fcd:	75 a9                	jne    800f78 <ipc_send+0x12>
	
	
//	panic("ipc_send not implemented");
}
  800fcf:	83 c4 2c             	add    $0x2c,%esp
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 28             	sub    $0x28,%esp
  800fdd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fe0:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fe3:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fe6:	8b 75 08             	mov    0x8(%ebp),%esi
  800fe9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fec:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int res;

	res=sys_ipc_recv( pg?pg:(void*)UTOP);
  800fef:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  800ff4:	85 db                	test   %ebx,%ebx
  800ff6:	74 02                	je     800ffa <ipc_recv+0x23>
  800ff8:	89 d8                	mov    %ebx,%eax
  800ffa:	89 04 24             	mov    %eax,(%esp)
  800ffd:	e8 21 fc ff ff       	call   800c23 <sys_ipc_recv>

	if( from_env_store) {
  801002:	85 f6                	test   %esi,%esi
  801004:	74 14                	je     80101a <ipc_recv+0x43>
		*from_env_store = (res==0)? thisenv->env_ipc_from:0;
  801006:	ba 00 00 00 00       	mov    $0x0,%edx
  80100b:	85 c0                	test   %eax,%eax
  80100d:	75 09                	jne    801018 <ipc_recv+0x41>
  80100f:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801015:	8b 52 74             	mov    0x74(%edx),%edx
  801018:	89 16                	mov    %edx,(%esi)
	}

	if( perm_store) {
  80101a:	85 ff                	test   %edi,%edi
  80101c:	74 1f                	je     80103d <ipc_recv+0x66>
		*perm_store = (res==0 && (uint32_t)pg < UTOP)? thisenv->env_ipc_perm:0;
  80101e:	85 c0                	test   %eax,%eax
  801020:	75 08                	jne    80102a <ipc_recv+0x53>
  801022:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801028:	76 08                	jbe    801032 <ipc_recv+0x5b>
  80102a:	ba 00 00 00 00       	mov    $0x0,%edx
  80102f:	90                   	nop
  801030:	eb 09                	jmp    80103b <ipc_recv+0x64>
  801032:	8b 15 04 20 80 00    	mov    0x802004,%edx
  801038:	8b 52 78             	mov    0x78(%edx),%edx
  80103b:	89 17                	mov    %edx,(%edi)
	}
	
	if( res) {
  80103d:	85 c0                	test   %eax,%eax
  80103f:	75 08                	jne    801049 <ipc_recv+0x72>
		return res;
	}
	
//	panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801041:	a1 04 20 80 00       	mov    0x802004,%eax
  801046:	8b 40 70             	mov    0x70(%eax),%eax
}
  801049:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80104c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80104f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801052:	89 ec                	mov    %ebp,%esp
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    
	...

00801058 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
  80105d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801060:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801063:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801069:	e8 f7 fd ff ff       	call   800e65 <sys_getenvid>
  80106e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801071:	89 54 24 10          	mov    %edx,0x10(%esp)
  801075:	8b 55 08             	mov    0x8(%ebp),%edx
  801078:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80107c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801080:	89 44 24 04          	mov    %eax,0x4(%esp)
  801084:	c7 04 24 1c 16 80 00 	movl   $0x80161c,(%esp)
  80108b:	e8 fd f0 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801090:	89 74 24 04          	mov    %esi,0x4(%esp)
  801094:	8b 45 10             	mov    0x10(%ebp),%eax
  801097:	89 04 24             	mov    %eax,(%esp)
  80109a:	e8 8d f0 ff ff       	call   80012c <vcprintf>
	cprintf("\n");
  80109f:	c7 04 24 0e 16 80 00 	movl   $0x80160e,(%esp)
  8010a6:	e8 e2 f0 ff ff       	call   80018d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ab:	cc                   	int3   
  8010ac:	eb fd                	jmp    8010ab <_panic+0x53>
	...

008010b0 <__udivdi3>:
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	83 ec 10             	sub    $0x10,%esp
  8010b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8010bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010be:	8b 75 10             	mov    0x10(%ebp),%esi
  8010c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8010c9:	75 35                	jne    801100 <__udivdi3+0x50>
  8010cb:	39 fe                	cmp    %edi,%esi
  8010cd:	77 61                	ja     801130 <__udivdi3+0x80>
  8010cf:	85 f6                	test   %esi,%esi
  8010d1:	75 0b                	jne    8010de <__udivdi3+0x2e>
  8010d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d8:	31 d2                	xor    %edx,%edx
  8010da:	f7 f6                	div    %esi
  8010dc:	89 c6                	mov    %eax,%esi
  8010de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8010e1:	31 d2                	xor    %edx,%edx
  8010e3:	89 f8                	mov    %edi,%eax
  8010e5:	f7 f6                	div    %esi
  8010e7:	89 c7                	mov    %eax,%edi
  8010e9:	89 c8                	mov    %ecx,%eax
  8010eb:	f7 f6                	div    %esi
  8010ed:	89 c1                	mov    %eax,%ecx
  8010ef:	89 fa                	mov    %edi,%edx
  8010f1:	89 c8                	mov    %ecx,%eax
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	5e                   	pop    %esi
  8010f7:	5f                   	pop    %edi
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    
  8010fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801100:	39 f8                	cmp    %edi,%eax
  801102:	77 1c                	ja     801120 <__udivdi3+0x70>
  801104:	0f bd d0             	bsr    %eax,%edx
  801107:	83 f2 1f             	xor    $0x1f,%edx
  80110a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80110d:	75 39                	jne    801148 <__udivdi3+0x98>
  80110f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801112:	0f 86 a0 00 00 00    	jbe    8011b8 <__udivdi3+0x108>
  801118:	39 f8                	cmp    %edi,%eax
  80111a:	0f 82 98 00 00 00    	jb     8011b8 <__udivdi3+0x108>
  801120:	31 ff                	xor    %edi,%edi
  801122:	31 c9                	xor    %ecx,%ecx
  801124:	89 c8                	mov    %ecx,%eax
  801126:	89 fa                	mov    %edi,%edx
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    
  80112f:	90                   	nop
  801130:	89 d1                	mov    %edx,%ecx
  801132:	89 fa                	mov    %edi,%edx
  801134:	89 c8                	mov    %ecx,%eax
  801136:	31 ff                	xor    %edi,%edi
  801138:	f7 f6                	div    %esi
  80113a:	89 c1                	mov    %eax,%ecx
  80113c:	89 fa                	mov    %edi,%edx
  80113e:	89 c8                	mov    %ecx,%eax
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	5e                   	pop    %esi
  801144:	5f                   	pop    %edi
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    
  801147:	90                   	nop
  801148:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80114c:	89 f2                	mov    %esi,%edx
  80114e:	d3 e0                	shl    %cl,%eax
  801150:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801153:	b8 20 00 00 00       	mov    $0x20,%eax
  801158:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80115b:	89 c1                	mov    %eax,%ecx
  80115d:	d3 ea                	shr    %cl,%edx
  80115f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801163:	0b 55 ec             	or     -0x14(%ebp),%edx
  801166:	d3 e6                	shl    %cl,%esi
  801168:	89 c1                	mov    %eax,%ecx
  80116a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80116d:	89 fe                	mov    %edi,%esi
  80116f:	d3 ee                	shr    %cl,%esi
  801171:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801175:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801178:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80117b:	d3 e7                	shl    %cl,%edi
  80117d:	89 c1                	mov    %eax,%ecx
  80117f:	d3 ea                	shr    %cl,%edx
  801181:	09 d7                	or     %edx,%edi
  801183:	89 f2                	mov    %esi,%edx
  801185:	89 f8                	mov    %edi,%eax
  801187:	f7 75 ec             	divl   -0x14(%ebp)
  80118a:	89 d6                	mov    %edx,%esi
  80118c:	89 c7                	mov    %eax,%edi
  80118e:	f7 65 e8             	mull   -0x18(%ebp)
  801191:	39 d6                	cmp    %edx,%esi
  801193:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801196:	72 30                	jb     8011c8 <__udivdi3+0x118>
  801198:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80119f:	d3 e2                	shl    %cl,%edx
  8011a1:	39 c2                	cmp    %eax,%edx
  8011a3:	73 05                	jae    8011aa <__udivdi3+0xfa>
  8011a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8011a8:	74 1e                	je     8011c8 <__udivdi3+0x118>
  8011aa:	89 f9                	mov    %edi,%ecx
  8011ac:	31 ff                	xor    %edi,%edi
  8011ae:	e9 71 ff ff ff       	jmp    801124 <__udivdi3+0x74>
  8011b3:	90                   	nop
  8011b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b8:	31 ff                	xor    %edi,%edi
  8011ba:	b9 01 00 00 00       	mov    $0x1,%ecx
  8011bf:	e9 60 ff ff ff       	jmp    801124 <__udivdi3+0x74>
  8011c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8011cb:	31 ff                	xor    %edi,%edi
  8011cd:	89 c8                	mov    %ecx,%eax
  8011cf:	89 fa                	mov    %edi,%edx
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    
	...

008011e0 <__umoddi3>:
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	83 ec 20             	sub    $0x20,%esp
  8011e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8011eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011f4:	85 d2                	test   %edx,%edx
  8011f6:	89 c8                	mov    %ecx,%eax
  8011f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8011fb:	75 13                	jne    801210 <__umoddi3+0x30>
  8011fd:	39 f7                	cmp    %esi,%edi
  8011ff:	76 3f                	jbe    801240 <__umoddi3+0x60>
  801201:	89 f2                	mov    %esi,%edx
  801203:	f7 f7                	div    %edi
  801205:	89 d0                	mov    %edx,%eax
  801207:	31 d2                	xor    %edx,%edx
  801209:	83 c4 20             	add    $0x20,%esp
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    
  801210:	39 f2                	cmp    %esi,%edx
  801212:	77 4c                	ja     801260 <__umoddi3+0x80>
  801214:	0f bd ca             	bsr    %edx,%ecx
  801217:	83 f1 1f             	xor    $0x1f,%ecx
  80121a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80121d:	75 51                	jne    801270 <__umoddi3+0x90>
  80121f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801222:	0f 87 e0 00 00 00    	ja     801308 <__umoddi3+0x128>
  801228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122b:	29 f8                	sub    %edi,%eax
  80122d:	19 d6                	sbb    %edx,%esi
  80122f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801232:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801235:	89 f2                	mov    %esi,%edx
  801237:	83 c4 20             	add    $0x20,%esp
  80123a:	5e                   	pop    %esi
  80123b:	5f                   	pop    %edi
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    
  80123e:	66 90                	xchg   %ax,%ax
  801240:	85 ff                	test   %edi,%edi
  801242:	75 0b                	jne    80124f <__umoddi3+0x6f>
  801244:	b8 01 00 00 00       	mov    $0x1,%eax
  801249:	31 d2                	xor    %edx,%edx
  80124b:	f7 f7                	div    %edi
  80124d:	89 c7                	mov    %eax,%edi
  80124f:	89 f0                	mov    %esi,%eax
  801251:	31 d2                	xor    %edx,%edx
  801253:	f7 f7                	div    %edi
  801255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801258:	f7 f7                	div    %edi
  80125a:	eb a9                	jmp    801205 <__umoddi3+0x25>
  80125c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801260:	89 c8                	mov    %ecx,%eax
  801262:	89 f2                	mov    %esi,%edx
  801264:	83 c4 20             	add    $0x20,%esp
  801267:	5e                   	pop    %esi
  801268:	5f                   	pop    %edi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    
  80126b:	90                   	nop
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801274:	d3 e2                	shl    %cl,%edx
  801276:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801279:	ba 20 00 00 00       	mov    $0x20,%edx
  80127e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801281:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801284:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801288:	89 fa                	mov    %edi,%edx
  80128a:	d3 ea                	shr    %cl,%edx
  80128c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801290:	0b 55 f4             	or     -0xc(%ebp),%edx
  801293:	d3 e7                	shl    %cl,%edi
  801295:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801299:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80129c:	89 f2                	mov    %esi,%edx
  80129e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8012a1:	89 c7                	mov    %eax,%edi
  8012a3:	d3 ea                	shr    %cl,%edx
  8012a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	d3 e6                	shl    %cl,%esi
  8012b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012b4:	d3 ea                	shr    %cl,%edx
  8012b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012ba:	09 d6                	or     %edx,%esi
  8012bc:	89 f0                	mov    %esi,%eax
  8012be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8012c1:	d3 e7                	shl    %cl,%edi
  8012c3:	89 f2                	mov    %esi,%edx
  8012c5:	f7 75 f4             	divl   -0xc(%ebp)
  8012c8:	89 d6                	mov    %edx,%esi
  8012ca:	f7 65 e8             	mull   -0x18(%ebp)
  8012cd:	39 d6                	cmp    %edx,%esi
  8012cf:	72 2b                	jb     8012fc <__umoddi3+0x11c>
  8012d1:	39 c7                	cmp    %eax,%edi
  8012d3:	72 23                	jb     8012f8 <__umoddi3+0x118>
  8012d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012d9:	29 c7                	sub    %eax,%edi
  8012db:	19 d6                	sbb    %edx,%esi
  8012dd:	89 f0                	mov    %esi,%eax
  8012df:	89 f2                	mov    %esi,%edx
  8012e1:	d3 ef                	shr    %cl,%edi
  8012e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012e7:	d3 e0                	shl    %cl,%eax
  8012e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012ed:	09 f8                	or     %edi,%eax
  8012ef:	d3 ea                	shr    %cl,%edx
  8012f1:	83 c4 20             	add    $0x20,%esp
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    
  8012f8:	39 d6                	cmp    %edx,%esi
  8012fa:	75 d9                	jne    8012d5 <__umoddi3+0xf5>
  8012fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8012ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801302:	eb d1                	jmp    8012d5 <__umoddi3+0xf5>
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	39 f2                	cmp    %esi,%edx
  80130a:	0f 82 18 ff ff ff    	jb     801228 <__umoddi3+0x48>
  801310:	e9 1d ff ff ff       	jmp    801232 <__umoddi3+0x52>
