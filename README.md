# Hardware Register Access Library

## Summary

This library is intended to simplify and error-proof software interfacing to memory-mapped hardware registers (e.g. within a microprocessor or FPGA).  It is really just the combination of the [Portable Bitfields C++ library](https://github.com/KKoovalsky/PortableBitfields) and [Embedded Template Library io_port C++ library](https://www.etlcpp.com/io_port.html), melding the individual-field-centric access offered by Portable Bitfields with the various read and write behaviors provided by `io_port`.  This combination library also aligns terminology of each dependency more consistently with our existing Plexus lexicon by providing several aliases.

## Example Application(s)

The following applications within this repository provide usage examples for the Hardware Register Access Library.  The `PLXS_HW_REG_BUILD_EXAMPLE_APPLICATIONS` CMake option must be turned `ON` in order to build these applications.

* [Cortex-M System Design Kit APB UART](./apps/hw_register_access_cmsdk_apb_uart_example/readme.md)
