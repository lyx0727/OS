
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
f0100049:	e8 8c 01 00 00       	call   f01001da <__x86.get_pc_thunk.bx>
f010004e:	81 c3 ba 22 01 00    	add    $0x122ba,%ebx
f0100054:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100057:	83 ec 08             	sub    $0x8,%esp
f010005a:	56                   	push   %esi
f010005b:	8d 83 78 f9 fe ff    	lea    -0x10688(%ebx),%eax
f0100061:	50                   	push   %eax
f0100062:	e8 3d 0b 00 00       	call   f0100ba4 <cprintf>
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
f0100081:	8d 83 94 f9 fe ff    	lea    -0x1066c(%ebx),%eax
f0100087:	50                   	push   %eax
f0100088:	e8 17 0b 00 00       	call   f0100ba4 <cprintf>
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
f01000a0:	e8 31 08 00 00       	call   f01008d6 <mon_backtrace>
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
f01000b5:	e8 20 01 00 00       	call   f01001da <__x86.get_pc_thunk.bx>
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
f01000d2:	e8 2f 17 00 00       	call   f0101806 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000d7:	e8 59 05 00 00       	call   f0100635 <cons_init>

	cprintf("hello world\n");
f01000dc:	8d 83 af f9 fe ff    	lea    -0x10651(%ebx),%eax
f01000e2:	89 04 24             	mov    %eax,(%esp)
f01000e5:	e8 ba 0a 00 00       	call   f0100ba4 <cprintf>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ea:	83 c4 08             	add    $0x8,%esp
f01000ed:	68 ac 1a 00 00       	push   $0x1aac
f01000f2:	8d 83 bc f9 fe ff    	lea    -0x10644(%ebx),%eax
f01000f8:	50                   	push   %eax
f01000f9:	e8 a6 0a 00 00       	call   f0100ba4 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000fe:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f0100105:	e8 36 ff ff ff       	call   f0100040 <test_backtrace>
f010010a:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010010d:	83 ec 0c             	sub    $0xc,%esp
f0100110:	6a 00                	push   $0x0
f0100112:	e8 c6 08 00 00       	call   f01009dd <monitor>
f0100117:	83 c4 10             	add    $0x10,%esp
f010011a:	eb f1                	jmp    f010010d <i386_init+0x63>

f010011c <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010011c:	f3 0f 1e fb          	endbr32 
f0100120:	55                   	push   %ebp
f0100121:	89 e5                	mov    %esp,%ebp
f0100123:	57                   	push   %edi
f0100124:	56                   	push   %esi
f0100125:	53                   	push   %ebx
f0100126:	83 ec 0c             	sub    $0xc,%esp
f0100129:	e8 ac 00 00 00       	call   f01001da <__x86.get_pc_thunk.bx>
f010012e:	81 c3 da 21 01 00    	add    $0x121da,%ebx
f0100134:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f0100137:	c7 c0 a4 46 11 f0    	mov    $0xf01146a4,%eax
f010013d:	83 38 00             	cmpl   $0x0,(%eax)
f0100140:	74 0f                	je     f0100151 <_panic+0x35>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100142:	83 ec 0c             	sub    $0xc,%esp
f0100145:	6a 00                	push   $0x0
f0100147:	e8 91 08 00 00       	call   f01009dd <monitor>
f010014c:	83 c4 10             	add    $0x10,%esp
f010014f:	eb f1                	jmp    f0100142 <_panic+0x26>
	panicstr = fmt;
f0100151:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100153:	fa                   	cli    
f0100154:	fc                   	cld    
	va_start(ap, fmt);
f0100155:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100158:	83 ec 04             	sub    $0x4,%esp
f010015b:	ff 75 0c             	pushl  0xc(%ebp)
f010015e:	ff 75 08             	pushl  0x8(%ebp)
f0100161:	8d 83 d7 f9 fe ff    	lea    -0x10629(%ebx),%eax
f0100167:	50                   	push   %eax
f0100168:	e8 37 0a 00 00       	call   f0100ba4 <cprintf>
	vcprintf(fmt, ap);
f010016d:	83 c4 08             	add    $0x8,%esp
f0100170:	56                   	push   %esi
f0100171:	57                   	push   %edi
f0100172:	e8 f2 09 00 00       	call   f0100b69 <vcprintf>
	cprintf("\n");
f0100177:	8d 83 13 fa fe ff    	lea    -0x105ed(%ebx),%eax
f010017d:	89 04 24             	mov    %eax,(%esp)
f0100180:	e8 1f 0a 00 00       	call   f0100ba4 <cprintf>
f0100185:	83 c4 10             	add    $0x10,%esp
f0100188:	eb b8                	jmp    f0100142 <_panic+0x26>

f010018a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010018a:	f3 0f 1e fb          	endbr32 
f010018e:	55                   	push   %ebp
f010018f:	89 e5                	mov    %esp,%ebp
f0100191:	56                   	push   %esi
f0100192:	53                   	push   %ebx
f0100193:	e8 42 00 00 00       	call   f01001da <__x86.get_pc_thunk.bx>
f0100198:	81 c3 70 21 01 00    	add    $0x12170,%ebx
	va_list ap;

	va_start(ap, fmt);
f010019e:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f01001a1:	83 ec 04             	sub    $0x4,%esp
f01001a4:	ff 75 0c             	pushl  0xc(%ebp)
f01001a7:	ff 75 08             	pushl  0x8(%ebp)
f01001aa:	8d 83 ef f9 fe ff    	lea    -0x10611(%ebx),%eax
f01001b0:	50                   	push   %eax
f01001b1:	e8 ee 09 00 00       	call   f0100ba4 <cprintf>
	vcprintf(fmt, ap);
f01001b6:	83 c4 08             	add    $0x8,%esp
f01001b9:	56                   	push   %esi
f01001ba:	ff 75 10             	pushl  0x10(%ebp)
f01001bd:	e8 a7 09 00 00       	call   f0100b69 <vcprintf>
	cprintf("\n");
f01001c2:	8d 83 13 fa fe ff    	lea    -0x105ed(%ebx),%eax
f01001c8:	89 04 24             	mov    %eax,(%esp)
f01001cb:	e8 d4 09 00 00       	call   f0100ba4 <cprintf>
	va_end(ap);
}
f01001d0:	83 c4 10             	add    $0x10,%esp
f01001d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5e                   	pop    %esi
f01001d8:	5d                   	pop    %ebp
f01001d9:	c3                   	ret    

f01001da <__x86.get_pc_thunk.bx>:
f01001da:	8b 1c 24             	mov    (%esp),%ebx
f01001dd:	c3                   	ret    

f01001de <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001de:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001e7:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001e8:	a8 01                	test   $0x1,%al
f01001ea:	74 0a                	je     f01001f6 <serial_proc_data+0x18>
f01001ec:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001f1:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001f2:	0f b6 c0             	movzbl %al,%eax
f01001f5:	c3                   	ret    
		return -1;
f01001f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001fb:	c3                   	ret    

f01001fc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001fc:	55                   	push   %ebp
f01001fd:	89 e5                	mov    %esp,%ebp
f01001ff:	57                   	push   %edi
f0100200:	56                   	push   %esi
f0100201:	53                   	push   %ebx
f0100202:	83 ec 1c             	sub    $0x1c,%esp
f0100205:	e8 88 05 00 00       	call   f0100792 <__x86.get_pc_thunk.si>
f010020a:	81 c6 fe 20 01 00    	add    $0x120fe,%esi
f0100210:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100212:	8d 1d 78 1d 00 00    	lea    0x1d78,%ebx
f0100218:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010021b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010021e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100221:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100224:	ff d0                	call   *%eax
f0100226:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100229:	74 2b                	je     f0100256 <cons_intr+0x5a>
		if (c == 0)
f010022b:	85 c0                	test   %eax,%eax
f010022d:	74 f2                	je     f0100221 <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f010022f:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100236:	8d 51 01             	lea    0x1(%ecx),%edx
f0100239:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010023c:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f010023f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100245:	b8 00 00 00 00       	mov    $0x0,%eax
f010024a:	0f 44 d0             	cmove  %eax,%edx
f010024d:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100254:	eb cb                	jmp    f0100221 <cons_intr+0x25>
	}
}
f0100256:	83 c4 1c             	add    $0x1c,%esp
f0100259:	5b                   	pop    %ebx
f010025a:	5e                   	pop    %esi
f010025b:	5f                   	pop    %edi
f010025c:	5d                   	pop    %ebp
f010025d:	c3                   	ret    

f010025e <kbd_proc_data>:
{
f010025e:	f3 0f 1e fb          	endbr32 
f0100262:	55                   	push   %ebp
f0100263:	89 e5                	mov    %esp,%ebp
f0100265:	56                   	push   %esi
f0100266:	53                   	push   %ebx
f0100267:	e8 6e ff ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f010026c:	81 c3 9c 20 01 00    	add    $0x1209c,%ebx
f0100272:	ba 64 00 00 00       	mov    $0x64,%edx
f0100277:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100278:	a8 01                	test   $0x1,%al
f010027a:	0f 84 fb 00 00 00    	je     f010037b <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f0100280:	a8 20                	test   $0x20,%al
f0100282:	0f 85 fa 00 00 00    	jne    f0100382 <kbd_proc_data+0x124>
f0100288:	ba 60 00 00 00       	mov    $0x60,%edx
f010028d:	ec                   	in     (%dx),%al
f010028e:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100290:	3c e0                	cmp    $0xe0,%al
f0100292:	74 64                	je     f01002f8 <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100294:	84 c0                	test   %al,%al
f0100296:	78 75                	js     f010030d <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f0100298:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010029e:	f6 c1 40             	test   $0x40,%cl
f01002a1:	74 0e                	je     f01002b1 <kbd_proc_data+0x53>
		data |= 0x80;
f01002a3:	83 c8 80             	or     $0xffffff80,%eax
f01002a6:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002a8:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002ab:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f01002b1:	0f b6 d2             	movzbl %dl,%edx
f01002b4:	0f b6 84 13 38 fb fe 	movzbl -0x104c8(%ebx,%edx,1),%eax
f01002bb:	ff 
f01002bc:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f01002c2:	0f b6 8c 13 38 fa fe 	movzbl -0x105c8(%ebx,%edx,1),%ecx
f01002c9:	ff 
f01002ca:	31 c8                	xor    %ecx,%eax
f01002cc:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002d2:	89 c1                	mov    %eax,%ecx
f01002d4:	83 e1 03             	and    $0x3,%ecx
f01002d7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002de:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002e2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002e5:	a8 08                	test   $0x8,%al
f01002e7:	74 65                	je     f010034e <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f01002e9:	89 f2                	mov    %esi,%edx
f01002eb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002ee:	83 f9 19             	cmp    $0x19,%ecx
f01002f1:	77 4f                	ja     f0100342 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01002f3:	83 ee 20             	sub    $0x20,%esi
f01002f6:	eb 0c                	jmp    f0100304 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01002f8:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002ff:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100304:	89 f0                	mov    %esi,%eax
f0100306:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100309:	5b                   	pop    %ebx
f010030a:	5e                   	pop    %esi
f010030b:	5d                   	pop    %ebp
f010030c:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010030d:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f0100313:	89 ce                	mov    %ecx,%esi
f0100315:	83 e6 40             	and    $0x40,%esi
f0100318:	83 e0 7f             	and    $0x7f,%eax
f010031b:	85 f6                	test   %esi,%esi
f010031d:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100320:	0f b6 d2             	movzbl %dl,%edx
f0100323:	0f b6 84 13 38 fb fe 	movzbl -0x104c8(%ebx,%edx,1),%eax
f010032a:	ff 
f010032b:	83 c8 40             	or     $0x40,%eax
f010032e:	0f b6 c0             	movzbl %al,%eax
f0100331:	f7 d0                	not    %eax
f0100333:	21 c8                	and    %ecx,%eax
f0100335:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f010033b:	be 00 00 00 00       	mov    $0x0,%esi
f0100340:	eb c2                	jmp    f0100304 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100342:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100345:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100348:	83 fa 1a             	cmp    $0x1a,%edx
f010034b:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010034e:	f7 d0                	not    %eax
f0100350:	a8 06                	test   $0x6,%al
f0100352:	75 b0                	jne    f0100304 <kbd_proc_data+0xa6>
f0100354:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010035a:	75 a8                	jne    f0100304 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010035c:	83 ec 0c             	sub    $0xc,%esp
f010035f:	8d 83 09 fa fe ff    	lea    -0x105f7(%ebx),%eax
f0100365:	50                   	push   %eax
f0100366:	e8 39 08 00 00       	call   f0100ba4 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100370:	ba 92 00 00 00       	mov    $0x92,%edx
f0100375:	ee                   	out    %al,(%dx)
}
f0100376:	83 c4 10             	add    $0x10,%esp
f0100379:	eb 89                	jmp    f0100304 <kbd_proc_data+0xa6>
		return -1;
f010037b:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100380:	eb 82                	jmp    f0100304 <kbd_proc_data+0xa6>
		return -1;
f0100382:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100387:	e9 78 ff ff ff       	jmp    f0100304 <kbd_proc_data+0xa6>

f010038c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010038c:	55                   	push   %ebp
f010038d:	89 e5                	mov    %esp,%ebp
f010038f:	57                   	push   %edi
f0100390:	56                   	push   %esi
f0100391:	53                   	push   %ebx
f0100392:	83 ec 1c             	sub    $0x1c,%esp
f0100395:	e8 40 fe ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f010039a:	81 c3 6e 1f 01 00    	add    $0x11f6e,%ebx
f01003a0:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003a2:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003a7:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003ac:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003b1:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003b2:	a8 20                	test   $0x20,%al
f01003b4:	75 13                	jne    f01003c9 <cons_putc+0x3d>
f01003b6:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003bc:	7f 0b                	jg     f01003c9 <cons_putc+0x3d>
f01003be:	89 ca                	mov    %ecx,%edx
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	ec                   	in     (%dx),%al
f01003c2:	ec                   	in     (%dx),%al
f01003c3:	ec                   	in     (%dx),%al
	     i++)
f01003c4:	83 c6 01             	add    $0x1,%esi
f01003c7:	eb e3                	jmp    f01003ac <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01003c9:	89 f8                	mov    %edi,%eax
f01003cb:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003ce:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003d3:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003d4:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003d9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003de:	ba 79 03 00 00       	mov    $0x379,%edx
f01003e3:	ec                   	in     (%dx),%al
f01003e4:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003ea:	7f 0f                	jg     f01003fb <cons_putc+0x6f>
f01003ec:	84 c0                	test   %al,%al
f01003ee:	78 0b                	js     f01003fb <cons_putc+0x6f>
f01003f0:	89 ca                	mov    %ecx,%edx
f01003f2:	ec                   	in     (%dx),%al
f01003f3:	ec                   	in     (%dx),%al
f01003f4:	ec                   	in     (%dx),%al
f01003f5:	ec                   	in     (%dx),%al
f01003f6:	83 c6 01             	add    $0x1,%esi
f01003f9:	eb e3                	jmp    f01003de <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003fb:	ba 78 03 00 00       	mov    $0x378,%edx
f0100400:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100404:	ee                   	out    %al,(%dx)
f0100405:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010040a:	b8 0d 00 00 00       	mov    $0xd,%eax
f010040f:	ee                   	out    %al,(%dx)
f0100410:	b8 08 00 00 00       	mov    $0x8,%eax
f0100415:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100416:	89 f8                	mov    %edi,%eax
f0100418:	80 cc 07             	or     $0x7,%ah
f010041b:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100421:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100424:	89 f8                	mov    %edi,%eax
f0100426:	0f b6 c0             	movzbl %al,%eax
f0100429:	89 f9                	mov    %edi,%ecx
f010042b:	80 f9 0a             	cmp    $0xa,%cl
f010042e:	0f 84 e2 00 00 00    	je     f0100516 <cons_putc+0x18a>
f0100434:	83 f8 0a             	cmp    $0xa,%eax
f0100437:	7f 46                	jg     f010047f <cons_putc+0xf3>
f0100439:	83 f8 08             	cmp    $0x8,%eax
f010043c:	0f 84 a8 00 00 00    	je     f01004ea <cons_putc+0x15e>
f0100442:	83 f8 09             	cmp    $0x9,%eax
f0100445:	0f 85 d8 00 00 00    	jne    f0100523 <cons_putc+0x197>
		cons_putc(' ');
