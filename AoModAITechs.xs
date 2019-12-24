//AoModAITechs.xs
//This file contains all tech rules
//by Loki_GdD

//==============================================================================
rule getOmniscience
minInterval 24 //starts in cAge4
inactive
{
    if (ShowAiEcho == true) aiEcho("getOmniscience:");
    //If we can afford it twice over, then get it.
    float goldCost=kbTechCostPerResource(cTechOmniscience, cResourceGold) * 2.0;
    float currentGold=kbResourceGet(cResourceGold);
    if (goldCost>currentGold)
	return;
    createSimpleResearchPlan(cTechOmniscience, -1, cMilitaryEscrowID, 25, true);
    xsDisableSelf();
}

//==============================================================================
rule getMasons
minInterval 131 //starts in cAge2
inactive
{
    int techID = cTechMasons;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        xsEnableRule("getArchitects");
        return;
	}
    
    if (ShowAiEcho == true) aiEcho("getMasons:");
	
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
	
    if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true));
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
			}
		}
        return;
	}
    
    if (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching)
	return;
       
    if ((foodSupply < 400) || (woodSupply < 600) || (foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
	return;
    
    if (kbGetTechStatus(techID) < cTechStatusResearching)
    createSimpleResearchPlan(techID, -1, cRootEscrowID, 40, true);
}

//==============================================================================
rule getArchitects
minInterval 131 //starts in cAge3, activated in getMasons
inactive
{
    int techID = cTechArchitects;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
    
    if (ShowAiEcho == true) aiEcho("getArchitects:");
	
    if (kbGetAge() < cAge3)
	return;
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
	
    if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true));
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
			}
		}
        return;
	}
	
    if (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching)
	return;
    
    if (kbGetAge() == cAge3)
    {
        if ((foodSupply < 1500) || (woodSupply < 1100) || (goldSupply > 1000))
		return;
	}
    else
    {
        if ((foodSupply < 400) || (woodSupply < 500))
        return;
        
	}
    createSimpleResearchPlan(techID, -1, cRootEscrowID, 80, true);
}

//==============================================================================
rule getFortifiedTownCenter
inactive
minInterval 41 //starts in cAge3
{
    int techID = cTechFortifyTownCenter;
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 90, true);
	xsDisableSelf();
}

//==============================================================================
rule getEnclosedDeck
minInterval 32 //starts in cAge2
inactive
{
    int techID = cTechEnclosedDeck;
    if (ShowAiEcho == true) aiEcho("getEnclosedDeck:");
    static int ruleStartTime = -1;
    
    if (ruleStartTime == -1)
	ruleStartTime = xsGetTime();
	
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (xsGetTime() - ruleStartTime < 5*60*1000))
	return;
    
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    
	
    if ((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2) || (foodSupply < 400) || (woodSupply < 400))
	return;
	
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 60, true);
	xsDisableSelf();
}

//==============================================================================
rule getPurseSeine
minInterval 30 //starts in cAge2
inactive
{
    int techID = cTechPurseSeine;
    if (ShowAiEcho == true) aiEcho("getPurseSeine:"); 
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 45, true);
	xsDisableSelf();
}

//==============================================================================
rule getSaltAmphora
minInterval 30 //starts in cAge3
inactive
{
    int techID = cTechSaltAmphora;
    if (ShowAiEcho == true) aiEcho("getSaltAmphora:");
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 80, true);
	xsDisableSelf();
}

//==============================================================================
rule getHusbandry
minInterval 23
inactive
{
    int techID = cTechHusbandry;
    if ((kbGetTechStatus(techID) > cTechStatusResearching) || (cMyCulture == cCultureAtlantean))
    {
        xsDisableSelf();
        return;
	}
    if (ShowAiEcho == true) aiEcho("getHusbandry:");      
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true) >= 0)
    return;
	
    int buildingType = cUnitTypeEarlyFoodDropsite;		
	
    int numResearchBuildings = kbUnitCount(cMyID, buildingType, cUnitStateAlive);
    if (numResearchBuildings < 1)
	return;
    
	if (kbGetAge() < cAge2)
    {    
        if (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching)
		return;
	}
	
    if ((kbGetTechStatus(cTechPickaxe) < cTechStatusResearching) || (kbGetTechStatus(cTechHandAxe) < cTechStatusResearching) ||
	(gHuntersExist == true) && (kbGetTechStatus(cTechHuntingDogs) < cTechStatusResearching))
	return;
    createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 99, true);
}

//==============================================================================
rule getPickaxe
minInterval 6 //starts in cAge1, gets set to 15
inactive
group age1EconUpgrades
{
    int techID = cTechPickaxe;
    int buildingType = cUnitTypeEarlyGoldDropsite;
    if (cMyCulture == cCultureAtlantean)
	buildingType = cUnitTypeGuild;
	
    int numResearchBuildings = kbUnitCount(cMyID, buildingType, cUnitStateAlive);
    if ((numResearchBuildings < 1) || (kbGetTechStatus(cTechHandAxe) < cTechStatusResearching) && (cMyCulture != cCultureEgyptian))
	return;
    
    if (kbGetAge() < cAge2)
    {    
        if ((kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching) || (cMyCulture != cCultureEgyptian) && (cMyCulture != cCultureAtlantean))
		return;
	}
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 95, true);
	xsDisableSelf();
}

//==============================================================================
rule getHandaxe
minInterval 5
inactive
group age1EconUpgrades
{    
    int techID = cTechHandAxe;
    int buildingType = cUnitTypeEarlyWoodDropsite;
    if (cMyCulture == cCultureAtlantean)
	buildingType = cUnitTypeGuild;	
	
    int numResearchBuildings = kbUnitCount(cMyID, buildingType, cUnitStateAlive);
    if ((numResearchBuildings < 1) || (kbGetTechStatus(cTechPickaxe) < cTechStatusResearching) && (cMyCulture == cCultureEgyptian))
	return;
    
    if (kbGetAge() < cAge2)
    {
        if ((kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching) || (cMyCulture == cCultureEgyptian))
		return;
	}
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 95, true);
	xsDisableSelf();
}

//==============================================================================
rule getHuntingDogs
minInterval 167 //starts in cAge1, gets set to 11
inactive
{
    int techID = cTechHuntingDogs;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
    
    static bool update = false;
    if (update == false)
    {
        xsSetRuleMinIntervalSelf(11);
        update = true;
	}
    if (ShowAiEcho == true) aiEcho("getHuntingDogs:");
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true) >= 0)
    return;
    
    int buildingType = cUnitTypeEarlyFoodDropsite;
    if (cMyCulture == cCultureAtlantean)
	buildingType = cUnitTypeGuild;	
	
    int numResearchBuildings = kbUnitCount(cMyID, buildingType, cUnitStateAlive);
    if (numResearchBuildings < 1)
	return;
    
    int numTemples = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding);
    if (numTemples < 1)
	return;
	
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    if ((woodSupply < 100) || (goldSupply < 100))
	return;
    
    int count = 0;
    int mainBaseID = kbBaseGetMainID(cMyID);
    int numAggressivePlans = aiGetResourceBreakdownNumberPlans(cResourceFood, cAIResourceSubTypeHuntAggressive, mainBaseID);
    if (ShowAiEcho == true) aiEcho("numAggressivePlans: "+numAggressivePlans);
    if (numAggressivePlans > 0)
	count = numAggressivePlans;
    
    if (count < 1)  //we have no hunters
    {
        gHuntersExist = false;
        return;
	}
    
	gHuntersExist = true;
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 100, true);
	xsSetRuleMinIntervalSelf(167);
	update = false;
}

