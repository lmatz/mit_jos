
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 73 05 00 00       	call   8005a4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  80004d:	8b 45 08             	mov    0x8(%ebp),%eax
  800050:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800054:	89 54 24 08          	mov    %edx,0x8(%esp)
  800058:	c7 44 24 04 b1 17 80 	movl   $0x8017b1,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 80 17 80 00 	movl   $0x801780,(%esp)
  800067:	e8 55 06 00 00       	call   8006c1 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	89 44 24 08          	mov    %eax,0x8(%esp)
  800078:	c7 44 24 04 90 17 80 	movl   $0x801790,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  800087:	e8 35 06 00 00       	call   8006c1 <cprintf>
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	3b 06                	cmp    (%esi),%eax
  800090:	75 13                	jne    8000a5 <check_regs+0x65>
  800092:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800099:	e8 23 06 00 00       	call   8006c1 <cprintf>
  80009e:	bf 00 00 00 00       	mov    $0x0,%edi
  8000a3:	eb 11                	jmp    8000b6 <check_regs+0x76>
  8000a5:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8000ac:	e8 10 06 00 00       	call   8006c1 <cprintf>
  8000b1:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000b6:	8b 46 04             	mov    0x4(%esi),%eax
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8000c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c4:	c7 44 24 04 b2 17 80 	movl   $0x8017b2,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8000d3:	e8 e9 05 00 00       	call   8006c1 <cprintf>
  8000d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8000db:	3b 46 04             	cmp    0x4(%esi),%eax
  8000de:	75 0e                	jne    8000ee <check_regs+0xae>
  8000e0:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  8000e7:	e8 d5 05 00 00       	call   8006c1 <cprintf>
  8000ec:	eb 11                	jmp    8000ff <check_regs+0xbf>
  8000ee:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8000f5:	e8 c7 05 00 00       	call   8006c1 <cprintf>
  8000fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000ff:	8b 46 08             	mov    0x8(%esi),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 43 08             	mov    0x8(%ebx),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	c7 44 24 04 b6 17 80 	movl   $0x8017b6,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  80011c:	e8 a0 05 00 00       	call   8006c1 <cprintf>
  800121:	8b 43 08             	mov    0x8(%ebx),%eax
  800124:	3b 46 08             	cmp    0x8(%esi),%eax
  800127:	75 0e                	jne    800137 <check_regs+0xf7>
  800129:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800130:	e8 8c 05 00 00       	call   8006c1 <cprintf>
  800135:	eb 11                	jmp    800148 <check_regs+0x108>
  800137:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  80013e:	e8 7e 05 00 00       	call   8006c1 <cprintf>
  800143:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800148:	8b 46 10             	mov    0x10(%esi),%eax
  80014b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014f:	8b 43 10             	mov    0x10(%ebx),%eax
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	c7 44 24 04 ba 17 80 	movl   $0x8017ba,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  800165:	e8 57 05 00 00       	call   8006c1 <cprintf>
  80016a:	8b 43 10             	mov    0x10(%ebx),%eax
  80016d:	3b 46 10             	cmp    0x10(%esi),%eax
  800170:	75 0e                	jne    800180 <check_regs+0x140>
  800172:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800179:	e8 43 05 00 00       	call   8006c1 <cprintf>
  80017e:	eb 11                	jmp    800191 <check_regs+0x151>
  800180:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800187:	e8 35 05 00 00       	call   8006c1 <cprintf>
  80018c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800191:	8b 46 14             	mov    0x14(%esi),%eax
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	8b 43 14             	mov    0x14(%ebx),%eax
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	c7 44 24 04 be 17 80 	movl   $0x8017be,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8001ae:	e8 0e 05 00 00       	call   8006c1 <cprintf>
  8001b3:	8b 43 14             	mov    0x14(%ebx),%eax
  8001b6:	3b 46 14             	cmp    0x14(%esi),%eax
  8001b9:	75 0e                	jne    8001c9 <check_regs+0x189>
  8001bb:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  8001c2:	e8 fa 04 00 00       	call   8006c1 <cprintf>
  8001c7:	eb 11                	jmp    8001da <check_regs+0x19a>
  8001c9:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8001d0:	e8 ec 04 00 00       	call   8006c1 <cprintf>
  8001d5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001da:	8b 46 18             	mov    0x18(%esi),%eax
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	8b 43 18             	mov    0x18(%ebx),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	c7 44 24 04 c2 17 80 	movl   $0x8017c2,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8001f7:	e8 c5 04 00 00       	call   8006c1 <cprintf>
  8001fc:	8b 43 18             	mov    0x18(%ebx),%eax
  8001ff:	3b 46 18             	cmp    0x18(%esi),%eax
  800202:	75 0e                	jne    800212 <check_regs+0x1d2>
  800204:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  80020b:	e8 b1 04 00 00       	call   8006c1 <cprintf>
  800210:	eb 11                	jmp    800223 <check_regs+0x1e3>
  800212:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800219:	e8 a3 04 00 00       	call   8006c1 <cprintf>
  80021e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800223:	8b 46 1c             	mov    0x1c(%esi),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	c7 44 24 04 c6 17 80 	movl   $0x8017c6,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  800240:	e8 7c 04 00 00       	call   8006c1 <cprintf>
  800245:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800248:	3b 46 1c             	cmp    0x1c(%esi),%eax
  80024b:	75 0e                	jne    80025b <check_regs+0x21b>
  80024d:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800254:	e8 68 04 00 00       	call   8006c1 <cprintf>
  800259:	eb 11                	jmp    80026c <check_regs+0x22c>
  80025b:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800262:	e8 5a 04 00 00       	call   8006c1 <cprintf>
  800267:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80026c:	8b 46 20             	mov    0x20(%esi),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 43 20             	mov    0x20(%ebx),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	c7 44 24 04 ca 17 80 	movl   $0x8017ca,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  800289:	e8 33 04 00 00       	call   8006c1 <cprintf>
  80028e:	8b 43 20             	mov    0x20(%ebx),%eax
  800291:	3b 46 20             	cmp    0x20(%esi),%eax
  800294:	75 0e                	jne    8002a4 <check_regs+0x264>
  800296:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  80029d:	e8 1f 04 00 00       	call   8006c1 <cprintf>
  8002a2:	eb 11                	jmp    8002b5 <check_regs+0x275>
  8002a4:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8002ab:	e8 11 04 00 00       	call   8006c1 <cprintf>
  8002b0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002b5:	8b 46 24             	mov    0x24(%esi),%eax
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 43 24             	mov    0x24(%ebx),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 04 ce 17 80 	movl   $0x8017ce,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8002d2:	e8 ea 03 00 00       	call   8006c1 <cprintf>
  8002d7:	8b 43 24             	mov    0x24(%ebx),%eax
  8002da:	3b 46 24             	cmp    0x24(%esi),%eax
  8002dd:	75 0e                	jne    8002ed <check_regs+0x2ad>
  8002df:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  8002e6:	e8 d6 03 00 00       	call   8006c1 <cprintf>
  8002eb:	eb 11                	jmp    8002fe <check_regs+0x2be>
  8002ed:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  8002f4:	e8 c8 03 00 00       	call   8006c1 <cprintf>
  8002f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002fe:	8b 46 28             	mov    0x28(%esi),%eax
  800301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800305:	8b 43 28             	mov    0x28(%ebx),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	c7 44 24 04 d5 17 80 	movl   $0x8017d5,0x4(%esp)
  800313:	00 
  800314:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  80031b:	e8 a1 03 00 00       	call   8006c1 <cprintf>
  800320:	8b 43 28             	mov    0x28(%ebx),%eax
  800323:	3b 46 28             	cmp    0x28(%esi),%eax
  800326:	75 25                	jne    80034d <check_regs+0x30d>
  800328:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  80032f:	e8 8d 03 00 00       	call   8006c1 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	c7 04 24 d9 17 80 00 	movl   $0x8017d9,(%esp)
  800342:	e8 7a 03 00 00       	call   8006c1 <cprintf>
	if (!mismatch)
  800347:	85 ff                	test   %edi,%edi
  800349:	74 23                	je     80036e <check_regs+0x32e>
  80034b:	eb 2f                	jmp    80037c <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  80034d:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800354:	e8 68 03 00 00       	call   8006c1 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 d9 17 80 00 	movl   $0x8017d9,(%esp)
  800367:	e8 55 03 00 00       	call   8006c1 <cprintf>
  80036c:	eb 0e                	jmp    80037c <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  80036e:	c7 04 24 a4 17 80 00 	movl   $0x8017a4,(%esp)
  800375:	e8 47 03 00 00       	call   8006c1 <cprintf>
  80037a:	eb 0c                	jmp    800388 <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80037c:	c7 04 24 a8 17 80 00 	movl   $0x8017a8,(%esp)
  800383:	e8 39 03 00 00       	call   8006c1 <cprintf>
}
  800388:	83 c4 1c             	add    $0x1c,%esp
  80038b:	5b                   	pop    %ebx
  80038c:	5e                   	pop    %esi
  80038d:	5f                   	pop    %edi
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <umain>:
		panic("sys_page_alloc: %e", r);
}

