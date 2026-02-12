PLATFORM := microuk101
EXAMPLES := hello.c helloconio.c adventure1.c life.c
CPPFLAGS := -D__MICROUK101__
CFLAGS := -t none -O --cpu 6502
START := 0x1000

%.txt: %.bin
	srec_cat $< -binary -offset $(START) -o $@ -os65v

%.bin: %.c
	cl65 $(CPPFLAGS) $(CFLAGS) -C $(PLATFORM).cfg $< $(PLATFORM).lib -o $@

clean:
	rm -f $(EXAMPLES:.c=.s) $(EXAMPLES:.c=.bin) $(EXAMPLES:.c=.txt)
