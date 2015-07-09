
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
	sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  800046:	c7 04 24 5e 00 80 00 	movl   $0x80005e,(%esp)
  80004d:	e8 aa 0e 00 00       	call   800efc <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800052:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800059:	00 00 00 
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 18             	sub    $0x18,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800067:	8b 50 04             	mov    0x4(%eax),%edx
  80006a:	83 e2 07             	and    $0x7,%edx
  80006d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800071:	8b 00                	mov    (%eax),%eax
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  80007e:	e8 d6 00 00 00       	call   800159 <cprintf>
	sys_env_destroy(sys_getenvid());
  800083:	e8 ad 0d 00 00       	call   800e35 <sys_getenvid>
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 d9 0d 00 00       	call   800e69 <sys_env_destroy>
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  8000a6:	e8 8a 0d 00 00       	call   800e35 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 f6                	test   %esi,%esi
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 03                	mov    (%ebx),%eax
  8000c3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cc:	89 34 24             	mov    %esi,(%esp)
  8000cf:	e8 6c ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000dc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f1:	e8 73 0d 00 00       	call   800e69 <sys_env_destroy>
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    

008000f8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800101:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800108:	00 00 00 
	b.cnt = 0;
  80010b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800112:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800115:	8b 45 0c             	mov    0xc(%ebp),%eax
  800118:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80011c:	8b 45 08             	mov    0x8(%ebp),%eax
  80011f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012d:	c7 04 24 73 01 80 00 	movl   $0x800173,(%esp)
  800134:	e8 c6 01 00 00       	call   8002ff <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800139:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80013f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800143:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800149:	89 04 24             	mov    %eax,(%esp)
  80014c:	e8 ff 09 00 00       	call   800b50 <sys_cputs>

	return b.cnt;
}
  800151:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80015f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800162:	89 44 24 04          	mov    %eax,0x4(%esp)
  800166:	8b 45 08             	mov    0x8(%ebp),%eax
  800169:	89 04 24             	mov    %eax,(%esp)
  80016c:	e8 87 ff ff ff       	call   8000f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	53                   	push   %ebx
  800177:	83 ec 14             	sub    $0x14,%esp
  80017a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	8b 55 08             	mov    0x8(%ebp),%edx
  800182:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800186:	83 c0 01             	add    $0x1,%eax
  800189:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80018b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800190:	75 19                	jne    8001ab <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800192:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800199:	00 
  80019a:	8d 43 08             	lea    0x8(%ebx),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 ab 09 00 00       	call   800b50 <sys_cputs>
		b->idx = 0;
  8001a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001af:	83 c4 14             	add    $0x14,%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 4c             	sub    $0x4c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001eb:	39 d1                	cmp    %edx,%ecx
  8001ed:	72 07                	jb     8001f6 <printnum+0x36>
  8001ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001f2:	39 d0                	cmp    %edx,%eax
  8001f4:	77 69                	ja     80025f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001fa:	83 eb 01             	sub    $0x1,%ebx
  8001fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800201:	89 44 24 08          	mov    %eax,0x8(%esp)
  800205:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800209:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80020d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800210:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800213:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800216:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80021a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800221:	00 
  800222:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80022b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80022f:	e8 bc 0d 00 00       	call   800ff0 <__udivdi3>
  800234:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800237:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80023a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80023e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800242:	89 04 24             	mov    %eax,(%esp)
  800245:	89 54 24 04          	mov    %edx,0x4(%esp)
  800249:	89 f2                	mov    %esi,%edx
  80024b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80024e:	e8 6d ff ff ff       	call   8001c0 <printnum>
  800253:	eb 11                	jmp    800266 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	89 74 24 04          	mov    %esi,0x4(%esp)
  800259:	89 3c 24             	mov    %edi,(%esp)
  80025c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80025f:	83 eb 01             	sub    $0x1,%ebx
  800262:	85 db                	test   %ebx,%ebx
  800264:	7f ef                	jg     800255 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80026a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80026e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800271:	89 44 24 08          	mov    %eax,0x8(%esp)
  800275:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027c:	00 
  80027d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800280:	89 14 24             	mov    %edx,(%esp)
  800283:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800286:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80028a:	e8 91 0e 00 00       	call   801120 <__umoddi3>
  80028f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800293:	0f be 80 86 12 80 00 	movsbl 0x801286(%eax),%eax
  80029a:	89 04 24             	mov    %eax,(%esp)
  80029d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002a0:	83 c4 4c             	add    $0x4c,%esp
  8002a3:	5b                   	pop    %ebx
  8002a4:	5e                   	pop    %esi
  8002a5:	5f                   	pop    %edi
  8002a6:	5d                   	pop    %ebp
  8002a7:	c3                   	ret    

008002a8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ab:	83 fa 01             	cmp    $0x1,%edx
  8002ae:	7e 0e                	jle    8002be <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	8b 52 04             	mov    0x4(%edx),%edx
  8002bc:	eb 22                	jmp    8002e0 <getuint+0x38>
	else if (lflag)
  8002be:	85 d2                	test   %edx,%edx
  8002c0:	74 10                	je     8002d2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 02                	mov    (%edx),%eax
  8002cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d0:	eb 0e                	jmp    8002e0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002d2:	8b 10                	mov    (%eax),%edx
  8002d4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 02                	mov    (%edx),%eax
  8002db:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ec:	8b 10                	mov    (%eax),%edx
  8002ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f1:	73 0a                	jae    8002fd <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f6:	88 0a                	mov    %cl,(%edx)
  8002f8:	83 c2 01             	add    $0x1,%edx
  8002fb:	89 10                	mov    %edx,(%eax)
}
  8002fd:	5d                   	pop    %ebp
  8002fe:	c3                   	ret    