void
umain(int argc, char **argv)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800396:	c7 04 24 a1 04 80 00 	movl   $0x8004a1,(%esp)
  80039d:	e8 ba 10 00 00       	call   80145c <set_pgfault_handler>

	__asm __volatile(
  8003a2:	50                   	push   %eax
  8003a3:	9c                   	pushf  
  8003a4:	58                   	pop    %eax
  8003a5:	0d d5 08 00 00       	or     $0x8d5,%eax
  8003aa:	50                   	push   %eax
  8003ab:	9d                   	popf   
  8003ac:	a3 44 20 80 00       	mov    %eax,0x802044
  8003b1:	8d 05 ec 03 80 00    	lea    0x8003ec,%eax
  8003b7:	a3 40 20 80 00       	mov    %eax,0x802040
  8003bc:	58                   	pop    %eax
  8003bd:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8003c3:	89 35 24 20 80 00    	mov    %esi,0x802024
  8003c9:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8003cf:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8003d5:	89 15 34 20 80 00    	mov    %edx,0x802034
  8003db:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8003e1:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8003e6:	89 25 48 20 80 00    	mov    %esp,0x802048
  8003ec:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8003f3:	00 00 00 
  8003f6:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8003fc:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  800402:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800408:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80040e:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800414:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  80041a:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  80041f:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800425:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  80042b:	8b 35 24 20 80 00    	mov    0x802024,%esi
  800431:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  800437:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  80043d:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800443:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  800449:	a1 3c 20 80 00       	mov    0x80203c,%eax
  80044e:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800454:	50                   	push   %eax
  800455:	9c                   	pushf  
  800456:	58                   	pop    %eax
  800457:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  80045c:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80045d:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800464:	74 0c                	je     800472 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800466:	c7 04 24 40 18 80 00 	movl   $0x801840,(%esp)
  80046d:	e8 4f 02 00 00       	call   8006c1 <cprintf>
	after.eip = before.eip;
  800472:	a1 40 20 80 00       	mov    0x802040,%eax
  800477:	a3 c0 20 80 00       	mov    %eax,0x8020c0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80047c:	c7 44 24 04 ee 17 80 	movl   $0x8017ee,0x4(%esp)
  800483:	00 
  800484:	c7 04 24 ff 17 80 00 	movl   $0x8017ff,(%esp)
  80048b:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800490:	ba e7 17 80 00       	mov    $0x8017e7,%edx
  800495:	b8 20 20 80 00       	mov    $0x802020,%eax
  80049a:	e8 a1 fb ff ff       	call   800040 <check_regs>
}
  80049f:	c9                   	leave  
  8004a0:	c3                   	ret    

008004a1 <pgfault>:
		cprintf("MISMATCH\n");
}

static void
pgfault(struct UTrapframe *utf)
{
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
  8004a4:	83 ec 28             	sub    $0x28,%esp
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8004b2:	74 27                	je     8004db <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004b4:	8b 40 28             	mov    0x28(%eax),%eax
  8004b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bf:	c7 44 24 08 60 18 80 	movl   $0x801860,0x8(%esp)
  8004c6:	00 
  8004c7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  8004d6:	e8 2d 01 00 00       	call   800608 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8004db:	8b 50 08             	mov    0x8(%eax),%edx
  8004de:	89 15 60 20 80 00    	mov    %edx,0x802060
  8004e4:	8b 50 0c             	mov    0xc(%eax),%edx
  8004e7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8004ed:	8b 50 10             	mov    0x10(%eax),%edx
  8004f0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8004f6:	8b 50 14             	mov    0x14(%eax),%edx
  8004f9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8004ff:	8b 50 18             	mov    0x18(%eax),%edx
  800502:	89 15 70 20 80 00    	mov    %edx,0x802070
  800508:	8b 50 1c             	mov    0x1c(%eax),%edx
  80050b:	89 15 74 20 80 00    	mov    %edx,0x802074
  800511:	8b 50 20             	mov    0x20(%eax),%edx
  800514:	89 15 78 20 80 00    	mov    %edx,0x802078
  80051a:	8b 50 24             	mov    0x24(%eax),%edx
  80051d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800523:	8b 50 28             	mov    0x28(%eax),%edx
  800526:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80052c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80052f:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800535:	8b 40 30             	mov    0x30(%eax),%eax
  800538:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80053d:	c7 44 24 04 16 18 80 	movl   $0x801816,0x4(%esp)
  800544:	00 
  800545:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  80054c:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800551:	ba e7 17 80 00       	mov    $0x8017e7,%edx
  800556:	b8 20 20 80 00       	mov    $0x802020,%eax
  80055b:	e8 e0 fa ff ff       	call   800040 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800560:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800567:	00 
  800568:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80056f:	00 
  800570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800577:	e8 86 0d 00 00       	call   801302 <sys_page_alloc>
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 20                	jns    8005a0 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800584:	c7 44 24 08 2b 18 80 	movl   $0x80182b,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 05 18 80 00 	movl   $0x801805,(%esp)
  80059b:	e8 68 00 00 00       	call   800608 <_panic>
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    
	...

008005a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	83 ec 18             	sub    $0x18,%esp
  8005aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005ad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t eid=sys_getenvid();
  8005b6:	e8 da 0d 00 00       	call   801395 <sys_getenvid>
	thisenv = (struct Env*)envs+ENVX(eid);
  8005bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005c8:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005cd:	85 f6                	test   %esi,%esi
  8005cf:	7e 07                	jle    8005d8 <libmain+0x34>
		binaryname = argv[0];
  8005d1:	8b 03                	mov    (%ebx),%eax
  8005d3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	89 34 24             	mov    %esi,(%esp)
  8005df:	e8 ac fd ff ff       	call   800390 <umain>

	// exit gracefully
	exit();
  8005e4:	e8 0b 00 00 00       	call   8005f4 <exit>
}
  8005e9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005ec:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005ef:	89 ec                	mov    %ebp,%esp
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    
	...

008005f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8005fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800601:	e8 c3 0d 00 00       	call   8013c9 <sys_env_destroy>
}
  800606:	c9                   	leave  
  800607:	c3                   	ret    

00800608 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800608:	55                   	push   %ebp
  800609:	89 e5                	mov    %esp,%ebp
  80060b:	56                   	push   %esi
  80060c:	53                   	push   %ebx
  80060d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800610:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800613:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800619:	e8 77 0d 00 00       	call   801395 <sys_getenvid>
  80061e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800621:	89 54 24 10          	mov    %edx,0x10(%esp)
  800625:	8b 55 08             	mov    0x8(%ebp),%edx
  800628:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80062c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800630:	89 44 24 04          	mov    %eax,0x4(%esp)
  800634:	c7 04 24 9c 18 80 00 	movl   $0x80189c,(%esp)
  80063b:	e8 81 00 00 00       	call   8006c1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800640:	89 74 24 04          	mov    %esi,0x4(%esp)
  800644:	8b 45 10             	mov    0x10(%ebp),%eax
  800647:	89 04 24             	mov    %eax,(%esp)
  80064a:	e8 11 00 00 00       	call   800660 <vcprintf>
	cprintf("\n");
  80064f:	c7 04 24 b0 17 80 00 	movl   $0x8017b0,(%esp)
  800656:	e8 66 00 00 00       	call   8006c1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80065b:	cc                   	int3   
  80065c:	eb fd                	jmp    80065b <_panic+0x53>
	...

00800660 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800660:	55                   	push   %ebp
  800661:	89 e5                	mov    %esp,%ebp
  800663:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800669:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800670:	00 00 00 
	b.cnt = 0;
  800673:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80067a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80067d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800680:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800684:	8b 45 08             	mov    0x8(%ebp),%eax
  800687:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800691:	89 44 24 04          	mov    %eax,0x4(%esp)
  800695:	c7 04 24 db 06 80 00 	movl   $0x8006db,(%esp)
  80069c:	e8 be 01 00 00       	call   80085f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b1:	89 04 24             	mov    %eax,(%esp)
  8006b4:	e8 f7 09 00 00       	call   8010b0 <sys_cputs>

	return b.cnt;
}
  8006b9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8006c7:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8006ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d1:	89 04 24             	mov    %eax,(%esp)
  8006d4:	e8 87 ff ff ff       	call   800660 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006d9:	c9                   	leave  
  8006da:	c3                   	ret    

008006db <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	53                   	push   %ebx
  8006df:	83 ec 14             	sub    $0x14,%esp
  8006e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006e5:	8b 03                	mov    (%ebx),%eax
  8006e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ea:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8006ee:	83 c0 01             	add    $0x1,%eax
  8006f1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006f3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006f8:	75 19                	jne    800713 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8006fa:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800701:	00 
  800702:	8d 43 08             	lea    0x8(%ebx),%eax
  800705:	89 04 24             	mov    %eax,(%esp)
  800708:	e8 a3 09 00 00       	call   8010b0 <sys_cputs>
		b->idx = 0;
  80070d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800713:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800717:	83 c4 14             	add    $0x14,%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5d                   	pop    %ebp
  80071c:	c3                   	ret    
  80071d:	00 00                	add    %al,(%eax)
	...

