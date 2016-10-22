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
    if (ShowAiEcho == true) aiEcho("findHuntableInfluence:");    
   
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
    if (ShowAiEcho == true) aiEcho("setupGodPowerPlan:");    

    if (planID == -1)
        return (false);
    if (powerProtoID == -1)
        return (false);

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
    aiPlanSetBaseID(planID, mainBaseID);

    //-- setup prosperity
    //-- This sets up the plan to cast itself when there are 16 people working on gold // Upped to 16 by Reth
    if (powerProtoID == cPowerProsperity)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 16);
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

//==============================================================================
// Shifting Sands Power
//==============================================================================
   if (powerProtoID == cPowerShiftingSands)
   {
      gShiftingSandPlanID = planID;
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false);
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
      xsEnableRule("rShiftingSand");
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

    //-- setup the Restoration power
    if (powerProtoID == cPowerRestoration)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
        aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
        aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
        aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        return (true);  
    }

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

    //-- setup the Tornado power
    if (powerProtoID == cPowerTornado)
    {
        gHeavyGPTechID = cTechTornado;
        gHeavyGPPlanID = planID;
        xsEnableRule("castHeavyGP");
        
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
        aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
        aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
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

    //-- setup the rain power to cast when we have at least 14 farms // Upped to 14 by Reth
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
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 14);


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
        aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
        aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
        aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
        return (true);
    }

    // Set up the heroize power
    // Any time we have a group of 8 or more military units
    if (powerProtoID == cPowerHeroize)
    {
        aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false);  
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
      aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
      aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
      aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
	  gHeavyGPTech=cTechTartarianGate;
	  gHeavyGPPlan=planID;
      xsEnableRule("rCastHeavyGP");
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


// Chinese GPS, copy paste from WarriorMario  ////////////

// Set up the Barrage power
	// 20 enemy military units within 30m of attack plan
	if(powerProtoID == cPowerBarrage)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		return (true);
	}
	// Set up the Call to Arms power
	// If we have a group of 10 or more military units. Lets hope there is a mythunit present
	if(powerProtoID == cPowerCallToArms)
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
	// Set up the Earth Dragon power
	// Near enemies?
	if(powerProtoID == cPowerEarthDragon)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
		return (true);
	}
	// Set up the Examination power
	// At least 50 villagers
	if(powerProtoID == cPowerExamination)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 

		 //-- create the query used for evaluation
		queryID = kbUnitQueryCreate("Examination Evaluation");
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
	// Set up the Geyser power
	// Atleast 15 enemies lets hope we can get an army at once
	// And we can place it nearby our army as we cannot be damaged by it (range is 10m)
	if(powerProtoID == cPowerGeyser)
	{ 
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 10.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		return (true);  
	}
	// Set up the Inferno power
	// Atleast 25 enemies
	// Dangerous for us too (range is 50 and not in our base!)
	if(powerProtoID == cPowerInferno)
	{ 
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 25);
		return (true);  
	}
	// Set up the Journey power
	// At least 70 units
	if(powerProtoID == cPowerJourney)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 

		 //-- create the query used for evaluation
		queryID = kbUnitQueryCreate("Journey Evaluation");
		if (queryID < 0)
		   return (false);

		kbUnitQueryResetData(queryID);
		kbUnitQuerySetPlayerID(queryID, cMyID);
		kbUnitQuerySetUnitType(queryID, cUnitTypeLogicalTypeUnitsNotBuildings);
		kbUnitQuerySetState(cUnitStateAlive);

		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 70);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);

		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		return (true);   
	}
	// Set up the Recreation power
	// Or actually destroy the plan and use painful manual casting
	if(powerProtoID == cPowerRecreation)
	{
		aiPlanDestroy(planID);
		xsEnableRule("rRecreation");
		return (false);  
	}
	// Set up the Timber Harvest power
	// We want 10 villagers on wood
	if(powerProtoID == cPowerTimberHarvest)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
		aiPlanSetVariableInt(planID, cGodPowerPlanResourceType, 0, cResourceGold);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		return (true);
	}
	// Set up the Tsunami power
	// Or actually destroy the plan and use painful manual casting
