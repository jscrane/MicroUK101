PLATFORM := microuk101
EXAMPLES := hello.c
START := 0x1000

%.txt: %.bin
	srec_cat $< -binary -offset $(START) -o $@ -os65v

%.bin: %.c
	cl65 -t none -C $(PLATFORM).cfg $< $(PLATFORM).lib -o $@

clean:
	rm -f $(EXAMPLES:.c=.s) $(EXAMPLES:.c=.bin) $(EXAMPLES:.c=.txt)
