//==============================================================================
// ADMIRAL X
// admiralmilitary.xs
// This is an extension of the default ai file: aomdefaultaimilitary.xs
// by Georg Kalus   MWD_kalus@web.de
// created with VIM
//
// military stuff
//==============================================================================

//==============================================================================
//getPlanPopSlots()     Returns the total pop slots taken by units in this plan
//==============================================================================
int getPlanPopSlots(int planID=-1)
{
   int unitCount = aiPlanGetNumberUnits( planID, cUnitTypeUnit );

   int popSlots = 0;
   int index = 0;
   int unitID = 0;
/*  ARGH!  No way to walk through unit list.  For now, just return 3*unitCount.
   for (index = 0; < unitCount)
   {
      unitID = 
   }
*/
   return(3*unitCount);
}  

//==============================================================================
// createSimpleAttackGoal
//==============================================================================
int createSimpleAttackGoal(string name="BUG", int attackPlayerID=-1,
   int unitPickerID=-1, int repeat=-1, int minAge=-1, int maxAge=-1,
   int baseID=-1, bool allowRetreat=false)
{
   OUTPUT("CreateSimpleAttackGoal:  Name="+name+", AttackPlayerID="+attackPlayerID+".", MILINFO);
   OUTPUT("  UnitPickerID="+unitPickerID+", Repeat="+repeat+", baseID="+baseID+".", MILINFO);
   OUTPUT("  MinAge="+minAge+", maxAge="+maxAge+", allowRetreat="+allowRetreat+".", MILINFO);

   //Create the goal.
   int goalID=aiPlanCreate(name, cPlanGoal);
   if (goalID < 0)
      return(-1);

   //Priority.
   aiPlanSetDesiredPriority(goalID, 90);
   //Attack player ID.
   if (attackPlayerID >= 0)
      aiPlanSetVariableInt(goalID, cGoalPlanAttackPlayerID, 0, attackPlayerID);
   else
      aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateAttackPlayerID, 0, true);
   //Base.
   if (baseID >= 0)
      aiPlanSetBaseID(goalID, baseID);
   else
      aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateBase, 0, true);
   //Attack.
   aiPlanSetAttack(goalID, true);
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeAttack);
   //Military.
   aiPlanSetMilitary(goalID, true);
   aiPlanSetEscrowID(goalID, cMilitaryEscrowID);
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);
   //Unit Picker.
   aiPlanSetVariableInt(goalID, cGoalPlanUnitPickerID, 0, unitPickerID);
   //Retreat.
   aiPlanSetVariableBool(goalID, cGoalPlanAllowRetreat, 0, allowRetreat);
   // Upgrade Building prefs.
   aiPlanSetNumberVariableValues(goalID, cGoalPlanUpgradeBuilding, 3, true);
   aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeTemple);
   aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 1, cUnitTypeSettlementLevel1);
   if(cMyCiv == cCivThor)
      aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeDwarfFoundry);
   else
      aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeArmory);
   //Handle maps where the enemy player is usually on a diff island.
   if (gTransportMap == true)
   {
      aiPlanSetVariableBool(goalID, cGoalPlanSetAreaGroups, 0, true);
      aiPlanSetVariableInt(goalID, cGoalPlanAttackRoutePatternType, 0, cAttackPlanAttackRoutePatternBest);
   }
   // Handle OkToAttack control variable
   if (cvOkToAttack == false)     
   {
      OUTPUT("CreateSimpleAttackPlan:  Setting attack "+goalID+" to idle.", MILINFO);
      aiPlanSetVariableBool(goalID, cGoalPlanIdleAttack, 0, true);       // Prevent attacks
   }

   //Done.
   return(goalID);
}

