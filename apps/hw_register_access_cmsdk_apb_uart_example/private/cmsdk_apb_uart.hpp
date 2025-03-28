#ifndef CMSDK_APB_UART_HPP
#define CMSDK_APB_UART_HPP

#include <cstdint>

#include "hw_register_access/hw_register_access.hpp"

//lint -save
//lint -e758 -e768 unreferenced globals

namespace cmsdk_apb_uart {

// clang-format off

enum class XDataRegField { 
    kData,
    kUnused
};
using XDataRegValue = plxs::HwRegValue<uint32_t,
  plxs::HwRegField<XDataRegField::kUnused, 24>,
  plxs::HwRegField<XDataRegField::kData, 8>>;

// State register type
enum class StateRegField {
  kTxBufferFull,
  kRxBufferFull,
  kTxBufferOverrun,
  kRxBufferOverrun,
  kUnused
};
using StateRegValue = plxs::HwRegValue<uint32_t,
  plxs::HwRegField<StateRegField::kUnused, 28>,
  plxs::HwRegField<StateRegField::kRxBufferOverrun, 1>,
  plxs::HwRegField<StateRegField::kTxBufferOverrun, 1>,
  plxs::HwRegField<StateRegField::kRxBufferFull, 1>,
  plxs::HwRegField<StateRegField::kTxBufferFull, 1>>;

// Ctrl register type
enum class CtrlRegField {
  kTxEn,
  kRxEn,
  kTxIntEn,
  kRxIntEn,
  kTxOvrIntEn,
  kRxOvrIntEn,
  kTxHighSpeedTestMode,
  kUnused
};
using CtrlRegValue = plxs::HwRegValue<uint32_t,
  plxs::HwRegField<CtrlRegField::kUnused, 25>,
  plxs::HwRegField<CtrlRegField::kTxHighSpeedTestMode, 1>,
  plxs::HwRegField<CtrlRegField::kRxOvrIntEn, 1>,
  plxs::HwRegField<CtrlRegField::kTxOvrIntEn, 1>,
  plxs::HwRegField<CtrlRegField::kRxIntEn, 1>,
  plxs::HwRegField<CtrlRegField::kTxIntEn, 1>,
  plxs::HwRegField<CtrlRegField::kRxEn, 1>,
  plxs::HwRegField<CtrlRegField::kTxEn, 1>>;

// IntStatClr register type
enum class IntStatClrRegField {
  kTxInt,
  kRxInt,
  kTxOvrInt,
  kRxOvrInt,
  kUnused
};
using IntStatClrRegValue = plxs::HwRegValue<uint32_t,
  plxs::HwRegField<IntStatClrRegField::kUnused, 28>,
  plxs::HwRegField<IntStatClrRegField::kRxOvrInt, 1>,
  plxs::HwRegField<IntStatClrRegField::kTxOvrInt, 1>,
  plxs::HwRegField<IntStatClrRegField::kRxInt, 1>,
  plxs::HwRegField<IntStatClrRegField::kTxInt, 1>>;

// BaudDiv register type
enum class BaudDivRegField {
  kBaudRateDiv,
  kUnused
};
using BaudDivRegValue = plxs::HwRegValue<uint32_t,
  plxs::HwRegField<BaudDivRegField::kUnused, 12>,
  plxs::HwRegField<BaudDivRegField::kBaudRateDiv, 20>>;

// see "Cortex-M System Design Kit Technical Reference Manual", APB UART,
// Programmers model
template <uintptr_t address>
struct UartRegSet {
  plxs::HwRegRO<XDataRegValue::Type, address> rxdata;  // same address as txdata
  plxs::HwRegWO<XDataRegValue::Type, address> txdata;        // same address as rxdata
  plxs::HwRegRW<StateRegValue::Type, address + 4> state;
  plxs::HwRegRW<CtrlRegValue::Type, address + 8> ctrl;
  plxs::HwRegRW<IntStatClrRegValue::Type, address + 12> intstatclr;
  plxs::HwRegRW<BaudDivRegValue::Type, address + 16> bauddiv;
};

// see section 3.6 CMSDK APB subsystem of "Application Note AN386, ARM Cortex-M4 SMM on V2M-MPS2"
using Uart0RegSet = UartRegSet<0x40004000>;
using Uart1RegSet = UartRegSet<0x40005000>;
using Uart2RegSet = UartRegSet<0x40006000>;
using Uart3RegSet = UartRegSet<0x40007000>;
using Uart4RegSet = UartRegSet<0x40009000>;

// clang-format on

}  // namespace cmsdk_apb_uart

//lint -restore

#endif  // CMSDK_APB_UART_HPP
