
//// Easy Handles
Log <- GSLog.Info;
E <- GSLog.Error;

//// Load version
require("version.nut");
//// Load industry table
require("libs/industry_list.nut");
//// Load town names
require("libs/town_list.nut");
//// Load Tiles library, for rand tile selection
require("libs/tile.nut");
//// Load player class for keeping track of players cities and other player related stuff
require("libs/player.nut");
//// Load Util class containing various util functions
require("libs/util.nut");
//test

class Builder extends GSController 
{	
	isComplete = null;
	gPlayers = null;
	gTowns = null;
	gTownNames = null;
	gTownIndustries = null;
	players = null;
	constructor() {
		this.isComplete = false;
		this.gPlayers = GSController.GetSetting("number_of_players");
		this.gTowns = GSController.GetSetting("number_of_towns");
		this.gTownNames = TownNames;
		this.gTownIndustries = GSController.GetSetting("max_town_industries");
		players = []; for(local p=1; p<=this.gPlayers; p++) players.append(Player());
	}
}
function Builder::Start()
{
	Log("Builder has begun!");		
	/*foreach(i,v in GSTownList()){			// for testing town not getting renamed
		Log(GSTown.IsValidTown(i) + " : " + i + " : " + GSTown.GetName(i));
	}*/ 
	if (this.isComplete == false) {
		//GSGame.Pause();			//Pause game while GS is building the map.
		this.Init();		// running some basic settings and other necessary stuff.. dont change this.
		this.RunOnce();		// Building the towns and industries, assigning evenly between players. (the actual things we want to make with this script)
		Util.MoneySetBalance(100000); //reset money to starting balance in case it has change during script.
		//GSGame.Unpause();
	}
	else if (this.isComplete == true) Log("Script has already been run!");
	Log("Builder has finished!");
	while (true)
	{
		this.Sleep(6000);
	}
}

function Builder::Init()
{	
	Util.ChangeSetting("construction.command_pause_level", 3); // Make it possible to build while game is pause.
	Util.ResetRandom();
	this.gTownNames = Util.Randomize(this.gTownNames);
}

/// SAVE and LOAD
function Builder::Save()
{
	local save_table = {};
	save_table.scriptComplete <- this.isComplete;
	Log("Saving game state");
	return save_table;
}
function Builder::Load(version, data)
{
	Log("Loading game state");
	if (data.rawin("scriptComplete")) {
		this.isComplete = data.rawget("scriptComplete");
	}
}

//// RunOnce() makes sure that the script won't be run everytime the game loads.
function Builder::RunOnce(){
	while(!this.isComplete){
		// Make all towns for all players
		this.MakeTowns(49);
		this.AssignTowns();
		//Placing industry signs
		this.AssignTownIndustries();
		//foreach(j, player in this.players){ Util.SetSignsTown(player.towns) }	// Set signs in towns ( obsolete when planting making indstries)

		local indu = Industries();
		// Function responsible for all things cencerning placement of land industies on the map.
		foreach(i,v in indu.norm) this.MakeIndustries(GSIndustryType.GetName(v["id"]), v["no"], v["dx"], v["dy"], v["id"], true); 

		// Function responsible for all things cencerning placement of water industies on the map.
		foreach(i,v in indu.water) this.MakeIndustries(GSIndustryType.GetName(v["id"]), v["no"], v["dx"], v["dy"], v["id"],false);

		//Placing industries in towns:
		this.placeTownIndustries(indu);

		this.isComplete = true;
	}
}

//// MakeTowns creates a town at random location.
function Builder::MakeTowns(minDistance)
{
	while(GSTown.GetTownCount()< (this.gTowns * this.gPlayers))
	{
		local isTownFounded = false;
		while(!isTownFounded)
		{
			local tile = Tile().RandLand();
			local closestTown = GSTile.GetClosestTown(tile);
			local distanceTownToTile = GSTown.GetDistanceManhattanToTile(closestTown, tile);
			if (distanceTownToTile > minDistance)
			{
				if(GSTown.FoundTown(tile, 0, false, 3, 0)){
					//Log(GSTown.GetTownCount() + " Town founded!");
					isTownFounded = true;
				} //else { E("Town not founded. Unknown reason! Trying new location..")}
			} //else { E("Too close to another town! Retrying with new location..")}
		}
	}
	Log(GSTown.GetTownCount() + " towns has been created.");
}


