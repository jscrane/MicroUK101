SOURCES := conio.s read.s write.s
PLATFORM := microuk101
OBJECTS := $(SOURCES:.s=.o)
LIBRARY := $(PLATFORM).lib
EXAMPLES := hello.c
CC65HOME := /usr/share/cc65

START := 0x1000

$(LIBRARY): $(OBJECTS)
	cp $(CC65HOME)/lib/none.lib $@
	ar65 a $@ $^

%.o: %.c
	cl65 -c -t none --cpu 6502 $<

%.o: %.s
	ca65 --cpu 6502 $<

%.txt: %.bin
	srec_cat $< -binary -offset $(START) -o $@ -os65v

%.bin: %.o $(LIBRARY)
	ld65 -C $(PLATFORM).cfg $< $(LIBRARY) -o $@

clean: clean-examples
	rm -f $(OBJECTS) $(LIBRARY)

clean-examples:
	rm -f $(EXAMPLES:.c=.s) $(EXAMPLES:.c=.bin) $(EXAMPLES:.c=.txt)
