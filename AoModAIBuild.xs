//AoModAIBuild.xs
//This file contains all build rules
//by Loki_GdD


//==============================================================================
rule norseInfantryBuild
    minInterval 6 //starts in cAge2
    inactive
{
    aiEcho("norseInfantryBuild:");
    
    int count=-1;
    static int unitQueryID=-1;
    static int buildingQueryID=-1;

    //If we don't have the query yet, create one.
    if (unitQueryID < 0)
    unitQueryID=kbUnitQueryCreate("Idle Infantry Query");
   
    //Define a query to get all matching units
    if (unitQueryID != -1)
    {
        kbUnitQuerySetPlayerID(unitQueryID, cMyID);
        kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
        kbUnitQuerySetActionType(unitQueryID, cActionIdle);
    }

    //If we don't have the query yet, create one.
    if (buildingQueryID < 0)
        buildingQueryID=kbUnitQueryCreate("Under Construction Query");
   
    //Define a query to get all matching units
    if (buildingQueryID != -1)
    {
        kbUnitQuerySetPlayerID(buildingQueryID, cMyID);
        kbUnitQuerySetState(buildingQueryID, cUnitStateBuilding);
    }

    int planIDToAddUnit=aiPlanGetIDByTypeAndVariableType(cPlanBuild, -1, -1);

    if (planIDToAddUnit < 0)
        return;

    kbUnitQueryResetResults(unitQueryID);
    kbUnitQuerySetUnitType(unitQueryID, cUnitTypeAbstractInfantry);
    int numberFound=kbUnitQueryExecute(unitQueryID);
    
    //keep at least one unit in the plan
    if (numberFound < 1)
        numberFound = 1;
    
    //don't put in too many infantry units
    if (numberFound > 5)
        numberFound = 5;

    aiPlanAddUnitType(planIDToAddUnit, cUnitTypeAbstractInfantry, numberFound, numberFound, numberFound);
 
    kbUnitQueryResetResults(unitQueryID);
//    kbUnitQuerySetUnitType(unitQueryID, cUnitTypeHeroNorse);
    kbUnitQuerySetUnitType(unitQueryID, cUnitTypeHero);
    numberFound=kbUnitQueryExecute(unitQueryID);
    
    //don't put in too many heroes
    if (numberFound > 3)
        numberFound = 3;

//    aiPlanAddUnitType(planIDToAddUnit, cUnitTypeHeroNorse, numberFound, numberFound, numberFound);
    aiPlanAddUnitType(planIDToAddUnit, cUnitTypeHero, numberFound, numberFound, numberFound);
}

//==============================================================================
rule repairTitanGate
//    minInterval 10 //starts in cAge5
    minInterval 35 //starts in cAge5
    inactive
{
    aiEcho("repairTitanGate:");
    
    int buildingID = -1;

    // Find the Titan Gate..
    static int tgQueryID=-1;
    //If we don't have a query ID, create it.
    if (tgQueryID < 0)
    {
        tgQueryID=kbUnitQueryCreate("TitanGateQuery");
        //If we still don't have one, bail.
        if (tgQueryID < 0)
        {
            xsDisableSelf();
            return;
        }
        //Else, setup the query data.
        kbUnitQuerySetPlayerID(tgQueryID, cMyID);
        kbUnitQuerySetUnitType(tgQueryID, cUnitTypeTitanGate);
        kbUnitQuerySetState(tgQueryID, cUnitStateBuilding);
    }

    int numBuilders = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);      // Used to set fractions we use for the titan gate
    if (cMyCulture == cCultureNorse)
        numBuilders = kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive);       // Get all inf, not just ulfsarks

    //Reset the results.
    kbUnitQueryResetResults(tgQueryID);
    //Run the query.  
    if (kbUnitQueryExecute(tgQueryID) > 0)
        buildingID = kbUnitQueryGetResult(tgQueryID, 0);

    if (buildingID >= 0)
    {
        //Don't create another plan for the same building.
        if (aiPlanGetIDByTypeAndVariableType(cPlanRepair, cRepairPlanTargetID, buildingID, true) >= 0)
        {
            xsDisableSelf();
            return;
        }

        //Create the plan.
        int planID=aiPlanCreate("BuildTitanGate", cPlanRepair);
        if (planID < 0)
        {
            xsDisableSelf();
            return;
        }

        aiPlanSetDesiredPriority(planID, 100);
        aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
        aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingID);
        aiPlanSetInitialPosition(planID, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
        if (cMyCulture != cCultureNorse)
//            aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, numBuilders/3, numBuilders/2, (numBuilders*2)/3);
            aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, numBuilders * 0.1, numBuilders * 0.25, numBuilders * 0.4);
        else
//            aiPlanAddUnitType(planID, cUnitTypeAbstractInfantry, numBuilders/3, numBuilders/2, (numBuilders*2)/3);
            aiPlanAddUnitType(planID, cUnitTypeAbstractInfantry, numBuilders * 0.1, numBuilders * 0.25, numBuilders * 0.4);
        aiPlanSetVariableBool(planID, cRepairPlanIsTitanGate, 0, true);
        aiPlanSetActive(planID);
//new test
        xsEnableRule("tacticalTitan");
        aiEcho("enabling tacticalTitan rule");

//new test end
        xsDisableSelf();
    }
    else
        aiEcho("       ======< No Gates found.  No AI plan launched.>=======");
}

//==============================================================================
rule repairBuildings1
    minInterval 487 //starts in cAge1, is set to 13 after 8 minutes
    inactive
{
    aiEcho("repairBuildings1: ");
        
    static bool update = false;
    if (update == false)
    {
        xsSetRuleMinIntervalSelf(13);
        update = true;
    }
    
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
    }
    
    int buildingThatShoots1ID = -1;
    int buildingThatShoots2ID = -1;
    
    int activeRepairPlans = aiPlanGetNumber(cPlanRepair, -1, true);
    if (activeRepairPlans > 0)
    {
        for (i = 0; < activeRepairPlans)
        {
            int repairPlanIndexID = aiPlanGetIDByIndex(cPlanRepair, -1, true, i);
            int targetID = aiPlanGetVariableInt(repairPlanIndexID, cRepairPlanTargetID, 0);
            if ((aiPlanGetVariableBool(repairPlanIndexID, cRepairPlanIsTitanGate, 0) == true) && (kbUnitIsType(targetID, cUnitTypeLogicalTypeBuildingNotTitanGate) == true))
            {
                vector targetLocation = kbUnitGetPosition(targetID);
                int myMilUnitsInR25 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, targetLocation, 25.0);
                int numAttEnemyMilUnitsInR25 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, targetLocation, 25.0, true);
                int numEnemyMilBuildingsInR25 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, targetLocation, 25.0);
                if ((kbUnitGetCurrentHitpoints(targetID) <= 0) || (kbUnitGetHealth(targetID) > 0.99) || (numEnemyMilBuildingsInR25 > 0) || (numAttEnemyMilUnitsInR25 > myMilUnitsInR25 + 4) || (goldSupply < 80))
                {
                    aiPlanDestroy(repairPlanIndexID);
                    continue;
                }
            }
            
            if ((kbUnitIsType(targetID, cUnitTypeBuildingsThatShoot) == true) && (aiPlanGetBaseID(repairPlanIndexID) == otherBaseID))
            {
                if (buildingThatShoots1ID == -1)
                {
                    buildingThatShoots1ID = targetID;
                    continue;
                }
                else if (buildingThatShoots2ID == -1)
                {
                    buildingThatShoots2ID = targetID;
                    continue;
                }
            }
        }
    }
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    int numBuilders = kbUnitCount(cMyID, builderType, cUnitStateAlive);
    int requiredBuilders = 10;
    if (cMyCulture == cCultureAtlantean)
        requiredBuilders = 4;
    
    if ((goldSupply < 110) || (woodSupply < 80) || (foodSupply < 80) || (numBuilders < requiredBuilders))
        return;
    
    int mainBaseID = kbBaseGetMainID(cMyID);

    int buildingID = -1;
    vector otherBaseLocation = kbBaseGetLocation(cMyID, otherBaseID);
    float radius = 30.0;
    if (otherBaseID == mainBaseID)
    {
        if ((xsGetTime() > 20*60*1000) || (kbGetAge() > cAge2))
            radius = 85.0;
        else
            radius = 60.0;
    }
    
    int numBuildingsThatShoot = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, otherBaseLocation, radius);
    for (i = 0; < numBuildingsThatShoot)
    {
        buildingID = findUnitByIndex(cUnitTypeBuildingsThatShoot, i, cUnitStateAlive, -1, cMyID, otherBaseLocation, radius);
        if (buildingID == -1)
            continue;
        if (kbUnitGetHealth(buildingID) < 0.8)
        {
            if ((buildingThatShoots1ID == buildingID) || (buildingThatShoots2ID == buildingID))
            {
                buildingID = -1;
                continue;
            }
            break;
        }
        else
            buildingID = -1;
    }
    
    if (buildingID < 0)
        buildingID = kbFindBestBuildingToRepair(otherBaseLocation, radius, 0.85, cUnitTypeMilitaryBuilding);
            
    
    if (buildingID >= 0)
    {
        //Don't create another plan for the same building.
        int repairPlanID = aiPlanGetIDByTypeAndVariableType(cPlanRepair, cRepairPlanTargetID, buildingID, true);		
        if (repairPlanID >= 0)
        {
            return;
        }
        
      
        //Create the plan.
        static int num = 0;
        num = num + 1;
        string planName = "Repair1_"+num;
        int planID = aiPlanCreate(planName, cPlanRepair);
        if (planID < 0)
            return;

        aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingID);
        aiPlanSetInitialPosition(planID, otherBaseLocation);
        
        if (kbUnitIsType(buildingID, cUnitTypeBuildingsThatShoot) == true)
            aiPlanSetVariableBool(planID, cRepairPlanIsTitanGate, 0, true);   //makes sure that the plan doesn't get destroyed
        
        if ((cMyCulture == cCultureAtlantean) || (numBuilders < 30))
            aiPlanAddUnitType(planID, builderType, 1, 1, 1);
        else
        {
            if ((kbUnitIsType(buildingID, cUnitTypeAbstractFortress) == true) || (kbUnitIsType(buildingID, cUnitTypeAbstractSettlement) == true))
            {
                aiPlanAddUnitType(planID, builderType, 1, 2, 3);
            }
            else
                aiPlanAddUnitType(planID, builderType, 1, 1, 1);
        }

        aiPlanSetDesiredPriority(planID, 100);
        aiPlanSetBaseID(planID, otherBaseID);
        aiPlanSetActive(planID);
    }
}

//==============================================================================
rule repairBuildings2
    minInterval 491 //starts in cAge1, is set to 23 after 8 minutes
    inactive
{
    aiEcho("repairBuildings2: ");
        
    static bool update = false;
    if (update == false)
    {
        xsSetRuleMinIntervalSelf(23);
        update = true;
    }
    
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
    }
    
    int buildingThatShoots1ID = -1;
    int buildingThatShoots2ID = -1;
        
    int activeRepairPlans = aiPlanGetNumber(cPlanRepair, -1, true);
    if (activeRepairPlans > 0)
    {
        for (i = 0; < activeRepairPlans)
        {
            int repairPlanIndexID = aiPlanGetIDByIndex(cPlanRepair, -1, true, i);
            int targetID = aiPlanGetVariableInt(repairPlanIndexID, cRepairPlanTargetID, 0);
            if ((aiPlanGetVariableBool(repairPlanIndexID, cRepairPlanIsTitanGate, 0) == true) && (kbUnitIsType(targetID, cUnitTypeLogicalTypeBuildingNotTitanGate) == true))
            {
                vector targetLocation = kbUnitGetPosition(targetID);
                int myMilUnitsInR25 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, targetLocation, 25.0);
                int numAttEnemyMilUnitsInR25 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, targetLocation, 25.0, true);
                int numEnemyMilBuildingsInR25 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, targetLocation, 25.0);
                if ((kbUnitGetCurrentHitpoints(targetID) <= 0) || (kbUnitGetHealth(targetID) > 0.99) || (numEnemyMilBuildingsInR25 > 0) || (numAttEnemyMilUnitsInR25 > myMilUnitsInR25 + 4) || (goldSupply < 80))
                {
                    aiPlanDestroy(repairPlanIndexID);
                    continue;
                }
            }
                
            if ((kbUnitIsType(targetID, cUnitTypeBuildingsThatShoot) == true) && (aiPlanGetBaseID(repairPlanIndexID) == otherBaseID))
            {
                if (buildingThatShoots1ID == -1)
                {
                    buildingThatShoots1ID = targetID;
                    continue;
                }
                else if (buildingThatShoots2ID == -1)
                {
                    buildingThatShoots2ID = targetID;
                    continue;
                }
            }
        }
    }
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    int numBuilders = kbUnitCount(cMyID, builderType, cUnitStateAlive);
//    int requiredBuilders = 12;
    int requiredBuilders = 16;
    if (cMyCulture == cCultureAtlantean)
//        requiredBuilders = 4;
        requiredBuilders = 6;
    
    if ((goldSupply < 110) || (woodSupply < 80) || (foodSupply < 80) || (numBuilders < requiredBuilders))
        return;
    
    int mainBaseID = kbBaseGetMainID(cMyID);

    int buildingID = -1;
    vector otherBaseLocation = kbBaseGetLocation(cMyID, otherBaseID);
    float radius = 30.0;
    if (otherBaseID == mainBaseID)
    {
        if ((xsGetTime() > 20*60*1000) || (kbGetAge() > cAge2))
            radius = 85.0;
        else
            radius = 60.0;
    }
    
    int numBuildingsThatShoot = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, otherBaseLocation, radius);
    for (i = 0; < numBuildingsThatShoot)
    {
        buildingID = findUnitByIndex(cUnitTypeBuildingsThatShoot, i, cUnitStateAlive, -1, cMyID, otherBaseLocation, radius);
        if (buildingID == -1)
            continue;
        if (kbUnitGetHealth(buildingID) < 0.8)
        {
            if ((buildingThatShoots1ID == buildingID) || (buildingThatShoots2ID == buildingID))
            {
                buildingID = -1;
                continue;
            }
            break;
        }
        else
            buildingID = -1;
    }
    
    if (buildingID < 0)
        buildingID = kbFindBestBuildingToRepair(otherBaseLocation, radius, 0.85, cUnitTypeMilitaryBuilding);

    
    if (buildingID >= 0)
    {
        //Don't create another plan for the same building.
        int repairPlanID = aiPlanGetIDByTypeAndVariableType(cPlanRepair, cRepairPlanTargetID, buildingID, true);		
        if (repairPlanID >= 0)
        {
            return;
        }


        //Create the plan.
        static int num = 0;
        num = num + 1;
        string planName = "Repair2_"+num;
        int planID = aiPlanCreate(planName, cPlanRepair);
        if (planID < 0)
            return;

        aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingID);
        aiPlanSetInitialPosition(planID, otherBaseLocation);

        if (kbUnitIsType(buildingID, cUnitTypeBuildingsThatShoot) == true)
            aiPlanSetVariableBool(planID, cRepairPlanIsTitanGate, 0, true);   //makes sure that the plan doesn't get destroyed
        
        if ((cMyCulture == cCultureAtlantean) || (numBuilders < 30))
            aiPlanAddUnitType(planID, builderType, 1, 1, 1);
        else
        {
            if ((kbUnitIsType(buildingID, cUnitTypeAbstractFortress) == true) || (kbUnitIsType(buildingID, cUnitTypeAbstractSettlement) == true))
            {
                aiPlanAddUnitType(planID, builderType, 1, 2,3);
            }
            else
                aiPlanAddUnitType(planID, builderType, 1, 1, 1);
        }
        
        aiPlanSetDesiredPriority(planID, 100);
        aiPlanSetBaseID(planID, otherBaseID);
        aiPlanSetActive(planID);
    }
}

//==============================================================================
rule buildMonuments
    minInterval 117 //starts in cAge2, cAge3, cAge4
    inactive
{
    aiEcho("buildMonuments:");

    static int lastQty = 0;

    int targetNum = -1;
    float scratch = 0.0;
    scratch = (-1.0 * cvRushBoomSlider) + 1.0;  //  0 for extreme rush, 2 for extreme boom
    scratch = (scratch * 1.5) + 0.5;      // 0.5 to 3.5
    targetNum = kbGetAge() + scratch;              // 0 for extreme rush, 3 for extreme boom, +1 in cAge2, 2 in cAge3, +3 in cAge4
    if ( kbGetAge() == cAge4 )
        targetNum = 5;
    if ( targetNum > 5 )
        targetNum = 5;

    if (cMyCiv == cCivIsis)
    {
        for (i=0;<targetNum)
        {
            vector loc=calcMonumentPos(i);

            int unitTypeID=-1;
            if (i==0)
                unitTypeID=cUnitTypeMonument;
            else if (i==1)
                unitTypeID=cUnitTypeMonument2;
            else if (i==2)
                unitTypeID=cUnitTypeMonument3;
            else if (i==3)
                unitTypeID=cUnitTypeMonument4;
            else if (i==4)
                unitTypeID=cUnitTypeMonument5;

            if ((kbUnitCount(cMyID, unitTypeID, cUnitStateAliveOrBuilding) > 0) || (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, unitTypeID, true) >= 0))
                continue;

            int monumentPlanID=aiPlanCreate("IsisBuildMonument"+i, cPlanBuild);
            if (monumentPlanID >= 0)
            {
                aiPlanSetVariableInt(monumentPlanID, cBuildPlanBuildingTypeID, 0, unitTypeID);
   
                aiPlanSetVariableVector(monumentPlanID, cBuildPlanInfluencePosition, 0, loc);
                aiPlanSetVariableFloat(monumentPlanID, cBuildPlanInfluencePositionDistance, 0, 20.0);
                aiPlanSetVariableFloat(monumentPlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
                aiPlanSetVariableInt(monumentPlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(loc));
                aiPlanSetVariableInt(monumentPlanID, cBuildPlanNumAreaBorderLayers, 0, 2);

                aiPlanSetDesiredPriority(monumentPlanID, 35);
                aiPlanAddUnitType(monumentPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
                aiPlanSetEscrowID(monumentPlanID, cEconomyEscrowID);
                aiPlanSetBaseID(monumentPlanID, kbBaseGetMainID(cMyID));
                aiPlanSetActive(monumentPlanID);
            }
        }
    }
    else
    {
        //Create the plan to build the monuments.
        int pid=aiPlanCreate("Monuments "+kbGetAge(), cPlanProgression);
        if (pid >= 0)
        { 
            aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalUnitID, targetNum, true);
            if (lastQty <= 0)
                aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 0, cUnitTypeMonument);
            if ( (targetNum > 1) && (lastQty <= 4) )
                aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 1, cUnitTypeMonument2);
            if ( (targetNum > 2) && (lastQty <= 4) )
                aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 2, cUnitTypeMonument3);
            if ( (targetNum > 3) && (lastQty <= 4) )
                aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 3, cUnitTypeMonument4);
            if ( (targetNum > 4) && (lastQty <= 4) )
                aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 4, cUnitTypeMonument5);
            aiPlanSetVariableBool(pid, cProgressionPlanRunInParallel, 0, false);
            aiPlanSetDesiredPriority(pid, 35);
            aiPlanSetEscrowID(pid, cEconomyEscrowID);
            aiPlanSetBaseID(pid, kbBaseGetMainID(cMyID));
            aiPlanSetActive(pid);

            lastQty = targetNum;
        }
    }

    //Go away now.
    xsDisableSelf();
}

//==============================================================================
rule buildHouse
    minInterval 11 //starts in cAge1
    inactive
{
    aiEcho("buildHouse:");
    
    static int unitQueryID=-1;

    int houseProtoID = cUnitTypeHouse;
    if (cMyCulture == cCultureAtlantean)
        houseProtoID = cUnitTypeManor;

    //Don't build another house if we've got at least gHouseAvailablePopRebuild open pop slots.
    if (kbGetPop()+gHouseAvailablePopRebuild < kbGetPopCap())
        return;

   
    //If we already have gHouseBuildLimit houses, we shouldn't build anymore.
    if (gHouseBuildLimit != -1)
    {
        int numHouses = kbUnitCount(cMyID, houseProtoID, cUnitStateAliveOrBuilding);
        if (numHouses >= gHouseBuildLimit)
            return;
    }

    //If we already have a house plan active, skip unless the house takes too long to build.
    static int count = 0;
    int housePlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, houseProtoID);
    if (housePlanID > -1)
    {
        int houseID = findUnit(houseProtoID, cUnitStateBuilding, -1, cMyID);
        if (houseID != -1)
        {
            if (kbUnitGetHealth(houseID) < 1.0)
            {
                if (count > 3)
                {
                    aiPlanDestroy(housePlanID);
                    aiTaskUnitDelete(houseID);
                    aiEcho("destroying house with ID: "+houseID);
                    count = 0; 
                }
                else
                {
                    count = count + 1;
                    return;
                }
            }
        }
        else
        {
            count = 0;
            return;
        }
    }
    else
    {
        count = 0;
    }

    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID=kbUnitGetBaseID(otherBaseUnitID);
    }
    
    vector location = cInvalidVector;
    int planID = aiPlanCreate("BuildHouse", cPlanBuild);
    if (planID >= 0)
    {
        aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, houseProtoID);

        int builderTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0);
        if (cMyCulture == cCultureNorse)
            builderTypeID = cUnitTypeAbstractInfantry;   // Exact match for land scout, so build plan can steal scout

//        aiPlanAddUnitType(planID, builderTypeID, gBuildersPerHouse, gBuildersPerHouse, gBuildersPerHouse);
        aiPlanAddUnitType(planID, builderTypeID, 1, 1, 1);

        // Hack to test norse scout-building if only one ulfsark exists
        if ((cMyCulture == cCultureNorse) && (kbUnitCount(cMyID, cUnitTypeUlfsark, cUnitStateAlive) == 1) 
         && (equal(aiPlanGetLocation(gLandExplorePlanID), cInvalidVector) == false))
        {
            aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
            aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);

            location = aiPlanGetLocation(gLandExplorePlanID);
            aiPlanSetBaseID(planID, -1);
            aiPlanSetVariableInt(planID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(location));

            aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 20.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 1.0);
        }
       
	   // Added a little override as this rule didn't seem to work properly. // Reth.
	   
	    else if ((findNumUnitsInBase(cMyID, kbBaseGetMain(cMyID), cUnitTypeTower) > 0)
              && (mapPreventsHousesAtTowers() == false) && (gBuildWallsAtMainBase == false)
              && (otherBaseID == mainBaseID) || (bHouseBunkering == true && mapPreventsHousesAtTowers() == false))
			  
        {
            //If we don't have the query yet, create one.
            if (unitQueryID < 0)
                unitQueryID = kbUnitQueryCreate("Tower Query");
   
            //Define a query to get all matching units
            if (unitQueryID != -1)
            {
                kbUnitQuerySetPlayerID(unitQueryID, cMyID);
                kbUnitQuerySetUnitType(unitQueryID, cUnitTypeTower);
                kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
            }

            kbUnitQueryResetResults(unitQueryID);
            int numTowers = kbUnitQueryExecute(unitQueryID);

            vector towerLoc1 = cInvalidVector;
            vector towerLoc2 = cInvalidVector;
            vector towerLoc3 = cInvalidVector;
            vector towerLoc4 = cInvalidVector;
            if (numTowers >= 1)
                towerLoc1 = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, 0));
            if (numTowers >= 2)
                towerLoc2 = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, 1));
            if (numTowers >= 3)
                towerLoc3 = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, 2));
            if (numTowers >= 4)
                towerLoc4 = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, 3));

            aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 0.0);

            if ((numHouses < 4) && (equal(towerLoc1, cInvalidVector) == false))
                aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, towerLoc1);
            else if ((numHouses < 8) && (equal(towerLoc2, cInvalidVector) == false))
                aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, towerLoc2);
            else if ((numHouses < 12) && (equal(towerLoc3, cInvalidVector) == false))
                aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, towerLoc3);
            else if (equal(towerLoc4, cInvalidVector) == false)
                aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, towerLoc4);

            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 8.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 10000.0);
        }
        else
        {
            aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
            aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);

            vector baseLocation = kbBaseGetLocation(cMyID, otherBaseID);
            aiPlanSetInitialPosition(planID, baseLocation);
            
            vector backVector = kbBaseGetBackVector(cMyID, otherBaseID);

            float bx = xsVectorGetX(backVector);
            float bz = xsVectorGetZ(backVector);
            float bxOrig = bx;
            float bzOrig = bz;

            int randomNumber = aiRandInt(2);
            if (otherBaseID != mainBaseID)
            {
                if (randomNumber == 0)
                {
                    bx = bxOrig * (8 + aiRandInt(5) - aiRandInt(3));
                    bz = bzOrig * (8 - aiRandInt(5) + aiRandInt(3));
                    aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 0.0);
                }
                else
                {
                    bx = bxOrig * (8 - aiRandInt(5) + aiRandInt(3));
                    bz = bzOrig * (8 + aiRandInt(5) - aiRandInt(3));
                    aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 0.0);
                }
            }
            else
            {
                bx = bxOrig * 33.0;
                bz = bzOrig * 33.0;
            }

            backVector = xsVectorSetX(backVector, bx);
            backVector = xsVectorSetZ(backVector, bz);
            backVector = xsVectorSetY(backVector, 0.0);

            vector backLocation = baseLocation + backVector;
            
            if (otherBaseID != mainBaseID)
            {
                location = backLocation;
            }
            else
            {
                if (aiRandInt(2) < 1)
                {
                    //left
                    bx = bzOrig * (-10);
                    bz = bxOrig * 10;
                }
                else
                {
                    //right
                    bx = bzOrig * 10;
                    bz = bxOrig * (-10);
                }
                backVector = xsVectorSetX(backVector, bx);
                backVector = xsVectorSetZ(backVector, bz);
                backVector = xsVectorSetY(backVector, 0.0);
                location = backLocation + backVector;
            }
            
            aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 15.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 150.0);
        }
        
        aiPlanSetBaseID(planID, otherBaseID);
        aiPlanSetEscrowID(planID, cEconomyEscrowID);
        aiPlanSetDesiredPriority(planID, 100);
        aiPlanSetActive(planID);
    }
}

