//==============================================================================
// ADMIRAL X
// admiralnaval.xs
// by Georg Kalus   MWD_kalus@web.de
// created with VIM
//
// Handles naval behaviour.
//==============================================================================

extern const int cExploredAreaGroups=1;
extern const int cNumberOfExploredIslands=8;
extern int gExploreIslandsGoalID=-1;
extern int gCurExploredIslandBase=-1;
extern int gRemoteIslandExploreTrans=-1;

//==============================================================================
// initNaval
//==============================================================================
void initNaval()
{
   OUTPUT("Naval Init.", INFO);
   
   //Get our initial location.
   vector here=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
   gCurExploredIslandBase = kbBaseGetMainID(cMyID);
   gExploreIslandsGoalID=aiPlanCreate("Islands Explore Goal", cPlanGoal);
   aiPlanSetActive(gExploreIslandsGoalID);
   aiPlanAddUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, "ExploredAreaGroups", cNumberOfExploredIslands);
   aiPlanSetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, 0, kbAreaGroupGetIDByPosition(here));
   for (i=1;<cNumberOfExploredIslands)
   {
      aiPlanSetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, i, -1);
   }
}

//==============================================================================
// navalAge2Handler
//==============================================================================
void navalAge2Handler(int age=1)
{
   OUTPUT("Naval Age "+age+".", TRACE);

   // Naval (scout other islands etc...)
   if (gTransportMap)
   {
      xsEnableRuleGroup("NavalClassical");
      OUTPUT("Enabled NavalClassical rule-group.", INFO);
   }
}

//==============================================================================
// navalAge3Handler
//==============================================================================
void navalAge3Handler(int age=2)
{
   OUTPUT("Naval Age "+age+".", TRACE);

   // Naval (build settlements on other islands etc...)
   if (gTransportMap)
   {
      xsEnableRuleGroup("NavalHeroic");
      OUTPUT("Enabled NavalHeroic rule-group.", ECONINFO);
   }
}

//==============================================================================
// navalAge4Handler
//==============================================================================
void navalAge4Handler(int age=3)
{
   OUTPUT("Naval Age "+age+".", TRACE);
}

