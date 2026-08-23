// Throwaway capture harness for PR "match knobs / TIME LIMIT" (#241).
//
// openglad_demo cannot film the end of a match: its binary is built WITHOUT
// -DTESTING, so the moment the mode declares a winner the SDL level-end path
// (screen::endgame -> results_screen -> popup_dialog) opens a modal dialog
// inside the worker thread's sim tick and blocks forever under the dummy
// video driver. The last frame the demo ever renders is therefore the tick
// BEFORE the buzzer, and the "<COLOR> TEAM WINS!" announcement never reaches
// a rendered frame.
//
// This harness links the TESTING build of the same engine (libog_game_test.a),
// where popup_dialog is a logging no-op, so the match can be played to the
// knob's tick and rendered for a few frames AFTER the win is declared — which
// is where the announcement banner lives (STANDARD_TEXT_TIME = 75 cycles).
//
// It is compiled and linked outside the repo tree (see build.sh next to this
// file); it changes no repo source and is not part of any CMake target.

#include <SDL3/SDL.h>

#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <memory>
#include <string>
#include <vector>

#include <gtest/gtest.h>

#include <openglad/gameplay/guy.h>
#include <openglad/interface/button.h>
#include <openglad/interface/screen.h>
#include <openglad/platform/game_loop.h>
#include <openglad/platform/game_session.h>
#include <openglad/platform/local_transport_shadow.h>
#include <openglad/resources/save_data.h>

void glad_init(bool preserve_frame_timing = false);

namespace {

void dump_screen_ppm(screen* s, const std::string& dir, int frame)
{
    std::filesystem::create_directories(dir);
    char path[1024];
    std::snprintf(path, sizeof(path), "%s/%05d.ppm", dir.c_str(), frame);
    FILE* fp = std::fopen(path, "wb");
    ASSERT_NE(nullptr, fp);
    std::fprintf(fp, "P6\n320 200\n255\n");
    for (int j = 0; j < 200; j++)
        for (int i = 0; i < 320; i++)
        {
            Uint8 r = 0, g = 0, b = 0;
            s->get_pixel(i, j, &r, &g, &b);
            std::fputc(r, fp);
            std::fputc(g, fp);
            std::fputc(b, fp);
        }
    std::fclose(fp);
}

int env_int(const char* name, int fallback)
{
    const char* v = std::getenv(name);
    return (v != nullptr && *v != '\0') ? std::atoi(v) : fallback;
}

} // namespace

// OG_TL_DIR      output directory (required)
// OG_TL_LIMIT    save_data.time_limit in sim ticks (0 = the map's own value)
// OG_TL_SCEN     modes scenario id (822 soccer by default)
// OG_TL_FROM     first tick to dump
// OG_TL_MAX      hard tick cap
TEST(TimeLimitShot, play_modes_match_to_the_knob_tick)
{
    const char* out = std::getenv("OG_TL_DIR");
    if (out == nullptr)
        GTEST_SKIP() << "set OG_TL_DIR to record";
    const std::string dir(out);
    const int limit = env_int("OG_TL_LIMIT", 720);
    const int scen = env_int("OG_TL_SCEN", 822);
    const int from = env_int("OG_TL_FROM", 0);
    const int max_ticks = env_int("OG_TL_MAX", 3000);

    screen* const s = og::runtime::current_session->myscreen_;
    ASSERT_NE(nullptr, s);

    SaveData& save = s->save_data;
    save.reset();
    save.current_campaign = "modes";
    save.current_levels[save.current_campaign] = static_cast<short>(scen);
    save.scen_num = static_cast<short>(scen);
    save.numplayers = 1;
    const int roster[3] = {FAMILY_SOLDIER, FAMILY_ELF, FAMILY_MAGE};
    for (std::size_t i = 0; i < 3; i++)
    {
        auto member = std::make_unique<guy>(roster[i]);
        member->upgrade_to_level(4);
        member->teamnum = 0;
        save.team_list[i] = std::move(member);
    }
    save.team_size = 3;
    // The knob under test: the same SaveData field the MATCH SETUP page, the
    // lobby and OPENGLAD_DEMO_MATCH_TIME_LIMIT all write.
    save.time_limit = static_cast<short>(limit);
    ASSERT_TRUE(save.save("save0"));

    glad_init();
    ASSERT_TRUE(og::runtime::current_game_session != nullptr);
    std::printf("[timelimit_shot] scen=%d save.time_limit=%d\n", scen,
                static_cast<int>(s->save_data.time_limit));

    GameLoopFrameState st;
    GameLoopDeps deps;
    deps.enable_render = false;
    deps.enable_event_poll = false;
    deps.enable_frame_timing = false;

    int tick = 0;
    bool ended = false;
    for (; tick < max_ticks; tick++)
    {
        const GameFrameResult r = game_frame_with_result(*s, st, deps);
        if (tick + 1 >= from)
        {
            s->redraw();
            score_panel(s);
            s->swap();
            dump_screen_ppm(s, dir, tick + 1);
        }
        if (r != GameFrameResult::Continue)
        {
            ended = true;
            std::printf("[timelimit_shot] match ended after tick %d\n",
                        tick + 1);
            break;
        }
        if (::testing::Test::HasFatalFailure())
            break;
    }

    // The frames the demo can never reach: the win was declared during the
    // tick above, the announcement was dispatched to the viewport with it,
    // and these renders are what a player would see on screen.
    if (ended)
    {
        for (int extra = 1; extra <= 12; extra++)
        {
            s->redraw();
            score_panel(s);
            s->swap();
            dump_screen_ppm(s, dir, tick + 1 + extra);
        }
    }
    std::printf("[timelimit_shot] ended=%d last_tick=%d\n",
                static_cast<int>(ended), tick + 1);

    s->world().end = 0;
    og::runtime::clear_local_transport_shadow(*og::runtime::current_game_session);
    s->world().delete_objects();
}