//	if(powerProtoID == cPowerTsunami)
//	{
//		xsEnableRule("rTsunami");
//		return (false);  
//		}
		
	// Set up the Uproot power
	if(powerProtoID == cPowerUproot)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 6);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeBuildingNotTitanGate);
		return (true);  
	}
	// Set up the Year of the Goat power
	// Or actually destroy the plan and use manual casting
	if(powerProtoID == cPowerYearOfTheGoat)
	{
		xsEnableRule("rYearOfTheGoat");
		return (false);  
	}

   return (false);
}
//==============================================================================
void initGodPowers(void)    //initialize the god power module
{
    if (ShowAiEcho == true) aiEcho("GP Init.");
    xsEnableRule("rAge1FindGP");
}

//==============================================================================
rule rAge1FindGP
    minInterval 12 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("rAge1FindGP:");    

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
    if (ShowAiEcho == true) aiEcho("rAge2FindGP:");    

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

    if (ShowAiEcho == true) aiEcho("initializing god power plan for age 2");
    if (cvOkToUseAge2GodPower == true)
        aiPlanSetActive(gAge2GodPowerPlanID);

    xsDisableSelf();
}

//==============================================================================
rule rAge3FindGP
    minInterval 12 //starts in cAge3
    inactive
{
    if (ShowAiEcho == true) aiEcho("rAge3FindGP:");    

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

    if (ShowAiEcho == true) aiEcho("initializing god power plan for age 3");
    if (cvOkToUseAge3GodPower == true)
        aiPlanSetActive(gAge3GodPowerPlanID);

    xsDisableSelf();
}

//==============================================================================
rule rAge4FindGP
    minInterval 12 //starts in cAge4
    inactive
{
    if (ShowAiEcho == true) aiEcho("rAge4FindGP:");    

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

    if (ShowAiEcho == true) aiEcho("initializing god power plan for age 4");
    if (cvOkToUseAge4GodPower == true)
        aiPlanSetActive(gAge4GodPowerPlanID);

    xsDisableSelf();
}

//==============================================================================
rule rCeaseFire
    minInterval 32 //starts in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("rCeaseFire:");    

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
    if (ShowAiEcho == true) aiEcho("rUnbuild:");    

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
    if (ShowAiEcho == true) aiEcho("gpAge2Handler:");    

    xsEnableRule("rAge2FindGP");
}

//==============================================================================
void gpAge3Handler(int age=2)
{
    if (ShowAiEcho == true) aiEcho("gpAge3Handler:");    

    xsEnableRule("rAge3FindGP");  
}

//==============================================================================
void gpAge4Handler(int age=3)
{
    if (ShowAiEcho == true) aiEcho("gpAge4Handler:");    

    xsEnableRule("rAge4FindGP");
}

//==============================================================================
rule rDwarvenMinePower
    minInterval 109 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("rDwarvenMinePower:");

    if (gDwarvenMinePlanID == -1)
    {
        xsDisableSelf();
        return;
    }

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numGoldMinesNearMBInR85 = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, mainBaseLocation, 85.0);
    //Are we in the third age yet? If not cast it only if there are no gold mines in range
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
    if (ShowAiEcho == true) aiEcho("unbuildHandler:");    

    xsEnableRule("rUnbuild");
}