008002ff <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ff:	55                   	push   %ebp
  800300:	89 e5                	mov    %esp,%ebp
  800302:	57                   	push   %edi
  800303:	56                   	push   %esi
  800304:	53                   	push   %ebx
  800305:	83 ec 4c             	sub    $0x4c,%esp
  800308:	8b 7d 08             	mov    0x8(%ebp),%edi
  80030b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80030e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800311:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800318:	eb 11                	jmp    80032b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80031a:	85 c0                	test   %eax,%eax
  80031c:	0f 84 b0 03 00 00    	je     8006d2 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800322:	89 74 24 04          	mov    %esi,0x4(%esp)
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032b:	0f b6 03             	movzbl (%ebx),%eax
  80032e:	83 c3 01             	add    $0x1,%ebx
  800331:	83 f8 25             	cmp    $0x25,%eax
  800334:	75 e4                	jne    80031a <vprintfmt+0x1b>
  800336:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800346:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80034d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800354:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800357:	eb 06                	jmp    80035f <vprintfmt+0x60>
  800359:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80035d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	0f b6 0b             	movzbl (%ebx),%ecx
  800362:	0f b6 c1             	movzbl %cl,%eax
  800365:	8d 53 01             	lea    0x1(%ebx),%edx
  800368:	83 e9 23             	sub    $0x23,%ecx
  80036b:	80 f9 55             	cmp    $0x55,%cl
  80036e:	0f 87 41 03 00 00    	ja     8006b5 <vprintfmt+0x3b6>
  800374:	0f b6 c9             	movzbl %cl,%ecx
  800377:	ff 24 8d 40 13 80 00 	jmp    *0x801340(,%ecx,4)
  80037e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800382:	eb d9                	jmp    80035d <vprintfmt+0x5e>
  800384:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80038b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800390:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800393:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800397:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80039a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80039d:	83 fb 09             	cmp    $0x9,%ebx
  8003a0:	77 2b                	ja     8003cd <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a2:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a5:	eb e9                	jmp    800390 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003aa:	8d 48 04             	lea    0x4(%eax),%ecx
  8003ad:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  8003b5:	eb 19                	jmp    8003d0 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  8003b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ba:	c1 f8 1f             	sar    $0x1f,%eax
  8003bd:	f7 d0                	not    %eax
  8003bf:	21 45 e4             	and    %eax,-0x1c(%ebp)
  8003c2:	eb 99                	jmp    80035d <vprintfmt+0x5e>
  8003c4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003cb:	eb 90                	jmp    80035d <vprintfmt+0x5e>
  8003cd:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  8003d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003d4:	79 87                	jns    80035d <vprintfmt+0x5e>
  8003d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003df:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003e2:	e9 76 ff ff ff       	jmp    80035d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003eb:	e9 6d ff ff ff       	jmp    80035d <vprintfmt+0x5e>
  8003f0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 50 04             	lea    0x4(%eax),%edx
  8003f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8003fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800400:	8b 00                	mov    (%eax),%eax
  800402:	89 04 24             	mov    %eax,(%esp)
  800405:	ff d7                	call   *%edi
  800407:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80040a:	e9 1c ff ff ff       	jmp    80032b <vprintfmt+0x2c>
  80040f:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 50 04             	lea    0x4(%eax),%edx
  800418:	89 55 14             	mov    %edx,0x14(%ebp)
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	89 c2                	mov    %eax,%edx
  80041f:	c1 fa 1f             	sar    $0x1f,%edx
  800422:	31 d0                	xor    %edx,%eax
  800424:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800426:	83 f8 09             	cmp    $0x9,%eax
  800429:	7f 0b                	jg     800436 <vprintfmt+0x137>
  80042b:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  800432:	85 d2                	test   %edx,%edx
  800434:	75 20                	jne    800456 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800436:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80043a:	c7 44 24 08 97 12 80 	movl   $0x801297,0x8(%esp)
  800441:	00 
  800442:	89 74 24 04          	mov    %esi,0x4(%esp)
  800446:	89 3c 24             	mov    %edi,(%esp)
  800449:	e8 0c 03 00 00       	call   80075a <printfmt>
  80044e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800451:	e9 d5 fe ff ff       	jmp    80032b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800456:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045a:	c7 44 24 08 a0 12 80 	movl   $0x8012a0,0x8(%esp)
  800461:	00 
  800462:	89 74 24 04          	mov    %esi,0x4(%esp)
  800466:	89 3c 24             	mov    %edi,(%esp)
  800469:	e8 ec 02 00 00       	call   80075a <printfmt>
  80046e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800471:	e9 b5 fe ff ff       	jmp    80032b <vprintfmt+0x2c>
  800476:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80047c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80047f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	89 55 14             	mov    %edx,0x14(%ebp)
  80048b:	8b 18                	mov    (%eax),%ebx
  80048d:	85 db                	test   %ebx,%ebx
  80048f:	75 05                	jne    800496 <vprintfmt+0x197>
  800491:	bb a3 12 80 00       	mov    $0x8012a3,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800496:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80049a:	7e 76                	jle    800512 <vprintfmt+0x213>
  80049c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8004a0:	74 7a                	je     80051c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a6:	89 1c 24             	mov    %ebx,(%esp)
  8004a9:	e8 fa 02 00 00       	call   8007a8 <strnlen>
  8004ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004b1:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  8004b3:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8004b7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004ba:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8004bd:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bf:	eb 0f                	jmp    8004d0 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	83 eb 01             	sub    $0x1,%ebx
  8004d0:	85 db                	test   %ebx,%ebx
  8004d2:	7f ed                	jg     8004c1 <vprintfmt+0x1c2>
  8004d4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8004d7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004da:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8004dd:	89 f7                	mov    %esi,%edi
  8004df:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8004e2:	eb 40                	jmp    800524 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e8:	74 18                	je     800502 <vprintfmt+0x203>
  8004ea:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004ed:	83 fa 5e             	cmp    $0x5e,%edx
  8004f0:	76 10                	jbe    800502 <vprintfmt+0x203>
					putch('?', putdat);
  8004f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8004fd:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800500:	eb 0a                	jmp    80050c <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800502:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800510:	eb 12                	jmp    800524 <vprintfmt+0x225>
  800512:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800515:	89 f7                	mov    %esi,%edi
  800517:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80051a:	eb 08                	jmp    800524 <vprintfmt+0x225>
  80051c:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80051f:	89 f7                	mov    %esi,%edi
  800521:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800524:	0f be 03             	movsbl (%ebx),%eax
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	85 c0                	test   %eax,%eax
  80052c:	74 25                	je     800553 <vprintfmt+0x254>
  80052e:	85 f6                	test   %esi,%esi
  800530:	78 b2                	js     8004e4 <vprintfmt+0x1e5>
  800532:	83 ee 01             	sub    $0x1,%esi
  800535:	79 ad                	jns    8004e4 <vprintfmt+0x1e5>
  800537:	89 fe                	mov    %edi,%esi
  800539:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80053c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80053f:	eb 1a                	jmp    80055b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800541:	89 74 24 04          	mov    %esi,0x4(%esp)
  800545:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80054c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054e:	83 eb 01             	sub    $0x1,%ebx
  800551:	eb 08                	jmp    80055b <vprintfmt+0x25c>
  800553:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800556:	89 fe                	mov    %edi,%esi
  800558:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80055b:	85 db                	test   %ebx,%ebx
  80055d:	7f e2                	jg     800541 <vprintfmt+0x242>
  80055f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800562:	e9 c4 fd ff ff       	jmp    80032b <vprintfmt+0x2c>
  800567:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80056a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80056d:	83 f9 01             	cmp    $0x1,%ecx
  800570:	7e 16                	jle    800588 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 08             	lea    0x8(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 10                	mov    (%eax),%edx
  80057d:	8b 48 04             	mov    0x4(%eax),%ecx
  800580:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800583:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800586:	eb 32                	jmp    8005ba <vprintfmt+0x2bb>
	else if (lflag)
  800588:	85 c9                	test   %ecx,%ecx
  80058a:	74 18                	je     8005a4 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8d 50 04             	lea    0x4(%eax),%edx
  800592:	89 55 14             	mov    %edx,0x14(%ebp)
  800595:	8b 00                	mov    (%eax),%eax
  800597:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059a:	89 c1                	mov    %eax,%ecx
  80059c:	c1 f9 1f             	sar    $0x1f,%ecx
  80059f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a2:	eb 16                	jmp    8005ba <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 50 04             	lea    0x4(%eax),%edx
  8005aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b2:	89 c2                	mov    %eax,%edx
  8005b4:	c1 fa 1f             	sar    $0x1f,%edx
  8005b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ba:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005bd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005c0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005c5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005c9:	0f 89 a7 00 00 00    	jns    800676 <vprintfmt+0x377>
				putch('-', putdat);
  8005cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005da:	ff d7                	call   *%edi
				num = -(long long) num;
  8005dc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005df:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005e2:	f7 d9                	neg    %ecx
  8005e4:	83 d3 00             	adc    $0x0,%ebx
  8005e7:	f7 db                	neg    %ebx
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ee:	e9 83 00 00 00       	jmp    800676 <vprintfmt+0x377>
  8005f3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005f6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f9:	89 ca                	mov    %ecx,%edx
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 a5 fc ff ff       	call   8002a8 <getuint>
  800603:	89 c1                	mov    %eax,%ecx
  800605:	89 d3                	mov    %edx,%ebx
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80060c:	eb 68                	jmp    800676 <vprintfmt+0x377>
  80060e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800611:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800614:	89 ca                	mov    %ecx,%edx
  800616:	8d 45 14             	lea    0x14(%ebp),%eax
  800619:	e8 8a fc ff ff       	call   8002a8 <getuint>
  80061e:	89 c1                	mov    %eax,%ecx
  800620:	89 d3                	mov    %edx,%ebx
  800622:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800627:	eb 4d                	jmp    800676 <vprintfmt+0x377>
  800629:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80062c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800630:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800637:	ff d7                	call   *%edi
			putch('x', putdat);
  800639:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800644:	ff d7                	call   *%edi
			num = (unsigned long long)
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8d 50 04             	lea    0x4(%eax),%edx
  80064c:	89 55 14             	mov    %edx,0x14(%ebp)
  80064f:	8b 08                	mov    (%eax),%ecx
  800651:	bb 00 00 00 00       	mov    $0x0,%ebx
  800656:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065b:	eb 19                	jmp    800676 <vprintfmt+0x377>
  80065d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800660:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800663:	89 ca                	mov    %ecx,%edx
  800665:	8d 45 14             	lea    0x14(%ebp),%eax
  800668:	e8 3b fc ff ff       	call   8002a8 <getuint>
  80066d:	89 c1                	mov    %eax,%ecx
  80066f:	89 d3                	mov    %edx,%ebx
  800671:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800676:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80067a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80067e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800681:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800685:	89 44 24 08          	mov    %eax,0x8(%esp)
  800689:	89 0c 24             	mov    %ecx,(%esp)
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	89 f2                	mov    %esi,%edx
  800692:	89 f8                	mov    %edi,%eax
  800694:	e8 27 fb ff ff       	call   8001c0 <printnum>
  800699:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80069c:	e9 8a fc ff ff       	jmp    80032b <vprintfmt+0x2c>
  8006a1:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	ff d7                	call   *%edi
  8006ad:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006b0:	e9 76 fc ff ff       	jmp    80032b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c0:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c2:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006c5:	80 38 25             	cmpb   $0x25,(%eax)
  8006c8:	0f 84 5d fc ff ff    	je     80032b <vprintfmt+0x2c>
  8006ce:	89 c3                	mov    %eax,%ebx
  8006d0:	eb f0                	jmp    8006c2 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  8006d2:	83 c4 4c             	add    $0x4c,%esp
  8006d5:	5b                   	pop    %ebx
  8006d6:	5e                   	pop    %esi
  8006d7:	5f                   	pop    %edi
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 28             	sub    $0x28,%esp
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	74 04                	je     8006ee <vsnprintf+0x14>
  8006ea:	85 d2                	test   %edx,%edx
  8006ec:	7f 07                	jg     8006f5 <vsnprintf+0x1b>
  8006ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f3:	eb 3b                	jmp    800730 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8006fc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006ff:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80070d:	8b 45 10             	mov    0x10(%ebp),%eax
  800710:	89 44 24 08          	mov    %eax,0x8(%esp)
  800714:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071b:	c7 04 24 e2 02 80 00 	movl   $0x8002e2,(%esp)
  800722:	e8 d8 fb ff ff       	call   8002ff <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800727:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80072a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073f:	8b 45 10             	mov    0x10(%ebp),%eax
  800742:	89 44 24 08          	mov    %eax,0x8(%esp)
  800746:	8b 45 0c             	mov    0xc(%ebp),%eax
  800749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	e8 82 ff ff ff       	call   8006da <vsnprintf>
	va_end(ap);

	return rc;
}
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800760:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800763:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800767:	8b 45 10             	mov    0x10(%ebp),%eax
  80076a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800771:	89 44 24 04          	mov    %eax,0x4(%esp)
  800775:	8b 45 08             	mov    0x8(%ebp),%eax
  800778:	89 04 24             	mov    %eax,(%esp)
  80077b:	e8 7f fb ff ff       	call   8002ff <vprintfmt>
	va_end(ap);
}
  800780:	c9                   	leave  
  800781:	c3                   	ret    
	...

