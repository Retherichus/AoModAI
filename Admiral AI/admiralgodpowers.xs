//==============================================================================
// ADMIRAL X
// admiralgodpowers.xs
// This is an extension of the default ai file: aomdefaultaigodpowers.xs
// by Georg Kalus   MWD_kalus@web.de
// created with VIM
//
// This is the basic logic behind the casting of the various god powers
//==============================================================================

// *****************************************************************************
//
// An explanation of some of the plan types, etc. in this file:
//
// aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModel...
//   CombatDistance - This is the standard one.  The plan will get attached to an 
//   attack plan, and the attack plan performs a query, and when the number and 
//   type of enemy units you specify are within the specified distance of the 
//   attack plan's location, the god power will go off. 
//
//   CombatDistancePosition - *doesn't* get attached to an attack plan.  
//   You specify a position, and when the number and type of enemy units are within 
//   distance of that position, the power goes off.  This, for instance, could see 
//   if there are many enemy units around your town center. 
//
//   CombatDistanceSelf - this one's kind of particular.  It gets attached to an 
//   attack plan.  The query you specify in the setup determines the number and 
//   type of *friendly* units neccessary to satisfy the evaluation.  Addtionally, 
//   there must be at least 5 (currently hardcoded) enemy units within the distance 
//   value of the attack plan for it to be successful.  Then the power will go off.  
//   This is typicaly used for powers than improve friendly units, like bronze, 
//   flaming weapons, and eclipse.  
//
// 
//
// *****************************************************************************
//==============================================================================
//Globals.
extern int gCeaseFirePlanID=-1;
extern int gSentinelPlanID=-1;
extern int gForestFirePlanID=-1;
extern int gHeavyGPTech=-1;
extern int gHeavyGPPlan=-1;
extern int gSpidersPlan=-1;
extern int gCarnivoraPlan=-1;

//==============================================================================
// findHuntableInfluence
//==============================================================================
vector findHuntableInfluence()
{
   vector townLocation=kbGetTownLocation();
   vector best=townLocation;
   float bestDistSqr=0.0;

   //Run a query.
   int queryID=kbUnitQueryCreate("Huntable Units");
   if (queryID < 0)
      return(best);

   kbUnitQueryResetData(queryID);
   kbUnitQueryResetResults(queryID);
   kbUnitQuerySetPlayerID(queryID, 0);
   kbUnitQuerySetUnitType(queryID, cUnitTypeHuntable);
   kbUnitQuerySetState(cUnitStateAlive);
   int numberFound=kbUnitQueryExecute(queryID);

   for (i=0; < numberFound)
   {
      vector position=kbUnitGetPosition(kbUnitQueryGetResult(queryID, i));
      float dx=xsVectorGetX(townLocation)-xsVectorGetX(position);
      float dz=xsVectorGetZ(townLocation)-xsVectorGetZ(position);

      float curDistSqr=((dx*dx) + (dz*dz));
      if (curDistSqr > bestDistSqr)
      {
         best=position;
         bestDistSqr=curDistSqr;
      }
   }

   return(best);
}