00800720 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	57                   	push   %edi
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	83 ec 4c             	sub    $0x4c,%esp
  800729:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072c:	89 d6                	mov    %edx,%esi
  80072e:	8b 45 08             	mov    0x8(%ebp),%eax
  800731:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
  800737:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800740:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800743:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800746:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074b:	39 d1                	cmp    %edx,%ecx
  80074d:	72 07                	jb     800756 <printnum+0x36>
  80074f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800752:	39 d0                	cmp    %edx,%eax
  800754:	77 69                	ja     8007bf <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800756:	89 7c 24 10          	mov    %edi,0x10(%esp)
  80075a:	83 eb 01             	sub    $0x1,%ebx
  80075d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800761:	89 44 24 08          	mov    %eax,0x8(%esp)
  800765:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800769:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80076d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800770:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800773:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800776:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80077a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800781:	00 
  800782:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800785:	89 04 24             	mov    %eax,(%esp)
  800788:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80078b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80078f:	e8 6c 0d 00 00       	call   801500 <__udivdi3>
  800794:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800797:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  80079a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80079e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007a2:	89 04 24             	mov    %eax,(%esp)
  8007a5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a9:	89 f2                	mov    %esi,%edx
  8007ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007ae:	e8 6d ff ff ff       	call   800720 <printnum>
  8007b3:	eb 11                	jmp    8007c6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b9:	89 3c 24             	mov    %edi,(%esp)
  8007bc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007bf:	83 eb 01             	sub    $0x1,%ebx
  8007c2:	85 db                	test   %ebx,%ebx
  8007c4:	7f ef                	jg     8007b5 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ca:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007dc:	00 
  8007dd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e0:	89 14 24             	mov    %edx,(%esp)
  8007e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007ea:	e8 41 0e 00 00       	call   801630 <__umoddi3>
  8007ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f3:	0f be 80 bf 18 80 00 	movsbl 0x8018bf(%eax),%eax
  8007fa:	89 04 24             	mov    %eax,(%esp)
  8007fd:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800800:	83 c4 4c             	add    $0x4c,%esp
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5f                   	pop    %edi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80080b:	83 fa 01             	cmp    $0x1,%edx
  80080e:	7e 0e                	jle    80081e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800810:	8b 10                	mov    (%eax),%edx
  800812:	8d 4a 08             	lea    0x8(%edx),%ecx
  800815:	89 08                	mov    %ecx,(%eax)
  800817:	8b 02                	mov    (%edx),%eax
  800819:	8b 52 04             	mov    0x4(%edx),%edx
  80081c:	eb 22                	jmp    800840 <getuint+0x38>
	else if (lflag)
  80081e:	85 d2                	test   %edx,%edx
  800820:	74 10                	je     800832 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800822:	8b 10                	mov    (%eax),%edx
  800824:	8d 4a 04             	lea    0x4(%edx),%ecx
  800827:	89 08                	mov    %ecx,(%eax)
  800829:	8b 02                	mov    (%edx),%eax
  80082b:	ba 00 00 00 00       	mov    $0x0,%edx
  800830:	eb 0e                	jmp    800840 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800832:	8b 10                	mov    (%eax),%edx
  800834:	8d 4a 04             	lea    0x4(%edx),%ecx
  800837:	89 08                	mov    %ecx,(%eax)
  800839:	8b 02                	mov    (%edx),%eax
  80083b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800848:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80084c:	8b 10                	mov    (%eax),%edx
  80084e:	3b 50 04             	cmp    0x4(%eax),%edx
  800851:	73 0a                	jae    80085d <sprintputch+0x1b>
		*b->buf++ = ch;
  800853:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800856:	88 0a                	mov    %cl,(%edx)
  800858:	83 c2 01             	add    $0x1,%edx
  80085b:	89 10                	mov    %edx,(%eax)
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	57                   	push   %edi
  800863:	56                   	push   %esi
  800864:	53                   	push   %ebx
  800865:	83 ec 4c             	sub    $0x4c,%esp
  800868:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80086e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800871:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800878:	eb 11                	jmp    80088b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80087a:	85 c0                	test   %eax,%eax
  80087c:	0f 84 b0 03 00 00    	je     800c32 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
  800882:	89 74 24 04          	mov    %esi,0x4(%esp)
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80088b:	0f b6 03             	movzbl (%ebx),%eax
  80088e:	83 c3 01             	add    $0x1,%ebx
  800891:	83 f8 25             	cmp    $0x25,%eax
  800894:	75 e4                	jne    80087a <vprintfmt+0x1b>
  800896:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80089d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a2:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8008a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008ad:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8008b4:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8008b7:	eb 06                	jmp    8008bf <vprintfmt+0x60>
  8008b9:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8008bd:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bf:	0f b6 0b             	movzbl (%ebx),%ecx
  8008c2:	0f b6 c1             	movzbl %cl,%eax
  8008c5:	8d 53 01             	lea    0x1(%ebx),%edx
  8008c8:	83 e9 23             	sub    $0x23,%ecx
  8008cb:	80 f9 55             	cmp    $0x55,%cl
  8008ce:	0f 87 41 03 00 00    	ja     800c15 <vprintfmt+0x3b6>
  8008d4:	0f b6 c9             	movzbl %cl,%ecx
  8008d7:	ff 24 8d 80 19 80 00 	jmp    *0x801980(,%ecx,4)
  8008de:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8008e2:	eb d9                	jmp    8008bd <vprintfmt+0x5e>
  8008e4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
  8008eb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008f0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8008f3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
  8008f7:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  8008fa:	8d 58 d0             	lea    -0x30(%eax),%ebx
  8008fd:	83 fb 09             	cmp    $0x9,%ebx
  800900:	77 2b                	ja     80092d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800902:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800905:	eb e9                	jmp    8008f0 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8d 48 04             	lea    0x4(%eax),%ecx
  80090d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800910:	8b 00                	mov    (%eax),%eax
  800912:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
  800915:	eb 19                	jmp    800930 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
  800917:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80091a:	c1 f8 1f             	sar    $0x1f,%eax
  80091d:	f7 d0                	not    %eax
  80091f:	21 45 e4             	and    %eax,-0x1c(%ebp)
  800922:	eb 99                	jmp    8008bd <vprintfmt+0x5e>
  800924:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  80092b:	eb 90                	jmp    8008bd <vprintfmt+0x5e>
  80092d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
  800930:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800934:	79 87                	jns    8008bd <vprintfmt+0x5e>
  800936:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800939:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80093c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80093f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800942:	e9 76 ff ff ff       	jmp    8008bd <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800947:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80094b:	e9 6d ff ff ff       	jmp    8008bd <vprintfmt+0x5e>
  800950:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800953:	8b 45 14             	mov    0x14(%ebp),%eax
  800956:	8d 50 04             	lea    0x4(%eax),%edx
  800959:	89 55 14             	mov    %edx,0x14(%ebp)
  80095c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800960:	8b 00                	mov    (%eax),%eax
  800962:	89 04 24             	mov    %eax,(%esp)
  800965:	ff d7                	call   *%edi
  800967:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80096a:	e9 1c ff ff ff       	jmp    80088b <vprintfmt+0x2c>
  80096f:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8d 50 04             	lea    0x4(%eax),%edx
  800978:	89 55 14             	mov    %edx,0x14(%ebp)
  80097b:	8b 00                	mov    (%eax),%eax
  80097d:	89 c2                	mov    %eax,%edx
  80097f:	c1 fa 1f             	sar    $0x1f,%edx
  800982:	31 d0                	xor    %edx,%eax
  800984:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800986:	83 f8 09             	cmp    $0x9,%eax
  800989:	7f 0b                	jg     800996 <vprintfmt+0x137>
  80098b:	8b 14 85 e0 1a 80 00 	mov    0x801ae0(,%eax,4),%edx
  800992:	85 d2                	test   %edx,%edx
  800994:	75 20                	jne    8009b6 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
  800996:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80099a:	c7 44 24 08 d0 18 80 	movl   $0x8018d0,0x8(%esp)
  8009a1:	00 
  8009a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a6:	89 3c 24             	mov    %edi,(%esp)
  8009a9:	e8 0c 03 00 00       	call   800cba <printfmt>
  8009ae:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009b1:	e9 d5 fe ff ff       	jmp    80088b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009ba:	c7 44 24 08 d9 18 80 	movl   $0x8018d9,0x8(%esp)
  8009c1:	00 
  8009c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009c6:	89 3c 24             	mov    %edi,(%esp)
  8009c9:	e8 ec 02 00 00       	call   800cba <printfmt>
  8009ce:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8009d1:	e9 b5 fe ff ff       	jmp    80088b <vprintfmt+0x2c>
  8009d6:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009dc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8009df:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e5:	8d 50 04             	lea    0x4(%eax),%edx
  8009e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009eb:	8b 18                	mov    (%eax),%ebx
  8009ed:	85 db                	test   %ebx,%ebx
  8009ef:	75 05                	jne    8009f6 <vprintfmt+0x197>
  8009f1:	bb dc 18 80 00       	mov    $0x8018dc,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
  8009f6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009fa:	7e 76                	jle    800a72 <vprintfmt+0x213>
  8009fc:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800a00:	74 7a                	je     800a7c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a06:	89 1c 24             	mov    %ebx,(%esp)
  800a09:	e8 fa 02 00 00       	call   800d08 <strnlen>
  800a0e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800a11:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
  800a13:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800a17:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800a1a:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800a1d:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a1f:	eb 0f                	jmp    800a30 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800a21:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a25:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a28:	89 04 24             	mov    %eax,(%esp)
  800a2b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a2d:	83 eb 01             	sub    $0x1,%ebx
  800a30:	85 db                	test   %ebx,%ebx
  800a32:	7f ed                	jg     800a21 <vprintfmt+0x1c2>
  800a34:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800a37:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a3a:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800a3d:	89 f7                	mov    %esi,%edi
  800a3f:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a42:	eb 40                	jmp    800a84 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a44:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a48:	74 18                	je     800a62 <vprintfmt+0x203>
  800a4a:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a4d:	83 fa 5e             	cmp    $0x5e,%edx
  800a50:	76 10                	jbe    800a62 <vprintfmt+0x203>
					putch('?', putdat);
  800a52:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a56:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a5d:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a60:	eb 0a                	jmp    800a6c <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800a62:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a6c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800a70:	eb 12                	jmp    800a84 <vprintfmt+0x225>
  800a72:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800a75:	89 f7                	mov    %esi,%edi
  800a77:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a7a:	eb 08                	jmp    800a84 <vprintfmt+0x225>
  800a7c:	89 7d e0             	mov    %edi,-0x20(%ebp)
  800a7f:	89 f7                	mov    %esi,%edi
  800a81:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800a84:	0f be 03             	movsbl (%ebx),%eax
  800a87:	83 c3 01             	add    $0x1,%ebx
  800a8a:	85 c0                	test   %eax,%eax
  800a8c:	74 25                	je     800ab3 <vprintfmt+0x254>
  800a8e:	85 f6                	test   %esi,%esi
  800a90:	78 b2                	js     800a44 <vprintfmt+0x1e5>
  800a92:	83 ee 01             	sub    $0x1,%esi
  800a95:	79 ad                	jns    800a44 <vprintfmt+0x1e5>
  800a97:	89 fe                	mov    %edi,%esi
  800a99:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800a9c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a9f:	eb 1a                	jmp    800abb <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aa1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aa5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800aac:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aae:	83 eb 01             	sub    $0x1,%ebx
  800ab1:	eb 08                	jmp    800abb <vprintfmt+0x25c>
  800ab3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ab6:	89 fe                	mov    %edi,%esi
  800ab8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800abb:	85 db                	test   %ebx,%ebx
  800abd:	7f e2                	jg     800aa1 <vprintfmt+0x242>
  800abf:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800ac2:	e9 c4 fd ff ff       	jmp    80088b <vprintfmt+0x2c>
  800ac7:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800aca:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800acd:	83 f9 01             	cmp    $0x1,%ecx
  800ad0:	7e 16                	jle    800ae8 <vprintfmt+0x289>
		return va_arg(*ap, long long);
  800ad2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad5:	8d 50 08             	lea    0x8(%eax),%edx
  800ad8:	89 55 14             	mov    %edx,0x14(%ebp)
  800adb:	8b 10                	mov    (%eax),%edx
  800add:	8b 48 04             	mov    0x4(%eax),%ecx
  800ae0:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800ae3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ae6:	eb 32                	jmp    800b1a <vprintfmt+0x2bb>
	else if (lflag)
  800ae8:	85 c9                	test   %ecx,%ecx
  800aea:	74 18                	je     800b04 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
  800aec:	8b 45 14             	mov    0x14(%ebp),%eax
  800aef:	8d 50 04             	lea    0x4(%eax),%edx
  800af2:	89 55 14             	mov    %edx,0x14(%ebp)
  800af5:	8b 00                	mov    (%eax),%eax
  800af7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800afa:	89 c1                	mov    %eax,%ecx
  800afc:	c1 f9 1f             	sar    $0x1f,%ecx
  800aff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b02:	eb 16                	jmp    800b1a <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
  800b04:	8b 45 14             	mov    0x14(%ebp),%eax
  800b07:	8d 50 04             	lea    0x4(%eax),%edx
  800b0a:	89 55 14             	mov    %edx,0x14(%ebp)
  800b0d:	8b 00                	mov    (%eax),%eax
  800b0f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b12:	89 c2                	mov    %eax,%edx
  800b14:	c1 fa 1f             	sar    $0x1f,%edx
  800b17:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b1a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800b1d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800b20:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800b25:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b29:	0f 89 a7 00 00 00    	jns    800bd6 <vprintfmt+0x377>
				putch('-', putdat);
  800b2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b33:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800b3a:	ff d7                	call   *%edi
				num = -(long long) num;
  800b3c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800b3f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800b42:	f7 d9                	neg    %ecx
  800b44:	83 d3 00             	adc    $0x0,%ebx
  800b47:	f7 db                	neg    %ebx
  800b49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b4e:	e9 83 00 00 00       	jmp    800bd6 <vprintfmt+0x377>
  800b53:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800b56:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b59:	89 ca                	mov    %ecx,%edx
  800b5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b5e:	e8 a5 fc ff ff       	call   800808 <getuint>
  800b63:	89 c1                	mov    %eax,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800b6c:	eb 68                	jmp    800bd6 <vprintfmt+0x377>
  800b6e:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800b71:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b74:	89 ca                	mov    %ecx,%edx
  800b76:	8d 45 14             	lea    0x14(%ebp),%eax
  800b79:	e8 8a fc ff ff       	call   800808 <getuint>
  800b7e:	89 c1                	mov    %eax,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
  800b87:	eb 4d                	jmp    800bd6 <vprintfmt+0x377>
  800b89:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800b8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b90:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b97:	ff d7                	call   *%edi
			putch('x', putdat);
  800b99:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b9d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ba4:	ff d7                	call   *%edi
			num = (unsigned long long)
  800ba6:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba9:	8d 50 04             	lea    0x4(%eax),%edx
  800bac:	89 55 14             	mov    %edx,0x14(%ebp)
  800baf:	8b 08                	mov    (%eax),%ecx
  800bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bb6:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bbb:	eb 19                	jmp    800bd6 <vprintfmt+0x377>
  800bbd:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800bc0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bc3:	89 ca                	mov    %ecx,%edx
  800bc5:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc8:	e8 3b fc ff ff       	call   800808 <getuint>
  800bcd:	89 c1                	mov    %eax,%ecx
  800bcf:	89 d3                	mov    %edx,%ebx
  800bd1:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bd6:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
  800bda:	89 54 24 10          	mov    %edx,0x10(%esp)
  800bde:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800be1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800be5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be9:	89 0c 24             	mov    %ecx,(%esp)
  800bec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bf0:	89 f2                	mov    %esi,%edx
  800bf2:	89 f8                	mov    %edi,%eax
  800bf4:	e8 27 fb ff ff       	call   800720 <printnum>
  800bf9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800bfc:	e9 8a fc ff ff       	jmp    80088b <vprintfmt+0x2c>
  800c01:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c04:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c08:	89 04 24             	mov    %eax,(%esp)
  800c0b:	ff d7                	call   *%edi
  800c0d:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800c10:	e9 76 fc ff ff       	jmp    80088b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c15:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c19:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800c20:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c22:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800c25:	80 38 25             	cmpb   $0x25,(%eax)
  800c28:	0f 84 5d fc ff ff    	je     80088b <vprintfmt+0x2c>
  800c2e:	89 c3                	mov    %eax,%ebx
  800c30:	eb f0                	jmp    800c22 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
  800c32:	83 c4 4c             	add    $0x4c,%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 28             	sub    $0x28,%esp
  800c40:	8b 45 08             	mov    0x8(%ebp),%eax
  800c43:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800c46:	85 c0                	test   %eax,%eax
  800c48:	74 04                	je     800c4e <vsnprintf+0x14>
  800c4a:	85 d2                	test   %edx,%edx
  800c4c:	7f 07                	jg     800c55 <vsnprintf+0x1b>
  800c4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c53:	eb 3b                	jmp    800c90 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c55:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c58:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800c5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800c5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c66:	8b 45 14             	mov    0x14(%ebp),%eax
  800c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c74:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c7b:	c7 04 24 42 08 80 00 	movl   $0x800842,(%esp)
  800c82:	e8 d8 fb ff ff       	call   80085f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c87:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c8a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c90:	c9                   	leave  
  800c91:	c3                   	ret    