//==============================================================================
rule buildSettlements
    minInterval 15 //starts in cAge3
    inactive
{
    aiEcho("buildSettlements:");

	if (AllyTcLimit == true && aiGetWorldDifficulty() > cDifficultyHard)
        {
            xsEnableRule("ModifiedbuildSettlements");
			xsDisableSelf();
            return;
        }
	
    //Figure out if we have any active BuildSettlements.
    int numberBuildSettlementGoals=aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true);
    int numberSettlements = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID);

    int numberSettlementsPlanned = numberSettlements + numberBuildSettlementGoals;

    if (numberSettlementsPlanned >= cvMaxSettlements)
        return;        // Don't go over script limit

    if (numberBuildSettlementGoals > 1)	// Allow 2 in progress, no more
        return;
    if (findASettlement() == false)
        return;
    if (numberSettlements > 1)  // Test for all the normal reasons to not build a settlement, unless we have only one
    {
        int popCapBuffer = 50;
        if (numberSettlements == 3)
            popCapBuffer = 30;
        else if (numberSettlements == 4)
            popCapBuffer = 20;
        else if (numberSettlements > 4)
            popCapBuffer = 10;
//        popCapBuffer = popCapBuffer + ((-1*cvRushBoomSlider)+1)*20;  // Add 0 for extreme rush, 40 for extreme boom
        popCapBuffer = popCapBuffer + ((-1*cvRushBoomSlider)+1)*5 + 5;  // Add 5 for extreme rush, 15 for extreme boom
        int currentPopNeeds=kbGetPop();
        int adjustedPopCap=getSoftPopCap()-popCapBuffer;

        //Don't do this unless we need the pop
        if (currentPopNeeds < adjustedPopCap)
            return;
      

        //If we're on Easy and we have 3 settlements, go away.
        if ((aiGetWorldDifficulty() == cDifficultyEasy) && (numberSettlementsPlanned >= 3))
        {
            xsDisableSelf();
            return;
        }
    }


    //Don't get too many more than our human allies.
    int largestAllyCount=-1;
    for (i=1; < cNumberPlayers)
    {
        if (i == cMyID)
            continue;
        if (kbIsPlayerAlly(i) == false)
            continue;
        if (kbIsPlayerHuman(i) == false)     // MK:  Only worry about humans, no sense holding back for confused AI ally
            continue;
        int count = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, i);
        if (count > largestAllyCount)
            largestAllyCount=count;
    }
    
    //Never have more than 2 more settlements than any human ally.
    int difference=numberSettlementsPlanned-largestAllyCount;
    if ((difference > 2) && (largestAllyCount>=0))     // If ally exists and we have more than 2 more...quit
        return;

    //See if there is another human on my team.
    bool haveHumanTeammate=false;
    for (i=1; < cNumberPlayers)
    {
        if (i == cMyID)
            continue;
        //Find the human player
        if (kbIsPlayerHuman(i) != true)
            continue;

        //This player is a human ally and not resigned.
        if ((kbIsPlayerAlly(i) == true) && (kbIsPlayerResigned(i) == false))
        {
            haveHumanTeammate=true;
            break;
        }
    }
    
    if (haveHumanTeammate == true)
    {
        if (kbGetAge() == cAge3)
        {
            if (numberSettlementsPlanned > 4)
                return;
        }
        else if (kbGetAge() == cAge4)
        {
            if (numberSettlementsPlanned >= cvMaxSettlements)
                return;
        }
    }
    aiEcho("Creating another settlement goal.");

    int numBuilders = 3;
    if (cMyCulture == cCultureAtlantean)
        numBuilders = 1;
        
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
		
		// Increase NumBuilders if conditions are met
		int MoreBuildersAvailable = getNumUnits(cUnitTypeAbstractVillager, cUnitStateAlive, -1, cMyID);
		float foodSupply = kbResourceGet(cResourceFood);
        if (cMyCulture == cCultureAtlantean)
		MoreBuildersAvailable = MoreBuildersAvailable *3;
		
		if (MoreBuildersAvailable > 45)
		{
        numBuilders = 6;
    if (cMyCulture == cCultureAtlantean)
        numBuilders = 2;            
        }
        
    //Else, do it.
    createBuildSettlementGoal("BuildSettlement", kbGetAge(), -1, kbBaseGetMainID(cMyID), numBuilders, builderType, true, 100);
}

// MODDED ONE
//==============================================================================
rule ModifiedbuildSettlements
    minInterval 15 //starts in cAge3
    inactive
{
    	if (xsGetTime() > ModdedTCTimer*60*1000)
        {
            AllyTcLimit = false;
			xsEnableRule("buildSettlements");
			xsDisableSelf();
            return;
        }
		
    aiEcho("buildSettlements:");

    //Figure out if we have any active BuildSettlements.
    int numberBuildSettlementGoals=aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true);
    int numberSettlements = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID);

    int numberSettlementsPlanned = numberSettlements + numberBuildSettlementGoals;

    if (numberSettlementsPlanned >= cvMaxSettlements)
        return;        // Don't go over script limit

    if (numberBuildSettlementGoals > 1)	// Allow 2 in progress, no more
        return;
    if (findASettlement() == false)
        return;
    if (numberSettlements > 1)  // Test for all the normal reasons to not build a settlement, unless we have only one
    {
        int popCapBuffer = 50;
        if (numberSettlements == 3)
            popCapBuffer = 30;
        else if (numberSettlements == 4)
            popCapBuffer = 20;
        else if (numberSettlements > 4)
            popCapBuffer = 10;
//        popCapBuffer = popCapBuffer + ((-1*cvRushBoomSlider)+1)*20;  // Add 0 for extreme rush, 40 for extreme boom
        popCapBuffer = popCapBuffer + ((-1*cvRushBoomSlider)+1)*5 + 5;  // Add 5 for extreme rush, 15 for extreme boom
        int currentPopNeeds=kbGetPop();
        int adjustedPopCap=getSoftPopCap()-popCapBuffer;

        //Don't do this unless we need the pop
        if (currentPopNeeds < adjustedPopCap)
            return;
      

        //If we're on Easy and we have 3 settlements, go away.
        if ((aiGetWorldDifficulty() == cDifficultyEasy) && (numberSettlementsPlanned >= 3))
        {
            xsDisableSelf();
            return;
        }
    }


    //Don't get too many more than our human allies.
    int largestAllyCount=-1;
    for (i=1; < cNumberPlayers)
    {
        if (i == cMyID)
            continue;
        if (kbIsPlayerAlly(i) == true)
            continue;

        int count = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, i);
        if (count > largestAllyCount)
            largestAllyCount=count;
    }
    
    //Never have more than 1 more settlements than any ally.
    int difference=numberSettlementsPlanned-largestAllyCount;
    if ((difference > 1) && (largestAllyCount>=0))     // If ally exists and we have more than 2 more...quit
        return;

    //See if there is another human on my team.
    bool haveHumanTeammate=false;
    for (i=1; < cNumberPlayers)
    {
        if (i == cMyID)
            continue;
        //Find the human player
        if (kbIsPlayerAlly(i) != true)
            continue;

        //This player is a human ally and not resigned.
        if ((kbIsPlayerAlly(i) == true) && (kbIsPlayerResigned(i) == false))
        {
            haveHumanTeammate=true;
            break;
        }
    }
    
    if (haveHumanTeammate == true)
    {
        if (kbGetAge() == cAge3)
        {
            if (numberSettlementsPlanned > 4)
                return;
        }
        else if (kbGetAge() == cAge4)
        {
            if (numberSettlementsPlanned >= cvMaxSettlements)
                return;
        }
    }
    aiEcho("Creating another settlement goal.");

    int numBuilders = 3;
    if (cMyCulture == cCultureAtlantean)
        numBuilders = 1;
        
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
        
    //Else, do it.
    createBuildSettlementGoal("BuildSettlement", kbGetAge(), -1, kbBaseGetMainID(cMyID), numBuilders, builderType, true, 100);
}


//==============================================================================
rule buildSettlementsEarly  //age 1/2 handler
    minInterval 16 //starts in cAge2
    inactive
{
    aiEcho("buildSettlementsEarly:");
    
    //Figure out if we have any active BuildSettlements.
    int numberBuildSettlementGoals = aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true);
    int numberSettlements = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID);

    int numberSettlementsPlanned = numberSettlements + numberBuildSettlementGoals;

    if (numberBuildSettlementGoals > 1)	// Allow 2 in progress, no more
        return;
    if (findASettlement() == false)
        return;

    if (kbGetAge() > cAge1)
    {
        if ((gEarlySettlementTarget < 2) && (xsGetTime() > 14*60*1000))
        {
            gEarlySettlementTarget = 2;
        }
        else if ((gEarlySettlementTarget < 3) && (xsGetTime() > 20*60*1000))
        {
            gEarlySettlementTarget = 3;
        }
    }
    
    if (numberSettlementsPlanned >= gEarlySettlementTarget)
        return;     // We have or are building all we want

    if ((cvRandomMapName == "nomad") && (numberSettlements == 0))
        return;		// Skip if we're still in nomad startup mode

    aiEcho("Creating another early settlement goal.");

    int numBuilders = 3;
    if (cMyCulture == cCultureAtlantean)
        numBuilders = 1;
        
//    //priority 85 to be below farming at 90.
//        createBuildSettlementGoal("BuildSettlement", kbGetAge(), -1, kbBaseGetMainID(cMyID), numBuilders, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0), true, 85);
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
        
    if (xsGetTime() > 20*60*1000)
        createBuildSettlementGoal("BuildSettlement", kbGetAge(), -1, kbBaseGetMainID(cMyID), numBuilders, builderType, true, 100);        
    else
        createBuildSettlementGoal("BuildSettlement", kbGetAge(), kbGetAge() + 1, kbBaseGetMainID(cMyID), numBuilders, builderType, true, 99);
}

//==============================================================================
vector calcDockPos(int which=-1)
{
//    vector basePos = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    vector basePos = kbBaseGetLocation(cMyID, gDockBaseID);
    vector towardCenter = kbGetMapCenter()- basePos;
    vector dockPos = cInvalidVector;
    float q = _atan2(xsVectorGetZ(towardCenter), xsVectorGetX(towardCenter));
    if (which == 1)
    {
        q = q + PI/4.0;
    }
    else
    {
        q = q - PI/4.0;
    }

    float c = _cos(q);
    float s = _sin(q);
//    float x = c * 7.0;
    float x = c * 14.0;
//    float z = s * 7.0;
    float z = s * 14.0;
    towardCenter = xsVectorSetX(towardCenter, x);
    towardCenter = xsVectorSetZ(towardCenter, z);
    int areaID = -1;

//    for (i=0; < 20)
    for (i=0; < 10)
    {
        dockPos = dockPos+towardCenter;
        areaID = kbAreaGetIDByPosition(dockPos);
        if (kbAreaGetType(areaID) == cAreaTypeWater)
        {
            dockPos = kbAreaGetCenter(areaID);
            break;
        }
    }
    return(dockPos);
}

//==============================================================================
rule dockMonitor
    inactive
//    minInterval 61 //starts in cAge1
    minInterval 15 //starts in cAge1
{
    aiEcho("dockMonitor:");
    
    if (gWaterMap == false)
    {
        xsDisableSelf();
        return;
    }
	
    if ((gTransportMap == false) && (xsGetTime() < 10*60*1000))
        return;
	
    int randomBase = findUnit(cUnitTypeAbstractSettlement);
    if (randomBase < 0)
        return;
    else
    {
        gDockBaseID = kbUnitGetBaseID(randomBase);
        aiEcho("gDockBaseID is #"+gDockBaseID);
    }

    int numDocks = kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding);
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (numDocks < numSettlements)
    {
        aiEcho("we have less docks than settlements, setting minInterval to 23");
        xsSetRuleMinIntervalSelf(23);
    }

    int desiredDocks = 1;
    if (cRandomMapName == "anatolia")
    {
        desiredDocks = 2;
        gDockBaseID = kbBaseGetMainID(cMyID);
    }
    
    // everything ok. we have enough docks
    if ((gTransportMap == false) && (numDocks >= desiredDocks))
    {
        aiEcho("gTransportMap == false and we have at least 1 dock, returning");
        return;
    }

    if (((numDocks >= kbGetAge()+1) && (numDocks >= numSettlements))
      || (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeDock) >= 0))
    {
        aiEcho("(numDocks >= kbGetAge()+1 AND numDocks >= numSettlements) or another dockplan already active, returning");
        return;
    }

    static vector dockPos1 = cInvalidVector;
    static vector dockPos2 = cInvalidVector;
    vector dockPos = cInvalidVector;

//    static int flipflop = 1;
    int flipflop = aiRandInt(2);
    if (flipflop == 1)
    {
        if (equal(dockPos1, cInvalidVector) == true)
            dockPos1 = calcDockPos(flipflop);
        dockPos = dockPos1;
    }
    else
    {
        if (equal(dockPos2, cInvalidVector) == true)
            dockPos2 = calcDockPos(flipflop);
        dockPos = dockPos2;
    }

    aiEcho("dockPos x="+xsVectorGetX(dockPos)+" z="+xsVectorGetZ(dockPos));

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
        
    int buildDock = aiPlanCreate("BuildDock", cPlanBuild);
    if (buildDock >= 0)
    {
        aiEcho("dockMonitor: Building dock at base #"+gDockBaseID);
        //BP Type and Priority.
        aiPlanSetVariableInt(buildDock, cBuildPlanBuildingTypeID, 0, cUnitTypeDock);
        aiPlanSetDesiredPriority(buildDock, 100);
//        aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
        aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 0, kbBaseGetLocation(cMyID, gDockBaseID));
        aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 1, dockPos);
//        aiPlanAddUnitType(buildDock, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanAddUnitType(buildDock, builderType, 1, 1, 1);
        aiPlanSetEscrowID(buildDock, cEconomyEscrowID);
        aiPlanSetActive(buildDock);
        xsSetRuleMinIntervalSelf(89);
    }
}

//==============================================================================
rule makeWonder
    minInterval 61 //starts in cAge4
    inactive       //  Activated on reaching age 4 if game isn't conquest
{
    aiEcho("makeWonder:");
    
    int   targetArea = -1;
    vector target = cInvalidVector;     // Will be used to center the building placement behind the town.
    target = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
    vector offset = cInvalidVector;
    offset = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
    offset = offset * 30.0;
    target = target + offset;
    targetArea = kbAreaGetIDByPosition(target);

	int planID=aiPlanCreate("Wonder Build", cPlanBuild);
    if (planID < 0)
        return;

    aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeWonder);

    aiPlanSetVariableInt(planID, cBuildPlanAreaID, 0, targetArea);
    aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 0, 2);

    aiPlanSetDesiredPriority(planID, 99);

    //Mil vs. Econ.
    aiPlanSetMilitary(planID, false);
    aiPlanSetEconomy(planID, true);

    //Escrow.
    aiPlanSetEscrowID(planID, cEconomyEscrowID);

    int builderUnit = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderUnit = cUnitTypeAbstractInfantry;

    int builderCount = -1;
    builderCount = kbUnitCount(cMyID, builderUnit, cUnitStateAlive);

    //Builders.
    aiPlanAddUnitType(planID, builderUnit, (2*builderCount)/3, builderCount, (3*builderCount)/2);   // Two thirds, all, or 150%...in case new builders are created.

    //Base ID.
    aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));

    //Go.
    aiPlanSetActive(planID);

    xsEnableRule("watchForWonder");     // Looks for wonder placement, starts defensive reaction.
    xsDisableSelf();
}

//==============================================================================
rule mainBaseAreaWallTeam1
//    minInterval 21 //starts in cAge2
    minInterval 23 //starts in cAge2
    inactive
{
    aiEcho("mainBaseAreaWallTeam1:");

    static bool alreadyStarted = false;
    int numHeroes = kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive);
    if ((alreadyStarted == false) && (numHeroes < 1) && (xsGetTime() < 6.5*60*1000))
        return;
    
    float goldSupply = kbResourceGet(cResourceGold);

    //If we already have a build wall plan, don't make another one.
    int wallPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true);
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);

    int mainBaseID=kbBaseGetMainID(cMyID);

    if (wallPlanID >= 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gMainBaseAreaWallTeam1PlanID)
            {
                static int mainBaseAreaWallTeam1StartTime = -1;
                if (mainBaseAreaWallTeam1StartTime < 0)
                    mainBaseAreaWallTeam1StartTime = xsGetTime();
                
                if ((goldSupply < 50) && (xsGetTime() > 19*60*1000))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    mainBaseAreaWallTeam1StartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
                }
                
                //destroy the plan if it has been active for more than 12 minutes
                if (xsGetTime() > (mainBaseAreaWallTeam1StartTime + 12*60*1000))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    mainBaseAreaWallTeam1StartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
                }

                //Get the enemies near my base
                int numEnemyUnitsNearBase = kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
                int myUnitsNearBase = kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
                int alliedUnitsNearBase = kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);

                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
                if ((secondsUnderAttack > 25) && (xsGetTime() > 19*60*1000))
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        mainBaseAreaWallTeam1StartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
                    }
                }

                return;
            }
        }
    }
    
    if (alreadyStarted == false)
    {
        if (goldSupply < 100)
            return;
    }
    else
    {
        if (goldSupply < 150)
            return;
    }
    
