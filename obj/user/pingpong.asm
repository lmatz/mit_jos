
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 6c 10 00 00       	call   8010ae <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 45 0e 00 00       	call   800e95 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  80005f:	e8 59 01 00 00       	call   8001bd <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 6f 12 00 00       	call   8012f6 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 c5 12 00 00       	call   801367 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 e9 0d 00 00       	call   800e95 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 76 17 80 00 	movl   $0x801776,(%esp)
  8000bf:	e8 f9 00 00 00       	call   8001bd <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 0b 12 00 00       	call   8012f6 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  80010a:	e8 86 0d 00 00       	call   800e95 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80014e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800155:	e8 6f 0d 00 00       	call   800ec9 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800165:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016c:	00 00 00 
	b.cnt = 0;
  80016f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800176:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800180:	8b 45 08             	mov    0x8(%ebp),%eax
  800183:	89 44 24 08          	mov    %eax,0x8(%esp)
  800187:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800191:	c7 04 24 d7 01 80 00 	movl   $0x8001d7,(%esp)
  800198:	e8 c2 01 00 00       	call   80035f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ad:	89 04 24             	mov    %eax,(%esp)
  8001b0:	e8 fb 09 00 00       	call   800bb0 <sys_cputs>

	return b.cnt;
}
  8001b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001c3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	89 04 24             	mov    %eax,(%esp)
  8001d0:	e8 87 ff ff ff       	call   80015c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	53                   	push   %ebx
  8001db:	83 ec 14             	sub    $0x14,%esp
  8001de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e1:	8b 03                	mov    (%ebx),%eax
  8001e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ea:	83 c0 01             	add    $0x1,%eax
  8001ed:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f4:	75 19                	jne    80020f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001f6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001fd:	00 
  8001fe:	8d 43 08             	lea    0x8(%ebx),%eax
  800201:	89 04 24             	mov    %eax,(%esp)
  800204:	e8 a7 09 00 00       	call   800bb0 <sys_cputs>
		b->idx = 0;
  800209:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80020f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800213:	83 c4 14             	add    $0x14,%esp
  800216:	5b                   	pop    %ebx
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    
  800219:	00 00                	add    %al,(%eax)
  80021b:	00 00                	add    %al,(%eax)
  80021d:	00 00                	add    %al,(%eax)
	...

00800220 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 4c             	sub    $0x4c,%esp
  800229:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80022c:	89 d6                	mov    %edx,%esi
  80022e:	8b 45 08             	mov    0x8(%ebp),%eax
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800240:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800243:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800246:	b9 00 00 00 00       	mov    $0x0,%ecx
  80024b:	39 d1                	cmp    %edx,%ecx
  80024d:	72 07                	jb     800256 <printnum+0x36>
  80024f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800252:	39 d0                	cmp    %edx,%eax
  800254:	77 69                	ja     8002bf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800256:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80025a:	83 eb 01             	sub    $0x1,%ebx
  80025d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800261:	89 44 24 08          	mov    %eax,0x8(%esp)
  800265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800269:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80026d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800270:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800273:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800276:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80027a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800281:	00 
  800282:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80028b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80028f:	e8 4c 12 00 00       	call   8014e0 <__udivdi3>
  800294:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800297:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80029a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80029e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002a2:	89 04 24             	mov    %eax,(%esp)
  8002a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002a9:	89 f2                	mov    %esi,%edx
  8002ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ae:	e8 6d ff ff ff       	call   800220 <printnum>
  8002b3:	eb 11                	jmp    8002c6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b9:	89 3c 24             	mov    %edi,(%esp)
  8002bc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bf:	83 eb 01             	sub    $0x1,%ebx
  8002c2:	85 db                	test   %ebx,%ebx
  8002c4:	7f ef                	jg     8002b5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ca:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002dc:	00 
  8002dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e0:	89 14 24             	mov    %edx,(%esp)
  8002e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002ea:	e8 21 13 00 00       	call   801610 <__umoddi3>
  8002ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f3:	0f be 80 93 17 80 00 	movsbl 0x801793(%eax),%eax
  8002fa:	89 04 24             	mov    %eax,(%esp)
  8002fd:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800300:	83 c4 4c             	add    $0x4c,%esp
  800303:	5b                   	pop    %ebx
  800304:	5e                   	pop    %esi
  800305:	5f                   	pop    %edi
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    

