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
    //aiEcho("*_*_*_*_*_*_");
    aiEcho("* monitorDefPlans:");

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
        int numMilUnitsInMBDefPlan2 = aiPlanGetNumberUnits(gMBDefPlan2ID, cUnitTypeLogicalTypeLandMilitary);
        int numMilUnitsInMBDefPlans = numMilUnitsInMBDefPlan1 + numMilUnitsInMBDefPlan2;
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
            
            //aiEcho("------------");
            
            int numMilUnitsInDefPlan = aiPlanGetNumberUnits(defendPlanID, cUnitTypeLogicalTypeLandMilitary);
            
            vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
            //aiEcho("defPlanDefPoint: "+defPlanDefPoint);
            int mySettlementsAtDefPoint = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID, defPlanDefPoint, 15.0);
            float distToMainBase = xsVectorLength(mainBaseLocation - defPlanDefPoint);
            //aiEcho("distToMainBase: "+distToMainBase);
            
//            int militaryUnitType = cUnitTypeLogicalTypeLandMilitary;
            int militaryUnitType = cUnitTypeMilitary;
            
//            int enemyUnitsInR10 = getNumUnitsByRel(cUnitTypeUnit, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 10.0, true);
            int enemyBuilderInR10 = getNumUnitsByRel(cUnitTypeAbstractVillager, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 10.0, true);    //includes norse villagers and dwarves, but shouldn't be a problem
            enemyBuilderInR10 = enemyBuilderInR10 + getNumUnitsByRel(cUnitTypeThrowingAxeman, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 10.0, true);
            enemyBuilderInR10 = enemyBuilderInR10 + getNumUnitsByRel(cUnitTypeUlfsark, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 10.0, true);
            enemyBuilderInR10 = enemyBuilderInR10 + getNumUnitsByRel(cUnitTypeHuskarl, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 10.0, true);
            enemyBuilderInR10 = enemyBuilderInR10 + getNumUnitsByRel(cUnitTypeHeroNorse, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 10.0, true);
            enemyBuilderInR10 = enemyBuilderInR10 + getNumUnitsByRel(cUnitTypeHeroRagnorok, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 10.0, true);
            
            int enemyMilUnitsInR35 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
            int enemyMilUnitsInR40 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 40.0, true);
            int enemyMilUnitsInR45 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 45.0, true);
            int enemyMilUnitsInR50 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int enemyMilUnitsInR55 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 55.0, true);
//            int enemyMilUnitsInR60 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 60.0, true);
            int enemyMilUnitsInR65 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 65.0, true);
//            int enemyMilUnitsInR70 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 70.0, true);
            int enemyMilUnitsInR75 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 75.0, true);
            int enemyMilUnitsInR80 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 80.0, true);
            int enemyMilUnitsInR85 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 85.0, true);
//            int enemyMilUnitsInR90 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 90.0, true);
            int enemyMilUnitsInR95 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 95.0, true);
//            int enemyMilUnitsInR100 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 100.0, true);
            
            int numAttEnemyMilUnitsInR25 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 25.0, true);
            int numAttEnemyMilUnitsInR35 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
//            int numAttEnemyMilUnitsInR40 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 40.0, true);
            int numAttEnemyMilUnitsInR45 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 45.0, true);
//            int numAttEnemyMilUnitsInR50 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int numAttEnemyMilUnitsInR55 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 55.0, true);
//            int numAttEnemyMilUnitsInR60 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 60.0, true);
            int numAttEnemyMilUnitsInR65 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 65.0, true);
//            int numAttEnemyMilUnitsInR70 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 70.0, true);
            int numAttEnemyMilUnitsInR75 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 75.0, true);
            int numAttEnemyMilUnitsInR80 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 80.0, true);
            int numAttEnemyMilUnitsInR85 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 85.0, true);
//            int numAttEnemyMilUnitsInR90 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 90.0, true);
            int numAttEnemySiegeInR25 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 25.0, true);
            int numAttEnemySiegeInR35 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
//            int numAttEnemySiegeInR40 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 40.0, true);
            int numAttEnemySiegeInR45 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 45.0, true);
//            int numAttEnemySiegeInR50 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int numAttEnemySiegeInR55 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 55.0, true);
            
            int numAttEnemyTitansInR50 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            
            int enemyMilBuildingsInR25 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, defPlanDefPoint, 25.0, true);
            int enemyMilBuildingsInR35 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
            int enemyMilBuildingsInR45 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, defPlanDefPoint, 45.0, true);
            int enemyMilBuildingsInR55 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, defPlanDefPoint, 55.0, true);
            int enemyMilBuildingsInR65 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, defPlanDefPoint, 65.0, true);
            int enemyMilBuildingsInR75 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, defPlanDefPoint, 75.0, true);
            int enemyMilBuildingsInR85 = getNumUnitsByRel(cUnitTypeMilitaryBuilding, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, defPlanDefPoint, 85.0, true);
            
            int enemyMilBuildingsThatShootInR25 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 25.0, true);
            int enemyMilBuildingsThatShootInR35 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
            int enemyMilBuildingsThatShootInR45 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 45.0, true);
            int enemyMilBuildingsThatShootInR55 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 55.0, true);
            int enemyMilBuildingsThatShootInR65 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 65.0, true);
            int enemyMilBuildingsThatShootInR75 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 75.0, true);
            int enemyMilBuildingsThatShootInR85 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 85.0, true);
            
            enemyMilBuildingsInR25 = enemyMilBuildingsInR25 - enemyMilBuildingsThatShootInR25;
            enemyMilBuildingsInR35 = enemyMilBuildingsInR35 - enemyMilBuildingsThatShootInR35;
            enemyMilBuildingsInR45 = enemyMilBuildingsInR45 - enemyMilBuildingsThatShootInR45;
            enemyMilBuildingsInR55 = enemyMilBuildingsInR55 - enemyMilBuildingsThatShootInR55;
            enemyMilBuildingsInR65 = enemyMilBuildingsInR65 - enemyMilBuildingsThatShootInR65;
            enemyMilBuildingsInR75 = enemyMilBuildingsInR75 - enemyMilBuildingsThatShootInR75;
            enemyMilBuildingsInR85 = enemyMilBuildingsInR85 - enemyMilBuildingsThatShootInR85;
            
//            int requiredUnits = enemyMilUnitsInR90;
            int requiredUnits = enemyMilUnitsInR85;
            
/* TODO: maybe include them in order to check the player's units in range 
            int myMilUnitsInR35 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 35.0);
            int myMilUnitsInR45 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 45.0);
            int myMilUnitsInR55 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 55.0);
//            int myMilUnitsInR65 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 65.0);
*/
            
            int defPlanBaseID = aiPlanGetBaseID(defendPlanID);
            int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, defPlanBaseID);
            //aiEcho("secondsUnderAttack: "+secondsUnderAttack);

            if (((defendPlanID == gDefendPlanID) && (defPlanBaseID == mainBaseID)) || (defendPlanID == gMBDefPlan1ID) || (defendPlanID == gMBDefPlan2ID))
            {
/*
                if (defendPlanID == gDefendPlanID)
                    aiEcho("defendPlanID == gDefendPlanID");
                else if (defendPlanID == gMBDefPlan1ID)
                    aiEcho("defendPlanID == gMBDefPlan1ID");
                else if (defendPlanID == gMBDefPlan2ID)
                    aiEcho("defendPlanID == gMBDefPlan2ID");
*/                

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
                        aiPlanSetDesiredPriority(defendPlanID, 54);
                    else
                    {
                        if (kbGetAge() > cAge3)
//                            aiPlanSetDesiredPriority(defendPlanID, 39); //TODO: find the best value
                            aiPlanSetDesiredPriority(defendPlanID, 38); //TODO: find the best value
                        else
                            aiPlanSetDesiredPriority(defendPlanID, 40);
                    }
                    
                    //override if there is an enemy Titan near our main base
                    if (numEnemyTitansNearMBInR80 > 0)
                        aiPlanSetDesiredPriority(defendPlanID, 60);
                }
                else if (defendPlanID == gMBDefPlan2ID)
                {
                    static int countZ = 0;
//                    if (numAttEnemyMilUnitsInR60 > 10)
                    if (numAttEnemyMilUnitsInR65 > 10)
                    {
                        if ((aiPlanGetBaseID(gDefendPlanID) != mainBaseID) && (countZ > 0))
                        {
                            aiPlanDestroy(gDefendPlanID);
                            gDefendPlanID = -1;
                            xsDisableRule("defendPlanRule");
                            //aiEcho("*********************************");
                            //aiEcho("destroying current gDefendPlanID and restarting defendPlanRule as there are too many enemies near our main base");
                            //aiEcho("*********************************");
                            
                            xsSetRuleMinInterval("defendPlanRule", 8);
                            xsEnableRule("defendPlanRule");
                            countZ = 0;
                        }
                        else
                            countZ = countZ + 1;
                    }
                    else
                        countZ = 0;
                    
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
                        aiPlanSetDesiredPriority(defendPlanID, 54);
                    else
                    {
                        if (kbGetAge() > cAge3)
                            aiPlanSetDesiredPriority(defendPlanID, 29); //TODO: find the best value
                        else
                            aiPlanSetDesiredPriority(defendPlanID, 30);
                    }
                    
                    //override if there is an enemy Titan near our main base
                    if (numEnemyTitansNearMBInR80 > 0)
                        aiPlanSetDesiredPriority(defendPlanID, 60);
                }
                
                if (((numMilUnitsInMBDefPlans >= enemyMilUnitsInR95) && (numAttEnemyMilUnitsInR75 < 3))
                 && ((numAttEnemyMilUnitsInR85 - numAttEnemyMilUnitsInR75 > 0) || (enemyMilBuildingsInR85 - enemyMilBuildingsInR75 > 0)))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 85.0);
                }
                else if (((numMilUnitsInMBDefPlans >= enemyMilUnitsInR85) && (numAttEnemyMilUnitsInR65 < 3))
                      && ((numAttEnemyMilUnitsInR75 - numAttEnemyMilUnitsInR65 > 0) || (enemyMilBuildingsInR75 - enemyMilBuildingsInR65 > 0)))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 75.0);
                }
                else if (((numMilUnitsInMBDefPlans >= enemyMilUnitsInR75) && (numAttEnemyMilUnitsInR55 < 3))
                      && ((numAttEnemyMilUnitsInR65 - numAttEnemyMilUnitsInR55 > 0) || (enemyMilBuildingsInR65 - enemyMilBuildingsInR55 > 0)))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 65.0);
                }
                else if (((numMilUnitsInMBDefPlans >= enemyMilUnitsInR65) && (numAttEnemyMilUnitsInR45 < 3))
                      && ((numAttEnemyMilUnitsInR55 - numAttEnemyMilUnitsInR45 > 0) || (enemyMilBuildingsInR55 - enemyMilBuildingsInR45 > 0)))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 55.0);
                }
                else if (((numMilUnitsInMBDefPlans >= enemyMilUnitsInR55) && (numAttEnemyMilUnitsInR35 < 3))
                      && ((numAttEnemyMilUnitsInR45 - numAttEnemyMilUnitsInR35 > 0) || (enemyMilBuildingsInR45 - enemyMilBuildingsInR35 > 0)))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 45.0);
                }
                else if (((numMilUnitsInMBDefPlans >= enemyMilUnitsInR45) && (numAttEnemyMilUnitsInR25 < 3))
                      && ((numAttEnemyMilUnitsInR35 - numAttEnemyMilUnitsInR25 > 0) || (enemyMilBuildingsInR35 - enemyMilBuildingsInR25 > 0)))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 35.0);
                }
                else
                {
//                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 25.0);
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 34.0);  //just a little less, keepUnitsWithinRange will pull them farther back
                }
                
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
                //aiEcho("------------");
                continue;
            }
            else if ((defendPlanID == gOtherBase1DefPlanID) || (defendPlanID == gOtherBase2DefPlanID)
                  || (defendPlanID == gOtherBase3DefPlanID) || (defendPlanID == gOtherBase4DefPlanID)
                  || ((defendPlanID == gDefendPlanID) && (defPlanBaseID != mainBaseID)))
            {
/*
                if (defendPlanID == gOtherBase1DefPlanID)
                    aiEcho("defendPlanID == gOtherBase1DefPlanID");
                else if (defendPlanID == gOtherBase2DefPlanID)
                    aiEcho("defendPlanID == gOtherBase2DefPlanID");
                else if (defendPlanID == gOtherBase3DefPlanID)
                    aiEcho("defendPlanID == gOtherBase3DefPlanID");
                else if (defendPlanID == gOtherBase4DefPlanID)
                    aiEcho("defendPlanID == gOtherBase4DefPlanID");
                else if ((defendPlanID == gDefendPlanID) && (defPlanBaseID != mainBaseID))
                    aiEcho("defendPlanID == gDefendPlanID and defPlanBaseID != mainBaseID");
*/

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
                
                if ((numAttEnemyMilUnitsInR45 < 3) && (numMilUnitsInDefPlan > enemyMilUnitsInR65)
                 && (numAttEnemyMilUnitsInR55 - numAttEnemyMilUnitsInR45 > 0))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 55.0);
                }
                else if ((numAttEnemyMilUnitsInR35 < 3) && ((numAttEnemySiegeInR45 - numAttEnemySiegeInR35 > 0)
                       || ((numMilUnitsInDefPlan >= enemyMilUnitsInR55) && ((numAttEnemyMilUnitsInR45 - numAttEnemyMilUnitsInR35 > 0) || (enemyMilBuildingsInR45 - enemyMilBuildingsInR35 > 0)))))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 45.0);
                }
                else if ((numAttEnemyMilUnitsInR25 < 3) && ((numAttEnemySiegeInR35 - numAttEnemySiegeInR25 > 0)
                       || ((numMilUnitsInDefPlan >= enemyMilUnitsInR45 - 1) && ((numAttEnemyMilUnitsInR35 - numAttEnemyMilUnitsInR25 > 0) || (enemyMilBuildingsInR35 - enemyMilBuildingsInR25 > 0)))))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 35.0);
                }
                else
                {
//                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 25.0);
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 34.0);  //just a little less, keepUnitsWithinRange will pull them farther back
                }
                
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
                    
                if (defendPlanID != gDefendPlanID)
                {
//                    if (secondsUnderAttack > 0)
                    if ((secondsUnderAttack > 0) || (numMilUnitsInDefPlan < enemyMilUnitsInR45))
                    {
//                        aiPlanSetDesiredPriority(defendPlanID, 55);
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
                //aiEcho("------------");
                continue;
            }
            else if (defendPlanID == gSettlementPosDefPlanID)
            {
                //aiEcho("mySettlementsAtDefPoint: "+mySettlementsAtDefPoint);
                
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
                
                if ((enemyBuilderInR10 < 1) && (numAttEnemyMilUnitsInR45 < 3) && (numMilUnitsInDefPlan > enemyMilUnitsInR65)
                 && (numAttEnemyMilUnitsInR55 - numAttEnemyMilUnitsInR45 > 0))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 55.0);
                    aiPlanSetNumberVariableValues(defendPlanID, cDefendPlanAttackTypeID, 1, true);
                    aiPlanSetVariableInt(defendPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
                }
                else if ((enemyBuilderInR10 < 1) && (numAttEnemyMilUnitsInR35 < 3) && ((numAttEnemySiegeInR45 - numAttEnemySiegeInR35 > 0)
                       || ((numMilUnitsInDefPlan >= enemyMilUnitsInR55) && (numAttEnemyMilUnitsInR45 - numAttEnemyMilUnitsInR35 > 0))))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 45.0);
                    aiPlanSetNumberVariableValues(defendPlanID, cDefendPlanAttackTypeID, 1, true);
                    aiPlanSetVariableInt(defendPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
                }
                else if ((enemyBuilderInR10 < 1) && (numAttEnemyMilUnitsInR25 < 3) && ((numAttEnemySiegeInR35 - numAttEnemySiegeInR25 > 0)
                       || ((numMilUnitsInDefPlan >= enemyMilUnitsInR45 - 1) && (numAttEnemyMilUnitsInR35 - numAttEnemyMilUnitsInR25 > 0))))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 35.0);
                    aiPlanSetNumberVariableValues(defendPlanID, cDefendPlanAttackTypeID, 1, true);
                    aiPlanSetVariableInt(defendPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
                }
                else
                {
//                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 25.0);
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 34.0);  //just a little less, keepUnitsWithinRange will pull them farther back
                    aiPlanSetNumberVariableValues(defendPlanID, cDefendPlanAttackTypeID, 2, true);
                    aiPlanSetVariableInt(defendPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeAbstractVillager);
                    aiPlanSetVariableInt(defendPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitary);
                }
                
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
                    
                int priorityA = 48;
                if (distToMainBase > 90.0)
                    priorityA = 52;
                static int countA = 0;
                static int resourceCountA = 0;
                if ((enemyMilUnitsInR50 < 4) && (numAttEnemySiegeInR45 < 1) && (numAttEnemyTitansInR50 < 1))
                {
                    if (countA <= 14)
                    {
                        if (distToMainBase < 85.0)
                            aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 7, 19, 19);
                        else
                        {
                            if (distToMainBase > 100.0)
                                aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 11, 24, 24);
                            else
                                aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 9, 22, 22);
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
                        //aiEcho("------------");
                        continue;
                    }
                    else
                    {
                        countA = 0;
                        xsSetRuleMinInterval("defendSettlementPosition", 10);
                        xsDisableRule("defendSettlementPosition");
                        aiPlanDestroy(defendPlanID);
                        //aiEcho("--__-- destroying gSettlementPosDefPlan as countA >= 15");
                        //aiEcho("------------");
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
                            xsSetRuleMinInterval("defendSettlementPosition", 10);
                            xsDisableRule("defendSettlementPosition");
                            aiPlanDestroy(defendPlanID);
                            //aiEcho("--__-- destroying gSettlementPosDefPlan as resourceCountA >= 2");
                            //aiEcho("------------");
                            continue;
                        }
                    }
                    else
                        resourceCountA = 0;
                    countA = 0;
                    aiPlanSetDesiredPriority(defendPlanID, priorityA);
                    //aiEcho("------------");
                    continue;
                }
            }
            else if (defendPlanID == gBaseUnderAttackDefPlanID)
            {
                //aiEcho("mySettlementsAtDefPoint: "+mySettlementsAtDefPoint);
                
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
                
                if ((numAttEnemyMilUnitsInR45 < 5) && (numMilUnitsInDefPlan > enemyMilUnitsInR65) && (numAttEnemyMilUnitsInR55 - numAttEnemyMilUnitsInR45 > 0))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 55.0);
                }
                else if ((numAttEnemyMilUnitsInR35 < 6) && ((numAttEnemySiegeInR45 - numAttEnemySiegeInR35 > 0)
                       || ((numMilUnitsInDefPlan >= enemyMilUnitsInR55) && ((numAttEnemyMilUnitsInR45 - numAttEnemyMilUnitsInR35 > 0) || (enemyMilBuildingsInR45 - enemyMilBuildingsInR35 > 0)))))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 45.0);
                }
                else if ((numAttEnemyMilUnitsInR25 < 6) && ((numAttEnemySiegeInR35 - numAttEnemySiegeInR25 > 0)
                       || ((numMilUnitsInDefPlan >= enemyMilUnitsInR45 - 1) && ((numAttEnemyMilUnitsInR35 - numAttEnemyMilUnitsInR25 > 0) || (enemyMilBuildingsInR35 - enemyMilBuildingsInR25 > 0)))))
                {
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 35.0);
                }
                else
                {
//                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 25.0);
                    aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 34.0);  //just a little less, keepUnitsWithinRange will pull them farther back
                }
                
                keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
                    
//                int priorityB = 49;
                int priorityB = 53;
