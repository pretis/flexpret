
#include "pret.h"

int val = 0;

void exception_test()
{
    //mtpcr(30,1);
  val = 5;  // If exception expires, the program returns 5.
}

int main(int argc, char *argv[])
{
  int h,l;
  get_time(h,l);         //Get time

  add_ns(h,l,500);       //Make it expire in 500 micro seconds
  exception_on_expire(h,l,exception_test);  
  deactive_exception();
  active_exception();

  thread_sleep();        //Put the thread to sleep

  deactive_exception();  //Deactive exception. Will do nothing.
  return val;
}