//==============================================================================
// createBaseGoal
//==============================================================================
int createBaseGoal(string name="BUG", int goalType=-1, int attackPlayerID=-1,
   int repeat=-1, int minAge=-1, int maxAge=-1, int parentBaseID=-1)
{
   OUTPUT("CreateBaseGoal:  Name="+name+", AttackPlayerID="+attackPlayerID+".", MILINFO);
   OUTPUT("  GoalType="+goalType+", Repeat="+repeat+", parentBaseID="+parentBaseID+".", MILINFO);
   OUTPUT("  MinAge="+minAge+", maxAge="+maxAge+".", MILINFO);

   //Create the goal.
   int goalID=aiPlanCreate(name, cPlanGoal);
   if (goalID < 0)
      return(-1);

   //Priority.
   aiPlanSetDesiredPriority(goalID, 90);
   //"Parent" Base.
   aiPlanSetBaseID(goalID, parentBaseID);
   //Base Type.
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, goalType);
   if (goalType == cGoalPlanGoalTypeForwardBase)
   {
      //Attack player ID.
      if (attackPlayerID >= 0)
         aiPlanSetVariableInt(goalID, cGoalPlanAttackPlayerID, 0, attackPlayerID);
      else
         aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateAttackPlayerID, 0, true);
      //Military.
      aiPlanSetMilitary(goalID, true);
      aiPlanSetEscrowID(goalID, cMilitaryEscrowID);
      //Active health.
      aiPlanSetVariableInt(goalID, cGoalPlanActiveHealthTypeID, 0, cUnitTypeBuilding);
      aiPlanSetVariableFloat(goalID, cGoalPlanActiveHealth, 0, 0.25);
   }
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

   //Done.
   return(goalID);
}

//==============================================================================
// createCallbackGoal
//==============================================================================
int createCallbackGoal(string name="BUG", string callbackName="BUG", int repeat=-1,
   int minAge=-1, int maxAge=-1, bool autoUpdate=false)
{
   OUTPUT("CreateCallbackGoal:  Name="+name+", CallbackName="+callbackName+".", MILINFO);
   OUTPUT("  Repeat="+repeat+", MinAge="+minAge+", maxAge="+maxAge+".", MILINFO);

   //Get the callbackFID.
   int callbackFID=xsGetFunctionID(callbackName);
   if (callbackFID < 0)
      return(-1);

   //Create the goal.
   int goalID=aiPlanCreate(name, cPlanGoal);
   if (goalID < 0)
      return(-1);

   //Goal Type.
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeCallback);
   //Auto update.
   aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
   //Callback FID.
   aiPlanSetVariableInt(goalID, cGoalPlanFunctionID, 0, callbackFID);
   //Priority.
   aiPlanSetDesiredPriority(goalID, 90);
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

   //Done.
   return(goalID);
}

//==============================================================================
// createBuildBuildingGoal
//==============================================================================
int createBuildBuildingGoal(string name="BUG", int buildingTypeID=-1, int repeat=-1,
   int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, int builderUnitTypeID=-1,
   bool autoUpdate=true, int pri=90, int buildingPlacementID = -1)
{
   OUTPUT("CreateBuildBuildingGoal:  Name="+name+", BuildingType="+kbGetUnitTypeName(buildingTypeID)+".", MILINFO);
   OUTPUT("  Repeat="+repeat+", MinAge="+minAge+", maxAge="+maxAge+".", MILINFO);

   //Create the goal.
   int goalID=aiPlanCreate(name, cPlanGoal);
   if (goalID < 0)
      return(-1);

   //Goal Type.
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeBuilding);
   //Base ID.
   aiPlanSetBaseID(goalID, baseID);
   //Auto update.
   aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
   //Building Type ID.
   aiPlanSetVariableInt(goalID, cGoalPlanBuildingTypeID, 0, buildingTypeID);
   //Building Placement ID.
   aiPlanSetVariableInt(goalID, cGoalPlanBuildingPlacementID, 0, buildingPlacementID);
   //Set the builder parms.
   aiPlanSetVariableInt(goalID, cGoalPlanMinUnitNumber, 0, 1);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxUnitNumber, 0, numberUnits);
   aiPlanSetVariableInt(goalID, cGoalPlanUnitTypeID, 0, builderUnitTypeID);
   
   //Priority.
   aiPlanSetDesiredPriority(goalID, pri);
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

   //Done.
   return(goalID);
}

