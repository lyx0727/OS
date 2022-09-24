
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

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
f010004e:	81 c3 ba 12 01 00    	add    $0x112ba,%ebx
f0100054:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100057:	83 ec 08             	sub    $0x8,%esp
f010005a:	56                   	push   %esi
f010005b:	8d 83 78 08 ff ff    	lea    -0xf788(%ebx),%eax
f0100061:	50                   	push   %eax
f0100062:	e8 a0 0a 00 00       	call   f0100b07 <cprintf>
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
f0100081:	8d 83 94 08 ff ff    	lea    -0xf76c(%ebx),%eax
f0100087:	50                   	push   %eax
f0100088:	e8 7a 0a 00 00       	call   f0100b07 <cprintf>
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
f01000ba:	81 c3 4e 12 01 00    	add    $0x1124e,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000c0:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000c6:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000cc:	29 d0                	sub    %edx,%eax
f01000ce:	50                   	push   %eax
f01000cf:	6a 00                	push   $0x0
f01000d1:	52                   	push   %edx
f01000d2:	e8 3b 16 00 00       	call   f0101712 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d7:	e8 4b 05 00 00       	call   f0100627 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000dc:	83 c4 08             	add    $0x8,%esp
f01000df:	68 ac 1a 00 00       	push   $0x1aac
f01000e4:	8d 83 af 08 ff ff    	lea    -0xf751(%ebx),%eax
f01000ea:	50                   	push   %eax
f01000eb:	e8 17 0a 00 00       	call   f0100b07 <cprintf>

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
f0100104:	e8 2c 08 00 00       	call   f0100935 <monitor>
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
f0100120:	81 c3 e8 11 01 00    	add    $0x111e8,%ebx
f0100126:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100129:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f010012f:	83 38 00             	cmpl   $0x0,(%eax)
f0100132:	74 0f                	je     f0100143 <_panic+0x35>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100134:	83 ec 0c             	sub    $0xc,%esp
f0100137:	6a 00                	push   $0x0
f0100139:	e8 f7 07 00 00       	call   f0100935 <monitor>
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
f0100153:	8d 83 ca 08 ff ff    	lea    -0xf736(%ebx),%eax
f0100159:	50                   	push   %eax
f010015a:	e8 a8 09 00 00       	call   f0100b07 <cprintf>
	vcprintf(fmt, ap);
f010015f:	83 c4 08             	add    $0x8,%esp
f0100162:	56                   	push   %esi
f0100163:	57                   	push   %edi
f0100164:	e8 63 09 00 00       	call   f0100acc <vcprintf>
	cprintf("\n");
f0100169:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f010016f:	89 04 24             	mov    %eax,(%esp)
f0100172:	e8 90 09 00 00       	call   f0100b07 <cprintf>
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
f010018a:	81 c3 7e 11 01 00    	add    $0x1117e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100190:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100193:	83 ec 04             	sub    $0x4,%esp
f0100196:	ff 75 0c             	pushl  0xc(%ebp)
f0100199:	ff 75 08             	pushl  0x8(%ebp)
f010019c:	8d 83 e2 08 ff ff    	lea    -0xf71e(%ebx),%eax
f01001a2:	50                   	push   %eax
f01001a3:	e8 5f 09 00 00       	call   f0100b07 <cprintf>
	vcprintf(fmt, ap);
f01001a8:	83 c4 08             	add    $0x8,%esp
f01001ab:	56                   	push   %esi
f01001ac:	ff 75 10             	pushl  0x10(%ebp)
f01001af:	e8 18 09 00 00       	call   f0100acc <vcprintf>
	cprintf("\n");
f01001b4:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f01001ba:	89 04 24             	mov    %eax,(%esp)
f01001bd:	e8 45 09 00 00       	call   f0100b07 <cprintf>
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
f01001fc:	81 c6 0c 11 01 00    	add    $0x1110c,%esi
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
f010025e:	81 c3 aa 10 01 00    	add    $0x110aa,%ebx
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
f01002a6:	0f b6 84 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%eax
f01002ad:	ff 
f01002ae:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f01002b4:	0f b6 8c 13 38 09 ff 	movzbl -0xf6c8(%ebx,%edx,1),%ecx
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
f0100315:	0f b6 84 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%eax
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
f0100351:	8d 83 fc 08 ff ff    	lea    -0xf704(%ebx),%eax
f0100357:	50                   	push   %eax
f0100358:	e8 aa 07 00 00       	call   f0100b07 <cprintf>
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
f010038c:	81 c3 7c 0f 01 00    	add    $0x10f7c,%ebx
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
f010054e:	e8 0b 12 00 00       	call   f010175e <memmove>
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
f010058a:	05 7e 0d 01 00       	add    $0x10d7e,%eax
	if (serial_exists)
