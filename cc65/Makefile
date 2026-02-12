SOURCES := conio.s read.s write.s crt0.s
PLATFORM := microuk101
OBJECTS := $(SOURCES:.s=.o)
LIBRARY := $(PLATFORM).lib
CC65HOME := /usr/share/cc65

START := 0x1000

$(LIBRARY): $(OBJECTS)
	ar65 a $@ $^

%.o: %.c
	cl65 -c -t none --cpu 6502 $<

%.o: %.s
	ca65 --cpu 6502 $<

install: $(LIBRARY)
	install -c -m 0644 $(LIBRARY) $(CC65HOME)/lib
	install -c -m 0644 $(PLATFORM).cfg $(CC65HOME)/cfg
	install -c -m 0644 $(PLATFORM).inc $(CC65HOME)/asminc

clean:
	rm -f $(OBJECTS) $(LIBRARY)