//==============================================================================
rule rPlaceTitanGate
//    minInterval 12 //starts in cAge5
    minInterval 11 //starts in cAge5
    inactive
{
    if (ShowAiEcho == true) aiEcho("rPlaceTitanGate:");    

    //Figure out the age 5 (yes, 5) god power and create the plan.
    int id = aiGetGodPowerTechIDForSlot(4); 
    if (id == -1)
        return;

    gAge5GodPowerID=aiGetGodPowerProtoIDForTechID(id);

    //Create the plan.
    gPlaceTitanGatePlanID = aiPlanCreate("PlaceTitanGate", cPlanGodPower);
    if (gPlaceTitanGatePlanID == -1)
    {
    // TODO: does this work at all?
        if (ShowAiEcho == true) aiEcho("couldn't create plan to place Titan Gate, retrying in 2 minutes");
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
    aiPlanSetVariableFloat(gPlaceTitanGatePlanID, cGodPowerPlanBuildingPlacementDistance, 0, 110.0);

    aiPlanSetActive(gPlaceTitanGatePlanID);

    xsDisableSelf();
}

//==============================================================================
rule rSentinel
    minInterval 15 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("rSentinel:");    

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
    if (ShowAiEcho == true) aiEcho("rRagnorokPower:");    

    if (gRagnorokPlanID == -1)
    {
        xsDisableSelf();
        return;
    }
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    

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
    if (ShowAiEcho == true) aiEcho("numVillagers: "+numVillagers);
    if (ShowAiEcho == true) aiEcho("myMilUnitsInR75: "+myMilUnitsInR75);
    if (ShowAiEcho == true) aiEcho("alliedMilUnitsInR75: "+alliedMilUnitsInR75);
    if (ShowAiEcho == true) aiEcho("enemyMilUnitsInR75: "+enemyMilUnitsInR75);
    
    static int count = 0;
    
    if ((currentPop > currentPopCap * 0.7) && (myMilUnitsInR75 + alliedMilUnitsInR75 + 3 >= enemyMilUnitsInR75)
     && (numEnemyTitansInR75 - numAlliedTitansInR75 - numTitans <= 0))
    {
        if ((currentPop <= currentPopCap - 2) || (foodSupply < 1000) || (goldSupply < 1000) || ((woodSupply < 800)))
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
    minInterval 13  //starts in cAge4
    inactive
{
    if (ShowAiEcho == true) aiEcho("castHeavyGP:");
    //check if we have a gEnemySettlementAttPlanID
    if (gEnemySettlementAttPlanID < 0)
    {
        if (ShowAiEcho == true) aiEcho("gEnemySettlementAttPlanID < 0, returning");
        return;
    }
    
    //get the targetPlayerID, the targetID, its unitType, its health and its position
    int targetPlayerID = aiPlanGetVariableInt(gEnemySettlementAttPlanID, cAttackPlanPlayerID, 0);
    if (ShowAiEcho == true) aiEcho("targetPlayerID: "+targetPlayerID);
    int targetID = aiPlanGetVariableInt(gEnemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0);
    if (ShowAiEcho == true) aiEcho("targetID: "+targetID);
    if (targetID < 0)
    {
        if (ShowAiEcho == true) aiEcho("targetID < 0, returning");
        return;
    }
    
    if (kbUnitIsType(targetID, cUnitTypeAbstractSettlement) == false)
    {
        if (ShowAiEcho == true) aiEcho("target is no cUnitTypeAbstractSettlement, returning");
        return;
    }
    
    float targetHealth = kbUnitGetHealth(targetID);
    if (ShowAiEcho == true) aiEcho("targetHealth: "+targetHealth);
    if (targetHealth < 0.5)
    {
        if (ShowAiEcho == true) aiEcho("targetHealth < 0.5, returning");
        return;
    }
    
    vector targetPosition = kbUnitGetPosition(targetID);
    if (ShowAiEcho == true) aiEcho("targetPosition: "+targetPosition);
    
    if (kbLocationVisible(targetPosition) == false)
    {
        if (ShowAiEcho == true) aiEcho("Target position is not visible, returning");
        return;
    }
    
    //check if the settlement is still being built
    int numSettlementsBeingBuiltAtTargetPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateBuilding, -1, targetPlayerID, targetPosition, 5.0);
    if (ShowAiEcho == true) aiEcho("numSettlementsBeingBuiltAtTargetPos: "+numSettlementsBeingBuiltAtTargetPos);
    if (numSettlementsBeingBuiltAtTargetPos > 0)
    {
        if (ShowAiEcho == true) aiEcho("the settlement is still being built, returning");
        return;
    }
    
    //count the number of enemy buildings in range
    int numMilBuildingsInR30 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, targetPosition, 30.0);
    if (ShowAiEcho == true) aiEcho("numMilBuildingsInR30: "+numMilBuildingsInR30);
   
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    float distanceToMainBase = xsVectorLength(mainBaseLocation - targetPosition);
    if (ShowAiEcho == true) aiEcho("distanceToMainBase: "+distanceToMainBase);
    
    if (distanceToMainBase > 110.0)
    {
        if (numMilBuildingsInR30 <= 2)
        {
            if (ShowAiEcho == true) aiEcho("there are just a few military buildings, returning");
            return;
        }
   
        //count the units in range
        int myMilUnitsInR40 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, targetPosition, 40.0);
        int alliedMilUnitsInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, targetPosition, 40.0, true);
        int enemyMilUnitsInR30 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, targetPosition, 30.0, true);
        if (ShowAiEcho == true) aiEcho("myMilUnitsInR40: "+myMilUnitsInR40);
        if (ShowAiEcho == true) aiEcho("alliedMilUnitsInR40: "+alliedMilUnitsInR40);
        if (ShowAiEcho == true) aiEcho("enemyMilUnitsInR30: "+enemyMilUnitsInR30);
  
        if (myMilUnitsInR40 + alliedMilUnitsInR40 + 5 <= enemyMilUnitsInR30)
        {
            if (ShowAiEcho == true) aiEcho("there are too many enemies, returning");
            return;
        }
        
        //TODO: Maybe also check if we have enough resources?
    }
  
    //cast gHeavyGPTechID
    if (aiCastGodPowerAtPosition(gHeavyGPTechID, targetPosition) == true)
    {
        if (ShowAiEcho == true) aiEcho("Casting heavyGP: "+gHeavyGPTechID+" at position: "+targetPosition);
        aiPlanDestroy(gHeavyGPPlanID);
        xsDisableSelf();
    }
    else
    {
        if (ShowAiEcho == true) aiEcho("Couldn't cast gHeavyGPTechID: "+gHeavyGPTechID);
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
    minInterval 25 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("rGaiaForestPower:");    

    if (gGaiaForestPlanID == -1)
    {
        xsDisableSelf();
        return;
    }
    bool JustCastIt = false;
    //Don't cast it too early?
    if (xsGetTime() < 1*20*1000)
        return;
		    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int NumTreesMB = getNumUnits(cUnitTypeGaiaForesttree, cUnitStateAlive, -1, 0, mainBaseLocation, 30.0);
	if (NumTreesMB < 3)
	JustCastIt = true;
    static int count = 0;
    bool autoCast = aiPlanGetVariableBool(gGaiaForestPlanID, cGodPowerPlanAutoCast, 0);
    if (autoCast == true)
    {
        //reset to false
        aiPlanSetVariableBool(gGaiaForestPlanID, cGodPowerPlanAutoCast, 0, false);
    }
    
    
    if (JustCastIt == true)
    {
        aiPlanSetVariableBool(gGaiaForestPlanID, cGodPowerPlanAutoCast, 0, true);
        if (ShowAiEcho == true) aiEcho("Setting cGodPowerPlanAutoCast to true");
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
    if (ShowAiEcho == true) aiEcho("rHesperidesPower:");    

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
        if (ShowAiEcho == true) aiEcho("Setting cGodPowerPlanAutoCast to true");
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
	
    if (ShowAiEcho == true) aiEcho("rCitadel:");    

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

//==============================================================================
// Shifting Sand Rule & Plan
//==============================================================================
rule rShiftingSand
   minInterval 25
   inactive
{
   static int queryID = -1;

   int planID = gShiftingSandPlanID;


   //-- create the query used for evaluation
   if (queryID < 0)
	  queryID=kbUnitQueryCreate("Shifting Sands Evaluation");

   if (queryID != -1)
   {
		kbUnitQuerySetPlayerRelation(queryID, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
		kbUnitQuerySetSeeableOnly(queryID, true);
		kbUnitQuerySetAscendingSort(queryID, true);
		kbUnitQuerySetMaximumDistance(queryID, 12);
        kbUnitQuerySetState(cUnitStateAlive);
   }

   kbUnitQueryResetResults(queryID);
   int numberFound=kbUnitQueryExecute(queryID);

   if (numberFound < 3)
	return;

   aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
     
   aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
   aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cPlayerRelationEnemy);

   aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, kbUnitGetPosition(kbUnitQueryGetResult(queryID, 0)));
   aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 1, kbBaseGetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID)));

   aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
   aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);

   aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelDualLocation);
   
}