//==============================================================================
// createBuildSettlementGoal
//==============================================================================
int createBuildSettlementGoal(string name="BUG", int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, int builderUnitTypeID=-1,
   bool autoUpdate=true, int pri=90)
{
   int buildingTypeID = cUnitTypeSettlementLevel1;

   OUTPUT("CreateBuildSettlementGoal:  Name="+name+", BuildingType="+kbGetUnitTypeName(buildingTypeID)+".", MILINFO);
   OUTPUT("  MinAge="+minAge+", maxAge="+maxAge+".", MILINFO);

   //Create the goal.
   int goalID=aiPlanCreate(name, cPlanGoal);
   if (goalID < 0)
      return(-1);

   //Goal Type.
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeBuildSettlement);
   //Base ID.
   aiPlanSetBaseID(goalID, baseID);
   //Auto update.
   aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
   //Building Type ID.
   aiPlanSetVariableInt(goalID, cGoalPlanBuildingTypeID, 0, buildingTypeID);
   //Building Search ID.
   aiPlanSetVariableInt(goalID, cGoalPlanBuildingSearchID, 0, cUnitTypeSettlement);
   //Set the builder parms.
   aiPlanSetVariableInt(goalID, cGoalPlanMinUnitNumber, 0, 1);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxUnitNumber, 0, numberUnits);
   aiPlanSetVariableInt(goalID, cGoalPlanUnitTypeID, 0, builderUnitTypeID);
   
   //Priority.
   aiPlanSetDesiredPriority(goalID, pri);
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, 1);

   //Done.
   return(goalID);
}

//==============================================================================
// createTransportPlan
//==============================================================================
int createTransportPlan(string name="BUG", int startAreaID=-1, int goalAreaID=-1,
   bool persistent=false, int transportPUID=-1, int pri=-1, int baseID=-1)
{
   OUTPUT("CreateTransportPlan:  Name="+name+", Priority="+pri+".", MILINFO);
   OUTPUT("  StartAreaID="+startAreaID+", GoalAreaID="+goalAreaID+", Persistent="+persistent+".", MILINFO);
   OUTPUT("  TransportType="+kbGetUnitTypeName(transportPUID)+", BaseID="+baseID+".", MILINFO);

   //Create the plan.
   int planID=aiPlanCreate(name, cPlanTransport);
   if (planID < 0)
      return(-1);

   //Priority.
   aiPlanSetDesiredPriority(planID, pri);
   //Base.
   aiPlanSetBaseID(planID, baseID);
   //Set the areas.
   aiPlanSetVariableInt(planID, cTransportPlanPathType, 0, 1);
   aiPlanSetVariableInt(planID, cTransportPlanGatherArea, 0, startAreaID);
   aiPlanSetVariableInt(planID, cTransportPlanTargetArea, 0, goalAreaID);
   //Default the initial position to the start area's location.
   aiPlanSetInitialPosition(planID, kbAreaGetCenter(startAreaID));
   //Transport type.
   aiPlanSetVariableInt(planID, cTransportPlanTransportTypeID, 0, transportPUID);
   //Persistent.
   aiPlanSetVariableBool(planID, cTransportPlanPersistent, 0, persistent);
   //Always add the transport unit type.
   aiPlanAddUnitType(planID, transportPUID, 1, 1, 1);
   //Activate.
   aiPlanSetActive(planID);

   //Done.
   return(planID);
}