f010044b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100450:	e8 37 ff ff ff       	call   f010038c <cons_putc>
		cons_putc(' ');
f0100455:	b8 20 00 00 00       	mov    $0x20,%eax
f010045a:	e8 2d ff ff ff       	call   f010038c <cons_putc>
		cons_putc(' ');
f010045f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100464:	e8 23 ff ff ff       	call   f010038c <cons_putc>
		cons_putc(' ');
f0100469:	b8 20 00 00 00       	mov    $0x20,%eax
f010046e:	e8 19 ff ff ff       	call   f010038c <cons_putc>
		cons_putc(' ');
f0100473:	b8 20 00 00 00       	mov    $0x20,%eax
f0100478:	e8 0f ff ff ff       	call   f010038c <cons_putc>
		break;
f010047d:	eb 26                	jmp    f01004a5 <cons_putc+0x119>
	switch (c & 0xff) {
f010047f:	83 f8 0d             	cmp    $0xd,%eax
f0100482:	0f 85 9b 00 00 00    	jne    f0100523 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f0100488:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010048f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100495:	c1 e8 16             	shr    $0x16,%eax
f0100498:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010049b:	c1 e0 04             	shl    $0x4,%eax
f010049e:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01004a5:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f01004ac:	cf 07 
f01004ae:	0f 87 92 00 00 00    	ja     f0100546 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f01004b4:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f01004ba:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004bf:	89 ca                	mov    %ecx,%edx
f01004c1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004c2:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f01004c9:	8d 71 01             	lea    0x1(%ecx),%esi
f01004cc:	89 d8                	mov    %ebx,%eax
f01004ce:	66 c1 e8 08          	shr    $0x8,%ax
f01004d2:	89 f2                	mov    %esi,%edx
f01004d4:	ee                   	out    %al,(%dx)
f01004d5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004da:	89 ca                	mov    %ecx,%edx
f01004dc:	ee                   	out    %al,(%dx)
f01004dd:	89 d8                	mov    %ebx,%eax
f01004df:	89 f2                	mov    %esi,%edx
f01004e1:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004e5:	5b                   	pop    %ebx
f01004e6:	5e                   	pop    %esi
f01004e7:	5f                   	pop    %edi
f01004e8:	5d                   	pop    %ebp
f01004e9:	c3                   	ret    
		if (crt_pos > 0) {
f01004ea:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004f1:	66 85 c0             	test   %ax,%ax
f01004f4:	74 be                	je     f01004b4 <cons_putc+0x128>
			crt_pos--;
f01004f6:	83 e8 01             	sub    $0x1,%eax
f01004f9:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100500:	0f b7 c0             	movzwl %ax,%eax
f0100503:	89 fa                	mov    %edi,%edx
f0100505:	b2 00                	mov    $0x0,%dl
f0100507:	83 ca 20             	or     $0x20,%edx
f010050a:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f0100510:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100514:	eb 8f                	jmp    f01004a5 <cons_putc+0x119>
		crt_pos += CRT_COLS;
f0100516:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f010051d:	50 
f010051e:	e9 65 ff ff ff       	jmp    f0100488 <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100523:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010052a:	8d 50 01             	lea    0x1(%eax),%edx
f010052d:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100534:	0f b7 c0             	movzwl %ax,%eax
f0100537:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010053d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100541:	e9 5f ff ff ff       	jmp    f01004a5 <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100546:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010054c:	83 ec 04             	sub    $0x4,%esp
f010054f:	68 00 0f 00 00       	push   $0xf00
f0100554:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010055a:	52                   	push   %edx
f010055b:	50                   	push   %eax
f010055c:	e8 f1 12 00 00       	call   f0101852 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100561:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100567:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010056d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100573:	83 c4 10             	add    $0x10,%esp
f0100576:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010057b:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010057e:	39 d0                	cmp    %edx,%eax
f0100580:	75 f4                	jne    f0100576 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100582:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f0100589:	50 
f010058a:	e9 25 ff ff ff       	jmp    f01004b4 <cons_putc+0x128>

f010058f <serial_intr>:
{
f010058f:	f3 0f 1e fb          	endbr32 
f0100593:	e8 f6 01 00 00       	call   f010078e <__x86.get_pc_thunk.ax>
f0100598:	05 70 1d 01 00       	add    $0x11d70,%eax
	if (serial_exists)
f010059d:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f01005a4:	75 01                	jne    f01005a7 <serial_intr+0x18>
f01005a6:	c3                   	ret    
{
f01005a7:	55                   	push   %ebp
f01005a8:	89 e5                	mov    %esp,%ebp
f01005aa:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005ad:	8d 80 d6 de fe ff    	lea    -0x1212a(%eax),%eax
f01005b3:	e8 44 fc ff ff       	call   f01001fc <cons_intr>
}
f01005b8:	c9                   	leave  
f01005b9:	c3                   	ret    

f01005ba <kbd_intr>:
{
f01005ba:	f3 0f 1e fb          	endbr32 
f01005be:	55                   	push   %ebp
f01005bf:	89 e5                	mov    %esp,%ebp
f01005c1:	83 ec 08             	sub    $0x8,%esp
f01005c4:	e8 c5 01 00 00       	call   f010078e <__x86.get_pc_thunk.ax>
f01005c9:	05 3f 1d 01 00       	add    $0x11d3f,%eax
	cons_intr(kbd_proc_data);
f01005ce:	8d 80 56 df fe ff    	lea    -0x120aa(%eax),%eax
f01005d4:	e8 23 fc ff ff       	call   f01001fc <cons_intr>
}
f01005d9:	c9                   	leave  
f01005da:	c3                   	ret    

f01005db <cons_getc>:
{
f01005db:	f3 0f 1e fb          	endbr32 
f01005df:	55                   	push   %ebp
f01005e0:	89 e5                	mov    %esp,%ebp
f01005e2:	53                   	push   %ebx
f01005e3:	83 ec 04             	sub    $0x4,%esp
f01005e6:	e8 ef fb ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01005eb:	81 c3 1d 1d 01 00    	add    $0x11d1d,%ebx
	serial_intr();
f01005f1:	e8 99 ff ff ff       	call   f010058f <serial_intr>
	kbd_intr();
f01005f6:	e8 bf ff ff ff       	call   f01005ba <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005fb:	8b 83 78 1f 00 00    	mov    0x1f78(%ebx),%eax
	return 0;
f0100601:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100606:	3b 83 7c 1f 00 00    	cmp    0x1f7c(%ebx),%eax
f010060c:	74 1f                	je     f010062d <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f010060e:	8d 48 01             	lea    0x1(%eax),%ecx
f0100611:	0f b6 94 03 78 1d 00 	movzbl 0x1d78(%ebx,%eax,1),%edx
f0100618:	00 
			cons.rpos = 0;
f0100619:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010061f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100624:	0f 44 c8             	cmove  %eax,%ecx
f0100627:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
}
f010062d:	89 d0                	mov    %edx,%eax
f010062f:	83 c4 04             	add    $0x4,%esp
f0100632:	5b                   	pop    %ebx
f0100633:	5d                   	pop    %ebp
f0100634:	c3                   	ret    

f0100635 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100635:	f3 0f 1e fb          	endbr32 
f0100639:	55                   	push   %ebp
f010063a:	89 e5                	mov    %esp,%ebp
f010063c:	57                   	push   %edi
f010063d:	56                   	push   %esi
f010063e:	53                   	push   %ebx
f010063f:	83 ec 1c             	sub    $0x1c,%esp
f0100642:	e8 93 fb ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100647:	81 c3 c1 1c 01 00    	add    $0x11cc1,%ebx
	was = *cp;
f010064d:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100654:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010065b:	5a a5 
	if (*cp != 0xA55A) {
f010065d:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100664:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100668:	0f 84 bc 00 00 00    	je     f010072a <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f010066e:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f0100675:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100678:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f010067f:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f0100685:	b8 0e 00 00 00       	mov    $0xe,%eax
f010068a:	89 fa                	mov    %edi,%edx
f010068c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010068d:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100690:	89 ca                	mov    %ecx,%edx
f0100692:	ec                   	in     (%dx),%al
f0100693:	0f b6 f0             	movzbl %al,%esi
f0100696:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100699:	b8 0f 00 00 00       	mov    $0xf,%eax
f010069e:	89 fa                	mov    %edi,%edx
f01006a0:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a1:	89 ca                	mov    %ecx,%edx
f01006a3:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01006a7:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f01006ad:	0f b6 c0             	movzbl %al,%eax
f01006b0:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f01006b2:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006b9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01006be:	89 c8                	mov    %ecx,%eax
f01006c0:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006c5:	ee                   	out    %al,(%dx)
f01006c6:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006cb:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006d0:	89 fa                	mov    %edi,%edx
f01006d2:	ee                   	out    %al,(%dx)
f01006d3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006d8:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006dd:	ee                   	out    %al,(%dx)
f01006de:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006e3:	89 c8                	mov    %ecx,%eax
f01006e5:	89 f2                	mov    %esi,%edx
f01006e7:	ee                   	out    %al,(%dx)
f01006e8:	b8 03 00 00 00       	mov    $0x3,%eax
f01006ed:	89 fa                	mov    %edi,%edx
f01006ef:	ee                   	out    %al,(%dx)
f01006f0:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006f5:	89 c8                	mov    %ecx,%eax
f01006f7:	ee                   	out    %al,(%dx)
f01006f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01006fd:	89 f2                	mov    %esi,%edx
f01006ff:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100700:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100705:	ec                   	in     (%dx),%al
f0100706:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100708:	3c ff                	cmp    $0xff,%al
f010070a:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f0100711:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100716:	ec                   	in     (%dx),%al
f0100717:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010071c:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010071d:	80 f9 ff             	cmp    $0xff,%cl
f0100720:	74 25                	je     f0100747 <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f0100722:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100725:	5b                   	pop    %ebx
f0100726:	5e                   	pop    %esi
f0100727:	5f                   	pop    %edi
f0100728:	5d                   	pop    %ebp
f0100729:	c3                   	ret    
		*cp = was;
f010072a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100731:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100738:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010073b:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100742:	e9 38 ff ff ff       	jmp    f010067f <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f0100747:	83 ec 0c             	sub    $0xc,%esp
f010074a:	8d 83 15 fa fe ff    	lea    -0x105eb(%ebx),%eax
f0100750:	50                   	push   %eax
f0100751:	e8 4e 04 00 00       	call   f0100ba4 <cprintf>
f0100756:	83 c4 10             	add    $0x10,%esp
}
f0100759:	eb c7                	jmp    f0100722 <cons_init+0xed>

f010075b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010075b:	f3 0f 1e fb          	endbr32 
f010075f:	55                   	push   %ebp
f0100760:	89 e5                	mov    %esp,%ebp
f0100762:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100765:	8b 45 08             	mov    0x8(%ebp),%eax
f0100768:	e8 1f fc ff ff       	call   f010038c <cons_putc>
}
f010076d:	c9                   	leave  
f010076e:	c3                   	ret    

f010076f <getchar>:

int
getchar(void)
{
f010076f:	f3 0f 1e fb          	endbr32 
f0100773:	55                   	push   %ebp
f0100774:	89 e5                	mov    %esp,%ebp
f0100776:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100779:	e8 5d fe ff ff       	call   f01005db <cons_getc>
f010077e:	85 c0                	test   %eax,%eax
f0100780:	74 f7                	je     f0100779 <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100782:	c9                   	leave  
f0100783:	c3                   	ret    

f0100784 <iscons>:

int
iscons(int fdnum)
{
f0100784:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f0100788:	b8 01 00 00 00       	mov    $0x1,%eax
f010078d:	c3                   	ret    

f010078e <__x86.get_pc_thunk.ax>:
f010078e:	8b 04 24             	mov    (%esp),%eax
f0100791:	c3                   	ret    

f0100792 <__x86.get_pc_thunk.si>:
f0100792:	8b 34 24             	mov    (%esp),%esi
f0100795:	c3                   	ret    

f0100796 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100796:	f3 0f 1e fb          	endbr32 
f010079a:	55                   	push   %ebp
f010079b:	89 e5                	mov    %esp,%ebp
f010079d:	56                   	push   %esi
f010079e:	53                   	push   %ebx
f010079f:	e8 36 fa ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01007a4:	81 c3 64 1b 01 00    	add    $0x11b64,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007aa:	83 ec 04             	sub    $0x4,%esp
f01007ad:	8d 83 38 fc fe ff    	lea    -0x103c8(%ebx),%eax
f01007b3:	50                   	push   %eax
f01007b4:	8d 83 56 fc fe ff    	lea    -0x103aa(%ebx),%eax
f01007ba:	50                   	push   %eax
f01007bb:	8d b3 5b fc fe ff    	lea    -0x103a5(%ebx),%esi
f01007c1:	56                   	push   %esi
f01007c2:	e8 dd 03 00 00       	call   f0100ba4 <cprintf>
f01007c7:	83 c4 0c             	add    $0xc,%esp
f01007ca:	8d 83 f4 fc fe ff    	lea    -0x1030c(%ebx),%eax
f01007d0:	50                   	push   %eax
f01007d1:	8d 83 64 fc fe ff    	lea    -0x1039c(%ebx),%eax
f01007d7:	50                   	push   %eax
f01007d8:	56                   	push   %esi
f01007d9:	e8 c6 03 00 00       	call   f0100ba4 <cprintf>
f01007de:	83 c4 0c             	add    $0xc,%esp
f01007e1:	8d 83 14 fa fe ff    	lea    -0x105ec(%ebx),%eax
f01007e7:	50                   	push   %eax
f01007e8:	8d 83 6d fc fe ff    	lea    -0x10393(%ebx),%eax
f01007ee:	50                   	push   %eax
f01007ef:	56                   	push   %esi
f01007f0:	e8 af 03 00 00       	call   f0100ba4 <cprintf>
	return 0;
}
f01007f5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007fd:	5b                   	pop    %ebx
f01007fe:	5e                   	pop    %esi
f01007ff:	5d                   	pop    %ebp
f0100800:	c3                   	ret    

f0100801 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100801:	f3 0f 1e fb          	endbr32 
f0100805:	55                   	push   %ebp
f0100806:	89 e5                	mov    %esp,%ebp
f0100808:	57                   	push   %edi
f0100809:	56                   	push   %esi
f010080a:	53                   	push   %ebx
f010080b:	83 ec 18             	sub    $0x18,%esp
f010080e:	e8 c7 f9 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100813:	81 c3 f5 1a 01 00    	add    $0x11af5,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100819:	8d 83 77 fc fe ff    	lea    -0x10389(%ebx),%eax
f010081f:	50                   	push   %eax
f0100820:	e8 7f 03 00 00       	call   f0100ba4 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100825:	83 c4 08             	add    $0x8,%esp
f0100828:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f010082e:	8d 83 1c fd fe ff    	lea    -0x102e4(%ebx),%eax
f0100834:	50                   	push   %eax
f0100835:	e8 6a 03 00 00       	call   f0100ba4 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010083a:	83 c4 0c             	add    $0xc,%esp
f010083d:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100843:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100849:	50                   	push   %eax
f010084a:	57                   	push   %edi
f010084b:	8d 83 44 fd fe ff    	lea    -0x102bc(%ebx),%eax
f0100851:	50                   	push   %eax
f0100852:	e8 4d 03 00 00       	call   f0100ba4 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100857:	83 c4 0c             	add    $0xc,%esp
f010085a:	c7 c0 6d 1c 10 f0    	mov    $0xf0101c6d,%eax
f0100860:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100866:	52                   	push   %edx
f0100867:	50                   	push   %eax
f0100868:	8d 83 68 fd fe ff    	lea    -0x10298(%ebx),%eax
f010086e:	50                   	push   %eax
f010086f:	e8 30 03 00 00       	call   f0100ba4 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100874:	83 c4 0c             	add    $0xc,%esp
f0100877:	c7 c0 60 40 11 f0    	mov    $0xf0114060,%eax
f010087d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100883:	52                   	push   %edx
f0100884:	50                   	push   %eax
f0100885:	8d 83 8c fd fe ff    	lea    -0x10274(%ebx),%eax
f010088b:	50                   	push   %eax
f010088c:	e8 13 03 00 00       	call   f0100ba4 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100891:	83 c4 0c             	add    $0xc,%esp
f0100894:	c7 c6 a0 46 11 f0    	mov    $0xf01146a0,%esi
f010089a:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01008a0:	50                   	push   %eax
f01008a1:	56                   	push   %esi
f01008a2:	8d 83 b0 fd fe ff    	lea    -0x10250(%ebx),%eax
f01008a8:	50                   	push   %eax
f01008a9:	e8 f6 02 00 00       	call   f0100ba4 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008ae:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008b1:	29 fe                	sub    %edi,%esi
f01008b3:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008b9:	c1 fe 0a             	sar    $0xa,%esi
f01008bc:	56                   	push   %esi
f01008bd:	8d 83 d4 fd fe ff    	lea    -0x1022c(%ebx),%eax
f01008c3:	50                   	push   %eax
f01008c4:	e8 db 02 00 00       	call   f0100ba4 <cprintf>
	return 0;
}
f01008c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008d1:	5b                   	pop    %ebx
f01008d2:	5e                   	pop    %esi
f01008d3:	5f                   	pop    %edi
f01008d4:	5d                   	pop    %ebp
f01008d5:	c3                   	ret    

f01008d6 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008d6:	f3 0f 1e fb          	endbr32 
f01008da:	55                   	push   %ebp
f01008db:	89 e5                	mov    %esp,%ebp
f01008dd:	57                   	push   %edi
f01008de:	56                   	push   %esi
f01008df:	53                   	push   %ebx
f01008e0:	83 ec 40             	sub    $0x40,%esp
f01008e3:	e8 f2 f8 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01008e8:	81 c3 20 1a 01 00    	add    $0x11a20,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ee:	89 e8                	mov    %ebp,%eax
	uint32_t* ebp = (uint32_t*)read_ebp();
f01008f0:	89 c7                	mov    %eax,%edi
	struct Eipdebuginfo info;
	memset(&info, 0, sizeof(struct Eipdebuginfo));
f01008f2:	6a 18                	push   $0x18
f01008f4:	6a 00                	push   $0x0
f01008f6:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008f9:	50                   	push   %eax
f01008fa:	e8 07 0f 00 00       	call   f0101806 <memset>
	int i;
	while(ebp){
f01008ff:	83 c4 10             	add    $0x10,%esp
		uint32_t eip = *(ebp + 1);
		cprintf("ebp %08x eip %08x args", ebp, eip);
f0100902:	8d 83 90 fc fe ff    	lea    -0x10370(%ebx),%eax
f0100908:	89 45 bc             	mov    %eax,-0x44(%ebp)
		for(i = 0; i < 4; i++){
			cprintf(" %08x", *(ebp + 2 + i));
f010090b:	8d 83 a7 fc fe ff    	lea    -0x10359(%ebx),%eax
f0100911:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	while(ebp){
f0100914:	eb 02                	jmp    f0100918 <mon_backtrace+0x42>
			cprintf("%s:%d: ", info.eip_file, info.eip_line);
			cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
			cprintf("+%d", eip - info.eip_fn_addr);
			cprintf("\n");
		}
		ebp = (uint32_t*)(*ebp);
f0100916:	8b 3f                	mov    (%edi),%edi
	while(ebp){
f0100918:	85 ff                	test   %edi,%edi
f010091a:	0f 84 b0 00 00 00    	je     f01009d0 <mon_backtrace+0xfa>
		uint32_t eip = *(ebp + 1);
f0100920:	8b 47 04             	mov    0x4(%edi),%eax
f0100923:	89 45 c0             	mov    %eax,-0x40(%ebp)
		cprintf("ebp %08x eip %08x args", ebp, eip);
f0100926:	83 ec 04             	sub    $0x4,%esp
f0100929:	50                   	push   %eax
f010092a:	57                   	push   %edi
f010092b:	ff 75 bc             	pushl  -0x44(%ebp)
f010092e:	e8 71 02 00 00       	call   f0100ba4 <cprintf>
f0100933:	83 c4 10             	add    $0x10,%esp
		for(i = 0; i < 4; i++){
f0100936:	be 00 00 00 00       	mov    $0x0,%esi
			cprintf(" %08x", *(ebp + 2 + i));
f010093b:	83 ec 08             	sub    $0x8,%esp
f010093e:	ff 74 b7 08          	pushl  0x8(%edi,%esi,4)
f0100942:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100945:	e8 5a 02 00 00       	call   f0100ba4 <cprintf>
		for(i = 0; i < 4; i++){
f010094a:	83 c6 01             	add    $0x1,%esi
f010094d:	83 c4 10             	add    $0x10,%esp
f0100950:	83 fe 04             	cmp    $0x4,%esi
f0100953:	75 e6                	jne    f010093b <mon_backtrace+0x65>
		cprintf("\n");
f0100955:	83 ec 0c             	sub    $0xc,%esp
f0100958:	8d 83 13 fa fe ff    	lea    -0x105ed(%ebx),%eax
f010095e:	50                   	push   %eax
f010095f:	e8 40 02 00 00       	call   f0100ba4 <cprintf>
		if(debuginfo_eip(eip, &info) == 0){
f0100964:	83 c4 08             	add    $0x8,%esp
f0100967:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010096a:	50                   	push   %eax
f010096b:	ff 75 c0             	pushl  -0x40(%ebp)
f010096e:	e8 3e 03 00 00       	call   f0100cb1 <debuginfo_eip>
f0100973:	83 c4 10             	add    $0x10,%esp
f0100976:	85 c0                	test   %eax,%eax
f0100978:	75 9c                	jne    f0100916 <mon_backtrace+0x40>
			cprintf("%s:%d: ", info.eip_file, info.eip_line);
f010097a:	83 ec 04             	sub    $0x4,%esp
f010097d:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100980:	ff 75 d0             	pushl  -0x30(%ebp)
f0100983:	8d 83 e7 f9 fe ff    	lea    -0x10619(%ebx),%eax
f0100989:	50                   	push   %eax
f010098a:	e8 15 02 00 00       	call   f0100ba4 <cprintf>
			cprintf("%.*s", info.eip_fn_namelen, info.eip_fn_name);
f010098f:	83 c4 0c             	add    $0xc,%esp
f0100992:	ff 75 d8             	pushl  -0x28(%ebp)
f0100995:	ff 75 dc             	pushl  -0x24(%ebp)
f0100998:	8d 83 ad fc fe ff    	lea    -0x10353(%ebx),%eax
f010099e:	50                   	push   %eax
f010099f:	e8 00 02 00 00       	call   f0100ba4 <cprintf>
			cprintf("+%d", eip - info.eip_fn_addr);
f01009a4:	83 c4 08             	add    $0x8,%esp
f01009a7:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01009aa:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01009ad:	50                   	push   %eax
f01009ae:	8d 83 b2 fc fe ff    	lea    -0x1034e(%ebx),%eax
f01009b4:	50                   	push   %eax
f01009b5:	e8 ea 01 00 00       	call   f0100ba4 <cprintf>
			cprintf("\n");
f01009ba:	8d 83 13 fa fe ff    	lea    -0x105ed(%ebx),%eax
f01009c0:	89 04 24             	mov    %eax,(%esp)
f01009c3:	e8 dc 01 00 00       	call   f0100ba4 <cprintf>
f01009c8:	83 c4 10             	add    $0x10,%esp
f01009cb:	e9 46 ff ff ff       	jmp    f0100916 <mon_backtrace+0x40>
	}
	return 0;
}
f01009d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01009d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009d8:	5b                   	pop    %ebx
f01009d9:	5e                   	pop    %esi
f01009da:	5f                   	pop    %edi
f01009db:	5d                   	pop    %ebp
f01009dc:	c3                   	ret    

f01009dd <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01009dd:	f3 0f 1e fb          	endbr32 
f01009e1:	55                   	push   %ebp
f01009e2:	89 e5                	mov    %esp,%ebp
f01009e4:	57                   	push   %edi
f01009e5:	56                   	push   %esi
f01009e6:	53                   	push   %ebx
f01009e7:	83 ec 68             	sub    $0x68,%esp
f01009ea:	e8 eb f7 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01009ef:	81 c3 19 19 01 00    	add    $0x11919,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01009f5:	8d 83 00 fe fe ff    	lea    -0x10200(%ebx),%eax
f01009fb:	50                   	push   %eax
f01009fc:	e8 a3 01 00 00       	call   f0100ba4 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100a01:	8d 83 24 fe fe ff    	lea    -0x101dc(%ebx),%eax
f0100a07:	89 04 24             	mov    %eax,(%esp)
f0100a0a:	e8 95 01 00 00       	call   f0100ba4 <cprintf>
f0100a0f:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f0100a12:	8d 83 ba fc fe ff    	lea    -0x10346(%ebx),%eax
f0100a18:	89 45 a0             	mov    %eax,-0x60(%ebp)
f0100a1b:	e9 d1 00 00 00       	jmp    f0100af1 <monitor+0x114>
f0100a20:	83 ec 08             	sub    $0x8,%esp
f0100a23:	0f be c0             	movsbl %al,%eax
f0100a26:	50                   	push   %eax
f0100a27:	ff 75 a0             	pushl  -0x60(%ebp)
f0100a2a:	e8 92 0d 00 00       	call   f01017c1 <strchr>
f0100a2f:	83 c4 10             	add    $0x10,%esp
f0100a32:	85 c0                	test   %eax,%eax
f0100a34:	74 6d                	je     f0100aa3 <monitor+0xc6>
			*buf++ = 0;
f0100a36:	c6 06 00             	movb   $0x0,(%esi)
f0100a39:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100a3c:	8d 76 01             	lea    0x1(%esi),%esi
f0100a3f:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f0100a42:	0f b6 06             	movzbl (%esi),%eax
f0100a45:	84 c0                	test   %al,%al
f0100a47:	75 d7                	jne    f0100a20 <monitor+0x43>
	argv[argc] = 0;
f0100a49:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f0100a50:	00 
	if (argc == 0)
f0100a51:	85 ff                	test   %edi,%edi
f0100a53:	0f 84 98 00 00 00    	je     f0100af1 <monitor+0x114>
f0100a59:	8d b3 18 1d 00 00    	lea    0x1d18(%ebx),%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a64:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f0100a67:	89 c7                	mov    %eax,%edi
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a69:	83 ec 08             	sub    $0x8,%esp
f0100a6c:	ff 36                	pushl  (%esi)
f0100a6e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a71:	e8 e5 0c 00 00       	call   f010175b <strcmp>
f0100a76:	83 c4 10             	add    $0x10,%esp
f0100a79:	85 c0                	test   %eax,%eax
f0100a7b:	0f 84 99 00 00 00    	je     f0100b1a <monitor+0x13d>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a81:	83 c7 01             	add    $0x1,%edi
f0100a84:	83 c6 0c             	add    $0xc,%esi
f0100a87:	83 ff 03             	cmp    $0x3,%edi
f0100a8a:	75 dd                	jne    f0100a69 <monitor+0x8c>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a8c:	83 ec 08             	sub    $0x8,%esp
f0100a8f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a92:	8d 83 dc fc fe ff    	lea    -0x10324(%ebx),%eax
f0100a98:	50                   	push   %eax
f0100a99:	e8 06 01 00 00       	call   f0100ba4 <cprintf>
	return 0;
f0100a9e:	83 c4 10             	add    $0x10,%esp
f0100aa1:	eb 4e                	jmp    f0100af1 <monitor+0x114>
		if (*buf == 0)
f0100aa3:	80 3e 00             	cmpb   $0x0,(%esi)
f0100aa6:	74 a1                	je     f0100a49 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f0100aa8:	83 ff 0f             	cmp    $0xf,%edi
f0100aab:	74 30                	je     f0100add <monitor+0x100>
		argv[argc++] = buf;
f0100aad:	8d 47 01             	lea    0x1(%edi),%eax
f0100ab0:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100ab3:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100ab7:	0f b6 06             	movzbl (%esi),%eax
f0100aba:	84 c0                	test   %al,%al
f0100abc:	74 81                	je     f0100a3f <monitor+0x62>
f0100abe:	83 ec 08             	sub    $0x8,%esp
f0100ac1:	0f be c0             	movsbl %al,%eax
f0100ac4:	50                   	push   %eax
f0100ac5:	ff 75 a0             	pushl  -0x60(%ebp)
f0100ac8:	e8 f4 0c 00 00       	call   f01017c1 <strchr>
f0100acd:	83 c4 10             	add    $0x10,%esp
f0100ad0:	85 c0                	test   %eax,%eax
f0100ad2:	0f 85 67 ff ff ff    	jne    f0100a3f <monitor+0x62>
			buf++;
f0100ad8:	83 c6 01             	add    $0x1,%esi
f0100adb:	eb da                	jmp    f0100ab7 <monitor+0xda>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100add:	83 ec 08             	sub    $0x8,%esp
f0100ae0:	6a 10                	push   $0x10
f0100ae2:	8d 83 bf fc fe ff    	lea    -0x10341(%ebx),%eax
f0100ae8:	50                   	push   %eax
f0100ae9:	e8 b6 00 00 00       	call   f0100ba4 <cprintf>
			return 0;
f0100aee:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100af1:	8d bb b6 fc fe ff    	lea    -0x1034a(%ebx),%edi
f0100af7:	83 ec 0c             	sub    $0xc,%esp
f0100afa:	57                   	push   %edi
f0100afb:	e8 50 0a 00 00       	call   f0101550 <readline>
		if (buf != NULL)
f0100b00:	83 c4 10             	add    $0x10,%esp
f0100b03:	85 c0                	test   %eax,%eax
f0100b05:	74 f0                	je     f0100af7 <monitor+0x11a>
f0100b07:	89 c6                	mov    %eax,%esi
	argv[argc] = 0;
f0100b09:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100b10:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b15:	e9 28 ff ff ff       	jmp    f0100a42 <monitor+0x65>
f0100b1a:	89 f8                	mov    %edi,%eax
f0100b1c:	8b 7d a4             	mov    -0x5c(%ebp),%edi
			return commands[i].func(argc, argv, tf);
f0100b1f:	83 ec 04             	sub    $0x4,%esp
f0100b22:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100b25:	ff 75 08             	pushl  0x8(%ebp)
f0100b28:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100b2b:	52                   	push   %edx
f0100b2c:	57                   	push   %edi
f0100b2d:	ff 94 83 20 1d 00 00 	call   *0x1d20(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100b34:	83 c4 10             	add    $0x10,%esp
f0100b37:	85 c0                	test   %eax,%eax
f0100b39:	79 b6                	jns    f0100af1 <monitor+0x114>
				break;
	}
}
f0100b3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100b3e:	5b                   	pop    %ebx
f0100b3f:	5e                   	pop    %esi
f0100b40:	5f                   	pop    %edi
f0100b41:	5d                   	pop    %ebp
f0100b42:	c3                   	ret    

f0100b43 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100b43:	f3 0f 1e fb          	endbr32 
f0100b47:	55                   	push   %ebp
f0100b48:	89 e5                	mov    %esp,%ebp
f0100b4a:	53                   	push   %ebx
f0100b4b:	83 ec 10             	sub    $0x10,%esp
f0100b4e:	e8 87 f6 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100b53:	81 c3 b5 17 01 00    	add    $0x117b5,%ebx
	cputchar(ch);
f0100b59:	ff 75 08             	pushl  0x8(%ebp)
f0100b5c:	e8 fa fb ff ff       	call   f010075b <cputchar>
	*cnt++;
}
f0100b61:	83 c4 10             	add    $0x10,%esp
f0100b64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b67:	c9                   	leave  
f0100b68:	c3                   	ret    

f0100b69 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100b69:	f3 0f 1e fb          	endbr32 
f0100b6d:	55                   	push   %ebp
f0100b6e:	89 e5                	mov    %esp,%ebp
f0100b70:	53                   	push   %ebx
f0100b71:	83 ec 14             	sub    $0x14,%esp
f0100b74:	e8 61 f6 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100b79:	81 c3 8f 17 01 00    	add    $0x1178f,%ebx
	int cnt = 0;
f0100b7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b86:	ff 75 0c             	pushl  0xc(%ebp)
f0100b89:	ff 75 08             	pushl  0x8(%ebp)
f0100b8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b8f:	50                   	push   %eax
f0100b90:	8d 83 3b e8 fe ff    	lea    -0x117c5(%ebx),%eax
f0100b96:	50                   	push   %eax
f0100b97:	e8 7a 04 00 00       	call   f0101016 <vprintfmt>
	return cnt;
}
f0100b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ba2:	c9                   	leave  
f0100ba3:	c3                   	ret    

f0100ba4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100ba4:	f3 0f 1e fb          	endbr32 
f0100ba8:	55                   	push   %ebp
f0100ba9:	89 e5                	mov    %esp,%ebp
f0100bab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100bae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100bb1:	50                   	push   %eax
f0100bb2:	ff 75 08             	pushl  0x8(%ebp)
f0100bb5:	e8 af ff ff ff       	call   f0100b69 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100bba:	c9                   	leave  
f0100bbb:	c3                   	ret    

f0100bbc <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100bbc:	55                   	push   %ebp
f0100bbd:	89 e5                	mov    %esp,%ebp
f0100bbf:	57                   	push   %edi
f0100bc0:	56                   	push   %esi
f0100bc1:	53                   	push   %ebx
f0100bc2:	83 ec 14             	sub    $0x14,%esp
f0100bc5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100bc8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100bcb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100bce:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100bd1:	8b 1a                	mov    (%edx),%ebx
f0100bd3:	8b 01                	mov    (%ecx),%eax
f0100bd5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bd8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100bdf:	eb 23                	jmp    f0100c04 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100be1:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100be4:	eb 1e                	jmp    f0100c04 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100be6:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100be9:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100bec:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100bf0:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bf3:	73 46                	jae    f0100c3b <stab_binsearch+0x7f>
			*region_left = m;
f0100bf5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100bf8:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100bfa:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100bfd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100c04:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100c07:	7f 5f                	jg     f0100c68 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c0c:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100c0f:	89 d0                	mov    %edx,%eax
f0100c11:	c1 e8 1f             	shr    $0x1f,%eax
f0100c14:	01 d0                	add    %edx,%eax
f0100c16:	89 c7                	mov    %eax,%edi
f0100c18:	d1 ff                	sar    %edi
f0100c1a:	83 e0 fe             	and    $0xfffffffe,%eax
f0100c1d:	01 f8                	add    %edi,%eax
f0100c1f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c22:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100c26:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100c28:	39 c3                	cmp    %eax,%ebx
f0100c2a:	7f b5                	jg     f0100be1 <stab_binsearch+0x25>
f0100c2c:	0f b6 0a             	movzbl (%edx),%ecx
f0100c2f:	83 ea 0c             	sub    $0xc,%edx
f0100c32:	39 f1                	cmp    %esi,%ecx
f0100c34:	74 b0                	je     f0100be6 <stab_binsearch+0x2a>
			m--;
f0100c36:	83 e8 01             	sub    $0x1,%eax
f0100c39:	eb ed                	jmp    f0100c28 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100c3b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c3e:	76 14                	jbe    f0100c54 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100c40:	83 e8 01             	sub    $0x1,%eax
f0100c43:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c46:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c49:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100c4b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c52:	eb b0                	jmp    f0100c04 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100c54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c57:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100c59:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100c5d:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100c5f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100c66:	eb 9c                	jmp    f0100c04 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100c68:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100c6c:	75 15                	jne    f0100c83 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100c6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c71:	8b 00                	mov    (%eax),%eax
f0100c73:	83 e8 01             	sub    $0x1,%eax
f0100c76:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c79:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100c7b:	83 c4 14             	add    $0x14,%esp
f0100c7e:	5b                   	pop    %ebx
f0100c7f:	5e                   	pop    %esi
f0100c80:	5f                   	pop    %edi
f0100c81:	5d                   	pop    %ebp
f0100c82:	c3                   	ret    
		for (l = *region_right;
f0100c83:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c86:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100c88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c8b:	8b 0f                	mov    (%edi),%ecx
f0100c8d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c90:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100c93:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100c97:	eb 03                	jmp    f0100c9c <stab_binsearch+0xe0>
		     l--)
f0100c99:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100c9c:	39 c1                	cmp    %eax,%ecx
f0100c9e:	7d 0a                	jge    f0100caa <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100ca0:	0f b6 1a             	movzbl (%edx),%ebx
f0100ca3:	83 ea 0c             	sub    $0xc,%edx
f0100ca6:	39 f3                	cmp    %esi,%ebx
f0100ca8:	75 ef                	jne    f0100c99 <stab_binsearch+0xdd>
		*region_left = l;
f0100caa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100cad:	89 07                	mov    %eax,(%edi)
}
f0100caf:	eb ca                	jmp    f0100c7b <stab_binsearch+0xbf>

f0100cb1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100cb1:	f3 0f 1e fb          	endbr32 
f0100cb5:	55                   	push   %ebp
f0100cb6:	89 e5                	mov    %esp,%ebp
f0100cb8:	57                   	push   %edi
f0100cb9:	56                   	push   %esi
f0100cba:	53                   	push   %ebx
f0100cbb:	83 ec 3c             	sub    $0x3c,%esp
f0100cbe:	e8 17 f5 ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0100cc3:	81 c3 45 16 01 00    	add    $0x11645,%ebx
f0100cc9:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100ccc:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100ccf:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100cd2:	8d 83 49 fe fe ff    	lea    -0x101b7(%ebx),%eax
f0100cd8:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100cda:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100ce1:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100ce4:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100ceb:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100cee:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100cf5:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100cfb:	0f 86 38 01 00 00    	jbe    f0100e39 <debuginfo_eip+0x188>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d01:	c7 c0 25 68 10 f0    	mov    $0xf0106825,%eax
f0100d07:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100d0d:	0f 86 da 01 00 00    	jbe    f0100eed <debuginfo_eip+0x23c>
f0100d13:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100d16:	c7 c0 d9 81 10 f0    	mov    $0xf01081d9,%eax
f0100d1c:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100d20:	0f 85 ce 01 00 00    	jne    f0100ef4 <debuginfo_eip+0x243>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100d26:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100d2d:	c7 c0 6c 23 10 f0    	mov    $0xf010236c,%eax
f0100d33:	c7 c2 24 68 10 f0    	mov    $0xf0106824,%edx
f0100d39:	29 c2                	sub    %eax,%edx
f0100d3b:	c1 fa 02             	sar    $0x2,%edx
f0100d3e:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100d44:	83 ea 01             	sub    $0x1,%edx
f0100d47:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100d4a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100d4d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100d50:	83 ec 08             	sub    $0x8,%esp
f0100d53:	57                   	push   %edi
f0100d54:	6a 64                	push   $0x64
f0100d56:	e8 61 fe ff ff       	call   f0100bbc <stab_binsearch>
	if (lfile == 0)
f0100d5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d5e:	83 c4 10             	add    $0x10,%esp
f0100d61:	85 c0                	test   %eax,%eax
f0100d63:	0f 84 92 01 00 00    	je     f0100efb <debuginfo_eip+0x24a>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d6f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100d72:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100d75:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d78:	83 ec 08             	sub    $0x8,%esp
f0100d7b:	57                   	push   %edi
f0100d7c:	6a 24                	push   $0x24
f0100d7e:	c7 c0 6c 23 10 f0    	mov    $0xf010236c,%eax
f0100d84:	e8 33 fe ff ff       	call   f0100bbc <stab_binsearch>

	if (lfun <= rfun) {
f0100d89:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d8c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100d8f:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0100d92:	83 c4 10             	add    $0x10,%esp
f0100d95:	39 c8                	cmp    %ecx,%eax
f0100d97:	0f 8f b7 00 00 00    	jg     f0100e54 <debuginfo_eip+0x1a3>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d9d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100da0:	c7 c1 6c 23 10 f0    	mov    $0xf010236c,%ecx
f0100da6:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100da9:	8b 11                	mov    (%ecx),%edx
f0100dab:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0100dae:	c7 c2 d9 81 10 f0    	mov    $0xf01081d9,%edx
f0100db4:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0100db7:	81 ea 25 68 10 f0    	sub    $0xf0106825,%edx
f0100dbd:	8b 5d bc             	mov    -0x44(%ebp),%ebx
f0100dc0:	39 d3                	cmp    %edx,%ebx
f0100dc2:	73 0c                	jae    f0100dd0 <debuginfo_eip+0x11f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100dc4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0100dc7:	81 c3 25 68 10 f0    	add    $0xf0106825,%ebx
f0100dcd:	89 5e 08             	mov    %ebx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100dd0:	8b 51 08             	mov    0x8(%ecx),%edx
f0100dd3:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100dd6:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100dd8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100ddb:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100dde:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100de1:	83 ec 08             	sub    $0x8,%esp
f0100de4:	6a 3a                	push   $0x3a
f0100de6:	ff 76 08             	pushl  0x8(%esi)
f0100de9:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100dec:	e8 f5 09 00 00       	call   f01017e6 <strfind>
f0100df1:	2b 46 08             	sub    0x8(%esi),%eax
f0100df4:	89 46 0c             	mov    %eax,0xc(%esi)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100df7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100dfa:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100dfd:	83 c4 08             	add    $0x8,%esp
f0100e00:	57                   	push   %edi
f0100e01:	6a 44                	push   $0x44
f0100e03:	c7 c0 6c 23 10 f0    	mov    $0xf010236c,%eax
f0100e09:	e8 ae fd ff ff       	call   f0100bbc <stab_binsearch>
	if (lline <= rline) {
f0100e0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100e11:	83 c4 10             	add    $0x10,%esp
f0100e14:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0100e17:	0f 8f e5 00 00 00    	jg     f0100f02 <debuginfo_eip+0x251>
		info->eip_line = stabs[lline].n_desc;
f0100e1d:	89 c2                	mov    %eax,%edx
f0100e1f:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100e22:	c7 c0 6c 23 10 f0    	mov    $0xf010236c,%eax
f0100e28:	0f b7 5c 88 06       	movzwl 0x6(%eax,%ecx,4),%ebx
f0100e2d:	89 5e 04             	mov    %ebx,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e30:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e33:	8d 44 88 04          	lea    0x4(%eax,%ecx,4),%eax
f0100e37:	eb 35                	jmp    f0100e6e <debuginfo_eip+0x1bd>
  	        panic("User address");
f0100e39:	83 ec 04             	sub    $0x4,%esp
f0100e3c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e3f:	8d 83 53 fe fe ff    	lea    -0x101ad(%ebx),%eax
f0100e45:	50                   	push   %eax
f0100e46:	6a 7f                	push   $0x7f
f0100e48:	8d 83 60 fe fe ff    	lea    -0x101a0(%ebx),%eax
f0100e4e:	50                   	push   %eax
f0100e4f:	e8 c8 f2 ff ff       	call   f010011c <_panic>
		info->eip_fn_addr = addr;
f0100e54:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100e57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e5a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100e5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e60:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100e63:	e9 79 ff ff ff       	jmp    f0100de1 <debuginfo_eip+0x130>
f0100e68:	83 ea 01             	sub    $0x1,%edx
f0100e6b:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100e6e:	39 d7                	cmp    %edx,%edi
f0100e70:	7f 3a                	jg     f0100eac <debuginfo_eip+0x1fb>
	       && stabs[lline].n_type != N_SOL
f0100e72:	0f b6 08             	movzbl (%eax),%ecx
f0100e75:	80 f9 84             	cmp    $0x84,%cl
f0100e78:	74 0b                	je     f0100e85 <debuginfo_eip+0x1d4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e7a:	80 f9 64             	cmp    $0x64,%cl
f0100e7d:	75 e9                	jne    f0100e68 <debuginfo_eip+0x1b7>
f0100e7f:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100e83:	74 e3                	je     f0100e68 <debuginfo_eip+0x1b7>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e85:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100e88:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100e8b:	c7 c0 6c 23 10 f0    	mov    $0xf010236c,%eax
f0100e91:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e94:	c7 c0 d9 81 10 f0    	mov    $0xf01081d9,%eax
f0100e9a:	81 e8 25 68 10 f0    	sub    $0xf0106825,%eax
f0100ea0:	39 c2                	cmp    %eax,%edx
f0100ea2:	73 08                	jae    f0100eac <debuginfo_eip+0x1fb>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100ea4:	81 c2 25 68 10 f0    	add    $0xf0106825,%edx
f0100eaa:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100eac:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100eaf:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100eb2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100eb7:	39 da                	cmp    %ebx,%edx
f0100eb9:	7d 53                	jge    f0100f0e <debuginfo_eip+0x25d>
		for (lline = lfun + 1;
f0100ebb:	8d 42 01             	lea    0x1(%edx),%eax
f0100ebe:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100ec1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100ec4:	c7 c2 6c 23 10 f0    	mov    $0xf010236c,%edx
f0100eca:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100ece:	eb 04                	jmp    f0100ed4 <debuginfo_eip+0x223>
			info->eip_fn_narg++;
f0100ed0:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100ed4:	39 c3                	cmp    %eax,%ebx
f0100ed6:	7e 31                	jle    f0100f09 <debuginfo_eip+0x258>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ed8:	0f b6 0a             	movzbl (%edx),%ecx
f0100edb:	83 c0 01             	add    $0x1,%eax
f0100ede:	83 c2 0c             	add    $0xc,%edx
f0100ee1:	80 f9 a0             	cmp    $0xa0,%cl
f0100ee4:	74 ea                	je     f0100ed0 <debuginfo_eip+0x21f>
	return 0;
f0100ee6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eeb:	eb 21                	jmp    f0100f0e <debuginfo_eip+0x25d>
		return -1;
f0100eed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ef2:	eb 1a                	jmp    f0100f0e <debuginfo_eip+0x25d>
f0100ef4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ef9:	eb 13                	jmp    f0100f0e <debuginfo_eip+0x25d>
		return -1;
f0100efb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f00:	eb 0c                	jmp    f0100f0e <debuginfo_eip+0x25d>
		return -1;
f0100f02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f07:	eb 05                	jmp    f0100f0e <debuginfo_eip+0x25d>
	return 0;
f0100f09:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f11:	5b                   	pop    %ebx
f0100f12:	5e                   	pop    %esi
f0100f13:	5f                   	pop    %edi
f0100f14:	5d                   	pop    %ebp
f0100f15:	c3                   	ret    

f0100f16 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f16:	55                   	push   %ebp
f0100f17:	89 e5                	mov    %esp,%ebp
f0100f19:	57                   	push   %edi
f0100f1a:	56                   	push   %esi
f0100f1b:	53                   	push   %ebx
f0100f1c:	83 ec 2c             	sub    $0x2c,%esp
f0100f1f:	e8 28 06 00 00       	call   f010154c <__x86.get_pc_thunk.cx>
f0100f24:	81 c1 e4 13 01 00    	add    $0x113e4,%ecx
f0100f2a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f2d:	89 c7                	mov    %eax,%edi
f0100f2f:	89 d6                	mov    %edx,%esi
f0100f31:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f34:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f37:	89 d1                	mov    %edx,%ecx
f0100f39:	89 c2                	mov    %eax,%edx
f0100f3b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f3e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100f41:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f44:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f47:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f4a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100f51:	39 c2                	cmp    %eax,%edx
f0100f53:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100f56:	72 41                	jb     f0100f99 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f58:	83 ec 0c             	sub    $0xc,%esp
f0100f5b:	ff 75 18             	pushl  0x18(%ebp)
f0100f5e:	83 eb 01             	sub    $0x1,%ebx
f0100f61:	53                   	push   %ebx
f0100f62:	50                   	push   %eax
f0100f63:	83 ec 08             	sub    $0x8,%esp
f0100f66:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f69:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f6c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f6f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f72:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f75:	e8 96 0a 00 00       	call   f0101a10 <__udivdi3>
f0100f7a:	83 c4 18             	add    $0x18,%esp
f0100f7d:	52                   	push   %edx
f0100f7e:	50                   	push   %eax
f0100f7f:	89 f2                	mov    %esi,%edx
f0100f81:	89 f8                	mov    %edi,%eax
f0100f83:	e8 8e ff ff ff       	call   f0100f16 <printnum>
f0100f88:	83 c4 20             	add    $0x20,%esp
f0100f8b:	eb 13                	jmp    f0100fa0 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f8d:	83 ec 08             	sub    $0x8,%esp
f0100f90:	56                   	push   %esi
f0100f91:	ff 75 18             	pushl  0x18(%ebp)
f0100f94:	ff d7                	call   *%edi
f0100f96:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f99:	83 eb 01             	sub    $0x1,%ebx
f0100f9c:	85 db                	test   %ebx,%ebx
f0100f9e:	7f ed                	jg     f0100f8d <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100fa0:	83 ec 08             	sub    $0x8,%esp
f0100fa3:	56                   	push   %esi
f0100fa4:	83 ec 04             	sub    $0x4,%esp
f0100fa7:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100faa:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fad:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100fb0:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fb3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100fb6:	e8 65 0b 00 00       	call   f0101b20 <__umoddi3>
f0100fbb:	83 c4 14             	add    $0x14,%esp
f0100fbe:	0f be 84 03 6e fe fe 	movsbl -0x10192(%ebx,%eax,1),%eax
f0100fc5:	ff 
f0100fc6:	50                   	push   %eax
f0100fc7:	ff d7                	call   *%edi
}
f0100fc9:	83 c4 10             	add    $0x10,%esp
f0100fcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fcf:	5b                   	pop    %ebx
f0100fd0:	5e                   	pop    %esi
f0100fd1:	5f                   	pop    %edi
f0100fd2:	5d                   	pop    %ebp
f0100fd3:	c3                   	ret    

f0100fd4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100fd4:	f3 0f 1e fb          	endbr32 
f0100fd8:	55                   	push   %ebp
f0100fd9:	89 e5                	mov    %esp,%ebp
f0100fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100fde:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100fe2:	8b 10                	mov    (%eax),%edx
f0100fe4:	3b 50 04             	cmp    0x4(%eax),%edx
f0100fe7:	73 0a                	jae    f0100ff3 <sprintputch+0x1f>
		*b->buf++ = ch;
f0100fe9:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100fec:	89 08                	mov    %ecx,(%eax)
f0100fee:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ff1:	88 02                	mov    %al,(%edx)
}
f0100ff3:	5d                   	pop    %ebp
f0100ff4:	c3                   	ret    

f0100ff5 <printfmt>:
{
f0100ff5:	f3 0f 1e fb          	endbr32 
f0100ff9:	55                   	push   %ebp
f0100ffa:	89 e5                	mov    %esp,%ebp
f0100ffc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100fff:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101002:	50                   	push   %eax
f0101003:	ff 75 10             	pushl  0x10(%ebp)
f0101006:	ff 75 0c             	pushl  0xc(%ebp)
f0101009:	ff 75 08             	pushl  0x8(%ebp)
f010100c:	e8 05 00 00 00       	call   f0101016 <vprintfmt>
}
f0101011:	83 c4 10             	add    $0x10,%esp
f0101014:	c9                   	leave  
f0101015:	c3                   	ret    

f0101016 <vprintfmt>:
{
f0101016:	f3 0f 1e fb          	endbr32 
f010101a:	55                   	push   %ebp
f010101b:	89 e5                	mov    %esp,%ebp
f010101d:	57                   	push   %edi
f010101e:	56                   	push   %esi
f010101f:	53                   	push   %ebx
f0101020:	83 ec 3c             	sub    $0x3c,%esp
f0101023:	e8 66 f7 ff ff       	call   f010078e <__x86.get_pc_thunk.ax>
f0101028:	05 e0 12 01 00       	add    $0x112e0,%eax
f010102d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101030:	8b 75 08             	mov    0x8(%ebp),%esi
f0101033:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101036:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101039:	8d 80 3c 1d 00 00    	lea    0x1d3c(%eax),%eax
f010103f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101042:	e9 cd 03 00 00       	jmp    f0101414 <.L25+0x48>
		padc = ' ';
f0101047:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f010104b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0101052:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0101059:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
f0101060:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101065:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101068:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010106b:	8d 43 01             	lea    0x1(%ebx),%eax
f010106e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101071:	0f b6 13             	movzbl (%ebx),%edx
f0101074:	8d 42 dd             	lea    -0x23(%edx),%eax
f0101077:	3c 55                	cmp    $0x55,%al
f0101079:	0f 87 21 04 00 00    	ja     f01014a0 <.L20>
f010107f:	0f b6 c0             	movzbl %al,%eax
f0101082:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101085:	89 ce                	mov    %ecx,%esi
f0101087:	03 b4 81 fc fe fe ff 	add    -0x10104(%ecx,%eax,4),%esi
f010108e:	3e ff e6             	notrack jmp *%esi

f0101091 <.L68>:
f0101091:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f0101094:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0101098:	eb d1                	jmp    f010106b <vprintfmt+0x55>

f010109a <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f010109a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010109d:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01010a1:	eb c8                	jmp    f010106b <vprintfmt+0x55>

f01010a3 <.L31>:
f01010a3:	0f b6 d2             	movzbl %dl,%edx
f01010a6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01010a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ae:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01010b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01010b4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01010b8:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01010bb:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01010be:	83 f9 09             	cmp    $0x9,%ecx
f01010c1:	77 58                	ja     f010111b <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01010c3:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01010c6:	eb e9                	jmp    f01010b1 <.L31+0xe>

f01010c8 <.L34>:
			precision = va_arg(ap, int);
f01010c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01010cb:	8b 00                	mov    (%eax),%eax
f01010cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d3:	8d 40 04             	lea    0x4(%eax),%eax
f01010d6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01010dc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01010e0:	79 89                	jns    f010106b <vprintfmt+0x55>
				width = precision, precision = -1;
f01010e2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010e8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01010ef:	e9 77 ff ff ff       	jmp    f010106b <vprintfmt+0x55>

f01010f4 <.L33>:
f01010f4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01010f7:	85 c0                	test   %eax,%eax
f01010f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01010fe:	0f 49 d0             	cmovns %eax,%edx
f0101101:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101104:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101107:	e9 5f ff ff ff       	jmp    f010106b <vprintfmt+0x55>

f010110c <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f010110c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010110f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f0101116:	e9 50 ff ff ff       	jmp    f010106b <vprintfmt+0x55>
f010111b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010111e:	89 75 08             	mov    %esi,0x8(%ebp)
f0101121:	eb b9                	jmp    f01010dc <.L34+0x14>

f0101123 <.L27>:
			lflag++;
f0101123:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101127:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010112a:	e9 3c ff ff ff       	jmp    f010106b <vprintfmt+0x55>

f010112f <.L30>:
f010112f:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0101132:	8b 45 14             	mov    0x14(%ebp),%eax
f0101135:	8d 58 04             	lea    0x4(%eax),%ebx
f0101138:	83 ec 08             	sub    $0x8,%esp
f010113b:	57                   	push   %edi
f010113c:	ff 30                	pushl  (%eax)
f010113e:	ff d6                	call   *%esi
			break;
f0101140:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101143:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0101146:	e9 c6 02 00 00       	jmp    f0101411 <.L25+0x45>

f010114b <.L28>:
f010114b:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f010114e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101151:	8d 58 04             	lea    0x4(%eax),%ebx
f0101154:	8b 00                	mov    (%eax),%eax
f0101156:	99                   	cltd   
f0101157:	31 d0                	xor    %edx,%eax
f0101159:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010115b:	83 f8 06             	cmp    $0x6,%eax
f010115e:	7f 27                	jg     f0101187 <.L28+0x3c>
f0101160:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101163:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101166:	85 d2                	test   %edx,%edx
f0101168:	74 1d                	je     f0101187 <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f010116a:	52                   	push   %edx
f010116b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010116e:	8d 80 8f fe fe ff    	lea    -0x10171(%eax),%eax
f0101174:	50                   	push   %eax
f0101175:	57                   	push   %edi
f0101176:	56                   	push   %esi
f0101177:	e8 79 fe ff ff       	call   f0100ff5 <printfmt>
f010117c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010117f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0101182:	e9 8a 02 00 00       	jmp    f0101411 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0101187:	50                   	push   %eax
f0101188:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010118b:	8d 80 86 fe fe ff    	lea    -0x1017a(%eax),%eax
f0101191:	50                   	push   %eax
f0101192:	57                   	push   %edi
f0101193:	56                   	push   %esi
f0101194:	e8 5c fe ff ff       	call   f0100ff5 <printfmt>
f0101199:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010119c:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010119f:	e9 6d 02 00 00       	jmp    f0101411 <.L25+0x45>

f01011a4 <.L24>:
f01011a4:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f01011a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01011aa:	83 c0 04             	add    $0x4,%eax
f01011ad:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01011b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01011b3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01011b5:	85 d2                	test   %edx,%edx
f01011b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011ba:	8d 80 7f fe fe ff    	lea    -0x10181(%eax),%eax
f01011c0:	0f 45 c2             	cmovne %edx,%eax
f01011c3:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01011c6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01011ca:	7e 06                	jle    f01011d2 <.L24+0x2e>
f01011cc:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01011d0:	75 0d                	jne    f01011df <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01011d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01011d5:	89 c3                	mov    %eax,%ebx
f01011d7:	03 45 d4             	add    -0x2c(%ebp),%eax
f01011da:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01011dd:	eb 58                	jmp    f0101237 <.L24+0x93>
f01011df:	83 ec 08             	sub    $0x8,%esp
f01011e2:	ff 75 d8             	pushl  -0x28(%ebp)
f01011e5:	ff 75 c8             	pushl  -0x38(%ebp)
f01011e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01011eb:	e8 85 04 00 00       	call   f0101675 <strnlen>
f01011f0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01011f3:	29 c2                	sub    %eax,%edx
f01011f5:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01011f8:	83 c4 10             	add    $0x10,%esp
f01011fb:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01011fd:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101201:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101204:	85 db                	test   %ebx,%ebx
f0101206:	7e 11                	jle    f0101219 <.L24+0x75>
					putch(padc, putdat);
f0101208:	83 ec 08             	sub    $0x8,%esp
f010120b:	57                   	push   %edi
f010120c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010120f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101211:	83 eb 01             	sub    $0x1,%ebx
f0101214:	83 c4 10             	add    $0x10,%esp
f0101217:	eb eb                	jmp    f0101204 <.L24+0x60>
f0101219:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010121c:	85 d2                	test   %edx,%edx
f010121e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101223:	0f 49 c2             	cmovns %edx,%eax
f0101226:	29 c2                	sub    %eax,%edx
f0101228:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010122b:	eb a5                	jmp    f01011d2 <.L24+0x2e>
					putch(ch, putdat);
f010122d:	83 ec 08             	sub    $0x8,%esp
f0101230:	57                   	push   %edi
f0101231:	52                   	push   %edx
f0101232:	ff d6                	call   *%esi
f0101234:	83 c4 10             	add    $0x10,%esp
f0101237:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010123a:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010123c:	83 c3 01             	add    $0x1,%ebx
f010123f:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101243:	0f be d0             	movsbl %al,%edx
f0101246:	85 d2                	test   %edx,%edx
f0101248:	74 4b                	je     f0101295 <.L24+0xf1>
f010124a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010124e:	78 06                	js     f0101256 <.L24+0xb2>
f0101250:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101254:	78 1e                	js     f0101274 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101256:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f010125a:	74 d1                	je     f010122d <.L24+0x89>
f010125c:	0f be c0             	movsbl %al,%eax
f010125f:	83 e8 20             	sub    $0x20,%eax
f0101262:	83 f8 5e             	cmp    $0x5e,%eax
f0101265:	76 c6                	jbe    f010122d <.L24+0x89>
					putch('?', putdat);
f0101267:	83 ec 08             	sub    $0x8,%esp
f010126a:	57                   	push   %edi
f010126b:	6a 3f                	push   $0x3f
f010126d:	ff d6                	call   *%esi
f010126f:	83 c4 10             	add    $0x10,%esp
f0101272:	eb c3                	jmp    f0101237 <.L24+0x93>
f0101274:	89 cb                	mov    %ecx,%ebx
f0101276:	eb 0e                	jmp    f0101286 <.L24+0xe2>
				putch(' ', putdat);
f0101278:	83 ec 08             	sub    $0x8,%esp
f010127b:	57                   	push   %edi
f010127c:	6a 20                	push   $0x20
f010127e:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0101280:	83 eb 01             	sub    $0x1,%ebx
f0101283:	83 c4 10             	add    $0x10,%esp
f0101286:	85 db                	test   %ebx,%ebx
f0101288:	7f ee                	jg     f0101278 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f010128a:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010128d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101290:	e9 7c 01 00 00       	jmp    f0101411 <.L25+0x45>
f0101295:	89 cb                	mov    %ecx,%ebx
f0101297:	eb ed                	jmp    f0101286 <.L24+0xe2>

f0101299 <.L29>:
f0101299:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010129c:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010129f:	83 f9 01             	cmp    $0x1,%ecx
f01012a2:	7f 1b                	jg     f01012bf <.L29+0x26>
	else if (lflag)
f01012a4:	85 c9                	test   %ecx,%ecx
f01012a6:	74 63                	je     f010130b <.L29+0x72>
		return va_arg(*ap, long);
f01012a8:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ab:	8b 00                	mov    (%eax),%eax
f01012ad:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012b0:	99                   	cltd   
f01012b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012b4:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b7:	8d 40 04             	lea    0x4(%eax),%eax
f01012ba:	89 45 14             	mov    %eax,0x14(%ebp)
f01012bd:	eb 17                	jmp    f01012d6 <.L29+0x3d>
		return va_arg(*ap, long long);
f01012bf:	8b 45 14             	mov    0x14(%ebp),%eax
f01012c2:	8b 50 04             	mov    0x4(%eax),%edx
f01012c5:	8b 00                	mov    (%eax),%eax
f01012c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012cd:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d0:	8d 40 08             	lea    0x8(%eax),%eax
f01012d3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01012d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012d9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01012dc:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01012e1:	85 c9                	test   %ecx,%ecx
f01012e3:	0f 89 0e 01 00 00    	jns    f01013f7 <.L25+0x2b>
				putch('-', putdat);
f01012e9:	83 ec 08             	sub    $0x8,%esp
f01012ec:	57                   	push   %edi
f01012ed:	6a 2d                	push   $0x2d
f01012ef:	ff d6                	call   *%esi
				num = -(long long) num;
f01012f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01012f7:	f7 da                	neg    %edx
f01012f9:	83 d1 00             	adc    $0x0,%ecx
f01012fc:	f7 d9                	neg    %ecx
f01012fe:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101301:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101306:	e9 ec 00 00 00       	jmp    f01013f7 <.L25+0x2b>
		return va_arg(*ap, int);
f010130b:	8b 45 14             	mov    0x14(%ebp),%eax
f010130e:	8b 00                	mov    (%eax),%eax
f0101310:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101313:	99                   	cltd   
f0101314:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101317:	8b 45 14             	mov    0x14(%ebp),%eax
f010131a:	8d 40 04             	lea    0x4(%eax),%eax
f010131d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101320:	eb b4                	jmp    f01012d6 <.L29+0x3d>

f0101322 <.L23>:
f0101322:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101325:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101328:	83 f9 01             	cmp    $0x1,%ecx
f010132b:	7f 1e                	jg     f010134b <.L23+0x29>
	else if (lflag)
f010132d:	85 c9                	test   %ecx,%ecx
f010132f:	74 32                	je     f0101363 <.L23+0x41>
		return va_arg(*ap, unsigned long);
f0101331:	8b 45 14             	mov    0x14(%ebp),%eax
f0101334:	8b 10                	mov    (%eax),%edx
f0101336:	b9 00 00 00 00       	mov    $0x0,%ecx
f010133b:	8d 40 04             	lea    0x4(%eax),%eax
f010133e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101341:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0101346:	e9 ac 00 00 00       	jmp    f01013f7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010134b:	8b 45 14             	mov    0x14(%ebp),%eax
f010134e:	8b 10                	mov    (%eax),%edx
f0101350:	8b 48 04             	mov    0x4(%eax),%ecx
f0101353:	8d 40 08             	lea    0x8(%eax),%eax
f0101356:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101359:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f010135e:	e9 94 00 00 00       	jmp    f01013f7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101363:	8b 45 14             	mov    0x14(%ebp),%eax
f0101366:	8b 10                	mov    (%eax),%edx
f0101368:	b9 00 00 00 00       	mov    $0x0,%ecx
f010136d:	8d 40 04             	lea    0x4(%eax),%eax
f0101370:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101373:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0101378:	eb 7d                	jmp    f01013f7 <.L25+0x2b>

f010137a <.L26>:
f010137a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010137d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101380:	83 f9 01             	cmp    $0x1,%ecx
f0101383:	7f 1b                	jg     f01013a0 <.L26+0x26>
	else if (lflag)
f0101385:	85 c9                	test   %ecx,%ecx
f0101387:	74 2c                	je     f01013b5 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
f0101389:	8b 45 14             	mov    0x14(%ebp),%eax
f010138c:	8b 10                	mov    (%eax),%edx
f010138e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101393:	8d 40 04             	lea    0x4(%eax),%eax
f0101396:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101399:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f010139e:	eb 57                	jmp    f01013f7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f01013a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01013a3:	8b 10                	mov    (%eax),%edx
f01013a5:	8b 48 04             	mov    0x4(%eax),%ecx
f01013a8:	8d 40 08             	lea    0x8(%eax),%eax
f01013ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01013ae:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f01013b3:	eb 42                	jmp    f01013f7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f01013b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01013b8:	8b 10                	mov    (%eax),%edx
f01013ba:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013bf:	8d 40 04             	lea    0x4(%eax),%eax
f01013c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01013c5:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f01013ca:	eb 2b                	jmp    f01013f7 <.L25+0x2b>

f01013cc <.L25>:
f01013cc:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f01013cf:	83 ec 08             	sub    $0x8,%esp
f01013d2:	57                   	push   %edi
f01013d3:	6a 30                	push   $0x30
f01013d5:	ff d6                	call   *%esi
			putch('x', putdat);
f01013d7:	83 c4 08             	add    $0x8,%esp
f01013da:	57                   	push   %edi
f01013db:	6a 78                	push   $0x78
f01013dd:	ff d6                	call   *%esi
			num = (unsigned long long)
f01013df:	8b 45 14             	mov    0x14(%ebp),%eax
f01013e2:	8b 10                	mov    (%eax),%edx
f01013e4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01013e9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01013ec:	8d 40 04             	lea    0x4(%eax),%eax
f01013ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013f2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01013f7:	83 ec 0c             	sub    $0xc,%esp
f01013fa:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f01013fe:	53                   	push   %ebx
f01013ff:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101402:	50                   	push   %eax
f0101403:	51                   	push   %ecx
f0101404:	52                   	push   %edx
f0101405:	89 fa                	mov    %edi,%edx
f0101407:	89 f0                	mov    %esi,%eax
f0101409:	e8 08 fb ff ff       	call   f0100f16 <printnum>
			break;
f010140e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0101411:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101414:	83 c3 01             	add    $0x1,%ebx
f0101417:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f010141b:	83 f8 25             	cmp    $0x25,%eax
f010141e:	0f 84 23 fc ff ff    	je     f0101047 <vprintfmt+0x31>
			if (ch == '\0')
f0101424:	85 c0                	test   %eax,%eax
f0101426:	0f 84 97 00 00 00    	je     f01014c3 <.L20+0x23>
			putch(ch, putdat);
f010142c:	83 ec 08             	sub    $0x8,%esp
f010142f:	57                   	push   %edi
f0101430:	50                   	push   %eax
f0101431:	ff d6                	call   *%esi
f0101433:	83 c4 10             	add    $0x10,%esp
f0101436:	eb dc                	jmp    f0101414 <.L25+0x48>

f0101438 <.L21>:
f0101438:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010143b:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f010143e:	83 f9 01             	cmp    $0x1,%ecx
f0101441:	7f 1b                	jg     f010145e <.L21+0x26>
	else if (lflag)
f0101443:	85 c9                	test   %ecx,%ecx
f0101445:	74 2c                	je     f0101473 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0101447:	8b 45 14             	mov    0x14(%ebp),%eax
f010144a:	8b 10                	mov    (%eax),%edx
f010144c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101451:	8d 40 04             	lea    0x4(%eax),%eax
f0101454:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101457:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f010145c:	eb 99                	jmp    f01013f7 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f010145e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101461:	8b 10                	mov    (%eax),%edx
f0101463:	8b 48 04             	mov    0x4(%eax),%ecx
f0101466:	8d 40 08             	lea    0x8(%eax),%eax
f0101469:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010146c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0101471:	eb 84                	jmp    f01013f7 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0101473:	8b 45 14             	mov    0x14(%ebp),%eax
f0101476:	8b 10                	mov    (%eax),%edx
f0101478:	b9 00 00 00 00       	mov    $0x0,%ecx
f010147d:	8d 40 04             	lea    0x4(%eax),%eax
f0101480:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101483:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0101488:	e9 6a ff ff ff       	jmp    f01013f7 <.L25+0x2b>

f010148d <.L35>:
f010148d:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f0101490:	83 ec 08             	sub    $0x8,%esp
f0101493:	57                   	push   %edi
f0101494:	6a 25                	push   $0x25
f0101496:	ff d6                	call   *%esi
			break;
f0101498:	83 c4 10             	add    $0x10,%esp
f010149b:	e9 71 ff ff ff       	jmp    f0101411 <.L25+0x45>

f01014a0 <.L20>:
f01014a0:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f01014a3:	83 ec 08             	sub    $0x8,%esp
f01014a6:	57                   	push   %edi
f01014a7:	6a 25                	push   $0x25
f01014a9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01014ab:	83 c4 10             	add    $0x10,%esp
f01014ae:	89 d8                	mov    %ebx,%eax
f01014b0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f01014b4:	74 05                	je     f01014bb <.L20+0x1b>
f01014b6:	83 e8 01             	sub    $0x1,%eax
f01014b9:	eb f5                	jmp    f01014b0 <.L20+0x10>
f01014bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014be:	e9 4e ff ff ff       	jmp    f0101411 <.L25+0x45>
}
f01014c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014c6:	5b                   	pop    %ebx
f01014c7:	5e                   	pop    %esi
f01014c8:	5f                   	pop    %edi
f01014c9:	5d                   	pop    %ebp
f01014ca:	c3                   	ret    

f01014cb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01014cb:	f3 0f 1e fb          	endbr32 
f01014cf:	55                   	push   %ebp
f01014d0:	89 e5                	mov    %esp,%ebp
f01014d2:	53                   	push   %ebx
f01014d3:	83 ec 14             	sub    $0x14,%esp
f01014d6:	e8 ff ec ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f01014db:	81 c3 2d 0e 01 00    	add    $0x10e2d,%ebx
f01014e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01014e4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01014e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014ea:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01014ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01014f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01014f8:	85 c0                	test   %eax,%eax
f01014fa:	74 2b                	je     f0101527 <vsnprintf+0x5c>
f01014fc:	85 d2                	test   %edx,%edx
f01014fe:	7e 27                	jle    f0101527 <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101500:	ff 75 14             	pushl  0x14(%ebp)
f0101503:	ff 75 10             	pushl  0x10(%ebp)
f0101506:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101509:	50                   	push   %eax
f010150a:	8d 83 cc ec fe ff    	lea    -0x11334(%ebx),%eax
f0101510:	50                   	push   %eax
f0101511:	e8 00 fb ff ff       	call   f0101016 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101516:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101519:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010151c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010151f:	83 c4 10             	add    $0x10,%esp
}
f0101522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101525:	c9                   	leave  
f0101526:	c3                   	ret    
		return -E_INVAL;
f0101527:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010152c:	eb f4                	jmp    f0101522 <vsnprintf+0x57>

f010152e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010152e:	f3 0f 1e fb          	endbr32 
f0101532:	55                   	push   %ebp
f0101533:	89 e5                	mov    %esp,%ebp
f0101535:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101538:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010153b:	50                   	push   %eax
f010153c:	ff 75 10             	pushl  0x10(%ebp)
f010153f:	ff 75 0c             	pushl  0xc(%ebp)
f0101542:	ff 75 08             	pushl  0x8(%ebp)
f0101545:	e8 81 ff ff ff       	call   f01014cb <vsnprintf>
	va_end(ap);

	return rc;
}
f010154a:	c9                   	leave  
f010154b:	c3                   	ret    

f010154c <__x86.get_pc_thunk.cx>:
f010154c:	8b 0c 24             	mov    (%esp),%ecx
f010154f:	c3                   	ret    

f0101550 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101550:	f3 0f 1e fb          	endbr32 
f0101554:	55                   	push   %ebp
f0101555:	89 e5                	mov    %esp,%ebp
f0101557:	57                   	push   %edi
f0101558:	56                   	push   %esi
f0101559:	53                   	push   %ebx
f010155a:	83 ec 1c             	sub    $0x1c,%esp
f010155d:	e8 78 ec ff ff       	call   f01001da <__x86.get_pc_thunk.bx>
f0101562:	81 c3 a6 0d 01 00    	add    $0x10da6,%ebx
f0101568:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010156b:	85 c0                	test   %eax,%eax
f010156d:	74 13                	je     f0101582 <readline+0x32>
		cprintf("%s", prompt);
f010156f:	83 ec 08             	sub    $0x8,%esp
f0101572:	50                   	push   %eax
f0101573:	8d 83 8f fe fe ff    	lea    -0x10171(%ebx),%eax
f0101579:	50                   	push   %eax
f010157a:	e8 25 f6 ff ff       	call   f0100ba4 <cprintf>
f010157f:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101582:	83 ec 0c             	sub    $0xc,%esp
f0101585:	6a 00                	push   $0x0
f0101587:	e8 f8 f1 ff ff       	call   f0100784 <iscons>
f010158c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010158f:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101592:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0101597:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f010159d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01015a0:	eb 51                	jmp    f01015f3 <readline+0xa3>
			cprintf("read error: %e\n", c);
f01015a2:	83 ec 08             	sub    $0x8,%esp
f01015a5:	50                   	push   %eax
f01015a6:	8d 83 54 00 ff ff    	lea    -0xffac(%ebx),%eax
f01015ac:	50                   	push   %eax
f01015ad:	e8 f2 f5 ff ff       	call   f0100ba4 <cprintf>
			return NULL;
f01015b2:	83 c4 10             	add    $0x10,%esp
f01015b5:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01015ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015bd:	5b                   	pop    %ebx
f01015be:	5e                   	pop    %esi
f01015bf:	5f                   	pop    %edi
f01015c0:	5d                   	pop    %ebp
f01015c1:	c3                   	ret    
			if (echoing)
f01015c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015c6:	75 05                	jne    f01015cd <readline+0x7d>
			i--;
f01015c8:	83 ef 01             	sub    $0x1,%edi
f01015cb:	eb 26                	jmp    f01015f3 <readline+0xa3>
				cputchar('\b');
f01015cd:	83 ec 0c             	sub    $0xc,%esp
f01015d0:	6a 08                	push   $0x8
f01015d2:	e8 84 f1 ff ff       	call   f010075b <cputchar>
f01015d7:	83 c4 10             	add    $0x10,%esp
f01015da:	eb ec                	jmp    f01015c8 <readline+0x78>
				cputchar(c);
f01015dc:	83 ec 0c             	sub    $0xc,%esp
f01015df:	56                   	push   %esi
f01015e0:	e8 76 f1 ff ff       	call   f010075b <cputchar>
f01015e5:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01015e8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01015eb:	89 f0                	mov    %esi,%eax
f01015ed:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01015f0:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01015f3:	e8 77 f1 ff ff       	call   f010076f <getchar>
f01015f8:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01015fa:	85 c0                	test   %eax,%eax
f01015fc:	78 a4                	js     f01015a2 <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01015fe:	83 f8 08             	cmp    $0x8,%eax
f0101601:	0f 94 c2             	sete   %dl
f0101604:	83 f8 7f             	cmp    $0x7f,%eax
f0101607:	0f 94 c0             	sete   %al
f010160a:	08 c2                	or     %al,%dl
f010160c:	74 04                	je     f0101612 <readline+0xc2>
f010160e:	85 ff                	test   %edi,%edi
f0101610:	7f b0                	jg     f01015c2 <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101612:	83 fe 1f             	cmp    $0x1f,%esi
f0101615:	7e 10                	jle    f0101627 <readline+0xd7>
f0101617:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f010161d:	7f 08                	jg     f0101627 <readline+0xd7>
			if (echoing)
f010161f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101623:	74 c3                	je     f01015e8 <readline+0x98>
f0101625:	eb b5                	jmp    f01015dc <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f0101627:	83 fe 0a             	cmp    $0xa,%esi
f010162a:	74 05                	je     f0101631 <readline+0xe1>
f010162c:	83 fe 0d             	cmp    $0xd,%esi
f010162f:	75 c2                	jne    f01015f3 <readline+0xa3>
			if (echoing)
f0101631:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101635:	75 13                	jne    f010164a <readline+0xfa>
			buf[i] = 0;
f0101637:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f010163e:	00 
			return buf;
f010163f:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101645:	e9 70 ff ff ff       	jmp    f01015ba <readline+0x6a>
				cputchar('\n');
f010164a:	83 ec 0c             	sub    $0xc,%esp
f010164d:	6a 0a                	push   $0xa
f010164f:	e8 07 f1 ff ff       	call   f010075b <cputchar>
f0101654:	83 c4 10             	add    $0x10,%esp
f0101657:	eb de                	jmp    f0101637 <readline+0xe7>

f0101659 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101659:	f3 0f 1e fb          	endbr32 
f010165d:	55                   	push   %ebp
f010165e:	89 e5                	mov    %esp,%ebp
f0101660:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101663:	b8 00 00 00 00       	mov    $0x0,%eax
f0101668:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010166c:	74 05                	je     f0101673 <strlen+0x1a>
		n++;
f010166e:	83 c0 01             	add    $0x1,%eax
f0101671:	eb f5                	jmp    f0101668 <strlen+0xf>
	return n;
}
f0101673:	5d                   	pop    %ebp
f0101674:	c3                   	ret    