//==============================================================================
// setupGodPowerPlan
//==============================================================================
bool setupGodPowerPlan(int planID = -1, int powerProtoID = -1)
{
   if (planID == -1)
      return (false);
   if (powerProtoID == -1)
      return (false);

   aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));

   //-- setup prosperity
   //-- This sets up the plan to cast itself when there are 8 people working on gold
   if (powerProtoID == cPowerProsperity)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
      aiPlanSetVariableInt(planID, cGodPowerPlanResourceType, 0, cResourceGold);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
      return (true);
   }

   //-- setup plenty
   //-- we want this to cast in our town when we have 20 or more workers in the world
   if (powerProtoID == cPowerPlenty)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 20);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
      //-- override the default building placement distance so that plenty has some room to cast
      //-- it is pretty big..
      aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 100.0);
      return (true);
   }

   //-- setup the serpents power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerPlagueofSerpents)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
      return (true);  
   }

   //-- setup the lure power
   //-- cast this in your town as soon as we have more than 3 huntable resources found, and towards that huntable stuff if we know about it
   if (powerProtoID == cPowerLure)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 

      //-- create the query used for evaluation
      int queryID=kbUnitQueryCreate("Huntable Evaluation");
      if (queryID < 0)
         return (false);

      kbUnitQueryResetData(queryID);
      kbUnitQuerySetPlayerID(queryID, 0);
      kbUnitQuerySetUnitType(queryID, cUnitTypeHuntable);
      kbUnitQuerySetState(cUnitStateAlive);

      aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, 0);

      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, 0);
      
      
      //-- now set up the targeting and the influences for targeting
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);

      //-- this one gets special influences (maybe)
      //-- set up from a simple query
      //-- we also prevent the default "back of town" placement
      aiPlanSetVariableInt(planID, cGodPowerPlanBPLocationPreference, 0, cBuildingPlacementPreferenceNone);
            
      vector v = findHuntableInfluence();
      aiPlanSetVariableVector(planID, cGodPowerPlanBPInfluence, 0, v);
      aiPlanSetVariableFloat(planID, cGodPowerPlanBPInfluenceValue, 0, 10.0);
      aiPlanSetVariableFloat(planID, cGodPowerPlanBPInfluenceDistance, 0, 100.0);
      return (true);  
   }

   //-- setup the pestilence power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 50 meters, and at least 3 buildings must be found
   //-- this works on buildings
   if (powerProtoID == cPowerPestilence)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 3);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitaryBuilding);
      return (true);  
   }

   //-- setup the bronze power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 10 meters
   if (powerProtoID == cPowerBronze) 
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      return (true);  
   }

   //-- setup the earthquake power
   if (powerProtoID == cPowerEarthquake)
   {
		gHeavyGPPlan=planID;
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		gHeavyGPTech=cTechEarthquake;
      xsEnableRule("rCastHeavyGP");
      return (true);
/*
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,cGodPowerPlanDistance, 0, 40.0);
      aiPlanSetVariableInt(planID,  cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractSettlement);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
      return (true);  
*/
   }

   //-- setup Citadel
   //-- This sets up the plan to cast itself immediately
   if (powerProtoID == cPowerCitadel)
   {
     
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
      return (true);
   }

   //-- setup the dwarven mine
   //-- use this when we are going to gather (so we don't allow it to cast right now)
   if (powerProtoID == cPowerDwarvenMine)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
      //-- set up the global
      gDwarvenMinePlanID = planID;
      //-- enable the monitoring rule
      xsEnableRule("rDwarvenMinePower");
      return (true);  
   }

    //-- setup the curse power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerCurse)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
      return (true);  
   }

   //-- setup the Eclipse power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 50 meters, and at least 6 myth units must be found
   //-- this works on buildings
   if (powerProtoID == cPowerEclipse)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 6);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMythUnit);
      return (true);  
   }

   //-- setup the flaming weapons
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 10 meters
   if (powerProtoID == cPowerFlamingWeapons) 
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeValidFlamingWeaponsTarget);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
      return (true);  
   }

   //-- setup the Forest Fire power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 40 meters
   if (powerProtoID == cPowerForestFire)
   {
      gForestFirePlanID = planID;
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
      xsEnableRule("rForestFire");
      return (true);
   }

   //-- setup the frost power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerFrost)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
      aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
      return (true);  
   }

   //-- setup the healing spring power
   //-- cast this within 50 meters of the military gather 
   if (powerProtoID == cPowerHealingSpring)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelMilitaryGatherPoint);
      aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 75.0);
      return (true);  
   }

   //-- setup the lightening storm power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerLightningStorm)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
      aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
      return (true);  
   }

    //-- setup the locust swarm power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 50 meters, and at least 3 farms must be found
   //-- this works on buildings
   if (powerProtoID == cPowerLocustSwarm)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractFarm);
      return (true);  
   }

    //-- setup the Meteor power
   if (powerProtoID == cPowerMeteor)
   {
		gHeavyGPPlan=planID;
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		gHeavyGPTech=cTechMeteor;
      xsEnableRule("rCastHeavyGP");
      return (true);
	  /*
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
      return (true);  
		*/
   }

   //-- setup the Nidhogg power
   //-- cast this in your town immediately
   if (powerProtoID == cPowerNidhogg)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
      return (true);  
   }

    //-- setup the Restoration power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerRestoration && aiIsMultiplayer() == false)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
      return (true);  
   }

   //-- setup the Sentinel power
   //-- disable auto casting, cast when under attack
   if (powerProtoID == cPowerSentinel)
   {
      gSentinelPlanID = planID;
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
      xsEnableRule("rSentinel");
      return (true);  
   }

    //-- setup the Ancestors power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerAncestors)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
      return (true);  
   }

    //-- setup the Fimbulwinter power
   //-- cast this in your town immediately
   if (powerProtoID == cPowerFimbulwinter)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
      return (true);  
   }

   //-- setup the Tornado power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 100 meters
   if (powerProtoID == cPowerTornado && aiIsMultiplayer() == false)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      return (true);  
   }

   //-- setup Undermine
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 50 meters, and at least 3 wall segments must be found
   //-- this works on buildings
   if (powerProtoID == cPowerUndermine)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 3);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractWall);
      return (true);  
   }

   //-- setup the great hunt
   //-- this power makes use of the KBResource evaluation condition
   //-- to find the best huntable kb resource with more than 200 total food.
   if (powerProtoID == cPowerGreatHunt)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelKBResource);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);

      aiPlanSetVariableInt(planID,  cGodPowerPlanResourceType, 0, cResourceFood);
      aiPlanSetVariableInt(planID,  cGodPowerPlanResourceSubType, 0, cAIResourceSubTypeEasy);
      aiPlanSetVariableBool(planID,  cGodPowerPlanResourceFilterHuntable, 0, true);
      aiPlanSetVariableFloat(planID, cGodPowerPlanResourceFilterTotal, 0, 600.0);
      return (true);  
   }

   //-- setup the bolt power
   //-- cast this on the first unit with over 250 hit points
   if (powerProtoID == cPowerBolt)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
     
       //-- create the query used for evaluation
      queryID=kbUnitQueryCreate("Bolt Evaluation");
      if (queryID < 0)
         return (false);

      kbUnitQueryResetData(queryID);
      kbUnitQuerySetPlayerID(queryID, aiGetMostHatedPlayerID());
      kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
      kbUnitQuerySetState(cUnitStateAlive);

      aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());

      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
      aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 250.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());

      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
      return (true);  
   }

     //-- setup the spy power
   if (powerProtoID == cPowerSpy)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
     
       //-- create the query used for evaluation
      queryID=kbUnitQueryCreate("Spy Evaluation");
      if (queryID < 0)
         return (false);

      kbUnitQueryResetData(queryID);
      kbUnitQuerySetPlayerRelation(cPlayerRelationEnemy);

      if (kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureGreek && aiRandInt(2) == 0)
	      kbUnitQuerySetUnitType(queryID, cUnitTypeScout);
      else if (kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureGreek)
	      kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
      else if (kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureEgyptian && aiRandInt(10) > 1)
	      kbUnitQuerySetUnitType(queryID, cUnitTypePharaoh);
      else if (kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureEgyptian)
	      kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
      else if (kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureNorse && aiRandInt(10) > 1)
	      kbUnitQuerySetUnitType(queryID, cUnitTypeOxCart);
      else if (kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureNorse && aiRandInt(10) > 1)
	      kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
      else if (kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureNorse)
	      kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
      else if (kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureAtlantean && aiRandInt(2) == 0)
	      kbUnitQuerySetUnitType(queryID, cUnitTypeOracleScout);
      else if (kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureAtlantean)
	      kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);

      kbUnitQuerySetState(cUnitStateAlive);

      aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);

      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
      return (true);  
   }

      //-- setup the Son of Osiris
      if (powerProtoID == cPowerSonofOsiris)
      {
         aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
     
          //-- create the query used for evaluation
         queryID=kbUnitQueryCreate("Osiris Evaluation");
         if (queryID < 0)
            return (false);

         kbUnitQueryResetData(queryID);
         kbUnitQuerySetPlayerID(queryID, cMyID);
         kbUnitQuerySetUnitType(queryID, cUnitTypePharaoh);
         kbUnitQuerySetState(cUnitStateAlive);

         aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
         aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
         aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
         aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);

         aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);

         //-- kill the empower plan and relic gather plans.
         aiPlanDestroy(gEmpowerPlanID);
         aiPlanDestroy(gRelicGatherPlanID);

         return (true);  
      }

   //-- setup the vision power
   if (powerProtoID == cPowerVision)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      //-- don't need visiblity to cast this one.
      aiPlanSetVariableBool(planID, cGodPowerPlanCheckVisibility, 0, false);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
     
      vector vLoc = guessEnemyLocation();
      aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, vLoc);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      return (true);  
   }      

    //-- setup the rain power to cast when we have at least 5 farms
   if (powerProtoID == cPowerRain)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);

      //-- create the query used for evaluation
      queryID=kbUnitQueryCreate("Rain Evaluation");
      if (queryID < 0)
         return (false);

      kbUnitQueryResetData(queryID);
      kbUnitQuerySetPlayerID(queryID, cMyID);
      kbUnitQuerySetUnitType(queryID, cUnitTypeFarm);
      kbUnitQuerySetState(cUnitStateAlive);

      aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);


      return (true);  
   }

   //-- setup Cease Fire
   //-- This sets up the plan to not cast itself
   //-- we also enable a rule that monitors the state of the player's main base
   //-- and waits until the base is under attack and has no defenders
   if (powerProtoID == cPowerCeaseFire)
   { 
      gCeaseFirePlanID = planID;
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
      xsEnableRule("rCeaseFire");
      return (true);
   }


   //-- setup the Walking Woods power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 10 meters
   if (powerProtoID == cPowerWalkingWoods) 
   {
      //-- basic plan type and eval model
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);

      //-- setup the nearby unit type to cast on
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeTree);

      //-- finish setup
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      return (true);  
   }

     
   //-- setup the Ragnorok Power
   //-- launch at 50 villagers
   if (powerProtoID == cPowerRagnorok)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
     
       //-- create the query used for evaluation
      queryID=kbUnitQueryCreate("Ragnorok Evaluation");
      if (queryID < 0)
         return (false);

      kbUnitQueryResetData(queryID);
      kbUnitQuerySetPlayerID(queryID, cMyID);
      kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
      kbUnitQuerySetState(cUnitStateAlive);

      aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 50);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);

      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
      return (true);  
   }    
   //
   // Set up the Gaia Forest power
   // Just fire and refire whenever we can, in the town.  This will keep a supply of fast-harvesting
   // wood in the well-protected zone around the player's town.
   if (powerProtoID == cPowerGaiaForest)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
      aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      return (true);
   }

      // Set up the Thunder Clap power
   // Logic similar to bronze...look for 5+ enemy units within 30 meters of the attack plan's position
   if (powerProtoID == cPowerTremor)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
