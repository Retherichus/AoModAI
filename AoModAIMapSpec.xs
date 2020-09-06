//==============================================================================
// AoMod AI
// AoModAIMapSpec.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// Contains all map-specific stuff
// If you want the AoMod ai to deal with your rms, you would need to add the
// following:
// 1. insert a line for your rms in preInitMap() in the appropriate block
// depending on whether you have a island map (transport map) or a water map
// (water but no transports required) or a land map where the AoMod ai can't even
// fish.
// 2. If you have made a map that needs special treatment like vinlandsaga,
// you would need to add a line in the corresponding block for the "subtype" of
// the map. Currently supported subtypes are "King of the Hill"-style maps
// (KOTHMAP), nomad-maps (NOMADMAP), great britain and tos_nothamerica
// (WATERNOMADMAP) and vinlandsaga-style (VINLANDSAGAMAP)
//
//==============================================================================

extern int gTransportUnit=-1;
extern bool NoFishing = false;

//==============================================================================
void preInitMap()
{
    if (cvRandomMapName == "None")
	cvRandomMapName = cRandomMapName; 
    int transport = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
	
    if ((cRandomMapName == "alfheim") ||
		(cRandomMapName == "alternate-alfheim") ||
		(cRandomMapName == "shimo alfheim") ||
		(cRandomMapName == "vanaheim") ||
		(cRandomMapName == "manaheim") ||
		(cRandomMapName == "island chain") || // do not try to fish here
		(cRandomMapName == "savannah") ||
		(cRandomMapName == "alternate-savannah") ||
		(cRandomMapName == "farmland") ||
		(cRandomMapName == "stronghold-v1") ||
		(cRandomMapName == "shimo savannah") ||
		(cRandomMapName == "monkey valley") ||
		(cRandomMapName == "valley of kings") ||
		(cRandomMapName == "alternate-valley-of-kings") ||
		(cRandomMapName == "mythland") ||
		(cRandomMapName == "gold rush") ||
		(cRandomMapName == "highland") ||
		(cRandomMapName == "highlands") ||
		(cRandomMapName == "alternate-highland") ||
		(cRandomMapName == "highlandsxp") ||
		(cRandomMapName == "iceworld") ||
		(cRandomMapName == "land nomad") ||
		(cRandomMapName == "green arabia new") ||
		(cRandomMapName == "misty mountain") ||
		(cRandomMapName == "black forest") ||
		(cRandomMapName == "dark forest") ||
		(cRandomMapName == "monticello") ||
		(cRandomMapName == "sudan") ||
		(cRandomMapName == "alpine") ||
		(cRandomMapName == "lost woods") ||
		(cRandomMapName == "daemonwood") ||
		(cRandomMapName == "mountain king") ||
		(cRandomMapName == "battle ground") ||
		(cRandomMapName == "alexandria") ||
		(cRandomMapName == "alexandriax2") ||
		(cRandomMapName == "arabia") ||
		(cRandomMapName == "acropolis") ||
		(cRandomMapName == "team acropolis") ||
		(cRandomMapName == "alternate-acropolis") ||
		(cRandomMapName == "oasis") ||
		(cRandomMapName == "alternate-oasis") ||
		(cRandomMapName == "jotunheim") ||
		(cRandomMapName == "alternate-jotunheim") ||
		(cRandomMapName == "macedonia") ||
		(cRandomMapName == "erebus") ||
		(cRandomMapName == "aral lake") ||
		(cRandomMapName == "tos_middleearth-v1") ||
		(cRandomMapName == "watering hole") ||
		(cRandomMapName == "stronghold") ||
		(cRandomMapName == "marsh") ||
		(cRandomMapName == "alternate-marsh") ||
		(cRandomMapName == "megalopolis") ||
		(cRandomMapName == "Megaopolis") ||
		(cRandomMapName == "alternate-megalopolis") ||
		(cRandomMapName == "tundra") ||
		(cRandomMapName == "alternate-tundra") ||
		(cRandomMapName == "torangia") ||
		(cRandomMapName == "fire void") ||
		(cRandomMapName == "primrose path") ||
		(cRandomMapName == "norwegian forest") ||
		(cRandomMapName == "criss cross") ||
		(cRandomMapName == "mountain pass 0-5") ||
		(cRandomMapName == "rocky mountains") ||
		(cRandomMapName == "cherimoya") ||
		(cRandomMapName == "ghost lake") ||
		(cRandomMapName == "green desert") || 
		(cRandomMapName == "Deep Jungle") || // Not guaranteed to have a pool generated nearby, and fishing in an enemy pool is a bad idea!
	(cRandomMapName == "sudden death")) // imho: does'nt make much sense to fish here
    {
        gWaterMap=false;
        gTransportMap=false;
        gNumBoatsToMaintain = 0;
        xsDisableRule("findFish"); 
        xsDisableRule("fishing");
		NoFishing = true;
	}
    else
	// auto detect
    {
        xsEnableRule("findFish");
		AutoDetectMap = true;
	    int WaterOnMap = kbAreaGetClosetArea(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), cAreaTypeWater);
        if (WaterOnMap != -1)
		NeedTransportCheck = true;	            		
	}	
    // find out what subtype the map is of
    if (cRandomMapName == "gold rush" ||
		cRandomMapName == "king of the hill" ||
	cRandomMapName == "treasure island" )
    {
        cvMapSubType = KOTHMAP;
	}
    else if ( cRandomMapName == "vinlandsaga" ||
		cRandomMapName == "team migration" ||
		cRandomMapName == "alternate-vinlandsaga" ||
		cRandomMapName == "mystere isle" ||
		(cRandomMapName == "vesuvius-v1" &&
		kbUnitCount(cMyID, transport, cUnitStateAlive) > 0) )
		{
			cvMapSubType = VINLANDSAGAMAP;
		}
		
		if (cvRandomMapName == "Transport Scenario")
		{
			gTransportMap = true;
			gWaterMap = true;
			xsEnableRule("fishing"); // force builds the dock.
		}	
		
		if (cvRandomMapName == "Migration Scenario")
		{
			gTransportMap = true;
			gWaterMap = true;
			cvMapSubType = VINLANDSAGAMAP;
			xsEnableRule("fishing"); // force builds the dock.
		}		
		//Tell the AI what kind of map we are on.
		aiSetWaterMap(gTransportMap == true);
}

