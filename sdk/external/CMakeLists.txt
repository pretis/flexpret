if (True)

  set(BUILD_STATIC_LIBRARY True)
  add_subdirectory(printf)
    
  target_compile_definitions(printf PUBLIC 
    printf_=printf
    
  )
  target_link_libraries(${PROJECT_NAME} printf)
endif()

# TODO: Add and configure