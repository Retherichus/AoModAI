//==============================================================================
// AoMod AI
// AoModAINaval.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// Handles naval behavior.
//==============================================================================
//==============================================================================
void navalAge2Handler(int age=1)
{
    // Naval (scout other islands etc...)
    if (gTransportMap == true)
    {
        xsEnableRuleGroup("NavalClassical");
	    xsEnableRule("PurgeLostEcoUnits");			
	}
    
    if ((cRandomMapName == "anatolia") // TODO: maybe on (cRandomMapName == "highlands") too?
	|| (cRandomMapName == "mediterranean")
	|| (cRandomMapName == "king of the hill") && (KoTHWaterVersion == true)
	|| (cRandomMapName == "sea of worms") 
	|| (cRandomMapName == "midgard"))
	{
		xsEnableRule("NavalGoalMonitor");
		xsEnableRule("WaterDefendPlan");
		xsEnableRule("getHeroicFleet");
	}
	
}

//==============================================================================
void navalAge3Handler(int age=2)
{
    // Naval (build settlements on other islands etc...)
    if (gTransportMap == true)
    xsEnableRuleGroup("NavalHeroic");
}

//==============================================================================
void navalAge4Handler(int age=3)
{
	if (gNavalUPID != -1)
	kbUnitPickSetDesiredNumberUnitTypes(gNavalUPID, 3, 3, true);
}

//==============================================================================
rule findOtherSettlements
minInterval 26 //starts in cAge3
group NavalHeroic
inactive
{
	static int bStartTime = -1;
	static int Attempts = 0;
	int TotalBuilders = kbUnitCount(cMyID, cBuilderType, cUnitStateAlive);
	if (cMyCulture == cCultureAtlantean)
	TotalBuilders = TotalBuilders * 2;
    else if ((cMyCulture == cCultureNorse) && (TotalBuilders >= 3))
	TotalBuilders = 10; // fake it
    
	
	int ActivePlans = findPlanByString("Remote Settlement Transport", cPlanTransport, -1, true, true);
	int ActiveBackupPlans = findPlanByString("Backup Remote Settlement", cPlanBuild, -1, true, true);
	if ((ActivePlans >= 1) || (TotalBuilders < 10) || (kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateAlive) < 1) 
	|| (kbResourceGet(cResourceGold) < 500) || (kbResourceGet(cResourceFood) < 200) || (kbResourceGet(cResourceWood) < 400) && (cMyCulture != cCultureEgyptian))
	return;
	
	//Get our initial location.
	vector here=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	
	//Get our start area ID.
	int startAreaID=kbAreaGetIDByPosition(here);
	
	//Find other islands area group.
	vector there = kbUnitGetPosition(findClosestUnitTypeByLoc(cPlayerRelationAny, cUnitTypeSettlement, cUnitStateAliveOrBuilding, here));
	
	// settlement is on my island
	if ((SameAG(there, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) == true) || (equal(there, cInvalidVector) == true))
	return; // no transport needed!
	
	//Create transport plan to get builders to the other island
	// but just do one per detected settlement!
	// therefore remember the pos where we did the transport to
	static vector gTransportToSettlementPos = cInvalidVector;
	
	if ((bStartTime != -1) && (ActiveBackupPlans > 0) && (xsGetTime() - bStartTime > 3*60*1000))
	{
		int ActiveBackupPlanID = findPlanByString("Backup Remote Settlement", cPlanBuild, -1);
		if (ActiveBackupPlanID != -1)
		{
			aiPlanDestroy(ActiveBackupPlanID);
			Attempts = 0;
			gTransportToSettlementPos = cInvalidVector; // reset and try new transport?
		}
	}
	
	// been there, done that
	if (equal(gTransportToSettlementPos, there))
	{
		int NumNeutralTC = NumUnitsOnAreaGroupByRel(true, kbAreaGroupGetIDByPosition(there), cUnitTypeSettlement, 0);	
		int NumBuilder = NumUnitsOnAreaGroupByRel(true, kbAreaGroupGetIDByPosition(there), cBuilderType, cMyID);	
		
		if ((NumBuilder > 0) && (NumNeutralTC >= 1) && (ActiveBackupPlans <= 0))
		{
			int planID=aiPlanCreate("Backup Remote Settlement", cPlanBuild);
			aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeSettlementLevel1);
			aiPlanSetDesiredPriority(planID, 100);
			aiPlanSetEconomy(planID, true);
			aiPlanSetEscrowID(planID, cEconomyEscrowID);
			aiPlanAddUnitType(planID, cBuilderType, 1, 1, NumBuilder);
			aiPlanSetInitialPosition(planID, there);
			aiPlanSetVariableVector(planID, cBuildPlanSettlementPlacementPoint, 0, there);
			aiPlanSetActive(planID);
			bStartTime = xsGetTime();
		}
		if (ActiveBackupPlans <= 0)
		Attempts = Attempts + 1;
		if (Attempts > 4)
		gTransportToSettlementPos = cInvalidVector;	
		return;
	}	
	
	
	claimSettlement(there);
	Attempts = 0;
	// remember the position that we did the transport to.
	gTransportToSettlementPos = there;
}

