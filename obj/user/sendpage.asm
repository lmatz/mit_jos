
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 5f 11 00 00       	call   80119e <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bd 00 00 00    	jne    800107 <umain+0xd3>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 f2 13 00 00       	call   801457 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 40 18 80 00 	movl   $0x801840,(%esp)
  80007b:	e8 29 02 00 00       	call   8002a9 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 00 20 80 00       	mov    0x802000,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 53 08 00 00       	call   8008e0 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 00 20 80 00       	mov    0x802000,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 44 09 00 00       	call   8009ea <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 54 18 80 00 	movl   $0x801854,(%esp)
  8000b1:	e8 f3 01 00 00       	call   8002a9 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 04 20 80 00       	mov    0x802004,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 1d 08 00 00       	call   8008e0 <strlen>
  8000c3:	83 c0 01             	add    $0x1,%eax
  8000c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ca:	a1 04 20 80 00       	mov    0x802004,%eax
  8000cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d3:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000da:	e8 5d 0a 00 00       	call   800b3c <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000df:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e6:	00 
  8000e7:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ee:	00 
  8000ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f6:	00 
  8000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000fa:	89 04 24             	mov    %eax,(%esp)
  8000fd:	e8 e4 12 00 00       	call   8013e6 <ipc_send>
		return;
  800102:	e9 d8 00 00 00       	jmp    8001df <umain+0x1ab>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800107:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010c:	8b 40 48             	mov    0x48(%eax),%eax
  80010f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011e:	00 
  80011f:	89 04 24             	mov    %eax,(%esp)
  800122:	e8 cb 0d 00 00       	call   800ef2 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800127:	a1 00 20 80 00       	mov    0x802000,%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 ac 07 00 00       	call   8008e0 <strlen>
  800134:	83 c0 01             	add    $0x1,%eax
  800137:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013b:	a1 00 20 80 00       	mov    0x802000,%eax
  800140:	89 44 24 04          	mov    %eax,0x4(%esp)
  800144:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  80014b:	e8 ec 09 00 00       	call   800b3c <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800150:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800157:	00 
  800158:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015f:	00 
  800160:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800167:	00 
  800168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80016b:	89 04 24             	mov    %eax,(%esp)
  80016e:	e8 73 12 00 00       	call   8013e6 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800173:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80017a:	00 
  80017b:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  800182:	00 
  800183:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	e8 c9 12 00 00       	call   801457 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018e:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800195:	00 
  800196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019d:	c7 04 24 40 18 80 00 	movl   $0x801840,(%esp)
  8001a4:	e8 00 01 00 00       	call   8002a9 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a9:	a1 04 20 80 00       	mov    0x802004,%eax
  8001ae:	89 04 24             	mov    %eax,(%esp)
  8001b1:	e8 2a 07 00 00       	call   8008e0 <strlen>
  8001b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ba:	a1 04 20 80 00       	mov    0x802004,%eax
  8001bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c3:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001ca:	e8 1b 08 00 00       	call   8009ea <strncmp>
  8001cf:	85 c0                	test   %eax,%eax
  8001d1:	75 0c                	jne    8001df <umain+0x1ab>
		cprintf("parent received correct message\n");
  8001d3:	c7 04 24 74 18 80 00 	movl   $0x801874,(%esp)
  8001da:	e8 ca 00 00 00       	call   8002a9 <cprintf>
	return;
}
  8001df:	c9                   	leave  
  8001e0:	c3                   	ret    
  8001e1:	00 00                	add    %al,(%eax)
	...

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	83 ec 18             	sub    $0x18,%esp
  8001ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8001f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  8001f6:	e8 8a 0d 00 00       	call   800f85 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  8001fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800200:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800203:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800208:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020d:	85 f6                	test   %esi,%esi
  80020f:	7e 07                	jle    800218 <libmain+0x34>
		binaryname = argv[0];
  800211:	8b 03                	mov    (%ebx),%eax
  800213:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  800218:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021c:	89 34 24             	mov    %esi,(%esp)
  80021f:	e8 10 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800224:	e8 0b 00 00 00       	call   800234 <exit>
}
  800229:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80022c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80022f:	89 ec                	mov    %ebp,%esp
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    
	...

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80023a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800241:	e8 73 0d 00 00       	call   800fb9 <sys_env_destroy>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800251:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800258:	00 00 00 
	b.cnt = 0;
  80025b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800262:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800265:	8b 45 0c             	mov    0xc(%ebp),%eax
  800268:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80026c:	8b 45 08             	mov    0x8(%ebp),%eax
  80026f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800273:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	c7 04 24 c3 02 80 00 	movl   $0x8002c3,(%esp)
  800284:	e8 c6 01 00 00       	call   80044f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800289:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80028f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800293:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800299:	89 04 24             	mov    %eax,(%esp)
  80029c:	e8 ff 09 00 00       	call   800ca0 <sys_cputs>

	return b.cnt;
}
  8002a1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002af:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b9:	89 04 24             	mov    %eax,(%esp)
  8002bc:	e8 87 ff ff ff       	call   800248 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	53                   	push   %ebx
  8002c7:	83 ec 14             	sub    $0x14,%esp
  8002ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002cd:	8b 03                	mov    (%ebx),%eax
  8002cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002d6:	83 c0 01             	add    $0x1,%eax
  8002d9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002db:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002e0:	75 19                	jne    8002fb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002e2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002e9:	00 
  8002ea:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ed:	89 04 24             	mov    %eax,(%esp)
  8002f0:	e8 ab 09 00 00       	call   800ca0 <sys_cputs>
		b->idx = 0;
  8002f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002ff:	83 c4 14             	add    $0x14,%esp
  800302:	5b                   	pop    %ebx
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    
	...

00800310 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	57                   	push   %edi
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
  800316:	83 ec 4c             	sub    $0x4c,%esp
  800319:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80031c:	89 d6                	mov    %edx,%esi
  80031e:	8b 45 08             	mov    0x8(%ebp),%eax
  800321:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800324:	8b 55 0c             	mov    0xc(%ebp),%edx
  800327:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80032a:	8b 45 10             	mov    0x10(%ebp),%eax
  80032d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800330:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800333:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800336:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033b:	39 d1                	cmp    %edx,%ecx
  80033d:	72 07                	jb     800346 <printnum+0x36>
  80033f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800342:	39 d0                	cmp    %edx,%eax
  800344:	77 69                	ja     8003af <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800346:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80034a:	83 eb 01             	sub    $0x1,%ebx
  80034d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800351:	89 44 24 08          	mov    %eax,0x8(%esp)
  800355:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800359:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80035d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800360:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800363:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800366:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80036a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800371:	00 
  800372:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80037b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80037f:	e8 4c 12 00 00       	call   8015d0 <__udivdi3>
  800384:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800387:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80038a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80038e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800392:	89 04 24             	mov    %eax,(%esp)
  800395:	89 54 24 04          	mov    %edx,0x4(%esp)
  800399:	89 f2                	mov    %esi,%edx
  80039b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80039e:	e8 6d ff ff ff       	call   800310 <printnum>
  8003a3:	eb 11                	jmp    8003b6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a9:	89 3c 24             	mov    %edi,(%esp)
  8003ac:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003af:	83 eb 01             	sub    $0x1,%ebx
  8003b2:	85 db                	test   %ebx,%ebx
  8003b4:	7f ef                	jg     8003a5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003ba:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003be:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003cc:	00 
  8003cd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003d0:	89 14 24             	mov    %edx,(%esp)
  8003d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003da:	e8 21 13 00 00       	call   801700 <__umoddi3>
  8003df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e3:	0f be 80 ee 18 80 00 	movsbl 0x8018ee(%eax),%eax
  8003ea:	89 04 24             	mov    %eax,(%esp)
  8003ed:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003f0:	83 c4 4c             	add    $0x4c,%esp
  8003f3:	5b                   	pop    %ebx
  8003f4:	5e                   	pop    %esi
  8003f5:	5f                   	pop    %edi
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003fb:	83 fa 01             	cmp    $0x1,%edx
  8003fe:	7e 0e                	jle    80040e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 08             	lea    0x8(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	8b 52 04             	mov    0x4(%edx),%edx
  80040c:	eb 22                	jmp    800430 <getuint+0x38>
	else if (lflag)
  80040e:	85 d2                	test   %edx,%edx
  800410:	74 10                	je     800422 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800412:	8b 10                	mov    (%eax),%edx
  800414:	8d 4a 04             	lea    0x4(%edx),%ecx
  800417:	89 08                	mov    %ecx,(%eax)
  800419:	8b 02                	mov    (%edx),%eax
  80041b:	ba 00 00 00 00       	mov    $0x0,%edx
  800420:	eb 0e                	jmp    800430 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800422:	8b 10                	mov    (%eax),%edx
  800424:	8d 4a 04             	lea    0x4(%edx),%ecx
  800427:	89 08                	mov    %ecx,(%eax)
  800429:	8b 02                	mov    (%edx),%eax
  80042b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800438:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043c:	8b 10                	mov    (%eax),%edx
  80043e:	3b 50 04             	cmp    0x4(%eax),%edx
  800441:	73 0a                	jae    80044d <sprintputch+0x1b>
		*b->buf++ = ch;
  800443:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800446:	88 0a                	mov    %cl,(%edx)
  800448:	83 c2 01             	add    $0x1,%edx
  80044b:	89 10                	mov    %edx,(%eax)
}
  80044d:	5d                   	pop    %ebp
  80044e:	c3                   	ret    

