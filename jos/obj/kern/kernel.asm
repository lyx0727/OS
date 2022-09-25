
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
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 6c 00 00 00       	call   f01000aa <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	e8 7e 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010004e:	81 c3 ba 22 01 00    	add    $0x122ba,%ebx
f0100054:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100057:	83 ec 08             	sub    $0x8,%esp
f010005a:	56                   	push   %esi
f010005b:	8d 83 58 f9 fe ff    	lea    -0x106a8(%ebx),%eax
f0100061:	50                   	push   %eax
f0100062:	e8 23 0b 00 00       	call   f0100b8a <cprintf>
	if (x > 0)
f0100067:	83 c4 10             	add    $0x10,%esp
f010006a:	85 f6                	test   %esi,%esi
f010006c:	7e 29                	jle    f0100097 <test_backtrace+0x57>
		test_backtrace(x-1);
f010006e:	83 ec 0c             	sub    $0xc,%esp
f0100071:	8d 46 ff             	lea    -0x1(%esi),%eax
f0100074:	50                   	push   %eax
f0100075:	e8 c6 ff ff ff       	call   f0100040 <test_backtrace>
f010007a:	83 c4 10             	add    $0x10,%esp
	else
		mon_backtrace(0, 0, 0);
	cprintf("leaving test_backtrace %d\n", x);
f010007d:	83 ec 08             	sub    $0x8,%esp
f0100080:	56                   	push   %esi
f0100081:	8d 83 74 f9 fe ff    	lea    -0x1068c(%ebx),%eax
f0100087:	50                   	push   %eax
f0100088:	e8 fd 0a 00 00       	call   f0100b8a <cprintf>
}
f010008d:	83 c4 10             	add    $0x10,%esp
f0100090:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100093:	5b                   	pop    %ebx
f0100094:	5e                   	pop    %esi
f0100095:	5d                   	pop    %ebp
f0100096:	c3                   	ret    
		mon_backtrace(0, 0, 0);
f0100097:	83 ec 04             	sub    $0x4,%esp
f010009a:	6a 00                	push   $0x0
f010009c:	6a 00                	push   $0x0
f010009e:	6a 00                	push   $0x0
f01000a0:	e8 0c 08 00 00       	call   f01008b1 <mon_backtrace>
f01000a5:	83 c4 10             	add    $0x10,%esp
f01000a8:	eb d3                	jmp    f010007d <test_backtrace+0x3d>

f01000aa <i386_init>:

void
i386_init(void)
{
f01000aa:	f3 0f 1e fb          	endbr32 
f01000ae:	55                   	push   %ebp
f01000af:	89 e5                	mov    %esp,%ebp
f01000b1:	53                   	push   %ebx
f01000b2:	83 ec 08             	sub    $0x8,%esp
f01000b5:	e8 12 01 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f01000ba:	81 c3 4e 22 01 00    	add    $0x1224e,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000c0:	c7 c2 60 40 11 f0    	mov    $0xf0114060,%edx
f01000c6:	c7 c0 a0 46 11 f0    	mov    $0xf01146a0,%eax
f01000cc:	29 d0                	sub    %edx,%eax
f01000ce:	50                   	push   %eax
f01000cf:	6a 00                	push   $0x0
f01000d1:	52                   	push   %edx
f01000d2:	e8 15 17 00 00       	call   f01017ec <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d7:	e8 4b 05 00 00       	call   f0100627 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000dc:	83 c4 08             	add    $0x8,%esp
f01000df:	68 ac 1a 00 00       	push   $0x1aac
f01000e4:	8d 83 8f f9 fe ff    	lea    -0x10671(%ebx),%eax
f01000ea:	50                   	push   %eax
f01000eb:	e8 9a 0a 00 00       	call   f0100b8a <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000f0:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000f7:	e8 44 ff ff ff       	call   f0100040 <test_backtrace>
f01000fc:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ff:	83 ec 0c             	sub    $0xc,%esp
f0100102:	6a 00                	push   $0x0
f0100104:	e8 af 08 00 00       	call   f01009b8 <monitor>
f0100109:	83 c4 10             	add    $0x10,%esp
f010010c:	eb f1                	jmp    f01000ff <i386_init+0x55>

f010010e <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010010e:	f3 0f 1e fb          	endbr32 
f0100112:	55                   	push   %ebp
f0100113:	89 e5                	mov    %esp,%ebp
f0100115:	57                   	push   %edi
f0100116:	56                   	push   %esi
f0100117:	53                   	push   %ebx
f0100118:	83 ec 0c             	sub    $0xc,%esp
f010011b:	e8 ac 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100120:	81 c3 e8 21 01 00    	add    $0x121e8,%ebx
f0100126:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100129:	c7 c0 a4 46 11 f0    	mov    $0xf01146a4,%eax
f010012f:	83 38 00             	cmpl   $0x0,(%eax)
f0100132:	74 0f                	je     f0100143 <_panic+0x35>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100134:	83 ec 0c             	sub    $0xc,%esp
f0100137:	6a 00                	push   $0x0
f0100139:	e8 7a 08 00 00       	call   f01009b8 <monitor>
f010013e:	83 c4 10             	add    $0x10,%esp
f0100141:	eb f1                	jmp    f0100134 <_panic+0x26>
	panicstr = fmt;
f0100143:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100145:	fa                   	cli    
f0100146:	fc                   	cld    
	va_start(ap, fmt);
f0100147:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010014a:	83 ec 04             	sub    $0x4,%esp
f010014d:	ff 75 0c             	pushl  0xc(%ebp)
f0100150:	ff 75 08             	pushl  0x8(%ebp)
f0100153:	8d 83 aa f9 fe ff    	lea    -0x10656(%ebx),%eax
f0100159:	50                   	push   %eax
f010015a:	e8 2b 0a 00 00       	call   f0100b8a <cprintf>
	vcprintf(fmt, ap);
f010015f:	83 c4 08             	add    $0x8,%esp
f0100162:	56                   	push   %esi
f0100163:	57                   	push   %edi
f0100164:	e8 e6 09 00 00       	call   f0100b4f <vcprintf>
	cprintf("\n");
f0100169:	8d 83 e6 f9 fe ff    	lea    -0x1061a(%ebx),%eax
f010016f:	89 04 24             	mov    %eax,(%esp)
f0100172:	e8 13 0a 00 00       	call   f0100b8a <cprintf>
f0100177:	83 c4 10             	add    $0x10,%esp
f010017a:	eb b8                	jmp    f0100134 <_panic+0x26>

f010017c <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010017c:	f3 0f 1e fb          	endbr32 
f0100180:	55                   	push   %ebp
f0100181:	89 e5                	mov    %esp,%ebp
f0100183:	56                   	push   %esi
f0100184:	53                   	push   %ebx
f0100185:	e8 42 00 00 00       	call   f01001cc <__x86.get_pc_thunk.bx>
f010018a:	81 c3 7e 21 01 00    	add    $0x1217e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100190:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100193:	83 ec 04             	sub    $0x4,%esp
f0100196:	ff 75 0c             	pushl  0xc(%ebp)
f0100199:	ff 75 08             	pushl  0x8(%ebp)
f010019c:	8d 83 c2 f9 fe ff    	lea    -0x1063e(%ebx),%eax
f01001a2:	50                   	push   %eax
f01001a3:	e8 e2 09 00 00       	call   f0100b8a <cprintf>
	vcprintf(fmt, ap);
f01001a8:	83 c4 08             	add    $0x8,%esp
f01001ab:	56                   	push   %esi
f01001ac:	ff 75 10             	pushl  0x10(%ebp)
f01001af:	e8 9b 09 00 00       	call   f0100b4f <vcprintf>
	cprintf("\n");
f01001b4:	8d 83 e6 f9 fe ff    	lea    -0x1061a(%ebx),%eax
f01001ba:	89 04 24             	mov    %eax,(%esp)
f01001bd:	e8 c8 09 00 00       	call   f0100b8a <cprintf>
	va_end(ap);
}
f01001c2:	83 c4 10             	add    $0x10,%esp
f01001c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001c8:	5b                   	pop    %ebx
f01001c9:	5e                   	pop    %esi
f01001ca:	5d                   	pop    %ebp
f01001cb:	c3                   	ret    

f01001cc <__x86.get_pc_thunk.bx>:
f01001cc:	8b 1c 24             	mov    (%esp),%ebx
f01001cf:	c3                   	ret    

f01001d0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001d0:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001d4:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001d9:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001da:	a8 01                	test   $0x1,%al
f01001dc:	74 0a                	je     f01001e8 <serial_proc_data+0x18>
f01001de:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001e3:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001e4:	0f b6 c0             	movzbl %al,%eax
f01001e7:	c3                   	ret    
		return -1;
f01001e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001ed:	c3                   	ret    

f01001ee <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001ee:	55                   	push   %ebp
f01001ef:	89 e5                	mov    %esp,%ebp
f01001f1:	57                   	push   %edi
f01001f2:	56                   	push   %esi
f01001f3:	53                   	push   %ebx
f01001f4:	83 ec 1c             	sub    $0x1c,%esp
f01001f7:	e8 88 05 00 00       	call   f0100784 <__x86.get_pc_thunk.si>
f01001fc:	81 c6 0c 21 01 00    	add    $0x1210c,%esi
f0100202:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100204:	8d 1d 78 1d 00 00    	lea    0x1d78,%ebx
f010020a:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010020d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100210:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100213:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100216:	ff d0                	call   *%eax
f0100218:	83 f8 ff             	cmp    $0xffffffff,%eax
f010021b:	74 2b                	je     f0100248 <cons_intr+0x5a>
		if (c == 0)
f010021d:	85 c0                	test   %eax,%eax
f010021f:	74 f2                	je     f0100213 <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f0100221:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100228:	8d 51 01             	lea    0x1(%ecx),%edx
f010022b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010022e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100231:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100237:	b8 00 00 00 00       	mov    $0x0,%eax
f010023c:	0f 44 d0             	cmove  %eax,%edx
f010023f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100246:	eb cb                	jmp    f0100213 <cons_intr+0x25>
	}
}
f0100248:	83 c4 1c             	add    $0x1c,%esp
f010024b:	5b                   	pop    %ebx
f010024c:	5e                   	pop    %esi
f010024d:	5f                   	pop    %edi
f010024e:	5d                   	pop    %ebp
f010024f:	c3                   	ret    

f0100250 <kbd_proc_data>:
{
f0100250:	f3 0f 1e fb          	endbr32 
f0100254:	55                   	push   %ebp
f0100255:	89 e5                	mov    %esp,%ebp
f0100257:	56                   	push   %esi
f0100258:	53                   	push   %ebx
f0100259:	e8 6e ff ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010025e:	81 c3 aa 20 01 00    	add    $0x120aa,%ebx
f0100264:	ba 64 00 00 00       	mov    $0x64,%edx
f0100269:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010026a:	a8 01                	test   $0x1,%al
f010026c:	0f 84 fb 00 00 00    	je     f010036d <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f0100272:	a8 20                	test   $0x20,%al
f0100274:	0f 85 fa 00 00 00    	jne    f0100374 <kbd_proc_data+0x124>
f010027a:	ba 60 00 00 00       	mov    $0x60,%edx
f010027f:	ec                   	in     (%dx),%al
f0100280:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100282:	3c e0                	cmp    $0xe0,%al
f0100284:	74 64                	je     f01002ea <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100286:	84 c0                	test   %al,%al
f0100288:	78 75                	js     f01002ff <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f010028a:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100290:	f6 c1 40             	test   $0x40,%cl
f0100293:	74 0e                	je     f01002a3 <kbd_proc_data+0x53>
		data |= 0x80;
f0100295:	83 c8 80             	or     $0xffffff80,%eax
f0100298:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010029a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010029d:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f01002a3:	0f b6 d2             	movzbl %dl,%edx
f01002a6:	0f b6 84 13 18 fb fe 	movzbl -0x104e8(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f01002b4:	0f b6 8c 13 18 fa fe 	movzbl -0x105e8(%ebx,%edx,1),%ecx
f01002bb:	ff 
f01002bc:	31 c8                	xor    %ecx,%eax
f01002be:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002c4:	89 c1                	mov    %eax,%ecx
f01002c6:	83 e1 03             	and    $0x3,%ecx
f01002c9:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002d0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002d4:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002d7:	a8 08                	test   $0x8,%al
f01002d9:	74 65                	je     f0100340 <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f01002db:	89 f2                	mov    %esi,%edx
f01002dd:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002e0:	83 f9 19             	cmp    $0x19,%ecx
f01002e3:	77 4f                	ja     f0100334 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01002e5:	83 ee 20             	sub    $0x20,%esi
f01002e8:	eb 0c                	jmp    f01002f6 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01002ea:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002f1:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002f6:	89 f0                	mov    %esi,%eax
f01002f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002fb:	5b                   	pop    %ebx
f01002fc:	5e                   	pop    %esi
f01002fd:	5d                   	pop    %ebp
f01002fe:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ff:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100305:	89 ce                	mov    %ecx,%esi
f0100307:	83 e6 40             	and    $0x40,%esi
f010030a:	83 e0 7f             	and    $0x7f,%eax
f010030d:	85 f6                	test   %esi,%esi
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 84 13 18 fb fe 	movzbl -0x104e8(%ebx,%edx,1),%eax
f010031c:	ff 
f010031d:	83 c8 40             	or     $0x40,%eax
f0100320:	0f b6 c0             	movzbl %al,%eax
f0100323:	f7 d0                	not    %eax
f0100325:	21 c8                	and    %ecx,%eax
f0100327:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f010032d:	be 00 00 00 00       	mov    $0x0,%esi
f0100332:	eb c2                	jmp    f01002f6 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100334:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100337:	8d 4e 20             	lea    0x20(%esi),%ecx
f010033a:	83 fa 1a             	cmp    $0x1a,%edx
f010033d:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100340:	f7 d0                	not    %eax
f0100342:	a8 06                	test   $0x6,%al
f0100344:	75 b0                	jne    f01002f6 <kbd_proc_data+0xa6>
f0100346:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010034c:	75 a8                	jne    f01002f6 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010034e:	83 ec 0c             	sub    $0xc,%esp
f0100351:	8d 83 dc f9 fe ff    	lea    -0x10624(%ebx),%eax
f0100357:	50                   	push   %eax
f0100358:	e8 2d 08 00 00       	call   f0100b8a <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100362:	ba 92 00 00 00       	mov    $0x92,%edx
f0100367:	ee                   	out    %al,(%dx)
}
f0100368:	83 c4 10             	add    $0x10,%esp
f010036b:	eb 89                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f010036d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100372:	eb 82                	jmp    f01002f6 <kbd_proc_data+0xa6>
		return -1;
f0100374:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100379:	e9 78 ff ff ff       	jmp    f01002f6 <kbd_proc_data+0xa6>

f010037e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010037e:	55                   	push   %ebp
f010037f:	89 e5                	mov    %esp,%ebp
f0100381:	57                   	push   %edi
f0100382:	56                   	push   %esi
f0100383:	53                   	push   %ebx
f0100384:	83 ec 1c             	sub    $0x1c,%esp
f0100387:	e8 40 fe ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010038c:	81 c3 7c 1f 01 00    	add    $0x11f7c,%ebx
f0100392:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100394:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100399:	b9 84 00 00 00       	mov    $0x84,%ecx
f010039e:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003a3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003a4:	a8 20                	test   $0x20,%al
f01003a6:	75 13                	jne    f01003bb <cons_putc+0x3d>
f01003a8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ae:	7f 0b                	jg     f01003bb <cons_putc+0x3d>
f01003b0:	89 ca                	mov    %ecx,%edx
f01003b2:	ec                   	in     (%dx),%al
f01003b3:	ec                   	in     (%dx),%al
f01003b4:	ec                   	in     (%dx),%al
f01003b5:	ec                   	in     (%dx),%al
	     i++)