f010058f:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100596:	75 01                	jne    f0100599 <serial_intr+0x18>
f0100598:	c3                   	ret    
{
f0100599:	55                   	push   %ebp
f010059a:	89 e5                	mov    %esp,%ebp
f010059c:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010059f:	8d 80 c8 ee fe ff    	lea    -0x11138(%eax),%eax
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
f01005bb:	05 4d 0d 01 00       	add    $0x10d4d,%eax
	cons_intr(kbd_proc_data);
f01005c0:	8d 80 48 ef fe ff    	lea    -0x110b8(%eax),%eax
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
f01005dd:	81 c3 2b 0d 01 00    	add    $0x10d2b,%ebx
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
f0100639:	81 c3 cf 0c 01 00    	add    $0x10ccf,%ebx
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
f010073c:	8d 83 08 09 ff ff    	lea    -0xf6f8(%ebx),%eax
f0100742:	50                   	push   %eax
f0100743:	e8 bf 03 00 00       	call   f0100b07 <cprintf>
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
f0100796:	81 c3 72 0b 01 00    	add    $0x10b72,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079c:	83 ec 04             	sub    $0x4,%esp
f010079f:	8d 83 38 0b ff ff    	lea    -0xf4c8(%ebx),%eax
f01007a5:	50                   	push   %eax
f01007a6:	8d 83 56 0b ff ff    	lea    -0xf4aa(%ebx),%eax
f01007ac:	50                   	push   %eax
f01007ad:	8d b3 5b 0b ff ff    	lea    -0xf4a5(%ebx),%esi
f01007b3:	56                   	push   %esi
f01007b4:	e8 4e 03 00 00       	call   f0100b07 <cprintf>
f01007b9:	83 c4 0c             	add    $0xc,%esp
f01007bc:	8d 83 e0 0b ff ff    	lea    -0xf420(%ebx),%eax
f01007c2:	50                   	push   %eax
f01007c3:	8d 83 64 0b ff ff    	lea    -0xf49c(%ebx),%eax
f01007c9:	50                   	push   %eax
f01007ca:	56                   	push   %esi
f01007cb:	e8 37 03 00 00       	call   f0100b07 <cprintf>
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
f01007ee:	81 c3 1a 0b 01 00    	add    $0x10b1a,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f4:	8d 83 6d 0b ff ff    	lea    -0xf493(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 07 03 00 00       	call   f0100b07 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100800:	83 c4 08             	add    $0x8,%esp
f0100803:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f0100809:	8d 83 08 0c ff ff    	lea    -0xf3f8(%ebx),%eax
f010080f:	50                   	push   %eax
f0100810:	e8 f2 02 00 00       	call   f0100b07 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100815:	83 c4 0c             	add    $0xc,%esp
f0100818:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f010081e:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100824:	50                   	push   %eax
f0100825:	57                   	push   %edi
f0100826:	8d 83 30 0c ff ff    	lea    -0xf3d0(%ebx),%eax
f010082c:	50                   	push   %eax
f010082d:	e8 d5 02 00 00       	call   f0100b07 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100832:	83 c4 0c             	add    $0xc,%esp
f0100835:	c7 c0 7d 1b 10 f0    	mov    $0xf0101b7d,%eax
f010083b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100841:	52                   	push   %edx
f0100842:	50                   	push   %eax
f0100843:	8d 83 54 0c ff ff    	lea    -0xf3ac(%ebx),%eax
f0100849:	50                   	push   %eax
f010084a:	e8 b8 02 00 00       	call   f0100b07 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084f:	83 c4 0c             	add    $0xc,%esp
f0100852:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f0100858:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010085e:	52                   	push   %edx
f010085f:	50                   	push   %eax
f0100860:	8d 83 78 0c ff ff    	lea    -0xf388(%ebx),%eax
f0100866:	50                   	push   %eax
f0100867:	e8 9b 02 00 00       	call   f0100b07 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086c:	83 c4 0c             	add    $0xc,%esp
f010086f:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100875:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010087b:	50                   	push   %eax
f010087c:	56                   	push   %esi
f010087d:	8d 83 9c 0c ff ff    	lea    -0xf364(%ebx),%eax
f0100883:	50                   	push   %eax
f0100884:	e8 7e 02 00 00       	call   f0100b07 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100889:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010088c:	29 fe                	sub    %edi,%esi
f010088e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100894:	c1 fe 0a             	sar    $0xa,%esi
f0100897:	56                   	push   %esi
f0100898:	8d 83 c0 0c ff ff    	lea    -0xf340(%ebx),%eax
f010089e:	50                   	push   %eax
f010089f:	e8 63 02 00 00       	call   f0100b07 <cprintf>
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
f01008bb:	83 ec 1c             	sub    $0x1c,%esp
f01008be:	e8 09 f9 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01008c3:	81 c3 45 0a 01 00    	add    $0x10a45,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008c9:	89 ef                	mov    %ebp,%edi
	uint32_t* ebp = (uint32_t*)read_ebp();
	int i;
	while(ebp){
		uint32_t eip = *(ebp + 1);
		cprintf("ebp %08x eip %08x args", ebp, eip);
f01008cb:	8d 83 86 0b ff ff    	lea    -0xf47a(%ebx),%eax
f01008d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		for(i = 0; i < 4; i++){
			cprintf(" %08x", *(ebp + 2 + i));
f01008d4:	8d 83 9d 0b ff ff    	lea    -0xf463(%ebx),%eax
f01008da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	while(ebp){
f01008dd:	eb 45                	jmp    f0100924 <mon_backtrace+0x73>
		cprintf("ebp %08x eip %08x args", ebp, eip);
f01008df:	83 ec 04             	sub    $0x4,%esp
f01008e2:	ff 77 04             	pushl  0x4(%edi)
f01008e5:	57                   	push   %edi
f01008e6:	ff 75 e0             	pushl  -0x20(%ebp)
f01008e9:	e8 19 02 00 00       	call   f0100b07 <cprintf>
f01008ee:	83 c4 10             	add    $0x10,%esp
		for(i = 0; i < 4; i++){
f01008f1:	be 00 00 00 00       	mov    $0x0,%esi
			cprintf(" %08x", *(ebp + 2 + i));
f01008f6:	83 ec 08             	sub    $0x8,%esp
f01008f9:	ff 74 b7 08          	pushl  0x8(%edi,%esi,4)
f01008fd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100900:	e8 02 02 00 00       	call   f0100b07 <cprintf>
		for(i = 0; i < 4; i++){
f0100905:	83 c6 01             	add    $0x1,%esi
f0100908:	83 c4 10             	add    $0x10,%esp
f010090b:	83 fe 04             	cmp    $0x4,%esi
f010090e:	75 e6                	jne    f01008f6 <mon_backtrace+0x45>
		}
		cprintf("\n");
f0100910:	83 ec 0c             	sub    $0xc,%esp
f0100913:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f0100919:	50                   	push   %eax
f010091a:	e8 e8 01 00 00       	call   f0100b07 <cprintf>
		ebp = (uint32_t*)(*ebp);
f010091f:	8b 3f                	mov    (%edi),%edi
f0100921:	83 c4 10             	add    $0x10,%esp
	while(ebp){
f0100924:	85 ff                	test   %edi,%edi
f0100926:	75 b7                	jne    f01008df <mon_backtrace+0x2e>
	// 		cprintf("%08x ", arg[i]);
	// 	cprintf("\n");
	// 	ebp = (uint32_t*) (*ebp);
	// }
	return 0;
}
f0100928:	b8 00 00 00 00       	mov    $0x0,%eax
f010092d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100930:	5b                   	pop    %ebx
f0100931:	5e                   	pop    %esi
f0100932:	5f                   	pop    %edi
f0100933:	5d                   	pop    %ebp
f0100934:	c3                   	ret    

f0100935 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100935:	f3 0f 1e fb          	endbr32 
f0100939:	55                   	push   %ebp
f010093a:	89 e5                	mov    %esp,%ebp
f010093c:	57                   	push   %edi
f010093d:	56                   	push   %esi
f010093e:	53                   	push   %ebx
f010093f:	83 ec 68             	sub    $0x68,%esp
f0100942:	e8 85 f8 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100947:	81 c3 c1 09 01 00    	add    $0x109c1,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010094d:	8d 83 ec 0c ff ff    	lea    -0xf314(%ebx),%eax
f0100953:	50                   	push   %eax
f0100954:	e8 ae 01 00 00       	call   f0100b07 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100959:	8d 83 10 0d ff ff    	lea    -0xf2f0(%ebx),%eax
f010095f:	89 04 24             	mov    %eax,(%esp)
f0100962:	e8 a0 01 00 00       	call   f0100b07 <cprintf>
f0100967:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010096a:	8d 83 a7 0b ff ff    	lea    -0xf459(%ebx),%eax
f0100970:	89 45 a0             	mov    %eax,-0x60(%ebp)
f0100973:	e9 dc 00 00 00       	jmp    f0100a54 <monitor+0x11f>
f0100978:	83 ec 08             	sub    $0x8,%esp
f010097b:	0f be c0             	movsbl %al,%eax
f010097e:	50                   	push   %eax
f010097f:	ff 75 a0             	pushl  -0x60(%ebp)
f0100982:	e8 46 0d 00 00       	call   f01016cd <strchr>
f0100987:	83 c4 10             	add    $0x10,%esp
f010098a:	85 c0                	test   %eax,%eax
f010098c:	74 74                	je     f0100a02 <monitor+0xcd>
			*buf++ = 0;
f010098e:	c6 06 00             	movb   $0x0,(%esi)
f0100991:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100994:	8d 76 01             	lea    0x1(%esi),%esi
f0100997:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f010099a:	0f b6 06             	movzbl (%esi),%eax
f010099d:	84 c0                	test   %al,%al
f010099f:	75 d7                	jne    f0100978 <monitor+0x43>
	argv[argc] = 0;
f01009a1:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f01009a8:	00 
	if (argc == 0)
f01009a9:	85 ff                	test   %edi,%edi
f01009ab:	0f 84 a3 00 00 00    	je     f0100a54 <monitor+0x11f>
		if (strcmp(argv[0], commands[i].name) == 0)
f01009b1:	83 ec 08             	sub    $0x8,%esp
f01009b4:	8d 83 56 0b ff ff    	lea    -0xf4aa(%ebx),%eax
f01009ba:	50                   	push   %eax
f01009bb:	ff 75 a8             	pushl  -0x58(%ebp)
f01009be:	e8 a4 0c 00 00       	call   f0101667 <strcmp>
f01009c3:	83 c4 10             	add    $0x10,%esp
f01009c6:	85 c0                	test   %eax,%eax
f01009c8:	0f 84 b4 00 00 00    	je     f0100a82 <monitor+0x14d>
f01009ce:	83 ec 08             	sub    $0x8,%esp
f01009d1:	8d 83 64 0b ff ff    	lea    -0xf49c(%ebx),%eax
f01009d7:	50                   	push   %eax
f01009d8:	ff 75 a8             	pushl  -0x58(%ebp)
f01009db:	e8 87 0c 00 00       	call   f0101667 <strcmp>
f01009e0:	83 c4 10             	add    $0x10,%esp
f01009e3:	85 c0                	test   %eax,%eax
f01009e5:	0f 84 92 00 00 00    	je     f0100a7d <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009eb:	83 ec 08             	sub    $0x8,%esp
f01009ee:	ff 75 a8             	pushl  -0x58(%ebp)
f01009f1:	8d 83 c9 0b ff ff    	lea    -0xf437(%ebx),%eax
f01009f7:	50                   	push   %eax
f01009f8:	e8 0a 01 00 00       	call   f0100b07 <cprintf>
	return 0;
f01009fd:	83 c4 10             	add    $0x10,%esp
f0100a00:	eb 52                	jmp    f0100a54 <monitor+0x11f>
		if (*buf == 0)
f0100a02:	80 3e 00             	cmpb   $0x0,(%esi)
f0100a05:	74 9a                	je     f01009a1 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f0100a07:	83 ff 0f             	cmp    $0xf,%edi
f0100a0a:	74 34                	je     f0100a40 <monitor+0x10b>
		argv[argc++] = buf;
f0100a0c:	8d 47 01             	lea    0x1(%edi),%eax
f0100a0f:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100a12:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a16:	0f b6 06             	movzbl (%esi),%eax
f0100a19:	84 c0                	test   %al,%al
f0100a1b:	0f 84 76 ff ff ff    	je     f0100997 <monitor+0x62>
f0100a21:	83 ec 08             	sub    $0x8,%esp
f0100a24:	0f be c0             	movsbl %al,%eax
f0100a27:	50                   	push   %eax
f0100a28:	ff 75 a0             	pushl  -0x60(%ebp)
f0100a2b:	e8 9d 0c 00 00       	call   f01016cd <strchr>
f0100a30:	83 c4 10             	add    $0x10,%esp
f0100a33:	85 c0                	test   %eax,%eax
f0100a35:	0f 85 5c ff ff ff    	jne    f0100997 <monitor+0x62>
			buf++;
f0100a3b:	83 c6 01             	add    $0x1,%esi
f0100a3e:	eb d6                	jmp    f0100a16 <monitor+0xe1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a40:	83 ec 08             	sub    $0x8,%esp
f0100a43:	6a 10                	push   $0x10
f0100a45:	8d 83 ac 0b ff ff    	lea    -0xf454(%ebx),%eax
f0100a4b:	50                   	push   %eax
f0100a4c:	e8 b6 00 00 00       	call   f0100b07 <cprintf>
			return 0;
f0100a51:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100a54:	8d bb a3 0b ff ff    	lea    -0xf45d(%ebx),%edi
f0100a5a:	83 ec 0c             	sub    $0xc,%esp
f0100a5d:	57                   	push   %edi
f0100a5e:	e8 f9 09 00 00       	call   f010145c <readline>
f0100a63:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100a65:	83 c4 10             	add    $0x10,%esp
f0100a68:	85 c0                	test   %eax,%eax
f0100a6a:	74 ee                	je     f0100a5a <monitor+0x125>
	argv[argc] = 0;
f0100a6c:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a73:	bf 00 00 00 00       	mov    $0x0,%edi
f0100a78:	e9 1d ff ff ff       	jmp    f010099a <monitor+0x65>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a7d:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a82:	83 ec 04             	sub    $0x4,%esp
f0100a85:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a88:	ff 75 08             	pushl  0x8(%ebp)
f0100a8b:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a8e:	52                   	push   %edx
f0100a8f:	57                   	push   %edi
f0100a90:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a97:	83 c4 10             	add    $0x10,%esp
f0100a9a:	85 c0                	test   %eax,%eax
f0100a9c:	79 b6                	jns    f0100a54 <monitor+0x11f>
				break;
	}
}
f0100a9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aa1:	5b                   	pop    %ebx
f0100aa2:	5e                   	pop    %esi
f0100aa3:	5f                   	pop    %edi
f0100aa4:	5d                   	pop    %ebp
f0100aa5:	c3                   	ret    

f0100aa6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100aa6:	f3 0f 1e fb          	endbr32 
f0100aaa:	55                   	push   %ebp
f0100aab:	89 e5                	mov    %esp,%ebp
f0100aad:	53                   	push   %ebx
f0100aae:	83 ec 10             	sub    $0x10,%esp
f0100ab1:	e8 16 f7 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100ab6:	81 c3 52 08 01 00    	add    $0x10852,%ebx
	cputchar(ch);
f0100abc:	ff 75 08             	pushl  0x8(%ebp)
f0100abf:	e8 89 fc ff ff       	call   f010074d <cputchar>
	*cnt++;
}
f0100ac4:	83 c4 10             	add    $0x10,%esp
f0100ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100aca:	c9                   	leave  
f0100acb:	c3                   	ret    

f0100acc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100acc:	f3 0f 1e fb          	endbr32 
f0100ad0:	55                   	push   %ebp
f0100ad1:	89 e5                	mov    %esp,%ebp
f0100ad3:	53                   	push   %ebx
f0100ad4:	83 ec 14             	sub    $0x14,%esp
f0100ad7:	e8 f0 f6 ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f0100adc:	81 c3 2c 08 01 00    	add    $0x1082c,%ebx
	int cnt = 0;
f0100ae2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100ae9:	ff 75 0c             	pushl  0xc(%ebp)
f0100aec:	ff 75 08             	pushl  0x8(%ebp)
f0100aef:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100af2:	50                   	push   %eax
f0100af3:	8d 83 9e f7 fe ff    	lea    -0x10862(%ebx),%eax
f0100af9:	50                   	push   %eax
f0100afa:	e8 27 04 00 00       	call   f0100f26 <vprintfmt>
	return cnt;
}
f0100aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b05:	c9                   	leave  
f0100b06:	c3                   	ret    

f0100b07 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b07:	f3 0f 1e fb          	endbr32 
f0100b0b:	55                   	push   %ebp
f0100b0c:	89 e5                	mov    %esp,%ebp
f0100b0e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b11:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b14:	50                   	push   %eax
f0100b15:	ff 75 08             	pushl  0x8(%ebp)
f0100b18:	e8 af ff ff ff       	call   f0100acc <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b1d:	c9                   	leave  
f0100b1e:	c3                   	ret    

f0100b1f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b1f:	55                   	push   %ebp
f0100b20:	89 e5                	mov    %esp,%ebp
f0100b22:	57                   	push   %edi
f0100b23:	56                   	push   %esi
f0100b24:	53                   	push   %ebx
f0100b25:	83 ec 14             	sub    $0x14,%esp
f0100b28:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b2b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b2e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b31:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b34:	8b 1a                	mov    (%edx),%ebx
f0100b36:	8b 01                	mov    (%ecx),%eax
f0100b38:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b3b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b42:	eb 23                	jmp    f0100b67 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100b44:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100b47:	eb 1e                	jmp    f0100b67 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b49:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b4c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b4f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b53:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b56:	73 46                	jae    f0100b9e <stab_binsearch+0x7f>
			*region_left = m;
f0100b58:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100b5b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100b5d:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100b60:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b67:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100b6a:	7f 5f                	jg     f0100bcb <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100b6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b6f:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100b72:	89 d0                	mov    %edx,%eax
f0100b74:	c1 e8 1f             	shr    $0x1f,%eax
f0100b77:	01 d0                	add    %edx,%eax
f0100b79:	89 c7                	mov    %eax,%edi
f0100b7b:	d1 ff                	sar    %edi
f0100b7d:	83 e0 fe             	and    $0xfffffffe,%eax
f0100b80:	01 f8                	add    %edi,%eax
f0100b82:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b85:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100b89:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b8b:	39 c3                	cmp    %eax,%ebx
f0100b8d:	7f b5                	jg     f0100b44 <stab_binsearch+0x25>
f0100b8f:	0f b6 0a             	movzbl (%edx),%ecx
f0100b92:	83 ea 0c             	sub    $0xc,%edx
f0100b95:	39 f1                	cmp    %esi,%ecx
f0100b97:	74 b0                	je     f0100b49 <stab_binsearch+0x2a>
			m--;
f0100b99:	83 e8 01             	sub    $0x1,%eax
f0100b9c:	eb ed                	jmp    f0100b8b <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100b9e:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100ba1:	76 14                	jbe    f0100bb7 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100ba3:	83 e8 01             	sub    $0x1,%eax
f0100ba6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100ba9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bac:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100bae:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bb5:	eb b0                	jmp    f0100b67 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bba:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100bbc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bc0:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100bc2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bc9:	eb 9c                	jmp    f0100b67 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100bcb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100bcf:	75 15                	jne    f0100be6 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100bd1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bd4:	8b 00                	mov    (%eax),%eax
f0100bd6:	83 e8 01             	sub    $0x1,%eax
f0100bd9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100bdc:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100bde:	83 c4 14             	add    $0x14,%esp
f0100be1:	5b                   	pop    %ebx
f0100be2:	5e                   	pop    %esi
f0100be3:	5f                   	pop    %edi
f0100be4:	5d                   	pop    %ebp
f0100be5:	c3                   	ret    
		for (l = *region_right;
f0100be6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100be9:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100beb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bee:	8b 0f                	mov    (%edi),%ecx
f0100bf0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bf3:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100bf6:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100bfa:	eb 03                	jmp    f0100bff <stab_binsearch+0xe0>
		     l--)
f0100bfc:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100bff:	39 c1                	cmp    %eax,%ecx
f0100c01:	7d 0a                	jge    f0100c0d <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100c03:	0f b6 1a             	movzbl (%edx),%ebx
f0100c06:	83 ea 0c             	sub    $0xc,%edx
f0100c09:	39 f3                	cmp    %esi,%ebx
f0100c0b:	75 ef                	jne    f0100bfc <stab_binsearch+0xdd>
		*region_left = l;
f0100c0d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c10:	89 07                	mov    %eax,(%edi)
}
f0100c12:	eb ca                	jmp    f0100bde <stab_binsearch+0xbf>

f0100c14 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c14:	f3 0f 1e fb          	endbr32 
f0100c18:	55                   	push   %ebp
f0100c19:	89 e5                	mov    %esp,%ebp
f0100c1b:	57                   	push   %edi
f0100c1c:	56                   	push   %esi
f0100c1d:	53                   	push   %ebx
f0100c1e:	83 ec 2c             	sub    $0x2c,%esp
f0100c21:	e8 fc 01 00 00       	call   f0100e22 <__x86.get_pc_thunk.cx>
f0100c26:	81 c1 e2 06 01 00    	add    $0x106e2,%ecx
f0100c2c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100c2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100c32:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c35:	8d 81 35 0d ff ff    	lea    -0xf2cb(%ecx),%eax
f0100c3b:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100c3d:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100c44:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100c47:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100c4e:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0100c51:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c58:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0100c5e:	0f 86 f4 00 00 00    	jbe    f0100d58 <debuginfo_eip+0x144>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c64:	c7 c0 21 66 10 f0    	mov    $0xf0106621,%eax
f0100c6a:	39 81 fc ff ff ff    	cmp    %eax,-0x4(%ecx)
f0100c70:	0f 86 88 01 00 00    	jbe    f0100dfe <debuginfo_eip+0x1ea>
f0100c76:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100c79:	c7 c0 b2 7f 10 f0    	mov    $0xf0107fb2,%eax
f0100c7f:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c83:	0f 85 7c 01 00 00    	jne    f0100e05 <debuginfo_eip+0x1f1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c89:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c90:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100c96:	c7 c2 20 66 10 f0    	mov    $0xf0106620,%edx
f0100c9c:	29 c2                	sub    %eax,%edx
f0100c9e:	c1 fa 02             	sar    $0x2,%edx
f0100ca1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100ca7:	83 ea 01             	sub    $0x1,%edx
f0100caa:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cad:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cb0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cb3:	83 ec 08             	sub    $0x8,%esp
f0100cb6:	53                   	push   %ebx
f0100cb7:	6a 64                	push   $0x64
f0100cb9:	e8 61 fe ff ff       	call   f0100b1f <stab_binsearch>
	if (lfile == 0)
f0100cbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cc1:	83 c4 10             	add    $0x10,%esp
f0100cc4:	85 c0                	test   %eax,%eax
f0100cc6:	0f 84 40 01 00 00    	je     f0100e0c <debuginfo_eip+0x1f8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ccc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ccf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cd2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100cd5:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100cd8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100cdb:	83 ec 08             	sub    $0x8,%esp
f0100cde:	53                   	push   %ebx
f0100cdf:	6a 24                	push   $0x24
f0100ce1:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0100ce4:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100cea:	e8 30 fe ff ff       	call   f0100b1f <stab_binsearch>

	if (lfun <= rfun) {
f0100cef:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100cf2:	83 c4 10             	add    $0x10,%esp
f0100cf5:	3b 75 d8             	cmp    -0x28(%ebp),%esi
f0100cf8:	7f 79                	jg     f0100d73 <debuginfo_eip+0x15f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100cfa:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100cfd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d00:	c7 c2 58 22 10 f0    	mov    $0xf0102258,%edx
f0100d06:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100d09:	8b 11                	mov    (%ecx),%edx
f0100d0b:	c7 c0 b2 7f 10 f0    	mov    $0xf0107fb2,%eax
f0100d11:	81 e8 21 66 10 f0    	sub    $0xf0106621,%eax
f0100d17:	39 c2                	cmp    %eax,%edx
f0100d19:	73 09                	jae    f0100d24 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d1b:	81 c2 21 66 10 f0    	add    $0xf0106621,%edx
f0100d21:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d24:	8b 41 08             	mov    0x8(%ecx),%eax
f0100d27:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d2a:	83 ec 08             	sub    $0x8,%esp
f0100d2d:	6a 3a                	push   $0x3a
f0100d2f:	ff 77 08             	pushl  0x8(%edi)
f0100d32:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d35:	e8 b8 09 00 00       	call   f01016f2 <strfind>
f0100d3a:	2b 47 08             	sub    0x8(%edi),%eax
f0100d3d:	89 47 0c             	mov    %eax,0xc(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d40:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100d43:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100d46:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100d49:	c7 c2 58 22 10 f0    	mov    $0xf0102258,%edx
f0100d4f:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
f0100d53:	83 c4 10             	add    $0x10,%esp
f0100d56:	eb 29                	jmp    f0100d81 <debuginfo_eip+0x16d>
  	        panic("User address");
f0100d58:	83 ec 04             	sub    $0x4,%esp
f0100d5b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d5e:	8d 83 3f 0d ff ff    	lea    -0xf2c1(%ebx),%eax
f0100d64:	50                   	push   %eax
f0100d65:	6a 7f                	push   $0x7f
f0100d67:	8d 83 4c 0d ff ff    	lea    -0xf2b4(%ebx),%eax
f0100d6d:	50                   	push   %eax
f0100d6e:	e8 9b f3 ff ff       	call   f010010e <_panic>
		info->eip_fn_addr = addr;
f0100d73:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0100d76:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100d79:	eb af                	jmp    f0100d2a <debuginfo_eip+0x116>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100d7b:	83 ee 01             	sub    $0x1,%esi
f0100d7e:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100d81:	39 f3                	cmp    %esi,%ebx
f0100d83:	7f 3a                	jg     f0100dbf <debuginfo_eip+0x1ab>
	       && stabs[lline].n_type != N_SOL
f0100d85:	0f b6 10             	movzbl (%eax),%edx
f0100d88:	80 fa 84             	cmp    $0x84,%dl
f0100d8b:	74 0b                	je     f0100d98 <debuginfo_eip+0x184>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100d8d:	80 fa 64             	cmp    $0x64,%dl
f0100d90:	75 e9                	jne    f0100d7b <debuginfo_eip+0x167>
f0100d92:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100d96:	74 e3                	je     f0100d7b <debuginfo_eip+0x167>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100d98:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100d9b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100d9e:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100da4:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100da7:	c7 c0 b2 7f 10 f0    	mov    $0xf0107fb2,%eax
f0100dad:	81 e8 21 66 10 f0    	sub    $0xf0106621,%eax
f0100db3:	39 c2                	cmp    %eax,%edx
f0100db5:	73 08                	jae    f0100dbf <debuginfo_eip+0x1ab>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100db7:	81 c2 21 66 10 f0    	add    $0xf0106621,%edx
f0100dbd:	89 17                	mov    %edx,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100dbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100dc2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100dc5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0100dca:	39 c8                	cmp    %ecx,%eax
f0100dcc:	7d 4a                	jge    f0100e18 <debuginfo_eip+0x204>
		for (lline = lfun + 1;
f0100dce:	8d 50 01             	lea    0x1(%eax),%edx
f0100dd1:	8d 1c 40             	lea    (%eax,%eax,2),%ebx
f0100dd4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100dd7:	c7 c0 58 22 10 f0    	mov    $0xf0102258,%eax
f0100ddd:	8d 44 98 10          	lea    0x10(%eax,%ebx,4),%eax
f0100de1:	eb 07                	jmp    f0100dea <debuginfo_eip+0x1d6>
			info->eip_fn_narg++;
f0100de3:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100de7:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0100dea:	39 d1                	cmp    %edx,%ecx
f0100dec:	74 25                	je     f0100e13 <debuginfo_eip+0x1ff>
f0100dee:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100df1:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100df5:	74 ec                	je     f0100de3 <debuginfo_eip+0x1cf>
	return 0;
f0100df7:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dfc:	eb 1a                	jmp    f0100e18 <debuginfo_eip+0x204>
		return -1;
f0100dfe:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e03:	eb 13                	jmp    f0100e18 <debuginfo_eip+0x204>
f0100e05:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e0a:	eb 0c                	jmp    f0100e18 <debuginfo_eip+0x204>
		return -1;
f0100e0c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e11:	eb 05                	jmp    f0100e18 <debuginfo_eip+0x204>
	return 0;
f0100e13:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100e18:	89 d0                	mov    %edx,%eax
f0100e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e1d:	5b                   	pop    %ebx
f0100e1e:	5e                   	pop    %esi
f0100e1f:	5f                   	pop    %edi
f0100e20:	5d                   	pop    %ebp
f0100e21:	c3                   	ret    

f0100e22 <__x86.get_pc_thunk.cx>:
f0100e22:	8b 0c 24             	mov    (%esp),%ecx
f0100e25:	c3                   	ret    

f0100e26 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100e26:	55                   	push   %ebp
f0100e27:	89 e5                	mov    %esp,%ebp
f0100e29:	57                   	push   %edi
f0100e2a:	56                   	push   %esi
f0100e2b:	53                   	push   %ebx
f0100e2c:	83 ec 2c             	sub    $0x2c,%esp
f0100e2f:	e8 ee ff ff ff       	call   f0100e22 <__x86.get_pc_thunk.cx>
f0100e34:	81 c1 d4 04 01 00    	add    $0x104d4,%ecx
f0100e3a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100e3d:	89 c7                	mov    %eax,%edi
f0100e3f:	89 d6                	mov    %edx,%esi
f0100e41:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e44:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e47:	89 d1                	mov    %edx,%ecx
f0100e49:	89 c2                	mov    %eax,%edx
f0100e4b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e4e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100e51:	8b 45 10             	mov    0x10(%ebp),%eax
f0100e54:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100e57:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100e5a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100e61:	39 c2                	cmp    %eax,%edx
f0100e63:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100e66:	72 41                	jb     f0100ea9 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100e68:	83 ec 0c             	sub    $0xc,%esp
f0100e6b:	ff 75 18             	pushl  0x18(%ebp)
f0100e6e:	83 eb 01             	sub    $0x1,%ebx
f0100e71:	53                   	push   %ebx
f0100e72:	50                   	push   %eax
f0100e73:	83 ec 08             	sub    $0x8,%esp
f0100e76:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100e79:	ff 75 e0             	pushl  -0x20(%ebp)
f0100e7c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100e7f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100e82:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100e85:	e8 96 0a 00 00       	call   f0101920 <__udivdi3>
f0100e8a:	83 c4 18             	add    $0x18,%esp
f0100e8d:	52                   	push   %edx
f0100e8e:	50                   	push   %eax
f0100e8f:	89 f2                	mov    %esi,%edx
f0100e91:	89 f8                	mov    %edi,%eax
f0100e93:	e8 8e ff ff ff       	call   f0100e26 <printnum>
f0100e98:	83 c4 20             	add    $0x20,%esp
f0100e9b:	eb 13                	jmp    f0100eb0 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100e9d:	83 ec 08             	sub    $0x8,%esp
f0100ea0:	56                   	push   %esi
f0100ea1:	ff 75 18             	pushl  0x18(%ebp)
f0100ea4:	ff d7                	call   *%edi
f0100ea6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100ea9:	83 eb 01             	sub    $0x1,%ebx
f0100eac:	85 db                	test   %ebx,%ebx
f0100eae:	7f ed                	jg     f0100e9d <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100eb0:	83 ec 08             	sub    $0x8,%esp
f0100eb3:	56                   	push   %esi
f0100eb4:	83 ec 04             	sub    $0x4,%esp
f0100eb7:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100eba:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ebd:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100ec0:	ff 75 d0             	pushl  -0x30(%ebp)
f0100ec3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100ec6:	e8 65 0b 00 00       	call   f0101a30 <__umoddi3>
f0100ecb:	83 c4 14             	add    $0x14,%esp
f0100ece:	0f be 84 03 5a 0d ff 	movsbl -0xf2a6(%ebx,%eax,1),%eax
f0100ed5:	ff 
f0100ed6:	50                   	push   %eax
f0100ed7:	ff d7                	call   *%edi
}
f0100ed9:	83 c4 10             	add    $0x10,%esp
f0100edc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100edf:	5b                   	pop    %ebx
f0100ee0:	5e                   	pop    %esi
f0100ee1:	5f                   	pop    %edi
f0100ee2:	5d                   	pop    %ebp
f0100ee3:	c3                   	ret    

f0100ee4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100ee4:	f3 0f 1e fb          	endbr32 
f0100ee8:	55                   	push   %ebp
f0100ee9:	89 e5                	mov    %esp,%ebp
f0100eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100eee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100ef2:	8b 10                	mov    (%eax),%edx
f0100ef4:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ef7:	73 0a                	jae    f0100f03 <sprintputch+0x1f>
		*b->buf++ = ch;
f0100ef9:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100efc:	89 08                	mov    %ecx,(%eax)
f0100efe:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f01:	88 02                	mov    %al,(%edx)
}
f0100f03:	5d                   	pop    %ebp
f0100f04:	c3                   	ret    

f0100f05 <printfmt>:
{
f0100f05:	f3 0f 1e fb          	endbr32 
f0100f09:	55                   	push   %ebp
f0100f0a:	89 e5                	mov    %esp,%ebp
f0100f0c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100f0f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100f12:	50                   	push   %eax
f0100f13:	ff 75 10             	pushl  0x10(%ebp)
f0100f16:	ff 75 0c             	pushl  0xc(%ebp)
f0100f19:	ff 75 08             	pushl  0x8(%ebp)
f0100f1c:	e8 05 00 00 00       	call   f0100f26 <vprintfmt>
}
f0100f21:	83 c4 10             	add    $0x10,%esp
f0100f24:	c9                   	leave  
f0100f25:	c3                   	ret    

f0100f26 <vprintfmt>:
{
f0100f26:	f3 0f 1e fb          	endbr32 
f0100f2a:	55                   	push   %ebp
f0100f2b:	89 e5                	mov    %esp,%ebp
f0100f2d:	57                   	push   %edi
f0100f2e:	56                   	push   %esi
f0100f2f:	53                   	push   %ebx
f0100f30:	83 ec 3c             	sub    $0x3c,%esp
f0100f33:	e8 48 f8 ff ff       	call   f0100780 <__x86.get_pc_thunk.ax>
f0100f38:	05 d0 03 01 00       	add    $0x103d0,%eax
f0100f3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f40:	8b 75 08             	mov    0x8(%ebp),%esi
f0100f43:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100f46:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f49:	8d 80 20 1d 00 00    	lea    0x1d20(%eax),%eax
f0100f4f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100f52:	e9 cd 03 00 00       	jmp    f0101324 <.L25+0x48>
		padc = ' ';
f0100f57:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100f5b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0100f62:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100f69:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0100f70:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f75:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100f78:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100f7b:	8d 43 01             	lea    0x1(%ebx),%eax
f0100f7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100f81:	0f b6 13             	movzbl (%ebx),%edx
f0100f84:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100f87:	3c 55                	cmp    $0x55,%al
f0100f89:	0f 87 21 04 00 00    	ja     f01013b0 <.L20>
f0100f8f:	0f b6 c0             	movzbl %al,%eax
f0100f92:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f95:	89 ce                	mov    %ecx,%esi
f0100f97:	03 b4 81 e8 0d ff ff 	add    -0xf218(%ecx,%eax,4),%esi
f0100f9e:	3e ff e6             	notrack jmp *%esi

f0100fa1 <.L68>:
f0100fa1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0100fa4:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0100fa8:	eb d1                	jmp    f0100f7b <vprintfmt+0x55>

f0100faa <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100faa:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100fad:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0100fb1:	eb c8                	jmp    f0100f7b <vprintfmt+0x55>

f0100fb3 <.L31>:
f0100fb3:	0f b6 d2             	movzbl %dl,%edx
f0100fb6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0100fb9:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fbe:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0100fc1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100fc4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0100fc8:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0100fcb:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100fce:	83 f9 09             	cmp    $0x9,%ecx
f0100fd1:	77 58                	ja     f010102b <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f0100fd3:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f0100fd6:	eb e9                	jmp    f0100fc1 <.L31+0xe>

f0100fd8 <.L34>:
			precision = va_arg(ap, int);
f0100fd8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fdb:	8b 00                	mov    (%eax),%eax
f0100fdd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100fe0:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fe3:	8d 40 04             	lea    0x4(%eax),%eax
f0100fe6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100fe9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0100fec:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100ff0:	79 89                	jns    f0100f7b <vprintfmt+0x55>
				width = precision, precision = -1;
f0100ff2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ff5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100ff8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0100fff:	e9 77 ff ff ff       	jmp    f0100f7b <vprintfmt+0x55>

f0101004 <.L33>:
f0101004:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101007:	85 c0                	test   %eax,%eax
f0101009:	ba 00 00 00 00       	mov    $0x0,%edx
f010100e:	0f 49 d0             	cmovns %eax,%edx
f0101011:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101014:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101017:	e9 5f ff ff ff       	jmp    f0100f7b <vprintfmt+0x55>

f010101c <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f010101c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010101f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0101026:	e9 50 ff ff ff       	jmp    f0100f7b <vprintfmt+0x55>
f010102b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010102e:	89 75 08             	mov    %esi,0x8(%ebp)
f0101031:	eb b9                	jmp    f0100fec <.L34+0x14>

f0101033 <.L27>:
			lflag++;
f0101033:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101037:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010103a:	e9 3c ff ff ff       	jmp    f0100f7b <vprintfmt+0x55>

f010103f <.L30>:
f010103f:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0101042:	8b 45 14             	mov    0x14(%ebp),%eax
f0101045:	8d 58 04             	lea    0x4(%eax),%ebx
f0101048:	83 ec 08             	sub    $0x8,%esp
f010104b:	57                   	push   %edi
f010104c:	ff 30                	pushl  (%eax)
f010104e:	ff d6                	call   *%esi
			break;
f0101050:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101053:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0101056:	e9 c6 02 00 00       	jmp    f0101321 <.L25+0x45>

f010105b <.L28>:
f010105b:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f010105e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101061:	8d 58 04             	lea    0x4(%eax),%ebx
f0101064:	8b 00                	mov    (%eax),%eax
f0101066:	99                   	cltd   
f0101067:	31 d0                	xor    %edx,%eax
f0101069:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010106b:	83 f8 06             	cmp    $0x6,%eax
f010106e:	7f 27                	jg     f0101097 <.L28+0x3c>
f0101070:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101073:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101076:	85 d2                	test   %edx,%edx
f0101078:	74 1d                	je     f0101097 <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f010107a:	52                   	push   %edx
f010107b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010107e:	8d 80 7b 0d ff ff    	lea    -0xf285(%eax),%eax
f0101084:	50                   	push   %eax
f0101085:	57                   	push   %edi
f0101086:	56                   	push   %esi
f0101087:	e8 79 fe ff ff       	call   f0100f05 <printfmt>
f010108c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010108f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101092:	e9 8a 02 00 00       	jmp    f0101321 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0101097:	50                   	push   %eax
f0101098:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010109b:	8d 80 72 0d ff ff    	lea    -0xf28e(%eax),%eax
f01010a1:	50                   	push   %eax
f01010a2:	57                   	push   %edi
f01010a3:	56                   	push   %esi
f01010a4:	e8 5c fe ff ff       	call   f0100f05 <printfmt>
f01010a9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010ac:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01010af:	e9 6d 02 00 00       	jmp    f0101321 <.L25+0x45>

f01010b4 <.L24>:
f01010b4:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f01010b7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ba:	83 c0 04             	add    $0x4,%eax
f01010bd:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01010c0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01010c5:	85 d2                	test   %edx,%edx
f01010c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01010ca:	8d 80 6b 0d ff ff    	lea    -0xf295(%eax),%eax
f01010d0:	0f 45 c2             	cmovne %edx,%eax
f01010d3:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01010d6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01010da:	7e 06                	jle    f01010e2 <.L24+0x2e>
f01010dc:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01010e0:	75 0d                	jne    f01010ef <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01010e2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01010e5:	89 c3                	mov    %eax,%ebx
f01010e7:	03 45 d4             	add    -0x2c(%ebp),%eax
f01010ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010ed:	eb 58                	jmp    f0101147 <.L24+0x93>
f01010ef:	83 ec 08             	sub    $0x8,%esp
f01010f2:	ff 75 d8             	pushl  -0x28(%ebp)
f01010f5:	ff 75 c8             	pushl  -0x38(%ebp)
f01010f8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01010fb:	e8 81 04 00 00       	call   f0101581 <strnlen>
f0101100:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101103:	29 c2                	sub    %eax,%edx
f0101105:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0101108:	83 c4 10             	add    $0x10,%esp
f010110b:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010110d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101111:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101114:	85 db                	test   %ebx,%ebx
f0101116:	7e 11                	jle    f0101129 <.L24+0x75>
					putch(padc, putdat);
f0101118:	83 ec 08             	sub    $0x8,%esp
f010111b:	57                   	push   %edi
f010111c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010111f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101121:	83 eb 01             	sub    $0x1,%ebx
f0101124:	83 c4 10             	add    $0x10,%esp
f0101127:	eb eb                	jmp    f0101114 <.L24+0x60>
f0101129:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010112c:	85 d2                	test   %edx,%edx
f010112e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101133:	0f 49 c2             	cmovns %edx,%eax
f0101136:	29 c2                	sub    %eax,%edx
f0101138:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010113b:	eb a5                	jmp    f01010e2 <.L24+0x2e>
					putch(ch, putdat);
f010113d:	83 ec 08             	sub    $0x8,%esp
f0101140:	57                   	push   %edi
f0101141:	52                   	push   %edx
f0101142:	ff d6                	call   *%esi
f0101144:	83 c4 10             	add    $0x10,%esp
f0101147:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010114a:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010114c:	83 c3 01             	add    $0x1,%ebx
f010114f:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101153:	0f be d0             	movsbl %al,%edx
f0101156:	85 d2                	test   %edx,%edx
f0101158:	74 4b                	je     f01011a5 <.L24+0xf1>
f010115a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010115e:	78 06                	js     f0101166 <.L24+0xb2>
f0101160:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101164:	78 1e                	js     f0101184 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101166:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010116a:	74 d1                	je     f010113d <.L24+0x89>
f010116c:	0f be c0             	movsbl %al,%eax
f010116f:	83 e8 20             	sub    $0x20,%eax
f0101172:	83 f8 5e             	cmp    $0x5e,%eax
f0101175:	76 c6                	jbe    f010113d <.L24+0x89>
					putch('?', putdat);
f0101177:	83 ec 08             	sub    $0x8,%esp
f010117a:	57                   	push   %edi
f010117b:	6a 3f                	push   $0x3f
f010117d:	ff d6                	call   *%esi
f010117f:	83 c4 10             	add    $0x10,%esp
f0101182:	eb c3                	jmp    f0101147 <.L24+0x93>
f0101184:	89 cb                	mov    %ecx,%ebx
f0101186:	eb 0e                	jmp    f0101196 <.L24+0xe2>
				putch(' ', putdat);
f0101188:	83 ec 08             	sub    $0x8,%esp
f010118b:	57                   	push   %edi
f010118c:	6a 20                	push   $0x20
f010118e:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101190:	83 eb 01             	sub    $0x1,%ebx
f0101193:	83 c4 10             	add    $0x10,%esp
f0101196:	85 db                	test   %ebx,%ebx
f0101198:	7f ee                	jg     f0101188 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010119a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010119d:	89 45 14             	mov    %eax,0x14(%ebp)
f01011a0:	e9 7c 01 00 00       	jmp    f0101321 <.L25+0x45>
f01011a5:	89 cb                	mov    %ecx,%ebx
f01011a7:	eb ed                	jmp    f0101196 <.L24+0xe2>

f01011a9 <.L29>:
f01011a9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01011ac:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01011af:	83 f9 01             	cmp    $0x1,%ecx
f01011b2:	7f 1b                	jg     f01011cf <.L29+0x26>
	else if (lflag)
f01011b4:	85 c9                	test   %ecx,%ecx
f01011b6:	74 63                	je     f010121b <.L29+0x72>
		return va_arg(*ap, long);
f01011b8:	8b 45 14             	mov    0x14(%ebp),%eax
f01011bb:	8b 00                	mov    (%eax),%eax
f01011bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011c0:	99                   	cltd   
f01011c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01011c7:	8d 40 04             	lea    0x4(%eax),%eax
f01011ca:	89 45 14             	mov    %eax,0x14(%ebp)
f01011cd:	eb 17                	jmp    f01011e6 <.L29+0x3d>
		return va_arg(*ap, long long);
f01011cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01011d2:	8b 50 04             	mov    0x4(%eax),%edx
f01011d5:	8b 00                	mov    (%eax),%eax
f01011d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011da:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01011dd:	8b 45 14             	mov    0x14(%ebp),%eax
f01011e0:	8d 40 08             	lea    0x8(%eax),%eax
f01011e3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01011e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01011e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01011ec:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01011f1:	85 c9                	test   %ecx,%ecx
f01011f3:	0f 89 0e 01 00 00    	jns    f0101307 <.L25+0x2b>
				putch('-', putdat);
f01011f9:	83 ec 08             	sub    $0x8,%esp
f01011fc:	57                   	push   %edi
f01011fd:	6a 2d                	push   $0x2d
f01011ff:	ff d6                	call   *%esi
				num = -(long long) num;
f0101201:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101204:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101207:	f7 da                	neg    %edx
f0101209:	83 d1 00             	adc    $0x0,%ecx
f010120c:	f7 d9                	neg    %ecx
f010120e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101211:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101216:	e9 ec 00 00 00       	jmp    f0101307 <.L25+0x2b>
		return va_arg(*ap, int);
f010121b:	8b 45 14             	mov    0x14(%ebp),%eax
f010121e:	8b 00                	mov    (%eax),%eax
f0101220:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101223:	99                   	cltd   
f0101224:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101227:	8b 45 14             	mov    0x14(%ebp),%eax
f010122a:	8d 40 04             	lea    0x4(%eax),%eax
f010122d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101230:	eb b4                	jmp    f01011e6 <.L29+0x3d>

f0101232 <.L23>:
f0101232:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101235:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101238:	83 f9 01             	cmp    $0x1,%ecx
f010123b:	7f 1e                	jg     f010125b <.L23+0x29>
	else if (lflag)
f010123d:	85 c9                	test   %ecx,%ecx
f010123f:	74 32                	je     f0101273 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0101241:	8b 45 14             	mov    0x14(%ebp),%eax
f0101244:	8b 10                	mov    (%eax),%edx
f0101246:	b9 00 00 00 00       	mov    $0x0,%ecx
f010124b:	8d 40 04             	lea    0x4(%eax),%eax
f010124e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101251:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0101256:	e9 ac 00 00 00       	jmp    f0101307 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010125b:	8b 45 14             	mov    0x14(%ebp),%eax
f010125e:	8b 10                	mov    (%eax),%edx
f0101260:	8b 48 04             	mov    0x4(%eax),%ecx
f0101263:	8d 40 08             	lea    0x8(%eax),%eax
f0101266:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101269:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f010126e:	e9 94 00 00 00       	jmp    f0101307 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101273:	8b 45 14             	mov    0x14(%ebp),%eax
f0101276:	8b 10                	mov    (%eax),%edx
f0101278:	b9 00 00 00 00       	mov    $0x0,%ecx
f010127d:	8d 40 04             	lea    0x4(%eax),%eax
f0101280:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101283:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0101288:	eb 7d                	jmp    f0101307 <.L25+0x2b>

f010128a <.L26>:
f010128a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010128d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101290:	83 f9 01             	cmp    $0x1,%ecx
f0101293:	7f 1b                	jg     f01012b0 <.L26+0x26>
	else if (lflag)
f0101295:	85 c9                	test   %ecx,%ecx
f0101297:	74 2c                	je     f01012c5 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f0101299:	8b 45 14             	mov    0x14(%ebp),%eax
f010129c:	8b 10                	mov    (%eax),%edx
f010129e:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012a3:	8d 40 04             	lea    0x4(%eax),%eax
f01012a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012a9:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f01012ae:	eb 57                	jmp    f0101307 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01012b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b3:	8b 10                	mov    (%eax),%edx
f01012b5:	8b 48 04             	mov    0x4(%eax),%ecx
f01012b8:	8d 40 08             	lea    0x8(%eax),%eax
f01012bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012be:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f01012c3:	eb 42                	jmp    f0101307 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01012c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c8:	8b 10                	mov    (%eax),%edx
f01012ca:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012cf:	8d 40 04             	lea    0x4(%eax),%eax
f01012d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01012d5:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f01012da:	eb 2b                	jmp    f0101307 <.L25+0x2b>

f01012dc <.L25>:
f01012dc:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f01012df:	83 ec 08             	sub    $0x8,%esp
f01012e2:	57                   	push   %edi
f01012e3:	6a 30                	push   $0x30
f01012e5:	ff d6                	call   *%esi
			putch('x', putdat);
f01012e7:	83 c4 08             	add    $0x8,%esp
f01012ea:	57                   	push   %edi
f01012eb:	6a 78                	push   $0x78
f01012ed:	ff d6                	call   *%esi
			num = (unsigned long long)
f01012ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f2:	8b 10                	mov    (%eax),%edx
f01012f4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01012f9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01012fc:	8d 40 04             	lea    0x4(%eax),%eax
f01012ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101302:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0101307:	83 ec 0c             	sub    $0xc,%esp
f010130a:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f010130e:	53                   	push   %ebx
f010130f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101312:	50                   	push   %eax
f0101313:	51                   	push   %ecx
f0101314:	52                   	push   %edx
f0101315:	89 fa                	mov    %edi,%edx
f0101317:	89 f0                	mov    %esi,%eax
f0101319:	e8 08 fb ff ff       	call   f0100e26 <printnum>
			break;
f010131e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0101321:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101324:	83 c3 01             	add    $0x1,%ebx
f0101327:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010132b:	83 f8 25             	cmp    $0x25,%eax
f010132e:	0f 84 23 fc ff ff    	je     f0100f57 <vprintfmt+0x31>
			if (ch == '\0')
f0101334:	85 c0                	test   %eax,%eax
f0101336:	0f 84 97 00 00 00    	je     f01013d3 <.L20+0x23>
			putch(ch, putdat);
f010133c:	83 ec 08             	sub    $0x8,%esp
f010133f:	57                   	push   %edi
f0101340:	50                   	push   %eax
f0101341:	ff d6                	call   *%esi
f0101343:	83 c4 10             	add    $0x10,%esp
f0101346:	eb dc                	jmp    f0101324 <.L25+0x48>

f0101348 <.L21>:
f0101348:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010134b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010134e:	83 f9 01             	cmp    $0x1,%ecx
f0101351:	7f 1b                	jg     f010136e <.L21+0x26>
	else if (lflag)
f0101353:	85 c9                	test   %ecx,%ecx
f0101355:	74 2c                	je     f0101383 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0101357:	8b 45 14             	mov    0x14(%ebp),%eax
f010135a:	8b 10                	mov    (%eax),%edx
f010135c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101361:	8d 40 04             	lea    0x4(%eax),%eax
f0101364:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101367:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f010136c:	eb 99                	jmp    f0101307 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010136e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101371:	8b 10                	mov    (%eax),%edx
f0101373:	8b 48 04             	mov    0x4(%eax),%ecx
f0101376:	8d 40 08             	lea    0x8(%eax),%eax
f0101379:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010137c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0101381:	eb 84                	jmp    f0101307 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101383:	8b 45 14             	mov    0x14(%ebp),%eax
f0101386:	8b 10                	mov    (%eax),%edx
f0101388:	b9 00 00 00 00       	mov    $0x0,%ecx
f010138d:	8d 40 04             	lea    0x4(%eax),%eax
f0101390:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101393:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0101398:	e9 6a ff ff ff       	jmp    f0101307 <.L25+0x2b>

f010139d <.L35>:
f010139d:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f01013a0:	83 ec 08             	sub    $0x8,%esp
f01013a3:	57                   	push   %edi
f01013a4:	6a 25                	push   $0x25
f01013a6:	ff d6                	call   *%esi
			break;
f01013a8:	83 c4 10             	add    $0x10,%esp
f01013ab:	e9 71 ff ff ff       	jmp    f0101321 <.L25+0x45>

f01013b0 <.L20>:
f01013b0:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f01013b3:	83 ec 08             	sub    $0x8,%esp
f01013b6:	57                   	push   %edi
f01013b7:	6a 25                	push   $0x25
f01013b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01013bb:	83 c4 10             	add    $0x10,%esp
f01013be:	89 d8                	mov    %ebx,%eax
f01013c0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01013c4:	74 05                	je     f01013cb <.L20+0x1b>
f01013c6:	83 e8 01             	sub    $0x1,%eax
f01013c9:	eb f5                	jmp    f01013c0 <.L20+0x10>
f01013cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01013ce:	e9 4e ff ff ff       	jmp    f0101321 <.L25+0x45>
}
f01013d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013d6:	5b                   	pop    %ebx
f01013d7:	5e                   	pop    %esi
f01013d8:	5f                   	pop    %edi
f01013d9:	5d                   	pop    %ebp
f01013da:	c3                   	ret    

f01013db <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01013db:	f3 0f 1e fb          	endbr32 
f01013df:	55                   	push   %ebp
f01013e0:	89 e5                	mov    %esp,%ebp
f01013e2:	53                   	push   %ebx
f01013e3:	83 ec 14             	sub    $0x14,%esp
f01013e6:	e8 e1 ed ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f01013eb:	81 c3 1d ff 00 00    	add    $0xff1d,%ebx
f01013f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01013f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01013f7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01013fa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01013fe:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101408:	85 c0                	test   %eax,%eax
f010140a:	74 2b                	je     f0101437 <vsnprintf+0x5c>
f010140c:	85 d2                	test   %edx,%edx
f010140e:	7e 27                	jle    f0101437 <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101410:	ff 75 14             	pushl  0x14(%ebp)
f0101413:	ff 75 10             	pushl  0x10(%ebp)
f0101416:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101419:	50                   	push   %eax
f010141a:	8d 83 dc fb fe ff    	lea    -0x10424(%ebx),%eax
f0101420:	50                   	push   %eax
f0101421:	e8 00 fb ff ff       	call   f0100f26 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101426:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101429:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010142c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010142f:	83 c4 10             	add    $0x10,%esp
}
f0101432:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101435:	c9                   	leave  
f0101436:	c3                   	ret    
		return -E_INVAL;
f0101437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010143c:	eb f4                	jmp    f0101432 <vsnprintf+0x57>

f010143e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010143e:	f3 0f 1e fb          	endbr32 
f0101442:	55                   	push   %ebp
f0101443:	89 e5                	mov    %esp,%ebp
f0101445:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101448:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010144b:	50                   	push   %eax
f010144c:	ff 75 10             	pushl  0x10(%ebp)
f010144f:	ff 75 0c             	pushl  0xc(%ebp)
f0101452:	ff 75 08             	pushl  0x8(%ebp)
f0101455:	e8 81 ff ff ff       	call   f01013db <vsnprintf>
	va_end(ap);

	return rc;
}
f010145a:	c9                   	leave  
f010145b:	c3                   	ret    