0080044f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	57                   	push   %edi
  800453:	56                   	push   %esi
  800454:	53                   	push   %ebx
  800455:	83 ec 4c             	sub    $0x4c,%esp
  800458:	8b 7d 08             	mov    0x8(%ebp),%edi
  80045b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80045e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800461:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800468:	eb 11                	jmp    80047b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80046a:	85 c0                	test   %eax,%eax
  80046c:	0f 84 b0 03 00 00    	je     800822 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800472:	89 74 24 04          	mov    %esi,0x4(%esp)
  800476:	89 04 24             	mov    %eax,(%esp)
  800479:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047b:	0f b6 03             	movzbl (%ebx),%eax
  80047e:	83 c3 01             	add    $0x1,%ebx
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e4                	jne    80046a <vprintfmt+0x1b>
  800486:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80048d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800492:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800496:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80049d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8004a4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8004a7:	eb 06                	jmp    8004af <vprintfmt+0x60>
  8004a9:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8004ad:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	0f b6 0b             	movzbl (%ebx),%ecx
  8004b2:	0f b6 c1             	movzbl %cl,%eax
  8004b5:	8d 53 01             	lea    0x1(%ebx),%edx
  8004b8:	83 e9 23             	sub    $0x23,%ecx
  8004bb:	80 f9 55             	cmp    $0x55,%cl
  8004be:	0f 87 41 03 00 00    	ja     800805 <vprintfmt+0x3b6>
  8004c4:	0f b6 c9             	movzbl %cl,%ecx
  8004c7:	ff 24 8d c0 19 80 00 	jmp    *0x8019c0(,%ecx,4)
  8004ce:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8004d2:	eb d9                	jmp    8004ad <vprintfmt+0x5e>
  8004d4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8004db:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004e3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8004e7:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  8004ea:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8004ed:	83 fb 09             	cmp    $0x9,%ebx
  8004f0:	77 2b                	ja     80051d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f2:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f5:	eb e9                	jmp    8004e0 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 48 04             	lea    0x4(%eax),%ecx
  8004fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800500:	8b 00                	mov    (%eax),%eax
  800502:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800505:	eb 19                	jmp    800520 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800507:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050a:	c1 f8 1f             	sar    $0x1f,%eax
  80050d:	f7 d0                	not    %eax
  80050f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800512:	eb 99                	jmp    8004ad <vprintfmt+0x5e>
  800514:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80051b:	eb 90                	jmp    8004ad <vprintfmt+0x5e>
  80051d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800520:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800524:	79 87                	jns    8004ad <vprintfmt+0x5e>
  800526:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800529:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80052f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800532:	e9 76 ff ff ff       	jmp    8004ad <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800537:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80053b:	e9 6d ff ff ff       	jmp    8004ad <vprintfmt+0x5e>
  800540:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 04 24             	mov    %eax,(%esp)
  800555:	ff d7                	call   *%edi
  800557:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80055a:	e9 1c ff ff ff       	jmp    80047b <vprintfmt+0x2c>
  80055f:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 50 04             	lea    0x4(%eax),%edx
  800568:	89 55 14             	mov    %edx,0x14(%ebp)
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 c2                	mov    %eax,%edx
  80056f:	c1 fa 1f             	sar    $0x1f,%edx
  800572:	31 d0                	xor    %edx,%eax
  800574:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800576:	83 f8 09             	cmp    $0x9,%eax
  800579:	7f 0b                	jg     800586 <vprintfmt+0x137>
  80057b:	8b 14 85 20 1b 80 00 	mov    0x801b20(,%eax,4),%edx
  800582:	85 d2                	test   %edx,%edx
  800584:	75 20                	jne    8005a6 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800586:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80058a:	c7 44 24 08 ff 18 80 	movl   $0x8018ff,0x8(%esp)
  800591:	00 
  800592:	89 74 24 04          	mov    %esi,0x4(%esp)
  800596:	89 3c 24             	mov    %edi,(%esp)
  800599:	e8 0c 03 00 00       	call   8008aa <printfmt>
  80059e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a1:	e9 d5 fe ff ff       	jmp    80047b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005a6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005aa:	c7 44 24 08 08 19 80 	movl   $0x801908,0x8(%esp)
  8005b1:	00 
  8005b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b6:	89 3c 24             	mov    %edi,(%esp)
  8005b9:	e8 ec 02 00 00       	call   8008aa <printfmt>
  8005be:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005c1:	e9 b5 fe ff ff       	jmp    80047b <vprintfmt+0x2c>
  8005c6:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8005cf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 04             	lea    0x4(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 18                	mov    (%eax),%ebx
  8005dd:	85 db                	test   %ebx,%ebx
  8005df:	75 05                	jne    8005e6 <vprintfmt+0x197>
  8005e1:	bb 0b 19 80 00       	mov    $0x80190b,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8005e6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ea:	7e 76                	jle    800662 <vprintfmt+0x213>
  8005ec:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005f0:	74 7a                	je     80066c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f6:	89 1c 24             	mov    %ebx,(%esp)
  8005f9:	e8 fa 02 00 00       	call   8008f8 <strnlen>
  8005fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800601:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800603:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800607:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80060a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80060d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	eb 0f                	jmp    800620 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800611:	89 74 24 04          	mov    %esi,0x4(%esp)
  800615:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800618:	89 04 24             	mov    %eax,(%esp)
  80061b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 eb 01             	sub    $0x1,%ebx
  800620:	85 db                	test   %ebx,%ebx
  800622:	7f ed                	jg     800611 <vprintfmt+0x1c2>
  800624:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800627:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80062a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80062d:	89 f7                	mov    %esi,%edi
  80062f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800632:	eb 40                	jmp    800674 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800634:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800638:	74 18                	je     800652 <vprintfmt+0x203>
  80063a:	8d 50 e0             	lea    -0x20(%eax),%edx
  80063d:	83 fa 5e             	cmp    $0x5e,%edx
  800640:	76 10                	jbe    800652 <vprintfmt+0x203>
					putch('?', putdat);
  800642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800646:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80064d:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800650:	eb 0a                	jmp    80065c <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800652:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800656:	89 04 24             	mov    %eax,(%esp)
  800659:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800660:	eb 12                	jmp    800674 <vprintfmt+0x225>
  800662:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800665:	89 f7                	mov    %esi,%edi
  800667:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80066a:	eb 08                	jmp    800674 <vprintfmt+0x225>
  80066c:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80066f:	89 f7                	mov    %esi,%edi
  800671:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800674:	0f be 03             	movsbl (%ebx),%eax
  800677:	83 c3 01             	add    $0x1,%ebx
  80067a:	85 c0                	test   %eax,%eax
  80067c:	74 25                	je     8006a3 <vprintfmt+0x254>
  80067e:	85 f6                	test   %esi,%esi
  800680:	78 b2                	js     800634 <vprintfmt+0x1e5>
  800682:	83 ee 01             	sub    $0x1,%esi
  800685:	79 ad                	jns    800634 <vprintfmt+0x1e5>
  800687:	89 fe                	mov    %edi,%esi
  800689:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80068c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80068f:	eb 1a                	jmp    8006ab <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800691:	89 74 24 04          	mov    %esi,0x4(%esp)
  800695:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80069c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069e:	83 eb 01             	sub    $0x1,%ebx
  8006a1:	eb 08                	jmp    8006ab <vprintfmt+0x25c>
  8006a3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8006a6:	89 fe                	mov    %edi,%esi
  8006a8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8006ab:	85 db                	test   %ebx,%ebx
  8006ad:	7f e2                	jg     800691 <vprintfmt+0x242>
  8006af:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006b2:	e9 c4 fd ff ff       	jmp    80047b <vprintfmt+0x2c>
  8006b7:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006ba:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006bd:	83 f9 01             	cmp    $0x1,%ecx
  8006c0:	7e 16                	jle    8006d8 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 08             	lea    0x8(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d0:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006d3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d6:	eb 32                	jmp    80070a <vprintfmt+0x2bb>
	else if (lflag)
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	74 18                	je     8006f4 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 04             	lea    0x4(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ea:	89 c1                	mov    %eax,%ecx
  8006ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f2:	eb 16                	jmp    80070a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 00                	mov    (%eax),%eax
  8006ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800702:	89 c2                	mov    %eax,%edx
  800704:	c1 fa 1f             	sar    $0x1f,%edx
  800707:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80070d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800710:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800715:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800719:	0f 89 a7 00 00 00    	jns    8007c6 <vprintfmt+0x377>
				putch('-', putdat);
  80071f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800723:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072a:	ff d7                	call   *%edi
				num = -(long long) num;
  80072c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80072f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800732:	f7 d9                	neg    %ecx
  800734:	83 d3 00             	adc    $0x0,%ebx
  800737:	f7 db                	neg    %ebx
  800739:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073e:	e9 83 00 00 00       	jmp    8007c6 <vprintfmt+0x377>
  800743:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800746:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800749:	89 ca                	mov    %ecx,%edx
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
  80074e:	e8 a5 fc ff ff       	call   8003f8 <getuint>
  800753:	89 c1                	mov    %eax,%ecx
  800755:	89 d3                	mov    %edx,%ebx
  800757:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  80075c:	eb 68                	jmp    8007c6 <vprintfmt+0x377>
  80075e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800761:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800764:	89 ca                	mov    %ecx,%edx
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
  800769:	e8 8a fc ff ff       	call   8003f8 <getuint>
  80076e:	89 c1                	mov    %eax,%ecx
  800770:	89 d3                	mov    %edx,%ebx
  800772:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800777:	eb 4d                	jmp    8007c6 <vprintfmt+0x377>
  800779:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  80077c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800780:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800787:	ff d7                	call   *%edi
			putch('x', putdat);
  800789:	89 74 24 04          	mov    %esi,0x4(%esp)
  80078d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800794:	ff d7                	call   *%edi
			num = (unsigned long long)
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8d 50 04             	lea    0x4(%eax),%edx
  80079c:	89 55 14             	mov    %edx,0x14(%ebp)
  80079f:	8b 08                	mov    (%eax),%ecx
  8007a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a6:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007ab:	eb 19                	jmp    8007c6 <vprintfmt+0x377>
  8007ad:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8007b0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b3:	89 ca                	mov    %ecx,%edx
  8007b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b8:	e8 3b fc ff ff       	call   8003f8 <getuint>
  8007bd:	89 c1                	mov    %eax,%ecx
  8007bf:	89 d3                	mov    %edx,%ebx
  8007c1:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c6:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  8007ca:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d9:	89 0c 24             	mov    %ecx,(%esp)
  8007dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e0:	89 f2                	mov    %esi,%edx
  8007e2:	89 f8                	mov    %edi,%eax
  8007e4:	e8 27 fb ff ff       	call   800310 <printnum>
  8007e9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007ec:	e9 8a fc ff ff       	jmp    80047b <vprintfmt+0x2c>
  8007f1:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f8:	89 04 24             	mov    %eax,(%esp)
  8007fb:	ff d7                	call   *%edi
  8007fd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800800:	e9 76 fc ff ff       	jmp    80047b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800805:	89 74 24 04          	mov    %esi,0x4(%esp)
  800809:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800810:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800812:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800815:	80 38 25             	cmpb   $0x25,(%eax)
  800818:	0f 84 5d fc ff ff    	je     80047b <vprintfmt+0x2c>
  80081e:	89 c3                	mov    %eax,%ebx
  800820:	eb f0                	jmp    800812 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800822:	83 c4 4c             	add    $0x4c,%esp
  800825:	5b                   	pop    %ebx
  800826:	5e                   	pop    %esi
  800827:	5f                   	pop    %edi
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	83 ec 28             	sub    $0x28,%esp
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800836:	85 c0                	test   %eax,%eax
  800838:	74 04                	je     80083e <vsnprintf+0x14>
  80083a:	85 d2                	test   %edx,%edx
  80083c:	7f 07                	jg     800845 <vsnprintf+0x1b>
  80083e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800843:	eb 3b                	jmp    800880 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800845:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800848:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  80084c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80084f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800856:	8b 45 14             	mov    0x14(%ebp),%eax
  800859:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085d:	8b 45 10             	mov    0x10(%ebp),%eax
  800860:	89 44 24 08          	mov    %eax,0x8(%esp)
  800864:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086b:	c7 04 24 32 04 80 00 	movl   $0x800432,(%esp)
  800872:	e8 d8 fb ff ff       	call   80044f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800877:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800888:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80088b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80088f:	8b 45 10             	mov    0x10(%ebp),%eax
  800892:	89 44 24 08          	mov    %eax,0x8(%esp)
  800896:	8b 45 0c             	mov    0xc(%ebp),%eax
  800899:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	89 04 24             	mov    %eax,(%esp)
  8008a3:	e8 82 ff ff ff       	call   80082a <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008b0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b7:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c8:	89 04 24             	mov    %eax,(%esp)
  8008cb:	e8 7f fb ff ff       	call   80044f <vprintfmt>
	va_end(ap);
}
  8008d0:	c9                   	leave  
  8008d1:	c3                   	ret    
	...

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  8008eb:	eb 03                	jmp    8008f0 <strlen+0x10>
		n++;
  8008ed:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f4:	75 f7                	jne    8008ed <strlen+0xd>
		n++;
	return n;
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	53                   	push   %ebx
  8008fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800907:	eb 03                	jmp    80090c <strnlen+0x14>
		n++;
  800909:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090c:	39 c1                	cmp    %eax,%ecx
  80090e:	74 06                	je     800916 <strnlen+0x1e>
  800910:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800914:	75 f3                	jne    800909 <strnlen+0x11>
		n++;
	return n;
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	53                   	push   %ebx
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800923:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800928:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80092c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80092f:	83 c2 01             	add    $0x1,%edx
  800932:	84 c9                	test   %cl,%cl
  800934:	75 f2                	jne    800928 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800936:	5b                   	pop    %ebx
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	53                   	push   %ebx
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800943:	89 1c 24             	mov    %ebx,(%esp)
  800946:	e8 95 ff ff ff       	call   8008e0 <strlen>
	strcpy(dst + len, src);
  80094b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800952:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800955:	89 04 24             	mov    %eax,(%esp)
  800958:	e8 bc ff ff ff       	call   800919 <strcpy>
	return dst;
}
  80095d:	89 d8                	mov    %ebx,%eax
  80095f:	83 c4 08             	add    $0x8,%esp
  800962:	5b                   	pop    %ebx
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	56                   	push   %esi
  800969:	53                   	push   %ebx
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800970:	8b 75 10             	mov    0x10(%ebp),%esi
  800973:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	eb 0f                	jmp    800989 <strncpy+0x24>
		*dst++ = *src;
  80097a:	0f b6 19             	movzbl (%ecx),%ebx
  80097d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800980:	80 39 01             	cmpb   $0x1,(%ecx)
  800983:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800986:	83 c2 01             	add    $0x1,%edx
  800989:	39 f2                	cmp    %esi,%edx
  80098b:	72 ed                	jb     80097a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	56                   	push   %esi
  800995:	53                   	push   %ebx
  800996:	8b 75 08             	mov    0x8(%ebp),%esi
  800999:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80099f:	89 f0                	mov    %esi,%eax
  8009a1:	85 d2                	test   %edx,%edx
  8009a3:	75 0a                	jne    8009af <strlcpy+0x1e>
  8009a5:	eb 17                	jmp    8009be <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a7:	88 18                	mov    %bl,(%eax)
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009af:	83 ea 01             	sub    $0x1,%edx
  8009b2:	74 07                	je     8009bb <strlcpy+0x2a>
  8009b4:	0f b6 19             	movzbl (%ecx),%ebx
  8009b7:	84 db                	test   %bl,%bl
  8009b9:	75 ec                	jne    8009a7 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  8009bb:	c6 00 00             	movb   $0x0,(%eax)
  8009be:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009cd:	eb 06                	jmp    8009d5 <strcmp+0x11>
		p++, q++;
  8009cf:	83 c1 01             	add    $0x1,%ecx
  8009d2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d5:	0f b6 01             	movzbl (%ecx),%eax
  8009d8:	84 c0                	test   %al,%al
  8009da:	74 04                	je     8009e0 <strcmp+0x1c>
  8009dc:	3a 02                	cmp    (%edx),%al
  8009de:	74 ef                	je     8009cf <strcmp+0xb>
  8009e0:	0f b6 c0             	movzbl %al,%eax
  8009e3:	0f b6 12             	movzbl (%edx),%edx
  8009e6:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f4:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8009f7:	eb 09                	jmp    800a02 <strncmp+0x18>
		n--, p++, q++;
  8009f9:	83 ea 01             	sub    $0x1,%edx
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a02:	85 d2                	test   %edx,%edx
  800a04:	75 07                	jne    800a0d <strncmp+0x23>
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	eb 13                	jmp    800a20 <strncmp+0x36>
  800a0d:	0f b6 18             	movzbl (%eax),%ebx
  800a10:	84 db                	test   %bl,%bl
  800a12:	74 04                	je     800a18 <strncmp+0x2e>
  800a14:	3a 19                	cmp    (%ecx),%bl
  800a16:	74 e1                	je     8009f9 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a18:	0f b6 00             	movzbl (%eax),%eax
  800a1b:	0f b6 11             	movzbl (%ecx),%edx
  800a1e:	29 d0                	sub    %edx,%eax
}
  800a20:	5b                   	pop    %ebx
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2d:	eb 07                	jmp    800a36 <strchr+0x13>
		if (*s == c)
  800a2f:	38 ca                	cmp    %cl,%dl
  800a31:	74 0f                	je     800a42 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	0f b6 10             	movzbl (%eax),%edx
  800a39:	84 d2                	test   %dl,%dl
  800a3b:	75 f2                	jne    800a2f <strchr+0xc>
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4e:	eb 07                	jmp    800a57 <strfind+0x13>
		if (*s == c)
  800a50:	38 ca                	cmp    %cl,%dl
  800a52:	74 0a                	je     800a5e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a54:	83 c0 01             	add    $0x1,%eax
  800a57:	0f b6 10             	movzbl (%eax),%edx
  800a5a:	84 d2                	test   %dl,%dl
  800a5c:	75 f2                	jne    800a50 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	90                   	nop
  800a60:	c3                   	ret    

