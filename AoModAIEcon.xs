//==============================================================================
// AoMod
// AoModAIEcon.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// Handles common economy functions.
//==============================================================================

//==============================================================================
rule updateWoodBreakdown
minInterval 12
inactive
{   
    if (ShowAiEcho == true) aiEcho("updateWoodBreakdown: ");
    if ((aiGetGameMode() == cGameModeDeathmatch) && (kbGetAge() < cAge4) && (xsGetTime() < 4*60*1000))
	return;
    int mainBaseID = kbBaseGetMainID(cMyID);
	int randomBaseID = mainBaseID;
    int randomBase = findUnit(cUnitTypeAbstractSettlement);
    if (randomBase >= 0)
    {
        randomBaseID = kbUnitGetBaseID(randomBase);
	}
	
    if ((aiRandInt(4) < 2) && (randomBaseID != mainBaseID))
    {
        randomBaseID = mainBaseID;
	}
	
    int woodPriority = 50;
    if (cMyCulture == cCultureEgyptian)
    woodPriority = 55;

    float ResSupply = kbResourceGet(cResourceWood) * 1.2;
	float Forecast = gWoodForecast;
	if (Forecast <= 200)
	Forecast = 200;

	float Ponti = 0.0;
	if(ResSupply < Forecast)
    Ponti = 0.0; 
    else
    Ponti = ResSupply/Forecast -1;

    float Percentage = 1.0;
    Percentage = Percentage - Ponti;
    if (Percentage > 1.0)
	Percentage = 1.0; 
    else if (Percentage < 0.1)
	Percentage = 0.1; 
    
    int gathererCount = kbUnitCount(cMyID,cUnitTypeAbstractVillager,cUnitStateAlive);
    int woodGathererCount = 0.5 + aiGetResourceGathererPercentage(cResourceWood, cRGPActual) * gathererCount;
    int closeMainBaseSites = kbGetNumberValidResources(mainBaseID, cResourceWood, cAIResourceSubTypeEasy);
	bool reducedWoodGathererCount = false;
	if ((woodGathererCount <= 0) && (kbGetAge() < cAge3) && (closeMainBaseSites > 0))
	{	
	    woodGathererCount = 1;
        reducedWoodGathererCount = true;
	}		
	
    // If we have no need for wood, set plans=0 and exit
    if (woodGathererCount <= 0)
    {
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, 0);
        aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, mainBaseID);
        if (gWoodBaseID != mainBaseID)
		aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, gWoodBaseID);
        return;
	}  
    // If we're this far, we need some wood gatherers.  The number of plans we use will be the greater of 
    // a) the ideal number for this number of gatherers, or
    // b) the number of plans active that have resource sites, either main base or wood base.
	
    //Count of sites.
    int numberMainBaseSites = kbGetNumberValidResources(mainBaseID, cResourceWood, cAIResourceSubTypeEasy);
    int numberWoodBaseSites = 0;
    if ((gWoodBaseID >= 0) && (gWoodBaseID != mainBaseID))    // Count wood base if different
	numberWoodBaseSites = kbGetNumberValidResources(gWoodBaseID, cResourceWood, cAIResourceSubTypeEasy);

    //Get the count of plans we currently have going.
    int numWoodPlans = aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0);
	
	int desiredWoodPlans = 1 + (woodGathererCount/12);
	if (cMyCulture == cCultureAtlantean)
	desiredWoodPlans = 1 + (woodGathererCount/4);
	
	if (desiredWoodPlans >= 2)
	desiredWoodPlans = 2;
	
	if ((kbGetAge() == cAge1) && (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching) || (kbGetAge() == cAge2) && (kbUnitCount(cMyID,cUnitTypeAge2Building, cUnitStateAlive) < 2))
    desiredWoodPlans = 1;
    
	if (woodGathererCount < desiredWoodPlans)
	desiredWoodPlans = woodGathererCount;
    
	if ((desiredWoodPlans < numWoodPlans) && (reducedWoodGathererCount == false))
    desiredWoodPlans = numWoodPlans;    // Try to preserve existing plans
	
    if (ShowAiEcho == true) aiEcho("desiredWoodPlans: "+desiredWoodPlans);
    // Three cases are possible:
    // 1)  We have enough sites at our main base.  All should work in main base.
    // 2)  We have some wood at main, but not enough.  Split the sites
    // 3)  We have no wood at main...use woodBase
	
    if (numberMainBaseSites >= desiredWoodPlans) // case 1
    {
        // remove any breakdown for woodBaseID
        if (gWoodBaseID != mainBaseID)
		aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, gWoodBaseID);
        gWoodBaseID = mainBaseID;
        aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans, woodPriority, Percentage, mainBaseID);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);
        return;
	}
	
    if ( (numberMainBaseSites > 0) && (numberMainBaseSites < desiredWoodPlans) )  // case 2
    {
        aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, numberMainBaseSites, woodPriority, Percentage, mainBaseID);
		
        if (numberWoodBaseSites > 0)  // We do have remote wood
        {
            aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans - numberMainBaseSites, woodPriority, Percentage, gWoodBaseID);		
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);
		}
        else  // No remote wood...bummer.  Kill old breakdown, look for more
        {
			if (gWoodBaseID != mainBaseID)		
            aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, gWoodBaseID);   // Remove old breakdown
            //Try to find a new wood base.
			if (ResourceBaseID != -1)
			gWoodBaseID=kbBaseFindCreateResourceBase(cResourceWood, cAIResourceSubTypeEasy, ResourceBaseID);
			
			if (gWoodBaseID < 0)
			gWoodBaseID=kbBaseFindCreateResourceBase(cResourceWood, cAIResourceSubTypeEasy, randomBaseID);
            if (gWoodBaseID >= 0)
            {
                aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans - numberMainBaseSites, woodPriority, Percentage, gWoodBaseID);	
				aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);      // We can have the full amount
			}
            else
            {
                aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, numberMainBaseSites);   // That's all we get
			}
		}
        return;
	}
	
    if (numberMainBaseSites < 1)  // case 3
    {
        aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy,mainBaseID);
		
        if (numberWoodBaseSites >= desiredWoodPlans)  // We have enough remote wood
        {
            aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans, woodPriority, Percentage, gWoodBaseID);
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);
		}
        else if (numberWoodBaseSites > 0)   // We have some, but not enough
        {
            aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, numberWoodBaseSites, woodPriority, Percentage, gWoodBaseID);
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, numberWoodBaseSites);
		}
        else  // We have none, try elsewhere
        {
            int oldWoodBase=gWoodBaseID;
            aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, gWoodBaseID);   // Remove old breakdown
            //Try to find a new wood base.
			if (ResourceBaseID != -1)
			gWoodBaseID=kbBaseFindCreateResourceBase(cResourceWood, cAIResourceSubTypeEasy, ResourceBaseID);
			
			if (gWoodBaseID < 0)
			gWoodBaseID=kbBaseFindCreateResourceBase(cResourceWood, cAIResourceSubTypeEasy, randomBaseID);
            if ((gWoodBaseID < 0) && (gTransportMap == true)) // did not find base on my mainbase
            {
                // try to find a wood base on another island
                gWoodBaseID = newResourceBase(oldWoodBase, cResourceWood);
			}			
			
            if (gWoodBaseID >= 0)
            {
				numberWoodBaseSites = kbGetNumberValidResources(gWoodBaseID, cResourceWood, cAIResourceSubTypeEasy);
                if (numberWoodBaseSites < desiredWoodPlans)
				desiredWoodPlans = numberWoodBaseSites;
                aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);      
                aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans, woodPriority, Percentage, gWoodBaseID);
			}
		}
        return;
	}
}

