#ifndef foo_PUBLIC_HPP
#define foo_PUBLIC_HPP

namespace foo {

//lint -esym(1502,foo::MyClass)
class MyClass {
 public:
  int DoSomething();
};

}  // namespace foo

#endif  // foo_PUBLIC_HPP
