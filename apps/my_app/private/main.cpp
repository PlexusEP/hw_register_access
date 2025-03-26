#include <gitversion/version.h>

#include <boost/program_options.hpp>
#include <iostream>

#include "foo/foo_public.hpp"

namespace po = boost::program_options;

namespace {
void PrintVersionInfo() {
  // generated version information
  std::cout << "Version:\t\t" << version::VERSION_STRING << std::endl;
  std::cout << " Tag:\t\t\t" << version::GIT_TAG_NAME << std::endl;
  std::cout << " Is Stable:\t\t" << version::IS_STABLE_VERSION << std::endl;
  std::cout << " Commit ID:\t\t" << version::GIT_COMMIT_ID << std::endl;
  std::cout << " Commits Since Tag:\t" << version::GIT_COMMITS_SINCE_TAG
            << std::endl;
  std::cout << std::endl;
}

void UseFoo() {
  foo::MyClass my_class;
  (void)my_class.DoSomething();
}
}  // anonymous namespace

int main(int argc, char* argv[]) {
  std::string input_name;
  auto input_name_value{po::value(&input_name)->default_value("you")};

  po::options_description desc{"Allowed options"};
  desc.add_options()("name", input_name_value, "input name");
  desc.add_options()("help,h", "display this help and exit");
  desc.add_options()("version,v", "output version information and exit");
  desc.add_options()("foo,f", "use the foo library and exit");

  po::positional_options_description pos_desc;
  (void)pos_desc.add("name", 1);

  //lint -e{1793} builder pattern
  auto options{po::command_line_parser(argc, argv)
                   .allow_unregistered()
                   .options(desc)
                   .positional(pos_desc)
                   .run()};

  po::variables_map vm;
  po::store(options, vm);
  po::notify(vm);

  if (vm.contains("help")) {
    std::cout << desc << std::endl;
  } else if (vm.contains("version")) {
    PrintVersionInfo();
  } else {
    std::cout << "Your name is: " << input_name << "!" << std::endl;
    UseFoo();
  }
}
