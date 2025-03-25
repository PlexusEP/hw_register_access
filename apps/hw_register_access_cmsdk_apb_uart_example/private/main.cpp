#include "qemu_debug_uart.hpp"

int main(int, char *[]) {
  qemu_debug_uart::Init();
  return 0;
}
