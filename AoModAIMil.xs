//==============================================================================
// AoMod AI
// AoModAIMil.xs
// This is a modification of Georg Kalus' extension of the default aomx ai file
// by Loki_GdD
//
// military stuff
//==============================================================================


//==============================================================================
rule monitorDefPlans
    minInterval 11 //starts in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("* monitorDefPlans:");

    // Find the defend plans
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);  // Defend plans, any state, active only
    if (activeDefPlans > 0)
    {
        int mainBaseID = kbBaseGetMainID(cMyID);
        vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
        
        int numEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    
        int numMilUnitsInOB1DefPlan = aiPlanGetNumberUnits(gOtherBase1DefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInOB2DefPlan = aiPlanGetNumberUnits(gOtherBase2DefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInOB3DefPlan = aiPlanGetNumberUnits(gOtherBase3DefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInOB4DefPlan = aiPlanGetNumberUnits(gOtherBase4DefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInBUADefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInSPDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInMBDefPlan1 = aiPlanGetNumberUnits(gMBDefPlan1ID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInMBDefPlans = numMilUnitsInMBDefPlan1;
        if (aiPlanGetBaseID(gDefendPlanID) == mainBaseID)
            numMilUnitsInMBDefPlans = numMilUnitsInMBDefPlans + numMilUnitsIngDefendPlan;
        
        float woodSupply = kbResourceGet(cResourceWood);
        float foodSupply = kbResourceGet(cResourceFood);
        float goldSupply = kbResourceGet(cResourceGold);
        
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;
            
            int numMilUnitsInDefPlan = aiPlanGetNumberUnits(defendPlanID, cUnitTypeLogicalTypeLandMilitary);
            
            vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
            int mySettlementsAtDefPoint = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID, defPlanDefPoint, 15.0);
            float distToMainBase = xsVectorLength(mainBaseLocation - defPlanDefPoint);
            
            int militaryUnitType = cUnitTypeMilitary;
            int enemyMilUnitsInR40 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 40.0, true);
            int enemyMilUnitsInR45 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 45.0, true);
            int enemyMilUnitsInR50 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int enemyMilUnitsInR80 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 80.0, true);
            
            int numAttEnemyMilUnitsInR45 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 45.0, true);
            int numAttEnemyMilUnitsInR80 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 80.0, true);

            int numAttEnemySiegeInR35 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
            int numAttEnemySiegeInR45 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 45.0, true);
            
            int numAttEnemyTitansInR50 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int requiredUnits = enemyMilUnitsInR80;
            
            int defPlanBaseID = aiPlanGetBaseID(defendPlanID);
            int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, defPlanBaseID);

            if (((defendPlanID == gDefendPlanID) && (defPlanBaseID == mainBaseID)) || (defendPlanID == gMBDefPlan1ID))
            {        
                if (defendPlanID == gMBDefPlan1ID)
                {
                    if ((numAttEnemyMilUnitsInR80 > 10) || (numEnemyTitansNearMBInR80 > 0))
                    {
                        if ((requiredUnits < 30) && (numEnemyTitansNearMBInR80 > 0))
                        {
                            //since there's an enemy Titan near our main base we need a lot of units
                            requiredUnits = 30;    //fake number to force a lot of units into our defend plan
                        }
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, requiredUnits / 4, requiredUnits / 2 + 3, requiredUnits / 2 + 3);
                    }
                    else
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 1);
                    
                    if ((secondsUnderAttack > 0) || (enemyMilUnitsInR80 > 8))
                        aiPlanSetDesiredPriority(defendPlanID, 50);
                    else
                    {
                            aiPlanSetDesiredPriority(defendPlanID, 38); //TODO: find the best value
                    }
                    
                    //override if there is an enemy Titan near our main base
                    if (numEnemyTitansNearMBInR80 > 0)
                        aiPlanSetDesiredPriority(defendPlanID, 60);
                }
		        aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 54.0);  //just a little less, keepUnitsWithinRange will pull them farther back
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
                continue;
            }
            else if ((defendPlanID == gOtherBase1DefPlanID) || (defendPlanID == gOtherBase2DefPlanID)
                  || (defendPlanID == gOtherBase3DefPlanID) || (defendPlanID == gOtherBase4DefPlanID)
                  || ((defendPlanID == gDefendPlanID) && (defPlanBaseID != mainBaseID)))
            {
                if (defendPlanID == gDefendPlanID)
                {
                    if (aiPlanGetBaseID(gBaseUnderAttackDefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInBUADefPlan;
                    if (aiPlanGetBaseID(gSettlementPosDefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInSPDefPlan;
                    if (aiPlanGetBaseID(gOtherBase1DefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB1DefPlan;
                    else if (aiPlanGetBaseID(gOtherBase2DefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB2DefPlan;
                    else if (aiPlanGetBaseID(gOtherBase3DefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB3DefPlan;
                    else if (aiPlanGetBaseID(gOtherBase4DefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB4DefPlan;
                }
                else
                {
                    if (aiPlanGetBaseID(gBaseUnderAttackDefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInBUADefPlan;
                    if (aiPlanGetBaseID(gSettlementPosDefPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInSPDefPlan;
                    if (aiPlanGetBaseID(gDefendPlanID) == defPlanBaseID)
                        numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsIngDefendPlan;
                }
                aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 48.0);  //just a little less, keepUnitsWithinRange will pull them farther back
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
                    
                if (defendPlanID != gDefendPlanID)
                {
                    if ((secondsUnderAttack > 0) || (numMilUnitsInDefPlan < enemyMilUnitsInR45))
                    {
                        aiPlanSetDesiredPriority(defendPlanID, 56);
                        if ((numAttEnemyMilUnitsInR45 > 4) || (numAttEnemySiegeInR45 > 0) || (numAttEnemyTitansInR50 > 0))
                            aiPlanAddUnitType(defendPlanID, cUnitTypeHero, 0, 1, 1);
                        else
                            aiPlanAddUnitType(defendPlanID, cUnitTypeHero, 0, 0, 1);
                    }
                    else
                    {
                        aiPlanAddUnitType(defendPlanID, cUnitTypeHero, 0, 0, 1);
                        if (distToMainBase < 70)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 25);
                        }
                        else if (distToMainBase < 90)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 27);
                        }
                        else if (distToMainBase < 110)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 29);
                        }
                        else if (distToMainBase < 130)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 31);
                        }
                        else
                        {
                            aiPlanSetDesiredPriority(defendPlanID, 33);
                        }
                    }
                    continue;
                }
                continue;
            }
            else if (defendPlanID == gSettlementPosDefPlanID)
            {
                
                if (aiPlanGetBaseID(gBaseUnderAttackDefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInBUADefPlan;
                if (aiPlanGetBaseID(gDefendPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsIngDefendPlan;
                if (aiPlanGetBaseID(gOtherBase1DefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB1DefPlan;
                else if (aiPlanGetBaseID(gOtherBase2DefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB2DefPlan;
                else if (aiPlanGetBaseID(gOtherBase3DefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB3DefPlan;
                else if (aiPlanGetBaseID(gOtherBase4DefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB4DefPlan;
					
				aiPlanSetNumberVariableValues(defendPlanID, cDefendPlanAttackTypeID, 4, true);
                aiPlanSetVariableInt(defendPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
			    aiPlanSetVariableInt(defendPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeAbstractVillager);
				aiPlanSetVariableInt(defendPlanID, cDefendPlanAttackTypeID, 2, cUnitTypeBuildingsThatShoot);
				aiPlanSetVariableInt(defendPlanID, cDefendPlanAttackTypeID, 3, cUnitTypeBuilding);
                               
			    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 48.0);  //just a little less, keepUnitsWithinRange will pull them farther back
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
	            int NumEnemyBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 55.0, true);	
                int priorityA = 48;
                if (distToMainBase > 90.0)
                    priorityA = 52;
                static int countA = 0;
                static int resourceCountA = 0; // add more
                if ((enemyMilUnitsInR50 < 4) && (numAttEnemySiegeInR45 < 1) && (numAttEnemyTitansInR50 < 1))
                {
                    if (countA <= 14)
                    {
                        if ((distToMainBase < 85.0) && (NumEnemyBuildings > 6))
                            aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 12, 18, 20);
                        else
                        {
                            if ((distToMainBase > 100.0) && (NumEnemyBuildings > 6))
                                aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 14, 22, 25);
                            else
                                aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 5, 8, 10);
                        }
                        
                        if (countA >= 12)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityA * 0.3);
                        }
                        else if (countA >= 9)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityA * 0.5);
                        }
                        else if (countA >= 6)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityA * 0.7);
                        }
                        else if (countA >= 3)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityA * 0.9);
                        }
                        countA = countA + 1;
                        continue;
                    }
                    else
                    {
                        countA = 0;
                        xsSetRuleMinInterval("defendSettlementPosition", 1);
                        xsDisableRule("defendSettlementPosition");
                        aiPlanDestroy(defendPlanID);
                        continue;
                    }
                }
                else
                {
                    if (enemyMilUnitsInR50 > 18)
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 11, enemyMilUnitsInR50 + 8, enemyMilUnitsInR50 + 8);
                    
                    if ((((woodSupply < 350) || (goldSupply < 350)) && (mySettlementsAtDefPoint < 1)) || ((woodSupply < 300) && (goldSupply < 300) && (foodSupply < 300)))
                    {
                        if (resourceCountA <= 1)
                            resourceCountA = resourceCountA + 1;
                        else
                        {
                            resourceCountA = 0;
                            xsSetRuleMinInterval("defendSettlementPosition", 1);
                            xsDisableRule("defendSettlementPosition");
                            aiPlanDestroy(defendPlanID);
                            continue;
                        }
                    }
                    else
                        resourceCountA = 0;
                    countA = 0;
                    aiPlanSetDesiredPriority(defendPlanID, priorityA);
                    continue;
                }
            }
            else if (defendPlanID == gBaseUnderAttackDefPlanID)
            {
                
                if (aiPlanGetBaseID(gSettlementPosDefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInSPDefPlan;
                if (aiPlanGetBaseID(gDefendPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsIngDefendPlan;
                if (aiPlanGetBaseID(gOtherBase1DefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB1DefPlan;
                else if (aiPlanGetBaseID(gOtherBase2DefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB2DefPlan;
                else if (aiPlanGetBaseID(gOtherBase3DefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB3DefPlan;
                else if (aiPlanGetBaseID(gOtherBase4DefPlanID) == defPlanBaseID)
                    numMilUnitsInDefPlan = numMilUnitsInDefPlan + numMilUnitsInOB4DefPlan;

                aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 45.0);  //just a little less, keepUnitsWithinRange will pull them farther back
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
                    
                int priorityB = 53;
                static int countB = 0;
                static int resourceCountB = 0;
                if ((enemyMilUnitsInR40 < 6) && (numAttEnemySiegeInR45 - numAttEnemySiegeInR35 < 1) && (numAttEnemyTitansInR50 < 1))
                {
                    if (countB <= 7)
                    {
                        if (distToMainBase < 80.0)
                            aiPlanAddUnitType(defendPlanID, cUnitTypeHumanSoldier, 4, 16, 16);
                        else
                        {
                            if (distToMainBase > 110.0)
                                aiPlanAddUnitType(defendPlanID, cUnitTypeHumanSoldier, 8, 20, 20);
                            else
                                aiPlanAddUnitType(defendPlanID, cUnitTypeHumanSoldier, 5, 18, 18);
                        }
                        
                        if (countB >= 6)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityB * 0.3);
                        }
                        else if (countB >= 4)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityB * 0.5);
                        }
                        else if (countB >= 2)
                        {
                            aiPlanSetDesiredPriority(defendPlanID, priorityB * 0.7);
                        }
                        countB = countB + 1;
                        continue;
                    }
                    else
                    {
                        countB = 0;
                        xsSetRuleMinInterval("defendBaseUnderAttack", 1);
                        xsDisableRule("defendBaseUnderAttack");
                        aiPlanDestroy(defendPlanID);
                        continue;
                    }
                }
                else
                {
                    if (enemyMilUnitsInR40 > 16)
                        aiPlanAddUnitType(defendPlanID, cUnitTypeHumanSoldier, 8, enemyMilUnitsInR40 + 6, enemyMilUnitsInR40 + 6);
                    
                    if ((((woodSupply < 300) || (goldSupply < 300)) && (mySettlementsAtDefPoint < 1)) || ((woodSupply < 300) && (goldSupply < 300) && (foodSupply < 300)))
                    {
                        if (resourceCountB <= 1)
                            resourceCountB = resourceCountB + 1;
                        else
                        {
                            resourceCountB = 0;
                            xsSetRuleMinInterval("defendBaseUnderAttack", 1);
                            xsDisableRule("defendBaseUnderAttack");
                            aiPlanDestroy(defendPlanID);
                            
                            aiPlanDestroy(gDefendPlanID);
                            gDefendPlanID = -1;
                            xsDisableRule("defendPlanRule");
                            gBaseUnderAttackID = -1;
                            
                            xsSetRuleMinInterval("defendPlanRule", 2);
                            xsEnableRule("defendPlanRule");
                            continue;
                        }
                    }
                    else
                        resourceCountB = 0;
                    countB = 0;
                    aiPlanSetDesiredPriority(defendPlanID, priorityB);
                    continue;
                }
            }
        }
    }
}

//==============================================================================
rule monitorAttPlans
    minInterval 7 //starts in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("* monitorAttackPlans:");
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numAttEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numEnemyMilUnitsNearMBInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 70.0, true);
    int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numAttEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);

    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyMilUnitsNearDefBInR50 = 0;
    int numAttEnemyMilUnitsNearDefBInR50 = 0;
    int numEnemyMilUnitsNearDefBInR40 = 0;
    int numEnemyTitansNearDefBInR55 = 0;
    int numAttEnemySiegeNearDefBInR50 = 0;

    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            numEnemyMilUnitsNearDefBInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 50.0, true);
            numAttEnemyMilUnitsNearDefBInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 50.0, true);
            numEnemyMilUnitsNearDefBInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 40.0, true);
            numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
            numAttEnemySiegeNearDefBInR50 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 50.0, true);
        }
    }
    
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();
	
	int number = 0;
	if (mPopLandAttack == true)
	{
	int numTcs=kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
	if (numTcs > 2)
	{
    number = numTcs * 8 - 10;
    if (currentPopCap >= 300)
	number = 50;
	}
    }
    
    int mainBaseUnderAttack = kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
    
    int mostHatedPlayerID = aiGetMostHatedPlayerID();
    int numMHPlayerSettlements = kbUnitCount(mostHatedPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    
    // Find the attack plans
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true );  // Attack plans, any state, active only
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (attackPlanID == -1)
                continue;
            
            int planState = aiPlanGetState(attackPlanID);
            float attPlanPriority = aiPlanGetDesiredPriority(attackPlanID);
            vector attPlanPosition = aiPlanGetLocation(attackPlanID);
            vector attPlanRetreatPosition = aiPlanGetInitialPosition(attackPlanID);
            float attPlanDistance = xsVectorLength(attPlanPosition - attPlanRetreatPosition);
            int numMilUnitsNearAttPlan = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, attPlanPosition, 50.0);
            int numAlliedMilUnitsNearAttPlan = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, attPlanPosition, 50.0, true);
            int numEnemyMilUnitsNearAttPlan = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, attPlanPosition, 30.0, true);
            int numEnemyBuildingsThatShootNearAttPlanInR25 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, attPlanPosition, 25.0, true);
            
            int numTitansInPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeAbstractTitan);
            int numMilUnitsInPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeLogicalTypeLandMilitary);
            
            static int killSettlementAttPlanCount = -1;
            static int killRandomAttPlanCount = -1;
            static int killRaidAttPlanCount = -1;
            static int killLandAttPlanCount = -1;
            
            if (attackPlanID == gEnemySettlementAttPlanID)
            {
                static int countA = 0;
                float distanceA = 30.0;
                if (ShowAiEcho == true) aiEcho("gEnemySettlementAttPlanID:  "+attackPlanID+"");
				if (ShowAiEcho == true) aiEcho("NumInPlan:  "+numMilUnitsInPlan+"");
                if (killSettlementAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killSettlementAttPlanCount = -1;
                    }
                    else
                    {
                        if ((aiPlanGetNoMoreUnits(attackPlanID) == true) && (numMilUnitsInPlan < 5) || (numAttEnemyTitansNearMBInR85 > 0) || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 2) && (planState < cPlanStateAttack) 
						|| (gTransportMap == true) && (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0))
                        {
                            if (DisallowPullBack == false) 
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
							//aiEcho("PullBack 1");
                            if ((killSettlementAttPlanCount >= 4) || (attPlanDistance < 25.0))
                            {
                                aiPlanDestroy(attackPlanID);
                                gEnemySettlementAttPlanTargetUnitID = -1;
                                killSettlementAttPlanCount = -1;
                                continue;
                            }
                            killSettlementAttPlanCount = killSettlementAttPlanCount + 1;
							if ((numMilUnitsInPlan < 5) || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 2) && (planState < cPlanStateAttack) 
							|| (gTransportMap == true) && (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0))
							killSettlementAttPlanCount = killSettlementAttPlanCount + 1; // kill the plan faster.
                            continue;
                        }
                        else
                        {
                            killSettlementAttPlanCount = -1;
                            aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        }
                    }
                }
                

                if (numAttEnemyTitansNearMBInR85 > 0)
                {
                    countA = 0;
                    if (planState < cPlanStateAttack)
                    {
                        aiPlanDestroy(attackPlanID);
                        gEnemySettlementAttPlanTargetUnitID = -1;
                    }
                    else
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        if (DisallowPullBack == false) 
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
						//aiEcho("PullBack 2");
                        killSettlementAttPlanCount = 0;
                    }
                    continue;
                }
                
                if ((kbUnitGetCurrentHitpoints(gEnemySettlementAttPlanTargetUnitID) <= 0) && (gEnemySettlementAttPlanTargetUnitID != -1))
                {
                    if (countA == -1)
                    {
                        //aiPlanDestroy(attackPlanID);
                        gEnemySettlementAttPlanTargetUnitID = -1;
						aiPlanSetVariableInt(gEnemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0, -1);
                        if (ShowAiEcho == true) aiEcho ("destroying gEnemySettlementAttPlanID as the target has been destroyed");
                        countA = 0;
                        continue;
                    }
                    
                    if (gSettlementPosDefPlanID > 0)
                    {
                        xsSetRuleMinInterval("defendSettlementPosition", 1);
                        xsDisableRule("defendSettlementPosition");
                        aiPlanDestroy(gSettlementPosDefPlanID);
                    }
                    gSettlementPosDefPlanDefPoint = gEnemySettlementAttPlanLastAttPoint;
					aiPlanSetVariableVector(attackPlanID, cAttackPlanGatherPoint, 0, gEnemySettlementAttPlanLastAttPoint);
                    aiPlanSetDesiredPriority(attackPlanID, 52);
					xsEnableRule("defendSettlementPosition");
                    countA = -1;
                    continue;
                }
                
                if (planState < cPlanStateAttack)
                {
                    if ((numAttEnemyMilUnitsNearMBInR85 > 10) || (numEnemyMilUnitsNearMBInR70 > 14)
                     || (numAttEnemyMilUnitsNearDefBInR50 > 6) || (numEnemyMilUnitsNearDefBInR40 > 10)
                     || (numAttEnemySiegeNearDefBInR50 > 0) && (numEnemyMilUnitsNearDefBInR40 > 3))
					 
                    {
                        countA = 0;
                        if ((numEnemyMilUnitsNearMBInR70 > 14) || (numEnemyMilUnitsNearDefBInR40 > 14) && (attPlanPriority <= 41))
                        {
                            aiPlanDestroy(attackPlanID);
                            if (ShowAiEcho == true) aiEcho ("destroying gEnemySettlementAttPlanID as there are too many enemies");
                            continue;
                        }
                        else
                        {
                            aiPlanSetDesiredPriority(attackPlanID, 41);
                        }
                    }
                    else
                    {
                        if (numTitansInPlan > 0)
                        {
                            aiPlanSetDesiredPriority(attackPlanID, 55);
                        }
                        else
                        {
                            aiPlanSetDesiredPriority(attackPlanID, 52);
                        }
                    }
                    
                    // Check to see if the gather phase is taking too long and just launch the attack if so.
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 10*1000) && (aiPlanGetState(attackPlanID) == cPlanStateGather))
                    {
                        if ((numEnemyMilUnitsNearMBInR70 > 10) || (numEnemyMilUnitsNearDefBInR40 > 6))
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, distanceA / 2);
                            countA = 0;
                        }
                        else
                        {
                            if (countA < 0)
                                countA = 0;
								aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 300.0);
                            countA = countA + 1;
                        }
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    countA = 0;
                    if (numTitansInPlan > 0)
                    {
                        aiPlanSetDesiredPriority(attackPlanID, 90);
                    }
                    else
                    {
                        float distanceToTarget = xsVectorLength(mainBaseLocation - kbUnitGetPosition(gEnemySettlementAttPlanTargetUnitID));
                        if ((currentPop <= currentPopCap - 6 - number) && (distanceToTarget > 110.0) && (aiRandInt(5) < 1) && (numMilUnitsInPlan < 5) )
                        {
                            aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                            aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                            if (DisallowPullBack == false) 
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
							//aiEcho("PullBack 3");
                            killSettlementAttPlanCount = 0;
                        }
                        else if ((numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan * 5) 
                              && (numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && (aiPlanGetNoMoreUnits(attackPlanID) == true)
                              && (currentPop <= currentPopCap - 6 - number * 0.95) && (numMilUnitsInPlan < 5))
                        {
                            aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                            aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);                            
                            if (DisallowPullBack == false)
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
							//aiEcho("PullBack 4");
                            killSettlementAttPlanCount = 0; 
                        }
                    }
                    continue;
                }
            }
            else if (attackPlanID == gRandomAttackPlanID)
            {
                static int countB = 0;
                float distanceB = 25.0;
				if (ShowAiEcho == true) aiEcho("gRandomAttackPlanID:  "+attackPlanID+"");
				if (ShowAiEcho == true) aiEcho("NumInPlan:  "+numMilUnitsInPlan+"");
                
                if (killRandomAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killRandomAttPlanCount = -1;
                    }
                    else
                    {
                        if (DisallowPullBack == false) 
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        if ((killRandomAttPlanCount >= 4) || (attPlanDistance < 25.0))
                        {
                            aiPlanDestroy(attackPlanID);
                            gRandomAttackTargetUnitID = -1;
                            killRandomAttPlanCount = -1;
                            continue;
                        }
                        killRandomAttPlanCount = killRandomAttPlanCount + 1;
                        continue;
                    }
                }
                
                if ((numEnemyTitansNearMBInR85 > 0) || (numEnemyTitansNearDefBInR55 > 0) || (numTitansInPlan > 0))
                {
                    countB = 0;
                    if (planState < cPlanStateAttack)
                    {
                        aiPlanDestroy(attackPlanID);
                        gRandomAttackTargetUnitID = -1;
                    }
                    else
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        if (DisallowPullBack == false) 
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killRandomAttPlanCount = 0;
                    }
                        
                    continue;
                }
                
                if (planState < cPlanStateAttack)
                {
                    if ((numEnemyMilUnitsNearMBInR85 > 8) || (numEnemyMilUnitsNearDefBInR50 > 6))
                    {
                        countB = 0;
                        if ((numEnemyMilUnitsNearMBInR70 > 11) || (numEnemyMilUnitsNearDefBInR40 > 9) && (attPlanPriority <= 20))
                        {
                            aiPlanDestroy(attackPlanID);
                            if (ShowAiEcho == true) aiEcho ("destroying gRandomAttackPlanID as there are too many enemies");
                            continue;
                        }
                        else
                        {
                            aiPlanSetDesiredPriority(attackPlanID, 20);
                        }
                    }
                    else
                    {
                        aiPlanSetDesiredPriority(attackPlanID, 50);
                    }
                    
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 10*1000) && (aiPlanGetState(attackPlanID) == cPlanStateGather))
                    {
                        if ((numEnemyMilUnitsNearMBInR85 > 6) || (numEnemyMilUnitsNearDefBInR50 > 6))
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, distanceB / 2);
                            countB = 0;
                        }
                        else
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 300.0);
                            countB = countB + 1;
                        }
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    countB = 0;
                    if ((numMilUnitsInPlan < 3)
                     || (numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && (numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan * 3) && (numMilUnitsInPlan < 3)
                     || (numEnemyBuildingsThatShootNearAttPlanInR25 > 0) && (numMilUnitsInPlan < 3))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        if (DisallowPullBack == false) 
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killRandomAttPlanCount = 0;
                        if  (numMilUnitsInPlan < 3)
                        if (ShowAiEcho == true) aiEcho ("Destroying gRandomAttackPlanID as less than 3 units in the plan");
                        else
                        if (ShowAiEcho == true) aiEcho ("Destroying gRandomAttackPlanID as there are too many enemies");
                    }
                    continue;
                }
            }
            else if (attackPlanID == gRaidingPartyAttackID)
            {
                
                if (killRaidAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killRaidAttPlanCount = -1;
                    }
                    else
                    {
                        if (DisallowPullBack == false) 
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        if ((killRaidAttPlanCount >= 4) || (attPlanDistance < 25.0))
                        {
                            aiPlanDestroy(attackPlanID);
                            gRaidingPartyTargetUnitID = -1;
                            killRaidAttPlanCount = -1;
                            continue;
                        }
                        killRaidAttPlanCount = killRaidAttPlanCount + 1;
                        continue;
                    }
                }
                
                if (planState < cPlanStateAttack)
                {
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0)
                    {
                        killRaidAttPlanCount = -1;
                        aiPlanDestroy(attackPlanID);
                        gRaidingPartyTargetUnitID = -1;
                        continue;
                    }
                    
                    if (mainBaseUnderAttack > 0)
                    {
                        aiPlanSetDesiredPriority(attackPlanID, 15);
                    }
                    else
                    {
                        if (aiPlanGetDesiredPriority(attackPlanID) < 34)
                            aiPlanSetDesiredPriority(attackPlanID, 34);
                    }
                }
                else if (planState == cPlanStateAttack)
                {
                    if ((numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.5) && ((numEnemyBuildingsThatShootNearAttPlanInR25 > 0)
                     || (numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan * 5)))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        if (DisallowPullBack == false) 
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killRaidAttPlanCount = 0;
                    }
                    continue;
                }
            }
            else if (attackPlanID == gEnemyWonderDefendPlan)
            {
                if (planState < cPlanStateAttack)
                {
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 60*1000))
                    {
                        if (aiPlanGetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0) != 200.0)
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 200.0);
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 200, 200, 200);
                    aiPlanSetDesiredPriority(attackPlanID, 99);
                        
                    aiPlanDestroy(gDefendPlanID);
                    aiPlanDestroy(gMBDefPlan1ID);
                    aiPlanDestroy(gOtherBase1DefPlanID);
                    aiPlanDestroy(gOtherBase2DefPlanID);
                    aiPlanDestroy(gOtherBase3DefPlanID);
                    aiPlanDestroy(gOtherBase4DefPlanID);
                    continue;
                }
            }
            else if (attackPlanID == gLandAttackPlanID)
            {
                static int countD = 0;
                float distanceD = 25.0;
                if (ShowAiEcho == true) aiEcho("gLandAttackPlanID:  "+attackPlanID+"");
				if (ShowAiEcho == true) aiEcho("NumInPlan:  "+numMilUnitsInPlan+"");
                if (killLandAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killLandAttPlanCount = -1;
                    }
                    else
                    {
                        if (DisallowPullBack == false) 
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        if ((killLandAttPlanCount >= 4) || (attPlanDistance < 25.0))
                        {
                            aiPlanDestroy(attackPlanID);
                            killLandAttPlanCount = -1;
							if (ShowAiEcho == true) aiEcho("Killing gLandAttackPlanID, Count >=4");
                            continue;
                        }
                        killLandAttPlanCount = killLandAttPlanCount + 1;
					    if (numMilUnitsInPlan < 5)
						killLandAttPlanCount = killLandAttPlanCount + 1; // kill the plan faster.
                        continue;
                    }
                }
                
                if ((numEnemyTitansNearMBInR85 > 0) || (numEnemyTitansNearDefBInR55 > 0) || ((numMHPlayerSettlements > 0) && (numTitansInPlan > 0)))
                {
                    countD = 0;
                    if (planState < cPlanStateAttack)
                    {
                        aiPlanDestroy(attackPlanID);
                    }
                    else
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        if (DisallowPullBack == false) 
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killLandAttPlanCount = 0;
                    }                
                    continue;
                }
                
                if (planState < cPlanStateAttack)
                {
                    if ((numEnemyMilUnitsNearMBInR85 > 10) || (numEnemyMilUnitsNearDefBInR50 > 6))
                    {
                        countD = 0;
                        if (kbGetAge() == cAge2)
                        {
                            killLandAttPlanCount = -1;
                            aiPlanDestroy(attackPlanID);
                            gRushAttackCount = gRushAttackCount -1;
                        }
                        else
                        {
                            if (((numEnemyMilUnitsNearMBInR70 > 20) || (numEnemyMilUnitsNearDefBInR40 > 20)) && (attPlanPriority <= 40))
                            {
                                aiPlanDestroy(attackPlanID);
                                if (ShowAiEcho == true) aiEcho ("destroying gLandAttackPlanID as there are too many enemies 1");
                                continue;
                            }
                            else
                            {
                                aiPlanSetDesiredPriority(attackPlanID, 40);
                            }
                        }
                    }
                    else
                    {
                        aiPlanSetDesiredPriority(attackPlanID, 50);
                    }
                    
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 10*1000) && (aiPlanGetState(attackPlanID) == cPlanStateGather))
                    {
                        if ((numEnemyMilUnitsNearMBInR85 > 14) || (numEnemyMilUnitsNearDefBInR50 > 14))
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, distanceD / 2);
                            countD = 0;
                        }
                        else
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 300.0);
                            countD = countD + 1;
                        }
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    countD = 0;
                    if (((kbGetAge() > cAge2) && (numMilUnitsInPlan < 3))
                     || (numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && (numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan * 5) && (numMilUnitsInPlan < 3)
                     || (kbGetAge() > cAge2) && (numEnemyBuildingsThatShootNearAttPlanInR25 > 0) && (numMilUnitsInPlan < 3) && (aiRandInt(3) == 1))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        if (DisallowPullBack == false) 
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killLandAttPlanCount = 0;
                    }
                    continue;
                }
            }
        }
    }
}

