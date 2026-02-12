PLATFORM := microuk101
EXAMPLES := hello.c helloconio.c adventure1.c life.c
CPPFLAGS := -D__MICROUK101__
CFLAGS := -t none -O --cpu 6502 -C $(PLATFORM).cfg
START := 0x1000

%.txt: %.bin
	srec_cat $< -binary -offset $(START) -o $@ -os65v

%.bin: %.c
	cl65 $(CPPFLAGS) $(CFLAGS) $< $(PLATFORM).lib none.lib -o $@

clean:
	rm -f $(EXAMPLES:.c=.o) $(EXAMPLES:.c=.bin) $(EXAMPLES:.c=.txt)