00800a61 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	83 ec 0c             	sub    $0xc,%esp
  800a67:	89 1c 24             	mov    %ebx,(%esp)
  800a6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a6e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a72:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a78:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a7b:	85 c9                	test   %ecx,%ecx
  800a7d:	74 30                	je     800aaf <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a85:	75 25                	jne    800aac <memset+0x4b>
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	75 20                	jne    800aac <memset+0x4b>
		c &= 0xFF;
  800a8c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a8f:	89 d3                	mov    %edx,%ebx
  800a91:	c1 e3 08             	shl    $0x8,%ebx
  800a94:	89 d6                	mov    %edx,%esi
  800a96:	c1 e6 18             	shl    $0x18,%esi
  800a99:	89 d0                	mov    %edx,%eax
  800a9b:	c1 e0 10             	shl    $0x10,%eax
  800a9e:	09 f0                	or     %esi,%eax
  800aa0:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800aa2:	09 d8                	or     %ebx,%eax
  800aa4:	c1 e9 02             	shr    $0x2,%ecx
  800aa7:	fc                   	cld    
  800aa8:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aaa:	eb 03                	jmp    800aaf <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aac:	fc                   	cld    
  800aad:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aaf:	89 f8                	mov    %edi,%eax
  800ab1:	8b 1c 24             	mov    (%esp),%ebx
  800ab4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ab8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800abc:	89 ec                	mov    %ebp,%esp
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	83 ec 08             	sub    $0x8,%esp
  800ac6:	89 34 24             	mov    %esi,(%esp)
  800ac9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800ad3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ad6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ad8:	39 c6                	cmp    %eax,%esi
  800ada:	73 35                	jae    800b11 <memmove+0x51>
  800adc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800adf:	39 d0                	cmp    %edx,%eax
  800ae1:	73 2e                	jae    800b11 <memmove+0x51>
		s += n;
		d += n;
  800ae3:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae5:	f6 c2 03             	test   $0x3,%dl
  800ae8:	75 1b                	jne    800b05 <memmove+0x45>
  800aea:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af0:	75 13                	jne    800b05 <memmove+0x45>
  800af2:	f6 c1 03             	test   $0x3,%cl
  800af5:	75 0e                	jne    800b05 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800af7:	83 ef 04             	sub    $0x4,%edi
  800afa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afd:	c1 e9 02             	shr    $0x2,%ecx
  800b00:	fd                   	std    
  800b01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b03:	eb 09                	jmp    800b0e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b05:	83 ef 01             	sub    $0x1,%edi
  800b08:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b0b:	fd                   	std    
  800b0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b0f:	eb 20                	jmp    800b31 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b17:	75 15                	jne    800b2e <memmove+0x6e>
  800b19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1f:	75 0d                	jne    800b2e <memmove+0x6e>
  800b21:	f6 c1 03             	test   $0x3,%cl
  800b24:	75 08                	jne    800b2e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b26:	c1 e9 02             	shr    $0x2,%ecx
  800b29:	fc                   	cld    
  800b2a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b2c:	eb 03                	jmp    800b31 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b2e:	fc                   	cld    
  800b2f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b31:	8b 34 24             	mov    (%esp),%esi
  800b34:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b38:	89 ec                	mov    %ebp,%esp
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b42:	8b 45 10             	mov    0x10(%ebp),%eax
  800b45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b49:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	89 04 24             	mov    %eax,(%esp)
  800b56:	e8 65 ff ff ff       	call   800ac0 <memmove>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b69:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b71:	eb 1c                	jmp    800b8f <memcmp+0x32>
		if (*s1 != *s2)
  800b73:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800b77:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800b7b:	83 c2 01             	add    $0x1,%edx
  800b7e:	83 e9 01             	sub    $0x1,%ecx
  800b81:	38 d8                	cmp    %bl,%al
  800b83:	74 0a                	je     800b8f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800b85:	0f b6 c0             	movzbl %al,%eax
  800b88:	0f b6 db             	movzbl %bl,%ebx
  800b8b:	29 d8                	sub    %ebx,%eax
  800b8d:	eb 09                	jmp    800b98 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8f:	85 c9                	test   %ecx,%ecx
  800b91:	75 e0                	jne    800b73 <memcmp+0x16>
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ba6:	89 c2                	mov    %eax,%edx
  800ba8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bab:	eb 07                	jmp    800bb4 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bad:	38 08                	cmp    %cl,(%eax)
  800baf:	74 07                	je     800bb8 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb1:	83 c0 01             	add    $0x1,%eax
  800bb4:	39 d0                	cmp    %edx,%eax
  800bb6:	72 f5                	jb     800bad <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 04             	sub    $0x4,%esp
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc9:	eb 03                	jmp    800bce <strtol+0x14>
		s++;
  800bcb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bce:	0f b6 02             	movzbl (%edx),%eax
  800bd1:	3c 20                	cmp    $0x20,%al
  800bd3:	74 f6                	je     800bcb <strtol+0x11>
  800bd5:	3c 09                	cmp    $0x9,%al
  800bd7:	74 f2                	je     800bcb <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd9:	3c 2b                	cmp    $0x2b,%al
  800bdb:	75 0c                	jne    800be9 <strtol+0x2f>
		s++;
  800bdd:	8d 52 01             	lea    0x1(%edx),%edx
  800be0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800be7:	eb 15                	jmp    800bfe <strtol+0x44>
	else if (*s == '-')
  800be9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bf0:	3c 2d                	cmp    $0x2d,%al
  800bf2:	75 0a                	jne    800bfe <strtol+0x44>
		s++, neg = 1;
  800bf4:	8d 52 01             	lea    0x1(%edx),%edx
  800bf7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfe:	85 db                	test   %ebx,%ebx
  800c00:	0f 94 c0             	sete   %al
  800c03:	74 05                	je     800c0a <strtol+0x50>
  800c05:	83 fb 10             	cmp    $0x10,%ebx
  800c08:	75 18                	jne    800c22 <strtol+0x68>
  800c0a:	80 3a 30             	cmpb   $0x30,(%edx)
  800c0d:	75 13                	jne    800c22 <strtol+0x68>
  800c0f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c13:	75 0d                	jne    800c22 <strtol+0x68>
		s += 2, base = 16;
  800c15:	83 c2 02             	add    $0x2,%edx
  800c18:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1d:	8d 76 00             	lea    0x0(%esi),%esi
  800c20:	eb 13                	jmp    800c35 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c22:	84 c0                	test   %al,%al
  800c24:	74 0f                	je     800c35 <strtol+0x7b>
  800c26:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c2b:	80 3a 30             	cmpb   $0x30,(%edx)
  800c2e:	75 05                	jne    800c35 <strtol+0x7b>
		s++, base = 8;
  800c30:	83 c2 01             	add    $0x1,%edx
  800c33:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c35:	b8 00 00 00 00       	mov    $0x0,%eax
  800c3a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c3c:	0f b6 0a             	movzbl (%edx),%ecx
  800c3f:	89 cf                	mov    %ecx,%edi
  800c41:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c44:	80 fb 09             	cmp    $0x9,%bl
  800c47:	77 08                	ja     800c51 <strtol+0x97>
			dig = *s - '0';
  800c49:	0f be c9             	movsbl %cl,%ecx
  800c4c:	83 e9 30             	sub    $0x30,%ecx
  800c4f:	eb 1e                	jmp    800c6f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c51:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c54:	80 fb 19             	cmp    $0x19,%bl
  800c57:	77 08                	ja     800c61 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800c59:	0f be c9             	movsbl %cl,%ecx
  800c5c:	83 e9 57             	sub    $0x57,%ecx
  800c5f:	eb 0e                	jmp    800c6f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c61:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c64:	80 fb 19             	cmp    $0x19,%bl
  800c67:	77 15                	ja     800c7e <strtol+0xc4>
			dig = *s - 'A' + 10;
  800c69:	0f be c9             	movsbl %cl,%ecx
  800c6c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c6f:	39 f1                	cmp    %esi,%ecx
  800c71:	7d 0b                	jge    800c7e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800c73:	83 c2 01             	add    $0x1,%edx
  800c76:	0f af c6             	imul   %esi,%eax
  800c79:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c7c:	eb be                	jmp    800c3c <strtol+0x82>
  800c7e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c84:	74 05                	je     800c8b <strtol+0xd1>
		*endptr = (char *) s;
  800c86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c89:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c8f:	74 04                	je     800c95 <strtol+0xdb>
  800c91:	89 c8                	mov    %ecx,%eax
  800c93:	f7 d8                	neg    %eax
}
  800c95:	83 c4 04             	add    $0x4,%esp
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5f                   	pop    %edi
  800c9b:	5d                   	pop    %ebp
  800c9c:	c3                   	ret    
  800c9d:	00 00                	add    %al,(%eax)
	...