//==============================================================================
rule defendPlanRule
    minInterval 61 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("defendPlanRule:");
    
    if ((kbGetAge() < cAge2) && (xsGetTime() < 5*60*1000))
        return;
    
    xsSetRuleMinIntervalSelf(61);
    static int defendCount = 0;      // For plan numbering
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    static int defendPlanStartTime = -1;
	
    int numAttEnemyMilUnitsNearMBInR60 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int myMilUnitsNearMBInR80 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 80.0);

    int baseToUse = mainBaseID;
    if ((gBaseUnderAttackID != -1) && (equal(gBaseUnderAttackLocation, cInvalidVector) == false) && (numAttEnemyMilUnitsNearMBInR60 < 11))
    {
        baseToUse = gBaseUnderAttackID;
    }

    bool defendPlanActive = false;
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;
                
            if (defendPlanID == gDefendPlanID)
            {
                defendPlanActive = true;		
				 
                int defPlanBaseID = aiPlanGetBaseID(defendPlanID);
                if (defPlanBaseID != baseToUse)
                {
                    vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                    int enemySettlementsAtDefPlanDefPoint = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 15.0);
                    int motherNatureSettlementsAtDefPlanDefPoint = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, defPlanDefPoint, 15.0);
    
                    if ((numEnemyTitansNearMBInR80 > 0) || (enemySettlementsAtDefPlanDefPoint - motherNatureSettlementsAtDefPlanDefPoint > 0)
                     || ((numAttEnemyMilUnitsNearMBInR80 > 12) && (numAttEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 1.4)))
                    {
                        aiPlanDestroy(defendPlanID);
                        gDefendPlanID = -1;
                        xsSetRuleMinIntervalSelf(2);
                        if (ShowAiEcho == true) aiEcho("destroying current gDefendPlanID and restarting defendPlanRule");
                        return;
                    }
                }				
            }
        }
    } 
    
    //If we already have a gDefendPlan, don't make another one.
    if (defendPlanActive == true)
    {
        return;
    }
    
    int defPlanID = aiPlanCreate("Defend plan #"+defendCount, cPlanDefend);
    if (defPlanID != -1)
    {
        defendCount = defendCount + 1;
        aiPlanSetVariableInt(defPlanID, cDefendPlanRefreshFrequency, 0, 10);
		if (gTransportMap == true)
        baseToUse = mainBaseID;
		aiPlanSetVariableVector(defPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, baseToUse));
        aiPlanSetVariableFloat(defPlanID, cDefendPlanEngageRange, 0, 50.0);
        aiPlanSetVariableFloat(defPlanID, cDefendPlanGatherDistance, 0, 30.0);
        aiPlanSetUnitStance(defPlanID, cUnitStanceDefensive);
        aiPlanSetVariableBool(defPlanID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(defPlanID, cDefendPlanAttackTypeID, 3, true);
        aiPlanSetVariableInt(defPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(defPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);
		aiPlanSetVariableInt(defPlanID, cDefendPlanAttackTypeID, 2, cUnitTypeAbstractVillager);

        aiPlanAddUnitType(defPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 200, 200);  // was 0 200, 200

        aiPlanSetDesiredPriority(defPlanID, 20);    // Way below others
        

		aiPlanSetBaseID(defPlanID, baseToUse);
        defendPlanStartTime = xsGetTime();
        aiPlanSetActive(defPlanID);
        gDefendPlanID = defPlanID;
    }
}

//==============================================================================
// RULE activateObeliskClearingPlan
//==============================================================================
rule activateObeliskClearingPlan // + vil hunting
    inactive
    minInterval 109 //starts in cAge2
{
    if (ShowAiEcho == true) aiEcho("activateObeliskClearingPlan:");
        
    int mainBaseID = kbBaseGetMainID(cMyID);
    static int obeliskPlanCount = 0;
    // We found targets, make a plan if we don't have one.
	aiPlanSetVariableVector(gObeliskClearingPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
    aiPlanSetBaseID(gObeliskClearingPlanID, mainBaseID);
    if ( (gObeliskClearingPlanID < 0) )
    {
        gObeliskClearingPlanID = aiPlanCreate("Obelisk plan #"+obeliskPlanCount, cPlanDefend);
        obeliskPlanCount = obeliskPlanCount + 1;

        if (gObeliskClearingPlanID < 0)
            return;
   
        aiPlanSetVariableVector(gObeliskClearingPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
        aiPlanSetVariableFloat(gObeliskClearingPlanID, cDefendPlanEngageRange, 0, 110.0);   //only in close range
        aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanRefreshFrequency, 0, 15);
        aiPlanSetVariableFloat(gObeliskClearingPlanID, cDefendPlanGatherDistance, 0, 40.0);

        aiPlanSetUnitStance(gObeliskClearingPlanID, cUnitStanceDefensive);
        aiPlanSetNumberVariableValues(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 2, false);
		aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeOutpost);
        aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeAbstractVillager);	
        
        if (cMyCulture == cCultureChinese)
		aiPlanAddUnitType(gObeliskClearingPlanID, cUnitTypeScoutChinese, 1, 1, 1);
		else 
        aiPlanAddUnitType(gObeliskClearingPlanID, cUnitTypeAbstractInfantry, 1, 1, 1);
        aiPlanSetDesiredPriority(gObeliskClearingPlanID, 16);
		aiPlanSetBaseID(gObeliskClearingPlanID, mainBaseID);
        aiPlanSetActive(gObeliskClearingPlanID);
    }
}

//==================================================================================
rule decreaseRaxPref    //Egyptian decrease rax units preference if has at least two Migdols
    minInterval 67 //starts in cAge3
    inactive
{  
    if (ShowAiEcho == true) aiEcho("decreaseRaxPref:");
    
    int numFortresses=kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAlive);
    if (numFortresses < 1)
        return;

    if (aiRandInt(4) == 0)	// 20% chance of A.I. going rax
    {
        xsDisableSelf();
        return;
    }

    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeAxeman, 0.2);
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeSpearman, 0.3);
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeSlinger, 0.1);
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeCamelry, 0.6);
    if (gAge3MinorGod == cTechAge3Sekhmet)
        kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeChariotArcher, 0.8);
    else
        kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeChariotArcher, 0.6);
    if (gAge4MinorGod == cTechAge4Thoth)		
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeWarElephant, 0.4);
	else    
	kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeWarElephant, 0.3);

    xsDisableSelf(); 
}

//==============================================================================
rule mainBaseDefPlan1   //Make a defend plan that protects the main base
    minInterval 8 //starts in cAge1
    inactive
{
    if (ShowAiEcho == true) aiEcho("mainBaseDefPlan1:");
  
    if (kbGetAge() < cAge2)
        return;
        
    static bool alreadyInAge3 = false;
    Vector Temp = cInvalidVector;
    if ((kbGetAge() == cAge3) && (alreadyInAge3 == false))
    {
        alreadyInAge3 = true;
        aiPlanDestroy(gMBDefPlan1ID);
        gMBDefPlan1ID = -1;
		xsSetRuleMinIntervalSelf(20);
        if (ShowAiEcho == true) aiEcho("destroying gMBDefPlan1ID");
    }
        
    int mainBaseID = kbBaseGetMainID(cMyID);

    //If we already have a mainBaseDefPlan1, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;
                
            if (defendPlanID == gMBDefPlan1ID)
            {
		    int activeGatherPlans = aiPlanGetNumber(cPlanGather, -1, true);
		    for (f = 0; < activeGatherPlans)
            {
			
            int foodGatherPlanID = aiPlanGetIDByIndex(cPlanGather, cPlanStateGather , true, f);
            int resourceID = aiPlanGetVariableInt(foodGatherPlanID, cGatherPlanResourceID, 0);
            if (resourceID == cResourceFood)
            {
			int Agg = findPlanByString("AutoGPFoodHuntAggressive", cPlanGather);
			int Easy = findPlanByString("AutoGPFoodEasy", cPlanGather);
			if (Agg != -1)
			Temp = aiPlanGetLocation(Agg);
			else 
			Temp = aiPlanGetLocation(Easy);
			if (equal(Temp, cInvalidVector) == false)
			{
			aiPlanSetVariableVector(gMBDefPlan1ID, cDefendPlanDefendPoint, 0, Temp);
			aiPlanSetVariableFloat(gMBDefPlan1ID, cDefendPlanGatherDistance, 0, 10.0);
			return;
			}
			}
			}
			    aiPlanSetVariableVector(gMBDefPlan1ID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
			    aiPlanSetVariableFloat(gMBDefPlan1ID, cDefendPlanGatherDistance, 0, 25.0);
                if (ShowAiEcho == true) aiEcho("mainBaseDefPlan1 exists: ID is "+defendPlanID);
                return;
            }
        }
    }

    int mainBaseDefPlan1ID = aiPlanCreate("mainBaseDefPlan1", cPlanDefend);
    if (mainBaseDefPlan1ID != -1)
    {
        aiPlanSetVariableInt(mainBaseDefPlan1ID, cDefendPlanRefreshFrequency, 0, 15);
        aiPlanSetVariableVector(mainBaseDefPlan1ID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
        
        aiPlanSetVariableFloat(mainBaseDefPlan1ID, cDefendPlanEngageRange, 0, 50.0);
        aiPlanSetVariableFloat(mainBaseDefPlan1ID, cDefendPlanGatherDistance, 0, 25.0);
        
        aiPlanSetUnitStance(mainBaseDefPlan1ID, cUnitStanceDefensive);
        aiPlanSetVariableBool(mainBaseDefPlan1ID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(mainBaseDefPlan1ID, cDefendPlanAttackTypeID, 3, true);
        aiPlanSetVariableInt(mainBaseDefPlan1ID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(mainBaseDefPlan1ID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);
		aiPlanSetVariableInt(mainBaseDefPlan1ID, cDefendPlanAttackTypeID, 2, cUnitTypeAbstractVillager);
        
        if (cMyCulture == cCultureNorse)
        {
        aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractInfantry, 0, 1, 2);
        aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeThrowingAxeman, 0, 1, 1);
        aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 0, 1, 1);
        }
        else
        {
        aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractInfantry, 0, 1, 1);
        aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractArcher, 0, 2, 2);
        aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 0, 1, 1);
        }
        

        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
        
		if (gAge2MinorGod == cTechAge2Okeanus)
            aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeFlyingMedic, 1, 1, 1);
        
        aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 2);
            
        aiPlanSetDesiredPriority(mainBaseDefPlan1ID, 40);
        
        aiPlanSetBaseID(mainBaseDefPlan1ID, mainBaseID);
        
        aiPlanSetActive(mainBaseDefPlan1ID);
        gMBDefPlan1ID = mainBaseDefPlan1ID;
        if (ShowAiEcho == true) aiEcho("mainBaseDefPlan1 set active: "+gMBDefPlan1ID);
    }
}

