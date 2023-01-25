//==============================================================================
// AoMod
// AoModAIEcon.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// Handles common economy functions.
//==============================================================================

//==============================================================================
rule updateBreakdowns
minInterval 12
inactive
{   
    if ((aiGetGameMode() == cGameModeDeathmatch) && (kbGetAge() < cAge4) && (xsGetTime() < 4*60*1000))
	return;

    for (i = 0; < 2)
	{   
        int Resource = cResourceWood;
		float ChosenForcast = gWoodForecast;
	    int cNumberPlanType = cGatherGoalPlanNumWoodPlans;
        int BaseID = gWoodBaseID;
		int PlanPriority = 50;
        if (i == 1)
		{
		    Resource = cResourceGold;
			ChosenForcast = gGoldForecast;
			cNumberPlanType = cGatherGoalPlanNumGoldPlans;
			BaseID = gGoldBaseID;
			if (gGoldForecast-kbResourceGet(cResourceGold) > gWoodForecast-kbResourceGet(cResourceWood))
			PlanPriority = 56;
			else if (cMyCulture != cCultureEgyptian)
			PlanPriority = 49;
			else
			PlanPriority = 51;
			
	    }
		int mainBaseID = kbBaseGetMainID(cMyID);
		vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	
		int randomBaseID = mainBaseID;
		int randomBase = findUnit(cUnitTypeAbstractSettlement);
		if (randomBase >= 0)
		randomBaseID = kbUnitGetBaseID(randomBase);
		
		bool BaseOnOtherAG = true;
		if ((gTransportMap == true) && (SameAG(kbBaseGetLocation(cMyID, BaseID), kbBaseGetLocation(cMyID, mainBaseID)) == false))
		BaseOnOtherAG = false;
		float ResSupply = kbResourceGet(Resource) * 1.25;
		float Forecast = ChosenForcast;	
		if (Forecast <= 0)
		Forecast = 0;
		
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
		int Villagers = kbUnitCount(cMyID,cUnitTypeAbstractVillager,cUnitStateAlive);
		int GathererCount = 0.5 + aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, Resource) * Villagers;
		// If we have no need for res, set plans=0 and exit
		if (GathererCount <= 0)
		{
			aiPlanSetVariableInt(gGatherGoalPlanID, cNumberPlanType, 0, 0);
			aiRemoveResourceBreakdown(Resource, cAIResourceSubTypeEasy, mainBaseID);
			if (BaseID != mainBaseID)
			aiRemoveResourceBreakdown(Resource, cAIResourceSubTypeEasy, BaseID);
			continue;
		}

		// If we're this far, we need some res gatherers.  The number of plans we use will be the greater of 
		// a) the ideal number for this number of gatherers, or
		// b) the number of plans active that have resource sites, either main base or res base.
		
		//Count of sites.
		int numberMainBaseSites = kbGetNumberValidResources(mainBaseID, Resource, cAIResourceSubTypeEasy);
		bool ResBaseEmpty = true;
		if (ResourceBaseID != -1)
		{
	        int ResourceBaseSites = kbGetNumberValidResources(ResourceBaseID, Resource, cAIResourceSubTypeEasy);
		    if (ResourceBaseSites > 0)
		    ResBaseEmpty = false; 
		    if ((i == 0) && (ResBaseEmpty == false) && (kbGetAge() > cAge1))
		    numberMainBaseSites = 0;
		    if (ResBaseEmpty == true)
		    aiRemoveResourceBreakdown(Resource, cAIResourceSubTypeEasy, ResourceBaseID);
		}
		int numberResBaseSites = 0;
		if ((BaseID >= 0) && (BaseID != mainBaseID))    // Count res base if different
		numberResBaseSites = kbGetNumberValidResources(BaseID, Resource, cAIResourceSubTypeEasy);
		if ((BaseID == ResourceBaseID) && (ResBaseEmpty == true))
		numberResBaseSites = 0;		
		//Get the count of plans we currently have going.
		int numPlans = aiPlanGetVariableInt(gGatherGoalPlanID, cNumberPlanType, 0);
		
	    int desiredPlans = 2;
	    if (cMyCulture == cCultureAtlantean)
		desiredPlans = 1 + (GathererCount/4);
		else if ((cMyCulture == cCultureEgyptian) && (i == 0))
	    desiredPlans = 1 + (GathererCount/12);
		else if ((cMyCulture != cCultureEgyptian) && (i == 1))
	    desiredPlans = 1 + (GathererCount/12);
	
		if (desiredPlans > 2)
		desiredPlans = 2;
	    if ((kbGetAge() == cAge1) || (kbGetAge() == cAge2) && (kbUnitCount(cMyID,cUnitTypeAge2Building, cUnitStateAlive) < 2))
		desiredPlans = 1;
		
		if (GathererCount < desiredPlans)
		desiredPlans = GathererCount;
		if ((Percentage < 0.75) && (numPlans > 0) && (ResSupply > 2000))
		desiredPlans = 1;
		else if (desiredPlans < numPlans)
		desiredPlans = numPlans;    // Try to preserve existing plans
	    if ((numberMainBaseSites > 1) && (ResBaseEmpty == false))
		numberMainBaseSites = 1;
	
		if (i == 0)
		aiPlanSetUserVariableInt(gSomeData, 15, 0, numberMainBaseSites+numberResBaseSites);
	    else
		aiPlanSetUserVariableInt(gSomeData, 14, 0, numberMainBaseSites+numberResBaseSites);	
	
		if (BaseOnOtherAG == false)
		{
			int Transport = kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateAlive);
			int TransPlan = findPlanByString("Remote Resource Refill Transport", cPlanTransport, -1);
			int numVills = 0;
			vector BaseLoc = kbBaseGetLocation(cMyID, BaseID);
			int AreaID = kbAreaGroupGetIDByPosition(BaseLoc);
			int WorkersThere = NumUnitsOnAreaGroupByRel(true, AreaID, cUnitTypeAbstractVillager, cMyID);
			if (SameAG(kbBaseGetLocation(cMyID, gGoldBaseID), kbBaseGetLocation(cMyID, gWoodBaseID)) == true)
			{
				if (i == 0)
			    WorkersThere = WorkersThere - (aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold) * Villagers);
				else
				WorkersThere = WorkersThere - (aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood) * Villagers);
			}
			
			if (WorkersThere < GathererCount)
			numVills = GathererCount - WorkersThere;
			if ((Transport < 1) && (TransPlan != -1))
			aiPlanDestroy(TransPlan);
			if (cMyCulture == cCultureAtlantean)
			Villagers = Villagers * 2;
			if ((numVills > 0) && (Transport > 0) && (TransPlan == -1) && (Villagers > 14) && (findPlanByString("Remote Resource Transport", cPlanTransport) == -1))
			{
				if (cMyCulture == cCultureAtlantean)
				{
					if (numVills > 3)
					numVills = 3;
					else if (numVills <= 1)
					numVills = 1;		
				}		
				else
				{
					if (numVills > 12)
					numVills = 12;
					else if (numVills <= 1)
					numVills = 1;	
				}
				if ((numVills > 3) || (cMyCulture == cCultureAtlantean) && (numVills > 0))
				{
					vector here=kbBaseGetLocation(cMyID, mainBaseID);
					int startAreaID=kbAreaGetIDByPosition(here);
					int DestAreaID=kbAreaGetIDByPosition(BaseLoc);
					int resourceTransportPlan=createTransportPlan("Remote Resource Refill Transport", startAreaID, DestAreaID, false, cUnitTypeTransport, 80, mainBaseID);
					if (resourceTransportPlan != -1)
					{
						aiPlanAddUnitType(resourceTransportPlan, cUnitTypeAbstractVillager, numVills, numVills, numVills);
						if (cMyCulture == cCultureNorse)
						{	
							int oxCarts = NumUnitsOnAreaGroupByRel(true, AreaID, cUnitTypeOxCart, cMyID);
							int WantedThere = 2;
							if (gGoldBaseID == gWoodBaseID)
							WantedThere = 4;
							if (oxCarts < WantedThere)
							aiPlanAddUnitType( resourceTransportPlan, cUnitTypeOxCart, 1, 1, 1);
						}
						aiPlanSetRequiresAllNeedUnits(resourceTransportPlan, true);
						aiPlanSetActive(resourceTransportPlan);
					}
				}
			}
		}	
		// Three cases are possible:
		// 1)  We have enough sites at our main base.  All should work in main base.
		// 2)  We have some res at main, but not enough.  Split the sites
		// 3)  We have no res at main...use resBase
		
		if (numberMainBaseSites >= desiredPlans) // case 1
		{
			// remove any breakdown for resBaseID
			if (BaseID != mainBaseID)
			aiRemoveResourceBreakdown(Resource, cAIResourceSubTypeEasy, BaseID);
			BaseID = mainBaseID;
			if (i == 0)
			gWoodBaseID = BaseID;
            else
			gGoldBaseID = BaseID;
			aiSetResourceBreakdown(Resource, cAIResourceSubTypeEasy, desiredPlans, PlanPriority, Percentage, BaseID);
			aiPlanSetVariableInt(gGatherGoalPlanID, cNumberPlanType, 0, desiredPlans);
			continue;
		}
		
		if ((numberMainBaseSites > 0) && (numberMainBaseSites < desiredPlans))  // case 2
		{
			aiSetResourceBreakdown(Resource, cAIResourceSubTypeEasy, numberMainBaseSites, PlanPriority, Percentage, mainBaseID);
			
			if (numberResBaseSites > 0)  // We do have remote res
			{
				aiSetResourceBreakdown(Resource, cAIResourceSubTypeEasy, desiredPlans - numberMainBaseSites, PlanPriority, Percentage, BaseID);	
				aiPlanSetVariableInt(gGatherGoalPlanID, cNumberPlanType, 0, desiredPlans);
			}
			else  // No remote res...bummer.  Kill old breakdown, look for more
			{
				if (BaseID != mainBaseID)		
				aiRemoveResourceBreakdown(Resource, cAIResourceSubTypeEasy, BaseID);   // Remove old breakdown
				//Try to find a new res base.
			    if ((ResourceBaseID != -1) && (ResBaseEmpty == false))
				BaseID=kbBaseFindCreateResourceBase(Resource, cAIResourceSubTypeEasy, ResourceBaseID);
				else
				BaseID=kbBaseFindCreateResourceBase(Resource, cAIResourceSubTypeEasy, randomBaseID);
				if (BaseID >= 0)
				{
					aiSetResourceBreakdown(Resource, cAIResourceSubTypeEasy, desiredPlans - numberMainBaseSites, PlanPriority, Percentage, BaseID);	
					aiPlanSetVariableInt(gGatherGoalPlanID, cNumberPlanType, 0, desiredPlans);      // We can have the full amount
			        if (i == 0)
			        gWoodBaseID = BaseID;
                    else
			        gGoldBaseID = BaseID;					
				}
				else
				{
					aiPlanSetVariableInt(gGatherGoalPlanID, cNumberPlanType, 0, numberMainBaseSites);   // That's all we get
				}
			}
			continue;
		}
		
		if (numberMainBaseSites < 1)  // case 3
		{
			aiRemoveResourceBreakdown(Resource, cAIResourceSubTypeEasy, mainBaseID);
			
			if (numberResBaseSites >= desiredPlans)  // We have enough remote res
			{
				aiSetResourceBreakdown(Resource, cAIResourceSubTypeEasy, desiredPlans, PlanPriority, Percentage, BaseID);
				aiPlanSetVariableInt(gGatherGoalPlanID, cNumberPlanType, 0, desiredPlans);
			}
			else if (numberResBaseSites > 0)   // We have some, but not enough
			{
				aiSetResourceBreakdown(Resource, cAIResourceSubTypeEasy, numberResBaseSites, PlanPriority, Percentage, BaseID);
				aiPlanSetVariableInt(gGatherGoalPlanID, cNumberPlanType, 0, numberResBaseSites);
			}
			else  // We have none, try elsewhere
			{
				int oldResBase=BaseID;
				aiRemoveResourceBreakdown(Resource, cAIResourceSubTypeEasy, BaseID);   // Remove old breakdown
				//Try to find a new res base.
				if ((ResourceBaseID != -1) && (ResBaseEmpty == false))
				BaseID=kbBaseFindCreateResourceBase(Resource, cAIResourceSubTypeEasy, ResourceBaseID);
				else
				BaseID=kbBaseFindCreateResourceBase(Resource, cAIResourceSubTypeEasy, randomBaseID);
				if ((BaseID < 0) && (gTransportMap == true)) // did not find base on my mainbase
				{
					// try to find a res base on another island
					BaseID = newResourceBase(oldResBase, Resource);
				}			
				
				if (BaseID >= 0)
				{
			        if (i == 0)
			        gWoodBaseID = BaseID;
                    else
			        gGoldBaseID = BaseID;				
					numberResBaseSites = kbGetNumberValidResources(BaseID, Resource, cAIResourceSubTypeEasy);
					if (numberResBaseSites < desiredPlans)
					desiredPlans = numberResBaseSites;
					aiPlanSetVariableInt(gGatherGoalPlanID, cNumberPlanType, 0, desiredPlans);      
					aiSetResourceBreakdown(Resource, cAIResourceSubTypeEasy, desiredPlans, PlanPriority, Percentage, BaseID);
				}
			}
			continue;
		}
	}
}
//==============================================================================
rule updateFoodBreakdown
minInterval 6
inactive
{
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
	}

    int numAggressivePlans = aiGetResourceBreakdownNumberPlans(cResourceFood, cAIResourceSubTypeHuntAggressive, mainBaseID);
	
	float distance = gMaximumBaseResourceDistance - 10;
	
    //Get the number of valid resources spots.
    int numberAggressiveResourceSpots = kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeHuntAggressive, distance);
    int numberEasyResourceSpots = kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeEasy, distance);
    // Only do one aggressive site at a time, they tend to take lots of gatherers
    if (numberAggressiveResourceSpots > 1)
	numberAggressiveResourceSpots = 1;
    int totalNumberResourceSpots = numberAggressiveResourceSpots + numberEasyResourceSpots;
    int gathererCount = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    int foodGathererCount = 0.5 + aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood) * gathererCount;
    
    if (foodGathererCount < 1) //always some units on food
    foodGathererCount = 1;

    MoreFarms = foodGathererCount; // Update build more farms
	if (MoreFarms >= 26)
	MoreFarms = 26;
    if ((cMyCulture == cCultureAtlantean) && (MoreFarms >= 6))
	MoreFarms = 6;

	
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
    int numShooters = -1;
	int TC = -1;
    float distanceToMainBase = 0.0;
    vector otherBaseLocation = cInvalidVector;
    int farmsWanted = 3;

 	if (gFarmBaseID >= 0)  // Farms get first priority
    {
        farmerReserve = kbBaseGetNumberUnits(cMyID, gFarmBaseID, -1, cUnitTypeFarm);
        if (cMyCulture != cCultureAtlantean)
		{
			if (gOtherBase1ID > 0)
			{
				otherBaseLocation = kbBaseGetLocation(cMyID, gOtherBase1ID);
				numBuilding1NearBase = getNumUnits(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				numShooters = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				TC = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
				
				if ((numBuilding1NearBase > 1) && (numShooters > 1) && (TC > 0) || (distanceToMainBase < 75.0) && (numShooters > 0) && (TC > 0))
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
				numBuilding1NearBase = getNumUnits(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				numShooters = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				TC = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
				
				if ((numBuilding1NearBase > 1) && (numShooters > 1) && (TC > 0) || (distanceToMainBase < 75.0) && (numShooters > 0) && (TC > 0))
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
				numBuilding1NearBase = getNumUnits(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				numShooters = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				TC = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
				
				if ((numBuilding1NearBase > 1) && (numShooters > 1) && (TC > 0) || (distanceToMainBase < 75.0) && (numShooters > 0) && (TC > 0))
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
				numBuilding1NearBase = getNumUnits(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				numShooters = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				TC = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, otherBaseLocation, 25.0);
				distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
				
				if ((numBuilding1NearBase > 1) && (numShooters > 1) && (TC > 0) || (distanceToMainBase < 75.0) && (numShooters > 0) && (TC > 0))
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
	|| (xsGetTime() > 9*60*1000))
	totalAmount = 200;

    if ((kbGetAge() > cAge1) || ((cMyCulture == cCultureEgyptian) && (xsGetTime() > 3*60*1000)))   // can build farms
    {
        if ((totalNumberResourceSpots < 2) || (totalAmount <= 1500) || (gFarming == true) || (kbGetAge() > cAge2))
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
			    xsEnableRule("fixUnfinishedFarms");
				extraFarms = true;
			}			
		 }
	}
	int numPlansWanted = 2;
    int farmThreshold = 15;
    if (cMyCulture == cCultureAtlantean)
    farmThreshold = 5;
	if ((gFarming == true) && (farmerReserve >= farmThreshold))
    numPlansWanted = 1;

    int numTemples = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding);
    int houseProtoID = cUnitTypeLogicalTypeHouses;
    if (cMyCulture == cCultureAtlantean)
	numTemples = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
    int numHouses = kbUnitCount(cMyID, houseProtoID, cUnitStateAlive);
    if ((kbGetAge() == cAge1) && (numTemples < 1) || (unassigned < numPlansWanted) || (kbGetAge() == cAge1) && (cMyCulture == cCultureNorse))
    {
        numPlansWanted = 1;
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

    if (unassigned <= 0)
    numPlansWanted = 0;
 
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
		    if ((aiGetWorldDifficulty() >= cDifficultyHard) && (aiGetGameMode() != cGameModeLightning) && (cMyCulture != cCultureAtlantean))
			numFarmPlansWanted = numFarmPlansWanted + 2;	
			else numFarmPlansWanted = numFarmPlansWanted + 1;               
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
}
 
//==============================================================================
void updateResourceHandler(int parm=0)
{
    //Handle food.
    if (parm == cResourceFood)
    {
        updateFoodBreakdown();
	}
    //Handle Gold.
    if (parm == cResourceGold)
    {
        updateBreakdowns();
	}
    //Handle Wood.
    if (parm == cResourceWood)
    {
        updateBreakdowns();
	}
}

//==============================================================================
int changeMainBase(int newSettle = -1)
{
    int newBaseID=kbUnitGetBaseID(newSettle);
    int oldMainBase=kbBaseGetMainID(cMyID);
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
    
    //enable favor breakdown for our new mainBaseID
    if (cMyCulture == cCultureGreek)
    {
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans);
        aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, 41, 1.0, mainBaseID);
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
        ResourceBaseID = CreateBaseInBackLoc(newBaseID, 25, gMaximumBaseResourceDistance, "Temp Resource Base");
	}

    // call these to update the gatherplans with the new mainbase
    updateFoodBreakdown();
    updateBreakdowns();
    return(newBaseID);
}