// Chinese rules, copy paste from WarriorMario //////////


//==============================================================================
// canAffordSpeedUpConstruction(int queryID, int index)
// Function to check whether we can afford a speed up
//==============================================================================
bool canAffordSpeedUpConstruction(int queryID = -1, int index = -1, int escrowID = -1)
{
	int gold  = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceGold );
	int wood  = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceWood );
	int food  = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceFood );
	int favor = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceFavor);
	if(kbEscrowGetAmount(escrowID, cResourceGold)<gold)
	{
		return(false);
	}
	if(kbEscrowGetAmount(escrowID, cResourceWood)<wood)
	{
		return(false);
	}
	if(kbEscrowGetAmount(escrowID, cResourceFood)<food)
	{
		return(false);
	}
	if(kbEscrowGetAmount(escrowID, cResourceFavor)<favor)
	{
		return(false);
	}
	return(true);
}
	
//==============================================================================
// rSpeedUpBuilding
// There are some times we want to speed up when possible:
// - economic buildings so we can get an edge over the other players as long as
// it doesn't mess up our age times.
// - military buildings in classical and higher
// Script is somewhat weird atm as the functions require queryID and indices
// We might want to add randomness as now every building is sped up ^^
//==============================================================================
rule rSpeedUpBuilding
minInterval 10
inactive
{
	// Set up a query
	static int queryID = -1;
	if(queryID ==-1)
	{
		queryID = kbUnitQueryCreate("Unit_ID_Query");
	}
	// Look for constructions
	kbUnitQuerySetPlayerID(queryID, cMyID);
	kbUnitQuerySetUnitType(queryID, cUnitTypeBuilding);
	kbUnitQuerySetState(queryID, cUnitStateBuilding);
	int numConstructions = kbUnitQueryExecute(queryID);
	for(i =0; < numConstructions)
	{
		int buildingID = kbUnitQueryGetResult(queryID,i);
		if(kbBuildingCanSpeedUpConstruction(queryID, i))
		{
			// Things we should speed up
			if(kbUnitIsType(buildingID,cUnitTypeEconomicBuilding))
			{
				if(canAffordSpeedUpConstruction(queryID,0,cEconomyEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cEconomyEscrowID);
				}
			}
			else if(kbUnitIsType(buildingID,cUnitTypeAbstractTemple))
			{
				if(canAffordSpeedUpConstruction(queryID,0,cEconomyEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cEconomyEscrowID);
				}
			}
			else if(kbUnitIsType(buildingID,cUnitTypeDropsite))
			{
				if(canAffordSpeedUpConstruction(queryID,0,cEconomyEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cEconomyEscrowID);
				}
			}
			else if(kbUnitIsType(buildingID,cUnitTypeAbstractDock))
			{
				if(canAffordSpeedUpConstruction(queryID,0,cEconomyEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cEconomyEscrowID);
				}
			}
			else if(kbUnitIsType(buildingID,cUnitTypeBuilding)&&kbGetAge()>cAge1)
			{
				if(canAffordSpeedUpConstruction(queryID,0,cMilitaryEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cMilitaryEscrowID);
				}
			}
		}
	}
}

