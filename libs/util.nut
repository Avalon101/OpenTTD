


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