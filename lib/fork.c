// implement fork from user space

#include <inc/string.h>
#include <inc/lib.h>

// PTE_COW marks copy-on-write page table entries.
// It is one of the bits explicitly allocated to user processes (PTE_AVAIL).
#define PTE_COW		0x800


//#define FORKDEBUG(...)  cprintf(__VA_ARGS__)
#define FORKDEBUG(...)
//
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	int r;

	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	FORKDEBUG("lib pgfault: fault address 0x%08x\n",(int)addr);

	if ( (err&FEC_WR) == 0 ) {
		panic("lib pgfault: The page fault is not caused by write\n");
	} 
	
	if ( (uvpt[PGNUM(addr)]&PTE_COW) == 0 ) {
		panic("lib pgfault: The page fault's page is not COW\n");
	}

	


	// Allocate a new page, map it at a temporary location (PFTEMP),
	// copy the data from the old page to the new page, then move the new
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
		
	envid_t envid=sys_getenvid();
	int res;
	
	res=sys_page_alloc(envid, PFTEMP, PTE_U | PTE_P | PTE_W);
	if (res<0) {
		panic("lib pgfault: cannot allocate temp page\n");
	}

	memmove(PFTEMP, (void*)ROUNDDOWN(addr,PGSIZE),PGSIZE);
	
	res=sys_page_map(envid,PFTEMP,envid,(void*)ROUNDDOWN(addr,PGSIZE), PTE_U | PTE_P | PTE_W);
	if (res<0) {
		panic("lib pgfault: cannot map page\n");
	}

	res=sys_page_unmap(envid,PFTEMP);
	if (res<0) {
		panic("lib pgfault: cannot unmap page\n");
	}
	return;
	//panic("pgfault not implemented");
}

//
// Map our virtual page pn (address pn*PGSIZE) into the target envid
// at the same virtual address.  If the page is writable or copy-on-write,
// the new mapping must be created copy-on-write, and then our mapping must be
// marked copy-on-write as well.  (Exercise: Why do we need to mark ours
// copy-on-write again if it was already copy-on-write at the beginning of
// this function?)
//
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;

	// LAB 4: Your code here.
	envid_t curenvid = sys_getenvid();

	pte_t pte = uvpt[pn];
	int perm;

	perm = PTE_U | PTE_P;
	if ( pte & PTE_W || pte & PTE_COW ) {
		perm |= PTE_COW;
	}

	r=sys_page_map(curenvid, (void*)(pn*PGSIZE), envid, (void*)(pn*PGSIZE),perm);
	if (r<0) {
		FORKDEBUG("lib duppage: sys_page_map curenvid fail\n");
		return r;
	}
	
	if ( perm & PTE_COW ) {
		r=sys_page_map(curenvid, (void*)(pn*PGSIZE), curenvid, (void*)(pn*PGSIZE), perm);
 		if (r<0) {
			FORKDEBUG("lib duppage: sys_page_map envid fail\n");
			return r;
		}
	}
	
	
//	panic("duppage not implemented");
	return 0;
}

//
// User-level fork with copy-on-write.
// Set up our page fault handler appropriately.
// Create a child.
// Copy our address space and page fault handler setup to the child.
// Then mark the child as runnable and return.
//
// Returns: child's envid to the parent, 0 to the child, < 0 on error.
// It is also OK to panic on error.
//
// Hint:
//   Use uvpd, uvpt, and duppage.
//   Remember to fix "thisenv" in the child process.
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
	// LAB 4: Your code here.
	int i,j,pn=0;
	envid_t curenvid=sys_getenvid();
	envid_t envid;
	int r;
	

	FORKDEBUG("fork: start to fork\n");
	set_pgfault_handler(pgfault);
	FORKDEBUG("fork: already set pgfault handler\n");


	if ( (envid = sys_exofork()) < 0) {
		return -1;
	}	

	FORKDEBUG("fork: already sys_exofork\n");
	
	if ( envid==0 ) {

		FORKDEBUG("fork: I am the child\n");
		sys_page_alloc(sys_getenvid(),(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P);

		thisenv=&envs[ENVX(sys_getenvid())];
		return envid;
	}	

	FORKDEBUG("fork: I am the parent\n");

//	while (pn<PGNUM(UXSTACKTOP-PGSIZE)) {
//		if ( pn*PGSIZE == (int) ROUNDDOWN(&r,PGSIZE)) {
//			FORKDEBUG("fork: r???\n");
//			pn++;
//			continue;
//		}
//		if ( (uvpd[PDX(pn<<PGSHIFT)]&PTE_P)==0 ) {
//			pn+=NPTENTRIES;
//			pn=ROUNDDOWN(pn,NPTENTRIES);
//			continue;
//		}
//		if (uvpt[pn] & PTE_P) {
//			duppage(envid,pn);
//		}
//		pn++;
//	}	

	for(i=PDX(UTEXT);i<PDX(UXSTACKTOP);i++ ) {
		if ( uvpd[i] & PTE_P ) {
			for ( j=0;j<NPTENTRIES;j++) {
		//		cprintf("i: %d, j:%d\n",i,j);
				pn=PGNUM(PGADDR(i,j,0));
				if ( pn== PGNUM(UXSTACKTOP-PGSIZE) ) {
					break;
				}
				if ( uvpt[pn] & PTE_P ) {
					duppage(envid,pn);
				}
			}
		}
	}
	FORKDEBUG("lib fork: after duppage\n");
	
	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_U | PTE_P | PTE_W)<0 ) {
		FORKDEBUG("lib fork: sys_page_alloc fail\n");
		return -1;
	}

	if (sys_page_map(envid,(void*)(UXSTACKTOP-PGSIZE),curenvid,PFTEMP, PTE_U | PTE_P | PTE_W)<0) {
		FORKDEBUG("lib fork: sys_page_map envid fail\n");
		return -1;
	}

	memmove((void*)(UXSTACKTOP-PGSIZE) , PFTEMP ,PGSIZE);
	
	if (sys_page_unmap(curenvid,PFTEMP)<0) {
		FORKDEBUG("lib fork: sys_page_map curenvid fail\n");
		return -1;
	}

	extern void _pgfault_upcall(void);

	if (sys_env_set_pgfault_upcall(envid,_pgfault_upcall)<0) {
		FORKDEBUG("lib fork: sys_env_set_pgfault_upcall fail\n");
		return -1;
	}

//	if (sys_page_alloc(envid,(void*)(UXSTACKTOP-PGSIZE),PTE_W | PTE_U | PTE_P)<0) {
//		FORKDEBUG("lib fork: sys_page_alloc fail\n");
//		return -1;
//	}		

	if (sys_env_set_status(envid, ENV_RUNNABLE)<0) {
		FORKDEBUG("lib fork: sys_env_set_status\n");
		return -1;
	}

	FORKDEBUG("lib fork: finish fork\n");

	return envid;
//	panic("fork not implemented");
}

// Challenge!
int
sfork(void)
{
	panic("sfork not implemented");
	return -E_INVAL;
}