//==============================================================================
rule updateGoldBreakdown
minInterval 13
inactive
{
    if (ShowAiEcho == true) aiEcho("updateGoldBreakdown: ");
    if ((aiGetGameMode() == cGameModeDeathmatch) && (kbGetAge() < cAge4) && (xsGetTime() < 4*60*1000))
	return;
    int mainBaseID = kbBaseGetMainID(cMyID);
	int randomBaseID = mainBaseID;
    int randomBase = findUnit(cUnitTypeAbstractSettlement);
    if (randomBase >= 0)
    {
        randomBaseID = kbUnitGetBaseID(randomBase);
	}
	
    if ((aiRandInt(4) < 2) && (randomBaseID != mainBaseID))
    {
        randomBaseID = mainBaseID;
	}
	
    int goldPriority = 50; // Same as wood for non-Egyptians
    if (cMyCulture == cCultureEgyptian)
    goldPriority = 56;	

    float ResSupply = kbResourceGet(cResourceGold) * 1.2;
	float Forecast = gGoldForecast;
	if (Forecast <= 200)
	Forecast = 200;
 
	float Ponti = 0.0;
	if(ResSupply < Forecast)
    Ponti = 0.0; 
    else
    Ponti = ResSupply/Forecast -1;

    float Percentage = 1.0;
    Percentage = Percentage - Ponti;
    if (Percentage > 1.0)
	Percentage = 1.0; 
    else if (Percentage < 0.1)
	Percentage = 0.1; 
	
    int gathererCount = kbUnitCount(cMyID,cUnitTypeAbstractVillager,cUnitStateAlive);
    int goldGathererCount = 0.5 + aiGetResourceGathererPercentage(cResourceGold, cRGPActual) * gathererCount;
    int closeMainBaseSites = kbGetNumberValidResources(mainBaseID, cResourceGold, cAIResourceSubTypeEasy);
	bool reducedGoldGathererCount = false;
	if ((goldGathererCount <= 0) && (kbGetAge() < cAge3) && (closeMainBaseSites > 0))
	{	
	    goldGathererCount = 1;
        reducedGoldGathererCount = true;
	}		
	
    // If we have no need for gold, set plans=0 and exit
    if (goldGathererCount <= 0)
    {
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, 0);
        aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, mainBaseID);
        if (gGoldBaseID != mainBaseID)
		aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, gGoldBaseID);
        return;
	}  
    // If we're this far, we need some gold gatherers.  The number of plans we use will be the greater of 
    // a) the ideal number for this number of gatherers, or
    // b) the number of plans active that have resource sites, either main base or gold base.
	
    //Count of sites.
    int numberMainBaseSites = kbGetNumberValidResources(mainBaseID, cResourceGold, cAIResourceSubTypeEasy);
    int numberGoldBaseSites = 0;
    if ((gGoldBaseID >= 0) && (gGoldBaseID != mainBaseID))    // Count gold base if different
	numberGoldBaseSites = kbGetNumberValidResources(gGoldBaseID, cResourceGold, cAIResourceSubTypeEasy);
	
    //Get the count of plans we currently have going.
    int numGoldPlans = aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0);
	
	int desiredGoldPlans = 1 + (goldGathererCount/12);
	if (cMyCulture == cCultureAtlantean)
	desiredGoldPlans = 1 + (goldGathererCount/4);
	
	if (desiredGoldPlans >= 2)
	desiredGoldPlans = 2;
	
	if ((kbGetAge() == cAge1) || (kbGetAge() == cAge2) && (kbUnitCount(cMyID,cUnitTypeAge2Building, cUnitStateAlive) < 2))
    desiredGoldPlans = 1;
    
	if (goldGathererCount < desiredGoldPlans)
	desiredGoldPlans = goldGathererCount;
    
	if ((desiredGoldPlans < numGoldPlans) && (reducedGoldGathererCount == false))
    desiredGoldPlans = numGoldPlans;    // Try to preserve existing plans

	if (numberMainBaseSites > 0)
		numberMainBaseSites = 1;
    if (ShowAiEcho == true) aiEcho("desiredGoldPlans: "+desiredGoldPlans);
    // Three cases are possible:
    // 1)  We have enough sites at our main base.  All should work in main base.
    // 2)  We have some gold at main, but not enough.  Split the sites
    // 3)  We have no gold at main...use goldBase
	
    if (numberMainBaseSites >= desiredGoldPlans) // case 1
    {
        // remove any breakdown for goldBaseID
        if (gGoldBaseID != mainBaseID)
		aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, gGoldBaseID);
        gGoldBaseID = mainBaseID;
        aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans, goldPriority, Percentage, mainBaseID);
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);
        return;
	}
	
    if ( (numberMainBaseSites > 0) && (numberMainBaseSites < desiredGoldPlans) )  // case 2
    {
        aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, numberMainBaseSites, goldPriority, Percentage, mainBaseID);
		
        if (numberGoldBaseSites > 0)  // We do have remote gold
        {
            aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans - numberMainBaseSites, goldPriority, Percentage, gGoldBaseID);
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);
		}
        else  // No remote gold...bummer.  Kill old breakdown, look for more
        {
			if (gGoldBaseID != mainBaseID)
            aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, gGoldBaseID);   // Remove old breakdown
            //Try to find a new gold base.
			if (ResourceBaseID != -1)
			gGoldBaseID=kbBaseFindCreateResourceBase(cResourceGold, cAIResourceSubTypeEasy, ResourceBaseID);
            if (gGoldBaseID < 0)
			gGoldBaseID=kbBaseFindCreateResourceBase(cResourceGold, cAIResourceSubTypeEasy, randomBaseID);
            if (gGoldBaseID >= 0)
            {
                aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);      // We can have the full amount
                aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans - numberMainBaseSites, goldPriority, Percentage, gGoldBaseID);
			}
            else
            {
                aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, numberMainBaseSites);   // That's all we get
			}
		}
        return;
	}
	
    if (numberMainBaseSites < 1)  // case 3
    {
        aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy,mainBaseID);
		
        if (numberGoldBaseSites >= desiredGoldPlans)  // We have enough remote gold
        {
            aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans, goldPriority, Percentage, gGoldBaseID);
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);
		}
        else if (numberGoldBaseSites > 0)   // We have some, but not enough
        {
            aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, numberGoldBaseSites, goldPriority, Percentage, gGoldBaseID);
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, numberGoldBaseSites);
		}
        else  // We have none, try elsewhere
        {
            int oldGoldBase=gGoldBaseID;
            aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, gGoldBaseID);   // Remove old breakdown
            //Try to find a new gold base.
			if (ResourceBaseID != -1)
			gGoldBaseID=kbBaseFindCreateResourceBase(cResourceGold, cAIResourceSubTypeEasy, ResourceBaseID);
			if (gGoldBaseID < 0)
			gGoldBaseID=kbBaseFindCreateResourceBase(cResourceGold, cAIResourceSubTypeEasy, randomBaseID);
			
            if ((gGoldBaseID < 0) && (gTransportMap == true)) // did not find base on my mainbase
            {
                // try to find a gold base on another island
                gGoldBaseID = newResourceBase(oldGoldBase, cResourceGold);
			}			
			
            if (gGoldBaseID >= 0)
            {
				numberGoldBaseSites = kbGetNumberValidResources(gGoldBaseID, cResourceGold, cAIResourceSubTypeEasy);
                if (numberGoldBaseSites < desiredGoldPlans)
				desiredGoldPlans = numberGoldBaseSites;
                aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);      
                aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans, goldPriority, Percentage, gGoldBaseID);
			}
		}
        return;
	}
}
//==============================================================================
rule updateFoodBreakdown
minInterval 9
inactive
{
    if (ShowAiEcho == true) aiEcho("updateFoodBreakdown: ");
    if ((aiGetGameMode() == cGameModeDeathmatch) && (kbGetAge() < cAge4) && (xsGetTime() < 4*60*1000))
	return;   
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
    int easyPriority = 65;
    int aggressivePriority = 45;
    int mainFarmPriority = 90;
    int otherFarmPriority = 88;
    if (kbGetAge() < cAge2)
	{
        if (cMyCulture == cCultureNorse)
	    aggressivePriority = 66; // above wood/gold so it doesn't steal the oxcart
        else 
	    aggressivePriority = 60;
	}

    int numAggressivePlans = aiGetResourceBreakdownNumberPlans(cResourceFood, cAIResourceSubTypeHuntAggressive, mainBaseID);
	float distance = gMaximumBaseResourceDistance;
	
    //Get the number of valid resources spots.
    int numberAggressiveResourceSpots = kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeHuntAggressive, distance);
    int numberEasyResourceSpots = kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeEasy, distance);	
	
    // Only do one aggressive site at a time, they tend to take lots of gatherers
    if (numberAggressiveResourceSpots > 1)
	numberAggressiveResourceSpots = 1;
	
    int totalNumberResourceSpots = numberAggressiveResourceSpots + numberEasyResourceSpots;
	
    int gathererCount = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    int foodGathererCount = 0.5 + aiGetResourceGathererPercentage(cResourceFood, cRGPActual) * gathererCount;
    
    if (foodGathererCount <= 0) //always some units on food
    {
        if (totalNumberResourceSpots > 0)
        foodGathererCount = 2;
        else
        foodGathererCount = 1;
    }

	MoreFarms = foodGathererCount; // Update build more farms
	if (MoreFarms >= 32)
	MoreFarms = 32;
    if ((cMyCulture == cCultureAtlantean) && (MoreFarms > 10))
	MoreFarms = 10;

    // Preference order is existing farms (except in age 1), new farms if low on food sites, aggressive hunt (size permitting), easy, then age 1 farms.  
    int aggHunters = 0;
    int easy = 0;
    int farmers = 0;
    int unassigned = foodGathererCount;
    int farmerReserve = 0;  // Number of farms we already have, use them first unless Egypt first age (slow slow farming)
    int farmerPreBuild = 0; // Number of farmers to ask for ahead of time when food starts running low.
    int farmerReserveOtherBase1 = 0;  // Number of farms we already have at our otherBase1
    int farmerReserveOtherBase2 = 0;  // Number of farms we already have at our otherBase2
    int farmerReserveOtherBase3 = 0;  // Number of farms we already have at our otherBase3
    int farmerReserveOtherBase4 = 0;  // Number of farms we already have at our otherBase4
    
    int numBuilding1NearBase = -1;
    int numFortressesNearBase = -1;
    int numTowersNearBase = -1;
    float distanceToMainBase = 0.0;
    vector otherBaseLocation = cInvalidVector;
    int requiredTowers = 1;
    int farmsWanted = 1;
	
    if (gFarmBaseID >= 0)  // Farms get first priority
    {
        int building1ID = -1;
        if (cMyCulture == cCultureEgyptian)
		building1ID = cUnitTypeBarracks;
        else if (cMyCulture == cCultureGreek)
		building1ID = cUnitTypeStable;
        else if (cMyCulture == cCultureNorse)
		building1ID = cUnitTypeLonghouse;
        else if (cMyCulture == cCultureChinese)
		building1ID = cUnitTypeBarracksChinese;			
        else if (cMyCulture == cCultureAtlantean)
		building1ID = cUnitTypeBarracksAtlantean;
        farmerReserve = kbBaseGetNumberUnits(cMyID, gFarmBaseID, -1, cUnitTypeFarm);

        if (gOtherBase1ID > 0)
        {
            otherBaseLocation = kbBaseGetLocation(cMyID, gOtherBase1ID);
            numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            numFortressesNearBase = getNumUnits(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            numTowersNearBase = getNumUnits(cUnitTypeTower, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
            
            if (distanceToMainBase < 100.0)
            {
                requiredTowers = 0;
				farmsWanted = 3;
			    if (cMyCulture == cCultureAtlantean)
			    farmsWanted = 1; // just one for atlanteans.	
			}
            
            if (((numFortressesNearBase > 0) && ((numBuilding1NearBase > 0) || (numTowersNearBase > requiredTowers)))
			|| ((numBuilding1NearBase > 0) && (numTowersNearBase > requiredTowers + 1)))
            {
                farmerReserveOtherBase1 = kbBaseGetNumberUnits(cMyID, gOtherBase1ID, -1, cUnitTypeFarm);
                if (farmerReserveOtherBase1 < farmsWanted)
				farmerReserveOtherBase1 = farmerReserveOtherBase1 + 1;
                if (farmerReserveOtherBase1 > farmsWanted)
				farmerReserveOtherBase1 = farmsWanted;
                farmerReserve = farmerReserve + farmerReserveOtherBase1;
			}
		}
        if (gOtherBase2ID > 0)
        {
            otherBaseLocation = kbBaseGetLocation(cMyID, gOtherBase2ID);
            numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            numFortressesNearBase = getNumUnits(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            numTowersNearBase = getNumUnits(cUnitTypeTower, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
            
            if (distanceToMainBase < 100.0)
            {
                requiredTowers = 0;
				farmsWanted = 3;
			    if (cMyCulture == cCultureAtlantean)
			    farmsWanted = 1; // just one for atlanteans.					
			}
            
            if (((numFortressesNearBase > 0) && ((numBuilding1NearBase > 0) || (numTowersNearBase > requiredTowers)))
			|| ((numBuilding1NearBase > 0) && (numTowersNearBase > requiredTowers + 1)))
            {
                farmerReserveOtherBase2 = kbBaseGetNumberUnits(cMyID, gOtherBase2ID, -1, cUnitTypeFarm);
                if (farmerReserveOtherBase2 < farmsWanted)
				farmerReserveOtherBase2 = farmerReserveOtherBase2 + 1;
                if (farmerReserveOtherBase2 > farmsWanted)
				farmerReserveOtherBase2 = farmsWanted;
                farmerReserve = farmerReserve + farmerReserveOtherBase2;
			}
		}
        if (gOtherBase3ID > 0)
        {
            otherBaseLocation = kbBaseGetLocation(cMyID, gOtherBase3ID);
            numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            numFortressesNearBase = getNumUnits(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            numTowersNearBase = getNumUnits(cUnitTypeTower, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
            
            if (distanceToMainBase < 100.0)
            {
                requiredTowers = 0;
				farmsWanted = 3;
			    if (cMyCulture == cCultureAtlantean)
			    farmsWanted = 1; // just one for atlanteans.					
			}
            
            if (((numFortressesNearBase > 0) && ((numBuilding1NearBase > 0) || (numTowersNearBase > requiredTowers)))
			|| ((numBuilding1NearBase > 0) && (numTowersNearBase > requiredTowers + 1)))
            {
                farmerReserveOtherBase3 = kbBaseGetNumberUnits(cMyID, gOtherBase3ID, -1, cUnitTypeFarm);
                if (farmerReserveOtherBase3 < farmsWanted)
				farmerReserveOtherBase3 = farmerReserveOtherBase3 + 1;
                if (farmerReserveOtherBase3 > farmsWanted)
				farmerReserveOtherBase3 = farmsWanted;
                farmerReserve = farmerReserve + farmerReserveOtherBase3;
			}
		}
        if (gOtherBase4ID > 0)
        {
            otherBaseLocation = kbBaseGetLocation(cMyID, gOtherBase4ID);
            numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            numFortressesNearBase = getNumUnits(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            numTowersNearBase = getNumUnits(cUnitTypeTower, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
            distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
            
            if (distanceToMainBase < 100.0)
            {
                requiredTowers = 0;
				farmsWanted = 3;
			    if (cMyCulture == cCultureAtlantean)
			    farmsWanted = 1; // just one for atlanteans.					
			}
            
            if (((numFortressesNearBase > 0) && ((numBuilding1NearBase > 0) || (numTowersNearBase > requiredTowers)))
			|| ((numBuilding1NearBase > 0) && (numTowersNearBase > requiredTowers + 1)))
            {
                farmerReserveOtherBase4 = kbBaseGetNumberUnits(cMyID, gOtherBase4ID, -1, cUnitTypeFarm);
                if (farmerReserveOtherBase4 < farmsWanted)
				farmerReserveOtherBase4 = farmerReserveOtherBase4 + 1;
                if (farmerReserveOtherBase4 > farmsWanted)
				farmerReserveOtherBase4 = farmsWanted;
                farmerReserve = farmerReserve + farmerReserveOtherBase4;
			}
		}
	}
    
    if (farmerReserve > unassigned)
	farmerReserve = unassigned;   // Can't reserve more than we have!
	
    if ((farmerReserve > 0) && (kbGetAge() > cAge1))
    {
        unassigned = unassigned - farmerReserve;
	}
	
	float aggressiveAmount = kbGetAmountValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeHuntAggressive, distance);
    float easyAmount = kbGetAmountValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeEasy, distance);
	float totalAmount = aggressiveAmount + easyAmount;

    if ((aiGetGameMode() == cGameModeLightning) || (aiGetGameMode() == cGameModeDeathmatch) 
	|| (xsGetTime() > 10*60*1000))
	totalAmount = 200; 

    if ((kbGetAge() > cAge1) || ((cMyCulture == cCultureEgyptian) && (xsGetTime() > 3*60*1000)))   // can build farms
    {
        if ((totalNumberResourceSpots < 2) || (totalAmount <= 1500) || (gFarming == true) || (kbGetAge() >= cAge3) || (aiGetWorldDifficulty() == cDifficultyNightmare))
        {
            if (cMyCulture == cCultureAtlantean)
		    farmerPreBuild = 2;  
            else
			farmerPreBuild = 4;  
			if (farmerPreBuild > unassigned)
            farmerPreBuild = unassigned;
            unassigned = unassigned - farmerPreBuild;
			if (farmerPreBuild > 0)
			gFarming = true;
			static bool extraFarms = false;
			if (extraFarms == false)
			{
				if ((aiGetGameMode() != cGameModeLightning) && (aiGetWorldDifficulty() == cDifficultyHard))
				xsEnableRule("buildExtraFarms");
				extraFarms = true;
			}			
		    
	     
		 }
	}

    if ((unassigned <= 0) && (totalNumberResourceSpots > 0))
    {
        if (numberEasyResourceSpots > 0)
        {
            if (cMyCulture == cCultureAtlantean)
            unassigned = 1;
            else
            unassigned = 3;
        }
        else
        {
            if (cMyCulture == cCultureAtlantean)
            unassigned = aiGetMinNumberNeedForGatheringAggressives();
            else
            unassigned = aiGetMinNumberNeedForGatheringAggressives() - 1;
        }
    }	
	
	int numPlansWanted = 2;
	int farmThreshold = 20;
    if (cMyCulture == cCultureAtlantean)
    farmThreshold = 7;
    
	if ((gFarming == true) && (farmerReserve >= farmThreshold))
    numPlansWanted = 1;

    if (unassigned <= 0)
    {
        if (kbGetAge() < cAge3)
        {
            unassigned = 1;
        }
        else
        numPlansWanted = 0;
    }	
	
    int numTemples = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding);
    int houseProtoID = cUnitTypeLogicalTypeHouses;
    if (cMyCulture == cCultureAtlantean)
	numTemples = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
    int numHouses = kbUnitCount(cMyID, houseProtoID, cUnitStateAlive);
    
    if ((kbGetAge() == cAge1) && (numTemples < 1) || (unassigned < numPlansWanted) || (kbGetAge() == cAge1) && (cMyCulture == cCultureNorse))
    {
        numPlansWanted = 1;
    }
	
    if (unassigned <= 0)
    {
        numPlansWanted = 0;
    }
	
    if (numPlansWanted > totalNumberResourceSpots)
    {
        if ((totalNumberResourceSpots < 1) && (kbGetAge() < cAge3))
        numPlansWanted = 1;
        else
        numPlansWanted = totalNumberResourceSpots;
    }

    int numPlansUnassigned = numPlansWanted;
    int minVillsToStartAggressive = aiGetMinNumberNeedForGatheringAggressives();

    int HuntPlanState = aiPlanGetState(findPlanByString("AutoGPFoodHuntAggressive"));
    // Start a new plan if we have enough villies and we have the resource.
    // If we have a plan open, don't kill it as long as we are within 2 of the needed min...the plan will steal from elsewhere.
    if ((numPlansUnassigned > 0) && (numberAggressiveResourceSpots > 0)
    && (unassigned > minVillsToStartAggressive) || (numAggressivePlans > 0) && (HuntPlanState > 0) && (unassigned >= minVillsToStartAggressive - 2))
    {
		aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 1);
		aggHunters = aiGetMinNumberNeedForGatheringAggressives(); // This plan will over-grab due to high priority
		if (numPlansUnassigned == 1)
		aggHunters = unassigned - 1;   // use them all if we're small enough for 1 plan		
		numPlansUnassigned = numPlansUnassigned - 1;
		unassigned = unassigned - aggHunters;
		numberAggressiveResourceSpots = 1;  // indicates 1 used
	}
    else  // Can't go aggressive
    {
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 0);
        numberAggressiveResourceSpots = 0;  // indicate none used
	}
	
    if ((numPlansUnassigned > 0) && (numberEasyResourceSpots > 0))
    {
        if (numberEasyResourceSpots > numPlansUnassigned)
		numberEasyResourceSpots = numPlansUnassigned;
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, numberEasyResourceSpots);
        easy = (numberEasyResourceSpots * unassigned) / numPlansUnassigned;
        unassigned = unassigned - easy;
        numPlansUnassigned = numPlansUnassigned - numberEasyResourceSpots;
	}
    else
    {
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 0);
        numberEasyResourceSpots = 0;
	}
    // If we still have some unassigned, and we're in the first age, try to dump them into a plan.
    if ((kbGetAge() == cAge1) && (unassigned > 0))
    {
        if ((aggHunters > 0) && (unassigned > 0))
        {
            aggHunters = aggHunters + unassigned;
            unassigned = 0;
		}
		
        if ((easy > 0) && (unassigned > 0))
        {
            easy = easy + unassigned;
            unassigned = 0;
		}
		
        // If we're here and unassigned > 0, we'll just make an easy plan and dump them there, hoping
        // that there's easy food somewhere outside our base.
        numberEasyResourceSpots = numberEasyResourceSpots + 1;
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, numberEasyResourceSpots);
        easy = easy + unassigned;
        unassigned = 0;
	    if ((gMaximumBaseResourceDistance < 110.0) && (kbGetAge() <cAge2))
		gMaximumBaseResourceDistance = gMaximumBaseResourceDistance + 10.0; 
	}  	
	
    // Now, the number of farmers we want is the unassigned total, plus reserve (existing farms) and prebuild (plan ahead).
    farmers = farmerReserve + farmerPreBuild;
    unassigned = unassigned - farmers;
	
	
    if (unassigned > 0)
    {  
        // Still unassigned?  Make an extra easy plan, hope they can find food somewhere
        numberEasyResourceSpots = numberEasyResourceSpots + 1;
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, numberEasyResourceSpots);
        easy = easy + unassigned;
        unassigned = 0;
	}
    
	int numFarmPlansWanted = 0;
    if (farmers > 0)
    {
        int farmersAtMainBase = 0;
        farmersAtMainBase = farmers;
        if (gOtherBase1ID > 0)
        {
            if ((farmersAtMainBase > 1) && (farmerReserveOtherBase1 > 0))
            {
                if (farmersAtMainBase < farmerReserveOtherBase1)
				farmerReserveOtherBase1 = farmersAtMainBase;
                farmersAtMainBase = farmersAtMainBase - farmerReserveOtherBase1;
                numFarmPlansWanted = numFarmPlansWanted + 1;
			}
		}
        if (gOtherBase2ID > 0)
        {
            if ((farmersAtMainBase > 1) && (farmerReserveOtherBase2 > 0))
            {
                if (farmersAtMainBase < farmerReserveOtherBase2)
				farmerReserveOtherBase2 = farmersAtMainBase;
                farmersAtMainBase = farmersAtMainBase - farmerReserveOtherBase2;
                numFarmPlansWanted = numFarmPlansWanted + 1;
			}
		}
        if (gOtherBase3ID > 0)
        {
            if ((farmersAtMainBase > 1) && (farmerReserveOtherBase3 > 0))
            {
                if (farmersAtMainBase < farmerReserveOtherBase3)
				farmerReserveOtherBase3 = farmersAtMainBase;
                farmersAtMainBase = farmersAtMainBase - farmerReserveOtherBase3;
                numFarmPlansWanted = numFarmPlansWanted + 1;
			}
		}
        if (gOtherBase4ID > 0)
        {
            if ((farmersAtMainBase > 1) && (farmerReserveOtherBase4 > 0))
            {
                if (farmersAtMainBase < farmerReserveOtherBase4)
				farmerReserveOtherBase4 = farmersAtMainBase;
                farmersAtMainBase = farmersAtMainBase - farmerReserveOtherBase4;
                numFarmPlansWanted = numFarmPlansWanted + 1;
			}
		}
        
        if (farmersAtMainBase < 0)
		farmersAtMainBase = 0;
		
        if (farmersAtMainBase > 0)
        {
            if (cMyCulture == cCultureAtlantean)
            {
                numFarmPlansWanted = numFarmPlansWanted + 1;
			}
            else
            {
				if ((aiGetWorldDifficulty() >= cDifficultyHard) && (aiGetGameMode() != cGameModeLightning))
			    numFarmPlansWanted = numFarmPlansWanted + 2;	
				else numFarmPlansWanted = numFarmPlansWanted + 1;
			}                
		}
        gFarming = true;
	}
    else
	gFarming = false;
	
	
    //Egyptians can farm in the first age.
    if (((kbGetAge() > 0) || (cMyCulture == cCultureEgyptian)) && (gFarmBaseID != -1) && (xsGetTime() > 2*60*1000))
    {
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, numFarmPlansWanted);
	}
    else
    {
        numFarmPlansWanted = 0;
	}
	
	
    //Set breakdown based on goals.
    if (gOtherBase1ID > 0)
    {
        if ((numFarmPlansWanted > 1) && (farmerReserveOtherBase1 > 0))
        {
            aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, 1, otherFarmPriority, (100.0*farmerReserveOtherBase1)/(foodGathererCount*100.0), gOtherBase1ID);
            numFarmPlansWanted = numFarmPlansWanted -1;
		}
        else
		aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, 0, otherFarmPriority, 0, gOtherBase1ID);
	}
    
    if (gOtherBase2ID > 0)
    {
        if ((numFarmPlansWanted > 1) && (farmerReserveOtherBase2 > 0))
        {
            aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, 1, otherFarmPriority, (100.0*farmerReserveOtherBase2)/(foodGathererCount*100.0), gOtherBase2ID);
            numFarmPlansWanted = numFarmPlansWanted -1;
		}
        else
		aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, 0, otherFarmPriority, 0, gOtherBase2ID);
	}
	
    if (gOtherBase3ID > 0)
    {
        if ((numFarmPlansWanted > 1) && (farmerReserveOtherBase3 > 0))
        {
            aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, 1, otherFarmPriority, (100.0*farmerReserveOtherBase3)/(foodGathererCount*100.0), gOtherBase3ID);
            numFarmPlansWanted = numFarmPlansWanted -1;
		}
        else
		aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, 0, otherFarmPriority, 0, gOtherBase3ID);
	}
	
    if (gOtherBase4ID > 0)
    {
        if ((numFarmPlansWanted > 1) && (farmerReserveOtherBase4 > 0))
        {
            aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, 1, otherFarmPriority, (100.0*farmerReserveOtherBase4)/(foodGathererCount*100.0), gOtherBase4ID);
            numFarmPlansWanted = numFarmPlansWanted -1;
		}
        else
		aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, 0, otherFarmPriority, 0, gOtherBase4ID);
	}
	
    aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, numFarmPlansWanted, mainFarmPriority, (100.0*farmersAtMainBase)/(foodGathererCount*100.0), gFarmBaseID);
    aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, numberAggressiveResourceSpots, aggressivePriority, (100.0*aggHunters)/(foodGathererCount*100.0), mainBaseID); 
    aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, numberEasyResourceSpots, easyPriority, (100.0*easy)/(foodGathererCount*100.0), mainBaseID);
	
	//Check the current farm base for a settlement.. and try to relocate the second plan on Hard difficulty.	
	if ((aiGetWorldDifficulty() >= cDifficultyHard) && (aiGetGameMode() != cGameModeLightning) && (cMyCulture != cCultureAtlantean) && (cvMapSubType != VINLANDSAGAMAP))
	{
		for (i = 0; < numFarmPlansWanted)
		{
			int FarmPlanID = aiPlanGetIDByIndex(cPlanFarm, -1, true, i);
			if (FarmPlanID == -1)
			continue;
			if (aiPlanGetBaseID(FarmPlanID) == gFarmBaseID)
			{
				vector InitialPos = aiPlanGetInitialPosition(FarmPlanID);
				int CurrentID = aiPlanGetVariableInt(FarmPlanID, cFarmPlanDropsiteID, 0);
				if ((kbUnitIsType(CurrentID, cUnitTypeAbstractSettlement) != true) && (CurrentID != -1) && (equal(InitialPos, kbBaseGetLocation(cMyID, mainBaseID)) == true))
				{
					int TC = getMainBaseUnitIDForPlayer(cMyID);
					if (TC != -1)
					{
						vector baseLocation = kbBaseGetLocation(cMyID, mainBaseID);
					    aiPlanSetVariableInt(FarmPlanID, cFarmPlanDropsiteID, 0, TC);
						aiPlanSetVariableVector(FarmPlanID, cFarmPlanFarmingPosition, 0, InitialPos);
						break;
					}
				}				
			}	
		}		
	}
}

