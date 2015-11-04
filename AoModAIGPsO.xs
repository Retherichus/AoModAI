//==============================================================================
// AoMod AI
// AoModAIGPs.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// This is the basic logic behind the casting of the various god powers
// Although some are rule driven, much of the complex searches and casting logic
// is handled by the C++ code.
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
//   This is typicaly used for powers that improve friendly units, like bronze, 
//   flaming weapons, and eclipse.  
//
// *****************************************************************************
//==============================================================================

//==============================================================================
vector findHuntableInfluence()
{
    aiEcho("findHuntableInfluence:");    
   
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
bool setupGodPowerPlan(int planID = -1, int powerProtoID = -1)
{
    aiEcho("setupGodPowerPlan:");    

    if (planID == -1)
        return (false);
    if (powerProtoID == -1)
        return (false);

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
    aiPlanSetBaseID(planID, mainBaseID);

    //-- setup prosperity
    //-- This sets up the plan to cast itself when there are 5 people working on gold
    if (powerProtoID == cPowerProsperity)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
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
//        aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 100.0);
        aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 140.0);
        return (true);
    }

    //-- setup the serpents power
    if (powerProtoID == cPowerPlagueofSerpents)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
//        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
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
        gHeavyGPTechID = cTechEarthquake;
        gHeavyGPPlanID = planID;
        xsEnableRule("castHeavyGP");
    
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        return (true);  
    }

//==============================================================================
// Citadel power
//==============================================================================	
    //-- setup the Citadel power
    //-- disabled auto casting, cast when under attack
    if (powerProtoID == cPowerCitadel)
    {
        fCitadelPlanID = planID;
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
        xsEnableRule("rCitadel");
        return (true);  
    }	

//==============================================================================

    //-- setup the dwarven mine
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
    if (powerProtoID == cPowerCurse)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
//        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
    }

    //-- setup the Eclipse power
    //-- this power will cast when it has a valid attack plan within the specified range
    //-- the attack plan is setup in the initializeAttack function  
    //-- the valid distance is 50 meters, and at least 5 archers must be found
    //-- this works on buildings
    if (powerProtoID == cPowerEclipse)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 2);
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
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableFloat(planID,cGodPowerPlanDistance, 0, 40.0);
        aiPlanSetVariableInt(planID,  cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractSettlement);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        return (true);  
    }

    //-- setup the frost power
    if (powerProtoID == cPowerFrost)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
//        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 20);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
    }

    //-- setup the healing spring power
    //-- cast this within 75 meters of the military gather 
    if (powerProtoID == cPowerHealingSpring)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelMilitaryGatherPoint);
        aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 75.0);
        return (true);  
    }

    //-- setup the lightening storm power
    if (powerProtoID == cPowerLightningStorm)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
//        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 20);
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
        gHeavyGPTechID = cTechMeteor;
        gHeavyGPPlanID = planID;
        xsEnableRule("castHeavyGP");
        
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        return (true);  
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

    //-- setup the Restoration power ''DISABLED FOR ONLINE FUNCTION, remove the excessive ''//'' to enable.''
//    if (powerProtoID == cPowerRestoration)
//    {
//        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
//        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
//        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
//        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
//        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
//        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
//        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
//        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
//        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
//        return (true);  
//    }

    //-- setup the Sentinel power
    //-- disabled auto casting, cast when under attack
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
    if (powerProtoID == cPowerAncestors)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