//==============================================================================
void initMapSpecific()
{
    // various map overrides
    if ( cRandomMapName == "farmland" )
    {
        int plan=aiPlanCreate("Farmland Forkboy Explore", cPlanExplore);
        if (plan >= 0)
        {
            aiPlanAddUnitType(plan, cUnitTypeForkboy, 1, 1, 1);
            aiPlanSetDesiredPriority(plan, 10);
            if ( cMyCulture == cCultureEgyptian )
			aiPlanSetVariableBool(plan, cExplorePlanDoLoops, 0, true);
            else
			aiPlanSetVariableBool(plan, cExplorePlanDoLoops, 0, false);
            aiPlanSetActive(plan, true);
            aiPlanSetEscrowID(plan, cEconomyEscrowID);
		}
	}
    else if ((cvRandomMapName == "erebus") || (cvRandomMapName == "river styx"))
    {
        aiSetMinNumberNeedForGatheringAggressvies(1);
	}
    //Vinlandsaga.
    else if (cvMapSubType == VINLANDSAGAMAP)
    {    
        gpDelayMigration = true;
        //Enable the rule that looks for the mainland.
        xsEnableRule("findVinlandsagaBase");
        //Turn off auto dropsite building.
		int House = cUnitTypeHouse;
		if (cMyCulture == cCultureAtlantean)
		House = cUnitTypeManor;
   		createSimpleBuildPlan(House, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1); 
        aiSetAllowAutoDropsites(false);
		if (aiGetGameMode() == cGameModeDeathmatch)
		aiSetAllowBuildings(true);
	    else
        aiSetAllowBuildings(false);
		
        // Move the transport toward map center to find continent quickly.
        int transportID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0));
        vector nearCenter = kbGetMapCenter();
        nearCenter = (nearCenter + kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) / 2.0;    // Halfway between start and center
        nearCenter = (nearCenter + kbGetMapCenter()) / 2.0;   // 3/4 of the way to map center
        aiTaskUnitMove(transportID, nearCenter);
        xsEnableRule("vinlandsagaFailsafe");  // In case something prevents transport from reaching, turn on the explore plan.
        //Turn off fishing.
        xsDisableRule("fishing");
        //Pause the age upgrades.
		if (aiGetGameMode() != cGameModeDeathmatch)
        aiSetPauseAllAgeUpgrades(true);
		gHuntingDogsASAP = false;
		IsRunHuntingDogs = true;
	}
    else if (cvMapSubType == KOTHMAP)
    {
        int KOTHunitQueryID = kbUnitQueryCreate("findPlentyVault");
        kbUnitQuerySetPlayerRelation(KOTHunitQueryID, cPlayerRelationAny);
        kbUnitQuerySetUnitType(KOTHunitQueryID, cUnitTypePlentyVaultKOTH);
		kbUnitQuerySetSeeableOnly(KOTHunitQueryID, false);
        kbUnitQuerySetState(KOTHunitQueryID, cUnitStateAny);
        kbUnitQueryResetResults(KOTHunitQueryID);
        int numberFound = kbUnitQueryExecute(KOTHunitQueryID);
        gKOTHPlentyUnitID = kbUnitQueryGetResult(KOTHunitQueryID, 0);
        kbSetForwardBasePosition(kbUnitGetPosition(gKOTHPlentyUnitID));
        if (gKOTHPlentyUnitID != -1)
	    KOTHGlobal = kbUnitGetPosition(gKOTHPlentyUnitID);
		if (SameAG(KOTHGlobal, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) == false)
		{
			KoTHWaterVersion = true;
			KOTHBASE = kbBaseCreate(cMyID, "KOTH BASE", KOTHGlobal, 5.0);
		}
		xsEnableRule("getKingOfTheHillVault");
        xsEnableRule("findFish");
		if (KoTHWaterVersion == false)
		xsEnableRule("BunkerUpThatWonder"); 
	}
}