//==============================================================================
// Make a defend plan, protect the main base, destroy plan when army size
// is nearly enough for an attack
//==============================================================================
rule defendPlanRule
minInterval 14
inactive
{
   static int defendCount = 0;      // For plan numbering
   int upID = -1;                   // Active unit picker, for getting target military size
   int targetPop = -1;              // Size needed to launch an attack, in pop slots
   int mainBaseID = kbBaseGetMainID(cMyID);

   if (kbGetAge() < cAge3)
      upID = gRushUPID;
   else
      upID = gLateUPID;

   targetPop = kbUnitPickGetMinimumPop(upID);

   if (gDefendPlanID < 0)
   {
      gDefendPlanID = aiPlanCreate("Defend plan #"+defendCount, cPlanDefend);
      defendCount = defendCount + 1;

      if (gDefendPlanID < 0)
         return;
   
      //aiPlanSetVariableInt(gDefendPlanID, cDefendPlanDefendBaseID, 0, mainBaseID);
      aiPlanSetVariableInt(gDefendPlanID, cDefendPlanRefreshFrequency, 0, 30);
      if(gForwardBaseID >= 0)
      {
         aiPlanSetVariableVector(gDefendPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, gForwardBaseID));
         aiPlanSetVariableFloat(gDefendPlanID, cDefendPlanEngageRange, 0, 30.0);
         aiPlanSetVariableFloat(gDefendPlanID, cDefendPlanGatherDistance, 0, 20.0);
      }
      else
      {
         aiPlanSetVariableVector(gDefendPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
         aiPlanSetVariableFloat(gDefendPlanID, cDefendPlanEngageRange, 0, 50.0);
         aiPlanSetVariableFloat(gDefendPlanID, cDefendPlanGatherDistance, 0, 50.0);
      }
      aiPlanSetUnitStance(gDefendPlanID, cUnitStanceDefensive);

      
      aiPlanSetNumberVariableValues(gDefendPlanID, cDefendPlanAttackTypeID, 2, true);
      aiPlanSetVariableInt(gDefendPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
      aiPlanSetVariableInt(gDefendPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeBuilding);

      aiPlanAddUnitType(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 200, 200);
      aiPlanSetDesiredPriority(gDefendPlanID, 20);    // Way below others
      aiPlanSetActive(gDefendPlanID);
      return;
   }

   if ( (getPlanPopSlots(gDefendPlanID) > targetPop) || (kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive)>0) )   // Make room for attack plan
   {
      aiPlanDestroy(gDefendPlanID);
      gDefendPlanID = -1;
      xsDisableSelf();
      xsEnableRule("reactivateDefendPlan");  // Start again in a minute
   }

   // Check if it's on the wrong continent
   int myAreaGroup = kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, mainBaseID));
   if ( myAreaGroup != kbAreaGroupGetIDByPosition(aiPlanGetLocation(gDefendPlanID)) )
   {  
      int targetAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, gForwardBaseID));
      int transportPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0);
      if(gForwardBaseID >= 0 && gTransportMap && aiPlanGetIDByTypeAndVariableType(cPlanTransport, cTransportPlanTargetArea, targetAreaID) < 0)
      {
         OUTPUT("transporting forward base defenders!", TEST);
         // transport builders there
         int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMain(cMyID)));
         int attackBaseTrans = createTransportPlan("Attack Base Transport", startAreaID,
                              targetAreaID, false, transportPUID, 100, kbBaseGetMainID(cMyID));
         if (attackBaseTrans >= 0)
         {
            aiPlanAddUnitType(attackBaseTrans, cUnitTypeLogicalTypeLandMilitary, 5, 100, 100);
            aiPlanSetRequiresAllNeedUnits( attackBaseTrans, false );
//            aiPlanSetVariableVector(attackBaseTrans, cTransportPlanDropOffPoint, 0, forwardBaseLoc);
            aiPlanSetVariableBool(attackBaseTrans, cTransportPlanMaximizeXportMovement, 0, true);
            aiPlanSetActive(attackBaseTrans, true);
         }
      }
      else
      {
         // Defend plan is on a different continent, scratch it.
         if (kbAreaGroupGetIDByPosition(aiPlanGetLocation(gDefendPlanID)) != -1)
         {
            OUTPUT("***** Defend plan is in wrong areaGroup:"+myAreaGroup+", "+kbAreaGroupGetIDByPosition(aiPlanGetLocation(gDefendPlanID)), MILINFO);
            aiPlanDestroy(gDefendPlanID);
            gDefendPlanID = -1;
            xsDisableSelf();
            xsEnableRule("reactivateDefendPlan");  // Start again in a minute
         }
      }
   }
}


