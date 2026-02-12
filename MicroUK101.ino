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
#include "roms/premier_basic5.h"
#include "roms/premier_basic6.h"
#include "roms/ceggs.h"

Memory memory;
r6502 cpu(memory);
Arduino machine(cpu);

static uint32_t acia_framing(uint8_t b) {
  switch (b) {
    case ACIA::ws7e2:
		  return SERIAL_7E2;
    case ACIA::ws7o2:
		  return SERIAL_7O2;
    case ACIA::ws7e1:
		  return SERIAL_7E1;
    case ACIA::ws7o1:
		  return SERIAL_7O1;
    case ACIA::ws8n2:
		  return SERIAL_8N2;
    case ACIA::ws8n1:
		  return SERIAL_8N1;
    case ACIA::ws8e1:
		  return SERIAL_8E1;
    case ACIA::ws8o1:
		  return SERIAL_8O1;
	}
  return SERIAL_8N1;
}

class SerialAcia: public Memory::Device {
public:
	SerialAcia(): Memory::Device(2048) {}

	void init() {
		_acia.register_framing_handler([](uint8_t b) {
      uint32_t cfg = acia_framing(b);
#if DEBUGGING == DEBUG_NONE
      Serial.begin(TERMINAL_SPEED, cfg);
#endif
      DBG_EMU("framing: %x\r\n", cfg);
		});
		_acia.register_read_data_handler([]() {
			uint8_t b = Serial.read();
			DBG_EMU("read: %02x", b);
			if (b == 0x0e)		// ^N
				machine.reset();
			else if (b == 0x08)	// BS
				b = '_';
			return b;
		});
		_acia.register_write_data_handler([](uint8_t b) {
			DBG_EMU("write: %02x", b);
			if (b == '_') {
				Serial.write(0x08);
				Serial.write(' ');
				Serial.write(0x08);
				return;
			}
			Serial.write(b);
		});
		_acia.register_can_rw_handler([](void) {
			uint8_t s = 0;
			if (Serial.available() > 0) s++;
			if (Serial.availableForWrite() > 0) s += 2;
			DBG_EMU("can_rw: %x", s);
			return s;
		});
    _acia.register_irq_handler([](bool irq) {
      if (irq) cpu.raise(0);
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
prom basic5(premier_basic5, 2048);
prom basic6(premier_basic6, 2048);
prom cegmon(ceggs, 2048);

ram<> pages[32];

void setup() {

  machine.begin();

  for (unsigned i = 0; i < 32; i++)
    memory.put(pages[i], i * ram<>::page_size);

  memory.put(tk2, 0x8000);
  memory.put(enc, 0x8800);
  memory.put(basic5, 0x9000);
  memory.put(basic6, 0x9800);
  memory.put(basic1, 0xa000);
  memory.put(basic2, 0xa800);
  memory.put(basic3, 0xb000);
  memory.put(basic4, 0xb800);

  memory.put(acia, 0xf000);
  memory.put(cegmon, 0xf800);

	acia.init();

  /* debugging
  machine.register_cpu_debug_handler([]() {
   return cpu.pc() >= 0x1000 && cpu.pc() < 0x2000;
  });
  */

  machine.reset();
}

void loop() {

	machine.run();
}