//==============================================================================
// getNextGathererUpgrade
//
// sets up a progression plan to research the next upgrade that benefits the given
// resource.
//==============================================================================
rule getNextGathererUpgrade
minInterval 16
inactive
{
	int gathererTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer, 0);
	int prio = 25;
	if ((gathererTypeID < 0) || (kbUnitCount(cMyID,cUnitTypeLogicalTypeBuildingsThatTrainMilitary, cUnitStateAliveOrBuilding) < 2))
	return;
	
	for (i=0; < 3)
	{
		int affectedUnitType=-1;
		if (i == cResourceGold)
		affectedUnitType=cUnitTypeGold;
		else if (i == cResourceWood)
		{
			affectedUnitType=cUnitTypeWood; 
		}
		else
		{
			//If we're not farming yet, don't get anything.
			if (gFarming != true)
			continue;
			if (kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAlive) >= 0)   // Farms always first
			{
				affectedUnitType=cUnitTypeFarm;
				prio = 90;
			}
		}
		
		//Get the building that we drop this resource off at.
		int dropSiteFilterID=kbTechTreeGetDropsiteUnitIDByResource(i, 0);
		if (cMyCulture == cCultureAtlantean)
		dropSiteFilterID = cUnitTypeGuild;  // All econ techs at guild
		if (dropSiteFilterID < 0)
		continue;
		
		//Don't do anything until you have a dropsite.
		if (findUnit(dropSiteFilterID) == -1)
		continue;
		
		//Get the cheapest thing.
		int upgradeTechID=kbTechTreeGetCheapestUnitUpgrade(gathererTypeID, cUpgradeTypeWorkRate, -1, dropSiteFilterID, false, affectedUnitType);
		if (upgradeTechID < 0)
		continue;
		//Dont make another plan if we already have one.
		if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, upgradeTechID) != -1)
		continue;
		
		//Make plan to get this upgrade.
        createSimpleResearchPlan(upgradeTechID, -1, cEconomyEscrowID, prio, true);
	}
}
//==============================================================================
rule getAmbassadors
inactive
minInterval 60 //starts in cAge3
{
    if (IhaveAllies == false)
	return;
	
    int techID = cTechAmbassadors;
    if (ShowAiEcho == true) aiEcho("getAmbassadors:");
    
    if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 1)
	return;
	
    float goldSupply = kbResourceGet(cResourceGold);
    if ((goldSupply < 500) || (kbGetAge() < cAge4))
	return;
    
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 25);
	xsDisableSelf();
}
//==============================================================================
rule getTaxCollectors
inactive
minInterval 47 //starts in cAge3
{
    int techID = cTechTaxCollectors;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
	
    if (ShowAiEcho == true) aiEcho("getTaxCollectors:");
	
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
	
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(47);
			}
		}
        return;
	}
    
    if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 1)
	return;
	
    if ((goldSupply < 600) || (foodSupply < 600))
	return;
	
    if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
	return;
    
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 50);
}

//==============================================================================
rule getHeroicFleet
inactive
minInterval 300 //starts in cAge2
{
    int techID = cTechHeroicFleet;
    if (ShowAiEcho == true) aiEcho("getHeroicFleet:");
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50);
	xsDisableSelf();
}

//==============================================================================
rule getCrenellations
inactive
minInterval 79 //starts in cAge2
{
    int techID = cTechCrenellations;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
	
    if (ShowAiEcho == true) aiEcho("getCrenellations:");
	
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(79);
			}
		}
        return;
	}
    
    if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching))
	return;
    
    if ((woodSupply < 300) || (foodSupply < 300))
	return;
	
    if ((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
	return;
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 70);
}

//==============================================================================
rule getSignalFires
inactive
minInterval 107 //starts in cAge2
{
    int techID = cTechSignalFires;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsEnableRule("getCarrierPigeons");
        xsDisableSelf();
        return;
	}
    
    if (ShowAiEcho == true) aiEcho("getSignalFires:");
	
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
	return;
    
    if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching))
	return;
	
    float woodSupply = kbResourceGet(cResourceWood);
    if (woodSupply < 500)
	return;
    
	createSimpleResearchPlan(techID, -1, cRootEscrowID, 5);
}

//==============================================================================
rule getBoilingOil
inactive
minInterval 79 //starts in cAge3
{
    int techID = cTechBoilingOil;
	int numTowers = kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
   
    if ((numTowers < 1) || (numMarkets < 1))
	return;

	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 70);
	xsDisableSelf();
}

//==============================================================================
rule getCarrierPigeons
inactive
minInterval 107 //starts in cAge2 activated in getSignalFires
{
    int techID = cTechCarrierPigeons;
    int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
    if ((numFortresses < 1) || (numMarkets < 1))
	return;
	
    float woodSupply = kbResourceGet(cResourceWood);
    if (woodSupply < 800)
	return;
    
	createSimpleResearchPlan(techID, -1, cRootEscrowID, 5);
	xsDisableSelf();
}

//==============================================================================
rule getWatchTower
inactive
minInterval 10 //starts in cAge2
{
    int techID = cTechWatchTower;
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 100);
	xsDisableSelf();
}

//==============================================================================
rule getGuardTower
inactive
minInterval 43 //starts in cAge3
{
    int techID = cTechGuardTower;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        if (cMyCulture == cCultureEgyptian)
		xsEnableRule("getBallistaTower");
        xsDisableSelf();
        return;
	}
	
    if (ShowAiEcho == true) aiEcho("getGuardTower:");
	
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(43);
			}
		}
        return;
	}
    
    int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
    if ((numFortresses < 1) || (numMarkets < 1))
	return;
    
    if ((goldSupply < 400) || (woodSupply < 400))
	return;
	
    if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
	return;
	
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 80);
}