//      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeMilitary);  // Var 1 is type to target on?
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      return (true);
   }

   // Set up the deconstruction power
   // Any building over 500 HP counts, cast it on building
   if (powerProtoID == cPowerDeconstruction)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
     
       //-- create the query used for evaluation
      queryID=kbUnitQueryCreate("Deconstruction Evaluation");
      if (queryID < 0)
         return (false);

      kbUnitQueryResetData(queryID);
      kbUnitQuerySetPlayerRelation(queryID, cPlayerRelationEnemy);
      kbUnitQuerySetUnitType(queryID, cUnitTypeLogicalTypeValidDeconstructionTarget);
      kbUnitQuerySetState(cUnitStateAlive);

      aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
 //     aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());

      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
      aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 500.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
//      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());

      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);      
      aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      return (true);
   }


   // Set up the Carnivora power
   // Exactly like Serpents
   if (powerProtoID == cPowerCarnivora)
   {
      if(gTransportMap==true)
      {
         aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
         aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
         aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		   gCarnivoraPlan=planID;
         xsEnableRule("rCarnivora");
         return (true);
      }
      else
      {
         aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
         aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
         aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
         aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
         aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
         aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
         aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
         aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      }
      return (true);
   }

   // Set up the Spiders power
   // Can't be reactive because of time delay.  Would like to place it
   // on gold mines or markets, if we haven't already spidered that location
   //****GK: so be it.
   if (powerProtoID == cPowerSpiders)
   {
/*
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
      aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
      aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      return (true);
*/
      gSpidersPlan = planID;
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
      aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      xsEnableRule("rSpiders");
      return (true);
   }

   // Set up the heroize power
   // Any time we have a group of 8 or more military units
   if (powerProtoID == cPowerHeroize)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      return (true);
   }

   // Set up the chaos power
   // 12 enemy mil units within 30m of attack plan
   if (powerProtoID == cPowerChaos)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
