//AoModAITechsA.xs
//This file contains all Chinese god specific techs.
//by Reth


//Chinese
//NuWa
//==============================================================================
// RULE: getAcupuncture
//==============================================================================
rule getAcupuncture
    inactive
    minInterval 30
{
    float foodSupply = kbResourceGet(cResourceFood);
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (foodSupply < 1000))
        return;
    if (kbGetTechStatus(cTechAcupuncture) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Acupuncture", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechAcupuncture);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetEscrowID(x, cEconomyEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Acupuncture");
    }
}

//FuXi
//==============================================================================
// RULE: getDomestication
//==============================================================================
rule getDomestication
    inactive
    minInterval 50
{
    float woodSupply = kbResourceGet(cResourceWood);
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (woodSupply < 500))
        return;
    if (kbGetTechStatus(cTechDomestication) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Domestication", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechDomestication);
        aiPlanSetDesiredPriority(x, 15);
        aiPlanSetEscrowID(x, cEconomyEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Domestication");
    }
}

//Shennong
//==============================================================================
// RULE: getWheelbarrow
//==============================================================================
rule getWheelbarrow
    inactive
    minInterval 25
{
    int techID = cTechWheelbarrow;
    int techStatus = kbGetTechStatus(techID);
	
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Wheelbarrow", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 100);
        aiPlanSetEscrowID(x, cEconomyEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting Wheelbarrow");
        xsSetRuleMinIntervalSelf(300);
    }
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
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    float goldSupply = kbResourceGet(cResourceGold);
	
    if (kbGetAge() < cAge3 && goldSupply < 650)
	return;
    if (kbGetTechStatus(cTechElixirofImmortality) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("ElixirofImmortality", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechElixirofImmortality);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting ElixirofImmortality");
    }
}

//Sunwukong
//==============================================================================
// RULE: getGoldenBandedStaff
//==============================================================================
rule getGoldenBandedStaff
    inactive
    minInterval 30
    group Sunwukong
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    float woodSupply = kbResourceGet(cResourceWood);
	
    if ((kbGetAge() < cAge3 && woodSupply < 650) || (kbUnitCount(cMyID, cUnitTypeMonkeyKing, cUnitStateAlive) < 1))
	return;
    if (kbGetTechStatus(cTechGoldenBandedStaff) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("GoldenBandedStaff", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechGoldenBandedStaff);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);	
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting GoldenBandedStaff");
    }
}


//Huangdi


//==============================================================================
// RULE: getStoneArmor
//==============================================================================
rule getStoneArmor
    inactive
    minInterval 27
    group Huangdi
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    float woodSupply = kbResourceGet(cResourceWood);
	
    if ((kbGetAge() < cAge3 && woodSupply < 650) || (kbUnitCount(cMyID, cUnitTypeTerracottaSoldier, cUnitStateAlive) < 1))
	return;
    if (kbGetTechStatus(cTechStoneArmor) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("StoneArmor", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechStoneArmor);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting StoneArmor");
    }
}

//==============================================================================
// RULE: getFiveGrains
//==============================================================================
rule getFiveGrains
    inactive
    minInterval 27
    group Huangdi
{
    if (kbGetTechStatus(cTechFiveGrains) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("FiveGrains", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechFiveGrains);
        aiPlanSetDesiredPriority(x, 75);
        aiPlanSetEscrowID(x, cEconomyEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting FiveGrains");
    }
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
	if (foodSupply < 400)
	return;
	
    if (kbGetTechStatus(cTechLandlordSpirit) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LandlordSpirit", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLandlordSpirit);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cEconomyEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting LandlordSpirit");
    }
}


//==============================================================================
// RULE: getBurials
//==============================================================================
rule getBurials
    inactive
    minInterval 27
    group Dabogong
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechBurials) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Burials", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechBurials);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);	
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Burials");
    }
}

//==============================================================================
// RULE: getHouseAltars
//==============================================================================
rule getHouseAltars
    inactive
    minInterval 27
    group Dabogong
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechHouseAltars) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("HouseAltars", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechHouseAltars);
        aiPlanSetDesiredPriority(x, 50);
        aiPlanSetEscrowID(x, cEconomyEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting HouseAltars");
    }
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
    if ((gAgeFaster == true && kbGetAge() < AgeFasterStop) || (goldSupply < 1000) || (kbUnitCount(cMyID, cUnitTypeJiangshi, cUnitStateAlive) < 1))
        return;
    if (kbGetTechStatus(cTechLifeDrain) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("LifeDrain", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechLifeDrain);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);	
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting LifeDrain");
    }
}