//==============================================================================
rule otherBasesDefPlans //Make defend plans that protect the other bases
    minInterval 43 //starts in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("otherBasesDefPlans:");
    
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (numSettlements < 2)
        return;

    bool otherBase1DefPlan = false;
    bool otherBase2DefPlan = false;
    bool otherBase3DefPlan = false;
    bool otherBase4DefPlan = false;
    
    //If we already have defend plans for all our other bases, don't make another one.	
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;
            
            
            vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
            int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID, defPlanDefPoint, 15.0);

            if (defendPlanID == gOtherBase1DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    if (ShowAiEcho == true) aiEcho("-> destroying gOtherBase1DefPlan, setting gOtherBase1UnitID and gOtherBase1ID to -1");
                    aiPlanDestroy(defendPlanID);
                    gOtherBase1DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase1ID);

                    gOtherBase1UnitID = -1;
                    gOtherBase1ID = -1;
                    if (gBuildWalls == true)
                    {
                        //destroy the wall plan at gOtherBase1UnitID
                        aiPlanDestroy(gOtherBase1RingWallTeamPlanID);
                        xsSetRuleMinInterval("otherBase1RingWallTeam", 11);
                        xsDisableRule("otherBase1RingWallTeam");
                    }
                }
                else
                {
                    otherBase1DefPlan = true;
                }
                continue;
            }
            else if (defendPlanID == gOtherBase2DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    if (ShowAiEcho == true) aiEcho("-> destroying gOtherBase2DefPlan, setting gOtherBase2UnitID and gOtherBase2ID to -1");
                    aiPlanDestroy(defendPlanID);
                    gOtherBase2DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase2ID);
          
                    gOtherBase2UnitID = -1;
                    gOtherBase2ID = -1;
                    if (gBuildWalls == true)
                    {
                        //destroy the wall plan at gOtherBase2UnitID
                        aiPlanDestroy(gOtherBase2RingWallTeamPlanID);
                        xsSetRuleMinInterval("otherBase2RingWallTeam", 11);
                        xsDisableRule("otherBase2RingWallTeam");
                    }
                }
                else
                {
                    otherBase2DefPlan = true;
                }
                continue;
            }
            else if (defendPlanID == gOtherBase3DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    if (ShowAiEcho == true) aiEcho("-> destroying gOtherBase3DefPlan, setting gOtherBase3UnitID and gOtherBase3ID to -1");
                    aiPlanDestroy(defendPlanID);
                    gOtherBase3DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase3ID);
                    
                    gOtherBase3UnitID = -1;
                    gOtherBase3ID = -1;
                    if (gBuildWalls == true)
                    {
                        //destroy the wall plan at gOtherBase3UnitID
                        aiPlanDestroy(gOtherBase3RingWallTeamPlanID);
                        xsSetRuleMinInterval("otherBase3RingWallTeam", 11);
                        xsDisableRule("otherBase3RingWallTeam");
                    }
                }
                else
                {
                    otherBase3DefPlan = true;
                }
                continue;
            }
            else if (defendPlanID == gOtherBase4DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    if (ShowAiEcho == true) aiEcho("-> destroying gOtherBase4DefPlan, setting gOtherBase4UnitID and gOtherBase4ID to -1");
                    aiPlanDestroy(defendPlanID);
                    gOtherBase4DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase4ID);
                    
                    gOtherBase4UnitID = -1;
                    gOtherBase4ID = -1;
                    if (gBuildWalls == true)
                    {
                        //destroy the wall plan at gOtherBase4UnitID
                        aiPlanDestroy(gOtherBase4RingWallTeamPlanID);
                        xsSetRuleMinInterval("otherBase4RingWallTeam", 11);
                        xsDisableRule("otherBase4RingWallTeam");
                    }
                }
                else
                {
                    otherBase4DefPlan = true;
                }
                continue;
            }
        }
    }
        
    bool otherBase1 = false;
    bool otherBase2 = false;
    bool otherBase3 = false;
    bool otherBase4 = false;

    int newBaseID = -1;
    int newBaseUnitID = -1;
    int mainBaseID = kbBaseGetMainID(cMyID);
    
    int OB1DefPlanBaseID = aiPlanGetBaseID(gOtherBase1DefPlanID);
    int OB2DefPlanBaseID = aiPlanGetBaseID(gOtherBase2DefPlanID);
    int OB3DefPlanBaseID = aiPlanGetBaseID(gOtherBase3DefPlanID);
    int OB4DefPlanBaseID = aiPlanGetBaseID(gOtherBase4DefPlanID);
    
    int index = -1;
    for (index = 0; < numSettlements)
    {
        int otherBaseUnitID = findUnitByIndex(cUnitTypeAbstractSettlement, index, cUnitStateAliveOrBuilding);
        if (otherBaseUnitID < 0)
            continue;
        else
        {
            //check IDs of all bases.
            int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
            if (otherBaseID == -1)
                continue;

            if (otherBaseUnitID == gOtherBase1UnitID)
            {
                if ((otherBaseID != gOtherBase1ID) || (otherBaseID != OB1DefPlanBaseID))
                {
                    if (ShowAiEcho == true) aiEcho("strange, otherBaseUnitID == gOtherBase1UnitID BUT otherBaseID != gOtherBase1ID OR otherBaseID != OB1DefPlanBaseID");
                    if (ShowAiEcho == true) aiEcho("removing farm breakdown, updating baseIDs of defplan and wall plan");
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase1ID);
                    
                    //set gOtherBase1ID to otherBaseID and update the baseID of gOtherBase1DefPlanID
                    gOtherBase1ID = otherBaseID;
                    aiPlanSetBaseID(gOtherBase1DefPlanID, otherBaseID);
                    
                    if (gBuildWalls == true)
                    {
                        //set the baseID of gOtherBase1RingWallTeamPlanID to the new gOtherBase1ID
                        aiPlanSetBaseID(gOtherBase1RingWallTeamPlanID, otherBaseID);
                    }
                }
                otherBase1 = true;
                continue;
            }
            else if (otherBaseUnitID == gOtherBase2UnitID)
            {
                if ((otherBaseID != gOtherBase2ID) || (otherBaseID != OB2DefPlanBaseID))
                {
                    if (ShowAiEcho == true) aiEcho("strange, otherBaseUnitID == gOtherBase2UnitID BUT otherBaseID != gOtherBase2ID OR otherBaseID != OB2DefPlanBaseID");
                    if (ShowAiEcho == true) aiEcho("removing farm breakdown, updating baseIDs of defplan and wall plan");
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase2ID);

                    //set gOtherBase2ID to otherBaseID and update the baseID of gOtherBase2DefPlanID
                    gOtherBase2ID = otherBaseID;
                    aiPlanSetBaseID(gOtherBase2DefPlanID, otherBaseID);
                    
                    if (gBuildWalls == true)
                    {
                        //set the baseID of gOtherBase2RingWallTeamPlanID to the new gOtherBase2ID
                        aiPlanSetBaseID(gOtherBase2RingWallTeamPlanID, otherBaseID);
                    }
                }
                otherBase2 = true;
                continue;
            }
            else if (otherBaseUnitID == gOtherBase3UnitID)
            {
                if ((otherBaseID != gOtherBase3ID) || (otherBaseID != OB3DefPlanBaseID))
                {
                    if (ShowAiEcho == true) aiEcho("strange, otherBaseUnitID == gOtherBase3UnitID BUT otherBaseID != gOtherBase3ID OR otherBaseID != OB3DefPlanBaseID");
                    if (ShowAiEcho == true) aiEcho("removing farm breakdown, updating baseIDs of defplan and wall plan");
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase3ID);

                    //set gOtherBase3ID to otherBaseID and update the baseID of gOtherBase3DefPlanID
                    gOtherBase3ID = otherBaseID;
                    aiPlanSetBaseID(gOtherBase3DefPlanID, otherBaseID);
                    
                    if (gBuildWalls == true)
                    {
                        //set the baseID of gOtherBase3RingWallTeamPlanID to the new gOtherBase3ID
                        aiPlanSetBaseID(gOtherBase3RingWallTeamPlanID, otherBaseID);
                    }
                }
                otherBase3 = true;
                continue;
            }
            else if (otherBaseUnitID == gOtherBase4UnitID)
            {
                if ((otherBaseID != gOtherBase4ID) || (otherBaseID != OB4DefPlanBaseID))
                {
                    if (ShowAiEcho == true) aiEcho("strange, otherBaseUnitID == gOtherBase4UnitID BUT otherBaseID != gOtherBase4ID OR otherBaseID != OB4DefPlanBaseID");
                    if (ShowAiEcho == true) aiEcho("removing farm breakdown, updating baseIDs of defplan and wall plan");
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase4ID);

                    //set gOtherBase4ID to otherBaseID and update the baseID of gOtherBase4DefPlanID
                    gOtherBase4ID = otherBaseID;
                    aiPlanSetBaseID(gOtherBase4DefPlanID, otherBaseID);
                    
                    if (gBuildWalls == true)
                    {
                        //set the baseID of gOtherBase4RingWallTeamPlanID to the new gOtherBase4ID
                        aiPlanSetBaseID(gOtherBase4RingWallTeamPlanID, otherBaseID);
                    }
                }
                otherBase4 = true;
                continue;
            }
            else if (otherBaseID != mainBaseID)
            {
                //we got a new base ID, save it, if no other base has been saved as new base ID yet
                if (newBaseID < 0 )
                {
                    newBaseID = otherBaseID;
                    newBaseUnitID = otherBaseUnitID;
                }
            }
        }
    }
    
    if (newBaseID < 0)
    {
        if (ShowAiEcho == true) aiEcho("newbaseID < 0, returning");
        return;
    }
    else if (otherBase1 == false)
    {
        gOtherBase1ID = newBaseID;
        gOtherBase1UnitID = newBaseUnitID;
        
            
        if ((gBuildWalls == true) && (cMyCulture != cCultureAtlantean))
        {
            //enable the wall plan for gOtherBase1UnitID
            xsEnableRule("otherBase1RingWallTeam");
            otherBase1RingWallTeam();
        }
    }
    else if (otherBase2 == false)
    {
        gOtherBase2ID = newBaseID;
        gOtherBase2UnitID = newBaseUnitID;
        

        
        if ((gBuildWalls == true) && (cMyCulture != cCultureAtlantean))
        {
            //enable the wall plan for gOtherBase2UnitID
            xsEnableRule("otherBase2RingWallTeam");
            otherBase2RingWallTeam();
        }
    }
    else if (otherBase3 == false)
    {
        gOtherBase3ID = newBaseID;
        gOtherBase3UnitID = newBaseUnitID;
        
        
        if ((gBuildWalls == true) && (cMyCulture != cCultureAtlantean))
        {
            //enable the wall plan for gOtherBase3UnitID
            xsEnableRule("otherBase3RingWallTeam");
            otherBase3RingWallTeam();
        }
    }
    else if (otherBase4 == false)
    {
        gOtherBase4ID = newBaseID;
        gOtherBase4UnitID = newBaseUnitID;
        

        
        if ((gBuildWalls == true) && (cMyCulture != cCultureAtlantean))
        {
            //enable the wall plan for gOtherBase4UnitID
            xsEnableRule("otherBase4RingWallTeam");
            otherBase4RingWallTeam();
        }
    }
    else
    {
        if (ShowAiEcho == true) aiEcho("4 other bases exist, returning");
        return;
    }
    
    vector newBaseUnitPosition = kbUnitGetPosition(newBaseUnitID);
    
    int number = -1;      // For plan numbering
    if (otherBase1DefPlan == false)
        number = 1;
    else if (otherBase2DefPlan == false)
        number = 2;
    else if (otherBase3DefPlan == false)
        number = 3;
    else if (otherBase4DefPlan == false)
        number = 4;
    
    int otherBaseDefPlanID = aiPlanCreate("otherBase"+number+"DefPlan", cPlanDefend);
    if (otherBaseDefPlanID != -1)
    {
        aiPlanSetVariableVector(otherBaseDefPlanID, cDefendPlanDefendPoint, 0, newBaseUnitPosition);
        aiPlanSetVariableInt(otherBaseDefPlanID, cDefendPlanRefreshFrequency, 0, 15);
        aiPlanSetUnitStance(otherBaseDefPlanID, cUnitStanceDefensive);
        aiPlanSetVariableBool(otherBaseDefPlanID, cDefendPlanPatrol, 0, false);
        aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeHumanSoldier, 0, 1, 1);
        aiPlanSetNumberVariableValues(otherBaseDefPlanID, cDefendPlanAttackTypeID, 3, true);
        aiPlanSetVariableInt(otherBaseDefPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(otherBaseDefPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);
		aiPlanSetVariableInt(otherBaseDefPlanID, cDefendPlanAttackTypeID, 2, cUnitTypeAbstractVillager);
        aiPlanSetVariableFloat(otherBaseDefPlanID, cDefendPlanGatherDistance, 0, 15.0);
        aiPlanSetVariableFloat(otherBaseDefPlanID, cDefendPlanEngageRange, 0, 40.0);
         
        aiPlanSetDesiredPriority(otherBaseDefPlanID, 25);    // low
         
        aiPlanSetBaseID(otherBaseDefPlanID, newBaseID);

        aiPlanSetActive(otherBaseDefPlanID);
        if (otherBase1DefPlan == false)
            gOtherBase1DefPlanID = otherBaseDefPlanID;
        else if (otherBase2DefPlan == false)
            gOtherBase2DefPlanID = otherBaseDefPlanID;
        else if (otherBase3DefPlan == false)
            gOtherBase3DefPlanID = otherBaseDefPlanID;
        else if (otherBase4DefPlan == false)
            gOtherBase4DefPlanID = otherBaseDefPlanID;
        if (ShowAiEcho == true) aiEcho("otherBaseDefPlan for base #"+newBaseID+" set active: "+otherBaseDefPlanID);
        
        //reset the minInterval since calling the wallplans seems to change the minInterval
        xsSetRuleMinIntervalSelf(43);
    }
}

