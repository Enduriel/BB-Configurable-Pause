::ConfigurablePause.MH.hook("scripts/states/world_state", function(q) {
	q.m.ConfigurablePause_Pause <- false;
	q.m.ConfigurablePause_OldDestination <- null;
	q.m.ConfigurablePause_OldPath <- null;
	q.m.ConfigurablePause_LastPauseOnSeeEnemy <- 0.0;
	q.m.ConfigurablePause <- {
		LastPauseOnSeeEnemy = 0.0,
		IsInThread = false
	};

	q.onInit = @(__original) function() {
		__original();
		this.m.Flags.set(::ConfigurablePause.FlagID.WasDay, false)
	}

	q.setEscortedEntity = @(__original) function( _entity ) {
		local ret = __original(_entity);
		if (_entity != null && this.m.EscortedEntity != null) {
			this.m.Player.m.ConfigurablePause_PausedTile = this.m.EscortedEntity.getTile();
		}
	}

	q.onMouseInput = @(__original) function( _mouse ) {
		local oldDest = this.getPlayer().m.Destination;
		local oldPath = this.getPlayer().getPath();
		local oldAttack = this.m.AutoAttack;
		local ret = __original(_mouse);
		local newDest = this.getPlayer().m.Destination;
		local newPath = this.getPlayer().getPath();
		local newAttack = this.m.AutoAttack;

		if ((oldDest != newDest) || (oldPath != newPath) || (oldAttack != newAttack)) {
			if (::ConfigurablePause.Mod.ModSettings.getSetting("UnpauseOnNewDestination").getValue()) {
				if (::World.Assets.isCamping()) {
					// patch because vanilla code doesn't check this if we are camping
					// which means you'd have to click twice to enter a location after camping
					local isEscorting = !::MSU.isNull(this.m.EscortedEntity);
					local entity = ::World.getEntityAtTile(newDest.Coords);
					// from world_state ~ line 965
					if (entity != null && (entity.isEnterable() || entity.isAttackable() || !entity.isVisited() || entity.getOnEnterCallback() != null)) {
						if (entity.getTile().isSameTileAs(this.m.Player.getTile()) && this.m.Player.getDistanceTo(entity) <= this.Const.World.CombatSettings.CombatPlayerDistance) {
							if (!isEscorting || entity.isAlliedWithPlayer()) {
								this.enterLocation(entity);
								return true;
							}
						} else if (!isEscorting) {
							this.m.AutoEnterLocation = ::WeakTableRef(entity);
							if (entity.isEnterable() && entity.isAlliedWithPlayer()) {
								this.m.WorldTownScreen.getMainDialogModule().preload(entity);
							}
						}
					}
				}
				this.setPause(false);
			}
		}

		return ret;
	}

	q.onUpdate = @(__original) function() {
		local oldPath = this.m.ConfigurablePause_OldPath;
		local newPath = this.getPlayer().getPath();
		local oldDest = this.m.ConfigurablePause_OldDestination;
		local newDest = this.getPlayer().m.Destination;

		if ((oldPath != null || oldDest != null) && (newPath == null && newDest == null)) {
			if (::ConfigurablePause.Mod.ModSettings.getSetting("PauseOnArrival").getValue()) {
				this.setPause(true);
			}
		}
		this.m.ConfigurablePause_OldDestination = newDest;
		this.m.ConfigurablePause_OldPath = newPath;

		if (this.m.ConfigurablePause_Pause) {
			this.setPause(true);
			this.m.ConfigurablePause_Pause = false;
		}

		local ret = __original();
		local isDayTime = ::World.getTime().IsDaytime;

		if (::ConfigurablePause.Mod.ModSettings.getSetting("PauseOnCampingNewDay").getValue()) {
			if (isDayTime && this.m.Flags.get(::ConfigurablePause.FlagID.WasDay) != isDayTime) {
				if (::World.Assets.isCamping()) {
					this.setPause(true);
				}
			}
		}

		if (::ConfigurablePause.Mod.ModSettings.getSetting("PauseOnCampingNewNight").getValue()) {
			if (!isDayTime && this.m.Flags.get(::ConfigurablePause.FlagID.WasDay) != isDayTime) {
				if (::World.Assets.isCamping()) {
					this.setPause(true);
				}
			}
		}
		this.m.Flags.set(::ConfigurablePause.FlagID.WasDay, ::World.getTime().IsDaytime);

		return ret;
	}

	q.setPause = @(__original) function( _f ) {
		if (_f || this.m.ConfigurablePause_LastPauseOnSeeEnemy + ::ConfigurablePause.Mod.ModSettings.getSetting("DelayBeforeUnpause").getValue() < ::Time.getExactTime()) {
			return __original(_f);
		}
	}

	q.onProcessInThread = @(__original) function() {
		this.m.ConfigurablePause.IsInThread = true;
		local ret = __original()
		this.m.ConfigurablePause.IsInThread = false;
		return ret;
	}

	q.ConfigurablePause_setPause <- function( _f ) {
		this.m.ConfigurablePause_Pause = _f;
	}

	q.showCombatDialog = @(__original) function( _isPlayerInitiated = true, _isCombatantsVisible = true, _allowFormationPicking = true, _properties = null, _pos = null ) {
		if (::ConfigurablePause.Mod.ModSettings.getSetting("PauseOnCombatDialog").getValue()) {
			this.setPause(true);
		}
		return __original(_isPlayerInitiated, _isCombatantsVisible, _allowFormationPicking, _properties, _pos);
	}

	q.showEventScreen = @(__original) function( _event, _isContract = false, _playSound = true ) {
		local ret = __original(_event, _isContract, _playSound);
		if (ret && ::ConfigurablePause.Mod.ModSettings.getSetting("PauseOnEventScreen").getValue()) {
			this.setPause(true);
		}
		return ret;
	}
})
