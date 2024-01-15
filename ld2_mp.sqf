_num = param[0, 1];
_drone = param[1, allUnitsUAV];
_rmvMavicDropBool = param[2, true];
_execCodeForAssembl = param[3, true];

player setVariable ["_num", _num];
player setVariable ["_bool_1", _rmvMavicDropBool];
player setVariable ["_bool_2", _execCodeForAssembl];
player setVariable ["_drones", _drone];

_grenadesArr = ["rhs_VOG25", "rhs_mag_M441_HE", "rhs_mag_M433_HEDP", "rhs_mag_M397_HET", "rhs_VOG25P", "rhs_mag_f1", "HandGrenade", "rhs_mag_m67", "rhs_mag_rgd5"];
//, "rhs_mag_rgo", "rhs_mag_rgn"

_grenades = param[4, _grenadesArr];

_rmvMavicDrop = {
	params["_drone"];
	{
		_dr = _x;
		_drType = typeOf _dr;
		_drCfg = configFile >> "cfgVehicles" >> _drType;
		_drName = getText (_drCfg >> "displayName");
		if ((_drName == "Mavic-3T") || (_drName == "Mavic-3")) then {
			removeAllActions _dr; 
		};
	}forEach _drone;
};

_start = {
	params["_drone", "_num", "_attachGren", "_grenades", "_closeMenu", "_start"];
	
	_drone addAction ["<t color='#0390fc'>Прикріпити снаряд</t>", {
		params ["_target", "_caller", "_actionId", "_arguments"];
		
		_drone = (_this select 3) select 0;
		_num = (_this select 3) select 1;
		_attachGren = (_this select 3) select 2;
		_grenades = (_this select 3) select 3;
		_closeMenu = (_this select 3) select 4;
		_start = (_this select 3) select 5;
		
		_inv = itemsWithMagazines player;
		_filtArr = [];
		{
			_gr = _x;
			{ if (_x == _gr) then { _filtArr pushBack _x } } forEach _inv;
		}forEach _grenades;
		
		_state = _drone getVariable ["stateG", true];
		
		if (_state == true) then {
			_used = _drone getVariable ["usedG", true];
			if (_used == true) then {
				_AttNum = [];
				_items = [];
				
				//_id = owner _caller;
				
				if (count _filtArr > 0) then {
					{
						_AttNum append [[_x, 0]];
					}forEach _grenades;
					
					_drone setVariable ["stateG", false, true];
					_drone setVariable ["countG", 0, true];
					_drone setVariable ["AttNumG", _AttNum, true];
					_drone setVariable ["Items1", _items, true];
					_drone setVariable ["usedG", false, true];
				
					[_drone, _num, _attachGren, _grenades, _AttNum, _items, _closeMenu, _start] spawn _attachGren;
					[_drone, _num, _attachGren, _grenades, _closeMenu, _start] spawn _closeMenu;
					
					_target removeAction _actionId;
				}else {
					hint "У вас немає снарядів";
				};
			}else {
				_AttNum = _drone getVariable "AttNumG";
				_count = _drone getVariable "countG";
				_items = _drone getVariable "Items1";
				if ((_count > 0) || ((count _filtArr) > 0)) then {
					[_drone, _num, _attachGren, _grenades, _AttNum, _items, _closeMenu, _start] spawn _attachGren;
					[_drone, _num, _attachGren, _grenades, _closeMenu, _start] spawn _closeMenu;
					_drone setVariable ["stateG", false, true];
					_target removeAction _actionId;
				}else {
					hint "У вас немає снарядів";
				};
			};
		}else { hint "Хтось інший цим вже займається"; };
	},[_drone, _num, _attachGren, _grenades, _closeMenu, _start], 0, false, false, "", "!(_this in _target)", 3];
};