function Builder::AssignTowns()
{
	// converting GS API List type to  Squirrel array
	local townList = [];
	foreach(i,v in GSTownList()){ townList.append(i)} // Creates townList, descending
	while(townList.len() > 0){
		for(local p=0; p<this.gPlayers; p++){
			local townID = townList.pop();
			local townName = this.gTownNames.pop();
			local newName = (p+1) + " - " + townName;
			//Log(GSTown.IsValidTown(townID) + " : " + townID + " : " + GSTown.GetName(townID) + " : " + newName + ";" +newName.len());
			//local namechange = false;
			//while(!namechange){	if(GSTown.SetName(townID,newName)){namechange = true} else{Log(GSTown.IsValidTown(townID) + " : " + townID + " : " + GSTown.GetName(townID) + " : " + newName + ";" +newName.len()); assert(false)}}
			GSTown.SetName(townID, newName);
			this.players[p].AddTown(townID);
		}
	}
	Log(this.gTowns + " towns assigned to each player.");
}


//// AssignTownIndustries assigns all the industries from the industry_list.nut that
//// has been marked for towns. Industries are assigned to random towns in the
//// players town table.

function Builder::AssignTownIndustries(){
	for(local p=1; p<=this.gPlayers; p++){
		local ilist_temp = Industries().town;
		// Remove Recycle depot from list (idx 0). Assign each town as first industry for every town.
		local recycle_depot = ilist_temp[0]; ilist_temp.remove(0);
		foreach(i, playerTowns in this.players[p-1].towns)
			{ this.players[p-1].towns[i].industries.append(23)}

		// Copy players towntable for a working copy. The copy will replace the players towntable when finished working on it.
		local ptown_tables = this.players[p-1].towns;

		// For each industry, pull random town belonging to player and assign that industry to the city.
		// Subtract 1 from the  count in ilist_temp for that industry.
		// Do this as long as the count > 0;			//cycle industries
		while(ilist_temp.len()>0){
			local current_industry = ilist_temp.pop();
			while(current_industry["no"] > 0){
				local rand_idx = GSBase.RandRange(ptown_tables.len()); // find random town

				if(ptown_tables[rand_idx].industries.len() < this.gTownIndustries){ // check if town has max number of industries already
					local its_a_dupe = false;
					foreach(i,indu_id in ptown_tables[rand_idx].industries){ // cylces industries already in town
						if(current_industry["id"] == indu_id) its_a_dupe = true;	// check if industry already exists in town.
					}
					if (its_a_dupe==false){		// if industry not already in town, add industry to town
						ptown_tables[rand_idx].industries.append(current_industry["id"]);	// adds industry to town to keep track of industries in every town
						this.players[p-1].towns = ptown_tables;				// update the town industry list for this current player
						current_industry["no"]--;	// subtract from counter, so we only put desired amount of this industry on the map
					}
				}
			}
		}
		// Add the recycle depot(industryID 23) we set aside earlier. add it to every town.


		// Log the players towns and assigned industries in those towns.
		Log(" "); // empty line
		Log("----------------Player"+p+" has towns: "+ ptown_tables.len() + "----------------");
		foreach(i,table in ptown_tables) {
			Log(GSTown.GetName(table["town_id"]) + " has been assigned " + (table.industries.len())  + " industries");
			foreach(i,industry in table.industries)
				{ Log("         " + GSIndustryType.GetName(industry)) }
		}
	}
	return;
}