00800308 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030b:	83 fa 01             	cmp    $0x1,%edx
  80030e:	7e 0e                	jle    80031e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 08             	lea    0x8(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	8b 52 04             	mov    0x4(%edx),%edx
  80031c:	eb 22                	jmp    800340 <getuint+0x38>
	else if (lflag)
  80031e:	85 d2                	test   %edx,%edx
  800320:	74 10                	je     800332 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 4a 04             	lea    0x4(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	ba 00 00 00 00       	mov    $0x0,%edx
  800330:	eb 0e                	jmp    800340 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800332:	8b 10                	mov    (%eax),%edx
  800334:	8d 4a 04             	lea    0x4(%edx),%ecx
  800337:	89 08                	mov    %ecx,(%eax)
  800339:	8b 02                	mov    (%edx),%eax
  80033b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800348:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	3b 50 04             	cmp    0x4(%eax),%edx
  800351:	73 0a                	jae    80035d <sprintputch+0x1b>
		*b->buf++ = ch;
  800353:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800356:	88 0a                	mov    %cl,(%edx)
  800358:	83 c2 01             	add    $0x1,%edx
  80035b:	89 10                	mov    %edx,(%eax)
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	57                   	push   %edi
  800363:	56                   	push   %esi
  800364:	53                   	push   %ebx
  800365:	83 ec 4c             	sub    $0x4c,%esp
  800368:	8b 7d 08             	mov    0x8(%ebp),%edi
  80036b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80036e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800371:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800378:	eb 11                	jmp    80038b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80037a:	85 c0                	test   %eax,%eax
  80037c:	0f 84 b0 03 00 00    	je     800732 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800382:	89 74 24 04          	mov    %esi,0x4(%esp)
  800386:	89 04 24             	mov    %eax,(%esp)
  800389:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038b:	0f b6 03             	movzbl (%ebx),%eax
  80038e:	83 c3 01             	add    $0x1,%ebx
  800391:	83 f8 25             	cmp    $0x25,%eax
  800394:	75 e4                	jne    80037a <vprintfmt+0x1b>
  800396:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8003a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ad:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003b4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8003b7:	eb 06                	jmp    8003bf <vprintfmt+0x60>
  8003b9:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8003bd:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	0f b6 0b             	movzbl (%ebx),%ecx
  8003c2:	0f b6 c1             	movzbl %cl,%eax
  8003c5:	8d 53 01             	lea    0x1(%ebx),%edx
  8003c8:	83 e9 23             	sub    $0x23,%ecx
  8003cb:	80 f9 55             	cmp    $0x55,%cl
  8003ce:	0f 87 41 03 00 00    	ja     800715 <vprintfmt+0x3b6>
  8003d4:	0f b6 c9             	movzbl %cl,%ecx
  8003d7:	ff 24 8d 60 18 80 00 	jmp    *0x801860(,%ecx,4)
  8003de:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8003e2:	eb d9                	jmp    8003bd <vprintfmt+0x5e>
  8003e4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8003eb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003f3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8003f7:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  8003fa:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8003fd:	83 fb 09             	cmp    $0x9,%ebx
  800400:	77 2b                	ja     80042d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800402:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800405:	eb e9                	jmp    8003f0 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8d 48 04             	lea    0x4(%eax),%ecx
  80040d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800415:	eb 19                	jmp    800430 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800417:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80041a:	c1 f8 1f             	sar    $0x1f,%eax
  80041d:	f7 d0                	not    %eax
  80041f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800422:	eb 99                	jmp    8003bd <vprintfmt+0x5e>
  800424:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80042b:	eb 90                	jmp    8003bd <vprintfmt+0x5e>
  80042d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800430:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800434:	79 87                	jns    8003bd <vprintfmt+0x5e>
  800436:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800439:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80043c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80043f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800442:	e9 76 ff ff ff       	jmp    8003bd <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800447:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80044b:	e9 6d ff ff ff       	jmp    8003bd <vprintfmt+0x5e>
  800450:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8d 50 04             	lea    0x4(%eax),%edx
  800459:	89 55 14             	mov    %edx,0x14(%ebp)
  80045c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800460:	8b 00                	mov    (%eax),%eax
  800462:	89 04 24             	mov    %eax,(%esp)
  800465:	ff d7                	call   *%edi
  800467:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80046a:	e9 1c ff ff ff       	jmp    80038b <vprintfmt+0x2c>
  80046f:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8d 50 04             	lea    0x4(%eax),%edx
  800478:	89 55 14             	mov    %edx,0x14(%ebp)
  80047b:	8b 00                	mov    (%eax),%eax
  80047d:	89 c2                	mov    %eax,%edx
  80047f:	c1 fa 1f             	sar    $0x1f,%edx
  800482:	31 d0                	xor    %edx,%eax
  800484:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800486:	83 f8 09             	cmp    $0x9,%eax
  800489:	7f 0b                	jg     800496 <vprintfmt+0x137>
  80048b:	8b 14 85 c0 19 80 00 	mov    0x8019c0(,%eax,4),%edx
  800492:	85 d2                	test   %edx,%edx
  800494:	75 20                	jne    8004b6 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800496:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80049a:	c7 44 24 08 a4 17 80 	movl   $0x8017a4,0x8(%esp)
  8004a1:	00 
  8004a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a6:	89 3c 24             	mov    %edi,(%esp)
  8004a9:	e8 0c 03 00 00       	call   8007ba <printfmt>
  8004ae:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b1:	e9 d5 fe ff ff       	jmp    80038b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004ba:	c7 44 24 08 ad 17 80 	movl   $0x8017ad,0x8(%esp)
  8004c1:	00 
  8004c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c6:	89 3c 24             	mov    %edi,(%esp)
  8004c9:	e8 ec 02 00 00       	call   8007ba <printfmt>
  8004ce:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004d1:	e9 b5 fe ff ff       	jmp    80038b <vprintfmt+0x2c>
  8004d6:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8004d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8004df:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e5:	8d 50 04             	lea    0x4(%eax),%edx
  8004e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004eb:	8b 18                	mov    (%eax),%ebx
  8004ed:	85 db                	test   %ebx,%ebx
  8004ef:	75 05                	jne    8004f6 <vprintfmt+0x197>
  8004f1:	bb b0 17 80 00       	mov    $0x8017b0,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8004f6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fa:	7e 76                	jle    800572 <vprintfmt+0x213>
  8004fc:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800500:	74 7a                	je     80057c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800502:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800506:	89 1c 24             	mov    %ebx,(%esp)
  800509:	e8 fa 02 00 00       	call   800808 <strnlen>
  80050e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800511:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800513:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800517:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80051a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80051d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	eb 0f                	jmp    800530 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800521:	89 74 24 04          	mov    %esi,0x4(%esp)
  800525:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052d:	83 eb 01             	sub    $0x1,%ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f ed                	jg     800521 <vprintfmt+0x1c2>
  800534:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800537:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80053a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80053d:	89 f7                	mov    %esi,%edi
  80053f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800542:	eb 40                	jmp    800584 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800544:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800548:	74 18                	je     800562 <vprintfmt+0x203>
  80054a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80054d:	83 fa 5e             	cmp    $0x5e,%edx
  800550:	76 10                	jbe    800562 <vprintfmt+0x203>
					putch('?', putdat);
  800552:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800556:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055d:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800560:	eb 0a                	jmp    80056c <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800562:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800570:	eb 12                	jmp    800584 <vprintfmt+0x225>
  800572:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800575:	89 f7                	mov    %esi,%edi
  800577:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80057a:	eb 08                	jmp    800584 <vprintfmt+0x225>
  80057c:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80057f:	89 f7                	mov    %esi,%edi
  800581:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800584:	0f be 03             	movsbl (%ebx),%eax
  800587:	83 c3 01             	add    $0x1,%ebx
  80058a:	85 c0                	test   %eax,%eax
  80058c:	74 25                	je     8005b3 <vprintfmt+0x254>
  80058e:	85 f6                	test   %esi,%esi
  800590:	78 b2                	js     800544 <vprintfmt+0x1e5>
  800592:	83 ee 01             	sub    $0x1,%esi
  800595:	79 ad                	jns    800544 <vprintfmt+0x1e5>
  800597:	89 fe                	mov    %edi,%esi
  800599:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80059c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80059f:	eb 1a                	jmp    8005bb <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005ac:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ae:	83 eb 01             	sub    $0x1,%ebx
  8005b1:	eb 08                	jmp    8005bb <vprintfmt+0x25c>
  8005b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005b6:	89 fe                	mov    %edi,%esi
  8005b8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005bb:	85 db                	test   %ebx,%ebx
  8005bd:	7f e2                	jg     8005a1 <vprintfmt+0x242>
  8005bf:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005c2:	e9 c4 fd ff ff       	jmp    80038b <vprintfmt+0x2c>
  8005c7:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005ca:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cd:	83 f9 01             	cmp    $0x1,%ecx
  8005d0:	7e 16                	jle    8005e8 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 08             	lea    0x8(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e0:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e6:	eb 32                	jmp    80061a <vprintfmt+0x2bb>
	else if (lflag)
  8005e8:	85 c9                	test   %ecx,%ecx
  8005ea:	74 18                	je     800604 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fa:	89 c1                	mov    %eax,%ecx
  8005fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800602:	eb 16                	jmp    80061a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800612:	89 c2                	mov    %eax,%edx
  800614:	c1 fa 1f             	sar    $0x1f,%edx
  800617:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80061d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800625:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800629:	0f 89 a7 00 00 00    	jns    8006d6 <vprintfmt+0x377>
				putch('-', putdat);
  80062f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800633:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063a:	ff d7                	call   *%edi
				num = -(long long) num;
  80063c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80063f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800642:	f7 d9                	neg    %ecx
  800644:	83 d3 00             	adc    $0x0,%ebx
  800647:	f7 db                	neg    %ebx
  800649:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064e:	e9 83 00 00 00       	jmp    8006d6 <vprintfmt+0x377>
  800653:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800656:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800659:	89 ca                	mov    %ecx,%edx
  80065b:	8d 45 14             	lea    0x14(%ebp),%eax
  80065e:	e8 a5 fc ff ff       	call   800308 <getuint>
  800663:	89 c1                	mov    %eax,%ecx
  800665:	89 d3                	mov    %edx,%ebx
  800667:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80066c:	eb 68                	jmp    8006d6 <vprintfmt+0x377>
  80066e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800671:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800674:	89 ca                	mov    %ecx,%edx
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 8a fc ff ff       	call   800308 <getuint>
  80067e:	89 c1                	mov    %eax,%ecx
  800680:	89 d3                	mov    %edx,%ebx
  800682:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800687:	eb 4d                	jmp    8006d6 <vprintfmt+0x377>
  800689:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80068c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800690:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800697:	ff d7                	call   *%edi
			putch('x', putdat);
  800699:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a4:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8d 50 04             	lea    0x4(%eax),%edx
  8006ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8006af:	8b 08                	mov    (%eax),%ecx
  8006b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b6:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006bb:	eb 19                	jmp    8006d6 <vprintfmt+0x377>
  8006bd:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006c0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c3:	89 ca                	mov    %ecx,%edx
  8006c5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c8:	e8 3b fc ff ff       	call   800308 <getuint>
  8006cd:	89 c1                	mov    %eax,%ecx
  8006cf:	89 d3                	mov    %edx,%ebx
  8006d1:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d6:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  8006da:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e9:	89 0c 24             	mov    %ecx,(%esp)
  8006ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f0:	89 f2                	mov    %esi,%edx
  8006f2:	89 f8                	mov    %edi,%eax
  8006f4:	e8 27 fb ff ff       	call   800220 <printnum>
  8006f9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006fc:	e9 8a fc ff ff       	jmp    80038b <vprintfmt+0x2c>
  800701:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800704:	89 74 24 04          	mov    %esi,0x4(%esp)
  800708:	89 04 24             	mov    %eax,(%esp)
  80070b:	ff d7                	call   *%edi
  80070d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800710:	e9 76 fc ff ff       	jmp    80038b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800715:	89 74 24 04          	mov    %esi,0x4(%esp)
  800719:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800720:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800722:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800725:	80 38 25             	cmpb   $0x25,(%eax)
  800728:	0f 84 5d fc ff ff    	je     80038b <vprintfmt+0x2c>
  80072e:	89 c3                	mov    %eax,%ebx
  800730:	eb f0                	jmp    800722 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800732:	83 c4 4c             	add    $0x4c,%esp
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	5f                   	pop    %edi
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 28             	sub    $0x28,%esp
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800746:	85 c0                	test   %eax,%eax
  800748:	74 04                	je     80074e <vsnprintf+0x14>
  80074a:	85 d2                	test   %edx,%edx
  80074c:	7f 07                	jg     800755 <vsnprintf+0x1b>
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800753:	eb 3b                	jmp    800790 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800755:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800758:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80075c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80075f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076d:	8b 45 10             	mov    0x10(%ebp),%eax
  800770:	89 44 24 08          	mov    %eax,0x8(%esp)
  800774:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	c7 04 24 42 03 80 00 	movl   $0x800342,(%esp)
  800782:	e8 d8 fb ff ff       	call   80035f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800787:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800790:	c9                   	leave  
  800791:	c3                   	ret    

00800792 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800798:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80079b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079f:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b0:	89 04 24             	mov    %eax,(%esp)
  8007b3:	e8 82 ff ff ff       	call   80073a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007c0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c7:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d8:	89 04 24             	mov    %eax,(%esp)
  8007db:	e8 7f fb ff ff       	call   80035f <vprintfmt>
	va_end(ap);
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    
	...

008007f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fb:	eb 03                	jmp    800800 <strlen+0x10>
		n++;
  8007fd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800800:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800804:	75 f7                	jne    8007fd <strlen+0xd>
		n++;
	return n;
}
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	53                   	push   %ebx
  80080c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80080f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800817:	eb 03                	jmp    80081c <strnlen+0x14>
		n++;
  800819:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	39 c1                	cmp    %eax,%ecx
  80081e:	74 06                	je     800826 <strnlen+0x1e>
  800820:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800824:	75 f3                	jne    800819 <strnlen+0x11>
		n++;
	return n;
}
  800826:	5b                   	pop    %ebx
  800827:	5d                   	pop    %ebp
  800828:	c3                   	ret    

00800829 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	53                   	push   %ebx
  80082d:	8b 45 08             	mov    0x8(%ebp),%eax
  800830:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800833:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800838:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80083c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80083f:	83 c2 01             	add    $0x1,%edx
  800842:	84 c9                	test   %cl,%cl
  800844:	75 f2                	jne    800838 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800846:	5b                   	pop    %ebx
  800847:	5d                   	pop    %ebp
  800848:	c3                   	ret    

00800849 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800853:	89 1c 24             	mov    %ebx,(%esp)
  800856:	e8 95 ff ff ff       	call   8007f0 <strlen>
	strcpy(dst + len, src);
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800862:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800865:	89 04 24             	mov    %eax,(%esp)
  800868:	e8 bc ff ff ff       	call   800829 <strcpy>
	return dst;
}
  80086d:	89 d8                	mov    %ebx,%eax
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	5b                   	pop    %ebx
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	56                   	push   %esi
  800879:	53                   	push   %ebx
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800880:	8b 75 10             	mov    0x10(%ebp),%esi
  800883:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800888:	eb 0f                	jmp    800899 <strncpy+0x24>
		*dst++ = *src;
  80088a:	0f b6 19             	movzbl (%ecx),%ebx
  80088d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800890:	80 39 01             	cmpb   $0x1,(%ecx)
  800893:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800896:	83 c2 01             	add    $0x1,%edx
  800899:	39 f2                	cmp    %esi,%edx
  80089b:	72 ed                	jb     80088a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089d:	5b                   	pop    %ebx
  80089e:	5e                   	pop    %esi
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	56                   	push   %esi
  8008a5:	53                   	push   %ebx
  8008a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ac:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008af:	89 f0                	mov    %esi,%eax
  8008b1:	85 d2                	test   %edx,%edx
  8008b3:	75 0a                	jne    8008bf <strlcpy+0x1e>
  8008b5:	eb 17                	jmp    8008ce <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b7:	88 18                	mov    %bl,(%eax)
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008bf:	83 ea 01             	sub    $0x1,%edx
  8008c2:	74 07                	je     8008cb <strlcpy+0x2a>
  8008c4:	0f b6 19             	movzbl (%ecx),%ebx
  8008c7:	84 db                	test   %bl,%bl
  8008c9:	75 ec                	jne    8008b7 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  8008cb:	c6 00 00             	movb   $0x0,(%eax)
  8008ce:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008dd:	eb 06                	jmp    8008e5 <strcmp+0x11>
		p++, q++;
  8008df:	83 c1 01             	add    $0x1,%ecx
  8008e2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e5:	0f b6 01             	movzbl (%ecx),%eax
  8008e8:	84 c0                	test   %al,%al
  8008ea:	74 04                	je     8008f0 <strcmp+0x1c>
  8008ec:	3a 02                	cmp    (%edx),%al
  8008ee:	74 ef                	je     8008df <strcmp+0xb>
  8008f0:	0f b6 c0             	movzbl %al,%eax
  8008f3:	0f b6 12             	movzbl (%edx),%edx
  8008f6:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800904:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800907:	eb 09                	jmp    800912 <strncmp+0x18>
		n--, p++, q++;
  800909:	83 ea 01             	sub    $0x1,%edx
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800912:	85 d2                	test   %edx,%edx
  800914:	75 07                	jne    80091d <strncmp+0x23>
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	eb 13                	jmp    800930 <strncmp+0x36>
  80091d:	0f b6 18             	movzbl (%eax),%ebx
  800920:	84 db                	test   %bl,%bl
  800922:	74 04                	je     800928 <strncmp+0x2e>
  800924:	3a 19                	cmp    (%ecx),%bl
  800926:	74 e1                	je     800909 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800928:	0f b6 00             	movzbl (%eax),%eax
  80092b:	0f b6 11             	movzbl (%ecx),%edx
  80092e:	29 d0                	sub    %edx,%eax
}
  800930:	5b                   	pop    %ebx
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	8b 45 08             	mov    0x8(%ebp),%eax
  800939:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093d:	eb 07                	jmp    800946 <strchr+0x13>
		if (*s == c)
  80093f:	38 ca                	cmp    %cl,%dl
  800941:	74 0f                	je     800952 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800943:	83 c0 01             	add    $0x1,%eax
  800946:	0f b6 10             	movzbl (%eax),%edx
  800949:	84 d2                	test   %dl,%dl
  80094b:	75 f2                	jne    80093f <strchr+0xc>
  80094d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095e:	eb 07                	jmp    800967 <strfind+0x13>
		if (*s == c)
  800960:	38 ca                	cmp    %cl,%dl
  800962:	74 0a                	je     80096e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800964:	83 c0 01             	add    $0x1,%eax
  800967:	0f b6 10             	movzbl (%eax),%edx
  80096a:	84 d2                	test   %dl,%dl
  80096c:	75 f2                	jne    800960 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  80096e:	5d                   	pop    %ebp
  80096f:	90                   	nop
  800970:	c3                   	ret    

