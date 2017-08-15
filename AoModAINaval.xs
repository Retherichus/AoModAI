//==============================================================================
// AoMod AI
// AoModAINaval.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// Handles naval behavior.
//==============================================================================

extern const int cExploredAreaGroups=1;
extern const int cNumberOfExploredIslands=8;
extern int gExploreIslandsGoalID=-1;
extern int gCurExploredIslandBase=-1;
extern int gRemoteIslandExploreTrans=-1;


//==============================================================================
void initNaval()
{
    if (ShowAiEcho == true) aiEcho("Naval Init.");
   
    //Get our initial location.
    vector here=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    gCurExploredIslandBase = kbBaseGetMainID(cMyID);
    if (gTransportMap == true)  //TODO: Check if we need this goal at all; if not remove it
    {
        gExploreIslandsGoalID=aiPlanCreate("Islands Explore Goal", cPlanGoal);
        aiPlanSetActive(gExploreIslandsGoalID);
        aiPlanAddUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, "ExploredAreaGroups", cNumberOfExploredIslands);
        aiPlanSetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, 0, kbAreaGroupGetIDByPosition(here));
        for (i=1;<cNumberOfExploredIslands)
        {
            aiPlanSetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, i, -1);
        }
    }
}

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
	 || (cRandomMapName == "midgard"))
        xsEnableRule("NavalGoalMonitor");
}

//==============================================================================
void navalAge3Handler(int age=2)
{

    // Naval (build settlements on other islands etc...)
    if (gTransportMap == true)
    {
        xsEnableRuleGroup("NavalHeroic");
    }
}

//==============================================================================
void navalAge4Handler(int age=3)
{
    if (ShowAiEcho == true) aiEcho("Naval Age "+age+".");
}

//==============================================================================
int initNavalUnitPicker(string name="BUG", int minShips=5,
   int maxShips=20, int numberBuildings=1, bool bWantSiegeShips=false)
{
    if (ShowAiEcho == true) aiEcho("initNavalUnitPicker:");
    
    //Create it.
    int upID=kbUnitPickCreate(name);
    if (upID < 0)
        return(-1);

    //Default init.
    kbUnitPickResetAll(upID);
    //0 Part Preference, 1 Parts CE, 0 Parts Cost.
    kbUnitPickSetPreferenceWeight(upID, 1.0);
    kbUnitPickSetCombatEfficiencyWeight(upID, 2.0);
    kbUnitPickSetCostWeight(upID, 1.0);
    kbUnitPickSetMinimumNumberUnits(upID, minShips);
    kbUnitPickSetMaximumNumberUnits(upID, maxShips);
    kbUnitPickSetAttackUnitType(upID, cUnitTypeLogicalTypeNavalMilitary);
    kbUnitPickSetGoalCombatEfficiencyType(upID, cUnitTypeLogicalTypeNavalMilitary);
    kbUnitPickSetMovementType(upID, cMovementTypeWater);

    //Desired number units types, buildings.
    kbUnitPickSetDesiredNumberUnitTypes(upID, 3, numberBuildings, false);


    //Do the preference work now.
    int choice = aiRandInt(2);
    if ( bWantSiegeShips == false )
    {
        if ( choice == 0 )
        {
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeArcherShip, 0.3);
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeHammerShip, 0.3);
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeSiegeShip, 0.0);
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.4);
        }
        else
        {
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeArcherShip, 0.5);
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeHammerShip, 0.3);
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeSiegeShip, 0.0);
            kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.2);
        }
    }
    else
    {
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeArcherShip, 0.2);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeHammerShip, 0.2);
        kbUnitPickSetPreferenceFactor(upID, cUnitTypeSiegeShip, 0.6);
    }

    //Done.
    return(upID);
}

//==============================================================================
rule findOtherSettlements
    minInterval 40 //starts in cAge3
    group NavalHeroic
    inactive
{
    if (ShowAiEcho == true) aiEcho("findOtherSettlements:");
    int ActivePlans = findPlanByString("Remote Settlement Transport", cPlanTransport, -1, true);
	if (ActivePlans >= 1)
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

    // been there, done that
    if ( equal(gTransportToSettlementPos, there) )
        return;

    claimSettlement(there);

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
			tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipGreek, cUnitStateAlive)/2;
			tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipNorse, cUnitStateAlive)/2;
			tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipAtlantean, cUnitStateAlive)/2;
			tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipEgyptian, cUnitStateAlive)/2;
			tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipChinese, cUnitStateAlive)/2;
		 }
		 //int tempNumberEnemyDocks=kbUnitCount(i, cUnitTypeDock, cUnitStateAlive);
		 if (tempNumberEnemyWarships > numberEnemyWarships)
			numberEnemyWarships=tempNumberEnemyWarships;
	  }
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
		 if (minShips < 5)
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
}