00800c92 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800c98:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800c9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cad:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb0:	89 04 24             	mov    %eax,(%esp)
  800cb3:	e8 82 ff ff ff       	call   800c3a <vsnprintf>
	va_end(ap);

	return rc;
}
  800cb8:	c9                   	leave  
  800cb9:	c3                   	ret    

00800cba <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800cc0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800cc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	89 04 24             	mov    %eax,(%esp)
  800cdb:	e8 7f fb ff ff       	call   80085f <vprintfmt>
	va_end(ap);
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    
	...

00800cf0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
  800cfb:	eb 03                	jmp    800d00 <strlen+0x10>
		n++;
  800cfd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d00:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d04:	75 f7                	jne    800cfd <strlen+0xd>
		n++;
	return n;
}
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	53                   	push   %ebx
  800d0c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d17:	eb 03                	jmp    800d1c <strnlen+0x14>
		n++;
  800d19:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d1c:	39 c1                	cmp    %eax,%ecx
  800d1e:	74 06                	je     800d26 <strnlen+0x1e>
  800d20:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800d24:	75 f3                	jne    800d19 <strnlen+0x11>
		n++;
	return n;
}
  800d26:	5b                   	pop    %ebx
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	53                   	push   %ebx
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d38:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800d3c:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800d3f:	83 c2 01             	add    $0x1,%edx
  800d42:	84 c9                	test   %cl,%cl
  800d44:	75 f2                	jne    800d38 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800d46:	5b                   	pop    %ebx
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	53                   	push   %ebx
  800d4d:	83 ec 08             	sub    $0x8,%esp
  800d50:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d53:	89 1c 24             	mov    %ebx,(%esp)
  800d56:	e8 95 ff ff ff       	call   800cf0 <strlen>
	strcpy(dst + len, src);
  800d5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d62:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800d65:	89 04 24             	mov    %eax,(%esp)
  800d68:	e8 bc ff ff ff       	call   800d29 <strcpy>
	return dst;
}
  800d6d:	89 d8                	mov    %ebx,%eax
  800d6f:	83 c4 08             	add    $0x8,%esp
  800d72:	5b                   	pop    %ebx
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 75 10             	mov    0x10(%ebp),%esi
  800d83:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d88:	eb 0f                	jmp    800d99 <strncpy+0x24>
		*dst++ = *src;
  800d8a:	0f b6 19             	movzbl (%ecx),%ebx
  800d8d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d90:	80 39 01             	cmpb   $0x1,(%ecx)
  800d93:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d96:	83 c2 01             	add    $0x1,%edx
  800d99:	39 f2                	cmp    %esi,%edx
  800d9b:	72 ed                	jb     800d8a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d9d:	5b                   	pop    %ebx
  800d9e:	5e                   	pop    %esi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	8b 75 08             	mov    0x8(%ebp),%esi
  800da9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dac:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800daf:	89 f0                	mov    %esi,%eax
  800db1:	85 d2                	test   %edx,%edx
  800db3:	75 0a                	jne    800dbf <strlcpy+0x1e>
  800db5:	eb 17                	jmp    800dce <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800db7:	88 18                	mov    %bl,(%eax)
  800db9:	83 c0 01             	add    $0x1,%eax
  800dbc:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800dbf:	83 ea 01             	sub    $0x1,%edx
  800dc2:	74 07                	je     800dcb <strlcpy+0x2a>
  800dc4:	0f b6 19             	movzbl (%ecx),%ebx
  800dc7:	84 db                	test   %bl,%bl
  800dc9:	75 ec                	jne    800db7 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
  800dcb:	c6 00 00             	movb   $0x0,(%eax)
  800dce:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dda:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ddd:	eb 06                	jmp    800de5 <strcmp+0x11>
		p++, q++;
  800ddf:	83 c1 01             	add    $0x1,%ecx
  800de2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800de5:	0f b6 01             	movzbl (%ecx),%eax
  800de8:	84 c0                	test   %al,%al
  800dea:	74 04                	je     800df0 <strcmp+0x1c>
  800dec:	3a 02                	cmp    (%edx),%al
  800dee:	74 ef                	je     800ddf <strcmp+0xb>
  800df0:	0f b6 c0             	movzbl %al,%eax
  800df3:	0f b6 12             	movzbl (%edx),%edx
  800df6:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	53                   	push   %ebx
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e04:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800e07:	eb 09                	jmp    800e12 <strncmp+0x18>
		n--, p++, q++;
  800e09:	83 ea 01             	sub    $0x1,%edx
  800e0c:	83 c0 01             	add    $0x1,%eax
  800e0f:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e12:	85 d2                	test   %edx,%edx
  800e14:	75 07                	jne    800e1d <strncmp+0x23>
  800e16:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1b:	eb 13                	jmp    800e30 <strncmp+0x36>
  800e1d:	0f b6 18             	movzbl (%eax),%ebx
  800e20:	84 db                	test   %bl,%bl
  800e22:	74 04                	je     800e28 <strncmp+0x2e>
  800e24:	3a 19                	cmp    (%ecx),%bl
  800e26:	74 e1                	je     800e09 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e28:	0f b6 00             	movzbl (%eax),%eax
  800e2b:	0f b6 11             	movzbl (%ecx),%edx
  800e2e:	29 d0                	sub    %edx,%eax
}
  800e30:	5b                   	pop    %ebx
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    

