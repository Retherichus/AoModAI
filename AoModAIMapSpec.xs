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
    if (ShowAiEcho == true) aiEcho("preInitMap:");    
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
        if (ShowAiEcho == true) aiEcho("This is an unknown map.");
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
    if (ShowAiEcho == true) aiEcho("initMapSpecific:");
	
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
        if (ShowAiEcho == true) aiEcho("Sending transport "+transportID+" to near map center at "+nearCenter);
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
        if (ShowAiEcho == true) aiEcho("looking for KOTH plenty Vault");
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
		if (kbAreaGroupGetIDByPosition(KOTHGlobal) != kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))))
		{
			KoTHWaterVersion = true;
			if (ShowAiEcho == true) aiEcho("Water version of KOTH detected.");
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
    if (ShowAiEcho == true) aiEcho("findVinlandsagaBase:");
    //Save our initial base ID.
    gVinlandsagaInitialBaseID=kbBaseGetMainID(cMyID);
    
	//Get our initial location.
    vector location=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    //Find the mainland area group.
    int mainlandGroupID=-1;
    if ((cRandomMapName == "vinlandsaga") ||
	(cRandomMapName == "vesuvius-v1") ||
	(cRandomMapName == "alternate-vinlandsaga") ||
	(cRandomMapName == "great britain") ||
	(cRandomMapName == "tos_northamerica") ||    
	(cRandomMapName == "tos_northamerica-v1-1") ||    
	(cRandomMapName == "tos_northamerica-v1"))
    {
        mainlandGroupID=kbFindAreaGroup(cAreaGroupTypeLand, 3.0, kbAreaGetIDByPosition(location));
	}
    else
    {
        mainlandGroupID=kbFindAreaGroupByLocation(cAreaGroupTypeLand, 0.5, 0.5);  // Can fail if mountains at map center
	}
    float easyAmount = kbGetAmountValidResources(gVinlandsagaInitialBaseID, cResourceFood, cAIResourceSubTypeEasy, 45);
    if ((mainlandGroupID < 0) || (xsGetTime() < 2*60*1000) && (easyAmount >= 50) && (aiGetGameMode() != cGameModeDeathmatch))
	return;
	
    if (ShowAiEcho == true) aiEcho("findVinlandsagaBase: Found the mainland, AGID="+mainlandGroupID+".");
	
    // stop the transport right away
    int transportID = findUnit(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0));
    if (ShowAiEcho == true) aiEcho("Stopping transport "+transportID);
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
    if (ShowAiEcho == true) aiEcho("vinlandsagaFailsafe:");
	
    //Make a plan to explore with the initial transport.
    gVinlandsagaTransportExplorePlanID=aiPlanCreate("Vinlandsaga Transport Explore", cPlanExplore);
    if (ShowAiEcho == true) aiEcho("Transport explore plan: "+gVinlandsagaTransportExplorePlanID);
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
    if (ShowAiEcho == true) aiEcho("vinlandsagaEnableFishing:");    
	
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
    if (ShowAiEcho == true) aiEcho("VinlandsagaBaseCallback:");
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
        int num = kbUnitCount(cMyID, cUnitTypeLogicalTypeGarrisonOnBoats, cUnitStateAny);
        planID=createTransportPlan("All Units Transport", startAreaID, goalAreaID, false, transportPUID, 100, gVinlandsagaInitialBaseID);
        if ( planID >= 0 )
        {
            aiPlanSetVariableBool(planID, cTransportPlanReturnWhenDone, 0, false);
            aiPlanAddUnitType(planID, cUnitTypeUnit, num, num, num);
            aiPlanAddUnitType(planID, cUnitTypeHero, 1, 1, 1);
            aiPlanSetActive(planID);
		}
		
        //Enable the rule that looks for a settlement.
        xsEnableRule("nomadSearchMode");
        xsEnableRule("transportAllUnits");
	}
    else
    {
        //Create the scout/villager xport plan.  If it works, add the unit type(s).
        planID=createTransportPlan("All Units Transport", startAreaID, goalAreaID, false, transportPUID, 100, gVinlandsagaInitialBaseID);
        if (planID >= 0)
        {
            if (cMyCulture == cCultureAtlantean)
			aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, 0, 3, 3);         
            else
			aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, 0, 5, 5);
			
            aiPlanAddUnitType(planID, cUnitTypeLogicalTypeGarrisonOnBoats, 0, 1, 8);
			aiPlanAddUnitType(planID, cUnitTypeHero, 1, 1, 1);
			if (cMyCiv != cCivOdin)
            aiPlanAddUnitType(planID, gLandScout, 1, 1, 1);
            if (cMyCulture == cCultureNorse)
			aiPlanAddUnitType(planID, cUnitTypeOxCart, 1, 1, 4);
			aiPlanSetVariableBool(planID, cTransportPlanReturnWhenDone, 0, false);
			aiPlanSetActive(planID);
		}
        if (ShowAiEcho == true) aiEcho("Transport plan ID is "+planID);
	}
	
    //change the farming baseID
    gFarmBaseID=kbBaseGetMainID(cMyID);
	ResourceBaseID = CreateBaseInBackLoc(kbBaseGetMainID(cMyID), 10, 100, "Temp Resource Base");
    //Allow auto dropsites again.
    aiSetAllowAutoDropsites(true);
    aiSetAllowBuildings(true);
	
    xsDisableRule("setEarlyEcon");
    xsEnableRule("econForecastAge1");
	xsEnableRule("transportAllUnits");
	
    //Enable the rule that will eventually enable fishing and other stuff.
    xsEnableRule("vinlandsagaEnableFishing");
}