//==============================================================================
rule NavalGoalMonitor
minInterval 13
group NavalClassical
inactive
{
	//Don't do anything in the first age.
	if ((kbGetAge() < 1) || (aiGetMostHatedPlayerID() < 0))
	return;
    static int reduceCount = 0;
	int ArrowShipMaintain = -1;
    int doomedID = -1;
	
	//See if we have any enemy warships running around.
	int numberEnemyWarships=0;
	//Find the largest warship count for any of our enemies.
	for (i=0; < cNumberPlayers)
	{
		if ((kbIsPlayerEnemy(i) == true) &&
		(kbIsPlayerResigned(i) == false) &&
		(kbHasPlayerLost(i) == false))
		{
			int tempNumberEnemyWarships=kbUnitCount(i, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
			if ( aiGetWorldDifficulty() > cDifficultyModerate )
			{
				tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeUtilityShip, cUnitStateAlive)/2;
			}
			if (tempNumberEnemyWarships > numberEnemyWarships)
			numberEnemyWarships=tempNumberEnemyWarships;
		}
	}
	
	
	int numMyMilShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
	int numAlliedMilShips = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationAlly);
	if ((numMyMilShips + numAlliedMilShips > numberEnemyWarships) && (numMyMilShips > 1))
	reduceCount = reduceCount + 1;
	else
	reduceCount = 0;
	
	if (reduceCount > 9)
	{
		//For now just delete one ship, idle units first    //TODO: create an attack plan to lose ships
		doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, cActionIdle, cMyID);
		if (doomedID < 0)
		doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID);
		aiTaskUnitDelete(doomedID);
		reduceCount = 0;
	}
	
	//Figure out the min/max number of warships we want.
	int minShips=2;
	int maxShips=1;
	if (numberEnemyWarships >= 0)
	{
		//Build at most 2 ships on easy.
		if (aiGetWorldDifficulty() == cDifficultyEasy)
		{
			minShips=1;
			maxShips=2;
		}
		//Build at most "6" ships on moderate.
		else if (aiGetWorldDifficulty() == cDifficultyModerate)
		{
			minShips=numberEnemyWarships/2;
			maxShips=numberEnemyWarships*3/4;
			if (minShips < 1)
            minShips=1;
			if (maxShips < 1)
            maxShips=1;
			if (minShips > 3)
            minShips=3;
			if (maxShips > 6)
            maxShips=6;
		}
		//Build the "same" number (within reason) on Hard/Titan.
		else
		{
			minShips=numberEnemyWarships*3/4;
			maxShips=numberEnemyWarships;
			if (minShips < 1)
            minShips=1;
			if (maxShips < 1)
            maxShips=1;
			if (minShips > 5)
            minShips=5;
			if (maxShips > 8)
            maxShips=8;
		}
	}
	
	//If this is enabled on KOTH, that means we have the water version.  Pretend the enemy
	//has lots of boats so that we will have lots, too.
	if (cvRandomMapName == "king of the hill")
	{
		minShips=6;
		maxShips=12;
	}
	
	//  At 2-3 pop each, don't let this take up most of our military space.
	if ( maxShips > aiGetMilitaryPop()/5 )
	maxShips = aiGetMilitaryPop()/5;
	
	if ( minShips > maxShips)
	minShips = maxShips;
	
	gTargetNavySize = maxShips+2;   // Set the global var for forecasting
	
	//If we already have a Naval UP, just set the numbers and be done.  If we don't
	//want anything, just set 1 since we've already done it before.
	if (gNavalUPID >= 0)
	{
		if (maxShips <= 2)
		{
			kbUnitPickSetMinimumNumberUnits(gNavalUPID, 2);
			kbUnitPickSetMaximumNumberUnits(gNavalUPID, 5);
			kbUnitPickSetMinimumPop(gNavalUPID, 2);
			kbUnitPickSetMaximumPop(gNavalUPID, 10);
		}
		else
		{
			kbUnitPickSetMinimumNumberUnits(gNavalUPID, 2);
			kbUnitPickSetMaximumNumberUnits(gNavalUPID, maxShips);
			kbUnitPickSetMinimumPop(gNavalUPID, minShips);
			kbUnitPickSetMaximumPop(gNavalUPID, maxShips*2);
		}
		return;
	}
	
	//Else, we don't have a Naval attack goal yet.  If we don't want any ships,
	//just return.
	if (maxShips <= 0)
	return;
	
	//Else, create the Naval attack goal.
	gNavalUPID=kbUnitPickCreate("Naval");
	if (gNavalUPID < 0)
	{
		xsDisableSelf();
		return;
	}
	//Fill in the UP.
	kbUnitPickResetAll(gNavalUPID);
	kbUnitPickSetPreferenceWeight(gNavalUPID, 2.0);
	kbUnitPickSetCombatEfficiencyWeight(gNavalUPID, 4.0);
	kbUnitPickSetCostWeight(gNavalUPID, 7.0);
	kbUnitPickSetDesiredNumberUnitTypes(gNavalUPID, 3, 2, true);
	kbUnitPickSetMinimumNumberUnits(gNavalUPID, 1);
	kbUnitPickSetMaximumNumberUnits(gNavalUPID, 3);
	kbUnitPickSetMinimumPop(gNavalUPID, 1);
	kbUnitPickSetMaximumPop(gNavalUPID, 4);	
	kbUnitPickSetAttackUnitType(gNavalUPID, cUnitTypeLogicalTypeNavalMilitary);
	kbUnitPickSetGoalCombatEfficiencyType(gNavalUPID, cUnitTypeLogicalTypeNavalMilitary);
	kbUnitPickSetPreferenceFactor(gNavalUPID, cUnitTypeLogicalTypeNavalMilitary, 1.0);
	kbUnitPickSetMovementType(gNavalUPID, cMovementTypeWater);
	
	//Create the attack goal.
	gNavalAttackGoalID=createSimpleAttackGoal("Naval Attack", -1, gNavalUPID, -1, kbGetAge(), -1, -1, false);
	if (gNavalAttackGoalID < 0)
	{
		xsDisableSelf();
		return;
	}  
	aiPlanSetVariableBool(gNavalAttackGoalID, cGoalPlanAutoUpdateBase, 0, false);
	aiPlanSetVariableBool(gNavalAttackGoalID, cGoalPlanSetAreaGroups, 0, false);
    aiPlanSetNumberVariableValues(gNavalAttackGoalID, cGoalPlanUpgradeBuilding, 1, true);
    aiPlanSetVariableInt(gNavalAttackGoalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeDock);
	
	int ArrowShip = -1;
	if (cMyCulture == cCultureGreek)
	ArrowShip = cUnitTypeTrireme;
	else if (cMyCulture == cCultureEgyptian)
	ArrowShip = cUnitTypeKebenit;
	else if (cMyCulture == cCultureNorse)
	ArrowShip = cUnitTypeLongboat;
	else if (cMyCulture == cCultureAtlantean)
	ArrowShip = cUnitTypeBireme;	
	else if (cMyCulture == cCultureChinese)
	ArrowShip = cUnitTypeJunk;

    if (ArrowShip != -1)
	{
	    ArrowShipMaintain = createSimpleMaintainPlan(ArrowShip, 2, false, kbBaseGetMainID(cMyID));
	    aiPlanSetDesiredPriority(ArrowShipMaintain, 100);
	}
	
	if (gWaterExploreID == -1)
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
}