f010145c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010145c:	f3 0f 1e fb          	endbr32 
f0101460:	55                   	push   %ebp
f0101461:	89 e5                	mov    %esp,%ebp
f0101463:	57                   	push   %edi
f0101464:	56                   	push   %esi
f0101465:	53                   	push   %ebx
f0101466:	83 ec 1c             	sub    $0x1c,%esp
f0101469:	e8 5e ed ff ff       	call   f01001cc <__x86.get_pc_thunk.bx>
f010146e:	81 c3 9a fe 00 00    	add    $0xfe9a,%ebx
f0101474:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101477:	85 c0                	test   %eax,%eax
f0101479:	74 13                	je     f010148e <readline+0x32>
		cprintf("%s", prompt);
f010147b:	83 ec 08             	sub    $0x8,%esp
f010147e:	50                   	push   %eax
f010147f:	8d 83 7b 0d ff ff    	lea    -0xf285(%ebx),%eax
f0101485:	50                   	push   %eax
f0101486:	e8 7c f6 ff ff       	call   f0100b07 <cprintf>
f010148b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010148e:	83 ec 0c             	sub    $0xc,%esp
f0101491:	6a 00                	push   $0x0
f0101493:	e8 de f2 ff ff       	call   f0100776 <iscons>
f0101498:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010149b:	83 c4 10             	add    $0x10,%esp
	i = 0;