//                if (distToMainBase > 90.0)
//                    priorityB = 53;
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
                        //aiEcho("------------");
                        continue;
                    }
                    else
                    {
                        countB = 0;
                        xsSetRuleMinInterval("defendBaseUnderAttack", 7);
                        xsDisableRule("defendBaseUnderAttack");
                        aiPlanDestroy(defendPlanID);
                        //aiEcho("--__-- destroying gBaseUnderAttackDefPlanID as countB >= 8");
                        //aiEcho("------------");
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
                            xsSetRuleMinInterval("defendBaseUnderAttack", 7);
                            xsDisableRule("defendBaseUnderAttack");
                            aiPlanDestroy(defendPlanID);
                            //aiEcho("--__-- destroying gBaseUnderAttackDefPlanID as resourceCountB >= 2");
                            
                            aiPlanDestroy(gDefendPlanID);
                            gDefendPlanID = -1;
                            xsDisableRule("defendPlanRule");
                            //aiEcho("destroying current gDefendPlanID and restarting defendPlanRule");
                            gBaseUnderAttackID = -1;
                            
                            xsSetRuleMinInterval("defendPlanRule", 8);
                            xsEnableRule("defendPlanRule");
                            //aiEcho("------------");
                            continue;
                        }
                    }
                    else
                        resourceCountB = 0;
                    countB = 0;
                    aiPlanSetDesiredPriority(defendPlanID, priorityB);
                    //aiEcho("------------");
                    continue;
                }
            }
        }
    }
}

//==============================================================================
rule monitorAttPlans
    minInterval 15 //starts in cAge2
    inactive
{
    //aiEcho("________________");
    aiEcho("* monitorAttackPlans:");
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int numEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numAttEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numEnemyMilUnitsNearMBInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 70.0, true);
    int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numAttEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);

    vector defPlanBaseLocation = cInvalidVector;
//    int numEnemyMilUnitsNearDefBInR60 = 0;
    int numEnemyMilUnitsNearDefBInR50 = 0;
    int numAttEnemyMilUnitsNearDefBInR50 = 0;
    int numEnemyMilUnitsNearDefBInR40 = 0;
//    int numEnemyTitansNearDefBInR60 = 0;
    int numEnemyTitansNearDefBInR55 = 0;
    int numAttEnemyTitansNearDefBInR55 = 0;
    int numAttEnemySiegeNearDefBInR50 = 0;

    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
//            numEnemyMilUnitsNearDefBInR60 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 60.0, true);
            numEnemyMilUnitsNearDefBInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 50.0, true);
            numAttEnemyMilUnitsNearDefBInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 50.0, true);
            numEnemyMilUnitsNearDefBInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 40.0, true);
//            numEnemyTitansNearDefBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 60.0, true);
            numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
            numAttEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
            numAttEnemySiegeNearDefBInR50 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 50.0, true);
        }
    }
    
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();
    
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
            int numMilUnitsNearAttPlan = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, attPlanPosition, 30.0);
            int numAlliedMilUnitsNearAttPlan = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, attPlanPosition, 30.0, true);
            int numEnemyMilUnitsNearAttPlan = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, attPlanPosition, 30.0, true);
            int numEnemyBuildingsThatShootNearAttPlanInR25 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, attPlanPosition, 25.0, true);
            
            int numMythInPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
            int numSiegeInPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeAbstractSiegeWeapon);
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
                //aiEcho("attackPlanID == gEnemySettlementAttPlanID");
                
                if (killSettlementAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killSettlementAttPlanCount = -1;
                    }
                    else
                    {
//                        if ((aiPlanGetNoMoreUnits(attackPlanID) == true) || (numEnemyTitansNearMBInR85 > 0))
                        if ((aiPlanGetNoMoreUnits(attackPlanID) == true) || (numAttEnemyTitansNearMBInR85 > 0))
                        {
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
                            if ((killSettlementAttPlanCount >= 4) || (attPlanDistance < 25.0))
                            {
                                aiPlanDestroy(attackPlanID);
                                gEnemySettlementAttPlanTargetUnitID = -1;
                                killSettlementAttPlanCount = -1;
                                continue;
                            }
                            killSettlementAttPlanCount = killSettlementAttPlanCount + 1;
                            continue;
                        }
                        else
                        {
                            killSettlementAttPlanCount = -1;
                            aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        }
                    }
                }
                

//                if (numEnemyTitansNearMBInR85 > 0)
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
                        aiPlanSetUnitStance(attackPlanID, cUnitStancePassive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killSettlementAttPlanCount = 0;
                    }
                    //aiEcho("destroying gEnemySettlementAttPlanID as there's an enemy Titan near our main base");
                    continue;
                }
                
                if ((kbUnitGetCurrentHitpoints(gEnemySettlementAttPlanTargetUnitID) <= 0) && (gEnemySettlementAttPlanTargetUnitID != -1))
                {
                    if (countA == -1)
                    {
                        aiPlanDestroy(attackPlanID);
                        gEnemySettlementAttPlanTargetUnitID = -1;
                        aiEcho("destroying gEnemySettlementAttPlanID as the target has been destroyed");
                        countA = 0;
                        continue;
                    }
                    
                    if (gSettlementPosDefPlanID > 0)
                    {
                        xsSetRuleMinInterval("defendSettlementPosition", 10);
                        xsDisableRule("defendSettlementPosition");
                        aiPlanDestroy(gSettlementPosDefPlanID);
                        //aiEcho("destroying last gSettlementPosDefPlan as we have a new defend position");
                    }
                    gSettlementPosDefPlanDefPoint = gEnemySettlementAttPlanLastAttPoint;
                    xsEnableRule("defendSettlementPosition");
                    countA = -1;
                    continue;
                }
                
                if (planState < cPlanStateAttack)
                {
                    //aiEcho("numEnemyMilUnitsNearMBInR100: "+numEnemyMilUnitsNearMBInR100);
                    //aiEcho("numEnemyMilUnitsNearDefBInR50: "+numEnemyMilUnitsNearDefBInR50);
//                    if ((numEnemyMilUnitsNearMBInR100 > 10) || (numEnemyMilUnitsNearDefBInR50 > 6)
//                    if ((numEnemyMilUnitsNearMBInR85 > 10) || (numEnemyMilUnitsNearDefBInR50 > 6)
//                     || ((numAttEnemySiegeNearDefBInR50 > 0) && (numEnemyMilUnitsNearDefBInR40 > 3)))
                    if ((numAttEnemyMilUnitsNearMBInR85 > 10) || (numEnemyMilUnitsNearMBInR70 > 14)
                     || (numAttEnemyMilUnitsNearDefBInR50 > 6) || (numEnemyMilUnitsNearDefBInR40 > 10)
                     || ((numAttEnemySiegeNearDefBInR50 > 0) && (numEnemyMilUnitsNearDefBInR40 > 3)))
                    {
                        countA = 0;
                        if ((numEnemyMilUnitsNearMBInR70 > 14) || (numEnemyMilUnitsNearDefBInR40 > 10) && (attPlanPriority < 20))
                        {
                            aiPlanDestroy(attackPlanID);
                            aiEcho("destroying gEnemySettlementAttPlanID as there are too many enemies");
                            continue;
                        }
                        else
                        {
                            aiPlanSetDesiredPriority(attackPlanID, 17);
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
                            aiPlanSetDesiredPriority(attackPlanID, 51);
                        }
                    }
                    
                    // Check to see if the gather phase is taking too long and just launch the attack if so.
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 20*1000))
                    {
//                        if ((numEnemyMilUnitsNearMBInR100 > 10) || (numEnemyMilUnitsNearDefBInR50 > 6))
//                        if ((numEnemyMilUnitsNearMBInR85 > 10) || (numEnemyMilUnitsNearDefBInR50 > 6))
                        if ((numEnemyMilUnitsNearMBInR70 > 10) || (numEnemyMilUnitsNearDefBInR40 > 6))
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, distanceA / 2);
                            countA = 0;
                        }
                        else
                        {
                            if (countA < 0)
                                countA = 0;
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, distanceA + countA * 10);
                            countA = countA + 1;
                            //aiEcho("*** gEnemySettlementAttPlanID gather timed out, increasing gather distance.");
/*
                            if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 3*60*1000))
                            {
                                aiPlanSetVariableBool(attackPlanID, cAttackPlanMoveAttack, 0, false);
                                aiEcho("Setting gEnemySettlementAttPlanID MoveAttack to false");
                            }
*/
                        }
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    countA = 0;
                    if (numTitansInPlan > 0)
                    {
//                        aiPlanSetDesiredPriority(attackPlanID, 85);
                        aiPlanSetDesiredPriority(attackPlanID, 90);
                    }
                    else
                    {
                        float distanceToTarget = xsVectorLength(mainBaseLocation - kbUnitGetPosition(gEnemySettlementAttPlanTargetUnitID));
//                        if ((numMythInPlan < 1) && (numSiegeInPlan < 1) && (currentPop <= currentPopCap - 3))
                        if ((numMythInPlan < 1) && (numSiegeInPlan < 1) && (currentPop <= currentPopCap - 3) && (distanceToTarget > 110.0))
                        {
                            aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                            aiPlanSetUnitStance(attackPlanID, cUnitStancePassive);
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
                            killSettlementAttPlanCount = 0;
                            //aiEcho("Destroying gEnemySettlementAttPlanID as there are no myth units and siege units in the plan");
                        }
                        else if ((numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan) 
                              && (numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && (aiPlanGetNoMoreUnits(attackPlanID) == true)
                              && (currentPop <= currentPopCap * 0.95))
                        {
                            aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                            aiPlanSetUnitStance(attackPlanID, cUnitStancePassive);                            
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
                            killSettlementAttPlanCount = 0; 
                            //aiEcho("Destroying gEnemySettlementAttPlanID as there are too many enemies");
                        }
                    }
                    continue;
                }
            }
            else if (attackPlanID == gRandomAttackPlanID)
            {
                //aiEcho("attackPlanID == gRandomAttackPlanID");
                static int countB = 0;
                float distanceB = 25.0;
                
                if (killRandomAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killRandomAttPlanCount = -1;
                    }
                    else
                    {
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
                
//                if ((numEnemyTitansNearMBInR100 > 0) || (numEnemyTitansNearDefBInR60 > 0) || (numTitansInPlan > 0))
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
                        aiPlanSetUnitStance(attackPlanID, cUnitStancePassive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killRandomAttPlanCount = 0;
                    }
/*                    
                    if (numTitansInPlan > 0)
                        aiEcho("destroying gRandomAttackPlanID as our Titan is in the plan");
                    else
                        aiEcho("destroying gRandomAttackPlanID as there's an enemy Titan near our main base or defBase");
*/                        
                    continue;
                }
                
                if (planState < cPlanStateAttack)
                {
//                    if ((numEnemyMilUnitsNearMBInR100 > 8) || (numEnemyMilUnitsNearDefBInR50 > 6))
                    if ((numEnemyMilUnitsNearMBInR85 > 8) || (numEnemyMilUnitsNearDefBInR50 > 6))
                    {
                        countB = 0;
                        if ((numEnemyMilUnitsNearMBInR70 > 11) || (numEnemyMilUnitsNearDefBInR40 > 9) && (attPlanPriority < 20))
                        {
                            aiPlanDestroy(attackPlanID);
                            aiEcho("destroying gRandomAttackPlanID as there are too many enemies");
                            continue;
                        }
                        else
                        {
                            aiPlanSetDesiredPriority(attackPlanID, 17);
                        }
                    }
                    else
                    {
                        aiPlanSetDesiredPriority(attackPlanID, 50);
                    }
                    
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 20*1000))
                    {
//                        if ((numEnemyMilUnitsNearMBInR100 > 6) || (numEnemyMilUnitsNearDefBInR50 > 6))
                        if ((numEnemyMilUnitsNearMBInR85 > 6) || (numEnemyMilUnitsNearDefBInR50 > 6))
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, distanceB / 2);
                            countB = 0;
                        }
                        else
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, distanceB + countB * 5);
                            countB = countB + 1;
                            //aiEcho("*** gRandomAttackPlanID gather timed out, increasing gather distance.");
/*
                            if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 3*60*1000))
                            {
                                aiPlanSetVariableBool(attackPlanID, cAttackPlanMoveAttack, 0, false);
                                aiEcho("Setting gRandomAttackPlanID MoveAttack to false");
                            }
*/
                        }
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    countB = 0;
//                    if ((numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && ((numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan) 
//                     || ((numEnemyBuildingsThatShootNearAttPlanInR25 > 0) && (numMythInPlan < 1) && (numSiegeInPlan < 1) && (numMilUnitsInPlan < 15))))
                    if ((numMilUnitsInPlan < 3)
                     || ((numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && ((numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan) 
                     || ((numEnemyBuildingsThatShootNearAttPlanInR25 > 0) && (numMythInPlan < 1) && (numSiegeInPlan < 1) && (numMilUnitsInPlan < 15)))))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStancePassive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killRandomAttPlanCount = 0;
                        if (numMilUnitsInPlan < 3)
                            aiEcho("Destroying gRandomAttackPlanID as less than 3 units in the plan");
                        else
                            aiEcho("Destroying gRandomAttackPlanID as there are too many enemies");
                    }
                    continue;
                }
            }
            else if (attackPlanID == gRaidingPartyAttackID)
            {
                //aiEcho("attackPlanID == gRaidingPartyAttackID");
                
                if (killRaidAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killRaidAttPlanCount = -1;
                    }
                    else
                    {
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
                        //aiEcho("Destroying gRaidingPartyAttackID as we have already tried to attack that target");
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
                     || (numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan)))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStancePassive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killRaidAttPlanCount = 0;
                        //aiEcho("Destroying gRaidingPartyAttackID as there are too many enemies");
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
                        if (aiPlanGetVariableBool(attackPlanID, cAttackPlanMoveAttack, 0) == true)
                            aiPlanSetVariableBool(attackPlanID, cAttackPlanMoveAttack, 0, false);
                        if (aiPlanGetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0) != 200.0)
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 200.0);
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 10, 200, 200);
                    aiPlanSetDesiredPriority(attackPlanID, 99);
                        
                    aiPlanDestroy(gDefendPlanID);
                    aiPlanDestroy(gMBDefPlan1ID);
                    aiPlanDestroy(gMBDefPlan2ID);
                    aiPlanDestroy(gOtherBase1DefPlanID);
                    aiPlanDestroy(gOtherBase2DefPlanID);
                    aiPlanDestroy(gOtherBase3DefPlanID);
                    aiPlanDestroy(gOtherBase4DefPlanID);
                    continue;
                }
            }
            else if (attackPlanID == gLandAttackPlanID)
            {
                //aiEcho("attackPlanID == gLandAttackPlanID");
                static int countD = 0;
                float distanceD = 25.0;
                
                if (killLandAttPlanCount != -1)
                {
                    if (planState < cPlanStateAttack)
                    {
                        //this must be a new plan, no need to destroy it!
                        killLandAttPlanCount = -1;
                    }
                    else
                    {
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        if ((killLandAttPlanCount >= 4) || (attPlanDistance < 25.0))
                        {
                            aiPlanDestroy(attackPlanID);
                            killLandAttPlanCount = -1;
                            continue;
                        }
                        killLandAttPlanCount = killLandAttPlanCount + 1;
                        continue;
                    }
                }
                
//                if ((numEnemyTitansNearMBInR100 > 0) || (numEnemyTitansNearDefBInR60 > 0) || ((numMHPlayerSettlements > 0) && (numTitansInPlan > 0)))
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
                        aiPlanSetUnitStance(attackPlanID, cUnitStancePassive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killLandAttPlanCount = 0;
                    }
/*                    
                    if (numTitansInPlan > 0)
                        aiEcho("destroying gLandAttackPlanID as our Titan is in the plan");
                    else
                        aiEcho("destroying gLandAttackPlanID as there's an enemy Titan near our main base or defBase");
*/                  
                    continue;
                }
                
                if (planState < cPlanStateAttack)
                {
//                    if ((numEnemyMilUnitsNearMBInR100 > 10) || (numEnemyMilUnitsNearDefBInR50 > 6))
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
                            if (((numEnemyMilUnitsNearMBInR70 > 14) || (numEnemyMilUnitsNearDefBInR40 > 10)) && (attPlanPriority < 20))
                            {
                                aiPlanDestroy(attackPlanID);
                                aiEcho("destroying gLandAttackPlanID as there are too many enemies");
                                continue;
                            }
                            else
                            {
                                aiPlanSetDesiredPriority(attackPlanID, 17);
                            }
                        }
                    }
                    else
                    {
                        aiPlanSetDesiredPriority(attackPlanID, 50);
                    }
                    
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 20*1000))
                    {
//                        if ((numEnemyMilUnitsNearMBInR100 > 6) || (numEnemyMilUnitsNearDefBInR50 > 6))
                        if ((numEnemyMilUnitsNearMBInR85 > 6) || (numEnemyMilUnitsNearDefBInR50 > 6))
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, distanceD / 2);
                            countD = 0;
                        }
                        else
                        {
                            aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, distanceD + countD * 5);
                            countD = countD + 1;
                            //aiEcho("*** gLandAttackPlanID gather timed out, increasing gather distance.");
                        }
                    }
                    continue;
                }
                else if (planState == cPlanStateAttack)
                {
                    countD = 0;
//                    if ((numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && ((numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan)
//                     || ((numEnemyBuildingsThatShootNearAttPlanInR25 > 0) && (numMythInPlan < 1) && (numSiegeInPlan < 1) && (numMilUnitsInPlan < 15))))
                    if (((kbGetAge() > cAge2) && (numMilUnitsInPlan < 5))
                     || ((numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && ((numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan)
                     || ((numEnemyBuildingsThatShootNearAttPlanInR25 > 0) && (numMythInPlan < 1) && (numSiegeInPlan < 1) && (numMilUnitsInPlan < 15)))))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStancePassive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killLandAttPlanCount = 0;
                        
                        if ((kbGetAge() > cAge2) && (numMilUnitsInPlan < 5))
                            aiEcho("Destroying gLandAttackPlanID as there less than 5 units in the plan");
                        else
                            aiEcho("Destroying gLandAttackPlanID as there are too many enemies");
                    }
                    continue;
                }
            }
        }
    }
}

