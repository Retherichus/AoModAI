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
    aiEcho("Naval Init.");
   
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
    aiEcho("Naval Age "+age+".");

    // Naval (scout other islands etc...)
    if (gTransportMap == true)
    {
        xsEnableRuleGroup("NavalClassical");
    }
    
    if ((cRandomMapName == "anatolia") // TODO: maybe on (cRandomMapName == "highlands") too?
     || (cRandomMapName == "mediterranean"))
        xsEnableRule("NavalGoalMonitor");
}

//==============================================================================
void navalAge3Handler(int age=2)
{
    //aiEcho("Naval Age "+age+".");

    // Naval (build settlements on other islands etc...)
    if (gTransportMap == true)
    {
        xsEnableRuleGroup("NavalHeroic");
    }
}

//==============================================================================
void navalAge4Handler(int age=3)
{
    aiEcho("Naval Age "+age+".");
}

//==============================================================================
int initNavalUnitPicker(string name="BUG", int minShips=5,
   int maxShips=20, int numberBuildings=1, bool bWantSiegeShips=false)
{
    aiEcho("initNavalUnitPicker:");
    
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
//  TODO: we need this here?
    //Min/Max units and Min/Max pop.
//   kbUnitPickSetMinimumPop(upID, minPop);
//   kbUnitPickSetMaximumPop(upID, maxPop);

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
    aiEcho("findOtherSettlements:");
        
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
    minInterval 13 //starts in cAge2
    group NavalClassical
    inactive
{
    aiEcho("NavalGoalMonitor:");

    //Don't do anything in the first age.
    if ((kbGetAge() < cAge2) || (aiGetMostHatedPlayerID() < 0))
        return;

    
    int numMyShips = 0;
    int numMyMilShips = 0;
    int numAlliedMilShips = 0;
    int numEnemyMilShips = 0;
    static int reduceCount = 0;
    int doomedID = -1;
    
    //Test to increase effectiveness on anatolia
    //TODO: rework it as there could be docks on either side of the map!!!
    if (cRandomMapName == "anatolia")
    {
        static int reduceCountBLTL = 0;
        static int reduceCountBRTR = 0;
        static int reduceCountBLBR = 0;
        static int reduceCountTLTR = 0;
        
        static vector centerToUse = cInvalidVector;
        static float radiusToUse = 0.0;
        static int lastUsedDock = -1;
        if (lastUsedDock == -1)
        {
            int dockIDInFishPlan = aiPlanGetVariableInt(gFishPlanID, cFishPlanDockID, 0);
            if (dockIDInFishPlan != -1)
            {
                lastUsedDock = dockIDInFishPlan;
            }
        }
        
        float xMax = kbGetMapXSize();
        float zMax = kbGetMapZSize();
        
        //TODO: check if it works
        //add waypoints to gWaterExploreID
        static bool firstRun = true;
        if (firstRun == true)
        {
            vector bottomLeft = vector(0, 0, 0);
            vector topLeft = vector(0, 0, 0);
            topLeft = xsVectorSetZ(topLeft, zMax);
            vector topRight = vector(0, 0, 0);
            topRight = xsVectorSetX(topRight, xMax);
            topRight = xsVectorSetZ(topRight, zMax);
            vector bottomRight = vector(0, 0, 0);
            bottomRight = xsVectorSetX(bottomRight, xMax);
            aiEcho("bottomLeft: "+bottomLeft);
            aiEcho("topLeft: "+topLeft);
            aiEcho("topRight: "+topRight);
            aiEcho("bottomRight: "+bottomRight);
            aiPlanAddWaypoint(gWaterExploreID, bottomLeft);
            aiPlanAddWaypoint(gWaterExploreID, topLeft);
            aiPlanAddWaypoint(gWaterExploreID, topRight);
            aiPlanAddWaypoint(gWaterExploreID, bottomRight);
            firstRun = false;
        }
        
        //BL = bottom left, TL = top left, BR = bottom right, TR = top right
        vector centerBLTL = vector(5, 0, 0);
        centerBLTL = xsVectorSetZ(centerBLTL, zMax/2);
        
        vector centerBRTR = vector(0, 0, 0);
        centerBRTR = xsVectorSetX(centerBRTR, xMax - 5);
        centerBRTR = xsVectorSetZ(centerBRTR, zMax/2);
        
        vector centerBLBR = vector(0, 0, 5);
        centerBLBR = xsVectorSetX(centerBLBR, xMax/2);
        
        vector centerTLTR = vector(0, 0, 0);
        centerTLTR = xsVectorSetX(centerTLTR, xMax/2);
        centerTLTR = xsVectorSetZ(centerTLTR, zMax - 5);
        
        int areaBLTL = kbAreaGetIDByPosition(centerBLTL);
        int areaBRTR = kbAreaGetIDByPosition(centerBRTR);
        int areaBLBR = kbAreaGetIDByPosition(centerBLBR);
        int areaTLTR = kbAreaGetIDByPosition(centerTLTR);
        
        int areaTypeBLTL = kbAreaGetType(areaBLTL);
        int areaTypeBRTR = kbAreaGetType(areaBRTR);
        int areaTypeBLBR = kbAreaGetType(areaBLBR);
        int areaTypeTLTR = kbAreaGetType(areaTLTR);
        
        if ((areaTypeBLTL == cAreaTypeWater) || (areaTypeBRTR == cAreaTypeWater))
        {
//            int numDocksBLTL = getNumUnits(cUnitTypeDock, cUnitStateAliveOrBuilding, -1, cMyID, centerBLTL, zMax/2);
            int numDocksBLTL = getNumUnits(cUnitTypeDock, cUnitStateAlive, -1, cMyID, centerBLTL, zMax/2);
            //aiEcho("numDocksBLTL: "+numDocksBLTL);
            if (numDocksBLTL > 0)
            {
                int dockIDBLTL = findUnitByIndex(cUnitTypeDock, 0, cUnitStateAlive, -1, cMyID, centerBLTL, zMax/2);
                
                int numMyShipsBLTL = getNumUnits(cUnitTypeShip, cUnitStateAlive, -1, cMyID, centerBLTL, zMax/2);
                int numMyMilShipsBLTL = getNumUnits(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID, centerBLTL, zMax/2);
                int numAlliedMilShipsBLTL = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, centerBLTL, zMax/2);
                int numEnemyMilShipsBLTL = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, centerBLTL, zMax/2);
                
                if ((numMyMilShipsBLTL + numAlliedMilShipsBLTL > numEnemyMilShipsBLTL + 1) && (numMyMilShipsBLTL > 1))
                {
                    reduceCountBLTL = reduceCountBLTL + 1;
                }
                else
                {
                    reduceCountBLTL = 0;
                }
                
                aiEcho("reduceCountBLTL: "+reduceCountBLTL);
                if (reduceCountBLTL > 9)
                {
                    //For now just delete one ship, idle units first    //TODO: create an attack plan to lose ships
                    doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, cActionIdle, cMyID, centerBLTL, zMax/2);
                    if (doomedID < 0)
                        doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID, centerBLTL, zMax/2);
            
                    aiEcho("!!!!!!!");
                    aiEcho("reduceCountBLTL > 9, deleting a military ship: "+doomedID);
                    aiEcho("!!!!!!!");
                    aiTaskUnitDelete(doomedID);
                    reduceCountBLTL = 0;
                }
                
                if ((numMyMilShipsBLTL > numMyMilShips) || (numMyShipsBLTL > numMyShips))
                {
                    numMyShips = numMyShipsBLTL;
                    numMyMilShips = numMyMilShipsBLTL;
                    numAlliedMilShips = numAlliedMilShipsBLTL;
                    numEnemyMilShips = numEnemyMilShipsBLTL;
                    centerToUse = centerBLTL;
                    radiusToUse = zMax/2;
                }
            }
            