//        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
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
    //-- cast this on the first unit with over 810 hit points

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
        aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 810.0);
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
     
        vector vLoc = vector(-1.0, -1.0, -1.0);

        //-- calculate the location to vision
        //-- find the center of the map
        vector vCenter = kbGetMapCenter();
        vector vTC = kbGetTownLocation();
        float centerx = xsVectorGetX(vCenter);
        float centerz = xsVectorGetZ(vCenter);
        float xoffset =  centerx - xsVectorGetX(vTC);
        float zoffset =  centerz - xsVectorGetZ(vTC);

        //xoffset = xoffset * -1.0;
        //zoffset = zoffset * -1.0;

        centerx = centerx + xoffset;
        centerz = centerz + zoffset;

        //-- cast this on the newly created location (reflected across the center)
        vLoc = xsVectorSetX(vLoc, centerx);
        vLoc = xsVectorSetZ(vLoc, centerz);

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
    if (powerProtoID == cPowerRagnorok)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 

        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        gRagnorokPlanID = planID;
        xsEnableRule("rRagnorokPower");
        return (true);  
    }

    
    // Set up the Gaia Forest power
    if (powerProtoID == cPowerGaiaForest)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        //-- set up the global
        gGaiaForestPlanID = planID;
        //-- enable the monitoring rule
        xsEnableRule("rGaiaForestPower");
        return (true);
    }

    // Set up the Thunder Clap power
    if (powerProtoID == cPowerTremor)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
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

        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
        aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 500.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);

        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);      
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
    }

    // Set up the Carnivora power
    if (powerProtoID == cPowerCarnivora)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
//        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
    }

    // Set up the Spiders power
    if (powerProtoID == cPowerSpiders)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
//        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
    }

    // Set up the heroize power
    // Any time we have a group of 8 or more military units
    if (powerProtoID == cPowerHeroize)
    {
//        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
//TODO: add a rule to cast it only on units in gDefendPlan
         
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
    }

    // Set up the chaos power
    if (powerProtoID == cPowerChaos)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
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
//        aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 200.0);
        aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 500.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
        aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);  
    }

    // Set up the hesperides power
    // Near the military gather point, for good protection
    if (powerProtoID == cPowerHesperides)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelMilitaryGatherPoint);
        aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 25.0);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        //-- set up the global
        gHesperidesPlanID = planID;
        //-- enable the monitoring rule
        xsEnableRule("rHesperidesPower");
        return (true);
    }

    // Set up the implode power
    if (powerProtoID == cPowerImplode)
    {
        gHeavyGPTechID = cTechImplode;
        gHeavyGPPlanID = planID;
        xsEnableRule("castHeavyGP");
        
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
        return (true);
    }

    // Set up the tartarian gate power
    // Fire if >= 4 military buildings near my army...will kill my army, but may take out their center, too.
    if (powerProtoID == cPowerTartarianGate)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeFarm);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
//        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
    }

    // Set up the vortex power
    if (powerProtoID == cPowerVortex)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
    }

    return (false);
}

//==============================================================================
void initGodPowers(void)    //initialize the god power module
{
    aiEcho("GP Init.");
    xsEnableRule("rAge1FindGP");
}

//==============================================================================
rule rAge1FindGP
    minInterval 12 //starts in cAge1
    inactive
{
    aiEcho("rAge1FindGP:");    

    int id=aiGetGodPowerTechIDForSlot(0); 
    if (id == -1)
        return;

    gAge1GodPowerID=aiGetGodPowerProtoIDForTechID(id);

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

    xsDisableSelf();
}

//==============================================================================
rule rAge2FindGP
    minInterval 12 //starts in cAge2
    inactive
{
    aiEcho("rAge2FindGP:");    

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

    aiEcho("initializing god power plan for age 2");
    if (cvOkToUseAge2GodPower == true)
        aiPlanSetActive(gAge2GodPowerPlanID);

    xsDisableSelf();
}

//==============================================================================
rule rAge3FindGP
    minInterval 12 //starts in cAge3
    inactive
{
    aiEcho("rAge3FindGP:");    

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

    aiEcho("initializing god power plan for age 3");
    if (cvOkToUseAge3GodPower == true)
        aiPlanSetActive(gAge3GodPowerPlanID);

    xsDisableSelf();
}

//==============================================================================
rule rAge4FindGP
    minInterval 12 //starts in cAge4
    inactive
{
    aiEcho("rAge4FindGP:");    

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

    aiEcho("initializing god power plan for age 4");
    if (cvOkToUseAge4GodPower == true)
        aiPlanSetActive(gAge4GodPowerPlanID);

    xsDisableSelf();
}

