


class Util
{
	constructor(){}
}

//////////////////////////
//// Functions for different stuff.
function Util::Borders(tile, dx, dy)  // Check that the placement of industries does not go beyond the map borders
{
			if (GSMap.GetTileX(tile)+dx>GSMap.GetMapSizeX()){				
				Log("dx has been inverted!");
				Log("dx = "+dx);
				dx = -dx;
				Log("dx = "+dx);
				Log("Tile X = "+GSMap.GetTileX(tile));
				Log("Mapsize X = "+GSMap.GetMapSizeX());
				Log("dy = "+dy);
				Log("Tile Y = "+GSMap.GetTileY(tile));
				Log("Mapsize Y = "+GSMap.GetMapSizeY());
			}
			if (GSMap.GetTileY(tile)+dy>GSMap.GetMapSizeY()){				
				Log("dy has been inverted!");
				Log("dy = "+dy);
				dy = -dy;
				Log("dy = "+dy);
				Log("Tile Y = "+GSMap.GetTileY(tile));
				Log("Mapsize Y = "+GSMap.GetMapSizeY());				
				Log("dx = "+dx);
				Log("Tile X = "+GSMap.GetTileX(tile));
				Log("Mapsize X = "+GSMap.GetMapSizeX());
			}
			local delta = [dx, dy];
			return delta;
}

//This function places an Industry.
function Util::PlaceIndustry(id, tile)
{
	if (GSIndustryType.IsValidIndustryType(id)){
		local success = GSIndustryType.BuildIndustry(id, tile);
		return success;
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
function util::SetSigns(text, amount, dx, dy, id, landtile = true)
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