//      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
//      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeMilitary);  // Target on this type
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
      aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
         aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      return (true);
   }


   // Set up the Traitors power
   // Same as bolt, anything over 200 HP
   if (powerProtoID == cPowerTraitors)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
     
       //-- create the query used for evaluation
      queryID=kbUnitQueryCreate("Traitors Evaluation");
      if (queryID < 0)
         return (false);

      kbUnitQueryResetData(queryID);
      kbUnitQuerySetPlayerRelation(queryID, cPlayerRelationEnemy);
      kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
      kbUnitQuerySetState(cUnitStateAlive);

      aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
      aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 200.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
      aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
      return (true);  
   }

   // Set up the hesperides power
   // Near the military gather point, for good protection
   if (powerProtoID == cPowerHesperides)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      if(gForwardBaseID >= 0)
      {
         aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, kbBaseGetLocation(cMyID, gForwardBaseID));
         aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
         aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 15.0);
      }
      else
      {
         aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelMilitaryGatherPoint);
         aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 25.0);
      }
      aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      return (true);
   }

   // Set up the implode power
   // Look for at least a dozen units, target it on a building (to be sure at least one exists)
   if (powerProtoID == cPowerImplode)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
      aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeBuilding);  // Target on this type
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeUnit);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
      aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      return (true);
   }

   // Set up the tartarian gate power
   // Fire if >= 4 military buildings near my army...will kill my army, but may take out their center, too.
   if (powerProtoID == cPowerTartarianGate)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		gHeavyGPTech=cTechTartarianGate;
		gHeavyGPPlan=planID;
      xsEnableRule("rCastHeavyGP");
      return (true);
   }

   // Set up the vortex power
   // If there are at least 15 (count 'em, 15!) enemy military units in my town, panic
   if (powerProtoID == cPowerVortex)
   {
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
      aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
      aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
      aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
      aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
      aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
      aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
      aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
      return (true);
   }

   return (false);
}

//==============================================================================
// initGP - initialize the god power module
//==============================================================================
void initGodPowers(void)
{
   OUTPUT("GP Init.", TRACE);
}

//==============================================================================
// Age 1 GP Rule
//==============================================================================
rule rAge1FindGP
   minInterval 12
   active
{
	int id=aiGetGodPowerTechIDForSlot(0); 
	if (id == -1)
		return;

	gAge1GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan.
	gAge1GodPowerPlanID=aiPlanCreate("Age1GodPower", cPlanGodPower);
	if (gAge1GodPowerPlanID == -1)
	{
	   //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
	}

	aiPlanSetVariableInt(gAge1GodPowerPlanID,  cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gAge1GodPowerPlanID, 100);
	aiPlanSetEscrowID(gAge1GodPowerPlanID, -1);

   //Setup the god power based on the type.
   if (setupGodPowerPlan(gAge1GodPowerPlanID, gAge1GodPowerID) == false)
   {
      aiPlanDestroy(gAge1GodPowerPlanID);
      gAge1GodPowerID=-1;
      xsDisableSelf();
      return;
   }

   if (cvOkToUseAge1GodPower == true)
   	aiPlanSetActive(gAge1GodPowerPlanID);

	//Kill ourselves if we every make a plan.
	xsDisableSelf();
}


//==============================================================================
// Age 2 GP Rule
//==============================================================================
rule rAge2FindGP
   minInterval 12
   inactive
{
	//Figure out the age2 god power and create the plan.
	int id=aiGetGodPowerTechIDForSlot(1); 
	if (id == -1)
	  return;

	gAge2GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan.
	gAge2GodPowerPlanID=aiPlanCreate("Age2GodPower", cPlanGodPower);
	if (gAge2GodPowerPlanID == -1)
   {
      //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
   }

	aiPlanSetVariableInt(gAge2GodPowerPlanID, cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gAge2GodPowerPlanID, 100);
	aiPlanSetEscrowID(gAge2GodPowerPlanID, -1);

   //Setup the god power based on the type.
   if (setupGodPowerPlan(gAge2GodPowerPlanID, gAge2GodPowerID) == false)
   {
      aiPlanDestroy(gAge2GodPowerPlanID);
      gAge2GodPowerID = -1;
      xsDisableSelf();
      return;
   }

   OUTPUT("initializing god power plan for age 2", GPINFO);
   if (cvOkToUseAge2GodPower == true)
      aiPlanSetActive(gAge2GodPowerPlanID);

	//Kill ourselves if we every make a plan.
	xsDisableSelf();
}


