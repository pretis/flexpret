# We do not install printf stuff anyway, so this just removes a warning
if (NOT DEFINED CMAKE_INSTALL_LIBDIR)
  set(CMAKE_INSTALL_LIBDIR "")
endif()

set(BUILD_STATIC_LIBRARY True)
add_subdirectory(printf EXCLUDE_FROM_ALL)
  
target_compile_definitions(printf PUBLIC 
  printf_=printf
  sprintf_=sprintf
  vsprintf_=vsprintf
  snprintf_=snprintf
  vsnprintf_=vsnprintf
  vprintf_=vprintf
)

target_compile_definitions(fp-sdk-if INTERFACE HAVE_PRINTF)
target_include_directories(fp-sdk-if INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/printf/src)
target_link_libraries(fp-sdk INTERFACE printf)