/*
    New area-based walling.  The concept is to get a list of appropriate areas, pass them to the walling plan,
    and have it build a wall around the convex hull defined by that area list.  To do this, I take this approach.
    1) Define a 'radius', which is the length of a square zone that we want to enclose.
    2) Add the center area to the list.
    3) For each area within 2 layers of that center area, include it if its in the same area group and
        a) its center is within that area, or
        b) it is a gold area, or
        c) it is a settlement area.
*/

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    int mainBaseAreaWallTeam1PlanID = aiPlanCreate("mainBaseAreaWallTeam1PlanID", cPlanBuildWall);
    if (mainBaseAreaWallTeam1PlanID != -1)
    {
        if (cRandomMapName == "ghost lake") 
            gMainBaseAreaWallRadius = 26;
        else if (cRandomMapName == "marsh")
            gMainBaseAreaWallRadius = 26;
        else if (cRandomMapName == "jotunheim")
            gMainBaseAreaWallRadius = 29;
        else if (cRandomMapName == "anatolia")
            gMainBaseAreaWallRadius = 29;
        else if (cRandomMapName == "savannah")
            gMainBaseAreaWallRadius = 27;
        else if (cRandomMapName == "alfheim")
            gMainBaseAreaWallRadius = 26;
        else if (cRandomMapName == "tundra")    //TODO: find the best radius
            gMainBaseAreaWallRadius = 26;
        
        aiPlanSetNumberVariableValues(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, 20, true);
        int numAreasAdded = 0;

        int mainArea = -1;
        vector mainCenter = kbBaseGetLocation(cMyID, mainBaseID);
        aiPlanSetInitialPosition(mainBaseAreaWallTeam1PlanID, mainCenter);
        
        float mainX = xsVectorGetX(mainCenter);
        float mainZ = xsVectorGetZ(mainCenter);
        mainArea = kbAreaGetIDByPosition(mainCenter);
        aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
        numAreasAdded = numAreasAdded + 1;
        
        static bool firstRun = true;
        static int savedBackAreaID = -1;
        
        if (gResetWallPlans == true)
        {
            firstRun = true;
            gBackAreaLocation = cInvalidVector;
            gHouseAreaLocation = cInvalidVector;
            gBackAreaID = -1;
            gHouseAreaID = -1;
            gResetWallPlans = false;
            savedBackAreaID = -1;
        }
        
        if (firstRun == true)
        {
            //always include the backArea
            if (equal(gBackAreaLocation, cInvalidVector) == true)
            {
                vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
                float bx = xsVectorGetX(backVector);
                float origbx = bx;
                float bz = xsVectorGetZ(backVector);
                float origbz = bz;
                bx = bx * 20.0;
                bz = bz * 20.0;

                for (m = 0; < 5)
                {
                    backVector = xsVectorSetX(backVector, bx);
                    backVector = xsVectorSetZ(backVector, bz);
                    backVector = xsVectorSetY(backVector, 0.0);

                    int areaGroup1 = kbAreaGroupGetIDByPosition(mainCenter);   // base area group
                    gBackAreaLocation = mainCenter + backVector;
                    int areaGroup2 = kbAreaGroupGetIDByPosition(gBackAreaLocation);   // back vector area group
                    if (areaGroup1 == areaGroup2)
                    {
                        gBackAreaID = kbAreaGetIDByPosition(gBackAreaLocation);
                        if ((gBackAreaID == mainArea) || (gBackAreaID == savedBackAreaID))
                        {
                            if (m < 4)
                            {
                                bx = bx * 1.1;
                                bz = bz * 1.1;
/*
                                if (gBackAreaID == mainArea)
                                    aiEcho("gBackAreaID is the same as the mainArea,");
                                else
                                    aiEcho("gBackAreaID is the same as the savedBackAreaID,");
*/
                                continue;
                            }
                            else
                            {
                                if (savedBackAreaID != -1)
                                {
                                    gBackAreaID = savedBackAreaID;
                                    break;
                                }
                                else
                                {
                                    gBackAreaID = -1;   //only add it if it's not the mainArea
                                    break;
                                }
                            }
                        }
                        else if (gBackAreaID == -1)
                        {
                            if (savedBackAreaID != -1)
                            {
                                gBackAreaID = savedBackAreaID;
                                break;
                            }
                            else
                            {
                                break;
                            }
                        }
                        else
                        {
                            if (kbAreaGetType(gBackAreaID) == cAreaTypeGold)
                            {
                                savedBackAreaID = gBackAreaID;
                                continue;
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
            
            //always include the houseArea
            if (equal(gHouseAreaLocation, cInvalidVector) == true)
            {
                bx = origbx * 30.0;
                bz = origbz * 30.0;

                for (n = 0; < 5)
                {
                    backVector = xsVectorSetX(backVector, bx);
                    backVector = xsVectorSetZ(backVector, bz);
                    backVector = xsVectorSetY(backVector, 0.0);

                    areaGroup1 = kbAreaGroupGetIDByPosition(mainCenter);   // base area group
                    gHouseAreaLocation = mainCenter + backVector;
                    areaGroup2 = kbAreaGroupGetIDByPosition(gHouseAreaLocation);   // house vector area group
                    if (areaGroup1 == areaGroup2)
                    {
                        gHouseAreaID = kbAreaGetIDByPosition(gHouseAreaLocation);
                        if ((gHouseAreaID == mainArea) || (gHouseAreaID == gBackAreaID))
                        {
                            if (n < 4)
                            {
                                bx = bx * 1.1;
                                bz = bz * 1.1;
/*
                                if (gHouseAreaID == mainArea)
                                    aiEcho("gHouseAreaID is the same as the mainArea,");
                                else
                                    aiEcho("gHouseAreaID is the same as the gBackAreaID,");
*/
                                continue;
                            }
                            else
                            {
                                gHouseAreaID = -1;   //only add it if it's not the mainArea or the gBackAreaID
/*
                                if (gHouseAreaID == mainArea)
                                    aiEcho("no need to add the gHouseAreaID as it's the same as the mainArea");
                                else
                                    aiEcho("no need to add the gHouseAreaID as it's the same as the gBackAreaID");
*/
                                break;
                            }
                        }
                        else if (gHouseAreaID == -1)
                        {
                            break;
                        }
                        else
                        {
                            break;
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
            xsEnableRule("mainBaseAreaWallTeam2");
            firstRun = false;
        }

        
        int firstRingCount = -1;      // How many areas are in first ring around main?
        int firstRingIndex = -1;      // Which one are we on?
        int secondRingCount = -1;     // How many border areas does the current first ring area have?
        int secondRingIndex = -1;  
        int firstRingID = -1;         // Actual ID of current 1st ring area
        int secondRingID = -1;
        vector areaCenter = cInvalidVector;    // Center point of this area
        float areaX = 0.0;
        float dx = 0.0;
        float areaZ = 0.0;
        float dz = 0.0;
        int areaType = -1;
        bool needToSave = false;

        firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
        for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
        {
            needToSave = true;            // We'll save this unless we have a problem
            firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
            if (firstRingID == -1)
                continue;
                
            areaCenter = kbAreaGetCenter(firstRingID);
            
            // Now, do the checks.
            areaX = xsVectorGetX(areaCenter);
            areaZ = xsVectorGetZ(areaCenter);
            dx = mainX - areaX;
            dz = mainZ - areaZ;
            if ((dx > gMainBaseAreaWallRadius) || (dx < -1.0 * gMainBaseAreaWallRadius)
             || (dz > gMainBaseAreaWallRadius) || (dz < -1.0 * gMainBaseAreaWallRadius))
            {
                needToSave = false;
            }
            
            areaType = kbAreaGetType(firstRingID);
            //increase the radius if it's a forest area
            if (areaType == cAreaTypeForest)
            {
//                if ((dx > gMainBaseAreaWallRadius * 1.3) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.3)
//                 || (dz > gMainBaseAreaWallRadius * 1.3) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.3))
                if ((dx > gMainBaseAreaWallRadius * 1.2) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.2)
                 || (dz > gMainBaseAreaWallRadius * 1.2) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.2))
                {
                    needToSave = false;
                }
                else
                {
                    needToSave = true;
                }
            }
            // Override if it's a special type
            else if (areaType == cAreaTypeGold)
            {
                needToSave = true;
            }
            else if (areaType == cAreaTypeSettlement)
            {
                needToSave = true;
            }
            else
            {
                // Override if it's the gBackAreaID or the gHouseAreaID
                if (gBackAreaID == firstRingID)
                {
                    needToSave = true;
                }
                else if (gHouseAreaID == firstRingID)
                {
                    needToSave = true;
                }
/*
                else
                {
                    if (needToSave == true)
                        aiEcho("adding area: "+firstRingID+" as it's within gMainBaseAreaWallRadius");
                }
*/
            }

            // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
            if (needToSave == true)
            {
                bool found = false;
                for (j = 0; < numAreasAdded)
                {
                    if (aiPlanGetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, j) == firstRingID)
                    {
                        found = true;     // It's in there, don't add it
                    }
                }
                if ((found == false) && (numAreasAdded < 20))  // add it
                {
                    aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
                    numAreasAdded = numAreasAdded + 1;
                    
                    // If we had to add it, check all its surrounding areas, too...if it turns out we need to.
                    secondRingCount = kbAreaGetNumberBorderAreas(firstRingID);     // How many does it touch?
                    for (secondRingIndex = 0; < secondRingCount)
                    {     
                        // Check each border area.  If it's gold or settlement and not already in list, add it.
                        secondRingID = kbAreaGetBorderAreaID(firstRingID, secondRingIndex);
                        if (secondRingID == -1)
                            continue;
                        
                        areaType = kbAreaGetType(secondRingID);
                        if ((areaType == cAreaTypeSettlement) || (areaType == cAreaTypeGold) || (areaType == cAreaTypeForest) || ((gHouseAreaID == secondRingID) && (gHouseAreaID != -1)))
                        {
                            bool skipme = false;       // Skip it if center is outside gMainBaseAreaWallRadius * 1.4
                            areaX = xsVectorGetX(kbAreaGetCenter(secondRingID));
                            areaZ = xsVectorGetZ(kbAreaGetCenter(secondRingID));
                            dx = mainX - areaX;
                            dz = mainZ - areaZ;
                            
                            if (areaType == cAreaTypeForest)
                            {
//                                if ((dx > gMainBaseAreaWallRadius * 1.3) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.3)
//                                 || (dz > gMainBaseAreaWallRadius * 1.3) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.3))
                                if ((dx > gMainBaseAreaWallRadius * 1.2) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.2)
                                 || (dz > gMainBaseAreaWallRadius * 1.2) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.2))
                                {
                                    skipme = true;
                                }
                            }
                            else
                            {
                                if ((dx > gMainBaseAreaWallRadius * 1.4) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.4)
                                 || (dz > gMainBaseAreaWallRadius * 1.4) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.4))
                                {
                                    skipme = true;
                                }
                            }
                            
                            // add it if it's the gHouseAreaID and not already added
                            if (gHouseAreaID == secondRingID)
                            {
                                skipme = false;
                            }
                            
                            bool alreadyIn = false;

                            for (k = 0; < numAreasAdded)
                            {
                                if (aiPlanGetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, k) == secondRingID)
                                {
                                    alreadyIn = true;     // It's in there, don't add it
                                }
                            }
                            
                            if ((alreadyIn == false) && (skipme == false) && (numAreasAdded < 20))  // add it
                            {
/*
                                if (gHouseAreaID == secondRingID)
                                {
                                    aiEcho("gHouseAreaID == secondRingID, adding the gHouseAreaID: "+gHouseAreaID);
                                }
                                else
                                {
                                    if (areaType == cAreaTypeForest)
                                        aiEcho("adding area: "+secondRingID+" as it's a forest area and within gMainBaseAreaWallRadius * 1.2");
                                    else if (areaType == cAreaTypeGold)
                                        aiEcho("adding area: "+secondRingID+" as it's a gold area and within gMainBaseAreaWallRadius * 1.4");
                                    else if (areaType == cAreaTypeSettlement)
                                        aiEcho("adding area: "+secondRingID+" as it's a settlement area and within gMainBaseAreaWallRadius * 1.4");
                                    else
                                        aiEcho("adding area: "+secondRingID+" as it's within gMainBaseAreaWallRadius * 1.4");
                                }
*/
                                aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, secondRingID);
                                numAreasAdded = numAreasAdded + 1;
                            }
                        }
                    }
                }
            }
        }
/*
        aiEcho("    Area list:");
        for (l = 0; < numAreasAdded)
            aiEcho("        "+aiPlanGetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, l));
*/
        // Set the true number of area variables, preserving existing values, then turn on the plan
        aiPlanSetNumberVariableValues(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

        aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
//        aiPlanAddUnitType(mainBaseAreaWallTeam1PlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanAddUnitType(mainBaseAreaWallTeam1PlanID, builderType, 1, 1, 1);
        aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanNumberOfGates, 0, 50);
        aiPlanSetVariableFloat(mainBaseAreaWallTeam1PlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
        aiPlanSetBaseID(mainBaseAreaWallTeam1PlanID, mainBaseID);
        aiPlanSetEscrowID(mainBaseAreaWallTeam1PlanID, cMilitaryEscrowID);
        aiPlanSetDesiredPriority(mainBaseAreaWallTeam1PlanID, 100);
        aiPlanSetActive(mainBaseAreaWallTeam1PlanID, true);
        gMainBaseAreaWallTeam1PlanID = mainBaseAreaWallTeam1PlanID;
        xsSetRuleMinIntervalSelf(127);
        if (alreadyStarted == false)
            alreadyStarted = true;
    }
}
//Reth
//==============================================================================
rule MBSecondaryWall
//    minInterval 21 //starts in cAge2
    minInterval 30 //starts in cAge4
    inactive
{
   if (aiGetWorldDifficulty() < cDifficultyNightmare)
  {
    xsDisableSelf();
	aiEcho("I will not build a secondary MB wall on Hard or lower.");
	return; // Disable and go back.
  }  
   
   // Go back if we're not in Mythic Age
    if (kbGetAge() < cAge4)
	 return;    



	//If we're in Mythic age, we want to ensure that we can spare some gold before building this mess of a wall.

	float goldSupply = kbResourceGet(cResourceGold);

    //Make sure we have enough gold
	if (goldSupply < 350)
	   return;   
	
	aiEcho("Secondary Wall plan launched");

    static bool alreadyStarted = false;
    int numHeroes = kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive);
    if ((alreadyStarted == false) && (numHeroes < 1) && (xsGetTime() < 6.5*60*1000))
        return;
    

    //If we already have a build wall plan, don't make another one.
    int wallPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true);
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);

    int mainBaseID=kbBaseGetMainID(cMyID);

    if (wallPlanID >= 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gMBSecondaryWall)
            {
                static int SecondaryMainBaseWallStartTime = -1;
                if (SecondaryMainBaseWallStartTime < 0)
                    SecondaryMainBaseWallStartTime = xsGetTime();
                
                if ((goldSupply < 50) && (xsGetTime() > 19*60*1000))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    SecondaryMainBaseWallStartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
                }
                
                //destroy the plan if it has been active for more than 12 minutes
                if (xsGetTime() > (SecondaryMainBaseWallStartTime + 12*60*1000))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    SecondaryMainBaseWallStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
                }

                //Get the enemies near my base
                int numEnemyUnitsNearBase = kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
                int myUnitsNearBase = kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
                int alliedUnitsNearBase = kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);

                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
                if ((secondsUnderAttack > 25) && (xsGetTime() > 19*60*1000))
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        SecondaryMainBaseWallStartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
                    }
                }

                return;
            }
        }
    }
    
    if (alreadyStarted == false)
    {
        if (goldSupply < 100)
            return;
    }
    else
    {
        if (goldSupply < 150)
            return;
    }
    
/*
    New area-based walling.  The concept is to get a list of appropriate areas, pass them to the walling plan,
    and have it build a wall around the convex hull defined by that area list.  To do this, I take this approach.
    1) Define a 'radius', which is the length of a square zone that we want to enclose.
    2) Add the center area to the list.
    3) For each area within 2 layers of that center area, include it if its in the same area group and
        a) its center is within that area, or
        b) it is a gold area, or
        c) it is a settlement area.
*/

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    int mainBaseAreaWallTeam1PlanID = aiPlanCreate("mainBaseAreaWallTeam1PlanID", cPlanBuildWall);
    if (mainBaseAreaWallTeam1PlanID != -1)
    {
        if (cRandomMapName == "ghost lake") 
            gMainBaseAreaWallRadius = 29;
        else if (cRandomMapName == "marsh")
            gMainBaseAreaWallRadius = 29;
        else if (cRandomMapName == "jotunheim")
            gMainBaseAreaWallRadius = 23;
        else if (cRandomMapName == "anatolia")
            gMainBaseAreaWallRadius = 23;
        else if (cRandomMapName == "savannah")
            gMainBaseAreaWallRadius = 31;
        else if (cRandomMapName == "alfheim")
            gMainBaseAreaWallRadius = 29;
        else if (cRandomMapName == "tundra")    //TODO: find the best radius
            gMainBaseAreaWallRadius = 29;
        
        aiPlanSetNumberVariableValues(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, 20, true);
        int numAreasAdded = 0;

        int mainArea = -1;
        vector mainCenter = kbBaseGetLocation(cMyID, mainBaseID);
        aiPlanSetInitialPosition(mainBaseAreaWallTeam1PlanID, mainCenter);
        
        float mainX = xsVectorGetX(mainCenter);
        float mainZ = xsVectorGetZ(mainCenter);
        mainArea = kbAreaGetIDByPosition(mainCenter);
        aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
        numAreasAdded = numAreasAdded + 1;
        
        static bool firstRun = true;
        static int savedBackAreaID = -1;
        
        if (gResetWallPlans == true)
        {
            firstRun = true;
            gBackAreaLocation = cInvalidVector;
            gHouseAreaLocation = cInvalidVector;
            gBackAreaID = -1;
            gHouseAreaID = -1;
            gResetWallPlans = false;
            savedBackAreaID = -1;
        }
        
        if (firstRun == true)
        {
            //always include the backArea
            if (equal(gBackAreaLocation, cInvalidVector) == true)
            {
                vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
                float bx = xsVectorGetX(backVector);
                float origbx = bx;
                float bz = xsVectorGetZ(backVector);
                float origbz = bz;
                bx = bx * 20.0;
                bz = bz * 20.0;

                for (m = 0; < 5)
                {
                    backVector = xsVectorSetX(backVector, bx);
                    backVector = xsVectorSetZ(backVector, bz);
                    backVector = xsVectorSetY(backVector, 0.0);

                    int areaGroup1 = kbAreaGroupGetIDByPosition(mainCenter);   // base area group
                    gBackAreaLocation = mainCenter + backVector;
                    int areaGroup2 = kbAreaGroupGetIDByPosition(gBackAreaLocation);   // back vector area group
                    if (areaGroup1 == areaGroup2)
                    {
                        gBackAreaID = kbAreaGetIDByPosition(gBackAreaLocation);
                        if ((gBackAreaID == mainArea) || (gBackAreaID == savedBackAreaID))
                        {
                            if (m < 4)
                            {
                                bx = bx * 1.1;
                                bz = bz * 1.1;
/*
                                if (gBackAreaID == mainArea)
                                    aiEcho("gBackAreaID is the same as the mainArea,");
                                else
                                    aiEcho("gBackAreaID is the same as the savedBackAreaID,");
*/
                                continue;
                            }
                            else
                            {
                                if (savedBackAreaID != -1)
                                {
                                    gBackAreaID = savedBackAreaID;
                                    break;
                                }
                                else
                                {
                                    gBackAreaID = -1;   //only add it if it's not the mainArea
                                    break;
                                }
                            }
                        }
                        else if (gBackAreaID == -1)
                        {
                            if (savedBackAreaID != -1)
                            {
                                gBackAreaID = savedBackAreaID;
                                break;
                            }
                            else
                            {
                                break;
                            }
                        }
                        else
                        {
                            if (kbAreaGetType(gBackAreaID) == cAreaTypeGold)
                            {
                                savedBackAreaID = gBackAreaID;
                                continue;
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
            
            //always include the houseArea
            if (equal(gHouseAreaLocation, cInvalidVector) == true)
            {
                bx = origbx * 30.0;
                bz = origbz * 30.0;

                for (n = 0; < 5)
                {
                    backVector = xsVectorSetX(backVector, bx);
                    backVector = xsVectorSetZ(backVector, bz);
                    backVector = xsVectorSetY(backVector, 0.0);

                    areaGroup1 = kbAreaGroupGetIDByPosition(mainCenter);   // base area group
                    gHouseAreaLocation = mainCenter + backVector;
                    areaGroup2 = kbAreaGroupGetIDByPosition(gHouseAreaLocation);   // house vector area group
                    if (areaGroup1 == areaGroup2)
                    {
                        gHouseAreaID = kbAreaGetIDByPosition(gHouseAreaLocation);
                        if ((gHouseAreaID == mainArea) || (gHouseAreaID == gBackAreaID))
                        {
                            if (n < 4)
                            {
                                bx = bx * 1.1;
                                bz = bz * 1.1;
/*
                                if (gHouseAreaID == mainArea)
                                    aiEcho("gHouseAreaID is the same as the mainArea,");
                                else
                                    aiEcho("gHouseAreaID is the same as the gBackAreaID,");
*/
                                continue;
                            }
                            else
                            {
                                gHouseAreaID = -1;   //only add it if it's not the mainArea or the gBackAreaID
/*
                                if (gHouseAreaID == mainArea)
                                    aiEcho("no need to add the gHouseAreaID as it's the same as the mainArea");
                                else
                                    aiEcho("no need to add the gHouseAreaID as it's the same as the gBackAreaID");
*/
                                break;
                            }
                        }
                        else if (gHouseAreaID == -1)
                        {
                            break;
                        }
                        else
                        {
                            break;
                        }
                    }
                    else
                    {
                        break;
                    }
                }
            }
            xsEnableRule("mainBaseAreaWallTeam2");
            firstRun = false;
        }

        
        int firstRingCount = -1;      // How many areas are in first ring around main?
        int firstRingIndex = -1;      // Which one are we on?
        int secondRingCount = -1;     // How many border areas does the current first ring area have?
        int secondRingIndex = -1;  
        int firstRingID = -1;         // Actual ID of current 1st ring area
        int secondRingID = -1;
        vector areaCenter = cInvalidVector;    // Center point of this area
        float areaX = 0.0;
        float dx = 0.0;
        float areaZ = 0.0;
        float dz = 0.0;
        int areaType = -1;
        bool needToSave = false;

        firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
        for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
        {
            needToSave = true;            // We'll save this unless we have a problem
            firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
            if (firstRingID == -1)
                continue;
                
            areaCenter = kbAreaGetCenter(firstRingID);
            
            // Now, do the checks.
            areaX = xsVectorGetX(areaCenter);
            areaZ = xsVectorGetZ(areaCenter);
            dx = mainX - areaX;
            dz = mainZ - areaZ;
            if ((dx > gSecondaryMainBaseAreaWallRadius) || (dx < -1.0 * gSecondaryMainBaseAreaWallRadius)
             || (dz > gSecondaryMainBaseAreaWallRadius) || (dz < -1.0 * gSecondaryMainBaseAreaWallRadius))
            {
                needToSave = false;
            }
            
            areaType = kbAreaGetType(firstRingID);
            //increase the radius if it's a forest area
            if (areaType == cAreaTypeForest)
            {
//                if ((dx > gSecondaryMainBaseAreaWallRadius * 1.3) || (dx < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.3)
//                 || (dz > gSecondaryMainBaseAreaWallRadius * 1.3) || (dz < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.3))
                if ((dx > gSecondaryMainBaseAreaWallRadius * 1.2) || (dx < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.2)
                 || (dz > gSecondaryMainBaseAreaWallRadius * 1.2) || (dz < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.2))
                {
                    needToSave = false;
                }
                else
                {
                    needToSave = true;
                }
            }
            // Override if it's a special type
            else if (areaType == cAreaTypeGold)
            {
                needToSave = true;
            }
            else if (areaType == cAreaTypeSettlement)
            {
                needToSave = true;
            }
            else
            {
                // Override if it's the gBackAreaID or the gHouseAreaID
                if (gBackAreaID == firstRingID)
                {
                    needToSave = true;
                }
                else if (gHouseAreaID == firstRingID)
                {
                    needToSave = true;
                }
/*
                else
                {
                    if (needToSave == true)
                        aiEcho("adding area: "+firstRingID+" as it's within gSecondaryMainBaseAreaWallRadius");
                }
*/
            }

            // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
            if (needToSave == true)
            {
                bool found = false;
                for (j = 0; < numAreasAdded)
                {
                    if (aiPlanGetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, j) == firstRingID)
                    {
                        found = true;     // It's in there, don't add it
                    }
                }
                if ((found == false) && (numAreasAdded < 20))  // add it
                {
                    aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
                    numAreasAdded = numAreasAdded + 1;
                    
                    // If we had to add it, check all its surrounding areas, too...if it turns out we need to.
                    secondRingCount = kbAreaGetNumberBorderAreas(firstRingID);     // How many does it touch?
                    for (secondRingIndex = 0; < secondRingCount)
                    {     
                        // Check each border area.  If it's gold or settlement and not already in list, add it.
                        secondRingID = kbAreaGetBorderAreaID(firstRingID, secondRingIndex);
                        if (secondRingID == -1)
                            continue;
                        
                        areaType = kbAreaGetType(secondRingID);
                        if ((areaType == cAreaTypeSettlement) || (areaType == cAreaTypeGold) || (areaType == cAreaTypeForest) || ((gHouseAreaID == secondRingID) && (gHouseAreaID != -1)))
                        {
                            bool skipme = false;       // Skip it if center is outside gSecondaryMainBaseAreaWallRadius * 1.4
                            areaX = xsVectorGetX(kbAreaGetCenter(secondRingID));
                            areaZ = xsVectorGetZ(kbAreaGetCenter(secondRingID));
                            dx = mainX - areaX;
                            dz = mainZ - areaZ;
                            
                            if (areaType == cAreaTypeForest)
                            {
//                                if ((dx > gSecondaryMainBaseAreaWallRadius * 1.3) || (dx < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.3)
//                                 || (dz > gSecondaryMainBaseAreaWallRadius * 1.3) || (dz < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.3))
                                if ((dx > gSecondaryMainBaseAreaWallRadius * 1.2) || (dx < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.2)
                                 || (dz > gSecondaryMainBaseAreaWallRadius * 1.2) || (dz < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.2))
                                {
                                    skipme = true;
                                }
                            }
                            else
                            {
                                if ((dx > gSecondaryMainBaseAreaWallRadius * 1.4) || (dx < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.4)
                                 || (dz > gSecondaryMainBaseAreaWallRadius * 1.4) || (dz < -1.0 * gSecondaryMainBaseAreaWallRadius * 1.4))
                                {
                                    skipme = true;
                                }
                            }
                            
                            // add it if it's the gHouseAreaID and not already added
                            if (gHouseAreaID == secondRingID)
                            {
                                skipme = false;
                            }
                            
                            bool alreadyIn = false;

                            for (k = 0; < numAreasAdded)
                            {
                                if (aiPlanGetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, k) == secondRingID)
                                {
                                    alreadyIn = true;     // It's in there, don't add it
                                }
                            }
                            
                            if ((alreadyIn == false) && (skipme == false) && (numAreasAdded < 20))  // add it
                            {
/*
                                if (gHouseAreaID == secondRingID)
                                {
                                    aiEcho("gHouseAreaID == secondRingID, adding the gHouseAreaID: "+gHouseAreaID);
                                }
                                else
                                {
                                    if (areaType == cAreaTypeForest)
                                        aiEcho("adding area: "+secondRingID+" as it's a forest area and within gSecondaryMainBaseAreaWallRadius * 1.2");
                                    else if (areaType == cAreaTypeGold)
                                        aiEcho("adding area: "+secondRingID+" as it's a gold area and within gSecondaryMainBaseAreaWallRadius * 1.4");
                                    else if (areaType == cAreaTypeSettlement)
                                        aiEcho("adding area: "+secondRingID+" as it's a settlement area and within gSecondaryMainBaseAreaWallRadius * 1.4");
                                    else
                                        aiEcho("adding area: "+secondRingID+" as it's within gSecondaryMainBaseAreaWallRadius * 1.4");
                                }
*/
                                aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, secondRingID);
                                numAreasAdded = numAreasAdded + 1;
                            }
                        }
                    }
                }
            }
        }
/*
        aiEcho("    Area list:");
        for (l = 0; < numAreasAdded)
            aiEcho("        "+aiPlanGetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, l));
*/
        // Set the true number of area variables, preserving existing values, then turn on the plan
        aiPlanSetNumberVariableValues(mainBaseAreaWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

        aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
//        aiPlanAddUnitType(mainBaseAreaWallTeam1PlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanAddUnitType(mainBaseAreaWallTeam1PlanID, builderType, 1, 1, 1);
        aiPlanSetVariableInt(mainBaseAreaWallTeam1PlanID, cBuildWallPlanNumberOfGates, 0, 50);
        aiPlanSetVariableFloat(mainBaseAreaWallTeam1PlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
        aiPlanSetBaseID(mainBaseAreaWallTeam1PlanID, mainBaseID);
        aiPlanSetEscrowID(mainBaseAreaWallTeam1PlanID, cMilitaryEscrowID);
        aiPlanSetDesiredPriority(mainBaseAreaWallTeam1PlanID, 100);
        aiPlanSetActive(mainBaseAreaWallTeam1PlanID, true);
        gMainBaseAreaWallTeam1PlanID = mainBaseAreaWallTeam1PlanID;
        xsSetRuleMinIntervalSelf(127);
        if (alreadyStarted == false)
            alreadyStarted = true;
    }
}


//==============================================================================
rule mainBaseAreaWallTeam2
//    minInterval 23 //starts in cAge2,  activated in mainBaseAreaWallTeam1 rule
    minInterval 29 //starts in cAge2,  activated in mainBaseAreaWallTeam1 rule
    inactive
{
    aiEcho("mainBaseAreaWallTeam2:");

    if ((cMyCulture == cCultureAtlantean) && (xsGetTime() < 15*60*1000))
        return;
    float goldSupply = kbResourceGet(cResourceGold);

    //If we already have a build wall plan, don't make another one.
    int wallPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true);
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);

    int mainBaseID=kbBaseGetMainID(cMyID);

    if (wallPlanID >= 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gMainBaseAreaWallTeam2PlanID)
            {
                static int mainBaseAreaWallTeam2StartTime = -1;
                if (mainBaseAreaWallTeam2StartTime < 0)
                    mainBaseAreaWallTeam2StartTime = xsGetTime();
                
                if (goldSupply < 100)
                {
                    aiPlanDestroy(wallPlanIndexID);
                    mainBaseAreaWallTeam2StartTime = -1;
                    xsSetRuleMinIntervalSelf(29);
                    return;
                }
                
                //destroy the plan if it has been active for more than 12 minutes
                if (xsGetTime() > (mainBaseAreaWallTeam2StartTime + 12*60*1000))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    mainBaseAreaWallTeam2StartTime = -1;
                    xsSetRuleMinIntervalSelf(67);
                    return;
                }
				
                //Get the enemies near my base
                int numEnemyUnitsNearBase = kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
                int myUnitsNearBase = kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
                int alliedUnitsNearBase = kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);
				
                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
                if (secondsUnderAttack > 25)
                {
                    //Destroy the plan if there are twice as many enemies as my units
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        mainBaseAreaWallTeam2StartTime = -1;
                        xsSetRuleMinIntervalSelf(67);
                        return;
                    }
                }

                return;
            }
        }
    }

    if (goldSupply < 240)
        return;
        