//==============================================================================
// RULE: getDemonSlayer
//==============================================================================
rule getDemonSlayer
    inactive
    minInterval 40
    group Zhongkui
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechDemonSlayer) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("DemonSlayer", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechDemonSlayer);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting DemonSlayer");
    }
}

// Hebo

//==============================================================================
// RULE: getSacrifices
//==============================================================================
rule getSacrifices
    inactive
    minInterval 30
    group Hebo
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechSacrifices) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("Sacrifices", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechSacrifices);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cEconomyEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting Sacrifices");
    }
}

//==============================================================================
// RULE: getRammedEarth
//==============================================================================
rule getRammedEarth
    inactive
    minInterval 27
    group Hebo
{
    if (gAgeFaster == true && kbGetAge() < AgeFasterStop)
        return;
    if (kbGetTechStatus(cTechRammedEarth) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("RammedEarth", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechRammedEarth);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cEconomyEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting RammedEarth");
    }
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
    if (kbGetTechStatus(cTechTigerSpirit) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("TigerSpirit", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechTigerSpirit);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting TigerSpirit");
    }
}

//==============================================================================
// RULE: getCelestialPalace
//==============================================================================
rule getCelestialPalace
    inactive
    minInterval 27
    group Xiwangmu
{
    if (kbGetTechStatus(cTechCelestialPalace) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("CelestialPalace", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechCelestialPalace);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);		
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting CelestialPalace");
    }
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
    
    if (techStatus == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("cTechHeavenlyFire", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 100);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting cTechHeavenlyFire");
        xsSetRuleMinIntervalSelf(11);
    }
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
    if (kbGetTechStatus(cTechNezhasDefeat) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("NezhasDefeat", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechNezhasDefeat);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);	
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting NezhasDefeat");
    }
}

//==============================================================================
// RULE: getEastSea
//==============================================================================
rule getEastSea
    inactive
    minInterval 27
    group Aokuang
{
    if (gTransportMap == false)
    {
        xsDisableSelf();
        return;
    }
	
    if (kbGetTechStatus(cTechEastSea) == cTechStatusAvailable)
    {
        int x=-1;
        x = aiPlanCreate("EastSea", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, cTechEastSea);
        aiPlanSetDesiredPriority(x, 10);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        xsDisableSelf();
        if (ShowAiEcho == true) aiEcho("Getting EastSea");
    }
}

//==============================================================================
rule getEarthenWall
    inactive
    minInterval 37 //starts in cAge2
{
    int techID = cTechEarthenWall;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {
        xsEnableRule("getStoneWall");
        xsDisableSelf();
        return;
    }

    if (ShowAiEcho == true) aiEcho("getEarhernWall:");


    
    if ((kbGetTechStatus(cTechWatchTower) < cTechStatusResearching) && (gTransportMap == false))
        return;
    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;	
    
    if (kbGetTechStatus(techID) == cTechStatusAvailable)
    {
        int x = aiPlanCreate("getEarthenWall", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 98);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);

    }
}

//==============================================================================
rule getGreatWall
    inactive
    minInterval 37 //starts in cAge2 activated in getStoneWall
{
    int techID = cTechGreatWall;
    if (kbGetTechStatus(techID) > cTechStatusResearching)
    {		
			
        xsDisableSelf();
        return;
    }
    
    if (ShowAiEcho == true) aiEcho("getGreatWall:");

    if (kbGetTechStatus(cTechStoneWallChinese) < cTechStatusResearching)
    {
        return;
    }

    if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) >= 0)
        return;
    
    int numFortresses = kbUnitCount(cMyID, cUnitTypeAbstractFortress, cUnitStateAliveOrBuilding);
    if (numFortresses < 1)
        return;
    
    float goldSupply = kbResourceGet(cResourceGold);
    float foodSupply = kbResourceGet(cResourceFood);    
    if ((goldSupply < 600) || (foodSupply < 750))
        return;
        

    static int count = 0;        
    if (count < 1)
    {
        count = count + 1;
        return;
    }

    if (kbGetTechStatus(techID) == cTechStatusAvailable)
    {
        int x = aiPlanCreate("GreatWall", cPlanResearch);
        aiPlanSetVariableInt(x, cResearchPlanTechID, 0, techID);
        aiPlanSetDesiredPriority(x, 90);
        aiPlanSetEscrowID(x, cMilitaryEscrowID);
        aiPlanSetActive(x);
        if (ShowAiEcho == true) aiEcho("Getting Great Wall");
    }
}
