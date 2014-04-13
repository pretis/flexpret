
//#include <stdio.h>

#define UART_COUT 0xFFFF0008
#define UART_DOUT 0xFFFF000C

//char __printfstr[80*4];

void uart_outputchar(char c)
{
  volatile char* uart_cout = (char*) UART_COUT;
  volatile char* uart_dout = (char*) UART_DOUT;
  while(*uart_cout != 0);
  *uart_dout = c;
}

void uart_outputstr(char* str)
{
  while(*str != 0){
    uart_outputchar(*str);
    str++;
  }
}

char qbuf[9];
char* itoa(n)
unsigned int n;
{
    register int i;
    for(i = 7; i >= 0; i--) {
        qbuf[i] = (n & 15) + 48;
        if(qbuf[i] >= 58) {
            qbuf[i] += 7;
        }
        n = n >> 4;
    }
    qbuf[8] = '\0';
    return(qbuf);
}
//int next;
//char qbuf[8];
//
//char* itoa(n)
//int n;
//{
//register int r, k;
//int flag = 0;
//next = 0;
//if (n < 0) {
//        qbuf[next++] = '-';
//         n = -n;
//}
//   if (n == 0) {
//         qbuf[next++] = '0';
//   } else {
//         k = 10000;
//         while (k > 0) {
//                 r = n / k;
//                 if (flag || r > 0) {
//                         qbuf[next++] = '0' + r;
//                         flag = 1;
//                 }
//                 n -= r * k;
//                 k = k / 10;
//         }
//   }
//   qbuf[next] = 0;
//   return(qbuf);
// }
//

char* hex(unsigned int n)
{
  int i,k;
  for(i=32-4, k=0; i>=0; i -= 4, k++){
    unsigned int a = (n >> i) & 0xf;
    if(a <= 9) 
      qbuf[k] = a + '0';
    else 
      qbuf[k] = a + 'a' - 10;
  } 
  qbuf[k] = 0;
  return qbuf;
}

#ifdef PRET_PC_STDIO
  #define debug_string(s) printf("%s", s);

#else
  #define debug_string(s) uart_outputstr(s);
  #define printf(str) uart_outputstr(str);
#endif