//==============================================================================
rule defendPlanRule
//    minInterval 15 //starts in cAge2
    minInterval 61 //starts in cAge1
    inactive
{
    aiEcho("defendPlanRule:");
    
    if ((kbGetAge() < cAge2) && (xsGetTime() < 5*60*1000))
        return;
        
    xsSetRuleMinIntervalSelf(61);
    static int defendCount = 0;      // For plan numbering
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
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
                //aiEcho("defendPlanActive = true");
                
                int defPlanBaseID = aiPlanGetBaseID(defendPlanID);
                if (defPlanBaseID != baseToUse)
                {
                    vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                    int enemySettlementsAtDefPlanDefPoint = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 15.0);
                    int motherNatureSettlementsAtDefPlanDefPoint = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, defPlanDefPoint, 15.0);
    
                    if ((numEnemyTitansNearMBInR80 > 0) || (enemySettlementsAtDefPlanDefPoint - motherNatureSettlementsAtDefPlanDefPoint > 0)
                     || ((numAttEnemyMilUnitsNearMBInR80 > 15) && (numAttEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 2.5)))
                    {
                        aiPlanDestroy(defendPlanID);
                        gDefendPlanID = -1;
                        xsSetRuleMinIntervalSelf(11);
                        aiEcho("destroying current gDefendPlanID and restarting defendPlanRule");
                        aiEcho("___");
                        return;
                    }
                }
            }
        }
    } 
    
    //If we already have a gDefendPlan, don't make another one.
    if (defendPlanActive == true)
    {
        //aiEcho("gDefendPlan exists: ID is "+defendPlanID);
        return;
    }
    
    int defPlanID = aiPlanCreate("Defend plan #"+defendCount, cPlanDefend);
    //aiEcho("gDefendPlanID #"+defPlanID);
    if (defPlanID != -1)
    {
        defendCount = defendCount + 1;
   
//        aiPlanSetVariableInt(defPlanID, cDefendPlanRefreshFrequency, 0, 5);
        aiPlanSetVariableInt(defPlanID, cDefendPlanRefreshFrequency, 0, 10);
        aiPlanSetVariableVector(defPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, baseToUse));
            
        if (baseToUse != mainBaseID)
        {
            aiPlanSetVariableFloat(defPlanID, cDefendPlanEngageRange, 0, 40.0);
            aiPlanSetVariableFloat(defPlanID, cDefendPlanGatherDistance, 0, 20.0);
//            aiPlanSetVariableFloat(defPlanID, cDefendPlanGatherDistance, 0, 25.0);
        }
        else
        {
            aiPlanSetVariableFloat(defPlanID, cDefendPlanEngageRange, 0, 50.0);
            aiPlanSetVariableFloat(defPlanID, cDefendPlanGatherDistance, 0, 30.0);
        }
    
        aiPlanSetUnitStance(defPlanID, cUnitStancePassive);
        aiPlanSetVariableBool(defPlanID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(defPlanID, cDefendPlanAttackTypeID, 2, true);
        aiPlanSetVariableInt(defPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(defPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);

        aiPlanAddUnitType(defPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 200, 200);

        aiPlanSetDesiredPriority(defPlanID, 20);    // Way below others
        
        aiPlanSetBaseID(defPlanID, baseToUse);
        
        aiPlanSetActive(defPlanID);
        gDefendPlanID = defPlanID;
    }
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
    inactive
//    minInterval 33 //starts in cAge2
    minInterval 109 //starts in cAge2
{
    aiEcho("activateObeliskClearingPlan:");
        
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
//        aiPlanSetVariableFloat(gObeliskClearingPlanID, cDefendPlanEngageRange, 0, 1000.0);   // Anywhere!
        aiPlanSetVariableFloat(gObeliskClearingPlanID, cDefendPlanEngageRange, 0, 120.0);   //only in close range
        aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanRefreshFrequency, 0, 30);
        aiPlanSetVariableFloat(gObeliskClearingPlanID, cDefendPlanGatherDistance, 0, 50.0);

        aiPlanSetUnitStance(gObeliskClearingPlanID, cUnitStanceDefensive);

        aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeOutpost);

        aiPlanAddUnitType(gObeliskClearingPlanID, cUnitTypeAbstractInfantry, 1, 1, 1);
//        aiPlanSetDesiredPriority(gObeliskClearingPlanID, 58);    // Above normal attack
        aiPlanSetDesiredPriority(gObeliskClearingPlanID, 16);
        aiPlanSetActive(gObeliskClearingPlanID);
    }
}

//==================================================================================
rule decreaseRaxPref    //Egyptian decrease rax units preference if has at least two Migdols
//    minInterval 11 //starts in cAge3
    minInterval 67 //starts in cAge3
    inactive
{  
    aiEcho("decreaseRaxPref:");
    
    int numFortresses=kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAlive);
    if (numFortresses < 2)
        return;

    if (aiRandInt(3) == 0)	// 33% chance of A.I. going rax
    {
        xsDisableSelf();
        return;
    }

    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeAxeman, 0.4);
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeSpearman, 0.4);
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeSlinger, 0.4);
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeCamelry, 0.6);
    if (gAge3MinorGod == cTechAge3Sekhmet)
        kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeChariotArcher, 0.7);
    else
        kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeChariotArcher, 0.6);
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeWarElephant, 0.3);

    xsDisableSelf(); 
}

//==============================================================================
rule mainBaseDefPlan1   //Make a defend plan that protects the main base
//    minInterval 61 //starts in cAge2
    minInterval 71 //starts in cAge1
    inactive
{
    aiEcho("mainBaseDefPlan1:");
  
    if (kbGetAge() < cAge2)
        return;
        
    static bool alreadyInAge3 = false;

    if ((kbGetAge() == cAge3) && (alreadyInAge3 == false))
    {
        alreadyInAge3 = true;
        aiPlanDestroy(gMBDefPlan1ID);
        gMBDefPlan1ID = -1;
        aiEcho("destroying gMBDefPlan1ID");
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
                aiEcho("mainBaseDefPlan1 exists: ID is "+defendPlanID);
                return;
            }
        }
    }

    int mainBaseDefPlan1ID = aiPlanCreate("mainBaseDefPlan1", cPlanDefend);
    if (mainBaseDefPlan1ID != -1)
    {
//        aiPlanSetVariableInt(mainBaseDefPlan1ID, cDefendPlanRefreshFrequency, 0, 5);
        aiPlanSetVariableInt(mainBaseDefPlan1ID, cDefendPlanRefreshFrequency, 0, 10);
        aiPlanSetVariableVector(mainBaseDefPlan1ID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
        
        aiPlanSetVariableFloat(mainBaseDefPlan1ID, cDefendPlanEngageRange, 0, 50.0);
//        aiPlanSetVariableFloat(mainBaseDefPlan1ID, cDefendPlanGatherDistance, 0, 20.0);
        aiPlanSetVariableFloat(mainBaseDefPlan1ID, cDefendPlanGatherDistance, 0, 25.0);
        
        aiPlanSetUnitStance(mainBaseDefPlan1ID, cUnitStancePassive);
        aiPlanSetVariableBool(mainBaseDefPlan1ID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(mainBaseDefPlan1ID, cDefendPlanAttackTypeID, 2, true);
        aiPlanSetVariableInt(mainBaseDefPlan1ID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(mainBaseDefPlan1ID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);

        if (kbGetAge() > cAge2)
        {
            aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractCavalry, 0, 2, 2);
            aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractInfantry, 0, 2, 2);
            if (cMyCulture == cCultureNorse)
            {
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeThrowingAxeman, 0, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 0, 2, 2);
//                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeBallista, 0, 1, 1);
            }
            else if (cMyCulture == cCultureGreek)
            {
                if (cMyCiv == cCivHades)
                {  
                    aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypePeltast, 0, 1, 1);
//                    aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeToxotes, 1, 1, 1);
                    aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeToxotes, 0, 1, 1);
                }
                else
                    aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractArcher, 0, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 0, 1, 1);
            }
            else if (cMyCulture == cCultureAtlantean)
            {
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractArcher, 0, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 0, 1, 1);
            }
            else
            {
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractArcher, 0, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 0, 1, 1);
            }
        }
        else
        {
            aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractCavalry, 1, 2, 2);
            if (cMyCulture == cCultureNorse)
            {
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractInfantry, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeThrowingAxeman, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 1, 2, 2);
            }
            else if (cMyCulture == cCultureGreek)
            {
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractInfantry, 1, 2, 2);
                if (cMyCiv == cCivHades)
                    aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeToxotes, 1, 2, 2);
                else
                    aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractArcher, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 1, 1, 1);
            }
            else if (cMyCulture == cCultureAtlantean)
            {
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractInfantry, 1, 3, 3);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractArcher, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 1, 1, 1);
            }
            else
            {
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractInfantry, 1, 3, 3);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeAbstractArcher, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeHero, 1, 1, 1);
            }
        }

        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 0, 1);
        
      //  if (gAge2MinorGod == cTechAge2Okeanus)
       //     aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeFlyingMedic, 0, 0, 1);
        
        aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 1);
            
        aiPlanSetDesiredPriority(mainBaseDefPlan1ID, 40);
        
        aiPlanSetBaseID(mainBaseDefPlan1ID, mainBaseID);
        
        aiPlanSetActive(mainBaseDefPlan1ID);
        gMBDefPlan1ID = mainBaseDefPlan1ID;
        aiEcho("mainBaseDefPlan1 set active: "+gMBDefPlan1ID);
    }
}

//==============================================================================
rule mainBaseDefPlan2   //Make a second defend plan that protects the main base
//    minInterval 63 //starts in cAge2
    minInterval 73 //starts in cAge1
    inactive
{
    aiEcho("mainBaseDefPlan2:");

    if (kbGetAge() < cAge2)
        return;
        
    static bool alreadyInAge3 = false;

    if ((kbGetAge() == cAge3) && (alreadyInAge3 == false))
    {
        alreadyInAge3 = true;
        aiPlanDestroy(gMBDefPlan2ID);
        gMBDefPlan2ID = -1;
        aiEcho("destroying gMBDefPlan2ID");
    }
        
    int mainBaseID = kbBaseGetMainID(cMyID);

    //If we already have a mainBaseDefPlan2, don't make another one.
    int activeDefPlans = aiPlanGetNumber(cPlanDefend, -1, true);
    if (activeDefPlans > 0)
    {
        for (i = 0; < activeDefPlans)
        {
            int defendPlanID = aiPlanGetIDByIndex(cPlanDefend, -1, true, i);
            if (defendPlanID == -1)
                continue;
                
            if (defendPlanID == gMBDefPlan2ID)
            {
                //aiEcho("mainBaseDefPlan2 exists: ID is "+defendPlanID);
                return;
            }
        }
    }

    int mainBaseDefPlan2ID = aiPlanCreate("mainBaseDefPlan2", cPlanDefend);
    if (mainBaseDefPlan2ID != -1)
    {
//        aiPlanSetVariableInt(mainBaseDefPlan2ID, cDefendPlanRefreshFrequency, 0, 5);
        aiPlanSetVariableInt(mainBaseDefPlan2ID, cDefendPlanRefreshFrequency, 0, 10);
        aiPlanSetVariableVector(mainBaseDefPlan2ID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
        
        aiPlanSetVariableFloat(mainBaseDefPlan2ID, cDefendPlanEngageRange, 0, 50.0);
        aiPlanSetVariableFloat(mainBaseDefPlan2ID, cDefendPlanGatherDistance, 0, 20.0);
//        aiPlanSetVariableFloat(mainBaseDefPlan2ID, cDefendPlanGatherDistance, 0, 15.0);

        aiPlanSetUnitStance(mainBaseDefPlan2ID, cUnitStancePassive);
        aiPlanSetVariableBool(mainBaseDefPlan2ID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(mainBaseDefPlan2ID, cDefendPlanAttackTypeID, 2, true);
        aiPlanSetVariableInt(mainBaseDefPlan2ID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(mainBaseDefPlan2ID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);

        if (kbGetAge() > cAge2)
        {
            aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractCavalry, 0, 2, 2);
            aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractInfantry, 0, 2, 2);
            if (cMyCulture == cCultureNorse)
            {
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeThrowingAxeman, 0, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeHero, 0, 1, 1);
//                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeBallista, 0, 1, 1);
            }
            else if (cMyCulture == cCultureGreek)
            {
                if (cMyCiv == cCivHades)
                {  
                    aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypePeltast, 0, 1, 1);
                    aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeToxotes, 0, 1, 1);
                }
                else
                    aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractArcher, 0, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeHero, 0, 0, 1);
            }
            else if (cMyCulture == cCultureAtlantean)
            {
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractArcher, 0, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeHero, 0, 1, 1);
            }
            else
            {
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractArcher, 0, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeHero, 0, 1, 1);
            }
        }
        else
        {
            aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractCavalry, 1, 2, 2);
            if (cMyCulture == cCultureNorse)
            {
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractInfantry, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeThrowingAxeman, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeHero, 0, 1, 1);
            }
            else if (cMyCulture == cCultureGreek)
            {
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractInfantry, 1, 2, 2);
                if (cMyCiv == cCivHades)
                    aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeToxotes, 1, 2, 2);
                else
                    aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractArcher, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeHero, 0, 0, 1);
            }
            else if (cMyCulture == cCultureAtlantean)
            {
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractInfantry, 1, 3, 3);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractArcher, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeHero, 1, 1, 1);
            }
            else
            {
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractInfantry, 1, 3, 3);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeAbstractArcher, 1, 2, 2);
                aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeHero, 0, 1, 1);
            }
        }
    //    if (gAge2MinorGod == cTechAge2Okeanus)
     //       aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeFlyingMedic, 0, 0, 1);
            
        aiPlanAddUnitType(mainBaseDefPlan2ID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 1);

        aiPlanSetDesiredPriority(mainBaseDefPlan2ID, 30);   // low but higher than gDefendPlan

        aiPlanSetBaseID(mainBaseDefPlan2ID, mainBaseID);
        
        aiPlanSetActive(mainBaseDefPlan2ID);
        gMBDefPlan2ID = mainBaseDefPlan2ID;
        aiEcho("mainBaseDefPlan2 set active: "+gMBDefPlan2ID);
    }
}

//==============================================================================
rule otherBasesDefPlans //Make defend plans that protect the other bases
    minInterval 43 //starts in cAge2
    inactive
{
    aiEcho("____!§$%&/()=?____");
    aiEcho("otherBasesDefPlans:");
    
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
            
            //Do we need this in here???
            int numFavorPlans = aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0);
            if (numFavorPlans < 2)
                numFavorPlans = 2;
            
            vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
            int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cMyID, defPlanDefPoint, 15.0);

            if (defendPlanID == gOtherBase1DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    aiEcho("-> destroying gOtherBase1DefPlan, setting gOtherBase1UnitID and gOtherBase1ID to -1");
                    aiPlanDestroy(defendPlanID);
                    gOtherBase1DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase1ID);
                    
                    if (cMyCulture == cCultureGreek)
                    {
                        //remove favor
                        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans - 1);
                        aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, gOtherBase1ID);
                        aiEcho("removing favor breakdown for gOtherBase1");
                    }

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
                    //aiEcho("defendPlanID == gOtherBase1DefPlanID");
                }
                continue;
            }
            else if (defendPlanID == gOtherBase2DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    aiEcho("-> destroying gOtherBase2DefPlan, setting gOtherBase2UnitID and gOtherBase2ID to -1");
                    aiPlanDestroy(defendPlanID);
                    gOtherBase2DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase2ID);
                    
                    if (cMyCulture == cCultureGreek)
                    {
                        //remove favor
                        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans - 1);
                        aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, gOtherBase2ID);
                        aiEcho("removing favor breakdown for gOtherBase2");
                    }
                    
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
                    //aiEcho("defendPlanID == gOtherBase2DefPlanID");
                }
                continue;
            }
            else if (defendPlanID == gOtherBase3DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    aiEcho("-> destroying gOtherBase3DefPlan, setting gOtherBase3UnitID and gOtherBase3ID to -1");
                    aiPlanDestroy(defendPlanID);
                    gOtherBase3DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase3ID);
                    
                    if (cMyCulture == cCultureGreek)
                    {
                        //remove favor
                        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans - 1);
                        aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, gOtherBase3ID);
                        aiEcho("removing favor breakdown for gOtherBase3");
                    }
                    
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
                    //aiEcho("defendPlanID == gOtherBase3DefPlanID");
                }
                continue;
            }
            else if (defendPlanID == gOtherBase4DefPlanID)
            {
                if (myBaseAtDefPlanPosition < 1)
                {
                    aiEcho("-> destroying gOtherBase4DefPlan, setting gOtherBase4UnitID and gOtherBase4ID to -1");
                    aiPlanDestroy(defendPlanID);
                    gOtherBase4DefPlanID = -1;
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase4ID);
                    
                    if (cMyCulture == cCultureGreek)
                    {
                        //remove favor
                        aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans - 1);
                        aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, gOtherBase4ID);
                        aiEcho("removing favor breakdown for gOtherBase4");
                    }
                    
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
                    //aiEcho("defendPlanID == gOtherBase4DefPlanID");
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
    
    int favorPriority = 40;
    
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
            //aiEcho("----------------------------------");
            //aiEcho("otherBaseUnitID: "+otherBaseUnitID+" for index: "+index+" hitpoints: "+kbUnitGetCurrentHitpoints(otherBaseUnitID));
            //aiEcho("otherBaseID: "+otherBaseID);
            if (otherBaseID == -1)
                continue;

            if (otherBaseUnitID == gOtherBase1UnitID)
            {
                if ((otherBaseID != gOtherBase1ID) || (otherBaseID != OB1DefPlanBaseID))
                {
                    aiEcho("strange, otherBaseUnitID == gOtherBase1UnitID BUT otherBaseID != gOtherBase1ID OR otherBaseID != OB1DefPlanBaseID");
                    aiEcho("removing farm breakdown, updating baseIDs of defplan and wall plan");
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase1ID);

                    //remove old favor breakdown and add new favor breakdown
                    if (cMyCulture == cCultureGreek)
                    {
                        aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, gOtherBase1ID);
                        aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, favorPriority, 1.0, otherBaseID);
                    }
                    
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
                //aiEcho("otherBaseUnitID == gOtherBase1UnitID");
                continue;
            }
            else if (otherBaseUnitID == gOtherBase2UnitID)
            {
                if ((otherBaseID != gOtherBase2ID) || (otherBaseID != OB2DefPlanBaseID))
                {
                    aiEcho("strange, otherBaseUnitID == gOtherBase2UnitID BUT otherBaseID != gOtherBase2ID OR otherBaseID != OB2DefPlanBaseID");
                    aiEcho("removing farm breakdown, updating baseIDs of defplan and wall plan");
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase2ID);
                    
                    //remove old favor breakdown and add new favor breakdown
                    if (cMyCulture == cCultureGreek)
                    {
                        aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, gOtherBase2ID);
                        aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, favorPriority, 1.0, otherBaseID);
                    }

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
                //aiEcho("otherBaseUnitID == gOtherBase2UnitID");
                continue;
            }
            else if (otherBaseUnitID == gOtherBase3UnitID)
            {
                if ((otherBaseID != gOtherBase3ID) || (otherBaseID != OB3DefPlanBaseID))
                {
                    aiEcho("strange, otherBaseUnitID == gOtherBase3UnitID BUT otherBaseID != gOtherBase3ID OR otherBaseID != OB3DefPlanBaseID");
                    aiEcho("removing farm breakdown, updating baseIDs of defplan and wall plan");
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase3ID);
                    
                    //remove old favor breakdown and add new favor breakdown
                    if (cMyCulture == cCultureGreek)
                    {
                        aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, gOtherBase3ID);
                        aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, favorPriority, 1.0, otherBaseID);
                    }

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
                //aiEcho("otherBaseUnitID == gOtherBase3UnitID");
                continue;
            }
            else if (otherBaseUnitID == gOtherBase4UnitID)
            {
                if ((otherBaseID != gOtherBase4ID) || (otherBaseID != OB4DefPlanBaseID))
                {
                    aiEcho("strange, otherBaseUnitID == gOtherBase4UnitID BUT otherBaseID != gOtherBase4ID OR otherBaseID != OB4DefPlanBaseID");
                    aiEcho("removing farm breakdown, updating baseIDs of defplan and wall plan");
                    //remove farm breakdown
                    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gOtherBase4ID);
                    
                    //remove old favor breakdown and add new favor breakdown
                    if (cMyCulture == cCultureGreek)
                    {
                        aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, gOtherBase4ID);
                        aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, favorPriority, 1.0, otherBaseID);
                    }

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
                //aiEcho("otherBaseUnitID == gOtherBase4UnitID");
                continue;
            }
            else if (otherBaseID != mainBaseID)
            {
                //we got a new base ID, save it, if no other base has been saved as new base ID yet
                if (newBaseID < 0 )
                {
                    newBaseID = otherBaseID;
                    newBaseUnitID = otherBaseUnitID;
                    //aiEcho("newBaseID = otherBaseID, ID = "+newBaseID);
                    //aiEcho("newBaseUnitID = otherBaseUnitID, ID = "+newBaseUnitID);
                }
            }
        }
    }
    
    numFavorPlans = aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0);
    
    if (newBaseID < 0)
    {
        aiEcho("newbaseID < 0, returning");
        return;
    }
    else if (otherBase1 == false)
    {
        gOtherBase1ID = newBaseID;
        gOtherBase1UnitID = newBaseUnitID;
        //aiEcho("otherBase1 == false -> gOtherBase1UnitID = newBaseUnitID: "+newBaseUnitID);
        
        if (cMyCulture == cCultureGreek)
        {
            //enable favor plan
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans + 1);
            aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, favorPriority, 1.0, gOtherBase1ID);
            aiEcho("adding favor breakdown for gOtherBase1");
        }
            
        if (gBuildWalls == true)
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
        //aiEcho("otherBase2 == false -> gOtherBase2UnitID = newBaseUnitID: "+newBaseUnitID);
        
        if (cMyCulture == cCultureGreek)
        {
            //enable favor plan
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans + 1);
            aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, favorPriority, 1.0, gOtherBase2ID);
            aiEcho("adding favor breakdown for gOtherBase2");
        }
        
        if (gBuildWalls == true)
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
        //aiEcho("otherBase3 == false -> gOtherBase3UnitID = newBaseUnitID: "+newBaseUnitID);
        
        if (cMyCulture == cCultureGreek)
        {
            //enable favor plan
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans + 1);
            aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, favorPriority, 1.0, gOtherBase3ID);
            aiEcho("adding favor breakdown for gOtherBase3");
        }
        
        if (gBuildWalls == true)
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
        //aiEcho("otherBase4 == false -> gOtherBase4UnitID = newBaseUnitID: "+newBaseUnitID);
        
        if (cMyCulture == cCultureGreek)
        {
            //enable favor plan
            aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, numFavorPlans + 1);
            aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, favorPriority, 1.0, gOtherBase4ID);
            aiEcho("adding favor breakdown for gOtherBase4");
        }
        
        if (gBuildWalls == true)
        {
            //enable the wall plan for gOtherBase4UnitID
            xsEnableRule("otherBase4RingWallTeam");
            otherBase4RingWallTeam();
        }
    }
    else
    {
        aiEcho("4 other bases exist, returning");
        return;
    }
    
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector newBaseLocation = kbBaseGetLocation(cMyID, newBaseID);
    vector newBaseUnitPosition = kbUnitGetPosition(newBaseUnitID);
    float distToMainBase = xsVectorLength(mainBaseLocation - newBaseUnitPosition);
    
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
//        aiPlanSetVariableInt(otherBaseDefPlanID, cDefendPlanRefreshFrequency, 0, 5);
        aiPlanSetVariableInt(otherBaseDefPlanID, cDefendPlanRefreshFrequency, 0, 10);
        aiPlanSetUnitStance(otherBaseDefPlanID, cUnitStancePassive);
        aiPlanSetVariableBool(otherBaseDefPlanID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(otherBaseDefPlanID, cDefendPlanAttackTypeID, 2, true);
        aiPlanSetVariableInt(otherBaseDefPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(otherBaseDefPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);

        if (distToMainBase > 80.0)
        {
            if (cMyCulture == cCultureNorse)
            {
                aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeThrowingAxeman, 0, 2, 2);
            }
            else if (cMyCulture == cCultureGreek)
            {
                if (cMyCiv == cCivHades)
                {  
                    aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypePeltast, 0, 1, 1);
                    aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeToxotes, 0, 1, 1);
                    aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeShadeofHades, 0, 1, 1);
                }
                else
                    aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeAbstractArcher, 0, 2, 2);
            }
            else
            {
                aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeAbstractArcher, 0, 2, 2);
            }
            aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeAbstractInfantry, 0, 2, 2);
            aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeAbstractCavalry, 0, 2, 2);
        }
        else
        {
            if (cMyCulture == cCultureNorse)
            {
                aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeThrowingAxeman, 0, 2, 2);
            }
            else if (cMyCulture == cCultureGreek)
            {
                if (cMyCiv == cCivHades)
                {  
                    aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypePeltast, 0, 1, 1);
                    aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeToxotes, 0, 1, 1);
                }
                else
                    aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeAbstractArcher, 0, 2, 2);
            }
            else
            {
                aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeAbstractArcher, 0, 2, 2);
            }
            aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeAbstractInfantry, 0, 1, 1);
            aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeAbstractCavalry, 0, 1, 1);
        }
        aiPlanAddUnitType(otherBaseDefPlanID, cUnitTypeHero, 0, 0, 1);
        
