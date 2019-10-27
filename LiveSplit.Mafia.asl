// Mafia autosplitter and load remover by pitpo, Lembox, pudingus and Wafu
// FRE autosplitter by TheShalty

state("game", "1.0")
{
	bool isLoading1 : 0x272584;
	bool isLoaded : 0x2F9464, 0x40;		// returns 0 in profile selection
	bool isLoading3 : 0x2F94BC;			// returns 1 in main menu
	bool m1Cutscene : 0x25608C;
	bool inMission : 0x255360, 0x460, 0xB4, 0xDC;
	byte subSegment : 0x27202C;
	byte finalCutscene : 0x256444;
	string6 mission : 0x2F94A8, 0x0;
	string16 missionAlt : 0x2F94A8, 0x0;	// used for "submissions"
}

state("game", "1.2")
{
	bool isLoading1 : 0x2D4BFC;
	bool isLoaded : 0x247E1C, 0x40;
	bool isLoading3 : 0x247E74;
	bool m1Cutscene : 0x23D730;
	bool inMission : 0x23D2BC, 0x460, 0xB4, 0xDC;
	byte subSegment : 0x2D46A4;
	byte finalCutscene : 0x2BDD7C;
	string6 mission : 0x247E60, 0x0;
	string16 missionAlt : 0x247E60, 0x0;
}

init
{
	if (modules.First().ModuleMemorySize == 3158016) {
		version = "1.0";
	}
	else if (modules.First().ModuleMemorySize == 2993526) {
		version = "1.2";
	}
}

startup
{
	settings.Add("fairplay", false, "Split after night segment in Fairplay");
	settings.Add("sarah", true, "Split after Sarah");
	settings.Add("whore", true, "Split after Whore");
	vars.crash = false;
	vars.lastMission = "";
	vars.fromExtrem = false;
}

update
{
	if (version == "") return;		// If version is unknown, don't do anything (without it, it'd default to "1.0" version)

	if (current.mission != null) {
		vars.lastMission = current.mission;
	}

	if (old.mission == "00menu" && current.mission != "00menu") {
		vars.crash = false;
		timer.IsGameTimePaused = false;
	}
}

start
{
	return ((!old.m1Cutscene && current.m1Cutscene && current.mission == "mise01") || (current.mission == "extrem" && !current.inMission && old.isLoading3 && !current.isLoading3));
}

// Reset timer on "An Offer You Can't Refuse" load (you can comment this section out if you don't want this feature)
reset
{
	return (current.mission == "mise01" && ((old.isLoading1 && !current.isLoading1) || (!old.isLoading3 && current.isLoading3)));
}

// Split for every mission change (at the very beginning of every loading) [you can comment this section out if you don't want this feature]
split
{
	if (current.mission == null) return;  // gets rid of null reference expections in debugview
	if (current.mission.Contains("mise") && old.mission != "00menu") {
		// Final split
		if (current.missionAlt == "mise20-galery") {
			return (current.subSegment == 49 && old.finalCutscene == 0 && current.finalCutscene > 0);
		}

		// Don't split on these mission changes
		else if (current.mission == "mise01") return false;

		// Split during Fairplay
		else if (current.mission == "mise06") {
			return (old.mission == "mise05" && settings["fairplay"]);
		}

		// Split after Sarah
		else if (current.missionAlt == "mise07b-saliery") {
			return (old.missionAlt == "mise07-sara" && settings["sarah"]);
		}

		// Split after The Whore
		else if (current.missionAlt == "mise08-kostel") {
			return (old.missionAlt == "mise08-hotel" && settings["whore"]);
		}

		// Split for everything else
		else {
			return (old.mission != current.mission);
		}
	}
	else if (old.missionAlt == "mise20-galery" && current.missionAlt == "FMV KONEC") {
		return true;
	}
	else {
		return (current.mission == "extrem" && old.inMission && !current.inMission && !current.isLoading3 && !current.isLoading1 && current.isLoaded); // split in case of FRE else false
	}
}

// Load remover  (you can comment this section out if you don't want this feature)
isLoading
{
	if (!vars.crash) {
		// FRE is real time only

		if (current.mission == "extrem") {
			return false;
		}
		else if (current.mission == "00menu") {
			if (old.mission == "extrem") vars.fromExtrem = true;

			return (current.isLoading1 && !vars.fromExtrem);
		}
		else {
			vars.fromExtrem = false;
			return (current.isLoading1 || !current.isLoaded || current.isLoading3);
		}
	}
}

exit
{
	if (vars.lastMission != "extrem") {
		timer.IsGameTimePaused = true;
	}
	vars.crash = true;	
}

