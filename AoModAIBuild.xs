//AoModAIBuild.xs
//This file contains all build rules
//by Loki_GdD


//==============================================================================
rule norseInfantryBuild
minInterval 6 //starts in cAge2
inactive
{
    int planIDToAddUnit=aiPlanGetIDByTypeAndVariableType(cPlanBuild, -1, -1);
    if ((planIDToAddUnit < 0) || (aiPlanGetVariableInt(planIDToAddUnit, cBuildPlanBuildingTypeID, 0) == cUnitTypeFarm))
	return;
    
    //keep at least one unit in the plan
	int InfFound = getNumUnits(cUnitTypeAbstractInfantry, cUnitStateAlive, cActionIdle, cMyID);
    if (InfFound < 1)
	InfFound = 1;
    
    //don't put in too many infantry units
    if (InfFound > 5)
	InfFound = 5;
    aiPlanAddUnitType(planIDToAddUnit, cUnitTypeAbstractInfantry, InfFound, InfFound, InfFound);
    
	int HeroFound = getNumUnits(cUnitTypeHero, cUnitStateAlive, cActionIdle, cMyID);
	if (HeroFound < 1)
	return; 

    if (HeroFound > 3)
	HeroFound = 3;
    aiPlanAddUnitType(planIDToAddUnit, cUnitTypeHero, HeroFound, HeroFound, HeroFound);
}

//==============================================================================
rule repairTitanGate
minInterval 10 //starts in cAge5
inactive
{
    int buildingID = findUnit(cUnitTypeTitanGate, cUnitStateBuilding);
	int MinWanted = 8;
	if (cMyCulture == cCultureAtlantean)
	MinWanted = MinWanted / 2;
	
    if (buildingID >= 0)
    {
        //Don't create another plan for the same building.
        if (aiPlanGetIDByTypeAndVariableType(cPlanRepair, cRepairPlanTargetID, buildingID, true) >= 0)
        {
            xsDisableSelf();
            return;
		}
		
        //Create the plan.
        int planID=aiPlanCreate("BuildTitanGate", cPlanRepair);
        if (planID < 0)
        return;
		
        aiPlanSetDesiredPriority(planID, 100);
        aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
        aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingID);
        aiPlanSetInitialPosition(planID, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
		aiPlanAddUnitType(planID, cBuilderType, MinWanted, MinWanted*2, MinWanted*3);
        aiPlanSetVariableBool(planID, cRepairPlanIsTitanGate, 0, true);
		aiPlanSetRequiresAllNeedUnits(planID, true);
        aiPlanSetActive(planID);
		//new test
        xsEnableRule("tacticalTitan");
		
		//new test end
        xsDisableSelf();
	}
}

//==============================================================================
rule repairBuildings
minInterval 487 //starts in cAge1, is set to 9 after 8 minutes
inactive
{
    xsSetRuleMinIntervalSelf(9);
	
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
    if (otherBaseUnitID < 0)
	return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
	}
    
    int buildingThatShoots1ID = -1;
    int buildingThatShoots2ID = -1;
    
    int activeRepairPlans = aiPlanGetNumber(cPlanRepair, -1, true);
    if (activeRepairPlans > 0)
    {
        for (i = 0; < activeRepairPlans)
        {
            int repairPlanIndexID = aiPlanGetIDByIndex(cPlanRepair, -1, true, i);
            int targetID = aiPlanGetVariableInt(repairPlanIndexID, cRepairPlanTargetID, 0);
			vector TarLoc = kbUnitGetPosition(targetID);
     		int Owner = kbUnitGetOwner(targetID);
			if (Owner != cMyID)
			{
			    int numUnitsInPlan = aiPlanGetNumberUnits(repairPlanIndexID, cUnitTypeUnit);
				for (a = 0; < numUnitsInPlan)
				{
			        int Worker = aiPlanGetUnitByIndex(repairPlanIndexID, a);
			        vector WorkerLoc = kbUnitGetPosition(Worker);
			        float Dist = xsVectorLength(TarLoc - WorkerLoc);				
		            if ((kbIsPlayerAlly(Owner) == true) && (kbHasPlayerLost(Owner) == false) && (Worker != -1 ) && (Dist < 35))
		            aiTaskUnitWork(Worker, targetID);
				}
			}
			
            if ((aiPlanGetVariableBool(repairPlanIndexID, cRepairPlanIsTitanGate, 0) == true) && (kbUnitIsType(targetID, cUnitTypeLogicalTypeBuildingNotTitanGate) == true))
            {
                vector targetLocation = kbUnitGetPosition(targetID);
                int myMilUnitsInR25 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, targetLocation, 25.0);
                int numAttEnemyMilUnitsInR25 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, targetLocation, 25.0, true);
                int numEnemyMilBuildingsInR25 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, targetLocation, 25.0);	
                if ((kbUnitGetCurrentHitpoints(targetID) <= 0) || (kbUnitGetHealth(targetID) > 0.99) || (numEnemyMilBuildingsInR25 > 0) || (numAttEnemyMilUnitsInR25 > myMilUnitsInR25 + 4) || (goldSupply < 80))
                {
                    aiPlanDestroy(repairPlanIndexID);
                    continue;
				}		
			}
		
            if ((kbUnitIsType(targetID, cUnitTypeBuildingsThatShoot) == true) && (aiPlanGetBaseID(repairPlanIndexID) == otherBaseID))
            {
                if (buildingThatShoots1ID == -1)
                {
                    buildingThatShoots1ID = targetID;
                    continue;
				}
                else if (buildingThatShoots2ID == -1)
                {
                    buildingThatShoots2ID = targetID;
                    continue;
				}
			}
		}
	}
    
    int numBuilders = kbUnitCount(cMyID, cBuilderType, cUnitStateAlive);
    int requiredBuilders = 12;
    if (cMyCulture == cCultureAtlantean)
	requiredBuilders = 4;
    
    if ((goldSupply < 110) || (woodSupply < 80) || (foodSupply < 80) || (numBuilders < requiredBuilders))
	return;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	
    int buildingID = -1;
    vector otherBaseLocation = kbBaseGetLocation(cMyID, otherBaseID);
    float radius = 30.0;
    if (otherBaseID == mainBaseID)
    {
        if ((xsGetTime() > 20*60*1000) || (kbGetAge() > cAge2))
		radius = 85.0;
        else
		radius = 60.0;
	}
    
    int numBuildingsThatShoot = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, otherBaseLocation, radius);
    for (i = 0; < numBuildingsThatShoot)
    {
        buildingID = findUnitByIndex(cUnitTypeBuildingsThatShoot, i, cUnitStateAlive, -1, cMyID, otherBaseLocation, radius);
        if (buildingID == -1)
		continue;
        if (kbUnitGetHealth(buildingID) < 0.8)
        {
            if ((buildingThatShoots1ID == buildingID) || (buildingThatShoots2ID == buildingID))
            {
                buildingID = -1;
                continue;
			}
            break;
		}
        else
		buildingID = -1;
	}
    
    if (buildingID < 0)
	buildingID = kbFindBestBuildingToRepair(otherBaseLocation, radius, 0.85, cUnitTypeMilitaryBuilding);

	if ((buildingID < 0) && (IhaveAllies == true))
	{
		if ((goldSupply < 400) || (woodSupply < 400) || (foodSupply < 400) || (IhaveAllies == false))
		return;
		int AllyBases = getNumUnits(cUnitTypeSettlementsThatTrainVillagers, cUnitStateAlive, -1, cPlayerRelationAlly);
		for (j = 0; < AllyBases)
		{
			bool Success = false;
			int CurrentAllyTC = findUnitByRelByIndex(cUnitTypeSettlementsThatTrainVillagers, j, cUnitStateAlive, -1, cPlayerRelationAlly);
			vector Pos = kbUnitGetPosition(CurrentAllyTC);
			if (SameAG(Pos, mainBaseLocation) == false)
			continue;
			int AllyBuildings = getNumUnits(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationAlly, Pos, radius);
			for (k = 0; < AllyBuildings)
			{
				int AllyRepairBuilding = findUnitByRelByIndex(cUnitTypeLogicalTypeBuildingsNotWalls, k, cUnitStateAlive, -1, cPlayerRelationAlly, Pos, radius);
				if ((kbUnitGetHealth(AllyRepairBuilding) < 0.8) && (kbUnitIsType(AllyRepairBuilding, cUnitTypeWonder) == false))
				{
					buildingID = AllyRepairBuilding;
					Success = true;
					break;
				}
			}
			if (Success == true)
			break;
		}
	}
	
    
    if (buildingID >= 0)
    {
        //Don't create another plan for the same building.
        int repairPlanID = aiPlanGetIDByTypeAndVariableType(cPlanRepair, cRepairPlanTargetID, buildingID, true);		
        if (repairPlanID >= 0)
        {
            return;
		}
        
		
        //Create the plan.
        static int num = 0;
        num = num + 1;
        string planName = "Repair_"+num;
        int planID = aiPlanCreate(planName, cPlanRepair);
        if (planID < 0)
		return;
		
        aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingID);
        aiPlanSetInitialPosition(planID, otherBaseLocation);
        
        if (kbUnitIsType(buildingID, cUnitTypeBuildingsThatShoot) == true)
		aiPlanSetVariableBool(planID, cRepairPlanIsTitanGate, 0, true);   //makes sure that the plan doesn't get destroyed
        
        if ((cMyCulture == cCultureAtlantean) || (numBuilders < 30))
		aiPlanAddUnitType(planID, cBuilderType, 1, 1, 1);
        else
        {
            if ((kbUnitIsType(buildingID, cUnitTypeAbstractFortress) == true) || (kbUnitIsType(buildingID, cUnitTypeAbstractSettlement) == true))
            {
                aiPlanAddUnitType(planID, cBuilderType, 1, 2, 3);
			}
            else
			aiPlanAddUnitType(planID, cBuilderType, 1, 1, 1);
		}
		
        aiPlanSetDesiredPriority(planID, 100);
        aiPlanSetBaseID(planID, otherBaseID);
        aiPlanSetActive(planID);
	}
}

//==============================================================================
rule buildMonuments
minInterval 42 //starts in cAge2, cAge3, cAge4
inactive
{
    int targetNum = -1;
    float scratch = 0.0;
    scratch = (-1.0 * cvRushBoomSlider) + 1.0;  //  0 for extreme rush, 2 for extreme boom
    scratch = (scratch * 1.5) + 0.5;      // 0.5 to 3.5
    targetNum = kbGetAge() + scratch;              // 0 for extreme rush, 3 for extreme boom, +1 in cAge2, 2 in cAge3, +3 in cAge4
    if (kbGetAge() >= cAge4)
	targetNum = 5;
    if (targetNum > 5)
	targetNum = 5;
	for (i=0;<targetNum)
	{
		int unitTypeID=-1;
		if (i==0)
		unitTypeID=cUnitTypeMonument;
		else if (i==1)
		unitTypeID=cUnitTypeMonument2;
		else if (i==2)
		unitTypeID=cUnitTypeMonument3;
		else if (i==3)
		unitTypeID=cUnitTypeMonument4;
		else if (i==4)
		unitTypeID=cUnitTypeMonument5;
		
		if ((kbUnitCount(cMyID, unitTypeID, cUnitStateAliveOrBuilding) > 0) || (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, unitTypeID, true) >= 0))
		continue;
		
		int monumentPlanID=aiPlanCreate("BuildMonument"+i, cPlanBuild);
		if (monumentPlanID >= 0)
		{
	        vector loc=calcMonumentPos(i);
			aiPlanSetVariableInt(monumentPlanID, cBuildPlanBuildingTypeID, 0, unitTypeID);
			aiPlanSetVariableVector(monumentPlanID, cBuildPlanInfluencePosition, 0, loc);
			aiPlanSetVariableFloat(monumentPlanID, cBuildPlanInfluencePositionDistance, 0, 20.0);
			aiPlanSetVariableFloat(monumentPlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
			aiPlanSetVariableInt(monumentPlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(loc));
			aiPlanSetVariableInt(monumentPlanID, cBuildPlanNumAreaBorderLayers, 0, 2);
			
			aiPlanSetDesiredPriority(monumentPlanID, 35);
			aiPlanAddUnitType(monumentPlanID, cBuilderType, 1, 1, 1);
			aiPlanSetEscrowID(monumentPlanID, cEconomyEscrowID);
			aiPlanSetBaseID(monumentPlanID, kbBaseGetMainID(cMyID));
			aiPlanSetActive(monumentPlanID);
		}
	}
}

//==============================================================================
rule buildHouse
minInterval 11 //starts in cAge1
inactive
{
    static int unitQueryID=-1;
	
    int houseProtoID = cUnitTypeHouse;
    if (cMyCulture == cCultureAtlantean)
	houseProtoID = cUnitTypeManor;
	bool skip = false;
	if ((cMyCulture == cCultureNorse) && (kbUnitCount(cMyID, cUnitTypeLogicalTypeHouses, cUnitStateAliveOrBuilding) < 1) && (kbGetAge() == cAge1))
	skip = true;

    //Don't build another house if we've got at least gHouseAvailablePopRebuild open pop slots.
    if ((kbGetPop()+gHouseAvailablePopRebuild < kbGetPopCap()) && (skip == false))
	return;
	
	
    //If we already have gHouseBuildLimit houses, we shouldn't build anymore.
    if (gHouseBuildLimit != -1)
    {
        int numHouses = kbUnitCount(cMyID, houseProtoID, cUnitStateAliveOrBuilding);
        if (numHouses >= gHouseBuildLimit)
		return;
	}
	
    //If we already have a house plan active, skip unless the house takes too long to build.
    static int count = 0;
    int housePlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, houseProtoID);
    if (housePlanID > -1)
    {
        int houseID = findUnit(houseProtoID, cUnitStateBuilding, -1, cMyID);
        if ((houseID != -1) || (aiPlanGetState(housePlanID) == cPlanStateNone))
        {
            if ((kbUnitGetHealth(houseID) < 1.0) || (aiPlanGetState(housePlanID) == cPlanStateNone))
            {
                if (count > 5)
                {
                    aiPlanDestroy(housePlanID);
                    aiTaskUnitDelete(houseID);
                    count = 0; 
				}
                else
                {
                    count = count + 1;
                    return;
				}
			}
		}
        else
        {
            count = 0;
            return;
		}
	}
    else
    {
        count = 0;
	}
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
    if (otherBaseUnitID < 0)
	return;
    else
    {
        int otherBaseID=kbUnitGetBaseID(otherBaseUnitID);
	}
    
	if (cvMapSubType == VINLANDSAGAMAP)
	{
		if (aiRandInt(4) > 1)
		otherBaseID=mainBaseID;
		else otherBaseID=kbUnitGetBaseID(otherBaseUnitID);
	}
	
    vector location = cInvalidVector;
    int planID = aiPlanCreate("BuildHouse", cPlanBuild);
    if (planID >= 0)
    {
        aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, houseProtoID);
		aiPlanAddUnitType(planID, cBuilderType, 1, 1, 1);
		// Added a little override as this rule didn't seem to work properly. // Reth.
		
		if ((findNumUnitsInBase(cMyID, kbBaseGetMain(cMyID), cUnitTypeTower) > 0)
		&& (mapPreventsHousesAtTowers() == false)
		&& (otherBaseID == mainBaseID))
		
        {
            //If we don't have the query yet, create one.
            if (unitQueryID < 0)
			unitQueryID = kbUnitQueryCreate("Tower Query");
			
            //Define a query to get all matching units
            if (unitQueryID != -1)
            {
                kbUnitQuerySetPlayerID(unitQueryID, cMyID);
                kbUnitQuerySetUnitType(unitQueryID, cUnitTypeTower);
                kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
			}
			
            kbUnitQueryResetResults(unitQueryID);
            int numTowers = kbUnitQueryExecute(unitQueryID);
			
            vector towerLoc1 = cInvalidVector;
            vector towerLoc2 = cInvalidVector;
            vector towerLoc3 = cInvalidVector;
            vector towerLoc4 = cInvalidVector;
            if (numTowers >= 1)
			towerLoc1 = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, 0));
            if (numTowers >= 2)
			towerLoc2 = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, 1));
            if (numTowers >= 3)
			towerLoc3 = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, 2));
            if (numTowers >= 4)
			towerLoc4 = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, 3));
			
            aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 0.0);
			
            if ((numHouses < 4) && (equal(towerLoc1, cInvalidVector) == false))
			aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, towerLoc1);
            else if ((numHouses < 8) && (equal(towerLoc2, cInvalidVector) == false))
			aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, towerLoc2);
            else if ((numHouses < 12) && (equal(towerLoc3, cInvalidVector) == false))
			aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, towerLoc3);
            else if (equal(towerLoc4, cInvalidVector) == false)
			aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, towerLoc4);
			
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 8.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 10000.0);
		}
        else
        {
            aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
            aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);	
            aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeBuilding); 
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitDistance, 0, 9);    
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitValue, 0, -5.0);   
            vector baseLocation = kbBaseGetLocation(cMyID, otherBaseID);
            aiPlanSetInitialPosition(planID, baseLocation);
            
            vector backVector = kbBaseGetBackVector(cMyID, otherBaseID);
			
            float bx = xsVectorGetX(backVector);
            float bz = xsVectorGetZ(backVector);
            float bxOrig = bx;
            float bzOrig = bz;
			
            bx = bxOrig * 25.0;
            bz = bzOrig * 25.0;
			if (otherBaseID != mainBaseID)
			{
                bx = bx / 2.2;
                bz = bz / 2.2;
			}
			
            backVector = xsVectorSetX(backVector, bx);
            backVector = xsVectorSetZ(backVector, bz);
            backVector = xsVectorSetY(backVector, 0.0);
			
            vector backLocation = baseLocation + backVector;
            
            if (otherBaseID != mainBaseID)
            {
                location = backLocation;
			}
            else
            {
                if (aiRandInt(2) < 1)
                {
                    //left
                    bx = bzOrig * (-10);
                    bz = bxOrig * 10;
				}
                else
                {
                    //right
                    bx = bzOrig * 10;
                    bz = bxOrig * (-10);
				}
                backVector = xsVectorSetX(backVector, bx);
                backVector = xsVectorSetZ(backVector, bz);
                backVector = xsVectorSetY(backVector, 0.0);
                location = backLocation + backVector;
			}
            
            aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 15.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 100.0);
		}
        
        aiPlanSetBaseID(planID, otherBaseID);
        aiPlanSetEscrowID(planID, cEconomyEscrowID);
        aiPlanSetDesiredPriority(planID, 100);			
        aiPlanSetActive(planID);
	}
}

