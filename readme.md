# Hardware Register Access Library

## Summary

This library is intended to simplify and error-proof software interfacing to memory-mapped hardware registers (e.g. within a microprocessor or FPGA).  It is really just the combination of the [Portable Bitfields C++ library](https://github.com/KKoovalsky/PortableBitfields) and [Embedded Template Library io_port C++ library](https://www.etlcpp.com/io_port.html), melding the individual-field-centric access offered by Portable Bitfields with the various read and write behaviors provided by `io_port`.  This combination library also aligns terminology of each dependency more consistently with our existing Plexus lexicon by providing several aliases.

## Typical Usage

``` cpp
// MyReg field IDs
enum class MyRegField {
  ... IDs of other fields in the State register ...
  kField1,
  kUnused
};

// declaration of MyReg value type
using MyRegValue = plxs::HwRegValue<uint32_t,
  plxs::HwRegField<StateRegField::kUnused, 28>,
  plxs::HwRegField<StateRegField::kField1, 1>,
  ... other fields in MyReg ...
>;

// declaration of the set of registers making up MyPeriph, assigned addresses relative to some base
template <uintptr_t address>
struct MyPeriphRegSet {
  ...
  plxs::HwRegRW<MyRegValue::Type, address + 4> myreg;
  ...
};

// declaration of the type for the register set for the 0th instance of MyPeriph peripheral
using MyPeriph0RegSet = MyPeriphRegSet<0x40004000>;

// instantiate register set for 0th instance of MyPeriph
MyPeriph0RegSet myperiph0_reg_set;

// example read
MyRegValue myreg_value{myperiph0_reg_set.myreg.read()};

// example write
myreg_value.at<MyRegField::kField1>() = 1;
myperiph0_reg_set.myreg.write(myreg_value.serialize());
```

## Example Application(s)

The following applications within this repository provide usage examples for the Hardware Register Access Library.

* [Cortex-M System Design Kit APB UART](./apps/hw_register_access_cmsdk_apb_uart_example/readme.md)

## Incorporating Into Your Project

CMake Package Manager (CPM) is recommended to incorporate this Hardware Register Access Library.  Use whatever `GIT_TAG` option is appropriate for your project.

```
include(CPM)

CPMAddPackage(
    NAME HwRegAccess
    GIT_REPOSITORY https://github.com/PlexusEP/hw_register_access.git
    GIT_TAG v1.0.0
)

target_link_libraries(your_target
    PRIVATE
        hw_register_access
)
```

And since this library is header-only, simply include the one-and-only header and start using it!

```
#include "hw_register_access/hw_register_access.hpp"
```

## Updating This Library

When updating this library, make sure it remains lint-free, conforms to style guidelines, etc.  To facilitate such updates, the development environment containing all the necessary tools has been containerized.  See the [C++ Project Template documentation](https://eng.plexus.com/git/pages/EP/cpp-project-template/site/browse/) for more information about containerization and the workflows available for performing various tasks using this environment.
