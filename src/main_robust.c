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

    /* Try to initialize with multiple configurations */
    struct notcurses *nc = NULL;
    struct app_ui ui;

    /* First attempt: standard settings */
    struct notcurses_options opts = {0};
    opts.loglevel = NCLOGLEVEL_ERROR;
    opts.flags = NCOPTION_SUPPRESS_BANNERS
               | NCOPTION_DRAIN_INPUT
               | NCOPTION_NO_WINCH_SIGHANDLER;
    
    /* Try initializing */
    nc = notcurses_init(&opts, stdout);
    
    if (!nc) {
        fprintf(stderr, "\nERROR: notcurses_init failed\n");
        fprintf(stderr, "Press Enter to exit...\n");
        getchar();
        return EXIT_FAILURE;
    }

    /* Try to initialize UI */
    if (ui_init(&ui, nc) != 0) {
        fprintf(stderr, "\nERROR: ui_init failed\n");
        notcurses_stop(nc);
        return EXIT_FAILURE;
    }

    /* Enable mouse - but try different modes */
    int mouse_enabled = notcurses_mice_enable(nc, NCMICE_BUTTON_EVENT);
    
    ui_draw(&ui);

    bool running = true;
    while (running) {
        struct ncinput ni;
        uint32_t id = notcurses_get_blocking(nc, &ni);

        if (id == (uint32_t)-1) {
            fprintf(stderr, "notcurses_get_blocking failed\n");
            running = false;
            break;
        }
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

        /* Handle ANY mouse event (not just button press) */
        if (nckey_mouse_p(id)) {
            ui_handle_click(&ui, ni.y, ni.x);
            continue;
        }
    }

    /* Cleanup */
    if (mouse_enabled == 0) {
        notcurses_mice_disable(nc);
    }
    ui_shutdown(&ui);
    notcurses_stop(nc);

    return EXIT_SUCCESS;
}
