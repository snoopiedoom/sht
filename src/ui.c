#include "ui.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

/*
 * Kanagawa(-wave) inspired colors (approximate):
 * bg:  0x1f1f28  (dark background)
 * fg:  0xdcd7ba  (warm light fg)
 * accent1: 0x7e9cd8 (blue)
 * accent2: 0xe46876 (red-ish)
 * accent3: 0x98bb6c (green-ish)
 * These are easy to tweak later.
 */

#define KANA_BG_MAIN      0x1f1f28u
#define KANA_BG_HEADER    0x16161du
#define KANA_BG_SIDEBAR   0x181820u
#define KANA_BG_STATUS    0x1a1a22u
#define KANA_FG_PRIMARY   0xdcd7bau
#define KANA_ACCENT_BLUE  0x7e9cd8u
#define KANA_ACCENT_RED   0xe46876u
#define KANA_ACCENT_GREEN 0x98bb6cu

#define HEX_TO_RGB(hex, r, g, b)        \
    do {                                \
        (r) = ((hex) >> 16) & 0xFF;     \
        (g) = ((hex) >> 8)  & 0xFF;     \
        (b) = (hex) & 0xFF;             \
    } while (0)

static void
set_plane_base_hex(struct ncplane *n, uint32_t fg_hex, uint32_t bg_hex)
{
    uint32_t fgch = 0;
    uint32_t bgch = 0;
    unsigned r, g, b;

    HEX_TO_RGB(fg_hex, r, g, b);
    ncchannel_set_rgb8(&fgch, r, g, b);

    HEX_TO_RGB(bg_hex, r, g, b);
    ncchannel_set_rgb8(&bgch, r, g, b);

    uint64_t chans = ncchannels_combine(fgch, bgch);
    ncplane_set_base(n, " ", 0, chans);
}

static void
destroy_child(struct ncplane **p)
{
    if (*p) {
        ncplane_destroy(*p);
        *p = NULL;
    }
}

int
ui_init(struct app_ui *ui, struct notcurses *nc)
{
    if (!ui || !nc) {
        return -1;
    }

    memset(ui, 0, sizeof(*ui));
    ui->nc   = nc;
    ui->root = notcurses_stdplane(ui->nc);

    ui_resize(ui);
    return 0;
}

void
ui_resize(struct app_ui *ui)
{
    if (!ui || !ui->root) {
        return;
    }

    /* Drop old layout planes if they exist */
    destroy_child(&ui->header);
    destroy_child(&ui->sidebar);
    destroy_child(&ui->main);
    destroy_child(&ui->status);

    unsigned rows, cols;
    ncplane_dim_yx(ui->root, &rows, &cols);

    int header_h  = 3;
    int status_h  = 1;
    int sidebar_w = (cols > 40) ? 24 : (cols / 4);

    if ((unsigned)(header_h + status_h) >= rows) {
        header_h = 1;
        status_h = 1;
    }
    if ((unsigned)sidebar_w >= cols) {
        sidebar_w = (int)(cols / 3);
    }

    struct ncplane_options header_opts = {
        .y = 0,
        .x = 0,
        .rows = header_h,
        .cols = (int)cols,
        .userptr = NULL,
        .name = "header",
        .resizecb = NULL,
        .flags = 0,
        .margin_b = 0,
        .margin_r = 0
    };

    struct ncplane_options sidebar_opts = {
        .y = header_h,
        .x = 0,
        .rows = (int)rows - header_h - status_h,
        .cols = sidebar_w,
        .userptr = NULL,
        .name = "sidebar",
        .resizecb = NULL,
        .flags = 0,
        .margin_b = 0,
        .margin_r = 0
    };

    struct ncplane_options main_opts = {
        .y = header_h,
        .x = sidebar_w,
        .rows = (int)rows - header_h - status_h,
        .cols = (int)cols - sidebar_w,
        .userptr = NULL,
        .name = "main",
        .resizecb = NULL,
        .flags = 0,
        .margin_b = 0,
        .margin_r = 0
    };

    struct ncplane_options status_opts = {
        .y = (int)rows - status_h,
        .x = 0,
        .rows = status_h,
        .cols = (int)cols,
        .userptr = NULL,
        .name = "status",
        .resizecb = NULL,
        .flags = 0,
        .margin_b = 0,
        .margin_r = 0
    };

    ui->header  = ncplane_create(ui->root, &header_opts);
    ui->sidebar = ncplane_create(ui->root, &sidebar_opts);
    ui->main    = ncplane_create(ui->root, &main_opts);
    ui->status  = ncplane_create(ui->root, &status_opts);

    set_plane_base_hex(ui->root,   KANA_FG_PRIMARY, KANA_BG_MAIN);
    set_plane_base_hex(ui->header, KANA_FG_PRIMARY, KANA_BG_HEADER);
    set_plane_base_hex(ui->sidebar,KANA_FG_PRIMARY, KANA_BG_SIDEBAR);
    set_plane_base_hex(ui->main,   KANA_FG_PRIMARY, KANA_BG_MAIN);
    set_plane_base_hex(ui->status, KANA_FG_PRIMARY, KANA_BG_STATUS);
}

void
ui_draw(struct app_ui *ui)
{
    if (!ui || !ui->root) {
        return;
    }

    ncplane_erase(ui->root);
    ncplane_erase(ui->header);
    ncplane_erase(ui->sidebar);
    ncplane_erase(ui->main);
    ncplane_erase(ui->status);

    /* Header: app title */
    ncplane_putstr_yx(ui->header, 1, 2, "simple-http-tui :: workspace");

    /* Sidebar: placeholder menu */
    ncplane_putstr_yx(ui->sidebar, 0, 1, "Collections");
    ncplane_putstr_yx(ui->sidebar, 2, 1, "[1] New Request");
    ncplane_putstr_yx(ui->sidebar, 3, 1, "[2] Import");
    ncplane_putstr_yx(ui->sidebar, 5, 1, "History");
    ncplane_putstr_yx(ui->sidebar, 6, 1, "Env vars");

    /* Main: placeholder "request editor" */
    ncplane_putstr_yx(ui->main, 0, 1, "Request");
    ncplane_putstr_yx(ui->main, 2, 1, "Method: GET");
    ncplane_putstr_yx(ui->main, 3, 1, "URL   : https://example.com/api");
    ncplane_putstr_yx(ui->main, 5, 1, "[ Body preview / headers / JSON editor go here ]");

    /* Status bar */
    ncplane_putstr_yx(ui->status, 0, 1,
                      "Status: ready  |  q / ESC to quit  |  click anywhere to log coords");

    notcurses_render(ui->nc);
}

void
ui_handle_click(struct app_ui *ui, int y, int x)
{
    if (!ui || !ui->status) {
        return;
    }

    ncplane_erase(ui->status);
    set_plane_base_hex(ui->status, KANA_FG_PRIMARY, KANA_BG_STATUS);

    ncplane_putstr_yx(ui->status, 0, 1, "Status: mouse click at ");
    ncplane_printf_yx(ui->status, 0, 27, "y=%d x=%d", y, x);

    notcurses_render(ui->nc);
}

void
ui_shutdown(struct app_ui *ui)
{
    if (!ui) {
        return;
    }

    destroy_child(&ui->header);
    destroy_child(&ui->sidebar);
    destroy_child(&ui->main);
    destroy_child(&ui->status);
}