::ConfigurablePause <- {
	ID = "mod_configurable_pause",
	Version = "0.3.0",
	Name = "Configurable Pause",
};

::ConfigurablePause.FlagID <- {
	LastSeenInPlayerVision = ::ConfigurablePause.ID + ".LastSeenInPlayerVision",
	WasDay = ::ConfigurablePause.ID + ".WasDay"
};

::ConfigurablePause.MH <- ::Hooks.register(::ConfigurablePause.ID, ::ConfigurablePause.Version, ::ConfigurablePause.Name);
::ConfigurablePause.MH.require("mod_msu");
::ConfigurablePause.MH.conflictWith("mod_pause [Configurable Pause supercedes this mod]", "mod_mbpause [Configurable Pause supercedes this mod]");


::ConfigurablePause.MH.queue(">mod_msu", ">mod_swifter", function() {
	::ConfigurablePause.Mod <- ::MSU.Class.Mod(::ConfigurablePause.ID, ::ConfigurablePause.Version, ::ConfigurablePause.Name)

	::ConfigurablePause.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/Enduriel/BB-Configurable-Pause");
	::ConfigurablePause.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
	::ConfigurablePause.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/730");

	foreach (file in ::IO.enumerateFiles(::ConfigurablePause.ID + "/hooks")) {
		::include(file);
	}

	local page = ::ConfigurablePause.Mod.ModSettings.addPage("General");

	page.addBooleanSetting("PauseOnSight", true, "Pause When Seeing Enemy", "Pauses the game when an enemy enters the player's vision radius");
	page.addBooleanSetting("UnpauseOnNewDestination", true, "Unpause On New Destination", "Unpauses the game when the player selects a new destination on the map");
	page.addBooleanSetting("PauseOnArrival", true, "Pause On Arrival", "Pauses the game when the player arrives at their destination");
	page.addBooleanSetting("PauseOnCampingNewDay", true, "Pause On New Day When Camping", "Pauses the game when dawn breaks and the player was camping (allowing you to immediately enter a city)");
	page.addBooleanSetting("PauseOnCampingNewNight", false, "Pause On Nightfall When Camping", "Pauses the game when night starts and the player was camping (allowing you to immediately attack a camp at night)");
	page.addEnumSetting("PauseOnEscortOverCity", "Day Only", ["Day Only", "Always", "Never"] "Pause When Escorting Caravan Over City", "Pauses the game when escorting a caravan and travelling over a city")
	page.addRangeSetting("DelayBeforeUnpause", 1.0, 0.0, 3.0, 0.1, "Pause Protection (sec)", "Amount of time after pausing due to seeing an enemy before the player is able to unpause");
	page.addRangeSetting("ReEnterVisionPause", 24, 0, 96, 1, "Block Pause on re-enter vision (ingame hours)", "Amount of time (in ingame hours) after an entity leaves player vision during which it will not trigger the auto-pause");
	page.addBooleanSetting("PauseOnCombatDialog", true, "Pause On Combat Popup", "Pauses the game when the combat dialog appears, the game will continue to be paused after combat.");
	page.addBooleanSetting("PauseOnEventScreen", true, "Pause On Event Popup", "Pauses the game when an event pops up.");
})