//==============================================================================
// initNavalUnitPicker
//==============================================================================
int initNavalUnitPicker(string name="BUG", int minShips=5,
   int maxShips=20, int numberBuildings=1, bool bWantSiegeShips=false)
{

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
// TODO: we need this here?
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
// findOtherSettlements 
//==============================================================================
rule findOtherSettlements
   minInterval 40
   group NavalHeroic
   inactive
{
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
// attackBaseGenerator 
//==============================================================================
rule attackBaseGenerator
   minInterval 5
   inactive
   group NavalClassical
{
   if(persWantForwardBase() == false)
   {
      xsDisableSelf();
      return;
   }

   int shipUnitTypeID=cUnitTypeBireme;
   int raxUnitTypeID=cUnitTypeBarracksAtlantean;
   if(cMyCulture==cCultureNorse)
   {
      shipUnitTypeID=cUnitTypeLongboat;
      raxUnitTypeID=cUnitTypeLonghouse;
   }
   else if(cMyCulture==cCultureEgyptian)
   {
      shipUnitTypeID=cUnitTypeKebenit;
      raxUnitTypeID=cUnitTypeBarracks;
   }
   else if(cMyCulture==cCultureGreek)
   {
      shipUnitTypeID=cUnitTypeTrireme;
      raxUnitTypeID=cUnitTypeAcademy;
   }


   int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
   if (transportPUID < 0)
   {
      OUTPUT("attackBaseGenerator: no water transport unit type", FAILURE);
      xsDisableSelf();
      return;
   }

   static bool builtShips=false;
   if(builtShips==false)
   {
      int maintainPlan=createSimpleMaintainPlan(shipUnitTypeID, 2, false, -1);
      aiPlanSetEscrowID(maintainPlan, cMilitaryEscrowID);
      aiPlanSetDesiredPriority(maintainPlan, 99);
      addUnitForecast(shipUnitTypeID, 2);
      builtShips=true;
   }
   
   // we don't have a transport yet, return...
   if ( kbUnitCount(cMyID, transportPUID, cUnitStateAlive) <= 0 )
   {
      OUTPUT("attackBaseGenerator: no water transport unit yet, return!", MILWARN);
      return;
   }

   vector forwardBaseLoc=findForwardBasePos();

   // create base there
   int newBaseID=kbBaseCreate(cMyID, "Forward Base"+kbBaseGetNextID(), forwardBaseLoc, 25.0);
   if (newBaseID > -1)
   {
      //Figure out the front vector.
      vector baseFront=xsVectorNormalize(kbGetMapCenter()-forwardBaseLoc);
      kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
      //Military gather point.
      kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, forwardBaseLoc);
      //Set the other flags.
      kbBaseSetMilitary(cMyID, newBaseID, true);
      kbBaseSetEconomy(cMyID, newBaseID, false);
      //Set the forward-ness of the base.
      kbBaseSetForward(cMyID, newBaseID, true);
      kbBaseSetActive(cMyID, newBaseID, true);
   }

   gForwardBaseID=newBaseID;

   // transport builders there
   int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMain(cMyID)));
   int targetAreaID=kbAreaGetIDByPosition(forwardBaseLoc);
   int attackBaseTrans = createTransportPlan("Attack Base Transport", startAreaID,
                              targetAreaID, false, transportPUID, 100, kbBaseGetMainID(cMyID));
   if (attackBaseTrans >= 0)
   {
      aiPlanAddUnitType(attackBaseTrans, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 3, 3, 3 );
      int numUnits=kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
      OUTPUT("Number military land units="+numUnits, TEST);
      aiPlanAddUnitType(attackBaseTrans, cUnitTypeLogicalTypeLandMilitary, numUnits/2, numUnits*3/4, numUnits);
      aiPlanSetRequiresAllNeedUnits( attackBaseTrans, true );
      aiPlanSetVariableVector(attackBaseTrans, cTransportPlanDropOffPoint, 0, forwardBaseLoc);
      aiPlanSetVariableBool(attackBaseTrans, cTransportPlanMaximizeXportMovement, 0, true);
      aiPlanSetActive(attackBaseTrans, true);
   }
   else
   {
      OUTPUT("attackBaseGenerator: could not setup transport plan, return!", FAILURE);
      xsDisableSelf();
      return;
   }

   int defendPlan =aiPlanCreate("Defend Island Base", cPlanDefend);
   if (defendPlan >= 0)
   {
      aiPlanAddUnitType(defendPlan, shipUnitTypeID, 2, 2, 5);
      aiPlanSetDesiredPriority(defendPlan, 100);
      aiPlanSetVariableVector(defendPlan, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, newBaseID));
      aiPlanSetVariableFloat(defendPlan, cDefendPlanEngageRange, 0, 60);
      aiPlanSetVariableFloat(defendPlan, cDefendPlanGatherDistance, 0, 5.0);
      aiPlanSetVariableInt(defendPlan, cDefendPlanRefreshFrequency, 0, 5);
      aiPlanSetNumberVariableValues(defendPlan, cDefendPlanAttackTypeID, 2, true);
      aiPlanSetVariableInt(defendPlan, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
      aiPlanSetVariableInt(defendPlan, cDefendPlanAttackTypeID, 1, cUnitTypeBuilding);
      aiPlanSetEscrowID(defendPlan, cMilitaryEscrowID);

      aiPlanSetActive(defendPlan, true); 
   }

   int builderTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0);
   int buildTower=aiPlanCreate("Build Attackbase Tower", cPlanBuild);
   if (buildTower >= 0)
   {
      aiPlanSetVariableInt(buildTower, cBuildPlanBuildingTypeID, 0, cUnitTypeTower);
      aiPlanSetDesiredPriority(buildTower, 90);
      aiPlanSetBaseID(buildTower, newBaseID);
      aiPlanSetVariableInt(buildTower, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(forwardBaseLoc));
      aiPlanSetVariableVector(buildTower, cBuildPlanInfluencePosition, 0, forwardBaseLoc);
      aiPlanSetVariableFloat(buildTower, cBuildPlanInfluencePositionDistance, 0, 10.0);
      aiPlanSetVariableFloat(buildTower, cBuildPlanInfluencePositionValue, 0, 1.0);
      aiPlanAddUnitType(buildTower, builderTypeID, 1, 2, 2);
      aiPlanSetEscrowID(buildTower, cEconomyEscrowID);
      aiPlanSetActive(buildTower);

      // I want a serious tower there!
      // TODO: maybe this is too expensive?
      xsEnableRule("towerUpgrade");
   }
   int buildLonghouse=aiPlanCreate("Build Attackbase Rax", cPlanBuild);
   if (buildLonghouse >= 0)
   {
      aiPlanSetVariableInt(buildLonghouse, cBuildPlanBuildingTypeID, 0, raxUnitTypeID);
      aiPlanSetDesiredPriority(buildLonghouse, 90);
      aiPlanSetBaseID(buildLonghouse, newBaseID);
      aiPlanSetVariableInt(buildLonghouse, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(forwardBaseLoc));
      aiPlanSetVariableVector(buildLonghouse, cBuildPlanInfluencePosition, 0, forwardBaseLoc);
      aiPlanSetVariableFloat(buildLonghouse, cBuildPlanInfluencePositionDistance, 0, 10.0);
      aiPlanSetVariableFloat(buildLonghouse, cBuildPlanInfluencePositionValue, 0, 1.0);

      aiPlanAddUnitType(buildLonghouse, builderTypeID, 1, 2, 2);
      aiPlanSetEscrowID(buildLonghouse, cMilitaryEscrowID);
      aiPlanSetActive(buildLonghouse);
   }
   buildLonghouse=aiPlanCreate("Build Attackbase Rax2", cPlanBuild);
   if (buildLonghouse >= 0)
   {
      aiPlanSetVariableInt(buildLonghouse, cBuildPlanBuildingTypeID, 0, raxUnitTypeID);
      aiPlanSetDesiredPriority(buildLonghouse, 90);
      aiPlanSetBaseID(buildLonghouse, newBaseID);
      aiPlanSetVariableInt(buildLonghouse, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(forwardBaseLoc));
      aiPlanSetVariableVector(buildLonghouse, cBuildPlanInfluencePosition, 0, forwardBaseLoc);
      aiPlanSetVariableFloat(buildLonghouse, cBuildPlanInfluencePositionDistance, 0, 10.0);
      aiPlanSetVariableFloat(buildLonghouse, cBuildPlanInfluencePositionValue, 0, 1.0);
      aiPlanAddUnitType(buildLonghouse, builderTypeID, 1, 2, 2);
      aiPlanSetEscrowID(buildLonghouse, cMilitaryEscrowID);
      aiPlanSetActive(buildLonghouse);
   }

   int AGID=kbAreaGroupGetIDByPosition(forwardBaseLoc);
   int player=getPlayerForIsland(AGID);

   // create attack goal for this island to build military bases.
   int attackGoalID=createSimpleAttackGoal("Island Attack", -1, gLateUPID, -1, kbGetAge(), -1, newBaseID, false);
   aiPlanSetVariableInt(attackGoalID, cGoalPlanAreaGroupID, 0, kbAreaGroupGetIDByPosition(forwardBaseLoc));
   aiPlanSetVariableInt(attackGoalID, cGoalPlanBaseID, 0, newBaseID);
   aiPlanSetBaseID(attackGoalID, newBaseID);
   aiPlanSetVariableBool(attackGoalID, cGoalPlanAutoUpdateBase, 0, false);
