::ConfigurablePause.MH.hook("scripts/entity/world/party", function(q) {
	q.m.ConfigurablePause_LastUpdateTime <- 0.0;

	q.create = @(__original) function() {
		__original();
		this.getFlags().set(::ConfigurablePause.FlagID.LastSeenInPlayerVision, 0.0);
	}

	q.onDiscovered = @(__original) function() {
		this.ConfigurablePause_inVisionUpdate();
		return __original();
	}

	q.onUpdate = @(__original) function() {
		local lastUpdateTime = this.m.ConfigurablePause_LastUpdateTime;
		// vanilla uses ::Time.getVirtualTimeF() which isn't the same thing and we need to know ingame time for reenter vision pause
		this.m.ConfigurablePause_LastUpdateTime = ::World.getTime().Time;
		local ret = __original();
		if (::ConfigurablePause.Mod.ModSettings.getSetting("PauseOnSight").getValue() && !this.m.IsPlayer) {
			// this should NEVER happen, but people were reporting issues
			// probably due to other buggy mods which errored
			if (!this.getFlags().has(::ConfigurablePause.FlagID.LastSeenInPlayerVision)) {
				::logError("Entity " + this.getName() + " did not have LastSeenInPlayerVision flag set! This should not be possible, but has been handled gracefully. If you see this in a log, please report this to Enduriel");
				::logInfo(" SpawnTime: " + this.m.SpawnTime + " WorldTime: " + ::Time.getVirtualTimeF() + " Description: " + this.getDescription());
				::MSU.Log.printData(this.getFlags().m);
				this.getFlags().set(::ConfigurablePause.FlagID.LastSeenInPlayerVision, 0.0);
			}
			if (this.getFlags().get(::ConfigurablePause.FlagID.LastSeenInPlayerVision) > 0.0) {
				if (::World.State.getPlayer().isAbleToSee(this)) { // player can see the entity in this update
					this.ConfigurablePause_inVisionUpdate(lastUpdateTime);
				}
			}
		}
		return ret;
	}

	q.ConfigurablePause_inVisionUpdate <- function( _lastUpdateTime = null ) {
		if (_lastUpdateTime == null) {
			_lastUpdateTime = this.m.ConfigurablePause_LastUpdateTime;
		}
		local worldTime = ::World.getTime().Time;
		local lastSeen = this.getFlags().get(::ConfigurablePause.FlagID.LastSeenInPlayerVision);
		if (lastSeen != 0.0) {
			lastSeen += ::ConfigurablePause.Mod.ModSettings.getSetting("ReEnterVisionPause").getValue() * ::World.getTime().SecondsPerHour;
		}
		if (this.isAttackable() &&
		  !this.isAlliedWithPlayer() &&
		  this.getTile().getDistanceTo(::World.State.getPlayer().getTile()) <= 8 &&
		  lastSeen < _lastUpdateTime
		  ) {
			::World.State.m.ConfigurablePause_LastPauseOnSeeEnemy = ::Time.getExactTime();
			::World.State.ConfigurablePause_setPause(true);
		}
		this.getFlags().set(::ConfigurablePause.FlagID.LastSeenInPlayerVision, worldTime);
	}
})
