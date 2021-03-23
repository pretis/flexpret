
#include "pret.h"


int main(int argc, char *argv[])
{
  int h,l;
  get_time(h,l);
  add_ms(h,l,10);
  delay_until(h,l);

  return 0;
}
