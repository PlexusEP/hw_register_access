# Hardware Register Access Library

This library is intended to simplify and make more robust software interfacing to hardware (microprocessor or FPGA) registers.  It is really just the combination of the [Portable Bitfields C++ library](https://github.com/KKoovalsky/PortableBitfields) and [Embedded Template Library io_port C++ library](https://www.etlcpp.com/io_port.html), melding the individual-field-centric access offered by Portable Bitfields with the various read and write behaviors provided by `io_port`.  In the process, this combination library aligns terminology of each dependency more consistently with our existing Plexus lexicon.

## Example: Cortex-M System Design Kit APB UART

### Registers and Fields Declared in cmsdk_apb_uart.hpp

``` cpp
#ifndef CMSDK_APB_UART_HPP
#define CMSDK_APB_UART_HPP

#include <cstdint>

#include "hw_register_access/hw_register_access.hpp"

//lint -save
//lint -e758 -e768 unreferenced globals

namespace cmsdk_apb_uart {

// clang-format off

using UnderlyingType = uint32_t;

// XData register type
enum class XDataFields { 
    kData,
    kUnused
};
using XDataRegister = plxs::hw_reg_data<UnderlyingType,
  plxs::hw_reg_field<XDataFields::kUnused, 24>,
  plxs::hw_reg_field<XDataFields::kData, 8>>;

// State register type
enum class StateFields {
  kTxBufferFull,
  kRxBufferFull,
  kTxBufferOverrun,
  kRxBufferOverrun,
  kUnused
};
using StateRegister = plxs::hw_reg_data<UnderlyingType,
  plxs::hw_reg_field<StateFields::kUnused, 28>,
  plxs::hw_reg_field<StateFields::kRxBufferOverrun, 1>,
  plxs::hw_reg_field<StateFields::kTxBufferOverrun, 1>,
  plxs::hw_reg_field<StateFields::kRxBufferFull, 1>,
  plxs::hw_reg_field<StateFields::kTxBufferFull, 1>>;

// Ctrl register type
enum class CtrlFields {
  kTxEn,
  kRxEn,
  kTxIntEn,
  kRxIntEn,
  kTxOvrIntEn,
  kRxOvrIntEn,
  kTxHighSpeedTestMode,
  kUnused
};
using CtrlRegister = plxs::hw_reg_data<UnderlyingType,
  plxs::hw_reg_field<CtrlFields::kUnused, 25>,
  plxs::hw_reg_field<CtrlFields::kTxHighSpeedTestMode, 1>,
  plxs::hw_reg_field<CtrlFields::kRxOvrIntEn, 1>,
  plxs::hw_reg_field<CtrlFields::kTxOvrIntEn, 1>,
  plxs::hw_reg_field<CtrlFields::kRxIntEn, 1>,
  plxs::hw_reg_field<CtrlFields::kTxIntEn, 1>,
  plxs::hw_reg_field<CtrlFields::kRxEn, 1>,
  plxs::hw_reg_field<CtrlFields::kTxEn, 1>>;

// IntStatClr register type
enum class IntStatClrFields {
  kTxInt,
  kRxInt,
  kTxOvrInt,
  kRxOvrInt,
  kUnused
};
using IntStatClrRegister = plxs::hw_reg_data<UnderlyingType,
  plxs::hw_reg_field<IntStatClrFields::kUnused, 28>,
  plxs::hw_reg_field<IntStatClrFields::kRxOvrInt, 1>,
  plxs::hw_reg_field<IntStatClrFields::kTxOvrInt, 1>,
  plxs::hw_reg_field<IntStatClrFields::kRxInt, 1>,
  plxs::hw_reg_field<IntStatClrFields::kTxInt, 1>>;

// BaudDiv register type
enum class BaudDivFields {
  kBaudRateDiv,
  kUnused
};
using BaudDivRegister = plxs::hw_reg_data<UnderlyingType,
  plxs::hw_reg_field<BaudDivFields::kUnused, 12>,
  plxs::hw_reg_field<BaudDivFields::kBaudRateDiv, 20>>;

// see Cortex-M System Design Kit Technical Reference Manual, APB UART,
// Programmers model
template <uintptr_t address>
struct RegisterSet {
  plxs::hw_reg_ro<UnderlyingType, address> rxdata;  // same address as txdata
  plxs::hw_reg_wo<UnderlyingType, address> txdata;        // same address as rxdata
  plxs::hw_reg_rw<UnderlyingType, address + 4> state;
  plxs::hw_reg_rw<UnderlyingType, address + 8> ctrl;
  plxs::hw_reg_rw<UnderlyingType, address + 12> intstatclr;
  plxs::hw_reg_rw<UnderlyingType, address + 16> bauddiv;
};

constexpr uintptr_t kUart0Base{0x40004000};
constexpr uintptr_t kUart1Base{0x40005000};
constexpr uintptr_t kUart2Base{0x40006000};
constexpr uintptr_t kUart3Base{0x40007000};
constexpr uintptr_t kUart4Base{0x40009000};

// clang-format on

}  // namespace cmsdk_apb_uart

//lint -restore

#endif  // CMSDK_APB_UART_HPP
```

### Usage Illustrated in Example qemu_debug_uart.cpp

``` cpp
#include "qemu_debug_uart.hpp"

#include "cmsdk_apb_uart.hpp"

namespace {  // anonymous
cmsdk_apb_uart::RegisterSet<cmsdk_apb_uart::kUart0Base>
    uart0_register_set;  //lint !e1756
}  // anonymous namespace

namespace qemu_debug_uart {

void Init() {
  // disable UART when changing configuration
  cmsdk_apb_uart::CtrlRegister ctrl{0};
  uart0_register_set.ctrl.write(ctrl.serialize());

  // 25MHz / 115200 = 217
  cmsdk_apb_uart::BaudDivRegister bauddiv;
  bauddiv.at<cmsdk_apb_uart::BaudDivFields::kBaudRateDiv>() = 217;
  uart0_register_set.bauddiv.write(bauddiv.serialize());

  // Enable Tx
  ctrl.at<cmsdk_apb_uart::CtrlFields::kTxEn>() = 1;
  uart0_register_set.ctrl.write(ctrl.serialize());
}

extern "C" uint8_t UART_SendChar(uint8_t txchar) {  //lint !e8010
  if (txchar == 10) (void)UART_SendChar(13);

  // wait for TX buffer availability
  while (1) {  //lint !e716
    cmsdk_apb_uart::StateRegister state{uart0_register_set.state.read()};
    if (state.at<cmsdk_apb_uart::StateFields::kTxBufferFull>() == 0) break;
  }

  cmsdk_apb_uart::XDataRegister txdata{txchar};
  uart0_register_set.txdata.write(txdata.serialize());

  return txchar;
}

}  // namespace qemu_debug_uart
```