00800ca0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	89 1c 24             	mov    %ebx,(%esp)
  800ca9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cad:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 c3                	mov    %eax,%ebx
  800cbe:	89 c7                	mov    %eax,%edi
  800cc0:	89 c6                	mov    %eax,%esi
  800cc2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cc4:	8b 1c 24             	mov    (%esp),%ebx
  800cc7:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ccb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ccf:	89 ec                	mov    %ebp,%esp
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 38             	sub    $0x38,%esp
  800cd9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cdc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800ce2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce6:	75 0c                	jne    800cf4 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800ce8:	c7 04 24 48 1b 80 00 	movl   $0x801b48,(%esp)
  800cef:	e8 b5 f5 ff ff       	call   8002a9 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf9:	b8 09 00 00 00       	mov    $0x9,%eax
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d04:	89 df                	mov    %ebx,%edi
  800d06:	89 de                	mov    %ebx,%esi
  800d08:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	7e 28                	jle    800d36 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d12:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d19:	00 
  800d1a:	c7 44 24 08 74 1b 80 	movl   $0x801b74,0x8(%esp)
  800d21:	00 
  800d22:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d29:	00 
  800d2a:	c7 04 24 91 1b 80 00 	movl   $0x801b91,(%esp)
  800d31:	e8 a2 07 00 00       	call   8014d8 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d36:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d39:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d3f:	89 ec                	mov    %ebp,%esp
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 38             	sub    $0x38,%esp
  800d49:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d57:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5f:	89 cb                	mov    %ecx,%ebx
  800d61:	89 cf                	mov    %ecx,%edi
  800d63:	89 ce                	mov    %ecx,%esi
  800d65:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7e 28                	jle    800d93 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d76:	00 
  800d77:	c7 44 24 08 74 1b 80 	movl   $0x801b74,0x8(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d86:	00 
  800d87:	c7 04 24 91 1b 80 00 	movl   $0x801b91,(%esp)
  800d8e:	e8 45 07 00 00       	call   8014d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d93:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d96:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d99:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9c:	89 ec                	mov    %ebp,%esp
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	89 1c 24             	mov    %ebx,(%esp)
  800da9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dad:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	be 00 00 00 00       	mov    $0x0,%esi
  800db6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dbb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc9:	8b 1c 24             	mov    (%esp),%ebx
  800dcc:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dd0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dd4:	89 ec                	mov    %ebp,%esp
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    

00800dd8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dd8:	55                   	push   %ebp
  800dd9:	89 e5                	mov    %esp,%ebp
  800ddb:	83 ec 38             	sub    $0x38,%esp
  800dde:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800de1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	b8 08 00 00 00       	mov    $0x8,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7e 28                	jle    800e29 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e05:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e0c:	00 
  800e0d:	c7 44 24 08 74 1b 80 	movl   $0x801b74,0x8(%esp)
  800e14:	00 
  800e15:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1c:	00 
  800e1d:	c7 04 24 91 1b 80 00 	movl   $0x801b91,(%esp)
  800e24:	e8 af 06 00 00       	call   8014d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e29:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e2c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e2f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e32:	89 ec                	mov    %ebp,%esp
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	83 ec 38             	sub    $0x38,%esp
  800e3c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e3f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e42:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4a:	b8 06 00 00 00       	mov    $0x6,%eax
  800e4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e52:	8b 55 08             	mov    0x8(%ebp),%edx
  800e55:	89 df                	mov    %ebx,%edi
  800e57:	89 de                	mov    %ebx,%esi
  800e59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	7e 28                	jle    800e87 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e63:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e6a:	00 
  800e6b:	c7 44 24 08 74 1b 80 	movl   $0x801b74,0x8(%esp)
  800e72:	00 
  800e73:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e7a:	00 
  800e7b:	c7 04 24 91 1b 80 00 	movl   $0x801b91,(%esp)
  800e82:	e8 51 06 00 00       	call   8014d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e90:	89 ec                	mov    %ebp,%esp
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 38             	sub    $0x38,%esp
  800e9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ea8:	8b 75 18             	mov    0x18(%ebp),%esi
  800eab:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 74 1b 80 	movl   $0x801b74,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 91 1b 80 00 	movl   $0x801b91,(%esp)
  800ee0:	e8 f3 05 00 00       	call   8014d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ee5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eeb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eee:	89 ec                	mov    %ebp,%esp
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 38             	sub    $0x38,%esp
  800ef8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800efb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efe:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f01:	be 00 00 00 00       	mov    $0x0,%esi
  800f06:	b8 04 00 00 00       	mov    $0x4,%eax
  800f0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 f7                	mov    %esi,%edi
  800f16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f18:	85 c0                	test   %eax,%eax
  800f1a:	7e 28                	jle    800f44 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f20:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f27:	00 
  800f28:	c7 44 24 08 74 1b 80 	movl   $0x801b74,0x8(%esp)
  800f2f:	00 
  800f30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f37:	00 
  800f38:	c7 04 24 91 1b 80 00 	movl   $0x801b91,(%esp)
  800f3f:	e8 94 05 00 00       	call   8014d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f44:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f47:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f4a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4d:	89 ec                	mov    %ebp,%esp
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	89 1c 24             	mov    %ebx,(%esp)
  800f5a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	ba 00 00 00 00       	mov    $0x0,%edx
  800f67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f6c:	89 d1                	mov    %edx,%ecx
  800f6e:	89 d3                	mov    %edx,%ebx
  800f70:	89 d7                	mov    %edx,%edi
  800f72:	89 d6                	mov    %edx,%esi
  800f74:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f76:	8b 1c 24             	mov    (%esp),%ebx
  800f79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f81:	89 ec                	mov    %ebp,%esp
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 0c             	sub    $0xc,%esp
  800f8b:	89 1c 24             	mov    %ebx,(%esp)
  800f8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f92:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f96:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9b:	b8 02 00 00 00       	mov    $0x2,%eax
  800fa0:	89 d1                	mov    %edx,%ecx
  800fa2:	89 d3                	mov    %edx,%ebx
  800fa4:	89 d7                	mov    %edx,%edi
  800fa6:	89 d6                	mov    %edx,%esi
  800fa8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800faa:	8b 1c 24             	mov    (%esp),%ebx
  800fad:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fb1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fb5:	89 ec                	mov    %ebp,%esp
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 38             	sub    $0x38,%esp
  800fbf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fc5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd5:	89 cb                	mov    %ecx,%ebx
  800fd7:	89 cf                	mov    %ecx,%edi
  800fd9:	89 ce                	mov    %ecx,%esi
  800fdb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	7e 28                	jle    801009 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fe5:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fec:	00 
  800fed:	c7 44 24 08 74 1b 80 	movl   $0x801b74,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 91 1b 80 00 	movl   $0x801b91,(%esp)
  801004:	e8 cf 04 00 00       	call   8014d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801009:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80100c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80100f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801012:	89 ec                	mov    %ebp,%esp
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    

00801016 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	89 1c 24             	mov    %ebx,(%esp)
  80101f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801023:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801027:	ba 00 00 00 00       	mov    $0x0,%edx
  80102c:	b8 01 00 00 00       	mov    $0x1,%eax
  801031:	89 d1                	mov    %edx,%ecx
  801033:	89 d3                	mov    %edx,%ebx
  801035:	89 d7                	mov    %edx,%edi
  801037:	89 d6                	mov    %edx,%esi
  801039:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80103b:	8b 1c 24             	mov    (%esp),%ebx
  80103e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801042:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801046:	89 ec                	mov    %ebp,%esp
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    
	...

0080104c <sfork>:
}

