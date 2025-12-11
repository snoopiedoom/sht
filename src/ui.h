
#ifndef UI_H
#define UI_H

#include <notcurses/notcurses.h>

struct app_ui {
    struct notcurses *nc;
    struct ncplane   *root;

    struct ncplane *header;
    struct ncplane *sidebar;
    struct ncplane *main;
    struct ncplane *status;
};

int  ui_init(struct app_ui *ui, struct notcurses *nc);
void ui_resize(struct app_ui *ui);
void ui_draw(struct app_ui *ui);
void ui_handle_click(struct app_ui *ui, int y, int x);
void ui_shutdown(struct app_ui *ui);

#endif /* UI_H */