00800971 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	83 ec 0c             	sub    $0xc,%esp
  800977:	89 1c 24             	mov    %ebx,(%esp)
  80097a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80097e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800982:	8b 7d 08             	mov    0x8(%ebp),%edi
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098b:	85 c9                	test   %ecx,%ecx
  80098d:	74 30                	je     8009bf <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800995:	75 25                	jne    8009bc <memset+0x4b>
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 20                	jne    8009bc <memset+0x4b>
		c &= 0xFF;
  80099c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099f:	89 d3                	mov    %edx,%ebx
  8009a1:	c1 e3 08             	shl    $0x8,%ebx
  8009a4:	89 d6                	mov    %edx,%esi
  8009a6:	c1 e6 18             	shl    $0x18,%esi
  8009a9:	89 d0                	mov    %edx,%eax
  8009ab:	c1 e0 10             	shl    $0x10,%eax
  8009ae:	09 f0                	or     %esi,%eax
  8009b0:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009b2:	09 d8                	or     %ebx,%eax
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
  8009b7:	fc                   	cld    
  8009b8:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ba:	eb 03                	jmp    8009bf <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009bc:	fc                   	cld    
  8009bd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009bf:	89 f8                	mov    %edi,%eax
  8009c1:	8b 1c 24             	mov    (%esp),%ebx
  8009c4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009c8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009cc:	89 ec                	mov    %ebp,%esp
  8009ce:	5d                   	pop    %ebp
  8009cf:	c3                   	ret    

008009d0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	83 ec 08             	sub    $0x8,%esp
  8009d6:	89 34 24             	mov    %esi,(%esp)
  8009d9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  8009e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8009e6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8009e8:	39 c6                	cmp    %eax,%esi
  8009ea:	73 35                	jae    800a21 <memmove+0x51>
  8009ec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ef:	39 d0                	cmp    %edx,%eax
  8009f1:	73 2e                	jae    800a21 <memmove+0x51>
		s += n;
		d += n;
  8009f3:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f5:	f6 c2 03             	test   $0x3,%dl
  8009f8:	75 1b                	jne    800a15 <memmove+0x45>
  8009fa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a00:	75 13                	jne    800a15 <memmove+0x45>
  800a02:	f6 c1 03             	test   $0x3,%cl
  800a05:	75 0e                	jne    800a15 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a07:	83 ef 04             	sub    $0x4,%edi
  800a0a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a0d:	c1 e9 02             	shr    $0x2,%ecx
  800a10:	fd                   	std    
  800a11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a13:	eb 09                	jmp    800a1e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a15:	83 ef 01             	sub    $0x1,%edi
  800a18:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a1b:	fd                   	std    
  800a1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a1e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a1f:	eb 20                	jmp    800a41 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a27:	75 15                	jne    800a3e <memmove+0x6e>
  800a29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2f:	75 0d                	jne    800a3e <memmove+0x6e>
  800a31:	f6 c1 03             	test   $0x3,%cl
  800a34:	75 08                	jne    800a3e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a36:	c1 e9 02             	shr    $0x2,%ecx
  800a39:	fc                   	cld    
  800a3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3c:	eb 03                	jmp    800a41 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a3e:	fc                   	cld    
  800a3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a41:	8b 34 24             	mov    (%esp),%esi
  800a44:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a48:	89 ec                	mov    %ebp,%esp
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a52:	8b 45 10             	mov    0x10(%ebp),%eax
  800a55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	89 04 24             	mov    %eax,(%esp)
  800a66:	e8 65 ff ff ff       	call   8009d0 <memmove>
}
  800a6b:	c9                   	leave  
  800a6c:	c3                   	ret    

