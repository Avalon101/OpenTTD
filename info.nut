require("version.nut");

class Builder extends GSInfo {
  function GetAuthor()      	{ return "funkyL+Avalon"; }
  function GetName()        	{ return "MapBuilder 3"; }
  function GetDescription()	{ return "A GS to build a new world"; }
  function GetVersion()     	{ return SELF_VERSION; }
  function GetDate()        	{ return "2016-09-09"; }
  function GetShortName() 	{ return "FLBu"; }
  function GetAPIVersion()  	{ return "1.5"; }
  function MinVersionToLoad()	{ return 1; }
  function CreateInstance()	{ return "Builder"; }
  function GetSettings() 	{

		AddSetting({ name = "number_of_players",
				description = "Number of players on the map: ",
				easy_value = 2,
				medium_value = 2,
				hard_value = 2,
				custom_value = 2,
				flags = CONFIG_NONE, min_value = 1, max_value = 4, step_size = 1 });
		AddSetting({ name = "number_of_towns",
				description = "Number of towns per player: ",
				easy_value = 15,
				medium_value = 15,
				hard_value = 15,
				custom_value = 15,
				flags = CONFIG_NONE, min_value = 1, max_value = 100, step_size = 1 });
		AddSetting({ name = "max_town_industries",
				description = "Maxmimum number of industries per town:",
				easy_value = 4,
				medium_value = 4,
				hard_value = 4,
				custom_value = 6,
				flags = CONFIG_NONE, min_value = 1, max_value = 15, step_size = 1 });
  }
}

RegisterGS(Builder());