/*
    New area-based walling.  The concept is to get a list of appropriate areas, pass them to the walling plan,
    and have it build a wall around the convex hull defined by that area list.  To do this, I take this approach.
    1) Define a 'radius', which is the length of a square zone that we want to enclose.
    2) Add the center area to the list.
    3) For each area within 2 layers of that center area, include it if its in the same area group and
        a) its center is within that area, or
        b) it is a gold area, or
        c) it is a settlement area.
*/

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    int mainBaseAreaWallTeam2PlanID = aiPlanCreate("mainBaseAreaWallTeam2PlanID", cPlanBuildWall);
    if (mainBaseAreaWallTeam2PlanID != -1)
    {
        aiPlanSetNumberVariableValues(mainBaseAreaWallTeam2PlanID, cBuildWallPlanAreaIDs, 20, true);
        int numAreasAdded = 0;

        int mainArea = -1;
        vector mainCenter = kbBaseGetLocation(cMyID, mainBaseID);
        aiPlanSetInitialPosition(mainBaseAreaWallTeam2PlanID, mainCenter);
        
        float mainX = xsVectorGetX(mainCenter);
        float mainZ = xsVectorGetZ(mainCenter);
        mainArea = kbAreaGetIDByPosition(mainCenter);
        aiPlanSetVariableInt(mainBaseAreaWallTeam2PlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
        numAreasAdded = numAreasAdded + 1;

        int firstRingCount = -1;      // How many areas are in first ring around main?
        int firstRingIndex = -1;      // Which one are we on?
        int secondRingCount = -1;     // How many border areas does the current first ring area have?
        int secondRingIndex = -1;  
        int firstRingID = -1;         // Actual ID of current 1st ring area
        int secondRingID = -1;
        vector areaCenter = cInvalidVector;    // Center point of this area
        float areaX = 0.0;
        float dx = 0.0;
        float areaZ = 0.0;
        float dz = 0.0;
        int areaType = -1;
        bool needToSave = false;

        firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
        for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
        {
            needToSave = true;            // We'll save this unless we have a problem
            firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
            if (firstRingID == -1)
                continue;
                
            areaCenter = kbAreaGetCenter(firstRingID);
            
            // Now, do the checks.
            areaX = xsVectorGetX(areaCenter);
            areaZ = xsVectorGetZ(areaCenter);
            dx = mainX - areaX;
            dz = mainZ - areaZ;
            if ((dx > gMainBaseAreaWallRadius) || (dx < -1.0 * gMainBaseAreaWallRadius)
             || (dz > gMainBaseAreaWallRadius) || (dz < -1.0 * gMainBaseAreaWallRadius))
            {
                needToSave = false;
            }

            areaType = kbAreaGetType(firstRingID);
            //increase the radius if it's a forest area
            if (areaType == cAreaTypeForest)
            {
//                if ((dx > gMainBaseAreaWallRadius * 1.3) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.3)
//                 || (dz > gMainBaseAreaWallRadius * 1.3) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.3))
                if ((dx > gMainBaseAreaWallRadius * 1.2) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.2)
                 || (dz > gMainBaseAreaWallRadius * 1.2) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.2))
                {
                    needToSave = false;
                }
                else
                {
                    needToSave = true;
                }
            }
            // Override if it's a special type
            else if (areaType == cAreaTypeGold)
            {
                needToSave = true;
            }
            else if (areaType == cAreaTypeSettlement)
            {
                needToSave = true;
            }
            else
            {
                // Override if it's the gBackAreaID or the gHouseAreaID
                if (gBackAreaID == firstRingID)
                {
                    needToSave = true;
                }
                else if (gHouseAreaID == firstRingID)
                {
                    needToSave = true;
                }
/*
                else
                {
                    if (needToSave == true)
                        aiEcho("adding area: "+firstRingID+" as it's within gMainBaseAreaWallRadius");
                }
*/
            }
            
            // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
            if (needToSave == true)
            {
                bool found = false;
                for (j = 0; < numAreasAdded)
                {
                    if (aiPlanGetVariableInt(mainBaseAreaWallTeam2PlanID, cBuildWallPlanAreaIDs, j) == firstRingID)
                    {
                        found = true;     // It's in there, don't add it
                    }
                }
                if ((found == false) && (numAreasAdded < 20))  // add it
                {
                    aiPlanSetVariableInt(mainBaseAreaWallTeam2PlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
                    numAreasAdded = numAreasAdded + 1;
                    
                    // If we had to add it, check all its surrounding areas, too...if it turns out we need to.
                    secondRingCount = kbAreaGetNumberBorderAreas(firstRingID);     // How many does it touch?
                    for (secondRingIndex = 0; < secondRingCount)
                    {     
                        // Check each border area.  If it's gold or settlement and not already in list, add it.
                        secondRingID = kbAreaGetBorderAreaID(firstRingID, secondRingIndex);
                        if (secondRingID == -1)
                            continue;
                        
                        areaType = kbAreaGetType(secondRingID);
                        if ((areaType == cAreaTypeSettlement) || (areaType == cAreaTypeGold) || (areaType == cAreaTypeForest) || ((gHouseAreaID == secondRingID) && (gHouseAreaID != -1)))
                        {
                            bool skipme = false;       // Skip it if center is outside gMainBaseAreaWallRadius * 1.4
                            areaX = xsVectorGetX(kbAreaGetCenter(secondRingID));
                            areaZ = xsVectorGetZ(kbAreaGetCenter(secondRingID));
                            dx = mainX - areaX;
                            dz = mainZ - areaZ;
                            
                            if (areaType == cAreaTypeForest)
                            {
//                                if ((dx > gMainBaseAreaWallRadius * 1.3) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.3)
//                                 || (dz > gMainBaseAreaWallRadius * 1.3) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.3))
                                if ((dx > gMainBaseAreaWallRadius * 1.2) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.2)
                                 || (dz > gMainBaseAreaWallRadius * 1.2) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.2))
                                {
                                    skipme = true;
                                }
                            }
                            else
                            {
                                if ((dx > gMainBaseAreaWallRadius * 1.4) || (dx < -1.0 * gMainBaseAreaWallRadius * 1.4)
                                 || (dz > gMainBaseAreaWallRadius * 1.4) || (dz < -1.0 * gMainBaseAreaWallRadius * 1.4))
                                {
                                    skipme = true;
                                }
                            }
                            
                            // add it if it's the gHouseAreaID and not already added
                            if (gHouseAreaID == secondRingID)
                            {
                                skipme = false;
                            }
                            
                            bool alreadyIn = false;

                            for (k = 0; < numAreasAdded)
                            {
                                if (aiPlanGetVariableInt(mainBaseAreaWallTeam2PlanID, cBuildWallPlanAreaIDs, k) == secondRingID)
                                {
                                    alreadyIn = true;     // It's in there, don't add it
                                }
                            }
                            
                            if ((alreadyIn == false) && (skipme == false) && (numAreasAdded < 20))  // add it
                            {
/*
                                if (gHouseAreaID == secondRingID)
                                {
                                    aiEcho("gHouseAreaID == secondRingID, adding the gHouseAreaID: "+gHouseAreaID);
                                }
                                else
                                {
                                    if (areaType == cAreaTypeForest)
                                        aiEcho("adding area: "+secondRingID+" as it's a forest area and within gMainBaseAreaWallRadius * 1.2");
                                    else if (areaType == cAreaTypeGold)
                                        aiEcho("adding area: "+secondRingID+" as it's a gold area and within gMainBaseAreaWallRadius * 1.4");
                                    else if (areaType == cAreaTypeSettlement)
                                        aiEcho("adding area: "+secondRingID+" as it's a settlement area and within gMainBaseAreaWallRadius * 1.4");
                                    else
                                        aiEcho("adding area: "+secondRingID+" as it's within gMainBaseAreaWallRadius * 1.4");
                                }
*/
                                aiPlanSetVariableInt(mainBaseAreaWallTeam2PlanID, cBuildWallPlanAreaIDs, numAreasAdded, secondRingID);
                                numAreasAdded = numAreasAdded + 1;
                            }
                        }
                    }
                }
            }
        }
/*
        aiEcho("    Area list:");
        for (l = 0; < numAreasAdded)
            aiEcho("        "+aiPlanGetVariableInt(mainBaseAreaWallTeam2PlanID, cBuildWallPlanAreaIDs, l));
*/
        // Set the true number of area variables, preserving existing values, then turn on the plan
        aiPlanSetNumberVariableValues(mainBaseAreaWallTeam2PlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

        aiPlanSetVariableInt(mainBaseAreaWallTeam2PlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
//        aiPlanAddUnitType(mainBaseAreaWallTeam2PlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanAddUnitType(mainBaseAreaWallTeam2PlanID, builderType, 1, 1, 1);
        aiPlanSetVariableInt(mainBaseAreaWallTeam2PlanID, cBuildWallPlanNumberOfGates, 0, 50);
        aiPlanSetVariableFloat(mainBaseAreaWallTeam2PlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
        aiPlanSetBaseID(mainBaseAreaWallTeam2PlanID, mainBaseID);
        aiPlanSetEscrowID(mainBaseAreaWallTeam2PlanID, cEconomyEscrowID);
        aiPlanSetDesiredPriority(mainBaseAreaWallTeam2PlanID, 100);
        aiPlanSetActive(mainBaseAreaWallTeam2PlanID, true);
        gMainBaseAreaWallTeam2PlanID = mainBaseAreaWallTeam2PlanID;
        xsSetRuleMinIntervalSelf(131);
    }
}

//==============================================================================
rule otherBaseRingWallTeam1
    minInterval 19 //starts in cAge2
    inactive
{
    aiEcho("otherBaseRingWallTeam1:");
  
    float goldSupply = kbResourceGet(cResourceGold);
    
    int mainBaseID=kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID=kbUnitGetBaseID(otherBaseUnitID);
        if (otherBaseID == mainBaseID)
        {
            return;
        }
    }

	if (aiGetWorldDifficulty() < cDifficultyNightmare)
	gOtherBaseWallRadius = 19;
	
    //check if there are farms close to where we want to place our walls and delete them
    vector otherBaseLocation = kbBaseGetLocation(cMyID, otherBaseID);
    int numFarmsInR12 = getNumUnits(cUnitTypeFarm, cUnitStateAliveOrBuilding, -1, cMyID, otherBaseLocation, 12.0);
    int numFarmsInR25 = getNumUnits(cUnitTypeFarm, cUnitStateAliveOrBuilding, -1, cMyID, otherBaseLocation, 25.0);
    aiEcho("numFarmsInR12: "+numFarmsInR12);
    aiEcho("numFarmsInR25: "+numFarmsInR25);
    if (numFarmsInR25 - numFarmsInR12 > 0)
    {
        for (i = numFarmsInR25 - 1; >= 0)
        {
            int farmIDInR25 = findUnitByIndex(cUnitTypeFarm, i, cUnitStateAliveOrBuilding, -1, cMyID, otherBaseLocation, 25.0);
            aiEcho("farmIDInR25: "+farmIDInR25);
            if (farmIDInR25 != -1)
            {
                vector farmPosition = kbUnitGetPosition(farmIDInR25);
                aiEcho("farmPosition: "+farmPosition);
                float distance = xsVectorLength(otherBaseLocation - farmPosition);
                if (distance > 12.0)
                {
                    aiTaskUnitDelete(farmIDInR25);
                    aiEcho("deleting farm with ID: "+farmIDInR25);
                    
                }
                else
                {
                    aiEcho("distance <= 12.0, breaking off");
                    break;
                }
            }
        }
    }
    
    //If we already have a build wall plan, don't make another one.
    int wallPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true);
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);

    if (wallPlanID >= 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBaseRingWallTeam1PlanID)
            {
                static int otherBaseRingWallTeam1StartTime = -1;
                if (otherBaseRingWallTeam1StartTime < 0)
                    otherBaseRingWallTeam1StartTime = xsGetTime();
                
                if (goldSupply < 120)
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBaseRingWallTeam1StartTime = -1;
                    xsSetRuleMinIntervalSelf(19);
                    return;
                }
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBaseRingWallTeam1StartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBaseRingWallTeam1StartTime = -1;
                    xsSetRuleMinIntervalSelf(59);
                    return;
                }

                //Get the enemies near my base
                int numEnemyUnitsNearBase = kbBaseGetNumberUnits(cMyID, otherBaseID, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
                int myUnitsNearBase = kbBaseGetNumberUnits(cMyID, otherBaseID, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
                int alliedUnitsNearBase = kbBaseGetNumberUnits(cMyID, otherBaseID, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);

                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, otherBaseID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBaseRingWallTeam1StartTime = -1;
                        xsSetRuleMinIntervalSelf(59);
                        return;
                    }
                }

                return;
            }
        }
    }
    
    if (goldSupply < 200)
        return;

    float otherBaseWallRadius = gOtherBaseWallRadius;
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    int otherBaseWallTeam1PlanID = aiPlanCreate("otherBaseWallTeam1PlanID", cPlanBuildWall);
    if (otherBaseWallTeam1PlanID != -1)
    {
        aiPlanSetNumberVariableValues(otherBaseWallTeam1PlanID, cBuildWallPlanAreaIDs, 20, true);
        int numAreasAdded = 0;

        int mainArea = -1;
        vector mainCenter = kbBaseGetLocation(cMyID, otherBaseID);
        aiPlanSetInitialPosition(otherBaseWallTeam1PlanID, mainCenter);
        
        float mainX = xsVectorGetX(mainCenter);
        float mainZ = xsVectorGetZ(mainCenter);
        mainArea = kbAreaGetIDByPosition(mainCenter);
        aiEcho("otherBaseRingWallTeam1:");
        aiEcho("My main area is "+mainArea+", at "+mainCenter);
        aiPlanSetVariableInt(otherBaseWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
        numAreasAdded = numAreasAdded + 1;
      
        int firstRingCount = -1;      // How many areas are in first ring around main?
        int firstRingIndex = -1;      // Which one are we on?
        int firstRingID = -1;         // Actual ID of current 1st ring area
        vector areaCenter = cInvalidVector;    // Center point of this area
        float areaX = 0.0;
        float dx = 0.0;
        float areaZ = 0.0;
        float dz = 0.0;
        int areaType = -1;
        bool needToSave = false;

        firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
        for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
        {
            needToSave = true;            // We'll save this unless we have a problem
            firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
            areaCenter = kbAreaGetCenter(firstRingID);
            // Now, do the checks.
            areaX = xsVectorGetX(areaCenter);
            areaZ = xsVectorGetZ(areaCenter);
            dx = mainX - areaX;
            dz = mainZ - areaZ;
            
            if ((dx > otherBaseWallRadius) || (dx < -1.0 * otherBaseWallRadius)
             || (dz > otherBaseWallRadius) || (dz < -1.0 * otherBaseWallRadius))
            {
                needToSave = false;
            }
            
            areaType = kbAreaGetType(firstRingID);
            // Increase the radius if it's a special type
            if (areaType == cAreaTypeGold)
            {
                int numGoldMinesByRadius = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, areaCenter, 15.0, true);             
                aiEcho("numGoldMinesByRadius: "+numGoldMinesByRadius);
                int numGoldMinesByArea = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, cInvalidVector, -1, true, firstRingID);
                aiEcho("numGoldMinesByArea: "+numGoldMinesByArea);
                int numGoldMines = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, cInvalidVector, -1, true, firstRingID);
                if (numGoldMines > 0)
                {
//                    if ((dx <= 25.0) && (dx >= -25.0)
//                     && (dz <= 25.0) && (dz >= -25.0))
                    if ((dx <= 30.0) && (dx >= -30.0)
                     && (dz <= 30.0) && (dz >= -30.0))
                    {
                        needToSave = true;
                    }
                }
            }

            // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
            if (needToSave == true)
            {
                bool found = false;
                for (j = 0; < numAreasAdded)
                {
                    if (aiPlanGetVariableInt(otherBaseWallTeam1PlanID, cBuildWallPlanAreaIDs, j) == firstRingID)
                    {
                        found = true;     // It's in there, don't add it
                    }
                }
                if ((found == false) && (numAreasAdded < 20))  // add it
                {
                    aiPlanSetVariableInt(otherBaseWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
                    numAreasAdded = numAreasAdded + 1;
                }
            }
        }