//==============================================================================
rule findVinlandsagaBase
minInterval 1 //starts in cAge1
inactive
{
    //Save our initial base ID.
	static bool RunOnce = false;
	if (RunOnce == false)
    gVinlandsagaInitialBaseID=kbBaseGetMainID(cMyID);
    RunOnce = true;
	//Get our initial location.
    vector location=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    //Find the mainland area group.
    static int mainlandGroupID=-1;
	
    if (mainlandGroupID == -1)
	{
        int TCs = kbUnitCount(0, cUnitTypeSettlement, cUnitStateAlive);
	    for (i=0; < TCs)
	    {
            int unitID = findUnitByIndex(cUnitTypeSettlement, i, cUnitStateAlive, -1, 0, kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID));
            vector unitLoc = kbUnitGetPosition(unitID);
		    int AreaID = kbAreaGetIDByPosition(unitLoc);
		    int testforEnemy = NumUnitsOnAreaGroupByRel(false, kbAreaGroupGetIDByPosition(unitLoc), cUnitTypeSettlementLevel1, cPlayerRelationEnemy);		
	        if ((SameAG(unitLoc, kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID)) == false) && (testforEnemy < 1) && (kbAreaGetType(AreaID) != cAreaTypeWater))
			{
				mainlandGroupID = kbAreaGroupGetIDByPosition(unitLoc);
				break;
			} 
		}
	}
	if (mainlandGroupID < 0)
	mainlandGroupID=kbFindAreaGroup(cAreaGroupTypeLand, 3.0, kbAreaGetIDByPosition(location));
	
    float easyAmount = kbGetAmountValidResources(gVinlandsagaInitialBaseID, cResourceFood, cAIResourceSubTypeEasy, 45);
    if ((mainlandGroupID < 0) || (xsGetTime() < 2*60*1000) && (easyAmount >= 50) && (aiGetGameMode() != cGameModeDeathmatch))
	return;
	
    // stop the transport right away
    int transportID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0));
    aiTaskUnitMove(transportID, kbUnitGetPosition(transportID));
	
    //Create the mainland base.
    int mainlandBaseGID=createBaseGoal("Mainland Base", cGoalPlanGoalTypeMainBase, -1, 1, 0, -1, kbBaseGetMainID(cMyID));
    if (mainlandBaseGID >= 0)
    {
        //Set the area ID.
        aiPlanSetVariableInt(mainlandBaseGID, cGoalPlanAreaGroupID, 0, mainlandGroupID);
        //Create the callback goal.
        int callbackGID=createCallbackGoal("Vinlandsaga Base Callback", "vinlandsagaBaseCallback", 1, 0, -1, false);
        if (callbackGID >= 0)
		aiPlanSetVariableInt(mainlandBaseGID, cGoalPlanDoneGoal, 0, callbackGID);
	}
    //Done.
	gpDelayMigration = false;
    xsDisableSelf();
}  

