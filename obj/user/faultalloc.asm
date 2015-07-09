
obj/user/faultalloc:     file format elf32-i386


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
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80003a:	c7 04 24 70 00 80 00 	movl   $0x800070,(%esp)
  800041:	e8 76 0f 00 00       	call   800fbc <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  800046:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80004d:	de 
  80004e:	c7 04 24 e0 12 80 00 	movl   $0x8012e0,(%esp)
  800055:	e8 bb 01 00 00       	call   800215 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  80005a:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  800061:	ca 
  800062:	c7 04 24 e0 12 80 00 	movl   $0x8012e0,(%esp)
  800069:	e8 a7 01 00 00       	call   800215 <cprintf>
}
  80006e:	c9                   	leave  
  80006f:	c3                   	ret    

00800070 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	53                   	push   %ebx
  800074:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800077:	8b 45 08             	mov    0x8(%ebp),%eax
  80007a:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80007c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800080:	c7 04 24 e4 12 80 00 	movl   $0x8012e4,(%esp)
  800087:	e8 89 01 00 00       	call   800215 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80008c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800093:	00 
  800094:	89 d8                	mov    %ebx,%eax
  800096:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a6:	e8 b7 0d 00 00       	call   800e62 <sys_page_alloc>
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 24                	jns    8000d3 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  8000af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b7:	c7 44 24 08 00 13 80 	movl   $0x801300,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 ee 12 80 00 	movl   $0x8012ee,(%esp)
  8000ce:	e8 89 00 00 00       	call   80015c <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000d7:	c7 44 24 08 2c 13 80 	movl   $0x80132c,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000e6:	00 
  8000e7:	89 1c 24             	mov    %ebx,(%esp)
  8000ea:	e8 03 07 00 00       	call   8007f2 <snprintf>
}
  8000ef:	83 c4 24             	add    $0x24,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

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
  80010a:	e8 e6 0d 00 00       	call   800ef5 <sys_getenvid>
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
  800155:	e8 cf 0d 00 00       	call   800f29 <sys_env_destroy>
}
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    

0080015c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800164:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800167:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80016d:	e8 83 0d 00 00       	call   800ef5 <sys_getenvid>
  800172:	8b 55 0c             	mov    0xc(%ebp),%edx
  800175:	89 54 24 10          	mov    %edx,0x10(%esp)
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800180:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800184:	89 44 24 04          	mov    %eax,0x4(%esp)
  800188:	c7 04 24 58 13 80 00 	movl   $0x801358,(%esp)
  80018f:	e8 81 00 00 00       	call   800215 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	89 74 24 04          	mov    %esi,0x4(%esp)
  800198:	8b 45 10             	mov    0x10(%ebp),%eax
  80019b:	89 04 24             	mov    %eax,(%esp)
  80019e:	e8 11 00 00 00       	call   8001b4 <vcprintf>
	cprintf("\n");
  8001a3:	c7 04 24 e2 12 80 00 	movl   $0x8012e2,(%esp)
  8001aa:	e8 66 00 00 00       	call   800215 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001af:	cc                   	int3   
  8001b0:	eb fd                	jmp    8001af <_panic+0x53>
	...

008001b4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c4:	00 00 00 
	b.cnt = 0;
  8001c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e9:	c7 04 24 2f 02 80 00 	movl   $0x80022f,(%esp)
  8001f0:	e8 ca 01 00 00       	call   8003bf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800205:	89 04 24             	mov    %eax,(%esp)
  800208:	e8 03 0a 00 00       	call   800c10 <sys_cputs>

	return b.cnt;
}
  80020d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800213:	c9                   	leave  
  800214:	c3                   	ret    

