#ifndef hw_register_access_HPP
#define hw_register_access_HPP

#include <etl/io_port.h>

#include <jungles/bitfields.hpp>

namespace plxs {

//lint -e{1790} inherit to add nested alias for T
template <typename T, typename... Fields>
class HwRegValue : public jungles::Bitfields<T, Fields...> {
 public:
  using Type = T;  // this type alias is the reason for this subclass
  using jungles::Bitfields<T, Fields...>::
      Bitfields;  // bring along the constructors from the base class
};

template <auto id, unsigned size>
using HwRegField = jungles::Field<id, size>;

template <typename T, uintptr_t address>
using HwRegRO = etl::io_port_ro<T, address>;

template <typename T, uintptr_t address>
using HwRegWO = etl::io_port_wo<T, address>;

template <typename T, uintptr_t address>
using HwRegRW = etl::io_port_rw<T, address>;

}  // namespace plxs

#endif  // hw_register_access_HPP