//==============================================================================
rule vinlandsagaFailsafe
minInterval 60 //starts in cAge1
inactive
{
    //Make a plan to explore with the initial transport.
    gVinlandsagaTransportExplorePlanID=aiPlanCreate("Vinlandsaga Transport Explore", cPlanExplore);
    if (gVinlandsagaTransportExplorePlanID >= 0)
    {
        aiPlanAddUnitType(gVinlandsagaTransportExplorePlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 1, 1, 1);
        aiPlanSetDesiredPriority(gVinlandsagaTransportExplorePlanID, 1);
        aiPlanSetVariableBool(gVinlandsagaTransportExplorePlanID, cExplorePlanDoLoops, 0, false);
        aiPlanSetActive(gVinlandsagaTransportExplorePlanID);
        aiPlanSetEscrowID(gVinlandsagaTransportExplorePlanID);
	}
    xsDisableSelf();
}

//==============================================================================
rule vinlandsagaEnableFishing
minInterval 10 //starts in cAge1
inactive
{
    //See how many wood dropsites we have.
    static int wdQueryID=-1;
    //If we don't have a query ID, create it.
    if (wdQueryID < 0)
    {
        wdQueryID=kbUnitQueryCreate("Wood Dropsite Query");
        //If we still don't have one, bail.
        if (wdQueryID < 0)
		return;
        //Else, setup the query data.
        kbUnitQuerySetPlayerID(wdQueryID, cMyID);
        if (cMyCulture == cCultureGreek)
		kbUnitQuerySetUnitType(wdQueryID, cUnitTypeStorehouse);
        else if (cMyCulture == cCultureChinese)
		kbUnitQuerySetUnitType(wdQueryID, cUnitTypeStoragePit);			
        else if ((cMyCulture == cCultureEgyptian) || (cMyCulture == cCultureAtlantean))
		kbUnitQuerySetUnitType(wdQueryID, cUnitTypeAbstractVillager);
        else if (cMyCulture == cCultureNorse)
		kbUnitQuerySetUnitType(wdQueryID, cUnitTypeLogicalTypeLandMilitary);
        kbUnitQuerySetAreaGroupID(wdQueryID, kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) );
        kbUnitQuerySetState(wdQueryID, cUnitStateAliveOrBuilding);
	}
    //Reset the results.
    kbUnitQueryResetResults(wdQueryID);
    //Run the query.  If we don't have anything, skip.
    if ((kbUnitQueryExecute(wdQueryID) <= 0) && (aiGetGameMode() != cGameModeDeathmatch))
	return;
	
    if ( cvMapSubType == WATERNOMADMAP )
    {
        if ( findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) < 0 )
		return;
	}
	
    //Enable the rule.
    xsEnableRule("fishing");
    //Unpause the age upgrades.
    aiSetPauseAllAgeUpgrades(false);
    //Unpause the pause kicker.
    xsEnableRule("unPauseAge2");
    xsSetRuleMinInterval("unPauseAge2", 15);
    xsDisableSelf();
}  


