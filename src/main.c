#include <locale.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <notcurses/notcurses.h>
#include "ui.h"


int
main(void)
{
    /* recommended for proper Unicode handling */
    setlocale(LC_ALL, "");

    struct notcurses_options opts = {0};
    opts.loglevel = NCLOGLEVEL_WARNING;
    /* leave flags = 0 for "full-screen app" behavior; can switch to
       NCOPTION_CLI_MODE if you want to behave more like a CLI. */

    struct notcurses *nc = notcurses_init(&opts, NULL);
    if (!nc) {
        fprintf(stderr, "notcurses_init() failed\n");
        return EXIT_FAILURE;
    }

    struct app_ui ui;
    if (ui_init(&ui, nc) != 0) {
        fprintf(stderr, "ui_init() failed\n");
        notcurses_stop(nc);
        return EXIT_FAILURE;
    }

    /* Enable mouse events (move + button + drag) */
    if (notcurses_mice_enable(nc, NCMICE_ALL_EVENTS) != 0) {
        fprintf(stderr, "warning: could not enable mouse events\n");
    }

    ui_draw(&ui);

    bool running = true;
    while (running) {
        struct ncinput ni;
        uint32_t id = notcurses_get_blocking(nc, &ni);

        if (id == (uint32_t)-1) {
            /* error */
            break;
        }
        if (id == 0) {
            /* timeout, if we used non-blocking (we don't here) */
            continue;
        }

        if (id == 'q' || id == 'Q' || id == NCKEY_ESC) {
            running = false;
            break;
        }

        if (id == NCKEY_RESIZE) {
            ui_resize(&ui);
            ui_draw(&ui);
            continue;
        }

        if (nckey_mouse_p(id) && ni.evtype == NCTYPE_PRESS) {
            ui_handle_click(&ui, ni.y, ni.x);
            continue;
        }

        /* Placeholder: later we can map keys to actions (tabs, panes, etc.) */
    }

    ui_shutdown(&ui);
    notcurses_stop(nc);

    return EXIT_SUCCESS;
}