00800215 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80021b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	8b 45 08             	mov    0x8(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	e8 87 ff ff ff       	call   8001b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	53                   	push   %ebx
  800233:	83 ec 14             	sub    $0x14,%esp
  800236:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800239:	8b 03                	mov    (%ebx),%eax
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800242:	83 c0 01             	add    $0x1,%eax
  800245:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800247:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024c:	75 19                	jne    800267 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80024e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800255:	00 
  800256:	8d 43 08             	lea    0x8(%ebx),%eax
  800259:	89 04 24             	mov    %eax,(%esp)
  80025c:	e8 af 09 00 00       	call   800c10 <sys_cputs>
		b->idx = 0;
  800261:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800267:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80026b:	83 c4 14             	add    $0x14,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ab:	39 d1                	cmp    %edx,%ecx
  8002ad:	72 07                	jb     8002b6 <printnum+0x36>
  8002af:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b2:	39 d0                	cmp    %edx,%eax
  8002b4:	77 69                	ja     80031f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002ba:	83 eb 01             	sub    $0x1,%ebx
  8002bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002c9:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002d0:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002d3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002e1:	00 
  8002e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002e5:	89 04 24             	mov    %eax,(%esp)
  8002e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002eb:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ef:	e8 6c 0d 00 00       	call   801060 <__udivdi3>
  8002f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002f7:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002fa:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	89 54 24 04          	mov    %edx,0x4(%esp)
  800309:	89 f2                	mov    %esi,%edx
  80030b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030e:	e8 6d ff ff ff       	call   800280 <printnum>
  800313:	eb 11                	jmp    800326 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800315:	89 74 24 04          	mov    %esi,0x4(%esp)
  800319:	89 3c 24             	mov    %edi,(%esp)
  80031c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031f:	83 eb 01             	sub    $0x1,%ebx
  800322:	85 db                	test   %ebx,%ebx
  800324:	7f ef                	jg     800315 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800326:	89 74 24 04          	mov    %esi,0x4(%esp)
  80032a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80032e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800331:	89 44 24 08          	mov    %eax,0x8(%esp)
  800335:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033c:	00 
  80033d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800340:	89 14 24             	mov    %edx,(%esp)
  800343:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800346:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80034a:	e8 41 0e 00 00       	call   801190 <__umoddi3>
  80034f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800353:	0f be 80 7b 13 80 00 	movsbl 0x80137b(%eax),%eax
  80035a:	89 04 24             	mov    %eax,(%esp)
  80035d:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800360:	83 c4 4c             	add    $0x4c,%esp
  800363:	5b                   	pop    %ebx
  800364:	5e                   	pop    %esi
  800365:	5f                   	pop    %edi
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80036b:	83 fa 01             	cmp    $0x1,%edx
  80036e:	7e 0e                	jle    80037e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 08             	lea    0x8(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	8b 52 04             	mov    0x4(%edx),%edx
  80037c:	eb 22                	jmp    8003a0 <getuint+0x38>
	else if (lflag)
  80037e:	85 d2                	test   %edx,%edx
  800380:	74 10                	je     800392 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800382:	8b 10                	mov    (%eax),%edx
  800384:	8d 4a 04             	lea    0x4(%edx),%ecx
  800387:	89 08                	mov    %ecx,(%eax)
  800389:	8b 02                	mov    (%edx),%eax
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	eb 0e                	jmp    8003a0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800392:	8b 10                	mov    (%eax),%edx
  800394:	8d 4a 04             	lea    0x4(%edx),%ecx
  800397:	89 08                	mov    %ecx,(%eax)
  800399:	8b 02                	mov    (%edx),%eax
  80039b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a2:	55                   	push   %ebp
  8003a3:	89 e5                	mov    %esp,%ebp
  8003a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ac:	8b 10                	mov    (%eax),%edx
  8003ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b1:	73 0a                	jae    8003bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b6:	88 0a                	mov    %cl,(%edx)
  8003b8:	83 c2 01             	add    $0x1,%edx
  8003bb:	89 10                	mov    %edx,(%eax)
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    

008003bf <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	57                   	push   %edi
  8003c3:	56                   	push   %esi
  8003c4:	53                   	push   %ebx
  8003c5:	83 ec 4c             	sub    $0x4c,%esp
  8003c8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003cb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003d1:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003d8:	eb 11                	jmp    8003eb <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003da:	85 c0                	test   %eax,%eax
  8003dc:	0f 84 b0 03 00 00    	je     800792 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  8003e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e6:	89 04 24             	mov    %eax,(%esp)
  8003e9:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003eb:	0f b6 03             	movzbl (%ebx),%eax
  8003ee:	83 c3 01             	add    $0x1,%ebx
  8003f1:	83 f8 25             	cmp    $0x25,%eax
  8003f4:	75 e4                	jne    8003da <vprintfmt+0x1b>
  8003f6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800402:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800406:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80040d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800414:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800417:	eb 06                	jmp    80041f <vprintfmt+0x60>
  800419:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  80041d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	0f b6 0b             	movzbl (%ebx),%ecx
  800422:	0f b6 c1             	movzbl %cl,%eax
  800425:	8d 53 01             	lea    0x1(%ebx),%edx
  800428:	83 e9 23             	sub    $0x23,%ecx
  80042b:	80 f9 55             	cmp    $0x55,%cl
  80042e:	0f 87 41 03 00 00    	ja     800775 <vprintfmt+0x3b6>
  800434:	0f b6 c9             	movzbl %cl,%ecx
  800437:	ff 24 8d 40 14 80 00 	jmp    *0x801440(,%ecx,4)
  80043e:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800442:	eb d9                	jmp    80041d <vprintfmt+0x5e>
  800444:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  80044b:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800450:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800453:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  800457:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  80045a:	8d 58 d0             	lea    -0x30(%eax),%ebx
  80045d:	83 fb 09             	cmp    $0x9,%ebx
  800460:	77 2b                	ja     80048d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800462:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800465:	eb e9                	jmp    800450 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 48 04             	lea    0x4(%eax),%ecx
  80046d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800470:	8b 00                	mov    (%eax),%eax
  800472:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800475:	eb 19                	jmp    800490 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800477:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80047a:	c1 f8 1f             	sar    $0x1f,%eax
  80047d:	f7 d0                	not    %eax
  80047f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800482:	eb 99                	jmp    80041d <vprintfmt+0x5e>
  800484:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80048b:	eb 90                	jmp    80041d <vprintfmt+0x5e>
  80048d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800490:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800494:	79 87                	jns    80041d <vprintfmt+0x5e>
  800496:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800499:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80049f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004a2:	e9 76 ff ff ff       	jmp    80041d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a7:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004ab:	e9 6d ff ff ff       	jmp    80041d <vprintfmt+0x5e>
  8004b0:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 50 04             	lea    0x4(%eax),%edx
  8004b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c0:	8b 00                	mov    (%eax),%eax
  8004c2:	89 04 24             	mov    %eax,(%esp)
  8004c5:	ff d7                	call   *%edi
  8004c7:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8004ca:	e9 1c ff ff ff       	jmp    8003eb <vprintfmt+0x2c>
  8004cf:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8d 50 04             	lea    0x4(%eax),%edx
  8004d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8004db:	8b 00                	mov    (%eax),%eax
  8004dd:	89 c2                	mov    %eax,%edx
  8004df:	c1 fa 1f             	sar    $0x1f,%edx
  8004e2:	31 d0                	xor    %edx,%eax
  8004e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e6:	83 f8 09             	cmp    $0x9,%eax
  8004e9:	7f 0b                	jg     8004f6 <vprintfmt+0x137>
  8004eb:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  8004f2:	85 d2                	test   %edx,%edx
  8004f4:	75 20                	jne    800516 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  8004f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fa:	c7 44 24 08 8c 13 80 	movl   $0x80138c,0x8(%esp)
  800501:	00 
  800502:	89 74 24 04          	mov    %esi,0x4(%esp)
  800506:	89 3c 24             	mov    %edi,(%esp)
  800509:	e8 0c 03 00 00       	call   80081a <printfmt>
  80050e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800511:	e9 d5 fe ff ff       	jmp    8003eb <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800516:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80051a:	c7 44 24 08 95 13 80 	movl   $0x801395,0x8(%esp)
  800521:	00 
  800522:	89 74 24 04          	mov    %esi,0x4(%esp)
  800526:	89 3c 24             	mov    %edi,(%esp)
  800529:	e8 ec 02 00 00       	call   80081a <printfmt>
  80052e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800531:	e9 b5 fe ff ff       	jmp    8003eb <vprintfmt+0x2c>
  800536:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80053c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80053f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8d 50 04             	lea    0x4(%eax),%edx
  800548:	89 55 14             	mov    %edx,0x14(%ebp)
  80054b:	8b 18                	mov    (%eax),%ebx
  80054d:	85 db                	test   %ebx,%ebx
  80054f:	75 05                	jne    800556 <vprintfmt+0x197>
  800551:	bb 98 13 80 00       	mov    $0x801398,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  800556:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055a:	7e 76                	jle    8005d2 <vprintfmt+0x213>
  80055c:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800560:	74 7a                	je     8005dc <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800562:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800566:	89 1c 24             	mov    %ebx,(%esp)
  800569:	e8 fa 02 00 00       	call   800868 <strnlen>
  80056e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800571:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800573:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800577:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80057a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  80057d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	eb 0f                	jmp    800590 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800581:	89 74 24 04          	mov    %esi,0x4(%esp)
  800585:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058d:	83 eb 01             	sub    $0x1,%ebx
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f ed                	jg     800581 <vprintfmt+0x1c2>
  800594:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800597:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80059a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  80059d:	89 f7                	mov    %esi,%edi
  80059f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005a2:	eb 40                	jmp    8005e4 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a8:	74 18                	je     8005c2 <vprintfmt+0x203>
  8005aa:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ad:	83 fa 5e             	cmp    $0x5e,%edx
  8005b0:	76 10                	jbe    8005c2 <vprintfmt+0x203>
					putch('?', putdat);
  8005b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b6:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005bd:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c0:	eb 0a                	jmp    8005cc <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c6:	89 04 24             	mov    %eax,(%esp)
  8005c9:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005d0:	eb 12                	jmp    8005e4 <vprintfmt+0x225>
  8005d2:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005d5:	89 f7                	mov    %esi,%edi
  8005d7:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005da:	eb 08                	jmp    8005e4 <vprintfmt+0x225>
  8005dc:	89 7d e0             	mov    %edi,-0x20(%ebp)
  8005df:	89 f7                	mov    %esi,%edi
  8005e1:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005e4:	0f be 03             	movsbl (%ebx),%eax
  8005e7:	83 c3 01             	add    $0x1,%ebx
  8005ea:	85 c0                	test   %eax,%eax
  8005ec:	74 25                	je     800613 <vprintfmt+0x254>
  8005ee:	85 f6                	test   %esi,%esi
  8005f0:	78 b2                	js     8005a4 <vprintfmt+0x1e5>
  8005f2:	83 ee 01             	sub    $0x1,%esi
  8005f5:	79 ad                	jns    8005a4 <vprintfmt+0x1e5>
  8005f7:	89 fe                	mov    %edi,%esi
  8005f9:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8005fc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ff:	eb 1a                	jmp    80061b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800601:	89 74 24 04          	mov    %esi,0x4(%esp)
  800605:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80060c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060e:	83 eb 01             	sub    $0x1,%ebx
  800611:	eb 08                	jmp    80061b <vprintfmt+0x25c>
  800613:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800616:	89 fe                	mov    %edi,%esi
  800618:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80061b:	85 db                	test   %ebx,%ebx
  80061d:	7f e2                	jg     800601 <vprintfmt+0x242>
  80061f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800622:	e9 c4 fd ff ff       	jmp    8003eb <vprintfmt+0x2c>
  800627:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80062a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062d:	83 f9 01             	cmp    $0x1,%ecx
  800630:	7e 16                	jle    800648 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 50 08             	lea    0x8(%eax),%edx
  800638:	89 55 14             	mov    %edx,0x14(%ebp)
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	8b 48 04             	mov    0x4(%eax),%ecx
  800640:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800643:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800646:	eb 32                	jmp    80067a <vprintfmt+0x2bb>
	else if (lflag)
  800648:	85 c9                	test   %ecx,%ecx
  80064a:	74 18                	je     800664 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8d 50 04             	lea    0x4(%eax),%edx
  800652:	89 55 14             	mov    %edx,0x14(%ebp)
  800655:	8b 00                	mov    (%eax),%eax
  800657:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065a:	89 c1                	mov    %eax,%ecx
  80065c:	c1 f9 1f             	sar    $0x1f,%ecx
  80065f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800662:	eb 16                	jmp    80067a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8d 50 04             	lea    0x4(%eax),%edx
  80066a:	89 55 14             	mov    %edx,0x14(%ebp)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800672:	89 c2                	mov    %eax,%edx
  800674:	c1 fa 1f             	sar    $0x1f,%edx
  800677:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80067a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80067d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800680:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800685:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800689:	0f 89 a7 00 00 00    	jns    800736 <vprintfmt+0x377>
				putch('-', putdat);
  80068f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800693:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80069a:	ff d7                	call   *%edi
				num = -(long long) num;
  80069c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80069f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8006a2:	f7 d9                	neg    %ecx
  8006a4:	83 d3 00             	adc    $0x0,%ebx
  8006a7:	f7 db                	neg    %ebx
  8006a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ae:	e9 83 00 00 00       	jmp    800736 <vprintfmt+0x377>
  8006b3:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006b6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006b9:	89 ca                	mov    %ecx,%edx
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 a5 fc ff ff       	call   800368 <getuint>
  8006c3:	89 c1                	mov    %eax,%ecx
  8006c5:	89 d3                	mov    %edx,%ebx
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006cc:	eb 68                	jmp    800736 <vprintfmt+0x377>
  8006ce:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006d1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8006d4:	89 ca                	mov    %ecx,%edx
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 8a fc ff ff       	call   800368 <getuint>
  8006de:	89 c1                	mov    %eax,%ecx
  8006e0:	89 d3                	mov    %edx,%ebx
  8006e2:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  8006e7:	eb 4d                	jmp    800736 <vprintfmt+0x377>
  8006e9:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f0:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006f7:	ff d7                	call   *%edi
			putch('x', putdat);
  8006f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006fd:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800704:	ff d7                	call   *%edi
			num = (unsigned long long)
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 08                	mov    (%eax),%ecx
  800711:	bb 00 00 00 00       	mov    $0x0,%ebx
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80071b:	eb 19                	jmp    800736 <vprintfmt+0x377>
  80071d:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800720:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800723:	89 ca                	mov    %ecx,%edx
  800725:	8d 45 14             	lea    0x14(%ebp),%eax
  800728:	e8 3b fc ff ff       	call   800368 <getuint>
  80072d:	89 c1                	mov    %eax,%ecx
  80072f:	89 d3                	mov    %edx,%ebx
  800731:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800736:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  80073a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80073e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800741:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800745:	89 44 24 08          	mov    %eax,0x8(%esp)
  800749:	89 0c 24             	mov    %ecx,(%esp)
  80074c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800750:	89 f2                	mov    %esi,%edx
  800752:	89 f8                	mov    %edi,%eax
  800754:	e8 27 fb ff ff       	call   800280 <printnum>
  800759:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80075c:	e9 8a fc ff ff       	jmp    8003eb <vprintfmt+0x2c>
  800761:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800764:	89 74 24 04          	mov    %esi,0x4(%esp)
  800768:	89 04 24             	mov    %eax,(%esp)
  80076b:	ff d7                	call   *%edi
  80076d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800770:	e9 76 fc ff ff       	jmp    8003eb <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800775:	89 74 24 04          	mov    %esi,0x4(%esp)
  800779:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800780:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800782:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800785:	80 38 25             	cmpb   $0x25,(%eax)
  800788:	0f 84 5d fc ff ff    	je     8003eb <vprintfmt+0x2c>
  80078e:	89 c3                	mov    %eax,%ebx
  800790:	eb f0                	jmp    800782 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800792:	83 c4 4c             	add    $0x4c,%esp
  800795:	5b                   	pop    %ebx
  800796:	5e                   	pop    %esi
  800797:	5f                   	pop    %edi
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	83 ec 28             	sub    $0x28,%esp
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	74 04                	je     8007ae <vsnprintf+0x14>
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	7f 07                	jg     8007b5 <vsnprintf+0x1b>
  8007ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b3:	eb 3b                	jmp    8007f0 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b8:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007db:	c7 04 24 a2 03 80 00 	movl   $0x8003a2,(%esp)
  8007e2:	e8 d8 fb ff ff       	call   8003bf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ea:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007f8:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800802:	89 44 24 08          	mov    %eax,0x8(%esp)
  800806:	8b 45 0c             	mov    0xc(%ebp),%eax
  800809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	89 04 24             	mov    %eax,(%esp)
  800813:	e8 82 ff ff ff       	call   80079a <vsnprintf>
	va_end(ap);

	return rc;
}
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800820:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800823:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800827:	8b 45 10             	mov    0x10(%ebp),%eax
  80082a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800831:	89 44 24 04          	mov    %eax,0x4(%esp)
  800835:	8b 45 08             	mov    0x8(%ebp),%eax
  800838:	89 04 24             	mov    %eax,(%esp)
  80083b:	e8 7f fb ff ff       	call   8003bf <vprintfmt>
	va_end(ap);
}
  800840:	c9                   	leave  
  800841:	c3                   	ret    
	...

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  80085b:	eb 03                	jmp    800860 <strlen+0x10>
		n++;
  80085d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800860:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800864:	75 f7                	jne    80085d <strlen+0xd>
		n++;
	return n;
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800877:	eb 03                	jmp    80087c <strnlen+0x14>
		n++;
  800879:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	39 c1                	cmp    %eax,%ecx
  80087e:	74 06                	je     800886 <strnlen+0x1e>
  800880:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800884:	75 f3                	jne    800879 <strnlen+0x11>
		n++;
	return n;
}
  800886:	5b                   	pop    %ebx
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800893:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800898:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80089c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80089f:	83 c2 01             	add    $0x1,%edx
  8008a2:	84 c9                	test   %cl,%cl
  8008a4:	75 f2                	jne    800898 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008a6:	5b                   	pop    %ebx
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b3:	89 1c 24             	mov    %ebx,(%esp)
  8008b6:	e8 95 ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c2:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008c5:	89 04 24             	mov    %eax,(%esp)
  8008c8:	e8 bc ff ff ff       	call   800889 <strcpy>
	return dst;
}
  8008cd:	89 d8                	mov    %ebx,%eax
  8008cf:	83 c4 08             	add    $0x8,%esp
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	56                   	push   %esi
  8008d9:	53                   	push   %ebx
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e0:	8b 75 10             	mov    0x10(%ebp),%esi
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e8:	eb 0f                	jmp    8008f9 <strncpy+0x24>
		*dst++ = *src;
  8008ea:	0f b6 19             	movzbl (%ecx),%ebx
  8008ed:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f0:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f6:	83 c2 01             	add    $0x1,%edx
  8008f9:	39 f2                	cmp    %esi,%edx
  8008fb:	72 ed                	jb     8008ea <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fd:	5b                   	pop    %ebx
  8008fe:	5e                   	pop    %esi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 75 08             	mov    0x8(%ebp),%esi
  800909:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090f:	89 f0                	mov    %esi,%eax
  800911:	85 d2                	test   %edx,%edx
  800913:	75 0a                	jne    80091f <strlcpy+0x1e>
  800915:	eb 17                	jmp    80092e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800917:	88 18                	mov    %bl,(%eax)
  800919:	83 c0 01             	add    $0x1,%eax
  80091c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80091f:	83 ea 01             	sub    $0x1,%edx
  800922:	74 07                	je     80092b <strlcpy+0x2a>
  800924:	0f b6 19             	movzbl (%ecx),%ebx
  800927:	84 db                	test   %bl,%bl
  800929:	75 ec                	jne    800917 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  80092b:	c6 00 00             	movb   $0x0,(%eax)
  80092e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093d:	eb 06                	jmp    800945 <strcmp+0x11>
		p++, q++;
  80093f:	83 c1 01             	add    $0x1,%ecx
  800942:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800945:	0f b6 01             	movzbl (%ecx),%eax
  800948:	84 c0                	test   %al,%al
  80094a:	74 04                	je     800950 <strcmp+0x1c>
  80094c:	3a 02                	cmp    (%edx),%al
  80094e:	74 ef                	je     80093f <strcmp+0xb>
  800950:	0f b6 c0             	movzbl %al,%eax
  800953:	0f b6 12             	movzbl (%edx),%edx
  800956:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800964:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800967:	eb 09                	jmp    800972 <strncmp+0x18>
		n--, p++, q++;
  800969:	83 ea 01             	sub    $0x1,%edx
  80096c:	83 c0 01             	add    $0x1,%eax
  80096f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800972:	85 d2                	test   %edx,%edx
  800974:	75 07                	jne    80097d <strncmp+0x23>
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	eb 13                	jmp    800990 <strncmp+0x36>
  80097d:	0f b6 18             	movzbl (%eax),%ebx
  800980:	84 db                	test   %bl,%bl
  800982:	74 04                	je     800988 <strncmp+0x2e>
  800984:	3a 19                	cmp    (%ecx),%bl
  800986:	74 e1                	je     800969 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800988:	0f b6 00             	movzbl (%eax),%eax
  80098b:	0f b6 11             	movzbl (%ecx),%edx
  80098e:	29 d0                	sub    %edx,%eax
}
  800990:	5b                   	pop    %ebx
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80099d:	eb 07                	jmp    8009a6 <strchr+0x13>
		if (*s == c)
  80099f:	38 ca                	cmp    %cl,%dl
  8009a1:	74 0f                	je     8009b2 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a3:	83 c0 01             	add    $0x1,%eax
  8009a6:	0f b6 10             	movzbl (%eax),%edx
  8009a9:	84 d2                	test   %dl,%dl
  8009ab:	75 f2                	jne    80099f <strchr+0xc>
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009be:	eb 07                	jmp    8009c7 <strfind+0x13>
		if (*s == c)
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	74 0a                	je     8009ce <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	0f b6 10             	movzbl (%eax),%edx
  8009ca:	84 d2                	test   %dl,%dl
  8009cc:	75 f2                	jne    8009c0 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  8009ce:	5d                   	pop    %ebp
  8009cf:	90                   	nop
  8009d0:	c3                   	ret    