//==============================================================================
void vinlandsagaBaseCallback(int parm1=-1)
{
    //Get our water transport type.
    int transportPUID=cUnitTypeTransport;
    //Get our main base.  This needs to be different than our initial base.
    if (kbBaseGetMainID(cMyID) == gVinlandsagaInitialBaseID)
	return;
	
    //Kill the transport explore plan.
    aiPlanDestroy(gVinlandsagaTransportExplorePlanID);
    xsDisableRule("vinlandsagaFailsafe");
    //Kill the land scout explore.
    aiPlanDestroy(gLandExplorePlanID);
    //Create a new land based explore plan for the mainland.
    gLandExplorePlanID=aiPlanCreate("Explore_Land_VS", cPlanExplore);
    if (gLandExplorePlanID >= 0)
    {
        aiPlanAddUnitType(gLandExplorePlanID, gLandScout, 1, 1, 1);
        aiPlanSetEscrowID(gLandExplorePlanID, cEconomyEscrowID);
        aiPlanSetBaseID(gLandExplorePlanID, kbBaseGetMainID(cMyID));
        //Don't loop as egyptian.
        if (cMyCulture == cCultureEgyptian)
        {
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanCanBuildLOSProto, 0, true);
		}
        aiPlanSetActive(gLandExplorePlanID);
	}
	
    //Get our start area ID.
    int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID));
    //Get our goal area ID.
    int goalAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	
    goalAreaID = verifyVinlandsagaBase( goalAreaID );  // Make sure it borders water,or find one that does.
    MigrationAreaID = goalAreaID;
    int planID=-1;
    if ( cvMapSubType == WATERNOMADMAP )
    {
        //Enable the rule that looks for a settlement.
	    aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 0);
        aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, -1);
        xsEnableRule("nomadSearchMode");
	}
    //change the farming baseID
    
	if (cvMapSubType != WATERNOMADMAP)
	{
	    ResourceBaseID = CreateBaseInBackLoc(kbBaseGetMainID(cMyID), 10, 100, "Temp Resource Base");
        xsEnableRule("vinlandsagaEnableFishing");
		gFarmBaseID=kbBaseGetMainID(cMyID);
	}
    //Allow auto dropsites again.
    aiSetAllowAutoDropsites(true);
    aiSetAllowBuildings(true);
    xsEnableRule("econForecastAge1");
    //Enable the rule that will eventually enable fishing and other stuff.
    
	xsDisableRule("setEarlyEcon");
	xsEnableRule("transportAllUnits");
}

