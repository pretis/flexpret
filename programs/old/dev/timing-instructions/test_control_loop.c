
#include "pret.h"

void compute_task()
{
}

void missed_deadline_handler()
{
}


int main(int argc, char *argv[])
{

int h,l;               // High and low 32-bit time values
get_time(h,l);         // Current time in nano seconds
while(1){              // Repeat control loop forever
  add_ms(h,l,10);      // Add 10ms 
  exception_on_expire(h,l,missed_deadline_handler);
                       // Upper timing bound. Exception handler
  compute_task();      // Sense, compute, and actuate 
  delay_until(h,l);    // Delay until start of next period
}

  return 0;
}