/*
        aiEcho("    Area list:");
        for (l = 0; < numAreasAdded)
            aiEcho("        "+aiPlanGetVariableInt(otherBaseWallTeam1PlanID, cBuildWallPlanAreaIDs, l));
*/
        // Set the true number of area variables, preserving existing values, then turn on the plan
        aiPlanSetNumberVariableValues(otherBaseWallTeam1PlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

        aiPlanSetVariableInt(otherBaseWallTeam1PlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
//        aiPlanAddUnitType(otherBaseWallTeam1PlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanAddUnitType(otherBaseWallTeam1PlanID, builderType, 1, 1, 1);
        aiPlanSetVariableInt(otherBaseWallTeam1PlanID, cBuildWallPlanNumberOfGates, 0, 40);
        aiPlanSetVariableFloat(otherBaseWallTeam1PlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
        aiPlanSetBaseID(otherBaseWallTeam1PlanID, otherBaseID);
        aiPlanSetEscrowID(otherBaseWallTeam1PlanID, cEconomyEscrowID);
        aiPlanSetDesiredPriority(otherBaseWallTeam1PlanID, 100);
        aiPlanSetActive(otherBaseWallTeam1PlanID, true);
        gOtherBaseRingWallTeam1PlanID = otherBaseWallTeam1PlanID;
        xsSetRuleMinIntervalSelf(37);
    }
}

//==============================================================================
rule otherBase1RingWallTeam
    minInterval 11 //starts in cAge2, activated in otherBasesDefPlans rule
    inactive
{
    aiEcho("otherBase1RingWallTeam:");
    
    float goldSupply = kbResourceGet(cResourceGold);
    
	if (aiGetWorldDifficulty() < cDifficultyNightmare)
	gOtherBaseWallRadius = 19;
	
    //If we already have a build wall plan, don't make another one.
    int wallPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true);
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);

    if (wallPlanID >= 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBase1RingWallTeamPlanID)
            {
                static int otherBase1RingWallTeamStartTime = -1;
                if (otherBase1RingWallTeamStartTime < 0)
                    otherBase1RingWallTeamStartTime = xsGetTime();
                
                if (goldSupply < 100)
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase1RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
                }
                
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBase1RingWallTeamStartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase1RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
                }

                //Get the enemies near my base
                int numEnemyUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase1ID, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
                int myUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase1ID, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
                int alliedUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase1ID, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);

                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, gOtherBase1ID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBase1RingWallTeamStartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
                    }
                }

                return;
            }
        }
    }
    
    if (goldSupply < 150)
        return;
    
    float otherBaseWallRadius = gOtherBaseWallRadius;
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    int otherBase1WallTeamPlanID = aiPlanCreate("otherBase1WallTeamPlanID", cPlanBuildWall);
    if (otherBase1WallTeamPlanID != -1)
    {
        aiPlanSetNumberVariableValues(otherBase1WallTeamPlanID, cBuildWallPlanAreaIDs, 20, true);
        int numAreasAdded = 0;

        int mainArea = -1;
        vector mainCenter = kbBaseGetLocation(cMyID, gOtherBase1ID);
        aiPlanSetInitialPosition(otherBase1WallTeamPlanID, mainCenter);
        
        float mainX = xsVectorGetX(mainCenter);
        float mainZ = xsVectorGetZ(mainCenter);
        mainArea = kbAreaGetIDByPosition(mainCenter);
        aiPlanSetVariableInt(otherBase1WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
        numAreasAdded = numAreasAdded + 1;
      
        int firstRingCount = -1;      // How many areas are in first ring around main?
        int firstRingIndex = -1;      // Which one are we on?
        int firstRingID = -1;         // Actual ID of current 1st ring area
        vector areaCenter = cInvalidVector;    // Center point of this area
        float areaX = 0.0;
        float dx = 0.0;
        float areaZ = 0.0;
        float dz = 0.0;
        bool needToSave = false;

        firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
        for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
        {
            needToSave = true;            // We'll save this unless we have a problem
            firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
            areaCenter = kbAreaGetCenter(firstRingID);
            // Now, do the checks.
            areaX = xsVectorGetX(areaCenter);
            areaZ = xsVectorGetZ(areaCenter);
            dx = mainX - areaX;
            dz = mainZ - areaZ;
            if ((dx > otherBaseWallRadius) || (dx < -1.0*otherBaseWallRadius)
             || (dz > otherBaseWallRadius) || (dz < -1.0*otherBaseWallRadius))
            {
                needToSave = false;
            }
            
            // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
            if (needToSave == true)
            {
                bool found =false;
                for (j = 0; < numAreasAdded)
                {
                    if (aiPlanGetVariableInt(otherBase1WallTeamPlanID, cBuildWallPlanAreaIDs, j) == firstRingID)
                    {
                        found = true;     // It's in there, don't add it
                    }
                }
                if ((found == false) && (numAreasAdded < 20))  // add it
                {
                    aiPlanSetVariableInt(otherBase1WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
                    numAreasAdded = numAreasAdded + 1;
                }
            }
        }
/*
        aiEcho("    Area list:");
        for (l = 0; < numAreasAdded)
            aiEcho("        "+aiPlanGetVariableInt(otherBase1WallTeamPlanID, cBuildWallPlanAreaIDs, l));
*/
        // Set the true number of area variables, preserving existing values, then turn on the plan
        aiPlanSetNumberVariableValues(otherBase1WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

        aiPlanSetVariableInt(otherBase1WallTeamPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
//        aiPlanAddUnitType(otherBase1WallTeamPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanAddUnitType(otherBase1WallTeamPlanID, builderType, 1, 1, 1);
        aiPlanSetVariableInt(otherBase1WallTeamPlanID, cBuildWallPlanNumberOfGates, 0, 40);
        aiPlanSetVariableFloat(otherBase1WallTeamPlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
        aiPlanSetBaseID(otherBase1WallTeamPlanID, gOtherBase1ID);
        aiPlanSetEscrowID(otherBase1WallTeamPlanID, cMilitaryEscrowID);
        aiPlanSetDesiredPriority(otherBase1WallTeamPlanID, 100);
        aiPlanSetActive(otherBase1WallTeamPlanID, true);
        gOtherBase1RingWallTeamPlanID = otherBase1WallTeamPlanID;
        xsSetRuleMinIntervalSelf(83);
    }
}

//==============================================================================
rule otherBase2RingWallTeam
    minInterval 11 //starts in cAge2, activated in otherBasesDefPlans rule
    inactive
{
    aiEcho("otherBase2RingWallTeam:");
    
    float goldSupply = kbResourceGet(cResourceGold);
    
    if (aiGetWorldDifficulty() < cDifficultyNightmare)
	gOtherBaseWallRadius = 19;
	
    //If we already have a build wall plan, don't make another one.
    int wallPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true);
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);

    if (wallPlanID >= 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBase2RingWallTeamPlanID)
            {
                static int otherBase2RingWallTeamStartTime = -1;
                if (otherBase2RingWallTeamStartTime < 0)
                    otherBase2RingWallTeamStartTime = xsGetTime();
                
                if (goldSupply < 100)
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase2RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
                }
                
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBase2RingWallTeamStartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase2RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
                }

                //Get the enemies near my base
                int numEnemyUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase2ID, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
                int myUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase2ID, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
                int alliedUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase2ID, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);

                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, gOtherBase2ID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBase2RingWallTeamStartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
                    }
                }

                return;
            }
        }
    }
    
    if (goldSupply < 150)
        return;

    float otherBaseWallRadius = gOtherBaseWallRadius;
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    int otherBase2WallTeamPlanID = aiPlanCreate("otherBase2WallTeamPlanID", cPlanBuildWall);
    if (otherBase2WallTeamPlanID != -1)
    {
        aiPlanSetNumberVariableValues(otherBase2WallTeamPlanID, cBuildWallPlanAreaIDs, 20, true);
        int numAreasAdded = 0;

        int mainArea = -1;
        vector mainCenter = kbBaseGetLocation(cMyID, gOtherBase2ID);
        aiPlanSetInitialPosition(otherBase2WallTeamPlanID, mainCenter);
        
        float mainX = xsVectorGetX(mainCenter);
        float mainZ = xsVectorGetZ(mainCenter);
        mainArea = kbAreaGetIDByPosition(mainCenter);
        aiPlanSetVariableInt(otherBase2WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
        numAreasAdded = numAreasAdded + 1;
      
        int firstRingCount = -1;      // How many areas are in first ring around main?
        int firstRingIndex = -1;      // Which one are we on?
        int firstRingID = -1;         // Actual ID of current 1st ring area
        vector areaCenter = cInvalidVector;    // Center point of this area
        float areaX = 0.0;
        float dx = 0.0;
        float areaZ = 0.0;
        float dz = 0.0;
        bool needToSave = false;

        firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
        for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
        {
            needToSave = true;            // We'll save this unless we have a problem
            firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
            areaCenter = kbAreaGetCenter(firstRingID);
            // Now, do the checks.
            areaX = xsVectorGetX(areaCenter);
            areaZ = xsVectorGetZ(areaCenter);
            dx = mainX - areaX;
            dz = mainZ - areaZ;
            if ((dx > otherBaseWallRadius) || (dx < -1.0*otherBaseWallRadius)
             || (dz > otherBaseWallRadius) || (dz < -1.0*otherBaseWallRadius))
            {
                needToSave = false;
            }

            // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
            if (needToSave == true)
            {
                bool found =false;
                for (j = 0; < numAreasAdded)
                {
                    if (aiPlanGetVariableInt(otherBase2WallTeamPlanID, cBuildWallPlanAreaIDs, j) == firstRingID)
                    {
                        found = true;     // It's in there, don't add it
                    }
                }
                if ((found == false) && (numAreasAdded < 20))  // add it
                {
                    aiPlanSetVariableInt(otherBase2WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
                    numAreasAdded = numAreasAdded + 1;
                }
            }
        }
/*
        aiEcho("    Area list:");
        for (l = 0; < numAreasAdded)
            aiEcho("        "+aiPlanGetVariableInt(otherBase2WallTeamPlanID, cBuildWallPlanAreaIDs, l));
*/
        // Set the true number of area variables, preserving existing values, then turn on the plan
        aiPlanSetNumberVariableValues(otherBase2WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

        aiPlanSetVariableInt(otherBase2WallTeamPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
//        aiPlanAddUnitType(otherBase2WallTeamPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanAddUnitType(otherBase2WallTeamPlanID, builderType, 1, 1, 1);
        aiPlanSetVariableInt(otherBase2WallTeamPlanID, cBuildWallPlanNumberOfGates, 0, 40);
        aiPlanSetVariableFloat(otherBase2WallTeamPlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
        aiPlanSetBaseID(otherBase2WallTeamPlanID, gOtherBase2ID);
        aiPlanSetEscrowID(otherBase2WallTeamPlanID, cMilitaryEscrowID);
        aiPlanSetDesiredPriority(otherBase2WallTeamPlanID, 100);
        aiPlanSetActive(otherBase2WallTeamPlanID, true);
        gOtherBase2RingWallTeamPlanID = otherBase2WallTeamPlanID;
        xsSetRuleMinIntervalSelf(83);
    }
}

//==============================================================================
rule otherBase3RingWallTeam
    minInterval 11 //starts in cAge2, activated in otherBasesDefPlans rule
    inactive
{
    aiEcho("otherBase3RingWallTeam:");
    
    float goldSupply = kbResourceGet(cResourceGold);
    
    if (aiGetWorldDifficulty() < cDifficultyNightmare)
	gOtherBaseWallRadius = 19;
	
    //If we already have a build wall plan, don't make another one.
    int wallPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true);
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);

    if (wallPlanID >= 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBase3RingWallTeamPlanID)
            {
                static int otherBase3RingWallTeamStartTime = -1;
                if (otherBase3RingWallTeamStartTime < 0)
                    otherBase3RingWallTeamStartTime = xsGetTime();
                
                if (goldSupply < 100)
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase3RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
                }
                
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBase3RingWallTeamStartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase3RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
                }

                //Get the enemies near my base
                int numEnemyUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase3ID, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
                int myUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase3ID, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
                int alliedUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase3ID, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);

                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, gOtherBase3ID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBase3RingWallTeamStartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
                    }
                }

                return;
            }
        }
    }
    
    if (goldSupply < 150)
        return;

    float otherBaseWallRadius = gOtherBaseWallRadius;
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    int otherBase3WallTeamPlanID = aiPlanCreate("otherBase3WallTeamPlanID", cPlanBuildWall);
    if (otherBase3WallTeamPlanID != -1)
    {
        aiPlanSetNumberVariableValues(otherBase3WallTeamPlanID, cBuildWallPlanAreaIDs, 20, true);
        int numAreasAdded = 0;

        int mainArea = -1;
        vector mainCenter = kbBaseGetLocation(cMyID, gOtherBase3ID);
        aiPlanSetInitialPosition(otherBase3WallTeamPlanID, mainCenter);
        
        float mainX = xsVectorGetX(mainCenter);
        float mainZ = xsVectorGetZ(mainCenter);
        mainArea = kbAreaGetIDByPosition(mainCenter);
        aiPlanSetVariableInt(otherBase3WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
        numAreasAdded = numAreasAdded + 1;
      
        int firstRingCount = -1;      // How many areas are in first ring around main?
        int firstRingIndex = -1;      // Which one are we on?
        int firstRingID = -1;         // Actual ID of current 1st ring area
        vector areaCenter = cInvalidVector;    // Center point of this area
        float areaX = 0.0;
        float dx = 0.0;
        float areaZ = 0.0;
        float dz = 0.0;
        bool needToSave = false;

        firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
        for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
        {
            needToSave = true;            // We'll save this unless we have a problem
            firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
            areaCenter = kbAreaGetCenter(firstRingID);
            // Now, do the checks.
            areaX = xsVectorGetX(areaCenter);
            areaZ = xsVectorGetZ(areaCenter);
            dx = mainX - areaX;
            dz = mainZ - areaZ;
            if ((dx > otherBaseWallRadius) || (dx < -1.0*otherBaseWallRadius)
             || (dz > otherBaseWallRadius) || (dz < -1.0*otherBaseWallRadius))
            {
                needToSave = false;
            }

            // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
            if (needToSave == true)
            {
                bool found =false;
                for (j = 0; < numAreasAdded)
                {
                    if (aiPlanGetVariableInt(otherBase3WallTeamPlanID, cBuildWallPlanAreaIDs, j) == firstRingID)
                    {
                        found = true;     // It's in there, don't add it
                    }
                }
                if ((found == false) && (numAreasAdded < 20))  // add it
                {
                    aiPlanSetVariableInt(otherBase3WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
                    numAreasAdded = numAreasAdded + 1;
                }
            }
        }
/*
        aiEcho("    Area list:");
        for (l = 0; < numAreasAdded)
            aiEcho("        "+aiPlanGetVariableInt(otherBase3WallTeamPlanID, cBuildWallPlanAreaIDs, l));
*/
        // Set the true number of area variables, preserving existing values, then turn on the plan
        aiPlanSetNumberVariableValues(otherBase3WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

        aiPlanSetVariableInt(otherBase3WallTeamPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
//        aiPlanAddUnitType(otherBase3WallTeamPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanAddUnitType(otherBase3WallTeamPlanID, builderType, 1, 1, 1);
        aiPlanSetVariableInt(otherBase3WallTeamPlanID, cBuildWallPlanNumberOfGates, 0, 40);
        aiPlanSetVariableFloat(otherBase3WallTeamPlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
        aiPlanSetBaseID(otherBase3WallTeamPlanID, gOtherBase3ID);
        aiPlanSetEscrowID(otherBase3WallTeamPlanID, cMilitaryEscrowID);
        aiPlanSetDesiredPriority(otherBase3WallTeamPlanID, 100);
        aiPlanSetActive(otherBase3WallTeamPlanID, true);
        gOtherBase3RingWallTeamPlanID = otherBase3WallTeamPlanID;
        xsSetRuleMinIntervalSelf(83);
    }
}

//==============================================================================
rule otherBase4RingWallTeam
    minInterval 11 //starts in cAge2, activated in otherBasesDefPlans rule
    inactive
{
    aiEcho("otherBase4RingWallTeam:");
    
    float goldSupply = kbResourceGet(cResourceGold);
    
	if (aiGetWorldDifficulty() < cDifficultyNightmare)
	gOtherBaseWallRadius = 19;
	
    //If we already have a build wall plan, don't make another one.
    int wallPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true);
    int activeWallPlans = aiPlanGetNumber(cPlanBuildWall, -1, true);

    if (wallPlanID >= 0)
    {
        for (i = 0; < activeWallPlans)
        {
            int wallPlanIndexID = aiPlanGetIDByIndex(cPlanBuildWall, -1, true, i);
            if (wallPlanIndexID == gOtherBase4RingWallTeamPlanID)
            {
                static int otherBase4RingWallTeamStartTime = -1;
                if (otherBase4RingWallTeamStartTime < 0)
                    otherBase4RingWallTeamStartTime = xsGetTime();
                
                if (goldSupply < 100)
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase4RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(23);
                    return;
                }
                
                //destroy the plan if it has been active for more than 12 minutes
                if ((xsGetTime() > (otherBase4RingWallTeamStartTime + 12*60*1000)))
                {
                    aiPlanDestroy(wallPlanIndexID);
                    otherBase4RingWallTeamStartTime = -1;
                    xsSetRuleMinIntervalSelf(61);
                    return;
                }

                //Get the enemies near my base
                int numEnemyUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase4ID, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
                int myUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase4ID, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
                int alliedUnitsNearBase = kbBaseGetNumberUnits(cMyID, gOtherBase4ID, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);

                //Get the time under attack.
                int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, gOtherBase4ID);
                if (secondsUnderAttack > 20)
                {
                    //Destroy the plan if there are twice as many enemies as my units 
                    if ((numEnemyUnitsNearBase > 2 * (myUnitsNearBase + alliedUnitsNearBase)) && (numEnemyUnitsNearBase > 4))
                    {
                        aiPlanDestroy(wallPlanIndexID);
                        otherBase4RingWallTeamStartTime = -1;
                        xsSetRuleMinIntervalSelf(61);
                        return;
                    }
                }

                return;
            }
        }
    }

    if (goldSupply < 150)
        return;    

    float otherBaseWallRadius = gOtherBaseWallRadius;
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    int otherBase4WallTeamPlanID = aiPlanCreate("otherBase4WallTeamPlanID", cPlanBuildWall);
    if (otherBase4WallTeamPlanID != -1)
    {
        aiPlanSetNumberVariableValues(otherBase4WallTeamPlanID, cBuildWallPlanAreaIDs, 20, true);
        int numAreasAdded = 0;

        int mainArea = -1;
        vector mainCenter = kbBaseGetLocation(cMyID, gOtherBase4ID);
        aiPlanSetInitialPosition(otherBase4WallTeamPlanID, mainCenter);
        
        float mainX = xsVectorGetX(mainCenter);
        float mainZ = xsVectorGetZ(mainCenter);
        mainArea = kbAreaGetIDByPosition(mainCenter);
        aiPlanSetVariableInt(otherBase4WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
        numAreasAdded = numAreasAdded + 1;
      
        int firstRingCount = -1;      // How many areas are in first ring around main?
        int firstRingIndex = -1;      // Which one are we on?
        int firstRingID = -1;         // Actual ID of current 1st ring area
        vector areaCenter = cInvalidVector;    // Center point of this area
        float areaX = 0.0;
        float dx = 0.0;
        float areaZ = 0.0;
        float dz = 0.0;
        bool needToSave = false;

        firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
        for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
        {
            needToSave = true;            // We'll save this unless we have a problem
            firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
            areaCenter = kbAreaGetCenter(firstRingID);
            // Now, do the checks.
            areaX = xsVectorGetX(areaCenter);
            areaZ = xsVectorGetZ(areaCenter);
            dx = mainX - areaX;
            dz = mainZ - areaZ;
            if ((dx > otherBaseWallRadius) || (dx < -1.0*otherBaseWallRadius)
             || (dz > otherBaseWallRadius) || (dz < -1.0*otherBaseWallRadius))
            {
                needToSave = false;
            }

            // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
            if (needToSave == true)
            {
                bool found = false;
                for (j = 0; < numAreasAdded)
                {
                    if (aiPlanGetVariableInt(otherBase4WallTeamPlanID, cBuildWallPlanAreaIDs, j) == firstRingID)
                    {
                        found = true;     // It's in there, don't add it
                    }
                }
                if ((found == false) && (numAreasAdded < 20))  // add it
                {
                    aiPlanSetVariableInt(otherBase4WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
                    numAreasAdded = numAreasAdded + 1;
                }
            }
        }
/*
        aiEcho("    Area list:");
        for (l = 0; < numAreasAdded)
            aiEcho("        "+aiPlanGetVariableInt(otherBase4WallTeamPlanID, cBuildWallPlanAreaIDs, l));
*/
        // Set the true number of area variables, preserving existing values, then turn on the plan
        aiPlanSetNumberVariableValues(otherBase4WallTeamPlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

        aiPlanSetVariableInt(otherBase4WallTeamPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
//        aiPlanAddUnitType(otherBase4WallTeamPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanAddUnitType(otherBase4WallTeamPlanID, builderType, 1, 1, 1);
        aiPlanSetVariableInt(otherBase4WallTeamPlanID, cBuildWallPlanNumberOfGates, 0, 40);
        aiPlanSetVariableFloat(otherBase4WallTeamPlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 12.0);
        aiPlanSetBaseID(otherBase4WallTeamPlanID, gOtherBase4ID);
        aiPlanSetEscrowID(otherBase4WallTeamPlanID, cMilitaryEscrowID);
        aiPlanSetDesiredPriority(otherBase4WallTeamPlanID, 100);
        aiPlanSetActive(otherBase4WallTeamPlanID, true);
        gOtherBase4RingWallTeamPlanID = otherBase4WallTeamPlanID;
        xsSetRuleMinIntervalSelf(83);
    }
}

//==============================================================================
rule buildSkyPassages
//    minInterval 28 //starts in cAge1
    minInterval 137 //starts in cAge1
    inactive
{
    aiEcho("buildSkyPassages:");
    
    // Make sure we have a sky passage at home, and one near the nearest TC of 
    // our Most Hated Player.  
    if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeSkyPassage, true) > -1)
        return;  // Quit if we're already building one

    if (kbBaseGetNumberUnits(cMyID, kbBaseGetMainID(cMyID), cPlayerRelationSelf, cUnitTypeSkyPassage) < 1)
    {  
        // We don't have one...make sure we have a plan in the works
        int planID=aiPlanCreate("BuildLocalSkyPassage", cPlanBuild);
        if (planID < 0)
            return;
        aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeSkyPassage);
        aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 0, kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))));
        aiPlanSetDesiredPriority(planID, 70);
        aiPlanSetMilitary(planID, true);
        aiPlanSetEconomy(planID, false);
        aiPlanSetEscrowID(planID, cMilitaryEscrowID);
        aiPlanAddUnitType(planID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
        aiPlanSetActive(planID);

        return;  // Don't start second until first is done
    }

/* disabled for now
    // Local base is covered, now let's check near our Most Hated Player's TC
    static int nearestMhpTCQueryID = -1;
    if (nearestMhpTCQueryID < 0)
    {
        nearestMhpTCQueryID = kbUnitQueryCreate("MostHatedPlayerTC");
    }
    kbUnitQuerySetPlayerID(nearestMhpTCQueryID, aiGetMostHatedPlayerID());
    kbUnitQuerySetUnitType(nearestMhpTCQueryID, cUnitTypeAbstractSettlement);
    kbUnitQuerySetState(nearestMhpTCQueryID, cUnitStateAliveOrBuilding);
    kbUnitQuerySetPosition(nearestMhpTCQueryID, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
    kbUnitQuerySetAscendingSort(nearestMhpTCQueryID, true);

    kbUnitQueryResetResults(nearestMhpTCQueryID);
    int numTCs = kbUnitQueryExecute(nearestMhpTCQueryID);
    if (numTCs < 1)
        return;  // No enemy TCs
    int enemyTC = kbUnitQueryGetResult(nearestMhpTCQueryID, aiRandInt(numTCs));   // ID of enemy TC we want to search, random selection
    vector enemyTCvec=cInvalidVector;
    enemyTCvec = kbUnitGetPosition(enemyTC);


    // We now know the nearest enemyTC, let's look for a sky passage near there
    static int skyPassageQueryID = -1;
    if (skyPassageQueryID < 0)
    {
        skyPassageQueryID = kbUnitQueryCreate("RemoteSkyPassage");
        kbUnitQuerySetPlayerID(skyPassageQueryID, cMyID);
        kbUnitQuerySetUnitType(skyPassageQueryID, cUnitTypeSkyPassage);
        kbUnitQuerySetState(skyPassageQueryID, cUnitStateAliveOrBuilding);
        kbUnitQuerySetMaximumDistance(skyPassageQueryID, 80.0);
    }
    kbUnitQuerySetPosition(skyPassageQueryID, enemyTCvec);
    kbUnitQueryResetResults(skyPassageQueryID);
    if (kbUnitQueryExecute(skyPassageQueryID) < 1)
    {  
        // None found, we need one...and we don't have an active plan.
        // First, pick a center location on our side of the enemy TC
        vector offset = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)) - enemyTCvec;
        offset = xsVectorNormalize(offset);
        vector target = enemyTCvec + (offset * 60.0);
      

        // Now, check if that's on ground, and just give up if it isn't
//        int targetArea = kbAreaGetIDByPosition(target);
//        if ( (kbAreaGetType(targetArea) == cAreaTypeWater) || (kbAreaGetType(targetArea) == cAreaTypeImpassableLand) )
//            return;
        // Figure out if it's on our enemy's areaGroup.  If not, step 5% closer until it is.
        int enemyAreaGroup = -1;
        int testAreaGroup = -1;
        testAreaGroup = kbAreaGroupGetIDByPosition(target);
        enemyAreaGroup = kbAreaGroupGetIDByPosition(enemyTCvec);


//        vector towardEnemy = offset * -5.0;    // 5m away from me, toward enemy TC
        vector towardEnemy = offset * -10.0;    // 10m away from me, toward enemy TC
        bool success = false;

//        for (i=0; <18)    // Keep testing until areaGroups match
        for (i = 0; < 9)    // Keep testing until areaGroups match
        {
            testAreaGroup = kbAreaGroupGetIDByPosition(target);
            if (testAreaGroup == enemyAreaGroup)
            {
                success = true;
                break;
            }
            else
            {
                target = target + towardEnemy;   // Try a bit closer
            }
        }
  

        // We have a target and it's on land...
        int remotePlanID=aiPlanCreate("BuildRemoteSkyPassage", cPlanBuild);
        if (remotePlanID < 0)
            return;
        aiPlanSetVariableInt(remotePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSkyPassage);
        aiPlanSetVariableInt(remotePlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(target));
        aiPlanSetVariableInt(remotePlanID, cBuildPlanNumAreaBorderLayers, 0, 1);
        aiPlanSetDesiredPriority(remotePlanID, 70);
        aiPlanSetMilitary(remotePlanID, true);
        aiPlanSetEconomy(remotePlanID, false);
        aiPlanSetEscrowID(remotePlanID, cMilitaryEscrowID);
        aiPlanAddUnitType(remotePlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanSetActive(remotePlanID);
    }
*/
}

//==============================================================================
rule buildFortress
    minInterval 19 //starts in cAge3
    inactive
{
    aiEcho("buildFortress:");

    if ((kbGetAge() > cAge3) && (gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) < cTechStatusResearching))
        return;
        
    float currentFood = kbResourceGet(cResourceFood);
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);
    float currentFavor = kbResourceGet(cResourceFavor);

    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
//    if (numSettlements <= 2)
    if (numSettlements < 2)
        xsSetRuleMinIntervalSelf(61);
    else
        xsSetRuleMinIntervalSelf(19);

    int bigBuildingID = cUnitTypeMigdolStronghold;
    if (cMyCulture == cCultureGreek)
        bigBuildingID = cUnitTypeFortress;
    else if (cMyCulture == cCultureNorse)
        bigBuildingID = cUnitTypeHillFort;
    else if (cMyCulture == cCultureAtlantean)
        bigBuildingID = cUnitTypePalace;	
    else if (cMyCulture == cCultureChinese)
        bigBuildingID = cUnitTypeCastle;		

    int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
    if (numFortresses >= kbGetBuildLimit(cMyID, bigBuildingID))
        return;

    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
        vector location = kbUnitGetPosition(otherBaseUnitID);
        aiEcho("location: "+location);
        
        bool planActive = false;
        int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
        if (activeBuildPlans > 0)
        {
            for (i = 0; < activeBuildPlans)
            {
                int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
                if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == bigBuildingID)
                {
                    aiEcho("buildPlanIndexID: "+buildPlanIndexID);
                    vector buildPlanCenterPos = aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0);
                    aiEcho("buildPlanCenterPos: "+buildPlanCenterPos);
                    if ((aiPlanGetBaseID(buildPlanIndexID) == otherBaseID) || (equal(location, buildPlanCenterPos) == true))
                    {
                        planActive = true;
                    }
                    
                    int enemySettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, buildPlanCenterPos, 15.0);
                    int motherNatureSettlementAtBuildPlanPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, buildPlanCenterPos, 15.0);
                    enemySettlementAtBuildPlanPos = enemySettlementAtBuildPlanPos - motherNatureSettlementAtBuildPlanPos;
                    int alliedSettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, buildPlanCenterPos, 15.0);
                    if ((enemySettlementAtBuildPlanPos > 0) || (alliedSettlementAtBuildPlanPos > 0))
                    {
                        aiEcho("destroying fortressBuildPlan as an enemy or an ally has built a settlement at the cBuildPlanCenterPosition");
                        aiPlanDestroy(buildPlanIndexID);
                    }
                }
            }
        }
        
        aiEcho("planActive: "+planActive);
        
        
        if (planActive == true)
        {
            aiEcho("plan to build fortress at otherBaseID "+otherBaseID+" already exists, returning");
            return;
        }
        
        if ((currentFood > 700) && (currentGold > 700) && (kbGetAge() == cAge3))
            return;        
        
        if (otherBaseID != mainBaseID)
        {
            int numFortressesNearOtherBase = getNumUnits(bigBuildingID, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
            float requiredResource = 450.0;
            if (kbGetAge() > cAge3)
                requiredResource = 350;
            if ((currentWood < requiredResource) || (currentGold < requiredResource) || (currentFavor < 15))
            {
                aiEcho("buildFortress: not enough resources");
                return;
            }
            
            //return, if there's already a fortress near other base 
            if (numFortressesNearOtherBase > 3)
                return;
            
            float buffer = 40.0;
            if (cRandomMapName == "jotunheim")
                buffer = 40.0;
            
            int numTreesAliveInR20 = getNumUnits(cUnitTypeTree, cUnitStateAlive, -1, 0, location, 20.0);
            int numWoodAliveInR20 = getNumUnits(cUnitTypeWood, cUnitStateAlive, -1, 0, location, 20.0);
            int numTreesDeadInR20 = getNumUnits(cUnitTypeTree, cUnitStateDead, -1, 0, location, 20.0);
            int numWoodDeadInR20 = getNumUnits(cUnitTypeWood, cUnitStateDead, -1, 0, location, 20.0);
            float woodAmountInR20 = kbGetAmountValidResources(otherBaseID, cResourceWood, cAIResourceSubTypeEasy, 20.0);
            

            
            
            if ((xsVectorGetX(location) < buffer) || (xsVectorGetZ(location) < buffer)
             || (xsVectorGetX(location) > kbGetMapXSize() - buffer)
             || (xsVectorGetZ(location) > kbGetMapZSize() - buffer)
//             || (numTreesAliveInR20 > 0) || (numTreesDeadInR20 > 0))    //cUnitStateDead doesn't work properly with cUnitTypeTree
//             || (numWoodAliveInR20 > 0) || (numWoodDeadInR20 > 0))  //cUnitStateDead doesn't work properly with cUnitTypeWood
             || (numTreesAliveInR20 > 1) || (woodAmountInR20 > 150))
            {
                int building1ID = -1;
                if (cMyCulture == cCultureEgyptian)
                    building1ID = cUnitTypeBarracks;
                else if (cMyCulture == cCultureGreek)
                    building1ID = cUnitTypeStable;
                else if (cMyCulture == cCultureNorse)
                    building1ID = cUnitTypeLonghouse;
                else if (cMyCulture == cCultureAtlantean)
                    building1ID = cUnitTypeBarracksAtlantean;
                else if (cMyCulture == cCultureChinese)
                    building1ID = cUnitTypeStableChinese;					
                int numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
                if (numBuilding1NearBase > 3)
                    return;
                    
                if (cMyCulture == cCultureGreek)
                {
                    int numTemplesNearBase = getNumUnits(cUnitTypeTemple, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
                    if (numTemplesNearBase > 1)
                        return;
                }
                else if (cMyCiv == cCivOuranos)
                {
                    int numSkyPassagesNearBase = getNumUnits(cUnitTypeSkyPassage, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
                    if (numSkyPassagesNearBase > 1)
                        return;
                }
            }
        }
        else
        {
            int numFortressesNearMainBase = getNumUnits(bigBuildingID, cUnitStateAliveOrBuilding, -1, cMyID, location, 60.0);
            if (numFortressesNearMainBase > 5)
            {
                return;
            }
            if (((currentWood < 800) || (currentGold < 800) || (currentFavor < 25)) && (numFortressesNearMainBase > 2))
            {
                return;
            }
            else if (((currentWood < 600) || (currentGold < 600) || (currentFavor < 20)) && (numFortressesNearMainBase < 3) && (numFortressesNearMainBase > 0))
            {
                return;
            }
            
            if (aiRandInt(2) < 1)
                return;
        }
    }	

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    int numBuilders = kbUnitCount(cMyID, builderType, cUnitStateAlive);
    
    //Over time, we will find out what areas are good and bad to build in.
    //Use that info here, because we want to protect houses.
    int planID = aiPlanCreate("BuildMoreFortresses", cPlanBuild);
    if (planID >= 0)
    {
        aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, bigBuildingID);
        aiPlanSetVariableInt(planID, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetBaseID(planID, otherBaseID);
        aiPlanSetDesiredPriority(planID, 100);
        if ((cMyCulture == cCultureAtlantean) || (numBuilders < 20))
            aiPlanAddUnitType(planID, builderType, 1, 1, 1);
        else
            aiPlanAddUnitType(planID, builderType, 3, 3, 3);
        
        aiPlanSetEscrowID(planID, cMilitaryEscrowID);
        
        aiPlanSetInitialPosition(planID, location);

        //variables for our fortress placing
        vector frontVector = kbBaseGetFrontVector(cMyID, otherBaseID);
        float fx = xsVectorGetX(frontVector);
        float fz = xsVectorGetZ(frontVector);
        
        if (otherBaseID == mainBaseID)
        {
            aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
            int desiredNumFortresses = 1;
            if (xsGetTime() < 30*60*1000)
                desiredNumFortresses = 0;
            if ((numFortressesNearMainBase > desiredNumFortresses) && (kbGetAge() < cAge4))
                return;
            
            fx = fx * 15;
            fz = fz * 15;

            frontVector = xsVectorSetX(frontVector, fx);
            frontVector = xsVectorSetZ(frontVector, fz);
            frontVector = xsVectorSetY(frontVector, 0.0);
            
            location = location + frontVector;
            aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
            if (kbGetAge() > cAge3)
                aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 50.0);
            else
                aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 40.0);
            aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 10000.0);
            aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 5.0);
        }
        else
        {
            aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
            aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, location);
            aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 11.0);          
            aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 0.0);
        }
        
        aiPlanSetActive(planID);
        aiEcho("buildFortress: attempting to build at base: #"+otherBaseID);
    }
}

