# TODO: Condition for adding
if (True)

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

  target_link_libraries(${PROJECT_NAME} printf)
endif()