_attachGren = {
	params["_drone", "_num", "_attachGren", "_grenades", "_AttNum", "_items", "_closeMenu", "_start"];
	
	{
		removeAllActions _x;
	}forEach [gunner _drone, driver _drone];
	
	_inv = itemsWithMagazines player;
	
	_filtArr = [];
	{
		_gr = _x;
		{ if (_x == _gr) then { _filtArr pushBack _x } } forEach _inv;
	}forEach _grenades;
	
	_ArrInt = _grenades arrayIntersect _filtArr;
	
	_count = _drone getVariable "countG";
	_AttNum = _drone getVariable "AttNumG";
	_items = _drone getVariable "Items1";
	
	{
		_item = _x;
		_itemConfig = configFile >> "CfgMagazines" >> _item;
		_itemName = getText (_itemConfig >> "displayName");
		
		_ItemCount = 0;
		{
			if (_x == _item) then {
				_ItemCount = _ItemCount + 1;
			};
		}forEach _inv;
			
		if (_count < _num) then {
			_drone addAction [format["<t color='#00FF00'>Прикріпити %1: %2</t>", _itemName, _ItemCount], {
				params ["_target", "_caller", "_actionId", "_arguments"];
				
				_drone = (_this select 3) select 0;
				_num = (_this select 3) select 1;
				_AttNum = (_this select 3) select 2;
				_attachGren = (_this select 3) select 3;
				_grenades = (_this select 3) select 4;
				_ArrInt = (_this select 3) select 5;
				_item = (_this select 3) select 6;
				_itemName = (_this select 3) select 7;
				_count = (_this select 3) select 8;
				_items = (_this select 3) select 9;
				_closeMenu = (_this select 3) select 10;
				_start = (_this select 3) select 11;
				{
					if ((_x select 0) == _item) then {
						_element0 = _x select 0;
						_element1 = _x select 1;
						_element1 = _element1 + 1;
						_x set [1, _element1];
						_items pushBack _item;
					};
				}forEach _AttNum;
				
				_count = _count + 1;
				_drone setVariable ["countG", _count, true];
				_drone setVariable ["AttNumG", _AttNum, true];
				_drone setVariable ["Items1", _items, true];
				
				_caller removeItem _item;
				
				//_id = owner _caller;
				hint format["You attached %1", _itemName];
				
				removeAllActions _drone;
				[_drone, _num, _attachGren, _grenades, _AttNum, _items, _closeMenu, _start] spawn _attachGren;
				[_drone, _num, _attachGren, _grenades, _closeMenu, _start] spawn _closeMenu;
				
			}, [_drone, _num, _AttNum, _attachGren, _grenades, _ArrInt, _item, _itemName, _count, _items, _closeMenu, _start], 10, true, false, "", "!(_this in _target)", 3];				
		}else {
			hint "Слоти закінчились!";
		};
		
	}forEach _ArrInt;
	
	if (_count > 0) then {
		
		_IntArr1 = _items arrayIntersect _items;
		
		{
			_item = _x;
			_itemConfig = configFile >> "CfgMagazines" >> _item;
			_itemName = getText (_itemConfig >> "displayName");
			_itemModel = getText (_itemConfig >> "model");
			_itemAmmo = getText (_itemConfig >> "ammo");
			
			_amount = 0;
			{
				if ((_x select 0) == _item) then {
					_amount = _x select 1;
				};
			}forEach _AttNum;
			
			_drone addAction [format["<t color='#fc1c1c'>Зняти %1: %2</t>", _itemName, _amount], {
				params ["_target", "_caller", "_actionId", "_arguments"];
		
				_drone = (_this select 3) select 0;
				_num = (_this select 3) select 1;
				_AttNum = (_this select 3) select 2;
				_attachGren = (_this select 3) select 3;
				_grenades = (_this select 3) select 4;
				_ArrInt = (_this select 3) select 5;
				_item = (_this select 3) select 6;
				_itemAmmo = (_this select 3) select 7;
				_itemModel = (_this select 3) select 8;
				_itemName = (_this select 3) select 9;
				_count = (_this select 3) select 10;
				_items = (_this select 3) select 11;
				_closeMenu = (_this select 3) select 12;
				_start = (_this select 3) select 13;
				{
					if ((_x select 0) == _item) then {
						_element0 = _x select 0;
						_element1 = _x select 1;
						_element1 = _element1 - 1;
						_x set [1, _element1];
						if (_element1 == 0) then {
							_items = _items - [_item];
						};
					};
				}forEach _AttNum;
				
				_count = _count - 1;
				
				_drone setVariable ["countG", _count, true];
				_drone setVariable ["AttNumG", _AttNum, true];
				_drone setVariable ["Items1", _items, true];
				
				_caller addItem _item;
				
				removeAllActions _drone;
				
				//_id = owner _caller;
				hint format["You detached %1", _itemName];
				
				{
					removeAllActions _x;
				}forEach [gunner _drone, driver _drone];
				
				[_drone, _num, _attachGren, _grenades, _AttNum, _items, _closeMenu, _start] spawn _attachGren;
				[_drone, _num, _attachGren, _grenades, _closeMenu, _start] spawn _closeMenu;
				
			}, [_drone, _num, _AttNum, _attachGren, _grenades, _ArrInt, _item, _itemAmmo, _itemModel, _itemName, _count, _items, _closeMenu, _start], 10, true, false, "", "!(_this in _target)", 3];
			{
				_x addAction [format["<t color='#fc1c1c'>Скинути %1: %2</t>", _itemName, _amount],{
					params ["_target", "_caller", "_actionId", "_arguments"];
					
					_drone = (_this select 3) select 0;
					_num = (_this select 3) select 1;
					_AttNum = (_this select 3) select 2;
					_attachGren = (_this select 3) select 3;
					_grenades = (_this select 3) select 4;
					_ArrInt = (_this select 3) select 5;
					_item = (_this select 3) select 6;
					_itemAmmo = (_this select 3) select 7;
					_itemModel = (_this select 3) select 8;
					_itemName = (_this select 3) select 9;
					_count = (_this select 3) select 10;
					_items = (_this select 3) select 11;
					_closeMenu = (_this select 3) select 12;
					_start = (_this select 3) select 13;
					{
						if ((_x select 0) == _item) then {
							_element0 = _x select 0;
							_element1 = _x select 1;
							_element1 = _element1 - 1;
							_x set [1, _element1];
							if (_element1 == 0) then {
								_items = _items - [_item];
							};
						};
					}forEach _AttNum;
					
					_count = _count - 1;
					_drone setVariable ["countG", _count, true];
					_drone setVariable ["AttNumG", _AttNum, true];
					_drone setVariable ["Items1", _items, true];
					
					_droneVelocity = velocity _drone;
					_pos = _target modelToWorld [0,0,-0.2];
					_gren = _itemAmmo createvehicle _pos;
					[_gren, [[0,0,-1],[0.1,0.1,1]]] remoteExec  ["setVectorDirandUp"]; 
					[_gren, [(_droneVelocity select 0) / 1.5, (_droneVelocity select 1) / 1.5 ,-2]] remoteExec  ["setVelocity"];
					
					removeAllActions _drone;
					
					//_id = owner _caller;
					hint format["You dropped %1", _itemName];
					
					[_drone, _num, _attachGren, _grenades, _AttNum, _items, _closeMenu, _start] spawn _attachGren;
					[_drone, _num, _attachGren, _grenades, _closeMenu, _start] spawn _closeMenu;
					
				}, [_drone, _num, _AttNum, _attachGren, _grenades, _ArrInt, _item, _itemAmmo, _itemModel, _itemName, _count, _items, _closeMenu, _start], 10, true, false, ""];
			}forEach [gunner _drone, driver _drone];
		}forEach _IntArr1;
	};
};