f01003b6:	83 c6 01             	add    $0x1,%esi
f01003b9:	eb e3                	jmp    f010039e <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01003bb:	89 f8                	mov    %edi,%eax
f01003bd:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003c5:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003c6:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003cb:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003d0:	ba 79 03 00 00       	mov    $0x379,%edx
f01003d5:	ec                   	in     (%dx),%al
f01003d6:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003dc:	7f 0f                	jg     f01003ed <cons_putc+0x6f>
f01003de:	84 c0                	test   %al,%al
f01003e0:	78 0b                	js     f01003ed <cons_putc+0x6f>
f01003e2:	89 ca                	mov    %ecx,%edx
f01003e4:	ec                   	in     (%dx),%al
f01003e5:	ec                   	in     (%dx),%al
f01003e6:	ec                   	in     (%dx),%al
f01003e7:	ec                   	in     (%dx),%al
f01003e8:	83 c6 01             	add    $0x1,%esi
f01003eb:	eb e3                	jmp    f01003d0 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ed:	ba 78 03 00 00       	mov    $0x378,%edx
f01003f2:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003f6:	ee                   	out    %al,(%dx)
f01003f7:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003fc:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100401:	ee                   	out    %al,(%dx)
f0100402:	b8 08 00 00 00       	mov    $0x8,%eax
f0100407:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100408:	89 f8                	mov    %edi,%eax
f010040a:	80 cc 07             	or     $0x7,%ah
f010040d:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100413:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100416:	89 f8                	mov    %edi,%eax
f0100418:	0f b6 c0             	movzbl %al,%eax
f010041b:	89 f9                	mov    %edi,%ecx
f010041d:	80 f9 0a             	cmp    $0xa,%cl
f0100420:	0f 84 e2 00 00 00    	je     f0100508 <cons_putc+0x18a>
f0100426:	83 f8 0a             	cmp    $0xa,%eax
f0100429:	7f 46                	jg     f0100471 <cons_putc+0xf3>
f010042b:	83 f8 08             	cmp    $0x8,%eax
f010042e:	0f 84 a8 00 00 00    	je     f01004dc <cons_putc+0x15e>
f0100434:	83 f8 09             	cmp    $0x9,%eax
f0100437:	0f 85 d8 00 00 00    	jne    f0100515 <cons_putc+0x197>
		cons_putc(' ');
f010043d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100442:	e8 37 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100447:	b8 20 00 00 00       	mov    $0x20,%eax
f010044c:	e8 2d ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100451:	b8 20 00 00 00       	mov    $0x20,%eax
f0100456:	e8 23 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f010045b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100460:	e8 19 ff ff ff       	call   f010037e <cons_putc>
		cons_putc(' ');
f0100465:	b8 20 00 00 00       	mov    $0x20,%eax
f010046a:	e8 0f ff ff ff       	call   f010037e <cons_putc>
		break;