//==============================================================================
rule buildSettlements
minInterval 5 //starts in cAge3
inactive
{
    //Figure out if we have any active BuildSettlements.
    int numberBuildSettlementGoals=aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true);
    int numberSettlements = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID);
	int MaxInProgress = 3;
	if (aiGetGameMode() == cGameModeDeathmatch)
    MaxInProgress = 4;
	
    int numberSettlementsPlanned = numberSettlements + numberBuildSettlementGoals;
	
    if (numberBuildSettlementGoals >= MaxInProgress)	// Allow 3 in progress, no more
	return;
    if (kbUnitCount(0, cUnitTypeSettlement, cUnitStateAny) < 1)
	return;
	
	//If we're on Easy and we have 3 settlements, go away.
	if ((aiGetWorldDifficulty() == cDifficultyEasy) && (numberSettlementsPlanned >= 3))
	{
		xsDisableSelf();
		return;
	}
    
	if ((kbGetAge() == cAge1) || (kbGetAge() == cAge2) && (AgingUp() == false))
    { 
		if (numberSettlementsPlanned >= gEarlySettlementTarget)
        return;     // We have or are building all we want
	}		
    
	
    int numBuilders = 3;
    if (cMyCulture == cCultureAtlantean)
	numBuilders = 1;
    if ((kbGetAge() > cAge2) && (aiGetGameMode() != cGameModeLightning))
    {
        numBuilders = 3+aiRandInt(4);
        if (cMyCulture == cCultureAtlantean)
	    numBuilders = 1+aiRandInt(2);
    }
    //Else, do it.
    createBuildSettlementGoal("BuildSettlement", kbGetAge(), -1, kbBaseGetMainID(cMyID), numBuilders, cBuilderType, true, 100);
}

//==============================================================================
rule dockMonitor
inactive
minInterval 87 //starts in cAge1
{
    xsSetRuleMinIntervalSelf(87);
    if ((gWaterMap == false) || (cRandomMapName == "Old Atlantis"))
    {
        xsDisableSelf();
        return;
	}
	static bool DockRemoval = false;
	
	if (DockRemoval == false)
    {
        if (gTransportMap == true)
        xsEnableRule("RemoveTooCloseDocks");
        DockRemoval = true;
	}		
	
    if (( kbGetAge() < cAge3) && (xsGetTime() < 8*60*1000) && (aiGetGameMode() != cGameModeDeathmatch))
	return;
	
    int numDocks = kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding);
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);

	
    int desiredDocks = 3;
	if ((gNavalUPID == -1) && (gFishPlanID != -1) || (kbGetAge() == cAge2))
	desiredDocks = 1;

    if (((numDocks >= kbGetAge()+1) && (numDocks >= numSettlements))
	|| (findPlanByString("BuildDock", cPlanBuild) != -1) || (numDocks >= 3) || (gTransportMap == false) && (numDocks >= desiredDocks))
    {
        return;
	}
	
    vector mainBaseLocation = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    vector dockPos = kbAreaGetCenter(kbAreaGetClosetArea(mainBaseLocation, cAreaTypeWater));
	if (gFishPlanID != -1)
	{
        vector WaterVector = aiPlanGetVariableVector(gFishPlanID, cFishPlanWaterPoint, 0);
		int FishArea = kbAreaGetIDByPosition(WaterVector);
	    if (kbAreaGetType(FishArea) == cAreaTypeWater)
		dockPos = WaterVector;
	}

    int buildDock = aiPlanCreate("BuildDock", cPlanBuild);
    if (buildDock >= 0)
    {
        //BP Type and Priority.
        aiPlanSetVariableInt(buildDock, cBuildPlanBuildingTypeID, 0, cUnitTypeDock);
        aiPlanSetDesiredPriority(buildDock, 100);
        aiPlanSetNumberVariableValues(buildDock, cBuildPlanDockPlacementPoint, 2);		
        aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 0, mainBaseLocation);
        aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 1, dockPos);
        aiPlanAddUnitType(buildDock, cBuilderType, 1, 1, 1);
        aiPlanSetEscrowID(buildDock, cEconomyEscrowID);
        aiPlanSetBaseID(buildDock, kbBaseGetMainID(cMyID));	   	
        aiPlanSetActive(buildDock);
	}
}

//==============================================================================
rule makeWonder
minInterval 61 //starts in cAge4
inactive       //  Activated on reaching age 4 if game isn't conquest
{
    if ((aiGetGameMode() == cGameModeLightning) && (xsGetTime() < 25*60*1000))
	return;
    int targetArea = -1;
    vector target = cInvalidVector;     // Will be used to center the building placement behind the town.
    target = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    vector offset = cInvalidVector;
    offset = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
    offset = offset * 30.0;
    target = target + offset;
    targetArea = kbAreaGetIDByPosition(target);
	
	int planID=aiPlanCreate("Wonder Build", cPlanBuild);
    if (planID < 0)
	return;
	
    aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeWonder);
    aiPlanSetVariableInt(planID, cBuildPlanAreaID, 0, targetArea);
    aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 0, 2);
	
    aiPlanSetDesiredPriority(planID, 100);
	
    //Mil vs. Econ.
    aiPlanSetMilitary(planID, false);
    aiPlanSetEconomy(planID, true);
	
    //Escrow.
    aiPlanSetEscrowID(planID, cEconomyEscrowID);

    int builderCount = 2 + kbUnitCount(cMyID, cBuilderType, cUnitStateAlive);
	if (builderCount > 18)
	builderCount = 18;
    else if (builderCount < 10)
	builderCount = 10;
    if (cMyCulture == cCultureAtlantean)
	builderCount = builderCount / 3;	
	
    //Builders.
    aiPlanAddUnitType(planID, cBuilderType, builderCount, builderCount, builderCount);   // Two thirds, all, or 150%...in case new builders are created.
	
    //Base ID.
    aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
	
    //Go.
    aiPlanSetActive(planID);
	
    xsEnableRule("watchForWonder");     // Looks for wonder placement, starts defensive reaction.
    xsDisableSelf();
}

//==============================================================================
int createCommonRingWallPlan(string WallPlanName = "BUG", int BaseID=-1, int radius=19, bool UnitID = false)
{
	if (UnitID == false)
    vector mainCenter = kbBaseGetLocation(cMyID, BaseID);
    else
	mainCenter = kbUnitGetPosition(BaseID);
    int Prio = 100;
	if ((cMyCulture == cCultureNorse) && (kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive)) < 2)
	Prio = 99;    
    int RingWallPlan = aiWallRingAroundPoint(""+WallPlanName, mainCenter, radius, 1, 1, 1, cEconomyEscrowID, 40, Prio);
    return(RingWallPlan);
}
//==============================================================================
rule mainBaseAreaWallTeam1
minInterval 5 //starts in cAge2
inactive
{
	int Temple = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
	if ((mRusher == true) && (kbGetAge() < cAge3) && (xsGetTime() < 15*60*1000) || (kbGetAge() < cAge2) && (Temple < 1 ) || (kbGetAge() < cAge2) && (cMyCulture == cCultureAtlantean)
	|| (cvMapSubType == NOMADMAP) && (kbGetAge() < cAge3) || (aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 8*60*1000))
    return;	
	
	if (kbGetAge() > cAge1)
	xsSetRuleMinIntervalSelf(23);
	
    static bool alreadyStarted = false;
	int MinVil = 10;
	if (cMyCulture == cCultureAtlantean)
	MinVil = 3;
	if (cMyCulture == cCultureNorse)
	MinVil = 0;	//fake it	
	int myVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	
	
    float goldSupply = kbResourceGet(cResourceGold);
	
    //If we already have a build wall plan, don't make another one.
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);
	
    int mainBaseID=kbBaseGetMainID(cMyID);
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	if (mainBaseID == gVinlandsagaInitialBaseID)
	return;
	
    if (activeWallPlans > 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gMainBaseAreaWallTeam1PlanID)
            {
                static int mainBaseAreaWallTeam1StartTime = -1;
                if (mainBaseAreaWallTeam1StartTime < 0)
				mainBaseAreaWallTeam1StartTime = xsGetTime();
                
                if ((goldSupply < 50) && (xsGetTime() > 19*60*1000) || (myVillagers < MinVil))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    mainBaseAreaWallTeam1StartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
				}
                
                //destroy the plan if it has been active for more than 12 minutes
                if (xsGetTime() > (mainBaseAreaWallTeam1StartTime + 12*60*1000))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    mainBaseAreaWallTeam1StartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
				}
				
                //Get the enemies near my base
                int numEnemyUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, gMainBaseAreaWallRadius);
				int myUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationSelf, mainBaseLocation, gMainBaseAreaWallRadius);  
                int alliedUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationAlly, mainBaseLocation, gMainBaseAreaWallRadius); 
                
				
                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
                if ((secondsUnderAttack > 25) && (xsGetTime() > 19*60*1000))
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        mainBaseAreaWallTeam1StartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
					}
				}
				
                return;
			}
		}
	}
    
    if ((alreadyStarted == false) && (kbGetAge() < cAge2))
    {
        if ((goldSupply < 50) && (kbGetAge() < cAge2) || (cMyCulture == cCultureAtlantean))
		return;
	}
    else
    {
        if ((goldSupply < 150) || (alreadyStarted == false) && (kbUnitCount(cMyID, cUnitTypeAge2Building, cUnitStateAliveOrBuilding) < 2) && (cMyCulture == cCultureAtlantean))
		return;
	}
	if (myVillagers < MinVil)
	return;
        
    static bool firstRun = true;

    if (firstRun == true)
	{
		if (cMyCulture != cCultureAtlantean)
        xsEnableRule("mainBaseAreaWallTeam2");
        firstRun = false;
	}
	
    string Readable = "mainBaseAreaWallTeam1PlanID";
	gMainBaseAreaWallTeam1PlanID = createCommonRingWallPlan(Readable, mainBaseID, gMainBaseAreaWallRadius);
    xsSetRuleMinIntervalSelf(127);
    if (alreadyStarted == false)
    alreadyStarted = true;
}
//==============================================================================
rule mainBaseAreaWallTeam2
minInterval 5 //starts in cAge2,  activated in mainBaseAreaWallTeam1 rule
inactive
{
	if ((mRusher == true) && (kbGetAge() < cAge3) && (xsGetTime() < 15*60*1000) || (kbGetAge() < cAge2))
	return;
    
	if (kbGetAge() > cAge1)
	xsSetRuleMinIntervalSelf(23);
	int MinVil = 10;
	if (cMyCulture == cCultureAtlantean)
	MinVil = 3;
	if (cMyCulture == cCultureNorse)
	MinVil = 0;	//fake it
	int myVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);		
	
    float goldSupply = kbResourceGet(cResourceGold);
	
    //If we already have a build wall plan, don't make another one.
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);
	
    int mainBaseID=kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	
    if (activeWallPlans > 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gMainBaseAreaWallTeam2PlanID)
            {
                static int mainBaseAreaWallTeam2StartTime = -1;
                if (mainBaseAreaWallTeam2StartTime < 0)
				mainBaseAreaWallTeam2StartTime = xsGetTime();
                
                if (goldSupply < 100)
                {
                    aiPlanDestroy(wallPlanIndexID);
                    mainBaseAreaWallTeam2StartTime = -1;
                    xsSetRuleMinIntervalSelf(29);
                    return;
				}
                
                //destroy the plan if it has been active for more than 12 minutes
                if (xsGetTime() > (mainBaseAreaWallTeam2StartTime + 12*60*1000)	|| (myVillagers < MinVil))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    mainBaseAreaWallTeam2StartTime = -1;
                    xsSetRuleMinIntervalSelf(67);
                    return;
				}
				
                //Get the enemies near my base
                int numEnemyUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, gMainBaseAreaWallRadius);
				int myUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationSelf, mainBaseLocation, gMainBaseAreaWallRadius);  
                int alliedUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationAlly, mainBaseLocation, gMainBaseAreaWallRadius); 
				
                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
                if (secondsUnderAttack > 25)
                {
                    //Destroy the plan if there are twice as many enemies as my units
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        mainBaseAreaWallTeam2StartTime = -1;
                        xsSetRuleMinIntervalSelf(67);
                        return;
					}
				}
				
                return;
			}
		}
	}
	
    if ((goldSupply < 150) || (myVillagers < MinVil))
	return;

    string Readable = "mainBaseAreaWallTeam2PlanID";
	gMainBaseAreaWallTeam2PlanID = createCommonRingWallPlan(Readable, mainBaseID, gMainBaseAreaWallRadius);
    xsSetRuleMinIntervalSelf(131);	
}
//==============================================================================
rule otherBaseRingWallTeam1 // this covers Gold on other bases
minInterval 19 //starts in cAge2
inactive
{
	if ((mRusher == true) && (kbGetAge() < cAge3))
	return;
	
    float goldSupply = kbResourceGet(cResourceGold);
    
    int mainBaseID=kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
    if (otherBaseUnitID < 0)
	return;
    else
    {
        int otherBaseID=kbUnitGetBaseID(otherBaseUnitID);
        if (otherBaseID == mainBaseID)
        {
            return;
		}
	}
	
	int MinVil = 12;
	if (cMyCulture == cCultureAtlantean)
	MinVil = 4;
	if (cMyCulture == cCultureNorse)
	MinVil = 0;	//fake it	
	int myVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);		
    //check if there are farms close to where we want to place our walls and delete them
    vector otherBaseLocation = kbBaseGetLocation(cMyID, otherBaseID);
	
    //If we already have a build wall plan, don't make another one.
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);
	
    if (activeWallPlans > 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBaseRingWallTeam1PlanID)
            {
                static int otherBaseRingWallTeam1StartTime = -1;
                if (otherBaseRingWallTeam1StartTime < 0)
				otherBaseRingWallTeam1StartTime = xsGetTime();
                
                if ((goldSupply < 120) || (myVillagers < MinVil))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBaseRingWallTeam1StartTime = -1;
                    xsSetRuleMinIntervalSelf(19);
                    return;
					}
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBaseRingWallTeam1StartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBaseRingWallTeam1StartTime = -1;
                    xsSetRuleMinIntervalSelf(59);
                    return;
				}
				
                //Get the enemies near my base
			    int numEnemyUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, otherBaseLocation, 35);
				int myUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationSelf, otherBaseLocation, 35);  
                int alliedUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationAlly, otherBaseLocation, 35); 				
				
                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, otherBaseID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBaseRingWallTeam1StartTime = -1;
                        xsSetRuleMinIntervalSelf(59);
                        return;
					}
				}
                return;
			}
		}
	}
    
    if ((goldSupply < 300) || (myVillagers < MinVil))
	return;

    string Readable = "otherBaseWallTeam1PlanID";
	gOtherBaseRingWallTeam1PlanID = createCommonRingWallPlan(Readable, otherBaseID, gOtherBaseWallRadius);	
    xsSetRuleMinIntervalSelf(37);
}
//==============================================================================
rule otherBase1RingWallTeam
minInterval 11 //starts in cAge2, activated in otherBasesDefPlans rule
inactive
{
	if ((mRusher == true) && (kbGetAge() < cAge3))
	return;    
    float goldSupply = kbResourceGet(cResourceGold);
	
	int MinVil = 12;
	if (cMyCulture == cCultureAtlantean)
	MinVil = 4;
	if (cMyCulture == cCultureNorse)
	MinVil = 0;	//fake it	
	int myVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);			
    //If we already have a build wall plan, don't make another one.
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);
	
    if (activeWallPlans > 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBase1RingWallTeamPlanID)
            {
                static int otherBase1RingWallTeamStartTime = -1;
                if (otherBase1RingWallTeamStartTime < 0)
				otherBase1RingWallTeamStartTime = xsGetTime();
                
                if ((goldSupply < 120) || (myVillagers < MinVil))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase1RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
				}
                
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBase1RingWallTeamStartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase1RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
				}
                vector otherBaseLocation1 = kbBaseGetLocation(cMyID, gOtherBase1ID);
                //Get the enemies near my base
			    int numEnemyUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, otherBaseLocation1, 35);
				int myUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationSelf, otherBaseLocation1, 35);  
                int alliedUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationAlly, otherBaseLocation1, 35); 						
				
				
                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, gOtherBase1ID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBase1RingWallTeamStartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
					}
				}
				
                return;
			}
		}
	}
    
    if ((goldSupply < 300) || (myVillagers < MinVil))
	return;
	string Readable = "OtherBase1RingWallTeamPlan";
	gOtherBase1RingWallTeamPlanID = createCommonRingWallPlan(Readable, gOtherBase1ID, gOtherBaseWallRadius);
	xsSetRuleMinIntervalSelf(83);
}