//==============================================================================
// Age 3 GP Rule
//==============================================================================
rule rAge3FindGP
   minInterval 12
   inactive
{
	//Figure out the age3 god power and create the plan.
	int id=aiGetGodPowerTechIDForSlot(2); 
	if (id == -1)
	  return;

	gAge3GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan
	gAge3GodPowerPlanID=aiPlanCreate("Age3GodPower", cPlanGodPower);
	if (gAge3GodPowerPlanID == -1)
	{
       //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
   }

	aiPlanSetVariableInt(gAge3GodPowerPlanID, cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gAge3GodPowerPlanID, 100);
	aiPlanSetEscrowID(gAge3GodPowerPlanID, -1);

   //Setup the god power based on the type.
   if (setupGodPowerPlan(gAge3GodPowerPlanID, gAge3GodPowerID) == false)
   {
      aiPlanDestroy(gAge3GodPowerPlanID);
      gAge3GodPowerID = -1;
      xsDisableSelf();
      return;
   }

   OUTPUT("initializing god power plan for age 3", GPINFO);
   if (cvOkToUseAge3GodPower == true)
      aiPlanSetActive(gAge3GodPowerPlanID);

   //Kill ourselves if we every make a plan.
	xsDisableSelf();
}


//==============================================================================
// Age 4 GP Rule
//==============================================================================
rule rAge4FindGP
   minInterval 12
   inactive
{
	//Figure out the age4 god power and create the plan.
	int id = aiGetGodPowerTechIDForSlot(3); 
	if (id == -1)
	  return;

	gAge4GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan.
	gAge4GodPowerPlanID=aiPlanCreate("Age4GodPower", cPlanGodPower);
	if (gAge4GodPowerPlanID == -1)
   {
      //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
   }

	aiPlanSetVariableInt(gAge4GodPowerPlanID, cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gAge4GodPowerPlanID, 100);
	aiPlanSetEscrowID(gAge4GodPowerPlanID, -1);

   //Setup the god power based on the type.
   if (setupGodPowerPlan(gAge4GodPowerPlanID, gAge4GodPowerID) == false)
   {
      aiPlanDestroy(gAge4GodPowerPlanID);
      gAge4GodPowerID=-1;
      xsDisableSelf();
      return;
   }

   OUTPUT("initializing god power plan for age 4", GPINFO);
   if (cvOkToUseAge4GodPower == true)
      aiPlanSetActive(gAge4GodPowerPlanID);

   //Kill ourselves if we every make a plan.
	xsDisableSelf();
	return;
}

//==============================================================================
// Cease Fire Rule
//==============================================================================
rule rCeaseFire
   minInterval 21
   inactive
{
   static int defCon=0;
   bool nowUnderAttack=kbBaseGetUnderAttack(cMyID, kbBaseGetMainID(cMyID));

   //Not in a state of alert.
   if (defCon == 0)
   {
      //Just get out if we are safe.
      if (nowUnderAttack == false)
         return;  
      //Up the alert level and come back later.
      defCon=defCon+1;
      return;
   }

   //If we are no longer under attack and below this point, then reset and get out.
   if (nowUnderAttack == false)
   {
      defCon=0;
      return;
   }

   //Otherwise handle the different alert levels.
   //Do we have any help in the area that we can use?
  //If we don't have a query ID, create it.
   static int allyQueryID=-1;
   if (allyQueryID < 0)
   {
      allyQueryID=kbUnitQueryCreate("AllyCount");
      //If we still don't have one, bail.
      if (allyQueryID < 0)
         return;
   }

   //Else, setup the query data.
   kbUnitQuerySetPlayerRelation(cPlayerRelationAlly);
   kbUnitQuerySetUnitType(allyQueryID, cUnitTypeMilitary);
   kbUnitQuerySetState(allyQueryID, cUnitStateAlive);
   //Reset the results.
   kbUnitQueryResetResults(allyQueryID);
   //Run the query. 
   int count=kbUnitQueryExecute(allyQueryID);

   //If there are still allies in the area, then just stay at this alert level.
   if (count > 0)
      return;

   //Defcon 2.  Cast the god power.
   aiPlanSetVariableBool(gCeaseFirePlanID, cGodPowerPlanAutoCast, 0, true); 
   xsDisableSelf();
}


//==============================================================================
// Unbuild Rule      
//==============================================================================
rule rUnbuild
   minInterval 12
   inactive
{

	//Create the plan.
	gUnbuildPlanID = aiPlanCreate("Unbuild", cPlanGodPower);
	if (gUnbuildPlanID == -1)
	{
	   //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
	}

//	aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gUnbuildPlanID, 100);
	aiPlanSetEscrowID(gUnbuildPlanID, -1);

   //Setup the plan.. 
   // these are first pass.. fix these eventually.. 
   aiPlanSetVariableBool(gUnbuildPlanID, cGodPowerPlanAutoCast, 0, true); 
   aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
   aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
//   aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
   aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnbuild);
   aiPlanSetVariableFloat(gUnbuildPlanID,  cGodPowerPlanDistance, 0, 40.0);
   aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeBuildingsNotWalls);
   aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanCount, 0, 1);


	aiPlanSetActive(gUnbuildPlanID);

	//Kill ourselves if we every make a plan.
	xsDisableSelf();
}