008009d1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	83 ec 0c             	sub    $0xc,%esp
  8009d7:	89 1c 24             	mov    %ebx,(%esp)
  8009da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009eb:	85 c9                	test   %ecx,%ecx
  8009ed:	74 30                	je     800a1f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009f5:	75 25                	jne    800a1c <memset+0x4b>
  8009f7:	f6 c1 03             	test   $0x3,%cl
  8009fa:	75 20                	jne    800a1c <memset+0x4b>
		c &= 0xFF;
  8009fc:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009ff:	89 d3                	mov    %edx,%ebx
  800a01:	c1 e3 08             	shl    $0x8,%ebx
  800a04:	89 d6                	mov    %edx,%esi
  800a06:	c1 e6 18             	shl    $0x18,%esi
  800a09:	89 d0                	mov    %edx,%eax
  800a0b:	c1 e0 10             	shl    $0x10,%eax
  800a0e:	09 f0                	or     %esi,%eax
  800a10:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a12:	09 d8                	or     %ebx,%eax
  800a14:	c1 e9 02             	shr    $0x2,%ecx
  800a17:	fc                   	cld    
  800a18:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1a:	eb 03                	jmp    800a1f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	8b 1c 24             	mov    (%esp),%ebx
  800a24:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a28:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a2c:	89 ec                	mov    %ebp,%esp
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 08             	sub    $0x8,%esp
  800a36:	89 34 24             	mov    %esi,(%esp)
  800a39:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a43:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a46:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a48:	39 c6                	cmp    %eax,%esi
  800a4a:	73 35                	jae    800a81 <memmove+0x51>
  800a4c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a4f:	39 d0                	cmp    %edx,%eax
  800a51:	73 2e                	jae    800a81 <memmove+0x51>
		s += n;
		d += n;
  800a53:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a55:	f6 c2 03             	test   $0x3,%dl
  800a58:	75 1b                	jne    800a75 <memmove+0x45>
  800a5a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a60:	75 13                	jne    800a75 <memmove+0x45>
  800a62:	f6 c1 03             	test   $0x3,%cl
  800a65:	75 0e                	jne    800a75 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a67:	83 ef 04             	sub    $0x4,%edi
  800a6a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a6d:	c1 e9 02             	shr    $0x2,%ecx
  800a70:	fd                   	std    
  800a71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a73:	eb 09                	jmp    800a7e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a75:	83 ef 01             	sub    $0x1,%edi
  800a78:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a7b:	fd                   	std    
  800a7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a7e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7f:	eb 20                	jmp    800aa1 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a81:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a87:	75 15                	jne    800a9e <memmove+0x6e>
  800a89:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8f:	75 0d                	jne    800a9e <memmove+0x6e>
  800a91:	f6 c1 03             	test   $0x3,%cl
  800a94:	75 08                	jne    800a9e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a96:	c1 e9 02             	shr    $0x2,%ecx
  800a99:	fc                   	cld    
  800a9a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9c:	eb 03                	jmp    800aa1 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a9e:	fc                   	cld    
  800a9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa1:	8b 34 24             	mov    (%esp),%esi
  800aa4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800aa8:	89 ec                	mov    %ebp,%esp
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	89 04 24             	mov    %eax,(%esp)
  800ac6:	e8 65 ff ff ff       	call   800a30 <memmove>
}
  800acb:	c9                   	leave  
  800acc:	c3                   	ret    