00800a6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	57                   	push   %edi
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a79:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a7c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a81:	eb 1c                	jmp    800a9f <memcmp+0x32>
		if (*s1 != *s2)
  800a83:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800a87:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800a8b:	83 c2 01             	add    $0x1,%edx
  800a8e:	83 e9 01             	sub    $0x1,%ecx
  800a91:	38 d8                	cmp    %bl,%al
  800a93:	74 0a                	je     800a9f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800a95:	0f b6 c0             	movzbl %al,%eax
  800a98:	0f b6 db             	movzbl %bl,%ebx
  800a9b:	29 d8                	sub    %ebx,%eax
  800a9d:	eb 09                	jmp    800aa8 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a9f:	85 c9                	test   %ecx,%ecx
  800aa1:	75 e0                	jne    800a83 <memcmp+0x16>
  800aa3:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5f                   	pop    %edi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab6:	89 c2                	mov    %eax,%edx
  800ab8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800abb:	eb 07                	jmp    800ac4 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abd:	38 08                	cmp    %cl,(%eax)
  800abf:	74 07                	je     800ac8 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ac1:	83 c0 01             	add    $0x1,%eax
  800ac4:	39 d0                	cmp    %edx,%eax
  800ac6:	72 f5                	jb     800abd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	57                   	push   %edi
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
  800ad0:	83 ec 04             	sub    $0x4,%esp
  800ad3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad9:	eb 03                	jmp    800ade <strtol+0x14>
		s++;
  800adb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ade:	0f b6 02             	movzbl (%edx),%eax
  800ae1:	3c 20                	cmp    $0x20,%al
  800ae3:	74 f6                	je     800adb <strtol+0x11>
  800ae5:	3c 09                	cmp    $0x9,%al
  800ae7:	74 f2                	je     800adb <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ae9:	3c 2b                	cmp    $0x2b,%al
  800aeb:	75 0c                	jne    800af9 <strtol+0x2f>
		s++;
  800aed:	8d 52 01             	lea    0x1(%edx),%edx
  800af0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800af7:	eb 15                	jmp    800b0e <strtol+0x44>
	else if (*s == '-')
  800af9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b00:	3c 2d                	cmp    $0x2d,%al
  800b02:	75 0a                	jne    800b0e <strtol+0x44>
		s++, neg = 1;
  800b04:	8d 52 01             	lea    0x1(%edx),%edx
  800b07:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b0e:	85 db                	test   %ebx,%ebx
  800b10:	0f 94 c0             	sete   %al
  800b13:	74 05                	je     800b1a <strtol+0x50>
  800b15:	83 fb 10             	cmp    $0x10,%ebx
  800b18:	75 18                	jne    800b32 <strtol+0x68>
  800b1a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b1d:	75 13                	jne    800b32 <strtol+0x68>
  800b1f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b23:	75 0d                	jne    800b32 <strtol+0x68>
		s += 2, base = 16;
  800b25:	83 c2 02             	add    $0x2,%edx
  800b28:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2d:	8d 76 00             	lea    0x0(%esi),%esi
  800b30:	eb 13                	jmp    800b45 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b32:	84 c0                	test   %al,%al
  800b34:	74 0f                	je     800b45 <strtol+0x7b>
  800b36:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b3b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b3e:	75 05                	jne    800b45 <strtol+0x7b>
		s++, base = 8;
  800b40:	83 c2 01             	add    $0x1,%edx
  800b43:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b45:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b4c:	0f b6 0a             	movzbl (%edx),%ecx
  800b4f:	89 cf                	mov    %ecx,%edi
  800b51:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b54:	80 fb 09             	cmp    $0x9,%bl
  800b57:	77 08                	ja     800b61 <strtol+0x97>
			dig = *s - '0';
  800b59:	0f be c9             	movsbl %cl,%ecx
  800b5c:	83 e9 30             	sub    $0x30,%ecx
  800b5f:	eb 1e                	jmp    800b7f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b61:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800b64:	80 fb 19             	cmp    $0x19,%bl
  800b67:	77 08                	ja     800b71 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800b69:	0f be c9             	movsbl %cl,%ecx
  800b6c:	83 e9 57             	sub    $0x57,%ecx
  800b6f:	eb 0e                	jmp    800b7f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b71:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800b74:	80 fb 19             	cmp    $0x19,%bl
  800b77:	77 15                	ja     800b8e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800b79:	0f be c9             	movsbl %cl,%ecx
  800b7c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b7f:	39 f1                	cmp    %esi,%ecx
  800b81:	7d 0b                	jge    800b8e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800b83:	83 c2 01             	add    $0x1,%edx
  800b86:	0f af c6             	imul   %esi,%eax
  800b89:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800b8c:	eb be                	jmp    800b4c <strtol+0x82>
  800b8e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800b90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b94:	74 05                	je     800b9b <strtol+0xd1>
		*endptr = (char *) s;
  800b96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b99:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800b9f:	74 04                	je     800ba5 <strtol+0xdb>
  800ba1:	89 c8                	mov    %ecx,%eax
  800ba3:	f7 d8                	neg    %eax
}
  800ba5:	83 c4 04             	add    $0x4,%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    
  800bad:	00 00                	add    %al,(%eax)
	...

00800bb0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	89 1c 24             	mov    %ebx,(%esp)
  800bb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bbd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcc:	89 c3                	mov    %eax,%ebx
  800bce:	89 c7                	mov    %eax,%edi
  800bd0:	89 c6                	mov    %eax,%esi
  800bd2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bd4:	8b 1c 24             	mov    (%esp),%ebx
  800bd7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bdb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800bdf:	89 ec                	mov    %ebp,%esp
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	83 ec 38             	sub    $0x38,%esp
  800be9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800bec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800bef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800bf2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf6:	75 0c                	jne    800c04 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800bf8:	c7 04 24 e8 19 80 00 	movl   $0x8019e8,(%esp)
  800bff:	e8 b9 f5 ff ff       	call   8001bd <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c09:	b8 09 00 00 00       	mov    $0x9,%eax
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	89 df                	mov    %ebx,%edi
  800c16:	89 de                	mov    %ebx,%esi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 28                	jle    800c46 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c22:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c29:	00 
  800c2a:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  800c31:	00 
  800c32:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c39:	00 
  800c3a:	c7 04 24 31 1a 80 00 	movl   $0x801a31,(%esp)
  800c41:	e8 a2 07 00 00       	call   8013e8 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c46:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800c49:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800c4c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800c4f:	89 ec                	mov    %ebp,%esp
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	83 ec 38             	sub    $0x38,%esp
  800c59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6f:	89 cb                	mov    %ecx,%ebx
  800c71:	89 cf                	mov    %ecx,%edi
  800c73:	89 ce                	mov    %ecx,%esi
  800c75:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7e 28                	jle    800ca3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c7f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800c86:	00 
  800c87:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  800c8e:	00 
  800c8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c96:	00 
  800c97:	c7 04 24 31 1a 80 00 	movl   $0x801a31,(%esp)
  800c9e:	e8 45 07 00 00       	call   8013e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ca3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ca6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ca9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cac:	89 ec                	mov    %ebp,%esp
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	89 1c 24             	mov    %ebx,(%esp)
  800cb9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cbd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	be 00 00 00 00       	mov    $0x0,%esi
  800cc6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ccb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cd9:	8b 1c 24             	mov    (%esp),%ebx
  800cdc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ce0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce4:	89 ec                	mov    %ebp,%esp
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 38             	sub    $0x38,%esp
  800cee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cf1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cf4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	b8 08 00 00 00       	mov    $0x8,%eax
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7e 28                	jle    800d39 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d11:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d15:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  800d24:	00 
  800d25:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d2c:	00 
  800d2d:	c7 04 24 31 1a 80 00 	movl   $0x801a31,(%esp)
  800d34:	e8 af 06 00 00       	call   8013e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d39:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d3c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d42:	89 ec                	mov    %ebp,%esp
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 38             	sub    $0x38,%esp
  800d4c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d52:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 28                	jle    800d97 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d73:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d7a:	00 
  800d7b:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  800d82:	00 
  800d83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8a:	00 
  800d8b:	c7 04 24 31 1a 80 00 	movl   $0x801a31,(%esp)
  800d92:	e8 51 06 00 00       	call   8013e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da0:	89 ec                	mov    %ebp,%esp
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 38             	sub    $0x38,%esp
  800daa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	b8 05 00 00 00       	mov    $0x5,%eax
  800db8:	8b 75 18             	mov    0x18(%ebp),%esi
  800dbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 28                	jle    800df5 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd1:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 31 1a 80 00 	movl   $0x801a31,(%esp)
  800df0:	e8 f3 05 00 00       	call   8013e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfe:	89 ec                	mov    %ebp,%esp
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 38             	sub    $0x38,%esp
  800e08:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	be 00 00 00 00       	mov    $0x0,%esi
  800e16:	b8 04 00 00 00       	mov    $0x4,%eax
  800e1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	8b 55 08             	mov    0x8(%ebp),%edx
  800e24:	89 f7                	mov    %esi,%edi
  800e26:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	7e 28                	jle    800e54 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e30:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e37:	00 
  800e38:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  800e3f:	00 
  800e40:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e47:	00 
  800e48:	c7 04 24 31 1a 80 00 	movl   $0x801a31,(%esp)
  800e4f:	e8 94 05 00 00       	call   8013e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e54:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e57:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e5a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5d:	89 ec                	mov    %ebp,%esp
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	83 ec 0c             	sub    $0xc,%esp
  800e67:	89 1c 24             	mov    %ebx,(%esp)
  800e6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e72:	ba 00 00 00 00       	mov    $0x0,%edx
  800e77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7c:	89 d1                	mov    %edx,%ecx
  800e7e:	89 d3                	mov    %edx,%ebx
  800e80:	89 d7                	mov    %edx,%edi
  800e82:	89 d6                	mov    %edx,%esi
  800e84:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e86:	8b 1c 24             	mov    (%esp),%ebx
  800e89:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e8d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e91:	89 ec                	mov    %ebp,%esp
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 0c             	sub    $0xc,%esp
  800e9b:	89 1c 24             	mov    %ebx,(%esp)
  800e9e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ea2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	ba 00 00 00 00       	mov    $0x0,%edx
  800eab:	b8 02 00 00 00       	mov    $0x2,%eax
  800eb0:	89 d1                	mov    %edx,%ecx
  800eb2:	89 d3                	mov    %edx,%ebx
  800eb4:	89 d7                	mov    %edx,%edi
  800eb6:	89 d6                	mov    %edx,%esi
  800eb8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800eba:	8b 1c 24             	mov    (%esp),%ebx
  800ebd:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ec1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ec5:	89 ec                	mov    %ebp,%esp
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    