//==============================================================================
rule transportAllUnits
inactive
minInterval 20 //starts in cAge1
{
    static int transportAllUnitsID=-1;
    int num = NumUnitsOnAreaGroupByRel(true, kbAreaGroupGetIDByPosition(kbUnitGetPosition(gVinlandsagaInitialBaseID)), cUnitTypeLogicalTypeGarrisonOnBoats, cMyID);
	
    //Get our water transport type.
    int transportPUID = cUnitTypeTransport;
	int numTransport = kbUnitCount(cMyID, transportPUID, cUnitStateAlive);

    //Get our start area ID.
    int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID));
    //Get our goal area ID.
    int TransPlan = findPlanByString("All Units Transport", cPlanTransport);
	if ((TransPlan != -1) && (numTransport < 1))
	{
	    aiPlanDestroy(TransPlan);
        return;
    }
	
    if ((numTransport < 1) || (num < 1) || (TransPlan != -1))
	return;
    int goalAreaID = MigrationAreaID;
	if (goalAreaID == -1)
	goalAreaID = kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));

    transportAllUnitsID=createTransportPlan("All Units Transport", startAreaID, goalAreaID, false, transportPUID, 100, gVinlandsagaInitialBaseID);
    if ( transportAllUnitsID >= 0 )
    {
        aiPlanSetVariableBool(transportAllUnitsID, cTransportPlanReturnWhenDone, 0, true);
		aiPlanSetVariableBool(transportAllUnitsID, cTransportPlanMaximizeXportMovement, 0, true);
		aiPlanAddUnitType(transportAllUnitsID, cUnitTypeAbstractVillager, 0, 0, num);
		aiPlanAddUnitType(transportAllUnitsID, cUnitTypeHumanSoldier, 1, num, num);
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
    if (ShowAiEcho == true) aiEcho("nomadSearchMode:");
	
    //Make plans to explore with the initial villagers and goats.
    gNomadExplorePlanID1=aiPlanCreate("Nomad Explore 1", cPlanExplore);
    if (gNomadExplorePlanID1 >= 0)
    {
        aiPlanAddUnitType(gNomadExplorePlanID1, cBuilderType, 1, 1, 1);
        aiPlanSetDesiredPriority(gNomadExplorePlanID1, 90);
        aiPlanSetVariableBool(gNomadExplorePlanID1, cExplorePlanDoLoops, 0, false);
        aiPlanSetActive(gNomadExplorePlanID1);
        aiPlanSetEscrowID(gNomadExplorePlanID1);
	}
    gNomadExplorePlanID2=aiPlanCreate("Nomad Explore 2", cPlanExplore);
    if (gNomadExplorePlanID2 >= 0)
    {
        aiPlanAddUnitType(gNomadExplorePlanID2, cBuilderType, 1, 1, 1);
        aiPlanSetDesiredPriority(gNomadExplorePlanID2, 90);
        aiPlanSetVariableBool(gNomadExplorePlanID2, cExplorePlanDoLoops, 0, false);
        aiPlanSetActive(gNomadExplorePlanID2);
        aiPlanSetEscrowID(gNomadExplorePlanID2);
	}
    gNomadExplorePlanID3=aiPlanCreate("Nomad Explore 3", cPlanExplore);
    if (gNomadExplorePlanID3 >= 0)
    {
        aiPlanAddUnitType(gNomadExplorePlanID3, cBuilderType, 1, 2, 2);   // Grab last Egyptian
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
	
    xsDisableRule("earlySettlementTracker");  // Normal settlement-building rule
	
    xsEnableRule("nomadBuildMode");
    xsDisableSelf();
    if (ShowAiEcho == true) aiEcho("Enabling nomadBuildMode");
}

//==============================================================================
rule nomadBuildMode        // Go to build mode when a suitable settlement is found
inactive
minInterval 1 //starts in cAge1
{
	if (ShowAiEcho == true) aiEcho("nomadBuildMode:");
	
    int count = -1;   // How many settlements found?
    static int settlementQuery = -1;    // All gaia settlements
    if (settlementQuery < 0)
    {
        settlementQuery = kbUnitQueryCreate("Nomad Settlement");
        kbUnitQuerySetPlayerID(settlementQuery, 0);
        kbUnitQuerySetUnitType(settlementQuery, cUnitTypeAbstractSettlement);
		kbUnitQuerySetSeeableOnly(settlementQuery, true);
	}
	
    static int builderQuery = -1;      // All builders within 20 meters of a gaia settlement
    if (builderQuery < 0)
    {
        builderQuery = kbUnitQueryCreate("Nomad Builder");
        kbUnitQuerySetPlayerID(builderQuery, cMyID);
        kbUnitQuerySetUnitType(builderQuery, cBuilderType);
        kbUnitQuerySetState(builderQuery, cUnitStateAlive);
		if (cMyCiv == cCivOuranos)
	    kbUnitQuerySetMaximumDistance(builderQuery, 90.0);
		else 
        kbUnitQuerySetMaximumDistance(builderQuery, 30.0);
        kbUnitQuerySetAscendingSort(builderQuery, true);
	}  
	
    kbUnitQueryResetResults(settlementQuery);
    count = kbUnitQueryExecute(settlementQuery);
    if (count < 1)
	return;     // No settlements seen, give up
	
    // Settlements seen, check if you have a builder close by
    if (ShowAiEcho == true) aiEcho("Found "+count+" settlements.");
    int i = -1;
    int settlement = -1;
    int foundSettlement = -1;
	
    for (i=0; < count)
    {
        settlement = kbUnitQueryGetResult(settlementQuery, i);
        if (ShowAiEcho == true) aiEcho("    Checking settlement "+settlement+" at "+kbUnitGetPosition(settlement));
        kbUnitQuerySetPosition(builderQuery, kbUnitGetPosition(settlement));
        kbUnitQueryResetResults(builderQuery);
        if ( kbUnitQueryExecute(builderQuery) > 0)   // Builder nearby
        {
            foundSettlement = settlement;
            if (ShowAiEcho == true) aiEcho("        Builder found, we'll use "+settlement);
            break;
		}
        if (ShowAiEcho == true) aiEcho("        No builders nearby.");
	}
	
    // If we found a usable settlement, build on it.  Otherwise, keep this rule active
    if (foundSettlement < 0)
	return;
	
    // We have one, let's use it and monitor for completion
    
    if (ShowAiEcho == true) aiEcho("Making main base.");
    int newBaseID=kbBaseCreate(cMyID, "Base"+kbBaseGetNextID(), kbUnitGetPosition(settlement), 75.0);
    if (newBaseID > -1)
    {
        //Figure out the front vector.
        vector baseFront=xsVectorNormalize(kbGetMapCenter()-kbUnitGetPosition(settlement));
        kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
        if (ShowAiEcho == true) aiEcho("Setting front vector to "+baseFront);
        //Military gather point.
        vector militaryGatherPoint=kbUnitGetPosition(settlement)+baseFront*18.0;
        kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
        //Set the other flags.
        kbBaseSetMilitary(cMyID, newBaseID, true);
        kbBaseSetEconomy(cMyID, newBaseID, true);
        //Set the resource distance limit.
        kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
        //Add the settlement to the base.
        kbBaseSetSettlement(cMyID, newBaseID, true);
        //Set the main-ness of the base.
        kbBaseSetMain(cMyID, newBaseID, true);
	}
	
    if (ShowAiEcho == true) aiEcho("Main base is "+newBaseID+" "+kbBaseGetMainID(cMyID));
	
    if (ShowAiEcho == true) aiEcho("Creating simple build plan");
	
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
    aiPlanAddUnitType(gNomadSettlementBuildPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 4, 4, 4);
    //Base ID.
    aiPlanSetBaseID(gNomadSettlementBuildPlanID, kbBaseGetMainID(cMyID));
    aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanCenterPosition, 0, kbUnitGetPosition(foundSettlement));
    aiPlanSetVariableFloat(gNomadSettlementBuildPlanID, cBuildPlanCenterPositionDistance, 0, 2.0);
    aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanSettlementPlacementPoint, 0, kbUnitGetPosition(foundSettlement));
    //Go.
    aiPlanSetActive(gNomadSettlementBuildPlanID);
	
	
    if (ShowAiEcho == true) aiEcho("Killing explore plans.");
    aiPlanDestroy(gNomadExplorePlanID1);
    aiPlanDestroy(gNomadExplorePlanID2);
    aiPlanDestroy(gNomadExplorePlanID3);
	
    xsEnableRule("nomadMonitor");
    xsDisableSelf();
    if (ShowAiEcho == true) aiEcho("Activating nomad monitor rule");
}