//==============================================================================
bool isFullyExplored(int areaGroupID=-1)    //returns true, if more than 80% of the specified areagroup is nonblack.
{
    if (ShowAiEcho == true) aiEcho("isFullyExplored:");

    float numTilesBlack = 0;
    float numTiles = 0;

    int num = kbAreaGetNumber();
   
    for ( i = 0; < num )
    {
        // not our island
        if ( getAreaGroupByArea(i) != areaGroupID )
            continue;

        numTiles = numTiles + kbAreaGetNumberTiles(i);
        numTilesBlack = numTilesBlack + kbAreaGetNumberBlackTiles(i);
    }

    static float epsilon=0.0;
    static int AGID=-1;
    if (areaGroupID==AGID)
        epsilon=epsilon+0.05;

    float blackPct = numTilesBlack / numTiles;

    // we leave some tolerance => the island does not have to be *fully* explored
    if ( blackPct <= epsilon )
    {
        AGID=-1;
        return ( true );
    }
    else
    {
        AGID=areaGroupID;
        return( false );
    }
}

//==============================================================================
// setupExploreIsland 
// find an area that belongs to an areagroup we have'nt explored yet and that
// is visible. If we have found such area, create transport plan from the
// currently explored island to that newly found area. Afterwards, destroy current
// explore plan and create a new one for the new island.
// returns 1 if the setup was successful
// else
// -1 if total failure
// -2 if no transport yet
//==============================================================================
int setupExploreIsland()
{
    if (ShowAiEcho == true) aiEcho("setupExploreIsland:");

    int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
    if (transportPUID < 0)
    {
        return(-1);
    }

    // we don't have a transport yet, return...
    if ( kbUnitCount(cMyID, transportPUID, cUnitStateAlive) <= 0 )
    {
        return(-2);
    }

    // find target area
    int targetAreaID = -1;
    int areaNum = kbAreaGetNumber();
    int j=-1;
    int potentialIsland=-1;
    bool goon=false;

    // We cannot test all areas since this would take too long and can cause AoM to crash.
    // We therefore make 16 random guesses and hope to find an areagroup we havent been to yet.
    // If we cannot find an appropriate area we hope for better luck next time.
    // We have the risk not to find an area, but we have the upper bound of 16 times this loop compared to
    // some hundred times. This is O(1) compared to O(n)
    // A nice sideeffect is that not all admirals have the same order of exploring islands.
    int max = 16;
    if (cMyCulture == cCultureAtlantean)
        max = 9;
    for (k = 0; < max)
    {
        int i = aiRandInt(areaNum);
        // we need land!
        if (kbAreaGetType(i) == cAreaTypeWater)
            continue;

        potentialIsland = getAreaGroupByArea(i);

        // check if this is an area group we been to already
        for (j=0; < aiPlanGetNumberUserVariableValues(gExploreIslandsGoalID, cExploredAreaGroups))
        {
            int jAGID=aiPlanGetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, j);

            if (jAGID < 0)
                break;
            if (potentialIsland == jAGID)
            {
                goon=true;
                break;
            }
        }
        if (goon==true)
        {
            goon=false;
            continue;
        }

        targetAreaID=verifyVinlandsagaBase(i, 2);
        if (targetAreaID >= 0 )
            break;
    }
   
    // we have no target area
    if ( targetAreaID < 0 )
    {
        return(-3); // no transport possible, we have no target area
    }

    // remember the area group (island) we explored
    int nextFreeSlot=-1;
    // start at 1, because 0 is always our home.
    for (j=1; <aiPlanGetNumberUserVariableValues(gExploreIslandsGoalID, cExploredAreaGroups))
    {
        if (aiPlanGetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, j) == -1)
        {
            nextFreeSlot=j;
            break;
        }
    }

    // all slots used.
    if (nextFreeSlot < 0)
        return(-1);

    aiPlanSetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, nextFreeSlot, potentialIsland);




    int baseToUse=kbBaseGetMain(cMyID);
    static int scoutQuery=-1;
    if (scoutQuery < 0)
        scoutQuery=kbUnitQueryCreate("Island Scout Query");
    configQuery(scoutQuery, gLandScout, cUnitStateAlive, cActionAny, cMyID);
    kbUnitQuerySetAreaGroupID(scoutQuery, aiPlanGetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, nextFreeSlot-1));
    if (kbUnitQueryExecute(scoutQuery) > 0)
        baseToUse=gCurExploredIslandBase;
    //Get the location of the currently active explore plan
    vector here=kbBaseGetLocation(cMyID, baseToUse);
    //Get our start area ID.
    int startAreaID=kbAreaGetIDByPosition(here);
   
    //Create transport plan to explore the other island.
    aiPlanDestroy(gRemoteIslandExploreTrans);
    gRemoteIslandExploreTrans=createTransportPlan("Remote Explore Trans", startAreaID,
                                                targetAreaID, false, transportPUID, 99, baseToUse);
    if ( gRemoteIslandExploreTrans >= 0 )
    {
        aiPlanAddUnitType( gRemoteIslandExploreTrans, gLandScout, 1, 1, 1 );
        aiPlanSetRequiresAllNeedUnits( gRemoteIslandExploreTrans, true );
        aiPlanSetActive(gRemoteIslandExploreTrans, true);
    }
    else
        if (ShowAiEcho == true) aiEcho("setupExploreIsland: cannot create transport plan! return"); 

    // dunno if this is enough...
    vector center=kbAreaGetCenter(targetAreaID);
    gCurExploredIslandBase = kbBaseCreate(cMyID, "Island Base "+kbBaseGetNextID(), center, 50.0);
    if ( gCurExploredIslandBase >= 0 )
    {
        kbBaseSetActive(cMyID, gCurExploredIslandBase, true);
        kbBaseSetEconomy(cMyID, gCurExploredIslandBase, true);
        kbBaseSetMilitary(cMyID, gCurExploredIslandBase, true);
    }


    // destroy old explore plan
    aiPlanDestroy(gLandExplorePlanID);
    gLandExplorePlanID=-1;
    gLandExplorePlanID=aiPlanCreate("Explore Island"+potentialIsland, cPlanExplore);
    if (gLandExplorePlanID >= 0)
    {
            aiPlanAddUnitType(gLandExplorePlanID, gLandScout, 1, 1, 1);

        aiPlanSetEscrowID(gLandExplorePlanID, cEconomyEscrowID);
        aiPlanSetBaseID(gLandExplorePlanID, gCurExploredIslandBase);
        if (cMyCulture == cCultureNorse )
            aiPlanSetDesiredPriority(gLandExplorePlanID, 99); // for norse. don't let build plans steal our scout.
        else if (cMyCulture != cCultureAtlantean )
            aiPlanSetDesiredPriority(gLandExplorePlanID, 80);
        aiPlanSetInitialPosition(gLandExplorePlanID, center);
        aiPlanSetVariableFloat(gLandExplorePlanID, cExplorePlanLOSMultiplier, 0, 1.7);
        if (cMyCulture == cCultureEgyptian)
        {
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanCanBuildLOSProto, 0, true);
        }
        else if (cMyCulture != cCultureAtlantean )
        {
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, true);
            aiPlanSetVariableInt(gLandExplorePlanID, cExplorePlanNumberOfLoops, 0, 2);
        }
        aiPlanSetActive(gLandExplorePlanID);
    }

    return(1);
}