00800790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	8b 55 08             	mov    0x8(%ebp),%edx
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  80079b:	eb 03                	jmp    8007a0 <strlen+0x10>
		n++;
  80079d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007a4:	75 f7                	jne    80079d <strlen+0xd>
		n++;
	return n;
}
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b7:	eb 03                	jmp    8007bc <strnlen+0x14>
		n++;
  8007b9:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bc:	39 c1                	cmp    %eax,%ecx
  8007be:	74 06                	je     8007c6 <strnlen+0x1e>
  8007c0:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8007c4:	75 f3                	jne    8007b9 <strnlen+0x11>
		n++;
	return n;
}
  8007c6:	5b                   	pop    %ebx
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	53                   	push   %ebx
  8007cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007d3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8007dc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007df:	83 c2 01             	add    $0x1,%edx
  8007e2:	84 c9                	test   %cl,%cl
  8007e4:	75 f2                	jne    8007d8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007e6:	5b                   	pop    %ebx
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	53                   	push   %ebx
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f3:	89 1c 24             	mov    %ebx,(%esp)
  8007f6:	e8 95 ff ff ff       	call   800790 <strlen>
	strcpy(dst + len, src);
  8007fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800802:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800805:	89 04 24             	mov    %eax,(%esp)
  800808:	e8 bc ff ff ff       	call   8007c9 <strcpy>
	return dst;
}
  80080d:	89 d8                	mov    %ebx,%eax
  80080f:	83 c4 08             	add    $0x8,%esp
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800820:	8b 75 10             	mov    0x10(%ebp),%esi
  800823:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800828:	eb 0f                	jmp    800839 <strncpy+0x24>
		*dst++ = *src;
  80082a:	0f b6 19             	movzbl (%ecx),%ebx
  80082d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800830:	80 39 01             	cmpb   $0x1,(%ecx)
  800833:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	39 f2                	cmp    %esi,%edx
  80083b:	72 ed                	jb     80082a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	8b 75 08             	mov    0x8(%ebp),%esi
  800849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80084f:	89 f0                	mov    %esi,%eax
  800851:	85 d2                	test   %edx,%edx
  800853:	75 0a                	jne    80085f <strlcpy+0x1e>
  800855:	eb 17                	jmp    80086e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800857:	88 18                	mov    %bl,(%eax)
  800859:	83 c0 01             	add    $0x1,%eax
  80085c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80085f:	83 ea 01             	sub    $0x1,%edx
  800862:	74 07                	je     80086b <strlcpy+0x2a>
  800864:	0f b6 19             	movzbl (%ecx),%ebx
  800867:	84 db                	test   %bl,%bl
  800869:	75 ec                	jne    800857 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80086b:	c6 00 00             	movb   $0x0,(%eax)
  80086e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800870:	5b                   	pop    %ebx
  800871:	5e                   	pop    %esi
  800872:	5d                   	pop    %ebp
  800873:	c3                   	ret    