f0101675 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101675:	f3 0f 1e fb          	endbr32 
f0101679:	55                   	push   %ebp
f010167a:	89 e5                	mov    %esp,%ebp
f010167c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010167f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101682:	b8 00 00 00 00       	mov    $0x0,%eax
f0101687:	39 d0                	cmp    %edx,%eax
f0101689:	74 0d                	je     f0101698 <strnlen+0x23>
f010168b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010168f:	74 05                	je     f0101696 <strnlen+0x21>
		n++;
f0101691:	83 c0 01             	add    $0x1,%eax
f0101694:	eb f1                	jmp    f0101687 <strnlen+0x12>
f0101696:	89 c2                	mov    %eax,%edx
	return n;
}
f0101698:	89 d0                	mov    %edx,%eax
f010169a:	5d                   	pop    %ebp
f010169b:	c3                   	ret    

f010169c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010169c:	f3 0f 1e fb          	endbr32 
f01016a0:	55                   	push   %ebp
f01016a1:	89 e5                	mov    %esp,%ebp
f01016a3:	53                   	push   %ebx
f01016a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01016aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01016af:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01016b3:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01016b6:	83 c0 01             	add    $0x1,%eax
f01016b9:	84 d2                	test   %dl,%dl
f01016bb:	75 f2                	jne    f01016af <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f01016bd:	89 c8                	mov    %ecx,%eax
f01016bf:	5b                   	pop    %ebx
f01016c0:	5d                   	pop    %ebp
f01016c1:	c3                   	ret    

