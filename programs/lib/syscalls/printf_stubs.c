#include <stdarg.h>
#include <stddef.h>

int printf_(const char* format, ...) {}
int sprintf_(char* s, const char* format, ...) {}
int vsprintf_(char* s, const char* format, va_list arg) {}
int snprintf_(char* s, size_t n, const char* format, ...) {}
int vsnprintf_(char* s, size_t n, const char* format, va_list arg) {}
int vprintf_(const char* format, va_list arg) {}