f010046f:	eb 26                	jmp    f0100497 <cons_putc+0x119>
	switch (c & 0xff) {
f0100471:	83 f8 0d             	cmp    $0xd,%eax
f0100474:	0f 85 9b 00 00 00    	jne    f0100515 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f010047a:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100481:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100487:	c1 e8 16             	shr    $0x16,%eax
f010048a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010048d:	c1 e0 04             	shl    $0x4,%eax
f0100490:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100497:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010049e:	cf 07 
f01004a0:	0f 87 92 00 00 00    	ja     f0100538 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f01004a6:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01004ac:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b1:	89 ca                	mov    %ecx,%edx
f01004b3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b4:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01004bb:	8d 71 01             	lea    0x1(%ecx),%esi
f01004be:	89 d8                	mov    %ebx,%eax
f01004c0:	66 c1 e8 08          	shr    $0x8,%ax
f01004c4:	89 f2                	mov    %esi,%edx
f01004c6:	ee                   	out    %al,(%dx)
f01004c7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cc:	89 ca                	mov    %ecx,%edx
f01004ce:	ee                   	out    %al,(%dx)
f01004cf:	89 d8                	mov    %ebx,%eax
f01004d1:	89 f2                	mov    %esi,%edx
f01004d3:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d7:	5b                   	pop    %ebx
f01004d8:	5e                   	pop    %esi
f01004d9:	5f                   	pop    %edi
f01004da:	5d                   	pop    %ebp
f01004db:	c3                   	ret    
		if (crt_pos > 0) {
f01004dc:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004e3:	66 85 c0             	test   %ax,%ax
f01004e6:	74 be                	je     f01004a6 <cons_putc+0x128>
			crt_pos--;
f01004e8:	83 e8 01             	sub    $0x1,%eax
f01004eb:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004f2:	0f b7 c0             	movzwl %ax,%eax
f01004f5:	89 fa                	mov    %edi,%edx
f01004f7:	b2 00                	mov    $0x0,%dl
f01004f9:	83 ca 20             	or     $0x20,%edx
f01004fc:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f0100502:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100506:	eb 8f                	jmp    f0100497 <cons_putc+0x119>
		crt_pos += CRT_COLS;
f0100508:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f010050f:	50 
f0100510:	e9 65 ff ff ff       	jmp    f010047a <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100515:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010051c:	8d 50 01             	lea    0x1(%eax),%edx
f010051f:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100526:	0f b7 c0             	movzwl %ax,%eax
f0100529:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010052f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100533:	e9 5f ff ff ff       	jmp    f0100497 <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100538:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010053e:	83 ec 04             	sub    $0x4,%esp
f0100541:	68 00 0f 00 00       	push   $0xf00
f0100546:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010054c:	52                   	push   %edx
f010054d:	50                   	push   %eax
f010054e:	e8 e5 12 00 00       	call   f0101838 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100553:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100559:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010055f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100565:	83 c4 10             	add    $0x10,%esp
f0100568:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010056d:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100570:	39 d0                	cmp    %edx,%eax
f0100572:	75 f4                	jne    f0100568 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100574:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010057b:	50 
f010057c:	e9 25 ff ff ff       	jmp    f01004a6 <cons_putc+0x128>

f0100581 <serial_intr>:
{
f0100581:	f3 0f 1e fb          	endbr32 
f0100585:	e8 f6 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f010058a:	05 7e 1d 01 00       	add    $0x11d7e,%eax
	if (serial_exists)
f010058f:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100596:	75 01                	jne    f0100599 <serial_intr+0x18>
f0100598:	c3                   	ret    
{
f0100599:	55                   	push   %ebp
f010059a:	89 e5                	mov    %esp,%ebp
f010059c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010059f:	8d 80 c8 de fe ff    	lea    -0x12138(%eax),%eax
f01005a5:	e8 44 fc ff ff       	call   f01001ee <cons_intr>
}
f01005aa:	c9                   	leave  
f01005ab:	c3                   	ret    

f01005ac <kbd_intr>:
{
f01005ac:	f3 0f 1e fb          	endbr32 
f01005b0:	55                   	push   %ebp
f01005b1:	89 e5                	mov    %esp,%ebp
f01005b3:	83 ec 08             	sub    $0x8,%esp
f01005b6:	e8 c5 01 00 00       	call   f0100780 <__x86.get_pc_thunk.ax>
f01005bb:	05 4d 1d 01 00       	add    $0x11d4d,%eax
	cons_intr(kbd_proc_data);
f01005c0:	8d 80 48 df fe ff    	lea    -0x120b8(%eax),%eax
f01005c6:	e8 23 fc ff ff       	call   f01001ee <cons_intr>
}
f01005cb:	c9                   	leave  
f01005cc:	c3                   	ret    

f01005cd <cons_getc>:
{
f01005cd:	f3 0f 1e fb          	endbr32 
f01005d1:	55                   	push   %ebp
f01005d2:	89 e5                	mov    %esp,%ebp
f01005d4:	53                   	push   %ebx
f01005d5:	83 ec 04             	sub    $0x4,%esp
f01005d8:	e8 ef fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01005dd:	81 c3 2b 1d 01 00    	add    $0x11d2b,%ebx
	serial_intr();
f01005e3:	e8 99 ff ff ff       	call   f0100581 <serial_intr>
	kbd_intr();
f01005e8:	e8 bf ff ff ff       	call   f01005ac <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005ed:	8b 83 78 1f 00 00    	mov    0x1f78(%ebx),%eax
	return 0;
f01005f3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005f8:	3b 83 7c 1f 00 00    	cmp    0x1f7c(%ebx),%eax
f01005fe:	74 1f                	je     f010061f <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f0100600:	8d 48 01             	lea    0x1(%eax),%ecx
f0100603:	0f b6 94 03 78 1d 00 	movzbl 0x1d78(%ebx,%eax,1),%edx
f010060a:	00 
			cons.rpos = 0;
f010060b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100611:	b8 00 00 00 00       	mov    $0x0,%eax
f0100616:	0f 44 c8             	cmove  %eax,%ecx
f0100619:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
}
f010061f:	89 d0                	mov    %edx,%eax
f0100621:	83 c4 04             	add    $0x4,%esp
f0100624:	5b                   	pop    %ebx
f0100625:	5d                   	pop    %ebp
f0100626:	c3                   	ret    

f0100627 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100627:	f3 0f 1e fb          	endbr32 
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	57                   	push   %edi
f010062f:	56                   	push   %esi
f0100630:	53                   	push   %ebx
f0100631:	83 ec 1c             	sub    $0x1c,%esp
f0100634:	e8 93 fb ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100639:	81 c3 cf 1c 01 00    	add    $0x11ccf,%ebx
	was = *cp;
f010063f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100646:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010064d:	5a a5 
	if (*cp != 0xA55A) {
f010064f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100656:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010065a:	0f 84 bc 00 00 00    	je     f010071c <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f0100660:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f0100667:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066a:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100671:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f0100677:	b8 0e 00 00 00       	mov    $0xe,%eax
f010067c:	89 fa                	mov    %edi,%edx
f010067e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010067f:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100682:	89 ca                	mov    %ecx,%edx
f0100684:	ec                   	in     (%dx),%al
f0100685:	0f b6 f0             	movzbl %al,%esi
f0100688:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010068b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100690:	89 fa                	mov    %edi,%edx
f0100692:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100693:	89 ca                	mov    %ecx,%edx
f0100695:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100699:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f010069f:	0f b6 c0             	movzbl %al,%eax
f01006a2:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f01006a4:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006ab:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006b0:	89 c8                	mov    %ecx,%eax
f01006b2:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006b7:	ee                   	out    %al,(%dx)
f01006b8:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006bd:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006c2:	89 fa                	mov    %edi,%edx
f01006c4:	ee                   	out    %al,(%dx)
f01006c5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ca:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006d5:	89 c8                	mov    %ecx,%eax
f01006d7:	89 f2                	mov    %esi,%edx
f01006d9:	ee                   	out    %al,(%dx)
f01006da:	b8 03 00 00 00       	mov    $0x3,%eax
f01006df:	89 fa                	mov    %edi,%edx
f01006e1:	ee                   	out    %al,(%dx)
f01006e2:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006e7:	89 c8                	mov    %ecx,%eax
f01006e9:	ee                   	out    %al,(%dx)
f01006ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ef:	89 f2                	mov    %esi,%edx
f01006f1:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006f2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006f7:	ec                   	in     (%dx),%al
f01006f8:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006fa:	3c ff                	cmp    $0xff,%al
f01006fc:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f0100703:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100708:	ec                   	in     (%dx),%al
f0100709:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010070e:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010070f:	80 f9 ff             	cmp    $0xff,%cl
f0100712:	74 25                	je     f0100739 <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f0100714:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100717:	5b                   	pop    %ebx
f0100718:	5e                   	pop    %esi
f0100719:	5f                   	pop    %edi
f010071a:	5d                   	pop    %ebp
f010071b:	c3                   	ret    
		*cp = was;
f010071c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100723:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f010072a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010072d:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100734:	e9 38 ff ff ff       	jmp    f0100671 <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f0100739:	83 ec 0c             	sub    $0xc,%esp
f010073c:	8d 83 e8 f9 fe ff    	lea    -0x10618(%ebx),%eax
f0100742:	50                   	push   %eax
f0100743:	e8 42 04 00 00       	call   f0100b8a <cprintf>
f0100748:	83 c4 10             	add    $0x10,%esp
}
f010074b:	eb c7                	jmp    f0100714 <cons_init+0xed>

f010074d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010074d:	f3 0f 1e fb          	endbr32 
f0100751:	55                   	push   %ebp
f0100752:	89 e5                	mov    %esp,%ebp
f0100754:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100757:	8b 45 08             	mov    0x8(%ebp),%eax
f010075a:	e8 1f fc ff ff       	call   f010037e <cons_putc>
}
f010075f:	c9                   	leave  
f0100760:	c3                   	ret    

f0100761 <getchar>:

int
getchar(void)
{
f0100761:	f3 0f 1e fb          	endbr32 
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076b:	e8 5d fe ff ff       	call   f01005cd <cons_getc>
f0100770:	85 c0                	test   %eax,%eax
f0100772:	74 f7                	je     f010076b <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100774:	c9                   	leave  
f0100775:	c3                   	ret    

f0100776 <iscons>:

int
iscons(int fdnum)
{
f0100776:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010077a:	b8 01 00 00 00       	mov    $0x1,%eax
f010077f:	c3                   	ret    

f0100780 <__x86.get_pc_thunk.ax>:
f0100780:	8b 04 24             	mov    (%esp),%eax
f0100783:	c3                   	ret    

f0100784 <__x86.get_pc_thunk.si>:
f0100784:	8b 34 24             	mov    (%esp),%esi
f0100787:	c3                   	ret    

f0100788 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100788:	f3 0f 1e fb          	endbr32 
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	56                   	push   %esi
f0100790:	53                   	push   %ebx
f0100791:	e8 36 fa ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100796:	81 c3 72 1b 01 00    	add    $0x11b72,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079c:	83 ec 04             	sub    $0x4,%esp
f010079f:	8d 83 18 fc fe ff    	lea    -0x103e8(%ebx),%eax
f01007a5:	50                   	push   %eax
f01007a6:	8d 83 36 fc fe ff    	lea    -0x103ca(%ebx),%eax
f01007ac:	50                   	push   %eax
f01007ad:	8d b3 3b fc fe ff    	lea    -0x103c5(%ebx),%esi
f01007b3:	56                   	push   %esi
f01007b4:	e8 d1 03 00 00       	call   f0100b8a <cprintf>
f01007b9:	83 c4 0c             	add    $0xc,%esp
f01007bc:	8d 83 c8 fc fe ff    	lea    -0x10338(%ebx),%eax
f01007c2:	50                   	push   %eax
f01007c3:	8d 83 44 fc fe ff    	lea    -0x103bc(%ebx),%eax
f01007c9:	50                   	push   %eax
f01007ca:	56                   	push   %esi
f01007cb:	e8 ba 03 00 00       	call   f0100b8a <cprintf>
	return 0;
}
f01007d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007d8:	5b                   	pop    %ebx
f01007d9:	5e                   	pop    %esi
f01007da:	5d                   	pop    %ebp
f01007db:	c3                   	ret    

f01007dc <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007dc:	f3 0f 1e fb          	endbr32 
f01007e0:	55                   	push   %ebp
f01007e1:	89 e5                	mov    %esp,%ebp
f01007e3:	57                   	push   %edi
f01007e4:	56                   	push   %esi
f01007e5:	53                   	push   %ebx
f01007e6:	83 ec 18             	sub    $0x18,%esp
f01007e9:	e8 de f9 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01007ee:	81 c3 1a 1b 01 00    	add    $0x11b1a,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f4:	8d 83 4d fc fe ff    	lea    -0x103b3(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 8a 03 00 00       	call   f0100b8a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100800:	83 c4 08             	add    $0x8,%esp
f0100803:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100809:	8d 83 f0 fc fe ff    	lea    -0x10310(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 75 03 00 00       	call   f0100b8a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100815:	83 c4 0c             	add    $0xc,%esp
f0100818:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010081e:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100824:	50                   	push   %eax
f0100825:	57                   	push   %edi
f0100826:	8d 83 18 fd fe ff    	lea    -0x102e8(%ebx),%eax
f010082c:	50                   	push   %eax
f010082d:	e8 58 03 00 00       	call   f0100b8a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100832:	83 c4 0c             	add    $0xc,%esp
f0100835:	c7 c0 5d 1c 10 f0    	mov    $0xf0101c5d,%eax
f010083b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100841:	52                   	push   %edx
f0100842:	50                   	push   %eax
f0100843:	8d 83 3c fd fe ff    	lea    -0x102c4(%ebx),%eax
f0100849:	50                   	push   %eax
f010084a:	e8 3b 03 00 00       	call   f0100b8a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084f:	83 c4 0c             	add    $0xc,%esp
f0100852:	c7 c0 60 40 11 f0    	mov    $0xf0114060,%eax
f0100858:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010085e:	52                   	push   %edx
f010085f:	50                   	push   %eax
f0100860:	8d 83 60 fd fe ff    	lea    -0x102a0(%ebx),%eax
f0100866:	50                   	push   %eax
f0100867:	e8 1e 03 00 00       	call   f0100b8a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	c7 c6 a0 46 11 f0    	mov    $0xf01146a0,%esi
f0100875:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010087b:	50                   	push   %eax
f010087c:	56                   	push   %esi
f010087d:	8d 83 84 fd fe ff    	lea    -0x1027c(%ebx),%eax
f0100883:	50                   	push   %eax
f0100884:	e8 01 03 00 00       	call   f0100b8a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100889:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088c:	29 fe                	sub    %edi,%esi
f010088e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100894:	c1 fe 0a             	sar    $0xa,%esi
f0100897:	56                   	push   %esi
f0100898:	8d 83 a8 fd fe ff    	lea    -0x10258(%ebx),%eax
f010089e:	50                   	push   %eax
f010089f:	e8 e6 02 00 00       	call   f0100b8a <cprintf>
	return 0;
}
f01008a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008ac:	5b                   	pop    %ebx
f01008ad:	5e                   	pop    %esi
f01008ae:	5f                   	pop    %edi
f01008af:	5d                   	pop    %ebp
f01008b0:	c3                   	ret    

f01008b1 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008b1:	f3 0f 1e fb          	endbr32 
f01008b5:	55                   	push   %ebp
f01008b6:	89 e5                	mov    %esp,%ebp
f01008b8:	57                   	push   %edi
f01008b9:	56                   	push   %esi
f01008ba:	53                   	push   %ebx
f01008bb:	83 ec 40             	sub    $0x40,%esp
f01008be:	e8 09 f9 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01008c3:	81 c3 45 1a 01 00    	add    $0x11a45,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008c9:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f01008cb:	89 c7                	mov    %eax,%edi
	struct Eipdebuginfo info;
	memset(&info, 0, sizeof(struct Eipdebuginfo));
f01008cd:	6a 18                	push   $0x18
f01008cf:	6a 00                	push   $0x0
f01008d1:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008d4:	50                   	push   %eax
f01008d5:	e8 12 0f 00 00       	call   f01017ec <memset>
	int i;
	while(ebp){
f01008da:	83 c4 10             	add    $0x10,%esp
		uint32_t eip = *(ebp + 1);
		cprintf("ebp %08x eip %08x args", ebp, eip);
f01008dd:	8d 83 66 fc fe ff    	lea    -0x1039a(%ebx),%eax
f01008e3:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for(i = 0; i < 4; i++){
			cprintf(" %08x", *(ebp + 2 + i));
f01008e6:	8d 83 7d fc fe ff    	lea    -0x10383(%ebx),%eax
f01008ec:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while(ebp){
f01008ef:	eb 02                	jmp    f01008f3 <mon_backtrace+0x42>
			cprintf("%s:%d: ", info.eip_file, info.eip_line);
			cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
			cprintf("+%d", eip - info.eip_fn_addr);
			cprintf("\n");
		}
		ebp = (uint32_t*)(*ebp);
f01008f1:	8b 3f                	mov    (%edi),%edi
	while(ebp){
f01008f3:	85 ff                	test   %edi,%edi
f01008f5:	0f 84 b0 00 00 00    	je     f01009ab <mon_backtrace+0xfa>
		uint32_t eip = *(ebp + 1);
f01008fb:	8b 47 04             	mov    0x4(%edi),%eax
f01008fe:	89 45 c0             	mov    %eax,-0x40(%ebp)
		cprintf("ebp %08x eip %08x args", ebp, eip);
f0100901:	83 ec 04             	sub    $0x4,%esp
f0100904:	50                   	push   %eax
f0100905:	57                   	push   %edi
f0100906:	ff 75 bc             	pushl  -0x44(%ebp)
f0100909:	e8 7c 02 00 00       	call   f0100b8a <cprintf>
f010090e:	83 c4 10             	add    $0x10,%esp
		for(i = 0; i < 4; i++){
f0100911:	be 00 00 00 00       	mov    $0x0,%esi
			cprintf(" %08x", *(ebp + 2 + i));
f0100916:	83 ec 08             	sub    $0x8,%esp
f0100919:	ff 74 b7 08          	pushl  0x8(%edi,%esi,4)
f010091d:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100920:	e8 65 02 00 00       	call   f0100b8a <cprintf>
		for(i = 0; i < 4; i++){
f0100925:	83 c6 01             	add    $0x1,%esi
f0100928:	83 c4 10             	add    $0x10,%esp
f010092b:	83 fe 04             	cmp    $0x4,%esi
f010092e:	75 e6                	jne    f0100916 <mon_backtrace+0x65>
		cprintf("\n");
f0100930:	83 ec 0c             	sub    $0xc,%esp
f0100933:	8d 83 e6 f9 fe ff    	lea    -0x1061a(%ebx),%eax
f0100939:	50                   	push   %eax
f010093a:	e8 4b 02 00 00       	call   f0100b8a <cprintf>
		if(debuginfo_eip(eip, &info) == 0){
f010093f:	83 c4 08             	add    $0x8,%esp
f0100942:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100945:	50                   	push   %eax
f0100946:	ff 75 c0             	pushl  -0x40(%ebp)
f0100949:	e8 49 03 00 00       	call   f0100c97 <debuginfo_eip>
f010094e:	83 c4 10             	add    $0x10,%esp
f0100951:	85 c0                	test   %eax,%eax
f0100953:	75 9c                	jne    f01008f1 <mon_backtrace+0x40>
			cprintf("%s:%d: ", info.eip_file, info.eip_line);
f0100955:	83 ec 04             	sub    $0x4,%esp
f0100958:	ff 75 d4             	pushl  -0x2c(%ebp)
f010095b:	ff 75 d0             	pushl  -0x30(%ebp)
f010095e:	8d 83 ba f9 fe ff    	lea    -0x10646(%ebx),%eax
f0100964:	50                   	push   %eax
f0100965:	e8 20 02 00 00       	call   f0100b8a <cprintf>
			cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
f010096a:	83 c4 0c             	add    $0xc,%esp
f010096d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100970:	ff 75 dc             	pushl  -0x24(%ebp)
f0100973:	8d 83 83 fc fe ff    	lea    -0x1037d(%ebx),%eax
f0100979:	50                   	push   %eax
f010097a:	e8 0b 02 00 00       	call   f0100b8a <cprintf>
			cprintf("+%d", eip - info.eip_fn_addr);
f010097f:	83 c4 08             	add    $0x8,%esp
f0100982:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100985:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100988:	50                   	push   %eax
f0100989:	8d 83 88 fc fe ff    	lea    -0x10378(%ebx),%eax
f010098f:	50                   	push   %eax
f0100990:	e8 f5 01 00 00       	call   f0100b8a <cprintf>
			cprintf("\n");
f0100995:	8d 83 e6 f9 fe ff    	lea    -0x1061a(%ebx),%eax
f010099b:	89 04 24             	mov    %eax,(%esp)
f010099e:	e8 e7 01 00 00       	call   f0100b8a <cprintf>
f01009a3:	83 c4 10             	add    $0x10,%esp
f01009a6:	e9 46 ff ff ff       	jmp    f01008f1 <mon_backtrace+0x40>
	}
	return 0;
}
f01009ab:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009b3:	5b                   	pop    %ebx
f01009b4:	5e                   	pop    %esi
f01009b5:	5f                   	pop    %edi
f01009b6:	5d                   	pop    %ebp
f01009b7:	c3                   	ret    

f01009b8 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009b8:	f3 0f 1e fb          	endbr32 
f01009bc:	55                   	push   %ebp
f01009bd:	89 e5                	mov    %esp,%ebp
f01009bf:	57                   	push   %edi
f01009c0:	56                   	push   %esi
f01009c1:	53                   	push   %ebx
f01009c2:	83 ec 68             	sub    $0x68,%esp
f01009c5:	e8 02 f8 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01009ca:	81 c3 3e 19 01 00    	add    $0x1193e,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009d0:	8d 83 d4 fd fe ff    	lea    -0x1022c(%ebx),%eax
f01009d6:	50                   	push   %eax
f01009d7:	e8 ae 01 00 00       	call   f0100b8a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01009dc:	8d 83 f8 fd fe ff    	lea    -0x10208(%ebx),%eax
f01009e2:	89 04 24             	mov    %eax,(%esp)
f01009e5:	e8 a0 01 00 00       	call   f0100b8a <cprintf>
f01009ea:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01009ed:	8d 83 90 fc fe ff    	lea    -0x10370(%ebx),%eax
f01009f3:	89 45 a0             	mov    %eax,-0x60(%ebp)
f01009f6:	e9 dc 00 00 00       	jmp    f0100ad7 <monitor+0x11f>
f01009fb:	83 ec 08             	sub    $0x8,%esp
f01009fe:	0f be c0             	movsbl %al,%eax
f0100a01:	50                   	push   %eax
f0100a02:	ff 75 a0             	pushl  -0x60(%ebp)
f0100a05:	e8 9d 0d 00 00       	call   f01017a7 <strchr>
f0100a0a:	83 c4 10             	add    $0x10,%esp
f0100a0d:	85 c0                	test   %eax,%eax
f0100a0f:	74 74                	je     f0100a85 <monitor+0xcd>
			*buf++ = 0;
f0100a11:	c6 06 00             	movb   $0x0,(%esi)
f0100a14:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100a17:	8d 76 01             	lea    0x1(%esi),%esi
f0100a1a:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a1d:	0f b6 06             	movzbl (%esi),%eax
f0100a20:	84 c0                	test   %al,%al
f0100a22:	75 d7                	jne    f01009fb <monitor+0x43>
	argv[argc] = 0;
f0100a24:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100a2b:	00 
	if (argc == 0)
f0100a2c:	85 ff                	test   %edi,%edi
f0100a2e:	0f 84 a3 00 00 00    	je     f0100ad7 <monitor+0x11f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a34:	83 ec 08             	sub    $0x8,%esp
f0100a37:	8d 83 36 fc fe ff    	lea    -0x103ca(%ebx),%eax
f0100a3d:	50                   	push   %eax
f0100a3e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a41:	e8 fb 0c 00 00       	call   f0101741 <strcmp>
f0100a46:	83 c4 10             	add    $0x10,%esp
f0100a49:	85 c0                	test   %eax,%eax
f0100a4b:	0f 84 b4 00 00 00    	je     f0100b05 <monitor+0x14d>
f0100a51:	83 ec 08             	sub    $0x8,%esp
f0100a54:	8d 83 44 fc fe ff    	lea    -0x103bc(%ebx),%eax
f0100a5a:	50                   	push   %eax
f0100a5b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a5e:	e8 de 0c 00 00       	call   f0101741 <strcmp>
f0100a63:	83 c4 10             	add    $0x10,%esp
f0100a66:	85 c0                	test   %eax,%eax
f0100a68:	0f 84 92 00 00 00    	je     f0100b00 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a6e:	83 ec 08             	sub    $0x8,%esp
f0100a71:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a74:	8d 83 b2 fc fe ff    	lea    -0x1034e(%ebx),%eax
f0100a7a:	50                   	push   %eax
f0100a7b:	e8 0a 01 00 00       	call   f0100b8a <cprintf>
	return 0;
f0100a80:	83 c4 10             	add    $0x10,%esp
f0100a83:	eb 52                	jmp    f0100ad7 <monitor+0x11f>
		if (*buf == 0)
f0100a85:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a88:	74 9a                	je     f0100a24 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f0100a8a:	83 ff 0f             	cmp    $0xf,%edi
f0100a8d:	74 34                	je     f0100ac3 <monitor+0x10b>
		argv[argc++] = buf;
f0100a8f:	8d 47 01             	lea    0x1(%edi),%eax
f0100a92:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a95:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a99:	0f b6 06             	movzbl (%esi),%eax
f0100a9c:	84 c0                	test   %al,%al
f0100a9e:	0f 84 76 ff ff ff    	je     f0100a1a <monitor+0x62>
f0100aa4:	83 ec 08             	sub    $0x8,%esp
f0100aa7:	0f be c0             	movsbl %al,%eax
f0100aaa:	50                   	push   %eax
f0100aab:	ff 75 a0             	pushl  -0x60(%ebp)
f0100aae:	e8 f4 0c 00 00       	call   f01017a7 <strchr>
f0100ab3:	83 c4 10             	add    $0x10,%esp
f0100ab6:	85 c0                	test   %eax,%eax
f0100ab8:	0f 85 5c ff ff ff    	jne    f0100a1a <monitor+0x62>
			buf++;
f0100abe:	83 c6 01             	add    $0x1,%esi
f0100ac1:	eb d6                	jmp    f0100a99 <monitor+0xe1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ac3:	83 ec 08             	sub    $0x8,%esp
f0100ac6:	6a 10                	push   $0x10
f0100ac8:	8d 83 95 fc fe ff    	lea    -0x1036b(%ebx),%eax
f0100ace:	50                   	push   %eax
f0100acf:	e8 b6 00 00 00       	call   f0100b8a <cprintf>
			return 0;
f0100ad4:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100ad7:	8d bb 8c fc fe ff    	lea    -0x10374(%ebx),%edi
f0100add:	83 ec 0c             	sub    $0xc,%esp
f0100ae0:	57                   	push   %edi
f0100ae1:	e8 50 0a 00 00       	call   f0101536 <readline>
f0100ae6:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100ae8:	83 c4 10             	add    $0x10,%esp
f0100aeb:	85 c0                	test   %eax,%eax
f0100aed:	74 ee                	je     f0100add <monitor+0x125>
	argv[argc] = 0;
f0100aef:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100af6:	bf 00 00 00 00       	mov    $0x0,%edi
f0100afb:	e9 1d ff ff ff       	jmp    f0100a1d <monitor+0x65>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100b00:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100b05:	83 ec 04             	sub    $0x4,%esp
f0100b08:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b0b:	ff 75 08             	pushl  0x8(%ebp)
f0100b0e:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b11:	52                   	push   %edx
f0100b12:	57                   	push   %edi
f0100b13:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b1a:	83 c4 10             	add    $0x10,%esp
f0100b1d:	85 c0                	test   %eax,%eax
f0100b1f:	79 b6                	jns    f0100ad7 <monitor+0x11f>
				break;
	}
}
f0100b21:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b24:	5b                   	pop    %ebx
f0100b25:	5e                   	pop    %esi
f0100b26:	5f                   	pop    %edi
f0100b27:	5d                   	pop    %ebp
f0100b28:	c3                   	ret    

f0100b29 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100b29:	f3 0f 1e fb          	endbr32 
f0100b2d:	55                   	push   %ebp
f0100b2e:	89 e5                	mov    %esp,%ebp
f0100b30:	53                   	push   %ebx
f0100b31:	83 ec 10             	sub    $0x10,%esp
f0100b34:	e8 93 f6 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100b39:	81 c3 cf 17 01 00    	add    $0x117cf,%ebx
	cputchar(ch);
f0100b3f:	ff 75 08             	pushl  0x8(%ebp)
f0100b42:	e8 06 fc ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0100b47:	83 c4 10             	add    $0x10,%esp
f0100b4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b4d:	c9                   	leave  
f0100b4e:	c3                   	ret    

f0100b4f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b4f:	f3 0f 1e fb          	endbr32 
f0100b53:	55                   	push   %ebp
f0100b54:	89 e5                	mov    %esp,%ebp
f0100b56:	53                   	push   %ebx
f0100b57:	83 ec 14             	sub    $0x14,%esp
f0100b5a:	e8 6d f6 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100b5f:	81 c3 a9 17 01 00    	add    $0x117a9,%ebx
	int cnt = 0;
f0100b65:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b6c:	ff 75 0c             	pushl  0xc(%ebp)
f0100b6f:	ff 75 08             	pushl  0x8(%ebp)
f0100b72:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b75:	50                   	push   %eax
f0100b76:	8d 83 21 e8 fe ff    	lea    -0x117df(%ebx),%eax
f0100b7c:	50                   	push   %eax
f0100b7d:	e8 7a 04 00 00       	call   f0100ffc <vprintfmt>
	return cnt;
}
f0100b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b88:	c9                   	leave  
f0100b89:	c3                   	ret    

f0100b8a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b8a:	f3 0f 1e fb          	endbr32 
f0100b8e:	55                   	push   %ebp
f0100b8f:	89 e5                	mov    %esp,%ebp
f0100b91:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b94:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b97:	50                   	push   %eax
f0100b98:	ff 75 08             	pushl  0x8(%ebp)
f0100b9b:	e8 af ff ff ff       	call   f0100b4f <vcprintf>
	va_end(ap);

	return cnt;
}
f0100ba0:	c9                   	leave  
f0100ba1:	c3                   	ret    

f0100ba2 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100ba2:	55                   	push   %ebp
f0100ba3:	89 e5                	mov    %esp,%ebp
f0100ba5:	57                   	push   %edi
f0100ba6:	56                   	push   %esi
f0100ba7:	53                   	push   %ebx
f0100ba8:	83 ec 14             	sub    $0x14,%esp
f0100bab:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100bae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100bb1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bb4:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100bb7:	8b 1a                	mov    (%edx),%ebx
f0100bb9:	8b 01                	mov    (%ecx),%eax
f0100bbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bbe:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100bc5:	eb 23                	jmp    f0100bea <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100bc7:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100bca:	eb 1e                	jmp    f0100bea <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100bcc:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bcf:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bd2:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100bd6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bd9:	73 46                	jae    f0100c21 <stab_binsearch+0x7f>
			*region_left = m;
f0100bdb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100bde:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100be0:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100be3:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100bea:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100bed:	7f 5f                	jg     f0100c4e <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100bf2:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100bf5:	89 d0                	mov    %edx,%eax
f0100bf7:	c1 e8 1f             	shr    $0x1f,%eax
f0100bfa:	01 d0                	add    %edx,%eax
f0100bfc:	89 c7                	mov    %eax,%edi
f0100bfe:	d1 ff                	sar    %edi
f0100c00:	83 e0 fe             	and    $0xfffffffe,%eax
f0100c03:	01 f8                	add    %edi,%eax
f0100c05:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c08:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100c0c:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100c0e:	39 c3                	cmp    %eax,%ebx
f0100c10:	7f b5                	jg     f0100bc7 <stab_binsearch+0x25>
f0100c12:	0f b6 0a             	movzbl (%edx),%ecx
f0100c15:	83 ea 0c             	sub    $0xc,%edx
f0100c18:	39 f1                	cmp    %esi,%ecx
f0100c1a:	74 b0                	je     f0100bcc <stab_binsearch+0x2a>
			m--;
f0100c1c:	83 e8 01             	sub    $0x1,%eax
f0100c1f:	eb ed                	jmp    f0100c0e <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100c21:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c24:	76 14                	jbe    f0100c3a <stab_binsearch+0x98>
			*region_right = m - 1;
f0100c26:	83 e8 01             	sub    $0x1,%eax
f0100c29:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c2c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c2f:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100c31:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c38:	eb b0                	jmp    f0100bea <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100c3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c3d:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100c3f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100c43:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100c45:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c4c:	eb 9c                	jmp    f0100bea <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100c4e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100c52:	75 15                	jne    f0100c69 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100c54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c57:	8b 00                	mov    (%eax),%eax
f0100c59:	83 e8 01             	sub    $0x1,%eax
f0100c5c:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c5f:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c61:	83 c4 14             	add    $0x14,%esp
f0100c64:	5b                   	pop    %ebx
f0100c65:	5e                   	pop    %esi
f0100c66:	5f                   	pop    %edi
f0100c67:	5d                   	pop    %ebp
f0100c68:	c3                   	ret    
		for (l = *region_right;
f0100c69:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c6c:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c71:	8b 0f                	mov    (%edi),%ecx
f0100c73:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c76:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100c79:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100c7d:	eb 03                	jmp    f0100c82 <stab_binsearch+0xe0>
		     l--)
f0100c7f:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100c82:	39 c1                	cmp    %eax,%ecx
f0100c84:	7d 0a                	jge    f0100c90 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100c86:	0f b6 1a             	movzbl (%edx),%ebx
f0100c89:	83 ea 0c             	sub    $0xc,%edx
f0100c8c:	39 f3                	cmp    %esi,%ebx
f0100c8e:	75 ef                	jne    f0100c7f <stab_binsearch+0xdd>
		*region_left = l;
f0100c90:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c93:	89 07                	mov    %eax,(%edi)
}
f0100c95:	eb ca                	jmp    f0100c61 <stab_binsearch+0xbf>

f0100c97 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c97:	f3 0f 1e fb          	endbr32 
f0100c9b:	55                   	push   %ebp
f0100c9c:	89 e5                	mov    %esp,%ebp
f0100c9e:	57                   	push   %edi
f0100c9f:	56                   	push   %esi
f0100ca0:	53                   	push   %ebx
f0100ca1:	83 ec 3c             	sub    $0x3c,%esp
f0100ca4:	e8 23 f5 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100ca9:	81 c3 5f 16 01 00    	add    $0x1165f,%ebx
f0100caf:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100cb2:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100cb5:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100cb8:	8d 83 1d fe fe ff    	lea    -0x101e3(%ebx),%eax
f0100cbe:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100cc0:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100cc7:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100cca:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100cd1:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100cd4:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100cdb:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100ce1:	0f 86 38 01 00 00    	jbe    f0100e1f <debuginfo_eip+0x188>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ce7:	c7 c0 05 68 10 f0    	mov    $0xf0106805,%eax
f0100ced:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100cf3:	0f 86 da 01 00 00    	jbe    f0100ed3 <debuginfo_eip+0x23c>
f0100cf9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100cfc:	c7 c0 b9 81 10 f0    	mov    $0xf01081b9,%eax
f0100d02:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100d06:	0f 85 ce 01 00 00    	jne    f0100eda <debuginfo_eip+0x243>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100d0c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100d13:	c7 c0 40 23 10 f0    	mov    $0xf0102340,%eax
f0100d19:	c7 c2 04 68 10 f0    	mov    $0xf0106804,%edx
f0100d1f:	29 c2                	sub    %eax,%edx
f0100d21:	c1 fa 02             	sar    $0x2,%edx
f0100d24:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100d2a:	83 ea 01             	sub    $0x1,%edx
f0100d2d:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100d30:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d33:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d36:	83 ec 08             	sub    $0x8,%esp
f0100d39:	57                   	push   %edi
f0100d3a:	6a 64                	push   $0x64
f0100d3c:	e8 61 fe ff ff       	call   f0100ba2 <stab_binsearch>
	if (lfile == 0)
f0100d41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d44:	83 c4 10             	add    $0x10,%esp
f0100d47:	85 c0                	test   %eax,%eax
f0100d49:	0f 84 92 01 00 00    	je     f0100ee1 <debuginfo_eip+0x24a>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d4f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100d52:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d55:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d58:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d5b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d5e:	83 ec 08             	sub    $0x8,%esp
f0100d61:	57                   	push   %edi
f0100d62:	6a 24                	push   $0x24
f0100d64:	c7 c0 40 23 10 f0    	mov    $0xf0102340,%eax
f0100d6a:	e8 33 fe ff ff       	call   f0100ba2 <stab_binsearch>

	if (lfun <= rfun) {
f0100d6f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d72:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100d75:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0100d78:	83 c4 10             	add    $0x10,%esp
f0100d7b:	39 c8                	cmp    %ecx,%eax
f0100d7d:	0f 8f b7 00 00 00    	jg     f0100e3a <debuginfo_eip+0x1a3>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d83:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d86:	c7 c1 40 23 10 f0    	mov    $0xf0102340,%ecx
f0100d8c:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100d8f:	8b 11                	mov    (%ecx),%edx
f0100d91:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0100d94:	c7 c2 b9 81 10 f0    	mov    $0xf01081b9,%edx
f0100d9a:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100d9d:	81 ea 05 68 10 f0    	sub    $0xf0106805,%edx
f0100da3:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100da6:	39 d3                	cmp    %edx,%ebx
f0100da8:	73 0c                	jae    f0100db6 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100daa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100dad:	81 c3 05 68 10 f0    	add    $0xf0106805,%ebx
f0100db3:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100db6:	8b 51 08             	mov    0x8(%ecx),%edx
f0100db9:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100dbc:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100dbe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100dc1:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100dc4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100dc7:	83 ec 08             	sub    $0x8,%esp
f0100dca:	6a 3a                	push   $0x3a
f0100dcc:	ff 76 08             	pushl  0x8(%esi)
f0100dcf:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dd2:	e8 f5 09 00 00       	call   f01017cc <strfind>
f0100dd7:	2b 46 08             	sub    0x8(%esi),%eax
f0100dda:	89 46 0c             	mov    %eax,0xc(%esi)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100ddd:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100de0:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100de3:	83 c4 08             	add    $0x8,%esp
f0100de6:	57                   	push   %edi
f0100de7:	6a 44                	push   $0x44
f0100de9:	c7 c0 40 23 10 f0    	mov    $0xf0102340,%eax
f0100def:	e8 ae fd ff ff       	call   f0100ba2 <stab_binsearch>
	if (lline <= rline) {
f0100df4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100df7:	83 c4 10             	add    $0x10,%esp
f0100dfa:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100dfd:	0f 8f e5 00 00 00    	jg     f0100ee8 <debuginfo_eip+0x251>
		info->eip_line = stabs[lline].n_desc;
f0100e03:	89 c2                	mov    %eax,%edx
f0100e05:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100e08:	c7 c0 40 23 10 f0    	mov    $0xf0102340,%eax
f0100e0e:	0f b7 5c 88 06       	movzwl 0x6(%eax,%ecx,4),%ebx
f0100e13:	89 5e 04             	mov    %ebx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e19:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100e1d:	eb 35                	jmp    f0100e54 <debuginfo_eip+0x1bd>
  	        panic("User address");
f0100e1f:	83 ec 04             	sub    $0x4,%esp
f0100e22:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e25:	8d 83 27 fe fe ff    	lea    -0x101d9(%ebx),%eax
f0100e2b:	50                   	push   %eax
f0100e2c:	6a 7f                	push   $0x7f
f0100e2e:	8d 83 34 fe fe ff    	lea    -0x101cc(%ebx),%eax
f0100e34:	50                   	push   %eax
f0100e35:	e8 d4 f2 ff ff       	call   f010010e <_panic>
		info->eip_fn_addr = addr;
f0100e3a:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100e3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e40:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e43:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e46:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e49:	e9 79 ff ff ff       	jmp    f0100dc7 <debuginfo_eip+0x130>
f0100e4e:	83 ea 01             	sub    $0x1,%edx
f0100e51:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100e54:	39 d7                	cmp    %edx,%edi
f0100e56:	7f 3a                	jg     f0100e92 <debuginfo_eip+0x1fb>
	       && stabs[lline].n_type != N_SOL
f0100e58:	0f b6 08             	movzbl (%eax),%ecx
f0100e5b:	80 f9 84             	cmp    $0x84,%cl
f0100e5e:	74 0b                	je     f0100e6b <debuginfo_eip+0x1d4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e60:	80 f9 64             	cmp    $0x64,%cl
f0100e63:	75 e9                	jne    f0100e4e <debuginfo_eip+0x1b7>
f0100e65:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100e69:	74 e3                	je     f0100e4e <debuginfo_eip+0x1b7>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e6b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100e6e:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100e71:	c7 c0 40 23 10 f0    	mov    $0xf0102340,%eax
f0100e77:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e7a:	c7 c0 b9 81 10 f0    	mov    $0xf01081b9,%eax
f0100e80:	81 e8 05 68 10 f0    	sub    $0xf0106805,%eax
f0100e86:	39 c2                	cmp    %eax,%edx
f0100e88:	73 08                	jae    f0100e92 <debuginfo_eip+0x1fb>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e8a:	81 c2 05 68 10 f0    	add    $0xf0106805,%edx
f0100e90:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e92:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e95:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e98:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e9d:	39 da                	cmp    %ebx,%edx
f0100e9f:	7d 53                	jge    f0100ef4 <debuginfo_eip+0x25d>
		for (lline = lfun + 1;
f0100ea1:	8d 42 01             	lea    0x1(%edx),%eax
f0100ea4:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100ea7:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100eaa:	c7 c2 40 23 10 f0    	mov    $0xf0102340,%edx
f0100eb0:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100eb4:	eb 04                	jmp    f0100eba <debuginfo_eip+0x223>
			info->eip_fn_narg++;
f0100eb6:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100eba:	39 c3                	cmp    %eax,%ebx
f0100ebc:	7e 31                	jle    f0100eef <debuginfo_eip+0x258>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ebe:	0f b6 0a             	movzbl (%edx),%ecx
f0100ec1:	83 c0 01             	add    $0x1,%eax
f0100ec4:	83 c2 0c             	add    $0xc,%edx
f0100ec7:	80 f9 a0             	cmp    $0xa0,%cl
f0100eca:	74 ea                	je     f0100eb6 <debuginfo_eip+0x21f>
	return 0;
f0100ecc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ed1:	eb 21                	jmp    f0100ef4 <debuginfo_eip+0x25d>
		return -1;
f0100ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ed8:	eb 1a                	jmp    f0100ef4 <debuginfo_eip+0x25d>
f0100eda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100edf:	eb 13                	jmp    f0100ef4 <debuginfo_eip+0x25d>
		return -1;
f0100ee1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ee6:	eb 0c                	jmp    f0100ef4 <debuginfo_eip+0x25d>
		return -1;
f0100ee8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100eed:	eb 05                	jmp    f0100ef4 <debuginfo_eip+0x25d>
	return 0;
f0100eef:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ef4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ef7:	5b                   	pop    %ebx
f0100ef8:	5e                   	pop    %esi
f0100ef9:	5f                   	pop    %edi
f0100efa:	5d                   	pop    %ebp
f0100efb:	c3                   	ret    

f0100efc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100efc:	55                   	push   %ebp
f0100efd:	89 e5                	mov    %esp,%ebp
f0100eff:	57                   	push   %edi
f0100f00:	56                   	push   %esi
f0100f01:	53                   	push   %ebx
f0100f02:	83 ec 2c             	sub    $0x2c,%esp
f0100f05:	e8 28 06 00 00       	call   f0101532 <__x86.get_pc_thunk.cx>
f0100f0a:	81 c1 fe 13 01 00    	add    $0x113fe,%ecx
f0100f10:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f13:	89 c7                	mov    %eax,%edi
f0100f15:	89 d6                	mov    %edx,%esi
f0100f17:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f1a:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f1d:	89 d1                	mov    %edx,%ecx
f0100f1f:	89 c2                	mov    %eax,%edx
f0100f21:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f24:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100f27:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f2a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f2d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f30:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100f37:	39 c2                	cmp    %eax,%edx
f0100f39:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100f3c:	72 41                	jb     f0100f7f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f3e:	83 ec 0c             	sub    $0xc,%esp
f0100f41:	ff 75 18             	pushl  0x18(%ebp)
f0100f44:	83 eb 01             	sub    $0x1,%ebx
f0100f47:	53                   	push   %ebx
f0100f48:	50                   	push   %eax
f0100f49:	83 ec 08             	sub    $0x8,%esp
f0100f4c:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f4f:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f52:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f55:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f58:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f5b:	e8 a0 0a 00 00       	call   f0101a00 <__udivdi3>
f0100f60:	83 c4 18             	add    $0x18,%esp
f0100f63:	52                   	push   %edx
f0100f64:	50                   	push   %eax
f0100f65:	89 f2                	mov    %esi,%edx
f0100f67:	89 f8                	mov    %edi,%eax
f0100f69:	e8 8e ff ff ff       	call   f0100efc <printnum>
f0100f6e:	83 c4 20             	add    $0x20,%esp
f0100f71:	eb 13                	jmp    f0100f86 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f73:	83 ec 08             	sub    $0x8,%esp
f0100f76:	56                   	push   %esi
f0100f77:	ff 75 18             	pushl  0x18(%ebp)
f0100f7a:	ff d7                	call   *%edi
f0100f7c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f7f:	83 eb 01             	sub    $0x1,%ebx
f0100f82:	85 db                	test   %ebx,%ebx
f0100f84:	7f ed                	jg     f0100f73 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f86:	83 ec 08             	sub    $0x8,%esp
f0100f89:	56                   	push   %esi
f0100f8a:	83 ec 04             	sub    $0x4,%esp
f0100f8d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f90:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f93:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f96:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f99:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f9c:	e8 6f 0b 00 00       	call   f0101b10 <__umoddi3>
f0100fa1:	83 c4 14             	add    $0x14,%esp
f0100fa4:	0f be 84 03 42 fe fe 	movsbl -0x101be(%ebx,%eax,1),%eax
f0100fab:	ff 
f0100fac:	50                   	push   %eax
f0100fad:	ff d7                	call   *%edi
}
f0100faf:	83 c4 10             	add    $0x10,%esp
f0100fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fb5:	5b                   	pop    %ebx
f0100fb6:	5e                   	pop    %esi
f0100fb7:	5f                   	pop    %edi
f0100fb8:	5d                   	pop    %ebp
f0100fb9:	c3                   	ret    

f0100fba <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100fba:	f3 0f 1e fb          	endbr32 
f0100fbe:	55                   	push   %ebp
f0100fbf:	89 e5                	mov    %esp,%ebp
f0100fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100fc4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100fc8:	8b 10                	mov    (%eax),%edx
f0100fca:	3b 50 04             	cmp    0x4(%eax),%edx
f0100fcd:	73 0a                	jae    f0100fd9 <sprintputch+0x1f>
		*b->buf++ = ch;
f0100fcf:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100fd2:	89 08                	mov    %ecx,(%eax)
f0100fd4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fd7:	88 02                	mov    %al,(%edx)
}
f0100fd9:	5d                   	pop    %ebp
f0100fda:	c3                   	ret    

f0100fdb <printfmt>:
{
f0100fdb:	f3 0f 1e fb          	endbr32 
f0100fdf:	55                   	push   %ebp
f0100fe0:	89 e5                	mov    %esp,%ebp
f0100fe2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100fe5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100fe8:	50                   	push   %eax
f0100fe9:	ff 75 10             	pushl  0x10(%ebp)
f0100fec:	ff 75 0c             	pushl  0xc(%ebp)
f0100fef:	ff 75 08             	pushl  0x8(%ebp)
f0100ff2:	e8 05 00 00 00       	call   f0100ffc <vprintfmt>
}
f0100ff7:	83 c4 10             	add    $0x10,%esp
f0100ffa:	c9                   	leave  
f0100ffb:	c3                   	ret    

f0100ffc <vprintfmt>:
{
f0100ffc:	f3 0f 1e fb          	endbr32 
f0101000:	55                   	push   %ebp
f0101001:	89 e5                	mov    %esp,%ebp
f0101003:	57                   	push   %edi
f0101004:	56                   	push   %esi
f0101005:	53                   	push   %ebx
f0101006:	83 ec 3c             	sub    $0x3c,%esp
f0101009:	e8 72 f7 ff ff       	call   f0100780 <__x86.get_pc_thunk.ax>
f010100e:	05 fa 12 01 00       	add    $0x112fa,%eax
f0101013:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101016:	8b 75 08             	mov    0x8(%ebp),%esi
f0101019:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010101c:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010101f:	8d 80 20 1d 00 00    	lea    0x1d20(%eax),%eax
f0101025:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101028:	e9 cd 03 00 00       	jmp    f01013fa <.L25+0x48>
		padc = ' ';
f010102d:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0101031:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0101038:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f010103f:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0101046:	b9 00 00 00 00       	mov    $0x0,%ecx
f010104b:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010104e:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101051:	8d 43 01             	lea    0x1(%ebx),%eax
f0101054:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101057:	0f b6 13             	movzbl (%ebx),%edx
f010105a:	8d 42 dd             	lea    -0x23(%edx),%eax
f010105d:	3c 55                	cmp    $0x55,%al
f010105f:	0f 87 21 04 00 00    	ja     f0101486 <.L20>
f0101065:	0f b6 c0             	movzbl %al,%eax
f0101068:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010106b:	89 ce                	mov    %ecx,%esi
f010106d:	03 b4 81 d0 fe fe ff 	add    -0x10130(%ecx,%eax,4),%esi
f0101074:	3e ff e6             	notrack jmp *%esi

f0101077 <.L68>:
f0101077:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f010107a:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f010107e:	eb d1                	jmp    f0101051 <vprintfmt+0x55>

f0101080 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0101080:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101083:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0101087:	eb c8                	jmp    f0101051 <vprintfmt+0x55>

f0101089 <.L31>:
f0101089:	0f b6 d2             	movzbl %dl,%edx
f010108c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f010108f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101094:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0101097:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010109a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010109e:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01010a1:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01010a4:	83 f9 09             	cmp    $0x9,%ecx
f01010a7:	77 58                	ja     f0101101 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01010a9:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01010ac:	eb e9                	jmp    f0101097 <.L31+0xe>

f01010ae <.L34>:
			precision = va_arg(ap, int);
f01010ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b1:	8b 00                	mov    (%eax),%eax
f01010b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b9:	8d 40 04             	lea    0x4(%eax),%eax
f01010bc:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010bf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01010c2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01010c6:	79 89                	jns    f0101051 <vprintfmt+0x55>
				width = precision, precision = -1;
f01010c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01010d5:	e9 77 ff ff ff       	jmp    f0101051 <vprintfmt+0x55>

f01010da <.L33>:
f01010da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01010dd:	85 c0                	test   %eax,%eax
f01010df:	ba 00 00 00 00       	mov    $0x0,%edx
f01010e4:	0f 49 d0             	cmovns %eax,%edx
f01010e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010ea:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01010ed:	e9 5f ff ff ff       	jmp    f0101051 <vprintfmt+0x55>

f01010f2 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01010f2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01010f5:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f01010fc:	e9 50 ff ff ff       	jmp    f0101051 <vprintfmt+0x55>
f0101101:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101104:	89 75 08             	mov    %esi,0x8(%ebp)
f0101107:	eb b9                	jmp    f01010c2 <.L34+0x14>

f0101109 <.L27>:
			lflag++;
f0101109:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010110d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101110:	e9 3c ff ff ff       	jmp    f0101051 <vprintfmt+0x55>

f0101115 <.L30>:
f0101115:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0101118:	8b 45 14             	mov    0x14(%ebp),%eax
f010111b:	8d 58 04             	lea    0x4(%eax),%ebx
f010111e:	83 ec 08             	sub    $0x8,%esp
f0101121:	57                   	push   %edi
f0101122:	ff 30                	pushl  (%eax)
f0101124:	ff d6                	call   *%esi
			break;
f0101126:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101129:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f010112c:	e9 c6 02 00 00       	jmp    f01013f7 <.L25+0x45>

f0101131 <.L28>:
f0101131:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f0101134:	8b 45 14             	mov    0x14(%ebp),%eax
f0101137:	8d 58 04             	lea    0x4(%eax),%ebx
f010113a:	8b 00                	mov    (%eax),%eax
f010113c:	99                   	cltd   
f010113d:	31 d0                	xor    %edx,%eax
f010113f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101141:	83 f8 06             	cmp    $0x6,%eax
f0101144:	7f 27                	jg     f010116d <.L28+0x3c>
f0101146:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101149:	8b 14 82             	mov    (%edx,%eax,4),%edx
f010114c:	85 d2                	test   %edx,%edx
f010114e:	74 1d                	je     f010116d <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f0101150:	52                   	push   %edx
f0101151:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101154:	8d 80 63 fe fe ff    	lea    -0x1019d(%eax),%eax
f010115a:	50                   	push   %eax
f010115b:	57                   	push   %edi
f010115c:	56                   	push   %esi
f010115d:	e8 79 fe ff ff       	call   f0100fdb <printfmt>
f0101162:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101165:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101168:	e9 8a 02 00 00       	jmp    f01013f7 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010116d:	50                   	push   %eax
f010116e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101171:	8d 80 5a fe fe ff    	lea    -0x101a6(%eax),%eax
f0101177:	50                   	push   %eax
f0101178:	57                   	push   %edi
f0101179:	56                   	push   %esi
f010117a:	e8 5c fe ff ff       	call   f0100fdb <printfmt>
f010117f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101182:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101185:	e9 6d 02 00 00       	jmp    f01013f7 <.L25+0x45>

f010118a <.L24>:
f010118a:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f010118d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101190:	83 c0 04             	add    $0x4,%eax
f0101193:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0101196:	8b 45 14             	mov    0x14(%ebp),%eax
f0101199:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010119b:	85 d2                	test   %edx,%edx
f010119d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011a0:	8d 80 53 fe fe ff    	lea    -0x101ad(%eax),%eax
f01011a6:	0f 45 c2             	cmovne %edx,%eax
f01011a9:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01011ac:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01011b0:	7e 06                	jle    f01011b8 <.L24+0x2e>
f01011b2:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01011b6:	75 0d                	jne    f01011c5 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01011b8:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01011bb:	89 c3                	mov    %eax,%ebx
f01011bd:	03 45 d4             	add    -0x2c(%ebp),%eax
f01011c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011c3:	eb 58                	jmp    f010121d <.L24+0x93>
f01011c5:	83 ec 08             	sub    $0x8,%esp
f01011c8:	ff 75 d8             	pushl  -0x28(%ebp)
f01011cb:	ff 75 c8             	pushl  -0x38(%ebp)
f01011ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01011d1:	e8 85 04 00 00       	call   f010165b <strnlen>
f01011d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01011d9:	29 c2                	sub    %eax,%edx
f01011db:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01011de:	83 c4 10             	add    $0x10,%esp
f01011e1:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01011e3:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01011e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01011ea:	85 db                	test   %ebx,%ebx
f01011ec:	7e 11                	jle    f01011ff <.L24+0x75>
					putch(padc, putdat);
f01011ee:	83 ec 08             	sub    $0x8,%esp
f01011f1:	57                   	push   %edi
f01011f2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01011f5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01011f7:	83 eb 01             	sub    $0x1,%ebx
f01011fa:	83 c4 10             	add    $0x10,%esp
f01011fd:	eb eb                	jmp    f01011ea <.L24+0x60>
f01011ff:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0101202:	85 d2                	test   %edx,%edx
f0101204:	b8 00 00 00 00       	mov    $0x0,%eax
f0101209:	0f 49 c2             	cmovns %edx,%eax
f010120c:	29 c2                	sub    %eax,%edx
f010120e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0101211:	eb a5                	jmp    f01011b8 <.L24+0x2e>
					putch(ch, putdat);
f0101213:	83 ec 08             	sub    $0x8,%esp
f0101216:	57                   	push   %edi
f0101217:	52                   	push   %edx
f0101218:	ff d6                	call   *%esi
f010121a:	83 c4 10             	add    $0x10,%esp
f010121d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101220:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101222:	83 c3 01             	add    $0x1,%ebx
f0101225:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101229:	0f be d0             	movsbl %al,%edx
f010122c:	85 d2                	test   %edx,%edx
f010122e:	74 4b                	je     f010127b <.L24+0xf1>
f0101230:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101234:	78 06                	js     f010123c <.L24+0xb2>
f0101236:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010123a:	78 1e                	js     f010125a <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f010123c:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101240:	74 d1                	je     f0101213 <.L24+0x89>
f0101242:	0f be c0             	movsbl %al,%eax
f0101245:	83 e8 20             	sub    $0x20,%eax
f0101248:	83 f8 5e             	cmp    $0x5e,%eax
f010124b:	76 c6                	jbe    f0101213 <.L24+0x89>
					putch('?', putdat);
f010124d:	83 ec 08             	sub    $0x8,%esp
f0101250:	57                   	push   %edi
f0101251:	6a 3f                	push   $0x3f
f0101253:	ff d6                	call   *%esi
f0101255:	83 c4 10             	add    $0x10,%esp
f0101258:	eb c3                	jmp    f010121d <.L24+0x93>
f010125a:	89 cb                	mov    %ecx,%ebx
f010125c:	eb 0e                	jmp    f010126c <.L24+0xe2>
				putch(' ', putdat);
f010125e:	83 ec 08             	sub    $0x8,%esp
f0101261:	57                   	push   %edi
f0101262:	6a 20                	push   $0x20
f0101264:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101266:	83 eb 01             	sub    $0x1,%ebx
f0101269:	83 c4 10             	add    $0x10,%esp
f010126c:	85 db                	test   %ebx,%ebx
f010126e:	7f ee                	jg     f010125e <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0101270:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0101273:	89 45 14             	mov    %eax,0x14(%ebp)
f0101276:	e9 7c 01 00 00       	jmp    f01013f7 <.L25+0x45>
f010127b:	89 cb                	mov    %ecx,%ebx
f010127d:	eb ed                	jmp    f010126c <.L24+0xe2>

f010127f <.L29>:
f010127f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101282:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101285:	83 f9 01             	cmp    $0x1,%ecx
f0101288:	7f 1b                	jg     f01012a5 <.L29+0x26>
	else if (lflag)
f010128a:	85 c9                	test   %ecx,%ecx
f010128c:	74 63                	je     f01012f1 <.L29+0x72>
		return va_arg(*ap, long);
f010128e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101291:	8b 00                	mov    (%eax),%eax
f0101293:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101296:	99                   	cltd   
f0101297:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010129a:	8b 45 14             	mov    0x14(%ebp),%eax
f010129d:	8d 40 04             	lea    0x4(%eax),%eax
f01012a0:	89 45 14             	mov    %eax,0x14(%ebp)
f01012a3:	eb 17                	jmp    f01012bc <.L29+0x3d>
		return va_arg(*ap, long long);
f01012a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01012a8:	8b 50 04             	mov    0x4(%eax),%edx
f01012ab:	8b 00                	mov    (%eax),%eax
f01012ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b6:	8d 40 08             	lea    0x8(%eax),%eax
f01012b9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01012bc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012bf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01012c2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01012c7:	85 c9                	test   %ecx,%ecx
f01012c9:	0f 89 0e 01 00 00    	jns    f01013dd <.L25+0x2b>
				putch('-', putdat);
f01012cf:	83 ec 08             	sub    $0x8,%esp
f01012d2:	57                   	push   %edi
f01012d3:	6a 2d                	push   $0x2d
f01012d5:	ff d6                	call   *%esi
				num = -(long long) num;
f01012d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01012dd:	f7 da                	neg    %edx
f01012df:	83 d1 00             	adc    $0x0,%ecx
f01012e2:	f7 d9                	neg    %ecx
f01012e4:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01012e7:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012ec:	e9 ec 00 00 00       	jmp    f01013dd <.L25+0x2b>
		return va_arg(*ap, int);
f01012f1:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f4:	8b 00                	mov    (%eax),%eax
f01012f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012f9:	99                   	cltd   
f01012fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012fd:	8b 45 14             	mov    0x14(%ebp),%eax
f0101300:	8d 40 04             	lea    0x4(%eax),%eax
f0101303:	89 45 14             	mov    %eax,0x14(%ebp)
f0101306:	eb b4                	jmp    f01012bc <.L29+0x3d>

f0101308 <.L23>:
f0101308:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010130b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010130e:	83 f9 01             	cmp    $0x1,%ecx
f0101311:	7f 1e                	jg     f0101331 <.L23+0x29>
	else if (lflag)
f0101313:	85 c9                	test   %ecx,%ecx
f0101315:	74 32                	je     f0101349 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0101317:	8b 45 14             	mov    0x14(%ebp),%eax
f010131a:	8b 10                	mov    (%eax),%edx
f010131c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101321:	8d 40 04             	lea    0x4(%eax),%eax
f0101324:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101327:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f010132c:	e9 ac 00 00 00       	jmp    f01013dd <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101331:	8b 45 14             	mov    0x14(%ebp),%eax
f0101334:	8b 10                	mov    (%eax),%edx
f0101336:	8b 48 04             	mov    0x4(%eax),%ecx
f0101339:	8d 40 08             	lea    0x8(%eax),%eax
f010133c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010133f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0101344:	e9 94 00 00 00       	jmp    f01013dd <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101349:	8b 45 14             	mov    0x14(%ebp),%eax
f010134c:	8b 10                	mov    (%eax),%edx
f010134e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101353:	8d 40 04             	lea    0x4(%eax),%eax
f0101356:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101359:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f010135e:	eb 7d                	jmp    f01013dd <.L25+0x2b>

f0101360 <.L26>:
f0101360:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101363:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101366:	83 f9 01             	cmp    $0x1,%ecx
f0101369:	7f 1b                	jg     f0101386 <.L26+0x26>
	else if (lflag)
f010136b:	85 c9                	test   %ecx,%ecx
f010136d:	74 2c                	je     f010139b <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f010136f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101372:	8b 10                	mov    (%eax),%edx
f0101374:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101379:	8d 40 04             	lea    0x4(%eax),%eax
f010137c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010137f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f0101384:	eb 57                	jmp    f01013dd <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101386:	8b 45 14             	mov    0x14(%ebp),%eax
f0101389:	8b 10                	mov    (%eax),%edx
f010138b:	8b 48 04             	mov    0x4(%eax),%ecx
f010138e:	8d 40 08             	lea    0x8(%eax),%eax
f0101391:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101394:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f0101399:	eb 42                	jmp    f01013dd <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010139b:	8b 45 14             	mov    0x14(%ebp),%eax
f010139e:	8b 10                	mov    (%eax),%edx
f01013a0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013a5:	8d 40 04             	lea    0x4(%eax),%eax
f01013a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01013ab:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f01013b0:	eb 2b                	jmp    f01013dd <.L25+0x2b>

f01013b2 <.L25>:
f01013b2:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f01013b5:	83 ec 08             	sub    $0x8,%esp
f01013b8:	57                   	push   %edi
f01013b9:	6a 30                	push   $0x30
f01013bb:	ff d6                	call   *%esi
			putch('x', putdat);
f01013bd:	83 c4 08             	add    $0x8,%esp
f01013c0:	57                   	push   %edi
f01013c1:	6a 78                	push   $0x78
f01013c3:	ff d6                	call   *%esi
			num = (unsigned long long)
f01013c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c8:	8b 10                	mov    (%eax),%edx
f01013ca:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01013cf:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01013d2:	8d 40 04             	lea    0x4(%eax),%eax
f01013d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013d8:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01013dd:	83 ec 0c             	sub    $0xc,%esp
f01013e0:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f01013e4:	53                   	push   %ebx
f01013e5:	ff 75 d4             	pushl  -0x2c(%ebp)
f01013e8:	50                   	push   %eax
f01013e9:	51                   	push   %ecx
f01013ea:	52                   	push   %edx
f01013eb:	89 fa                	mov    %edi,%edx
f01013ed:	89 f0                	mov    %esi,%eax
f01013ef:	e8 08 fb ff ff       	call   f0100efc <printnum>
			break;
f01013f4:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01013f7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013fa:	83 c3 01             	add    $0x1,%ebx
f01013fd:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101401:	83 f8 25             	cmp    $0x25,%eax
f0101404:	0f 84 23 fc ff ff    	je     f010102d <vprintfmt+0x31>
			if (ch == '\0')
f010140a:	85 c0                	test   %eax,%eax
f010140c:	0f 84 97 00 00 00    	je     f01014a9 <.L20+0x23>
			putch(ch, putdat);
f0101412:	83 ec 08             	sub    $0x8,%esp
f0101415:	57                   	push   %edi
f0101416:	50                   	push   %eax
f0101417:	ff d6                	call   *%esi
f0101419:	83 c4 10             	add    $0x10,%esp
f010141c:	eb dc                	jmp    f01013fa <.L25+0x48>

f010141e <.L21>:
f010141e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101421:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101424:	83 f9 01             	cmp    $0x1,%ecx
f0101427:	7f 1b                	jg     f0101444 <.L21+0x26>
	else if (lflag)
f0101429:	85 c9                	test   %ecx,%ecx
f010142b:	74 2c                	je     f0101459 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f010142d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101430:	8b 10                	mov    (%eax),%edx
f0101432:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101437:	8d 40 04             	lea    0x4(%eax),%eax
f010143a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010143d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0101442:	eb 99                	jmp    f01013dd <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101444:	8b 45 14             	mov    0x14(%ebp),%eax
f0101447:	8b 10                	mov    (%eax),%edx
f0101449:	8b 48 04             	mov    0x4(%eax),%ecx
f010144c:	8d 40 08             	lea    0x8(%eax),%eax
f010144f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101452:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0101457:	eb 84                	jmp    f01013dd <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101459:	8b 45 14             	mov    0x14(%ebp),%eax
f010145c:	8b 10                	mov    (%eax),%edx
f010145e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101463:	8d 40 04             	lea    0x4(%eax),%eax
f0101466:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101469:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f010146e:	e9 6a ff ff ff       	jmp    f01013dd <.L25+0x2b>

f0101473 <.L35>:
f0101473:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f0101476:	83 ec 08             	sub    $0x8,%esp
f0101479:	57                   	push   %edi
f010147a:	6a 25                	push   $0x25
f010147c:	ff d6                	call   *%esi
			break;
f010147e:	83 c4 10             	add    $0x10,%esp
f0101481:	e9 71 ff ff ff       	jmp    f01013f7 <.L25+0x45>

f0101486 <.L20>:
f0101486:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f0101489:	83 ec 08             	sub    $0x8,%esp
f010148c:	57                   	push   %edi
f010148d:	6a 25                	push   $0x25
f010148f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101491:	83 c4 10             	add    $0x10,%esp
f0101494:	89 d8                	mov    %ebx,%eax
f0101496:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010149a:	74 05                	je     f01014a1 <.L20+0x1b>
f010149c:	83 e8 01             	sub    $0x1,%eax
f010149f:	eb f5                	jmp    f0101496 <.L20+0x10>
f01014a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014a4:	e9 4e ff ff ff       	jmp    f01013f7 <.L25+0x45>
}
f01014a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014ac:	5b                   	pop    %ebx
f01014ad:	5e                   	pop    %esi
f01014ae:	5f                   	pop    %edi
f01014af:	5d                   	pop    %ebp
f01014b0:	c3                   	ret    

f01014b1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01014b1:	f3 0f 1e fb          	endbr32 
f01014b5:	55                   	push   %ebp
f01014b6:	89 e5                	mov    %esp,%ebp
f01014b8:	53                   	push   %ebx
f01014b9:	83 ec 14             	sub    $0x14,%esp
f01014bc:	e8 0b ed ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01014c1:	81 c3 47 0e 01 00    	add    $0x10e47,%ebx
f01014c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01014cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014d0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01014d4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01014d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01014de:	85 c0                	test   %eax,%eax
f01014e0:	74 2b                	je     f010150d <vsnprintf+0x5c>
f01014e2:	85 d2                	test   %edx,%edx
f01014e4:	7e 27                	jle    f010150d <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01014e6:	ff 75 14             	pushl  0x14(%ebp)
f01014e9:	ff 75 10             	pushl  0x10(%ebp)
f01014ec:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014ef:	50                   	push   %eax
f01014f0:	8d 83 b2 ec fe ff    	lea    -0x1134e(%ebx),%eax
f01014f6:	50                   	push   %eax
f01014f7:	e8 00 fb ff ff       	call   f0100ffc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101502:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101505:	83 c4 10             	add    $0x10,%esp
}
f0101508:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010150b:	c9                   	leave  
f010150c:	c3                   	ret    
		return -E_INVAL;
f010150d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101512:	eb f4                	jmp    f0101508 <vsnprintf+0x57>

f0101514 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101514:	f3 0f 1e fb          	endbr32 
f0101518:	55                   	push   %ebp
f0101519:	89 e5                	mov    %esp,%ebp
f010151b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010151e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101521:	50                   	push   %eax
f0101522:	ff 75 10             	pushl  0x10(%ebp)
f0101525:	ff 75 0c             	pushl  0xc(%ebp)
f0101528:	ff 75 08             	pushl  0x8(%ebp)
f010152b:	e8 81 ff ff ff       	call   f01014b1 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101530:	c9                   	leave  
f0101531:	c3                   	ret    

f0101532 <__x86.get_pc_thunk.cx>:
f0101532:	8b 0c 24             	mov    (%esp),%ecx
f0101535:	c3                   	ret    

f0101536 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101536:	f3 0f 1e fb          	endbr32 
f010153a:	55                   	push   %ebp
f010153b:	89 e5                	mov    %esp,%ebp
f010153d:	57                   	push   %edi
f010153e:	56                   	push   %esi
f010153f:	53                   	push   %ebx
f0101540:	83 ec 1c             	sub    $0x1c,%esp
f0101543:	e8 84 ec ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0101548:	81 c3 c0 0d 01 00    	add    $0x10dc0,%ebx
f010154e:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101551:	85 c0                	test   %eax,%eax
f0101553:	74 13                	je     f0101568 <readline+0x32>
		cprintf("%s", prompt);
f0101555:	83 ec 08             	sub    $0x8,%esp
f0101558:	50                   	push   %eax
f0101559:	8d 83 63 fe fe ff    	lea    -0x1019d(%ebx),%eax
f010155f:	50                   	push   %eax
f0101560:	e8 25 f6 ff ff       	call   f0100b8a <cprintf>
f0101565:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101568:	83 ec 0c             	sub    $0xc,%esp
f010156b:	6a 00                	push   $0x0
f010156d:	e8 04 f2 ff ff       	call   f0100776 <iscons>
f0101572:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101575:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101578:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f010157d:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101583:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101586:	eb 51                	jmp    f01015d9 <readline+0xa3>
			cprintf("read error: %e\n", c);
f0101588:	83 ec 08             	sub    $0x8,%esp
f010158b:	50                   	push   %eax
f010158c:	8d 83 28 00 ff ff    	lea    -0xffd8(%ebx),%eax
f0101592:	50                   	push   %eax
f0101593:	e8 f2 f5 ff ff       	call   f0100b8a <cprintf>
			return NULL;
f0101598:	83 c4 10             	add    $0x10,%esp
f010159b:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01015a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015a3:	5b                   	pop    %ebx
f01015a4:	5e                   	pop    %esi
f01015a5:	5f                   	pop    %edi
f01015a6:	5d                   	pop    %ebp
f01015a7:	c3                   	ret    
			if (echoing)
f01015a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015ac:	75 05                	jne    f01015b3 <readline+0x7d>
			i--;
f01015ae:	83 ef 01             	sub    $0x1,%edi
f01015b1:	eb 26                	jmp    f01015d9 <readline+0xa3>
				cputchar('\b');
f01015b3:	83 ec 0c             	sub    $0xc,%esp
f01015b6:	6a 08                	push   $0x8
f01015b8:	e8 90 f1 ff ff       	call   f010074d <cputchar>
f01015bd:	83 c4 10             	add    $0x10,%esp
f01015c0:	eb ec                	jmp    f01015ae <readline+0x78>
				cputchar(c);
f01015c2:	83 ec 0c             	sub    $0xc,%esp
f01015c5:	56                   	push   %esi
f01015c6:	e8 82 f1 ff ff       	call   f010074d <cputchar>
f01015cb:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01015ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01015d1:	89 f0                	mov    %esi,%eax
f01015d3:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01015d6:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01015d9:	e8 83 f1 ff ff       	call   f0100761 <getchar>
f01015de:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01015e0:	85 c0                	test   %eax,%eax
f01015e2:	78 a4                	js     f0101588 <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01015e4:	83 f8 08             	cmp    $0x8,%eax
f01015e7:	0f 94 c2             	sete   %dl
f01015ea:	83 f8 7f             	cmp    $0x7f,%eax
f01015ed:	0f 94 c0             	sete   %al
f01015f0:	08 c2                	or     %al,%dl
f01015f2:	74 04                	je     f01015f8 <readline+0xc2>
f01015f4:	85 ff                	test   %edi,%edi
f01015f6:	7f b0                	jg     f01015a8 <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01015f8:	83 fe 1f             	cmp    $0x1f,%esi
f01015fb:	7e 10                	jle    f010160d <readline+0xd7>
f01015fd:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101603:	7f 08                	jg     f010160d <readline+0xd7>
			if (echoing)
f0101605:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101609:	74 c3                	je     f01015ce <readline+0x98>
f010160b:	eb b5                	jmp    f01015c2 <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f010160d:	83 fe 0a             	cmp    $0xa,%esi
f0101610:	74 05                	je     f0101617 <readline+0xe1>
f0101612:	83 fe 0d             	cmp    $0xd,%esi
f0101615:	75 c2                	jne    f01015d9 <readline+0xa3>
			if (echoing)
f0101617:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010161b:	75 13                	jne    f0101630 <readline+0xfa>
			buf[i] = 0;
f010161d:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f0101624:	00 
			return buf;
f0101625:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f010162b:	e9 70 ff ff ff       	jmp    f01015a0 <readline+0x6a>
				cputchar('\n');
f0101630:	83 ec 0c             	sub    $0xc,%esp
f0101633:	6a 0a                	push   $0xa
f0101635:	e8 13 f1 ff ff       	call   f010074d <cputchar>
f010163a:	83 c4 10             	add    $0x10,%esp
f010163d:	eb de                	jmp    f010161d <readline+0xe7>

f010163f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010163f:	f3 0f 1e fb          	endbr32 
f0101643:	55                   	push   %ebp
f0101644:	89 e5                	mov    %esp,%ebp
f0101646:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101649:	b8 00 00 00 00       	mov    $0x0,%eax
f010164e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101652:	74 05                	je     f0101659 <strlen+0x1a>
		n++;
f0101654:	83 c0 01             	add    $0x1,%eax
f0101657:	eb f5                	jmp    f010164e <strlen+0xf>
	return n;
}
f0101659:	5d                   	pop    %ebp
f010165a:	c3                   	ret    

f010165b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010165b:	f3 0f 1e fb          	endbr32 
f010165f:	55                   	push   %ebp
f0101660:	89 e5                	mov    %esp,%ebp
f0101662:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101665:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101668:	b8 00 00 00 00       	mov    $0x0,%eax
f010166d:	39 d0                	cmp    %edx,%eax
f010166f:	74 0d                	je     f010167e <strnlen+0x23>
f0101671:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101675:	74 05                	je     f010167c <strnlen+0x21>
		n++;
f0101677:	83 c0 01             	add    $0x1,%eax
f010167a:	eb f1                	jmp    f010166d <strnlen+0x12>
f010167c:	89 c2                	mov    %eax,%edx
	return n;
}
f010167e:	89 d0                	mov    %edx,%eax
f0101680:	5d                   	pop    %ebp
f0101681:	c3                   	ret    

f0101682 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101682:	f3 0f 1e fb          	endbr32 
f0101686:	55                   	push   %ebp
f0101687:	89 e5                	mov    %esp,%ebp
f0101689:	53                   	push   %ebx
f010168a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010168d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101690:	b8 00 00 00 00       	mov    $0x0,%eax
f0101695:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0101699:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010169c:	83 c0 01             	add    $0x1,%eax
f010169f:	84 d2                	test   %dl,%dl
f01016a1:	75 f2                	jne    f0101695 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f01016a3:	89 c8                	mov    %ecx,%eax
f01016a5:	5b                   	pop    %ebx
f01016a6:	5d                   	pop    %ebp
f01016a7:	c3                   	ret    

f01016a8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01016a8:	f3 0f 1e fb          	endbr32 
f01016ac:	55                   	push   %ebp
f01016ad:	89 e5                	mov    %esp,%ebp
f01016af:	53                   	push   %ebx
f01016b0:	83 ec 10             	sub    $0x10,%esp
f01016b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01016b6:	53                   	push   %ebx
f01016b7:	e8 83 ff ff ff       	call   f010163f <strlen>
f01016bc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01016bf:	ff 75 0c             	pushl  0xc(%ebp)
f01016c2:	01 d8                	add    %ebx,%eax
f01016c4:	50                   	push   %eax
f01016c5:	e8 b8 ff ff ff       	call   f0101682 <strcpy>
	return dst;
}
f01016ca:	89 d8                	mov    %ebx,%eax
f01016cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016cf:	c9                   	leave  
f01016d0:	c3                   	ret    