f010149e:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f01014a3:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01014a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01014ac:	eb 51                	jmp    f01014ff <readline+0xa3>
			cprintf("read error: %e\n", c);
f01014ae:	83 ec 08             	sub    $0x8,%esp
f01014b1:	50                   	push   %eax
f01014b2:	8d 83 40 0f ff ff    	lea    -0xf0c0(%ebx),%eax
f01014b8:	50                   	push   %eax
f01014b9:	e8 49 f6 ff ff       	call   f0100b07 <cprintf>
			return NULL;
f01014be:	83 c4 10             	add    $0x10,%esp
f01014c1:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01014c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014c9:	5b                   	pop    %ebx
f01014ca:	5e                   	pop    %esi
f01014cb:	5f                   	pop    %edi
f01014cc:	5d                   	pop    %ebp
f01014cd:	c3                   	ret    
			if (echoing)
f01014ce:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01014d2:	75 05                	jne    f01014d9 <readline+0x7d>
			i--;
f01014d4:	83 ef 01             	sub    $0x1,%edi
f01014d7:	eb 26                	jmp    f01014ff <readline+0xa3>
				cputchar('\b');
f01014d9:	83 ec 0c             	sub    $0xc,%esp
f01014dc:	6a 08                	push   $0x8
f01014de:	e8 6a f2 ff ff       	call   f010074d <cputchar>
f01014e3:	83 c4 10             	add    $0x10,%esp
f01014e6:	eb ec                	jmp    f01014d4 <readline+0x78>
				cputchar(c);
