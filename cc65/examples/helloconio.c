#include <conio.h>

int main() {
	clrscr();

	// Test Absolute Positioning
	gotoxy(10, 5);
	cputs("CONIO TEST");

	// Test Relative Printing
	gotoxy(10, 7);
	cputs("Press any key to exit...");

	// Wait for keyboard input
	cgetc();

	clrscr();
	return 0;
}