f01016c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01016c2:	f3 0f 1e fb          	endbr32 
f01016c6:	55                   	push   %ebp
f01016c7:	89 e5                	mov    %esp,%ebp
f01016c9:	53                   	push   %ebx
f01016ca:	83 ec 10             	sub    $0x10,%esp
f01016cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01016d0:	53                   	push   %ebx
f01016d1:	e8 83 ff ff ff       	call   f0101659 <strlen>
f01016d6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01016d9:	ff 75 0c             	pushl  0xc(%ebp)
f01016dc:	01 d8                	add    %ebx,%eax
f01016de:	50                   	push   %eax
f01016df:	e8 b8 ff ff ff       	call   f010169c <strcpy>
	return dst;
}
f01016e4:	89 d8                	mov    %ebx,%eax
f01016e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016e9:	c9                   	leave  
f01016ea:	c3                   	ret    

f01016eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01016eb:	f3 0f 1e fb          	endbr32 
f01016ef:	55                   	push   %ebp
f01016f0:	89 e5                	mov    %esp,%ebp
f01016f2:	56                   	push   %esi
f01016f3:	53                   	push   %ebx
f01016f4:	8b 75 08             	mov    0x8(%ebp),%esi
f01016f7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016fa:	89 f3                	mov    %esi,%ebx
f01016fc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01016ff:	89 f0                	mov    %esi,%eax
f0101701:	39 d8                	cmp    %ebx,%eax
f0101703:	74 11                	je     f0101716 <strncpy+0x2b>
		*dst++ = *src;
