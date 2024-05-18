# We do not install printf stuff anyway, so this just removes a warning
if (NOT DEFINED CMAKE_INSTALL_LIBDIR)
  set(CMAKE_INSTALL_LIBDIR "")
endif()

set(BUILD_STATIC_LIBRARY True)

# Configure library to be as small as possible
set(SUPPORT_DECIMAL_SPECIFIERS false)
set(SUPPORT_EXPONENTIAL_SPECIFIERS false)
set(SUPPORT_MSVC_STYLE_INTEGER_SPECIFIERS false)
set(SUPPORT_WRITEBACK_SPECIFIER false)
set(SUPPORT_LONG_LONG false)
set(CHECK_FOR_NUL_IN_FORMAT_SPECIFIER false)

#[[
We specify `EXCLUDE_FROM_ALL` because `printf` is its own standalone project.
Also, if a top-level CMakeLists.txt adds our SDK, it would add this one too.
Then running `make install` will also run `printf`'s install commands, which
we do not want.
]]
add_subdirectory(printf EXCLUDE_FROM_ALL)

#[[
The `printf` submodule implements the "printf familiy" suffized with an underscore,
like so: `printf_`, `sprintf_`. (See bottom of `./printf/src/printf/printf.c`)
Then it does `#define printf_ printf`, which is referred to as "aliasing" of 
function names in the documentation.

This is done in the header file using `#define`. However, that requires the header
file to always be included in source code that uses `printf`. It is better to
define these macros on the command line so they are always set.
]]
target_compile_definitions(printf PUBLIC 
  printf_=printf
  sprintf_=sprintf
  vsprintf_=vsprintf
  snprintf_=snprintf
  vsnprintf_=vsnprintf
  vprintf_=vprintf
)

target_compile_definitions(fp-sdk PUBLIC HAVE_PRINTF)
target_include_directories(fp-sdk PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/printf/src)
target_link_libraries(fp-sdk PUBLIC printf)