//==============================================================================
void updateResourceHandler(int parm=0)
{
    if (ShowAiEcho == true) aiEcho("updateResourceHandler:");    
    
    //Handle food.
    if (parm == cResourceFood)
    {
        updateFoodBreakdown();
	}
    //Handle Gold.
    if (parm == cResourceGold)
    {
        updateGoldBreakdown();
	}
    //Handle Wood.
    if (parm == cResourceWood)
    {
        updateWoodBreakdown();
	}
}

//==============================================================================
int changeMainBase(int newSettle = -1)
{
    if (ShowAiEcho == true) aiEcho("changeMainBase:");
	
    if (ShowAiEcho == true) aiEcho("new baseUnitID: "+newSettle);
    int newBaseID=kbUnitGetBaseID(newSettle);
    if (ShowAiEcho == true) aiEcho("new base ID: "+newBaseID);
    int oldMainBase=kbBaseGetMainID(cMyID);
    if (ShowAiEcho == true) aiEcho("old main base ID: "+oldMainBase);
    vector settlementPosition=kbUnitGetPosition(newSettle);
	
    // set the flags for the new base.
    //Figure out the front vector.
    vector baseFront=xsVectorNormalize(kbGetMapCenter()-settlementPosition);
    kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
    //Military gather point.
    vector militaryGatherPoint=settlementPosition+baseFront*18;
    kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
    //Set the other flags.
    kbBaseSetMilitary(cMyID, newBaseID, true);
    kbBaseSetEconomy(cMyID, newBaseID, true);
    //Set the resource distance limit.
    kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
    // set new town location
    kbSetTownLocation(settlementPosition);
    //Add the settlement to the base.
    kbBaseAddUnit(cMyID, newBaseID, newSettle);
    kbBaseSetSettlement(cMyID, newBaseID, true);
    
    // remove all farm breakdowns
    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, oldMainBase);
    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase1ID);
    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase2ID);
    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase3ID);
    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase4ID);
    
    int numFavorPlans = aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0);
    if (numFavorPlans < 1)
	numFavorPlans = 1;
    //remove all favor breakdowns
    if (cMyCulture == cCultureGreek)
	aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, oldMainBase);
	
    // Switch the mainBase and set the main-ness of the base.
    aiSwitchMainBase(newBaseID, true);
    kbBaseSetMain(cMyID, newBaseID, true);
    
    // set the flags for the old base.
    kbBaseSetMain(cMyID, oldMainBase, false);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    if (ShowAiEcho == true) aiEcho("main base ID: "+mainBaseID);
    
    //enable favor breakdown for our new mainBaseID
    if (cMyCulture == cCultureGreek)
    {
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans);
        aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, 41, 1.0, mainBaseID);
        if (ShowAiEcho == true) aiEcho("adding favor breakdown for mainBaseID");
	}
    
    // destroy the old defend plans and wallplans
    aiPlanDestroy(gDefendPlanID);
    aiPlanDestroy(gMBDefPlan1ID);
    if (gBuildWallsAtMainBase == true)
    {
        gResetWallPlans = true;
        aiPlanDestroy(gMainBaseAreaWallTeam1PlanID);
        aiPlanDestroy(gMainBaseAreaWallTeam2PlanID);
	}
    
    if (mainBaseID == gOtherBase1ID)
    {
        aiPlanDestroy(gOtherBase1DefPlanID);
        gOtherBase1ID = -1;
        gOtherBase1UnitID = -1;
        if (gBuildWalls == true)
        {
            aiPlanDestroy(gOtherBase1RingWallTeamPlanID);
            xsDisableRule("otherBase1RingWallTeam");
		}
	}
    else if (mainBaseID == gOtherBase2ID)
    {
        aiPlanDestroy(gOtherBase2DefPlanID);
        gOtherBase2ID = -1;
        gOtherBase2UnitID = -1;
        if (gBuildWalls == true)
        {
            aiPlanDestroy(gOtherBase2RingWallTeamPlanID);
            xsDisableRule("otherBase2RingWallTeam");
		}
	}
    else if (mainBaseID == gOtherBase3ID)
    {
        aiPlanDestroy(gOtherBase3DefPlanID);
        gOtherBase3ID = -1;
        gOtherBase3UnitID = -1;
        if (gBuildWalls == true)
        {
            aiPlanDestroy(gOtherBase3RingWallTeamPlanID);
            xsDisableRule("otherBase3RingWallTeam");
		}
	}
    else if (mainBaseID == gOtherBase4ID)
    {
        aiPlanDestroy(gOtherBase4DefPlanID);
        gOtherBase4ID = -1;
        gOtherBase4UnitID = -1;
        if (gBuildWalls == true)
        {
            aiPlanDestroy(gOtherBase4RingWallTeamPlanID);
            xsDisableRule("otherBase4RingWallTeam");
		}
	}   
   
	
    //increase the gHouseAvailablePopRebuild
    gHouseAvailablePopRebuild = 22;
	
	//restart fishing too, if active.
	if ((gFishing == true) && (gFishPlanID != -1) && (aiPlanGetActive(gFishPlanID) == true))
    {
        aiPlanDestroy(gFishPlanID); 
		for (i = 0; < kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding))
		{
            int Dock = findUnitByIndex(cUnitTypeDock, i, cUnitStateAliveOrBuilding);
			if (Dock != -1)
			aiTaskUnitDelete(Dock);    			
	    }
		xsEnableRule("fishing");
	}	

	if (ResourceBaseID != -1)
	{
		kbBaseDestroy(cMyID, ResourceBaseID);
        ResourceBaseID = CreateBaseInBackLoc(newBaseID, 40, 100, "Temp Resource Base");
	}

    // call these to update the gatherplans with the new mainbase
    updateFoodBreakdown();
    updateGoldBreakdown();
    updateWoodBreakdown();
	
    return(newBaseID);
}

//==============================================================================
rule relocateFarming
minInterval 108 //starts in cAge2 (or cAge3 on transport maps)
inactive
{
    if (ShowAiEcho == true) aiEcho("relocateFarming:");
	int mainBaseID = kbBaseGetMainID(cMyID);
    //Fixup the old RB for farming.
    if (gFarmBaseID != -1)
    {
        if (findNumUnitsInBase(cMyID, gFarmBaseID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) > 0)
		return;
        //Remove the old breakdown.
        aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gFarmBaseID);
	}
	
    //If no settlement, then move the farming to another base that has a settlement.
    int unit=findUnit(cUnitTypeAbstractSettlement);
    if (unit != -1)
    {
        //Get new base ID.
        gFarmBaseID = kbUnitGetBaseID(unit);
        
        //Remove the breakdown if there's already one for the farm base.
        aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gFarmBaseID);
        
        //Make a new breakdown.
        int numFarmPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm);
        aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, numFarmPlans, 90, 1.0, gFarmBaseID);
		
        if (cvMapSubType != VINLANDSAGAMAP)
        {
            // update mainbase
            // should work now
            changeMainBase(unit);
			gMainBaseAreaWallRadius = gOtherBaseWallRadius;	
			if (ShowAiEcho == true) aiEcho("I'm in trouble.. new Mainbase ID: "+unit);
		}
	}
    else
    {
        //If there are no other bases without settlements... stop farming.
        gFarmBaseID=-1;
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, 0);
        if (ShowAiEcho == true) aiEcho("Stopped farming");
	}
}

//==============================================================================
rule startLandScouting  //grabs the first scout in the scout list and starts scouting with it.
minInterval 1 //starts in cAge1
inactive
{
    //If no scout, go away.
    if ((gLandScout == -1) || (cvMapSubType == VINLANDSAGAMAP))
    {
        xsDisableSelf();
        return;
	}
	
    if (ShowAiEcho == true) aiEcho("startLandScouting:");
	
    //Land based Scouting.
    gLandExplorePlanID=aiPlanCreate("Explore_Land", cPlanExplore);
    if (gLandExplorePlanID >= 0)
    {
        if (cMyCulture == cCultureAtlantean )
        {
            aiPlanAddUnitType(gLandExplorePlanID, cUnitTypeAbstractScout, 0, 1, 1);
            //aiPlanAddUnitType(gLandExplorePlanID, cUnitTypeOracleHero, 0, 1, 1);    // Makes sure the relic plan sees this plan as a hero source. Also crashes the game!
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanOracleExplore, 0, true);
            aiPlanSetDesiredPriority(gLandExplorePlanID, 80);  // Allow oracleHero relic plan to steal one
		}
        else
        {
            aiPlanAddUnitType(gLandExplorePlanID, gLandScout, 1, 1, 1);
            // TODO: maybe set the priority with a rule depending on how many builders we have.
            if (cMyCulture == cCultureNorse )
			aiPlanSetDesiredPriority(gLandExplorePlanID, 50);
            else if (cMyCulture != cCultureAtlantean)
			aiPlanSetDesiredPriority(gLandExplorePlanID, 80);
		}
        aiPlanSetEscrowID(gLandExplorePlanID, cEconomyEscrowID);
		
		
        aiPlanSetInitialPosition(gLandExplorePlanID, kbBaseGetLocation(cMyID,kbBaseGetMainID(cMyID)));
        aiPlanSetVariableFloat(gLandExplorePlanID, cExplorePlanLOSMultiplier, 0, 1.7);
        if (cMyCulture == cCultureEgyptian)
        {
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanCanBuildLOSProto, 0, false);
            xsEnableRule("autoBuildOutpost");
		}
        else if (cMyCulture != cCultureAtlantean )
        {
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, true);
            aiPlanSetVariableInt(gLandExplorePlanID, cExplorePlanNumberOfLoops, 0, 2);
		}
        aiPlanSetActive(gLandExplorePlanID);
	}
	
    //Go away now.
    xsDisableSelf();
}

//==============================================================================
// RULE: autoBuildOutpost
//==============================================================================
rule autoBuildOutpost   //Restrict Egyptians from building outposts until they have a temple.
minInterval 10 //starts in cAge1, activated in startLandScouting
inactive  
{
    if ((gLandScout == -1) || (cMyCulture != cCultureEgyptian))
    {
        xsDisableSelf();
        return;
	}
    
    if (ShowAiEcho == true) aiEcho("autoBuildOutpost:");
    
    if (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive) < 1)
	return;
	
    aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanCanBuildLOSProto, 0, true);
    xsDisableSelf();
}