// Challenge!
int
sfork(void)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801052:	c7 44 24 08 9f 1b 80 	movl   $0x801b9f,0x8(%esp)
  801059:	00 
  80105a:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  801061:	00 
  801062:	c7 04 24 b5 1b 80 00 	movl   $0x801bb5,(%esp)
  801069:	e8 6a 04 00 00       	call   8014d8 <_panic>

0080106e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
  801073:	83 ec 20             	sub    $0x20,%esp
  801076:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801079:	8b 30                	mov    (%eax),%esi
	uint32_t err = utf->utf_err;
  80107b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80107f:	75 1c                	jne    80109d <pgfault+0x2f>

	// LAB 4: Your code here.
	FORKDEBUG("lib pgfault: fault address 0x%08x\n",(int)addr);

	if ( (err&FEC_WR) == 0 ) {
		panic("lib pgfault: The page fault is not caused by write\n");
  801081:	c7 44 24 08 e0 1b 80 	movl   $0x801be0,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 b5 1b 80 00 	movl   $0x801bb5,(%esp)
  801098:	e8 3b 04 00 00       	call   8014d8 <_panic>
	} 
	
	if ( (uvpt[PGNUM(addr)]&PTE_COW) == 0 ) {
  80109d:	89 f0                	mov    %esi,%eax
  80109f:	c1 e8 0c             	shr    $0xc,%eax
  8010a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a9:	f6 c4 08             	test   $0x8,%ah
  8010ac:	75 1c                	jne    8010ca <pgfault+0x5c>
		panic("lib pgfault: The page fault's page is not COW\n");
  8010ae:	c7 44 24 08 14 1c 80 	movl   $0x801c14,0x8(%esp)
  8010b5:	00 
  8010b6:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
  8010bd:	00 
  8010be:	c7 04 24 b5 1b 80 00 	movl   $0x801bb5,(%esp)
  8010c5:	e8 0e 04 00 00       	call   8014d8 <_panic>
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
		
	envid_t envid=sys_getenvid();
  8010ca:	e8 b6 fe ff ff       	call   800f85 <sys_getenvid>
  8010cf:	89 c3                	mov    %eax,%ebx
	int res;
	
	res=sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W);
  8010d1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8010e0:	00 
  8010e1:	89 04 24             	mov    %eax,(%esp)
  8010e4:	e8 09 fe ff ff       	call   800ef2 <sys_page_alloc>
	if (res<0) {
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	79 1c                	jns    801109 <pgfault+0x9b>
		panic("lib pgfault: cannot allocate temp page\n");
  8010ed:	c7 44 24 08 44 1c 80 	movl   $0x801c44,0x8(%esp)
  8010f4:	00 
  8010f5:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8010fc:	00 
  8010fd:	c7 04 24 b5 1b 80 00 	movl   $0x801bb5,(%esp)
  801104:	e8 cf 03 00 00       	call   8014d8 <_panic>
	}

	memmove(PFTEMP, (void*)ROUNDDOWN(addr,PGSIZE),PGSIZE);
  801109:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  80110f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801116:	00 
  801117:	89 74 24 04          	mov    %esi,0x4(%esp)
  80111b:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801122:	e8 99 f9 ff ff       	call   800ac0 <memmove>
	
	res=sys_page_map(envid,PFTEMP,envid,(void*)ROUNDDOWN(addr,PGSIZE), PTE_U | PTE_P | PTE_W);
  801127:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80112e:	00 
  80112f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801133:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801137:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80113e:	00 
  80113f:	89 1c 24             	mov    %ebx,(%esp)
  801142:	e8 4d fd ff ff       	call   800e94 <sys_page_map>
	if (res<0) {
  801147:	85 c0                	test   %eax,%eax
  801149:	79 1c                	jns    801167 <pgfault+0xf9>
		panic("lib pgfault: cannot map page\n");
  80114b:	c7 44 24 08 c0 1b 80 	movl   $0x801bc0,0x8(%esp)
  801152:	00 
  801153:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  80115a:	00 
  80115b:	c7 04 24 b5 1b 80 00 	movl   $0x801bb5,(%esp)
  801162:	e8 71 03 00 00       	call   8014d8 <_panic>
	}

	res=sys_page_unmap(envid,PFTEMP);
  801167:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80116e:	00 
  80116f:	89 1c 24             	mov    %ebx,(%esp)
  801172:	e8 bf fc ff ff       	call   800e36 <sys_page_unmap>
	if (res<0) {
  801177:	85 c0                	test   %eax,%eax
  801179:	79 1c                	jns    801197 <pgfault+0x129>
		panic("lib pgfault: cannot unmap page\n");
  80117b:	c7 44 24 08 6c 1c 80 	movl   $0x801c6c,0x8(%esp)
  801182:	00 
  801183:	c7 44 24 04 45 00 00 	movl   $0x45,0x4(%esp)
  80118a:	00 
  80118b:	c7 04 24 b5 1b 80 00 	movl   $0x801bb5,(%esp)
  801192:	e8 41 03 00 00       	call   8014d8 <_panic>
	}
	return;
	//panic("pgfault not implemented");
}
  801197:	83 c4 20             	add    $0x20,%esp
  80119a:	5b                   	pop    %ebx
  80119b:	5e                   	pop    %esi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 4c             	sub    $0x4c,%esp
	// LAB 4: Your code here.
	int i,j,pn=0;
	envid_t curenvid=sys_getenvid();
  8011a7:	e8 d9 fd ff ff       	call   800f85 <sys_getenvid>
  8011ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	envid_t envid;
	int r;
	

	FORKDEBUG("fork: start to fork\n");
	set_pgfault_handler(pgfault);
  8011af:	c7 04 24 6e 10 80 00 	movl   $0x80106e,(%esp)
  8011b6:	e8 75 03 00 00       	call   801530 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8011bb:	ba 07 00 00 00       	mov    $0x7,%edx
  8011c0:	89 d0                	mov    %edx,%eax
  8011c2:	cd 30                	int    $0x30
  8011c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
	FORKDEBUG("fork: already set pgfault handler\n");


	if ( (envid = sys_exofork()) < 0) {
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	0f 88 c2 01 00 00    	js     801391 <fork+0x1f3>
		return -1;
	}	

	FORKDEBUG("fork: already sys_exofork\n");
	
	if ( envid==0 ) {
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	75 39                	jne    80120c <fork+0x6e>

		FORKDEBUG("fork: I am the child\n");
		sys_page_alloc(sys_getenvid(),(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P);
  8011d3:	e8 ad fd ff ff       	call   800f85 <sys_getenvid>
  8011d8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011df:	00 
  8011e0:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011e7:	ee 
  8011e8:	89 04 24             	mov    %eax,(%esp)
  8011eb:	e8 02 fd ff ff       	call   800ef2 <sys_page_alloc>

		thisenv=&envs[ENVX(sys_getenvid())];
  8011f0:	e8 90 fd ff ff       	call   800f85 <sys_getenvid>
  8011f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011fa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011fd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801202:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return envid;
  801207:	e9 8c 01 00 00       	jmp    801398 <fork+0x1fa>
  80120c:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
  801213:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801216:	8b 04 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%eax
  80121d:	a8 01                	test   $0x1,%al
  80121f:	0f 84 a9 00 00 00    	je     8012ce <fork+0x130>
			for ( j=0;j<NPTENTRIES;j++) {
		//		cprintf("i: %d, j:%d\n",i,j);
				pn=PGNUM(PGADDR(i,j,0));
  801225:	c1 e2 16             	shl    $0x16,%edx
  801228:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80122b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801230:	89 de                	mov    %ebx,%esi
  801232:	c1 e6 0c             	shl    $0xc,%esi
  801235:	0b 75 e4             	or     -0x1c(%ebp),%esi
  801238:	c1 ee 0c             	shr    $0xc,%esi
				if ( pn== PGNUM(UXSTACKTOP-PGSIZE) ) {
  80123b:	81 fe ff eb 0e 00    	cmp    $0xeebff,%esi
  801241:	0f 84 87 00 00 00    	je     8012ce <fork+0x130>
					break;
				}
				if ( uvpt[pn] & PTE_P ) {
  801247:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80124e:	a8 01                	test   $0x1,%al
  801250:	74 6d                	je     8012bf <fork+0x121>
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid();
  801252:	e8 2e fd ff ff       	call   800f85 <sys_getenvid>
  801257:	89 45 e0             	mov    %eax,-0x20(%ebp)

	pte_t pte = uvpt[pn];
  80125a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	int perm;

	perm = PTE_U | PTE_P;
	if ( pte & PTE_W || pte & PTE_COW ) {
  801261:	25 02 08 00 00       	and    $0x802,%eax
  801266:	83 f8 01             	cmp    $0x1,%eax
  801269:	19 ff                	sbb    %edi,%edi
  80126b:	81 e7 00 f8 ff ff    	and    $0xfffff800,%edi
  801271:	81 c7 05 08 00 00    	add    $0x805,%edi
		perm |= PTE_COW;
	}

	r=sys_page_map(curenvid, (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE),perm);
  801277:	c1 e6 0c             	shl    $0xc,%esi
  80127a:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80127e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801282:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801285:	89 44 24 08          	mov    %eax,0x8(%esp)
  801289:	89 74 24 04          	mov    %esi,0x4(%esp)
  80128d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801290:	89 14 24             	mov    %edx,(%esp)
  801293:	e8 fc fb ff ff       	call   800e94 <sys_page_map>
	if (r<0) {
  801298:	85 c0                	test   %eax,%eax
  80129a:	78 23                	js     8012bf <fork+0x121>
		FORKDEBUG("lib duppage: sys_page_map curenvid fail\n");
		return r;
	}
	
	if ( perm & PTE_COW ) {
  80129c:	f7 c7 00 08 00 00    	test   $0x800,%edi
  8012a2:	74 1b                	je     8012bf <fork+0x121>
		r=sys_page_map(curenvid, (void*)(pn*PGSIZE), curenvid, (void*)(pn*PGSIZE), perm);
  8012a4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8012a8:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012b7:	89 04 24             	mov    %eax,(%esp)
  8012ba:	e8 d5 fb ff ff       	call   800e94 <sys_page_map>
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
			for ( j=0;j<NPTENTRIES;j++) {
  8012bf:	83 c3 01             	add    $0x1,%ebx
  8012c2:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8012c8:	0f 85 62 ff ff ff    	jne    801230 <fork+0x92>
//			duppage(envid,pn);
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
  8012ce:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
  8012d2:	81 7d dc bb 03 00 00 	cmpl   $0x3bb,-0x24(%ebp)
  8012d9:	0f 85 34 ff ff ff    	jne    801213 <fork+0x75>
			}
		}
	}
	FORKDEBUG("lib fork: after duppage\n");
	
	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_U | PTE_P | PTE_W)<0 ) {
  8012df:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012e6:	00 
  8012e7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012ee:	ee 
  8012ef:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8012f2:	89 14 24             	mov    %edx,(%esp)
  8012f5:	e8 f8 fb ff ff       	call   800ef2 <sys_page_alloc>
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	0f 88 8f 00 00 00    	js     801391 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_alloc fail\n");
		return -1;
	}

	if (sys_page_map(envid,(void*)(UXSTACKTOP-PGSIZE),curenvid,PFTEMP, PTE_U | PTE_P | PTE_W)<0) {
  801302:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801309:	00 
  80130a:	c7 44 24 0c 00 f0 7f 	movl   $0x7ff000,0xc(%esp)
  801311:	00 
  801312:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801315:	89 44 24 08          	mov    %eax,0x8(%esp)
  801319:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801320:	ee 
  801321:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801324:	89 14 24             	mov    %edx,(%esp)
  801327:	e8 68 fb ff ff       	call   800e94 <sys_page_map>
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 61                	js     801391 <fork+0x1f3>
		FORKDEBUG("lib fork: sys_page_map envid fail\n");
		return -1;
	}

	memmove((void*)(UXSTACKTOP-PGSIZE) , PFTEMP ,PGSIZE);
  801330:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801337:	00 
  801338:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80133f:	00 
  801340:	c7 04 24 00 f0 bf ee 	movl   $0xeebff000,(%esp)
  801347:	e8 74 f7 ff ff       	call   800ac0 <memmove>
	
	if (sys_page_unmap(curenvid,PFTEMP)<0) {
  80134c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801353:	00 
  801354:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801357:	89 04 24             	mov    %eax,(%esp)
  80135a:	e8 d7 fa ff ff       	call   800e36 <sys_page_unmap>
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 2e                	js     801391 <fork+0x1f3>
		return -1;
	}

	extern void _pgfault_upcall(void);

	if (sys_env_set_pgfault_upcall(envid,_pgfault_upcall)<0) {
  801363:	c7 44 24 04 a4 15 80 	movl   $0x8015a4,0x4(%esp)
  80136a:	00 
  80136b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80136e:	89 14 24             	mov    %edx,(%esp)
  801371:	e8 5d f9 ff ff       	call   800cd3 <sys_env_set_pgfault_upcall>
  801376:	85 c0                	test   %eax,%eax
  801378:	78 17                	js     801391 <fork+0x1f3>
//	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P)<0) {
//		FORKDEBUG("lib fork: sys_page_alloc fail\n");
//		return -1;
//	}		

	if (sys_env_set_status(envid, ENV_RUNNABLE)<0) {
  80137a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801381:	00 
  801382:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801385:	89 04 24             	mov    %eax,(%esp)
  801388:	e8 4b fa ff ff       	call   800dd8 <sys_env_set_status>
  80138d:	85 c0                	test   %eax,%eax
  80138f:	79 07                	jns    801398 <fork+0x1fa>
  801391:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)

	FORKDEBUG("lib fork: finish fork\n");

	return envid;
//	panic("fork not implemented");
}
  801398:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80139b:	83 c4 4c             	add    $0x4c,%esp
  80139e:	5b                   	pop    %ebx
  80139f:	5e                   	pop    %esi
  8013a0:	5f                   	pop    %edi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    
	...

008013b0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b6:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8013bb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013be:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8013c4:	8b 12                	mov    (%edx),%edx
  8013c6:	39 ca                	cmp    %ecx,%edx
  8013c8:	75 0c                	jne    8013d6 <ipc_find_env+0x26>
			return envs[i].env_id;
  8013ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8013cd:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  8013d2:	8b 00                	mov    (%eax),%eax
  8013d4:	eb 0e                	jmp    8013e4 <ipc_find_env+0x34>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013d6:	83 c0 01             	add    $0x1,%eax
  8013d9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013de:	75 db                	jne    8013bb <ipc_find_env+0xb>
  8013e0:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	57                   	push   %edi
  8013ea:	56                   	push   %esi
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 2c             	sub    $0x2c,%esp
  8013ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int res;
	do {
		res=sys_ipc_try_send(to_env,val,pg?pg:(void*)UTOP,perm);
  8013f5:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  8013f8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8013fd:	85 f6                	test   %esi,%esi
  8013ff:	74 03                	je     801404 <ipc_send+0x1e>
  801401:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801404:	8b 55 14             	mov    0x14(%ebp),%edx
  801407:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80140b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80140f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801412:	89 44 24 04          	mov    %eax,0x4(%esp)
  801416:	89 3c 24             	mov    %edi,(%esp)
  801419:	e8 82 f9 ff ff       	call   800da0 <sys_ipc_try_send>
		
		if( res!=0 && res!= -E_IPC_NOT_RECV) {
  80141e:	85 c0                	test   %eax,%eax
  801420:	0f 95 c3             	setne  %bl
  801423:	74 21                	je     801446 <ipc_send+0x60>
  801425:	83 f8 f8             	cmp    $0xfffffff8,%eax
  801428:	74 1c                	je     801446 <ipc_send+0x60>
			panic("ipc_send: error\n");
  80142a:	c7 44 24 08 8c 1c 80 	movl   $0x801c8c,0x8(%esp)
  801431:	00 
  801432:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801439:	00 
  80143a:	c7 04 24 9d 1c 80 00 	movl   $0x801c9d,(%esp)
  801441:	e8 92 00 00 00       	call   8014d8 <_panic>
		}
		else {
			sys_yield();	
  801446:	e8 06 fb ff ff       	call   800f51 <sys_yield>
		}
	} while(res!=0);
  80144b:	84 db                	test   %bl,%bl
  80144d:	75 a9                	jne    8013f8 <ipc_send+0x12>
	
	
//	panic("ipc_send not implemented");
}
  80144f:	83 c4 2c             	add    $0x2c,%esp
  801452:	5b                   	pop    %ebx
  801453:	5e                   	pop    %esi
  801454:	5f                   	pop    %edi
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 28             	sub    $0x28,%esp
  80145d:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801460:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801463:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801466:	8b 75 08             	mov    0x8(%ebp),%esi
  801469:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80146c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int res;

	res=sys_ipc_recv( pg?pg:(void*)UTOP);
  80146f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801474:	85 db                	test   %ebx,%ebx
  801476:	74 02                	je     80147a <ipc_recv+0x23>
  801478:	89 d8                	mov    %ebx,%eax
  80147a:	89 04 24             	mov    %eax,(%esp)
  80147d:	e8 c1 f8 ff ff       	call   800d43 <sys_ipc_recv>

	if( from_env_store) {
  801482:	85 f6                	test   %esi,%esi
  801484:	74 14                	je     80149a <ipc_recv+0x43>
		*from_env_store = (res==0)? thisenv->env_ipc_from:0;
  801486:	ba 00 00 00 00       	mov    $0x0,%edx
  80148b:	85 c0                	test   %eax,%eax
  80148d:	75 09                	jne    801498 <ipc_recv+0x41>
  80148f:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  801495:	8b 52 74             	mov    0x74(%edx),%edx
  801498:	89 16                	mov    %edx,(%esi)
	}

	if( perm_store) {
  80149a:	85 ff                	test   %edi,%edi
  80149c:	74 1f                	je     8014bd <ipc_recv+0x66>
		*perm_store = (res==0 && (uint32_t)pg < UTOP)? thisenv->env_ipc_perm:0;
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	75 08                	jne    8014aa <ipc_recv+0x53>
  8014a2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8014a8:	76 08                	jbe    8014b2 <ipc_recv+0x5b>
  8014aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014af:	90                   	nop
  8014b0:	eb 09                	jmp    8014bb <ipc_recv+0x64>
  8014b2:	8b 15 0c 20 80 00    	mov    0x80200c,%edx
  8014b8:	8b 52 78             	mov    0x78(%edx),%edx
  8014bb:	89 17                	mov    %edx,(%edi)
	}
	
	if( res) {
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	75 08                	jne    8014c9 <ipc_recv+0x72>
		return res;
	}
	
