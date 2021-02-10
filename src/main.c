#include <generated/csr.h>
#include <irq.h>
#include <stdio.h>
#include <uart.h>

#define SWITCH_MASK ((1 << 5) - 1)

// This program doesn't do too much when there are no LEDs
#ifndef CSR_LEDS_BASE
#error "SoC does not contain any LEDs"
#endif  // ifdef CSR_LEDS_BASE

void init(void);
void isr(void);

uint32_t number_to_segments[] = {0x3F, 0x06, 0x5B, 0x4F, 0x66,
                                 0x6D, 0x7D, 0x07, 0x7F, 0x6F};

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

  int led_state = 0;  // All leds off initially
  int last_switches = 0;

  int cur_led = 0;

  segment_display_s0_write(0);
  segment_display_s1_write(0);
  segment_display_s2_write(0);
  segment_display_s3_write(0);

  while (1) {
    int switches = (~switches_in_read()) & SWITCH_MASK;

    int diff = last_switches ^ switches;
    int pressed = diff & switches;

    last_switches = switches;

    // A button was pressed
    if (pressed & ((1 << 5) - 1)) {
      printf("button press: %d\n", pressed);
    }

    // Update LEDs
    led_state ^= pressed;
    leds_out_write(led_state);

    // Write number set from buttons to segment display
    segment_display_s0_write(number_to_segments[led_state % 10]);
    segment_display_s1_write(number_to_segments[led_state / 10]);

    // Small chaser on GPIO LEDs
    gpio_leds_out_write(1 << cur_led);

    busy_wait(100);

    if (++cur_led > 7) {
      cur_led = 0;
    }
  }

  return 0;
}