//==============================================================================
rule buildTowerAtOtherBase
//    minInterval 60 //starts in cAge2
    minInterval 61 //starts in cAge2
    inactive
{
    aiEcho("buildTowerAtOtherBase: ");

    int numTowers = kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
    
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false) && (numTowers > 0))
        return;
        
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);
    float currentFood = kbResourceGet(cResourceFood);

    if (((currentFood > 560) && (currentGold > 350) && (kbGetAge() == cAge2))
     || ((currentFood > 700) && (currentGold > 700) && (kbGetAge() == cAge3)))
        return;
    
    int towerLimit = kbGetBuildLimit(cMyID, cUnitTypeTower);
    if (numTowers >= towerLimit)
        return;

    if ((numTowers > 20) && (kbGetAge() == 2))
        return;

    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (numSettlements < 2)
        xsSetRuleMinIntervalSelf(61);
    else
        xsSetRuleMinIntervalSelf(31);

    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
        vector otherBaseLocation = kbUnitGetPosition(otherBaseUnitID);

        int numTowersNearBase = getNumUnits(cUnitTypeTower, cUnitStateAliveOrBuilding, -1, cMyID, otherBaseLocation, 30.0);

        if (otherBaseID == mainBaseID)
        {
            aiEcho("otherBaseID == mainBaseID, returning");
            return;
        }
    }

    int baseID = -1;
    if (otherBaseID != mainBaseID)
    {
        //return, if more than 2 towers near other base 
        aiEcho("numTowersNearBase #"+otherBaseID+": "+numTowersNearBase);
        if ((numTowersNearBase > 1) && (kbGetAge() == cAge2))
            return;
        else if (numTowersNearBase > 4)
            return;

        baseID = otherBaseID;
        aiEcho("building tower at base: #"+otherBaseID);
    }
    
    bool planActive = false;
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeTower)
            {
                aiEcho("buildPlanIndexID: "+buildPlanIndexID);
                vector buildPlanCenterPos = aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0);
                aiEcho("buildPlanCenterPos: "+buildPlanCenterPos);
                if ((aiPlanGetBaseID(buildPlanIndexID) == otherBaseID) || (equal(otherBaseLocation, buildPlanCenterPos) == true))
                {
                    planActive = true;
                }
                    
                int enemySettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, buildPlanCenterPos, 15.0);
                int motherNatureSettlementAtBuildPlanPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, buildPlanCenterPos, 15.0);
                enemySettlementAtBuildPlanPos = enemySettlementAtBuildPlanPos - motherNatureSettlementAtBuildPlanPos;
                int alliedSettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, buildPlanCenterPos, 15.0);
                if ((enemySettlementAtBuildPlanPos > 0) || (alliedSettlementAtBuildPlanPos > 0))
                {
                    aiEcho("destroying towerBuildPlan as an enemy or an ally has built a settlement at the cBuildPlanCenterPosition");
                    aiPlanDestroy(buildPlanIndexID);
                }
            }
        }
    }
    
    aiEcho("planActive: "+planActive);
    
    
    if (planActive == true)
    {
        aiEcho("plan to build tower at otherBaseID "+otherBaseID+" already exists, returning");
        return;
    }
    
    if ((numTowersNearBase < 1) && ((currentWood < 300) || (currentGold < 200)))
        return;
    else if ((currentWood < 500) || (currentGold < 300))
        return;

    //variables for our tower placing
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
        
    //Build a tower near our other base
    numTowersNearBase = numTowersNearBase + 1;
    int buildTowerAtOtherBasePlanID = aiPlanCreate("buildTowerAtOtherBase: tower #"+numTowersNearBase, cPlanBuild);
    if (buildTowerAtOtherBasePlanID >= 0)
    {
        aiPlanSetInitialPosition(buildTowerAtOtherBasePlanID, otherBaseLocation);
        aiPlanSetVariableInt(buildTowerAtOtherBasePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTower);
        aiPlanSetVariableInt(buildTowerAtOtherBasePlanID, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetDesiredPriority(buildTowerAtOtherBasePlanID, 100);
        aiPlanSetVariableBool(buildTowerAtOtherBasePlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildTowerAtOtherBasePlanID, cBuildPlanRandomBPValue, 0, 0.99);
        
        aiPlanSetVariableVector(buildTowerAtOtherBasePlanID, cBuildPlanCenterPosition, 0, otherBaseLocation);
//        aiPlanSetVariableFloat(buildTowerAtOtherBasePlanID, cBuildPlanCenterPositionDistance, 0, 14.0);
        aiPlanSetVariableFloat(buildTowerAtOtherBasePlanID, cBuildPlanCenterPositionDistance, 0, 13.0);
        aiPlanAddUnitType(buildTowerAtOtherBasePlanID, builderType, 1, 1, 1);
        aiPlanSetEscrowID(buildTowerAtOtherBasePlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(buildTowerAtOtherBasePlanID, baseID);
        aiPlanSetActive(buildTowerAtOtherBasePlanID);
        aiEcho("building tower at our other base: "+otherBaseID+" near otherBaseLocation: "+otherBaseLocation);
    }
}

//==============================================================================
rule buildBuildingsAtOtherBase
//    minInterval 30 //starts in cAge2
    minInterval 31 //starts in cAge2
    inactive
{	
    aiEcho("buildBuildingsAtOtherBase:");
 
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
    if ((woodSupply < 200) || (goldSupply < 120))
        return;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID=kbUnitGetBaseID(otherBaseUnitID);
        if (otherBaseID == mainBaseID)
        {
            aiEcho("otherBaseID == mainBaseID, returning");
            return;
        }
    }
    
    int building1ID = -1;
    if (cMyCulture == cCultureEgyptian)
        building1ID = cUnitTypeBarracks;
    else if (cMyCulture == cCultureGreek)
        building1ID = cUnitTypeStable;
    else if (cMyCulture == cCultureNorse)
        building1ID = cUnitTypeLonghouse;
    else if (cMyCulture == cCultureAtlantean)
        building1ID = cUnitTypeCounterBuilding;
    else if (cMyCulture == cCultureChinese)
        building1ID = cUnitTypeStableChinese;	
	
        
    vector location = kbUnitGetPosition(otherBaseUnitID);
    aiEcho("location: "+location);

    //return if we already have a building1 at the other base
    int numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
//    if ((cMyCiv == cCivHades) || (cMyCiv == cCivZeus))
    if (cMyCulture == cCultureGreek)
    {
        if ((gTransportMap == false) || (numBuilding1NearBase > 0))
        {
            building1ID = cUnitTypeTemple;
            int numTemplesNearBase = getNumUnits(building1ID, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
            if (numTemplesNearBase > 0)
                return;
        }
        else
        {
            if (numBuilding1NearBase > 0)
                return;
        }
    }
    else if (cMyCiv == cCivOuranos)
    {
        if ((gTransportMap == false) || (numBuilding1NearBase > 0))
        {
            building1ID = cUnitTypeSkyPassage;
            int numSkyPassagesNearBase = getNumUnits(building1ID, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
            if (numSkyPassagesNearBase > 0)
                return;
        }
        else
        {
            if (numBuilding1NearBase > 0)
                return;
        }
    }
    else
    {
        if (numBuilding1NearBase > 0)
            return;
    }
    
    float buffer = 20.0;
    if (cRandomMapName == "jotunheim")
        buffer = 40.0;
    
    int numTreesAliveInR20 = getNumUnits(cUnitTypeTree, cUnitStateAlive, -1, 0, location, 20.0);
    int numWoodAliveInR20 = getNumUnits(cUnitTypeWood, cUnitStateAlive, -1, 0, location, 20.0);
    int numTreesDeadInR20 = getNumUnits(cUnitTypeTree, cUnitStateDead, -1, 0, location, 20.0);
    int numWoodDeadInR20 = getNumUnits(cUnitTypeWood, cUnitStateDead, -1, 0, location, 20.0);
    float woodAmountInR20 = kbGetAmountValidResources(otherBaseID, cResourceWood, cAIResourceSubTypeEasy, 20.0);
    
    aiEcho("numTreesAliveInR20: "+numTreesAliveInR20);
    aiEcho("numWoodAliveInR20: "+numWoodAliveInR20);
    aiEcho("numTreesDeadInR20: "+numTreesDeadInR20);
    aiEcho("numWoodDeadInR20: "+numWoodDeadInR20);
    aiEcho("woodAmountInR20: "+woodAmountInR20);
   
    
    if ((xsVectorGetX(location) < buffer) || (xsVectorGetZ(location) < buffer)
     || (xsVectorGetX(location) > kbGetMapXSize() - buffer)
     || (xsVectorGetZ(location) > kbGetMapZSize() - buffer)
//     || (numTreesAliveInR20 > 0) || (numTreesDeadInR20 > 0))    //cUnitStateDead doesn't work properly with cUnitTypeTrees
//     || (numWoodAliveInR20 > 0) || (numWoodDeadInR20 > 0))  //cUnitStateDead doesn't work properly with cUnitTypeWood
     || (numTreesAliveInR20 > 1) || (woodAmountInR20 > 150))
    {
        int numFortressesNearOtherBase = getNumUnits(cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
        if (numFortressesNearOtherBase > 0)
            return;
    }
    
    bool planActive = false;
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == building1ID)
            {
                aiEcho("buildPlanIndexID: "+buildPlanIndexID);
                vector buildPlanCenterPos = aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0);
                aiEcho("buildPlanCenterPos: "+buildPlanCenterPos);
                if ((aiPlanGetBaseID(buildPlanIndexID) == otherBaseID) || (equal(location, buildPlanCenterPos) == true))
                {
                    planActive = true;
                }
                    
                int enemySettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, buildPlanCenterPos, 15.0);
                int motherNatureSettlementAtBuildPlanPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, buildPlanCenterPos, 15.0);
                enemySettlementAtBuildPlanPos = enemySettlementAtBuildPlanPos - motherNatureSettlementAtBuildPlanPos;
                int alliedSettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, buildPlanCenterPos, 15.0);
                if ((enemySettlementAtBuildPlanPos > 0) || (alliedSettlementAtBuildPlanPos > 0))
                {
                    aiEcho("destroying building1BuildPlan as an enemy or an ally has built a settlement at the cBuildPlanCenterPosition");
                    aiPlanDestroy(buildPlanIndexID);
                }
            }
        }
    }
    
    aiEcho("planActive: "+planActive);
    
    
    if (planActive == true)
    {
        aiEcho("plan to build building1ID at otherBaseID "+otherBaseID+" already exists, returning");
        return;
    }

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;

    //Force building #1 to go down.
    int buildBuilding1AtOtherBasePlanID = aiPlanCreate("buildBuilding1AtOtherBase", cPlanBuild);
    if (buildBuilding1AtOtherBasePlanID >= 0)
    {
        aiPlanSetInitialPosition(buildBuilding1AtOtherBasePlanID, location);
        aiPlanSetVariableInt(buildBuilding1AtOtherBasePlanID, cBuildPlanBuildingTypeID, 0, building1ID);
        aiPlanSetVariableInt(buildBuilding1AtOtherBasePlanID, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetVariableBool(buildBuilding1AtOtherBasePlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanRandomBPValue, 0, 0.99);
        
        aiPlanSetVariableVector(buildBuilding1AtOtherBasePlanID, cBuildPlanCenterPosition, 0, location);
        if (building1ID == cUnitTypeTemple)
            aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanCenterPositionDistance, 0, 11.0);
        else if (building1ID == cUnitTypeSkyPassage)
            aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanCenterPositionDistance, 0, 9.0);
        else
            aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanCenterPositionDistance, 0, 10.0);
        aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanBuildingBufferSpace, 0, 0.0);

        aiPlanSetDesiredPriority(buildBuilding1AtOtherBasePlanID, 100);
        aiPlanAddUnitType(buildBuilding1AtOtherBasePlanID, builderType, 1, 1, 1);
        aiPlanSetEscrowID(buildBuilding1AtOtherBasePlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(buildBuilding1AtOtherBasePlanID, otherBaseID);
        aiPlanSetActive(buildBuilding1AtOtherBasePlanID);
        gBuildBuilding1AtOtherBasePlanID = buildBuilding1AtOtherBasePlanID;	
        aiEcho("buildBuilding1AtOtherBasePlan set active: "+gBuildBuilding1AtOtherBasePlanID);
    }
}

rule buildBuildingsAtOtherBase2
    minInterval 31 //starts in cAge2
    inactive
{	
    aiEcho("buildBuildingsAtOtherBase2:");
	if (aiGetWorldDifficulty() < cDifficultyNightmare && kbGetAge() < 3)
	return; // Wait untill age 3 for Hard difficulty and lower.
 
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
    if ((woodSupply < 200) || (goldSupply < 120))
        return;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID=kbUnitGetBaseID(otherBaseUnitID);
        if (otherBaseID == mainBaseID)
        {
            aiEcho("otherBaseID == mainBaseID, returning");
            return;
        }
    }
    
    int building1ID = -1;
    if (cMyCulture == cCultureEgyptian)
        building1ID = cUnitTypeBarracks;
    else if (cMyCulture == cCultureGreek)
	{
	int RandomBuilding = aiRandInt(3);
	            if (RandomBuilding == 0)
                building1ID = cUnitTypeAcademy;
            else if (RandomBuilding == 1)
                building1ID = cUnitTypeArcheryRange;
            else if (RandomBuilding == 2)
                building1ID = cUnitTypeStable;
	}
    else if (cMyCulture == cCultureNorse)
        building1ID = cUnitTypeLonghouse;
    else if (cMyCulture == cCultureAtlantean)
        building1ID = cUnitTypeBarracksAtlantean;
    else if (cMyCulture == cCultureChinese)
        building1ID = cUnitTypeBarracksChinese;	
	
        
    vector location = kbUnitGetPosition(otherBaseUnitID);
    aiEcho("location: "+location);

    //return if we already have a building1 at the other base
    int numBuilding1NearBase = getNumUnits(building1ID, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);

	

            if (numBuilding1NearBase > 2 && cMyCulture != cCultureGreek)
                return;
				
	            if (numBuilding1NearBase > 1 && cMyCulture == cCultureGreek)
                return;			
   
    
    float buffer = 40.0;
    if (cRandomMapName == "jotunheim")
        buffer = 40.0;
    
    int numTreesAliveInR20 = getNumUnits(cUnitTypeTree, cUnitStateAlive, -1, 0, location, 20.0);
    int numWoodAliveInR20 = getNumUnits(cUnitTypeWood, cUnitStateAlive, -1, 0, location, 20.0);
    int numTreesDeadInR20 = getNumUnits(cUnitTypeTree, cUnitStateDead, -1, 0, location, 20.0);
    int numWoodDeadInR20 = getNumUnits(cUnitTypeWood, cUnitStateDead, -1, 0, location, 20.0);
    float woodAmountInR20 = kbGetAmountValidResources(otherBaseID, cResourceWood, cAIResourceSubTypeEasy, 20.0);
    

 
    
    if ((xsVectorGetX(location) < buffer) || (xsVectorGetZ(location) < buffer)
     || (xsVectorGetX(location) > kbGetMapXSize() - buffer)
     || (xsVectorGetZ(location) > kbGetMapZSize() - buffer)
     || (numTreesAliveInR20 > 1) || (woodAmountInR20 > 150))
    {
        int numFortressesNearOtherBase = getNumUnits(cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding, -1, cMyID, location, 30.0);
        if (numFortressesNearOtherBase > 2)
            return;
    }
    
    bool planActive = false;
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == building1ID)
            {
                aiEcho("buildPlanIndexID: "+buildPlanIndexID);
                vector buildPlanCenterPos = aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0);
                aiEcho("buildPlanCenterPos: "+buildPlanCenterPos);
                if ((aiPlanGetBaseID(buildPlanIndexID) == otherBaseID) || (equal(location, buildPlanCenterPos) == true))
                {
                    planActive = true;
                }
                    
                int enemySettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, buildPlanCenterPos, 15.0);
                int motherNatureSettlementAtBuildPlanPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, buildPlanCenterPos, 15.0);
                enemySettlementAtBuildPlanPos = enemySettlementAtBuildPlanPos - motherNatureSettlementAtBuildPlanPos;
                int alliedSettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, buildPlanCenterPos, 15.0);
                if ((enemySettlementAtBuildPlanPos > 0) || (alliedSettlementAtBuildPlanPos > 0))
                {
                    aiEcho("destroying building1BuildPlan as an enemy or an ally has built a settlement at the cBuildPlanCenterPosition");
                    aiPlanDestroy(buildPlanIndexID);
                }
            }
        }
    }
    
    aiEcho("planActive: "+planActive);
    
    
    if (planActive == true)
    {
        aiEcho("plan to build building1ID at otherBaseID "+otherBaseID+" already exists, returning");
        return;
    }

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;

    //Force building #1 to go down.
    int buildBuilding1AtOtherBasePlanID = aiPlanCreate("buildBuilding1AtOtherBase", cPlanBuild);
    if (buildBuilding1AtOtherBasePlanID >= 0)
    {
        aiPlanSetInitialPosition(buildBuilding1AtOtherBasePlanID, location);
        aiPlanSetVariableInt(buildBuilding1AtOtherBasePlanID, cBuildPlanBuildingTypeID, 0, building1ID);
        aiPlanSetVariableInt(buildBuilding1AtOtherBasePlanID, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetVariableBool(buildBuilding1AtOtherBasePlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanRandomBPValue, 0, 0.99);
        
        aiPlanSetVariableVector(buildBuilding1AtOtherBasePlanID, cBuildPlanCenterPosition, 0, location);
            aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanCenterPositionDistance, 0, 10.0);
        aiPlanSetVariableFloat(buildBuilding1AtOtherBasePlanID, cBuildPlanBuildingBufferSpace, 0, 0.0);

        aiPlanSetDesiredPriority(buildBuilding1AtOtherBasePlanID, 100);
        aiPlanAddUnitType(buildBuilding1AtOtherBasePlanID, builderType, 1, 1, 1);
        aiPlanSetEscrowID(buildBuilding1AtOtherBasePlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(buildBuilding1AtOtherBasePlanID, otherBaseID);
        aiPlanSetActive(buildBuilding1AtOtherBasePlanID);
        gBuildBuilding1AtOtherBasePlanID = buildBuilding1AtOtherBasePlanID;	
        aiEcho("buildBuilding1AtOtherBasePlan set active: "+gBuildBuilding1AtOtherBasePlanID);
    }
}



