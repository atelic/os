# Declare constants for multiboot header
.set ALIGN, 1<<0					#align loaded modules on page bounds
.set MEMINFO, 1<<1					#provides memory map
.set FLAGS, ALIGN | MEMINFO			#the multiboot flag field
.set MAGIC, 0x1BADB002				#lets bootloader find the header
.set CHECKSUM, (-MAGIC + FLAGS)		#checksum to prove we are multiboot

# Declare a header as in the Multiboot Standard. We put this into a special
# section so we can force the header to be in the start of the final program.
# The bootloader will search for this magic sequence and
# recognize us as a multiboot kernel.

.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM

# Currently the stack pointer register points at anything and using it may
# cause massive harm. Instead, we'll provide our own stack. We will allocate
# room for a small temporary stack by creating a symbol at the bottom of it,
# then allocating 16384 bytes for it, and finally creating a symbol at the top.

.section .bootstrap_stack, "aw", @nobits
stack_bottom:
.skip 16384 # 16 KiB
stack_top:

# The linker script specifies _start as the entry point to the kernel and the
# bootloader will jump to this position once the kernel has been loaded. It
# doesn't make sense to return from this function as the bootloader is gone

.section .text
.global _start
.type _start @function
_start:

	# Welcome to kernel mode! We now have sufficient code for the bootloader to
	# load and run our operating system. It doesn't do anything interesting yet.

	#printf("Hello world!\n") if you will

	# To set up a stack, we simply set the esp (stack pointer) register to point to the top of
	# our stack (as it grows downwards)
	movl $stack_top, %esp

	# We are now ready to actually execute C code.
	# We call kernel_main in kernel.c 
	call kernel_main

	# In case the function returns, we'll want to put the computer into an
	# infinite loop. To do that, we use the clear interrupt ('cli') instruction
	# to disable interrupts, the halt instruction ('hlt') to stop the CPU until
	# the next interrupt arrives, and jumping to the halt instruction if it ever
	# continues execution, just to be safe. We will create a local label rather
	# than real symbol and jump to there endlessly.
	cli
	hlt

.Lhang:
	jmp .Lhang

# Set the size of the _start symbol to the current location '.' minus its start.
# This is useful when debugging or when you implement call tracing.
.size _start, . - _start

# assemble the boot.s with 
# i686-elf-as boot.s -o boot.o