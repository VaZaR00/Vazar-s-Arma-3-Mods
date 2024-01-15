_reb_cover = param[1, 3000.0];
_effSTR2 = param[2, 1.0];
_reb = {
	_unit = _this select 0;  											//op_1 or op_2
	_reb_cover = _this select 1;
	while {alive reb_1} do {
		_dron = remoteControlled _unit;  
		_pilot = remoteControlled _dron;  								//op_1 or op_2
		_how_far_1 = _dron distance2d reb_1;
		if ((_unit == _pilot) && (_how_far_1 < _reb_cover) && alive reb_1 && alive _dron) then {
			_eff_str = 9 / ((_how_far_1 / _reb_cover) / (1-(_how_far_1 / _reb_cover)));
			_PP_film = ppEffectCreate ["FilmGrain",2000];
			_PP_film ppEffectEnable true;
			_PP_film ppEffectAdjust [_eff_str,0,2.23,2,2,true];
			_PP_film ppEffectCommit 0;
			["bad connection<br/>please, check your transmitter", -1, -1, 0.5, 0, 0, 789] remoteExec ["BIS_fnc_dynamicText", _unit, true];
			if (_eff_str > 0.32) then {
				["<t color='#ff0000' size = '.8'>losing connection!<br/>immediately land the drone</t>", -1, -1, 0.5, 0.5, 0, 789] remoteExec ["BIS_fnc_dynamicText", _unit, true];
				_dron setDamage 0.017;
				if (!alive _dron) then {
					ppEffectDestroy _PP_film;
				};
			};
			if (_eff_str > 0.7) then {
				_dron setDamage 1;
				ppEffectDestroy _PP_film;
			};
		} 
		else {
			_PP_film = ppEffectCreate ["FilmGrain",2000];
			_PP_film ppEffectEnable true;
			_PP_film ppEffectAdjust [0,0,2.23,2,2,true];
			_PP_film ppEffectCommit 0;
		};
		sleep 0.5;
	};
};
_reb_gun_work = {
	_dron = _this select 0;
	_effSTR2 = _this select 1;
	_unit = _this select 2;
	_bot = remoteControlled _dron;
	_pilot = remoteControlled _bot;
	_bot_ctrl = remoteControlled _pilot;
	while {(alive _dron) && (alive _pilot)} do {
		if ((_effSTR2 > 0)&&(alive _dron)&&(_bot_ctrl == _pilot)) then {
			_PP_film = ppEffectCreate ["FilmGrain",2000];
			_PP_film ppEffectEnable true;
			_PP_film ppEffectAdjust [_effSTR2,0,2.23,2,2,true];
			_PP_film ppEffectCommit 0;
			["<t color='#ff0000' size = '.8'>losing connection!<br/>immediately land the drone</t>", -1, -1, 0.5, 0.5, 0, 789] remoteExec ["BIS_fnc_dynamicText", _unit, true];
			_dron setDamage 0.5;
			[format ["keep seeking..."]] remoteExec ["hint", player];
			if (!alive _dron) then {
				ppEffectDestroy _PP_film;
			};
		}else {
			_PP_film = ppEffectCreate ["FilmGrain",2000];
			_PP_film ppEffectEnable true;
			_PP_film ppEffectAdjust [0,0,2.23,2,2,true];
			_PP_film ppEffectCommit 0;
			[format [""]] remoteExec ["hint", player];
		};
		sleep 0.1;
	};
};
_reb_rifle = {
	_unit = _this select 0;
	_reb_gun_work = _this select 1;
	_effSTR2 = _this select 2;
	{
		while {alive _x} do {
			_aimAt = cursorTarget; 
			_botAimAt = remoteControlled _aimAt;
			_pilotAimAt = remoteControlled _botAimAt;
			_currWeap = currentWeapon _unit;
			_rebGun = "launch_I_Titan_short_F";
			if ((_aimAt == _x)&&(_currWeap == _rebGun)) then {
				[_aimAt, _effSTR2, _pilotAimAt] spawn _reb_gun_work;
			};
			sleep 0.1;
		};
	} forEach allUnitsUAV;
};
[player, _reb_cover] spawn _reb;
[player, _reb_gun_work, _effSTR2] spawn _reb_rifle;