//==============================================================================
void econAge2Handler(int age=1)
{
    if (ShowAiEcho == true) aiEcho("econAge2Handler");
    
	
    // Start early settlement monitor if not already active (vinland, team mig, nomad)
    xsEnableRule("buildSettlements");
    
    //fishing
    if (gFishing == true)
	xsEnableRule("getPurseSeine");
	
    // Transports
    if (gTransportMap == true) 
	xsEnableRule("getEnclosedDeck");
	
    if ( (aiGetGameMode() == cGameModeDeathmatch) || (aiGetGameMode() == cGameModeLightning) )  // Add an emergency armory
    {
		int Armory = cUnitTypeArmory;
		if (cMyCiv == cCivThor)
		Armory = cUnitTypeDwarfFoundry;
        if (cMyCulture == cCultureAtlantean)
        {
            createSimpleBuildPlan(cUnitTypeArmory, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
            createSimpleBuildPlan(cUnitTypeManor, 3, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
		}
        else
        {
            createSimpleBuildPlan(Armory, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 3);
            createSimpleBuildPlan(cUnitTypeHouse, 6, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
		}
	}
	
    // Set escrow caps
    kbEscrowSetCap(cEconomyEscrowID, cResourceFood, 800.0);    // Age 3
	kbEscrowSetCap(cEconomyEscrowID, cResourceWood, 400.0);
	kbEscrowSetCap(cEconomyEscrowID, cResourceGold, 500.0);    // Age 3
    kbEscrowSetCap(cEconomyEscrowID, cResourceFavor, 30.0);
    kbEscrowSetCap(cMilitaryEscrowID, cResourceFood, 200.0);
    kbEscrowSetCap(cMilitaryEscrowID, cResourceWood, 200.0);   // Towers
    kbEscrowSetCap(cMilitaryEscrowID, cResourceGold, 200.0);   // Towers
    kbEscrowSetCap(cMilitaryEscrowID, cResourceFavor, 30.0);
}


//==============================================================================
void econAge3Handler(int age=0)
{
    if (ShowAiEcho == true) aiEcho("econAge3Handler:");
	
    // enable the relocateFarming rule now if this is a transport map
    if (gTransportMap == true)
	xsEnableRule("relocateFarming");
	
    xsEnableRule("getFortifiedTownCenter");
    
    // Fishing
    if (gFishing == true) 
	xsEnableRule("getSaltAmphora");
	
    if ((aiGetGameMode() == cGameModeDeathmatch) || (aiGetGameMode() == cGameModeLightning))   // Add an emergency market
    {
        if (cMyCulture == cCultureAtlantean)
        {
            createSimpleBuildPlan(cUnitTypeMarket, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
            gExtraMarket = true; // Set the global so we know to look for SECOND market before trading.       
            createSimpleBuildPlan(cUnitTypeManor, 1, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
		}
        else
        {
            createSimpleBuildPlan(cUnitTypeMarket, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 5);
            gExtraMarket = true; // Set the global so we know to look for SECOND market before trading.       
            createSimpleBuildPlan(cUnitTypeHouse, 2, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
		}
	}
	
    // Set escrow caps
    kbEscrowSetCap( cEconomyEscrowID, cResourceFood, 1000.0);    // Age 4
    kbEscrowSetCap( cEconomyEscrowID, cResourceWood, 400.0);     // Settlements, upgrades
    kbEscrowSetCap( cEconomyEscrowID, cResourceGold, 1000.0);    // Age 4
    kbEscrowSetCap( cEconomyEscrowID, cResourceFavor, 30.0);
    kbEscrowSetCap( cMilitaryEscrowID, cResourceFood, 400.0);
    kbEscrowSetCap( cMilitaryEscrowID, cResourceWood, 400.0);
    kbEscrowSetCap( cMilitaryEscrowID, cResourceGold, 400.0);
    kbEscrowSetCap( cMilitaryEscrowID, cResourceFavor, 30.0);
	
    kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 85.0);
}

//==============================================================================
void econAge4Handler(int age=0)
{
    if (ShowAiEcho == true) aiEcho("econAge4Handler:");
    
    int numBuilders = 0;
    int bigBuildingType = MyFortress;
    if (aiGetGameMode() == cGameModeDeathmatch)     // Add 2 extra big buildings and 2-3 little buildings
    {
        switch(cMyCulture)
        {
            case cCultureGreek:
            {
                numBuilders = 3;
                createSimpleBuildPlan(cUnitTypeBarracks, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
                createSimpleBuildPlan(cUnitTypeStable, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
                createSimpleBuildPlan(cUnitTypeArcheryRange, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
                break;
			}
            case cCultureEgyptian:
            {
                numBuilders = 5;
                createSimpleBuildPlan(cUnitTypeBarracks, 2, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
				createSimpleBuildPlan(cUnitTypeSiegeCamp, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
                break;
			}
            case cCultureNorse:
            {
                numBuilders = 2;
                createSimpleBuildPlan(cUnitTypeLonghouse, 2, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
                break;
			}
            case cCultureAtlantean:
            {
                numBuilders = 1;
                createSimpleBuildPlan(cUnitTypeBarracksAtlantean, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
				createSimpleBuildPlan(cUnitTypeCounterBuilding, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
                break;
			}
            case cCultureChinese:
            {
                numBuilders = 3;
                createSimpleBuildPlan(cUnitTypeBarracksChinese, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
				createSimpleBuildPlan(cUnitTypeStableChinese, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
                break;
			}			
		}
        createSimpleBuildPlan(bigBuildingType, 3, 80, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), numBuilders);
	}
	
	
    // Set escrow caps tighter
	if ((TitanAvailable == true) && (gTransportMap == false))
	{
		kbEscrowSetCap(cEconomyEscrowID, cResourceFood, 1200.0);
		kbEscrowSetCap(cEconomyEscrowID, cResourceWood, 1200.0);     
		kbEscrowSetCap(cEconomyEscrowID, cResourceGold, 1200.0);    
		kbEscrowSetCap(cEconomyEscrowID, cResourceFavor, 60.0);
	}
	else 
	{
		kbEscrowSetCap(cEconomyEscrowID, cResourceFood, 300.0);    
		kbEscrowSetCap(cEconomyEscrowID, cResourceWood, 300.0);
		kbEscrowSetCap(cEconomyEscrowID, cResourceGold, 300.0);    
		kbEscrowSetCap(cEconomyEscrowID, cResourceFavor, 30.0);
	}
	
    kbEscrowSetCap( cMilitaryEscrowID, cResourceFood, 300.0);
    kbEscrowSetCap( cMilitaryEscrowID, cResourceWood, 300.0);   
    kbEscrowSetCap( cMilitaryEscrowID, cResourceGold, 300.0);   
    kbEscrowSetCap( cMilitaryEscrowID, cResourceFavor, 30.0);
}

//==============================================================================
void createCivPopPlan()
{    
	gCivPopPlanID=aiPlanCreate("civPop", cPlanTrain);
    if (gCivPopPlanID >= 0)
    {
        //Get our mainline villager PUID.
        int gathererPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer,0);
        aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0, gathererPUID);
        //Train off of economy escrow.
        aiPlanSetEscrowID(gCivPopPlanID, cEconomyEscrowID);
        //Default to 10.
        aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0, 10);  
        aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement);  
        aiPlanSetDesiredPriority(gCivPopPlanID, 97);
        aiPlanSetActive(gCivPopPlanID);
	}
}	
//==============================================================================
void initEcon() //setup the initial Econ stuff.
{
    if (ShowAiEcho == true) aiEcho("initEcon:");    
    
	//Set our update resource handler.
    aiSetUpdateResourceEventHandler("updateResourceHandler");
	
    //Set up auto-gather escrows.
    aiSetAutoGatherEscrowID(cEconomyEscrowID);
    aiSetAutoFarmEscrowID(cEconomyEscrowID);
	
    //Distribute the resources we have.
    kbEscrowAllocateCurrentResources();
	
    //Set our bases.
    gFarmBaseID=kbBaseGetMainID(cMyID);
    gGoldBaseID=kbBaseGetMainID(cMyID);
    gWoodBaseID=kbBaseGetMainID(cMyID);
	
    //Make a plan to manage the villager population.
    createCivPopPlan();
	
    //Create a herd plan to gather all herdables that we ecounter.
    xsEnableRule("createHerdplan");
    
    //enable the setEarlyEcon rule
    xsEnableRule("setEarlyEcon");
}

//==============================================================================
rule setEarlyEcon
minInterval 5 //starts in cAge1
inactive
{
	if (ShowAiEcho == true) aiEcho("setEarlyEcon: ");
    int gathererCount = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
	
    if (cMyCulture == cCultureAtlantean)
	gathererCount = gathererCount * 3;
    gathererCount = gathererCount + kbUnitCount(cMyID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0), cUnitStateAlive);
	
    if ((gathererCount < 7) && (xsGetTime() < 2*60*1000))
	return;
	
    float foodGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);
    float woodGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood);
    float goldGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold);
    float favorGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor);
    aiSetResourceGathererPercentage(cResourceFood, foodGPct, false, cRGPScript);
    aiSetResourceGathererPercentage(cResourceWood, woodGPct, false, cRGPScript);
    aiSetResourceGathererPercentage(cResourceGold, goldGPct, false, cRGPScript);
    aiSetResourceGathererPercentage(cResourceFavor, favorGPct, false, cRGPScript);
    aiNormalizeResourceGathererPercentages(cRGPScript);
	
    if (ShowAiEcho == true) aiEcho("Setting normal gatherer distribution.");
	
	xsEnableRule("econForecastAge1");
    xsDisableSelf();
}

//==============================================================================
void postInitEcon()
{
    if (ShowAiEcho == true) aiEcho("postInitEcon:");
	
    //Set the RGP weights.  Script in charge.
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanScriptRPGPct, 0, 1.0);
    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanCostRPGPct, 0, 0.0);
    aiSetResourceGathererPercentageWeight(cRGPScript, 1.0);
    aiSetResourceGathererPercentageWeight(cRGPCost, 0.0);
	
    //Setup AI Cost weights.
    kbSetAICostWeight(cResourceFood, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFood));
    kbSetAICostWeight(cResourceWood, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceWood));
    kbSetAICostWeight(cResourceGold, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceGold));
    kbSetAICostWeight(cResourceFavor, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFavor));
	
    //Set initial gatherer percentages.
    float foodGPct=aiPlanGetVariableFloat(gGatherGoalPlanID,0, cResourceFood);    
    float woodGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, 0, cResourceWood);   
    float goldGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, 0, cResourceGold);   
    float favorGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, 0, cResourceFavor);
	
    aiSetResourceGathererPercentage(cResourceFood, 1.0, false, cRGPScript);	// Changed these to 100% food early then
    aiSetResourceGathererPercentage(cResourceWood, 0.0, false, cRGPScript);	// the setEarlyEcon rule above will set the 
    aiSetResourceGathererPercentage(cResourceGold, 0.0, false, cRGPScript);	// former "initial" values once we have 7 (or 3 atlantean) gatherers.
    aiSetResourceGathererPercentage(cResourceFavor, 0.0, false, cRGPScript);
    aiNormalizeResourceGathererPercentages(cRGPScript);
	
    //Set up the initial resource break downs.
    int numFoodEasyPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy);
    int numFoodHuntAggressivePlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive);
    int numFishPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFish);
    int numWoodPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0);
    int numGoldPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0);
    int numFavorPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0);
	aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, numFoodEasyPlans, 100, 1.0, kbBaseGetMainID(cMyID));
    aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, numFoodHuntAggressivePlans, 90, 1.0, kbBaseGetMainID(cMyID));
    aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, numFishPlans, 100, 1.0, kbBaseGetMainID(cMyID));
	
    if (cMyCulture == cCultureEgyptian)
    {
        aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, numWoodPlans, 50, 1.0, kbBaseGetMainID(cMyID));
        aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, numGoldPlans, 55, 1.0, kbBaseGetMainID(cMyID));
	}
    else
    {
        aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, numWoodPlans, 55, 1.0, kbBaseGetMainID(cMyID));
        aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, numGoldPlans, 50, 1.0, kbBaseGetMainID(cMyID));
	}
    aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, numFavorPlans, 40, 1.0, kbBaseGetMainID(cMyID));
}

//==============================================================================
rule fishing
minInterval 1 //starts in cAge1
inactive
{
	static int Run = 0;
    xsSetRuleMinIntervalSelf(11);
    if ((cRandomMapName == "river styx") || (aiPlanGetActive(gFishPlanID) == true))
    {
        xsDisableSelf();
        return;
	}
    WaitForDock = true;
    if (ShowAiEcho == true) aiEcho("fishing:");
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
    //Get the closest water area.  if there isn't one, we can't fish.
    static int areaID=-1;
    if (areaID == -1)
	areaID = kbAreaGetClosetArea(mainBaseLocation, cAreaTypeWater);
    if (areaID == -1)
    {
        xsDisableSelf();
        return;
	}
	
    //Get our fish gatherer.
    int fishGatherer = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
	
    if ((gTransportMap == false) && (xsGetTime() < 1*30*1000) && (cRandomMapName != "anatolia"))
	return;
	
    if (gTransportMap == true)
	gNumBoatsToMaintain = gNumBoatsToMaintain + aiRandInt(4);
	if (cRandomMapName == "Basin")
	gNumBoatsToMaintain = 4;
	
    if (kbUnitCount(0, cUnitTypeFish) < 1)
	gNumBoatsToMaintain = 1;
	
	
    //Create the fish plan.
    int fishPlanID = aiPlanCreate("FishPlan", cPlanFish);
    if (fishPlanID >= 0)
    {
        aiPlanSetDesiredPriority(fishPlanID, 52);
        aiPlanSetVariableVector(fishPlanID, cFishPlanLandPoint, 0, mainBaseLocation);
        aiPlanSetVariableVector(fishPlanID, cFishPlanWaterPoint, 0, kbAreaGetCenter(areaID));
        aiPlanSetVariableBool(fishPlanID, cFishPlanAutoTrainBoats, 0, true);
        aiPlanSetEscrowID(fishPlanID, cEconomyEscrowID);
        aiPlanAddUnitType(fishPlanID, fishGatherer, 2, gNumBoatsToMaintain, gNumBoatsToMaintain);
        aiPlanSetVariableFloat(fishPlanID, cFishPlanMaximumDockDist, 0, 500.0);
        gFishing = true;
        aiPlanSetActive(fishPlanID);
        gFishPlanID = fishPlanID;
		xsEnableRule("FishBoatMonitor");
		
	}
    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFish, 1);
	Run = Run + 1;
	if (Run > 1)
	{
		xsDisableSelf();
		return; 
	}
	
    gHouseAvailablePopRebuild = gHouseAvailablePopRebuild + 3;
	
	if (cRandomMapName == "Basin" && cMyCiv != cCivPoseidon)
	{
		xsDisableSelf();
		return;
	}
	
    if ((gTransportMap == true) || (cRandomMapName == "anatolia") && (gWaterExploreID == -1))
    {
        //Make a plan to explore with the water scout.
        gWaterExploreID = aiPlanCreate("Explore_Water", cPlanExplore);
        if (gWaterExploreID >= 0)
        {
            aiPlanAddUnitType(gWaterExploreID, gWaterScout, 1, 1, 1);
            aiPlanSetDesiredPriority(gWaterExploreID, 100);
            aiPlanSetVariableBool(gWaterExploreID, cExplorePlanDoLoops, 0, false);
            aiPlanSetVariableBool(gWaterExploreID, cExplorePlanAvoidingAttackedAreas, 0, false);
            aiPlanSetVariableFloat(gWaterExploreID, cExplorePlanLOSMultiplier, 0, 1.5); //Test
            aiPlanSetEscrowID(gWaterExploreID, cEconomyEscrowID);
            aiPlanSetActive(gWaterExploreID);
		}
	}
    xsDisableSelf();
}