00800e33 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e3d:	eb 07                	jmp    800e46 <strchr+0x13>
		if (*s == c)
  800e3f:	38 ca                	cmp    %cl,%dl
  800e41:	74 0f                	je     800e52 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e43:	83 c0 01             	add    $0x1,%eax
  800e46:	0f b6 10             	movzbl (%eax),%edx
  800e49:	84 d2                	test   %dl,%dl
  800e4b:	75 f2                	jne    800e3f <strchr+0xc>
  800e4d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e5e:	eb 07                	jmp    800e67 <strfind+0x13>
		if (*s == c)
  800e60:	38 ca                	cmp    %cl,%dl
  800e62:	74 0a                	je     800e6e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e64:	83 c0 01             	add    $0x1,%eax
  800e67:	0f b6 10             	movzbl (%eax),%edx
  800e6a:	84 d2                	test   %dl,%dl
  800e6c:	75 f2                	jne    800e60 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
  800e6e:	5d                   	pop    %ebp
  800e6f:	90                   	nop
  800e70:	c3                   	ret    

00800e71 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 0c             	sub    $0xc,%esp
  800e77:	89 1c 24             	mov    %ebx,(%esp)
  800e7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e7e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800e82:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e8b:	85 c9                	test   %ecx,%ecx
  800e8d:	74 30                	je     800ebf <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e95:	75 25                	jne    800ebc <memset+0x4b>
  800e97:	f6 c1 03             	test   $0x3,%cl
  800e9a:	75 20                	jne    800ebc <memset+0x4b>
		c &= 0xFF;
  800e9c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e9f:	89 d3                	mov    %edx,%ebx
  800ea1:	c1 e3 08             	shl    $0x8,%ebx
  800ea4:	89 d6                	mov    %edx,%esi
  800ea6:	c1 e6 18             	shl    $0x18,%esi
  800ea9:	89 d0                	mov    %edx,%eax
  800eab:	c1 e0 10             	shl    $0x10,%eax
  800eae:	09 f0                	or     %esi,%eax
  800eb0:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800eb2:	09 d8                	or     %ebx,%eax
  800eb4:	c1 e9 02             	shr    $0x2,%ecx
  800eb7:	fc                   	cld    
  800eb8:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eba:	eb 03                	jmp    800ebf <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ebc:	fc                   	cld    
  800ebd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ebf:	89 f8                	mov    %edi,%eax
  800ec1:	8b 1c 24             	mov    (%esp),%ebx
  800ec4:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ec8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ecc:	89 ec                	mov    %ebp,%esp
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 08             	sub    $0x8,%esp
  800ed6:	89 34 24             	mov    %esi,(%esp)
  800ed9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800ee3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ee6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ee8:	39 c6                	cmp    %eax,%esi
  800eea:	73 35                	jae    800f21 <memmove+0x51>
  800eec:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800eef:	39 d0                	cmp    %edx,%eax
  800ef1:	73 2e                	jae    800f21 <memmove+0x51>
		s += n;
		d += n;
  800ef3:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ef5:	f6 c2 03             	test   $0x3,%dl
  800ef8:	75 1b                	jne    800f15 <memmove+0x45>
  800efa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f00:	75 13                	jne    800f15 <memmove+0x45>
  800f02:	f6 c1 03             	test   $0x3,%cl
  800f05:	75 0e                	jne    800f15 <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800f07:	83 ef 04             	sub    $0x4,%edi
  800f0a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f0d:	c1 e9 02             	shr    $0x2,%ecx
  800f10:	fd                   	std    
  800f11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f13:	eb 09                	jmp    800f1e <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f15:	83 ef 01             	sub    $0x1,%edi
  800f18:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f1b:	fd                   	std    
  800f1c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f1e:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f1f:	eb 20                	jmp    800f41 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f27:	75 15                	jne    800f3e <memmove+0x6e>
  800f29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f2f:	75 0d                	jne    800f3e <memmove+0x6e>
  800f31:	f6 c1 03             	test   $0x3,%cl
  800f34:	75 08                	jne    800f3e <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800f36:	c1 e9 02             	shr    $0x2,%ecx
  800f39:	fc                   	cld    
  800f3a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3c:	eb 03                	jmp    800f41 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f3e:	fc                   	cld    
  800f3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f41:	8b 34 24             	mov    (%esp),%esi
  800f44:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800f48:	89 ec                	mov    %ebp,%esp
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f52:	8b 45 10             	mov    0x10(%ebp),%eax
  800f55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f60:	8b 45 08             	mov    0x8(%ebp),%eax
  800f63:	89 04 24             	mov    %eax,(%esp)
  800f66:	e8 65 ff ff ff       	call   800ed0 <memmove>
}
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	57                   	push   %edi
  800f71:	56                   	push   %esi
  800f72:	53                   	push   %ebx
  800f73:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f79:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f7c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f81:	eb 1c                	jmp    800f9f <memcmp+0x32>
		if (*s1 != *s2)
  800f83:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
  800f87:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
  800f8b:	83 c2 01             	add    $0x1,%edx
  800f8e:	83 e9 01             	sub    $0x1,%ecx
  800f91:	38 d8                	cmp    %bl,%al
  800f93:	74 0a                	je     800f9f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
  800f95:	0f b6 c0             	movzbl %al,%eax
  800f98:	0f b6 db             	movzbl %bl,%ebx
  800f9b:	29 d8                	sub    %ebx,%eax
  800f9d:	eb 09                	jmp    800fa8 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f9f:	85 c9                	test   %ecx,%ecx
  800fa1:	75 e0                	jne    800f83 <memcmp+0x16>
  800fa3:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800fa8:	5b                   	pop    %ebx
  800fa9:	5e                   	pop    %esi
  800faa:	5f                   	pop    %edi
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fb6:	89 c2                	mov    %eax,%edx
  800fb8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fbb:	eb 07                	jmp    800fc4 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fbd:	38 08                	cmp    %cl,(%eax)
  800fbf:	74 07                	je     800fc8 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fc1:	83 c0 01             	add    $0x1,%eax
  800fc4:	39 d0                	cmp    %edx,%eax
  800fc6:	72 f5                	jb     800fbd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
  800fd0:	83 ec 04             	sub    $0x4,%esp
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fd9:	eb 03                	jmp    800fde <strtol+0x14>
		s++;
  800fdb:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fde:	0f b6 02             	movzbl (%edx),%eax
  800fe1:	3c 20                	cmp    $0x20,%al
  800fe3:	74 f6                	je     800fdb <strtol+0x11>
  800fe5:	3c 09                	cmp    $0x9,%al
  800fe7:	74 f2                	je     800fdb <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fe9:	3c 2b                	cmp    $0x2b,%al
  800feb:	75 0c                	jne    800ff9 <strtol+0x2f>
		s++;
  800fed:	8d 52 01             	lea    0x1(%edx),%edx
  800ff0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ff7:	eb 15                	jmp    80100e <strtol+0x44>
	else if (*s == '-')
  800ff9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801000:	3c 2d                	cmp    $0x2d,%al
  801002:	75 0a                	jne    80100e <strtol+0x44>
		s++, neg = 1;
  801004:	8d 52 01             	lea    0x1(%edx),%edx
  801007:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80100e:	85 db                	test   %ebx,%ebx
  801010:	0f 94 c0             	sete   %al
  801013:	74 05                	je     80101a <strtol+0x50>
  801015:	83 fb 10             	cmp    $0x10,%ebx
  801018:	75 18                	jne    801032 <strtol+0x68>
  80101a:	80 3a 30             	cmpb   $0x30,(%edx)
  80101d:	75 13                	jne    801032 <strtol+0x68>
  80101f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801023:	75 0d                	jne    801032 <strtol+0x68>
		s += 2, base = 16;
  801025:	83 c2 02             	add    $0x2,%edx
  801028:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	eb 13                	jmp    801045 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801032:	84 c0                	test   %al,%al
  801034:	74 0f                	je     801045 <strtol+0x7b>
  801036:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80103b:	80 3a 30             	cmpb   $0x30,(%edx)
  80103e:	75 05                	jne    801045 <strtol+0x7b>
		s++, base = 8;
  801040:	83 c2 01             	add    $0x1,%edx
  801043:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801045:	b8 00 00 00 00       	mov    $0x0,%eax
  80104a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80104c:	0f b6 0a             	movzbl (%edx),%ecx
  80104f:	89 cf                	mov    %ecx,%edi
  801051:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801054:	80 fb 09             	cmp    $0x9,%bl
  801057:	77 08                	ja     801061 <strtol+0x97>
			dig = *s - '0';
  801059:	0f be c9             	movsbl %cl,%ecx
  80105c:	83 e9 30             	sub    $0x30,%ecx
  80105f:	eb 1e                	jmp    80107f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  801061:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801064:	80 fb 19             	cmp    $0x19,%bl
  801067:	77 08                	ja     801071 <strtol+0xa7>
			dig = *s - 'a' + 10;
  801069:	0f be c9             	movsbl %cl,%ecx
  80106c:	83 e9 57             	sub    $0x57,%ecx
  80106f:	eb 0e                	jmp    80107f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  801071:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801074:	80 fb 19             	cmp    $0x19,%bl
  801077:	77 15                	ja     80108e <strtol+0xc4>
			dig = *s - 'A' + 10;
  801079:	0f be c9             	movsbl %cl,%ecx
  80107c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80107f:	39 f1                	cmp    %esi,%ecx
  801081:	7d 0b                	jge    80108e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
  801083:	83 c2 01             	add    $0x1,%edx
  801086:	0f af c6             	imul   %esi,%eax
  801089:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  80108c:	eb be                	jmp    80104c <strtol+0x82>
  80108e:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801090:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801094:	74 05                	je     80109b <strtol+0xd1>
		*endptr = (char *) s;
  801096:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801099:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80109b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80109f:	74 04                	je     8010a5 <strtol+0xdb>
  8010a1:	89 c8                	mov    %ecx,%eax
  8010a3:	f7 d8                	neg    %eax
}
  8010a5:	83 c4 04             	add    $0x4,%esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5e                   	pop    %esi
  8010aa:	5f                   	pop    %edi
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    
  8010ad:	00 00                	add    %al,(%eax)
	...