//==============================================================================
rule attackEnemySettlement
    minInterval 15 //starts in cAge2
    inactive
{

    if (ShowAiEcho == true) aiEcho("attackEnemySettlement:");
    xsSetRuleMinIntervalSelf(15+aiRandInt(18));
    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
    int numSiegeWeapons = kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive);
    int numRagnorokHeroes = kbUnitCount(cMyID, cUnitTypeHeroRagnorok, cUnitStateAlive);
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    static bool ResetOk = false;
	bool Converted = false;
	
	int SiegeMU = 0;
	int SiegeMU2 = 0;
	if (cMyCulture == cCultureGreek)
	SiegeMU = cUnitTypeColossus;
	
	if (cMyCulture == cCultureEgyptian)
	{
	SiegeMU = cUnitTypeScarab;
	SiegeMU2 = cUnitTypeSphinx;
	}
	
	if (cMyCulture == cCultureNorse)
	SiegeMU = cUnitTypeMountainGiant;
	
	if (cMyCulture == cCultureAtlantean)
	SiegeMU = cUnitTypeBehemoth;
	
	if (cMyCulture == cCultureChinese)
	{
	SiegeMU = cUnitTypeVermilionBird;
	SiegeMU2 = cUnitTypePixiu;
	}
	
	int sMUCombined = ((kbUnitCount(cMyID, SiegeMU, cUnitStateAlive)) + (kbUnitCount(cMyID, SiegeMU2, cUnitStateAlive)));
	if (sMUCombined < 0)
	sMUCombined = 0;
	
	numSiegeWeapons = numSiegeWeapons + (sMUCombined);
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
	int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numAttEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);

    if (ShowAiEcho == true) aiEcho("numAttEnemyMilUnitsNearMBInR85: "+numAttEnemyMilUnitsNearMBInR85);
    if (ShowAiEcho == true) aiEcho("numAttEnemyTitansNearMBInR85: "+numAttEnemyTitansNearMBInR85);
    
    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyTitansNearDefBInR35 = 0;
    int numAttEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (ShowAiEcho == true) aiEcho("defPlanBaseLocation: "+defPlanBaseLocation);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            numEnemyTitansNearDefBInR35 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 35.0, true);
            numAttEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
        }
    }
    if (ShowAiEcho == true) aiEcho("numAttEnemyTitansNearDefBInR55: "+numAttEnemyTitansNearMBInR85);
    
    static int attackPlanStartTime = -1;
    if (ShowAiEcho == true) aiEcho("attackPlanStartTime: "+attackPlanStartTime);

    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    
    static int lastTargetUnitID = -1;
    static int lastTargetCount = 0;
    
    float closeToMB = 110.0;
    int baseToUse = mainBaseID;
    float radius = closeToMB;
    vector baseLocationToUse = mainBaseLocation;
    
    int numEnemySettlementsNearMB = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, mainBaseLocation, radius);
    int numMotherNatureSettlementsNearMB = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, mainBaseLocation, radius);
    if (ShowAiEcho == true) aiEcho("numEnemySettlementsNearMB: "+numEnemySettlementsNearMB);
    if (ShowAiEcho == true) aiEcho("numMotherNatureSettlementsNearMB: "+numMotherNatureSettlementsNearMB);
    
    if (numEnemySettlementsNearMB - numMotherNatureSettlementsNearMB < 1)
    {
        radius = 300.0;
        if (defPlanBaseID != -1)
        {
            baseToUse = defPlanBaseID;
            baseLocationToUse = defPlanBaseLocation;
        }
    }
    
    int index = 0;
    int enemySettlementID = -1;
    int closestSettlementID = -1;
    int closestSettlementPlayerID = -1;
    int secondClosestSettlementID = -1;
    int secondClosestSettlementPlayerID = -1;
    float savedDistanceToClosestSettlement = 1000.0;
    float savedDistanceToSecondClosestSettlement = 1001.0;
    
	if ((xsGetTime() > 15*60*1000) && (kbGetAge() < cAge3)) // Try not to get stuck in Classical forever.
	return;
	
    int playerID = -1;
    for (playerID = 1; < cNumberPlayers)
    {
        if (playerID == cMyID)
            continue;
        else if (kbIsPlayerAlly(playerID) == true)
            continue;
        else
        {
            if ((kbIsPlayerResigned(playerID) == true) || (kbHasPlayerLost(playerID) == true))
                continue;
            else
            {
                int numEnemySettlementsInRange = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, playerID, baseLocationToUse, radius);
                if (ShowAiEcho == true) aiEcho("numEnemySettlementsInRange: "+numEnemySettlementsInRange+" of player "+playerID);
                if (numEnemySettlementsInRange > 0)
                {
                    if (numEnemySettlementsInRange >= 2)
                        numEnemySettlementsInRange = 2;
                        
                    for (index = 0; < numEnemySettlementsInRange)
                    {
                        enemySettlementID = findUnitByIndex(cUnitTypeAbstractSettlement, index, cUnitStateAliveOrBuilding, -1, playerID, baseLocationToUse, radius);
                        if (enemySettlementID == -1)
                            continue;
                            
                        vector enemySettlementPos = kbUnitGetPosition(enemySettlementID);
                        float distanceToDefBaseToUse = xsVectorLength(baseLocationToUse - enemySettlementPos);
                        if (ShowAiEcho == true) aiEcho("distanceToDefBaseToUse: "+distanceToDefBaseToUse);
                        if (distanceToDefBaseToUse < savedDistanceToClosestSettlement)
                        {
                            savedDistanceToClosestSettlement = distanceToDefBaseToUse;
                            closestSettlementID = enemySettlementID;
                            closestSettlementPlayerID = playerID;
                            continue;
                        }
                        else if (distanceToDefBaseToUse < savedDistanceToSecondClosestSettlement)
                        {
                            savedDistanceToSecondClosestSettlement = distanceToDefBaseToUse;
                            secondClosestSettlementID = enemySettlementID;
                            secondClosestSettlementPlayerID = playerID;
                            continue;
                        }
                    }
                }
            }
        }
    }
    
    if (ShowAiEcho == true) aiEcho("closestSettlementID: "+closestSettlementID);
    if (ShowAiEcho == true) aiEcho("secondClosestSettlementID: "+secondClosestSettlementID);
    
    int targetSettlementID = -1;
    int targetPlayerID = -1;
    bool targetSettlementCloseToMB = false;
    int numSettlementsBeingBuiltCloseToMB = 0;
    
    if (closestSettlementID != -1)
    {
        targetSettlementID = closestSettlementID;
        targetPlayerID = closestSettlementPlayerID;
        if (radius <= closeToMB)
        {
            targetSettlementCloseToMB = true;
            if (ShowAiEcho == true) aiEcho("closestSettlementID close to mainBase: "+closestSettlementID);
            vector closestSettlementPos = kbUnitGetPosition(closestSettlementID);
            numSettlementsBeingBuiltCloseToMB = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateBuilding, -1, playerID, closestSettlementPos, 15.0);
            if (ShowAiEcho == true) aiEcho("numSettlementsBeingBuiltCloseToMB: "+numSettlementsBeingBuiltCloseToMB);
        }
        else
        {
            if (ShowAiEcho == true) aiEcho("closestSettlementID in Range "+radius+": "+closestSettlementID);
        }
    }
    
    if (targetSettlementCloseToMB == false)
    {
        //reset the number of myth units in gMBDefPlan1ID
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(gMBDefPlan1ID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 0, 1);
    }
    
    bool randomAttackPlanActive = false;
    bool landAttackPlanActive = false;
    int numUnitsInDef = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
    
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();
    if (ShowAiEcho == true) aiEcho("currentPop: "+currentPop+", currentPopCap: "+currentPopCap);
    
    // Find the attack plans
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true );  // Attack plans, any state, active only
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (ShowAiEcho == true) aiEcho("attackPlanID: "+attackPlanID);
            if (attackPlanID == -1)
                continue;
            
            int planState = aiPlanGetState(attackPlanID);
            
            if (ShowAiEcho == true) aiEcho("planState: "+planState);
            
            if (attackPlanID == gEnemySettlementAttPlanID)
            {
                if (ShowAiEcho == true) aiEcho("attackPlanID == gEnemySettlementAttPlanID");
                
                int numTitansInAttackPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeAbstractTitan);
                int numMythInAttackPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
                int numSiegeInAttackPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeAbstractSiegeWeapon);

                if ((targetSettlementCloseToMB == true) && (planState <= cPlanStateGather))
                {
                    if ((aiPlanGetVariableInt(attackPlanID, cAttackPlanSpecificTargetID, 0) != closestSettlementID) && (closestSettlementID != -1))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanSpecificTargetID, 0, closestSettlementID);
                        if (ShowAiEcho == true) aiEcho("Setting attackPlanID cAttackPlanSpecificTargetID to closestSettlementID close to mainBase: "+closestSettlementID);
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanPlayerID, 0, closestSettlementPlayerID);
                        if (ShowAiEcho == true) aiEcho("Setting attackPlanID cAttackPlanPlayerID to closestSettlementPlayerID: "+closestSettlementPlayerID);
                    }
                }
                
				if ((ResetOk == true) && (kbUnitGetCurrentHitpoints(gEnemySettlementAttPlanTargetUnitID) <= 0) && (gEnemySettlementAttPlanTargetUnitID != -1) || (ResetOk == true) && (gEnemySettlementAttPlanTargetUnitID == -1))
				{
				attackPlanStartTime = xsGetTime();
				aiPlanSetVariableVector(attackPlanID, cAttackPlanGatherPoint, 0, gEnemySettlementAttPlanLastAttPoint);
				aiPlanSetUnitStance(attackPlanID, cUnitStanceAggressive);
				ResetOk = false;
				}
				
                if (planState == cPlanStateAttack)
                {
                    //set the minimum number of siege weapons to 1, so that other plans can't steal all of them
                    if (targetSettlementCloseToMB == true)
                    {
                        aiPlanAddUnitType(attackPlanID, cUnitTypeAbstractSiegeWeapon, 1, 2, 2);
                    }
                    else
                    {
                        aiPlanAddUnitType(attackPlanID, cUnitTypeAbstractSiegeWeapon, 1, 3, 4);
                    }
                    
                    if (numTitansInAttackPlan > 0)
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, false);  // Make sure the gEnemySettlementAttPlan stays open
                       if (ShowAiEcho == true) aiEcho ("Setting gEnemySettlementAttPlanID NoMoreUnits to false");
                        aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 10, currentPopCap / 5 + 3, currentPopCap / 5 + 3);
                    }
                    else if ((currentPop >= currentPopCap * 0.8) && ((numMythInAttackPlan > 0) || (numSiegeInAttackPlan > 0)) && (kbGetAge() > cAge3)
                          && (woodSupply > 300) && (goldSupply > 400) && (foodSupply > 400) && (numEnemyMilUnitsNearMBInR80 < 20))
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, false);  // Make sure the gEnemySettlementAttPlan stays open
                        aiPlanSetDesiredPriority(attackPlanID, 55);
                       if (ShowAiEcho == true) aiEcho ("Setting gEnemySettlementAttPlanID NoMoreUnits to false");
                        aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 8, currentPopCap / 5, currentPopCap / 5);
                    }
                    else
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, true);  // Make sure the gEnemySettlementAttPlan is closed
                        aiPlanSetDesiredPriority(attackPlanID, 52);
                       if (ShowAiEcho == true) aiEcho ("Setting gEnemySettlementAttPlanID NoMoreUnits to true");
                    }
                }
                else if (((planState == cPlanStateGather) || (planState == cPlanStateExplore) || (planState == cPlanStateNone))
                 && (xsGetTime() > attackPlanStartTime + 3.5*60*1000) && (attackPlanStartTime != -1)
				 || (planState < cPlanStateAttack) && (xsGetTime() > attackPlanStartTime + 3.5*60*1000) && (attackPlanStartTime != -1))
                {
                    if ((xsGetTime() > attackPlanStartTime + 5*60*1000) && (attackPlanStartTime != -1) || (gTransportMap == true) && (planState == cPlanStateGather) && (xsGetTime() > attackPlanStartTime + 2*60*1000))
                    {
                        aiPlanDestroy(attackPlanID);
                        gEnemySettlementAttPlanTargetUnitID = -1;
                        if (ShowAiEcho == true) aiEcho ("destroying gEnemySettlementAttPlanID as it has been active for more than 5 Minutes");
                    }
                    continue;
                }
                if (ShowAiEcho == true) aiEcho("returning");
                return;                
            }
            else if (attackPlanID == gRandomAttackPlanID)
            {
                if (planState < cPlanStateAttack)
                {
                    randomAttackPlanActive = true;
                }
                continue;
            }
            else if ((attackPlanID == gLandAttackPlanID) && (numUnitsInDef < 15)) // trying this..
            {
                landAttackPlanActive = true;
                continue;
            }
		if ((attackPlanID == gLandAttackPlanID) && (kbGetAge() < cAge4)) // allow the plan to go off in Classical and Heroic without siege
	    Converted = true;
        }
    }
    
    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR85 > 0))
    {
        if (ShowAiEcho == true) aiEcho("attackEnemySettlement: returning as there's an enemy Titan near our main base");
        return;
    }
    else if ((numEnemyTitansNearDefBInR35 > 0) || (numAttEnemyTitansNearDefBInR55 > 0))
    {
        if (ShowAiEcho == true) aiEcho("attackEnemySettlement: returning as there's an enemy Titan near our defPlanBase");
        return;
    }

    if (gEnemyWonderDefendPlan > 0)
    {
        if (ShowAiEcho == true) aiEcho("returning as there's a wonder attack plan open");
        return;
    }
   
    if ((numAttEnemyMilUnitsNearMBInR85 > 10) && (targetSettlementCloseToMB == false))
    {
       if (ShowAiEcho == true) aiEcho ("returning as there are too many enemies near our main base");
        return;
    }
    
    bool settlementPosDefPlanActive = false;
    
    // Find the defend plans
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true );  // Defend plans, any state, active only
    if (activeDefPlans > 0)
    {
        for (j = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, j);
            if (defendPlanID == -1)
                continue;
                
            else if (defendPlanID == gSettlementPosDefPlanID)
            {
                settlementPosDefPlanActive = true;
                if (ShowAiEcho == true) aiEcho("settlementPosDefPlanActive = true");
                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 15.0);
                int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 15.0, true);
            }
        }
    }
    
    int number = 0;
	if (mPopLandAttack == true)
	{
	int numTcs=kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
	if (numTcs > 2)
	{
    number = numTcs * 8 - 10;
    if (currentPopCap >= 300)
	number = 50;
	}
    }
  
  // StandardAI Pop
   int upID = -1;                   // Active unit picker, for getting target military size
   int targetPop = -1;              // Size needed to launch an attack, in pop slots
   
   if (kbGetAge() < cAge3)
      upID = gRushUPID;
   else
      upID = gLateUPID;
   targetPop = kbUnitPickGetMinimumPop(upID);  
   //
   
    int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
	int numMilUnitsInMBDefPlan1 = aiPlanGetNumberUnits(gMBDefPlan1ID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numSiegeUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeAbstractSiegeWeapon);
    int numMythUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
    int numTitansIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeAbstractTitan);
    
    if (ShowAiEcho == true) aiEcho("numMilUnitsIngDefendPlan: "+numMilUnitsIngDefendPlan);
    if (ShowAiEcho == true) aiEcho("numMilUnitsInBaseUnderAttackDefPlan: "+numMilUnitsInBaseUnderAttackDefPlan);
    if (ShowAiEcho == true) aiEcho("numMilUnitsInSettlementPosDefPlan: "+numMilUnitsInSettlementPosDefPlan);
    int numMilUnitsInDefPlans = numMilUnitsIngDefendPlan + numMilUnitsInMBDefPlan1 + numMilUnitsInBaseUnderAttackDefPlan * 0.4 + numMilUnitsInSettlementPosDefPlan * 0.4;
	
    if (ShowAiEcho == true) aiEcho("total numMilUnitsInDefPlans: "+numMilUnitsInDefPlans);   
	
    int mostHatedPlayerID = aiGetMostHatedPlayerID();
    int numMHPlayerSettlements = kbUnitCount(mostHatedPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (ShowAiEcho == true) aiEcho("numMHPlayerSettlements: "+numMHPlayerSettlements);      
    
    if (targetSettlementCloseToMB == false)
    {
        if ((numMHPlayerSettlements < 1) && (targetSettlementID < 0))
        {
            if (ShowAiEcho == true) aiEcho("targetSettlementID < 0 and numMHPlayerSettlements < 1, returning");
            return;
        }
        if ((settlementPosDefPlanActive == true) && (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1))
        {
           if (ShowAiEcho == true) aiEcho ("returning as there's a settlementPosDefPlan active");
            return;
        }
        else if (randomAttackPlanActive == true)
        {
           if (ShowAiEcho == true) aiEcho ("returning as there is a gRandomAttackPlanID active and gathering units");
            return;
        }
        else if (landAttackPlanActive == true)
        {
           if (ShowAiEcho == true) aiEcho ("returning as there is a landAttackPlan active");
            return;
        }
        else if ((numSiegeWeapons < 1+aiRandInt(2)) && (aiRandInt(10) > 5) && (Converted == false))
        {
           if (ShowAiEcho == true) aiEcho ("returning as we don't have a Titan, a siege weapon, or a military myth unit");
            return;
        }
        else if ((woodSupply < 30) || (goldSupply < 80) || (foodSupply < 90) || (UseStandardPop == false) && (currentPop <= currentPopCap - 6 - number) ||
		 (UseStandardPop == true) && (numMilUnitsInDefPlans*3 < targetPop))
        {
           if (ShowAiEcho == true) aiEcho ("returning as we don't have enough resources");
            return;
        }
    }
    else
    {

        if ((woodSupply < 30) || (goldSupply < 80) || (foodSupply < 90) || (UseStandardPop == false) && (currentPop <= currentPopCap - 6 - number) 
		|| (UseStandardPop == true) && (numMilUnitsInDefPlans*3 < targetPop))
        {
           if (ShowAiEcho == true) aiEcho ("returning as we don't have enough resources");
            return;
        }
    }

    
    int enemyMainBaseUnitID = -1;
    float veryCloseRange = 65.0;
    
    if ((targetSettlementID != -1) && (targetPlayerID != -1))
    {
        enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(targetPlayerID);
        if (ShowAiEcho == true) aiEcho("enemyMainBaseUnitID: "+enemyMainBaseUnitID+" for player: "+targetPlayerID);
        if ((targetSettlementID == enemyMainBaseUnitID) && (savedDistanceToClosestSettlement > veryCloseRange)
         && (secondClosestSettlementID != -1))
        {
            //check if the secondClosestSettlement's distance is only a little farther
            if (savedDistanceToSecondClosestSettlement - savedDistanceToClosestSettlement < 20.0 )
            {
                enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(secondClosestSettlementPlayerID);
                if (ShowAiEcho == true) aiEcho("enemyMainBaseUnitID: "+enemyMainBaseUnitID+" for player: "+secondClosestSettlementPlayerID);
                if (secondClosestSettlementID != enemyMainBaseUnitID)
                {
                    targetSettlementID = secondClosestSettlementID;
                    targetPlayerID = secondClosestSettlementPlayerID;
                    if (ShowAiEcho == true) aiEcho("setting targetSettlementID to secondClosestSettlementID: "+targetSettlementID);
                }
            }
        }
    }
	
    if ((targetSettlementID < 0) || ((lastTargetCount > 3) && (targetSettlementCloseToMB == false)))
    {    
        if ((targetSettlementID != secondClosestSettlementID) && (secondClosestSettlementID != -1) && (aiRandInt(5) < 4))
        {
            targetSettlementID = secondClosestSettlementID;
            targetPlayerID = secondClosestSettlementPlayerID;
            if (ShowAiEcho == true) aiEcho("setting targetSettlementID to secondClosestSettlementID: "+targetSettlementID);
        }
        else
        {
            index = aiRandInt(numMHPlayerSettlements);
            targetSettlementID = findUnitByIndex(cUnitTypeAbstractSettlement, index, cUnitStateAliveOrBuilding, -1, mostHatedPlayerID);
            if (targetSettlementID != -1)
            {
                if (ShowAiEcho == true) aiEcho("setting targetSettlementID to random settlement ID: "+targetSettlementID);
                targetPlayerID = mostHatedPlayerID;
                
            }
            else
            {
                if (ShowAiEcho == true) aiEcho("targetSettlementID < 0, returning");
                return;
            }
        }
    }
    
    vector targetSettlementPos = kbUnitGetPosition(targetSettlementID);
    float distanceToTarget = xsVectorLength(baseLocationToUse - targetSettlementPos);
    if (ShowAiEcho == true) aiEcho("distanceToTarget: "+distanceToTarget);
    
    enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(targetPlayerID);
    if (ShowAiEcho == true) aiEcho("enemyMainBaseUnitID: "+enemyMainBaseUnitID+" for player: "+targetPlayerID);
    bool targetIsEnemyMainBase = false;
        
    if (targetSettlementID == enemyMainBaseUnitID)
    {
        if (ShowAiEcho == true) aiEcho("Enemy Settlement is his mainbase");
		
            if ((numTitansIngDefendPlan > 0)
             || ((numMilUnitsInDefPlans >= 16) && ((numSiegeUnitsIngDefendPlan > 1) || (numMilUnitsInDefPlans >= 25) && (aiRandInt(3) == 0) ||
			 ((numSiegeUnitsIngDefendPlan > 1) && (numMythUnitsIngDefendPlan > 0) && (numMilUnitsInDefPlans >= 12)))))
            {
                targetIsEnemyMainBase = true;
               if (ShowAiEcho == true) aiEcho ("We have enough troops, attacking enemy main base!");
            }
            else
            {
               if (ShowAiEcho == true) aiEcho ("returning as we don't have enough troops to attack his main base");
                return;
            }
    }
    else
    {
        if ((targetSettlementCloseToMB == true) && (numSettlementsBeingBuiltCloseToMB > 0))
        {
            if (numMilUnitsInDefPlans < 8)
            {
               if (ShowAiEcho == true) aiEcho ("returning as we don't have enough troops to attack targetSettlementID:"+targetSettlementID+" in close range");
                return;
            }
            else
            {
               if (ShowAiEcho == true) aiEcho ("We have enough troops to attack targetSettlementID:"+targetSettlementID+" in close range");
            }
        }
        else
        {
            if ((numTitansIngDefendPlan > 0) || ((numMilUnitsInDefPlans > 12) && ((numSiegeUnitsIngDefendPlan > 0)
             || (numMilUnitsInDefPlans > 20))))
            {
               if (ShowAiEcho == true) aiEcho ("We have enough troops to attack targetSettlementID:"+targetSettlementID);
            }
            else
            {
               if (ShowAiEcho == true) aiEcho ("returning as we don't have enough troops to attack targetSettlementID:"+targetSettlementID);
                return;
            }
        }
    }
    
    int enemySettlementAttPlanID = aiPlanCreate("enemy settlement attack plan", cPlanAttack);
    if (enemySettlementAttPlanID < 0)
        return;

    if (targetSettlementCloseToMB == true)
    {
        //set the number of myth units in gMBDefPlan1ID to 0
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(gMBDefPlan1ID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 0, 0);
    }
    
    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanPlayerID, 0, targetPlayerID);
    
    // Specify other continent so that armies will transport
	if (gTransportMap == true)
	{
    aiPlanSetNumberVariableValues(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 1, true);
	aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(targetSettlementPos));
    }
	
    vector militaryGatherPoint = cInvalidVector;
    if ((defPlanBaseID != mainBaseID) && (defPlanBaseID != -1) && (equal(defPlanBaseLocation, cInvalidVector) == false))
    {
        vector frontVector = kbBaseGetFrontVector(cMyID, defPlanBaseID);
        float fx = xsVectorGetX(frontVector);
        float fz = xsVectorGetZ(frontVector);
        float fxOrig = fx;
        float fzOrig = fz;
        if (aiRandInt(2) < 1)
        {
            fx = fzOrig * (-11);
            fz = fxOrig * 11;
        }
        else
        {
            fx = fzOrig * 11;
            fz = fxOrig * (-11);
        }
        frontVector = xsVectorSetX(frontVector, fx);
        frontVector = xsVectorSetZ(frontVector, fz);
        frontVector = xsVectorSetY(frontVector, 0.0);
        militaryGatherPoint = defPlanBaseLocation + frontVector;
    }
    else
    {
        militaryGatherPoint = getMainBaseMilitaryGatherPoint();
    }
    if (ShowAiEcho == true) aiEcho("militaryGatherPoint: "+militaryGatherPoint);
    
    aiPlanSetVariableVector(enemySettlementAttPlanID, cAttackPlanGatherPoint, 0, militaryGatherPoint);
    aiPlanSetVariableFloat(enemySettlementAttPlanID, cAttackPlanGatherDistance, 0, 30.0);

    if (numTitans > 0)
        aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractTitan, 0, 1, 1);

    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
         
    if ((targetIsEnemyMainBase == false) && (numTitans < 1))
    {
        if (targetSettlementCloseToMB == true)
        {
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractSiegeWeapon, 1, 1, 2);
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 1, 1);
            
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
            
            if (numMilUnitsInDefPlans < 14)
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans, 12, 14);
            else
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.9, numMilUnitsInDefPlans * 0.95, numMilUnitsInDefPlans);
        }
        else
        {
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractSiegeWeapon, 0, 2, 3);
            if (numRagnorokHeroes < 10)
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 2, 2);
            
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 4);
            
            if (numMilUnitsInDefPlans < 14)
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans, 12, 14);
            else
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.90, numMilUnitsInDefPlans * 0.95, numMilUnitsInDefPlans);
        }
            
        aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
        aiPlanSetRequiresAllNeedUnits(enemySettlementAttPlanID, false);
        aiPlanSetUnitStance(enemySettlementAttPlanID, cUnitStanceDefensive);
    }
    else
    {
        aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractSiegeWeapon, 0, 2, 2);
        if ((cMyCulture == cCultureGreek) || (cMyCulture == cCultureEgyptian))
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 2, 3);
        else if (cMyCulture == cCultureAtlantean)
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 3, 4);
        else if (cMyCulture == cCultureChinese)
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 4, 8);			
        else
        {
            if (numRagnorokHeroes < 10)
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 4, 4);
        }
        
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
        
        if (numTitans > 0)
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans, numMilUnitsInDefPlans, numMilUnitsInDefPlans);
        else
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.9, numMilUnitsInDefPlans, numMilUnitsInDefPlans);

        aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
        
        aiPlanSetRequiresAllNeedUnits(enemySettlementAttPlanID, false);
        aiPlanSetUnitStance(enemySettlementAttPlanID, cUnitStanceDefensive);
    }
    
  
    if (aiRandInt(2) < 1)
        aiPlanSetVariableBool(enemySettlementAttPlanID, cAttackPlanAutoUseGPs, 0, false);
    else
        aiPlanSetVariableBool(enemySettlementAttPlanID, cAttackPlanAutoUseGPs, 0, true);
    
    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanRefreshFrequency, 0, 12); 
    

    aiPlanSetInitialPosition(enemySettlementAttPlanID, baseLocationToUse);

    if (numTitans > 0)
        aiPlanSetDesiredPriority(enemySettlementAttPlanID, 55);
    else
        aiPlanSetDesiredPriority(enemySettlementAttPlanID, 52);

    
	
    aiPlanSetNumberVariableValues(enemySettlementAttPlanID, cAttackPlanTargetTypeID, 5, true);
	aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetTypeID, 0, cUnitTypeAbstractVillager);
    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetTypeID, 1, cUnitTypeUnit);
	aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetTypeID, 2, cUnitTypeMilitaryBuilding);
    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetTypeID, 3, cUnitTypeBuilding);
	aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetTypeID, 4, cUnitTypeAbstractTradeUnit);
    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0, targetSettlementID);
	
	int FromGoal = aGoalID;
	if (kbGetAge() >= cAge3)
	FromGoal = gLandAttackGoalID;    
	aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanFromGoalID, 0, FromGoal);
	aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
    aiPlanSetActive(enemySettlementAttPlanID);
	if (cMyCiv == cCivKronos)
    aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanAttackPlanID, 0, enemySettlementAttPlanID);
	
	int GPFindPlan = aiFindBestAttackGodPowerPlan();
	if ((GPFindPlan > 0) && (GPFindPlan != gUnbuildPlanID))
    aiPlanSetVariableInt(GPFindPlan, cGodPowerPlanAttackPlanID, 0, enemySettlementAttPlanID);	
	
    if (lastTargetUnitID == targetSettlementID)
    {
        lastTargetCount = lastTargetCount + 1;
    }
    else
    {
        lastTargetUnitID = targetSettlementID;
        lastTargetCount = 0;
    }
    if (ShowAiEcho == true) aiEcho("lastTargetCount: "+lastTargetCount);
    
    gEnemySettlementAttPlanTargetUnitID = targetSettlementID;
    gEnemySettlementAttPlanID = enemySettlementAttPlanID;
    gEnemySettlementAttPlanLastAttPoint = targetSettlementPos;
    if (ShowAiEcho == true) aiEcho("gEnemySettlementAttPlanLastAttPoint: "+gEnemySettlementAttPlanLastAttPoint);
    if (ShowAiEcho == true) aiEcho("Creating enemy settlement attack plan, target ID is: "+targetSettlementID);
    attackPlanStartTime = xsGetTime();
	if (gTransportMap == false)
	ResetOk = true;
    if (ShowAiEcho == true) aiEcho("attackPlanStartTime: "+attackPlanStartTime);
	bool Announce = false;
	static int lastAnnounced = 0;
	
	if ((aiRandInt(3) == 0) && (IhaveAllies == true) && (aiGetCaptainPlayerID(cMyID) == cMyID) && (targetSettlementID > 0) && (xsGetTime() > lastAnnounced + 3*60*1000))
	{
	Announce = true;
	lastAnnounced = xsGetTime();
	}
	
	if (Announce == true)
	{
	int RandMessage = 1+aiRandInt(4);
	if (RandMessage == 3)
	RandMessage = 2;
	for (i=1; < cNumberPlayers)
    {
      if (i == cMyID)
         continue;
    if ((kbIsPlayerAlly(i) == true) && (kbIsPlayerHuman(i) == true) && (kbHasPlayerLost(i) == false))
	aiCommsSendStatementWithVector(i, cAICommPromptAIAttackHere, RandMessage, targetSettlementPos);
	}
	}
}