////Function for placing Industries.
function Builder::MakeIndustries(text, amount, dx, dy, id, isLandTile){
	local tile = 0;
	//This function loops once per number of Industry of each type per player in industry list. Oo
	for(local i=0; i<amount; i++)
		{
			for(local n=1; n<=this.gPlayers; n++){
				local industryPlaced = false;
				local bufferX = 10;
				local bufferY = 10;
				do{
					//Log("Trying to place: "+text);
					do{
						//get random tile (also limits the industry placeable area on the map to map size -15 on each axis)
						tile = Tile().DrawRandomTile(isLandTile);
					//a fuction that evaluates the tile is ok in all ways before moving on.				
					}
					while(!(Tile.CheckAll(tile, dx, dy, bufferX, bufferY)));	
					
					if(id==30){
						local coastTile = false;
						local newTile = null;
						local tileIsOK = true;
						local xTile = null;
						local yTile = null;

						xTile = GSMap.GetTileX(tile);
						yTile = GSMap.GetTileY(tile);							
						local x = 0;
						local y = 0;
						local i = GSBase.RandRange(2); // skal ændres til 4 når havnene kan placeres på nordlige / vestlige kanter.
						Log ("i: "+i);
						if (i==0){
							x = -1;
							y = 0;
						} else if (i==1){
							x = 0;
							y = -1;
						} else if (i==2){
							x = 1;
							y = 0;
						} else if (i==3){
							x = 0;
							y = 1;
						}
						do{
							xTile = xTile + x;
							yTile = yTile + y;
							tileIsOK = Util.CheckBorders(xTile, yTile);

							newTile = GSMap.GetTileIndex(xTile, yTile);								
							coastTile = GSTile.IsCoastTile(newTile);
						} while (tileIsOK && !coastTile);
						if(coastTile){
							tile = newTile;
						}
					}

					//level an area around a tile equal to industry size (NOTE: this funcion returns true even if only a few tiles was leveled!)
					local tilesSucessfullyLeveled = Tile().LevelTiles(tile, dx, dy);

					//place industry							
					local industryBuildable = GSIndustryType.CanBuildIndustry(id);
					if (industryBuildable) {
						industryPlaced = Util().PlaceIndustry(id, tile);
					}
				}while(!industryPlaced);
			//set sign	
			local signText = n+" - "+text;	
			Util.SetSign(signText, tile);
			}
		}	
}