//==============================================================================
rule collectIdleVills
minInterval 35 //starts in cAge1
inactive
{
    if (ShowAiEcho == true) aiEcho("collectIdleVills:");
	
    // find all vills that have the same base as the first one
    static int villQuery = -1;
    if (villQuery < 0)
    {
        villQuery = kbUnitQueryCreate("Idle Vill Query");
        configQuery(villQuery, cUnitTypeAbstractVillager, cActionIdle, cUnitStateAlive, cMyID);
	}
    kbUnitQueryResetResults(villQuery);
    int numberVills = kbUnitQueryExecute(villQuery);
	int ActualVills = numberVills;
	if (cMyCulture == cCultureAtlantean)
	ActualVills = ActualVills * 3;
	
    if (numberVills <= 0)
    {
        return;
	}
    
    if (ShowAiEcho == true) aiEcho("collectIdleVills:");
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
    static int randomResourceQueryID = -1;
    if (randomResourceQueryID < 0)
	randomResourceQueryID = kbUnitQueryCreate("Idle Villie Resource Sites");
	
    if (numberVills > 4)
	numberVills = 4;
	
    bool noTrees = false;
    
	
	float woodSupply = kbResourceGet(cResourceWood);
    if ((woodSupply > 3000) && (xsGetTime() > 20*60*1000)) 
	noTrees = true;
	
    bool noGoldMines = false;
	
    int numMainBaseGoldSites = kbGetNumberValidResources(mainBaseID, cResourceGold, cAIResourceSubTypeEasy);
    int numGoldBaseSites = 0;
    if ((gGoldBaseID >= 0) && (gGoldBaseID != mainBaseID))    // Count gold base if different
	numGoldBaseSites = kbGetNumberValidResources(gGoldBaseID, cResourceGold, cAIResourceSubTypeEasy);
    int numGoldSites = numMainBaseGoldSites + numGoldBaseSites;
	
    if ((numGoldSites < 1) && (xsGetTime() > 20*60*1000))
	noGoldMines = true;
	
	if (ActualVills >= 6) // 6 idle vills? assume there is no wood/gold left.
	{
		noTrees = true;
		noGoldMines = true;
		if (ShowAiEcho == true) aiEcho("More than 8 idle vills, no trees/wood?");
	}
    int numLivingHerdablesNearMainBase = getNumUnits(cUnitTypeHerdable, cUnitStateAlive, -1, cMyID, mainBaseLocation, 50.0);
    int numDeadHerdablesNearMainBase = getNumUnits(cUnitTypeHerdable, cUnitStateAlive, -1, 0, mainBaseLocation, 50.0); //'dead' herdables have playerID=0 and cUnitStateAlive
	
	bool noFarmsAvailable = false;
	
	int numFarmsNearMainBase = kbBaseGetNumberUnits(cMyID, gFarmBaseID, -1, cUnitTypeFarm);
    int gathererCount = kbUnitCount(cMyID,cUnitTypeAbstractVillager,cUnitStateAlive);  
    int foodGathererCount = aiGetResourceGathererPercentage(cResourceFood, cRGPActual) * gathererCount;
	
	if (numFarmsNearMainBase < foodGathererCount)
	noFarmsAvailable = true;
	
    for (i = 0; < numberVills)
    {
        int currentVillie = kbUnitQueryGetResult(villQuery, i);
        vector villiePos = kbUnitGetPosition(currentVillie);
        int villieAGID = kbAreaGroupGetIDByPosition(villiePos);
		
        kbUnitQueryResetData(randomResourceQueryID);
		
        int randomResource = -1;
        int resourceType = -1;
        int unitState = cUnitStateAlive;
        int playerID = 0;
        int radius = -1;
		string ResourceName = "Invalid";
        if ((noTrees == true) && (noGoldMines == true) && (noFarmsAvailable == true))
		randomResource = 5;
        else
        {
            if (noTrees == true)
			randomResource = 0;
            else if (noGoldMines == true)
			randomResource = 1;
            else if ((noGoldMines == true) && (noTrees == true) && (noFarmsAvailable == false) || (noFarmsAvailable == false) && (aiRandInt(2) == 0))
			randomResource = 2;		
			else 
			randomResource = aiRandInt(3);
		}
		
		
		if (numLivingHerdablesNearMainBase > 0)
        {
            if ((numDeadHerdablesNearMainBase > 0) && (aiRandInt(2) < 1))
            {
                randomResource = 4;
			}
            else
			randomResource = 3;
		}
        else if ((numDeadHerdablesNearMainBase > 0) && (aiRandInt(2) < 1))
        {
            randomResource = 4;
		}
		
		
        switch(randomResource)
        {
            case 0:
            {
                resourceType = cUnitTypeGold;
				ResourceName = "Gold";
                if (ShowAiEcho == true) aiEcho("sending idle villager to gold");
                break;
			}
            case 1:
            {
                resourceType = cUnitTypeWood;
				radius = 45;
				villiePos = mainBaseLocation;
				ResourceName = "Wood";
                if (ShowAiEcho == true) aiEcho("sending idle villager to wood");
                break;
			}			
            case 2:
            {
                resourceType = cUnitTypeFarm;
				playerID = cMyID;
				ResourceName = "Farm";
                if (ShowAiEcho == true) aiEcho("sending idle villager to Farm");
                break;
			}
            case 3:
            {
                resourceType = cUnitTypeHerdable;
				playerID = cMyID;
				ResourceName = "Herd";
                if (ShowAiEcho == true) aiEcho("sending idle villager to a living herdable");
                break;
			}
            case 4:
            {
                resourceType = cUnitTypeHerdable;
				ResourceName = "Herd";
                if (ShowAiEcho == true) aiEcho("sending idle villager to a dead herdable");
                break;
			}
            case 5:
            {
				ResourceName = "Going home";
                break;
			}
		}
		
        if (randomResource == 5)
        {
            aiTaskUnitMove(currentVillie, mainBaseLocation);
            if (ShowAiEcho == true) aiEcho("sending idle villager to mainBase");
		}
        else
        {
            if ((cRandomMapName == "vinlandsaga") || (cRandomMapName == "team migration"))
			configQuery(randomResourceQueryID, resourceType, -1, unitState, playerID, villiePos, true);
			else
			configQuery(randomResourceQueryID, resourceType, -1, unitState, playerID, villiePos, true, radius);
            kbUnitQuerySetAreaGroupID(randomResourceQueryID, villieAGID);
            kbUnitQueryResetResults(randomResourceQueryID);
            int numberRandomResource = kbUnitQueryExecute(randomResourceQueryID);
            if (numberRandomResource > 0)
            aiTaskUnitWork(currentVillie, kbUnitQueryGetResult(randomResourceQueryID, 0));
		}
	}
}

//==============================================================================
rule PurgeLostEcoUnits
minInterval 38 //starts in cAge1
inactive
{
    vector mainBaseLocation = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	vector UnitLocation = cInvalidVector;
	int AreaID = -1;
	
	for (i = 0; < getNumUnits(cUnitTypeAbstractVillager, cUnitStateAlive, cActionIdle, cMyID))
	{
		int Villager = findUnitByIndex(cUnitTypeAbstractVillager, i, cUnitStateAlive, cActionIdle);
		UnitLocation = kbUnitGetPosition(Villager);
		AreaID = kbAreaGetIDByPosition(UnitLocation);
		if ((Villager != -1) && (kbUnitGetPlanID(Villager) == -1) && (kbAreaGroupGetIDByPosition(UnitLocation) != kbAreaGroupGetIDByPosition(mainBaseLocation)) && (kbAreaGetType(AreaID) != cAreaTypeWater)
		&& (NumUnitsOnAreaGroupByRel(false, kbAreaGroupGetIDByPosition(UnitLocation), cUnitTypeAbstractSettlement, cPlayerRelationAny) <= 0))
		{
		    aiTaskUnitDelete(Villager);  
		    break;
		}
	}
	// Check Caravans too
	for (i = 0; < getNumUnits(cUnitTypeAbstractTradeUnit, cUnitStateAlive, cActionIdle, cMyID))
	{
		int Caravan = findUnitByIndex(cUnitTypeAbstractTradeUnit, i, cUnitStateAlive, cActionIdle);
		UnitLocation = kbUnitGetPosition(Caravan);
		AreaID = kbAreaGetIDByPosition(UnitLocation);
		if ((Caravan != -1) && (kbAreaGroupGetIDByPosition(UnitLocation) != kbAreaGroupGetIDByPosition(mainBaseLocation)) && (kbAreaGetType(AreaID) != cAreaTypeWater))
		{
		    aiTaskUnitDelete(Caravan);     
		    break;
		}			
	}	
}

//==============================================================================
rule randomUpgrader
minInterval 61 //starts in cAge5
inactive
{
	
    if (ShowAiEcho == true) aiEcho("randomUpgrader:");
	return;
    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching))
	return;
    
    if ((gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching))
	return;
    
    static int id = 0;
    //Don't do anything until we have some pop.
    int maxPop = kbGetPopCap();
    if (maxPop < 120)
	return;
    //If we still have some pop slots to fill, quit.
    int currentPop = kbGetPop();
    if ((maxPop - currentPop) > 20)
	return;
	
    //If we have lots of resources, get a random upgrade.
    float currentFood = kbResourceGet(cResourceFood);
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);
    float currentFavor = kbResourceGet(cResourceFavor);
	
    if ((currentFood > 2000) && (currentWood > 2000) && (currentGold > 2000))
    {
        int upgradeTechID = kbTechTreeGetRandomUnitUpgrade();
        //Dont make another plan if we already have one.
        if ((aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, upgradeTechID) != -1)
		|| (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, upgradeTechID) != -1))
		return;
		
        //Make plan to get this upgrade.
        int planID = aiPlanCreate("nextRandomUpgrade - "+id, cPlanProgression);
        if (planID < 0)
		return;
		
        aiPlanSetVariableInt(planID, cProgressionPlanGoalTechID, 0, upgradeTechID);
        aiPlanSetDesiredPriority(planID, 50);
        aiPlanSetEscrowID(planID, cMilitaryEscrowID);
        aiPlanSetActive(planID);
        if (ShowAiEcho == true) aiEcho("randomUpgrader: successful in creating a progression to "+kbGetTechName(upgradeTechID));
        id++;
	}
}

//==============================================================================
rule createHerdplan
minInterval 10 //starts in cAge1
inactive
{
    if (ShowAiEcho == true) aiEcho("createHerdplan:");
	
    static bool increaseInterval = true;
    static bool researchGranary = false;
    static int herdplanStartTime = -1;
    if ((increaseInterval == true) && (researchGranary == true))
    {
        xsSetRuleMinIntervalSelf(71);
        increaseInterval = false;
        return;
	}
    else
    {    
        if ((gResearchGranaryID > 0) && (researchGranary == false))
		aiPlanDestroy(gHerdPlanID);
        else if ((herdplanStartTime != -1) && (xsGetTime() < herdplanStartTime + 5*60*1000))
		return;
        else
		aiPlanDestroy(gHerdPlanID);
	}
	
	
    gHerdPlanID=aiPlanCreate("GatherHerdable Plan", cPlanHerd);
    if (gHerdPlanID >= 0)
    {
        herdplanStartTime = xsGetTime();
        aiPlanAddUnitType(gHerdPlanID, cUnitTypeHerdable, 0, 100, 100);
        if (gResearchGranaryID < 0)
        {
            if ((cRandomMapName != "vinlandsaga") && (cRandomMapName != "team migration"))
			aiPlanSetBaseID(gHerdPlanID, kbBaseGetMainID(cMyID));
            else
            {  
                if ((cMyCulture == cCultureGreek) || (cMyCulture == cCultureEgyptian))
				aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingTypeID, 0, cUnitTypeGranary);  
                else if (cMyCulture == cCultureNorse)
				aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingTypeID, 0, cUnitTypeOxCart);
                else if (cMyCulture == cCultureAtlantean)
				aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingTypeID, 0, cUnitTypeAbstractVillager);
                else if (cMyCulture == cCultureChinese)
				aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingTypeID, 0, cUnitTypeStoragePit);					
			}
		}
        else
        {
            aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingID, 0, gResearchGranaryID);  
            researchGranary = true;
		}
        aiPlanSetVariableFloat(gHerdPlanID, cHerdPlanDistance, 0, 20.0);
        aiPlanSetActive(gHerdPlanID);
        if (ShowAiEcho == true) aiEcho("activating herdplan ID is: "+gHerdPlanID);
        if (gResearchGranaryID > 0)
		if (ShowAiEcho == true) aiEcho("herdPlanBuildingID is: "+gResearchGranaryID);
	}
}

//==============================================================================
rule monitorTrade
inactive
minInterval 23 //starts in cAge3, activated in tradeWithCaravans
{
    if (ShowAiEcho == true) aiEcho("monitorTrade:");
    if (ShowAiEcho == true) aiEcho("gTradeMarketUnitID: "+gTradeMarketUnitID);
    if (((gTradeMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0))
	|| (gTradeMarketUnitID == -1))
    {
        if (gTradePlanID != -1)
        {
            aiPlanDestroy(gTradePlanID);
            gTradePlanID = -1;
            if (ShowAiEcho == true) aiEcho("killing gTradePlanID");
		}
        
        int activeTradePlans = aiPlanGetNumber(cPlanTrade, -1, true);
        if (ShowAiEcho == true) aiEcho("activeTradePlans: "+activeTradePlans);
        if (activeTradePlans > 0)
        {
            for (i = 0; < activeTradePlans)
            {
                int tradePlanIndexID = aiPlanGetIDByIndex(cPlanTrade, -1, true, i);
                if (tradePlanIndexID != -1)
                {
                    aiPlanDestroy(tradePlanIndexID);
                    if (ShowAiEcho == true) aiEcho("destroying tradePlanIndexID: "+tradePlanIndexID);
				}
			}
		}
        
        if (ShowAiEcho == true) aiEcho("gTradeMarketUnitID has been destroyed or is -1, returning");
        return;
	}
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int tradeCartPUID = cUnitTypeAbstractTradeUnit;
    
    bool test = false;
    
    if (gTradePlanID == -1)
    {
        if ((gTradeMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) > 0))
        {
            test = true;
            if (ShowAiEcho == true) aiEcho("setting test = true");
		}
        else
        {
            if (ShowAiEcho == true) aiEcho("no gTradeMarketUnitID -> no trade plan, returning");
            return;
		}
	}	
    
    vector marketLocation = kbUnitGetPosition(gTradeMarketUnitID);
    int numEnemyAttBuildingsNearMarketInR60 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, marketLocation, 60.0);
    int numMotherNatureAttBuildingsNearMarketInR50 = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, 0, marketLocation, 50.0);
    int numEnemyMilUnitsNearMarketInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, marketLocation, 40.0, true);
    int myMilUnitsNearMarketInR30 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, marketLocation, 30.0);
    int alliedMilUnitsNearMarketInR30 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, marketLocation, 30.0, true);
    if ((numEnemyAttBuildingsNearMarketInR60 - numMotherNatureAttBuildingsNearMarketInR50 > 0)
	|| (numEnemyMilUnitsNearMarketInR40 - myMilUnitsNearMarketInR30 - alliedMilUnitsNearMarketInR30 > 1))
    {
        if (test == false)
        {
            aiPlanDestroy(gTradePlanID);
            gTradePlanID = -1;
            if (ShowAiEcho == true) aiEcho("too many enemies or enemy buildings near market, destroying plan and returning");
		}
        if (ShowAiEcho == true) aiEcho("returning");
        return;
	}
    
    if (test == true)
    {
        int tradePlanID = aiPlanCreate("MarketTrade", cPlanTrade);
        if (tradePlanID < 0)
		return;
		
        aiPlanSetInitialPosition(tradePlanID, kbUnitGetPosition(gTradeMarketUnitID));
        aiPlanSetVariableVector(tradePlanID, cTradePlanStartPosition, 0, kbUnitGetPosition(gTradeMarketUnitID));
        aiPlanSetVariableInt(tradePlanID, cTradePlanTradeUnitType, 0, tradeCartPUID);
        aiPlanSetVariableInt(tradePlanID, cTradePlanMarketID, 0, gTradeMarketUnitID);
        aiPlanAddUnitType(tradePlanID, tradeCartPUID, 1, 1, 1);     // Just one to start
        aiPlanSetVariableInt(tradePlanID, cTradePlanTargetUnitTypeID, 0, cUnitTypeAbstractSettlement);
        aiPlanSetBaseID(tradePlanID, mainBaseID);
        aiPlanSetEconomy(tradePlanID, true);
        aiPlanSetDesiredPriority(tradePlanID, 100);
		aiPlanSetVariableInt(gTradePlanID, cTradePlanTradeUnitTypeMax, 0, 1);
        aiPlanSetActive(tradePlanID);
        gTradePlanID = tradePlanID;
        if (ShowAiEcho == true) aiEcho("creating trade plan with ID: "+tradePlanID);
	}
}