//   aiPlanSetVariableBool(attackGoalID, cGoalPlanAutoUpdateAttackPlayerID, 0, true);
   aiPlanSetVariableInt(attackGoalID, cGoalPlanAttackPlayerID, 0, player);
   aiPlanSetVariableBool(attackGoalID, cGoalPlanSetAreaGroups, 0, false);
   aiPlanSetEscrowID(attackGoalID, cMilitaryEscrowID);
   aiPlanSetDesiredPriority(attackGoalID, 99);

   // done.
   xsDisableSelf();
}

/*
//==============================================================================
// RULE dockAttackStarter
// this belongs to heroic, because we have no siege ships before
// TODO: this is inactive at the moment, because it doesn't work as wanted
//==============================================================================
rule dockAttackStarter
   minInterval 65
   group NavalHeroic
   inactive
{
   int dockQuery = kbUnitQueryCreate("Enemy Dock Query");
   configQueryRelation(dockQuery, cUnitTypeDock, -1, cUnitStateAlive, cPlayerRelationEnemy);
   int numResults=kbUnitQueryExecute(dockQuery);
   if ( numResults <= 0 )
      return;

   // found a dock!
   // start our dockattack goal
   //Create the attack goal.
   int upID = initNavalUnitPicker("Naval Dock UP", 4, 4+aiRandInt(4), 3, true);

   // repeat this goal just once, because we create a new goal next time the
   // rule is executed anyway
   int dockAttackID=createSimpleAttackGoal("Naval Dock Attack", -1, upID, 1,
                                             kbGetAge(), -1, -1, false);
   if (dockAttackID < 0)
   {
      OUTPUT("dockAttackStarter: cannot create Attack Goal", FAILURE);
      xsDisableSelf();
      return;
   }

   int dockToAttack=aiRandInt(numResults);
   aiPlanSetVariableInt(dockAttackID, cGoalPlanTargetTypeUnit, 0, kbUnitQueryGetResult(dockQuery, dockToAttack));
//   aiPlanSetVariableInt(dockAttackID, cGoalPlanTargetTypeUnitType, 0, cUnitTypeDock);

//   xsDisableSelf();
}
*/