//==============================================================================
rule transportAllUnits
inactive
minInterval 5 //starts in cAge1
{
    int num = NumUnitsOnAreaGroupByRel(true, kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID)), cUnitTypeLogicalTypeGarrisonOnBoats, cMyID);
    //Get our water transport type.
    int transportPUID = cUnitTypeTransport;
	int numTransport = kbUnitCount(cMyID, transportPUID, cUnitStateAlive);
	
    //Get our start area ID.
    int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID));
    int TransPlan = findPlanByString("All Units Transport", cPlanTransport);
	
	if (cvMapSubType == WATERNOMADMAP)
	{
		static int FailCount = 0;
		static bool Check = true;
		if ((TransPlan != -1) && (Check == true))
		Check = false;
		if ((Check == true) && (num > 0))
		{
			FailCount = FailCount+1;
			if (FailCount > 3)
			{
				xsEnableRule("findVinlandsagaBase");
				FailCount = 0;
			}
		}
	}
	if ((TransPlan != -1) && (numTransport < 1))
	{
	    aiPlanDestroy(TransPlan);
        return;
	}
    if ((numTransport < 1) || (num < 1) || (TransPlan != -1))
	return;
    //Get our goal area ID.
    int goalAreaID = MigrationAreaID;
	if (goalAreaID == -1)
	goalAreaID = kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	
    int transportAllUnitsID=createTransportPlan("All Units Transport", startAreaID, goalAreaID, false, transportPUID, 100, gVinlandsagaInitialBaseID);
    if (transportAllUnitsID >= 0 )
    {
        aiPlanSetVariableBool(transportAllUnitsID, cTransportPlanReturnWhenDone, 0, true);
		aiPlanSetVariableBool(transportAllUnitsID, cTransportPlanMaximizeXportMovement, 0, true);
		aiPlanAddUnitType(transportAllUnitsID, cUnitTypeAbstractVillager, 0, 0, num+3);
		aiPlanAddUnitType(transportAllUnitsID, cUnitTypeHumanSoldier, 1, num+3, num+3);
        aiPlanAddUnitType(transportAllUnitsID, cUnitTypeHero, 1, 1, 1);
		if (cMyCulture == cCultureGreek)
		aiPlanAddUnitType(transportAllUnitsID, cUnitTypeScout, 1, 1, 1);
		if (cMyCulture == cCultureNorse)
		aiPlanAddUnitType(transportAllUnitsID, cUnitTypeOxCart, 1, 1, 1);
	    if (cMyCiv == cCivSet)
		aiPlanAddUnitType(transportAllUnitsID, cUnitTypeHyenaofSet, 0, 1, 1);
	    aiPlanAddUnitType(transportAllUnitsID, cUnitTypeHerdable, 0, 4, 8);
        aiPlanAddUnitType(transportAllUnitsID, cUnitTypeLogicalTypeGarrisonOnBoats, 0, 1, 2);	
	    aiPlanAddUnitType(transportAllUnitsID, cUnitTypeFlyingUnit, 0, 0, 0);
        aiPlanSetActive(transportAllUnitsID);
	}
}
//==============================================================================
rule nomadSearchMode
inactive
minInterval 1 //starts in cAge1
{
    //Make plans to explore with the initial villagers and goats.
    gNomadExplorePlanID1=aiPlanCreate("Nomad Explore 1", cPlanExplore);
    if (gNomadExplorePlanID1 >= 0)
    {
        aiPlanAddUnitType(gNomadExplorePlanID1, cBuilderType, 0, 0, 1);
        aiPlanSetDesiredPriority(gNomadExplorePlanID1, 90);
        aiPlanSetVariableBool(gNomadExplorePlanID1, cExplorePlanDoLoops, 0, false);
        aiPlanSetActive(gNomadExplorePlanID1);
        aiPlanSetEscrowID(gNomadExplorePlanID1);
	}
    gNomadExplorePlanID2=aiPlanCreate("Nomad Explore 2", cPlanExplore);
    if (gNomadExplorePlanID2 >= 0)
    {
        aiPlanAddUnitType(gNomadExplorePlanID2, cBuilderType, 0, 0, 1);
        aiPlanSetDesiredPriority(gNomadExplorePlanID2, 90);
        aiPlanSetVariableBool(gNomadExplorePlanID2, cExplorePlanDoLoops, 0, false);
        aiPlanSetActive(gNomadExplorePlanID2);
        aiPlanSetEscrowID(gNomadExplorePlanID2);
	}
    gNomadExplorePlanID3=aiPlanCreate("Nomad Explore 3", cPlanExplore);
    if (gNomadExplorePlanID3 >= 0)
    {
        aiPlanAddUnitType(gNomadExplorePlanID3, cBuilderType, 0, 0, 2);   // Grab last Egyptian
        aiPlanSetDesiredPriority(gNomadExplorePlanID3, 90);
        aiPlanSetVariableBool(gNomadExplorePlanID3, cExplorePlanDoLoops, 0, false);
        aiPlanSetActive(gNomadExplorePlanID3);
        aiPlanSetEscrowID(gNomadExplorePlanID3);
	}      
	
    //Turn off fishing.
    xsDisableRule("fishing");
	
    //Turn off buildhouse.
    xsDisableRule("buildHouse");
    //Pause the age upgrades.
    aiSetPauseAllAgeUpgrades(true);
    xsEnableRule("nomadBuildMode");
    xsDisableSelf();
}

