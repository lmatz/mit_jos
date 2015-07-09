
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 39 01 00 00       	call   f0100177 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 a0 6c 10 f0 	movl   $0xf0106ca0,(%esp)
f010005f:	e8 bb 41 00 00       	call   f010421f <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 79 41 00 00       	call   f01041ec <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 ff 7e 10 f0 	movl   $0xf0107eff,(%esp)
f010007a:	e8 a0 41 00 00       	call   f010421f <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d 80 2e 23 f0 00 	cmpl   $0x0,0xf0232e80
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 80 2e 23 f0    	mov    %esi,0xf0232e80

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000a4:	e8 05 65 00 00       	call   f01065ae <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 f8 6c 10 f0 	movl   $0xf0106cf8,(%esp)
f01000c2:	e8 58 41 00 00       	call   f010421f <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 19 41 00 00       	call   f01041ec <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 ff 7e 10 f0 	movl   $0xf0107eff,(%esp)
f01000da:	e8 40 41 00 00       	call   f010421f <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e6:	e8 e8 07 00 00       	call   f01008d3 <monitor>
f01000eb:	eb f2                	jmp    f01000df <_panic+0x5a>

f01000ed <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000ed:	55                   	push   %ebp
f01000ee:	89 e5                	mov    %esp,%ebp
f01000f0:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000f3:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000f8:	89 c2                	mov    %eax,%edx
f01000fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000ff:	77 20                	ja     f0100121 <mp_main+0x34>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100101:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100105:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f010010c:	f0 
f010010d:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0100114:	00 
f0100115:	c7 04 24 ba 6c 10 f0 	movl   $0xf0106cba,(%esp)
f010011c:	e8 64 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100121:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100127:	0f 22 da             	mov    %edx,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010012a:	e8 7f 64 00 00       	call   f01065ae <cpunum>
f010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100133:	c7 04 24 c6 6c 10 f0 	movl   $0xf0106cc6,(%esp)
f010013a:	e8 e0 40 00 00       	call   f010421f <cprintf>

	lapic_init();
f010013f:	e8 a3 65 00 00       	call   f01066e7 <lapic_init>
	env_init_percpu();
f0100144:	e8 77 36 00 00       	call   f01037c0 <env_init_percpu>
	trap_init_percpu();
f0100149:	e8 02 41 00 00       	call   f0104250 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014e:	66 90                	xchg   %ax,%ax
f0100150:	e8 59 64 00 00       	call   f01065ae <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 30 23 f0    	add    $0xf0233024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010015e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100163:	f0 87 02             	lock xchg %eax,(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100166:	c7 04 24 20 14 12 f0 	movl   $0xf0121420,(%esp)
f010016d:	e8 0b 68 00 00       	call   f010697d <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100172:	e8 43 4b 00 00       	call   f0104cba <sched_yield>

f0100177 <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp
f010017a:	57                   	push   %edi
f010017b:	56                   	push   %esi
f010017c:	53                   	push   %ebx
f010017d:	83 ec 1c             	sub    $0x1c,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100180:	b8 08 40 27 f0       	mov    $0xf0274008,%eax
f0100185:	2d 78 1b 23 f0       	sub    $0xf0231b78,%eax
f010018a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010018e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100195:	00 
f0100196:	c7 04 24 78 1b 23 f0 	movl   $0xf0231b78,(%esp)
f010019d:	e8 8f 5d 00 00       	call   f0105f31 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001a2:	e8 16 05 00 00       	call   f01006bd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01001a7:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001ae:	00 
f01001af:	c7 04 24 dc 6c 10 f0 	movl   $0xf0106cdc,(%esp)
f01001b6:	e8 64 40 00 00       	call   f010421f <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01001bb:	e8 10 19 00 00       	call   f0101ad0 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01001c0:	e8 25 36 00 00       	call   f01037ea <env_init>
	trap_init();
f01001c5:	e8 22 41 00 00       	call   f01042ec <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001ca:	e8 f7 60 00 00       	call   f01062c6 <mp_init>
	lapic_init();
f01001cf:	90                   	nop
f01001d0:	e8 12 65 00 00       	call   f01066e7 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001d5:	e8 87 3f 00 00       	call   f0104161 <pic_init>
f01001da:	c7 04 24 20 14 12 f0 	movl   $0xf0121420,(%esp)
f01001e1:	e8 97 67 00 00       	call   f010697d <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001e6:	83 3d 88 2e 23 f0 07 	cmpl   $0x7,0xf0232e88
f01001ed:	77 24                	ja     f0100213 <i386_init+0x9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001ef:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001f6:	00 
f01001f7:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f01001fe:	f0 
f01001ff:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100206:	00 
f0100207:	c7 04 24 ba 6c 10 f0 	movl   $0xf0106cba,(%esp)
f010020e:	e8 72 fe ff ff       	call   f0100085 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100213:	b8 ea 61 10 f0       	mov    $0xf01061ea,%eax
f0100218:	2d 70 61 10 f0       	sub    $0xf0106170,%eax
f010021d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100221:	c7 44 24 04 70 61 10 	movl   $0xf0106170,0x4(%esp)
f0100228:	f0 
f0100229:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100230:	e8 5b 5d 00 00       	call   f0105f90 <memmove>
f0100235:	be 00 00 00 00       	mov    $0x0,%esi
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010023a:	bf 20 30 23 f0       	mov    $0xf0233020,%edi
f010023f:	eb 49                	jmp    f010028a <i386_init+0x113>
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
f0100241:	e8 68 63 00 00       	call   f01065ae <cpunum>
f0100246:	6b c0 74             	imul   $0x74,%eax,%eax
f0100249:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010024e:	39 c3                	cmp    %eax,%ebx
f0100250:	74 35                	je     f0100287 <i386_init+0x110>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100252:	89 f0                	mov    %esi,%eax
f0100254:	c1 f8 02             	sar    $0x2,%eax
f0100257:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010025d:	c1 e0 0f             	shl    $0xf,%eax
f0100260:	8d 80 00 c0 23 f0    	lea    -0xfdc4000(%eax),%eax
f0100266:	a3 84 2e 23 f0       	mov    %eax,0xf0232e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010026b:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100272:	00 
f0100273:	0f b6 04 37          	movzbl (%edi,%esi,1),%eax
f0100277:	89 04 24             	mov    %eax,(%esp)
f010027a:	e8 98 63 00 00       	call   f0106617 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010027f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100282:	83 f8 01             	cmp    $0x1,%eax
f0100285:	75 f8                	jne    f010027f <i386_init+0x108>
f0100287:	83 c6 74             	add    $0x74,%esi
f010028a:	8d 9e 20 30 23 f0    	lea    -0xfdccfe0(%esi),%ebx
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100290:	6b 05 c4 33 23 f0 74 	imul   $0x74,0xf02333c4,%eax
f0100297:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010029c:	39 c3                	cmp    %eax,%ebx
f010029e:	72 a1                	jb     f0100241 <i386_init+0xca>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01002a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01002a7:	00 
f01002a8:	c7 04 24 04 81 22 f0 	movl   $0xf0228104,(%esp)
f01002af:	e8 83 3c 00 00       	call   f0103f37 <env_create>
	ENV_CREATE(user_yield,ENV_TYPE_USER);
	ENV_CREATE(user_yield,ENV_TYPE_USER);	
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f01002b4:	e8 01 4a 00 00       	call   f0104cba <sched_yield>
f01002b9:	00 00                	add    %al,(%eax)
f01002bb:	00 00                	add    %al,(%eax)
f01002bd:	00 00                	add    %al,(%eax)
	...

f01002c0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002c0:	55                   	push   %ebp
f01002c1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002c8:	ec                   	in     (%dx),%al
f01002c9:	ec                   	in     (%dx),%al
f01002ca:	ec                   	in     (%dx),%al
f01002cb:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002cc:	5d                   	pop    %ebp
f01002cd:	c3                   	ret    

f01002ce <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002ce:	55                   	push   %ebp
f01002cf:	89 e5                	mov    %esp,%ebp
f01002d1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d6:	ec                   	in     (%dx),%al
f01002d7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002de:	f6 c2 01             	test   $0x1,%dl
f01002e1:	74 09                	je     f01002ec <serial_proc_data+0x1e>
f01002e3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002e8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002e9:	0f b6 c0             	movzbl %al,%eax
}
f01002ec:	5d                   	pop    %ebp
f01002ed:	c3                   	ret    

f01002ee <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002ee:	55                   	push   %ebp
f01002ef:	89 e5                	mov    %esp,%ebp
f01002f1:	57                   	push   %edi
f01002f2:	56                   	push   %esi
f01002f3:	53                   	push   %ebx
f01002f4:	83 ec 0c             	sub    $0xc,%esp
f01002f7:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01002f9:	bb 24 22 23 f0       	mov    $0xf0232224,%ebx
f01002fe:	bf 20 20 23 f0       	mov    $0xf0232020,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100303:	eb 1e                	jmp    f0100323 <cons_intr+0x35>
		if (c == 0)
f0100305:	85 c0                	test   %eax,%eax
f0100307:	74 1a                	je     f0100323 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f0100309:	8b 13                	mov    (%ebx),%edx
f010030b:	88 04 17             	mov    %al,(%edi,%edx,1)
f010030e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100311:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100316:	0f 94 c2             	sete   %dl
f0100319:	0f b6 d2             	movzbl %dl,%edx
f010031c:	83 ea 01             	sub    $0x1,%edx
f010031f:	21 d0                	and    %edx,%eax
f0100321:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100323:	ff d6                	call   *%esi
f0100325:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100328:	75 db                	jne    f0100305 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010032a:	83 c4 0c             	add    $0xc,%esp
f010032d:	5b                   	pop    %ebx
f010032e:	5e                   	pop    %esi
f010032f:	5f                   	pop    %edi
f0100330:	5d                   	pop    %ebp
f0100331:	c3                   	ret    

f0100332 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100332:	55                   	push   %ebp
f0100333:	89 e5                	mov    %esp,%ebp
f0100335:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100338:	b8 c2 05 10 f0       	mov    $0xf01005c2,%eax
f010033d:	e8 ac ff ff ff       	call   f01002ee <cons_intr>
}
f0100342:	c9                   	leave  
f0100343:	c3                   	ret    

f0100344 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100344:	55                   	push   %ebp
f0100345:	89 e5                	mov    %esp,%ebp
f0100347:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010034a:	80 3d 04 20 23 f0 00 	cmpb   $0x0,0xf0232004
f0100351:	74 0a                	je     f010035d <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100353:	b8 ce 02 10 f0       	mov    $0xf01002ce,%eax
f0100358:	e8 91 ff ff ff       	call   f01002ee <cons_intr>
}
f010035d:	c9                   	leave  
f010035e:	c3                   	ret    

f010035f <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010035f:	55                   	push   %ebp
f0100360:	89 e5                	mov    %esp,%ebp
f0100362:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100365:	e8 da ff ff ff       	call   f0100344 <serial_intr>
	kbd_intr();
f010036a:	e8 c3 ff ff ff       	call   f0100332 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010036f:	8b 15 20 22 23 f0    	mov    0xf0232220,%edx
f0100375:	b8 00 00 00 00       	mov    $0x0,%eax
f010037a:	3b 15 24 22 23 f0    	cmp    0xf0232224,%edx
f0100380:	74 21                	je     f01003a3 <cons_getc+0x44>
		c = cons.buf[cons.rpos++];
f0100382:	0f b6 82 20 20 23 f0 	movzbl -0xfdcdfe0(%edx),%eax
f0100389:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f010038c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f0100392:	0f 94 c1             	sete   %cl
f0100395:	0f b6 c9             	movzbl %cl,%ecx
f0100398:	83 e9 01             	sub    $0x1,%ecx
f010039b:	21 ca                	and    %ecx,%edx
f010039d:	89 15 20 22 23 f0    	mov    %edx,0xf0232220
		return c;
	}
	return 0;
}
f01003a3:	c9                   	leave  
f01003a4:	c3                   	ret    

f01003a5 <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01003a5:	55                   	push   %ebp
f01003a6:	89 e5                	mov    %esp,%ebp
f01003a8:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01003ab:	e8 af ff ff ff       	call   f010035f <cons_getc>
f01003b0:	85 c0                	test   %eax,%eax
f01003b2:	74 f7                	je     f01003ab <getchar+0x6>
		/* do nothing */;
	return c;
}
f01003b4:	c9                   	leave  
f01003b5:	c3                   	ret    

f01003b6 <iscons>:

int
iscons(int fdnum)
{
f01003b6:	55                   	push   %ebp
f01003b7:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01003b9:	b8 01 00 00 00       	mov    $0x1,%eax
f01003be:	5d                   	pop    %ebp
f01003bf:	c3                   	ret    

f01003c0 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003c0:	55                   	push   %ebp
f01003c1:	89 e5                	mov    %esp,%ebp
f01003c3:	57                   	push   %edi
f01003c4:	56                   	push   %esi
f01003c5:	53                   	push   %ebx
f01003c6:	83 ec 2c             	sub    $0x2c,%esp
f01003c9:	89 c7                	mov    %eax,%edi
f01003cb:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003d0:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003d5:	eb 08                	jmp    f01003df <cons_putc+0x1f>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01003d7:	e8 e4 fe ff ff       	call   f01002c0 <delay>
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003dc:	83 c3 01             	add    $0x1,%ebx
f01003df:	89 f2                	mov    %esi,%edx
f01003e1:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003e2:	a8 20                	test   $0x20,%al
f01003e4:	75 08                	jne    f01003ee <cons_putc+0x2e>
f01003e6:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003ec:	75 e9                	jne    f01003d7 <cons_putc+0x17>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01003ee:	89 fa                	mov    %edi,%edx
f01003f0:	89 f8                	mov    %edi,%eax
f01003f2:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003f5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003fa:	ee                   	out    %al,(%dx)
f01003fb:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100400:	be 79 03 00 00       	mov    $0x379,%esi
f0100405:	eb 08                	jmp    f010040f <cons_putc+0x4f>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100407:	e8 b4 fe ff ff       	call   f01002c0 <delay>
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010040c:	83 c3 01             	add    $0x1,%ebx
f010040f:	89 f2                	mov    %esi,%edx
f0100411:	ec                   	in     (%dx),%al
f0100412:	84 c0                	test   %al,%al
f0100414:	78 08                	js     f010041e <cons_putc+0x5e>
f0100416:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010041c:	75 e9                	jne    f0100407 <cons_putc+0x47>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010041e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100423:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100427:	ee                   	out    %al,(%dx)
f0100428:	b2 7a                	mov    $0x7a,%dl
f010042a:	b8 0d 00 00 00       	mov    $0xd,%eax
f010042f:	ee                   	out    %al,(%dx)
f0100430:	b8 08 00 00 00       	mov    $0x8,%eax
f0100435:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100436:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010043c:	75 06                	jne    f0100444 <cons_putc+0x84>
		c |= 0x0700;
f010043e:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100444:	89 f8                	mov    %edi,%eax
f0100446:	25 ff 00 00 00       	and    $0xff,%eax
f010044b:	83 f8 09             	cmp    $0x9,%eax
f010044e:	0f 84 88 00 00 00    	je     f01004dc <cons_putc+0x11c>
f0100454:	83 f8 09             	cmp    $0x9,%eax
f0100457:	7f 11                	jg     f010046a <cons_putc+0xaa>
f0100459:	83 f8 08             	cmp    $0x8,%eax
f010045c:	0f 85 ae 00 00 00    	jne    f0100510 <cons_putc+0x150>
f0100462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0100468:	eb 18                	jmp    f0100482 <cons_putc+0xc2>
f010046a:	83 f8 0a             	cmp    $0xa,%eax
f010046d:	8d 76 00             	lea    0x0(%esi),%esi
f0100470:	74 40                	je     f01004b2 <cons_putc+0xf2>
f0100472:	83 f8 0d             	cmp    $0xd,%eax
f0100475:	8d 76 00             	lea    0x0(%esi),%esi
f0100478:	0f 85 92 00 00 00    	jne    f0100510 <cons_putc+0x150>
f010047e:	66 90                	xchg   %ax,%ax
f0100480:	eb 38                	jmp    f01004ba <cons_putc+0xfa>
	case '\b':
		if (crt_pos > 0) {
f0100482:	0f b7 05 10 20 23 f0 	movzwl 0xf0232010,%eax
f0100489:	66 85 c0             	test   %ax,%ax
f010048c:	0f 84 e8 00 00 00    	je     f010057a <cons_putc+0x1ba>
			crt_pos--;
f0100492:	83 e8 01             	sub    $0x1,%eax
f0100495:	66 a3 10 20 23 f0    	mov    %ax,0xf0232010
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010049b:	0f b7 c0             	movzwl %ax,%eax
f010049e:	66 81 e7 00 ff       	and    $0xff00,%di
f01004a3:	83 cf 20             	or     $0x20,%edi
f01004a6:	8b 15 0c 20 23 f0    	mov    0xf023200c,%edx
f01004ac:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b0:	eb 7b                	jmp    f010052d <cons_putc+0x16d>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004b2:	66 83 05 10 20 23 f0 	addw   $0x50,0xf0232010
f01004b9:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004ba:	0f b7 05 10 20 23 f0 	movzwl 0xf0232010,%eax
f01004c1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004c7:	c1 e8 10             	shr    $0x10,%eax
f01004ca:	66 c1 e8 06          	shr    $0x6,%ax
f01004ce:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004d1:	c1 e0 04             	shl    $0x4,%eax
f01004d4:	66 a3 10 20 23 f0    	mov    %ax,0xf0232010
f01004da:	eb 51                	jmp    f010052d <cons_putc+0x16d>
		break;
	case '\t':
		cons_putc(' ');
f01004dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e1:	e8 da fe ff ff       	call   f01003c0 <cons_putc>
		cons_putc(' ');
f01004e6:	b8 20 00 00 00       	mov    $0x20,%eax
f01004eb:	e8 d0 fe ff ff       	call   f01003c0 <cons_putc>
		cons_putc(' ');
f01004f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f5:	e8 c6 fe ff ff       	call   f01003c0 <cons_putc>
		cons_putc(' ');
f01004fa:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ff:	e8 bc fe ff ff       	call   f01003c0 <cons_putc>
		cons_putc(' ');
f0100504:	b8 20 00 00 00       	mov    $0x20,%eax
f0100509:	e8 b2 fe ff ff       	call   f01003c0 <cons_putc>
f010050e:	eb 1d                	jmp    f010052d <cons_putc+0x16d>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100510:	0f b7 05 10 20 23 f0 	movzwl 0xf0232010,%eax
f0100517:	0f b7 c8             	movzwl %ax,%ecx
f010051a:	8b 15 0c 20 23 f0    	mov    0xf023200c,%edx
f0100520:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f0100524:	83 c0 01             	add    $0x1,%eax
f0100527:	66 a3 10 20 23 f0    	mov    %ax,0xf0232010
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010052d:	66 81 3d 10 20 23 f0 	cmpw   $0x7cf,0xf0232010
f0100534:	cf 07 
f0100536:	76 42                	jbe    f010057a <cons_putc+0x1ba>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100538:	a1 0c 20 23 f0       	mov    0xf023200c,%eax
f010053d:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100544:	00 
f0100545:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010054f:	89 04 24             	mov    %eax,(%esp)
f0100552:	e8 39 5a 00 00       	call   f0105f90 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100557:	8b 15 0c 20 23 f0    	mov    0xf023200c,%edx
f010055d:	b8 80 07 00 00       	mov    $0x780,%eax
f0100562:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100568:	83 c0 01             	add    $0x1,%eax
f010056b:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100570:	75 f0                	jne    f0100562 <cons_putc+0x1a2>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100572:	66 83 2d 10 20 23 f0 	subw   $0x50,0xf0232010
f0100579:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010057a:	8b 0d 08 20 23 f0    	mov    0xf0232008,%ecx
f0100580:	89 cb                	mov    %ecx,%ebx
f0100582:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100587:	89 ca                	mov    %ecx,%edx
f0100589:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010058a:	0f b7 35 10 20 23 f0 	movzwl 0xf0232010,%esi
f0100591:	83 c1 01             	add    $0x1,%ecx
f0100594:	89 f0                	mov    %esi,%eax
f0100596:	66 c1 e8 08          	shr    $0x8,%ax
f010059a:	89 ca                	mov    %ecx,%edx
f010059c:	ee                   	out    %al,(%dx)
f010059d:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a2:	89 da                	mov    %ebx,%edx
f01005a4:	ee                   	out    %al,(%dx)
f01005a5:	89 f0                	mov    %esi,%eax
f01005a7:	89 ca                	mov    %ecx,%edx
f01005a9:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005aa:	83 c4 2c             	add    $0x2c,%esp
f01005ad:	5b                   	pop    %ebx
f01005ae:	5e                   	pop    %esi
f01005af:	5f                   	pop    %edi
f01005b0:	5d                   	pop    %ebp
f01005b1:	c3                   	ret    

f01005b2 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005b2:	55                   	push   %ebp
f01005b3:	89 e5                	mov    %esp,%ebp
f01005b5:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01005bb:	e8 00 fe ff ff       	call   f01003c0 <cons_putc>
}
f01005c0:	c9                   	leave  
f01005c1:	c3                   	ret    

f01005c2 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01005c2:	55                   	push   %ebp
f01005c3:	89 e5                	mov    %esp,%ebp
f01005c5:	53                   	push   %ebx
f01005c6:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c9:	ba 64 00 00 00       	mov    $0x64,%edx
f01005ce:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01005cf:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005d4:	a8 01                	test   $0x1,%al
f01005d6:	0f 84 d9 00 00 00    	je     f01006b5 <kbd_proc_data+0xf3>
f01005dc:	b2 60                	mov    $0x60,%dl
f01005de:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01005df:	3c e0                	cmp    $0xe0,%al
f01005e1:	75 11                	jne    f01005f4 <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01005e3:	83 0d 00 20 23 f0 40 	orl    $0x40,0xf0232000
f01005ea:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f01005ef:	e9 c1 00 00 00       	jmp    f01006b5 <kbd_proc_data+0xf3>
	} else if (data & 0x80) {
f01005f4:	84 c0                	test   %al,%al
f01005f6:	79 32                	jns    f010062a <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01005f8:	8b 15 00 20 23 f0    	mov    0xf0232000,%edx
f01005fe:	f6 c2 40             	test   $0x40,%dl
f0100601:	75 03                	jne    f0100606 <kbd_proc_data+0x44>
f0100603:	83 e0 7f             	and    $0x7f,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f0100606:	0f b6 c0             	movzbl %al,%eax
f0100609:	0f b6 80 a0 6d 10 f0 	movzbl -0xfef9260(%eax),%eax
f0100610:	83 c8 40             	or     $0x40,%eax
f0100613:	0f b6 c0             	movzbl %al,%eax
f0100616:	f7 d0                	not    %eax
f0100618:	21 c2                	and    %eax,%edx
f010061a:	89 15 00 20 23 f0    	mov    %edx,0xf0232000
f0100620:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100625:	e9 8b 00 00 00       	jmp    f01006b5 <kbd_proc_data+0xf3>
	} else if (shift & E0ESC) {
f010062a:	8b 15 00 20 23 f0    	mov    0xf0232000,%edx
f0100630:	f6 c2 40             	test   $0x40,%dl
f0100633:	74 0c                	je     f0100641 <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100635:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100638:	83 e2 bf             	and    $0xffffffbf,%edx
f010063b:	89 15 00 20 23 f0    	mov    %edx,0xf0232000
	}

	shift |= shiftcode[data];
f0100641:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f0100644:	0f b6 90 a0 6d 10 f0 	movzbl -0xfef9260(%eax),%edx
f010064b:	0b 15 00 20 23 f0    	or     0xf0232000,%edx
f0100651:	0f b6 88 a0 6e 10 f0 	movzbl -0xfef9160(%eax),%ecx
f0100658:	31 ca                	xor    %ecx,%edx
f010065a:	89 15 00 20 23 f0    	mov    %edx,0xf0232000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100660:	89 d1                	mov    %edx,%ecx
f0100662:	83 e1 03             	and    $0x3,%ecx
f0100665:	8b 0c 8d a0 6f 10 f0 	mov    -0xfef9060(,%ecx,4),%ecx
f010066c:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f0100670:	f6 c2 08             	test   $0x8,%dl
f0100673:	74 1a                	je     f010068f <kbd_proc_data+0xcd>
		if ('a' <= c && c <= 'z')
f0100675:	89 d9                	mov    %ebx,%ecx
f0100677:	8d 43 9f             	lea    -0x61(%ebx),%eax
f010067a:	83 f8 19             	cmp    $0x19,%eax
f010067d:	77 05                	ja     f0100684 <kbd_proc_data+0xc2>
			c += 'A' - 'a';
f010067f:	83 eb 20             	sub    $0x20,%ebx
f0100682:	eb 0b                	jmp    f010068f <kbd_proc_data+0xcd>
		else if ('A' <= c && c <= 'Z')
f0100684:	83 e9 41             	sub    $0x41,%ecx
f0100687:	83 f9 19             	cmp    $0x19,%ecx
f010068a:	77 03                	ja     f010068f <kbd_proc_data+0xcd>
			c += 'a' - 'A';
f010068c:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010068f:	f7 d2                	not    %edx
f0100691:	f6 c2 06             	test   $0x6,%dl
f0100694:	75 1f                	jne    f01006b5 <kbd_proc_data+0xf3>
f0100696:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010069c:	75 17                	jne    f01006b5 <kbd_proc_data+0xf3>
		cprintf("Rebooting!\n");
f010069e:	c7 04 24 63 6d 10 f0 	movl   $0xf0106d63,(%esp)
f01006a5:	e8 75 3b 00 00       	call   f010421f <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006aa:	ba 92 00 00 00       	mov    $0x92,%edx
f01006af:	b8 03 00 00 00       	mov    $0x3,%eax
f01006b4:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01006b5:	89 d8                	mov    %ebx,%eax
f01006b7:	83 c4 14             	add    $0x14,%esp
f01006ba:	5b                   	pop    %ebx
f01006bb:	5d                   	pop    %ebp
f01006bc:	c3                   	ret    

f01006bd <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006bd:	55                   	push   %ebp
f01006be:	89 e5                	mov    %esp,%ebp
f01006c0:	57                   	push   %edi
f01006c1:	56                   	push   %esi
f01006c2:	53                   	push   %ebx
f01006c3:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006c6:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01006cb:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01006ce:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01006d3:	0f b7 00             	movzwl (%eax),%eax
f01006d6:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006da:	74 11                	je     f01006ed <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006dc:	c7 05 08 20 23 f0 b4 	movl   $0x3b4,0xf0232008
f01006e3:	03 00 00 
f01006e6:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006eb:	eb 16                	jmp    f0100703 <cons_init+0x46>
	} else {
		*cp = was;
f01006ed:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006f4:	c7 05 08 20 23 f0 d4 	movl   $0x3d4,0xf0232008
f01006fb:	03 00 00 
f01006fe:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100703:	8b 0d 08 20 23 f0    	mov    0xf0232008,%ecx
f0100709:	89 cb                	mov    %ecx,%ebx
f010070b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100710:	89 ca                	mov    %ecx,%edx
f0100712:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100713:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100716:	89 ca                	mov    %ecx,%edx
f0100718:	ec                   	in     (%dx),%al
f0100719:	0f b6 f8             	movzbl %al,%edi
f010071c:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010071f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100724:	89 da                	mov    %ebx,%edx
f0100726:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100727:	89 ca                	mov    %ecx,%edx
f0100729:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010072a:	89 35 0c 20 23 f0    	mov    %esi,0xf023200c
	crt_pos = pos;
f0100730:	0f b6 c8             	movzbl %al,%ecx
f0100733:	09 cf                	or     %ecx,%edi
f0100735:	66 89 3d 10 20 23 f0 	mov    %di,0xf0232010

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f010073c:	e8 f1 fb ff ff       	call   f0100332 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f0100741:	0f b7 05 90 13 12 f0 	movzwl 0xf0121390,%eax
f0100748:	25 fd ff 00 00       	and    $0xfffd,%eax
f010074d:	89 04 24             	mov    %eax,(%esp)
f0100750:	e8 9b 39 00 00       	call   f01040f0 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100755:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010075a:	b8 00 00 00 00       	mov    $0x0,%eax
f010075f:	89 da                	mov    %ebx,%edx
f0100761:	ee                   	out    %al,(%dx)
f0100762:	b2 fb                	mov    $0xfb,%dl
f0100764:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100769:	ee                   	out    %al,(%dx)
f010076a:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010076f:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100774:	89 ca                	mov    %ecx,%edx
f0100776:	ee                   	out    %al,(%dx)
f0100777:	b2 f9                	mov    $0xf9,%dl
f0100779:	b8 00 00 00 00       	mov    $0x0,%eax
f010077e:	ee                   	out    %al,(%dx)
f010077f:	b2 fb                	mov    $0xfb,%dl
f0100781:	b8 03 00 00 00       	mov    $0x3,%eax
f0100786:	ee                   	out    %al,(%dx)
f0100787:	b2 fc                	mov    $0xfc,%dl
f0100789:	b8 00 00 00 00       	mov    $0x0,%eax
f010078e:	ee                   	out    %al,(%dx)
f010078f:	b2 f9                	mov    $0xf9,%dl
f0100791:	b8 01 00 00 00       	mov    $0x1,%eax
f0100796:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100797:	b2 fd                	mov    $0xfd,%dl
f0100799:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010079a:	3c ff                	cmp    $0xff,%al
f010079c:	0f 95 c0             	setne  %al
f010079f:	89 c6                	mov    %eax,%esi
f01007a1:	a2 04 20 23 f0       	mov    %al,0xf0232004
f01007a6:	89 da                	mov    %ebx,%edx
f01007a8:	ec                   	in     (%dx),%al
f01007a9:	89 ca                	mov    %ecx,%edx
f01007ab:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007ac:	89 f0                	mov    %esi,%eax
f01007ae:	84 c0                	test   %al,%al
f01007b0:	75 0c                	jne    f01007be <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f01007b2:	c7 04 24 6f 6d 10 f0 	movl   $0xf0106d6f,(%esp)
f01007b9:	e8 61 3a 00 00       	call   f010421f <cprintf>
}
f01007be:	83 c4 1c             	add    $0x1c,%esp
f01007c1:	5b                   	pop    %ebx
f01007c2:	5e                   	pop    %esi
f01007c3:	5f                   	pop    %edi
f01007c4:	5d                   	pop    %ebp
f01007c5:	c3                   	ret    
	...

f01007d0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d6:	c7 04 24 b0 6f 10 f0 	movl   $0xf0106fb0,(%esp)
f01007dd:	e8 3d 3a 00 00       	call   f010421f <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e2:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007e9:	00 
f01007ea:	c7 04 24 80 70 10 f0 	movl   $0xf0107080,(%esp)
f01007f1:	e8 29 3a 00 00       	call   f010421f <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007fd:	00 
f01007fe:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100805:	f0 
f0100806:	c7 04 24 a8 70 10 f0 	movl   $0xf01070a8,(%esp)
f010080d:	e8 0d 3a 00 00       	call   f010421f <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100812:	c7 44 24 08 95 6c 10 	movl   $0x106c95,0x8(%esp)
f0100819:	00 
f010081a:	c7 44 24 04 95 6c 10 	movl   $0xf0106c95,0x4(%esp)
f0100821:	f0 
f0100822:	c7 04 24 cc 70 10 f0 	movl   $0xf01070cc,(%esp)
f0100829:	e8 f1 39 00 00       	call   f010421f <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010082e:	c7 44 24 08 78 1b 23 	movl   $0x231b78,0x8(%esp)
f0100835:	00 
f0100836:	c7 44 24 04 78 1b 23 	movl   $0xf0231b78,0x4(%esp)
f010083d:	f0 
f010083e:	c7 04 24 f0 70 10 f0 	movl   $0xf01070f0,(%esp)
f0100845:	e8 d5 39 00 00       	call   f010421f <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010084a:	c7 44 24 08 08 40 27 	movl   $0x274008,0x8(%esp)
f0100851:	00 
f0100852:	c7 44 24 04 08 40 27 	movl   $0xf0274008,0x4(%esp)
f0100859:	f0 
f010085a:	c7 04 24 14 71 10 f0 	movl   $0xf0107114,(%esp)
f0100861:	e8 b9 39 00 00       	call   f010421f <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100866:	b8 07 44 27 f0       	mov    $0xf0274407,%eax
f010086b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100870:	c1 f8 0a             	sar    $0xa,%eax
f0100873:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100877:	c7 04 24 38 71 10 f0 	movl   $0xf0107138,(%esp)
f010087e:	e8 9c 39 00 00       	call   f010421f <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100883:	b8 00 00 00 00       	mov    $0x0,%eax
f0100888:	c9                   	leave  
f0100889:	c3                   	ret    

f010088a <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010088a:	55                   	push   %ebp
f010088b:	89 e5                	mov    %esp,%ebp
f010088d:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100890:	a1 dc 71 10 f0       	mov    0xf01071dc,%eax
f0100895:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100899:	a1 d8 71 10 f0       	mov    0xf01071d8,%eax
f010089e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a2:	c7 04 24 c9 6f 10 f0 	movl   $0xf0106fc9,(%esp)
f01008a9:	e8 71 39 00 00       	call   f010421f <cprintf>
f01008ae:	a1 e8 71 10 f0       	mov    0xf01071e8,%eax
f01008b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008b7:	a1 e4 71 10 f0       	mov    0xf01071e4,%eax
f01008bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008c0:	c7 04 24 c9 6f 10 f0 	movl   $0xf0106fc9,(%esp)
f01008c7:	e8 53 39 00 00       	call   f010421f <cprintf>
	return 0;
}
f01008cc:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d1:	c9                   	leave  
f01008d2:	c3                   	ret    

f01008d3 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008d3:	55                   	push   %ebp
f01008d4:	89 e5                	mov    %esp,%ebp
f01008d6:	57                   	push   %edi
f01008d7:	56                   	push   %esi
f01008d8:	53                   	push   %ebx
f01008d9:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008dc:	c7 04 24 64 71 10 f0 	movl   $0xf0107164,(%esp)
f01008e3:	e8 37 39 00 00       	call   f010421f <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008e8:	c7 04 24 88 71 10 f0 	movl   $0xf0107188,(%esp)
f01008ef:	e8 2b 39 00 00       	call   f010421f <cprintf>

	if (tf != NULL)
f01008f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008f8:	74 0b                	je     f0100905 <monitor+0x32>
		print_trapframe(tf);
f01008fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01008fd:	89 04 24             	mov    %eax,(%esp)
f0100900:	e8 0e 3c 00 00       	call   f0104513 <print_trapframe>

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100905:	bf d8 71 10 f0       	mov    $0xf01071d8,%edi

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
f010090a:	c7 04 24 d2 6f 10 f0 	movl   $0xf0106fd2,(%esp)
f0100911:	e8 ba 53 00 00       	call   f0105cd0 <readline>
f0100916:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100918:	85 c0                	test   %eax,%eax
f010091a:	74 ee                	je     f010090a <monitor+0x37>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010091c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100923:	be 00 00 00 00       	mov    $0x0,%esi
f0100928:	eb 06                	jmp    f0100930 <monitor+0x5d>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010092a:	c6 03 00             	movb   $0x0,(%ebx)
f010092d:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100930:	0f b6 03             	movzbl (%ebx),%eax
f0100933:	84 c0                	test   %al,%al
f0100935:	74 63                	je     f010099a <monitor+0xc7>
f0100937:	0f be c0             	movsbl %al,%eax
f010093a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093e:	c7 04 24 d6 6f 10 f0 	movl   $0xf0106fd6,(%esp)
f0100945:	e8 a9 55 00 00       	call   f0105ef3 <strchr>
f010094a:	85 c0                	test   %eax,%eax
f010094c:	75 dc                	jne    f010092a <monitor+0x57>
			*buf++ = 0;
		if (*buf == 0)
f010094e:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100951:	74 47                	je     f010099a <monitor+0xc7>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100953:	83 fe 0f             	cmp    $0xf,%esi
f0100956:	75 16                	jne    f010096e <monitor+0x9b>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100958:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010095f:	00 
f0100960:	c7 04 24 db 6f 10 f0 	movl   $0xf0106fdb,(%esp)
f0100967:	e8 b3 38 00 00       	call   f010421f <cprintf>
f010096c:	eb 9c                	jmp    f010090a <monitor+0x37>
			return 0;
		}
		argv[argc++] = buf;
f010096e:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100972:	83 c6 01             	add    $0x1,%esi
f0100975:	eb 03                	jmp    f010097a <monitor+0xa7>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100977:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010097a:	0f b6 03             	movzbl (%ebx),%eax
f010097d:	84 c0                	test   %al,%al
f010097f:	74 af                	je     f0100930 <monitor+0x5d>
f0100981:	0f be c0             	movsbl %al,%eax
f0100984:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100988:	c7 04 24 d6 6f 10 f0 	movl   $0xf0106fd6,(%esp)
f010098f:	e8 5f 55 00 00       	call   f0105ef3 <strchr>
f0100994:	85 c0                	test   %eax,%eax
f0100996:	74 df                	je     f0100977 <monitor+0xa4>
f0100998:	eb 96                	jmp    f0100930 <monitor+0x5d>
			buf++;
	}
	argv[argc] = 0;
f010099a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009a1:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009a2:	85 f6                	test   %esi,%esi
f01009a4:	0f 84 60 ff ff ff    	je     f010090a <monitor+0x37>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009aa:	8b 07                	mov    (%edi),%eax
f01009ac:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b0:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009b3:	89 04 24             	mov    %eax,(%esp)
f01009b6:	e8 d9 54 00 00       	call   f0105e94 <strcmp>
f01009bb:	ba 00 00 00 00       	mov    $0x0,%edx
f01009c0:	85 c0                	test   %eax,%eax
f01009c2:	74 1d                	je     f01009e1 <monitor+0x10e>
f01009c4:	a1 e4 71 10 f0       	mov    0xf01071e4,%eax
f01009c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009cd:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009d0:	89 04 24             	mov    %eax,(%esp)
f01009d3:	e8 bc 54 00 00       	call   f0105e94 <strcmp>
f01009d8:	85 c0                	test   %eax,%eax
f01009da:	75 28                	jne    f0100a04 <monitor+0x131>
f01009dc:	ba 01 00 00 00       	mov    $0x1,%edx
			return commands[i].func(argc, argv, tf);
f01009e1:	6b d2 0c             	imul   $0xc,%edx,%edx
f01009e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01009e7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009eb:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01009ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009f2:	89 34 24             	mov    %esi,(%esp)
f01009f5:	ff 92 e0 71 10 f0    	call   *-0xfef8e20(%edx)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009fb:	85 c0                	test   %eax,%eax
f01009fd:	78 1d                	js     f0100a1c <monitor+0x149>
f01009ff:	e9 06 ff ff ff       	jmp    f010090a <monitor+0x37>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a04:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a0b:	c7 04 24 f8 6f 10 f0 	movl   $0xf0106ff8,(%esp)
f0100a12:	e8 08 38 00 00       	call   f010421f <cprintf>
f0100a17:	e9 ee fe ff ff       	jmp    f010090a <monitor+0x37>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a1c:	83 c4 5c             	add    $0x5c,%esp
f0100a1f:	5b                   	pop    %ebx
f0100a20:	5e                   	pop    %esi
f0100a21:	5f                   	pop    %edi
f0100a22:	5d                   	pop    %ebp
f0100a23:	c3                   	ret    

f0100a24 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a24:	55                   	push   %ebp
f0100a25:	89 e5                	mov    %esp,%ebp
f0100a27:	57                   	push   %edi
f0100a28:	56                   	push   %esi
f0100a29:	53                   	push   %ebx
f0100a2a:	83 ec 4c             	sub    $0x4c,%esp

static __inline uint32_t
read_eip(void)
{
	uint32_t eip;
	__asm __volatile("movl 4(%%ebp),%0" : "=r" (eip));
f0100a2d:	8b 7d 04             	mov    0x4(%ebp),%edi

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a30:	89 e8                	mov    %ebp,%eax
f0100a32:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	uint32_t eip=read_eip();
	uint32_t ebp=read_ebp();
	uint32_t esp=ebp;
	int i;
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f0100a35:	c7 04 24 0e 70 10 f0 	movl   $0xf010700e,(%esp)
f0100a3c:	e8 de 37 00 00       	call   f010421f <cprintf>
f0100a41:	8b 75 c4             	mov    -0x3c(%ebp),%esi
	// in Entry.S it sets ebp to 0 at first,so if ebp==0 then we know that there is no more stack.
	while(ebp!=0) {
f0100a44:	e9 bf 00 00 00       	jmp    f0100b08 <mon_backtrace+0xe4>
		cprintf("ebp %08x  eip %08x  args  ",ebp,eip);
f0100a49:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100a4d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100a50:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a54:	c7 04 24 20 70 10 f0 	movl   $0xf0107020,(%esp)
f0100a5b:	e8 bf 37 00 00       	call   f010421f <cprintf>
		// pop the saved ebp to current ebp.
		ebp=*(uint32_t *)esp;
f0100a60:	8b 06                	mov    (%esi),%eax
f0100a62:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		esp+=4;
		// pop the saved eip to current eip.
		eip=*(uint32_t *)esp;
f0100a65:	8b 7e 04             	mov    0x4(%esi),%edi
f0100a68:	bb 00 00 00 00       	mov    $0x0,%ebx
		esp+=4;
		for(i=0;i<=4;i++){
			cprintf("%08x ",*(uint32_t *)esp);
f0100a6d:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100a71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a75:	c7 04 24 3b 70 10 f0 	movl   $0xf010703b,(%esp)
f0100a7c:	e8 9e 37 00 00       	call   f010421f <cprintf>
		ebp=*(uint32_t *)esp;
		esp+=4;
		// pop the saved eip to current eip.
		eip=*(uint32_t *)esp;
		esp+=4;
		for(i=0;i<=4;i++){
f0100a81:	83 c3 01             	add    $0x1,%ebx
f0100a84:	83 fb 05             	cmp    $0x5,%ebx
f0100a87:	75 e4                	jne    f0100a6d <mon_backtrace+0x49>
			cprintf("%08x ",*(uint32_t *)esp);
			esp+=4;
		}
		cprintf("\n");
f0100a89:	c7 04 24 ff 7e 10 f0 	movl   $0xf0107eff,(%esp)
f0100a90:	e8 8a 37 00 00       	call   f010421f <cprintf>
		cprintf("        ");
f0100a95:	c7 04 24 41 70 10 f0 	movl   $0xf0107041,(%esp)
f0100a9c:	e8 7e 37 00 00       	call   f010421f <cprintf>
		debuginfo_eip(eip,&info);
f0100aa1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aa8:	89 3c 24             	mov    %edi,(%esp)
f0100aab:	e8 82 49 00 00       	call   f0105432 <debuginfo_eip>
		cprintf("%s:%d: ",info.eip_file, info.eip_line);
f0100ab0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ab3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ab7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100aba:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100abe:	c7 04 24 b2 6c 10 f0 	movl   $0xf0106cb2,(%esp)
f0100ac5:	e8 55 37 00 00       	call   f010421f <cprintf>
		cprintf("%.*s",info.eip_fn_namelen, info.eip_fn_name);
f0100aca:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100acd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ad1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ad8:	c7 04 24 4a 70 10 f0 	movl   $0xf010704a,(%esp)
f0100adf:	e8 3b 37 00 00       	call   f010421f <cprintf>
		cprintf("+%d", eip-info.eip_fn_addr);
f0100ae4:	89 f8                	mov    %edi,%eax
f0100ae6:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100ae9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aed:	c7 04 24 4f 70 10 f0 	movl   $0xf010704f,(%esp)
f0100af4:	e8 26 37 00 00       	call   f010421f <cprintf>
		cprintf("\n");
f0100af9:	c7 04 24 ff 7e 10 f0 	movl   $0xf0107eff,(%esp)
f0100b00:	e8 1a 37 00 00       	call   f010421f <cprintf>
f0100b05:	8b 75 c4             	mov    -0x3c(%ebp),%esi
	uint32_t esp=ebp;
	int i;
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
	// in Entry.S it sets ebp to 0 at first,so if ebp==0 then we know that there is no more stack.
	while(ebp!=0) {
f0100b08:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0100b0c:	0f 85 37 ff ff ff    	jne    f0100a49 <mon_backtrace+0x25>
		cprintf("+%d", eip-info.eip_fn_addr);
		cprintf("\n");
		esp=ebp;
	}
	return 0;
}
f0100b12:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b17:	83 c4 4c             	add    $0x4c,%esp
f0100b1a:	5b                   	pop    %ebx
f0100b1b:	5e                   	pop    %esi
f0100b1c:	5f                   	pop    %edi
f0100b1d:	5d                   	pop    %ebp
f0100b1e:	c3                   	ret    
	...

f0100b20 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b20:	55                   	push   %ebp
f0100b21:	89 e5                	mov    %esp,%ebp
f0100b23:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b26:	89 d1                	mov    %edx,%ecx
f0100b28:	c1 e9 16             	shr    $0x16,%ecx
f0100b2b:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b2e:	a8 01                	test   $0x1,%al
f0100b30:	74 4d                	je     f0100b7f <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b32:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b37:	89 c1                	mov    %eax,%ecx
f0100b39:	c1 e9 0c             	shr    $0xc,%ecx
f0100b3c:	3b 0d 88 2e 23 f0    	cmp    0xf0232e88,%ecx
f0100b42:	72 20                	jb     f0100b64 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b44:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b48:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0100b4f:	f0 
f0100b50:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0100b57:	00 
f0100b58:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0100b5f:	e8 21 f5 ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b64:	c1 ea 0c             	shr    $0xc,%edx
f0100b67:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b6d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b74:	a8 01                	test   $0x1,%al
f0100b76:	74 07                	je     f0100b7f <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b78:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b7d:	eb 05                	jmp    f0100b84 <check_va2pa+0x64>
f0100b7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b84:	c9                   	leave  
f0100b85:	c3                   	ret    

f0100b86 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100b86:	55                   	push   %ebp
f0100b87:	89 e5                	mov    %esp,%ebp
f0100b89:	83 ec 18             	sub    $0x18,%esp
f0100b8c:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	DEBUG("page_free\n");
	if ( pp->pp_ref != 0) {
f0100b8f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100b94:	74 1c                	je     f0100bb2 <page_free+0x2c>
		panic("page_free: pp->pp_ref is nonzero!\n");
f0100b96:	c7 44 24 08 f0 71 10 	movl   $0xf01071f0,0x8(%esp)
f0100b9d:	f0 
f0100b9e:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
f0100ba5:	00 
f0100ba6:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0100bad:	e8 d3 f4 ff ff       	call   f0100085 <_panic>
	}
	if ( pp->pp_link !=NULL) {
f0100bb2:	83 38 00             	cmpl   $0x0,(%eax)
f0100bb5:	74 1c                	je     f0100bd3 <page_free+0x4d>
		panic("page_free: pp->pp_link is not NULL");
f0100bb7:	c7 44 24 08 14 72 10 	movl   $0xf0107214,0x8(%esp)
f0100bbe:	f0 
f0100bbf:	c7 44 24 04 a0 01 00 	movl   $0x1a0,0x4(%esp)
f0100bc6:	00 
f0100bc7:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0100bce:	e8 b2 f4 ff ff       	call   f0100085 <_panic>
	}
	pp->pp_link = page_free_list;
f0100bd3:	8b 15 30 22 23 f0    	mov    0xf0232230,%edx
f0100bd9:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100bdb:	a3 30 22 23 f0       	mov    %eax,0xf0232230

}
f0100be0:	c9                   	leave  
f0100be1:	c3                   	ret    

f0100be2 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100be2:	55                   	push   %ebp
f0100be3:	89 e5                	mov    %esp,%ebp
f0100be5:	83 ec 18             	sub    $0x18,%esp
f0100be8:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100beb:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100bef:	83 ea 01             	sub    $0x1,%edx
f0100bf2:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100bf6:	66 85 d2             	test   %dx,%dx
f0100bf9:	75 08                	jne    f0100c03 <page_decref+0x21>
		page_free(pp);
f0100bfb:	89 04 24             	mov    %eax,(%esp)
f0100bfe:	e8 83 ff ff ff       	call   f0100b86 <page_free>
}
f0100c03:	c9                   	leave  
f0100c04:	c3                   	ret    

f0100c05 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100c05:	55                   	push   %ebp
f0100c06:	89 e5                	mov    %esp,%ebp
f0100c08:	53                   	push   %ebx
f0100c09:	83 ec 14             	sub    $0x14,%esp
f0100c0c:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100c0e:	83 3d 28 22 23 f0 00 	cmpl   $0x0,0xf0232228
f0100c15:	75 61                	jne    f0100c78 <boot_alloc+0x73>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c17:	b8 07 50 27 f0       	mov    $0xf0275007,%eax
f0100c1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c21:	a3 28 22 23 f0       	mov    %eax,0xf0232228
		cprintf("the first time call boot_alloc nextfree: %08x\n",nextfree);
f0100c26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c2a:	c7 04 24 38 72 10 f0 	movl   $0xf0107238,(%esp)
f0100c31:	e8 e9 35 00 00       	call   f010421f <cprintf>
		cprintf("next free phsical address: %08x\n",PADDR(nextfree));
f0100c36:	a1 28 22 23 f0       	mov    0xf0232228,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c3b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100c40:	77 20                	ja     f0100c62 <boot_alloc+0x5d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c42:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c46:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0100c4d:	f0 
f0100c4e:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
f0100c55:	00 
f0100c56:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0100c5d:	e8 23 f4 ff ff       	call   f0100085 <_panic>
f0100c62:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0100c68:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c6c:	c7 04 24 68 72 10 f0 	movl   $0xf0107268,(%esp)
f0100c73:	e8 a7 35 00 00       	call   f010421f <cprintf>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if ( n == 0) {
f0100c78:	85 db                	test   %ebx,%ebx
f0100c7a:	75 07                	jne    f0100c83 <boot_alloc+0x7e>
		return nextfree;
f0100c7c:	a1 28 22 23 f0       	mov    0xf0232228,%eax
f0100c81:	eb 45                	jmp    f0100cc8 <boot_alloc+0xc3>
	}

	result = nextfree;
f0100c83:	a1 28 22 23 f0       	mov    0xf0232228,%eax
	newfreespace = ROUNDUP(n,PGSIZE);
f0100c88:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f0100c8e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	if(  (char*) (npages * PGSIZE) - result < newfreespace ) {
f0100c94:	8b 15 88 2e 23 f0    	mov    0xf0232e88,%edx
f0100c9a:	c1 e2 0c             	shl    $0xc,%edx
f0100c9d:	29 c2                	sub    %eax,%edx
f0100c9f:	39 d3                	cmp    %edx,%ebx
f0100ca1:	76 1c                	jbe    f0100cbf <boot_alloc+0xba>
		panic("boot_alloc: no enough space for new memory allocation!\n");
f0100ca3:	c7 44 24 08 8c 72 10 	movl   $0xf010728c,0x8(%esp)
f0100caa:	f0 
f0100cab:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
f0100cb2:	00 
f0100cb3:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0100cba:	e8 c6 f3 ff ff       	call   f0100085 <_panic>
	}
	else {
		nextfree += newfreespace;
f0100cbf:	8d 1c 18             	lea    (%eax,%ebx,1),%ebx
f0100cc2:	89 1d 28 22 23 f0    	mov    %ebx,0xf0232228
	}
	
	return result;
}
f0100cc8:	83 c4 14             	add    $0x14,%esp
f0100ccb:	5b                   	pop    %ebx
f0100ccc:	5d                   	pop    %ebp
f0100ccd:	c3                   	ret    

f0100cce <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100cce:	55                   	push   %ebp
f0100ccf:	89 e5                	mov    %esp,%ebp
f0100cd1:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100cd4:	e8 d5 58 00 00       	call   f01065ae <cpunum>
f0100cd9:	6b c0 74             	imul   $0x74,%eax,%eax
f0100cdc:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f0100ce3:	74 16                	je     f0100cfb <tlb_invalidate+0x2d>
f0100ce5:	e8 c4 58 00 00       	call   f01065ae <cpunum>
f0100cea:	6b c0 74             	imul   $0x74,%eax,%eax
f0100ced:	8b 90 28 30 23 f0    	mov    -0xfdccfd8(%eax),%edx
f0100cf3:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cf6:	39 42 60             	cmp    %eax,0x60(%edx)
f0100cf9:	75 06                	jne    f0100d01 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100cfe:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0100d01:	c9                   	leave  
f0100d02:	c3                   	ret    

f0100d03 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100d03:	55                   	push   %ebp
f0100d04:	89 e5                	mov    %esp,%ebp
f0100d06:	83 ec 18             	sub    $0x18,%esp
f0100d09:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100d0c:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100d0f:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100d11:	89 04 24             	mov    %eax,(%esp)
f0100d14:	e8 af 33 00 00       	call   f01040c8 <mc146818_read>
f0100d19:	89 c6                	mov    %eax,%esi
f0100d1b:	83 c3 01             	add    $0x1,%ebx
f0100d1e:	89 1c 24             	mov    %ebx,(%esp)
f0100d21:	e8 a2 33 00 00       	call   f01040c8 <mc146818_read>
f0100d26:	c1 e0 08             	shl    $0x8,%eax
f0100d29:	09 f0                	or     %esi,%eax
}
f0100d2b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100d2e:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100d31:	89 ec                	mov    %ebp,%esp
f0100d33:	5d                   	pop    %ebp
f0100d34:	c3                   	ret    

f0100d35 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0100d35:	55                   	push   %ebp
f0100d36:	89 e5                	mov    %esp,%ebp
f0100d38:	83 ec 18             	sub    $0x18,%esp
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100d3b:	b8 15 00 00 00       	mov    $0x15,%eax
f0100d40:	e8 be ff ff ff       	call   f0100d03 <nvram_read>
f0100d45:	c1 e0 0a             	shl    $0xa,%eax
f0100d48:	89 c2                	mov    %eax,%edx
f0100d4a:	c1 fa 1f             	sar    $0x1f,%edx
f0100d4d:	c1 ea 14             	shr    $0x14,%edx
f0100d50:	8d 04 02             	lea    (%edx,%eax,1),%eax
f0100d53:	c1 f8 0c             	sar    $0xc,%eax
f0100d56:	a3 2c 22 23 f0       	mov    %eax,0xf023222c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100d5b:	b8 17 00 00 00       	mov    $0x17,%eax
f0100d60:	e8 9e ff ff ff       	call   f0100d03 <nvram_read>
f0100d65:	89 c2                	mov    %eax,%edx
f0100d67:	c1 e2 0a             	shl    $0xa,%edx
f0100d6a:	89 d0                	mov    %edx,%eax
f0100d6c:	c1 f8 1f             	sar    $0x1f,%eax
f0100d6f:	c1 e8 14             	shr    $0x14,%eax
f0100d72:	01 d0                	add    %edx,%eax
f0100d74:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100d77:	85 c0                	test   %eax,%eax
f0100d79:	74 0e                	je     f0100d89 <i386_detect_memory+0x54>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100d7b:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100d81:	89 15 88 2e 23 f0    	mov    %edx,0xf0232e88
f0100d87:	eb 0c                	jmp    f0100d95 <i386_detect_memory+0x60>
	else
		npages = npages_basemem;
f0100d89:	8b 15 2c 22 23 f0    	mov    0xf023222c,%edx
f0100d8f:	89 15 88 2e 23 f0    	mov    %edx,0xf0232e88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100d95:	c1 e0 0c             	shl    $0xc,%eax
f0100d98:	c1 e8 0a             	shr    $0xa,%eax
f0100d9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d9f:	a1 2c 22 23 f0       	mov    0xf023222c,%eax
f0100da4:	c1 e0 0c             	shl    $0xc,%eax
f0100da7:	c1 e8 0a             	shr    $0xa,%eax
f0100daa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dae:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f0100db3:	c1 e0 0c             	shl    $0xc,%eax
f0100db6:	c1 e8 0a             	shr    $0xa,%eax
f0100db9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dbd:	c7 04 24 c4 72 10 f0 	movl   $0xf01072c4,(%esp)
f0100dc4:	e8 56 34 00 00       	call   f010421f <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
}
f0100dc9:	c9                   	leave  
f0100dca:	c3                   	ret    

f0100dcb <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100dcb:	55                   	push   %ebp
f0100dcc:	89 e5                	mov    %esp,%ebp
f0100dce:	56                   	push   %esi
f0100dcf:	53                   	push   %ebx
f0100dd0:	83 ec 10             	sub    $0x10,%esp
//		pages[i].pp_ref = 0;
//		pages[i].pp_link = page_free_list;
//		page_free_list = &pages[i];
//	}

	pages[0].pp_ref = 1;
f0100dd3:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
f0100dd8:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f0100dde:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
f0100de3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	for(i = 1;i< npages_basemem;i++) {
f0100de9:	8b 35 2c 22 23 f0    	mov    0xf023222c,%esi
f0100def:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100df4:	b8 01 00 00 00       	mov    $0x1,%eax
f0100df9:	eb 48                	jmp    f0100e43 <page_init+0x78>
		if (i==MPENTRY_PADDR/PGSIZE) {
f0100dfb:	83 f8 07             	cmp    $0x7,%eax
f0100dfe:	75 1b                	jne    f0100e1b <page_init+0x50>
			pages[i].pp_ref=1;
f0100e00:	8b 15 90 2e 23 f0    	mov    0xf0232e90,%edx
f0100e06:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
			pages[i].pp_link=NULL;
f0100e0c:	8b 15 90 2e 23 f0    	mov    0xf0232e90,%edx
f0100e12:	c7 42 38 00 00 00 00 	movl   $0x0,0x38(%edx)
			continue;
f0100e19:	eb 25                	jmp    f0100e40 <page_init+0x75>
f0100e1b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		}
		pages[i].pp_ref = 0;
f0100e22:	8b 1d 90 2e 23 f0    	mov    0xf0232e90,%ebx
f0100e28:	66 c7 44 13 04 00 00 	movw   $0x0,0x4(%ebx,%edx,1)
		pages[i].pp_link = page_free_list;
f0100e2f:	8b 1d 90 2e 23 f0    	mov    0xf0232e90,%ebx
f0100e35:	89 0c 13             	mov    %ecx,(%ebx,%edx,1)
		page_free_list = &pages[i];
f0100e38:	89 d1                	mov    %edx,%ecx
f0100e3a:	03 0d 90 2e 23 f0    	add    0xf0232e90,%ecx
//	}

	pages[0].pp_ref = 1;
	pages[0].pp_link = NULL;

	for(i = 1;i< npages_basemem;i++) {
f0100e40:	83 c0 01             	add    $0x1,%eax
f0100e43:	39 f0                	cmp    %esi,%eax
f0100e45:	72 b4                	jb     f0100dfb <page_init+0x30>
f0100e47:	89 0d 30 22 23 f0    	mov    %ecx,0xf0232230
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	for(i = PGNUM(PADDR(boot_alloc(0)));i < npages;i++) {
f0100e4d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e52:	e8 ae fd ff ff       	call   f0100c05 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e57:	89 c2                	mov    %eax,%edx
f0100e59:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e5e:	77 20                	ja     f0100e80 <page_init+0xb5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e60:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e64:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0100e6b:	f0 
f0100e6c:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f0100e73:	00 
f0100e74:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0100e7b:	e8 05 f2 ff ff       	call   f0100085 <_panic>
f0100e80:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100e86:	c1 ea 0c             	shr    $0xc,%edx
f0100e89:	8b 0d 30 22 23 f0    	mov    0xf0232230,%ecx
f0100e8f:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100e96:	eb 24                	jmp    f0100ebc <page_init+0xf1>
//		if (i==MPENTRY_PADDR/PGSIZE) {
//			continue;
//		}
		pages[i].pp_ref=0;
f0100e98:	8b 1d 90 2e 23 f0    	mov    0xf0232e90,%ebx
f0100e9e:	66 c7 44 03 04 00 00 	movw   $0x0,0x4(%ebx,%eax,1)
		pages[i].pp_link = page_free_list;
f0100ea5:	8b 1d 90 2e 23 f0    	mov    0xf0232e90,%ebx
f0100eab:	89 0c 03             	mov    %ecx,(%ebx,%eax,1)
		page_free_list = &pages[i];
f0100eae:	89 c1                	mov    %eax,%ecx
f0100eb0:	03 0d 90 2e 23 f0    	add    0xf0232e90,%ecx
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

	for(i = PGNUM(PADDR(boot_alloc(0)));i < npages;i++) {
f0100eb6:	83 c2 01             	add    $0x1,%edx
f0100eb9:	83 c0 08             	add    $0x8,%eax
f0100ebc:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0100ec2:	72 d4                	jb     f0100e98 <page_init+0xcd>
f0100ec4:	89 0d 30 22 23 f0    	mov    %ecx,0xf0232230
		pages[i].pp_ref=0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}

}
f0100eca:	83 c4 10             	add    $0x10,%esp
f0100ecd:	5b                   	pop    %ebx
f0100ece:	5e                   	pop    %esi
f0100ecf:	5d                   	pop    %ebp
f0100ed0:	c3                   	ret    

f0100ed1 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ed1:	55                   	push   %ebp
f0100ed2:	89 e5                	mov    %esp,%ebp
f0100ed4:	57                   	push   %edi
f0100ed5:	56                   	push   %esi
f0100ed6:	53                   	push   %ebx
f0100ed7:	83 ec 5c             	sub    $0x5c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100eda:	3c 01                	cmp    $0x1,%al
f0100edc:	19 f6                	sbb    %esi,%esi
f0100ede:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100ee4:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ee7:	8b 15 30 22 23 f0    	mov    0xf0232230,%edx
f0100eed:	85 d2                	test   %edx,%edx
f0100eef:	75 1c                	jne    f0100f0d <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100ef1:	c7 44 24 08 00 73 10 	movl   $0xf0107300,0x8(%esp)
f0100ef8:	f0 
f0100ef9:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0100f00:	00 
f0100f01:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0100f08:	e8 78 f1 ff ff       	call   f0100085 <_panic>

	if (only_low_memory) {
f0100f0d:	84 c0                	test   %al,%al
f0100f0f:	74 4d                	je     f0100f5e <check_page_free_list+0x8d>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100f11:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100f14:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f17:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100f1a:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f1d:	8b 1d 90 2e 23 f0    	mov    0xf0232e90,%ebx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f23:	89 d0                	mov    %edx,%eax
f0100f25:	29 d8                	sub    %ebx,%eax
f0100f27:	c1 e0 09             	shl    $0x9,%eax
f0100f2a:	c1 e8 16             	shr    $0x16,%eax
f0100f2d:	39 c6                	cmp    %eax,%esi
f0100f2f:	0f 96 c0             	setbe  %al
f0100f32:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100f35:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100f39:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100f3b:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f3f:	8b 12                	mov    (%edx),%edx
f0100f41:	85 d2                	test   %edx,%edx
f0100f43:	75 de                	jne    f0100f23 <check_page_free_list+0x52>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100f45:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f4e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100f51:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f54:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f59:	a3 30 22 23 f0       	mov    %eax,0xf0232230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f5e:	8b 1d 30 22 23 f0    	mov    0xf0232230,%ebx
f0100f64:	eb 63                	jmp    f0100fc9 <check_page_free_list+0xf8>
f0100f66:	89 d8                	mov    %ebx,%eax
f0100f68:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0100f6e:	c1 f8 03             	sar    $0x3,%eax
f0100f71:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100f74:	89 c2                	mov    %eax,%edx
f0100f76:	c1 ea 16             	shr    $0x16,%edx
f0100f79:	39 d6                	cmp    %edx,%esi
f0100f7b:	76 4a                	jbe    f0100fc7 <check_page_free_list+0xf6>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f7d:	89 c2                	mov    %eax,%edx
f0100f7f:	c1 ea 0c             	shr    $0xc,%edx
f0100f82:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0100f88:	72 20                	jb     f0100faa <check_page_free_list+0xd9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f8a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f8e:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0100f95:	f0 
f0100f96:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f9d:	00 
f0100f9e:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0100fa5:	e8 db f0 ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100faa:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100fb1:	00 
f0100fb2:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100fb9:	00 
f0100fba:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fbf:	89 04 24             	mov    %eax,(%esp)
f0100fc2:	e8 6a 4f 00 00       	call   f0105f31 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100fc7:	8b 1b                	mov    (%ebx),%ebx
f0100fc9:	85 db                	test   %ebx,%ebx
f0100fcb:	75 99                	jne    f0100f66 <check_page_free_list+0x95>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100fcd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd2:	e8 2e fc ff ff       	call   f0100c05 <boot_alloc>
f0100fd7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fda:	8b 15 30 22 23 f0    	mov    0xf0232230,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100fe0:	8b 1d 90 2e 23 f0    	mov    0xf0232e90,%ebx
		assert(pp < pages + npages);
f0100fe6:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f0100feb:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100fee:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100ff1:	89 45 cc             	mov    %eax,-0x34(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ff4:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0100ff7:	be 00 00 00 00       	mov    $0x0,%esi
f0100ffc:	bf 00 00 00 00       	mov    $0x0,%edi
f0101001:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101004:	e9 cd 01 00 00       	jmp    f01011d6 <check_page_free_list+0x305>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101009:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f010100c:	73 24                	jae    f0101032 <check_page_free_list+0x161>
f010100e:	c7 44 24 0c 39 7c 10 	movl   $0xf0107c39,0xc(%esp)
f0101015:	f0 
f0101016:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010101d:	f0 
f010101e:	c7 44 24 04 10 03 00 	movl   $0x310,0x4(%esp)
f0101025:	00 
f0101026:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010102d:	e8 53 f0 ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f0101032:	3b 55 cc             	cmp    -0x34(%ebp),%edx
f0101035:	72 24                	jb     f010105b <check_page_free_list+0x18a>
f0101037:	c7 44 24 0c 5a 7c 10 	movl   $0xf0107c5a,0xc(%esp)
f010103e:	f0 
f010103f:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101046:	f0 
f0101047:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f010104e:	00 
f010104f:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101056:	e8 2a f0 ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010105b:	89 d0                	mov    %edx,%eax
f010105d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101060:	a8 07                	test   $0x7,%al
f0101062:	74 24                	je     f0101088 <check_page_free_list+0x1b7>
f0101064:	c7 44 24 0c 24 73 10 	movl   $0xf0107324,0xc(%esp)
f010106b:	f0 
f010106c:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101073:	f0 
f0101074:	c7 44 24 04 12 03 00 	movl   $0x312,0x4(%esp)
f010107b:	00 
f010107c:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101083:	e8 fd ef ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101088:	c1 f8 03             	sar    $0x3,%eax
f010108b:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f010108e:	85 c0                	test   %eax,%eax
f0101090:	75 24                	jne    f01010b6 <check_page_free_list+0x1e5>
f0101092:	c7 44 24 0c 6e 7c 10 	movl   $0xf0107c6e,0xc(%esp)
f0101099:	f0 
f010109a:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01010a1:	f0 
f01010a2:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f01010a9:	00 
f01010aa:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01010b1:	e8 cf ef ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01010b6:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010bb:	75 24                	jne    f01010e1 <check_page_free_list+0x210>
f01010bd:	c7 44 24 0c 7f 7c 10 	movl   $0xf0107c7f,0xc(%esp)
f01010c4:	f0 
f01010c5:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01010cc:	f0 
f01010cd:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f01010d4:	00 
f01010d5:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01010dc:	e8 a4 ef ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01010e1:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01010e6:	75 24                	jne    f010110c <check_page_free_list+0x23b>
f01010e8:	c7 44 24 0c 58 73 10 	movl   $0xf0107358,0xc(%esp)
f01010ef:	f0 
f01010f0:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01010f7:	f0 
f01010f8:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f01010ff:	00 
f0101100:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101107:	e8 79 ef ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f010110c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101111:	75 24                	jne    f0101137 <check_page_free_list+0x266>
f0101113:	c7 44 24 0c 98 7c 10 	movl   $0xf0107c98,0xc(%esp)
f010111a:	f0 
f010111b:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101122:	f0 
f0101123:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f010112a:	00 
f010112b:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101132:	e8 4e ef ff ff       	call   f0100085 <_panic>
f0101137:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101139:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010113e:	76 59                	jbe    f0101199 <check_page_free_list+0x2c8>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101140:	89 c3                	mov    %eax,%ebx
f0101142:	c1 eb 0c             	shr    $0xc,%ebx
f0101145:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101148:	77 20                	ja     f010116a <check_page_free_list+0x299>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010114a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010114e:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0101155:	f0 
f0101156:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010115d:	00 
f010115e:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0101165:	e8 1b ef ff ff       	call   f0100085 <_panic>
f010116a:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0101170:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0101173:	76 24                	jbe    f0101199 <check_page_free_list+0x2c8>
f0101175:	c7 44 24 0c 7c 73 10 	movl   $0xf010737c,0xc(%esp)
f010117c:	f0 
f010117d:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101184:	f0 
f0101185:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f010118c:	00 
f010118d:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101194:	e8 ec ee ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0101199:	3d 00 70 00 00       	cmp    $0x7000,%eax
f010119e:	75 24                	jne    f01011c4 <check_page_free_list+0x2f3>
f01011a0:	c7 44 24 0c b2 7c 10 	movl   $0xf0107cb2,0xc(%esp)
f01011a7:	f0 
f01011a8:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01011af:	f0 
f01011b0:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01011b7:	00 
f01011b8:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01011bf:	e8 c1 ee ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f01011c4:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f01011ca:	77 05                	ja     f01011d1 <check_page_free_list+0x300>
			++nfree_basemem;
f01011cc:	83 c7 01             	add    $0x1,%edi
f01011cf:	eb 03                	jmp    f01011d4 <check_page_free_list+0x303>
		else
			++nfree_extmem;
f01011d1:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011d4:	8b 12                	mov    (%edx),%edx
f01011d6:	85 d2                	test   %edx,%edx
f01011d8:	0f 85 2b fe ff ff    	jne    f0101009 <check_page_free_list+0x138>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f01011de:	85 ff                	test   %edi,%edi
f01011e0:	7f 24                	jg     f0101206 <check_page_free_list+0x335>
f01011e2:	c7 44 24 0c cf 7c 10 	movl   $0xf0107ccf,0xc(%esp)
f01011e9:	f0 
f01011ea:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01011f1:	f0 
f01011f2:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01011f9:	00 
f01011fa:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101201:	e8 7f ee ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f0101206:	85 f6                	test   %esi,%esi
f0101208:	7f 24                	jg     f010122e <check_page_free_list+0x35d>
f010120a:	c7 44 24 0c e1 7c 10 	movl   $0xf0107ce1,0xc(%esp)
f0101211:	f0 
f0101212:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101219:	f0 
f010121a:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101221:	00 
f0101222:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101229:	e8 57 ee ff ff       	call   f0100085 <_panic>
}
f010122e:	83 c4 5c             	add    $0x5c,%esp
f0101231:	5b                   	pop    %ebx
f0101232:	5e                   	pop    %esi
f0101233:	5f                   	pop    %edi
f0101234:	5d                   	pop    %ebp
f0101235:	c3                   	ret    

f0101236 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0101236:	55                   	push   %ebp
f0101237:	89 e5                	mov    %esp,%ebp
f0101239:	53                   	push   %ebx
f010123a:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
//	DEBUG("page_alloc\n");
	struct PageInfo* result = NULL;
	if (!page_free_list ) {
f010123d:	8b 1d 30 22 23 f0    	mov    0xf0232230,%ebx
f0101243:	85 db                	test   %ebx,%ebx
f0101245:	74 6b                	je     f01012b2 <page_alloc+0x7c>
		DEBUG("page_alloc: There is no page_free_list!\n");
		return NULL;
	}

	result = page_free_list;
	page_free_list = page_free_list->pp_link;
f0101247:	8b 03                	mov    (%ebx),%eax
f0101249:	a3 30 22 23 f0       	mov    %eax,0xf0232230
	result->pp_link = NULL;
f010124e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if ( alloc_flags & ALLOC_ZERO ) {
f0101254:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101258:	74 58                	je     f01012b2 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010125a:	89 d8                	mov    %ebx,%eax
f010125c:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101262:	c1 f8 03             	sar    $0x3,%eax
f0101265:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101268:	89 c2                	mov    %eax,%edx
f010126a:	c1 ea 0c             	shr    $0xc,%edx
f010126d:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0101273:	72 20                	jb     f0101295 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101275:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101279:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0101280:	f0 
f0101281:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101288:	00 
f0101289:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0101290:	e8 f0 ed ff ff       	call   f0100085 <_panic>
		memset(page2kva(result),0,PGSIZE);
f0101295:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010129c:	00 
f010129d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012a4:	00 
f01012a5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012aa:	89 04 24             	mov    %eax,(%esp)
f01012ad:	e8 7f 4c 00 00       	call   f0105f31 <memset>
	}
//	DEBUG("page_alloc: after memset\n");
	
	return result;
}
f01012b2:	89 d8                	mov    %ebx,%eax
f01012b4:	83 c4 14             	add    $0x14,%esp
f01012b7:	5b                   	pop    %ebx
f01012b8:	5d                   	pop    %ebp
f01012b9:	c3                   	ret    

f01012ba <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01012ba:	55                   	push   %ebp
f01012bb:	89 e5                	mov    %esp,%ebp
f01012bd:	56                   	push   %esi
f01012be:	53                   	push   %ebx
f01012bf:	83 ec 10             	sub    $0x10,%esp
	// Fill this function in

	pde_t* result=NULL;
	if( pgdir[PDX(va)]==0  ) {
f01012c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012c5:	89 de                	mov    %ebx,%esi
f01012c7:	c1 ee 16             	shr    $0x16,%esi
f01012ca:	c1 e6 02             	shl    $0x2,%esi
f01012cd:	03 75 08             	add    0x8(%ebp),%esi
f01012d0:	8b 06                	mov    (%esi),%eax
f01012d2:	85 c0                	test   %eax,%eax
f01012d4:	75 78                	jne    f010134e <pgdir_walk+0x94>
		if ( create==0 ) {
f01012d6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01012da:	0f 84 d3 00 00 00    	je     f01013b3 <pgdir_walk+0xf9>
			return NULL;
		}
		else {
			struct PageInfo* newpage=page_alloc(1);
f01012e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01012e7:	e8 4a ff ff ff       	call   f0101236 <page_alloc>
			if ( newpage==NULL ) {
f01012ec:	85 c0                	test   %eax,%eax
f01012ee:	66 90                	xchg   %ax,%ax
f01012f0:	0f 84 bd 00 00 00    	je     f01013b3 <pgdir_walk+0xf9>
				return NULL;
			}	
			
			newpage->pp_ref++;
f01012f6:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[PDX(va)]=page2pa(newpage)|PTE_P|PTE_W|PTE_U;
f01012fb:	89 c2                	mov    %eax,%edx
f01012fd:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101303:	c1 fa 03             	sar    $0x3,%edx
f0101306:	c1 e2 0c             	shl    $0xc,%edx
f0101309:	83 ca 07             	or     $0x7,%edx
f010130c:	89 16                	mov    %edx,(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010130e:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101314:	c1 f8 03             	sar    $0x3,%eax
f0101317:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010131a:	89 c2                	mov    %eax,%edx
f010131c:	c1 ea 0c             	shr    $0xc,%edx
f010131f:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0101325:	72 20                	jb     f0101347 <pgdir_walk+0x8d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101327:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010132b:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0101332:	f0 
f0101333:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010133a:	00 
f010133b:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0101342:	e8 3e ed ff ff       	call   f0100085 <_panic>
			result = page2kva(newpage);
f0101347:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010134c:	eb 58                	jmp    f01013a6 <pgdir_walk+0xec>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010134e:	c1 e8 0c             	shr    $0xc,%eax
f0101351:	8b 15 88 2e 23 f0    	mov    0xf0232e88,%edx
f0101357:	39 d0                	cmp    %edx,%eax
f0101359:	72 1c                	jb     f0101377 <pgdir_walk+0xbd>
		panic("pa2page called with invalid pa");
f010135b:	c7 44 24 08 c4 73 10 	movl   $0xf01073c4,0x8(%esp)
f0101362:	f0 
f0101363:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010136a:	00 
f010136b:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0101372:	e8 0e ed ff ff       	call   f0100085 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101377:	89 c1                	mov    %eax,%ecx
f0101379:	c1 e1 0c             	shl    $0xc,%ecx
f010137c:	39 d0                	cmp    %edx,%eax
f010137e:	72 20                	jb     f01013a0 <pgdir_walk+0xe6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101380:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101384:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f010138b:	f0 
f010138c:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101393:	00 
f0101394:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f010139b:	e8 e5 ec ff ff       	call   f0100085 <_panic>
			
		}
	}	
	else {
		result =  page2kva(pa2page(PTE_ADDR((pgdir[PDX(va)])))) ;
f01013a0:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
	}

	return &result[PTX(va)];
f01013a6:	c1 eb 0a             	shr    $0xa,%ebx
f01013a9:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01013af:	01 d8                	add    %ebx,%eax
f01013b1:	eb 05                	jmp    f01013b8 <pgdir_walk+0xfe>
f01013b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013b8:	83 c4 10             	add    $0x10,%esp
f01013bb:	5b                   	pop    %ebx
f01013bc:	5e                   	pop    %esi
f01013bd:	5d                   	pop    %ebp
f01013be:	c3                   	ret    

f01013bf <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01013bf:	55                   	push   %ebp
f01013c0:	89 e5                	mov    %esp,%ebp
f01013c2:	57                   	push   %edi
f01013c3:	56                   	push   %esi
f01013c4:	53                   	push   %ebx
f01013c5:	83 ec 2c             	sub    $0x2c,%esp
f01013c8:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	pte_t* entry;
	uint32_t low=ROUNDDOWN((uint32_t)va,PGSIZE);
f01013cb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01013d1:	89 c3                	mov    %eax,%ebx
f01013d3:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t high=ROUNDUP((uint32_t)va+len,PGSIZE);
f01013d9:	03 45 10             	add    0x10(%ebp),%eax
f01013dc:	05 ff 0f 00 00       	add    $0xfff,%eax
f01013e1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01013e6:	89 45 e0             	mov    %eax,-0x20(%ebp)

	for(;low<high;low+=PGSIZE) {
		entry=pgdir_walk(env->env_pgdir,(void*)low,false);
		if (entry==NULL || low>=ULIM || (PGOFF(*entry) & PGOFF(perm|PTE_P))!=PGOFF(perm|PTE_P) ) {
f01013e9:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ec:	25 fe 0f 00 00       	and    $0xffe,%eax
f01013f1:	83 c8 01             	or     $0x1,%eax
f01013f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013f7:	89 c7                	mov    %eax,%edi
f01013f9:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
	// LAB 3: Your code here.
	pte_t* entry;
	uint32_t low=ROUNDDOWN((uint32_t)va,PGSIZE);
	uint32_t high=ROUNDUP((uint32_t)va+len,PGSIZE);

	for(;low<high;low+=PGSIZE) {
f01013ff:	eb 47                	jmp    f0101448 <user_mem_check+0x89>
		entry=pgdir_walk(env->env_pgdir,(void*)low,false);
f0101401:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101408:	00 
f0101409:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010140d:	8b 46 60             	mov    0x60(%esi),%eax
f0101410:	89 04 24             	mov    %eax,(%esp)
f0101413:	e8 a2 fe ff ff       	call   f01012ba <pgdir_walk>
		if (entry==NULL || low>=ULIM || (PGOFF(*entry) & PGOFF(perm|PTE_P))!=PGOFF(perm|PTE_P) ) {
f0101418:	85 c0                	test   %eax,%eax
f010141a:	74 11                	je     f010142d <user_mem_check+0x6e>
f010141c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101422:	77 09                	ja     f010142d <user_mem_check+0x6e>
f0101424:	8b 00                	mov    (%eax),%eax
f0101426:	21 f8                	and    %edi,%eax
f0101428:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f010142b:	74 15                	je     f0101442 <user_mem_check+0x83>
			user_mem_check_addr=(low<(uint32_t)va)?(uint32_t)va:low;
f010142d:	3b 5d dc             	cmp    -0x24(%ebp),%ebx
f0101430:	73 03                	jae    f0101435 <user_mem_check+0x76>
f0101432:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101435:	89 1d 34 22 23 f0    	mov    %ebx,0xf0232234
f010143b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;	
f0101440:	eb 10                	jmp    f0101452 <user_mem_check+0x93>
	// LAB 3: Your code here.
	pte_t* entry;
	uint32_t low=ROUNDDOWN((uint32_t)va,PGSIZE);
	uint32_t high=ROUNDUP((uint32_t)va+len,PGSIZE);

	for(;low<high;low+=PGSIZE) {
f0101442:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101448:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f010144b:	72 b4                	jb     f0101401 <user_mem_check+0x42>
f010144d:	b8 00 00 00 00       	mov    $0x0,%eax
			return -E_FAULT;	
		}
	}

	return 0;
}
f0101452:	83 c4 2c             	add    $0x2c,%esp
f0101455:	5b                   	pop    %ebx
f0101456:	5e                   	pop    %esi
f0101457:	5f                   	pop    %edi
f0101458:	5d                   	pop    %ebp
f0101459:	c3                   	ret    

f010145a <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010145a:	55                   	push   %ebp
f010145b:	89 e5                	mov    %esp,%ebp
f010145d:	53                   	push   %ebx
f010145e:	83 ec 14             	sub    $0x14,%esp
f0101461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int ret;
	if ( (ret=user_mem_check(env, va, len, perm | PTE_U)) < 0) {
f0101464:	8b 45 14             	mov    0x14(%ebp),%eax
f0101467:	83 c8 04             	or     $0x4,%eax
f010146a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010146e:	8b 45 10             	mov    0x10(%ebp),%eax
f0101471:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101475:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101478:	89 44 24 04          	mov    %eax,0x4(%esp)
f010147c:	89 1c 24             	mov    %ebx,(%esp)
f010147f:	e8 3b ff ff ff       	call   f01013bf <user_mem_check>
f0101484:	85 c0                	test   %eax,%eax
f0101486:	79 24                	jns    f01014ac <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101488:	a1 34 22 23 f0       	mov    0xf0232234,%eax
f010148d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101491:	8b 43 48             	mov    0x48(%ebx),%eax
f0101494:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101498:	c7 04 24 e4 73 10 f0 	movl   $0xf01073e4,(%esp)
f010149f:	e8 7b 2d 00 00       	call   f010421f <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01014a4:	89 1c 24             	mov    %ebx,(%esp)
f01014a7:	e8 94 27 00 00       	call   f0103c40 <env_destroy>
	}
//	cprintf("user_mem_check: %d\n",ret);
}
f01014ac:	83 c4 14             	add    $0x14,%esp
f01014af:	5b                   	pop    %ebx
f01014b0:	5d                   	pop    %ebp
f01014b1:	c3                   	ret    

f01014b2 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01014b2:	55                   	push   %ebp
f01014b3:	89 e5                	mov    %esp,%ebp
f01014b5:	57                   	push   %edi
f01014b6:	56                   	push   %esi
f01014b7:	53                   	push   %ebx
f01014b8:	83 ec 2c             	sub    $0x2c,%esp
f01014bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	// Fill this function in
	uintptr_t nextva=va;
	physaddr_t nextpa=pa;
	uint32_t wholesize=ROUNDUP(size,PGSIZE);	
f01014be:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
	int temp;
	pte_t* pte;
	
	for(temp=0;temp<wholesize/PGSIZE;temp++) {
f01014c4:	c1 e9 0c             	shr    $0xc,%ecx
f01014c7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01014ca:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014cd:	89 d3                	mov    %edx,%ebx
f01014cf:	be 00 00 00 00       	mov    $0x0,%esi
		pte=pgdir_walk(pgdir,(const void*) nextva,1);
		if(!pte) {
			panic("boot_map_region: not enough memory for allocation\n");
			return ;
		}
		pte[0]= PTE_ADDR(nextpa) | perm | PTE_P;
f01014d4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014d7:	83 c8 01             	or     $0x1,%eax
f01014da:	89 45 dc             	mov    %eax,-0x24(%ebp)
	physaddr_t nextpa=pa;
	uint32_t wholesize=ROUNDUP(size,PGSIZE);	
	int temp;
	pte_t* pte;
	
	for(temp=0;temp<wholesize/PGSIZE;temp++) {
f01014dd:	eb 53                	jmp    f0101532 <boot_map_region+0x80>
		pte=pgdir_walk(pgdir,(const void*) nextva,1);
f01014df:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01014e6:	00 
f01014e7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01014eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01014ee:	89 04 24             	mov    %eax,(%esp)
f01014f1:	e8 c4 fd ff ff       	call   f01012ba <pgdir_walk>
		if(!pte) {
f01014f6:	85 c0                	test   %eax,%eax
f01014f8:	75 1c                	jne    f0101516 <boot_map_region+0x64>
			panic("boot_map_region: not enough memory for allocation\n");
f01014fa:	c7 44 24 08 1c 74 10 	movl   $0xf010741c,0x8(%esp)
f0101501:	f0 
f0101502:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
f0101509:	00 
f010150a:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101511:	e8 6f eb ff ff       	call   f0100085 <_panic>
			return ;
		}
		pte[0]= PTE_ADDR(nextpa) | perm | PTE_P;
f0101516:	89 fa                	mov    %edi,%edx
f0101518:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010151e:	0b 55 dc             	or     -0x24(%ebp),%edx
f0101521:	89 10                	mov    %edx,(%eax)
		nextpa += PGSIZE;
f0101523:	81 c7 00 10 00 00    	add    $0x1000,%edi
		nextva +=PGSIZE;
f0101529:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	physaddr_t nextpa=pa;
	uint32_t wholesize=ROUNDUP(size,PGSIZE);	
	int temp;
	pte_t* pte;
	
	for(temp=0;temp<wholesize/PGSIZE;temp++) {
f010152f:	83 c6 01             	add    $0x1,%esi
f0101532:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101535:	72 a8                	jb     f01014df <boot_map_region+0x2d>
		}
		pte[0]= PTE_ADDR(nextpa) | perm | PTE_P;
		nextpa += PGSIZE;
		nextva +=PGSIZE;
	}	
}
f0101537:	83 c4 2c             	add    $0x2c,%esp
f010153a:	5b                   	pop    %ebx
f010153b:	5e                   	pop    %esi
f010153c:	5f                   	pop    %edi
f010153d:	5d                   	pop    %ebp
f010153e:	c3                   	ret    

f010153f <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010153f:	55                   	push   %ebp
f0101540:	89 e5                	mov    %esp,%ebp
f0101542:	83 ec 18             	sub    $0x18,%esp
f0101545:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101548:	89 75 fc             	mov    %esi,-0x4(%ebp)
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
//	panic("mmio_map_region not implemented");
	void* res=(void*)base;
f010154b:	8b 1d 00 13 12 f0    	mov    0xf0121300,%ebx
	size = ROUNDUP(size,PGSIZE);
f0101551:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101554:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f010155a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (base+size> MMIOLIM ) {
f0101560:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101563:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f0101568:	76 1c                	jbe    f0101586 <mmio_map_region+0x47>
		panic("mio_map_region: Overflow the MMIOLIM\n");
f010156a:	c7 44 24 08 50 74 10 	movl   $0xf0107450,0x8(%esp)
f0101571:	f0 
f0101572:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f0101579:	00 
f010157a:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101581:	e8 ff ea ff ff       	call   f0100085 <_panic>
	}
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_P | PTE_W | PTE_P);
f0101586:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
f010158d:	00 
f010158e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101591:	89 04 24             	mov    %eax,(%esp)
f0101594:	89 f1                	mov    %esi,%ecx
f0101596:	89 da                	mov    %ebx,%edx
f0101598:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010159d:	e8 10 ff ff ff       	call   f01014b2 <boot_map_region>
	base+=size;
f01015a2:	01 35 00 13 12 f0    	add    %esi,0xf0121300
	return res;
}
f01015a8:	89 d8                	mov    %ebx,%eax
f01015aa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01015ad:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01015b0:	89 ec                	mov    %ebp,%esp
f01015b2:	5d                   	pop    %ebp
f01015b3:	c3                   	ret    

f01015b4 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01015b4:	55                   	push   %ebp
f01015b5:	89 e5                	mov    %esp,%ebp
f01015b7:	53                   	push   %ebx
f01015b8:	83 ec 14             	sub    $0x14,%esp
f01015bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t* pte=pgdir_walk(pgdir, va, 0);
f01015be:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01015c5:	00 
f01015c6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01015c9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01015cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01015d0:	89 04 24             	mov    %eax,(%esp)
f01015d3:	e8 e2 fc ff ff       	call   f01012ba <pgdir_walk>
	if( pte==NULL ) {
f01015d8:	85 c0                	test   %eax,%eax
f01015da:	74 3e                	je     f010161a <page_lookup+0x66>
		return NULL;
	}
	
	if ( pte_store!=0 ) {
f01015dc:	85 db                	test   %ebx,%ebx
f01015de:	74 02                	je     f01015e2 <page_lookup+0x2e>
		*pte_store=pte;
f01015e0:	89 03                	mov    %eax,(%ebx)
	}
	if ( pte[0] == 0 ) {
f01015e2:	8b 00                	mov    (%eax),%eax
f01015e4:	85 c0                	test   %eax,%eax
f01015e6:	74 32                	je     f010161a <page_lookup+0x66>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015e8:	c1 e8 0c             	shr    $0xc,%eax
f01015eb:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f01015f1:	72 1c                	jb     f010160f <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01015f3:	c7 44 24 08 c4 73 10 	movl   $0xf01073c4,0x8(%esp)
f01015fa:	f0 
f01015fb:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0101602:	00 
f0101603:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f010160a:	e8 76 ea ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f010160f:	c1 e0 03             	shl    $0x3,%eax
f0101612:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
		return NULL;
	}

	return pa2page(PTE_ADDR(pte[0]));
f0101618:	eb 05                	jmp    f010161f <page_lookup+0x6b>
f010161a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010161f:	83 c4 14             	add    $0x14,%esp
f0101622:	5b                   	pop    %ebx
f0101623:	5d                   	pop    %ebp
f0101624:	c3                   	ret    

f0101625 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101625:	55                   	push   %ebp
f0101626:	89 e5                	mov    %esp,%ebp
f0101628:	83 ec 28             	sub    $0x28,%esp
f010162b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f010162e:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101631:	8b 75 08             	mov    0x8(%ebp),%esi
f0101634:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte=NULL;
f0101637:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *page=page_lookup(pgdir,va,&pte);
f010163e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101641:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101645:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101649:	89 34 24             	mov    %esi,(%esp)
f010164c:	e8 63 ff ff ff       	call   f01015b4 <page_lookup>
	if( page==NULL ) {
f0101651:	85 c0                	test   %eax,%eax
f0101653:	74 1d                	je     f0101672 <page_remove+0x4d>
		return;
	}
	page_decref(page);
f0101655:	89 04 24             	mov    %eax,(%esp)
f0101658:	e8 85 f5 ff ff       	call   f0100be2 <page_decref>
	pte[0]=0;
f010165d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101660:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir,va);
f0101666:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010166a:	89 34 24             	mov    %esi,(%esp)
f010166d:	e8 5c f6 ff ff       	call   f0100cce <tlb_invalidate>
}
f0101672:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101675:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101678:	89 ec                	mov    %ebp,%esp
f010167a:	5d                   	pop    %ebp
f010167b:	c3                   	ret    

f010167c <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010167c:	55                   	push   %ebp
f010167d:	89 e5                	mov    %esp,%ebp
f010167f:	83 ec 28             	sub    $0x28,%esp
f0101682:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101685:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101688:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010168b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010168e:	8b 75 10             	mov    0x10(%ebp),%esi
	// Fill this function in
	DEBUG("page_insert: just enter\n");	
	pte_t* pte = pgdir_walk(pgdir,va,1); 
f0101691:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101698:	00 
f0101699:	89 74 24 04          	mov    %esi,0x4(%esp)
f010169d:	89 3c 24             	mov    %edi,(%esp)
f01016a0:	e8 15 fc ff ff       	call   f01012ba <pgdir_walk>
f01016a5:	89 c3                	mov    %eax,%ebx
	DEBUG("page_insert: after pgdir_walk\n");
	if ( pte ){
f01016a7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01016ac:	85 db                	test   %ebx,%ebx
f01016ae:	74 3e                	je     f01016ee <page_insert+0x72>
		pp->pp_ref++;
f01016b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01016b3:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		page_remove(pgdir,va);	
f01016b8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01016bc:	89 3c 24             	mov    %edi,(%esp)
f01016bf:	e8 61 ff ff ff       	call   f0101625 <page_remove>
	}
	else {
		return -E_NO_MEM;
	}	

	pte[0]=page2pa(pp)|perm|PTE_P;
f01016c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01016c7:	83 c8 01             	or     $0x1,%eax
f01016ca:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016cd:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f01016d3:	c1 fa 03             	sar    $0x3,%edx
f01016d6:	c1 e2 0c             	shl    $0xc,%edx
f01016d9:	09 d0                	or     %edx,%eax
f01016db:	89 03                	mov    %eax,(%ebx)
	DEBUG("page_insert: after assign new phaddr to pte\n");

	tlb_invalidate(pgdir,va);
f01016dd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01016e1:	89 3c 24             	mov    %edi,(%esp)
f01016e4:	e8 e5 f5 ff ff       	call   f0100cce <tlb_invalidate>
f01016e9:	b8 00 00 00 00       	mov    $0x0,%eax

	DEBUG("page_insert: after tlb_invalidate\n");

	return 0;
}
f01016ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01016f1:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01016f4:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01016f7:	89 ec                	mov    %ebp,%esp
f01016f9:	5d                   	pop    %ebp
f01016fa:	c3                   	ret    

f01016fb <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f01016fb:	55                   	push   %ebp
f01016fc:	89 e5                	mov    %esp,%ebp
f01016fe:	57                   	push   %edi
f01016ff:	56                   	push   %esi
f0101700:	53                   	push   %ebx
f0101701:	83 ec 2c             	sub    $0x2c,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101704:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010170b:	e8 26 fb ff ff       	call   f0101236 <page_alloc>
f0101710:	89 c3                	mov    %eax,%ebx
f0101712:	85 c0                	test   %eax,%eax
f0101714:	75 24                	jne    f010173a <check_page_installed_pgdir+0x3f>
f0101716:	c7 44 24 0c f2 7c 10 	movl   $0xf0107cf2,0xc(%esp)
f010171d:	f0 
f010171e:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101725:	f0 
f0101726:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f010172d:	00 
f010172e:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101735:	e8 4b e9 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f010173a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101741:	e8 f0 fa ff ff       	call   f0101236 <page_alloc>
f0101746:	89 c7                	mov    %eax,%edi
f0101748:	85 c0                	test   %eax,%eax
f010174a:	75 24                	jne    f0101770 <check_page_installed_pgdir+0x75>
f010174c:	c7 44 24 0c 08 7d 10 	movl   $0xf0107d08,0xc(%esp)
f0101753:	f0 
f0101754:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010175b:	f0 
f010175c:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0101763:	00 
f0101764:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010176b:	e8 15 e9 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101770:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101777:	e8 ba fa ff ff       	call   f0101236 <page_alloc>
f010177c:	89 c6                	mov    %eax,%esi
f010177e:	85 c0                	test   %eax,%eax
f0101780:	75 24                	jne    f01017a6 <check_page_installed_pgdir+0xab>
f0101782:	c7 44 24 0c 1e 7d 10 	movl   $0xf0107d1e,0xc(%esp)
f0101789:	f0 
f010178a:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101791:	f0 
f0101792:	c7 44 24 04 87 04 00 	movl   $0x487,0x4(%esp)
f0101799:	00 
f010179a:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01017a1:	e8 df e8 ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f01017a6:	89 1c 24             	mov    %ebx,(%esp)
f01017a9:	e8 d8 f3 ff ff       	call   f0100b86 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01017ae:	89 f8                	mov    %edi,%eax
f01017b0:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f01017b6:	c1 f8 03             	sar    $0x3,%eax
f01017b9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017bc:	89 c2                	mov    %eax,%edx
f01017be:	c1 ea 0c             	shr    $0xc,%edx
f01017c1:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f01017c7:	72 20                	jb     f01017e9 <check_page_installed_pgdir+0xee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017cd:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f01017d4:	f0 
f01017d5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01017dc:	00 
f01017dd:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f01017e4:	e8 9c e8 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01017e9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017f0:	00 
f01017f1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01017f8:	00 
f01017f9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01017fe:	89 04 24             	mov    %eax,(%esp)
f0101801:	e8 2b 47 00 00       	call   f0105f31 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101806:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0101809:	89 f0                	mov    %esi,%eax
f010180b:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101811:	c1 f8 03             	sar    $0x3,%eax
f0101814:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101817:	89 c2                	mov    %eax,%edx
f0101819:	c1 ea 0c             	shr    $0xc,%edx
f010181c:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0101822:	72 20                	jb     f0101844 <check_page_installed_pgdir+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101824:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101828:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f010182f:	f0 
f0101830:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101837:	00 
f0101838:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f010183f:	e8 41 e8 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0101844:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010184b:	00 
f010184c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0101853:	00 
f0101854:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101859:	89 04 24             	mov    %eax,(%esp)
f010185c:	e8 d0 46 00 00       	call   f0105f31 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0101861:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101868:	00 
f0101869:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101870:	00 
f0101871:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101875:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010187a:	89 04 24             	mov    %eax,(%esp)
f010187d:	e8 fa fd ff ff       	call   f010167c <page_insert>
	assert(pp1->pp_ref == 1);
f0101882:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101887:	74 24                	je     f01018ad <check_page_installed_pgdir+0x1b2>
f0101889:	c7 44 24 0c 34 7d 10 	movl   $0xf0107d34,0xc(%esp)
f0101890:	f0 
f0101891:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101898:	f0 
f0101899:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f01018a0:	00 
f01018a1:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01018a8:	e8 d8 e7 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01018ad:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01018b4:	01 01 01 
f01018b7:	74 24                	je     f01018dd <check_page_installed_pgdir+0x1e2>
f01018b9:	c7 44 24 0c 78 74 10 	movl   $0xf0107478,0xc(%esp)
f01018c0:	f0 
f01018c1:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01018c8:	f0 
f01018c9:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f01018d0:	00 
f01018d1:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01018d8:	e8 a8 e7 ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01018dd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01018e4:	00 
f01018e5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01018ec:	00 
f01018ed:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018f1:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01018f6:	89 04 24             	mov    %eax,(%esp)
f01018f9:	e8 7e fd ff ff       	call   f010167c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01018fe:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0101905:	02 02 02 
f0101908:	74 24                	je     f010192e <check_page_installed_pgdir+0x233>
f010190a:	c7 44 24 0c 9c 74 10 	movl   $0xf010749c,0xc(%esp)
f0101911:	f0 
f0101912:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101919:	f0 
f010191a:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f0101921:	00 
f0101922:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101929:	e8 57 e7 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010192e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101933:	74 24                	je     f0101959 <check_page_installed_pgdir+0x25e>
f0101935:	c7 44 24 0c 45 7d 10 	movl   $0xf0107d45,0xc(%esp)
f010193c:	f0 
f010193d:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101944:	f0 
f0101945:	c7 44 24 04 90 04 00 	movl   $0x490,0x4(%esp)
f010194c:	00 
f010194d:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101954:	e8 2c e7 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0101959:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010195e:	74 24                	je     f0101984 <check_page_installed_pgdir+0x289>
f0101960:	c7 44 24 0c 56 7d 10 	movl   $0xf0107d56,0xc(%esp)
f0101967:	f0 
f0101968:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010196f:	f0 
f0101970:	c7 44 24 04 91 04 00 	movl   $0x491,0x4(%esp)
f0101977:	00 
f0101978:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010197f:	e8 01 e7 ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0101984:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010198b:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010198e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101991:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101997:	c1 f8 03             	sar    $0x3,%eax
f010199a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010199d:	89 c2                	mov    %eax,%edx
f010199f:	c1 ea 0c             	shr    $0xc,%edx
f01019a2:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f01019a8:	72 20                	jb     f01019ca <check_page_installed_pgdir+0x2cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01019aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01019ae:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f01019b5:	f0 
f01019b6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01019bd:	00 
f01019be:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f01019c5:	e8 bb e6 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01019ca:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01019d1:	03 03 03 
f01019d4:	74 24                	je     f01019fa <check_page_installed_pgdir+0x2ff>
f01019d6:	c7 44 24 0c c0 74 10 	movl   $0xf01074c0,0xc(%esp)
f01019dd:	f0 
f01019de:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01019e5:	f0 
f01019e6:	c7 44 24 04 93 04 00 	movl   $0x493,0x4(%esp)
f01019ed:	00 
f01019ee:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01019f5:	e8 8b e6 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01019fa:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101a01:	00 
f0101a02:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101a07:	89 04 24             	mov    %eax,(%esp)
f0101a0a:	e8 16 fc ff ff       	call   f0101625 <page_remove>
	assert(pp2->pp_ref == 0);
f0101a0f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101a14:	74 24                	je     f0101a3a <check_page_installed_pgdir+0x33f>
f0101a16:	c7 44 24 0c 67 7d 10 	movl   $0xf0107d67,0xc(%esp)
f0101a1d:	f0 
f0101a1e:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101a25:	f0 
f0101a26:	c7 44 24 04 95 04 00 	movl   $0x495,0x4(%esp)
f0101a2d:	00 
f0101a2e:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101a35:	e8 4b e6 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a3a:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0101a3f:	8b 08                	mov    (%eax),%ecx
f0101a41:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101a47:	89 da                	mov    %ebx,%edx
f0101a49:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101a4f:	c1 fa 03             	sar    $0x3,%edx
f0101a52:	c1 e2 0c             	shl    $0xc,%edx
f0101a55:	39 d1                	cmp    %edx,%ecx
f0101a57:	74 24                	je     f0101a7d <check_page_installed_pgdir+0x382>
f0101a59:	c7 44 24 0c ec 74 10 	movl   $0xf01074ec,0xc(%esp)
f0101a60:	f0 
f0101a61:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101a68:	f0 
f0101a69:	c7 44 24 04 98 04 00 	movl   $0x498,0x4(%esp)
f0101a70:	00 
f0101a71:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101a78:	e8 08 e6 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0101a7d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0101a83:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a88:	74 24                	je     f0101aae <check_page_installed_pgdir+0x3b3>
f0101a8a:	c7 44 24 0c 78 7d 10 	movl   $0xf0107d78,0xc(%esp)
f0101a91:	f0 
f0101a92:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101a99:	f0 
f0101a9a:	c7 44 24 04 9a 04 00 	movl   $0x49a,0x4(%esp)
f0101aa1:	00 
f0101aa2:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101aa9:	e8 d7 e5 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0101aae:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0101ab4:	89 1c 24             	mov    %ebx,(%esp)
f0101ab7:	e8 ca f0 ff ff       	call   f0100b86 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0101abc:	c7 04 24 14 75 10 f0 	movl   $0xf0107514,(%esp)
f0101ac3:	e8 57 27 00 00       	call   f010421f <cprintf>
}
f0101ac8:	83 c4 2c             	add    $0x2c,%esp
f0101acb:	5b                   	pop    %ebx
f0101acc:	5e                   	pop    %esi
f0101acd:	5f                   	pop    %edi
f0101ace:	5d                   	pop    %ebp
f0101acf:	c3                   	ret    

f0101ad0 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101ad0:	55                   	push   %ebp
f0101ad1:	89 e5                	mov    %esp,%ebp
f0101ad3:	57                   	push   %edi
f0101ad4:	56                   	push   %esi
f0101ad5:	53                   	push   %ebx
f0101ad6:	83 ec 3c             	sub    $0x3c,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f0101ad9:	e8 57 f2 ff ff       	call   f0100d35 <i386_detect_memory>
	// Remove this line when you're ready to test this function.
//	panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101ade:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101ae3:	e8 1d f1 ff ff       	call   f0100c05 <boot_alloc>
f0101ae8:	a3 8c 2e 23 f0       	mov    %eax,0xf0232e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101aed:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101af4:	00 
f0101af5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101afc:	00 
f0101afd:	89 04 24             	mov    %eax,(%esp)
f0101b00:	e8 2c 44 00 00       	call   f0105f31 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101b05:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101b0a:	89 c2                	mov    %eax,%edx
f0101b0c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101b11:	77 20                	ja     f0101b33 <mem_init+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101b13:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b17:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0101b1e:	f0 
f0101b1f:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
f0101b26:	00 
f0101b27:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101b2e:	e8 52 e5 ff ff       	call   f0100085 <_panic>
f0101b33:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101b39:	83 ca 05             	or     $0x5,%edx
f0101b3c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
//	DEBUG("Before pages array are allocated!\n");
	pages = (struct PageInfo*)boot_alloc(npages*sizeof(struct PageInfo));
f0101b42:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f0101b47:	c1 e0 03             	shl    $0x3,%eax
f0101b4a:	e8 b6 f0 ff ff       	call   f0100c05 <boot_alloc>
f0101b4f:	a3 90 2e 23 f0       	mov    %eax,0xf0232e90
	memset(pages,0,npages*sizeof(struct PageInfo));
f0101b54:	8b 15 88 2e 23 f0    	mov    0xf0232e88,%edx
f0101b5a:	c1 e2 03             	shl    $0x3,%edx
f0101b5d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101b61:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b68:	00 
f0101b69:	89 04 24             	mov    %eax,(%esp)
f0101b6c:	e8 c0 43 00 00       	call   f0105f31 <memset>
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env*)boot_alloc(NENV*sizeof(struct Env));	
f0101b71:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101b76:	e8 8a f0 ff ff       	call   f0100c05 <boot_alloc>
f0101b7b:	a3 38 22 23 f0       	mov    %eax,0xf0232238
	memset(envs,0,NENV*sizeof(struct Env));
f0101b80:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0101b87:	00 
f0101b88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101b8f:	00 
f0101b90:	89 04 24             	mov    %eax,(%esp)
f0101b93:	e8 99 43 00 00       	call   f0105f31 <memset>
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
//	DEBUG("Before page_init!\n");
	page_init();
f0101b98:	e8 2e f2 ff ff       	call   f0100dcb <page_init>
//	DEBUG("Before Check page free list!\n");
	check_page_free_list(1);
f0101b9d:	b8 01 00 00 00       	mov    $0x1,%eax
f0101ba2:	e8 2a f3 ff ff       	call   f0100ed1 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101ba7:	83 3d 90 2e 23 f0 00 	cmpl   $0x0,0xf0232e90
f0101bae:	75 1c                	jne    f0101bcc <mem_init+0xfc>
		panic("'pages' is a null pointer!");
f0101bb0:	c7 44 24 08 89 7d 10 	movl   $0xf0107d89,0x8(%esp)
f0101bb7:	f0 
f0101bb8:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101bbf:	00 
f0101bc0:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101bc7:	e8 b9 e4 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101bcc:	a1 30 22 23 f0       	mov    0xf0232230,%eax
f0101bd1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101bd6:	eb 05                	jmp    f0101bdd <mem_init+0x10d>
		++nfree;
f0101bd8:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101bdb:	8b 00                	mov    (%eax),%eax
f0101bdd:	85 c0                	test   %eax,%eax
f0101bdf:	75 f7                	jne    f0101bd8 <mem_init+0x108>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101be1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101be8:	e8 49 f6 ff ff       	call   f0101236 <page_alloc>
f0101bed:	89 c6                	mov    %eax,%esi
f0101bef:	85 c0                	test   %eax,%eax
f0101bf1:	75 24                	jne    f0101c17 <mem_init+0x147>
f0101bf3:	c7 44 24 0c f2 7c 10 	movl   $0xf0107cf2,0xc(%esp)
f0101bfa:	f0 
f0101bfb:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101c02:	f0 
f0101c03:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101c0a:	00 
f0101c0b:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101c12:	e8 6e e4 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101c17:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c1e:	e8 13 f6 ff ff       	call   f0101236 <page_alloc>
f0101c23:	89 c7                	mov    %eax,%edi
f0101c25:	85 c0                	test   %eax,%eax
f0101c27:	75 24                	jne    f0101c4d <mem_init+0x17d>
f0101c29:	c7 44 24 0c 08 7d 10 	movl   $0xf0107d08,0xc(%esp)
f0101c30:	f0 
f0101c31:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101c38:	f0 
f0101c39:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0101c40:	00 
f0101c41:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101c48:	e8 38 e4 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101c4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c54:	e8 dd f5 ff ff       	call   f0101236 <page_alloc>
f0101c59:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c5c:	85 c0                	test   %eax,%eax
f0101c5e:	75 24                	jne    f0101c84 <mem_init+0x1b4>
f0101c60:	c7 44 24 0c 1e 7d 10 	movl   $0xf0107d1e,0xc(%esp)
f0101c67:	f0 
f0101c68:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101c6f:	f0 
f0101c70:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101c77:	00 
f0101c78:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101c7f:	e8 01 e4 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c84:	39 fe                	cmp    %edi,%esi
f0101c86:	75 24                	jne    f0101cac <mem_init+0x1dc>
f0101c88:	c7 44 24 0c a4 7d 10 	movl   $0xf0107da4,0xc(%esp)
f0101c8f:	f0 
f0101c90:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101c97:	f0 
f0101c98:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0101c9f:	00 
f0101ca0:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101ca7:	e8 d9 e3 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101cac:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101caf:	74 05                	je     f0101cb6 <mem_init+0x1e6>
f0101cb1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101cb4:	75 24                	jne    f0101cda <mem_init+0x20a>
f0101cb6:	c7 44 24 0c 40 75 10 	movl   $0xf0107540,0xc(%esp)
f0101cbd:	f0 
f0101cbe:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101cc5:	f0 
f0101cc6:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f0101ccd:	00 
f0101cce:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101cd5:	e8 ab e3 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101cda:	8b 15 90 2e 23 f0    	mov    0xf0232e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101ce0:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f0101ce5:	c1 e0 0c             	shl    $0xc,%eax
f0101ce8:	89 f1                	mov    %esi,%ecx
f0101cea:	29 d1                	sub    %edx,%ecx
f0101cec:	c1 f9 03             	sar    $0x3,%ecx
f0101cef:	c1 e1 0c             	shl    $0xc,%ecx
f0101cf2:	39 c1                	cmp    %eax,%ecx
f0101cf4:	72 24                	jb     f0101d1a <mem_init+0x24a>
f0101cf6:	c7 44 24 0c b6 7d 10 	movl   $0xf0107db6,0xc(%esp)
f0101cfd:	f0 
f0101cfe:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101d05:	f0 
f0101d06:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101d0d:	00 
f0101d0e:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101d15:	e8 6b e3 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101d1a:	89 f9                	mov    %edi,%ecx
f0101d1c:	29 d1                	sub    %edx,%ecx
f0101d1e:	c1 f9 03             	sar    $0x3,%ecx
f0101d21:	c1 e1 0c             	shl    $0xc,%ecx
f0101d24:	39 c8                	cmp    %ecx,%eax
f0101d26:	77 24                	ja     f0101d4c <mem_init+0x27c>
f0101d28:	c7 44 24 0c d3 7d 10 	movl   $0xf0107dd3,0xc(%esp)
f0101d2f:	f0 
f0101d30:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101d37:	f0 
f0101d38:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101d3f:	00 
f0101d40:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101d47:	e8 39 e3 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101d4c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d4f:	29 d1                	sub    %edx,%ecx
f0101d51:	89 ca                	mov    %ecx,%edx
f0101d53:	c1 fa 03             	sar    $0x3,%edx
f0101d56:	c1 e2 0c             	shl    $0xc,%edx
f0101d59:	39 d0                	cmp    %edx,%eax
f0101d5b:	77 24                	ja     f0101d81 <mem_init+0x2b1>
f0101d5d:	c7 44 24 0c f0 7d 10 	movl   $0xf0107df0,0xc(%esp)
f0101d64:	f0 
f0101d65:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101d6c:	f0 
f0101d6d:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101d74:	00 
f0101d75:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101d7c:	e8 04 e3 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101d81:	a1 30 22 23 f0       	mov    0xf0232230,%eax
f0101d86:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101d89:	c7 05 30 22 23 f0 00 	movl   $0x0,0xf0232230
f0101d90:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101d93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d9a:	e8 97 f4 ff ff       	call   f0101236 <page_alloc>
f0101d9f:	85 c0                	test   %eax,%eax
f0101da1:	74 24                	je     f0101dc7 <mem_init+0x2f7>
f0101da3:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f0101daa:	f0 
f0101dab:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101db2:	f0 
f0101db3:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101dba:	00 
f0101dbb:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101dc2:	e8 be e2 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101dc7:	89 34 24             	mov    %esi,(%esp)
f0101dca:	e8 b7 ed ff ff       	call   f0100b86 <page_free>
	page_free(pp1);
f0101dcf:	89 3c 24             	mov    %edi,(%esp)
f0101dd2:	e8 af ed ff ff       	call   f0100b86 <page_free>
	page_free(pp2);
f0101dd7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101dda:	89 14 24             	mov    %edx,(%esp)
f0101ddd:	e8 a4 ed ff ff       	call   f0100b86 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101de2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101de9:	e8 48 f4 ff ff       	call   f0101236 <page_alloc>
f0101dee:	89 c6                	mov    %eax,%esi
f0101df0:	85 c0                	test   %eax,%eax
f0101df2:	75 24                	jne    f0101e18 <mem_init+0x348>
f0101df4:	c7 44 24 0c f2 7c 10 	movl   $0xf0107cf2,0xc(%esp)
f0101dfb:	f0 
f0101dfc:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101e03:	f0 
f0101e04:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f0101e0b:	00 
f0101e0c:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101e13:	e8 6d e2 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101e18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e1f:	e8 12 f4 ff ff       	call   f0101236 <page_alloc>
f0101e24:	89 c7                	mov    %eax,%edi
f0101e26:	85 c0                	test   %eax,%eax
f0101e28:	75 24                	jne    f0101e4e <mem_init+0x37e>
f0101e2a:	c7 44 24 0c 08 7d 10 	movl   $0xf0107d08,0xc(%esp)
f0101e31:	f0 
f0101e32:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101e39:	f0 
f0101e3a:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0101e41:	00 
f0101e42:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101e49:	e8 37 e2 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101e4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e55:	e8 dc f3 ff ff       	call   f0101236 <page_alloc>
f0101e5a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101e5d:	85 c0                	test   %eax,%eax
f0101e5f:	75 24                	jne    f0101e85 <mem_init+0x3b5>
f0101e61:	c7 44 24 0c 1e 7d 10 	movl   $0xf0107d1e,0xc(%esp)
f0101e68:	f0 
f0101e69:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101e70:	f0 
f0101e71:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f0101e78:	00 
f0101e79:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101e80:	e8 00 e2 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101e85:	39 fe                	cmp    %edi,%esi
f0101e87:	75 24                	jne    f0101ead <mem_init+0x3dd>
f0101e89:	c7 44 24 0c a4 7d 10 	movl   $0xf0107da4,0xc(%esp)
f0101e90:	f0 
f0101e91:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101e98:	f0 
f0101e99:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101ea0:	00 
f0101ea1:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101ea8:	e8 d8 e1 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ead:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101eb0:	74 05                	je     f0101eb7 <mem_init+0x3e7>
f0101eb2:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101eb5:	75 24                	jne    f0101edb <mem_init+0x40b>
f0101eb7:	c7 44 24 0c 40 75 10 	movl   $0xf0107540,0xc(%esp)
f0101ebe:	f0 
f0101ebf:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101ec6:	f0 
f0101ec7:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0101ece:	00 
f0101ecf:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101ed6:	e8 aa e1 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0101edb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ee2:	e8 4f f3 ff ff       	call   f0101236 <page_alloc>
f0101ee7:	85 c0                	test   %eax,%eax
f0101ee9:	74 24                	je     f0101f0f <mem_init+0x43f>
f0101eeb:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f0101ef2:	f0 
f0101ef3:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101efa:	f0 
f0101efb:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0101f02:	00 
f0101f03:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101f0a:	e8 76 e1 ff ff       	call   f0100085 <_panic>
f0101f0f:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101f12:	89 f0                	mov    %esi,%eax
f0101f14:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0101f1a:	c1 f8 03             	sar    $0x3,%eax
f0101f1d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f20:	89 c2                	mov    %eax,%edx
f0101f22:	c1 ea 0c             	shr    $0xc,%edx
f0101f25:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0101f2b:	72 20                	jb     f0101f4d <mem_init+0x47d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101f31:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0101f38:	f0 
f0101f39:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101f40:	00 
f0101f41:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0101f48:	e8 38 e1 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101f4d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f54:	00 
f0101f55:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101f5c:	00 
f0101f5d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f62:	89 04 24             	mov    %eax,(%esp)
f0101f65:	e8 c7 3f 00 00       	call   f0105f31 <memset>
	page_free(pp0);
f0101f6a:	89 34 24             	mov    %esi,(%esp)
f0101f6d:	e8 14 ec ff ff       	call   f0100b86 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101f72:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101f79:	e8 b8 f2 ff ff       	call   f0101236 <page_alloc>
f0101f7e:	85 c0                	test   %eax,%eax
f0101f80:	75 24                	jne    f0101fa6 <mem_init+0x4d6>
f0101f82:	c7 44 24 0c 1c 7e 10 	movl   $0xf0107e1c,0xc(%esp)
f0101f89:	f0 
f0101f8a:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101f91:	f0 
f0101f92:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0101f99:	00 
f0101f9a:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101fa1:	e8 df e0 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0101fa6:	39 c6                	cmp    %eax,%esi
f0101fa8:	74 24                	je     f0101fce <mem_init+0x4fe>
f0101faa:	c7 44 24 0c 3a 7e 10 	movl   $0xf0107e3a,0xc(%esp)
f0101fb1:	f0 
f0101fb2:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0101fb9:	f0 
f0101fba:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101fc1:	00 
f0101fc2:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0101fc9:	e8 b7 e0 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fce:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101fd1:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0101fd7:	c1 fa 03             	sar    $0x3,%edx
f0101fda:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fdd:	89 d0                	mov    %edx,%eax
f0101fdf:	c1 e8 0c             	shr    $0xc,%eax
f0101fe2:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0101fe8:	72 20                	jb     f010200a <mem_init+0x53a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fea:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101fee:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0101ff5:	f0 
f0101ff6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101ffd:	00 
f0101ffe:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0102005:	e8 7b e0 ff ff       	call   f0100085 <_panic>
	return (void *)(pa + KERNBASE);
f010200a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102010:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102016:	80 38 00             	cmpb   $0x0,(%eax)
f0102019:	74 24                	je     f010203f <mem_init+0x56f>
f010201b:	c7 44 24 0c 4a 7e 10 	movl   $0xf0107e4a,0xc(%esp)
f0102022:	f0 
f0102023:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010202a:	f0 
f010202b:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0102032:	00 
f0102033:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010203a:	e8 46 e0 ff ff       	call   f0100085 <_panic>
f010203f:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102042:	39 d0                	cmp    %edx,%eax
f0102044:	75 d0                	jne    f0102016 <mem_init+0x546>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102046:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102049:	89 0d 30 22 23 f0    	mov    %ecx,0xf0232230

	// free the pages we took
	page_free(pp0);
f010204f:	89 34 24             	mov    %esi,(%esp)
f0102052:	e8 2f eb ff ff       	call   f0100b86 <page_free>
	page_free(pp1);
f0102057:	89 3c 24             	mov    %edi,(%esp)
f010205a:	e8 27 eb ff ff       	call   f0100b86 <page_free>
	page_free(pp2);
f010205f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102062:	89 04 24             	mov    %eax,(%esp)
f0102065:	e8 1c eb ff ff       	call   f0100b86 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010206a:	a1 30 22 23 f0       	mov    0xf0232230,%eax
f010206f:	eb 05                	jmp    f0102076 <mem_init+0x5a6>
		--nfree;
f0102071:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102074:	8b 00                	mov    (%eax),%eax
f0102076:	85 c0                	test   %eax,%eax
f0102078:	75 f7                	jne    f0102071 <mem_init+0x5a1>
		--nfree;
	assert(nfree == 0);
f010207a:	85 db                	test   %ebx,%ebx
f010207c:	74 24                	je     f01020a2 <mem_init+0x5d2>
f010207e:	c7 44 24 0c 54 7e 10 	movl   $0xf0107e54,0xc(%esp)
f0102085:	f0 
f0102086:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010208d:	f0 
f010208e:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0102095:	00 
f0102096:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010209d:	e8 e3 df ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01020a2:	c7 04 24 60 75 10 f0 	movl   $0xf0107560,(%esp)
f01020a9:	e8 71 21 00 00       	call   f010421f <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01020ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020b5:	e8 7c f1 ff ff       	call   f0101236 <page_alloc>
f01020ba:	89 c7                	mov    %eax,%edi
f01020bc:	85 c0                	test   %eax,%eax
f01020be:	75 24                	jne    f01020e4 <mem_init+0x614>
f01020c0:	c7 44 24 0c f2 7c 10 	movl   $0xf0107cf2,0xc(%esp)
f01020c7:	f0 
f01020c8:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01020cf:	f0 
f01020d0:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f01020d7:	00 
f01020d8:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01020df:	e8 a1 df ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01020e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020eb:	e8 46 f1 ff ff       	call   f0101236 <page_alloc>
f01020f0:	89 c3                	mov    %eax,%ebx
f01020f2:	85 c0                	test   %eax,%eax
f01020f4:	75 24                	jne    f010211a <mem_init+0x64a>
f01020f6:	c7 44 24 0c 08 7d 10 	movl   $0xf0107d08,0xc(%esp)
f01020fd:	f0 
f01020fe:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102105:	f0 
f0102106:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f010210d:	00 
f010210e:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102115:	e8 6b df ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f010211a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102121:	e8 10 f1 ff ff       	call   f0101236 <page_alloc>
f0102126:	89 c6                	mov    %eax,%esi
f0102128:	85 c0                	test   %eax,%eax
f010212a:	75 24                	jne    f0102150 <mem_init+0x680>
f010212c:	c7 44 24 0c 1e 7d 10 	movl   $0xf0107d1e,0xc(%esp)
f0102133:	f0 
f0102134:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010213b:	f0 
f010213c:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f0102143:	00 
f0102144:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010214b:	e8 35 df ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102150:	39 df                	cmp    %ebx,%edi
f0102152:	75 24                	jne    f0102178 <mem_init+0x6a8>
f0102154:	c7 44 24 0c a4 7d 10 	movl   $0xf0107da4,0xc(%esp)
f010215b:	f0 
f010215c:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102163:	f0 
f0102164:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f010216b:	00 
f010216c:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102173:	e8 0d df ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102178:	39 c3                	cmp    %eax,%ebx
f010217a:	74 04                	je     f0102180 <mem_init+0x6b0>
f010217c:	39 c7                	cmp    %eax,%edi
f010217e:	75 24                	jne    f01021a4 <mem_init+0x6d4>
f0102180:	c7 44 24 0c 40 75 10 	movl   $0xf0107540,0xc(%esp)
f0102187:	f0 
f0102188:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010218f:	f0 
f0102190:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0102197:	00 
f0102198:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010219f:	e8 e1 de ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01021a4:	8b 15 30 22 23 f0    	mov    0xf0232230,%edx
f01021aa:	89 55 c8             	mov    %edx,-0x38(%ebp)
	page_free_list = 0;
f01021ad:	c7 05 30 22 23 f0 00 	movl   $0x0,0xf0232230
f01021b4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01021b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021be:	e8 73 f0 ff ff       	call   f0101236 <page_alloc>
f01021c3:	85 c0                	test   %eax,%eax
f01021c5:	74 24                	je     f01021eb <mem_init+0x71b>
f01021c7:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f01021ce:	f0 
f01021cf:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01021d6:	f0 
f01021d7:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f01021de:	00 
f01021df:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01021e6:	e8 9a de ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01021eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01021ee:	89 44 24 08          	mov    %eax,0x8(%esp)
f01021f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01021f9:	00 
f01021fa:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01021ff:	89 04 24             	mov    %eax,(%esp)
f0102202:	e8 ad f3 ff ff       	call   f01015b4 <page_lookup>
f0102207:	85 c0                	test   %eax,%eax
f0102209:	74 24                	je     f010222f <mem_init+0x75f>
f010220b:	c7 44 24 0c 80 75 10 	movl   $0xf0107580,0xc(%esp)
f0102212:	f0 
f0102213:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010221a:	f0 
f010221b:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102222:	00 
f0102223:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010222a:	e8 56 de ff ff       	call   f0100085 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010222f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102236:	00 
f0102237:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010223e:	00 
f010223f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102243:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102248:	89 04 24             	mov    %eax,(%esp)
f010224b:	e8 2c f4 ff ff       	call   f010167c <page_insert>
f0102250:	85 c0                	test   %eax,%eax
f0102252:	78 24                	js     f0102278 <mem_init+0x7a8>
f0102254:	c7 44 24 0c b8 75 10 	movl   $0xf01075b8,0xc(%esp)
f010225b:	f0 
f010225c:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102263:	f0 
f0102264:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f010226b:	00 
f010226c:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102273:	e8 0d de ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0102278:	89 3c 24             	mov    %edi,(%esp)
f010227b:	e8 06 e9 ff ff       	call   f0100b86 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102280:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102287:	00 
f0102288:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010228f:	00 
f0102290:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102294:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102299:	89 04 24             	mov    %eax,(%esp)
f010229c:	e8 db f3 ff ff       	call   f010167c <page_insert>
f01022a1:	85 c0                	test   %eax,%eax
f01022a3:	74 24                	je     f01022c9 <mem_init+0x7f9>
f01022a5:	c7 44 24 0c e8 75 10 	movl   $0xf01075e8,0xc(%esp)
f01022ac:	f0 
f01022ad:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01022b4:	f0 
f01022b5:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f01022bc:	00 
f01022bd:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01022c4:	e8 bc dd ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022c9:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01022ce:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01022d1:	8b 08                	mov    (%eax),%ecx
f01022d3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01022d9:	89 fa                	mov    %edi,%edx
f01022db:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f01022e1:	c1 fa 03             	sar    $0x3,%edx
f01022e4:	c1 e2 0c             	shl    $0xc,%edx
f01022e7:	39 d1                	cmp    %edx,%ecx
f01022e9:	74 24                	je     f010230f <mem_init+0x83f>
f01022eb:	c7 44 24 0c ec 74 10 	movl   $0xf01074ec,0xc(%esp)
f01022f2:	f0 
f01022f3:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01022fa:	f0 
f01022fb:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102302:	00 
f0102303:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010230a:	e8 76 dd ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010230f:	ba 00 00 00 00       	mov    $0x0,%edx
f0102314:	e8 07 e8 ff ff       	call   f0100b20 <check_va2pa>
f0102319:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010231c:	89 da                	mov    %ebx,%edx
f010231e:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0102324:	c1 fa 03             	sar    $0x3,%edx
f0102327:	c1 e2 0c             	shl    $0xc,%edx
f010232a:	39 d0                	cmp    %edx,%eax
f010232c:	74 24                	je     f0102352 <mem_init+0x882>
f010232e:	c7 44 24 0c 18 76 10 	movl   $0xf0107618,0xc(%esp)
f0102335:	f0 
f0102336:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010233d:	f0 
f010233e:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102345:	00 
f0102346:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010234d:	e8 33 dd ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0102352:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102357:	74 24                	je     f010237d <mem_init+0x8ad>
f0102359:	c7 44 24 0c 34 7d 10 	movl   $0xf0107d34,0xc(%esp)
f0102360:	f0 
f0102361:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102368:	f0 
f0102369:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102370:	00 
f0102371:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102378:	e8 08 dd ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f010237d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102382:	74 24                	je     f01023a8 <mem_init+0x8d8>
f0102384:	c7 44 24 0c 78 7d 10 	movl   $0xf0107d78,0xc(%esp)
f010238b:	f0 
f010238c:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102393:	f0 
f0102394:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010239b:	00 
f010239c:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01023a3:	e8 dd dc ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01023a8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023af:	00 
f01023b0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023b7:	00 
f01023b8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01023bc:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01023c1:	89 04 24             	mov    %eax,(%esp)
f01023c4:	e8 b3 f2 ff ff       	call   f010167c <page_insert>
f01023c9:	85 c0                	test   %eax,%eax
f01023cb:	74 24                	je     f01023f1 <mem_init+0x921>
f01023cd:	c7 44 24 0c 48 76 10 	movl   $0xf0107648,0xc(%esp)
f01023d4:	f0 
f01023d5:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01023dc:	f0 
f01023dd:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f01023e4:	00 
f01023e5:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01023ec:	e8 94 dc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023f1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023f6:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01023fb:	e8 20 e7 ff ff       	call   f0100b20 <check_va2pa>
f0102400:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102403:	89 f2                	mov    %esi,%edx
f0102405:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f010240b:	c1 fa 03             	sar    $0x3,%edx
f010240e:	c1 e2 0c             	shl    $0xc,%edx
f0102411:	39 d0                	cmp    %edx,%eax
f0102413:	74 24                	je     f0102439 <mem_init+0x969>
f0102415:	c7 44 24 0c 84 76 10 	movl   $0xf0107684,0xc(%esp)
f010241c:	f0 
f010241d:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102424:	f0 
f0102425:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f010242c:	00 
f010242d:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102434:	e8 4c dc ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0102439:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010243e:	74 24                	je     f0102464 <mem_init+0x994>
f0102440:	c7 44 24 0c 45 7d 10 	movl   $0xf0107d45,0xc(%esp)
f0102447:	f0 
f0102448:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010244f:	f0 
f0102450:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102457:	00 
f0102458:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010245f:	e8 21 dc ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102464:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010246b:	e8 c6 ed ff ff       	call   f0101236 <page_alloc>
f0102470:	85 c0                	test   %eax,%eax
f0102472:	74 24                	je     f0102498 <mem_init+0x9c8>
f0102474:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f010247b:	f0 
f010247c:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102483:	f0 
f0102484:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f010248b:	00 
f010248c:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102493:	e8 ed db ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102498:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010249f:	00 
f01024a0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024a7:	00 
f01024a8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024ac:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01024b1:	89 04 24             	mov    %eax,(%esp)
f01024b4:	e8 c3 f1 ff ff       	call   f010167c <page_insert>
f01024b9:	85 c0                	test   %eax,%eax
f01024bb:	74 24                	je     f01024e1 <mem_init+0xa11>
f01024bd:	c7 44 24 0c 48 76 10 	movl   $0xf0107648,0xc(%esp)
f01024c4:	f0 
f01024c5:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01024cc:	f0 
f01024cd:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01024d4:	00 
f01024d5:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01024dc:	e8 a4 db ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01024e1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024e6:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01024eb:	e8 30 e6 ff ff       	call   f0100b20 <check_va2pa>
f01024f0:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01024f3:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f01024f9:	c1 fa 03             	sar    $0x3,%edx
f01024fc:	c1 e2 0c             	shl    $0xc,%edx
f01024ff:	39 d0                	cmp    %edx,%eax
f0102501:	74 24                	je     f0102527 <mem_init+0xa57>
f0102503:	c7 44 24 0c 84 76 10 	movl   $0xf0107684,0xc(%esp)
f010250a:	f0 
f010250b:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102512:	f0 
f0102513:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010251a:	00 
f010251b:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102522:	e8 5e db ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0102527:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010252c:	74 24                	je     f0102552 <mem_init+0xa82>
f010252e:	c7 44 24 0c 45 7d 10 	movl   $0xf0107d45,0xc(%esp)
f0102535:	f0 
f0102536:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010253d:	f0 
f010253e:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102545:	00 
f0102546:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010254d:	e8 33 db ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102552:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102559:	e8 d8 ec ff ff       	call   f0101236 <page_alloc>
f010255e:	85 c0                	test   %eax,%eax
f0102560:	74 24                	je     f0102586 <mem_init+0xab6>
f0102562:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f0102569:	f0 
f010256a:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102571:	f0 
f0102572:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102579:	00 
f010257a:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102581:	e8 ff da ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102586:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010258b:	8b 00                	mov    (%eax),%eax
f010258d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102592:	89 c2                	mov    %eax,%edx
f0102594:	c1 ea 0c             	shr    $0xc,%edx
f0102597:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f010259d:	72 20                	jb     f01025bf <mem_init+0xaef>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010259f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025a3:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f01025aa:	f0 
f01025ab:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01025b2:	00 
f01025b3:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01025ba:	e8 c6 da ff ff       	call   f0100085 <_panic>
f01025bf:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01025c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025ce:	00 
f01025cf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025d6:	00 
f01025d7:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01025dc:	89 04 24             	mov    %eax,(%esp)
f01025df:	e8 d6 ec ff ff       	call   f01012ba <pgdir_walk>
f01025e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01025e7:	83 c2 04             	add    $0x4,%edx
f01025ea:	39 d0                	cmp    %edx,%eax
f01025ec:	74 24                	je     f0102612 <mem_init+0xb42>
f01025ee:	c7 44 24 0c b4 76 10 	movl   $0xf01076b4,0xc(%esp)
f01025f5:	f0 
f01025f6:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01025fd:	f0 
f01025fe:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102605:	00 
f0102606:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010260d:	e8 73 da ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102612:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102619:	00 
f010261a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102621:	00 
f0102622:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102626:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010262b:	89 04 24             	mov    %eax,(%esp)
f010262e:	e8 49 f0 ff ff       	call   f010167c <page_insert>
f0102633:	85 c0                	test   %eax,%eax
f0102635:	74 24                	je     f010265b <mem_init+0xb8b>
f0102637:	c7 44 24 0c f4 76 10 	movl   $0xf01076f4,0xc(%esp)
f010263e:	f0 
f010263f:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102646:	f0 
f0102647:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010264e:	00 
f010264f:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102656:	e8 2a da ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010265b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102660:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102665:	e8 b6 e4 ff ff       	call   f0100b20 <check_va2pa>
f010266a:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010266d:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0102673:	c1 fa 03             	sar    $0x3,%edx
f0102676:	c1 e2 0c             	shl    $0xc,%edx
f0102679:	39 d0                	cmp    %edx,%eax
f010267b:	74 24                	je     f01026a1 <mem_init+0xbd1>
f010267d:	c7 44 24 0c 84 76 10 	movl   $0xf0107684,0xc(%esp)
f0102684:	f0 
f0102685:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010268c:	f0 
f010268d:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f0102694:	00 
f0102695:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010269c:	e8 e4 d9 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01026a1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01026a6:	74 24                	je     f01026cc <mem_init+0xbfc>
f01026a8:	c7 44 24 0c 45 7d 10 	movl   $0xf0107d45,0xc(%esp)
f01026af:	f0 
f01026b0:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01026b7:	f0 
f01026b8:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01026bf:	00 
f01026c0:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01026c7:	e8 b9 d9 ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01026cc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026d3:	00 
f01026d4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026db:	00 
f01026dc:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01026e1:	89 04 24             	mov    %eax,(%esp)
f01026e4:	e8 d1 eb ff ff       	call   f01012ba <pgdir_walk>
f01026e9:	f6 00 04             	testb  $0x4,(%eax)
f01026ec:	75 24                	jne    f0102712 <mem_init+0xc42>
f01026ee:	c7 44 24 0c 34 77 10 	movl   $0xf0107734,0xc(%esp)
f01026f5:	f0 
f01026f6:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01026fd:	f0 
f01026fe:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f0102705:	00 
f0102706:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010270d:	e8 73 d9 ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102712:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102717:	f6 00 04             	testb  $0x4,(%eax)
f010271a:	75 24                	jne    f0102740 <mem_init+0xc70>
f010271c:	c7 44 24 0c 5f 7e 10 	movl   $0xf0107e5f,0xc(%esp)
f0102723:	f0 
f0102724:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010272b:	f0 
f010272c:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f0102733:	00 
f0102734:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010273b:	e8 45 d9 ff ff       	call   f0100085 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102740:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102747:	00 
f0102748:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010274f:	00 
f0102750:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102754:	89 04 24             	mov    %eax,(%esp)
f0102757:	e8 20 ef ff ff       	call   f010167c <page_insert>
f010275c:	85 c0                	test   %eax,%eax
f010275e:	74 24                	je     f0102784 <mem_init+0xcb4>
f0102760:	c7 44 24 0c 48 76 10 	movl   $0xf0107648,0xc(%esp)
f0102767:	f0 
f0102768:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010276f:	f0 
f0102770:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f0102777:	00 
f0102778:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010277f:	e8 01 d9 ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102784:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010278b:	00 
f010278c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102793:	00 
f0102794:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102799:	89 04 24             	mov    %eax,(%esp)
f010279c:	e8 19 eb ff ff       	call   f01012ba <pgdir_walk>
f01027a1:	f6 00 02             	testb  $0x2,(%eax)
f01027a4:	75 24                	jne    f01027ca <mem_init+0xcfa>
f01027a6:	c7 44 24 0c 68 77 10 	movl   $0xf0107768,0xc(%esp)
f01027ad:	f0 
f01027ae:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01027b5:	f0 
f01027b6:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f01027bd:	00 
f01027be:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01027c5:	e8 bb d8 ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01027ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01027d1:	00 
f01027d2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027d9:	00 
f01027da:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01027df:	89 04 24             	mov    %eax,(%esp)
f01027e2:	e8 d3 ea ff ff       	call   f01012ba <pgdir_walk>
f01027e7:	f6 00 04             	testb  $0x4,(%eax)
f01027ea:	74 24                	je     f0102810 <mem_init+0xd40>
f01027ec:	c7 44 24 0c 9c 77 10 	movl   $0xf010779c,0xc(%esp)
f01027f3:	f0 
f01027f4:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01027fb:	f0 
f01027fc:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f0102803:	00 
f0102804:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010280b:	e8 75 d8 ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102810:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102817:	00 
f0102818:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010281f:	00 
f0102820:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102824:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102829:	89 04 24             	mov    %eax,(%esp)
f010282c:	e8 4b ee ff ff       	call   f010167c <page_insert>
f0102831:	85 c0                	test   %eax,%eax
f0102833:	78 24                	js     f0102859 <mem_init+0xd89>
f0102835:	c7 44 24 0c d4 77 10 	movl   $0xf01077d4,0xc(%esp)
f010283c:	f0 
f010283d:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102844:	f0 
f0102845:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f010284c:	00 
f010284d:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102854:	e8 2c d8 ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102859:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102860:	00 
f0102861:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102868:	00 
f0102869:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010286d:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102872:	89 04 24             	mov    %eax,(%esp)
f0102875:	e8 02 ee ff ff       	call   f010167c <page_insert>
f010287a:	85 c0                	test   %eax,%eax
f010287c:	74 24                	je     f01028a2 <mem_init+0xdd2>
f010287e:	c7 44 24 0c 0c 78 10 	movl   $0xf010780c,0xc(%esp)
f0102885:	f0 
f0102886:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010288d:	f0 
f010288e:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102895:	00 
f0102896:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010289d:	e8 e3 d7 ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01028a9:	00 
f01028aa:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01028b1:	00 
f01028b2:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01028b7:	89 04 24             	mov    %eax,(%esp)
f01028ba:	e8 fb e9 ff ff       	call   f01012ba <pgdir_walk>
f01028bf:	f6 00 04             	testb  $0x4,(%eax)
f01028c2:	74 24                	je     f01028e8 <mem_init+0xe18>
f01028c4:	c7 44 24 0c 9c 77 10 	movl   $0xf010779c,0xc(%esp)
f01028cb:	f0 
f01028cc:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01028d3:	f0 
f01028d4:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f01028db:	00 
f01028dc:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01028e3:	e8 9d d7 ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01028e8:	ba 00 00 00 00       	mov    $0x0,%edx
f01028ed:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01028f2:	e8 29 e2 ff ff       	call   f0100b20 <check_va2pa>
f01028f7:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01028fa:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0102900:	c1 fa 03             	sar    $0x3,%edx
f0102903:	c1 e2 0c             	shl    $0xc,%edx
f0102906:	39 d0                	cmp    %edx,%eax
f0102908:	74 24                	je     f010292e <mem_init+0xe5e>
f010290a:	c7 44 24 0c 48 78 10 	movl   $0xf0107848,0xc(%esp)
f0102911:	f0 
f0102912:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102919:	f0 
f010291a:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f0102921:	00 
f0102922:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102929:	e8 57 d7 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010292e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102933:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102938:	e8 e3 e1 ff ff       	call   f0100b20 <check_va2pa>
f010293d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102940:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0102946:	c1 fa 03             	sar    $0x3,%edx
f0102949:	c1 e2 0c             	shl    $0xc,%edx
f010294c:	39 d0                	cmp    %edx,%eax
f010294e:	74 24                	je     f0102974 <mem_init+0xea4>
f0102950:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f0102957:	f0 
f0102958:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010295f:	f0 
f0102960:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f0102967:	00 
f0102968:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010296f:	e8 11 d7 ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102974:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0102979:	74 24                	je     f010299f <mem_init+0xecf>
f010297b:	c7 44 24 0c 75 7e 10 	movl   $0xf0107e75,0xc(%esp)
f0102982:	f0 
f0102983:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010298a:	f0 
f010298b:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102992:	00 
f0102993:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010299a:	e8 e6 d6 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f010299f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01029a4:	74 24                	je     f01029ca <mem_init+0xefa>
f01029a6:	c7 44 24 0c 67 7d 10 	movl   $0xf0107d67,0xc(%esp)
f01029ad:	f0 
f01029ae:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01029b5:	f0 
f01029b6:	c7 44 24 04 20 04 00 	movl   $0x420,0x4(%esp)
f01029bd:	00 
f01029be:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01029c5:	e8 bb d6 ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc;
	assert((pp = page_alloc(0)) && pp == pp2);
f01029ca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029d1:	e8 60 e8 ff ff       	call   f0101236 <page_alloc>
f01029d6:	85 c0                	test   %eax,%eax
f01029d8:	74 04                	je     f01029de <mem_init+0xf0e>
f01029da:	39 c6                	cmp    %eax,%esi
f01029dc:	74 24                	je     f0102a02 <mem_init+0xf32>
f01029de:	c7 44 24 0c a4 78 10 	movl   $0xf01078a4,0xc(%esp)
f01029e5:	f0 
f01029e6:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01029ed:	f0 
f01029ee:	c7 44 24 04 23 04 00 	movl   $0x423,0x4(%esp)
f01029f5:	00 
f01029f6:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01029fd:	e8 83 d6 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102a02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a09:	00 
f0102a0a:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102a0f:	89 04 24             	mov    %eax,(%esp)
f0102a12:	e8 0e ec ff ff       	call   f0101625 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a17:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a1c:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102a21:	e8 fa e0 ff ff       	call   f0100b20 <check_va2pa>
f0102a26:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a29:	74 24                	je     f0102a4f <mem_init+0xf7f>
f0102a2b:	c7 44 24 0c c8 78 10 	movl   $0xf01078c8,0xc(%esp)
f0102a32:	f0 
f0102a33:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102a3a:	f0 
f0102a3b:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0102a42:	00 
f0102a43:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102a4a:	e8 36 d6 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102a4f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a54:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102a59:	e8 c2 e0 ff ff       	call   f0100b20 <check_va2pa>
f0102a5e:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102a61:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0102a67:	c1 fa 03             	sar    $0x3,%edx
f0102a6a:	c1 e2 0c             	shl    $0xc,%edx
f0102a6d:	39 d0                	cmp    %edx,%eax
f0102a6f:	74 24                	je     f0102a95 <mem_init+0xfc5>
f0102a71:	c7 44 24 0c 74 78 10 	movl   $0xf0107874,0xc(%esp)
f0102a78:	f0 
f0102a79:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102a80:	f0 
f0102a81:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f0102a88:	00 
f0102a89:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102a90:	e8 f0 d5 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0102a95:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102a9a:	74 24                	je     f0102ac0 <mem_init+0xff0>
f0102a9c:	c7 44 24 0c 34 7d 10 	movl   $0xf0107d34,0xc(%esp)
f0102aa3:	f0 
f0102aa4:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102aab:	f0 
f0102aac:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f0102ab3:	00 
f0102ab4:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102abb:	e8 c5 d5 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102ac0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ac5:	74 24                	je     f0102aeb <mem_init+0x101b>
f0102ac7:	c7 44 24 0c 67 7d 10 	movl   $0xf0107d67,0xc(%esp)
f0102ace:	f0 
f0102acf:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102ad6:	f0 
f0102ad7:	c7 44 24 04 2a 04 00 	movl   $0x42a,0x4(%esp)
f0102ade:	00 
f0102adf:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102ae6:	e8 9a d5 ff ff       	call   f0100085 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102aeb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102af2:	00 
f0102af3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102afa:	00 
f0102afb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102aff:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102b04:	89 04 24             	mov    %eax,(%esp)
f0102b07:	e8 70 eb ff ff       	call   f010167c <page_insert>
f0102b0c:	85 c0                	test   %eax,%eax
f0102b0e:	74 24                	je     f0102b34 <mem_init+0x1064>
f0102b10:	c7 44 24 0c ec 78 10 	movl   $0xf01078ec,0xc(%esp)
f0102b17:	f0 
f0102b18:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102b1f:	f0 
f0102b20:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0102b27:	00 
f0102b28:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102b2f:	e8 51 d5 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref);
f0102b34:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102b39:	75 24                	jne    f0102b5f <mem_init+0x108f>
f0102b3b:	c7 44 24 0c 86 7e 10 	movl   $0xf0107e86,0xc(%esp)
f0102b42:	f0 
f0102b43:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102b4a:	f0 
f0102b4b:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f0102b52:	00 
f0102b53:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102b5a:	e8 26 d5 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_link == NULL);
f0102b5f:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102b62:	74 24                	je     f0102b88 <mem_init+0x10b8>
f0102b64:	c7 44 24 0c 92 7e 10 	movl   $0xf0107e92,0xc(%esp)
f0102b6b:	f0 
f0102b6c:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102b73:	f0 
f0102b74:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0102b7b:	00 
f0102b7c:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102b83:	e8 fd d4 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b88:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b8f:	00 
f0102b90:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102b95:	89 04 24             	mov    %eax,(%esp)
f0102b98:	e8 88 ea ff ff       	call   f0101625 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b9d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ba2:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102ba7:	e8 74 df ff ff       	call   f0100b20 <check_va2pa>
f0102bac:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102baf:	74 24                	je     f0102bd5 <mem_init+0x1105>
f0102bb1:	c7 44 24 0c c8 78 10 	movl   $0xf01078c8,0xc(%esp)
f0102bb8:	f0 
f0102bb9:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102bc0:	f0 
f0102bc1:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f0102bc8:	00 
f0102bc9:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102bd0:	e8 b0 d4 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102bd5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102bda:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102bdf:	e8 3c df ff ff       	call   f0100b20 <check_va2pa>
f0102be4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102be7:	74 24                	je     f0102c0d <mem_init+0x113d>
f0102be9:	c7 44 24 0c 24 79 10 	movl   $0xf0107924,0xc(%esp)
f0102bf0:	f0 
f0102bf1:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102bf8:	f0 
f0102bf9:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0102c00:	00 
f0102c01:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102c08:	e8 78 d4 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0102c0d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c12:	74 24                	je     f0102c38 <mem_init+0x1168>
f0102c14:	c7 44 24 0c 56 7d 10 	movl   $0xf0107d56,0xc(%esp)
f0102c1b:	f0 
f0102c1c:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102c23:	f0 
f0102c24:	c7 44 24 04 35 04 00 	movl   $0x435,0x4(%esp)
f0102c2b:	00 
f0102c2c:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102c33:	e8 4d d4 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102c38:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c3d:	74 24                	je     f0102c63 <mem_init+0x1193>
f0102c3f:	c7 44 24 0c 67 7d 10 	movl   $0xf0107d67,0xc(%esp)
f0102c46:	f0 
f0102c47:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102c4e:	f0 
f0102c4f:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0102c56:	00 
f0102c57:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102c5e:	e8 22 d4 ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102c63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c6a:	e8 c7 e5 ff ff       	call   f0101236 <page_alloc>
f0102c6f:	85 c0                	test   %eax,%eax
f0102c71:	74 04                	je     f0102c77 <mem_init+0x11a7>
f0102c73:	39 c3                	cmp    %eax,%ebx
f0102c75:	74 24                	je     f0102c9b <mem_init+0x11cb>
f0102c77:	c7 44 24 0c 4c 79 10 	movl   $0xf010794c,0xc(%esp)
f0102c7e:	f0 
f0102c7f:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102c86:	f0 
f0102c87:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0102c8e:	00 
f0102c8f:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102c96:	e8 ea d3 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102c9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ca2:	e8 8f e5 ff ff       	call   f0101236 <page_alloc>
f0102ca7:	85 c0                	test   %eax,%eax
f0102ca9:	74 24                	je     f0102ccf <mem_init+0x11ff>
f0102cab:	c7 44 24 0c 0d 7e 10 	movl   $0xf0107e0d,0xc(%esp)
f0102cb2:	f0 
f0102cb3:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102cba:	f0 
f0102cbb:	c7 44 24 04 3c 04 00 	movl   $0x43c,0x4(%esp)
f0102cc2:	00 
f0102cc3:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102cca:	e8 b6 d3 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ccf:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102cd4:	8b 08                	mov    (%eax),%ecx
f0102cd6:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102cdc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102cdf:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0102ce5:	c1 fa 03             	sar    $0x3,%edx
f0102ce8:	c1 e2 0c             	shl    $0xc,%edx
f0102ceb:	39 d1                	cmp    %edx,%ecx
f0102ced:	74 24                	je     f0102d13 <mem_init+0x1243>
f0102cef:	c7 44 24 0c ec 74 10 	movl   $0xf01074ec,0xc(%esp)
f0102cf6:	f0 
f0102cf7:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102cfe:	f0 
f0102cff:	c7 44 24 04 3f 04 00 	movl   $0x43f,0x4(%esp)
f0102d06:	00 
f0102d07:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102d0e:	e8 72 d3 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0102d13:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102d19:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102d1e:	74 24                	je     f0102d44 <mem_init+0x1274>
f0102d20:	c7 44 24 0c 78 7d 10 	movl   $0xf0107d78,0xc(%esp)
f0102d27:	f0 
f0102d28:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102d2f:	f0 
f0102d30:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f0102d37:	00 
f0102d38:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102d3f:	e8 41 d3 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102d44:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102d4a:	89 3c 24             	mov    %edi,(%esp)
f0102d4d:	e8 34 de ff ff       	call   f0100b86 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102d52:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102d59:	00 
f0102d5a:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102d61:	00 
f0102d62:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102d67:	89 04 24             	mov    %eax,(%esp)
f0102d6a:	e8 4b e5 ff ff       	call   f01012ba <pgdir_walk>
f0102d6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102d72:	8b 0d 8c 2e 23 f0    	mov    0xf0232e8c,%ecx
f0102d78:	83 c1 04             	add    $0x4,%ecx
f0102d7b:	8b 11                	mov    (%ecx),%edx
f0102d7d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d83:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d86:	c1 ea 0c             	shr    $0xc,%edx
f0102d89:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0102d8f:	72 23                	jb     f0102db4 <mem_init+0x12e4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d91:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d94:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102d98:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0102d9f:	f0 
f0102da0:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0102da7:	00 
f0102da8:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102daf:	e8 d1 d2 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102db4:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102db7:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102dbd:	39 d0                	cmp    %edx,%eax
f0102dbf:	74 24                	je     f0102de5 <mem_init+0x1315>
f0102dc1:	c7 44 24 0c a7 7e 10 	movl   $0xf0107ea7,0xc(%esp)
f0102dc8:	f0 
f0102dc9:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102dd0:	f0 
f0102dd1:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0102dd8:	00 
f0102dd9:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102de0:	e8 a0 d2 ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102de5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f0102deb:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102df1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102df4:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0102dfa:	c1 f8 03             	sar    $0x3,%eax
f0102dfd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e00:	89 c2                	mov    %eax,%edx
f0102e02:	c1 ea 0c             	shr    $0xc,%edx
f0102e05:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0102e0b:	72 20                	jb     f0102e2d <mem_init+0x135d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102e11:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0102e18:	f0 
f0102e19:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102e20:	00 
f0102e21:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0102e28:	e8 58 d2 ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102e2d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102e34:	00 
f0102e35:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102e3c:	00 
f0102e3d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e42:	89 04 24             	mov    %eax,(%esp)
f0102e45:	e8 e7 30 00 00       	call   f0105f31 <memset>
	page_free(pp0);
f0102e4a:	89 3c 24             	mov    %edi,(%esp)
f0102e4d:	e8 34 dd ff ff       	call   f0100b86 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102e52:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102e59:	00 
f0102e5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102e61:	00 
f0102e62:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102e67:	89 04 24             	mov    %eax,(%esp)
f0102e6a:	e8 4b e4 ff ff       	call   f01012ba <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e6f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e72:	2b 15 90 2e 23 f0    	sub    0xf0232e90,%edx
f0102e78:	c1 fa 03             	sar    $0x3,%edx
f0102e7b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e7e:	89 d0                	mov    %edx,%eax
f0102e80:	c1 e8 0c             	shr    $0xc,%eax
f0102e83:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0102e89:	72 20                	jb     f0102eab <mem_init+0x13db>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102e8f:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0102e96:	f0 
f0102e97:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102e9e:	00 
f0102e9f:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0102ea6:	e8 da d1 ff ff       	call   f0100085 <_panic>
	return (void *)(pa + KERNBASE);
f0102eab:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102eb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102eb4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102eba:	f6 00 01             	testb  $0x1,(%eax)
f0102ebd:	74 24                	je     f0102ee3 <mem_init+0x1413>
f0102ebf:	c7 44 24 0c bf 7e 10 	movl   $0xf0107ebf,0xc(%esp)
f0102ec6:	f0 
f0102ec7:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102ece:	f0 
f0102ecf:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0102ed6:	00 
f0102ed7:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102ede:	e8 a2 d1 ff ff       	call   f0100085 <_panic>
f0102ee3:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102ee6:	39 d0                	cmp    %edx,%eax
f0102ee8:	75 d0                	jne    f0102eba <mem_init+0x13ea>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102eea:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0102eef:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102ef5:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102efb:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102efe:	a3 30 22 23 f0       	mov    %eax,0xf0232230

	// free the pages we took
	page_free(pp0);
f0102f03:	89 3c 24             	mov    %edi,(%esp)
f0102f06:	e8 7b dc ff ff       	call   f0100b86 <page_free>
	page_free(pp1);
f0102f0b:	89 1c 24             	mov    %ebx,(%esp)
f0102f0e:	e8 73 dc ff ff       	call   f0100b86 <page_free>
	page_free(pp2);
f0102f13:	89 34 24             	mov    %esi,(%esp)
f0102f16:	e8 6b dc ff ff       	call   f0100b86 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102f1b:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102f22:	00 
f0102f23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f2a:	e8 10 e6 ff ff       	call   f010153f <mmio_map_region>
f0102f2f:	89 c3                	mov    %eax,%ebx
f0102f31:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102f34:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102f3b:	00 
f0102f3c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f43:	e8 f7 e5 ff ff       	call   f010153f <mmio_map_region>
f0102f48:	89 c7                	mov    %eax,%edi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102f4a:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102f50:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f56:	76 07                	jbe    f0102f5f <mem_init+0x148f>
f0102f58:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102f5d:	76 24                	jbe    f0102f83 <mem_init+0x14b3>
f0102f5f:	c7 44 24 0c 70 79 10 	movl   $0xf0107970,0xc(%esp)
f0102f66:	f0 
f0102f67:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102f6e:	f0 
f0102f6f:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f0102f76:	00 
f0102f77:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102f7e:	e8 02 d1 ff ff       	call   f0100085 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102f83:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0102f89:	76 0e                	jbe    f0102f99 <mem_init+0x14c9>
f0102f8b:	8d 97 a0 1f 00 00    	lea    0x1fa0(%edi),%edx
f0102f91:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102f97:	76 24                	jbe    f0102fbd <mem_init+0x14ed>
f0102f99:	c7 44 24 0c 98 79 10 	movl   $0xf0107998,0xc(%esp)
f0102fa0:	f0 
f0102fa1:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102fa8:	f0 
f0102fa9:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0102fb0:	00 
f0102fb1:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102fb8:	e8 c8 d0 ff ff       	call   f0100085 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102fbd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102fc0:	09 fa                	or     %edi,%edx
f0102fc2:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102fc8:	74 24                	je     f0102fee <mem_init+0x151e>
f0102fca:	c7 44 24 0c c0 79 10 	movl   $0xf01079c0,0xc(%esp)
f0102fd1:	f0 
f0102fd2:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0102fd9:	f0 
f0102fda:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0102fe1:	00 
f0102fe2:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0102fe9:	e8 97 d0 ff ff       	call   f0100085 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102fee:	39 c7                	cmp    %eax,%edi
f0102ff0:	73 24                	jae    f0103016 <mem_init+0x1546>
f0102ff2:	c7 44 24 0c d6 7e 10 	movl   $0xf0107ed6,0xc(%esp)
f0102ff9:	f0 
f0102ffa:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0103001:	f0 
f0103002:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0103009:	00 
f010300a:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103011:	e8 6f d0 ff ff       	call   f0100085 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0103016:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103019:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010301e:	e8 fd da ff ff       	call   f0100b20 <check_va2pa>
f0103023:	85 c0                	test   %eax,%eax
f0103025:	74 24                	je     f010304b <mem_init+0x157b>
f0103027:	c7 44 24 0c e8 79 10 	movl   $0xf01079e8,0xc(%esp)
f010302e:	f0 
f010302f:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0103036:	f0 
f0103037:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f010303e:	00 
f010303f:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103046:	e8 3a d0 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010304b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010304e:	81 c2 00 10 00 00    	add    $0x1000,%edx
f0103054:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103057:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010305c:	e8 bf da ff ff       	call   f0100b20 <check_va2pa>
f0103061:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103066:	74 24                	je     f010308c <mem_init+0x15bc>
f0103068:	c7 44 24 0c 0c 7a 10 	movl   $0xf0107a0c,0xc(%esp)
f010306f:	f0 
f0103070:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0103077:	f0 
f0103078:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f010307f:	00 
f0103080:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103087:	e8 f9 cf ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010308c:	89 fa                	mov    %edi,%edx
f010308e:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0103093:	e8 88 da ff ff       	call   f0100b20 <check_va2pa>
f0103098:	85 c0                	test   %eax,%eax
f010309a:	74 24                	je     f01030c0 <mem_init+0x15f0>
f010309c:	c7 44 24 0c 3c 7a 10 	movl   $0xf0107a3c,0xc(%esp)
f01030a3:	f0 
f01030a4:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01030ab:	f0 
f01030ac:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f01030b3:	00 
f01030b4:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01030bb:	e8 c5 cf ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01030c0:	8d 97 00 10 00 00    	lea    0x1000(%edi),%edx
f01030c6:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01030cb:	e8 50 da ff ff       	call   f0100b20 <check_va2pa>
f01030d0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01030d3:	74 24                	je     f01030f9 <mem_init+0x1629>
f01030d5:	c7 44 24 0c 60 7a 10 	movl   $0xf0107a60,0xc(%esp)
f01030dc:	f0 
f01030dd:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01030e4:	f0 
f01030e5:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f01030ec:	00 
f01030ed:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01030f4:	e8 8c cf ff ff       	call   f0100085 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01030f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103100:	00 
f0103101:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103105:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010310a:	89 04 24             	mov    %eax,(%esp)
f010310d:	e8 a8 e1 ff ff       	call   f01012ba <pgdir_walk>
f0103112:	f6 00 1a             	testb  $0x1a,(%eax)
f0103115:	75 24                	jne    f010313b <mem_init+0x166b>
f0103117:	c7 44 24 0c 8c 7a 10 	movl   $0xf0107a8c,0xc(%esp)
f010311e:	f0 
f010311f:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0103126:	f0 
f0103127:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f010312e:	00 
f010312f:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103136:	e8 4a cf ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010313b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103142:	00 
f0103143:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103147:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010314c:	89 04 24             	mov    %eax,(%esp)
f010314f:	e8 66 e1 ff ff       	call   f01012ba <pgdir_walk>
f0103154:	f6 00 04             	testb  $0x4,(%eax)
f0103157:	74 24                	je     f010317d <mem_init+0x16ad>
f0103159:	c7 44 24 0c d0 7a 10 	movl   $0xf0107ad0,0xc(%esp)
f0103160:	f0 
f0103161:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0103168:	f0 
f0103169:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0103170:	00 
f0103171:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103178:	e8 08 cf ff ff       	call   f0100085 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010317d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103184:	00 
f0103185:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103189:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f010318e:	89 04 24             	mov    %eax,(%esp)
f0103191:	e8 24 e1 ff ff       	call   f01012ba <pgdir_walk>
f0103196:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010319c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031a3:	00 
f01031a4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01031a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01031ab:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01031b0:	89 04 24             	mov    %eax,(%esp)
f01031b3:	e8 02 e1 ff ff       	call   f01012ba <pgdir_walk>
f01031b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f01031be:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01031c5:	00 
f01031c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01031ca:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01031cf:	89 04 24             	mov    %eax,(%esp)
f01031d2:	e8 e3 e0 ff ff       	call   f01012ba <pgdir_walk>
f01031d7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f01031dd:	c7 04 24 e8 7e 10 f0 	movl   $0xf0107ee8,(%esp)
f01031e4:	e8 36 10 00 00       	call   f010421f <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages) , PTE_U | PTE_P);
f01031e9:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031ee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031f3:	77 20                	ja     f0103215 <mem_init+0x1745>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031f9:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0103200:	f0 
f0103201:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0103208:	00 
f0103209:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103210:	e8 70 ce ff ff       	call   f0100085 <_panic>
f0103215:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f010321c:	00 
f010321d:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103223:	89 04 24             	mov    %eax,(%esp)
f0103226:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010322b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103230:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0103235:	e8 78 e2 ff ff       	call   f01014b2 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t)pages, PTSIZE, PADDR(pages) , PTE_W | PTE_P); 
f010323a:	a1 90 2e 23 f0       	mov    0xf0232e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010323f:	89 c2                	mov    %eax,%edx
f0103241:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103246:	77 20                	ja     f0103268 <mem_init+0x1798>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103248:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010324c:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0103253:	f0 
f0103254:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f010325b:	00 
f010325c:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103263:	e8 1d ce ff ff       	call   f0100085 <_panic>
f0103268:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010326f:	00 
f0103270:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103276:	89 04 24             	mov    %eax,(%esp)
f0103279:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010327e:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0103283:	e8 2a e2 ff ff       	call   f01014b2 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	boot_map_region(kern_pgdir ,UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f0103288:	a1 38 22 23 f0       	mov    0xf0232238,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010328d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103292:	77 20                	ja     f01032b4 <mem_init+0x17e4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103294:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103298:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f010329f:	f0 
f01032a0:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f01032a7:	00 
f01032a8:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01032af:	e8 d1 cd ff ff       	call   f0100085 <_panic>
f01032b4:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01032bb:	00 
f01032bc:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01032c2:	89 04 24             	mov    %eax,(%esp)
f01032c5:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01032ca:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01032cf:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01032d4:	e8 d9 e1 ff ff       	call   f01014b2 <boot_map_region>
	boot_map_region(kern_pgdir ,(uintptr_t)envs, PTSIZE, PADDR(envs), PTE_W | PTE_P);
f01032d9:	a1 38 22 23 f0       	mov    0xf0232238,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032de:	89 c2                	mov    %eax,%edx
f01032e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032e5:	77 20                	ja     f0103307 <mem_init+0x1837>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032eb:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f01032f2:	f0 
f01032f3:	c7 44 24 04 d4 00 00 	movl   $0xd4,0x4(%esp)
f01032fa:	00 
f01032fb:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103302:	e8 7e cd ff ff       	call   f0100085 <_panic>
f0103307:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010330e:	00 
f010330f:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103315:	89 04 24             	mov    %eax,(%esp)
f0103318:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010331d:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0103322:	e8 8b e1 ff ff       	call   f01014b2 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103327:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f010332c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103331:	77 20                	ja     f0103353 <mem_init+0x1883>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103333:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103337:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f010333e:	f0 
f010333f:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
f0103346:	00 
f0103347:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010334e:	e8 32 cd ff ff       	call   f0100085 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack),PTE_W | PTE_P );
f0103353:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010335a:	00 
f010335b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103360:	89 04 24             	mov    %eax,(%esp)
f0103363:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103368:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010336d:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0103372:	e8 3b e1 ff ff       	call   f01014b2 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 0xFFFFFFFF-KERNBASE+1, 0, PTE_W | PTE_P ); 
f0103377:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f010337e:	00 
f010337f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103386:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010338b:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103390:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f0103395:	e8 18 e1 ff ff       	call   f01014b2 <boot_map_region>
f010339a:	c7 45 cc 00 40 23 f0 	movl   $0xf0234000,-0x34(%ebp)
f01033a1:	bb 00 40 23 f0       	mov    $0xf0234000,%ebx
f01033a6:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033ab:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01033b1:	77 20                	ja     f01033d3 <mem_init+0x1903>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01033b7:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f01033be:	f0 
f01033bf:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
f01033c6:	00 
f01033c7:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01033ce:	e8 b2 cc ff ff       	call   f0100085 <_panic>
	// LAB 4: Your code here:
	int i;
	uintptr_t cur;
	for(i=0;i<NCPU;i++) {
		cur=KSTACKTOP-i*(KSTKSIZE+KSTKGAP);
		boot_map_region(kern_pgdir, cur - KSTKSIZE, KSTKSIZE,
f01033d3:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01033da:	00 
f01033db:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01033e1:	89 04 24             	mov    %eax,(%esp)
f01033e4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01033e9:	89 f2                	mov    %esi,%edx
f01033eb:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
f01033f0:	e8 bd e0 ff ff       	call   f01014b2 <boot_map_region>
f01033f5:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01033fb:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	uintptr_t cur;
	for(i=0;i<NCPU;i++) {
f0103401:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103407:	75 a2                	jne    f01033ab <mem_init+0x18db>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103409:	8b 1d 8c 2e 23 f0    	mov    0xf0232e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010340f:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f0103414:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
f010341b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103421:	be 00 00 00 00       	mov    $0x0,%esi
f0103426:	eb 70                	jmp    f0103498 <mem_init+0x19c8>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0103428:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f010342e:	89 d8                	mov    %ebx,%eax
f0103430:	e8 eb d6 ff ff       	call   f0100b20 <check_va2pa>
f0103435:	8b 15 90 2e 23 f0    	mov    0xf0232e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010343b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103441:	77 20                	ja     f0103463 <mem_init+0x1993>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103443:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103447:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f010344e:	f0 
f010344f:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0103456:	00 
f0103457:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010345e:	e8 22 cc ff ff       	call   f0100085 <_panic>
f0103463:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010346a:	39 d0                	cmp    %edx,%eax
f010346c:	74 24                	je     f0103492 <mem_init+0x19c2>
f010346e:	c7 44 24 0c 04 7b 10 	movl   $0xf0107b04,0xc(%esp)
f0103475:	f0 
f0103476:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010347d:	f0 
f010347e:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0103485:	00 
f0103486:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010348d:	e8 f3 cb ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103492:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103498:	39 f7                	cmp    %esi,%edi
f010349a:	77 8c                	ja     f0103428 <mem_init+0x1958>
f010349c:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01034a1:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f01034a7:	89 d8                	mov    %ebx,%eax
f01034a9:	e8 72 d6 ff ff       	call   f0100b20 <check_va2pa>
f01034ae:	8b 15 38 22 23 f0    	mov    0xf0232238,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034b4:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01034ba:	77 20                	ja     f01034dc <mem_init+0x1a0c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01034c0:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f01034c7:	f0 
f01034c8:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f01034cf:	00 
f01034d0:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01034d7:	e8 a9 cb ff ff       	call   f0100085 <_panic>
f01034dc:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01034e3:	39 d0                	cmp    %edx,%eax
f01034e5:	74 24                	je     f010350b <mem_init+0x1a3b>
f01034e7:	c7 44 24 0c 38 7b 10 	movl   $0xf0107b38,0xc(%esp)
f01034ee:	f0 
f01034ef:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01034f6:	f0 
f01034f7:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f01034fe:	00 
f01034ff:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103506:	e8 7a cb ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010350b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103511:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0103517:	75 88                	jne    f01034a1 <mem_init+0x19d1>
f0103519:	be 00 00 00 00       	mov    $0x0,%esi
f010351e:	eb 3b                	jmp    f010355b <mem_init+0x1a8b>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0103520:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0103526:	89 d8                	mov    %ebx,%eax
f0103528:	e8 f3 d5 ff ff       	call   f0100b20 <check_va2pa>
f010352d:	39 c6                	cmp    %eax,%esi
f010352f:	74 24                	je     f0103555 <mem_init+0x1a85>
f0103531:	c7 44 24 0c 6c 7b 10 	movl   $0xf0107b6c,0xc(%esp)
f0103538:	f0 
f0103539:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0103540:	f0 
f0103541:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0103548:	00 
f0103549:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103550:	e8 30 cb ff ff       	call   f0100085 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103555:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010355b:	a1 88 2e 23 f0       	mov    0xf0232e88,%eax
f0103560:	c1 e0 0c             	shl    $0xc,%eax
f0103563:	39 c6                	cmp    %eax,%esi
f0103565:	72 b9                	jb     f0103520 <mem_init+0x1a50>
f0103567:	c7 45 d0 00 00 ff ef 	movl   $0xefff0000,-0x30(%ebp)

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010356e:	89 df                	mov    %ebx,%edi
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103570:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103573:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0103576:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103579:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010357f:	89 c6                	mov    %eax,%esi
f0103581:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0103587:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010358a:	81 c2 00 00 01 00    	add    $0x10000,%edx
f0103590:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103593:	89 da                	mov    %ebx,%edx
f0103595:	89 f8                	mov    %edi,%eax
f0103597:	e8 84 d5 ff ff       	call   f0100b20 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010359c:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f01035a3:	77 23                	ja     f01035c8 <mem_init+0x1af8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035a5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01035a8:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01035ac:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f01035b3:	f0 
f01035b4:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01035bb:	00 
f01035bc:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01035c3:	e8 bd ca ff ff       	call   f0100085 <_panic>
f01035c8:	39 f0                	cmp    %esi,%eax
f01035ca:	74 24                	je     f01035f0 <mem_init+0x1b20>
f01035cc:	c7 44 24 0c 94 7b 10 	movl   $0xf0107b94,0xc(%esp)
f01035d3:	f0 
f01035d4:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01035db:	f0 
f01035dc:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01035e3:	00 
f01035e4:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01035eb:	e8 95 ca ff ff       	call   f0100085 <_panic>
f01035f0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01035f6:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01035fc:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01035ff:	0f 85 9e 01 00 00    	jne    f01037a3 <mem_init+0x1cd3>
f0103605:	bb 00 00 00 00       	mov    $0x0,%ebx
f010360a:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010360d:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0103610:	89 f8                	mov    %edi,%eax
f0103612:	e8 09 d5 ff ff       	call   f0100b20 <check_va2pa>
f0103617:	83 f8 ff             	cmp    $0xffffffff,%eax
f010361a:	74 24                	je     f0103640 <mem_init+0x1b70>
f010361c:	c7 44 24 0c dc 7b 10 	movl   $0xf0107bdc,0xc(%esp)
f0103623:	f0 
f0103624:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010362b:	f0 
f010362c:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0103633:	00 
f0103634:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010363b:	e8 45 ca ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0103640:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103646:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f010364c:	75 bf                	jne    f010360d <mem_init+0x1b3d>
f010364e:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f0103655:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010365c:	81 7d d0 00 00 f7 ef 	cmpl   $0xeff70000,-0x30(%ebp)
f0103663:	0f 85 07 ff ff ff    	jne    f0103570 <mem_init+0x1aa0>
f0103669:	89 fb                	mov    %edi,%ebx
f010366b:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103670:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103676:	83 fa 04             	cmp    $0x4,%edx
f0103679:	77 2e                	ja     f01036a9 <mem_init+0x1bd9>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010367b:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010367f:	0f 85 aa 00 00 00    	jne    f010372f <mem_init+0x1c5f>
f0103685:	c7 44 24 0c 01 7f 10 	movl   $0xf0107f01,0xc(%esp)
f010368c:	f0 
f010368d:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f0103694:	f0 
f0103695:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f010369c:	00 
f010369d:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01036a4:	e8 dc c9 ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01036a9:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01036ae:	76 55                	jbe    f0103705 <mem_init+0x1c35>
				assert(pgdir[i] & PTE_P);
f01036b0:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01036b3:	f6 c2 01             	test   $0x1,%dl
f01036b6:	75 24                	jne    f01036dc <mem_init+0x1c0c>
f01036b8:	c7 44 24 0c 01 7f 10 	movl   $0xf0107f01,0xc(%esp)
f01036bf:	f0 
f01036c0:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01036c7:	f0 
f01036c8:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01036cf:	00 
f01036d0:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f01036d7:	e8 a9 c9 ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f01036dc:	f6 c2 02             	test   $0x2,%dl
f01036df:	75 4e                	jne    f010372f <mem_init+0x1c5f>
f01036e1:	c7 44 24 0c 12 7f 10 	movl   $0xf0107f12,0xc(%esp)
f01036e8:	f0 
f01036e9:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01036f0:	f0 
f01036f1:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f01036f8:	00 
f01036f9:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103700:	e8 80 c9 ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103705:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0103709:	74 24                	je     f010372f <mem_init+0x1c5f>
f010370b:	c7 44 24 0c 23 7f 10 	movl   $0xf0107f23,0xc(%esp)
f0103712:	f0 
f0103713:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010371a:	f0 
f010371b:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0103722:	00 
f0103723:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f010372a:	e8 56 c9 ff ff       	call   f0100085 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010372f:	83 c0 01             	add    $0x1,%eax
f0103732:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103737:	0f 85 33 ff ff ff    	jne    f0103670 <mem_init+0x1ba0>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010373d:	c7 04 24 00 7c 10 f0 	movl   $0xf0107c00,(%esp)
f0103744:	e8 d6 0a 00 00       	call   f010421f <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103749:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010374e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103753:	77 20                	ja     f0103775 <mem_init+0x1ca5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103755:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103759:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0103760:	f0 
f0103761:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
f0103768:	00 
f0103769:	c7 04 24 1f 7c 10 f0 	movl   $0xf0107c1f,(%esp)
f0103770:	e8 10 c9 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103775:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010377b:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010377e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103783:	e8 49 d7 ff ff       	call   f0100ed1 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103788:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010378b:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103790:	83 e0 f3             	and    $0xfffffff3,%eax
f0103793:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f0103796:	e8 60 df ff ff       	call   f01016fb <check_page_installed_pgdir>
}
f010379b:	83 c4 3c             	add    $0x3c,%esp
f010379e:	5b                   	pop    %ebx
f010379f:	5e                   	pop    %esi
f01037a0:	5f                   	pop    %edi
f01037a1:	5d                   	pop    %ebp
f01037a2:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01037a3:	89 da                	mov    %ebx,%edx
f01037a5:	89 f8                	mov    %edi,%eax
f01037a7:	e8 74 d3 ff ff       	call   f0100b20 <check_va2pa>
f01037ac:	e9 17 fe ff ff       	jmp    f01035c8 <mem_init+0x1af8>
	...

f01037c0 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01037c0:	55                   	push   %ebp
f01037c1:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f01037c3:	b8 88 13 12 f0       	mov    $0xf0121388,%eax
f01037c8:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f01037cb:	b8 23 00 00 00       	mov    $0x23,%eax
f01037d0:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01037d2:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01037d4:	b0 10                	mov    $0x10,%al
f01037d6:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01037d8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01037da:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01037dc:	ea e3 37 10 f0 08 00 	ljmp   $0x8,$0xf01037e3
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01037e3:	b0 00                	mov    $0x0,%al
f01037e5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01037e8:	5d                   	pop    %ebp
f01037e9:	c3                   	ret    

f01037ea <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01037ea:	55                   	push   %ebp
f01037eb:	89 e5                	mov    %esp,%ebp
f01037ed:	b8 84 ef 01 00       	mov    $0x1ef84,%eax
f01037f2:	ba 00 00 00 00       	mov    $0x0,%edx
	
	int i;
	env_free_list=NULL;
	ENVDEBUG("NENV -1: %u\n",NENV-1);
	for(i=NENV-1;i>=0;i--) {
		envs[i].env_id=0;
f01037f7:	8b 0d 38 22 23 f0    	mov    0xf0232238,%ecx
f01037fd:	c7 44 01 48 00 00 00 	movl   $0x0,0x48(%ecx,%eax,1)
f0103804:	00 
		envs[i].env_link=env_free_list;
f0103805:	8b 0d 38 22 23 f0    	mov    0xf0232238,%ecx
f010380b:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
		env_free_list=&envs[i];
f010380f:	89 c2                	mov    %eax,%edx
f0103811:	03 15 38 22 23 f0    	add    0xf0232238,%edx
		envs[i].env_parent_id=0;
f0103817:	c7 42 4c 00 00 00 00 	movl   $0x0,0x4c(%edx)
		envs[i].env_pgdir=NULL;
f010381e:	8b 0d 38 22 23 f0    	mov    0xf0232238,%ecx
f0103824:	c7 44 01 60 00 00 00 	movl   $0x0,0x60(%ecx,%eax,1)
f010382b:	00 
		envs[i].env_type=ENV_TYPE_USER;
f010382c:	8b 0d 38 22 23 f0    	mov    0xf0232238,%ecx
f0103832:	c7 44 01 50 00 00 00 	movl   $0x0,0x50(%ecx,%eax,1)
f0103839:	00 
		envs[i].env_status=0;
f010383a:	8b 0d 38 22 23 f0    	mov    0xf0232238,%ecx
f0103840:	c7 44 01 54 00 00 00 	movl   $0x0,0x54(%ecx,%eax,1)
f0103847:	00 
		envs[i].env_runs=0;
f0103848:	8b 0d 38 22 23 f0    	mov    0xf0232238,%ecx
f010384e:	c7 44 01 58 00 00 00 	movl   $0x0,0x58(%ecx,%eax,1)
f0103855:	00 
f0103856:	83 e8 7c             	sub    $0x7c,%eax
	// LAB 3: Your code here.
	
	int i;
	env_free_list=NULL;
	ENVDEBUG("NENV -1: %u\n",NENV-1);
	for(i=NENV-1;i>=0;i--) {
f0103859:	83 f8 84             	cmp    $0xffffff84,%eax
f010385c:	75 99                	jne    f01037f7 <env_init+0xd>
f010385e:	89 15 3c 22 23 f0    	mov    %edx,0xf023223c
		envs[i].env_runs=0;
	}
	ENVDEBUG("env_free_list: 0x%08x\n",env_free_list);

	// Per-CPU part of the initialization
	env_init_percpu();
f0103864:	e8 57 ff ff ff       	call   f01037c0 <env_init_percpu>
}
f0103869:	5d                   	pop    %ebp
f010386a:	c3                   	ret    

f010386b <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f010386b:	55                   	push   %ebp
f010386c:	89 e5                	mov    %esp,%ebp
f010386e:	83 ec 18             	sub    $0x18,%esp
f0103871:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103874:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103877:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010387a:	8b 45 08             	mov    0x8(%ebp),%eax
f010387d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103880:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103884:	85 c0                	test   %eax,%eax
f0103886:	75 17                	jne    f010389f <envid2env+0x34>
		*env_store = curenv;
f0103888:	e8 21 2d 00 00       	call   f01065ae <cpunum>
f010388d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103890:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103896:	89 06                	mov    %eax,(%esi)
f0103898:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f010389d:	eb 6b                	jmp    f010390a <envid2env+0x9f>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010389f:	89 c3                	mov    %eax,%ebx
f01038a1:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01038a7:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f01038aa:	03 1d 38 22 23 f0    	add    0xf0232238,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01038b0:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01038b4:	74 05                	je     f01038bb <envid2env+0x50>
f01038b6:	39 43 48             	cmp    %eax,0x48(%ebx)
f01038b9:	74 0d                	je     f01038c8 <envid2env+0x5d>
		*env_store = 0;
f01038bb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f01038c1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f01038c6:	eb 42                	jmp    f010390a <envid2env+0x9f>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01038c8:	84 d2                	test   %dl,%dl
f01038ca:	74 37                	je     f0103903 <envid2env+0x98>
f01038cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01038d0:	e8 d9 2c 00 00       	call   f01065ae <cpunum>
f01038d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d8:	39 98 28 30 23 f0    	cmp    %ebx,-0xfdccfd8(%eax)
f01038de:	74 23                	je     f0103903 <envid2env+0x98>
f01038e0:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01038e3:	e8 c6 2c 00 00       	call   f01065ae <cpunum>
f01038e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01038eb:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01038f1:	3b 78 48             	cmp    0x48(%eax),%edi
f01038f4:	74 0d                	je     f0103903 <envid2env+0x98>
		*env_store = 0;
f01038f6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f01038fc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103901:	eb 07                	jmp    f010390a <envid2env+0x9f>
	}

	*env_store = e;
f0103903:	89 1e                	mov    %ebx,(%esi)
f0103905:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f010390a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010390d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103910:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103913:	89 ec                	mov    %ebp,%esp
f0103915:	5d                   	pop    %ebp
f0103916:	c3                   	ret    

f0103917 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103917:	55                   	push   %ebp
f0103918:	89 e5                	mov    %esp,%ebp
f010391a:	53                   	push   %ebx
f010391b:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f010391e:	e8 8b 2c 00 00       	call   f01065ae <cpunum>
f0103923:	6b c0 74             	imul   $0x74,%eax,%eax
f0103926:	8b 98 28 30 23 f0    	mov    -0xfdccfd8(%eax),%ebx
f010392c:	e8 7d 2c 00 00       	call   f01065ae <cpunum>
f0103931:	89 43 5c             	mov    %eax,0x5c(%ebx)

	__asm __volatile("movl %0,%%esp\n"
f0103934:	8b 65 08             	mov    0x8(%ebp),%esp
f0103937:	61                   	popa   
f0103938:	07                   	pop    %es
f0103939:	1f                   	pop    %ds
f010393a:	83 c4 08             	add    $0x8,%esp
f010393d:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010393e:	c7 44 24 08 31 7f 10 	movl   $0xf0107f31,0x8(%esp)
f0103945:	f0 
f0103946:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
f010394d:	00 
f010394e:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103955:	e8 2b c7 ff ff       	call   f0100085 <_panic>

f010395a <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010395a:	55                   	push   %ebp
f010395b:	89 e5                	mov    %esp,%ebp
f010395d:	53                   	push   %ebx
f010395e:	83 ec 14             	sub    $0x14,%esp
	// LAB 3: Your code here.

	
	ENVDEBUG("start to env_run\n");

	if (curenv!=NULL) {
f0103961:	e8 48 2c 00 00       	call   f01065ae <cpunum>
f0103966:	6b c0 74             	imul   $0x74,%eax,%eax
f0103969:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f0103970:	74 29                	je     f010399b <env_run+0x41>
		if( curenv->env_status==ENV_RUNNING ) {
f0103972:	e8 37 2c 00 00       	call   f01065ae <cpunum>
f0103977:	6b c0 74             	imul   $0x74,%eax,%eax
f010397a:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103980:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103984:	75 15                	jne    f010399b <env_run+0x41>
			curenv->env_status=ENV_RUNNABLE;
f0103986:	e8 23 2c 00 00       	call   f01065ae <cpunum>
f010398b:	6b c0 74             	imul   $0x74,%eax,%eax
f010398e:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103994:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
	}

	curenv=e;
f010399b:	e8 0e 2c 00 00       	call   f01065ae <cpunum>
f01039a0:	bb 20 30 23 f0       	mov    $0xf0233020,%ebx
f01039a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01039a8:	8b 55 08             	mov    0x8(%ebp),%edx
f01039ab:	89 54 18 08          	mov    %edx,0x8(%eax,%ebx,1)
	curenv->env_status=ENV_RUNNING;
f01039af:	e8 fa 2b 00 00       	call   f01065ae <cpunum>
f01039b4:	6b c0 74             	imul   $0x74,%eax,%eax
f01039b7:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01039bb:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f01039c2:	e8 e7 2b 00 00       	call   f01065ae <cpunum>
f01039c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01039ca:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01039ce:	83 40 58 01          	addl   $0x1,0x58(%eax)
	ENVDEBUG("curenv->env_pgdir: 0x%08x, PADDR: 0x%08x\n",curenv->env_pgdir,PADDR(curenv->env_pgdir));	
	lcr3(PADDR(curenv->env_pgdir));
f01039d2:	e8 d7 2b 00 00       	call   f01065ae <cpunum>
f01039d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01039da:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01039de:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039e1:	89 c2                	mov    %eax,%edx
f01039e3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039e8:	77 20                	ja     f0103a0a <env_run+0xb0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039ee:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f01039f5:	f0 
f01039f6:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
f01039fd:	00 
f01039fe:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103a05:	e8 7b c6 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103a0a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103a10:	0f 22 da             	mov    %edx,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103a13:	c7 04 24 20 14 12 f0 	movl   $0xf0121420,(%esp)
f0103a1a:	e8 4d 2e 00 00       	call   f010686c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103a1f:	f3 90                	pause  
	ENVDEBUG("end with lcr3\n");
	unlock_kernel();
	env_pop_tf(&(curenv->env_tf));
f0103a21:	e8 88 2b 00 00       	call   f01065ae <cpunum>
f0103a26:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a29:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103a2f:	89 04 24             	mov    %eax,(%esp)
f0103a32:	e8 e0 fe ff ff       	call   f0103917 <env_pop_tf>

f0103a37 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103a37:	55                   	push   %ebp
f0103a38:	89 e5                	mov    %esp,%ebp
f0103a3a:	57                   	push   %edi
f0103a3b:	56                   	push   %esi
f0103a3c:	53                   	push   %ebx
f0103a3d:	83 ec 2c             	sub    $0x2c,%esp
f0103a40:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103a43:	e8 66 2b 00 00       	call   f01065ae <cpunum>
f0103a48:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a4b:	39 b8 28 30 23 f0    	cmp    %edi,-0xfdccfd8(%eax)
f0103a51:	75 35                	jne    f0103a88 <env_free+0x51>
		lcr3(PADDR(kern_pgdir));
f0103a53:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103a58:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103a5d:	77 20                	ja     f0103a7f <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103a5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a63:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0103a6a:	f0 
f0103a6b:	c7 44 24 04 cb 01 00 	movl   $0x1cb,0x4(%esp)
f0103a72:	00 
f0103a73:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103a7a:	e8 06 c6 ff ff       	call   f0100085 <_panic>
f0103a7f:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103a85:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103a88:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103a8b:	e8 1e 2b 00 00       	call   f01065ae <cpunum>
f0103a90:	6b d0 74             	imul   $0x74,%eax,%edx
f0103a93:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a98:	83 ba 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%edx)
f0103a9f:	74 11                	je     f0103ab2 <env_free+0x7b>
f0103aa1:	e8 08 2b 00 00       	call   f01065ae <cpunum>
f0103aa6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aa9:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103aaf:	8b 40 48             	mov    0x48(%eax),%eax
f0103ab2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103aba:	c7 04 24 48 7f 10 f0 	movl   $0xf0107f48,(%esp)
f0103ac1:	e8 59 07 00 00       	call   f010421f <cprintf>
f0103ac6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103acd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103ad0:	c1 e0 02             	shl    $0x2,%eax
f0103ad3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103ad6:	8b 47 60             	mov    0x60(%edi),%eax
f0103ad9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103adc:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103adf:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103ae5:	0f 84 b8 00 00 00    	je     f0103ba3 <env_free+0x16c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103aeb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103af1:	89 f0                	mov    %esi,%eax
f0103af3:	c1 e8 0c             	shr    $0xc,%eax
f0103af6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103af9:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0103aff:	72 20                	jb     f0103b21 <env_free+0xea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103b01:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103b05:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0103b0c:	f0 
f0103b0d:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
f0103b14:	00 
f0103b15:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103b1c:	e8 64 c5 ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b21:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103b24:	c1 e2 16             	shl    $0x16,%edx
f0103b27:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103b2a:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0103b2f:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103b36:	01 
f0103b37:	74 17                	je     f0103b50 <env_free+0x119>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103b39:	89 d8                	mov    %ebx,%eax
f0103b3b:	c1 e0 0c             	shl    $0xc,%eax
f0103b3e:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103b41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b45:	8b 47 60             	mov    0x60(%edi),%eax
f0103b48:	89 04 24             	mov    %eax,(%esp)
f0103b4b:	e8 d5 da ff ff       	call   f0101625 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103b50:	83 c3 01             	add    $0x1,%ebx
f0103b53:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103b59:	75 d4                	jne    f0103b2f <env_free+0xf8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103b5b:	8b 47 60             	mov    0x60(%edi),%eax
f0103b5e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103b61:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b68:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b6b:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0103b71:	72 1c                	jb     f0103b8f <env_free+0x158>
		panic("pa2page called with invalid pa");
f0103b73:	c7 44 24 08 c4 73 10 	movl   $0xf01073c4,0x8(%esp)
f0103b7a:	f0 
f0103b7b:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b82:	00 
f0103b83:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0103b8a:	e8 f6 c4 ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f0103b8f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b92:	c1 e0 03             	shl    $0x3,%eax
f0103b95:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
f0103b9b:	89 04 24             	mov    %eax,(%esp)
f0103b9e:	e8 3f d0 ff ff       	call   f0100be2 <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103ba3:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103ba7:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103bae:	0f 85 19 ff ff ff    	jne    f0103acd <env_free+0x96>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103bb4:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103bb7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103bbc:	77 20                	ja     f0103bde <env_free+0x1a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103bbe:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bc2:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0103bc9:	f0 
f0103bca:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
f0103bd1:	00 
f0103bd2:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103bd9:	e8 a7 c4 ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0103bde:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103be5:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103beb:	c1 e8 0c             	shr    $0xc,%eax
f0103bee:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f0103bf4:	72 1c                	jb     f0103c12 <env_free+0x1db>
		panic("pa2page called with invalid pa");
f0103bf6:	c7 44 24 08 c4 73 10 	movl   $0xf01073c4,0x8(%esp)
f0103bfd:	f0 
f0103bfe:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103c05:	00 
f0103c06:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0103c0d:	e8 73 c4 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f0103c12:	c1 e0 03             	shl    $0x3,%eax
f0103c15:	03 05 90 2e 23 f0    	add    0xf0232e90,%eax
f0103c1b:	89 04 24             	mov    %eax,(%esp)
f0103c1e:	e8 bf cf ff ff       	call   f0100be2 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103c23:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103c2a:	a1 3c 22 23 f0       	mov    0xf023223c,%eax
f0103c2f:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103c32:	89 3d 3c 22 23 f0    	mov    %edi,0xf023223c
}
f0103c38:	83 c4 2c             	add    $0x2c,%esp
f0103c3b:	5b                   	pop    %ebx
f0103c3c:	5e                   	pop    %esi
f0103c3d:	5f                   	pop    %edi
f0103c3e:	5d                   	pop    %ebp
f0103c3f:	c3                   	ret    

f0103c40 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103c40:	55                   	push   %ebp
f0103c41:	89 e5                	mov    %esp,%ebp
f0103c43:	53                   	push   %ebx
f0103c44:	83 ec 14             	sub    $0x14,%esp
f0103c47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103c4a:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103c4e:	75 19                	jne    f0103c69 <env_destroy+0x29>
f0103c50:	e8 59 29 00 00       	call   f01065ae <cpunum>
f0103c55:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c58:	39 98 28 30 23 f0    	cmp    %ebx,-0xfdccfd8(%eax)
f0103c5e:	74 09                	je     f0103c69 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103c60:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103c67:	eb 2f                	jmp    f0103c98 <env_destroy+0x58>
	}

	env_free(e);
f0103c69:	89 1c 24             	mov    %ebx,(%esp)
f0103c6c:	e8 c6 fd ff ff       	call   f0103a37 <env_free>

	if (curenv == e) {
f0103c71:	e8 38 29 00 00       	call   f01065ae <cpunum>
f0103c76:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c79:	39 98 28 30 23 f0    	cmp    %ebx,-0xfdccfd8(%eax)
f0103c7f:	75 17                	jne    f0103c98 <env_destroy+0x58>
		curenv = NULL;
f0103c81:	e8 28 29 00 00       	call   f01065ae <cpunum>
f0103c86:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c89:	c7 80 28 30 23 f0 00 	movl   $0x0,-0xfdccfd8(%eax)
f0103c90:	00 00 00 
		sched_yield();
f0103c93:	e8 22 10 00 00       	call   f0104cba <sched_yield>
	}
}
f0103c98:	83 c4 14             	add    $0x14,%esp
f0103c9b:	5b                   	pop    %ebx
f0103c9c:	5d                   	pop    %ebp
f0103c9d:	c3                   	ret    

f0103c9e <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103c9e:	55                   	push   %ebp
f0103c9f:	89 e5                	mov    %esp,%ebp
f0103ca1:	53                   	push   %ebx
f0103ca2:	83 ec 14             	sub    $0x14,%esp
	ENVDEBUG("start to env_alloc\n");
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103ca5:	8b 1d 3c 22 23 f0    	mov    0xf023223c,%ebx
f0103cab:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f0103cb0:	85 db                	test   %ebx,%ebx
f0103cb2:	0f 84 ae 01 00 00    	je     f0103e66 <env_alloc+0x1c8>
	ENVDEBUG("start to env_setup_vm\n");
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103cb8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103cbf:	e8 72 d5 ff ff       	call   f0101236 <page_alloc>
f0103cc4:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0103cc9:	85 c0                	test   %eax,%eax
f0103ccb:	0f 84 95 01 00 00    	je     f0103e66 <env_alloc+0x1c8>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	(p->pp_ref)++;
f0103cd1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103cd6:	2b 05 90 2e 23 f0    	sub    0xf0232e90,%eax
f0103cdc:	c1 f8 03             	sar    $0x3,%eax
f0103cdf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103ce2:	89 c2                	mov    %eax,%edx
f0103ce4:	c1 ea 0c             	shr    $0xc,%edx
f0103ce7:	3b 15 88 2e 23 f0    	cmp    0xf0232e88,%edx
f0103ced:	72 20                	jb     f0103d0f <env_alloc+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103cef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cf3:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0103cfa:	f0 
f0103cfb:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103d02:	00 
f0103d03:	c7 04 24 2b 7c 10 f0 	movl   $0xf0107c2b,(%esp)
f0103d0a:	e8 76 c3 ff ff       	call   f0100085 <_panic>
	e->env_pgdir=page2kva(p);
f0103d0f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103d14:	89 43 60             	mov    %eax,0x60(%ebx)
	memset(e->env_pgdir, 0, PGSIZE);
f0103d17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103d1e:	00 
f0103d1f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d26:	00 
f0103d27:	89 04 24             	mov    %eax,(%esp)
f0103d2a:	e8 02 22 00 00       	call   f0105f31 <memset>
f0103d2f:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	for(i=PDX(UTOP);i<1024;i++) {
		e->env_pgdir[i]=kern_pgdir[i];
f0103d34:	8b 53 60             	mov    0x60(%ebx),%edx
f0103d37:	8b 0d 8c 2e 23 f0    	mov    0xf0232e8c,%ecx
f0103d3d:	8b 0c 01             	mov    (%ecx,%eax,1),%ecx
f0103d40:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103d43:	83 c0 04             	add    $0x4,%eax

	// LAB 3: Your code here.
	(p->pp_ref)++;
	e->env_pgdir=page2kva(p);
	memset(e->env_pgdir, 0, PGSIZE);
	for(i=PDX(UTOP);i<1024;i++) {
f0103d46:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103d4b:	75 e7                	jne    f0103d34 <env_alloc+0x96>
		e->env_pgdir[i]=kern_pgdir[i];
	}
//	memcpy(e->env_pgdir,kern_pgdir,PGSIZE);	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103d4d:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d50:	89 c2                	mov    %eax,%edx
f0103d52:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d57:	77 20                	ja     f0103d79 <env_alloc+0xdb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d5d:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0103d64:	f0 
f0103d65:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
f0103d6c:	00 
f0103d6d:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103d74:	e8 0c c3 ff ff       	call   f0100085 <_panic>
f0103d79:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103d7f:	83 ca 05             	or     $0x5,%edx
f0103d82:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103d88:	8b 43 48             	mov    0x48(%ebx),%eax
f0103d8b:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103d90:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103d95:	7f 05                	jg     f0103d9c <env_alloc+0xfe>
f0103d97:	b8 00 10 00 00       	mov    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103d9c:	89 da                	mov    %ebx,%edx
f0103d9e:	2b 15 38 22 23 f0    	sub    0xf0232238,%edx
f0103da4:	c1 fa 02             	sar    $0x2,%edx
f0103da7:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103dad:	09 d0                	or     %edx,%eax
f0103daf:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103db2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103db5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103db8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103dbf:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103dc6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103dcd:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103dd4:	00 
f0103dd5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103ddc:	00 
f0103ddd:	89 1c 24             	mov    %ebx,(%esp)
f0103de0:	e8 4c 21 00 00       	call   f0105f31 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103de5:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103deb:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103df1:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103df7:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103dfe:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103e04:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103e0b:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103e12:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103e16:	8b 43 44             	mov    0x44(%ebx),%eax
f0103e19:	a3 3c 22 23 f0       	mov    %eax,0xf023223c
	*newenv_store = e;
f0103e1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e21:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103e23:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103e26:	e8 83 27 00 00       	call   f01065ae <cpunum>
f0103e2b:	6b d0 74             	imul   $0x74,%eax,%edx
f0103e2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e33:	83 ba 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%edx)
f0103e3a:	74 11                	je     f0103e4d <env_alloc+0x1af>
f0103e3c:	e8 6d 27 00 00       	call   f01065ae <cpunum>
f0103e41:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e44:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0103e4a:	8b 40 48             	mov    0x48(%eax),%eax
f0103e4d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103e51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e55:	c7 04 24 5e 7f 10 f0 	movl   $0xf0107f5e,(%esp)
f0103e5c:	e8 be 03 00 00       	call   f010421f <cprintf>
f0103e61:	ba 00 00 00 00       	mov    $0x0,%edx
	return 0;
}
f0103e66:	89 d0                	mov    %edx,%eax
f0103e68:	83 c4 14             	add    $0x14,%esp
f0103e6b:	5b                   	pop    %ebx
f0103e6c:	5d                   	pop    %ebp
f0103e6d:	c3                   	ret    

f0103e6e <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103e6e:	55                   	push   %ebp
f0103e6f:	89 e5                	mov    %esp,%ebp
f0103e71:	57                   	push   %edi
f0103e72:	56                   	push   %esi
f0103e73:	53                   	push   %ebx
f0103e74:	83 ec 2c             	sub    $0x2c,%esp
f0103e77:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)i
	ENVDEBUG("region_alloc start\n");
	uint32_t i;
	uintptr_t _va=ROUNDDOWN((uintptr_t)va,PGSIZE);
f0103e79:	89 d0                	mov    %edx,%eax
f0103e7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103e80:	89 45 e0             	mov    %eax,-0x20(%ebp)
	pte_t* pte;
	len+=((uintptr_t)va-_va);
	len=ROUNDUP(len,PGSIZE);
f0103e83:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0103e8a:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0103e8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103e92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103e95:	be 00 00 00 00       	mov    $0x0,%esi
	for(i=0;i<len;i+=PGSIZE) {
f0103e9a:	e9 87 00 00 00       	jmp    f0103f26 <region_alloc+0xb8>
		struct PageInfo* page=page_alloc(0);
f0103e9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103ea6:	e8 8b d3 ff ff       	call   f0101236 <page_alloc>
f0103eab:	89 c3                	mov    %eax,%ebx
		if(page==NULL) panic("region_alloc: Out of Memory\n");
f0103ead:	85 c0                	test   %eax,%eax
f0103eaf:	75 1c                	jne    f0103ecd <region_alloc+0x5f>
f0103eb1:	c7 44 24 08 73 7f 10 	movl   $0xf0107f73,0x8(%esp)
f0103eb8:	f0 
f0103eb9:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
f0103ec0:	00 
f0103ec1:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103ec8:	e8 b8 c1 ff ff       	call   f0100085 <_panic>
		
		//res=page_insert(e->env_pgdir, page,i,PTE_U | PTE_W);
		
		page->pp_ref++;
f0103ecd:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		pte=pgdir_walk(e->env_pgdir, (const void*)(_va+i), true);
f0103ed2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103ed9:	00 
f0103eda:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103edd:	8d 04 16             	lea    (%esi,%edx,1),%eax
f0103ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ee4:	8b 47 60             	mov    0x60(%edi),%eax
f0103ee7:	89 04 24             	mov    %eax,(%esp)
f0103eea:	e8 cb d3 ff ff       	call   f01012ba <pgdir_walk>
		if (pte==NULL) panic("region_alloc: pte not found\n");
f0103eef:	85 c0                	test   %eax,%eax
f0103ef1:	75 1c                	jne    f0103f0f <region_alloc+0xa1>
f0103ef3:	c7 44 24 08 90 7f 10 	movl   $0xf0107f90,0x8(%esp)
f0103efa:	f0 
f0103efb:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f0103f02:	00 
f0103f03:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103f0a:	e8 76 c1 ff ff       	call   f0100085 <_panic>
		
		*pte = page2pa(page) | PTE_P | PTE_U | PTE_W;
f0103f0f:	2b 1d 90 2e 23 f0    	sub    0xf0232e90,%ebx
f0103f15:	c1 fb 03             	sar    $0x3,%ebx
f0103f18:	c1 e3 0c             	shl    $0xc,%ebx
f0103f1b:	83 cb 07             	or     $0x7,%ebx
f0103f1e:	89 18                	mov    %ebx,(%eax)
	uint32_t i;
	uintptr_t _va=ROUNDDOWN((uintptr_t)va,PGSIZE);
	pte_t* pte;
	len+=((uintptr_t)va-_va);
	len=ROUNDUP(len,PGSIZE);
	for(i=0;i<len;i+=PGSIZE) {
f0103f20:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103f26:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0103f29:	0f 82 70 ff ff ff    	jb     f0103e9f <region_alloc+0x31>
		
		*pte = page2pa(page) | PTE_P | PTE_U | PTE_W;
		//if(res) panic("region_alloc: Page insert fail");
	}
	ENVDEBUG("region_alloc ends\n");
}
f0103f2f:	83 c4 2c             	add    $0x2c,%esp
f0103f32:	5b                   	pop    %ebx
f0103f33:	5e                   	pop    %esi
f0103f34:	5f                   	pop    %edi
f0103f35:	5d                   	pop    %ebp
f0103f36:	c3                   	ret    

f0103f37 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103f37:	55                   	push   %ebp
f0103f38:	89 e5                	mov    %esp,%ebp
f0103f3a:	57                   	push   %edi
f0103f3b:	56                   	push   %esi
f0103f3c:	53                   	push   %ebx
f0103f3d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	ENVDEBUG("start to env_create\n");
	int res=0;
	struct Env *newenv=NULL;
f0103f40:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	res=env_alloc(&newenv,0);
f0103f47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103f4e:	00 
f0103f4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103f52:	89 04 24             	mov    %eax,(%esp)
f0103f55:	e8 44 fd ff ff       	call   f0103c9e <env_alloc>
	
	if(res<0) {
f0103f5a:	85 c0                	test   %eax,%eax
f0103f5c:	79 20                	jns    f0103f7e <env_create+0x47>
		panic("env_create:%e\n",res);
f0103f5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f62:	c7 44 24 08 ad 7f 10 	movl   $0xf0107fad,0x8(%esp)
f0103f69:	f0 
f0103f6a:	c7 44 24 04 b5 01 00 	movl   $0x1b5,0x4(%esp)
f0103f71:	00 
f0103f72:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103f79:	e8 07 c1 ff ff       	call   f0100085 <_panic>
	}
	
	load_icode(newenv,binary);
f0103f7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	ENVDEBUG("start to load_icode\n");
	ENVDEBUG("e->env_pgdir: 0x%08x, and PADDR(e->env_pgdir) : 0x%08x\n",e->env_pgdir,PADDR(e->env_pgdir));	
	lcr3(PADDR(e->env_pgdir));
f0103f81:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f84:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103f89:	77 20                	ja     f0103fab <env_create+0x74>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103f8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f8f:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0103f96:	f0 
f0103f97:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
f0103f9e:	00 
f0103f9f:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103fa6:	e8 da c0 ff ff       	call   f0100085 <_panic>
f0103fab:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103fb1:	0f 22 d8             	mov    %eax,%cr3
	struct Elf * elfhdr=(struct Elf *)binary;
f0103fb4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fb7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Proghdr *ph, *eph;
	if (elfhdr->e_magic!=ELF_MAGIC) {
f0103fba:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f0103fc0:	74 1c                	je     f0103fde <env_create+0xa7>
		panic("load_icode: illegal elf file\n");	
f0103fc2:	c7 44 24 08 bc 7f 10 	movl   $0xf0107fbc,0x8(%esp)
f0103fc9:	f0 
f0103fca:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
f0103fd1:	00 
f0103fd2:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0103fd9:	e8 a7 c0 ff ff       	call   f0100085 <_panic>
	}	
	ph=(struct Proghdr*)((uint8_t*)elfhdr+elfhdr->e_phoff);
f0103fde:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103fe1:	03 5b 1c             	add    0x1c(%ebx),%ebx
	eph= ph+elfhdr->e_phnum;
f0103fe4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103fe7:	0f b7 72 2c          	movzwl 0x2c(%edx),%esi
f0103feb:	c1 e6 05             	shl    $0x5,%esi
f0103fee:	8d 34 33             	lea    (%ebx,%esi,1),%esi
f0103ff1:	eb 71                	jmp    f0104064 <env_create+0x12d>
	ENVDEBUG("before lcr3 e->env_pgdir\n");
	ENVDEBUG("e->env_pgdir: 0x%08x, and PADDR(e->env_pgdir) : 0x%08x\n",e->env_pgdir,PADDR(e->env_pgdir));	
	ENVDEBUG("load_icode for loop\n");
	for(;ph<eph;ph++) {
		if(ph->p_type!=ELF_PROG_LOAD) continue;
f0103ff3:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103ff6:	75 69                	jne    f0104061 <env_create+0x12a>
		
		if(ph->p_filesz > ph->p_memsz) panic("load_icode: file>mem\n");
f0103ff8:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103ffb:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0103ffe:	76 1c                	jbe    f010401c <env_create+0xe5>
f0104000:	c7 44 24 08 da 7f 10 	movl   $0xf0107fda,0x8(%esp)
f0104007:	f0 
f0104008:	c7 44 24 04 90 01 00 	movl   $0x190,0x4(%esp)
f010400f:	00 
f0104010:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f0104017:	e8 69 c0 ff ff       	call   f0100085 <_panic>
		ENVDEBUG("load_prog %d\n",ph->p_filesz);
		region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f010401c:	8b 53 08             	mov    0x8(%ebx),%edx
f010401f:	89 f8                	mov    %edi,%eax
f0104021:	e8 48 fe ff ff       	call   f0103e6e <region_alloc>
	
		memmove((void*)ph->p_va,binary+ph->p_offset,ph->p_filesz);
f0104026:	8b 43 10             	mov    0x10(%ebx),%eax
f0104029:	89 44 24 08          	mov    %eax,0x8(%esp)
f010402d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104030:	03 43 04             	add    0x4(%ebx),%eax
f0104033:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104037:	8b 43 08             	mov    0x8(%ebx),%eax
f010403a:	89 04 24             	mov    %eax,(%esp)
f010403d:	e8 4e 1f 00 00       	call   f0105f90 <memmove>
		memset((void*)ph->p_va+ph->p_filesz,0,(ph->p_memsz-ph->p_filesz));
f0104042:	8b 43 10             	mov    0x10(%ebx),%eax
f0104045:	8b 53 14             	mov    0x14(%ebx),%edx
f0104048:	29 c2                	sub    %eax,%edx
f010404a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010404e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104055:	00 
f0104056:	03 43 08             	add    0x8(%ebx),%eax
f0104059:	89 04 24             	mov    %eax,(%esp)
f010405c:	e8 d0 1e 00 00       	call   f0105f31 <memset>
	ph=(struct Proghdr*)((uint8_t*)elfhdr+elfhdr->e_phoff);
	eph= ph+elfhdr->e_phnum;
	ENVDEBUG("before lcr3 e->env_pgdir\n");
	ENVDEBUG("e->env_pgdir: 0x%08x, and PADDR(e->env_pgdir) : 0x%08x\n",e->env_pgdir,PADDR(e->env_pgdir));	
	ENVDEBUG("load_icode for loop\n");
	for(;ph<eph;ph++) {
f0104061:	83 c3 20             	add    $0x20,%ebx
f0104064:	39 de                	cmp    %ebx,%esi
f0104066:	77 8b                	ja     f0103ff3 <env_create+0xbc>
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	
	lcr3(PADDR(kern_pgdir));
f0104068:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010406d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104072:	77 20                	ja     f0104094 <env_create+0x15d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104074:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104078:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f010407f:	f0 
f0104080:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0104087:	00 
f0104088:	c7 04 24 3d 7f 10 f0 	movl   $0xf0107f3d,(%esp)
f010408f:	e8 f1 bf ff ff       	call   f0100085 <_panic>
f0104094:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010409a:	0f 22 d8             	mov    %eax,%cr3
	region_alloc(e,(void*)USTACKTOP-PGSIZE,PGSIZE);
f010409d:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01040a2:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01040a7:	89 f8                	mov    %edi,%eax
f01040a9:	e8 c0 fd ff ff       	call   f0103e6e <region_alloc>
	e->env_tf.tf_eip=elfhdr->e_entry;
f01040ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01040b1:	8b 42 18             	mov    0x18(%edx),%eax
f01040b4:	89 47 30             	mov    %eax,0x30(%edi)
	if(res<0) {
		panic("env_create:%e\n",res);
	}
	
	load_icode(newenv,binary);
	newenv->env_type= type;
f01040b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01040ba:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040bd:	89 50 50             	mov    %edx,0x50(%eax)
	ENVDEBUG("end with env_create\n");
}
f01040c0:	83 c4 3c             	add    $0x3c,%esp
f01040c3:	5b                   	pop    %ebx
f01040c4:	5e                   	pop    %esi
f01040c5:	5f                   	pop    %edi
f01040c6:	5d                   	pop    %ebp
f01040c7:	c3                   	ret    

f01040c8 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01040c8:	55                   	push   %ebp
f01040c9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01040cb:	ba 70 00 00 00       	mov    $0x70,%edx
f01040d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01040d3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01040d4:	b2 71                	mov    $0x71,%dl
f01040d6:	ec                   	in     (%dx),%al
f01040d7:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01040da:	5d                   	pop    %ebp
f01040db:	c3                   	ret    

f01040dc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01040dc:	55                   	push   %ebp
f01040dd:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01040df:	ba 70 00 00 00       	mov    $0x70,%edx
f01040e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01040e7:	ee                   	out    %al,(%dx)
f01040e8:	b2 71                	mov    $0x71,%dl
f01040ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01040ed:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01040ee:	5d                   	pop    %ebp
f01040ef:	c3                   	ret    

f01040f0 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01040f0:	55                   	push   %ebp
f01040f1:	89 e5                	mov    %esp,%ebp
f01040f3:	56                   	push   %esi
f01040f4:	53                   	push   %ebx
f01040f5:	83 ec 10             	sub    $0x10,%esp
f01040f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01040fb:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01040fd:	66 a3 90 13 12 f0    	mov    %ax,0xf0121390
	if (!didinit)
f0104103:	80 3d 40 22 23 f0 00 	cmpb   $0x0,0xf0232240
f010410a:	74 4e                	je     f010415a <irq_setmask_8259A+0x6a>
f010410c:	ba 21 00 00 00       	mov    $0x21,%edx
f0104111:	ee                   	out    %al,(%dx)
f0104112:	89 f0                	mov    %esi,%eax
f0104114:	66 c1 e8 08          	shr    $0x8,%ax
f0104118:	b2 a1                	mov    $0xa1,%dl
f010411a:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010411b:	c7 04 24 f0 7f 10 f0 	movl   $0xf0107ff0,(%esp)
f0104122:	e8 f8 00 00 00       	call   f010421f <cprintf>
f0104127:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f010412c:	0f b7 f6             	movzwl %si,%esi
f010412f:	f7 d6                	not    %esi
f0104131:	0f a3 de             	bt     %ebx,%esi
f0104134:	73 10                	jae    f0104146 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0104136:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010413a:	c7 04 24 d0 84 10 f0 	movl   $0xf01084d0,(%esp)
f0104141:	e8 d9 00 00 00       	call   f010421f <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104146:	83 c3 01             	add    $0x1,%ebx
f0104149:	83 fb 10             	cmp    $0x10,%ebx
f010414c:	75 e3                	jne    f0104131 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f010414e:	c7 04 24 ff 7e 10 f0 	movl   $0xf0107eff,(%esp)
f0104155:	e8 c5 00 00 00       	call   f010421f <cprintf>
}
f010415a:	83 c4 10             	add    $0x10,%esp
f010415d:	5b                   	pop    %ebx
f010415e:	5e                   	pop    %esi
f010415f:	5d                   	pop    %ebp
f0104160:	c3                   	ret    

f0104161 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104161:	55                   	push   %ebp
f0104162:	89 e5                	mov    %esp,%ebp
f0104164:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0104167:	c6 05 40 22 23 f0 01 	movb   $0x1,0xf0232240
f010416e:	ba 21 00 00 00       	mov    $0x21,%edx
f0104173:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104178:	ee                   	out    %al,(%dx)
f0104179:	b2 a1                	mov    $0xa1,%dl
f010417b:	ee                   	out    %al,(%dx)
f010417c:	b2 20                	mov    $0x20,%dl
f010417e:	b8 11 00 00 00       	mov    $0x11,%eax
f0104183:	ee                   	out    %al,(%dx)
f0104184:	b2 21                	mov    $0x21,%dl
f0104186:	b8 20 00 00 00       	mov    $0x20,%eax
f010418b:	ee                   	out    %al,(%dx)
f010418c:	b8 04 00 00 00       	mov    $0x4,%eax
f0104191:	ee                   	out    %al,(%dx)
f0104192:	b8 03 00 00 00       	mov    $0x3,%eax
f0104197:	ee                   	out    %al,(%dx)
f0104198:	b2 a0                	mov    $0xa0,%dl
f010419a:	b8 11 00 00 00       	mov    $0x11,%eax
f010419f:	ee                   	out    %al,(%dx)
f01041a0:	b2 a1                	mov    $0xa1,%dl
f01041a2:	b8 28 00 00 00       	mov    $0x28,%eax
f01041a7:	ee                   	out    %al,(%dx)
f01041a8:	b8 02 00 00 00       	mov    $0x2,%eax
f01041ad:	ee                   	out    %al,(%dx)
f01041ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01041b3:	ee                   	out    %al,(%dx)
f01041b4:	b2 20                	mov    $0x20,%dl
f01041b6:	b8 68 00 00 00       	mov    $0x68,%eax
f01041bb:	ee                   	out    %al,(%dx)
f01041bc:	b8 0a 00 00 00       	mov    $0xa,%eax
f01041c1:	ee                   	out    %al,(%dx)
f01041c2:	b2 a0                	mov    $0xa0,%dl
f01041c4:	b8 68 00 00 00       	mov    $0x68,%eax
f01041c9:	ee                   	out    %al,(%dx)
f01041ca:	b8 0a 00 00 00       	mov    $0xa,%eax
f01041cf:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01041d0:	0f b7 05 90 13 12 f0 	movzwl 0xf0121390,%eax
f01041d7:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01041db:	74 0b                	je     f01041e8 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f01041dd:	0f b7 c0             	movzwl %ax,%eax
f01041e0:	89 04 24             	mov    %eax,(%esp)
f01041e3:	e8 08 ff ff ff       	call   f01040f0 <irq_setmask_8259A>
}
f01041e8:	c9                   	leave  
f01041e9:	c3                   	ret    
	...

f01041ec <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01041ec:	55                   	push   %ebp
f01041ed:	89 e5                	mov    %esp,%ebp
f01041ef:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01041f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01041f9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104200:	8b 45 08             	mov    0x8(%ebp),%eax
f0104203:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104207:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010420a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010420e:	c7 04 24 39 42 10 f0 	movl   $0xf0104239,(%esp)
f0104215:	e8 25 16 00 00       	call   f010583f <vprintfmt>
	return cnt;
}
f010421a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010421d:	c9                   	leave  
f010421e:	c3                   	ret    

f010421f <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010421f:	55                   	push   %ebp
f0104220:	89 e5                	mov    %esp,%ebp
f0104222:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0104225:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0104228:	89 44 24 04          	mov    %eax,0x4(%esp)
f010422c:	8b 45 08             	mov    0x8(%ebp),%eax
f010422f:	89 04 24             	mov    %eax,(%esp)
f0104232:	e8 b5 ff ff ff       	call   f01041ec <vcprintf>
	va_end(ap);

	return cnt;
}
f0104237:	c9                   	leave  
f0104238:	c3                   	ret    

f0104239 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104239:	55                   	push   %ebp
f010423a:	89 e5                	mov    %esp,%ebp
f010423c:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010423f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104242:	89 04 24             	mov    %eax,(%esp)
f0104245:	e8 68 c3 ff ff       	call   f01005b2 <cputchar>
	*cnt++;
}
f010424a:	c9                   	leave  
f010424b:	c3                   	ret    
f010424c:	00 00                	add    %al,(%eax)
	...

f0104250 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104250:	55                   	push   %ebp
f0104251:	89 e5                	mov    %esp,%ebp
f0104253:	83 ec 18             	sub    $0x18,%esp
f0104256:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104259:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010425c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	uint8_t cpu_id = thiscpu->cpu_id;
f010425f:	e8 4a 23 00 00       	call   f01065ae <cpunum>
f0104264:	6b c0 74             	imul   $0x74,%eax,%eax
f0104267:	0f b6 b8 20 30 23 f0 	movzbl -0xfdccfe0(%eax),%edi
	struct Taskstate* cpu_ts = &(thiscpu->cpu_ts);
f010426e:	e8 3b 23 00 00       	call   f01065ae <cpunum>
f0104273:	6b c0 74             	imul   $0x74,%eax,%eax
f0104276:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010427b:	8d 48 0c             	lea    0xc(%eax),%ecx
	

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	cpu_ts->ts_esp0 = KSTACKTOP - (KSTKSIZE+KSTKGAP)*cpu_id;
f010427e:	89 fb                	mov    %edi,%ebx
f0104280:	0f b6 d3             	movzbl %bl,%edx
f0104283:	89 d6                	mov    %edx,%esi
f0104285:	c1 e6 10             	shl    $0x10,%esi
f0104288:	f7 de                	neg    %esi
f010428a:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0104290:	89 70 10             	mov    %esi,0x10(%eax)
	cpu_ts->ts_ss0 = GD_KD;
f0104293:	66 c7 40 14 10 00    	movw   $0x10,0x14(%eax)

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpu_id ] = SEG16(STS_T32A, (uint32_t) (cpu_ts),
f0104299:	83 c2 05             	add    $0x5,%edx
f010429c:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01042a1:	66 c7 04 d0 67 00    	movw   $0x67,(%eax,%edx,8)
f01042a7:	66 89 4c d0 02       	mov    %cx,0x2(%eax,%edx,8)
f01042ac:	89 ce                	mov    %ecx,%esi
f01042ae:	c1 ee 10             	shr    $0x10,%esi
f01042b1:	89 f3                	mov    %esi,%ebx
f01042b3:	88 5c d0 04          	mov    %bl,0x4(%eax,%edx,8)
f01042b7:	c6 44 d0 06 40       	movb   $0x40,0x6(%eax,%edx,8)
f01042bc:	c1 e9 18             	shr    $0x18,%ecx
f01042bf:	88 4c d0 07          	mov    %cl,0x7(%eax,%edx,8)
					sizeof(struct Taskstate)-1, 0);
	gdt[(GD_TSS0 >> 3) + cpu_id ].sd_s = 0;
f01042c3:	c6 44 d0 05 89       	movb   $0x89,0x5(%eax,%edx,8)
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01042c8:	89 f8                	mov    %edi,%eax
f01042ca:	0f b6 d8             	movzbl %al,%ebx
f01042cd:	8d 1c dd 28 00 00 00 	lea    0x28(,%ebx,8),%ebx
f01042d4:	0f 00 db             	ltr    %bx
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01042d7:	b8 94 13 12 f0       	mov    $0xf0121394,%eax
f01042dc:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);

	
}
f01042df:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01042e2:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01042e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01042e8:	89 ec                	mov    %ebp,%esp
f01042ea:	5d                   	pop    %ebp
f01042eb:	c3                   	ret    

f01042ec <trap_init>:
extern int trap_handlers[];


void
trap_init(void)
{
f01042ec:	55                   	push   %ebp
f01042ed:	89 e5                	mov    %esp,%ebp
f01042ef:	56                   	push   %esi
f01042f0:	53                   	push   %ebx
f01042f1:	b8 00 00 00 00       	mov    $0x0,%eax

	// LAB 3: Your code here.
	int i;
	for(i=0;i<20;i++) {
		if (i==3) {
			SETGATE(idt[i], false, GD_KT, trap_handlers[i], 3);
f01042f6:	be a8 13 12 f0       	mov    $0xf01213a8,%esi
f01042fb:	bb 78 22 23 f0       	mov    $0xf0232278,%ebx
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	int i;
	for(i=0;i<20;i++) {
		if (i==3) {
f0104300:	83 f8 03             	cmp    $0x3,%eax
f0104303:	75 2b                	jne    f0104330 <trap_init+0x44>
			SETGATE(idt[i], false, GD_KT, trap_handlers[i], 3);
f0104305:	8b 16                	mov    (%esi),%edx
f0104307:	66 89 13             	mov    %dx,(%ebx)
f010430a:	66 c7 05 7a 22 23 f0 	movw   $0x8,0xf023227a
f0104311:	08 00 
f0104313:	c6 05 7c 22 23 f0 00 	movb   $0x0,0xf023227c
f010431a:	c6 05 7d 22 23 f0 ee 	movb   $0xee,0xf023227d
f0104321:	c1 ea 10             	shr    $0x10,%edx
f0104324:	66 89 15 7e 22 23 f0 	mov    %dx,0xf023227e
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	int i;
	for(i=0;i<20;i++) {
f010432b:	83 c0 01             	add    $0x1,%eax
f010432e:	eb d0                	jmp    f0104300 <trap_init+0x14>
		if (i==3) {
			SETGATE(idt[i], false, GD_KT, trap_handlers[i], 3);
		}
		else {
			SETGATE(idt[i], false, GD_KT,  trap_handlers[i], 0);
f0104330:	8b 0c 85 9c 13 12 f0 	mov    -0xfedec64(,%eax,4),%ecx
f0104337:	ba 60 22 23 f0       	mov    $0xf0232260,%edx
f010433c:	66 89 0c c2          	mov    %cx,(%edx,%eax,8)
f0104340:	66 c7 44 c2 02 08 00 	movw   $0x8,0x2(%edx,%eax,8)
f0104347:	c6 44 c2 04 00       	movb   $0x0,0x4(%edx,%eax,8)
f010434c:	c6 44 c2 05 8e       	movb   $0x8e,0x5(%edx,%eax,8)
f0104351:	c1 e9 10             	shr    $0x10,%ecx
f0104354:	66 89 4c c2 06       	mov    %cx,0x6(%edx,%eax,8)
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	int i;
	for(i=0;i<20;i++) {
f0104359:	83 c0 01             	add    $0x1,%eax
f010435c:	83 f8 14             	cmp    $0x14,%eax
f010435f:	75 9f                	jne    f0104300 <trap_init+0x14>
		else {
			SETGATE(idt[i], false, GD_KT,  trap_handlers[i], 0);
		}
	}
	
	SETGATE(idt[48], false, GD_KT, trap_handlers[20], 3);
f0104361:	a1 ec 13 12 f0       	mov    0xf01213ec,%eax
f0104366:	66 a3 e0 23 23 f0    	mov    %ax,0xf02323e0
f010436c:	66 c7 05 e2 23 23 f0 	movw   $0x8,0xf02323e2
f0104373:	08 00 
f0104375:	c6 05 e4 23 23 f0 00 	movb   $0x0,0xf02323e4
f010437c:	c6 05 e5 23 23 f0 ee 	movb   $0xee,0xf02323e5
f0104383:	c1 e8 10             	shr    $0x10,%eax
f0104386:	66 a3 e6 23 23 f0    	mov    %ax,0xf02323e6

	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, trap_handlers[21], 0);
f010438c:	a1 f0 13 12 f0       	mov    0xf01213f0,%eax
f0104391:	66 a3 60 23 23 f0    	mov    %ax,0xf0232360
f0104397:	66 c7 05 62 23 23 f0 	movw   $0x8,0xf0232362
f010439e:	08 00 
f01043a0:	c6 05 64 23 23 f0 00 	movb   $0x0,0xf0232364
f01043a7:	c6 05 65 23 23 f0 8e 	movb   $0x8e,0xf0232365
f01043ae:	c1 e8 10             	shr    $0x10,%eax
f01043b1:	66 a3 66 23 23 f0    	mov    %ax,0xf0232366
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, trap_handlers[22], 0);
f01043b7:	a1 f4 13 12 f0       	mov    0xf01213f4,%eax
f01043bc:	66 a3 68 23 23 f0    	mov    %ax,0xf0232368
f01043c2:	66 c7 05 6a 23 23 f0 	movw   $0x8,0xf023236a
f01043c9:	08 00 
f01043cb:	c6 05 6c 23 23 f0 00 	movb   $0x0,0xf023236c
f01043d2:	c6 05 6d 23 23 f0 8e 	movb   $0x8e,0xf023236d
f01043d9:	c1 e8 10             	shr    $0x10,%eax
f01043dc:	66 a3 6e 23 23 f0    	mov    %ax,0xf023236e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, trap_handlers[23], 0);
f01043e2:	a1 f8 13 12 f0       	mov    0xf01213f8,%eax
f01043e7:	66 a3 80 23 23 f0    	mov    %ax,0xf0232380
f01043ed:	66 c7 05 82 23 23 f0 	movw   $0x8,0xf0232382
f01043f4:	08 00 
f01043f6:	c6 05 84 23 23 f0 00 	movb   $0x0,0xf0232384
f01043fd:	c6 05 85 23 23 f0 8e 	movb   $0x8e,0xf0232385
f0104404:	c1 e8 10             	shr    $0x10,%eax
f0104407:	66 a3 86 23 23 f0    	mov    %ax,0xf0232386
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, trap_handlers[24], 0);
f010440d:	a1 fc 13 12 f0       	mov    0xf01213fc,%eax
f0104412:	66 a3 d0 23 23 f0    	mov    %ax,0xf02323d0
f0104418:	66 c7 05 d2 23 23 f0 	movw   $0x8,0xf02323d2
f010441f:	08 00 
f0104421:	c6 05 d4 23 23 f0 00 	movb   $0x0,0xf02323d4
f0104428:	c6 05 d5 23 23 f0 8e 	movb   $0x8e,0xf02323d5
f010442f:	c1 e8 10             	shr    $0x10,%eax
f0104432:	66 a3 d6 23 23 f0    	mov    %ax,0xf02323d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, trap_handlers[25], 0);
f0104438:	a1 00 14 12 f0       	mov    0xf0121400,%eax
f010443d:	66 a3 f8 23 23 f0    	mov    %ax,0xf02323f8
f0104443:	66 c7 05 fa 23 23 f0 	movw   $0x8,0xf02323fa
f010444a:	08 00 
f010444c:	c6 05 fc 23 23 f0 00 	movb   $0x0,0xf02323fc
f0104453:	c6 05 fd 23 23 f0 8e 	movb   $0x8e,0xf02323fd
f010445a:	c1 e8 10             	shr    $0x10,%eax
f010445d:	66 a3 fe 23 23 f0    	mov    %ax,0xf02323fe

	// Per-CPU setup 
	trap_init_percpu();
f0104463:	e8 e8 fd ff ff       	call   f0104250 <trap_init_percpu>
}
f0104468:	5b                   	pop    %ebx
f0104469:	5e                   	pop    %esi
f010446a:	5d                   	pop    %ebp
f010446b:	c3                   	ret    

f010446c <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010446c:	55                   	push   %ebp
f010446d:	89 e5                	mov    %esp,%ebp
f010446f:	53                   	push   %ebx
f0104470:	83 ec 14             	sub    $0x14,%esp
f0104473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104476:	8b 03                	mov    (%ebx),%eax
f0104478:	89 44 24 04          	mov    %eax,0x4(%esp)
f010447c:	c7 04 24 04 80 10 f0 	movl   $0xf0108004,(%esp)
f0104483:	e8 97 fd ff ff       	call   f010421f <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104488:	8b 43 04             	mov    0x4(%ebx),%eax
f010448b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010448f:	c7 04 24 13 80 10 f0 	movl   $0xf0108013,(%esp)
f0104496:	e8 84 fd ff ff       	call   f010421f <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010449b:	8b 43 08             	mov    0x8(%ebx),%eax
f010449e:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044a2:	c7 04 24 22 80 10 f0 	movl   $0xf0108022,(%esp)
f01044a9:	e8 71 fd ff ff       	call   f010421f <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01044ae:	8b 43 0c             	mov    0xc(%ebx),%eax
f01044b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044b5:	c7 04 24 31 80 10 f0 	movl   $0xf0108031,(%esp)
f01044bc:	e8 5e fd ff ff       	call   f010421f <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01044c1:	8b 43 10             	mov    0x10(%ebx),%eax
f01044c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044c8:	c7 04 24 40 80 10 f0 	movl   $0xf0108040,(%esp)
f01044cf:	e8 4b fd ff ff       	call   f010421f <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01044d4:	8b 43 14             	mov    0x14(%ebx),%eax
f01044d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044db:	c7 04 24 4f 80 10 f0 	movl   $0xf010804f,(%esp)
f01044e2:	e8 38 fd ff ff       	call   f010421f <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01044e7:	8b 43 18             	mov    0x18(%ebx),%eax
f01044ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ee:	c7 04 24 5e 80 10 f0 	movl   $0xf010805e,(%esp)
f01044f5:	e8 25 fd ff ff       	call   f010421f <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01044fa:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01044fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104501:	c7 04 24 6d 80 10 f0 	movl   $0xf010806d,(%esp)
f0104508:	e8 12 fd ff ff       	call   f010421f <cprintf>
}
f010450d:	83 c4 14             	add    $0x14,%esp
f0104510:	5b                   	pop    %ebx
f0104511:	5d                   	pop    %ebp
f0104512:	c3                   	ret    

f0104513 <print_trapframe>:
	
}

void
print_trapframe(struct Trapframe *tf)
{
f0104513:	55                   	push   %ebp
f0104514:	89 e5                	mov    %esp,%ebp
f0104516:	56                   	push   %esi
f0104517:	53                   	push   %ebx
f0104518:	83 ec 10             	sub    $0x10,%esp
f010451b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010451e:	e8 8b 20 00 00       	call   f01065ae <cpunum>
f0104523:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104527:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010452b:	c7 04 24 7c 80 10 f0 	movl   $0xf010807c,(%esp)
f0104532:	e8 e8 fc ff ff       	call   f010421f <cprintf>
	print_regs(&tf->tf_regs);
f0104537:	89 1c 24             	mov    %ebx,(%esp)
f010453a:	e8 2d ff ff ff       	call   f010446c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010453f:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104543:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104547:	c7 04 24 9a 80 10 f0 	movl   $0xf010809a,(%esp)
f010454e:	e8 cc fc ff ff       	call   f010421f <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104553:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104557:	89 44 24 04          	mov    %eax,0x4(%esp)
f010455b:	c7 04 24 ad 80 10 f0 	movl   $0xf01080ad,(%esp)
f0104562:	e8 b8 fc ff ff       	call   f010421f <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104567:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f010456a:	83 f8 13             	cmp    $0x13,%eax
f010456d:	77 09                	ja     f0104578 <print_trapframe+0x65>
		return excnames[trapno];
f010456f:	8b 14 85 c0 83 10 f0 	mov    -0xfef7c40(,%eax,4),%edx
f0104576:	eb 1c                	jmp    f0104594 <print_trapframe+0x81>
	if (trapno == T_SYSCALL)
f0104578:	ba c0 80 10 f0       	mov    $0xf01080c0,%edx
f010457d:	83 f8 30             	cmp    $0x30,%eax
f0104580:	74 12                	je     f0104594 <print_trapframe+0x81>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104582:	8d 48 e0             	lea    -0x20(%eax),%ecx
f0104585:	ba db 80 10 f0       	mov    $0xf01080db,%edx
f010458a:	83 f9 0f             	cmp    $0xf,%ecx
f010458d:	76 05                	jbe    f0104594 <print_trapframe+0x81>
f010458f:	ba cc 80 10 f0       	mov    $0xf01080cc,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104594:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104598:	89 44 24 04          	mov    %eax,0x4(%esp)
f010459c:	c7 04 24 ee 80 10 f0 	movl   $0xf01080ee,(%esp)
f01045a3:	e8 77 fc ff ff       	call   f010421f <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01045a8:	3b 1d 60 2a 23 f0    	cmp    0xf0232a60,%ebx
f01045ae:	75 19                	jne    f01045c9 <print_trapframe+0xb6>
f01045b0:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01045b4:	75 13                	jne    f01045c9 <print_trapframe+0xb6>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01045b6:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01045b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045bd:	c7 04 24 00 81 10 f0 	movl   $0xf0108100,(%esp)
f01045c4:	e8 56 fc ff ff       	call   f010421f <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01045c9:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01045cc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d0:	c7 04 24 0f 81 10 f0 	movl   $0xf010810f,(%esp)
f01045d7:	e8 43 fc ff ff       	call   f010421f <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01045dc:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01045e0:	75 47                	jne    f0104629 <print_trapframe+0x116>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01045e2:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01045e5:	be 29 81 10 f0       	mov    $0xf0108129,%esi
f01045ea:	a8 01                	test   $0x1,%al
f01045ec:	75 05                	jne    f01045f3 <print_trapframe+0xe0>
f01045ee:	be 1d 81 10 f0       	mov    $0xf010811d,%esi
f01045f3:	b9 39 81 10 f0       	mov    $0xf0108139,%ecx
f01045f8:	a8 02                	test   $0x2,%al
f01045fa:	75 05                	jne    f0104601 <print_trapframe+0xee>
f01045fc:	b9 34 81 10 f0       	mov    $0xf0108134,%ecx
f0104601:	ba 3f 81 10 f0       	mov    $0xf010813f,%edx
f0104606:	a8 04                	test   $0x4,%al
f0104608:	75 05                	jne    f010460f <print_trapframe+0xfc>
f010460a:	ba 1d 82 10 f0       	mov    $0xf010821d,%edx
f010460f:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104613:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104617:	89 54 24 04          	mov    %edx,0x4(%esp)
f010461b:	c7 04 24 44 81 10 f0 	movl   $0xf0108144,(%esp)
f0104622:	e8 f8 fb ff ff       	call   f010421f <cprintf>
f0104627:	eb 0c                	jmp    f0104635 <print_trapframe+0x122>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104629:	c7 04 24 ff 7e 10 f0 	movl   $0xf0107eff,(%esp)
f0104630:	e8 ea fb ff ff       	call   f010421f <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104635:	8b 43 30             	mov    0x30(%ebx),%eax
f0104638:	89 44 24 04          	mov    %eax,0x4(%esp)
f010463c:	c7 04 24 53 81 10 f0 	movl   $0xf0108153,(%esp)
f0104643:	e8 d7 fb ff ff       	call   f010421f <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104648:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f010464c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104650:	c7 04 24 62 81 10 f0 	movl   $0xf0108162,(%esp)
f0104657:	e8 c3 fb ff ff       	call   f010421f <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010465c:	8b 43 38             	mov    0x38(%ebx),%eax
f010465f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104663:	c7 04 24 75 81 10 f0 	movl   $0xf0108175,(%esp)
f010466a:	e8 b0 fb ff ff       	call   f010421f <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010466f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104673:	74 27                	je     f010469c <print_trapframe+0x189>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104675:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104678:	89 44 24 04          	mov    %eax,0x4(%esp)
f010467c:	c7 04 24 84 81 10 f0 	movl   $0xf0108184,(%esp)
f0104683:	e8 97 fb ff ff       	call   f010421f <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104688:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010468c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104690:	c7 04 24 93 81 10 f0 	movl   $0xf0108193,(%esp)
f0104697:	e8 83 fb ff ff       	call   f010421f <cprintf>
	}
}
f010469c:	83 c4 10             	add    $0x10,%esp
f010469f:	5b                   	pop    %ebx
f01046a0:	5e                   	pop    %esi
f01046a1:	5d                   	pop    %ebp
f01046a2:	c3                   	ret    

f01046a3 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01046a3:	55                   	push   %ebp
f01046a4:	89 e5                	mov    %esp,%ebp
f01046a6:	83 ec 38             	sub    $0x38,%esp
f01046a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01046ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01046af:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01046b2:	0f 20 d0             	mov    %cr2,%eax
f01046b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ( (tf->tf_cs &  0x3)==0 ) {
f01046b8:	8b 55 08             	mov    0x8(%ebp),%edx
f01046bb:	f6 42 34 03          	testb  $0x3,0x34(%edx)
f01046bf:	75 24                	jne    f01046e5 <page_fault_handler+0x42>
		TRAPDEBUG("kernel level page fault\n");
		print_trapframe(tf);
f01046c1:	89 14 24             	mov    %edx,(%esp)
f01046c4:	e8 4a fe ff ff       	call   f0104513 <print_trapframe>
		panic("page_fault_handler: kernel page fault\n");
f01046c9:	c7 44 24 08 68 83 10 	movl   $0xf0108368,0x8(%esp)
f01046d0:	f0 
f01046d1:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f01046d8:	00 
f01046d9:	c7 04 24 a6 81 10 f0 	movl   $0xf01081a6,(%esp)
f01046e0:	e8 a0 b9 ff ff       	call   f0100085 <_panic>
	TRAPDEBUG("page_fault_handler: curenv's id: %d\n",curenv->env_id);
	TRAPDEBUG("page_fault_handler: fault address: 0x%08x\n", fault_va);

//	user_mem_assert(curenv,(void*)(UXSTACKTOP-4),4,0);

	if (curenv->env_pgfault_upcall != NULL ) {
f01046e5:	e8 c4 1e 00 00       	call   f01065ae <cpunum>
f01046ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ed:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01046f3:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f01046f7:	0f 84 1b 01 00 00    	je     f0104818 <page_fault_handler+0x175>
		
		struct UTrapframe *frame;
		if (tf->tf_esp<UXSTACKTOP && tf->tf_esp>=UXSTACKTOP-PGSIZE) {
f01046fd:	8b 55 08             	mov    0x8(%ebp),%edx
f0104700:	8b 42 3c             	mov    0x3c(%edx),%eax
f0104703:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0104709:	c7 45 e0 cc ff bf ee 	movl   $0xeebfffcc,-0x20(%ebp)
f0104710:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104716:	77 06                	ja     f010471e <page_fault_handler+0x7b>
			frame=(struct UTrapframe*)(tf->tf_esp-4-sizeof(struct UTrapframe));
f0104718:	83 e8 38             	sub    $0x38,%eax
f010471b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		}
		else {
			frame=(struct UTrapframe*)(UXSTACKTOP-sizeof(struct UTrapframe));
		}
		TRAPDEBUG("page_fault_handler: before user_mem_assert\n");	
		user_mem_assert(curenv,(void*)frame,sizeof(struct UTrapframe),PTE_W|PTE_U);
f010471e:	e8 8b 1e 00 00       	call   f01065ae <cpunum>
f0104723:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010472a:	00 
f010472b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104732:	00 
f0104733:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104736:	89 54 24 04          	mov    %edx,0x4(%esp)
f010473a:	6b c0 74             	imul   $0x74,%eax,%eax
f010473d:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104743:	89 04 24             	mov    %eax,(%esp)
f0104746:	e8 0f cd ff ff       	call   f010145a <user_mem_assert>
		

		frame->utf_regs=tf->tf_regs;
f010474b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010474e:	83 c7 08             	add    $0x8,%edi
f0104751:	8b 75 08             	mov    0x8(%ebp),%esi
f0104754:	ba 20 00 00 00       	mov    $0x20,%edx
f0104759:	f7 c7 01 00 00 00    	test   $0x1,%edi
f010475f:	74 04                	je     f0104765 <page_fault_handler+0xc2>
f0104761:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104762:	83 ea 01             	sub    $0x1,%edx
f0104765:	f7 c7 02 00 00 00    	test   $0x2,%edi
f010476b:	74 05                	je     f0104772 <page_fault_handler+0xcf>
f010476d:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f010476f:	83 ea 02             	sub    $0x2,%edx
f0104772:	89 d1                	mov    %edx,%ecx
f0104774:	c1 e9 02             	shr    $0x2,%ecx
f0104777:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104779:	b8 00 00 00 00       	mov    $0x0,%eax
f010477e:	f6 c2 02             	test   $0x2,%dl
f0104781:	74 0b                	je     f010478e <page_fault_handler+0xeb>
f0104783:	0f b7 0c 06          	movzwl (%esi,%eax,1),%ecx
f0104787:	66 89 0c 07          	mov    %cx,(%edi,%eax,1)
f010478b:	83 c0 02             	add    $0x2,%eax
f010478e:	f6 c2 01             	test   $0x1,%dl
f0104791:	74 07                	je     f010479a <page_fault_handler+0xf7>
f0104793:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
f0104797:	88 14 07             	mov    %dl,(%edi,%eax,1)
		frame->utf_eflags=tf->tf_eflags;
f010479a:	8b 55 08             	mov    0x8(%ebp),%edx
f010479d:	8b 42 38             	mov    0x38(%edx),%eax
f01047a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01047a3:	89 42 2c             	mov    %eax,0x2c(%edx)
		frame->utf_eip=tf->tf_eip;
f01047a6:	8b 55 08             	mov    0x8(%ebp),%edx
f01047a9:	8b 42 30             	mov    0x30(%edx),%eax
f01047ac:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01047af:	89 42 28             	mov    %eax,0x28(%edx)
		frame->utf_err=tf->tf_err;
f01047b2:	8b 55 08             	mov    0x8(%ebp),%edx
f01047b5:	8b 42 2c             	mov    0x2c(%edx),%eax
f01047b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01047bb:	89 42 04             	mov    %eax,0x4(%edx)
		frame->utf_esp=tf->tf_esp;
f01047be:	8b 55 08             	mov    0x8(%ebp),%edx
f01047c1:	8b 42 3c             	mov    0x3c(%edx),%eax
f01047c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01047c7:	89 42 30             	mov    %eax,0x30(%edx)
		frame->utf_fault_va=fault_va;
f01047ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047cd:	89 02                	mov    %eax,(%edx)


		curenv->env_tf.tf_eip=(uintptr_t)curenv->env_pgfault_upcall;
f01047cf:	e8 da 1d 00 00       	call   f01065ae <cpunum>
f01047d4:	bb 20 30 23 f0       	mov    $0xf0233020,%ebx
f01047d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01047dc:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
f01047e0:	e8 c9 1d 00 00       	call   f01065ae <cpunum>
f01047e5:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e8:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01047ec:	8b 40 64             	mov    0x64(%eax),%eax
f01047ef:	89 46 30             	mov    %eax,0x30(%esi)
		curenv->env_tf.tf_esp=(uintptr_t)frame;
f01047f2:	e8 b7 1d 00 00       	call   f01065ae <cpunum>
f01047f7:	6b c0 74             	imul   $0x74,%eax,%eax
f01047fa:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01047fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104801:	89 50 3c             	mov    %edx,0x3c(%eax)
		
		TRAPDEBUG("page_fault_handler: before env_run\n");	
		env_run(curenv);
f0104804:	e8 a5 1d 00 00       	call   f01065ae <cpunum>
f0104809:	6b c0 74             	imul   $0x74,%eax,%eax
f010480c:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104810:	89 04 24             	mov    %eax,(%esp)
f0104813:	e8 42 f1 ff ff       	call   f010395a <env_run>
		panic("page_fault_handler: cannot be reached\n");
	}
	
	
	
	cprintf("There is no pgfault upcall\n");	
f0104818:	c7 04 24 b2 81 10 f0 	movl   $0xf01081b2,(%esp)
f010481f:	e8 fb f9 ff ff       	call   f010421f <cprintf>
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104824:	8b 45 08             	mov    0x8(%ebp),%eax
f0104827:	8b 58 30             	mov    0x30(%eax),%ebx
		curenv->env_id, fault_va, tf->tf_eip);
f010482a:	e8 7f 1d 00 00       	call   f01065ae <cpunum>
	
	
	
	cprintf("There is no pgfault upcall\n");	
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010482f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104833:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104836:	89 54 24 08          	mov    %edx,0x8(%esp)
f010483a:	bb 20 30 23 f0       	mov    $0xf0233020,%ebx
f010483f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104842:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104846:	8b 40 48             	mov    0x48(%eax),%eax
f0104849:	89 44 24 04          	mov    %eax,0x4(%esp)
f010484d:	c7 04 24 90 83 10 f0 	movl   $0xf0108390,(%esp)
f0104854:	e8 c6 f9 ff ff       	call   f010421f <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104859:	8b 45 08             	mov    0x8(%ebp),%eax
f010485c:	89 04 24             	mov    %eax,(%esp)
f010485f:	e8 af fc ff ff       	call   f0104513 <print_trapframe>
	env_destroy(curenv);
f0104864:	e8 45 1d 00 00       	call   f01065ae <cpunum>
f0104869:	6b c0 74             	imul   $0x74,%eax,%eax
f010486c:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104870:	89 04 24             	mov    %eax,(%esp)
f0104873:	e8 c8 f3 ff ff       	call   f0103c40 <env_destroy>
}
f0104878:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010487b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010487e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104881:	89 ec                	mov    %ebp,%esp
f0104883:	5d                   	pop    %ebp
f0104884:	c3                   	ret    

f0104885 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104885:	55                   	push   %ebp
f0104886:	89 e5                	mov    %esp,%ebp
f0104888:	57                   	push   %edi
f0104889:	56                   	push   %esi
f010488a:	53                   	push   %ebx
f010488b:	83 ec 2c             	sub    $0x2c,%esp
f010488e:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104891:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104892:	83 3d 80 2e 23 f0 00 	cmpl   $0x0,0xf0232e80
f0104899:	74 01                	je     f010489c <trap+0x17>
		asm volatile("hlt");
f010489b:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010489c:	e8 0d 1d 00 00       	call   f01065ae <cpunum>
f01048a1:	6b d0 74             	imul   $0x74,%eax,%edx
f01048a4:	81 c2 24 30 23 f0    	add    $0xf0233024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01048aa:	b8 01 00 00 00       	mov    $0x1,%eax
f01048af:	f0 87 02             	lock xchg %eax,(%edx)
f01048b2:	83 f8 02             	cmp    $0x2,%eax
f01048b5:	75 0c                	jne    f01048c3 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01048b7:	c7 04 24 20 14 12 f0 	movl   $0xf0121420,(%esp)
f01048be:	e8 ba 20 00 00       	call   f010697d <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f01048c3:	9c                   	pushf  
f01048c4:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01048c5:	f6 c4 02             	test   $0x2,%ah
f01048c8:	74 24                	je     f01048ee <trap+0x69>
f01048ca:	c7 44 24 0c ce 81 10 	movl   $0xf01081ce,0xc(%esp)
f01048d1:	f0 
f01048d2:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f01048d9:	f0 
f01048da:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
f01048e1:	00 
f01048e2:	c7 04 24 a6 81 10 f0 	movl   $0xf01081a6,(%esp)
f01048e9:	e8 97 b7 ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01048ee:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01048f2:	83 e0 03             	and    $0x3,%eax
f01048f5:	83 f8 03             	cmp    $0x3,%eax
f01048f8:	0f 85 a9 00 00 00    	jne    f01049a7 <trap+0x122>
f01048fe:	c7 04 24 20 14 12 f0 	movl   $0xf0121420,(%esp)
f0104905:	e8 73 20 00 00       	call   f010697d <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f010490a:	e8 9f 1c 00 00       	call   f01065ae <cpunum>
f010490f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104912:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f0104919:	75 24                	jne    f010493f <trap+0xba>
f010491b:	c7 44 24 0c e7 81 10 	movl   $0xf01081e7,0xc(%esp)
f0104922:	f0 
f0104923:	c7 44 24 08 45 7c 10 	movl   $0xf0107c45,0x8(%esp)
f010492a:	f0 
f010492b:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
f0104932:	00 
f0104933:	c7 04 24 a6 81 10 f0 	movl   $0xf01081a6,(%esp)
f010493a:	e8 46 b7 ff ff       	call   f0100085 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010493f:	e8 6a 1c 00 00       	call   f01065ae <cpunum>
f0104944:	6b c0 74             	imul   $0x74,%eax,%eax
f0104947:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010494d:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104951:	75 2e                	jne    f0104981 <trap+0xfc>
			env_free(curenv);
f0104953:	e8 56 1c 00 00       	call   f01065ae <cpunum>
f0104958:	be 20 30 23 f0       	mov    $0xf0233020,%esi
f010495d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104960:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0104964:	89 04 24             	mov    %eax,(%esp)
f0104967:	e8 cb f0 ff ff       	call   f0103a37 <env_free>
			curenv = NULL;
f010496c:	e8 3d 1c 00 00       	call   f01065ae <cpunum>
f0104971:	6b c0 74             	imul   $0x74,%eax,%eax
f0104974:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f010497b:	00 
			sched_yield();
f010497c:	e8 39 03 00 00       	call   f0104cba <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104981:	e8 28 1c 00 00       	call   f01065ae <cpunum>
f0104986:	bb 20 30 23 f0       	mov    $0xf0233020,%ebx
f010498b:	6b c0 74             	imul   $0x74,%eax,%eax
f010498e:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104992:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104997:	89 c7                	mov    %eax,%edi
f0104999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f010499b:	e8 0e 1c 00 00       	call   f01065ae <cpunum>
f01049a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a3:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01049a7:	89 35 60 2a 23 f0    	mov    %esi,0xf0232a60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch(tf->tf_trapno) {
f01049ad:	8b 46 28             	mov    0x28(%esi),%eax
f01049b0:	83 f8 0e             	cmp    $0xe,%eax
f01049b3:	74 42                	je     f01049f7 <trap+0x172>
f01049b5:	83 f8 30             	cmp    $0x30,%eax
f01049b8:	74 08                	je     f01049c2 <trap+0x13d>
f01049ba:	83 f8 03             	cmp    $0x3,%eax
f01049bd:	75 53                	jne    f0104a12 <trap+0x18d>
f01049bf:	90                   	nop
f01049c0:	eb 43                	jmp    f0104a05 <trap+0x180>
		case T_SYSCALL:
			tf->tf_regs.reg_eax=syscall(tf->tf_regs.reg_eax,
f01049c2:	8b 46 04             	mov    0x4(%esi),%eax
f01049c5:	89 44 24 14          	mov    %eax,0x14(%esp)
f01049c9:	8b 06                	mov    (%esi),%eax
f01049cb:	89 44 24 10          	mov    %eax,0x10(%esp)
f01049cf:	8b 46 10             	mov    0x10(%esi),%eax
f01049d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01049d6:	8b 46 18             	mov    0x18(%esi),%eax
f01049d9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049dd:	8b 46 14             	mov    0x14(%esi),%eax
f01049e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049e4:	8b 46 1c             	mov    0x1c(%esi),%eax
f01049e7:	89 04 24             	mov    %eax,(%esp)
f01049ea:	e8 71 03 00 00       	call   f0104d60 <syscall>
f01049ef:	89 46 1c             	mov    %eax,0x1c(%esi)
f01049f2:	e9 8f 00 00 00       	jmp    f0104a86 <trap+0x201>
						    tf->tf_regs.reg_edi,
					            tf->tf_regs.reg_esi);
			return;
		case T_PGFLT:
			TRAPDEBUG("page fault\n");
			page_fault_handler(tf);
f01049f7:	89 34 24             	mov    %esi,(%esp)
f01049fa:	e8 a4 fc ff ff       	call   f01046a3 <page_fault_handler>
f01049ff:	90                   	nop
f0104a00:	e9 81 00 00 00       	jmp    f0104a86 <trap+0x201>
			return;		
		case T_BRKPT:
			TRAPDEBUG("break point fault\n");
			monitor(tf);
f0104a05:	89 34 24             	mov    %esi,(%esp)
f0104a08:	e8 c6 be ff ff       	call   f01008d3 <monitor>
f0104a0d:	8d 76 00             	lea    0x0(%esi),%esi
f0104a10:	eb 74                	jmp    f0104a86 <trap+0x201>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104a12:	83 f8 27             	cmp    $0x27,%eax
f0104a15:	75 16                	jne    f0104a2d <trap+0x1a8>
		cprintf("Spurious interrupt on irq 7\n");
f0104a17:	c7 04 24 ee 81 10 f0 	movl   $0xf01081ee,(%esp)
f0104a1e:	e8 fc f7 ff ff       	call   f010421f <cprintf>
		print_trapframe(tf);
f0104a23:	89 34 24             	mov    %esi,(%esp)
f0104a26:	e8 e8 fa ff ff       	call   f0104513 <print_trapframe>
f0104a2b:	eb 59                	jmp    f0104a86 <trap+0x201>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if ( tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104a2d:	83 f8 20             	cmp    $0x20,%eax
f0104a30:	75 13                	jne    f0104a45 <trap+0x1c0>
		TRAPDEBUG("timer interrupt\n");
		lapic_eoi();
f0104a32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104a38:	e8 8d 1b 00 00       	call   f01065ca <lapic_eoi>
		sched_yield();
f0104a3d:	8d 76 00             	lea    0x0(%esi),%esi
f0104a40:	e8 75 02 00 00       	call   f0104cba <sched_yield>
		panic("trap_dispatch: timer cannot be reached\n");
	}	


	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104a45:	89 34 24             	mov    %esi,(%esp)
f0104a48:	e8 c6 fa ff ff       	call   f0104513 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104a4d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104a52:	75 1c                	jne    f0104a70 <trap+0x1eb>
		panic("unhandled trap in kernel");
f0104a54:	c7 44 24 08 0b 82 10 	movl   $0xf010820b,0x8(%esp)
f0104a5b:	f0 
f0104a5c:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
f0104a63:	00 
f0104a64:	c7 04 24 a6 81 10 f0 	movl   $0xf01081a6,(%esp)
f0104a6b:	e8 15 b6 ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f0104a70:	e8 39 1b 00 00       	call   f01065ae <cpunum>
f0104a75:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a78:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104a7e:	89 04 24             	mov    %eax,(%esp)
f0104a81:	e8 ba f1 ff ff       	call   f0103c40 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104a86:	e8 23 1b 00 00       	call   f01065ae <cpunum>
f0104a8b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a8e:	83 b8 28 30 23 f0 00 	cmpl   $0x0,-0xfdccfd8(%eax)
f0104a95:	74 2a                	je     f0104ac1 <trap+0x23c>
f0104a97:	e8 12 1b 00 00       	call   f01065ae <cpunum>
f0104a9c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a9f:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104aa5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104aa9:	75 16                	jne    f0104ac1 <trap+0x23c>
		env_run(curenv);
f0104aab:	e8 fe 1a 00 00       	call   f01065ae <cpunum>
f0104ab0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab3:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104ab9:	89 04 24             	mov    %eax,(%esp)
f0104abc:	e8 99 ee ff ff       	call   f010395a <env_run>
	else
		sched_yield();
f0104ac1:	e8 f4 01 00 00       	call   f0104cba <sched_yield>
	...

f0104ac8 <fn_divide>:


/*
 * Lab 3: Your code here for _alltraps
 */
TRAPHANDLER_NOEC(fn_divide,T_DIVIDE)
f0104ac8:	6a 00                	push   $0x0
f0104aca:	6a 00                	push   $0x0
f0104acc:	e9 f2 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104ad1:	90                   	nop

f0104ad2 <fn_debug>:
TRAPHANDLER_NOEC(fn_debug,T_DEBUG)
f0104ad2:	6a 00                	push   $0x0
f0104ad4:	6a 01                	push   $0x1
f0104ad6:	e9 e8 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104adb:	90                   	nop

f0104adc <fn_nmi>:
TRAPHANDLER_NOEC(fn_nmi,T_NMI)
f0104adc:	6a 00                	push   $0x0
f0104ade:	6a 02                	push   $0x2
f0104ae0:	e9 de 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104ae5:	90                   	nop

f0104ae6 <fn_brkpt>:
TRAPHANDLER_NOEC(fn_brkpt,T_BRKPT)
f0104ae6:	6a 00                	push   $0x0
f0104ae8:	6a 03                	push   $0x3
f0104aea:	e9 d4 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104aef:	90                   	nop

f0104af0 <fn_oflow>:
TRAPHANDLER_NOEC(fn_oflow,T_OFLOW)
f0104af0:	6a 00                	push   $0x0
f0104af2:	6a 04                	push   $0x4
f0104af4:	e9 ca 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104af9:	90                   	nop

f0104afa <fn_bound>:
TRAPHANDLER_NOEC(fn_bound,T_BOUND)
f0104afa:	6a 00                	push   $0x0
f0104afc:	6a 05                	push   $0x5
f0104afe:	e9 c0 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b03:	90                   	nop

f0104b04 <fn_illop>:
TRAPHANDLER_NOEC(fn_illop,T_ILLOP)
f0104b04:	6a 00                	push   $0x0
f0104b06:	6a 06                	push   $0x6
f0104b08:	e9 b6 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b0d:	90                   	nop

f0104b0e <fn_device>:
TRAPHANDLER_NOEC(fn_device,T_DEVICE)
f0104b0e:	6a 00                	push   $0x0
f0104b10:	6a 07                	push   $0x7
f0104b12:	e9 ac 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b17:	90                   	nop

f0104b18 <fn_dblflt>:
TRAPHANDLER(fn_dblflt,T_DBLFLT)
f0104b18:	6a 08                	push   $0x8
f0104b1a:	e9 a4 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b1f:	90                   	nop

f0104b20 <fn_coproc>:
/*TRAPHANDLER(fn_coproc,T_COPROC)*/
TRAPHANDLER(fn_coproc,98)
f0104b20:	6a 62                	push   $0x62
f0104b22:	e9 9c 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b27:	90                   	nop

f0104b28 <fn_tss>:
TRAPHANDLER(fn_tss,T_TSS)
f0104b28:	6a 0a                	push   $0xa
f0104b2a:	e9 94 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b2f:	90                   	nop

f0104b30 <fn_segnp>:
TRAPHANDLER(fn_segnp,T_SEGNP)
f0104b30:	6a 0b                	push   $0xb
f0104b32:	e9 8c 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b37:	90                   	nop

f0104b38 <fn_stack>:
TRAPHANDLER(fn_stack,T_STACK)
f0104b38:	6a 0c                	push   $0xc
f0104b3a:	e9 84 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b3f:	90                   	nop

f0104b40 <fn_gpflt>:
TRAPHANDLER(fn_gpflt,T_GPFLT)
f0104b40:	6a 0d                	push   $0xd
f0104b42:	e9 7c 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b47:	90                   	nop

f0104b48 <fn_pgflt>:
TRAPHANDLER(fn_pgflt,T_PGFLT)
f0104b48:	6a 0e                	push   $0xe
f0104b4a:	e9 74 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b4f:	90                   	nop

f0104b50 <fn_res>:
/*TRAPHANDLER(fn_res,T_RES)*/
TRAPHANDLER(fn_res,99)
f0104b50:	6a 63                	push   $0x63
f0104b52:	e9 6c 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b57:	90                   	nop

f0104b58 <fn_fperr>:
TRAPHANDLER_NOEC(fn_fperr,T_FPERR)
f0104b58:	6a 00                	push   $0x0
f0104b5a:	6a 10                	push   $0x10
f0104b5c:	e9 62 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b61:	90                   	nop

f0104b62 <fn_align>:
TRAPHANDLER(fn_align,T_ALIGN)
f0104b62:	6a 11                	push   $0x11
f0104b64:	e9 5a 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b69:	90                   	nop

f0104b6a <fn_mchk>:
TRAPHANDLER_NOEC(fn_mchk,T_MCHK)
f0104b6a:	6a 00                	push   $0x0
f0104b6c:	6a 12                	push   $0x12
f0104b6e:	e9 50 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b73:	90                   	nop

f0104b74 <fn_simderr>:
TRAPHANDLER_NOEC(fn_simderr,T_SIMDERR)
f0104b74:	6a 00                	push   $0x0
f0104b76:	6a 13                	push   $0x13
f0104b78:	e9 46 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b7d:	90                   	nop

f0104b7e <fn_syscall>:
TRAPHANDLER_NOEC(fn_syscall,T_SYSCALL)
f0104b7e:	6a 00                	push   $0x0
f0104b80:	6a 30                	push   $0x30
f0104b82:	e9 3c 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b87:	90                   	nop

f0104b88 <irq_timer>:

/* interrupt request */
TRAPHANDLER_NOEC(irq_timer, IRQ_OFFSET+IRQ_TIMER)
f0104b88:	6a 00                	push   $0x0
f0104b8a:	6a 20                	push   $0x20
f0104b8c:	e9 32 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b91:	90                   	nop

f0104b92 <irq_kbd>:
TRAPHANDLER_NOEC(irq_kbd, IRQ_OFFSET+IRQ_KBD)
f0104b92:	6a 00                	push   $0x0
f0104b94:	6a 21                	push   $0x21
f0104b96:	e9 28 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104b9b:	90                   	nop

f0104b9c <irq_serial>:
TRAPHANDLER_NOEC(irq_serial, IRQ_OFFSET+IRQ_SERIAL)
f0104b9c:	6a 00                	push   $0x0
f0104b9e:	6a 24                	push   $0x24
f0104ba0:	e9 1e 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104ba5:	90                   	nop

f0104ba6 <irq_spurious>:
TRAPHANDLER_NOEC(irq_spurious, IRQ_OFFSET+IRQ_SPURIOUS)
f0104ba6:	6a 00                	push   $0x0
f0104ba8:	6a 27                	push   $0x27
f0104baa:	e9 14 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104baf:	90                   	nop

f0104bb0 <irq_ide>:
TRAPHANDLER_NOEC(irq_ide, IRQ_OFFSET+IRQ_IDE)
f0104bb0:	6a 00                	push   $0x0
f0104bb2:	6a 2e                	push   $0x2e
f0104bb4:	e9 0a 00 00 00       	jmp    f0104bc3 <_alltraps>
f0104bb9:	90                   	nop

f0104bba <irq_error>:
TRAPHANDLER_NOEC(irq_error, IRQ_OFFSET+IRQ_ERROR)
f0104bba:	6a 00                	push   $0x0
f0104bbc:	6a 33                	push   $0x33
f0104bbe:	e9 00 00 00 00       	jmp    f0104bc3 <_alltraps>

f0104bc3 <_alltraps>:



.globl _alltraps
_alltraps:
	pushl %ds
f0104bc3:	1e                   	push   %ds
	pushl %es
f0104bc4:	06                   	push   %es
	pushal 
f0104bc5:	60                   	pusha  
	movw  $GD_KD, %ax
f0104bc6:	66 b8 10 00          	mov    $0x10,%ax
	movw  %ax, %ds
f0104bca:	8e d8                	mov    %eax,%ds
	movw  %ax, %es
f0104bcc:	8e c0                	mov    %eax,%es
	pushl %esp
f0104bce:	54                   	push   %esp
	call trap	
f0104bcf:	e8 b1 fc ff ff       	call   f0104885 <trap>
	...

f0104be0 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104be0:	55                   	push   %ebp
f0104be1:	89 e5                	mov    %esp,%ebp
f0104be3:	83 ec 18             	sub    $0x18,%esp
f0104be6:	8b 15 38 22 23 f0    	mov    0xf0232238,%edx
f0104bec:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104bf1:	8b 4a 54             	mov    0x54(%edx),%ecx
f0104bf4:	83 e9 01             	sub    $0x1,%ecx
f0104bf7:	83 f9 02             	cmp    $0x2,%ecx
f0104bfa:	76 0f                	jbe    f0104c0b <sched_halt+0x2b>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104bfc:	83 c0 01             	add    $0x1,%eax
f0104bff:	83 c2 7c             	add    $0x7c,%edx
f0104c02:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c07:	75 e8                	jne    f0104bf1 <sched_halt+0x11>
f0104c09:	eb 07                	jmp    f0104c12 <sched_halt+0x32>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104c0b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104c10:	75 1a                	jne    f0104c2c <sched_halt+0x4c>
		cprintf("No runnable environments in the system!\n");
f0104c12:	c7 04 24 10 84 10 f0 	movl   $0xf0108410,(%esp)
f0104c19:	e8 01 f6 ff ff       	call   f010421f <cprintf>
		while (1)
			monitor(NULL);
f0104c1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104c25:	e8 a9 bc ff ff       	call   f01008d3 <monitor>
f0104c2a:	eb f2                	jmp    f0104c1e <sched_halt+0x3e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104c30:	e8 79 19 00 00       	call   f01065ae <cpunum>
f0104c35:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c38:	c7 80 28 30 23 f0 00 	movl   $0x0,-0xfdccfd8(%eax)
f0104c3f:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104c42:	a1 8c 2e 23 f0       	mov    0xf0232e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104c47:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104c4c:	77 20                	ja     f0104c6e <sched_halt+0x8e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104c4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c52:	c7 44 24 08 1c 6d 10 	movl   $0xf0106d1c,0x8(%esp)
f0104c59:	f0 
f0104c5a:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
f0104c61:	00 
f0104c62:	c7 04 24 39 84 10 f0 	movl   $0xf0108439,(%esp)
f0104c69:	e8 17 b4 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0104c6e:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0104c74:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104c77:	e8 32 19 00 00       	call   f01065ae <cpunum>
f0104c7c:	6b d0 74             	imul   $0x74,%eax,%edx
f0104c7f:	81 c2 24 30 23 f0    	add    $0xf0233024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104c85:	b8 02 00 00 00       	mov    $0x2,%eax
f0104c8a:	f0 87 02             	lock xchg %eax,(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104c8d:	c7 04 24 20 14 12 f0 	movl   $0xf0121420,(%esp)
f0104c94:	e8 d3 1b 00 00       	call   f010686c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104c99:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104c9b:	e8 0e 19 00 00       	call   f01065ae <cpunum>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104ca0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ca3:	8b 80 30 30 23 f0    	mov    -0xfdccfd0(%eax),%eax
f0104ca9:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104cae:	89 c4                	mov    %eax,%esp
f0104cb0:	6a 00                	push   $0x0
f0104cb2:	6a 00                	push   $0x0
f0104cb4:	fb                   	sti    
f0104cb5:	f4                   	hlt    
f0104cb6:	eb fd                	jmp    f0104cb5 <sched_halt+0xd5>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104cb8:	c9                   	leave  
f0104cb9:	c3                   	ret    

f0104cba <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104cba:	55                   	push   %ebp
f0104cbb:	89 e5                	mov    %esp,%ebp
f0104cbd:	57                   	push   %edi
f0104cbe:	56                   	push   %esi
f0104cbf:	53                   	push   %ebx
f0104cc0:	83 ec 1c             	sub    $0x1c,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	int start;
	struct Env* last=thiscpu->cpu_env;
f0104cc3:	e8 e6 18 00 00       	call   f01065ae <cpunum>
f0104cc8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ccb:	8b b8 28 30 23 f0    	mov    -0xfdccfd8(%eax),%edi
	start=last?ENVX(last->env_id)%NENV:0;
f0104cd1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104cd6:	85 ff                	test   %edi,%edi
f0104cd8:	74 14                	je     f0104cee <sched_yield+0x34>
f0104cda:	8b 4f 48             	mov    0x48(%edi),%ecx
	start=start==0?0:(start+1)%NENV;
f0104cdd:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0104ce3:	74 09                	je     f0104cee <sched_yield+0x34>
f0104ce5:	83 c1 01             	add    $0x1,%ecx
f0104ce8:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
	bool find=false;
	for(i=start; (i!=start) || !find ; i=(i+1)%NENV,find=true ) {
		if (envs[i].env_status==ENV_RUNNABLE) {
f0104cee:	8b 35 38 22 23 f0    	mov    0xf0232238,%esi
f0104cf4:	89 c8                	mov    %ecx,%eax
f0104cf6:	ba 00 00 00 00       	mov    $0x0,%edx
	int start;
	struct Env* last=thiscpu->cpu_env;
	start=last?ENVX(last->env_id)%NENV:0;
	start=start==0?0:(start+1)%NENV;
	bool find=false;
	for(i=start; (i!=start) || !find ; i=(i+1)%NENV,find=true ) {
f0104cfb:	bb 01 00 00 00       	mov    $0x1,%ebx
f0104d00:	eb 2a                	jmp    f0104d2c <sched_yield+0x72>
		if (envs[i].env_status==ENV_RUNNABLE) {
f0104d02:	6b d0 7c             	imul   $0x7c,%eax,%edx
f0104d05:	8d 14 16             	lea    (%esi,%edx,1),%edx
f0104d08:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104d0c:	75 08                	jne    f0104d16 <sched_yield+0x5c>
			env_run(&envs[i]);
f0104d0e:	89 14 24             	mov    %edx,(%esp)
f0104d11:	e8 44 ec ff ff       	call   f010395a <env_run>
	int start;
	struct Env* last=thiscpu->cpu_env;
	start=last?ENVX(last->env_id)%NENV:0;
	start=start==0?0:(start+1)%NENV;
	bool find=false;
	for(i=start; (i!=start) || !find ; i=(i+1)%NENV,find=true ) {
f0104d16:	83 c0 01             	add    $0x1,%eax
f0104d19:	89 c2                	mov    %eax,%edx
f0104d1b:	c1 fa 1f             	sar    $0x1f,%edx
f0104d1e:	c1 ea 16             	shr    $0x16,%edx
f0104d21:	01 d0                	add    %edx,%eax
f0104d23:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104d28:	29 d0                	sub    %edx,%eax
f0104d2a:	89 da                	mov    %ebx,%edx
f0104d2c:	39 c8                	cmp    %ecx,%eax
f0104d2e:	75 d2                	jne    f0104d02 <sched_yield+0x48>
f0104d30:	84 d2                	test   %dl,%dl
f0104d32:	74 ce                	je     f0104d02 <sched_yield+0x48>
		}
	}

//	cprintf("sched don't find a new to run\n");
	
	if ( last && last->env_status==ENV_RUNNING) {
f0104d34:	85 ff                	test   %edi,%edi
f0104d36:	74 12                	je     f0104d4a <sched_yield+0x90>
f0104d38:	83 7f 54 03          	cmpl   $0x3,0x54(%edi)
f0104d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104d40:	75 08                	jne    f0104d4a <sched_yield+0x90>
		env_run(last);
f0104d42:	89 3c 24             	mov    %edi,(%esp)
f0104d45:	e8 10 ec ff ff       	call   f010395a <env_run>
	}

	// sched_halt never returns
	sched_halt();
f0104d4a:	e8 91 fe ff ff       	call   f0104be0 <sched_halt>
}
f0104d4f:	83 c4 1c             	add    $0x1c,%esp
f0104d52:	5b                   	pop    %ebx
f0104d53:	5e                   	pop    %esi
f0104d54:	5f                   	pop    %edi
f0104d55:	5d                   	pop    %ebp
f0104d56:	c3                   	ret    
	...

f0104d60 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104d60:	55                   	push   %ebp
f0104d61:	89 e5                	mov    %esp,%ebp
f0104d63:	83 ec 48             	sub    $0x48,%esp
f0104d66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104d69:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104d6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104d6f:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d72:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104d75:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104d78:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// Return any appropriate return value.
	// LAB 3: Your code here.

//	panic("syscall not implemented");

	switch (syscallno) {
f0104d7b:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
f0104d80:	83 fa 0c             	cmp    $0xc,%edx
f0104d83:	0f 87 8b 05 00 00    	ja     f0105314 <syscall+0x5b4>
f0104d89:	ff 24 95 7c 84 10 f0 	jmp    *-0xfef7b84(,%edx,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.
//	cprintf("Enter the sys_cputs function\n");
	// LAB 3: Your code here.
	user_mem_assert(curenv,s,len,PTE_U);
f0104d90:	e8 19 18 00 00       	call   f01065ae <cpunum>
f0104d95:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104d9c:	00 
f0104d9d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104da1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104da5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104da8:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104dae:	89 04 24             	mov    %eax,(%esp)
f0104db1:	e8 a4 c6 ff ff       	call   f010145a <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104db6:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104dba:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104dbe:	c7 04 24 4a 70 10 f0 	movl   $0xf010704a,(%esp)
f0104dc5:	e8 55 f4 ff ff       	call   f010421f <cprintf>
f0104dca:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dcf:	e9 40 05 00 00       	jmp    f0105314 <syscall+0x5b4>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104dd4:	e8 86 b5 ff ff       	call   f010035f <cons_getc>
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char*)a1,a2);
			break;
		case SYS_cgetc:
			return	sys_cgetc();
f0104dd9:	e9 36 05 00 00       	jmp    f0105314 <syscall+0x5b4>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104dde:	66 90                	xchg   %ax,%ax
f0104de0:	e8 c9 17 00 00       	call   f01065ae <cpunum>
f0104de5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104de8:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104dee:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((char*)a1,a2);
			break;
		case SYS_cgetc:
			return	sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f0104df1:	e9 1e 05 00 00       	jmp    f0105314 <syscall+0x5b4>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104df6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104dfd:	00 
f0104dfe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e01:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e05:	89 34 24             	mov    %esi,(%esp)
f0104e08:	e8 5e ea ff ff       	call   f010386b <envid2env>
f0104e0d:	85 c0                	test   %eax,%eax
f0104e0f:	0f 88 ff 04 00 00    	js     f0105314 <syscall+0x5b4>
		return r;
	if (e == curenv)
f0104e15:	e8 94 17 00 00       	call   f01065ae <cpunum>
f0104e1a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e20:	39 90 28 30 23 f0    	cmp    %edx,-0xfdccfd8(%eax)
f0104e26:	75 23                	jne    f0104e4b <syscall+0xeb>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104e28:	e8 81 17 00 00       	call   f01065ae <cpunum>
f0104e2d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e30:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104e36:	8b 40 48             	mov    0x48(%eax),%eax
f0104e39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e3d:	c7 04 24 46 84 10 f0 	movl   $0xf0108446,(%esp)
f0104e44:	e8 d6 f3 ff ff       	call   f010421f <cprintf>
f0104e49:	eb 28                	jmp    f0104e73 <syscall+0x113>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104e4b:	8b 72 48             	mov    0x48(%edx),%esi
f0104e4e:	e8 5b 17 00 00       	call   f01065ae <cpunum>
f0104e53:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104e57:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e5a:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0104e60:	8b 40 48             	mov    0x48(%eax),%eax
f0104e63:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e67:	c7 04 24 61 84 10 f0 	movl   $0xf0108461,(%esp)
f0104e6e:	e8 ac f3 ff ff       	call   f010421f <cprintf>
	env_destroy(e);
f0104e73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e76:	89 04 24             	mov    %eax,(%esp)
f0104e79:	e8 c2 ed ff ff       	call   f0103c40 <env_destroy>
f0104e7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e83:	e9 8c 04 00 00       	jmp    f0105314 <syscall+0x5b4>
	//   allocated!
	

	// LAB 4: Your code here.
	struct PageInfo *page=NULL;
	struct Env* env=NULL;
f0104e88:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	int res;


	if ( !(perm & PTE_U) || !(perm & PTE_P) ) {
f0104e8f:	89 d8                	mov    %ebx,%eax
f0104e91:	83 e0 05             	and    $0x5,%eax
f0104e94:	83 f8 05             	cmp    $0x5,%eax
f0104e97:	0f 85 90 00 00 00    	jne    f0104f2d <syscall+0x1cd>
		return -E_INVAL;
	}

	if ( perm & (~PTE_SYSCALL) ) {
f0104e9d:	f7 c3 f8 f1 ff ff    	test   $0xfffff1f8,%ebx
f0104ea3:	0f 85 84 00 00 00    	jne    f0104f2d <syscall+0x1cd>
		return -E_INVAL;		
	}

	if ( (PGOFF(va) != 0) || ( (uintptr_t)va >= UTOP ) ) {
f0104ea9:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104eaf:	75 7c                	jne    f0104f2d <syscall+0x1cd>
f0104eb1:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104eb7:	77 74                	ja     f0104f2d <syscall+0x1cd>
		return -E_INVAL;
	}
	
  	SYSDEBUG("sys_page_alloc: before page_alloc\n");
	page=page_alloc(true);
f0104eb9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104ec0:	e8 71 c3 ff ff       	call   f0101236 <page_alloc>
f0104ec5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  	SYSDEBUG("sys_page_alloc: after page_alloc\n");
	envid2env(envid,&env,true);
f0104ec8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ecf:	00 
f0104ed0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ed7:	89 34 24             	mov    %esi,(%esp)
f0104eda:	e8 8c e9 ff ff       	call   f010386b <envid2env>
	SYSDEBUG("sys_page_alloc: after envid2env\n");
	res= page_insert(env->env_pgdir, page, va, perm);
f0104edf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104ee3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104ee7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104eea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104ef1:	8b 40 60             	mov    0x60(%eax),%eax
f0104ef4:	89 04 24             	mov    %eax,(%esp)
f0104ef7:	e8 80 c7 ff ff       	call   f010167c <page_insert>
  	SYSDEBUG("sys_page_alloc: after page_insert\n");
	if (res<0) {
f0104efc:	85 c0                	test   %eax,%eax
f0104efe:	0f 88 10 04 00 00    	js     f0105314 <syscall+0x5b4>
		// NO_MEM
		return res;
	}

	res=envid2env(envid, &env, true);
f0104f04:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f0b:	00 
f0104f0c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f0f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f13:	89 34 24             	mov    %esi,(%esp)
f0104f16:	e8 50 e9 ff ff       	call   f010386b <envid2env>
f0104f1b:	85 c0                	test   %eax,%eax
f0104f1d:	0f 9f c2             	setg   %dl
f0104f20:	0f b6 d2             	movzbl %dl,%edx
f0104f23:	83 ea 01             	sub    $0x1,%edx
f0104f26:	21 d0                	and    %edx,%eax
f0104f28:	e9 e7 03 00 00       	jmp    f0105314 <syscall+0x5b4>
f0104f2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104f32:	e9 dd 03 00 00       	jmp    f0105314 <syscall+0x5b4>
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	int res;
	struct Env* srcenv=NULL;
f0104f37:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct Env* dstenv=NULL;
f0104f3e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	struct PageInfo* page=NULL;	


	if ( (uintptr_t)srcva>=UTOP || (uintptr_t)dstva>=UTOP || PGOFF(srcva)!=0 || PGOFF(dstva)!=0) {
f0104f45:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104f4b:	0f 87 d1 00 00 00    	ja     f0105022 <syscall+0x2c2>
f0104f51:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104f58:	0f 87 c4 00 00 00    	ja     f0105022 <syscall+0x2c2>
f0104f5e:	8b 45 18             	mov    0x18(%ebp),%eax
f0104f61:	09 f8                	or     %edi,%eax
f0104f63:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104f68:	0f 85 b4 00 00 00    	jne    f0105022 <syscall+0x2c2>
		return -E_INVAL;
	}
	
	SYSDEBUG("sys_page_map: before envid2env src\n");	
	res=envid2env(srcenvid,&srcenv,true);
f0104f6e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f75:	00 
f0104f76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f7d:	89 34 24             	mov    %esi,(%esp)
f0104f80:	e8 e6 e8 ff ff       	call   f010386b <envid2env>
	if (res<0) {	
f0104f85:	85 c0                	test   %eax,%eax
f0104f87:	0f 88 87 03 00 00    	js     f0105314 <syscall+0x5b4>
		// BAD_ENV
		return res;
	}
	SYSDEBUG("sys_page_map: after envid2env src\n");
	res=envid2env(dstenvid,&dstenv,true);
f0104f8d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f94:	00 
f0104f95:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f98:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f9c:	89 1c 24             	mov    %ebx,(%esp)
f0104f9f:	e8 c7 e8 ff ff       	call   f010386b <envid2env>
	if (res<0) {
f0104fa4:	85 c0                	test   %eax,%eax
f0104fa6:	0f 88 68 03 00 00    	js     f0105314 <syscall+0x5b4>
		// BAD_ENV
		return res;
	}
	SYSDEBUG("sys_page_map: after envid2env dst\n");
	pte_t* pte=NULL;
f0104fac:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	page=page_lookup(srcenv->env_pgdir, srcva, &pte);
f0104fb3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104fb6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104fba:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104fbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fc1:	8b 40 60             	mov    0x60(%eax),%eax
f0104fc4:	89 04 24             	mov    %eax,(%esp)
f0104fc7:	e8 e8 c5 ff ff       	call   f01015b4 <page_lookup>
	SYSDEBUG("sys_page_map: after page_lookup\n");
	if (page==NULL) {
f0104fcc:	85 c0                	test   %eax,%eax
f0104fce:	74 52                	je     f0105022 <syscall+0x2c2>
		return -E_INVAL;
	}

	if ( !(perm & PTE_U) || !(perm & PTE_P) ) {
f0104fd0:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104fd3:	83 e2 05             	and    $0x5,%edx
f0104fd6:	83 fa 05             	cmp    $0x5,%edx
f0104fd9:	75 47                	jne    f0105022 <syscall+0x2c2>
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		case SYS_page_alloc:
			return sys_page_alloc((envid_t)a1, (void*)a2, a3);
		case SYS_page_map:
			return sys_page_map((envid_t)a1, (void*)a2, (envid_t)a3, (void*)a4,a5);
f0104fdb:	8b 55 1c             	mov    0x1c(%ebp),%edx

	if ( !(perm & PTE_U) || !(perm & PTE_P) ) {
		return -E_INVAL;
	}

	if ( perm & (~PTE_SYSCALL) ) {
f0104fde:	f7 c2 f8 f1 ff ff    	test   $0xfffff1f8,%edx
f0104fe4:	75 3c                	jne    f0105022 <syscall+0x2c2>
		return -E_INVAL;
	}

	if ( (perm & PTE_W) && !(*pte & PTE_W) ) {
f0104fe6:	f6 c2 02             	test   $0x2,%dl
f0104fe9:	74 08                	je     f0104ff3 <syscall+0x293>
f0104feb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104fee:	f6 01 02             	testb  $0x2,(%ecx)
f0104ff1:	74 2f                	je     f0105022 <syscall+0x2c2>
		return -E_INVAL;
	}

	res=page_insert(dstenv->env_pgdir, page, dstva, perm);
f0104ff3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104ff7:	8b 55 18             	mov    0x18(%ebp),%edx
f0104ffa:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105002:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105005:	8b 40 60             	mov    0x60(%eax),%eax
f0105008:	89 04 24             	mov    %eax,(%esp)
f010500b:	e8 6c c6 ff ff       	call   f010167c <page_insert>
f0105010:	85 c0                	test   %eax,%eax
f0105012:	0f 9f c2             	setg   %dl
f0105015:	0f b6 d2             	movzbl %dl,%edx
f0105018:	83 ea 01             	sub    $0x1,%edx
f010501b:	21 d0                	and    %edx,%eax
f010501d:	e9 f2 02 00 00       	jmp    f0105314 <syscall+0x5b4>
f0105022:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105027:	e9 e8 02 00 00       	jmp    f0105314 <syscall+0x5b4>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	struct Env* env=NULL;
f010502c:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	struct PageInfo* page=NULL;
	int res;	

	if ( (uintptr_t)va > UTOP || PGOFF(va)!=0 ) {
f0105033:	81 ff 00 00 c0 ee    	cmp    $0xeec00000,%edi
f0105039:	77 43                	ja     f010507e <syscall+0x31e>
f010503b:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0105041:	75 3b                	jne    f010507e <syscall+0x31e>
		return -E_INVAL;
	}

	res=envid2env(envid,&env,true);
f0105043:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010504a:	00 
f010504b:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010504e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105052:	89 34 24             	mov    %esi,(%esp)
f0105055:	e8 11 e8 ff ff       	call   f010386b <envid2env>
	if (res<0) {
f010505a:	85 c0                	test   %eax,%eax
f010505c:	0f 88 b2 02 00 00    	js     f0105314 <syscall+0x5b4>
		return res;
	}
	
	page_remove(env->env_pgdir,va);
f0105062:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105066:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105069:	8b 40 60             	mov    0x60(%eax),%eax
f010506c:	89 04 24             	mov    %eax,(%esp)
f010506f:	e8 b1 c5 ff ff       	call   f0101625 <page_remove>
f0105074:	b8 00 00 00 00       	mov    $0x0,%eax
f0105079:	e9 96 02 00 00       	jmp    f0105314 <syscall+0x5b4>
f010507e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105083:	e9 8c 02 00 00       	jmp    f0105314 <syscall+0x5b4>
	// status is set to ENV_NOT_RUNNABLE, and the register set is copied
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *newenv=NULL;
f0105088:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	envid_t res=env_alloc(&newenv,curenv->env_id);		
f010508f:	90                   	nop
f0105090:	e8 19 15 00 00       	call   f01065ae <cpunum>
f0105095:	6b c0 74             	imul   $0x74,%eax,%eax
f0105098:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010509e:	8b 40 48             	mov    0x48(%eax),%eax
f01050a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01050a8:	89 04 24             	mov    %eax,(%esp)
f01050ab:	e8 ee eb ff ff       	call   f0103c9e <env_alloc>
	if (res<0) {
f01050b0:	85 c0                	test   %eax,%eax
f01050b2:	0f 88 5c 02 00 00    	js     f0105314 <syscall+0x5b4>
		return res;
	}
	
	newenv->env_status=ENV_NOT_RUNNABLE;
f01050b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050bb:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	newenv->env_tf=curenv->env_tf;
f01050c2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01050c5:	e8 e4 14 00 00       	call   f01065ae <cpunum>
f01050ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01050cd:	8b b0 28 30 23 f0    	mov    -0xfdccfd8(%eax),%esi
f01050d3:	b9 11 00 00 00       	mov    $0x11,%ecx
f01050d8:	89 df                	mov    %ebx,%edi
f01050da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	newenv->env_tf.tf_regs.reg_eax=0;
f01050dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050df:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return newenv->env_id;
f01050e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050e9:	8b 40 48             	mov    0x48(%eax),%eax
f01050ec:	e9 23 02 00 00       	jmp    f0105314 <syscall+0x5b4>
	// envid to a struct Env.
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.
	// LAB 4: Your code here.
	struct Env* env=NULL;
f01050f1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int res=envid2env(envid,&env,true);
f01050f8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050ff:	00 
f0105100:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105103:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105107:	89 34 24             	mov    %esi,(%esp)
f010510a:	e8 5c e7 ff ff       	call   f010386b <envid2env>
	if (res<0) {
f010510f:	85 c0                	test   %eax,%eax
f0105111:	0f 88 fd 01 00 00    	js     f0105314 <syscall+0x5b4>
		SYSDEBUG("sys_env_set_status: %e\n",res);
		// BAD_ENV
		return res;
	}
	if (status!=ENV_RUNNABLE && status!=ENV_NOT_RUNNABLE) {
f0105117:	83 ff 02             	cmp    $0x2,%edi
f010511a:	74 0e                	je     f010512a <syscall+0x3ca>
f010511c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105121:	83 ff 04             	cmp    $0x4,%edi
f0105124:	0f 85 ea 01 00 00    	jne    f0105314 <syscall+0x5b4>
		SYSDEBUG("sys_env_set_status: %e\n",-E_INVAL);
		return -E_INVAL;
	}	

	env->env_status=status;
f010512a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010512d:	89 78 54             	mov    %edi,0x54(%eax)
f0105130:	b8 00 00 00 00       	mov    $0x0,%eax
f0105135:	e9 da 01 00 00       	jmp    f0105314 <syscall+0x5b4>
	SYSDEBUG("sys_env_set_pgfault_upcall: envid: %d\n",envid);
	if (func==NULL) {
		SYSDEBUG("sys_env_set_pgfault_upcall: func is NULL\n");
	}

	struct Env* env=NULL;
f010513a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	int res=envid2env(envid,&env,true);
f0105141:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105148:	00 
f0105149:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010514c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105150:	89 34 24             	mov    %esi,(%esp)
f0105153:	e8 13 e7 ff ff       	call   f010386b <envid2env>
	if (res<0) {
f0105158:	85 c0                	test   %eax,%eax
f010515a:	0f 88 b4 01 00 00    	js     f0105314 <syscall+0x5b4>
		SYSDEBUG("sys_env_Set_pgfault_upcall: %e\n",res);
		return res;
	}
	
	env->env_pgfault_upcall=func;
f0105160:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105163:	89 78 64             	mov    %edi,0x64(%eax)
f0105166:	b8 00 00 00 00       	mov    $0x0,%eax
f010516b:	e9 a4 01 00 00       	jmp    f0105314 <syscall+0x5b4>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105170:	e8 45 fb ff ff       	call   f0104cba <sched_yield>
	struct Env* env;
	int res;
	struct PageInfo* page;
	pte_t* pte;

	res=envid2env(envid,&env,0);
f0105175:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010517c:	00 
f010517d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105180:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105184:	89 34 24             	mov    %esi,(%esp)
f0105187:	e8 df e6 ff ff       	call   f010386b <envid2env>
f010518c:	89 c2                	mov    %eax,%edx
	if ( res<0 ) {
f010518e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0105193:	85 d2                	test   %edx,%edx
f0105195:	0f 88 79 01 00 00    	js     f0105314 <syscall+0x5b4>
		return -E_BAD_ENV;
	}
	
	if ( env->env_ipc_recving==0 || env->env_status!=ENV_NOT_RUNNABLE ) {
f010519b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010519e:	80 7a 68 00          	cmpb   $0x0,0x68(%edx)
f01051a2:	0f 84 f1 00 00 00    	je     f0105299 <syscall+0x539>
f01051a8:	83 7a 54 04          	cmpl   $0x4,0x54(%edx)
f01051ac:	0f 85 e7 00 00 00    	jne    f0105299 <syscall+0x539>
		return -E_IPC_NOT_RECV;
	}

	if ( (uintptr_t)srcva < UTOP) {
f01051b2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01051b8:	0f 87 9f 00 00 00    	ja     f010525d <syscall+0x4fd>
		if ( (uintptr_t)(srcva)%PGSIZE !=0 ) {
f01051be:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01051c4:	0f 85 d6 00 00 00    	jne    f01052a0 <syscall+0x540>
			SYSDEBUG("sys_ipc_try_send: srcva not aligned\n");
			return -E_INVAL;
		}

		if ( !(perm & PTE_U) || !(perm & PTE_P) ) {
f01051ca:	8b 45 18             	mov    0x18(%ebp),%eax
f01051cd:	83 e0 05             	and    $0x5,%eax
f01051d0:	83 f8 05             	cmp    $0x5,%eax
f01051d3:	0f 85 c7 00 00 00    	jne    f01052a0 <syscall+0x540>
			SYSDEBUG("sys_ipc_try_send: perm U P\n");
			return -E_INVAL;
		}
		if ( perm & (~PTE_SYSCALL) ) {
f01051d9:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f01051e0:	0f 85 ba 00 00 00    	jne    f01052a0 <syscall+0x540>
			SYSDEBUG("sys_ipc_try_send: perm PTE_SYSCALL\n");
			return -E_INVAL;
		}
		page=page_lookup(curenv->env_pgdir, srcva, &pte);
f01051e6:	e8 c3 13 00 00       	call   f01065ae <cpunum>
f01051eb:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01051ee:	89 54 24 08          	mov    %edx,0x8(%esp)
f01051f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01051f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01051f9:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01051ff:	8b 40 60             	mov    0x60(%eax),%eax
f0105202:	89 04 24             	mov    %eax,(%esp)
f0105205:	e8 aa c3 ff ff       	call   f01015b4 <page_lookup>
		if ( page == NULL) {
f010520a:	85 c0                	test   %eax,%eax
f010520c:	0f 84 8e 00 00 00    	je     f01052a0 <syscall+0x540>
			SYSDEBUG("sys_ipc_try_send: pte null\n");
			return -E_INVAL;
		}
		if ( !(*pte & PTE_P) ) {
f0105212:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105215:	f6 02 01             	testb  $0x1,(%edx)
f0105218:	0f 84 82 00 00 00    	je     f01052a0 <syscall+0x540>
			SYSDEBUG("sys_ipc_try_send: page not mapped\n");
			return -E_INVAL;
		}
	}

	if ( (uintptr_t)(env->env_ipc_dstva) < UTOP && (uintptr_t)srcva< UTOP) {
f010521e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105221:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105224:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010522a:	77 31                	ja     f010525d <syscall+0x4fd>
	
		res=page_insert(env->env_pgdir,page,env->env_ipc_dstva,perm);	
f010522c:	8b 5d 18             	mov    0x18(%ebp),%ebx
f010522f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105233:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105237:	89 44 24 04          	mov    %eax,0x4(%esp)
f010523b:	8b 42 60             	mov    0x60(%edx),%eax
f010523e:	89 04 24             	mov    %eax,(%esp)
f0105241:	e8 36 c4 ff ff       	call   f010167c <page_insert>
f0105246:	89 c2                	mov    %eax,%edx
		if( res<0 ) {
f0105248:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010524d:	85 d2                	test   %edx,%edx
f010524f:	0f 88 bf 00 00 00    	js     f0105314 <syscall+0x5b4>
			return -E_NO_MEM;
		}
		env->env_ipc_perm=perm;
f0105255:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105258:	89 58 78             	mov    %ebx,0x78(%eax)
f010525b:	eb 07                	jmp    f0105264 <syscall+0x504>

	}
	else {
		env->env_ipc_perm=0;
f010525d:	c7 42 78 00 00 00 00 	movl   $0x0,0x78(%edx)
	}

	
	env->env_ipc_recving=0;
f0105264:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105267:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	env->env_ipc_from=curenv->env_id;
f010526b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010526e:	e8 3b 13 00 00       	call   f01065ae <cpunum>
f0105273:	6b c0 74             	imul   $0x74,%eax,%eax
f0105276:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010527c:	8b 40 48             	mov    0x48(%eax),%eax
f010527f:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value=value;
f0105282:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105285:	89 78 70             	mov    %edi,0x70(%eax)
	env->env_status=ENV_RUNNABLE;
f0105288:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010528b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0105292:	b8 00 00 00 00       	mov    $0x0,%eax
f0105297:	eb 7b                	jmp    f0105314 <syscall+0x5b4>
f0105299:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
f010529e:	eb 74                	jmp    f0105314 <syscall+0x5b4>
f01052a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01052a5:	eb 6d                	jmp    f0105314 <syscall+0x5b4>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ( (uintptr_t)dstva < UTOP) {
f01052a7:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01052ad:	8d 76 00             	lea    0x0(%esi),%esi
f01052b0:	77 08                	ja     f01052ba <syscall+0x55a>
		if ( (uintptr_t)dstva % PGSIZE !=0 ) {
f01052b2:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f01052b8:	75 55                	jne    f010530f <syscall+0x5af>
			SYSDEBUG("sys_ipc_recv: dstva not aligned\n");
			return -E_INVAL;
		}
	}
	curenv->env_tf.tf_regs.reg_eax=0;
f01052ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01052c0:	e8 e9 12 00 00       	call   f01065ae <cpunum>
f01052c5:	bb 20 30 23 f0       	mov    $0xf0233020,%ebx
f01052ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01052cd:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01052d1:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	curenv->env_ipc_recving=1;
f01052d8:	e8 d1 12 00 00       	call   f01065ae <cpunum>
f01052dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01052e0:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01052e4:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva=dstva;
f01052e8:	e8 c1 12 00 00       	call   f01065ae <cpunum>
f01052ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01052f0:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01052f4:	89 70 6c             	mov    %esi,0x6c(%eax)
	curenv->env_status=ENV_NOT_RUNNABLE;
f01052f7:	e8 b2 12 00 00       	call   f01065ae <cpunum>
f01052fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01052ff:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0105303:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f010530a:	e8 ab f9 ff ff       	call   f0104cba <sched_yield>
f010530f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return sys_ipc_recv((void*)a1);
		default:
			return -E_NO_SYS;
	}
	return 0;
}
f0105314:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105317:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010531a:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010531d:	89 ec                	mov    %ebp,%esp
f010531f:	5d                   	pop    %ebp
f0105320:	c3                   	ret    
	...

f0105330 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105330:	55                   	push   %ebp
f0105331:	89 e5                	mov    %esp,%ebp
f0105333:	57                   	push   %edi
f0105334:	56                   	push   %esi
f0105335:	53                   	push   %ebx
f0105336:	83 ec 14             	sub    $0x14,%esp
f0105339:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010533c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010533f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105342:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105345:	8b 1a                	mov    (%edx),%ebx
f0105347:	8b 01                	mov    (%ecx),%eax
f0105349:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010534c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0105353:	e9 88 00 00 00       	jmp    f01053e0 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0105358:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010535b:	01 d8                	add    %ebx,%eax
f010535d:	89 c7                	mov    %eax,%edi
f010535f:	c1 ef 1f             	shr    $0x1f,%edi
f0105362:	01 c7                	add    %eax,%edi
f0105364:	d1 ff                	sar    %edi
f0105366:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105369:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010536c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0105370:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105372:	eb 03                	jmp    f0105377 <stab_binsearch+0x47>
			m--;
f0105374:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105377:	39 c3                	cmp    %eax,%ebx
f0105379:	7f 0c                	jg     f0105387 <stab_binsearch+0x57>
f010537b:	0f b6 0a             	movzbl (%edx),%ecx
f010537e:	83 ea 0c             	sub    $0xc,%edx
f0105381:	39 f1                	cmp    %esi,%ecx
f0105383:	75 ef                	jne    f0105374 <stab_binsearch+0x44>
f0105385:	eb 05                	jmp    f010538c <stab_binsearch+0x5c>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105387:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010538a:	eb 54                	jmp    f01053e0 <stab_binsearch+0xb0>
f010538c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010538f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105392:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105395:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105399:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010539c:	76 11                	jbe    f01053af <stab_binsearch+0x7f>
			*region_left = m;
f010539e:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01053a1:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01053a3:	8d 5f 01             	lea    0x1(%edi),%ebx
f01053a6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01053ad:	eb 31                	jmp    f01053e0 <stab_binsearch+0xb0>
		} else if (stabs[m].n_value > addr) {
f01053af:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01053b2:	73 17                	jae    f01053cb <stab_binsearch+0x9b>
			*region_right = m - 1;
f01053b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053b7:	83 e8 01             	sub    $0x1,%eax
f01053ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01053bd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01053c0:	89 02                	mov    %eax,(%edx)
f01053c2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01053c9:	eb 15                	jmp    f01053e0 <stab_binsearch+0xb0>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01053cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01053ce:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01053d1:	89 19                	mov    %ebx,(%ecx)
			l = m;
			addr++;
f01053d3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01053d7:	89 c3                	mov    %eax,%ebx
f01053d9:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01053e0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01053e3:	0f 8e 6f ff ff ff    	jle    f0105358 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01053e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01053ed:	75 0f                	jne    f01053fe <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01053ef:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01053f2:	8b 02                	mov    (%edx),%eax
f01053f4:	83 e8 01             	sub    $0x1,%eax
f01053f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01053fa:	89 01                	mov    %eax,(%ecx)
f01053fc:	eb 2c                	jmp    f010542a <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01053fe:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105401:	8b 03                	mov    (%ebx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105403:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105406:	8b 0a                	mov    (%edx),%ecx
f0105408:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010540b:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010540e:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105412:	eb 03                	jmp    f0105417 <stab_binsearch+0xe7>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105414:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105417:	39 c8                	cmp    %ecx,%eax
f0105419:	7e 0a                	jle    f0105425 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f010541b:	0f b6 1a             	movzbl (%edx),%ebx
f010541e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105421:	39 f3                	cmp    %esi,%ebx
f0105423:	75 ef                	jne    f0105414 <stab_binsearch+0xe4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0105425:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105428:	89 02                	mov    %eax,(%edx)
	}
}
f010542a:	83 c4 14             	add    $0x14,%esp
f010542d:	5b                   	pop    %ebx
f010542e:	5e                   	pop    %esi
f010542f:	5f                   	pop    %edi
f0105430:	5d                   	pop    %ebp
f0105431:	c3                   	ret    

f0105432 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105432:	55                   	push   %ebp
f0105433:	89 e5                	mov    %esp,%ebp
f0105435:	83 ec 58             	sub    $0x58,%esp
f0105438:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010543b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010543e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105441:	8b 75 08             	mov    0x8(%ebp),%esi
f0105444:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105447:	c7 03 b0 84 10 f0    	movl   $0xf01084b0,(%ebx)
	info->eip_line = 0;
f010544d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105454:	c7 43 08 b0 84 10 f0 	movl   $0xf01084b0,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010545b:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105462:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105465:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010546c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105472:	76 1f                	jbe    f0105493 <debuginfo_eip+0x61>
f0105474:	bf 6f 67 11 f0       	mov    $0xf011676f,%edi
f0105479:	c7 45 c4 31 2d 11 f0 	movl   $0xf0112d31,-0x3c(%ebp)
f0105480:	c7 45 bc 30 2d 11 f0 	movl   $0xf0112d30,-0x44(%ebp)
f0105487:	c7 45 c0 98 89 10 f0 	movl   $0xf0108998,-0x40(%ebp)
f010548e:	e9 ba 00 00 00       	jmp    f010554d <debuginfo_eip+0x11b>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if ( user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U) < 0 ) {
f0105493:	e8 16 11 00 00       	call   f01065ae <cpunum>
f0105498:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010549f:	00 
f01054a0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f01054a7:	00 
f01054a8:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f01054af:	00 
f01054b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01054b3:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f01054b9:	89 04 24             	mov    %eax,(%esp)
f01054bc:	e8 fe be ff ff       	call   f01013bf <user_mem_check>
f01054c1:	85 c0                	test   %eax,%eax
f01054c3:	0f 88 fd 01 00 00    	js     f01056c6 <debuginfo_eip+0x294>
			return -1;
		}

		stabs = usd->stabs;
f01054c9:	b8 00 00 20 00       	mov    $0x200000,%eax
f01054ce:	8b 10                	mov    (%eax),%edx
f01054d0:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stab_end = usd->stab_end;
f01054d3:	8b 48 04             	mov    0x4(%eax),%ecx
f01054d6:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stabstr = usd->stabstr;
f01054d9:	8b 50 08             	mov    0x8(%eax),%edx
f01054dc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f01054df:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.

		if ( user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U) < 0 ) {
f01054e2:	e8 c7 10 00 00       	call   f01065ae <cpunum>
f01054e7:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01054ee:	00 
f01054ef:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
f01054f6:	00 
f01054f7:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01054fa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01054fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0105501:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f0105507:	89 04 24             	mov    %eax,(%esp)
f010550a:	e8 b0 be ff ff       	call   f01013bf <user_mem_check>
f010550f:	85 c0                	test   %eax,%eax
f0105511:	0f 88 af 01 00 00    	js     f01056c6 <debuginfo_eip+0x294>
			return -1;
		}

		if ( user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0 ) {
f0105517:	e8 92 10 00 00       	call   f01065ae <cpunum>
f010551c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105523:	00 
f0105524:	89 fa                	mov    %edi,%edx
f0105526:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0105529:	89 54 24 08          	mov    %edx,0x8(%esp)
f010552d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105530:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105534:	6b c0 74             	imul   $0x74,%eax,%eax
f0105537:	8b 80 28 30 23 f0    	mov    -0xfdccfd8(%eax),%eax
f010553d:	89 04 24             	mov    %eax,(%esp)
f0105540:	e8 7a be ff ff       	call   f01013bf <user_mem_check>
f0105545:	85 c0                	test   %eax,%eax
f0105547:	0f 88 79 01 00 00    	js     f01056c6 <debuginfo_eip+0x294>
			return -1;
		}
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010554d:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0105550:	0f 83 70 01 00 00    	jae    f01056c6 <debuginfo_eip+0x294>
f0105556:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010555a:	0f 85 66 01 00 00    	jne    f01056c6 <debuginfo_eip+0x294>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105560:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105567:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010556a:	2b 45 c0             	sub    -0x40(%ebp),%eax
f010556d:	c1 f8 02             	sar    $0x2,%eax
f0105570:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105576:	83 e8 01             	sub    $0x1,%eax
f0105579:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010557c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010557f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105582:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105586:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f010558d:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105590:	e8 9b fd ff ff       	call   f0105330 <stab_binsearch>
	if (lfile == 0)
f0105595:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105598:	85 c0                	test   %eax,%eax
f010559a:	0f 84 26 01 00 00    	je     f01056c6 <debuginfo_eip+0x294>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01055a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01055a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01055a9:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01055ac:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01055af:	89 74 24 04          	mov    %esi,0x4(%esp)
f01055b3:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01055ba:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01055bd:	e8 6e fd ff ff       	call   f0105330 <stab_binsearch>

	if (lfun <= rfun) {
f01055c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01055c5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01055c8:	7f 35                	jg     f01055ff <debuginfo_eip+0x1cd>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01055ca:	6b c0 0c             	imul   $0xc,%eax,%eax
f01055cd:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01055d0:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01055d3:	89 fa                	mov    %edi,%edx
f01055d5:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f01055d8:	39 d0                	cmp    %edx,%eax
f01055da:	73 06                	jae    f01055e2 <debuginfo_eip+0x1b0>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01055dc:	03 45 c4             	add    -0x3c(%ebp),%eax
f01055df:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01055e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01055e5:	6b c2 0c             	imul   $0xc,%edx,%eax
f01055e8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01055eb:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f01055ef:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01055f2:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01055f4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f01055f7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01055fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01055fd:	eb 0f                	jmp    f010560e <debuginfo_eip+0x1dc>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01055ff:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105605:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105608:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010560b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010560e:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105615:	00 
f0105616:	8b 43 08             	mov    0x8(%ebx),%eax
f0105619:	89 04 24             	mov    %eax,(%esp)
f010561c:	e8 f3 08 00 00       	call   f0105f14 <strfind>
f0105621:	2b 43 08             	sub    0x8(%ebx),%eax
f0105624:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs,&lline,&rline,N_SLINE,addr);
f0105627:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010562a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010562d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105631:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105638:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010563b:	e8 f0 fc ff ff       	call   f0105330 <stab_binsearch>
	info->eip_line=stabs[lline].n_desc;
f0105640:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105643:	6b d0 0c             	imul   $0xc,%eax,%edx
f0105646:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0105649:	0f b7 54 32 06       	movzwl 0x6(%edx,%esi,1),%edx
f010564e:	89 53 04             	mov    %edx,0x4(%ebx)
	if (lline>rline) {
f0105651:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105654:	7e 07                	jle    f010565d <debuginfo_eip+0x22b>
		info->eip_line=-1;
f0105656:	c7 43 04 ff ff ff ff 	movl   $0xffffffff,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f010565d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0105660:	89 75 bc             	mov    %esi,-0x44(%ebp)
f0105663:	eb 06                	jmp    f010566b <debuginfo_eip+0x239>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105665:	83 e8 01             	sub    $0x1,%eax
f0105668:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f010566b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010566e:	3b 45 bc             	cmp    -0x44(%ebp),%eax
f0105671:	7c 24                	jl     f0105697 <debuginfo_eip+0x265>
	       && stabs[lline].n_type != N_SOL
f0105673:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105676:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0105679:	8d 0c 96             	lea    (%esi,%edx,4),%ecx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010567c:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105680:	80 fa 84             	cmp    $0x84,%dl
f0105683:	74 5a                	je     f01056df <debuginfo_eip+0x2ad>
f0105685:	80 fa 64             	cmp    $0x64,%dl
f0105688:	75 db                	jne    f0105665 <debuginfo_eip+0x233>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010568a:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f010568e:	74 d5                	je     f0105665 <debuginfo_eip+0x233>
f0105690:	eb 4d                	jmp    f01056df <debuginfo_eip+0x2ad>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105692:	03 45 c4             	add    -0x3c(%ebp),%eax
f0105695:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105697:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010569a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010569d:	7d 2e                	jge    f01056cd <debuginfo_eip+0x29b>
		for (lline = lfun + 1;
f010569f:	83 c0 01             	add    $0x1,%eax
f01056a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01056a5:	eb 08                	jmp    f01056af <debuginfo_eip+0x27d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01056a7:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01056ab:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01056af:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01056b2:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01056b5:	7d 16                	jge    f01056cd <debuginfo_eip+0x29b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01056b7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01056ba:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01056bd:	80 7c 82 04 a0       	cmpb   $0xa0,0x4(%edx,%eax,4)
f01056c2:	74 e3                	je     f01056a7 <debuginfo_eip+0x275>
f01056c4:	eb 07                	jmp    f01056cd <debuginfo_eip+0x29b>
f01056c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01056cb:	eb 05                	jmp    f01056d2 <debuginfo_eip+0x2a0>
f01056cd:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f01056d2:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01056d5:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01056d8:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01056db:	89 ec                	mov    %ebp,%esp
f01056dd:	5d                   	pop    %ebp
f01056de:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01056df:	6b c0 0c             	imul   $0xc,%eax,%eax
f01056e2:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01056e5:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f01056e8:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f01056eb:	39 f8                	cmp    %edi,%eax
f01056ed:	72 a3                	jb     f0105692 <debuginfo_eip+0x260>
f01056ef:	eb a6                	jmp    f0105697 <debuginfo_eip+0x265>
	...

f0105700 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105700:	55                   	push   %ebp
f0105701:	89 e5                	mov    %esp,%ebp
f0105703:	57                   	push   %edi
f0105704:	56                   	push   %esi
f0105705:	53                   	push   %ebx
f0105706:	83 ec 4c             	sub    $0x4c,%esp
f0105709:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010570c:	89 d6                	mov    %edx,%esi
f010570e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105711:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105714:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105717:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010571a:	8b 45 10             	mov    0x10(%ebp),%eax
f010571d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105720:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105723:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105726:	b9 00 00 00 00       	mov    $0x0,%ecx
f010572b:	39 d1                	cmp    %edx,%ecx
f010572d:	72 07                	jb     f0105736 <printnum+0x36>
f010572f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105732:	39 d0                	cmp    %edx,%eax
f0105734:	77 69                	ja     f010579f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105736:	89 7c 24 10          	mov    %edi,0x10(%esp)
f010573a:	83 eb 01             	sub    $0x1,%ebx
f010573d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105741:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105745:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105749:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010574d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0105750:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0105753:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105756:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010575a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105761:	00 
f0105762:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105765:	89 04 24             	mov    %eax,(%esp)
f0105768:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010576b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010576f:	e8 bc 12 00 00       	call   f0106a30 <__udivdi3>
f0105774:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105777:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010577a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010577e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105782:	89 04 24             	mov    %eax,(%esp)
f0105785:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105789:	89 f2                	mov    %esi,%edx
f010578b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010578e:	e8 6d ff ff ff       	call   f0105700 <printnum>
f0105793:	eb 11                	jmp    f01057a6 <printnum+0xa6>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105795:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105799:	89 3c 24             	mov    %edi,(%esp)
f010579c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010579f:	83 eb 01             	sub    $0x1,%ebx
f01057a2:	85 db                	test   %ebx,%ebx
f01057a4:	7f ef                	jg     f0105795 <printnum+0x95>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01057a6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057aa:	8b 74 24 04          	mov    0x4(%esp),%esi
f01057ae:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01057b1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01057b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01057bc:	00 
f01057bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01057c0:	89 14 24             	mov    %edx,(%esp)
f01057c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01057c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01057ca:	e8 91 13 00 00       	call   f0106b60 <__umoddi3>
f01057cf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01057d3:	0f be 80 ba 84 10 f0 	movsbl -0xfef7b46(%eax),%eax
f01057da:	89 04 24             	mov    %eax,(%esp)
f01057dd:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01057e0:	83 c4 4c             	add    $0x4c,%esp
f01057e3:	5b                   	pop    %ebx
f01057e4:	5e                   	pop    %esi
f01057e5:	5f                   	pop    %edi
f01057e6:	5d                   	pop    %ebp
f01057e7:	c3                   	ret    

f01057e8 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01057e8:	55                   	push   %ebp
f01057e9:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01057eb:	83 fa 01             	cmp    $0x1,%edx
f01057ee:	7e 0e                	jle    f01057fe <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01057f0:	8b 10                	mov    (%eax),%edx
f01057f2:	8d 4a 08             	lea    0x8(%edx),%ecx
f01057f5:	89 08                	mov    %ecx,(%eax)
f01057f7:	8b 02                	mov    (%edx),%eax
f01057f9:	8b 52 04             	mov    0x4(%edx),%edx
f01057fc:	eb 22                	jmp    f0105820 <getuint+0x38>
	else if (lflag)
f01057fe:	85 d2                	test   %edx,%edx
f0105800:	74 10                	je     f0105812 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105802:	8b 10                	mov    (%eax),%edx
f0105804:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105807:	89 08                	mov    %ecx,(%eax)
f0105809:	8b 02                	mov    (%edx),%eax
f010580b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105810:	eb 0e                	jmp    f0105820 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105812:	8b 10                	mov    (%eax),%edx
f0105814:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105817:	89 08                	mov    %ecx,(%eax)
f0105819:	8b 02                	mov    (%edx),%eax
f010581b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105820:	5d                   	pop    %ebp
f0105821:	c3                   	ret    

f0105822 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105822:	55                   	push   %ebp
f0105823:	89 e5                	mov    %esp,%ebp
f0105825:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105828:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010582c:	8b 10                	mov    (%eax),%edx
f010582e:	3b 50 04             	cmp    0x4(%eax),%edx
f0105831:	73 0a                	jae    f010583d <sprintputch+0x1b>
		*b->buf++ = ch;
f0105833:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105836:	88 0a                	mov    %cl,(%edx)
f0105838:	83 c2 01             	add    $0x1,%edx
f010583b:	89 10                	mov    %edx,(%eax)
}
f010583d:	5d                   	pop    %ebp
f010583e:	c3                   	ret    

f010583f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010583f:	55                   	push   %ebp
f0105840:	89 e5                	mov    %esp,%ebp
f0105842:	57                   	push   %edi
f0105843:	56                   	push   %esi
f0105844:	53                   	push   %ebx
f0105845:	83 ec 4c             	sub    $0x4c,%esp
f0105848:	8b 7d 08             	mov    0x8(%ebp),%edi
f010584b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010584e:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0105851:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0105858:	eb 11                	jmp    f010586b <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010585a:	85 c0                	test   %eax,%eax
f010585c:	0f 84 b0 03 00 00    	je     f0105c12 <vprintfmt+0x3d3>
				return;
			putch(ch, putdat);
f0105862:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105866:	89 04 24             	mov    %eax,(%esp)
f0105869:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f010586b:	0f b6 03             	movzbl (%ebx),%eax
f010586e:	83 c3 01             	add    $0x1,%ebx
f0105871:	83 f8 25             	cmp    $0x25,%eax
f0105874:	75 e4                	jne    f010585a <vprintfmt+0x1b>
f0105876:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f010587d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105882:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f0105886:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f010588d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0105894:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0105897:	eb 06                	jmp    f010589f <vprintfmt+0x60>
f0105899:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f010589d:	89 d3                	mov    %edx,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010589f:	0f b6 0b             	movzbl (%ebx),%ecx
f01058a2:	0f b6 c1             	movzbl %cl,%eax
f01058a5:	8d 53 01             	lea    0x1(%ebx),%edx
f01058a8:	83 e9 23             	sub    $0x23,%ecx
f01058ab:	80 f9 55             	cmp    $0x55,%cl
f01058ae:	0f 87 41 03 00 00    	ja     f0105bf5 <vprintfmt+0x3b6>
f01058b4:	0f b6 c9             	movzbl %cl,%ecx
f01058b7:	ff 24 8d 80 85 10 f0 	jmp    *-0xfef7a80(,%ecx,4)
f01058be:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
f01058c2:	eb d9                	jmp    f010589d <vprintfmt+0x5e>
f01058c4:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f01058cb:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01058d0:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f01058d3:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f01058d7:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
f01058da:	8d 58 d0             	lea    -0x30(%eax),%ebx
f01058dd:	83 fb 09             	cmp    $0x9,%ebx
f01058e0:	77 2b                	ja     f010590d <vprintfmt+0xce>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01058e2:	83 c2 01             	add    $0x1,%edx
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01058e5:	eb e9                	jmp    f01058d0 <vprintfmt+0x91>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01058e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01058ea:	8d 48 04             	lea    0x4(%eax),%ecx
f01058ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
f01058f0:	8b 00                	mov    (%eax),%eax
f01058f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			goto process_precision;
f01058f5:	eb 19                	jmp    f0105910 <vprintfmt+0xd1>

		case '.':
			if (width < 0)
f01058f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058fa:	c1 f8 1f             	sar    $0x1f,%eax
f01058fd:	f7 d0                	not    %eax
f01058ff:	21 45 e4             	and    %eax,-0x1c(%ebp)
f0105902:	eb 99                	jmp    f010589d <vprintfmt+0x5e>
f0105904:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f010590b:	eb 90                	jmp    f010589d <vprintfmt+0x5e>
f010590d:	89 4d cc             	mov    %ecx,-0x34(%ebp)

		process_precision:
			if (width < 0)
f0105910:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105914:	79 87                	jns    f010589d <vprintfmt+0x5e>
f0105916:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105919:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010591c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010591f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105922:	e9 76 ff ff ff       	jmp    f010589d <vprintfmt+0x5e>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105927:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			goto reswitch;
f010592b:	e9 6d ff ff ff       	jmp    f010589d <vprintfmt+0x5e>
f0105930:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105933:	8b 45 14             	mov    0x14(%ebp),%eax
f0105936:	8d 50 04             	lea    0x4(%eax),%edx
f0105939:	89 55 14             	mov    %edx,0x14(%ebp)
f010593c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105940:	8b 00                	mov    (%eax),%eax
f0105942:	89 04 24             	mov    %eax,(%esp)
f0105945:	ff d7                	call   *%edi
f0105947:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f010594a:	e9 1c ff ff ff       	jmp    f010586b <vprintfmt+0x2c>
f010594f:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105952:	8b 45 14             	mov    0x14(%ebp),%eax
f0105955:	8d 50 04             	lea    0x4(%eax),%edx
f0105958:	89 55 14             	mov    %edx,0x14(%ebp)
f010595b:	8b 00                	mov    (%eax),%eax
f010595d:	89 c2                	mov    %eax,%edx
f010595f:	c1 fa 1f             	sar    $0x1f,%edx
f0105962:	31 d0                	xor    %edx,%eax
f0105964:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105966:	83 f8 09             	cmp    $0x9,%eax
f0105969:	7f 0b                	jg     f0105976 <vprintfmt+0x137>
f010596b:	8b 14 85 e0 86 10 f0 	mov    -0xfef7920(,%eax,4),%edx
f0105972:	85 d2                	test   %edx,%edx
f0105974:	75 20                	jne    f0105996 <vprintfmt+0x157>
				printfmt(putch, putdat, "error %d", err);
f0105976:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010597a:	c7 44 24 08 cb 84 10 	movl   $0xf01084cb,0x8(%esp)
f0105981:	f0 
f0105982:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105986:	89 3c 24             	mov    %edi,(%esp)
f0105989:	e8 0c 03 00 00       	call   f0105c9a <printfmt>
f010598e:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105991:	e9 d5 fe ff ff       	jmp    f010586b <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0105996:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010599a:	c7 44 24 08 57 7c 10 	movl   $0xf0107c57,0x8(%esp)
f01059a1:	f0 
f01059a2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01059a6:	89 3c 24             	mov    %edi,(%esp)
f01059a9:	e8 ec 02 00 00       	call   f0105c9a <printfmt>
f01059ae:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01059b1:	e9 b5 fe ff ff       	jmp    f010586b <vprintfmt+0x2c>
f01059b6:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01059b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01059bf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01059c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01059c5:	8d 50 04             	lea    0x4(%eax),%edx
f01059c8:	89 55 14             	mov    %edx,0x14(%ebp)
f01059cb:	8b 18                	mov    (%eax),%ebx
f01059cd:	85 db                	test   %ebx,%ebx
f01059cf:	75 05                	jne    f01059d6 <vprintfmt+0x197>
f01059d1:	bb d4 84 10 f0       	mov    $0xf01084d4,%ebx
				p = "(null)";
			if (width > 0 && padc != '-')
f01059d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01059da:	7e 76                	jle    f0105a52 <vprintfmt+0x213>
f01059dc:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f01059e0:	74 7a                	je     f0105a5c <vprintfmt+0x21d>
				for (width -= strnlen(p, precision); width > 0; width--)
f01059e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01059e6:	89 1c 24             	mov    %ebx,(%esp)
f01059e9:	e8 da 03 00 00       	call   f0105dc8 <strnlen>
f01059ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01059f1:	29 c2                	sub    %eax,%edx
					putch(padc, putdat);
f01059f3:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f01059f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01059fa:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01059fd:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01059ff:	eb 0f                	jmp    f0105a10 <vprintfmt+0x1d1>
					putch(padc, putdat);
f0105a01:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a05:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a08:	89 04 24             	mov    %eax,(%esp)
f0105a0b:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105a0d:	83 eb 01             	sub    $0x1,%ebx
f0105a10:	85 db                	test   %ebx,%ebx
f0105a12:	7f ed                	jg     f0105a01 <vprintfmt+0x1c2>
f0105a14:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0105a17:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105a1a:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0105a1d:	89 f7                	mov    %esi,%edi
f0105a1f:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0105a22:	eb 40                	jmp    f0105a64 <vprintfmt+0x225>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105a24:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105a28:	74 18                	je     f0105a42 <vprintfmt+0x203>
f0105a2a:	8d 50 e0             	lea    -0x20(%eax),%edx
f0105a2d:	83 fa 5e             	cmp    $0x5e,%edx
f0105a30:	76 10                	jbe    f0105a42 <vprintfmt+0x203>
					putch('?', putdat);
f0105a32:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a36:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0105a3d:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105a40:	eb 0a                	jmp    f0105a4c <vprintfmt+0x20d>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0105a42:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a46:	89 04 24             	mov    %eax,(%esp)
f0105a49:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105a4c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0105a50:	eb 12                	jmp    f0105a64 <vprintfmt+0x225>
f0105a52:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0105a55:	89 f7                	mov    %esi,%edi
f0105a57:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0105a5a:	eb 08                	jmp    f0105a64 <vprintfmt+0x225>
f0105a5c:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0105a5f:	89 f7                	mov    %esi,%edi
f0105a61:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0105a64:	0f be 03             	movsbl (%ebx),%eax
f0105a67:	83 c3 01             	add    $0x1,%ebx
f0105a6a:	85 c0                	test   %eax,%eax
f0105a6c:	74 25                	je     f0105a93 <vprintfmt+0x254>
f0105a6e:	85 f6                	test   %esi,%esi
f0105a70:	78 b2                	js     f0105a24 <vprintfmt+0x1e5>
f0105a72:	83 ee 01             	sub    $0x1,%esi
f0105a75:	79 ad                	jns    f0105a24 <vprintfmt+0x1e5>
f0105a77:	89 fe                	mov    %edi,%esi
f0105a79:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105a7c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105a7f:	eb 1a                	jmp    f0105a9b <vprintfmt+0x25c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105a81:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105a85:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105a8c:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105a8e:	83 eb 01             	sub    $0x1,%ebx
f0105a91:	eb 08                	jmp    f0105a9b <vprintfmt+0x25c>
f0105a93:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105a96:	89 fe                	mov    %edi,%esi
f0105a98:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105a9b:	85 db                	test   %ebx,%ebx
f0105a9d:	7f e2                	jg     f0105a81 <vprintfmt+0x242>
f0105a9f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105aa2:	e9 c4 fd ff ff       	jmp    f010586b <vprintfmt+0x2c>
f0105aa7:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105aaa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105aad:	83 f9 01             	cmp    $0x1,%ecx
f0105ab0:	7e 16                	jle    f0105ac8 <vprintfmt+0x289>
		return va_arg(*ap, long long);
f0105ab2:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ab5:	8d 50 08             	lea    0x8(%eax),%edx
f0105ab8:	89 55 14             	mov    %edx,0x14(%ebp)
f0105abb:	8b 10                	mov    (%eax),%edx
f0105abd:	8b 48 04             	mov    0x4(%eax),%ecx
f0105ac0:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0105ac3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105ac6:	eb 32                	jmp    f0105afa <vprintfmt+0x2bb>
	else if (lflag)
f0105ac8:	85 c9                	test   %ecx,%ecx
f0105aca:	74 18                	je     f0105ae4 <vprintfmt+0x2a5>
		return va_arg(*ap, long);
f0105acc:	8b 45 14             	mov    0x14(%ebp),%eax
f0105acf:	8d 50 04             	lea    0x4(%eax),%edx
f0105ad2:	89 55 14             	mov    %edx,0x14(%ebp)
f0105ad5:	8b 00                	mov    (%eax),%eax
f0105ad7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105ada:	89 c1                	mov    %eax,%ecx
f0105adc:	c1 f9 1f             	sar    $0x1f,%ecx
f0105adf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105ae2:	eb 16                	jmp    f0105afa <vprintfmt+0x2bb>
	else
		return va_arg(*ap, int);
f0105ae4:	8b 45 14             	mov    0x14(%ebp),%eax
f0105ae7:	8d 50 04             	lea    0x4(%eax),%edx
f0105aea:	89 55 14             	mov    %edx,0x14(%ebp)
f0105aed:	8b 00                	mov    (%eax),%eax
f0105aef:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105af2:	89 c2                	mov    %eax,%edx
f0105af4:	c1 fa 1f             	sar    $0x1f,%edx
f0105af7:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0105afa:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105afd:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105b00:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0105b05:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105b09:	0f 89 a7 00 00 00    	jns    f0105bb6 <vprintfmt+0x377>
				putch('-', putdat);
f0105b0f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b13:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105b1a:	ff d7                	call   *%edi
				num = -(long long) num;
f0105b1c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105b1f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105b22:	f7 d9                	neg    %ecx
f0105b24:	83 d3 00             	adc    $0x0,%ebx
f0105b27:	f7 db                	neg    %ebx
f0105b29:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105b2e:	e9 83 00 00 00       	jmp    f0105bb6 <vprintfmt+0x377>
f0105b33:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105b36:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105b39:	89 ca                	mov    %ecx,%edx
f0105b3b:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b3e:	e8 a5 fc ff ff       	call   f01057e8 <getuint>
f0105b43:	89 c1                	mov    %eax,%ecx
f0105b45:	89 d3                	mov    %edx,%ebx
f0105b47:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0105b4c:	eb 68                	jmp    f0105bb6 <vprintfmt+0x377>
f0105b4e:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105b51:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0105b54:	89 ca                	mov    %ecx,%edx
f0105b56:	8d 45 14             	lea    0x14(%ebp),%eax
f0105b59:	e8 8a fc ff ff       	call   f01057e8 <getuint>
f0105b5e:	89 c1                	mov    %eax,%ecx
f0105b60:	89 d3                	mov    %edx,%ebx
f0105b62:	b8 08 00 00 00       	mov    $0x8,%eax
			base = 8;
			goto number;
f0105b67:	eb 4d                	jmp    f0105bb6 <vprintfmt+0x377>
f0105b69:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0105b6c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b70:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105b77:	ff d7                	call   *%edi
			putch('x', putdat);
f0105b79:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105b7d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105b84:	ff d7                	call   *%edi
			num = (unsigned long long)
f0105b86:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b89:	8d 50 04             	lea    0x4(%eax),%edx
f0105b8c:	89 55 14             	mov    %edx,0x14(%ebp)
f0105b8f:	8b 08                	mov    (%eax),%ecx
f0105b91:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105b96:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105b9b:	eb 19                	jmp    f0105bb6 <vprintfmt+0x377>
f0105b9d:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0105ba0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105ba3:	89 ca                	mov    %ecx,%edx
f0105ba5:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ba8:	e8 3b fc ff ff       	call   f01057e8 <getuint>
f0105bad:	89 c1                	mov    %eax,%ecx
f0105baf:	89 d3                	mov    %edx,%ebx
f0105bb1:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105bb6:	0f be 55 e0          	movsbl -0x20(%ebp),%edx
f0105bba:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105bbe:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105bc1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105bc5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105bc9:	89 0c 24             	mov    %ecx,(%esp)
f0105bcc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105bd0:	89 f2                	mov    %esi,%edx
f0105bd2:	89 f8                	mov    %edi,%eax
f0105bd4:	e8 27 fb ff ff       	call   f0105700 <printnum>
f0105bd9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0105bdc:	e9 8a fc ff ff       	jmp    f010586b <vprintfmt+0x2c>
f0105be1:	89 55 d0             	mov    %edx,-0x30(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105be4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105be8:	89 04 24             	mov    %eax,(%esp)
f0105beb:	ff d7                	call   *%edi
f0105bed:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0105bf0:	e9 76 fc ff ff       	jmp    f010586b <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105bf5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105bf9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105c00:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105c02:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105c05:	80 38 25             	cmpb   $0x25,(%eax)
f0105c08:	0f 84 5d fc ff ff    	je     f010586b <vprintfmt+0x2c>
f0105c0e:	89 c3                	mov    %eax,%ebx
f0105c10:	eb f0                	jmp    f0105c02 <vprintfmt+0x3c3>
				/* do nothing */;
			break;
		}
	}
}
f0105c12:	83 c4 4c             	add    $0x4c,%esp
f0105c15:	5b                   	pop    %ebx
f0105c16:	5e                   	pop    %esi
f0105c17:	5f                   	pop    %edi
f0105c18:	5d                   	pop    %ebp
f0105c19:	c3                   	ret    

f0105c1a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105c1a:	55                   	push   %ebp
f0105c1b:	89 e5                	mov    %esp,%ebp
f0105c1d:	83 ec 28             	sub    $0x28,%esp
f0105c20:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c23:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0105c26:	85 c0                	test   %eax,%eax
f0105c28:	74 04                	je     f0105c2e <vsnprintf+0x14>
f0105c2a:	85 d2                	test   %edx,%edx
f0105c2c:	7f 07                	jg     f0105c35 <vsnprintf+0x1b>
f0105c2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105c33:	eb 3b                	jmp    f0105c70 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105c35:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105c38:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0105c3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105c3f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105c46:	8b 45 14             	mov    0x14(%ebp),%eax
f0105c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c4d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c50:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c54:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105c57:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c5b:	c7 04 24 22 58 10 f0 	movl   $0xf0105822,(%esp)
f0105c62:	e8 d8 fb ff ff       	call   f010583f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105c67:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105c6a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105c6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0105c70:	c9                   	leave  
f0105c71:	c3                   	ret    

f0105c72 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105c72:	55                   	push   %ebp
f0105c73:	89 e5                	mov    %esp,%ebp
f0105c75:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0105c78:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0105c7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c7f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105c82:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105c86:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c89:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c8d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c90:	89 04 24             	mov    %eax,(%esp)
f0105c93:	e8 82 ff ff ff       	call   f0105c1a <vsnprintf>
	va_end(ap);

	return rc;
}
f0105c98:	c9                   	leave  
f0105c99:	c3                   	ret    

f0105c9a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105c9a:	55                   	push   %ebp
f0105c9b:	89 e5                	mov    %esp,%ebp
f0105c9d:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0105ca0:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0105ca3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ca7:	8b 45 10             	mov    0x10(%ebp),%eax
f0105caa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105cae:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105cb5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cb8:	89 04 24             	mov    %eax,(%esp)
f0105cbb:	e8 7f fb ff ff       	call   f010583f <vprintfmt>
	va_end(ap);
}
f0105cc0:	c9                   	leave  
f0105cc1:	c3                   	ret    
	...

f0105cd0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105cd0:	55                   	push   %ebp
f0105cd1:	89 e5                	mov    %esp,%ebp
f0105cd3:	57                   	push   %edi
f0105cd4:	56                   	push   %esi
f0105cd5:	53                   	push   %ebx
f0105cd6:	83 ec 1c             	sub    $0x1c,%esp
f0105cd9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105cdc:	85 c0                	test   %eax,%eax
f0105cde:	74 10                	je     f0105cf0 <readline+0x20>
		cprintf("%s", prompt);
f0105ce0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ce4:	c7 04 24 57 7c 10 f0 	movl   $0xf0107c57,(%esp)
f0105ceb:	e8 2f e5 ff ff       	call   f010421f <cprintf>

	i = 0;
	echoing = iscons(0);
f0105cf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105cf7:	e8 ba a6 ff ff       	call   f01003b6 <iscons>
f0105cfc:	89 c7                	mov    %eax,%edi
f0105cfe:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105d03:	e8 9d a6 ff ff       	call   f01003a5 <getchar>
f0105d08:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105d0a:	85 c0                	test   %eax,%eax
f0105d0c:	79 17                	jns    f0105d25 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d12:	c7 04 24 08 87 10 f0 	movl   $0xf0108708,(%esp)
f0105d19:	e8 01 e5 ff ff       	call   f010421f <cprintf>
f0105d1e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0105d23:	eb 76                	jmp    f0105d9b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105d25:	83 f8 08             	cmp    $0x8,%eax
f0105d28:	74 08                	je     f0105d32 <readline+0x62>
f0105d2a:	83 f8 7f             	cmp    $0x7f,%eax
f0105d2d:	8d 76 00             	lea    0x0(%esi),%esi
f0105d30:	75 19                	jne    f0105d4b <readline+0x7b>
f0105d32:	85 f6                	test   %esi,%esi
f0105d34:	7e 15                	jle    f0105d4b <readline+0x7b>
			if (echoing)
f0105d36:	85 ff                	test   %edi,%edi
f0105d38:	74 0c                	je     f0105d46 <readline+0x76>
				cputchar('\b');
f0105d3a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105d41:	e8 6c a8 ff ff       	call   f01005b2 <cputchar>
			i--;
f0105d46:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105d49:	eb b8                	jmp    f0105d03 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105d4b:	83 fb 1f             	cmp    $0x1f,%ebx
f0105d4e:	66 90                	xchg   %ax,%ax
f0105d50:	7e 23                	jle    f0105d75 <readline+0xa5>
f0105d52:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105d58:	7f 1b                	jg     f0105d75 <readline+0xa5>
			if (echoing)
f0105d5a:	85 ff                	test   %edi,%edi
f0105d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105d60:	74 08                	je     f0105d6a <readline+0x9a>
				cputchar(c);
f0105d62:	89 1c 24             	mov    %ebx,(%esp)
f0105d65:	e8 48 a8 ff ff       	call   f01005b2 <cputchar>
			buf[i++] = c;
f0105d6a:	88 9e 80 2a 23 f0    	mov    %bl,-0xfdcd580(%esi)
f0105d70:	83 c6 01             	add    $0x1,%esi
f0105d73:	eb 8e                	jmp    f0105d03 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105d75:	83 fb 0a             	cmp    $0xa,%ebx
f0105d78:	74 05                	je     f0105d7f <readline+0xaf>
f0105d7a:	83 fb 0d             	cmp    $0xd,%ebx
f0105d7d:	75 84                	jne    f0105d03 <readline+0x33>
			if (echoing)
f0105d7f:	85 ff                	test   %edi,%edi
f0105d81:	74 0c                	je     f0105d8f <readline+0xbf>
				cputchar('\n');
f0105d83:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105d8a:	e8 23 a8 ff ff       	call   f01005b2 <cputchar>
			buf[i] = 0;
f0105d8f:	c6 86 80 2a 23 f0 00 	movb   $0x0,-0xfdcd580(%esi)
f0105d96:	b8 80 2a 23 f0       	mov    $0xf0232a80,%eax
			return buf;
		}
	}
}
f0105d9b:	83 c4 1c             	add    $0x1c,%esp
f0105d9e:	5b                   	pop    %ebx
f0105d9f:	5e                   	pop    %esi
f0105da0:	5f                   	pop    %edi
f0105da1:	5d                   	pop    %ebp
f0105da2:	c3                   	ret    
	...

f0105db0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105db0:	55                   	push   %ebp
f0105db1:	89 e5                	mov    %esp,%ebp
f0105db3:	8b 55 08             	mov    0x8(%ebp),%edx
f0105db6:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; *s != '\0'; s++)
f0105dbb:	eb 03                	jmp    f0105dc0 <strlen+0x10>
		n++;
f0105dbd:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105dc0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105dc4:	75 f7                	jne    f0105dbd <strlen+0xd>
		n++;
	return n;
}
f0105dc6:	5d                   	pop    %ebp
f0105dc7:	c3                   	ret    

f0105dc8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105dc8:	55                   	push   %ebp
f0105dc9:	89 e5                	mov    %esp,%ebp
f0105dcb:	53                   	push   %ebx
f0105dcc:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105dd2:	b8 00 00 00 00       	mov    $0x0,%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105dd7:	eb 03                	jmp    f0105ddc <strnlen+0x14>
		n++;
f0105dd9:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ddc:	39 c1                	cmp    %eax,%ecx
f0105dde:	74 06                	je     f0105de6 <strnlen+0x1e>
f0105de0:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0105de4:	75 f3                	jne    f0105dd9 <strnlen+0x11>
		n++;
	return n;
}
f0105de6:	5b                   	pop    %ebx
f0105de7:	5d                   	pop    %ebp
f0105de8:	c3                   	ret    

f0105de9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105de9:	55                   	push   %ebp
f0105dea:	89 e5                	mov    %esp,%ebp
f0105dec:	53                   	push   %ebx
f0105ded:	8b 45 08             	mov    0x8(%ebp),%eax
f0105df0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105df3:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105df8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105dfc:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105dff:	83 c2 01             	add    $0x1,%edx
f0105e02:	84 c9                	test   %cl,%cl
f0105e04:	75 f2                	jne    f0105df8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105e06:	5b                   	pop    %ebx
f0105e07:	5d                   	pop    %ebp
f0105e08:	c3                   	ret    

f0105e09 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105e09:	55                   	push   %ebp
f0105e0a:	89 e5                	mov    %esp,%ebp
f0105e0c:	53                   	push   %ebx
f0105e0d:	83 ec 08             	sub    $0x8,%esp
f0105e10:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105e13:	89 1c 24             	mov    %ebx,(%esp)
f0105e16:	e8 95 ff ff ff       	call   f0105db0 <strlen>
	strcpy(dst + len, src);
f0105e1b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105e1e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e22:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0105e25:	89 04 24             	mov    %eax,(%esp)
f0105e28:	e8 bc ff ff ff       	call   f0105de9 <strcpy>
	return dst;
}
f0105e2d:	89 d8                	mov    %ebx,%eax
f0105e2f:	83 c4 08             	add    $0x8,%esp
f0105e32:	5b                   	pop    %ebx
f0105e33:	5d                   	pop    %ebp
f0105e34:	c3                   	ret    

f0105e35 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105e35:	55                   	push   %ebp
f0105e36:	89 e5                	mov    %esp,%ebp
f0105e38:	56                   	push   %esi
f0105e39:	53                   	push   %ebx
f0105e3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105e40:	8b 75 10             	mov    0x10(%ebp),%esi
f0105e43:	ba 00 00 00 00       	mov    $0x0,%edx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105e48:	eb 0f                	jmp    f0105e59 <strncpy+0x24>
		*dst++ = *src;
f0105e4a:	0f b6 19             	movzbl (%ecx),%ebx
f0105e4d:	88 1c 10             	mov    %bl,(%eax,%edx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105e50:	80 39 01             	cmpb   $0x1,(%ecx)
f0105e53:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105e56:	83 c2 01             	add    $0x1,%edx
f0105e59:	39 f2                	cmp    %esi,%edx
f0105e5b:	72 ed                	jb     f0105e4a <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105e5d:	5b                   	pop    %ebx
f0105e5e:	5e                   	pop    %esi
f0105e5f:	5d                   	pop    %ebp
f0105e60:	c3                   	ret    

f0105e61 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105e61:	55                   	push   %ebp
f0105e62:	89 e5                	mov    %esp,%ebp
f0105e64:	56                   	push   %esi
f0105e65:	53                   	push   %ebx
f0105e66:	8b 75 08             	mov    0x8(%ebp),%esi
f0105e69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105e6c:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105e6f:	89 f0                	mov    %esi,%eax
f0105e71:	85 d2                	test   %edx,%edx
f0105e73:	75 0a                	jne    f0105e7f <strlcpy+0x1e>
f0105e75:	eb 17                	jmp    f0105e8e <strlcpy+0x2d>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105e77:	88 18                	mov    %bl,(%eax)
f0105e79:	83 c0 01             	add    $0x1,%eax
f0105e7c:	83 c1 01             	add    $0x1,%ecx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105e7f:	83 ea 01             	sub    $0x1,%edx
f0105e82:	74 07                	je     f0105e8b <strlcpy+0x2a>
f0105e84:	0f b6 19             	movzbl (%ecx),%ebx
f0105e87:	84 db                	test   %bl,%bl
f0105e89:	75 ec                	jne    f0105e77 <strlcpy+0x16>
			*dst++ = *src++;
		*dst = '\0';
f0105e8b:	c6 00 00             	movb   $0x0,(%eax)
f0105e8e:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0105e90:	5b                   	pop    %ebx
f0105e91:	5e                   	pop    %esi
f0105e92:	5d                   	pop    %ebp
f0105e93:	c3                   	ret    

f0105e94 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105e94:	55                   	push   %ebp
f0105e95:	89 e5                	mov    %esp,%ebp
f0105e97:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105e9a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105e9d:	eb 06                	jmp    f0105ea5 <strcmp+0x11>
		p++, q++;
f0105e9f:	83 c1 01             	add    $0x1,%ecx
f0105ea2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105ea5:	0f b6 01             	movzbl (%ecx),%eax
f0105ea8:	84 c0                	test   %al,%al
f0105eaa:	74 04                	je     f0105eb0 <strcmp+0x1c>
f0105eac:	3a 02                	cmp    (%edx),%al
f0105eae:	74 ef                	je     f0105e9f <strcmp+0xb>
f0105eb0:	0f b6 c0             	movzbl %al,%eax
f0105eb3:	0f b6 12             	movzbl (%edx),%edx
f0105eb6:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105eb8:	5d                   	pop    %ebp
f0105eb9:	c3                   	ret    

f0105eba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105eba:	55                   	push   %ebp
f0105ebb:	89 e5                	mov    %esp,%ebp
f0105ebd:	53                   	push   %ebx
f0105ebe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ec1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105ec4:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0105ec7:	eb 09                	jmp    f0105ed2 <strncmp+0x18>
		n--, p++, q++;
f0105ec9:	83 ea 01             	sub    $0x1,%edx
f0105ecc:	83 c0 01             	add    $0x1,%eax
f0105ecf:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105ed2:	85 d2                	test   %edx,%edx
f0105ed4:	75 07                	jne    f0105edd <strncmp+0x23>
f0105ed6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105edb:	eb 13                	jmp    f0105ef0 <strncmp+0x36>
f0105edd:	0f b6 18             	movzbl (%eax),%ebx
f0105ee0:	84 db                	test   %bl,%bl
f0105ee2:	74 04                	je     f0105ee8 <strncmp+0x2e>
f0105ee4:	3a 19                	cmp    (%ecx),%bl
f0105ee6:	74 e1                	je     f0105ec9 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ee8:	0f b6 00             	movzbl (%eax),%eax
f0105eeb:	0f b6 11             	movzbl (%ecx),%edx
f0105eee:	29 d0                	sub    %edx,%eax
}
f0105ef0:	5b                   	pop    %ebx
f0105ef1:	5d                   	pop    %ebp
f0105ef2:	c3                   	ret    

f0105ef3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105ef3:	55                   	push   %ebp
f0105ef4:	89 e5                	mov    %esp,%ebp
f0105ef6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ef9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105efd:	eb 07                	jmp    f0105f06 <strchr+0x13>
		if (*s == c)
f0105eff:	38 ca                	cmp    %cl,%dl
f0105f01:	74 0f                	je     f0105f12 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105f03:	83 c0 01             	add    $0x1,%eax
f0105f06:	0f b6 10             	movzbl (%eax),%edx
f0105f09:	84 d2                	test   %dl,%dl
f0105f0b:	75 f2                	jne    f0105eff <strchr+0xc>
f0105f0d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0105f12:	5d                   	pop    %ebp
f0105f13:	c3                   	ret    

f0105f14 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105f14:	55                   	push   %ebp
f0105f15:	89 e5                	mov    %esp,%ebp
f0105f17:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105f1e:	eb 07                	jmp    f0105f27 <strfind+0x13>
		if (*s == c)
f0105f20:	38 ca                	cmp    %cl,%dl
f0105f22:	74 0a                	je     f0105f2e <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105f24:	83 c0 01             	add    $0x1,%eax
f0105f27:	0f b6 10             	movzbl (%eax),%edx
f0105f2a:	84 d2                	test   %dl,%dl
f0105f2c:	75 f2                	jne    f0105f20 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0105f2e:	5d                   	pop    %ebp
f0105f2f:	90                   	nop
f0105f30:	c3                   	ret    

f0105f31 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105f31:	55                   	push   %ebp
f0105f32:	89 e5                	mov    %esp,%ebp
f0105f34:	83 ec 0c             	sub    $0xc,%esp
f0105f37:	89 1c 24             	mov    %ebx,(%esp)
f0105f3a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f3e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105f42:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105f45:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105f48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105f4b:	85 c9                	test   %ecx,%ecx
f0105f4d:	74 30                	je     f0105f7f <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105f4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105f55:	75 25                	jne    f0105f7c <memset+0x4b>
f0105f57:	f6 c1 03             	test   $0x3,%cl
f0105f5a:	75 20                	jne    f0105f7c <memset+0x4b>
		c &= 0xFF;
f0105f5c:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105f5f:	89 d3                	mov    %edx,%ebx
f0105f61:	c1 e3 08             	shl    $0x8,%ebx
f0105f64:	89 d6                	mov    %edx,%esi
f0105f66:	c1 e6 18             	shl    $0x18,%esi
f0105f69:	89 d0                	mov    %edx,%eax
f0105f6b:	c1 e0 10             	shl    $0x10,%eax
f0105f6e:	09 f0                	or     %esi,%eax
f0105f70:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0105f72:	09 d8                	or     %ebx,%eax
f0105f74:	c1 e9 02             	shr    $0x2,%ecx
f0105f77:	fc                   	cld    
f0105f78:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105f7a:	eb 03                	jmp    f0105f7f <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105f7c:	fc                   	cld    
f0105f7d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105f7f:	89 f8                	mov    %edi,%eax
f0105f81:	8b 1c 24             	mov    (%esp),%ebx
f0105f84:	8b 74 24 04          	mov    0x4(%esp),%esi
f0105f88:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0105f8c:	89 ec                	mov    %ebp,%esp
f0105f8e:	5d                   	pop    %ebp
f0105f8f:	c3                   	ret    

f0105f90 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105f90:	55                   	push   %ebp
f0105f91:	89 e5                	mov    %esp,%ebp
f0105f93:	83 ec 08             	sub    $0x8,%esp
f0105f96:	89 34 24             	mov    %esi,(%esp)
f0105f99:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105f9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105fa0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
f0105fa3:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0105fa6:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0105fa8:	39 c6                	cmp    %eax,%esi
f0105faa:	73 35                	jae    f0105fe1 <memmove+0x51>
f0105fac:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105faf:	39 d0                	cmp    %edx,%eax
f0105fb1:	73 2e                	jae    f0105fe1 <memmove+0x51>
		s += n;
		d += n;
f0105fb3:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105fb5:	f6 c2 03             	test   $0x3,%dl
f0105fb8:	75 1b                	jne    f0105fd5 <memmove+0x45>
f0105fba:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105fc0:	75 13                	jne    f0105fd5 <memmove+0x45>
f0105fc2:	f6 c1 03             	test   $0x3,%cl
f0105fc5:	75 0e                	jne    f0105fd5 <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0105fc7:	83 ef 04             	sub    $0x4,%edi
f0105fca:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105fcd:	c1 e9 02             	shr    $0x2,%ecx
f0105fd0:	fd                   	std    
f0105fd1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105fd3:	eb 09                	jmp    f0105fde <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105fd5:	83 ef 01             	sub    $0x1,%edi
f0105fd8:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105fdb:	fd                   	std    
f0105fdc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105fde:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105fdf:	eb 20                	jmp    f0106001 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105fe1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105fe7:	75 15                	jne    f0105ffe <memmove+0x6e>
f0105fe9:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105fef:	75 0d                	jne    f0105ffe <memmove+0x6e>
f0105ff1:	f6 c1 03             	test   $0x3,%cl
f0105ff4:	75 08                	jne    f0105ffe <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f0105ff6:	c1 e9 02             	shr    $0x2,%ecx
f0105ff9:	fc                   	cld    
f0105ffa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105ffc:	eb 03                	jmp    f0106001 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105ffe:	fc                   	cld    
f0105fff:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106001:	8b 34 24             	mov    (%esp),%esi
f0106004:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106008:	89 ec                	mov    %ebp,%esp
f010600a:	5d                   	pop    %ebp
f010600b:	c3                   	ret    

f010600c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010600c:	55                   	push   %ebp
f010600d:	89 e5                	mov    %esp,%ebp
f010600f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106012:	8b 45 10             	mov    0x10(%ebp),%eax
f0106015:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106019:	8b 45 0c             	mov    0xc(%ebp),%eax
f010601c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106020:	8b 45 08             	mov    0x8(%ebp),%eax
f0106023:	89 04 24             	mov    %eax,(%esp)
f0106026:	e8 65 ff ff ff       	call   f0105f90 <memmove>
}
f010602b:	c9                   	leave  
f010602c:	c3                   	ret    

f010602d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010602d:	55                   	push   %ebp
f010602e:	89 e5                	mov    %esp,%ebp
f0106030:	57                   	push   %edi
f0106031:	56                   	push   %esi
f0106032:	53                   	push   %ebx
f0106033:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106036:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106039:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010603c:	ba 00 00 00 00       	mov    $0x0,%edx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106041:	eb 1c                	jmp    f010605f <memcmp+0x32>
		if (*s1 != *s2)
f0106043:	0f b6 04 17          	movzbl (%edi,%edx,1),%eax
f0106047:	0f b6 1c 16          	movzbl (%esi,%edx,1),%ebx
f010604b:	83 c2 01             	add    $0x1,%edx
f010604e:	83 e9 01             	sub    $0x1,%ecx
f0106051:	38 d8                	cmp    %bl,%al
f0106053:	74 0a                	je     f010605f <memcmp+0x32>
			return (int) *s1 - (int) *s2;
f0106055:	0f b6 c0             	movzbl %al,%eax
f0106058:	0f b6 db             	movzbl %bl,%ebx
f010605b:	29 d8                	sub    %ebx,%eax
f010605d:	eb 09                	jmp    f0106068 <memcmp+0x3b>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010605f:	85 c9                	test   %ecx,%ecx
f0106061:	75 e0                	jne    f0106043 <memcmp+0x16>
f0106063:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0106068:	5b                   	pop    %ebx
f0106069:	5e                   	pop    %esi
f010606a:	5f                   	pop    %edi
f010606b:	5d                   	pop    %ebp
f010606c:	c3                   	ret    

f010606d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010606d:	55                   	push   %ebp
f010606e:	89 e5                	mov    %esp,%ebp
f0106070:	8b 45 08             	mov    0x8(%ebp),%eax
f0106073:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0106076:	89 c2                	mov    %eax,%edx
f0106078:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010607b:	eb 07                	jmp    f0106084 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f010607d:	38 08                	cmp    %cl,(%eax)
f010607f:	74 07                	je     f0106088 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106081:	83 c0 01             	add    $0x1,%eax
f0106084:	39 d0                	cmp    %edx,%eax
f0106086:	72 f5                	jb     f010607d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106088:	5d                   	pop    %ebp
f0106089:	c3                   	ret    

f010608a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010608a:	55                   	push   %ebp
f010608b:	89 e5                	mov    %esp,%ebp
f010608d:	57                   	push   %edi
f010608e:	56                   	push   %esi
f010608f:	53                   	push   %ebx
f0106090:	83 ec 04             	sub    $0x4,%esp
f0106093:	8b 55 08             	mov    0x8(%ebp),%edx
f0106096:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106099:	eb 03                	jmp    f010609e <strtol+0x14>
		s++;
f010609b:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010609e:	0f b6 02             	movzbl (%edx),%eax
f01060a1:	3c 20                	cmp    $0x20,%al
f01060a3:	74 f6                	je     f010609b <strtol+0x11>
f01060a5:	3c 09                	cmp    $0x9,%al
f01060a7:	74 f2                	je     f010609b <strtol+0x11>
		s++;

	// plus/minus sign
	if (*s == '+')
f01060a9:	3c 2b                	cmp    $0x2b,%al
f01060ab:	75 0c                	jne    f01060b9 <strtol+0x2f>
		s++;
f01060ad:	8d 52 01             	lea    0x1(%edx),%edx
f01060b0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01060b7:	eb 15                	jmp    f01060ce <strtol+0x44>
	else if (*s == '-')
f01060b9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01060c0:	3c 2d                	cmp    $0x2d,%al
f01060c2:	75 0a                	jne    f01060ce <strtol+0x44>
		s++, neg = 1;
f01060c4:	8d 52 01             	lea    0x1(%edx),%edx
f01060c7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01060ce:	85 db                	test   %ebx,%ebx
f01060d0:	0f 94 c0             	sete   %al
f01060d3:	74 05                	je     f01060da <strtol+0x50>
f01060d5:	83 fb 10             	cmp    $0x10,%ebx
f01060d8:	75 18                	jne    f01060f2 <strtol+0x68>
f01060da:	80 3a 30             	cmpb   $0x30,(%edx)
f01060dd:	75 13                	jne    f01060f2 <strtol+0x68>
f01060df:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01060e3:	75 0d                	jne    f01060f2 <strtol+0x68>
		s += 2, base = 16;
f01060e5:	83 c2 02             	add    $0x2,%edx
f01060e8:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01060ed:	8d 76 00             	lea    0x0(%esi),%esi
f01060f0:	eb 13                	jmp    f0106105 <strtol+0x7b>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01060f2:	84 c0                	test   %al,%al
f01060f4:	74 0f                	je     f0106105 <strtol+0x7b>
f01060f6:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01060fb:	80 3a 30             	cmpb   $0x30,(%edx)
f01060fe:	75 05                	jne    f0106105 <strtol+0x7b>
		s++, base = 8;
f0106100:	83 c2 01             	add    $0x1,%edx
f0106103:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106105:	b8 00 00 00 00       	mov    $0x0,%eax
f010610a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010610c:	0f b6 0a             	movzbl (%edx),%ecx
f010610f:	89 cf                	mov    %ecx,%edi
f0106111:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106114:	80 fb 09             	cmp    $0x9,%bl
f0106117:	77 08                	ja     f0106121 <strtol+0x97>
			dig = *s - '0';
f0106119:	0f be c9             	movsbl %cl,%ecx
f010611c:	83 e9 30             	sub    $0x30,%ecx
f010611f:	eb 1e                	jmp    f010613f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0106121:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0106124:	80 fb 19             	cmp    $0x19,%bl
f0106127:	77 08                	ja     f0106131 <strtol+0xa7>
			dig = *s - 'a' + 10;
f0106129:	0f be c9             	movsbl %cl,%ecx
f010612c:	83 e9 57             	sub    $0x57,%ecx
f010612f:	eb 0e                	jmp    f010613f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f0106131:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0106134:	80 fb 19             	cmp    $0x19,%bl
f0106137:	77 15                	ja     f010614e <strtol+0xc4>
			dig = *s - 'A' + 10;
f0106139:	0f be c9             	movsbl %cl,%ecx
f010613c:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010613f:	39 f1                	cmp    %esi,%ecx
f0106141:	7d 0b                	jge    f010614e <strtol+0xc4>
			break;
		s++, val = (val * base) + dig;
f0106143:	83 c2 01             	add    $0x1,%edx
f0106146:	0f af c6             	imul   %esi,%eax
f0106149:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f010614c:	eb be                	jmp    f010610c <strtol+0x82>
f010614e:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0106150:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106154:	74 05                	je     f010615b <strtol+0xd1>
		*endptr = (char *) s;
f0106156:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106159:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f010615b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010615f:	74 04                	je     f0106165 <strtol+0xdb>
f0106161:	89 c8                	mov    %ecx,%eax
f0106163:	f7 d8                	neg    %eax
}
f0106165:	83 c4 04             	add    $0x4,%esp
f0106168:	5b                   	pop    %ebx
f0106169:	5e                   	pop    %esi
f010616a:	5f                   	pop    %edi
f010616b:	5d                   	pop    %ebp
f010616c:	c3                   	ret    
f010616d:	00 00                	add    %al,(%eax)
	...

f0106170 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106170:	fa                   	cli    

	xorw    %ax, %ax
f0106171:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106173:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106175:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106177:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106179:	0f 01 16             	lgdtl  (%esi)
f010617c:	74 70                	je     f01061ee <mpentry_end+0x4>
	movl    %cr0, %eax
f010617e:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106181:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106185:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106188:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010618e:	08 00                	or     %al,(%eax)

f0106190 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106190:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106194:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106196:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106198:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010619a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010619e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01061a0:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01061a2:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f01061a7:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01061aa:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01061ad:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01061b2:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01061b5:	8b 25 84 2e 23 f0    	mov    0xf0232e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01061bb:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01061c0:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f01061c5:	ff d0                	call   *%eax

f01061c7 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01061c7:	eb fe                	jmp    f01061c7 <spin>
f01061c9:	8d 76 00             	lea    0x0(%esi),%esi

f01061cc <gdt>:
	...
f01061d4:	ff                   	(bad)  
f01061d5:	ff 00                	incl   (%eax)
f01061d7:	00 00                	add    %al,(%eax)
f01061d9:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01061e0:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f01061e4 <gdtdesc>:
f01061e4:	17                   	pop    %ss
f01061e5:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01061ea <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01061ea:	90                   	nop
f01061eb:	00 00                	add    %al,(%eax)
f01061ed:	00 00                	add    %al,(%eax)
	...

f01061f0 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f01061f0:	55                   	push   %ebp
f01061f1:	89 e5                	mov    %esp,%ebp
f01061f3:	56                   	push   %esi
f01061f4:	53                   	push   %ebx
f01061f5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01061fa:	b9 00 00 00 00       	mov    $0x0,%ecx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01061ff:	eb 09                	jmp    f010620a <sum+0x1a>
		sum += ((uint8_t *)addr)[i];
f0106201:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106205:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106207:	83 c1 01             	add    $0x1,%ecx
f010620a:	39 d1                	cmp    %edx,%ecx
f010620c:	7c f3                	jl     f0106201 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f010620e:	89 d8                	mov    %ebx,%eax
f0106210:	5b                   	pop    %ebx
f0106211:	5e                   	pop    %esi
f0106212:	5d                   	pop    %ebp
f0106213:	c3                   	ret    

f0106214 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106214:	55                   	push   %ebp
f0106215:	89 e5                	mov    %esp,%ebp
f0106217:	56                   	push   %esi
f0106218:	53                   	push   %ebx
f0106219:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010621c:	8b 0d 88 2e 23 f0    	mov    0xf0232e88,%ecx
f0106222:	89 c3                	mov    %eax,%ebx
f0106224:	c1 eb 0c             	shr    $0xc,%ebx
f0106227:	39 cb                	cmp    %ecx,%ebx
f0106229:	72 20                	jb     f010624b <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010622b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010622f:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0106236:	f0 
f0106237:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010623e:	00 
f010623f:	c7 04 24 a5 88 10 f0 	movl   $0xf01088a5,(%esp)
f0106246:	e8 3a 9e ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010624b:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010624e:	89 f2                	mov    %esi,%edx
f0106250:	c1 ea 0c             	shr    $0xc,%edx
f0106253:	39 d1                	cmp    %edx,%ecx
f0106255:	77 20                	ja     f0106277 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106257:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010625b:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0106262:	f0 
f0106263:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010626a:	00 
f010626b:	c7 04 24 a5 88 10 f0 	movl   $0xf01088a5,(%esp)
f0106272:	e8 0e 9e ff ff       	call   f0100085 <_panic>
f0106277:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010627d:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106283:	eb 2f                	jmp    f01062b4 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106285:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010628c:	00 
f010628d:	c7 44 24 04 b5 88 10 	movl   $0xf01088b5,0x4(%esp)
f0106294:	f0 
f0106295:	89 1c 24             	mov    %ebx,(%esp)
f0106298:	e8 90 fd ff ff       	call   f010602d <memcmp>
f010629d:	85 c0                	test   %eax,%eax
f010629f:	75 10                	jne    f01062b1 <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f01062a1:	ba 10 00 00 00       	mov    $0x10,%edx
f01062a6:	89 d8                	mov    %ebx,%eax
f01062a8:	e8 43 ff ff ff       	call   f01061f0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01062ad:	84 c0                	test   %al,%al
f01062af:	74 0c                	je     f01062bd <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f01062b1:	83 c3 10             	add    $0x10,%ebx
f01062b4:	39 f3                	cmp    %esi,%ebx
f01062b6:	72 cd                	jb     f0106285 <mpsearch1+0x71>
f01062b8:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f01062bd:	89 d8                	mov    %ebx,%eax
f01062bf:	83 c4 10             	add    $0x10,%esp
f01062c2:	5b                   	pop    %ebx
f01062c3:	5e                   	pop    %esi
f01062c4:	5d                   	pop    %ebp
f01062c5:	c3                   	ret    

f01062c6 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f01062c6:	55                   	push   %ebp
f01062c7:	89 e5                	mov    %esp,%ebp
f01062c9:	57                   	push   %edi
f01062ca:	56                   	push   %esi
f01062cb:	53                   	push   %ebx
f01062cc:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f01062cf:	c7 05 c0 33 23 f0 20 	movl   $0xf0233020,0xf02333c0
f01062d6:	30 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062d9:	83 3d 88 2e 23 f0 00 	cmpl   $0x0,0xf0232e88
f01062e0:	75 24                	jne    f0106306 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062e2:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f01062e9:	00 
f01062ea:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f01062f1:	f0 
f01062f2:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f01062f9:	00 
f01062fa:	c7 04 24 a5 88 10 f0 	movl   $0xf01088a5,(%esp)
f0106301:	e8 7f 9d ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106306:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f010630d:	85 c0                	test   %eax,%eax
f010630f:	74 16                	je     f0106327 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0106311:	c1 e0 04             	shl    $0x4,%eax
f0106314:	ba 00 04 00 00       	mov    $0x400,%edx
f0106319:	e8 f6 fe ff ff       	call   f0106214 <mpsearch1>
f010631e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106321:	85 c0                	test   %eax,%eax
f0106323:	75 3c                	jne    f0106361 <mp_init+0x9b>
f0106325:	eb 20                	jmp    f0106347 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106327:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f010632e:	c1 e0 0a             	shl    $0xa,%eax
f0106331:	2d 00 04 00 00       	sub    $0x400,%eax
f0106336:	ba 00 04 00 00       	mov    $0x400,%edx
f010633b:	e8 d4 fe ff ff       	call   f0106214 <mpsearch1>
f0106340:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106343:	85 c0                	test   %eax,%eax
f0106345:	75 1a                	jne    f0106361 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106347:	ba 00 00 01 00       	mov    $0x10000,%edx
f010634c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106351:	e8 be fe ff ff       	call   f0106214 <mpsearch1>
f0106356:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106359:	85 c0                	test   %eax,%eax
f010635b:	0f 84 2b 02 00 00    	je     f010658c <mp_init+0x2c6>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106361:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106364:	8b 78 04             	mov    0x4(%eax),%edi
f0106367:	85 ff                	test   %edi,%edi
f0106369:	74 06                	je     f0106371 <mp_init+0xab>
f010636b:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f010636f:	74 11                	je     f0106382 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106371:	c7 04 24 18 87 10 f0 	movl   $0xf0108718,(%esp)
f0106378:	e8 a2 de ff ff       	call   f010421f <cprintf>
f010637d:	e9 0a 02 00 00       	jmp    f010658c <mp_init+0x2c6>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106382:	89 f8                	mov    %edi,%eax
f0106384:	c1 e8 0c             	shr    $0xc,%eax
f0106387:	3b 05 88 2e 23 f0    	cmp    0xf0232e88,%eax
f010638d:	72 20                	jb     f01063af <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010638f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106393:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f010639a:	f0 
f010639b:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01063a2:	00 
f01063a3:	c7 04 24 a5 88 10 f0 	movl   $0xf01088a5,(%esp)
f01063aa:	e8 d6 9c ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f01063af:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01063b5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01063bc:	00 
f01063bd:	c7 44 24 04 ba 88 10 	movl   $0xf01088ba,0x4(%esp)
f01063c4:	f0 
f01063c5:	89 3c 24             	mov    %edi,(%esp)
f01063c8:	e8 60 fc ff ff       	call   f010602d <memcmp>
f01063cd:	85 c0                	test   %eax,%eax
f01063cf:	74 11                	je     f01063e2 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f01063d1:	c7 04 24 48 87 10 f0 	movl   $0xf0108748,(%esp)
f01063d8:	e8 42 de ff ff       	call   f010421f <cprintf>
f01063dd:	e9 aa 01 00 00       	jmp    f010658c <mp_init+0x2c6>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01063e2:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f01063e6:	89 f8                	mov    %edi,%eax
f01063e8:	e8 03 fe ff ff       	call   f01061f0 <sum>
f01063ed:	84 c0                	test   %al,%al
f01063ef:	90                   	nop
f01063f0:	74 11                	je     f0106403 <mp_init+0x13d>
		cprintf("SMP: Bad MP configuration checksum\n");
f01063f2:	c7 04 24 7c 87 10 f0 	movl   $0xf010877c,(%esp)
f01063f9:	e8 21 de ff ff       	call   f010421f <cprintf>
f01063fe:	e9 89 01 00 00       	jmp    f010658c <mp_init+0x2c6>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106403:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106407:	3c 01                	cmp    $0x1,%al
f0106409:	74 1f                	je     f010642a <mp_init+0x164>
f010640b:	3c 04                	cmp    $0x4,%al
f010640d:	8d 76 00             	lea    0x0(%esi),%esi
f0106410:	74 18                	je     f010642a <mp_init+0x164>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106412:	0f b6 c0             	movzbl %al,%eax
f0106415:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106419:	c7 04 24 a0 87 10 f0 	movl   $0xf01087a0,(%esp)
f0106420:	e8 fa dd ff ff       	call   f010421f <cprintf>
f0106425:	e9 62 01 00 00       	jmp    f010658c <mp_init+0x2c6>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010642a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f010642e:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0106432:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0106435:	e8 b6 fd ff ff       	call   f01061f0 <sum>
f010643a:	02 47 2a             	add    0x2a(%edi),%al
f010643d:	84 c0                	test   %al,%al
f010643f:	74 11                	je     f0106452 <mp_init+0x18c>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106441:	c7 04 24 c0 87 10 f0 	movl   $0xf01087c0,(%esp)
f0106448:	e8 d2 dd ff ff       	call   f010421f <cprintf>
f010644d:	e9 3a 01 00 00       	jmp    f010658c <mp_init+0x2c6>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106452:	85 ff                	test   %edi,%edi
f0106454:	0f 84 32 01 00 00    	je     f010658c <mp_init+0x2c6>
		return;
	ismp = 1;
f010645a:	c7 05 00 30 23 f0 01 	movl   $0x1,0xf0233000
f0106461:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106464:	8b 47 24             	mov    0x24(%edi),%eax
f0106467:	a3 00 40 27 f0       	mov    %eax,0xf0274000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010646c:	8d 77 2c             	lea    0x2c(%edi),%esi
f010646f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106474:	e9 88 00 00 00       	jmp    f0106501 <mp_init+0x23b>
		switch (*p) {
f0106479:	0f b6 06             	movzbl (%esi),%eax
f010647c:	84 c0                	test   %al,%al
f010647e:	74 06                	je     f0106486 <mp_init+0x1c0>
f0106480:	3c 04                	cmp    $0x4,%al
f0106482:	77 59                	ja     f01064dd <mp_init+0x217>
f0106484:	eb 52                	jmp    f01064d8 <mp_init+0x212>
		case MPPROC:
			proc = (struct mpproc *)p;
f0106486:	89 f2                	mov    %esi,%edx
			if (proc->flags & MPPROC_BOOT)
f0106488:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f010648c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106490:	74 11                	je     f01064a3 <mp_init+0x1dd>
				bootcpu = &cpus[ncpu];
f0106492:	6b 05 c4 33 23 f0 74 	imul   $0x74,0xf02333c4,%eax
f0106499:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010649e:	a3 c0 33 23 f0       	mov    %eax,0xf02333c0
			if (ncpu < NCPU) {
f01064a3:	a1 c4 33 23 f0       	mov    0xf02333c4,%eax
f01064a8:	83 f8 07             	cmp    $0x7,%eax
f01064ab:	7f 12                	jg     f01064bf <mp_init+0x1f9>
				cpus[ncpu].cpu_id = ncpu;
f01064ad:	6b d0 74             	imul   $0x74,%eax,%edx
f01064b0:	88 82 20 30 23 f0    	mov    %al,-0xfdccfe0(%edx)
				ncpu++;
f01064b6:	83 05 c4 33 23 f0 01 	addl   $0x1,0xf02333c4
f01064bd:	eb 14                	jmp    f01064d3 <mp_init+0x20d>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01064bf:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f01064c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064c7:	c7 04 24 f0 87 10 f0 	movl   $0xf01087f0,(%esp)
f01064ce:	e8 4c dd ff ff       	call   f010421f <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01064d3:	83 c6 14             	add    $0x14,%esi
			continue;
f01064d6:	eb 26                	jmp    f01064fe <mp_init+0x238>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01064d8:	83 c6 08             	add    $0x8,%esi
			continue;
f01064db:	eb 21                	jmp    f01064fe <mp_init+0x238>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01064dd:	0f b6 c0             	movzbl %al,%eax
f01064e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064e4:	c7 04 24 18 88 10 f0 	movl   $0xf0108818,(%esp)
f01064eb:	e8 2f dd ff ff       	call   f010421f <cprintf>
			ismp = 0;
f01064f0:	c7 05 00 30 23 f0 00 	movl   $0x0,0xf0233000
f01064f7:	00 00 00 
			i = conf->entry;
f01064fa:	0f b7 5f 22          	movzwl 0x22(%edi),%ebx
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01064fe:	83 c3 01             	add    $0x1,%ebx
f0106501:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106505:	39 c3                	cmp    %eax,%ebx
f0106507:	0f 82 6c ff ff ff    	jb     f0106479 <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010650d:	a1 c0 33 23 f0       	mov    0xf02333c0,%eax
f0106512:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106519:	83 3d 00 30 23 f0 00 	cmpl   $0x0,0xf0233000
f0106520:	75 22                	jne    f0106544 <mp_init+0x27e>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106522:	c7 05 c4 33 23 f0 01 	movl   $0x1,0xf02333c4
f0106529:	00 00 00 
		lapicaddr = 0;
f010652c:	c7 05 00 40 27 f0 00 	movl   $0x0,0xf0274000
f0106533:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106536:	c7 04 24 38 88 10 f0 	movl   $0xf0108838,(%esp)
f010653d:	e8 dd dc ff ff       	call   f010421f <cprintf>
		return;
f0106542:	eb 48                	jmp    f010658c <mp_init+0x2c6>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106544:	a1 c4 33 23 f0       	mov    0xf02333c4,%eax
f0106549:	89 44 24 08          	mov    %eax,0x8(%esp)
f010654d:	a1 c0 33 23 f0       	mov    0xf02333c0,%eax
f0106552:	0f b6 00             	movzbl (%eax),%eax
f0106555:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106559:	c7 04 24 bf 88 10 f0 	movl   $0xf01088bf,(%esp)
f0106560:	e8 ba dc ff ff       	call   f010421f <cprintf>

	if (mp->imcrp) {
f0106565:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106568:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010656c:	74 1e                	je     f010658c <mp_init+0x2c6>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010656e:	c7 04 24 64 88 10 f0 	movl   $0xf0108864,(%esp)
f0106575:	e8 a5 dc ff ff       	call   f010421f <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010657a:	ba 22 00 00 00       	mov    $0x22,%edx
f010657f:	b8 70 00 00 00       	mov    $0x70,%eax
f0106584:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106585:	b2 23                	mov    $0x23,%dl
f0106587:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106588:	83 c8 01             	or     $0x1,%eax
f010658b:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f010658c:	83 c4 2c             	add    $0x2c,%esp
f010658f:	5b                   	pop    %ebx
f0106590:	5e                   	pop    %esi
f0106591:	5f                   	pop    %edi
f0106592:	5d                   	pop    %ebp
f0106593:	c3                   	ret    

f0106594 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106594:	55                   	push   %ebp
f0106595:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106597:	c1 e0 02             	shl    $0x2,%eax
f010659a:	03 05 04 40 27 f0    	add    0xf0274004,%eax
f01065a0:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01065a2:	a1 04 40 27 f0       	mov    0xf0274004,%eax
f01065a7:	83 c0 20             	add    $0x20,%eax
f01065aa:	8b 00                	mov    (%eax),%eax
}
f01065ac:	5d                   	pop    %ebp
f01065ad:	c3                   	ret    

f01065ae <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f01065ae:	55                   	push   %ebp
f01065af:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01065b1:	8b 15 04 40 27 f0    	mov    0xf0274004,%edx
f01065b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01065bc:	85 d2                	test   %edx,%edx
f01065be:	74 08                	je     f01065c8 <cpunum+0x1a>
		return lapic[ID] >> 24;
f01065c0:	83 c2 20             	add    $0x20,%edx
f01065c3:	8b 02                	mov    (%edx),%eax
f01065c5:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f01065c8:	5d                   	pop    %ebp
f01065c9:	c3                   	ret    

f01065ca <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01065ca:	55                   	push   %ebp
f01065cb:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01065cd:	83 3d 04 40 27 f0 00 	cmpl   $0x0,0xf0274004
f01065d4:	74 0f                	je     f01065e5 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01065d6:	ba 00 00 00 00       	mov    $0x0,%edx
f01065db:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01065e0:	e8 af ff ff ff       	call   f0106594 <lapicw>
}
f01065e5:	5d                   	pop    %ebp
f01065e6:	c3                   	ret    

f01065e7 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f01065e7:	55                   	push   %ebp
f01065e8:	89 e5                	mov    %esp,%ebp
}
f01065ea:	5d                   	pop    %ebp
f01065eb:	c3                   	ret    

f01065ec <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f01065ec:	55                   	push   %ebp
f01065ed:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01065ef:	8b 55 08             	mov    0x8(%ebp),%edx
f01065f2:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01065f8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01065fd:	e8 92 ff ff ff       	call   f0106594 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106602:	8b 15 04 40 27 f0    	mov    0xf0274004,%edx
f0106608:	81 c2 00 03 00 00    	add    $0x300,%edx
f010660e:	8b 02                	mov    (%edx),%eax
f0106610:	f6 c4 10             	test   $0x10,%ah
f0106613:	75 f9                	jne    f010660e <lapic_ipi+0x22>
		;
}
f0106615:	5d                   	pop    %ebp
f0106616:	c3                   	ret    

f0106617 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106617:	55                   	push   %ebp
f0106618:	89 e5                	mov    %esp,%ebp
f010661a:	56                   	push   %esi
f010661b:	53                   	push   %ebx
f010661c:	83 ec 10             	sub    $0x10,%esp
f010661f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106622:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0106626:	ba 70 00 00 00       	mov    $0x70,%edx
f010662b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106630:	ee                   	out    %al,(%dx)
f0106631:	b2 71                	mov    $0x71,%dl
f0106633:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106638:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106639:	83 3d 88 2e 23 f0 00 	cmpl   $0x0,0xf0232e88
f0106640:	75 24                	jne    f0106666 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106642:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0106649:	00 
f010664a:	c7 44 24 08 40 6d 10 	movl   $0xf0106d40,0x8(%esp)
f0106651:	f0 
f0106652:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0106659:	00 
f010665a:	c7 04 24 dc 88 10 f0 	movl   $0xf01088dc,(%esp)
f0106661:	e8 1f 9a ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106666:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010666d:	00 00 
	wrv[1] = addr >> 4;
f010666f:	89 f0                	mov    %esi,%eax
f0106671:	c1 e8 04             	shr    $0x4,%eax
f0106674:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010667a:	c1 e3 18             	shl    $0x18,%ebx
f010667d:	89 da                	mov    %ebx,%edx
f010667f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106684:	e8 0b ff ff ff       	call   f0106594 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106689:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010668e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106693:	e8 fc fe ff ff       	call   f0106594 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106698:	ba 00 85 00 00       	mov    $0x8500,%edx
f010669d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066a2:	e8 ed fe ff ff       	call   f0106594 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01066a7:	c1 ee 0c             	shr    $0xc,%esi
f01066aa:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01066b0:	89 da                	mov    %ebx,%edx
f01066b2:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01066b7:	e8 d8 fe ff ff       	call   f0106594 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01066bc:	89 f2                	mov    %esi,%edx
f01066be:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066c3:	e8 cc fe ff ff       	call   f0106594 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01066c8:	89 da                	mov    %ebx,%edx
f01066ca:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01066cf:	e8 c0 fe ff ff       	call   f0106594 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01066d4:	89 f2                	mov    %esi,%edx
f01066d6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01066db:	e8 b4 fe ff ff       	call   f0106594 <lapicw>
		microdelay(200);
	}
}
f01066e0:	83 c4 10             	add    $0x10,%esp
f01066e3:	5b                   	pop    %ebx
f01066e4:	5e                   	pop    %esi
f01066e5:	5d                   	pop    %ebp
f01066e6:	c3                   	ret    

f01066e7 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01066e7:	55                   	push   %ebp
f01066e8:	89 e5                	mov    %esp,%ebp
f01066ea:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f01066ed:	a1 00 40 27 f0       	mov    0xf0274000,%eax
f01066f2:	85 c0                	test   %eax,%eax
f01066f4:	0f 84 20 01 00 00    	je     f010681a <lapic_init+0x133>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f01066fa:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106701:	00 
f0106702:	89 04 24             	mov    %eax,(%esp)
f0106705:	e8 35 ae ff ff       	call   f010153f <mmio_map_region>
f010670a:	a3 04 40 27 f0       	mov    %eax,0xf0274004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010670f:	ba 27 01 00 00       	mov    $0x127,%edx
f0106714:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106719:	e8 76 fe ff ff       	call   f0106594 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010671e:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106723:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106728:	e8 67 fe ff ff       	call   f0106594 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010672d:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106732:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106737:	e8 58 fe ff ff       	call   f0106594 <lapicw>
	lapicw(TICR, 10000000); 
f010673c:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106741:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106746:	e8 49 fe ff ff       	call   f0106594 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010674b:	e8 5e fe ff ff       	call   f01065ae <cpunum>
f0106750:	6b c0 74             	imul   $0x74,%eax,%eax
f0106753:	05 20 30 23 f0       	add    $0xf0233020,%eax
f0106758:	39 05 c0 33 23 f0    	cmp    %eax,0xf02333c0
f010675e:	74 0f                	je     f010676f <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0106760:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106765:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010676a:	e8 25 fe ff ff       	call   f0106594 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010676f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106774:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106779:	e8 16 fe ff ff       	call   f0106594 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010677e:	a1 04 40 27 f0       	mov    0xf0274004,%eax
f0106783:	83 c0 30             	add    $0x30,%eax
f0106786:	8b 00                	mov    (%eax),%eax
f0106788:	c1 e8 10             	shr    $0x10,%eax
f010678b:	3c 03                	cmp    $0x3,%al
f010678d:	76 0f                	jbe    f010679e <lapic_init+0xb7>
		lapicw(PCINT, MASKED);
f010678f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106794:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106799:	e8 f6 fd ff ff       	call   f0106594 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010679e:	ba 33 00 00 00       	mov    $0x33,%edx
f01067a3:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01067a8:	e8 e7 fd ff ff       	call   f0106594 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01067ad:	ba 00 00 00 00       	mov    $0x0,%edx
f01067b2:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01067b7:	e8 d8 fd ff ff       	call   f0106594 <lapicw>
	lapicw(ESR, 0);
f01067bc:	ba 00 00 00 00       	mov    $0x0,%edx
f01067c1:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01067c6:	e8 c9 fd ff ff       	call   f0106594 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01067cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01067d0:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01067d5:	e8 ba fd ff ff       	call   f0106594 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f01067da:	ba 00 00 00 00       	mov    $0x0,%edx
f01067df:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01067e4:	e8 ab fd ff ff       	call   f0106594 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01067e9:	ba 00 85 08 00       	mov    $0x88500,%edx
f01067ee:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01067f3:	e8 9c fd ff ff       	call   f0106594 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01067f8:	8b 15 04 40 27 f0    	mov    0xf0274004,%edx
f01067fe:	81 c2 00 03 00 00    	add    $0x300,%edx
f0106804:	8b 02                	mov    (%edx),%eax
f0106806:	f6 c4 10             	test   $0x10,%ah
f0106809:	75 f9                	jne    f0106804 <lapic_init+0x11d>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010680b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106810:	b8 20 00 00 00       	mov    $0x20,%eax
f0106815:	e8 7a fd ff ff       	call   f0106594 <lapicw>
}
f010681a:	c9                   	leave  
f010681b:	c3                   	ret    
f010681c:	00 00                	add    %al,(%eax)
	...

f0106820 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106820:	55                   	push   %ebp
f0106821:	89 e5                	mov    %esp,%ebp
f0106823:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106826:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010682c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010682f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106832:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106839:	5d                   	pop    %ebp
f010683a:	c3                   	ret    

f010683b <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f010683b:	55                   	push   %ebp
f010683c:	89 e5                	mov    %esp,%ebp
f010683e:	53                   	push   %ebx
f010683f:	83 ec 04             	sub    $0x4,%esp
f0106842:	89 c2                	mov    %eax,%edx
	return lock->locked && lock->cpu == thiscpu;
f0106844:	b8 00 00 00 00       	mov    $0x0,%eax
f0106849:	83 3a 00             	cmpl   $0x0,(%edx)
f010684c:	74 18                	je     f0106866 <holding+0x2b>
f010684e:	8b 5a 08             	mov    0x8(%edx),%ebx
f0106851:	e8 58 fd ff ff       	call   f01065ae <cpunum>
f0106856:	6b c0 74             	imul   $0x74,%eax,%eax
f0106859:	05 20 30 23 f0       	add    $0xf0233020,%eax
f010685e:	39 c3                	cmp    %eax,%ebx
f0106860:	0f 94 c0             	sete   %al
f0106863:	0f b6 c0             	movzbl %al,%eax
}
f0106866:	83 c4 04             	add    $0x4,%esp
f0106869:	5b                   	pop    %ebx
f010686a:	5d                   	pop    %ebp
f010686b:	c3                   	ret    

f010686c <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010686c:	55                   	push   %ebp
f010686d:	89 e5                	mov    %esp,%ebp
f010686f:	83 ec 78             	sub    $0x78,%esp
f0106872:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0106875:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0106878:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010687b:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010687e:	89 d8                	mov    %ebx,%eax
f0106880:	e8 b6 ff ff ff       	call   f010683b <holding>
f0106885:	85 c0                	test   %eax,%eax
f0106887:	0f 85 cd 00 00 00    	jne    f010695a <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010688d:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106894:	00 
f0106895:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106898:	89 44 24 04          	mov    %eax,0x4(%esp)
f010689c:	8d 75 a8             	lea    -0x58(%ebp),%esi
f010689f:	89 34 24             	mov    %esi,(%esp)
f01068a2:	e8 e9 f6 ff ff       	call   f0105f90 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01068a7:	8b 43 08             	mov    0x8(%ebx),%eax
f01068aa:	0f b6 38             	movzbl (%eax),%edi
f01068ad:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01068b0:	e8 f9 fc ff ff       	call   f01065ae <cpunum>
f01068b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01068b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01068bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01068c1:	c7 04 24 ec 88 10 f0 	movl   $0xf01088ec,(%esp)
f01068c8:	e8 52 d9 ff ff       	call   f010421f <cprintf>
f01068cd:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01068cf:	8d 7d d0             	lea    -0x30(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01068d2:	89 fe                	mov    %edi,%esi
f01068d4:	eb 62                	jmp    f0106938 <spin_unlock+0xcc>
f01068d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01068da:	89 04 24             	mov    %eax,(%esp)
f01068dd:	e8 50 eb ff ff       	call   f0105432 <debuginfo_eip>
f01068e2:	85 c0                	test   %eax,%eax
f01068e4:	78 39                	js     f010691f <spin_unlock+0xb3>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01068e6:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01068e8:	89 c2                	mov    %eax,%edx
f01068ea:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01068ed:	89 54 24 18          	mov    %edx,0x18(%esp)
f01068f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01068f4:	89 54 24 14          	mov    %edx,0x14(%esp)
f01068f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01068fb:	89 54 24 10          	mov    %edx,0x10(%esp)
f01068ff:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106902:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106906:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106909:	89 54 24 08          	mov    %edx,0x8(%esp)
f010690d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106911:	c7 04 24 50 89 10 f0 	movl   $0xf0108950,(%esp)
f0106918:	e8 02 d9 ff ff       	call   f010421f <cprintf>
f010691d:	eb 12                	jmp    f0106931 <spin_unlock+0xc5>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010691f:	8b 03                	mov    (%ebx),%eax
f0106921:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106925:	c7 04 24 67 89 10 f0 	movl   $0xf0108967,(%esp)
f010692c:	e8 ee d8 ff ff       	call   f010421f <cprintf>
f0106931:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106934:	39 fb                	cmp    %edi,%ebx
f0106936:	74 06                	je     f010693e <spin_unlock+0xd2>
f0106938:	8b 03                	mov    (%ebx),%eax
f010693a:	85 c0                	test   %eax,%eax
f010693c:	75 98                	jne    f01068d6 <spin_unlock+0x6a>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010693e:	c7 44 24 08 6f 89 10 	movl   $0xf010896f,0x8(%esp)
f0106945:	f0 
f0106946:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010694d:	00 
f010694e:	c7 04 24 7b 89 10 f0 	movl   $0xf010897b,(%esp)
f0106955:	e8 2b 97 ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f010695a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106961:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0106968:	b8 00 00 00 00       	mov    $0x0,%eax
f010696d:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0106970:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106973:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0106976:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106979:	89 ec                	mov    %ebp,%esp
f010697b:	5d                   	pop    %ebp
f010697c:	c3                   	ret    

f010697d <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010697d:	55                   	push   %ebp
f010697e:	89 e5                	mov    %esp,%ebp
f0106980:	56                   	push   %esi
f0106981:	53                   	push   %ebx
f0106982:	83 ec 20             	sub    $0x20,%esp
f0106985:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106988:	89 d8                	mov    %ebx,%eax
f010698a:	e8 ac fe ff ff       	call   f010683b <holding>
f010698f:	85 c0                	test   %eax,%eax
f0106991:	75 09                	jne    f010699c <spin_lock+0x1f>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106993:	89 da                	mov    %ebx,%edx
f0106995:	b9 01 00 00 00       	mov    $0x1,%ecx
f010699a:	eb 2e                	jmp    f01069ca <spin_lock+0x4d>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010699c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010699f:	e8 0a fc ff ff       	call   f01065ae <cpunum>
f01069a4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01069a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01069ac:	c7 44 24 08 24 89 10 	movl   $0xf0108924,0x8(%esp)
f01069b3:	f0 
f01069b4:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f01069bb:	00 
f01069bc:	c7 04 24 7b 89 10 f0 	movl   $0xf010897b,(%esp)
f01069c3:	e8 bd 96 ff ff       	call   f0100085 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01069c8:	f3 90                	pause  
f01069ca:	89 c8                	mov    %ecx,%eax
f01069cc:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01069cf:	85 c0                	test   %eax,%eax
f01069d1:	75 f5                	jne    f01069c8 <spin_lock+0x4b>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01069d3:	e8 d6 fb ff ff       	call   f01065ae <cpunum>
f01069d8:	6b c0 74             	imul   $0x74,%eax,%eax
f01069db:	05 20 30 23 f0       	add    $0xf0233020,%eax
f01069e0:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01069e3:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f01069e6:	89 ea                	mov    %ebp,%edx
f01069e8:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01069ed:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01069f3:	76 25                	jbe    f0106a1a <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
f01069f5:	8b 4a 04             	mov    0x4(%edx),%ecx
f01069f8:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01069fb:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01069fd:	83 c0 01             	add    $0x1,%eax
f0106a00:	83 f8 0a             	cmp    $0xa,%eax
f0106a03:	75 e8                	jne    f01069ed <spin_lock+0x70>
f0106a05:	eb 19                	jmp    f0106a20 <spin_lock+0xa3>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106a07:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106a0d:	83 c0 01             	add    $0x1,%eax
f0106a10:	83 c2 04             	add    $0x4,%edx
f0106a13:	83 f8 09             	cmp    $0x9,%eax
f0106a16:	7e ef                	jle    f0106a07 <spin_lock+0x8a>
f0106a18:	eb 06                	jmp    f0106a20 <spin_lock+0xa3>
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f0106a1a:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f0106a1e:	eb e7                	jmp    f0106a07 <spin_lock+0x8a>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106a20:	83 c4 20             	add    $0x20,%esp
f0106a23:	5b                   	pop    %ebx
f0106a24:	5e                   	pop    %esi
f0106a25:	5d                   	pop    %ebp
f0106a26:	c3                   	ret    
	...

f0106a30 <__udivdi3>:
f0106a30:	55                   	push   %ebp
f0106a31:	89 e5                	mov    %esp,%ebp
f0106a33:	57                   	push   %edi
f0106a34:	56                   	push   %esi
f0106a35:	83 ec 10             	sub    $0x10,%esp
f0106a38:	8b 45 14             	mov    0x14(%ebp),%eax
f0106a3b:	8b 55 08             	mov    0x8(%ebp),%edx
f0106a3e:	8b 75 10             	mov    0x10(%ebp),%esi
f0106a41:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106a44:	85 c0                	test   %eax,%eax
f0106a46:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0106a49:	75 35                	jne    f0106a80 <__udivdi3+0x50>
f0106a4b:	39 fe                	cmp    %edi,%esi
f0106a4d:	77 61                	ja     f0106ab0 <__udivdi3+0x80>
f0106a4f:	85 f6                	test   %esi,%esi
f0106a51:	75 0b                	jne    f0106a5e <__udivdi3+0x2e>
f0106a53:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a58:	31 d2                	xor    %edx,%edx
f0106a5a:	f7 f6                	div    %esi
f0106a5c:	89 c6                	mov    %eax,%esi
f0106a5e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0106a61:	31 d2                	xor    %edx,%edx
f0106a63:	89 f8                	mov    %edi,%eax
f0106a65:	f7 f6                	div    %esi
f0106a67:	89 c7                	mov    %eax,%edi
f0106a69:	89 c8                	mov    %ecx,%eax
f0106a6b:	f7 f6                	div    %esi
f0106a6d:	89 c1                	mov    %eax,%ecx
f0106a6f:	89 fa                	mov    %edi,%edx
f0106a71:	89 c8                	mov    %ecx,%eax
f0106a73:	83 c4 10             	add    $0x10,%esp
f0106a76:	5e                   	pop    %esi
f0106a77:	5f                   	pop    %edi
f0106a78:	5d                   	pop    %ebp
f0106a79:	c3                   	ret    
f0106a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106a80:	39 f8                	cmp    %edi,%eax
f0106a82:	77 1c                	ja     f0106aa0 <__udivdi3+0x70>
f0106a84:	0f bd d0             	bsr    %eax,%edx
f0106a87:	83 f2 1f             	xor    $0x1f,%edx
f0106a8a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0106a8d:	75 39                	jne    f0106ac8 <__udivdi3+0x98>
f0106a8f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0106a92:	0f 86 a0 00 00 00    	jbe    f0106b38 <__udivdi3+0x108>
f0106a98:	39 f8                	cmp    %edi,%eax
f0106a9a:	0f 82 98 00 00 00    	jb     f0106b38 <__udivdi3+0x108>
f0106aa0:	31 ff                	xor    %edi,%edi
f0106aa2:	31 c9                	xor    %ecx,%ecx
f0106aa4:	89 c8                	mov    %ecx,%eax
f0106aa6:	89 fa                	mov    %edi,%edx
f0106aa8:	83 c4 10             	add    $0x10,%esp
f0106aab:	5e                   	pop    %esi
f0106aac:	5f                   	pop    %edi
f0106aad:	5d                   	pop    %ebp
f0106aae:	c3                   	ret    
f0106aaf:	90                   	nop
f0106ab0:	89 d1                	mov    %edx,%ecx
f0106ab2:	89 fa                	mov    %edi,%edx
f0106ab4:	89 c8                	mov    %ecx,%eax
f0106ab6:	31 ff                	xor    %edi,%edi
f0106ab8:	f7 f6                	div    %esi
f0106aba:	89 c1                	mov    %eax,%ecx
f0106abc:	89 fa                	mov    %edi,%edx
f0106abe:	89 c8                	mov    %ecx,%eax
f0106ac0:	83 c4 10             	add    $0x10,%esp
f0106ac3:	5e                   	pop    %esi
f0106ac4:	5f                   	pop    %edi
f0106ac5:	5d                   	pop    %ebp
f0106ac6:	c3                   	ret    
f0106ac7:	90                   	nop
f0106ac8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106acc:	89 f2                	mov    %esi,%edx
f0106ace:	d3 e0                	shl    %cl,%eax
f0106ad0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106ad3:	b8 20 00 00 00       	mov    $0x20,%eax
f0106ad8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0106adb:	89 c1                	mov    %eax,%ecx
f0106add:	d3 ea                	shr    %cl,%edx
f0106adf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106ae3:	0b 55 ec             	or     -0x14(%ebp),%edx
f0106ae6:	d3 e6                	shl    %cl,%esi
f0106ae8:	89 c1                	mov    %eax,%ecx
f0106aea:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0106aed:	89 fe                	mov    %edi,%esi
f0106aef:	d3 ee                	shr    %cl,%esi
f0106af1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106af5:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0106af8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106afb:	d3 e7                	shl    %cl,%edi
f0106afd:	89 c1                	mov    %eax,%ecx
f0106aff:	d3 ea                	shr    %cl,%edx
f0106b01:	09 d7                	or     %edx,%edi
f0106b03:	89 f2                	mov    %esi,%edx
f0106b05:	89 f8                	mov    %edi,%eax
f0106b07:	f7 75 ec             	divl   -0x14(%ebp)
f0106b0a:	89 d6                	mov    %edx,%esi
f0106b0c:	89 c7                	mov    %eax,%edi
f0106b0e:	f7 65 e8             	mull   -0x18(%ebp)
f0106b11:	39 d6                	cmp    %edx,%esi
f0106b13:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0106b16:	72 30                	jb     f0106b48 <__udivdi3+0x118>
f0106b18:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0106b1b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106b1f:	d3 e2                	shl    %cl,%edx
f0106b21:	39 c2                	cmp    %eax,%edx
f0106b23:	73 05                	jae    f0106b2a <__udivdi3+0xfa>
f0106b25:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0106b28:	74 1e                	je     f0106b48 <__udivdi3+0x118>
f0106b2a:	89 f9                	mov    %edi,%ecx
f0106b2c:	31 ff                	xor    %edi,%edi
f0106b2e:	e9 71 ff ff ff       	jmp    f0106aa4 <__udivdi3+0x74>
f0106b33:	90                   	nop
f0106b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b38:	31 ff                	xor    %edi,%edi
f0106b3a:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106b3f:	e9 60 ff ff ff       	jmp    f0106aa4 <__udivdi3+0x74>
f0106b44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106b48:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0106b4b:	31 ff                	xor    %edi,%edi
f0106b4d:	89 c8                	mov    %ecx,%eax
f0106b4f:	89 fa                	mov    %edi,%edx
f0106b51:	83 c4 10             	add    $0x10,%esp
f0106b54:	5e                   	pop    %esi
f0106b55:	5f                   	pop    %edi
f0106b56:	5d                   	pop    %ebp
f0106b57:	c3                   	ret    
	...

f0106b60 <__umoddi3>:
f0106b60:	55                   	push   %ebp
f0106b61:	89 e5                	mov    %esp,%ebp
f0106b63:	57                   	push   %edi
f0106b64:	56                   	push   %esi
f0106b65:	83 ec 20             	sub    $0x20,%esp
f0106b68:	8b 55 14             	mov    0x14(%ebp),%edx
f0106b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106b6e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0106b71:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106b74:	85 d2                	test   %edx,%edx
f0106b76:	89 c8                	mov    %ecx,%eax
f0106b78:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0106b7b:	75 13                	jne    f0106b90 <__umoddi3+0x30>
f0106b7d:	39 f7                	cmp    %esi,%edi
f0106b7f:	76 3f                	jbe    f0106bc0 <__umoddi3+0x60>
f0106b81:	89 f2                	mov    %esi,%edx
f0106b83:	f7 f7                	div    %edi
f0106b85:	89 d0                	mov    %edx,%eax
f0106b87:	31 d2                	xor    %edx,%edx
f0106b89:	83 c4 20             	add    $0x20,%esp
f0106b8c:	5e                   	pop    %esi
f0106b8d:	5f                   	pop    %edi
f0106b8e:	5d                   	pop    %ebp
f0106b8f:	c3                   	ret    
f0106b90:	39 f2                	cmp    %esi,%edx
f0106b92:	77 4c                	ja     f0106be0 <__umoddi3+0x80>
f0106b94:	0f bd ca             	bsr    %edx,%ecx
f0106b97:	83 f1 1f             	xor    $0x1f,%ecx
f0106b9a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0106b9d:	75 51                	jne    f0106bf0 <__umoddi3+0x90>
f0106b9f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0106ba2:	0f 87 e0 00 00 00    	ja     f0106c88 <__umoddi3+0x128>
f0106ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106bab:	29 f8                	sub    %edi,%eax
f0106bad:	19 d6                	sbb    %edx,%esi
f0106baf:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106bb5:	89 f2                	mov    %esi,%edx
f0106bb7:	83 c4 20             	add    $0x20,%esp
f0106bba:	5e                   	pop    %esi
f0106bbb:	5f                   	pop    %edi
f0106bbc:	5d                   	pop    %ebp
f0106bbd:	c3                   	ret    
f0106bbe:	66 90                	xchg   %ax,%ax
f0106bc0:	85 ff                	test   %edi,%edi
f0106bc2:	75 0b                	jne    f0106bcf <__umoddi3+0x6f>
f0106bc4:	b8 01 00 00 00       	mov    $0x1,%eax
f0106bc9:	31 d2                	xor    %edx,%edx
f0106bcb:	f7 f7                	div    %edi
f0106bcd:	89 c7                	mov    %eax,%edi
f0106bcf:	89 f0                	mov    %esi,%eax
f0106bd1:	31 d2                	xor    %edx,%edx
f0106bd3:	f7 f7                	div    %edi
f0106bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106bd8:	f7 f7                	div    %edi
f0106bda:	eb a9                	jmp    f0106b85 <__umoddi3+0x25>
f0106bdc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106be0:	89 c8                	mov    %ecx,%eax
f0106be2:	89 f2                	mov    %esi,%edx
f0106be4:	83 c4 20             	add    $0x20,%esp
f0106be7:	5e                   	pop    %esi
f0106be8:	5f                   	pop    %edi
f0106be9:	5d                   	pop    %ebp
f0106bea:	c3                   	ret    
f0106beb:	90                   	nop
f0106bec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106bf0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106bf4:	d3 e2                	shl    %cl,%edx
f0106bf6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0106bf9:	ba 20 00 00 00       	mov    $0x20,%edx
f0106bfe:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0106c01:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0106c04:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106c08:	89 fa                	mov    %edi,%edx
f0106c0a:	d3 ea                	shr    %cl,%edx
f0106c0c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106c10:	0b 55 f4             	or     -0xc(%ebp),%edx
f0106c13:	d3 e7                	shl    %cl,%edi
f0106c15:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106c19:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0106c1c:	89 f2                	mov    %esi,%edx
f0106c1e:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0106c21:	89 c7                	mov    %eax,%edi
f0106c23:	d3 ea                	shr    %cl,%edx
f0106c25:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106c29:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0106c2c:	89 c2                	mov    %eax,%edx
f0106c2e:	d3 e6                	shl    %cl,%esi
f0106c30:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106c34:	d3 ea                	shr    %cl,%edx
f0106c36:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106c3a:	09 d6                	or     %edx,%esi
f0106c3c:	89 f0                	mov    %esi,%eax
f0106c3e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0106c41:	d3 e7                	shl    %cl,%edi
f0106c43:	89 f2                	mov    %esi,%edx
f0106c45:	f7 75 f4             	divl   -0xc(%ebp)
f0106c48:	89 d6                	mov    %edx,%esi
f0106c4a:	f7 65 e8             	mull   -0x18(%ebp)
f0106c4d:	39 d6                	cmp    %edx,%esi
f0106c4f:	72 2b                	jb     f0106c7c <__umoddi3+0x11c>
f0106c51:	39 c7                	cmp    %eax,%edi
f0106c53:	72 23                	jb     f0106c78 <__umoddi3+0x118>
f0106c55:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106c59:	29 c7                	sub    %eax,%edi
f0106c5b:	19 d6                	sbb    %edx,%esi
f0106c5d:	89 f0                	mov    %esi,%eax
f0106c5f:	89 f2                	mov    %esi,%edx
f0106c61:	d3 ef                	shr    %cl,%edi
f0106c63:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106c67:	d3 e0                	shl    %cl,%eax
f0106c69:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106c6d:	09 f8                	or     %edi,%eax
f0106c6f:	d3 ea                	shr    %cl,%edx
f0106c71:	83 c4 20             	add    $0x20,%esp
f0106c74:	5e                   	pop    %esi
f0106c75:	5f                   	pop    %edi
f0106c76:	5d                   	pop    %ebp
f0106c77:	c3                   	ret    
f0106c78:	39 d6                	cmp    %edx,%esi
f0106c7a:	75 d9                	jne    f0106c55 <__umoddi3+0xf5>
f0106c7c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0106c7f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0106c82:	eb d1                	jmp    f0106c55 <__umoddi3+0xf5>
f0106c84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106c88:	39 f2                	cmp    %esi,%edx
f0106c8a:	0f 82 18 ff ff ff    	jb     f0106ba8 <__umoddi3+0x48>
f0106c90:	e9 1d ff ff ff       	jmp    f0106bb2 <__umoddi3+0x52>