//        aiPlanSetVariableFloat(otherBaseDefPlanID, cDefendPlanGatherDistance, 0, 14.0);
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
        aiEcho("otherBaseDefPlan for base #"+newBaseID+" set active: "+otherBaseDefPlanID);
        
        //reset the minInterval since calling the wallplans seems to change the minInterval
        xsSetRuleMinIntervalSelf(43);
    }
}

//==============================================================================
rule attackEnemySettlement
    minInterval 29 //starts in cAge2
    inactive
{
    aiEcho("-----_____-----");
    aiEcho("******* attackEnemySettlement:");
    
    int numHumanSoldiers = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);
    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
    int numSiegeWeapons = kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive);
    int numRagnorokHeroes = kbUnitCount(cMyID, cUnitTypeHeroRagnorok, cUnitStateAlive);
    
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);

    int numMythUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeMythUnitNotTitan, cUnitStateAlive);
    int numNonMilitaryMythUnits = kbUnitCount(cMyID, cUnitTypePegasus, cUnitStateAlive);
    if (cMyCiv == cCivOdin)
        numNonMilitaryMythUnits = numNonMilitaryMythUnits + kbUnitCount(cMyID, cUnitTypeRaven, cUnitStateAlive);
    else if (cMyCulture == cCultureAtlantean)
        numNonMilitaryMythUnits = numNonMilitaryMythUnits + kbUnitCount(cMyID, cUnitTypeFlyingMedic, cUnitStateAlive);
    int numMilitaryMythUnits = numMythUnits - numNonMilitaryMythUnits;
    int numSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
//    int numEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numAttEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
//    int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    aiEcho("numEnemyMilUnitsNearMBInR80: "+numEnemyMilUnitsNearMBInR80);
    aiEcho("numAttEnemyMilUnitsNearMBInR85: "+numAttEnemyMilUnitsNearMBInR85);
    aiEcho("numAttEnemyTitansNearMBInR85: "+numAttEnemyTitansNearMBInR85);
    
    vector defPlanBaseLocation = cInvalidVector;
//    int numEnemyTitansNearDefBInR55 = 0;
    int numEnemyTitansNearDefBInR35 = 0;
    int numAttEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        aiEcho("defPlanBaseLocation: "+defPlanBaseLocation);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
//            numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
            numEnemyTitansNearDefBInR35 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 35.0, true);
            numAttEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
        }
    }
    aiEcho("numAttEnemyTitansNearDefBInR55: "+numAttEnemyTitansNearMBInR85);
    
    static int attackPlanStartTime = -1;
    aiEcho("attackPlanStartTime: "+attackPlanStartTime);

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
    aiEcho("numEnemySettlementsNearMB: "+numEnemySettlementsNearMB);
    aiEcho("numMotherNatureSettlementsNearMB: "+numMotherNatureSettlementsNearMB);
    
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
                aiEcho("numEnemySettlementsInRange: "+numEnemySettlementsInRange+" of player "+playerID);
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
                        aiEcho("distanceToDefBaseToUse: "+distanceToDefBaseToUse);
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
    
    aiEcho("closestSettlementID: "+closestSettlementID);
    aiEcho("secondClosestSettlementID: "+secondClosestSettlementID);
    
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
            aiEcho("closestSettlementID close to mainBase: "+closestSettlementID);
            vector closestSettlementPos = kbUnitGetPosition(closestSettlementID);
            numSettlementsBeingBuiltCloseToMB = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateBuilding, -1, playerID, closestSettlementPos, 15.0);
            aiEcho("numSettlementsBeingBuiltCloseToMB: "+numSettlementsBeingBuiltCloseToMB);
        }
        else
        {
            aiEcho("closestSettlementID in Range "+radius+": "+closestSettlementID);
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
        
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();
    aiEcho("currentPop: "+currentPop+", currentPopCap: "+currentPopCap);
    
    // Find the attack plans
    int activeAttPlans = aiPlanGetNumber(cPlanAttack, -1, true );  // Attack plans, any state, active only
    if (activeAttPlans > 0)
    {
        for (i = 0; < activeAttPlans)
        {
            int attackPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);
            aiEcho("attackPlanID: "+attackPlanID);
            if (attackPlanID == -1)
                continue;
            
            int planState = aiPlanGetState(attackPlanID);
            aiEcho(",.-,.-,.-,.-,.-");
            aiEcho("planState: "+planState);
            
            if (attackPlanID == gEnemySettlementAttPlanID)
            {
                aiEcho("attackPlanID == gEnemySettlementAttPlanID");
                
                int numTitansInAttackPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeAbstractTitan);
                int numMythInAttackPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
                int numSiegeInAttackPlan = aiPlanGetNumberUnits(attackPlanID, cUnitTypeAbstractSiegeWeapon);
                
                if ((targetSettlementCloseToMB == true) && (planState <= cPlanStateGather))
                {
                    if ((aiPlanGetVariableInt(attackPlanID, cAttackPlanSpecificTargetID, 0) != closestSettlementID) && (closestSettlementID != -1))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanSpecificTargetID, 0, closestSettlementID);
                        aiEcho("Setting attackPlanID cAttackPlanSpecificTargetID to closestSettlementID close to mainBase: "+closestSettlementID);
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanPlayerID, 0, closestSettlementPlayerID);
                        aiEcho("Setting attackPlanID cAttackPlanPlayerID to closestSettlementPlayerID: "+closestSettlementPlayerID);
                    }
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
                        aiPlanAddUnitType(attackPlanID, cUnitTypeAbstractSiegeWeapon, 1, 3, 3);
                    }
                    
                    if (numTitansInAttackPlan > 0)
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, false);  // Make sure the gEnemySettlementAttPlan stays open
                        aiEcho("Setting gEnemySettlementAttPlanID NoMoreUnits to false");
                        aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 10, currentPopCap / 5 + 3, currentPopCap / 5 + 3);
                    }
//                    else if ((currentPop >= currentPopCap * 0.85) && ((numMythInAttackPlan > 0) || (numSiegeInAttackPlan > 0)) && (kbGetAge() > cAge3)
                    else if ((currentPop >= currentPopCap * 0.8) && ((numMythInAttackPlan > 0) || (numSiegeInAttackPlan > 0)) && (kbGetAge() > cAge3)
                          && (woodSupply > 300) && (goldSupply > 400) && (foodSupply > 400) && (numEnemyMilUnitsNearMBInR80 < 20))
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, false);  // Make sure the gEnemySettlementAttPlan stays open
                        aiPlanSetDesiredPriority(attackPlanID, 55);
                        aiEcho("Setting gEnemySettlementAttPlanID NoMoreUnits to false");
                        aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 8, currentPopCap / 5, currentPopCap / 5);
                    }
                    else
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, true);  // Make sure the gEnemySettlementAttPlan is closed
                        aiPlanSetDesiredPriority(attackPlanID, 51);
                        aiEcho("Setting gEnemySettlementAttPlanID NoMoreUnits to true");
                    }
                }
//                else if (((planState < cPlanStateAttack) && (planState != cPlanStateDone))
//                else if (((planState == cPlanStateGather) || (planState == cPlanStateExplore))
                else if (((planState == cPlanStateGather) || (planState == cPlanStateExplore) || (planState == cPlanStateNone))
//                 && (xsGetTime() > attackPlanStartTime + 5*60*1000) && (attackPlanStartTime != -1))
                 && (xsGetTime() > attackPlanStartTime + 3.5*60*1000) && (attackPlanStartTime != -1))
                {
                    if ((xsGetTime() > attackPlanStartTime + 5*60*1000) && (attackPlanStartTime != -1))
                    {
                        aiPlanDestroy(attackPlanID);
                        gEnemySettlementAttPlanTargetUnitID = -1;
                        aiEcho("destroying gEnemySettlementAttPlanID as it has been active for more than 5 Minutes");
                    }
                    else
                    {
                        aiPlanSetVariableBool(attackPlanID, cAttackPlanMoveAttack, 0, false);
                        aiEcho("setting cAttackPlanMoveAttack to false");
                    }
                    continue;
                }
                aiEcho("returning");
                return;                
            }
            else if (attackPlanID == gRandomAttackPlanID)
            {
                if (planState < cPlanStateAttack)
                {
                    //aiEcho("there is a gRandomAttackPlanID active and gathering units");
                    randomAttackPlanActive = true;
                }
                continue;
            }
            else if (attackPlanID == gLandAttackPlanID)
            {
                //aiEcho("there is a gLandAttackPlanID active");
                landAttackPlanActive = true;
                continue;
            }
        }
    }
    
//    if (numEnemyTitansNearMBInR85 > 0)
    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR85 > 0))
    {
        aiEcho("attackEnemySettlement: returning as there's an enemy Titan near our main base");
        return;
    }
//    else if (numEnemyTitansNearDefBInR55 > 0)
    else if ((numEnemyTitansNearDefBInR35 > 0) || (numAttEnemyTitansNearDefBInR55 > 0))
    {
        aiEcho("attackEnemySettlement: returning as there's an enemy Titan near our defPlanBase");
        return;
    }

    if (gEnemyWonderDefendPlan > 0)
    {
        aiEcho("returning as there's a wonder attack plan open");
        return;
    }
   
//    if ((numEnemyMilUnitsNearMBInR100 > 10) && (targetSettlementCloseToMB == false))
//    if ((numEnemyMilUnitsNearMBInR85 > 10) && (targetSettlementCloseToMB == false))
    if ((numAttEnemyMilUnitsNearMBInR85 > 10) && (targetSettlementCloseToMB == false))
    {
        aiEcho("returning as there are too many enemies near our main base");
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
                aiEcho("settlementPosDefPlanActive = true");
                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 15.0);
                int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 15.0, true);
            }
        }
    }
    
    
    int mostHatedPlayerID = aiGetMostHatedPlayerID();
    int numMHPlayerSettlements = kbUnitCount(mostHatedPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    //aiEcho("mostHatedPlayerID is: "+mostHatedPlayerID);
    aiEcho("numMHPlayerSettlements: "+numMHPlayerSettlements);      
    
    if (targetSettlementCloseToMB == false)
    {
        if ((numMHPlayerSettlements < 1) && (targetSettlementID < 0))
        {
            aiEcho("targetSettlementID < 0 and numMHPlayerSettlements < 1, returning");
            return;
        }
        if ((settlementPosDefPlanActive == true) && (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1))
        {
            aiEcho("returning as there's a settlementPosDefPlan active");
            return;
        }
        else if (randomAttackPlanActive == true)
        {
            aiEcho("returning as there is a gRandomAttackPlanID active and gathering units");
            return;
        }
        else if (landAttackPlanActive == true)
        {
            aiEcho("returning as there is a landAttackPlan active");
            return;
        }
//        else if ((numSiegeWeapons < 1) && (numMilitaryMythUnits < 1) && (numTitans < 1) && (currentPop <= currentPopCap))
        else if ((numSiegeWeapons < 1) && (numMilitaryMythUnits < 1) && (numTitans < 1) && (currentPop <= currentPopCap - 2))
        {
            aiEcho("returning as we don't have a Titan, a siege weapon, or a military myth unit");
            return;
        }
        else if (((woodSupply < 400) || (goldSupply < 400) || (foodSupply < 400)) && (currentPop <= currentPopCap - 2))
        {
            aiEcho("returning as we don't have enough resources");
            return;
        }
    }
    else
    {

        if (((woodSupply < 150) || (goldSupply < 150) || (foodSupply < 110)) && (currentPop <= currentPopCap - 2))
        {
            aiEcho("returning as we don't have enough resources");
            return;
        }
    }

    
    int enemyMainBaseUnitID = -1;
    float veryCloseRange = 65.0;
    
    if ((targetSettlementID != -1) && (targetPlayerID != -1))
    {
        enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(targetPlayerID);
        aiEcho("enemyMainBaseUnitID: "+enemyMainBaseUnitID+" for player: "+targetPlayerID);
        if ((targetSettlementID == enemyMainBaseUnitID) && (savedDistanceToClosestSettlement > veryCloseRange)
         && (secondClosestSettlementID != -1))
        {
            //check if the secondClosestSettlement's distance is only a little farther
            if (savedDistanceToSecondClosestSettlement - savedDistanceToClosestSettlement < 20.0 )
            {
                enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(secondClosestSettlementPlayerID);
                aiEcho("enemyMainBaseUnitID: "+enemyMainBaseUnitID+" for player: "+secondClosestSettlementPlayerID);
                if (secondClosestSettlementID != enemyMainBaseUnitID)
                {
                    targetSettlementID = secondClosestSettlementID;
                    targetPlayerID = secondClosestSettlementPlayerID;
                    aiEcho("setting targetSettlementID to secondClosestSettlementID: "+targetSettlementID);
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
            aiEcho("setting targetSettlementID to secondClosestSettlementID: "+targetSettlementID);
        }
        else
        {
            index = aiRandInt(numMHPlayerSettlements);
            targetSettlementID = findUnitByIndex(cUnitTypeAbstractSettlement, index, cUnitStateAliveOrBuilding, -1, mostHatedPlayerID);
            if (targetSettlementID != -1)
            {
                aiEcho("setting targetSettlementID to random settlement ID: "+targetSettlementID);
                targetPlayerID = mostHatedPlayerID;
                aiEcho("----------------------------------------");
            }
            else
            {
                aiEcho("targetSettlementID < 0, returning");
                return;
            }
        }
    }
    
    
    int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInMBDefPlan2 = aiPlanGetNumberUnits(gMBDefPlan2ID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numSiegeUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeAbstractSiegeWeapon);
    int numMythUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
    int numTitansIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeAbstractTitan);
    
    aiEcho("numMilUnitsIngDefendPlan: "+numMilUnitsIngDefendPlan);
    aiEcho("numMilUnitsInBaseUnderAttackDefPlan: "+numMilUnitsInBaseUnderAttackDefPlan);
    aiEcho("numMilUnitsInSettlementPosDefPlan: "+numMilUnitsInSettlementPosDefPlan);
    int numMilUnitsInDefPlans = numMilUnitsIngDefendPlan + numMilUnitsInBaseUnderAttackDefPlan * 0.4 + numMilUnitsInSettlementPosDefPlan * 0.4;
//    if ((numMilUnitsInMBDefPlan2 > 3) && (numEnemyMilUnitsNearMBInR85 < 11) && (numEnemyTitansNearMBInR85 < 1))
    if ((numMilUnitsInMBDefPlan2 > 3) && (numAttEnemyMilUnitsNearMBInR85 < 11) && (numAttEnemyTitansNearMBInR85 < 1))
    {
        numMilUnitsInDefPlans = numMilUnitsInDefPlans + numMilUnitsInMBDefPlan2 * 0.4;
    }
    aiEcho("total numMilUnitsInDefPlans: "+numMilUnitsInDefPlans);

    
    vector targetSettlementPos = kbUnitGetPosition(targetSettlementID);
    float distanceToTarget = xsVectorLength(baseLocationToUse - targetSettlementPos);
    aiEcho("distanceToTarget: "+distanceToTarget);
    
    enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(targetPlayerID);
    aiEcho("enemyMainBaseUnitID: "+enemyMainBaseUnitID+" for player: "+targetPlayerID);
    bool targetIsEnemyMainBase = false;
        
    if (targetSettlementID == enemyMainBaseUnitID)
    {
        aiEcho("Enemy Settlement is his mainbase");
        if ((kbGetAge() < cAge4) && (1 + getNumPlayersByRel(true) - getNumPlayersByRel(false) < 0))
        {
            aiEcho("Not yet in Age4 and there are too many enemy players, returning!");
            return;
        }
        else
        {
            if ((numTitansIngDefendPlan > 0)
             || ((numMilUnitsInDefPlans > 14) && ((numSiegeUnitsIngDefendPlan > 1) || (numMythUnitsIngDefendPlan > 1)
              || ((numSiegeUnitsIngDefendPlan > 0) && (numMythUnitsIngDefendPlan > 0)))))
            {
                targetIsEnemyMainBase = true;
                aiEcho("We have enough troops, attacking enemy main base!");
            }
            else
            {
                aiEcho("returning as we don't have enough troops to attack his main base");
                return;
            }
        }
    }
    else
    {
        if ((targetSettlementCloseToMB == true) && (numSettlementsBeingBuiltCloseToMB > 0))
        {
            if (numMilUnitsInDefPlans < 8)
            {
                aiEcho("returning as we don't have enough troops to attack targetSettlementID:"+targetSettlementID+" in close range");
                return;
            }
            else
            {
                aiEcho("We have enough troops to attack targetSettlementID:"+targetSettlementID+" in close range");
            }
        }
        else
        {
            if ((numTitansIngDefendPlan > 0) || ((numMilUnitsInDefPlans > 9) && ((numSiegeUnitsIngDefendPlan > 0)
             || (numMythUnitsIngDefendPlan > 0))))
            {
                aiEcho("We have enough troops to attack targetSettlementID:"+targetSettlementID);
            }
            else
            {
                aiEcho("returning as we don't have enough troops to attack targetSettlementID:"+targetSettlementID);
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
    
    int enemySettlementsBeingBuiltAtTSP = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateBuilding, -1, targetPlayerID, targetSettlementPos, 15.0);
//    if ((enemySettlementsBeingBuiltAtTSP > 0) && (kbUnitGetHealth(targetSettlementID) < 0.6))
    if ((enemySettlementsBeingBuiltAtTSP > 0) && (kbUnitGetHealth(targetSettlementID) < 0.8))
    {
        aiPlanSetVariableBool(enemySettlementAttPlanID, cAttackPlanMoveAttack, 0, false);
        aiEcho("Setting gEnemySettlementAttPlanID MoveAttack to false");
    }
    
    // Specify other continent so that armies will transport
    aiPlanSetNumberVariableValues(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 1, true);  
    //aiEcho("Area group for enemySettlement is "+kbAreaGroupGetIDByPosition(targetSettlementPos));
    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(targetSettlementPos));

    vector militaryGatherPoint = cInvalidVector;
//    if ((defPlanBaseID != mainBaseID) && (defPlanBaseID != -1))
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
    aiEcho("militaryGatherPoint: "+militaryGatherPoint);
    
    aiPlanSetVariableVector(enemySettlementAttPlanID, cAttackPlanGatherPoint, 0, militaryGatherPoint);
    aiPlanSetVariableFloat(enemySettlementAttPlanID, cAttackPlanGatherDistance, 0, 12.0);

    if (numTitans > 0)
        aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractTitan, 0, 1, 1);

    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
         
    if ((targetIsEnemyMainBase == false) && (numTitans < 1))
    {
        if (targetSettlementCloseToMB == true)
        {
//            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractSiegeWeapon, 0, 2, 2);
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 1, 1);
            
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
            
            if (numMilUnitsInDefPlans < 14)
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, 8, 12, 12);
            else
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.5, numMilUnitsInDefPlans * 0.8, numMilUnitsInDefPlans * 0.8);
        }
        else
        {
//            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractSiegeWeapon, 0, 3, 3);
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractSiegeWeapon, 0, 2, 2);
            if (numRagnorokHeroes < 10)
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 2, 2);
            
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
            
            if (numMilUnitsInDefPlans < 14)
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, 8, 12, 12);
            else
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.55, numMilUnitsInDefPlans * 0.9, numMilUnitsInDefPlans * 0.9);
        }
            