//==============================================================================
rule tradeWithCaravans
minInterval 31 //starts in cAge3
inactive
{
    if (ShowAiEcho == true) aiEcho("tradeWithCaravans:");
    
    if ((gTradeMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0))
    {
        if (gTradePlanID != -1)
        {
            aiPlanDestroy(gTradePlanID);
            gTradePlanID = -1;
		}
	}
	
    xsSetRuleMinIntervalSelf(31);
    //Force build a market.
    static int failedBase = -1;  // Set to the main base ID if no valid market position exists, so we don't retry forever.
    int mainBaseID = kbBaseGetMainID(cMyID);
	
    if (failedBase == mainBaseID)  // We've failed at this spot before
    {
        xsSetRuleMinIntervalSelf(210);
        failedBase = -1;    //Try again in 3.5 minutes
        return;
	}
	
    static bool builtMarket = false;
    static int marketTime = -1;   // Set when we create the build plan
    static int buildPlanID = -1;
	
	
    int targetNumMarkets = 1;
    if (gExtraMarket == true)
	targetNumMarkets = 2;      // One near main base, one for trade
    static bool extraRuleEnabled = false;
	
    if (builtMarket == false)
    {
        vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);  // my main base location
        vector allyLocation = cInvalidVector;
        vector marketLocation = cInvalidVector;

        // Since we can't specify a target TC, if we have allies, we'll build in the corner
        // that is nearest the most distant ally TC, which should give us a good run back
        // to our TCs.  If no allies, or if ally corner == our corner, choose the
        // corner that is second closest to our base.
		
        // Do simple dx+dz distance check for each corner
        float bottom = -1;
        float top = -1;
        float right = -1;
        float left = -1;
        int closestToMe = -1;
        int closestToAlly = -1;
        int secondClosestToMe = -1;
        float min = -1.0;
		
        bottom = xsVectorGetX(mainBaseLocation) + xsVectorGetZ(mainBaseLocation);    // dist to bottom
        left = xsVectorGetX(mainBaseLocation) + (kbGetMapZSize() - xsVectorGetZ(mainBaseLocation));
        right = (kbGetMapXSize() - xsVectorGetX(mainBaseLocation)) + xsVectorGetZ(mainBaseLocation);
        top = (kbGetMapXSize() - xsVectorGetX(mainBaseLocation)) + (kbGetMapZSize() - xsVectorGetZ(mainBaseLocation)); 
		
        // Find closest corner, and mark it as distant so we can then find the second closest
        if ( xsVectorGetX(mainBaseLocation) < (kbGetMapXSize()/2) )
        {  // we're on bottom left half
            if ( xsVectorGetZ(mainBaseLocation) < (kbGetMapZSize()/2) )
            {  // we're lower right half ergo bottom corner
                bottom = 10000;     // Won't be closest
                closestToMe = 0;  // x0,z0
			}
            else
            {  // we're on upper left half, ergo left
                left = 10000;
                closestToMe = 1;  // x0, z1
			}
		}
        else
        {  // we're on upper right half
            if ( xsVectorGetZ(mainBaseLocation) > (kbGetMapZSize()/2) )
            {  // we're upper left half ergo top corner
                top = 10000;     // Won't be closest
                closestToMe = 3;  // x1, z1
			}
            else
            {  // we're on bottom right half, ergo right
                right = 10000;
                closestToMe = 2;  // x1, z0
			}
		}
		
        // Find second closest to me.
        min = 9000.0;
        if ( bottom < min )
        {
            min = bottom;
            secondClosestToMe = 0;
		}
        if ( top < min )
        {
            min = top;
            secondClosestToMe = 3;
		}
        if ( left < min )
        {
            min = left;
            secondClosestToMe = 1;
		}
        if ( right < min )
        {
            min = right;
            secondClosestToMe = 2;
		}
		
        // We've found the closest and second closest corners.  If we have an ally, find its closest corner
		
        // Look for an ally TC.  If we find one, use it to determine position.
        //If we don't have a query ID, create it.
        static int distantAllyTCQuery=-1;
        if (distantAllyTCQuery < 0)
        {
            distantAllyTCQuery=kbUnitQueryCreate("MarketQuery");
            //If we still don't have one, bail.
            if (distantAllyTCQuery < 0)
			return;
            //Else, setup the query data.
            kbUnitQuerySetPlayerRelation(distantAllyTCQuery, cPlayerRelationAlly);
            kbUnitQuerySetUnitType(distantAllyTCQuery, cUnitTypeAbstractSettlement);
            kbUnitQuerySetState(distantAllyTCQuery, cUnitStateAlive);
            kbUnitQuerySetPosition(distantAllyTCQuery, mainBaseLocation);
            kbUnitQuerySetAscendingSort(distantAllyTCQuery, true);
			if (gTransportMap == true)
			kbUnitQuerySetAreaGroupID(distantAllyTCQuery, kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))));
		}
        kbUnitQueryResetResults(distantAllyTCQuery);
        int tcCount = kbUnitQueryExecute(distantAllyTCQuery);
        int tcID = -1;
        if (tcCount > 0)
        {
            tcID = kbUnitQueryGetResult(distantAllyTCQuery, tcCount-1);
            allyLocation = kbUnitGetPosition(tcID);
		}
		
        if ( xsVectorGetX(allyLocation) < (kbGetMapXSize()/2) )
        {  // we're on bottom left half
            if ( xsVectorGetZ(allyLocation) < (kbGetMapZSize()/2) )
            {  // we're lower right half ergo bottom corner
                closestToAlly = 0;  // x0,z0
			}
            else
            {  // we're on upper left half, ergo left
                closestToAlly = 1;  // x0, z1
			}
		}
        else
        {  // we're on upper right half
            if ( xsVectorGetZ(allyLocation) > (kbGetMapZSize()/2) )
            {  // we're upper left half ergo top corner
                closestToAlly = 3;  // x1, z1
			}
            else
            {  // we're on bottom right half, ergo right
                closestToAlly = 2;  // x1, z0
			}
		}
		
        // Now, sort it all out...
        // Since we can't override the tendency to trade with our own settlements, this is what we'll do.
        // If the most distant ally's closest corner is not the same as ours, we'll go there.  
        // If we don't have an ally, or the ally's closest corner is the same as ours, we'll use our 
        // second closest corner.
		
        int chosenCorner = -1;
		static int LastCorner = -1;
		static int SwitchCount = 0;
		
        if ((mapRestrictsMarketAttack() == false) && (IhaveAllies == false) || (cRandomMapName == "watering hole"))
        {
		    if ((aiRandInt(3) <= 1) && (cRandomMapName != "watering hole"))
			chosenCorner = secondClosestToMe;
			else
			chosenCorner = closestToMe;
		}
        else
        {
            if ((tcID < 0) || (closestToAlly == closestToMe))
            {
                chosenCorner = closestToMe;
			}
            else
            {
                chosenCorner = closestToAlly;
			}
		}
		if (LastCorner == -1)
		LastCorner = chosenCorner;
	    
		if ((LastCorner != chosenCorner) && (LastCorner != -1))
		{
			SwitchCount = SwitchCount + 1;
			if (SwitchCount >= 2)
			{
				LastCorner = chosenCorner;
				SwitchCount  = 0;
			}
			else
			chosenCorner = LastCorner;
	    }
		
        switch(chosenCorner)
        {
            case 0:
            {  // X and Z low
                marketLocation = xsVectorSetX(marketLocation, 2);
                marketLocation = xsVectorSetZ(marketLocation, 2);
                break;
			}
            case 1:
            {  // X low, Z hi
                marketLocation = xsVectorSetX(marketLocation, 2);
                marketLocation = xsVectorSetZ(marketLocation, kbGetMapZSize()-2);
                break;
			}
            case 2:
            {  // X hi, Z lo
                marketLocation = xsVectorSetX(marketLocation, kbGetMapXSize()-2);
                marketLocation = xsVectorSetZ(marketLocation, 2);
                break;
			}
            case 3:
            {  // X hi, Z hi
                marketLocation = xsVectorSetX(marketLocation, kbGetMapXSize()-2);
                marketLocation = xsVectorSetZ(marketLocation, kbGetMapZSize()-2);
                break;
			}
		}
		
        marketLocation = xsVectorSetY(marketLocation, 0);
		
        // Figure out if it's on our areaGroup.  If not, step 5% closer until it is.
        int homeAreaGroup = -1;
        int marketAreaGroup = -1;
        homeAreaGroup = kbAreaGroupGetIDByPosition(mainBaseLocation);
		
        int i = -1;
        vector towardHome = cInvalidVector;
        towardHome = mainBaseLocation - marketLocation;
        towardHome = towardHome / 20;    // 5% of distance from market to home
        bool success = false;
		
        for (i = 0; < 20)    // Keep testing until areaGroups match
        {
            marketAreaGroup = kbAreaGroupGetIDByPosition(marketLocation);
            if (marketAreaGroup == homeAreaGroup)
            {
                success = true;
                break;
			}
            else
            {
                marketLocation = marketLocation + towardHome;   // Try a bit closer
			}
		}
        
        //override on anatolia
        bool override = false;
        if (cRandomMapName == "anatolia")
        {
            vector backVector = kbBaseGetBackVector(cMyID, mainBaseID);
            float bx = xsVectorGetX(backVector);
            float bz = xsVectorGetZ(backVector);
            bx = bx * 30;
            bz = bz * 30;
			
            backVector = xsVectorSetX(backVector, bx);
            backVector = xsVectorSetZ(backVector, bz);
            backVector = xsVectorSetY(backVector, 0.0);
            vector backLocation = mainBaseLocation + backVector;
            
            int mainBaseAreaID = kbAreaGetIDByPosition(mainBaseLocation);
            int backAreaID = kbAreaGetIDByPosition(backLocation);
            if ((backAreaID != mainBaseAreaID) && (backAreaID != -1))
            {
                vector backAreaLocation = kbAreaGetCenter(backAreaID);
                marketLocation = backAreaLocation;
                float backDistance = xsVectorLength(mainBaseLocation - backAreaLocation);
                if (backDistance < 45.0)
                {
                    int index = -1;
                    int areaID = -1;
                    int areaType = -1;
                    float savedDistance = 0.0;
                    int numBorderAreas = kbAreaGetNumberBorderAreas(backAreaID);
                    for (index = 0; < numBorderAreas)
                    {
                        areaID = kbAreaGetBorderAreaID(backAreaID, index);
                        if (areaID == -1)
						continue;
                        
                        vector areaLocation = kbAreaGetCenter(areaID);
                        float distance = xsVectorLength(mainBaseLocation - areaLocation);
                        if ((distance >= 45.0) && (distance < 85.0))    //away but not too far away
                        {
                            areaType = kbAreaGetType(areaID);
                            if (areaType == cAreaTypeForest)
                            {
                                int numTreesInR15 = getNumUnits(cUnitTypeTree, cUnitStateAlive, -1, 0, areaLocation, 15.0);
                                if (numTreesInR15 > 15)
                                {
                                    if (ShowAiEcho == true) aiEcho("There are too many trees, skipping area");
                                    continue;
								}
							}
                            else if (areaType == cAreaTypeSettlement)
                            {
                                if (ShowAiEcho == true) aiEcho("This is a settlement area, skipping it");
                                continue;
							}
                            else if (areaType == cAreaTypeImpassableLand)
                            {
                                if (ShowAiEcho == true) aiEcho("This is an impassable land area, skipping it");
                                continue;
							}
                            int numBuildingsInR15 = getNumUnits(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cMyID, areaLocation, 15.0);
                            if (numBuildingsInR15 > 3)
                            {
                                if (ShowAiEcho == true) aiEcho("There are too many buildings, skipping area");
                                continue;
							}
                            if (distance > savedDistance)
                            {
                                marketLocation = areaLocation;
                                savedDistance = distance;
                                if (ShowAiEcho == true) aiEcho("setting marketLocation to areaLocation and saving distance");
                                continue;
							}
						}
					}
				}
			}
            else
            {
                marketLocation = mainBaseLocation;
                if (ShowAiEcho == true) aiEcho("setting marketLocation to mainBaseLocation");
			}
            
            override = true;
            success = true;
		}
        //build a local market in 2 min anyway.
        if (extraRuleEnabled == false)
        {
            xsEnableRule("makeExtraMarket");
            extraRuleEnabled = true;
	    }
		
        if (success == false)
        {
            failedBase = mainBaseID;
            return;
		}
        
        if (ShowAiEcho == true) aiEcho("Market target location is "+marketLocation+" in areaGroup "+kbAreaGroupGetIDByPosition(marketLocation));
        gTradeMarketDesiredLocation = marketLocation; // Set the global var for later reference in identifying the trade market.
		
        static float distanceIncrease = 0;
		
		bool Skip = false;
		int MarketsThere = getNumUnits(cUnitTypeMarket, cUnitStateAny, -1, cMyID, gTradeMarketDesiredLocation, 60.0);
        int ExistingPlan = findPlanByString("BUILDMARKET", cPlanBuild, false);
		if ((ExistingPlan != -1) || (MarketsThere > 0))
		Skip = true;
	    if (Skip == false)
	    {
            buildPlanID=aiPlanCreate("BUILDMARKET", cPlanBuild);
            if (buildPlanID < 0)
		    return;		
            //Setup the build plan.
            aiPlanSetVariableInt(buildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeMarket);
            if ((override == false) || (equal(marketLocation, mainBaseLocation) == true))
            {
                aiPlanSetVariableVector(buildPlanID, cBuildPlanInfluencePosition, 0, marketLocation);
                aiPlanSetVariableFloat(buildPlanID, cBuildPlanInfluencePositionDistance, 0, 30.0);
                aiPlanSetVariableFloat(buildPlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
                aiPlanSetVariableInt(buildPlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(marketLocation));
                aiPlanSetVariableInt(buildPlanID, cBuildPlanNumAreaBorderLayers, 0, 2);
		    }
            else
            {
                aiPlanSetVariableFloat(buildPlanID, cBuildPlanRandomBPValue, 0, 0.99);
                aiPlanSetVariableVector(buildPlanID, cBuildPlanCenterPosition, 0, marketLocation);
                aiPlanSetVariableFloat(buildPlanID, cBuildPlanCenterPositionDistance, 0, 15.0 + distanceIncrease);          
		    }
            if (cMyCulture == cCultureAtlantean)
		    aiPlanAddUnitType(buildPlanID, cBuilderType, 1, 1, 1);
            else
		    aiPlanAddUnitType(buildPlanID, cBuilderType, 1, 2, 2);
        	aiPlanSetDesiredPriority(buildPlanID, 100);
        	aiPlanSetEscrowID(buildPlanID, cEconomyEscrowID);
       	    aiPlanSetActive(buildPlanID);
		
        	builtMarket = true;
        	marketTime = xsGetTime(); 
		}
    }
    //If we don't have a query ID, create it.
    static int marketQueryID=-1;
    if (marketQueryID < 0)
    {
        marketQueryID=kbUnitQueryCreate("MarketQuery");
        //If we still don't have one, bail.
        if (marketQueryID < 0)
		return;
        //Else, setup the query data.
        kbUnitQuerySetPlayerID(marketQueryID, cMyID);
        kbUnitQuerySetUnitType(marketQueryID, cUnitTypeMarket);
        kbUnitQuerySetState(marketQueryID, cUnitStateAlive);
	}
	if (gTransportMap == true)
	kbUnitQuerySetAreaGroupID(marketQueryID, kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))));
    kbUnitQuerySetPosition(marketQueryID, gTradeMarketDesiredLocation);
    kbUnitQuerySetAscendingSort(marketQueryID, true);
	
	
    //Reset the results.
    kbUnitQueryResetResults(marketQueryID);
    //Run the query.  
    int numMarkets = kbUnitQueryExecute(marketQueryID);
    
    static int retryCount = 0;
    if (retryCount > 4)
    {
        retryCount = 0;
        xsSetRuleMinIntervalSelf(107);
        distanceIncrease = distanceIncrease + 5.0;
	}
    
    if (numMarkets <= 0)
    {
        if (aiPlanGetState(buildPlanID) < 0)   // No market, and not building or placing
        {  
		    // Scrap it and start over
            aiPlanDestroy(buildPlanID);  			
            buildPlanID = -1;
            builtMarket = false;
            retryCount = retryCount + 1;
		}
        return;        // No market at all, bail
	}
    if (numMarkets < targetNumMarkets)    // Trade market not done yet
    {
        if (aiPlanGetState(buildPlanID) < 0)   // No trade market, and not building or placing
        {  
            // Scrap it and start over 
            aiPlanDestroy(buildPlanID); 		
            buildPlanID = -1;
            builtMarket = false;
            retryCount = retryCount + 1;
		}
        return;
	}
    
    retryCount = 0;
	
    // We have our target number of markets
	
    //reset the gTradeMarketUnitID to -1
    gTradeMarketUnitID = -1;
    
    for (i = 0; < numMarkets)
    {
        int marketUnitID = kbUnitQueryGetResult(marketQueryID, i);
        if (marketUnitID == -1)
		continue;
        
        if (marketUnitID != gExtraMarketUnitID)
        {
            if (ShowAiEcho == true) aiEcho("marketUnitID != gExtraMarketUnitID, setting gTradeMarketUnitID to marketUnitID");
            gTradeMarketLocation = kbUnitGetPosition(marketUnitID);
            gTradeMarketUnitID = marketUnitID;
            break;
		}
	}
    
    if (gTradeMarketUnitID == -1)
    {
        return;
	}
    static bool MarketTower = false;
	if (MarketTower == false)
    xsEnableRule("TowerUpMarket");
	MarketTower = true;
	
    // We have a market for trade, activate the rule to rebuild if lost
    xsEnableRule("rebuildMarket");      // Will restart process if market is lost
	
    //Create the market trade plan.
    if (gTradePlanID >= 0)
    {
        aiPlanDestroy(gTradePlanID);  // Delete old one based on previous market, if any.
        gTradePlanID = -1;
	}
    string planName = "MarketTrade";
    gTradePlanID = aiPlanCreate(planName, cPlanTrade);
    if (gTradePlanID < 0)
	return;
    
    //Get our cart PUID.
    int tradeCartPUID = cUnitTypeAbstractTradeUnit;    
    aiPlanSetInitialPosition(gTradePlanID, kbUnitGetPosition(gTradeMarketUnitID));
    aiPlanSetVariableVector(gTradePlanID, cTradePlanStartPosition, 0, kbUnitGetPosition(gTradeMarketUnitID));
    aiPlanSetVariableInt(gTradePlanID, cTradePlanTradeUnitType, 0, tradeCartPUID);
    aiPlanSetVariableInt(gTradePlanID, cTradePlanMarketID, 0, gTradeMarketUnitID);
    aiPlanAddUnitType(gTradePlanID, tradeCartPUID, 1, 1, 1);     // Just one to start, max 1, maintain plan will adjust later
	aiPlanSetVariableInt(gTradePlanID, cTradePlanTradeUnitTypeMax, 0, 1);
    aiPlanSetVariableInt(gTradePlanID, cTradePlanTargetUnitTypeID, 0, cUnitTypeAbstractSettlement);
    aiPlanSetBaseID(gTradePlanID, mainBaseID);
    aiPlanSetEconomy(gTradePlanID, true);
    aiPlanSetDesiredPriority(gTradePlanID, 100);
    aiPlanSetActive(gTradePlanID);
	
    // Activate the rule to monitor it
    xsEnableRule("monitorTrade");
	distanceIncrease = 0;
    //Go away.
    xsDisableSelf();
}

