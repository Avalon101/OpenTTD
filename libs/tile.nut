require("util.nut");


class Tile
{
	constructor(){}
}


function Tile::CheckTownArea(tile){
	local result = false;

	local waterTile = GSTile.IsWaterTile(tile);	
	local coastTile = GSTile.IsCoastTile (tile);
	//local buildable = GSTile.IsBuildable(tile);	
	local waterlevel = false;
	if (GSTile.GetMinHeight(tile) == 0) {
	waterlevel = true;
	}	
	//if (buildable && !waterTile && !coastTile && !waterlevel) {
	if (!waterTile && !coastTile && !waterlevel) {
		result = true;
	}	
	return result;
}

//// Evaluate random tile if its possible to build industry here:
function Tile::CheckAll(tile, dx, dy, bufferX, bufferY){
	local result = false;

	local waterTile = GSTile.IsWaterTile(tile);
	if (!waterTile) {
		local buildable = GSTile.IsBuildable(tile);//evaluate tile is buildbable (not too steep and not a shore tile) and that an area around the tile is buildable.
 		local coastTile = GSTile.IsCoastTile (tile);
 		local waterlevel = false;
 		if (GSTile.GetMinHeight(tile) == 0) {
			waterlevel = true;
 		}
		local steepSlope = GSTile.IsSteepSlope(GSTile.GetSlope(tile));
		local buildableRectangle = GSTile.IsBuildableRectangle(tile, dx+bufferX, dy+bufferY); //A buffer is added to dx and dy to ensure that raising the landscape wont accidently happen too close to other already placed industries or a city.

		//Jeg kan ikke finde en metode som checker at vi rent faktisk KAN level før vi prøver =(

		if (buildable && buildableRectangle && !coastTile && !steepSlope && !waterlevel){
			result = true;
		}	
	} else {
		result = true;
	}
	return result;
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
	local endTile = GSMap.GetTileIndex(startTileX+dx,startTileY+dy);

	enum ExpensesType {EXPENSES_CONSTRUCTION = 1};

	//local balance = GSCompany.GetBankBalance(0); 
	//local companyMoneySuccess = GSCompany.ChangeBankBalance(0, 1000000+(1000000-balance), ExpensesType.EXPENSES_CONSTRUCTION);
	Util.MoneySetBalance(1000000000);
	local companyOne = GSCompanyMode(0);

	local succes = GSTile.LevelTiles(current, endTile);

	return succes;
}

//////////////////////////
//// Functions for random tiles.

function Tile::DrawRandomTile(isLandTile){ // Select between land or water tile
	local tile =0;
	if (isLandTile == true){
		tile = Tile().RandLand();
	} else {
		tile = Tile().RandWater();
	}
	return tile;
}

function Tile::RandCoast()
{
	local tile = 0;
	do{ tile = this.Rand()}
	while(!GSTile.IsCoastTile(tile));
	return tile;
}

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
	local tile = 0;
	local mapsize = GSMap.GetMapSize();
	do{tile = GSBase.RandRange(mapsize) -15} //reducing the axis of the maps by 15 tiles to ensure we will always place the industries within the map borders.
	while (!GSMap.IsValidTile(tile));
	return tile;
}