f01016d1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01016d1:	f3 0f 1e fb          	endbr32 
f01016d5:	55                   	push   %ebp
f01016d6:	89 e5                	mov    %esp,%ebp
f01016d8:	56                   	push   %esi
f01016d9:	53                   	push   %ebx
f01016da:	8b 75 08             	mov    0x8(%ebp),%esi
f01016dd:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016e0:	89 f3                	mov    %esi,%ebx
f01016e2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01016e5:	89 f0                	mov    %esi,%eax
f01016e7:	39 d8                	cmp    %ebx,%eax
f01016e9:	74 11                	je     f01016fc <strncpy+0x2b>
		*dst++ = *src;
f01016eb:	83 c0 01             	add    $0x1,%eax
f01016ee:	0f b6 0a             	movzbl (%edx),%ecx
f01016f1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01016f4:	80 f9 01             	cmp    $0x1,%cl
f01016f7:	83 da ff             	sbb    $0xffffffff,%edx
f01016fa:	eb eb                	jmp    f01016e7 <strncpy+0x16>
	}
	return ret;
}
f01016fc:	89 f0                	mov    %esi,%eax
f01016fe:	5b                   	pop    %ebx
f01016ff:	5e                   	pop    %esi
f0101700:	5d                   	pop    %ebp
f0101701:	c3                   	ret    