00800ec9 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	83 ec 38             	sub    $0x38,%esp
  800ecf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800edd:	b8 03 00 00 00       	mov    $0x3,%eax
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee5:	89 cb                	mov    %ecx,%ebx
  800ee7:	89 cf                	mov    %ecx,%edi
  800ee9:	89 ce                	mov    %ecx,%esi
  800eeb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eed:	85 c0                	test   %eax,%eax
  800eef:	7e 28                	jle    800f19 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ef5:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800efc:	00 
  800efd:	c7 44 24 08 14 1a 80 	movl   $0x801a14,0x8(%esp)
  800f04:	00 
  800f05:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f0c:	00 
  800f0d:	c7 04 24 31 1a 80 00 	movl   $0x801a31,(%esp)
  800f14:	e8 cf 04 00 00       	call   8013e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f19:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f1c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f1f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f22:	89 ec                	mov    %ebp,%esp
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    

00800f26 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f26:	55                   	push   %ebp
  800f27:	89 e5                	mov    %esp,%ebp
  800f29:	83 ec 0c             	sub    $0xc,%esp
  800f2c:	89 1c 24             	mov    %ebx,(%esp)
  800f2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f33:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f37:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f41:	89 d1                	mov    %edx,%ecx
  800f43:	89 d3                	mov    %edx,%ebx
  800f45:	89 d7                	mov    %edx,%edi
  800f47:	89 d6                	mov    %edx,%esi
  800f49:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f4b:	8b 1c 24             	mov    (%esp),%ebx
  800f4e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f52:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f56:	89 ec                	mov    %ebp,%esp
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
	...

00800f5c <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  800f62:	c7 44 24 08 3f 1a 80 	movl   $0x801a3f,0x8(%esp)
  800f69:	00 
  800f6a:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  800f71:	00 
  800f72:	c7 04 24 55 1a 80 00 	movl   $0x801a55,(%esp)
  800f79:	e8 6a 04 00 00       	call   8013e8 <_panic>

00800f7e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	56                   	push   %esi
  800f82:	53                   	push   %ebx
  800f83:	83 ec 20             	sub    $0x20,%esp
  800f86:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f89:	8b 30                	mov    (%eax),%esi
	uint32_t err = utf->utf_err;
  800f8b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f8f:	75 1c                	jne    800fad <pgfault+0x2f>

	// LAB 4: Your code here.
	FORKDEBUG("lib pgfault: fault address 0x%08x\n",(int)addr);

	if ( (err&FEC_WR) == 0 ) {
		panic("lib pgfault: The page fault is not caused by write\n");
  800f91:	c7 44 24 08 80 1a 80 	movl   $0x801a80,0x8(%esp)
  800f98:	00 
  800f99:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  800fa0:	00 
  800fa1:	c7 04 24 55 1a 80 00 	movl   $0x801a55,(%esp)
  800fa8:	e8 3b 04 00 00       	call   8013e8 <_panic>
	} 
	
	if ( (uvpt[PGNUM(addr)]&PTE_COW) == 0 ) {
  800fad:	89 f0                	mov    %esi,%eax
  800faf:	c1 e8 0c             	shr    $0xc,%eax
  800fb2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb9:	f6 c4 08             	test   $0x8,%ah
  800fbc:	75 1c                	jne    800fda <pgfault+0x5c>
		panic("lib pgfault: The page fault's page is not COW\n");
  800fbe:	c7 44 24 08 b4 1a 80 	movl   $0x801ab4,0x8(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  800fcd:	00 
  800fce:	c7 04 24 55 1a 80 00 	movl   $0x801a55,(%esp)
  800fd5:	e8 0e 04 00 00       	call   8013e8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
		
	envid_t envid=sys_getenvid();
  800fda:	e8 b6 fe ff ff       	call   800e95 <sys_getenvid>
  800fdf:	89 c3                	mov    %eax,%ebx
	int res;
	
	res=sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W);
  800fe1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ff0:	00 
  800ff1:	89 04 24             	mov    %eax,(%esp)
  800ff4:	e8 09 fe ff ff       	call   800e02 <sys_page_alloc>
	if (res<0) {
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	79 1c                	jns    801019 <pgfault+0x9b>
		panic("lib pgfault: cannot allocate temp page\n");
  800ffd:	c7 44 24 08 e4 1a 80 	movl   $0x801ae4,0x8(%esp)
  801004:	00 
  801005:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  80100c:	00 
  80100d:	c7 04 24 55 1a 80 00 	movl   $0x801a55,(%esp)
  801014:	e8 cf 03 00 00       	call   8013e8 <_panic>
	}

	memmove(PFTEMP, (void*)ROUNDDOWN(addr,PGSIZE),PGSIZE);
  801019:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  80101f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801026:	00 
  801027:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801032:	e8 99 f9 ff ff       	call   8009d0 <memmove>
	
	res=sys_page_map(envid,PFTEMP,envid,(void*)ROUNDDOWN(addr,PGSIZE), PTE_U | PTE_P | PTE_W);
  801037:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80103e:	00 
  80103f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801043:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801047:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80104e:	00 
  80104f:	89 1c 24             	mov    %ebx,(%esp)
  801052:	e8 4d fd ff ff       	call   800da4 <sys_page_map>
	if (res<0) {
  801057:	85 c0                	test   %eax,%eax
  801059:	79 1c                	jns    801077 <pgfault+0xf9>
		panic("lib pgfault: cannot map page\n");
  80105b:	c7 44 24 08 60 1a 80 	movl   $0x801a60,0x8(%esp)
  801062:	00 
  801063:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80106a:	00 
  80106b:	c7 04 24 55 1a 80 00 	movl   $0x801a55,(%esp)
  801072:	e8 71 03 00 00       	call   8013e8 <_panic>
	}

	res=sys_page_unmap(envid,PFTEMP);
  801077:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80107e:	00 
  80107f:	89 1c 24             	mov    %ebx,(%esp)
  801082:	e8 bf fc ff ff       	call   800d46 <sys_page_unmap>
	if (res<0) {
  801087:	85 c0                	test   %eax,%eax
  801089:	79 1c                	jns    8010a7 <pgfault+0x129>
		panic("lib pgfault: cannot unmap page\n");
  80108b:	c7 44 24 08 0c 1b 80 	movl   $0x801b0c,0x8(%esp)
  801092:	00 
  801093:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  80109a:	00 
  80109b:	c7 04 24 55 1a 80 00 	movl   $0x801a55,(%esp)
  8010a2:	e8 41 03 00 00       	call   8013e8 <_panic>
	}
	return;
	//panic("pgfault not implemented");
}
  8010a7:	83 c4 20             	add    $0x20,%esp
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5d                   	pop    %ebp
  8010ad:	c3                   	ret    

