


class Util
{
	constructor(){}
}

////////////////////////////////////////////////////
//// Functions for different stuff.
////////////////////////////////////////////////////

function Util::IndustryCheck(current_industry, indu_id)
{	
	local industryCheck = false;
	//GrainMill (32)
	//Brewery (33)
	//HardwareStore (44)
	//Hotel (45)
	//FoodMarket (46)
	//GasStation (47)
	//BuildersYard (48)

	
	if(current_industry["id"] == 32 && indu_id == 33) industryCheck = true; //Placing: GrainMill - not possible if town has: Brewery
	if(current_industry["id"] == 33 && indu_id == 32) industryCheck = true; //Placing: Brewery - not possible if town has: GrainMill

	if(current_industry["id"] == 45 && (indu_id == 46 || indu_id == 47)) industryCheck = true; //Placing: Hotel - not possible if town has: FoodMarket OR GasStation 
	if(current_industry["id"] == 46 && (indu_id == 47 || indu_id == 45)) industryCheck = true; //Placing: FoodMarket - not possible if town has: GasStation OR Hotel
	if(current_industry["id"] == 47 && (indu_id == 44 || indu_id == 45 || indu_id == 46)) industryCheck = true; //Placing: GasStation - not possible if town has: HardwareStore / Hotel / FoodMarket / BuildersYard
	if(current_industry["id"] == 44 && (indu_id == 48 || indu_id == 47)) industryCheck = true; //Placing: HardwareStore - not possible if town has: BuildersYard / GasStation
	if(current_industry["id"] == 48 && (indu_id == 47 || indu_id == 44)) industryCheck = true; //Placing: BuildersYard - not possible if town has: GasStation / HardwareStore
	return industryCheck;
}

function Util::CreateSearchGrid(townTileX, townTileY)
{
	//check we dont go beyond the map borders
	local townGridXStart = Util.BordersMin(townTileX);
	local townGridYStart = Util.BordersMin(townTileY);
	local townGridXEnd = Util.BordersMax(townTileX, GSMap.GetMapSizeX()); //Note: kortet ingame i TTD er 2 felter mindre end hvad mapsize returnerer !
	local townGridYEnd = Util.BordersMax(townTileY, GSMap.GetMapSizeY()); //Note: kortet ingame i TTD er 2 felter mindre end hvad mapsize returnerer !

	Log("townGridXStart: "+townGridXStart);
	Log("townGridYStart: "+townGridYStart);
	Log("townGridXEnd: "+townGridXEnd);
	Log("townGridYEnd: "+townGridYEnd);

	local townGridStartTile = GSMap.GetTileIndex(townGridXStart, townGridYStart);
	local townGridEndTile = GSMap.GetTileIndex(townGridXEnd, townGridYEnd);

	local townGridList = GSTileList();				
	townGridList.AddRectangle(townGridStartTile,townGridEndTile);
	return townGridList;
}

function Util::GetTownIndustryPlacementArray(townGridList, townId, industryId)
{	
	local maxDistanceFromTownCenter = 7;
	local current_tile = null;
	local withinTownInfluence = false;
	local townIndustryPlacementArrayList = GSTileList();
	for(current_tile = townGridList.Begin(); !townGridList.IsEnd(); current_tile = townGridList.Next()) {
		local manhattanDistance = GSTown.GetDistanceManhattanToTile(townId, current_tile);		
		if (industryId == 23){
			if (GSTile.IsWithinTownInfluence(current_tile,townId)){
				townIndustryPlacementArrayList.AddTile(current_tile);
			}
		} else if (manhattanDistance <= maxDistanceFromTownCenter){
			//local companyOne = GSCompanyMode(0);
			//local tree = GSTile.PlantTree(current_tile);
			townIndustryPlacementArrayList.AddTile(current_tile);
			//Log("Tile was manhattanDistance of "+manhattanDistance+" to town");
			//Log("Tile X: "+GSMap.GetTileX(current_tile));
			//Log("Tile Y: "+GSMap.GetTileY(current_tile));
		}
	}
	local townIndustryPlacementArrayListArray = [];
	for(current_tile = townIndustryPlacementArrayList.Begin(); !townIndustryPlacementArrayList.IsEnd(); current_tile = townIndustryPlacementArrayList.Next()) {					
		townIndustryPlacementArrayListArray.append(current_tile);
	}
	//g("townIndustryPlacementArrayListArray length: "+townIndustryPlacementArrayListArray.len());
	return townIndustryPlacementArrayListArray;
}

function Util::TownAreaOffset(tileValue, townTileValue)
{	
	local offset = false;
	if (tileValue<townTileValue){
		offset = true;
	}
	return offset;
}