f01014e8:	83 ec 0c             	sub    $0xc,%esp
f01014eb:	56                   	push   %esi
f01014ec:	e8 5c f2 ff ff       	call   f010074d <cputchar>
f01014f1:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01014f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01014f7:	89 f0                	mov    %esi,%eax
f01014f9:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01014fc:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01014ff:	e8 5d f2 ff ff       	call   f0100761 <getchar>
f0101504:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101506:	85 c0                	test   %eax,%eax
f0101508:	78 a4                	js     f01014ae <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010150a:	83 f8 08             	cmp    $0x8,%eax
f010150d:	0f 94 c2             	sete   %dl
f0101510:	83 f8 7f             	cmp    $0x7f,%eax
f0101513:	0f 94 c0             	sete   %al
f0101516:	08 c2                	or     %al,%dl
f0101518:	74 04                	je     f010151e <readline+0xc2>
f010151a:	85 ff                	test   %edi,%edi
f010151c:	7f b0                	jg     f01014ce <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010151e:	83 fe 1f             	cmp    $0x1f,%esi
f0101521:	7e 10                	jle    f0101533 <readline+0xd7>
f0101523:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101529:	7f 08                	jg     f0101533 <readline+0xd7>
			if (echoing)
f010152b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010152f:	74 c3                	je     f01014f4 <readline+0x98>
f0101531:	eb b5                	jmp    f01014e8 <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f0101533:	83 fe 0a             	cmp    $0xa,%esi
f0101536:	74 05                	je     f010153d <readline+0xe1>
f0101538:	83 fe 0d             	cmp    $0xd,%esi
f010153b:	75 c2                	jne    f01014ff <readline+0xa3>
			if (echoing)