008010ae <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 4: Your code here.
	int i,j,pn=0;
	envid_t curenvid=sys_getenvid();
  8010b7:	e8 d9 fd ff ff       	call   800e95 <sys_getenvid>
  8010bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	envid_t envid;
	int r;
	

	FORKDEBUG("fork: start to fork\n");
	set_pgfault_handler(pgfault);
  8010bf:	c7 04 24 7e 0f 80 00 	movl   $0x800f7e,(%esp)
  8010c6:	e8 75 03 00 00       	call   801440 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010cb:	ba 07 00 00 00       	mov    $0x7,%edx
  8010d0:	89 d0                	mov    %edx,%eax
  8010d2:	cd 30                	int    $0x30
  8010d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	FORKDEBUG("fork: already set pgfault handler\n");


	if ( (envid = sys_exofork()) < 0) {
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	0f 88 c2 01 00 00    	js     8012a1 <fork+0x1f3>
		return -1;
	}	

	FORKDEBUG("fork: already sys_exofork\n");
	
	if ( envid==0 ) {
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	75 39                	jne    80111c <fork+0x6e>

		FORKDEBUG("fork: I am the child\n");
		sys_page_alloc(sys_getenvid(),(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P);
  8010e3:	e8 ad fd ff ff       	call   800e95 <sys_getenvid>
  8010e8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010ef:	00 
  8010f0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010f7:	ee 
  8010f8:	89 04 24             	mov    %eax,(%esp)
  8010fb:	e8 02 fd ff ff       	call   800e02 <sys_page_alloc>

		thisenv=&envs[ENVX(sys_getenvid())];
  801100:	e8 90 fd ff ff       	call   800e95 <sys_getenvid>
  801105:	25 ff 03 00 00       	and    $0x3ff,%eax
  80110a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80110d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801112:	a3 04 20 80 00       	mov    %eax,0x802004
		return envid;
  801117:	e9 8c 01 00 00       	jmp    8012a8 <fork+0x1fa>
  80111c:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
  801123:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801126:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  80112d:	a8 01                	test   $0x1,%al
  80112f:	0f 84 a9 00 00 00    	je     8011de <fork+0x130>
			for ( j=0;j<NPTENTRIES;j++) {
		//		cprintf("i: %d, j:%d\n",i,j);
				pn=PGNUM(PGADDR(i,j,0));
  801135:	c1 e2 16             	shl    $0x16,%edx
  801138:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80113b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801140:	89 de                	mov    %ebx,%esi
  801142:	c1 e6 0c             	shl    $0xc,%esi
  801145:	0b 75 e4             	or     -0x1c(%ebp),%esi
  801148:	c1 ee 0c             	shr    $0xc,%esi
				if ( pn== PGNUM(UXSTACKTOP-PGSIZE) ) {
  80114b:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801151:	0f 84 87 00 00 00    	je     8011de <fork+0x130>
					break;
				}
				if ( uvpt[pn] & PTE_P ) {
  801157:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80115e:	a8 01                	test   $0x1,%al
  801160:	74 6d                	je     8011cf <fork+0x121>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid();
  801162:	e8 2e fd ff ff       	call   800e95 <sys_getenvid>
  801167:	89 45 e0             	mov    %eax,-0x20(%ebp)

	pte_t pte = uvpt[pn];
  80116a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm;

	perm = PTE_U | PTE_P;
	if ( pte & PTE_W || pte & PTE_COW ) {
  801171:	25 02 08 00 00       	and    $0x802,%eax
  801176:	83 f8 01             	cmp    $0x1,%eax
  801179:	19 ff                	sbb    %edi,%edi
  80117b:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801181:	81 c7 05 08 00 00    	add    $0x805,%edi
		perm |= PTE_COW;
	}

	r=sys_page_map(curenvid, (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE),perm);
  801187:	c1 e6 0c             	shl    $0xc,%esi
  80118a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80118e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801192:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801195:	89 44 24 08          	mov    %eax,0x8(%esp)
  801199:	89 74 24 04          	mov    %esi,0x4(%esp)
  80119d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8011a0:	89 14 24             	mov    %edx,(%esp)
  8011a3:	e8 fc fb ff ff       	call   800da4 <sys_page_map>
	if (r<0) {
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	78 23                	js     8011cf <fork+0x121>
		FORKDEBUG("lib duppage: sys_page_map curenvid fail\n");
		return r;
	}
	
	if ( perm & PTE_COW ) {
  8011ac:	f7 c7 00 08 00 00    	test   $0x800,%edi
  8011b2:	74 1b                	je     8011cf <fork+0x121>
		r=sys_page_map(curenvid, (void*)(pn*PGSIZE), curenvid, (void*)(pn*PGSIZE), perm);
  8011b4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8011b8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8011bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011c7:	89 04 24             	mov    %eax,(%esp)
  8011ca:	e8 d5 fb ff ff       	call   800da4 <sys_page_map>
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
			for ( j=0;j<NPTENTRIES;j++) {
  8011cf:	83 c3 01             	add    $0x1,%ebx
  8011d2:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8011d8:	0f 85 62 ff ff ff    	jne    801140 <fork+0x92>
//			duppage(envid,pn);
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
  8011de:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  8011e2:	81 7d dc bb 03 00 00 	cmpl   $0x3bb,-0x24(%ebp)
  8011e9:	0f 85 34 ff ff ff    	jne    801123 <fork+0x75>
			}
		}
	}
	FORKDEBUG("lib fork: after duppage\n");
	
	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_U | PTE_P | PTE_W)<0 ) {
  8011ef:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011f6:	00 
  8011f7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011fe:	ee 
  8011ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801202:	89 14 24             	mov    %edx,(%esp)
  801205:	e8 f8 fb ff ff       	call   800e02 <sys_page_alloc>
  80120a:	85 c0                	test   %eax,%eax
  80120c:	0f 88 8f 00 00 00    	js     8012a1 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_alloc fail\n");
		return -1;
	}

	if (sys_page_map(envid,(void*)(UXSTACKTOP-PGSIZE),curenvid,PFTEMP, PTE_U | PTE_P | PTE_W)<0) {
  801212:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801219:	00 
  80121a:	c7 44 24 0c 00 f0 7f 	movl   $0x7ff000,0xc(%esp)
  801221:	00 
  801222:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801225:	89 44 24 08          	mov    %eax,0x8(%esp)
  801229:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801230:	ee 
  801231:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801234:	89 14 24             	mov    %edx,(%esp)
  801237:	e8 68 fb ff ff       	call   800da4 <sys_page_map>
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 61                	js     8012a1 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_map envid fail\n");
		return -1;
	}

	memmove((void*)(UXSTACKTOP-PGSIZE) , PFTEMP ,PGSIZE);
  801240:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801247:	00 
  801248:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80124f:	00 
  801250:	c7 04 24 00 f0 bf ee 	movl   $0xeebff000,(%esp)
  801257:	e8 74 f7 ff ff       	call   8009d0 <memmove>
	
	if (sys_page_unmap(curenvid,PFTEMP)<0) {
  80125c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801263:	00 
  801264:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801267:	89 04 24             	mov    %eax,(%esp)
  80126a:	e8 d7 fa ff ff       	call   800d46 <sys_page_unmap>
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 2e                	js     8012a1 <fork+0x1f3>
		return -1;
	}

	extern void _pgfault_upcall(void);

	if (sys_env_set_pgfault_upcall(envid,_pgfault_upcall)<0) {
  801273:	c7 44 24 04 b4 14 80 	movl   $0x8014b4,0x4(%esp)
  80127a:	00 
  80127b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80127e:	89 14 24             	mov    %edx,(%esp)
  801281:	e8 5d f9 ff ff       	call   800be3 <sys_env_set_pgfault_upcall>
  801286:	85 c0                	test   %eax,%eax
  801288:	78 17                	js     8012a1 <fork+0x1f3>
//	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P)<0) {
//		FORKDEBUG("lib fork: sys_page_alloc fail\n");
//		return -1;
//	}		

	if (sys_env_set_status(envid, ENV_RUNNABLE)<0) {
  80128a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801291:	00 
  801292:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801295:	89 04 24             	mov    %eax,(%esp)
  801298:	e8 4b fa ff ff       	call   800ce8 <sys_env_set_status>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	79 07                	jns    8012a8 <fork+0x1fa>
  8012a1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)

	FORKDEBUG("lib fork: finish fork\n");

	return envid;
//	panic("fork not implemented");
}
  8012a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012ab:	83 c4 4c             	add    $0x4c,%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5f                   	pop    %edi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    
	...

008012c0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8012cb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8012ce:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8012d4:	8b 12                	mov    (%edx),%edx
  8012d6:	39 ca                	cmp    %ecx,%edx
  8012d8:	75 0c                	jne    8012e6 <ipc_find_env+0x26>
			return envs[i].env_id;
  8012da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012dd:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  8012e2:	8b 00                	mov    (%eax),%eax
  8012e4:	eb 0e                	jmp    8012f4 <ipc_find_env+0x34>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012e6:	83 c0 01             	add    $0x1,%eax
  8012e9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012ee:	75 db                	jne    8012cb <ipc_find_env+0xb>
  8012f0:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    

008012f6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	57                   	push   %edi
  8012fa:	56                   	push   %esi
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 2c             	sub    $0x2c,%esp
  8012ff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801302:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int res;
	do {
		res=sys_ipc_try_send(to_env,val,pg?pg:(void*)UTOP,perm);
  801305:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  801308:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80130d:	85 f6                	test   %esi,%esi
  80130f:	74 03                	je     801314 <ipc_send+0x1e>
  801311:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801314:	8b 55 14             	mov    0x14(%ebp),%edx
  801317:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80131b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80131f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801322:	89 44 24 04          	mov    %eax,0x4(%esp)
  801326:	89 3c 24             	mov    %edi,(%esp)
  801329:	e8 82 f9 ff ff       	call   800cb0 <sys_ipc_try_send>
		
		if( res!=0 && res!= -E_IPC_NOT_RECV) {
  80132e:	85 c0                	test   %eax,%eax
  801330:	0f 95 c3             	setne  %bl
  801333:	74 21                	je     801356 <ipc_send+0x60>
  801335:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801338:	74 1c                	je     801356 <ipc_send+0x60>
			panic("ipc_send: error\n");
  80133a:	c7 44 24 08 2c 1b 80 	movl   $0x801b2c,0x8(%esp)
  801341:	00 
  801342:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801349:	00 
  80134a:	c7 04 24 3d 1b 80 00 	movl   $0x801b3d,(%esp)
  801351:	e8 92 00 00 00       	call   8013e8 <_panic>
		}
		else {
			sys_yield();	
  801356:	e8 06 fb ff ff       	call   800e61 <sys_yield>
		}
	} while(res!=0);
  80135b:	84 db                	test   %bl,%bl
  80135d:	75 a9                	jne    801308 <ipc_send+0x12>
	
	
//	panic("ipc_send not implemented");
}
  80135f:	83 c4 2c             	add    $0x2c,%esp
  801362:	5b                   	pop    %ebx
  801363:	5e                   	pop    %esi
  801364:	5f                   	pop    %edi
  801365:	5d                   	pop    %ebp
  801366:	c3                   	ret    

