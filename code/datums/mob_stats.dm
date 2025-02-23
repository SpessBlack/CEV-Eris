/datum/stat_holder
	var/list/stat_list = list()

/datum/stat_holder/New()
	for(var/sttype in subtypesof(/datum/stat))
		var/datum/stat/S = new sttype
		stat_list[S.name] = S

/datum/stat_holder/proc/addTempStat(statName, Value, timeDelay)
	var/datum/stat/S = stat_list[statName]
	S.addModif(timeDelay, Value)

/datum/stat_holder/proc/changeStat(statName, Value)
	var/datum/stat/S = stat_list[statName]
	S.changeValue(Value)
	
/datum/stat_holder/proc/setStat(statName, Value)
	var/datum/stat/S = stat_list[statName]
	S.setValue(Value)

/datum/stat_holder/proc/getStat(statName, pure = FALSE)
	if (!islist(statName))
		var/datum/stat/S = stat_list[statName]
		return S ? S.getValue(pure) : 0

//	Those are accept list of stats
//	Compound stat checks.
//	Lowest value among the stats passed in
/datum/stat_holder/proc/getMinStat(var/list/namesList, pure = FALSE)
	if(!islist(namesList))
		log_debug("passed non-list to getMinStat()")
		return 0
	var/lowest = INFINITY
	for (var/name in namesList)
		if(getStat(name, pure) < lowest)
			lowest = getStat(name, pure)
	return lowest

//	Get the highest value among the stats passed in
/datum/stat_holder/proc/getMaxStat(var/list/namesList, pure = FALSE)
	if(!islist(namesList))
		log_debug("passed non-list to getMaxStat()")
		return 0
	var/highest = -INFINITY
	for (var/name in namesList)
		if(getStat(name, pure) > highest)
			highest = getStat(name, pure)
	return highest

//	Sum total of the stats
/datum/stat_holder/proc/getSumOfStat(var/list/namesList, pure = FALSE)
	if(!islist(namesList))
		log_debug("passed non-list to getSumStat()")
		return 0
	var/sum = 0
	for (var/name in namesList)
		sum += getStat(name, pure)
	return sum

//	Get the average (mean) value of the stats
/datum/stat_holder/proc/getAvgStat(var/list/namesList, pure = FALSE)
	if(!islist(namesList))
		log_debug("passed non-list to getAvgStat()")
		return 0
	var/avg = getSumOfStat(namesList, pure)
	return avg / namesList.len

// return value from 0 to 1 based on value of stat, more stat value less return value
// use this proc to get multiplier for decreasing delay time (exaple: "50 * getDelayMult(STAT_ROB, STAT_LEVEL_ADEPT)"  this will result in 5 seconds if stat STAT_ROB = 0 and result will be 0 if STAT_ROB = STAT_LEVEL_ADEPT)
/datum/stat_holder/proc/getDelayMult(statName, statCap = STAT_LEVEL_MAX, pure = FALSE)
    if(!statName)
        return
    return 1 - max(0,min(1,getStat(statName, pure)/statCap))

/datum/stat_holder/proc/Clone()
	var/datum/stat_holder/new_stat = new()
	for (var/S in stat_list)
		new_stat.changeStat(S, src.getStat(S))
	return new_stat

/datum/stat_mod
	var/time = 0
	var/value = 0
	var/id

/datum/stat_mod/New(delay, affect)
	src.time = world.time + delay
	src.value = affect



/datum/stat
	var/name = "Character stat"
	var/desc = "Basic characteristic, you are not supposed to see this. Report to admins."
	var/value = STAT_VALUE_DEFAULT
	var/list/mods

/datum/stat/proc/addModif(delay, affect, id)
	for(var/elem in mods)
		var/datum/stat_mod/SM = elem
		if(SM.id == id)
			SM.time = world.time + delay
			SM.value = affect
			return
	mods += new /datum/stat_mod(delay, affect)

/datum/stat/proc/changeValue(affect)
	value = value + affect

/datum/stat/proc/getValue(pure = FALSE)
	if(pure)
		return value
	else
		. = value
		for(var/elem in mods)
			var/datum/stat_mod/SM = elem
			if(SM.time > world.time)
				mods -= SM
				qdel(SM)
			. += SM.value

/datum/stat/proc/setValue(value)
	src.value = value

/datum/stat/productivity
	name = STAT_MEC
	desc = "The world hadn't ever had so many moving parts or so few labels. Character's ability in building and using various tools.."

/datum/stat/cognition
	name = STAT_COG
	desc = "Too many dots, not enough lines. Knowledge and ability to create new items."

/datum/stat/biology
	name = STAT_BIO
	desc = "What's the difference between being dead, and just not knowing you're alive? Competence in physiology and chemistry."

/datum/stat/physique
	name = STAT_ROB
	desc = "Violence is what people do when they run out of good ideas. Increases your health, damage in unarmed combat, affect the knockdown chance."

/datum/stat/robustness
	name = STAT_TGH
	desc = "You're a tough guy, but I'm a nightmare wrapped in the apocalypse. Enhances your resistance to poisons and also raises your speed in uncomfortable clothes."

/datum/stat/aiming
	name = STAT_VIG
	desc = "Here, paranoia is nothing but a useful trait. Improves your ability to control recoil on guns, helps you resist insanity."

// Use to perform stat checks
/mob/proc/stat_check(stat_path, needed)
	var/points = src.stats.getStat(stat_path)
	return points >= needed

/proc/statPointsToLevel(var/points)
	switch(points)
		if (STAT_LEVEL_NONE to STAT_LEVEL_BASIC)
			return "Untrained"
		if (STAT_LEVEL_BASIC to STAT_LEVEL_ADEPT)
			return "Basic"
		if (STAT_LEVEL_ADEPT to STAT_LEVEL_EXPERT)
			return "Adept"
		if (STAT_LEVEL_EXPERT to STAT_LEVEL_PROF)
			return "Expert"
		if (STAT_LEVEL_PROF to INFINITY)
			return "Master"