f0101705:	83 c0 01             	add    $0x1,%eax
f0101708:	0f b6 0a             	movzbl (%edx),%ecx
f010170b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010170e:	80 f9 01             	cmp    $0x1,%cl
f0101711:	83 da ff             	sbb    $0xffffffff,%edx
f0101714:	eb eb                	jmp    f0101701 <strncpy+0x16>
	}
	return ret;
}
f0101716:	89 f0                	mov    %esi,%eax
f0101718:	5b                   	pop    %ebx
f0101719:	5e                   	pop    %esi
f010171a:	5d                   	pop    %ebp
f010171b:	c3                   	ret    

f010171c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010171c:	f3 0f 1e fb          	endbr32 
f0101720:	55                   	push   %ebp
f0101721:	89 e5                	mov    %esp,%ebp
f0101723:	56                   	push   %esi
f0101724:	53                   	push   %ebx
f0101725:	8b 75 08             	mov    0x8(%ebp),%esi
f0101728:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010172b:	8b 55 10             	mov    0x10(%ebp),%edx
f010172e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101730:	85 d2                	test   %edx,%edx
f0101732:	74 21                	je     f0101755 <strlcpy+0x39>
f0101734:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101738:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010173a:	39 c2                	cmp    %eax,%edx
f010173c:	74 14                	je     f0101752 <strlcpy+0x36>
f010173e:	0f b6 19             	movzbl (%ecx),%ebx
f0101741:	84 db                	test   %bl,%bl
f0101743:	74 0b                	je     f0101750 <strlcpy+0x34>
			*dst++ = *src++;