f0101702 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101702:	f3 0f 1e fb          	endbr32 
f0101706:	55                   	push   %ebp
f0101707:	89 e5                	mov    %esp,%ebp
f0101709:	56                   	push   %esi
f010170a:	53                   	push   %ebx
f010170b:	8b 75 08             	mov    0x8(%ebp),%esi
f010170e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101711:	8b 55 10             	mov    0x10(%ebp),%edx
f0101714:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101716:	85 d2                	test   %edx,%edx
f0101718:	74 21                	je     f010173b <strlcpy+0x39>
f010171a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010171e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0101720:	39 c2                	cmp    %eax,%edx
f0101722:	74 14                	je     f0101738 <strlcpy+0x36>
f0101724:	0f b6 19             	movzbl (%ecx),%ebx
f0101727:	84 db                	test   %bl,%bl
f0101729:	74 0b                	je     f0101736 <strlcpy+0x34>
			*dst++ = *src++;
f010172b:	83 c1 01             	add    $0x1,%ecx
f010172e:	83 c2 01             	add    $0x1,%edx
f0101731:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101734:	eb ea                	jmp    f0101720 <strlcpy+0x1e>
f0101736:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101738:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010173b:	29 f0                	sub    %esi,%eax
}
f010173d:	5b                   	pop    %ebx
f010173e:	5e                   	pop    %esi
f010173f:	5d                   	pop    %ebp
f0101740:	c3                   	ret    