//==============================================================================
rule WallManager
inactive
minInterval 37
{
    int techID = -1;
    static int Step = 0;
	int FinalStep = 3;
	if (cMyCulture == cCultureGreek)
	FinalStep = 1;
    else if (cMyCulture == cCultureEgyptian)
	FinalStep = 2;
    else if (cMyCulture == cCultureNorse)
	FinalStep = 0;
    int GoldNeeded = 350;
	int FoodNeeded = 350;
    xsSetRuleMinIntervalSelf(37);
	
    switch(Step)
    {
        case 0:
        {
	        if (cMyCulture == cCultureChinese)
			{	
			    techID = cTechEarthenWall;
                GoldNeeded = 200;
	            FoodNeeded = 200;				
			}
		    else
			techID = cTechStoneWall;	
            break;
		}	
        case 1:
        {
			
		    if (cMyCulture == cCultureChinese)
			techID = cTechStoneWallChinese;
		    else
			{
		        if (cMyCulture == cCultureAtlantean)
				{
                    techID = cTechBronzeWall;
                    GoldNeeded = 400;
	                FoodNeeded = 500;
				}
			    else
				{
				    techID = cTechFortifiedWall;
                    GoldNeeded = 600;
	                FoodNeeded = 750;
			    }
			}		
            break;
		}
        case 2:
        {
		    if (cMyCulture == cCultureAtlantean)
            techID = cTechIronWall;
		    else if (cMyCulture == cCultureEgyptian)
			techID = cTechCitadelWall;	
            else if (cMyCulture == cCultureChinese)
			techID = cTechFortifiedWall;    
            GoldNeeded = 600;
	        FoodNeeded = 750;		
            break;
		}
        case 3:
        {
		    if (cMyCulture == cCultureAtlantean)
            techID = cTechOreichalkosWall;			
            else if (cMyCulture == cCultureChinese)
			techID = cTechGreatWall;
            GoldNeeded = 750;
	        FoodNeeded = 1080;		
            break;
		}
	}
	
	if ((Step > FinalStep) || (techID == -1))
	{	
        xsDisableSelf();
        return;
	}
	
	if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        Step = Step + 1;
		xsSetRuleMinIntervalSelf(5);
		return;
	}
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
	
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching) && (kbGetAge() == cAge2) 
			|| (foodSupply > 800) && (goldSupply > 750) && (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching) && (kbGetAge() == cAge3))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(37);
			}		
		}
        return;
	}
    if ((foodSupply < FoodNeeded) || (goldSupply < GoldNeeded) || (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
	return; 

	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 30);
	xsSetRuleMinIntervalSelf(2);
}
//==============================================================================
rule getBallistaTower
inactive
minInterval 47 //starts in cAge3 activated in getGuardTower
{
    int techID = cTechBallistaTower;
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    if ((woodSupply < 800) || (foodSupply < 500))
	return;
	
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 80);
	xsDisableSelf();
}


//==============================================================================
rule getHandsOfThePharaoh
inactive
minInterval 30 //starts in cAge1
{
    int techID = cTechHandsofthePharaoh;
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 100);
	xsDisableSelf();
}

//==============================================================================
rule getAxeOfMuspell
inactive
minInterval 43 //starts in cAge3
{
    int techID = cTechAxeofMuspell;   
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    float foodSupply = kbResourceGet(cResourceFood);
    if ((goldSupply < 375) || (woodSupply < 150))
	return;
    
    if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
	return;
	
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 25);
	xsDisableSelf();	
}

//==============================================================================
rule getBeastSlayer
inactive
minInterval 41 //starts in cAge4
{
    int techID = cTechBeastSlayer;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
    
    if (ShowAiEcho == true) aiEcho("getBeastSlayer:");
	
    float foodSupply = kbResourceGet(cResourceFood);
    float woodSupply = kbResourceGet(cResourceWood);
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if ((kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (TitanAvailable == true))
        {
            if ((favorSupply > 15) && (goldSupply > 500) && (foodSupply > 500) && (woodSupply > 500))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(41);
			}
		}
        return;
	}
    
    if ((gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching))
	return;
    
    int specialUnitID = -1;
    if (cMyCiv == cCivZeus)
	specialUnitID = cUnitTypeMyrmidon;
    else if (cMyCiv == cCivHades)
	specialUnitID = cUnitTypeCrossbowman;
    else if (cMyCiv == cCivPoseidon)
	specialUnitID = cUnitTypeHetairoi;
    
    int numSpecialUnits = kbUnitCount(cMyID, specialUnitID, cUnitStateAlive);
    if (numSpecialUnits < 4)
	return;
	
    if ((kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (TitanAvailable == true))
    {
        if ((goldSupply < 600) || (foodSupply < 500) || (favorSupply < 25))
		return;
        
        if ((favorSupply < 65) && (goldSupply > 650) && (foodSupply > 650) && (woodSupply > 700))
		return;
	}
	
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50);
	xsSetRuleMinIntervalSelf(11);
}

//==============================================================================
rule getMediumInfantry
inactive
minInterval 13 //starts in cAge2
group mediumUpg
{
    int techID = cTechMediumInfantry;
	int NeededRes = 300;
	if (cMyCulture == cCultureChinese)
	techID = cTechMediumBarracks;
	else if (cMyCulture == cCultureEgyptian)
	{
	    techID = cTechMediumSpearmen;
        NeededRes = 200;
    }		

    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
	
    if (ShowAiEcho == true) aiEcho("getMediumInfantry:");
	
	
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);    
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true));
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(13);
			}
		}
        return;
	}
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
	return;
	
    int numInfantry = kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive);
	if (cMyCulture == cCultureChinese)
	numInfantry = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);

    if ((numInfantry < 5) && (kbGetAge() < cAge3))
	return;
    
    if (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching)
    {
        if (numInfantry < 9)
        {
            if ((goldSupply < NeededRes) || (foodSupply < NeededRes))
			return;
			
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
			return;
		}
	}
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 49, true);
	xsSetRuleMinIntervalSelf(11);
}

//==============================================================================
rule getMediumCavalry
inactive
minInterval 12 //starts in cAge2
group mediumUpg
{
    int techID = cTechMediumCavalry;
	int NeededFood = 400;
	if (cMyCulture == cCultureChinese)
	techID = cTechMediumStable;	
	else if (cMyCulture == cCultureEgyptian)
	{
	    techID = cTechMediumAxemen;
        NeededFood = 200;
    }
	
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
	
    if (ShowAiEcho == true) aiEcho("getMediumCavalry:");
	
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);    
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true));
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(12);
			}
		}
        return;
	}
    
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
	return;
	
    int numCavalry = kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateAlive);
    if ((numCavalry < 5) && (kbGetAge() < cAge3))
	return;
    
    if (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching)
    {
        if (numCavalry < 9)
        {
            if ((goldSupply < 200) || (foodSupply < NeededFood))
			return;
			
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
			return;
		}
	}
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 49, true);
	xsSetRuleMinIntervalSelf(11);
}

//==============================================================================
rule getMediumArchers
inactive
minInterval 11 //starts in cAge2
group mediumUpg
{
    int techID = cTechMediumArchers;
	if (cMyCulture == cCultureEgyptian)
	techID = cTechMediumSlingers;	
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
    
    if (ShowAiEcho == true) aiEcho("getMediumArchers:");    
	
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(11);
			}
		}
        return;
	}
    
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
	return;
    
    int numArchers = kbUnitCount(cMyID, cUnitTypeAbstractArcher, cUnitStateAlive);
    if ((numArchers < 5) && (kbGetAge() < cAge3))
	return;
    
    if (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching)
    {
        if (numArchers < 9)
        {
            if ((goldSupply < 300) || (woodSupply < 300))
			return;
			
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
			return;
		}
	}
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 49);
	xsSetRuleMinIntervalSelf(11);
}

//==============================================================================
rule getDraftHorses
inactive
minInterval 20 //starts in cAge3
{
    int techID = cTechDraftHorses;   
    if (ShowAiEcho == true) aiEcho("getDraftHorses:");
    
    int numSiegeWeapons = kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive);
    if (numSiegeWeapons < 2)
	return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    if ((goldSupply < 400) || (foodSupply < 600))
	return;
	
    if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
	return;
	
    static int count = 0;
    if (count < 1)
    {
        count = count + 1;
        return;
	}
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50, true);
	xsDisableSelf();
}

