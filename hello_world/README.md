# Hello World Kernel

A super basic kernel that puts the string hello world into the terminal after booting

It can be compiled as such:

```
i686-elf-gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
```

If you use the c++ kernel then you will need to use the c++ compiler instead

It can be made into a bootable .iso file by running the following commands:

```
	mkdir -p isodir
	mkdir -p isodir/boot
	cp myos.bin isodir/boot/myos.bin
	mkdir -p isodir/boot/grub
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o myos.iso isodir
```

If on linux, you can burn this to a bootable USB as such:

```
sudo dd if=myos.iso of=/dev/sdx && sync
```

where sdx is the location of the USB. Don't erase your hard disk!!


TODO:
	* Adding Support for Newlines to Terminal Driver
	* Implementing Terminal Scrolling
	* Rendering Colorful ASCII Art