00800874 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80087a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087d:	eb 06                	jmp    800885 <strcmp+0x11>
		p++, q++;
  80087f:	83 c1 01             	add    $0x1,%ecx
  800882:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800885:	0f b6 01             	movzbl (%ecx),%eax
  800888:	84 c0                	test   %al,%al
  80088a:	74 04                	je     800890 <strcmp+0x1c>
  80088c:	3a 02                	cmp    (%edx),%al
  80088e:	74 ef                	je     80087f <strcmp+0xb>
  800890:	0f b6 c0             	movzbl %al,%eax
  800893:	0f b6 12             	movzbl (%edx),%edx
  800896:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a4:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008a7:	eb 09                	jmp    8008b2 <strncmp+0x18>
		n--, p++, q++;
  8008a9:	83 ea 01             	sub    $0x1,%edx
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b2:	85 d2                	test   %edx,%edx
  8008b4:	75 07                	jne    8008bd <strncmp+0x23>
  8008b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bb:	eb 13                	jmp    8008d0 <strncmp+0x36>
  8008bd:	0f b6 18             	movzbl (%eax),%ebx
  8008c0:	84 db                	test   %bl,%bl
  8008c2:	74 04                	je     8008c8 <strncmp+0x2e>
  8008c4:	3a 19                	cmp    (%ecx),%bl
  8008c6:	74 e1                	je     8008a9 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c8:	0f b6 00             	movzbl (%eax),%eax
  8008cb:	0f b6 11             	movzbl (%ecx),%edx
  8008ce:	29 d0                	sub    %edx,%eax
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008dd:	eb 07                	jmp    8008e6 <strchr+0x13>
		if (*s == c)
  8008df:	38 ca                	cmp    %cl,%dl
  8008e1:	74 0f                	je     8008f2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	0f b6 10             	movzbl (%eax),%edx
  8008e9:	84 d2                	test   %dl,%dl
  8008eb:	75 f2                	jne    8008df <strchr+0xc>
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fe:	eb 07                	jmp    800907 <strfind+0x13>
		if (*s == c)
  800900:	38 ca                	cmp    %cl,%dl
  800902:	74 0a                	je     80090e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800904:	83 c0 01             	add    $0x1,%eax
  800907:	0f b6 10             	movzbl (%eax),%edx
  80090a:	84 d2                	test   %dl,%dl
  80090c:	75 f2                	jne    800900 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  80090e:	5d                   	pop    %ebp
  80090f:	90                   	nop
  800910:	c3                   	ret    