//==============================================================================
rule defendSettlementPosition
    minInterval 1 //starts in cAge2, activated in monitorAttack rule or findMySettlementsBeingBuilt rule
    inactive
{
    
    if (ShowAiEcho == true) aiEcho("defendSettlementPosition");
    xsSetRuleMinIntervalSelf(23);
    static int defendPlanStartTime = -1;
    
    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    float distToMainBase = xsVectorLength(mainBaseLocation - gSettlementPosDefPlanDefPoint);
    
    int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, gSettlementPosDefPlanDefPoint, 50.0, true);
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int myMilUnitsNearMBInR80 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 80.0);
    int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, gSettlementPosDefPlanDefPoint, 15.0);
    int myBuildingsThatShootAtDefPlanPosition = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, gSettlementPosDefPlanDefPoint, 15.0);
    int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, gSettlementPosDefPlanDefPoint, 15.0, true);
	int NumEnemyBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, gSettlementPosDefPlanDefPoint, 50.0, true);
    int NumBThatShoots = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, gSettlementPosDefPlanDefPoint, 35.0, true);
    int enemySettlementAtDefPlanPositionID = -1;
    
    int playerID = -1;
    for (playerID = 1; < cNumberPlayers)
    {
        if (playerID == cMyID)
            continue;
        else if (kbIsPlayerAlly(playerID) == true)
            continue;
        else
        {
            if ((kbIsPlayerResigned(playerID) == true) || (kbHasPlayerLost(playerID) == true))
                continue;
            else
            {
                enemySettlementAtDefPlanPositionID = findUnitByIndex(cUnitTypeAbstractSettlement, 0, cUnitStateAlive, -1, playerID, gSettlementPosDefPlanDefPoint, 15.0);
                if (enemySettlementAtDefPlanPositionID != -1)
                {
                    break;
                }
            }
        }
    }
    
    //If we already have a settlementPosDefPlan, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;
                
            if (defendPlanID == gSettlementPosDefPlanID)
            {

                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int numAttEnemyMilUnitsInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 40.0, true);
                
                if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0)
                 || ((enemySettlementAtDefPlanPositionID != -1) && (kbUnitGetCurrentHitpoints(enemySettlementAtDefPlanPositionID) > 0))
                 || ((numEnemyMilUnitsNearMBInR80 > 15) && (numEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 3)))
                {
                    aiPlanDestroy(defendPlanID);
                    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0))
                        if (ShowAiEcho == true) aiEcho("destroying gSettlementPosDefPlan as there's an enemy Titan near our main base");
                    else if ((enemySettlementAtDefPlanPositionID != -1) && (kbUnitGetCurrentHitpoints(enemySettlementAtDefPlanPositionID) > 0))
                        if (ShowAiEcho == true) aiEcho("destroying gSettlementPosDefPlan as there's an enemy Settlement at our defend position");
                    else
                        if (ShowAiEcho == true) aiEcho("destroying gSettlementPosDefPlan as there are too many enemies near our main base");
                    xsSetRuleMinIntervalSelf(1);
                    xsDisableSelf();
                    return;
                }

                if ((xsGetTime() > defendPlanStartTime + 4*60*1000) || (alliedBaseAtDefPlanPosition > 0)
                 || ((myBaseAtDefPlanPosition > 0) && ((numAttEnemyMilUnitsInR40 < 10) && (myBuildingsThatShootAtDefPlanPosition > 0))
                 || (equal(aiPlanGetVariableVector(gBaseUnderAttackDefPlanID, cDefendPlanDefendPoint, 0), defPlanDefPoint) == true)))
                 
                {
                    if (xsGetTime() > defendPlanStartTime + 2.5*60*1000)
                        if (ShowAiEcho == true) aiEcho("destroying gSettlementPosDefPlan as it has been active for more than 2.5 Minutes");
                    else if (alliedBaseAtDefPlanPosition > 0)
                        if (ShowAiEcho == true) aiEcho("destroying gSettlementPosDefPlan as an ally has built a settlement at the defend position");
                    else
                    {
                        if (ShowAiEcho == true) aiEcho("destroying gSettlementPosDefPlan as numAttEnemyMilUnitsInR40 < 10");
                        if (ShowAiEcho == true) aiEcho("and I have a settlement plus 1 defensive building at the defend position");
                    }
                    aiPlanDestroy(defendPlanID);
                    xsSetRuleMinIntervalSelf(1);
                    xsDisableSelf();
                    return;
                }
                return;
            }
        }
    }
    
    if (gEnemyWonderDefendPlan > 0)
    {
        return;
    }
    
    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0))
    {
        return;
    }
    
    static int count = 0;
    if (numMilUnits < 14)
    {
        xsSetRuleMinIntervalSelf(11);
        if (count > 2)
        {
            xsSetRuleMinIntervalSelf(1);
            count = 0;
            xsDisableSelf();
        }
        else
            count = count + 1;
        return;
    }
 
    if (ShowAiEcho == true) aiEcho("gSettlementPosDefPlanDefPoint: "+gSettlementPosDefPlanDefPoint);
    int settlementPosDefPlanID = aiPlanCreate("settlementPosDefPlan", cPlanDefend);
    if (settlementPosDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
        aiPlanSetVariableInt(settlementPosDefPlanID, cDefendPlanRefreshFrequency, 0, 15);
        
        aiPlanSetVariableVector(settlementPosDefPlanID, cDefendPlanDefendPoint, 0, gSettlementPosDefPlanDefPoint);
        aiPlanSetVariableFloat(settlementPosDefPlanID, cDefendPlanEngageRange, 0, 40.0);
        aiPlanSetVariableFloat(settlementPosDefPlanID, cDefendPlanGatherDistance, 0, 20.0);

        aiPlanSetUnitStance(settlementPosDefPlanID, cUnitStanceDefensive);
        aiPlanSetVariableBool(settlementPosDefPlanID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(settlementPosDefPlanID, cDefendPlanAttackTypeID, 5, true);
        aiPlanSetVariableInt(settlementPosDefPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(settlementPosDefPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeAbstractVillager);
		aiPlanSetVariableInt(settlementPosDefPlanID, cDefendPlanAttackTypeID, 2, cUnitTypeBuildingsThatShoot);
		aiPlanSetVariableInt(settlementPosDefPlanID, cDefendPlanAttackTypeID, 3, cUnitTypeBuilding);
		aiPlanSetVariableInt(settlementPosDefPlanID, cDefendPlanAttackTypeID, 4, cUnitTypeAbstractWall);


        if (distToMainBase < 85.0)
        {
            if (cMyCulture == cCultureAtlantean)
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 0, 0, 1);
            }
            else
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 0, 0, 1);
            }
            
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
            	
				if (NumEnemyBuildings > 6)
				aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 7, 15, 18);
				else aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 3, 5, 6);
            
        }
        else
        {
            if (cMyCulture == cCultureNorse)
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 0, 1, 2);
            }
            else if (cMyCulture == cCultureAtlantean)
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 0, 1, 2);
            }
            else
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 0, 1, 2);
            }
            if (distToMainBase > 100.0)
            {
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                    aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
                
				if ((NumEnemyBuildings > 6) || (NumBThatShoots >= 1))
				aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractSiegeWeapon, 1, 2, 2);
				else aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
				if (NumEnemyBuildings > 6)
				aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 15, 25, 35); // add more
				else aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 5, 8, 10);
				
            }
            else
            {
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                    aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
                
			   if ((NumEnemyBuildings > 6) || (NumBThatShoots >= 1))
				aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractSiegeWeapon, 1, 2, 2);
				else aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
				if (NumEnemyBuildings > 6)
				aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 15, 18, 25); // add more
				else aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 5, 8, 10);
            }
        }
        aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractTitan, 0, 1, 1);
        if (ShowAiEcho == true) aiEcho("Initial BUILDINGS FOUND "+NumEnemyBuildings+"");

        //override
        if (enemyMilUnitsInR50 > 18)
            aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 11, enemyMilUnitsInR50 + 8, enemyMilUnitsInR50 + 15);
        
		aiPlanSetDesiredPriority(settlementPosDefPlanID, 52);
		aiPlanSetBaseID(settlementPosDefPlanID, mainBaseID);
        aiPlanSetActive(settlementPosDefPlanID);
        gSettlementPosDefPlanID = settlementPosDefPlanID;
        if (ShowAiEcho == true) aiEcho("settlementPosDefPlan set active: "+gSettlementPosDefPlanID);
        xsSetRuleMinIntervalSelf(23);
    } 
}


//==============================================================================
rule createRaidingParty
    minInterval 67 //starts in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("*!*!*createRaidingParty:");

    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector baseLocationToUse = mainBaseLocation;
    
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    
    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyTitansNearDefBInR35 = 0;
    int numAttEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            baseLocationToUse = defPlanBaseLocation;
            numEnemyTitansNearDefBInR35 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 35.0, true);
            numAttEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
        }
    }
    
    static int attackPlanStartTime = -1;
    
    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR85 > 0))
    {
        return;
    }
    else if ((numEnemyTitansNearDefBInR35 > 0) || (numAttEnemyTitansNearDefBInR55 > 0))
    {
        return;
    }
    
    
    //If we already have a raiding party attack plan don't make another one.
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true);
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (attackPlanID == -1)
                continue;
            if (attackPlanID == gRaidingPartyAttackID)
            {
                if ((kbUnitGetCurrentHitpoints(gRaidingPartyTargetUnitID) <= 0) && (gRaidingPartyTargetUnitID != -1))
                {
                    aiPlanDestroy(attackPlanID);
                    gRaidingPartyTargetUnitID = -1;
                }
                else if ((aiPlanGetState(attackPlanID) < cPlanStateAttack) && (xsGetTime() > attackPlanStartTime + 3*60*1000) && (attackPlanStartTime != -1))
                {
                    aiPlanDestroy(attackPlanID);
                    gRaidingPartyTargetUnitID = -1;
                }		
                return;
            }
        }
    }
	if ((xsGetTime() > 15*60*1000) && (kbGetAge() < cAge3)) // Try not to get stuck in Classical forever.
	return;
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    
    
    if ((woodSupply < 40) || (foodSupply < 90) || (goldSupply < 80))
    {
        return;
    }

    if (gEnemyWonderDefendPlan > 0)
    {
        return;
    }


    static int lastTargetUnitID = -1;
    static int lastTargetCount = 0;
    
    int targetUnitID = -1;
    bool targetIsMarket = false;
    bool targetIsDropsite = false;
    int index = 0;
    float closeRangeRadius = 100.0;
    int playerID = -1;
    for (playerID = 1; < cNumberPlayers)
    {
        if (playerID == cMyID)
            continue;
        else if (kbIsPlayerAlly(playerID) == true)
            continue;
        else
        {
            if ((kbIsPlayerResigned(playerID) == true) || (kbHasPlayerLost(playerID) == true))
                continue;
            else
            {
                int enemyEconUnit = -1;
                if (kbGetCultureForPlayer(playerID) == cCultureAtlantean)
                    enemyEconUnit = cUnitTypeVillagerAtlantean;
                else
                    enemyEconUnit = cUnitTypeDropsite;
                
                int numEnemyDropsitesInCloseRange = getNumUnits(enemyEconUnit, cUnitStateAliveOrBuilding, -1, playerID, mainBaseLocation, closeRangeRadius);
                int dropsiteUnitIDinCloseRange = -1;
                if (numEnemyDropsitesInCloseRange > 0)
                {
                    index = aiRandInt(numEnemyDropsitesInCloseRange);
                    dropsiteUnitIDinCloseRange = findUnitByIndex(enemyEconUnit, index, cUnitStateAliveOrBuilding, -1, playerID, mainBaseLocation, closeRangeRadius);
                    if (kbUnitIsType(dropsiteUnitIDinCloseRange, cUnitTypeAbstractSettlement) == true)
                    {
                        dropsiteUnitIDinCloseRange = -1;
                        continue;
                    }
                    targetIsDropsite = true;
                    targetUnitID = dropsiteUnitIDinCloseRange;
                    break;
                }
            }
        }
    }
    
    int militaryUnit1ID = -1;
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();
	
	int number = 0;
	if (mPopLandAttack == true)
	{
	int numTcs=kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
	if (numTcs > 2)
	{
    number = numTcs * 8 - 10;
    if (currentPopCap >= 300)
	number = 50;
	}
    }
	
    // StandardAI Pop
    int upID = -1;                   // Active unit picker, for getting target military size
    int targetPop = -1;              // Size needed to launch an attack, in pop slots
   
    if (kbGetAge() < cAge3)
    upID = gRushUPID;
    else
    upID = gLateUPID;
    targetPop = kbUnitPickGetMinimumPop(upID);  
    //		
    
    int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
	int numMilUnitsInMBDefPlan1 = aiPlanGetNumberUnits(gMBDefPlan1ID, cUnitTypeLogicalTypeLandMilitary);	
    int numMilUnitsInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInDefPlans = numMilUnitsIngDefendPlan + numMilUnitsInMBDefPlan1 + numMilUnitsInBaseUnderAttackDefPlan * 0.4 + numMilUnitsInSettlementPosDefPlan * 0.4;
		
    if (dropsiteUnitIDinCloseRange != -1)
    {
        if ((UseStandardPop == false) && (currentPop <= currentPopCap - 9 - number) || 
		(UseStandardPop == true) && (numMilUnitsInDefPlans*3 < targetPop)) 
        {
            return;
        }
    }
    else
    {
        if (currentPop <= currentPopCap - 6 - number)
        {
            return;
        }
        
        if (numEnemyMilUnitsNearMBInR80 > 8)
        {
            return;
        }
        
        int enemyPlayerID = aiGetMostHatedPlayerID();
    
        int numEnemyMarkets = kbUnitCount(enemyPlayerID, cUnitTypeMarket, cUnitStateAliveOrBuilding);

        if (kbGetCultureForPlayer(enemyPlayerID) == cCultureAtlantean)
            enemyEconUnit = cUnitTypeVillagerAtlantean;
        else
            enemyEconUnit = cUnitTypeDropsite;   

        int numEnemyDropsites = kbUnitCount(enemyPlayerID, enemyEconUnit, cUnitStateAliveOrBuilding);
    

        if ((mapRestrictsMarketAttack() == false) && (numEnemyMarkets > 0) && ((numEnemyDropsites < 1) || (aiRandInt(5) < 2)))
        {
            for (j = 0; < numEnemyMarkets)
            {
                int enemyMarketUnitID = findUnitByIndex(cUnitTypeMarket, j, cUnitStateAliveOrBuilding, -1, enemyPlayerID);
                vector enemyMarketLocation = kbUnitGetPosition(enemyMarketUnitID);
                //reduced radius from 55 to 40; TODO: check if it's OK
                int numEnemyBuildingsAtMarketLocation = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numEnemyTowersAtMarketLocation = getNumUnitsByRel(cUnitTypeTower, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numEnemyFortressesAtMarketLocation = getNumUnitsByRel(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numEnemySettlementsAtMarketLocation = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numMotherNatureSettlementsAtMarketLocation = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, enemyMarketLocation, 40.0);
                numEnemySettlementsAtMarketLocation = numEnemySettlementsAtMarketLocation - numMotherNatureSettlementsAtMarketLocation;
                if ((numEnemyBuildingsAtMarketLocation < 8) && (numEnemyTowersAtMarketLocation < 1) && (numEnemyFortressesAtMarketLocation < 1) && (numEnemySettlementsAtMarketLocation < 1))
                {
                    targetUnitID = enemyMarketUnitID;
                    targetIsMarket = true;
                    break;
                }
            }
        }
        else if ((numEnemyDropsites > 0) && (aiRandInt(5) < 4))
        {
            int enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(enemyPlayerID);
            vector enemyMainBaseUnitLocation = kbUnitGetPosition(enemyMainBaseUnitID);
            float distanceToSavedEnemyDropsiteUnitID = 0.0;
            int max = 16;
            if (cMyCulture == cCultureAtlantean)
                max = 9;
            if (numEnemyDropsites > max)
                numEnemyDropsites = max;
            for (k = 0; < numEnemyDropsites)
            {
                int dropsiteUnitID = -1;
                int possibleEnemyDropsiteUnitID = findUnitByIndex(enemyEconUnit, k, cUnitStateAliveOrBuilding, -1, enemyPlayerID);
                vector possibleEnemyDropsiteUnitLocation = kbUnitGetPosition(possibleEnemyDropsiteUnitID);
                float distanceToEnemyMainBase = xsVectorLength(enemyMainBaseUnitLocation - possibleEnemyDropsiteUnitLocation);
                if ((distanceToEnemyMainBase > 85.0) && (distanceToEnemyMainBase > distanceToSavedEnemyDropsiteUnitID))
                {
                    dropsiteUnitID = possibleEnemyDropsiteUnitID;
                    //reduced radius from 55 to 40; TODO: check if it's OK
                    int numEnemyMilitaryBuildingsAtDropsiteLocation = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, kbUnitGetPosition(dropsiteUnitID), 40.0);
                    int numEnemyTowersAtDropsiteLocation = getNumUnitsByRel(cUnitTypeTower, cUnitStateAlive, -1, cPlayerRelationEnemy, kbUnitGetPosition(dropsiteUnitID), 40.0);
                    int numEnemyFortressesAtDropsiteLocation = getNumUnitsByRel(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cPlayerRelationEnemy, kbUnitGetPosition(dropsiteUnitID), 40.0);
                    int numEnemySettlementsAtDropsiteLocation = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, kbUnitGetPosition(dropsiteUnitID), 40.0);
                    int numMotherNatureSettlementsAtDropsiteLocation = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, kbUnitGetPosition(dropsiteUnitID), 40.0);
                    numEnemySettlementsAtDropsiteLocation = numEnemySettlementsAtDropsiteLocation - numMotherNatureSettlementsAtDropsiteLocation;
                    if ((numEnemyMilitaryBuildingsAtDropsiteLocation < 3) && (numEnemyTowersAtDropsiteLocation < 1) && (numEnemyFortressesAtDropsiteLocation < 1) && (numEnemySettlementsAtDropsiteLocation < 1))
                    {
                        if ((lastTargetCount > 1) && (dropsiteUnitID == lastTargetUnitID))
                        {
                            continue;
                        }
                        targetUnitID = dropsiteUnitID;
                        targetIsDropsite = true;
                        distanceToSavedEnemyDropsiteUnitID = distanceToEnemyMainBase;
                    }
                }
            }
        }
        else
        {
            if ((equal(gRaidingPartyLastTargetLocation, cInvalidVector) == false) && ((aiRandInt(2) < 1) || (kbGetCultureForPlayer(enemyPlayerID) == cCultureAtlantean)))
            {
                militaryUnit1ID = findUnitByIndex(cUnitTypeHumanSoldier, 0, cUnitStateAlive, cActionIdle);
                if (militaryUnit1ID > 0)
                {
                    aiTaskUnitMove(militaryUnit1ID, gRaidingPartyLastTargetLocation);
                }
                else
                {
                }
            }
            if ((equal(gRaidingPartyLastMarketLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
            {
                int militaryUnit2ID = findUnitByIndex(cUnitTypeHumanSoldier, 1, cUnitStateAlive, cActionIdle);
                if (militaryUnit2ID > 0)
                {
                    aiTaskUnitMove(militaryUnit2ID, gRaidingPartyLastMarketLocation);
                }
                else
                {
                }
            }
            return;
        }
    }
    
    if ((lastTargetCount > 1) && (dropsiteUnitIDinCloseRange != -1))
    {
        if (ShowAiEcho == true) aiEcho("lastTargetCount > 1 and dropsiteUnitIDinCloseRange != -1, trying to send a military unit to check if the target still exists!");
        if ((equal(gRaidingPartyLastTargetLocation, cInvalidVector) == false) && (kbGetCultureForPlayer(playerID) == cCultureAtlantean))
        {
            militaryUnit1ID = findUnitByIndex(cUnitTypeHumanSoldier, 0, cUnitStateAlive, cActionIdle);
            if (militaryUnit1ID > 0)
            {
                aiTaskUnitMove(militaryUnit1ID, gRaidingPartyLastTargetLocation);
                if (ShowAiEcho == true) aiEcho("Moving military unit1: "+militaryUnit1ID+" to gRaidingPartyLastTargetLocation: "+gRaidingPartyLastTargetLocation);
            }
            else
            {
                if (ShowAiEcho == true) aiEcho("No idle military unit1 available");
            }
        }
    }
    
    if (targetUnitID < 0)
    {
        return;
    }   
    
    int numSiegeUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeAbstractSiegeWeapon);  
    
    int raidingPartyAttackID = aiPlanCreate("Raiding Party", cPlanAttack);
    if (raidingPartyAttackID < 0)
        return;

    vector militaryGatherPoint = cInvalidVector;
    if ((defPlanBaseID != mainBaseID) && (defPlanBaseID != -1) && (equal(defPlanBaseLocation, cInvalidVector) == false))
    {
        vector frontVector = kbBaseGetFrontVector(cMyID, defPlanBaseID);
        float fx = xsVectorGetX(frontVector);
        float fz = xsVectorGetZ(frontVector);
        float fxOrig = fx;
        float fzOrig = fz;
        if (aiRandInt(2) < 1)
        {
            fx = fzOrig * (-11);
            fz = fxOrig * 11;
        }
        else
        {
            fx = fzOrig * 11;
            fz = fxOrig * (-11);
        }
        frontVector = xsVectorSetX(frontVector, fx);
        frontVector = xsVectorSetZ(frontVector, fz);
        frontVector = xsVectorSetY(frontVector, 0.0);
        militaryGatherPoint = defPlanBaseLocation + frontVector;
    }
    else
    {
        militaryGatherPoint = getMainBaseMilitaryGatherPoint();
    }
    if (ShowAiEcho == true) aiEcho("militaryGatherPoint: "+militaryGatherPoint);

    aiPlanSetVariableVector(raidingPartyAttackID, cAttackPlanGatherPoint, 0, militaryGatherPoint);
    aiPlanSetVariableFloat(raidingPartyAttackID, cAttackPlanGatherDistance, 0, 20.0);
    if (dropsiteUnitIDinCloseRange < 0)
        aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanPlayerID, 0, enemyPlayerID);
    else
        aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanPlayerID, 0, playerID);

    aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanSpecificTargetID, 0, targetUnitID);
    aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
    
    aiPlanSetUnitStance(raidingPartyAttackID, cUnitStanceDefensive);
    aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
    
    aiPlanSetVariableBool(raidingPartyAttackID, cAttackPlanAutoUseGPs, 0, false);

    aiPlanSetRequiresAllNeedUnits(raidingPartyAttackID, false);
    
    if (cMyCulture == cCultureGreek)
    {
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeToxotes, 1, 3, 6);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeHippikon, 1, 1, 1);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeHoplite, 1, 1, 1);
    }
    else if (cMyCulture == cCultureEgyptian)
    {
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeSlinger, 1, 2, 2);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeAxeman, 1, 1, 3);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeSpearman, 1, 2, 4);

    }
    else if (cMyCulture == cCultureNorse)
    {
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeThrowingAxeman, 0, 0, 1);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeRaidingCavalry, 1, 3, 6);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeUlfsark, 1, 1, 1);
    }
    else if (cMyCulture == cCultureAtlantean)
    {
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeJavelinCavalry, 1, 3, 6);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeMaceman, 1, 1, 1);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeSwordsman, 1, 1, 2);
    }
    else if (cMyCulture == cCultureChinese)
    {
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeChuKoNu, 1, 3, 6);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeHalberdier, 1, 2, 3);
    }	
    
    if (targetIsMarket == true)
    {
        aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanRefreshFrequency, 0, 12);
        if (numSiegeUnitsIngDefendPlan > 1)
            aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
    }
    else
    {
        aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanRefreshFrequency, 0, 12);
    }
    
    aiPlanSetInitialPosition(raidingPartyAttackID, baseLocationToUse);

    if ((dropsiteUnitIDinCloseRange != -1) && (dropsiteUnitIDinCloseRange == targetUnitID))
        aiPlanSetDesiredPriority(raidingPartyAttackID, 44); //lower than most attack plans
    else
        aiPlanSetDesiredPriority(raidingPartyAttackID, 34); //lower than most attack plans

	
    aiPlanSetActive(raidingPartyAttackID);
    gRaidingPartyTargetUnitID = targetUnitID;
    gRaidingPartyAttackID = raidingPartyAttackID;
    if (ShowAiEcho == true) aiEcho("Creating raiding party attack plan #: "+gRaidingPartyAttackID);
    if (targetIsMarket == true)
    {
        gRaidingPartyLastMarketLocation = kbUnitGetPosition(gRaidingPartyTargetUnitID);
    }
    else
    {
        gRaidingPartyLastTargetLocation = kbUnitGetPosition(gRaidingPartyTargetUnitID);
    }
    attackPlanStartTime = xsGetTime();
    
    if (lastTargetUnitID == gRaidingPartyTargetUnitID)
        lastTargetCount = lastTargetCount + 1;
    else
    {
        lastTargetUnitID = gRaidingPartyTargetUnitID;
        lastTargetCount = 0;
    }
}