//==============================================================================
rule otherBase2RingWallTeam
minInterval 11 //starts in cAge2, activated in otherBasesDefPlans rule
inactive
{
	if ((mRusher == true) && (kbGetAge() < cAge3))
	return;    
    float goldSupply = kbResourceGet(cResourceGold);

	int MinVil = 12;
	if (cMyCulture == cCultureAtlantean)
	MinVil = 4;
	if (cMyCulture == cCultureNorse)
	MinVil = 0;	//fake it	
	int myVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);			
	
    //If we already have a build wall plan, don't make another one.
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);
	
    if (activeWallPlans > 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBase2RingWallTeamPlanID)
            {
                static int otherBase2RingWallTeamStartTime = -1;
                if (otherBase2RingWallTeamStartTime < 0)
				otherBase2RingWallTeamStartTime = xsGetTime();
                
                if ((goldSupply < 120) || (myVillagers < MinVil))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase2RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
				}
                
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBase2RingWallTeamStartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase2RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
				}
				
                vector otherBaseLocation2 = kbBaseGetLocation(cMyID, gOtherBase2ID);
                //Get the enemies near my base
			    int numEnemyUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, otherBaseLocation2, 35);
				int myUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationSelf, otherBaseLocation2, 35);  
                int alliedUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationAlly, otherBaseLocation2, 35); 
				
                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, gOtherBase2ID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBase2RingWallTeamStartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
					}
				}
				
                return;
			}
		}
	}
    
    if ((goldSupply < 300) || (myVillagers < MinVil))
	return;
    string Readable = "OtherBase2RingWallTeamPlan";
    gOtherBase2RingWallTeamPlanID = createCommonRingWallPlan(Readable, gOtherBase2ID, gOtherBaseWallRadius);
	xsSetRuleMinIntervalSelf(83);
}

//==============================================================================
rule otherBase3RingWallTeam
minInterval 11 //starts in cAge2, activated in otherBasesDefPlans rule
inactive
{
	if ((mRusher == true) && (kbGetAge() < cAge3))
	return;    
    float goldSupply = kbResourceGet(cResourceGold);
	
	int MinVil = 12;
	if (cMyCulture == cCultureAtlantean)
	MinVil = 4;
	if (cMyCulture == cCultureNorse)
	MinVil = 0;	//fake it	
	int myVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);			
	
    //If we already have a build wall plan, don't make another one.
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);
	
    if (activeWallPlans > 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBase3RingWallTeamPlanID)
            {
                static int otherBase3RingWallTeamStartTime = -1;
                if (otherBase3RingWallTeamStartTime < 0)
				otherBase3RingWallTeamStartTime = xsGetTime();
                
                if ((goldSupply < 120) || (myVillagers < MinVil))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase3RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
				}
                
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBase3RingWallTeamStartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase3RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
				}
				
                vector otherBaseLocation3 = kbBaseGetLocation(cMyID, gOtherBase3ID);
                //Get the enemies near my base
			    int numEnemyUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, otherBaseLocation3, 35);
				int myUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationSelf, otherBaseLocation3, 35);  
                int alliedUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationAlly, otherBaseLocation3, 35); 
				
                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, gOtherBase3ID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBase3RingWallTeamStartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
					}
				}
				
                return;
			}
		}
	}
    
    if ((goldSupply < 300) || (myVillagers < MinVil))
	return;
	string Readable = "OtherBase3RingWallTeamPlan";
    gOtherBase3RingWallTeamPlanID = createCommonRingWallPlan(Readable, gOtherBase3ID, gOtherBaseWallRadius);
	xsSetRuleMinIntervalSelf(83);
}

//==============================================================================
rule otherBase4RingWallTeam
minInterval 11 //starts in cAge2, activated in otherBasesDefPlans rule
inactive
{
	if ((mRusher == true) && (kbGetAge() < cAge3))
	return;    
    float goldSupply = kbResourceGet(cResourceGold);
	
	int MinVil = 12;
	if (cMyCulture == cCultureAtlantean)
	MinVil = 4;
	if (cMyCulture == cCultureNorse)
	MinVil = 0;	//fake it	
	int myVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);		
	
    //If we already have a build wall plan, don't make another one.
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);
	
    if (activeWallPlans > 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBase4RingWallTeamPlanID)
            {
                static int otherBase4RingWallTeamStartTime = -1;
                if (otherBase4RingWallTeamStartTime < 0)
				otherBase4RingWallTeamStartTime = xsGetTime();
                
                if ((goldSupply < 120) || (myVillagers < MinVil))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase4RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
				}
                
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBase4RingWallTeamStartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase4RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
				}
				
                vector otherBaseLocation4 = kbBaseGetLocation(cMyID, gOtherBase4ID);
                //Get the enemies near my base
			    int numEnemyUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, otherBaseLocation4, 35);
				int myUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationSelf, otherBaseLocation4, 35);  
                int alliedUnitsNearBase = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cMyID, cPlayerRelationAlly, otherBaseLocation4, 35); 
				
                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, gOtherBase4ID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBase4RingWallTeamStartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
					}
				}
				
                return;
			}
		}
	}
	
    if ((goldSupply < 300) || (myVillagers < MinVil))
	return;    
	string Readable = "OtherBase4RingWallTeamPlan";
    gOtherBase4RingWallTeamPlanID = createCommonRingWallPlan(Readable, gOtherBase4ID, gOtherBaseWallRadius);
	xsSetRuleMinIntervalSelf(83);
}

//==============================================================================
rule buildSkyPassages
minInterval 180 //starts in cAge1
inactive
{
    
    // Make sure we have a sky passage at home, and one near the nearest TC of 
    // our Most Hated Player.
	
    if (kbBaseGetNumberUnits(cMyID, kbBaseGetMainID(cMyID), cPlayerRelationSelf, cUnitTypeSkyPassage) < 1)
    {  
        // We don't have one...make sure we have a plan in the works
		if (findPlanByString("BuildLocalSkyPassage", cPlanBuild) != -1)
		return;
	
        int planID=aiPlanCreate("BuildLocalSkyPassage", cPlanBuild);
        if (planID < 0)
		return;
        aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeSkyPassage);
        aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 0, kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))));
        aiPlanSetDesiredPriority(planID, 70);
        aiPlanSetMilitary(planID, true);
        aiPlanSetEconomy(planID, false);
        aiPlanSetEscrowID(planID, cMilitaryEscrowID);
        aiPlanAddUnitType(planID, cBuilderType, 1, 1, 1);
        aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
        aiPlanSetActive(planID);
		return;
	}
	if ((gTransportMap == true) || (kbResourceGet(cResourceGold) < 300) || (kbResourceGet(cResourceWood) < 400) || (findPlanByString("BuildRemoteSkyPassage", cPlanBuild) != -1))
	return;
	
	// Local base is covered, now let's check near our Most Hated Player's TC
	int MHPTC = getMainBaseUnitIDForPlayer(aiGetMostHatedPlayerID());
	vector enemyTCvec = kbUnitGetPosition(MHPTC);
	
	if (MHPTC > 0)
	{  // None found, we need one...and we don't have an active plan.
		// First, pick a center location on our side of the enemy TC
		vector offset = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)) - enemyTCvec;
		offset = xsVectorNormalize(offset);
		vector target = enemyTCvec + (offset * 60.0);
		
		// Now, check if that's on ground, and just give up if it isn't
		// Figure out if it's on our enemy's areaGroup.  If not, step 5% closer until it is.
		int enemyAreaGroup = -1;
		enemyAreaGroup = kbAreaGroupGetIDByPosition(enemyTCvec);
		
		vector towardEnemy = offset * -5.0;   // 5m away from me, toward enemy TC
		bool success = false;
		
		for (i=0; <18)	// Keep testing until areaGroups match
		{
			int testAreaGroup = kbAreaGroupGetIDByPosition(target);
			int NumEnemy = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, target, 23.0, false);
			int NumSelf = getNumUnits(cUnitTypeSkyPassage, cUnitStateAliveOrBuilding, -1, cMyID, target, 100.0);
			if ((testAreaGroup == enemyAreaGroup) && (NumEnemy < 1) && (NumSelf < 1))
			{
				success = true;
				break;
			}
			else
			{
				target = target + towardEnemy;   // Try a bit closer
			}
		}
		if (success == false)
		return;  
		
		int remotePlanID=aiPlanCreate("BuildRemoteSkyPassage", cPlanBuild);
		if (remotePlanID < 0)
		return;
		aiPlanSetVariableInt(remotePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSkyPassage);
		aiPlanSetVariableInt(remotePlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(target));
		aiPlanSetVariableInt(remotePlanID, cBuildPlanNumAreaBorderLayers, 0, 1);
		aiPlanSetDesiredPriority(remotePlanID, 70);
		aiPlanSetEscrowID(remotePlanID, cMilitaryEscrowID);
		aiPlanAddUnitType(remotePlanID, cBuilderType, 1, 1, 1);
		aiPlanSetActive(remotePlanID);
	}
}

//==============================================================================
rule buildFortress
minInterval 2 //starts in cAge3
inactive
{
	
    if ((kbGetAge() > cAge3) && (gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) < cTechStatusResearching))
	return;
	
    float currentFood = kbResourceGet(cResourceFood);
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);
    float currentFavor = kbResourceGet(cResourceFavor);
	
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (numSettlements < 2)
	xsSetRuleMinIntervalSelf(40);
    else
	xsSetRuleMinIntervalSelf(14);
	
    int bigBuildingID = MyFortress;	
	bool TryMB = false;
	
    int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
    if (numFortresses >= kbGetBuildLimit(cMyID, bigBuildingID))
	return;
	
	int SupportUnitsPlan = findPlanByString("SupportUnits", cPlanBuild);
    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID);
    if (otherBaseUnitID < 0)
	return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
        vector location = kbUnitGetPosition(otherBaseUnitID);
        
        bool planActive = false;
        int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
        if (activeBuildPlans > 0)
        {
            for (i = 0; < activeBuildPlans)
            {
                int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
				if (aiPlanGetUserVariableInt(buildPlanIndexID, 0, 0) != -1)
				continue;
			
                if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == bigBuildingID)
                {
                    vector buildPlanCenterPos = aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0);
                    if ((aiPlanGetBaseID(buildPlanIndexID) == otherBaseID) || (equal(location, buildPlanCenterPos) == true))
                    {
                        planActive = true;
					}
                    
                    int enemySettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, buildPlanCenterPos, 15.0);
                    int motherNatureSettlementAtBuildPlanPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, buildPlanCenterPos, 15.0);
                    enemySettlementAtBuildPlanPos = enemySettlementAtBuildPlanPos - motherNatureSettlementAtBuildPlanPos;
                    int alliedSettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, buildPlanCenterPos, 15.0);
					if (aiPlanGetBaseID(buildPlanIndexID) == mainBaseID) 
                    {
                        alliedSettlementAtBuildPlanPos = 0;
                        enemySettlementAtBuildPlanPos = 0;
					}
					
				    if ((enemySettlementAtBuildPlanPos > 0) || (alliedSettlementAtBuildPlanPos > 0) 
					|| (SupportUnitsPlan != -1) && (aiPlanGetBaseID(buildPlanIndexID) != mainBaseID))
                    {
                        aiPlanDestroy(buildPlanIndexID);
					}
				}
			}
		}
        
        if (planActive == true)
        {
            return;
		}
        
        if ((currentFood > 700) && (currentGold > 700) && (kbGetAge() == cAge3) || (numFortresses >= 4) && (kbGetAge() == cAge3))
		return;
        float requiredResource = 350;
        if (kbGetAge() > cAge3)
	    requiredResource = 450;
        if ((currentWood < requiredResource) && (cMyCulture != cCultureEgyptian) || (currentGold < requiredResource) || 
		(numFortresses >= 7) && (SupportUnitsPlan != -1))
		return;	
 		   
        if (otherBaseID != mainBaseID)
        {
            int numFortressesNearOtherBase = getNumUnits(bigBuildingID, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
            //return, if there's already a fortress near other base 
            if (numFortressesNearOtherBase > 0)
		    TryMB = true;	
		}
        else
        TryMB = true;
	}
	
	if (TryMB == true)
	{
		otherBaseID = mainBaseID;
		int numFortressesNearMB = getNumUnits(bigBuildingID, cUnitStateAliveOrBuilding, -1, cMyID, kbBaseGetLocation(cMyID, otherBaseID), 75.0);    		
		if (numFortressesNearMB > 3)
		{
			return;
		}	
	}
    int numBuilders = kbUnitCount(cMyID, cBuilderType, cUnitStateAlive);
    
    //Over time, we will find out what areas are good and bad to build in.
    //Use that info here, because we want to protect houses.
    int planID = aiPlanCreate("BuildMoreFortresses", cPlanBuild);
    if (planID >= 0)
    {
        aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, bigBuildingID);
        aiPlanSetVariableInt(planID, cBuildPlanMaxRetries, 0, 8);
        aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 0.0);
        aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
        aiPlanSetBaseID(planID, otherBaseID);
        aiPlanSetDesiredPriority(planID, 100);
        if ((cMyCulture == cCultureAtlantean) || (numBuilders < 20))
		aiPlanAddUnitType(planID, cBuilderType, 1, 1, 1);
        else
		aiPlanAddUnitType(planID, cBuilderType, 3, 3, 3);
        
        aiPlanSetEscrowID(planID, cMilitaryEscrowID);
        
        
        //variables for our fortress placing
        vector frontVector = kbBaseGetFrontVector(cMyID, otherBaseID);
        float fx = xsVectorGetX(frontVector);
        float fz = xsVectorGetZ(frontVector);
        
        if (otherBaseID == mainBaseID)
        {
            aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
            fx = fx * aiRandInt(40) + 25;
            fz = fz * aiRandInt(40) + 25;
            frontVector = xsVectorSetX(frontVector, fx);
            frontVector = xsVectorSetZ(frontVector, fz);
            frontVector = xsVectorSetY(frontVector, 0.0);
            
            location = location + frontVector;
            aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 40.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 100.0);

            aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 10.0);
            aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitTypeID, 0, MyFortress); 
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitDistance, 0, 15);    
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitValue, 0, -22.0);  			
		}
        else
        {
            aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
            aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, location);
            aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 11.0);          
            aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 0.0);
            aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeTree); 
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitDistance, 0, 10);    
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitValue, 0, -20.0);        // -20 points per unit
            // Weight it to stay very close to center point.
            aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);    // Position influence for landing position
		}
        aiPlanSetInitialPosition(planID, location);
        aiPlanSetActive(planID);
	}
	}

