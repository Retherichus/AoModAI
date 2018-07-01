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
    if (ShowAiEcho == true) aiEcho("Naval Age "+age+".");
	
    // Naval (scout other islands etc...)
    if (gTransportMap == true)
    {
        xsEnableRuleGroup("NavalClassical");
	}
    
    if ((cRandomMapName == "anatolia") // TODO: maybe on (cRandomMapName == "highlands") too?
	|| (cRandomMapName == "mediterranean")
	|| (cRandomMapName == "king of the hill")
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
    if (ShowAiEcho == true) aiEcho("Naval Age "+age+".");
}

//==============================================================================
rule findOtherSettlements
minInterval 26 //starts in cAge3
group NavalHeroic
inactive
{
	if (ShowAiEcho == true) aiEcho("findOtherSettlements:");
	int Builder = cUnitTypeAbstractVillager;
	static int bStartTime = -1;
	static int Attempts = 0;
	int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
	if (cMyCulture == cCultureNorse)
	Builder = cUnitTypeAbstractInfantry;
	int TotalBuilders = kbUnitCount(cMyID, Builder, cUnitStateAlive);
	if (cMyCulture == cCultureAtlantean)
	TotalBuilders = TotalBuilders * 2;
	
	int ActivePlans = findPlanByString("Remote Settlement Transport", cPlanTransport, -1, true);
	int ActiveBackupPlans = findPlanByString("Backup Remote Settlement", cPlanBuild, -1, true);
	if ((ActivePlans >= 1) || (TotalBuilders < 14) || (kbUnitCount(cMyID, transportPUID, cUnitStateAlive) < 1) 
	|| (kbResourceGet(cResourceGold) < 500) || (kbResourceGet(cResourceFood) < 200) || (kbResourceGet(cResourceWood) < 400) && (cMyCulture != cCultureEgyptian))
	return;
	
	//Get our initial location.
	vector here=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	
	//Get our start area ID.
	int startAreaID=kbAreaGetIDByPosition(here);
	
	//Find other islands area group.
	vector there = findBestSettlement();
	
	// settlement is on my island
	if ( isOnMyIsland(there) == true )
	return; // no transport needed!
	
	//Create transport plan to get builders to the other island
	// but just do one per detected settlement!
	// therefore remember the pos where we did the transport to
	static vector gTransportToSettlementPos = cInvalidVector;
	
	if ((bStartTime != -1) && (ActiveBackupPlans > 0) && (xsGetTime() - bStartTime > 4*60*1000))
	{
		int ActiveBackupPlanID = findPlanByString("Backup Remote Settlement", cPlanBuild, -1);
		if (ActiveBackupPlanID > 0)
		{
			aiPlanDestroy(ActiveBackupPlanID);
			Attempts = 0;
			gTransportToSettlementPos = cInvalidVector; // reset and try new transport?
		}
	}
	
	// been there, done that
	if (equal(gTransportToSettlementPos, there))
	{
		int builderTypeID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0);
		int NumNeutralTC = getNumUnits(cUnitTypeSettlement, cUnitStateAny, -1, 0, there, 125.0, true);	
		int NumBuilder = getNumUnits(builderTypeID, cUnitStateAlive, -1, cMyID, there, 125.0);
		
		if ((NumBuilder > 0) && (NumNeutralTC == 1) && (ActiveBackupPlans <= 0))
		{
			int planID=aiPlanCreate("Backup Remote Settlement", cPlanBuild);
			aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeSettlementLevel1);
			aiPlanSetDesiredPriority(planID, 100);
			aiPlanSetEconomy(planID, true);
			aiPlanSetEscrowID(planID, cEconomyEscrowID);
			aiPlanAddUnitType(planID, builderTypeID, 1, 1, NumBuilder);
			aiPlanSetInitialPosition(planID, there);
			aiPlanSetVariableVector(planID, cBuildPlanSettlementPlacementPoint, 0, there);
			aiPlanSetActive(planID);
			bStartTime = xsGetTime();
		}
		if (ActiveBackupPlans <= 0)
		Attempts = Attempts + 1;
		if (Attempts > 6)
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
	int numEnemyMilShips = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy);
	
	if ((numMyMilShips + numAlliedMilShips > numEnemyMilShips + 1) && (numMyMilShips > 1))
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
	int minShips=0;
	int maxShips=0;
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
	
	gTargetNavySize = maxShips;   // Set the global var for forecasting
	
	//If we already have a Naval UP, just set the numbers and be done.  If we don't
	//want anything, just set 1 since we've already done it before.
	if (gNavalUPID >= 0)
	{
		if (maxShips <= 0)
		{
			kbUnitPickSetMinimumNumberUnits(gNavalUPID, 1);
			kbUnitPickSetMaximumNumberUnits(gNavalUPID, 1);
		}
		else
		{
			kbUnitPickSetMinimumNumberUnits(gNavalUPID, minShips);
			kbUnitPickSetMaximumNumberUnits(gNavalUPID, maxShips);
		}
		return;
	}
	
	//Else, we don't have a Naval attack goal yet.  If we don't want any ships,
	//just return.
	if (maxShips <= 0)
	return;
	
	//Else, create the Naval attack goal.
	if (ShowAiEcho == true) aiEcho("Creating NavalAttackGoal for "+maxShips+" ships since I've seen "+numberEnemyWarships+" for Player "+aiGetMostHatedPlayerID()+".");
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
	kbUnitPickSetMinimumNumberUnits(gNavalUPID, minShips);
	kbUnitPickSetMaximumNumberUnits(gNavalUPID, maxShips);
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
minInterval 20
{
	static int  mWaterDefendPlan = -1;
	xsSetRuleMinIntervalSelf(20); 
	int navyUnit = findUnit(cUnitTypeLogicalTypeNavalMilitary);
	int DockUnit = findUnit(cUnitTypeDock);
	vector WaterVector = aiPlanGetVariableVector(gFishPlanID, cFishPlanWaterPoint, 0);
	vector Dock = kbUnitGetPosition(DockUnit); 
	
	if ((mWaterDefendPlan != -1) && (equal(Dock, cInvalidVector) == false))
	{
		aiPlanSetVariableVector(mWaterDefendPlan, cDefendPlanDefendPoint, 0, Dock);
		aiPlanSetInitialPosition(mWaterDefendPlan, WaterVector);
	}
	
	
	if ((mWaterDefendPlan != -1) && (aiPlanGetNumberUnits(mWaterDefendPlan, cUnitTypeLogicalTypeNavalMilitary) >= 3))
	{
		aiPlanDestroy(mWaterDefendPlan);
		mWaterDefendPlan = -1;
		xsSetRuleMinIntervalSelf(35);
		return;
	}  
	
	if ((navyUnit < 0) || (DockUnit < 0) || (gFishPlanID < 0))
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