00800911 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	83 ec 0c             	sub    $0xc,%esp
  800917:	89 1c 24             	mov    %ebx,(%esp)
  80091a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80091e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800922:	8b 7d 08             	mov    0x8(%ebp),%edi
  800925:	8b 45 0c             	mov    0xc(%ebp),%eax
  800928:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092b:	85 c9                	test   %ecx,%ecx
  80092d:	74 30                	je     80095f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800935:	75 25                	jne    80095c <memset+0x4b>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 20                	jne    80095c <memset+0x4b>
		c &= 0xFF;
  80093c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093f:	89 d3                	mov    %edx,%ebx
  800941:	c1 e3 08             	shl    $0x8,%ebx
  800944:	89 d6                	mov    %edx,%esi
  800946:	c1 e6 18             	shl    $0x18,%esi
  800949:	89 d0                	mov    %edx,%eax
  80094b:	c1 e0 10             	shl    $0x10,%eax
  80094e:	09 f0                	or     %esi,%eax
  800950:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800952:	09 d8                	or     %ebx,%eax
  800954:	c1 e9 02             	shr    $0x2,%ecx
  800957:	fc                   	cld    
  800958:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095a:	eb 03                	jmp    80095f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095c:	fc                   	cld    
  80095d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095f:	89 f8                	mov    %edi,%eax
  800961:	8b 1c 24             	mov    (%esp),%ebx
  800964:	8b 74 24 04          	mov    0x4(%esp),%esi
  800968:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80096c:	89 ec                	mov    %ebp,%esp
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	83 ec 08             	sub    $0x8,%esp
  800976:	89 34 24             	mov    %esi,(%esp)
  800979:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80097d:	8b 45 08             	mov    0x8(%ebp),%eax
  800980:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800983:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800986:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800988:	39 c6                	cmp    %eax,%esi
  80098a:	73 35                	jae    8009c1 <memmove+0x51>
  80098c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098f:	39 d0                	cmp    %edx,%eax
  800991:	73 2e                	jae    8009c1 <memmove+0x51>
		s += n;
		d += n;
  800993:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800995:	f6 c2 03             	test   $0x3,%dl
  800998:	75 1b                	jne    8009b5 <memmove+0x45>
  80099a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a0:	75 13                	jne    8009b5 <memmove+0x45>
  8009a2:	f6 c1 03             	test   $0x3,%cl
  8009a5:	75 0e                	jne    8009b5 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8009a7:	83 ef 04             	sub    $0x4,%edi
  8009aa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ad:	c1 e9 02             	shr    $0x2,%ecx
  8009b0:	fd                   	std    
  8009b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b3:	eb 09                	jmp    8009be <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b5:	83 ef 01             	sub    $0x1,%edi
  8009b8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009bb:	fd                   	std    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009be:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bf:	eb 20                	jmp    8009e1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009c7:	75 15                	jne    8009de <memmove+0x6e>
  8009c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009cf:	75 0d                	jne    8009de <memmove+0x6e>
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 08                	jne    8009de <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
  8009d9:	fc                   	cld    
  8009da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dc:	eb 03                	jmp    8009e1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009de:	fc                   	cld    
  8009df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e1:	8b 34 24             	mov    (%esp),%esi
  8009e4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8009e8:	89 ec                	mov    %ebp,%esp
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	89 04 24             	mov    %eax,(%esp)
  800a06:	e8 65 ff ff ff       	call   800970 <memmove>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	57                   	push   %edi
  800a11:	56                   	push   %esi
  800a12:	53                   	push   %ebx
  800a13:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a19:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a1c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a21:	eb 1c                	jmp    800a3f <memcmp+0x32>
		if (*s1 != *s2)
  800a23:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800a27:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	83 e9 01             	sub    $0x1,%ecx
  800a31:	38 d8                	cmp    %bl,%al
  800a33:	74 0a                	je     800a3f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800a35:	0f b6 c0             	movzbl %al,%eax
  800a38:	0f b6 db             	movzbl %bl,%ebx
  800a3b:	29 d8                	sub    %ebx,%eax
  800a3d:	eb 09                	jmp    800a48 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3f:	85 c9                	test   %ecx,%ecx
  800a41:	75 e0                	jne    800a23 <memcmp+0x16>
  800a43:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800a48:	5b                   	pop    %ebx
  800a49:	5e                   	pop    %esi
  800a4a:	5f                   	pop    %edi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a56:	89 c2                	mov    %eax,%edx
  800a58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a5b:	eb 07                	jmp    800a64 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5d:	38 08                	cmp    %cl,(%eax)
  800a5f:	74 07                	je     800a68 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	39 d0                	cmp    %edx,%eax
  800a66:	72 f5                	jb     800a5d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	83 ec 04             	sub    $0x4,%esp
  800a73:	8b 55 08             	mov    0x8(%ebp),%edx
  800a76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	eb 03                	jmp    800a7e <strtol+0x14>
		s++;
  800a7b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7e:	0f b6 02             	movzbl (%edx),%eax
  800a81:	3c 20                	cmp    $0x20,%al
  800a83:	74 f6                	je     800a7b <strtol+0x11>
  800a85:	3c 09                	cmp    $0x9,%al
  800a87:	74 f2                	je     800a7b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a89:	3c 2b                	cmp    $0x2b,%al
  800a8b:	75 0c                	jne    800a99 <strtol+0x2f>
		s++;
  800a8d:	8d 52 01             	lea    0x1(%edx),%edx
  800a90:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800a97:	eb 15                	jmp    800aae <strtol+0x44>
	else if (*s == '-')
  800a99:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800aa0:	3c 2d                	cmp    $0x2d,%al
  800aa2:	75 0a                	jne    800aae <strtol+0x44>
		s++, neg = 1;
  800aa4:	8d 52 01             	lea    0x1(%edx),%edx
  800aa7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aae:	85 db                	test   %ebx,%ebx
  800ab0:	0f 94 c0             	sete   %al
  800ab3:	74 05                	je     800aba <strtol+0x50>
  800ab5:	83 fb 10             	cmp    $0x10,%ebx
  800ab8:	75 18                	jne    800ad2 <strtol+0x68>
  800aba:	80 3a 30             	cmpb   $0x30,(%edx)
  800abd:	75 13                	jne    800ad2 <strtol+0x68>
  800abf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ac3:	75 0d                	jne    800ad2 <strtol+0x68>
		s += 2, base = 16;
  800ac5:	83 c2 02             	add    $0x2,%edx
  800ac8:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800acd:	8d 76 00             	lea    0x0(%esi),%esi
  800ad0:	eb 13                	jmp    800ae5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad2:	84 c0                	test   %al,%al
  800ad4:	74 0f                	je     800ae5 <strtol+0x7b>
  800ad6:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800adb:	80 3a 30             	cmpb   $0x30,(%edx)
  800ade:	75 05                	jne    800ae5 <strtol+0x7b>
		s++, base = 8;
  800ae0:	83 c2 01             	add    $0x1,%edx
  800ae3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aec:	0f b6 0a             	movzbl (%edx),%ecx
  800aef:	89 cf                	mov    %ecx,%edi
  800af1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800af4:	80 fb 09             	cmp    $0x9,%bl
  800af7:	77 08                	ja     800b01 <strtol+0x97>
			dig = *s - '0';
  800af9:	0f be c9             	movsbl %cl,%ecx
  800afc:	83 e9 30             	sub    $0x30,%ecx
  800aff:	eb 1e                	jmp    800b1f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b01:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b04:	80 fb 19             	cmp    $0x19,%bl
  800b07:	77 08                	ja     800b11 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800b09:	0f be c9             	movsbl %cl,%ecx
  800b0c:	83 e9 57             	sub    $0x57,%ecx
  800b0f:	eb 0e                	jmp    800b1f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b11:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b14:	80 fb 19             	cmp    $0x19,%bl
  800b17:	77 15                	ja     800b2e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800b19:	0f be c9             	movsbl %cl,%ecx
  800b1c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b1f:	39 f1                	cmp    %esi,%ecx
  800b21:	7d 0b                	jge    800b2e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800b23:	83 c2 01             	add    $0x1,%edx
  800b26:	0f af c6             	imul   %esi,%eax
  800b29:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b2c:	eb be                	jmp    800aec <strtol+0x82>
  800b2e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b30:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b34:	74 05                	je     800b3b <strtol+0xd1>
		*endptr = (char *) s;
  800b36:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b39:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b3f:	74 04                	je     800b45 <strtol+0xdb>
  800b41:	89 c8                	mov    %ecx,%eax
  800b43:	f7 d8                	neg    %eax
}
  800b45:	83 c4 04             	add    $0x4,%esp
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    
  800b4d:	00 00                	add    %al,(%eax)
	...