//==============================================================================
// RULE exploreIslands
// periodically check, if we have fully explored the current island.
// as soon as 80% of the island is visible, setup an explore plan for another
// island
//==============================================================================
rule exploreIslands
    minInterval 26 //starts in cAge2
    group NavalClassical
    inactive
{
    if (ShowAiEcho == true) aiEcho("exploreIslands:");
    static int numTries=0;

    // only the captain does this, everyting else costs too much
    // computation power and causes aom to crash
    if ((aiGetCaptainPlayerID(cMyID) != cMyID) || (cvDoExploreOtherIslands == false))
    {
        xsDisableSelf();
        return;
    }

    // find out the areagroupid of the currently explored island
    vector explorePos = aiPlanGetLocation(gLandExplorePlanID);
    int curAreaGroupID = kbAreaGroupGetIDByPosition(explorePos);
    if ( curAreaGroupID < 0 )
        return;

    // if the currenly explored island is (almost) fully explored,
    // setup new explore plan
    if ( isFullyExplored(curAreaGroupID) == true )
    {
        // setup new plan for another island
        int result=setupExploreIsland();
        if ( result == 1 )
        {
            // we have just setup a new plan, let the scout go for a while...
            xsSetRuleMinIntervalSelf(127);
            numTries=0;
            return;
        }
        else if (result == -1) // total failure or all explored
        {
            xsDisableSelf();
            return;
        }
        else if (result == -2) // no transport yet. Just wait
        {
            return;
        }
        else // no target area found.
        {
            // disable rule if failed three times in a row.
            // we assume that we have all area groups explored.
            numTries=numTries+1;
            if (numTries >= 3)
            {
                xsDisableSelf();
                return;
            }
        }
    }
    else
        xsSetRuleMinIntervalSelf(26);
}