//==============================================================================
rule rCeaseFire
    minInterval 21 //starts in cAge2
    inactive
{
    aiEcho("rCeaseFire:");    

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
rule rUnbuild
    minInterval 12 //starts in cAge1
    inactive
{
    aiEcho("rUnbuild:");    

    //Create the plan.
    gUnbuildPlanID = aiPlanCreate("Unbuild", cPlanGodPower);
    if (gUnbuildPlanID == -1)
    {
        //This is bad, and we most likely can never build a plan, so kill ourselves.
        xsDisableSelf();
        return;
    }

    aiPlanSetDesiredPriority(gUnbuildPlanID, 100);
    aiPlanSetEscrowID(gUnbuildPlanID, -1);

    //Setup the plan.. 
    // these are first pass.. fix these eventually.. 
    aiPlanSetVariableBool(gUnbuildPlanID, cGodPowerPlanAutoCast, 0, true); 
    aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
    aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
    aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnbuild);
    aiPlanSetVariableFloat(gUnbuildPlanID,  cGodPowerPlanDistance, 0, 40.0);
    aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeBuildingsNotWalls);
    aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanCount, 0, 1);

    aiPlanSetActive(gUnbuildPlanID);
    xsDisableSelf();
}

//==============================================================================
void gpAge2Handler(int age=1)
{
    aiEcho("gpAge2Handler:");    

    xsEnableRule("rAge2FindGP");
}

//==============================================================================
void gpAge3Handler(int age=2)
{
    aiEcho("gpAge3Handler:");    

    xsEnableRule("rAge3FindGP");  
}

//==============================================================================
void gpAge4Handler(int age=3)
{
    aiEcho("gpAge4Handler:");    

    xsEnableRule("rAge4FindGP");
}

//==============================================================================
rule rDwarvenMinePower
    minInterval 109 //starts in cAge1
    inactive
{
    aiEcho("rDwarvenMinePower:");

    if (gDwarvenMinePlanID == -1)
    {
        xsDisableSelf();
        return;
    }

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numGoldMinesNearMBInR85 = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, mainBaseLocation, 85.0);
    //Are we in the third age yet? If not cast it only if there are no gold mines in range
//    if (kbGetAge() < cAge3)
    if ((kbGetAge() < cAge3) && (numGoldMinesNearMBInR85 > 0))
        return;
       
    aiPlanSetVariableBool(gDwarvenMinePlanID, cGodPowerPlanAutoCast, 0, true);
   
    //Finished.
    gDwarvenMinePlanID = -1;
    xsDisableSelf();
}

//==============================================================================
void unbuildHandler(void)
{
    aiEcho("unbuildHandler:");    

    xsEnableRule("rUnbuild");
}

//==============================================================================
rule rPlaceTitanGate
//    minInterval 12 //starts in cAge5
    minInterval 11 //starts in cAge5
    inactive
{
    aiEcho("rPlaceTitanGate:");    

    //Figure out the age 5 (yes, 5) god power and create the plan.
    int id = aiGetGodPowerTechIDForSlot(4); 
    if (id == -1)
        return;

    gAge5GodPowerID=aiGetGodPowerProtoIDForTechID(id);

    //Create the plan.
    gPlaceTitanGatePlanID = aiPlanCreate("PlaceTitanGate", cPlanGodPower);
    if (gPlaceTitanGatePlanID == -1)
    {
/*
        //This is bad, and we most likely can never build a plan, so kill ourselves.
        xsDisableSelf();
*/
    // TODO: does this work at all?
        aiEcho("____-----____ couldn't create plan to place Titan Gate, retrying in 2 minutes");
        xsSetRuleMinIntervalSelf(127);
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
    //-- override the default building placement distance so that the Titan Gate has some room to cast
    //-- it is pretty big..
//    aiPlanSetVariableFloat(gPlaceTitanGatePlanID, cGodPowerPlanBuildingPlacementDistance, 0, 100.0);
    aiPlanSetVariableFloat(gPlaceTitanGatePlanID, cGodPowerPlanBuildingPlacementDistance, 0, 110.0);

    aiPlanSetActive(gPlaceTitanGatePlanID);

    xsDisableSelf();
}

//==============================================================================
rule rSentinel
    minInterval 11 //starts in cAge1
    inactive
{
    aiEcho("rSentinel:");    

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
rule rRagnorokPower
    minInterval 13 //starts in cAge4
    inactive
{
    aiEcho("rRagnorokPower:");    

    if (gRagnorokPlanID == -1)
    {
        xsDisableSelf();
        return;
    }
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    
    int numTrees = kbUnitCount(0, cUnitTypeTree, cUnitStateAlive);
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    int myMilUnitsInR75 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 75.0);
    int alliedMilUnitsInR75 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, mainBaseLocation, 75.0, true);
    int enemyMilUnitsInR75 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 75.0, true);
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    int numEnemyTitansInR75 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 75.0, true);
    int numAlliedTitansInR75 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationAlly, mainBaseLocation, 75.0, true);
    aiEcho("numVillagers: "+numVillagers);
    aiEcho("myMilUnitsInR75: "+myMilUnitsInR75);
    aiEcho("alliedMilUnitsInR75: "+alliedMilUnitsInR75);
    aiEcho("enemyMilUnitsInR75: "+enemyMilUnitsInR75);
    
    static int count = 0;
    