00800b50 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	89 1c 24             	mov    %ebx,(%esp)
  800b59:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b5d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	b8 00 00 00 00       	mov    $0x0,%eax
  800b66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b69:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6c:	89 c3                	mov    %eax,%ebx
  800b6e:	89 c7                	mov    %eax,%edi
  800b70:	89 c6                	mov    %eax,%esi
  800b72:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b74:	8b 1c 24             	mov    (%esp),%ebx
  800b77:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b7b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b7f:	89 ec                	mov    %ebp,%esp
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 38             	sub    $0x38,%esp
  800b89:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800b8c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800b8f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800b92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b96:	75 0c                	jne    800ba4 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800b98:	c7 04 24 c8 14 80 00 	movl   $0x8014c8,(%esp)
  800b9f:	e8 b5 f5 ff ff       	call   800159 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ba9:	b8 09 00 00 00       	mov    $0x9,%eax
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb4:	89 df                	mov    %ebx,%edi
  800bb6:	89 de                	mov    %ebx,%esi
  800bb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	7e 28                	jle    800be6 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bc2:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800bc9:	00 
  800bca:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800bd1:	00 
  800bd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bd9:	00 
  800bda:	c7 04 24 11 15 80 00 	movl   $0x801511,(%esp)
  800be1:	e8 b2 03 00 00       	call   800f98 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800be6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800be9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bec:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bef:	89 ec                	mov    %ebp,%esp
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	83 ec 38             	sub    $0x38,%esp
  800bf9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bfc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bff:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c07:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	89 cb                	mov    %ecx,%ebx
  800c11:	89 cf                	mov    %ecx,%edi
  800c13:	89 ce                	mov    %ecx,%esi
  800c15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c17:	85 c0                	test   %eax,%eax
  800c19:	7e 28                	jle    800c43 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c1f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800c26:	00 
  800c27:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800c2e:	00 
  800c2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c36:	00 
  800c37:	c7 04 24 11 15 80 00 	movl   $0x801511,(%esp)
  800c3e:	e8 55 03 00 00       	call   800f98 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800c43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c46:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c49:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c4c:	89 ec                	mov    %ebp,%esp
  800c4e:	5d                   	pop    %ebp
  800c4f:	c3                   	ret    

00800c50 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	89 1c 24             	mov    %ebx,(%esp)
  800c59:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c5d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c61:	be 00 00 00 00       	mov    $0x0,%esi
  800c66:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c6b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800c79:	8b 1c 24             	mov    (%esp),%ebx
  800c7c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c80:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c84:	89 ec                	mov    %ebp,%esp
  800c86:	5d                   	pop    %ebp
  800c87:	c3                   	ret    

00800c88 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 38             	sub    $0x38,%esp
  800c8e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c91:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c94:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	89 df                	mov    %ebx,%edi
  800ca9:	89 de                	mov    %ebx,%esi
  800cab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7e 28                	jle    800cd9 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb5:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cbc:	00 
  800cbd:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800cc4:	00 
  800cc5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ccc:	00 
  800ccd:	c7 04 24 11 15 80 00 	movl   $0x801511,(%esp)
  800cd4:	e8 bf 02 00 00       	call   800f98 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cd9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cdc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cdf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ce2:	89 ec                	mov    %ebp,%esp
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	83 ec 38             	sub    $0x38,%esp
  800cec:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cef:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfa:	b8 06 00 00 00       	mov    $0x6,%eax
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	8b 55 08             	mov    0x8(%ebp),%edx
  800d05:	89 df                	mov    %ebx,%edi
  800d07:	89 de                	mov    %ebx,%esi
  800d09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	7e 28                	jle    800d37 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d13:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d1a:	00 
  800d1b:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800d22:	00 
  800d23:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2a:	00 
  800d2b:	c7 04 24 11 15 80 00 	movl   $0x801511,(%esp)
  800d32:	e8 61 02 00 00       	call   800f98 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d37:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d40:	89 ec                	mov    %ebp,%esp
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 38             	sub    $0x38,%esp
  800d4a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d50:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d53:	b8 05 00 00 00       	mov    $0x5,%eax
  800d58:	8b 75 18             	mov    0x18(%ebp),%esi
  800d5b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 28                	jle    800d95 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d71:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d78:	00 
  800d79:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800d80:	00 
  800d81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d88:	00 
  800d89:	c7 04 24 11 15 80 00 	movl   $0x801511,(%esp)
  800d90:	e8 03 02 00 00       	call   800f98 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d95:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d98:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9e:	89 ec                	mov    %ebp,%esp
  800da0:	5d                   	pop    %ebp
  800da1:	c3                   	ret    

00800da2 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	83 ec 38             	sub    $0x38,%esp
  800da8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dab:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dae:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	be 00 00 00 00       	mov    $0x0,%esi
  800db6:	b8 04 00 00 00       	mov    $0x4,%eax
  800dbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc4:	89 f7                	mov    %esi,%edi
  800dc6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7e 28                	jle    800df4 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd0:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800ddf:	00 
  800de0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de7:	00 
  800de8:	c7 04 24 11 15 80 00 	movl   $0x801511,(%esp)
  800def:	e8 a4 01 00 00       	call   800f98 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800df4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfd:	89 ec                	mov    %ebp,%esp
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	89 1c 24             	mov    %ebx,(%esp)
  800e0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e12:	ba 00 00 00 00       	mov    $0x0,%edx
  800e17:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1c:	89 d1                	mov    %edx,%ecx
  800e1e:	89 d3                	mov    %edx,%ebx
  800e20:	89 d7                	mov    %edx,%edi
  800e22:	89 d6                	mov    %edx,%esi
  800e24:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e26:	8b 1c 24             	mov    (%esp),%ebx
  800e29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e31:	89 ec                	mov    %ebp,%esp
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	89 1c 24             	mov    %ebx,(%esp)
  800e3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e42:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e46:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e50:	89 d1                	mov    %edx,%ecx
  800e52:	89 d3                	mov    %edx,%ebx
  800e54:	89 d7                	mov    %edx,%edi
  800e56:	89 d6                	mov    %edx,%esi
  800e58:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e5a:	8b 1c 24             	mov    (%esp),%ebx
  800e5d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e61:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e65:	89 ec                	mov    %ebp,%esp
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    