f0101741 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101741:	f3 0f 1e fb          	endbr32 
f0101745:	55                   	push   %ebp
f0101746:	89 e5                	mov    %esp,%ebp
f0101748:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010174b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010174e:	0f b6 01             	movzbl (%ecx),%eax
f0101751:	84 c0                	test   %al,%al
f0101753:	74 0c                	je     f0101761 <strcmp+0x20>
f0101755:	3a 02                	cmp    (%edx),%al
f0101757:	75 08                	jne    f0101761 <strcmp+0x20>
		p++, q++;
f0101759:	83 c1 01             	add    $0x1,%ecx
f010175c:	83 c2 01             	add    $0x1,%edx
f010175f:	eb ed                	jmp    f010174e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101761:	0f b6 c0             	movzbl %al,%eax
f0101764:	0f b6 12             	movzbl (%edx),%edx
f0101767:	29 d0                	sub    %edx,%eax
}
f0101769:	5d                   	pop    %ebp
f010176a:	c3                   	ret    

f010176b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010176b:	f3 0f 1e fb          	endbr32 
f010176f:	55                   	push   %ebp
f0101770:	89 e5                	mov    %esp,%ebp
f0101772:	53                   	push   %ebx
f0101773:	8b 45 08             	mov    0x8(%ebp),%eax
f0101776:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101779:	89 c3                	mov    %eax,%ebx
f010177b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010177e:	eb 06                	jmp    f0101786 <strncmp+0x1b>
		n--, p++, q++;