//==============================================================================
rule nomadMonitor    // Watch the build goal.  When a settlement is up, turn on normal function.  If goal fails, restart.
inactive
minInterval 1 //starts in cAge1
{
    if (ShowAiEcho == true) aiEcho("nomadMonitor:");
	
    if ( (aiPlanGetState(gNomadSettlementBuildPlanID) >= 0) && (aiPlanGetState(gNomadSettlementBuildPlanID) != cPlanStateDone) )
	return;     // Plan exists, is not finished
	
    // plan is done or died.  Check if we have a settlement
    if (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) > 0) // AliveOrBuilding in case state isn't updated instantly
    {  // We have a settlement, go normal
        if (ShowAiEcho == true) aiEcho("Settlement is finished, normal start.");
        xsDisableSelf();
        xsEnableRule("earlySettlementTracker");
        //Turn on fishing.
        if ( cvMapSubType == WATERNOMADMAP )
		xsEnableRule("fishing");      
        //Turn on buildhouse.
        xsEnableRule("buildHouse");
		
        int tc = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
        if ( tc >= 0)   
        {
            // Set main base
            int oldMainBase = kbBaseGetMainID(cMyID);
            if (ShowAiEcho == true) aiEcho("Old main base was "+oldMainBase);
            if (ShowAiEcho == true) aiEcho("Killing early gather plans.");
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
	            ResourceBaseID = CreateBaseInBackLoc(kbUnitGetBaseID(tc), 40, 85, "Temp Resource Base");
			}
            if (ShowAiEcho == true) aiEcho("TC is in base "+kbUnitGetBaseID(tc));
            if (ShowAiEcho == true) aiEcho("New main base is "+kbBaseGetMainID(cMyID));
            vector front = cInvalidVector;
            front = xsVectorNormalize(kbGetMapCenter()-kbUnitGetPosition(tc));
            kbBaseSetFrontVector(cMyID, kbBaseGetMainID(cMyID), front);
            if (ShowAiEcho == true) aiEcho("Front vector is "+front);
            gFarmBaseID = kbBaseGetMainID(cMyID);
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
		}
		
		
        // Fix god power plan for age 1
        aiPlanSetBaseID(gAge1GodPowerPlanID, kbBaseGetMainID(cMyID));
		
		
        // force the temple soon
        createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
        //Unpause the age upgrades.
        aiSetPauseAllAgeUpgrades(false);
        //Unpause the pause kicker.
        xsEnableRule("unPauseAge2");
        xsSetRuleMinInterval("unPauseAge2", 15);
		
	}
    else
    {  // No settlement, restart chain
        if (ShowAiEcho == true) aiEcho("No settlement exists, restart nomad chain.");
        xsEnableRule("nomadSearchMode");
        xsDisableSelf();
	}
}



//==============================================================================
bool mapPreventsRush()  //TODO: this are not all maps that prevent rushes.
{
    if (ShowAiEcho == true) aiEcho("mapPreventsRush:");
    
    if ((cRandomMapName == "vinlandsaga") ||
	(cRandomMapName == "river nile") ||
	(cRandomMapName == "alternate-vinlandsaga") ||
	(cRandomMapName == "amazonas") ||
	(cRandomMapName == "team migration") ||
	(cRandomMapName == "archipelago") ||
	(cRandomMapName == "black sea"))
    {
        return(true);
	}
    else   
	return(false);
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
    if (ShowAiEcho == true) aiEcho("mapPreventsHousesAtTowers:");
    
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
    if (ShowAiEcho == true) aiEcho("mapRestrictsMarketAttack:");
    
    if ((cRandomMapName == "highland")
	|| (cRandomMapName == "watering hole") //TODO: Test if this is really better!
	|| (cRandomMapName == "jotunheim"))
    {
        return(true);
	}
    else
	return(false);
}