//==============================================================================
rule buildTowerAtOtherBase
minInterval 61 //starts in cAge2
inactive
{
    if ((aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 8*60*1000))
	return;
	
	
    int numTowers = kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
    
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false) && (numTowers > 0))
	return;
	
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);
    float currentFood = kbResourceGet(cResourceFood);
	
    if ((kbGetAge() == cAge2)
	|| (currentFood > 500) && (currentGold > 500) && (kbGetAge() == cAge3))
	return;
    
    int towerLimit = kbGetBuildLimit(cMyID, cUnitTypeTower);
    if (numTowers >= towerLimit)
	return;
	
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (numSettlements < 2)
	xsSetRuleMinIntervalSelf(58);
    else
	xsSetRuleMinIntervalSelf(28);
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID);
    if (otherBaseUnitID < 0)
	return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
        vector otherBaseLocation = kbUnitGetPosition(otherBaseUnitID);
		
        int numTowersNearBase = getNumUnits(cUnitTypeTower, cUnitStateAliveOrBuilding, -1, cMyID, otherBaseLocation, 30.0);
		int Fortressthere = getNumUnits(cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding, -1, cMyID, otherBaseLocation, 30.0);
        if (otherBaseID == mainBaseID)
        {
            return;
		}
	}
	
    int baseID = -1;
    if (otherBaseID != mainBaseID)
    {
        //return, if more than 2 towers near other base 
        if ((numTowersNearBase > 1) && (kbGetAge() == cAge2))
		return;
        else if (numTowersNearBase+Fortressthere >= 1)
		return;
		
        baseID = otherBaseID;
	}
    
    bool planActive = false;
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeTower)
            {
                vector buildPlanCenterPos = aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0);
                if ((aiPlanGetBaseID(buildPlanIndexID) == otherBaseID) || (equal(otherBaseLocation, buildPlanCenterPos) == true))
                {
                    planActive = true;
				}
				
                int enemySettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, buildPlanCenterPos, 15.0);
                int motherNatureSettlementAtBuildPlanPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, buildPlanCenterPos, 15.0);
                enemySettlementAtBuildPlanPos = enemySettlementAtBuildPlanPos - motherNatureSettlementAtBuildPlanPos;
                int alliedSettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, buildPlanCenterPos, 15.0);
                if ((enemySettlementAtBuildPlanPos > 0) || (alliedSettlementAtBuildPlanPos > 0))
                {
                    aiPlanDestroy(buildPlanIndexID);
				}
			}
		}
	}
    
    
    
    if (planActive == true)
    {
        return;
	}
    
    if ((numTowersNearBase < 1) && ((currentWood < 300) || (currentGold < 200)))
	return;
    else if ((currentWood < 500) || (currentGold < 300))
	return;
	
    //Build a tower near our other base
    numTowersNearBase = numTowersNearBase + 1;
    int buildTowerAtOtherBasePlanID = aiPlanCreate("buildTowerAtOtherBase: tower #"+numTowersNearBase, cPlanBuild);
    if (buildTowerAtOtherBasePlanID >= 0)
    {
        aiPlanSetInitialPosition(buildTowerAtOtherBasePlanID, otherBaseLocation);
        aiPlanSetVariableInt(buildTowerAtOtherBasePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTower);
        aiPlanSetVariableInt(buildTowerAtOtherBasePlanID, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetDesiredPriority(buildTowerAtOtherBasePlanID, 100);
        aiPlanSetVariableBool(buildTowerAtOtherBasePlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildTowerAtOtherBasePlanID, cBuildPlanRandomBPValue, 0, 0.99);
        aiPlanSetVariableVector(buildTowerAtOtherBasePlanID, cBuildPlanCenterPosition, 0, otherBaseLocation);
        aiPlanSetVariableFloat(buildTowerAtOtherBasePlanID, cBuildPlanCenterPositionDistance, 0, 13.0);
        aiPlanAddUnitType(buildTowerAtOtherBasePlanID, cBuilderType, 1, 1, 1);
        aiPlanSetEscrowID(buildTowerAtOtherBasePlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(buildTowerAtOtherBasePlanID, baseID);
        aiPlanSetActive(buildTowerAtOtherBasePlanID);
	}
}

//==============================================================================
rule buildBuildingsAtOtherBase
minInterval 31 //starts in cAge2
inactive
{	
    if (kbGetAge() < cAge3)
	return;	
	
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
    if ((woodSupply < 250) || (goldSupply < 300))
	return;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID);
    if (otherBaseUnitID < 0)
	return;
    else
    {
        int otherBaseID=kbUnitGetBaseID(otherBaseUnitID);
        if ((otherBaseID == mainBaseID) || (otherBaseID == gVinlandsagaInitialBaseID))
        {
            return;
		}
	}
    
    int building1ID = -1;
    if (cMyCulture == cCultureEgyptian)
	building1ID = cUnitTypeBarracks;
    else if (cMyCulture == cCultureGreek)
	building1ID = cUnitTypeStable;
    else if (cMyCulture == cCultureNorse)
	building1ID = cUnitTypeLonghouse;
    else if (cMyCulture == cCultureAtlantean)
	building1ID = cUnitTypeCounterBuilding;
    else if (cMyCulture == cCultureChinese)
	building1ID = cUnitTypeStableChinese;	
	
	
    vector location = kbUnitGetPosition(otherBaseUnitID);
	
    //return if we already have a building1 at the other base
    int numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAliveOrBuilding, -1, cMyID, location, 25.0);
    if ((cMyCulture == cCultureEgyptian)|| (cMyCulture == cCultureNorse))
    {
        if (numBuilding1NearBase > 1)
		return;
	}
	else
	{
        if (numBuilding1NearBase > 0)
		{
			if (cMyCulture == cCultureGreek)
			{
	            int RandomBuilding = aiRandInt(2);
	            if (RandomBuilding == 0)
                building1ID = cUnitTypeAcademy;
                else 
                building1ID = cUnitTypeArcheryRange;
			}
			if (cMyCulture == cCultureAtlantean)
			building1ID = cUnitTypeBarracksAtlantean;
			if (cMyCulture == cCultureChinese)
			building1ID = cUnitTypeBarracksChinese;	
			numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAliveOrBuilding, -1, cMyID, location, 25.0);
			if ((cMyCiv == cCivOuranos) && (gTransportMap == false) && (numBuilding1NearBase > 0))
			{
				building1ID = cUnitTypeSkyPassage;
				numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAliveOrBuilding, -1, cMyID, location, 25.0);
			}
		}
		if (numBuilding1NearBase > 0)
		return;		
	}
	
    
    bool planActive = false;
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == building1ID)
            {
                vector buildPlanCenterPos = aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0);
                if ((aiPlanGetBaseID(buildPlanIndexID) == otherBaseID) || (equal(location, buildPlanCenterPos) == true))
                {
                    planActive = true;
				}
				
                int enemySettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, buildPlanCenterPos, 15.0);
                int motherNatureSettlementAtBuildPlanPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, buildPlanCenterPos, 15.0);
                enemySettlementAtBuildPlanPos = enemySettlementAtBuildPlanPos - motherNatureSettlementAtBuildPlanPos;
                int alliedSettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, buildPlanCenterPos, 15.0);
                if ((enemySettlementAtBuildPlanPos > 0) || (alliedSettlementAtBuildPlanPos > 0))
                {
                    aiPlanDestroy(buildPlanIndexID);
				}
			}
		}
	}
    
    
    
    if (planActive == true)
    {
        return;
	}
	
    //Force building #1 to go down.
    int buildBuilding1AtOtherBasePlanID = aiPlanCreate("buildBuilding1AtOtherBase", cPlanBuild);
    if (buildBuilding1AtOtherBasePlanID >= 0)
    {
        aiPlanSetInitialPosition(buildBuilding1AtOtherBasePlanID, location);
        aiPlanSetVariableInt(buildBuilding1AtOtherBasePlanID, cBuildPlanBuildingTypeID, 0, building1ID);
        aiPlanSetVariableInt(buildBuilding1AtOtherBasePlanID, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetVariableBool(buildBuilding1AtOtherBasePlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanRandomBPValue, 0, 0.99);
        
        aiPlanSetVariableVector(buildBuilding1AtOtherBasePlanID, cBuildPlanCenterPosition, 0, location);
        if (building1ID == cUnitTypeSkyPassage)
        aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanCenterPositionDistance, 0, 9.0);
        else
		aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanCenterPositionDistance, 0, 10.0);
        aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanBuildingBufferSpace, 0, 0.0);
        aiPlanSetVariableInt(buildBuilding1AtOtherBasePlanID, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeTree); 
        aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanInfluenceUnitDistance, 0, 10);    
        aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanInfluenceUnitValue, 0, -20.0);        // -20 points per unit
        // Weight it to stay very close to center point.
        aiPlanSetVariableVector(buildBuilding1AtOtherBasePlanID, cBuildPlanInfluencePosition, 0, location);    // Position influence for landing position				
		
        aiPlanSetDesiredPriority(buildBuilding1AtOtherBasePlanID, 100);
        aiPlanAddUnitType(buildBuilding1AtOtherBasePlanID, cBuilderType, 1, 1, 1);
        aiPlanSetEscrowID(buildBuilding1AtOtherBasePlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(buildBuilding1AtOtherBasePlanID, otherBaseID);
        aiPlanSetActive(buildBuilding1AtOtherBasePlanID);
        gBuildBuilding1AtOtherBasePlanID = buildBuilding1AtOtherBasePlanID;	
	}
}
//==============================================================================
rule buildMirrorTower
minInterval 29 //starts in cAge4
inactive
{
    
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);
	
    int numMirrorTowers = kbUnitCount(cMyID, cUnitTypeTowerMirror, cUnitStateAliveOrBuilding);
    int buildMirrorTowerLimit = kbGetBuildLimit(cMyID, cUnitTypeTowerMirror);
    if (numMirrorTowers >= buildMirrorTowerLimit)
	return;
	
    if ((currentWood < 500) || (currentGold < 300))
	return;
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID);
    if (otherBaseUnitID < 0)
	return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
        vector otherBaseLocation = kbUnitGetPosition(otherBaseUnitID);
		
        int numMirrorTowersNearBase = getNumUnits(cUnitTypeTowerMirror, cUnitStateAliveOrBuilding, -1, cMyID, otherBaseLocation, 30.0);
		
        if (otherBaseID == mainBaseID)
        {
            return;
		}
	}
	
    int baseID = -1;
    if (otherBaseID != mainBaseID)
    {
        //return, if there's at least 1 mirror tower near other base 
        if (numMirrorTowersNearBase > 0)
		return;
		
        baseID = otherBaseID;
	}
    
    bool planActive = false;
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeTowerMirror)
            {
                vector buildPlanCenterPos = aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0);
                if ((aiPlanGetBaseID(buildPlanIndexID) == otherBaseID) || (equal(otherBaseLocation, buildPlanCenterPos) == true))
                {
                    planActive = true;
				}
				
                int enemySettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, buildPlanCenterPos, 15.0);
                int motherNatureSettlementAtBuildPlanPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, buildPlanCenterPos, 15.0);
                enemySettlementAtBuildPlanPos = enemySettlementAtBuildPlanPos - motherNatureSettlementAtBuildPlanPos;
                int alliedSettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, buildPlanCenterPos, 15.0);
                if ((enemySettlementAtBuildPlanPos > 0) || (alliedSettlementAtBuildPlanPos > 0))
                {
                    aiPlanDestroy(buildPlanIndexID);
				}
			}
		}
	}
    
    
	
    if (planActive == true)
    {
        return;
	}
	
    //Build a mirror tower near our other base
    static int count = 1;
    int buildMirrorTowerPlanID = aiPlanCreate("Build mirror tower #"+count, cPlanBuild);
    if (buildMirrorTowerPlanID >= 0)
    {
        aiPlanSetInitialPosition(buildMirrorTowerPlanID, otherBaseLocation);
        aiPlanSetVariableInt(buildMirrorTowerPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTowerMirror);
        aiPlanSetVariableInt(buildMirrorTowerPlanID, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetDesiredPriority(buildMirrorTowerPlanID, 100);
        aiPlanSetVariableBool(buildMirrorTowerPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildMirrorTowerPlanID, cBuildPlanRandomBPValue, 0, 0.99);
        
        aiPlanSetVariableVector(buildMirrorTowerPlanID, cBuildPlanCenterPosition, 0, otherBaseLocation);
        aiPlanSetVariableFloat(buildMirrorTowerPlanID, cBuildPlanCenterPositionDistance, 0, 13.0);
        aiPlanAddUnitType(buildMirrorTowerPlanID, cBuilderType, 1, 1, 1);
        aiPlanSetEscrowID(buildMirrorTowerPlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(buildMirrorTowerPlanID, baseID);
        aiPlanSetActive(buildMirrorTowerPlanID);
        count = count + 1;
	}
}

//==============================================================================
rule buildInitialTemple //and rebuild it if destroyed
inactive
minInterval 41 //starts in cAge1
{
    
    if (gTransportMap == true)
    {
        if ((gGatherGoalPlanID >= 0) && (cMyCulture == cCultureGreek))
        {
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 1);
            aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, 41, 1.0, kbBaseGetMainID(cMyID));
		}
        xsDisableSelf();
        return;
	}
    
    if ((xsGetTime() < 2*60*1000) && (aiGetWorldDifficulty() <= cDifficultyNightmare))
	return;

    int mainBaseID = kbBaseGetMainID(cMyID);
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeTemple) && (aiPlanGetBaseID(buildPlanIndexID) == mainBaseID))
            {
                return;
			}
		}
	}
    
    static bool greekFavorActivated = false;
    vector location = kbBaseGetLocation(cMyID, mainBaseID);
    float distance = 45.0;
    if (xsGetTime() > 20*60*1000)
	distance = 55.0;
    int numTemplesAtMainBase = getNumUnits(cUnitTypeTemple, cUnitStateAliveOrBuilding, -1, cMyID, location, distance);
    if (numTemplesAtMainBase > 0)
    {
        if ((cMyCulture == cCultureGreek) && (greekFavorActivated == false) && (xsGetTime() > 4.5*60*1000))
        {
            if (gGatherGoalPlanID >= 0)
            {
                aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 1);
                aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, 41, 1.0, kbBaseGetMainID(cMyID));
                greekFavorActivated = true;
			}
		}
        return;
	}
    
    vector frontVector = kbBaseGetFrontVector(cMyID, kbBaseGetMainID(cMyID));
    float fx = xsVectorGetX(frontVector);
    float fz = xsVectorGetZ(frontVector);
	
    //Force a temple to go down            
    int templePlanID = aiPlanCreate("build temple", cPlanBuild);
    if (templePlanID >= 0)
    {
        aiPlanSetVariableInt(templePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTemple);
        aiPlanSetVariableBool(templePlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);        
		
        fx = fx * 15;
        fz = fz * 15;
		
        frontVector = xsVectorSetX(frontVector, fx);
        frontVector = xsVectorSetZ(frontVector, fz);
        frontVector = xsVectorSetY(frontVector, 0.0);
        location = location + frontVector;
		
        aiPlanSetVariableVector(templePlanID, cBuildPlanInfluencePosition, 0, location);
        if (xsGetTime() > 20*60*1000)
        {
            aiPlanSetVariableFloat(templePlanID, cBuildPlanRandomBPValue, 0, 0.99);
            aiPlanSetVariableFloat(templePlanID, cBuildPlanInfluencePositionDistance, 0, 40.0);
            aiPlanSetVariableFloat(templePlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
		}
        else
        {
            aiPlanSetVariableFloat(templePlanID, cBuildPlanRandomBPValue, 0, 0.0);
            aiPlanSetVariableFloat(templePlanID, cBuildPlanInfluencePositionDistance, 0, 15.0);
            aiPlanSetVariableFloat(templePlanID, cBuildPlanInfluencePositionValue, 0, 10000.0);
		}
		
        aiPlanSetDesiredPriority(templePlanID, 100);
        aiPlanAddUnitType(templePlanID, cBuilderType, 1, 1, 1);
        aiPlanSetEscrowID(templePlanID, cEconomyEscrowID);
        aiPlanSetBaseID(templePlanID, mainBaseID);
        aiPlanSetActive(templePlanID);
	}
}