//==============================================================================
// RULE NavalGoalMonitor
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
         }
         //int tempNumberEnemyDocks=kbUnitCount(i, cUnitTypeDock, cUnitStateAlive);
         if (tempNumberEnemyWarships > numberEnemyWarships)
            numberEnemyWarships=tempNumberEnemyWarships;
      }
   }
   //Figure out the min/max number of warships we want.
   int minShips=0;
   int maxShips=0;
   if (numberEnemyWarships > 0)
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
   OUTPUT("Creating NavalAttackGoal for "+maxShips+" ships since I've seen "+numberEnemyWarships+" for Player "+aiGetMostHatedPlayerID()+".", MILINFO);
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
// isFullyExplored 
// returns true, if more than 80% of the specified areagroup is nonblack.
//==============================================================================
bool isFullyExplored(int areaGroupID=-1)
{
   OUTPUT("isFullyExplored:", TRACE);

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
   if(areaGroupID==AGID)
      epsilon=epsilon+0.05;

   OUTPUT("isFullyExplored: AGID="+areaGroupID+" numTiles="+numTiles+" numBlack="+numTilesBlack+".", TEST);
   float blackPct = numTilesBlack / numTiles;
   OUTPUT("                 blackPct="+blackPct+".", TEST);
   OUTPUT("                 epsilon="+epsilon, TEST);

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
   OUTPUT("setupExploreIsland:", TRACE);

   int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
   if (transportPUID < 0)
   {
      OUTPUT("setupExploreIsland: no water transport unit type", FAILURE);
      return(-1);
   }

   // we don't have a transport yet, return...
   if ( kbUnitCount(cMyID, transportPUID, cUnitStateAlive) <= 0 )
   {
      OUTPUT("setupExploreIsland: no water transport unit yet, return!", MILWARN);
      return(-2);
   }

   // find target area
   int targetAreaID = -1;
   int areaNum = kbAreaGetNumber();
   int j=-1;
   int potentialIsland=-1;
   bool goon=false;

   OUTPUT("    areaNum="+areaNum, TEST);
   // We cannot test all areas since this would take too long and can cause AoM to crash.
   // We therefore make 16 random guesses and hope to find an areagroup we havent been to yet.
   // If we cannot find an appropriate area we hope for better luck next time.
   // We have the risk not to find an area, but we have the upper bound of 16 times this loop compared to
   // some hundred times. This is O(1) compared to O(n)
   // A nice sideeffect is that not all admirals have the same order of exploring islands.
   for ( k = 0; < 16 )
   {
      int i = aiRandInt(areaNum);
      // we need land!
      if (kbAreaGetType(i) == cAreaTypeWater)
         continue;

      potentialIsland = getAreaGroupByArea(i);

      // maybe this is an allys island that we do not need to explore
//      if(isFullyExplored(potentialIsland)==true)
//      {
//         goon=false;
//	 continue;
//      }

      OUTPUT("    potential island="+potentialIsland, TEST);
      // check if this is an area group we been to already
      for(j=0; <aiPlanGetNumberUserVariableValues(gExploreIslandsGoalID, cExploredAreaGroups))
      {
	 int jAGID=aiPlanGetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, j);
         OUTPUT("    jAGID="+jAGID, TEST);

	 if(jAGID < 0)
            break;
         if(potentialIsland == jAGID)
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
      if(targetAreaID >= 0 )
         break;
   }
   
   // we have no target area
   if ( targetAreaID < 0 )
   {
      OUTPUT("setupExploreIsland: no target area found, return!", MILWARN);
      return(-3); // no transport possible, we have no target area
   }

   // remember the area group (island) we explored
   int nextFreeSlot=-1;
   // start at 1, because 0 is always our home.
   for(j=1; <aiPlanGetNumberUserVariableValues(gExploreIslandsGoalID, cExploredAreaGroups))
   {
      if (aiPlanGetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, j) == -1)
      {
         nextFreeSlot=j;
	 break;
      }
   }

   // all slots used.
   if(nextFreeSlot < 0)
      return(-1);

   aiPlanSetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, nextFreeSlot, potentialIsland);

   // TEST
   OUTPUT("Already explored area groups are:", TEST);
   for(j=0; <aiPlanGetNumberUserVariableValues(gExploreIslandsGoalID, cExploredAreaGroups))
   {
      OUTPUT("   AGID="+aiPlanGetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, j), TEST);
   }

   int baseToUse=kbBaseGetMain(cMyID);
   static int scoutQuery=-1;
   if(scoutQuery < 0)
      scoutQuery=kbUnitQueryCreate("Island Scout Query");
   configQuery(scoutQuery, gLandScout, cUnitStateAlive, cActionAny, cMyID);
   kbUnitQuerySetAreaGroupID(scoutQuery, aiPlanGetUserVariableInt(gExploreIslandsGoalID, cExploredAreaGroups, nextFreeSlot-1));
   if(kbUnitQueryExecute(scoutQuery) > 0)
      baseToUse=gCurExploredIslandBase;
   //Get the location of the currently active explore plan
   vector here=kbBaseGetLocation(cMyID, baseToUse);
   //Get our start area ID.
   int startAreaID=kbAreaGetIDByPosition(here);
   
   //Create transport plan to explore the other island.
   OUTPUT("setupExploreIsland: creating transport plan!", MILINFO);
   aiPlanDestroy(gRemoteIslandExploreTrans);
   gRemoteIslandExploreTrans=createTransportPlan("Remote Explore Trans", startAreaID,
                                               targetAreaID,
                                               false, transportPUID, 99, baseToUse);
   if ( gRemoteIslandExploreTrans >= 0 )
   {
      aiPlanAddUnitType( gRemoteIslandExploreTrans, gLandScout, 1, 1, 1 );
      aiPlanSetRequiresAllNeedUnits( gRemoteIslandExploreTrans, true );
      aiPlanSetActive(gRemoteIslandExploreTrans, true);
   }
   else
      OUTPUT("setupExploreIsland: cannot create transport plan! return", FAILURE); 

   OUTPUT("create new base for area group ID="+potentialIsland+".", MILINFO);
   // dunno if this is enough...
   vector center=kbAreaGetCenter(targetAreaID);
   gCurExploredIslandBase = kbBaseCreate(cMyID, "Island Base "+kbBaseGetNextID(), center, 50.0);
   if ( gCurExploredIslandBase >= 0 )
   {
      kbBaseSetActive(cMyID, gCurExploredIslandBase, true);
      kbBaseSetEconomy(cMyID, gCurExploredIslandBase, true);
      kbBaseSetMilitary(cMyID, gCurExploredIslandBase, true);
   }

   OUTPUT("create new explore plan for area group ID="+potentialIsland+".", MILINFO);

   // destroy old explore plan
   aiPlanDestroy(gLandExplorePlanID);
   gLandExplorePlanID=-1;
   gLandExplorePlanID=aiPlanCreate("Explore Island"+potentialIsland, cPlanExplore);
   if (gLandExplorePlanID >= 0)
   {
      aiPlanAddUnitType(gLandExplorePlanID, gLandScout, 1, 1, 1);
      aiPlanSetActive(gLandExplorePlanID);
      aiPlanSetEscrowID(gLandExplorePlanID, cEconomyEscrowID);
      aiPlanSetBaseID(gLandExplorePlanID, gCurExploredIslandBase);
      aiPlanSetDesiredPriority(gLandExplorePlanID, 99); // for norse. don't let build plans steal our scout.
      aiPlanSetInitialPosition(gLandExplorePlanID, center);
      //Don't loop as egyptian.
      if (cMyCulture == cCultureEgyptian)
         aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);
      else if (cMyCulture == cCultureAtlantean )
         aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanOracleExplore, 0, true);
   }

   return(1);
}  