//            int numDocksBRTR = getNumUnits(cUnitTypeDock, cUnitStateAliveOrBuilding, -1, cMyID, centerBRTR, zMax/2);
            int numDocksBRTR = getNumUnits(cUnitTypeDock, cUnitStateAlive, -1, cMyID, centerBRTR, zMax/2);
            //aiEcho("numDocksBRTR: "+numDocksBRTR);
            if (numDocksBRTR > 0)
            {
                int dockIDBRTR = findUnitByIndex(cUnitTypeDock, 0, cUnitStateAlive, -1, cMyID, centerBRTR, zMax/2);
                
                int numMyShipsBRTR = getNumUnits(cUnitTypeShip, cUnitStateAlive, -1, cMyID, centerBRTR, zMax/2);
                int numMyMilShipsBRTR = getNumUnits(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID, centerBRTR, zMax/2);
                int numAlliedMilShipsBRTR = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, centerBRTR, zMax/2);
                int numEnemyMilShipsBRTR = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, centerBRTR, zMax/2);
            
                if ((numMyMilShipsBRTR + numAlliedMilShipsBRTR > numEnemyMilShipsBRTR + 1) && (numMyMilShipsBRTR > 1))
                {
                    reduceCountBRTR = reduceCountBRTR + 1;
                }
                else
                {
                    reduceCountBRTR = 0;
                }
                    
                aiEcho("reduceCountBRTR: "+reduceCountBRTR);
                if (reduceCountBRTR > 9)
                {
                    //For now just delete one ship, idle units first    //TODO: create an attack plan to lose ships
                    doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, cActionIdle, cMyID, centerBRTR, zMax/2);
                    if (doomedID < 0)
                        doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID, centerBRTR, zMax/2);
            
                    aiEcho("!!!!!!!");
                    aiEcho("reduceCountBRTR > 9, deleting a military ship: "+doomedID);
                    aiEcho("!!!!!!!");
                    aiTaskUnitDelete(doomedID);
                    reduceCountBRTR = 0;
                } 
                
                if ((numMyMilShipsBRTR > numMyMilShips) || (numMyShipsBRTR > numMyShips) || (numDocksBLTL < 1))
                {
                    numMyShips = numMyShipsBRTR;
                    numMyMilShips = numMyMilShipsBRTR;
                    numAlliedMilShips = numAlliedMilShipsBRTR;
                    numEnemyMilShips = numEnemyMilShipsBRTR;
                    centerToUse = centerBRTR;
                    radiusToUse = zMax/2;
                }
            }
        }
        else if ((areaTypeBLBR == cAreaTypeWater) || (areaTypeTLTR == cAreaTypeWater))
        {
//            int numDocksBLBR = getNumUnits(cUnitTypeDock, cUnitStateAliveOrBuilding, -1, cMyID, centerBLBR, xMax/2);
            int numDocksBLBR = getNumUnits(cUnitTypeDock, cUnitStateAlive, -1, cMyID, centerBLBR, xMax/2);
            //aiEcho("numDocksBLBR: "+numDocksBLBR);
            if (numDocksBLBR > 0)
            {
                int dockIDBLBR = findUnitByIndex(cUnitTypeDock, 0, cUnitStateAlive, -1, cMyID, centerBLBR, xMax/2);
                
                int numMyShipsBLBR = getNumUnits(cUnitTypeShip, cUnitStateAlive, -1, cMyID, centerBLBR, xMax/2);
                int numMyMilShipsBLBR = getNumUnits(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID, centerBLBR, xMax/2);
                int numAlliedMilShipsBLBR = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, centerBLBR, xMax/2);
                int numEnemyMilShipsBLBR = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, centerBLBR, xMax/2);
                
                if ((numMyMilShipsBLBR + numAlliedMilShipsBLBR > numEnemyMilShipsBLBR + 1) && (numMyMilShipsBLBR > 1))
                {
                    reduceCountBLBR = reduceCountBLBR + 1;
                }
                else
                {
                    reduceCountBLBR = 0;
                }
                
                aiEcho("reduceCountBLBR: "+reduceCountBLBR);
                if (reduceCountBLBR > 9)
                {
                    //For now just delete one ship, idle units first    //TODO: create an attack plan to lose ships
                    doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, cActionIdle, cMyID, centerBLBR, xMax/2);
                    if (doomedID < 0)
                        doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID, centerBLBR, xMax/2);
            
                    aiEcho("!!!!!!!");
                    aiEcho("reduceCountBLBR > 9, deleting a military ship: "+doomedID);
                    aiEcho("!!!!!!!");
                    aiTaskUnitDelete(doomedID);
                    reduceCountBLBR = 0;
                }
                
                if ((numMyMilShipsBLBR > numMyMilShips) || (numMyShipsBLBR > numMyShips))
                {
                    numMyShips = numMyShipsBLBR;
                    numMyMilShips = numMyMilShipsBLBR;
                    numAlliedMilShips = numAlliedMilShipsBLBR;
                    numEnemyMilShips = numEnemyMilShipsBLBR;
                    centerToUse = centerBLBR;
                    radiusToUse = xMax/2;
                }
            }
            