f0101745:	83 c1 01             	add    $0x1,%ecx
f0101748:	83 c2 01             	add    $0x1,%edx
f010174b:	88 5a ff             	mov    %bl,-0x1(%edx)
f010174e:	eb ea                	jmp    f010173a <strlcpy+0x1e>
f0101750:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101752:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101755:	29 f0                	sub    %esi,%eax
}
f0101757:	5b                   	pop    %ebx
f0101758:	5e                   	pop    %esi
f0101759:	5d                   	pop    %ebp
f010175a:	c3                   	ret    

f010175b <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010175b:	f3 0f 1e fb          	endbr32 
f010175f:	55                   	push   %ebp
f0101760:	89 e5                	mov    %esp,%ebp
f0101762:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101765:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101768:	0f b6 01             	movzbl (%ecx),%eax
f010176b:	84 c0                	test   %al,%al
f010176d:	74 0c                	je     f010177b <strcmp+0x20>
f010176f:	3a 02                	cmp    (%edx),%al
f0101771:	75 08                	jne    f010177b <strcmp+0x20>
		p++, q++;
f0101773:	83 c1 01             	add    $0x1,%ecx
f0101776:	83 c2 01             	add    $0x1,%edx
f0101779:	eb ed                	jmp    f0101768 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010177b:	0f b6 c0             	movzbl %al,%eax
f010177e:	0f b6 12             	movzbl (%edx),%edx
f0101781:	29 d0                	sub    %edx,%eax
}
f0101783:	5d                   	pop    %ebp
f0101784:	c3                   	ret    