//==============================================================================
rule relocateFarming
minInterval 26 //starts in cAge2 (or cAge3 on transport maps)
inactive
{
	int mainBaseID = kbBaseGetMainID(cMyID);
	vector fbaseLocation = kbBaseGetLocation(cMyID, gFarmBaseID);
	static int count = 0;
	if (count >= 3)
	{
	    xsSetRuleMinIntervalSelf(7);	
        count = 3;
	}
	else
	xsSetRuleMinIntervalSelf(26);

    //Fixup the old RB for farming.
    if (gFarmBaseID != -1)
    {
        int MyUnits = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, fbaseLocation, 80.0);
		int AllyUnits = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, fbaseLocation, 80.0, true);
		int NumEnemy = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, fbaseLocation, 95.0, true);
		int AllyStoleMyTC = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, fbaseLocation, 10.0, true);
		int EnemyTC = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, fbaseLocation, 10.0, true);
		int mNatureSettle = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, fbaseLocation, 10.0);
		int total = AllyStoleMyTC+EnemyTC-mNatureSettle;
	    if ((findNumUnitsInBase(cMyID, gFarmBaseID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) > 0) 
		|| (MyUnits+AllyUnits >= NumEnemy) && (AllyStoleMyTC+EnemyTC-mNatureSettle < 1))
		{
	        count = 0;
		    return;
		}
		else
		{	
	        count = count + 1;
	        xsSetRuleMinIntervalSelf(7);
		}
	
	    if  (count >= 3)
		{	
            aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gFarmBaseID);
	        xsSetRuleMinIntervalSelf(7);
		}
		else
		return;
	}
	
    //If no settlement, then move the farming to another base that has a settlement.
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (numSettlements > 0)
    {    
	    int unit=findUnit(cUnitTypeAbstractSettlement);
		int BetterTc = FindSaferTC();
		if (BetterTc != -1)
		unit = BetterTc;
	
        //Get new base ID.
        gFarmBaseID = kbUnitGetBaseID(unit);
        
        //Remove the breakdown if there's already one for the farm base.
        aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gFarmBaseID);
        
        //Make a new breakdown.
        int numFarmPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm);
        aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, numFarmPlans, 90, 1.0, gFarmBaseID);
		
        if ((cvMapSubType != VINLANDSAGAMAP) || (VinOkToChange == true))
        {
            // update mainbase
            // should work now
            changeMainBase(unit);
			count = 0;
			if (ShowAIDebug == true) aiEcho("I'm in trouble.. new Mainbase ID: "+unit);
		}
	}
    else
    {
        //If there are no other bases without settlements... stop farming.
        gFarmBaseID=-1;
        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, 0);
		count = 3;
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
    //Land based Scouting.
    gLandExplorePlanID=aiPlanCreate("Explore_Land", cPlanExplore);
    int explorePlan = aiPlanGetIDByIndex(cPlanExplore, -1, true, 0);
    if (gLandExplorePlanID >= 0)
    {
        if (cMyCulture == cCultureAtlantean )
        {
            aiPlanAddUnitType(gLandExplorePlanID, cUnitTypeAbstractScout, 0, 1, 1);
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
    
    if (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive) < 1)
	return;
	
    aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanCanBuildLOSProto, 0, true);
    xsDisableSelf();
}