//            int numDocksTLTR = getNumUnits(cUnitTypeDock, cUnitStateAliveOrBuilding, -1, cMyID, centerTLTR, xMax/2);
            int numDocksTLTR = getNumUnits(cUnitTypeDock, cUnitStateAlive, -1, cMyID, centerTLTR, xMax/2);
            //aiEcho("numDocksTLTR: "+numDocksTLTR);
            if (numDocksTLTR > 0)
            {
                int dockIDTLTR = findUnitByIndex(cUnitTypeDock, 0, cUnitStateAlive, -1, cMyID, centerTLTR, xMax/2);
                
                int numMyShipsTLTR = getNumUnits(cUnitTypeShip, cUnitStateAlive, -1, cMyID, centerTLTR, xMax/2);
                int numMyMilShipsTLTR = getNumUnits(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID, centerTLTR, xMax/2);
                int numAlliedMilShipsTLTR = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, centerTLTR, xMax/2);
                int numEnemyMilShipsTLTR = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, centerTLTR, xMax/2);
              
                if ((numMyMilShipsTLTR + numAlliedMilShipsTLTR > numEnemyMilShipsTLTR + 1) && (numMyMilShipsTLTR > 1))
                {
                    reduceCountTLTR = reduceCountTLTR + 1;
                }
                else
                {
                    reduceCountTLTR = 0;
                }
                
                aiEcho("reduceCountTLTR: "+reduceCountTLTR);
                if (reduceCountTLTR > 9)
                {
                    //For now just delete one ship, idle units first    //TODO: create an attack plan to lose ships
                    doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, cActionIdle, cMyID, centerTLTR, xMax/2);
                    if (doomedID < 0)
                        doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID, centerTLTR, xMax/2);
            
                    aiEcho("!!!!!!!");
                    aiEcho("reduceCountTLTR > 9, deleting a military ship: "+doomedID);
                    aiEcho("!!!!!!!");
                    aiTaskUnitDelete(doomedID);
                    reduceCountTLTR = 0;
                }
                
                if ((numMyMilShipsTLTR > numMyMilShips) || (numMyShipsTLTR > numMyShips) || (numDocksBLBR < 1))
                {
                    numMyShips = numMyShipsTLTR;
                    numMyMilShips = numMyMilShipsTLTR;
                    numAlliedMilShips = numAlliedMilShipsTLTR;
                    numEnemyMilShips = numEnemyMilShipsTLTR;
                    centerToUse = centerTLTR;
                    radiusToUse = xMax/2;
                }
            }
        }
        
        if (equal(centerToUse, cInvalidVector) == false)
        {
            int dockIDToUse = findUnitByIndex(cUnitTypeDock, 0, cUnitStateAlive, -1, cMyID, centerToUse, radiusToUse);
            aiEcho("dockIDToUse: "+dockIDToUse);
            if (dockIDToUse != -1)
            {
                aiEcho("lastUsedDock: "+lastUsedDock);
                if (lastUsedDock != dockIDToUse)
                {
                    aiEcho("lastUsedDock != dockIDToUse, killing old gFishPlanID and restarting fishing rule");
                    lastUsedDock = dockIDToUse;
                    aiPlanDestroy(gFishPlanID);
                    gFishPlanID = -1;
                    gDockToUse = dockIDToUse;
                    xsEnableRule("fishing");
                }
            }
        }
    }
    else    //all other maps
    {
        numMyShips = kbUnitCount(cMyID, cUnitTypeShip, cUnitStateAlive);
        numMyMilShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
        numAlliedMilShips = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationAlly);
        numEnemyMilShips = getNumUnitsByRel(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy);
        
        if ((numMyMilShips + numAlliedMilShips > numEnemyMilShips + 1) && (numMyMilShips > 1))
        {
            reduceCount = reduceCount + 1;
        }
        else
        {
            reduceCount = 0;
        }
        
        aiEcho("reduceCount: "+reduceCount);
        if (reduceCount > 9)
        {
            //For now just delete one ship, idle units first    //TODO: create an attack plan to lose ships
            doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, cActionIdle, cMyID);
            if (doomedID < 0)
                doomedID = findUnit(cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive, -1, cMyID);
            
            aiEcho("!!!!!!!");
            aiEcho("ReduceCount > 9, deleting a military ship: "+doomedID);
            aiEcho("!!!!!!!");
            aiTaskUnitDelete(doomedID);
            reduceCount = 0;
        }
    }

    aiEcho("numMyShips: "+numMyShips);
    aiEcho("numMyMilShips: "+numMyMilShips);
    aiEcho("numAlliedMilShips: "+numAlliedMilShips);
    aiEcho("numEnemyMilShips: "+numEnemyMilShips);

        
    //Figure out the min/max number of warships we want.
    int minShips = 0;