//==============================================================================
rule randomAttackGenerator
    minInterval 28 //starts in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("******* randomAttackGenerator:");

    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    
    static int attackPlanStartTime = -1;
    
    bool enemySettlementAttPlanActive = false;
    bool landAttackPlanActive = false;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector baseLocationToUse = mainBaseLocation;
    
    float closeRangeRadius = 100.0;    
    int numEnemySettlementsInCloseRange = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, mainBaseLocation, closeRangeRadius);
    int numMotherNatureSettlementsInCloseRange = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, mainBaseLocation, closeRangeRadius);
    numEnemySettlementsInCloseRange = numEnemySettlementsInCloseRange - numMotherNatureSettlementsInCloseRange;
    int numEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);

    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
        }
    }
    
    //If we already have a randomAttackPlan don't make another one.	
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true);
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (attackPlanID == -1)
                continue;
            
            if (attackPlanID == gRandomAttackPlanID)
            {
                if ((kbUnitGetCurrentHitpoints(gRandomAttackTargetUnitID) <= 0) && (gRandomAttackTargetUnitID != -1))
                {
                    aiPlanDestroy(attackPlanID);
                    gRandomAttackTargetUnitID = -1;
                    continue;
                }
                else if ((aiPlanGetState(attackPlanID) < cPlanStateAttack) && (((xsGetTime() > attackPlanStartTime + 4*60*1000) && (attackPlanStartTime != -1)) || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0)))
                {
                    aiPlanDestroy(attackPlanID);
                    gRandomAttackTargetUnitID = -1;
                    continue;
                }
                return;
            }
            else if (attackPlanID == gEnemySettlementAttPlanID)
            {
                if (aiPlanGetState(gEnemySettlementAttPlanID) < cPlanStateAttack)
                {
                    enemySettlementAttPlanActive = true;
                }
            }
            else if (attackPlanID == gLandAttackPlanID)
            {
                landAttackPlanActive = true;
            }
        }
    }
    
    if ((xsGetTime() > 15*60*1000) && (kbGetAge() < cAge3)) // Try not to get stuck in Classical forever.
	return;
	
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);

    
    if ((woodSupply < 50) || (foodSupply < 150) || (goldSupply < 100))
    {
        return;
    }
    

    if (numEnemySettlementsInCloseRange > 0)
    {
        return;
    }
    else if (numTitans > 0)
    {
        return;
    }
    else if (numEnemyTitansNearMBInR85 > 0)
    {
        return;
    }
    else if (numEnemyTitansNearDefBInR55 > 0)
    {
        return;
    }
    else if (gEnemyWonderDefendPlan > 0)
    {
        return;
    }
    
    bool targetIsMarket = false;
    bool targetIsDropsite = false;
    int index = 0;
    int playerID = -1;
    closeRangeRadius = 100.0;
    
    for (playerID = 1; < cNumberPlayers)
    {
        if (playerID == cMyID)
            continue;
        else if (kbIsPlayerAlly(playerID) == true)
            continue;
        else
        {
            if ((kbIsPlayerResigned(playerID) == true) || (kbHasPlayerLost(playerID) == true))
                continue;
            else
            {
                int enemyEconUnit = -1;
                if (kbGetCultureForPlayer(playerID) == cCultureAtlantean)
                    enemyEconUnit = cUnitTypeVillagerAtlantean;
                else
                    enemyEconUnit = cUnitTypeDropsite;
                int numEnemyDropsitesInCloseRange = getNumUnits(enemyEconUnit, cUnitStateAliveOrBuilding, -1, playerID, mainBaseLocation, closeRangeRadius);
                if (kbGetCivForPlayer(playerID) == cCivOuranos)	
				{
				int SkyPassages = getNumUnits(cUnitTypeSkyPassage, cUnitStateAliveOrBuilding, -1, playerID, mainBaseLocation, closeRangeRadius);
				if (SkyPassages > 0)
				enemyEconUnit = cUnitTypeSkyPassage;
				}				
                int dropsiteUnitIDinCloseRange = -1;
                if (numEnemyDropsitesInCloseRange > 0)
                {
                    index = aiRandInt(numEnemyDropsitesInCloseRange);
                    dropsiteUnitIDinCloseRange = findUnitByIndex(enemyEconUnit, index, cUnitStateAliveOrBuilding, -1, playerID, mainBaseLocation, closeRangeRadius);
                    targetIsDropsite = true;
                    gRandomAttackTargetUnitID = dropsiteUnitIDinCloseRange;
                    break;
                }
            }
        }
    }    
    

    if ((numEnemyMilUnitsNearMBInR85 > 8) && (dropsiteUnitIDinCloseRange < 0))
    {
        return;
    }
    
    bool settlementPosDefPlanActive = false;
    // Find the defend plans
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true );  // Defend plans, any state, active only
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;
                
            else if (defendPlanID == gSettlementPosDefPlanID)
            {
                settlementPosDefPlanActive = true;
                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 15.0);
                int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 15.0, true);
            }
        }
    }
    
    
    int enemyPlayerID = aiGetMostHatedPlayerID();
    
    
    if (dropsiteUnitIDinCloseRange < 0)
    {
        int numEnemyMarkets = kbUnitCount(enemyPlayerID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
    
        if (numEnemyMarkets > 0)
        {
            for (j = 0; < numEnemyMarkets)
            {
                int enemyMarketUnitID = findUnitByIndex(cUnitTypeMarket, j, cUnitStateAliveOrBuilding, -1, enemyPlayerID);
                vector enemyMarketPosition = kbUnitGetPosition(enemyMarketUnitID);
                //reduced radius from 50 to 40; TODO: check if it's OK
                int numEnemyBuildingsAtMarketLocation = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketPosition, 40.0);
                int numEnemyTowersAtMarketLocation = getNumUnitsByRel(cUnitTypeTower, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketPosition, 40.0);
                int numEnemyFortressesAtMarketLocation = getNumUnitsByRel(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketPosition, 40.0);
                int numEnemySettlementsAtMarketLocation = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketPosition, 40.0);
                int numMotherNatureSettlementsAtMarketLocation = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, enemyMarketPosition, 40.0);
                numEnemySettlementsAtMarketLocation = numEnemySettlementsAtMarketLocation - numMotherNatureSettlementsAtMarketLocation;
                if ((numEnemyBuildingsAtMarketLocation < 8) && (numEnemyTowersAtMarketLocation < 1) && (numEnemyFortressesAtMarketLocation < 1) && (numEnemySettlementsAtMarketLocation < 1))
                {
                    gRandomAttackTargetUnitID = enemyMarketUnitID;
                    targetIsMarket = true;
                    break;
                }
            }
        }
    }


    if ((equal(gRandomAttackLastTargetLocation, cInvalidVector) == false) && ((aiRandInt(2) < 1) || (kbGetCultureForPlayer(playerID) == cCultureAtlantean)))
    {
        int militaryUnit1ID = findUnitByIndex(cUnitTypeHumanSoldier, 0, cUnitStateAlive, cActionIdle);
        if (militaryUnit1ID > 0)
        {
            aiTaskUnitMove(militaryUnit1ID, gRandomAttackLastTargetLocation);
        }
        else
        {
        }
    }
    
    if ((targetIsMarket == false) && (equal(gRandomAttackLastMarketLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
    {
        int militaryUnit2ID = findUnitByIndex(cUnitTypeHumanSoldier, 1, cUnitStateAlive, cActionIdle);
        if (militaryUnit2ID > 0)
        {
            aiTaskUnitMove(militaryUnit2ID, gRandomAttackLastMarketLocation);
        }
        else
        {
        }
    }

    if (landAttackPlanActive == true)
    {
        return;
    }
    else if ((enemySettlementAttPlanActive == true) && (dropsiteUnitIDinCloseRange < 0) && (targetIsMarket == false))
    {
        return;
    }
    else if ((settlementPosDefPlanActive == true) && (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1))
    {
        return;
    }
    else if ((gRandomAttackTargetUnitID < 0) && (targetIsMarket == false))
    {
        return;
    }   

    int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
	int numMilUnitsInMBDefPlan1 = aiPlanGetNumberUnits(gMBDefPlan1ID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numHumanSoldiersIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeHumanSoldier);	
	
    int numHumanSoldiersInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeHumanSoldier);
    int numHumanSoldiersInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeHumanSoldier);
    int numMythUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
    int numMilUnitsInDefPlans = numMilUnitsIngDefendPlan + numMilUnitsInMBDefPlan1 + numMilUnitsInBaseUnderAttackDefPlan * 0.4 + numMilUnitsInSettlementPosDefPlan * 0.4;
    int numHumanSoldiersInDefPlans = numHumanSoldiersIngDefendPlan + numHumanSoldiersInBaseUnderAttackDefPlan * 0.4 + numHumanSoldiersInSettlementPosDefPlan * 0.4;
    
    if ((dropsiteUnitIDinCloseRange > 0) || (targetIsMarket == true))
    {
        if (mapRestrictsMarketAttack() == true)
        {
            if (numMilUnitsInDefPlans < 20)
            {
                return;
            }
        }
        else
        {
            if (numMilUnitsInDefPlans < 6)
            {
                return;
            }
        }
    }
    else
    {
        return;
    }
    
    int randomAttackPlanID = aiPlanCreate("randomAttackPlan", cPlanAttack);
    if (randomAttackPlanID < 0)
        return;
    
    vector militaryGatherPoint = cInvalidVector;
    if ((defPlanBaseID != mainBaseID) && (defPlanBaseID != -1) && (equal(defPlanBaseLocation, cInvalidVector) == false))
    {
        vector frontVector = kbBaseGetFrontVector(cMyID, defPlanBaseID);
        float fx = xsVectorGetX(frontVector);
        float fz = xsVectorGetZ(frontVector);
        float fxOrig = fx;
        float fzOrig = fz;
        if (aiRandInt(2) < 1)
        {
            fx = fzOrig * (-11);
            fz = fxOrig * 11;
        }
        else
        {
            fx = fzOrig * 11;
            fz = fxOrig * (-11);
        }
        frontVector = xsVectorSetX(frontVector, fx);
        frontVector = xsVectorSetZ(frontVector, fz);
        frontVector = xsVectorSetY(frontVector, 0.0);
        militaryGatherPoint = defPlanBaseLocation + frontVector;
    }
    else
    {
        militaryGatherPoint = getMainBaseMilitaryGatherPoint();
    }
    if (ShowAiEcho == true) aiEcho("militaryGatherPoint: "+militaryGatherPoint);
    
    aiPlanSetVariableVector(randomAttackPlanID, cAttackPlanGatherPoint, 0, militaryGatherPoint);
    aiPlanSetVariableFloat(randomAttackPlanID, cAttackPlanGatherDistance, 0, 30.0);
    if (dropsiteUnitIDinCloseRange > 0)
        aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanPlayerID, 0, playerID);
    else
        aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanPlayerID, 0, enemyPlayerID);
    
    if ((dropsiteUnitIDinCloseRange > 0) || (targetIsMarket == true))
    {
        aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanSpecificTargetID, 0, gRandomAttackTargetUnitID);
        aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
        aiPlanSetUnitStance(randomAttackPlanID, cUnitStanceDefensive);
        aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
        aiPlanSetRequiresAllNeedUnits(randomAttackPlanID, false);
        if (((enemySettlementAttPlanActive == true) && (mapRestrictsMarketAttack() == false)) || (dropsiteUnitIDinCloseRange > 0))
        {
            if (targetIsMarket == true)
            {
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeHero, 0, 1, 1);
                
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                    aiPlanAddUnitType(randomAttackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
                
                if (aiRandInt(2) < 1)
                    aiPlanSetVariableBool(randomAttackPlanID, cAttackPlanAutoUseGPs, 0, false);
                else
                    aiPlanSetVariableBool(randomAttackPlanID, cAttackPlanAutoUseGPs, 0, true);
            }
            else
                aiPlanSetVariableBool(randomAttackPlanID, cAttackPlanAutoUseGPs, 0, false);
            
            if (numHumanSoldiersInDefPlans < 10)
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeHumanSoldier, 4, 6, 6);
            else
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeHumanSoldier, numHumanSoldiersInDefPlans * 0.5, numHumanSoldiersInDefPlans * 0.7, numHumanSoldiersInDefPlans * 0.7);
        }
        else
        {
            if (mapRestrictsMarketAttack() == false)
            {
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeHero, 0, 1, 1);
                
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                    aiPlanAddUnitType(randomAttackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
                
                if (numHumanSoldiersInDefPlans < 10)
                    aiPlanAddUnitType(randomAttackPlanID, cUnitTypeHumanSoldier, 4, 7, 7);
                else
                    aiPlanAddUnitType(randomAttackPlanID, cUnitTypeHumanSoldier, numHumanSoldiersInDefPlans * 0.5, numHumanSoldiersInDefPlans * 0.85, numHumanSoldiersInDefPlans * 0.85);
            }
            else
            {
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeAbstractSiegeWeapon, 0, 2, 2);
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeHero, 0, 1, 1);
                
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                    aiPlanAddUnitType(randomAttackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
                
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.6, numMilUnitsInDefPlans * 0.9, numMilUnitsInDefPlans * 0.9);
            }
            
            if (aiRandInt(2) < 1)
                aiPlanSetVariableBool(randomAttackPlanID, cAttackPlanAutoUseGPs, 0, false);
            else
                aiPlanSetVariableBool(randomAttackPlanID, cAttackPlanAutoUseGPs, 0, true);
        }
    }
	

	
    aiPlanSetInitialPosition(randomAttackPlanID, baseLocationToUse);
    aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanRefreshFrequency, 0, 12);

    aiPlanSetNumberVariableValues(randomAttackPlanID, cAttackPlanTargetTypeID, 5, false);
    aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanTargetTypeID, 0, cUnitTypeAbstractVillager);	
    aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanTargetTypeID, 1, cUnitTypeUnit);
	aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanTargetTypeID, 2, cUnitTypeMilitaryBuilding);
	aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanTargetTypeID, 3, cUnitTypeBuilding);
    aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanTargetTypeID, 4, cUnitTypeAbstractWall);	

   	// Specify other continent so that armies will transport
    if (gTransportMap == true)
	{
	vector targetPos = kbUnitGetPosition(gRandomAttackTargetUnitID);
	aiPlanSetNumberVariableValues(randomAttackPlanID, cAttackPlanTargetAreaGroups, 1, true);   
	aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(targetPos));
	}
	
	aiPlanSetDesiredPriority(randomAttackPlanID, 50);
	
    aiPlanSetActive(randomAttackPlanID);
    gRandomAttackPlanID = randomAttackPlanID;
    if (ShowAiEcho == true) aiEcho("Creating randomAttackPlan #: "+gRandomAttackPlanID);
    
    if (targetIsMarket == true)
    {
        gRandomAttackLastMarketLocation = kbUnitGetPosition(gRandomAttackTargetUnitID);
    }
    else if (targetIsDropsite == true)
    {
        gRandomAttackLastTargetLocation = kbUnitGetPosition(gRandomAttackTargetUnitID);
    }
    
    attackPlanStartTime = xsGetTime();
}

