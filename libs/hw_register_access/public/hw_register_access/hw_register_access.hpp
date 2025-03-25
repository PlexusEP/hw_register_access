#ifndef hw_register_access_HPP
#define hw_register_access_HPP

#include <etl/io_port.h>

#include <jungles/bitfields.hpp>

namespace plxs {

// aliases for jungles/bitfields types

template <typename UnderlyingType, typename... Fields>
using HwRegData = jungles::Bitfields<UnderlyingType, Fields...>;

template <auto id, unsigned size>
using HwRegField = jungles::Field<id, size>;

// wrappers for etl/io_port behavior

template <typename T, uintptr_t address>
using HwRegRO = etl::io_port_ro<T, address>;

template <typename T, uintptr_t address>
using HwRegWO = etl::io_port_wo<T, address>;

template <typename T, uintptr_t address>
using HwRegRW = etl::io_port_rw<T, address>;

}  // namespace plxs

#endif  // hw_register_access_HPP