//==============================================================================
rule getEngineers
inactive
minInterval 20 //starts in cAge4
{
    int techID = cTechEngineers;
    if (ShowAiEcho == true) aiEcho("getEngineers:");
    
    int numSiegeWeapons = kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive);
    if (numSiegeWeapons < 2)
	return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    if ((goldSupply < 800) || (foodSupply < 600))
	return;
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50, true);
	xsDisableSelf();
}

//==============================================================================
rule getCoinage
inactive
minInterval 20 //starts in cAge4
{
	createSimpleResearchPlan(cTechCoinage, -1, cEconomyEscrowID, 100);
	xsDisableSelf();
}

//==============================================================================
rule researchCopperShields
minInterval 14 //starts in cAge2
inactive
group ArmoryAge2
{
    if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
	return;
    
    int techID = cTechCopperShields;
	if (cMyCiv == cCivThor)
	techID = cTechCopperShieldsThor;
	
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
	
    if (ShowAiEcho == true) aiEcho("researchCopperShields:");
	
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);
	
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(14);
			}
		}
        return;
	}
    
    int numHumanSoldiers = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);
    int numHeroes = kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive);
    int numMilitaryShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeShipNotFishinghip, cUnitStateAlive);
    if (numHumanSoldiers + numHeroes + numMilitaryShips < 13)
	return;
    
    if (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching)
    {
        if (numHumanSoldiers + numHeroes + numMilitaryShips < 21)
        {
            if ((goldSupply < 300) || (woodSupply < 300))
			return;
			
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
			return;
		}
	}
	
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50);
	xsSetRuleMinIntervalSelf(11);
}

//==============================================================================
rule researchCopperMail
minInterval 15 //starts in cAge2
inactive
group ArmoryAge2
{
    if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
	return;
	
    if (ShowAiEcho == true) aiEcho("researchCopperMail:");
	
    int techID = cTechCopperMail;
	if (cMyCiv == cCivThor)
	techID = cTechCopperMailThor;	
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
	
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
	
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(15);
			}
		}
        return;
	}
    
    int numHumanSoldiers = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);
    int numHeroes = kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive);
    int numMilitaryShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeShipNotFishinghip, cUnitStateAlive);
    if (numHumanSoldiers + numHeroes + numMilitaryShips < 13)
	return;
    
    if (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching)
    {
        if (numHumanSoldiers + numHeroes + numMilitaryShips < 21)
        {
            if ((goldSupply < 300) || (foodSupply < 300))
			return;
			
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
			return;
		}
	}
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50);
	xsSetRuleMinIntervalSelf(11);
}

//==============================================================================
rule researchCopperWeapons
minInterval 16 //starts in cAge2
inactive
group ArmoryAge2
{
    if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
	return;
	
    if (ShowAiEcho == true) aiEcho("researchCopperWeapons:");
	
    int techID = cTechCopperWeapons;
	if (cMyCiv == cCivThor)
	techID = cTechCopperWeaponsThor;	
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsDisableSelf();
        return;
	}
	
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    float woodSupply = kbResourceGet(cResourceWood);  
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (kbGetTechStatus(techID) < cTechStatusResearching)
        {
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(16);
			}
		}
        return;
	}
    
    int numHumanSoldiers = kbUnitCount(cMyID, cUnitTypeHumanSoldier, cUnitStateAlive);
    int numHeroes = kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive);
    int numMilitaryShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeShipNotFishinghip, cUnitStateAlive);
    int numBuildingsThatShoot = kbUnitCount(cMyID, cUnitTypeBuildingsThatShoot, cUnitStateAlive);
    if (numHumanSoldiers + numHeroes + numMilitaryShips + numBuildingsThatShoot < 15)
	return;
    
    if (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching)
    {
        if (numHumanSoldiers + numHeroes + numMilitaryShips + numBuildingsThatShoot < 31)
        {
            if ((goldSupply < 400) || (foodSupply < 400))
			return;
			
            if ((foodSupply > 560) && (goldSupply > 350) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching))
			return;
		}
	}
    
    static int count = 0;        
    if (count < 1)
    {
        count = count + 1;
        return;
	}
	
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50);
	xsSetRuleMinIntervalSelf(11);
}

//==============================================================================
rule getSecretsOfTheTitan
minInterval 17 //starts in cAge4
inactive
{
	
    if (ShowAiEcho == true) aiEcho("getSecretsOfTheTitan:");
    if (TitanAvailable == false)
    {
        xsDisableSelf();
        return;
	}	
    
    if ((gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) < cTechStatusResearching))
	return;
    
    int techID = cTechSecretsoftheTitans;
    if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true) >= 0)
    {
        xsDisableSelf();
        return;
	}
    
    // Make a progression to get Titan
    int titanPID = aiPlanCreate("GetSecretsOfTheTitan", cPlanProgression);
    if (titanPID != 0)
    {
        aiPlanSetVariableInt(titanPID, cProgressionPlanGoalTechID, 0, techID);
        aiPlanSetDesiredPriority(titanPID, 100);
		if (gTransportMap == false)
        aiPlanSetEscrowID(titanPID, cEconomyEscrowID);
		else 
		aiPlanSetEscrowID(titanPID, cMilitaryEscrowID);
        aiPlanSetActive(titanPID);
        if (ShowAiEcho == true) aiEcho("getting secrets of the titans");
        xsDisableSelf();
	}
}



/////////////////////////////////// CIV TECHS ///////////////////////////////////
//==============================================================================
//Greek START
//==============================================================================

//Hades
//==============================================================================
rule getVaultsOfErebus
minInterval 23 //starts in cAge2
inactive
{
	createSimpleResearchPlan(cTechVaultsofErebus, -1, cEconomyEscrowID, 50);
	xsDisableSelf();
}

//Poseidon
//==============================================================================
rule getLordOfHorses
inactive
minInterval 45 //starts in cAge2
{
    int techID = cTechLordofHorses;
    int numCavalry = kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateAlive);
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((foodSupply < 300) || (favorSupply < 20) || (numCavalry < 5))
	return;
	
    if ((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
	return;
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 5);
	xsDisableSelf();
}

//Zeus
//==============================================================================
rule getOlympicParentage
minInterval 23 //starts in cAge2
inactive
{
    int techID = cTechOlympicParentage;   
    int numHeroes = kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive);
    if (numHeroes < 1)
	return;
	
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((foodSupply < 400) || (favorSupply < 20))
	return;
	
    if ((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
	return;
	
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 25);
    xsDisableSelf();
}

//age2
//Athena
//the unit picker decides.

//Hermes
//==============================================================================
rule getWingedMessenger
inactive
minInterval 27 //starts in cAge2
group Hermes
{
    int techID = cTechWingedMessenger;   
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
	return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((goldSupply < 100) || (favorSupply < 20))
	return;
	
    if ((foodSupply > 560) && (goldSupply > 350) && (kbGetAge() == cAge2))
	return;
	
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 25);
	xsDisableSelf();
}

//Ares
//the unit picker decides.

//age3
//Aphrodite
//==============================================================================
rule getDivineBlood
inactive
minInterval 27 //starts in cAge3
group Aphrodite
{
    int techID = cTechDivineBlood;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
	}
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (techStatus < cTechStatusResearching)
        {
            if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(27);
			}
		}
        return;
	}
    
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 75);
	xsSetRuleMinIntervalSelf(11);
}

