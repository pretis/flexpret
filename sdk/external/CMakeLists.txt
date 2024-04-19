if (printf IN_LIST EXTERNAL_LIBS_USED)

  set(BUILD_STATIC_LIBRARY True)
  add_subdirectory(printf)
    
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
  target_link_libraries(fp-sdk-if INTERFACE printf)
endif()