//==============================================================================
rule sendIdleTradeUnitsToRandomBase
minInterval 17 //starts in cAge3
inactive
{
    if (ShowAiEcho == true) aiEcho("sendIdleTradeUnitsToRandomBase:");
    
    if (ShowAiEcho == true) aiEcho("gTradeMarketUnitID: "+gTradeMarketUnitID);
    //check the trade plan
    if ((gTradeMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0))
    {
        if (ShowAiEcho == true) aiEcho("gTradeMarketUnitID has been destroyed or is -1");
        if (gTradePlanID != -1)
        {
            aiPlanDestroy(gTradePlanID);
            gTradePlanID = -1;
            if (ShowAiEcho == true) aiEcho("killing gTradePlanID");
		}
        
        int activeTradePlans = aiPlanGetNumber(cPlanTrade, -1, true);
        if (ShowAiEcho == true) aiEcho("activeTradePlans: "+activeTradePlans);
        if (activeTradePlans > 0)
        {
            for (i = 0; < activeTradePlans)
            {
                int tradePlanIndexID = aiPlanGetIDByIndex(cPlanTrade, -1, true, i);
                if (tradePlanIndexID != -1)
                {
                    aiPlanDestroy(tradePlanIndexID);
                    if (ShowAiEcho == true) aiEcho("destroying tradePlanIndexID: "+tradePlanIndexID);
				}
			}
		}
	}
	
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive);
    if (numMarkets < 1)
	return;
    
    int tradeCartPUID = cUnitTypeAbstractTradeUnit;
    int numTradeUnits = kbUnitCount(cMyID, tradeCartPUID, cUnitStateAlive);
    if (numTradeUnits < 1)
    {
        if (ShowAiEcho == true) aiEcho("numTradeUnits < 1, returning");
        return;
	}
    
    static int lastUsedMarket = -1;
    static bool override = false;
	bool RetreatMB = false;
    static int count = 0;
    int tradeMarket1ID = -1;
    int tradeMarket2ID = -1;
    
    for (i = 0; < numMarkets)
    {
        int marketID = findUnitByIndex(cUnitTypeMarket, i, cUnitStateAlive, -1, cMyID);
        if (marketID == -1)
		continue;
        
        if ((marketID == gTradeMarketUnitID) && (gTradeMarketUnitID != -1))
        {
            tradeMarket1ID = marketID;
		}
        else
        {
            if (tradeMarket2ID == -1)
            {
                tradeMarket2ID = marketID;
			}
		}
	}
    
    int numEnemyAttBuildingsNearMarketInR50 = 0;
    int numMotherNatureAttBuildingsNearMarketInR50 = 0;
    int numEnemyMilUnitsNearMarketInR30 = 0;
    int myMilUnitsNearMarketInR30 = 0;
    int alliedMilUnitsNearMarketInR30 = 0;
    vector tradeMarketPosition = cInvalidVector;
    vector tradeUnitPos = cInvalidVector;
    vector targetMarketPos = cInvalidVector;
    
    int marketToUse = tradeMarket1ID;   //prefer our gTradeMarketUnitID
    if (marketToUse != -1)
    {
        tradeMarketPosition = kbUnitGetPosition(marketToUse);
        numEnemyAttBuildingsNearMarketInR50 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, tradeMarketPosition, 50.0);
        numMotherNatureAttBuildingsNearMarketInR50 = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, 0, tradeMarketPosition, 50.0);
        numEnemyMilUnitsNearMarketInR30 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, tradeMarketPosition, 30.0, true);
        myMilUnitsNearMarketInR30 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, tradeMarketPosition, 30.0);
        alliedMilUnitsNearMarketInR30 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, tradeMarketPosition, 30.0, true);
        if ((numEnemyAttBuildingsNearMarketInR50 - numMotherNatureAttBuildingsNearMarketInR50 > 0)
		|| (numEnemyMilUnitsNearMarketInR30 - myMilUnitsNearMarketInR30 - alliedMilUnitsNearMarketInR30 > 1))
        {
            marketToUse = -1;
		}
	}
    
    if (marketToUse == -1)
    {
        marketToUse = tradeMarket2ID;
        if (marketToUse == -1)
        {
            if (ShowAiEcho == true) aiEcho("marketToUse == -1, returning");
            return;
		}
	}
    
    if (ShowAiEcho == true) aiEcho("marketToUse: "+marketToUse);
    tradeMarketPosition = kbUnitGetPosition(marketToUse);
    
    if (lastUsedMarket == -1)
    {
		lastUsedMarket = marketToUse;
	}
    
    if (ShowAiEcho == true) aiEcho("lastUsedMarket: "+lastUsedMarket);
    
    if (marketToUse != lastUsedMarket)
    {
        //send all units to our new market
        override = true;
	}
    
    if (gResetTradeMarket == true)
    {
        override = true;
        count = 0;
        gResetTradeMarket = false;
        if (ShowAiEcho == true) aiEcho("gResetTradeMarket == true, setting override = true");
	}
    
    if (override == true)
    {
        vector otradeMarketPosition = kbUnitGetPosition(marketToUse);
        int onumEnemyAttBuildingsNearMarketInR50 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, tradeMarketPosition, 50.0);
        int onumMotherNatureAttBuildingsNearMarketInR50 = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, 0, tradeMarketPosition, 50.0);
        int onumEnemyMilUnitsNearMarketInR30 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, tradeMarketPosition, 30.0, true);
        int omyMilUnitsNearMarketInR30 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, tradeMarketPosition, 30.0);
        int oalliedMilUnitsNearMarketInR30 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, tradeMarketPosition, 30.0, true);
        if ((onumEnemyAttBuildingsNearMarketInR50 - onumMotherNatureAttBuildingsNearMarketInR50 > 0)
		|| (onumEnemyMilUnitsNearMarketInR30 - omyMilUnitsNearMarketInR30 - oalliedMilUnitsNearMarketInR30 > 1))
        {
            RetreatMB = true;
		}
		
        if (count > 1)
        {
            override = false;
            count = 0;
            if (ShowAiEcho == true) aiEcho("count > 0, setting override = false and count = 0");
            lastUsedMarket = marketToUse;
            if (ShowAiEcho == true) aiEcho("setting lastUsedMarket = marketToUse");
		}
        else
        {
            count = count + 1;
            if (ShowAiEcho == true) aiEcho("count: "+count);
		}
	}
    
    int action = cActionIdle;
    int numTradeUnitsToUse = getNumUnits(tradeCartPUID, cUnitStateAlive, action, cMyID);
    if ((numTradeUnitsToUse < 1) || (aiRandInt(10) == 0) || (override == true))
    {
        action = -1;
        numTradeUnitsToUse = getNumUnits(tradeCartPUID, cUnitStateAlive, action, cMyID);
        if (numTradeUnitsToUse < 1)
        {
            if (ShowAiEcho == true) aiEcho("numTradeUnitsToUse < 1, returning");
            return;
		}
	}
    
    if (ShowAiEcho == true) aiEcho("action: "+action);
    
	int numTcs = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    float minRequiredDistance = 36.0;
	
    int tradeDestinationID = -1;
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int mainBaseUnitID = getMainBaseUnitIDForPlayer(cMyID);
    if (mainBaseUnitID != -1)
    {
        float mainBaseTradeRouteLength = xsVectorLength(mainBaseLocation - tradeMarketPosition);
        if (mainBaseTradeRouteLength > minRequiredDistance)
		tradeDestinationID = mainBaseUnitID;
	}
    
    int min = 0;
    int max = 16;
	
    //override
    if (override == true)
	max = numTradeUnitsToUse;   //all trade units
    
    int otherBaseUnitID = -1;
    vector otherBaseUnitPosition = cInvalidVector;
    int tradeUnitID = -1;
    int planID = -1;
    int targetID = -1;
    vector targetPosition = cInvalidVector;
    
    float tradeRouteLength = 0.0;
    float currentTradeRouteLength = 0.0;
    int alliedTradeDestinationID = -1;
    int numAlliedSettlementsInR100 = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, tradeMarketPosition, 220.0);
    if (ShowAiEcho == true) aiEcho("numAlliedSettlementsInR100: "+numAlliedSettlementsInR100);
    if (numAlliedSettlementsInR100 > 0)
    {
        if (numAlliedSettlementsInR100 > 3)
		numAlliedSettlementsInR100 = 3;
        for (i = 0; < numAlliedSettlementsInR100)
        {
            int alliedSettlementIDInR100 = findUnitByRelByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive, -1, cPlayerRelationAlly, tradeMarketPosition, 220.0);
            if (ShowAiEcho == true) aiEcho("alliedSettlementIDInR100: "+alliedSettlementIDInR100);
            if (alliedSettlementIDInR100 != -1)
            {
                vector alliedSettlementLocation = kbUnitGetPosition(alliedSettlementIDInR100);
                float alliedTradeRouteLength = xsVectorLength(alliedSettlementLocation - tradeMarketPosition);
                if (ShowAiEcho == true) aiEcho("alliedTradeRouteLength: "+alliedTradeRouteLength);
                if ((alliedTradeRouteLength > minRequiredDistance) && (kbAreaGroupGetIDByPosition(alliedSettlementLocation) == kbAreaGroupGetIDByPosition(mainBaseLocation)))
				alliedTradeDestinationID = alliedSettlementIDInR100;
			}
		}
	}
    
    if (ShowAiEcho == true) aiEcho("alliedTradeDestinationID: "+alliedTradeDestinationID);
    
    static int flipFlop = 0;
    if (flipFlop == 0)
    {
        flipFlop = 1;
        if (numTradeUnitsToUse > max)
		numTradeUnitsToUse = max;
        for (i = 0; < numTradeUnitsToUse)
        {
            otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
            otherBaseUnitPosition = kbUnitGetPosition(otherBaseUnitID);
			if (kbAreaGroupGetIDByPosition(otherBaseUnitPosition) != kbAreaGroupGetIDByPosition(mainBaseLocation))
			continue;
            tradeRouteLength = xsVectorLength(otherBaseUnitPosition - tradeMarketPosition);
			
            tradeUnitID = findUnitByIndex(tradeCartPUID, i, cUnitStateAlive, action, cMyID);
            if (ShowAiEcho == true) aiEcho("tradeUnitID: "+tradeUnitID);
            if (tradeUnitID > 0)
            {
                if (override == true)
                {
			        if (RetreatMB == true)
					aiTaskUnitMove(tradeUnitID, mainBaseLocation);	
					else 
                    aiTaskUnitWork(tradeUnitID, marketToUse);
                    if (ShowAiEcho == true) aiEcho("Sending trade unit: "+tradeUnitID+" to new market: "+marketToUse);
                    continue;
				}
                
                if (action == -1)   //check the currentTradeRouteLength of all tradeUnits
                {
                    planID = kbUnitGetPlanID(tradeUnitID);
                    if (planID != -1)
					continue;
					
                    targetID = kbUnitGetTargetUnitID(tradeUnitID);
                    if (targetID != -1)
                    {
                        targetPosition = kbUnitGetPosition(targetID);
                        currentTradeRouteLength = xsVectorLength(targetPosition - tradeMarketPosition);
                        if (currentTradeRouteLength > minRequiredDistance)
                        {
                            //50% chance to use the alliedTradeDestinationID
                            if ((alliedTradeDestinationID != -1) && (aiRandInt(4) > 0))
                            {
                                tradeDestinationID = alliedTradeDestinationID;
                                if (ShowAiEcho == true) aiEcho("setting tradeDestinationID = alliedTradeDestinationID");
                                continue;
							}
                            
                            if ((tradeRouteLength > currentTradeRouteLength) && (tradeRouteLength <= 80.0))
                            {
                                tradeDestinationID = otherBaseUnitID;
                                if (ShowAiEcho == true) aiEcho("setting new tradeDestinationID of tradeUnitID: "+tradeUnitID+" to: "+tradeDestinationID);
                                continue;
							}
                            if (ShowAiEcho == true) aiEcho("currentTradeRouteLength of tradeUnitID: "+tradeUnitID+" > minRequiredDistance, no need to change target");
                            continue;
						}
					}
				}
                
                if (tradeRouteLength > minRequiredDistance)
                {
                    if (tradeDestinationID == -1)   // mainBaseTradeRouteLength <= minRequiredDistance
                    {
                        tradeDestinationID = otherBaseUnitID;
					}
                    else
                    {
                        if ((tradeRouteLength > mainBaseTradeRouteLength) || (aiRandInt(10) < 1))
						tradeDestinationID = otherBaseUnitID;
					}
				}
				//50% chance to use the alliedTradeDestinationID
                if ((alliedTradeDestinationID != -1) && (aiRandInt(4) > 0))
                {
                    tradeDestinationID = alliedTradeDestinationID;
                    if (ShowAiEcho == true) aiEcho("setting tradeDestinationID = alliedTradeDestinationID");
				}
                
                if (tradeDestinationID != -1)
                {
                    aiTaskUnitWork(tradeUnitID, tradeDestinationID);				
				}
			}
		}
	}
    else
    {
        flipFlop = 0;
        if (numTradeUnitsToUse > max)
		min = numTradeUnitsToUse - max;
        for (i = numTradeUnitsToUse - 1; >= min)
        {
            otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
            otherBaseUnitPosition = kbUnitGetPosition(otherBaseUnitID);
			if (kbAreaGroupGetIDByPosition(otherBaseUnitPosition) != kbAreaGroupGetIDByPosition(mainBaseLocation))
			continue;			
            tradeRouteLength = xsVectorLength(otherBaseUnitPosition - tradeMarketPosition);
			
            tradeUnitID = findUnitByIndex(tradeCartPUID, i, cUnitStateAlive, action, cMyID);
            if (ShowAiEcho == true) aiEcho("tradeUnitID: "+tradeUnitID);
            if (tradeUnitID > 0)
            {
                if (override == true)
                {
			        if (RetreatMB == true)
					aiTaskUnitMove(tradeUnitID, mainBaseLocation);	
					else
                    aiTaskUnitWork(tradeUnitID, marketToUse);

                    if (ShowAiEcho == true) aiEcho("Sending trade unit: "+tradeUnitID+" to new market: "+marketToUse);
                    continue;
				}
                
                if (action == -1)   //check the currentTradeRouteLength of all tradeUnits
                {
                    planID = kbUnitGetPlanID(tradeUnitID);
                    if (planID != -1)
					continue;
					
                    targetID = kbUnitGetTargetUnitID(tradeUnitID);
                    if (targetID != -1) 
                    {
                        targetPosition = kbUnitGetPosition(targetID);
                        currentTradeRouteLength = xsVectorLength(targetPosition - tradeMarketPosition);
                        if (currentTradeRouteLength > minRequiredDistance)
                        {
                            //50% chance to use the alliedTradeDestinationID
                            if ((alliedTradeDestinationID != -1) && (aiRandInt(4) > 0))
                            {
                                tradeDestinationID = alliedTradeDestinationID;
                                if (ShowAiEcho == true) aiEcho("setting tradeDestinationID = alliedTradeDestinationID");
                                continue;
							}
                            
                            if ((tradeRouteLength > currentTradeRouteLength) && (tradeRouteLength <= 80.0))
                            {
                                tradeDestinationID = otherBaseUnitID;
                                if (ShowAiEcho == true) aiEcho("setting new tradeDestinationID of tradeUnitID: "+tradeUnitID+" to: "+tradeDestinationID);
                                continue;
							}
                            if (ShowAiEcho == true) aiEcho("currentTradeRouteLength of tradeUnitID: "+tradeUnitID+" > minRequiredDistance, no need to change target");
                            continue;
						}
					}
				}
				
                if (tradeRouteLength > minRequiredDistance)
                {
                    if (tradeDestinationID == -1)   // mainBaseTradeRouteLength <= minRequiredDistance
                    {
                        tradeDestinationID = otherBaseUnitID;
					}
                    else
                    {
                        if ((tradeRouteLength > mainBaseTradeRouteLength) || (aiRandInt(10) < 1))
						tradeDestinationID = otherBaseUnitID;
					}
				}
                
                //50% chance to use the alliedTradeDestinationID
                if ((alliedTradeDestinationID != -1) && (aiRandInt(4) > 0))
                {
                    tradeDestinationID = alliedTradeDestinationID;
                    if (ShowAiEcho == true) aiEcho("setting tradeDestinationID = alliedTradeDestinationID");
				}
				
                if (tradeDestinationID != -1)
                {
                    aiTaskUnitWork(tradeUnitID, tradeDestinationID);
				}
			}
		}
	}
}

