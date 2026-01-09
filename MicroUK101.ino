#include <r65emu.h>
#include <r6502.h>
#include <acia.h>
#include <debugging.h>
#include "roms/encoder.h"
#include "roms/toolkit2.h"
#include "roms/basuk01.h"
#include "roms/basuk02.h"
#include "roms/basuk03.h"
#include "roms/basuk04.h"
#include "roms/ceggs.h"

Memory memory;
r6502 cpu(memory);

class SerialAcia: public Memory::Device {
public:
	SerialAcia(): Memory::Device(2048) {}

	void init() {
		_acia.register_framing_handler([](uint32_t cfg) {
#if DEBUGGING != DEBUG_NONE
			DBG_EMU(printf("framing: %x\r\n", cfg));
#else
			Serial.begin(TERMINAL_SPEED, cfg);
#endif
		});
		_acia.register_read_data_handler([]() {
			uint8_t b = Serial.read();
			DBG_EMU(printf("read: %x\r\n", b));
			return b;
		});
		_acia.register_write_data_handler([](uint8_t b) {
			DBG_EMU(printf("write: %x\r\n", b));
			Serial.write(b);
		});
		_acia.register_can_rw_handler([](void) {
			uint8_t s = 0;
			if (Serial.available() > 0) s++;
			if (Serial.availableForWrite() > 0) s += 2;
			DBG_EMU(printf("can_rw: %x\r\n", s));
			return s;
		});
	}

	virtual void operator=(uint8_t b) { _acia.write(_acc, b); }
	virtual operator uint8_t() { return _acia.read(_acc); }

private:
	ACIA _acia;

} acia;

prom tk2(toolkit2, 2048);
prom enc(encoder, 2048);
prom basic1(basuk01, 2048);
prom basic2(basuk02, 2048);
prom basic3(basuk03, 2048);
prom basic4(basuk04, 2048);
prom cegmon(ceggs, 2048);

ram<> pages[32];

void setup() {

	hardware_init(cpu);

        for (unsigned i = 0; i < 32; i++)
                memory.put(pages[i], i * ram<>::page_size);

        memory.put(tk2, 0x8000);
        memory.put(enc, 0x8800);
        memory.put(basic1, 0xa000);
        memory.put(basic2, 0xa800);
        memory.put(basic3, 0xb000);
        memory.put(basic4, 0xb800);

	memory.put(acia, 0xf000);
	memory.put(cegmon, 0xf800);

	acia.init();
	hardware_reset();
}

void loop() {

	hardware_run();
}
