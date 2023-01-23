#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>

static void gpio_setup(void) {
    /* Enable GPIOC clock. */
    /* Manually: */
    // RCC_APB2ENR |= RCC_APB2ENR_IOPCEN;
    /* Using API functions: */
    rcc_periph_clock_enable(RCC_GPIOC);

    /* Set GPIO13 (in GPIO port C) to 'output push-pull'. */
    /* Manually: */
    // GPIOC_CRH = (GPIO_CNF_OUTPUT_PUSHPULL << (((12 - 8) * 4) + 2));
    // GPIOC_CRH |= (GPIO_MODE_OUTPUT_2_MHZ << ((12 - 8) * 4));
    /* Using API functions: */
    gpio_set_mode(GPIOC, GPIO_MODE_OUTPUT_2_MHZ, GPIO_CNF_OUTPUT_PUSHPULL,
                  GPIO13);
}

int main(void) {
    int i;

    gpio_setup();

    /* Blink the LED (PC13) on the board. */
    while (1) {
        /* Manually: */
        // GPIOC_BSRR = GPIO12;		/* LED off */
        // for (i = 0; i < 800000; i++)	/* Wait a bit. */
        // 	__asm__("nop");
        // GPIOC_BRR = GPIO12;		/* LED on */
        // for (i = 0; i < 800000; i++)	/* Wait a bit. */
        // 	__asm__("nop");

        /* Using API functions gpio_set()/gpio_clear(): */
        // gpio_set(GPIOC, GPIO12);	/* LED off */
        // for (i = 0; i < 800000; i++)	/* Wait a bit. */
        // 	__asm__("nop");
        // gpio_clear(GPIOC, GPIO12);	/* LED on */
        // for (i = 0; i < 800000; i++)	/* Wait a bit. */
        // 	__asm__("nop");

        /* Using API function gpio_toggle(): */
        gpio_toggle(GPIOC, GPIO13);  /* LED on/off */
        for (i = 0; i < 800000; i++) /* Wait a bit. */
            __asm__("nop");
    }

    return 0;
}