//==============================================================================
// RULE treasureIsland --
// this rule is only for the random map "Treasure Island"
// tries to find the treasure island. If the island is found, a base is created
// on this island.
//==============================================================================
rule treasureIsland
   minInterval 26
   inactive
{
   OUTPUT("treasureIsland:", TRACE);

   int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
   if (transportPUID < 0)
   {
      OUTPUT("treasureIsland: no water transport unit type", FAILURE);
      xsDisableSelf();
      return;
   }

   // we don't have a transport yet, return...
   if ( kbUnitCount(cMyID, transportPUID, cUnitStateAlive) <= 0 )
   {
      OUTPUT("treasureIsland: no water transport unit yet, return!", MILWARN);
      return;
   }

   // if we have a transport...
   int treasureIslandAGID=kbAreaGroupGetIDByPosition(kbGetMapCenter());
   if (treasureIslandAGID < 0 )
   {
      OUTPUT("treasureIsland: Island not found, return!", FAILURE);
      xsDisableSelf();
      return;
   }
   
   //Create the treasure island base.
   int treasureBaseGID=createBaseGoal("Treasure Base", cGoalPlanGoalTypeMainBase,
      -1, 1, 0, -1, kbBaseGetMainID(cMyID));
   if (treasureBaseGID >= 0)
   {
      //Set the area ID.
      aiPlanSetVariableInt(treasureBaseGID, cGoalPlanAreaGroupID, 0, treasureIslandAGID);
      //Create the callback goal.
      int callbackGID=createCallbackGoal("Treasure Base Callback", "treasureBaseCallback",
         1, 0, -1, false);
      if (callbackGID >= 0)
         aiPlanSetVariableInt(treasureBaseGID, cGoalPlanDoneGoal, 0, callbackGID);
   }

   xsDisableSelf();
}

