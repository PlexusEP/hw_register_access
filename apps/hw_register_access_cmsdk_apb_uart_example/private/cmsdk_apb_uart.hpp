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
using XDataRegister = plxs::HwRegData<UnderlyingType,
  plxs::HwRegField<XDataFields::kUnused, 24>,
  plxs::HwRegField<XDataFields::kData, 8>>;

// State register type
enum class StateFields {
  kTxBufferFull,
  kRxBufferFull,
  kTxBufferOverrun,
  kRxBufferOverrun,
  kUnused
};
using StateRegister = plxs::HwRegData<UnderlyingType,
  plxs::HwRegField<StateFields::kUnused, 28>,
  plxs::HwRegField<StateFields::kRxBufferOverrun, 1>,
  plxs::HwRegField<StateFields::kTxBufferOverrun, 1>,
  plxs::HwRegField<StateFields::kRxBufferFull, 1>,
  plxs::HwRegField<StateFields::kTxBufferFull, 1>>;

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
using CtrlRegister = plxs::HwRegData<UnderlyingType,
  plxs::HwRegField<CtrlFields::kUnused, 25>,
  plxs::HwRegField<CtrlFields::kTxHighSpeedTestMode, 1>,
  plxs::HwRegField<CtrlFields::kRxOvrIntEn, 1>,
  plxs::HwRegField<CtrlFields::kTxOvrIntEn, 1>,
  plxs::HwRegField<CtrlFields::kRxIntEn, 1>,
  plxs::HwRegField<CtrlFields::kTxIntEn, 1>,
  plxs::HwRegField<CtrlFields::kRxEn, 1>,
  plxs::HwRegField<CtrlFields::kTxEn, 1>>;

// IntStatClr register type
enum class IntStatClrFields {
  kTxInt,
  kRxInt,
  kTxOvrInt,
  kRxOvrInt,
  kUnused
};
using IntStatClrRegister = plxs::HwRegData<UnderlyingType,
  plxs::HwRegField<IntStatClrFields::kUnused, 28>,
  plxs::HwRegField<IntStatClrFields::kRxOvrInt, 1>,
  plxs::HwRegField<IntStatClrFields::kTxOvrInt, 1>,
  plxs::HwRegField<IntStatClrFields::kRxInt, 1>,
  plxs::HwRegField<IntStatClrFields::kTxInt, 1>>;

// BaudDiv register type
enum class BaudDivFields {
  kBaudRateDiv,
  kUnused
};
using BaudDivRegister = plxs::HwRegData<UnderlyingType,
  plxs::HwRegField<BaudDivFields::kUnused, 12>,
  plxs::HwRegField<BaudDivFields::kBaudRateDiv, 20>>;

// see Cortex-M System Design Kit Technical Reference Manual, APB UART,
// Programmers model
template <uintptr_t address>
struct RegisterSet {
  plxs::HwRegRO<UnderlyingType, address> rxdata;  // same address as txdata
  plxs::HwRegWO<UnderlyingType, address> txdata;        // same address as rxdata
  plxs::HwRegRW<UnderlyingType, address + 4> state;
  plxs::HwRegRW<UnderlyingType, address + 8> ctrl;
  plxs::HwRegRW<UnderlyingType, address + 12> intstatclr;
  plxs::HwRegRW<UnderlyingType, address + 16> bauddiv;
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