//==============================================================================
rule nomadBuildMode        // Go to build mode when a suitable settlement is found
inactive
minInterval 1 //starts in cAge1
{
	int Unit = findUnit(cBuilderType);
    vector UnitLoc = kbUnitGetPosition(Unit);
	int tc = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
	int settlement = findClosestUnitTypeByLoc(cPlayerRelationEnemy, cUnitTypeSettlement, cUnitStateAlive, UnitLoc, -1, false, true);
    if ((settlement < 0) || (Unit < 0) || (cvMapSubType == WATERNOMADMAP) && (SameAG(kbUnitGetPosition(settlement), kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID)) == true))
	return;

    gNomadSettlementBuildPlanID=aiPlanCreate("Nomad settlement build", cPlanBuild);
    if (gNomadSettlementBuildPlanID < 0)
	return;
    //Puid.
    aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSettlementLevel1);
    //Priority.
    aiPlanSetDesiredPriority(gNomadSettlementBuildPlanID, 100);
    //Mil vs. Econ.
    aiPlanSetMilitary(gNomadSettlementBuildPlanID, false);
    aiPlanSetEconomy(gNomadSettlementBuildPlanID, true);
    //Escrow.
    aiPlanSetEscrowID(gNomadSettlementBuildPlanID, cEconomyEscrowID);
    //Builders.
    aiPlanAddUnitType(gNomadSettlementBuildPlanID, cBuilderType, 4, 4, 20);
    //Base ID.
    aiPlanSetBaseID(gNomadSettlementBuildPlanID, kbBaseGetMainID(cMyID));
    aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanCenterPosition, 0, kbUnitGetPosition(settlement));
    aiPlanSetVariableFloat(gNomadSettlementBuildPlanID, cBuildPlanCenterPositionDistance, 0, 2.0);
    aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanSettlementPlacementPoint, 0, kbUnitGetPosition(settlement));
    //Go.
    aiPlanSetActive(gNomadSettlementBuildPlanID);
    aiPlanDestroy(gNomadExplorePlanID1);
    aiPlanDestroy(gNomadExplorePlanID2);
    aiPlanDestroy(gNomadExplorePlanID3);
	
    xsEnableRule("nomadMonitor");
    xsDisableSelf();
}