//==============================================================================
rule buildArmory
inactive
minInterval 47 //starts in cAge1
{
    
    if (gTransportMap == true)
    {
        xsDisableSelf();
        return;
	}
	float woodSupply = kbResourceGet(cResourceWood);
	int numBuilders = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
	int MilBuildings = kbUnitCount(cMyID, cUnitTypeLogicalTypeBuildingsThatTrainMilitary, cUnitStateAliveOrBuilding);
	
    if ((kbGetAge() < cAge2)|| (kbGetAge() >= cAge2) && (woodSupply < 450) && (cMyCulture != cCultureEgyptian) || (MilBuildings < 4))
	return;
    
    xsSetRuleMinIntervalSelf(47);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int buildingID = cUnitTypeArmory;
    if (cMyCiv == cCivThor)
	buildingID = cUnitTypeDwarfFoundry;
    int numArmories = kbUnitCount(cMyID, buildingID, cUnitStateAliveOrBuilding);
    int armoryBuildPlan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, buildingID, true);
    if ((numArmories > 0) || (armoryBuildPlan != -1))
    {
        xsSetRuleMinIntervalSelf(140);
        return;
	}
    
    if (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching)
	return;
    
    vector location = kbBaseGetLocation(cMyID, mainBaseID);
    vector backVector = kbBaseGetBackVector(cMyID, mainBaseID);
    float bx = xsVectorGetX(backVector);
    float bz = xsVectorGetZ(backVector);
    float bxOrig = bx;
    float bzOrig = bz;
    
    int armoryPlanID=aiPlanCreate("Armory", cPlanBuild);
    if (armoryPlanID >= 0)
    {
        aiPlanSetVariableInt(armoryPlanID, cBuildPlanBuildingTypeID, 0, buildingID);
        aiPlanSetVariableBool(armoryPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(armoryPlanID, cBuildPlanRandomBPValue, 0, 0.99);
		
        bx = bx * 25;
        bz = bz * 25;
		
        backVector = xsVectorSetX(backVector, bx);
        backVector = xsVectorSetZ(backVector, bz);
        backVector = xsVectorSetY(backVector, 0.0);
        location = location + backVector;
		
        aiPlanSetVariableVector(armoryPlanID, cBuildPlanInfluencePosition, 0, location);
        aiPlanSetVariableFloat(armoryPlanID, cBuildPlanInfluencePositionDistance, 0, 40.0);
        aiPlanSetVariableFloat(armoryPlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
        aiPlanSetDesiredPriority(armoryPlanID, 100);
        aiPlanAddUnitType(armoryPlanID, cBuilderType, 1, 1, 1);
        aiPlanSetEscrowID(armoryPlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(armoryPlanID, mainBaseID);
        aiPlanSetActive(armoryPlanID);
	}
}

//==============================================================================
rule fixUnfinishedWalls
inactive
minInterval 83 //starts in cAge2
{
	
    int numUnfinishedWalls = getNumUnits(cUnitTypeAbstractWall, cUnitStateBuilding, -1, cMyID);
    if (numUnfinishedWalls < 1)
	return;
    
    if (numUnfinishedWalls > 5)
	numUnfinishedWalls = 5;
	
    static int wallPiece1UnitID = -1;
    static int wallPiece2UnitID = -1;
    static int wallPiece3UnitID = -1;
    static int wallPiece4UnitID = -1;
    static int wallPiece5UnitID = -1;
    
    bool wallPiece1UnitIDSavedNow = false;
    bool wallPiece2UnitIDSavedNow = false;
    bool wallPiece3UnitIDSavedNow = false;
    bool wallPiece4UnitIDSavedNow = false;
    bool wallPiece5UnitIDSavedNow = false;
    
    for (i = 0; < numUnfinishedWalls)
    {
        int unfinishedWallID = findUnitByIndex(cUnitTypeAbstractWall, i, cUnitStateBuilding, -1, cMyID);
        if (unfinishedWallID > 0)
        {
            if (unfinishedWallID == wallPiece1UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece1UnitID = -1;
			}
            else if (unfinishedWallID == wallPiece2UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece2UnitID = -1;
			}
            else if (unfinishedWallID == wallPiece3UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece3UnitID = -1;
			}
            else if (unfinishedWallID == wallPiece4UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece4UnitID = -1;
			}
            else if (unfinishedWallID == wallPiece5UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece5UnitID = -1;
			}
            else
            {
                if (wallPiece1UnitID == -1)
                {
                    wallPiece1UnitID = unfinishedWallID;
                    wallPiece1UnitIDSavedNow = true;
				}
                else if (wallPiece2UnitID == -1)
                {
                    wallPiece2UnitID = unfinishedWallID;
                    wallPiece2UnitIDSavedNow = true;
				}
                else if (wallPiece3UnitID == -1)
                {
                    wallPiece3UnitID = unfinishedWallID;
                    wallPiece3UnitIDSavedNow = true;
				}
                else if (wallPiece4UnitID == -1)
                {
                    wallPiece4UnitID = unfinishedWallID;
                    wallPiece4UnitIDSavedNow = true;
				}
                else if (wallPiece5UnitID == -1)
                {
                    wallPiece5UnitID = unfinishedWallID;
                    wallPiece5UnitIDSavedNow = true;
				}
			}
		}
	}
    
    if (wallPiece1UnitIDSavedNow == false)
	wallPiece1UnitID = -1;
    if (wallPiece2UnitIDSavedNow == false)
	wallPiece2UnitID = -1;
    if (wallPiece3UnitIDSavedNow == false)
	wallPiece3UnitID = -1;
    if (wallPiece4UnitIDSavedNow == false)
	wallPiece4UnitID = -1;
    if (wallPiece5UnitIDSavedNow == false)
	wallPiece5UnitID = -1;
}

//==============================================================================
rule fixUnfinishedFarms
inactive
minInterval 80 //starts in cAge2
{
    int numUnfinishedFarms = getNumUnits(cUnitTypeFarm, cUnitStateBuilding, -1, cMyID);
    if (numUnfinishedFarms < 1)
	return;
    
    if (numUnfinishedFarms > 3)
	numUnfinishedFarms = 3;
	
    static int farmPiece1UnitID = -1;
    static int farmPiece2UnitID = -1;
    static int farmPiece3UnitID = -1;
    bool farmPiece1UnitIDSavedNow = false;
    bool farmPiece2UnitIDSavedNow = false;
    bool farmPiece3UnitIDSavedNow = false;
    
    for (i = 0; < numUnfinishedFarms)
    {
        int unfinishedfarmID = findUnitByIndex(cUnitTypeFarm, i, cUnitStateBuilding, -1, cMyID);
        if (unfinishedfarmID > 0)
        {
            if (unfinishedfarmID == farmPiece1UnitID)
            {
                aiTaskUnitDelete(unfinishedfarmID);
                farmPiece1UnitID = -1;
			}
            else if (unfinishedfarmID == farmPiece2UnitID)
            {
                aiTaskUnitDelete(unfinishedfarmID);
                farmPiece2UnitID = -1;
			}
            else if (unfinishedfarmID == farmPiece3UnitID)
            {
                aiTaskUnitDelete(unfinishedfarmID);
                farmPiece3UnitID = -1;
			}
            else
            {
                if (farmPiece1UnitID == -1)
                {
                    farmPiece1UnitID = unfinishedfarmID;
                    farmPiece1UnitIDSavedNow = true;
				}
                else if (farmPiece2UnitID == -1)
                {
                    farmPiece2UnitID = unfinishedfarmID;
                    farmPiece2UnitIDSavedNow = true;
				}
                else if (farmPiece3UnitID == -1)
                {
                    farmPiece3UnitID = unfinishedfarmID;
                    farmPiece3UnitIDSavedNow = true;
				}
			}
		}
	}
    if (farmPiece1UnitIDSavedNow == false)
	farmPiece1UnitID = -1;
    if (farmPiece2UnitIDSavedNow == false)
	farmPiece2UnitID = -1;
    if (farmPiece3UnitIDSavedNow == false)
	farmPiece3UnitID = -1;
}

//==============================================================================
rule buildResearchGranary   //or a guild for Atlanteans or a house for Norse
inactive
minInterval 15 //starts in cAge1
{
    if (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding) < 1)
    return;
	
    int buildingType = cUnitTypeGranary;
    if (cMyCulture == cCultureAtlantean)
	buildingType = cUnitTypeGuild;
    else if (cMyCulture == cCultureNorse)
	buildingType = cUnitTypeHouse;
    else if (cMyCulture == cCultureChinese)
	buildingType = cUnitTypeStoragePit;		
	
    int mainBaseID = kbBaseGetMainID(cMyID);
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == buildingType) && (aiPlanGetBaseID(buildPlanIndexID) == mainBaseID))
            {
                return;
			}
		}
	}
    
    if (gResearchGranaryID > 0)
    {
        float researchGranaryHitpoints = kbUnitGetCurrentHitpoints(gResearchGranaryID);
        if (researchGranaryHitpoints > 0)
        {
            return;
		}
	}
	
    vector location = kbBaseGetLocation(cMyID, mainBaseID);
    vector backVector = kbBaseGetBackVector(cMyID, mainBaseID);
    float bx = xsVectorGetX(backVector);
    float bz = xsVectorGetZ(backVector);
    
    bx = bx * 25;
    bz = bz * 25;
	
    backVector = xsVectorSetX(backVector, bx);
    backVector = xsVectorSetZ(backVector, bz);
    backVector = xsVectorSetY(backVector, 0.0);
    location = location + backVector;
    
    int granaryID = findUnitByIndex(buildingType, 0, cUnitStateAliveOrBuilding, -1, cMyID, location);
    if (granaryID > 0)
    {
        gResearchGranaryID = granaryID;
        return;
	}
	
    float woodSupply = kbResourceGet(cResourceWood);
    if ((woodSupply < 150) && (cMyCulture != cCultureAtlantean) || (woodSupply < 250) && (cMyCulture == cCultureAtlantean))
	return;	

    //Force a granary (or guild or house) to go down            
    int researchGranaryPlanID=aiPlanCreate("buildResearchGranary", cPlanBuild);
    if (researchGranaryPlanID >= 0)
    {
        aiPlanSetVariableInt(researchGranaryPlanID, cBuildPlanBuildingTypeID, 0, buildingType);
        aiPlanSetVariableBool(researchGranaryPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(researchGranaryPlanID, cBuildPlanRandomBPValue, 0, 0.0);
		
        aiPlanSetVariableVector(researchGranaryPlanID, cBuildPlanInfluencePosition, 0, location);
        aiPlanSetVariableFloat(researchGranaryPlanID, cBuildPlanInfluencePositionDistance, 0, 12.0);
        aiPlanSetVariableFloat(researchGranaryPlanID, cBuildPlanInfluencePositionValue, 0, 10000.0);
		
        aiPlanSetDesiredPriority(researchGranaryPlanID, 100);
        aiPlanAddUnitType(researchGranaryPlanID, cBuilderType, 1, 1, 1);
        aiPlanSetEscrowID(researchGranaryPlanID, cEconomyEscrowID);
        aiPlanSetBaseID(researchGranaryPlanID, mainBaseID);
        aiPlanSetActive(researchGranaryPlanID);
	}
}