f0101780:	83 c0 01             	add    $0x1,%eax
f0101783:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101786:	39 d8                	cmp    %ebx,%eax
f0101788:	74 16                	je     f01017a0 <strncmp+0x35>
f010178a:	0f b6 08             	movzbl (%eax),%ecx
f010178d:	84 c9                	test   %cl,%cl
f010178f:	74 04                	je     f0101795 <strncmp+0x2a>
f0101791:	3a 0a                	cmp    (%edx),%cl
f0101793:	74 eb                	je     f0101780 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101795:	0f b6 00             	movzbl (%eax),%eax
f0101798:	0f b6 12             	movzbl (%edx),%edx
f010179b:	29 d0                	sub    %edx,%eax
}
f010179d:	5b                   	pop    %ebx
f010179e:	5d                   	pop    %ebp
f010179f:	c3                   	ret    
		return 0;
f01017a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01017a5:	eb f6                	jmp    f010179d <strncmp+0x32>

f01017a7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01017a7:	f3 0f 1e fb          	endbr32 
f01017ab:	55                   	push   %ebp
f01017ac:	89 e5                	mov    %esp,%ebp
f01017ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01017b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017b5:	0f b6 10             	movzbl (%eax),%edx
f01017b8:	84 d2                	test   %dl,%dl
f01017ba:	74 09                	je     f01017c5 <strchr+0x1e>
		if (*s == c)
f01017bc:	38 ca                	cmp    %cl,%dl
f01017be:	74 0a                	je     f01017ca <strchr+0x23>
	for (; *s; s++)
f01017c0:	83 c0 01             	add    $0x1,%eax
f01017c3:	eb f0                	jmp    f01017b5 <strchr+0xe>
			return (char *) s;
	return 0;
f01017c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017ca:	5d                   	pop    %ebp
f01017cb:	c3                   	ret    

f01017cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01017cc:	f3 0f 1e fb          	endbr32 
f01017d0:	55                   	push   %ebp
f01017d1:	89 e5                	mov    %esp,%ebp
f01017d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017da:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01017dd:	38 ca                	cmp    %cl,%dl
f01017df:	74 09                	je     f01017ea <strfind+0x1e>
f01017e1:	84 d2                	test   %dl,%dl
f01017e3:	74 05                	je     f01017ea <strfind+0x1e>
	for (; *s; s++)
f01017e5:	83 c0 01             	add    $0x1,%eax
f01017e8:	eb f0                	jmp    f01017da <strfind+0xe>
			break;
	return (char *) s;
}
f01017ea:	5d                   	pop    %ebp
f01017eb:	c3                   	ret    

f01017ec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01017ec:	f3 0f 1e fb          	endbr32 
f01017f0:	55                   	push   %ebp
f01017f1:	89 e5                	mov    %esp,%ebp
f01017f3:	57                   	push   %edi
f01017f4:	56                   	push   %esi
f01017f5:	53                   	push   %ebx
f01017f6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01017fc:	85 c9                	test   %ecx,%ecx
f01017fe:	74 31                	je     f0101831 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101800:	89 f8                	mov    %edi,%eax
f0101802:	09 c8                	or     %ecx,%eax
f0101804:	a8 03                	test   $0x3,%al
f0101806:	75 23                	jne    f010182b <memset+0x3f>
		c &= 0xFF;
f0101808:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010180c:	89 d3                	mov    %edx,%ebx
f010180e:	c1 e3 08             	shl    $0x8,%ebx
f0101811:	89 d0                	mov    %edx,%eax
f0101813:	c1 e0 18             	shl    $0x18,%eax
f0101816:	89 d6                	mov    %edx,%esi
f0101818:	c1 e6 10             	shl    $0x10,%esi
f010181b:	09 f0                	or     %esi,%eax
f010181d:	09 c2                	or     %eax,%edx
f010181f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101821:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101824:	89 d0                	mov    %edx,%eax
f0101826:	fc                   	cld    
f0101827:	f3 ab                	rep stos %eax,%es:(%edi)
f0101829:	eb 06                	jmp    f0101831 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010182b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010182e:	fc                   	cld    
f010182f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101831:	89 f8                	mov    %edi,%eax
f0101833:	5b                   	pop    %ebx
f0101834:	5e                   	pop    %esi
f0101835:	5f                   	pop    %edi
f0101836:	5d                   	pop    %ebp
f0101837:	c3                   	ret    

f0101838 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101838:	f3 0f 1e fb          	endbr32 
f010183c:	55                   	push   %ebp
f010183d:	89 e5                	mov    %esp,%ebp
f010183f:	57                   	push   %edi
f0101840:	56                   	push   %esi
f0101841:	8b 45 08             	mov    0x8(%ebp),%eax
f0101844:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101847:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010184a:	39 c6                	cmp    %eax,%esi
f010184c:	73 32                	jae    f0101880 <memmove+0x48>
f010184e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101851:	39 c2                	cmp    %eax,%edx
f0101853:	76 2b                	jbe    f0101880 <memmove+0x48>
		s += n;
		d += n;
f0101855:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101858:	89 fe                	mov    %edi,%esi
f010185a:	09 ce                	or     %ecx,%esi
f010185c:	09 d6                	or     %edx,%esi
f010185e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101864:	75 0e                	jne    f0101874 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101866:	83 ef 04             	sub    $0x4,%edi
f0101869:	8d 72 fc             	lea    -0x4(%edx),%esi
f010186c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010186f:	fd                   	std    
f0101870:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101872:	eb 09                	jmp    f010187d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101874:	83 ef 01             	sub    $0x1,%edi
f0101877:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f010187a:	fd                   	std    
f010187b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010187d:	fc                   	cld    
f010187e:	eb 1a                	jmp    f010189a <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101880:	89 c2                	mov    %eax,%edx
f0101882:	09 ca                	or     %ecx,%edx
f0101884:	09 f2                	or     %esi,%edx
f0101886:	f6 c2 03             	test   $0x3,%dl
f0101889:	75 0a                	jne    f0101895 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010188b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010188e:	89 c7                	mov    %eax,%edi
f0101890:	fc                   	cld    
f0101891:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101893:	eb 05                	jmp    f010189a <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0101895:	89 c7                	mov    %eax,%edi
f0101897:	fc                   	cld    
f0101898:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010189a:	5e                   	pop    %esi
f010189b:	5f                   	pop    %edi
f010189c:	5d                   	pop    %ebp
f010189d:	c3                   	ret    

f010189e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010189e:	f3 0f 1e fb          	endbr32 
f01018a2:	55                   	push   %ebp
f01018a3:	89 e5                	mov    %esp,%ebp
f01018a5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01018a8:	ff 75 10             	pushl  0x10(%ebp)
f01018ab:	ff 75 0c             	pushl  0xc(%ebp)
f01018ae:	ff 75 08             	pushl  0x8(%ebp)
f01018b1:	e8 82 ff ff ff       	call   f0101838 <memmove>
}
f01018b6:	c9                   	leave  
f01018b7:	c3                   	ret    

f01018b8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01018b8:	f3 0f 1e fb          	endbr32 
f01018bc:	55                   	push   %ebp
f01018bd:	89 e5                	mov    %esp,%ebp
f01018bf:	56                   	push   %esi
f01018c0:	53                   	push   %ebx
f01018c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01018c4:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018c7:	89 c6                	mov    %eax,%esi
f01018c9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018cc:	39 f0                	cmp    %esi,%eax
f01018ce:	74 1c                	je     f01018ec <memcmp+0x34>
		if (*s1 != *s2)
f01018d0:	0f b6 08             	movzbl (%eax),%ecx
f01018d3:	0f b6 1a             	movzbl (%edx),%ebx
f01018d6:	38 d9                	cmp    %bl,%cl
f01018d8:	75 08                	jne    f01018e2 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01018da:	83 c0 01             	add    $0x1,%eax
f01018dd:	83 c2 01             	add    $0x1,%edx
f01018e0:	eb ea                	jmp    f01018cc <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f01018e2:	0f b6 c1             	movzbl %cl,%eax
f01018e5:	0f b6 db             	movzbl %bl,%ebx
f01018e8:	29 d8                	sub    %ebx,%eax
f01018ea:	eb 05                	jmp    f01018f1 <memcmp+0x39>
	}

	return 0;
f01018ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018f1:	5b                   	pop    %ebx
f01018f2:	5e                   	pop    %esi
f01018f3:	5d                   	pop    %ebp
f01018f4:	c3                   	ret    

f01018f5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01018f5:	f3 0f 1e fb          	endbr32 
f01018f9:	55                   	push   %ebp
f01018fa:	89 e5                	mov    %esp,%ebp
f01018fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01018ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101902:	89 c2                	mov    %eax,%edx
f0101904:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101907:	39 d0                	cmp    %edx,%eax
f0101909:	73 09                	jae    f0101914 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f010190b:	38 08                	cmp    %cl,(%eax)
f010190d:	74 05                	je     f0101914 <memfind+0x1f>
	for (; s < ends; s++)
f010190f:	83 c0 01             	add    $0x1,%eax
f0101912:	eb f3                	jmp    f0101907 <memfind+0x12>
			break;
	return (void *) s;
}
f0101914:	5d                   	pop    %ebp
f0101915:	c3                   	ret    

f0101916 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101916:	f3 0f 1e fb          	endbr32 
f010191a:	55                   	push   %ebp
f010191b:	89 e5                	mov    %esp,%ebp
f010191d:	57                   	push   %edi
f010191e:	56                   	push   %esi
f010191f:	53                   	push   %ebx
f0101920:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101923:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101926:	eb 03                	jmp    f010192b <strtol+0x15>
		s++;
f0101928:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010192b:	0f b6 01             	movzbl (%ecx),%eax
f010192e:	3c 20                	cmp    $0x20,%al
f0101930:	74 f6                	je     f0101928 <strtol+0x12>
f0101932:	3c 09                	cmp    $0x9,%al
f0101934:	74 f2                	je     f0101928 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0101936:	3c 2b                	cmp    $0x2b,%al
f0101938:	74 2a                	je     f0101964 <strtol+0x4e>
	int neg = 0;
f010193a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010193f:	3c 2d                	cmp    $0x2d,%al
f0101941:	74 2b                	je     f010196e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101943:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101949:	75 0f                	jne    f010195a <strtol+0x44>
f010194b:	80 39 30             	cmpb   $0x30,(%ecx)
f010194e:	74 28                	je     f0101978 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101950:	85 db                	test   %ebx,%ebx
f0101952:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101957:	0f 44 d8             	cmove  %eax,%ebx
f010195a:	b8 00 00 00 00       	mov    $0x0,%eax
f010195f:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101962:	eb 46                	jmp    f01019aa <strtol+0x94>
		s++;
f0101964:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101967:	bf 00 00 00 00       	mov    $0x0,%edi
f010196c:	eb d5                	jmp    f0101943 <strtol+0x2d>
		s++, neg = 1;
f010196e:	83 c1 01             	add    $0x1,%ecx
f0101971:	bf 01 00 00 00       	mov    $0x1,%edi
f0101976:	eb cb                	jmp    f0101943 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101978:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010197c:	74 0e                	je     f010198c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010197e:	85 db                	test   %ebx,%ebx
f0101980:	75 d8                	jne    f010195a <strtol+0x44>
		s++, base = 8;
f0101982:	83 c1 01             	add    $0x1,%ecx
f0101985:	bb 08 00 00 00       	mov    $0x8,%ebx
f010198a:	eb ce                	jmp    f010195a <strtol+0x44>
		s += 2, base = 16;
f010198c:	83 c1 02             	add    $0x2,%ecx
f010198f:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101994:	eb c4                	jmp    f010195a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0101996:	0f be d2             	movsbl %dl,%edx
f0101999:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010199c:	3b 55 10             	cmp    0x10(%ebp),%edx
f010199f:	7d 3a                	jge    f01019db <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01019a1:	83 c1 01             	add    $0x1,%ecx
f01019a4:	0f af 45 10          	imul   0x10(%ebp),%eax
f01019a8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01019aa:	0f b6 11             	movzbl (%ecx),%edx
f01019ad:	8d 72 d0             	lea    -0x30(%edx),%esi
f01019b0:	89 f3                	mov    %esi,%ebx
f01019b2:	80 fb 09             	cmp    $0x9,%bl
f01019b5:	76 df                	jbe    f0101996 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f01019b7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01019ba:	89 f3                	mov    %esi,%ebx
f01019bc:	80 fb 19             	cmp    $0x19,%bl
f01019bf:	77 08                	ja     f01019c9 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01019c1:	0f be d2             	movsbl %dl,%edx
f01019c4:	83 ea 57             	sub    $0x57,%edx
f01019c7:	eb d3                	jmp    f010199c <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f01019c9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01019cc:	89 f3                	mov    %esi,%ebx
f01019ce:	80 fb 19             	cmp    $0x19,%bl
f01019d1:	77 08                	ja     f01019db <strtol+0xc5>
			dig = *s - 'A' + 10;