//==============================================================================
// RULE reactivateDefendPlan
//==============================================================================
rule reactivateDefendPlan
active
minInterval 60
{
   xsEnableRule("defendPlanRule");
   xsDisableSelf();
}

//==============================================================================
// RULE activateObeliskClearingPlan
// Create a simple plan to destroy enemy obelisks, remove plan if none exist
// MK: Need to create a rule chain (loop) to create this plan, then set it to not take more units after 
// it's first filled, then check every 90 seconds to see if it's empty and recreate or refill it.
// This will get over the "stream infantry into the enemy town" problem.
// Ideally, another rule could be used to explicitly set the target IDs (rather than Target Type)
// to make sure it doesn't focus over and over on the same obelisk.
//==============================================================================
rule activateObeliskClearingPlan
active
minInterval 33
{
   if (kbGetAge() < cAge2)
      return;
   int mainBaseID = kbBaseGetMainID(cMyID);
   static int obeliskPlanCount = 0;

   static int obeliskQueryID=-1;
   //If we don't have a query ID, create it.
   if (obeliskQueryID < 0)
   {
      obeliskQueryID=kbUnitQueryCreate("Obelisk Query");
      //If we still don't have one, bail.
      if (obeliskQueryID < 0)
         return;
      //Else, setup the query data.
      kbUnitQuerySetPlayerRelation( obeliskQueryID, cPlayerRelationEnemy );
      //kbUnitQuerySetPlayerID(obeliskQueryID, 2);
      kbUnitQuerySetUnitType(obeliskQueryID, cUnitTypeOutpost);      // NOT cUnitTypeObelisk!!!
      kbUnitQuerySetState(obeliskQueryID, cUnitStateAliveOrBuilding);
   }

   // Check for obelisks
   kbUnitQueryResetResults(obeliskQueryID);
   int obeliskCount = kbUnitQueryExecute(obeliskQueryID);

   if (obeliskCount < 1)
   {
      if (gObeliskClearingPlanID >= 0)
      {
         aiPlanDestroy(gObeliskClearingPlanID);
         gObeliskClearingPlanID = -1;
      }
      return;     // No targets, take it easy
   }

   // We found targets, make a plan if we don't have one.
   
   if ( (gObeliskClearingPlanID < 0) )
   {
      gObeliskClearingPlanID = aiPlanCreate("Obelisk plan #"+obeliskPlanCount, cPlanDefend);
      obeliskPlanCount = obeliskPlanCount + 1;

      if (gObeliskClearingPlanID < 0)
         return;
   
      aiPlanSetVariableVector(gObeliskClearingPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
      aiPlanSetVariableFloat(gObeliskClearingPlanID, cDefendPlanEngageRange, 0, 1000.0);   // Anywhere!
      aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanRefreshFrequency, 0, 30);
      aiPlanSetVariableFloat(gObeliskClearingPlanID, cDefendPlanGatherDistance, 0, 50.0);
      aiPlanSetUnitStance(gObeliskClearingPlanID, cUnitStanceDefensive);

      aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeOutpost);

      aiPlanAddUnitType(gObeliskClearingPlanID, cUnitTypeAbstractInfantry, 1, 1, 1);
      aiPlanSetDesiredPriority(gObeliskClearingPlanID, 58);    // Above normal attack
      aiPlanSetActive(gObeliskClearingPlanID);
   }
}