00801367 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	83 ec 28             	sub    $0x28,%esp
  80136d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801370:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801373:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801376:	8b 75 08             	mov    0x8(%ebp),%esi
  801379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80137c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int res;

	res=sys_ipc_recv( pg?pg:(void*)UTOP);
  80137f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801384:	85 db                	test   %ebx,%ebx
  801386:	74 02                	je     80138a <ipc_recv+0x23>
  801388:	89 d8                	mov    %ebx,%eax
  80138a:	89 04 24             	mov    %eax,(%esp)
  80138d:	e8 c1 f8 ff ff       	call   800c53 <sys_ipc_recv>

	if( from_env_store) {
  801392:	85 f6                	test   %esi,%esi
  801394:	74 14                	je     8013aa <ipc_recv+0x43>
		*from_env_store = (res==0)? thisenv->env_ipc_from:0;
  801396:	ba 00 00 00 00       	mov    $0x0,%edx
  80139b:	85 c0                	test   %eax,%eax
  80139d:	75 09                	jne    8013a8 <ipc_recv+0x41>
  80139f:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8013a5:	8b 52 74             	mov    0x74(%edx),%edx
  8013a8:	89 16                	mov    %edx,(%esi)
	}

	if( perm_store) {
  8013aa:	85 ff                	test   %edi,%edi
  8013ac:	74 1f                	je     8013cd <ipc_recv+0x66>
		*perm_store = (res==0 && (uint32_t)pg < UTOP)? thisenv->env_ipc_perm:0;
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	75 08                	jne    8013ba <ipc_recv+0x53>
  8013b2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8013b8:	76 08                	jbe    8013c2 <ipc_recv+0x5b>
  8013ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8013bf:	90                   	nop
  8013c0:	eb 09                	jmp    8013cb <ipc_recv+0x64>
  8013c2:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8013c8:	8b 52 78             	mov    0x78(%edx),%edx
  8013cb:	89 17                	mov    %edx,(%edi)
	}
	
	if( res) {
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	75 08                	jne    8013d9 <ipc_recv+0x72>
		return res;
	}
	
//	panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8013d1:	a1 04 20 80 00       	mov    0x802004,%eax
  8013d6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8013d9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013dc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013df:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013e2:	89 ec                	mov    %ebp,%esp
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    
	...

008013e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8013f0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013f3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8013f9:	e8 97 fa ff ff       	call   800e95 <sys_getenvid>
  8013fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801401:	89 54 24 10          	mov    %edx,0x10(%esp)
  801405:	8b 55 08             	mov    0x8(%ebp),%edx
  801408:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80140c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801410:	89 44 24 04          	mov    %eax,0x4(%esp)
  801414:	c7 04 24 48 1b 80 00 	movl   $0x801b48,(%esp)
  80141b:	e8 9d ed ff ff       	call   8001bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801420:	89 74 24 04          	mov    %esi,0x4(%esp)
  801424:	8b 45 10             	mov    0x10(%ebp),%eax
  801427:	89 04 24             	mov    %eax,(%esp)
  80142a:	e8 2d ed ff ff       	call   80015c <vcprintf>
	cprintf("\n");
  80142f:	c7 04 24 7c 1a 80 00 	movl   $0x801a7c,(%esp)
  801436:	e8 82 ed ff ff       	call   8001bd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80143b:	cc                   	int3   
  80143c:	eb fd                	jmp    80143b <_panic+0x53>
	...

00801440 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801446:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80144d:	75 58                	jne    8014a7 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  80144f:	a1 04 20 80 00       	mov    0x802004,%eax
  801454:	8b 40 48             	mov    0x48(%eax),%eax
  801457:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80145e:	00 
  80145f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801466:	ee 
  801467:	89 04 24             	mov    %eax,(%esp)
  80146a:	e8 93 f9 ff ff       	call   800e02 <sys_page_alloc>
  80146f:	85 c0                	test   %eax,%eax
  801471:	74 1c                	je     80148f <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  801473:	c7 44 24 08 6c 1b 80 	movl   $0x801b6c,0x8(%esp)
  80147a:	00 
  80147b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801482:	00 
  801483:	c7 04 24 98 1b 80 00 	movl   $0x801b98,(%esp)
  80148a:	e8 59 ff ff ff       	call   8013e8 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  80148f:	a1 04 20 80 00       	mov    0x802004,%eax
  801494:	8b 40 48             	mov    0x48(%eax),%eax
  801497:	c7 44 24 04 b4 14 80 	movl   $0x8014b4,0x4(%esp)
  80149e:	00 
  80149f:	89 04 24             	mov    %eax,(%esp)
  8014a2:	e8 3c f7 ff ff       	call   800be3 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	a3 08 20 80 00       	mov    %eax,0x802008
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    
  8014b1:	00 00                	add    %al,(%eax)
	...

008014b4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014b4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014b5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  8014ba:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014bc:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl  %esp , %ebx
  8014bf:	89 e3                	mov    %esp,%ebx
	movl  40(%esp) , %eax
  8014c1:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl  48(%esp) , %esp
  8014c5:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl  %eax 
  8014c9:	50                   	push   %eax


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl  %ebx , %esp
  8014ca:	89 dc                	mov    %ebx,%esp
	subl  $4 , 48(%esp)
  8014cc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl  %eax
  8014d1:	58                   	pop    %eax
	popl  %eax
  8014d2:	58                   	pop    %eax
	popal
  8014d3:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4 , %esp
  8014d4:	83 c4 04             	add    $0x4,%esp
	popfl
  8014d7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8014d8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8014d9:	c3                   	ret    
  8014da:	00 00                	add    %al,(%eax)
  8014dc:	00 00                	add    %al,(%eax)
	...