00800acd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800acd:	55                   	push   %ebp
  800ace:	89 e5                	mov    %esp,%ebp
  800ad0:	57                   	push   %edi
  800ad1:	56                   	push   %esi
  800ad2:	53                   	push   %ebx
  800ad3:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800adc:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae1:	eb 1c                	jmp    800aff <memcmp+0x32>
		if (*s1 != *s2)
  800ae3:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800ae7:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800aeb:	83 c2 01             	add    $0x1,%edx
  800aee:	83 e9 01             	sub    $0x1,%ecx
  800af1:	38 d8                	cmp    %bl,%al
  800af3:	74 0a                	je     800aff <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800af5:	0f b6 c0             	movzbl %al,%eax
  800af8:	0f b6 db             	movzbl %bl,%ebx
  800afb:	29 d8                	sub    %ebx,%eax
  800afd:	eb 09                	jmp    800b08 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aff:	85 c9                	test   %ecx,%ecx
  800b01:	75 e0                	jne    800ae3 <memcmp+0x16>
  800b03:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b16:	89 c2                	mov    %eax,%edx
  800b18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1b:	eb 07                	jmp    800b24 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b1d:	38 08                	cmp    %cl,(%eax)
  800b1f:	74 07                	je     800b28 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b21:	83 c0 01             	add    $0x1,%eax
  800b24:	39 d0                	cmp    %edx,%eax
  800b26:	72 f5                	jb     800b1d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	83 ec 04             	sub    $0x4,%esp
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	eb 03                	jmp    800b3e <strtol+0x14>
		s++;
  800b3b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3e:	0f b6 02             	movzbl (%edx),%eax
  800b41:	3c 20                	cmp    $0x20,%al
  800b43:	74 f6                	je     800b3b <strtol+0x11>
  800b45:	3c 09                	cmp    $0x9,%al
  800b47:	74 f2                	je     800b3b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b49:	3c 2b                	cmp    $0x2b,%al
  800b4b:	75 0c                	jne    800b59 <strtol+0x2f>
		s++;
  800b4d:	8d 52 01             	lea    0x1(%edx),%edx
  800b50:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b57:	eb 15                	jmp    800b6e <strtol+0x44>
	else if (*s == '-')
  800b59:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b60:	3c 2d                	cmp    $0x2d,%al
  800b62:	75 0a                	jne    800b6e <strtol+0x44>
		s++, neg = 1;
  800b64:	8d 52 01             	lea    0x1(%edx),%edx
  800b67:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6e:	85 db                	test   %ebx,%ebx
  800b70:	0f 94 c0             	sete   %al
  800b73:	74 05                	je     800b7a <strtol+0x50>
  800b75:	83 fb 10             	cmp    $0x10,%ebx
  800b78:	75 18                	jne    800b92 <strtol+0x68>
  800b7a:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7d:	75 13                	jne    800b92 <strtol+0x68>
  800b7f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b83:	75 0d                	jne    800b92 <strtol+0x68>
		s += 2, base = 16;
  800b85:	83 c2 02             	add    $0x2,%edx
  800b88:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8d:	8d 76 00             	lea    0x0(%esi),%esi
  800b90:	eb 13                	jmp    800ba5 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b92:	84 c0                	test   %al,%al
  800b94:	74 0f                	je     800ba5 <strtol+0x7b>
  800b96:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b9b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9e:	75 05                	jne    800ba5 <strtol+0x7b>
		s++, base = 8;
  800ba0:	83 c2 01             	add    $0x1,%edx
  800ba3:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba5:	b8 00 00 00 00       	mov    $0x0,%eax
  800baa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bac:	0f b6 0a             	movzbl (%edx),%ecx
  800baf:	89 cf                	mov    %ecx,%edi
  800bb1:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bb4:	80 fb 09             	cmp    $0x9,%bl
  800bb7:	77 08                	ja     800bc1 <strtol+0x97>
			dig = *s - '0';
  800bb9:	0f be c9             	movsbl %cl,%ecx
  800bbc:	83 e9 30             	sub    $0x30,%ecx
  800bbf:	eb 1e                	jmp    800bdf <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800bc1:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bc4:	80 fb 19             	cmp    $0x19,%bl
  800bc7:	77 08                	ja     800bd1 <strtol+0xa7>
			dig = *s - 'a' + 10;
  800bc9:	0f be c9             	movsbl %cl,%ecx
  800bcc:	83 e9 57             	sub    $0x57,%ecx
  800bcf:	eb 0e                	jmp    800bdf <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800bd1:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bd4:	80 fb 19             	cmp    $0x19,%bl
  800bd7:	77 15                	ja     800bee <strtol+0xc4>
			dig = *s - 'A' + 10;
  800bd9:	0f be c9             	movsbl %cl,%ecx
  800bdc:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bdf:	39 f1                	cmp    %esi,%ecx
  800be1:	7d 0b                	jge    800bee <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  800be3:	83 c2 01             	add    $0x1,%edx
  800be6:	0f af c6             	imul   %esi,%eax
  800be9:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bec:	eb be                	jmp    800bac <strtol+0x82>
  800bee:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bf0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf4:	74 05                	je     800bfb <strtol+0xd1>
		*endptr = (char *) s;
  800bf6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf9:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bff:	74 04                	je     800c05 <strtol+0xdb>
  800c01:	89 c8                	mov    %ecx,%eax
  800c03:	f7 d8                	neg    %eax
}
  800c05:	83 c4 04             	add    $0x4,%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    
  800c0d:	00 00                	add    %al,(%eax)
	...

