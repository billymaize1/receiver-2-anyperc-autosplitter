state("Receiver2") {}

startup
{
	vars.Log = (Action<object>)(output => print("[Receiver 2] " + output));
	vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\ULibrary.bin")).CreateInstance("ULibrary.Unity");

	refreshRate = 30;
	vars.canStart = false;
}

onStart
{
	vars.canStart = false;
}

init
{
	vars.Unity.TryOnLoad = (Func<dynamic, bool>)(helper =>
	{
		try
		{
			var lst = helper.GetClass("mscorlib", "List`1"); // List<T>

			var lms = helper.GetClass("Wolfire.Receiver2", 0x2000187); // LevelManagerScript

			var rcs = helper.GetClass("Wolfire.Receiver2", 0x2000298); // ReceiverCoreScript
			var rpgm = helper.GetClass("Wolfire.Receiver2", 0x200012D); // RankingProgressionGameMode
			var rpd = helper.GetClass("Wolfire.Receiver2", 0x200012C); // RankingProgressionData
			var gss = helper.GetClass("Wolfire.Receiver2", 0x200024D); // GameSessionStatistic
			// var lah = helper.GetClass("Wolfire.Receiver2", 0x2000195); // LocalAimHandler

			vars.Unity.Make<float>(lms.Static, lms["instance"], lms["load_queue"], lst["_size"]).Name = "loadQueue";
			vars.Unity.Make<int>(rcs.Static, rcs["instance"], rcs["game_mode"], rpgm["checkpoint_rank"]).Name = "rank";
			vars.Unity.Make<int>(rcs.Static, rcs["instance"], rcs["game_mode"], rpgm["progression_data"], rpd["regular_tapes_picked_up"]).Name = "tapesCollected";
			// vars.Unity.Make<int>(rcs.Static, rcs["instance"], rcs["game_mode"], rpgm["progression_data"], rpd["regular_tapes_consumed"]).Name = "tapesConsumed";
			vars.Unity.Make<float>(rcs.Static, rcs["instance"], rcs["session_data"], gss["session_time"]).Name = "time";
			vars.Unity.Make<ulong>(rcs.Static, rcs["instance"], rcs["session_data"], gss["session_start_date_time"]).Name = "startTime";
			// vars.Unity.Make<bool>(lah.Static, lah["player_instance"], lah["dead"]).Name = "dead";

			return true;
		}
		catch (InvalidOperationException)
		{
			helper.ClearImages();
			return false;
		}
	});

	vars.Unity.Load(game);
}

update
{
	if (!vars.Unity.Loaded) return false;

	vars.Unity.Watchers.UpdateAll(game);

	// current.dead = vars.Unity.Watchers["dead"].Current;
	current.loadQueue = vars.Unity.Watchers["loadQueue"].Current;
	current.rank = vars.Unity.Watchers["rank"].Current;
	current.time = vars.Unity.Watchers["time"].Current;
	current.startTime = vars.Unity.Watchers["startTime"].Current;
	current.tapesCollected = vars.Unity.Watchers["tapesCollected"].Current;

	// if (old.tapesCollected != current.tapesCollected)
	// 	vars.Log(old.tapesCollected + " -> " + current.tapesCollected);
}

start
{
	if (old.loadQueue > 0 && current.loadQueue == 0)
		vars.canStart = true;

	return vars.canStart && old.time < current.time;
}

split
{
	return current.rank == old.rank + 1 ||
	       current.rank == 5 && old.tapesCollected == 22 && current.tapesCollected == 23;
}

reset
{
	return old.startTime < current.startTime;
}

gameTime
{
	return TimeSpan.FromSeconds(current.time);
}

isLoading
{
	return true;
}

exit
{
	vars.Unity.Reset();
}

shutdown
{
	vars.Unity.Reset();
}