//==============================================================================
// treasureBaseCallback ---
// callback for the treasure island base.
// creates a transport plan from the main base to the treasure base. Afterwards
// a build plan for a temple on the treasure island is created.
// @seealso treasureIsland
//==============================================================================
void treasureBaseCallback(int parm=-1)
{
   int numBases=kbBaseGetNumber(cMyID);
   int treasureBase=-1;
   int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
   for(i=0; < numBases)
   {
      vector basePos=kbBaseGetLocation(cMyID, i);
      if(isOnMyIsland(basePos) == false)
      {
	 treasureBase=i;
         break;
      }
   }

   if (treasureBase == -1)
   {
      OUTPUT("treasureBaseCallback: could not find Treasure Island Base!", FAILURE);
      return;
   }

   int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMain(cMyID)));
   int targetAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, treasureBase));
   int treasureIslandTrans = createTransportPlan("TreasureIslandTrans", startAreaID,
                              targetAreaID, false, transportPUID, 90, kbBaseGetMainID(cMyID));
   if ( treasureIslandTrans >= 0 )
   {
      aiPlanAddUnitType( treasureIslandTrans, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 3, 3, 3 );
      aiPlanSetRequiresAllNeedUnits( treasureIslandTrans, true );
      aiPlanSetActive(treasureIslandTrans, true);
   }
   else
   {
      OUTPUT("treasureBaseCallback: could not setup transport plan, return!", FAILURE);
      xsDisableSelf();
      return;
   }

   int buildTemple=aiPlanCreate("BuildTreasuryTemple", cPlanBuild);
   if (buildTemple >= 0)
   {
      aiPlanSetVariableInt(buildTemple, cBuildPlanBuildingTypeID, 0, cUnitTypeTemple);
      aiPlanSetDesiredPriority(buildTemple, 30);
      aiPlanAddUnitType(buildTemple, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 3, 3, 3);
      aiPlanSetVariableInt(buildTemple, cBuildPlanAreaID, 0, targetAreaID);
      aiPlanSetBaseID(buildTemple, treasureBase);
      aiPlanSetEscrowID(buildTemple, cEconomyEscrowID);
      aiPlanSetActive(buildTemple);
   }

   // collect the relics from the island
   aiPlanSetBaseID(gRelicGatherPlanID, treasureBase);
}

