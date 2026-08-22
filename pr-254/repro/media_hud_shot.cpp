// Throwaway PR-media harness (scratchpad only; never added to the repo).
//
// Includes the real HUD integration test verbatim so the session fixture and
// its helpers (GladHud, HudObListSwap, FreezeGuard, ViewHudStateGuard,
// ViewCountGuard, make_player, capture_rendered_frame) are the ones CI runs,
// then adds one case that dumps the rendered 320x200 framebuffer as a PPM.
// Run with --gtest_filter='GladHud.media_*' and HUD_SHOT_DIR set.

#include "/home/yans/code/openglad/tests/integration/test_glad_hud.cpp"

#include <cstdio>
#include <cstdlib>
#include <string>

namespace {

// The frame indices come back through capture_rendered_frame; curpal_ is the
// classic 0..63-per-channel VGA palette, so widen to 8-bit for the PPM.
void media_dump_ppm(screen& scr, const std::string& path)
{
    const auto frame = capture_rendered_frame(scr);
    std::FILE* f = std::fopen(path.c_str(), "wb");
    ASSERT_TRUE(f != nullptr) << "cannot open " << path;
    std::fprintf(f, "P6\n320 200\n255\n");
    for (std::size_t i = 0; i < frame.size(); ++i)
    {
        int r = 0, g = 0, b = 0;
        query_palette_reg(frame[i], &r, &g, &b);
        const unsigned char px[3] = {
            static_cast<unsigned char>(r * 255 / 63),
            static_cast<unsigned char>(g * 255 / 63),
            static_cast<unsigned char>(b * 255 / 63),
        };
        std::fwrite(px, 1, 3, f);
    }
    std::fclose(f);
}

std::string media_dir()
{
    const char* dir = std::getenv("HUD_SHOT_DIR");
    return dir != nullptr ? std::string(dir) : std::string(".");
}

} // namespace

// Full-screen pane: the classic HUD with the frozen-time cell at three
// countdown values, so the cell can be seen holding one position while the
// number shrinks.
TEST_F(GladHud, media_freeze_countdown_fullscreen)
{
    HudObListSwap swap;
    screen* const s = og::runtime::current_session->myscreen_;
    viewscreen* const v = s->viewob[0].get();
    ASSERT_TRUE(v != nullptr);

    GameWorld& world = s->world();
    FreezeGuard freeze_guard(world);
    ViewHudStateGuard view_guard(*v);

    auto control = make_player(0);
    ASSERT_TRUE(control != nullptr);
    walker* const controlp = control.get();
    world.oblist.push_back(std::move(control));
    v->control = controlp;
    v->prefs[PREF_SCORE] = PREF_SCORE_OFF;
    v->prefs[PREF_VIEW] = PREF_VIEW_FULL;
    v->resize(static_cast<char>(PREF_VIEW_FULL));

    const std::string dir = media_dir();
    const std::int32_t values[] = {152, 88, 7, 0};
    for (std::int32_t left : values)
    {
        world.enemy_freeze = left;
        s->clearbuffer();
        ASSERT_EQ(1, (int)new_score_panel(s, 1));
        char stem[32];
        std::snprintf(stem, sizeof(stem), "/full_%03d.ppm",
                      static_cast<int>(left));
        media_dump_ppm(*s, dir + stem);
    }
}

// Narrow columns: the 3-way PREF_VIEW_PANELS split, where 6e5576dc reserves
// the radar column and falls back to the short "T: N" form; and the 4-way
// quadrant split. ready_for_battle rebuilds the views, so this case never
// holds a pointer to the old ones.
TEST_F(GladHud, media_freeze_countdown_columns)
{
    HudObListSwap swap;
    screen* const s = og::runtime::current_session->myscreen_;
    GameWorld& world = s->world();
    FreezeGuard freeze_guard(world);
    ViewCountGuard view_count_guard(*s);

    auto control = make_player(0);
    ASSERT_TRUE(control != nullptr);
    walker* const controlp = control.get();
    world.oblist.push_back(std::move(control));

    const std::string dir = media_dir();

    const auto shoot = [&](int views, signed char mode, const char* tag,
                           std::int32_t left) {
        s->ready_for_battle(static_cast<short>(views));
        ASSERT_EQ(views, static_cast<int>(s->numviews));
        for (int i = 0; i < s->numviews; ++i)
        {
            ASSERT_TRUE(s->viewob[i] != nullptr);
            s->viewob[i]->control = controlp;
            s->viewob[i]->prefs[PREF_SCORE] = PREF_SCORE_OFF;
            s->viewob[i]->prefs[PREF_VIEW] = mode;
            s->viewob[i]->resize(static_cast<char>(mode));
        }
        world.enemy_freeze = left;
        s->clearbuffer();
        ASSERT_EQ(1, (int)new_score_panel(s, 1));
        char stem[48];
        std::snprintf(stem, sizeof(stem), "/%s_%03d.ppm", tag,
                      static_cast<int>(left));
        media_dump_ppm(*s, dir + stem);
    };

    // 100px-wide columns: the full string would run into the radar block, so
    // the cell shortens to "T: 88".
    shoot(3, PREF_VIEW_PANELS, "cols3", 88);
    // The same column has no room for three digits even shortened, so the
    // cell gives up rather than overlap the radar.
    shoot(3, PREF_VIEW_PANELS, "cols3", 300);
    // 159x99 quadrants: room for the cell again.
    shoot(4, PREF_VIEW_FULL, "quad", 88);
}