//    if ((currentPop > currentPopCap * 0.6) || (myMilUnitsInR75 + alliedMilUnitsInR75 + 3 >= enemyMilUnitsInR75))
    if ((currentPop > currentPopCap * 0.7) && (myMilUnitsInR75 + alliedMilUnitsInR75 + 3 >= enemyMilUnitsInR75)
     && (numEnemyTitansInR75 - numAlliedTitansInR75 - numTitans <= 0))
    {
        if ((currentPop <= currentPopCap - 2) || (foodSupply < 1000) || (goldSupply < 1000) || ((woodSupply < 800) && (numTrees > 14)))
        {
            count = 0;
            return;
        }
        else
        {
            // Check if most military upgrades are researched and we are at pop cap.
            if (cMyCiv == cCivThor)
            {
                if ((kbGetTechStatus(cTechChampionInfantry) < cTechStatusResearching)
                 || (kbGetTechStatus(cTechChampionCavalry) < cTechStatusResearching)
                 || (kbGetTechStatus(cTechMeteoricIronMail) < cTechStatusResearching)
                 || (kbGetTechStatus(cTechDragonscaleShields) < cTechStatusResearching)
                 || (kbGetTechStatus(cTechHammeroftheGods) < cTechStatusResearching))
                {
                    count = 0;
                    return;
                }
            }
            else
            {
                if ((kbGetTechStatus(cTechChampionInfantry) < cTechStatusResearching)
                 || (kbGetTechStatus(cTechChampionCavalry) < cTechStatusResearching)
                 || (kbGetTechStatus(cTechIronMail) < cTechStatusResearching)
                 || (kbGetTechStatus(cTechIronShields) < cTechStatusResearching)
                 || (kbGetTechStatus(cTechIronWeapons) < cTechStatusResearching))
                {
                    count = 0;
                    return;
                }
            }
            count = 3;
        }
    }
    else
    {
        count = count + 1;
    }
    
    if ((numVillagers < 10) || (count <= 2))
    {
        return;
    }
    
    aiPlanSetVariableBool(gRagnorokPlanID, cGodPowerPlanAutoCast, 0, true);
    
    //Finished.
    gRagnorokPlanID = -1;
    xsDisableSelf();
}

