#include <locale.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <notcurses/notcurses.h>
#include "ui.h"

int main(void)
{
    setlocale(LC_ALL, "");

    struct notcurses_options opts = {0};
    opts.loglevel = NCLOGLEVEL_ERROR;  /* Reduce logging */
    opts.flags = NCOPTION_SUPPRESS_BANNERS
               | NCOPTION_DRAIN_INPUT
               | NCOPTION_PRESERVE_CURSOR
               | NCOPTION_NO_ALTERNATE_SCREEN;  /* Try alternate screen off */

    struct notcurses *nc = notcurses_init(&opts, stdout);
    if (!nc) {
        fprintf(stderr, "notcurses_init failed\n");
        fprintf(stderr, "Press Enter to exit...\n");
        getchar();
        return EXIT_FAILURE;
    }

    struct app_ui ui;
    if (ui_init(&ui, nc) != 0) {
        fprintf(stderr, "ui_init failed\n");
        notcurses_stop(nc);
        return EXIT_FAILURE;
    }

    /* Try different mouse mode - just button press events */
    notcurses_mice_enable(nc, NCMICE_BUTTON_EVENT);

    ui_draw(&ui);

    bool running = true;
    while (running) {
        struct ncinput ni;
        uint32_t id = notcurses_get_blocking(nc, &ni);

        if (id == (uint32_t)-1) break;
        if (id == 0) continue;

        if (id == 'q' || id == 'Q' || id == NCKEY_ESC) {
            running = false;
            break;
        }

        if (id == NCKEY_RESIZE) {
            ui_resize(&ui);
            ui_draw(&ui);
            continue;
        }

        /* Check for ANY mouse event (not just press) */
        if (nckey_mouse_p(id)) {
            ui_handle_click(&ui, ni.y, ni.x);
            continue;
        }
    }

    notcurses_mice_disable(nc);
    ui_shutdown(&ui);
    notcurses_stop(nc);

    return EXIT_SUCCESS;
}