//==============================================================================
rule destroyUnnecessaryDropsites
inactive
minInterval 480 //starts in cAge2
{
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
    if (otherBaseUnitID < 0)
	return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
	}
    
    float radius = 0;
    if (otherBaseID == mainBaseID)
    {
        if (xsGetTime() < 10*60*1000)
		radius = 20;
        else
		radius = 50;
	}
    else
	radius = gOtherBaseWallRadius + 10;
    
    vector baseLocation = kbBaseGetLocation(cMyID, otherBaseID);
    int numDropsitesNearBase = getNumUnits(cUnitTypeDropsite, cUnitStateAliveOrBuilding, -1, cMyID, baseLocation, radius);
    if (numDropsitesNearBase < 1)
	return;
    
    if (numDropsitesNearBase > 16)
	numDropsitesNearBase = 16;
    
    for (i = 0; < numDropsitesNearBase)
    {
        int dropsiteID = findUnitByIndex(cUnitTypeDropsite, i, cUnitStateAliveOrBuilding, -1, cMyID, baseLocation, radius);
        if (dropsiteID > 0)
        {
            if (dropsiteID != gResearchGranaryID)
            {
                vector dropsiteLocation = kbUnitGetPosition(dropsiteID);
                int numAnimals = getNumUnits(cUnitTypeHuntedResource, cUnitStateAny, -1, 0, dropsiteLocation, 17.0);
                int numWildCrops = getNumUnits(cUnitTypeWildCrops, cUnitStateAny, -1, 0, dropsiteLocation, 17.0);
                int numTrees = getNumUnits(cUnitTypeTree, cUnitStateAlive, -1, 0, dropsiteLocation, 35.0);
                int numGoldMines = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, dropsiteLocation, 17.0);
                int NumFarms = getNumUnits(cUnitTypeFarm, cUnitStateAliveOrBuilding, -1, cMyID, dropsiteLocation, 21.0);
				
                if (kbUnitIsType(dropsiteID, cUnitTypeGranary) == true)
                {
                    if ((numAnimals < 2) && (numWildCrops < 1) && (NumFarms < 1) || (otherBaseID != mainBaseID))
                    {
                        if ((kbGetTechStatus(cTechPlow) != cTechStatusResearching) && (kbGetTechStatus(cTechHuntingDogs) != cTechStatusResearching) && (kbGetTechStatus(cTechHusbandry) != cTechStatusResearching))
                        {
                            aiTaskUnitDelete(dropsiteID);
						}
                        continue;
					}
				}
                if (cMyCulture == cCultureEgyptian)
                {
                    if (kbUnitIsType(dropsiteID, cUnitTypeLumberCamp) == true)
                    {
                        if ((numTrees < 1) || (otherBaseID != mainBaseID))
                        {
                            if (kbGetTechStatus(cTechHandAxe) != cTechStatusResearching)
                            {
                                aiTaskUnitDelete(dropsiteID);
							}
						}
                        continue;
					}
                    if (kbUnitIsType(dropsiteID, cUnitTypeMiningCamp) == true)
                    {
                        if (numGoldMines < 1)
                        {
                            if (kbGetTechStatus(cTechPickaxe) != cTechStatusResearching)
                            {
                                aiTaskUnitDelete(dropsiteID);
							}
						}
                        continue;
					}
				}
                else if (cMyCulture == cCultureGreek)
                {
                    if (kbUnitIsType(dropsiteID, cUnitTypeStorehouse) == true)
                    {
                        if (((numTrees < 1) && (numGoldMines < 1)) || ((otherBaseID != mainBaseID) && (numGoldMines < 1)))
                        {
                            if ((kbGetTechStatus(cTechHandAxe) != cTechStatusResearching) && (kbGetTechStatus(cTechPickaxe) != cTechStatusResearching))
                            {
                                aiTaskUnitDelete(dropsiteID);
							}
						}
                        continue;
					}
				}
                else if (cMyCulture == cCultureChinese)
                {
                    if (kbUnitIsType(dropsiteID, cUnitTypeStoragePit) == true)
                    {
                        if (((numTrees < 1) && (numGoldMines < 1) && (NumFarms < 1) || ((otherBaseID != mainBaseID) && (numGoldMines < 1))))
                        {
                            if ((kbGetTechStatus(cTechHandAxe) != cTechStatusResearching) && (kbGetTechStatus(cTechPickaxe) != cTechStatusResearching))
                            {
                                aiTaskUnitDelete(dropsiteID);
							}
						}
                        continue;				
					}
				}
			}
		}
	}
}
//==============================================================================
rule findMySettlementsBeingBuilt
minInterval 3 //starts in cAge2
inactive
{
    
    int myBaseAtDefPlanPosition = -1;
    int ActivePlan = findPlanByString("settlementPosDefPlan", cPlanDefend);
    if (ActivePlan > 0)
    {
        vector defendPlanDefendPoint = aiPlanGetVariableVector(ActivePlan, cDefendPlanDefendPoint, 0);
        myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defendPlanDefendPoint, 15.0);
        if (myBaseAtDefPlanPosition < 1)
        return;
	}
    
    int numSettlementsBeingBuilt = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateBuilding);
    if (numSettlementsBeingBuilt > 0)
    {
        for (i = 0; < numSettlementsBeingBuilt)
        {
            int mainBaseID = kbBaseGetMainID(cMyID);
            vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
            
            int settlementBeingBuiltID = findUnitByIndex(cUnitTypeAbstractSettlement, i, cUnitStateBuilding, -1, cMyID);
            if ((settlementBeingBuiltID != -1) && ((SameAG(kbUnitGetPosition(settlementBeingBuiltID), mainBaseLocation) == true)))
            {
                vector settlementBeingBuiltPosition = kbUnitGetPosition(settlementBeingBuiltID);
                float distanceToMainBase = xsVectorLength(mainBaseLocation - settlementBeingBuiltPosition);
                if (distanceToMainBase > 30.0)
                {
                    if (myBaseAtDefPlanPosition > 0)
                    {
                        xsSetRuleMinInterval("defendSettlementPosition", 1);
                        xsDisableRule("defendSettlementPosition");
                        aiPlanDestroy(gSettlementPosDefPlanID);
					}
                    gSettlementPosDefPlanDefPoint = settlementBeingBuiltPosition;
                    xsEnableRule("defendSettlementPosition");
                    break;
				}
			}
		}
	}
}
//==============================================================================
rule buildMBTower
minInterval 22 //starts in cAge2
inactive
{
    if ((aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 6*60*1000))
    return;	
    
    int numTowers = kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
    
    if (cMyCulture != cCultureEgyptian)
    {
        if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (numTowers > 0))
		return;
		
        if ((gAge2MinorGod == cTechAge2Heimdall) && (kbGetTechStatus(cTechSafeguard) < cTechStatusResearching))
		return;
	}
	
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);
    float currentFood = kbResourceGet(cResourceFood);
	
    if ((currentWood < 400) && (cMyCulture != cCultureEgyptian) || (currentGold < 300))
	return;
	
    if (kbGetAge() == cAge2)
    {
        if ((currentFood > 500) && (currentGold > 300))
        return;
	}
    else if (kbGetAge() == cAge3)
    {
        int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
        int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
        if ((numFortresses < 1) || (numMarkets < 1))
		return;
        
        if ((currentFood > 700) && (currentGold > 700))
		return;
	}
    
	int mainBaseID = kbBaseGetMainID(cMyID);
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int NumTowersInMB = getNumUnits(cUnitTypeTower, cUnitStateAlive, -1, cMyID, mainBaseLocation, 85.0);
    int towerLimit = kbGetBuildLimit(cMyID, cUnitTypeTower);
	if (kbGetAge() == cAge2)
	towerLimit = 4;
    if ((numTowers >= towerLimit) || (NumTowersInMB >= 6))
	return;
	
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeTower) && (aiPlanGetBaseID(buildPlanIndexID) == mainBaseID))
            {
                return;
			}
		}
	}
	
	int attempt = 0;
	vector testVec = cInvalidVector;
	float spacingDistance = 24.0; // Mid- and corner-spots on a square with 'radius' spacingDistance, i.e. each side is 2 * spacingDistance.
	float exclusionRadius = spacingDistance / 2.0;
	float dx = spacingDistance;
	float dz = spacingDistance;
	bool success = false;
	
	for (attempt = 0; < 10) // Take ten tries to place it
	{
		testVec = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)); // Start with base location
		
		switch(aiRandInt(8)) // 0..7
		{  // Use 0.9 * on corners to "round them" a bit
			case 0:
			{  // W
				dx = -0.9 * dx;
				dz = 0.9 * dz;
				break;
			}
			case 1:
			{  // NW
				dx = 0.0;
				break;
			}
			case 2:
			{  // N
				dx = 0.9 * dx;
				dz = 0.9 * dz;
				break;
			}
			case 3:
			{  // NE
				dz = 0.0;
				break;
			}
			case 4:
			{  // E
				dx = 0.9 * dx;
				dz = -0.9 * dz;
				break;
			}
			case 5:
			{  // SE
				dx = 0.0;
				dz = -1.0 * dz;
				break;
			}
			case 6:
			{  // S
				dx = -0.9 * dx;
				dz = -0.9 * dz;
				break;
			}
			case 7:
			{  // SW
				dx = -1.0 * dx;
				dz = 0;
				break;
			}
		}
		testVec = xsVectorSetX(testVec, xsVectorGetX(testVec) + dx);
		testVec = xsVectorSetZ(testVec, xsVectorGetZ(testVec) + dz);
		int towerSearch = findClosestUnitTypeByLoc(cPlayerRelationSelf, cUnitTypeTower, cUnitStateAliveOrBuilding, testVec, exclusionRadius);
		if (towerSearch < 1)
		{  // Site is clear, use it
			if (kbAreaGroupGetIDByPosition(testVec) == kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))))
			{  // Make sure it's in same areagroup.
				success = true;
				break;
			}
		}
	}
	
	// We have found a location (success == true) or we need to just do a brute force placement around the TC.
	if (success == false)
	testVec = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	
    //Build a tower near our main base
    static int count = 1;
    int buildMBTowerPlanID = aiPlanCreate("Build main base tower #"+count, cPlanBuild);
    if (buildMBTowerPlanID >= 0)
    {
        if (success == true)
        aiPlanSetVariableFloat(buildMBTowerPlanID, cBuildPlanCenterPositionDistance, 0, 18);
        else
        aiPlanSetVariableFloat(buildMBTowerPlanID, cBuildPlanCenterPositionDistance, 0, 30.0);	
        aiPlanSetInitialPosition(buildMBTowerPlanID, mainBaseLocation);
        aiPlanSetVariableInt(buildMBTowerPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTower);
        aiPlanSetDesiredPriority(buildMBTowerPlanID, 100);
        aiPlanSetVariableBool(buildMBTowerPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildMBTowerPlanID, cBuildPlanRandomBPValue, 0, 0.99);
        
        aiPlanSetVariableVector(buildMBTowerPlanID, cBuildPlanCenterPosition, 0, testVec);
        aiPlanAddUnitType(buildMBTowerPlanID, cBuilderType, 1, 1, 1);
        aiPlanSetEscrowID(buildMBTowerPlanID, cMilitaryEscrowID);
        // Add position influence for nearby towers
        aiPlanSetVariableInt(buildMBTowerPlanID, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeTower); 
        aiPlanSetVariableFloat(buildMBTowerPlanID, cBuildPlanInfluenceUnitDistance, 0, spacingDistance);    
        aiPlanSetVariableFloat(buildMBTowerPlanID, cBuildPlanInfluenceUnitValue, 0, -20.0);        // -20 points per tower
        // Weight it to stay very close to center point.
        aiPlanSetVariableVector(buildMBTowerPlanID, cBuildPlanInfluencePosition, 0, testVec);    // Position influence for landing position
        aiPlanSetVariableFloat(buildMBTowerPlanID, cBuildPlanInfluencePositionDistance, 0, exclusionRadius);     // 100m range.
		aiPlanSetVariableFloat(buildMBTowerPlanID, cBuildPlanInfluencePositionValue, 0, 10.0);        // 10 points for center		
        aiPlanSetBaseID(buildMBTowerPlanID, mainBaseID);
        aiPlanSetActive(buildMBTowerPlanID);
        count = count + 1;
	}
}

//==============================================================================
rule fixJammedDropsiteBuildPlans
minInterval 97 //starts in cAge1
inactive
{
	
    static int SHBuildPlanID = -1;
    static int LCBuildPlanID = -1;
    static int MCBuildPlanID = -1;
    int dropsiteTypeID = -1;
    int dropsiteBuildPlanID = -1;
    int loops = 1;
    if (cMyCulture == cCultureEgyptian)
	loops = 2;
    for (i = 0; < loops)
    {
        if (cMyCulture == cCultureGreek)
		dropsiteTypeID = cUnitTypeStorehouse;
        else if (cMyCulture == cCultureChinese)
		dropsiteTypeID = cUnitTypeStoragePit;			
        else
        {
            if (i == 0)
			dropsiteTypeID = cUnitTypeLumberCamp;
            else
			dropsiteTypeID = cUnitTypeMiningCamp;
		}
        
        dropsiteBuildPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, dropsiteTypeID, true);
        if (dropsiteBuildPlanID != -1)
        {
            int numBuildersInPlan = aiPlanGetNumberUnits(dropsiteBuildPlanID, cUnitTypeAbstractVillager);
            if (numBuildersInPlan > 5)
            {
                if (cMyCulture == cCultureGreek)
                {
                    if (dropsiteBuildPlanID == SHBuildPlanID)
                    {
                        aiPlanDestroy(dropsiteBuildPlanID);
					}
                    else
                    {
                        SHBuildPlanID = dropsiteBuildPlanID;
					}
				}
                else    //Egyptian
                {
                    if (i == 0)
                    {
                        if (dropsiteBuildPlanID == LCBuildPlanID)
                        {
                            aiPlanDestroy(dropsiteBuildPlanID);
						}
                        else
                        {
                            LCBuildPlanID = dropsiteBuildPlanID;
						}
					}
                    else
                    {
                        if (dropsiteBuildPlanID == MCBuildPlanID)
                        {
                            aiPlanDestroy(dropsiteBuildPlanID);
						}
                        else
                        {
                            LCBuildPlanID = dropsiteBuildPlanID;
						}
					}
				}
			}
		}
	}
}
//==============================================================================
rule rebuildMarket  // If market dies, restart
minInterval 19 //starts in cAge3, activated in tradeWithCaravans, after market is built
inactive
{
    
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
        
        xsEnableRule("tradeWithCaravans");
        xsDisableSelf();
        gTradeMarketUnitID = -1;
	}
}
//==============================================================================
rule buildExtraFarms
minInterval 6 //gets activated in updateFoodBreakdown
inactive
{
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector backLocation = cInvalidVector;
    vector backVector = kbBaseGetBackVector(cMyID, mainBaseID);
    float bx = xsVectorGetX(backVector);
    float bz = xsVectorGetZ(backVector);
    
    bx = bx * 10;
    bz = bz * 10;
	
    backVector = xsVectorSetX(backVector, bx);
    backVector = xsVectorSetZ(backVector, bz);
    backVector = xsVectorSetY(backVector, 0.0);
    backLocation = mainBaseLocation + backVector;
	int Resource = cResourceWood;
	if (cMyCulture == cCultureEgyptian)
	Resource = cResourceGold;
	int numVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
	if (cMyCulture == cCultureAtlantean)
	numVillagers = numVillagers*2;
    int numFarmsNearMainBaseInR30 = kbBaseGetNumberUnits(cMyID, gFarmBaseID, -1, cUnitTypeFarm);
    int ActivePlans = findPlanByString("Build main base farm", cPlanBuild, -1, true, true);
	
    if ((gFarming == false) || (numFarmsNearMainBaseInR30 >= MoreFarms) || (numFarmsNearMainBaseInR30+ActivePlans >= MoreFarms)
	|| (numVillagers < 10) || (ActivePlans >= 2) || (cMyCulture == cCultureAtlantean) && (ActivePlans > 0))
    return;
	
    //Build a farm near our main base
    int farmBuildPlan = aiPlanCreate("Build main base farm", cPlanBuild);
    if (farmBuildPlan >= 0)
    {
        aiPlanSetInitialPosition(farmBuildPlan, backLocation);
        aiPlanSetVariableInt(farmBuildPlan, cBuildPlanBuildingTypeID, 0, cUnitTypeFarm);
        aiPlanSetVariableInt(farmBuildPlan, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetDesiredPriority(farmBuildPlan, 100);
		
		//Try to favor the placement around the TC first.
		aiPlanSetVariableInt(farmBuildPlan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeAbstractSettlement); 
        aiPlanSetVariableFloat(farmBuildPlan, cBuildPlanInfluenceUnitDistance, 0, 40);    
		aiPlanSetVariableFloat(farmBuildPlan, cBuildPlanInfluenceUnitValue, 0, 100.0);
		
        aiPlanSetVariableBool(farmBuildPlan, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(farmBuildPlan, cBuildPlanRandomBPValue, 0, 0.99);
        aiPlanSetVariableVector(farmBuildPlan, cBuildPlanCenterPosition, 0, mainBaseLocation);
        aiPlanSetVariableFloat(farmBuildPlan, cBuildPlanCenterPositionDistance, 0, 25.0);
        aiPlanSetVariableFloat(farmBuildPlan, cBuildPlanBuildingBufferSpace, 0, 0.0);
        aiPlanAddUnitType(farmBuildPlan, cUnitTypeAbstractVillager, 1, 1, 1);
        aiPlanSetEscrowID(farmBuildPlan, cEconomyEscrowID);
        aiPlanSetBaseID(farmBuildPlan, mainBaseID);
        aiPlanSetActive(farmBuildPlan);
	}
}
//==============================================================================
rule makeExtraMarket    //If it takes more than 4 minutes to place our trade market, throw down a local one
inactive
minInterval 1 //starts in cAge3, activated in tradeWithCaravans
{
    xsSetRuleMinIntervalSelf(67);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int mainBaseAreaID = kbAreaGetIDByPosition(mainBaseLocation);
    
    int numMarketsNearMB = getNumUnits(cUnitTypeMarket, cUnitStateAlive, -1, cMyID, mainBaseLocation, 50.0);
    
    if ((gExtraMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gExtraMarketUnitID) <= 0))
    {
        gExtraMarketUnitID = -1;
	}
    
    if (gExtraMarketUnitID == -1)
    {
        if (numMarketsNearMB > 0)
        {
            for (i = 0; < numMarketsNearMB)
            {
                int marketIDNearMB = findUnitByIndex(cUnitTypeMarket, i, cUnitStateAlive, -1, cMyID, mainBaseLocation, 50.0);
                if (marketIDNearMB == -1)
				continue;
				
                if (marketIDNearMB == gTradeMarketUnitID)
				continue;
                
                if ((marketIDNearMB == gExtraMarketUnitID) && (kbUnitGetCurrentHitpoints(marketIDNearMB) > 0))
                {
                    continue;
				}
                else
                {
                    gExtraMarketUnitID = marketIDNearMB;
				}
				
			}
		}
	}
    
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive);
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeMarket) && (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanAreaID, 0) == mainBaseAreaID))
            return;
		}
	}
	
    if ((numMarkets > 1) || (numMarkets > 0) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0) || (kbBaseGetNumberUnits(cMyID, mainBaseID, -1, cUnitTypeMarket) > 0))
    return;

    // Time has expired, add another market.
    int marketPlanID = aiPlanCreate("BuildNearbyMarket", cPlanBuild);
    if (marketPlanID >= 0)
    {
        aiPlanSetVariableInt(marketPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeMarket);
        aiPlanSetVariableInt(marketPlanID, cBuildPlanNumAreaBorderLayers, 0, 2);
        aiPlanSetVariableInt(marketPlanID, cBuildPlanAreaID, 0, mainBaseAreaID);  
        //Put it way in the back.
        vector backVector=kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
        float x = xsVectorGetX(backVector);
        float z = xsVectorGetZ(backVector);
        x = x * 60.0;
        z = z * 60.0;
        backVector = xsVectorSetX(backVector, x);
        backVector = xsVectorSetZ(backVector, z);
        backVector = xsVectorSetY(backVector, 0.0);
        vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
        location = location + backVector;		
        aiPlanSetVariableVector(marketPlanID, cBuildPlanInfluencePosition, 0, location);
        aiPlanSetVariableFloat(marketPlanID, cBuildPlanInfluencePositionDistance, 0, 45.0);
        aiPlanSetVariableFloat(marketPlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
        aiPlanSetDesiredPriority(marketPlanID, 100);
        aiPlanAddUnitType(marketPlanID, cBuilderType, 1, 1, 1);
        aiPlanSetEscrowID(marketPlanID, cEconomyEscrowID);
        aiPlanSetBaseID(marketPlanID, mainBaseID);
        aiPlanSetActive(marketPlanID);
        gExtraMarket = true; // Set the global so we know to look for SECOND market before trading.
        xsSetRuleMinIntervalSelf(67);
	}
}
// moved from Extra, expansion stuff etc