//==============================================================================
rule castHeavyGP
    minInterval 11  //starts in cAge4
    inactive
{
    aiEcho("castHeavyGP:");
    //check if we have a gEnemySettlementAttPlanID
    if (gEnemySettlementAttPlanID < 0)
    {
        aiEcho("gEnemySettlementAttPlanID < 0, returning");
        return;
    }
    
    //get the targetPlayerID, the targetID, its unitType, its health and its position
    int targetPlayerID = aiPlanGetVariableInt(gEnemySettlementAttPlanID, cAttackPlanPlayerID, 0);
    aiEcho("targetPlayerID: "+targetPlayerID);
    int targetID = aiPlanGetVariableInt(gEnemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0);
    aiEcho("targetID: "+targetID);
    if (targetID < 0)
    {
        aiEcho("targetID < 0, returning");
        return;
    }
    
    if (kbUnitIsType(targetID, cUnitTypeAbstractSettlement) == false)
    {
        aiEcho("target is no cUnitTypeAbstractSettlement, returning");
        return;
    }
    
    float targetHealth = kbUnitGetHealth(targetID);
    aiEcho("targetHealth: "+targetHealth);
    if (targetHealth < 0.5)
    {
        aiEcho("targetHealth < 0.5, returning");
        return;
    }
    
    vector targetPosition = kbUnitGetPosition(targetID);
    aiEcho("targetPosition: "+targetPosition);
    
    if (kbLocationVisible(targetPosition) == false)
    {
        aiEcho("Target position is not visible, returning");
        return;
    }
    
    //check if the settlement is still being built
    int numSettlementsBeingBuiltAtTargetPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateBuilding, -1, targetPlayerID, targetPosition, 5.0);
    aiEcho("numSettlementsBeingBuiltAtTargetPos: "+numSettlementsBeingBuiltAtTargetPos);
    if (numSettlementsBeingBuiltAtTargetPos > 0)
    {
        aiEcho("the settlement is still being built, returning");
        return;
    }
    
    //count the number of enemy buildings in range
    int numMilBuildingsInR30 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, targetPosition, 30.0);
    aiEcho("numMilBuildingsInR30: "+numMilBuildingsInR30);
   
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    float distanceToMainBase = xsVectorLength(mainBaseLocation - targetPosition);
    aiEcho("distanceToMainBase: "+distanceToMainBase);
    
    if (distanceToMainBase > 110.0)
    {
        if (numMilBuildingsInR30 <= 2)
        {
            aiEcho("there are just a few military buildings, returning");
            return;
        }
   
        //count the units in range
        int myMilUnitsInR40 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, targetPosition, 40.0);
        int alliedMilUnitsInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, targetPosition, 40.0, true);
        int enemyMilUnitsInR30 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, targetPosition, 30.0, true);
        aiEcho("myMilUnitsInR40: "+myMilUnitsInR40);
        aiEcho("alliedMilUnitsInR40: "+alliedMilUnitsInR40);
        aiEcho("enemyMilUnitsInR30: "+enemyMilUnitsInR30);
  
        if (myMilUnitsInR40 + alliedMilUnitsInR40 + 5 <= enemyMilUnitsInR30)
        {
            aiEcho("there are too many enemies, returning");
            return;
        }
        
        //TODO: Maybe also check if we have enough resources?
    }
  
    //cast gHeavyGPTechID
    if (aiCastGodPowerAtPosition(gHeavyGPTechID, targetPosition) == true)
    {
        aiEcho("Casting heavyGP: "+gHeavyGPTechID+" at position: "+targetPosition);
        aiPlanDestroy(gHeavyGPPlanID);
        xsDisableSelf();
    }
    else
    {
        aiEcho("Couldn't cast gHeavyGPTechID: "+gHeavyGPTechID);
    }
}

//==============================================================================
void findTownDefenseGP(int baseID = -1)
{
    if (gTownDefenseGodPowerPlanID != -1)
        return;
        
    gTownDefenseGodPowerPlanID = aiFindBestTownDefenseGodPowerPlan();
    if (gTownDefenseGodPowerPlanID == -1)
        return;

    int mainBaseID = kbBaseGetMainID(cMyID);
    
    //remember the evaluation model and change it.
    gTownDefenseEvalModel = aiPlanGetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0);
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
    //remember the targeting model and change it.
    gTownDefenseTargetingModel = aiPlanGetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanTargetingModel, 0);
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
    //remember the playerID.
    gTownDefensePlayerID = aiPlanGetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryPlayerID, 0);
    //remember the location and change it.
    gTownDefenseLocation = aiPlanGetVariableVector(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryLocation, 0);
    aiPlanSetVariableVector(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryLocation, 0, kbBaseGetLocation(cMyID, baseID));
    //change the distance.
    float distance = 40.0;
    if (baseID == mainBaseID)
        distance = 55.0;
    aiPlanSetVariableFloat(gTownDefenseGodPowerPlanID, cGodPowerPlanDistance, 0, distance);
}