//==============================================================================
rule nomadMonitor    // Watch the build goal.  When a settlement is up, turn on normal function.  If goal fails, restart.
inactive
minInterval 1 //starts in cAge1
{
	
    if ( (aiPlanGetState(gNomadSettlementBuildPlanID) >= 0) && (aiPlanGetState(gNomadSettlementBuildPlanID) != cPlanStateDone) )
	return; 
    // plan is done or died.  Check if we have a settlement
	int tc = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (tc >= 0)   
    {
		// Set main base
		int oldMainBase = kbBaseGetMainID(cMyID);
		aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, oldMainBase);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, oldMainBase);
		aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, oldMainBase);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, oldMainBase);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, oldMainBase);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, oldMainBase);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, oldMainBase);
		aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, -1);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, -1);
		aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, -1);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, -1);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, -1);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, -1);
		aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, -1);
		aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, -1);
		aiSetResourceBreakdown( cResourceFavor, cAIResourceSubTypeEasy, 0, 48, 0.00, kbBaseGetMainID(cMyID));
		if ( kbUnitGetBaseID(tc) != oldMainBase )
		{
			kbBaseDestroy(cMyID, oldMainBase);
			kbBaseSetMain(cMyID, kbUnitGetBaseID(tc),true);
		}
		vector front = cInvalidVector;
		front = xsVectorNormalize(kbGetMapCenter()-kbUnitGetPosition(tc));
		kbBaseSetFrontVector(cMyID, kbBaseGetMainID(cMyID), front);
		gFarmBaseID = kbBaseGetMainID(cMyID);
        gGoldBaseID=kbBaseGetMainID(cMyID);
        gWoodBaseID=kbBaseGetMainID(cMyID);	
		// Fix herdable plans
		aiPlanDestroy(gHerdPlanID);
		gHerdPlanID=aiPlanCreate("GatherHerdable Plan Nomad", cPlanHerd);
		if (gHerdPlanID >= 0)
		{
			aiPlanAddUnitType(gHerdPlanID, cUnitTypeHerdable, 0, 100, 100);
			aiPlanSetBaseID(gHerdPlanID, kbBaseGetMainID(cMyID));
			aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingID, 0, tc);
			aiPlanSetActive(gHerdPlanID);
		}
		aiSetResourceBreakdown( cResourceFavor, cAIResourceSubTypeEasy, 0, 48, 0.00, kbBaseGetMainID(cMyID));
		updateFoodBreakdown();
		updateBreakdowns();
		xsEnableRule("updateFoodBreakdown");
		xsEnableRule("updateBreakdowns");
        // Fix god power plan for age 1
        aiPlanSetBaseID(gAge1GodPowerPlanID, kbBaseGetMainID(cMyID));
		aiPlanSetBaseID(gAge2ProgressionPlanID, kbBaseGetMainID(cMyID));
        //Unpause the age upgrades.
        aiSetPauseAllAgeUpgrades(false);
        //Unpause the pause kicker.
        xsEnableRule("unPauseAge2");
        xsSetRuleMinInterval("unPauseAge2", 15);
		xsEnableRule("buildHouse");
		if (cvMapSubType == WATERNOMADMAP)
		{
		    xsEnableRule("findFish");
	        xsDisableRule("transportAllUnits");
	    }
        aiPlanDestroy(gNomadExplorePlanID1);
        aiPlanDestroy(gNomadExplorePlanID2);
        aiPlanDestroy(gNomadExplorePlanID3);	
	    xsDisableSelf();
	}
	else
	{  // No settlement, restart chain
	    xsEnableRule("nomadSearchMode");
		aiEcho("Back to searching for a tc");
		xsDisableSelf();
	}
}

//==============================================================================
bool mapPreventsWalls() //some maps do not allow walls or it doesn't make sense to build walls there
{
	if (cRandomMapName == "acropolis" ||
	cRandomMapName == "alternate-acropolis" ||
	cRandomMapName == "stronghold-v1" ||
	cRandomMapName == "torangia" ||
	cRandomMapName == "amazonas" ||
	cRandomMapName == "fire void" ||
	cRandomMapName == "the void" ||
	cRandomMapName == "daemonwood" ||
	cRandomMapName == "black forest" ||
	cRandomMapName == "holy mountain" ||
	cRandomMapName == "black sea"  ||
	cvMapSubType == VINLANDSAGAMAP ||		
	cRandomMapName == "akIslandDom" )
    {
        return(true);
	}
    else
	return(false);
}

//==============================================================================
bool mapPreventsHousesAtTowers()
{
    if ( cRandomMapName == "amazonas" ||
		cRandomMapName == "acropolis" ||
	cRandomMapName == "alternate-acropolis" )
	return(true);
    else
	return(false);
}

//==============================================================================
bool mapRestrictsMarketAttack()
{
    if ((cRandomMapName == "highland")
	|| (cRandomMapName == "watering hole") //TODO: Test if this is really better!
	|| (cRandomMapName == "jotunheim"))
    {
	return(true);
	}
    else
	return(false);
	}		