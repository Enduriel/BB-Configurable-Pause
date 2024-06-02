::ConfigurablePause <- {
	ID = "mod_configurable_pause",
	Version = "0.1.0",
	Name = "Configurable Pause"
}

::ConfigurablePause.FlagID <- {
	WasDay = ::ConfigurablePause.ID + ".0",
	WasSeen = ::ConfigurablePause.ID + ".1",
	WasInPlayerVision = ::ConfigurablePause.ID + ".2"
}

::ConfigurablePause.SettingID <- {
	DelayBeforeUnpause = "DelayBeforeUnpause",
	ReEnterVisionPause = "ReEnterVisionPause",
	PauseOnSight = "PauseOnSight",
	PauseOnCampingNewDay = "PauseOnCampingNewDay",
	PauseOnEscortOverCity = "PauseOnEscortOverCity"
}

::mods_registerMod(::ConfigurablePause.ID, ::ConfigurablePause.Version, ::ConfigurablePause.Name);

::mods_queue(::ConfigurablePause.ID, "mod_msu(>=1.2.0), >mod_swifter", function()
{
	::ConfigurablePause.Mod <- ::MSU.Class.Mod(::ConfigurablePause.ID, ::ConfigurablePause.Version, ::ConfigurablePause.Name)
	::includeFiles(::IO.enumerateFiles("configurable_pause"));

	local page = ::ConfigurablePause.Mod.ModSettings.addPage("General");
	page.addRangeSetting(::ConfigurablePause.SettingID.DelayBeforeUnpause, 1.0, 0.0, 3.0, 0.1, "Pause Protection", "Amount of time after pausing automatically before the player is able to unpause");
	page.addRangeSetting(::ConfigurablePause.SettingID.ReEnterVisionPause, 5.0, 0.0, 30.0, 0.5, "Block Pause on re-enter vision", "Amount of time after an entity leaves player vision during which it will not trigger the auto-pause");

	page.addBooleanSetting(::ConfigurablePause.SettingID.PauseOnSight, true, "Pause When Seeing Enemy", "Pauses the game when an enemy enters the player's vision radius");
	page.addBooleanSetting(::ConfigurablePause.SettingID.PauseOnCampingNewDay, true, "Pause On New Day When Camping", "Pauses the game when dawn breaks and the player was camping (allowing you to immediately enter a city)");

	page.addBooleanSetting(::ConfigurablePause.SettingID.PauseOnEscortOverCity, true, "Pause When Escorting Caravan Over City", "Pauses the game when escorting a caravan and travelling over a city during daytime");
});