f010153d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101541:	75 13                	jne    f0101556 <readline+0xfa>
			buf[i] = 0;
f0101543:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f010154a:	00 
			return buf;
f010154b:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101551:	e9 70 ff ff ff       	jmp    f01014c6 <readline+0x6a>
				cputchar('\n');
f0101556:	83 ec 0c             	sub    $0xc,%esp
f0101559:	6a 0a                	push   $0xa
f010155b:	e8 ed f1 ff ff       	call   f010074d <cputchar>
f0101560:	83 c4 10             	add    $0x10,%esp
f0101563:	eb de                	jmp    f0101543 <readline+0xe7>

f0101565 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101565:	f3 0f 1e fb          	endbr32 
f0101569:	55                   	push   %ebp
f010156a:	89 e5                	mov    %esp,%ebp
f010156c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010156f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101574:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101578:	74 05                	je     f010157f <strlen+0x1a>
		n++;
f010157a:	83 c0 01             	add    $0x1,%eax
f010157d:	eb f5                	jmp    f0101574 <strlen+0xf>
	return n;
}
f010157f:	5d                   	pop    %ebp
f0101580:	c3                   	ret    

f0101581 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101581:	f3 0f 1e fb          	endbr32 
f0101585:	55                   	push   %ebp
f0101586:	89 e5                	mov    %esp,%ebp
f0101588:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010158b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010158e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101593:	39 d0                	cmp    %edx,%eax
f0101595:	74 0d                	je     f01015a4 <strnlen+0x23>
f0101597:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010159b:	74 05                	je     f01015a2 <strnlen+0x21>
		n++;
f010159d:	83 c0 01             	add    $0x1,%eax
f01015a0:	eb f1                	jmp    f0101593 <strnlen+0x12>
f01015a2:	89 c2                	mov    %eax,%edx
	return n;
}
f01015a4:	89 d0                	mov    %edx,%eax
f01015a6:	5d                   	pop    %ebp
f01015a7:	c3                   	ret    

f01015a8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015a8:	f3 0f 1e fb          	endbr32 
f01015ac:	55                   	push   %ebp
f01015ad:	89 e5                	mov    %esp,%ebp
f01015af:	53                   	push   %ebx
f01015b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01015b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01015bb:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01015bf:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01015c2:	83 c0 01             	add    $0x1,%eax
f01015c5:	84 d2                	test   %dl,%dl
f01015c7:	75 f2                	jne    f01015bb <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f01015c9:	89 c8                	mov    %ecx,%eax
f01015cb:	5b                   	pop    %ebx
f01015cc:	5d                   	pop    %ebp
f01015cd:	c3                   	ret    

f01015ce <strcat>:

char *
strcat(char *dst, const char *src)
{
f01015ce:	f3 0f 1e fb          	endbr32 
f01015d2:	55                   	push   %ebp
f01015d3:	89 e5                	mov    %esp,%ebp
f01015d5:	53                   	push   %ebx
f01015d6:	83 ec 10             	sub    $0x10,%esp
f01015d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01015dc:	53                   	push   %ebx
f01015dd:	e8 83 ff ff ff       	call   f0101565 <strlen>
f01015e2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01015e5:	ff 75 0c             	pushl  0xc(%ebp)
f01015e8:	01 d8                	add    %ebx,%eax
f01015ea:	50                   	push   %eax
f01015eb:	e8 b8 ff ff ff       	call   f01015a8 <strcpy>
	return dst;
}
f01015f0:	89 d8                	mov    %ebx,%eax
f01015f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01015f5:	c9                   	leave  
f01015f6:	c3                   	ret    

f01015f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01015f7:	f3 0f 1e fb          	endbr32 
f01015fb:	55                   	push   %ebp
f01015fc:	89 e5                	mov    %esp,%ebp
f01015fe:	56                   	push   %esi
f01015ff:	53                   	push   %ebx
f0101600:	8b 75 08             	mov    0x8(%ebp),%esi
f0101603:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101606:	89 f3                	mov    %esi,%ebx
f0101608:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010160b:	89 f0                	mov    %esi,%eax
f010160d:	39 d8                	cmp    %ebx,%eax
f010160f:	74 11                	je     f0101622 <strncpy+0x2b>
		*dst++ = *src;
f0101611:	83 c0 01             	add    $0x1,%eax
f0101614:	0f b6 0a             	movzbl (%edx),%ecx
f0101617:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010161a:	80 f9 01             	cmp    $0x1,%cl
f010161d:	83 da ff             	sbb    $0xffffffff,%edx
f0101620:	eb eb                	jmp    f010160d <strncpy+0x16>
	}
	return ret;
}
f0101622:	89 f0                	mov    %esi,%eax
f0101624:	5b                   	pop    %ebx
f0101625:	5e                   	pop    %esi
f0101626:	5d                   	pop    %ebp
f0101627:	c3                   	ret    

f0101628 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101628:	f3 0f 1e fb          	endbr32 
f010162c:	55                   	push   %ebp
f010162d:	89 e5                	mov    %esp,%ebp
f010162f:	56                   	push   %esi
f0101630:	53                   	push   %ebx
f0101631:	8b 75 08             	mov    0x8(%ebp),%esi
f0101634:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101637:	8b 55 10             	mov    0x10(%ebp),%edx
f010163a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010163c:	85 d2                	test   %edx,%edx
f010163e:	74 21                	je     f0101661 <strlcpy+0x39>
f0101640:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101644:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0101646:	39 c2                	cmp    %eax,%edx
f0101648:	74 14                	je     f010165e <strlcpy+0x36>
f010164a:	0f b6 19             	movzbl (%ecx),%ebx
f010164d:	84 db                	test   %bl,%bl
f010164f:	74 0b                	je     f010165c <strlcpy+0x34>
			*dst++ = *src++;
f0101651:	83 c1 01             	add    $0x1,%ecx
f0101654:	83 c2 01             	add    $0x1,%edx
f0101657:	88 5a ff             	mov    %bl,-0x1(%edx)
f010165a:	eb ea                	jmp    f0101646 <strlcpy+0x1e>
f010165c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f010165e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101661:	29 f0                	sub    %esi,%eax
}
f0101663:	5b                   	pop    %ebx
f0101664:	5e                   	pop    %esi
f0101665:	5d                   	pop    %ebp
f0101666:	c3                   	ret    

f0101667 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101667:	f3 0f 1e fb          	endbr32 
f010166b:	55                   	push   %ebp
f010166c:	89 e5                	mov    %esp,%ebp
f010166e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101671:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101674:	0f b6 01             	movzbl (%ecx),%eax
f0101677:	84 c0                	test   %al,%al
f0101679:	74 0c                	je     f0101687 <strcmp+0x20>
f010167b:	3a 02                	cmp    (%edx),%al
f010167d:	75 08                	jne    f0101687 <strcmp+0x20>
		p++, q++;
f010167f:	83 c1 01             	add    $0x1,%ecx
f0101682:	83 c2 01             	add    $0x1,%edx
f0101685:	eb ed                	jmp    f0101674 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101687:	0f b6 c0             	movzbl %al,%eax
f010168a:	0f b6 12             	movzbl (%edx),%edx
f010168d:	29 d0                	sub    %edx,%eax
}
f010168f:	5d                   	pop    %ebp
f0101690:	c3                   	ret    

f0101691 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101691:	f3 0f 1e fb          	endbr32 
f0101695:	55                   	push   %ebp
f0101696:	89 e5                	mov    %esp,%ebp
f0101698:	53                   	push   %ebx
f0101699:	8b 45 08             	mov    0x8(%ebp),%eax
f010169c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010169f:	89 c3                	mov    %eax,%ebx
f01016a1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016a4:	eb 06                	jmp    f01016ac <strncmp+0x1b>
		n--, p++, q++;
f01016a6:	83 c0 01             	add    $0x1,%eax
f01016a9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016ac:	39 d8                	cmp    %ebx,%eax
f01016ae:	74 16                	je     f01016c6 <strncmp+0x35>
f01016b0:	0f b6 08             	movzbl (%eax),%ecx
f01016b3:	84 c9                	test   %cl,%cl
f01016b5:	74 04                	je     f01016bb <strncmp+0x2a>
f01016b7:	3a 0a                	cmp    (%edx),%cl
f01016b9:	74 eb                	je     f01016a6 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016bb:	0f b6 00             	movzbl (%eax),%eax
f01016be:	0f b6 12             	movzbl (%edx),%edx
f01016c1:	29 d0                	sub    %edx,%eax
}
f01016c3:	5b                   	pop    %ebx
f01016c4:	5d                   	pop    %ebp
f01016c5:	c3                   	ret    
		return 0;
f01016c6:	b8 00 00 00 00       	mov    $0x0,%eax
f01016cb:	eb f6                	jmp    f01016c3 <strncmp+0x32>

f01016cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016cd:	f3 0f 1e fb          	endbr32 
f01016d1:	55                   	push   %ebp
f01016d2:	89 e5                	mov    %esp,%ebp
f01016d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01016d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01016db:	0f b6 10             	movzbl (%eax),%edx
f01016de:	84 d2                	test   %dl,%dl
f01016e0:	74 09                	je     f01016eb <strchr+0x1e>
		if (*s == c)
f01016e2:	38 ca                	cmp    %cl,%dl
f01016e4:	74 0a                	je     f01016f0 <strchr+0x23>
	for (; *s; s++)
f01016e6:	83 c0 01             	add    $0x1,%eax
f01016e9:	eb f0                	jmp    f01016db <strchr+0xe>
			return (char *) s;
	return 0;
f01016eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01016f0:	5d                   	pop    %ebp
f01016f1:	c3                   	ret    

f01016f2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01016f2:	f3 0f 1e fb          	endbr32 
f01016f6:	55                   	push   %ebp
f01016f7:	89 e5                	mov    %esp,%ebp
f01016f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01016fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101700:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101703:	38 ca                	cmp    %cl,%dl
f0101705:	74 09                	je     f0101710 <strfind+0x1e>
f0101707:	84 d2                	test   %dl,%dl
f0101709:	74 05                	je     f0101710 <strfind+0x1e>
	for (; *s; s++)
f010170b:	83 c0 01             	add    $0x1,%eax
f010170e:	eb f0                	jmp    f0101700 <strfind+0xe>
			break;
	return (char *) s;
}
f0101710:	5d                   	pop    %ebp
f0101711:	c3                   	ret    

f0101712 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101712:	f3 0f 1e fb          	endbr32 
f0101716:	55                   	push   %ebp
f0101717:	89 e5                	mov    %esp,%ebp
f0101719:	57                   	push   %edi
f010171a:	56                   	push   %esi
f010171b:	53                   	push   %ebx
f010171c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010171f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101722:	85 c9                	test   %ecx,%ecx
f0101724:	74 31                	je     f0101757 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101726:	89 f8                	mov    %edi,%eax
f0101728:	09 c8                	or     %ecx,%eax
f010172a:	a8 03                	test   $0x3,%al
f010172c:	75 23                	jne    f0101751 <memset+0x3f>
		c &= 0xFF;