//==============================================================================
rule buildMirrorTower
    minInterval 29 //starts in cAge4
    inactive
{
    aiEcho("buildMirrorTower:");
    
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);

    int numMirrorTowers = kbUnitCount(cMyID, cUnitTypeTowerMirror, cUnitStateAliveOrBuilding);
    int buildMirrorTowerLimit = kbGetBuildLimit(cMyID, cUnitTypeTowerMirror);
    if (numMirrorTowers >= buildMirrorTowerLimit)
        return;

    if ((currentWood < 500) || (currentGold < 300))
        return;

    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
        vector otherBaseLocation = kbUnitGetPosition(otherBaseUnitID);

        int numMirrorTowersNearBase = getNumUnits(cUnitTypeTowerMirror, cUnitStateAliveOrBuilding, -1, cMyID, otherBaseLocation, 30.0);

        if (otherBaseID == mainBaseID)
        {
            aiEcho("otherBaseID == mainBaseID, returning");
            return;
        }
    }

    int baseID = -1;
    if (otherBaseID != mainBaseID)
    {
        //return, if there's at least 1 mirror tower near other base 
        aiEcho("numMirrorTowersNearBase #"+otherBaseID+": "+numMirrorTowersNearBase);
        if (numMirrorTowersNearBase > 0)
            return;

        baseID = otherBaseID;
        aiEcho("building mirror tower at base: #"+otherBaseID);
    }
    
    bool planActive = false;
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeTowerMirror)
            {
                aiEcho("buildPlanIndexID: "+buildPlanIndexID);
                vector buildPlanCenterPos = aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0);
                aiEcho("buildPlanCenterPos: "+buildPlanCenterPos);
                if ((aiPlanGetBaseID(buildPlanIndexID) == otherBaseID) || (equal(otherBaseLocation, buildPlanCenterPos) == true))
                {
                    planActive = true;
                }

                int enemySettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, buildPlanCenterPos, 15.0);
                int motherNatureSettlementAtBuildPlanPos = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, buildPlanCenterPos, 15.0);
                enemySettlementAtBuildPlanPos = enemySettlementAtBuildPlanPos - motherNatureSettlementAtBuildPlanPos;
                int alliedSettlementAtBuildPlanPos = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, buildPlanCenterPos, 15.0);
                if ((enemySettlementAtBuildPlanPos > 0) || (alliedSettlementAtBuildPlanPos > 0))
                {
                    aiEcho("destroying mirrorTowerBuildPlan as an enemy or an ally has built a settlement at the cBuildPlanCenterPosition");
                    aiPlanDestroy(buildPlanIndexID);
                }
            }
        }
    }
    
    aiEcho("planActive: "+planActive);
    

    if (planActive == true)
    {
        aiEcho("plan to build mirror tower at otherBaseID "+otherBaseID+" already exists, returning");
        return;
    }
        
    //Build a mirror tower near our other base
    static int count = 1;
    int buildMirrorTowerPlanID = aiPlanCreate("Build mirror tower #"+count, cPlanBuild);
    if (buildMirrorTowerPlanID >= 0)
    {
        aiPlanSetInitialPosition(buildMirrorTowerPlanID, otherBaseLocation);
        aiPlanSetVariableInt(buildMirrorTowerPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTowerMirror);
        aiPlanSetVariableInt(buildMirrorTowerPlanID, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetDesiredPriority(buildMirrorTowerPlanID, 100);
        aiPlanSetVariableBool(buildMirrorTowerPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildMirrorTowerPlanID, cBuildPlanRandomBPValue, 0, 0.99);
        
        aiPlanSetVariableVector(buildMirrorTowerPlanID, cBuildPlanCenterPosition, 0, otherBaseLocation);
//        aiPlanSetVariableFloat(buildMirrorTowerPlanID, cBuildPlanCenterPositionDistance, 0, 14.0);
        aiPlanSetVariableFloat(buildMirrorTowerPlanID, cBuildPlanCenterPositionDistance, 0, 13.0);
        aiPlanAddUnitType(buildMirrorTowerPlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanSetEscrowID(buildMirrorTowerPlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(buildMirrorTowerPlanID, baseID);
        aiPlanSetActive(buildMirrorTowerPlanID);
        count = count + 1;
        aiEcho("building mirror tower at our other base: "+otherBaseID+" near otherBaseLocation: "+otherBaseLocation);
    }
}

//==============================================================================
rule buildInitialTemple //and rebuild it if destroyed
    inactive
    minInterval 41 //starts in cAge1
{
    aiEcho("buildInitialTemple:");
    
    if (gTransportMap == true)
    {
        if ((gGatherGoalPlanID >= 0) && (cMyCulture == cCultureGreek))
        {
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 1);
            aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, 41, 1.0, kbBaseGetMainID(cMyID));
        }
        xsDisableSelf();
        return;
    }
    
    if (xsGetTime() < 60*1000)
        return;

    int mainBaseID = kbBaseGetMainID(cMyID);
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeTemple) && (aiPlanGetBaseID(buildPlanIndexID) == mainBaseID))
            {
                aiEcho("buildPlanIndexID: "+buildPlanIndexID);
                aiEcho("plan to build temple at mainBaseID "+mainBaseID+" already exists, returning");
                return;
            }
        }
    }
    
    static bool greekFavorActivated = false;
    vector location = kbBaseGetLocation(cMyID, mainBaseID);
    float distance = 45.0;
    if (xsGetTime() > 20*60*1000)
        distance = 55.0;
    int numTemplesAtMainBase = getNumUnits(cUnitTypeTemple, cUnitStateAliveOrBuilding, -1, cMyID, location, distance);
    if (numTemplesAtMainBase > 0)
    {
        if ((cMyCulture == cCultureGreek) && (greekFavorActivated == false) && (xsGetTime() > 4.5*60*1000))
        {
            if (gGatherGoalPlanID >= 0)
            {
                aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 1);
                aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, 41, 1.0, kbBaseGetMainID(cMyID));
                greekFavorActivated = true;
            }
        }
        return;
    }
    
    vector frontVector = kbBaseGetFrontVector(cMyID, kbBaseGetMainID(cMyID));
    float fx = xsVectorGetX(frontVector);
    float fz = xsVectorGetZ(frontVector);
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;

    //Force a temple to go down            
    int templePlanID = aiPlanCreate("build temple", cPlanBuild);
    if (templePlanID >= 0)
    {
        aiPlanSetVariableInt(templePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTemple);
        aiPlanSetVariableBool(templePlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);        
            
        fx = fx * 15;
        fz = fz * 15;

        frontVector = xsVectorSetX(frontVector, fx);
        frontVector = xsVectorSetZ(frontVector, fz);
        frontVector = xsVectorSetY(frontVector, 0.0);
        location = location + frontVector;

        aiPlanSetVariableVector(templePlanID, cBuildPlanInfluencePosition, 0, location);
        if (xsGetTime() > 20*60*1000)
        {
            aiPlanSetVariableFloat(templePlanID, cBuildPlanRandomBPValue, 0, 0.99);
            aiPlanSetVariableFloat(templePlanID, cBuildPlanInfluencePositionDistance, 0, 40.0);
            aiPlanSetVariableFloat(templePlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
        }
        else
        {
            aiPlanSetVariableFloat(templePlanID, cBuildPlanRandomBPValue, 0, 0.0);
            aiPlanSetVariableFloat(templePlanID, cBuildPlanInfluencePositionDistance, 0, 15.0);
//            aiPlanSetVariableFloat(templePlanID, cBuildPlanInfluencePositionDistance, 0, 12.0);
            aiPlanSetVariableFloat(templePlanID, cBuildPlanInfluencePositionValue, 0, 10000.0);
//            aiPlanSetVariableFloat(templePlanID, cBuildPlanBuildingBufferSpace, 0, 0.0);

        }

        aiPlanSetDesiredPriority(templePlanID, 100);
        aiPlanAddUnitType(templePlanID, builderType, 1, 1, 1);
        aiPlanSetEscrowID(templePlanID, cEconomyEscrowID);
        aiPlanSetBaseID(templePlanID, mainBaseID);
        aiPlanSetActive(templePlanID);
    }
}

//==============================================================================
rule buildArmory
    inactive
//    minInterval 17 //starts in cAge2
    minInterval 25 //starts in cAge1
{
    aiEcho("buildArmory:");
    
    if (gTransportMap == true)
    {
        xsDisableSelf();
        return;
    }
/*
    static int ruleStartTime = -1;    
    if (ruleStartTime == -1)
        ruleStartTime = xsGetTime();
*/    
//    if (xsGetTime() < ruleStartTime + 3*60*1000)
    if (kbGetAge() < cAge2)
        return;
    
    xsSetRuleMinIntervalSelf(25);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int buildingID = cUnitTypeArmory;
    if (cMyCiv == cCivThor)
        buildingID = cUnitTypeDwarfFoundry;
    int numArmories = kbUnitCount(cMyID, buildingID, cUnitStateAliveOrBuilding);
    int armoryBuildPlan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, buildingID, true);
    if ((numArmories > 0) || (armoryBuildPlan != -1))
    {
        xsSetRuleMinIntervalSelf(45);
        return;
    }
    
    if ((gBuildTowers == true) && (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching))
        return;
    
    vector location = kbBaseGetLocation(cMyID, mainBaseID);
    vector backVector = kbBaseGetBackVector(cMyID, mainBaseID);
    float bx = xsVectorGetX(backVector);
    float bz = xsVectorGetZ(backVector);
    float bxOrig = bx;
    float bzOrig = bz;

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    static bool firstPlan = true;
    int armoryPlanID=aiPlanCreate("Armory", cPlanBuild);
    if (armoryPlanID >= 0)
    {
        aiPlanSetVariableInt(armoryPlanID, cBuildPlanBuildingTypeID, 0, buildingID);
        aiPlanSetVariableBool(armoryPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(armoryPlanID, cBuildPlanRandomBPValue, 0, 0.99);
            
        bx = bx * 25;
        bz = bz * 25;

        backVector = xsVectorSetX(backVector, bx);
        backVector = xsVectorSetZ(backVector, bz);
        backVector = xsVectorSetY(backVector, 0.0);
        location = location + backVector;

        aiPlanSetVariableVector(armoryPlanID, cBuildPlanInfluencePosition, 0, location);
        if (firstPlan == true)
        {
            aiPlanSetVariableFloat(armoryPlanID, cBuildPlanInfluencePositionDistance, 0, 15.0);
            aiPlanSetVariableFloat(armoryPlanID, cBuildPlanInfluencePositionValue, 0, 10000.0);
            firstPlan = false;
        }
        else
        {
            aiPlanSetVariableFloat(armoryPlanID, cBuildPlanInfluencePositionDistance, 0, 40.0);
            aiPlanSetVariableFloat(armoryPlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
        }
        aiPlanSetDesiredPriority(armoryPlanID, 100);
        aiPlanAddUnitType(armoryPlanID, builderType, 1, 1, 1);
        aiPlanSetEscrowID(armoryPlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(armoryPlanID, mainBaseID);
        aiPlanSetActive(armoryPlanID);
    }
}

//==============================================================================
rule fixUnfinishedWalls
    inactive
//    minInterval 77 //starts in cAge2
    minInterval 83 //starts in cAge2
{
    aiEcho("fixUnfinishedWalls:");

    int numUnfinishedWalls = getNumUnits(cUnitTypeAbstractWall, cUnitStateBuilding, -1, cMyID);
    if (numUnfinishedWalls < 1)
        return;
    
    if (numUnfinishedWalls > 5)
        numUnfinishedWalls = 5;
        
    static int wallPiece1UnitID = -1;
    static int wallPiece2UnitID = -1;
    static int wallPiece3UnitID = -1;
    static int wallPiece4UnitID = -1;
    static int wallPiece5UnitID = -1;
    
    bool wallPiece1UnitIDSavedNow = false;
    bool wallPiece2UnitIDSavedNow = false;
    bool wallPiece3UnitIDSavedNow = false;
    bool wallPiece4UnitIDSavedNow = false;
    bool wallPiece5UnitIDSavedNow = false;
    
    for (i = 0; < numUnfinishedWalls)
    {
        int unfinishedWallID = findUnitByIndex(cUnitTypeAbstractWall, i, cUnitStateBuilding, -1, cMyID);
        if (unfinishedWallID > 0)
        {
            if (unfinishedWallID == wallPiece1UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece1UnitID = -1;
            }
            else if (unfinishedWallID == wallPiece2UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece2UnitID = -1;
            }
            else if (unfinishedWallID == wallPiece3UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece3UnitID = -1;
            }
            else if (unfinishedWallID == wallPiece4UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece4UnitID = -1;
            }
            else if (unfinishedWallID == wallPiece5UnitID)
            {
                aiTaskUnitDelete(unfinishedWallID);
                wallPiece5UnitID = -1;
            }
            else
            {
                if (wallPiece1UnitID == -1)
                {
                    wallPiece1UnitID = unfinishedWallID;
                    wallPiece1UnitIDSavedNow = true;
                }
                else if (wallPiece2UnitID == -1)
                {
                    wallPiece2UnitID = unfinishedWallID;
                    wallPiece2UnitIDSavedNow = true;
                }
                else if (wallPiece3UnitID == -1)
                {
                    wallPiece3UnitID = unfinishedWallID;
                    wallPiece3UnitIDSavedNow = true;
                }
                else if (wallPiece4UnitID == -1)
                {
                    wallPiece4UnitID = unfinishedWallID;
                    wallPiece4UnitIDSavedNow = true;
                }
                else if (wallPiece5UnitID == -1)
                {
                    wallPiece5UnitID = unfinishedWallID;
                    wallPiece5UnitIDSavedNow = true;
                }
            }
        }
    }
    
    if (wallPiece1UnitIDSavedNow == false)
        wallPiece1UnitID = -1;
    if (wallPiece2UnitIDSavedNow == false)
        wallPiece2UnitID = -1;
    if (wallPiece3UnitIDSavedNow == false)
        wallPiece3UnitID = -1;
    if (wallPiece4UnitIDSavedNow == false)
        wallPiece4UnitID = -1;
    if (wallPiece5UnitIDSavedNow == false)
        wallPiece5UnitID = -1;
}

//==============================================================================
rule buildResearchGranary   //or a guild for Atlanteans or a house for Norse
    inactive
//    minInterval 35 //starts in cAge1
    minInterval 45 //starts in cAge1
{
//    if (gTransportMap == true)
    if ((gTransportMap == true) && (cMyCulture != cCultureAtlantean))
    {
        xsDisableSelf();
        return;
    }
    
    if (kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive) < 1)
    {
        return;
    }

    int buildingType = cUnitTypeGranary;
    if (cMyCulture == cCultureAtlantean)
        buildingType = cUnitTypeGuild;
    else if (cMyCulture == cCultureNorse)
        buildingType = cUnitTypeHouse;
        
    int mainBaseID = kbBaseGetMainID(cMyID);
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == buildingType) && (aiPlanGetBaseID(buildPlanIndexID) == mainBaseID))
            {
                return;
            }
        }
    }
    
    if (gResearchGranaryID > 0)
    {
        float researchGranaryHitpoints = kbUnitGetCurrentHitpoints(gResearchGranaryID);
        if (researchGranaryHitpoints > 0)
        {
            return;
        }
    }
 
    vector location = kbBaseGetLocation(cMyID, mainBaseID);
    vector backVector = kbBaseGetBackVector(cMyID, mainBaseID);
    float bx = xsVectorGetX(backVector);
    float bz = xsVectorGetZ(backVector);
    
    bx = bx * 25;
    bz = bz * 25;

    backVector = xsVectorSetX(backVector, bx);
    backVector = xsVectorSetZ(backVector, bz);
    backVector = xsVectorSetY(backVector, 0.0);
    location = location + backVector;
    
    float woodSupply = kbResourceGet(cResourceWood);
    if (woodSupply < 100)
        return;
    
    float radius = 25.0;
    if (xsGetTime() > 12*60*1000)
        radius = radius + 30.0;
    else if (xsGetTime() > 8*60*1000)
        radius = radius + 15.0;
    int granaryID = findUnitByIndex(buildingType, 0, cUnitStateAliveOrBuilding, -1, cMyID, location, radius);
    if (granaryID > 0)
    {
        gResearchGranaryID = granaryID;
        return;
    }

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
        
    //Force a granary (or guild or house) to go down            
    int researchGranaryPlanID=aiPlanCreate("buildResearchGranary", cPlanBuild);
    if (researchGranaryPlanID >= 0)
    {
        aiPlanSetVariableInt(researchGranaryPlanID, cBuildPlanBuildingTypeID, 0, buildingType);
        aiPlanSetVariableBool(researchGranaryPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(researchGranaryPlanID, cBuildPlanRandomBPValue, 0, 0.0);

        aiPlanSetVariableVector(researchGranaryPlanID, cBuildPlanInfluencePosition, 0, location);
        aiPlanSetVariableFloat(researchGranaryPlanID, cBuildPlanInfluencePositionDistance, 0, 12.0);
        aiPlanSetVariableFloat(researchGranaryPlanID, cBuildPlanInfluencePositionValue, 0, 10000.0);

        aiPlanSetDesiredPriority(researchGranaryPlanID, 100);
        aiPlanAddUnitType(researchGranaryPlanID, builderType, 1, 1, 1);
        aiPlanSetEscrowID(researchGranaryPlanID, cEconomyEscrowID);
        aiPlanSetBaseID(researchGranaryPlanID, mainBaseID);
        aiPlanSetActive(researchGranaryPlanID);
    }
}

//==============================================================================
rule destroyUnnecessaryDropsites
    inactive
//    minInterval 83 //starts in cAge2
    minInterval 97 //starts in cAge2
{
    aiEcho("destroyUnnecessaryDropsites:");
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    int otherBaseUnitID = findUnit(cUnitTypeAbstractSettlement);
    if (otherBaseUnitID < 0)
        return;
    else
    {
        int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
    }
    
    float radius = 0;
    if (otherBaseID == mainBaseID)
    {
//        if (xsGetTime() < 12*60*1000)
        if (xsGetTime() < 10*60*1000)
            radius = 20;
        else
            radius = 50;
    }
    else
        radius = gOtherBaseWallRadius + 10;
    
    vector baseLocation = kbBaseGetLocation(cMyID, otherBaseID);
    int numDropsitesNearBase = getNumUnits(cUnitTypeDropsite, cUnitStateAliveOrBuilding, -1, cMyID, baseLocation, radius);
    if (numDropsitesNearBase < 1)
        return;
    
    if (numDropsitesNearBase > 16)
        numDropsitesNearBase = 16;
    
    for (i = 0; < numDropsitesNearBase)
    {
        int dropsiteID = findUnitByIndex(cUnitTypeDropsite, i, cUnitStateAliveOrBuilding, -1, cMyID, baseLocation, radius);
        if (dropsiteID > 0)
        {
            if (dropsiteID != gResearchGranaryID)
            {
                vector dropsiteLocation = kbUnitGetPosition(dropsiteID);
                int numAnimals = getNumUnits(cUnitTypeHuntedResource, cUnitStateAlive, -1, 0, dropsiteLocation, 17.0);
                int numWildCrops = getNumUnits(cUnitTypeWildCrops, cUnitStateAlive, -1, 0, dropsiteLocation, 17.0);
                int numTrees = getNumUnits(cUnitTypeTree, cUnitStateAlive, -1, 0, dropsiteLocation, 17.0);
                int numGoldMines = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, dropsiteLocation, 17.0);
                
                if (kbUnitIsType(dropsiteID, cUnitTypeGranary) == true)
                {
                    if (((numAnimals < 2) && (numWildCrops < 1)) || (otherBaseID != mainBaseID))
                    {
                        if ((kbGetTechStatus(cTechPlow) != cTechStatusResearching) && (kbGetTechStatus(cTechHuntingDogs) != cTechStatusResearching) && (kbGetTechStatus(cTechHusbandry) != cTechStatusResearching))
                        {
                            aiTaskUnitDelete(dropsiteID);
                        }
                        continue;
                    }
                }
                if (cMyCulture == cCultureEgyptian)
                {
                    if (kbUnitIsType(dropsiteID, cUnitTypeLumberCamp) == true)
                    {
                        if ((numTrees < 1) || (otherBaseID != mainBaseID))
                        {
                            if (kbGetTechStatus(cTechHandAxe) != cTechStatusResearching)
                            {
                                aiTaskUnitDelete(dropsiteID);
                            }
                        }
                        continue;
                    }
                    if (kbUnitIsType(dropsiteID, cUnitTypeMiningCamp) == true)
                    {
                        if (numGoldMines < 1)
                        {
                            if (kbGetTechStatus(cTechPickaxe) != cTechStatusResearching)
                            {
                                aiTaskUnitDelete(dropsiteID);
                            }
                        }
                        continue;
                    }
                }
                else if (cMyCulture == cCultureGreek)
                {
                    if (kbUnitIsType(dropsiteID, cUnitTypeStorehouse) == true)
                    {
                        if (((numTrees < 1) && (numGoldMines < 1)) || ((otherBaseID != mainBaseID) && (numGoldMines < 1)))
                        {
                            if ((kbGetTechStatus(cTechHandAxe) != cTechStatusResearching) && (kbGetTechStatus(cTechPickaxe) != cTechStatusResearching))
                            {
                                aiTaskUnitDelete(dropsiteID);
                            }
                        }
                        continue;
                    }
                }
                else if (cMyCulture == cCultureChinese)
                {
                    if (kbUnitIsType(dropsiteID, cUnitTypeStoragePit) == true)
                    {
                        if (((numTrees < 1) && (numGoldMines < 1)) || ((otherBaseID != mainBaseID) && (numGoldMines < 1)))
                        {
                            if ((kbGetTechStatus(cTechHandAxe) != cTechStatusResearching) && (kbGetTechStatus(cTechPickaxe) != cTechStatusResearching))
                            {
                                aiTaskUnitDelete(dropsiteID);
                            }
                        }
                        continue;				
            }
        }
    }
}
}
}
//==============================================================================
rule findMySettlementsBeingBuilt
//    minInterval 16 //starts in cAge2
    minInterval 479 //starts in cAge1, is set to 7 after 8 minutes
    inactive
{
    aiEcho("findMySettlementsBeingBuilt: ");
        
    static bool update = false;
    if (update == false)
    {
        xsSetRuleMinIntervalSelf(7);
        update = true;
    }
    
    int myBaseAtDefPlanPosition = -1;
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanIndexID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanIndexID == -1)
                continue;
                
            if (defendPlanIndexID == gSettlementPosDefPlanID)
            {
                vector defendPlanDefendPoint = aiPlanGetVariableVector(defendPlanIndexID, cDefendPlanDefendPoint, 0);
                myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defendPlanDefendPoint, 15.0);
                if (myBaseAtDefPlanPosition < 1)
                {
                    return;
                }
                break;
            }
        }
    }
    
    int numSettlementsBeingBuilt = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateBuilding);
    if (numSettlementsBeingBuilt > 0)
    {
        for (i = 0; < numSettlementsBeingBuilt)
        {
            int mainBaseID = kbBaseGetMainID(cMyID);
            vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
            
            int settlementBeingBuiltID = findUnitByIndex(cUnitTypeAbstractSettlement, i, cUnitStateBuilding, -1, cMyID);
            if (settlementBeingBuiltID != -1)
            {
                vector settlementBeingBuiltPosition = kbUnitGetPosition(settlementBeingBuiltID);
                float distanceToMainBase = xsVectorLength(mainBaseLocation - settlementBeingBuiltPosition);
//                if (distanceToMainBase > 65.0)
                if (distanceToMainBase > 60.0)
                {
                    if (myBaseAtDefPlanPosition > 0)
                    {
                        xsSetRuleMinInterval("defendSettlementPosition", 7);
                        xsDisableRule("defendSettlementPosition");
                        aiPlanDestroy(gSettlementPosDefPlanID);
                    }
                    gSettlementPosDefPlanDefPoint = settlementBeingBuiltPosition;
                    xsEnableRule("defendSettlementPosition");
                    break;
                }
            }
        }
    }
}

//==============================================================================
rule rebuildDropsites   //rebuilds dropsites near gold mines and trees
//    minInterval 53 //starts in cAge2
    minInterval 59 //starts in cAge2
    inactive
{    
    aiEcho("rebuildDropsites:");
    
    float woodSupply = kbResourceGet(cResourceWood);
    if (woodSupply < 150)
        return;

    vector location = cInvalidVector;
    
    int activeGatherPlans = aiPlanGetNumber(cPlanGather, -1, true);
    if (activeGatherPlans > 0)
    {
        for (i = 0; < activeGatherPlans)
        {
            int gatherPlanID = aiPlanGetIDByIndex(cPlanGather, -1, true, i);
          
            if (aiPlanGetVariableInt(gatherPlanID, cGatherPlanDropsiteID, 0) != -1)
            {
                location = cInvalidVector;
                continue;
            }
            
            int resource = aiPlanGetVariableInt(gatherPlanID, cGatherPlanResourceType, 0);
//            if ((resource != cResourceGold) && (resource != cResourceWood))
            if (resource != cResourceGold) //only gold for now; TODO: also check for wood and trees
            {
                location = cInvalidVector;
                continue;
            }
            
            int dropsiteTypeID = cUnitTypeStorehouse;
            if (cMyCulture == cCultureEgyptian)
            {
//                if (resource == cResourceGold)
                    dropsiteTypeID = cUnitTypeMiningCamp; //only gold for now
//                else if (resource == cResourceWood)
//                    dropsiteTypeID = cUnitTypeLumberCamp;
            }
            
            aiEcho("gatherPlanID: "+gatherPlanID);
            aiEcho("resource: "+resource);
            int mainBaseID = kbBaseGetMainID(cMyID);
            int baseID = aiPlanGetBaseID(gatherPlanID);
            float distance = 20.0;
            location = aiPlanGetLocation(gatherPlanID);
            if (resource == cResourceGold)
            {
                int numGoldMinesInR50 = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, location, 50.0);
                aiEcho("numGoldMinesInR50: "+numGoldMinesInR50);
                if (numGoldMinesInR50 > 0)
                {
                    int randomGoldMine = findUnitByIndex(cUnitTypeGold, aiRandInt(numGoldMinesInR50), cUnitStateAlive, -1, 0, location, 50.0);
                    location = kbUnitGetPosition(randomGoldMine);
                }
                else
                {
                    location = cInvalidVector;
                    continue;
                }
            }
            else
            {
                distance = 40.0;
            }
                
            int numDropsitesInRange = getNumUnits(dropsiteTypeID, cUnitStateAliveOrBuilding, -1, cMyID, location, distance);
            aiEcho("numDropsitesInRange"+distance+": "+numDropsitesInRange);
            if (numDropsitesInRange < 1)
            {
                int numEnemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, location, 50.0, true);
                int numEnemyMilBuildingsInR50 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, location, 50.0);
                if ((numEnemyMilUnitsInR50 < 1) && (numEnemyMilBuildingsInR50 < 1))
                {
                    aiEcho("found a location: "+location+", breaking off");
                    break;
                }
                else
                {
                    location = cInvalidVector;
                    continue;
                }
            }
            else
            {
                location = cInvalidVector;
                continue;
            }
        }
    }
    
    if (equal(location, cInvalidVector) == true)
    {
        aiEcho("no location to build a dropsite, returning");
        return;
    }
    
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanID, cBuildPlanBuildingTypeID, 0) == dropsiteTypeID) && (aiPlanGetBaseID(buildPlanID) == baseID))
            {
                aiEcho("plan to build dropsite at baseID "+baseID+" already exists, returning");
                return;
            }
        }
    }
            
    //Build a dropsite near the base or the resource
    static int count = 1;
    int buildDropsitePlanID = aiPlanCreate("rebuild dropsite #"+count, cPlanBuild);
    if (buildDropsitePlanID >= 0)
    {
        aiPlanSetInitialPosition(buildDropsitePlanID, location);
        aiPlanSetVariableInt(buildDropsitePlanID, cBuildPlanBuildingTypeID, 0, dropsiteTypeID);
        aiPlanSetVariableBool(buildDropsitePlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildDropsitePlanID, cBuildPlanRandomBPValue, 0, 0.0);
        aiPlanSetVariableVector(buildDropsitePlanID, cBuildPlanCenterPosition, 0, location);
        aiPlanSetVariableFloat(buildDropsitePlanID, cBuildPlanCenterPositionDistance, 0, 5.0);

        aiPlanSetVariableFloat(buildDropsitePlanID, cBuildPlanBuildingBufferSpace, 0, 0.0);
        aiPlanAddUnitType(buildDropsitePlanID, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), 1, 1, 1);
        aiPlanSetEscrowID(buildDropsitePlanID, cEconomyEscrowID);
        aiPlanSetBaseID(buildDropsitePlanID, baseID);
        aiPlanSetDesiredPriority(buildDropsitePlanID, 100);
        aiPlanSetActive(buildDropsitePlanID);
        count = count + 1;
        if (baseID == mainBaseID)
            aiEcho("building dropsite near our resource: "+resource+" near location: "+location);
        else
            aiEcho("building dropsite near our base: "+baseID+" near location: "+location);
    }
}