//==============================================================================
// Forest Fire Rule
//==============================================================================
rule rForestFire
   minInterval 15
   inactive
{
   static int enemyQueryID = -1;
   static int treeQueryID = -1;
   static int treeQueryID2 = -1;
   static int tryCount = 0;

   int planID = gForestFirePlanID;
   int mostHatedPlayerID=aiGetMostHatedPlayerID();

   if (planID < 0)
   {
	xsDisableSelf();
	return;
   }

   //If we don't have the query yet, create one.
   if (treeQueryID < 0)
   treeQueryID=kbUnitQueryCreate("Tree Query");
   
   //Define a query to get all matching units
   if (treeQueryID != -1)
   {
      kbUnitQuerySetPlayerID(treeQueryID, 0);
      kbUnitQuerySetUnitType(treeQueryID, cUnitTypeTree);
      kbUnitQuerySetState(treeQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(treeQueryID);
   int treeFound=kbUnitQueryExecute(treeQueryID);

// Weird if statement below happens... :P
   if (treeFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (treeQueryID2 < 0)
   treeQueryID2=kbUnitQueryCreate("Tree Surrounding Query");
   
   //Define a query to get all matching units
   if (treeQueryID2 != -1)
   {
		kbUnitQuerySetPlayerID(treeQueryID2, 0);
		kbUnitQuerySetUnitType(treeQueryID2, cUnitTypeTree);
	        kbUnitQuerySetState(treeQueryID2, cUnitStateAlive);
		kbUnitQuerySetMaximumDistance(treeQueryID2, 8);
   }

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Enemy Villager Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeAbstractVillager);
      kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 8);
   }

   int numberFoundTemp = 0;
   int numberTreeTemp = 0;

   for (i=0; < treeFound)
   {
	   kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(treeQueryID, i)));
	   kbUnitQuerySetPosition(treeQueryID2, kbUnitGetPosition(kbUnitQueryGetResult(treeQueryID, i)));
	   kbUnitQueryResetResults(enemyQueryID);
	   numberFoundTemp=kbUnitQueryExecute(enemyQueryID);
	   kbUnitQueryResetResults(treeQueryID2);
	   numberTreeTemp=kbUnitQueryExecute(treeQueryID2);
	   if (numberFoundTemp > 2 && numberTreeTemp > 3)
	   {
   		if ((aiCastGodPowerAtUnit(cTechForestFire,kbUnitQueryGetResult(treeQueryID, i)) == true) ||
				 (tryCount > 60))
   		{
  				aiPlanDestroy(planID);
     			kbUnitQueryDestroy(treeQueryID);
      		kbUnitQueryDestroy(treeQueryID2);
	      	kbUnitQueryDestroy(enemyQueryID);
		     	xsDisableSelf();
			   return;
		   }
		   else
		      tryCount = tryCount + 1;
	   }
   }
}

//==============================================================================
// Age 2 Handler
//==============================================================================
void gpAge2Handler(int age=1)
{
   xsEnableRule("rAge2FindGP");
}

//==============================================================================
// Age 3 Handler
//==============================================================================
void gpAge3Handler(int age=2)
{
	xsEnableRule("rAge3FindGP");  
}

//==============================================================================
// Age 4 Handler
//==============================================================================
void gpAge4Handler(int age=3)
{
	xsEnableRule("rAge4FindGP");
}

//==============================================================================
// Dwarven Mine Rule
//==============================================================================
rule rDwarvenMinePower
   minInterval 59
   inactive
{
   if (gDwarvenMinePlanID == -1)
   {
      xsDisableSelf();
      return;
   }

   //Are we in the third age yet??
   if (kbGetAge() < 2)
      return;

   //Are we gathering gold?  If so, then enable the gold mine to be cast.
   float fPercent=aiGetResourceGathererPercentage(cResourceGold, cRGPActual);
   if (fPercent <= 0.0)
      return;
       
   aiPlanSetVariableBool(gDwarvenMinePlanID, cGodPowerPlanAutoCast, 0, true);
   
   //Finished.
   gDwarvenMinePlanID=-1;
   xsDisableSelf();
}

//==============================================================================
// unbuildHandler
//==============================================================================
void unbuildHandler(void)
{
   xsEnableRule("rUnbuild");
}