//	panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8014c1:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8014c6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8014c9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8014cc:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8014cf:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8014d2:	89 ec                	mov    %ebp,%esp
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    
	...

008014d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014d8:	55                   	push   %ebp
  8014d9:	89 e5                	mov    %esp,%ebp
  8014db:	56                   	push   %esi
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8014e0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014e3:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8014e9:	e8 97 fa ff ff       	call   800f85 <sys_getenvid>
  8014ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8014f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801500:	89 44 24 04          	mov    %eax,0x4(%esp)
  801504:	c7 04 24 a8 1c 80 00 	movl   $0x801ca8,(%esp)
  80150b:	e8 99 ed ff ff       	call   8002a9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801510:	89 74 24 04          	mov    %esi,0x4(%esp)
  801514:	8b 45 10             	mov    0x10(%ebp),%eax
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	e8 29 ed ff ff       	call   800248 <vcprintf>
	cprintf("\n");
  80151f:	c7 04 24 dc 1b 80 00 	movl   $0x801bdc,(%esp)
  801526:	e8 7e ed ff ff       	call   8002a9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80152b:	cc                   	int3   
  80152c:	eb fd                	jmp    80152b <_panic+0x53>
	...

00801530 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801536:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  80153d:	75 58                	jne    801597 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  80153f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801544:	8b 40 48             	mov    0x48(%eax),%eax
  801547:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80154e:	00 
  80154f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801556:	ee 
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 93 f9 ff ff       	call   800ef2 <sys_page_alloc>
  80155f:	85 c0                	test   %eax,%eax
  801561:	74 1c                	je     80157f <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  801563:	c7 44 24 08 cc 1c 80 	movl   $0x801ccc,0x8(%esp)
  80156a:	00 
  80156b:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801572:	00 
  801573:	c7 04 24 f8 1c 80 00 	movl   $0x801cf8,(%esp)
  80157a:	e8 59 ff ff ff       	call   8014d8 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  80157f:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801584:	8b 40 48             	mov    0x48(%eax),%eax
  801587:	c7 44 24 04 a4 15 80 	movl   $0x8015a4,0x4(%esp)
  80158e:	00 
  80158f:	89 04 24             	mov    %eax,(%esp)
  801592:	e8 3c f7 ff ff       	call   800cd3 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801597:	8b 45 08             	mov    0x8(%ebp),%eax
  80159a:	a3 10 20 80 00       	mov    %eax,0x802010
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    
  8015a1:	00 00                	add    %al,(%eax)
	...