//==============================================================================
void econAge2Handler(int age=1)
{
    // Start early settlement monitor if not already active (vinland, team mig, nomad)
    xsEnableRule("buildSettlements");
    
    //fishing
    if (gFishing == true)
	xsEnableRule("getPurseSeine");
	
    // Transports
    if (gTransportMap == true) 
	xsEnableRule("getEnclosedDeck");

    if (cvMapSubType == VINLANDSAGAMAP)
	xsEnableRule("VinLandMBChange");
	
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
	kbEscrowSetCap(cEconomyEscrowID, cResourceWood, 300.0);
	kbEscrowSetCap(cEconomyEscrowID, cResourceGold, 500.0);    // Age 3
    kbEscrowSetCap(cEconomyEscrowID, cResourceFavor, 50.0);
    kbEscrowSetCap(cMilitaryEscrowID, cResourceFood, 100.0);
    kbEscrowSetCap(cMilitaryEscrowID, cResourceWood, 200.0);   // Towers
    kbEscrowSetCap(cMilitaryEscrowID, cResourceGold, 200.0);   // Towers
    kbEscrowSetCap(cMilitaryEscrowID, cResourceFavor, 50.0);
}


//==============================================================================
void econAge3Handler(int age=0)
{
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
    kbEscrowSetCap( cEconomyEscrowID, cResourceFavor, 50.0);
    kbEscrowSetCap( cMilitaryEscrowID, cResourceFood, 400.0);
    kbEscrowSetCap( cMilitaryEscrowID, cResourceWood, 400.0);
    kbEscrowSetCap( cMilitaryEscrowID, cResourceGold, 400.0);
    kbEscrowSetCap( cMilitaryEscrowID, cResourceFavor, 50.0);
	
    kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 85.0);
}