00800e69 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 38             	sub    $0x38,%esp
  800e6f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e72:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e75:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e78:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7d:	b8 03 00 00 00       	mov    $0x3,%eax
  800e82:	8b 55 08             	mov    0x8(%ebp),%edx
  800e85:	89 cb                	mov    %ecx,%ebx
  800e87:	89 cf                	mov    %ecx,%edi
  800e89:	89 ce                	mov    %ecx,%esi
  800e8b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	7e 28                	jle    800eb9 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e95:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 08 f4 14 80 	movl   $0x8014f4,0x8(%esp)
  800ea4:	00 
  800ea5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eac:	00 
  800ead:	c7 04 24 11 15 80 00 	movl   $0x801511,(%esp)
  800eb4:	e8 df 00 00 00       	call   800f98 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800eb9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ebc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ebf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec2:	89 ec                	mov    %ebp,%esp
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	89 1c 24             	mov    %ebx,(%esp)
  800ecf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ed3:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed7:	ba 00 00 00 00       	mov    $0x0,%edx
  800edc:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee1:	89 d1                	mov    %edx,%ecx
  800ee3:	89 d3                	mov    %edx,%ebx
  800ee5:	89 d7                	mov    %edx,%edi
  800ee7:	89 d6                	mov    %edx,%esi
  800ee9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800eeb:	8b 1c 24             	mov    (%esp),%ebx
  800eee:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ef2:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ef6:	89 ec                	mov    %ebp,%esp
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    
	...

00800efc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f02:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f09:	75 58                	jne    800f63 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  800f0b:	a1 04 20 80 00       	mov    0x802004,%eax
  800f10:	8b 40 48             	mov    0x48(%eax),%eax
  800f13:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f1a:	00 
  800f1b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800f22:	ee 
  800f23:	89 04 24             	mov    %eax,(%esp)
  800f26:	e8 77 fe ff ff       	call   800da2 <sys_page_alloc>
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	74 1c                	je     800f4b <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  800f2f:	c7 44 24 08 20 15 80 	movl   $0x801520,0x8(%esp)
  800f36:	00 
  800f37:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800f3e:	00 
  800f3f:	c7 04 24 4a 15 80 00 	movl   $0x80154a,(%esp)
  800f46:	e8 4d 00 00 00       	call   800f98 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  800f4b:	a1 04 20 80 00       	mov    0x802004,%eax
  800f50:	8b 40 48             	mov    0x48(%eax),%eax
  800f53:	c7 44 24 04 70 0f 80 	movl   $0x800f70,0x4(%esp)
  800f5a:	00 
  800f5b:	89 04 24             	mov    %eax,(%esp)
  800f5e:	e8 20 fc ff ff       	call   800b83 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f63:	8b 45 08             	mov    0x8(%ebp),%eax
  800f66:	a3 08 20 80 00       	mov    %eax,0x802008
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    
  800f6d:	00 00                	add    %al,(%eax)
	...

00800f70 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f70:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f71:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800f76:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f78:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl  %esp , %ebx
  800f7b:	89 e3                	mov    %esp,%ebx
	movl  40(%esp) , %eax
  800f7d:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl  48(%esp) , %esp
  800f81:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl  %eax 
  800f85:	50                   	push   %eax


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl  %ebx , %esp
  800f86:	89 dc                	mov    %ebx,%esp
	subl  $4 , 48(%esp)
  800f88:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl  %eax
  800f8d:	58                   	pop    %eax
	popl  %eax
  800f8e:	58                   	pop    %eax
	popal
  800f8f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4 , %esp
  800f90:	83 c4 04             	add    $0x4,%esp
	popfl
  800f93:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800f94:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800f95:	c3                   	ret    
	...

00800f98 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	56                   	push   %esi
  800f9c:	53                   	push   %ebx
  800f9d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800fa0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fa3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800fa9:	e8 87 fe ff ff       	call   800e35 <sys_getenvid>
  800fae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb1:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fbc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc4:	c7 04 24 58 15 80 00 	movl   $0x801558,(%esp)
  800fcb:	e8 89 f1 ff ff       	call   800159 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fd0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd7:	89 04 24             	mov    %eax,(%esp)
  800fda:	e8 19 f1 ff ff       	call   8000f8 <vcprintf>
	cprintf("\n");
  800fdf:	c7 04 24 7a 12 80 00 	movl   $0x80127a,(%esp)
  800fe6:	e8 6e f1 ff ff       	call   800159 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800feb:	cc                   	int3   
  800fec:	eb fd                	jmp    800feb <_panic+0x53>
	...

00800ff0 <__udivdi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	83 ec 10             	sub    $0x10,%esp
  800ff8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	8b 75 10             	mov    0x10(%ebp),%esi
  801001:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801004:	85 c0                	test   %eax,%eax
  801006:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801009:	75 35                	jne    801040 <__udivdi3+0x50>
  80100b:	39 fe                	cmp    %edi,%esi
  80100d:	77 61                	ja     801070 <__udivdi3+0x80>
  80100f:	85 f6                	test   %esi,%esi
  801011:	75 0b                	jne    80101e <__udivdi3+0x2e>
  801013:	b8 01 00 00 00       	mov    $0x1,%eax
  801018:	31 d2                	xor    %edx,%edx
  80101a:	f7 f6                	div    %esi
  80101c:	89 c6                	mov    %eax,%esi
  80101e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801021:	31 d2                	xor    %edx,%edx
  801023:	89 f8                	mov    %edi,%eax
  801025:	f7 f6                	div    %esi
  801027:	89 c7                	mov    %eax,%edi
  801029:	89 c8                	mov    %ecx,%eax
  80102b:	f7 f6                	div    %esi
  80102d:	89 c1                	mov    %eax,%ecx
  80102f:	89 fa                	mov    %edi,%edx
  801031:	89 c8                	mov    %ecx,%eax
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	39 f8                	cmp    %edi,%eax
  801042:	77 1c                	ja     801060 <__udivdi3+0x70>
  801044:	0f bd d0             	bsr    %eax,%edx
  801047:	83 f2 1f             	xor    $0x1f,%edx
  80104a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80104d:	75 39                	jne    801088 <__udivdi3+0x98>
  80104f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801052:	0f 86 a0 00 00 00    	jbe    8010f8 <__udivdi3+0x108>
  801058:	39 f8                	cmp    %edi,%eax
  80105a:	0f 82 98 00 00 00    	jb     8010f8 <__udivdi3+0x108>
  801060:	31 ff                	xor    %edi,%edi
  801062:	31 c9                	xor    %ecx,%ecx
  801064:	89 c8                	mov    %ecx,%eax
  801066:	89 fa                	mov    %edi,%edx
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    
  80106f:	90                   	nop
  801070:	89 d1                	mov    %edx,%ecx
  801072:	89 fa                	mov    %edi,%edx
  801074:	89 c8                	mov    %ecx,%eax
  801076:	31 ff                	xor    %edi,%edi
  801078:	f7 f6                	div    %esi
  80107a:	89 c1                	mov    %eax,%ecx
  80107c:	89 fa                	mov    %edi,%edx
  80107e:	89 c8                	mov    %ecx,%eax
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
  801087:	90                   	nop
  801088:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80108c:	89 f2                	mov    %esi,%edx
  80108e:	d3 e0                	shl    %cl,%eax
  801090:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801093:	b8 20 00 00 00       	mov    $0x20,%eax
  801098:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80109b:	89 c1                	mov    %eax,%ecx
  80109d:	d3 ea                	shr    %cl,%edx
  80109f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010a6:	d3 e6                	shl    %cl,%esi
  8010a8:	89 c1                	mov    %eax,%ecx
  8010aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010ad:	89 fe                	mov    %edi,%esi
  8010af:	d3 ee                	shr    %cl,%esi
  8010b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010bb:	d3 e7                	shl    %cl,%edi
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	d3 ea                	shr    %cl,%edx
  8010c1:	09 d7                	or     %edx,%edi
  8010c3:	89 f2                	mov    %esi,%edx
  8010c5:	89 f8                	mov    %edi,%eax
  8010c7:	f7 75 ec             	divl   -0x14(%ebp)
  8010ca:	89 d6                	mov    %edx,%esi
  8010cc:	89 c7                	mov    %eax,%edi
  8010ce:	f7 65 e8             	mull   -0x18(%ebp)
  8010d1:	39 d6                	cmp    %edx,%esi
  8010d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010d6:	72 30                	jb     801108 <__udivdi3+0x118>
  8010d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010df:	d3 e2                	shl    %cl,%edx
  8010e1:	39 c2                	cmp    %eax,%edx
  8010e3:	73 05                	jae    8010ea <__udivdi3+0xfa>
  8010e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010e8:	74 1e                	je     801108 <__udivdi3+0x118>
  8010ea:	89 f9                	mov    %edi,%ecx
  8010ec:	31 ff                	xor    %edi,%edi
  8010ee:	e9 71 ff ff ff       	jmp    801064 <__udivdi3+0x74>
  8010f3:	90                   	nop
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	31 ff                	xor    %edi,%edi
  8010fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010ff:	e9 60 ff ff ff       	jmp    801064 <__udivdi3+0x74>
  801104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801108:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80110b:	31 ff                	xor    %edi,%edi
  80110d:	89 c8                	mov    %ecx,%eax
  80110f:	89 fa                	mov    %edi,%edx
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    
	...