008014e0 <__udivdi3>:
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	57                   	push   %edi
  8014e4:	56                   	push   %esi
  8014e5:	83 ec 10             	sub    $0x10,%esp
  8014e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8014f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8014f9:	75 35                	jne    801530 <__udivdi3+0x50>
  8014fb:	39 fe                	cmp    %edi,%esi
  8014fd:	77 61                	ja     801560 <__udivdi3+0x80>
  8014ff:	85 f6                	test   %esi,%esi
  801501:	75 0b                	jne    80150e <__udivdi3+0x2e>
  801503:	b8 01 00 00 00       	mov    $0x1,%eax
  801508:	31 d2                	xor    %edx,%edx
  80150a:	f7 f6                	div    %esi
  80150c:	89 c6                	mov    %eax,%esi
  80150e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801511:	31 d2                	xor    %edx,%edx
  801513:	89 f8                	mov    %edi,%eax
  801515:	f7 f6                	div    %esi
  801517:	89 c7                	mov    %eax,%edi
  801519:	89 c8                	mov    %ecx,%eax
  80151b:	f7 f6                	div    %esi
  80151d:	89 c1                	mov    %eax,%ecx
  80151f:	89 fa                	mov    %edi,%edx
  801521:	89 c8                	mov    %ecx,%eax
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	5e                   	pop    %esi
  801527:	5f                   	pop    %edi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    
  80152a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801530:	39 f8                	cmp    %edi,%eax
  801532:	77 1c                	ja     801550 <__udivdi3+0x70>
  801534:	0f bd d0             	bsr    %eax,%edx
  801537:	83 f2 1f             	xor    $0x1f,%edx
  80153a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80153d:	75 39                	jne    801578 <__udivdi3+0x98>
  80153f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801542:	0f 86 a0 00 00 00    	jbe    8015e8 <__udivdi3+0x108>
  801548:	39 f8                	cmp    %edi,%eax
  80154a:	0f 82 98 00 00 00    	jb     8015e8 <__udivdi3+0x108>
  801550:	31 ff                	xor    %edi,%edi
  801552:	31 c9                	xor    %ecx,%ecx
  801554:	89 c8                	mov    %ecx,%eax
  801556:	89 fa                	mov    %edi,%edx
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	5e                   	pop    %esi
  80155c:	5f                   	pop    %edi
  80155d:	5d                   	pop    %ebp
  80155e:	c3                   	ret    
  80155f:	90                   	nop
  801560:	89 d1                	mov    %edx,%ecx
  801562:	89 fa                	mov    %edi,%edx
  801564:	89 c8                	mov    %ecx,%eax
  801566:	31 ff                	xor    %edi,%edi
  801568:	f7 f6                	div    %esi
  80156a:	89 c1                	mov    %eax,%ecx
  80156c:	89 fa                	mov    %edi,%edx
  80156e:	89 c8                	mov    %ecx,%eax
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	5e                   	pop    %esi
  801574:	5f                   	pop    %edi
  801575:	5d                   	pop    %ebp
  801576:	c3                   	ret    
  801577:	90                   	nop
  801578:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80157c:	89 f2                	mov    %esi,%edx
  80157e:	d3 e0                	shl    %cl,%eax
  801580:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801583:	b8 20 00 00 00       	mov    $0x20,%eax
  801588:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80158b:	89 c1                	mov    %eax,%ecx
  80158d:	d3 ea                	shr    %cl,%edx
  80158f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801593:	0b 55 ec             	or     -0x14(%ebp),%edx
  801596:	d3 e6                	shl    %cl,%esi
  801598:	89 c1                	mov    %eax,%ecx
  80159a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80159d:	89 fe                	mov    %edi,%esi
  80159f:	d3 ee                	shr    %cl,%esi
  8015a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015ab:	d3 e7                	shl    %cl,%edi
  8015ad:	89 c1                	mov    %eax,%ecx
  8015af:	d3 ea                	shr    %cl,%edx
  8015b1:	09 d7                	or     %edx,%edi
  8015b3:	89 f2                	mov    %esi,%edx
  8015b5:	89 f8                	mov    %edi,%eax
  8015b7:	f7 75 ec             	divl   -0x14(%ebp)
  8015ba:	89 d6                	mov    %edx,%esi
  8015bc:	89 c7                	mov    %eax,%edi
  8015be:	f7 65 e8             	mull   -0x18(%ebp)
  8015c1:	39 d6                	cmp    %edx,%esi
  8015c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015c6:	72 30                	jb     8015f8 <__udivdi3+0x118>
  8015c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015cf:	d3 e2                	shl    %cl,%edx
  8015d1:	39 c2                	cmp    %eax,%edx
  8015d3:	73 05                	jae    8015da <__udivdi3+0xfa>
  8015d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8015d8:	74 1e                	je     8015f8 <__udivdi3+0x118>
  8015da:	89 f9                	mov    %edi,%ecx
  8015dc:	31 ff                	xor    %edi,%edi
  8015de:	e9 71 ff ff ff       	jmp    801554 <__udivdi3+0x74>
  8015e3:	90                   	nop
  8015e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015e8:	31 ff                	xor    %edi,%edi
  8015ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8015ef:	e9 60 ff ff ff       	jmp    801554 <__udivdi3+0x74>
  8015f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8015f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8015fb:	31 ff                	xor    %edi,%edi
  8015fd:	89 c8                	mov    %ecx,%eax
  8015ff:	89 fa                	mov    %edi,%edx
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	5e                   	pop    %esi
  801605:	5f                   	pop    %edi
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    
	...

00801610 <__umoddi3>:
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	57                   	push   %edi
  801614:	56                   	push   %esi
  801615:	83 ec 20             	sub    $0x20,%esp
  801618:	8b 55 14             	mov    0x14(%ebp),%edx
  80161b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80161e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801621:	8b 75 0c             	mov    0xc(%ebp),%esi
  801624:	85 d2                	test   %edx,%edx
  801626:	89 c8                	mov    %ecx,%eax
  801628:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80162b:	75 13                	jne    801640 <__umoddi3+0x30>
  80162d:	39 f7                	cmp    %esi,%edi
  80162f:	76 3f                	jbe    801670 <__umoddi3+0x60>
  801631:	89 f2                	mov    %esi,%edx
  801633:	f7 f7                	div    %edi
  801635:	89 d0                	mov    %edx,%eax
  801637:	31 d2                	xor    %edx,%edx
  801639:	83 c4 20             	add    $0x20,%esp
  80163c:	5e                   	pop    %esi
  80163d:	5f                   	pop    %edi
  80163e:	5d                   	pop    %ebp
  80163f:	c3                   	ret    
  801640:	39 f2                	cmp    %esi,%edx
  801642:	77 4c                	ja     801690 <__umoddi3+0x80>
  801644:	0f bd ca             	bsr    %edx,%ecx
  801647:	83 f1 1f             	xor    $0x1f,%ecx
  80164a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80164d:	75 51                	jne    8016a0 <__umoddi3+0x90>
  80164f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801652:	0f 87 e0 00 00 00    	ja     801738 <__umoddi3+0x128>
  801658:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165b:	29 f8                	sub    %edi,%eax
  80165d:	19 d6                	sbb    %edx,%esi
  80165f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801662:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801665:	89 f2                	mov    %esi,%edx
  801667:	83 c4 20             	add    $0x20,%esp
  80166a:	5e                   	pop    %esi
  80166b:	5f                   	pop    %edi
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    
  80166e:	66 90                	xchg   %ax,%ax
  801670:	85 ff                	test   %edi,%edi
  801672:	75 0b                	jne    80167f <__umoddi3+0x6f>
  801674:	b8 01 00 00 00       	mov    $0x1,%eax
  801679:	31 d2                	xor    %edx,%edx
  80167b:	f7 f7                	div    %edi
  80167d:	89 c7                	mov    %eax,%edi
  80167f:	89 f0                	mov    %esi,%eax
  801681:	31 d2                	xor    %edx,%edx
  801683:	f7 f7                	div    %edi
  801685:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801688:	f7 f7                	div    %edi
  80168a:	eb a9                	jmp    801635 <__umoddi3+0x25>
  80168c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801690:	89 c8                	mov    %ecx,%eax
  801692:	89 f2                	mov    %esi,%edx
  801694:	83 c4 20             	add    $0x20,%esp
  801697:	5e                   	pop    %esi
  801698:	5f                   	pop    %edi
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    
  80169b:	90                   	nop
  80169c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016a4:	d3 e2                	shl    %cl,%edx
  8016a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8016a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8016ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8016b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8016b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016b8:	89 fa                	mov    %edi,%edx
  8016ba:	d3 ea                	shr    %cl,%edx
  8016bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8016c3:	d3 e7                	shl    %cl,%edi
  8016c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8016cc:	89 f2                	mov    %esi,%edx
  8016ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8016d1:	89 c7                	mov    %eax,%edi
  8016d3:	d3 ea                	shr    %cl,%edx
  8016d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8016dc:	89 c2                	mov    %eax,%edx
  8016de:	d3 e6                	shl    %cl,%esi
  8016e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016e4:	d3 ea                	shr    %cl,%edx
  8016e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016ea:	09 d6                	or     %edx,%esi
  8016ec:	89 f0                	mov    %esi,%eax
  8016ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8016f1:	d3 e7                	shl    %cl,%edi
  8016f3:	89 f2                	mov    %esi,%edx
  8016f5:	f7 75 f4             	divl   -0xc(%ebp)
  8016f8:	89 d6                	mov    %edx,%esi
  8016fa:	f7 65 e8             	mull   -0x18(%ebp)
  8016fd:	39 d6                	cmp    %edx,%esi
  8016ff:	72 2b                	jb     80172c <__umoddi3+0x11c>
  801701:	39 c7                	cmp    %eax,%edi
  801703:	72 23                	jb     801728 <__umoddi3+0x118>
  801705:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801709:	29 c7                	sub    %eax,%edi
  80170b:	19 d6                	sbb    %edx,%esi
  80170d:	89 f0                	mov    %esi,%eax
  80170f:	89 f2                	mov    %esi,%edx
  801711:	d3 ef                	shr    %cl,%edi
  801713:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801717:	d3 e0                	shl    %cl,%eax
  801719:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80171d:	09 f8                	or     %edi,%eax
  80171f:	d3 ea                	shr    %cl,%edx
  801721:	83 c4 20             	add    $0x20,%esp
  801724:	5e                   	pop    %esi
  801725:	5f                   	pop    %edi
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    
  801728:	39 d6                	cmp    %edx,%esi
  80172a:	75 d9                	jne    801705 <__umoddi3+0xf5>
  80172c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80172f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801732:	eb d1                	jmp    801705 <__umoddi3+0xf5>
  801734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801738:	39 f2                	cmp    %esi,%edx
  80173a:	0f 82 18 ff ff ff    	jb     801658 <__umoddi3+0x48>
  801740:	e9 1d ff ff ff       	jmp    801662 <__umoddi3+0x52>