008010b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	89 1c 24             	mov    %ebx,(%esp)
  8010b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010bd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cc:	89 c3                	mov    %eax,%ebx
  8010ce:	89 c7                	mov    %eax,%edi
  8010d0:	89 c6                	mov    %eax,%esi
  8010d2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010d4:	8b 1c 24             	mov    (%esp),%ebx
  8010d7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010db:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8010df:	89 ec                	mov    %ebp,%esp
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	83 ec 38             	sub    $0x38,%esp
  8010e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
	if (upcall==NULL) {
  8010f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010f6:	75 0c                	jne    801104 <sys_env_set_pgfault_upcall+0x21>
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
  8010f8:	c7 04 24 08 1b 80 00 	movl   $0x801b08,(%esp)
  8010ff:	e8 bd f5 ff ff       	call   8006c1 <cprintf>
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801104:	bb 00 00 00 00       	mov    $0x0,%ebx
  801109:	b8 09 00 00 00       	mov    $0x9,%eax
  80110e:	8b 55 08             	mov    0x8(%ebp),%edx
  801111:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801114:	89 df                	mov    %ebx,%edi
  801116:	89 de                	mov    %ebx,%esi
  801118:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80111a:	85 c0                	test   %eax,%eax
  80111c:	7e 28                	jle    801146 <sys_env_set_pgfault_upcall+0x63>
		panic("syscall %d returned %d (> 0)", num, ret);
  80111e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801122:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801129:	00 
  80112a:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  801131:	00 
  801132:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801139:	00 
  80113a:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  801141:	e8 c2 f4 ff ff       	call   800608 <_panic>
{
	if (upcall==NULL) {
		cprintf("lib sys_env_set_pgfault_up: upcall is NULL\n");
	}
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801146:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801149:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80114c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80114f:	89 ec                	mov    %ebp,%esp
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    

00801153 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801153:	55                   	push   %ebp
  801154:	89 e5                	mov    %esp,%ebp
  801156:	83 ec 38             	sub    $0x38,%esp
  801159:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80115c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80115f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801162:	b9 00 00 00 00       	mov    $0x0,%ecx
  801167:	b8 0c 00 00 00       	mov    $0xc,%eax
  80116c:	8b 55 08             	mov    0x8(%ebp),%edx
  80116f:	89 cb                	mov    %ecx,%ebx
  801171:	89 cf                	mov    %ecx,%edi
  801173:	89 ce                	mov    %ecx,%esi
  801175:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801177:	85 c0                	test   %eax,%eax
  801179:	7e 28                	jle    8011a3 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80117f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801186:	00 
  801187:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  80118e:	00 
  80118f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801196:	00 
  801197:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  80119e:	e8 65 f4 ff ff       	call   800608 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8011a3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011a6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011a9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011ac:	89 ec                	mov    %ebp,%esp
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 0c             	sub    $0xc,%esp
  8011b6:	89 1c 24             	mov    %ebx,(%esp)
  8011b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011bd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c1:	be 00 00 00 00       	mov    $0x0,%esi
  8011c6:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011cb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011d9:	8b 1c 24             	mov    (%esp),%ebx
  8011dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011e0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011e4:	89 ec                	mov    %ebp,%esp
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 38             	sub    $0x38,%esp
  8011ee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011f1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011f4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801201:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801204:	8b 55 08             	mov    0x8(%ebp),%edx
  801207:	89 df                	mov    %ebx,%edi
  801209:	89 de                	mov    %ebx,%esi
  80120b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80120d:	85 c0                	test   %eax,%eax
  80120f:	7e 28                	jle    801239 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801211:	89 44 24 10          	mov    %eax,0x10(%esp)
  801215:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80121c:	00 
  80121d:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  801224:	00 
  801225:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80122c:	00 
  80122d:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  801234:	e8 cf f3 ff ff       	call   800608 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801239:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80123c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80123f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801242:	89 ec                	mov    %ebp,%esp
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 38             	sub    $0x38,%esp
  80124c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80124f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801252:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80125a:	b8 06 00 00 00       	mov    $0x6,%eax
  80125f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801262:	8b 55 08             	mov    0x8(%ebp),%edx
  801265:	89 df                	mov    %ebx,%edi
  801267:	89 de                	mov    %ebx,%esi
  801269:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80126b:	85 c0                	test   %eax,%eax
  80126d:	7e 28                	jle    801297 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80126f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801273:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80127a:	00 
  80127b:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  801282:	00 
  801283:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80128a:	00 
  80128b:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  801292:	e8 71 f3 ff ff       	call   800608 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801297:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80129a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80129d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012a0:	89 ec                	mov    %ebp,%esp
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    

008012a4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	83 ec 38             	sub    $0x38,%esp
  8012aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b3:	b8 05 00 00 00       	mov    $0x5,%eax
  8012b8:	8b 75 18             	mov    0x18(%ebp),%esi
  8012bb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	7e 28                	jle    8012f5 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d1:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012d8:	00 
  8012d9:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  8012e0:	00 
  8012e1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012e8:	00 
  8012e9:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  8012f0:	e8 13 f3 ff ff       	call   800608 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8012f5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012f8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012fb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8012fe:	89 ec                	mov    %ebp,%esp
  801300:	5d                   	pop    %ebp
  801301:	c3                   	ret    

00801302 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	83 ec 38             	sub    $0x38,%esp
  801308:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80130b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80130e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801311:	be 00 00 00 00       	mov    $0x0,%esi
  801316:	b8 04 00 00 00       	mov    $0x4,%eax
  80131b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80131e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801321:	8b 55 08             	mov    0x8(%ebp),%edx
  801324:	89 f7                	mov    %esi,%edi
  801326:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801328:	85 c0                	test   %eax,%eax
  80132a:	7e 28                	jle    801354 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  80132c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801330:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801337:	00 
  801338:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  80133f:	00 
  801340:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801347:	00 
  801348:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  80134f:	e8 b4 f2 ff ff       	call   800608 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801354:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801357:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80135a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80135d:	89 ec                	mov    %ebp,%esp
  80135f:	5d                   	pop    %ebp
  801360:	c3                   	ret    

00801361 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
  801364:	83 ec 0c             	sub    $0xc,%esp
  801367:	89 1c 24             	mov    %ebx,(%esp)
  80136a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80136e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801372:	ba 00 00 00 00       	mov    $0x0,%edx
  801377:	b8 0a 00 00 00       	mov    $0xa,%eax
  80137c:	89 d1                	mov    %edx,%ecx
  80137e:	89 d3                	mov    %edx,%ebx
  801380:	89 d7                	mov    %edx,%edi
  801382:	89 d6                	mov    %edx,%esi
  801384:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801386:	8b 1c 24             	mov    (%esp),%ebx
  801389:	8b 74 24 04          	mov    0x4(%esp),%esi
  80138d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801391:	89 ec                	mov    %ebp,%esp
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	83 ec 0c             	sub    $0xc,%esp
  80139b:	89 1c 24             	mov    %ebx,(%esp)
  80139e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013a2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ab:	b8 02 00 00 00       	mov    $0x2,%eax
  8013b0:	89 d1                	mov    %edx,%ecx
  8013b2:	89 d3                	mov    %edx,%ebx
  8013b4:	89 d7                	mov    %edx,%edi
  8013b6:	89 d6                	mov    %edx,%esi
  8013b8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8013ba:	8b 1c 24             	mov    (%esp),%ebx
  8013bd:	8b 74 24 04          	mov    0x4(%esp),%esi
  8013c1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013c5:	89 ec                	mov    %ebp,%esp
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    

008013c9 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	83 ec 38             	sub    $0x38,%esp
  8013cf:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013d2:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013d5:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013dd:	b8 03 00 00 00       	mov    $0x3,%eax
  8013e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e5:	89 cb                	mov    %ecx,%ebx
  8013e7:	89 cf                	mov    %ecx,%edi
  8013e9:	89 ce                	mov    %ecx,%esi
  8013eb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	7e 28                	jle    801419 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f5:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8013fc:	00 
  8013fd:	c7 44 24 08 34 1b 80 	movl   $0x801b34,0x8(%esp)
  801404:	00 
  801405:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80140c:	00 
  80140d:	c7 04 24 51 1b 80 00 	movl   $0x801b51,(%esp)
  801414:	e8 ef f1 ff ff       	call   800608 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801419:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80141c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80141f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801422:	89 ec                	mov    %ebp,%esp
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    

00801426 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 0c             	sub    $0xc,%esp
  80142c:	89 1c 24             	mov    %ebx,(%esp)
  80142f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801433:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801437:	ba 00 00 00 00       	mov    $0x0,%edx
  80143c:	b8 01 00 00 00       	mov    $0x1,%eax
  801441:	89 d1                	mov    %edx,%ecx
  801443:	89 d3                	mov    %edx,%ebx
  801445:	89 d7                	mov    %edx,%edi
  801447:	89 d6                	mov    %edx,%esi
  801449:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80144b:	8b 1c 24             	mov    (%esp),%ebx
  80144e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801452:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801456:	89 ec                	mov    %ebp,%esp
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    
	...

0080145c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801462:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801469:	75 58                	jne    8014c3 <set_pgfault_handler+0x67>
		// First time through!
		// LAB 4: Your code here.
		PGFAULTDEBUG("set_pgfault_handler: first time through\n");
		void *va=(void*)(UXSTACKTOP-PGSIZE);

		if ( sys_page_alloc(thisenv->env_id,va,PTE_P | PTE_U | PTE_W) ) {
  80146b:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  801470:	8b 40 48             	mov    0x48(%eax),%eax
  801473:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80147a:	00 
  80147b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801482:	ee 
  801483:	89 04 24             	mov    %eax,(%esp)
  801486:	e8 77 fe ff ff       	call   801302 <sys_page_alloc>
  80148b:	85 c0                	test   %eax,%eax
  80148d:	74 1c                	je     8014ab <set_pgfault_handler+0x4f>
			panic("set_pgfault_handler: sys_page_alloc fail\n");
  80148f:	c7 44 24 08 60 1b 80 	movl   $0x801b60,0x8(%esp)
  801496:	00 
  801497:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  80149e:	00 
  80149f:	c7 04 24 8c 1b 80 00 	movl   $0x801b8c,(%esp)
  8014a6:	e8 5d f1 ff ff       	call   800608 <_panic>
		}
		sys_env_set_pgfault_upcall(thisenv->env_id,_pgfault_upcall);
  8014ab:	a1 cc 20 80 00       	mov    0x8020cc,%eax
  8014b0:	8b 40 48             	mov    0x48(%eax),%eax
  8014b3:	c7 44 24 04 d0 14 80 	movl   $0x8014d0,0x4(%esp)
  8014ba:	00 
  8014bb:	89 04 24             	mov    %eax,(%esp)
  8014be:	e8 20 fc ff ff       	call   8010e3 <sys_env_set_pgfault_upcall>
	}

	PGFAULTDEBUG("set_pgfault_handler: handler's address %d\n",handler);

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c6:	a3 d0 20 80 00       	mov    %eax,0x8020d0
	PGFAULTDEBUG("set_pgfault_handler: finish set\n");
}
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    
  8014cd:	00 00                	add    %al,(%eax)
	...