f010172e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101732:	89 d3                	mov    %edx,%ebx
f0101734:	c1 e3 08             	shl    $0x8,%ebx
f0101737:	89 d0                	mov    %edx,%eax
f0101739:	c1 e0 18             	shl    $0x18,%eax
f010173c:	89 d6                	mov    %edx,%esi
f010173e:	c1 e6 10             	shl    $0x10,%esi
f0101741:	09 f0                	or     %esi,%eax
f0101743:	09 c2                	or     %eax,%edx
f0101745:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101747:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010174a:	89 d0                	mov    %edx,%eax
f010174c:	fc                   	cld    
f010174d:	f3 ab                	rep stos %eax,%es:(%edi)
f010174f:	eb 06                	jmp    f0101757 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101751:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101754:	fc                   	cld    
f0101755:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101757:	89 f8                	mov    %edi,%eax
f0101759:	5b                   	pop    %ebx
f010175a:	5e                   	pop    %esi
f010175b:	5f                   	pop    %edi
f010175c:	5d                   	pop    %ebp
f010175d:	c3                   	ret    

f010175e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010175e:	f3 0f 1e fb          	endbr32 
f0101762:	55                   	push   %ebp
f0101763:	89 e5                	mov    %esp,%ebp
f0101765:	57                   	push   %edi
f0101766:	56                   	push   %esi
f0101767:	8b 45 08             	mov    0x8(%ebp),%eax
f010176a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010176d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101770:	39 c6                	cmp    %eax,%esi
f0101772:	73 32                	jae    f01017a6 <memmove+0x48>
f0101774:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101777:	39 c2                	cmp    %eax,%edx
f0101779:	76 2b                	jbe    f01017a6 <memmove+0x48>
		s += n;
		d += n;
f010177b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010177e:	89 fe                	mov    %edi,%esi
f0101780:	09 ce                	or     %ecx,%esi
f0101782:	09 d6                	or     %edx,%esi
f0101784:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010178a:	75 0e                	jne    f010179a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010178c:	83 ef 04             	sub    $0x4,%edi
f010178f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101792:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101795:	fd                   	std    
f0101796:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101798:	eb 09                	jmp    f01017a3 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010179a:	83 ef 01             	sub    $0x1,%edi
f010179d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01017a0:	fd                   	std    
f01017a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017a3:	fc                   	cld    
f01017a4:	eb 1a                	jmp    f01017c0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017a6:	89 c2                	mov    %eax,%edx
f01017a8:	09 ca                	or     %ecx,%edx
f01017aa:	09 f2                	or     %esi,%edx
f01017ac:	f6 c2 03             	test   $0x3,%dl
f01017af:	75 0a                	jne    f01017bb <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017b1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01017b4:	89 c7                	mov    %eax,%edi
f01017b6:	fc                   	cld    
f01017b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017b9:	eb 05                	jmp    f01017c0 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f01017bb:	89 c7                	mov    %eax,%edi
f01017bd:	fc                   	cld    
f01017be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017c0:	5e                   	pop    %esi
f01017c1:	5f                   	pop    %edi
f01017c2:	5d                   	pop    %ebp
f01017c3:	c3                   	ret    

f01017c4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01017c4:	f3 0f 1e fb          	endbr32 
f01017c8:	55                   	push   %ebp
f01017c9:	89 e5                	mov    %esp,%ebp
f01017cb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01017ce:	ff 75 10             	pushl  0x10(%ebp)
f01017d1:	ff 75 0c             	pushl  0xc(%ebp)
f01017d4:	ff 75 08             	pushl  0x8(%ebp)
f01017d7:	e8 82 ff ff ff       	call   f010175e <memmove>
}
f01017dc:	c9                   	leave  
f01017dd:	c3                   	ret    

f01017de <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01017de:	f3 0f 1e fb          	endbr32 
f01017e2:	55                   	push   %ebp
f01017e3:	89 e5                	mov    %esp,%ebp
f01017e5:	56                   	push   %esi
f01017e6:	53                   	push   %ebx
f01017e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01017ea:	8b 55 0c             	mov    0xc(%ebp),%edx
f01017ed:	89 c6                	mov    %eax,%esi
f01017ef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01017f2:	39 f0                	cmp    %esi,%eax
f01017f4:	74 1c                	je     f0101812 <memcmp+0x34>
		if (*s1 != *s2)
f01017f6:	0f b6 08             	movzbl (%eax),%ecx
f01017f9:	0f b6 1a             	movzbl (%edx),%ebx
f01017fc:	38 d9                	cmp    %bl,%cl
f01017fe:	75 08                	jne    f0101808 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101800:	83 c0 01             	add    $0x1,%eax
f0101803:	83 c2 01             	add    $0x1,%edx
f0101806:	eb ea                	jmp    f01017f2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0101808:	0f b6 c1             	movzbl %cl,%eax
f010180b:	0f b6 db             	movzbl %bl,%ebx
f010180e:	29 d8                	sub    %ebx,%eax
f0101810:	eb 05                	jmp    f0101817 <memcmp+0x39>
	}

	return 0;
f0101812:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101817:	5b                   	pop    %ebx
f0101818:	5e                   	pop    %esi
f0101819:	5d                   	pop    %ebp
f010181a:	c3                   	ret    

f010181b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010181b:	f3 0f 1e fb          	endbr32 
f010181f:	55                   	push   %ebp
f0101820:	89 e5                	mov    %esp,%ebp
f0101822:	8b 45 08             	mov    0x8(%ebp),%eax
f0101825:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101828:	89 c2                	mov    %eax,%edx
f010182a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010182d:	39 d0                	cmp    %edx,%eax
f010182f:	73 09                	jae    f010183a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101831:	38 08                	cmp    %cl,(%eax)
f0101833:	74 05                	je     f010183a <memfind+0x1f>
	for (; s < ends; s++)
f0101835:	83 c0 01             	add    $0x1,%eax
f0101838:	eb f3                	jmp    f010182d <memfind+0x12>
			break;
	return (void *) s;
}
f010183a:	5d                   	pop    %ebp
f010183b:	c3                   	ret    

f010183c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010183c:	f3 0f 1e fb          	endbr32 
f0101840:	55                   	push   %ebp
f0101841:	89 e5                	mov    %esp,%ebp
f0101843:	57                   	push   %edi
f0101844:	56                   	push   %esi
f0101845:	53                   	push   %ebx
f0101846:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101849:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010184c:	eb 03                	jmp    f0101851 <strtol+0x15>
		s++;
f010184e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101851:	0f b6 01             	movzbl (%ecx),%eax
f0101854:	3c 20                	cmp    $0x20,%al
f0101856:	74 f6                	je     f010184e <strtol+0x12>
f0101858:	3c 09                	cmp    $0x9,%al
f010185a:	74 f2                	je     f010184e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f010185c:	3c 2b                	cmp    $0x2b,%al
f010185e:	74 2a                	je     f010188a <strtol+0x4e>
	int neg = 0;
f0101860:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101865:	3c 2d                	cmp    $0x2d,%al
f0101867:	74 2b                	je     f0101894 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101869:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010186f:	75 0f                	jne    f0101880 <strtol+0x44>
f0101871:	80 39 30             	cmpb   $0x30,(%ecx)
f0101874:	74 28                	je     f010189e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101876:	85 db                	test   %ebx,%ebx
f0101878:	b8 0a 00 00 00       	mov    $0xa,%eax
f010187d:	0f 44 d8             	cmove  %eax,%ebx
f0101880:	b8 00 00 00 00       	mov    $0x0,%eax
f0101885:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101888:	eb 46                	jmp    f01018d0 <strtol+0x94>
		s++;
f010188a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010188d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101892:	eb d5                	jmp    f0101869 <strtol+0x2d>
		s++, neg = 1;
f0101894:	83 c1 01             	add    $0x1,%ecx
f0101897:	bf 01 00 00 00       	mov    $0x1,%edi
f010189c:	eb cb                	jmp    f0101869 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010189e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01018a2:	74 0e                	je     f01018b2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01018a4:	85 db                	test   %ebx,%ebx
f01018a6:	75 d8                	jne    f0101880 <strtol+0x44>
		s++, base = 8;
f01018a8:	83 c1 01             	add    $0x1,%ecx
f01018ab:	bb 08 00 00 00       	mov    $0x8,%ebx
f01018b0:	eb ce                	jmp    f0101880 <strtol+0x44>
		s += 2, base = 16;
f01018b2:	83 c1 02             	add    $0x2,%ecx
f01018b5:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018ba:	eb c4                	jmp    f0101880 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01018bc:	0f be d2             	movsbl %dl,%edx
f01018bf:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018c2:	3b 55 10             	cmp    0x10(%ebp),%edx
f01018c5:	7d 3a                	jge    f0101901 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01018c7:	83 c1 01             	add    $0x1,%ecx
f01018ca:	0f af 45 10          	imul   0x10(%ebp),%eax
f01018ce:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01018d0:	0f b6 11             	movzbl (%ecx),%edx
f01018d3:	8d 72 d0             	lea    -0x30(%edx),%esi
f01018d6:	89 f3                	mov    %esi,%ebx
f01018d8:	80 fb 09             	cmp    $0x9,%bl
f01018db:	76 df                	jbe    f01018bc <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f01018dd:	8d 72 9f             	lea    -0x61(%edx),%esi
f01018e0:	89 f3                	mov    %esi,%ebx
f01018e2:	80 fb 19             	cmp    $0x19,%bl
f01018e5:	77 08                	ja     f01018ef <strtol+0xb3>
			dig = *s - 'a' + 10;
f01018e7:	0f be d2             	movsbl %dl,%edx
f01018ea:	83 ea 57             	sub    $0x57,%edx
f01018ed:	eb d3                	jmp    f01018c2 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f01018ef:	8d 72 bf             	lea    -0x41(%edx),%esi
f01018f2:	89 f3                	mov    %esi,%ebx
f01018f4:	80 fb 19             	cmp    $0x19,%bl
f01018f7:	77 08                	ja     f0101901 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01018f9:	0f be d2             	movsbl %dl,%edx
f01018fc:	83 ea 37             	sub    $0x37,%edx
f01018ff:	eb c1                	jmp    f01018c2 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101901:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101905:	74 05                	je     f010190c <strtol+0xd0>
		*endptr = (char *) s;
f0101907:	8b 75 0c             	mov    0xc(%ebp),%esi
f010190a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010190c:	89 c2                	mov    %eax,%edx
f010190e:	f7 da                	neg    %edx
f0101910:	85 ff                	test   %edi,%edi
f0101912:	0f 45 c2             	cmovne %edx,%eax
}
f0101915:	5b                   	pop    %ebx
f0101916:	5e                   	pop    %esi
f0101917:	5f                   	pop    %edi
f0101918:	5d                   	pop    %ebp
f0101919:	c3                   	ret    
f010191a:	66 90                	xchg   %ax,%ax
f010191c:	66 90                	xchg   %ax,%ax
f010191e:	66 90                	xchg   %ax,%ax