//    int maxShips = 0;
    int maxShips = 1;
    if (numEnemyMilShips > 0)
    {
        //Build at most 2 ships on easy.
        if (aiGetWorldDifficulty() == cDifficultyEasy)
        {
            minShips = 1;
            maxShips = 2;
        }
        //Build at most "6" ships on moderate.
        else if (aiGetWorldDifficulty() == cDifficultyModerate)
        {
            minShips = (numEnemyMilShips - numAlliedMilShips + 1) * 0.5;
            maxShips = (numEnemyMilShips - numAlliedMilShips + 1) * 0.75;
            if (minShips < 1)
                minShips = 1;
            if (maxShips < 1)
                maxShips = 1;
            if (minShips > 3)
                minShips = 3;
            if (maxShips > 6)
                maxShips = 6;
        } 
        //Build the "same" number (within reason) on Hard/Titan.
        else
        {
            minShips = (numEnemyMilShips - numAlliedMilShips + 1) * 0.75;
            maxShips = (numEnemyMilShips - numAlliedMilShips + 1);
            if (minShips < 1)
                minShips = 1;
            if (maxShips < 1)
                maxShips = 1;
            if (minShips > 5)
                minShips = 5;
            if (maxShips > 8)
                maxShips = 8;
        }
    }
    
    //If this is enabled on KOTH, that means we have the water version.  Pretend the enemy
    //has lots of boats so that we will have lots, too.
    if (cvRandomMapName == "king of the hill")
    {
        minShips = 6;
        maxShips = 12;
    }

    //  At 2-3 pop each, don't let this take up most of our military space.
    if (maxShips > aiGetMilitaryPop() / 5)
        maxShips = aiGetMilitaryPop() / 5;

    if (minShips > maxShips)
        minShips = maxShips;
        
    aiEcho("minShips: "+minShips+", maxShips: "+maxShips);
    aiEcho("--,,--,,--,,--");