//==============================================================================
rule getGoldenApples
inactive
minInterval 29 //starts in cAge3
group Aphrodite
{   
    int techID = cTechGoldenApples;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        xsDisableSelf();
        return;
	}
    
    float foodSupply = kbResourceGet(cResourceFood);
    float goldSupply = kbResourceGet(cResourceGold);
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
    {
        if (techStatus < cTechStatusResearching)
        {
            if ((foodSupply > 700) && (goldSupply > 700) && (kbGetAge() == cAge3))
            {
                aiPlanDestroy(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true));
                xsSetRuleMinIntervalSelf(29);
			}
		}
        return;
	}
	
    if (kbGetAge() == cAge3)
    {
        if ((foodSupply > 700) && (goldSupply > 700))
		return;
	}
	
    if ((foodSupply < 400) || (goldSupply < 300))
	return;
    
    static int count = 0;        
    if (count < 1)
    {
        count = count + 1;
        return;
	}
    
	createSimpleResearchPlan(techID, -1, cEconomyEscrowID, 50);
	xsSetRuleMinIntervalSelf(11);
}

//Apollo
//==============================================================================
rule getTempleOfHealing
inactive
minInterval 30 //starts in cAge3
group Apollo
{
    int techID = cTechTempleofHealing;
	createSimpleResearchPlan(techID, -1, cRootEscrowID, 6);
	xsDisableSelf();
}

//==============================================================================
rule getOracle
inactive
minInterval 31 //starts in cAge3
group Apollo
{
    int techID = cTechOracle;
    if (kbGetTechStatus(cTechTempleofHealing) < cTechStatusResearching)
	return;
    
    if ((kbGetAge() > cAge3) && (gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching))
	return;
    
    int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
    int numMarkets = kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding);
    if ((numFortresses < 1) || (numMarkets < 1))
	return;
	
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((woodSupply < 300) && (favorSupply < 20))
	return;
	
	createSimpleResearchPlan(techID, -1, cRootEscrowID, 5);
	xsDisableSelf();
}


//Dionysus
//the unit picker decides.

//age4
//Artemis
//==============================================================================
rule getFlamesOfTyphon
inactive
minInterval 29 //starts in cAge4
group Hera
{
	
    int techID = cTechFlamesofTyphon;
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 70))
	return;
    
    if ((foodSupply < 800) || (favorSupply < 30) || (kbUnitCount(cMyID, cUnitTypeChimera, cUnitStateAlive) < 2))
	return;
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50);
	xsDisableSelf();
    
}

//==============================================================================
rule getTrierarch
inactive
minInterval 31 //starts in cAge4
group Hera
{
    if (gTransportMap == false)
    {
        xsDisableSelf();
        return;
	}
    int techID = cTechTrierarch;
    
    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching))
	return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((goldSupply < 600) || (favorSupply < 60))
	return;
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 30);
	xsDisableSelf();
}

//Hephaestus
//==============================================================================
rule getForgeOfOlympus
inactive
minInterval 35 //starts in cAge4
group Hephaestus
{
    int techID = cTechForgeofOlympus;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        //cTechForgeofOlympus is researched, reactivate the attack goal
        aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0, false);
        if (ShowAiEcho == true) aiEcho("reactivating attack goal");
        xsDisableSelf();
        return;
	}
    
    if (aiPlanGetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0) == false)
    {
        //set the gLandAttackGoalID to idle so that no armory techs get researched
        aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0, true);
        if (ShowAiEcho == true) aiEcho("setting gLandAttackGoalID to idle");
        xsSetRuleMinIntervalSelf(10);
	}
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
	return;
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 100);
}

//==============================================================================
rule getHandOfTalos
inactive
minInterval 31 //starts in cAge4
group Hephaestus
{
    int techID = cTechHandofTalos;
    
    if (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching)
	return;
    
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((woodSupply < 500) || (favorSupply < 30))
	return;
    
    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 75))
	return;
	
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50);
	xsDisableSelf();	
}

//==============================================================================
rule getShoulderOfTalos
inactive
minInterval 33 //starts in cAge4
group Hephaestus
{
    int techID = cTechShoulderofTalos;  
    if (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching)
	return;
    
    if (kbGetTechStatus(cTechHandofTalos) < cTechStatusResearching)
	return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((goldSupply < 500) || (favorSupply < 30))
	return;
    
    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 75))
	return;
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50);
	xsDisableSelf();	
}


//Hera
//==============================================================================
rule getAthenianWall
inactive
minInterval 37 //starts in cAge4
group Hera
{
    int techID = cTechAthenianWall;
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
	return;
	
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 80))
	return;
    
    if ((woodSupply < 800) || (favorSupply < 45))
	return;
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 30);
	xsDisableSelf();
}

//==============================================================================
rule getMonstrousRage
inactive
minInterval 29 //starts in cAge4
group Hera
{
    int techID = cTechMonstrousRage;
    float foodSupply = kbResourceGet(cResourceFood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 75))
	return;
    
    if ((foodSupply < 500) || (favorSupply < 37))
	return;
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 50);
	xsDisableSelf();
}

//==============================================================================
rule getFaceOfTheGorgon
inactive
minInterval 31 //starts in cAge4
group Hera
{
    int techID = cTechFaceoftheGorgon;
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((TitanAvailable == true) && (kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching) && (favorSupply < 80))
	return;
    
    if ((woodSupply < 600) || (favorSupply < 45))
	return;
	
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 40);
	xsDisableSelf();
}

//==============================================================================
//Greek END
//==============================================================================

//==============================================================================
//Egyptian START
//==============================================================================
//Isis
//==============================================================================
// RULE: getFloodOfTheNile
//==============================================================================
rule getFloodOfTheNile
inactive
minInterval 23
{
	createSimpleResearchPlan(cTechFloodoftheNile, -1, cEconomyEscrowID, 75);
    xsDisableSelf();
}

//Ra
//==============================================================================
// RULE: getSkinOfTheRhino
//==============================================================================
rule getSkinOfTheRhino
inactive
minInterval 23
{
	createSimpleResearchPlan(cTechSkinOfTheRhino, -1, cEconomyEscrowID, 15);
    xsDisableSelf();
}

//Set
//==============================================================================
// RULE: getFeral
//==============================================================================
rule getFeral
inactive
minInterval 23
{
    if (kbGetAge() < cAge3)
	return;
	createSimpleResearchPlan(cTechFeral, -1, cRootEscrowID, 5);
    xsDisableSelf();
}

//age2 
//Anubis

//==============================================================================
// RULE: getNecropolis
//==============================================================================
rule getNecropolis
inactive
minInterval 31
group Anubis
{
    float goldSupply = kbResourceGet(cResourceGold);
    if (kbGetAge() < cAge3 && goldSupply < 750)
	return;
	createSimpleResearchPlan(cTechNecropolis, -1, cRootEscrowID, 10);
    xsDisableSelf();
}