//==============================================================================
void releaseTownDefenseGP()
{
    if (gTownDefenseGodPowerPlanID == -1)
        return;
        
    //Change the evaluation model back.
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0, gTownDefenseEvalModel);
    //Reset the player.
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryPlayerID, 0, gTownDefensePlayerID);
    //Change the targeting model back
    aiPlanSetVariableInt(gTownDefenseGodPowerPlanID, cGodPowerPlanTargetingModel, 0, gTownDefenseTargetingModel);
    //change the location back
    aiPlanSetVariableVector(gTownDefenseGodPowerPlanID, cGodPowerPlanQueryLocation, 0, gTownDefenseLocation);
    //change the distance back
    aiPlanSetVariableFloat(gTownDefenseGodPowerPlanID, cGodPowerPlanDistance, 0, 55.0);
    //Release the plan.
    gTownDefenseGodPowerPlanID = -1;
    gTownDefenseEvalModel = -1; 
    gTownDefensePlayerID = -1;
    gTownDefenseTargetingModel = -1;
    gTownDefenseLocation = cInvalidVector;
}

//==============================================================================
rule rGaiaForestPower
    minInterval 109 //starts in cAge1
    inactive
{
    aiEcho("rGaiaForestPower:");    

    if (gGaiaForestPlanID == -1)
    {
        xsDisableSelf();
        return;
    }
    
    //Don't cast it too early?
    if (xsGetTime() < 3*60*1000)
        return;
    
    static int count = 0;
    bool autoCast = aiPlanGetVariableBool(gGaiaForestPlanID, cGodPowerPlanAutoCast, 0);
    if (autoCast == true)
    {
        //reset to false
        aiPlanSetVariableBool(gGaiaForestPlanID, cGodPowerPlanAutoCast, 0, false);
    }
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numTreesNearMB = getNumUnits(cUnitTypeTree, cUnitStateAlive, -1, 0, mainBaseLocation, 40.0); //50? 60?
    if (numTreesNearMB < 10)
    {
        aiPlanSetVariableBool(gGaiaForestPlanID, cGodPowerPlanAutoCast, 0, true);
        aiEcho("Setting cGodPowerPlanAutoCast to true");
        count = count + 1;
    }
    
    if (count >= 3)
    {
        //Finished.
        gGaiaForestPlanID = -1;
        xsDisableSelf();
    }
}

//==============================================================================
rule rHesperidesPower
    minInterval 109 //starts in cAge3
    inactive
{
    aiEcho("rHesperidesPower:");    

    if (gHesperidesPlanID == -1)
    {
        xsDisableSelf();
        return;
    }
    
    static int count = 0;
    bool autoCast = aiPlanGetVariableBool(gHesperidesPlanID, cGodPowerPlanAutoCast, 0);
    if (autoCast == true)
    {
        //reset to false
        aiPlanSetVariableBool(gHesperidesPlanID, cGodPowerPlanAutoCast, 0, false);
    }
    
    //for now only cast if we don't have one already
    int numHesperides = kbUnitCount(cMyID, cUnitTypeHesperidesTree, cUnitStateAlive);
    if (numHesperides < 1)
    {
        aiPlanSetVariableBool(gHesperidesPlanID, cGodPowerPlanAutoCast, 0, true);
        aiEcho("Setting cGodPowerPlanAutoCast to true");
        count = count + 1;
    }
    
    if (count >= 2)
    {
        //Finished.
        gHesperidesPlanID = -1;
        xsDisableSelf();
    }
}

//==============================================================================
// rule rCitadel, modified Sentinel plan to be exact.
//==============================================================================
rule rCitadel
    minInterval 20 //starts in cAge1
    inactive
{
    if (cMyCiv != cCivSet && cMyCiv != cCivRa) {
        xsDisableSelf();
        return;    
    }
	
    aiEcho("rCitadel:");    

    int planID=fCitadelPlanID;
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
        if (aiCastGodPowerAtUnit(cTechCitadel,kbUnitQueryGetResult(unitQueryID, i)) == true)
        {
            aiPlanSetBaseID(planID, baseID);
            aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
            aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
            aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
            xsDisableSelf();
        }
    }
}