//==============================================================================
rule WaterDefendPlan
inactive
group NavalClassical
minInterval 18
{
	xsSetRuleMinIntervalSelf(18);
	static int  mWaterDefendPlan = -1;
	int navyUnit = findUnit(cUnitTypeLogicalTypeNavalMilitary);
	int DockUnit = findUnit(cUnitTypeDock);
	int EnemyDock = -1;
	vector WaterVector = aiPlanGetVariableVector(gFishPlanID, cFishPlanWaterPoint, 0);
	vector Dock = kbUnitGetPosition(DockUnit); 
	
	
	if ((mWaterDefendPlan != -1) && (equal(Dock, cInvalidVector) == false))
	{
		aiPlanSetVariableVector(mWaterDefendPlan, cDefendPlanDefendPoint, 0, Dock);
		aiPlanSetInitialPosition(mWaterDefendPlan, WaterVector);
	}
	
	
	if (mWaterDefendPlan != -1)
	{
		int ActiveWaterAttack = findPlanByString("WaterAttack", cPlanAttack, -1);
		if (ActiveWaterAttack != -1)
		{	
			if (aiPlanGetNumberUnits(ActiveWaterAttack, cUnitTypeLogicalTypeNavalMilitary) <= 0)
			{
		        aiPlanDestroy(ActiveWaterAttack);
				xsSetRuleMinIntervalSelf(2);
			    return;
			}
			int planState = aiPlanGetState(ActiveWaterAttack);
			int CurrentPlayer = aiPlanGetVariableInt(ActiveWaterAttack, cAttackPlanPlayerID, 0);
			int EnemyBoats = (kbUnitCount(CurrentPlayer, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive) + kbUnitCount(CurrentPlayer, cUnitTypeDock, cUnitStateAlive) + 
			kbUnitCount(CurrentPlayer, cUnitTypeUtilityShip, cUnitStateAlive));
			if (aiPlanGetNumberUnits(mWaterDefendPlan, cUnitTypeLogicalTypeNavalMilitary) >= 3)
			aiPlanAddUnitType(ActiveWaterAttack, cUnitTypeLogicalTypeNavalMilitary, 0, 200, 200);
			
		    if ((EnemyBoats <= 0) || (planState == cPlanStateNone))
			{
				bool Success = false;
				int startIndex = aiRandInt(cNumberPlayers);
				for (i = 0; < cNumberPlayers)
				{
					//If we're past the end of our players, go back to the start.
					int actualIndex = i + startIndex;
					if (actualIndex >= cNumberPlayers)
					actualIndex = actualIndex - cNumberPlayers;
					if (actualIndex <= 0)
					continue;
					if ((kbIsPlayerEnemy(actualIndex) == true) &&
					(kbIsPlayerResigned(actualIndex) == false) &&
					(kbHasPlayerLost(actualIndex) == false))
					{
						EnemyBoats = (kbUnitCount(actualIndex, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive) + kbUnitCount(actualIndex, cUnitTypeDock, cUnitStateAlive) + 
						kbUnitCount(actualIndex, cUnitTypeUtilityShip, cUnitStateAlive));
						if (EnemyBoats > 0)
						{
							aiPlanSetVariableInt(ActiveWaterAttack, cAttackPlanPlayerID, 0, actualIndex);
							EnemyDock = findUnit(cUnitTypeDock, cUnitStateAlive, -1, actualIndex, cInvalidVector, true);
			                if (EnemyDock == -1)
			                EnemyDock = findUnitByRel(cUnitTypeDock, cUnitStateAlive, -1, cPlayerRelationEnemy, cInvalidVector, -1, true);							
			                if (EnemyDock != -1)
			                aiPlanSetVariableInt(ActiveWaterAttack, cAttackPlanSpecificTargetID, 0, EnemyDock);							
							Success = true;
							break;
						}
					}
					if (Success == true)
					return;
				}
			}
			else if (EnemyBoats > 0)
			return;
		}
		if ((Success == false) && (ActiveWaterAttack != -1))
		{
		    aiPlanDestroy(ActiveWaterAttack);
			xsSetRuleMinIntervalSelf(2);
			return;
		}
		
	    if ((aiPlanGetNumberUnits(mWaterDefendPlan, cUnitTypeLogicalTypeNavalMilitary) >= 3) && (ActiveWaterAttack == -1))
		{
	        vector vectorToUse = kbUnitGetPosition(navyUnit);
			if (equal(WaterVector, cInvalidVector) == false)
			vectorToUse = WaterVector;
		    if (equal(vectorToUse, cInvalidVector) == true)
			return; 
		    int MHP = aiGetMostHatedPlayerID();
			EnemyDock = findUnit(cUnitTypeDock, cUnitStateAlive, -1, MHP, cInvalidVector, true);
			if (EnemyDock == -1)
			EnemyDock = findUnitByRel(cUnitTypeDock, cUnitStateAlive, -1, cPlayerRelationEnemy, cInvalidVector, -1, true);
			
			int WaterAttackPlan = createDefOrAttackPlan("WaterAttack", false, -1, 30, vectorToUse, -1, 50, false);
			if (WaterAttackPlan < 0)
			return;
		    
			aiPlanSetVariableVector(WaterAttackPlan, cAttackPlanGatherPoint, 0, WaterVector);
			aiPlanSetInitialPosition(WaterAttackPlan, WaterVector);
			aiPlanSetVariableInt(WaterAttackPlan, cAttackPlanPlayerID, 0, MHP);
			aiPlanAddUnitType(WaterAttackPlan, cUnitTypeLogicalTypeNavalMilitary, 0, 0, 200);  
			aiPlanSetVariableFloat(WaterAttackPlan, cAttackPlanGatherDistance, 0, 2000.0);
			aiPlanSetVariableInt(WaterAttackPlan, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
			if (EnemyDock != -1)
			aiPlanSetVariableInt(WaterAttackPlan, cAttackPlanSpecificTargetID, 0, EnemyDock);
			aiPlanSetNumberVariableValues(WaterAttackPlan, cAttackPlanTargetTypeID, 2, true);
            aiPlanSetVariableInt(WaterAttackPlan, cAttackPlanTargetTypeID, 0, cUnitTypeUnit);
            aiPlanSetVariableInt(WaterAttackPlan, cAttackPlanTargetTypeID, 1, cUnitTypeBuilding);
			aiPlanSetActive(WaterAttackPlan);
		}
	    return;	
	}  
	
	if (DockUnit < 0)
	return;
	
	if ((mWaterDefendPlan < 0) && (equal(Dock, cInvalidVector) == false))
	{
		mWaterDefendPlan = aiPlanCreate("Water Defend Plan", cPlanDefend);
		aiPlanSetVariableVector(mWaterDefendPlan, cDefendPlanDefendPoint, 0, Dock);
		aiPlanSetVariableFloat(mWaterDefendPlan, cDefendPlanEngageRange, 0, 125.0);
		aiPlanSetVariableBool(mWaterDefendPlan, cDefendPlanPatrol, 0, false);
		aiPlanSetVariableFloat(mWaterDefendPlan, cDefendPlanGatherDistance, 0, 55.0);
		aiPlanSetInitialPosition(mWaterDefendPlan, WaterVector);
		aiPlanSetUnitStance(mWaterDefendPlan, cUnitStanceDefensive);
		aiPlanSetVariableInt(mWaterDefendPlan, cDefendPlanRefreshFrequency, 0, 12);
		aiPlanSetNumberVariableValues(mWaterDefendPlan, cDefendPlanAttackTypeID, 3, true);
		aiPlanSetVariableInt(mWaterDefendPlan, cDefendPlanAttackTypeID, 0, cUnitTypeLogicalTypeNavalMilitary);
		aiPlanSetVariableInt(mWaterDefendPlan, cDefendPlanAttackTypeID, 1, cUnitTypeShip);
		aiPlanSetVariableInt(mWaterDefendPlan, cDefendPlanAttackTypeID, 2, cUnitTypeDock);
		
		aiPlanAddUnitType(mWaterDefendPlan, cUnitTypeLogicalTypeNavalMilitary, 0, 0, 200);
		aiPlanSetDesiredPriority(mWaterDefendPlan, 1);    // Very low priority, gather unused units.
		aiPlanSetActive(mWaterDefendPlan); 
	}
}