f0101785 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101785:	f3 0f 1e fb          	endbr32 
f0101789:	55                   	push   %ebp
f010178a:	89 e5                	mov    %esp,%ebp
f010178c:	53                   	push   %ebx
f010178d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101790:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101793:	89 c3                	mov    %eax,%ebx
f0101795:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101798:	eb 06                	jmp    f01017a0 <strncmp+0x1b>
		n--, p++, q++;
f010179a:	83 c0 01             	add    $0x1,%eax
f010179d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01017a0:	39 d8                	cmp    %ebx,%eax
f01017a2:	74 16                	je     f01017ba <strncmp+0x35>
f01017a4:	0f b6 08             	movzbl (%eax),%ecx
f01017a7:	84 c9                	test   %cl,%cl
f01017a9:	74 04                	je     f01017af <strncmp+0x2a>
f01017ab:	3a 0a                	cmp    (%edx),%cl
f01017ad:	74 eb                	je     f010179a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01017af:	0f b6 00             	movzbl (%eax),%eax
f01017b2:	0f b6 12             	movzbl (%edx),%edx
f01017b5:	29 d0                	sub    %edx,%eax
}
f01017b7:	5b                   	pop    %ebx
f01017b8:	5d                   	pop    %ebp
f01017b9:	c3                   	ret    
		return 0;
f01017ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01017bf:	eb f6                	jmp    f01017b7 <strncmp+0x32>

f01017c1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01017c1:	f3 0f 1e fb          	endbr32 
f01017c5:	55                   	push   %ebp
f01017c6:	89 e5                	mov    %esp,%ebp
f01017c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01017cb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017cf:	0f b6 10             	movzbl (%eax),%edx
f01017d2:	84 d2                	test   %dl,%dl
f01017d4:	74 09                	je     f01017df <strchr+0x1e>
		if (*s == c)
f01017d6:	38 ca                	cmp    %cl,%dl
f01017d8:	74 0a                	je     f01017e4 <strchr+0x23>
	for (; *s; s++)
f01017da:	83 c0 01             	add    $0x1,%eax
f01017dd:	eb f0                	jmp    f01017cf <strchr+0xe>
			return (char *) s;
	return 0;
f01017df:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017e4:	5d                   	pop    %ebp
f01017e5:	c3                   	ret    

f01017e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01017e6:	f3 0f 1e fb          	endbr32 
f01017ea:	55                   	push   %ebp
f01017eb:	89 e5                	mov    %esp,%ebp
f01017ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01017f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017f4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01017f7:	38 ca                	cmp    %cl,%dl
f01017f9:	74 09                	je     f0101804 <strfind+0x1e>
f01017fb:	84 d2                	test   %dl,%dl
f01017fd:	74 05                	je     f0101804 <strfind+0x1e>
	for (; *s; s++)
f01017ff:	83 c0 01             	add    $0x1,%eax
f0101802:	eb f0                	jmp    f01017f4 <strfind+0xe>
			break;
	return (char *) s;
}
f0101804:	5d                   	pop    %ebp
f0101805:	c3                   	ret    

f0101806 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101806:	f3 0f 1e fb          	endbr32 
f010180a:	55                   	push   %ebp
f010180b:	89 e5                	mov    %esp,%ebp
f010180d:	57                   	push   %edi
f010180e:	56                   	push   %esi
f010180f:	53                   	push   %ebx
f0101810:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101813:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101816:	85 c9                	test   %ecx,%ecx
f0101818:	74 31                	je     f010184b <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010181a:	89 f8                	mov    %edi,%eax
f010181c:	09 c8                	or     %ecx,%eax
f010181e:	a8 03                	test   $0x3,%al
f0101820:	75 23                	jne    f0101845 <memset+0x3f>
		c &= 0xFF;
f0101822:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101826:	89 d3                	mov    %edx,%ebx
f0101828:	c1 e3 08             	shl    $0x8,%ebx
f010182b:	89 d0                	mov    %edx,%eax
f010182d:	c1 e0 18             	shl    $0x18,%eax
f0101830:	89 d6                	mov    %edx,%esi
f0101832:	c1 e6 10             	shl    $0x10,%esi
f0101835:	09 f0                	or     %esi,%eax
f0101837:	09 c2                	or     %eax,%edx
f0101839:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010183b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f010183e:	89 d0                	mov    %edx,%eax
f0101840:	fc                   	cld    
f0101841:	f3 ab                	rep stos %eax,%es:(%edi)
f0101843:	eb 06                	jmp    f010184b <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101845:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101848:	fc                   	cld    
f0101849:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010184b:	89 f8                	mov    %edi,%eax
f010184d:	5b                   	pop    %ebx
f010184e:	5e                   	pop    %esi
f010184f:	5f                   	pop    %edi
f0101850:	5d                   	pop    %ebp
f0101851:	c3                   	ret    

f0101852 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101852:	f3 0f 1e fb          	endbr32 
f0101856:	55                   	push   %ebp
f0101857:	89 e5                	mov    %esp,%ebp
f0101859:	57                   	push   %edi
f010185a:	56                   	push   %esi
f010185b:	8b 45 08             	mov    0x8(%ebp),%eax
f010185e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101861:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101864:	39 c6                	cmp    %eax,%esi
f0101866:	73 32                	jae    f010189a <memmove+0x48>
f0101868:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010186b:	39 c2                	cmp    %eax,%edx
f010186d:	76 2b                	jbe    f010189a <memmove+0x48>
		s += n;
		d += n;
f010186f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101872:	89 fe                	mov    %edi,%esi
f0101874:	09 ce                	or     %ecx,%esi
f0101876:	09 d6                	or     %edx,%esi
f0101878:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010187e:	75 0e                	jne    f010188e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101880:	83 ef 04             	sub    $0x4,%edi
f0101883:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101886:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0101889:	fd                   	std    
f010188a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010188c:	eb 09                	jmp    f0101897 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f010188e:	83 ef 01             	sub    $0x1,%edi
f0101891:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101894:	fd                   	std    
f0101895:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101897:	fc                   	cld    
f0101898:	eb 1a                	jmp    f01018b4 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010189a:	89 c2                	mov    %eax,%edx
f010189c:	09 ca                	or     %ecx,%edx
f010189e:	09 f2                	or     %esi,%edx
f01018a0:	f6 c2 03             	test   $0x3,%dl
f01018a3:	75 0a                	jne    f01018af <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01018a5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01018a8:	89 c7                	mov    %eax,%edi
f01018aa:	fc                   	cld    
f01018ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01018ad:	eb 05                	jmp    f01018b4 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f01018af:	89 c7                	mov    %eax,%edi
f01018b1:	fc                   	cld    
f01018b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01018b4:	5e                   	pop    %esi
f01018b5:	5f                   	pop    %edi
f01018b6:	5d                   	pop    %ebp
f01018b7:	c3                   	ret    

f01018b8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01018b8:	f3 0f 1e fb          	endbr32 
f01018bc:	55                   	push   %ebp
f01018bd:	89 e5                	mov    %esp,%ebp
f01018bf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01018c2:	ff 75 10             	pushl  0x10(%ebp)
f01018c5:	ff 75 0c             	pushl  0xc(%ebp)
f01018c8:	ff 75 08             	pushl  0x8(%ebp)
f01018cb:	e8 82 ff ff ff       	call   f0101852 <memmove>
}
f01018d0:	c9                   	leave  
f01018d1:	c3                   	ret    

f01018d2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01018d2:	f3 0f 1e fb          	endbr32 
f01018d6:	55                   	push   %ebp
f01018d7:	89 e5                	mov    %esp,%ebp
f01018d9:	56                   	push   %esi
f01018da:	53                   	push   %ebx
f01018db:	8b 45 08             	mov    0x8(%ebp),%eax
f01018de:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018e1:	89 c6                	mov    %eax,%esi
f01018e3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018e6:	39 f0                	cmp    %esi,%eax
f01018e8:	74 1c                	je     f0101906 <memcmp+0x34>
		if (*s1 != *s2)
f01018ea:	0f b6 08             	movzbl (%eax),%ecx
f01018ed:	0f b6 1a             	movzbl (%edx),%ebx
f01018f0:	38 d9                	cmp    %bl,%cl
f01018f2:	75 08                	jne    f01018fc <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01018f4:	83 c0 01             	add    $0x1,%eax
f01018f7:	83 c2 01             	add    $0x1,%edx
f01018fa:	eb ea                	jmp    f01018e6 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f01018fc:	0f b6 c1             	movzbl %cl,%eax
f01018ff:	0f b6 db             	movzbl %bl,%ebx
f0101902:	29 d8                	sub    %ebx,%eax
f0101904:	eb 05                	jmp    f010190b <memcmp+0x39>
	}

	return 0;
f0101906:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010190b:	5b                   	pop    %ebx
f010190c:	5e                   	pop    %esi
f010190d:	5d                   	pop    %ebp
f010190e:	c3                   	ret    

f010190f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010190f:	f3 0f 1e fb          	endbr32 
f0101913:	55                   	push   %ebp
f0101914:	89 e5                	mov    %esp,%ebp
f0101916:	8b 45 08             	mov    0x8(%ebp),%eax
f0101919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010191c:	89 c2                	mov    %eax,%edx
f010191e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101921:	39 d0                	cmp    %edx,%eax
f0101923:	73 09                	jae    f010192e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101925:	38 08                	cmp    %cl,(%eax)
f0101927:	74 05                	je     f010192e <memfind+0x1f>
	for (; s < ends; s++)
f0101929:	83 c0 01             	add    $0x1,%eax
f010192c:	eb f3                	jmp    f0101921 <memfind+0x12>
			break;
	return (void *) s;
}
f010192e:	5d                   	pop    %ebp
f010192f:	c3                   	ret    

f0101930 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101930:	f3 0f 1e fb          	endbr32 
f0101934:	55                   	push   %ebp
f0101935:	89 e5                	mov    %esp,%ebp
f0101937:	57                   	push   %edi
f0101938:	56                   	push   %esi
f0101939:	53                   	push   %ebx
f010193a:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010193d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101940:	eb 03                	jmp    f0101945 <strtol+0x15>
		s++;
f0101942:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101945:	0f b6 01             	movzbl (%ecx),%eax
f0101948:	3c 20                	cmp    $0x20,%al
f010194a:	74 f6                	je     f0101942 <strtol+0x12>
f010194c:	3c 09                	cmp    $0x9,%al
f010194e:	74 f2                	je     f0101942 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0101950:	3c 2b                	cmp    $0x2b,%al
f0101952:	74 2a                	je     f010197e <strtol+0x4e>
	int neg = 0;
f0101954:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0101959:	3c 2d                	cmp    $0x2d,%al
f010195b:	74 2b                	je     f0101988 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010195d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101963:	75 0f                	jne    f0101974 <strtol+0x44>
f0101965:	80 39 30             	cmpb   $0x30,(%ecx)
f0101968:	74 28                	je     f0101992 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010196a:	85 db                	test   %ebx,%ebx
f010196c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101971:	0f 44 d8             	cmove  %eax,%ebx
f0101974:	b8 00 00 00 00       	mov    $0x0,%eax
f0101979:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010197c:	eb 46                	jmp    f01019c4 <strtol+0x94>
		s++;
f010197e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101981:	bf 00 00 00 00       	mov    $0x0,%edi
f0101986:	eb d5                	jmp    f010195d <strtol+0x2d>
		s++, neg = 1;
f0101988:	83 c1 01             	add    $0x1,%ecx
f010198b:	bf 01 00 00 00       	mov    $0x1,%edi
f0101990:	eb cb                	jmp    f010195d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101992:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101996:	74 0e                	je     f01019a6 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0101998:	85 db                	test   %ebx,%ebx
f010199a:	75 d8                	jne    f0101974 <strtol+0x44>
		s++, base = 8;
f010199c:	83 c1 01             	add    $0x1,%ecx
f010199f:	bb 08 00 00 00       	mov    $0x8,%ebx
f01019a4:	eb ce                	jmp    f0101974 <strtol+0x44>
		s += 2, base = 16;