//        aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
        aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanAttackRoutePattern, 0, -1);
        aiPlanSetRequiresAllNeedUnits(enemySettlementAttPlanID, false);
        aiPlanSetUnitStance(enemySettlementAttPlanID, cUnitStanceDefensive);
    }
    else
    {
//        aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractSiegeWeapon, 0, 3, 3);
        aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractSiegeWeapon, 0, 2, 2);
        if ((cMyCulture == cCultureGreek) || (cMyCulture == cCultureEgyptian))
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 2, 2);
        else if (cMyCulture == cCultureAtlantean)
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 3, 3);
        else
        {
            if (numRagnorokHeroes < 10)
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeHero, 0, 4, 4);
        }
        
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
        
        if (numTitans > 0)
            aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.4, numMilUnitsInDefPlans * 0.6, numMilUnitsInDefPlans * 0.6);
        else
        {
            if (currentPopCap > 160)
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.60, numMilUnitsInDefPlans * 0.8, numMilUnitsInDefPlans * 0.8);
            else
                aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.60, numMilUnitsInDefPlans * 0.9, numMilUnitsInDefPlans * 0.9);
        }
//        aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
        aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanAttackRoutePattern, 0, -1);
        
        aiPlanSetRequiresAllNeedUnits(enemySettlementAttPlanID, false);
        aiPlanSetUnitStance(enemySettlementAttPlanID, cUnitStanceDefensive);
    }
    
  //  if (gAge2MinorGod == cTechAge2Okeanus)
   //     aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeFlyingMedic, 0, 1, 1);
  
    int numScouts = kbUnitCount(cMyID, cUnitTypeAbstractScout, cUnitStateAlive);
//    if ((aiRandInt(2) < 1) || (numTitans > 0) || (numScouts < 2) || (targetSettlementCloseToMB == true))
    if ((aiRandInt(2) < 1) || (numTitans > 0) || (numScouts < 2) || (targetSettlementCloseToMB == true)
      || (distanceToTarget <= veryCloseRange))
        aiPlanSetVariableBool(enemySettlementAttPlanID, cAttackPlanAutoUseGPs, 0, false);
    else
        aiPlanSetVariableBool(enemySettlementAttPlanID, cAttackPlanAutoUseGPs, 0, true);
    
    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanRefreshFrequency, 0, 10); 

//    aiPlanSetInitialPosition(enemySettlementAttPlanID, defPlanBaseLocation);
    aiPlanSetInitialPosition(enemySettlementAttPlanID, baseLocationToUse);

    if (numTitans > 0)
        aiPlanSetDesiredPriority(enemySettlementAttPlanID, 55);
    else
        aiPlanSetDesiredPriority(enemySettlementAttPlanID, 51);

    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0, targetSettlementID);
    
    aiPlanSetActive(enemySettlementAttPlanID);
    
    if (lastTargetUnitID == targetSettlementID)
    {
        lastTargetCount = lastTargetCount + 1;
    }
    else
    {
        lastTargetUnitID = targetSettlementID;
        lastTargetCount = 0;
    }
    aiEcho("lastTargetCount: "+lastTargetCount);
    
    gEnemySettlementAttPlanTargetUnitID = targetSettlementID;
    gEnemySettlementAttPlanID = enemySettlementAttPlanID;
    gEnemySettlementAttPlanLastAttPoint = targetSettlementPos;
    aiEcho("gEnemySettlementAttPlanLastAttPoint: "+gEnemySettlementAttPlanLastAttPoint);
    aiEcho("Creating enemy settlement attack plan, target ID is: "+targetSettlementID);
    attackPlanStartTime = xsGetTime();
    aiEcho("attackPlanStartTime: "+attackPlanStartTime);
}

//==============================================================================
rule defendSettlementPosition
    minInterval 15 //starts in cAge2, activated in monitorAttack rule or findMySettlementsBeingBuilt rule
    inactive
{
    aiEcho("--------------------");
    aiEcho("defendSettlementPosition");
    xsSetRuleMinIntervalSelf(23);
    static int defendPlanStartTime = -1;
    
    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    float distToMainBase = xsVectorLength(mainBaseLocation - gSettlementPosDefPlanDefPoint);
    
    int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, gSettlementPosDefPlanDefPoint, 50.0, true);
//    int numEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int myMilUnitsNearMBInR80 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 80.0);
    int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, gSettlementPosDefPlanDefPoint, 15.0);
    int myBuildingsThatShootAtDefPlanPosition = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cMyID, gSettlementPosDefPlanDefPoint, 15.0);
    int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, gSettlementPosDefPlanDefPoint, 15.0, true);

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
                //aiEcho("settlementPosDefPlan exists: ID is "+defendPlanID);

                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int numAttEnemyMilUnitsInR40 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 40.0, true);
                
//                if ((numEnemyTitansNearMBInR80 > 0) || ((enemySettlementAtDefPlanPositionID != -1) && (kbUnitGetCurrentHitpoints(enemySettlementAtDefPlanPositionID) > 0))
                if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0)
                 || ((enemySettlementAtDefPlanPositionID != -1) && (kbUnitGetCurrentHitpoints(enemySettlementAtDefPlanPositionID) > 0))
                 || ((numEnemyMilUnitsNearMBInR80 > 15) && (numEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 3)))
                {
                    aiPlanDestroy(defendPlanID);
//                    if (numEnemyTitansNearMBInR80 > 0)
                    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0))
                        aiEcho("destroying gSettlementPosDefPlan as there's an enemy Titan near our main base");
                    else if ((enemySettlementAtDefPlanPositionID != -1) && (kbUnitGetCurrentHitpoints(enemySettlementAtDefPlanPositionID) > 0))
                        aiEcho("destroying gSettlementPosDefPlan as there's an enemy Settlement at our defend position");
                    else
                        aiEcho("destroying gSettlementPosDefPlan as there are too many enemies near our main base");
                    xsSetRuleMinIntervalSelf(11);
                    xsDisableSelf();
                    return;
                }

                if ((xsGetTime() > defendPlanStartTime + 10*60*1000) || (alliedBaseAtDefPlanPosition > 0)
                 || ((myBaseAtDefPlanPosition > 0) && ((numAttEnemyMilUnitsInR40 < 10) && (myBuildingsThatShootAtDefPlanPosition > 1))
                 || (equal(aiPlanGetVariableVector(gBaseUnderAttackDefPlanID, cDefendPlanDefendPoint, 0), defPlanDefPoint) == true)))
                 
                {
                    if (xsGetTime() > defendPlanStartTime + 10*60*1000)
                        aiEcho("destroying gSettlementPosDefPlan as it has been active for more than 10 Minutes");
                    else if (alliedBaseAtDefPlanPosition > 0)
                        aiEcho("destroying gSettlementPosDefPlan as an ally has built a settlement at the defend position");
                    else
                    {
                        aiEcho("destroying gSettlementPosDefPlan as numAttEnemyMilUnitsInR40 < 10");
                        aiEcho("and I have a settlement plus 1 defensive building at the defend position");
                    }
                    aiPlanDestroy(defendPlanID);
                    xsSetRuleMinIntervalSelf(11);
                    xsDisableSelf();
                    return;
                }
                //aiEcho("returning");
                return;
            }
        }
    }
    
    if (gEnemyWonderDefendPlan > 0)
    {
        //aiEcho("returning as there's a wonder attack plan open");
        return;
    }
    
//    if (numEnemyTitansNearMBInR80 > 0)
    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0))
    {
        //aiEcho("returning as there's an enemy Titan near our main base");
        return;
    }
    
    static int count = 0;
    if (numMilUnits < 20)
    {
        xsSetRuleMinIntervalSelf(11);
        if (count > 2)
        {
            xsSetRuleMinIntervalSelf(12);
            count = 0;
            xsDisableSelf();
        }
        else
            count = count + 1;
        return;
    }
 
    aiEcho("gSettlementPosDefPlanDefPoint: "+gSettlementPosDefPlanDefPoint);
    int settlementPosDefPlanID = aiPlanCreate("settlementPosDefPlan", cPlanDefend);
    if (settlementPosDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
//        aiPlanSetVariableInt(settlementPosDefPlanID, cDefendPlanRefreshFrequency, 0, 5);
        aiPlanSetVariableInt(settlementPosDefPlanID, cDefendPlanRefreshFrequency, 0, 10);
        
        aiPlanSetVariableVector(settlementPosDefPlanID, cDefendPlanDefendPoint, 0, gSettlementPosDefPlanDefPoint);
        aiPlanSetVariableFloat(settlementPosDefPlanID, cDefendPlanEngageRange, 0, 40.0);
//        aiPlanSetVariableFloat(settlementPosDefPlanID, cDefendPlanGatherDistance, 0, 15.0);
        aiPlanSetVariableFloat(settlementPosDefPlanID, cDefendPlanGatherDistance, 0, 17.0);

        aiPlanSetUnitStance(settlementPosDefPlanID, cUnitStancePassive);
        aiPlanSetVariableBool(settlementPosDefPlanID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(settlementPosDefPlanID, cDefendPlanAttackTypeID, 1, true);
        aiPlanSetVariableInt(settlementPosDefPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);

        if (distToMainBase < 85.0)
        {
            if (cMyCulture == cCultureAtlantean)
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 1, 1, 1);
            }
            else
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 1, 1, 1);
            }
            
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
            
            aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 7, 19, 19);
        }
        else
        {
            if (cMyCulture == cCultureNorse)
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 2, 4, 4);
            }
            else if (cMyCulture == cCultureAtlantean)
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 1, 3, 3);
            }
            else
            {
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeHero, 1, 2, 2);
            }
            if (distToMainBase > 100.0)
            {
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                    aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 2, 2);
                
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractSiegeWeapon, 1, 2, 2);
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 11, 24, 24);
            }
            else
            {
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
                    aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
                
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractSiegeWeapon, 1, 1, 1);
                aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 9, 22, 22);
            }
        }
        aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractTitan, 0, 1, 1);
        
    //    if (gAge2MinorGod == cTechAge2Okeanus)
     //       aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeFlyingMedic, 0, 0, 1);

        //override
        if (enemyMilUnitsInR50 > 18)
            aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 11, enemyMilUnitsInR50 + 8, enemyMilUnitsInR50 + 8);
        
        aiPlanSetDesiredPriority(settlementPosDefPlanID, 52);
        aiPlanSetActive(settlementPosDefPlanID);
        gSettlementPosDefPlanID = settlementPosDefPlanID;
        aiEcho("settlementPosDefPlan set active: "+gSettlementPosDefPlanID);
        xsSetRuleMinIntervalSelf(23);
    } 
}


//==============================================================================
rule createRaidingParty
//    minInterval 63 //starts in cAge2
    minInterval 70 //starts in cAge2
    inactive
{
    aiEcho("*!*!*createRaidingParty:");
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector baseLocationToUse = mainBaseLocation;
    
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
//    int numEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR85 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    
    vector defPlanBaseLocation = cInvalidVector;
//    int numEnemyTitansNearDefBInR55 = 0;
    int numEnemyTitansNearDefBInR35 = 0;
    int numAttEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            baseLocationToUse = defPlanBaseLocation;
//          int numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
            numEnemyTitansNearDefBInR35 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 35.0, true);
            numAttEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
        }
    }
    
    static int attackPlanStartTime = -1;
    
//    if (numEnemyTitansNearMBInR85 > 0)
    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR85 > 0))
    {
        //aiEcho("returning as there's an enemy Titan near our main base");
        return;
    }