//==============================================================================
// buildGarden // Stolen from the Expansion. ):
//==============================================================================
rule buildGarden
minInterval 11
inactive
{
	if (kbUnitCount(cMyID, cUnitTypeGarden, cUnitStateBuilding) > 0)
	return;
	
	//If we already have gGardenBuildLimit gardens, we shouldn't build anymore.
	if (gGardenBuildLimit != -1)
	{
		int numberOfGardens = kbUnitCount(cMyID, cUnitTypeGarden, cUnitStateAliveOrBuilding);
		if (numberOfGardens >= gGardenBuildLimit)
		return;
	}
	//If we already have a garden plan active, skip.
	if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeGarden) > -1)
	return;
	
	//Over time, we will find out what areas are good and bad to build in.  Use that info here, because we want to protect houses.
	int planID = aiPlanCreate("BuildGarden", cPlanBuild);
	if (planID >= 0)
	{
		aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeGarden);
		aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
		aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
		aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
		aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
		aiPlanSetDesiredPriority(planID, 100);
		aiPlanAddUnitType(planID, cBuilderType, 1, 1, 1);
		aiPlanSetEscrowID(planID, cEconomyEscrowID);
		
		vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
		
		float x = xsVectorGetX(backVector);
		float z = xsVectorGetZ(backVector);
		x = x * 40.0;
		z = z * 40.0;
		
		backVector = xsVectorSetX(backVector, x);
		backVector = xsVectorSetZ(backVector, z);
		backVector = xsVectorSetY(backVector, 0.0);
		vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
		int areaGroup1 = kbAreaGroupGetIDByPosition(location);   // Base area group
		location = location + backVector;
		int areaGroup2 = kbAreaGroupGetIDByPosition(location);   // Back vector area group
		if (areaGroup1 != areaGroup2)
		location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));   // Reset to area center if back is in wrong area group
		
		aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
		aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 20.0);
		aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 1.0);		
		aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
		aiPlanSetActive(planID);
	}
}

//==============================================================================
// Rule: ChooseGardenResource
//==============================================================================
rule ChooseGardenResource
minInterval 20
inactive
{
    float FoodSupply = kbResourceGet(cResourceFood);
    float WoodSupply = kbResourceGet(cResourceWood); 
	float GoldSupply = kbResourceGet(cResourceGold);
    float MyFavor = kbResourceGet(cResourceFavor); 
	
	int res  = cResourceGold;
	string resname = "Gold";
	
	if ((aiGetCurrentResourceNeed(cResourceGold) < aiGetCurrentResourceNeed(cResourceWood)) || (WoodSupply < 200) && (GoldSupply > 200))
	{
		res	 = cResourceWood;
		resname = "Wood";
	}
	
    if (FoodSupply < 250)
	{
		res  = cResourceFood;
		resname = "Food";
	}
	
	if (MyFavor < 60 && FoodSupply > 400 && WoodSupply > 300 && GoldSupply > 400)
	{
		res  = cResourceFavor;
		resname = "Favor";
	}
	
	if (MyFavor < 30 && FoodSupply > 250)
	{
		res  = cResourceFavor;
		resname = "Favor";
	}
	
	if ((FoodSupply > 500) && (WoodSupply > 400) && (GoldSupply > 400) && (MyFavor > 60))
	{  	
		int choice = 0;
		if (WoodSupply > GoldSupply)
		choice = 1;
	
		switch(choice)
		{
			case 0:  // Wood
			{
				res  = cResourceWood;
				resname = "Wood";
			}
			case 1:  // Gold
			{
				res  = cResourceGold;
				resname = "Gold";
			}	
		}
	}	
	kbSetGardenResource(res);
}		

//==============================================================================	
rule WallAllyMB  // now does the opposite and walls up all non Mainbases for players.
minInterval 25
inactive
{ 
	
    if (gTransportMap == true)
	{
		xsDisableSelf();
		return;
	}
	if (aiGetCaptainPlayerID(cMyID) != cMyID)
    return;
    int alliedBaseUnitID = -1;
	int MBalliedBaseUnitID = -1;
    xsSetRuleMinIntervalSelf(20);
	//If we already have a build wall plan, don't make another one.
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);
    float goldSupply = kbResourceGet(cResourceGold);
	
    if (activeWallPlans > 0)
    {
		for (i = 0; < activeWallPlans)
		{
			int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
			if (wallPlanIndexID == WallAllyPlanID)
			{
				static int WallAllyStartTime = -1;
				if (WallAllyStartTime < 0)
				WallAllyStartTime = xsGetTime();
				
				if (goldSupply < 50)
				{
					aiPlanDestroy(wallPlanIndexID);
					WallAllyStartTime = -1;
					xsSetRuleMinIntervalSelf(20);
					return;
				}
				//destroy the plan if it has been active for more than 12 minutes
				if ((xsGetTime() > (WallAllyStartTime + 12*60*1000)))
				{
					aiPlanDestroy(wallPlanIndexID);
					WallAllyStartTime = -1;
					xsSetRuleMinIntervalSelf(30);
					return;
				}
				
                vector location = aiPlanGetLocation(wallPlanIndexID);
				int TheirTC = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cPlayerRelationAlly, location, 50.0);
				int myTc = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID, location, 50.0);
				int TcsThere = 0 + TheirTC + myTc;
				
                //Destroy the plan if there are twice as many enemies as my units 
                if (TcsThere < 1)
                {
                    aiPlanDestroy(wallPlanIndexID);
					WallAllyStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
					return;
			    }				
				return;
			}
		}
	}	
	
	int Villagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
	if ((cMyCulture == cCultureAtlantean) || (aiGetWorldDifficulty() > cDifficultyHard))
	Villagers = Villagers * 3;
    if ((Villagers < 18) || (kbGetAge() < cAge2) || (xsGetTime() < 10*60*1000) || (aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 10*60*1000))
    return;	
	
	static int lastTargetPlayerIDSaveTime = -1;
    static int lastTargetPlayerID = -1;
    static bool increaseStartIndex = false;
	
    static int startIndex = -1;
    if (increaseStartIndex == true)
    {
		if (startIndex >= cNumberPlayers - 1)
		startIndex = 0;
		else
		startIndex = startIndex + 1;
		increaseStartIndex = false;
	}
    
    if ((startIndex < 0) || (xsGetTime() > lastTargetPlayerIDSaveTime + (1)*1*1000))
    {
		startIndex = aiRandInt(cNumberPlayers);
	}
	
    int comparePlayerID = -1;
    for (i = 0; < cNumberPlayers)
    {
		//If we're past the end of our players, go back to the start.
		int actualIndex = i + startIndex;
		if (actualIndex >= cNumberPlayers)
		actualIndex = actualIndex - cNumberPlayers;
		if ((actualIndex <= 0) || (actualIndex == cMyID))
		continue;
		if ((kbIsPlayerAlly(actualIndex) == true) && 
		(kbIsPlayerResigned(actualIndex) == false) && 
		(kbIsPlayerHuman(actualIndex) == true) && 
		(kbHasPlayerLost(actualIndex) == false))
		{
			comparePlayerID = actualIndex;
			if (actualIndex == lastTargetPlayerID)
			{
				increaseStartIndex = true;
				continue;
			}
			break;
		}
	}
    int actualPlayerID = comparePlayerID;
    if (actualPlayerID != lastTargetPlayerID)
    {
		lastTargetPlayerID = actualPlayerID;
		lastTargetPlayerIDSaveTime = xsGetTime();
	}
	
    if (actualPlayerID != -1)
    {
		alliedBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, actualPlayerID);
		MBalliedBaseUnitID = getMainBaseUnitIDForPlayer(actualPlayerID);
		vector otherBaseLocation = kbUnitGetPosition(alliedBaseUnitID);
	}
	if ((kbIsPlayerHuman(actualIndex) == false) || (alliedBaseUnitID == MBalliedBaseUnitID) || (goldSupply < 160) || (alliedBaseUnitID == -1))
	return;
	
    int radius = 19;
    static int count = 1;

    string Readable = "OtherWallAllyPlanID"+count;
	WallAllyPlanID = createCommonRingWallPlan(Readable, alliedBaseUnitID, radius, true);		
	xsSetRuleMinIntervalSelf(25);
	count = count + 1;
}

//==============================================================================
rule rebuildSiegeCamp
inactive
minInterval 37 
{
    int mainBaseID = kbBaseGetMainID(cMyID);
    int numSiegeCamps = kbUnitCount(cMyID, cUnitTypeSiegeCamp, cUnitStateAliveOrBuilding);
    
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
		for (i = 0; < activeBuildPlans)
		{
			int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
			if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeSiegeCamp)
			{
				return;
			}
		}
	}
	
    if ((numSiegeCamps > 0) || (kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive) < 10) || (kbResourceGet(cResourceGold) < 250))
    {
		return;
	}
	
    int RebuildSiegeCamp = aiPlanCreate("RebuildSiegeCamp", cPlanBuild);
    if (RebuildSiegeCamp >= 0)
    {
		aiPlanSetVariableInt(RebuildSiegeCamp, cBuildPlanBuildingTypeID, 0, cUnitTypeSiegeCamp);      
		aiPlanSetDesiredPriority(RebuildSiegeCamp, 100);
		aiPlanAddUnitType(RebuildSiegeCamp, cBuilderType, 1, 1, 1);
		aiPlanSetEscrowID(RebuildSiegeCamp, cMilitaryEscrowID);
		aiPlanSetBaseID(RebuildSiegeCamp, mainBaseID);
		aiPlanSetActive(RebuildSiegeCamp);
	}
}	

//==============================================================================
rule SupportUnits
minInterval 10 //starts in cAge3
group Forwarding
inactive
{
	if (gTransportMap == true)
    {
		xsDisableSelf();
		return;
	}
	
	int currentPop = kbGetPop();           
    int currentPopCap = kbGetPopCap();
	int ActivePlans = findPlanByString("SupportUnits", cPlanBuild, -1, true, true);
	if (gGlutRatio > 0.80)
	xsSetRuleMinIntervalSelf(3);
    else
	xsSetRuleMinIntervalSelf(10);	
	
	if ((currentPop <= currentPopCap*0.5) && (ActivePlans > 0) || (ActivePlans > 0) && (kbResourceGet(cResourceGold) < 250) 
	|| (ActivePlans > 0) && (kbResourceGet(cResourceWood) < 250) && (cMyCulture != cCultureEgyptian))
	{
        for (l = 0; < ActivePlans)
		{
            int StalledPlanID = findPlanByString("SupportUnits", cPlanBuild);
            if (StalledPlanID != -1)
            aiPlanDestroy(StalledPlanID);
		}
		xsSetRuleMinIntervalSelf(35);
		return;
	}
	
    if ((ActivePlans >= 3) || (kbResourceGet(cResourceGold) < 800) || (kbCanAffordUnit(cUnitTypeTower, cMilitaryEscrowID) == false)
	|| (kbResourceGet(cResourceWood) < 400) && (cMyCulture != cCultureEgyptian) || (kbResourceGet(cResourceFood) < 800) || (kbResourceGet(cResourceFavor) < 5))
	return;  // Quit if we're already building one or not enough resources

	for (d = 0; < 2)
	{
        bool Success = false;
        int Building = MyFortress;
	    int Rand = aiRandInt(2);
	    if ((cMyCulture == cCultureAtlantean) && (kbGetTechStatus(cTechAge4Helios) == cTechStatusActive))
	    Rand = aiRandInt(3);
	    if (Rand == 0)
	    Building = cUnitTypeTower;
	    else if (Rand == 2)
	    Building = cUnitTypeTowerMirror;
        
		int UnitToUse = cUnitTypeMilitary;
		if (d == 1)
		UnitToUse = cUnitTypeBuildingsThatShoot;
		int unitID = findUnit(UnitToUse, cUnitStateAlive, cActionRangedAttack, cMyID);
		if (unitID == -1)
		continue;
	
		vector unitLoc = kbUnitGetPosition(unitID);
		int mainBaseID = kbBaseGetMainID(cMyID);
		vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
		float distanceToMainBase = xsVectorLength(mainBaseLocation - unitLoc);
		
		int MyUnits = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationSelf, unitLoc, 45.0, true);
		int AllyUnits = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, unitLoc, 45.0, true);
		int EnemyUnits = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, unitLoc, 35.0, true);
		int EnemyShoots = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, unitLoc, 45.0, true);
		int MBTShoots = getNumUnitsByRel(cUnitTypeTower, cUnitStateAlive, -1, cPlayerRelationSelf, mainBaseLocation, 55.0, true);
		int MBFShoots = getNumUnitsByRel(MyFortress, cUnitStateAlive, -1, cPlayerRelationSelf, mainBaseLocation, 55.0, true);
		int ShootersThere = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationSelf, unitLoc, 50.0, true);
		if ((EnemyUnits+EnemyShoots < 4) || (MyUnits+AllyUnits < EnemyUnits) || (distanceToMainBase < 50) || (ShootersThere >= 8))
		continue;
		
		if ((kbUnitCount(cMyID, Building, cUnitStateAliveOrBuilding) >= kbGetBuildLimit(cMyID, Building)) || (d == 1) && (kbUnitCount(cMyID, Building, cUnitStateAliveOrBuilding)+1 >= kbGetBuildLimit(cMyID, Building)))
		{ 
			int UnitsFound = getNumUnits(Building, cUnitStateAlive, cActionIdle, cMyID);
			for (i=0; < UnitsFound)
			{
				int doomedID = findUnitByIndex(Building, i, cUnitStateAlive, cActionIdle, cMyID);
				vector Candidate = kbUnitGetPosition(doomedID);
				float DistanceFromMB = xsVectorLength(mainBaseLocation - Candidate);
				float DistanceFromUToLoc = xsVectorLength(unitLoc - Candidate);
				int Market = findClosestUnitTypeByLoc(cPlayerRelationSelf, cUnitTypeMarket, cUnitStateAliveOrBuilding, Candidate, 30);
				int MarketTowers = 0;
				int MyTC = findClosestUnitTypeByLoc(cPlayerRelationSelf, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, Candidate, 35);
				int TowerTHere = 0;
				if (MyTC != -1)
				TowerTHere = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAliveOrBuilding, -1, cMyID, kbUnitGetPosition(MyTC), 25.0);
			    if (Market != -1)
				MarketTowers = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAliveOrBuilding, -1, cMyID, kbUnitGetPosition(Market), 25.0);
			
				if ((Building == cUnitTypeTower) && (DistanceFromMB < 55) && (MBTShoots <= 6) || (Building == MyFortress) && (DistanceFromMB < 55) && (MBFShoots <= 4) 
				|| (DistanceFromUToLoc < 45) || (Market != -1) && (MarketTowers <= 2)|| (MyTC != -1) && (TowerTHere < 2))
				continue;
				if (doomedID != -1)
				{
					aiTaskUnitDelete(doomedID);
					Success = true;
					break;
				}
			}
		}
		else 
		Success = true;
		
		if (Success == false)
		continue;
		
		int numBuilders = 2;
		if (cMyCulture == cCultureAtlantean)
		numBuilders = 1;
		else if (gGlutRatio < 0.5)
		numBuilders = 1;
		
		//Build near our UnitLoc
		
		int TowerAroundAttUnitPlan = aiPlanCreate("SupportUnits", cPlanBuild);
		if (TowerAroundAttUnitPlan >= 0)
		{
			aiPlanSetInitialPosition(TowerAroundAttUnitPlan, unitLoc);
			aiPlanSetVariableInt(TowerAroundAttUnitPlan, cBuildPlanBuildingTypeID, 0, Building);
			aiPlanSetVariableInt(TowerAroundAttUnitPlan, cBuildPlanMaxRetries, 0, 10);
			aiPlanSetDesiredPriority(TowerAroundAttUnitPlan, 100);
			
			//Try to favor the placement around the Unit first.
			aiPlanSetVariableInt(TowerAroundAttUnitPlan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeMilitary); 
			aiPlanSetVariableFloat(TowerAroundAttUnitPlan, cBuildPlanInfluenceUnitDistance, 0, 35);    
			aiPlanSetVariableFloat(TowerAroundAttUnitPlan, cBuildPlanInfluenceUnitValue, 0, 100.0);   
			aiPlanSetVariableVector(TowerAroundAttUnitPlan, cBuildPlanInfluencePosition, 0, unitLoc);
			aiPlanSetVariableFloat(TowerAroundAttUnitPlan, cBuildPlanInfluencePositionDistance, 0, 30);  
			aiPlanSetVariableFloat(TowerAroundAttUnitPlan, cBuildPlanInfluencePositionValue, 0, 30.0);       
			
			aiPlanSetVariableBool(TowerAroundAttUnitPlan, cBuildPlanInfluenceAtBuilderPosition, 0, true);
			aiPlanSetVariableFloat(TowerAroundAttUnitPlan, cBuildPlanRandomBPValue, 0, 0.99);
			aiPlanSetVariableVector(TowerAroundAttUnitPlan, cBuildPlanCenterPosition, 0, unitLoc);
			aiPlanSetVariableFloat(TowerAroundAttUnitPlan, cBuildPlanCenterPositionDistance, 0, 14.00);
			aiPlanSetVariableFloat(TowerAroundAttUnitPlan, cBuildPlanBuildingBufferSpace, 0, 4.0);

			aiPlanAddUnitType(TowerAroundAttUnitPlan, cBuilderType, numBuilders, numBuilders, numBuilders);
			aiPlanSetEscrowID(TowerAroundAttUnitPlan, cEconomyEscrowID);
			aiPlanAddUserVariableInt(TowerAroundAttUnitPlan, 0, "Ignore Me", 1);
			aiPlanSetUserVariableInt(TowerAroundAttUnitPlan, 0, 0, 250);
			aiPlanSetActive(TowerAroundAttUnitPlan);
		}
	}	
}