//==============================================================================
// rRecreation
// There are some times we want to cast recreation:
// - 1 dead villager in archaic -> rule interval is very low, every second counts
// - 2 dead villagers in classical
// - 3 dead villagers in heroic and later
// - No enemy army nearby otherwise they get killed, resurrected and killed again
//==============================================================================
rule rRecreation
minInterval 15
inactive
{
	static int deadQuery = -1;
	static int deadNearbyQuery = -1;
	static int enemyQuery = -1;
	float enemyRange = 20.0;
	int numRequired  = 1;// Early we want every villager to be alive
	if(kbGetAge()==cAge2)
	{
		xsSetRuleMinIntervalSelf(10);// Less important
		numRequired = 2;
	}
	if(kbGetAge()>cAge2)
	{
		xsSetRuleMinIntervalSelf(10);
		numRequired = 3;
	}
	// Set up queries
	if(deadQuery == -1)
	{
		deadQuery = kbUnitQueryCreate("Dead Villager Query");
		kbUnitQuerySetPlayerID(deadQuery, cMyID);
		kbUnitQuerySetUnitType(deadQuery, cUnitTypeVillagerChineseDeadReplacement);
		kbUnitQuerySetState(deadQuery, cUnitStateAny);
	}
	kbUnitQueryResetResults(deadQuery);
	if(deadNearbyQuery == -1)
	{
		deadNearbyQuery = kbUnitQueryCreate("Dead Nearby Villager Query");
		kbUnitQuerySetPlayerID(deadNearbyQuery, cMyID);
		kbUnitQuerySetUnitType(deadNearbyQuery, cUnitTypeVillagerChineseDeadReplacement);
		kbUnitQuerySetState(deadNearbyQuery, cUnitStateAny);
	}
	int numDead = kbUnitQueryExecute(deadQuery);
	if(enemyQuery == -1)
	{
		enemyQuery = kbUnitQueryCreate("Enemy Army Query");
		kbUnitQuerySetPlayerID(enemyQuery, cMyID);
		kbUnitQuerySetPlayerRelation(enemyQuery, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQuery, cUnitTypeMilitary);
		kbUnitQuerySetState(enemyQuery, cUnitStateAlive);
	}
	// Loop through all the dead villagers we found
	for(i=0;<numDead)
	{
		vector position = kbUnitGetPosition(kbUnitQueryGetResult(deadQuery,i));
		kbUnitQueryResetResults(enemyQuery);
		kbUnitQuerySetPosition(enemyQuery,position);
		kbUnitQuerySetMaximumDistance(enemyQuery,enemyRange);
		// Check for enemies
		if(kbUnitQueryExecute(enemyQuery)==0)
		{
			// We want atleast 2 dead villagers
			kbUnitQueryResetResults(deadNearbyQuery);
			kbUnitQuerySetPosition(deadNearbyQuery,position);
			kbUnitQuerySetMaximumDistance(deadNearbyQuery,10);// GP range
			if(kbUnitQueryExecute(deadNearbyQuery)>1)
			{
				// 2 villagers to be revived lets go!
				if(aiCastGodPowerAtPosition(cTechRecreation,position))
				{
					// Did we make it? Kill the rule if so
					xsDisableSelf();
				}
			}
		}
	}
}