//==============================================================================
rule buildGoldMineTower
//    minInterval 33 //starts in cAge2
    minInterval 47 //starts in cAge2
    inactive
{
    float goldSupply = kbResourceGet(cResourceGold);
	if (kbGetAge() < cAge3 && goldSupply < 750)
	return; // We need the gold to advance quicker.
	
	aiEcho("buildGoldMineTower:");
 
    int numTowers = kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
    
    if (cMyCulture != cCultureEgyptian)
    {
        if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (numTowers > 0))
            return;
            
        if ((gAge2MinorGod == cTechAge2Heimdall) && (kbGetTechStatus(cTechSafeguard) < cTechStatusResearching))
            return;
    }
     
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);
    float currentFood = kbResourceGet(cResourceFood);

    if ((currentWood < 300) || (currentGold < 150))
        return;
        
    if (((currentFood > 500) && (currentGold > 300) && (kbGetAge() == cAge2))
     || ((currentFood > 700) && (currentGold > 700) && (kbGetAge() == cAge3)))
        return;
    
    int towerLimit = kbGetBuildLimit(cMyID, cUnitTypeTower);
    if (numTowers >= towerLimit)
        return;

    if ((numTowers > 15) && (kbGetAge() == 2))
        return;

    aiEcho("buildGoldMineTower:");
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector location = cInvalidVector;
       
    int numGoldMinesInR90 = getNumUnits(cUnitTypeGold, cUnitStateAlive, -1, 0, mainBaseLocation, 90.0);
    aiEcho("numGoldMinesInR90: "+numGoldMinesInR90);
    if (numGoldMinesInR90 > 0)
    {
        for (i = 0; < numGoldMinesInR90)
        {
            int goldMineID = findUnitByIndex(cUnitTypeGold, i, cUnitStateAlive, -1, 0, mainBaseLocation, 90.0);
            if (goldMineID > 0)
            {
                location = kbUnitGetPosition(goldMineID);
                int numTowersNearLocation = getNumUnits(cUnitTypeTower, cUnitStateAliveOrBuilding, -1, cMyID, location, 12.0);
                aiEcho("numTowersNearLocation: "+location+": "+numTowersNearLocation);
                if (numTowersNearLocation < 1)
                    break;
                else
                    location = cInvalidVector;
            }
        }
    }
    
    if (equal(location, cInvalidVector) == true)
    {
        aiEcho("no location to build a tower, returning");
        return;
    }


    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeTower) && (equal(location, aiPlanGetVariableVector(buildPlanIndexID, cBuildPlanCenterPosition, 0)) == true))
            {
                aiEcho("plan to build tower near gold mine at location "+location+" already exists, returning");
                return;
            }
        }
    }
    
    float distToMainBase = xsVectorLength(mainBaseLocation - location);

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    int numBuilders = kbUnitCount(cMyID, builderType, cUnitStateAlive);    
        
    //Build a tower near the gold mine
    static int count = 1;
    int buildGoldMineTowerPlanID = aiPlanCreate("Build gold mine tower #"+count, cPlanBuild);
    if (buildGoldMineTowerPlanID >= 0)
    {
        aiPlanSetInitialPosition(buildGoldMineTowerPlanID, location);
        aiPlanSetVariableInt(buildGoldMineTowerPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTower);
        aiPlanSetVariableInt(buildGoldMineTowerPlanID, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetDesiredPriority(buildGoldMineTowerPlanID, 100);
        aiPlanSetVariableBool(buildGoldMineTowerPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildGoldMineTowerPlanID, cBuildPlanRandomBPValue, 0, 0.0);
        aiPlanSetVariableVector(buildGoldMineTowerPlanID, cBuildPlanCenterPosition, 0, location);
        aiPlanSetVariableFloat(buildGoldMineTowerPlanID, cBuildPlanCenterPositionDistance, 0, 4.0);

        aiPlanSetVariableFloat(buildGoldMineTowerPlanID, cBuildPlanBuildingBufferSpace, 0, 0.0);
        if ((distToMainBase < 50.0) || (cMyCulture == cCultureAtlantean) || (numBuilders < 30))
            aiPlanAddUnitType(buildGoldMineTowerPlanID, builderType, 1, 1, 1);
        else
            aiPlanAddUnitType(buildGoldMineTowerPlanID, builderType, 1, 2, 2);
        aiPlanSetEscrowID(buildGoldMineTowerPlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(buildGoldMineTowerPlanID, mainBaseID);

        aiPlanSetActive(buildGoldMineTowerPlanID);
        count = count + 1;
        aiEcho("building tower near gold mine at location: "+location);
    }
}

//==============================================================================
rule buildMBTower
//    minInterval 70 //starts in cAge2
    minInterval 73 //starts in cAge2
    inactive
{
    aiEcho("buildMBTower:");
    
    int numTowers = kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
    
    if (cMyCulture != cCultureEgyptian)
    {
        if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (numTowers > 0))
            return;
            
        if ((gAge2MinorGod == cTechAge2Heimdall) && (kbGetTechStatus(cTechSafeguard) < cTechStatusResearching))
            return;
    }
     
    float currentWood = kbResourceGet(cResourceWood);
    float currentGold = kbResourceGet(cResourceGold);
    float currentFood = kbResourceGet(cResourceFood);

    if ((currentWood < 500) || (currentGold < 300))
        return;
        
    if (kbGetAge() == cAge2)
    {
        if ((currentFood > 500) && (currentGold > 300))
            return;
    }
    else if (kbGetAge() == cAge3)
    {
        int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
        int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
        if ((numFortresses < 1) || (numMarkets < 1))
            return;
        
        if ((currentFood > 700) && (currentGold > 700))
            return;
    }
    
    int towerLimit = kbGetBuildLimit(cMyID, cUnitTypeTower);
    if (numTowers >= towerLimit)
        return;

    int mainBaseID = kbBaseGetMainID(cMyID);
    
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeTower) && (aiPlanGetBaseID(buildPlanIndexID) == mainBaseID))
            {
                return;
            }
        }
    }
    
        
    //variables for our tower placing
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector frontVector = kbBaseGetFrontVector(cMyID, mainBaseID);
    float fx = xsVectorGetX(frontVector);
    float fz = xsVectorGetZ(frontVector);
    float fxOrig = fx;
    float fzOrig = fz;
    
    aiEcho("mainBaseLocation: "+mainBaseLocation);
    aiEcho("frontVector: "+frontVector);
    aiEcho("fx: "+fx);
    aiEcho("fz: "+fz);
    
    //Towers should be placed in a radius of 20m around a point 15m in front of our main base
    fx = fxOrig * 15;
    fz = fzOrig * 15;
    frontVector = xsVectorSetX(frontVector, fx);
    frontVector = xsVectorSetZ(frontVector, fz);
    frontVector = xsVectorSetY(frontVector, 0.0);
    vector location = mainBaseLocation + frontVector;
    vector centerLocation = location;
    aiEcho("centerLocation: "+centerLocation);
    
    for (i = 0; < 3)
    {
        switch(i)
        {
            case 0: //front
            {
                fx = fxOrig * 20;
                fz = fzOrig * 20;
            }
            case 1: //left
            {
                fx = fzOrig * (-20);
                fz = fxOrig * 20;
            }
            case 2: //right
            {
                fx = fzOrig * 20;
                fz = fxOrig * (-20);
            }
        }
        frontVector = xsVectorSetX(frontVector, fx);
        frontVector = xsVectorSetZ(frontVector, fz);
        frontVector = xsVectorSetY(frontVector, 0.0);
        if (i == 0)
            vector frontLocation = centerLocation + frontVector;
        else if (i == 1)
            vector leftLocation = centerLocation + frontVector;
        else if (i == 2)
            vector rightLocation = centerLocation + frontVector;
    }
    
    int numTowersNearFront = getNumUnits(cUnitTypeTower, cUnitStateAliveOrBuilding, -1, cMyID, frontLocation, 18.0);
    int numTowersNearLeft = getNumUnits(cUnitTypeTower, cUnitStateAliveOrBuilding, -1, cMyID, leftLocation, 18.0);
    int numTowersNearRight = getNumUnits(cUnitTypeTower, cUnitStateAliveOrBuilding, -1, cMyID, rightLocation, 18.0);
    if ((numTowersNearFront < 2) && (numTowersNearFront <= numTowersNearLeft) && (numTowersNearFront <= numTowersNearRight))
    {
        location = frontLocation;
        aiEcho("using frontLocation");
    }
    else
    {
        if ((numTowersNearLeft < 2) && (numTowersNearLeft <= numTowersNearRight))
        {
            location = leftLocation;
            aiEcho("using leftLocation");
        }
        else
        {
            if (numTowersNearLeft < 2)
            {
                location = rightLocation;
                aiEcho("using rightLocation");
            }
            else
            {
                aiEcho("returning, as there are 2 towers near the front, left and right location");
                return;
            }
        }
    }

    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    aiEcho("using location: "+location);

    //Build a tower near our main base
    static int count = 1;
    int buildMBTowerPlanID = aiPlanCreate("Build main base tower #"+count, cPlanBuild);
    if (buildMBTowerPlanID >= 0)
    {
        aiPlanSetInitialPosition(buildMBTowerPlanID, location);
        aiPlanSetVariableInt(buildMBTowerPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeTower);
        aiPlanSetDesiredPriority(buildMBTowerPlanID, 100);
        aiPlanSetVariableBool(buildMBTowerPlanID, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(buildMBTowerPlanID, cBuildPlanRandomBPValue, 0, 0.99);
        
        aiPlanSetVariableVector(buildMBTowerPlanID, cBuildPlanCenterPosition, 0, location);
        aiPlanSetVariableFloat(buildMBTowerPlanID, cBuildPlanCenterPositionDistance, 0, 10.0);
        aiPlanAddUnitType(buildMBTowerPlanID, builderType, 1, 1, 1);
        aiPlanSetEscrowID(buildMBTowerPlanID, cMilitaryEscrowID);
        aiPlanSetBaseID(buildMBTowerPlanID, mainBaseID);
        aiPlanSetActive(buildMBTowerPlanID);
        count = count + 1;
        aiEcho("building tower at our main base: "+mainBaseID+" near location: "+location);
    }
}

//==============================================================================
rule fixJammedDropsiteBuildPlans
//    minInterval 29 //starts in cAge1
    minInterval 97 //starts in cAge1
    inactive
{
    aiEcho("fixJammedDropsiteBuildPlans:");
	
    static int SHBuildPlanID = -1;
    static int LCBuildPlanID = -1;
    static int MCBuildPlanID = -1;
    int dropsiteTypeID = -1;
    int dropsiteBuildPlanID = -1;
    int loops = 1;
    if (cMyCulture == cCultureEgyptian)
        loops = 2;
    for (i = 0; < loops)
    {
        if (cMyCulture == cCultureGreek)
            dropsiteTypeID = cUnitTypeStorehouse;
        if (cMyCulture == cCultureChinese)
            dropsiteTypeID = cUnitTypeStoragePit;			
        else
        {
            if (i == 0)
                dropsiteTypeID = cUnitTypeLumberCamp;
            else
                dropsiteTypeID = cUnitTypeMiningCamp;
        }
        
        dropsiteBuildPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, dropsiteTypeID, true);
        aiEcho("dropsiteBuildPlanID: "+dropsiteBuildPlanID);
        if (dropsiteBuildPlanID != -1)
        {
            int numBuildersInPlan = aiPlanGetNumberUnits(dropsiteBuildPlanID, cUnitTypeAbstractVillager);
            aiEcho("numBuildersInPlan: "+numBuildersInPlan);
            if (numBuildersInPlan > 5)
            {
                aiEcho("*!*!*!*!*!*!*!* fixJammedDropsiteBuildPlans:");
                if (cMyCulture == cCultureGreek)
                {
                    if (dropsiteBuildPlanID == SHBuildPlanID)
                    {
                        aiPlanDestroy(dropsiteBuildPlanID);
                        aiEcho("dropsiteBuildPlanID == SHBuildPlanID");
                        aiEcho("destroying dropsiteBuildPlanID: "+dropsiteBuildPlanID);
                    }
                    else
                    {
                        SHBuildPlanID = dropsiteBuildPlanID;
                        aiEcho("saving SHBuildPlanID");
                    }
                }
                else    //Egyptian
                {
                    if (i == 0)
                    {
                        if (dropsiteBuildPlanID == LCBuildPlanID)
                        {
                            aiPlanDestroy(dropsiteBuildPlanID);
                            aiEcho("dropsiteBuildPlanID == LCBuildPlanID");
                            aiEcho("destroying dropsiteBuildPlanID: "+dropsiteBuildPlanID);
                        }
                        else
                        {
                            LCBuildPlanID = dropsiteBuildPlanID;
                            aiEcho("saving LCBuildPlanID");
                        }
                    }
                    else
                    {
                        if (dropsiteBuildPlanID == MCBuildPlanID)
                        {
                            aiPlanDestroy(dropsiteBuildPlanID);
                            aiEcho("dropsiteBuildPlanID == MCBuildPlanID");
                            aiEcho("destroying dropsiteBuildPlanID: "+dropsiteBuildPlanID);
                        }
                        else
                        {
                            LCBuildPlanID = dropsiteBuildPlanID;
                            aiEcho("saving MCBuildPlanID");
                        }
                    }
                }
                aiEcho("*!*!*!*!*!*!*!*");
            }
        }
    }
}

//==============================================================================
rule buildExtraFarms
    minInterval 29 //gets activated in updateFoodBreakdown
    inactive
{
    aiEcho("buildExtraFarms:");
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector backLocation = cInvalidVector;
    vector backVector = kbBaseGetBackVector(cMyID, mainBaseID);
    float bx = xsVectorGetX(backVector);
    float bz = xsVectorGetZ(backVector);
    
    bx = bx * 10;
    bz = bz * 10;

    backVector = xsVectorSetX(backVector, bx);
    backVector = xsVectorSetZ(backVector, bz);
    backVector = xsVectorSetY(backVector, 0.0);
    backLocation = mainBaseLocation + backVector;
    
    int numFarmsNearMainBaseInR30 = getNumUnits(cUnitTypeFarm, cUnitStateAlive, -1, cMyID, mainBaseLocation, 30.0);
    
    if ((gFarming == false) || (numFarmsNearMainBaseInR30 > 19))
    {
        xsSetRuleMinIntervalSelf(67);
        return;
    }
    else
        xsSetRuleMinIntervalSelf(29);

    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
//    int numFarmPlans = 0;
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
//            if (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeFarm)
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeFarm) && (aiPlanGetBaseID(buildPlanIndexID) == mainBaseID))
            {
//                numFarmPlans = numFarmPlans + 1;
                return;
            }
        }
    }
    
    float resourceSupply = kbResourceGet(cResourceWood);
    if (cMyCulture == cCultureEgyptian)
        resourceSupply = kbResourceGet(cResourceGold);
    
    if (resourceSupply < 150)
    {
        return;
    }

//    float distance = kbBaseGetMaximumResourceDistance(cMyID, mainBaseID);
    float distance = 85.0;
    int numAggressiveResourceSpots = kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeHuntAggressive, distance);
    int numEasyResourceSpots = kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeEasy, distance);
    int totalNumResourceSpots = numAggressiveResourceSpots + numEasyResourceSpots;

//    if ((numFarmsNearMainBaseInR30 < 8) && (totalNumResourceSpots > 0))
    if ((totalNumResourceSpots > 1) && (numFarmsNearMainBaseInR30 > 5))
    {
        return;
    }
    
    //Build a farm near our main base
    static int count = 1;
    int farmBuildPlan = aiPlanCreate("Build main base farm #"+count, cPlanBuild);
    if (farmBuildPlan >= 0)
    {
        aiPlanSetInitialPosition(farmBuildPlan, backLocation);
        aiPlanSetVariableInt(farmBuildPlan, cBuildPlanBuildingTypeID, 0, cUnitTypeFarm);
        aiPlanSetVariableInt(farmBuildPlan, cBuildPlanMaxRetries, 0, 10);
        aiPlanSetDesiredPriority(farmBuildPlan, 100);
        aiPlanSetVariableBool(farmBuildPlan, cBuildPlanInfluenceAtBuilderPosition, 0, false);
        aiPlanSetVariableFloat(farmBuildPlan, cBuildPlanRandomBPValue, 0, 0.99);
        aiPlanSetVariableVector(farmBuildPlan, cBuildPlanCenterPosition, 0, backLocation);
        aiPlanSetVariableFloat(farmBuildPlan, cBuildPlanCenterPositionDistance, 0, 20.0);
        aiPlanSetVariableFloat(farmBuildPlan, cBuildPlanBuildingBufferSpace, 0, 0.0);
        aiPlanAddUnitType(farmBuildPlan, cUnitTypeAbstractVillager, 1, 1, 1);
        aiPlanSetEscrowID(farmBuildPlan, cEconomyEscrowID);
        aiPlanSetBaseID(farmBuildPlan, mainBaseID);
        aiPlanSetActive(farmBuildPlan);
        count = count + 1;
    }
}

//==============================================================================
rule rebuildMarket  // If market dies, restart
    minInterval 19 //starts in cAge3, activated in tradeWithCaravans, after market is built
    inactive
{
    aiEcho("rebuildMarket:");
    
    aiEcho("gTradeMarketUnitID: "+gTradeMarketUnitID);
    if ((gTradeMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0))
    {
        aiEcho("gTradeMarketUnitID has been destroyed or is -1");
        if (gTradePlanID != -1)
        {
            aiPlanDestroy(gTradePlanID);
            gTradePlanID = -1;
            aiEcho("killing gTradePlanID");
        }
        
        int activeTradePlans = aiPlanGetNumber(cPlanTrade, -1, true);
        aiEcho("activeTradePlans: "+activeTradePlans);
        if (activeTradePlans > 0)
        {
            for (i = 0; < activeTradePlans)
            {
                int tradePlanIndexID = aiPlanGetIDByIndex(cPlanTrade, -1, true, i);
                if (tradePlanIndexID != -1)
                {
                    aiPlanDestroy(tradePlanIndexID);
                    aiEcho("destroying tradePlanIndexID: "+tradePlanIndexID);
                }
            }
        }
        
        xsEnableRule("tradeWithCaravans");
        xsDisableSelf();
        gTradeMarketUnitID = -1;
    }
}

//==============================================================================
rule makeExtraMarket    //If it takes more than 5 minutes to place our trade market, throw down a local one
    inactive
//    minInterval 31 //starts in cAge3, activated in tradeWithCaravans
    minInterval 37 //starts in cAge3, activated in tradeWithCaravans
{
//    xsSetRuleMinIntervalSelf(31);
    xsSetRuleMinIntervalSelf(37);
    static int ruleStartTime = -1;
    aiEcho("*!*!*!*!*!*makeExtraMarket:");
    if (ruleStartTime == -1)
        ruleStartTime = xsGetTime();
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int mainBaseAreaID = kbAreaGetIDByPosition(mainBaseLocation);
    
    int numMarketsNearMB = getNumUnits(cUnitTypeMarket, cUnitStateAlive, -1, cMyID, mainBaseLocation, 50.0);
    aiEcho("numMarketsNearMB: "+numMarketsNearMB);
    
    if ((gExtraMarketUnitID != -1) && (kbUnitGetCurrentHitpoints(gExtraMarketUnitID) <= 0))
    {
        gExtraMarketUnitID = -1;
    }
    
    if (gExtraMarketUnitID == -1)
    {
        if (numMarketsNearMB > 0)
        {
            for (i = 0; < numMarketsNearMB)
            {
                int marketIDNearMB = findUnitByIndex(cUnitTypeMarket, i, cUnitStateAlive, -1, cMyID, mainBaseLocation, 50.0);
                aiEcho("marketIDNearMB: "+marketIDNearMB);
                if (marketIDNearMB == -1)
                    continue;
        
                if (marketIDNearMB == gTradeMarketUnitID)
                    continue;
                
                if ((marketIDNearMB == gExtraMarketUnitID) && (kbUnitGetCurrentHitpoints(marketIDNearMB) > 0))
                {
                    aiEcho("marketIDNearMB == gTradeMarketUnitID");
                    continue;
                }
                else
                {
                    gExtraMarketUnitID = marketIDNearMB;
                    aiEcho("setting gExtraMarketUnitID to: "+marketIDNearMB);
                }
            
            }
        }
    }
    
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
    int activeBuildPlans = aiPlanGetNumber(cPlanBuild, -1, true);
    if (activeBuildPlans > 0)
    {
        for (i = 0; < activeBuildPlans)
        {
            int buildPlanIndexID = aiPlanGetIDByIndex(cPlanBuild, -1, true, i);
            if ((aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanBuildingTypeID, 0) == cUnitTypeMarket) && (aiPlanGetVariableInt(buildPlanIndexID, cBuildPlanAreaID, 0) == mainBaseAreaID))
            {
                ruleStartTime = -1;
                return;
            }
        }
    }
        
    if ((numMarkets > 1) || ((numMarkets > 0) && (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0)))
    {
        ruleStartTime = -1;
        return;
    }
    
    
    static bool firstRun = true;
//    int minutes = 3;
    int minutes = 2;
    if (firstRun == true)
//        minutes = 5;
        minutes = 4;
    
    if (xsGetTime() < ruleStartTime + minutes*60*1000)
        return;
    
    int builderType = cUnitTypeAbstractVillager;
    if (cMyCulture == cCultureNorse)
        builderType = cUnitTypeAbstractInfantry;
    
    // Time has expired, add another market.
    int marketPlanID = aiPlanCreate("BuildNearbyMarket", cPlanBuild);
    if (marketPlanID >= 0)
    {
        aiPlanSetVariableInt(marketPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeMarket);
        aiPlanSetVariableInt(marketPlanID, cBuildPlanNumAreaBorderLayers, 0, 2);
        aiPlanSetVariableInt(marketPlanID, cBuildPlanAreaID, 0, mainBaseAreaID);        
        aiPlanSetDesiredPriority(marketPlanID, 100);
        aiPlanAddUnitType(marketPlanID, builderType, 1, 1, 1);
        aiPlanSetEscrowID(marketPlanID, cEconomyEscrowID);
        aiPlanSetBaseID(marketPlanID, mainBaseID);
        aiPlanSetActive(marketPlanID);
        gExtraMarket = true; // Set the global so we know to look for SECOND market before trading.
//        xsSetRuleMinIntervalSelf(181);
        xsSetRuleMinIntervalSelf(127);
        firstRun = false;
    }
}