function Util::BordersMin(tile)  // Check that the tile in context does not go beyond the map borders (less then 0)
{	
	local delta = 1;
	if (tile-19 > 0){
		delta = tile-19;
	}
	return delta;
}

function Util::BordersMax(tile, mapsize)  // Check that the tile in context does not go beyond the map borders (More then max)
{	
	local delta = mapsize-2; ////Note: kortet ingame i TTD er 2 felter mindre end hvad mapsize returnerer !
	if (tile+19 < mapsize){				
		delta = tile+19;
	}
	return delta;
}

//This function places an Industry.
function Util::PlaceIndustry(id, tile)
{	
	if (GSIndustryType.IsValidIndustryType(id)){
		local success = GSIndustryType.BuildIndustry(id, tile);
		return success;
	} else {
		Log("Invalid IndustryType: "+id);
	}
}

//////////////////////////////
// Change current balance to desired absolute value, compared to built-in relative change.
function Util::MoneySetBalance(new_balance)
{
	local balance = GSCompany.GetBankBalance(GSCompany.COMPANY_FIRST);
	//local loan = GSCompany.GetLoanAmount();
	local money_diff = new_balance - balance;
	GSCompany.ChangeBankBalance(GSCompany.COMPANY_FIRST, money_diff, GSCompany.EXPENSES_TRAIN_INC);
}

///////////////////////////////////
//// Make sure the random generator won't start at same point every time you load at same save point.
function Util::ResetRandom()
{
	local systime0 = GSDate.GetSystemTime();
	local skip = systime0 % 997;
	//Log("Skipping " + skip + " random calls!");
	for(local i=0; i<skip; i++){GSBase.RandRangeItem(0,1024);}
	local timecount = GSDate.GetSystemTime() - systime0;
	Log("Skipped " + skip + " random calls in " + timecount + " seconds!");
}

//////////////////////////////
// Randomize a list
function Util::Randomize(old_list)
{
	local new_list = [];
	while(old_list.len()>0)
	{
		local i = GSBase.RandRange(old_list.len());
		new_list.append(old_list[i]);
		old_list.remove(i);
	}
	return new_list;
}

//////////////////////////////
// Shorten the process of handling settings.
function Util::ChangeSetting(setting, value)
{
	if (GSGameSettings.IsValid(setting))
	{
		GSGameSettings.SetValue(setting, value);
		return true;
	}
	else{ E("Somthing went wrong.. please contact developer!");return false;}
}

//// SetSign() puts a single sign with text [text] and tile [tile]. Fucntion is used by SetSigns() to put
//// several signs at random location at once.
function Util::SetSign(text, tile)
{
	//local text = GSIndustryType.GetName(type.id)
	if (GSSign.IsValidSign(GSSign.BuildSign(tile, text)))
		{ Log("Sign planted: '" + text + "', " + GSMap.GetTileX(tile) + ", " + GSMap.GetTileY(tile)) + ", " + tile;
		  return true;}
	else 
		{ E("Couldn't plant sign '" + text + "', "  + GSMap.GetTileX(tile) + ", " + GSMap.GetTileY(tile)) + ", " + tile;
		  return false}	
}

// unused
//// SetSigns() can put a select amount of signs at different random locations. landtile defines if
//// the tile is land or water; set to true for land, false for water
function Util::SetSigns(text, amount, dx, dy, id, landtile = true)
{
	local tile = 512;
	for(local i=0; i<amount; i++)
	{
		for(local n=1; n<=this.gPlayers; n++)
		{
			local text = n + " - " + text;
			do{
				if (landtile == true){ tile = Tile().RandLand()}
				else { tile = Tile().RandWater()}
			}
			while(!(this.SetSign(text, tile)));		
			local delta = Util().Borders(tile, dx, dy);
			dx = delta[0];
			dy = delta[1];
			local succes = Tile().LevelTiles(tile, dx, dy);
			local succes = Industries().PlaceIndustry(id, tile); //, dx, dy);
		}
	}
}


// Set signs in towns for each industry assigned to that town.
function Util::SetSignsTown(playerTownTable)
{
	foreach(i, townSet in playerTownTable)
	{
		local towntile = GSTown.GetLocation(playerTownTable[i].town_id);	// find the tile location of town center
		foreach( j, industry in townSet.industries)
		{
			local signtile = Tile.Neighbour(towntile,j+1, j+1); // Get the tile location for the tile below last industry sign in town. This makes sure the signs a set up on a pretty list and are readable.
			local text = "Town - " + GSIndustryType.GetName(industry);	// create the text for the sign (" Town - [industryname]")
			Util.SetSign(text, signtile);	// plant sign
		}
	}
}