00800c10 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	89 c3                	mov    %eax,%ebx
  800c2e:	89 c7                	mov    %eax,%edi
  800c30:	89 c6                	mov    %eax,%esi
  800c32:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c34:	8b 1c 24             	mov    (%esp),%ebx
  800c37:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c3b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c3f:	89 ec                	mov    %ebp,%esp
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 38             	sub    $0x38,%esp
  800c49:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c4c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c4f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  800c52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c56:	75 0c                	jne    800c64 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  800c58:	c7 04 24 c8 15 80 00 	movl   $0x8015c8,(%esp)
  800c5f:	e8 b1 f5 ff ff       	call   800215 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c69:	b8 09 00 00 00       	mov    $0x9,%eax
  800c6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c74:	89 df                	mov    %ebx,%edi
  800c76:	89 de                	mov    %ebx,%esi
  800c78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7e 28                	jle    800ca6 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c82:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800c89:	00 
  800c8a:	c7 44 24 08 f4 15 80 	movl   $0x8015f4,0x8(%esp)
  800c91:	00 
  800c92:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c99:	00 
  800c9a:	c7 04 24 11 16 80 00 	movl   $0x801611,(%esp)
  800ca1:	e8 b6 f4 ff ff       	call   80015c <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ca6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ca9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800caf:	89 ec                	mov    %ebp,%esp
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 38             	sub    $0x38,%esp
  800cb9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cbc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbf:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccf:	89 cb                	mov    %ecx,%ebx
  800cd1:	89 cf                	mov    %ecx,%edi
  800cd3:	89 ce                	mov    %ecx,%esi
  800cd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 28                	jle    800d03 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdf:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ce6:	00 
  800ce7:	c7 44 24 08 f4 15 80 	movl   $0x8015f4,0x8(%esp)
  800cee:	00 
  800cef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf6:	00 
  800cf7:	c7 04 24 11 16 80 00 	movl   $0x801611,(%esp)
  800cfe:	e8 59 f4 ff ff       	call   80015c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d03:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d06:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0c:	89 ec                	mov    %ebp,%esp
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	89 1c 24             	mov    %ebx,(%esp)
  800d19:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d1d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	be 00 00 00 00       	mov    $0x0,%esi
  800d26:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	8b 55 08             	mov    0x8(%ebp),%edx
  800d37:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d39:	8b 1c 24             	mov    (%esp),%ebx
  800d3c:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d40:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d44:	89 ec                	mov    %ebp,%esp
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 38             	sub    $0x38,%esp
  800d4e:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d51:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d54:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	89 df                	mov    %ebx,%edi
  800d69:	89 de                	mov    %ebx,%esi
  800d6b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 f4 15 80 	movl   $0x8015f4,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 11 16 80 00 	movl   $0x801611,(%esp)
  800d94:	e8 c3 f3 ff ff       	call   80015c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d99:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d9c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da2:	89 ec                	mov    %ebp,%esp
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 38             	sub    $0x38,%esp
  800dac:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800daf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dba:	b8 06 00 00 00       	mov    $0x6,%eax
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	89 df                	mov    %ebx,%edi
  800dc7:	89 de                	mov    %ebx,%esi
  800dc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7e 28                	jle    800df7 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd3:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800dda:	00 
  800ddb:	c7 44 24 08 f4 15 80 	movl   $0x8015f4,0x8(%esp)
  800de2:	00 
  800de3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dea:	00 
  800deb:	c7 04 24 11 16 80 00 	movl   $0x801611,(%esp)
  800df2:	e8 65 f3 ff ff       	call   80015c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800df7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dfa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e00:	89 ec                	mov    %ebp,%esp
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	83 ec 38             	sub    $0x38,%esp
  800e0a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e10:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	b8 05 00 00 00       	mov    $0x5,%eax
  800e18:	8b 75 18             	mov    0x18(%ebp),%esi
  800e1b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 f4 15 80 	movl   $0x8015f4,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 11 16 80 00 	movl   $0x801611,(%esp)
  800e50:	e8 07 f3 ff ff       	call   80015c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e55:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e58:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e5b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5e:	89 ec                	mov    %ebp,%esp
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 38             	sub    $0x38,%esp
  800e68:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e6b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	be 00 00 00 00       	mov    $0x0,%esi
  800e76:	b8 04 00 00 00       	mov    $0x4,%eax
  800e7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e81:	8b 55 08             	mov    0x8(%ebp),%edx
  800e84:	89 f7                	mov    %esi,%edi
  800e86:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	7e 28                	jle    800eb4 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e90:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e97:	00 
  800e98:	c7 44 24 08 f4 15 80 	movl   $0x8015f4,0x8(%esp)
  800e9f:	00 
  800ea0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea7:	00 
  800ea8:	c7 04 24 11 16 80 00 	movl   $0x801611,(%esp)
  800eaf:	e8 a8 f2 ff ff       	call   80015c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eb4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ebd:	89 ec                	mov    %ebp,%esp
  800ebf:	5d                   	pop    %ebp
  800ec0:	c3                   	ret    

