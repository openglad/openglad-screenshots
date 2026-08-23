// Throwaway media harness for PR #254's #232 proof captures.
// Real gameplay frames WITH the score panel, headless (SDL dummy video).
// Reuses tests/integration/test_game_loop.cpp's gameplay_rec helpers verbatim.
// Never committed; compiled out-of-tree against libog_game_test.a.
#include "/home/yans/code/openglad/tests/integration/test_game_loop.cpp"

#include <cstdio>
#include <cstdlib>
short new_score_panel(screen* s, short do_it);

namespace media_shots {

// One simulated+rendered run. players: seat count. freeze_at/freeze_bank:
// tick to stage the freeze and its value. frames: total ticks to run.
// every_n: dump cadence. tag: dump_screen scene name.
static void run_and_dump(int players, int frames, int freeze_at,
                         int freeze_bank, int every_n, const char* tag)
{
    screen* const s = og::runtime::current_session->myscreen_;
    ASSERT_TRUE(s != nullptr);

    gameplay_rec::build_save(s, "gladiator", 1, players,
                             {FAMILY_SOLDIER, FAMILY_ELF, FAMILY_MAGE,
                              FAMILY_ARCHER},
                             4);
    glad_init();
    ASSERT_EQ(players, static_cast<int>(s->numviews));

    screen* const server =
        og::runtime::local_transport_shadow_testing_server_screen(
            *og::runtime::current_game_session);

    GameLoopFrameState st;
    GameLoopDeps deps;
    deps.enable_render = false;
    deps.enable_event_poll = false;
    deps.enable_frame_timing = false;

    for (int f = 0; f < frames; ++f)
    {
        if (game_frame_with_result(*s, st, deps) != GameFrameResult::Continue)
            break;
        if (f == freeze_at)
        {
            if (server != nullptr)
                server->world().enemy_freeze = freeze_bank;
            s->world().enemy_freeze = freeze_bank;
            for (int v = 0; v < s->numviews; ++v)
                s->viewob[v]->set_display_text("TIME IS FROZEN!", 40);
        }
        // A couple of genuine feed messages so the branch strip shows the
        // feed doing its real job while the HUD carries the countdown.
        if (f == freeze_at + 45)
            for (int v = 0; v < s->numviews; ++v)
                s->viewob[v]->set_display_text("REINFORCEMENTS SIGHTED", 40);
        if (f == freeze_at + 95)
            for (int v = 0; v < s->numviews; ++v)
                s->viewob[v]->set_display_text("THE GATE GRINDS OPEN", 40);
        s->redraw();
        new_score_panel(s, 1);
        s->swap();
        if (f % every_n == 0)
            gameplay_rec::dump_screen(s, tag, f);
    }

    s->world().end = 0;
    s->world().delete_objects();
}

} // namespace media_shots

TEST(MediaShots, solo_run)
{
    // freeze 150 staged at f=10, expires at f=160; run to 174 so the cell's
    // disappearance at 0 is on tape.
    media_shots::run_and_dump(1, 174, 10, 150, 1, "m232_solo");
}

TEST(MediaShots, three_way)
{
    media_shots::run_and_dump(3, 30, 5, 88, 29, "m232_3way");
}

TEST(MediaShots, four_way)
{
    media_shots::run_and_dump(4, 30, 5, 88, 29, "m232_4way");
}