//    else if (numEnemyTitansNearDefBInR55 > 0)
    else if ((numEnemyTitansNearDefBInR35 > 0) || (numAttEnemyTitansNearDefBInR55 > 0))
    {
        //aiEcho("returning as there's an enemy Titan near our defPlanBase");
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
                //aiEcho("attackPlanID == gRaidingPartyAttackID");
                if ((kbUnitGetCurrentHitpoints(gRaidingPartyTargetUnitID) <= 0) && (gRaidingPartyTargetUnitID != -1))
                {
                    aiPlanDestroy(attackPlanID);
                    gRaidingPartyTargetUnitID = -1;
                    //aiEcho("destroying gRaidingPartyAttackID as the target has been destroyed");
//                    continue;
                }
                else if ((aiPlanGetState(attackPlanID) < cPlanStateAttack) && (xsGetTime() > attackPlanStartTime + 3*60*1000) && (attackPlanStartTime != -1))
                {
                    aiPlanDestroy(attackPlanID);
                    gRaidingPartyTargetUnitID = -1;
                    //aiEcho("destroying gRaidingPartyAttackID as it has been active for more than 3 Minutes");
//                    continue;
                }
                //aiEcho("returning");
                return;
            }
        }
    }
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    
    
    if ((woodSupply < 120) || (foodSupply < 120) || (goldSupply < 120))
    {
        //aiEcho("returning as we don't have enough resources");
        return;
    }

    if (gEnemyWonderDefendPlan > 0)
    {
        //aiEcho("returning as there's a wonder attack plan open");
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
                //aiEcho("numEnemyDropsitesInCloseRange: "+numEnemyDropsitesInCloseRange);
                int dropsiteUnitIDinCloseRange = -1;
                if (numEnemyDropsitesInCloseRange > 0)
                {
                    index = aiRandInt(numEnemyDropsitesInCloseRange);
                    dropsiteUnitIDinCloseRange = findUnitByIndex(enemyEconUnit, index, cUnitStateAliveOrBuilding, -1, playerID, mainBaseLocation, closeRangeRadius);
                    if (kbUnitIsType(dropsiteUnitIDinCloseRange, cUnitTypeAbstractSettlement) == true)
                    {
                        //aiEcho("dropsiteUnitIDinCloseRange: "+dropsiteUnitIDinCloseRange+" is a cUnitTypeAbstractSettlement, skipping it!");
                        dropsiteUnitIDinCloseRange = -1;
                        continue;
                    }
                    //aiEcho("dropsiteUnitIDinCloseRange: "+dropsiteUnitIDinCloseRange);
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
    
    if (dropsiteUnitIDinCloseRange != -1)
    {
//        if ((currentPop <= currentPopCap - 9) || (currentPopCap < 115))
        if (currentPop <= currentPopCap - 9)
        {
            //aiEcho("returning as currentPop <= currentPopCap - 9");
            return;
        }
    }
    else
    {
//        if ((currentPop <= currentPopCap - 6) || (currentPopCap < 115))
        if (currentPop <= currentPopCap - 6)
        {
            //aiEcho("returning as currentPop <= currentPopCap - 6");
            return;
        }
        
        if (numEnemyMilUnitsNearMBInR80 > 8)
        {
            //aiEcho("returning as there are too many enemies near my main base");
            return;
        }
        
        int enemyPlayerID = aiGetMostHatedPlayerID();
        //aiEcho("enemyPlayerID is: "+enemyPlayerID);
    
        int numEnemyMarkets = kbUnitCount(enemyPlayerID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
        //aiEcho("numEnemyMarkets: "+numEnemyMarkets);

        if (kbGetCultureForPlayer(enemyPlayerID) == cCultureAtlantean)
            enemyEconUnit = cUnitTypeVillagerAtlantean;
        else
            enemyEconUnit = cUnitTypeDropsite;   

        int numEnemyDropsites = kbUnitCount(enemyPlayerID, enemyEconUnit, cUnitStateAliveOrBuilding);
        //aiEcho("numEnemyDropsites: "+numEnemyDropsites);
    

        if ((mapRestrictsMarketAttack() == false) && (numEnemyMarkets > 0) && ((numEnemyDropsites < 1) || (aiRandInt(5) < 2)))
        {
            for (j = 0; < numEnemyMarkets)
            {
                int enemyMarketUnitID = findUnitByIndex(cUnitTypeMarket, j, cUnitStateAliveOrBuilding, -1, enemyPlayerID);
                vector enemyMarketLocation = kbUnitGetPosition(enemyMarketUnitID);
                //aiEcho("enemyMarketLocation: "+enemyMarketLocation);
                //reduced radius from 55 to 40; TODO: check if it's OK
//                int numEnemyBuildingsAtMarketLocation = getNumUnitsByRel(cUnitTypeBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numEnemyBuildingsAtMarketLocation = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numEnemyTowersAtMarketLocation = getNumUnitsByRel(cUnitTypeTower, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numEnemyFortressesAtMarketLocation = getNumUnitsByRel(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numEnemySettlementsAtMarketLocation = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketLocation, 40.0);
                int numMotherNatureSettlementsAtMarketLocation = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, enemyMarketLocation, 40.0);
                numEnemySettlementsAtMarketLocation = numEnemySettlementsAtMarketLocation - numMotherNatureSettlementsAtMarketLocation;
                //aiEcho("numEnemySettlementsAtMarketLocation: "+numEnemySettlementsAtMarketLocation);
                //aiEcho("numEnemyBuildingsAtMarketLocation: "+numEnemyBuildingsAtMarketLocation);
                //aiEcho("numEnemyTowersAtMarketLocation: "+numEnemyTowersAtMarketLocation);
                if ((numEnemyBuildingsAtMarketLocation < 8) && (numEnemyTowersAtMarketLocation < 1) && (numEnemyFortressesAtMarketLocation < 1) && (numEnemySettlementsAtMarketLocation < 1))
                {
                    //aiEcho("only a few buildings at market location");
                    targetUnitID = enemyMarketUnitID;
                    targetIsMarket = true;
                    break;
                }
            }
        }
        else if ((numEnemyDropsites > 0) && (aiRandInt(5) < 4))
        {
            int enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(enemyPlayerID);
            //aiEcho("enemyMainBaseUnitID: "+enemyMainBaseUnitID+" for player: "+enemyPlayerID);
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
                //aiEcho("distanceToEnemyMainBase: "+distanceToEnemyMainBase);
//                if ((distanceToEnemyMainBase > 90.0) && (distanceToEnemyMainBase > distanceToSavedEnemyDropsiteUnitID))
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
                    //aiEcho("numEnemySettlementsAtDropsiteLocation: "+numEnemySettlementsAtDropsiteLocation);
                    if ((numEnemyMilitaryBuildingsAtDropsiteLocation < 3) && (numEnemyTowersAtDropsiteLocation < 1) && (numEnemyFortressesAtDropsiteLocation < 1) && (numEnemySettlementsAtDropsiteLocation < 1))
                    {
                        if ((lastTargetCount > 1) && (dropsiteUnitID == lastTargetUnitID))
                        {
                            //aiEcho("lastTargetCount > 1 and dropsiteUnitID == lastTargetUnitID, skipping dropsite!");
                            continue;
                        }
                        //aiEcho("only a few military buildings at dropsite location");
                        targetUnitID = dropsiteUnitID;
                        targetIsDropsite = true;
                        distanceToSavedEnemyDropsiteUnitID = distanceToEnemyMainBase;
//                        aiEcho("distanceToEnemyMainBase: "+distanceToEnemyMainBase+" > 80.0 and distanceToEnemyMainBase > distanceToSavedEnemyDropsiteUnitID: "+distanceToSavedEnemyDropsiteUnitID);
                        //aiEcho("distanceToEnemyMainBase: "+distanceToEnemyMainBase+" > 90.0 and distanceToEnemyMainBase > distanceToSavedEnemyDropsiteUnitID: "+distanceToSavedEnemyDropsiteUnitID);
                        //aiEcho("setting targetUnitID to "+targetUnitID);
                    }
                }
            }
        }
        else
        {
//            if ((equal(gRaidingPartyLastTargetLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
            if ((equal(gRaidingPartyLastTargetLocation, cInvalidVector) == false) && ((aiRandInt(2) < 1) || (kbGetCultureForPlayer(enemyPlayerID) == cCultureAtlantean)))
            {
//                int militaryUnit1ID = findUnitByIndex(cUnitTypeHumanSoldier, 0, cUnitStateAlive, cActionIdle);
                militaryUnit1ID = findUnitByIndex(cUnitTypeHumanSoldier, 0, cUnitStateAlive, cActionIdle);
                if (militaryUnit1ID > 0)
                {
                    aiTaskUnitMove(militaryUnit1ID, gRaidingPartyLastTargetLocation);
                    //aiEcho("Moving military unit1: "+militaryUnit1ID+" to gRaidingPartyLastTargetLocation: "+gRaidingPartyLastTargetLocation);
                }
                else
                {
                    //aiEcho("No idle military unit1 available");
                }
            }
            if ((equal(gRaidingPartyLastMarketLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
            {
                int militaryUnit2ID = findUnitByIndex(cUnitTypeHumanSoldier, 1, cUnitStateAlive, cActionIdle);
                if (militaryUnit2ID > 0)
                {
                    aiTaskUnitMove(militaryUnit2ID, gRaidingPartyLastMarketLocation);
                    //aiEcho("Moving military unit2: "+militaryUnit2ID+" to gRaidingPartyLastMarketLocation: "+gRaidingPartyLastMarketLocation);
                }
                else
                {
                    //aiEcho("No idle military unit2 available");
                }
            }
            return;
        }
    }
    
    if ((lastTargetCount > 1) && (dropsiteUnitIDinCloseRange != -1))
    {
        aiEcho("lastTargetCount > 1 and dropsiteUnitIDinCloseRange != -1, trying to send a military unit to check if the target still exists!");
        if ((equal(gRaidingPartyLastTargetLocation, cInvalidVector) == false) && (kbGetCultureForPlayer(playerID) == cCultureAtlantean))
        {
            militaryUnit1ID = findUnitByIndex(cUnitTypeHumanSoldier, 0, cUnitStateAlive, cActionIdle);
            if (militaryUnit1ID > 0)
            {
                aiTaskUnitMove(militaryUnit1ID, gRaidingPartyLastTargetLocation);
                aiEcho("Moving military unit1: "+militaryUnit1ID+" to gRaidingPartyLastTargetLocation: "+gRaidingPartyLastTargetLocation);
            }
            else
            {
                aiEcho("No idle military unit1 available");
            }
        }
    }
    
    if (targetUnitID < 0)
    {
        //aiEcho("no target as targetUnitID is: "+targetUnitID+", returning");
        return;
    }   
    
    int numSiegeUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeAbstractSiegeWeapon);  
    
    int raidingPartyAttackID = aiPlanCreate("Raiding Party", cPlanAttack);
    if (raidingPartyAttackID < 0)
        return;

    vector militaryGatherPoint = cInvalidVector;
//    if ((defPlanBaseID != mainBaseID) && (defPlanBaseID != -1))
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
    aiEcho("militaryGatherPoint: "+militaryGatherPoint);

    aiPlanSetVariableVector(raidingPartyAttackID, cAttackPlanGatherPoint, 0, militaryGatherPoint);
    aiPlanSetVariableFloat(raidingPartyAttackID, cAttackPlanGatherDistance, 0, 10.0);
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
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeToxotes, 1, 2, 2);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeHippikon, 1, 1, 1);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeHoplite, 1, 1, 1);
    }
    else if (cMyCulture == cCultureEgyptian)
    {
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeSlinger, 1, 2, 2);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeAxeman, 1, 1, 1);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeSpearman, 1, 1, 1);

    }
    else if (cMyCulture == cCultureNorse)
    {
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeThrowingAxeman, 1, 2, 2);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeRaidingCavalry, 1, 1, 1);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeUlfsark, 1, 1, 1);
    }
    else if (cMyCulture == cCultureAtlantean)
    {
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeJavelinCavalry, 1, 2, 2);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeMaceman, 1, 1, 1);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeSwordsman, 1, 1, 1);
    }
    
    if (targetIsMarket == true)
    {
        aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanRefreshFrequency, 0, 10);
        if (numSiegeUnitsIngDefendPlan > 1)
            aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
    }
    else
    {
        aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanRefreshFrequency, 0, 10);
    }
    
//    aiPlanSetInitialPosition(raidingPartyAttackID, mainBaseLocation);
//    aiPlanSetInitialPosition(raidingPartyAttackID, defPlanBaseLocation);
    aiPlanSetInitialPosition(raidingPartyAttackID, baseLocationToUse);

    if ((dropsiteUnitIDinCloseRange != -1) && (dropsiteUnitIDinCloseRange == targetUnitID))
        aiPlanSetDesiredPriority(raidingPartyAttackID, 44); //lower than most attack plans
    else
        aiPlanSetDesiredPriority(raidingPartyAttackID, 34); //lower than most attack plans
    aiPlanSetActive(raidingPartyAttackID);
    gRaidingPartyTargetUnitID = targetUnitID;
    gRaidingPartyAttackID = raidingPartyAttackID;
    aiEcho("Creating raiding party attack plan #: "+gRaidingPartyAttackID);
    if (targetIsMarket == true)
    {
        //aiEcho("Target is an enemy market, ID is: "+gRaidingPartyTargetUnitID);
        gRaidingPartyLastMarketLocation = kbUnitGetPosition(gRaidingPartyTargetUnitID);
        //aiEcho("gRaidingPartyLastMarketLocation: "+gRaidingPartyLastMarketLocation);
    }
    else
    {
        //aiEcho("Target is an enemy dropsite, ID is: "+gRaidingPartyTargetUnitID);
        gRaidingPartyLastTargetLocation = kbUnitGetPosition(gRaidingPartyTargetUnitID);
        //aiEcho("gRaidingPartyLastTargetLocation: "+gRaidingPartyLastTargetLocation);
    }
    attackPlanStartTime = xsGetTime();
    //aiEcho("attackPlanStartTime: "+attackPlanStartTime);
    
    if (lastTargetUnitID == gRaidingPartyTargetUnitID)
        lastTargetCount = lastTargetCount + 1;
    else
    {
        lastTargetUnitID = gRaidingPartyTargetUnitID;
        lastTargetCount = 0;
    }
    //aiEcho("lastTargetCount: "+lastTargetCount);
}

//==============================================================================
rule randomAttackGenerator
//    minInterval 43 //starts in cAge2
    minInterval 41 //starts in cAge2
    inactive
{
    //aiEcho("-----_____-----");
    aiEcho("******* randomAttackGenerator:");
   
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    
    static int attackPlanStartTime = -1;
    
    bool enemySettlementAttPlanActive = false;
    bool landAttackPlanActive = false;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    vector baseLocationToUse = mainBaseLocation;
    
    float closeRangeRadius = 110;    
    int numEnemySettlementsInCloseRange = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, mainBaseLocation, closeRangeRadius);
    //aiEcho("numEnemySettlementsInCloseRange: "+numEnemySettlementsInCloseRange);
    int numMotherNatureSettlementsInCloseRange = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, mainBaseLocation, closeRangeRadius);
    //aiEcho("numMotherNatureSettlementsInCloseRange: "+numMotherNatureSettlementsInCloseRange);
    numEnemySettlementsInCloseRange = numEnemySettlementsInCloseRange - numMotherNatureSettlementsInCloseRange;
    //aiEcho("modified numEnemySettlementsInCloseRange: "+numEnemySettlementsInCloseRange);
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
                //aiEcho("attackPlanID == gRandomAttackPlanID");
                if ((kbUnitGetCurrentHitpoints(gRandomAttackTargetUnitID) <= 0) && (gRandomAttackTargetUnitID != -1))
                {
                    aiPlanDestroy(attackPlanID);
                    gRandomAttackTargetUnitID = -1;
                    //aiEcho("destroying gRandomAttackPlanID as the target has been destroyed");
                    continue;
                }
                else if ((aiPlanGetState(attackPlanID) < cPlanStateAttack) && (((xsGetTime() > attackPlanStartTime + 4*60*1000) && (attackPlanStartTime != -1)) || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0)))
                {
                    aiPlanDestroy(attackPlanID);
                    gRandomAttackTargetUnitID = -1;
                    //aiEcho("destroying gRandomAttackPlanID as it has been active for more than 4 Minutes");
                    continue;
                }
                //aiEcho("returning");
                return;
            }
            else if (attackPlanID == gEnemySettlementAttPlanID)
            {
                if (aiPlanGetState(gEnemySettlementAttPlanID) < cPlanStateAttack)
                {
                    //aiEcho("there is a gEnemySettlementAttPlanID active and gathering units");
                    enemySettlementAttPlanActive = true;
                }
            }
            else if (attackPlanID == gLandAttackPlanID)
            {
                //aiEcho("there is a gLandAttackPlanID active");
                landAttackPlanActive = true;
            }
        }
    }
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);

    
    if ((woodSupply < 200) || (foodSupply < 200) || (goldSupply < 200))
    {
        //aiEcho("returning as we don't have enough resources");
        return;
    }
    

    if (numEnemySettlementsInCloseRange > 0)
    {
        //aiEcho("randomAttackGenerator: returning as there's an enemy Settlement in close range");
        return;
    }
    else if (numTitans > 0)
    {
        //aiEcho("randomAttackGenerator: returning as we have a Titan");
        return;
    }
    else if (numEnemyTitansNearMBInR85 > 0)
    {
        //aiEcho("randomAttackGenerator: returning as there's an enemy Titan near our main base");
        return;
    }
    else if (numEnemyTitansNearDefBInR55 > 0)
    {
        //aiEcho("randomAttackGenerator: returning as there's an enemy Titan near our defPlanbase");
        return;
    }
    else if (gEnemyWonderDefendPlan > 0)
    {
        //aiEcho("randomAttackGenerator: returning as there's a wonder attack plan open");
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
                //aiEcho("numEnemyDropsitesInCloseRange: "+numEnemyDropsitesInCloseRange);
                int dropsiteUnitIDinCloseRange = -1;
                if (numEnemyDropsitesInCloseRange > 0)
                {
                    index = aiRandInt(numEnemyDropsitesInCloseRange);
                    dropsiteUnitIDinCloseRange = findUnitByIndex(enemyEconUnit, index, cUnitStateAliveOrBuilding, -1, playerID, mainBaseLocation, closeRangeRadius);
                    //aiEcho("dropsiteUnitIDinCloseRange: "+dropsiteUnitIDinCloseRange);
                    targetIsDropsite = true;
                    gRandomAttackTargetUnitID = dropsiteUnitIDinCloseRange;
                    break;
                }
            }
        }
    }    
    

//    if ((numEnemyMilUnitsNearMBInR100 > 8) && (dropsiteUnitIDinCloseRange < 0))
    if ((numEnemyMilUnitsNearMBInR85 > 8) && (dropsiteUnitIDinCloseRange < 0))
    {
        //aiEcho("randomAttackGenerator: returning as there are too many enemies near our main base");
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
                //aiEcho("settlementPosDefPlanActive = true");
                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 15.0);
                int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 15.0, true);
            }
        }
    }
    
    
    int enemyPlayerID = aiGetMostHatedPlayerID();
    //aiEcho("enemyPlayerID is: "+enemyPlayerID);
    
    
    if (dropsiteUnitIDinCloseRange < 0)
    {
        int numEnemyMarkets = kbUnitCount(enemyPlayerID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
        //aiEcho("numEnemyMarkets: "+numEnemyMarkets);
    
        if (numEnemyMarkets > 0)
        {
            for (j = 0; < numEnemyMarkets)
            {
                int enemyMarketUnitID = findUnitByIndex(cUnitTypeMarket, j, cUnitStateAliveOrBuilding, -1, enemyPlayerID);
                vector enemyMarketPosition = kbUnitGetPosition(enemyMarketUnitID);
                //aiEcho("enemyMarketPosition: "+enemyMarketPosition);
                //reduced radius from 50 to 40; TODO: check if it's OK
//                int numEnemyBuildingsAtMarketLocation = getNumUnitsByRel(cUnitTypeBuilding, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketPosition, 40.0);
                int numEnemyBuildingsAtMarketLocation = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketPosition, 40.0);
                int numEnemyTowersAtMarketLocation = getNumUnitsByRel(cUnitTypeTower, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketPosition, 40.0);
                int numEnemyFortressesAtMarketLocation = getNumUnitsByRel(cUnitTypeAbstractFortress, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketPosition, 40.0);
                int numEnemySettlementsAtMarketLocation = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, enemyMarketPosition, 40.0);
                int numMotherNatureSettlementsAtMarketLocation = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, enemyMarketPosition, 40.0);
                numEnemySettlementsAtMarketLocation = numEnemySettlementsAtMarketLocation - numMotherNatureSettlementsAtMarketLocation;
                //aiEcho("numEnemySettlementsAtMarketLocation: "+numEnemySettlementsAtMarketLocation);
                //aiEcho("numEnemyBuildingsAtMarketLocation: "+numEnemyBuildingsAtMarketLocation);
                //aiEcho("numEnemyTowersAtMarketLocation: "+numEnemyTowersAtMarketLocation);
                if ((numEnemyBuildingsAtMarketLocation < 8) && (numEnemyTowersAtMarketLocation < 1) && (numEnemyFortressesAtMarketLocation < 1) && (numEnemySettlementsAtMarketLocation < 1))
                {
                    //aiEcho("only a few buildings at market location");
                    gRandomAttackTargetUnitID = enemyMarketUnitID;
                    targetIsMarket = true;
                    break;
                }
            }
        }
    }


//    if ((equal(gRandomAttackLastTargetLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
    if ((equal(gRandomAttackLastTargetLocation, cInvalidVector) == false) && ((aiRandInt(2) < 1) || (kbGetCultureForPlayer(playerID) == cCultureAtlantean)))
    {
        int militaryUnit1ID = findUnitByIndex(cUnitTypeHumanSoldier, 0, cUnitStateAlive, cActionIdle);
        if (militaryUnit1ID > 0)
        {
            aiTaskUnitMove(militaryUnit1ID, gRandomAttackLastTargetLocation);
            //aiEcho("Moving military unit1: "+militaryUnit1ID+" to gRandomAttackLastTargetLocation: "+gRandomAttackLastTargetLocation);
        }
        else
        {
            //aiEcho("No idle military unit1 available");
        }
    }
    
    if ((targetIsMarket == false) && (equal(gRandomAttackLastMarketLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
    {
        int militaryUnit2ID = findUnitByIndex(cUnitTypeHumanSoldier, 1, cUnitStateAlive, cActionIdle);
        if (militaryUnit2ID > 0)
        {
            aiTaskUnitMove(militaryUnit2ID, gRandomAttackLastMarketLocation);
            //aiEcho("Moving military unit2: "+militaryUnit2ID+" to gRandomAttackLastMarketLocation: "+gRandomAttackLastMarketLocation);
        }
        else
        {
            //aiEcho("No idle military unit2 available");
        }
    }

    if (landAttackPlanActive == true)
    {
        //aiEcho("returning as there is a gLandAttackPlanID active");
        return;
    }
    else if ((enemySettlementAttPlanActive == true) && (dropsiteUnitIDinCloseRange < 0) && (targetIsMarket == false))
    {
        //aiEcho("returning as there is a gEnemySettlementAttPlanID active and gathering units");
        return;
    }
    else if ((settlementPosDefPlanActive == true) && (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1))
    {
        //aiEcho("returning as there is a gSettlementPosDefPlanID active");
        return;
    }
    else if ((gRandomAttackTargetUnitID < 0) && (targetIsMarket == false))
    {
        //aiEcho("no target, returning");
        return;
    }   

    int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInMBDefPlan2 = aiPlanGetNumberUnits(gMBDefPlan2ID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numHumanSoldiersIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeHumanSoldier);
    int numHumanSoldiersInMBDefPlan2 = aiPlanGetNumberUnits(gMBDefPlan2ID, cUnitTypeHumanSoldier);
    int numHumanSoldiersInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeHumanSoldier);
    int numHumanSoldiersInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeHumanSoldier);
    int numMythUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
    
    //aiEcho("numMilUnitsIngDefendPlan: "+numMilUnitsIngDefendPlan);
    //aiEcho("numMilUnitsInBaseUnderAttackDefPlan: "+numMilUnitsInBaseUnderAttackDefPlan);
    //aiEcho("numMilUnitsInSettlementPosDefPlan: "+numMilUnitsInSettlementPosDefPlan);
    //aiEcho("numHumanSoldiersIngDefendPlan: "+numHumanSoldiersIngDefendPlan);
    //aiEcho("numHumanSoldiersInBaseUnderAttackDefPlan: "+numHumanSoldiersInBaseUnderAttackDefPlan);
    //aiEcho("numHumanSoldiersInSettlementPosDefPlan: "+numHumanSoldiersInSettlementPosDefPlan);
    int numMilUnitsInDefPlans = numMilUnitsIngDefendPlan + numMilUnitsInBaseUnderAttackDefPlan * 0.4 + numMilUnitsInSettlementPosDefPlan * 0.4;
    int numHumanSoldiersInDefPlans = numHumanSoldiersIngDefendPlan + numHumanSoldiersInBaseUnderAttackDefPlan * 0.4 + numHumanSoldiersInSettlementPosDefPlan * 0.4;
    if ((numMilUnitsInMBDefPlan2 > 3) && (numEnemyMilUnitsNearMBInR85 < 11) && (numEnemyTitansNearMBInR85 < 1))
    {
        numMilUnitsInDefPlans = numMilUnitsInDefPlans + numMilUnitsInMBDefPlan2 * 0.4;
        numHumanSoldiersInDefPlans = numHumanSoldiersInDefPlans + numHumanSoldiersInMBDefPlan2 * 0.4;
    }
    //aiEcho("total numMilUnitsInDefPlans: "+numMilUnitsInDefPlans);
    //aiEcho("total numHumanSoldiersInDefPlans: "+numHumanSoldiersInDefPlans);
    
    if ((dropsiteUnitIDinCloseRange > 0) || (targetIsMarket == true))
    {
        if (mapRestrictsMarketAttack() == true)
        {
            if (numMilUnitsInDefPlans < 20)
            {
                //aiEcho("returning as there are only "+numMilUnitsInDefPlans+" units in our defend plans and mapRestrictsMarketAttack == true.");
                return;
            }
        }
        else
        {
            if (numMilUnitsInDefPlans < 6)
            {
                //aiEcho("returning as there are only "+numMilUnitsInDefPlans+" units in our defend plans.");
                return;
            }
        }
    }
    else
    {
        return;
    }
    
    int numScouts = kbUnitCount(cMyID, cUnitTypeAbstractScout, cUnitStateAlive);
    
    int randomAttackPlanID = aiPlanCreate("randomAttackPlan", cPlanAttack);
    if (randomAttackPlanID < 0)
        return;
    
    vector militaryGatherPoint = cInvalidVector;
//    if ((defPlanBaseID != mainBaseID) && (defPlanBaseID != -1))
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
    aiEcho("militaryGatherPoint: "+militaryGatherPoint);
    
    aiPlanSetVariableVector(randomAttackPlanID, cAttackPlanGatherPoint, 0, militaryGatherPoint);
    aiPlanSetVariableFloat(randomAttackPlanID, cAttackPlanGatherDistance, 0, 10.0);
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
                
                if ((aiRandInt(2) < 1) || (numScouts < 2))
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
            
            if ((aiRandInt(2) < 1) || (numScouts < 2))
                aiPlanSetVariableBool(randomAttackPlanID, cAttackPlanAutoUseGPs, 0, false);
            else
                aiPlanSetVariableBool(randomAttackPlanID, cAttackPlanAutoUseGPs, 0, true);
        }
    }
    
//    aiPlanSetInitialPosition(randomAttackPlanID, mainBaseLocation);
//    aiPlanSetInitialPosition(randomAttackPlanID, defPlanBaseLocation);
    aiPlanSetInitialPosition(randomAttackPlanID, baseLocationToUse);
    aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanRefreshFrequency, 0, 10);

    aiPlanSetDesiredPriority(randomAttackPlanID, 50);
    
    aiPlanSetActive(randomAttackPlanID);
    gRandomAttackPlanID = randomAttackPlanID;
    aiEcho("Creating randomAttackPlan #: "+gRandomAttackPlanID);
    
    //aiEcho("----------");
    if (targetIsMarket == true)
    {
        //aiEcho("Target is an enemy market, ID is: "+gRandomAttackTargetUnitID);
        gRandomAttackLastMarketLocation = kbUnitGetPosition(gRandomAttackTargetUnitID);
        //aiEcho("gRandomAttackLastMarketLocation: "+gRandomAttackLastMarketLocation);
    }
    else if (targetIsDropsite == true)
    {
        //aiEcho("Target is an enemy dropsite, ID is: "+gRandomAttackTargetUnitID);
        gRandomAttackLastTargetLocation = kbUnitGetPosition(gRandomAttackTargetUnitID);
        //aiEcho("gRandomAttackLastTargetLocation: "+gRandomAttackLastTargetLocation);
    }
    
    attackPlanStartTime = xsGetTime();
    //aiEcho("attackPlanStartTime: "+attackPlanStartTime);
    //aiEcho("----------");
}

//==============================================================================
rule createLandAttack
    minInterval 53 //starts in cAge2
    inactive
{
    aiEcho("-----_____-----");
    aiEcho("******* createLandAttack:");
   
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
    aiEcho("numSiegeWeapons: "+numSiegeWeapons);
    aiEcho("numMilitaryMythUnits: "+numMilitaryMythUnits);
    
    int numEnemySettlements = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, kbGetMapCenter(), 2000.0);
    int numMotherNatureSettlements = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, kbGetMapCenter(), 2000.0);
    aiEcho("numEnemySettlements: "+numEnemySettlements);
    aiEcho("numMotherNatureSettlements: "+numMotherNatureSettlements);
    numEnemySettlements = numEnemySettlements - numMotherNatureSettlements;
    aiEcho("modified numEnemySettlements: "+numEnemySettlements);

    float closeRangeRadius = 110.0;
    int numEnemySettlementsInCloseRange = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, -1, cPlayerRelationEnemy, mainBaseLocation, closeRangeRadius);
    aiEcho("numEnemySettlementsInCloseRange: "+numEnemySettlementsInCloseRange);
    int numMotherNatureSettlementsInCloseRange = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, mainBaseLocation, closeRangeRadius);
    aiEcho("numMotherNatureSettlementsInCloseRange: "+numMotherNatureSettlementsInCloseRange);
    numEnemySettlementsInCloseRange = numEnemySettlementsInCloseRange - numMotherNatureSettlementsInCloseRange;
    aiEcho("modified numEnemySettlementsInCloseRange: "+numEnemySettlementsInCloseRange);
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
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
                aiEcho("attackPlanID == gLandAttackPlanID");

                if ((aiPlanGetState(attackPlanID) < cPlanStateAttack)
                 && (((xsGetTime() > attackPlanStartTime + 5*60*1000) && (attackPlanStartTime != -1))
                  || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 1)))
                {
                    aiPlanDestroy(attackPlanID);
                    aiEcho("destroying gLandAttackPlanID as it has been active for more than 4 Minutes");
                    continue;
                }
                aiEcho("returning");
                return;
            }
            else if (attackPlanID == gEnemySettlementAttPlanID)
            {
                aiEcho("there is a gEnemySettlementAttPlanID active");
                enemySettlementAttPlanActive = true;
            }
            else if (attackPlanID == gRandomAttackPlanID)
            {
                aiEcho("there is a gRandomAttackPlanID active");
                randomAttackPlanActive = true;
            }
        }
    }
    
    int enemyPlayerID = aiGetMostHatedPlayerID();
    int numTargetPlayerSettlements = kbUnitCount(enemyPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);

    
    int currentPop = kbGetPop();
    int currentPopCap = kbGetPopCap();

    if ((kbGetAge() < cAge3) || (gRushAttackCount < gRushCount))
    {
        if (gRushCount < 1)
        {
            aiEcho("returning as we don't want to rush");
            return;
        }
        else if (gRushAttackCount >= gRushCount)
        {
            aiEcho("returning as gRushAttackCount >= gRushCount");
            return;
        }
        else if ((woodSupply < 100) || (foodSupply < 100) || (goldSupply < 100))
        {
            aiEcho("returning as we don't have enough resources");
            return;
        }
    }
    else
    {
        if (((numMilitaryMythUnits > 1) || (numSiegeWeapons > 0)) && (numTargetPlayerSettlements > 0) && (aiRandInt(3) < 1))
        {
            aiEcho("returning as numMilitaryMythUnits > 1 or numSiegeWeapons > 0");
            return;
        }

        else if (((woodSupply < 230) || (foodSupply < 230) || (goldSupply < 230)) && (currentPop < currentPopCap))
        {
            aiEcho("returning as we don't have enough resources");
            return;
        }
    }
    

    if (numEnemySettlementsInCloseRange > 0)
    {
        aiEcho("createLandAttack: returning as there's an enemy Settlement in close range");
        return;
    }
    else if ((numTitans > 0) && (numTargetPlayerSettlements > 0))
    {
        aiEcho("createLandAttack: returning as we have a Titan and our target player still has settlements");
        return;
    }   
    else if (numEnemyTitansNearMBInR85 > 0)
    {
        aiEcho("createLandAttack: returning as there's an enemy Titan near our main base");
        return;
    }
    else if (numEnemyTitansNearDefBInR55 > 0)
    {
        aiEcho("createLandAttack: returning as there's an enemy Titan near our defPlanBase");
        return;
    }
    else if (gEnemyWonderDefendPlan > 0)
    {
        aiEcho("createLandAttack: returning as there's a wonder attack plan open");
        return;
    }
    else if (numEnemyMilUnitsNearMBInR80 > 10)
    {
        aiEcho("createLandAttack: returning as there are too many enemies near our main base");
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
                aiEcho("settlementPosDefPlanActive = true");
                vector defPlanDefPoint = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
                int myBaseAtDefPlanPosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cMyID, defPlanDefPoint, 15.0);
                int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 15.0, true);
            }
        }
    }
    
    if (enemySettlementAttPlanActive == true)
    {
        aiEcho("returning as there is a gEnemySettlementAttPlanID active");
        return;
    }
    else if ((randomAttackPlanActive == true) && (aiPlanGetState(attackPlanID) < cPlanStateAttack))
    {
        aiEcho("returning as there is a gRandomAttackPlanID active and gathering units");
        return;
    }
    else if ((randomAttackPlanActive == true) && (aiPlanGetNumberUnits(gRandomAttackPlanID, cUnitTypeLogicalTypeLandMilitary) > 4))
    {
        aiEcho("returning as there is a gRandomAttackPlanID active and there are more than 4 units in the plan");
        return;
    }
    else if ((settlementPosDefPlanActive == true) && ((kbGetAge() > cAge2) || (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1)))
    {
        aiEcho("returning as there is a gSettlementPosDefPlanID active");
        return;
    }
        
    int numMilUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInMBDefPlan2 = aiPlanGetNumberUnits(gMBDefPlan2ID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInBaseUnderAttackDefPlan = aiPlanGetNumberUnits(gBaseUnderAttackDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMilUnitsInSettlementPosDefPlan = aiPlanGetNumberUnits(gSettlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary);
    int numMythUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
    
    aiEcho("numMilUnitsIngDefendPlan: "+numMilUnitsIngDefendPlan);
    aiEcho("numMilUnitsInBaseUnderAttackDefPlan: "+numMilUnitsInBaseUnderAttackDefPlan);
    aiEcho("numMilUnitsInSettlementPosDefPlan: "+numMilUnitsInSettlementPosDefPlan);
    int numMilUnitsInDefPlans = numMilUnitsIngDefendPlan + numMilUnitsInBaseUnderAttackDefPlan * 0.4 + numMilUnitsInSettlementPosDefPlan * 0.4;
    if ((numMilUnitsInMBDefPlan2 > 3) && (numEnemyMilUnitsNearMBInR85 < 11) && (numEnemyTitansNearMBInR85 < 1))
    {
        numMilUnitsInDefPlans = numMilUnitsInDefPlans + numMilUnitsInMBDefPlan2 * 0.4;
    }
    aiEcho("total numMilUnitsInDefPlans: "+numMilUnitsInDefPlans);
    
    
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
//        if (currentPop <= currentPopCap - 3)
        if (currentPop <= currentPopCap - 4)
        {
//            aiEcho("returning as currentPop <= currentPopCap - 3");
            aiEcho("returning as currentPop <= currentPopCap - 4");
            return;
        }
    }
    
//    if (numMilUnitsInDefPlans < requiredUnits)
    if (numMilUnitsInDefPlans < requiredUnits * 0.8)
    {
        aiEcho("returning as there are only "+numMilUnitsInDefPlans+" units in our defend plans.");
        return;
    }
    
    
    int landAttackPlanID = aiPlanCreate("landAttackPlan", cPlanAttack);
    if (landAttackPlanID < 0)
        return;
    
    vector militaryGatherPoint = cInvalidVector;
//    if ((defPlanBaseID != mainBaseID) && (defPlanBaseID != -1))
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
    aiEcho("militaryGatherPoint: "+militaryGatherPoint);
    
    aiPlanSetVariableVector(landAttackPlanID, cAttackPlanGatherPoint, 0, militaryGatherPoint);
    aiPlanSetVariableFloat(landAttackPlanID, cAttackPlanGatherDistance, 0, 15.0);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanPlayerID, 0, enemyPlayerID);
    
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanAttackRoutePattern, 0, cAttackPlanAttackRoutePatternBest);
    aiPlanSetUnitStance(landAttackPlanID, cUnitStanceDefensive);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
    aiPlanSetRequiresAllNeedUnits(landAttackPlanID, false);

    if (numEnemySettlements < 1)
    {
        aiPlanAddUnitType(landAttackPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.5, numMilUnitsInDefPlans * 0.8, numMilUnitsInDefPlans * 0.8);
        aiPlanSetVariableInt(landAttackPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeNone);
    }
    else
    {
        aiPlanAddUnitType(landAttackPlanID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
        if (numRagnorokHeroes < 10)
            aiPlanAddUnitType(landAttackPlanID, cUnitTypeHero, 0, 1, 1);
        
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
            aiPlanAddUnitType(landAttackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
    
        if (kbGetAge() == cAge2)
            aiPlanAddUnitType(landAttackPlanID, cUnitTypeLogicalTypeLandMilitary, requiredUnits * 0.6, requiredUnits + 3, requiredUnits + 3);
        else
            aiPlanAddUnitType(landAttackPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans * 0.6, numMilUnitsInDefPlans * 0.9, numMilUnitsInDefPlans * 0.9); 
            
        aiPlanSetVariableInt(landAttackPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
    }
    
  //  if (gAge2MinorGod == cTechAge2Okeanus)
  //      aiPlanAddUnitType(landAttackPlanID, cUnitTypeFlyingMedic, 0, 1, 1);
    
//    aiPlanSetInitialPosition(landAttackPlanID, defPlanBaseLocation);
    aiPlanSetInitialPosition(landAttackPlanID, baseLocationToUse);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanRefreshFrequency, 0, 10);

    aiPlanSetVariableBool(landAttackPlanID, cAttackPlanAutoUseGPs, 0, false);
    
    aiPlanSetNumberVariableValues(landAttackPlanID, cAttackPlanTargetTypeID, 2, true);      
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetTypeID, 0, cUnitTypeUnit);
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetTypeID, 1, cUnitTypeBuilding);

    aiPlanSetDesiredPriority(landAttackPlanID, 50);
    
    aiPlanSetActive(landAttackPlanID);
    
    if (gRushAttackCount < gRushCount)
        gRushAttackCount = gRushAttackCount + 1;
    
    gLandAttackPlanID = landAttackPlanID;
    aiEcho("Creating landAttackPlan #: "+gLandAttackPlanID);

    attackPlanStartTime = xsGetTime();
    //aiEcho("attackPlanStartTime: "+attackPlanStartTime);
    aiEcho("----------");
}

//==============================================================================
rule setUnitPicker
//    minInterval 67 //starts in cAge2
    minInterval 103 //starts in cAge2
    inactive
{
    aiEcho("setUnitPicker:");

//    if (xsGetTime() < 16*60*1000)
    if (xsGetTime() < 15*60*1000)
        return;
    
    static bool rushUPupdate = false;
    static bool landUPupdate = false;
    
    if (rushUPupdate == false)
    {
        // increase the number of buildings of the rushUPID
        if ((cMyCulture == cCultureEgyptian) || (cMyCulture == cCultureNorse))
            kbUnitPickSetDesiredNumberUnitTypes(gRushUPID, 2, 3, true);  // 2 unit types and 3 buildings
        else
            kbUnitPickSetDesiredNumberUnitTypes(gRushUPID, 2, 2, true);  // 2 unit types and 2 buildings
        //aiEcho("------------");
        //aiEcho("increasing the number of buildings of the rushUPID");
        //aiEcho("------------");
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
                //aiEcho("------------");
                //aiEcho("increasing the number of buildings and units of the lateUPID");
                //aiEcho("------------");
                landUPupdate = true;
            }
        }
        
        if (kbGetTechStatus(cTechSecretsoftheTitans) > cTechStatusResearching)
        {
            // reset myth and siege preference to 1.0
            kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeMythUnit, 1.0);
            kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeAbstractSiegeWeapon, 1.0);
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
    minInterval 15 //starts in cAge2, activated in baseAttackTracker rule
    inactive
{
    aiEcho("___defendBaseUnderAttack: ");
    
    xsSetRuleMinIntervalSelf(17);
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    float distToMainBase = xsVectorLength(mainBaseLocation - gBaseUnderAttackLocation);
    
//    int numEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyTitansNearMBInR60 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 60.0, true);
    int numAttEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int myMilUnitsNearMBInR80 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 80.0);
   
    static int defendPlanStartTime = -1;
    
    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
    
    int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, gBaseUnderAttackLocation, 15.0, true);
    aiEcho("alliedBaseAtDefPlanPosition: "+alliedBaseAtDefPlanPosition);
    
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
                //aiEcho("gBaseUnderAttackDefPlanID exists: ID is "+defendPlanID);