function Builder::placeTownIndustries(indu){
	for(local p=1; p<=this.gPlayers; p++){
		local ptown_tables = this.players[p-1].towns;
		foreach(i, town_id in ptown_tables){
			Log ("-------------NEW TOWN--------------");
			local townId = town_id["town_id"];
			foreach(j, industryId in ptown_tables[i].industries){
				Log ("-------------NEW INDUSTRY--------------");
				//Log ("town itteration number: "+i);
				//Log ("industry itteration number: "+j);
				//Log ("industryId: "+industryId);
				//Log("Town list length: "+ptown_tables.len());

				local townTile = GSTown.GetLocation(townId);
				//Log ("townId: "+townId);

				//Create a small search grid of tiles aound the town in context:
				local townTileX = GSMap.GetTileX(townTile);
				local townTileY = GSMap.GetTileY(townTile);
				//Log("townTileX:"+townTileX);
				//Log("townTileY:"+townTileY);				
				local townGridList = Util.CreateSearchGrid(townTileX, townTileY);
				
				//Create the allowed industry placement area around the town in context:
				local townIndustryPlacementArrayList = Util.GetTownIndustryPlacementArray(townGridList, townId, industryId);

				//get the size of the Industry in context from town list. (Omkriv koden!)
				//-----------------------------------------------
				local deltaXYList = [];
				foreach(i,v in indu.town){
					if(v["id"]==industryId){
						deltaXYList.append({dx=v["dx"], dy=v["dy"]});
						break;
					}
				}
				
				local dx = null;
				local dy = null;
				foreach(i,v in deltaXYList){
					dx = v["dx"];
					dy = v["dy"];
				}
				
				Log("dx: "+dx);
				Log("dy: "+dy);
				//Log("townIndustryPlacementArrayList length: "+townIndustryPlacementArrayList.len());
				//-----------------------------------------------
				
				//pick a random tile within the towns placement area and test if an industry can be build on that tile.
				local randomTile = null;
				local industryPlaced = false;
				//The outer loop evaluates if the industry in context has been build upon the selected tile.
				do {	
					//the inner loop checks if the randomly selected tile within the towns placement area is buildable acording to a few rules.
					do {
						local randomTileIndex = GSBase.RandRange(townIndustryPlacementArrayList.len());
						if (industryId == 23){
							townIndustryPlacementArrayList = Util.Randomize(townIndustryPlacementArrayList);
							randomTile = townIndustryPlacementArrayList.pop();
						} else {
							randomTile = townIndustryPlacementArrayList[randomTileIndex];
						}
						Log("Industry Id= "+GSIndustryType.GetName(industryId));
						Log("Town name: "+GSTown.GetName(townId));

						Log("townTileX:"+townTileX);
						Log("townTileY:"+townTileY);
						Log("randomTileX: "+GSMap.GetTileX(randomTile));
						Log("randomTileY: "+GSMap.GetTileY(randomTile));

						//x og y coordinates are move a distance equal to the aize of the industry in context)
						local tileX = GSMap.GetTileX(randomTile);
						local tileY = GSMap.GetTileY(randomTile);
						Log("tileX: "+tileX);
						Log("tileY: "+tileY);
						local xOffset = Util().TownAreaOffset(tileX,townTileX);
						local yOffset = Util().TownAreaOffset(tileY,townTileY);
						
						if (xOffset){
							tileX = tileX-dx;
						}
						if (yOffset){
							tileY = tileY-dy;
						}
						randomTile = GSMap.GetTileIndex(tileX, tileY);
						//Log("randomTile X has been ofset tile by: "+dx);
						//Log("randomTile Y has been ofset tile by: "+dy);

						if (!Tile().CheckTownArea(randomTile) && townIndustryPlacementArrayList.len() == 0) {
							local townExpanded = GSTown.ExpandTown(townId, 2); //town is expanded by 2 houses.
							Log ("Town has been expanded!");
							if (GSTown.GetHouseCount(townId) > 10){
								E("town nr "+townId+" has grown too large ! - build map again =(");
								assert(false);
							}
							townIndustryPlacementArrayList = Util.GetTownIndustryPlacementArray(townGridList, townId, industryId);
						}	
					}
					while(!Tile().CheckTownArea(randomTile));

					//level an area around a tile equal to industry size (NOTE: this funcion returns true even if only a few tiles was leveled!)
					local tilesSucessfullyLeveled = Tile().LevelTiles(randomTile, dx, dy);					
					//Log("tile was leveled: "+tilesSucessfullyLeveled);

					local industryBuildable = GSIndustryType.CanBuildIndustry(industryId);
					//We are curently not placing junk yards (id=24), thus we force the check to evaluate true.
					if(industryBuildable) {
						//place industry:
						industryPlaced = Util().PlaceIndustry(industryId, randomTile);
					} else {
						E("Industry is not buildable: "+industryId);
					}

					//Then the loop runs all over again.
					if (industryId == 23){
						//Log("townIndustryPlacementArrayList length =" +townIndustryPlacementArrayList.len());
						if (!industryPlaced && townIndustryPlacementArrayList.len() == 0) {
							local townExpanded = GSTown.ExpandTown(townId, 2); //town is expanded by 2 houses.
							Log ("Town has been expanded!");
							if (GSTown.GetHouseCount(townId) > 10){
								E("town nr "+townId+" has grown too large ! - build map again =(");
								assert(false);
							}
							townIndustryPlacementArrayList = Util.GetTownIndustryPlacementArray(townGridList, townId, industryId);
						}	
					} /*else if (industryId == 47) {
						industryPlaced = true;
					}*/
				}while(!industryPlaced);
				
				//set industry sign
				local text = GSIndustryType.GetName(industryId);
				local signText = p+" - "+text;	
				Util.SetSign(signText, randomTile);
			}
		}
	}
}