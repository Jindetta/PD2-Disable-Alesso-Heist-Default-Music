if RequiredScript == "lib/tweak_data/levelstweakdata" then
    Hooks:PostHook(
        LevelsTweakData,
        "init",
        "DAHDM_TweakData",
        function(td)
            td.arena.death_track = nil
            td.arena.death_event = nil
            td.arena.music = "heist"
        end
    )
else
    local MusicManagerJukeboxDefaults = MusicManager.jukebox_default_tracks

    function MusicManager:jukebox_default_tracks()
        local tracks = MusicManagerJukeboxDefaults(self)

        tracks.heist_arena = "all"

        return tracks
    end

    if Global.game_settings and Global.game_settings.level_id == "arena" then
        local MusicManagerPostEvent = MusicManager.post_event

        function MusicManager:post_event(event)
            if is_arena_event(event) then
                Global.music_manager.current_event = event
            else
                MusicManagerPostEvent(self, event)
            end
        end

        function MusicManager:track_listen_start(event, track)
            if self._current_track ~= track or self._current_event ~= event then
                self._skip_play = true

                Global.music_manager.source:stop()

                if track then
                    Global.music_manager.source:set_switch("music_randomizer", track)
                end

                self._current_track = track
                self._current_event = event
                play_event(event)
            end
        end

        function MusicManager:track_listen_stop()
            if self._current_event then
                Global.music_manager.source:post_event("stop_all_music")

                play_event(Global.music_manager.current_event)
            end

            if self._current_track and Global.music_manager.current_track then
                Global.music_manager.source:set_switch("music_randomizer", Global.music_manager.current_track)
            end

            self._current_event = nil
            self._current_track = nil
            self._skip_play = nil
        end

        local function play_event(event)
            if not is_arena_event(event) then
                Global.music_manager.source:post_event(event)
            end
        end

        local function is_arena_event(event)
            local patterns = {"^alesso_", "^crowd_"}

            if type(event) == "string" then
                for _, pattern in ipairs(patterns) do
                    if event:find(pattern) ~= nil then
                        return true
                    end
                end
            end

            return not event
        end
    end
end
