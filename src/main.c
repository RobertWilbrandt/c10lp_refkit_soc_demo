#include <generated/csr.h>
#include <irq.h>
#include <stdio.h>
#include <uart.h>

// This program doesn't do too much when there are no LEDs
#ifndef CSR_LEDS_BASE
#error "SoC does not contain any LEDs"
#endif  // ifdef CSR_LEDS_BASE

void init(void);
void isr(void);

void init(void) {
#ifdef CONFIG_CPU_HAS_INTERRUPT
  irq_setmask(0);
  irq_setie(1);
#endif  // ifdef CONFIG_CPU_HAS_INTERRUPT

  uart_init();
}

void isr(void) {
#ifdef CONFIG_CPU_HAS_INTERRUPT
  unsigned int irqs = irq_pending() & irq_getmask();

#ifndef UART_POLLING
  if (irqs & (1 << UART_INTERRUPT)) {
    uart_isr();
  }
#endif  // ifndef UART_POLLING
#endif  // ifdef CONFIG_CPU_HAS_INTERRUPT
}

int main(void) {
  init();

  while (1) {
    for (size_t i = 0; i < 4; ++i) {
      leds_out_write(1 << i);
      printf("LED %d\n", i);

      busy_wait(1000);
    }
  }

  return 0;
}
