#include "qemu_debug_uart.hpp"

#include "cmsdk_apb_uart.hpp"

using namespace cmsdk_apb_uart;

namespace {                                  // anonymous
RegisterSet<kUart0Base> uart0_register_set;  //lint !e1756
}  // anonymous namespace

namespace qemu_debug_uart {

void Init() {
  // disable UART when changing configuration
  CtrlRegister ctrl{0};
  uart0_register_set.ctrl.write(ctrl.serialize());

  // 25MHz / 115200 = 217
  BaudDivRegister bauddiv;
  bauddiv.at<BaudDivFields::kBaudRateDiv>() = 217;
  uart0_register_set.bauddiv.write(bauddiv.serialize());

  // Enable Tx
  ctrl.at<CtrlFields::kTxEn>() = 1;
  uart0_register_set.ctrl.write(ctrl.serialize());
}

}  // namespace qemu_debug_uart

extern "C" uint8_t UART_SendChar(uint8_t txchar) {  //lint !e8010 !e765
  if (txchar == 10) (void)UART_SendChar(13);

  // wait for TX buffer availability
  while (1) {  //lint !e716
    StateRegister state{uart0_register_set.state.read()};
    if (state.at<StateFields::kTxBufferFull>() == 0) break;
  }

  XDataRegister txdata{txchar};
  uart0_register_set.txdata.write(txdata.serialize());

  return txchar;
}