00801120 <__umoddi3>:
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	83 ec 20             	sub    $0x20,%esp
  801128:	8b 55 14             	mov    0x14(%ebp),%edx
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801131:	8b 75 0c             	mov    0xc(%ebp),%esi
  801134:	85 d2                	test   %edx,%edx
  801136:	89 c8                	mov    %ecx,%eax
  801138:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80113b:	75 13                	jne    801150 <__umoddi3+0x30>
  80113d:	39 f7                	cmp    %esi,%edi
  80113f:	76 3f                	jbe    801180 <__umoddi3+0x60>
  801141:	89 f2                	mov    %esi,%edx
  801143:	f7 f7                	div    %edi
  801145:	89 d0                	mov    %edx,%eax
  801147:	31 d2                	xor    %edx,%edx
  801149:	83 c4 20             	add    $0x20,%esp
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    
  801150:	39 f2                	cmp    %esi,%edx
  801152:	77 4c                	ja     8011a0 <__umoddi3+0x80>
  801154:	0f bd ca             	bsr    %edx,%ecx
  801157:	83 f1 1f             	xor    $0x1f,%ecx
  80115a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80115d:	75 51                	jne    8011b0 <__umoddi3+0x90>
  80115f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801162:	0f 87 e0 00 00 00    	ja     801248 <__umoddi3+0x128>
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	29 f8                	sub    %edi,%eax
  80116d:	19 d6                	sbb    %edx,%esi
  80116f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801175:	89 f2                	mov    %esi,%edx
  801177:	83 c4 20             	add    $0x20,%esp
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    
  80117e:	66 90                	xchg   %ax,%ax
  801180:	85 ff                	test   %edi,%edi
  801182:	75 0b                	jne    80118f <__umoddi3+0x6f>
  801184:	b8 01 00 00 00       	mov    $0x1,%eax
  801189:	31 d2                	xor    %edx,%edx
  80118b:	f7 f7                	div    %edi
  80118d:	89 c7                	mov    %eax,%edi
  80118f:	89 f0                	mov    %esi,%eax
  801191:	31 d2                	xor    %edx,%edx
  801193:	f7 f7                	div    %edi
  801195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801198:	f7 f7                	div    %edi
  80119a:	eb a9                	jmp    801145 <__umoddi3+0x25>
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	89 c8                	mov    %ecx,%eax
  8011a2:	89 f2                	mov    %esi,%edx
  8011a4:	83 c4 20             	add    $0x20,%esp
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    
  8011ab:	90                   	nop
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011b4:	d3 e2                	shl    %cl,%edx
  8011b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c8:	89 fa                	mov    %edi,%edx
  8011ca:	d3 ea                	shr    %cl,%edx
  8011cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011d3:	d3 e7                	shl    %cl,%edi
  8011d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011dc:	89 f2                	mov    %esi,%edx
  8011de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011e1:	89 c7                	mov    %eax,%edi
  8011e3:	d3 ea                	shr    %cl,%edx
  8011e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	d3 e6                	shl    %cl,%esi
  8011f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011f4:	d3 ea                	shr    %cl,%edx
  8011f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011fa:	09 d6                	or     %edx,%esi
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801201:	d3 e7                	shl    %cl,%edi
  801203:	89 f2                	mov    %esi,%edx
  801205:	f7 75 f4             	divl   -0xc(%ebp)
  801208:	89 d6                	mov    %edx,%esi
  80120a:	f7 65 e8             	mull   -0x18(%ebp)
  80120d:	39 d6                	cmp    %edx,%esi
  80120f:	72 2b                	jb     80123c <__umoddi3+0x11c>
  801211:	39 c7                	cmp    %eax,%edi
  801213:	72 23                	jb     801238 <__umoddi3+0x118>
  801215:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801219:	29 c7                	sub    %eax,%edi
  80121b:	19 d6                	sbb    %edx,%esi
  80121d:	89 f0                	mov    %esi,%eax
  80121f:	89 f2                	mov    %esi,%edx
  801221:	d3 ef                	shr    %cl,%edi
  801223:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801227:	d3 e0                	shl    %cl,%eax
  801229:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80122d:	09 f8                	or     %edi,%eax
  80122f:	d3 ea                	shr    %cl,%edx
  801231:	83 c4 20             	add    $0x20,%esp
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    
  801238:	39 d6                	cmp    %edx,%esi
  80123a:	75 d9                	jne    801215 <__umoddi3+0xf5>
  80123c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80123f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801242:	eb d1                	jmp    801215 <__umoddi3+0xf5>
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	39 f2                	cmp    %esi,%edx
  80124a:	0f 82 18 ff ff ff    	jb     801168 <__umoddi3+0x48>
  801250:	e9 1d ff ff ff       	jmp    801172 <__umoddi3+0x52>