_closeMenu = {
	params ["_drone", "_num", "_attachGren", "_grenades", "_closeMenu", "_start"];

	_drone addAction ["<t color='#b01313'>Close menu</t>", {
		params ["_target", "_caller", "_actionId", "_arguments"];
		
		_drone = (_this select 3) select 0;
		_num = (_this select 3) select 1;
		_attachGren = (_this select 3) select 2;
		_grenades = (_this select 3) select 3;
		_closeMenu = (_this select 3) select 4;
		_start = (_this select 3) select 5;
		
		_drone setVariable ["stateG", true, true];
		
		removeAllActions _drone;
		_target removeAction _actionId;
		
		[_drone, _num, _attachGren, _grenades, _closeMenu, _start] spawn _start;
		
	},[_drone, _num, _attachGren, _grenades, _closeMenu, _start], 12, true, true, "", "!(_this in _target)", 3];
};

_actMenuVis = {
	params["_drone", "_num", "_attachGren", "_grenades", "_closeMenu", "_start"];
	
	while {sleep 1; alive player} do {
		_dist = player distance _drone;
		if (_dist > 3) then {
			removeAllActions _drone;
			_drone setVariable ["stateG", true, true];
			[_drone, _num, _attachGren, _grenades, _closeMenu, _start] spawn _start;
		};
	};
};

player addEventHandler ["WeaponAssembled", {
	params ["_unit", "_uav"];
	_num = player getVariable "_num";
	_bool_1 = player getVariable "_bool_1";
	_bool_2 = player getVariable "_bool_2";
	_drones = player getVariable "_drones";
	if ((_uav in allUnitsUAV) and !(_uav in _drones) and (_bool_2 == true)) then {
		[_num, [_uav], _bool_1, _bool_2] execVM "ld2_mp.sqf";
	};
}];

if (_rmvMavicDropBool == true) then {
	[_drone] spawn _rmvMavicDrop;
};

{
	[_x, _num, _attachGren, _grenades, _closeMenu, _start] spawn _start;
	[_x, _num, _attachGren, _grenades, _closeMenu, _start] spawn _actMenuVis;
}forEach _drone;