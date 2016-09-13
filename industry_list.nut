
// no: number of given industry to plant
// dx: x length to build. If 0 means no flat land required
// dy: y length to build
// ltype: type of location, 0 = land tile not towns, 1 = water only, 2 = cities, 3 = cities replacing houses, 4 = town coastline
// id: FIRS industry id index
INDUSTRY <- { 
				AluminumPlant = {no = 1, dx = 10, dy = 5, ltype = 0, id = 9},
				ArableFarm = {no = 14, dx = 0, dy = 0, ltype = 0, id = 25},
				BauxiteMine	= {no = 8, dx = 5, dy = 4, ltype = 0, id = 6},
				Biorefinery = {no = 1, dx = 5, dy = 5, ltype = 0, id = 43},
				Brewery = {no = 3, dx = 3, dy = 2, ltype = 2, id = 33},
				BrickWorks = {no = 3, dx = 5, dy = 5, ltype = 0, id = 42},
				BuildersYard = {no = 3, dx = 2, dy = 2, ltype = 2, id = 48},
				CementPlant	= {no = 3, dx = 7, dy = 7, ltype = 0, id = 40},
				ClayPit	= {no = 10, dx = 9, dy = 5, ltype = 0, id = 41},
				CoalMine = {no = 10, dx = 3, dy = 4, ltype = 0, id = 0},
				Dairy = {no = 4, dx = 5, dy = 5, ltype = 2, id = 34},
				DairyFarm = {no = 20, dx = 0, dy = 0, ltype = 0, id = 27},
				DredgingSite = {no = 5, dx = 3, dy = 4, ltype = 1, id = 19},
				FertilizerPlant = {no = 1, dx = 7, dy = 7, ltype = 0, id = 37},
				FishingGrounds = {no = 6, dx = 7, dy = 7, ltype = 1, id = 31},
				FishingHarbor = {no = 4, dx = 0, dy = 0, ltype = 4, id = 30},
				FoodMarket = {no = 3, dx = 1, dy = 1, ltype = 3, id = 46},
				Forest = {no = 8, dx = 0, dy = 0, ltype = 0, id = 12},
				FruitPlantation = {no = 20, dx = 0, dy = 0, ltype = 0, id = 29},
				FurnitureFactory = {no = 3, dx = 5, dy = 3, ltype = 2, id = 13},
				GasStation = {no = 3, dx = 2, dy = 2, ltype = 2, id = 47},
				GlassWorks = {no = 3, dx = 4, dy = 4, ltype = 0, id = 21},
				GrainMill = {no = 4, dx = 3, dy = 2, ltype = 2, id = 32},
				HardwareStore = {no = 3, dx = 1, dy = 1, ltype = 3, id = 44},
				Hotel = {no = 3, dx = 2, dy = 2, ltype = 2, id = 45},
				IronOreMine = {no = 8, dx = 4, dy = 4, ltype = 0, id = 18},
				IronWorks = {no = 1, dx = 3, dy = 3, ltype = 0, id = 20},
				JunkYard = {no = 6, dx = 0, dy = 0, ltype = 0, id = 24},
				LimeKiln = {no = 1, dx = 3, dy = 4, ltype = 0, id = 1},
				LumberYard = {no = 1, dx = 5, dy = 5, ltype = 0, id = 38},
				MachineShop = {no = 1, dx = 6, dy = 6, ltype = 0, id = 36},
				MetalFabricationPlant = {no = 5, dx = 3, dy = 5, ltype = 0, id = 3},
				MetalWorkshop = {no = 3, dx = 4, dy = 5, ltype = 0, id = 10},
				MixedFarm = {no = 12, dx = 0, dy = 0, ltype = 0, id = 28},
				OilRefinery	= {no = 1, dx = 4, dy = 5, ltype = 0, id = 4},
				OilRig = {no = 5, dx = 11, dy = 11, ltype = 1, id = 5}, //speciel positioning
				OilWells = {no = 5, dx = 0, dy = 0, ltype = 0, id = 15},
				PaperMill = {no = 3, dx = 0, dy = 0, ltype = 0, id = 14},
				PlasticsPlant = {no = 3, dx = 5, dy = 5, ltype = 0, id = 16},
				Quary = {no = 4, dx = 9, dy = 5, ltype = 0, id = 11},
				RecyclingPlant = {no = 4, dx = 3, dy = 2, ltype = 0, id = 22},
				RecyclingDepot = {no = 15, dx = 2, dy = 2, ltype = 2, id = 23},
				Sawmill = {no = 1, dx = 0, dy = 0, ltype = 0, id = 2},
				SheepFarm = {no = 12, dx = 0, dy = 0, ltype = 0, id = 26},
				SmithyForge = {no = 1, dx = 2, dy = 1, ltype = 3, id = 7},
				SteelMill = {no = 1, dx = 4, dy = 4, ltype = 0, id = 8},
				Stockyard = {no = 3, dx = 5, dy = 4, ltype = 2, id = 35},
				SugarRefinery = {no = 4, dx = 4, dy = 3, ltype = 2, id = 17},
				TextileMill = {no = 4, dx = 5, dy = 4, ltype = 2, id = 39},
};

class Industries
{
	norm = null; // All industries on land (not water) and not in towns
	water = null; // All industries at sea
	town = null; // All industries in towns

	constructor(){
		this.norm = this.TList(0);
		this.water = this.TList(1);
		this.town = this.TList(2); this.town.extend(this.TList(3));this.town.extend(this.TList(4));
	}
}

//// Sorting lists from type
function Industries::TList(type){
	local list = [];
	foreach(i, v in INDUSTRY)
	{
		if(v["ltype"]==type) list.append({id=v["id"], no=v["no"], dx=v["dx"], dy=v["dy"]});
	}
	return list;
}

function Industries::PlaceIndustry(id, tile) //, dx, dy)
{
	if (GSIndustryType.IsValidIndustryType(id)){
//		local IndustryName = GSIndustryType.GetName(id);
//		local x = GSMap.GetTileX(tile);		
//		local y = GSMap.GetTileY(tile);
//		if (dx<0){
//			x = x+dx;
//		}
//		if (dy<0){
//			y = y+dy;
//		}
//		local new_tile = GSMap.GetTileIndex(x, y);
		local succes = GSIndustryType.BuildIndustry(id, tile);
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
//// Below not used.. save for latere reference
// Put an industry in random location on map
function Industries::makeIndustry(type)
{
	if(GSIndustryType.ProspectIndustry(type)){
		Log("Success building: " + GSIndustryType.GetName(type));
	}
	else E("Failed building: " + GSIndustryType.GetName(type));
}
// Put an industry of type IType on random maptile
function Industries::PutIndustry(IType)
{
	local tile = this.RandTile();
	local typename = GSIndustryType.GetName(IType);
	if (GSIndustryType.BuildIndustry(IType,tile)){
		GSSign.BuildSign(tile, "1 - " + typename);
		Log("Success building : " + typename + " at " + GSMap.GetTileY(tile) + ", " + GSMap.GetTileX(tile));
		return true;}
	else { GSSign.BuildSign(tile,"fail");E("Failed building: " + typename + " at " + GSMap.GetTileY(tile) + ", " + GSMap.GetTileX(tile));}

}