//                if ((numEnemyTitansNearMBInR80 > 0) || (enemySettlementAtDefPlanPosition - numMotherNatureSettlementsAtDefPlanPosition > 0)
                if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0)
                 || (enemySettlementAtDefPlanPosition - numMotherNatureSettlementsAtDefPlanPosition > 0)
                 || ((numEnemyMilUnitsNearMBInR80 > 15) && (numEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 2.5)))
                {
                    aiPlanDestroy(defendPlanID);
//                    if (numEnemyTitansNearMBInR80 > 0)
                    if ((numEnemyTitansNearMBInR60 > 0) || (numAttEnemyTitansNearMBInR80 > 0))
                        aiEcho("destroying gBaseUnderAttackDefPlanID as there's an enemy Titan near our main base");
                    else if (enemySettlementAtDefPlanPosition - numMotherNatureSettlementsAtDefPlanPosition > 0)
                        aiEcho("destroying gBaseUnderAttackDefPlanID as there's an enemy settlement at our defend postion");
                    else
                        aiEcho("destroying gBaseUnderAttackDefPlanID as there are too many enemies near our main base");
                    gBaseUnderAttackDefPlanID = -1;
                    
                    aiPlanDestroy(gDefendPlanID);
                    gDefendPlanID = -1;
                    xsDisableRule("defendPlanRule");
                    aiEcho("destroying current gDefendPlanID and restarting defendPlanRule");
                    gBaseUnderAttackID = -1;
                    
                    xsSetRuleMinInterval("defendPlanRule", 8);
                    xsEnableRule("defendPlanRule");
                    
                    aiEcho("___");
                    xsSetRuleMinIntervalSelf(9);
                    xsDisableSelf();
                    return;
                }

                if ((alliedBaseAtDefPlanPosition > 0) || ((xsGetTime() > defendPlanStartTime + 3*60*1000) && (enemyMilUnitsInR50 < 3) && (numAttEnemySiegeInR50 < 1)))
                {
                    aiPlanDestroy(defendPlanID);
                    if (alliedBaseAtDefPlanPosition > 0)
                        aiEcho("destroying gBaseUnderAttackDefPlanID as an ally has built a base at our defend position");
                    else
                        aiEcho("destroying gBaseUnderAttackDefPlanID as it has been active for more than 3 Minutes and there are less than 3 enemies");
                    gBaseUnderAttackID = -1;
                    gBaseUnderAttackDefPlanID = -1;
                    aiEcho("___");
                    xsSetRuleMinIntervalSelf(9);
                    xsDisableSelf();
                    return;
                }
                
                if (defPlanBaseID != gBaseUnderAttackID)
                {
                    aiEcho("defPlanBaseID: "+defPlanBaseID+", gBaseUnderAttackID: "+gBaseUnderAttackID);
                    aiEcho("strange, defPlanBaseID != gBaseUnderAttackID, updating defPlanBaseID to gBaseUnderAttackID");
                    aiEcho("___");
                    aiPlanSetBaseID(defendPlanID, gBaseUnderAttackID);
                }
                //aiEcho("returning");
                //aiEcho("___");
                return;
            }
        }
    }
    
    if (gEnemyWonderDefendPlan > 0)
    {
        aiEcho("returning as there's a wonder attack plan open");
        return;
    }
    
    if (numMilUnits < 20)
    {
        aiEcho("returning as we only have "+numMilUnits+" military units");
        return;
    }
    
    aiEcho("gBaseUnderAttackLocation: "+gBaseUnderAttackLocation);
    int baseUnderAttackDefPlanID = aiPlanCreate("baseUnderAttackDefPlan", cPlanDefend);
    if (baseUnderAttackDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
//        aiPlanSetVariableInt(baseUnderAttackDefPlanID, cDefendPlanRefreshFrequency, 0, 5);
        aiPlanSetVariableInt(baseUnderAttackDefPlanID, cDefendPlanRefreshFrequency, 0, 10);
        
        aiPlanSetVariableVector(baseUnderAttackDefPlanID, cDefendPlanDefendPoint, 0, gBaseUnderAttackLocation);
        
        aiPlanSetVariableFloat(baseUnderAttackDefPlanID, cDefendPlanEngageRange, 0, 40.0);

//        aiPlanSetVariableFloat(baseUnderAttackDefPlanID, cDefendPlanGatherDistance, 0, 15.0);
        aiPlanSetVariableFloat(baseUnderAttackDefPlanID, cDefendPlanGatherDistance, 0, 20.0);

        aiPlanSetUnitStance(baseUnderAttackDefPlanID, cUnitStancePassive);
        aiPlanSetVariableBool(baseUnderAttackDefPlanID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(baseUnderAttackDefPlanID, cDefendPlanAttackTypeID, 2, true);
        aiPlanSetVariableInt(baseUnderAttackDefPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(baseUnderAttackDefPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);

//        if (distToMainBase < 85.0)
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
        
     //   if (gAge2MinorGod == cTechAge2Okeanus)
      //      aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeFlyingMedic, 0, 0, 1);
        
        //override
        if (enemyMilUnitsInR40 > 16)
            aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 8, enemyMilUnitsInR40 + 6, enemyMilUnitsInR40 + 6);
        
        aiPlanSetDesiredPriority(baseUnderAttackDefPlanID, 53);
        aiPlanSetBaseID(baseUnderAttackDefPlanID, gBaseUnderAttackID);
        aiPlanSetActive(baseUnderAttackDefPlanID);
        gBaseUnderAttackDefPlanID = baseUnderAttackDefPlanID;
        aiEcho("baseUnderAttackDefPlanID set active: "+gBaseUnderAttackDefPlanID);
        aiEcho("___");
        xsSetRuleMinIntervalSelf(17);
    }
}

//==============================================================================
rule defendAlliedBase   //TODO: check all allied bases not just the main base of each ally
//    minInterval 53 //starts in cAge2
    minInterval 89 //starts in cAge2
    inactive
{
 
 if (mCanIDefendAllies == false)
 {
	xsDisableSelf();
	return;
 }   
    aiEcho("........defendAlliedBase: ");
 
 
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
                aiEcho("numEnemyTitansInR70 > 0 or numEnemyMilUnitsInR70 > alliedMilUnitsInR70, using alliedBaseUnitID: "+alliedBaseUnitID);
                break;
            }
            else
                alliedBaseUnitID = -1;
        }
    }    
    
   
    static int defendPlanStartTime = -1;
    int numMilUnits = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
    
    int alliedBaseAtDefPlanPosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationAlly, alliedBaseLocation, 15.0, true);
    aiEcho("alliedBaseAtDefPlanPosition: "+alliedBaseAtDefPlanPosition);

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
                aiEcho("gAlliedBaseDefPlanID exists: ID is "+defendPlanID);

                if (enemySettlementAtDefPointPosition - numMotherNatureSettlementsAtDefPointPosition > 0)
                {
                    aiPlanDestroy(defendPlanID);
                    aiEcho("destroying gAlliedBaseDefPlanID as there's an enemy settlement at the allied base position");
                    gAlliedBaseDefPlanID = -1;
                    aiEcho("___");
                    count = 0;
                    return;
                }

                if ((numEnemyTitansNearDefPointInR70 < 1) && (numEnemyMilUnitsNearDefPointInR70 < alliedMilUnitsNearDefPointInR70))
                {
                    if (count > 1)
                    {
                        aiPlanDestroy(defendPlanID);
                        aiEcho("destroying gAlliedBaseDefPlanID as there are no enemy Titans and there are less enemies than allies");
                        gAlliedBaseDefPlanID = -1;
                        aiEcho("___");
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
                //aiEcho("returning");
                //aiEcho("___");
                return;
            }
        }
    }
    
    if (alliedBaseUnitID == -1)
    {
        aiEcho("returning as alliedBaseUnitID == -1");
        return;
    }
    
    if (enemySettlementAtAlliedBasePosition - numMotherNatureSettlementsAtAlliedBasePosition > 0)
    {
        aiEcho("returning as there's an enemy settlement at the allied base position");
        return;
    }
    
    if (gEnemyWonderDefendPlan > 0)
    {
        aiEcho("returning as there's a wonder attack plan open");
        return;
    }
    
    if (numMilUnits < 20)
    {
        aiEcho("returning as we only have "+numMilUnits+" military units");
        return;
    }
    
    aiEcho("alliedBaseLocation: "+alliedBaseLocation);
    int alliedBaseDefPlanID = aiPlanCreate("alliedBaseDefPlanID", cPlanDefend);
    if (alliedBaseDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
        aiPlanSetVariableInt(alliedBaseDefPlanID, cDefendPlanRefreshFrequency, 0, 10);
        
        aiPlanSetVariableVector(alliedBaseDefPlanID, cDefendPlanDefendPoint, 0, alliedBaseLocation);
        
        aiPlanSetVariableFloat(alliedBaseDefPlanID, cDefendPlanEngageRange, 0, 70.0);

        aiPlanSetVariableFloat(alliedBaseDefPlanID, cDefendPlanGatherDistance, 0, 15.0);

        aiPlanSetUnitStance(alliedBaseDefPlanID, cUnitStancePassive);
        aiPlanSetVariableBool(alliedBaseDefPlanID, cDefendPlanPatrol, 0, false);

        aiPlanSetNumberVariableValues(alliedBaseDefPlanID, cDefendPlanAttackTypeID, 2, true);
        aiPlanSetVariableInt(alliedBaseDefPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeMilitary);
        aiPlanSetVariableInt(alliedBaseDefPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeMilitaryBuilding);

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
        aiEcho("alliedBaseDefPlanID set active: "+gAlliedBaseDefPlanID);
        aiEcho("___");
    }
}

//==============================================================================
rule tacticalBuildings
//    minInterval 23 //starts in cAge1
    minInterval 103 //starts in cAge1, is set to 11 in cAge2
    inactive
{
    //aiEcho("---___---___---");
    aiEcho("tacticalBuildings:");

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
    //aiEcho("numAttBuildings: "+numAttBuildings);
    int max = 16;
    if (cMyCulture == cCultureAtlantean)
        max = 9;
    if (numAttBuildings > max)
        numAttBuildings = max;
    if (numAttBuildings < 1)
    {
        //aiEcho("There are no attacking buildings, returning");
        //aiEcho("---___---___---");
        return;
    }
    for (i = 0; < numAttBuildings)
    {
        int attBuildingID = findUnitByIndex(cUnitTypeBuildingsThatShoot, i, cUnitStateAlive, cActionRangedAttack, cMyID);
        if (attBuildingID == -1)
            continue;
        
        //aiEcho("attBuildingID: "+attBuildingID);
        
        int currentTargetID = kbUnitGetTargetUnitID(attBuildingID);
        //aiEcho("currentTargetID: "+currentTargetID);
        if (kbUnitIsType(currentTargetID, cUnitTypeHumanSoldier) == true)
        {
            //aiEcho("currentTargetID: "+currentTargetID+" is a cUnitTypeHumanSoldier, no need to change targets");
            //aiEcho("---___---___---");
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
        //aiEcho("numEnemyHumanSoldiersInR: "+numEnemyHumanSoldiersInR);
        //aiEcho("numEnemyVillagersInR: "+numEnemyVillagersInR);
        
        if (numEnemyHumanSoldiersInR < 1)
        {
            if (numEnemyVillagersInR > 0)
            {
                int enemyVillagerUnitID = findUnitByRel(cUnitTypeAbstractVillager, cUnitStateAlive, -1, cPlayerRelationEnemy, buildingPosition, radius, true);
                if (enemyVillagerUnitID != -1)
                {
                    //aiEcho("tasking building: "+attBuildingID+" to attack enemyVillagerUnitID: "+enemyVillagerUnitID);
                    //aiEcho("---___---___---");
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
                //aiEcho("tasking building: "+attBuildingID+" to attack enemyHumanSoldierID: "+enemyHumanSoldierID);
                //aiEcho("---___---___---");
                aiTaskUnitWork(attBuildingID, enemyHumanSoldierID);
                continue;
            }
        }
    }   
}

//==============================================================================
// tacticalSiegeAttackBuildings
//==============================================================================
rule tacticalSiege
   minInterval 5
   active
{
   static int unitQueryID=-1;
   static int enemyQueryID=-1;

   if (aiGetWorldDifficulty() == cDifficultyEasy)
   {
	xsDisableSelf();
	return;
   }

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
   unitQueryID=kbUnitQueryCreate("My Siege Query");
   
   //Define a query to get all matching units
   if (unitQueryID != -1)
   {
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
		// Don't want Norse Ballista to attack buildings.
			kbUnitQuerySetUnitType(unitQueryID, cUnitTypeAbstractSiegeWeapon);			
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
		kbUnitQuerySetMaximumDistance(enemyQueryID, 34);
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
rule tacticalTitan
    minInterval 11 //starts in cAge5, activated in repairTitanGate
    inactive
{
    //aiEcho("---___---___---");
    aiEcho("tacticalTitan:");
    
    static bool titanCreated = false;
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    if (titanCreated == false)
    {
        if (numTitans > 0)
        {
            titanCreated = true;
            //aiEcho("we've just created a Titan, setting titanCreated to true");
        }
        else
        {
            //aiEcho("no Titan yet, returning");
            //aiEcho("---___---___---");
            return;
        }
    }    
    
    int titanID = findUnit(cUnitTypeAbstractTitan);
    if (titanID == -1)
    {
        //aiEcho("Our Titan has been killed, disabling tacticalTitan rule");
        //aiEcho("---___---___---");
        xsDisableSelf();
        return;
    }
    
    vector titanPosition = kbUnitGetPosition(titanID);
    int myMilUnitsInR20 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, titanPosition, 20.0);
        
    int numEnemyTitansInR10 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, titanPosition, 10.0, true);
    //aiEcho("numEnemyTitansInR10: "+numEnemyTitansInR10);
    int numAttEnemyMilUnitsInR10 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 10.0, true);
    //aiEcho("numAttEnemyMilUnitsInR10: "+numAttEnemyMilUnitsInR10);
    
    int currentTargetID = kbUnitGetTargetUnitID(titanID);
    //aiEcho("currentTargetID: "+currentTargetID);
    
    int planID = kbUnitGetPlanID(titanID);
    vector defPlanDefPoint = aiPlanGetVariableVector(planID, cDefendPlanDefendPoint, 0);
    //aiEcho("defPlanDefPoint: "+defPlanDefPoint);
    if (equal(defPlanDefPoint, cInvalidVector) == false)
    {
        float defPlanEngageRange = aiPlanGetVariableFloat(planID, cDefendPlanEngageRange, 0);
        //aiEcho("defPlanEngageRange: "+defPlanEngageRange);
        float distanceToDefPoint = xsVectorLength(titanPosition - defPlanDefPoint);
        //aiEcho("distanceToDefPoint: "+distanceToDefPoint);
        if (distanceToDefPoint > defPlanEngageRange - 1.0)
        {
            float minDistance = 5.0 + distanceToDefPoint - defPlanEngageRange;
            if (minDistance < 10.0)
                minDistance = 10.0;
            float multiplier = minDistance / distanceToDefPoint;
            //aiEcho("multiplier: "+multiplier);
            vector directionalVector = titanPosition - defPlanDefPoint;
            //aiEcho("directionalVector: "+directionalVector);
            vector desiredPosition = titanPosition - directionalVector * multiplier;
            //aiEcho("desiredPosition: "+desiredPosition);
            
//            if (numAttEnemyMilUnitsInR10 < 5)
            if ((numAttEnemyMilUnitsInR10 < 5) || (myMilUnitsInR20 < 5))
            {
                //aiEcho("moving Titan back to desiredPosition");
                //aiEcho("---___---___---");
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
                //aiEcho("tasking Titan to attack attPlanTargetID: "+attPlanTargetID);
                //aiEcho("---___---___---");
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
        //aiEcho("currentTargetID: "+currentTargetID+" is a human soldier, a myth unit, a Titan, or a building that shoots, no need to change targets");
        //aiEcho("---___---___---");
        return;
    }
    
    int numAttEnemyHumanSoldiersInR8 = getNumUnitsByRel(cUnitTypeHumanSoldier, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 8.0, true);
    //aiEcho("numAttEnemyHumanSoldiersInR8: "+numAttEnemyHumanSoldiersInR8);
    int numAttEnemyArchersInR20 = getNumUnitsByRel(cUnitTypeAbstractArcher, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 20.0, true);
    //aiEcho("numAttEnemyArchersInR20: "+numAttEnemyArchersInR20);
    int numEnemyMythUnitsInR8 = getNumUnitsByRel(cUnitTypeLogicalTypeMythUnitNotTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, titanPosition, 8.0, true);
    //aiEcho("numEnemyMythUnitsInR8: "+numEnemyMythUnitsInR8);
    int numEnemyBuildingsThatShootInR20 = getNumUnitsByRel(cUnitTypeBuildingsThatShoot, cUnitStateAlive, -1, cPlayerRelationEnemy, titanPosition, 20.0, true);
    //aiEcho("numEnemyBuildingsThatShootInR20: "+numEnemyBuildingsThatShootInR20);    

    
    if (numAttEnemyHumanSoldiersInR8 < 4)
    {
        if (numEnemyMythUnitsInR8 > 0)
        {
            int enemyMythUnitID = findUnitByRelByIndex(cUnitTypeLogicalTypeMythUnitNotTitan, 0, cUnitStateAlive, -1, cPlayerRelationEnemy, titanPosition, 8.0, true);
            if (enemyMythUnitID != -1)
            {
                //aiEcho("tasking Titan to attack enemyMythUnitID: "+enemyMythUnitID);
                //aiEcho("---___---___---");
                aiTaskUnitWork(titanID, enemyMythUnitID);
                return;
            }
        }
        else if (numAttEnemyArchersInR20 > 4)
        {
            int attEnemyArcherID = findUnitByRelByIndex(cUnitTypeAbstractArcher, 0, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, titanPosition, 20.0, true);
            if (attEnemyArcherID != -1)
            {
                //aiEcho("tasking Titan to attack attEnemyArcherID: "+attEnemyArcherID);
                //aiEcho("---___---___---");
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
            //aiEcho("tasking Titan to attack attEnemyHumanSoldierID: "+attEnemyHumanSoldierID);
            //aiEcho("---___---___---");
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
    aiEcho("---------------------------------------");
    aiEcho("baseAttackTracker:");

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
                aiEcho("baseID for attack tracking is "+otherBaseID);	
                aiEcho("secondsUnderAttack: "+secondsUnderAttack+" for base ID: "+otherBaseID);
                aiEcho("enemyMilUnitsInR50: "+enemyMilUnitsInR50);
                aiEcho("enemyMilUnitsInR45: "+enemyMilUnitsInR45);
                aiEcho("myMilUnitsInR45: "+myMilUnitsInR45);
                aiEcho("distanceToMainBase: "+distanceToMainBase);
                
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
//                if ((otherBaseID != mainBaseID) && (distanceToMainBase > 65.0) 
                if ((otherBaseID != mainBaseID) && (distanceToMainBase > 60.0) && (BUADefPlanActivated == false)
                 && ((equal(aiPlanGetVariableVector(gBaseUnderAttackDefPlanID, cDefendPlanDefendPoint, 0), gBaseUnderAttackLocation) == false)
                  || (gBaseUnderAttackDefPlanID == -1)))
                {
                    xsSetRuleMinInterval("defendBaseUnderAttack", 9);
                    xsDisableRule("defendBaseUnderAttack");
                    aiPlanDestroy(gBaseUnderAttackDefPlanID);
                    gBaseUnderAttackDefPlanID = -1;
                    aiEcho("destroying gBaseUnderAttackDefPlanID");
                    gBaseUnderAttackLocation = otherBaseLocation;
                    gBaseUnderAttackID = otherBaseID;
                    xsEnableRule("defendBaseUnderAttack");
        
                    aiPlanDestroy(gDefendPlanID);
                    gDefendPlanID = -1;
                    xsDisableRule("defendPlanRule");
                    aiEcho("destroying current gDefendPlanID and restarting defendPlanRule");
                    xsSetRuleMinInterval("defendPlanRule", 8);
                    xsEnableRule("defendPlanRule");
        
//                    aiEcho("otherBaseID != mainBaseID and distanceToMainBase > 65.0, enabling defendBaseUnderAttack rule");
                    aiEcho("otherBaseID != mainBaseID and distanceToMainBase > 60.0, enabling defendBaseUnderAttack rule");
//                    break;
                    BUADefPlanActivated = true;
                }
                else
                {
                    if (BUADefPlanActivated == true)
                        aiEcho("BUADefPlanActivated = true, can't activate another one");
                    else
                        aiEcho("Don't need a defend plan for otherBaseID: "+otherBaseID);
                }
            }
        }
    }
}



//==============================================================================
/* TODO: create a new attack plan against:

cUnitTypeShadeofErebus
cUnitTypeSerpent
cUnitTypeAnimalPredator

or better against military units of player 0 (=mother nature)
*/