008015a4 <_pgfault_upcall>:
  8015a4:	54                   	push   %esp
  8015a5:	a1 10 20 80 00       	mov    0x802010,%eax
  8015aa:	ff d0                	call   *%eax
  8015ac:	83 c4 04             	add    $0x4,%esp
  8015af:	89 e3                	mov    %esp,%ebx
  8015b1:	8b 44 24 28          	mov    0x28(%esp),%eax
  8015b5:	8b 64 24 30          	mov    0x30(%esp),%esp
  8015b9:	50                   	push   %eax
  8015ba:	89 dc                	mov    %ebx,%esp
  8015bc:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  8015c1:	58                   	pop    %eax
  8015c2:	58                   	pop    %eax
  8015c3:	61                   	popa   
  8015c4:	83 c4 04             	add    $0x4,%esp
  8015c7:	9d                   	popf   
  8015c8:	5c                   	pop    %esp
  8015c9:	c3                   	ret    
  8015ca:	00 00                	add    %al,(%eax)
  8015cc:	00 00                	add    %al,(%eax)
	...

008015d0 <__udivdi3>:
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	57                   	push   %edi
  8015d4:	56                   	push   %esi
  8015d5:	83 ec 10             	sub    $0x10,%esp
  8015d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015db:	8b 55 08             	mov    0x8(%ebp),%edx
  8015de:	8b 75 10             	mov    0x10(%ebp),%esi
  8015e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8015e9:	75 35                	jne    801620 <__udivdi3+0x50>
  8015eb:	39 fe                	cmp    %edi,%esi
  8015ed:	77 61                	ja     801650 <__udivdi3+0x80>
  8015ef:	85 f6                	test   %esi,%esi
  8015f1:	75 0b                	jne    8015fe <__udivdi3+0x2e>
  8015f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f8:	31 d2                	xor    %edx,%edx
  8015fa:	f7 f6                	div    %esi
  8015fc:	89 c6                	mov    %eax,%esi
  8015fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801601:	31 d2                	xor    %edx,%edx
  801603:	89 f8                	mov    %edi,%eax
  801605:	f7 f6                	div    %esi
  801607:	89 c7                	mov    %eax,%edi
  801609:	89 c8                	mov    %ecx,%eax
  80160b:	f7 f6                	div    %esi
  80160d:	89 c1                	mov    %eax,%ecx
  80160f:	89 fa                	mov    %edi,%edx
  801611:	89 c8                	mov    %ecx,%eax
  801613:	83 c4 10             	add    $0x10,%esp
  801616:	5e                   	pop    %esi
  801617:	5f                   	pop    %edi
  801618:	5d                   	pop    %ebp
  801619:	c3                   	ret    
  80161a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801620:	39 f8                	cmp    %edi,%eax
  801622:	77 1c                	ja     801640 <__udivdi3+0x70>
  801624:	0f bd d0             	bsr    %eax,%edx
  801627:	83 f2 1f             	xor    $0x1f,%edx
  80162a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80162d:	75 39                	jne    801668 <__udivdi3+0x98>
  80162f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801632:	0f 86 a0 00 00 00    	jbe    8016d8 <__udivdi3+0x108>
  801638:	39 f8                	cmp    %edi,%eax
  80163a:	0f 82 98 00 00 00    	jb     8016d8 <__udivdi3+0x108>
  801640:	31 ff                	xor    %edi,%edi
  801642:	31 c9                	xor    %ecx,%ecx
  801644:	89 c8                	mov    %ecx,%eax
  801646:	89 fa                	mov    %edi,%edx
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	5e                   	pop    %esi
  80164c:	5f                   	pop    %edi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    
  80164f:	90                   	nop
  801650:	89 d1                	mov    %edx,%ecx
  801652:	89 fa                	mov    %edi,%edx
  801654:	89 c8                	mov    %ecx,%eax
  801656:	31 ff                	xor    %edi,%edi
  801658:	f7 f6                	div    %esi
  80165a:	89 c1                	mov    %eax,%ecx
  80165c:	89 fa                	mov    %edi,%edx
  80165e:	89 c8                	mov    %ecx,%eax
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	5e                   	pop    %esi
  801664:	5f                   	pop    %edi
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    
  801667:	90                   	nop
  801668:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80166c:	89 f2                	mov    %esi,%edx
  80166e:	d3 e0                	shl    %cl,%eax
  801670:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801673:	b8 20 00 00 00       	mov    $0x20,%eax
  801678:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80167b:	89 c1                	mov    %eax,%ecx
  80167d:	d3 ea                	shr    %cl,%edx
  80167f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801683:	0b 55 ec             	or     -0x14(%ebp),%edx
  801686:	d3 e6                	shl    %cl,%esi
  801688:	89 c1                	mov    %eax,%ecx
  80168a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80168d:	89 fe                	mov    %edi,%esi
  80168f:	d3 ee                	shr    %cl,%esi
  801691:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801695:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801698:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80169b:	d3 e7                	shl    %cl,%edi
  80169d:	89 c1                	mov    %eax,%ecx
  80169f:	d3 ea                	shr    %cl,%edx
  8016a1:	09 d7                	or     %edx,%edi
  8016a3:	89 f2                	mov    %esi,%edx
  8016a5:	89 f8                	mov    %edi,%eax
  8016a7:	f7 75 ec             	divl   -0x14(%ebp)
  8016aa:	89 d6                	mov    %edx,%esi
  8016ac:	89 c7                	mov    %eax,%edi
  8016ae:	f7 65 e8             	mull   -0x18(%ebp)
  8016b1:	39 d6                	cmp    %edx,%esi
  8016b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8016b6:	72 30                	jb     8016e8 <__udivdi3+0x118>
  8016b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8016bf:	d3 e2                	shl    %cl,%edx
  8016c1:	39 c2                	cmp    %eax,%edx
  8016c3:	73 05                	jae    8016ca <__udivdi3+0xfa>
  8016c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8016c8:	74 1e                	je     8016e8 <__udivdi3+0x118>
  8016ca:	89 f9                	mov    %edi,%ecx
  8016cc:	31 ff                	xor    %edi,%edi
  8016ce:	e9 71 ff ff ff       	jmp    801644 <__udivdi3+0x74>
  8016d3:	90                   	nop
  8016d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016d8:	31 ff                	xor    %edi,%edi
  8016da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8016df:	e9 60 ff ff ff       	jmp    801644 <__udivdi3+0x74>
  8016e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8016eb:	31 ff                	xor    %edi,%edi
  8016ed:	89 c8                	mov    %ecx,%eax
  8016ef:	89 fa                	mov    %edi,%edx
  8016f1:	83 c4 10             	add    $0x10,%esp
  8016f4:	5e                   	pop    %esi
  8016f5:	5f                   	pop    %edi
  8016f6:	5d                   	pop    %ebp
  8016f7:	c3                   	ret    
	...

