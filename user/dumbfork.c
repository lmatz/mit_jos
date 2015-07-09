// Ping-pong a counter between two processes.
// Only need to start one of these -- splits into two, crudely.

#include <inc/string.h>
#include <inc/lib.h>

//#define DUMBFORKDEBUG(...) cprintf(__VA_ARGS__)
#define DUMBFORKDEBUG(...)


envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
	envid_t who;
	int i;


	DUMBFORKDEBUG("ready to fork a child process\n");
	DUMBFORKDEBUG("parent's envid: %d\n",sys_getenvid());
	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}

void
duppage(envid_t dstenv, void *addr)
{
	int r;
	DUMBFORKDEBUG("enter the duppage\n");
	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_alloc: %e", r);
	
	DUMBFORKDEBUG("duppage:after sys_page_alloc\n");

	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		panic("sys_page_map: %e", r);


	DUMBFORKDEBUG("duppage:after sys_page_map \n");

	memmove(UTEMP, addr, PGSIZE);


	DUMBFORKDEBUG("duppage:after memmove\n");

	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		panic("sys_page_unmap: %e", r);

	DUMBFORKDEBUG("duppage:after sys_page_unmap\n");
}

envid_t
dumbfork(void)
{
	envid_t envid;
	uint8_t *addr;
	int r;
	extern unsigned char end[];

	// Allocate a new child environment.
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	DUMBFORKDEBUG("dumbfork: after sys_exofork\n");

	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		DUMBFORKDEBUG("Child envid: %d\n",sys_getenvid());
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}

	DUMBFORKDEBUG("Parent envid: %d\n",sys_getenvid());

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
		duppage(envid, addr);


	DUMBFORKDEBUG("Parent after duppage the entire address space\n");
	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));

	DUMBFORKDEBUG("Parent after duppage the stack we are currently on\n");

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	DUMBFORKDEBUG("Parent start the child environment running\n");

	return envid;
}