//==============================================================================
// rTsunami
// When to cast Tsunami:
// - Enemy town
// - Enough enemy buildings and units
// Then we want to know how to cast Tsunami:
// - In the direction of the houses
// This is gonna be ugly
//==============================================================================
rule rTsunami
minInterval 25
inactive
{
	static int enemyTownQuery = -1;
	static int enemyUnitsQuery = -1;
	static int directionQuery = -1;
	float townRange = 25;
	int numReqUnits = 25;
	if(enemyTownQuery == -1)
	{
		enemyTownQuery = kbUnitQueryCreate("Enemy Town Query");
		kbUnitQuerySetPlayerID(enemyTownQuery, cMyID);
		kbUnitQuerySetPlayerRelation(enemyTownQuery, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyTownQuery, cUnitTypeAbstractSettlement);
		kbUnitQuerySetState(enemyTownQuery, cUnitStateAlive);
	}
	if(enemyUnitsQuery == -1)
	{
		enemyUnitsQuery = kbUnitQueryCreate("Enemy Units Query");
		kbUnitQuerySetPlayerID(enemyUnitsQuery, cMyID);
		kbUnitQuerySetPlayerRelation(enemyUnitsQuery, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyUnitsQuery, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings);
		kbUnitQuerySetState(enemyUnitsQuery, cUnitStateAliveOrBuilding);
	}
	if(directionQuery == -1)
	{
		directionQuery = kbUnitQueryCreate("Enemy Tower Query");
		kbUnitQuerySetPlayerID(directionQuery, cMyID);
		kbUnitQuerySetPlayerRelation(directionQuery, cPlayerRelationEnemy);
		kbUnitQuerySetState(directionQuery, cUnitStateAlive);
	}
	int numTowns = kbUnitQueryExecute(enemyTownQuery);
	for(i=0;< numTowns)
	{
		vector position = kbUnitGetPosition(kbUnitQueryGetResult(enemyTownQuery,i));
		kbUnitQueryResetResults(enemyUnitsQuery);
		kbUnitQuerySetPosition(enemyUnitsQuery, position);
		kbUnitQuerySetMaximumDistance(enemyUnitsQuery,townRange);
		if(kbUnitQueryExecute(enemyUnitsQuery)>=numReqUnits)
		{
			// Valid town
			// Now get a good direction... I guess players and AI all love towers so lets try and nuke those
			kbUnitQueryResetResults(directionQuery);
			kbUnitQuerySetUnitType(directionQuery, cUnitTypeTower);
			kbUnitQuerySetPosition(directionQuery, position);
			kbUnitQuerySetMaximumDistance(directionQuery,townRange);
			int numBuildings = kbUnitQueryExecute(directionQuery);
			if(numBuildings==0)// Try other military buildings :/
			{
				kbUnitQueryResetResults(directionQuery);
				kbUnitQuerySetUnitType(directionQuery, cUnitTypeMilitaryBuilding);
				numBuildings = kbUnitQueryExecute(directionQuery);
			}
			if(numBuildings==0)// Still nothing
			{
				// This should never happen as we already checked for this but maybe in the nanosecond all the buildings died...
				continue;// Better luck next town
			}
			// Okay now the shit that is super easy but is always done in the wrong order... Even by the devs so we have to fix that too
			// aiCastGodPowerAtPositionFacingPosition() basically faces in the opposite direction because the dev rushed it.
			vector startPosition = kbUnitGetPosition(kbUnitQueryGetResult(directionQuery,0));
			// So uhm get the distance between the start and end position do that 2x and subtract it from the realfinalposition
			vector finalPosition = position - (position-startPosition)*2;
			if(aiCastGodPowerAtPositionFacingPosition(cTechTsunami,startPosition,finalPosition))
			{
			
			}
			
		}
	}
	
}
//==============================================================================
rule rYearOfTheGoat
minInterval 15
inactive
{
	vector position = kbGetTownLocation()+ vector(2,2,2);// Little bit off the town position
	// Cast in archaic because we're rushing
	if(cvRushBoomSlider>0.5)
	{
		aiCastGodPowerAtPosition(cTechYearoftheGoat,position);
	}
	else if(cvRushBoomSlider>0.0&&kbGetAge()>cAge1)
	{
		aiCastGodPowerAtPosition(cTechYearoftheGoat,position);
	}
	else if(kbGetAge()>cAge2)
	{
		aiCastGodPowerAtPosition(cTechYearoftheGoat,position);
	}
	
}

//==============================================================================
// RULE rCastHeavyGP -- TARTARIAN
//==============================================================================
rule rCastHeavyGP
   minInterval 8
	inactive
{
   static int settleQuery=-1;
	static int fortressQuery=-1;
	static int farmQuery=-1;
	static int CastAttempt=0;
    int TartGate = kbUnitCount(cMyID, cUnitTypeTartarianGate, cUnitStateAlive);
	if (TartGate > 1)
	{
	xsDisableSelf();
	return;
	}
	
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
   			  CastAttempt = CastAttempt+1;
			  if (CastAttempt > 5)
			  xsDisableSelf();
   			  return;
   			}
			}
		}
	}
}