//==============================================================================
void econAge4Handler(int age=0)
{
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
		kbEscrowSetCap(cEconomyEscrowID, cResourceFood, 800.0);
		kbEscrowSetCap(cEconomyEscrowID, cResourceWood, 800.0);     
		kbEscrowSetCap(cEconomyEscrowID, cResourceGold, 800.0);    
	}
	else 
	{
		kbEscrowSetCap(cEconomyEscrowID, cResourceFood, 400.0);    
		kbEscrowSetCap(cEconomyEscrowID, cResourceWood, 400.0);
		kbEscrowSetCap(cEconomyEscrowID, cResourceGold, 400.0);    
		kbEscrowSetCap(cEconomyEscrowID, cResourceFavor, 50.0);
	}
	kbEscrowSetCap(cEconomyEscrowID, cResourceFavor, 50.0);
    kbEscrowSetCap(cMilitaryEscrowID, cResourceFood, 400.0);
    kbEscrowSetCap(cMilitaryEscrowID, cResourceWood, 400.0);   
    kbEscrowSetCap(cMilitaryEscrowID, cResourceGold, 400.0);   
    kbEscrowSetCap(cMilitaryEscrowID, cResourceFavor, 50.0);
}

//==============================================================================
void createCivPopPlan()
{
    if ((cMyCulture == cCultureNorse) && (aiGetGameMode() == cGameModeDeathmatch) && (kbGetAge() < cAge4))
	return;
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
	xsEnableRule("econForecastAge1");
}