008014d0 <_pgfault_upcall>:
  8014d0:	54                   	push   %esp
  8014d1:	a1 d0 20 80 00       	mov    0x8020d0,%eax
  8014d6:	ff d0                	call   *%eax
  8014d8:	83 c4 04             	add    $0x4,%esp
  8014db:	89 e3                	mov    %esp,%ebx
  8014dd:	8b 44 24 28          	mov    0x28(%esp),%eax
  8014e1:	8b 64 24 30          	mov    0x30(%esp),%esp
  8014e5:	50                   	push   %eax
  8014e6:	89 dc                	mov    %ebx,%esp
  8014e8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
  8014ed:	58                   	pop    %eax
  8014ee:	58                   	pop    %eax
  8014ef:	61                   	popa   
  8014f0:	83 c4 04             	add    $0x4,%esp
  8014f3:	9d                   	popf   
  8014f4:	5c                   	pop    %esp
  8014f5:	c3                   	ret    
	...

00801500 <__udivdi3>:
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	57                   	push   %edi
  801504:	56                   	push   %esi
  801505:	83 ec 10             	sub    $0x10,%esp
  801508:	8b 45 14             	mov    0x14(%ebp),%eax
  80150b:	8b 55 08             	mov    0x8(%ebp),%edx
  80150e:	8b 75 10             	mov    0x10(%ebp),%esi
  801511:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801514:	85 c0                	test   %eax,%eax
  801516:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801519:	75 35                	jne    801550 <__udivdi3+0x50>
  80151b:	39 fe                	cmp    %edi,%esi
  80151d:	77 61                	ja     801580 <__udivdi3+0x80>
  80151f:	85 f6                	test   %esi,%esi
  801521:	75 0b                	jne    80152e <__udivdi3+0x2e>
  801523:	b8 01 00 00 00       	mov    $0x1,%eax
  801528:	31 d2                	xor    %edx,%edx
  80152a:	f7 f6                	div    %esi
  80152c:	89 c6                	mov    %eax,%esi
  80152e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801531:	31 d2                	xor    %edx,%edx
  801533:	89 f8                	mov    %edi,%eax
  801535:	f7 f6                	div    %esi
  801537:	89 c7                	mov    %eax,%edi
  801539:	89 c8                	mov    %ecx,%eax
  80153b:	f7 f6                	div    %esi
  80153d:	89 c1                	mov    %eax,%ecx
  80153f:	89 fa                	mov    %edi,%edx
  801541:	89 c8                	mov    %ecx,%eax
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	5e                   	pop    %esi
  801547:	5f                   	pop    %edi
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    
  80154a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801550:	39 f8                	cmp    %edi,%eax
  801552:	77 1c                	ja     801570 <__udivdi3+0x70>
  801554:	0f bd d0             	bsr    %eax,%edx
  801557:	83 f2 1f             	xor    $0x1f,%edx
  80155a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80155d:	75 39                	jne    801598 <__udivdi3+0x98>
  80155f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801562:	0f 86 a0 00 00 00    	jbe    801608 <__udivdi3+0x108>
  801568:	39 f8                	cmp    %edi,%eax
  80156a:	0f 82 98 00 00 00    	jb     801608 <__udivdi3+0x108>
  801570:	31 ff                	xor    %edi,%edi
  801572:	31 c9                	xor    %ecx,%ecx
  801574:	89 c8                	mov    %ecx,%eax
  801576:	89 fa                	mov    %edi,%edx
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	5e                   	pop    %esi
  80157c:	5f                   	pop    %edi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    
  80157f:	90                   	nop
  801580:	89 d1                	mov    %edx,%ecx
  801582:	89 fa                	mov    %edi,%edx
  801584:	89 c8                	mov    %ecx,%eax
  801586:	31 ff                	xor    %edi,%edi
  801588:	f7 f6                	div    %esi
  80158a:	89 c1                	mov    %eax,%ecx
  80158c:	89 fa                	mov    %edi,%edx
  80158e:	89 c8                	mov    %ecx,%eax
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	5e                   	pop    %esi
  801594:	5f                   	pop    %edi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    
  801597:	90                   	nop
  801598:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80159c:	89 f2                	mov    %esi,%edx
  80159e:	d3 e0                	shl    %cl,%eax
  8015a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8015a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8015ab:	89 c1                	mov    %eax,%ecx
  8015ad:	d3 ea                	shr    %cl,%edx
  8015af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8015b6:	d3 e6                	shl    %cl,%esi
  8015b8:	89 c1                	mov    %eax,%ecx
  8015ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8015bd:	89 fe                	mov    %edi,%esi
  8015bf:	d3 ee                	shr    %cl,%esi
  8015c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015cb:	d3 e7                	shl    %cl,%edi
  8015cd:	89 c1                	mov    %eax,%ecx
  8015cf:	d3 ea                	shr    %cl,%edx
  8015d1:	09 d7                	or     %edx,%edi
  8015d3:	89 f2                	mov    %esi,%edx
  8015d5:	89 f8                	mov    %edi,%eax
  8015d7:	f7 75 ec             	divl   -0x14(%ebp)
  8015da:	89 d6                	mov    %edx,%esi
  8015dc:	89 c7                	mov    %eax,%edi
  8015de:	f7 65 e8             	mull   -0x18(%ebp)
  8015e1:	39 d6                	cmp    %edx,%esi
  8015e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8015e6:	72 30                	jb     801618 <__udivdi3+0x118>
  8015e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8015ef:	d3 e2                	shl    %cl,%edx
  8015f1:	39 c2                	cmp    %eax,%edx
  8015f3:	73 05                	jae    8015fa <__udivdi3+0xfa>
  8015f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8015f8:	74 1e                	je     801618 <__udivdi3+0x118>
  8015fa:	89 f9                	mov    %edi,%ecx
  8015fc:	31 ff                	xor    %edi,%edi
  8015fe:	e9 71 ff ff ff       	jmp    801574 <__udivdi3+0x74>
  801603:	90                   	nop
  801604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801608:	31 ff                	xor    %edi,%edi
  80160a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80160f:	e9 60 ff ff ff       	jmp    801574 <__udivdi3+0x74>
  801614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801618:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80161b:	31 ff                	xor    %edi,%edi
  80161d:	89 c8                	mov    %ecx,%eax
  80161f:	89 fa                	mov    %edi,%edx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	5e                   	pop    %esi
  801625:	5f                   	pop    %edi
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    
	...