//==============================================================================
rule BunkerUpThatWonder
minInterval 5 
inactive
{	
    if (kbGetAge() < cAge2)
	return;

	xsSetRuleMinIntervalSelf(22+aiRandInt(8));
	int WonderUnitID = -1;
	int WonderType = cUnitTypeWonder;
	int ResNeeded = 200;
	vector WonderLoc = cInvalidVector;
	if ((cRandomMapName == "king of the hill") && (KoTHWaterVersion == false))
	{
		WonderUnitID = gKOTHPlentyUnitID;
		WonderType = cUnitTypePlentyVaultKOTH;
		WonderLoc = KOTHGlobal;
		ResNeeded = 400;
	}
    else
	{
	    int WonderPlanID = findPlanByString("Ally Wonder Defend Plan", cPlanDefend);
	    if (WonderPlanID < 0)
	    return;
	    WonderLoc = aiPlanGetLocation(WonderPlanID);
	}
   
	WonderUnitID = findUnitByRel(WonderType, cUnitStateAliveOrBuilding, -1, cPlayerRelationAlly, WonderLoc, 75);
	if (WonderUnitID < 0)
    WonderUnitID = findUnitByRel(WonderType, cUnitStateAliveOrBuilding, -1, cPlayerRelationSelf, WonderLoc, 75);	
	if (WonderUnitID < 0)
	return;		
     
	vector location = kbUnitGetPosition(WonderUnitID);
	
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
    if ((woodSupply < ResNeeded) || (goldSupply < ResNeeded))
	return;
    
    int Building = cUnitTypeTower;
    int numBuilders = 2;
	if (cMyCulture == cCultureAtlantean)
	numBuilders = 1;
	
    int numBuildingNearBase = getNumUnits(Building, cUnitStateAliveOrBuilding, -1, cMyID, location, 75.0);
	
    if (numBuildingNearBase >= 2)
    {
        if (cMyCulture != cCultureAtlantean)
		numBuilders = 4;
		Building = MyFortress;
	    numBuildingNearBase = getNumUnits(Building, cUnitStateAliveOrBuilding, -1, cMyID, location, 75.0);	
		if (numBuildingNearBase > 1)
		return;
	}
	
	
    if (findPlanByString("BunkerUpthatWonder", cPlanBuild) != -1)
	return;
	
    //Force building #1 to go down.
    int BunkerUpWonder = aiPlanCreate("BunkerUpthatWonder", cPlanBuild);
    if (BunkerUpWonder >= 0)
    {
        aiPlanSetVariableInt(BunkerUpWonder, cBuildPlanBuildingTypeID, 0, Building);
        aiPlanSetVariableBool(BunkerUpWonder, cBuildPlanInfluenceAtBuilderPosition, 0, false);
		aiPlanSetVariableInt(BunkerUpWonder, cBuildPlanMaxRetries, 0, 5);
        aiPlanSetVariableFloat(BunkerUpWonder, cBuildPlanRandomBPValue, 0, 0.99);
        aiPlanSetVariableVector(BunkerUpWonder, cBuildPlanCenterPosition, 0, location);
		aiPlanSetVariableInt(BunkerUpWonder, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeBuildingsThatShoot); 
		aiPlanSetVariableFloat(BunkerUpWonder, cBuildPlanInfluenceUnitDistance, 0, 12);    
		aiPlanSetVariableFloat(BunkerUpWonder, cBuildPlanInfluenceUnitValue, 0, -20.0);
        aiPlanSetVariableFloat(BunkerUpWonder, cBuildPlanCenterPositionDistance, 0, 20.0);
        aiPlanSetVariableFloat(BunkerUpWonder, cBuildPlanBuildingBufferSpace, 0, 10.0);
        aiPlanSetDesiredPriority(BunkerUpWonder, 100);
        aiPlanAddUnitType(BunkerUpWonder, cBuilderType, numBuilders, numBuilders, numBuilders);
        aiPlanSetEscrowID(BunkerUpWonder, cMilitaryEscrowID);
        aiPlanSetActive(BunkerUpWonder);
	}
}

//==============================================================================
rule TowerUpMarket
minInterval 60 
inactive
{	
	xsSetRuleMinIntervalSelf(39+aiRandInt(16));
	int ResNeeded = 50;
	
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
	int ActivePlan = findPlanByString("Build trade market tower", cPlanBuild);
	vector location = kbUnitGetPosition(gTradeMarketUnitID);
	int numTowersNearMarket = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAliveOrBuilding, -1, cMyID, gTradeMarketLocation, 40.0);
	int AlliedTowers = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAliveOrBuilding, -1, cPlayerRelationAlly, gTradeMarketLocation, 40.0);
	if (AlliedTowers > 0 )
	numTowersNearMarket = numTowersNearMarket + AlliedTowers;

	if (numTowersNearMarket > 0)
	ResNeeded = 600;
    if ((woodSupply < ResNeeded) && (cMyCulture != cCultureEgyptian) || (goldSupply < ResNeeded) || (ActivePlan != -1) || (gTradeMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0) || 
	(gTradeMarketUnitID == -1) || (numTowersNearMarket >= 2))
	return;
	
	//Build a tower or fortress near our trade market
	int buildTowerPlanID = aiPlanCreate("Build trade market tower", cPlanBuild);
	if (buildTowerPlanID >= 0)
	{
        int Building = cUnitTypeTower;
		if ((aiRandInt(5) < 1) && (kbCanAffordUnit(MyFortress, cEconomyEscrowID) == true) && (kbUnitCount(cMyID, MyFortress, cUnitStateAny) < 7))
		Building = MyFortress;
		aiPlanSetVariableInt(buildTowerPlanID, cBuildPlanBuildingTypeID, 0, Building);
		aiPlanSetDesiredPriority(buildTowerPlanID, 100);
		aiPlanSetVariableVector(buildTowerPlanID, cBuildPlanCenterPosition, 0, location);
		aiPlanSetVariableInt(buildTowerPlanID, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeBuildingsThatShoot); 
		aiPlanSetVariableFloat(buildTowerPlanID, cBuildPlanInfluenceUnitDistance, 0, 10);    
        aiPlanSetVariableFloat(buildTowerPlanID, cBuildPlanCenterPositionDistance, 0, 10.0);
        aiPlanSetVariableFloat(buildTowerPlanID, cBuildPlanBuildingBufferSpace, 0, 12.0); 
        aiPlanSetVariableFloat(buildTowerPlanID, cBuildPlanInfluenceUnitValue, 0, -12.0);        // -18 points per tower
        // Weight it to stay very close to center point.
        aiPlanSetVariableVector(buildTowerPlanID, cBuildPlanInfluencePosition, 0, location);    // Position influence for landing position
        aiPlanSetVariableFloat(buildTowerPlanID, cBuildPlanInfluencePositionDistance, 0, 12);     // 100m range.
		aiPlanSetVariableFloat(buildTowerPlanID, cBuildPlanInfluencePositionValue, 0, 10.0);        // 10 points for center			
		
		
		aiPlanAddUnitType(buildTowerPlanID, cBuilderType, 1, 1, 1);
		aiPlanSetEscrowID(buildTowerPlanID, cEconomyEscrowID);
		aiPlanSetActive(buildTowerPlanID);
	}
}

//==============================================================================
rule ExtraBuildings
minInterval 18 //starts in cAge3
group Forwarding
inactive
{
	if (gTransportMap == true)
    {
		xsDisableSelf();
		return;
	}
	
	int currentPop = kbGetPop();           
    int currentPopCap = kbGetPopCap();
	int ActivePlans = findPlanByString("ExtraBuildings", cPlanBuild, -1, true, true);
	if (gGlutRatio > 0.25) 
	xsSetRuleMinIntervalSelf(7);
    else
	xsSetRuleMinIntervalSelf(15);	
	
	if ((currentPop <= currentPopCap*0.5) && (ActivePlans > 0) || (ActivePlans > 0) && (kbResourceGet(cResourceGold) < 150) 
	|| (ActivePlans > 0) && (kbResourceGet(cResourceWood) < 150) && (cMyCulture != cCultureEgyptian))
	{
        for (l = 0; < ActivePlans)
		{
            int StalledPlanID = findPlanByString("ExtraBuildings", cPlanBuild);
            if (StalledPlanID != -1)
            aiPlanDestroy(StalledPlanID);
		}
		xsSetRuleMinIntervalSelf(35);
		return;
	}
	
	int Building1 = kbTechTreeGetUnitIDByTrain(kbUnitPickGetResult(gLateUPID, 0), cMyCiv);
	int Building2 = kbTechTreeGetUnitIDByTrain(kbUnitPickGetResult(gLateUPID, 1), cMyCiv);
	if (cMyCulture == cCultureNorse)
	{
        if (Building1 == cUnitTypeSettlementLevel1)
	    Building1 = cUnitTypeLonghouse;
        if (Building2 == cUnitTypeSettlementLevel1)
	    Building2 = cUnitTypeLonghouse;
	}
	else if (cMyCulture == cCultureEgyptian)
	{
        if (Building1 == cUnitTypePharaoh)
	    Building1 = MyFortress;
        if (Building2 == cUnitTypePharaoh)
	    Building2 = MyFortress;
	}

	if ((ActivePlans >= 2) || (kbCanAffordUnit(Building1, cMilitaryEscrowID) == false) || (kbCanAffordUnit(Building2, cMilitaryEscrowID) == false)
    || (kbResourceGet(cResourceGold) < 400) || (kbResourceGet(cResourceWood) < 350) && (cMyCulture != cCultureEgyptian) 
	|| (kbResourceGet(cResourceFood) < 400) || (kbResourceGet(cResourceFavor) < 5))
	return;  // Quit if we're already building one or not enough resources
		
	bool SkipB1 = false;
	bool SkipB2 = false;
	bool FortressCapped = false;
	if (kbUnitCount(cMyID, MyFortress, cUnitStateAliveOrBuilding)+1 >= kbGetBuildLimit(cMyID, MyFortress))
	FortressCapped = true;
	if ((Building1 == MyFortress) && (FortressCapped == true))
    SkipB1 = true;
	if ((Building2 == MyFortress) && (FortressCapped == true))
    SkipB2 = true;

	for (d = 0; < 1)
	{
		int UnitToUse = cUnitTypeMilitary;
		int unitID = findUnit(UnitToUse, cUnitStateAlive, cActionRangedAttack, cMyID);
		if (unitID == -1)
		continue;
		
		vector unitLoc = kbUnitGetPosition(unitID);
		int mainBaseID = kbBaseGetMainID(cMyID);
		vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
		float distanceToMainBase = xsVectorLength(mainBaseLocation - unitLoc);
		int ChosenBuilding = -1;
		int MyUnits = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationSelf, unitLoc, 45.0, true);
		int AllyUnits = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, unitLoc, 45.0, true);
		int EnemyUnits = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, unitLoc, 35.0, true);
		int EnemyShoots = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, unitLoc, 45.0, true);
		int TrainBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsThatTrainMilitary, cUnitStateAliveOrBuilding, -1, cPlayerRelationSelf, unitLoc, 50.0, true);
		if ((EnemyUnits+EnemyShoots < 4) || (MyUnits+AllyUnits < EnemyUnits) || (distanceToMainBase < 75) || (TrainBuildings >=4))
		continue;
		
		if ((getNumUnits(Building1, cUnitStateAliveOrBuilding, -1, cMyID, unitLoc, 50) < 2) && (SkipB1 == false))
		ChosenBuilding = Building1;
	    else if ((getNumUnits(Building2, cUnitStateAliveOrBuilding, -1, cMyID, unitLoc, 50) < 1) && (SkipB2 == false))
		ChosenBuilding = Building2;
		else if (getNumUnits(cUnitTypeTemple, cUnitStateAliveOrBuilding, -1, cMyID, unitLoc, 50) < 1)
	    ChosenBuilding = cUnitTypeTemple;

		if (ChosenBuilding == -1)
		return;	
		
		int numBuilders = 2;
		if (cMyCulture == cCultureAtlantean)
		numBuilders = 1;
		
		if (gGlutRatio < 0.2)
		numBuilders = 1;
		
		//Build near our UnitLoc
		
		int MilBuildingThatTrains = aiPlanCreate("ExtraBuildings", cPlanBuild);
		if (MilBuildingThatTrains >= 0)
		{
			aiPlanSetInitialPosition(MilBuildingThatTrains, unitLoc);
			aiPlanSetVariableInt(MilBuildingThatTrains, cBuildPlanBuildingTypeID, 0, ChosenBuilding);
			aiPlanSetVariableInt(MilBuildingThatTrains, cBuildPlanMaxRetries, 0, 10);
			aiPlanSetVariableBool(MilBuildingThatTrains, cBuildPlanInfluenceAtBuilderPosition, 0, false);
			aiPlanSetVariableFloat(MilBuildingThatTrains, cBuildPlanRandomBPValue, 0, 0.99);
			
			aiPlanSetVariableVector(MilBuildingThatTrains, cBuildPlanCenterPosition, 0, unitLoc);
			aiPlanSetVariableFloat(MilBuildingThatTrains, cBuildPlanCenterPositionDistance, 0, 11.0);
			aiPlanSetVariableFloat(MilBuildingThatTrains, cBuildPlanBuildingBufferSpace, 0, 12.0); //0
			aiPlanSetVariableInt(MilBuildingThatTrains, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeTree); 
			aiPlanSetVariableFloat(MilBuildingThatTrains, cBuildPlanInfluenceUnitDistance, 0, 10);    
			aiPlanSetVariableFloat(MilBuildingThatTrains, cBuildPlanInfluenceUnitValue, 0, -20.0);        // -20 points per unit
			// Weight it to stay very close to center point.
			aiPlanSetVariableVector(MilBuildingThatTrains, cBuildPlanInfluencePosition, 0, unitLoc);    // Position influence for landing position				
			
			aiPlanSetDesiredPriority(MilBuildingThatTrains, 100);
			aiPlanAddUnitType(MilBuildingThatTrains, cBuilderType, numBuilders, numBuilders, numBuilders);
			aiPlanSetEscrowID(MilBuildingThatTrains, cMilitaryEscrowID);
			aiPlanSetBaseID(MilBuildingThatTrains, kbBaseGetMainID(cMyID));
			aiPlanSetActive(MilBuildingThatTrains);
		}		
	}
}