::mods_hookExactClass("states/world_state", function(o) {
	o.m.ConfigurablePause <- {
		LastPauseOnSeeEnemy = 0.0,
		IsInThread = false
		// NumChecks = 0,
		// TimePerCheck = {
		// 	Dummy = {
		// 		NumChecks = 0,
		// 		Total = 0.0
		// 	}
		// }
	}
	local onInit = o.onInit;
	o.onInit = function()
	{
		onInit();
		this.m.Flags.add(::ConfigurablePause.FlagID.WasDay, false)
	}

	local onUpdate = o.onUpdate;
	o.onUpdate = function()
	{
		local ret = onUpdate();
		// ::MSU.Utils.Timer("PerfTestCP").unpause()
		if (this.m.Flags.get(::ConfigurablePause.FlagID.WasDay) != ::World.getTime().IsDaytime)
		{
			this.ConfigurablePause_onNewDayTime();
		}
		// local time = ::MSU.Utils.Timer("PerfTestCP").stopNoPrint();

		// if (!(this.m.ConfigurablePause.NumChecks in this.m.ConfigurablePause.TimePerCheck))
		// 	this.m.ConfigurablePause.TimePerCheck[this.m.ConfigurablePause.NumChecks] <- clone this.m.ConfigurablePause.TimePerCheck.Dummy

		// local table = this.m.ConfigurablePause.TimePerCheck[this.m.ConfigurablePause.NumChecks];
		// ++table.NumChecks;
		// table.Total += time;
		// this.m.ConfigurablePause.NumChecks = 0;
		return ret;
	}

	// o.ConfigurablePause_printPerfTimers <- function()
	// {
	// 	foreach (i, table in this.m.ConfigurablePause.TimePerCheck)
	// 	{
	// 		if (i == "Dummy") continue;
	// 		::logInfo(format("NumEntities: %i, AvgTimePerCheck %f, NumTests: %i", i, table.Total / table.NumChecks, table.NumChecks));
	// 	}
	// }

	// local setPause = o.setPause;
	// o.setPause = function( _f )
	// {
	// 	if (_f || this.m.ConfigurablePause.LastPauseOnSeeEnemy + ::ConfigurablePause.Mod.ModSettings.getSetting(::ConfigurablePause.SettingID.DelayBeforeUnpause).getValue() < ::Time.getExactTime())
	// 		return setPause(_f);
	// }
	local onProcessInThread = o.onProcessInThread;
	o.onProcessInThread = function()
	{
		this.m.ConfigurablePause.IsInThread = true;
		local ret = onProcessInThread()
		this.m.ConfigurablePause.IsInThread = false;
		return ret;
	}


	o.ConfigurablePause_onNewDayTime <- function()
	{
		if (::World.getTime().IsDaytime && ::World.Assets.isCamping() && !this.isPaused() && !::World.getMenuStack().hasBacksteps() && ::ConfigurablePause.Mod.ModSettings.getSetting(::ConfigurablePause.SettingID.PauseOnCampingNewDay).getValue())
			this.setPause(true);
		this.m.Flags.set(::ConfigurablePause.FlagID.WasDay, ::World.getTime().IsDaytime);
	}

	o.ConfigurablePause_isInThread <- function()
	{
		return this.m.ConfigurablePause.IsInThread;
	}
});