//==============================================================================
rule airScout1
minInterval 83 //starts in cAge1
inactive
{
    if (ShowAiEcho == true) aiEcho("airScout1:");
    
    static bool delay = false;
    if (delay == true)
    {
        delay = false;
        return;
	}
    
    static bool typeSwitched = false;
    int scoutType = gAirScout;
    vector mapCenter = kbGetMapCenter();
    static vector lastPosition = cInvalidVector;
    
    if (cMyCulture == cCultureGreek)
    {
        int currentPop = kbGetPop();
        int currentPopCap = kbGetPopCap();
        int numScouts = kbUnitCount(cMyID, gAirScout, cUnitStateAlive);
        if (numScouts < 1)
        {
            if ((currentPop > currentPopCap - 2) && (typeSwitched == false))
            {
                aiPlanDestroy(gAirScout1PlanID);
                lastPosition = cInvalidVector;
                int numProdromos = kbUnitCount(cMyID, cUnitTypeProdromos, cUnitStateAlive);
                int numHippikon = kbUnitCount(cMyID, cUnitTypeHippikon, cUnitStateAlive);
                if (numProdromos > 2)
				scoutType = cUnitTypeProdromos;
                else if (numHippikon > 2)
				scoutType = cUnitTypeHippikon;
                else
				scoutType = cUnitTypeHumanSoldier;
                typeSwitched = true;
			}
		}
        else
        {
            if (typeSwitched == true)
            {
                aiPlanDestroy(gAirScout1PlanID);
                lastPosition = cInvalidVector;
                scoutType = gAirScout;
                typeSwitched = false;
			}
		}
	}
    
    int activeExplorePlans = aiPlanGetNumber(cPlanExplore, -1, true);
    if (activeExplorePlans > 0)
    {
        for (i = 0; < activeExplorePlans)
        {
            int explorePlanID = aiPlanGetIDByIndex(cPlanExplore, -1, true, i);
            if (explorePlanID == gAirScout1PlanID)
            {
                int numUnitsInPlan = aiPlanGetNumberUnits(explorePlanID, cUnitTypeUnit);
                if (numUnitsInPlan > 0)
                {
                    int unitID = aiPlanGetUnitByIndex(explorePlanID, 0);
                    if (unitID != -1)
                    {
                        vector currentPosition = kbUnitGetPosition(unitID);
                        if (equal(currentPosition, lastPosition) == true)
                        {
                            delay = true;
                            aiPlanDestroy(explorePlanID);
                            typeSwitched = false;
                            lastPosition = cInvalidVector;
                            aiTaskUnitMove(unitID, mapCenter);
						}
                        else
                        {
                            lastPosition = currentPosition;
						}
					}
                    else
                    {
                        lastPosition = cInvalidVector;
					}
				}
                else
                {
                    lastPosition = cInvalidVector;
				}
                return;
			}
		}
	}
    
    int airScout1PlanID = aiPlanCreate("AirScout1Plan", cPlanExplore);
    if (airScout1PlanID >= 0)
    {
		if ((cMyCulture == cCultureAtlantean) || (cMyCulture == cCultureEgyptian))
		{
		    aiPlanAddUnitType(airScout1PlanID, scoutType, 0, 1, 1);
		    aiPlanSetDesiredPriority(airScout1PlanID, 48);
		}
	    else
		{
		
            aiPlanAddUnitType(airScout1PlanID, scoutType, 1, 1, 1);
		    aiPlanSetDesiredPriority(airScout1PlanID, 100);	
		}
        aiPlanSetVariableBool(airScout1PlanID, cExplorePlanDoLoops, 0, false);
        aiPlanSetVariableBool(airScout1PlanID, cExplorePlanAvoidingAttackedAreas, 0, true);
        aiPlanSetVariableFloat(airScout1PlanID, cExplorePlanLOSMultiplier, 0, 4.0);
        aiPlanSetEscrowID(airScout1PlanID, cEconomyEscrowID);
        aiPlanSetActive(airScout1PlanID);
        gAirScout1PlanID = airScout1PlanID;
	}
}

//==============================================================================
rule airScout2  //air scout plan that doesn't avoid attacked areas
minInterval 79 //starts in cAge1
inactive
{
    if (ShowAiEcho == true) aiEcho("airScout2:");
	
    static bool delay = false;
    if (delay == true)
    {
        delay = false;
        return;
	}
    
    vector mapCenter = kbGetMapCenter();
    static vector lastPosition = cInvalidVector;
    
    int activeExplorePlans = aiPlanGetNumber(cPlanExplore, -1, true);
    if (activeExplorePlans > 0)
    {
        for (i = 0; < activeExplorePlans)
        {
            int explorePlanID = aiPlanGetIDByIndex(cPlanExplore, -1, true, i);
            if (explorePlanID == gAirScout2PlanID)
            {
                int numUnitsInPlan = aiPlanGetNumberUnits(explorePlanID, cUnitTypeUnit);
                if (numUnitsInPlan > 0)
                {
                    int unitID = aiPlanGetUnitByIndex(explorePlanID, 0);
                    if (unitID != -1)
                    {
                        vector currentPosition = kbUnitGetPosition(unitID);
                        if (equal(currentPosition, lastPosition) == true)
                        {
                            delay = true;
                            aiPlanDestroy(explorePlanID);
                            lastPosition = cInvalidVector;
                            aiTaskUnitMove(unitID, mapCenter);
						}
                        else
                        {
                            lastPosition = currentPosition;
						}
					}
                    else
                    {
                        lastPosition = cInvalidVector;
					}
				}
                else
                {
                    lastPosition = cInvalidVector;
				}
                return;
			}
		}
	}
    
    int airScout2PlanID = aiPlanCreate("AirScout2Plan", cPlanExplore);
    if (airScout2PlanID >= 0)
    {
        aiPlanAddUnitType(airScout2PlanID, gAirScout, 1, 1, 1);
        aiPlanSetVariableBool(airScout2PlanID, cExplorePlanDoLoops, 0, false);
        aiPlanSetVariableBool(airScout2PlanID, cExplorePlanAvoidingAttackedAreas, 0, false);
        aiPlanSetVariableFloat(airScout2PlanID, cExplorePlanLOSMultiplier, 0, 6.0);
        aiPlanSetEscrowID(airScout2PlanID, cEconomyEscrowID);
        aiPlanSetDesiredPriority(airScout2PlanID, 99);
        aiPlanSetActive(airScout2PlanID);
        gAirScout2PlanID = airScout2PlanID;
	}
}

//==============================================================================
rule norseInfantryCheck
minInterval 10 //starts in cAge2
inactive
{
    if (ShowAiEcho == true) aiEcho("norseInfantryCheck:");
	
    //Get a count of our ulfsarks.
	int ulfCountS=kbUnitCount(cMyID, cUnitTypeUlfsarkStarting, cUnitStateAlive);
    int ulfCount=kbUnitCount(cMyID, cUnitTypeUlfsark, cUnitStateAlive);
	int AllBuilders=kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive); // just do it!
	ulfCount = ulfCount + ulfCountS + AllBuilders;
    
	if ((kbGetAge() < cAge2) && (ulfCount >= 1) || (xsGetTime() < 2*60*1000) || (ulfCount >= 2))   
    return;
	
	
    //If we're low on infantry, make sure we have at least X pop slots free.
    int availablePopSlots=kbGetPopCap()-kbGetPop();
    if (availablePopSlots >= 3)      // Room for current vil-in-training and ulfsark
	return;
	
    //Else, find a villager to transform or delete.
    //Create/get our query.
    static int vQID=-1;
    if (vQID < 0)
    {
        vQID=kbUnitQueryCreate("NorseInfantryCheckVillagers");
        if (vQID < 0)
        {
            xsDisableSelf();
            return;
		}
	}
    kbUnitQuerySetPlayerID(vQID, cMyID);
    kbUnitQuerySetUnitType(vQID, cUnitTypeAbstractVillager);
    kbUnitQuerySetState(vQID, cUnitStateAlive);
    kbUnitQueryResetResults(vQID);
    int numberVillagers=kbUnitQueryExecute(vQID);
    for (i=0; < numberVillagers)
    {
        int villagerID=kbUnitQueryGetResult(vQID, i);
        if (aiTaskUnitTransform(villagerID) == true)
        {
            vector unitLoc=kbUnitGetPosition(villagerID);
            aiTaskUnitMove(villagerID, unitLoc);
			StuckTransformID = villagerID;
			xsEnableRule("StuckNorseTransform");
            return;
		}
        else if (aiTaskUnitDelete(villagerID) == true)
        {
            availablePopSlots = availablePopSlots+1;
            if (availablePopSlots >= 3)
			return;
		}
	}
}

rule PharaohEmp
minInterval 8
inactive
{
	static bool FirstRun = false;
	if (gEmpowerPlanID == -1)
	return;
	 
	int PlanToUse = gEmpowerPlanID;
	if ((kbUnitCount(cMyID, cUnitTypePharaohofOsiris, cUnitStateAlive) > 0) && (eOsiris >= 0))
	{
		PlanToUse = eOsiris;
		aiPlanAddUnitType(gEmpowerPlanID, cUnitTypePharaoh, 0, 0, 0);
	}	
	else
	aiPlanAddUnitType(gEmpowerPlanID, cUnitTypePharaoh, 1, 1, 1);	

    if (FirstRun == false)
	{
	    int Pharaoh = findUnit(cUnitTypePharaoh, cUnitStateAlive, cActionIdle, cMyID);
		int TC = findUnit(cUnitTypeDropsite, cUnitStateBuilding, -1, cMyID);
	    if (TC == -1)
	    TC = findUnit(cUnitTypeDropsite, cUnitStateAliveOrBuilding, -1, cMyID);
	    if ((Pharaoh != -1) && (TC != -1))
	    aiTaskUnitWork(Pharaoh, TC);
	    FirstRun = true;
		return;
	}
	
	int CurrentEmpowerID = aiPlanGetVariableInt(PlanToUse, cEmpowerPlanTargetID, 0);
	int Agg = findPlanByString("AutoGPFoodHuntAggressive", cPlanGather);
	if (Agg != -1)
	{
		if ((CurrentEmpowerID != aiPlanGetVariableInt(Agg, cGatherPlanDropsiteID, 0)) && (aiPlanGetVariableInt(Agg, cGatherPlanDropsiteID, 0) != -1))
		{	
		    aiPlanSetVariableInt(PlanToUse, cEmpowerPlanTargetID, 0, aiPlanGetVariableInt(Agg, cGatherPlanDropsiteID, 0));
			return;
		}
	}
    if (gFarming == true)
	{
		for (i = 0; < aiPlanGetNumber(cPlanFarm, -1, true))
		{
			int FarmPlanID = aiPlanGetIDByIndex(cPlanFarm, -1, true, i);
			if (FarmPlanID == -1)
			continue;
			if (aiPlanGetBaseID(FarmPlanID) == gFarmBaseID)
			{
				vector InitialPos = aiPlanGetInitialPosition(FarmPlanID);
				int CurrentID = aiPlanGetVariableInt(FarmPlanID, cFarmPlanDropsiteID, 0);					
				CurrentEmpowerID = aiPlanGetVariableInt(PlanToUse, cEmpowerPlanTargetID, 0);
				if ((kbUnitIsType(CurrentEmpowerID, cUnitTypeGranary) == true) && (kbUnitIsType(CurrentID, cUnitTypeAbstractSettlement) == true))
			    {
					aiPlanSetVariableInt(PlanToUse, cEmpowerPlanTargetID, 0, aiPlanGetVariableInt(FarmPlanID, cFarmPlanDropsiteID, 0));
					break;
				}
			}
		}
	}
}