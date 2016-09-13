


class Tile
{
	constructor(){}
}

//////////////////////////
//// Functions for random tiles.
function Tile::RandWater()  // Water tile
{
	local tile = 0;
	do{ tile = this.Rand()}
	while(!GSTile.IsWaterTile(tile));
	return tile;
}

function Tile::RandLand() // Land tile
{
	local tile = 0;
	do{ tile = this.Rand()}
	while(GSTile.IsWaterTile(tile));
	return tile;
}

function Tile::Rand() // Any random tile
{
	local mapsize = GSMap.GetMapSize();
	local tile = GSBase.RandRange(mapsize) -1;
	return tile;
}

function Tile::Neighbour(current, dx, dy)
{
	local x = GSMap.GetTileX(current);
	local y = GSMap.GetTileY(current);
	local new_tile = GSMap.GetTileIndex(x+dx, y+dy);
	return new_tile;
}

function Tile::LevelTiles(current, dx, dy)
{
	local startTileX = GSMap.GetTileX(current);
	local startTileY = GSMap.GetTileY(current);

	local endTiles = GSMap.GetTileIndex(startTileX+dx,startTileY+dy);
	
	enum ExpensesType {EXPENSES_CONSTRUCTION = 1};

	//local companyID = GSCompany.ResolveCompanyID(0);
	//Log ("Company Resolved: "+companyID);
	local companyMoneySuccess = GSCompany.ChangeBankBalance(0, 10000000, ExpensesType.EXPENSES_CONSTRUCTION);

	local companyOne = GSCompanyMode(0);

	local succes = GSTile.LevelTiles(current, endTiles);

	return succes;
}