//==============================================================================
rule createLandAttack
    minInterval 27 //starts in cAge2
    inactive
{
	
	xsSetRuleMinIntervalSelf(15+aiRandInt(12));
    if (ShowAiEcho == true) aiEcho("createLandAttack:");
    if ((mRusher == true) && (kbGetAge() < cAge3))
	xsSetRuleMinIntervalSelf(12);
	
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    int numRagnorokHeroes = kbUnitCount(cMyID, cUnitTypeHeroRagnorok, cUnitStateAlive);
    static int attackPlanStartTime = -1;
    
    bool enemySettlementAttPlanActive = false;
    bool randomAttackPlanActive = false;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector baseLocationToUse = mainBaseLocation;
    
    int numSiegeWeapons = kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive);
    int numMythUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeMythUnitNotTitan, cUnitStateAlive);
    int numNonMilitaryMythUnits = kbUnitCount(cMyID, cUnitTypePegasus, cUnitStateAlive);
    if (cMyCiv == cCivOdin)
        numNonMilitaryMythUnits = numNonMilitaryMythUnits + kbUnitCount(cMyID, cUnitTypeRaven, cUnitStateAlive);
    else if (cMyCulture == cCultureAtlantean)
        numNonMilitaryMythUnits = numNonMilitaryMythUnits + kbUnitCount(cMyID, cUnitTypeFlyingMedic, cUnitStateAlive);
    int numMilitaryMythUnits = numMythUnits - numNonMilitaryMythUnits;
    if (ShowAiEcho == true) aiEcho("numSiegeWeapons: "+numSiegeWeapons);
    if (ShowAiEcho == true) aiEcho("numMilitaryMythUnits: "+numMilitaryMythUnits);
    
    int numEnemySettlements = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, kbGetMapCenter(), 2000.0);
    int numMotherNatureSettlements = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, kbGetMapCenter(), 2000.0);
    if (ShowAiEcho == true) aiEcho("numEnemySettlements: "+numEnemySettlements);
    if (ShowAiEcho == true) aiEcho("numMotherNatureSettlements: "+numMotherNatureSettlements);
    numEnemySettlements = numEnemySettlements - numMotherNatureSettlements;
    if (ShowAiEcho == true) aiEcho("modified numEnemySettlements: "+numEnemySettlements);
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);

    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
        }
    }
    
    //If we already have a landAttackPlan don't make another one.	
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true);
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            if (attackPlanID == -1)
                continue;
            
            if (attackPlanID == gLandAttackPlanID)
            {
                if (ShowAiEcho == true) aiEcho("attackPlanID == gLandAttackPlanID");
				
                if ((aiPlanGetState(attackPlanID) < cPlanStateAttack)
                 && (((xsGetTime() > attackPlanStartTime + 3*60*1000) && (attackPlanStartTime != -1))
                  || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 1) || (gTransportMap == true) && (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0)) 
				  || (gTransportMap == true) && (aiPlanGetState(attackPlanID) == cPlanStateGather) && (xsGetTime() > attackPlanStartTime + 2*60*1000))
                {
                    aiPlanDestroy(attackPlanID);
                    if (ShowAiEcho == true) aiEcho("destroying gLandAttackPlanID as it has been active for more than 4 Minutes");
                    continue;
                }
                if (ShowAiEcho == true) aiEcho("returning");
                return;
            }
            else if (attackPlanID == gEnemySettlementAttPlanID)
            {
                if (ShowAiEcho == true) aiEcho("there is a gEnemySettlementAttPlanID active");
                enemySettlementAttPlanActive = true;
            }
            else if (attackPlanID == gRandomAttackPlanID)
            {
                if (ShowAiEcho == true) aiEcho("there is a gRandomAttackPlanID active");
                randomAttackPlanActive = true;
            }
        }
    }
    if ((xsGetTime() > 15*60*1000) && (kbGetAge() < cAge3)) // Try not to get stuck in Classical forever.
	return;
    int enemyPlayerID = aiGetMostHatedPlayerID();
    int numTargetPlayerSettlements = kbUnitCount(enemyPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);

    
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();
	
	int number = 0;
	if (mPopLandAttack == true)
	{
	int numTcs=kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
	if (numTcs > 2)
	{
    number = numTcs * 8 - 10;
    if (currentPopCap >= 300)
	number = 50;
	}
    }
	
    // StandardAI Pop
    int upID = -1;                   // Active unit picker, for getting target military size
    int targetPop = -1;              // Size needed to launch an attack, in pop slots
   
    if (kbGetAge() < cAge3)
    upID = gRushUPID;
    else
    upID = gLateUPID;
    targetPop = kbUnitPickGetMinimumPop(upID);  
    //	
   
    int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
	int numMilUnitsInMBDefPlan1 = aiPlanGetNumberUnits(gMBDefPlan1ID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMythUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
	
    if (ShowAiEcho == true) aiEcho("numMilUnitsIngDefendPlan: "+numMilUnitsIngDefendPlan);
    if (ShowAiEcho == true) aiEcho("numMilUnitsInBaseUnderAttackDefPlan: "+numMilUnitsInBaseUnderAttackDefPlan);
    if (ShowAiEcho == true) aiEcho("numMilUnitsInSettlementPosDefPlan: "+numMilUnitsInSettlementPosDefPlan);
    int numMilUnitsInDefPlans = numMilUnitsIngDefendPlan + numMilUnitsInMBDefPlan1 + numMilUnitsInBaseUnderAttackDefPlan * 0.4 + numMilUnitsInSettlementPosDefPlan * 0.4;
    if (ShowAiEcho == true) aiEcho("total numMilUnitsInDefPlans: "+numMilUnitsInDefPlans);	

    if ((kbGetAge() < cAge3) || (gRushAttackCount < gRushCount))
    {
        if (gRushCount < 1)
        {
            if (ShowAiEcho == true) aiEcho("returning as we don't want to rush");
            return;
        }
        else if (gRushAttackCount >= gRushCount)
        {
            if (ShowAiEcho == true) aiEcho("returning as gRushAttackCount >= gRushCount");
            return;
        }
    }
        if ((foodSupply < 50) || (goldSupply < 50))
        {
            if (ShowAiEcho == true) aiEcho("returning as we don't have enough resources");
            return;
        }
  
    
    if ((numTitans > 0) && (numTargetPlayerSettlements > 0))
    {
        if (ShowAiEcho == true) aiEcho("createLandAttack: returning as we have a Titan and our target player still has settlements");
        return;
    }   
    else if (numEnemyTitansNearMBInR85 > 0)
    {
        if (ShowAiEcho == true) aiEcho("createLandAttack: returning as there's an enemy Titan near our main base");
        return;
    }
    else if (numEnemyTitansNearDefBInR55 > 0)
    {
        if (ShowAiEcho == true) aiEcho("createLandAttack: returning as there's an enemy Titan near our defPlanBase");
        return;
    }
    else if (gEnemyWonderDefendPlan > 0)
    {
        if (ShowAiEcho == true) aiEcho("createLandAttack: returning as there's a wonder attack plan open");
        return;
    }
    else if (numEnemyMilUnitsNearMBInR80 > 10)
    {
        if (ShowAiEcho == true) aiEcho("createLandAttack: returning as there are too many enemies near our main base");
        return;
    }
    
    bool settlementPosDefPlanActive = false;
    // Find the defend plans
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true );  // Defend plans, any state, active only
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;
                
            else if (defendPlanID == gSettlementPosDefPlanID)
            {
                settlementPosDefPlanActive = true;
                if (ShowAiEcho == true) aiEcho("settlementPosDefPlanActive = true");
                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 15.0);
				int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 35.0, true);
				
			    int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
	            int NumEnemyBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
				int alliedMilUnitsNearDefPointInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 70.0, true);
				int Combined = NumEnemyBuildings + enemyMilUnitsInR50;
				if (Combined < 10)
				settlementPosDefPlanActive = false;
            }
        }
    }
    
    if ((enemySettlementAttPlanActive == true) && (numMilUnitsInDefPlans < 15)) //trying this..
    {
        if (ShowAiEcho == true) aiEcho("returning as there is a gEnemySettlementAttPlanID active");
        return;
    }
    else if ((randomAttackPlanActive == true) && (aiPlanGetState(attackPlanID) < cPlanStateAttack))
    {
        if (ShowAiEcho == true) aiEcho("returning as there is a gRandomAttackPlanID active and gathering units");
        return;
    }
    else if ((randomAttackPlanActive == true) && (aiPlanGetNumberUnits(gRandomAttackPlanID, cUnitTypeLogicalTypeLandMilitary) > 10) && (numMilUnitsInDefPlans < 15)) //trying this..
    {
        if (ShowAiEcho == true) aiEcho("returning as there is a gRandomAttackPlanID active and there are more than 10 units in the plan");
        return;
    }
    else if ((settlementPosDefPlanActive == true) && (kbGetAge() > cAge2) || (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1) && (Combined > 9))
    {
        if (ShowAiEcho == true) aiEcho("returning as there is a gSettlementPosDefPlanID active");
        return;
    }
        
   
    int requiredUnits = currentPopCap / 10;
    if ((kbGetAge() == cAge2) || (gRushAttackCount < gRushCount))
    {
        if ((gRushCount > 1) && (gRushAttackCount == 0))
            requiredUnits = gFirstRushSize;
        else
            requiredUnits = gRushSize;
    }
    else
    {
        if ((UseStandardPop == false) && (currentPop <= currentPopCap - 10 - number) || (UseStandardPop == true) && (numMilUnitsInDefPlans*3 < targetPop))
        {
            if (ShowAiEcho == true) aiEcho("returning as currentPop <= currentPopCap - 10");
            return;
        }
    }
    
    if (numMilUnitsInDefPlans < requiredUnits * 0.8)
    {
        if (ShowAiEcho == true) aiEcho("returning as there are only "+numMilUnitsInDefPlans+" units in our defend plans.");
        return;
    }
    
    
    int landAttackPlanID = aiPlanCreate("landAttackPlan", cPlanAttack);
    if (landAttackPlanID < 0)
        return;
    
    vector militaryGatherPoint = cInvalidVector;
    if ((defPlanBaseID != mainBaseID) && (defPlanBaseID != -1) && (equal(defPlanBaseLocation, cInvalidVector) == false))
    {
        vector frontVector = kbBaseGetFrontVector(cMyID, defPlanBaseID);
        float fx = xsVectorGetX(frontVector);
        float fz = xsVectorGetZ(frontVector);
        float fxOrig = fx;
        float fzOrig = fz;
        if (aiRandInt(2) < 1)
        {
            fx = fzOrig * (-11);
            fz = fxOrig * 11;
        }
        else
        {
            fx = fzOrig * 11;
            fz = fxOrig * (-11);
        }
        frontVector = xsVectorSetX(frontVector, fx);
        frontVector = xsVectorSetZ(frontVector, fz);
        frontVector = xsVectorSetY(frontVector, 0.0);
        militaryGatherPoint = defPlanBaseLocation + frontVector;
    }
    else
    {
        militaryGatherPoint = getMainBaseMilitaryGatherPoint();
    }
    if (ShowAiEcho == true) aiEcho("militaryGatherPoint: "+militaryGatherPoint);
    
    aiPlanSetVariableVector(landAttackPlanID, cAttackPlanGatherPoint, 0, militaryGatherPoint);
    aiPlanSetVariableFloat(landAttackPlanID, cAttackPlanGatherDistance, 0, 30.0);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanPlayerID, 0, enemyPlayerID);
   
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
    aiPlanSetUnitStance(landAttackPlanID, cUnitStanceDefensive);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
    aiPlanSetRequiresAllNeedUnits(landAttackPlanID, false);

    if (numEnemySettlements < 1)
    {
        aiPlanAddUnitType(landAttackPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.90, numMilUnitsInDefPlans * 0.95, numMilUnitsInDefPlans);
        aiPlanSetVariableInt(landAttackPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeNone);
    }
    else
    {
        aiPlanAddUnitType(landAttackPlanID, cUnitTypeAbstractSiegeWeapon, 0, 2, 3);
        if (numRagnorokHeroes < 10)
            aiPlanAddUnitType(landAttackPlanID, cUnitTypeHero, 0, 1, 1);
        
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(landAttackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
    
        aiPlanAddUnitType(landAttackPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.9, numMilUnitsInDefPlans, numMilUnitsInDefPlans);  
        aiPlanSetVariableInt(landAttackPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
    }
    
	// Specify other continent so that armies will transport
    if (gTransportMap == true)
	{
	int targetSettlementID = -1;
	int enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(enemyPlayerID);
	targetSettlementID = enemyMainBaseUnitID;
	vector targetSettlementPos = kbUnitGetPosition(targetSettlementID); // uses main TC
    aiPlanSetNumberVariableValues(landAttackPlanID, cAttackPlanTargetAreaGroups, 1, true);
	if (kbAreaGroupGetIDByPosition(targetSettlementPos) != kbAreaGroupGetIDByPosition(baseLocationToUse))
	aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(targetSettlementPos));
    }
	
    aiPlanSetInitialPosition(landAttackPlanID, baseLocationToUse);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanRefreshFrequency, 0, 10);

    if (aiRandInt(2) < 1)
    aiPlanSetVariableBool(landAttackPlanID, cAttackPlanAutoUseGPs, 0, false);
    else
    aiPlanSetVariableBool(landAttackPlanID, cAttackPlanAutoUseGPs, 0, true);

    
    aiPlanSetNumberVariableValues(landAttackPlanID, cAttackPlanTargetTypeID, 5, true); 
	aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetTypeID, 0, cUnitTypeAbstractVillager);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetTypeID, 1, cUnitTypeUnit);
	aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetTypeID, 2, cUnitTypeMilitaryBuilding);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetTypeID, 3, cUnitTypeBuilding);
	aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetTypeID, 4, cUnitTypeAbstractTradeUnit);
    
	aiPlanSetDesiredPriority(landAttackPlanID, 50);
	
	int FromGoal = aGoalID;
	if (kbGetAge() >= cAge3)
	FromGoal = gLandAttackGoalID;
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanFromGoalID, 0, gLandAttackGoalID);
    aiPlanSetActive(landAttackPlanID);
	gLandAttackPlanID = landAttackPlanID;
	if (cMyCiv == cCivKronos)
    aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanAttackPlanID, 0, landAttackPlanID);
	
	int GPFindPlan = aiFindBestAttackGodPowerPlan();
	if ((GPFindPlan > 0) && (GPFindPlan != gUnbuildPlanID))
    aiPlanSetVariableInt(GPFindPlan, cGodPowerPlanAttackPlanID, 0, landAttackPlanID);		
    
    if (gRushAttackCount < gRushCount)
        gRushAttackCount = gRushAttackCount + 1;
    

    if (ShowAiEcho == true) aiEcho("Creating landAttackPlan #: "+gLandAttackPlanID);

    attackPlanStartTime = xsGetTime();
    
}

//==============================================================================
rule setUnitPicker
    minInterval 103 //starts in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("setUnitPicker:");

    if (xsGetTime() < 15*60*1000)
        return;
    
    static bool rushUPupdate = false;
    static bool landUPupdate = false;
    
    if (rushUPupdate == false)
    {
        // increase the number of buildings of the rushUPID
        kbUnitPickSetDesiredNumberUnitTypes(gRushUPID, 3, 2, true);  // 2 unit types and 2 buildings
        rushUPupdate = true;
        return;
    }
    else if (kbGetAge() > cAge2)
    {
        int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive);
        int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAlive);
        if ((numFortresses > 0) && (numMarkets > 0))
        {
            if (landUPupdate == false)
            {
                // increase the number of buildings of the lateUPID
                kbUnitPickSetDesiredNumberUnitTypes(gLateUPID, 3, 3, true);  // 3 unit types and 3 buildings.
                landUPupdate = true;
            }
        }
        
        if ((kbGetTechStatus(cTechSecretsoftheTitans) > cTechStatusResearching) || (kbGetAge() > cAge3) && (TitanAvailable == false))
        {
            kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeAbstractSiegeWeapon, 0.8);		
            if (landUPupdate == false)
            {
                kbUnitPickSetDesiredNumberUnitTypes(gLateUPID, 3, 3, true);  // 3 unit types and 3 buildings.
                landUPupdate = true;
            }
            xsDisableSelf();
        }
    }
}

//==============================================================================
rule defendBaseUnderAttack
    minInterval 1 //starts in cAge2, activated in baseAttackTracker rule
    inactive
{
    if (ShowAiEcho == true) aiEcho("defendBaseUnderAttack: ");
    
    xsSetRuleMinIntervalSelf(15);
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    float distToMainBase = xsVectorLength(mainBaseLocation - gBaseUnderAttackLocation);
    
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int myMilUnitsNearMBInR80 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 80.0);
   
    static int defendPlanStartTime = -1;
    
    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
    
    int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, gBaseUnderAttackLocation, 15.0, true);
    if (ShowAiEcho == true) aiEcho("alliedBaseAtDefPlanPosition: "+alliedBaseAtDefPlanPosition);
    
    int enemyMilUnitsInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, gBaseUnderAttackLocation, 40.0, true);
    int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, gBaseUnderAttackLocation, 50.0, true);
    int enemySettlementAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, gBaseUnderAttackLocation, 15.0);
    int numMotherNatureSettlementsAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, gBaseUnderAttackLocation, 15.0);
    int numAttEnemySiegeInR50 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, gBaseUnderAttackLocation, 50.0, true);
    
    //If we already have a gBaseUnderAttackDefPlanID, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;
                
            int defPlanBaseID = aiPlanGetBaseID(defendPlanID);
            if (defendPlanID == gBaseUnderAttackDefPlanID)
            {

                if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0)
                 || (enemySettlementAtDefPlanPosition - numMotherNatureSettlementsAtDefPlanPosition > 0)
                 || ((numEnemyMilUnitsNearMBInR80 > 15) && (numEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 2.5)))
                {
                    aiPlanDestroy(defendPlanID);
                    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0))
                        if (ShowAiEcho == true) aiEcho("destroying gBaseUnderAttackDefPlanID as there's an enemy Titan near our main base");
                    else if (enemySettlementAtDefPlanPosition - numMotherNatureSettlementsAtDefPlanPosition > 0)
                        if (ShowAiEcho == true) aiEcho("destroying gBaseUnderAttackDefPlanID as there's an enemy settlement at our defend postion");
                    else
                        if (ShowAiEcho == true) aiEcho("destroying gBaseUnderAttackDefPlanID as there are too many enemies near our main base");
                    gBaseUnderAttackDefPlanID = -1;
                    
                    aiPlanDestroy(gDefendPlanID);
                    gDefendPlanID = -1;
                    xsDisableRule("defendPlanRule");
                    if (ShowAiEcho == true) aiEcho("destroying current gDefendPlanID and restarting defendPlanRule");
                    gBaseUnderAttackID = -1;
                    
                    xsSetRuleMinInterval("defendPlanRule", 2);
                    xsEnableRule("defendPlanRule");
                    
                    xsSetRuleMinIntervalSelf(1);
                    xsDisableSelf();
                    return;
                }

                if ((alliedBaseAtDefPlanPosition > 0) || ((xsGetTime() > defendPlanStartTime + 20*1000) && (enemyMilUnitsInR50 < 3) && (numAttEnemySiegeInR50 < 1)))
                {
                    aiPlanDestroy(defendPlanID);
                    if (alliedBaseAtDefPlanPosition > 0)
                        if (ShowAiEcho == true) aiEcho("destroying gBaseUnderAttackDefPlanID as an ally has built a base at our defend position");
                    else
                        if (ShowAiEcho == true) aiEcho("destroying gBaseUnderAttackDefPlanID as it has been active for more than 20 seconds and there are less than 3 enemies");
                    gBaseUnderAttackID = -1;
                    gBaseUnderAttackDefPlanID = -1;
                    xsSetRuleMinIntervalSelf(1);
                    xsDisableSelf();
                    return;
                }
                
                if (defPlanBaseID != gBaseUnderAttackID)
                {
                    if (ShowAiEcho == true) aiEcho("defPlanBaseID: "+defPlanBaseID+", gBaseUnderAttackID: "+gBaseUnderAttackID);
                    if (ShowAiEcho == true) aiEcho("strange, defPlanBaseID != gBaseUnderAttackID, updating defPlanBaseID to gBaseUnderAttackID");
                    aiPlanSetBaseID(defendPlanID, gBaseUnderAttackID);
                }
                return;
            }
        }
    }
    
    if (gEnemyWonderDefendPlan > 0)
    {
        if (ShowAiEcho == true) aiEcho("returning as there's a wonder attack plan open");
        return;
    }
    
    if (numMilUnits < 20)
    {
        if (ShowAiEcho == true) aiEcho("returning as we only have "+numMilUnits+" military units");
        return;
    }
    
    if (ShowAiEcho == true) aiEcho("gBaseUnderAttackLocation: "+gBaseUnderAttackLocation);
    int baseUnderAttackDefPlanID = aiPlanCreate("baseUnderAttackDefPlan", cPlanDefend);
    if (baseUnderAttackDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
        aiPlanSetVariableInt(baseUnderAttackDefPlanID, cDefendPlanRefreshFrequency, 0, 15);
        
        aiPlanSetVariableVector(baseUnderAttackDefPlanID, cDefendPlanDefendPoint, 0, gBaseUnderAttackLocation);
        
        aiPlanSetVariableFloat(baseUnderAttackDefPlanID, cDefendPlanEngageRange, 0, 40.0);

        aiPlanSetVariableFloat(baseUnderAttackDefPlanID, cDefendPlanGatherDistance, 0, 20.0);

        aiPlanSetUnitStance(baseUnderAttackDefPlanID, cUnitStanceDefensive);
        aiPlanSetVariableBool(baseUnderAttackDefPlanID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(baseUnderAttackDefPlanID, cDefendPlanAttackTypeID, 3, true);
        aiPlanSetVariableInt(baseUnderAttackDefPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(baseUnderAttackDefPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);
		aiPlanSetVariableInt(baseUnderAttackDefPlanID, cDefendPlanAttackTypeID, 2, cUnitTypeAbstractVillager);

        if (distToMainBase < 80.0)
        {
            if (cMyCulture == cCultureAtlantean)
            {
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHero, 1, 1, 1);
            }
            else
            {
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHero, 1, 1, 1);
            }
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
            
            aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 4, 16, 16);
            if (cMyCiv == cCivHades)
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeShadeofHades, 0, 2, 2);
        }
        else
        {
            if (cMyCulture == cCultureNorse)
            {
                if (kbGetAge() > cAge3)
                    aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHero, 1, 3, 3);
                else
                    aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHero, 1, 2, 2);
            }
            else if (cMyCulture == cCultureAtlantean)
            {
                if (kbGetAge() > cAge3)
                    aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHero, 1, 2, 2);
                else
                    aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHero, 1, 1, 1);
            }
            else
            {           
                if (kbGetAge() > cAge3)
                    aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHero, 1, 2, 2);
                else
                    aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHero, 1, 1, 1);                    
            }
            if (distToMainBase > 110.0)
            {
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                    aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
                
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeAbstractSiegeWeapon, 1, 2, 2);
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 8, 20, 20);
            }
            else
            {
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                    aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
                
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeAbstractSiegeWeapon, 1, 1, 1);
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 5, 18, 18);
            }
            if (cMyCiv == cCivHades)
                aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeShadeofHades, 0, 4, 4);
        }
        aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeAbstractTitan, 0, 1, 1);
        
        
        //override
        if (enemyMilUnitsInR40 > 16)
            aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 8, enemyMilUnitsInR40 + 6, enemyMilUnitsInR40 + 6);
        
        aiPlanSetDesiredPriority(baseUnderAttackDefPlanID, 53);
        aiPlanSetBaseID(baseUnderAttackDefPlanID, gBaseUnderAttackID);
        aiPlanSetActive(baseUnderAttackDefPlanID);
        gBaseUnderAttackDefPlanID = baseUnderAttackDefPlanID;
        if (ShowAiEcho == true) aiEcho("baseUnderAttackDefPlanID set active: "+gBaseUnderAttackDefPlanID);
        xsSetRuleMinIntervalSelf(15);
    }
}