f01019d3:	0f be d2             	movsbl %dl,%edx
f01019d6:	83 ea 37             	sub    $0x37,%edx
f01019d9:	eb c1                	jmp    f010199c <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f01019db:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01019df:	74 05                	je     f01019e6 <strtol+0xd0>
		*endptr = (char *) s;
f01019e1:	8b 75 0c             	mov    0xc(%ebp),%esi
f01019e4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01019e6:	89 c2                	mov    %eax,%edx
f01019e8:	f7 da                	neg    %edx
f01019ea:	85 ff                	test   %edi,%edi
f01019ec:	0f 45 c2             	cmovne %edx,%eax
}
f01019ef:	5b                   	pop    %ebx
f01019f0:	5e                   	pop    %esi
f01019f1:	5f                   	pop    %edi
f01019f2:	5d                   	pop    %ebp
f01019f3:	c3                   	ret    
f01019f4:	66 90                	xchg   %ax,%ax
f01019f6:	66 90                	xchg   %ax,%ax
f01019f8:	66 90                	xchg   %ax,%ax
f01019fa:	66 90                	xchg   %ax,%ax
f01019fc:	66 90                	xchg   %ax,%ax
f01019fe:	66 90                	xchg   %ax,%ax

f0101a00 <__udivdi3>:
f0101a00:	f3 0f 1e fb          	endbr32 
f0101a04:	55                   	push   %ebp
f0101a05:	57                   	push   %edi
f0101a06:	56                   	push   %esi
f0101a07:	53                   	push   %ebx
f0101a08:	83 ec 1c             	sub    $0x1c,%esp
f0101a0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101a0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101a13:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101a17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101a1b:	85 d2                	test   %edx,%edx
f0101a1d:	75 19                	jne    f0101a38 <__udivdi3+0x38>
f0101a1f:	39 f3                	cmp    %esi,%ebx
f0101a21:	76 4d                	jbe    f0101a70 <__udivdi3+0x70>
f0101a23:	31 ff                	xor    %edi,%edi
f0101a25:	89 e8                	mov    %ebp,%eax
f0101a27:	89 f2                	mov    %esi,%edx
f0101a29:	f7 f3                	div    %ebx
f0101a2b:	89 fa                	mov    %edi,%edx
f0101a2d:	83 c4 1c             	add    $0x1c,%esp
f0101a30:	5b                   	pop    %ebx
f0101a31:	5e                   	pop    %esi
f0101a32:	5f                   	pop    %edi
f0101a33:	5d                   	pop    %ebp
f0101a34:	c3                   	ret    
f0101a35:	8d 76 00             	lea    0x0(%esi),%esi
f0101a38:	39 f2                	cmp    %esi,%edx
f0101a3a:	76 14                	jbe    f0101a50 <__udivdi3+0x50>
f0101a3c:	31 ff                	xor    %edi,%edi
f0101a3e:	31 c0                	xor    %eax,%eax
f0101a40:	89 fa                	mov    %edi,%edx
f0101a42:	83 c4 1c             	add    $0x1c,%esp
f0101a45:	5b                   	pop    %ebx
f0101a46:	5e                   	pop    %esi
f0101a47:	5f                   	pop    %edi
f0101a48:	5d                   	pop    %ebp
f0101a49:	c3                   	ret    
f0101a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a50:	0f bd fa             	bsr    %edx,%edi
f0101a53:	83 f7 1f             	xor    $0x1f,%edi
f0101a56:	75 48                	jne    f0101aa0 <__udivdi3+0xa0>
f0101a58:	39 f2                	cmp    %esi,%edx
f0101a5a:	72 06                	jb     f0101a62 <__udivdi3+0x62>
f0101a5c:	31 c0                	xor    %eax,%eax
f0101a5e:	39 eb                	cmp    %ebp,%ebx
f0101a60:	77 de                	ja     f0101a40 <__udivdi3+0x40>
f0101a62:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a67:	eb d7                	jmp    f0101a40 <__udivdi3+0x40>
f0101a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a70:	89 d9                	mov    %ebx,%ecx
f0101a72:	85 db                	test   %ebx,%ebx
f0101a74:	75 0b                	jne    f0101a81 <__udivdi3+0x81>
f0101a76:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a7b:	31 d2                	xor    %edx,%edx
f0101a7d:	f7 f3                	div    %ebx
f0101a7f:	89 c1                	mov    %eax,%ecx
f0101a81:	31 d2                	xor    %edx,%edx
f0101a83:	89 f0                	mov    %esi,%eax
f0101a85:	f7 f1                	div    %ecx
f0101a87:	89 c6                	mov    %eax,%esi
f0101a89:	89 e8                	mov    %ebp,%eax
f0101a8b:	89 f7                	mov    %esi,%edi
f0101a8d:	f7 f1                	div    %ecx
f0101a8f:	89 fa                	mov    %edi,%edx
f0101a91:	83 c4 1c             	add    $0x1c,%esp
f0101a94:	5b                   	pop    %ebx
f0101a95:	5e                   	pop    %esi
f0101a96:	5f                   	pop    %edi
f0101a97:	5d                   	pop    %ebp
f0101a98:	c3                   	ret    
f0101a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101aa0:	89 f9                	mov    %edi,%ecx
f0101aa2:	b8 20 00 00 00       	mov    $0x20,%eax
f0101aa7:	29 f8                	sub    %edi,%eax
f0101aa9:	d3 e2                	shl    %cl,%edx
f0101aab:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101aaf:	89 c1                	mov    %eax,%ecx
f0101ab1:	89 da                	mov    %ebx,%edx
f0101ab3:	d3 ea                	shr    %cl,%edx
f0101ab5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101ab9:	09 d1                	or     %edx,%ecx
f0101abb:	89 f2                	mov    %esi,%edx
f0101abd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ac1:	89 f9                	mov    %edi,%ecx
f0101ac3:	d3 e3                	shl    %cl,%ebx
f0101ac5:	89 c1                	mov    %eax,%ecx
f0101ac7:	d3 ea                	shr    %cl,%edx
f0101ac9:	89 f9                	mov    %edi,%ecx
f0101acb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101acf:	89 eb                	mov    %ebp,%ebx
f0101ad1:	d3 e6                	shl    %cl,%esi
f0101ad3:	89 c1                	mov    %eax,%ecx
f0101ad5:	d3 eb                	shr    %cl,%ebx
f0101ad7:	09 de                	or     %ebx,%esi
f0101ad9:	89 f0                	mov    %esi,%eax
f0101adb:	f7 74 24 08          	divl   0x8(%esp)
f0101adf:	89 d6                	mov    %edx,%esi
f0101ae1:	89 c3                	mov    %eax,%ebx
f0101ae3:	f7 64 24 0c          	mull   0xc(%esp)
f0101ae7:	39 d6                	cmp    %edx,%esi
f0101ae9:	72 15                	jb     f0101b00 <__udivdi3+0x100>
f0101aeb:	89 f9                	mov    %edi,%ecx
f0101aed:	d3 e5                	shl    %cl,%ebp
f0101aef:	39 c5                	cmp    %eax,%ebp
f0101af1:	73 04                	jae    f0101af7 <__udivdi3+0xf7>
f0101af3:	39 d6                	cmp    %edx,%esi
f0101af5:	74 09                	je     f0101b00 <__udivdi3+0x100>
f0101af7:	89 d8                	mov    %ebx,%eax
f0101af9:	31 ff                	xor    %edi,%edi
f0101afb:	e9 40 ff ff ff       	jmp    f0101a40 <__udivdi3+0x40>
f0101b00:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101b03:	31 ff                	xor    %edi,%edi
f0101b05:	e9 36 ff ff ff       	jmp    f0101a40 <__udivdi3+0x40>
f0101b0a:	66 90                	xchg   %ax,%ax
f0101b0c:	66 90                	xchg   %ax,%ax
f0101b0e:	66 90                	xchg   %ax,%ax

f0101b10 <__umoddi3>:
f0101b10:	f3 0f 1e fb          	endbr32 
f0101b14:	55                   	push   %ebp
f0101b15:	57                   	push   %edi
f0101b16:	56                   	push   %esi
f0101b17:	53                   	push   %ebx
f0101b18:	83 ec 1c             	sub    $0x1c,%esp
f0101b1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101b1f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101b23:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101b27:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101b2b:	85 c0                	test   %eax,%eax
f0101b2d:	75 19                	jne    f0101b48 <__umoddi3+0x38>
f0101b2f:	39 df                	cmp    %ebx,%edi
f0101b31:	76 5d                	jbe    f0101b90 <__umoddi3+0x80>
f0101b33:	89 f0                	mov    %esi,%eax
f0101b35:	89 da                	mov    %ebx,%edx
f0101b37:	f7 f7                	div    %edi
f0101b39:	89 d0                	mov    %edx,%eax
f0101b3b:	31 d2                	xor    %edx,%edx
f0101b3d:	83 c4 1c             	add    $0x1c,%esp
f0101b40:	5b                   	pop    %ebx
f0101b41:	5e                   	pop    %esi
f0101b42:	5f                   	pop    %edi
f0101b43:	5d                   	pop    %ebp
f0101b44:	c3                   	ret    
f0101b45:	8d 76 00             	lea    0x0(%esi),%esi
f0101b48:	89 f2                	mov    %esi,%edx
f0101b4a:	39 d8                	cmp    %ebx,%eax
f0101b4c:	76 12                	jbe    f0101b60 <__umoddi3+0x50>
f0101b4e:	89 f0                	mov    %esi,%eax
f0101b50:	89 da                	mov    %ebx,%edx
f0101b52:	83 c4 1c             	add    $0x1c,%esp
f0101b55:	5b                   	pop    %ebx
f0101b56:	5e                   	pop    %esi
f0101b57:	5f                   	pop    %edi
f0101b58:	5d                   	pop    %ebp
f0101b59:	c3                   	ret    
f0101b5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b60:	0f bd e8             	bsr    %eax,%ebp
f0101b63:	83 f5 1f             	xor    $0x1f,%ebp
f0101b66:	75 50                	jne    f0101bb8 <__umoddi3+0xa8>
f0101b68:	39 d8                	cmp    %ebx,%eax
f0101b6a:	0f 82 e0 00 00 00    	jb     f0101c50 <__umoddi3+0x140>
f0101b70:	89 d9                	mov    %ebx,%ecx
f0101b72:	39 f7                	cmp    %esi,%edi
f0101b74:	0f 86 d6 00 00 00    	jbe    f0101c50 <__umoddi3+0x140>
f0101b7a:	89 d0                	mov    %edx,%eax
f0101b7c:	89 ca                	mov    %ecx,%edx
f0101b7e:	83 c4 1c             	add    $0x1c,%esp
f0101b81:	5b                   	pop    %ebx
f0101b82:	5e                   	pop    %esi
f0101b83:	5f                   	pop    %edi
f0101b84:	5d                   	pop    %ebp
f0101b85:	c3                   	ret    
f0101b86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b8d:	8d 76 00             	lea    0x0(%esi),%esi
f0101b90:	89 fd                	mov    %edi,%ebp
f0101b92:	85 ff                	test   %edi,%edi
f0101b94:	75 0b                	jne    f0101ba1 <__umoddi3+0x91>
f0101b96:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b9b:	31 d2                	xor    %edx,%edx
f0101b9d:	f7 f7                	div    %edi
f0101b9f:	89 c5                	mov    %eax,%ebp
f0101ba1:	89 d8                	mov    %ebx,%eax
f0101ba3:	31 d2                	xor    %edx,%edx
f0101ba5:	f7 f5                	div    %ebp
f0101ba7:	89 f0                	mov    %esi,%eax
f0101ba9:	f7 f5                	div    %ebp
f0101bab:	89 d0                	mov    %edx,%eax
f0101bad:	31 d2                	xor    %edx,%edx
f0101baf:	eb 8c                	jmp    f0101b3d <__umoddi3+0x2d>
f0101bb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101bb8:	89 e9                	mov    %ebp,%ecx
f0101bba:	ba 20 00 00 00       	mov    $0x20,%edx
f0101bbf:	29 ea                	sub    %ebp,%edx
f0101bc1:	d3 e0                	shl    %cl,%eax
f0101bc3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bc7:	89 d1                	mov    %edx,%ecx
f0101bc9:	89 f8                	mov    %edi,%eax
f0101bcb:	d3 e8                	shr    %cl,%eax
f0101bcd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101bd1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101bd5:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101bd9:	09 c1                	or     %eax,%ecx
f0101bdb:	89 d8                	mov    %ebx,%eax
f0101bdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101be1:	89 e9                	mov    %ebp,%ecx
f0101be3:	d3 e7                	shl    %cl,%edi
f0101be5:	89 d1                	mov    %edx,%ecx
f0101be7:	d3 e8                	shr    %cl,%eax
f0101be9:	89 e9                	mov    %ebp,%ecx
f0101beb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101bef:	d3 e3                	shl    %cl,%ebx
f0101bf1:	89 c7                	mov    %eax,%edi
f0101bf3:	89 d1                	mov    %edx,%ecx
f0101bf5:	89 f0                	mov    %esi,%eax
f0101bf7:	d3 e8                	shr    %cl,%eax
f0101bf9:	89 e9                	mov    %ebp,%ecx
f0101bfb:	89 fa                	mov    %edi,%edx
f0101bfd:	d3 e6                	shl    %cl,%esi
f0101bff:	09 d8                	or     %ebx,%eax
f0101c01:	f7 74 24 08          	divl   0x8(%esp)
f0101c05:	89 d1                	mov    %edx,%ecx
f0101c07:	89 f3                	mov    %esi,%ebx
f0101c09:	f7 64 24 0c          	mull   0xc(%esp)
f0101c0d:	89 c6                	mov    %eax,%esi
f0101c0f:	89 d7                	mov    %edx,%edi
f0101c11:	39 d1                	cmp    %edx,%ecx
f0101c13:	72 06                	jb     f0101c1b <__umoddi3+0x10b>
f0101c15:	75 10                	jne    f0101c27 <__umoddi3+0x117>
f0101c17:	39 c3                	cmp    %eax,%ebx
f0101c19:	73 0c                	jae    f0101c27 <__umoddi3+0x117>
f0101c1b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101c1f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101c23:	89 d7                	mov    %edx,%edi
f0101c25:	89 c6                	mov    %eax,%esi
f0101c27:	89 ca                	mov    %ecx,%edx
f0101c29:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101c2e:	29 f3                	sub    %esi,%ebx
f0101c30:	19 fa                	sbb    %edi,%edx
f0101c32:	89 d0                	mov    %edx,%eax
f0101c34:	d3 e0                	shl    %cl,%eax
f0101c36:	89 e9                	mov    %ebp,%ecx
f0101c38:	d3 eb                	shr    %cl,%ebx
f0101c3a:	d3 ea                	shr    %cl,%edx
f0101c3c:	09 d8                	or     %ebx,%eax
f0101c3e:	83 c4 1c             	add    $0x1c,%esp
f0101c41:	5b                   	pop    %ebx
f0101c42:	5e                   	pop    %esi
f0101c43:	5f                   	pop    %edi
f0101c44:	5d                   	pop    %ebp
f0101c45:	c3                   	ret    
f0101c46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c4d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c50:	29 fe                	sub    %edi,%esi
f0101c52:	19 c3                	sbb    %eax,%ebx
f0101c54:	89 f2                	mov    %esi,%edx
f0101c56:	89 d9                	mov    %ebx,%ecx
f0101c58:	e9 1d ff ff ff       	jmp    f0101b7a <__umoddi3+0x6a>