//==============================================================================
// RULE exploreIslands
// periodically check, if we have fully explored the current island.
// as soon as 80% of the island is visible, setup an explore plan for another
// island
//==============================================================================
rule exploreIslands
   minInterval 26
   group NavalClassical
   inactive
{
   OUTPUT("exploreIslands:", TRACE);
   static int numTries=0;

   // only the captain does this, everyting else costs too much
   // computation power and causes aom to crash
   if( (aiGetCaptainPlayerID(cMyID) != cMyID) || (cvDoExploreOtherIslands == false) )
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
      OUTPUT("exploreIslands: island is fully explored, setup new explore plan!", MILINFO);
      // setup new plan for another island
      int result=setupExploreIsland();
      if ( result == 1 )
      {
         // we have just setup a new plan, let the scout go for a while...
         xsSetRuleMinIntervalSelf(120);
	 numTries=0;
         return;
      }
      else if(result == -1) // total failure or all explored
      {
         xsDisableSelf();
         return;
      }
      else if(result == -2) // no transport yet. Just wait
      {
         return;
      }
      else // no target area found.
      {
	 // disable rule if failed three times in a row.
	 // we assume that we have all area groups explored.
         numTries=numTries+1;
	 if(numTries >= 3)
	 {
	    OUTPUT("exploreIslands: disabling rule because we have all area groups explored!", TEST);
            xsDisableSelf();
	    return;
	 }
      }
   }
   else
      xsSetRuleMinIntervalSelf(26);
}