00801700 <__umoddi3>:
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	83 ec 20             	sub    $0x20,%esp
  801708:	8b 55 14             	mov    0x14(%ebp),%edx
  80170b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80170e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801711:	8b 75 0c             	mov    0xc(%ebp),%esi
  801714:	85 d2                	test   %edx,%edx
  801716:	89 c8                	mov    %ecx,%eax
  801718:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80171b:	75 13                	jne    801730 <__umoddi3+0x30>
  80171d:	39 f7                	cmp    %esi,%edi
  80171f:	76 3f                	jbe    801760 <__umoddi3+0x60>
  801721:	89 f2                	mov    %esi,%edx
  801723:	f7 f7                	div    %edi
  801725:	89 d0                	mov    %edx,%eax
  801727:	31 d2                	xor    %edx,%edx
  801729:	83 c4 20             	add    $0x20,%esp
  80172c:	5e                   	pop    %esi
  80172d:	5f                   	pop    %edi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    
  801730:	39 f2                	cmp    %esi,%edx
  801732:	77 4c                	ja     801780 <__umoddi3+0x80>
  801734:	0f bd ca             	bsr    %edx,%ecx
  801737:	83 f1 1f             	xor    $0x1f,%ecx
  80173a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80173d:	75 51                	jne    801790 <__umoddi3+0x90>
  80173f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801742:	0f 87 e0 00 00 00    	ja     801828 <__umoddi3+0x128>
  801748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174b:	29 f8                	sub    %edi,%eax
  80174d:	19 d6                	sbb    %edx,%esi
  80174f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801752:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801755:	89 f2                	mov    %esi,%edx
  801757:	83 c4 20             	add    $0x20,%esp
  80175a:	5e                   	pop    %esi
  80175b:	5f                   	pop    %edi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    
  80175e:	66 90                	xchg   %ax,%ax
  801760:	85 ff                	test   %edi,%edi
  801762:	75 0b                	jne    80176f <__umoddi3+0x6f>
  801764:	b8 01 00 00 00       	mov    $0x1,%eax
  801769:	31 d2                	xor    %edx,%edx
  80176b:	f7 f7                	div    %edi
  80176d:	89 c7                	mov    %eax,%edi
  80176f:	89 f0                	mov    %esi,%eax
  801771:	31 d2                	xor    %edx,%edx
  801773:	f7 f7                	div    %edi
  801775:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801778:	f7 f7                	div    %edi
  80177a:	eb a9                	jmp    801725 <__umoddi3+0x25>
  80177c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801780:	89 c8                	mov    %ecx,%eax
  801782:	89 f2                	mov    %esi,%edx
  801784:	83 c4 20             	add    $0x20,%esp
  801787:	5e                   	pop    %esi
  801788:	5f                   	pop    %edi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    
  80178b:	90                   	nop
  80178c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801790:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801794:	d3 e2                	shl    %cl,%edx
  801796:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801799:	ba 20 00 00 00       	mov    $0x20,%edx
  80179e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8017a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8017a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8017a8:	89 fa                	mov    %edi,%edx
  8017aa:	d3 ea                	shr    %cl,%edx
  8017ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8017b3:	d3 e7                	shl    %cl,%edi
  8017b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8017b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8017bc:	89 f2                	mov    %esi,%edx
  8017be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8017c1:	89 c7                	mov    %eax,%edi
  8017c3:	d3 ea                	shr    %cl,%edx
  8017c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8017cc:	89 c2                	mov    %eax,%edx
  8017ce:	d3 e6                	shl    %cl,%esi
  8017d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8017d4:	d3 ea                	shr    %cl,%edx
  8017d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017da:	09 d6                	or     %edx,%esi
  8017dc:	89 f0                	mov    %esi,%eax
  8017de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8017e1:	d3 e7                	shl    %cl,%edi
  8017e3:	89 f2                	mov    %esi,%edx
  8017e5:	f7 75 f4             	divl   -0xc(%ebp)
  8017e8:	89 d6                	mov    %edx,%esi
  8017ea:	f7 65 e8             	mull   -0x18(%ebp)
  8017ed:	39 d6                	cmp    %edx,%esi
  8017ef:	72 2b                	jb     80181c <__umoddi3+0x11c>
  8017f1:	39 c7                	cmp    %eax,%edi
  8017f3:	72 23                	jb     801818 <__umoddi3+0x118>
  8017f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017f9:	29 c7                	sub    %eax,%edi
  8017fb:	19 d6                	sbb    %edx,%esi
  8017fd:	89 f0                	mov    %esi,%eax
  8017ff:	89 f2                	mov    %esi,%edx
  801801:	d3 ef                	shr    %cl,%edi
  801803:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801807:	d3 e0                	shl    %cl,%eax
  801809:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80180d:	09 f8                	or     %edi,%eax
  80180f:	d3 ea                	shr    %cl,%edx
  801811:	83 c4 20             	add    $0x20,%esp
  801814:	5e                   	pop    %esi
  801815:	5f                   	pop    %edi
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    
  801818:	39 d6                	cmp    %edx,%esi
  80181a:	75 d9                	jne    8017f5 <__umoddi3+0xf5>
  80181c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80181f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801822:	eb d1                	jmp    8017f5 <__umoddi3+0xf5>
  801824:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801828:	39 f2                	cmp    %esi,%edx
  80182a:	0f 82 18 ff ff ff    	jb     801748 <__umoddi3+0x48>
  801830:	e9 1d ff ff ff       	jmp    801752 <__umoddi3+0x52>