00800ec1 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 0c             	sub    $0xc,%esp
  800ec7:	89 1c 24             	mov    %ebx,(%esp)
  800eca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ece:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800edc:	89 d1                	mov    %edx,%ecx
  800ede:	89 d3                	mov    %edx,%ebx
  800ee0:	89 d7                	mov    %edx,%edi
  800ee2:	89 d6                	mov    %edx,%esi
  800ee4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ee6:	8b 1c 24             	mov    (%esp),%ebx
  800ee9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800eed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ef1:	89 ec                	mov    %ebp,%esp
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	89 1c 24             	mov    %ebx,(%esp)
  800efe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f02:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f06:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0b:	b8 02 00 00 00       	mov    $0x2,%eax
  800f10:	89 d1                	mov    %edx,%ecx
  800f12:	89 d3                	mov    %edx,%ebx
  800f14:	89 d7                	mov    %edx,%edi
  800f16:	89 d6                	mov    %edx,%esi
  800f18:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f1a:	8b 1c 24             	mov    (%esp),%ebx
  800f1d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f21:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f25:	89 ec                	mov    %ebp,%esp
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	83 ec 38             	sub    $0x38,%esp
  800f2f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f32:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f35:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f3d:	b8 03 00 00 00       	mov    $0x3,%eax
  800f42:	8b 55 08             	mov    0x8(%ebp),%edx
  800f45:	89 cb                	mov    %ecx,%ebx
  800f47:	89 cf                	mov    %ecx,%edi
  800f49:	89 ce                	mov    %ecx,%esi
  800f4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	7e 28                	jle    800f79 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f55:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 08 f4 15 80 	movl   $0x8015f4,0x8(%esp)
  800f64:	00 
  800f65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f6c:	00 
  800f6d:	c7 04 24 11 16 80 00 	movl   $0x801611,(%esp)
  800f74:	e8 e3 f1 ff ff       	call   80015c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f79:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f7c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f7f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f82:	89 ec                	mov    %ebp,%esp
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	89 1c 24             	mov    %ebx,(%esp)
  800f8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f93:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f97:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa1:	89 d1                	mov    %edx,%ecx
  800fa3:	89 d3                	mov    %edx,%ebx
  800fa5:	89 d7                	mov    %edx,%edi
  800fa7:	89 d6                	mov    %edx,%esi
  800fa9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fab:	8b 1c 24             	mov    (%esp),%ebx
  800fae:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fb2:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fb6:	89 ec                	mov    %ebp,%esp
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    
	...