//==============================================================================
void postInitEcon()
{
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
    if ((cvMapSubType == WATERNOMADMAP) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive) < 1))
	return;
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
		if ((Villager != -1) && (kbUnitGetPlanID(Villager) == -1) && (SameAG(UnitLocation, mainBaseLocation) == false) && (kbAreaGetType(AreaID) != cAreaTypeWater)
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
		if ((Caravan != -1) && (SameAG(UnitLocation, mainBaseLocation) == false) && (kbAreaGetType(AreaID) != cAreaTypeWater))
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
		if (upgradeTechID == -1)
		return;
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
        id++;
	}
}

//==============================================================================
rule createHerdplan
minInterval 1 //starts in cAge1
inactive
{
	xsSetRuleMinIntervalSelf(68);
    if (gHerdPlanID >= 0)
	{
		if ((cRandomMapName != "vinlandsaga") && (cRandomMapName != "team migration"))
		aiPlanSetBaseID(gHerdPlanID, kbBaseGetMainID(cMyID));
		else
		{
			if (gResearchGranaryID >= 0)
			aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingID, 0, gResearchGranaryID);
			else if (gResearchGranaryID < 0)
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
	return;
	}
	
    gHerdPlanID=aiPlanCreate("GatherHerdable Plan", cPlanHerd);
    if (gHerdPlanID < 0)
    return;	

    aiPlanAddUnitType(gHerdPlanID, cUnitTypeHerdable, 0, 100, 100);
    aiPlanSetVariableFloat(gHerdPlanID, cHerdPlanDistance, 0, 16.0);
    if ((cRandomMapName != "vinlandsaga") && (cRandomMapName != "team migration"))
    aiPlanSetBaseID(gHerdPlanID, kbBaseGetMainID(cMyID));		
    aiPlanSetActive(gHerdPlanID);
}