00801630 <__umoddi3>:
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	57                   	push   %edi
  801634:	56                   	push   %esi
  801635:	83 ec 20             	sub    $0x20,%esp
  801638:	8b 55 14             	mov    0x14(%ebp),%edx
  80163b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80163e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801641:	8b 75 0c             	mov    0xc(%ebp),%esi
  801644:	85 d2                	test   %edx,%edx
  801646:	89 c8                	mov    %ecx,%eax
  801648:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80164b:	75 13                	jne    801660 <__umoddi3+0x30>
  80164d:	39 f7                	cmp    %esi,%edi
  80164f:	76 3f                	jbe    801690 <__umoddi3+0x60>
  801651:	89 f2                	mov    %esi,%edx
  801653:	f7 f7                	div    %edi
  801655:	89 d0                	mov    %edx,%eax
  801657:	31 d2                	xor    %edx,%edx
  801659:	83 c4 20             	add    $0x20,%esp
  80165c:	5e                   	pop    %esi
  80165d:	5f                   	pop    %edi
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    
  801660:	39 f2                	cmp    %esi,%edx
  801662:	77 4c                	ja     8016b0 <__umoddi3+0x80>
  801664:	0f bd ca             	bsr    %edx,%ecx
  801667:	83 f1 1f             	xor    $0x1f,%ecx
  80166a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80166d:	75 51                	jne    8016c0 <__umoddi3+0x90>
  80166f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801672:	0f 87 e0 00 00 00    	ja     801758 <__umoddi3+0x128>
  801678:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167b:	29 f8                	sub    %edi,%eax
  80167d:	19 d6                	sbb    %edx,%esi
  80167f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801685:	89 f2                	mov    %esi,%edx
  801687:	83 c4 20             	add    $0x20,%esp
  80168a:	5e                   	pop    %esi
  80168b:	5f                   	pop    %edi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    
  80168e:	66 90                	xchg   %ax,%ax
  801690:	85 ff                	test   %edi,%edi
  801692:	75 0b                	jne    80169f <__umoddi3+0x6f>
  801694:	b8 01 00 00 00       	mov    $0x1,%eax
  801699:	31 d2                	xor    %edx,%edx
  80169b:	f7 f7                	div    %edi
  80169d:	89 c7                	mov    %eax,%edi
  80169f:	89 f0                	mov    %esi,%eax
  8016a1:	31 d2                	xor    %edx,%edx
  8016a3:	f7 f7                	div    %edi
  8016a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a8:	f7 f7                	div    %edi
  8016aa:	eb a9                	jmp    801655 <__umoddi3+0x25>
  8016ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016b0:	89 c8                	mov    %ecx,%eax
  8016b2:	89 f2                	mov    %esi,%edx
  8016b4:	83 c4 20             	add    $0x20,%esp
  8016b7:	5e                   	pop    %esi
  8016b8:	5f                   	pop    %edi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    
  8016bb:	90                   	nop
  8016bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016c4:	d3 e2                	shl    %cl,%edx
  8016c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8016c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8016ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8016d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8016d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016d8:	89 fa                	mov    %edi,%edx
  8016da:	d3 ea                	shr    %cl,%edx
  8016dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8016e3:	d3 e7                	shl    %cl,%edi
  8016e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8016e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8016ec:	89 f2                	mov    %esi,%edx
  8016ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8016f1:	89 c7                	mov    %eax,%edi
  8016f3:	d3 ea                	shr    %cl,%edx
  8016f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8016f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	d3 e6                	shl    %cl,%esi
  801700:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801704:	d3 ea                	shr    %cl,%edx
  801706:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80170a:	09 d6                	or     %edx,%esi
  80170c:	89 f0                	mov    %esi,%eax
  80170e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801711:	d3 e7                	shl    %cl,%edi
  801713:	89 f2                	mov    %esi,%edx
  801715:	f7 75 f4             	divl   -0xc(%ebp)
  801718:	89 d6                	mov    %edx,%esi
  80171a:	f7 65 e8             	mull   -0x18(%ebp)
  80171d:	39 d6                	cmp    %edx,%esi
  80171f:	72 2b                	jb     80174c <__umoddi3+0x11c>
  801721:	39 c7                	cmp    %eax,%edi
  801723:	72 23                	jb     801748 <__umoddi3+0x118>
  801725:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801729:	29 c7                	sub    %eax,%edi
  80172b:	19 d6                	sbb    %edx,%esi
  80172d:	89 f0                	mov    %esi,%eax
  80172f:	89 f2                	mov    %esi,%edx
  801731:	d3 ef                	shr    %cl,%edi
  801733:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801737:	d3 e0                	shl    %cl,%eax
  801739:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80173d:	09 f8                	or     %edi,%eax
  80173f:	d3 ea                	shr    %cl,%edx
  801741:	83 c4 20             	add    $0x20,%esp
  801744:	5e                   	pop    %esi
  801745:	5f                   	pop    %edi
  801746:	5d                   	pop    %ebp
  801747:	c3                   	ret    
  801748:	39 d6                	cmp    %edx,%esi
  80174a:	75 d9                	jne    801725 <__umoddi3+0xf5>
  80174c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80174f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801752:	eb d1                	jmp    801725 <__umoddi3+0xf5>
  801754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801758:	39 f2                	cmp    %esi,%edx
  80175a:	0f 82 18 ff ff ff    	jb     801678 <__umoddi3+0x48>
  801760:	e9 1d ff ff ff       	jmp    801682 <__umoddi3+0x52>