//==============================================================================
rule defendAlliedBase   //TODO: check all allied bases not just the main base of each ally
    minInterval 89 //starts in cAge2
    inactive
{
 
 if (mCanIDefendAllies == false)
 {
	xsDisableSelf();
	return;
 }   
    if (ShowAiEcho == true) aiEcho("........defendAlliedBase: ");
    xsSetRuleMinIntervalSelf(89);
 
    int startIndex = aiRandInt(cNumberPlayers);
    int alliedBaseUnitID = -1;
    for (i = 0; < cNumberPlayers)
    {
        //If we're past the end of our players, go back to the start.
        int actualIndex = i + startIndex;
        if (actualIndex >= cNumberPlayers)
            actualIndex = actualIndex - cNumberPlayers;
        if (actualIndex <= 0)
            continue;
        if (actualIndex == cMyID)
            continue;
        if (kbIsPlayerAlly(actualIndex) == true)
        {
            if (kbIsPlayerResigned(actualIndex) == true)
                continue;
            
            alliedBaseUnitID = getMainBaseUnitIDForPlayer(actualIndex);
            
            vector alliedBaseLocation = kbUnitGetPosition(alliedBaseUnitID);
            int numEnemyTitansInR70 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 70.0, true);
            int numEnemyMilUnitsInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 70.0, true);
            int alliedMilUnitsInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, alliedBaseLocation, 70.0, true);
            
            if ((numEnemyTitansInR70 > 0) || (numEnemyMilUnitsInR70 > alliedMilUnitsInR70))
            {
                if (ShowAiEcho == true) aiEcho("numEnemyTitansInR70 > 0 or numEnemyMilUnitsInR70 > alliedMilUnitsInR70, using alliedBaseUnitID: "+alliedBaseUnitID);
                break;
            }
            else
                alliedBaseUnitID = -1;
        }
    }    
    
   
    static int defendPlanStartTime = -1;
    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
    
    int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, alliedBaseLocation, 15.0, true);
    if (ShowAiEcho == true) aiEcho("alliedBaseAtDefPlanPosition: "+alliedBaseAtDefPlanPosition);

    int enemySettlementAtAlliedBasePosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 15.0);
    int numMotherNatureSettlementsAtAlliedBasePosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, alliedBaseLocation, 15.0);
    
    //If we already have a gAlliedBaseDefPlanID, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (j = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, j);
            if (defendPlanID == -1)
                continue;
                
            vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
            int enemySettlementAtDefPointPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 15.0);
            int numMotherNatureSettlementsAtDefPointPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, defPlanDefPoint, 15.0);
            int numEnemyTitansNearDefPointInR70 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 70.0, true);
            int numEnemyMilUnitsNearDefPointInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 70.0, true);
            int alliedMilUnitsNearDefPointInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 70.0, true);
            static int count = 0;
            
            if (defendPlanID == gAlliedBaseDefPlanID)
            {
                if (ShowAiEcho == true) aiEcho("gAlliedBaseDefPlanID exists: ID is "+defendPlanID);
                xsSetRuleMinIntervalSelf(20); // be on alert
                if (enemySettlementAtDefPointPosition - numMotherNatureSettlementsAtDefPointPosition > 0)
                {
                    aiPlanDestroy(defendPlanID);
                    if (ShowAiEcho == true) aiEcho("destroying gAlliedBaseDefPlanID as there's an enemy settlement at the allied base position");
                    gAlliedBaseDefPlanID = -1;
					xsSetRuleMinIntervalSelf(40);
                    count = 0;
                    return;
                }

                if ((numEnemyTitansNearDefPointInR70 < 1) && (numEnemyMilUnitsNearDefPointInR70 < alliedMilUnitsNearDefPointInR70))
                {
                    if (count > 1)
                    {
                        aiPlanDestroy(defendPlanID);
                        if (ShowAiEcho == true) aiEcho("destroying gAlliedBaseDefPlanID as there are no enemy Titans and there are less enemies than allies");
                        gAlliedBaseDefPlanID = -1;
						xsSetRuleMinIntervalSelf(40);
                        count = 0;
                        return;
                    }
                    else
                        count = count + 1;
                }
                else
                {
                    count = 0;
                    if ((numEnemyTitansNearDefPointInR70 > 0) && (numEnemyMilUnitsNearDefPointInR70 < 16))
                    {
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 20, 20);
                    }
                    else
                    {
                        aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, numEnemyMilUnitsNearDefPointInR70 - alliedMilUnitsInR70 + 4, numEnemyMilUnitsNearDefPointInR70 - alliedMilUnitsNearDefPointInR70 + 4);
                    }
                }
                return;
            }
        }
    }
    
    if (alliedBaseUnitID == -1)
    {
        if (ShowAiEcho == true) aiEcho("returning as alliedBaseUnitID == -1");
        return;
    }
    
    if (enemySettlementAtAlliedBasePosition - numMotherNatureSettlementsAtAlliedBasePosition > 0)
    {
        if (ShowAiEcho == true) aiEcho("returning as there's an enemy settlement at the allied base position");
        return;
    }
    
    if (gEnemyWonderDefendPlan > 0)
    {
        if (ShowAiEcho == true) aiEcho("returning as there's a wonder attack plan open");
        return;
    }
    
    if (numMilUnits < 20)
    {
        if (ShowAiEcho == true) aiEcho("returning as we only have "+numMilUnits+" military units");
        return;
    }
    
    if (ShowAiEcho == true) aiEcho("alliedBaseLocation: "+alliedBaseLocation);
    int alliedBaseDefPlanID = aiPlanCreate("alliedBaseDefPlanID", cPlanDefend);
    if (alliedBaseDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
        aiPlanSetVariableInt(alliedBaseDefPlanID, cDefendPlanRefreshFrequency, 0, 15);
        
        aiPlanSetVariableVector(alliedBaseDefPlanID, cDefendPlanDefendPoint, 0, alliedBaseLocation);
        
        aiPlanSetVariableFloat(alliedBaseDefPlanID, cDefendPlanEngageRange, 0, 70.0);

        aiPlanSetVariableFloat(alliedBaseDefPlanID, cDefendPlanGatherDistance, 0, 15.0);

        aiPlanSetUnitStance(alliedBaseDefPlanID, cUnitStanceDefensive);
        aiPlanSetVariableBool(alliedBaseDefPlanID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(alliedBaseDefPlanID, cDefendPlanAttackTypeID, 3, true);
        aiPlanSetVariableInt(alliedBaseDefPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(alliedBaseDefPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);
        aiPlanSetVariableInt(alliedBaseDefPlanID, cDefendPlanAttackTypeID, 2, cUnitTypeAbstractVillager);
        if (cMyCulture == cCultureNorse)
        {
            aiPlanAddUnitType(alliedBaseDefPlanID, cUnitTypeHero, 1, 2, 2);
        }
        else if (cMyCulture == cCultureAtlantean)
        {    
            aiPlanAddUnitType(alliedBaseDefPlanID, cUnitTypeHero, 1, 1, 1);
        }
        else
        {    
            aiPlanAddUnitType(alliedBaseDefPlanID, cUnitTypeHero, 1, 1, 1);
        }

        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(alliedBaseDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);

        if ((numEnemyTitansInR70 > 0) && (numEnemyMilUnitsInR70 < 16))
        {
            aiPlanAddUnitType(alliedBaseDefPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 20, 20);
        }
        else
        {
            aiPlanAddUnitType(alliedBaseDefPlanID, cUnitTypeLogicalTypeLandMilitary, 0, numEnemyMilUnitsInR70 - alliedMilUnitsInR70 + 4, numEnemyMilUnitsInR70 - alliedMilUnitsInR70 + 4);
        }
        
        aiPlanSetDesiredPriority(alliedBaseDefPlanID, 35);
        aiPlanSetActive(alliedBaseDefPlanID);
        gAlliedBaseDefPlanID = alliedBaseDefPlanID;
		xsSetRuleMinIntervalSelf(20); // be on alert
        if (ShowAiEcho == true) aiEcho("alliedBaseDefPlanID set active: "+gAlliedBaseDefPlanID);
    }
}

//==============================================================================
rule tacticalBuildings
    minInterval 103 //starts in cAge1, is set to 11 in cAge2
    inactive
{
    if (ShowAiEcho == true) aiEcho("tacticalBuildings:");

    static bool alreadyInAge2 = false;
    
    if (alreadyInAge2 == false)
    {
        if (kbGetAge() == cAge2)
        {
            xsSetRuleMinIntervalSelf(11);
            alreadyInAge2 = true;
        }
    }
    
    int numAttBuildings = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, cActionRangedAttack, cMyID);
    int max = 16;
    if (cMyCulture == cCultureAtlantean)
        max = 9;
    if (numAttBuildings > max)
        numAttBuildings = max;
    if (numAttBuildings < 1)
    {
        return;
    }
    for (i = 0; < numAttBuildings)
    {
        int attBuildingID = findUnitByIndex(cUnitTypeBuildingsThatShoot, i, cUnitStateAlive, cActionRangedAttack, cMyID);
        if (attBuildingID == -1)
            continue;
        
        
        int currentTargetID = kbUnitGetTargetUnitID(attBuildingID);
        if (kbUnitIsType(currentTargetID, cUnitTypeHumanSoldier) == true)
        {
            continue;
        }
        
        float radius = 20.0;
        if (kbUnitIsType(attBuildingID, cUnitTypeAbstractFortress) == true)
        {
            if (cMyCulture == cCultureNorse)
                radius = radius - 2;
        }
        else if (kbUnitIsType(attBuildingID, cUnitTypeAbstractSettlement) == true)
        {
            if (kbGetTechStatus(cTechFortifyTownCenter) > cTechStatusResearching)
                radius = radius + 2;
        }
        
        vector buildingPosition = kbUnitGetPosition(attBuildingID);
        int numEnemyHumanSoldiersInR = getNumUnitsByRel(cUnitTypeHumanSoldier, cUnitStateAlive, -1, cPlayerRelationEnemy, buildingPosition, radius, true);
        int numEnemyVillagersInR = getNumUnitsByRel(cUnitTypeAbstractVillager, cUnitStateAlive, -1, cPlayerRelationEnemy, buildingPosition, radius, true);
        
        if (numEnemyHumanSoldiersInR < 1)
        {
            if (numEnemyVillagersInR > 0)
            {
                int enemyVillagerUnitID = findUnitByRel(cUnitTypeAbstractVillager, cUnitStateAlive, -1, cPlayerRelationEnemy, buildingPosition, radius, true);
                if (enemyVillagerUnitID != -1)
                {
                    aiTaskUnitWork(attBuildingID, enemyVillagerUnitID);
                    continue;
                }
            }
        }
        else
        {
            int enemyHumanSoldierID = findUnitByRel(cUnitTypeHumanSoldier, cUnitStateAlive, -1, cPlayerRelationEnemy, buildingPosition, radius, true);
            if (enemyHumanSoldierID != -1)
            {
                aiTaskUnitWork(attBuildingID, enemyHumanSoldierID);
                continue;
            }
        }
    }   
}



//==============================================================================
rule tacticalTitan
    minInterval 11 //starts in cAge5, activated in repairTitanGate
    inactive
{
    if (ShowAiEcho == true) aiEcho("tacticalTitan:");
    
    static bool titanCreated = false;
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    if (titanCreated == false)
    {
        if (numTitans > 0)
        {
            titanCreated = true;
        }
        else
        {
            return;
        }
    }    
    
    int titanID = findUnit(cUnitTypeAbstractTitan);
    if (titanID == -1)
    {
        xsDisableSelf();
        return;
    }
    
    vector titanPosition = kbUnitGetPosition(titanID);
    int myMilUnitsInR20 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, titanPosition, 20.0);
    int numAttEnemyMilUnitsInR10 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 10.0, true);
    
    int currentTargetID = kbUnitGetTargetUnitID(titanID);
    
    int planID = kbUnitGetPlanID(titanID);
    vector defPlanDefPoint = aiPlanGetVariableVector(planID, cDefendPlanDefendPoint, 0);
    if (equal(defPlanDefPoint, cInvalidVector) == false)
    {
        float defPlanEngageRange = aiPlanGetVariableFloat(planID, cDefendPlanEngageRange, 0);
        float distanceToDefPoint = xsVectorLength(titanPosition - defPlanDefPoint);
        if (distanceToDefPoint > defPlanEngageRange - 1.0)
        {
            float minDistance = 5.0 + distanceToDefPoint - defPlanEngageRange;
            if (minDistance < 10.0)
                minDistance = 10.0;
            float multiplier = minDistance / distanceToDefPoint;
            vector directionalVector = titanPosition - defPlanDefPoint;
            vector desiredPosition = titanPosition - directionalVector * multiplier;
            
            if ((numAttEnemyMilUnitsInR10 < 5) || (myMilUnitsInR20 < 5))
            {
                aiTaskUnitMove(titanID, desiredPosition);
                return;
            }
        }
    }
    else
    {
        int attPlanTargetID = aiPlanGetVariableInt(planID, cAttackPlanSpecificTargetID, 0);
        if ((attPlanTargetID != -1) && (aiPlanGetState(planID) == cPlanStateAttack))
        {
            if ((kbUnitIsType(currentTargetID, cUnitTypeAbstractVillager) == true)
             || (kbUnitIsType(currentTargetID, cUnitTypeAbstractTradeUnit) == true))
            {
                aiTaskUnitWork(titanID, attPlanTargetID);
                return;
            }
        }
    }
    
    if ((kbUnitIsType(currentTargetID, cUnitTypeHumanSoldier) == true)
     || (kbUnitIsType(currentTargetID, cUnitTypeLogicalTypeMythUnitNotTitan) == true)
     || (kbUnitIsType(currentTargetID, cUnitTypeAbstractTitan) == true)
     || (kbUnitIsType(currentTargetID, cUnitTypeBuildingsThatShoot) == true))
    {
        return;
    }
    
    int numAttEnemyHumanSoldiersInR8 = getNumUnitsByRel(cUnitTypeHumanSoldier, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 8.0, true);
    int numAttEnemyArchersInR20 = getNumUnitsByRel(cUnitTypeAbstractArcher, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 20.0, true);
    int numEnemyMythUnitsInR8 = getNumUnitsByRel(cUnitTypeLogicalTypeMythUnitNotTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, titanPosition, 8.0, true);

    if (numAttEnemyHumanSoldiersInR8 < 4)
    {
        if (numEnemyMythUnitsInR8 > 0)
        {
            int enemyMythUnitID = findUnitByRelByIndex(cUnitTypeLogicalTypeMythUnitNotTitan, 0, cUnitStateAlive, -1, cPlayerRelationEnemy, titanPosition, 8.0, true);
            if (enemyMythUnitID != -1)
            {
                aiTaskUnitWork(titanID, enemyMythUnitID);
                return;
            }
        }
        else if (numAttEnemyArchersInR20 > 4)
        {
            int attEnemyArcherID = findUnitByRelByIndex(cUnitTypeAbstractArcher, 0, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 20.0, true);
            if (attEnemyArcherID != -1)
            {
                aiTaskUnitWork(titanID, attEnemyArcherID);
                return;
            }
        }
    }
    else
    {
        int attEnemyHumanSoldierID = findUnitByRelByIndex(cUnitTypeHumanSoldier, 0, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 8.0, true);
        if (attEnemyHumanSoldierID != -1)
        {
            aiTaskUnitWork(titanID, attEnemyHumanSoldierID);
            return;
        }
    }
}

//==============================================================================
rule baseAttackTracker
    minInterval 13 //starts in cAge2
    inactive
{
    
    if (ShowAiEcho == true) aiEcho("baseAttackTracker:");

    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    static int lastBaseID = -1;
    bool townDefenseGPActivated = false;
    bool BUADefPlanActivated = false;

    for (i = 0; < numSettlements)
    {
        int otherBaseUnitID = findUnitByIndex(cUnitTypeAbstractSettlement, i, cUnitStateAlive);
        if (otherBaseUnitID < 0)
            continue;
        else
        {
            //Get the base ID
            int otherBaseID = kbUnitGetBaseID(otherBaseUnitID);
            if (otherBaseID == -1)
                continue;

            vector otherBaseLocation = kbBaseGetLocation(cMyID, otherBaseID);
            float distanceToMainBase = xsVectorLength(mainBaseLocation - otherBaseLocation);
            int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, otherBaseLocation, 50.0, true);
            int enemyMilUnitsInR45 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, otherBaseLocation, 45.0, true);
            int myMilUnitsInR45 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, otherBaseLocation, 45.0, true);
            //Get the time under attack.
            int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, otherBaseID);
            if ((secondsUnderAttack > 15) || ((secondsUnderAttack > 0) && (enemyMilUnitsInR50 > 9)))
            {
                if (ShowAiEcho == true) aiEcho("baseID for attack tracking is "+otherBaseID);	
                if (ShowAiEcho == true) aiEcho("secondsUnderAttack: "+secondsUnderAttack+" for base ID: "+otherBaseID);
                if (ShowAiEcho == true) aiEcho("enemyMilUnitsInR50: "+enemyMilUnitsInR50);
                if (ShowAiEcho == true) aiEcho("enemyMilUnitsInR45: "+enemyMilUnitsInR45);
                if (ShowAiEcho == true) aiEcho("myMilUnitsInR45: "+myMilUnitsInR45);
                if (ShowAiEcho == true) aiEcho("distanceToMainBase: "+distanceToMainBase);
                
                //Try to use a god power to help us.
                if (secondsUnderAttack > 30)
                {
                    if (townDefenseGPActivated == false)
                    {
                        if (gTownDefenseGodPowerPlanID != -1)
                        {
                            if (otherBaseID == lastBaseID)
                            {
                                //skip it once
                                lastBaseID = -1;
                            }
                            else
                            {
                                //release previous GP plan
                                releaseTownDefenseGP();
                            }
                        }
                    
                        if (gTownDefenseGodPowerPlanID == -1)
                        {
                            //if there is no gTownDefenseGodPowerPlanID, find one
                            findTownDefenseGP(otherBaseID);
                            if (gTownDefenseGodPowerPlanID != -1)
                            {
                                townDefenseGPActivated = true;
                                //save the lastBaseID
                                lastBaseID = otherBaseID;
                            }
                        }
                    }
                }
                
                if (otherBaseID != mainBaseID)
                {
                    if (myMilUnitsInR45 < enemyMilUnitsInR45)
                    {
                        //Try to train a military unit there
                        taskMilUnitTrainAtBase(otherBaseID);
                    }
                }
                
                //if it's not our main base, create a defend plan
                if ((otherBaseID != mainBaseID) && (distanceToMainBase > 60.0) && (BUADefPlanActivated == false)
                 && ((equal(aiPlanGetVariableVector(gBaseUnderAttackDefPlanID, cDefendPlanDefendPoint, 0), gBaseUnderAttackLocation) == false)
                  || (gBaseUnderAttackDefPlanID == -1)))
                {
                    xsSetRuleMinInterval("defendBaseUnderAttack", 1);
                    xsDisableRule("defendBaseUnderAttack");
                    aiPlanDestroy(gBaseUnderAttackDefPlanID);
                    gBaseUnderAttackDefPlanID = -1;
                    if (ShowAiEcho == true) aiEcho("destroying gBaseUnderAttackDefPlanID");
                    gBaseUnderAttackLocation = otherBaseLocation;
                    gBaseUnderAttackID = otherBaseID;
                    xsEnableRule("defendBaseUnderAttack");
        
                    aiPlanDestroy(gDefendPlanID);
                    gDefendPlanID = -1;
                    xsDisableRule("defendPlanRule");
                    if (ShowAiEcho == true) aiEcho("destroying current gDefendPlanID and restarting defendPlanRule");
                    xsSetRuleMinInterval("defendPlanRule", 2);
                    xsEnableRule("defendPlanRule");
        
                    if (ShowAiEcho == true) aiEcho("otherBaseID != mainBaseID and distanceToMainBase > 60.0, enabling defendBaseUnderAttack rule");
                    BUADefPlanActivated = true;
                }
                else
                {
                    if (BUADefPlanActivated == true)
                        if (ShowAiEcho == true) aiEcho("BUADefPlanActivated = true, can't activate another one");
                    else
                        if (ShowAiEcho == true) aiEcho("Don't need a defend plan for otherBaseID: "+otherBaseID);
                }
            }
        }
    }
}
//==============================================================================