//Bast
//==============================================================================
// RULE: getCriosphinx
//==============================================================================
rule getCriosphinx
inactive
minInterval 31
group Bast
{
    if ((kbUnitCount(cMyID, cUnitTypeSphinx, cUnitStateAlive) < 2) || (kbResourceGet(cResourceWood) < 250))
	return;
	createSimpleResearchPlan(cTechCriosphinx, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//==============================================================================
// RULE: getHieracosphinx
//==============================================================================
rule getHieracosphinx
inactive
minInterval 33
group Bast
{
    if ((kbUnitCount(cMyID, cUnitTypeSphinx, cUnitStateAlive) < 2) || (kbResourceGet(cResourceWood) < 350))
	return;
	createSimpleResearchPlan(cTechHieracosphinx, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//Ptah
//==============================================================================
// RULE: getShaduf
//==============================================================================
rule getShaduf
inactive
minInterval 27
group Ptah
{
	createSimpleResearchPlan(cTechShaduf, -1, cEconomyEscrowID, 95);
    xsDisableSelf();
}

//age3
//Hathor
//==============================================================================
// RULE: getSundriedMudBrick
//==============================================================================
rule getSundriedMudBrick
inactive
minInterval 27
group Hathor
{
	createSimpleResearchPlan(cTechSundriedMudBrick, -1, cRootEscrowID, 25);
    xsDisableSelf();
}

//==============================================================================
// RULE: getMedjay
//==============================================================================
rule getMedjay
inactive
minInterval 29
group Hathor
{
    if ((kbGetAge() < cAge4) || (kbResourceGet(cResourceFood) < 1000))
	return;
	createSimpleResearchPlan(cTechMedjay, -1, cRootEscrowID, 2);
    xsDisableSelf();
}

//==============================================================================
// RULE: getCrocodopolis
//==============================================================================
rule getCrocodopolis
inactive
minInterval 31
group Hathor
{
    if ((kbUnitCount(cMyID, cUnitTypePetsuchos, cUnitStateAlive) < 3)|| (kbResourceGet(cResourceWood) < 500))
	return;
	createSimpleResearchPlan(cTechCrocodopolis, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//Sekhmet
//==============================================================================
// RULE: getBoneBow
//==============================================================================
rule getBoneBow
inactive
minInterval 27
group Sekhmet
{
    if ((kbUnitCount(cMyID, cUnitTypeChariotArcher, cUnitStateAlive) < 5) || (kbResourceGet(cResourceWood) < 300))
	return;
	createSimpleResearchPlan(cTechBoneBow, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//==============================================================================
// RULE: getSlingsOfTheSun
//==============================================================================
rule getSlingsOfTheSun
inactive
minInterval 29
group Sekhmet
{
    if ((kbUnitCount(cMyID, cUnitTypeSlinger, cUnitStateAlive) < 6) || (kbResourceGet(cResourceGold) < 600))
	return;
	createSimpleResearchPlan(cTechSlingsoftheSun, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//==============================================================================
// RULE: getStonesOfRedLinen
//==============================================================================
rule getStonesOfRedLinen
inactive
minInterval 31
group Sekhmet
{
    if (kbUnitCount(cMyID, cUnitTypeCatapult, cUnitStateAlive) < 1)
	return;
    createSimpleResearchPlan(cTechStonesofRedLinen, cUnitTypeSiegeCamp, cMilitaryEscrowID, 25);
	xsDisableSelf();
}

//==============================================================================
// RULE: getRamOfTheWestWind
//==============================================================================
rule getRamOfTheWestWind
inactive
minInterval 33
group Sekhmet
{
    if ((kbUnitCount(cMyID, cUnitTypeSiegeTower, cUnitStateAlive) < 1) || (kbResourceGet(cResourceGold) < 550))
	return;
	createSimpleResearchPlan(cTechRamoftheWestWind, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//Nephthys
//==============================================================================
// RULE: getSpiritOfMaat
//==============================================================================
rule NephthysMiscUpg
inactive
minInterval 27
group Nephthys
{
	createSimpleResearchPlan(cTechSpiritofMaat, -1, cMilitaryEscrowID, 25);
	createSimpleResearchPlan(cTechFuneralRites, -1, cMilitaryEscrowID, 25);
	createSimpleResearchPlan(cTechCityoftheDead, -1, cMilitaryEscrowID, 25);
    xsDisableSelf();
}


//age4
//Horus
//the unit picker decides.

//Osiris
//==============================================================================
// RULE: getAtefCrown
//==============================================================================
rule getAtefCrown
inactive
minInterval 27
group Osiris
{
    if (kbUnitCount(cMyID, cUnitTypeMummy, cUnitStateAlive) < 2)
	return;
	createSimpleResearchPlan(cTechAtefCrown, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//==============================================================================
// RULE: getFuneralBarge
//==============================================================================
rule getFuneralBarge
inactive
minInterval 27
group Osiris
{
    if ((gNavalAttackGoalID != -1) || (gTransportMap == true))
	createSimpleResearchPlan(cTechFuneralBarge, -1, cMilitaryEscrowID, 25);
    xsDisableSelf();
}

//==============================================================================
// RULE: NewKingdom
//==============================================================================
rule getNewKingdom
inactive
minInterval 27
group Osiris
{
	createSimpleResearchPlan(cTechNewKingdom, -1, cEconomyEscrowID, 75);
    xsDisableSelf();
}
//Thoth
//==============================================================================
// RULE: getBookofThoth
//==============================================================================
rule getBookofThoth
inactive
minInterval 27
group Thoth
{
	createSimpleResearchPlan(cTechBookofThoth, -1, cEconomyEscrowID, 75);
    xsDisableSelf();
}

//==============================================================================
//Egyptian END
//==============================================================================


//==============================================================================
//Norse START
//==============================================================================
//Thor
//==============================================================================
rule getPigSticker
inactive
minInterval 16 //starts in cAge1
{
    int techID = cTechPigSticker;
	createSimpleResearchPlan(techID, -1, cRootEscrowID, 40);
	xsDisableSelf();	
}

//Odin
//==============================================================================
rule getLoneWanderer
inactive
minInterval 36 //starts in cAge1
{
    
    if ((kbGetAge() < cAge4) || (kbUnitCount(cMyID, cUnitTypeUlfsark, cUnitStateAlive) < 5) || (kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAlive) < 10))
	return;
	createSimpleResearchPlan(cTechLoneWanderer, -1, cRootEscrowID, 5);
    xsDisableSelf();
}


//Loki
//==============================================================================
rule getEyesInTheForest
inactive
minInterval 36 //starts in cAge1
{
    if (kbGetAge() < cAge3)
	return;
	createSimpleResearchPlan(cTechEyesintheForest, -1, cRootEscrowID, 5);
    xsDisableSelf();
}

//age2
//Freyja
//the unit picker decides.

//Heimdall
//==============================================================================
rule getSafeguard
inactive
minInterval 60 //starts in cAge2
group Heimdall
{
    if (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching)
	return;

	createSimpleResearchPlan(cTechSafeguard, -1, cRootEscrowID, 25);
	xsDisableSelf();
}

//Forseti
//the unit picker decides.

//age3
//Njord
//the unit picker decides.

//Skadi
//==============================================================================
rule getRime
inactive
minInterval 60 //starts in cAge3
group Skadi
{
    if ((kbUnitCount(cMyID, cUnitTypeFrostGiant, cUnitStateAlive) < 2))
	return;
	createSimpleResearchPlan(cTechRime, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}
//Bragi
//==============================================================================
rule getSwineArray
inactive
minInterval 60 //starts in cAge3
group Bragi
{
    if ((kbUnitCount(cMyID, cUnitTypeUlfsark, cUnitStateAlive) < 5) || (kbResourceGet(cResourceWood) < 400))
	return;
	createSimpleResearchPlan(cTechSwineArray, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//==============================================================================
rule getThurisazRune
inactive
minInterval 60 //starts in cAge3
group Bragi
{
    if ((kbResourceGet(cResourceWood) < 350) 
	|| (kbUnitCount(cMyID, cUnitTypeMythUnit, cUnitStateAlive) < 2))
	return;
	createSimpleResearchPlan(cTechThurisazRune, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//age4
//Baldr
//==============================================================================
rule getDwarvenAuger
inactive
minInterval 60 //starts in cAge4
group Baldr
{
    if (kbUnitCount(cMyID, cUnitTypePortableRam, cUnitStateAlive) < 2)
	return;
	createSimpleResearchPlan(cTechDwarvenAuger, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}
//==============================================================================
rule getSonsOfSleipnir
inactive
minInterval 60 //starts in cAge4
group Baldr
{
    if ((kbUnitCount(cMyID, cUnitTypeRaidingCavalry, cUnitStateAlive) < 4) || (kbResourceGet(cResourceFood) < 400))
	return;
	createSimpleResearchPlan(cTechSonsofSleipnir, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

//Tyr
//Hel
//==============================================================================
rule getRampageAndBlood
inactive
minInterval 60 //starts in cAge4
group Hel
{
    createSimpleResearchPlan(cTechRampage, -1, cMilitaryEscrowID, 20);
	createSimpleResearchPlan(cTechGraniteBlood, -1, cMilitaryEscrowID, 20);
    xsDisableSelf();
}

//==============================================================================
//Norse END
//==============================================================================

//==============================================================================
//Atlantean START
//==============================================================================
//Gaia
//==============================================================================
// RULE: getChannels
//==============================================================================
rule getChannels
inactive
minInterval 23
{
    if (kbGetAge() < cAge3)
	return;
    createSimpleResearchPlan(cTechChannels, -1, cRootEscrowID, 2);
    xsDisableSelf();
}

//Kronos
//==============================================================================
// RULE: getFocus
//==============================================================================
rule getFocus
inactive
minInterval 23
{
    if (kbResourceGet(cResourceWood) < 800)
	return;
    createSimpleResearchPlan(cTechFocus, -1, cRootEscrowID, 1);
    xsDisableSelf();
}

//Oranos
//==============================================================================
// RULE: getSafePassage
//==============================================================================
rule getSafePassage
inactive
minInterval 23
{
    int techID = cTechSafePassage;  
    if (kbGetTechStatus(cTechWatchTower) < cTechStatusResearching)
	return;
    
    int numSkyPassages = kbUnitCount(cMyID, cUnitTypeSkyPassage, cUnitStateAlive);
    if (numSkyPassages < 2)
	return;
	
    float woodSupply = kbResourceGet(cResourceWood);
    float favorSupply = kbResourceGet(cResourceFavor);
    if ((woodSupply < 250) || (favorSupply < 15))
	return;
    
    createSimpleResearchPlan(techID, -1, cRootEscrowID, 40);
	xsDisableSelf();
}


//age2
//Leto
//Oceanus
//unit picker does these.

//Prometheus
//==============================================================================
// RULE: getHeartOfTheTitans
//==============================================================================
rule getHeartOfTheTitans
inactive
minInterval 27
group Prometheus
{
    float goldSupply = kbResourceGet(cResourceGold);
    if ((kbGetAge() < cAge3) && (goldSupply < 650) || (goldSupply < 250))
	return;
    createSimpleResearchPlan(cTechHeartoftheTitans, -1, cMilitaryEscrowID, 25);
    xsDisableSelf();
}

//age3
//Rheia
//==============================================================================
// RULE: getHornsOfConsecration
//==============================================================================
rule RheiaMiscUpg
inactive
minInterval 29
group Rheia
{
    createSimpleResearchPlan(cTechHornsofConsecration, -1, cRootEscrowID, 20);
	createSimpleResearchPlan(cTechRheiasGift, -1, cRootEscrowID, 25);
    xsDisableSelf();
}

//Theia
//==============================================================================
// RULE: getLemurianDescendants
//==============================================================================
rule getLemurianDescendants
inactive
minInterval 27
group Theia
{
    if ((kbResourceGet(cResourceGold) < 250) || (kbResourceGet(cResourceFood) < 300))
	return;
    createSimpleResearchPlan(cTechLemurianDescendants, -1, cRootEscrowID, 20);
    xsDisableSelf();
}
//==============================================================================
// RULE: getLanceOfStone
//==============================================================================
rule getLanceOfStone
inactive
minInterval 31
group Theia
{
    if ((kbUnitCount(cMyID, cUnitTypeLancerHero, cUnitStateAlive) < 4))
	return;
    createSimpleResearchPlan(cTechLanceofStone, -1, cMilitaryEscrowID, 1);
    xsDisableSelf();
}

//Hyperion
//==============================================================================
// RULE: getHeroicRenewal
//==============================================================================
rule getHeroicRenewal
inactive
minInterval 27
group Hyperion
{
    if ((kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive) < 3))
	return;
    createSimpleResearchPlan(cTechHeroicRenewal, -1, cMilitaryEscrowID, 25);
    xsDisableSelf();
}

//==============================================================================
// RULE: getGemino
//==============================================================================
rule getGemino
inactive
minInterval 29
group Hyperion
{
    if ((kbUnitCount(cMyID, cUnitTypeSatyr, cUnitStateAlive) < 3) || (kbResourceGet(cResourceWood) < 350))
	return;
    createSimpleResearchPlan(cTechGemino, -1, cMilitaryEscrowID, 5);
    xsDisableSelf();
}


//age4
//Atlas
//==============================================================================
// RULE: getTitanShield
//==============================================================================
rule getTitanShield
inactive
minInterval 27
group Atlas
{
    createSimpleResearchPlan(cTechTitanShield, -1, cRootEscrowID, 25);
    xsDisableSelf();
}

//==============================================================================
// RULE: getEyesOfAtlas
//==============================================================================
rule getEyesOfAtlas
inactive
minInterval 29
group Atlas
{
    if (kbUnitCount(cMyID, cUnitTypeMythUnit, cUnitStateAlive) < 3)
	return;
    createSimpleResearchPlan(cTechEyesofAtlas, -1, cMilitaryEscrowID, 1);
    xsDisableSelf();
}

//==============================================================================
// RULE: getIoGuardian
//==============================================================================
rule getIoGuardian
inactive
minInterval 31
group Atlas
{
    if (kbUnitCount(cMyID, cUnitTypeArgus, cUnitStateAlive) < 3)
	return;
    createSimpleResearchPlan(cTechIoGuardian, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}


//Hekate
//==============================================================================
// RULE: getHekateMisc
//==============================================================================
rule getHekateMisc
inactive
minInterval 27
group Hekate
{
    if (kbUnitCount(cMyID, cUnitTypeMythUnit, cUnitStateAlive) < 3)
	return;
    createSimpleResearchPlan(cTechMythicRejuvenation, -1, cMilitaryEscrowID, 25);
	createSimpleResearchPlan(cTechCelerity, -1, cMilitaryEscrowID, 15);
    xsDisableSelf();
}
//==============================================================================
// RULE: getAsperBlood
//==============================================================================
rule getAsperBlood
inactive
minInterval 31
group Hekate
{
    if(kbUnitCount(cMyID, cUnitTypeLampades, cUnitStateAlive) < 2)
	return;
    createSimpleResearchPlan(cTechAsperBlood, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}


//Helios
//==============================================================================
// RULE: getHeliosMisc
//==============================================================================
rule getHeliosMisc
inactive
minInterval 29
group Helios
{
    if(kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive) < 2)
	return;	
    createSimpleResearchPlan(cTechPetrified, -1, cMilitaryEscrowID, 15);
	createSimpleResearchPlan(cTechHalooftheSun, cUnitTypePalace, cMilitaryEscrowID, 15);
    xsDisableSelf();
}
//==============================================================================
//Atlantean END
//==============================================================================

//==============================================================================
//Chinese START
//==============================================================================
//NuWa
//==============================================================================
// RULE: getAcupuncture
//==============================================================================
rule getAcupuncture
inactive
minInterval 30
{
    float foodSupply = kbResourceGet(cResourceFood);
    if ((foodSupply < 1000) || (kbGetAge() < cAge3))
	return;
    createSimpleResearchPlan(cTechAcupuncture, -1, cEconomyEscrowID, 5);
    xsDisableSelf();
}

//FuXi
// not worth it, unless they adjust the base food value of Herdables to 51.

//Shennong
//==============================================================================
// RULE: getWheelbarrow
//==============================================================================
rule getWheelbarrow
inactive
minInterval 25
{
    createSimpleResearchPlan(cTechWheelbarrow, -1, cEconomyEscrowID, 75);
    xsDisableSelf();	
}

//age2
//Chang'e
//==============================================================================
// RULE: getElixirofImmortality
//==============================================================================
rule getElixirofImmortality
inactive
minInterval 27
group Change
{
    float goldSupply = kbResourceGet(cResourceGold);
	
    if ((kbGetAge() < cAge3) && (goldSupply < 700))
	return;
    createSimpleResearchPlan(cTechElixirofImmortality, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();	
}

//Sunwukong
//the unit picker decides.

//Huangdi
//==============================================================================
// RULE: getStoneArmor
//==============================================================================
rule getStoneArmor
inactive
minInterval 27
group Huangdi
{
    
    float woodSupply = kbResourceGet(cResourceWood);
    if ((kbGetAge() < cAge3 && woodSupply < 600) || (kbUnitCount(cMyID, cUnitTypeTerracottaSoldier, cUnitStateAlive) < 3))
	return;
    createSimpleResearchPlan(cTechStoneArmor, -1, cMilitaryEscrowID, 1);
    xsDisableSelf();	
}

//==============================================================================
// RULE: getFiveGrains
//==============================================================================
rule getFiveGrains
inactive
minInterval 27
group Huangdi
{
    createSimpleResearchPlan(cTechFiveGrains, -1, cEconomyEscrowID, 75);
    xsDisableSelf();	
}

//Dabogong

//==============================================================================
// RULE: getLandlordSpirit
//==============================================================================
rule getLandlordSpirit
inactive
minInterval 45
group Dabogong
{
    float foodSupply = kbResourceGet(cResourceFood);
	if ((foodSupply < 600) || (kbGetAge() < cAge4))
	return;
    createSimpleResearchPlan(cTechLandlordSpirit, -1, cEconomyEscrowID, 10);
    xsDisableSelf();	
}


//==============================================================================
// RULE: getBurials
//==============================================================================
rule getBurials
inactive
minInterval 27
group Dabogong
{
    createSimpleResearchPlan(cTechBurials, -1, cMilitaryEscrowID, 50);
    xsDisableSelf();
}

//==============================================================================
// RULE: getHouseAltars
//==============================================================================
rule getHouseAltars
inactive
minInterval 27
group Dabogong
{
    createSimpleResearchPlan(cTechHouseAltars, -1, cEconomyEscrowID, 50);
    xsDisableSelf();	
}

// Zhongkui

//==============================================================================
// RULE: getLifeDrain
//==============================================================================
rule getLifeDrain
inactive
minInterval 60
group Zhongkui
{
    float goldSupply = kbResourceGet(cResourceGold);
    if ((goldSupply < 1000) || (kbUnitCount(cMyID, cUnitTypeJiangshi, cUnitStateAlive) < 2))
	return;
    createSimpleResearchPlan(cTechLifeDrain, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}


//==============================================================================
// RULE: getDemonSlayer
//==============================================================================
rule getDemonSlayer
inactive
minInterval 40
group Zhongkui
{
    createSimpleResearchPlan(cTechDemonSlayer, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}

// Hebo

//==============================================================================
// RULE: getSacrifices
//==============================================================================
rule HeboMiscUpg
inactive
minInterval 30
group Hebo
{
	createSimpleResearchPlan(cTechSacrifices, -1, cMilitaryEscrowID, 10);
	createSimpleResearchPlan(cTechRammedEarth, -1, cMilitaryEscrowID, 10);
	xsDisableSelf();
}

// Xiwangmu
//==============================================================================
// RULE: getTigerSpirit
//==============================================================================
rule getTigerSpirit
inactive
minInterval 27
group Xiwangmu
{
    if (kbUnitCount(cMyID, cUnitTypeWhiteTiger, cUnitStateAlive) < 2)
	return;
    createSimpleResearchPlan(cTechTigerSpirit, -1, cMilitaryEscrowID, 10);
    xsDisableSelf();
}


// Chongli
//==============================================================================
// RULE: getHeavenlyFire
//==============================================================================
rule getHeavenlyFire
inactive
minInterval 10
group Chongli
{
    int techID = cTechHeavenlyFire;
    int techStatus = kbGetTechStatus(techID);
    if ((techStatus > cTechStatusResearching) || (techStatus < cTechStatusAvailable))
    {
        //cTechHeavenlyFire is researched, reactivate the attack goal
        aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0, false);
        if (ShowAiEcho == true) aiEcho("reactivating attack goal");
        xsDisableSelf();
        return;
	}
    
    if (aiPlanGetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0) == false)
    {
        //set the gLandAttackGoalID to idle so that no armory techs get researched
        aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0, true);
        if (ShowAiEcho == true) aiEcho("setting gLandAttackGoalID to idle");
        xsSetRuleMinIntervalSelf(10);
	}
    
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
	return;
    
	createSimpleResearchPlan(techID, -1, cMilitaryEscrowID, 100);
	xsSetRuleMinIntervalSelf(11);
}

// Aokuang
//==============================================================================
// RULE: getNezhasDefeat
//==============================================================================
rule getNezhasDefeat
inactive
minInterval 27
group Aokuang
{
	createSimpleResearchPlan(cTechNezhasDefeat, -1, cMilitaryEscrowID, 10);
	xsDisableSelf();
}

//==============================================================================
// RULE: getEastSea
//==============================================================================
rule getEastSea
inactive
minInterval 27
group Aokuang
{
    if (gTransportMap == true)
	createSimpleResearchPlan(cTechEastSea, -1, cMilitaryEscrowID, 10);
	xsDisableSelf();
}

//==============================================================================
//Chinese END
//==============================================================================