//==============================================================================
// Titan Gate Rule
//==============================================================================
rule rPlaceTitanGate
   minInterval 12
   inactive
{

	//Figure out the age 5 (yes, 5) god power and create the plan.
	int id = aiGetGodPowerTechIDForSlot(4); 
	if (id == -1)
	  return;

	gAge5GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan.
	gPlaceTitanGatePlanID = aiPlanCreate("PlaceTitanGate", cPlanGodPower);
	if (gPlaceTitanGatePlanID == -1)
	{
	   //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
	}

	// Set the Base
	aiPlanSetBaseID(gPlaceTitanGatePlanID, kbBaseGetMainID(cMyID));

	aiPlanSetVariableInt(gPlaceTitanGatePlanID,  cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gPlaceTitanGatePlanID, 100);
	aiPlanSetEscrowID(gPlaceTitanGatePlanID, -1);

    //Setup the plan.. 
	aiPlanSetVariableBool(gPlaceTitanGatePlanID, cGodPowerPlanAutoCast, 0, true); 
	aiPlanSetVariableInt(gPlaceTitanGatePlanID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
	aiPlanSetVariableInt(gPlaceTitanGatePlanID, cGodPowerPlanCount, 0, 6);
	aiPlanSetVariableInt(gPlaceTitanGatePlanID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
	//-- override the default building placement distance so that plenty has some room to cast
	//-- it is pretty big..
	aiPlanSetVariableFloat(gPlaceTitanGatePlanID, cGodPowerPlanBuildingPlacementDistance, 0, 100.0);

	aiPlanSetActive(gPlaceTitanGatePlanID);

	//Kill ourselves if we ever make a plan.
	xsDisableSelf();
}

//==============================================================================
// Sentinel Rule --- 
//==============================================================================
rule rSentinel
   minInterval 2
   inactive
{

   int planID=gSentinelPlanID;
   static int unitQueryID=-1;
   static int enemyQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("Settlement Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
      if (aiRandInt(100) < 50)
      {
         kbUnitQuerySetPlayerID(unitQueryID, cMyID);
         kbUnitQuerySetPlayerRelation(unitQueryID, cPlayerRelationSelf);
      }
      else
      {
         kbUnitQuerySetPlayerID(unitQueryID, -1);
         kbUnitQuerySetPlayerRelation(unitQueryID, cPlayerRelationAlly);
      }
      kbUnitQuerySetUnitType(unitQueryID, cUnitTypeAbstractSettlement);
      kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
   }

   kbUnitQueryResetResults(unitQueryID);
   int settlementFound=kbUnitQueryExecute(unitQueryID);

   if (settlementFound < 1)
	return;

   //If we don't have the query yet, create one.
   if (enemyQueryID < 0)
   enemyQueryID=kbUnitQueryCreate("Enemy Query");
   
   //Define a query to get all matching units
   if (enemyQueryID != -1)
   {
		kbUnitQuerySetPlayerID(enemyQueryID, -1);
		kbUnitQuerySetPlayerRelation(enemyQueryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQueryID, cUnitTypeLogicalTypeLandMilitary);
	        kbUnitQuerySetState(enemyQueryID, cUnitStateAlive);
		kbUnitQuerySetMaximumDistance(enemyQueryID, 32);
   }

   int i=0;
   int baseID=-1;
   int enemyFound=0;
   for (i=0; < settlementFound)
   {
      kbUnitQuerySetPosition(enemyQueryID, kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i)));
      kbUnitQueryResetResults(enemyQueryID);
   	enemyFound=kbUnitQueryExecute(enemyQueryID);
   	if (enemyFound > 4)
      {
         baseID = kbUnitGetBaseID(kbUnitQueryGetResult(unitQueryID, i));
      	break;
      }
   }
  
   if (baseID != -1)
   {
   	if (aiCastGodPowerAtUnit(cTechSentinel,kbUnitQueryGetResult(unitQueryID, i)) == true)
   	{
   	   aiPlanSetBaseID(planID, baseID);
   	   aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
   	   aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
   	   aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
   	   xsDisableSelf();
   	}
   }

}

//==============================================================================
// rCarnivora -- 
//==============================================================================
rule rCarnivora
   inactive
	minInterval 4
{
   static int dockQueryID=-1;
	static int times=0;
	static vector loc1=cInvalidVector;
	static vector loc2=cInvalidVector;
	static vector loc3=cInvalidVector;
	
	// we have cast three times, disable self.
	if(times >= 3)
	{
	   kbUnitQueryDestroy(dockQueryID);
		aiPlanDestroy(gCarnivoraPlan);
		xsDisableSelf();
		return;
	}


	xsSetRuleMinIntervalSelf(4);

	if(dockQueryID < 0)
	{
	   dockQueryID=kbUnitQueryCreate("Enemy Dock Query");
	   configQueryRelation(dockQueryID, cUnitTypeDock, -1, cUnitStateAlive, cPlayerRelationEnemy);
	}

	kbUnitQueryResetResults(dockQueryID);
	int numDocks=kbUnitQueryExecute(dockQueryID);
	for(j=0; < numDocks)
	{
		vector loc=kbUnitGetPosition(kbUnitQueryGetResult(dockQueryID, j));
		if(equal(loc, loc1) == true)
		   continue;
		if(equal(loc, loc2) == true)
		   continue;
		if(equal(loc, loc3) == true)
		   continue;

		int waterAreaID=kbAreaGetClosetArea(loc, cAreaTypeWater);
//		OUTPUT("rCarnivora: closest water area ID="+waterAreaID, GPINFO);
		vector areaCenter=kbAreaGetCenter(waterAreaID);
		vector towardsCenter=areaCenter-loc;
		towardsCenter=xsVectorNormalize(towardsCenter);
//		OUTPUT("rCarnivora: dock is at x="+xsVectorGetX(loc)+" z="+xsVectorGetZ(loc)+".", GPINFO);
		vector carnivoraloc = loc + towardsCenter*8.0;
//		OUTPUT("rCarnivora: Carnivora should be at x="+xsVectorGetX(loc)+" z="+xsVectorGetZ(loc)+".", GPINFO);

		if(kbLocationVisible(carnivoraloc) == true)
		{
		   if(aiCastGodPowerAtPosition(cTechAudrey,carnivoraloc) == true)
         {
         	if(equal(loc1, cInvalidVector) == true)
         	   loc1=loc;
         	else if(equal(loc2, cInvalidVector) == true)
	         	loc2=loc;
         	else if(equal(loc3, cInvalidVector) == true)
	         	loc3=loc;
            times=times+1;
	         OUTPUT("Carnivora successfully cast at dock! It was the "+times+" time.", GPINFO);
				// wait until it is available again!
				xsSetRuleMinIntervalSelf(125);
		   	break;
		   }
		}
	}
}

