#include <r65emu.h>
#include <r6502.h>
#include <acia.h>
#include "roms/encoder.h"
#include "roms/toolkit2.h"
#include "roms/basuk01.h"
#include "roms/basuk02.h"
#include "roms/basuk03.h"
#include "roms/basuk04.h"
#include "roms/ceggs.h"

r6502 cpu(memory);

class SerialDevice: public Memory::Device, public ACIA {
public:
	SerialDevice(HardwareSerial &s): Memory::Device(2048), _s(s) {}

	void operator=(uint8_t b) { ACIA::write(_acc, b); }
	operator uint8_t() { return ACIA::read(_acc); }

protected:
	uint8_t read_data() { return _s.read(); }
	bool acia_more() { return _s.available() > 0; }
	void write_data(uint8_t b) { _s.write(b); }
	void acia_framing(uint32_t config) { _s.begin(TERMINAL_SPEED, config); }

private:
	HardwareSerial &_s;

} acia(Serial);

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

	hardware_reset();
}

void loop() {

	if (!cpu.halted()) {
#if defined(CPU_DEBUG)
		char buf[256];
		Serial.println(cpu.status(buf, sizeof(buf)));
		cpu.run(1);
#else
                cpu.run(1000);
#endif
	}	
}
