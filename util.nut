


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