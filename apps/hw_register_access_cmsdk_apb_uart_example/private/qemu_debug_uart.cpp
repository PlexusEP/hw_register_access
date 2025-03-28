#include "qemu_debug_uart.hpp"

#include "cmsdk_apb_uart.hpp"

using namespace cmsdk_apb_uart;

namespace {                 // anonymous
Uart0RegSet uart0_reg_set;  //lint !e1756
}  // anonymous namespace

namespace qemu_debug_uart {

void Init() {
  // disable UART when changing configuration
  CtrlRegValue ctrl_value{0};
  uart0_reg_set.ctrl.write(ctrl_value.serialize());

  // 25MHz / 115200 = 217
  BaudDivRegValue bauddiv_value;
  bauddiv_value.at<BaudDivRegField::kBaudRateDiv>() = 217;
  uart0_reg_set.bauddiv.write(bauddiv_value.serialize());

  // Enable Tx
  ctrl_value.at<CtrlRegField::kTxEn>() = 1;
  uart0_reg_set.ctrl.write(ctrl_value.serialize());
}

}  // namespace qemu_debug_uart

extern "C" uint8_t UART_SendChar(uint8_t txchar) {  //lint !e8010 !e765
  if (txchar == 10) (void)UART_SendChar(13);

  // wait for TX buffer availability
  while (1) {  //lint !e716
    StateRegValue state_value{uart0_reg_set.state.read()};
    if (state_value.at<StateRegField::kTxBufferFull>() == 0) break;
  }

  XDataRegValue txdata_value{txchar};
  uart0_reg_set.txdata.write(txdata_value.serialize());

  return txchar;
}
