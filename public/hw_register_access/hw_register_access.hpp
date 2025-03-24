#ifndef hw_register_access_HPP
#define hw_register_access_HPP

#include <etl/io_port.h>

#include <jungles/bitfields.hpp>

namespace plxs {

// aliases for jungles/bitfields types

template <typename UnderlyingType, typename... Fields>
using hw_reg_data = jungles::Bitfields<UnderlyingType, Fields...>;

template <auto Id, unsigned Size>
using hw_reg_field = jungles::Field<Id, Size>;

// wrappers for etl/io_port behavior

template <typename T, uintptr_t Address>
using hw_reg_ro = etl::io_port_ro<T, Address>;

template <typename T, uintptr_t Address>
using hw_reg_wo = etl::io_port_wo<T, Address>;

template <typename T, uintptr_t Address>
using hw_reg_rw = etl::io_port_rw<T, Address>;

}  // namespace plxs

#endif  // hw_register_access_HPP
