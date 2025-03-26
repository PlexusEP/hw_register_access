#include <gmock/gmock.h>
#include <gtest/gtest.h>

#include "foo/foo_public.hpp"

TEST(foo, MyTest) {
  foo::MyClass mc;
  auto val{mc.DoSomething()};
  EXPECT_EQ(val, 24);  // note equality to the *fake* implementation
}
