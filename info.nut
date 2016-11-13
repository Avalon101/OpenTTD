require("version.nut");

class Builder extends GSInfo {
  function GetAuthor()      	{ return "funkyL+Avalon"; }
  function GetName()        	{ return "MapBuilder 3"; }
  function GetDescription()	{ return "A GS to build a new world"; }
  function GetVersion()     	{ return SELF_VERSION; }
  function GetDate()        	{ return "2016-10-01"; }
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
				description = "Maxmimum number of random industries per town:",
				easy_value = 7,
				medium_value = 7,
				hard_value = 7,
				custom_value = 7,
				flags = CONFIG_NONE, min_value = 6, max_value = 15, step_size = 1 });
		AddSetting({ name = "industry_amount_variation",
				description = "Industry variation:",
				easy_value = 1,
				medium_value = 2,
				hard_value = 3,
				custom_value = 1,
				flags = CONFIG_NONE, min_value = 1, max_value = 3, step_size = 1 });
		AddLabels("industry_amount_variation", {_1 = "Normal", _2 = "Second option", _3 = "Third option" } );
  }
}

RegisterGS(Builder());