//==================================================================================
// RULE: Egyptian decrease rax units preference if has at least two Migdols
//==================================================================================
rule decreaseRaxPref
   minInterval 11
   inactive
{  
   int numberOfFortresses=kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAlive);

   if (cMyCulture != cCultureEgyptian)
      xsDisableSelf();

   if (numberOfFortresses < 2)
      return;

   if (aiRandInt(3) == 0)	// 33% chance of A.I going rax
   {
      xsDisableSelf();
      return;
   }

   kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeAxeman, 0.4);
   kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeSpearman, 0.4);
   kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeSlinger, 0.4);
   kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeCamelry, 0.6);
   kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeChariotArcher, 0.6);
   kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeWarElephant, 0.3);

   if (gAge3MinorGod == cTechAge3Sekhmet)
      kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeChariotArcher, 0.7);

   xsDisableSelf(); 
}

//==============================================================================
// tacticalSiegeAttackBuildings
//==============================================================================
rule tacticalSiegeAttackBuildings
   minInterval 5
   active
{
   static int unitQueryID=-1;
   static int enemyQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
		// Don't want Norse Ballista to attack buildings.
		if (cMyCulture != cCultureNorse)
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeAbstractSiegeWeapon);
		else
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypePortableRam);			

      kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int siegeFound=kbUnitQueryExecute(unitQueryID);

   if (siegeFound < 1)
      return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
      enemyQueryID=kbUnitQueryCreate("Target Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeBuilding);
      kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyQueryID, true);
		kbUnitQuerySetAscendingSort(enemyQueryID, true);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 30);
   }

   int numberFoundTemp = 0;
   int enemyUnitIDTemp = 0;

   for (i=0; < siegeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   if (numberFoundTemp > 0 && kbUnitIsType(kbUnitQueryGetResult(enemyQueryID, 0), cUnitTypeAbstractSettlement) == false )
	   {
         enemyUnitIDTemp = kbUnitQueryGetResult(enemyQueryID, 0);
         aiTaskUnitWork(kbUnitQueryGetResult(unitQueryID, i), enemyUnitIDTemp);
	   }
   }
}

//==============================================================================
// RULE trainMercs
//==============================================================================
rule trainMercs
   minInterval 21
   active
{
   if(cMyCulture != cCultureEgyptian)
   {
      xsDisableSelf();
      return;
   }

   int settleQuery=kbUnitQueryCreate("SettleQuery");
   configQuery(settleQuery, cUnitTypeAbstractSettlement, -1, cUnitStateAlive, cMyID);
   kbUnitQueryResetResults(settleQuery);
   int numSettles=kbUnitQueryExecute(settleQuery);
   int settleID=-1;
   for(j=0; < numSettles)
   {
      settleID=kbUnitQueryGetResult(settleQuery, j);
      int itsBase=kbUnitGetBaseID(settleID);
      // TODO: maybe attack enemy vills and caravans as well...
      int numberEnemyUnits=kbBaseGetNumberUnits(cMyID, itsBase, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
      int numberAlliedUnits=kbBaseGetNumberUnits(cMyID, itsBase, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);
      int numberMyUnits=kbBaseGetNumberUnits(cMyID, itsBase, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
//      OUTPUT("trainMercs: numberBadUnits="+numberEnemyUnits, TEST);
//      OUTPUT("trainMercs: numberGoodUnits="+(numberAlliedUnits+numberMyUnits), TEST);
      if(kbBaseGetUnderAttack(cMyID, itsBase) == true && numberEnemyUnits > (numberAlliedUnits+numberMyUnits))
      {
	 int numMercs=numberEnemyUnits;
	 if(numMercs > 3)
            numMercs=3;
         OUTPUT("trainMercs: training="+numMercs+" Mercenaries.", MILINFO);
         for(i=0; < numMercs)
            aiTaskUnitTrain(settleID, cUnitTypeMercenary);
      }
   }
}
