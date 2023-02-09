#ifndef FLEXPRET_PRINTER_H
#define FLEXPRET_PRINTER_H

typedef struct {
    int port;
    int pin;
    int baudrate;
} fp_printer_config_t;

void fp_printer_run(fp_printer_config_t *cfg);

void fp_printer_int(int val);

void fp_printer_str(const char str[]);

#endif