f01019a6:	83 c1 02             	add    $0x2,%ecx
f01019a9:	bb 10 00 00 00       	mov    $0x10,%ebx
f01019ae:	eb c4                	jmp    f0101974 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f01019b0:	0f be d2             	movsbl %dl,%edx
f01019b3:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01019b6:	3b 55 10             	cmp    0x10(%ebp),%edx
f01019b9:	7d 3a                	jge    f01019f5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01019bb:	83 c1 01             	add    $0x1,%ecx
f01019be:	0f af 45 10          	imul   0x10(%ebp),%eax
f01019c2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01019c4:	0f b6 11             	movzbl (%ecx),%edx
f01019c7:	8d 72 d0             	lea    -0x30(%edx),%esi
f01019ca:	89 f3                	mov    %esi,%ebx
f01019cc:	80 fb 09             	cmp    $0x9,%bl
f01019cf:	76 df                	jbe    f01019b0 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f01019d1:	8d 72 9f             	lea    -0x61(%edx),%esi
f01019d4:	89 f3                	mov    %esi,%ebx
f01019d6:	80 fb 19             	cmp    $0x19,%bl
f01019d9:	77 08                	ja     f01019e3 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01019db:	0f be d2             	movsbl %dl,%edx
f01019de:	83 ea 57             	sub    $0x57,%edx
f01019e1:	eb d3                	jmp    f01019b6 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f01019e3:	8d 72 bf             	lea    -0x41(%edx),%esi
f01019e6:	89 f3                	mov    %esi,%ebx
f01019e8:	80 fb 19             	cmp    $0x19,%bl
f01019eb:	77 08                	ja     f01019f5 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01019ed:	0f be d2             	movsbl %dl,%edx
f01019f0:	83 ea 37             	sub    $0x37,%edx
f01019f3:	eb c1                	jmp    f01019b6 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f01019f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01019f9:	74 05                	je     f0101a00 <strtol+0xd0>
		*endptr = (char *) s;
f01019fb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01019fe:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0101a00:	89 c2                	mov    %eax,%edx
f0101a02:	f7 da                	neg    %edx
f0101a04:	85 ff                	test   %edi,%edi
f0101a06:	0f 45 c2             	cmovne %edx,%eax
}
f0101a09:	5b                   	pop    %ebx
f0101a0a:	5e                   	pop    %esi
f0101a0b:	5f                   	pop    %edi
f0101a0c:	5d                   	pop    %ebp
f0101a0d:	c3                   	ret    
f0101a0e:	66 90                	xchg   %ax,%ax

f0101a10 <__udivdi3>:
f0101a10:	f3 0f 1e fb          	endbr32 
f0101a14:	55                   	push   %ebp
f0101a15:	57                   	push   %edi
f0101a16:	56                   	push   %esi
f0101a17:	53                   	push   %ebx
f0101a18:	83 ec 1c             	sub    $0x1c,%esp
f0101a1b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101a1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101a23:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101a27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101a2b:	85 d2                	test   %edx,%edx
f0101a2d:	75 19                	jne    f0101a48 <__udivdi3+0x38>
f0101a2f:	39 f3                	cmp    %esi,%ebx
f0101a31:	76 4d                	jbe    f0101a80 <__udivdi3+0x70>
f0101a33:	31 ff                	xor    %edi,%edi
f0101a35:	89 e8                	mov    %ebp,%eax
f0101a37:	89 f2                	mov    %esi,%edx
f0101a39:	f7 f3                	div    %ebx
f0101a3b:	89 fa                	mov    %edi,%edx
f0101a3d:	83 c4 1c             	add    $0x1c,%esp
f0101a40:	5b                   	pop    %ebx
f0101a41:	5e                   	pop    %esi
f0101a42:	5f                   	pop    %edi
f0101a43:	5d                   	pop    %ebp
f0101a44:	c3                   	ret    
f0101a45:	8d 76 00             	lea    0x0(%esi),%esi
f0101a48:	39 f2                	cmp    %esi,%edx
f0101a4a:	76 14                	jbe    f0101a60 <__udivdi3+0x50>
f0101a4c:	31 ff                	xor    %edi,%edi
f0101a4e:	31 c0                	xor    %eax,%eax
f0101a50:	89 fa                	mov    %edi,%edx
f0101a52:	83 c4 1c             	add    $0x1c,%esp
f0101a55:	5b                   	pop    %ebx
f0101a56:	5e                   	pop    %esi
f0101a57:	5f                   	pop    %edi
f0101a58:	5d                   	pop    %ebp
f0101a59:	c3                   	ret    
f0101a5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a60:	0f bd fa             	bsr    %edx,%edi
f0101a63:	83 f7 1f             	xor    $0x1f,%edi
f0101a66:	75 48                	jne    f0101ab0 <__udivdi3+0xa0>
f0101a68:	39 f2                	cmp    %esi,%edx
f0101a6a:	72 06                	jb     f0101a72 <__udivdi3+0x62>
f0101a6c:	31 c0                	xor    %eax,%eax
f0101a6e:	39 eb                	cmp    %ebp,%ebx
f0101a70:	77 de                	ja     f0101a50 <__udivdi3+0x40>
f0101a72:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a77:	eb d7                	jmp    f0101a50 <__udivdi3+0x40>
f0101a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a80:	89 d9                	mov    %ebx,%ecx
f0101a82:	85 db                	test   %ebx,%ebx
f0101a84:	75 0b                	jne    f0101a91 <__udivdi3+0x81>
f0101a86:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a8b:	31 d2                	xor    %edx,%edx
f0101a8d:	f7 f3                	div    %ebx
f0101a8f:	89 c1                	mov    %eax,%ecx
f0101a91:	31 d2                	xor    %edx,%edx
f0101a93:	89 f0                	mov    %esi,%eax
f0101a95:	f7 f1                	div    %ecx
f0101a97:	89 c6                	mov    %eax,%esi
f0101a99:	89 e8                	mov    %ebp,%eax
f0101a9b:	89 f7                	mov    %esi,%edi
f0101a9d:	f7 f1                	div    %ecx
f0101a9f:	89 fa                	mov    %edi,%edx
f0101aa1:	83 c4 1c             	add    $0x1c,%esp
f0101aa4:	5b                   	pop    %ebx
f0101aa5:	5e                   	pop    %esi
f0101aa6:	5f                   	pop    %edi
f0101aa7:	5d                   	pop    %ebp
f0101aa8:	c3                   	ret    
f0101aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101ab0:	89 f9                	mov    %edi,%ecx
f0101ab2:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ab7:	29 f8                	sub    %edi,%eax
f0101ab9:	d3 e2                	shl    %cl,%edx
f0101abb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101abf:	89 c1                	mov    %eax,%ecx
f0101ac1:	89 da                	mov    %ebx,%edx
f0101ac3:	d3 ea                	shr    %cl,%edx
f0101ac5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101ac9:	09 d1                	or     %edx,%ecx
f0101acb:	89 f2                	mov    %esi,%edx
f0101acd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ad1:	89 f9                	mov    %edi,%ecx
f0101ad3:	d3 e3                	shl    %cl,%ebx
f0101ad5:	89 c1                	mov    %eax,%ecx
f0101ad7:	d3 ea                	shr    %cl,%edx
f0101ad9:	89 f9                	mov    %edi,%ecx
f0101adb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101adf:	89 eb                	mov    %ebp,%ebx
f0101ae1:	d3 e6                	shl    %cl,%esi
f0101ae3:	89 c1                	mov    %eax,%ecx
f0101ae5:	d3 eb                	shr    %cl,%ebx
f0101ae7:	09 de                	or     %ebx,%esi
f0101ae9:	89 f0                	mov    %esi,%eax
f0101aeb:	f7 74 24 08          	divl   0x8(%esp)
f0101aef:	89 d6                	mov    %edx,%esi
f0101af1:	89 c3                	mov    %eax,%ebx
f0101af3:	f7 64 24 0c          	mull   0xc(%esp)
f0101af7:	39 d6                	cmp    %edx,%esi
f0101af9:	72 15                	jb     f0101b10 <__udivdi3+0x100>
f0101afb:	89 f9                	mov    %edi,%ecx
f0101afd:	d3 e5                	shl    %cl,%ebp
f0101aff:	39 c5                	cmp    %eax,%ebp
f0101b01:	73 04                	jae    f0101b07 <__udivdi3+0xf7>
f0101b03:	39 d6                	cmp    %edx,%esi
f0101b05:	74 09                	je     f0101b10 <__udivdi3+0x100>
f0101b07:	89 d8                	mov    %ebx,%eax
f0101b09:	31 ff                	xor    %edi,%edi
f0101b0b:	e9 40 ff ff ff       	jmp    f0101a50 <__udivdi3+0x40>
f0101b10:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101b13:	31 ff                	xor    %edi,%edi
f0101b15:	e9 36 ff ff ff       	jmp    f0101a50 <__udivdi3+0x40>
f0101b1a:	66 90                	xchg   %ax,%ax
f0101b1c:	66 90                	xchg   %ax,%ax
f0101b1e:	66 90                	xchg   %ax,%ax

f0101b20 <__umoddi3>:
f0101b20:	f3 0f 1e fb          	endbr32 
f0101b24:	55                   	push   %ebp
f0101b25:	57                   	push   %edi
f0101b26:	56                   	push   %esi
f0101b27:	53                   	push   %ebx
f0101b28:	83 ec 1c             	sub    $0x1c,%esp
f0101b2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101b2f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101b33:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101b37:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101b3b:	85 c0                	test   %eax,%eax
f0101b3d:	75 19                	jne    f0101b58 <__umoddi3+0x38>
f0101b3f:	39 df                	cmp    %ebx,%edi
f0101b41:	76 5d                	jbe    f0101ba0 <__umoddi3+0x80>
f0101b43:	89 f0                	mov    %esi,%eax
f0101b45:	89 da                	mov    %ebx,%edx
f0101b47:	f7 f7                	div    %edi
f0101b49:	89 d0                	mov    %edx,%eax
f0101b4b:	31 d2                	xor    %edx,%edx
f0101b4d:	83 c4 1c             	add    $0x1c,%esp
f0101b50:	5b                   	pop    %ebx
f0101b51:	5e                   	pop    %esi
f0101b52:	5f                   	pop    %edi
f0101b53:	5d                   	pop    %ebp
f0101b54:	c3                   	ret    
f0101b55:	8d 76 00             	lea    0x0(%esi),%esi
f0101b58:	89 f2                	mov    %esi,%edx
f0101b5a:	39 d8                	cmp    %ebx,%eax
f0101b5c:	76 12                	jbe    f0101b70 <__umoddi3+0x50>
f0101b5e:	89 f0                	mov    %esi,%eax
f0101b60:	89 da                	mov    %ebx,%edx
f0101b62:	83 c4 1c             	add    $0x1c,%esp
f0101b65:	5b                   	pop    %ebx
f0101b66:	5e                   	pop    %esi
f0101b67:	5f                   	pop    %edi
f0101b68:	5d                   	pop    %ebp
f0101b69:	c3                   	ret    
f0101b6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b70:	0f bd e8             	bsr    %eax,%ebp
f0101b73:	83 f5 1f             	xor    $0x1f,%ebp
f0101b76:	75 50                	jne    f0101bc8 <__umoddi3+0xa8>
f0101b78:	39 d8                	cmp    %ebx,%eax
f0101b7a:	0f 82 e0 00 00 00    	jb     f0101c60 <__umoddi3+0x140>
f0101b80:	89 d9                	mov    %ebx,%ecx
f0101b82:	39 f7                	cmp    %esi,%edi
f0101b84:	0f 86 d6 00 00 00    	jbe    f0101c60 <__umoddi3+0x140>
f0101b8a:	89 d0                	mov    %edx,%eax
f0101b8c:	89 ca                	mov    %ecx,%edx
f0101b8e:	83 c4 1c             	add    $0x1c,%esp
f0101b91:	5b                   	pop    %ebx
f0101b92:	5e                   	pop    %esi
f0101b93:	5f                   	pop    %edi
f0101b94:	5d                   	pop    %ebp
f0101b95:	c3                   	ret    
f0101b96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b9d:	8d 76 00             	lea    0x0(%esi),%esi
f0101ba0:	89 fd                	mov    %edi,%ebp
f0101ba2:	85 ff                	test   %edi,%edi
f0101ba4:	75 0b                	jne    f0101bb1 <__umoddi3+0x91>
f0101ba6:	b8 01 00 00 00       	mov    $0x1,%eax
f0101bab:	31 d2                	xor    %edx,%edx
f0101bad:	f7 f7                	div    %edi
f0101baf:	89 c5                	mov    %eax,%ebp
f0101bb1:	89 d8                	mov    %ebx,%eax
f0101bb3:	31 d2                	xor    %edx,%edx
f0101bb5:	f7 f5                	div    %ebp
f0101bb7:	89 f0                	mov    %esi,%eax
f0101bb9:	f7 f5                	div    %ebp
f0101bbb:	89 d0                	mov    %edx,%eax
f0101bbd:	31 d2                	xor    %edx,%edx
f0101bbf:	eb 8c                	jmp    f0101b4d <__umoddi3+0x2d>
f0101bc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101bc8:	89 e9                	mov    %ebp,%ecx
f0101bca:	ba 20 00 00 00       	mov    $0x20,%edx
f0101bcf:	29 ea                	sub    %ebp,%edx
f0101bd1:	d3 e0                	shl    %cl,%eax
f0101bd3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bd7:	89 d1                	mov    %edx,%ecx
f0101bd9:	89 f8                	mov    %edi,%eax
f0101bdb:	d3 e8                	shr    %cl,%eax
f0101bdd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101be1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101be5:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101be9:	09 c1                	or     %eax,%ecx
f0101beb:	89 d8                	mov    %ebx,%eax
f0101bed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101bf1:	89 e9                	mov    %ebp,%ecx
f0101bf3:	d3 e7                	shl    %cl,%edi
f0101bf5:	89 d1                	mov    %edx,%ecx
f0101bf7:	d3 e8                	shr    %cl,%eax
f0101bf9:	89 e9                	mov    %ebp,%ecx
f0101bfb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101bff:	d3 e3                	shl    %cl,%ebx
f0101c01:	89 c7                	mov    %eax,%edi
f0101c03:	89 d1                	mov    %edx,%ecx
f0101c05:	89 f0                	mov    %esi,%eax
f0101c07:	d3 e8                	shr    %cl,%eax
f0101c09:	89 e9                	mov    %ebp,%ecx
f0101c0b:	89 fa                	mov    %edi,%edx
f0101c0d:	d3 e6                	shl    %cl,%esi
f0101c0f:	09 d8                	or     %ebx,%eax
f0101c11:	f7 74 24 08          	divl   0x8(%esp)
f0101c15:	89 d1                	mov    %edx,%ecx
f0101c17:	89 f3                	mov    %esi,%ebx
f0101c19:	f7 64 24 0c          	mull   0xc(%esp)
f0101c1d:	89 c6                	mov    %eax,%esi
f0101c1f:	89 d7                	mov    %edx,%edi
f0101c21:	39 d1                	cmp    %edx,%ecx
f0101c23:	72 06                	jb     f0101c2b <__umoddi3+0x10b>
f0101c25:	75 10                	jne    f0101c37 <__umoddi3+0x117>
f0101c27:	39 c3                	cmp    %eax,%ebx
f0101c29:	73 0c                	jae    f0101c37 <__umoddi3+0x117>
f0101c2b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101c2f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101c33:	89 d7                	mov    %edx,%edi
f0101c35:	89 c6                	mov    %eax,%esi
f0101c37:	89 ca                	mov    %ecx,%edx
f0101c39:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101c3e:	29 f3                	sub    %esi,%ebx
f0101c40:	19 fa                	sbb    %edi,%edx
f0101c42:	89 d0                	mov    %edx,%eax
f0101c44:	d3 e0                	shl    %cl,%eax
f0101c46:	89 e9                	mov    %ebp,%ecx
f0101c48:	d3 eb                	shr    %cl,%ebx
f0101c4a:	d3 ea                	shr    %cl,%edx
f0101c4c:	09 d8                	or     %ebx,%eax
f0101c4e:	83 c4 1c             	add    $0x1c,%esp
f0101c51:	5b                   	pop    %ebx
f0101c52:	5e                   	pop    %esi
f0101c53:	5f                   	pop    %edi
f0101c54:	5d                   	pop    %ebp
f0101c55:	c3                   	ret    
f0101c56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c5d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c60:	29 fe                	sub    %edi,%esi
f0101c62:	19 c3                	sbb    %eax,%ebx
f0101c64:	89 f2                	mov    %esi,%edx
f0101c66:	89 d9                	mov    %ebx,%ecx
f0101c68:	e9 1d ff ff ff       	jmp    f0101b8a <__umoddi3+0x6a>