//    gTargetNavySize = maxShips;   // Set the global var for forecasting

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
            if (maxShips < 3)
            {
                kbUnitPickSetDesiredNumberUnitTypes(gNavalUPID, maxShips, 2, true);
            }
            else
            {
                kbUnitPickSetDesiredNumberUnitTypes(gNavalUPID, 3, 2, true);
            }
            kbUnitPickSetMinimumNumberUnits(gNavalUPID, minShips);
            kbUnitPickSetMaximumNumberUnits(gNavalUPID, maxShips);
        }
        
        if (numEnemyMilShips < 1)
        {
            kbUnitPickSetPreferenceFactor(gNavalUPID, cUnitTypeHammerShip, 0.0);
//            aiPlanSetVariableBool(gNavalAttackGoalID, cGoalPlanIdleAttack, 0, true);
        }
        else
        {
            kbUnitPickSetPreferenceFactor(gNavalUPID, cUnitTypeHammerShip, 1.0);
//            aiPlanSetVariableBool(gNavalAttackGoalID, cGoalPlanIdleAttack, 0, false);
        }
        
        return;
    }

    //Else, we don't have a Naval attack goal yet.  If we don't want any ships,
    //just return.
    if (maxShips <= 0)
        return;
    
    //Else, create the Naval attack goal.
    aiEcho("Creating NavalAttackGoal for "+maxShips+" ships");
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
    
    if (maxShips < 3)
    {
        kbUnitPickSetDesiredNumberUnitTypes(gNavalUPID, maxShips, 2, true);
    }
    else
    {
        kbUnitPickSetDesiredNumberUnitTypes(gNavalUPID, 3, 2, true);
    }
    
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
    aiEcho("isFullyExplored:");

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

    //aiEcho("isFullyExplored: AGID="+areaGroupID+" numTiles="+numTiles+" numBlack="+numTilesBlack+".");
    float blackPct = numTilesBlack / numTiles;
    //aiEcho("                 blackPct="+blackPct+".");
    //aiEcho("                 epsilon="+epsilon);

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
    aiEcho("setupExploreIsland:");

    int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
    if (transportPUID < 0)
    {
        //aiEcho("setupExploreIsland: no water transport unit type");
        return(-1);
    }

    // we don't have a transport yet, return...
    if ( kbUnitCount(cMyID, transportPUID, cUnitStateAlive) <= 0 )
    {
        //aiEcho("setupExploreIsland: no water transport unit yet, return!");
        return(-2);
    }

    // find target area
    int targetAreaID = -1;
    int areaNum = kbAreaGetNumber();
    int j=-1;
    int potentialIsland=-1;
    bool goon=false;

    //aiEcho("    areaNum="+areaNum);
    // We cannot test all areas since this would take too long and can cause AoM to crash.
    // We therefore make 16 random guesses and hope to find an areagroup we havent been to yet.
    // If we cannot find an appropriate area we hope for better luck next time.
    // We have the risk not to find an area, but we have the upper bound of 16 times this loop compared to
    // some hundred times. This is O(1) compared to O(n)
    // A nice sideeffect is that not all admirals have the same order of exploring islands.
    int max = 16;
    if (cMyCulture == cCultureAtlantean)
        max = 9;