//==============================================================================
// rSpiders -- 
//==============================================================================
rule rSpiders
   inactive
	minInterval 4
{
   static int goldQueryID=-1;
	static int marketQueryID=-1;
	static int villQueryID=-1;
	static vector loc1=cInvalidVector;
	static vector loc2=cInvalidVector;
	static vector loc3=cInvalidVector;
	static int times=0;

	// we have cast three times, disable self.
	if(times >= 3)
	{
	   kbUnitQueryDestroy(goldQueryID);
		kbUnitQueryDestroy(marketQueryID);
		kbUnitQueryDestroy(villQueryID);
		aiPlanDestroy(gSpidersPlan);
		xsDisableSelf();
		return;
	}

	xsSetRuleMinIntervalSelf(4);

	if(marketQueryID < 0)
	{
	   marketQueryID=kbUnitQueryCreate("Enemy Market Query");
	   configQueryRelation(marketQueryID, cUnitTypeMarket, -1, cUnitStateAlive, cPlayerRelationEnemy);
	}

	kbUnitQueryResetResults(marketQueryID);
	int numMarkets=kbUnitQueryExecute(marketQueryID);
	for(j=0; < numMarkets)
	{
		vector loc=kbUnitGetPosition(kbUnitQueryGetResult(marketQueryID, j));
		if(equal(loc, loc1) == true)
		   continue;
		if(equal(loc, loc2) == true)
		   continue;
		if(equal(loc, loc3) == true)
		   continue;

		if(aiCastGodPowerAtPosition(cTechSpiders,loc) == true)
      {
      	if(equal(loc1, cInvalidVector) == true)
      	   loc1=loc;
      	else if(equal(loc2, cInvalidVector) == true)
	      	loc2=loc;
      	else if(equal(loc3, cInvalidVector) == true)
	      	loc3=loc;

         times=times+1;
	      OUTPUT("Spiders successfully cast at market! It was the "+times+" time.", GPINFO);

      	// wait until it is available again!
      	xsSetRuleMinIntervalSelf(305);
      }
      return;
	}

	if(goldQueryID < 0)
	{
	   goldQueryID=kbUnitQueryCreate("Gold Heap Query");
	   configQuery(goldQueryID, cUnitTypeGold, -1, cUnitStateAlive, 0);
	}

	if(villQueryID < 0)
	   villQueryID=kbUnitQueryCreate("Goldie Query");

	kbUnitQueryResetResults(goldQueryID);
	int numGold=kbUnitQueryExecute(goldQueryID);
	for(i=0; < numGold)
	{
		loc=kbUnitGetPosition(kbUnitQueryGetResult(goldQueryID, i));
		if(equal(loc, loc1) == true)
		   continue;
		if(equal(loc, loc2) == true)
		   continue;
		if(equal(loc, loc3) == true)
		   continue;

	   kbUnitQueryResetData(villQueryID);
		configQueryRelation(villQueryID, cUnitTypeAbstractVillager, -1, cUnitStateAlive, cPlayerRelationEnemy, loc, false, 10.0);
		kbUnitQueryResetResults(villQueryID);
		int numVills=kbUnitQueryExecute(villQueryID);
		if( (numVills >= 5) && (kbLocationVisible(loc)==true) )
		{
   		if(aiCastGodPowerAtPosition(cTechSpiders,loc) == true)
			{
				if(equal(loc1, cInvalidVector) == true)
				   loc1=loc;
				else if(equal(loc2, cInvalidVector) == true)
					loc2=loc;
				else if(equal(loc3, cInvalidVector) == true)
					loc3=loc;

			   times=times+1;
				OUTPUT("Spiders successfully cast at gold! It was the "+times+" time.", GPINFO);

				// wait until it is available again!
				xsSetRuleMinIntervalSelf(305);
			}
		   return;
		}
	}
}

//==============================================================================
// RULE rCastHeavyGP -- 
//==============================================================================
rule rCastHeavyGP
   minInterval 5
	inactive
{
   static int settleQuery=-1;
	static int fortressQuery=-1;
	static int farmQuery=-1;

	if(settleQuery < 0)
	{
	   settleQuery=kbUnitQueryCreate("Enemy Settle Query");
		configQueryRelation(settleQuery, cUnitTypeAbstractSettlement, -1, cUnitStateAlive, cPlayerRelationEnemy);
	}

	if(fortressQuery < 0)
	   fortressQuery=kbUnitQueryCreate("Fortress Query");
	if(farmQuery < 0)
	   farmQuery=kbUnitQueryCreate("Farm Query");

	kbUnitQueryResetResults(settleQuery);
	int numSettles=kbUnitQueryExecute(settleQuery);
	for(i=0; <numSettles)
	{
	   vector loc=kbUnitGetPosition(kbUnitQueryGetResult(settleQuery, i));
		kbUnitQueryResetData(fortressQuery);
		kbUnitQueryResetData(farmQuery);
		configQueryRelation(fortressQuery, cUnitTypeAbstractFortress, -1, cUnitStateAlive, cPlayerRelationEnemy, loc, false, 40.0);
		configQueryRelation(farmQuery, cUnitTypeFarm, -1, cUnitStateAlive, cPlayerRelationEnemy, loc, false, 30.0);

		kbUnitQueryResetResults(fortressQuery);
		kbUnitQueryResetResults(farmQuery);
		int numForts=kbUnitQueryExecute(fortressQuery);
		int numFarms=kbUnitQueryExecute(farmQuery);
		if( (numFarms > 0) && (numForts > 0) )
		{
			if(gHeavyGPTech == cTechTartarianGate)
			{
			   loc=kbUnitGetPosition(kbUnitQueryGetResult(fortressQuery, i));
			}

         if(kbLocationVisible(loc) == true)
			{
      		if(aiCastGodPowerAtPosition(gHeavyGPTech,loc) == true)
   			{
   				kbUnitQueryDestroy(settleQuery);
   				kbUnitQueryDestroy(fortressQuery);
   				kbUnitQueryDestroy(farmQuery);
   		      aiPlanDestroy(gHeavyGPPlan);
   			   xsDisableSelf();
   				return;
   			}
			}
		}
	}
}

