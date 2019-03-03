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
    xsSetRuleMinIntervalSelf(11);
	static int HelpTimer = -1;
    if (HelpTimer == -1)
    HelpTimer = xsGetTime();
	static int ResourceTimer = -1;
    if (ResourceTimer == -1)
    ResourceTimer = xsGetTime();	
	
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
            int enemyMilUnitsInR50 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int enemyMilUnitsInR80 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 85.0, true);
            
            int numAttEnemyMilUnitsInR50 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            int numAttEnemyMilUnitsInR80 = getNumUnitsByRel(militaryUnitType, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 85.0, true);
			
            int numAttEnemySiegeInR50 = getNumUnitsByRel(cUnitTypeAbstractSiegeWeapon, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, defPlanDefPoint, 50.0, true);
            
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
					{
						if (kbGetAge() == cAge2)
						aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 8, 8);
						else 
						aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 1);
					}					
					
                    
                    if ((secondsUnderAttack > 0) || (enemyMilUnitsInR80 > 8))
					aiPlanSetDesiredPriority(defendPlanID, 54);
                    else
                    {
						aiPlanSetDesiredPriority(defendPlanID, 38); //TODO: find the best value
					}
                    
                    //override if there is an enemy Titan near our main base
                    if (numEnemyTitansNearMBInR80 > 0)
					aiPlanSetDesiredPriority(defendPlanID, 60);
				}
				
				if ((AoModAllies == true) && (secondsUnderAttack > 20) && 
                (enemyMilUnitsInR80 > numMilUnitsInDefPlan * 1.20))
                {
					if (xsGetTime() - ResourceTimer > 1*20*1000)
					{
						//Ask for resources too!
						if (kbResourceGet(cResourceFood) < 250)
						{
							MessageRel(cPlayerRelationAlly, RequestFood);
							if (ShowAIComms == true) aiEcho("Low on Food and under attack.. Requesting Food!");
						}
						if (kbResourceGet(cResourceWood) < 200)
						{
							MessageRel(cPlayerRelationAlly, RequestWood);
							if (ShowAIComms == true) aiEcho("Low on Wood and under attack.. Requesting Wood!");
						}
						if (kbResourceGet(cResourceGold) < 250)
						{
							MessageRel(cPlayerRelationAlly, RequestGold);
							if (ShowAIComms == true) aiEcho("Low on Gold and under attack.. Requesting Gold!");
						}
						ResourceTimer = xsGetTime();
					}
					
					if (xsGetTime() - HelpTimer > 2*60*1000)
					{
						vector TCLoc = aiPlanGetVariableVector(defendPlanID, cDefendPlanDefendPoint, 0);
						int TCID = findClosestUnitTypeByLoc(cPlayerRelationSelf, cUnitTypeAbstractSettlement, TCLoc, 30);
						if (TCID != -1)
						{
							HelpTimer = xsGetTime();
							MessageRel(cPlayerRelationAlly, INeedHelp, TCID);
							if (ShowAIComms == true) aiEcho("Requesting Help at TC ID: "+TCID);
							vector TowerLocation=kbBaseGetLastKnownDamageLocation(cMyID, defPlanBaseID);
							if ((equal(TowerLocation, cInvalidVector) == false) && (defPlanBaseID == mainBaseID))
							MessageRel(cPlayerRelationAlly, RequestTower, VectorData, TowerLocation);
						}
					}
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
					if ((secondsUnderAttack > 0) || (numMilUnitsInDefPlan < enemyMilUnitsInR50))
					{
						aiPlanSetDesiredPriority(defendPlanID, 56);
						if ((numAttEnemyMilUnitsInR50 > 4) || (numAttEnemySiegeInR50 > 0) || (numAttEnemyTitansInR50 > 0))
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
				
				aiPlanSetVariableFloat(defendPlanID, cDefendPlanEngageRange, 0, 48.0);  //just a little less, keepUnitsWithinRange will pull them farther back
				keepUnitsWithinRange(defendPlanID, defPlanDefPoint);
				int NumEnemyBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 55.0, true);	
				int priorityA = 48;
				if (distToMainBase > 90.0)
				priorityA = 52;
				static int countA = 0;
				static int resourceCountA = 0; // add more
				if ((enemyMilUnitsInR50 < 4) && (numAttEnemySiegeInR50 < 1) && (numAttEnemyTitansInR50 < 1))
				{
					if (countA <= 14)
					{
						if ((distToMainBase < 85.0) && (NumEnemyBuildings > 6))
						aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 12, 19, 19);
						else
						{
							if ((distToMainBase > 100.0) && (NumEnemyBuildings > 6))
							aiPlanAddUnitType(defendPlanID, cUnitTypeLogicalTypeLandMilitary, 11, 22, 24);
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
				if ((enemyMilUnitsInR50 < 6) && (numAttEnemySiegeInR50 - numAttEnemySiegeInR50 < 1) && (numAttEnemyTitansInR50 < 1))
				{
					if (countB <= 7)
					{
						aiPlanAddUnitType(defendPlanID, cUnitTypeHumanSoldier, 4, 16, 18);
						
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
					if (enemyMilUnitsInR50 > 16)
					aiPlanAddUnitType(defendPlanID, cUnitTypeHumanSoldier, 8, enemyMilUnitsInR50 + 6, enemyMilUnitsInR50 + 6);
					
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
			int NumVar = aiPlanGetNumberUserVariableValues(attackPlanID, 0);
			int SpecialNum = aiPlanGetUserVariableInt(attackPlanID, 0, 0);
			int	TimeActive = aiPlanGetUserVariableInt(attackPlanID, 0, 1);
            
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
                        if ((aiPlanGetNoMoreUnits(attackPlanID) == true) && (numMilUnitsInPlan < 3) || (numAttEnemyTitansNearMBInR85 > 0) || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 2) && (planState < cPlanStateAttack) 
						|| (gTransportMap == true) && (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 0))
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
							if ((numMilUnitsInPlan < 3) || (aiPlanGetVariableInt(attackPlanID, cAttackPlanNumberAttacks, 0) > 2) && (planState < cPlanStateAttack) 
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
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
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
                        if ((numEnemyMilUnitsNearMBInR70 > 14) || (numEnemyMilUnitsNearDefBInR40 > 14) && (attPlanPriority <= 20))
                        {
                            aiPlanDestroy(attackPlanID);
                            if (ShowAiEcho == true) aiEcho ("destroying gEnemySettlementAttPlanID as there are too many enemies");
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
                        if ((distanceToTarget > 110.0) && (numMilUnitsInPlan < 3))
                        {
                            aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                            aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
                            killSettlementAttPlanCount = 0;
						}
                        else if ((numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan) 
						&& (numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.3) && (aiPlanGetNoMoreUnits(attackPlanID) == true)
						&& (numMilUnitsInPlan < 3))
                        {
                            aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                            aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);                            
                            pullBackUnits(attackPlanID, attPlanRetreatPosition);
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
                        if ((numEnemyMilUnitsNearMBInR70 > 11) || (numEnemyMilUnitsNearDefBInR40 > 9) && (attPlanPriority < 20))
                        {
                            aiPlanDestroy(attackPlanID);
                            if (ShowAiEcho == true) aiEcho ("destroying gRandomAttackPlanID as there are too many enemies");
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
                    if (numMilUnitsInPlan < 3)
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killRandomAttPlanCount = 0;
                        if (ShowAiEcho == true) aiEcho ("Destroying gRandomAttackPlanID as less than 3 units in the plan");
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
                    if ((numMilUnitsNearAttPlan >= numMilUnitsInPlan * 0.5) && (numMilUnitsInPlan < 3) && (numEnemyBuildingsThatShootNearAttPlanInR25 > 0)
					|| (numEnemyMilUnitsNearAttPlan > numMilUnitsNearAttPlan + numAlliedMilUnitsNearAttPlan) && (numMilUnitsInPlan < 3))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        killRaidAttPlanCount = 0;
					}
                    continue;
				}
			}
            else if (attackPlanID == gEnemyWonderDefendPlan)
            {
		        int numUnitsInPlan = aiPlanGetNumberUnits(gEnemyWonderDefendPlan, cUnitTypeUnit);
		        //aiEcho("Number in plan: "+numUnitsInPlan);
                if (planState < cPlanStateAttack)
                {
                    if (aiPlanGetVariableInt(attackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime() - 10*1000))
                    {
                        if (aiPlanGetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0) != 400.0)
						aiPlanSetVariableFloat(attackPlanID, cAttackPlanGatherDistance, 0, 400.0);
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
                        pullBackUnits(attackPlanID, attPlanRetreatPosition);
                        if ((killLandAttPlanCount >= 4) || (attPlanDistance < 25.0))
                        {
                            aiPlanDestroy(attackPlanID);
                            killLandAttPlanCount = -1;
							if (ShowAiEcho == true) aiEcho("Killing gLandAttackPlanID, Count >=4");
                            continue;
						}
                        killLandAttPlanCount = killLandAttPlanCount + 1;
					    if (numMilUnitsInPlan < 3)
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
                            if (((numEnemyMilUnitsNearMBInR70 > 20) || (numEnemyMilUnitsNearDefBInR40 > 20)) && (attPlanPriority < 20))
                            {
                                aiPlanDestroy(attackPlanID);
                                if (ShowAiEcho == true) aiEcho ("destroying gLandAttackPlanID as there are too many enemies 1");
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
                    if ((kbGetAge() >= cAge2) && (numMilUnitsInPlan < 3))
                    {
                        aiPlanSetVariableInt(attackPlanID, cAttackPlanRefreshFrequency, 0, 60);
                        aiPlanSetUnitStance(attackPlanID, cUnitStanceDefensive);
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
    
    xsSetRuleMinIntervalSelf(27);
    static int defendCount = 0;      // For plan numbering
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    static int defendPlanStartTime = -1;
	
    int numAttEnemyMilUnitsNearMBInR60 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 110.0, true);
    int numAttEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numEnemyTitansNearMBInR80 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int myMilUnitsNearMBInR80 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, mainBaseLocation, 80.0);
	
    int baseToUse = mainBaseID;
    if ((gBaseUnderAttackID != -1) && (equal(gBaseUnderAttackLocation, cInvalidVector) == false) && (numAttEnemyMilUnitsNearMBInR60 < 7))
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
					|| ((numAttEnemyMilUnitsNearMBInR80 > 10) && (numAttEnemyMilUnitsNearMBInR80 > myMilUnitsNearMBInR80 * 1.3)))
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
    return;
	
	if (gTransportMap == true)
    baseToUse = mainBaseID;
    int defPlanID = createDefOrAttackPlan("Defend plan #"+defendCount, true, 80, 30, kbBaseGetLocation(cMyID, baseToUse), baseToUse, 20, false);
    if (defPlanID != -1)
    {
        defendCount = defendCount + 1;
        aiPlanAddUnitType(defPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 200, 200); 
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
    if (gObeliskClearingPlanID < 0)
    {
		gObeliskClearingPlanID = createDefOrAttackPlan("Obelisk plan #"+obeliskPlanCount, true, 110, 25, kbBaseGetLocation(cMyID, mainBaseID), mainBaseID, 16, false);
        if (gObeliskClearingPlanID < 0)
		return;
	    obeliskPlanCount = obeliskPlanCount + 1;
        aiPlanSetNumberVariableValues(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 2, true);
		aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeLogicalTypeIdleCivilian);
        aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeOutpost);	
        
        if (cMyCulture == cCultureChinese)
		aiPlanAddUnitType(gObeliskClearingPlanID, cUnitTypeScoutChinese, 1, 1, 1);
		else 
        aiPlanAddUnitType(gObeliskClearingPlanID, cUnitTypeAbstractInfantry, 1, 1, 1);
        aiPlanSetActive(gObeliskClearingPlanID);
	}
	if (gObeliskClearingPlanID != -1)
	aiPlanSetVariableVector(gObeliskClearingPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
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
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeCamelry, 0.8);
	kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeChariotArcher, 1.0);
    if (gAge4MinorGod == cTechAge4Thoth)		
    kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeWarElephant, 0.7);
	else    
	kbUnitPickSetPreferenceFactor(gLateUPID, cUnitTypeWarElephant, 0.4);
	
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
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	
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
				int numEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
				if (numEnemyMilUnitsNearMBInR85 < 4)
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
			    aiPlanSetVariableVector(gMBDefPlan1ID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
			    aiPlanSetVariableFloat(gMBDefPlan1ID, cDefendPlanGatherDistance, 0, 25.0);
                if (ShowAiEcho == true) aiEcho("mainBaseDefPlan1 exists: ID is "+defendPlanID);
                return;
			}
		}
	}
	
    int mainBaseDefPlan1ID = createDefOrAttackPlan("mainBaseDefPlan1", true, 50, 25, kbBaseGetLocation(cMyID, mainBaseID), mainBaseID, 40, false);
    if (mainBaseDefPlan1ID != -1)
    {
        if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
		aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
		
		if (gAge2MinorGod == cTechAge2Okeanus)
		aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeFlyingMedic, 1, 1, 1);
	    aiPlanAddUnitType(mainBaseDefPlan1ID, cUnitTypeLogicalTypeLandMilitary, 0, 2, 2);
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
    
    int otherBaseDefPlanID = createDefOrAttackPlan("otherBase"+number+"DefPlan", true, 40, 15, newBaseUnitPosition, newBaseID, 25, false);
    if (otherBaseDefPlanID != -1)
    {
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
minInterval 29 //starts in cAge2
inactive
{
	if (kbGetAge() < cAge3)
	return;
    if (ShowAiEcho == true) aiEcho("attackEnemySettlement:");
	if (ShouldIAgeUp() == true)
    xsSetRuleMinIntervalSelf(120);
    else
	xsSetRuleMinIntervalSelf(29);	
    int numSiegeWeapons = kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive);
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    static bool ResetOk = false;
	
	int SiegeMU = 0;
	int SiegeMU2 = 0;
	
	if (cMyCulture == cCultureGreek)
	SiegeMU = cUnitTypeColossus;
	else if (cMyCulture == cCultureEgyptian)
	{
		SiegeMU = cUnitTypeScarab;
		SiegeMU2 = cUnitTypeSphinx;
	}
	else if (cMyCulture == cCultureNorse)
	SiegeMU = cUnitTypeMountainGiant;

	else if (cMyCulture == cCultureAtlantean)
	SiegeMU = cUnitTypeBehemoth;
	
	else if (cMyCulture == cCultureChinese)
	{
		SiegeMU = cUnitTypeVermilionBird;
		SiegeMU2 = cUnitTypePixiu;
	}
	
	int sMUCombined = ((kbUnitCount(cMyID, SiegeMU, cUnitStateAlive)) + (kbUnitCount(cMyID, SiegeMU2, cUnitStateAlive)));
	if (sMUCombined < 0)
	sMUCombined = 0;
	
	numSiegeWeapons = numSiegeWeapons + sMUCombined;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
	int numEnemyMilUnitsNearMBInR80 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 80.0, true);
    int numAttEnemyMilUnitsNearMBInR85 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, cActionAttack, cPlayerRelationEnemy, mainBaseLocation, 85.0, true);
    int numEnemyTitansNearMBInR75 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, mainBaseLocation, 75.0, true);
	
    if (ShowAiEcho == true) aiEcho("numAttEnemyMilUnitsNearMBInR85: "+numAttEnemyMilUnitsNearMBInR85);
    if (ShowAiEcho == true) aiEcho("numEnemyTitansNearMBInR75: "+numEnemyTitansNearMBInR75);
    
    vector defPlanBaseLocation = cInvalidVector;
    int numEnemyTitansNearDefBInR55 = 0;
    int numAttEnemyTitansNearDefBInR55 = 0;
    int defPlanBaseID = aiPlanGetBaseID(gDefendPlanID);
    if (defPlanBaseID != -1)
    {
        defPlanBaseLocation = kbBaseGetLocation(cMyID, defPlanBaseID);
        if (ShowAiEcho == true) aiEcho("defPlanBaseLocation: "+defPlanBaseLocation);
        if (equal(defPlanBaseLocation, cInvalidVector) == false)
        {
            numEnemyTitansNearDefBInR55 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanBaseLocation, 55.0, true);
		}
	}
    
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
	int numMilUnitsInDefPlans = AvailableUnitsFromDefPlans();
    
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
                    aiPlanAddUnitType(attackPlanID, cUnitTypeAbstractSiegeWeapon, 1, 3, 4);
					
                    if (numTitansInAttackPlan > 0)
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, false);  // Make sure the gEnemySettlementAttPlan stays open
						if (ShowAiEcho == true) aiEcho ("Setting gEnemySettlementAttPlanID NoMoreUnits to false");
                        aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 10, kbGetPopCap(), kbGetPopCap());
						xsSetRuleMinIntervalSelf(12);
					}
                    else if ((currentPop >= currentPopCap * 0.8) && ((numMythInAttackPlan > 0) || (numSiegeInAttackPlan > 0)) && (kbGetAge() > cAge3)
					&& (woodSupply > 300) && (goldSupply > 400) && (foodSupply > 400) && (numEnemyMilUnitsNearMBInR80 < 20))
                    {
                        aiPlanSetNoMoreUnits(attackPlanID, false);  // Make sure the gEnemySettlementAttPlan stays open
                        aiPlanSetDesiredPriority(attackPlanID, 55);
						if (ShowAiEcho == true) aiEcho ("Setting gEnemySettlementAttPlanID NoMoreUnits to false");
                        aiPlanAddUnitType(attackPlanID, cUnitTypeLogicalTypeLandMilitary, 10, kbGetPopCap(), kbGetPopCap());
						xsSetRuleMinIntervalSelf(12);
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
            else if ((attackPlanID == gLandAttackPlanID) && (numMilUnitsInDefPlans < 15)) // trying this..
            {
                landAttackPlanActive = true;
                continue;
			}
		}
	}
    
    if ((numEnemyTitansNearDefBInR55 > 0) || (numEnemyTitansNearMBInR75 > 0))
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
    
	if ((kbGetAge() < cAge3) && (gRushAttackCount >= gRushCount))
	return;
	
    
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
			    int enemyMilUnitsInR50 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
	            int NumEnemyBuildings = getNumUnitsByRel(cUnitTypeLogicalTypeBuildingsNotWalls, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 35.0, true);
				int Combined = NumEnemyBuildings + enemyMilUnitsInR50;
				if (Combined <= 5)
				settlementPosDefPlanActive = false;				
			}
		}
	}
    int numSiegeUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeAbstractSiegeWeapon);
    int numMythUnitsIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeMythUnitNotTitan);
    int numTitansIngDefendPlan = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeAbstractTitan);
	
    if (ShowAiEcho == true) aiEcho("total numMilUnitsInDefPlans: "+numMilUnitsInDefPlans);   
	
    int mostHatedPlayerID = aiGetMostHatedPlayerID();
    int numMHPlayerSettlements = kbUnitCount(mostHatedPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
    if (ShowAiEcho == true) aiEcho("numMHPlayerSettlements: "+numMHPlayerSettlements);      
    
	if (ReadyToAttack() == false)
	{
		if (ShowAiEcho == true) aiEcho ("returning as we're not ready to make an attack");
		return;
	}	
	
    if (targetSettlementCloseToMB == false)
    {
        if ((numMHPlayerSettlements < 1) && (targetSettlementID < 0))
        {
            if (ShowAiEcho == true) aiEcho("targetSettlementID < 0 and numMHPlayerSettlements < 1, returning");
            return;
		}
        if ((settlementPosDefPlanActive == true) && (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1) && (Combined > 5))
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
        else if ((numSiegeWeapons < 1) && (aiRandInt(10) > 5))
        {
			if (ShowAiEcho == true) aiEcho ("returning as we don't have a Titan, a siege weapon, or a military myth unit");
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
        || ((numMilUnitsInDefPlans > 14) && ((numSiegeUnitsIngDefendPlan > 1) || (numMythUnitsIngDefendPlan > 1)
	    || ((numSiegeUnitsIngDefendPlan > 0) && (numMythUnitsIngDefendPlan > 0)))) || (numMilUnitsInDefPlans >= 20) && (aiRandInt(3) == 0))
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
            || (numMythUnitsIngDefendPlan > 0))))
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
    
    int enemySettlementAttPlanID = createDefOrAttackPlan("enemy settlement attack plan", false, -1, 30, cInvalidVector, -1, -1, false);
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
		aiPlanSetNumberVariableValues(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 2, true);  
		aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(mainBaseLocation));
		aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanTargetAreaGroups, 1, kbAreaGroupGetIDByPosition(targetSettlementPos));
	}
	
    if (numTitans > 0)
	aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeAbstractTitan, 0, 1, 1);
    aiPlanAddUnitType(enemySettlementAttPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans, numMilUnitsInDefPlans, numMilUnitsInDefPlans);
	
    if (numTitans > 0)
	aiPlanSetDesiredPriority(enemySettlementAttPlanID, 55);
    else
	aiPlanSetDesiredPriority(enemySettlementAttPlanID, 52);

    aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanSpecificTargetID, 0, targetSettlementID);
  	aiPlanSetVariableInt(enemySettlementAttPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
	
	if (cMyCiv == cCivKronos)
    aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanAttackPlanID, 0, enemySettlementAttPlanID);
	
	int GPFindPlan = aiFindBestAttackGodPowerPlan();
	if ((GPFindPlan > 0) && (GPFindPlan != gUnbuildPlanID))
    aiPlanSetVariableInt(GPFindPlan, cGodPowerPlanAttackPlanID, 0, enemySettlementAttPlanID);	
    aiPlanSetActive(enemySettlementAttPlanID);
	
	if (gSomeData != -1)
	aiPlanSetUserVariableInt(gSomeData, SettlementAttackTarget, 0 , targetPlayerID);
	
    if (lastTargetUnitID == targetSettlementID)
    lastTargetCount = lastTargetCount + 1;
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
    if (numMilUnits < 10)
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
	
	int BaseToUse = kbUnitGetBaseID(findUnit(cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding, cActionAny, cMyID, gSettlementPosDefPlanDefPoint, 30));
	if (BaseToUse == -1)  
	return;
    if (ShowAiEcho == true) aiEcho("gSettlementPosDefPlanDefPoint: "+gSettlementPosDefPlanDefPoint);
    int settlementPosDefPlanID = createDefOrAttackPlan("settlementPosDefPlan", true, 40, 20, gSettlementPosDefPlanDefPoint, BaseToUse, 52, false);
    if (settlementPosDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
        if (distToMainBase < 100.0)
        {
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
			aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
			
			if (NumEnemyBuildings > 6)
			aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 7, 15, 18);
			else aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 3, 5, 6);
            
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
        aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeAbstractTitan, 0, 1, 1);
		
        //override
        if (enemyMilUnitsInR50 > 18)
		aiPlanAddUnitType(settlementPosDefPlanID, cUnitTypeLogicalTypeLandMilitary, 11, enemyMilUnitsInR50 + 8, enemyMilUnitsInR50 + 8);
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
	
    if (gEnemyWonderDefendPlan > 0)
    return;

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
                
                int numEnemyDropsitesInCloseRange = getNumUnits(enemyEconUnit, cUnitStateAlive, -1, playerID, mainBaseLocation, closeRangeRadius);
				if ((numEnemyDropsitesInCloseRange < 1) && (kbGetCultureForPlayer(playerID) != cCultureAtlantean))
				numEnemyDropsitesInCloseRange = getNumUnits(cUnitTypeAbstractVillager, cUnitStateAlive, -1, playerID, mainBaseLocation, closeRangeRadius);
                int dropsiteUnitIDinCloseRange = -1;
                if (numEnemyDropsitesInCloseRange > 0)
                {
                    index = aiRandInt(numEnemyDropsitesInCloseRange);
                    dropsiteUnitIDinCloseRange = findUnitByIndex(enemyEconUnit, index, cUnitStateAlive, -1, playerID, mainBaseLocation, closeRangeRadius);
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
	
    if (dropsiteUnitIDinCloseRange != -1)
    {
        if (ReadyToAttack() == false)
        {
            return;
		}
	}
    else
    {
        if (ReadyToAttack() == false)
        {
            return;
		}
        
        if (numEnemyMilUnitsNearMBInR80 > 8)
        {
            return;
		}

        int enemyPlayerID = aiGetMostHatedPlayerID();
        int numEnemyMarkets = kbUnitCount(enemyPlayerID, cUnitTypeMarket, cUnitStateAlive);
		
        if (kbGetCultureForPlayer(enemyPlayerID) == cCultureAtlantean)
		enemyEconUnit = cUnitTypeVillagerAtlantean;
        else
		enemyEconUnit = cUnitTypeDropsite;   
        int numEnemyDropsites = kbUnitCount(enemyPlayerID, enemyEconUnit, cUnitStateAlive);
				
        if ((mapRestrictsMarketAttack() == false) && (numEnemyMarkets > 0) && ((numEnemyDropsites < 1) || (aiRandInt(5) < 2)))
        {
            for (j = 0; < numEnemyMarkets)
            {
                int enemyMarketUnitID = findUnitByIndex(cUnitTypeMarket, j, cUnitStateAlive, -1, enemyPlayerID);
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
                int possibleEnemyDropsiteUnitID = findUnitByIndex(enemyEconUnit, k, cUnitStateAlive, -1, enemyPlayerID);
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
			}
            if ((equal(gRaidingPartyLastMarketLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
            {
                int militaryUnit2ID = findUnitByIndex(cUnitTypeHumanSoldier, 1, cUnitStateAlive, cActionIdle);
                if (militaryUnit2ID > 0)
                {
                    aiTaskUnitMove(militaryUnit2ID, gRaidingPartyLastMarketLocation);
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
    
    int raidingPartyAttackID = createDefOrAttackPlan("Raiding Party", false, -1, 20, cInvalidVector, -1, -1, false);
    if (raidingPartyAttackID < 0)
	return;
    if (dropsiteUnitIDinCloseRange < 0)
	aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanPlayerID, 0, enemyPlayerID);
    else
	aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanPlayerID, 0, playerID);
	
    aiPlanSetVariableInt(raidingPartyAttackID, cAttackPlanSpecificTargetID, 0, targetUnitID);
    aiPlanSetVariableBool(raidingPartyAttackID, cAttackPlanAutoUseGPs, 0, false);
    
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
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeChuKoNu, 1, 3, 5);
        aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeHalberdier, 1, 2, 2);
		aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeScoutChinese, 1, 2, 3);
	}	
    
    if (targetIsMarket == true)
    {
        if (numSiegeUnitsIngDefendPlan > 1)
		aiPlanAddUnitType(raidingPartyAttackID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
	}
	
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
minInterval 41 //starts in cAge2
inactive
{
    if (ShowAiEcho == true) aiEcho("randomAttackGenerator:");
	if (ShouldIAgeUp() == true)
    xsSetRuleMinIntervalSelf(82);
    else
	xsSetRuleMinIntervalSelf(41);		
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
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
	
    if (ReadyToAttack() == false)
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
                int numEnemyDropsitesInCloseRange = getNumUnits(enemyEconUnit, cUnitStateAlive, -1, playerID, mainBaseLocation, closeRangeRadius);
                if (kbGetCivForPlayer(playerID) == cCivOuranos)	
				{
					int SkyPassages = getNumUnits(cUnitTypeSkyPassage, cUnitStateAlive, -1, playerID, mainBaseLocation, closeRangeRadius);
					if (SkyPassages > 0)
					enemyEconUnit = cUnitTypeSkyPassage;
				}				
                int dropsiteUnitIDinCloseRange = -1;
                if (numEnemyDropsitesInCloseRange > 0)
                {
                    index = aiRandInt(numEnemyDropsitesInCloseRange);
                    dropsiteUnitIDinCloseRange = findUnitByIndex(enemyEconUnit, index, cUnitStateAlive, -1, playerID, mainBaseLocation, closeRangeRadius);
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
        int numEnemyMarkets = kbUnitCount(enemyPlayerID, cUnitTypeMarket, cUnitStateAlive);
		
        if (numEnemyMarkets > 0)
        {
            for (j = 0; < numEnemyMarkets)
            {
                int enemyMarketUnitID = findUnitByIndex(cUnitTypeMarket, j, cUnitStateAlive, -1, enemyPlayerID);
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
	}
    
    if ((targetIsMarket == false) && (equal(gRandomAttackLastMarketLocation, cInvalidVector) == false) && (aiRandInt(2) < 1))
    {
        int militaryUnit2ID = findUnitByIndex(cUnitTypeHumanSoldier, 1, cUnitStateAlive, cActionIdle);
        if (militaryUnit2ID > 0)
        {
            aiTaskUnitMove(militaryUnit2ID, gRandomAttackLastMarketLocation);
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
    
    int randomAttackPlanID = createDefOrAttackPlan("randomAttackPlan", false, -1, 30, cInvalidVector, -1, 50, false);
    if (randomAttackPlanID < 0)
	return;
    
    if (dropsiteUnitIDinCloseRange > 0)
	aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanPlayerID, 0, playerID);
    else
	aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanPlayerID, 0, enemyPlayerID);
    
    if ((dropsiteUnitIDinCloseRange > 0) || (targetIsMarket == true))
    {
        aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanSpecificTargetID, 0, gRandomAttackTargetUnitID);
        if (((enemySettlementAttPlanActive == true) && (mapRestrictsMarketAttack() == false)) || (dropsiteUnitIDinCloseRange > 0))
        {
            if (targetIsMarket == true)
            {
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeAbstractSiegeWeapon, 0, 1, 1);
                aiPlanAddUnitType(randomAttackPlanID, cUnitTypeHero, 0, 1, 1);
                
                if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
				aiPlanAddUnitType(randomAttackPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
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
		}
	}
	
   	// Specify other continent so that armies will transport
    if (gTransportMap == true)
	{
		vector targetPos = kbUnitGetPosition(gRandomAttackTargetUnitID);
		aiPlanSetNumberVariableValues(randomAttackPlanID, cAttackPlanTargetAreaGroups, 2, true);  
		aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(mainBaseLocation));
		aiPlanSetVariableInt(randomAttackPlanID, cAttackPlanTargetAreaGroups, 1, kbAreaGroupGetIDByPosition(targetPos));
	}

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
minInterval 53 //starts in cAge2
inactive
{
	
	if (ShouldIAgeUp() == true)
    xsSetRuleMinIntervalSelf(106);
    else
	xsSetRuleMinIntervalSelf(53);	
    if (ShowAiEcho == true) aiEcho("createLandAttack:");
	
    int numTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
    static int attackPlanStartTime = -1;
    bool enemySettlementAttPlanActive = false;
    bool randomAttackPlanActive = false;
    
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    
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
	
    int enemyPlayerID = aiGetMostHatedPlayerID();
    int numTargetPlayerSettlements = kbUnitCount(enemyPlayerID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding); 
	int numMilUnitsInDefPlans = AvailableUnitsFromDefPlans();	
	
    if (kbGetAge() < cAge3)
    {
        if (gRushCount < 1)
        {
            if (ShowAiEcho == true) aiEcho("returning as we don't want to rush");
            return;
		}
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
				int Combined = NumEnemyBuildings + enemyMilUnitsInR50;
				if (Combined <= 5)
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
    else if ((randomAttackPlanActive == true) && (numMilUnitsInDefPlans < 15)) //trying this..
    {
        if (ShowAiEcho == true) aiEcho("returning as there is a gRandomAttackPlanID active and there are more than 10 units in the plan");
        return;
	}
    else if ((settlementPosDefPlanActive == true) && (myBaseAtDefPlanPosition + alliedBaseAtDefPlanPosition < 1) && (Combined > 5))
    {
        if (ShowAiEcho == true) aiEcho("returning as there is a gSettlementPosDefPlanID active");
        return;
	}
	
    int requiredUnits = kbGetPopCap() / 10;
    if ((kbGetAge() == cAge2) && (gRushAttackCount < gRushCount) && (ShouldIAgeUp() == false))
    {
        if ((gRushCount > 1) && (gRushAttackCount == 0))
		requiredUnits = gFirstRushSize;
        else
		requiredUnits = gRushSize;
        if (numMilUnitsInDefPlans < requiredUnits * 0.8)
        return;		
	}
    else
    {
        if (ReadyToAttack() == false) 
        return;
	} 
    
    int landAttackPlanID = createDefOrAttackPlan("landAttackPlan", false, -1, 30, cInvalidVector, -1, 50, false);
    if (landAttackPlanID < 0)
	return;
   
    aiPlanSetVariableInt(landAttackPlanID, cAttackPlanPlayerID, 0, enemyPlayerID);
	aiPlanAddUnitType(landAttackPlanID, cUnitTypeLogicalTypeLandMilitary, numMilUnitsInDefPlans, numMilUnitsInDefPlans, numMilUnitsInDefPlans);  
	aiPlanSetVariableInt(landAttackPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
    
	// Specify other continent so that armies will transport
    if (gTransportMap == true)
	{
		int enemyMainBaseUnitID = getMainBaseUnitIDForPlayer(enemyPlayerID);
		int targetSettlementID = enemyMainBaseUnitID;
		vector targetSettlementPos = kbUnitGetPosition(targetSettlementID); // uses main TC
		aiPlanSetNumberVariableValues(landAttackPlanID, cAttackPlanTargetAreaGroups, 2, true);  
		aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(mainBaseLocation));
		aiPlanSetVariableInt(landAttackPlanID, cAttackPlanTargetAreaGroups, 1, kbAreaGroupGetIDByPosition(targetSettlementPos));
	}
	
	gLandAttackPlanID = landAttackPlanID;
	if (cMyCiv == cCivKronos)
    aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanAttackPlanID, 0, landAttackPlanID);
	
	int GPFindPlan = aiFindBestAttackGodPowerPlan();
	if ((GPFindPlan > 0) && (GPFindPlan != gUnbuildPlanID))
    aiPlanSetVariableInt(GPFindPlan, cGodPowerPlanAttackPlanID, 0, landAttackPlanID);		
    
    if (gRushAttackCount < gRushCount)
	gRushAttackCount = gRushAttackCount + 1;
    aiPlanSetActive(landAttackPlanID);
	
    if (ShowAiEcho == true) aiEcho("Creating landAttackPlan #: "+gLandAttackPlanID);
	if (gSomeData != -1)
	aiPlanSetUserVariableInt(gSomeData, LandAttackTarget, 0 , aiPlanGetVariableInt(landAttackPlanID, cAttackPlanPlayerID, 0));	
    attackPlanStartTime = xsGetTime();
}

//==============================================================================
rule setUnitPicker
minInterval 60 //starts in cAge2
inactive
{
	if (xsGetTime() < 12*60*1000)
	return;
    if (kbGetAge() == cAge2)
	{
	    aiPlanSetVariableBool(gRushGoalID, cGoalPlanIdleAttack, 0, true);
		if ((cMyCulture == cCultureNorse) || (cMyCulture == cCultureEgyptian))
        kbUnitPickSetDesiredNumberUnitTypes(gRushUPID, 2, 3, true);
		else
		kbUnitPickSetDesiredNumberUnitTypes(gRushUPID, 2, 2, true);
	}
    xsDisableSelf();

}

//==============================================================================
rule defendBaseUnderAttack
minInterval 1 //starts in cAge2, activated in baseAttackTracker rule
inactive
{
    if (ShowAiEcho == true) aiEcho("defendBaseUnderAttack: ");
    
    xsSetRuleMinIntervalSelf(17);
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
				
                if ((alliedBaseAtDefPlanPosition > 0) || ((xsGetTime() > defendPlanStartTime + 1*20*1000) && (enemyMilUnitsInR50 < 3) && (numAttEnemySiegeInR50 < 1)))
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
    int baseUnderAttackDefPlanID = createDefOrAttackPlan("baseUnderAttackDefPlan", true, 40, 20, gBaseUnderAttackLocation, gBaseUnderAttackID, 53, false);
	
    if (baseUnderAttackDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
		
        if (distToMainBase < 80.0)
        {
            aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHero, 1, 1, 1);
            if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
			aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
            
            aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 4, 16, 16);
            if (cMyCiv == cCivHades)
			aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeShadeofHades, 0, 2, 2);
		}
        else
        {
			if ((cRandomMapName != "anatolia") && (gTransportMap == false)) //water myth units cause problems!
			aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeLogicalTypeMythUnitNotTitan, 0, 1, 1);
			aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeAbstractSiegeWeapon, 1, 1, 2);
			aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 8, 18, 20);
			if (cMyCiv == cCivHades)
			aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeShadeofHades, 0, 4, 4);
		}
        aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeAbstractTitan, 0, 1, 1);
        
        
        //override
        if (enemyMilUnitsInR40 > 16)
		aiPlanAddUnitType(baseUnderAttackDefPlanID, cUnitTypeHumanSoldier, 8, enemyMilUnitsInR40 + 6, enemyMilUnitsInR40 + 6);
        aiPlanSetActive(baseUnderAttackDefPlanID);
        gBaseUnderAttackDefPlanID = baseUnderAttackDefPlanID;
        if (ShowAiEcho == true) aiEcho("baseUnderAttackDefPlanID set active: "+gBaseUnderAttackDefPlanID);
        xsSetRuleMinIntervalSelf(17);
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
    if (ShowAiEcho == true) aiEcho("defendAlliedBase: ");
    xsSetRuleMinIntervalSelf(89);
    int alliedBaseUnitID = -1;
    int startIndex = aiRandInt(cNumberPlayers);
	
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
            int numEnemyTitansNearDefPointInR70 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 90.0, true);
            int numEnemyMilUnitsNearDefPointInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, defPlanDefPoint, 90.0, true);
            int alliedMilUnitsNearDefPointInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, defPlanDefPoint, 90.0, true);
            static int count = 0;
            
            if (defendPlanID == gAlliedBaseDefPlanID)
            {
                if (ShowAiEcho == true) aiEcho("gAlliedBaseDefPlanID exists: ID is "+defendPlanID);
				HelpSettleID = -1;
                xsSetRuleMinIntervalSelf(40); // be on alert
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
    
	
	if (HelpSettleID != -1)
	{
		alliedBaseUnitID = HelpSettleID;
		HelpSettleID = -1;
		alliedBaseLocation = kbUnitGetPosition(alliedBaseUnitID);
		numEnemyTitansInR70 = getNumUnitsByRel(cUnitTypeAbstractTitan, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 90.0, true);
		numEnemyMilUnitsInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 90.0, true);
		alliedMilUnitsInR70 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationAlly, alliedBaseLocation, 90.0, true);	
        enemySettlementAtAlliedBasePosition = getNumUnitsByRel(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, cPlayerRelationEnemy, alliedBaseLocation, 15.0);
        numMotherNatureSettlementsAtAlliedBasePosition = getNumUnits(cUnitTypeAbstractSettlement, cUnitStateAlive, -1, 0, alliedBaseLocation, 15.0);		
		
		if ((alliedMilUnitsInR70 > numEnemyMilUnitsInR70+4))
		return;
	}
	
	int mainBaseID = kbBaseGetMainID(cMyID);
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	if ((kbAreaGroupGetIDByPosition(alliedBaseLocation) != kbAreaGroupGetIDByPosition(mainBaseLocation) && (gTransportMap == true))) // transport and can't reach?
	return;
	
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
    
    if (numMilUnits < 14)
    {
        if (ShowAiEcho == true) aiEcho("returning as we only have "+numMilUnits+" military units or too few enemies");
        return;
	}
    
    if (ShowAiEcho == true) aiEcho("alliedBaseLocation: "+alliedBaseLocation);
    int alliedBaseDefPlanID = createDefOrAttackPlan("alliedBaseDefPlan", true, 70, 20, alliedBaseLocation, -1, 35, false);
    if (alliedBaseDefPlanID > 0)
    {
        defendPlanStartTime = xsGetTime();
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
        aiPlanSetActive(alliedBaseDefPlanID);
        gAlliedBaseDefPlanID = alliedBaseDefPlanID;
		xsSetRuleMinIntervalSelf(20); // be on alert
        if (ShowAiEcho == true) aiEcho("alliedBaseDefPlanID set active: "+gAlliedBaseDefPlanID);
	}
}

//==============================================================================
rule tacticalBuildings
minInterval 11
inactive
{
    if (ShowAiEcho == true) aiEcho("tacticalBuildings:");
    
    int numAttBuildings = getNumUnits(cUnitTypeBuildingsThatShoot, cUnitStateAlive, cActionRangedAttack, cMyID);
    int max = 12;
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
            int enemyMilUnitsInR45 = getNumUnitsByRel(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cPlayerRelationEnemy, otherBaseLocation, 45.0, true);
            int myMilUnitsInR45 = getNumUnits(cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive, -1, cMyID, otherBaseLocation, 45.0, true);
            //Get the time under attack.
            int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, otherBaseID);
            if ((secondsUnderAttack > 15) || ((secondsUnderAttack > 0) && (enemyMilUnitsInR45 > 9)))
            {
                if (ShowAiEcho == true) aiEcho("baseID for attack tracking is "+otherBaseID);	
                if (ShowAiEcho == true) aiEcho("secondsUnderAttack: "+secondsUnderAttack+" for base ID: "+otherBaseID);
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