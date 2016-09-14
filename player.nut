




class Player
{
	towns = null;

	constructor(){
		this.towns = [];
	}
}

function Player::AddTown(id)
{
	this.towns.append({town_id=id, industries=[]})
}