//==============================================================================
rule monitorTrade
inactive
minInterval 23 //starts in cAge3, activated in tradeWithCaravans
{
    if (((gTradeMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0))
	|| (gTradeMarketUnitID == -1))
    {
        if (gTradePlanID != -1)
        {
            aiPlanDestroy(gTradePlanID);
            gTradePlanID = -1;
		}
        
        int activeTradePlans = aiPlanGetNumber(cPlanTrade, -1, true);
        if (activeTradePlans > 0)
        {
            for (i = 0; < activeTradePlans)
            {
                int tradePlanIndexID = aiPlanGetIDByIndex(cPlanTrade, -1, true, i);
                if (tradePlanIndexID != -1)
                {
                    aiPlanDestroy(tradePlanIndexID);
				}
			}
		}
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
		}
        else
        {
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
		}
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
	}
}

//==============================================================================
rule tradeWithCaravans
minInterval 31 //starts in cAge3
inactive
{
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
		    //if ((aiRandInt(3) <= 1) && (cRandomMapName != "watering hole"))  //TEMP
			//chosenCorner = secondClosestToMe;
			//else
			//chosenCorner = closestToMe;
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
                                    continue;
								}
							}
                            else if (areaType == cAreaTypeSettlement)
                            {
                                continue;
							}
                            else if (areaType == cAreaTypeImpassableLand)
                            {
                                continue;
							}
                            int numBuildingsInR15 = getNumUnits(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cMyID, areaLocation, 15.0);
                            if (numBuildingsInR15 > 3)
                            {
                                continue;
							}
                            if (distance > savedDistance)
                            {
                                marketLocation = areaLocation;
                                savedDistance = distance;
                                continue;
							}
						}
					}
				}
			}
            else
            {
                marketLocation = mainBaseLocation;
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
        gTradeMarketDesiredLocation = marketLocation; // Set the global var for later reference in identifying the trade market.
		
        static float distanceIncrease = 0;
		
		bool Skip = false;
		int MarketsThere = getNumUnits(cUnitTypeMarket, cUnitStateAny, -1, cMyID, gTradeMarketDesiredLocation, 60.0);
        int ExistingPlan = findPlanByString("BUILDMARKET", cPlanBuild);
		if ((ExistingPlan != -1) || (MarketsThere > 0) || (buildPlanID != -1))
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
minInterval 7 //starts in cAge3
inactive
{
    //check the trade plan
    if ((gTradeMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0))
    {
        if (gTradePlanID != -1)
        {
            aiPlanDestroy(gTradePlanID);
            gTradePlanID = -1;
		}
        
        int activeTradePlans = aiPlanGetNumber(cPlanTrade, -1, true);
        if (activeTradePlans > 0)
        {
            for (i = 0; < activeTradePlans)
            {
                int tradePlanIndexID = aiPlanGetIDByIndex(cPlanTrade, -1, true, i);
                if (tradePlanIndexID != -1)
                {
                    aiPlanDestroy(tradePlanIndexID);
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
            return;
		}
	}
    tradeMarketPosition = kbUnitGetPosition(marketToUse);
    
    if (lastUsedMarket == -1)
    {
		lastUsedMarket = marketToUse;
	}
    
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
	}
	
    if (override == true)
    {
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
            lastUsedMarket = marketToUse;
		}
        else
        {
            count = count + 1;
		}
	}
    
    int action = cActionIdle;
    int numTradeUnitsToUse = getNumUnits(tradeCartPUID, cUnitStateAlive, action, cMyID);
    if ((numTradeUnitsToUse < 1) || (aiRandInt(5) == 0) || (override == true))
    {
        action = -1;
        numTradeUnitsToUse = getNumUnits(tradeCartPUID, cUnitStateAlive, action, cMyID);
        if (numTradeUnitsToUse < 1)
        {
            return;
		}
	}
	
    float minRequiredDistance = 40.0;
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
	vector AllyBaseUnitPosition = cInvalidVector;
    int tradeUnitID = -1;
    int planID = -1;
    int targetID = -1;
    vector targetPosition = cInvalidVector;
    
    float tradeRouteLength = 0.0;
	float AllyRouteLength = 0.0;
    float currentTradeRouteLength = 0.0;
    int alliedTradeDestinationID = -1;
    int numAlliedSettlementsInR100 = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, tradeMarketPosition, 240);
    if (numAlliedSettlementsInR100 > 0)
    {
        if (numAlliedSettlementsInR100 > 3)
		numAlliedSettlementsInR100 = 3;
        for (i = 0; < numAlliedSettlementsInR100)
        {
            int alliedSettlementIDInR100 = findUnitByRelByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive, -1, cPlayerRelationAlly, tradeMarketPosition, 240);
            if (alliedSettlementIDInR100 != -1)
            {
                vector alliedSettlementLocation = kbUnitGetPosition(alliedSettlementIDInR100);
                float alliedTradeRouteLength = xsVectorLength(alliedSettlementLocation - tradeMarketPosition);
			    if ((alliedTradeRouteLength > minRequiredDistance) && (SameAG(alliedSettlementLocation, tradeMarketPosition) == true))
				alliedTradeDestinationID = alliedSettlementIDInR100;
			}
		}
	}
	
	if (alliedTradeDestinationID != -1)
	{
	    AllyBaseUnitPosition = kbUnitGetPosition(alliedTradeDestinationID);
		AllyRouteLength = xsVectorLength(AllyBaseUnitPosition - tradeMarketPosition)*2; // gets a bonus
	}
	
	if (numTradeUnitsToUse > max)
	numTradeUnitsToUse = max;
	for (i = 0; < numTradeUnitsToUse)
	{
		otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
		otherBaseUnitPosition = kbUnitGetPosition(otherBaseUnitID);
		
		tradeRouteLength = xsVectorLength(otherBaseUnitPosition - tradeMarketPosition);
		tradeUnitID = findUnitByIndex(tradeCartPUID, i, cUnitStateAlive, action, cMyID);
		if (tradeUnitID > 0)
		{
			if (override == true)
			{
				if (RetreatMB == true)
				aiTaskUnitMove(tradeUnitID, mainBaseLocation);
				else 
				aiTaskUnitWork(tradeUnitID, marketToUse);
				continue;
			}
			
			if (action == -1)   //check the currentTradeRouteLength of all tradeUnits
			{
				planID = kbUnitGetPlanID(tradeUnitID);
				if (planID != -1)
				continue;
				targetID = kbUnitGetTargetUnitID(tradeUnitID);
				int Owner = kbUnitGetOwner(targetID);
				bool cTargetIsAlly = false;
				if ((Owner > 0) && (kbIsPlayerAlly(Owner) == true) && (Owner != cMyID))
				cTargetIsAlly = true;
				if (targetID != -1)
				{
					targetPosition = kbUnitGetPosition(targetID);
					if (cTargetIsAlly == true)
					currentTradeRouteLength = xsVectorLength(targetPosition - tradeMarketPosition)*2;
				    else
					currentTradeRouteLength = xsVectorLength(targetPosition - tradeMarketPosition);
					if (currentTradeRouteLength > minRequiredDistance)
					{
						//Always use Ally Route if available, update to a better tc if needed.
						if ((alliedTradeDestinationID != -1) && (AllyRouteLength > currentTradeRouteLength) && (AllyRouteLength <= 480))
						{
					        
							tradeDestinationID = alliedTradeDestinationID;
						//aiEcho("Found better route! Ally Old dist: "+currentTradeRouteLength/2+",  New dist: "+AllyRouteLength/2+". at TC ID: "+tradeDestinationID+"");
						    aiTaskUnitWork(tradeUnitID, tradeDestinationID);
							continue;
						}
					
						if ((tradeRouteLength > currentTradeRouteLength) && (tradeRouteLength <= 240.0) && (cTargetIsAlly == false))
						{
							tradeDestinationID = otherBaseUnitID;				
							//aiEcho("Found better route! Old dist: "+currentTradeRouteLength+",  New dist: "+tradeRouteLength+". at TC ID: "+tradeDestinationID+"");
						    aiTaskUnitWork(tradeUnitID, tradeDestinationID);
						}
					}	
				}
			continue;
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
			//Always use the alliedTradeDestinationID, 50% bonus is too hard to pass up on.
			if (alliedTradeDestinationID != -1)
			{
				tradeDestinationID = alliedTradeDestinationID;
				tradeRouteLength = AllyRouteLength/2; 
				
			}
			
			if ((tradeDestinationID != -1) && (SameAG(kbUnitGetPosition(tradeDestinationID), tradeMarketPosition) == true))
			{	
				aiTaskUnitWork(tradeUnitID, tradeDestinationID);
				//aiEcho("Sending trade unit: "+tradeUnitID+" to tradeDestinationID: "+tradeDestinationID+" Distance : "+tradeRouteLength);
			}
		}
	}
}

//==============================================================================
rule airScout1
minInterval 83 //starts in cAge1
inactive
{
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