//    for (k = 0; < 16)
    for (k = 0; < max)
    {
        int i = aiRandInt(areaNum);
        // we need land!
        if (kbAreaGetType(i) == cAreaTypeWater)
            continue;

        potentialIsland = getAreaGroupByArea(i);

        //aiEcho("    potential island="+potentialIsland);
        // check if this is an area group we been to already
        for (j=0; < aiPlanGetNumberUserVariableValues(gExploreIslandsGoalID, cExploredAreaGroups))
        {
            int jAGID=aiPlanGetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, j);
            //aiEcho("    jAGID="+jAGID);

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
        //aiEcho("setupExploreIsland: no target area found, return!");
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

    // TEST
    //aiEcho("Already explored area groups are:");

/* disabled
    for (j=0; <aiPlanGetNumberUserVariableValues(gExploreIslandsGoalID, cExploredAreaGroups))
    {
        aiEcho("   AGID="+aiPlanGetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, j));
    }
*/

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
    //aiEcho("setupExploreIsland: creating transport plan!");
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
        aiEcho("setupExploreIsland: cannot create transport plan! return"); 

    //aiEcho("create new base for area group ID="+potentialIsland+".");
    // dunno if this is enough...
    vector center=kbAreaGetCenter(targetAreaID);
    gCurExploredIslandBase = kbBaseCreate(cMyID, "Island Base "+kbBaseGetNextID(), center, 50.0);
    if ( gCurExploredIslandBase >= 0 )
    {
        kbBaseSetActive(cMyID, gCurExploredIslandBase, true);
        kbBaseSetEconomy(cMyID, gCurExploredIslandBase, true);
        kbBaseSetMilitary(cMyID, gCurExploredIslandBase, true);
    }

    //aiEcho("create new explore plan for area group ID="+potentialIsland+".");

    // destroy old explore plan
    aiPlanDestroy(gLandExplorePlanID);
    gLandExplorePlanID=-1;
    gLandExplorePlanID=aiPlanCreate("Explore Island"+potentialIsland, cPlanExplore);
    if (gLandExplorePlanID >= 0)
    {
        if (cMyCulture == cCultureAtlantean )
        {
            aiPlanAddUnitType(gLandExplorePlanID, cUnitTypeOracleScout, 0, 1, 1);
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);
            aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanOracleExplore, 0, true);
            aiPlanSetDesiredPriority(gLandExplorePlanID, 25);  // Allow oracleHero relic plan to steal one
        }
        else
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
    aiEcho("exploreIslands:");
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
        //aiEcho("exploreIslands: island is fully explored, setup new explore plan!");
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
                //aiEcho("exploreIslands: disabling rule because we have all area groups explored!");
                xsDisableSelf();
                return;
            }
        }
    }
    else
        xsSetRuleMinIntervalSelf(26);
}