f0101920 <__udivdi3>:
f0101920:	f3 0f 1e fb          	endbr32 
f0101924:	55                   	push   %ebp
f0101925:	57                   	push   %edi
f0101926:	56                   	push   %esi
f0101927:	53                   	push   %ebx
f0101928:	83 ec 1c             	sub    $0x1c,%esp
f010192b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010192f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101933:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101937:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010193b:	85 d2                	test   %edx,%edx
f010193d:	75 19                	jne    f0101958 <__udivdi3+0x38>
f010193f:	39 f3                	cmp    %esi,%ebx
f0101941:	76 4d                	jbe    f0101990 <__udivdi3+0x70>
f0101943:	31 ff                	xor    %edi,%edi
f0101945:	89 e8                	mov    %ebp,%eax
f0101947:	89 f2                	mov    %esi,%edx
f0101949:	f7 f3                	div    %ebx
f010194b:	89 fa                	mov    %edi,%edx
f010194d:	83 c4 1c             	add    $0x1c,%esp
f0101950:	5b                   	pop    %ebx
f0101951:	5e                   	pop    %esi
f0101952:	5f                   	pop    %edi
f0101953:	5d                   	pop    %ebp
f0101954:	c3                   	ret    
f0101955:	8d 76 00             	lea    0x0(%esi),%esi
f0101958:	39 f2                	cmp    %esi,%edx
f010195a:	76 14                	jbe    f0101970 <__udivdi3+0x50>
f010195c:	31 ff                	xor    %edi,%edi
f010195e:	31 c0                	xor    %eax,%eax
f0101960:	89 fa                	mov    %edi,%edx
f0101962:	83 c4 1c             	add    $0x1c,%esp
f0101965:	5b                   	pop    %ebx
f0101966:	5e                   	pop    %esi
f0101967:	5f                   	pop    %edi
f0101968:	5d                   	pop    %ebp
f0101969:	c3                   	ret    
f010196a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101970:	0f bd fa             	bsr    %edx,%edi
f0101973:	83 f7 1f             	xor    $0x1f,%edi
f0101976:	75 48                	jne    f01019c0 <__udivdi3+0xa0>
f0101978:	39 f2                	cmp    %esi,%edx
f010197a:	72 06                	jb     f0101982 <__udivdi3+0x62>
f010197c:	31 c0                	xor    %eax,%eax
f010197e:	39 eb                	cmp    %ebp,%ebx
f0101980:	77 de                	ja     f0101960 <__udivdi3+0x40>
f0101982:	b8 01 00 00 00       	mov    $0x1,%eax
f0101987:	eb d7                	jmp    f0101960 <__udivdi3+0x40>
f0101989:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101990:	89 d9                	mov    %ebx,%ecx
f0101992:	85 db                	test   %ebx,%ebx
f0101994:	75 0b                	jne    f01019a1 <__udivdi3+0x81>
f0101996:	b8 01 00 00 00       	mov    $0x1,%eax
f010199b:	31 d2                	xor    %edx,%edx
f010199d:	f7 f3                	div    %ebx
f010199f:	89 c1                	mov    %eax,%ecx
f01019a1:	31 d2                	xor    %edx,%edx
f01019a3:	89 f0                	mov    %esi,%eax
f01019a5:	f7 f1                	div    %ecx
f01019a7:	89 c6                	mov    %eax,%esi
f01019a9:	89 e8                	mov    %ebp,%eax
f01019ab:	89 f7                	mov    %esi,%edi
f01019ad:	f7 f1                	div    %ecx
f01019af:	89 fa                	mov    %edi,%edx
f01019b1:	83 c4 1c             	add    $0x1c,%esp
f01019b4:	5b                   	pop    %ebx
f01019b5:	5e                   	pop    %esi
f01019b6:	5f                   	pop    %edi
f01019b7:	5d                   	pop    %ebp
f01019b8:	c3                   	ret    
f01019b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01019c0:	89 f9                	mov    %edi,%ecx
f01019c2:	b8 20 00 00 00       	mov    $0x20,%eax
f01019c7:	29 f8                	sub    %edi,%eax
f01019c9:	d3 e2                	shl    %cl,%edx
f01019cb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01019cf:	89 c1                	mov    %eax,%ecx
f01019d1:	89 da                	mov    %ebx,%edx
f01019d3:	d3 ea                	shr    %cl,%edx
f01019d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01019d9:	09 d1                	or     %edx,%ecx
f01019db:	89 f2                	mov    %esi,%edx
f01019dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019e1:	89 f9                	mov    %edi,%ecx
f01019e3:	d3 e3                	shl    %cl,%ebx
f01019e5:	89 c1                	mov    %eax,%ecx
f01019e7:	d3 ea                	shr    %cl,%edx
f01019e9:	89 f9                	mov    %edi,%ecx
f01019eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01019ef:	89 eb                	mov    %ebp,%ebx
f01019f1:	d3 e6                	shl    %cl,%esi
f01019f3:	89 c1                	mov    %eax,%ecx
f01019f5:	d3 eb                	shr    %cl,%ebx
f01019f7:	09 de                	or     %ebx,%esi
f01019f9:	89 f0                	mov    %esi,%eax
f01019fb:	f7 74 24 08          	divl   0x8(%esp)
f01019ff:	89 d6                	mov    %edx,%esi
f0101a01:	89 c3                	mov    %eax,%ebx
f0101a03:	f7 64 24 0c          	mull   0xc(%esp)
f0101a07:	39 d6                	cmp    %edx,%esi
f0101a09:	72 15                	jb     f0101a20 <__udivdi3+0x100>
f0101a0b:	89 f9                	mov    %edi,%ecx
f0101a0d:	d3 e5                	shl    %cl,%ebp
f0101a0f:	39 c5                	cmp    %eax,%ebp
f0101a11:	73 04                	jae    f0101a17 <__udivdi3+0xf7>
f0101a13:	39 d6                	cmp    %edx,%esi
f0101a15:	74 09                	je     f0101a20 <__udivdi3+0x100>
f0101a17:	89 d8                	mov    %ebx,%eax
f0101a19:	31 ff                	xor    %edi,%edi
f0101a1b:	e9 40 ff ff ff       	jmp    f0101960 <__udivdi3+0x40>
f0101a20:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101a23:	31 ff                	xor    %edi,%edi
f0101a25:	e9 36 ff ff ff       	jmp    f0101960 <__udivdi3+0x40>
f0101a2a:	66 90                	xchg   %ax,%ax
f0101a2c:	66 90                	xchg   %ax,%ax
f0101a2e:	66 90                	xchg   %ax,%ax

f0101a30 <__umoddi3>:
f0101a30:	f3 0f 1e fb          	endbr32 
f0101a34:	55                   	push   %ebp
f0101a35:	57                   	push   %edi
f0101a36:	56                   	push   %esi
f0101a37:	53                   	push   %ebx
f0101a38:	83 ec 1c             	sub    $0x1c,%esp
f0101a3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101a3f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a47:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a4b:	85 c0                	test   %eax,%eax
f0101a4d:	75 19                	jne    f0101a68 <__umoddi3+0x38>
f0101a4f:	39 df                	cmp    %ebx,%edi
f0101a51:	76 5d                	jbe    f0101ab0 <__umoddi3+0x80>
f0101a53:	89 f0                	mov    %esi,%eax
f0101a55:	89 da                	mov    %ebx,%edx
f0101a57:	f7 f7                	div    %edi
f0101a59:	89 d0                	mov    %edx,%eax
f0101a5b:	31 d2                	xor    %edx,%edx
f0101a5d:	83 c4 1c             	add    $0x1c,%esp
f0101a60:	5b                   	pop    %ebx
f0101a61:	5e                   	pop    %esi
f0101a62:	5f                   	pop    %edi
f0101a63:	5d                   	pop    %ebp
f0101a64:	c3                   	ret    
f0101a65:	8d 76 00             	lea    0x0(%esi),%esi
f0101a68:	89 f2                	mov    %esi,%edx
f0101a6a:	39 d8                	cmp    %ebx,%eax
f0101a6c:	76 12                	jbe    f0101a80 <__umoddi3+0x50>
f0101a6e:	89 f0                	mov    %esi,%eax
f0101a70:	89 da                	mov    %ebx,%edx
f0101a72:	83 c4 1c             	add    $0x1c,%esp
f0101a75:	5b                   	pop    %ebx
f0101a76:	5e                   	pop    %esi
f0101a77:	5f                   	pop    %edi
f0101a78:	5d                   	pop    %ebp
f0101a79:	c3                   	ret    
f0101a7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a80:	0f bd e8             	bsr    %eax,%ebp
f0101a83:	83 f5 1f             	xor    $0x1f,%ebp
f0101a86:	75 50                	jne    f0101ad8 <__umoddi3+0xa8>
f0101a88:	39 d8                	cmp    %ebx,%eax
f0101a8a:	0f 82 e0 00 00 00    	jb     f0101b70 <__umoddi3+0x140>
f0101a90:	89 d9                	mov    %ebx,%ecx
f0101a92:	39 f7                	cmp    %esi,%edi
f0101a94:	0f 86 d6 00 00 00    	jbe    f0101b70 <__umoddi3+0x140>
f0101a9a:	89 d0                	mov    %edx,%eax
f0101a9c:	89 ca                	mov    %ecx,%edx
f0101a9e:	83 c4 1c             	add    $0x1c,%esp
f0101aa1:	5b                   	pop    %ebx
f0101aa2:	5e                   	pop    %esi
f0101aa3:	5f                   	pop    %edi
f0101aa4:	5d                   	pop    %ebp
f0101aa5:	c3                   	ret    
f0101aa6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101aad:	8d 76 00             	lea    0x0(%esi),%esi
f0101ab0:	89 fd                	mov    %edi,%ebp
f0101ab2:	85 ff                	test   %edi,%edi
f0101ab4:	75 0b                	jne    f0101ac1 <__umoddi3+0x91>
f0101ab6:	b8 01 00 00 00       	mov    $0x1,%eax
f0101abb:	31 d2                	xor    %edx,%edx
f0101abd:	f7 f7                	div    %edi
f0101abf:	89 c5                	mov    %eax,%ebp
f0101ac1:	89 d8                	mov    %ebx,%eax
f0101ac3:	31 d2                	xor    %edx,%edx
f0101ac5:	f7 f5                	div    %ebp
f0101ac7:	89 f0                	mov    %esi,%eax
f0101ac9:	f7 f5                	div    %ebp
f0101acb:	89 d0                	mov    %edx,%eax
f0101acd:	31 d2                	xor    %edx,%edx
f0101acf:	eb 8c                	jmp    f0101a5d <__umoddi3+0x2d>
f0101ad1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101ad8:	89 e9                	mov    %ebp,%ecx
f0101ada:	ba 20 00 00 00       	mov    $0x20,%edx
f0101adf:	29 ea                	sub    %ebp,%edx
f0101ae1:	d3 e0                	shl    %cl,%eax
f0101ae3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ae7:	89 d1                	mov    %edx,%ecx
f0101ae9:	89 f8                	mov    %edi,%eax
f0101aeb:	d3 e8                	shr    %cl,%eax
f0101aed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101af1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101af5:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101af9:	09 c1                	or     %eax,%ecx
f0101afb:	89 d8                	mov    %ebx,%eax
f0101afd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101b01:	89 e9                	mov    %ebp,%ecx
f0101b03:	d3 e7                	shl    %cl,%edi
f0101b05:	89 d1                	mov    %edx,%ecx
f0101b07:	d3 e8                	shr    %cl,%eax
f0101b09:	89 e9                	mov    %ebp,%ecx
f0101b0b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101b0f:	d3 e3                	shl    %cl,%ebx
f0101b11:	89 c7                	mov    %eax,%edi
f0101b13:	89 d1                	mov    %edx,%ecx
f0101b15:	89 f0                	mov    %esi,%eax
f0101b17:	d3 e8                	shr    %cl,%eax
f0101b19:	89 e9                	mov    %ebp,%ecx
f0101b1b:	89 fa                	mov    %edi,%edx
f0101b1d:	d3 e6                	shl    %cl,%esi
f0101b1f:	09 d8                	or     %ebx,%eax
f0101b21:	f7 74 24 08          	divl   0x8(%esp)
f0101b25:	89 d1                	mov    %edx,%ecx
f0101b27:	89 f3                	mov    %esi,%ebx
f0101b29:	f7 64 24 0c          	mull   0xc(%esp)
f0101b2d:	89 c6                	mov    %eax,%esi
f0101b2f:	89 d7                	mov    %edx,%edi
f0101b31:	39 d1                	cmp    %edx,%ecx
f0101b33:	72 06                	jb     f0101b3b <__umoddi3+0x10b>
f0101b35:	75 10                	jne    f0101b47 <__umoddi3+0x117>
f0101b37:	39 c3                	cmp    %eax,%ebx
f0101b39:	73 0c                	jae    f0101b47 <__umoddi3+0x117>
f0101b3b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101b3f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101b43:	89 d7                	mov    %edx,%edi
f0101b45:	89 c6                	mov    %eax,%esi
f0101b47:	89 ca                	mov    %ecx,%edx
f0101b49:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101b4e:	29 f3                	sub    %esi,%ebx
f0101b50:	19 fa                	sbb    %edi,%edx
f0101b52:	89 d0                	mov    %edx,%eax
f0101b54:	d3 e0                	shl    %cl,%eax
f0101b56:	89 e9                	mov    %ebp,%ecx
f0101b58:	d3 eb                	shr    %cl,%ebx
f0101b5a:	d3 ea                	shr    %cl,%edx
f0101b5c:	09 d8                	or     %ebx,%eax
f0101b5e:	83 c4 1c             	add    $0x1c,%esp
f0101b61:	5b                   	pop    %ebx
f0101b62:	5e                   	pop    %esi
f0101b63:	5f                   	pop    %edi
f0101b64:	5d                   	pop    %ebp
f0101b65:	c3                   	ret    
f0101b66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b6d:	8d 76 00             	lea    0x0(%esi),%esi
f0101b70:	29 fe                	sub    %edi,%esi
f0101b72:	19 c3                	sbb    %eax,%ebx
f0101b74:	89 f2                	mov    %esi,%edx
f0101b76:	89 d9                	mov    %ebx,%ecx
f0101b78:	e9 1d ff ff ff       	jmp    f0101a9a <__umoddi3+0x6a>