00800fbc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fc2:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fc9:	75 58                	jne    801023 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  800fcb:	a1 04 20 80 00       	mov    0x802004,%eax
  800fd0:	8b 40 48             	mov    0x48(%eax),%eax
  800fd3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800fda:	00 
  800fdb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800fe2:	ee 
  800fe3:	89 04 24             	mov    %eax,(%esp)
  800fe6:	e8 77 fe ff ff       	call   800e62 <sys_page_alloc>
  800feb:	85 c0                	test   %eax,%eax
  800fed:	74 1c                	je     80100b <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  800fef:	c7 44 24 08 20 16 80 	movl   $0x801620,0x8(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800ffe:	00 
  800fff:	c7 04 24 4c 16 80 00 	movl   $0x80164c,(%esp)
  801006:	e8 51 f1 ff ff       	call   80015c <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  80100b:	a1 04 20 80 00       	mov    0x802004,%eax
  801010:	8b 40 48             	mov    0x48(%eax),%eax
  801013:	c7 44 24 04 30 10 80 	movl   $0x801030,0x4(%esp)
  80101a:	00 
  80101b:	89 04 24             	mov    %eax,(%esp)
  80101e:	e8 20 fc ff ff       	call   800c43 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	a3 08 20 80 00       	mov    %eax,0x802008
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    
  80102d:	00 00                	add    %al,(%eax)
	...

00801030 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801030:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801031:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  801036:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801038:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl  %esp , %ebx
  80103b:	89 e3                	mov    %esp,%ebx
	movl  40(%esp) , %eax
  80103d:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl  48(%esp) , %esp
  801041:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl  %eax 
  801045:	50                   	push   %eax


	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl  %ebx , %esp
  801046:	89 dc                	mov    %ebx,%esp
	subl  $4 , 48(%esp)
  801048:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl  %eax
  80104d:	58                   	pop    %eax
	popl  %eax
  80104e:	58                   	pop    %eax
	popal
  80104f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4 , %esp
  801050:	83 c4 04             	add    $0x4,%esp
	popfl
  801053:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801054:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801055:	c3                   	ret    
	...

00801060 <__udivdi3>:
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	83 ec 10             	sub    $0x10,%esp
  801068:	8b 45 14             	mov    0x14(%ebp),%eax
  80106b:	8b 55 08             	mov    0x8(%ebp),%edx
  80106e:	8b 75 10             	mov    0x10(%ebp),%esi
  801071:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801074:	85 c0                	test   %eax,%eax
  801076:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801079:	75 35                	jne    8010b0 <__udivdi3+0x50>
  80107b:	39 fe                	cmp    %edi,%esi
  80107d:	77 61                	ja     8010e0 <__udivdi3+0x80>
  80107f:	85 f6                	test   %esi,%esi
  801081:	75 0b                	jne    80108e <__udivdi3+0x2e>
  801083:	b8 01 00 00 00       	mov    $0x1,%eax
  801088:	31 d2                	xor    %edx,%edx
  80108a:	f7 f6                	div    %esi
  80108c:	89 c6                	mov    %eax,%esi
  80108e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801091:	31 d2                	xor    %edx,%edx
  801093:	89 f8                	mov    %edi,%eax
  801095:	f7 f6                	div    %esi
  801097:	89 c7                	mov    %eax,%edi
  801099:	89 c8                	mov    %ecx,%eax
  80109b:	f7 f6                	div    %esi
  80109d:	89 c1                	mov    %eax,%ecx
  80109f:	89 fa                	mov    %edi,%edx
  8010a1:	89 c8                	mov    %ecx,%eax
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    
  8010aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b0:	39 f8                	cmp    %edi,%eax
  8010b2:	77 1c                	ja     8010d0 <__udivdi3+0x70>
  8010b4:	0f bd d0             	bsr    %eax,%edx
  8010b7:	83 f2 1f             	xor    $0x1f,%edx
  8010ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010bd:	75 39                	jne    8010f8 <__udivdi3+0x98>
  8010bf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8010c2:	0f 86 a0 00 00 00    	jbe    801168 <__udivdi3+0x108>
  8010c8:	39 f8                	cmp    %edi,%eax
  8010ca:	0f 82 98 00 00 00    	jb     801168 <__udivdi3+0x108>
  8010d0:	31 ff                	xor    %edi,%edi
  8010d2:	31 c9                	xor    %ecx,%ecx
  8010d4:	89 c8                	mov    %ecx,%eax
  8010d6:	89 fa                	mov    %edi,%edx
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    
  8010df:	90                   	nop
  8010e0:	89 d1                	mov    %edx,%ecx
  8010e2:	89 fa                	mov    %edi,%edx
  8010e4:	89 c8                	mov    %ecx,%eax
  8010e6:	31 ff                	xor    %edi,%edi
  8010e8:	f7 f6                	div    %esi
  8010ea:	89 c1                	mov    %eax,%ecx
  8010ec:	89 fa                	mov    %edi,%edx
  8010ee:	89 c8                	mov    %ecx,%eax
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    
  8010f7:	90                   	nop
  8010f8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010fc:	89 f2                	mov    %esi,%edx
  8010fe:	d3 e0                	shl    %cl,%eax
  801100:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801103:	b8 20 00 00 00       	mov    $0x20,%eax
  801108:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80110b:	89 c1                	mov    %eax,%ecx
  80110d:	d3 ea                	shr    %cl,%edx
  80110f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801113:	0b 55 ec             	or     -0x14(%ebp),%edx
  801116:	d3 e6                	shl    %cl,%esi
  801118:	89 c1                	mov    %eax,%ecx
  80111a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80111d:	89 fe                	mov    %edi,%esi
  80111f:	d3 ee                	shr    %cl,%esi
  801121:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801125:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80112b:	d3 e7                	shl    %cl,%edi
  80112d:	89 c1                	mov    %eax,%ecx
  80112f:	d3 ea                	shr    %cl,%edx
  801131:	09 d7                	or     %edx,%edi
  801133:	89 f2                	mov    %esi,%edx
  801135:	89 f8                	mov    %edi,%eax
  801137:	f7 75 ec             	divl   -0x14(%ebp)
  80113a:	89 d6                	mov    %edx,%esi
  80113c:	89 c7                	mov    %eax,%edi
  80113e:	f7 65 e8             	mull   -0x18(%ebp)
  801141:	39 d6                	cmp    %edx,%esi
  801143:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801146:	72 30                	jb     801178 <__udivdi3+0x118>
  801148:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80114b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80114f:	d3 e2                	shl    %cl,%edx
  801151:	39 c2                	cmp    %eax,%edx
  801153:	73 05                	jae    80115a <__udivdi3+0xfa>
  801155:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801158:	74 1e                	je     801178 <__udivdi3+0x118>
  80115a:	89 f9                	mov    %edi,%ecx
  80115c:	31 ff                	xor    %edi,%edi
  80115e:	e9 71 ff ff ff       	jmp    8010d4 <__udivdi3+0x74>
  801163:	90                   	nop
  801164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801168:	31 ff                	xor    %edi,%edi
  80116a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80116f:	e9 60 ff ff ff       	jmp    8010d4 <__udivdi3+0x74>
  801174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801178:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80117b:	31 ff                	xor    %edi,%edi
  80117d:	89 c8                	mov    %ecx,%eax
  80117f:	89 fa                	mov    %edi,%edx
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    
	...

00801190 <__umoddi3>:
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	57                   	push   %edi
  801194:	56                   	push   %esi
  801195:	83 ec 20             	sub    $0x20,%esp
  801198:	8b 55 14             	mov    0x14(%ebp),%edx
  80119b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011a4:	85 d2                	test   %edx,%edx
  8011a6:	89 c8                	mov    %ecx,%eax
  8011a8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8011ab:	75 13                	jne    8011c0 <__umoddi3+0x30>
  8011ad:	39 f7                	cmp    %esi,%edi
  8011af:	76 3f                	jbe    8011f0 <__umoddi3+0x60>
  8011b1:	89 f2                	mov    %esi,%edx
  8011b3:	f7 f7                	div    %edi
  8011b5:	89 d0                	mov    %edx,%eax
  8011b7:	31 d2                	xor    %edx,%edx
  8011b9:	83 c4 20             	add    $0x20,%esp
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    
  8011c0:	39 f2                	cmp    %esi,%edx
  8011c2:	77 4c                	ja     801210 <__umoddi3+0x80>
  8011c4:	0f bd ca             	bsr    %edx,%ecx
  8011c7:	83 f1 1f             	xor    $0x1f,%ecx
  8011ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8011cd:	75 51                	jne    801220 <__umoddi3+0x90>
  8011cf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8011d2:	0f 87 e0 00 00 00    	ja     8012b8 <__umoddi3+0x128>
  8011d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011db:	29 f8                	sub    %edi,%eax
  8011dd:	19 d6                	sbb    %edx,%esi
  8011df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e5:	89 f2                	mov    %esi,%edx
  8011e7:	83 c4 20             	add    $0x20,%esp
  8011ea:	5e                   	pop    %esi
  8011eb:	5f                   	pop    %edi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    
  8011ee:	66 90                	xchg   %ax,%ax
  8011f0:	85 ff                	test   %edi,%edi
  8011f2:	75 0b                	jne    8011ff <__umoddi3+0x6f>
  8011f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f9:	31 d2                	xor    %edx,%edx
  8011fb:	f7 f7                	div    %edi
  8011fd:	89 c7                	mov    %eax,%edi
  8011ff:	89 f0                	mov    %esi,%eax
  801201:	31 d2                	xor    %edx,%edx
  801203:	f7 f7                	div    %edi
  801205:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801208:	f7 f7                	div    %edi
  80120a:	eb a9                	jmp    8011b5 <__umoddi3+0x25>
  80120c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801210:	89 c8                	mov    %ecx,%eax
  801212:	89 f2                	mov    %esi,%edx
  801214:	83 c4 20             	add    $0x20,%esp
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    
  80121b:	90                   	nop
  80121c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801220:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801224:	d3 e2                	shl    %cl,%edx
  801226:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801229:	ba 20 00 00 00       	mov    $0x20,%edx
  80122e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801231:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801234:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801238:	89 fa                	mov    %edi,%edx
  80123a:	d3 ea                	shr    %cl,%edx
  80123c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801240:	0b 55 f4             	or     -0xc(%ebp),%edx
  801243:	d3 e7                	shl    %cl,%edi
  801245:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801249:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80124c:	89 f2                	mov    %esi,%edx
  80124e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801251:	89 c7                	mov    %eax,%edi
  801253:	d3 ea                	shr    %cl,%edx
  801255:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801259:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	d3 e6                	shl    %cl,%esi
  801260:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801264:	d3 ea                	shr    %cl,%edx
  801266:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80126a:	09 d6                	or     %edx,%esi
  80126c:	89 f0                	mov    %esi,%eax
  80126e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801271:	d3 e7                	shl    %cl,%edi
  801273:	89 f2                	mov    %esi,%edx
  801275:	f7 75 f4             	divl   -0xc(%ebp)
  801278:	89 d6                	mov    %edx,%esi
  80127a:	f7 65 e8             	mull   -0x18(%ebp)
  80127d:	39 d6                	cmp    %edx,%esi
  80127f:	72 2b                	jb     8012ac <__umoddi3+0x11c>
  801281:	39 c7                	cmp    %eax,%edi
  801283:	72 23                	jb     8012a8 <__umoddi3+0x118>
  801285:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801289:	29 c7                	sub    %eax,%edi
  80128b:	19 d6                	sbb    %edx,%esi
  80128d:	89 f0                	mov    %esi,%eax
  80128f:	89 f2                	mov    %esi,%edx
  801291:	d3 ef                	shr    %cl,%edi
  801293:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801297:	d3 e0                	shl    %cl,%eax
  801299:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80129d:	09 f8                	or     %edi,%eax
  80129f:	d3 ea                	shr    %cl,%edx
  8012a1:	83 c4 20             	add    $0x20,%esp
  8012a4:	5e                   	pop    %esi
  8012a5:	5f                   	pop    %edi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    
  8012a8:	39 d6                	cmp    %edx,%esi
  8012aa:	75 d9                	jne    801285 <__umoddi3+0xf5>
  8012ac:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8012af:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8012b2:	eb d1                	jmp    801285 <__umoddi3+0xf5>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	39 f2                	cmp    %esi,%edx
  8012ba:	0f 82 18 ff ff ff    	jb     8011d8 <__umoddi3+0x48>
  8012c0:	e9 1d ff ff ff       	jmp    8011e2 <__umoddi3+0x52>
