state("Receiver2"){

	//the player's current rank: 0=intro, 1=baseline (where speedruns start), 2=asleep, 3=sleepwalker, 4=liminal, 5=awake
	byte rank : "UnityPlayer.dll", 0x017E1BD8, 0x8, 0x10, 0x30, 0x18, 0x28, 0x150, 0x94;

	//global timer pointer, in seconds
	float time : "UnityPlayer.dll", 0x0017E1BD8, 0x8, 0x10, 0x30, 0x18, 0x28, 0x30, 0x54;

	//player HP: only ever uses 2 values, 0 (dead) and 1 (alive).
	byte hp : "UnityPlayer.dll", 0x017C1280, 0x20, 0x10, 0x20, 0x120, 0x18;

	//the time displayed in the pause menu, in whole seconds
	int menuTime : "UnityPlayer.dll", 0x017C1A60, 0x3F0, 0x40, 0x68, 0x28, 0x78, 0x2E8, 0x134;

}

init{
	refreshRate = 30;
}

start{
	/*
	start is delayed by 2 seconds to prevent multiple livesplit timer resets;
	when the player selects "yes" to restarting or dies, the in-game timer resets, 
	then increments to 1, then resets again before keeping time as it should.
	the final condition is to prevent the timer from starting itself
	in the middle of a loaded session (i.e. on game startup)
	*/
	if(current.rank == 1 && current.hp == 1 && current.time >= 2 && current.time <= 3){
		return true;
	}
}

gameTime{
	TimeSpan gt = TimeSpan.FromSeconds(current.time);
	return gt;
}

reset{
	//if the in-game timer is reset
	if (current.time < old.time){
		return true;
	}
}

split{
	if (current.rank == (old.rank + 1)){
			return true;
	}

	/*
	for the final split, where the player's rank won't increase.
	will split when the player opens the pause menu (to view the final time)
	I couldn't find a memory pointer that stores the amount of tapes collected,
	which would be useful to see if the player has actually reached the win state,
	but opening the menu to check the timer at the end is a requirement in the speedrun rules.
	just don't pause on the last level until you've gotten all 3 tapes!
	*/
	else if (current.rank == 5 && current.menuTime > old.menuTime){
		return true;
	}
}
