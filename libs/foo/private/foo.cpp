#include <iostream>

#include "bar/bar_public.hpp"
#include "foo_public.hpp"

namespace foo {

int MyClass::DoSomething() {
  std::cout << "Hello from foo!  Here's a number for you: " << bar::GetValue()
            << std::endl;
  return bar::GetValue();
}

}  // namespace foo
